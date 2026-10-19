#!/usr/bin/env python3
"""Affected lifetime attachment checks; one new Context, no predecessor suites."""
import argparse
import copy
from datetime import datetime,timezone
import json
from pathlib import Path
import runpy
import tempfile
import time

HERE=Path(__file__).resolve().parent


def main():
    start=datetime.now(timezone.utc).isoformat();timer=time.perf_counter()
    m=runpy.run_path(str(HERE/'compose.py'))
    parser=argparse.ArgumentParser(description=__doc__)
    runpy.run_path(str(m['PIPELINE']/'compose.py'))['arguments'](parser)
    parser.add_argument('--output',type=Path,required=True);args=parser.parse_args()
    ctx=m['Context'](args.gcc_root,args.ada_root,args.plugin_include,args.gcc_match)
    rows=[];variants=[]
    def check(name,value):
        if not value:raise AssertionError(name)
        rows.append(name)
    def reject(name,fn,fragment):
        try:fn()
        except ValueError as exc:check(name,fragment in str(exc))
        else:raise AssertionError(name+' accepted')
    audit=m['read'](HERE/'inputs.json')['historical_audit_documents'][0]
    view=m['RepositoryAuditView'](audit)
    extension=m['audit_extension'](view)
    check('historical prose adapter preserves current consumed argument',
        extension['argument_before_attachment_section_unchanged'] and
        extension['selected_source_configuration_frontend_location_argument_unchanged'])
    for key,value in [('path','docs/evidence/other.py'),('revision','0'*40),('sha256','0'*64),('bytes',0)]:
        changed=copy.deepcopy(audit);changed[key]=value
        reject('historical prose adapter rejects changed '+key,lambda:m['RepositoryAuditView'](changed),
               'only exact accepted historical')
    for path in ('docs/evidence/retained-literal-pipeline-20261018/selected-route.py',
                 'docs/research/retained-literal-type-alias-controls.md','samples/hello_world.adb'):
        check('historical prose adapter preserves actual path '+path,view/path==m['REPO']/path)
    captured=[];real_evaluate=ctx.selected['evaluate']
    def capture(*a,**kw):
        r=real_evaluate(*a,**kw);captured.append(r);return r
    ctx.selected['evaluate']=capture
    hello=(m['REPO']/'samples/hello_world.adb').read_bytes()
    shell=b'with Silver_IO; procedure Main is pragma SPARK_Mode (On); begin\n'
    sources=[('Hello',hello),('same_counts_other_bytes',hello.replace(b'Hello, world!',b'Other, world!')),
        ('both_callees_empty_literal_nulls',shell+b'Silver_IO.Put (""); null; Silver_IO.Put_Line ("xy"); null;\nend Main;\n')]
    with tempfile.TemporaryDirectory(prefix='lifetime-attachment-',dir=m['REPO']/'tmp') as temp:
        path=Path(temp)/'main.adb'
        for name,raw in sources:
            path.write_bytes(raw)
            r=m['evaluate'](m['PIPELINE']/'selected-route.json',ctx,None if name=='Hello' else path)
            selected=captured[-1];a=r['lifetime_attachment'];c=r['source_counts']['output_calls']
            check(name+' source/count binding in every new leaf',r['source']==m['identity'](raw) and
                all(r[k]['source']==r['source'] and r[k]['source_counts']==r['source_counts'] for k in
                    ('selected_native_RTL_cache_lifetime','selected_native_completed_alias_graph','selected_native_shared_query_lifetime')))
            check(name+' inherited69 guards unchanged and all conjunctive',len(selected['conditions'])==69 and
                all(r['conditions'][k]==v for k,v in selected['conditions'].items()) and
                r['conditions']==r['conditional_conditions'] and r['evaluated_predicates_pass'] and
                r['conditional_arithmetic_pass'] and not r['failed_predicates'] and not r['unresolved_predicates'])
            check(name+' original corrected named inputs joined',a['original_corrected_named_RTL_graph_inputs_joined'] and
                r['selected_native_shared_query_lifetime']['same_source_corrected_incoming_history_verified'])
            check(name+' same1589 logical-line ordinary lifetime and unchanged preallocation',
                a['ordinary_maps']['permanent_source_entries_upper']==1589 and a['ordinary_maps']['logical_lines_upper']==2**24
                and a['ordinary_maps']['existing_line_guards']==selected['ordinary_map_later_shared_join']['existing_logical_line_guards']
                and a['ordinary_maps']['source_lifetime_closed'] and a['ordinary_maps']['bound_applies']
                and a['ordinary_maps']['later_GGC_events_upper']==0
                and r['selected_native_ordinary_map_preallocation']==selected['selected_native_ordinary_map_preallocation'])
            check(name+' disjoint maps3 RTL4C graph14 query0 once',a['event_owners']==dict(
                ordinary_maps=3,RTL_caches=4*c,completed_alias_graph=14,shared_query=0) and
                r['selected_native_shared_query_lifetime']['graph14_events_added_again']==0 and
                r['selected_native_shared_query_lifetime']['RTL4C_events_added_again']==0 and
                r['core_result']['native_original_shared_storage']['partial_ledger']==selected['core_result']['native_original_shared_storage']['partial_ledger'])
            check(name+' historical projections and pending flags preserved',
                r['selected_native_later_shared_demands']==selected['selected_native_later_shared_demands'] and
                r['selected_native_shared_query_lifetime']['independent_review_status']=='pending' and
                not r['selected_native_completed_alias_graph']['complete_scalar_finalizer_lifetime_closed'] and
                all(a['accepted_current_scopes'].values()) and not a['diagnostic_named_only_projection_used_as_guard'])
            check(name+' native proof parent collector and total remain incomplete',
                r['complete_imported_allocation_events'] is None and r['complete_imported_allocation_bytes'] is None and
                a['total_GGC_events'] is None and all(r[k] is False for k in ('whole_literal_pipeline_capacity_established',
                    'complete_native_capacity','complete_proof_pipeline_capacity','complete_parent_storage_closed',
                    'production_launcher_adopted','production_admission_changed','aggregate_RAM_gate')) and
                r['selected_native_shared_query_lifetime']['complete_collector_lifetime_closed'] is False and
                r['selected_native_shared_query_lifetime']['complete_global_counter_lifetime_closed'] is False and
                'mem_attrs' in r['open_joins']['native_remaining_lifetime_and_collector'])
            if name=='Hello':
                baseline=r;incoming=selected
                check('Hello exact accepted RTL graph and query outputs',all(r[key]==m['read'](m['E']/m['PACKETS'][name]/'result.json')
                    for name,key in [('rtl','selected_native_RTL_cache_lifetime'),('graph','selected_native_completed_alias_graph'),
                                     ('query','selected_native_shared_query_lifetime')]))
                check('Hello shared768 partial2312 location13 remain separate',
                    r['core_result']['native_original_shared_storage']['interface']['additional_shared_GGC_backing_request_events_upper']==768
                    and r['core_result']['native_original_shared_storage']['partial_ledger']['known_selected_GGC_event_subtotal']==2312
                    and r['selected_native_location_lifetime']['additional_location_and_later_warning_GGC_events_upper']==13)
            else:
                check(name+' different bytes cannot reuse Hello identity',r['source']!=baseline['source'])
            variants.append(dict(name=name,source=r['source'],counts=r['source_counts'],guards=len(r['conditions']),
                evaluated_predicates_pass=r['evaluated_predicates_pass'],event_owners=a['event_owners']))
    ctx.selected['evaluate']=real_evaluate
    for key in incoming['conditions']:
        changed=copy.deepcopy(incoming);changed['conditions'][key]=changed['conditional_conditions'][key]=False
        r=m['attach'](hello,changed,ctx)
        check('inherited failed guard propagates '+key,r['failed_predicates']==[key] and
            r['failed_conditional_predicates']==[key] and not r['evaluated_predicates_pass'] and not r['conditional_arithmetic_pass'])
    # Force each raw newly consumed arithmetic flag false. Structural/source
    # checks must not assert that arithmetic passes or erase the failed flag.
    cases=[]
    for key in incoming['selected_native_ordinary_map_preallocation']['guards']:
        cases.append(('ordinary',['guards',key]))
    for key in ('individual_size_t_products_fit','map_count_and_index_uint64_fit'):
        cases.append(('ordinary',[key]))
    leaves=dict(rtl=baseline['selected_native_RTL_cache_lifetime'],graph=baseline['selected_native_completed_alias_graph'],
                query=baseline['selected_native_shared_query_lifetime'])
    for label,names in [('rtl',('CONST_INT','reg_attrs')),('graph',('alias_sets','child_maps','scalar_finalizers')),
        ('query',('identifier_hash','type_hash','integer_hash','global_decls','stmt_list_cache','alias_sets','scalar_finalizers','counter_endpoints'))]:
        for name in names:
            for key in leaves[label][name]['checks']:cases.append((label,[name,'checks',key]))
            if 'fits' in leaves[label][name]:cases.append((label,[name,'fits']))
    cases.extend([('rtl',['conditional_cache_capacity_established']),
                  ('graph',['conditional_selected_graph_capacity_established']),
                  ('query',['conditional_selected_shared_capacity_established'])])
    for label,path in cases:
        changed=copy.deepcopy(incoming)
        if label=='ordinary':target=changed['selected_native_ordinary_map_preallocation']
        else:target=copy.deepcopy(leaves[label])
        obj=target
        for key in path[:-1]:obj=obj[key]
        obj[path[-1]]=False
        if label!='ordinary':
            original_fn=ctx.leaves[label]['evaluate_source']
            ctx.leaves[label]['evaluate_source']=lambda *a,target=target,**kw:copy.deepcopy(target)
        try:r=m['attach'](hello,changed,ctx)
        finally:
            if label!='ordinary':ctx.leaves[label]['evaluate_source']=original_fn
        check('new raw failed guard propagates '+label+'.'+'.'.join(path),
            len(r['failed_predicates'])==1 and r['failed_predicates']==r['failed_conditional_predicates'] and
            r['failed_predicates'][0] in r['lifetime_attachment']['guards'] and
            not r['evaluated_predicates_pass'] and not r['conditional_arithmetic_pass'])
    # The graph's type-UID comparison has no separate stored boolean.
    real_guards=m['attach'].__globals__['arithmetic_guards']
    def graph_overflow(ordinary,rtl,graph,query):
        graph=copy.deepcopy(graph);graph['joined_type_UID_projection_upper']=2**32
        return real_guards(ordinary,rtl,graph,query)
    m['attach'].__globals__['arithmetic_guards']=graph_overflow
    try:r=m['attach'](hello,incoming,ctx)
    finally:m['attach'].__globals__['arithmetic_guards']=real_guards
    check('new graph type UID numeric comparison returns failure',r['failed_predicates']==['native_lifetime_graph_type_UID_unsigned'])
    for role,path,value,fragment in [
        ('selected',['source','sha256'],'0'*64,'selected actual source'),
        ('selected',['source_counts','null_statements'],99,'selected actual source'),
        ('original',['source','sha256'],'0'*64,'same actual source'),
        ('original',['counter_endpoints','next_DECL_UID_upper'],0,'corrected original identity'),
        ('correction',['identifier_hash','historical_insertions_upper'],0,'exact indexed filename correction'),
        ('named',['source','sha256'],'0'*64,'same actual source'),
        ('named',['named_source_demands','identifier_insertions'],0,'named later ownership')]:
        changed=copy.deepcopy(incoming)
        targets=dict(selected=changed,original=changed['core_result']['native_original_shared_storage']['interface'],
            correction=changed['frontend_location_join']['corrected_shared_identifier_projection'],
            named=changed['selected_native_later_shared_demands'])
        obj=targets[role]
        for key in path[:-1]:obj=obj[key]
        obj[path[-1]]=value
        reject('reject changed '+role+'.'+'.'.join(path),lambda:m['attach'](hello,changed,ctx),fragment)
    for label in ('rtl','graph','query'):
        old=ctx.leaves[label]['evaluate_source']
        def mismatch(*a,old=old,**kw):
            result=old(*a,**kw);result['source']['sha256']='0'*64;return result
        ctx.leaves[label]['evaluate_source']=mismatch
        try:reject('reject changed leaf source '+label,lambda:m['attach'](hello,incoming,ctx),
            'attached actual source' if label=='query' else 'same actual source')
        finally:ctx.leaves[label]['evaluate_source']=old
    for label,path in [('rtl',['new_shared_GGC_backing_request_events_upper']),
                       ('graph',['new_disjoint_GGC_events_upper']),('query',['graph14_events_added_again']),
                       ('query',['complete_collector_lifetime_closed'])]:
        old=ctx.leaves[label]['evaluate_source']
        def mismatch(*a,old=old,path=path,**kw):
            result=old(*a,**kw);result[path[0]]=1;return result
        ctx.leaves[label]['evaluate_source']=mismatch
        try:reject('reject changed event/global scope '+label+'.'+path[0],lambda:m['attach'](hello,incoming,ctx),
            'repaired RTL ownership' if label=='rtl' else 'exact graph ownership' if label=='graph' else
            'global residuals' if path[0]=='complete_collector_lifetime_closed' else 'disjoint maps RTL graph')
        finally:ctx.leaves[label]['evaluate_source']=old
    # A named-only failed projection remains diagnostic; accepted full scoped
    # endpoints, independently evaluated above, supply the new guards.
    changed=copy.deepcopy(incoming)
    named=changed['selected_native_later_shared_demands']['named_only_projection']
    named['checks']=dict.fromkeys(named['checks'],False)
    r=m['attach'](hello,changed,ctx)
    check('named-only false arithmetic never becomes guard',r['conditions']==baseline['conditions'] and r['evaluated_predicates_pass'])
    # Reuse accepted predecessor join to construct a failed line premise; this
    # is an in-memory interface fixture, not a newly admitted failing program.
    frontend=copy.deepcopy(incoming['selected_native_frontend_storage'])
    location=copy.deepcopy(incoming['selected_native_location_lifetime'])
    frontend['components']['physical_sources']['extra_physical_objects']['Main']['physical_line_entries_bound']=2**24+1
    location['Main_physical_line_entries_upper']=2**24+1;location['Main_ordinary_map_line_guard']=False
    failed=ctx.selected['attach'](hello,incoming['core_result'],incoming['selected_native_invocation'],
        incoming['native_Ada_numeric'],frontend,location,ctx.selected_context)
    r=m['attach'](hello,failed,ctx)
    check('actual inherited logical-line failure returns scoped graph and inapplicable maps bound',
        r['failed_predicates']==['native_location_Main_ordinary_map_lines'] and
        not r['lifetime_attachment']['ordinary_maps']['bound_applies'] and not r['evaluated_predicates_pass'])
    pins=m['read'](HERE/'inputs.json');pins['files'][0]['sha256']='0'*64
    reject('reject changed pinned accepted input without second Context',lambda:m['check_pins'](pins),'changed attachment input')
    arithmetic=[]
    for c,n,d in [(1,0,1),(2,2,2),(10000,0,2),(2**31,0,1),(1,2**32,1)]:
        rtl=ctx.leaves['rtl']['transfer'](c,n,ctx.contexts['rtl'])
        graph=ctx.leaves['graph']['transfer'](c,n,d,ctx.contexts['graph'])
        query=ctx.leaves['query']['endpoints'](c,n,d,ctx.contexts['query'])
        ordinary=incoming['selected_native_ordinary_map_preallocation']
        guards=m['arithmetic_guards'](ordinary,rtl,graph,query)
        passed=all(guards.values())
        check('affected arithmetic count case '+str((c,n,d)),passed==(c<2**31 and n<2**32))
        arithmetic.append(dict(C=c,N=n,D=d,passed=passed,failed=[k for k,v in guards.items() if not v]))
    baseline['offline_run']=dict(started_utc=start,completed_utc=datetime.now(timezone.utc).isoformat(),
        scope='Hello generated once in affected lifetime attachment run; no native execution')
    (HERE/'result.json').write_text(json.dumps(baseline,indent=2)+'\n')
    result=dict(started_utc=start,completed_utc=datetime.now(timezone.utc).isoformat(),elapsed_seconds=time.perf_counter()-timer,
        passed=True,checks=len(rows),check_names=rows,variants=variants,affected_arithmetic_cases=arithmetic,
        validation=ctx.validation,new_contexts=1,inherited_guard_count=69,new_guard_count=len(baseline['lifetime_attachment']['guards']),
        native_tool_executions=0,predecessor_suites_rerun=False,broad_suites_rerun=False,
        runtime_census_reinventoried=False,corpus_checkers_rerun=False,
        selected_model='GPT-6.1 Sol',selected_effort='Extra High',runtime_confirmed_model_effort=None,
        token_cost_measurements=None,implementation_inputs={name:m['identity']((HERE/name).read_bytes()) for name in
            ('compose.py','check.py','inputs.json')},
        retained_evidence='selected route129; ordinary1609; writer93 and accepted review; repaired RTL17/21029 states; graph36; query42/33 arithmetic cases and accepted reviews. None replayed.',
        validation_scope='Affected actual-source binding, accepted current lifetime scopes, event ownership and all inherited/new failed-guard propagation; finite arithmetic corroboration only.')
    result['validation_rework']=[
        'First attempt stopped in graph Context because the current pipeline audit note contains the later accepted attachment. Compiler, executable and model/source pins all matched. Narrow exact path/revision/hash prose adapter added; frozen leaves unchanged.',
        'Initial successful changed-overlay run passed196 checks in5.9949517s. Final run adds the exact audit exception allowlist and consumed-argument preservation checks; this code change justified repeating this affected overlay run. No predecessor suite replay.',
        'Initial scratch pin-generator setup lacked the worktree tmp directory; creating the directory changed no candidate source or bound.']
    args.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({k:result[k] for k in ('checks','new_guard_count','elapsed_seconds','native_tool_executions')}))


if __name__=='__main__':main()
