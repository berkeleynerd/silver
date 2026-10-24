#!/usr/bin/env python3
"""One focused review audit; imports only the new cut-C checker/provider."""
from datetime import datetime, timezone
import hashlib
import importlib.util
import json
from pathlib import Path
import platform
import subprocess
import sys
import time

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PACKET = ROOT / 'docs/evidence/retained-main-entry-capacity-20261024'
FREEZE = 'e45ee72a42d6cc669e95b80c2c991cbc65fe4e73'


def digest(data):
    return hashlib.sha256(data).hexdigest()


def git(*args):
    return subprocess.check_output(['git', '-C', str(ROOT), *args])


def main():
    started = datetime.now(timezone.utc)
    start = time.monotonic()
    paths = sorted(p for p in PACKET.iterdir() if p.is_file())
    paths += [ROOT / 'docs/research/retained-main-entry-capacity.md']
    frozen = []
    for path in paths:
        rel = path.relative_to(ROOT).as_posix()
        data = path.read_bytes()
        assert data == git('show', f'{FREEZE}:{rel}'), rel
        frozen.append({'path': rel, 'bytes': len(data), 'sha256': digest(data)})

    sys.path.insert(0, str(PACKET))
    spec = importlib.util.spec_from_file_location('cut_c_author_check', PACKET / 'check.py')
    check = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(check)
    checker_start = time.monotonic()
    sources, counts = check.identities()
    native = check.native_charges(sources)
    inventory = check.source_seams(sources)
    rows = check.arithmetic()
    checker_elapsed = time.monotonic() - checker_start
    author = json.loads((PACKET / 'result.json').read_text())
    actual = {
        'status': 'pass', 'platform': platform.platform(),
        'configuration': check.CONFIGURATION,
        'assertions': sum(check.COUNTS.values()),
        'families': dict(sorted(check.COUNTS.items())), 'identities': counts,
        'native_charge_witnesses': native, 'Hashcons_owner_inventory': inventory,
        'entry_envelopes': rows, 'native_capture_compiler_prover_Lean_runs': 0,
        'predecessor_checker_replays': 0, 'source_argument_machine_proved': False,
        'full_Main_storage_closed': False,
    }
    author.pop('elapsed_seconds')
    assert actual == author, 'focused export differs from author result'
    completed = datetime.now(timezone.utc)
    result = {
        'status': 'pass', 'reviewed_commit': FREEZE,
        'started_utc': started.isoformat(), 'completed_utc': completed.isoformat(),
        'elapsed_seconds': time.monotonic() - start,
        'checker_elapsed_seconds': checker_elapsed,
        'platform': platform.platform(), 'machine': platform.machine(),
        'reviewer_model_selected': 'GPT-6 Astra', 'reviewer_effort_selected': 'Extra High',
        'runtime_model_confirmation': None, 'token_usage': None, 'monetary_cost': None,
        'frozen_author_files': frozen,
        'checker_invocations': 1, 'assertions': actual['assertions'],
        'families': actual['families'], 'identities': counts,
        'export_matches_author_except_elapsed': True,
        'checked_export_sha256': digest(json.dumps(actual, sort_keys=True).encode()),
        'maximal_role': 'put_line', 'maximal_entry_envelope': rows['put_line'],
        'native_compiler_prover_Lean_solver_capture_disassembler_runs': 0,
        'predecessor_checker_replays': 0,
        'source_argument_machine_proved': False,
        'configuration_206_adopted': False, 'full_Main_storage_closed': False,
    }
    (HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({k: result[k] for k in [
        'status', 'reviewed_commit', 'assertions', 'identities',
        'checker_elapsed_seconds', 'elapsed_seconds', 'completed_utc']}, sort_keys=True))


if __name__ == '__main__':
    main()
