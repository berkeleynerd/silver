#!/usr/bin/env python3
"""Serial scratch probe; not Silver tooling. No project/cache writes."""
import argparse
import datetime
import hashlib
import json
import os
import platform
from pathlib import Path
import resource
import signal
import subprocess
import time

p = argparse.ArgumentParser()
p.add_argument('case')
p.add_argument('--rss-mib', type=int, default=512)
p.add_argument('--file-mib', type=int, default=16)
p.add_argument('--seconds', type=float, default=30)
p.add_argument('command', nargs=argparse.REMAINDER)
a = p.parse_args()
cwd = Path(a.case).resolve()
cmd = a.command[1:] if a.command[:1] == ['--'] else a.command
cwd.mkdir(parents=True, exist_ok=True)
inputs = {str(f.relative_to(cwd)): hashlib.sha256(f.read_bytes()).hexdigest()
          for f in cwd.rglob('*') if f.is_file()}
# Refuse to launch any child unless the sampled memory guard is available.
subprocess.check_output(['ps', '-axo', 'pgid=,rss='], text=True)
started = datetime.datetime.now(datetime.timezone.utc).isoformat()
before = resource.getrusage(resource.RUSAGE_CHILDREN)

def limits():
    resource.setrlimit(resource.RLIMIT_CORE, (0, 0))
    resource.setrlimit(resource.RLIMIT_FSIZE, (a.file_mib * 1048576,) * 2)
    resource.setrlimit(resource.RLIMIT_CPU, (int(a.seconds) + 2,) * 2)

maximum_rss = 0
guard = None
samples = []
begin = time.monotonic()
with (cwd / 'stdout.txt').open('wb') as out, (cwd / 'stderr.txt').open('wb') as err:
    proc = subprocess.Popen(cmd, cwd=cwd, stdout=out, stderr=err,
                            start_new_session=True, preexec_fn=limits)
    while proc.poll() is None:
        elapsed = time.monotonic() - begin
        lines = subprocess.check_output(['ps', '-axo', 'pgid=,rss='], text=True).splitlines()
        rss = sum(int(x.split()[1]) for x in lines if x.split() and int(x.split()[0]) == proc.pid)
        maximum_rss = max(maximum_rss, rss)
        samples.append([round(elapsed, 4), rss])
        if elapsed > a.seconds or rss > a.rss_mib * 1024:
            guard = 'elapsed' if elapsed > a.seconds else 'aggregate_sampled_rss'
            os.killpg(proc.pid, signal.SIGTERM)
            try:
                proc.wait(timeout=1)
            except subprocess.TimeoutExpired:
                os.killpg(proc.pid, signal.SIGKILL)
            break
        time.sleep(.05)
    rc = proc.wait()
elapsed = time.monotonic() - begin
after = resource.getrusage(resource.RUSAGE_CHILDREN)
outputs = {str(f.relative_to(cwd)): {'bytes': f.stat().st_size,
           'allocated_bytes': f.stat().st_blocks * 512,
           'sha256': hashlib.sha256(f.read_bytes()).hexdigest()}
           for f in cwd.rglob('*') if f.is_file()}
result = {'started_utc': started, 'elapsed_seconds': elapsed, 'command': cmd,
          'cwd': str(cwd), 'exit_status': rc, 'guard_trigger': guard,
          'max_aggregate_sampled_rss_kib': maximum_rss,
          'child_maxrss_native_units': after.ru_maxrss,
          'child_maxrss_unit': 'bytes' if platform.system() == 'Darwin' else 'KiB',
          'child_user_seconds': after.ru_utime - before.ru_utime,
          'child_system_seconds': after.ru_stime - before.ru_stime,
          'limits': {'rss_mib_sampled': a.rss_mib, 'file_mib_rlimit': a.file_mib,
                     'wall_seconds': a.seconds, 'core_bytes': 0},
          'input_sha256': inputs, 'outputs': outputs, 'rss_samples': samples}
(cwd / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({k:v for k,v in result.items() if k not in ('outputs', 'rss_samples', 'input_sha256')}, indent=2))
