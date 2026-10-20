"""Retain completed new domains and interrupted-batch evidence without reruns."""
import hashlib,json,tarfile
from pathlib import Path
HERE=Path(__file__).resolve().parent.parent;CODE=HERE/'collector'
roots=[Path('/tmp/silver-r53-rest-20261020'),Path('/home/canto/src/github.com/berkeleynerd/silver/tmp/r53-meta-tail-20261020')]
def identity(b):return dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
archives=[];post={}
for root,names in zip(roots,[['input_is_valid','put_line'],['put','is_message']]):
 plan=json.loads((root/'plan.json').read_text())
 post[str(root)]={p:dict(expected=i,actual=identity(Path(p).read_bytes())) for p,i in plan['file_identities'].items()}
 assert all(x['expected']==x['actual'] for x in post[str(root)].values())
 for case in names:
  dest=HERE/(case.replace('_','-')+'-capture.tar.gz');archives.append(dest)
  with tarfile.open(dest,'w:gz') as t:
   for p in sorted((root/case).rglob('*')):
    if p.is_file():t.add(p,arcname=str(p.relative_to(root)))
   for p in [root/'plan.json',root/'driver-resolution.json',root/'result.json']:
    t.add(p,arcname=p.name)
   for p in sorted((root/'overlay').glob('*')):
    if p.is_file():t.add(p,arcname=str(p.relative_to(root)))
   for p in sorted(CODE.glob('*.py')):
    if str(p) in plan['file_identities']:t.add(p,arcname='collector/'+p.name)
(HERE/'remaining-post-identities.json').write_text(json.dumps(post,indent=2)+'\n')
registry=Path('/home/canto/src/github.com/berkeleynerd/silver/.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs')
dest=HERE/'remaining-managed.tar.gz';archives.append(dest)
with tarfile.open(dest,'w:gz') as t:
 for run in ['20261020T212620-bf50915cba85','20261020T212742-ef4313af368d']:
  for p in sorted((registry/run).rglob('*')):
   if p.is_file():t.add(p,arcname=str(p.relative_to(registry)))
manifest={}
for p in archives:
 with tarfile.open(p) as t:
  members={m.name:identity(t.extractfile(m).read()) for m in t.getmembers() if m.isfile()}
 manifest[p.name]=dict(identity=identity(p.read_bytes()),members=members)
(HERE/'remaining-manifest.json').write_text(json.dumps(manifest,indent=2)+'\n')
print(json.dumps({p.name:manifest[p.name]['identity'] for p in archives},indent=2))
