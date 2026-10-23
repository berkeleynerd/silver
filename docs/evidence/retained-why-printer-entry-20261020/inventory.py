"""New syntax projection only. Never invokes a preceding checker or transform."""
from pathlib import Path
from collections import Counter
import gzip, importlib.util, json, sys
HERE=Path(__file__).resolve().parent
REPO=HERE.parents[2]; EVIDENCE=HERE.parent
R51=EVIDENCE/'retained-why-preinline-prefix-20261020'
R56=EVIDENCE/'retained-why-fixed-inline-family-20261020'
R57=EVIDENCE/'retained-why-returned-storage-20261020'
R58=EVIDENCE/'retained-why-postinline-preparation-20261020'
CASES=['put-line','put','first-or-default','is-message','input-is-valid']
sys.path.insert(0,str(R56))
spec=importlib.util.spec_from_file_location('printer_entry_family',R56/'family_model.py')
fm=importlib.util.module_from_spec(spec);spec.loader.exec_module(fm)
sys.path.pop(0)
def read(p):return json.loads(p.read_text())
def project(case):
 g=json.loads(gzip.decompress((R51/f'{case}-graph.json.gz').read_bytes()))
 types=read(R56/f'{case}-types.json'); fam=read(R56/f'{case}-family.json')
 ds={d['declaration']:d for d in g['declarations']};m=fm.Family(g,types['types'])
 def tree(t):
  k,key,ty,attrs,ch,bounds,pats=m.nodes[t]
  if k=='app':key={'pointer':key,'name':g['symbols'][str(key)]['name']}
  return dict(kind=k,key=key,type=ty,attrs=sorted(attrs),bound=bounds,children=[tree(x) for x in ch])
 def features(t):
  counts=Counter();attrs=set();letvals=[];eps=[];consts=[];qs=[]
  def walk(t,path=()):
   k,key,ty,aa,ch,bo,pa=m.nodes[t];counts[k]+=1;attrs.update(aa)
   if k=='let':letvals.append(dict(path=path,value=list(m.dimensions(ch[0])),body=list(m.dimensions(ch[1])),uses=dict(m.free(ch[1])).get(bo[0][0],0),value_root_kind=m.nodes[ch[0]][0],value_tree=tree(ch[0]) if m.dimensions(ch[0])[1] else None))
   if k=='eps':
    node=m.nodes[ch[0]]
    assert not m.free(t) and m.dimensions(t)==(9,1,0,5)
    assert node[0]=='binop' and node[1]==0
    left,right=[m.nodes[x] for x in node[4]]
    assert left[0]==right[0]=='app' and g['symbols'][str(left[1])]['name']=='infix ='
    var,w=left[4];assert m.nodes[var][0]=='var' and m.nodes[var][1]==bo[0][0]
    assert not m.free(w) and m.dimensions(w)==(2,0,0,2)
    assert m.dimensions(node[4][1])==(3,0,0,2)
    eps.append(dict(path=path,dimensions=list(m.dimensions(t)),tree=tree(t)))
   if k=='const':consts.append(dict(key=key,type=ty))
   if k=='quant':qs.append(dict(kind=key[0],triggers=key[1],arity=len(bo[0])))
   for i,x in enumerate(ch):walk(x,path+(i,))
  walk(t)
  return dict(counts=dict(counts),attrs=sorted(attrs),lets=letvals,eps=eps,constants=consts,quantifiers=qs)
 routes={}
 for route in ('raw','ce'):
  rows=[]
  for r in fam['stages'][route]['roots']:
   dp=g['raw_task_declaration_sequences'][str(r['task'])][-1]
   p,=ds[dp]['candidate_root_indexes' if route=='ce' else 'raw_root_indexes']
   f=features(m.open(p));assert not f['counts'].get('case',0)
   rows.append(dict(goal=r['goal'],check_id=r['check_id'],root_index=r['root_index'],formula=p,**f))
  routes[route]=rows
 data=[]
 for ts,constructors in types['data'].items():
  ident=types['type_symbols'][ts]['identifier'];name=types['identifiers'][str(ident)]['name']
  data.append(dict(type_symbol=int(ts),name=name,constructor_arities=list(map(len,constructors))))
 multi=[d for d in data if len(d['constructor_arities'])>1]
 assert len(multi)==1 and multi[0]['name']=='bool' and multi[0]['constructor_arities']==[0,0]
 assert max(a for d in data for a in d['constructor_arities'])<=2
 ranges=[];floats=[]
 for ts,t in types['type_symbols'].items():
  if t['definition_tag']==1:ranges.append(dict(type_symbol=int(ts),name=types['identifiers'][str(t['identifier'])]['name'],bounds=t['range']))
  elif t['definition_tag']==2:floats.append(dict(type_symbol=int(ts),definition=t))
 assert not floats
 return dict(case=case,routes=routes,data=data,range_types=ranges,float_types=floats,
  transform_replay=False,predecessor_aggregate_replay=False)
def compact(p):
 """Retain reviewable observations; verbose occurrence rows stay in scratch."""
 q={k:v for k,v in p.items() if k!='routes'};q['routes']={}
 for route,rows in p['routes'].items():
  rr=[]
  for r in rows:
   lets=r['lets']; qs=r['quantifiers']
   rr.append(dict(goal=r['goal'],check_id=r['check_id'],root_index=r['root_index'],
    formula=r['formula'],counts=r['counts'],eps=r['eps'],
    let_value_dimensions=[dict(dimensions=list(k),occurrences=n) for k,n in sorted(Counter(tuple(x['value']) for x in lets).items())],
    binding_bearing_let_values=[x for x in lets if x['value'][1]],
    let_count=len(lets),nonleaf_values_under_binders=sum(x['value'][0]>1 and x['body'][1]>0 for x in lets),
    quantifier_kinds=dict(Counter(str((x['kind'],x['triggers'])) for x in qs)),
    maximum_quantifier_arity=max([x['arity'] for x in qs]+[0]),
    triggered_quantifiers=sum(bool(x['triggers']) for x in qs)))
  q['routes'][route]=rr
 return q
if __name__=='__main__':
 for case in CASES:
  p=compact(project(case));(HERE/f'{case}-inventory.json').write_text(json.dumps(p,sort_keys=True,indent=2)+'\n')
  print(case, 'data',len(p['data']),'range',len(p['range_types']),[(r,sum(len(x['eps']) for x in rows)) for r,rows in p['routes'].items()])
