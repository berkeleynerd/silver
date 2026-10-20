#!/usr/bin/env python3
"""Bounded review replay and retained-record checks; no public evaluate run."""
from datetime import datetime, timezone
import gzip
import hashlib
import io
import json
from pathlib import Path
import platform
import runpy
import subprocess
import sys
import tarfile
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = REPO / 'docs/evidence'
PACKET = E / 'retained-literal-native-review-regressions-20261020'
TARGET = 'a3af18004743d36328a499760699305357389fb8'


def read(path):
    return json.loads(path.read_bytes())


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def main():
    started = datetime.now(timezone.utc).isoformat()
    timer = time.perf_counter()
    pins = read(E / 'retained-literal-native-completion-20261019/inputs.json')['repository']
    assert len(pins) == 94
    for row in pins:
        current = (REPO / row['path']).read_bytes()
        frozen = subprocess.check_output(['git', 'show', TARGET + ':' + row['path']], cwd=REPO)
        assert current == frozen
        assert identity(current) == {k: row[k] for k in ('bytes', 'sha256')}
    for name in ('compose.py', 'inputs.json', 'result.json'):
        path = 'docs/evidence/retained-literal-native-completion-20261019/' + name
        assert (REPO / path).read_bytes() == subprocess.check_output(
            ['git', 'show', TARGET + ':' + path], cwd=REPO)

    # This is the one authorized cheap test replay, exercising frozen attach.
    completed = subprocess.run([sys.executable, str(PACKET / 'check.py')],
        cwd=REPO, text=True, capture_output=True, check=True)
    replay = json.loads(completed.stdout)
    assert not completed.stderr
    assert replay['status'] == 'passed'
    assert (replay['cases'], replay['false_verdict_cases'], replay['malformed_input_cases']) == (27, 19, 7)

    retained = read(PACKET / 'public-output-retention.json')
    expanded = {}
    for row in retained['files']:
        compressed = (PACKET / row['path']).read_bytes()
        raw = gzip.decompress(compressed)
        assert identity(compressed) == row['compressed_identity']
        assert identity(raw) == row['uncompressed_identity']
        expanded[row['path']] = raw
    fixture = runpy.run_path(str(PACKET / 'check-public-rejection.py'))['program']()
    assert expanded['rejected-30654.adb.gz'] == fixture
    full = json.loads(expanded['public-return.json.gz'])
    summary = read(PACKET / 'public-rejection-result.json')
    boundary = read(E / 'retained-literal-relocation-refinement-20261018/result.json')[
        'adjacent_unit_literal_call_boundary']['30654']
    assert full['source'] == summary['source'] == identity(fixture) == boundary['source_identity']
    for key in ('source_counts', 'complete_native_capacity', 'coverage', 'native_residuals'):
        assert summary[key] == full[key], key
    counts = full['source_counts']
    assert (counts['output_calls'], counts['null_statements'], counts['decoded_literal_bytes']) == (30654, 0, 30654)
    assert counts['decoded_literal_lengths'] == [1] * 30654
    assert full['complete_native_capacity'] is False
    assert full['components'] == {} and all(v is None for v in full['coverage'].values())
    linker = full['register_result']['predecessor_result']['core_result']['literal_output_linker']
    failed = linker['link']['failed_sufficient_checks']
    assert failed == summary['refined_linker_failed_checks'] == boundary['failed_sufficient_checks']
    assert set(failed) == {'fixed_signed_relocation_reach', 'EH_signed_fields'}
    for field in ('conditions', 'conditional_conditions'):
        assert full[field]['literal_output_linker_representation'] is False
    for key in ('repository_inputs_checked', 'compiler_shell_sources_checked'):
        assert summary[key] == full['validation'][key]

    inputs = read(PACKET / 'inputs.json')
    probe = inputs['reviewer_probe']
    with tarfile.open(REPO / probe['archive']) as archive:
        assert archive.extractfile(probe['member']).read() == (PACKET / probe['retained_copy']).read_bytes()
    sources = read(PACKET / 'sources.json')
    rebuilt = io.BytesIO()
    with tarfile.open(PACKET / 'sources.tar.gz') as original, tarfile.open(
            fileobj=rebuilt, mode='w', format=tarfile.USTAR_FORMAT) as archive:
        assert original.getnames() == [row['path'] for row in sources['files']]
        for row in sources['files']:
            raw = original.extractfile(row['path']).read()
            assert identity(raw) == row['identity']
            for reference in row['matching_manifest_entries']:
                manifest = read(REPO / reference['manifest'])
                matches = [x for x in manifest[reference['array']] if x['path'] == row['path']]
                assert len(matches) == 1
                assert {k: matches[0][k] for k in ('bytes', 'sha256')} == identity(raw)
            info = tarfile.TarInfo(row['path'])
            info.size, info.mode = len(raw), 0o644
            archive.addfile(info, io.BytesIO(raw))
    compressed = io.BytesIO()
    with gzip.GzipFile(filename='', fileobj=compressed, mode='wb', mtime=0) as output:
        output.write(rebuilt.getvalue())
    assert compressed.getvalue() == (PACKET / 'sources.tar.gz').read_bytes()

    reconciliation = read(E / 'retained-imported-frontier-disposition-20261020/reconciliation.json')
    entry = reconciliation['input']
    raw = (REPO / entry['path']).read_bytes()
    assert identity(raw) == {k: entry[k] for k in ('bytes', 'sha256')}
    baseline = json.loads(raw)
    register = baseline['register_result']
    core = register['predecessor_result']['core_result']
    frontier = core['open_joins']['native_post_prefix_imported_frontier']
    for key, value in reconciliation['historical_fields'].items():
        assert frontier[key] is value or (type(frontier[key]) is type(value) and frontier[key] == value), key
    assert core['native_counter_emission_interface']['interface'] == reconciliation['selected_counter_interface']
    ledger = register['selected_native_GGC_ledger']
    owners = {row['owner']: row for row in ledger['owner_rows']}
    assert len(owners) == len(ledger['owner_rows']) == reconciliation['current_ledger_owner_count'] == 51
    for row in reconciliation['selected_owner_rows']:
        assert owners[row['owner']] == row, row['owner']
    for key, value in reconciliation['current_guard_values'].items():
        assert value is True
        assert baseline['conditions'][key] is value and baseline['conditional_conditions'][key] is value, key
    assert ledger['selected_GGC_event_partition_closed'] is reconciliation['selected_GGC_event_partition_closed'] is True
    for key, value in reconciliation['remaining_production_and_proof_flags'].items():
        assert value is False and baseline[key] is False, key

    result = dict(status='passed', review_targets={
        'regressions': '64ca2dcdaa96d7addc6370aa80ec1e6630de9c99',
        'disposition': '6205c920ad'},
        reviewer_selection=dict(model='GPT-6 Astra', effort='Extra High', runtime_confirmation=False),
        host=platform.platform(), started_UTC=started,
        finished_UTC=datetime.now(timezone.utc).isoformat(), elapsed_seconds=time.perf_counter()-timer,
        frozen_pins_byte_equal_to_target=len(pins), frozen_aggregate_files_checked=3,
        focused_check_replays=1, focused_check_result=replay,
        public_evaluate_executions=0, public_retention_identities_and_summary_verified=True,
        public_failed_checks=failed, original_probe_byte_equal_to_archive=True,
        retained_GCC_files=2, existing_source_manifest_matches=6,
        deterministic_archive_rebuilt_from_retained_members=True,
        reconciliation_historical_fields=len(reconciliation['historical_fields']),
        reconciliation_guard_values=len(reconciliation['current_guard_values']),
        reconciliation_owner_rows=len(reconciliation['selected_owner_rows']), current_ledger_owners=51,
        counter_interface_exact_match=True, remaining_production_and_proof_flags_unchanged=True,
        native_tool_executions=0, broad_suites_executed=0, token_and_monetary_measurements=None)
    (HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
