#!/usr/bin/env python3
"""Authorized static-data research only: compile/link, never execute outputs."""
from pathlib import Path
import hashlib
import json
import os
import platform
import shutil
import subprocess
import sys

base = Path(__file__).resolve().parent
gcc = Path(sys.argv[1]).resolve()
assert platform.system() == 'Linux'
records = []
for cmd in [['uname', '-a'], [str(gcc), '-v'], [str(gcc), '-dumpmachine'],
            [str(gcc), '-print-prog-name=ld'], ['ld', '--version'],
            ['df', '-k', str(base)], ['free', '-b']]:
    r = subprocess.run(cmd, capture_output=True, text=True)
    records.append({'command': cmd, 'status': r.returncode, 'stdout': r.stdout, 'stderr': r.stderr})
(base / 'linux-identity.json').write_text(json.dumps(records, indent=2)+'\n')
hashes = []
for f in [gcc, Path(shutil.which('ld'))]:
    hashes.append({'path':str(f),'sha256':hashlib.sha256(f.read_bytes()).hexdigest(),'bytes':f.stat().st_size})
(base / 'linux-binary-hashes.json').write_text(json.dumps(hashes, indent=2)+'\n')
for name, n, model in [('linux-bss-control', 16, 'small'),
                       ('linux-bss-small', 2147483647, 'small'),
                       ('linux-bss-medium', 2147483647, 'medium'),
                       ('linux-bss-large', 2147483647, 'large')]:
    d = base / 'probes' / name
    d.mkdir(parents=True, exist_ok=False)
    (d/'probe.c').write_text(f'char a[{n}];\nchar b[{n}];\nchar c[{n}];\nint main(void) {{ a[0] = 1; b[0] = 2; c[0] = 3; return a[0] + b[0] + c[0]; }}\n')
    cmd = [sys.executable, str(base/'run_probe.py'), str(d), '--', str(gcc),
           '-v', '-O0', '-save-temps', '-mcmodel='+model, 'probe.c', '-o', 'probe']
    subprocess.run(cmd, check=True)
    for filename, options in [('probe.o', ['-W','-S','-r']), ('probe',['-W','-S','-l'])]:
        if (d/filename).exists():
            r = subprocess.run(['readelf',*options,filename],cwd=d,capture_output=True,text=True)
            (d/(filename+'.readelf.txt')).write_text(r.stdout+r.stderr)
    result=json.loads((d/'result.json').read_text())
    print(name, 'status', result['exit_status'], 'guard', result['guard_trigger'], flush=True)
