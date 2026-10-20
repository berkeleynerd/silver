"""Finite witnesses for source-level marker exclusion; not a theorem prover.

Demand-evaluate the inline_trivial eligibility of thirteen distinguished
symbols and their prior definition dependencies. Non-app root constructors
are stable under this nonsimplifying mapper. Their free-variable sets suffice
when they appear as arguments; they are never expanded as eligible bodies here.
"""
import argparse,collections,gzip,json
from pathlib import Path
HERE=Path(__file__).resolve().parent;OLD=HERE.parent
CASES=['put-line','put','first-or-default','is-message','input-is-valid']

def derive(case):
 g=json.loads(gzip.decompress((OLD/'retained-why-preinline-prefix-20261020'/f'{case}-graph.json.gz').read_bytes()))
 prior=json.loads((OLD/'retained-why-parallel-first-fill-20261020'/f'{case}-certificate.json').read_text())
 md=json.loads((HERE/f'{case}-metadata.json').read_text())
 terms,binds,syms=g['terms'],g['bindings'],g['symbols']
 assert all('inline:trivial' not in x['attrs'] for x in terms)
 assert all('inline:trivial' not in x['attrs'] for x in syms.values())
 assert all('inline:trivial' not in x['attrs'] for x in g['variables'].values())
 definitions={s:d for d in g['declarations'] for s in d['definition_symbols']}
 excluded={s['old_pointer'] for s in md['selected_symbols']['inline:no']}
 sequences=list(g['raw_task_declaration_sequences'].values())
 rank={d:i for i,d in enumerate(sequences[0])}
 def fv(i):
  k,a=terms[i]['kind'],terms[i]['args']
  if k=='var':return {a[0]}
  if k in ('quant','eps'):return set(map(int,binds[a[0] if k=='eps' else a[1]]['free_variables']))
  if k=='let':return fv(a[0])|set(map(int,binds[a[1]]['free_variables']))
  if k=='app':ch=a[1]
  elif k in ('bin','if','not'):ch=a[1:] if k=='bin' else a
  elif k=='case':return fv(a[0])|set().union(*(set(map(int,binds[b]['free_variables'])) for p,b in a[1]))
  else:ch=[]
  return set().union(*(fv(x) for x in ch))
 def expression(i):
  t=terms[i];k,a=t['kind'],t['args'];x=dict(kind=k,free=fv(i),attrs=set(t['attrs']),root=i)
  if k=='var':x['variable']=a[0]
  elif k=='app':x.update(symbol=a[0],arguments=[expression(z) for z in a[1]])
  return x
 def subst(e,m):
  if e['kind']=='var' and e['variable'] in m:
   out=dict(m[e['variable']]);out['attrs']=out['attrs']|e['attrs'];return out
  out=dict(e)
  if e['kind']=='app':out['arguments']=[subst(z,m) for z in e['arguments']]
  out['free']=set().union(*(m[v]['free'] if v in m else {v} for v in e['free']))
  return out
 def description(e):
  d={k:v for k,v in e.items() if k not in ('free','attrs','arguments')};d.update(free=sorted(e['free']),attrs=sorted(e['attrs']))
  if e['kind']=='app':d.update(name=syms[str(e['symbol'])]['name'],arguments=[description(z) for z in e['arguments']])
  return d
 def body(d):
  assert d['kind']==3 and len(d['definition_symbols'])==1 and len(d['raw_root_indexes'])==1
  i=d['raw_root_indexes'][0];vl=[]
  if terms[i]['kind']=='quant':
   q,b=terms[i]['args'];assert q==0;bd=binds[b];assert not bd['saved'];vl=bd['variables'];i=bd['body']
  k,a=terms[i]['kind'],terms[i]['args'];ls=d['definition_symbols'][0]
  if k=='app':assert syms[str(a[0])]['name']=='infix =' and len(a[1])==2;hd,res=a[1]
  else:assert k=='bin' and a[0]==3;_,hd,res=a
  assert terms[hd]['kind']=='app' and terms[hd]['args'][0]==ls
  assert [terms[v]['args'][0] for v in terms[hd]['args'][1]]==vl
  return vl,res
 decisions={};active=set()
 def decision(s):
  if s in decisions:return decisions[s]
  sym=syms[str(s)];d=definitions.get(s)
  if d is None or d['kind']!=3 or len(d['definition_symbols'])!=1 or s in excluded:
   decisions[s]=dict(symbol=s,name=sym['name'],eligible=False,reason='no singleton logical definition' if d is None or d['kind']!=3 or len(d['definition_symbols'])!=1 else 'actual inline:no');return decisions[s]
  assert s not in active, ('unexpected recursive target dependency',s)
  active.add(s);vl,root=body(d);before=expression(root)
  # These witnesses have no force-inline attribute and only refer to prior defs.
  assert 'inline:trivial' not in before['attrs']|set(sym['attrs'])
  def rewrite(e):
   if e['kind']!='app':return e
   out=dict(e);out['arguments']=[rewrite(z) for z in e['arguments']];out['free']=set().union(*(z['free'] for z in out['arguments']))
   callee=e['symbol'];cd=definitions.get(callee)
   if cd is not None:assert rank[cd['declaration']]<rank[d['declaration']], ('forward/recursive target',s,callee)
   dec=decision(callee)
   if not dec['eligible']:return out
   replacement=subst(dec['_body'],dict(zip(dec['_formals'],out['arguments'])));replacement['attrs']=replacement['attrs']|out['attrs'];return replacement
  after=rewrite(before)
  assert 'inline:trivial' not in after['attrs']|set(sym['attrs'])
  if after['kind'] in ('var','const','true','false'):eligible=True
  elif after['kind']=='app':
   seen=set();eligible=True
   for arg in after['arguments']:
    if arg['kind']=='var':
     if arg['variable'] in seen:eligible=False
     seen.add(arg['variable'])
    elif arg['kind']=='eps' or arg['free']:eligible=False
  else:eligible=False
  assert not ('introduced' in sym['attrs'] and sym['arity']==0)
  out=dict(symbol=s,name=sym['name'],declaration=d['declaration'],raw_body=root,formals=vl,body_before=description(before),body_after_prior_inlining=description(after),eligible=eligible,reason='source notdef/trivial',_body=after,_formals=vl)
  decisions[s]=out;active.remove(s);return out
 def visible_apps(i,frames=()):
  k,a=terms[i]['kind'],terms[i]['args']
  if k=='var':
   v=a[0]
   for n,(bound,saved) in enumerate(frames):
    if v in bound:return collections.Counter()
    if str(v) in saved:return visible_apps(saved[str(v)],frames[n+1:])
   return collections.Counter()
  result=collections.Counter()
  if k=='app':result[a[0]]+=1;ch=a[1]
  elif k in ('bin','if','not'):ch=a[1:] if k=='bin' else a
  elif k in ('let','quant','eps'):
   b=binds[a[0] if k=='eps' else a[1]];ff=((set(b['variables']),b['saved']),)+frames
   result+=visible_apps(b['body'],ff)
   for tr in b['triggers']:
    for j in tr:result+=visible_apps(j,ff)
   ch=[a[0]] if k=='let' else []
  elif k=='case':
   for _,bi in a[1]:
    b=binds[bi];result+=visible_apps(b['body'],((set(b['variables']),b['saved']),)+frames)
   ch=[a[0]]
  else:ch=[]
  for j in ch:result+=visible_apps(j,frames)
  return result
 witnesses=[]
 for residual in prior['unresolved']:
  name=residual['name'];apps=visible_apps(residual['candidate_root_index'])
  markername='index_I1_one' if name=='concat_singleton_left_def' else 'infix >' if name=='bool_eq_rev' else 'dynamic_invariant'
  candidates=[s for s in apps if syms[str(s)]['name']==markername and decision(s)['eligible']]
  assert len(candidates)==1,(case,name,candidates)
  marker=candidates[0];sym=syms[str(marker)];d=definitions[marker]
  assert marker not in excluded and not sym['constr'] and not sym['projection']
  assert all((not x['compatible'] and x['raw_declaration']) or (case=='input-is-valid' and x['compatible'] and not x['raw_declaration']) for x in residual['initial_same_key_objects'])
  assert all(seq.index(d['declaration'])<seq.index(residual['declaration']) for seq in sequences)
  # Metadata can retain a removed lsymbol: record these occurrences, then check
  # the only later metadata-to-term inputs (literal range/float projections).
  metadata_occ=[];literal_inputs=[]
  mapname='first-domain-address-map.json.gz' if case=='first-or-default' else case+'-correspondence.map.json.gz'
  oldnew={int(k):v for k,v in json.loads(gzip.decompress((OLD/'retained-why-parallel-residual-transfer-20261020'/mapname).read_bytes())).items()}
  newmarker=oldnew[marker]
  for mn,als in md['updated_metadata'].items():
   for al in als:
    if any(kind==2 and value==newmarker for kind,value in al):metadata_occ.append(mn)
    if mn in ('range_type','float_type'):
     literal_inputs.extend(value for kind,value in al if kind==2)
  assert newmarker not in literal_inputs
  prrow=next(x for x in md['raw_prop_roots'] if x['old_prsymbol']==residual['prsymbol']);assert 'introduced' not in prrow['prsymbol_attrs']
  witnesses.append(dict(prsymbol_attrs=prrow['prsymbol_attrs'],prsymbol=residual['prsymbol'],name=name,marker=marker,marker_new_pointer=newmarker,marker_name=markername,marker_identifier=sym['identifier'],marker_definition=d['declaration'],marker_attrs=sym['attrs'],marker_constructor=sym['constr'],marker_projection=sym['projection'],raw_root=residual['raw_root_index'],candidate_root=residual['candidate_root_index'],visible_candidate_occurrences=apps[marker],raw_stored=residual['raw_stored'],ce_stored=residual['candidate_stored'],marker_metadata_occurrences=metadata_occ,literal_metadata_inputs_exclude_marker=True,retained_projection_stage='after_first_CE' if case=='input-is-valid' else 'registration',retained_same_key_objects=residual['initial_same_key_objects']))
 # The extra Put-family polymorphic declarations form a closed unseeded cluster
 # after eliminate_builtin removes the four captured wf axioms.
 unignored={x['old_pointer'] for x in md['raw_signature_polymorphism'] if not x['ignored']}
 assert all(syms[str(x)]['name'] in ('well_founded','acc') for x in unignored)
 rem={x['old_pointer']:x['name'] for x in md['selected_symbols']['remove_prop']}
 dependencies=[]
 for d in g['declarations']:
  used=set().union(*(visible_apps(i).keys() for i in d['raw_root_indexes']))
  hit=used&unignored
  if hit:
   removed=d['kind']==5 and d['symbol'] in rem
   internal=d['kind']==3 and set(d['definition_symbols'])<=unignored or d['kind']==4 and any(x['old_declaration']==d['declaration'] and set(x['old_heads'])<=unignored for x in md['raw_inductive_declarations'])
   assert removed or internal,(case,d,hit)
   dependencies.append(dict(declaration=d['declaration'],kind=d['kind'],prsymbol=d['symbol'],defined_logic_symbols=d['definition_symbols'],referenced_cluster=sorted(hit),removed_builtin=removed,removed_axiom_name=rem.get(d['symbol'])))
 # No original Dind clause key is one of the thirteen residual physical heads.
 residual_heads={x['prsymbol'] for x in witnesses}
 assert not residual_heads.intersection(x for d in md['raw_inductive_declarations'] for x in d['old_clause_prsymbols'])
 unignored_new={x['pointer'] for x in md['raw_signature_polymorphism'] if not x['ignored']}
 kept={p for al in md['updated_metadata'].get('remove_unused:keep',[]) for k,p in al if k==2}
 assert not kept&unignored_new
 return dict(case=case,raw_tasks=len(sequences),witnesses=witnesses,eligibility_decisions=[{k:v for k,v in x.items() if not k.startswith('_')} for x in decisions.values()],unignored_polymorphic_cluster=sorted(unignored),cluster_incoming_declarations=dependencies,raw_and_ce_stored_closures_have_no_force_inline_attribute=True,cluster_excluded_from_keep=True,inductive_clause_keys_disjoint_from_residuals=True,no_introduced_prsymbol='introduced_prsymbol' not in md['updated_counts'],all_raw_polymorphic_signatures_ignored=md['all_raw_polymorphic_signatures_ignored'],source_theorem_machine_checked=False)

a=argparse.ArgumentParser();a.add_argument('--output',type=Path,default=HERE);args=a.parse_args()
for case in CASES:
 result=derive(case);(args.output/f'{case}-exclusions.json').write_text(json.dumps(result,indent=2)+'\n')
 print(case,[(x['name'],x['marker_name'],x['visible_candidate_occurrences'],x['marker_metadata_occurrences']) for x in result['witnesses']])
