#!/usr/bin/env python3
"""Focused source-bound transfer, ownership and endpoint checks; offline only."""
import argparse
import copy
from datetime import datetime, timezone
import json
from pathlib import Path
import tempfile
import time

from derive import (Context,HERE,REPO,I32,U32,identity,read,evaluate_source,
                    identifier_transfer,finalizer_transfer,rtl_hash_transfer,RESIDUALS)


def main():
    start=time.monotonic()
    started=datetime.now(timezone.utc).isoformat()
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gcc-root',type=Path,default=Path('/tmp/silver-backend-compose-20261018/full-source'))
    parser.add_argument('--output',type=Path,default=HERE/'check-results.json')
    args=parser.parse_args()
    context=Context(args.gcc_root)
    checks=[]

    def check(name,value):
        if not value: raise AssertionError(name)
        checks.append(name)

    def reject(name,operation):
        try: operation()
        except (ValueError,TypeError): checks.append(name)
        else: raise AssertionError('accepted '+name)

    raw=(REPO/'samples/hello_world.adb').read_bytes()
    shared,corrected=context.default_shared,context.default_correction
    original=copy.deepcopy((shared,corrected))
    result=evaluate_source(raw,shared,corrected,context)
    check('exact retained actual-source result',result==read(HERE/'result.json'))
    check('predecessors unchanged',original==(shared,corrected))
    check('independent named ownership addition',
          sum(r['identifiers'] for r in result['consumer_rows'])==3 and
          sum(r['DECL_UID'] for r in result['consumer_rows'])==5 and
          sum(r['type_UID'] for r in result['consumer_rows'])==0 and
          sum(r['scalar_finalizers'] for r in result['consumer_rows'])==6)
    projected=result['named_only_projection']
    check('corrected source-sensitive incoming history retained',
          result['incoming_corrected_identifier_state']['historical_insertions_upper']==40883 and
          projected['identifier_hash']['historical_insertions_upper']==40886 and
          projected['identifier_hash']['allocated_slots_upper']==65536)
    check('named UID projection',projected['next_DECL_UID_upper']==5877 and projected['next_type_UID_upper']==2306)
    check('named ordinary finalizer projection',
          projected['scalar_finalizers']['occupied_upper']==39268 and
          projected['scalar_finalizers']['allocated_slots_upper']==58900 and
          projected['scalar_finalizers']['each_ordinary_backing_bytes_upper']==942408)
    check('absent residuals leave endpoints unresolved',
          set(result['unresolved_endpoint_inputs'])==set(RESIDUALS) and
          result['conditional_full_arithmetic_fits'] is None and
          all(result['conditional_full_endpoint'][k] is None for k in
              ('identifier_hash','scalar_finalizers','next_DECL_UID_upper','next_type_UID_upper','temporary_name_serial_upper')))
    check('ownership excludes all already charged direct objects',all(
          v==0 for k,v in result['ownership'].items() if k.endswith(('added_again','added','backing_events'))))
    check('six registrations do not count assembler control again',
          result['named_source_demands']['scalar_finalizer_registrations']==6 and
          result['incoming_scalar_finalizers']['additional_pushes']==5)
    check('global completeness remains false',result['total_GGC_events'] is None and not any(
          result[k] for k in ('complete_later_shared_storage_closed','complete_global_counter_lifetime_closed',
          'complete_collector_lifetime_closed','complete_gimplifier_lifetime_closed',
          'whole_literal_pipeline_capacity_established','production_admission_changed','aggregate_RAM_gate')))
    check('remaining-family partition is explicit',len(result['remaining_shared_families'])==9 and
          all(r['required_input'] and r['next_join'] for r in result['remaining_shared_families']))

    reject('different bytes with equal C N rejected',lambda:evaluate_source(
        raw.replace(b'Hello, world!',b'Other, world!'),shared,corrected,context))
    altered=copy.deepcopy(shared);altered['source_counts']['null_statements']=1
    reject('altered source counts rejected',lambda:evaluate_source(raw,altered,corrected,context))
    altered=copy.deepcopy(corrected);altered['identifier_hash']['historical_insertions_upper']-=1
    reject('uncorrected identifier history rejected',lambda:evaluate_source(raw,shared,altered,context))
    altered=copy.deepcopy(shared);altered['scalar_finalizers']['additional_pushes']=4
    reject('erased original finalizer allowance rejected',lambda:evaluate_source(raw,altered,corrected,context))
    altered=copy.deepcopy(shared);altered['counter_endpoints']['next_DECL_UID_upper']-=1
    reject('erased original declaration increment rejected',lambda:evaluate_source(raw,altered,corrected,context))
    for bad in ({'unknown':0},{'identifier_insertions':-1},{'type_UID_increments':True},
                {'scalar_finalizer_registrations':1.5}):
        reject('invalid residual '+repr(bad),lambda bad=bad:evaluate_source(raw,shared,corrected,context,bad))
    zero={k:0 for k in RESIDUALS}
    conditional=evaluate_source(raw,shared,corrected,context,zero)
    check('explicit zero computes conditional arithmetic without source closure',
          conditional['conditional_full_arithmetic_fits'] and
          not conditional['supplied_residual_source_bounds_established'] and
          not conditional['complete_later_shared_storage_closed'] and
          conditional['conditional_full_endpoint']['identifier_hash']==projected['identifier_hash'])
    partial=evaluate_source(raw,shared,corrected,context,dict(identifier_insertions=7))
    check('partly supplied residual does not fill remaining zeros',
          partial['conditional_full_endpoint']['identifier_hash']['historical_insertions_upper']==40893 and
          partial['conditional_full_endpoint']['scalar_finalizers'] is None and
          len(partial['unresolved_endpoint_inputs'])==3)

    for key,base,limit in (('DECL_UID_increments',5877,I32),('type_UID_increments',2306,U32)):
        at=evaluate_source(raw,shared,corrected,context,dict(zero,**{key:limit-base}))
        beyond=evaluate_source(raw,shared,corrected,context,dict(zero,**{key:limit-base+1}))
        check(key+' exact signed/unsigned endpoint',at['conditional_full_arithmetic_fits'] and
              not beyond['conditional_full_arithmetic_fits'])
    for history,slots in ((49151,65536),(49152,131072)):
        row=identifier_transfer(corrected['identifier_hash'],history-40883,context.shared_code)
        check('identifier strict threshold '+str(history),row['allocated_slots_upper']==slots)
    for history in (U32//4,U32//4+1):
        row=identifier_transfer(corrected['identifier_hash'],history-40883,context.shared_code)
        check('identifier historical multiply endpoint '+str(history),
              row['checks']['historical_insertions_unsigned']==(history<=U32//4))
    for history in (U32//3+1,U32//3+2):
        row=finalizer_transfer(shared['scalar_finalizers'],history-39262,context.shared_code)
        check('finalizer growth endpoint '+str(history),
              row['checks']['growth_unsigned']==(3*(history-1)<=U32))
    changed=copy.deepcopy(corrected['identifier_hash'])
    changed['allocated_slots_upper']=131072
    check('retained identifier capacity survives low occupancy transfer',
          identifier_transfer(changed,0,context.shared_code)['allocated_slots_upper']==131072)
    changed=copy.deepcopy(shared['scalar_finalizers']);changed['allocated_slots_upper']=100000
    check('retained finalizer capacity survives removals',
          finalizer_transfer(changed,0,context.shared_code)['allocated_slots_upper']==100000)

    # Small independent pre-hit/tombstone histories exercise the conditional
    # transfer, without substituting these artificial inputs for native state.
    prime=lambda n:next(p for p in context.primes if p>=n)
    for mode in ('fresh','hits','remove_and_reinsert'):
        incoming=90;slots=127;keys=set(range(incoming));occupied=incoming;backings=0
        lookups=200;new_history=0
        for i in range(lookups):
            if mode=='remove_and_reinsert' and i%2==0: keys.discard(i%90)
            if slots*3<=occupied*4:
                live=len(keys)
                if 2*live>slots or (8*live<slots and slots>32): slots=prime(max(7,2*live))
                occupied=live;backings+=1
            key=90+i if mode=='fresh' else i%90
            if key not in keys: keys.add(key);occupied+=1;new_history+=1
        bound=rtl_hash_transfer(incoming,127,lookups,new_history,context.primes)
        check('independent RTL weak-cache history '+mode,
              bound['non_lookup_backing_requests_upper'] is None and
              not bound['complete_cache_lifetime_closed'] and
              backings<=bound['additional_GGC_backing_requests_upper'] and
              slots<=bound['outgoing_slots_upper'] and occupied<=bound['outgoing_history_upper'])
    reject('RTL new entries cannot exceed lookups',lambda:rtl_hash_transfer(90,127,1,2,context.primes))

    # Exercise the reusable accepted consumer functions on actual recognized
    # source variants. These are narrow incoming-field arithmetic fixtures,
    # not claims that all other original-shared fields were reevaluated.
    for c,n in ((2,3),(40,0),(1,50)):
        source=(b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin '+
                b'Silver_IO.Put ("x");'*c+b'null;'*n+b'end Main;')
        counts=context.recognizer(source);fixture=copy.deepcopy(shared)
        fixture['source']=identity(source);fixture['source_counts']=counts
        additions=c+35;history=40846+additions;slots=context.shared_code['identifier_slots'](history)
        fixture['source_bound_demands']['identifier_new_entries']=additions
        fixture['identifier_hash'].update(historical_insertions_upper=history,occupied_upper=history,
            allocated_slots_upper=slots,each_ordinary_backing_bytes_upper=8*slots,
            post_prefix_backing_requests_upper=additions)
        fixture['counter_endpoints'].update(next_DECL_UID_upper=5870+2*c+n,
            next_type_UID_upper=2300+6*c,next_temporary_name_serial_upper=history)
        correction=context.location['corrected_shared_identifier_projection'](fixture,identity(source),counts)
        value=evaluate_source(source,fixture,correction,context)
        check('recognized source narrow arithmetic fixture '+str((c,n)),
              value['named_source_demands']==dict(identifier_insertions=2*c+1,DECL_UID_increments=3*c+2,
                  type_UID_increments=0,scalar_finalizer_registrations=6) and
              value['conditional_full_endpoint']['next_DECL_UID_upper'] is None)

    # One changed complete compiler source must fail before any arithmetic.
    manifest=read(HERE/'inputs.json')
    with tempfile.TemporaryDirectory(prefix='later-shared-negative-',dir=HERE) as tmp:
        root=Path(tmp)
        for row in manifest['files']:
            if row['root']=='gcc':
                dest=root/row['path'];dest.parent.mkdir(parents=True,exist_ok=True)
                dest.symlink_to(args.gcc_root/row['path'])
        changed=root/'gcc/varasm.cc';changed.unlink()
        changed.write_bytes((args.gcc_root/'gcc/varasm.cc').read_bytes()+b'\n/* changed */\n')
        reject('changed complete source identity rejected',lambda:Context(root))
    report=dict(passed=True,checks=len(checks),cases=checks,started_utc=started,
        completed_utc=datetime.now(timezone.utc).isoformat(),elapsed_seconds=time.monotonic()-start,
        source_files=context.source_files,repository_inputs=context.repository_files,
        callable_identity=identity((HERE/'derive.py').read_bytes()),
        checker_identity=identity((HERE/'check.py').read_bytes()),
        remaining_families_identity=identity((HERE/'remaining-families.json').read_bytes()),
        source_argument_identity=identity((REPO/'docs/research/retained-literal-later-shared-storage.md').read_bytes()),
        native_tool_executions=0,accepted_component_suites_rerun=0,aggregate_Context_instantiations=0,
        selected_model='GPT-6 Astra',selected_effort='Extra High',runtime_confirmed_model_effort=None,
        token_cost_evidence=None,independent_review='pending')
    args.output.write_text(json.dumps(report,indent=2,sort_keys=True)+'\n')
    print(json.dumps({k:report[k] for k in ('passed','checks','elapsed_seconds','native_tool_executions')}))


if __name__=='__main__':
    main()
