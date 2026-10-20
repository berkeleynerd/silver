#!/usr/bin/env python3
"""Independent manifest/output joins and narrow Reader rejection probes.

This does not rerun observers, native captures, binder analyses or predecessor
checkers. Read logs are streamed for identity/count/boundary checks only.
"""
from pathlib import Path
import ast
import hashlib
import importlib.util
import io
import json
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
AUTHOR = HERE.parent / 'retained-why-fixed-registration-state-20261020'
DOMAIN = HERE.parent / 'retained-why-fixed-session-domain-20261020'
TARGET = 'e6e063c800d38620050960f2b7cae97dbc02305b'


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def main():
    started = time.perf_counter()
    target_paths = subprocess.check_output(
        ['git', 'diff-tree', '--no-commit-id', '--name-only', '-r', TARGET],
        cwd=ROOT, text=True).splitlines()
    assert len(target_paths) == 6
    inputs = {}
    for path in target_paths:
        raw = (ROOT / path).read_bytes()
        assert raw == subprocess.check_output(['git', 'show', TARGET + ':' + path], cwd=ROOT)
        inputs[path] = identity(raw)
    author = load('registration_author_reviewed', AUTHOR / 'check.py')
    dependencies = json.loads((AUTHOR / 'inputs.json').read_text())['dependencies']
    for path, expected in dependencies.items():
        assert author.file_identity(ROOT / path) == expected
        inputs[path] = expected
    for path in ('oracle.md', 'docs/evidence/retained-why-fixed-session-domain-20261020/analyze.py',
                 'docs/reviews/review-why-fixed-session-domain-20261020.md'):
        inputs[path] = identity((ROOT / path).read_bytes())
    manifest = json.loads((DOMAIN / 'capture-manifest.json').read_text())
    cases = json.loads((DOMAIN / 'summary.json').read_text())['cases'][:4]
    saved = {}
    for name in ('is-message-result.json', 'other-cases-result.json'):
        result = json.loads((AUTHOR / name).read_text())
        assert not result['ordinary_ending_capacity_established'] and not result['issue153_complete']
        assert result['native_runs'] == result['binder_analyses'] == result['accepted_session_replays_repeated'] == 0
        for row in result['cases']:
            assert row['case'] not in saved
            saved[row['case']] = row
    assert set(saved) == {row['case'] for row in cases}
    sys.path.insert(0, str(HERE.parent / 'retained-why-inline-identifier-state-20261018'))
    counter = load('registration_counter_reviewed', HERE.parent / 'retained-why-inline-identifier-state-20261018/compose.py')
    representative = load('registration_representative_reviewed', HERE.parent / 'retained-why-inline-representative-state-20261018/project.py')
    common_spec, = [r for r in manifest['archives'] if r['path'] == 'capture-common.tar.gz']
    common = author.Packet(common_spec)
    joined = []
    try:
        plan = common.json('plan.json')
        probe = common.raw('probe.py').decode()
        tree = ast.parse(probe)
        names = {'u64', 'block_fields', 'raw_graph', 'capture_fixed_session'}
        functions = {n.name: n for n in tree.body if isinstance(n, ast.FunctionDef) and n.name in names}
        assert set(functions) == names
        capture = ast.get_source_segment(probe, functions['capture_fixed_session'])
        ordered = ['session.capture_helpers()', 'capture_identifier()', 'read_table_state()',
                   'raw_graph(table_roots)', 'capture_auxiliary()', '_memory_log.close()']
        assert [capture.index(s) for s in ordered] == sorted(capture.index(s) for s in ordered)
        sources = {'probe.py': [{
            'name': n, 'first': node.lineno, 'last': node.end_lineno,
            'sha256': identity(ast.get_source_segment(probe, node).encode())['sha256']
        } for n, node in functions.items()]}
        for name in ('snapshot-observer.py', 'table-observer.py'):
            raw = common.raw(name)
            sources[name] = identity(raw)
        first_name, first_spec = next(iter(plan['shared_observer']['symbols'].items()))
        for case in cases:
            name = case['case']
            row = saved[name]
            analysis_path = ROOT / case['source_analysis']
            assert author.file_identity(analysis_path) == case['analysis_identity']
            inputs[case['source_analysis']] = case['analysis_identity']
            analysis = json.loads(analysis_path.read_text())
            skip = case['exact_session_replay']['sequential_reads']
            assert skip == analysis['exact_session_replay']['sequential_reads'] == row['accepted_prefix_reads_not_replayed']
            spec, = [s for s in manifest['archives'] if s['path'] == 'capture-' + name.replace('_', '-') + '.tar.gz']
            packet = author.Packet(spec)
            try:
                prefix = name + '/capture/'
                get = lambda n: packet.json(prefix + n)
                summary, process, capture_result = [get(n) for n in ('summary.json', 'process.json', 'result.json')]
                selected, = [c for c in plan['inputs'] if c['name'] == name]
                assert row['pid'] == case['pid'] == process['pid'] == analysis['pid']
                assert row['endpoint'] == case['endpoint'] == plan['endpoint']['symbol'] == analysis['endpoint']
                assert row['phase'] == case['phase']
                assert process['argv'] == selected['argv'] and process['environment'] == selected['environment']
                assert process['initial_threads'] == 1 and not summary['new_threads']
                assert summary['completed'] and not summary['failures'] and not summary['guard_hits']
                assert not summary.get('auxiliary_failures')
                assert all(r['hits'] == 0 for r in summary['forbidden_calls'].values())
                assert capture_result['completed'] and capture_result['returncode'] == 0 and not capture_result['timed_out']
                assert not capture_result['failures']
                ident, table, aux = [get(n) for n in ('identifier-state.json', 'hsdecl-table.json', 'auxiliary-state.json')]
                for filename, key in (('identifier-state.json', 'identifier_state'), ('hsdecl-table.json', 'hsdecl_table'),
                                      ('auxiliary-state.json', 'auxiliary_state')):
                    assert identity(packet.raw(prefix + filename)) == summary[key]['identity']
                assert representative.decoded(ident['counter']['fields'][0]) == ident['counter']['decoded'] == row['private_identifier_counter'] == summary['identifier_state']['counter']
                for key in ('next_tag', 'outer_length', 'allocated_key_slots', 'nonempty_key_slots', 'limit', 'oversize', 'rover'):
                    assert row['Hsdecl'][key] == table[key]
                assert row['Hsdecl']['maximum_bucket_length'] == max(len(r['payload']) - 2 for r in table['buckets'])
                assert row['Hsdecl']['retained_unique_declarations'] == len(table['retained_unique_declarations'])
                assert not row['Hsdecl']['continuing_capacity_established']
                assert row['representative_graph_blocks'] == summary['representative_graph']['blocks']
                observed = json.loads(json.dumps(counter.auxiliary_observations(aux, representative.decoded)))
                assert observed == row['auxiliary_observations']
                assert len(observed) == 4 and all(not r['continuing_capacity_established'] for r in observed.values())
                log_name = prefix + 'memory-reads.jsonl'
                digest, size, count, boundary = hashlib.sha256(), 0, 0, None
                with packet.archive.extractfile(log_name) as stream:
                    for count, line in enumerate(stream, 1):
                        digest.update(line)
                        size += len(line)
                        if count == skip + 1:
                            boundary = json.loads(line)
                assert {'bytes': size, 'sha256': digest.hexdigest()} == {k: packet.members[log_name][k] for k in ('bytes', 'sha256')}
                assert boundary == {'address': ident['instruction_checks'][first_name]['address'],
                                    'bytes': 32, 'hex': first_spec['first32']}
                assert count == row['total_read_log_lines_hashed']
                assert count - skip == row['suffix_reads_replayed_in_order']
                joined.append({'case': name, 'pid': row['pid'], 'prefix_reads': skip,
                               'suffix_reads': count - skip, 'total_lines_hashed': count,
                               'private_identifier_counter': row['private_identifier_counter'],
                               'Hsdecl_next_tag': row['Hsdecl']['next_tag']})
            finally:
                packet.archive.close()
    finally:
        common.archive.close()

    def encoded(address, size, payload):
        return (json.dumps({'address': address, 'bytes': size, 'hex': payload}) + '\n').encode()
    prefix = encoded(16, 2, 'abcd')
    suffix = encoded(32, 2, '1234')
    good = prefix + suffix
    reader = author.Reader(io.BytesIO(good))
    reader.line()
    assert reader.read(32, 2) == bytes.fromhex('1234')
    reader.finish(identity(good))
    rejected = []

    def rejects(name, body):
        try:
            body()
        except (AssertionError, ValueError):
            rejected.append(name)
        else:
            raise AssertionError('probe unexpectedly accepted: ' + name)

    def read_one(raw, address=32, size=2):
        return author.Reader(io.BytesIO(raw)).read(address, size)

    def finish_after(raw, count, expected):
        r = author.Reader(io.BytesIO(raw))
        for _ in range(count):
            r.line()
        r.finish(expected)

    rejects('wrong_address', lambda: read_one(suffix, address=40))
    rejects('wrong_requested_size', lambda: read_one(suffix, size=1))
    rejects('short_payload', lambda: read_one(encoded(32, 2, '12')))
    rejects('truncated_log', lambda: read_one(b''))
    rejects('unconsumed_suffix', lambda: finish_after(good, 1, identity(good)))
    rejects('changed_prefix', lambda: finish_after(encoded(16, 2, 'abce') + suffix, 2, identity(good)))
    rejects('changed_payload', lambda: finish_after(prefix + encoded(32, 2, '1235'), 2, identity(good)))
    rejects('reordered_rows', lambda: read_one(suffix + prefix, address=16))
    output = dict(review_target=TARGET, disposition='accept bounded stopped-state suffix replay; no material finding',
                  exact_target_files=len(target_paths), inputs=inputs, source_review=sources,
                  case_joins=joined, reader_positive_probe='passed', reader_rejection_probes=rejected,
                  full_suffix_replays_repeated=0, accepted_prefix_replays_repeated=0,
                  native_runs=0, binder_analyses=0, source_semantics_machine_proved=False,
                  continuing_capacity_established=False, freshness_established=False,
                  elapsed_seconds=time.perf_counter()-started)
    (HERE / 'result.json').write_text(json.dumps(output, indent=2) + '\n')
    print(json.dumps({k: output[k] for k in ('disposition', 'exact_target_files', 'reader_rejection_probes', 'elapsed_seconds')}))


if __name__ == '__main__':
    main()
