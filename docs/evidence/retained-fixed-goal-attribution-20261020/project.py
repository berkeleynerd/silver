#!/usr/bin/env python3
"""Finite raw-forest label projection. No observer/native replay."""
import json,struct,tarfile,hashlib,time
from functools import lru_cache
from pathlib import Path
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
CASES=['put_line','put','first_or_default','is_message','input_is_valid']
class Graph:
 def __init__(self,data):
  self.b={x['address']:x for x in map(json.loads,data.splitlines())};self.bindings=set()
 def fields(self,p,n=None,tag=0):
  r=self.b[p];assert r['tag']==tag and (n is None or r['words']==n)
  assert r['header']==int.from_bytes(bytes.fromhex(r['header_hex']),'little')
  assert r['words']==r['header']>>10 and r['tag']==r['header']&255
  raw=bytes.fromhex(r['payload_hex']);assert len(raw)==8*r['words']
  return struct.unpack('<'+'Q'*r['words'],raw)
 def string(self,p):
  r=self.b[p];assert r['tag']==252
  raw=bytes.fromhex(r['payload_hex']);assert 0<=raw[-1]<=7
  return raw[:len(raw)-1-raw[-1]].decode()
 @lru_cache(None)
 def attrs(self,p):
  if p==1:return ()
  l,a,unit,r,h=self.fields(p,5);assert unit==1 and h&1
  st,tag=self.fields(a,2);assert tag&1
  return self.attrs(l)+(self.string(st),)+self.attrs(r)
 def seq(self,p):
  result=[];seen=set()
  while p!=1:
   assert p not in seen;seen.add(p);a,p=self.fields(p,2);result.append(a)
  return result
 def term(self,p):
  node,ty,attrs,loc=self.fields(p,4)
  if node&1:assert node in [1,3];return node,(),ty,self.attrs(attrs)
  r=self.b[node];return r['tag'],self.fields(node,tag=r['tag']),ty,self.attrs(attrs)
 def check_binding(self,p):
  self.bindings.add(p)
  _,mapping=self.fields(p,2)
  def walk(m):
   if m==1:return
   l,key,value,r,h=self.fields(m,5);tag,fs,ty,attrs=self.term(value)
   assert tag==0 and len(fs)==1 and ty!=1, ('nonvariable saved image',value)
   walk(l);walk(r)
  walk(mapping)
 def shape_search(self,p):
  tag,fs,ty,attrs=self.term(p)
  if ty!=1 or 'stop_split' in attrs:return []
  child=[]
  if tag==8 and fs[0]==5:child=[fs[2]]
  elif tag==4:
   v,info,body=self.fields(fs[1],3);self.check_binding(info);child=[fs[0],body]
  elif tag==7 and fs[0]==1:
   vs,info,triggers,body=self.fields(fs[1],4);self.check_binding(info);child=[body]+[x for ts in self.seq(triggers) for x in self.seq(ts)]
  elif tag==5:raise AssertionError('Tcase requires source opening argument')
  return [(p,attrs)]+[a for ch in child for a in self.shape_search(ch)]
 def trivial(self,p):
  tag,fs,ty,attrs=self.term(p)
  if tag==1 and not fs:return True
  if tag==7:
   vs,info,triggers,body=self.fields(fs[1],4);self.check_binding(info);return self.trivial(body)
  if tag==4:
   v,info,body=self.fields(fs[1],3);self.check_binding(info);return self.trivial(body)
  if tag==8 and fs[0]==5:return self.trivial(fs[2])
  assert tag!=5
  return False
 def goal(self,task,chain):
  h,=self.fields(task,1);assert h==chain[0]['head'];td,*_=self.fields(h,6);assert td==chain[0]['tdecl']
  nd,_=self.fields(td,2);dec,=self.fields(nd,1);dnd,_,_=self.fields(dec,3);prop,=self.fields(dnd,1,5)
  kind,symbol,fmla=self.fields(prop,3);assert kind==5
  ident,=self.fields(symbol,1);name,attrs,loc,tag=self.fields(ident,4)
  locbody=list(self.fields(self.fields(loc,1)[0],3)) if loc!=1 else None
  return symbol,ident,self.string(name),locbody,fmla

def project():
 start=time.monotonic();results={};maps={};summaries={};identities={};members={}
 sha=lambda b:hashlib.sha256(b).hexdigest()
 certificate_path='docs/evidence/retained-why-goal-revalidation-20261020/goal-certificate.json'
 certificate=json.loads((ROOT/certificate_path).read_text());identities[certificate_path]=sha((ROOT/certificate_path).read_bytes())
 for case in CASES:
  archive=ROOT/'docs/evidence/retained-why-save-state-capture-20261020'/('capture-'+case.replace('_','-')+'.tar.gz')
  prefix=('inline/' if case=='input_is_valid' else 'registration/')+case+'/capture/'
  identities[str(archive.relative_to(ROOT))]=sha(archive.read_bytes())
  with tarfile.open(archive) as t:
   blobs={n:t.extractfile(prefix+n).read() for n in ['session-forest.json','session-task-chains.json','session-blocks.jsonl','session-tables.json','process.json']}
   members[case]={prefix+n:sha(b) for n,b in blobs.items()}
   forest=json.loads(blobs['session-forest.json'])['visits'];chains=json.loads(blobs['session-task-chains.json']);tables=json.loads(blobs['session-tables.json']);process=json.loads(blobs['process.json'])
   assert not any(x in process['argv'] for x in ['--limit-line','--limit-lines','--limit-region','--logging','-j','--replay'])
   for flag,value in [('--proof','per_check'),('--counterexample','off'),('--prover','cvc5,z3,altergo'),('--steps','0'),('--timeout','0')]:
    assert process['argv'][process['argv'].index(flag)+1]==value
   g=Graph(blobs['session-blocks.jsonl'])
  proofnodes={(e['key']-1)//2:e['value'] for e in tables['proof_nodes']['entries']}
  transnodes={(e['key']-1)//2:e['value'] for e in tables['transformations']['entries']}
  roots=[v for v in forest if v['root']];assert len(roots)==1
  root=roots[0];assert root['goal']==0 and not root['detached']
  _,_,_,_,root_trans=g.fields(root['proof_node'],5)
  tids=g.seq(root_trans);assert len(tids)==1
  tid=(tids[0]-1)//2
  tname,targs,children,tparent,detached=g.fields(transnodes[tid],5)
  assert g.string(tname)=='split_goal_wp_conj' and targs==1 and detached==1
  assert (tparent-1)//2==root['goal']
  assert {(x-1)//2 for x in g.seq(children)}=={v['goal'] for v in forest if not v['root']}
  oldgoals={r['goal']:r for r in certificate[case]['goals']}
  rows=[]
  for v in forest:
   symbol,ident,name,loc,fmla=g.goal(v['task'],chains[str(v['task'])]);visits=g.shape_search(fmla);attrs=[a for _,ls in visits for a in ls]
   assert oldgoals[v['goal']]['proposition']==symbol and oldgoals[v['goal']]['formula']==fmla
   assert proofnodes[v['goal']]==v['proof_node']
   nameptr,expl,parent,pas,transformations=g.fields(v['proof_node'],5)
   assert not v['detached']
   if not v['root']:
    assert transformations==1
    parent_tid,=g.fields(parent,1,0);assert (parent_tid-1)//2==tid
   labels=[s for s in attrs if s.startswith('GP_Check:')];trivial=g.trivial(fmla)
   ck=None
   for _,aset in visits:
    for a in aset:
     if a.startswith('GP_Check:'):
      parts=a.split(':');ck={'id':int(parts[1]),'kind':parts[2],'source_location':':'.join(parts[3:])}
    if ck is not None and ck['kind']=='VC_LOOP_INVARIANT':
     for a in aset:
      if a.startswith('expl:'):ck['kind']='VC_LOOP_INVARIANT_INIT' if a=='expl:loop invariant init' else 'VC_LOOP_INVARIANT_PRESERV'
   assert v['root'] or trivial or ck is not None
   rows.append(dict(goal=v['goal'],root=v['root'],symbol=symbol,ident=ident,name=name,location_words=loc,formula=fmla,
                    trivial=trivial,check_labels=labels,check=ck,already_proved='GP_Already_Proved' in attrs))
  results[case]=rows
  selected=[x for x in rows if not x['root'] and x['check_labels'] and not x['already_proved']]
  groups={}
  for x in selected:
   key=(x['check']['id'],x['check']['kind']);groups.setdefault(key,[]).append(x)
  mappings=[]
  for key,group in sorted(groups.items()):
   for rank,row in enumerate(sorted(group,key=lambda x:x['goal'],reverse=True)):
    mappings.append({'goal':row['goal'],'check_id':key[0],'check_kind':key[1],'root_index':rank,'source_location':row['check']['source_location'],'trivial':row['trivial']})
  assert len({(x['check_id'],x['check_kind'],x['root_index']) for x in mappings})==len(mappings)
  assert len({x['symbol'] for x in rows})==1
  maps[case]=mappings
  summaries[case]={'raw_goals':len(rows),'registered':len(selected),'nontrivial_registered':sum(not x['trivial'] for x in selected),'checks':len(groups),'shared_name':rows[0]['name'],'distinct_raw_proposition_objects':1,'checked_bindings':len(g.bindings),'captured_pid':process['pid']}
 return {'raw-goal-labels.json':results,'fixed-root-map.json':maps,
         'projection-inputs.json':{'files':identities,'members':members},
         'cases':summaries,'elapsed_seconds':time.monotonic()-start}
if __name__=='__main__':
 result=project()
 for name in ['raw-goal-labels.json','fixed-root-map.json','projection-inputs.json']:
  assert result[name]==json.loads((HERE/name).read_text()), name
 assert result['cases']==json.loads((HERE/'projection-result.json').read_text())['cases']
 print(json.dumps({'cases':result['cases'],'elapsed_seconds':result['elapsed_seconds'],'status':'PASS'}))
