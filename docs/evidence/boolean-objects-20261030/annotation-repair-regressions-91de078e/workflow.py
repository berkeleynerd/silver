"""One-off snapshot/run/restore helper; installed-worktree use requires handoff."""
from pathlib import Path
import ast
import datetime
import gzip
import hashlib
import json
import os
import re
import shutil
import stat
import subprocess
import sys
import tarfile

HERE = Path(__file__).resolve().parent
WORK = Path('/home/canto/src/github.com/berkeleynerd/silver/tmp/constant-array-iteration')
BACKUP = WORK / 'tmp/boolean-repair-regression-91de'
PATHS = ['scripts', 'tests', 'src', 'proof', 'samples', 'catalogue', 'silver.gpr',
         'alire.toml', 'rosetta/refresh.py', 'rosetta/manifest.json', 'rosetta/coverage.json']
REGISTRY = Path('/home/canto/src/github.com/berkeleynerd/silver/.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs')
RUNS = {
    'source': (1, 'test_lean_source.py', None, 12),
    'platform': (1, 'test_platforms.py', None, 16),
    'integrity': (2, 'test_output_integrity.py', None, 17),
    'tool-source': (1, 'test_silver.py', 'test_tool_failures_and_source_changes_do_not_report_success', 1),
}
BUILD_BINARIES = {
    '.silver/linux-x86_64/compiler/bin/silver': '69006d784a7fa256c3a7bd78db22a9003e9053b199c97b8c6a82e3bbe31cb506',
    '.silver/linux-x86_64/compiler/bin/silver_image_adapter': '524f344475f1bb636826214b1f2113d0cf9e03839be65a05c8f389681b1ffcfc',
}


def write(path, data):
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text(json.dumps(data, sort_keys=True, indent=2) + '\n')


def digest(path):
    if not path.is_file():
        return None
    with path.open('rb') as stream:
        return hashlib.file_digest(stream, 'sha256').hexdigest()


def nodes(root):
    result = {}
    for name in PATHS:
        start = root / name
        if not start.exists() and not start.is_symlink():
            result[name] = {'kind': 'absent'}
            continue
        candidates = [start]
        if start.is_dir() and not start.is_symlink():
            candidates += sorted(start.rglob('*'))
        for path in candidates:
            mode = stat.S_IMODE(path.lstat().st_mode)
            if path.is_symlink():
                entry = {'kind': 'symlink', 'target': os.readlink(path), 'mode': mode}
            elif path.is_dir():
                entry = {'kind': 'directory', 'mode': mode}
            else:
                entry = {'kind': 'file', 'sha256': digest(path), 'mode': mode}
            result[str(path.relative_to(root))] = entry
    return result


def snapshot_check():
    snapshot = json.loads((HERE / 'snapshot-manifest.json').read_text())
    mismatches = [name for name, expected in snapshot['files_sha256'].items()
                  if digest(WORK / name) != expected]
    mode_mismatches = [name for name, expected in snapshot['files_mode'].items() if stat.S_IMODE((WORK / name).stat().st_mode) & 0o111 != expected & 0o111]
    assert not mismatches and not mode_mismatches, (mismatches, mode_mismatches)
    return len(snapshot['files_sha256'])


def install():
    # Lead/native-agent handoff must precede this explicit command.
    assert not BACKUP.exists(), 'snapshot backup already exists; inspect it rather than overwrite'
    assert all(digest(WORK / name) == expected for name, expected in BUILD_BINARIES.items()), 'matching native build identities changed; inspect before snapshot mutation'
    original = nodes(WORK)
    write(HERE / 'original-git-state.json', {'head': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=WORK, text=True).strip(), 'branch': subprocess.check_output(['git', 'branch', '--show-current'], cwd=WORK, text=True).strip()})
    status = subprocess.check_output(['git', 'status', '--porcelain=v1', '-uall'], cwd=WORK, text=True)
    write(HERE / 'original-nodes.json', original)
    (HERE / 'original-status.txt').write_text(status)
    BACKUP.mkdir()
    write(BACKUP / 'original-nodes.json', original)
    for name in PATHS:
        source, target = WORK / name, BACKUP / 'original' / name
        if source.exists() or source.is_symlink():
            target.parent.mkdir(parents=True, exist_ok=True)
            source.rename(target)
    with tarfile.open(HERE / 'final-inputs.tar') as archive:
        archive.extractall(WORK, members=[member for member in archive.getmembers() if member.name.rstrip('/') != 'rosetta'], filter='data')
    count = snapshot_check()
    write(HERE / 'snapshot-installation.json', {
        'installed_at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
        'commit': '91de078ed81d102485c7dd286758e127630b01d6', 'files_checked': count,
        'worktree': str(WORK), 'backup': str(BACKUP),
        'compiler_sha256': digest(WORK / '.silver/linux-x86_64/compiler/bin/silver'),
        'adapter_sha256': digest(WORK / '.silver/linux-x86_64/compiler/bin/silver_image_adapter'),
    })
    print('Installed exact snapshot:', count, 'files; originals retained:', len(original), flush=True)


def run(label):
    assert BACKUP.exists(), 'install snapshot only after native handoff'
    workers, pattern, keyword, expected_count = RUNS[label]
    result_file = HERE / label / 'verification.json'
    assert not result_file.exists(), 'do not rerun retained outcomes without diagnosis'
    assert snapshot_check() == len(json.loads((HERE / "snapshot-manifest.json").read_text())["files_sha256"])
    module = pattern[:-3]
    tree = ast.parse((WORK / 'tests' / pattern).read_text())
    expected = sorted(module + '.' + cls.name + '.' + method.name
                      for cls in tree.body if isinstance(cls, ast.ClassDef)
                      for method in cls.body if isinstance(method, ast.FunctionDef)
                      and method.name.startswith('test_') and (keyword is None or method.name == keyword))
    assert len(expected) == expected_count
    command = [sys.executable, 'scripts/dev.py', 'test', '--task', '#291', '--jobs', str(workers),
               '--reason', 'Refresh ' + label + ' regressions on final reviewed annotation-repair snapshot 91de078ed8',
               '--', '-p', pattern]
    if keyword:
        command += ['-k', keyword]
    output = HERE / label
    output.mkdir()
    memory = dict(line.split(':', 1) for line in Path('/proc/meminfo').read_text().splitlines())
    write(output / 'command.json', {'command': command, 'cwd': str(WORK), 'expected_ids': expected,
                                 'mem_available': memory.get('MemAvailable'),
                                 'swap_free': memory.get('SwapFree')})
    with (output / 'launch.log').open('x') as stream:
        process = subprocess.run(command, cwd=WORK, stdout=stream, stderr=subprocess.STDOUT)
    launch = (output / 'launch.log').read_text()
    match = re.search(r'Managed run: (\S+)', launch)
    assert match, launch
    run_id = match.group(1)
    events_data = (REGISTRY / run_id / 'events.jsonl').read_bytes()
    log_data = (REGISTRY / run_id / 'native.log').read_bytes()
    (output / 'events.jsonl.gz').write_bytes(gzip.compress(events_data, mtime=0))
    (output / 'native.log.gz').write_bytes(gzip.compress(log_data, mtime=0))
    events = [json.loads(line) for line in events_data.splitlines()]
    prepared = next(event for event in events if event['event'] == 'prepared')
    terminal = next(event for event in reversed(events) if event['event'] == 'finished')
    hashes = prepared['inputs']['inputs_sha256']
    mismatches = [name for name, expected_hash in hashes.items() if digest(Path(name)) != expected_hash]
    log = log_data.decode()
    actual = sorted(re.findall(r'^test_\w+ \(([^)]+)\)', log, re.M))
    test_duration = re.search(r'Ran (\d+) tests? in ([\d.]+)s', log)
    snapshot = json.loads((HERE / 'snapshot-manifest.json').read_text())
    snapshot_mismatches = [name for name, expected_hash in snapshot['files_sha256'].items()
                           if digest(WORK / name) != expected_hash]
    record = {
        'run_id': run_id, 'label': label, 'command_returncode': process.returncode,
        'outcome': terminal.get('outcome'), 'workers': workers,
        'managed_seconds': terminal.get('duration_seconds'),
        'unittest_seconds': float(test_duration.group(2)) if test_duration else None,
        'expected_ids': expected, 'observed_ids': actual,
        'managed_input_count': len(hashes), 'managed_input_mismatches': mismatches,
        'snapshot_files_checked': len(snapshot['files_sha256']),
        'snapshot_mismatches': snapshot_mismatches,
        'skipped': bool(re.search(r'\.\.\. skipped|^OK \(skipped=', log, re.M)), 'fingerprint': prepared['fingerprint'],
        'finished_at': terminal['utc'],
    }
    write(result_file, record)
    print(json.dumps(record, indent=2), flush=True)
    assert process.returncode == 0 and terminal.get('outcome') == 'success', 'retained failed outcome; report/diagnose before any mutation'
    assert not mismatches and not snapshot_mismatches and not record['skipped'] and actual == expected
    assert test_duration and int(test_duration.group(1)) == expected_count


def restore():
    assert BACKUP.exists()
    final_checks = {}
    for label in RUNS:
        record = json.loads((HERE / label / 'verification.json').read_text())
        assert record['outcome'] == 'success' and not record['managed_input_mismatches']
        events = [json.loads(line) for line in gzip.decompress((HERE / label / 'events.jsonl.gz').read_bytes()).splitlines()]
        captured = next(event['inputs']['inputs_sha256'] for event in events if event['event'] == 'prepared')
        mismatches = [name for name, expected in captured.items() if digest(Path(name)) != expected]
        final_checks[label] = {'run_id': record['run_id'], 'input_count': len(captured), 'mismatches': mismatches}
    write(HERE / 'final-input-verification.json', final_checks)
    assert all(not item['mismatches'] for item in final_checks.values()), 'inputs changed after an earlier result; retain/report before restoration'
    assert snapshot_check() == len(json.loads((HERE / "snapshot-manifest.json").read_text())["files_sha256"])
    original = json.loads((HERE / 'original-nodes.json').read_text())
    for name in PATHS:
        current, saved = WORK / name, BACKUP / 'original' / name
        tested = BACKUP / 'tested' / name
        tested.parent.mkdir(parents=True, exist_ok=True)
        current.rename(tested)
        if saved.exists() or saved.is_symlink():
            saved.rename(current)
    observed = nodes(WORK)
    missing = [name for name in original if original[name] != observed.get(name)]
    extras = sorted(observed.keys() - original.keys())
    status = subprocess.check_output(['git', 'status', '--porcelain=v1', '-uall'], cwd=WORK, text=True)
    # The dedicated new backup is inside the preserved scratch area; exclude
    # its own paths when comparing the existing checkout status.
    def filtered(value):
        return [line for line in value.splitlines() if 'tmp/boolean-repair-regression-91de/' not in line]
    prior_status = (HERE / 'original-status.txt').read_text()
    original_git = json.loads((HERE / 'original-git-state.json').read_text())
    restored_git = {'head': subprocess.check_output(['git', 'rev-parse', 'HEAD'], cwd=WORK, text=True).strip(), 'branch': subprocess.check_output(['git', 'branch', '--show-current'], cwd=WORK, text=True).strip()}
    assert original_git == restored_git, (original_git, restored_git)
    record = {'git_state_preserved': True, 'restored_at': datetime.datetime.now(datetime.timezone.utc).isoformat(),
              'original_nodes_checked': len(original), 'mismatches': missing, 'extra_nodes': extras,
              'original_status_preserved': filtered(status) == filtered(prior_status),
              'compiler_sha256': digest(WORK / '.silver/linux-x86_64/compiler/bin/silver'),
              'adapter_sha256': digest(WORK / '.silver/linux-x86_64/compiler/bin/silver_image_adapter')}
    write(HERE / 'restoration-verification.json', record)
    print(json.dumps(record, indent=2))
    assert not missing and not extras and record['original_status_preserved']


if __name__ == '__main__':
    if sys.argv[1] == 'install':
        install()
    elif sys.argv[1] == 'restore':
        restore()
    else:
        run(sys.argv[1])
