from pathlib import Path
from datetime import datetime,timezone
import gzip,hashlib,json,shutil,subprocess,sys
root=Path.cwd();sys.path.insert(0,str(root/'scripts'))
from platforms import native_layout
from proof_provenance import validate_provenance,digest
host=native_layout(root);evidence=root/'docs/evidence/named-scalar-arguments-392-20261117/complete-native'
registry=Path('/Volumes/EXTERNAL/Users/rebecca/src/github.com/berkeleynerd/silver/.git/silver-runs/linux-aarch64/e513549bff0f5897/runs')
prove='20261117T034048-8c22c1e6a33d';build='20261117T055412-08a00820e2ef';run=registry/build
manifest=validate_provenance(host,host.compiler/'obj/gnatprove')
summary=json.loads(subprocess.check_output(['python3','scripts/dev.py','runs','status']))
runs=[r for r in summary['runs'] if r['run_id'] in (prove,build)]
assert len(runs)==2 and all(r['state']=='success' and not r['active'] for r in runs)
build_events=[json.loads(x) for x in (run/'events.jsonl').read_text().splitlines()]
prepared=next(x['inputs'] for x in build_events if x['event']=='prepared')
assert prepared['inputs_sha256']==manifest['inputs_sha256']
assert prepared['tools']==manifest['tools']
for name in ('events.jsonl','native.log'):
 with (run/name).open('rb') as src,gzip.open(evidence/f'build-{name}.gz','wb') as dst:shutil.copyfileobj(src,dst)
(evidence/'managed-runs.json').write_text(json.dumps(runs,indent=2)+'\n')
(evidence/'original-terminal-exits.json').write_text(json.dumps({'prove':{'session_id':87037,'exit_code':0,'source':'Lead collected original exec session and reported exit 0 to collector at 2026-11-17 05:53:49 UTC; the session is lead-local.','reported_stdout_summary':'Success: all checks proved (19726); Complete GNATprove evidence: 78 units, 1252 entities, 1751 flow_checks, 17975 proof_checks.'},'build':{'session_id':53113,'exit_code':0,'source':'Collector directly resumed original exec session with write_stdin and observed exit_code 0.','stdout_after_managed_run':'gprbuild: "silver" up to date\ngprbuild: "silver_image_adapter" up to date\n'}},indent=2)+'\n')
verification=json.loads((evidence/'audit-verification.json').read_text())
verification['post_build_verification']={'verified_utc':datetime.now(timezone.utc).isoformat(),'native_manifest_still_valid':True,'build_input_hashes_match_proof':True,'build_tool_identities_match_proof':True,'build_workers_actual':next(r['workers'] for r in runs if r['run_id']==build),'binary_sha256':{x.name:digest(x) for x in (host.compiler/'bin/silver',host.compiler/'bin/silver_image_adapter')}}
(evidence/'audit-verification.json').write_text(json.dumps(verification,indent=2)+'\n')
for name in ('collect.py','finalize.py','monitor.py','progress.py'):
 shutil.copy2(root/'tmp/final-native-392'/name,evidence/name)
checksums={p.name:digest(p) for p in sorted(evidence.iterdir()) if p.is_file() and p.name!='SHA256SUMS.json'}
(evidence/'SHA256SUMS.json').write_text(json.dumps(checksums,indent=2)+'\n')
print(json.dumps({'evidence':str(evidence),'build_workers':verification['post_build_verification']['build_workers_actual'],'files':len(checksums),'total_bytes':sum(p.stat().st_size for p in evidence.iterdir() if p.is_file()),'post_build_manifest_valid':True},indent=2))
