#!/usr/bin/env python3
"""Affected shared-storage/linker aggregate joins, without broad leaf reruns."""
import argparse
import copy
from datetime import datetime, timezone
import importlib.util
import json
from pathlib import Path
import tempfile
import time

HERE=Path(__file__).resolve().parent


def main():
    started=datetime.now(timezone.utc).isoformat();timer=time.perf_counter()
    spec=importlib.util.spec_from_file_location('literal_attachment',HERE/'compose.py')
    m=importlib.util.module_from_spec(spec);spec.loader.exec_module(m)
    parser=argparse.ArgumentParser(description=__doc__);m.arguments(parser)
    parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
    ctx=m.Context(args.gcc_root,args.ada_root,args.plugin_include,args.gcc_match);rows=[]

    def check(name,condition):
        if not condition:raise AssertionError(name)
        rows.append(dict(name=name,passed=True))

    def reject(name,fn,fragment):
        try:fn()
        except ValueError as exc:check(name,fragment in str(exc))
        else:raise AssertionError(name+' accepted')

    verification=ctx.original_shared_source_validation
    check('shared partition is current35 historical3 source60',verification['current_repository_files_verified']==35
        and verification['historical_repository_files_verified']==3 and verification['complete_source_files_verified']==60
        and not verification['leaf_Context_executed'] and not verification['historical_files_counted_as_current'])
    check('relocation source13 capsule12',ctx.relocation_refinement_source_validation['repository_inputs_verified']==13
        and ctx.relocation_refinement_source_validation['complete_capsule_files_verified']==12)
    # Execute the exact historical evaluator using the current validated input
    # interfaces. Its Context is defined but never instantiated; no recursion.
    legacy={'__file__':str(HERE/'compose.py'),'__name__':'historical_aggregate_projection'}
    revision=verification['historical_repository_revision']
    exec(compile(m.read_historical_repository_file(revision,str((HERE/'compose.py').relative_to(m.REPO))),
                 '<checked aggregate predecessor>','exec'),legacy)
    fixture=m.read(HERE/'fixture.json')
    fixture['source']=str((HERE/fixture['source']).resolve())
    fixture['shared_inputs']={k:str((HERE/v).resolve()) for k,v in fixture['shared_inputs'].items()}
    shell=b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin\n';tail=b'\nend Main;\n'
    variants=[('Hello',Path(fixture['source']).read_bytes()),
        ('mixed_empty_8192',shell+b'Silver_IO.Put (""); null; Silver_IO.Put_Line ("'+b'x'*8192+b'");'+tail),
        ('5000_calls',shell+b'Silver_IO.Put ("x");\n'*5000+tail)]
    summaries=[]
    with tempfile.TemporaryDirectory(prefix='silver-shared-linker-attachment-') as tmp:
        root=Path(tmp);descriptor=root/'descriptor.json';source=root/'main.adb'
        descriptor.write_text(json.dumps(fixture))
        for name,raw in variants:
            source.write_bytes(raw)
            old=legacy['evaluate'](descriptor,ctx,source)
            current=m.evaluate(descriptor,ctx,source)
            attached=current['native_original_shared_storage'];shared=attached['interface']
            prior_shared=ctx.original_shared['derive'](old,ctx.original_shared_context)
            check(name+' eleven source/capacity projections unchanged',all(current[k]==old[k]
                for k in attached['source_capacity_projection_keys']))
            check(name+' actual pure derivation unchanged except inherited diagnostics',
                {k:v for k,v in shared.items() if k!='retained_aggregate_failed_conditional_predicates'}==
                {k:v for k,v in prior_shared.items() if k!='retained_aggregate_failed_conditional_predicates'})
            check(name+' diagnostic scope explicit', 'before adding the original-shared guards' in attached['inherited_diagnostics_scope']
                and shared['retained_aggregate_failed_conditional_predicates']==[]
                and shared['retained_aggregate_unresolved_predicates']==current['unresolved_predicates'])
            check(name+' named shared guards feed both maps',all(
                current['conditions']['native_original_shared_'+k]==v==
                current['conditional_conditions']['native_original_shared_'+k]
                for k,v in shared['conditions'].items()))
            ledger=attached['partial_ledger'];c=current['source_counts']['output_calls']
            n=current['source_counts']['null_statements'];d=sum(current['source_counts'][k]>0 for k in ('Put','Put_Line'))
            check(name+' partial ledger has exact ownership',ledger['GGC_groups']==dict(
                original_Main=609*c+24*n+54*d+398,original_String216=216,original_helpers94=94,synthetic173=173,
                new_shared_backings=shared['additional_shared_GGC_backing_request_events_upper'])
                and ledger['known_selected_GGC_event_subtotal']==sum(ledger['GGC_groups'].values())
                and not ledger['prefix_and_filename_ingress_in_subtotal']
                and not ledger['forced_dummy_and_warning_symbol_controls_in_subtotal']
                and ledger['direct_small_cache_vectors_added_again']==ledger['historical_null_packets_added']==0)
            historical=current['literal_output_linker_historical_conservative'];link=current['literal_output_linker']
            refinement=current['literal_output_linker_refinement'];v=link['link']['layout']['retained_endpoint']
            check(name+' historical linker is exact source predecessor',historical==old['literal_output_linker'])
            check(name+' all39 other linker guards retained',len(refinement['unchanged_other_checks'])==39
                and refinement['unchanged_other_checks']=={k:x for k,x in historical['link']['checks'].items()
                    if k!='fixed_signed_relocation_reach'})
            restored=copy.deepcopy(link)
            restored['link']['relocation_bounds']['common_signed32']=historical['link']['relocation_bounds']['common_signed32']
            for key in ('checks','failed_sufficient_checks','selected_output_link_representation_fits'):
                restored['link'][key]=historical['link'][key]
            restored['selected_literal_assembler_and_linker_representation_fits']=historical['selected_literal_assembler_and_linker_representation_fits']
            check(name+' only reviewed linker fields changed',restored==historical
                and refinement['operand_domains']['common_signed32']==v+2019040+15)
            check(name+' local arithmetic passes with three actual unknowns',current['conditional_arithmetic_pass']
                and current['failed_conditional_predicates']==[] and not current['evaluated_predicates_pass']
                and set(current['unresolved_predicates'])=={'Main_assembler_object_interface','Main_GAS_BFD_storage',
                    'literal_output_linker_representation'} and all(current['conditions'][k] is None for k in current['unresolved_predicates']))
            check(name+' broad negatives and missing totals preserved',not current['whole_literal_pipeline_capacity_established']
                and not shared['complete_original_gigi_storage_closed'] and not shared['complete_global_counter_lifetime_closed']
                and not shared['complete_collector_lifetime_closed'] and not shared['later_consumers_included']
                and shared['complete_imported_allocation_events'] is None and shared['complete_imported_allocation_bytes'] is None
                and ledger['complete_imported_allocation_events'] is None and ledger['complete_imported_allocation_bytes'] is None
                and shared['remaining_Ada_integer_storage']['incoming_occupied'] is None
                and shared['remaining_Ada_integer_storage']['incoming_allocated'] is None
                and not current['production_admission_changed'] and not current['aggregate_RAM_gate'])
            if name=='Hello':
                baseline=current;projection=old
                retained=m.read(m.EVIDENCE/'retained-literal-original-shared-storage-20261018/result.json');retained.pop('offline_run')
                check('Hello exact accepted shared result',shared==retained)
                check('Hello partial subtotal2312 backing768',ledger['known_selected_GGC_event_subtotal']==2312
                    and shared['additional_shared_GGC_backing_request_events_upper']==768)
            if name=='5000_calls':
                check('5000 old failure retained with refined pass',historical['link']['failed_sufficient_checks']==
                    ['fixed_signed_relocation_reach'] and prior_shared['retained_aggregate_failed_conditional_predicates']==
                    ['literal_output_linker_representation'] and refinement['predecessor_failed_checks']==
                    ['fixed_signed_relocation_reach'] and link['link']['failed_sufficient_checks']==[])
            summaries.append(dict(name=name,source=m.identity(raw),calls=c,nulls=n,
                partial_GGC_events=ledger['known_selected_GGC_event_subtotal'],shared_backing_events=shared['additional_shared_GGC_backing_request_events_upper'],
                old_signed_bound=historical['link']['relocation_bounds']['common_signed32'],
                refined_signed_bound=refinement['operand_domains']['common_signed32'],conditional_arithmetic_pass=current['conditional_arithmetic_pass'],
                historical_failed_linker_checks=historical['link']['failed_sufficient_checks'],unresolved_predicates=current['unresolved_predicates']))
        for name,path,value in [('helper multiplicity',['native_original_String_storage','helper94_additions'],2),
            ('collector demand',['native_collector_callbacks','collector_callback_additional_GGC_events'],1),
            ('source count',['source_counts','output_calls'],2)]:
            changed=copy.deepcopy(projection);obj=changed
            for k in path[:-1]:obj=obj[k]
            obj[path[-1]]=value
            reject(name,lambda:m.attach_original_shared_storage(changed,ctx),'join')
        original_derive=ctx.original_shared['derive']
        def failing_shared(p,c):
            r=original_derive(p,c);r['conditions']['selected_counter_endpoints']=False
            r['selected_original_shared_container_interface_fits']=False
            return r
        ctx.original_shared['derive']=failing_shared;source.write_bytes(variants[0][1])
        failed=m.evaluate(descriptor,ctx,source);ctx.original_shared['derive']=original_derive
        check('shared failed guard affects final verdict only after inherited diagnostic',
            failed['failed_predicates']==failed['failed_conditional_predicates']==['native_original_shared_selected_counter_endpoints']
            and failed['native_original_shared_storage']['interface']['retained_aggregate_failed_conditional_predicates']==[])
        base=baseline['literal_output_linker_historical_conservative']
        for key in ('EH_signed_fields','fixed_unsigned_relocation_reach'):
            altered=copy.deepcopy(base);altered['link']['checks'][key]=False
            altered['link']['selected_output_link_representation_fits']=False
            altered['link']['failed_sufficient_checks']=[k for k,v in altered['link']['checks'].items() if not v]
            changed,_=m.attach_relocation_refinement(altered,ctx)
            check('independent linker failure retained '+key,key in changed['link']['failed_sufficient_checks']
                and not changed['selected_literal_assembler_and_linker_representation_fits'])
        altered=copy.deepcopy(base);altered['link']['relocation_bounds']['common_signed32']+=1
        reject('wrong conservative predecessor',lambda:m.attach_relocation_refinement(altered,ctx),'exact predecessor')
    roots=dict(gcc=args.gcc_root,ada=args.ada_root,plugin=args.plugin_include)
    reader=m.read_historical_repository_file
    def corrupt_history(rev,path):
        raw=reader(rev,path)
        return raw+b'\n' if rev==revision and path.endswith('/compose.py') else raw
    m.read_historical_repository_file=corrupt_history
    reject('historical aggregate pin mutation',lambda:m.verify_shared_attachment(roots),'predecessor input join')
    m.read_historical_repository_file=reader
    read=m.read
    for filename,fragment in [('inputs.json','predecessor input join'),('sources.json','complete source join')]:
        def corrupt_current(path):
            r=read(path)
            if Path(path)==m.EVIDENCE/'retained-literal-original-shared-storage-20261018'/filename:
                row=r[0] if isinstance(r,list) else r['files'][0];row['sha256']='0'*64
            return r
        m.read=corrupt_current
        reject('shared current '+filename+' mutation',lambda:m.verify_shared_attachment(roots),fragment)
        m.read=read
    record=dict(checks=len(rows),all_passed=True,checks_detail=rows,actual_source_cases=summaries,
        selected_model='GPT-6 Astra',selected_effort='Extra High',runtime_model_confirmation=None,token_cost_measurements=None,
        broad_leaf_or_aggregate_success_rerun=False,native_tool_executions=0,
        started_utc=started,completed_utc=datetime.now(timezone.utc).isoformat(),elapsed_seconds=time.perf_counter()-timer)
    args.output.write_text(json.dumps(record,indent=2)+'\n')
    print(json.dumps({k:record[k] for k in ('checks','all_passed','native_tool_executions','elapsed_seconds')}))


if __name__=='__main__':main()
