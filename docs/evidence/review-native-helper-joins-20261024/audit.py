#!/usr/bin/env python3
"""Focused #201/#209 review receipt; no predecessor/native execution."""
from datetime import datetime, timezone
import hashlib
import importlib.util
import json
from pathlib import Path
import platform
import subprocess
import sys
import tarfile
import time

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
BASE = ROOT / 'docs/evidence/retained-general-native-capacity-20261024'
PACKET = BASE / 'helper-joins'
FREEZE = '99734327fd77d426fead054d7ba0e12999b00d8a'
FIRST = '36d478da0cb3261920fd595ba4a9bdcde54b0cb5'
REPAIR_207 = '1604467b0f2892d3f92f4f40caaabcc05be52271'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def git(*args):
    return subprocess.check_output(['git', '-C', str(ROOT), *args])


def bind(path, commit):
    relative = path.relative_to(ROOT).as_posix()
    data = path.read_bytes()
    assert data == git('show', f'{commit}:{relative}'), relative
    return {'path': relative, 'bytes': len(data), 'sha256': sha(data), 'commit': commit}


def main():
    start = time.perf_counter()
    started = datetime.now(timezone.utc)
    frozen = [bind(p, FREEZE) for p in sorted(PACKET.iterdir()) if p.is_file()]
    frozen.append(bind(ROOT / 'docs/research/retained-general-native-capacity.md', FREEZE))
    historical = [bind(p, REPAIR_207) for p in sorted(BASE.iterdir())
                  if p.is_file() and p.name != 'README.md']
    historical.append(bind(BASE / 'check-result.json', FIRST))

    # Extra source seam: va_gc reserve normalizes capacity before ggc_realloc.
    # Its actual 72-byte caller request needs the selected GGC class, beyond
    # the previously sufficient coarse 512-byte rounding bound.
    archive = ROOT / 'docs/evidence/retained-backend-capacity-20261018/allocator-sources.tar.gz'
    archive_identity = bind(archive, FREEZE)
    with tarfile.open(archive) as tar:
        data = tar.extractfile('gcc/ggc-page.cc').read()
    manifest = json.loads((archive.parent / 'source-manifest.json').read_text())
    row, = [r for r in manifest['files'] if r['path'] == 'gcc/ggc-page.cc']
    assert sha(data) == row['sha256']
    lines = data.split(b'\n')
    spans = []
    for lo, hi in [(151, 161), (179, 203), (1292, 1327), (1883, 1921)]:
        spans.append({'first_lf_line': lo, 'last_lf_line': hi,
                      'sha256': sha(b'\n'.join(lines[lo-1:hi]) + b'\n')})
    assert b'MAX_ALIGNMENT * 9' in data
    assert 9 * 8 == 72 and (72 - 8) // 16 == 4

    spec = importlib.util.spec_from_file_location('new_helper_check', PACKET / 'check.py')
    check = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(check)
    invoked = time.perf_counter()
    actual = check.check()
    invocation_elapsed = time.perf_counter() - invoked
    author = json.loads((PACKET / 'current.json').read_text())
    volatile = ['checked_at_utc', 'offline_elapsed_seconds']
    assert {k:v for k,v in actual.items() if k not in volatile} == {
        k:v for k,v in author.items() if k not in volatile}
    result = {
        'status': 'pass', 'reviewed_commit': FREEZE,
        'started_utc': started.isoformat(),
        'completed_utc': datetime.now(timezone.utc).isoformat(),
        'elapsed_seconds': time.perf_counter() - start,
        'focused_checker_elapsed_seconds': actual['offline_elapsed_seconds'],
        'focused_invocation_elapsed_seconds': invocation_elapsed,
        'platform': platform.platform(), 'machine': platform.machine(),
        'selected_reviewer_model': 'GPT-6 Astra', 'selected_reviewer_effort': 'Extra High',
        'runtime_model_confirmation': None, 'tokens': None, 'monetary_cost': None,
        'frozen_author_files': frozen, 'preserved_historical_files': historical,
        'additional_source': {
            'archive': archive_identity, 'member': 'gcc/ggc-page.cc',
            'bytes': len(data), 'sha256': sha(data), 'LF_spans': spans,
            'selected_host_MAX_ALIGNMENT': 8, 'vector_actual_caller_bytes': 72,
            'recovered_capacity': 4,
            'host_layout_is_reviewed_premise_not_measured_by_this_script': True,
        },
        'focused_checker_invocations': 1, 'predecessor_checker_replays': 0,
        'export_matches_author_except_clock_and_elapsed': True,
        'source_files': actual['source_files'], 'LF_witnesses': actual['LF_witnesses'],
        'pinned_inputs': actual['pinned_inputs'],
        'subset_assignments_checked': actual['subset_assignments_checked'],
        'signed_endpoint_pairs_checked': actual['signed_endpoint_pairs_checked'],
        'selected_String_extent_pairs_checked': actual['selected_String_extent_pairs_checked'],
        'current_repaired_general_C': actual['repaired_general_C'],
        'current_classified_C': actual['classified_with_annotation_C'],
        'descriptor': actual['descriptor'],
        'native_compiler_prover_Lean_solver_capture_disassembler_runs': 0,
        'source_argument_machine_proved': False, 'full_F_local_storage_closed': False,
        'dynamic_F_Q_closed': False, 'general_fixed_entry_cost_closed': False,
        'whole_native_capacity_closed': False,
    }
    (HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({k:result[k] for k in [
        'status', 'reviewed_commit', 'source_files', 'LF_witnesses', 'pinned_inputs',
        'subset_assignments_checked', 'signed_endpoint_pairs_checked',
        'focused_checker_elapsed_seconds', 'focused_invocation_elapsed_seconds',
        'elapsed_seconds', 'completed_utc']}, sort_keys=True))


if __name__ == '__main__':
    main()
