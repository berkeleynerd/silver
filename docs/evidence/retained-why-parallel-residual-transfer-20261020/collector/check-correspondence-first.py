import json,tarfile,struct,collections,gzip
from pathlib import Path
CASE='first_or_default';NEW=Path('/tmp/silver-r53-20261020-a2')/CASE/'capture'
with tarfile.open('docs/evidence/retained-why-save-state-capture-20261020/capture-first-or-default.tar.gz') as t:
 prefix='registration/'+CASE+'/capture/'
 oldblocks={r['address']:r for r in map(json.loads,t.extractfile(prefix+'session-blocks.jsonl'))}
 oldchains=json.load(t.extractfile(prefix+'session-task-chains.json'))
 oldtables=json.load(t.extractfile(prefix+'session-tables.json'))
 oldbias=json.load(t.extractfile(prefix+'session-symbols.json'))['load_bias']
newblocks={r['address']:r for r in map(json.loads,(NEW/'session-blocks.jsonl').open())}
newchains=json.loads((NEW/'session-task-chains.json').read_text());newtables=json.loads((NEW/'session-tables.json').read_text());newbias=json.loads((NEW/'session-symbols.json').read_text())['load_bias']
def f(blocks,p):
 r=blocks[p];return struct.unpack('<'+'Q'*r['words'],bytes.fromhex(r['payload_hex']))
oldtasks={r['key']:r['value'] for r in oldtables['raw_tasks']['entries']};newtasks={r['key']:r['value'] for r in newtables['raw_tasks']['entries']}
assert oldtasks.keys()==newtasks.keys()
mapping={};reverse={};pending=[];declaration_pairs=set();events=collections.Counter()
for k in oldtasks:
 a=oldchains[str(oldtasks[k])];b=newchains[str(newtasks[k])];assert len(a)==len(b)
 for x,y in zip(a,b):
  an,at=f(oldblocks,x['tdecl']);bn,bt=f(newblocks,y['tdecl']);assert at==bt
  assert oldblocks[an]['tag']==newblocks[bn]['tag']
  if oldblocks[an]['tag']==0:
   ad,=f(oldblocks,an);bd,=f(newblocks,bn);pending.append((ad,bd));declaration_pairs.add((ad,bd))
while pending:
 a,b=pending.pop()
 if a&1 or b&1:assert a==b,('immediate',a,b);events['immediates']+=1;continue
 if a in mapping:assert mapping[a]==b,('sharing',a,b,mapping[a]);continue
 assert b not in reverse,('reverse-sharing',a,b,reverse.get(b))
 mapping[a]=b;reverse[b]=a
 x,y=oldblocks[a],newblocks[b]
 assert (x['tag'],x['words'])==(y['tag'],y['words']),('shape',a,b,x,y)
 events['blocks']+=1
 if x['tag']<246:pending.extend(zip(f(oldblocks,a),f(newblocks,b)))
 elif x['tag']==255:
  ax=f(oldblocks,a);bx=f(newblocks,b)
  assert ax[0]-oldbias==bx[0]-newbias and ax[1:]==bx[1:],('custom',a,b)
  events['custom_ops_load_bias_joins']+=1
 else:assert x['payload_hex']==y['payload_hex'],('opaque',a,b,x,y)
result=dict(case=CASE,raw_tasks=len(oldtasks),declaration_pairs=len(declaration_pairs),events=dict(events),old_load_bias=oldbias,new_load_bias=newbias,exact_tags_and_immediates_equal=True,sharing_bijection=True,custom_operations_join='same executable-relative address; remaining opaque words equal')
print(json.dumps(result,indent=2));Path('tmp/r53-correspondence-result.json').write_text(json.dumps(result,indent=2)+'\n');Path('tmp/r53-address-map.json.gz').write_bytes(gzip.compress(json.dumps(mapping,sort_keys=True).encode(),mtime=0))
