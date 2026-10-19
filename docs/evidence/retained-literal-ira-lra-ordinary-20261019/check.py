#!/usr/bin/env python3
"""Focused new storage arithmetic; never executes a predecessor or native tool."""
import argparse
from datetime import datetime, timezone
import importlib.util
import json
from pathlib import Path
import platform
import time

HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('ira_ordinary_storage',HERE/'derive.py')
d=importlib.util.module_from_spec(spec);spec.loader.exec_module(d)


def main():
    ap=argparse.ArgumentParser();ap.add_argument('--gcc-source',required=True)
    args=ap.parse_args();started=datetime.now(timezone.utc).isoformat()
    tick=time.perf_counter();checks=[]
    def check(name,value):
        if not value:raise AssertionError(name)
        checks.append(name)
    def rejects(name,call,reason):
        try:call()
        except ValueError as ex:check(name,reason in str(ex))
        else:raise AssertionError('did not reject '+name)

    verified=d.verify_inputs(args.gcc_source)
    result=d.arithmetic(1,0);result['input_verification']=verified
    result['retained_interface']=d.retained_interface_check()
    check('Hello extents',result['extents']==dict(A=4,K=104,B=10,M=27,U=29,P=64,
                                                 cost_class_insert_attempts_upper=12))
    check('Hello local predicates',all(type(v) is bool and v for v in
                                     result['local_representation_checks'].values()))
    check('Hello frozen GGC owner 47054',
          result['retained_interface']['frozen_GGC_total_preserved']==47054)
    check('Hello sparse request 64',result['sparse_sets']['individual_bytes_upper']==64)
    check('Hello point bitmap request 16',result['dense_point_bitmaps']['individual_bytes_upper']==16)
    check('Hello cost hash 251',result['cost_class_hash']['slots_upper']==251)
    check('one word and at most two constructor opportunities',
          result['lifetimes']['one_word_objects_per_allocno']==1 and
          result['lifetimes']['live_range_constructor_calls_upper']==8)
    check('no invented pressure bound',result['lifetimes']['pressure_sum_upper_per_allocno'] is None)
    requests={r['family']:r for r in result['ordinary_requests']}
    check('target move-table unsigned short request',
          requests['target move table per mode and flavor']['each_request_bytes_upper']==2312)
    check('signed caller request 832',
          requests['cost-class pointer map with signed byte caller']['each_request_bytes_upper']==832)
    check('allocno unknown stride distinguished',result['ordinary_pools'][0]['exact_stride_bytes'] is None)
    check('no aggregate total',result['aggregate_ordinary_bytes'] is None and
          result['lifetime_ordinary_request_total'] is None and not result['aggregate_RAM_gate'])
    for key in ('new_GGC_events','new_scalar_registrations','new_array_registrations',
                'shared_bitmap_or_ET_blocks_recharged'):
        check('separate owner '+key,result[key]==0)
    for key in ('numeric_cost_arithmetic_closed','excess_pressure_arithmetic_closed',
                'outer_IRA_helper_interfaces_closed','all_LRA_ordinary_helpers_closed',
                'complete_all_ordinary_native_capacity','complete_native_capacity',
                'whole_literal_pipeline_capacity_established','production_admission_changed'):
        check('residual remains '+key,result[key] is False)

    # Exact local boundaries are tested even if another independent guard fails.
    caller_c=(d.I32//8-99)//5
    point_n=(d.I32-65)//12
    sparse_c=(d.U32-32)//32
    cases=[(1,0),(1,1),(1,64),(2,0),(34,51),(1000,1000),(10**6,10**6),
           (caller_c,0),(caller_c+1,0),(1,point_n),(1,point_n+1),
           (sparse_c,0),(sparse_c+1,0),(d.U32,d.U32),(d.I64,d.I64)]
    case_rows=[]
    for c,n in cases:
        r=d.arithmetic(c,n);x=r['extents'];g=r['local_representation_checks']
        check('derived extents '+str((c,n)),x['A']==4*c and x['P']==14*c+12*n+50
              and x['K']==99+5*c and x['U']==7*c+5*n+22)
        check('local conjunction '+str((c,n)),r['conditional_named_IRA_allocation_capacity']==
              all(g.values()) and r['failed_predicates']==[k for k,v in g.items() if not v])
        check('no narrowing or wrapping '+str((c,n)),
              requests['cost-class pointer map with signed byte caller']['element_bytes']==8 and
              g['cost_class_pointer_byte_caller_signed']==(8*(99+5*c)<=d.I32))
        case_rows.append(dict(C=c,N=n,local_storage_fits=r['conditional_named_IRA_allocation_capacity'],
                              failed=r['failed_predicates']))
    for c,expected in ((caller_c,True),(caller_c+1,False)):
        r=d.arithmetic(c,0);g=r['local_representation_checks']
        check('signed caller exact boundary '+str(c),g['cost_class_pointer_byte_caller_signed']==expected)
        check('signed caller failure is not size_t overflow '+str(c),g['every_named_ordinary_request_span'])
    for n,expected in ((point_n,True),(point_n+1,False)):
        check('point successor boundary '+str(n),d.arithmetic(1,n)['local_representation_checks']
              ['point_endpoint_and_finish_successor_signed']==expected)
    for c,expected in ((sparse_c,True),(sparse_c+1,False)):
        check('sparse unsigned request boundary '+str(c),d.arithmetic(c,0)['local_representation_checks']
              ['sparse_set_unsigned_request']==expected)

    # Independent recurrence for nonexact va_heap vectors; no enormous allocation.
    cap=0;growth=[]
    for length in range(1,4097):
        old=cap
        if length>cap:cap=4 if cap==0 else max(length,cap*3//2)
        if cap>max(4,2*length):raise AssertionError('preorder induction sample')
        if old!=cap:growth.append(dict(length=length,old=old,capacity=cap))
    check('4096 vector lengths',True)

    # Each observed actual pool stride is <= 256, aligned to eight.  Simulate
    # all such strides and block edges to check the conservative transfer.
    pool_cases=0
    for stride in range(8,257,8):
        q=65528//stride
        for objects in (0,1,q-1,q,q+1,2*q-1,2*q,2*q+1,100000):
            actual_blocks=(objects+q-1)//q
            bound=d.pooled('bounded',objects,stride_upper=256)
            if not (actual_blocks<=bound['retained_blocks_upper'] and
                    actual_blocks*q<=bound['allocated_and_free_slots_upper']):
                raise AssertionError('upper-stride pool transfer')
            exact=d.pooled('exact',objects,stride=stride)
            if exact['retained_blocks_upper']!=actual_blocks or \
               exact['allocated_and_free_slots_upper']!=actual_blocks*q:
                raise AssertionError('exact-stride pool transfer')
            pool_cases+=1
    check('all 32 bounded strides and pool edges',True)
    for stride in (88,32,40):
        q=65528//stride
        check('selected pool edge '+str(stride),
              d.pooled('selected',q,stride=stride)['retained_blocks_upper']==1 and
              d.pooled('selected',q+1,stride=stride)['retained_blocks_upper']==2)

    prime_cases=[]
    for prime in d.PRIMES:
        for demand in (prime,prime+1):
            next_p=next((p for p in d.PRIMES if p>=demand),None)
            check('prime selection '+str(demand),next_p is None or
                  (next_p>=demand and all(p<demand or p>=next_p for p in d.PRIMES)))
            prime_cases.append(dict(demand=demand,selected=next_p))
    # Model pre-hit INSERT calls too.  The bound counts attempted queries;
    # only a miss increments population, and expansion can precede a hit.
    for attempts in (0,1,12,189,190,191,252,1000,10000):
        for hit_every in (0,2,3,5):
            p=251;live=0
            for i in range(attempts):
                if 3*p<=4*live:p=next(q for q in d.PRIMES if q>=2*live)
                if not hit_every or i%hit_every:live+=1
            upper=next(q for q in d.PRIMES if q>=max(200,2*attempts))
            check('hash pre-hit growth '+str((attempts,hit_every)),p<=upper)
    check('largest safe probe prime',2*2147483647-3<=d.U32)
    check('last retained prime probe fails',2*4294967291-3>d.U32)
    huge=d.arithmetic(d.I64,d.I64)
    for key in ('every_named_ordinary_request_span','cost_class_hash_prime_exists',
                'typed_pool_retained_count_fields','cost_class_hash_individual_span'):
        check('large input fails '+key,huge['local_representation_checks'][key] is False)

    for c,n in ((0,0),(True,0),(1,-1),(1,False),(1.0,0)):
        rejects('invalid count '+str((c,n)),lambda c=c,n=n:d.arithmetic(c,n),'literal C/N domain')
    rejects('invalid pool stride',lambda:d.pooled('bad',1,stride=7),'pool stride range')
    pins=d.read(HERE/'inputs.json');pins['files'][0]['sha256']='0'*64
    rejects('mutated source pin',lambda:d.verify_inputs(args.gcc_source,pins),'changed IRA input')
    pins=d.read(HERE/'inputs.json');pins['excerpts'][0]['text']='not a retained IRA excerpt'
    rejects('mutated source excerpt',lambda:d.verify_inputs(args.gcc_source,pins),'missing IRA excerpt')

    summary=dict(scope='New IRA graph/cost/traversal storage arithmetic and read-only fixed-Hello reconciliation',
        checks_passed=len(checks),check_names=checks,count_cases=case_rows,
        vector_lengths_checked=4096,vector_growth_boundaries=growth,
        pool_stride_and_edge_cases=pool_cases,hash_prime_boundary_cases=prime_cases,
        input_verification=verified,started_UTC=started,finished_UTC=datetime.now(timezone.utc).isoformat(),
        checker_wall_seconds=time.perf_counter()-tick,
        host=dict(system=platform.system(),release=platform.release(),machine=platform.machine()),
        native_tool_executions=0,predecessor_evaluator_or_checker_executions=0,
        aggregate_or_corpus_replays=0,actual_source_adapter_created=False,
        source_reachability_argument_is_handwritten=True,independent_review_status='pending')
    (HERE/'result.json').write_text(json.dumps(result,indent=2)+'\n')
    (HERE/'check-results.json').write_text(json.dumps(summary,indent=2)+'\n')
    print(json.dumps({k:summary[k] for k in ('checks_passed','checker_wall_seconds','host','input_verification')}))


if __name__=='__main__':main()
