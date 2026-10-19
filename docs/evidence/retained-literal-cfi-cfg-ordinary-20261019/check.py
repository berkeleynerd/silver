#!/usr/bin/env python3
"""Focused boundary, source-attachment and non-ownership checks only."""
import argparse
import copy
from datetime import datetime, timezone
import importlib.util
import json
from pathlib import Path
import platform
import time

HERE=Path(__file__).resolve().parent
spec=importlib.util.spec_from_file_location('ordinary_cfi_cfg', HERE/'derive.py')
d=importlib.util.module_from_spec(spec)
spec.loader.exec_module(d)


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--gcc-source',required=True)
    args=parser.parse_args()
    started=datetime.now(timezone.utc).isoformat(); tick=time.perf_counter()
    checks=[]
    def check(name, value):
        if not value:
            raise AssertionError(name)
        checks.append(name)
    def rejects(name, call, text):
        try:
            call()
        except ValueError as ex:
            check(name, text in str(ex))
        else:
            raise AssertionError('did not reject '+name)

    verification=d.verify_inputs(args.gcc_source)
    accepted=d.read(d.EVIDENCE/'retained-literal-mem-ssa-attachment-20261019/result.json')
    pools=d.read(d.EVIDENCE/'retained-literal-shared-bitmap-pools-20261019/result.json')
    raw=(d.REPO/'samples/hello_world.adb').read_bytes()
    def attach(a=accepted,p=pools,r=raw,path=None,launch=None):
        return d.attach(r,a,p,accepted['source_path'] if path is None else path,
                        accepted['launch'] if launch is None else launch)
    result=attach();result['input_verification']=verification
    check('retained Hello source and counts',result['source']==accepted['source'] and
          result['source_counts']==accepted['source_counts'])
    check('all local predicates are true booleans',all(type(v) is bool and v for v in
          result['local_representation_checks'].values()))
    check('Hello trace backing 2312',result['CFI']['trace_each_backing_bytes_upper']==2312)
    check('Hello ordinary trace hash upper 13',result['hashes'][0]['slots_upper']==13)
    check('Hello expansion label-map upper 13',result['hashes'][1]['slots_upper']==13)
    check('Hello head-end backing 104',result['expansion']['head_end_backing_bytes_upper']==104)
    check('Hello jump nreg backing 416',result['jump']['register_array_bytes_upper']==416)
    check('Hello signed use bound 81',result['jump']['signed_usage_magnitude_upper']==81)
    check('Hello traversal inline no heap',result['CFG']['traversal_heap_request_bytes_upper']==0)
    check('loop iterator inline16 no heap',result['CFG']['root_loop_iterator_inline_capacity']==16
          and result['CFG']['root_loop_iterator_heap_requests']==0)
    check('ET owner retained exactly',result['retained_owners']['shared_bitmap_and_ET']==pools['dominance'])
    check('ordinary and GGC domains separate',all(result[k]==0 for k in
          ('new_GGC_events','new_scalar_registrations','new_array_registrations',
           'new_shared_bitmap_or_ET_pool_blocks')))
    check('no aggregate memory or lifetime total',result['aggregate_ordinary_bytes'] is None and
          result['lifetime_ordinary_request_total'] is None and not result['aggregate_RAM_gate'])
    check('no broad completion claim',not any(result[k] for k in
          ('complete_all_ordinary_helper_lifetimes_closed','complete_native_capacity',
           'complete_collector_lifetime_closed','whole_literal_pipeline_capacity_established',
           'production_admission_changed')))

    cases=[(1,0),(1,1),(1,4),(1,5),(1,10),(1,11),(1,12),(1,19),(1,20),
           (2,0),(20,31),(34,64),(1000,1000),(10**6,10**6),
           ((d.I32-17)//64,0),((d.I32-17)//64+1,0),
           (1,(d.I32-27)//5),(1,(d.I32-27)//5+1),
           (1,(d.I32//4-10)//2),(1,(d.I32//4-10)//2+1),
           (d.U32,d.U32),(d.I64,d.I64)]
    arithmetic_rows=[]
    for c,n in cases:
        row=d.arithmetic(c,n)
        check('arithmetic conjunction '+str((c,n)),
              row['conditional_named_ordinary_container_capacity_established']==
              all(row['local_representation_checks'].values()) and
              row['failed_predicates']==[k for k,v in row['local_representation_checks'].items() if not v])
        arithmetic_rows.append(dict(C=c,N=n,fits=row['conditional_named_ordinary_container_capacity_established'],
                                    failed=row['failed_predicates']))

    # Enumerate the actual retained growth recurrence, independently of the
    # closed-form upper bound; finite tests do not replace its induction proof.
    vector_boundary=[]
    capacity=16
    for logical in range(1,2049):
        old=capacity
        if logical>capacity:
            capacity=capacity*3//2
        require=capacity<=d.trace_capacity(logical)
        if not require:
            raise AssertionError('trace growth recurrence '+str(logical))
        if old!=capacity:
            vector_boundary.append(dict(logical=logical,old=old,actual=capacity,
                                        upper=d.trace_capacity(logical)))
    check('2048 trace lengths cover actual recurrence',True)
    for t,expected in ((16,16),(17,24),(24,34),(25,36)):
        check('trace bound at '+str(t),d.trace_capacity(t)==expected)
    for n,expected in ((4,0),(5,344)):
        check('CFG inline boundary N='+str(n),
              d.arithmetic(1,n)['CFG']['traversal_heap_request_bytes_upper']==expected)

    hash_boundaries=[]
    for prime in d.PRIMES[:-1]:
        for demand in (prime,prime+1):
            p=d.next_prime(demand)
            check('hash prime demand '+str(demand),p>=demand and
                  not any(q>=demand and q<p for q in d.PRIMES))
            hash_boundaries.append(dict(demand=demand,prime=p))
    check('prime table exhausted',d.next_prime(d.PRIMES[-1]+1) is None)
    check('largest usable probe prime',d.hash_bound('boundary',2147483647,0,8)['checks']['probe_addition_unsigned'])
    check('last table prime violates probe addition',not d.hash_bound('boundary',4294967291,0,8)['checks']['probe_addition_unsigned'])
    check('hash missing prime fails safely',not d.hash_bound('boundary',2**64,0,8)['fits'])
    h=d.hash_bound('boundary',13,d.U32//8,16)
    check('hash too-empty unsigned limit',h['checks']['entry_count_and_too_empty_unsigned'])
    check('hash too-empty unsigned next',not d.hash_bound('boundary',13,d.U32//8+1,16)['checks']['entry_count_and_too_empty_unsigned'])
    # Simulate insertion-only tables, including growth before each insertion.
    for count in (0,1,5,6,7,9,10,11,13,16,31,100,1000):
        p=d.next_prime(13)
        for live in range(count):
            if p*3<=live*4:
                p=d.next_prime(live*2)
        check('insertion-only map growth '+str(count),p<=d.hash_bound('test',13,count,16)['slots_upper'])
    for c in ((d.I32-17)//64,(d.I32-17)//64+1):
        check('jump signed usage boundary '+str(c),
              d.arithmetic(c,0)['local_representation_checks']['jump_signed_usage_counter_magnitude']==
              (64*c+17<=d.I32))
    for n in ((d.I32-27)//5,(d.I32-27)//5+1):
        check('jump signed ndead boundary '+str(n),
              d.arithmetic(1,n)['local_representation_checks']['jump_signed_deleted_instruction_count']==
              (27+5*n<=d.I32))
    huge=d.arithmetic(d.I64,d.I64)
    for key in ('CFI_vector_individual_span','expansion_head_end_individual_span',
                'maybe_local_decls_individual_span','jump_register_array_individual_span',
                'CFG_traversal_individual_spans','dominance_individual_spans'):
        check('individual request overlarge '+key,huge['local_representation_checks'][key] is False)

    rejects('zero calls',lambda:d.arithmetic(0,0),'literal C/N domain')
    rejects('boolean call count',lambda:d.arithmetic(True,0),'literal C/N domain')
    rejects('negative null count',lambda:d.arithmetic(1,-1),'literal C/N domain')
    rejects('same counts different bytes',lambda:attach(r=raw.replace(b'Hello',b'HELLO')),
            'same physical Main identity')
    rejects('wrong source path',lambda:attach(path=accepted['source_path']+'x'),'accepted Main source path')
    for bad in (b'\x00',b'\x0b',b'\x0c',b'\x80'):
        rejects('physical alphabet '+str(bad),lambda bad=bad:d.recognize(raw+bad),
                'selected physical Main alphabet')
    for name,path in (
        ('core complete counts',('core_result','source_counts','maximum_literal_length')),
        ('core shape owner',('core_result','RTL_shape','CFI_traces_upper')),
        ('MEM chronology owner',('selected_native_MEM_counter_lifetime','RTL','final_first_unused_pseudo_upper')),
        ('CFI label owner',('selected_native_MEM_counter_lifetime','emission_counter_endpoints','CFI_label_counter_at_exit_upper'))):
        altered=copy.deepcopy(accepted); target=altered
        for key in path[:-1]:target=target[key]
        target[path[-1]]+=1
        rejects(name,lambda altered=altered:attach(a=altered),
                {'core complete counts':'same physical Main identity',
                 'core shape owner':'accepted RTL shape owner',
                 'MEM chronology owner':'accepted MEM/RTL owner',
                 'CFI label owner':'accepted CFI and emission label owners'}[name])
    altered=copy.deepcopy(accepted);altered['conditions'][next(iter(altered['conditions']))]=False
    rejects('failed inherited guard',lambda:attach(a=altered),'accepted inherited guards')
    altered=copy.deepcopy(accepted);altered['core_result']['launch']['native_options'].append('-g')
    rejects('changed selected launch',lambda:attach(a=altered),'accepted selected launch')
    altered=copy.deepcopy(pools);altered['dominance']['live_nodes_combined_upper']+=1
    rejects('ET ownership mutation',lambda:attach(p=altered),'accepted shared ET owner')
    pins=d.read(HERE/'inputs.json');pins['files'][0]['sha256']='0'*64
    rejects('source pin mutation',lambda:d.verify_inputs(args.gcc_source,pins),'changed CFI/CFG input')
    pins=d.read(HERE/'inputs.json');pins['excerpts'][0]['text']='not a retained source excerpt'
    rejects('source excerpt mutation',lambda:d.verify_inputs(args.gcc_source,pins),'missing CFI/CFG source excerpt')

    summary=dict(scope='New CFI/CFG source, arithmetic and frozen-Hello attachment checks',
        checks_passed=len(checks),check_names=checks,count_cases=arithmetic_rows,
        trace_lengths_checked=2048,trace_growth_boundaries=vector_boundary,
        hash_prime_boundary_cases=hash_boundaries,input_verification=verification,
        started_UTC=started,finished_UTC=datetime.now(timezone.utc).isoformat(),
        checker_wall_seconds=time.perf_counter()-tick,
        host=dict(system=platform.system(),release=platform.release(),machine=platform.machine()),
        native_tool_executions=0,predecessor_Context_or_evaluator_calls=0,
        aggregate_or_corpus_executions=0,independent_review_status='pending')
    (HERE/'result.json').write_text(json.dumps(result,indent=2)+'\n')
    (HERE/'check-results.json').write_text(json.dumps(summary,indent=2)+'\n')
    print(json.dumps({k:summary[k] for k in ('checks_passed','checker_wall_seconds','input_verification')},indent=2))


if __name__=='__main__':
    main()
