"""Replay Driver.update_task's typed metadata projection; no target execution.

The captured ordered driver AVL, task Patricia histories, and clone maps supply
all inputs. Types use their structural hashcons equivalence (including Alias).
The output retains original physical pointers plus the proven old-domain join.
"""
import argparse, collections, gzip, importlib.util, json, hashlib
from pathlib import Path
HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('r51model',HERE.parent/'retained-why-preinline-prefix-20261020/model.py');m=importlib.util.module_from_spec(spec);import sys;sys.modules[spec.name]=m;spec.loader.exec_module(m)
a=argparse.ArgumentParser();a.add_argument('capture',type=Path);a.add_argument('address_map',type=Path);a.add_argument('output',type=Path);args=a.parse_args()
r=m.Raw((args.capture/'session-blocks.jsonl').read_bytes());meta=json.loads((args.capture/'metadata.json').read_text())
reverse={v:int(k) for k,v in json.loads(gzip.decompress(args.address_map.read_bytes())).items()}
metas={int(k):v for k,v in meta['metas'].items()};tds={int(k):v for k,v in meta['tdecls'].items()};theories={int(k):v for k,v in meta['theories'].items()}
def ty(p):
 n,_=r.fields(p,2); tag=r.blocks[n]['tag']
 if tag==0:return ('var',r.fields(n,1)[0])
 ts,tl=r.fields(n,2,1);return ('app',ts,tuple(ty(x) for x in r.seq(tl)))
def inst(t,sub):
 if t[0]=='var':return sub.get(t[1],t)
 return app(t[1],tuple(inst(x,sub) for x in t[2]))
def app(ts,tl):
 _,vl,definition=r.fields(ts,3);vl=r.seq(vl);assert len(vl)==len(tl)
 if not definition&1 and r.blocks[definition]['tag']==0:return inst(ty(r.fields(definition,1)[0]),dict(zip(vl,tl)))
 return ('app',ts,tl)
def trans(t,smty,smts):
 if t[0]=='var':return t
 ts=t[1];tl=tuple(trans(x,smty,smts) for x in t[2])
 if ts in smts:return app(smts[ts],tl)
 if ts in smty:return inst(ty(smty[ts]),dict(zip(r.seq(r.fields(ts,3)[1]),tl)))
 return app(ts,tl)
class MissingLocalMap(Exception):
 pass
def marg(arg,clone=None):
 kind,p=arg['kind'],arg['value']
 if kind==0:value=ty(p)
 elif kind==4:value=r.string(p)
 elif kind==5:assert p&1;value=(p-(1<<64) if p>>63 else p)>>1
 else:value=p
 if clone:
  th,sm=clone;smty,smts,smls,smpr=map(dict,sm)
  if kind==0:value=trans(value,smty,smts)
  elif kind in (1,2,3):
   ident=r.fields(p,3 if kind==1 else 5 if kind==2 else 1)[0]
   if ident in th['local_identifiers']:
    lookup=(smts,smls,smpr)[kind-1]
    if p not in lookup:raise MissingLocalMap(p)
    value=lookup[p]
 return (kind,value)
def key(x):return json.dumps(x,separators=(',',':'))
# Every task of a process has the same raw meta/clone histories; verify exactly.
histories=list(meta['raw_task_histories'].values());history=histories[0];assert all(x==history for x in histories)
updated=collections.defaultdict(dict);events=[]
def add(td,clone,origin):
 item=tds[td];mp=item['meta'];descriptor=metas[mp]
 try:al=tuple(marg(arg,clone) for arg in item['arguments'])
 except MissingLocalMap as e:
  events.append(dict(origin=origin,td=td,meta=descriptor['name'],dropped_missing_local_symbol=e.args[0]));return
 if descriptor['exclusive']:updated[mp]={}
 updated[mp][key(al)]=al
 events.append(dict(origin=origin,td=td,meta=descriptor['name'],arguments=al))
for row in history['meta_rows']:
 for td in row['tdecls']:add(td,None,'raw')
clones={row['identifier']:row['tdecls'] for row in history['clone_rows']}
driver,=[d for d in meta['drivers'] if d.get('selected')];assert driver['drv_thuse']==1
for entry in driver['metadata']:
 th=theories[entry['theory']]
 for ctd in clones.get(entry['identifier'],[]):
  c=tds[ctd];assert c['kind'] in (1,2)
  clone=None if c['kind']==1 else (th,c['symbol_maps'])
  for td in entry['tdecls']:add(td,clone,dict(driver_theory=entry['theory'],clone_tdecl=ctd,kind=c['kind']))
rows={metas[mp]['name']:list(values.values()) for mp,values in updated.items()}
def tagged(name,kind):return {p for al in rows.get(name,[]) for k,p in al if k==kind}
def syminfo(p,kind):
 ident=r.fields(p,3 if kind==1 else 5 if kind==2 else 1)[0];name,attrs=r.ident(ident)
 return dict(pointer=p,old_pointer=reverse.get(p),identifier=ident,name=name,attrs=sorted(attrs))
selected={name:[syminfo(p,kind) for p in sorted(tagged(name,kind))] for name,kind in [('inline:no',2),('encoding:ignore_polymorphism_ts',1),('encoding:ignore_polymorphism_ls',2),('encoding:ignore_polymorphism_pr',3),('remove_prop',3),('introduced_prsymbol',3),('syntax_logic',2),('literal:keep',1)]}
# A sufficient all-raw-signatures certificate, stronger than needed after removal.
chains=json.loads((args.capture/'session-task-chains.json').read_text());decls={tds[x['tdecl']]['declaration'] for chain in chains.values() for x in chain if tds[x['tdecl']]['kind']==0}
poly=[];kinds=collections.Counter();ts_seen=set();ls_seen=set();prop_roots=[];inductive=[]
def check_ts(ts):
 if ts in ts_seen:return
 ts_seen.add(ts);_,vl,df=r.fields(ts,3)
 if r.seq(vl) and df==1:poly.append(dict(kind='type',**syminfo(ts,1),ignored=ts in tagged('encoding:ignore_polymorphism_ts',1)))
def check_ls(ls):
 if ls in ls_seen:return
 ls_seen.add(ls);r.symbol(ls);lsd=r.symbols[ls]
 tv=set().union(*(r.typevars(t) for t in lsd['arg_types']+(() if lsd['value_type'] is None else (lsd['value_type'],))))
 if tv:poly.append(dict(kind='logic',**syminfo(ls,2),type_variables=sorted(tv),ignored=ls in tagged('encoding:ignore_polymorphism_ls',2)))
for dp in sorted(decls):
 node,*_=r.fields(dp,3);tag=r.blocks[node]['tag'];kinds[tag]+=1;nf=r.fields(node,tag=tag)
 if tag==0:check_ts(nf[0])
 elif tag==1:
  for pair in r.seq(nf[0]):check_ts(r.fields(pair,2)[0])
 elif tag==2:check_ls(nf[0])
 elif tag==3:
  for pair in r.seq(nf[0]):check_ls(r.fields(pair,2)[0])
 elif tag==4:
  heads=[];clauses=[]
  for pair in r.seq(r.fields(nf[0],2)[1]):
   ls,cs=r.fields(pair,2);check_ls(ls);heads.append(ls)
   clauses.extend(r.fields(cp,2)[0] for cp in r.seq(cs))
  inductive.append(dict(declaration=dp,old_declaration=reverse.get(dp),heads=heads,old_heads=[reverse.get(x) for x in heads],clause_prsymbols=clauses,old_clause_prsymbols=[reverse.get(x) for x in clauses]))
 else:
  assert tag==5;pk,pr,term=r.fields(nf[0],3);prop_roots.append(dict(prsymbol=pr,old_prsymbol=reverse.get(pr),term=term,old_term=reverse.get(term),kind=pk>>1,prsymbol_attrs=syminfo(pr,3)['attrs']))
result=dict(input_sha256={n:hashlib.sha256((args.capture/n).read_bytes()).hexdigest() for n in ('session-blocks.jsonl','session-task-chains.json','metadata.json')},raw_tasks=len(histories),common_histories=True,driver_theories=len(driver['metadata']),transformations=driver['transformations'],updated_counts={k:len(v) for k,v in rows.items()},updated_metadata=rows,update_events=events,selected_symbols=selected,raw_declaration_kind_counts=dict(kinds),raw_signature_polymorphism=poly,all_raw_polymorphic_signatures_ignored=all(x['ignored'] for x in poly),raw_prop_roots=prop_roots,raw_inductive_declarations=inductive,raw_prop_typevar_claim='See joined R51 raw proposition closure certificate; no type variables',source_theorem_machine_checked=False)
args.output.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps({k:result[k] for k in ['raw_tasks','driver_theories','updated_counts','raw_declaration_kind_counts','raw_signature_polymorphism','all_raw_polymorphic_signatures_ignored']},indent=2))
