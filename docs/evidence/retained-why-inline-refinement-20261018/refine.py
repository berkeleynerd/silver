"""Source-derived optional-exclusion inline bound for the frozen entry graph.
The Choice nodes overapproximate every inline:no exclusion set. They do not
claim the native metadata payloads (not captured) or exact native output.
"""
from functools import lru_cache
from collections import Counter

class Refiner:
 def __init__(self,g,excluded=None):
  self.g=g;self.blocks=g['blocks'];self.nodes=[];self.intern={};self.variables={};self.nextvar=0
  self.environment={};self.environment_stored_symbols={};self.active_stored_symbols=set();self.hit_rows=[];self.input_roots=[];self.declarations=[]
  self.ambiguous=[];self.excluded=excluded
 def fields(self,p,n=None):
  r=self.blocks[str(p)];assert r['tag']==0
  x=r['fields'];assert n is None or len(x)==n
  return x
 def seq(self,p):
  out=[]
  while p!=1:v,p=self.fields(p,2);out.append(v)
  return tuple(out)
 def mapping(self,p):
  if p==1:return ()
  l,k,v,r,h=self.fields(p,5)
  return self.mapping(l)+((k,v),)+self.mapping(r)
 def string(self,p):
  r=self.blocks[str(p)];assert r['tag']==252;b=bytes.fromhex(r['payload_hex'])
  return b[:-1-b[-1]].decode()
 def attrs(self,p):return frozenset(self.string(self.fields(k,2)[0]) for k,v in self.mapping(p))
 def ident(self,p):
  name,attrs,loc,tag=self.fields(p,4)
  return {'name':self.string(name),'tag':tag>>1,'attributes':sorted(self.attrs(attrs))}
 @lru_cache(None)
 def ty(self,p):
  nd,_=self.fields(p,2);r=self.blocks[str(nd)];x=r['fields']
  if r['tag']==0:return ('v',x[0])
  assert r['tag']==1
  return ('a',x[0],tuple(self.ty(t) for t in self.seq(x[1])))
 def oty(self,p):return None if p==1 else self.ty(self.fields(p,1)[0])
 def variable(self,raw):
  self.nextvar+=1;key=self.nextvar
  name,ty=self.fields(raw,2);self.variables[key]=(self.ty(ty),self.ident(name))
  return key
 def make(self,kind,key,ty,attrs,children=(),bindings=(),patterns=()):
  obj=(kind,key,ty,frozenset(attrs),tuple(children),tuple(bindings),tuple(patterns))
  if obj not in self.intern:self.intern[obj]=len(self.nodes);self.nodes.append(obj)
  return self.intern[obj]
 def with_attrs(self,t,attrs):
  n=self.nodes[t]
  if n[0]=='choice':return self.choice([self.with_attrs(x,attrs) for x in n[4]])
  return self.make(n[0],n[1],n[2],n[3]|attrs,*n[4:])
 def choice(self,alternatives):
  out=[]
  for x in alternatives:
   n=self.nodes[x]
   out.extend(n[4] if n[0]=='choice' else [x])
  out=tuple(dict.fromkeys(out));assert out
  if len(out)==1:return out[0]
  ty=self.nodes[out[0]][2];assert all(self.nodes[x][2]==ty for x in out)
  return self.make('choice',None,ty,(),out)
 def pattern(self,p):
  nd,vs,ty=self.fields(p,3);variables=tuple(k for k,v in self.mapping(vs))
  if nd==1:return 1,(),variables
  row=self.blocks[str(nd)];tag=row['tag'];x=row['fields']
  children=[] if tag==0 else self.seq(x[1]) if tag==1 else x if tag==2 else [x[0]]
  count=1;symbols={x[0]} if tag==1 else set()
  for c in children:
   n,s,_=self.pattern(c);count+=n;symbols.update(s)
  return count,tuple(sorted(symbols)),variables
 @lru_cache(None)
 def stored_symbols(self,p):
  # get_used_syms_decl can inspect delayed values that disappear from the
  # opened tree. Retain a conservative symbol provenance for those as well.
  nd,_,_,_=self.fields(p,4)
  if nd&1:return frozenset()
  row=self.blocks[str(nd)];tag=row['tag'];x=row['fields'];syms=set();children=[]
  def binding(bp,quant=False,pattern=False):
   v,bi,*rest=self.fields(bp,4 if quant else 3)
   children.extend(t for _,t in self.mapping(self.fields(bi,2)[1]))
   if quant:
    tr,t=rest;children.extend(q for ts in self.seq(tr) for q in self.seq(ts));children.append(t)
   else:
    children.append(rest[0])
    if pattern:syms.update(self.pattern(v)[1])
  if tag==2:syms.add(x[0]);children.extend(self.seq(x[1]))
  elif tag==3:children.extend(x)
  elif tag==4:children.append(x[0]);binding(x[1])
  elif tag==5:
   children.append(x[0])
   for bp in self.seq(x[1]):binding(bp,pattern=True)
  elif tag==6:binding(x[0])
  elif tag==7:binding(x[1],quant=True)
  elif tag==8:children.extend(x[1:])
  elif tag==9:children.append(x[0])
  for child in children:syms.update(self.stored_symbols(child))
  return frozenset(syms)
 def raw_definition_symbols(self,axiom):
  nd=self.fields(axiom,4)[0];row=self.blocks[str(nd)];extra=set()
  if row['tag']==7:
   vl,bi,tr,axiom=self.fields(row['fields'][1],4)
   for _,value in self.mapping(self.fields(bi,2)[1]):extra.update(self.stored_symbols(value))
   for ts in self.seq(tr):
    for t in self.seq(ts):extra.update(self.stored_symbols(t))
   nd=self.fields(axiom,4)[0];row=self.blocks[str(nd)]
  assert row['tag'] in (2,8)
  body=self.seq(row['fields'][1])[1] if row['tag']==2 else row['fields'][2]
  return self.stored_symbols(body)|extra
 def newframe(self,raws,bi):
  bound=tuple((v,self.variable(v)) for v in raws);_,subst=self.fields(bi,2)
  return (bound,self.mapping(subst))
 def open(self,p,frames=()):
  rawnode,ty,attrs,loc=self.fields(p,4);at=self.attrs(attrs);ty=self.oty(ty)
  if rawnode&1:return self.make('true' if rawnode==1 else 'false',None,ty,at)
  row=self.blocks[str(rawnode)];tag=row['tag'];x=row['fields']
  kind=['var','const','app','if','let','case','eps','quant','binop','not'][tag]
  if kind=='var':
   raw=x[0]
   for i,(bound,subst) in enumerate(frames):
    if raw in dict(bound):return self.make('var',dict(bound)[raw],ty,at)
    if raw in dict(subst):return self.with_attrs(self.open(dict(subst)[raw],frames[i+1:]),at)
   # Free input variables, including those in stored substitution values, share
   # their original identity. Locally opened binders have separate identities.
   key=-raw
   if key not in self.variables:
    name,vty=self.fields(raw,2);self.variables[key]=(self.ty(vty),self.ident(name))
   return self.make('var',key,ty,at)
  if kind=='const':return self.make(kind,x[0],ty,at)
  if kind=='app':return self.make(kind,x[0],ty,at,[self.open(t,frames) for t in self.seq(x[1])])
  if kind=='if':return self.make(kind,None,ty,at,[self.open(t,frames) for t in x])
  if kind=='binop':return self.make(kind,x[0]>>1,ty,at,[self.open(t,frames) for t in x[1:]])
  if kind=='not':return self.make(kind,None,ty,at,[self.open(x[0],frames)])
  if kind in ('let','eps'):
   bp=x[1] if kind=='let' else x[0];v,bi,t=self.fields(bp,3);fr=self.newframe([v],bi)
   child=self.open(t,(fr,)+frames);vars_=tuple(q for _,q in fr[0])
   children=[self.open(x[0],frames),child] if kind=='let' else [child]
   return self.make(kind,None,ty,at,children,[vars_])
  if kind=='quant':
   vl,bi,tr,t=self.fields(x[1],4);fr=self.newframe(self.seq(vl),bi)
   children=[self.open(t,(fr,)+frames)]
   triggers=tuple(self.seq(ts) for ts in self.seq(tr));lengths=tuple(len(ts) for ts in triggers)
   children.extend(self.open(t,(fr,)+frames) for ts in triggers for t in ts)
   return self.make(kind,(x[0]>>1,lengths),ty,at,children,[tuple(q for _,q in fr[0])])
  assert kind=='case';children=[self.open(x[0],frames)];bounds=[];patterns=[]
  for bp in self.seq(x[1]):
   p,bi,t=self.fields(bp,3);pn,syms,vs=self.pattern(p);fr=self.newframe(vs,bi)
   children.append(self.open(t,(fr,)+frames));bounds.append(tuple(q for _,q in fr[0]));patterns.append((pn,syms))
  return self.make(kind,None,ty,at,children,bounds,patterns)
 def child_scopes(self,n):
  kind,_,_,_,children,bindings,_=n
  if kind in ('quant','eps'):return [frozenset(bindings[0])]*len(children)
  if kind=='let':return [frozenset(),frozenset(bindings[0])]
  if kind=='case':return [frozenset()]+[frozenset(v) for v in bindings]
  return [frozenset()]*len(children)
 @lru_cache(None)
 def free(self,t):
  n=self.nodes[t];kind,key,ty,attrs,children,bindings,patterns=n
  if kind=='var':return ((key,1),)
  if kind=='choice':
   result={}
   for child in children:
    for v,k in self.free(child):result[v]=max(result.get(v,0),k)
   return tuple(sorted(result.items()))
  result=Counter()
  for child,bound in zip(children,self.child_scopes(n)):
   result.update({v:k for v,k in self.free(child) if v not in bound})
  return tuple(sorted(result.items()))
 @lru_cache(None)
 def closed(self,t,scope=frozenset()):
  n=self.nodes[t];kind,key,ty,attrs,children,bindings,patterns=n
  if kind=='var':return key in scope,key in scope
  if kind=='choice':
   c=[self.closed(x,scope) for x in children]
   return any(x[0] for x in c),all(x[1] for x in c)
  c=[self.closed(x,scope|bound) for x,bound in zip(children,self.child_scopes(n))]
  return all(x[0] for x in c),all(x[1] for x in c)
 def argument_classes(self,t):
  n=self.nodes[t]
  if n[0]=='choice':
   c=[self.argument_classes(x) for x in n[4]]
   return frozenset().union(*(x[0] for x in c)),any(x[1] for x in c),any(x[2] for x in c)
  if n[0]=='var':return frozenset([n[1]]),False,False
  if n[0]=='eps':return frozenset(),False,True
  may,must=self.closed(t)
  return frozenset(),may,not must
 def eligible(self,t):
  n=self.nodes[t];kind,key,ty,attrs,children,bindings,patterns=n
  if kind=='choice':
   c=[self.eligible(x) for x in children];return any(x[0] for x in c),all(x[1] for x in c)
  if 'inline:trivial' in attrs or kind in ('var','const','true','false'):return True,True
  if kind!='app':return False,False
  classes=[self.argument_classes(x) for x in children]
  mandatory=[vs for vs,closed,bad in classes if not closed]
  # Existence of distinct variable choices is a small bipartite matching.
  def choose(i,seen):
   if i==len(mandatory):return True
   return any(choose(i+1,seen|{v}) for v in mandatory[i]-seen)
  may=choose(0,frozenset())
  must=all(not bad for vs,closed,bad in classes) and all(not classes[i][0]&classes[j][0] for i in range(len(classes)) for j in range(i))
  return may,must
 @lru_cache(None)
 def symbols(self,t):
  n=self.nodes[t];result={n[1]} if n[0]=='app' else set()
  for _,syms in n[6]:result.update(syms)
  for child in n[4]:result.update(self.symbols(child))
  return frozenset(result)
 @lru_cache(None)
 def linear(self,t,formals=()):
  # Coordinates (n,b,p,a) of nonformal structure, plus per-formal occurrence
  # coefficients. Choices take coordinatewise maxima, never summing alternatives.
  n=self.nodes[t];kind,key,ty,attrs,children,bindings,patterns=n
  if kind=='var' and key in formals:return (0,0,0,0),tuple(int(key==v) for v in formals)
  if kind=='choice':
   rows=[self.linear(x,formals) for x in children]
   return tuple(max(x[0][i] for x in rows) for i in range(4)),tuple(max(x[1][i] for x in rows) for i in range(len(formals)))
  base=[1,sum(map(len,bindings)),sum(p for p,_ in patterns),int(kind=='app')];coef=[0]*len(formals)
  for child in children:
   b,c=self.linear(child,formals)
   base=[x+y for x,y in zip(base,b)];coef=[x+y for x,y in zip(coef,c)]
  return tuple(base),tuple(coef)
 def dimensions(self,t):return self.linear(t)[0]
 def instantiate_type(self,ty,mt):
  if ty is None:return None
  if ty[0]=='v':return mt.get(ty[1],ty)
  return ('a',ty[1],tuple(self.instantiate_type(t,mt) for t in ty[2]))
 def match_type(self,pattern,actual,mt):
  assert pattern is not None and actual is not None
  if pattern[0]=='v':
   old=mt.setdefault(pattern[1],actual);assert old==actual,'inconsistent polymorphic instance'
  else:
   assert actual[:2]==pattern[:2] and len(actual[2])==len(pattern[2]),'type shape mismatch'
   for p,a in zip(pattern[2],actual[2]):self.match_type(p,a,mt)
 def substitute(self,t,mv,mt):
  # Bound variables use locally unique alpha identities. Rename them on each
  # expansion, preserving repeated references and pattern/trigger bindings.
  rename={}
  def go(t,mv,rename):
   n=self.nodes[t];kind,key,ty,attrs,children,bindings,patterns=n
   if kind=='choice':return self.choice([go(x,mv,rename) for x in children])
   if kind=='var':
    if key in mv:return self.with_attrs(mv[key],attrs)
    return self.make(kind,rename.get(key,key),self.instantiate_type(ty,mt),attrs)
   local={};newbindings=[]
   for group in bindings:
    vs=[]
    for v in group:
     self.nextvar+=1;nv=self.nextvar;oldty,ident=self.variables[v]
     self.variables[nv]=(self.instantiate_type(oldty,mt),ident);local[v]=nv;vs.append(nv)
    newbindings.append(tuple(vs))
   newchildren=[]
   for child,scope in zip(children,self.child_scopes(n)):
    ren=dict(rename);ren.update({v:local[v] for v in scope})
    newchildren.append(go(child,{v:x for v,x in mv.items() if v not in scope},ren))
   return self.make(kind,key,self.instantiate_type(ty,mt),attrs,newchildren,newbindings,patterns)
  return go(t,mv,rename)
 def replace(self,t,root_index):
  n=self.nodes[t];kind,key,ty,attrs,children,bindings,patterns=n
  transformed=[self.replace(x,root_index) for x in children]
  miss=self.make(kind,key,ty,attrs,transformed,bindings,patterns)
  if kind!='app' or key not in self.environment:return miss
  formals,body=self.environment[key];self.active_stored_symbols.update(self.environment_stored_symbols[key]);assert len(formals)==len(transformed)
  mt={}
  for v,arg in zip(formals,transformed):self.match_type(self.variables[v][0],self.nodes[arg][2],mt)
  bt=self.nodes[body][2]
  if bt is None:assert ty is None
  else:self.match_type(bt,ty,mt)
  base,coef=self.linear(body,formals);args=[self.dimensions(x) for x in transformed]
  weighted=tuple(base[i]+sum(c*a[i] for c,a in zip(coef,args)) for i in range(4))
  hit=self.with_attrs(self.substitute(body,dict(zip(formals,transformed)),mt),attrs)
  actual=self.dimensions(hit);assert all(a<=w for a,w in zip(actual,weighted)),('weighted substitution failure',actual,weighted)
  assert self.nodes[hit][2]==ty
  self.hit_rows.append({'root':root_index,'symbol':self.ident(self.fields(key,5)[0]),
   'body_dimensions':self.dimensions(body),'nonformal_coordinates':base,'formal_occurrences':coef,
   'argument_coordinates':args,'substitution_coordinates_upper':weighted})
  # Either the meta excludes this symbol, or the mapped definition is stored.
  # Keeping both also removes dependence on the unknown exclusion correlations.
  return self.choice([miss,hit]) if self.excluded is None else hit
 def run(self):
  roots=[];candidates=[];results=[];input_roots=[]
  for decl_index,p in enumerate(self.g['roots']):
   dn,_,_=self.fields(p,3);row=self.blocks[str(dn)];tag=row['tag'];x=row['fields'];batch=[]
   if tag==3:
    for pair in self.seq(x[0]):
     ls,ld=self.fields(pair,2);_,axiom,_=self.fields(ld,3);a=self.open(axiom);an=self.nodes[a]
     formals=()
     if an[0]=='quant':
      assert an[1][0]==0;formals=an[5][0];a=an[4][0];an=self.nodes[a]
     assert an[0] in ('app','binop') and len(an[4])==2
     body=an[4][1];assert set(dict(self.free(body)))<=set(formals)
     batch.append((ls,formals,body,self.raw_definition_symbols(axiom)))
   elif tag==5:
    pk,pr,t=self.fields(x[0],3);batch=[(None,(),self.open(t),self.stored_symbols(t))]
   elif tag==4:raise AssertionError('no inductive declarations in frozen pair')
   outputs=[];stored_provenance=[]
   for ls,formals,t,stored_syms in batch:
    index=len(roots);roots.append(t);input_roots.append(self.dimensions(t));self.active_stored_symbols=set(stored_syms)
    out=self.replace(t,index);outputs.append(out);stored_provenance.append(frozenset(self.active_stored_symbols))
    results.append({'declaration_index':decl_index,'kind':'logic' if tag==3 else 'prop','symbol':None if ls is None else self.ident(self.fields(ls,5)[0]),
                    'arity':len(formals),'input':self.dimensions(t),'output_coordinates_upper':self.dimensions(out)})
   if tag==3 and len(batch)==1:
    ls,formals,t,_=batch[0];out=outputs[0];ident=self.ident(self.fields(ls,5)[0]);rec=ls in self.symbols(out) or ls in stored_provenance[0]
    candidate=self.with_attrs(out,frozenset(ident['attributes']));may,must=self.eligible(candidate)
    assert not rec,('unsupported possible self-reference',decl_index,ident)
    candidates.append({'declaration_index':decl_index,'symbol':ident,'may_eligible':may,'must_eligible':must,'self_reference_possible':rec,'body_coordinates_upper':self.dimensions(out)})
    if may and not must:self.ambiguous.append(decl_index)
    # The successful result below requires uniform eligibility. Do not hide an
    # ambiguous eligibility result by admitting every singleton definition.
    assert may==must,('eligibility depends on exclusion choices',decl_index,ident)
    if may and (self.excluded is None or ls not in self.excluded):
     assert set(dict(self.free(out)))<=set(formals)
     self.environment[ls]=(formals,out);self.environment_stored_symbols[ls]=stored_provenance[0]
  return {'scope':'frozen first Input_Is_Valid/cvc5 entry; all inline:no exclusion sets',
    'input_coordinates':input_roots,'root_results':results,'definition_eligibility':candidates,'symbol_matched_optional_hits':self.hit_rows,
    'eligible_definition_count':sum(x['must_eligible'] for x in candidates),'environment_entries':len(self.environment),'optional_hit_count':len(self.hit_rows),'term_templates':len(self.nodes),
    'eligibility_ambiguities':self.ambiguous,'metadata_exclusion_set_known':False,
    'all_fixed_pair_dimensions_established':False,'whole_pipeline_capacity_established':False}
