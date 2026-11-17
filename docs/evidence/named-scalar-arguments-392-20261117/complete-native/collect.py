from pathlib import Path
import hashlib,json,gzip,shutil,subprocess,sys,tarfile,socket
from datetime import datetime,timezone
root=Path.cwd()
sys.path.insert(0,str(root/'scripts'))
from platforms import native_layout
from proof_provenance import validate_provenance,input_hashes,digest
from check_evidence import audit_sources
host=native_layout(root)
reports=host.compiler/'obj/gnatprove'
run_id='20261117T034048-8c22c1e6a33d'
registry=Path('/Volumes/EXTERNAL/Users/rebecca/src/github.com/berkeleynerd/silver/.git/silver-runs/linux-aarch64/e513549bff0f5897/runs')
run=registry/run_id
evidence=root/'docs/evidence/named-scalar-arguments-392-20261117/complete-native'
evidence.mkdir(parents=True,exist_ok=True)
manifest=validate_provenance(host,reports)
assert manifest['inputs_sha256']==input_hashes(host)
inputs=json.loads((reports/'proof-inputs.json').read_text())
assert {k:manifest[k] for k in inputs}==inputs
stats=audit_sources(root/'src',reports,host.generated,effective_command=manifest['command'])
head=subprocess.check_output(['git','rev-parse','HEAD'],text=True).strip()
assert head=='f4ed7cd513047df7c8a24c04b3fd107ee704db1c',head
tracked={}
for name,sha in manifest['inputs_sha256'].items():
 if name.startswith(('src/','scripts/')) or name in ('silver.gpr','alire.toml','proof/silver_proof_containers.gpr'):
  blob=subprocess.check_output(['git','show',f'{head}:{name}'])
  actual=hashlib.sha256(blob).hexdigest()
  assert actual==sha,(name,actual,sha)
  tracked[name]=sha
(evidence/'tracked-inputs-at-commit.json').write_text(json.dumps({'commit':head,'sha256':tracked},indent=2)+'\n')
for name in ('proof-inputs.json','proof-provenance.json'):
 shutil.copy2(reports/name,evidence/name)
shutil.copy2(root/'tmp/final-native-392/initial-state.json',evidence/'initial-state.json')
report_names=sorted(manifest['reports_sha256'])
with tarfile.open(evidence/'native-reports.tar.gz','w:gz') as t:
 for name in report_names:t.add(reports/name,arcname=name,recursive=False)
with tarfile.open(evidence/'native-reports.tar.gz','r:gz') as t:
 assert sorted(t.getnames())==report_names
 for name,sha in manifest['reports_sha256'].items():
  assert hashlib.sha256(t.extractfile(name).read()).hexdigest()==sha,name
for name in ('monitoring.jsonl','progress.jsonl'):
 source=root/'tmp/final-native-392'/name
 if source.exists():
  with source.open('rb') as src,gzip.open(evidence/f'{name}.gz','wb') as dest:shutil.copyfileobj(src,dest)
for name in ('events.jsonl','native.log'):
 with (run/name).open('rb') as src,gzip.open(evidence/f'prove-{name}.gz','wb') as dest:shutil.copyfileobj(src,dest)
events=[json.loads(x) for x in (run/'events.jsonl').read_text().splitlines()]
(evidence/'audit-verification.json').write_text(json.dumps({'verified_utc':datetime.now(timezone.utc).isoformat(),'host':host.key,'machine':socket.gethostname(),'worktree':str(root),'commit':head,'managed_run':run_id,'stats':stats,'input_hashes_verified':len(manifest['inputs_sha256']),'tool_identities_verified':len(manifest['tools']),'report_hashes_verified':len(manifest['reports_sha256']),'tracked_inputs_match_commit':len(tracked),'manifest_matches_proof_inputs':True,'archive_content_hashes_verified':True,'initial_state':manifest['initial_state'],'events_terminal':[{k:e.get(k) for k in ('event','phase','state','returncode','utc','error')} for e in events[-5:]]},indent=2)+'\n')
print(json.dumps({'evidence':str(evidence),'stats':stats,'inputs':len(manifest['inputs_sha256']),'tools':len(manifest['tools']),'reports':len(report_names),'tracked_inputs':len(tracked)},indent=2))
