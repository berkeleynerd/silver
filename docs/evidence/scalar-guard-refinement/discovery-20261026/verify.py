#!/usr/bin/env python3
"""Check retained bytes, immutable run input captures, diagnostics and doors oracle.

Read-only; invokes no compiler, prover or managed runner. This focused evidence
check is not the Silver report-policy audit or universal/source assurance.
"""
from pathlib import Path
from collections import Counter
import gzip
import hashlib
import json

HERE = Path(__file__).resolve().parent
IMAGE = ('references to the "Image" attribute are handled in an imprecise way, '
         'so nothing will be known about the evaluation of the attribute reference '
         'apart from a bound on its length [imprecise-image]')
MESSAGES = {'VC_RANGE_CHECK': 'range check proved',
            'VC_LENGTH_CHECK': 'length check proved',
            'VC_OVERFLOW_CHECK': 'overflow check proved',
            'VC_DIVISION_CHECK': 'division check proved'}
POSITIVE = {'guards': {'VC_RANGE_CHECK': 24}, 'flow': {'VC_RANGE_CHECK': 7},
            'edges': {'VC_OVERFLOW_CHECK': 7, 'VC_DIVISION_CHECK': 5},
            'conservative': {'VC_DIVISION_CHECK': 2},
            'doors': {'VC_RANGE_CHECK': 3, 'VC_DIVISION_CHECK': 2}}
NEGATIVE = {'stale_replacement': (9, 18, 'VC_RANGE_CHECK'),
            'branch_join': (8, 15, 'VC_RANGE_CHECK'),
            'omitted_else': (8, 15, 'VC_RANGE_CHECK'),
            'loop_reentry': (8, 42, 'VC_RANGE_CHECK'),
            'minimum_negation': (8, 36, 'VC_OVERFLOW_CHECK'),
            'shadowed_mutable': (9, 12, 'VC_RANGE_CHECK')}


def sha(raw):
    return hashlib.sha256(raw).hexdigest()


def read(path):
    path = HERE / path
    raw = path.read_bytes()
    return gzip.decompress(raw) if path.suffix == '.gz' else raw


def load(path):
    return json.loads(read(path))


def raw_main(folder):
    reports = list((HERE / folder / 'reports').glob('main*.spark.gz'))
    assert len(reports) == 1
    return json.loads(gzip.decompress(reports[0].read_bytes()))


def main():
    index = load('retention-index.json')
    for entry in index['inputs']:
        stored = (HERE / entry['retained']).read_bytes()
        raw = read(entry['retained'])
        assert sha(stored) == entry['stored_sha256'], entry['retained']
        assert len(raw) == entry['bytes'] and sha(raw) == entry['sha256'], entry['retained']
    analysis = load('analysis.json')
    assert len(analysis['runs']) == 27
    events_by_run = {}
    for run in analysis['runs']:
        events = [json.loads(line) for line in read(f"runs/{run['run_id']}/events.jsonl.gz").splitlines()]
        events_by_run[run['run_id']] = events
        prepared = next(e for e in events if e['event'] == 'prepared')
        command = next(e for e in events if e['event'] == 'command')
        assert prepared['inputs'] == run['prepared_inputs']
        assert command['command'] == run['command']
    assert len(analysis['source_comparisons']) == 60
    for comparison in analysis['source_comparisons']:
        raw = read(comparison['retained'])
        assert len(raw) > 0 and len(raw) == comparison['bytes']
        prepared = next(e for e in events_by_run[comparison['run_id']] if e['event'] == 'prepared')
        assert sha(raw) == prepared['inputs']['inputs_sha256'][comparison['original']]
    proof_rows, diagnostic_rows = 0, []
    for name, counts in POSITIVE.items():
        report = raw_main(Path('native') / name)
        records = report['proof']
        assert Counter(r['rule'] for r in records) == counts, name
        assert all(r['severity'] == 'info' and r['message']['text'] == MESSAGES[r['rule']]
                   and r['how_proved'] in ('prover', 'trivial') for r in records), name
        proof_rows += len(records)
        for record in report['flow']:
            assert record['severity'] == 'warning' and record['how_proved'] == 'flow'
            assert record['check_tree'] == {} and record['file'] == 'main.adb'
            assert (record['rule'], record['message']['text']) in (
                ('DEAD_CODE', 'this statement is never reached'),
                ('INEFFECTIVE', 'initialization of "Visits" has no effect'))
        assert len(report['flow']) == {'edges': 2, 'doors': 1}.get(name, 0)
        for record in report['warn_error']:
            assert record['rule'] == 'imprecise-image' and record['message']['text'] == IMAGE
            assert record['severity'] == 'warning' and record['how_proved'] == 'trivial'
            assert record['check_tree'] == {} and record['suppressed'] == ''
        assert len(report['warn_error']) == {'edges': 1, 'doors': 2}.get(name, 0)
        sarif = load(f'native/{name}/reports/gnatprove.sarif.gz')
        main_results = [r for run in sarif['runs'] for r in run.get('results', [])
                        if r['locations'][0]['physicalLocation']['artifactLocation']['uri'] == 'main.adb']
        assert Counter(r['ruleId'] for r in main_results) == Counter(
            r['rule'] for k in ('proof', 'flow', 'warn_error') for r in report[k])
        for record in main_results:
            if record['ruleId'] == 'imprecise-image':
                assert record['kind'] == 'open' and record['level'] == 'warning'
                assert record['message']['text'] == IMAGE
                assert record['suppressions'] == [{'kind': 'external'}]
    unsafe = raw_main('native/unsafe')['proof']
    assert [(r['line'], r['col'], r['severity']) for r in unsafe] == [
        (11, 18, 'high'), (17, 15, 'medium'), (22, 15, 'info'),
        (27, 42, 'info'), (32, 36, 'info'), (37, 12, 'info')]
    for name, expected in NEGATIVE.items():
        records = raw_main(Path('negative') / name)['proof']
        assert len(records) == 1
        record = records[0]
        assert (record['line'], record['col'], record['rule']) == expected
        assert record['severity'] == 'high' and 'might fail' in record['message']['text']
        diagnostic_rows.append(dict(case=name, line=expected[0], col=expected[1], rule=expected[2]))
    static = read('native/static/proof.stdout').decode()
    assert static.count('static expression fails Constraint_Check') == 2
    assert 'main.adb:7:34' in static and 'main.adb:8:30' in static
    assert not list((HERE / 'native/static/reports').glob('*.spark.gz'))
    # A different computation from the door-major visit-count/parity Main.
    states = [False] * 101
    for step in range(1, 101):
        for door in range(step, 101, step):
            states[door] = not states[door]
    expected = ''.join(f" {door} is {'open' if states[door] else 'closed'}\n"
                       for door in range(1, 101)).encode()
    actual = read('native/doors/program.stdout')
    assert actual == expected == read('native/doors/expected.txt') == read('recipes/doors.expected.txt')
    assert read('native/doors/program.stderr') == b''
    doors_run = load('native/doors/run.json.gz')
    assert doors_run['execution']['exit_status'] == 0 and doors_run['build']['exit_status'] == 0
    frame = load('frame/results/summary.json')
    assert frame['recognizer'] == []
    assert len(frame['proxy']) == 12
    assert [r['exit_status'] for r in frame['proxy']] == [0, 1, 0, 0, 1, 0, 0, 0, 0, 0, 0, 0]
    for number in (1, 4):
        assert b'raised STORAGE_ERROR : stack overflow or erroneous memory access' in read(
            f'frame/results/proxy-{number}.stdout.gz')
    print(json.dumps(dict(status='retained evidence checks passed; no native tool invoked',
                          retained_files=len(index['inputs']), run_events=27,
                          nonempty_input_comparisons=60, positive_main_proof_records=proof_rows,
                          combined_unsafe_unproved=2, combined_unsafe_later_info=4,
                          isolated_expected_failures=diagnostic_rows,
                          static_illegal_sites=2,
                          doors=dict(bytes=len(actual), lines=len(actual.splitlines()), sha256=sha(actual)),
                          concrete_parser_runs=0), indent=2))


if __name__ == '__main__':
    main()
