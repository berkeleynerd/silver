import json
from pathlib import Path
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = Path('/home/canto/src/github.com/berkeleynerd/silver')
GNATPROVE = ROOT/'.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/bin/gnatprove'
cwd = HERE/'naming-body-indexed'
command = [str(GNATPROVE), '-P', str(cwd/'program.gpr'), '-U', '--mode=all',
           '--report=all', '--warnings=error', '--checks-as-errors=on',
           '--level=2', '--prover=cvc5,z3,altergo', '--steps=100000',
           '--timeout=0', '--memlimit=1000', '-j1', '--no-loop-unrolling',
           '--subdirs=explore/cr-comment']
start = time.monotonic()
result = subprocess.run(command, cwd=cwd, capture_output=True)
row = {'command':command, 'returncode':result.returncode,
       'seconds':time.monotonic()-start,
       'stdout':result.stdout.decode(errors='replace'),
       'stderr':result.stderr.decode(errors='replace')}
(HERE/'candidate-indexed.json').write_text(json.dumps(row,indent=2)+'\n')
print(json.dumps(row,indent=2))
