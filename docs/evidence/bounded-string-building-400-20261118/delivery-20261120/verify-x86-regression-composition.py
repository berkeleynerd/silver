#!/usr/bin/env python3
from pathlib import Path
import json,hashlib,re,subprocess
H=Path(__file__).resolve().parent;root=H.parents[1];pr='001c50dce1bcf3ad2d174b4426f684fe78cb2e64';work=root/'tmp/pr403-validation-runs/build-001c50dce1/checkout'
assert subprocess.check_output(['git','rev-parse','HEAD'],cwd=work).decode().strip()==pr
run=next((work/'.git/silver-runs').glob('**/runs/20261120T125015-03ea0dfd16e0'))
events=[json.loads(x) for x in (run/'events.jsonl').read_text().splitlines()];get=lambda e:next(x for x in events if x['event']==e)
inv=get('prepared')['inputs']['inputs_sha256'];historical=json.loads((H/'recovered-regression-verification.json').read_text());repo={x['path']:x['sha256'] for x in historical['repository_inputs']};n=0;additional=[]
for name,expected in inv.items():
 p=Path(name);actual=hashlib.sha256(p.read_bytes()).hexdigest();assert actual==expected,name
 if p.is_relative_to(work) and '.silver' not in p.relative_to(work).parts:
  relative=p.relative_to(work).as_posix();assert repo[relative]==expected,relative;n+=1
 else:additional.append(name)
assert n==1340 and len(additional)==8
log=(run/'native.log').read_text();ids=re.findall(r'^test_\w+ \(([\w.]+)\) \.\.\. ok$',log,re.M);old=historical['runs']['20261118T173931-305d1781f71e']['tests'];skips={x['id'] for x in old if x['status']=='skipped'};assert set(ids)==skips and len(ids)==2
assert log.rstrip().endswith('Ran 2 tests in 3.816s\n\nOK');assert get('finished')['outcome']=='success';assert [e['returncode'] for e in events if e['event']=='phase-end' and e.get('phase')=='test']==[0]
launcher=json.loads((H/'x86-skipped-tests/launcher.json').read_text());assert launcher['returncode']==0
out={'reviewed_pr':pr,'run_id':'20261120T125015-03ea0dfd16e0','managed_directory':str(run),'repository_hashes_match_pr_and_retained_arm':n,'additional_current_inputs_matching':len(additional),'passed_ids':ids,'retained_arm_passes':722,'fresh_x86_passes':2,'total_inventory_covered':724,'invoking_stack_soft_bytes':launcher['stack_soft_bytes'],'invoking_stack_hard_bytes':launcher['stack_hard_bytes'],'start':get('started')['utc'],'finish':get('finished')['utc'],'managed_duration_seconds':get('finished')['duration_seconds'],'test_duration_seconds':3.816,'available_cpus':get('started')['available_cpus'],'workers':get('started')['workers'],'phase_returncode':0,'final_outcome':'success','final_returncode':get('finished')['returncode'],'launcher_returncode':0,'log_sha256':hashlib.sha256(log.encode()).hexdigest()}
(H/'x86-regression-composition.json').write_text(json.dumps(out,indent=2)+'\n');print(json.dumps(out,indent=2))
