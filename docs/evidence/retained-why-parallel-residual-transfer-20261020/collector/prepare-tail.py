"""Continue only never-started domains on the host filesystem after /tmp filled."""
from pathlib import Path
import json,hashlib,copy,tarfile
CODE=Path(__file__).resolve().parent;HERE=CODE.parent
OLD=Path('/tmp/silver-r53-rest-20261020');ROOT=Path('/home/canto/src/github.com/berkeleynerd/silver/tmp/r53-meta-tail-20261020');ROOT.mkdir(exist_ok=False)
plan=json.loads((OLD/'plan.json').read_text())
def move(value):
 if isinstance(value,str):return value.replace(str(OLD),str(ROOT))
 if isinstance(value,list):return [move(x) for x in value]
 if isinstance(value,dict):return {move(k):move(v) for k,v in value.items()}
 return value
def identity(p):
 b=Path(p).read_bytes();return dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
plan=move(plan);plan['inputs']=[c for c in plan['inputs'] if c['name'] in ('put','is_message')]
plan['scope']='R53 never-started Put and Is_Message metadata projections after /tmp ENOSPC; exact inputs, J12, one serial managed worker, no solver/preparation/full Hsdecl; completed First/Input/Put_Line preserved'
plan['file_identities']={p:i for p,i in plan['file_identities'].items() if not p.startswith(str(ROOT)+'/')}
(ROOT/'overlay').mkdir()
for f in (OLD/'overlay').iterdir():(ROOT/'overlay'/f.name).write_bytes(f.read_bytes())
for c in plan['inputs']:
 cwd=Path(c['cwd']);cwd.mkdir();(cwd/'temp').mkdir()
 assert len(c['server']['socket'].encode())<108
 for n in [c['argv'][-1],'why3.conf']:(cwd/n).write_bytes((OLD/c['name']/n).read_bytes())
for f in ROOT.rglob('*'):
 if f.is_file():
  native_origin=str(f).replace(str(ROOT),'/home/canto/src/github.com/berkeleynerd/silver/tmp/wse-20261020')
  actual=identity(f);assert actual==plan['inherited_file_identities'][native_origin]
  plan['file_identities'][str(f)]=actual
for f in CODE.glob('*.py'):plan['file_identities'][str(f)]=identity(f)
resolution=move(json.loads((OLD/'driver-resolution.json').read_text()))
for name,value in [('plan.json',plan),('driver-resolution.json',resolution)]:
 (ROOT/name).write_text(json.dumps(value,indent=2)+'\n');(HERE/('tail-'+name)).write_bytes((ROOT/name).read_bytes())
print('Tail prepared',ROOT,'socket lengths',[len(c['server']['socket']) for c in plan['inputs']])
