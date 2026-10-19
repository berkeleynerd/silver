#!/usr/bin/env python3
"""Offline fixtures for retained bytes, lookup/visit multiplicity and failures."""
import json
import hashlib
from pathlib import Path
import struct
import tempfile
import unittest

from session_observer import SessionCapture, RawStore, ProjectionError, DEFAULT_LIMITS
from replay import replay as replay_capture


def integer(n):
    return ((n << 1) | 1) & ((1 << 64) - 1)


class Memory:
    def __init__(self):
        self.memory = {}
        self.next = 0x10000
        self.reads = []
        self.symbols = {name: 0x1000 + 0x1000 * i for i, name in enumerate([
            'caml_signal_handlers', 'camlStdlib', 'camlWhy3__Debug',
            'camlGnat_main__fun_14206', 'camlStdlib__new_exit_481',
            'camlWhy3__Debug__fun_3073'])}

    def put(self, address, raw):
        self.memory.update({address + i: b for i, b in enumerate(raw)})

    def word(self, address, value):
        self.put(address, struct.pack('<Q', value))

    def block(self, fields, tag=0):
        pointer = self.next + 8
        self.word(self.next, len(fields) << 10 | tag)
        self.put(pointer, struct.pack('<' + 'Q' * len(fields), *fields))
        self.next += (len(fields) + 1) * 8
        return pointer

    def string(self, value):
        raw = value.encode() + b'\0'
        raw += b'\0' * (-len(raw) % 8)
        return self.block(struct.unpack('<' + 'Q' * (len(raw) // 8), raw), 252)

    def lst(self, values):
        result = 1
        for value in reversed(values):
            result = self.block([value, result])
        return result

    def table(self, rows, int_keys=True):
        heads = [1, 1, 1, 1]
        # Input order is desired bucket order, including duplicate keys.
        for key, value in reversed(rows):
            bucket = ((key >> 1) & 3) if int_keys else 0
            heads[bucket] = self.block([key, value, heads[bucket]])
        array = self.block(heads)
        return self.block([integer(len(rows)), array, integer(0), integer(4)])

    def read(self, address, size):
        raw = bytes(self.memory[address + i] for i in range(size))
        self.reads.append({'address': address, 'bytes': size, 'hex': raw.hex()})
        return raw

    def resolve(self, name):
        return self.symbols[name]


def fixture(detached=False, duplicate=False, cycle=False, bad_helper=False, bad_graph=False):
    m = Memory()
    # Opaque scalar and shared ordinary node exercise the non-pointer boundary.
    scalar = m.block([0x1122334455667788], 253)
    leaf = m.block([integer(2), scalar])
    declaration = m.block([leaf, leaf], 247 if bad_graph else 0)
    td = m.block([m.block([declaration]), integer(0)])
    head = m.block([td, 1, 1, 1, 1, integer(0)])
    task = m.block([head])
    other_task = m.block([m.block([td, 1, 1, 1, 1, integer(1)])])
    theory = m.block([m.string('Theory'), m.lst([integer(1), integer(1)]), integer(0), 1])
    pn = m.block([m.string('Goal'), m.string('Explanation'), m.block([theory], 1),
                  m.table([], False), m.lst([integer(1)]) if cycle else 1])
    file = m.block([integer(0), m.string('input.gnat-json'), m.string('gnat-json'),
                    1, m.lst([theory])])
    task_rows = [] if detached else [(integer(1), task)]
    if duplicate:
        task_rows.append((integer(1), other_task))
    trans = m.block([m.string('split'), 1, m.lst([integer(1)]), integer(1), 1])
    fields = [m.table([]), integer(0), m.table([(integer(1), pn)]), integer(2),
              m.table([(integer(1), trans)] if cycle else []), integer(0), integer(1),
              m.string('session'), m.table([(integer(0), file)]), m.table([], False),
              m.block([integer(6), 3, 1, 1, 1, 1]), m.table(task_rows),
              m.table([]), m.table([]), m.table([], False), m.table([]), m.table([])]
    session = m.block(fields)
    controller = m.block([session, 1, 1, 1, 1, 1])
    signal = m.block([m.resolve('camlGnat_main__fun_14206'), 0x100000000000005,
                      controller, 1], 247)
    handlers = m.block([1, 1, signal, 1])
    m.word(m.resolve('caml_signal_handlers'), handlers)
    printer = m.block([0x900000, 0x100000000000005], 247)
    terminal = m.block([0x900100, 0x100000000000005], 247)
    gate = m.block([3])
    exit_link = m.block([m.resolve('camlStdlib__new_exit_481'), 0x100000000000005,
                         printer, gate, terminal], 247)
    exit_ref = m.block([exit_link, 1] if bad_helper else [exit_link])
    m.word(m.resolve('camlStdlib') + 0x338, exit_ref)
    stat = m.block([leaf, printer, m.string('stat')])
    wrapper = m.block([m.resolve('camlWhy3__Debug__fun_3073'), 0x100000000000005, stat], 247)
    stats = m.block([m.lst([wrapper])])
    m.word(m.resolve('camlWhy3__Debug') + 0x128, stats)
    m.word(m.resolve('camlWhy3__Debug') + 0x70, m.block([m.string('stats'), 3]))
    m.word(m.resolve('camlWhy3__Debug') + 0x80, m.block([m.block([printer, 1])]))
    m.word(m.resolve('camlWhy3__Debug') + 0x108,
           m.table([(m.string('phase'), m.block([scalar, integer(1)]))], False))
    return m, {'task': task, 'other_task': other_task, 'session': session,
               'signal': signal, 'raw_table': fields[11], 'declaration': declaration}


class Replay:
    def __init__(self, rows):
        self.rows = iter(rows)
        self.count = 0

    def read(self, address, size):
        row = next(self.rows)
        if (address, size) != (row['address'], row['bytes']):
            raise AssertionError(('replay request differs', address, size, row))
        self.count += 1
        return bytes.fromhex(row['hex'])

    def exhausted(self):
        return next(self.rows, None) is None


class ObserverTests(unittest.TestCase):
    def setUp(self):
        # Small disposable fixtures stay on the repository filesystem.
        self.temp = tempfile.TemporaryDirectory(prefix='observer-fixture-', dir=SCRATCH)
        self.out = Path(self.temp.name)

    def tearDown(self):
        self.temp.cleanup()

    def run_capture(self, memory, out=None, limits=None):
        c = SessionCapture(memory.read, memory.resolve, out or self.out, limits)
        c.capture_roots()
        c.capture_session()
        c.capture_helpers()
        c.close()
        return c

    def test_sharing_duplicates_and_exact_read_replay(self):
        memory, addresses = fixture(duplicate=True)
        c = self.run_capture(memory)
        self.assertTrue(c.session_result['complete'])
        self.assertTrue(c.helper_result['complete'])
        self.assertFalse(c.helper_result['complete_R'])
        visits = json.loads((self.out / 'session-forest.json').read_text())['visits']
        self.assertEqual([v['task'] for v in visits], [addresses['task']] * 2)
        self.assertEqual(c.session_result['raw_task_values'], 2)
        blocks = [json.loads(s) for s in (self.out / 'session-blocks.jsonl').read_text().splitlines()]
        self.assertEqual(len(blocks), len({b['address'] for b in blocks}))
        replay_dir = self.out / 'replay'
        replay_dir.mkdir()
        replay = Replay(memory.reads)
        replay.resolve = memory.resolve
        repeated = self.run_capture(replay, replay_dir)
        self.assertTrue(replay.exhausted())
        self.assertEqual(repeated.session_result, c.session_result)
        self.assertEqual(repeated.helper_result, c.helper_result)
        for path in self.out.glob('*.json*'):
            self.assertEqual(path.read_bytes(), (replay_dir / path.name).read_bytes(), path.name)

    def test_missing_raw_task_is_detached(self):
        memory, _ = fixture(detached=True)
        c = self.run_capture(memory)
        self.assertTrue(c.session_result['complete'])
        visits = json.loads((self.out / 'session-forest.json').read_text())['visits']
        self.assertTrue(all(v['detached'] and v['task'] is None for v in visits))

    def test_standalone_replay_on_retained_synthetic_files(self):
        memory, _ = fixture(duplicate=True)
        self.run_capture(memory)
        process = b'{"pid": 101}\n'
        (self.out / 'process.json').write_bytes(process)
        (self.out / 'session-observer.json').write_text(json.dumps({
            'symbols': memory.symbols, 'code_checks': [], 'pid': 101,
            'core_join': {'process.json': {'bytes': len(process),
                                         'sha256': hashlib.sha256(process).hexdigest()}}}))
        (self.out / 'session-memory-reads.jsonl').write_text(
            ''.join(json.dumps(row) + '\n' for row in memory.reads))
        result = replay_capture(self.out, SCRATCH)
        self.assertEqual(result['status'], 'pass')
        self.assertTrue(result['session_complete'])
        self.assertFalse(result['complete_R'])
        (self.out / 'process.json').write_bytes(b'{"pid": 102}\n')
        with self.assertRaisesRegex(AssertionError, 'process.json'):
            replay_capture(self.out, SCRATCH)

    def test_session_cycle_preserves_raw_root_and_failure(self):
        memory, _ = fixture(cycle=True)
        c = self.run_capture(memory)
        self.assertTrue(c.roots['complete'])
        self.assertFalse(c.session_result['complete'])
        self.assertIn('session forest cycle', str(c.session_result['failures']))
        self.assertTrue((self.out / 'session-root.json').is_file())
        self.assertTrue((self.out / 'session-tables.json').is_file())

    def test_helper_failure_does_not_discard_session(self):
        memory, _ = fixture(bad_helper=True)
        c = self.run_capture(memory)
        self.assertTrue(c.session_result['complete'])
        self.assertFalse(c.helper_result['complete'])
        self.assertTrue(c.helper_result['failures'])

    def test_unsupported_logical_closure_retained_before_rejection(self):
        memory, addresses = fixture(bad_graph=True)
        c = self.run_capture(memory)
        self.assertFalse(c.session_result['complete'])
        blocks = [json.loads(s) for s in (self.out / 'session-blocks.jsonl').read_text().splitlines()]
        bad, = [b for b in blocks if b['address'] == addresses['declaration']]
        self.assertEqual(bad['tag'], 247)
        self.assertIn('unsupported runtime block', str(c.session_result['failures']))

    def test_bucket_cycle_and_count_mismatch(self):
        for defect in ['cycle', 'count']:
            memory, addresses = fixture()
            store = RawStore(memory.read, self.out, DEFAULT_LIMITS)
            table = addresses['raw_table']
            buckets = int.from_bytes(memory.read(table + 8, 8), 'little')
            cell = int.from_bytes(memory.read(buckets + 8, 8), 'little')
            if defect == 'cycle':
                memory.word(cell + 16, cell)
            else:
                memory.word(table, integer(3))
            with self.assertRaisesRegex(ProjectionError, 'bucket cycle|table count mismatch'):
                store.table(table)
            store.close()

    def test_distinct_colliding_keys_keep_first_duplicate_binding(self):
        memory = Memory()
        pointer = memory.table([(integer(1), integer(11)), (integer(5), integer(22)),
                                (integer(1), integer(33))])
        store = RawStore(memory.read, self.out, DEFAULT_LIMITS)
        table, lookup = store.table(pointer)
        self.assertEqual([row['key'] for row in table['entries']],
                         [integer(1), integer(5), integer(1)])
        self.assertEqual(lookup, {1: integer(11), 5: integer(22)})
        store.close()

    def test_diagnostic_limit_does_not_create_complete_claim(self):
        memory, _ = fixture()
        limits = dict(DEFAULT_LIMITS, blocks=5)
        c = self.run_capture(memory, limits=limits)
        self.assertFalse(c.session_result['complete'])
        self.assertLessEqual(len(c.store.seen), 5)
        self.assertEqual(len(c.roots['root_words']), 6)


if __name__ == '__main__':
    import argparse
    parser = argparse.ArgumentParser()
    parser.add_argument('--scratch-root', type=Path, required=True)
    args, remaining = parser.parse_known_args()
    SCRATCH = args.scratch_root
    SCRATCH.mkdir(parents=True, exist_ok=True)
    unittest.main(argv=['test_observer.py', *remaining])
