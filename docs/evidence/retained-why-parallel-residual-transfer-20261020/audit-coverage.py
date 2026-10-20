import bisect,json,struct,tarfile,time
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
CASES=('put_line','put','first_or_default','is_message','input_is_valid')
results=[]
for case in CASES:
 arc=ROOT/'docs/evidence/retained-why-save-state-capture-20261020'/('capture-'+case.replace('_','-')+'.tar.gz')
 prefix=('inline/' if case=='input_is_valid' else 'registration/')+case+'/capture/'
 with tarfile.open(arc) as t:
  blocks={r['address']:r for r in map(json.loads,t.extractfile(prefix+'session-blocks.jsonl'))}
  chains=json.load(t.extractfile(prefix+'session-task-chains.json'))
  def fields(p): return struct.unpack('<'+'Q'*blocks[p]['words'],bytes.fromhex(blocks[p]['payload_hex']))
  tdecls=sorted({r['tdecl'] for c in chains.values() for r in c})
  meta=[]; use=[]
  for td in tdecls:
   n=fields(td)[0]; tag=blocks[n]['tag']
   if tag==3:
    m,args=fields(n); meta.append(dict(tdecl=td,node=n,meta=m,args=args,meta_block_retained=m in blocks,args_block_retained=args in blocks))
   elif tag==1: use.append(fields(n)[0])
  targets=sorted({p for r in meta for p in (r['meta'],r['args']) if not p&1}|set(use))
  covered={p:[] for p in targets}; logrows=0
  for name in t.getnames():
   if not name.startswith(prefix) or not name.endswith('memory-reads.jsonl'):continue
   for idx,line in enumerate(t.extractfile(name),1):
    r=json.loads(line); logrows+=1; lo=r['address']; hi=lo+r['bytes']
    for p in targets[bisect.bisect_right(targets,lo-40):bisect.bisect_left(targets,hi+8)]:
     if lo < p+40 and p-8 < hi:covered[p].append(dict(member=name,line=idx,**r))
  out=dict(case=case,raw_task_chains=len(chains),unique_tdecls=len(tdecls),meta_tdecls=len(meta),unique_meta_record_pointers=len({r['meta'] for r in meta}),meta_records_present_in_session_blocks=sum(r['meta_block_retained'] for r in meta),args_lists_present_in_session_blocks=sum(r['args_block_retained'] for r in meta),memory_read_rows=logrows,covered_targets={p:v for p,v in covered.items() if v},meta_nodes=meta,use_theory_pointers=sorted(set(use)))
  print(case,{k:v for k,v in out.items() if k not in ('meta_nodes','use_theory_pointers','covered_targets')},'covered',len(out['covered_targets']),flush=True)
  results.append(out)
out=json.dumps(results,indent=2)+'\n'
if '--write' in __import__('sys').argv: (HERE/'metadata-coverage.json').write_text(out)
else: assert (HERE/'metadata-coverage.json').read_text()==out
print('Metadata byte-coverage audit passed; no native execution or predecessor replay.')
