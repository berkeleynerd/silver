"""Create isolated exact-input workspaces for the four still-missing domains."""
import copy,hashlib,json,tarfile
from pathlib import Path
CODE=Path(__file__).resolve().parent;HERE=CODE.parent;REPO=HERE.parents[2]
ROOT=Path('/tmp/silver-r53-rest-20261020');ROOT.mkdir(exist_ok=False)
CAP=REPO/'docs/evidence/retained-why-save-state-capture-20261020'
def identity(p):
 b=Path(p).read_bytes();return dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest())
with tarfile.open(CAP/'capture-common.tar.gz') as t:
 old=json.load(t.extractfile('registration/plan.json'));inline=json.load(t.extractfile('inline/plan.json'))
 resolution=json.load(t.extractfile('registration/driver-resolution.json'))
 original='/home/canto/src/github.com/berkeleynerd/silver/tmp/wse-20261020'
 (ROOT/'overlay').mkdir()
 for member in t.getnames():
  if member.startswith('registration/overlay/'):(ROOT/'overlay'/Path(member).name).write_bytes(t.extractfile(member).read())
origins={**old['file_identities'],**inline['file_identities']}
assert all(identity(p)==expected for p,expected in origins.items())
def replace(value,origin):
 if isinstance(value,str):return value.replace(origin,str(ROOT))
 if isinstance(value,list):return [replace(x,origin) for x in value]
 if isinstance(value,dict):return {replace(k,origin):replace(v,origin) for k,v in value.items()}
 return value
cases=[];relocated=[]
for name in ['input_is_valid','put_line','put','is_message']:
 source=inline if name=='input_is_valid' else old
 group='inline' if name=='input_is_valid' else 'registration'
 case=copy.deepcopy(next(c for c in source['inputs'] if c['name']==name));origin=str(Path(case['cwd']).parent)
 case=replace(case,origin);case['argv'][1:1]=['-j','12'];case['server']['argv'][-1]='12'
 cwd=Path(case['cwd']);cwd.mkdir();(cwd/'temp').mkdir()
 with tarfile.open(CAP/('capture-'+name.replace('_','-')+'.tar.gz')) as t:
  for file in [case['argv'][-1],'why3.conf']:
   (cwd/file).write_bytes(t.extractfile(group+'/'+name+'/'+file).read())
   expected=source['file_identities'][origin+'/'+name+'/'+file]
   assert identity(cwd/file)==expected
   relocated.append(dict(path=str(cwd/file),origin=origin+'/'+name+'/'+file,identity=expected))
 cases.append(case)
plan=copy.deepcopy(old);plan['inputs']=cases;plan['collector_root']=str(CODE)
plan['scope']='Four remaining missing physical-domain metadata projections, actual J12 registration, sequential one managed worker, zero solvers/preparation, no full Hsdecl'
plan['inherited_file_identities']=origins
plan['file_identities']={p:expected for p,expected in old['file_identities'].items() if not p.startswith(original+'/')}
for f in (ROOT/'overlay').iterdir():
 expected=old['file_identities'][original+'/overlay/'+f.name];assert identity(f)==expected
 plan['file_identities'][str(f)]=expected
 relocated.append(dict(path=str(f),origin=original+'/overlay/'+f.name,identity=expected))
for row in relocated:plan['file_identities'][row['path']]=row['identity']
for f in CODE.glob('*.py'):plan['file_identities'][str(f)]=identity(f)
plan['required_overlay_paths']=replace(old['required_overlay_paths'],original)
plan['selected_driver_closure']=replace(old['selected_driver_closure'],original)
plan['arithmetic_sites']={};plan['full_Hsdecl_capture']=False
plan['intentional_argv_delta_from_retained_serial']=['client -j 12','server -j 12','isolated writable paths','Input_Is_Valid stop is registration, with raw immutable tasks joined to old later inline cut']
resolution=replace(resolution,original)
for name,value in [('plan.json',plan),('driver-resolution.json',resolution),('relocation-check.json',dict(all_preserved=True,checked_original_identities=len(origins),relocated=relocated))]:
 (ROOT/name).write_text(json.dumps(value,indent=2)+'\n')
 (HERE/('remaining-'+name)).write_bytes((ROOT/name).read_bytes())
print('Four isolated domains prepared; original identity checks',len(origins),'; relocated exact files',len(relocated))
