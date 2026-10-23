"""Reconcile new fixed Ptree captures and compute raw structural envelopes."""
from pathlib import Path
import collections,hashlib,json,struct,tarfile,time
HERE=Path(__file__).resolve().parent
ROOT=HERE.parents[2]
START=time.perf_counter()
def identity(data):return dict(bytes=len(data),sha256=hashlib.sha256(data).hexdigest())
manifest=json.loads((HERE/'archive-manifest.json').read_text())
for name,expected in manifest.items():
 assert identity((HERE/name).read_bytes())=={k:expected[k] for k in ('bytes','sha256')}
 with tarfile.open(HERE/name) as tar:
  assert set(expected['members'])=={m.name for m in tar.getmembers()}
  for path,e in expected['members'].items():assert identity(tar.extractfile(path).read())==e,path
with tarfile.open(HERE/'capture.tar.gz') as tar:
 def read(path):return json.loads(tar.extractfile(path).read())
 plan=read('plan.json'); old=read('origin-plan.json');runs=read('result.json')
 original={c['name']:c for c in old['inputs']}
 for path,expected in plan['file_identities'].items():assert identity(Path(path).read_bytes())==expected,path
 elf=Path(plan['cases'][0]['argv'][0]).read_bytes()
 phoff=struct.unpack_from('<Q',elf,32)[0];phsize,phnum=struct.unpack_from('<HH',elf,54)
 def elf_bytes(vaddr,size):
  for i in range(phnum):
   typ,flags,off,va,pa,filesz,memsz,align=struct.unpack_from('<IIQQQQQQ',elf,phoff+i*phsize)
   if typ==1 and va<=vaddr and vaddr+size<=va+filesz:return elf[off+vaddr-va:off+vaddr-va+size]
  raise AssertionError('unmapped ELF span')
 expected_decls=json.loads((ROOT/'docs/evidence/retained-producer-fixed-context-20261018/result.json').read_text())['inputs']
 results=[]
 for case,run in zip(plan['cases'],runs):
  name=case['name'];assert run['case']==name and run['returncode']==0 and not run['timeout']
  assert case['argv']==original[name]['argv']
  assert identity(tar.extractfile(name+'/'+case['argv'][-1]).read())==original[name]['input']==case['input']
  assert identity(tar.extractfile(name+'/why3.conf').read())==old['file_identities'][original[name]['cwd']+'/why3.conf']
  proc=read(name+'/capture/process.json');summary=read(name+'/capture/summary.json');graph=read(name+'/capture/graph.json')
  assert proc['argv']==case['argv'] and proc['environment']==case['environment']
  assert 'Gnat_ast_to_ptree__read_channel' in proc['stack'] and 'type_mlw_file' in proc['stack']
  assert bytes.fromhex(proc['entry_instruction_bytes'])==elf_bytes(0x6fed10,120)
  assert summary['completed'] and not summary['guard_hits'] and summary['stopped_before_typing']
  assert summary['inferior_calls']==summary['inferior_memory_writes']==0
  nodes={int(k):r for k,r in graph['objects'].items()};memo={};visiting=set();postorder=[];todo=[(graph['root'],False)]
  while todo:
   v,done=todo.pop()
   if v in memo:continue
   if v&1:
    n=(v if v<2**63 else v-2**64)>>1;memo[v]=(0,1,0,0,0,1,abs(n));continue
   r=nodes[v];assert (r['header']&255,r['header']>>10)==(r['tag'],r['words'])
   if r['tag']==252:
    assert len(bytes.fromhex(r['data_hex']))==r['length']<8*r['words']
    memo[v]=(1,0,1,r['length'],r['words'],1,0);postorder.append(v);continue
   assert r['tag']<246 and len(r['fields'])==r['words']
   if not done:
    assert v not in visiting,'cyclic Ptree data';visiting.add(v);todo.append((v,True))
    todo.extend((w,False) for w in r['fields'] if w not in memo)
   else:
    visiting.remove(v);children=[memo[w] for w in r['fields']]
    memo[v]=(1+sum(c[0] for c in children),sum(c[1] for c in children),sum(c[2] for c in children),sum(c[3] for c in children),r['words']+sum(c[4] for c in children),1+max([c[5] for c in children]+[0]),max([c[6] for c in children]+[0]));postorder.append(v)
  assert len(postorder)==len(nodes)==summary['objects']
  weights=collections.Counter({graph['root']:1});positions=collections.Counter()
  for v in reversed(postorder):
   r=nodes[v]
   for w in r.get('fields',[]):
    if not w&1:weights[w]+=weights[v]
   if r['tag']==0 and r['words']==3 and all(w&1 for w in r.get('fields',[])):
    positions[tuple(r['fields'])]+=weights[v]
  def field(v):return nodes[v]['fields']
  def ml_list(v):
   result=[];seen=set()
   while v!=1:
    assert v not in seen;seen.add(v);r=nodes[v];assert r['tag']==0 and r['words']==2
    hd,v=r['fields'];result.append(hd)
   return result
  assert nodes[graph['root']]['tag']==0 and nodes[graph['root']]['words']==1
  modules=ml_list(field(graph['root'])[0]);decl_count=0;decls=[]
  for module in modules:
   assert nodes[module]['tag']==0 and nodes[module]['words']==3
   assert field(module)[1]==1  # native extra field is raw OCaml immediate 1 in every fixed module
   decls.extend(ml_list(field(module)[2]))
  while decls:
   d=decls.pop();decl_count+=1
   if nodes[d]['tag']==13:decls.extend(ml_list(field(d)[3]))
  assert len(modules)==expected_decls[name]['modules'] and decl_count==expected_decls[name]['ptree_declaration_total']
  results.append(dict(case=name,unique_blocks=len(nodes),**dict(zip(['expanded_blocks','expanded_immediates','expanded_string_occurrences','expanded_direct_string_bytes','expanded_words','expanded_depth','maximum_absolute_immediate'],memo[graph['root']])),position_candidate_occurrences=sum(positions.values()),maximum_identical_three_integer_record_occurrences=max(positions.values()),maximum_direct_string_payload=max(r.get('length',0) for r in nodes.values()),native_module_tuple_words=3,native_module_extra_raw_value=1,modules=len(modules),declarations=decl_count,capture_seconds=run['elapsed_seconds']))
result=dict(status='pass',scope='new fixed immutable Ptree raw inputs only; serializer capacity and transfer proof remain separate',cases=results,successful_capture_run='20261023T222412-097c69803446',failed_preparation_run='20261023T222336-b7d60127af41',target_capture_seconds=sum(r['elapsed_seconds'] for r in runs),new_target_captures=5,solver_runs=0,inferior_function_calls=0,inferior_memory_writes=0,successful_capture_replays=0,elapsed_seconds=time.perf_counter()-START)
(HERE/'result.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))
