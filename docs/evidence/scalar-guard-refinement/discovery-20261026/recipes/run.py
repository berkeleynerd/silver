#!/usr/bin/env python3
"""Serial scratch native discovery; default prints commands, --execute runs them.

This is ordinary Ada/SPARK discovery, never a Silver admission/proof claim.
Only the lead may invoke --execute after checking native worker/headroom status.
"""
from pathlib import Path
from collections import Counter
from datetime import datetime, timezone
import argparse
import hashlib
import json
import shutil
import subprocess
import sys
import time

BASE = Path(__file__).resolve().parent
ROOT = BASE.parents[1]
RUNNER_ROOT = ROOT
OPTIONS = ['--subdirs=explore/guard', '-U', '--mode=all', '--report=all',
           '--checks-as-errors=on', '--level=2', '--prover=cvc5,z3,altergo',
           '--steps=100000', '--timeout=0', '--memlimit=1000',
           '--no-loop-unrolling', '--warnings=continue']


def native_command(case, jobs, tool, subdir="explore/guard"):
    project = case / 'probe.gpr'
    inputs = [case / 'src', project]
    if case.name == 'doors':
        inputs += [ROOT / 'src' / name for name in
                   ['silver_io.ads', 'silver_io.adb', 'silver_output_libc.ads']]
    command = [sys.executable, str(RUNNER_ROOT / 'scripts/dev.py'), 'tool', '--task', '#237',
               '--jobs', str(jobs), '--reason', 'Guard-specific native discovery on original unannotated Main source.',
               '--workspace', str(case)]
    for item in inputs:
        command += ['--input', str(item)]
    command += ['--', tool, '-P', str(project)]
    return command + ([f'--subdirs={subdir}', *OPTIONS[1:]] if tool == 'gnatprove' else ['-p'])


def execute(command, destination):
    start = time.monotonic()
    result = subprocess.run(command, cwd=RUNNER_ROOT, capture_output=True, text=True)
    destination.with_suffix('.stdout').write_text(result.stdout)
    destination.with_suffix('.stderr').write_text(result.stderr)
    return dict(command=command, exit_status=result.returncode,
                elapsed_seconds=time.monotonic()-start)


def inventory(folder):
    # Keep raw .spark labels separate from SARIF's normalized ruleId vocabulary.
    records = []
    sarif = []
    for path in sorted(folder.rglob('*.spark')):
        data = json.loads(path.read_text())
        for category in ['proof', 'flow', 'warn_error', 'spark']:
            for item in data.get(category, []):
                if isinstance(item, dict):
                    records.append(dict(report=str(path.relative_to(folder)), category=category,
                                        **{k:item[k] for k in ['rule','severity','file','line','col','message','how_proved'] if k in item}))
    for path in sorted(folder.rglob('*.sarif')):
        for run in json.loads(path.read_text()).get('runs', []):
            for item in run.get('results', []):
                sarif.append(dict(report=str(path.relative_to(folder)),
                                  **{k:item[k] for k in ['ruleId','level','message','locations'] if k in item}))
    return dict(raw_records=records, sarif_records=sarif,
                raw_rule_counts=dict(Counter((r.get('rule') or '(no rule)') for r in records)),
                sarif_rule_counts=dict(Counter((r.get('ruleId') or '(no rule)') for r in sarif)))


def main():
    global RUNNER_ROOT
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--execute', action='store_true')
    parser.add_argument('--runner-root', type=Path, default=ROOT, help='Checkout owning the existing installed toolchain; projects stay in this scratch tree')
    parser.add_argument('--jobs', type=int, default=2)
    parser.add_argument('--only', nargs='+', help='Selected manifest case names, in manifest order')
    parser.add_argument('--skip-driver-execution', action='store_true')
    args = parser.parse_args()
    RUNNER_ROOT=args.runner_root.resolve(strict=True)
    if args.jobs < 1:
        parser.error('--jobs must be an explicit positive reservation')
    manifest = json.loads((BASE/'manifest.json').read_text())
    known = {c['name'] for c in manifest['cases']}
    if args.only and set(args.only)-known:
        parser.error('unknown --only case')
    cases = [c for c in manifest['cases'] if not args.only or c['name'] in args.only]
    batch_id=datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')
    subdir='explore/guard/'+batch_id
    commands = [native_command(BASE/'probes'/c['name'], args.jobs, 'gnatprove', subdir) for c in cases]
    if not args.execute:
        print(json.dumps(dict(status='dry plan; no tools run', commands=commands), indent=2))
        return
    # Read the managed summary and paths before launching any native process.
    subprocess.run([sys.executable, 'scripts/dev.py', 'runs', 'status'], cwd=RUNNER_ROOT, check=True)
    subprocess.run([sys.executable, 'scripts/dev.py', 'paths'], cwd=RUNNER_ROOT, check=True)
    batch = BASE/'results'/batch_id
    batch.mkdir(parents=True, exist_ok=False)
    shutil.copy2(BASE/'manifest.json', batch/'expectations.json')
    outcomes=[]
    for expectation, command in zip(cases, commands):
        name=expectation['name']
        case=BASE/'probes'/name
        out=batch/name
        out.mkdir()
        shutil.copytree(case/'src', out/'src')
        shutil.copy2(case/'probe.gpr', out/'probe.gpr')
        result=execute(command, out/'proof')
        result['name']=name
        result['native_expectation']=expectation['native_expectation']
        result['main_sha256']=hashlib.sha256((case/'src/main.adb').read_bytes()).hexdigest()
        reports=case/'obj'/subdir/'gnatprove'
        if reports.exists():
            shutil.copytree(reports, out/'reports')
            result['inventory']=inventory(out/'reports')
        else:
            result['inventory']={'note':'No report directory; inspect complete frontend stdout/stderr.'}
        if name=='doors' and result['exit_status']==0 and not args.skip_driver_execution:
            result['build']=execute(native_command(case,args.jobs,'gprbuild'),out/'build')
            if result['build']['exit_status']==0:
                app=subprocess.run([str(case/'bin/main')],cwd=case,capture_output=True,timeout=30)
                (out/'program.stdout').write_bytes(app.stdout)
                (out/'program.stderr').write_bytes(app.stderr)
                expected=(BASE/'doors.expected.txt').read_bytes()
                shutil.copy2(BASE/'doors.expected.txt',out/'expected.txt')
                result['execution']={'exit_status':app.returncode,'stdout_matches_independent_toggle_model':app.stdout==expected,
                                     'stdout_lines':len(app.stdout.splitlines()),'stderr_empty':app.stderr==b''}
        (out/'run.json').write_text(json.dumps(result,indent=2)+'\n')
        outcomes.append(result)
        # Expected failure is recorded, never suppressed or represented as proof success.
        print(json.dumps({'case':name,'expected':expectation['native_expectation'],'observed_exit':result['exit_status']}),flush=True)
    (batch/'summary.json').write_text(json.dumps(outcomes,indent=2)+'\n')
    print(batch)
    print('Manual full-report/source-site review remains required; exits alone are not the discovery verdict.')

if __name__=='__main__':
    main()
