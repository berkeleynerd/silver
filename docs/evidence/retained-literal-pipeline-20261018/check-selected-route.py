#!/usr/bin/env python3
"""One affected selected-route attachment run; no predecessor/broad suites."""
import argparse
import copy
from datetime import datetime, timezone
import json
from pathlib import Path
import runpy
import tempfile
import time

HERE=Path(__file__).resolve().parent


def main():
    started=datetime.now(timezone.utc).isoformat(); timer=time.perf_counter()
    m=runpy.run_path(str(HERE/'selected-route.py'))
    parser=argparse.ArgumentParser(description=__doc__)
    runpy.run_path(str(HERE/'compose.py'))['arguments'](parser)
    parser.add_argument('--output',type=Path,required=True); args=parser.parse_args()
    ctx=m['Context'](args.gcc_root,args.ada_root,args.plugin_include,args.gcc_match)
    rows=[]; summaries=[]

    def check(name,value):
        if not value:raise AssertionError(name)
        rows.append(dict(name=name,passed=True))

    def reject(name,fn,fragment):
        try:fn()
        except ValueError as exc:check(name,fragment in str(exc))
        else:raise AssertionError(name+' accepted')

    hello=(m['REPO']/'samples/hello_world.adb').read_bytes()
    shell=b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin\n'; tail=b'\nend Main;\n'
    variants=[('Hello',hello,True),
        ('mixed_empty_8192',shell+b'Silver_IO.Put (""); null; Silver_IO.Put_Line ("'+b'x'*8192+b'");'+tail,True),
        ('5000_calls',shell+b'Silver_IO.Put ("x");\n'*5000+tail,True),
        ('32766_calls',shell+b'Silver_IO.Put ("x");\n'*32766+tail,False)]
    (m['REPO']/'tmp').mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='selected-route-',dir=m['REPO']/'tmp') as temp:
        source=Path(temp)/'main.adb'
        for name,raw,passing in variants:
            source.write_bytes(raw)
            result=m['evaluate'](HERE/'selected-route.json',ctx,None if name=='Hello' else source)
            core=result['core_result']; invocation=result['selected_native_invocation']; numeric=result['native_Ada_numeric']
            frontend=result['selected_native_frontend_storage'];location=result['selected_native_location_lifetime']
            c=result['source_counts']['output_calls']
            check(name+' same actual source identities',result['source']==core['source']==invocation['source_identity']==m['identity'](raw)
                and numeric['source']['sha256']==result['source']['sha256'])
            check(name+' all old predicates preserved except three source gaps',all(result['conditions'][k]==
                (core['conditional_conditions'][k] if k in m['CLOSED'] else v) for k,v in core['conditions'].items())
                and all(result['conditional_conditions'][k]==v for k,v in core['conditional_conditions'].items()))
            check(name+' selected final diagnostics',result['evaluated_predicates_pass']==passing
                and result['conditional_arithmetic_pass']==passing and result['unresolved_predicates']==[]
                and set(core['unresolved_predicates'])==set(m['CLOSED'])
                and ('historical-in-derivation' in result['core_result_scope']))
            check(name+' selected source assessments closed independently of production',all(
                result['source_family_condition_assessments'][k]['source_family_premises_closed']
                and not result['source_family_condition_assessments'][k]['production_launcher_adopted'] for k in m['CLOSED']))
            check(name+' all numeric guards conjunctive',all(result['conditions']['native_Ada_numeric_'+k]==v
                for k,v in numeric['checks'].items()) and numeric['demands']==dict(Uints=28420+9*c,
                    Udigits=107726+(70+ctx.numeric_context.model['uint_digits'](c+2))*c,Ureals=67,Rep_Table=504))
            storage=result['frontend_location_join'];current=result['selected_current_source_bound_shared_storage']
            old_shared=core['native_original_shared_storage']['interface']
            check(name+' all new storage guards conjunctive',all(result['conditions'][k]==v
                and result['conditional_conditions'][k]==v for k,v in storage['guards'].items())
                and len(result['conditions'])==len(core['conditions'])+8+len(storage['guards']))
            check(name+' frontend same source numeric paths and node arrays',frontend['source']==result['source']
                and frontend['components']['numeric']==numeric and frontend['selected_launch']['native']==invocation['graph']['native']
                and frontend['components']['gigi_array_and_name_input']['each_association_array_raw_bytes_upper']==
                    8*frontend['joined_logical_tables']['node_identities'])
            check(name+' current indexed source and filename population',frontend['exported_source_entry_bounds']['permanent_source_entries_upper']==1589
                and frontend['exported_source_entry_bounds']['Source_File_backing_demand']==1590
                and current['filename_ingress']['lookup_calls_upper']==1590
                and current['filename_ingress']['direct_GGC_requests_upper']==3180)
            check(name+' identifier history is corrected actual source',current['source']==result['source']
                and current['source_counts']==result['source_counts']
                and current['identifier_hash']['incoming_historical_insertions_upper']==40847
                and current['identifier_hash']['historical_insertions_upper']==40847+old_shared['source_bound_demands']['identifier_new_entries']
                and current['counter_endpoints']['next_temporary_name_serial_upper']==old_shared['counter_endpoints']['next_temporary_name_serial_upper']+1)
            check(name+' warning boundary and delta ownership',location['later_warning']['incoming']==core['native_warning_map_demand']['conditional_map_transfer']
                and location['additional_location_and_later_warning_GGC_events_upper']==
                    location['ad_hoc_storage']['additional_GGC_backing_requests_upper']+location['later_warning']['additional_GGC_backing_requests_upper']
                and not location['filename_ingress']['included_in_new_location_warning_delta']
                and current['extra_shared_GGC_backing_events']==0
                and current['additional_shared_GGC_backing_request_events_upper']==old_shared['additional_shared_GGC_backing_request_events_upper'])
            check(name+' ordinary line premises and individual Dope bound',all(storage['ordinary_map_line_checks'].values())
                and storage['virtual_Dope_Rec']['individual_caller_bytes']==8 and storage['virtual_Dope_Rec']['objects_upper']==9
                and not frontend['components']['physical_sources']['virtual_source_Dope_Rec_metadata_storage_priced_here'])
            check(name+' immutable core GGC ledger unchanged',core['native_original_shared_storage']['partial_ledger']==
                ctx.core['attach_original_shared_storage'](dict(source=core['source'],source_counts=core['source_counts'],
                    complete_path_bound=core['complete_path_bound'],**{k:core[k] for k in
                    core['native_original_shared_storage']['source_capacity_projection_keys'] if k not in ('source','source_counts','complete_path_bound')},
                    whole_literal_pipeline_capacity_established=False,
                    unresolved_predicates=core['unresolved_predicates'],
                    failed_conditional_predicates=[k for k,v in core['conditional_conditions'].items()
                        if not k.startswith('native_original_shared_') and not v]),ctx.core_context)['partial_ledger'])
            check(name+' missing totals and broad flags remain open',result['complete_imported_allocation_events'] is None
                and result['complete_imported_allocation_bytes'] is None and not any(result[k] for k in
                ('whole_literal_pipeline_capacity_established','complete_native_capacity','complete_proof_pipeline_capacity',
                 'complete_parent_storage_closed','production_launcher_adopted','production_admission_changed','aggregate_RAM_gate'))
                and not invocation['proof_library_verification_waived'] and invocation['fixed_Silver_compile_jobs']==0)
            check(name+' 39 linker guards and exact conservative input preserved',invocation['link_interface']==core['literal_output_linker_historical_conservative']
                and len(core['literal_output_linker_refinement']['unchanged_other_checks'])==39
                and all(core['literal_output_linker']['link']['checks'][k]==v for k,v in
                    core['literal_output_linker_refinement']['unchanged_other_checks'].items()))
            if name=='Hello':
                baseline=result
                check('Hello accepted numeric exact equality',numeric==m['read'](m['E']/'retained-literal-ada-numeric-20261018/result.json'))
                check('Hello separate partial2312 and numeric28429',core['native_original_shared_storage']['partial_ledger']['known_selected_GGC_event_subtotal']==2312
                    and numeric['demands']['Uints']==28429)
            if name=='5000_calls':
                check('5000 old conservative failure remains diagnostic',invocation['link_interface']['link']['failed_sufficient_checks']==['fixed_signed_relocation_reach']
                    and core['literal_output_linker']['link']['failed_sufficient_checks']==[] and result['failed_predicates']==[])
            if name=='32766_calls':
                check('scope digit transition returns numeric success and linker failure',
                    numeric['demand_rows']['Main_constructor']['Udigits']==62*c
                    and numeric['all_selected_checks_pass']
                    and 'literal_output_linker_representation' in result['failed_predicates'])
            summaries.append(dict(name=name,source=result['source'],calls=c,demands=numeric['demands'],
                evaluated_predicates_pass=result['evaluated_predicates_pass'],failed_predicates=result['failed_predicates'],
                unresolved_predicates=result['unresolved_predicates'],core_unresolved_predicates=core['unresolved_predicates']))
        core=baseline['core_result'];invocation=baseline['selected_native_invocation'];numeric=baseline['native_Ada_numeric']
        frontend=baseline['selected_native_frontend_storage'];location=baseline['selected_native_location_lifetime']
        real_join=m['attach'].__globals__['join_frontend_location']
        for key in baseline['frontend_location_join']['guards']:
            def forced(*a, key=key, **kw):
                joined=real_join(*a,**kw);joined['guards'][key]=False;return joined
            m['attach'].__globals__['join_frontend_location']=forced
            try:r=m['attach'](hello,core,invocation,numeric,frontend,location,ctx)
            finally:m['attach'].__globals__['join_frontend_location']=real_join
            check('new guard failure stays independently conjunctive '+key,key in r['failed_predicates']
                and not r['evaluated_predicates_pass'] and not r['conditional_arithmetic_pass'])
        for label,target,path,value,fragment in [
            ('frontend source',frontend,['source','sha256'],'0'*64,'actual source/count'),
            ('frontend path',frontend,['selected_launch','native','configuration'],'/wrong.adc','path/configuration'),
            ('frontend actual map',frontend,['mapping','records'],1,'actual mapping'),
            ('frontend physical bytes',frontend,['components','physical_sources','extra_physical_objects','Main','bytes'],1,'physical source identity'),
            ('frontend numeric double charge',frontend,['numeric_lifetime_projection','Uints'],1,'numeric projection'),
            ('frontend node table',frontend,['components','core_tables','tables','Node_Offsets','demand'],1,'node and association'),
            ('frontend transient ownership',frontend,['exported_source_entry_bounds','permanent_source_entries_upper'],1590,'source population'),
            ('frontend patterns lifetime',frontend,['components','physical_sources','pattern_String_allocations_upper'],6,'pattern String lifetime'),
            ('location source',location,['source','sha256'],'0'*64,'actual source/count'),
            ('location old warning boundary',location,['later_warning','incoming','original_gigi_put_call_ceiling'],1,'warning R5'),
            ('location filename double charge',location,['filename_ingress','included_in_new_location_warning_delta'],True,'warning R5'),
            ('location prefix double charge',location,['ad_hoc_storage','initial_ordinary_objects_added_again'],1,'warning R5'),
            ('location total GGC claim',location,['total_GGC_events'],1,'warning R5'),
            ('location Main line identity',location,['Main_physical_line_entries_upper'],1,'ordinary-map line')]:
            changed=copy.deepcopy(target);obj=changed
            for k in path[:-1]:obj=obj[k]
            obj[path[-1]]=value
            ff,ll=(changed,location) if target is frontend else (frontend,changed)
            reject(label,lambda:m['attach'](hello,core,invocation,numeric,ff,ll,ctx),fragment)
        changed=copy.deepcopy(core);changed['native_original_shared_storage']['interface']['source']['sha256']='0'*64
        reject('retained Hello cannot impersonate actual source-bound shared',lambda:m['attach'](hello,changed,invocation,numeric,frontend,location,ctx),'shared projection source')
        original_abi=ctx.dope_abi;ctx.dope_abi=dict(original_abi,individual_caller_bytes=16)
        try:reject('changed Dope object ABI',lambda:m['attach'](hello,core,invocation,numeric,frontend,location,ctx),'Dope_Rec individual-object ABI')
        finally:ctx.dope_abi=original_abi
        for key in numeric['checks']:
            changed=copy.deepcopy(numeric);changed['checks'][key]=False;changed['all_selected_checks_pass']=False
            changed_front=copy.deepcopy(frontend);changed_front['components']['numeric']=changed
            r=m['attach'](hello,core,invocation,changed,changed_front,location,ctx)
            check('numeric guard failure stays conjunctive '+key,'native_Ada_numeric_'+key in r['failed_predicates']
                and not r['evaluated_predicates_pass'])
        for key in ('selected_native_launch_graph_computable','selected_main_emission_to_GAS_object_route_bound',
                    'selected_fixed_link_input_materialization_computable'):
            changed=copy.deepcopy(invocation);changed[key]=False
            r=m['attach'](hello,core,changed,numeric,frontend,location,ctx)
            check('invocation guard failure stays conjunctive '+key,'native_invocation_'+key in r['failed_predicates'])
        for label,path,value,fragment in [
            ('source identity',['source_identity','sha256'],'0'*64,'source/count'),
            ('counts',['source_counts','output_calls'],2,'source/count'),
            ('common path',['common_Main_bindings','phase1','path'],'/tmp/wrong/main.adb','common Main'),
            ('System',['shared_System','identity','bytes'],1,'configuration/System'),
            ('emission',['emission_interface','final_chain'],1,'exact emission'),
            ('link input',['link_interface','link','layout','retained_endpoint'],1,'conservative linker'),
            ('binder family',['binder_object_family','GGC_events_upper'],1,'binder family')]:
            changed=copy.deepcopy(invocation);obj=changed
            for k in path[:-1]:obj=obj[k]
            obj[path[-1]]=value
            reject(label,lambda:m['attach'](hello,core,changed,numeric,frontend,location,ctx),fragment)
        changed=copy.deepcopy(invocation)
        next(row for row in changed['materialization'] if row['role']=='silver_io.o')['identity']['bytes']=1
        reject('fixed object hash',lambda:m['attach'](hello,core,changed,numeric,frontend,location,ctx),'fixed object/linker')
        changed=copy.deepcopy(core);changed['Main_assembler_object_interface']['ELF']['file_bytes_upper']=-1
        reject('exact ELF interface',lambda:m['attach'](hello,changed,invocation,numeric,frontend,location,ctx),'assembly/ELF/storage')
        changed=copy.deepcopy(numeric);changed['demand_rows']['original_Main_constant_size_callbacks']['Uints']+=1
        reject('numeric ownership',lambda:m['attach'](hello,core,invocation,changed,frontend,location,ctx),'numeric demand ownership')
        descriptor=m['read'](HERE/'selected-route.json');descriptor['core_descriptor']=str(HERE/'selected-core-fixture.json')
        descriptor['runtime']['cwd']='/tmp/silver-literal-pipeline-20261018'
        path=Path(temp)/'route.json';path.write_text(json.dumps(descriptor))
        reject('historical short root cannot impersonate graph',lambda:m['evaluate'](path,ctx),'accepted source and temporary path classes')
        check('fixed route path conventions',len(invocation['graph']['project_root'])==109 and
            invocation['path_bytes']==513 and core['complete_path_bound']==512)
        check('historical fixture unchanged and distinct route',m['read'](HERE/'fixture.json')['launch']['native_Main'] !=
            core['launch']['native_Main'] and ctx.core_context.original_shared_source_validation['current_repository_files_verified']==35)
        baseline['offline_run']=dict(started_utc=started,completed_utc=datetime.now(timezone.utc).isoformat(),
            scope='Hello generated once within affected attachment check; no separate replay')
        (HERE/'selected-route-result.json').write_text(json.dumps(baseline,indent=2)+'\n')
    output=dict(started_utc=started,completed_utc=datetime.now(timezone.utc).isoformat(),elapsed_seconds=time.perf_counter()-timer,
        checks=len(rows),passed=rows,variants=summaries,validation=ctx.validation,
        implementation_inputs={name:m['identity']((HERE/name).read_bytes()) for name in
            ('selected-route.py','selected-route.json','selected-core-fixture.json','selected-route-inputs.json','check-selected-route.py')},
        native_tool_executions=0,predecessor_suites_rerun=False,broad_suites_rerun=False,
        selected_model='GPT-6.1 Sol',selected_effort='Extra High',runtime_confirmed_model_effort=None,token_cost_measurements=None,
        validation_rework=dict(scope='New frontend/location/source-bound indexed shared attachment only.',
            initial_new_attachment_smoke='57 checks passed in11.662330seconds; new guard/ownership/identity assertions added for required coverage, then rerun only this affected harness.',
            earlier_selected_route_evidence='106 checks before9091e36fb2 retained in repository history before this attachment; not rerun as a predecessor suite.',
            preserved_leaf_successes='frontend43/52,location140/191,numeric57/106 retained; no corpus inventory repeated.'))
    args.output.write_text(json.dumps(output,indent=2)+'\n')
    print(json.dumps({k:output[k] for k in ('checks','elapsed_seconds','native_tool_executions')}))


if __name__=='__main__':main()
