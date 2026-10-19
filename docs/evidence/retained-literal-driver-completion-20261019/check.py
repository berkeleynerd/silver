#!/usr/bin/env python3
"""Focused offline checks; no native compiler, disassembler or broad replay."""
import argparse
from copy import deepcopy
from datetime import datetime, timezone
import json
from pathlib import Path
import re
import runpy
import tarfile
import time

H=Path(__file__).resolve().parent
R=H.parents[2]
a=runpy.run_path(str(H/'compose.py'))
t0=time.perf_counter(); started=datetime.now(timezone.utc).isoformat()
c=a['Context'](); evaluate=a['evaluate']; identify=a['identity']; n=0

def check(ok,why):
    global n
    if not ok: raise AssertionError(why)
    n+=1

def rejects(fn,why):
    try: fn()
    except ValueError: check(True,why)
    else: raise AssertionError('accepted '+why)

raw=(R/'samples/hello_world.adb').read_bytes()
g=c.api['build'](raw,c.join)
b=evaluate(raw,c,invocation=g)
check(b==json.loads((H/'result.json').read_bytes()),'retained current result equality')
check(b['source_identity']==identify(raw),'actual source identity')
check(b['driver_source_or_object_content_reads']==0 and b['selected_driver_GGC_events']==0,'driver read projection')
check(not any(b[k] for k in ('aggregate_RAM_or_parent_arena_used_as_child_bound','production_launcher_adopted',
    'SPARK_or_Lean_correspondence_established','whole_native_pipeline_capacity_established')),'scope boundaries')
check(b['remaining_driver_capacity_obligations']==[],'documented local closure')
by={r['role']:r for r in b['drivers']}
for role,count,inputs,cap in [('Main_compile',14,1,30),('binder_compile',12,1,30),('link',9,12,67)]:
    p=by[role]
    check(p['argv_positions']==17 and len(p['retained_switches'])==count and len(p['input_records'])==inputs,role+' input partition')
    check(p['argbuf']['capacity']==cap and p['switch_request']==384 and p['infile_request']==512,role+' current capacity')
    check(p['separated_operand_pointer_request']==16 and p['decoded_option_request']==1632,role+' output/decoded requests')
    check(p['strings']['temp_name']==60 and p['jobserver']['largest_string_value']==71,role+' fixed string delta')
    check(p['jobserver']['largest_string_value']==len('jobserver is not available: '+'%<MAKEFLAGS%> environment variable is unset'),role+' jobserver literal length')
    check(p['diagnostic']['option_classifier_requested_bytes']==0,role+' fresh zero-options classifier')
    check(p['largest_partial_obstack_object']<=a['I32'] and p['largest_obstack_chunk']+15<=a['I64'],role+' chunk arithmetic')
check(b['multilib']['retained_match_array']==360 and b['configured_compiler_records_including_sentinel']==83,'fixed-table current substitution')
check(by['Main_compile']['frontend']['argv_positions_exact_from_source']==23 and
      by['Main_compile']['frontend']['argv_positions_accepted_upper']==25,'actual vs conservative frontend count')
check(by['Main_compile']['frontend']['argv'][3:7]==['-dumpbase','main~1.adb','-dumpbase-ext','.adb'],'output-derived dumpbase')
check(by['Main_compile']['frontend']['argv'][-3]==g['graph']['Main'],'same actual Main compiler input')
check(by['binder_compile']['frontend']['frontend_theme']=='emoji' and by['Main_compile']['frontend']['frontend_theme']=='ASCII','LANG-specific frontend theme')
check(by['Main_compile']['frontend']['environment_entries']==10 and by['binder_compile']['frontend']['environment_entries']==6,'generated frontend environments')
with tarfile.open(R/'docs/evidence/retained-binder-options-20261018/artifacts.tar.gz') as tar:
    witness=json.loads(tar.extractfile('output/capture/frontend-exec.json').read())
f=by['binder_compile']['frontend']
check(f['argv'][1:-1]==witness['argv'][1:-1],'source-expanded binder argv matches retained spelling/order')
check(f['environment']['COLLECT_GCC_OPTIONS']==witness['environment']['COLLECT_GCC_OPTIONS'],'source-expanded collected binder options')
check(set(f['environment'])==set(witness['environment']),'binder environment key root')
co=b['collect2']
for slots,request in [('first_ld_write_slots_upper','first_ld_pointer_request'),('second_ld_write_slots_upper','second_ld_pointer_request'),
                      ('input_object_write_slots_upper','input_object_pointer_request'),('unused_C_write_slots_upper','unused_C_pointer_request')]:
    check(co[slots]*8<=co[request],slots+' fits own allocation')
check(co['argv_positions']==47 and co['ld_argv_positions']==46 and co['diagnostic']['owned_urlifier_vector']==0,'current collect2 shell')
check([(r['GCC_initializer_roots'],r['GCC_static_registrations'],r['GCC_destructor_targets']) for r in b['static_lifecycle']]==[(8,30,9),(4,3,3)],'separate executable roots')
# Actual recognized variants must preserve only the source-independent driver
# projection, while identities and counts are freshly recomputed.
for count in [1,2,17,127,5000]:
    source=(b'with Silver_IO; procedure Main is pragma SPARK_Mode(On); begin '+
            b'Silver_IO.Put("a"); null; Silver_IO.Put_Line("");'*count+b'end Main;')
    result=evaluate(source,c)
    check(result['source_identity']==identify(source) and result['source_counts']['output_calls']==2*count,'actual source variant')
    check(result['drivers']==b['drivers'] and result['collect2']==b['collect2'],'source-independent driver read projection')
    check(result['invocation_identity']!=b['invocation_identity'],'source-bound invocation identity changes')
for source in [b'',raw+b'garbage',raw.replace(b'Put_Line',b'Unknown'),raw+b'\v']:
    rejects(lambda source=source:evaluate(source,c),'nonmember raw source')
rejects(lambda:evaluate(raw.decode(),c),'source text instead of actual bytes')
# Each supplied descriptor must be the whole accepted graph, including source.
mutations=[]
for index in [0,2,3]:
    q=deepcopy(g);q['processes'][index]['argv'].append('-pipe');mutations.append(q)
    q=deepcopy(g);q['processes'][index]['environment']['MAKEFLAGS']='--jobserver-auth=3,4';mutations.append(q)
    q=deepcopy(g);q['processes'][index]['environment']['GLIBCXX_TUNABLES']='glibcxx.eh_pool.obj_count=1';mutations.append(q)
q=deepcopy(g);q['source_identity']['sha256']='0'*64;mutations.append(q)
q=deepcopy(g);q['processes'][0]['child_frontend']['argv_positions_upper']=24;mutations.append(q)
q=deepcopy(g);q['processes'][3]['collect2_argv'].append('-plugin');mutations.append(q)
q=deepcopy(g);q['materialization'][0]['identity']['bytes']+=1;mutations.append(q)
for q in mutations:rejects(lambda q=q:evaluate(raw,c,invocation=q),'changed invocation/source/materialization')
old_runtime=json.loads((R/'docs/evidence/retained-null-pipeline-20261018/fixture.json').read_bytes())['runtime']
rt={k:old_runtime[k] for k in ['cwd','binder_temporary_root']}
for char in ['x','_', '~']:
    new={k:v.replace('w',char).replace('t',char) if k=='cwd' else v[:-1]+char for k,v in rt.items()}
    # Prefix replacements preserve width, normalization and the accepted alphabet.
    result=evaluate(raw,c,runtime=new)
    check(result['drivers'][0]['frontend']['argv_positions_exact_from_source']==23,'accepted same-width path variant')
    check(result['drivers'][0]['strings']==by['Main_compile']['strings'],'path-width arithmetic invariant')
for bad in ['relative','/tmp/short',rt['cwd'][:-1]+' ',rt['cwd'][:-1]+'%',rt['cwd'][:-1]+"'"]:
    rejects(lambda bad=bad:evaluate(raw,c,runtime=dict(rt,cwd=bad)),'invalid path projection')
for demand in range(0,257):
    v=a['vector'](demand)
    check(v['capacity']>=demand and v['request_bytes']==8+8*v['capacity'],'vector growth boundary')
for size in [0,1,15,16,100,2902,3109,4095,4096,8192,33282,a['I32']]:
    check(a['chunk'](size)>=size and a['chunk'](size)+15<=a['I64'],'individual obstack object boundary')
for bad in [-1,1.5,True,a['I32']+1]:
    rejects(lambda bad=bad:a['vector'](bad),'invalid vector demand')
    rejects(lambda bad=bad:a['chunk'](bad),'invalid partial object')
# Spec syntax, selected helper counts and empty named routes are independently
# checkable structure facts supporting the handwritten interpreter projection.
check(c.specs['link_command'].count('%:sanitize(')==9,'nine selected sanitizer predicates')
check(c.specs['post_link']=='' and c.specs['asm_final'].startswith('%{gsplit-dwarf:') and c.specs['link_ssp'].endswith(':}'),'selected empty terminal spec guards')
maxdepth=0
for name in ['link_command','link','startfile','endfile','libgcc','link_gcc_c_sequence','lib',
             'asm_options','invoke_as','asm_debug_option','cc1','cc1_cpu']:
    depth=0
    for char in c.specs[name]:
        if char=='{':depth+=1;maxdepth=max(maxdepth,depth)
        elif char=='}':depth-=1
        check(depth>=0,'fixed balanced spec syntax')
    check(depth==0,name+' complete braces')
check(maxdepth==12 and 4*maxdepth+16==64,'conservative selected recursion allowance')
# Detect altered byte windows, callback records and incomplete roots without
# mutating the repository or executing a disassembler.
records=json.loads((H/'lifecycle.json').read_bytes())
for record in records:
    executable=Path(record['path']).read_bytes()
    variants=[]
    q=deepcopy(record);q['roots'].pop();variants.append(q)
    q=deepcopy(record);q['registrations'][0]['destructor']+=1;variants.append(q)
    q=deepcopy(record);q['windows'][0]['hex']='00'+q['windows'][0]['hex'][2:];variants.append(q)
    q=deepcopy(record);q['init_array'][0]+=1;variants.append(q)
    for q in variants:rejects(lambda q=q:a['verify_lifecycle'](q,executable),'lifecycle mutation')
q=deepcopy(c.paths);c.paths=deepcopy(q);c.paths['implicit_specs_candidates'].pop()
rejects(c.verify_specs_absence,'incomplete specs-candidate domain');c.paths=q
check(all(p['returncode']==0 for p in json.loads((R/'docs/evidence/retained-link-no-lto-20261018/capture/result.json').read_bytes())['commands']), 'reused successful no-LTO driver/collect2 witness')
result=dict(status='passed',focused_checks=n,started_UTC=started,finished_UTC=datetime.now(timezone.utc).isoformat(),
    elapsed_seconds=time.perf_counter()-t0,source_files=len(c.sources),repository_inputs=c.repository_pins,
    actual_source_variants=6,native_tool_executions=0,broad_predecessor_replay=False,
    source_argument_and_review_required=True,production_admission_changed=False)
p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output',type=Path,default=H/'checks.json');args=p.parse_args()
args.output.write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result))
