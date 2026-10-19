#!/usr/bin/env python3
"""Focused actual-source GGC attachment checks; no predecessor suite replay."""
import argparse
import copy
from datetime import datetime, timezone
import json
from pathlib import Path
import platform
import runpy
import tempfile
import time

HERE = Path(__file__).resolve().parent


def main():
    start,timer = datetime.now(timezone.utc).isoformat(),time.perf_counter()
    m = runpy.run_path(str(HERE/'compose.py'))
    parser = argparse.ArgumentParser(description=__doc__)
    runpy.run_path(str(m['PIPELINE']/'compose.py'))['arguments'](parser)
    parser.add_argument('--output',type=Path,required=True)
    args = parser.parse_args()
    ctx = m['Context'](args.gcc_root,args.ada_root,args.plugin_include,args.gcc_match)
    checks,variants = [],[]
    def check(name,value):
        if not value: raise AssertionError(name)
        checks.append(name)
    def reject(name,fn,fragment):
        try: fn()
        except ValueError as exc:
            if fragment not in str(exc): raise AssertionError(name+': expected '+fragment+'; got '+str(exc)) from exc
            check(name,True)
        else: raise AssertionError(name+' accepted')
    def mutate(obj,path,value):
        result = copy.deepcopy(obj); target = result
        for key in path[:-1]: target = target[key]
        target[path[-1]] = value
        return result
    check('complete frozen current and historical packets and source sets checked',
        ctx.validation['accepted_current_and_historical_records']==18 and
        ctx.validation['native']==dict(gcc=46,repository=29) and
        ctx.validation['no_new_historical_input_exception'] is True)
    captured=[]
    original_evaluate=ctx.prior['evaluate']
    def capture(*a,**kw):
        result=original_evaluate(*a,**kw);captured.append(result);return result
    ctx.prior['evaluate']=capture
    hello=(m['REPO']/'samples/hello_world.adb').read_bytes()
    shell=b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin\n'
    sources=[('Hello',hello),('equal_counts_different_bytes',hello.replace(b'Hello, world!',b'Other, world!')),
        ('mixed_empty_literals_and_nulls',shell+b'Silver_IO.Put (""); null; Silver_IO.Put_Line ("xy"); null;\nend Main;\n'),
        ('larger_C_and_N',shell+b'Silver_IO.Put ("x"); null;\n'*6+b'end Main;\n'),
        ('collector_pointer_growth',shell+b'Silver_IO.Put ("x"); null;\n'*10+b'end Main;\n')]
    preserve=['core_result','selected_native_MEM_counter_lifetime','selected_native_SSA_lifetime_extension',
        'selected_native_shared_query_lifetime','selected_native_shared_bitmap_pool_lifetime',
        'selected_native_finalizer_lifetime','mem_ssa_attachment','lifetime_attachment','pool_finalizer_attachment']
    scope_flags=['whole_literal_pipeline_capacity_established','complete_native_capacity',
        'complete_proof_pipeline_capacity','complete_parent_storage_closed','production_launcher_adopted',
        'production_admission_changed','aggregate_RAM_gate']
    with tempfile.TemporaryDirectory(prefix='ggc-attachment-',dir=m['REPO']/'tmp') as tmp:
        path=Path(tmp)/'main.adb'
        for name,raw in sources:
            path.write_bytes(raw)
            r=m['evaluate'](m['PIPELINE']/'selected-route.json',ctx,None if name=='Hello' else path)
            prior=captured[-1];a=r['ggc_attachment'];ledger=r['selected_native_GGC_ledger'];c=r['source_counts']['output_calls'];n=r['source_counts']['null_statements']
            rows={x['owner']:x for x in ledger['owner_rows']}
            check(name+' actual bytes counts path launch and finalizer owners joined',
                ledger['source']==r['source']==m['identity'](raw) and ledger['source_counts']==r['source_counts'] and
                ledger['source_path']==r['source_path'] and ledger['launch']==r['launch'] and
                a['actual_finalizer_scalar_array_depth_initialization_and_callbacks_joined'])
            check(name+' inherited219 and new17 conjunctive236 predicates',
                len(prior['conditions'])==219 and len(r['conditions'])==236 and len(a['guards'])==17 and
                all(r['conditions'][k]==v for k,v in prior['conditions'].items()) and
                all(r['conditional_conditions'][k]==v for k,v in prior['conditional_conditions'].items()) and
                r['evaluated_predicates_pass'] and r['conditional_arithmetic_pass'] and
                not r['failed_predicates'] and not r['unresolved_predicates'])
            check(name+' all predecessor complete ordinary and event owners unchanged',
                all(r[k]==prior[k] for k in preserve) and a['existing_ordinary_cold_and_all_predecessor_event_owners_preserved'])
            check(name+' exact source-sensitive new rows and existing gimplifier owner',
                rows['expansion_CALL_EXPR_trees']['positive_GGC_requests_upper']==c and
                rows['second_LRA_unshare_nonchain']['positive_GGC_requests_upper']==664*c+n+16 and
                rows['CFI_nonchain_and_backings']['positive_GGC_requests_upper']==4*n+39 and
                rows['Main_gimplifier_trees_and_tuples']['positive_GGC_requests_upper']==51*c+11*n+5)
            check(name+' unique50 owners exclude zero leaves and duplicate subtotals',
                len(rows)==len(ledger['owner_rows'])==50 and
                sum(x['positive_GGC_requests_upper'] for x in rows.values())==ledger['total_positive_GGC_events_upper'] and
                not ledger['ownership']['original_subtotal_added_as_an_extra_row'] and
                ledger['gimplifier_exhaustion']['new_events']==0 and not a['zero_pool_finalizer_delta_recharged'])
            collector=ledger['collector'];f=r['selected_native_finalizer_lifetime']
            check(name+' current scalar depth array and marker owners preserved once',
                (collector['scalar_finalizer_history_upper'],collector['scalar_finalizer_capacity_upper'],collector['scalar_finalizer_backing_bytes_upper'])==(39275,58911,942584) and
                collector['context_depth']==collector['array_finalizer_registrations']==collector['callback_GGC_events']==0 and
                collector['depth_backing_bytes']==collector['each_outer_finalizer_backing_bytes']==40 and
                collector['marker_ordinary_request_bytes_each']==104 and
                f['existing_ordinary_initialization']==ctx.prior_context.initialization and
                not f['initialization_and_scalar_owners_recharged'])
            cap=1 << (max(128,ledger['total_positive_GGC_events_upper'])-1).bit_length()
            check(name+' count pages and least power2 indexed pointer backing exposed conditionally',
                r['selected_positive_GGC_events_upper']==r['selected_active_pages_upper']==ledger['total_positive_GGC_events_upper'] and
                collector['each_pointer_vector_capacity_upper']==cap and collector['each_pointer_vector_request_bytes_upper']==8*cap and
                r['selected_collector_indexed_storage_capacity_established'] and
                a['source_event_partition_is_conditional_on_all_arithmetic'] and a['ledger_status']=='computed')
            check(name+' ordinary native producer proof parent and whole grammar remain open',
                all(r[k] is False for k in scope_flags) and r['complete_imported_allocation_events'] is
                r['complete_imported_allocation_bytes'] is None and not ledger['complete_all_ordinary_native_capacity'] and
                len(ledger['remaining_ordinary_owners'])==4 and collector['actual_collection_count'] is None and
                not collector['scheduling_counters_require_cumulative_byte_no_wrap'] and
                a['frozen_leaf_pending_and_incomplete_flags_preserved_as_history'])
            if name=='Hello':
                baseline,incoming=r,prior
                frozen=m['read'](m['LEDGER']/'result.json')
                check('Hello ledger equals accepted source theorem except actual source path',
                    {k:v for k,v in ledger.items() if k!='source_path'}=={k:v for k,v in frozen.items() if k!='source_path'})
                check('Hello47054 pages65536 pointers524288 bytes scalar942584',
                    r['selected_positive_GGC_events_upper']==47054 and cap==65536 and
                    collector['each_pointer_vector_request_bytes_upper']==524288 and
                    rows['GNAT_node_association_arrays']['each_raw_request_bytes_upper']==330352)
            elif name=='equal_counts_different_bytes':
                check('equal counts do not reuse Hello source identity',{k:v for k,v in r['source_counts'].items() if k!='source_sha256'}==
                    {k:v for k,v in baseline['source_counts'].items() if k!='source_sha256'} and
                    r['source']!=baseline['source'] and ledger['source']!=baseline['selected_native_GGC_ledger']['source'])
            else:
                check(name+' count variation changes actual bound',r['source_counts']!=baseline['source_counts'] and
                    r['selected_positive_GGC_events_upper']!=47054)
            if name=='collector_pointer_growth':
                check('actual source crosses collector pointer allocation boundary',
                    r['selected_positive_GGC_events_upper']>65536 and cap==131072 and
                    collector['each_pointer_vector_request_bytes_upper']==1048576)
            variants.append(dict(name=name,source=r['source'],counts=r['source_counts'],guards=len(r['conditions']),
                positive_GGC_events_upper=r['selected_positive_GGC_events_upper'],pointer_capacity=cap,
                passed=r['evaluated_predicates_pass']))
        # Genuine source/path/configuration/ownership failures survive the
        # arithmetic short-circuit. The file for Hello remains materialized.
        first=next(iter(incoming['conditions']))
        failed=copy.deepcopy(incoming);failed['conditions'][first]=failed['conditional_conditions'][first]=False
        bads=[
            (['source','sha256'],'0'*64,'actual source'),
            (['source_counts','null_statements'],1,'actual source counts'),
            (['core_result','source_path'],incoming['source_path']+'x','exact source path'),
            (['launch'],{},'path/launch equality'),
            (['selected_native_frontend_storage','source','sha256'],'0'*64,'same-source'),
            (['selected_native_invocation','processes',0,'argv'],['plugin-added'],'selected invocation'),
            (['selected_native_invocation','processes',0,'environment','EXTRA'],'1','selected invocation'),
            (['core_result','native_initial_SSA_lifetime','ordinary_requests','shared_default_bitmap_headers_upper'],0,'ordinary cold'),
            (['core_result','native_initial_CF_CFG_lifetime','ordinary_requests','shared_default_bitmap_headers_upper'],0,'ordinary cold'),
            (['core_result','native_SSA_helper_backing','ranger_per_instance','bitmap_obstack_initial_chunks_upper'],0,'ordinary cold'),
            (['selected_native_finalizer_lifetime','context_depth'],1,'finalizer source theorem'),
            (['selected_native_finalizer_lifetime','scalar_history_upper'],39276,'finalizer source theorem'),
            (['selected_native_shared_bitmap_pool_lifetime','LRA_additional_pools','invariant_vector_initial_slots_already_owned'],0,'pool source theorem'),
            (['selected_current_source_bound_shared_storage','filename_ingress','direct_GGC_requests_upper'],3178,'filename'),
            (['core_result','native_gimplifier_ingress','selected_helper_subtotal_GGC_events_upper'],6,'gimplifier'),
            (['core_result','native_lowering_data','conditional_native_selected_constructor_requests','selected_nonchain_RTX_lifetime_requests_upper'],120,'operation'),
            (['core_result','selected_native_backing','DF_selected_reference_and_solver_transfer','selected_REG_DEAD_UNUSED_note_requests_upper'],0,'accepted RTL backing'),
            (['core_result','native_original_shared_storage','partial_ledger','GGC_groups','original_Main'],1060,'original exact'),
            (['selected_native_frontend_storage','components','gigi_array_and_name_input','association_array_requests'],0,'association'),
            (['core_result','native_collector_callbacks','collector_callback_additional_GGC_events'],1,'callback')]
        for obj,label in [(incoming,'passing'),(failed,'failed prerequisite')]:
            for path_,value,fragment in bads:
                reject(label+' genuine mismatch '+'.'.join(map(str,path_)),
                    lambda obj=obj,path_=path_,value=value:m['attach'](hello,mutate(obj,path_,value),ctx),fragment)
        reject('equal counts different raw source rejected even on failed path',
            lambda:m['attach'](sources[1][1],failed,ctx),'actual source identity')
    for obj,label in [(incoming,'passing'),(failed,'failed prerequisite')]:
        changed=copy.deepcopy(obj)
        changed['launch']['native_Main']=changed['core_result']['launch']['native_Main']='/tmp/other/main.adb'
        reject(label+' equal mutated launch records rejected by actual invocation',
            lambda changed=changed:m['attach'](hello,changed,ctx),'common Main path')
        changed=copy.deepcopy(obj)
        changed['launch']['native_options']=changed['core_result']['launch']['native_options']=['-fplugin=other']
        reject(label+' equal mutated launch options rejected',
            lambda changed=changed:m['attach'](hello,changed,ctx),'exact accepted launch options')
    ctx.prior['evaluate']=original_evaluate
    original_native=ctx.native['compose']
    def must_not_run(*a,**kw): raise AssertionError('native evaluation on failed inherited arithmetic')
    ctx.native['compose']=must_not_run
    for key in incoming['conditions']:
        changed=copy.deepcopy(incoming);changed['conditions'][key]=changed['conditional_conditions'][key]=False
        r=m['attach'](hello,changed,ctx);a=r['ggc_attachment']
        check('inherited false guard shortcircuits and is retained '+key,
            r['failed_predicates']==r['failed_conditional_predicates']==[key] and
            len(r['unresolved_predicates'])==17 and r['selected_native_GGC_ledger'] is None and
            r['selected_positive_GGC_events_upper'] is r['selected_active_pages_upper'] is None and
            not r['evaluated_predicates_pass'] and not r['conditional_arithmetic_pass'] and
            not r['selected_collector_indexed_storage_capacity_established'] and
            a['ledger_status']=='not_computed_upstream_arithmetic' and not a['native_evaluation_performed'] and
            all(v is None for v in a['guards'].values()) and all(r[k]==changed[k] for k in preserve))
    for field in ('conditions','conditional_conditions'):
        changed=copy.deepcopy(incoming);changed[field][first]=False
        r=m['attach'](hello,changed,ctx)
        check('each separate upstream condition map shortcircuits '+field,
            r['selected_native_GGC_ledger'] is None and not r['evaluated_predicates_pass'] and not r['conditional_arithmetic_pass'])
    for path_ in (['conditional_arithmetic_pass'],['core_result','conditional_arithmetic_pass']):
        r=m['attach'](hello,mutate(incoming,path_,False),ctx)
        check('upstream capacity summary shortcircuits '+'.'.join(path_),r['selected_native_GGC_ledger'] is None and not r['evaluated_predicates_pass'])
    ctx.native['compose']=original_native
    ledger0=baseline['selected_native_GGC_ledger']
    def patch(ledger):
        ctx.native['compose']=lambda *a,**kw:copy.deepcopy(ledger)
        try:return m['attach'](hello,incoming,ctx)
        finally:ctx.native['compose']=original_native
    for key in ledger0['local_representation_checks']:
        r=patch(mutate(ledger0,['local_representation_checks',key],False));name='native_GGC_'+key
        check('new false local arithmetic remains computed and failed '+key,
            r['failed_predicates']==r['failed_conditional_predicates']==[name] and not r['unresolved_predicates'] and
            r['selected_native_GGC_ledger'] is not None and r['ggc_attachment']['ledger_status']=='computed' and
            not r['evaluated_predicates_pass'] and not r['selected_collector_indexed_storage_capacity_established'])
    r=patch(mutate(ledger0,['conditional_selected_GGC_and_collector_storage_capacity'],False))
    check('new false capacity conjunction retained',r['failed_predicates']==['native_GGC_conditional_capacity'] and
        not r['conditional_arithmetic_pass'] and r['ggc_attachment']['ledger_status']=='computed')
    reject('nonboolean new arithmetic rejected',lambda:patch(mutate(ledger0,['local_representation_checks','active_page_signed_index'],1)), 'boolean native')
    reject('nonboolean inherited arithmetic rejected',lambda:m['attach'](hello,mutate(incoming,['conditions',first],1),ctx),'boolean inherited')
    for path_,value,fragment in [
        (['source','sha256'],'0'*64,'actual source/path/launch'),
        (['owner_rows',0,'owner'],'filename_ingress','unique complete'),
        (['total_positive_GGC_events_upper'],47053,'unique complete'),
        (['ownership','original_subtotal_added_as_an_extra_row'],True,'zero and subtotal'),
        (['collector','scalar_finalizer_history_upper'],47054,'actual finalizer'),
        (['collector','depth_backing_bytes'],80,'actual finalizer'),
        (['collector','each_outer_finalizer_backing_bytes'],80,'actual finalizer'),
        (['collector','callback_GGC_events'],1,'actual finalizer'),
        (['complete_all_ordinary_native_capacity'],True,'indexed-only'),
        (['aggregate_RAM_gate'],True,'indexed-only')]:
        reject('returned native mismatch '+'.'.join(map(str,path_)),lambda path_=path_,value=value:patch(mutate(ledger0,path_,value)),fragment)
    # New narrow arithmetic boundaries reuse pure accepted formulas. No source
    # theorem or large-source admission is inferred from these count-only cases.
    bounds=[]
    for c in (ctx.native['I32']//10000,ctx.native['I32']//10000+1):
        x=ctx.native['additions'](c,0)
        check('signed hard frequency boundary '+str(c),x['local_representation_checks']['LRA_signed_hard_register_frequency']==(10000*c<=ctx.native['I32']))
        bounds.append(dict(C=c,N=0,signed_hard_frequency=x['local_representation_checks']['LRA_signed_hard_register_frequency']))
    for demand in (65535,65536,65537,ctx.native['I32'],ctx.native['I32']+1,ctx.native['U32']+1):
        cap=ctx.native['power2'](max(128,demand))
        check('page signed unsigned boundary '+str(demand),cap>=demand and
            (demand>128 or cap>=128) and (demand!=65537 or cap==131072) and
            (demand!=ctx.native['U32']+1 or cap>ctx.native['U32']))
        bounds.append(dict(positive_events=demand,capacity=cap,signed_index_fits=demand<=ctx.native['I32'],unsigned_capacity_fits=cap<=ctx.native['U32']))
    result=dict(status='passed',check_count=len(checks),checks=checks,actual_sources=variants,
        inherited_false_guards=219,new_false_guards=17,boundary_cases=bounds,new_contexts=1,
        validation=ctx.validation,started_utc=start,completed_utc=datetime.now(timezone.utc).isoformat(),
        elapsed_seconds=time.perf_counter()-timer,platform=platform.platform(),
        native_tool_executions=0,build_prover_solver_capture_runs=0,predecessor_suites_rerun=False,
        corpus_replays=0,pending_Why_CFI_candidates_consumed=False)
    args.output.write_text(json.dumps(result,indent=2)+'\n')
    baseline['offline_run']=dict(started_utc=start,completed_utc=result['completed_utc'],elapsed_seconds=result['elapsed_seconds'],
        run_kind='retained Hello from same focused five-source checker; no duplicate standalone evaluation')
    (HERE/'result.json').write_text(json.dumps(baseline,indent=2)+'\n')
    print(json.dumps({k:result[k] for k in ('status','check_count','inherited_false_guards','new_false_guards','elapsed_seconds')}))


if __name__=='__main__': main()
