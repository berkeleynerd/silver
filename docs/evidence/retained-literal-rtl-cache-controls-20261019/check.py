#!/usr/bin/env python3
"""Focused cache lifetime arithmetic and source/ownership checks; no native run."""
import argparse
from datetime import datetime,timezone
import json
from pathlib import Path
import tempfile
import time

from derive import Context,HERE,REPO,U32,identity,read,cache_capacity,transfer,evaluate_source


def main():
    start=time.monotonic();started=datetime.now(timezone.utc).isoformat()
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gcc-root',type=Path,default=Path('/tmp/silver-backend-compose-20261018/full-source'))
    parser.add_argument('--output',type=Path,default=HERE/'check-results.json')
    args=parser.parse_args();context=Context(args.gcc_root);cases=[]

    def check(name,value):
        if not value:raise AssertionError(name)
        cases.append(name)

    def reject(name,call):
        try:call()
        except (ValueError,TypeError):cases.append(name)
        else:raise AssertionError('accepted '+name)

    raw=(REPO/'samples/hello_world.adb').read_bytes()
    result=evaluate_source(raw,context)
    check('exact retained source-bound result',result==read(HERE/'result.json'))
    check('actual source identity',result['source']==identity(raw) and
          result['source_counts']['source_sha256']==identity(raw)['sha256'])
    check('complete prefix and setup constant history',
          result['CONST_INT']['historical_insertions_upper']==39378 and
          result['reg_attrs']['historical_insertions_upper']==39260)
    check('complete native hash byte ceilings',all(
          result[k]['allocated_slots_upper']==131071 and
          result[k]['each_backing_caller_bytes_upper']==1048568 and
          result[k]['each_backing_rounded_bytes_upper']==1048576 for k in ('CONST_INT','reg_attrs')))
    check('first setup 121 remains inside existing owner',
          result['CONST_INT']['first_setup_backing_events_already_owned']==121 and
          result['CONST_INT']['total_post_prefix_backing_events_upper']==122 and
          result['new_shared_GGC_backing_request_events_upper']==4)
    check('cache capacities do not assume empty incoming history',
          all(result[k]['incoming_prefix_history_upper']==39257 for k in ('CONST_INT','reg_attrs')))
    check('register lookup composition',result['reg_attrs']['original_declaration_calls_upper']==1 and
          result['reg_attrs']['split_part_calls_upper']==2 and
          result['reg_attrs']['insertion_capable_lookups_upper']==3)
    check('nonlookup backbones are closed source zeros',all(
          result[k]['source_lifetime_closed'] and result[k]['post_prefix_non_lookup_backing_events']==0
          for k in ('CONST_INT','reg_attrs')))
    check('five disjoint scalar control registrations',sum(r['registrations'] for r in
          result['control_rows'])==result['additional_control_scalar_registrations_upper']==5)
    check('existing controls and frame backbones not added again',
          result['new_control_direct_GGC_events']==result['new_control_hash_replacement_events']==0 and
          result['original_five_registrations_added_again']==result['named_six_registrations_added_again']==0)
    check('selected loops and DF registration exclusions retained',
          result['selected_recorded_loop_exit_controls']==result['selected_DF_GGC_controls']==0)
    check('complete cache family does not promote global endpoint claims',
          result['conditional_cache_capacity_established'] and result['total_GGC_events'] is None and
          not any(result[k] for k in ('complete_scalar_finalizer_lifetime_closed',
          'complete_type_alias_lifetime_closed','complete_global_counter_lifetime_closed',
          'complete_collector_lifetime_closed','whole_literal_pipeline_capacity_established',
          'production_admission_changed','aggregate_RAM_gate')))

    for c,n,length in ((1,0,0),(2,3,65),(40,0,1),(1,50,127)):
        src=(b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin '+
            (b'Silver_IO.Put ("'+b'x'*length+b'");')*c+b'null;'*n+b'end Main;')
        value=evaluate_source(src,context)
        check('recognized source '+str((c,n,length)),value['source']==identity(src) and
              value['CONST_INT']['historical_insertions_upper']==39257+120+c and
              value['reg_attrs']['historical_insertions_upper']==39257+3*c and
              value['new_shared_GGC_backing_request_events_upper']==4*c and
              value['additional_control_scalar_registrations_upper']==5)
    a=evaluate_source(raw,context);b=evaluate_source(raw.replace(b'Hello, world!',b'Other, world!'),context)
    check('different bytes retain different source identity even at equal counts',
          a['source']!=b['source'] and a['source_input']==b['source_input'])
    reject('unsupported source rejected',lambda:evaluate_source(raw.replace(b'Put_Line',b'New_Line'),context))
    reject('noncurrent source alphabet rejected',lambda:evaluate_source(raw+b'\x00',context))
    for c,n in ((0,0),(-1,0),(True,0),(1,-1),(1,False)):
        reject('invalid C N '+str((c,n)),lambda c=c,n=n:transfer(c,n,context))

    # Prime transitions and the width endpoint are arithmetic probes, not
    # fabricated accepted native source or source-size claims.
    for prime in (61,127,131071,262139):
        below=cache_capacity(prime//2,context.primes)
        above=cache_capacity(prime//2+1,context.primes)
        check('next prime transition '+str(prime),
              below['allocated_slots_upper']<=prime<above['allocated_slots_upper'])
    for h in (2**30-1,2**30):
        row=cache_capacity(h,context.primes)
        check('historical region endpoint '+str(h),row['checks']['historical_region']==(h<2**30))
    huge=transfer(2**32,0,context)
    check('overflow guard fails without losing sourced multiplicity',
          not huge['conditional_cache_capacity_established'] and
          huge['reg_attrs']['source_lifetime_closed'] and huge['total_GGC_events'] is None)
    reject('negative cache history rejected',lambda:cache_capacity(-1,context.primes))

    # Independent concrete table histories include pre-hit growth, all hits,
    # weak deletion/reinsertion, and a retained large backing at low occupancy.
    prime_for=lambda n:next(p for p in context.primes if p>=n)
    for mode in ('new','hits','weak_deletion','retained_capacity'):
        incoming=50;keys=set(range(incoming));occupied=incoming
        slots=131071 if mode=='retained_capacity' else 61
        backs=0;new=0;lookups=300
        for i in range(lookups):
            if mode=='weak_deletion' and i%3==0:keys.discard(i%50)
            if slots*3<=occupied*4:
                live=len(keys)
                if 2*live>slots or (8*live<slots and slots>32):slots=prime_for(max(7,2*live))
                occupied=live;backs+=1
            key=50+i if mode=='new' else i%50
            if key not in keys:keys.add(key);occupied+=1;new+=1
        # The retained large capacity needs the complete historical seed,
        # rather than the current live occupancy50.
        history_seed=39257 if mode=='retained_capacity' else incoming
        bound=cache_capacity(history_seed+new,context.primes)
        check('independent table history '+mode,backs<=lookups and
              slots<=bound['allocated_slots_upper'] and occupied<=bound['occupied_upper'])
    for entries in (0,2):
        check('fixed control no resize at '+str(entries)+' entries',31*3>entries*4)

    # Complete retained source identity is enforced before module loading.
    manifest=read(HERE/'inputs.json')
    with tempfile.TemporaryDirectory(prefix='negative-',dir=HERE) as tmp:
        root=Path(tmp)
        for row in manifest['files']:
            if row['root']=='gcc':
                p=root/row['path'];p.parent.mkdir(parents=True,exist_ok=True)
                p.symlink_to(args.gcc_root/row['path'])
        p=root/'gcc/emit-rtl.cc';p.unlink()
        p.write_bytes((args.gcc_root/'gcc/emit-rtl.cc').read_bytes()+b'\n/* changed */\n')
        reject('changed complete cache source rejected',lambda:Context(root))
    report=dict(passed=True,checks=len(cases),cases=cases,started_utc=started,
        completed_utc=datetime.now(timezone.utc).isoformat(),elapsed_seconds=time.monotonic()-start,
        source_files=context.source_files,repository_inputs=context.repository_files,
        callable_identity=identity((HERE/'derive.py').read_bytes()),
        checker_identity=identity((HERE/'check.py').read_bytes()),
        source_argument_identity=identity((REPO/'docs/research/retained-literal-rtl-cache-controls.md').read_bytes()),
        native_tool_executions=0,accepted_component_suites_rerun=0,aggregate_executions=0,
        selected_model='GPT-6 Astra',selected_effort='Extra High',runtime_confirmed_model_effort=None,
        token_cost_evidence=None,independent_review='pending')
    args.output.write_text(json.dumps(report,indent=2,sort_keys=True)+'\n')
    print(json.dumps({k:report[k] for k in ('passed','checks','elapsed_seconds')}))


if __name__=='__main__':
    main()
