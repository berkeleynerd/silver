#!/usr/bin/env python3
"""Focused offline checks of exact joins, bounded state and partial I/O."""
import argparse
from copy import deepcopy
from datetime import datetime, timezone
import json
from pathlib import Path
import runpy
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
api = runpy.run_path(str(HERE/'compose.py'))
started = datetime.now(timezone.utc).isoformat()
t0 = time.perf_counter()
checks = 0


def check(value, reason):
    global checks
    if not value: raise AssertionError(reason)
    checks += 1


def rejects(fn, reason):
    try: fn()
    except (ValueError,UnicodeEncodeError): check(True,reason)
    else: raise AssertionError('accepted '+reason)


context = api['Context']()
source = (REPO/'samples/hello_world.adb').read_bytes()
invocation = context.api['build'](source,context.invocation)
base = api['evaluate'](source,context,invocation=invocation)
check(base['selected_parent_design_capacity_fits'] and not base['parent_design_residuals'], 'design closure')
check(not base['production_launcher_adopted'] and
      not base['production_SPARK_GNATprove_Lean_correspondence_complete'], 'production obligations persist')
check(not base['whole_literal_pipeline_capacity_established'], 'component scope')
check(base['observed_graph_extents'] == dict(fixed_input_bytes=18998,parent_path_count=28,
      maximum_argv_bytes_including_NUL=1493,maximum_env_bytes_including_NUL=563), 'fresh graph derivation')
check(len(base['generated_outputs']) == 8 and len(base['directories']) == 6, 'closed path ownership')
check([row['role'] for row in base['vectors']] == api['JOB_ROLES'], 'actual four-job order')
check(sum(row['identity']['bytes'] for row in base['initial_files'] if row['role'] != 'Main') == 18998,
      'fixed byte extents')
check(len({row['mtime_seconds'] for row in base['initial_files'] if row['mtime_seconds'] is not None}) == 1,
      'coherent fixed-source timestamps')
check(all(row['mtime_seconds'] is None or row['mtime_seconds'] == 1792304395 for row in base['initial_files']),
      'UTC timestamp arithmetic')
check(base['representation_payload_sum']+base['representation_internal_alignment_allowance'] <= 65536,
      'bounded explicit record representation')

mutations = [
    lambda r:r['materialization'][0]['identity'].__setitem__('bytes',119),
    lambda r:r['materialization'][2].__setitem__('timestamp','20261018061956'),
    lambda r:r['materialization'][6]['identity'].__setitem__('sha256','0'*64),
    lambda r:r['processes'][1]['argv'].__setitem__(3,'fixture-main.ali'),
    lambda r:r['processes'][2]['argv'].__setitem__(-3,'fixture-binder.adb'),
    lambda r:r['processes'][3]['environment'].__setitem__('LD_PRELOAD','injected'),
    lambda r:r['processes'][3]['argv'].__setitem__(14,r['processes'][3]['argv'][14].replace('$ORIGIN','expanded')),
    lambda r:r['processes'].append(deepcopy(r['processes'][0])),
    lambda r:r['processes'][0]['outputs'].pop(),
]
for mutate in mutations:
    changed = deepcopy(invocation)
    mutate(changed)
    rejects(lambda changed=changed:api['evaluate'](source,context,invocation=changed), 'changed selected graph/configuration')
rejects(lambda:api['evaluate'](source+b'--new bytes\n',context,invocation=invocation), 'stale source identity')
for raw in (b'',source.replace(b'Put_Line',b'Unknown'),source+b'\v'):
    rejects(lambda raw=raw:api['evaluate'](raw,context), 'outside recognized literal family')
for count in (1,2,31,3000):
    raw=(b'with Silver_IO; procedure Main is pragma SPARK_Mode(On); begin '+
         b'Silver_IO.Put("a"); null; Silver_IO.Put_Line("");'*count+b'end Main;')
    got=api['evaluate'](raw,context)
    check(got['source_identity']==api['identity'](raw) and got['source_counts']['output_calls']==2*count,
          'actual source attachment')
    check(got['vectors']==base['vectors'] and got['observed_graph_extents']==base['observed_graph_extents'],
          'source-independent parent storage')
    check(got['selected_parent_design_capacity_fits'], 'larger actual input joins')
runtime=dict(cwd='/tmp/'+('r'*104),binder_temporary_root='/tmp/'+('t'*43))
changed=api['evaluate'](source,context,runtime=runtime)
check(changed['directories'][0]==runtime['cwd'] and
      changed['observed_graph_extents']==base['observed_graph_extents'], 'same-width role rebinding')
rejects(lambda:api['evaluate'](source,context,path_bytes=511), 'outside selected path capacity')
rejects(lambda:api['evaluate'](source,context,runtime=dict(cwd='/tmp/short',binder_temporary_root=runtime['binder_temporary_root'])),
        'wrong role width')

vector=api['c_vector']
check(vector(['x'*2047],17,2048)['bytes_including_NUL']==2048, 'arena exact boundary')
check(vector(['']*17,17,2048)['count']==17, 'pointer vector exact boundary')
check(vector(['x'*1023],7,1024)['bytes_including_NUL']==1024, 'environment exact boundary')
for strings,slots,capacity in [(['x'*2048],17,2048),(['']*18,17,2048),(['x\0y'],17,2048),(['é'],17,2048)]:
    rejects(lambda strings=strings,slots=slots,capacity=capacity:vector(strings,slots,capacity), 'unsafe C vector')

start,step,request=api['start_copy'],api['copy_step'],api['copy_request']
for length in (0,1,4095,4096,4097,8193):
    raw=bytes((i*13+7)%256 for i in range(length))
    state=start(length)
    read_position=0
    output=bytearray()
    buffer=b''
    operation=0
    while state['phase'] not in ('done','failed'):
        before=dict(state)
        state=step(state,'eintr')
        check(state==before,'EINTR leaves every copy field unchanged')
        phase=state['phase']
        if phase=='read':
            n=min(request(state),1+(operation*71)%4096)
            buffer=raw[read_position:read_position+n]
            read_position+=n
        elif phase=='write':
            n=min(request(state),1+(operation*37)%4096)
            output.extend(buffer[state['cursor']:state['cursor']+n])
        else:
            n=0
        state=step(state,phase,n)
        check(bytes(output)==raw[:length-state['remaining']], 'actual byte-prefix correspondence')
        check(read_position==length-state['remaining']+state['pending'], 'read/write prefix invariant')
        operation+=1
    check(state['phase']=='done' and bytes(output)==raw,'complete partial-I/O byte replay')

# Exhaust all reachable local states and partial returns for reduced chunks.
# This exercises the general induction; it is not the universal proof itself.
local_states=0
for chunk in range(1,9):
    for length in range(0,2*chunk+2):
        pending=[start(length,chunk)]
        seen=set()
        while pending:
            state=pending.pop()
            key=tuple(state.items())
            if key in seen: continue
            seen.add(key);local_states+=1
            if state['phase'] in ('done','failed'): continue
            check(step(state,'eintr',chunk=chunk)==state,'local interrupted transition')
            check(step(state,'error',chunk=chunk)['phase']=='failed','local external error transition')
            for value in range(request(state,chunk)+1):
                next_state=step(state,state['phase'],value,chunk)
                check(api['copy_invariant'](next_state,chunk),'all local partial returns preserve invariant')
                pending.append(next_state)

for bad in (-1,2**63,True):
    rejects(lambda bad=bad:start(bad), 'invalid source extent')
state=start(api['I64'])
state=step(state,'read',4096)
state=step(state,'write',1)
check(state['remaining']==api['I64']-1 and state['cursor']==1 and state['pending']==4095,
      'signed64 boundary partial write without lifetime addition')
state=step(state,'write',4095)
check(state['remaining']==api['I64']-4096 and state['cursor']==0,'largest extent chunk completes')
tail=dict(length=api['I64'],remaining=1,pending=0,cursor=0,loaded=0,phase='read',failure=None)
tail=step(step(step(tail,'read',1),'write',1),'probe',0)
check(tail['phase']=='done','largest extent final byte and EOF')
check(step(start(1),'read',0)['failure']=='premature_EOF','premature EOF does not launch jobs')
check(step(step(start(1),'read',1),'write',0)['failure']=='zero_write','zero write terminates')
check(step(start(0),'probe',1)['failure']=='unexpected_extra_source_byte','extra source byte fails')
rejects(lambda:step(start(1),'read',2),'oversized OS return checked before narrowing')
rejects(lambda:step(start(1),'read',-1),'negative OS return checked before narrowing')

route=api['start_route']()
for index,pid in enumerate((1,9,999999999,api['I32'])):
    route=api['route_step'](route,'fork',pid=pid)
    check(route['outstanding_pid']==pid and route['next_job']==index,'one positive pid_t retained')
    check(api['route_step'](route,'eintr')==route,'interrupted wait has no retry counter')
    route=api['route_step'](route,'wait',pid=pid,status=0)
check(route['phase']=='done' and route['next_job']==4 and route['outstanding_pid']==0,'four exact sequential jobs')
rejects(lambda:api['route_step'](route,'fork',pid=1),'no fifth job')
for pid in (0,-1,api['I32']+1):
    rejects(lambda pid=pid:api['route_step'](api['start_route'](),'fork',pid=pid),'invalid parent PID')
waiting=api['route_step'](api['start_route'](),'fork',pid=7)
rejects(lambda:api['route_step'](waiting,'fork',pid=8),'no second concurrent parent child')
rejects(lambda:api['route_step'](waiting,'wait',pid=8,status=0),'no unrelated child completion')
for status in (1,9,127,256,255*256,api['I32']):
    stopped=api['route_step'](waiting,'wait',pid=7,status=status)
    check(stopped['phase']=='failed' and stopped['next_job']==0,'failure/signal never advances graph')
check(api['route_step'](waiting,'error')['outstanding_pid']==7,'wait error preserves outstanding ownership')
check(api['route_step'](api['start_route'](),'error')['phase']=='failed','fork failure is terminal')

report=dict(status='passed',focused_checks=checks,exhaustive_reduced_copy_states=local_states,
            started_UTC=started,finished_UTC=datetime.now(timezone.utc).isoformat(),
            elapsed_seconds=time.perf_counter()-t0,native_platform='linux-x86_64',
            actual_source='samples/hello_world.adb',source_identity=api['identity'](source),
            native_tool_executions=0,production_admission_changed=False,
            production_launcher_adopted=False,whole_literal_pipeline_capacity_established=False)
parser=argparse.ArgumentParser(description=__doc__)
parser.add_argument('--output',type=Path,required=True)
args=parser.parse_args()
args.output.write_text(json.dumps(report,indent=2)+'\n')
print(json.dumps(report))
