#!/usr/bin/env python3
"""Check arithmetic boundaries for the source-derived map growth sequence."""
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import runpy
import time

HERE=Path(__file__).resolve().parent
m=runpy.run_path(str(HERE/'derive.py'))
started=datetime.now(timezone.utc).isoformat(); timer=time.perf_counter()
checked=[]


def check(name,value):
    if not value:
        raise AssertionError(name)
    checked.append(name)


identities=m['check_inputs']('/tmp/silver-backend-compose-20261018/full-source',
    '/tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada')
for n in range(1590):
    r=m['derive'](n,2**24)
    expected=0 if n==0 else 1 if n<=256 else 2 if n<=1024 else 3
    check('file population '+str(n),r['additional_GGC_events_upper']==expected
        and r['each_caller_bytes_upper']==[0,8192,32768,131072][expected]
        and r['individual_size_t_products_fit'] and r['map_count_and_index_uint64_fit'])
for lines in (1,2,11,12,255,256,65536,2**24-1,2**24):
    r=m['derive'](1589,lines)
    check('logical lines '+str(lines),r['additional_GGC_events_upper']==3
        and r['highest_location_upper'] < m['PACKED_LIMIT'])
for lines in (2**24+1,2**32-1,2**64):
    r=m['derive'](1589,lines)
    check('out of single-map domain '+str(lines),not r['guards']['one_map_per_file']
        and r['additional_GGC_events_upper'] is None and r['allocation_rows'] is None)
for count,lines in ((True,1),(-1,1),(1590,1),(1,0),(1,True)):
    try:
        m['derive'](count,lines)
    except ValueError:
        check('invalid interface '+str((count,lines)),True)
    else:
        raise AssertionError((count,lines))
r=m['derive'](1589,2**24)
check('independent growth thresholds',[(x['used_before'],x['raw_before_rounding'],x['allocated_map_slots'])
    for x in r['allocation_rows']]==[(0,8192,256),(256,16448,1024),(1024,65600,4096)])
check('conditional and global scope',r['total_GGC_events'] is None
    and r['additional_finalizers_upper']==0 and not r['complete_ordinary_map_lifetime_closed']
    and not r['complete_native_capacity'] and not r['production_admission_changed'])
output=dict(started_utc=started,completed_utc=datetime.now(timezone.utc).isoformat(),
    elapsed_seconds=time.perf_counter()-timer,checks=len(checked),passed=checked,
    complete_source_identities_checked=identities,
    implementation_inputs={name:hashlib.sha256((HERE/name).read_bytes()).hexdigest()
        for name in ('derive.py','check.py','inputs.json')},
    model_effort='Lead live setting unavailable; no model switch claimed',
    token_cost_measurements=None,native_tool_executions=0,
    prior_successful_suites_rerun=False,scope='selected preallocation arithmetic and rejected premises')
(HERE/'check-results.json').write_text(json.dumps(output,indent=2)+'\n')
print(json.dumps({k:output[k] for k in ('checks','elapsed_seconds','native_tool_executions')}))
