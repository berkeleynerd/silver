import hashlib
import json
from pathlib import Path
import shutil
import subprocess
import time

HERE = Path(__file__).resolve().parent
cwd = HERE/'naming-body-indexed'
GPRBUILD = Path(shutil.which('gprbuild')).resolve()
commands = [[str(GPRBUILD), '-P', str(cwd/'program.gpr'), '-p', '-j1'],
            [str(cwd/'bin/main')]]
rows = []
for command in commands:
    start = time.monotonic()
    result = subprocess.run(command, cwd=cwd, capture_output=True)
    rows.append({'command':command, 'returncode':result.returncode,
                 'seconds':time.monotonic()-start,
                 'stdout':result.stdout.decode(errors='replace'),
                 'stderr':result.stderr.decode(errors='replace')})
    print(json.dumps(rows[-1]), flush=True)
    if result.returncode:
        break
(HERE/'candidate-native-indexed.json').write_text(json.dumps({
    'gprbuild':str(GPRBUILD),
    'gprbuild_sha256':hashlib.sha256(GPRBUILD.read_bytes()).hexdigest(),
    'runs':rows},indent=2)+'\n')
