#!/usr/bin/env python3
"""Retain one new author check; divert only the state check's summary write.

This is an offline projection/source/ELF-data check, not a native target run.
The output record must not already exist, preventing accidental repeat checks.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PACKETS = {
    'logging': 'retained-parallel-logging-prefix-20261020',
    'state': 'retained-why-parallel-state-attachment-20261020',
}


def identity(path):
    data = path.read_bytes()
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('component', choices=PACKETS)
    parser.add_argument('--author-freeze', required=True)
    args = parser.parse_args()
    packet = ROOT / 'docs/evidence' / PACKETS[args.component]
    script = packet / 'check.py'
    record = HERE / (args.component + '-check.json')
    assert not record.exists(), 'Retain the first successful check; do not replay.'
    before = {str(p.relative_to(ROOT)): identity(p)
              for p in sorted(packet.rglob('*')) if p.is_file()}
    command = [sys.executable, '-B', str(script.relative_to(ROOT))]
    redirected = None
    if args.component == 'state':
        redirected = HERE / 'state-check-summary.json'
        assert not redirected.exists()
        shim = '''from pathlib import Path
import runpy, sys
from unittest.mock import patch
script = Path(sys.argv[1]).resolve()
destination = Path(sys.argv[2]).resolve()
original = Path.write_text
def redirect(path, data, *args, **kwargs):
    assert path.resolve() == script.parent / 'check-result.json', path
    return original(destination, data, *args, **kwargs)
sys.path.insert(0, str(script.parent))
sys.argv = [str(script)]
with patch.object(Path, 'write_text', redirect):
    runpy.run_path(str(script), run_name='__main__')
'''
        command = [sys.executable, '-B', '-c', shim,
                   str(script.relative_to(ROOT)), str(redirected.relative_to(ROOT))]
    started = datetime.now(timezone.utc).isoformat()
    start = time.monotonic()
    result = subprocess.run(command, cwd=ROOT, text=True, capture_output=True)
    elapsed = time.monotonic() - start
    after = {str(p.relative_to(ROOT)): identity(p)
             for p in sorted(packet.rglob('*')) if p.is_file()}
    summary = json.loads(result.stdout) if result.returncode == 0 else None
    retained = {
        'component': args.component, 'author_freeze': args.author_freeze,
        'started_utc': started, 'elapsed_seconds': elapsed,
        'command': command, 'script_identity': identity(script),
        'author_packet_before': before, 'author_packet_unchanged': before == after,
        'exit_code': result.returncode, 'stdout': result.stdout,
        'stderr': result.stderr, 'result': summary,
        'redirected_summary': str(redirected.relative_to(ROOT)) if redirected else None,
    }
    record.write_text(json.dumps(retained, indent=2) + '\n')
    print(json.dumps({k: retained[k] for k in
                     ('component', 'elapsed_seconds', 'exit_code',
                      'author_packet_unchanged', 'result')}, indent=2))
    assert before == after
    assert result.returncode == 0
    if redirected:
        assert json.loads(redirected.read_text()) == summary


if __name__ == '__main__':
    main()
