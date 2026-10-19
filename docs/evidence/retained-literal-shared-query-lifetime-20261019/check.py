#!/usr/bin/env python3
"""Focused query-lifetime interface and source/ownership checks; no native run."""
import argparse
import copy
from datetime import datetime,timezone
import json
from pathlib import Path
import time

from derive import Context,HERE,REPO,I32,U32,evaluate_source,evaluate_default,endpoints,read


def main():
    start=time.monotonic();started=datetime.now(timezone.utc).isoformat()
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gcc-root',type=Path,default=Path('/tmp/silver-backend-compose-20261018/full-source'))
    parser.add_argument('--output',type=Path,default=HERE/'check-results.json')
    args=parser.parse_args();context=Context(args.gcc_root);checks=[]

    def check(name,value):
        if not value:raise AssertionError(name)
        checks.append(name)

    def reject(name,callback):
        try:callback()
        except (ValueError,TypeError):checks.append(name)
        else:raise AssertionError('accepted '+name)

    result=evaluate_default(context)
    check('exact retained source result',result==read(HERE/'result.json'))
    check('same-source corrected history verified',result['same_source_corrected_incoming_history_verified'])
    ids=result['identifier_hash'];counters=result['counter_endpoints'];final=result['scalar_finalizers']
    check('corrected ingress includes indexed System',ids['corrected_incoming_history_upper']==40847)
    check('complete identifier endpoint and capacity',ids['historical_insertions_upper']==40886 and
          ids['allocated_slots_upper']==65536 and ids['each_ordinary_backing_bytes_upper']==524288)
    check('complete tree UID endpoints',counters['next_DECL_UID_upper']==5877 and counters['next_type_UID_upper']==2306)
    check('type hash retains original six lookups and actual allocated state',
          result['type_hash']['occupied_upper']==39263 and result['type_hash']['allocated_slots_upper']==131071 and
          result['type_hash']['additional_insertion_capable_lookups']==6)
    check('integer hash retains original317 lookups',result['integer_hash']['occupied_upper']==39574 and
          result['integer_hash']['allocated_slots_upper']==131071 and
          result['integer_hash']['additional_insertion_capable_lookups']==317)
    check('global declarations retain original nine pushes',result['global_decls']['occupied_upper']==414860 and
          result['global_decls']['allocated_slots_upper']==1048575)
    check('statement cache retains full original432 pushes',result['stmt_list_cache']['occupied_upper']==432 and
          result['stmt_list_cache']['allocated_slots_upper']==1023)
    check('alias graph endpoint includes original sentinel allowance once',
          result['alias_sets']['occupied_upper']==414861 and counters['alias_ID_upper']==414860)
    check('four scalar owners join18 registrations once',sum(r['registrations'] for r in
          result['closed_scalar_control_owners'])==18 and final['historical_registrations_upper']==39275)
    check('scalar allocated state and request ceiling',final['allocated_slots_upper']==58911 and
          final['each_ordinary_backing_bytes_upper']==942584)
    demand=result['later_query_demands']
    check('rooted call-length hit remains an actual lookup',demand['call_length_existing_small_slot_lookups']==1)
    check('later small/large integer mutations are zero',all(demand[k]==0 for k in
          ('integer_hash_lookups','integer_hash_entries','small_integer_cache_writes','small_integer_cache_vectors')))
    check('type and global/list mutation demand zero',all(demand[k]==0 for k in
          ('type_UID_increments','type_hash_lookups','type_hash_entries','global_decls_pushes','stmt_list_cache_pushes')))
    check('new packet recharges no allocation owner',all(result[k]==0 for k in
          ('new_direct_GGC_events','new_shared_GGC_backing_events','new_scalar_registrations',
           'new_ordinary_backing_events','graph14_events_added_again','RTL4C_events_added_again')))
    closed=('complete_identifier_lifetime_closed','complete_DECL_UID_lifetime_closed',
            'complete_type_lifetime_closed','complete_tree_integer_cache_lifetime_closed',
            'complete_alias_lifetime_closed','complete_global_decls_lifetime_closed',
            'complete_stmt_list_cache_lifetime_closed','complete_scalar_finalizer_lifetime_closed')
    check('only selected family lifetimes promoted',all(result[k] for k in closed))
    open_flags=('complete_array_finalizer_lifetime_closed','complete_collector_lifetime_closed',
        'complete_global_counter_lifetime_closed','complete_gimplifier_lifetime_closed',
        'whole_literal_pipeline_capacity_established','production_admission_changed','aggregate_RAM_gate')
    check('other obligations remain open',not any(result[k] for k in open_flags) and result['total_GGC_events'] is None)
    check('handwritten source argument needs review',result['source_reachability_argument_is_handwritten'] and
          result['independent_review_status']=='pending')
    check('no prohibited replay',all(result[k]==0 for k in ('native_tool_executions',
          'accepted_component_suites_rerun','aggregate_executions','corpus_checkers_rerun')))

    raw=(REPO/'samples/hello_world.adb').read_bytes()
    def invoke(packets=None,correction=None,source=raw):
        p=context.defaults if packets is None else packets
        return evaluate_source(source,p['original'],context.correction if correction is None else correction,
            p['named'],p['rtl'],p['graph'],context)
    reject('different source bytes with same counts',lambda:invoke(source=raw+b'\n'))
    for family in ('original','named','rtl','graph'):
        p=copy.deepcopy(context.defaults);p[family]['source']['sha256']='0'*64
        reject('mismatched '+family+' source',lambda p=p:invoke(p))
    changed=copy.deepcopy(context.correction)
    changed['identifier_hash']['incoming_historical_insertions_upper']=40846
    reject('stale uncorrected filename ingress',lambda:invoke(correction=changed))
    for family,key,value in [('original','type_hash',{'allocated_slots_upper':0}),
            ('original','integer_hash',{'additional_insertion_capable_lookups':0}),
            ('original','global_decls',{'incoming_allocated_slots_upper':0}),
            ('original','stmt_list_cache',{'additional_pushes':0}),
            ('named','named_source_demands',{'DECL_UID_increments':0}),
            ('graph','alias_sets',{'occupied_upper':414855})]:
        p=copy.deepcopy(context.defaults);p[family][key].update(value)
        reject('erased incoming/owned '+family+' '+key,lambda p=p:invoke(p))
    p=copy.deepcopy(context.defaults);p['rtl']['additional_control_scalar_registrations_upper']=0
    reject('erased RTL scalar ownership',lambda:invoke(p))
    p=copy.deepcopy(context.defaults);p['graph']['new_scalar_finalizer_registrations_upper']=0
    reject('erased alias child-map registrations',lambda:invoke(p))
    for c,n,d in [(0,0,1),(1,-1,1),(1,0,2),(2,0,3),(True,0,1)]:
        reject('invalid domain '+str((c,n,d)),lambda c=c,n=n,d=d:endpoints(c,n,d,context))
    check('native guard does not silently accept huge C',
          not endpoints(I32,0,1,context)['conditional_selected_shared_capacity_established'])
    check('native guard does not silently accept huge N',
          not endpoints(1,U32,1,context)['conditional_selected_shared_capacity_established'])
    model_cases=0
    for c in (1,2,3,9,100,10000):
        for n in (0,1,100):
            for d in range(1,min(c,2)+1):
                row=endpoints(c,n,d,context);model_cases+=1
                assert row['counter_endpoints']['next_DECL_UID_upper']==5869+5*c+n+3*d
                assert row['counter_endpoints']['next_type_UID_upper']==2295+6*c+5*d
                assert row['identifier_hash']['historical_insertions_upper']==40879+3*c+4*d
                assert row['integer_hash']['occupied_upper']==39257+164*c+16*d+137
                assert row['stmt_list_cache']['occupied_upper']==265+167*c+12*n
                assert row['scalar_finalizers']==final
                assert row['conditional_selected_shared_capacity_established']
    check('source-count transfer matrix',model_cases==33)
    elapsed=time.monotonic()-start
    args.output.write_text(json.dumps(dict(passed=True,checks=len(checks),check_names=checks,
        arithmetic_cases=model_cases,started_utc=started,elapsed_seconds=elapsed,
        source_files_verified=context.source_files,repository_inputs_verified=context.repository_files,
        handwritten_source_argument_independently_reviewed=False,native_tool_executions=0,
        accepted_component_suites_rerun=0,aggregate_executions=0,corpus_checkers_rerun=0),indent=2)+'\n')
    print(json.dumps(dict(passed=True,checks=len(checks),elapsed_seconds=elapsed)))


if __name__=='__main__':
    main()
