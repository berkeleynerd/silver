#!/usr/bin/env python3
"""Affected IRA numeric adapter checks; predecessor evidence is reused."""
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
    args=parser.parse_args();ctx=m['Context'](args.gcc_root,args.ada_root,args.plugin_include,args.gcc_match)
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
    preserve=['core_result','selected_native_invocation','selected_native_MEM_counter_lifetime',
        'selected_native_SSA_lifetime_extension','selected_native_shared_query_lifetime',
        'selected_native_shared_bitmap_pool_lifetime','selected_native_finalizer_lifetime',
        'selected_native_GGC_ledger','selected_positive_GGC_events_upper','selected_active_pages_upper',
        'selected_GGC_event_partition_closed','selected_collector_indexed_storage_capacity_established',
        'lifetime_attachment','mem_ssa_attachment','pool_finalizer_attachment','ggc_attachment',
        m['CFI_FIELD'],m['IRA_FIELD'],'ordinary_attachment','selected_named_ordinary_capacity_established']
    broad=['whole_literal_pipeline_capacity_established','complete_native_capacity','complete_proof_pipeline_capacity',
        'complete_parent_storage_closed','production_launcher_adopted','production_admission_changed','aggregate_RAM_gate']
    residual=['outer_IRA_helper_capacity_closed','remaining_LRA_arithmetic_closed','all_ordinary_native_capacity',
        'complete_native_capacity','whole_literal_pipeline_capacity_established','production_admission_changed','aggregate_RAM_gate']
    check('complete accepted packets and39 actual LF coordinate operative checks',ctx.validation['accepted_current_and_historical_records']==24 and
        ctx.validation['numeric']==dict(GCC_files=29,repository_files=18,LF_coordinate_and_operative_excerpt_checks=39) and
        not ctx.validation['numeric_fixed_Hello_reconciliation_called'])
    captured=[];original_prior=ctx.prior['evaluate']
    def capture(*a,**kw):
        r=original_prior(*a,**kw);captured.append(r);return r
    ctx.prior['evaluate']=capture
    raw=(m['REPO']/'samples/hello_world.adb').read_bytes()
    shell=b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin\n'
    sources=[('Hello',raw),('same_counts_other_bytes',raw.replace(b'Hello, world!',b'Other, world!')),
        ('C2_N2',shell+b'Silver_IO.Put (""); null; Silver_IO.Put_Line ("xy"); null;\nend Main;\n'),
        ('C10_N10',shell+b'Silver_IO.Put ("x"); null;\n'*10+b'end Main;\n')]
    with tempfile.TemporaryDirectory(prefix='IRA-numeric-attachment-',dir=m['REPO']/'tmp') as tmp:
        source_path=Path(tmp)/'main.adb'
        for name,source in sources:
            source_path.write_bytes(source)
            r=m['evaluate'](m['PIPELINE']/'selected-route.json',ctx,None if name=='Hello' else source_path)
            prior=captured[-1];leaf=r['selected_native_IRA_numeric_arithmetic'];ar=leaf['arithmetic'];a=r['IRA_numeric_attachment']
            check(name+' actual complete source path launch config and335 guards',len(r['conditions'])==335 and len(a['guards'])==30 and
                leaf['source']==r['source'] and leaf['source_counts']==r['source_counts'] and leaf['source_path']==r['source_path'] and
                leaf['launch']==r['launch'] and leaf['actual_shared_inputs']==r['actual_shared_inputs'] and
                leaf['complete_path_bound']==r['complete_path_bound'] and r['evaluated_predicates_pass'] and r['conditional_arithmetic_pass'])
            check(name+' exact independent inherited305 maps and20 owner fields preserved',
                all(r[f][k] is v for f in ('conditions','conditional_conditions') for k,v in prior[f].items()) and
                all(r[k]==prior[k] for k in preserve))
            c,n=r['source_counts']['output_calls'],r['source_counts']['null_statements'];x=dict(A=4*c,K=99+5*c,B=2*n+10,M=7*c+5*n+20,P=14*c+12*n+50)
            check(name+' actual A K B M P and signed64 client transfer',ar['extents']==x and
                ar['aggregate']['signed64_sum_absolute_upper']==524280000*c and ar['aggregate']['cost_terms_upper']==4*c)
            check(name+' actual GGC owner retained without fixed47054 rule',leaf['retained_owners']['actual_GGC_owners']==prior['selected_native_GGC_ledger'] and
                leaf['retained_owners']['actual_GGC_events_upper']==prior['selected_positive_GGC_events_upper'])
            check(name+' separate IRA1000 and LRA10000 fields retained',ar['constants']['IRA_frequency_upper']==1000 and
                ar['constants']['LRA_frequency_unit_separate']==10000 and ar['separate_LRA_signed_usage_guard'] is r['conditions'][m['LRA_GUARD']] and
                leaf['retained_owners']['separate_LRA10000_guard'] is prior['conditions'][m['LRA_GUARD']])
            check(name+' zero GGC finalizer bitmap ET recharge and broad scope',all(ar[k]==0 for k in
                ('new_GGC_events','new_scalar_registrations','new_array_registrations','new_shared_bitmap_or_ET_blocks')) and
                all(ar[k] is False for k in residual) and all(r[k] is False for k in broad) and
                r['complete_imported_allocation_events'] is r['complete_imported_allocation_bytes'] is None)
            check(name+' earlier numeric-open flags remain frozen component history',
                r[m['IRA_FIELD']]['numeric_cost_arithmetic_closed'] is r[m['IRA_FIELD']]['excess_pressure_arithmetic_closed'] is False and
                r['ordinary_attachment']['numeric_cost_pressure_priority_and_outer_IRA_LRA_capacity_established'] is False and
                r['selected_named_IRA_numeric_arithmetic_established'] and a['earlier_numeric_open_flags_are_component_history'])
            if name=='Hello':
                baseline,incoming=r,prior
                pure=ctx.numeric['arithmetic'](1,0)
                check('Hello numeric pure fields exactly match accepted result',ar==pure and all(ar[k]==ctx.numeric_reference[k] for k in pure))
            if name=='same_counts_other_bytes':check('same numerical counts retain different physical identity',r['source']!=baseline['source'] and
                {k:v for k,v in r['source_counts'].items() if k!='source_sha256'}=={k:v for k,v in baseline['source_counts'].items() if k!='source_sha256'})
            if name=='C10_N10':check('nonHello69927 GGC events retained',r['selected_positive_GGC_events_upper']==69927)
            variants.append(dict(name=name,source=r['source'],counts=r['source_counts'],extents=ar['extents'],
                guards=len(r['conditions']),GGC_events=r['selected_positive_GGC_events_upper'],passed=r['evaluated_predicates_pass']))
    ctx.prior['evaluate']=original_prior
    # New arithmetic must never run for any failed/null305 layer. Retain all
    # actual values; the exhaustive236/CFI43/IRA26 loops are accepted evidence.
    original_numeric=ctx.numeric['arithmetic']
    def forbidden(*a,**kw):raise AssertionError('numeric evaluation entered on false/null prerequisites')
    ctx.numeric['arithmetic']=forbidden
    key=next(k for k in incoming['conditions'] if k.startswith('native_ordinary_CFI_CFG_'))
    ira_key=next(k for k in incoming['conditions'] if k.startswith('native_ordinary_IRA_'))
    for field in ('conditions','conditional_conditions'):
        for prior_key in (key,ira_key):
            for value in (False,None):
                changed=mutate(incoming,[field,prior_key],value);r=m['attach'](raw,changed,ctx)
                check(field+' prior ordinary '+prior_key+'='+str(value)+' skips numeric unchanged',
                    r['selected_native_IRA_numeric_arithmetic'] is None and not r['conditional_arithmetic_pass'] and
                    all(r[f][k] is v for f in ('conditions','conditional_conditions') for k,v in changed[f].items()) and
                    all(v is None for v in r['IRA_numeric_attachment']['guards'].values()) and all(r[k]==changed[k] for k in preserve))
    # Produce real accepted failed236/305 states rather than fabricating true
    # prerequisites to reach a wrapper that requires them.
    ggc_ctx=ctx.prior_context.prior_context;ggc_api=ctx.prior_context.prior
    keys219=ggc_ctx.reference['conditions'].keys()
    first=next(iter(incoming['conditions']));pool_key=next(k for k in incoming['conditions'] if k.startswith('native_pool_finalizer_'))
    for prior_key in (first,pool_key):
        old=ctx.prior['project'](incoming,keys219);old['conditions'][prior_key]=old['conditional_conditions'][prior_key]=False
        failed236=ggc_api['attach'](raw,old,ggc_ctx)
        failed305=ctx.prior['attach'](raw,failed236,ctx.prior_context)
        r=m['attach'](raw,failed305,ctx)
        check('real failed219 layer retains17 GGC69 ordinary30 numeric nulls '+prior_key,
            len(r['unresolved_predicates'])==116 and r['failed_predicates']==[prior_key] and
            all(r[f][k] is v for f in ('conditions','conditional_conditions') for k,v in failed305[f].items()) and
            all(r[k]==failed305[k] for k in preserve) and r['selected_native_IRA_numeric_arithmetic'] is None)
        real_failed=failed305
    for prior_key in ('native_GGC_active_page_signed_index',m['LRA_GUARD']):
        if prior_key not in incoming['conditions']:prior_key='native_GGC_active_page_signed_index'
        changed=copy.deepcopy(incoming);changed['conditions'][prior_key]=changed['conditional_conditions'][prior_key]=False
        changed=ctx.prior['attach'](raw,ctx.prior['project'](changed,ctx.prior_context.reference['conditions'].keys()),ctx.prior_context)
        r=m['attach'](raw,changed,ctx)
        check('distinct native prerequisite '+prior_key+' cannot be replaced by numeric theorem',
            r['selected_native_IRA_numeric_arithmetic'] is None and r['conditions'][prior_key] is False and
            len(r['unresolved_predicates'])==99 and not r['selected_named_IRA_numeric_arithmetic_established'])
    for path in [('evaluated_predicates_pass',),('conditional_arithmetic_pass',),('selected_named_ordinary_capacity_established',),
        ('ordinary_attachment','selected_named_ordinary_capacity_established'),('core_result','conditional_arithmetic_pass')]:
        r=m['attach'](raw,mutate(incoming,path,False),ctx)
        check('false summary skips numeric '+'.'.join(path),r['selected_native_IRA_numeric_arithmetic'] is None and not r['evaluated_predicates_pass'])
    ctx.numeric['arithmetic']=original_numeric
    mismatches=[(['core_result','RTL_shape','split_referenced_pseudos_upper'],0,'IRA actual referenced-pseudo'),
        (['selected_native_shared_bitmap_pool_lifetime','extents','P'],0,'pool source theorem'),
        (['actual_shared_inputs','configuration','sha256'],'0'*64,'configuration/System join'),
        (['selected_native_invocation','processes',0,'environment','EXTRA'],'1','selected invocation'),
        (['ordinary_attachment','new_GGC_events'],1,'ordinary attachment owner metadata')]
    for obj,label in [(incoming,'passing'),(real_failed,'real false/null')]:
        for path,value,fragment in mismatches:
            reject(label+' source configuration owner mismatch '+'.'.join(map(str,path)),
                lambda obj=obj,path=path,value=value:m['attach'](raw,mutate(obj,path,value),ctx),fragment)
        reject(label+' equal-count wrong physical source rejected',lambda obj=obj:m['attach'](sources[1][1],obj,ctx),'actual source identity')
    failed_local=mutate(incoming,['conditions',ira_key],False)
    for obj,label in [(incoming,'passing'),(failed_local,'false ordinary arithmetic')]:
        for path,value in [([m['IRA_FIELD'],'ordinary_requests',0,'each_request_bytes_upper'],0),
            ([m['IRA_FIELD'],'launch','native_options'],[]),([m['CFI_FIELD'],'retained_owners','initial_CF_CFG_GGC'],0),
            ([m['IRA_FIELD'],'retained_owners','existing_GGC_positive_events_upper'],1),
            ([m['IRA_FIELD'],'extents','A'],0),([m['IRA_FIELD'],'numeric_cost_arithmetic_closed'],True)]:
            reject(label+' complete prior owner mismatch '+'.'.join(map(str,path)),
                lambda obj=obj,path=path,value=value:m['attach'](raw,mutate(obj,path,value),ctx),'complete actual ordinary')
    pure=original_numeric(1,0)
    def patch_numeric(value):
        ctx.numeric['arithmetic']=lambda *a,**kw:copy.deepcopy(value)
        try:return m['attach'](raw,incoming,ctx)
        finally:ctx.numeric['arithmetic']=original_numeric
    for field,prefix in [('local_numeric_checks','native_IRA_numeric_'),('inherited_representation_checks','native_IRA_numeric_inherited_')]:
        for prior_key in pure[field]:
            r=patch_numeric(mutate(pure,[field,prior_key],False))
            check('false numeric check stays computed '+prior_key,r['failed_predicates']==r['failed_conditional_predicates']==[prefix+prior_key] and
                r['selected_native_IRA_numeric_arithmetic'] is not None and not r['unresolved_predicates'] and
                not r['selected_named_IRA_numeric_arithmetic_established'] and all(r[k]==incoming[k] for k in preserve))
    r=patch_numeric(mutate(pure,['conditional_selected_IRA_numeric_arithmetic'],False))
    check('false new numeric conjunction remains computed',r['failed_predicates']==['native_IRA_numeric_conditional_capacity'] and
        r['IRA_numeric_attachment']['status']=='computed' and not r['conditional_arithmetic_pass'])
    reject('nonboolean numeric local check rejected',lambda:patch_numeric(mutate(pure,['local_numeric_checks','per_allocno_reference_count_signed'],1)),'boolean IRA numeric')
    reject('nonboolean numeric inherited check rejected',lambda:patch_numeric(mutate(pure,['inherited_representation_checks','allocno_ID_count_signed'],1)),'boolean IRA numeric')
    for path,value,fragment in [(['source_counts','null_statements'],1,'complete count and extent'),(['extents','A'],0,'complete count and extent'),
        (['separate_LRA_signed_usage_guard'],False,'LRA10000'),(['previous_storage_owners_modified'],True,'recharge')]+[
        ([k],1,'recharge') for k in ('new_GGC_events','new_scalar_registrations','new_array_registrations','new_shared_bitmap_or_ET_blocks')]+[
        ([k],True,'scope remains named') for k in residual]:
        reject('numeric returned owner scope mutation '+'.'.join(path),lambda path=path,value=value:patch_numeric(mutate(pure,path,value)),fragment)
    # Pure arithmetic boundary export only; these huge counts do not establish
    # physical source admission or passing inherited305 guards.
    boundary_cases=[]
    for name,c,n,key_ in [('aggregate_last',ctx.numeric['I64']//524280000,0,'aggregate_cost_sums_signed64'),
        ('aggregate_first',ctx.numeric['I64']//524280000+1,0,'aggregate_cost_sums_signed64'),
        ('point_last',1,(ctx.numeric['I32']-65)//12,'point_endpoint_successor_signed'),
        ('point_first',1,(ctx.numeric['I32']-65)//12+1,'point_endpoint_successor_signed'),
        ('ID_last',ctx.numeric['I32']//4,0,'allocno_ID_count_signed'),
        ('ID_first',ctx.numeric['I32']//4+1,0,'allocno_ID_count_signed')]:
        ar=original_numeric(c,n);guard=ar['local_numeric_checks'].get(key_,ar['inherited_representation_checks'].get(key_))
        check('pure boundary exact guard exported '+name,guard is name.endswith('last') and
            m['numeric_guards'](ar,ctx)[('native_IRA_numeric_' if key_ in ar['local_numeric_checks'] else 'native_IRA_numeric_inherited_')+key_] is guard)
        boundary_cases.append(dict(name=name,C=c,N=n,guard=key_,value=guard,failed_predicates=ar['failed_predicates']))
    ar=original_numeric(ctx.numeric['I32']//10000+1,0)
    check('IRA conjunction can pass while separate LRA10000 guard fails',ar['conditional_selected_IRA_numeric_arithmetic'] is True and ar['separate_LRA_signed_usage_guard'] is False)
    # Audit copies and the successor result must not mutate the prior owners.
    duplicate=m['attach'](raw,incoming,ctx);duplicate['selected_native_IRA_numeric_arithmetic']['retained_owners']['ordinary_IRA']['extents']['A']=0
    check('new retained owner audit copies do not alias prior owners',incoming[m['IRA_FIELD']]['extents']['A']==4 and duplicate[m['IRA_FIELD']]['extents']['A']==4)
    result=dict(status='passed',check_count=len(checks),checks=checks,actual_sources=variants,pure_boundary_cases=boundary_cases,
        affected_scope='New numeric attachment, complete prior owner validation and representative false/null layers only; unaffected305 and accepted numeric111 evidence reused.',
        new_successor_contexts=1,new_numeric_false_checks=30,real_failed_unresolved_predicates=116,
        started_utc=start,completed_utc=datetime.now(timezone.utc).isoformat(),elapsed_seconds=time.perf_counter()-timer,
        platform=platform.platform(),validation=ctx.validation,native_tool_executions=0,build_prover_solver_capture_runs=0,
        predecessor_suites_rerun=False,aggregate_or_corpus_executions=0,fixed_Hello_reconciliation_called=False)
    args.output.write_text(json.dumps(result,indent=2)+'\n')
    baseline['offline_run']=dict(started_utc=start,completed_utc=result['completed_utc'],elapsed_seconds=result['elapsed_seconds'],
        run_kind='Hello retained from same affected numeric checker; accepted predecessor suites not replayed')
    (HERE/'result.json').write_text(json.dumps(baseline,indent=2)+'\n')
    print(json.dumps({k:result[k] for k in ('status','check_count','elapsed_seconds')}))


if __name__=='__main__':main()
