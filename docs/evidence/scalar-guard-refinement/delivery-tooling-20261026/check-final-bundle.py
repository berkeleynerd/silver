from pathlib import Path
from datetime import datetime, timezone
import ast, gzip, hashlib, json, re
ROOT=Path('/home/canto/src/github.com/berkeleynerd/silver')
CANON=ROOT/'tmp/scalar-guard-refinement'
B=CANON/'docs/evidence/scalar-guard-refinement/delivery-20261026'
T=CANON/'docs/evidence/scalar-guard-refinement/delivery-tooling-20261026'
REG=ROOT/'.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs'
OUT=ROOT/'tmp/guard-evidence-delivery-review-20261026'
sha=lambda x: hashlib.sha256(x).hexdigest()
def raw(item): return gzip.decompress((B/item['path']).read_bytes())
def obj(item): return json.loads(raw(item))
def one(rows,event):
 vals=[r for r in rows if r['event']==event]; assert len(vals)==1,(event,len(vals)); return vals[0]
validation_bytes=(B/'validation.json').read_bytes()
assert sha(validation_bytes)=='72f5d0f8094de0307ea5ac9b03b0ae6d8a83ba667e3f90b5cda527faf18f982c'
v=json.loads(validation_bytes); ix=json.loads((B/'artifact-index.json').read_bytes())
assert v['implementation_commit']=='d4d564cf358bd2c617b4899c53ceb0c0c1fd69da'
for name,item in ix.items():
 assert item['path']==name
 packed=(B/name).read_bytes(); unpacked=gzip.decompress(packed)
 assert sha(packed)==item['compressed_sha256'] and sha(unpacked)==item['sha256'] and len(unpacked)==item['bytes'],name
refs=[]
def walk(value):
 if isinstance(value,dict):
  if {'path','sha256','compressed_sha256','bytes'}<=value.keys(): assert ix[value['path']]==value; refs.append(value['path'])
  for child in value.values(): walk(child)
 elif isinstance(value,list):
  for child in value: walk(child)
walk(v)
assert set(refs)==set(ix),(set(ix)-set(refs),set(refs)-set(ix))
summary={}
checkpoints=[('native_full',v['native_full']),('native_build',v['native_build']),('lean',v['lean'])]
checkpoints.extend(v['full_suite_checkpoint']['successful_final_input_repair_tests'].items())
for label,item in checkpoints:
 rid=item['run_id']; d=REG/rid
 assert raw(item['events'])==(d/'events.jsonl').read_bytes(),label
 rows=[json.loads(line) for line in raw(item['events']).splitlines()]; start=one(rows,'started'); finish=one(rows,'finished')
 assert item['outcome']==finish['outcome']=='success' and finish['returncode'] in (None,0) and not finish['failure_keys']
 assert item['duration_seconds']==finish['duration_seconds'] and item['started_utc']==start['utc'] and item['finished_utc']==finish['utc']
 assert item['invocation_command']==start['command'] and len(start['command'])>0
 lean=label=='lean'; capture=start['inputs'] if lean else one(rows,'prepared')['inputs']
 assert obj(item['captured_inputs'])==capture
 commands=[r['command'] for r in rows if r['event']==('phase_started' if lean else 'command')]
 assert commands==item['commands'] and commands and all(commands)
 assert raw(item['log'])==(d/('lean-proof.log' if lean else 'native.log')).read_bytes()
 inventory=obj(item['tracked_input_comparison']['target_inputs'])
 assert len(inventory)==item['tracked_input_comparison']['expected']==item['tracked_input_comparison']['matched']
 for name,digest in inventory.items(): assert sha((CANON/name).read_bytes())==digest,(label,name)
 work=Path(item['worktree']); sources=capture['sources' if lean else 'inputs_sha256']
 normalized={}
 for name,digest in sources.items():
  p=Path(name); p=p if p.is_absolute() else work/p
  assert sha(p.read_bytes())==digest,(label,str(p))
  if p.is_relative_to(work): normalized[str(p.relative_to(work))]=digest
 assert all(normalized[name]==digest for name,digest in inventory.items())
 summary[label]={'run_id':rid,'outcome':'success','managed_seconds':finish['duration_seconds'],'captured_inputs':len(sources),'tracked_matches':len(inventory),'actual_commands':len(commands)}
 if lean:
  result=obj(item['result']); assert raw(item['result'])==(d/'lean-evidence.json').read_bytes()
  assert result['scope']=='complete' and result['axiom_audit']=='passed' and result['kernel_recheck'] is None
  assert result['inputs_digest_sha256']==sha(json.dumps(sources,sort_keys=True).encode())
  assert result['modules']==item['modules'] and len(result['modules'])==497
  phases=[{key:r[key] for key in ['phase','started_at','finished_at','elapsed_seconds','exit_code']} for r in rows if r['event']=='phase_finished']
  assert phases==result['phases'] and [p['phase'] for p in phases]==['build','audit'] and all(p['exit_code']==0 for p in phases)
  log=raw(item['log']); transcript=log[item['fresh_audit']['transcript_log_byte_offset']:]
  assert sha(transcript)==item['fresh_audit']['transcript_sha256']
  audit='Silver axiom audit passed: 104238 declarations; foundations: [propext, Classical.choice, Quot.sound]'
  assert transcript.decode().count(audit)==1 and item['fresh_audit']['output']==audit
  assert sorted(re.findall(r'(?m)^SILVER_MODULE (.+)$',transcript.decode()))==result['modules']
  expected_modules=sorted('.'.join(p.relative_to(CANON/'proof').with_suffix('').parts) for p in (CANON/'proof').rglob('*.lean') if '.lake' not in p.parts and p.name!='lakefile.lean')
  assert expected_modules==result['modules']
  summary[label].update(phases=phases,modules=497,declarations=104238,runner_elapsed_seconds=result['elapsed_seconds'])
# Retained full native provenance and all report bytes must match the selected run.
n=v['native_full']; native_dir=REG/n['run_id']/'proof-evidence'
for name,item in n['reports'].items(): assert raw(item)==(native_dir/name).read_bytes(),name
prov=obj(n['reports']['proof-provenance.json']); initial=obj(n['reports']['proof-inputs.json'])
assert prov['complete'] is True and prov['mode']=='full' and {k:prov[k] for k in initial}==initial
assert prov['inputs_sha256']==obj(n['captured_inputs'])['inputs_sha256'] and prov['tools']==obj(n['captured_inputs'])['tools']
assert set(prov['reports_sha256'])==set(n['reports'])-{'proof-provenance.json','proof-inputs.json'}
for name,digest in prov['reports_sha256'].items(): assert sha(raw(n['reports'][name]))==digest
assert v['fresh_check_evidence']==n['fresh_check_evidence'] and n['fresh_check_evidence']['exit_code']==0
assert n['fresh_check_evidence']['output'] in raw(n['log']).decode()
summary['native_report_inventory']=len(prov['reports_sha256'])
# Preserve failure and the single reviewed historical auditor difference.
f=v['full_suite_checkpoint']; baseline=f['baseline_failed_full_suite']
assert f['fresh_full_suite_success'] is False and baseline['outcome']=='failure' and baseline['returncode']==1 and baseline['errors']==1 and baseline['tests']==511
for key,filename in [('events','events.jsonl'),('log','native.log')]: assert raw(baseline[key])==(REG/baseline['run_id']/filename).read_bytes()
base_inputs=obj(baseline['input_comparison']['baseline_target_inputs']); assert len(base_inputs)==739
changes={name:(digest,sha((CANON/name).read_bytes())) for name,digest in base_inputs.items() if sha((CANON/name).read_bytes())!=digest}
assert set(changes)=={'scripts/check_evidence.py'}
assert changes['scripts/check_evidence.py']==('7d8bb865f97e419ec5c3b6466964151feb3cd5ba8233fd80ae521af4525f268e','1cfe226a5c86874b4cd574da5589f8b925599f009a8e784bd42242e9da2b0060')
assert sha(raw(f['reviewed_auditor_delta']['baseline_auditor']))==changes['scripts/check_evidence.py'][0]
assert raw(f['reviewed_auditor_delta']['final_auditor'])==(CANON/'scripts/check_evidence.py').read_bytes()
for label,count in [('image',5),('evidence',60)]: assert f['successful_final_input_repair_tests'][label]['tests']==count
renderer=baseline['renderer_inputs']; rec=obj(renderer['reconciled_snapshot']); prior=obj(renderer['original_snapshot'])
assert rec['suite_outcome']=='failure' and rec['exit_code']==prior['exit_code']==1
assert rec['original_capture']['sha256']==sha(raw(renderer['original_snapshot']))
assert rec['original_launch_log']['sha256']==sha(raw(renderer['original_launch_log']))
assert len(rec['ignored_nested_announcements'])==4 and rec['before']==rec['after']
for name,digest in rec['before'].items(): assert sha((CANON/name).read_bytes())==digest
log=raw(baseline['log']).decode()
for method in ['test_manifest_samples','test_native_complete_100_doors','test_native_guarded_updates_division_and_captured_bounds','test_checked_in_certificates_equal_regeneration']:
 assert re.search(r'(?m)^'+method+r' .* \.\.\. ok$',log),method
samples=json.loads((CANON/'samples/manifest.json').read_bytes())['samples']
assert len(samples)==48 and sum(1+len(row.get('argument_cases',[])) for row in samples)==104
summary['suite']={'baseline_run':baseline['run_id'],'outcome':'failure','tests':511,'errors':1,'tracked_baseline_inputs':739,'unchanged_final_matches':738,'historical_difference':changes,'focused_tests':[5,60],'manifest_samples':48,'execution_cases':104}
# The successful earlier source build is a companion, with an explicit old-auditor difference.
c=json.loads((B/'preserved-source/completion.json').read_bytes()); cr=REG/c['run_id']; companion=[]
for name,item in c['artifacts'].items():
 packed=(B/'preserved-source'/item['path']).read_bytes(); data=gzip.decompress(packed)
 assert sha(packed)==item['gzip_sha256'] and sha(data)==item['raw_sha256'] and len(data)==item['raw_bytes']
 assert data==(cr/name).read_bytes(); companion.append('preserved-source/'+item['path'])
rows=[json.loads(x) for x in (cr/'events.jsonl').read_bytes().splitlines()]; cs=one(rows,'started'); cf=one(rows,'finished'); ce=json.loads((cr/'lean-evidence.json').read_bytes())
assert c['outcome']==cf['outcome']=='success' and c['duration_seconds']==cf['duration_seconds'] and c['phases']==ce['phases']
assert c['command']==cs['command'] and c['modules']==len(ce['modules'])==497
csources=cs['inputs']['sources']; diffs={name:{'captured':digest,'final':sha((CANON/name).read_bytes())} for name,digest in csources.items() if sha((CANON/name).read_bytes())!=digest}
assert len(csources)==c['captured_sources']==612 and c['matched_final_sources']==611 and diffs==c['input_differences'] and set(diffs)=={'scripts/check_evidence.py'}
clog=(cr/'lean-proof.log').read_text()
for module,seconds in c['module_build_seconds'].items(): assert re.search(r'Silver\.'+module+r' \('+str(seconds)+r's\)',clog),(module,seconds)
summary['preserved_source']={'run_id':c['run_id'],'outcome':'success','input_matches':611,'captured_inputs':612,'difference':diffs,'phases':c['phases'],'module_seconds':c['module_build_seconds']}
actual={str(p.relative_to(B)) for p in B.rglob('*') if p.is_file()}
assert actual==set(ix)|{'artifact-index.json','validation.json','preserved-source/completion.json'}|set(companion)
# Retained delivery tooling remains byte-identical to reviewed scratch.
ti=json.loads((T/'index.json').read_bytes())
for name,item in ti['artifacts'].items():
 data=(T/name).read_bytes();assert sha(data)==item['sha256'] and len(data)==item['bytes'] and data==(ROOT/item['original_path']).read_bytes()
summary.update(checked_utc=datetime.now(timezone.utc).isoformat(),validation_sha256=sha(validation_bytes),artifact_index_sha256=sha((B/'artifact-index.json').read_bytes()),indexed_artifacts=len(ix),bundle_files=len(actual),bundle_bytes=sum((B/p).stat().st_size for p in actual),tooling_artifacts=len(ti['artifacts']),tooling_index_sha256=sha((T/'index.json').read_bytes()),checks='passed',validators_invoked=False)
(OUT/'final-bundle-checks.json').write_text(json.dumps(summary,indent=2)+'\n')
print(json.dumps(summary,indent=2))
