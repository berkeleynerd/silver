#!/usr/bin/env python3
"""Affected ordinary-map/named-later attachment checks; no predecessor suites."""
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
        if not value: raise AssertionError(name)
        rows.append(dict(name=name,passed=True))

    def reject(name,fn,fragment):
        try: fn()
        except ValueError as exc: check(name,fragment in str(exc))
        else: raise AssertionError(name+' accepted')

    historical=json.loads(ctx.core['read_historical_repository_file']('ab12e2db3756e5871467bbcb423459291a7d76bd',
        'docs/evidence/retained-literal-pipeline-20261018/selected-route-result.json'))
    hello=(m['REPO']/'samples/hello_world.adb').read_bytes()
    shell=b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin\n'
    variants=[('Hello',hello),('equal_counts_other_source',hello.replace(b'Hello, world!',b'Other, world!')),
        ('mixed_callees',shell+b'Silver_IO.Put (""); null; Silver_IO.Put_Line ("xy");\nend Main;\n')]
    (m['REPO']/'tmp').mkdir(exist_ok=True)
    with tempfile.TemporaryDirectory(prefix='selected-map-later-',dir=m['REPO']/'tmp') as temp:
        source=Path(temp)/'main.adb'
        for name,raw in variants:
            source.write_bytes(raw)
            result=m['evaluate'](HERE/'selected-route.json',ctx,None if name=='Hello' else source)
            core=result['core_result'];storage=result['frontend_location_join']
            ordinary=result['selected_native_ordinary_map_preallocation'];later=result['selected_native_later_shared_demands']
            joined=result['ordinary_map_later_shared_join'];c=result['source_counts']['output_calls']
            check(name+' actual source bound through original corrected and named state',
                result['source']==joined['source']==later['source']==m['identity'](raw)
                and later['source_counts']==result['source_counts']
                and later['incoming_corrected_identifier_state']==result['selected_current_source_bound_shared_storage']['identifier_hash']
                and later['incoming_original_counters']==core['native_original_shared_storage']['interface']['counter_endpoints'])
            check(name+' all existing 69 condition keys unchanged',len(result['conditions'])==69
                and result['conditions'].keys()==historical['conditions'].keys()
                and result['conditions']==result['conditional_conditions'] and result['evaluated_predicates_pass'])
            check(name+' ordinary permanent not transient population',joined['permanent_source_entries_upper']==ordinary['file_count_upper']==1589
                and result['selected_native_frontend_storage']['exported_source_entry_bounds']['Source_File_backing_demand']==1590)
            check(name+' physical to logical binding and all existing line guards',joined['physical_to_logical_identity_under_no_Source_Reference']
                and joined['existing_logical_line_guards']==storage['ordinary_map_line_checks']
                and joined['ordinary_preallocation_bound_applies'] and ordinary['logical_lines_upper']==2**24
                and len(joined['virtual_template_identities'])==3)
            check(name+' three separate ordinary GGC requests and zero finalizers',
                [r['rounded_GGC_bytes'] for r in ordinary['allocation_rows']]==[8192,32768,131072]
                and ordinary['additional_GGC_events_upper']==3 and ordinary['additional_finalizers_upper']==0)
            check(name+' named ownership rows sum to2C+1 3C+2 zero and six',later['named_source_demands']==dict(
                identifier_insertions=2*c+1,DECL_UID_increments=3*c+2,type_UID_increments=0,scalar_finalizer_registrations=6)
                and sum(r['identifiers'] for r in later['consumer_rows'])==2*c+1
                and sum(r['DECL_UID'] for r in later['consumer_rows'])==3*c+2
                and sum(r['scalar_finalizers'] for r in later['consumer_rows'])==6)
            check(name+' no repeated direct or GGC costs',later['ownership']['new_direct_GGC_objects_added']==0
                and later['ownership']['new_named_shared_GGC_backing_events']==0
                and all(v==0 for k,v in later['ownership'].items() if k.endswith('added_again'))
                and not joined['existing_GGC_partial_ledger_changed'])
            check(name+' four residuals and five full endpoints remain null',
                later['explicit_residual_ceilings']==dict.fromkeys(ctx.later['RESIDUALS'])
                and all(later['conditional_full_endpoint'][k] is None for k in ('identifier_hash','scalar_finalizers',
                    'next_DECL_UID_upper','next_type_UID_upper','temporary_name_serial_upper'))
                and later['conditional_full_arithmetic_fits'] is None and later['conditional_full_endpoint']['checks']=={})
            check(name+' named projections never become lifetime guards',not later['named_only_projection']['valid_as_complete_lifetime_endpoint']
                and later['named_only_projection']['byte_bounds_exclude_interleaved_unjoined_consumers']
                and joined['named_projection_guards_added']==0 and not joined['later_named_projection_used_as_whole_lifetime_guard'])
            check(name+' complete lifetime and imported totals remain open',ordinary['total_GGC_events'] is None
                and not ordinary['complete_ordinary_map_lifetime_closed'] and not ordinary['later_ordinary_map_mutators_excluded_here']
                and later['total_GGC_events'] is None and not any(later[k] for k in
                    ('complete_later_shared_storage_closed','complete_global_counter_lifetime_closed','complete_collector_lifetime_closed',
                     'complete_gimplifier_lifetime_closed','whole_literal_pipeline_capacity_established'))
                and result['complete_imported_allocation_events'] is None and result['complete_imported_allocation_bytes'] is None
                and not any(result[k] for k in ('whole_literal_pipeline_capacity_established','complete_native_capacity',
                    'complete_proof_pipeline_capacity','complete_parent_storage_closed','production_launcher_adopted',
                    'production_admission_changed','aggregate_RAM_gate')))
            if name=='Hello':
                baseline=result
                check('Hello existing condition values and partial ledger unchanged',result['conditions']==historical['conditions']
                    and core['native_original_shared_storage']['partial_ledger']==historical['core_result']['native_original_shared_storage']['partial_ledger']
                    and result['selected_current_source_bound_shared_storage']==historical['selected_current_source_bound_shared_storage'])
                check('Hello independent accepted named result equality',later==m['read'](m['E']/'retained-literal-later-shared-storage-20261018/result.json'))
                check('Hello shared768 partial2312 location13 remain separate',
                    core['native_original_shared_storage']['interface']['additional_shared_GGC_backing_request_events_upper']==768
                    and core['native_original_shared_storage']['partial_ledger']['known_selected_GGC_event_subtotal']==2312
                    and result['selected_native_location_lifetime']['additional_location_and_later_warning_GGC_events_upper']==13)
            summaries.append(dict(name=name,source=result['source'],calls=c,source_counts=result['source_counts'],
                named_demands=later['named_source_demands'],named_only_projection=later['named_only_projection'],
                conditions=len(result['conditions']),evaluated_predicates_pass=result['evaluated_predicates_pass']))

    core=baseline['core_result'];invocation=baseline['selected_native_invocation'];numeric=baseline['native_Ada_numeric']
    frontend=baseline['selected_native_frontend_storage'];location=baseline['selected_native_location_lifetime']
    storage=baseline['frontend_location_join'];ordinary=baseline['selected_native_ordinary_map_preallocation']
    later=baseline['selected_native_later_shared_demands']
    # Only the affected assembly of existing guards is exercised; leaf suites are not rerun.
    for key in core['conditions']:
        changed=copy.deepcopy(core);changed['conditional_conditions'][key]=False
        if key not in m['CLOSED']:changed['conditions'][key]=False
        r=m['attach'](hello,changed,invocation,numeric,frontend,location,ctx)
        check('existing core guard remains conjunctive '+key,key in r['failed_predicates'] and not r['evaluated_predicates_pass'])
    globals_=m['attach'].__globals__;real_join=globals_['join_frontend_location']
    for key in storage['guards']:
        def forced(*a,key=key,**kw):
            joined=real_join(*a,**kw);joined['guards'][key]=False;return joined
        globals_['join_frontend_location']=forced
        try:r=m['attach'](hello,core,invocation,numeric,frontend,location,ctx)
        finally:globals_['join_frontend_location']=real_join
        check('existing storage guard remains conjunctive '+key,key in r['failed_predicates'] and not r['conditional_arithmetic_pass'])
    for key in numeric['checks']:
        changed=copy.deepcopy(numeric);changed['checks'][key]=False;ff=copy.deepcopy(frontend);ff['components']['numeric']=changed
        r=m['attach'](hello,core,invocation,changed,ff,location,ctx)
        check('existing numeric guard remains conjunctive '+key,'native_Ada_numeric_'+key in r['failed_predicates'])
    for key in ('selected_native_launch_graph_computable','selected_main_emission_to_GAS_object_route_bound',
                'selected_fixed_link_input_materialization_computable'):
        changed=copy.deepcopy(invocation);changed[key]=False
        r=m['attach'](hello,core,changed,numeric,frontend,location,ctx)
        check('existing invocation guard remains conjunctive '+key,'native_invocation_'+key in r['failed_predicates'])

    inputs=dict(frontend=frontend,storage=storage,ordinary=ordinary,later=later)
    for name,role,path,value,fragment in [
        ('permanent population','frontend',['exported_source_entry_bounds','permanent_source_entries_upper'],1590,'permanent population'),
        ('transient spare','frontend',['components','physical_sources','Source_File_backing_demand'],1591,'permanent population'),
        ('runtime logical table','frontend',['components','physical_sources','runtime','logical_line_table_objects'],1,'physical-to-logical'),
        ('Main Source_Reference','frontend',['components','physical_sources','extra_physical_objects','Main','checks','no_Source_Reference'],False,'physical-to-logical'),
        ('Main logical table','frontend',['components','physical_sources','extra_physical_objects','Main','logical_line_table_objects'],1,'physical-to-logical'),
        ('virtual multiplicity','frontend',['components','physical_sources','virtual_sources',0,'copies_upper'],8,'virtual template'),
        ('virtual line sharing','frontend',['components','physical_sources','virtual_sources',0,'shared_physical_text_and_line_arrays'],False,'virtual template'),
        ('logical guard','storage',['ordinary_map_line_checks','Main_ordinary_map_lines'],False,'logical last-line'),
        ('ordinary request','ordinary',['allocation_rows',1,'rounded_GGC_bytes'],1,'exact accepted preallocation'),
        ('ordinary events','ordinary',['additional_GGC_events_upper'],0,'exact accepted preallocation'),
        ('ordinary finalizers','ordinary',['additional_finalizers_upper'],1,'exact accepted preallocation'),
        ('ordinary lifetime','ordinary',['complete_ordinary_map_lifetime_closed'],True,'exact accepted preallocation'),
        ('named source','later',['source','sha256'],'0'*64,'actual original shared'),
        ('named old counters','later',['incoming_original_counters','next_DECL_UID_upper'],0,'actual original shared'),
        ('named corrected ingress','storage',['current_source_bound_shared_storage','identifier_hash','historical_insertions_upper'],0,'actual original shared'),
        ('named identifier demand','later',['named_source_demands','identifier_insertions'],0,'disjoint 2C+1'),
        ('named registration row','later',['consumer_rows',2,'scalar_finalizers'],2,'disjoint 2C+1'),
        ('named original controls double charge','later',['ownership','original_five_scalar_registrations_added_again'],1,'no repeated'),
        ('named full endpoint','later',['conditional_full_endpoint','next_DECL_UID_upper'],0,'stay null'),
        ('named invented zero residual','later',['explicit_residual_ceilings','identifier_insertions'],0,'stay null'),
        ('named full arithmetic','later',['conditional_full_arithmetic_fits'],True,'stay null'),
        ('named complete lifetime','later',['complete_later_shared_storage_closed'],True,'stay null'),
        ('named complete projection','later',['named_only_projection','valid_as_complete_lifetime_endpoint'],True,'stay null')]:
        changed=copy.deepcopy(inputs);obj=changed[role]
        for key in path[:-1]:obj=obj[key]
        obj[path[-1]]=value
        reject('reject '+name,lambda:m['join_ordinary_and_named_later'](hello,core,
            changed['frontend'],changed['storage'],changed['ordinary'],changed['later'],ctx),fragment)
    old_eval=ctx.later['evaluate_source']
    def failed_named(*a,**kw):
        value=old_eval(*a,**kw)
        value['named_only_projection']['checks']=dict.fromkeys(value['named_only_projection']['checks'],False)
        return value
    ctx.later['evaluate_source']=failed_named
    try:r=m['attach'](hello,core,invocation,numeric,frontend,location,ctx)
    finally:ctx.later['evaluate_source']=old_eval
    check('false named-only arithmetic stays diagnostic and adds no guard',r['conditions']==baseline['conditions']
        and r['evaluated_predicates_pass'] and not any(r['selected_native_later_shared_demands']['named_only_projection']['checks'].values()))
    ff=copy.deepcopy(frontend);ll=copy.deepcopy(location)
    ff['components']['physical_sources']['extra_physical_objects']['Main']['physical_line_entries_bound']=2**24+1
    ll['Main_physical_line_entries_upper']=2**24+1;ll['Main_ordinary_map_line_guard']=False
    r=m['attach'](hello,core,invocation,numeric,ff,ll,ctx)
    check('existing logical-line capacity failure returns full graph and null endpoints',
        r['failed_predicates']==['native_location_Main_ordinary_map_lines']
        and not r['ordinary_map_later_shared_join']['ordinary_preallocation_bound_applies']
        and r['selected_native_later_shared_demands']['conditional_full_arithmetic_fits'] is None)
    for fragment in ('retained-literal-ordinary-maps-20261018/derive.py','retained-literal-later-shared-storage-20261018/derive.py'):
        original_read=m['Context'].__init__.__globals__['read']
        def changed_pin(path,fragment=fragment):
            value=original_read(path)
            if Path(path)==HERE/'selected-route-inputs.json':
                value=copy.deepcopy(value);next(row for row in value['files'] if row['path'].endswith(fragment))['sha256']='0'*64
            return value
        m['Context'].__init__.__globals__['read']=changed_pin
        try:reject('reject changed new attachment identity '+fragment,
            lambda:m['Context'](args.gcc_root,args.ada_root,args.plugin_include,args.gcc_match),'selected route current input')
        finally:m['Context'].__init__.__globals__['read']=original_read
    baseline['offline_run']=dict(started_utc=started,completed_utc=datetime.now(timezone.utc).isoformat(),
        scope='Hello generated once within affected ordinary-map/named-later attachment check')
    (HERE/'selected-route-result.json').write_text(json.dumps(baseline,indent=2)+'\n')
    output=dict(started_utc=started,completed_utc=datetime.now(timezone.utc).isoformat(),elapsed_seconds=time.perf_counter()-timer,
        checks=len(rows),passed=rows,variants=summaries,validation=ctx.validation,
        implementation_inputs={name:m['identity']((HERE/name).read_bytes()) for name in
            ('selected-route.py','selected-route.json','selected-core-fixture.json','selected-route-inputs.json','check-selected-route.py')},
        native_tool_executions=0,predecessor_suites_rerun=False,broad_suites_rerun=False,runtime_census_reinventoried=False,
        selected_model='GPT-6.1 Sol',selected_effort='Extra High',runtime_confirmed_model_effort=None,token_cost_measurements=None,
        validation_scope='Affected ordinary preallocation/named-later source identity, ownership, null endpoints and preservation of all69 guard assembly only.',
        validation_rework=[
            'Attempt1 stopped after Context identity checks before source evaluation: historical reader requires a full40-character revision; checker reference corrected to exact base.',
            'Attempt2 passed source and all69 guard checks, then a corrected-ingress mutation exposed shared-object aliasing across helper inputs. New join now independently recomputes the correction from original shared input before comparison. Accepted leaves/arithmetic unchanged.'],
        reused_evidence='ordinary1609; named later40 and AST repair33; prior selected118; earlier accepted leaves unchanged; no corpus inventory or predecessor suite replay.')
    args.output.write_text(json.dumps(output,indent=2)+'\n')
    print(json.dumps({k:output[k] for k in ('checks','elapsed_seconds','native_tool_executions')}))


if __name__=='__main__':main()
