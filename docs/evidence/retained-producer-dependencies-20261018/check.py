#!/usr/bin/env python3
"""Check retained fixed-dependency evidence offline; does not execute tools."""
import hashlib
import json
from pathlib import Path
import runpy
import tarfile


def main():
    root = Path(__file__).resolve().parent
    repo = root.parents[2]
    check_graph = runpy.run_path(str(root.parent / 'retained-producer-fixed-20261018/check.py'))['check_graph']
    summary = json.loads((root / 'summary.json').read_text())
    manifest = json.loads((root / 'archive-manifest.json').read_text())
    archives = {}
    for name in sorted({r['archive'] for r in manifest['files']}):
        with tarfile.open(root / name) as archive:
            members = archive.getmembers()
            assert all(m.isfile() for m in members)
            assert len({m.name for m in members}) == len(members)
            archives[name] = {m.name: archive.extractfile(m).read() for m in members}
    expected_members = {(r['archive'], r['path']) for r in manifest['files']}
    assert expected_members == {(a, p) for a, items in archives.items() for p in items}
    for row in manifest['files']:
        data = archives[row['archive']][row['path']]
        assert len(data) == row['bytes'], row
        assert hashlib.sha256(data).hexdigest() == row['sha256'], row
    inputs = archives['inputs-and-logs.tar.gz']
    graphs = archives['graphs.tar.gz']
    runs = archives['managed-runs.tar.gz']
    plan = json.loads(inputs['plan.json'])
    for source in plan['library_inputs']:
        data = inputs['library-src/' + source['name']]
        assert hashlib.sha256(data).hexdigest() == source['sha256']
        assert len(data) == source['bytes']
        assert data == (repo / 'src' / source['name']).read_bytes()
    assert len(plan['library_inputs']) == 6
    for case in ['library-obj', *[r['case'] for r in summary['cases']]]:
        result = json.loads(inputs[case + '/phase1-result.json'])
        rows = result if isinstance(result, list) else [result]
        assert all(r['exit'] == 0 for r in rows)
    for run_id in summary['managed_runs'].values():
        events = [json.loads(line) for line in runs[run_id + '/events.jsonl'].splitlines()]
        assert events[-1]['event'] == 'finished'
        assert events[-1]['outcome'] == 'success'
        native_end = [e for e in events if e['event'] == 'phase-end' and e['phase'] == 'native-tool']
        assert len(native_end) == 1 and native_end[0]['returncode'] == 0
        prepared = next(e['inputs'] for e in events if e['event'] == 'prepared')
        for path, digest in prepared['inputs_sha256'].items():
            prefix = '/tmp/silver-producer-fixed-deps-plan-20261018/'
            if path.startswith(prefix):
                assert hashlib.sha256(inputs[path.removeprefix(prefix)]).hexdigest() == digest, path
            elif path.endswith('/libexec/spark/bin/gnat2why'):
                assert digest == summary['producer_sha256']
    metrics = tuple(summary['post_standard_sum'])
    sums = dict.fromkeys(metrics, 0)
    roots = 0
    reference_standard = None
    for row in summary['cases']:
        case = row['case']
        result = json.loads(inputs[case + '/result.json'])
        assert result['debugger_exit'] == 0
        assert result['producer_sha256'] == summary['producer_sha256'] == plan['producer_sha256']
        checked = {}
        for snap in result['snapshots']:
            graph = json.loads(graphs[case + '/graph-' + snap['phase'] + '.json'])
            actual = check_graph(graph)
            assert actual == {k: snap[k] for k in actual}
            checked[snap['phase']] = graph
        assert set(checked) == {'before_standard', 'after_standard', 'before_free'}
        before, standard, final = (checked[k] for k in ('before_standard','after_standard','before_free'))
        assert [before[k] for k in metrics] == [1445, 0, 0, 0]
        assert [standard[k] for k in metrics] == [6481, 1293, 1714, 9562]
        if reference_standard is None:
            reference_standard = standard
        assert standard == reference_standard
        # The retained Standard graph is unchanged in each observed final state.
        for part in ('nodes', 'lists'):
            assert all(final['graph'][part][k] == v for k, v in standard['graph'][part].items())
        assert row['after_standard'] == {k: standard[k] for k in metrics}
        assert row['final'] == {k: final[k] for k in metrics}
        delta = {k: final[k] - standard[k] for k in metrics}
        assert row['post_standard'] == delta
        assert row['additional_theory_roots'] == len(final['theory_roots']) - len(standard['theory_roots'])
        assert row['temporary_name_delta'] == final['temporary_names'] - standard['temporary_names']
        assert row['producer_subprocess_seconds'] == result['elapsed_seconds']
        roots += row['additional_theory_roots']
        for k in metrics:
            sums[k] += delta[k]
    assert sums == summary['post_standard_sum']
    assert roots == summary['additional_theory_root_sum'] == 219
    assert sums == dict(nodes=8868, lists=2017, retained_elements=3015, all_theory_occurrences=13059)
    print('Verified 15 raw graphs, five deltas, six current library inputs, and 11 successful managed runs')


if __name__ == '__main__':
    main()
