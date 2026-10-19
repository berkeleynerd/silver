#!/usr/bin/env python3
"""Affected IRA addition and changed joins; retained CFI366 is not replayed."""
import argparse
import copy
from datetime import datetime,timezone
import json
from pathlib import Path
import platform
import runpy
import tempfile
import time

HERE=Path(__file__).resolve().parent


def main():
    start,timer=datetime.now(timezone.utc).isoformat(),time.perf_counter()
    m=runpy.run_path(str(HERE/'compose.py'))
    parser=argparse.ArgumentParser(description=__doc__)
    runpy.run_path(str(m['PIPELINE']/'compose.py'))['arguments'](parser)
    parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    ctx=m['Context'](args.gcc_root,args.ada_root,args.plugin_include,args.gcc_match)
    checks,variants=[],[]
    def check(name,value):
        if not value:raise AssertionError(name)
        checks.append(name)
    def reject(name,fn,fragment):
        try:fn()
        except ValueError as exc:
            if fragment not in str(exc):raise AssertionError(name+': expected '+fragment+'; got '+str(exc)) from exc
            check(name,True)
        else:raise AssertionError(name+' accepted')
    def mutate(obj,path,value):
        result=copy.deepcopy(obj);target=result
        for key in path[:-1]:target=target[key]
        target[path[-1]]=value
        return result
    check('accepted IRA full identities plus reviewed operative LF sites',
        ctx.validation['accepted_current_and_historical_records']==27 and
        ctx.ira_inputs==dict(GCC_files=45,repository_files=19,source_excerpts=35) and
        ctx.validation['IRA_reviewed_operative_LF_sites']==7 and
        ctx.validation['frozen_IRA_excerpt_metadata_not_promoted_to_correct_LF_coordinates'] and
        not ctx.validation['IRA_fixed_Hello_interface_checker_called'])
    captured=[];original_evaluate=ctx.prior['evaluate']
    def capture(*a,**kw):
        r=original_evaluate(*a,**kw);captured.append(r);return r
    ctx.prior['evaluate']=capture
    hello=(m['REPO']/'samples/hello_world.adb').read_bytes()
    shell=b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin\n'
    sources=[('Hello',hello),('same_counts_other_bytes',hello.replace(b'Hello, world!',b'Other, world!')),
        ('C2_N2',shell+b'Silver_IO.Put (""); null; Silver_IO.Put_Line ("xy"); null;\nend Main;\n'),
        ('C70_allocno_pool_bound',shell+b'Silver_IO.Put ("x");\n'*70+b'end Main;\n'),
        ('C10_N10_variable_GGC',shell+b'Silver_IO.Put ("x"); null;\n'*10+b'end Main;\n')]
    preserve=['core_result','selected_native_MEM_counter_lifetime','selected_native_SSA_lifetime_extension',
        'selected_native_shared_query_lifetime','selected_native_shared_bitmap_pool_lifetime',
        'selected_native_finalizer_lifetime','selected_native_GGC_ledger','mem_ssa_attachment',
        'lifetime_attachment','pool_finalizer_attachment','ggc_attachment','selected_positive_GGC_events_upper',
        'selected_active_pages_upper','selected_GGC_event_partition_closed','selected_collector_indexed_storage_capacity_established']
    broad=['whole_literal_pipeline_capacity_established','complete_native_capacity',
        'complete_proof_pipeline_capacity','complete_parent_storage_closed','production_launcher_adopted',
        'production_admission_changed','aggregate_RAM_gate']
    residual=['numeric_cost_arithmetic_closed','excess_pressure_arithmetic_closed','outer_IRA_helper_interfaces_closed',
        'all_LRA_ordinary_helpers_closed','complete_all_ordinary_native_capacity','complete_native_capacity',
        'whole_literal_pipeline_capacity_established','production_admission_changed','aggregate_RAM_gate']
    with tempfile.TemporaryDirectory(prefix='ordinary-ira-attachment-',dir=m['REPO']/'tmp') as tmp:
        path=Path(tmp)/'main.adb'
        for name,raw in sources:
            path.write_bytes(raw)
            r=m['evaluate'](m['PIPELINE']/'selected-route.json',ctx,None if name=='Hello' else path)
            prior=captured[-1];ira=r['selected_native_IRA_ordinary_storage'];cfi=r['selected_native_CFI_CFG_ordinary_lifetime'];a=r['ordinary_attachment']
            c,n=r['source_counts']['output_calls'],r['source_counts']['null_statements'];x=ira['extents']
            check(name+' actual IRA identity complete counts path launch and configuration',
                ira['source']==r['source']==m['identity'](raw) and ira['source_counts']==r['source_counts'] and
                ira['source_path']==r['source_path'] and ira['launch']==r['launch'] and
                ira['actual_shared_inputs']==r['actual_shared_inputs'] and ira['same_source_accepted_owners_verified'])
            check(name+' inherited236 CFI43 IRA26 conjunctive305 guards',
                len(r['conditions'])==305 and len(a['guards'])==69 and a['CFI_local_guards']==43 and a['IRA_local_guards']==26 and
                all(r['conditions'][k]==v for k,v in prior['conditions'].items()) and
                all(r['conditional_conditions'][k]==v for k,v in prior['conditional_conditions'].items()) and
                r['evaluated_predicates_pass'] and r['conditional_arithmetic_pass'] and not r['failed_predicates'] and not r['unresolved_predicates'])
            check(name+' complete existing cold GGC scalar bitmap and collector owners unchanged',all(r[k]==prior[k] for k in preserve))
            check(name+' actual A K B M U P and H source owner transfer',x==dict(A=4*c,K=99+5*c,B=2*n+10,M=7*c+5*n+20,
                U=7*c+5*n+22,P=2*(7*c+5*n+20)+2*n+10,cost_class_insert_attempts_upper=7+5*c) and
                ira['retained_owners']['RTL_shape']==prior['core_result']['RTL_shape'] and
                ira['retained_owners']['shared_bitmap_extents']==prior['selected_native_shared_bitmap_pool_lifetime']['extents'])
            check(name+' variable actual GGC ledger retained instead of fixedHello reconciliation',
                ira['retained_owners']['existing_GGC_positive_events_upper']==prior['selected_positive_GGC_events_upper'] and
                ira['retained_owners']['existing_GGC_owner_rows']==prior['selected_native_GGC_ledger']['owner_rows'] and
                not ira['fixed_Hello_reconciliation_used_as_actual_source_rule'])
            check(name+' original CFI owner branch preserved in combined adapter',
                cfi['source']==r['source'] and cfi['source_counts']==r['source_counts'] and cfi['inherited_guard_count']==178 and
                cfi['retained_owners']['shared_bitmap_and_ET']==prior['selected_native_shared_bitmap_pool_lifetime']['dominance'] and
                cfi['retained_owners']['emission_labels']==prior['selected_native_MEM_counter_lifetime']['emission_counter_endpoints'])
            check(name+' named IRA requests pools and target owners stay disjoint',len(ira['ordinary_requests'])==29 and
                len(ira['ordinary_pools'])==4 and all(ira[k]==0 for k in ('new_GGC_events','new_scalar_registrations',
                'new_array_registrations','shared_bitmap_or_ET_blocks_recharged')) and
                not ira['lifetimes']['target_cost_buffers_recharged'] and ira['lifetimes']['shared_bitmap_allocator_owner_preserved'] and
                all(q['lifetime_block_request_total'] is None for q in ira['ordinary_pools']))
            check(name+' numeric pressure priority outer IRA LRA broad capacities remain open',
                all(ira[k] is False for k in residual) and all(r[k] is False for k in broad) and
                ira['aggregate_ordinary_bytes'] is ira['lifetime_ordinary_request_total'] is None and
                r['complete_imported_allocation_events'] is r['complete_imported_allocation_bytes'] is None and
                not a['numeric_cost_pressure_priority_and_outer_IRA_LRA_capacity_established'])
            if name=='Hello':
                baseline,incoming=r,prior
                frozen=m['read'](m['IRA']/'result.json')
                pure=set(ctx.ira['arithmetic'](1,0))
                check('Hello pure IRA fields equal accepted packet without calling frozen reconciliation',all(ira[k]==frozen[k] for k in pure))
                old=m['read'](HERE/'cfi-stage/result.json')['selected_native_CFI_CFG_ordinary_lifetime']
                check('Hello CFI leaf unchanged except actual worktree source path',
                    {k:v for k,v in cfi.items() if k!='source_path'}=={k:v for k,v in old.items() if k!='source_path'})
            if name=='same_counts_other_bytes':check('same numerical counts keep independent actual source identity',r['source']!=baseline['source'] and
                {k:v for k,v in r['source_counts'].items() if k!='source_sha256'}=={k:v for k,v in baseline['source_counts'].items() if k!='source_sha256'})
            if name=='C70_allocno_pool_bound':check('actual source crosses conservative allocno block upper bound',ira['ordinary_pools'][0]['retained_blocks_upper']==2 and
                ira['ordinary_pools'][0]['live_objects_upper']==280 and ira['ordinary_pools'][0]['exact_stride_bytes'] is None)
            if name=='C10_N10_variable_GGC':check('actual69927 GGC ownership rules out fixed47054 reuse',r['selected_positive_GGC_events_upper']==69927 and
                ira['retained_owners']['existing_GGC_positive_events_upper']==69927)
            variants.append(dict(name=name,source=r['source'],counts=r['source_counts'],extents=x,guards=len(r['conditions']),
                GGC_events=prior['selected_positive_GGC_events_upper'],IRA_allocno_blocks=ira['ordinary_pools'][0]['retained_blocks_upper'],passed=r['evaluated_predicates_pass']))
    ctx.prior['evaluate']=original_evaluate
    # The inherited236 exhaustive loop is retained in cfi-stage. No common
    # prerequisite gathering/projection/CFI guard algorithm changed. Exercise
    # each prerequisite layer and real null state against the new IRA branch.
    original_cfi,original_ira=ctx.cfi['attach'],ctx.ira['arithmetic']
    def forbidden(*a,**kw):raise AssertionError('ordinary evaluation on failed or null prerequisites')
    ctx.cfi['attach']=ctx.ira['arithmetic']=forbidden
    representatives=[next(iter(incoming['conditions'])),
        next(k for k in incoming['conditions'] if k.startswith('native_pool_finalizer_')),
        'native_GGC_LRA_signed_hard_register_frequency']
    for key in representatives:
        changed=copy.deepcopy(incoming);changed['conditions'][key]=changed['conditional_conditions'][key]=False
        r=m['attach'](hello,changed,ctx)
        check('new IRA branch preserves failed prerequisite layer '+key,
            r['failed_predicates']==r['failed_conditional_predicates']==[key] and len(r['unresolved_predicates'])==69 and
            r['selected_native_IRA_ordinary_storage'] is r['selected_native_CFI_CFG_ordinary_lifetime'] is None and
            not r['evaluated_predicates_pass'] and not r['conditional_arithmetic_pass'] and all(r[k]==changed[k] for k in preserve))
    failed219=m['project'](incoming,ctx.prior_context.reference['conditions'].keys())
    first=representatives[0];failed219['conditions'][first]=failed219['conditional_conditions'][first]=False
    failed236=ctx.prior['attach'](hello,failed219,ctx.prior_context)
    r=m['attach'](hello,failed236,ctx)
    check('new IRA branch preserves real17 null GGC and adds69 uncomputed ordinary checks',
        all(r[field][k]==v for field in ('conditions','conditional_conditions') for k,v in failed236[field].items()) and
        len(r['unresolved_predicates'])==86 and r['failed_predicates']==failed236['failed_predicates'] and
        r['selected_native_IRA_ordinary_storage'] is r['selected_native_CFI_CFG_ordinary_lifetime'] is None and
        not r['selected_named_ordinary_capacity_established'] and all(r[k]==failed236[k] for k in preserve))
    for field in ('conditions','conditional_conditions'):
        r=m['attach'](hello,mutate(incoming,[field,'native_GGC_active_page_signed_index'],None),ctx)
        check('new IRA branch skips each separately null inherited map '+field,r['selected_native_IRA_ordinary_storage'] is
            r['selected_native_CFI_CFG_ordinary_lifetime'] is None and not r['conditional_arithmetic_pass'])
    ctx.cfi['attach'],ctx.ira['arithmetic']=original_cfi,original_ira
    bads=[(['core_result','RTL_shape','split_referenced_pseudos_upper'],0,'IRA actual referenced-pseudo'),
        (['selected_native_shared_bitmap_pool_lifetime','extents','U'],0,'pool source theorem'),
        (['selected_native_shared_bitmap_pool_lifetime','extents','P'],0,'pool source theorem'),
        (['actual_shared_inputs','configuration','sha256'],'0'*64,'configuration/System join'),
        (['selected_native_invocation','processes',0,'environment','EXTRA'],'1','selected invocation')]
    for obj,label in [(incoming,'passing'),(failed236,'real false/null')]:
        for path_,value,fragment in bads:
            reject(label+' IRA owner/config mismatch '+'.'.join(map(str,path_)),lambda obj=obj,path_=path_,value=value:
                m['attach'](hello,mutate(obj,path_,value),ctx),fragment)
        reject(label+' equal-count different physical source rejected before arithmetic',lambda obj=obj:m['attach'](sources[1][1],obj,ctx),'actual source identity')
    pure0=original_ira(1,0)
    def patch_pure(leaf):
        ctx.ira['arithmetic']=lambda *a,**kw:copy.deepcopy(leaf)
        try:return m['attach'](hello,incoming,ctx)
        finally:ctx.ira['arithmetic']=original_ira
    for key in pure0['local_representation_checks']:
        r=patch_pure(mutate(pure0,['local_representation_checks',key],False))
        check('new IRA false predicate remains computed '+key,
            r['failed_predicates']==r['failed_conditional_predicates']==['native_ordinary_IRA_'+key] and
            r['selected_native_IRA_ordinary_storage'] is not None and not r['unresolved_predicates'] and
            not r['evaluated_predicates_pass'] and not r['selected_named_ordinary_capacity_established'])
    r=patch_pure(mutate(pure0,['conditional_named_IRA_allocation_capacity'],False))
    check('new IRA false conjunction remains computed',r['failed_predicates']==['native_ordinary_IRA_conditional_capacity'] and
        not r['conditional_arithmetic_pass'] and r['ordinary_attachment']['ordinary_status']=='computed')
    reject('nonboolean IRA predicate rejected',lambda:patch_pure(mutate(pure0,['local_representation_checks','register_extent_signed'],1)),'boolean ordinary IRA')
    for key in residual:
        reject('IRA residual cannot be silently closed '+key,lambda key=key:patch_pure(mutate(pure0,[key],True)),'IRA named storage scope')
    for path_,value,fragment in [(['extents','A'],0,'IRA actual source count'),(['source_input','null_statements'],1,'IRA actual source count'),
        (['new_GGC_events'],1,'not recharged'),(['shared_bitmap_or_ET_blocks_recharged'],1,'not recharged'),
        (['lifetimes','target_cost_buffers_recharged'],True,'not recharged'),(['ordinary_pools',0,'new_GGC_events'],1,'not recharged'),
        (['aggregate_ordinary_bytes'],1,'IRA named storage scope')]:
        reject('IRA returned owner mutation '+'.'.join(map(str,path_)),lambda path_=path_,value=value:patch_pure(mutate(pure0,path_,value)),fragment)
    # Representative CFI local failure proves the added IRA conjunction does
    # not erase prior failure handling; its exhaustive43 cases remain retained.
    cfi0=baseline['selected_native_CFI_CFG_ordinary_lifetime'];key=next(iter(cfi0['local_representation_checks']))
    changed=mutate(cfi0,['local_representation_checks',key],False);ctx.cfi['attach']=lambda *a,**kw:copy.deepcopy(changed)
    try:r=m['attach'](hello,incoming,ctx)
    finally:ctx.cfi['attach']=original_cfi
    check('added IRA conjunction retains prior CFI failure and exact false predicate',
        r['failed_predicates']==['native_ordinary_CFI_CFG_'+key] and not r['selected_named_ordinary_capacity_established'] and
        r['selected_native_IRA_ordinary_storage'] is not None)
    # Accepted pure arithmetic can return multiple false conditions at large
    # counts. Exercise its export without claiming huge-count source admission.
    huge=original_ira(ctx.ira['I64'],ctx.ira['I64']);g=m['ira_guards'](huge,ctx)
    check('all overlarge pure IRA failures remain false without new source-admission claim',
        not all(g.values()) and all(g['native_ordinary_IRA_'+k] is False for k in huge['failed_predicates']))
    result=dict(status='passed',check_count=len(checks),checks=checks,actual_sources=variants,
        affected_scope='Accepted IRA addition, changed source/owner joins, representative prior failure layers and real nullable state; unaffected exhaustiveCFI366 evidence retained without replay',
        reused_CFI_checks=366,reused_CFI_elapsed_seconds=12.968061241990654,
        new_IRA_false_guards=26,representative_inherited_failure_layers=3,real_null_GGC_guards=17,new_successor_contexts=1,
        started_utc=start,completed_utc=datetime.now(timezone.utc).isoformat(),elapsed_seconds=time.perf_counter()-timer,
        platform=platform.platform(),validation=ctx.validation,native_tool_executions=0,
        build_prover_solver_capture_runs=0,predecessor_suites_rerun=False,aggregate_or_corpus_executions=0,
        fixed_Hello_IRA_interface_checker_called=False)
    args.output.write_text(json.dumps(result,indent=2)+'\n')
    baseline['offline_run']=dict(started_utc=start,completed_utc=result['completed_utc'],elapsed_seconds=result['elapsed_seconds'],
        run_kind='Hello retained from same affected IRA checker; prior CFI366 evidence retained separately')
    (HERE/'result.json').write_text(json.dumps(baseline,indent=2)+'\n')
    print(json.dumps({k:result[k] for k in ('status','check_count','new_IRA_false_guards','elapsed_seconds')}))


if __name__=='__main__':main()
