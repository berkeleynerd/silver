"""Replay all available attempt-2 metadata blocks to the first absent read.

This is a useful partial-input regression: it must reach an unavailable AVL
child, not misclassify the root as a Patricia leaf. No native process starts.
"""
import importlib.util,json,struct,tempfile,traceback
from pathlib import Path
from types import SimpleNamespace
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('reader',HERE/'metadata.py')
m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
ROOT=Path('/tmp/silver-r53-20261020-a2/first_or_default/capture')
class MissingRead(Exception):pass
class Store:
 def __init__(self):
  self.rows={r['address']:r for r in map(json.loads,(ROOT/'session-blocks.jsonl').open())}
 def raw(self,p):
  if p not in self.rows:raise MissingRead(p)
  r=dict(self.rows[p]);r['fields']=struct.unpack('<'+'Q'*r['words'],bytes.fromhex(r['payload_hex']));return r
 def block(self,p,tag=0,words=None):
  r=self.raw(p);assert r['tag']==tag and (words is None or r['words']==words),(p,r,tag,words);return r['fields']
 def values(self,p):
  seen=set()
  while p!=1:
   assert p not in seen;seen.add(p);x,p=self.block(p,words=2);yield x
 def table(self,p,int_keys=True):
  n,b,s,i=self.block(p,words=4);rows=[]
  for bucket,c in enumerate(self.block(b)):
   while c!=1:
    k,v,next=self.block(c,words=3);rows.append(dict(bucket=bucket,cell=c,key=k,value=v,next=next));c=next
  assert n>>1==len(rows);return dict(entries=rows),{}
s=SimpleNamespace(store=Store(),out=ROOT,roots=json.loads((ROOT/'session-root.json').read_text()))
p=m.Projection(s)
try:p.collect();raise AssertionError('partial input unexpectedly completed')
except MissingRead as e:
 result=dict(status='expected missing input after corrected source-layout traversal',missing_address=e.args[0],decoded_metas=len(p.metas),decoded_tdecls=len(p.tdecls),decoded_theories=len(p.theories),traceback=traceback.format_exc(),native_runs=0)
 assert result['decoded_metas']==9 and result['decoded_tdecls']==561
 print(json.dumps(result,indent=2))
 (HERE.parent/'partial-reader-replay.json').write_text(json.dumps(result,indent=2)+'\n')
