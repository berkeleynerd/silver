#!/usr/bin/env python3
"""Lead-only optional frame experiment; default emits a plan, --execute runs it.

Synthetic frames are storage proxies. --compiler adds exact-source baseline
recognition; run again with the eventual candidate binary at implementation time.
No proxy result establishes actual parser resource sufficiency.
"""
from pathlib import Path
from datetime import datetime, timezone
import argparse
import hashlib
import json
import resource
import shutil
import subprocess
import sys
import time
BASE=Path(__file__).resolve().parent
ROOT=BASE.parents[1]
RUNNER_ROOT=ROOT
PROXY=BASE/'frame-proxy'


def managed(tool,workspace,inputs,jobs=1):
    result=[sys.executable,str(RUNNER_ROOT/'scripts/dev.py'),'tool','--task','#237',
            '--jobs',str(jobs),'--reason','Measure feature-local recursive frame storage before scalar-flow representation selection.',
            '--workspace',str(workspace)]
    for path in inputs:
        result+=['--input',str(path)]
    return result+['--',*tool]


def run(command,out,stack_kib=None):
    def limit():
        resource.setrlimit(resource.RLIMIT_STACK,(stack_kib*1024,stack_kib*1024))
    start=time.monotonic()
    value=subprocess.run(command,cwd=RUNNER_ROOT,capture_output=True,text=True,
                         preexec_fn=limit if stack_kib else None)
    out.with_suffix('.stdout').write_text(value.stdout)
    out.with_suffix('.stderr').write_text(value.stderr)
    return dict(command=command,exit_status=value.returncode,stack_kib=stack_kib,
                elapsed_seconds=time.monotonic()-start)


def main():
    global RUNNER_ROOT
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--execute',action='store_true')
    parser.add_argument('--runner-root',type=Path,default=ROOT,help='Checkout owning the existing installed toolchain; projects stay in this scratch tree')
    parser.add_argument('--compiler',type=Path,help='Existing current/candidate silver executable, for check only')
    args=parser.parse_args()
    RUNNER_ROOT=args.runner_root.resolve(strict=True)
    shapes=json.loads((BASE/'recognizer-shapes/shapes.json').read_text())
    build=managed(['gprbuild','-P',str(PROXY/'frame.gpr'),'-p'],PROXY,
                  [PROXY/'frame.gpr',PROXY/'src'])
    rows=[dict(mode=mode,depth=shape['depth'],count=shape['active_scalars'],stack_kib=8192)
          for shape in shapes if shape['form']=='parentheses' for mode in ['current','fixed','active']]
    if not args.execute:
        print(json.dumps(dict(build=build,proxy_runs=rows,compiler=str(args.compiler) if args.compiler else None,
                              status='planned only; no native tools run'),indent=2))
        return
    subprocess.run([sys.executable,'scripts/dev.py','runs','status'],cwd=RUNNER_ROOT,check=True)
    subprocess.run([sys.executable,'scripts/dev.py','paths'],cwd=RUNNER_ROOT,check=True)
    out=BASE/'frame-results'/datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')
    out.mkdir(parents=True,exist_ok=False)
    summary={'build':run(build,out/'build'),'proxy':[],'recognizer':[]}
    if summary['build']['exit_status']!=0:
        (out/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
        raise SystemExit('Proxy build failed; complete logs retained; no measurements claimed.')
    for path in (PROXY/'obj').rglob('*.su'):
        shutil.copy2(path,out/path.name)
    for index,row in enumerate(rows):
        command=managed([str(PROXY/'bin/main'),row['mode'],str(row['depth']),str(row['count']),'1'],
                        out,[PROXY/'bin/main',PROXY/'src',PROXY/'frame.gpr'])
        summary['proxy'].append({**row,**run(command,out/f'proxy-{index}',row['stack_kib'])})
    if args.compiler:
        compiler=args.compiler.resolve(strict=True)
        summary['compiler_sha256']=hashlib.sha256(compiler.read_bytes()).hexdigest()
        for shape in shapes:
            for neighbor in [False,True]:
                name=shape['name']+('-4097' if neighbor else '')
                source=BASE/'recognizer-shapes'/(name+'.adb')
                command=managed([str(compiler),'check',str(source)],out,[compiler,source])
                summary['recognizer'].append(dict(name=name,**run(command,out/name,8192)))
    (out/'summary.json').write_text(json.dumps(summary,indent=2)+'\n')
    print(out)

if __name__=='__main__':
    main()
