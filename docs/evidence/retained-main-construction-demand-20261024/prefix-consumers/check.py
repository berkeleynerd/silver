"""Focused new consumer checks. No native or successful predecessor runs."""
import datetime
import hashlib
import importlib.util
import json
import platform
import subprocess
import tarfile
import time
from pathlib import Path

START = time.monotonic()
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
spec = importlib.util.spec_from_file_location('consumers', HERE/'consumers.py')
c = importlib.util.module_from_spec(spec); spec.loader.exec_module(c)
assertions = 0


def ok(condition, label):
 global assertions
 assertions += 1
 if not condition: raise AssertionError(label)

def sha(data): return hashlib.sha256(data).hexdigest()
def read(name): return json.loads((HERE/name).read_text())
def write(name, value): (HERE/name).write_text(json.dumps(value, indent=2)+'\n')

def check_pin(row, data=None):
 data = (ROOT/row['path']).read_bytes() if data is None else data
 ok(len(data)==row['bytes'] and sha(data)==row['sha256'], row['path'])


inputs=read('inputs.json')
for row in inputs['providers'] + inputs['immutable_prior_packets']: check_pin(row)
r=inputs['research_prefix']; b=(ROOT/r['path']).read_bytes()
check_pin(r,b[:r['bytes']])
ok(len(b)>r['bytes'], 'research is append-only')
ret=read('retrieval.json'); data=(HERE/'yojson-3.0.0.tar.gz').read_bytes()
ok(len(data)==ret['bytes'] and sha(data)==ret['sha256'] and ret['http_status']==200,'retrieved source identity')
archives={}; sources={}
for row in read('source-witnesses.json'):
 if row['archive']:
  if row['archive'] not in archives: archives[row['archive']]=tarfile.open(ROOT/row['archive'])
  b=archives[row['archive']].extractfile(row['path']).read()
 else: b=(ROOT/row['path']).read_bytes()
 check_pin(row,b); sources[row['path']]=b.decode(); lines=b.splitlines(True)
 for piece in row['spans']:
  selected=b''.join(lines[piece['first']-1:piece['last']])
  ok(sha(selected)==piece['sha256'] and selected.decode()==piece['text'],row['path']+':'+str(piece['first']))
for archive in archives.values():archive.close()

def src(suffix):
 matches=[v for k,v in sources.items() if k.endswith(suffix)]
 ok(len(matches)==1,'unique source '+suffix)
 return matches[0]

binary=read('binary-version-path.json'); p=Path(binary['accepted_binary']['path']); b=p.read_bytes()
ok(len(b)==binary['accepted_binary']['identity']['bytes'] and sha(b)==binary['accepted_binary']['identity']['sha256'],'same accepted installed image')
needle=binary['needle'].encode()
for offset in binary['offsets']:ok(b[offset:offset+len(needle)]==needle,'version-path byte window')
ok('3.0.0' in binary['needle'], 'family version only')

reader=src('/lib/read.mll'); common=src('/lib/common.ml'); lexing=src('/stdlib/lexing.ml')
for anchor in ['let from_channel ?buf ?fname ?lnum ic =', 'let lexbuf = Lexing.from_channel ic in', 'let v = init_lexer ?buf ?fname ?lnum () in', '`Assoc (List.rev !acc)', '`List (List.rev !acc)', 'let buf_size = 32', 'read_junk_without_positions buf buf_size lexbuf']:
 ok(anchor in reader,'Yojson source '+anchor)
ok('Buffer.create 256' in common and '?(lnum = 1)' in common,'fresh parser owner')
ok('Bytes.create 512' in lexing and 'Bytes.create 1024' in lexing and 'Int.min (2 * Bytes.length lexbuf.lex_buffer)' in lexing,'refill/growth operands')
safe=src('/lib/safe.cppo.ml')
ok(all('#define '+x+'\n' in safe for x in ['INT','INTLIT','FLOAT','STRING']) and '#define FLOATLIT' not in safe and '#include "read.ml"' in safe, 'exact Safe preprocessor selection')
converter=src('/gnat_ast_to_ptree.ml')
ok('let json = Yojson.Safe.from_channel c in' in converter,'actual entrypoint has default options')
ok('let pow2 = BigInt.mul_int 4 exp in' in converter,'base16 stored exponent')
selected=converter.split('let mk_const_of_ureal')[1].split('let curr_attrs')[0]
ok('pow_int' not in selected and 'shift_' not in selected,'no selected exponent expansion')
number=src('/number.ml')
ok('normalize d (BigInt.mul p p) e2' in number,'trial divisor squaring explicitly retained')
ok('if BigInt.eq i BigInt.zero then' in number,'zero bypasses normalize')
ok('let (q,r) as qr = euclidean_div_mod x y' in src('/bigInt.ml'),'signed adjustment included')
fmt=src('/stdlib/format.ml')
for anchor in ['let pp_buffer_size = 512','let pp_infinity = 1000000010','let b = pp_make_buffer () in','let ppf = formatter_of_buffer b in','state.pp_right_total <- pp_infinity','state.pp_right_total <- state.pp_right_total + token.length','pp_left_total = 1','pp_curr_depth = 1']:
 ok(anchor in fmt,'formatter source '+anchor)
ok('Buffer.create 64' in src('/stdlib/printf.ml'),'Printf fresh private buffer')
buf=src('/stdlib/buffer.ml')
ok('while old_pos + more > !new_len do new_len := 2 * !new_len done' in buf,'geometric buffer request')
z=src('/caml_z.c')
for anchor in ['malloc(num_digits+1)','ml_z_alloc(1 + j / (2 * sizeof(mp_limb_t)))','ml_z_alloc(size_arg1 + size_arg2)','ml_z_alloc(size_arg1 - size_arg2 + 1)','#define Z_PERFORM_CHECK 0','#define Z_CUSTOM_BLOCK 1']:
 ok(anchor in z,'numeric request '+anchor)

origin=read('numeric-origins.json'); actual=set()
with tarfile.open(ROOT/origin['archive']) as t:
 for row in origin['snapshots']:
  data=t.extractfile(row['path']).read();check_pin(row,data); s=json.loads(data)
  codes={f['code'] for f in s['numeric_fields'] if f['type']=='urealp__ureal'}
  ok(codes==set(map(int,s['ureals']))=={v['ureal_code'] for v in row['values']}, 'complete numeric provider projection')
  for v in row['values']:
   x=s['ureals'][str(v['ureal_code'])]
   val=[int(s['uints'][str(x['num'])]['value']),int(s['uints'][str(x['den'])]['value']),x['rbase'],x['negative']]
   ok(val==v['tuple'],'origin tuple follows accepted decoded fields');actual.add(tuple(val))
ok(sorted(actual)==[tuple(v) for v in origin['distinct_tuples']], 'all tuple union')
ok(len(origin['snapshots'])==18 and len(actual)==10,'complete 18-snapshot/ten-tuple provider')
ok(all(0<n<1<<64 and abs(d)<=4080 and base in [2,16] and sign in [0,1] for n,d,base,sign in actual),'actual selected operands')
ok('No Main route emits a Ureal.' in (ROOT/'docs/research/retained-producer-numerics.md').read_text(),'Main source induction attachment')
ok('Numeric Why nodes are immutable' in (ROOT/'docs/research/retained-producer-numerics.md').read_text(),'fixed origin stability')

controls=[]
values=sorted({(-n if sign else n) for n,d,base,sign in actual} | {1,-1,(1<<64)-1,-((1<<64)-1),1<<63,-(1<<63),5**27,-(5**27)})
for value in values:
 for prime in [2,5]:
  r=c.normalize_trace(value,prime)
  # Independent repeated-division reference, unlike the source's squaring recursion.
  ref=value; e=0
  while ref%prime==0:ref//=prime;e+=1
  ok((r['value'],r['valuation'])==(ref,e),'normalization independent linear reference')
  ok(e<=63 and abs(ref)<=abs(value),'normalization value/valuation')
  for event in r['trace']:
   if 'p_squared' in event:ok(event['p_squared']<1<<128,'failed-trial divisor bound')
   if 'v' in event:
    ok(abs(event['v'])<=abs(value) and event['p']<1<<128,'all recursive operands')
    # Actual Z.ediv_rem and BigInt.computer_div_mod intermediate signed corrections.
    q,m=c.trunc_divmod(event['v'],event['p'])
    eq,er=(q-1,m+event['p']) if m<0 else (q,m)
    cq,cr=(eq+1,er-event['p']) if event['v']<0 and er!=0 else (eq,er)
    ok((cq,cr)==(q,m),'two signed adjustment layers')
    ok(max(abs(q),abs(m),abs(eq),abs(er),abs(cq),abs(cr))<1<<129,'signed intermediate magnitude')
  controls.append({'input':value,'prime':prime,'value':r['value'],'valuation':e,'max_depth':max(x.get('depth',0) for x in r['trace']),'max_trial_divisor':max(x.get('p',0) for x in r['trace'])})
ok(10**40 < 1<<133,'40 decimal characters supply bits, not exponent value')
ok(1+40//16==3 and 8*(6+3)==72,'actual native requests')
ok(10**18-1 < 1<<62,'small decimal parse path intermediate')

exports={role:c.producer_envelope(role) for role in c.AUXILIARY}
ok(len(exports)==5,'five launch roles')
for role,r in exports.items():
 ok(all(r['guards'].values()),'guards '+role)
 ok(r['Yojson']['file_bytes_including_Close_LF']==(1<<31)-1,'body/file '+role)
 ok(r['Format_Printf_Buffer']['per_call_output_bytes_upper']==1<<37,'format output '+role)
 ok(r['complete_C_to_T_representation_when_joined_to_accepted_prefix_and_auxiliary'] and not r['T_to_builder_transport'],'exact scope '+role)
 ok((r['process_global_exception_allowance'],r['save_entering_callbacks'],r['save_calls'])==(2,2,3),'single allowance '+role)
for data in [b'0\n',b'[]\n',b'{"theory_declarations":[]}\n',b'[]\n\n']:
 r=c.from_serialized_json('put',data)
 ok(r['producer_body_bytes_upper']==len(data)-1 and r['Yojson']['file_bytes_including_Close_LF']==len(data),'strip exactly producer terminal LF')
for args in [('unknown',b'[]\n',c.CONFIGURATION),('put','[]\n',c.CONFIGURATION),('put',b'[]',c.CONFIGURATION),('put',b'\n',c.CONFIGURATION),('put',b'[]\n','other')]:
 try:c.from_serialized_json(*args)
 except ValueError:ok(True,'reject unsupported public input')
 else:ok(False,'reject unsupported public input')
# Geometric inductive boundary controls, no large strings or native parser runs.
for initial,limit in [(256,(1<<31)-1),(1024,(1<<31)-1),(512,1<<37),(64,1<<37)]:
 cap=initial
 while cap<limit:
  required=cap+1; new=2*cap
  ok(new<=max(initial,2*required) and new<1<<62,'one doubling fits')
  cap=new
 ok(cap<=max(initial,2*limit),'final geometric bound')
# Text-only formatter flush: once total>78 the system box has been forced;
# residual tokens are known. Sentinel differences may be negative, still represented.
for length in [0,1,77,78,79,c.PP_INFINITY-1,c.PP_INFINITY,c.PP_INFINITY+1,1<<37]:
 total=length+1
 ok(abs(c.PP_INFINITY-total)<1<<62 and total<1<<62,'large text flush arithmetic')
 for chunks in [[length], [0,0,length,0], [min(77,length),length-min(77,length)]]:
  right=left=1; space=78; queue=[None]; seen=0
  def advance():
   global left,space,seen
   while queue and (queue[0] is not None or right-left>=space):
    token=queue.pop(0)
    if token is not None:
     left+=token; space-=token; seen+=token
  for chunk in chunks:
   right+=chunk;queue.append(chunk);advance()
  ok(not queue or length<78,'system box cannot remain unknown past margin')
  right=c.PP_INFINITY;advance()
  ok(not queue and seen==length and left==length+1,'all text drains even beyond sentinel')

write('exports.json',{'producer_maximum':exports,'normalization_controls':controls})
local_inputs={name:{'bytes':(HERE/name).stat().st_size,'sha256':sha((HERE/name).read_bytes())} for name in ['consumers.py','prepare.py','check.py','inputs.json','source-witnesses.json','numeric-origins.json','binary-version-path.json','retrieval.json','yojson-3.0.0.tar.gz','exports.json']}
result={'status':'passed','assertions':assertions,'elapsed_seconds':time.monotonic()-START,'utc':datetime.datetime.now(datetime.timezone.utc).isoformat(),'platform':platform.platform(),'base_commit':inputs['base_commit'],'new_source_files':len(read('source-witnesses.json')),'source_excerpts':sum(len(r['spans']) for r in read('source-witnesses.json')),'immutable_prior_packet_files':len(inputs['immutable_prior_packets']),'numeric_controls':len(controls),'local_inputs':local_inputs,'native_target_capture_disassembler_compiler_prover_Lean_service_runs':0,'predecessor_checker_runs':0,'claim':'C->T individual representation interface, conditional on exact accepted source/producer/primitive/physical premises; no T->builder or aggregate physical bound'}
write('result.json',result)
print(json.dumps({k:v for k,v in result.items() if k!='local_inputs'},indent=2))
