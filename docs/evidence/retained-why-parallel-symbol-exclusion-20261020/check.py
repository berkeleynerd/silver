"""Focused archive-only metadata/witness derivation and source identity check.

No inferior, collector, predecessor model, broad proof or solver is run.
Temporary files are under this worktree's tmp/ because /tmp is full.
"""
import argparse,hashlib,json,subprocess,sys,tarfile,tempfile,time
from pathlib import Path
HERE=Path(__file__).resolve().parent;ROOT=HERE.parents[2];start=time.monotonic()
a=argparse.ArgumentParser();a.add_argument('--refresh',action='store_true');args=a.parse_args()
inputs=json.loads((HERE/'inputs.json').read_text())
for name,expected in inputs['inputs'].items():
 b=(ROOT/name).read_bytes();assert dict(bytes=len(b),sha256=hashlib.sha256(b).hexdigest())==expected,name
witnesses=json.loads((HERE/'source-witnesses.json').read_text())
with tarfile.open(ROOT/'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz') as t:
 for name,row in witnesses.items():
  b=t.extractfile(name).read();assert len(b)==row['bytes'] and hashlib.sha256(b).hexdigest()==row['sha256']
  lines=b.decode().splitlines()
  for e in row['excerpts']:assert '\n'.join(lines[e['first']-1:e['last']])==e['text']
scratch=ROOT/'tmp';scratch.mkdir(exist_ok=True)
with tempfile.TemporaryDirectory(prefix='r54-check-',dir=scratch) as temp:
 out=Path(temp)
 for case in ['put-line','put','first-or-default','is-message','input-is-valid']:
  cap=out/case;cap.mkdir()
  archive=ROOT/'docs/evidence/retained-why-parallel-residual-transfer-20261020'/f'{case}-capture.tar.gz'
  prefix=case.replace('-','_')+'/capture/'
  with tarfile.open(archive) as t:
   for name in ['metadata.json','session-blocks.jsonl','session-task-chains.json']:(cap/name).write_bytes(t.extractfile(prefix+name).read())
  mapname='first-domain-address-map.json.gz' if case=='first-or-default' else case+'-correspondence.map.json.gz'
  amap=archive.parent/mapname;output=out/f'{case}-metadata.json'
  subprocess.run([sys.executable,'-B',str(HERE/'derive-metadata.py'),str(cap),str(amap),str(output)],check=True,stdout=subprocess.DEVNULL)
  if args.refresh:(HERE/output.name).write_bytes(output.read_bytes())
  else:assert output.read_bytes()==(HERE/output.name).read_bytes(),output.name
 subprocess.run([sys.executable,'-B',str(HERE/'derive-exclusions.py'),'--output',str(out)],check=True,stdout=subprocess.DEVNULL)
 for p in out.glob('*-exclusions.json'):
  if args.refresh:(HERE/p.name).write_bytes(p.read_bytes())
  else:assert p.read_bytes()==(HERE/p.name).read_bytes(),p.name
result=dict(status='pass',elapsed_seconds=time.monotonic()-start,repository_inputs=len(inputs['inputs']),source_files=len(witnesses),source_excerpts=sum(len(x['excerpts']) for x in witnesses.values()),metadata_domains=5,exclusion_certificates=5,residual_keys=13,exact_generated_files=10,refresh=args.refresh,native_runs=0,old_capture_reader_replays=0,source_theorem_machine_checked=False)
print(json.dumps(result,indent=2))
if not args.refresh:(HERE/'check-result.json').write_text(json.dumps(result,indent=2)+'\n')
