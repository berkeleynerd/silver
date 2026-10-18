"""Offline first-inline dimensions from retained raw OCaml declaration graph.
Source: Why3 9390baf... term.ml:258-283 descend and constructor definitions.
Counts use full occurrence trees, including triggers and repeated shared edges.
This is a measurement/checker, not a proof of source/runtime correspondence.
"""
import json,sys
from pathlib import Path
from functools import lru_cache
from collections import Counter
sys.setrecursionlimit(10000)
def decode(g):
 blocks=g['blocks']
 def fields(p,n=None,tag=0):
  r=blocks[str(p)];assert r['tag']==tag,(hex(p),r['tag'],tag)
  x=r['fields'];assert n is None or len(x)==n,(hex(p),len(x),n)
  return x
 def integer(v):
  assert v&1
  if v>=1<<63:v-=1<<64
  return v>>1
 def seq(p):
  seen=set();out=[]
  while p!=1:
   assert p not in seen,'list cycle';seen.add(p)
   x,p=fields(p,2);out.append(x)
  return tuple(out)
 def mapping(p):
  seen=set()
  def walk(p):
   if p==1:return []
   assert p not in seen,'map cycle';seen.add(p)
   l,k,v,r,h=fields(p,5);assert integer(h)>0
   return walk(l)+[(k,v)]+walk(r)
  out=tuple(walk(p));assert len({k for k,v in out})==len(out),'duplicate map key'
  tags=[integer(fields(fields(k,2)[0],4)[3]) for k,v in out]
  assert tags==sorted(set(tags)),'map keys not ordered by variable identifier'
  return out
 def validate_graph():
  for ptr,row in blocks.items():
   assert row['header']&255==row['tag'] and row['header']>>10==row['words']
   if row['tag']<246:
    assert len(row['fields'])==row['words']
    for v in row['fields']:
     assert v&1 or str(v) in blocks, ('missing graph edge',ptr,v)
   else:
    assert row['tag']==252,'unhandled opaque payload'
    assert len(bytes.fromhex(row['payload_hex']))==8*row['words']
 validate_graph()
 def typename(p):
  node,_=fields(p,2);row=blocks[str(node)]
  assert row['tag'] in (0,1)
  return row['tag'],row['fields']
 def node(p):
  v=fields(p,4)[0]
  if v&1:
   assert v in (1,3);return ('true' if v==1 else 'false'),()
  r=blocks[str(v)];tag=r['tag'];assert tag<=9
  return ['var','const','app','if','let','case','eps','quant','binop','not'][tag],tuple(r['fields'])
 @lru_cache(None)
 def pattern_checked(p):
  nd,vs,ty=fields(p,3)
  if nd==1:count,variables=1,frozenset()
  else:
   r=blocks[str(nd)];tag=r['tag'];x=r['fields'];assert tag in range(4)
   if tag==0:count,variables=1,frozenset([x[0]])
   elif tag==1:
    count=1;variables=frozenset()
    for c in seq(x[1]):
     n,v=pattern_checked(c);assert not variables&v,'duplicate pattern variable'
     count+=n;variables|=v
   elif tag==2:
    n,v=pattern_checked(x[0]);m,w=pattern_checked(x[1]);assert v==w,'or-pattern variables differ'
    count,variables=1+n+m,v
   else:
    n,v=pattern_checked(x[0]);assert x[1] not in v,'duplicate as-pattern variable'
    count,variables=1+n,v|{x[1]}
  assert {k for k,_ in mapping(vs)}==set(variables),'pattern variable metadata mismatch'
  return count,variables
 def pattern(p):
  n,variables=pattern_checked(p);return n,len(variables)
 def frame(bound,bi):
  bvars,bsubst=fields(bi,2)
  return tuple(bound),mapping(bsubst)
 def descend(p,frames):
  active=set()
  while True:
   key=(p,frames);assert key not in active,'substitution cycle';active.add(key)
   k,x=node(p)
   if k!='var':return p,frames
   v=x[0]
   for i,(bound,subst) in enumerate(frames):
    if v in bound:return p,()
    sm=dict(subst)
    if v in sm:
     p=sm[v];frames=frames[i+1:];break
   else:return p,()
 def plus(a,b):return tuple(x+y for x,y in zip(a,b))
 @lru_cache(None)
 def measure(p,frames=()):
  p,frames=descend(p,frames);k,x=node(p)
  d=(1,0,0,int(k=='app'));children=[]
  if k=='app':children=[(q,frames) for q in seq(x[1])]
  elif k in ('if','binop'):children=[(q,frames) for q in (x if k=='if' else x[1:])]
  elif k=='not':children=[(x[0],frames)]
  elif k in ('let','eps'):
   bp=x[1] if k=='let' else x[0];v,bi,t=fields(bp,3)
   d=plus(d,(0,1,0,0));children=[(t,(frame([v],bi),)+frames)]
   if k=='let':children.insert(0,(x[0],frames))
  elif k=='case':
   children=[(x[0],frames)]
   for br in seq(x[1]):
    pat,bi,t=fields(br,3);pn,b=pattern(pat);d=plus(d,(0,b,pn,0))
    children.append((t,(frame([v for v,_ in mapping(fields(pat,3)[1])],bi),)+frames))
  elif k=='quant':
   vl,bi,tr,t=fields(x[1],4);vs=seq(vl);d=plus(d,(0,len(vs),0,0));fs=(frame(vs,bi),)+frames
   children=[(t,fs)]+[(q,fs) for trigger in seq(tr) for q in seq(trigger)]
  for q,fs in children:d=plus(d,measure(q,fs))
  return d

 def asrow(d):return dict(zip(['n','b','p','a'],d),m=sum(d[:3]))
 # The stored representation is deliberately reported separately. Every saved
 # substitution value is followed, including values absent from opened terms.
 seen_terms=set();seen_binds=set();seen_types=set();seen_symbols=set();pending=[];bind_rows=[];binding_uses=[]
 def add_type(ty):
  if ty in seen_types:return
  seen_types.add(ty);tag,x=typename(ty)
  if tag==1:
   for child in seq(x[1]):add_type(child)
 def symbol(ls):
  if ls in seen_symbols:return
  seen_symbols.add(ls);_,args,value,_,_=fields(ls,5)
  for ty in seq(args):add_type(ty)
  if value!=1:add_type(fields(value,1)[0])
 def binding(bp,kind):
  x=fields(bp,4 if kind=='quant' else 3);bound,bi=x[:2]
  binding_uses.append((bp,kind))
  if bi not in seen_binds:
   seen_binds.add(bi);varmap,subst=fields(bi,2);vars_=mapping(varmap);sub=mapping(subst)
   bind_rows.append({'address':bi,'free_count_entries':len(vars_),'stored_counts':[integer(v) for _,v in vars_],
                     'substitution_entries':len(sub),'substitution_values':[v for _,v in sub]})
   pending.extend(v for _,v in sub)
  if kind=='quant':pending.extend(t for tr in seq(x[2]) for t in seq(tr));pending.append(x[3])
  else:pending.append(x[2])
  # Variable/pattern types are present in the graph; term and symbol types below
  # cover operational term types. Complete validator/type traversal is residual.
 def collect():
  while pending:
   p=pending.pop()
   if p in seen_terms:continue
   seen_terms.add(p);k,x=node(p);ty=fields(p,4)[1]
   if ty!=1:add_type(fields(ty,1)[0])
   if k=='var':add_type(fields(x[0],2)[1])
   elif k=='app':symbol(x[0]);pending.extend(seq(x[1]))
   elif k=='if':pending.extend(x)
   elif k=='binop':pending.extend(x[1:])
   elif k=='not':pending.append(x[0])
   elif k=='let':pending.append(x[0]);binding(x[1],'let')
   elif k=='eps':binding(x[0],'eps')
   elif k=='quant':binding(x[1],'quant')
   elif k=='case':
    pending.append(x[0])
    for bp in seq(x[1]):binding(bp,'case')


 @lru_cache(None)
 def freevars(p,frames=()):
  # Source descend, retaining the distinction between a bound leaf and a free
  # variable (the dimension-only descend can erase this distinction).
  while True:
   k,x=node(p)
   if k!='var':break
   v=x[0]
   for i,(bound,subst) in enumerate(frames):
    if v in bound:return ()
    sm=dict(subst)
    if v in sm:p=sm[v];frames=frames[i+1:];break
   else:return ((v,1),)
  k,x=node(p);children=[]
  if k=='app':children=[(q,frames) for q in seq(x[1])]
  elif k in ('if','binop'):children=[(q,frames) for q in (x if k=='if' else x[1:])]
  elif k=='not':children=[(x[0],frames)]
  elif k in ('let','eps'):
   bp=x[1] if k=='let' else x[0];v,bi,t=fields(bp,3)
   children=[(t,(frame([v],bi),)+frames)]
   if k=='let':children.insert(0,(x[0],frames))
  elif k=='case':
   children=[(x[0],frames)]
   for br in seq(x[1]):
    pat,bi,t=fields(br,3)
    children.append((t,(frame([v for v,_ in mapping(fields(pat,3)[1])],bi),)+frames))
  elif k=='quant':
   vl,bi,tr,t=fields(x[1],4);fs=(frame(seq(vl),bi),)+frames
   children=[(t,fs)]+[(q,fs) for trigger in seq(tr) for q in seq(trigger)]
  result=Counter()
  for q,fs in children:result.update(dict(freevars(q,fs)))
  return tuple(sorted(result.items()))

 def validate_bindings():
  for bp,kind in binding_uses:
   x=fields(bp,4 if kind=='quant' else 3);bound,bi=x[:2]
   bound=seq(bound) if kind=='quant' else [v for v,_ in mapping(fields(bound,3)[1])] if kind=='case' else [bound]
   fs=(frame(bound,bi),);terms=([x[3]]+[t for tr in seq(x[2]) for t in seq(tr)]) if kind=='quant' else [x[2]]
   actual=Counter()
   for t in terms:actual.update(dict(freevars(t,fs)))
   expected={k:integer(v) for k,v in mapping(fields(bi,2)[0])}
   assert all(v>0 for v in expected.values()),'nonpositive free-variable occurrence count'
   assert dict(actual)==expected, ('binding free-count mismatch',bi,dict(actual),expected)
  return len(binding_uses)

 batches=[];axioms=[]
 for index,decl in enumerate(g['roots']):
  dn,_,_=fields(decl,3);r=blocks[str(dn)];tag=r['tag'];x=r['fields']
  batch={'logical_declaration_index':index,'address':decl,'tag':tag,'roots':[]}
  if tag==3:
   assert len(x)==1
   for pair in seq(x[0]):
    ls,ld=fields(pair,2);ls2,axiom,decrease=fields(ld,3);assert ls==ls2
    symbol(ls);pending.append(axiom);axioms.append({'kind':'logic_axiom','root':axiom,'dimensions':asrow(measure(axiom)),'decrease_length':len(seq(decrease))})
    k,xx=node(axiom);fs=();arity=0;body=axiom
    if k=='quant':
     assert xx[0]==1,'definition axiom is not universal'
     vl,bi,tr,body=fields(xx[1],4);vs=seq(vl);arity=len(vs);fs=(frame(vs,bi),)
    assert arity==len(seq(fields(ls,5)[1])),'logic arity mismatch'
    body,fs=descend(body,fs);k,xx=node(body)
    if k=='app':args=seq(xx[1]);assert len(args)==2;body=args[1]
    elif k=='binop':body=xx[2]
    else:raise AssertionError(('invalid definition',k))
    batch['roots'].append({'arity':arity,'root':body,'dimensions':asrow(measure(body,fs))})
  elif tag==4:
   assert len(x)==1
   sign,inds=fields(x[0],2)
   for pair in seq(inds):
    ls,clauses=fields(pair,2);symbol(ls)
    for clause in seq(clauses):
     pr,t=fields(clause,2);pending.append(t);batch['roots'].append({'root':t,'dimensions':asrow(measure(t))})
  elif tag==5:
   assert len(x)==1
   pk,pr,t=fields(x[0],3);pending.append(t);batch['prop_kind']=integer(pk)
   batch['roots'].append({'root':t,'dimensions':asrow(measure(t))})
  else:assert tag in (0,1,2)
  batches.append(batch)
 collect()
 validated_bindings=validate_bindings()
 result={'scope':g['scope'],'status':'one-pair dimensions conditional on valid binder/source representation',
  'ordered_batches':batches,'logic_axiom_validator_roots':axioms,
  'validated_binder_payloads':validated_bindings,
  'source_projection':'term.ml descend frames; no fresh-name allocation; type-erased alpha-invariant dimensions',
  'stored':{'unique_terms_including_unused_substitution_values':len(seen_terms),'bind_infos':bind_rows,
            'unique_term_and_application_symbol_types':len(seen_types),'application_symbols':len(seen_symbols),
            'all_graph_blocks':len(blocks),'all_graph_payload_bytes':g['retained_payload_bytes']},
  'remaining':['complete substitution operational work and type/validator bounds beyond checked semantic free-count metadata',
               'source correspondence of runtime layout and semantic opening projection',
               'all registered-task/driver entry projection and shared process lifetime']}
 return result
