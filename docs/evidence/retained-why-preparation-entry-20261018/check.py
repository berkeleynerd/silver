"""Offline replay, actual metadata checks and corruption/omission checks."""
from pathlib import Path
import copy,json,tarfile,tempfile,shutil,subprocess,sys
import compose
from decode import decode
HERE=Path(__file__).resolve().parent
result,dimensions,batches=compose.compose()
assert result==json.loads((HERE/'result.json').read_text())
assert dimensions==json.loads((HERE/'dimensions.json').read_text())
assert batches==json.loads((HERE/'batches.json').read_text())
with tarfile.open(HERE/'capture.tar.gz') as t:
 graph=json.loads(t.extractfile('capture/inline-entry-graph.json').read())
def rejected(g):
 try:decode(g)
 except (AssertionError,KeyError,RecursionError):return
 raise AssertionError('malformed graph accepted')
g=copy.deepcopy(graph);p=next(iter(g['blocks']));g['blocks'][p]['header']^=1024;rejected(g)
g=copy.deepcopy(graph);g['blocks'].pop(str(g['roots'][0]));rejected(g)
bi=next(x for x in dimensions['stored']['bind_infos'] if x['substitution_entries'])
g=copy.deepcopy(graph);g['blocks'].pop(str(bi['substitution_values'][0]));rejected(g)
bi=next(x for x in dimensions['stored']['bind_infos'] if x['free_count_entries'])
g=copy.deepcopy(graph);mp=g['blocks'][str(bi['address'])]['fields'][0]
g['blocks'][str(mp)]['fields'][2]+=2;rejected(g)
# Omitting real trigger occurrences must change the result or violate checked
# binder counts. Find an actual quantifier payload; do not invent test syntax.
changed=False
for ptr,row in graph['blocks'].items():
 if row['tag']==7 and row['words']==2:
  qptr=row['fields'][1];q=graph['blocks'].get(str(qptr))
  if q and q['tag']==0 and q['words']==4 and q['fields'][2]!=1:
   g=copy.deepcopy(graph);g['blocks'][str(qptr)]['fields'][2]=1
   try:changed=decode(g)!=dimensions
   except (AssertionError,KeyError):changed=True
   if changed:break
assert changed,'no exercised trigger omission'
# Whole-packet identity rejects changes even outside the particular decoded
# root projection (e.g. unused stored values or captured native provenance).
with tempfile.TemporaryDirectory() as tmp:
 target=Path(tmp)
 shutil.copy2(HERE/'capture.tar.gz',target/'capture.tar.gz')
 p=target/'capture.tar.gz';b=bytearray(p.read_bytes());b[-10]^=1;p.write_bytes(b)
 old=compose.HERE;compose.HERE=target
 try:
  try:compose.read_archive('capture',json.loads((HERE/'inputs.json').read_text())['capture'])
  except AssertionError:pass
  else:raise AssertionError('corrupt archive accepted')
 finally:compose.HERE=old
p=subprocess.run([sys.executable,'-B',str(HERE/'compose.py')],capture_output=True,text=True,check=True)
assert json.loads(p.stdout)==result
print('PASS: one-pair replay; 157 binder payload checks; malformed graph/count/substitution/trigger/archive checks; portable CLI')
