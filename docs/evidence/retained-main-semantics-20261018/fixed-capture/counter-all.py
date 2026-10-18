import gdb,json
from pathlib import Path
root=Path('/tmp/silver-frontend-fixed-counter-20261018')
scan=json.loads((root/'static-all-tables.json').read_text());hooks=json.loads((root/'decrease-hooks.json').read_text())
static={v:int(k,16) for k,v in scan['targets'].items() if v!='checks__determine_range_cache_n'}
base=int(gdb.parse_and_eval('&uintp__uints__last_val'))-static['uintp__uints__last_val']
inf=gdb.selected_inferior()
def readi_start(address):return int.from_bytes(bytes(inf.read_memory(address,4)),'little',signed=True)
counts={k:dict(positive=0,negative=0,stores=0,initial=readi_start(base+static[k]),latest=None,peak=None) for k in static}
cache_calls={'discrete':0,'real':0};hit_rows=[];events=[];phases=[]
query_rows=[];return_rows=[];coherence={};coherence_failures=[];range_mutations=0
def readp(symbol):return int.from_bytes(bytes(inf.read_memory(int(gdb.parse_and_eval('&'+symbol)),8)),'little')
def node_info(n):
 head=readp('atree__atree_private_part__node_offsets__table')+16*n
 slots=readp('atree__atree_private_part__slots__table');off=readi(head+12)
 return dict(n=n,kind=readi(head)&255,sloc=readi(slots+4*(off+2)),etype=readi(slots+4*(off+4)),raw_header=[readi(head+4*j) for j in range(4)])
def readi(address):return int.from_bytes(bytes(inf.read_memory(address,4)),'little',signed=True)
def signed(v):return (v+2**31)%2**32-2**31
class Store(gdb.Breakpoint):
 def __init__(self,h):
  super().__init__('*'+str(base+h['address']),internal=True);self.h=h;self.count=0
 def stop(self):
  h=self.h;addr=base+static[h['target']];old=readi(addr)
  rhs=int(h['rhs'],0) if h['rhs'].startswith(('0x','-')) or h['rhs'].isdigit() else int(gdb.parse_and_eval('$'+h['rhs']))
  new=signed(rhs if h['operation']=='mov' else old-rhs)
  row=counts[h['target']]
  if row['initial'] is None:row['initial']=old
  row['peak']=max(old,new,row['peak'] if row['peak'] is not None else old)
  row['negative']+=max(0,old-new);row['stores']+=1;row['latest']=new;self.count+=1
  return False
stores=[Store(h) for h in hooks]
def uint_value(code):
 if code==-2100000000:return None
 bias=-2100000000+32768
 if -2099999999<=code<=bias+32767**2:return str(code-bias)
 first=-699999999
 p=readp('uintp__uints__table')+8*(code-first);length=readi(p);loc=readi(p+4)
 assert 1<=length<100000,(code,length)
 digits=bytes(inf.read_memory(readp('uintp__udigits__table')+4*loc,4*length))
 ds=[int.from_bytes(digits[4*j:4*j+4],'little',signed=True) for j in range(length)]
 value=abs(ds[0])
 for d in ds[1:]:value=value*32768+d
 return str(-value if ds[0]<0 else value)
class Return(gdb.FinishBreakpoint):
 def __init__(self,row):super().__init__(gdb.newest_frame(),internal=True);self.row=row
 def stop(self):
  row=self.row;rax=int(gdb.parse_and_eval('$rax'));edx=int(gdb.parse_and_eval('$edx'))
  ok=rax&255;lo=signed(rax>>32);hi=signed(edx);assert ok in (0,1)
  assert row['tag']=='discrete','unexpected real query; reader needs Ureal decoder'
  val=(ok,uint_value(lo),uint_value(hi));key=(row['n'],row['original'],row['valid'])
  if key in coherence and coherence[key]!=val:coherence_failures.append(dict(key=key,earlier=coherence[key],current=val))
  coherence[key]=val;return_rows.append(dict(row,returned=val));return False
class Range(gdb.Breakpoint):
 def __init__(self,sym,tag):super().__init__(sym,internal=True);self.tag=tag
 def stop(self):
  global range_mutations
  cache_calls[self.tag]+=1
  n=int(gdb.parse_and_eval('$edi'));valid=int(gdb.parse_and_eval('$esi'))&255
  original=readi(readp('atree__orig_nodes__tableX')+4*n)
  row=dict(tag=self.tag,valid=valid,original=original,**node_info(n));query_rows.append(row)
  Return(row)
  addr=int(gdb.parse_and_eval('&checks__determine_range_cache_n'))+4*(n%1024)
  if readi(addr)==n:hit_rows.append(dict(row,cache_original=readi(int(gdb.parse_and_eval('&checks__determine_range_cache_o'))+4*(n%1024))))
  inf.write_memory(addr,bytes(4));range_mutations+=1
  return False
Range('checks__determine_range','discrete');Range('checks__determine_range_r','real')
def record(tag):
 for k,v in counts.items():v['positive']=readi(base+static[k])-v['initial']+v['negative']
 row=dict(phase=tag,pools={k:dict(v,position=readi(base+static[k])) for k,v in counts.items()},cache_calls=dict(cache_calls),cache_same_node_entries=len(hit_rows))
 phases.append(row);(root/'all-miss'/'progress.json').write_text(json.dumps(row,indent=2)+'\n');print('POOL_PHASE '+json.dumps(dict(phase=tag,table_positions=len(row['pools']),cache_calls=dict(cache_calls)),sort_keys=True))
def source_map():
 ty=gdb.lookup_type('sinput__source_file_record').strip_typedefs();layout={f.name:(f.bitpos//8,f.type.sizeof) for f in ty.fields()}
 ptr=readp('sinput__source_file__table');last=readi(int(gdb.parse_and_eval('&sinput__source_file__last_val')))
 return dict(record_size=ty.sizeof,fields=layout,rows=[dict(index=i,**{n:readi(ptr+(i-1)*ty.sizeof+layout[n][0]) for n in ('file_name','source_first','source_last','template','instance','inlined_call')}) for i in range(1,last+1)])
class Phase(gdb.Breakpoint):
 def __init__(self,sym,tag,halt=False):super().__init__(sym,internal=True);self.tag=tag;self.halt=halt
 def stop(self):record(self.tag);return self.halt
Phase('frontend','frontend_entry');Phase('cstand__create_standard','standard_entry');Phase('gnat2why__driver__translate_standard_package','before_standard_translation');Phase('why__gen__names__free','before_symbol_free',True)
class Guard(gdb.Breakpoint):
 def __init__(self,sym,halt):super().__init__(sym,internal=True);self.halt=halt;self.count=0
 def stop(self):self.count+=1;return self.halt or self.count>63
backend=Guard('gnat2why__driver__run_gnatwhy3',False);collect=Guard('gnat2why__driver__collect_one_result',True)
def final():
 row=dict(source_map=source_map(),phases=phases,cache_calls=cache_calls,cache_same_node=hit_rows,queries=query_rows,returns=return_rows,coherence_failures=coherence_failures,range_mutations=range_mutations,stores=[dict(h,count=b.count) for h,b in zip(hooks,stores)],backend_calls=backend.count,unexpected_collect=collect.count)
 (root/'all-miss'/'pool-counters.json').write_text(json.dumps(row,indent=2)+'\n')
 print('POOL_FINAL '+json.dumps(dict(phases=[x['phase'] for x in phases],cache_calls=cache_calls,same_node=len(hit_rows),backend_calls=backend.count)))
