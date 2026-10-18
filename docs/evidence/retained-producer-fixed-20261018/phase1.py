#!/usr/bin/env python3
from pathlib import Path
import json
import os
import subprocess
import time

root = Path(__file__).resolve().parent
plan = json.loads((root / 'invocation-phase1.json').read_text())
env = dict(os.environ)
env.update(plan['environment'])
start = time.monotonic()
run = subprocess.run(plan['argv'], cwd=plan['cwd'], env=env,
                     stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                     text=True, timeout=45)
(root / 'phase1.log').write_text(run.stdout)
result = dict(exit_status=run.returncode, elapsed_seconds=time.monotonic()-start,
              scope='isolated null Main global generation only, no solvers',
              argv=plan['argv'], cwd=plan['cwd'])
(root / 'phase1-result.json').write_text(json.dumps(result, indent=2)+'\n')
print(run.stdout)
print(json.dumps(result))
raise SystemExit(run.returncode)
