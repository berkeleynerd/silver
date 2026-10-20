#!/usr/bin/env python3
"""Focused source/excerpt retention checks, not a semantic dependency prover."""
from pathlib import Path
import argparse
import hashlib
import json
import re
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def read(path):
    return json.loads(path.read_text())


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--write-result', action='store_true')
    args = parser.parse_args()
    started = time.monotonic()
    manifest = read(HERE / 'inputs.json')
    for row in manifest['inputs']:
        assert identity((ROOT / row['path']).read_bytes()) == {
            key: row[key] for key in ('bytes', 'sha256')}, row['path']
    with tarfile.open(HERE / 'sources.tar.gz') as archive:
        sources = {m.name: archive.extractfile(m).read()
                   for m in archive.getmembers()}
    origins = read(HERE / 'source-inputs.json')
    assert len(origins) == len(sources) == 22
    assert {row['member'] for row in origins} == set(sources)
    archives = {}
    try:
        for row in origins:
            raw = sources[row['member']]
            assert identity(raw) == {k: row[k] for k in ('bytes', 'sha256')}
            if 'archive' in row:
                name = row['archive']
                if name not in archives:
                    archives[name] = tarfile.open(ROOT / name)
                assert raw == archives[name].extractfile(row['archive_member']).read()
            else:
                assert raw == (ROOT / row['repository_path']).read_bytes()
    finally:
        for archive in archives.values():
            archive.close()

    source = {name: raw.decode() for name, raw in sources.items()}
    excerpts = read(HERE / 'source-excerpts.json')
    assert len({row['id'] for row in excerpts}) == len(excerpts) == 47
    for row in excerpts:
        lines = source[row['member']].splitlines(keepends=True)
        assert 1 <= row['first'] <= row['last'] <= len(lines), row['id']
        actual = ''.join(lines[row['first'] - 1:row['last']])
        assert actual == row['text'], row['id']
        assert identity(actual.encode())['sha256'] == row['sha256'], row['id']
        assert row['anchor'] in actual, row['id']
    by_id = {row['id']: row['text'] for row in excerpts}
    dependencies = read(HERE / 'dependency-map.json')
    assert len({row['id'] for row in dependencies}) == len(dependencies) == 16
    for row in dependencies:
        assert row['source_ids'] and all(s in by_id for s in row['source_ids'])
        assert all(row[k] for k in ('caller', 'reads', 'writes', 'exceptions',
                                    'dependency_conclusion'))

    census = read(HERE / 'use-census.json')
    for token, retained in census.items():
        actual = [dict(member=name, line=i, text=line)
                  for name, body in sorted(source.items())
                  for i, line in enumerate(body.splitlines(), 1)
                  if re.search(r'(?<![A-Za-z_0-9])' + re.escape(token)
                               + r'(?![A-Za-z_0-9])', line)]
        assert actual == retained, token
    assert {r['member'] for r in census['session_prover_ids']} == {
        'why3/src/session/session_itp.ml'}
    assert [r['line'] for r in census['session_dir_for_save']] == [966, 2242]

    # Source anchors and caller order support review; absence of these names
    # alone is deliberately not presented as a transitive dependency proof.
    ending = by_id['ordinary_report'].split('let ending c () =', 1)[1]
    assert ending.index('C.save_session c') < ending.index('Gnat_checks.iter')
    assert ending.index('Gnat_checks.iter') < ending.index('Gnat_report.print_messages')
    signal = by_id['signal_outer'].split('let save_session_and_exit c signum =', 1)[1]
    assert signal.index('C.save_session c;') < signal.index('exit signum')
    assert 'with Exit -> ending ()' in by_id['scheduler_ending']
    assert 'if is_new_session then c' in by_id['fresh_entry']
    assert 'Session_itp.load_session session_dir' in by_id['fresh_entry']
    assert 'Controller_itp.reload_files ~ignore_shapes:false c' in by_id['fresh_entry']
    assert 's.session_raw_tasks' in by_id['live_getters']
    for name in ('report_stats', 'report_json', 'report_validity',
                 'report_register', 'report_output'):
        assert not any(token in by_id[name] for token in (
            'session_prover_ids', 'Sshape.', 'Gshape.', 'load_session',
            'why3session.xml', 'why3shapes')), name
    assert 'Hid.add s.th_state' in by_id['status_caches']
    assert 'Hfile.add s.file_state' in by_id['status_caches']
    assert '"results", List []' in by_id['error_output']
    assert 'pragma Warnings (Off, Success)' in by_id['producer_collect']
    assert 'Handle_Error (Msg, Internal)' in by_id['producer_parse']
    assert 'Build;' in by_id['silver_gate']
    assert by_id['silver_gate'].index('Read_Proof;') < by_id['silver_gate'].index('Build;')
    issue = read(HERE / 'issue-88.json')
    assert issue['number'] == 88
    assert 'Unknown coupling is unresolved, not a confirmation-only exception.' in issue['body']
    assert 'a reliable detection path distinguishes it from defects' in issue['body']

    result = dict(
        scope='Selected fresh Per_Check CE-off automatic non-replay save-artifact dependency',
        source_members=len(sources), repository_inputs=len(manifest['inputs']),
        exact_source_excerpts=len(excerpts), field_specific_excerpt_anchors=len(excerpts),
        dependency_rows=len(dependencies), census_tokens=len(census),
        census_occurrences=sum(map(len, census.values())),
        current_result_reads_saved_xml_shapes_or_numeric_prover_ids=False,
        later_session_load_depends_on_saved_artifacts=True,
        nonreplay_alone_establishes_freshness=False,
        faithful_saved_artifact_premise_required_for_selected_current_result=False,
        save_execution_capacity_and_typed_state_obligations_removed=False,
        all_save_work_observation_only=False,
        reliable_interruption_or_boundary_detector_established=False,
        saved_artifact_correctness_established=False,
        complete_save_capacity_established=False,
        whole_pipeline_claim=False, source_semantics_machine_proved=False,
        native_runs=0, proof_solver_runs=0, capture_runs=0,
        public_evaluator_runs=0, predecessor_checker_replays=0,
        external_source_fetches=0, independent_review='pending')
    if args.write_result:
        (HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    else:
        assert result == read(HERE / 'result.json')
    print(json.dumps(dict(result=result, check_seconds=time.monotonic() - started)))


if __name__ == '__main__':
    main()
