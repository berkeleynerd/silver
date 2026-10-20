"""Read-only GDB observations; every GC/request stops before it executes."""
import gdb, json, struct, hashlib
from pathlib import Path
ROOT=Path(CAPTURE_ROOT)
CODE=Path(COLLECTOR_ROOT)
PLAN=json.loads((ROOT/'plan.json').read_text())
CASE=PLAN['inputs'][CASE_INDEX]
OUT=Path(CASE['cwd'])/'capture'
INF=gdb.selected_inferior()
SUMMARY={'name':CASE['name'],'completed':False,'failures':[],'snapshots':[],
         'guard_hits':[],'startup_guard_hits':[],'protected':False,'new_threads':[],'guards':{},'counter_addresses':{}}
def data(addr,n=8):return bytes(INF.read_memory(addr,n))
def u64(addr):return int.from_bytes(data(addr),'little')
def address(name):return int(gdb.parse_and_eval('(unsigned long)&'+name))
def identity(p):
 b=Path(p).read_bytes();return {'bytes':len(b),'sha256':hashlib.sha256(b).hexdigest()}
def save(): (OUT/'summary.json').write_text(json.dumps(SUMMARY,indent=2)+'\n')
def snapshot(label,native=False):
 state=u64(address('Caml_state'))
 fields={n:(struct.unpack('<d',data(state+v['offset']))[0] if v['type']=='double' else u64(state+v['offset'])) for n,v in PLAN['state_fields'].items()}
 ptr=int(gdb.parse_and_eval('$r15')) if native else fields['young_ptr']
 row={'label':label,'pc':hex(int(gdb.parse_and_eval('$pc'))),'state_address':state,
      'state':fields,'effective_young_ptr':ptr,'minor_allocated_words':(fields['young_alloc_end']-ptr)//8,
      'native_r14':int(gdb.parse_and_eval('$r14')) if native else None,'tables':{}}
 for n in ['caml_allocated_words','caml_gc_phase','caml_extra_heap_resources','caml_dependent_size','caml_dependent_allocated','caml_init_minor_heap_wsz','caml_init_heap_wsz','caml_custom_major_ratio','caml_custom_minor_ratio','caml_custom_minor_max_bsz']:
  addr=address(n);SUMMARY['counter_addresses'][n]=addr
  row[n]=struct.unpack('<d',data(addr))[0] if n=='caml_extra_heap_resources' else (int.from_bytes(data(addr,4),'little') if n=='caml_gc_phase' else u64(addr))
 for n,entry_size in [('ref_table',8),('ephe_ref_table',16),('custom_table',24)]:
  addr=fields[n];vals={k:u64(addr+i*8) for i,k in enumerate(['base','end','threshold','ptr','limit','size','reserve'])}
  vals['entry_size']=entry_size;vals['used_entries']=(vals['ptr']-vals['base'])//entry_size;row['tables'][n]=vals
 SUMMARY['snapshots'].append(row);save();print('SNAPSHOT '+json.dumps({k:row[k] for k in ['label','minor_allocated_words','caml_allocated_words','caml_extra_heap_resources']}),flush=True)
 return row
class Guard(gdb.Breakpoint):
 def __init__(self,name):
  self.label=name;addr=address(name);super().__init__('*'+hex(addr));self.silent=True
  SUMMARY['guards'][name]={'address':addr,'first32':data(addr,32).hex()}
 def stop(self):
  event={'guard':self.label,'pc':int(gdb.parse_and_eval('$pc')),'backtrace':gdb.execute('bt 12',to_string=True)}
  if not SUMMARY['protected']:
   SUMMARY['startup_guard_hits'].append(event);save();return False
  SUMMARY['guard_hits'].append(event)
  SUMMARY['failures'].append('collection/request/override guard: '+self.label)
  try:snapshot('guard:'+self.label)
  except Exception as e:SUMMARY['failures'].append(str(e))
  save();return True
class Phase(gdb.Breakpoint):
 def __init__(self,name,final=False,start=False):
  self.start=start;self.final=final;self.label=name;super().__init__('*'+hex(address(name)));self.silent=True
 def stop(self):
  try:
   row=snapshot('end_of_registration' if self.final else ('before_first_why3_module' if self.start else 'runtime_initialized'),self.final or self.start)
   if self.start:SUMMARY['protected']=True;SUMMARY['baseline']=row;save()
   if self.final:
    s=row['state'];assert row['native_r14']==row['state_address']
    assert s['minor_heap_wsz']==2**28
    assert row['minor_allocated_words'] < s['minor_heap_wsz']
    assert row['caml_allocated_words'] < s['minor_heap_wsz']
    base=SUMMARY['baseline']
    assert all(s[n]==0 for n in ['in_minor_collection','requested_major_slice','requested_minor_gc'])
    assert all(s[n]==base['state'][n] for n in ['stat_minor_words','stat_promoted_words','stat_major_words','stat_minor_collections','stat_major_collections','stat_compactions','stat_forced_major_collections'])
    assert row['caml_gc_phase']==base['caml_gc_phase']
    assert s['young_trigger']==base['state']['young_trigger']
    assert s['extra_heap_resources_minor']<=1 and row['caml_extra_heap_resources']<=1
    for t in row['tables'].values():assert t['ptr']<=t['threshold']
    proc=Path('/proc')/str(INF.pid)
    (OUT/'maps.txt').write_bytes((proc/'maps').read_bytes())
    mapped={}
    for line in (proc/'maps').read_text().splitlines():
     parts=line.split()
     if len(parts)>=6 and parts[-1].startswith('/') and Path(parts[-1]).is_file():mapped[parts[-1]]=identity(parts[-1])
    SUMMARY['mapped_files']=mapped
    capture_fixed_session()
    SUMMARY['completed']=True;save()
  except Exception as e:SUMMARY['failures'].append(type(e).__name__+': '+str(e));save();return True
  return self.final
proc=Path('/proc')/str(INF.pid)
env=dict(s.decode().split('=',1) for s in (proc/'environ').read_bytes().split(b'\0') if s)
assert env==CASE['environment'],env
args=[s.decode() for s in (proc/'cmdline').read_bytes().split(b'\0') if s]
assert args==CASE['argv'],args
(OUT/'process.json').write_text(json.dumps({'pid':INF.pid,'executable':str((proc/'exe').resolve()),'environment':env,'argv':args,'initial_threads':len(INF.threads())},indent=2)+'\n')
for name in PLAN['guards']:Guard(name)
Phase('caml_start_program');Phase(PLAN['protected_start'],start=True);Phase(PLAN['endpoint']['symbol'],True)
for kind in ['fork','vfork','exec']:gdb.execute('catch '+kind)
def new_thread(event):SUMMARY['new_threads'].append(event.inferior_thread.num);save()
gdb.events.new_thread.connect(new_thread)
save()
def finish_capture():
 if not SUMMARY['completed'] and not SUMMARY['failures']:SUMMARY['failures'].append('stopped before endpoint without a handled guard')
 if SUMMARY['new_threads']:SUMMARY['failures'].append('unexpected new thread')
 save()

# Observe the real open64 result inside caml_sys_open. The retained disassembly
# establishes rbp = copied pathname, eax = fd result, ebx = original open flags.
# No inferior calls, writes, FinishBreakpoint, or guessed caller-frame layout.
SUMMARY['file_opens']=[]
class FileOpen(gdb.Breakpoint):
 def __init__(self):
  spec=PLAN['observer'];addr=address(spec['symbol'])+spec['offset']
  super().__init__('*'+hex(addr));self.silent=True
  SUMMARY['file_open_site']={'address':addr,'first32':data(addr,32).hex()}
  assert SUMMARY['file_open_site']['first32']==spec['first32'], 'file-open instruction mismatch'
 def stop(self):
  try:
   frame=gdb.selected_frame()
   ptr=int(frame.read_register('rbp'))
   path=gdb.Value(ptr).cast(gdb.lookup_type('char').pointer()).string(encoding='utf-8',errors='strict')
   raw=int(frame.read_register('eax')) & 0xffffffff
   fd=raw if raw < 2**31 else raw-2**32
   flags=int(frame.read_register('ebx')) & 0xffffffff
   row={'path':path,'fd':fd,'flags':flags,'protected':SUMMARY['protected']}
   if fd>=0:
    link=Path('/proc')/str(INF.pid)/'fd'/str(fd)
    resolved=link.resolve(strict=True)
    row['resolved_path']=str(resolved)
    if flags & 3 == 0 and resolved.is_file():
     row['identity']=identity(link)
     assert str(resolved) in PLAN['file_identities'], 'unpinned read: '+str(resolved)
     assert row['identity']==PLAN['file_identities'][str(resolved)], 'changed read: '+str(resolved)
   SUMMARY['file_opens'].append(row)
   return False
  except Exception as e:
   SUMMARY['failures'].append('file-open observer: '+type(e).__name__+': '+str(e))
   save();return True
FileOpen()
original_finish_capture=finish_capture
def finish_capture():
 if SUMMARY['completed']:
  actual={r['resolved_path'] for r in SUMMARY['file_opens'] if r['fd']>=0 and r['flags'] & 3 == 0}
  missing=set(PLAN['required_overlay_paths'])-actual
  if missing:SUMMARY['failures'].append('overlay paths not opened: '+str(sorted(missing)))
  missing=set(PLAN['selected_driver_closure'].values())-actual
  if missing:SUMMARY['failures'].append('selected driver closure paths not opened: '+str(sorted(missing)))
 original_finish_capture()

# Additional segment boundaries and dispatch guards. All reads are from the
# stopped inferior; no OCaml helper, register write or fabricated return.
SUMMARY['dispatch']={'transform':[],'graft':[],'connection':[]}
SUMMARY['forbidden_calls']={}
def ocaml_string(ptr):
 assert ptr & 1 == 0
 header=u64(ptr-8);assert header & 255 == 252
 words=header>>10;length=8*words-1-data(ptr+8*words-1,1)[0]
 return data(ptr,length).decode('utf-8')
def block_fields(ptr,count):
 assert ptr & 1 == 0
 header=u64(ptr-8);assert header & 255 == 0 and header>>10==count,(hex(ptr),hex(header),count)
 return [u64(ptr+8*i) for i in range(count)]
def list_values(ptr):
 seen=set();values=[]
 while ptr!=1:
  assert ptr not in seen,'cyclic list';seen.add(ptr)
  head,ptr=block_fields(ptr,2);values.append(head)
 return values
def task_shape(ptr):
 seen=set();decls=[]
 while ptr!=1:
  node=block_fields(ptr,1)[0]
  assert node not in seen,'cyclic task chain';seen.add(node)
  fields=block_fields(node,6);decls.append(fields[0]);ptr=fields[1]
 return {'chain_length':len(decls),'declaration_addresses':decls}
class PreviousEndpoint(gdb.Breakpoint):
 def __init__(self):
  super().__init__('*'+hex(address(PLAN['previous_endpoint']['symbol'])));self.silent=True
 def stop(self):
  try:
   row=snapshot('before_server_and_split',True)
   SUMMARY['previous_endpoint_visits']=SUMMARY.get('previous_endpoint_visits',0)+1
   assert SUMMARY['previous_endpoint_visits']==1
   save();return False
  except Exception as e:
   SUMMARY['failures'].append('previous endpoint: '+repr(e));save();return True
class Dispatch(gdb.Breakpoint):
 def __init__(self,label,spec):
  self.label=label;addr=address(spec['symbol']);assert data(addr,32).hex()==spec['first32']
  super().__init__('*'+hex(addr));self.silent=True
 def stop(self):
  try:
   frame=gdb.selected_frame();reg=lambda n:int(frame.read_register(n))
   row={'pc':reg('pc')}
   if self.label=='transform':
    row.update(name=ocaml_string(reg('rax')),argument_count=len(list_values(reg('rdi'))),input_task=task_shape(reg('rcx')))
    assert row['name']=='split_goal_wp_conj' and row['argument_count']==0
   elif self.label=='graft':
    row.update(name=ocaml_string(reg('rdi')),argument_count=len(list_values(reg('rsi'))),tasks=[task_shape(t) for t in list_values(reg('rdx'))])
    assert row['name']=='split_goal_wp_conj' and row['argument_count']==0
   else:
    row.update(socket_name=ocaml_string(reg('rax')))
    assert row['socket_name']==CASE['server']['socket']
   SUMMARY['dispatch'][self.label].append(row);save();return False
  except Exception as e:
   SUMMARY['failures'].append('dispatch '+self.label+': '+repr(e));save();return True
class Forbidden(gdb.Breakpoint):
 def __init__(self,name,spec):
  self.name=name;addr=address(name);assert data(addr,32).hex()==spec['first32']
  super().__init__('*'+hex(addr));self.silent=True
  SUMMARY['forbidden_calls'][name]={'address':addr,'first32':data(addr,32).hex(),'hits':0}
 def stop(self):
  SUMMARY['forbidden_calls'][self.name]['hits']+=1
  SUMMARY['failures'].append('unexpected scheduling/printing/dispatch: '+self.name);save();return True
PreviousEndpoint()
for label,spec in PLAN['dispatch_observers'].items():Dispatch(label,spec)
for name,spec in PLAN['forbidden_calls'].items():Forbidden(name,spec)
assert data(address(PLAN['endpoint']['symbol']),32).hex()==PLAN['endpoint']['first32']
prior_finish_capture=finish_capture
def finish_capture():
 prior_finish_capture()
 if SUMMARY['completed']:
  assert SUMMARY['previous_endpoint_visits']==1
  assert len(SUMMARY['dispatch']['connection'])==1
  assert len(SUMMARY['dispatch']['transform'])==len(SUMMARY['dispatch']['graft'])>0
  assert not any(r['hits'] for r in SUMMARY['forbidden_calls'].values())
 save()

# R53 endpoint projection: missing metadata and raw logical correspondence only.
import importlib.util
_spec=importlib.util.spec_from_file_location('r53_session',CODE/'inherited-session_observer.py')
_session_module=importlib.util.module_from_spec(_spec);_spec.loader.exec_module(_session_module)
_meta_spec=importlib.util.spec_from_file_location('r53_metadata',CODE/'metadata.py')
_meta_module=importlib.util.module_from_spec(_meta_spec);_meta_spec.loader.exec_module(_meta_module)
def capture_fixed_session():
    global data
    original_read=data
    log=(OUT/'metadata-memory-reads.jsonl').open('w')
    def logged_read(addr,n=8):
        b=original_read(addr,n)
        log.write(json.dumps(dict(address=addr,bytes=n,hex=b.hex()),separators=(',',':'))+'\n')
        return b
    data=logged_read
    checks={}
    for name,spec in PLAN['session_observer']['symbols'].items():
        ptr=address(name);checks[name]={'address':ptr,'elf_value':spec['elf_value']}
        if 'code_hex' in spec:
            got=data(ptr,len(bytes.fromhex(spec['code_hex']))).hex()
            assert got==spec['code_hex'],('session root code mismatch',name)
            checks[name]['code_hex']=got
    bias=address('camlWhy3__Ident')-PLAN['session_observer']['ident_elf_value']
    assert all(row['address']==bias+row['elf_value'] for row in checks.values())
    (OUT/'session-symbols.json').write_text(json.dumps({'load_bias':bias,'checks':checks},indent=2)+'\n')
    session=_session_module.SessionCapture(data,address,OUT,PLAN['session_observer']['limits'])
    try:
        roots=session.capture_roots();assert roots['complete'],roots
        result=session.capture_session();assert result['complete'],result
        meta=_meta_module.Projection(session).collect();assert meta['complete']
        selected=[r for r in meta['drivers'] if r.get('selected')]
        expected=['inline_trivial','eliminate_builtin','remove_unused','detect_polymorphism','eliminate_inductive','eliminate_algebraic_if_poly','eliminate_literal','eliminate_gnatprove_guard_epsilon','eliminate_epsilon','introduce_premises','simplify_formula','discriminate_if_poly','encoding_smt_if_poly']
        assert len(selected)==1 and selected[0]['transformations']==expected
        SUMMARY['metadata']={'complete':True,'identity':identity(OUT/'metadata.json'),'full_Hsdecl_captured':False}
        save()
    finally:
        session.close();log.close();data=original_read
