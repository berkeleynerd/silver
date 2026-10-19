#!/usr/bin/env python3
"""New actual-source ordinary attachment checks; no accepted suite replay."""
import argparse
import copy
from datetime import datetime, timezone
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
    check('complete accepted packet and CFI source identities checked',
        ctx.validation['accepted_current_and_historical_records']==18 and
        ctx.cfi_inputs==dict(source_files=33,repository_files=23,source_excerpts=26))
    capture=[];original_evaluate=ctx.prior['evaluate']
    def evaluate(*a,**kw):
        r=original_evaluate(*a,**kw);capture.append(r);return r
    ctx.prior['evaluate']=evaluate
    hello=(m['REPO']/'samples/hello_world.adb').read_bytes()
    shell=b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin\n'
    sources=[('Hello',hello),('same_numerical_counts_other_bytes',hello.replace(b'Hello, world!',b'Other, world!')),
        ('mixed_C2_N2',shell+b'Silver_IO.Put (""); null; Silver_IO.Put_Line ("xy"); null;\nend Main;\n')]
    sources += [('N'+str(n),shell+b'Silver_IO.Put ("");\n'+b'null;\n'*n+b'end Main;\n') for n in (4,5,11,12)]
    preserve=['core_result','selected_native_MEM_counter_lifetime','selected_native_SSA_lifetime_extension',
        'selected_native_shared_query_lifetime','selected_native_shared_bitmap_pool_lifetime',
        'selected_native_finalizer_lifetime','selected_native_GGC_ledger','mem_ssa_attachment',
        'lifetime_attachment','pool_finalizer_attachment','ggc_attachment','selected_positive_GGC_events_upper',
        'selected_active_pages_upper','selected_GGC_event_partition_closed','selected_collector_indexed_storage_capacity_established']
    broad=['whole_literal_pipeline_capacity_established','complete_native_capacity',
        'complete_proof_pipeline_capacity','complete_parent_storage_closed','production_launcher_adopted',
        'production_admission_changed','aggregate_RAM_gate']
    with tempfile.TemporaryDirectory(prefix='ordinary-attachment-',dir=m['REPO']/'tmp') as tmp:
        path=Path(tmp)/'main.adb'
        for name,raw in sources:
            path.write_bytes(raw)
            r=m['evaluate'](m['PIPELINE']/'selected-route.json',ctx,None if name=='Hello' else path)
            prior=capture[-1];leaf=r['selected_native_CFI_CFG_ordinary_lifetime'];a=r['ordinary_attachment']
            c,n=r['source_counts']['output_calls'],r['source_counts']['null_statements']
            check(name+' actual source complete counts path launch configuration',
                leaf['source']==r['source']==m['identity'](raw) and leaf['source_counts']==r['source_counts'] and
                leaf['source_path']==r['source_path'] and leaf['launch']==r['launch'] and
                leaf['actual_shared_inputs']==r['actual_shared_inputs'] and leaf['inherited_guard_count']==178)
            check(name+' inherited236 and new43 conjunctive279 guards',
                len(r['conditions'])==279 and len(a['guards'])==43 and
                all(r['conditions'][k]==v for k,v in prior['conditions'].items()) and
                all(r['conditional_conditions'][k]==v for k,v in prior['conditional_conditions'].items()) and
                r['evaluated_predicates_pass'] and r['conditional_arithmetic_pass'] and
                not r['failed_predicates'] and not r['unresolved_predicates'])
            check(name+' every existing complete owner and GGC collector bound unchanged',all(r[k]==prior[k] for k in preserve))
            check(name+' original178 projection exact and existing ET CFG emission retained once',
                all(r['conditions'][k]==prior['conditions'][k] for k in ctx.keys178) and
                leaf['retained_owners']['shared_bitmap_and_ET']==prior['selected_native_shared_bitmap_pool_lifetime']['dominance'] and
                leaf['retained_owners']['emission_labels']==prior['selected_native_MEM_counter_lifetime']['emission_counter_endpoints'] and
                not leaf['dominance']['ET_pool_backing_recharged'] and
                all(a[k]==leaf[k]==0 for k in ('new_GGC_events','new_scalar_registrations','new_array_registrations','new_shared_bitmap_or_ET_pool_blocks')))
            check(name+' actual C N E B K R0 M Uf transfer',leaf['extents']==dict(B=2*n+10,expansion_block_slots=n+6,T=n+5,
                K0=98+3*c,K=99+5*c,R0=64*c+n+16,M=7*c+5*n+20,Uf=7*c+7*n+46) and
                leaf['jump']['register_array_bytes_upper']==4*(99+5*c) and
                leaf['jump']['signed_usage_magnitude_upper']==64*c+n+17)
            check(name+' named closure separate from broad native pipeline and totals',
                r['selected_named_ordinary_capacity_established'] and all(r[k] is False for k in broad) and
                leaf['aggregate_ordinary_bytes'] is leaf['lifetime_ordinary_request_total'] is None and
                r['complete_imported_allocation_events'] is r['complete_imported_allocation_bytes'] is None and
                not leaf['complete_all_ordinary_helper_lifetimes_closed'])
            if name=='Hello':
                baseline,incoming=r,prior
                frozen=m['read'](m['CFI']/'result.json')
                check('Hello general attachment matches accepted retained leaf apart from path and verification metadata',
                    {k:v for k,v in leaf.items() if k!='source_path'}==
                    {k:v for k,v in frozen.items() if k not in ('source_path','input_verification')})
                check('Hello accepted individual ordinary requests',leaf['CFI']['trace_each_backing_bytes_upper']==2312 and
                    leaf['hashes'][0]['each_backing_bytes_upper']==104 and
                    leaf['expansion']['head_end_backing_bytes_upper']==104 and leaf['jump']['register_array_bytes_upper']==416)
            if name=='same_numerical_counts_other_bytes':
                check('same numerical counts retain independent source identity',r['source']!=baseline['source'] and
                    {k:v for k,v in r['source_counts'].items() if k!='source_sha256'}==
                    {k:v for k,v in baseline['source_counts'].items() if k!='source_sha256'})
            if name in ('N4','N5'):
                check('actual CFG inline heap boundary '+name,
                    leaf['CFG']['traversal_heap_request_bytes_upper']==(0 if n==4 else 344))
            if name in ('N11','N12'):
                check('actual CFI trace growth boundary '+name,
                    leaf['CFI']['trace_capacity_upper']==(16 if n==11 else 24))
            variants.append(dict(name=name,source=r['source'],counts=r['source_counts'],guards=len(r['conditions']),
                trace_capacity=leaf['CFI']['trace_capacity_upper'],CFG_iterator_heap=leaf['CFG']['traversal_heap_request_bytes_upper'],passed=r['evaluated_predicates_pass']))
    ctx.prior['evaluate']=original_evaluate
    original_cfi=ctx.cfi['attach']
    def must_not_run(*a,**kw):raise AssertionError('ordinary API entered on failed or uncomputed inherited prerequisite')
    ctx.cfi['attach']=must_not_run
    first=next(iter(incoming['conditions']))
    for key in incoming['conditions']:
        changed=copy.deepcopy(incoming);changed['conditions'][key]=changed['conditional_conditions'][key]=False
        r=m['attach'](hello,changed,ctx)
        check('inherited false guard retained without ordinary evaluation '+key,
            r['failed_predicates']==r['failed_conditional_predicates']==[key] and
            len(r['unresolved_predicates'])==43 and r['selected_native_CFI_CFG_ordinary_lifetime'] is None and
            not r['evaluated_predicates_pass'] and not r['conditional_arithmetic_pass'] and
            not r['selected_named_ordinary_capacity_established'] and
            all(r[k]==changed[k] for k in preserve) and
            all(v is None for v in r['ordinary_attachment']['guards'].values()))
    # Produce a real accepted236 failed result; original219 false entails all17
    # native guards null. This is not a manufactured all-true callee projection.
    keys219=ctx.prior_context.reference['conditions'].keys()
    failed219=m['project'](incoming,keys219)
    failed219['conditions'][first]=failed219['conditional_conditions'][first]=False
    failed236=ctx.prior['attach'](hello,failed219,ctx.prior_context)
    check('real predecessor failure has17 null GGC predicates and no ledger',
        sum(v is None for v in failed236['conditions'].values())==17 and failed236['selected_native_GGC_ledger'] is None)
    r=m['attach'](hello,failed236,ctx)
    check('all real false and null inherited236 values survive as279 unresolved outcome',
        all(r[field][k]==v for field in ('conditions','conditional_conditions') for k,v in failed236[field].items()) and
        len(r['unresolved_predicates'])==60 and r['selected_native_CFI_CFG_ordinary_lifetime'] is None and
        r['failed_predicates']==failed236['failed_predicates'] and not r['conditional_arithmetic_pass'] and
        all(r[k]==failed236[k] for k in preserve))
    for field in ('conditions','conditional_conditions'):
        changed=copy.deepcopy(incoming);changed[field]['native_GGC_active_page_signed_index']=None
        r=m['attach'](hello,changed,ctx)
        check('each uncomputed inherited map separately shortcircuits '+field,
            r['selected_native_CFI_CFG_ordinary_lifetime'] is None and not r['evaluated_predicates_pass'] and not r['conditional_arithmetic_pass'])
    ctx.cfi['attach']=original_cfi
    # Corruptions are rejected before arithmetic decisions on both passing and
    # genuinely failed/null predecessor records.
    bads=[
        (['source','sha256'],'0'*64,'actual source'),
        (['source_counts','null_statements'],1,'actual source counts'),
        (['core_result','source_path'],incoming['source_path']+'x','exact source path'),
        (['selected_native_invocation','processes',0,'environment','EXTRA'],'1','selected invocation'),
        (['core_result','RTL_shape','CFI_traces_upper'],6,'ordinary accepted RTL shape'),
        (['core_result','RTL_shape','edges_upper'],8,'ordinary accepted RTL shape'),
        (['selected_native_MEM_counter_lifetime','RTL','pre_split_first_unused_pseudo_upper'],100,'ordinary accepted MEM/RTL'),
        (['selected_native_MEM_counter_lifetime','emission_counter_endpoints','CFI_label_counter_at_exit_upper'],6,'ordinary accepted CFI'),
        (['selected_native_shared_bitmap_pool_lifetime','dominance','live_nodes_combined_upper'],21,'pool source theorem'),
        (['core_result','native_initial_CF_CFG_lifetime','ordinary_requests','shared_default_bitmap_headers_upper'],0,'ordinary cold'),
        (['core_result','native_SSA_helper_backing','ranger_per_instance','bitmap_obstack_initial_chunks_upper'],0,'ordinary cold')]
    for obj,label in [(incoming,'passing'),(failed236,'false and null predecessor')]:
        for path_,value,fragment in bads:
            reject(label+' genuine source config or owner mismatch '+'.'.join(map(str,path_)),
                lambda obj=obj,path_=path_,value=value:m['attach'](hello,mutate(obj,path_,value),ctx),fragment)
        reject(label+' different equal-count physical source',lambda obj=obj:m['attach'](sources[1][1],obj,ctx),'actual source identity')
    leaf0=baseline['selected_native_CFI_CFG_ordinary_lifetime']
    def patch(leaf):
        ctx.cfi['attach']=lambda *a,**kw:copy.deepcopy(leaf)
        try:return m['attach'](hello,incoming,ctx)
        finally:ctx.cfi['attach']=original_cfi
    for key in leaf0['local_representation_checks']:
        r=patch(mutate(leaf0,['local_representation_checks',key],False))
        check('new false ordinary predicate remains computed '+key,
            r['failed_predicates']==r['failed_conditional_predicates']==['native_ordinary_CFI_CFG_'+key] and
            r['selected_native_CFI_CFG_ordinary_lifetime'] is not None and not r['unresolved_predicates'] and
            not r['evaluated_predicates_pass'] and not r['selected_named_ordinary_capacity_established'])
    r=patch(mutate(leaf0,['conditional_named_ordinary_container_capacity_established'],False))
    check('new false ordinary capacity conjunction retained',r['failed_predicates']==['native_ordinary_CFI_CFG_conditional_capacity'] and
        not r['conditional_arithmetic_pass'] and r['ordinary_attachment']['ordinary_status']=='computed')
    reject('nonboolean local arithmetic rejected',lambda:patch(mutate(leaf0,['local_representation_checks','jump_register_extent_signed'],1)),'boolean ordinary')
    reject('nonboolean inherited arithmetic rejected',lambda:m['attach'](hello,mutate(incoming,['conditions',first],1),ctx),'boolean or uncomputed')
    for path_,value,fragment in [
        (['source','sha256'],'0'*64,'actual-source CFI'),
        (['retained_owners','initial_CF_CFG_GGC'],0,'exact existing'),
        (['retained_owners','shared_bitmap_and_ET','live_nodes_combined_upper'],0,'exact existing'),
        (['new_GGC_events'],1,'adds zero'),
        (['dominance','ET_pool_backing_recharged'],True,'adds zero'),
        (['aggregate_ordinary_bytes'],1,'scope remains narrow'),
        (['complete_native_capacity'],True,'scope remains narrow')]:
        reject('returned ordinary ownership or scope mismatch '+'.'.join(map(str,path_)),
            lambda path_=path_,value=value:patch(mutate(leaf0,path_,value)),fragment)
    result=dict(status='passed',checks=checks,check_count=len(checks),actual_sources=variants,
        inherited_false_guards=236,inherited_real_null_GGC_guards=17,new_false_guards=43,new_contexts=1,
        started_utc=start,completed_utc=datetime.now(timezone.utc).isoformat(),elapsed_seconds=time.perf_counter()-timer,
        platform=platform.platform(),validation=ctx.validation,native_tool_executions=0,
        build_prover_solver_capture_runs=0,predecessor_suites_rerun=False,aggregate_or_corpus_executions=0)
    args.output.write_text(json.dumps(result,indent=2)+'\n')
    baseline['offline_run']=dict(started_utc=start,completed_utc=result['completed_utc'],elapsed_seconds=result['elapsed_seconds'],
        run_kind='Hello retained from same focused actual-source checker; no duplicate standalone evaluation')
    (HERE/'result.json').write_text(json.dumps(baseline,indent=2)+'\n')
    print(json.dumps({k:result[k] for k in ('status','check_count','inherited_false_guards','new_false_guards','elapsed_seconds')}))


if __name__=='__main__':main()
