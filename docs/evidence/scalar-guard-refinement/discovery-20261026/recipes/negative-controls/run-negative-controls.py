#!/usr/bin/env python3
"""Run only six isolated expected-fail #237 controls; default is a dry plan.

Native failures remain failures. A diagnostic expectation is met only when its
own source site is unproved, not because some other site/tool failed first.
"""
from pathlib import Path
from datetime import datetime, timezone
from collections import Counter
import argparse
import hashlib
import json
import shutil
import subprocess
import sys
import time
import uuid

BASE=Path(__file__).resolve().parent
GUARD_ROOT=BASE.parents[2]
OPTIONS=['-U','--mode=all','--report=all','--checks-as-errors=on','--level=2',
         '--prover=cvc5,z3,altergo','--steps=100000','--timeout=0',
         '--memlimit=1000','--no-loop-unrolling','--warnings=continue']


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def command(runner_root,workspace,jobs,batch_id):
    return [sys.executable,str(runner_root/'scripts/dev.py'),'tool','--task','#237',
            '--jobs',str(jobs),'--reason',
            'Isolate one previously combined unsafe guard site so preceding failing checks cannot make it vacuously proved.',
            '--workspace',str(workspace),'--input',str(workspace/'src'),
            '--input',str(workspace/'probe.gpr'),'--','gnatprove','-P',str(workspace/'probe.gpr'),
            '--subdirs=explore/guard-negative/'+batch_id,*OPTIONS]


def inventory(folder):
    raw=[]
    sarif=[]
    for path in sorted(folder.rglob('*.spark')):
        data=json.loads(path.read_text())
        for category in ['proof','flow','warn_error','spark']:
            for item in data.get(category,[]):
                if isinstance(item,dict):
                    raw.append(dict(report=str(path.relative_to(folder)),category=category,
                                    **{k:item[k] for k in ['rule','severity','file','line','col',
                                                         'check_file','check_line','check_col',
                                                         'message','how_proved','unproved_status'] if k in item}))
    for path in sorted(folder.rglob('*.sarif')):
        for run in json.loads(path.read_text()).get('runs',[]):
            for item in run.get('results',[]):
                sarif.append(dict(report=str(path.relative_to(folder)),
                                  **{k:item[k] for k in ['ruleId','level','message','locations'] if k in item}))
    return dict(raw_records=raw,sarif_records=sarif,
                raw_rule_counts=dict(Counter(r.get('rule','(no rule)') for r in raw)),
                sarif_rule_counts=dict(Counter(r.get('ruleId','(no rule)') for r in sarif)))


def diagnosis(records,expectation,exit_status):
    expected=expectation['expected_check']
    unproved=[r for r in records if r['category']=='proof' and
              r.get('rule','').startswith('VC_') and r.get('severity')!='info']
    matching=[r for r in unproved if Path(r.get('file','')).name==expected['file'] and
              r.get('line')==expected['line'] and r.get('col')==expected['col'] and
              r.get('rule')==expected['rule'] and
              expected['message_contains'] in r.get('message',{}).get('text','')]
    return dict(expected_site=expected,observed_unproved_safety_records=unproved,
                expected_site_failure_records=matching,
                diagnostic_expectation_met=(exit_status!=0 and len(matching)==1 and len(unproved)==1),
                interpretation='Expected native failure at this one site; never a native proof pass. Missing/extra diagnostics require review.')


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--execute',action='store_true')
    parser.add_argument('--runner-root',type=Path,default=GUARD_ROOT,
                        help='Existing checkout owning installed pinned tools; never relocate tools')
    parser.add_argument('--jobs',type=int,default=2)
    args=parser.parse_args()
    if args.jobs<1:
        parser.error('--jobs must be an explicit positive worker reservation')
    runner_root=args.runner_root.resolve(strict=True)
    manifest=json.loads((BASE/'manifest.json').read_text())
    batch_id=datetime.now(timezone.utc).strftime('%Y%m%dT%H%M%SZ')+'-'+uuid.uuid4().hex[:8]
    batch=BASE/'results'/batch_id
    plans=[dict(name=c['name'],expected_check=c['expected_check'],
                command=command(runner_root,batch/c['name']/'input',args.jobs,batch_id)) for c in manifest['cases']]
    if not args.execute:
        print(json.dumps(dict(status='dry plan; no tools run',cases=plans),indent=2))
        return
    # Inspect all task labels, including active division/driver work, before scheduling.
    subprocess.run([sys.executable,'scripts/dev.py','runs','status'],cwd=runner_root,check=True)
    subprocess.run([sys.executable,'scripts/dev.py','paths'],cwd=runner_root,check=True)
    batch.mkdir(parents=True,exist_ok=False)
    shutil.copy2(BASE/'manifest.json',batch/'expectations.json')
    outcomes=[]
    for case,plan in zip(manifest['cases'],plans):
        out=batch/case['name']
        out.mkdir(exist_ok=False)
        submitted=out/'input'
        shutil.copytree(BASE/'projects'/case['name'],submitted)
        source=submitted/'src/main.adb'
        project=submitted/'probe.gpr'
        before={'main.adb':digest(source),'probe.gpr':digest(project)}
        if before['main.adb']!=case['source_sha256']:
            raise RuntimeError('Template source changed after manifest preparation: '+case['name'])
        source.chmod(0o444)
        project.chmod(0o444)
        result=dict(name=case['name'],native_expectation='EXPECTED FAIL',status='starting',
                    command=plan['command'],source_hashes_before=before,expected_check=case['expected_check'],
                    started_utc=datetime.now(timezone.utc).isoformat())
        (out/'run.json').write_text(json.dumps(result,indent=2)+'\n')
        started=time.monotonic()
        # No admitted source, binary build, positive rerun or executable run occurs here.
        native=subprocess.run(plan['command'],cwd=runner_root,capture_output=True,text=True)
        (out/'proof.stdout').write_text(native.stdout)
        (out/'proof.stderr').write_text(native.stderr)
        result.update(status='finished',exit_status=native.returncode,
                      finished_utc=datetime.now(timezone.utc).isoformat(),
                      elapsed_seconds=time.monotonic()-started,
                      source_hashes_after={'main.adb':digest(source),'probe.gpr':digest(project)})
        reports=submitted/'obj/explore/guard-negative'/batch_id/'gnatprove'
        if reports.exists():
            shutil.copytree(reports,out/'reports')
            try:
                result['inventory']=inventory(out/'reports')
            except (OSError,ValueError,TypeError) as error:
                result['inventory']={'error':str(error),'raw_records':[]}
        else:
            result['inventory']={'note':'No report directory; inspect complete frontend stdout/stderr.','raw_records':[]}
        result['diagnosis']=diagnosis(result['inventory']['raw_records'],case,native.returncode)
        result['submitted_source_unchanged']=result['source_hashes_before']==result['source_hashes_after']
        (out/'run.json').write_text(json.dumps(result,indent=2)+'\n')
        outcomes.append(result)
        (batch/'summary.json').write_text(json.dumps(outcomes,indent=2)+'\n')
        print(json.dumps(dict(case=case['name'],expected='native failure at one specified site',
                              observed_exit=native.returncode,
                              diagnostic_expectation_met=result['diagnosis']['diagnostic_expectation_met'])),flush=True)
    met=all(r['diagnosis']['diagnostic_expectation_met'] and r['submitted_source_unchanged'] for r in outcomes)
    (batch/'diagnostic-summary.json').write_text(json.dumps(dict(
        status='observed diagnostic expectations; not native proof success',
        all_six_expected_sites_exposed=met,cases=len(outcomes)),indent=2)+'\n')
    print(batch)
    print('Review full reports and exact source sites. Expected-fail controls remain native proof failures.')
    if not met:
        raise SystemExit(1)

if __name__=='__main__':
    main()
