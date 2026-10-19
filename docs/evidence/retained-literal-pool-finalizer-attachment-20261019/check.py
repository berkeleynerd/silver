#!/usr/bin/env python3
"""Focused successor attachment checks; no predecessor checker/suite replay."""
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
    start, timer = datetime.now(timezone.utc).isoformat(), time.perf_counter()
    m = runpy.run_path(str(HERE/'compose.py'))
    parser = argparse.ArgumentParser(description=__doc__)
    runpy.run_path(str(m['PIPELINE']/'compose.py'))['arguments'](parser)
    parser.add_argument('--output', type=Path, required=True)
    args = parser.parse_args()
    ctx = m['Context'](args.gcc_root,args.ada_root,args.plugin_include,args.gcc_match)
    checks, variants = [], []
    def check(name, value):
        if not value: raise AssertionError(name)
        checks.append(name)
    def reject(name, fn, fragment):
        try: fn()
        except ValueError as exc: check(name, fragment in str(exc))
        else: raise AssertionError(name+' accepted')
    def mutate(obj, path, value):
        obj = copy.deepcopy(obj); target = obj
        for key in path[:-1]: target = target[key]
        target[path[-1]] = value
        return obj
    check('complete pool and finalizer identities/excerpts checked without fixed checker',
        ctx.validation['pool'] == dict(compiler=38, repository=19) and
        ctx.validation['finalizer'] == dict(compiler=24,repository=8,excerpts=27,
            retained_array_types=15,retained_array_sites=28) and
        not ctx.validation['fixed_finalizer_checker_used_as_general_evaluator'])
    check('corrected int element and unsigned capacity representation bound to actual declaration',
        ctx.point_frequency_representation['element_type'] == 'int' and
        ctx.point_frequency_representation['element_bytes'] == 4 and
        ctx.point_frequency_representation['reserve_and_growth_arithmetic'] == 'unsigned')
    captured = []
    original_evaluate = ctx.prior['evaluate']
    def capture(*a, **kw):
        r = original_evaluate(*a, **kw); captured.append(r); return r
    ctx.prior['evaluate'] = capture
    hello = (m['REPO']/'samples/hello_world.adb').read_bytes()
    shell = b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin\n'
    sources = [('Hello',hello),('same_counts_other_bytes',hello.replace(b'Hello, world!',b'Other, world!')),
        ('mixed_empty_literals_and_nulls',shell+b'Silver_IO.Put (""); null; Silver_IO.Put_Line ("xy"); null;\nend Main;\n'),
        ('program_point_domain_over128',shell+b'Silver_IO.Put ("x");\n'*6+b'end Main;\n')]
    with tempfile.TemporaryDirectory(prefix='pool-finalizer-attachment-',dir=m['REPO']/'tmp') as temp:
        path = Path(temp)/'main.adb'
        for name,raw in sources:
            path.write_bytes(raw)
            r = m['evaluate'](m['PIPELINE']/'selected-route.json',ctx,None if name=='Hello' else path)
            prior = captured[-1]; p = r['selected_native_shared_bitmap_pool_lifetime']
            f = r['selected_native_finalizer_lifetime']; a = r['pool_finalizer_attachment']
            check(name+' both new leaves match actual complete source identity/counts',
                r['source'] == m['identity'](raw) and all(x['source']==r['source'] and
                x['source_counts']==r['source_counts'] for x in (p,f)))
            check(name+' inherited178 and new41 predicates remain conjunctive219',
                len(prior['conditions'])==178 and len(r['conditions'])==219 and
                all(r['conditions'][k]==v for k,v in prior['conditions'].items()) and
                all(r['conditional_conditions'][k]==v for k,v in prior['conditional_conditions'].items()) and
                r['conditions']==r['conditional_conditions'] and r['evaluated_predicates_pass'] and
                r['conditional_arithmetic_pass'] and not r['failed_predicates'] and not r['unresolved_predicates'])
            check(name+' original core MEM SSA query and previous event owners unchanged',
                all(r[k]==prior[k] for k in ('core_result','selected_native_MEM_counter_lifetime',
                    'selected_native_SSA_lifetime_extension','selected_native_shared_query_lifetime',
                    'mem_ssa_attachment','lifetime_attachment')) and
                a['prior_MEM_SSA_and_shared_event_owners']==prior['mem_ssa_attachment']['owners'])
            check(name+' ordinary cold bitmap ET and invariant owners retained once',
                a['existing_ordinary_cold_owners_preserved'] and a['conservative_initial_CFG_SSA_ET_owners_unchanged'] and
                p['retained_bitmap_owner_rows']['no_predecessor_event_owner_recharged'] and
                p['LRA_additional_pools']['invariant_vector_initial_slots_already_owned']==100 and
                p['LRA_additional_pools']['invariant_hash_initial_slots_already_owned']==127 and
                not p['dominance']['initial_CF_SSA_and_RTL_cold_block_owners_recharged'])
            check(name+' ordinary block cache and linked allocator have no invented lifetime counter',
                p['bitmap_allocator']['lifetime_chunk_requests_upper'] is None and
                not p['shared_block_cache']['stored_block_count_field'] and
                all(x['lifetime_block_requests_upper'] is None for x in p['dominance']['ordinary_pools']+
                    [p['LRA_additional_pools']['live_ranges']]) and
                not p['DF_bitmap_families']['generations_coexist'])
            check(name+' scalar39275 capacity58911 and zero-array depth0 theorem joined to actual route',
                f['actual_scalar_and_callback_owners_verified'] and f['actual_source_derived_configured_invocation_verified'] and
                (f['scalar_history_upper'],f['scalar_capacity_upper'],f['scalar_backing_bytes_upper'])==(39275,58911,942584) and
                f['context_depth']==0 and f['depth_backing_bytes']==f['outer_backing_bytes_each']==40 and
                f['outer_vector_lengths']==[1,1] and f['outer_vector_capacities']==[4,4] and
                f['array_registration_history']==f['array_inner_capacity']==f['array_inner_backing_requests']==0 and
                not f['vector_destructor_loop_reachable'] and not f['initialization_and_scalar_owners_recharged'])
            check(name+' pool and finalizer joins add zero events or registrations',
                all(x[k]==0 for x in (p,f,a) for k in ('new_GGC_events','new_scalar_registrations','new_array_registrations')) and
                not a['existing_scalar39275_and_initialization_charged_again'])
            check(name+' accepted current scopes separated from frozen historical flags',
                all(a['accepted_current_scopes'].values()) and a['frozen_leaf_pending_and_incomplete_flags_preserved_as_history'] and
                p['independent_review_status']=='pending' and not p['complete_array_finalizer_lifetime_closed'] and
                f['selected_finalizer_lifetime_source_join_complete'])
            check(name+' page GGC native and full pipeline stay nullfalse',
                p['total_GGC_events'] is f['total_GGC_events'] is f['active_page_bound'] is a['total_GGC_events'] is None and
                r['complete_imported_allocation_events'] is r['complete_imported_allocation_bytes'] is None and
                all(r[k] is False for k in ('whole_literal_pipeline_capacity_established','complete_native_capacity',
                    'complete_proof_pipeline_capacity','complete_parent_storage_closed','production_launcher_adopted',
                    'production_admission_changed','aggregate_RAM_gate')) and not f['complete_collector_capacity'] and
                not f['by_depth_and_save_in_use_page_arrays_closed'] and 'other required' in
                r['open_joins']['native_remaining_lifetime_and_collector'])
            if name=='Hello':
                baseline,incoming = r,prior
                check('Hello pool exactly equals accepted general-callable retained result',p==m['read'](m['POOL']/'result.json'))
                frozen = m['read'](m['FINAL']/'result.json')
                shared = ['context_depth','depth_entries_used_upper','depth_backing_bytes','outer_vector_lengths',
                    'outer_vector_capacities','outer_backing_bytes_each','old_context_bitmap_backups',
                    'scalar_history_upper','scalar_capacity_upper','scalar_backing_bytes_upper',
                    'array_registration_history','array_inner_capacity','array_inner_backing_requests',
                    'vector_destructor_loop_reachable','new_GGC_events','initialization_and_scalar_owners_recharged']
                check('Hello accepted finalizer fields agree without calling fixed checker',all(f[k]==frozen[k] for k in shared))
            else: check(name+' same-count sample identity cannot be reused',r['source']!=baseline['source'])
            if name=='program_point_domain_over128':
                check('actual program-point bitmap crosses sparse element boundary with four-byte int backing',
                    p['extents']['P']==134 and p['bit_domains']['program_point']['live_elements_per_header_upper']==2 and
                    p['program_points']['point_frequency_request_bytes_upper']==8+4*p['program_points']['point_frequency_capacity_upper'])
            variants.append(dict(name=name,source=r['source'],counts=r['source_counts'],guards=len(r['conditions']),
                passed=r['evaluated_predicates_pass'],point_extent=p['extents']['P'],scalar_history=f['scalar_history_upper']))
        descriptor = m['read'](m['PIPELINE']/'selected-route.json')
        descriptor['core_descriptor']=str(m['PIPELINE']/'selected-core-fixture.json');descriptor['host_page_bytes']=8192
        changed_path=Path(temp)/'changed-route.json';changed_path.write_text(json.dumps(descriptor))
        reject('changed descriptor configuration rejected',lambda:m['evaluate'](changed_path,ctx),'fixed path/page class')
    ctx.prior['evaluate']=original_evaluate
    for key in incoming['conditions']:
        changed=copy.deepcopy(incoming);changed['conditions'][key]=changed['conditional_conditions'][key]=False
        r=m['attach'](hello,changed,ctx)
        check('inherited false guard retained '+key,r['failed_predicates']==[key] and
            r['failed_conditional_predicates']==[key] and not r['evaluated_predicates_pass'] and not r['conditional_arithmetic_pass'])
    p0=baseline['selected_native_shared_bitmap_pool_lifetime'];f0=baseline['selected_native_finalizer_lifetime']
    paths=[('pool',['local_representation_checks',k]) for k in p0['local_representation_checks']]
    paths += [('pool',['inherited_owner_guards',k]) for k in p0['inherited_owner_guards']]
    paths += [('pool',['bit_domains',k,'fits']) for k in p0['bit_domains']]
    paths += [('pool',['dominance','ordinary_pools',i,'fits']) for i in range(2)]
    paths += [('pool',['LRA_additional_pools','live_ranges','fits']),
        ('pool',['conditional_selected_shared_bitmap_and_pool_capacity_established'])]
    paths += [('finalizer',['retained_scalar_guards',k]) for k in f0['retained_scalar_guards']]
    paths += [('finalizer',['local_representation_checks',k]) for k in f0['local_representation_checks']]
    paths += [('finalizer',['conditional_selected_finalizer_capacity'])]
    def patch(label,leaf):
        namespace,name=(ctx.pool,'evaluate_source') if label=='pool' else (m['attach'].__globals__,'finalizer_extension')
        original=namespace[name];namespace[name]=lambda *a,**kw:copy.deepcopy(leaf)
        try:return m['attach'](hello,incoming,ctx)
        finally:namespace[name]=original
    for label,path in paths:
        r=patch(label,mutate(p0 if label=='pool' else f0,path,False))
        check('new false raw guard retained '+label+'.'+'.'.join(map(str,path)),
            len(r['failed_predicates'])==1 and r['failed_predicates']==r['failed_conditional_predicates'] and
            r['failed_predicates'][0] in r['pool_finalizer_attachment']['guards'] and not r['evaluated_predicates_pass'] and
            not r['conditional_arithmetic_pass'])
    reject('nonboolean new raw arithmetic rejected',
        lambda:patch('finalizer',mutate(f0,['local_representation_checks','depth_individual_request_span'],1)),
        'boolean pool/finalizer arithmetic')
    for path,value,fragment in [
        (['source','sha256'],'0'*64,'actual source'),
        (['source_counts','maximum_literal_length'],0,'actual source'),
        (['core_result','source','sha256'],'0'*64,'actual source'),
        (['selected_native_MEM_counter_lifetime','source_counts','decoded_literal_bytes'],0,'actual source'),
        (['selected_native_shared_query_lifetime','counter_endpoints','next_DECL_UID_upper'],0,'declaration UID owner'),
        (['selected_native_shared_query_lifetime','scalar_finalizers','allocated_slots_upper'],0,'scalar39275'),
        (['core_result','native_initial_SSA_lifetime','ordinary_requests','shared_default_bitmap_headers_upper'],0,'ordinary cold'),
        (['core_result','native_SSA_helper_backing','ranger_per_instance','bitmap_obstack_initial_chunks_upper'],0,'ordinary cold'),
        (['core_result','native_initial_SSA_lifetime','ordinary_requests','ET_node_pool_blocks_upper'],0,'ordinary cold'),
        (['core_result','native_initial_SSA_lifetime','ordinary_requests','ET_occurrence_pool_blocks_upper'],0,'ordinary cold'),
        (['core_result','native_initial_CF_CFG_lifetime','ordinary_requests'],{},'ordinary cold'),
        (['selected_native_invocation','processes',0,'argv'],incoming['selected_native_invocation']['processes'][0]['argv']+['-fplugin=other.so'],'source-derived selected invocation'),
        (['selected_native_invocation','processes',0,'environment','OTHER_PLUGIN'],'yes','source-derived selected invocation'),
        (['core_result','native_collector_callbacks','finalizer_additional_ordinary_allocation_requests'],1,'callback zero-allocation')]:
        reject('reject changed input '+'.'.join(map(str,path)),
            lambda path=path,value=value:m['attach'](hello,mutate(incoming,path,value),ctx),fragment)
    for label,leaf in [('pool',p0),('finalizer',f0)]:
        for path,value in [(['source','sha256'],'0'*64),(['source_counts','maximum_literal_length'],0)]:
            reject('reject changed leaf identity/counts '+label+'.'+'.'.join(path),
                lambda label=label,leaf=leaf,path=path,value=value:patch(label,mutate(leaf,path,value)),
                'attached complete actual source')
    for label,path,value,fragment in [
        ('pool',['new_GGC_events'],1,'zero pool/finalizer'),
        ('finalizer',['new_scalar_registrations'],1,'zero pool/finalizer'),
        ('pool',['LRA_additional_pools','invariant_vector_initial_slots_already_owned'],0,'ordinary cold'),
        ('pool',['dominance','initial_CF_SSA_and_RTL_cold_block_owners_recharged'],True,'ordinary cold'),
        ('pool',['DF_bitmap_families','generations_coexist'],True,'ordinary cold'),
        ('pool',['bitmap_allocator','lifetime_chunk_requests_upper'],1,'invent lifetime'),
        ('finalizer',['initialization_and_scalar_owners_recharged'],True,'existing scalar'),
        ('finalizer',['array_registration_history'],1,'zero-array'),
        ('finalizer',['context_depth'],1,'depth0'),
        ('finalizer',['active_page_bound'],10,'scope remains open')]:
        reject('reject owner/theorem/scope change '+label+'.'+'.'.join(path),
            lambda label=label,path=path,value=value:patch(label,mutate(p0 if label=='pool' else f0,path,value)),fragment)
    pins=m['read'](HERE/'inputs.json');pins['files'][0]['sha256']='0'*64
    pin_api=runpy.run_path(str(m['E']/'retained-literal-lifetime-attachment-20261019/compose.py'))
    reject('changed accepted source record rejected without new Context',lambda:pin_api['check_pins'](pins),'changed attachment input')
    reject('equal counts cannot substitute another source identity',
        lambda:m['attach'](hello.replace(b'Hello, world!',b'Other, world!'),incoming,ctx),'actual source')
    arithmetic=[];core_ctx=ctx.route_context.core_context;core_api=ctx.route_context.core
    point_good=((2**31-1)//2-50)//14
    count_cases=[(1,0),(6,0),(204,0),(205,0),(1,165),(1,166),(1,250),(1,251),
        (point_good,0),(point_good+1,0),(2**31,0),(1,2**32)]
    for c,n in count_cases:
        p=ctx.pool['endpoints'](c,n,5872+5*c+n,ctx.pool_context)
        p['inherited_owner_guards']=dict(
            mem=ctx.prior_context.mem['endpoints'](c,n,ctx.prior_context.mem_context)['conditional_selected_chronology_and_pool_capacity_established'],
            initial_SSA=core_api['native_initial_ssa_lifetime'](c,n,core_ctx)['conditional_initial_SSA_lifetime_closed'],
            initial_CFG=core_api['native_initial_cf_cfg_lifetime'](c,n,core_ctx)['conditional_initial_CF_CFG_lifetime_closed'],
            SSA_helpers=core_api['native_ssa_helper_backing'](c,n,core_ctx)['conditional_SSA_helper_backing_closed'])
        p['conditional_selected_shared_bitmap_and_pool_capacity_established'] &= all(p['inherited_owner_guards'].values())
        guards=m['arithmetic_guards'](p,f0)
        check('new count-only guard conjunction '+str((c,n)),len(guards)==41 and all(guards.values())==(c<1000000 and n<1000000))
        arithmetic.append(dict(C=c,N=n,passed=all(guards.values()),failed=[k for k,v in guards.items() if not v],
            LRA_live_pool_blocks=p['LRA_additional_pools']['live_ranges']['retained_blocks_upper'],
            ET_blocks=[x['retained_blocks_upper'] for x in p['dominance']['ordinary_pools']]))
    check('new live-range and ET retained-block boundaries represented',
        [arithmetic[i]['LRA_live_pool_blocks'] for i in (2,3)]==[1,2] and
        [arithmetic[i]['ET_blocks'][1] for i in (4,5)]==[1,2] and
        [arithmetic[i]['ET_blocks'][0] for i in (6,7)]==[1,2])
    check('point-frequency 31-bit boundary retains failing predicate independently of other failures',
        'native_pool_finalizer_pool_point_frequency_capacity_31_bits' not in arithmetic[8]['failed'] and
        'native_pool_finalizer_pool_point_frequency_capacity_31_bits' in arithmetic[9]['failed'])
    completed=datetime.now(timezone.utc).isoformat()
    baseline['offline_run']=dict(started_utc=start,completed_utc=completed,
        scope='Hello generated once in new focused pool/finalizer attachment run; no native execution')
    (HERE/'result.json').write_text(json.dumps(baseline,indent=2)+'\n')
    result=dict(started_utc=start,completed_utc=completed,elapsed_seconds=time.perf_counter()-timer,
        passed=True,checks=len(checks),check_names=checks,actual_source_variants=variants,
        count_only_arithmetic_cases=arithmetic,inherited_guard_count=178,new_guard_count=41,total_guards=219,
        new_contexts=1,validation=ctx.validation,selected_model='GPT-6.1 Sol',selected_effort='Extra High',
        runtime_confirmed_model_effort=None,token_cost_measurements=None,
        host=platform.system()+' '+platform.release()+' '+platform.machine(),
        native_tool_executions=0,build_prover_solver_capture_runs=0,predecessor_suites_rerun=False,
        large_corpus_rerun=False,array_census_regenerated=False,runtime_census_reinventoried=False,
        implementation_inputs={name:m['identity']((HERE/name).read_bytes()) for name in ('compose.py','check.py','inputs.json')},
        reused_evidence='Accepted MEM/SSA269 and predecessors; pool52/21 count cases/11 bitmap boundaries/18 pool boundaries; finalizer67 and retained15-type28-site projection; exact A/B/C source review. None replayed.',
        validation_scope='New actual-source, source-derived configuration, owner, representation and failure joins; finite arithmetic corroboration. Accepted handwritten arguments supply lifetime reachability.')
    args.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:result[k] for k in ('passed','checks','total_guards','elapsed_seconds')}))


if __name__=='__main__':main()
