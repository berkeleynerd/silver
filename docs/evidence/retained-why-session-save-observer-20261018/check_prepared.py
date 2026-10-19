#!/usr/bin/env python3
"""Check frozen harness inputs and minimal probe changes without native execution."""
import argparse
import ast
import hashlib
import json
from pathlib import Path
import tarfile
import time

P = Path(__file__).resolve().parent
OLD = '/tmp/silver-why-inline-identifier-capture3-20261018'


def identity(path):
    raw = path.read_bytes()
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def check(workspace):
    start = time.monotonic()
    prepared = json.loads((workspace / 'prepared.json').read_text())
    assert prepared['prepared_only'] and not prepared['executed']
    for name, expected in prepared['files'].items():
        assert identity(workspace / name) == expected, name
    plan = json.loads((workspace / 'plan.json').read_text())
    for name, expected in plan['file_identities'].items():
        assert identity(Path(name)) == expected, name
    for name in ['session_observer.py', 'gdb_adapter.py', 'replay.py']:
        assert (workspace / name).read_bytes() == (P / name).read_bytes()
    archive_path = P.parent / 'retained-why-inline-identifier-state-20261018/capture.tar.gz'
    assert identity(archive_path) == prepared['capture_archive']
    with tarfile.open(archive_path) as archive:
        old_plan = json.loads(archive.extractfile('plan.json').read().decode().replace(OLD, str(workspace)))
        probe = archive.extractfile('probe.py').read().decode().replace(OLD, str(workspace))
        run = archive.extractfile('run.py').read().decode().replace(OLD, str(workspace))
    assert plan['inputs'] == old_plan['inputs']
    for key in ['guards', 'entry_observers', 'shared_observer', 'table_observer',
                'arithmetic_sites', 'dispatch_observers', 'server_identity', 'state_fields']:
        assert plan[key] == old_plan[key], key
    additions = {'camlGnat_main__save_session_and_exit_3133',
                 'camlWhy3__Session_itp__save_session_4339'}
    assert set(plan['forbidden_calls']) == set(old_plan['forbidden_calls']) | additions
    for name, row in old_plan['forbidden_calls'].items():
        assert plan['forbidden_calls'][name] == row
    marker = '# Existing entry observer, extended to complete table roots.'
    probe = probe.replace(marker, "exec(compile((ROOT/'gdb_adapter.py').read_text(), str(ROOT/'gdb_adapter.py'), 'exec'))\n\n" + marker)
    probe = probe.replace('   capture_identifier()\n', '   capture_identifier()\n   capture_session_roots()\n')
    probe = probe.replace('   capture_auxiliary()\n', '   del graph\n   capture_session_projection()\n   capture_auxiliary()\n')
    assert (workspace / 'probe.py').read_text() == probe
    assert (workspace / 'run.py').read_text() == run
    for path in workspace.glob('*.py'):
        ast.parse(path.read_text(), filename=str(path))
    case, = plan['inputs']
    cwd = Path(case['cwd'])
    assert sorted(x.name for x in cwd.iterdir()) == sorted([case['argv'][-1], 'why3.conf', 'temp'])
    assert not list((cwd / 'temp').iterdir())
    assert '--socket' in case['argv'] and case['server']['argv'][-3:] == ['--single-client', '-j', '1']
    assert prepared['managed_command'][-3:] == ['--', 'python3', str(workspace / 'run.py')]
    return {'status': 'pass', 'seconds': time.monotonic() - start,
            'frozen_files': len(prepared['files']), 'plan_input_identities': len(plan['file_identities']),
            'original_guards_preserved': True, 'new_save_stop_guards': sorted(additions),
            'native_runs': 0}


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('workspace', type=Path)
    args = parser.parse_args()
    print(json.dumps(check(args.workspace.resolve())))
