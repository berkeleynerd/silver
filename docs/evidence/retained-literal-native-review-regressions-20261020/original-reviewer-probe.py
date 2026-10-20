from pathlib import Path
from copy import deepcopy
from datetime import datetime, timezone
from types import SimpleNamespace
import ast, hashlib, json, os, platform, runpy, subprocess, time
R=Path.cwd();H=R/'docs/evidence/retained-literal-native-completion-20261019';S=R/'tmp/native-review'
os.environ['TMPDIR']=str(S)
t0=time.perf_counter();start=datetime.now(timezone.utc).isoformat();n=0;negative=0

def ck(v,why):
 global n
 assert v,why
 n+=1

def rejects(fn,why):
 global negative
 try:fn()
 except ValueError:ck(True,why);negative+=1
 else:raise AssertionError(why)

owned=[R/'docs/research/retained-literal-native-completion.md',R/'docs/evidence/retained-literal-binder-completion-20261019/compose.py',*sorted(H.iterdir())]
for p in owned:
 if p.suffix=='.py':ast.parse(p.read_text())
 if p.suffix=='.json':json.loads(p.read_bytes())
 ck(p.read_bytes()==subprocess.check_output(['git','show','4f29a3bf85:'+str(p.relative_to(R))]),'frozen Git bytes')
a=runpy.run_path(str(H/'compose.py'))
tool=Path('/home/canto/src/github.com/berkeleynerd/silver/.tools/linux-x86_64/alire/toolchains/gnat_native_16.1.0_9f74f58a')
c=a['Context']('/tmp/silver-backend-compose-20261018/full-source','/tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada',tool/'lib/gcc/x86_64-pc-linux-gnu/16.1.0/plugin/include','/tmp/silver-backend-compose-20261018/gas-source')
s=(b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin\n'+
   b'Silver_IO.Put ("review"); null; Silver_IO.Put_Line ("");\n'+
   b'Silver_IO.Put ("a""b"); Silver_IO.Put_Line ("'+b'Z'*513+b'"); null;\n'+
   b'Silver_IO.Put (""); null; Silver_IO.Put_Line ("tail"); null; Silver_IO.Put ("x");\nend Main;\n')
p=S/'main.adb';p.write_bytes(s)
v=a['evaluate'](R/'docs/evidence/retained-literal-pipeline-20261018/selected-route.json',c,p)
(S/'fresh-result.json').write_text(json.dumps(v,indent=2)+'\n')
r=v['register_result'];parts=v['components'];g=r['predecessor_result']['selected_native_invocation']
ck(v['complete_native_capacity'] and len(v['conditions'])==475,'fresh complete native')
ck(v['source_counts']['output_calls']==7 and v['source_counts']['null_statements']==4,'fresh counts')
ck(v['source_counts']['decoded_literal_lengths']==[6,0,3,513,0,4,1],'fresh literal bytes')
ck(v['source']=={'bytes':len(s),'sha256':hashlib.sha256(s).hexdigest()},'source identity')
for field in ['conditions','conditional_conditions']:
 ck({k:v[field][k] for k in r[field]}==r[field],'all 408 inherited predicates preserved')
 ck(all(type(x) is bool and x for x in v[field].values()),'475 typed computed predicates')
ck(set(v['coverage'])==set(a['STAGES']) and len(v['coverage'])==12 and all(v['coverage'].values()),'complete stage partition')
ck(r['selected_positive_GGC_events_upper']==r['predecessor_result']['selected_positive_GGC_events_upper']+4,'corrected ledger')
ck(len(r['selected_native_GGC_ledger']['owner_rows'])==51,'51 current owners')
rt={'cwd':g['graph']['project_root'],'binder_temporary_root':g['processes'][0]['environment']['TMPDIR']}
g512=c.parent_context.api['build'](s,c.parent_context.invocation,runtime=rt,path_bytes=512)
ck(g512==dict(g,path_bytes=512),'single scalar bound difference')
ck(g['path_bytes']==513 and r['complete_path_bound']==512,'units retained')
ck(parts['parent']['invocation_identity']==parts['driver']['invocation_identity']==a['identity'](json.dumps(g512,sort_keys=True,separators=(',',':')).encode()),'child complete graph identity')
ck([p['role'] for p in g512['processes']]==['Main_compile','binder_generate','binder_compile','link'],'four explicit jobs')
ck(g512['fixed_Silver_compile_jobs']==g512['GPR_or_Gprbind_jobs']==0,'no hidden regeneration')
ck(len(g512['materialization'])==12,'complete initial inputs')
ck(all(parts[k]['source_identity']==v['source'] for k in ['parent','driver','binder']),'all processes same raw source')
ck(parts['Ada']['source']==v['source'],'Ada same source')
sh=parts['compiler_shells'];bc=parts['binder_compiler']
ck([x['actual_argc'] for x in sh['processes']]==[23,20],'actual compiler counts')
ck([x['theme'] for x in sh['processes']]==['ASCII','emoji'],'distinct actual themes')
for x in sh['processes']:
 d=x['individual_requests'];ck(d['original_argv_pointers']==208 and d['decoded_option_array_each']==2400,'25 argv storage')
 ck(d['saved_optimization_vector']==4808 and d['reconstructed_GNAT_C_argv']==408,'vector and reconstructed argv')
 ck(d['diagnostic_option_classifier']==10224 and d['coverage_filename']==1031,'fresh gnat1 diagnostics and path buffers')
# Independent growth trajectory instead of evaluating the candidate formula.
e=56378;cap=4
while cap<e:cap=cap*2 if cap<16 else cap*3//2
ck(cap<=bc['finalizer_capacity'] and bc['finalizer_capacity']==84565,'finalizer actual growth dominated')
ck(bc['page_pointer_capacity']==65536 and bc['individual_requests']['page_pointer_each']==524288,'page rounding')
ck(bc['individual_requests']['scalar_finalizer']==1353048 and bc['individual_requests']['array_finalizer']==2706088,'independent finalizer requests')
ck(bc['first_collection_margin']==75148 and bc['actual_marking_collections']==0,'first-collection theorem joined')
ck(parts['binder_assembler']['assembly_bytes_upper']==31743 and parts['binder_assembler']['maximum_checksum_directive_bytes']==19,'checksum GAS extents')
for k in ['complete_proof_pipeline_capacity','whole_current_grammar_capacity','production_launcher_adopted','production_SPARK_Lean_correspondence_complete','production_admission_changed','Oracle_changed','aggregate_RAM_gate']:
 ck(v[k] is False,'research boundary '+k)
# Fresh simultaneous faults across distant inherited owners; no completion
# context is available on these branches, so accidental evaluation would fail.
minimal=SimpleNamespace(register_schema=c.register_schema,shell_sources_checked=266,manifest=c.manifest)
keys=['native_Main_frontend','native_GGC_','native_completed_outer_','native_completed_LRA_']
selected=[next(k for k in r['conditions'] if k.startswith(prefix)) for prefix in keys]
for field in ['conditions','conditional_conditions']:
 for key in selected:
  for bad in [False,None]:
   q=dict(r);q[field]=dict(r[field]);q[field][key]=bad
   out=a['attach'](q,s,minimal)
   ck(out['complete_native_capacity'] is False and out[field][key] is bad and out['components']=={} and all(x is None for x in out['coverage'].values()),'failure precedes all completion joins')
for field in ['conditions','conditional_conditions']:
 for bad in [1,0,'true']:
  q=dict(r);q[field]=dict(r[field]);q[field][selected[0]]=bad
  rejects(lambda q=q:a['attach'](q,s,minimal),'nonboolean predicate')
# Exact graph mutations beyond the author suite's role/count samples.
for field in ['materialization','frontend','binder_family','fixed_children','temporary_edge']:
 q=deepcopy(r);x=q['predecessor_result']['selected_native_invocation']
 if field=='materialization':x['materialization'][0]['identity']['sha256']='0'*64
 elif field=='frontend':x['processes'][0]['child_frontend']['argv_positions_upper']=24
 elif field=='binder_family':x['binder_object_family']['interface']['file_bytes_upper']+=1
 elif field=='fixed_children':x['fixed_Silver_compile_jobs']=1
 else:x['processes'][2]['assembler_argv'][-1]+='x'
 rejects(lambda q=q:a['attach'](q,s,c),'changed whole graph '+field)
# Late status/guard injection challenges all newly joined consumers. The public
# source API remains immutable; these are deliberately synthetic fault tests.
def fault_api(group,method,field,value,stage):
 original=getattr(c,group)[method]
 def replacement(*args,**kwargs):
  out=deepcopy(original(*args,**kwargs));out[field]=value;return out
 getattr(c,group)[method]=replacement
 try:
  out=a['attach'](r,s,c)
  ck(out['complete_native_capacity'] is False and out['coverage'][stage] is value,'late nontrue stage '+stage)
 finally:getattr(c,group)[method]=original
for value in [False,None]:
 fault_api('parent','evaluate','selected_parent_design_capacity_fits',value,'input_materialization_and_parent')
 fault_api('driver','evaluate','driver_and_collect2_shell_capacity_closed_under_documented_source_projection',value,'GCC_drivers_and_collect2')
 fault_api('ada','apply','complete_selected_Ada_frontend_capacity',value,'Main_Ada_frontend')
 fault_api('shells','compiler_shells','capacity_established',value,'gnat1_common_shells_startup_and_exit')
 fault_api('shells','binder_compiler','capacity_established',value,'binder_compiler')
 orig=c.assembler_context.result;c.assembler_context.result=deepcopy(orig)
 c.assembler_context.result['conditional_binder_assembler_capacity']=value
 try:
  out=a['attach'](r,s,c);ck(out['complete_native_capacity'] is False and out['coverage']['binder_assembler'] is value,'late GAS status')
 finally:c.assembler_context.result=orig
# Known source/compiler threshold/counter mismatches cannot be passed as families.
checksum=r['predecessor_result']['core_result']['accepted_output_binder_checksum']
for key in ['allocation_event_bound','maximum_rounded_request_bound','universal_rounded_GGC_bytes_bound_subject_to_reviewed_source_projection']:
 q=deepcopy(checksum);q[key]+=1;rejects(lambda q=q:c.shells['binder_compiler'](g512,q),'changed checksum theorem')
q=deepcopy(c.shell_inputs);q['lifecycle']['GCC_owned_init_entries']=8
rejects(lambda:c.shells['compiler_shells'](g512,parts['driver'],q),'driver roots cannot substitute for gnat1')
q=deepcopy(c.shell_inputs);q['registry']['pass_instances_upper']=393
rejects(lambda:c.shells['compiler_shells'](g512,parts['driver'],q),'changed registry')
result={'status':'passed','checks':n,'rejected_exceptions':negative,'started_UTC':start,'finished_UTC':datetime.now(timezone.utc).isoformat(),'elapsed_seconds':time.perf_counter()-t0,'source':v['source'],'counts':{'C':7,'N':4,'literal_lengths':[6,0,3,513,0,4,1]},'current_GGC_events':r['selected_positive_GGC_events_upper'],'conditions':len(v['conditions']),'stages':len(v['coverage']),'repository_inputs':len(c.manifest['repository']),'compiler_shell_sources':c.shell_sources_checked,'host':platform.platform(),'native_runs':0,'broad_predecessor_replay':False,'author_suite_rerun':False}
(S/'probe-result.json').write_text(json.dumps(result,indent=2)+'\n');print(json.dumps(result,indent=2))
