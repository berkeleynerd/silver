import json
from pathlib import Path
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = Path('/home/canto/src/github.com/berkeleynerd/silver')
ARTIFACTS = ROOT/'.silver/linux-x86_64'
before = set(ARTIFACTS.glob('program-*'))
command = [str(ARTIFACTS/'compiler/bin/silver'), 'run', str(HERE/'cr/main.adb')]
start = time.monotonic()
result = subprocess.run(command, cwd=HERE, capture_output=True)
row = {'command':command, 'returncode':result.returncode,
       'seconds':time.monotonic()-start,
       'stdout':result.stdout.decode(errors='replace'),
       'stderr':result.stderr.decode(errors='replace'),
       'new_program_directories':[str(p) for p in sorted(set(ARTIFACTS.glob('program-*'))-before)]}
(HERE/'endtoend.json').write_text(json.dumps(row,indent=2)+'\n')
print(json.dumps(row,indent=2))
