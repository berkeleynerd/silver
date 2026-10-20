#!/usr/bin/env python3
"""R54 bounded reviewer checks. Runs no native target, compiler, solver or proof.

The exclusion author's checker normally overwrites check-result.json. Redirect
only that write, and its temporary-directory root, into this reviewer packet.
All computation and exact-output comparisons in the frozen checker are intact.
"""
import datetime
import hashlib
import json
from pathlib import Path
import platform
import subprocess
import sys
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
SLICES = {
    'completion': 'retained-server-completion-format-20261020',
    'exclusion': 'retained-why-parallel-symbol-exclusion-20261020',
    'attribution': 'retained-fixed-goal-attribution-20261020',
}

def identity(p):
    b = p.read_bytes()
    return {'bytes': len(b), 'sha256': hashlib.sha256(b).hexdigest()}

def run():
    assert not (HERE / 'check-runs.json').exists(), 'Retain first check; do not repeat silently.'
    results = []
    before = {str(p.relative_to(ROOT)): identity(p)
              for dirname in SLICES.values()
              for p in (ROOT / 'docs/evidence' / dirname).rglob('*') if p.is_file()}
    for name, dirname in SLICES.items():
        script = ROOT / 'docs/evidence' / dirname / 'check.py'
        if name == 'exclusion':
            wrapper = r'''
import pathlib, runpy, sys, tempfile
from unittest.mock import patch
script = pathlib.Path(sys.argv[1]); reviewer = pathlib.Path(sys.argv[2])
author_result = script.parent / 'check-result.json'
original_write = pathlib.Path.write_text
original_temp = tempfile.TemporaryDirectory
def write_text(self, data, *args, **kwargs):
    if self == author_result:
        self = reviewer / 'exclusion-check-result.json'
    return original_write(self, data, *args, **kwargs)
def temp(*args, **kwargs):
    kwargs['dir'] = reviewer
    return original_temp(*args, **kwargs)
sys.argv = [str(script)]
with patch.object(pathlib.Path, 'write_text', write_text), patch.object(tempfile, 'TemporaryDirectory', temp):
    runpy.run_path(str(script), run_name='__main__')
'''
            cmd = [sys.executable, '-B', '-c', wrapper, str(script), str(HERE)]
        else:
            cmd = [sys.executable, '-B', str(script)]
        start = time.monotonic()
        when = datetime.datetime.now(datetime.timezone.utc).isoformat()
        p = subprocess.run(cmd, cwd=ROOT, capture_output=True, text=True)
        elapsed = time.monotonic() - start
        (HERE / (name + '-stdout.json')).write_text(p.stdout)
        (HERE / (name + '-stderr.txt')).write_text(p.stderr)
        row = {'component': name, 'script': str(script.relative_to(ROOT)),
               'script_identity': identity(script), 'started_utc': when,
               'elapsed_seconds': elapsed, 'exit_code': p.returncode}
        if p.returncode == 0:
            row['result'] = json.loads(p.stdout)
        results.append(row)
        print(json.dumps(row), flush=True)
    after = {str(p.relative_to(ROOT)): identity(p)
             for dirname in SLICES.values()
             for p in (ROOT / 'docs/evidence' / dirname).rglob('*') if p.is_file()}
    record = {'host': platform.system(), 'machine': platform.machine(),
              'author_packets_unchanged': before == after, 'runs': results,
              'native_runs': 0, 'predecessor_replays': 0}
    (HERE / 'check-runs.json').write_text(json.dumps(record, indent=2) + '\n')
    assert before == after, 'Author packet mutated'
    assert all(r['exit_code'] == 0 for r in results)

if __name__ == '__main__':
    run()
