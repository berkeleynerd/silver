#!/usr/bin/env python3
"""Reconcile fixed-library observations offline; no toolchain execution."""
import hashlib
import json
from pathlib import Path
import runpy
import tarfile


def read_archive(path):
    with tarfile.open(path) as archive:
        members = archive.getmembers()
        assert all(m.isfile() for m in members)
        assert len({m.name for m in members}) == len(members)
        return {m.name: archive.extractfile(m).read() for m in members}


def main():
    root = Path(__file__).resolve().parent
    check_graph = runpy.run_path(str(root.parent / 'retained-producer-fixed-20261018/check.py'))['check_graph']
    manifest = json.loads((root / 'archive-manifest.json').read_text())
    archives = {name: read_archive(root / name) for name in {r['archive'] for r in manifest['files']}}
    assert {(r['archive'], r['path']) for r in manifest['files']} == {(a,p) for a,v in archives.items() for p in v}
    for row in manifest['files']:
        data = archives[row['archive']][row['path']]
        assert len(data) == row['bytes']
        assert hashlib.sha256(data).hexdigest() == row['sha256']
    previous = read_archive(root.parent / 'retained-producer-dependencies-20261018/inputs-and-logs.tar.gz')
    inputs = archives['inputs-and-outputs.tar.gz']
    graphs = archives['graphs.tar.gz']
    runs = archives['managed-runs.tar.gz']
    summary = json.loads((root / 'summary.json').read_text())
    for row in summary['cases']:
        case = row['case']
        result = json.loads(inputs[case + '/result.json'])
        assert result['debugger_exit'] == 0
        assert result['producer_sha256'] == row['producer_sha256']
        assert result['elapsed_seconds'] == row['probe_seconds']
        checked = {}
        for snapshot in result['snapshots']:
            graph = json.loads(graphs[case + '/graph-' + snapshot['phase'] + '.json'])
            actual = check_graph(graph)
            assert actual == {k:snapshot[k] for k in actual}
            checked[snapshot['phase']] = graph
        assert set(checked) == {'before_standard','after_standard','before_free'}
        final = checked['before_free']
        assert row['final'] == {k:final[k] for k in row['final']}
        assert row['theory_roots'] == len(final['theory_roots'])
        log = inputs[case + '/probe.log'].decode()
        assert 'UNEXPECTED_RESULT_COLLECTION' not in log
        assert log.count('FALSE_BACKEND_CALL ') == row['false_backend_calls'] < 63
        outputs = [p for p in inputs if p.startswith(case+'/obj/') and p.endswith('.gnat-json')]
        assert len(outputs) == row['false_backend_calls']
        for output in outputs:
            json.loads(inputs[output])
        options = json.loads(inputs[case+'/options.json'])
        assert options['parallel_why3']
        assert all(v['why3_args'] == ['/usr/bin/false'] for v in options['file_specific'].values())
        events = [json.loads(line) for line in runs[row['run_id']+'/events.jsonl'].splitlines()]
        assert events[-1]['event'] == 'finished' and events[-1]['outcome'] == 'success'
        native = [e for e in events if e['event']=='phase-end' and e['phase']=='native-tool']
        assert len(native)==1 and native[0]['returncode']==0
        prepared = next(e['inputs'] for e in events if e['event']=='prepared')
        for path, digest in prepared['inputs_sha256'].items():
            body_prefix = '/tmp/silver-producer-fixed-bodies-20261018/'
            deps_prefix = '/tmp/silver-producer-fixed-deps-plan-20261018/'
            if path.startswith(body_prefix):
                assert hashlib.sha256(inputs[path.removeprefix(body_prefix)]).hexdigest() == digest
            elif path.startswith(deps_prefix):
                assert hashlib.sha256(previous[path.removeprefix(deps_prefix)]).hexdigest() == digest
            elif path.endswith('/libexec/spark/bin/gnat2why'):
                assert digest == row['producer_sha256']
    print('Verified 12 fixed-library graphs, five serialized files, disabled backend and four successful managed runs')


if __name__ == '__main__':
    main()
