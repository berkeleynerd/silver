#!/usr/bin/env python3
"""One combined review audit; no native tools or predecessor checker execution."""
import hashlib
import importlib.util
import json
import platform
import subprocess
import sys
import tarfile
import time
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PACK = ROOT / 'docs/evidence/retained-general-native-capacity-20261024'
KERNEL = '36d478da0cb3261920fd595ba4a9bdcde54b0cb5'
REPAIR = '1604467b0f2892d3f92f4f40caaabcc05be52271'
sys.dont_write_bytecode = True


def sha(data):
    return hashlib.sha256(data).hexdigest()


def load(path):
    return json.loads(path.read_bytes())


def frozen_blob(commit, path):
    return subprocess.check_output(['git', 'show', f'{commit}:{path}'], cwd=ROOT)


def main():
    started = datetime.now(timezone.utc).isoformat()
    begin = time.perf_counter()
    inputs = []
    for path in sorted(PACK.iterdir()):
        if path.is_file():
            rel = str(path.relative_to(ROOT))
            data = path.read_bytes()
            assert data == frozen_blob(REPAIR, rel), rel
            inputs.append({'path': rel, 'sha256': sha(data), 'bytes': len(data)})
    for rel in ('docs/research/retained-general-native-capacity.md',
                'docs/research/retained-native-expansion.md'):
        data = (ROOT / rel).read_bytes()
        assert data == frozen_blob(REPAIR, rel)
        inputs.append({'path': rel, 'sha256': sha(data), 'bytes': len(data)})

    # Verify the first kernel's retained source and evidence without invoking
    # its historical checker or pretending its old document pin is current.
    historical = load(PACK / 'inputs.json')['inputs']
    for row in historical:
        assert sha(frozen_blob(KERNEL, row['path'])) == row['sha256']
    manifest = load(PACK / 'source-manifest.json')
    assert manifest['gcc_commit'] == '6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea'
    archive = PACK / manifest['archive']
    assert sha(archive.read_bytes()) == manifest['archive_sha256']
    sources = {}
    with tarfile.open(archive, 'r:gz') as tar:
        members = tar.getmembers()
        assert len(members) == len(manifest['files'])
        assert all(m.isfile() for m in members)
        assert {m.name for m in members} == {r['path'] for r in manifest['files']}
        for row in manifest['files']:
            data = tar.extractfile(row['path']).read()
            assert len(data) == row['bytes'] and sha(data) == row['sha256']
            prior = load(ROOT / row['predecessor_manifest'])['files']
            match = [p for p in prior if p['path'] == row['predecessor_key']]
            assert len(match) == 1 and match[0]['sha256'] == row['sha256']
            sources[row['path']] = data
    witnesses = load(PACK / 'source-witnesses.json')['witnesses']
    assert len({w['id'] for w in witnesses}) == len(witnesses)
    for row in witnesses:
        lines = sources[row['source']].split(b'\n')
        first, last = row['first_lf_line'], row['last_lf_line']
        assert 1 <= first <= last <= len(lines)
        data = b'\n'.join(lines[first - 1:last]) + b'\n'
        assert sha(data) == row['sha256'] and data.decode() == row['excerpt']

    expected = {
        'type_nodes': [3, 5, 6, 6], 'type_declarations': [3, 4, 3, 2],
        'rm_vectors_3': [1, 0, 1, 0], 'lang_type_payloads': [1, 2, 2, 1],
        'direct_constant_requests': [9, 56, 42, 12],
        'direct_unary_nodes_and_slots': [1, 6, 6, 1],
        'alloca_request_count': [0, 2, 0, 0],
        'alloca_logical_payload_bytes': [0, 9, 0, 0],
    }
    retained_kernel = load(PACK / 'check-result.json')
    assert retained_kernel['direct_kernel_coefficients'] == expected
    assert retained_kernel['source_files'] == len(sources) == 22
    assert retained_kernel['source_witnesses'] == len(witnesses) == 50
    for row in retained_kernel['program_projections']:
        assert sha((ROOT / row['source']).read_bytes()) == row['sha256']
        assert row['V_Main'] == row['A_Main'] + 32 * row['E_Main'] + 3 * row['H_store']
        p = row['coarse_direct_kernel_projection']
        for key, coefficients in expected.items():
            assert p[key] == max(coefficients) * row['E_Main']
        assert p['selected_caller_byte_projection'] == (
            256 * p['type_nodes'] + 48 * p['rm_vectors_3']
            + 16 * p['lang_type_payloads'] + 40 * p['direct_constant_requests'])
        assert row['complete_native_capacity_result'] is False

    # The only invoked author checker is the current focused repair checker.
    spec = importlib.util.spec_from_file_location('reviewed_string_pack', PACK / 'repair-string-pack.py')
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    current_begin = time.perf_counter()
    current = module.run()
    invocation_elapsed = time.perf_counter() - current_begin
    author = load(PACK / 'string-pack-current.json')
    for key in set(author) | set(current):
        if key != 'offline_elapsed_seconds':
            assert current[key] == author[key], key
    (HERE / 'repair-check-result.json').write_text(json.dumps(current, indent=2) + '\n')
    result = {
        'status': 'pass', 'reviewed_kernel_commit': KERNEL, 'reviewed_repair_commit': REPAIR,
        'selected_reviewer_model': 'GPT-6 Astra', 'selected_reviewer_effort': 'Extra High',
        'runtime_model_confirmation': 'unavailable', 'tokens': None, 'cost': None,
        'native_platform': platform.system() + ' ' + platform.machine(),
        'review_started_utc': '2026-10-24T03:11:24Z', 'audit_started_utc': started,
        'audit_finished_utc': datetime.now(timezone.utc).isoformat(),
        'audit_elapsed_seconds': time.perf_counter() - begin,
        'focused_repair_checker_invocation_seconds': invocation_elapsed,
        'focused_repair_checker_internal_seconds': current['offline_elapsed_seconds'],
        'frozen_inputs': inputs, 'kernel_complete_sources_verified': len(sources),
        'kernel_LF_witnesses_verified': len(witnesses),
        'historical_kernel_inputs_verified_at_exact_kernel_commit': len(historical),
        'retained_kernel_coefficients_and_five_projections_checked': True,
        'retained_4096_assignment_success_reused_without_replay': True,
        'repair_complete_sources_verified': current['source_files_verified'],
        'repair_LF_witnesses_verified': current['LF_witnesses_verified'],
        'repair_historical_inputs_verified': current['historical_inputs_verified'],
        'repair_boundary_pairs_checked': current['signed_and_boundary_pairs_checked'],
        'current_export_matches_author_except_elapsed': True,
        'matching_source_callsite_inventory_rechecked': current['matching_file_callsite_occurrences_rechecked'],
        'full_negative_inventory_replayed': False,
        'native_compiler_runs': 0, 'prover_runs': 0, 'predecessor_checker_runs': 0,
        'independent_focused_checker_invocations': 1,
        'complete_native_capacity_result': False,
        'semantic_branch_coverage_machine_proved': False,
    }
    (HERE / 'audit.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({k: result[k] for k in ('status', 'audit_elapsed_seconds',
        'focused_repair_checker_internal_seconds', 'kernel_complete_sources_verified',
        'repair_complete_sources_verified', 'current_export_matches_author_except_elapsed')}))


if __name__ == '__main__':
    main()
