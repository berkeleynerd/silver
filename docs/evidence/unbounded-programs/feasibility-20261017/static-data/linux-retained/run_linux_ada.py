#!/usr/bin/env python3
"""Same-source Ada backend probe; no proof/build/application execution."""
from pathlib import Path
import json
import platform
import shutil
import subprocess
import sys

base = Path(__file__).resolve().parent
gcc = Path(sys.argv[1]).resolve()
runtime_src = Path(sys.argv[2]).resolve()
assert platform.system() == 'Linux'
lines = ['with Silver_IO;', 'procedure Main is', '   pragma SPARK_Mode (On);',
         '   A0 : constant String := "x";']
for i in range(1,21):
    lines.append(f'   A{i} : constant String := A{i-1} & A{i-1};')
lines += ['begin','   Silver_IO.Put_Line (A20);','end Main;']
source = '\n'.join(lines)+'\n'
for model in ['small', 'medium', 'large']:
    d = base / 'probes' / ('linux-ada-1mib-'+model)
    d.mkdir(parents=True, exist_ok=False)
    (d/'main.adb').write_text(source)
    for name in ['silver_io.ads','silver_io.adb','silver_output_libc.ads',
                 'silver_arguments.ads','silver_arguments.adb','silver_runtime.ads']:
        shutil.copy2(runtime_src/name,d/name)
    cmd = [sys.executable, str(base/'run_probe.py'), str(d), '--', str(gcc),
           '-v', '-S', '-O0', '-gnat2022', '-gnata', '-gnato',
           '-mcmodel='+model, 'main.adb', '-o', 'main.s']
    subprocess.run(cmd, check=True)
    result=json.loads((d/'result.json').read_text())
    print(model, 'status', result['exit_status'], 'guard', result['guard_trigger'], flush=True)
