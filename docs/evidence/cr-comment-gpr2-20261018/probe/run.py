import hashlib
import json
from pathlib import Path
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = Path('/home/canto/src/github.com/berkeleynerd/silver')
SILVER = ROOT/'.silver/linux-x86_64/compiler/bin/silver'
GNATPROVE = ROOT/'.tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/bin/gnatprove'
rows = []
for variant in ['lf', 'cr']:
    cwd = HERE/variant
    commands = [
        [str(SILVER), 'check', str(cwd/'main.adb')],
        [str(GNATPROVE), '-P', str(cwd/'program.gpr'), '-U', '--mode=all',
         '--report=all', '--warnings=error', '--checks-as-errors=on',
         '--level=2', '--prover=cvc5,z3,altergo', '--steps=100000',
         '--timeout=0', '--memlimit=1000', '-j1', '--no-loop-unrolling',
         '--subdirs=explore/cr-comment'],
    ]
    for i, command in enumerate(commands):
        start = time.monotonic()
        result = subprocess.run(command, cwd=cwd, capture_output=True)
        elapsed = time.monotonic()-start
        (cwd/f'command-{i}.stdout').write_bytes(result.stdout)
        (cwd/f'command-{i}.stderr').write_bytes(result.stderr)
        rows.append({'variant':variant, 'command':command,
                     'returncode':result.returncode, 'seconds':elapsed,
                     'stdout':result.stdout.decode(errors='replace'),
                     'stderr':result.stderr.decode(errors='replace')})
        print(json.dumps(rows[-1]), flush=True)
(HERE/'result.json').write_text(json.dumps({
    'purpose':'Two-source diagnostic, not a full audit or capacity proof',
    'executables':{str(p):hashlib.sha256(p.read_bytes()).hexdigest()
                   for p in [SILVER,GNATPROVE]},
    'runs':rows},indent=2)+'\n')
