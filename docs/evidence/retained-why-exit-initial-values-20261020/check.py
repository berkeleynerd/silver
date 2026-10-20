#!/usr/bin/env python3
"""Project initial exit values from retained logs; no target execution/replay."""
import argparse
import bisect
import hashlib
import json
from pathlib import Path
import struct
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
CAPTURE = ROOT / 'docs/evidence/retained-why-save-state-capture-20261020'
CASES = ('put_line', 'put', 'first_or_default', 'is_message', 'input_is_valid')
FIELDS = ('pp_scan_stack', 'pp_format_stack', 'pp_tbox_stack', 'pp_tag_stack',
          'pp_mark_stack', 'pp_margin', 'pp_min_space_left', 'pp_max_indent',
          'pp_space_left', 'pp_current_indent', 'pp_is_new_line', 'pp_left_total',
          'pp_right_total', 'pp_curr_depth', 'pp_max_boxes', 'pp_ellipsis',
          'pp_out_string', 'pp_out_flush', 'pp_out_newline', 'pp_out_spaces',
          'pp_out_indent', 'pp_print_tags', 'pp_mark_tags', 'pp_mark_open_tag',
          'pp_mark_close_tag', 'pp_print_open_tag', 'pp_print_close_tag', 'pp_queue')
LOGS = ('memory-reads.jsonl', 'save-state-memory-reads.jsonl')
SOURCE_SPECS = (
    ('docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz',
     (('src/util/debug.ml', 65, 78), ('src/util/debug.ml', 158, 203),
      ('src/gnat/gnat_main.ml', 264, 276), ('src/gnat/gnat_main.ml', 316, 347))),
    ('docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz',
     (('stdlib/format.ml', 136, 189), ('stdlib/hashtbl.ml', 20, 45))))


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def tagged(raw):
    assert raw & 1, raw
    return (raw if raw < 2**63 else raw - 2**64) >> 1


def project(archive, manifest):
    path = CAPTURE / archive['path']
    assert identity(path.read_bytes()) == {k: archive[k] for k in ('bytes', 'sha256')}
    expected = {m['path']: m for m in archive['members']}
    with tarfile.open(path) as tar:
        members = {m.name.rsplit('/', 1)[-1]: m for m in tar if m.isfile()}
        identities = {}

        def small(name):
            member = members[name]
            assert member.size < 4 * 1024 * 1024
            raw = tar.extractfile(member).read()
            got = identity(raw)
            assert got == {k: expected[member.name][k] for k in ('bytes', 'sha256')}
            identities[member.name] = got
            return raw

        roots = json.loads(small('exit-hook-roots.json'))
        process = json.loads(small('process.json'))
        assert roots['complete'] and not roots['failures'] and not roots['unknown_closures']
        assert roots['statistic_values']['roots'] == []
        assert 'GNATWHY3LOG' not in process['environment']
        table = roots['timing_table']
        fmt = roots['formatter_record']
        addresses = {json.loads(line) for line in small('timing-values-addresses.jsonl').splitlines()}
        addresses.update((fmt, table['address'], table['array']))
        addresses.update(e['cell'] for e in table['entries'])
        addresses |= {a - 8 for a in list(addresses)}

        def scan(wanted):
            wanted = sorted(wanted)
            found = {}
            for log in LOGS:
                member = members[log]
                digest = hashlib.sha256()
                size = 0
                for lineno, line in enumerate(tar.extractfile(member), 1):
                    digest.update(line)
                    size += len(line)
                    r = json.loads(line)
                    lo, n = r['address'], r['bytes']
                    i = bisect.bisect_left(wanted, lo)
                    if i < len(wanted) and wanted[i] < lo + n:
                        assert len(bytes.fromhex(r['hex'])) == n
                        while i < len(wanted) and wanted[i] < lo + n:
                            found.setdefault(wanted[i], []).append(
                                {'member': member.name, 'line': lineno, **r})
                            i += 1
                got = {'bytes': size, 'sha256': digest.hexdigest()}
                assert got == {k: expected[member.name][k] for k in ('bytes', 'sha256')}
                identities[member.name] = got
            return found

        reads = scan(addresses)

        def get(addr, count):
            parts = [bytes.fromhex(r['hex'])[addr-r['address']:addr-r['address']+count]
                     for r in reads.get(addr, [])
                     if r['address'] <= addr and addr + count <= r['address'] + r['bytes']]
            assert parts and all(len(p) == count and p == parts[0] for p in parts), (addr, count)
            return parts[0]

        def words(addr, count):
            return struct.unpack('<' + 'Q' * count, get(addr, count * 8))

        def block(addr, count, tag):
            header, = words(addr - 8, 1)
            assert header >> 10 == count and header & 255 == tag, (addr, count, tag, header)
            return words(addr, count)

        values = block(fmt, 28, 0)
        size, backing, seed, initial = block(table['address'], 4, 0)
        assert backing == table['array']
        size, seed, initial = map(tagged, (size, seed, initial))
        header, = words(backing - 8, 1)
        assert header & 255 == 0
        buckets = words(backing, header >> 10)
        entries = {e['cell']: e for e in table['entries']}
        visited = set()
        decoded = []
        for bucket, head in enumerate(buckets):
            while head != 1:
                assert head not in visited
                visited.add(head)
                key, value, nxt = block(head, 3, 0)
                assert entries[head] == {'bucket': bucket, 'cell': head, 'key': key,
                                          'value': value, 'next': nxt}
                h, = words(key - 8, 1)
                assert h & 255 == 252
                raw = get(key, (h >> 10) * 8)
                padding = raw[-1]
                assert padding < 8 and raw[len(raw)-padding-1:-1] == b'\0' * padding
                name = raw[:len(raw)-padding-1].decode('ascii')
                time_addr, count = block(value, 2, 0)
                time_bits, = block(time_addr, 1, 253)
                time_raw = struct.pack('<Q', time_bits)
                decoded.append({'bucket': bucket, 'name': name, 'name_bytes': len(name),
                                'count': tagged(count), 'binary64_le_hex': time_raw.hex(),
                                'python_float_hex': struct.unpack('<d', time_raw)[0].hex()})
                head = nxt
        assert len(visited) == size == len(entries)
        assert len({e['name'] for e in decoded}) == size
        # A second scan answers only whether immediate pointer targets are retained.
        # Scalar values and the record pointer do not prove queue/callback contents.
        targets = {v for v in values if not v & 1}
        target_reads = scan(targets)
        fields = []
        for name, raw in zip(FIELDS, values, strict=True):
            fields.append({'name': name, 'raw': raw, **(
                {'immediate': tagged(raw)} if raw & 1 else
                {'first_byte_covered_in_named_logs': bool(target_reads.get(raw))})})
        # Retain only the exact spans used for interpretation and availability.
        all_reads = { (r['member'], r['line']): r
                      for group in (reads, target_reads)
                      for records in group.values() for r in records }
        return {
            'pid': process['pid'], 'archive': archive['path'],
            'environment': process['environment'], 'formatter_address': fmt,
            'formatter_fields': fields,
            'timing_table': {'entries': size, 'backing_slots': len(buckets), 'seed': seed,
                             'initial_size': initial, 'values': decoded},
            'registered_statistics_roots': roots['statistic_values']['roots'],
            'exit_once_gates_raw': [link['gate'] for link in roots['exit_chain'] if 'gate' in link],
            'member_identities': identities,
            'selected_reads': [r for _, r in sorted(all_reads.items())],
            'complete_formatter_graph': False, 'complete_exit_capacity': False,
            'complete_save_capacity': False,
        }


def compute():
    manifest_path = CAPTURE / 'capture-manifest.json'
    manifest = json.loads(manifest_path.read_text())
    archives = {a['path']: a for a in manifest['archives']}
    cases = []
    for case in CASES:
        archive = archives['capture-' + case.replace('_', '-') + '.tar.gz']
        cases.append({'case': case, **project(archive, manifest)})
    sources = []
    for path, specs in SOURCE_SPECS:
        with tarfile.open(ROOT / path) as tar:
            members = {m.name: m for m in tar if m.isfile()}
            for suffix, first, last in specs:
                member = next(n for n in members if n.endswith('/' + suffix))
                raw = tar.extractfile(member).read()
                sources.append({'archive': path, 'archive_identity': identity((ROOT/path).read_bytes()),
                                'member': member, 'member_identity': identity(raw),
                                'first': first, 'last': last,
                                'text': ''.join(raw.decode().splitlines(keepends=True)[first-1:last])})
    return {'schema': 1, 'manifest_identity': identity(manifest_path.read_bytes()),
            'scope': 'Initial values and named-log availability only; no history or future bound inferred',
            'cases': cases, 'source_witnesses': sources}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true', help='Create initial result; refuses overwrite')
    args = parser.parse_args()
    start = time.monotonic()
    result = compute()
    destination = HERE / 'result.json'
    if args.write:
        with destination.open('x') as out:
            out.write(json.dumps(result, indent=2) + '\n')
    else:
        assert json.loads(destination.read_text()) == result
    print(json.dumps({'ok': True, 'cases': len(result['cases']),
                      'seconds': time.monotonic()-start,
                      'initial_result_created': args.write}))
