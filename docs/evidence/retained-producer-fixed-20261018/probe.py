#!/usr/bin/env python3
"""One isolated debugger observation; no proof or membership claim."""
from pathlib import Path
import hashlib
import json
import os
import signal
import subprocess
import sys
import time

root = Path(__file__).resolve().parent
plan = json.loads((root / 'invocation.json').read_text())
gdb_root = Path('/tmp/silver-capacity-debugger-20261018/root')
gdb = gdb_root / 'usr/bin/gdb'
env = dict(os.environ)
env.update(plan['environment'])
env['LD_LIBRARY_PATH'] = str(gdb_root / 'usr/lib/x86_64-linux-gnu')
env['DEBUGINFOD_URLS'] = ''
command = [str(gdb), '-nx', '-q', '-batch', '-x', str(root / 'probe.gdb'), '--args', *plan['argv']]
start = time.monotonic()
process = subprocess.Popen(command, cwd=plan['cwd'], env=env,
                           stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                           text=True, start_new_session=True)
try:
    output, _ = process.communicate(timeout=45)
except subprocess.TimeoutExpired:
    os.killpg(process.pid, signal.SIGTERM)
    try:
        output, _ = process.communicate(timeout=5)
    except subprocess.TimeoutExpired:
        os.killpg(process.pid, signal.SIGKILL)
        output, _ = process.communicate()
    (root / 'probe.log').write_text(output)
    raise SystemExit('Debugger probe timed out; retained output, no successful measurement')
(root / 'probe.log').write_text(output)
snapshots = [json.loads(line.removeprefix('CAPACITY_SNAPSHOT '))
             for line in output.splitlines() if line.startswith('CAPACITY_SNAPSHOT ')]
result = dict(command=command, cwd=plan['cwd'],
              producer_sha256=hashlib.sha256(Path(plan['argv'][0]).read_bytes()).hexdigest(),
              debugger_sha256=hashlib.sha256(gdb.read_bytes()).hexdigest(),
              elapsed_seconds=time.monotonic()-start,
              debugger_exit=process.returncode, snapshots=snapshots,
              scope='observed isolated null Main, reconstructed producer invocation, no solvers')
(root / 'result.json').write_text(json.dumps(result, indent=2)+'\n')
print(output)
print(json.dumps({k:result[k] for k in ('elapsed_seconds','debugger_exit','snapshots')}))
if process.returncode or {r['phase'] for r in snapshots} != {'before_standard','after_standard','before_free'}:
    raise SystemExit('Did not observe all expected producer phases')
