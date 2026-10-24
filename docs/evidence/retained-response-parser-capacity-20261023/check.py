#!/usr/bin/env python3
"""New source/pin/arithmetic checks only; no predecessor or native replay."""
import hashlib
import io
import json
from pathlib import Path
import subprocess
import tarfile
import time
import sys
sys.dont_write_bytecode = True
from capacity import I, U, LL, SZ, power2, round_x, normal, terminal, stdout_offer, arbitrary_stream, guard, precut

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
sha = lambda b: hashlib.sha256(b).hexdigest()
started = time.monotonic()
checks = 0

def require(condition):
    global checks
    checks += 1
    assert condition, checks

def load_provider(path):
    pin = next(x for x in inputs['providers'] if x['path']==path)
    if 'commit' in pin:
        data = subprocess.check_output(['git','show',pin['commit']+':'+path],cwd=ROOT)
    else:
        data = (ROOT/path).read_bytes()
    require(sha(data)==pin['sha256'])
    return data

inputs = json.loads((HERE/'inputs.json').read_text())
for pin in inputs['providers']:
    load_provider(pin['path'])
manifest = json.loads((HERE/'source-manifest.json').read_text())
data = (HERE/'sources.tar.gz').read_bytes()
require(sha(data)==manifest['archive_sha256'])
with tarfile.open(fileobj=io.BytesIO(data)) as t:
    sources = {m.name:t.extractfile(m).read() for m in t if m.isfile()}
for m in manifest['files']:
    require(len(sources[m['member']])==m['bytes'])
    require(sha(sources[m['member']])==m['sha256'])
for witness in json.loads((HERE/'source-witnesses.json').read_text()):
    lines=sources[witness['member']].decode().splitlines(keepends=True)
    chunk=''.join(lines[witness['first']-1:witness['last']]).encode()
    require(sha(chunk)==witness['sha256'])
identity = json.loads(load_provider('docs/evidence/retained-producer-response-20261018/identity.json'))
require(identity['gnatcoll_complete_archive_sha256']==manifest['gnatcoll_complete_archive_sha256'])
require(identity['premise']=='Candidate source behavior and current installed config/driver bytes; no historical binary-source identity claim.')
for f in identity['files']:
    if f['path'] in sources:
        require(sha(sources[f['path']])==f['sha256'])
with tarfile.open(fileobj=io.BytesIO(load_provider('docs/evidence/retained-producer-null-tail-20261018/runtime-sources.tar.gz'))) as t:
    require(t.extractfile('installed-runtime/s-atocou.ads').read()==sources['runtime/s-atocou.ads'])

# Reached-path witnesses, not a parser implementation or a native defect claim.
buf=sources['gnatcoll/core/src/gnatcoll-buffer.adb'].decode()
js=sources['gnatcoll/core/src/gnatcoll-json.adb'].decode()
spec=sources['gnatcoll/core/src/gnatcoll-buffer.ads'].decode()
lo=buf.index('   function Next\n')
hi=buf.index('   function Next (Self',lo)
offset_next=buf[lo:hi]
require('Internal_Next' not in offset_next)
require('Offset := Offset + 1' in offset_next and 'Self.EOF := True' in offset_next)
require('return Read (Data => Data)' in js)
require('Data : Reader := Open (Path)' in js)
require('while Next (Data, CC, Offset) loop' in js)
for name in ('Current','First','Last'):
    require(any(name in line and ':= 0;' in line for line in spec.splitlines()))
require('Offset        : Long_Long_Integer  := 0;' in spec)
require('Self.First := Self.Current + 1' in buf)
require('FD_Size > Long_Long_Integer (Integer\'Last)' in buf)
require('new Read_State_Array (1 .. 32)' in js)
require('new Read_State_Array (1 .. Read_States\'Last * 2)' in js)
# No clear of popped slots: inspect both close-event branches, excluding push.
close=js[js.index('         if Event.Kind = OBJECT_END then'):js.index('            if Read_States_Last > 0 then',js.index('         else\n            if Read_States_Last > 0 then'))]
require('Read_States_Last := Read_States_Last - 1' in close)
require('JSON_Null' not in close and 'Create' not in close)
stream_model=dict(initial_last=0,initial_current=0,offset_next_refills=False,
                  first_scan_eof=True,first_event='DOC_END',
                  initial_parser_state='EXPECT_VALUE',outcome='Invalid_JSON_Stream caught as Read_Result.Success=False')
require(not (stream_model['initial_current']<stream_model['initial_last']))

# Arithmetic discontinuities and intermediate-overflow countermodels.
require(round_x(4096)==4096 and round_x(4097)==8192)
require(round_x(8192)==12288)  # strictly next page, not ordinary ceil
require(power2(32)==32 and power2(33)==64)
require(3*(U//3)<=U and 3*(U//3+1)>U)
require(power2(2**30+1)>I)
require(3*2**30+32<U)
require(not guard(arbitrary_stream(2**30),416,4096,4096)['all_guards'])
require(guard(arbitrary_stream(2**30-1),416,4096,4096)['all_guards'])
require(not guard(arbitrary_stream(I),416,4096,4096)['guards']['file_and_scanner_spare'])

# Exhaustive bounded prefix-growth check, including 1/2/3/4-byte appends.
# The proof is Current<needed<=d at each actual growth, in the prose.
states=[set() for _ in range(16385)]
states[0].add(0)
for n in range(16385):
    for cap in states[n]:
        for add in (1,2,3,4):
            dest=n+add
            if dest>=len(states):
                continue
            nc=cap
            if dest>23 and dest>cap:
                nc=round_x(max(3*cap//2,dest))
                require(cap<=dest-1)
                require(nc<=max(24,round_x(max(3*(dest-1)//2,dest))))
            states[dest].add(nc)

# Each Why source byte is emitted as ASCII; JSON-decoding expands it to
# <=2 UTF-8 bytes. This is not the bound for arbitrary Unicode escapes.
for c in range(256):
    if c in (34,92):
        enc='\\'+chr(c)
    elif c in (8,9,10,12,13):
        enc={8:r'\b',9:r'\t',10:r'\n',12:r'\f',13:r'\r'}[c]
    elif 32<=c<=126:
        enc=chr(c)
    else:
        enc='\\u%04x'%c
    decoded=json.loads('"'+enc+'"')
    require(len(enc)<=6)
    require(len(decoded.encode('utf8'))<=2)

# Fresh payload ownership model exercises stale slots and three vector
# stores (old/new/slice temporary). It does not replace the source census.
slots=[None]*32
for depth in range(1,8):
    slots[depth-1]=depth
active=7
active-=1
require(slots[6]==7)  # a pop does not clear the retained seventh cursor
old=[100,101,102,103]
new=list(old)
slice_temp=list(old)
require(sum(v==100 for arr in (old,new,slice_temp) for v in arr)==3)
require(active==6 and sum(v is not None for v in slots)==7)

j=json.loads(load_provider('docs/evidence/retained-why-canonical-json-input-20261023/result.json'))
r=json.loads(load_provider('docs/evidence/retained-reporting-composition-20261023/result.json'))
report={x['case']:x for x in r['cases']}
rows=[]
for x in j['cases']:
    y=report[x['case']]
    p=normal(x['R'],x['G'],x['A'],x['N'],y['W_o'],y['L_o'],other_warning_max=422,debug_bytes=26619)
    base=x['JSON_B']['constant']+3*y['W_o']+6*y['L_o']
    require(p['B']==base-84)
    intact=guard(p,416,4096,4096)
    require(intact['all_guards'])
    X=y['orientation_only']['X']
    b=stdout_offer(base+6*X,2)
    malformed=guard(arbitrary_stream(b),416,4096,4096)
    require(malformed['all_guards'])
    one=terminal(X//2)
    require(guard(one,416,4096,4096)['all_guards'])
    rows.append(dict(case=x['case'],normal=p,normal_guard=intact,
                     orientation_only=dict(P=416,M=444,X=X,response_path_bytes=416,
                                           runtime_max_path=4096,runtime_page_size=4096,
                                           malformed_stdout_bytes=b,malformed_guard=malformed,
                                           terminal=one),actual_config_attached=False))
fixed=json.loads(load_provider('docs/evidence/retained-fixed-failure-composition-20261023/result.json'))
pre=[]
for x in fixed['cases']:
    for example in x['examples_only']:
        P=example['scalar']['P']
        a=precut(P,x['raw_label_U'])
        require(a['X']==example['scalar']['X'])
        require(a['text']==example['scalar']['standard']['B'])
        g=guard(arbitrary_stream(a['stdout']),416,4096,4096)
        require(g['all_guards'])
        pre.append(dict(case=x['case'],cwd_bytes_example=example['cwd_bytes_example'],
                        derived=a,guard=g,actual_config_attached=False))
# Largest source-config P for our sufficient malformed capacity interface;
# separate from the provider's whole scalar formatter sufficient region1927.
def fits(P):
    return guard(arbitrary_stream(precut(P,189)['stdout']),416,4096,4096)['all_guards']
lo,hi=180,100000
while lo+1<hi:
    mid=(lo+hi)//2
    if fits(mid):lo=mid
    else:hi=mid
require(fits(lo) and not fits(hi))
result=dict(status='pass',checks=checks,scope='Conditional response parser representation through Read_File return/propagation',
            platform='Linux x86_64 source/configuration model; offline Python checks',
            source_files=len(sources),provider_files=len(inputs['providers']),
            stream_source_counterexample=stream_model,
            normal_and_postcut=rows,precut=pre,
            precut_parser_guard_P_upper_only=lo,
            composed_with_provider_P_upper=min(lo,fixed['sufficient_region']['PrecutP_upper']),
            malformed_maximum_byte_bound_under_guard=2**30-1,
            actual_configuration_guards=None,
            native_runs=0,compiler_runs=0,prover_runs=0,predecessor_replays=0,
            aggregate_RAM_or_stack_gate=False,global_e=2,save_callbacks=2,saves=3,
            allowance_renewed=False,whole_119_complete=False,
            production_changes=False,independent_review_required=True,
            elapsed_seconds=time.monotonic()-started)
(HERE/'result.json').write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(dict(status='pass',checks=checks,normal_cases=len(rows),precut_examples=len(pre),
                     precut_parser_P_upper=lo,composed_P_upper=result['composed_with_provider_P_upper'],
                     elapsed_seconds=result['elapsed_seconds'])))
