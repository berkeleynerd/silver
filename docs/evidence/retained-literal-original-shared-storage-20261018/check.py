#!/usr/bin/env python3
"""Offline source variants, join mutations and independent growth simulations."""
import argparse
import copy
from datetime import datetime, timezone
import importlib.util
import json
from pathlib import Path
import random
import tempfile
import time

HERE=Path(__file__).resolve().parent


def main():
    started=datetime.now(timezone.utc).isoformat(); timer=time.perf_counter()
    spec=importlib.util.spec_from_file_location('original_shared',HERE/'compose.py')
    m=importlib.util.module_from_spec(spec); spec.loader.exec_module(m)
    parser=argparse.ArgumentParser(description=__doc__); m.arguments(parser)
    args=parser.parse_args()
    ctx=m.Context(args.gcc_root,args.ada_root,args.plugin_include,args.gcc_match)
    rows=[]

    def check(name,condition):
        if not condition:
            raise AssertionError(name)
        rows.append(dict(name=name,passed=True))

    def rejected(name,fn,match):
        try:
            fn()
        except ValueError as exc:
            check(name,match in str(exc))
        else:
            raise AssertionError(name+' was accepted')

    fixture=m.read(m.AGGREGATE/'fixture.json')
    fixture['source']=str((m.AGGREGATE/fixture['source']).resolve())
    fixture['shared_inputs']={k:str((m.AGGREGATE/v).resolve()) for k,v in fixture['shared_inputs'].items()}
    hello=Path(fixture['source']).read_bytes()
    shell=b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin\n'
    tail=b'\nend Main;\n'
    variants=[('Hello',hello,1,0,1),
        ('mixed',shell+b'Silver_IO.Put ("x"); null; Silver_IO.Put_Line ("a""b");'+tail,2,1,2),
        ('empty_literal',shell+b'Silver_IO.Put ("");'+tail,1,0,1),
        ('case_CRLF',hello.upper().replace(b'\n',b'\r\n'),1,0,1),
        ('8192_bytes',shell+b'Silver_IO.Put ("'+b'x'*8192+b'");'+tail,1,0,1),
        ('5000_calls',shell+b'Silver_IO.Put ("x");\n'*5000+tail,5000,0,1)]
    summaries=[]
    with tempfile.TemporaryDirectory(prefix='silver-original-shared-') as tmp:
        root=Path(tmp); desc=root/'descriptor.json'; src=root/'main.adb'
        desc.write_text(json.dumps(fixture))
        for name,raw,c,n,d in variants:
            src.write_bytes(raw)
            a=ctx.aggregate.evaluate(desc,ctx.aggregate_context,src)
            r=m.derive(a,ctx)
            k=c+4*d+5; v=164*c+16*d+8; h=151+167*c+12*n+114
            expected=dict(identifier_lookups=k+28,identifier_new_entries=k+26,
                type_hash_lookups=2*d+4,type_hash_entries=2*d+4,
                integer_hash_lookups=v+129,integer_hash_entries=v+129,
                small_integer_cache_writes=v+132,already_owned_small_integer_cache_vectors=v,
                global_decls_pushes=d+8,stmt_list_cache_pushes=h,alias_sets_pushes=4,
                scalar_finalizer_pushes=5,vector_finalizer_pushes=0,
                dummy_identifier_entries=1,dummy_DECL_UIDs=1)
            check(name+' actual-source demand sum',r['source_bound_demands']==expected)
            f=r['filename_ingress']
            check(name+' physical/virtual file join',f['source_file_entries_upper']==1588
                and f['identifier_lookups_upper']==1589
                and f['optional_Image_I_physical_body_already_in_union']
                and not f['actual_invocation_materialization_established'])
            ids=r['identifier_hash']
            check(name+' incoming identifier high water',ids['incoming_historical_insertions_upper']==40846
                and ids['incoming_allocated_slots_upper']==65536
                and ids['historical_insertions_upper']==40846+k+26)
            check(name+' hash requests count lookups',r['type_hash']['additional_GGC_backing_requests_upper']==2*d+4
                and r['integer_hash']['additional_GGC_backing_requests_upper']==v+129
                and r['integer_hash']['successful_lookup_can_replace_backing'])
            check(name+' vector occupied and allocated states',r['global_decls']['incoming_allocated_slots_upper']==414851
                and r['alias_sets']['incoming_occupied_upper']==414851
                and r['stmt_list_cache']['incoming_allocated_slots_upper']==0
                and r['stmt_list_cache']['occupied_upper']==h)
            z=r['scalar_finalizers']
            check(name+' finalizer high water',z['incoming_occupied_upper']==39257
                and z['incoming_allocated_slots_upper']==58884
                and z['additional_pushes']==5 and z['allocated_slots_upper']==58891)
            e=r['counter_endpoints']
            check(name+' finite counter endpoints',e['next_DECL_UID_upper']==5832+2*c+n+3*d+5+30
                and e['next_type_UID_upper']==2278+6*c+5*d+3+14
                and e['next_temporary_name_serial_upper']==40846+k+26
                and e['next_function_definition_number']==4 and e['helper_name_fnno_next']==2)
            check(name+' no duplicate direct caches or scalar registrations',r['small_integer_cache']['extra_GGC_requests']==0
                and r['additional_shared_GGC_backing_request_events_upper']==(2*d+4)+(v+129)+(d+8)+h+4)
            ada=r['remaining_Ada_integer_storage']
            check(name+' Ada incoming state remains separate',ada==dict(Uint_entries=2*c,Udigits_words=10*c,
                UI_Ints_wrapper_calls=2*c,incoming_occupied=None,incoming_allocated=None,complete_backing_closed=False))
            check(name+' broad claims remain false',not any(r[x] for x in (
                'later_consumers_included','complete_original_gigi_storage_closed',
                'complete_global_counter_lifetime_closed','complete_collector_lifetime_closed',
                'whole_literal_pipeline_capacity_established','aggregate_RAM_gate','production_admission_changed'))
                and r['complete_imported_allocation_events'] is None
                and r['complete_imported_allocation_bytes'] is None and r['native_tool_executions']==0)
            check(name+' aggregate unresolved conditions retained',r['retained_aggregate_unresolved_predicates']==
                ['Main_assembler_object_interface','Main_GAS_BFD_storage','literal_output_linker_representation']
                and r['retained_aggregate_failed_conditional_predicates']==a['failed_conditional_predicates'])
            check(name+' selected shared interface fits',r['selected_original_shared_container_interface_fits'])
            if name=='Hello':
                base=a
                check('Hello individual byte ceilings',ids['each_ordinary_backing_bytes_upper']==524288
                    and r['type_hash']['each_caller_bytes_upper']==1048568
                    and r['integer_hash']['each_rounded_bytes_upper']==1048576
                    and r['global_decls']['each_rounded_bytes_upper']==8388608
                    and r['stmt_list_cache']['each_rounded_bytes_upper']==8192
                    and z['each_ordinary_backing_bytes_upper']==942264
                    and r['additional_shared_GGC_backing_request_events_upper']==768)
            if name=='5000_calls':
                check('5000-call conservative relocation failure retained',bool(r['retained_aggregate_failed_conditional_predicates']))
            counts={key:value for key,value in r['source_counts'].items() if key!='decoded_literal_lengths'}
            lengths=r['source_counts']['decoded_literal_lengths']
            summaries.append(dict(name=name,source_counts=counts,
                literal_lengths_count=len(lengths),
                literal_lengths_compact_json_identity=m.identity(json.dumps(lengths,separators=(',',':')).encode('ascii')),
                shared_backing_events_upper=r['additional_shared_GGC_backing_request_events_upper'],
                selected_shared_interface_fits=r['selected_original_shared_container_interface_fits'],
                aggregate_failed_conditional_predicates=r['retained_aggregate_failed_conditional_predicates']))

        mutations=[
            ('Main demands',['native_original_Main_storage','interface','shared_demands','identifier_lookups'],0),
            ('I114 join',['native_original_Main_storage','fixed_context_I'],113),
            ('String entries',['native_original_String_storage','interface','identifier_new_entries'],10),
            ('helper entries',['native_original_helper_storage','interface','shared_container_demands','identifier_new_entries_ceiling'],3),
            ('synthetic finalizers',['native_synthetic_function_storage','shared_container_demands','singleton_finalizer_registrations'],1),
            ('helper ownership',['native_original_String_storage','helper94_additions'],2),
            ('historical null duplication',['native_original_Main_storage','historical_null_structural_and_name_packets_additions'],1),
            ('warning finalizer',['native_warning_map_demand','conditional_map_transfer','additional_singleton_finalizer_registrations_ceiling'],0),
            ('symbol finalizer',['native_pool_lifetime','additional_singleton_finalizer_registrations_upper'],0),
            ('collector backing effects',['native_collector_callbacks','collector_callback_additional_GGC_events'],1),
            ('function numbers',['native_counter_emission_interface','interface','function_definition_numbers','Main'],2)]
        for name,path,value in mutations:
            changed=copy.deepcopy(base); obj=changed
            for key in path[:-1]:obj=obj[key]
            obj[path[-1]]=value
            rejected(name+' mutation',lambda:m.derive(changed,ctx),'join')
        old_prefix=ctx.prefix
        ctx.prefix=copy.deepcopy(old_prefix);ctx.prefix['counters']['ggc_bytes']['positive_events']-=1
        rejected('prefix seed mutation',lambda:m.derive(base,ctx),'fixed prefix')
        ctx.prefix=old_prefix
        changed=copy.deepcopy(base);changed['complete_path_bound']=32768
        check('filename signed-short boundary',not m.derive(changed,ctx)['conditions']['filename_ingress'])
        # Exercise the actual Context verification paths without changing inputs.
        old_here=m.HERE; m.HERE=root
        pins=m.read(old_here/'inputs.json'); sources=m.read(old_here/'sources.json')
        altered=copy.deepcopy(pins);altered[0]['sha256']='0'*64
        (root/'inputs.json').write_text(json.dumps(altered))
        (root/'sources.json').write_text(json.dumps(sources))
        rejected('repository pin mutation',lambda:m.Context(args.gcc_root,args.ada_root,args.plugin_include,args.gcc_match),
            'shared-storage input')
        (root/'inputs.json').write_text(json.dumps(pins));sources['files'][0]['bytes']+=1
        (root/'sources.json').write_text(json.dumps(sources))
        rejected('complete source mutation',lambda:m.Context(args.gcc_root,args.ada_root,args.plugin_include,args.gcc_match),
            'shared-storage source')
        m.HERE=old_here
        src.write_bytes(shell+b'Silver_IO.Put (Unknown);'+tail)
        rejected('unrecognized expression source',lambda:m.evaluate(desc,ctx,src),'literal')

    # Simulations follow source transitions, independently of the closed forms.
    for incoming in (0,4,7,15,16,31,1023,414851):
        for pushes in (0,1,2,16,433,5000):
            for gc in (False,True):
                allocated=incoming; live=incoming
                peak=allocated
                for step in range(pushes):
                    # Removal can retain the larger backing at low occupancy.
                    if step%13==7 and live:live-=1
                    desired=live+1
                    if desired>allocated:
                        allocated=max(desired,4 if allocated==0 else
                            allocated*2 if allocated<16 else allocated*3//2)
                        if gc:allocated=(m.rho(8+8*allocated)-8)//8
                    live=desired;peak=max(peak,allocated)
                bound=m.gc_vector(incoming,pushes)['allocated_slots_upper'] if gc else max(incoming,m.heap_capacity(incoming+pushes))
                check('vector simulation %d/%d/%s'%(incoming,pushes,gc),peak<=bound)
    for target in (12287,12288,24575,24576,40846,49151,49152,100000):
        slots=16384;history=0
        for _ in range(target):
            history+=1
            if 4*history>=3*slots:slots*=2
        check('identifier post-insert threshold '+str(target),slots==m.identifier_slots(target))
    check('identifier strict equality',m.identifier_slots(12287)==16384 and m.identifier_slots(12288)==32768)
    primes=ctx.primes
    rng=random.Random(119)
    for initial in (7,1021,2039):
        slots=initial;occupied=deleted=history=0;peak=slots;requests=lookups=0
        for step in range(10000):
            if step%7==0 and occupied>deleted:
                deleted+=1  # GC removal retains m_n_elements until expansion.
            lookups+=1
            if 3*slots<=4*occupied:
                live=occupied-deleted
                if 2*live>slots or (8*live<slots and slots>32):
                    slots=next(p for p in primes if p>=2*live)
                occupied=live;deleted=0;requests+=1;peak=max(peak,slots)
            if rng.randrange(3):  # miss, possibly reusing a tombstone
                history+=1
                if deleted:deleted-=1
                else:occupied+=1
            bound=m.hash_backing(initial,0,lookups,history,primes)
            if peak>bound['allocated_slots_upper'] or requests>lookups:
                raise AssertionError('hash transition bound')
        check('hash hit/delete/retain simulation '+str(initial),True)
    hit=m.hash_backing(7,6,1,0,primes)
    check('successful lookup can expand without insertion',hit['additional_GGC_backing_requests_upper']==1
        and hit['allocated_slots_upper']==13)
    check('deleted retained allocation dominates low live count',m.hash_backing(131071,1,1,0,primes)['allocated_slots_upper']==131071)
    check('finite prime last admitted request',m.hash_backing(2039,0,0,m.I32//2,primes)['checks']['prime_exists'])
    check('finite prime unavailable beyond last tier',not m.hash_backing(2039,0,0,m.I32//2+1,primes)['fits'])
    check('finite hash empty-threshold admitted',m.hash_backing(2039,0,0,m.U32//8,primes)['fits'])
    check('finite hash empty-threshold rejected',not m.hash_backing(2039,0,0,m.U32//8+1,primes)['checks']['empty_threshold_unsigned'])
    check('finite vector unsigned growth failure',not m.gc_vector(0,m.U32//3+2)['fits'])
    check('finite vector normalized capacity failure',not m.gc_vector(0,2**31)['checks']['normalized_capacity_31_bits'])
    check('identifier arithmetic threshold failure',4*(m.U32//4+1)>m.U32)
    # Last delimiter separates the decimal serial even when prefixes contain it.
    spellings={prefix+'.'+str(i) for i in range(100) for prefix in ('T','T.1','a.99.b','a_3')}
    check('temporary serial suffix is injective across prefixes',all(s.rsplit('.',1)[1].isdigit() for s in spellings)
        and all({int(s.rsplit('.',1)[1]) for s in spellings if s.endswith('.'+str(i))}=={i} for i in range(100)))
    result=dict(checks=len(rows),all_passed=True,checks_detail=rows,source_variants=summaries,
        selected_model='GPT-6 Astra',selected_effort='Extra High',runtime_model_confirmation=None,
        token_cost_measurements=None,native_tool_executions=0,
        started_utc=started,completed_utc=datetime.now(timezone.utc).isoformat(),elapsed_seconds=time.perf_counter()-timer)
    args.output.write_text(json.dumps(result,indent=2,sort_keys=True)+'\n')
    print(json.dumps({k:result[k] for k in ('checks','all_passed','native_tool_executions','elapsed_seconds')}))


if __name__=='__main__':
    main()
