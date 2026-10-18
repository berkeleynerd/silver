#!/usr/bin/env python3
"""Focused offline graph, identity, checksum-family and regression checks."""
import argparse
from copy import deepcopy
from datetime import datetime, timezone
import json
from pathlib import Path
import re
import runpy
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
api = runpy.run_path(str(HERE/'compose.py'))
started = datetime.now(timezone.utc).isoformat()
t0 = time.perf_counter()
context = api['Context']()
build, identify = api['build'], api['identity']
source = (REPO/'samples/hello_world.adb').read_bytes()
base = build(source, context)
checks = 0


def check(ok, reason):
    global checks
    if not ok: raise AssertionError(reason)
    checks += 1


def rejects(fn, reason):
    try: fn()
    except ValueError: check(True, reason)
    else: raise AssertionError('accepted '+reason)


by_role = {row['role']:row for row in base['processes']}
graph = base['graph']; obj = graph['native']['cwd']; main = graph['Main']
check(set(by_role)=={'Main_compile','binder_generate','binder_compile','link'}, 'closed native job set')
check(base['fixed_Silver_compile_jobs']==base['GPR_or_Gprbind_jobs']==0, 'no regeneration route')
check(not base['proof_library_verification_waived'], 'proof library requirements persist')
check(len(graph['project_root'])==109 and len(obj)==113 and len(graph['binder_body'])==127,
      'accepted path class')
check(len(graph['native']['assembly'].rsplit('/',1)[0])==48, 'common TMPDIR')
check(all(binding==dict(path=main,identity=identify(source))
          for binding in base['common_Main_bindings'].values()), 'same bytes and Main path')
check(by_role['Main_compile']['argv'].count('-fsplit-wide-types')==1 and
      by_role['binder_compile']['argv'].count('-fsplit-wide-types')==1, 'native split propagation')
check(by_role['Main_compile']['argv'][-4:]==[main,'-o','main~1.o','-gnateI1'], 'indexed Main routing')
check(by_role['Main_compile']['assembler_argv'][1:4]==['--64','-o','main~1.o'], 'Main GAS argv')
check(by_role['binder_compile']['assembler_argv'][1:4]==['--64','-o','b__main~1.o'], 'binder GAS argv')
check(by_role['binder_generate']['argv'][3]==graph['native_Main_ALI'], 'actual ALI binder edge')
check(by_role['binder_compile']['argv'][-3:]==['b__main~1.adb','-o','b__main~1.o'], 'generated binder edge')
for role in ('Main_compile','binder_compile'):
    check(by_role[role]['cwd']==obj and by_role[role]['environment']['TMPDIR']==
          graph['native']['assembly'].rsplit('/',1)[0], role+' common paths')
files = {row['role']:row for row in base['materialization']}
check(files['naming']['identity']['bytes']==327 and files['naming']['path'].endswith('.TMP'),
      'indexed TMP naming has no configuration dependency')
map_lines = files['source_mapping']['text'].splitlines()
check(len(map_lines)==12 and len(set(map_lines[::3]))==4 and
      all(Path(path).parent==Path(graph['project_root']) for path in map_lines[2::3]), 'four exact map bindings')
for name in ('silver_io.ads','silver_io.adb','silver_output_libc.ads'):
    check(files[name]['identity']==identify((REPO/'src'/name).read_bytes()), name+' source correspondence')
    check(files[name]['timestamp']=='20261018061955', name+' coherent selected D timestamp')
for name in ('silver_io.ali','silver_output_libc.ali'):
    check(files[name]['identity']==identify(context.artifacts['options/literal-proposed/obj/'+name]),
          name+' exact selected ALI rather than indexed timestamp variant')
for name in ('silver_io.o','silver_output_libc.o'):
    check(files[name]['identity']==identify(context.artifacts['indexed/obj/'+name]), name+' fixed object')
check(len(base['fixed_ALI_inputs'])==82 and len(base['fixed_link_inputs'])==15,'complete fixed inventories')
for vector in ('argv','collect2_argv','ld_argv'):
    args=by_role['link'][vector]
    objects=['main~1.o','b__main~1.o',obj+'/silver_output_libc.o',obj+'/silver_io.o']
    index=args.index(objects[0]);check(args[index:index+4]==objects, vector+' generated/fixed ordering')
    check(args[args.index('-o')+1]==graph['project_root']+'/bin/main', vector+' output route')
    check(not any(arg.startswith(('@','-plugin')) for arg in args),vector+' no response/plugin')
check(by_role['link']['argv'][1:3]==['-fno-lto','-fno-use-linker-plugin'],'explicit no-plugin driver')
check(len(by_role['link']['collect2_argv'])==47 and len(by_role['link']['ld_argv'])==46,'argv sizes')
check(any('$ORIGIN' in arg for arg in by_role['link']['argv']) and
      not any('\\$ORIGIN' in arg for arg in by_role['link']['argv']), 'literal dollar without display escape')
check([s for s in by_role['link']['collect2_argv'] if s.startswith('-L')][:2]==['-L'+obj+'/']*2,
      'both local search roles rebound')
for x in base['ordered_library_resolution']:
    check(x['selected'] in [r['path'] for r in base['fixed_link_inputs']], 'selected fixed input '+x['library'])
family=base['binder_object_family']
check(family['identity_is_variable'] and not family['equals_captured_fixture'] and
      'sha256' not in family['interface'],'no variable-object fixture equality')
check(family['GGC_rounded_bytes_upper']==5167732 and family['GGC_events_upper']==56378 and
      family['GGC_largest_rounded_request']==262144,'accepted checksum lifetime bound')
baseline_ali=context.artifacts['indexed/obj/main~1.ali']
baseline_spec=context.spec
checksum_values=[0,1,2**15-1,2**31-1,2**31,2**32-1,*range(1073676290,1073676304)]
for value in checksum_values:
    ali=re.sub(rb'(?m)(^U main%b\s+main\.adb\s+)[0-9a-f]{8}',
               lambda m:m[1]+f'{value:08x}'.encode(),baseline_ali)
    bound=api['binder_source_from_ali'](ali,base,context)
    check(bound['Main_checksum']==value and len(bound['spec'])==19920,'binder uint32 binding')
    normalize=lambda x:re.sub(rb'(?<=u00001 : constant Version_32 := 16#)[0-9a-f]{8}',b'00000000',x)
    check(normalize(bound['spec'])==normalize(baseline_spec),'only Main checksum declaration varies')
    check(len(bound['body'])==10316 and len(bound['body'])<=10343,'shortened trailing comments')
rejects(lambda: api['binder_source_from_ali'](b'U main%b main.adb garbage\n',base,context),'bad checksum')
rejects(lambda: api['binder_source_from_ali'](baseline_ali+baseline_ali,base,context),'duplicate Main checksum')
rejects(lambda: build(source,context,path_bytes=127),'insufficient complete pathname bound')
rejects(lambda: build(source,context,host_page_bytes=3),'non-power-of-two host page')
for root in ['/tmp/short','/tmp/'+('x'*103),'relative/'+('x'*100),'/tmp/'+('x'*100)+' bad']:
    rejects(lambda root=root:build(source,context,runtime=dict(cwd=root,
            binder_temporary_root=graph['native']['assembly'].rsplit('/',1)[0])),'invalid runtime root')
for raw in [b'', b'procedure Main is begin null; end Main;', source.replace(b'Put_Line',b'Unknown'),
            source+b'\v', source+b'garbage']:
    rejects(lambda raw=raw:build(raw,context),'outside complete selected source family')
# The graph structure depends on source/configuration, never historical program
# execution. Changes in recognized counts re-evaluate the interface formulas.
for count in [1,2,17,5000]:
    raw=(b'with Silver_IO; procedure Main is pragma SPARK_Mode(On); begin '+
         b'Silver_IO.Put("a"); null; Silver_IO.Put_Line("");'*count+b'end Main;')
    result=build(raw,context)
    check(result['source_identity']==identify(raw) and result['source_counts']['output_calls']==2*count,
          'actual variable source counts')
    check(result['processes']==base['processes'],'source-independent argv graph')
    check(result['binder_object_family']==family,'checksum family not fixture checksum')
check(base['link_interface']['selected_literal_assembler_and_linker_representation_fits'],'hello selected arithmetic')
check(base['selected_native_launch_graph_computable'] and not base['production_launcher_adopted'] and
      not base['whole_literal_pipeline_capacity_established'],'design/production/whole capacity distinction')
result=dict(status='passed',focused_checks=checks,started_UTC=started,
            finished_UTC=datetime.now(timezone.utc).isoformat(),elapsed_seconds=time.perf_counter()-t0,
            repository_inputs=context.input_count,complete_retained_sources=len(context.sources),
            installed_configuration_inputs=len(context.installed_inputs),native_tool_executions=0,
            production_admission_changed=False,whole_literal_pipeline_capacity_established=False)
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output',type=Path,required=True)
args=parser.parse_args();args.output.write_text(json.dumps(result,indent=2)+'\n')
print(json.dumps(result))
