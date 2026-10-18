"""One managed first-RTL setup capture; no completed compilation."""
from pathlib import Path
import hashlib
import json
import os
import signal
import subprocess
import time

root = Path(__file__).parent
capture = root / 'capture'
plan = json.loads((root / 'invocation.json').read_text())
assert not (capture / 'result.json').exists(), 'preserve previous capture'
gdbroot = Path('/tmp/silver-capacity-debugger-20261018/root')
gdb = gdbroot / 'usr/bin/gdb'
script = '''set pagination off
set confirm off
set auto-load off
set debuginfod enabled off
set startup-with-shell off
set disable-randomization off
set breakpoint always-inserted on
set follow-fork-mode child
set detach-on-fork on
set language c
python
import gdb,json
plan=json.load(open('/tmp/silver-native-rtl-setup-20261018/invocation.json'))
gdb.execute('unset environment')
for key,value in plan['environment'].items():
    gdb.execute('set environment '+key+'='+value)
end
catch exec
run
python
exec(open('/tmp/silver-native-rtl-setup-20261018/frontend.py').read())
end
break *0x1358170
continue
python
exec(open('/tmp/silver-native-rtl-setup-20261018/counters.py').read())
end
continue
python
finish_capture()
end
quit
'''
(capture / 'probe.gdb').write_text(script)
debugger_environment = {'PATH': '/usr/bin:/bin', 'LC_ALL': 'C', 'LANG': 'C',
    'LD_LIBRARY_PATH': str(gdbroot / 'usr/lib/x86_64-linux-gnu'), 'DEBUGINFOD_URLS': ''}
cmd = [str(gdb), '-nx', '-q', '-batch', '-x', str(capture / 'probe.gdb'), '--args', *plan['argv']]
start = time.monotonic()
process = subprocess.Popen(cmd, cwd=plan['cwd'], env=debugger_environment,
    stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True, start_new_session=True)
timed_out = False
try:
    output, _ = process.communicate(timeout=300)
except subprocess.TimeoutExpired:
    timed_out = True
    os.killpg(process.pid, signal.SIGTERM)
    output, _ = process.communicate(timeout=30)
(capture / 'probe.log').write_text(output)
result = {'command': cmd, 'debugger_environment': debugger_environment,
    'elapsed_seconds': time.monotonic()-start, 'returncode': process.returncode,
    'timed_out': timed_out, 'scope': 'first initialize_rtl entry-to-return counters; no compiler output delivery',
    'gnat1_sha256': hashlib.sha256(Path(plan['gnat1']).read_bytes()).hexdigest(),
    'gcc_sha256': hashlib.sha256(Path(plan['argv'][0]).read_bytes()).hexdigest(),
    'gdb_sha256': hashlib.sha256(gdb.read_bytes()).hexdigest()}
(capture / 'result.json').write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps(result))
print('\n'.join(line for line in output.splitlines() if line.startswith('RTL_')))
if timed_out or process.returncode or not (capture / 'counter-summary.json').exists():
    print(output)
    raise SystemExit(1)
data = json.loads((capture / 'counter-summary.json').read_text())
assert data['completed'] and not data['failures'] and not data['unexpected_collections'] and not data['new_threads']
