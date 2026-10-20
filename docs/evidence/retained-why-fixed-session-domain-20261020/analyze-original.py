#!/usr/bin/env python3
"""Replay new fixed-session projections and count each actual forest offline.

No target, solver, compiler or capture is started. A projection diagnostic
limit or successful sample is not a universal capacity conclusion.
"""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import struct
import tempfile
import time

HERE = Path(__file__).resolve().parent
EVIDENCE = HERE.parent


def identity(path):
    raw = path.read_bytes()
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


class Reader:
    def __init__(self, path):
        self.file = path.open()
        self.count = 0

    def read(self, address, size):
        row = json.loads(self.file.readline())
        assert (row['address'], row['bytes']) == (address, size), ('read sequence differs', self.count)
        raw = bytes.fromhex(row['hex'])
        assert len(raw) == size
        self.count += 1
        return raw


def analyze(capture, output, scratch):
    start = time.perf_counter()
    plan_path = capture.parent.parent / 'plan.json'
    plan = json.loads(plan_path.read_text())
    case, = [row for row in plan['inputs'] if row['name'] == capture.parent.name]
    get = lambda name: json.loads((capture / name).read_text())
    summary, process, result = get('summary.json'), get('process.json'), get('result.json')
    assert result['completed'] and result['returncode'] == 0 and not result['timed_out']
    assert summary['completed'] and not summary['failures'] and not summary['guard_hits']
    assert all(row['hits'] == 0 for row in summary['forbidden_calls'].values())
    assert process['argv'] == case['argv'] and process['environment'] == case['environment']
    assert identity(capture.parent / case['argv'][-1]) == plan['file_identities'][str(capture.parent / case['argv'][-1])]
    symbols = get('session-symbols.json')
    observer_path = capture.parent.parent / 'session_observer.py'
    assert identity(observer_path) == plan['file_identities'][str(observer_path)]
    observer_api = load('fixed_session_observer_replay', observer_path)
    reader = Reader(capture / 'memory-reads.jsonl')
    scratch.mkdir(parents=True, exist_ok=True)
    try:
        for name, spec in plan['session_observer']['symbols'].items():
            actual = symbols['checks'][name]
            assert actual['address'] == symbols['load_bias'] + spec['elf_value']
            if 'code_hex' in spec:
                assert reader.read(actual['address'], len(bytes.fromhex(spec['code_hex']))).hex() == spec['code_hex'] == actual['code_hex']
        with tempfile.TemporaryDirectory(prefix='fixed-session-replay-', dir=scratch) as directory:
            out = Path(directory)
            observer = observer_api.SessionCapture(reader.read,
                lambda name: symbols['checks'][name]['address'], out, plan['session_observer']['limits'])
            try:
                assert observer.capture_roots()['complete']
                assert observer.capture_session()['complete']
                assert observer.capture_helpers()['complete']
            finally:
                observer.close()
            files = sorted(path.name for path in out.iterdir())
            for name in files:
                assert identity(capture / name) == identity(out / name), ('replay output differs', name)
            # The next read belongs to the separately recorded private-counter
            # observer, rather than being falsely claimed as consumed here.
            following = json.loads(reader.file.readline())
            first_name, first_spec = next(iter(plan['shared_observer']['symbols'].items()))
            ident = get('identifier-state.json')
            assert following['address'] == ident['instruction_checks'][first_name]['address']
            assert following['hex'] == first_spec['first32'] and following['bytes'] == 32
    finally:
        reader.file.close()
    blocks = {}
    with (capture / 'session-blocks.jsonl').open() as stream:
        for line in stream:
            row = json.loads(line)
            assert str(row['address']) not in blocks
            assert int.from_bytes(bytes.fromhex(row['header_hex']), 'little') == row['header']
            assert row['tag'] == row['header'] & 255 and row['words'] == row['header'] >> 10
            raw = bytes.fromhex(row['payload_hex'])
            assert len(raw) == row['words'] * 8
            row['fields'] = list(struct.unpack('<' + 'Q' * row['words'], raw))
            blocks[str(row['address'])] = row
    binder_path = EVIDENCE / 'retained-why-session-save-state-20261019/binders.py'
    cert = load('fixed_session_binders', binder_path).certificate(
        blocks, get('session-task-chains.json'), get('session-forest.json'))
    roots = get('session-result.json')['logical_graph']['roots']
    assert set(roots) == {p for task in cert['tasks'].values() for p in task['logical_declarations']}
    refiner_path = EVIDENCE / 'retained-why-inline-refinement-20261018/refine.py'
    refiner = load('fixed_session_refiner', refiner_path).Refiner({'blocks': blocks, 'roots': roots})
    for pointer, row in cert['formulas'].items():
        nodes, binders, _, _ = refiner.dimensions(refiner.open(int(pointer)))
        assert (nodes, binders) == (row['opened_term_occurrences'], row['opened_binder_occurrences'])
    facts = {'scope': 'Per-process raw-task forest and conditional binder charge; not complete ending or preparation capacity',
        'case': case['name'], 'pid': process['pid'], 'endpoint': plan['endpoint']['symbol'],
        'source_inputs': {'plan': identity(plan_path), 'process': identity(capture / 'process.json'),
            'input_json': identity(capture.parent / case['argv'][-1]),
            'session_observer': identity(observer_path), 'binders': identity(binder_path), 'refiner': identity(refiner_path)},
        'exact_session_replay': {'sequential_reads': reader.count, 'byte_equal_files': files,
            'remaining_memory_log': 'counter, representative and auxiliary reads retained; not claimed replayed here'},
        'raw_task_values': len(cert['tasks']), 'forest_visits': len(cert['visits']),
        'distinct_formulas': len(cert['formulas']), 'B_binders': cert['B_binders'],
        'explicit_alpha_crosschecked_formulas': len(cert['formulas']),
        'full_certificate': cert, 'native_executions_by_analyzer': 0,
        'ordinary_ending_capacity_established': False, 'all_pair_preparation_capacity_established': False,
        'elapsed_seconds': time.perf_counter() - start}
    output.write_text(json.dumps(facts, indent=2) + '\n')
    print(json.dumps({key: facts[key] for key in ['case','pid','raw_task_values','forest_visits','distinct_formulas','B_binders','elapsed_seconds']}))


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--capture', type=Path, required=True)
    parser.add_argument('--output', type=Path, required=True)
    parser.add_argument('--scratch', type=Path, required=True)
    args = parser.parse_args()
    analyze(args.capture, args.output, args.scratch)
