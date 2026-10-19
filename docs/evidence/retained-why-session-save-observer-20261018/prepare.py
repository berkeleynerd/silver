#!/usr/bin/env python3
"""Prepare, pin and print the restricted harness. Never start native processes."""
import argparse
import ast
import hashlib
import importlib.util
import json
from pathlib import Path
import shlex
import tarfile

P = Path(__file__).resolve().parent
OLD_ROOT = '/tmp/silver-why-inline-identifier-capture3-20261018'


def identity(path):
    raw = path.read_bytes()
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--workspace', type=Path, required=True)
    parser.add_argument('--repo', type=Path, required=True)
    args = parser.parse_args()
    workspace = args.workspace.resolve()
    repo = args.repo.resolve()
    assert workspace.is_relative_to(repo / 'tmp'), 'retain on repository filesystem'
    workspace.mkdir(exist_ok=False)
    old_packet = P.parent / 'retained-why-inline-identifier-state-20261018'
    missing = P.parent / 'retained-why-session-save-capacity-20261018'
    expected_capture = json.loads((missing / 'inputs.json').read_text())['reused_files'][
        'docs/evidence/retained-why-inline-identifier-state-20261018/capture.tar.gz']
    assert identity(old_packet / 'capture.tar.gz') == expected_capture
    with tarfile.open(old_packet / 'capture.tar.gz') as archive:
        plan = json.loads(archive.extractfile('plan.json').read().decode().replace(OLD_ROOT, str(workspace)))
        internal = [str(path)[len(str(workspace)) + 1:] for path in plan['file_identities']
                    if str(path).startswith(str(workspace) + '/')]
        for relative in internal:
            member = relative.replace('input_is_valid/', 'input/', 1) if relative.startswith('input_is_valid/') else relative
            raw = archive.extractfile(member).read()
            try:
                raw = raw.decode().replace(OLD_ROOT, str(workspace)).encode()
            except UnicodeDecodeError:
                pass
            path = workspace / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(raw)
        driver_resolution = archive.extractfile('driver-resolution.json').read().decode().replace(OLD_ROOT, str(workspace))
    case, = plan['inputs']
    (Path(case['cwd']) / 'temp').mkdir()
    for name in ['session_observer.py', 'gdb_adapter.py', 'replay.py']:
        (workspace / name).write_bytes((P / name).read_bytes())
    native = json.loads((missing / 'native-layout.json').read_text())
    audit_path = P.parent / 'retained-why-inline-callback-closure-20261018/audit.py'
    spec = importlib.util.spec_from_file_location('retained_elf', audit_path)
    audit = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(audit)
    exe = Path(case['argv'][0])
    assert identity(exe) == json.loads((missing / 'inputs.json').read_text())['executable']['identity']
    elf = audit.ELF(exe.read_bytes())
    # Stop an incidental signal save before its body; never inject a signal.
    for name in ['camlGnat_main__save_session_and_exit_3133',
                 'camlWhy3__Session_itp__save_session_4339']:
        symbol = elf.symbols[name]
        plan['forbidden_calls'][name] = {
            'symbol': name, 'address': symbol['value'], 'size': symbol['size'],
            'first32': elf.read(symbol['value'], 32).hex()}
    names = ['caml_signal_handlers', 'camlStdlib', 'camlWhy3__Debug',
             *sorted(native['bodies'])]
    symbols = {name: {'elf_value': elf.symbols[name]['value']} for name in names}
    for name, body in native['bodies'].items():
        raw = bytes.fromhex(''.join(row['hex'] for row in body['instructions']))
        assert elf.read(body['address'], len(raw)) == raw
        symbols[name]['code_hex'] = raw[:32].hex()
    plan['session_observer'] = {
        'symbols': symbols, 'ident_elf_value': elf.symbols['camlWhy3__Ident']['value'],
        'limits': {'blocks': 1000000, 'payload_bytes': 134217728,
                   'block_words': 1048576, 'edges': 1000000, 'cached_blocks': 256},
        'scope': 'Same-process session roots/forest/raw tasks plus known helper roots; no numeric B or R; no target continuation past first inline entry'}
    probe = (workspace / 'probe.py').read_text()
    marker = '# Existing entry observer, extended to complete table roots.'
    assert probe.count(marker) == 1
    probe = probe.replace(marker, "exec(compile((ROOT/'gdb_adapter.py').read_text(), str(ROOT/'gdb_adapter.py'), 'exec'))\n\n" + marker)
    assert probe.count('   capture_identifier()\n') == 1
    probe = probe.replace('   capture_identifier()\n', '   capture_identifier()\n   capture_session_roots()\n')
    assert probe.count('   capture_auxiliary()\n') == 1
    probe = probe.replace('   capture_auxiliary()\n', '   del graph\n   capture_session_projection()\n   capture_auxiliary()\n')
    (workspace / 'probe.py').write_text(probe)
    resolution = json.loads(driver_resolution)
    for name, row in resolution.items():
        row['identity'] = identity(Path(name))
    (workspace / 'driver-resolution.json').write_text(json.dumps(resolution, indent=2) + '\n')
    reason = ('Missing current session roots after retained all-read coverage audit; source-bound fresh prefix; '
              'offline duplicate lookup, repeated visit, cycle, detached, partial persistence and exact replay fixtures passed; '
              'one worker stopped before first inline, printer, save callback, prover request or solver')
    managed = '''"""One restricted managed observation; --print only emits its command."""
from pathlib import Path
import json, subprocess, sys, shlex
ROOT=Path(__file__).resolve().parent
REPO=Path(REPO_LITERAL)
plan=json.loads((ROOT/'plan.json').read_text())
cmd=['python3',str(REPO/'scripts/dev.py'),'tool','--task','#119','--jobs','1',
 '--reason',REASON_LITERAL,'--workspace',str(ROOT)]
paths=set(plan['file_identities'])|{str(ROOT/n) for n in ['managed.py','run.py','plan.json','driver-resolution.json']}
paths.add(plan['gdbroot']+'/usr/bin/gdb')
for p in sorted(paths):cmd+=['--input',p]
cmd+=['--','python3',str(ROOT/'run.py')]
if '--print' in sys.argv:print(shlex.join(cmd))
else:raise SystemExit(subprocess.call(cmd,cwd=REPO))
'''.replace('REPO_LITERAL', repr(str(repo))).replace('REASON_LITERAL', repr(reason))
    (workspace / 'managed.py').write_text(managed)
    for name in list(plan['file_identities']):
        if not name.startswith(str(workspace) + '/'):
            assert identity(Path(name)) == plan['file_identities'][name], name
        plan['file_identities'][name] = identity(Path(name))
    for name in ['session_observer.py', 'gdb_adapter.py', 'replay.py', 'driver-resolution.json']:
        plan['file_identities'][str(workspace / name)] = identity(workspace / name)
    plan['scope'] = plan['session_observer']['scope']
    (workspace / 'plan.json').write_text(json.dumps(plan, indent=2) + '\n')
    for path in workspace.glob('*.py'):
        ast.parse(path.read_text(), filename=str(path))
    command = ['python3', str(repo / 'scripts/dev.py'), 'tool', '--task', '#119', '--jobs', '1',
               '--reason', reason, '--workspace', str(workspace)]
    paths = set(plan['file_identities']) | {str(workspace / n) for n in
                                          ['managed.py', 'run.py', 'plan.json', 'driver-resolution.json']}
    paths.add(plan['gdbroot'] + '/usr/bin/gdb')
    for path in sorted(paths):
        command += ['--input', path]
    command += ['--', 'python3', str(workspace / 'run.py')]
    record = {'prepared_only': True, 'executed': False, 'workspace': str(workspace),
              'managed_command': command, 'launch_wrapper': ['python3', str(workspace / 'managed.py')],
              'capture_archive': expected_capture,
              'files': {str(path.relative_to(workspace)): identity(path)
                        for path in sorted(workspace.rglob('*')) if path.is_file()},
              'preserved_native_limits': {'workers': 1, 'address_space_GiB': 6, 'timeout_seconds': 120},
              'no_native_target_started': True}
    (workspace / 'prepared.json').write_text(json.dumps(record, indent=2) + '\n')
    (workspace / 'managed-command.txt').write_text(shlex.join(command) + '\n')
    print(json.dumps({'prepared_only': True, 'workspace': str(workspace),
                      'launch_wrapper': record['launch_wrapper'], 'retained_files': len(record['files'])}))


if __name__ == '__main__':
    main()
