from pathlib import Path
import json,hashlib,tarfile,gzip,shutil
root=Path('/home/canto/src/github.com/berkeleynerd/silver/tmp/wfs-20261020');repo=Path('/home/canto/src/github.com/berkeleynerd/silver/tmp/retained-tool-capacity');out=repo/'docs/evidence/retained-why-fixed-session-domain-20261020'
managed=Path('/home/canto/src/github.com/berkeleynerd/silver/.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs/20261020T071442-a3e5fa7cb995')
def ident(path):
 h=hashlib.sha256();size=0
 with path.open('rb') as f:
  for b in iter(lambda:f.read(1024*1024),b''):h.update(b);size+=len(b)
 return {'bytes':size,'sha256':h.hexdigest()}
def pack(name,files):
 path=out/name;members=[]
 with path.open('wb') as raw,gzip.GzipFile(filename='',mode='wb',fileobj=raw,mtime=0) as gz,tarfile.open(fileobj=gz,mode='w') as tar:
  for arcname,src in sorted(files):
   row=ident(src);info=tarfile.TarInfo(arcname);info.size=row['bytes'];info.mode=0o644;info.mtime=0
   with src.open('rb') as f:tar.addfile(info,f)
   members.append({'path':arcname,**row})
 record={'path':name,**ident(path),'members':members};print(name,record['bytes'],len(members),flush=True);return record
plan=json.loads((root/'plan.json').read_text());result=json.loads((root/'result.json').read_text());assert len(result['cases'])==4
assert all(c['completed'] and c['returncode']==0 and not c['failures'] and not c['guard_hits'] and not c['timed_out'] for c in result['cases'])
# Preserve precisely the executed files and their before/after identity contract.
for path,row in plan['file_identities'].items():assert ident(Path(path))==row,path
archives=[]
common=[(p.name,p) for p in root.iterdir() if p.is_file()]
common += [('overlay/'+p.name,p) for p in (root/'overlay').iterdir() if p.is_file()]
common += [('managed/'+name,managed/name) for name in ['events.jsonl','native.log']]
common += [('preparation/prepare-fixed-session-capture.py',Path('/tmp/prepare-fixed-session-capture.py'))]
archives.append(pack('capture-common.tar.gz',common))
for case in plan['inputs']:
 d=root/case['name'];files=[(str(p.relative_to(root)),p) for p in d.rglob('*') if p.is_file()]
 archives.append(pack('capture-'+case['name'].replace('_','-')+'.tar.gz',files))
manifest={'scope':'Four new registration-endpoint captures; complete Input_Is_Valid PID97103 evidence reused separately','managed_run':'20261020T071442-a3e5fa7cb995','native_process_cases':4,'workers':1,'archives':archives,'retained_Input_Is_Valid':plan['retained_Input_Is_Valid'],'capture_result':result,'limitations':['The inherited runner final message says all five; this selected plan actually executed only the four listed cases.','Read-only debugger observations plus inspected source/runtime premises, not proof or solver success.','Diagnostic dump/time/heap limits are not admission thresholds.','Session replay and per-process numeric attachment are separate evidence.']}
(out/'capture-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print('Packaged completed capture; no target rerun.')
