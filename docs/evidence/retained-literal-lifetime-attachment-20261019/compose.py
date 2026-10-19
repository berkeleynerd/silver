#!/usr/bin/env python3
"""Attach reviewed selected literal lifetimes without completing the pipeline.

Offline research only. Predecessor packets and their historical flags stay frozen.
"""
import argparse
import copy
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import runpy
import subprocess
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = REPO/'docs/evidence'
PIPELINE = E/'retained-literal-pipeline-20261018'
PACKETS = dict(rtl='retained-literal-rtl-cache-controls-20261019',
    graph='retained-literal-type-alias-controls-20261019',
    query='retained-literal-shared-query-lifetime-20261019')
AUDIT_NOTE = dict(path='docs/research/retained-literal-pipeline.md',
    revision='603e0feeaab329b6492c3cc8d82f90a7f095c070',bytes=157004,
    sha256='898ee62690d7fe58f639192198ff83aaa7a95a89a88c2a6658250699fa0bc3eb')


def read(path):
    return json.loads(Path(path).read_bytes())


def identity(raw):
    return dict(bytes=len(raw),sha256=hashlib.sha256(raw).hexdigest())


def require(value, message):
    if not value:
        raise ValueError(message)


def check_pins(manifest):
    for row in manifest['files']:
        expected={key:row[key] for key in ('bytes','sha256')}
        raw=(REPO/row['path']).read_bytes()
        require(identity(raw)==expected,'changed attachment input '+row['path'])
        require(len(row['revision'])==40,'full accepted revision required')
        historical=subprocess.check_output(['git','show',row['revision']+':'+row['path']],cwd=REPO)
        require(historical==raw and identity(historical)==expected,
                'changed accepted historical input '+row['path'])


class HistoricalAuditDocument:
    """Bytes of one frozen prose dependency, never a source/code substitute."""
    def __init__(self,row):
        require(row==AUDIT_NOTE,'only exact accepted historical pipeline audit document')
        self.raw=subprocess.check_output(['git','show',row['revision']+':'+row['path']],cwd=REPO)
        require(identity(self.raw)=={k:row[k] for k in ('bytes','sha256')},
                'historical pipeline audit document identity')

    def read_bytes(self):
        return self.raw


class RepositoryAuditView:
    def __init__(self,row):
        self.path=row['path'];self.document=HistoricalAuditDocument(row)

    def __truediv__(self,path):
        return self.document if path==self.path else REPO/path


def audit_extension(view):
    old=view.document.read_bytes();current=(REPO/view.path).read_bytes()
    section=b'## Selected native design route, frontend storage and location attachment\n'
    start=b'`selected-route.json` supplies explicit runtime configuration'
    old_end=b'All 40 core local guards and the three invocation/five numeric guards remain'
    new_end=b'The ordinary-map attachment exports the unchanged accepted preallocation'
    require(old.count(section)==current.count(section)==1 and
        old.split(section)[0]==current.split(section)[0],
        'accepted pipeline argument before attachment section unchanged')
    require(old.count(start)==current.count(start)==old.count(old_end)==current.count(new_end)==1 and
        old.split(start)[1].split(old_end)[0]==current.split(start)[1].split(new_end)[0],
        'consumed selected route source/configuration/frontend argument unchanged')
    return dict(current_note=identity(current),historical_note=identity(old),
        argument_before_attachment_section_unchanged=True,
        selected_source_configuration_frontend_location_argument_unchanged=True,
        later_attachment_extension_review='docs/reviews/review-literal-map-later-attachment-6beebbc39c.md',
        exception_applies_only_to_historical_prose=True)


class Context:
    def __init__(self,gcc_root,ada_root,plugin_include,gcc_match=None):
        manifest=read(HERE/'inputs.json')
        check_pins(manifest)
        self.selected=runpy.run_path(str(PIPELINE/'selected-route.py'))
        self.selected_context=self.selected['Context'](gcc_root,ada_root,plugin_include,gcc_match)
        self.selected_reference=read(PIPELINE/'selected-route-result.json')
        require(len(self.selected_reference['conditions'])==69,'accepted selected69 guard schema')
        self.leaves={name:runpy.run_path(str(E/packet/'derive.py')) for name,packet in PACKETS.items()}
        require(len(manifest['historical_audit_documents'])==1,'one frozen prose input')
        audit=manifest['historical_audit_documents'][0]
        view=RepositoryAuditView(audit)
        extension=audit_extension(view)
        self.contexts={}
        for name,leaf in self.leaves.items():
            globals_=leaf['Context'].__init__.__globals__;actual_repo=globals_['REPO']
            if name in ('graph','query'):globals_['REPO']=view
            try:self.contexts[name]=leaf['Context'](gcc_root)
            finally:globals_['REPO']=actual_repo
        # Reuse the reviewed writer census and argument; check complete source
        # identities without replaying its census/checker or predecessor suites.
        writers=read(E/'retained-literal-ordinary-map-writers-20261019/inputs.json')
        roots=dict(gcc=Path(gcc_root),repo=REPO)
        for row in writers['files']:
            require(identity((roots[row['root']]/row['path']).read_bytes())==
                    {key:row[key] for key in ('bytes','sha256')},
                    'changed reviewed ordinary writer input '+row['path'])
        self.validation=dict(accepted_historical_and_current_records=len(manifest['files']),
            ordinary_writer_identity_records=len(writers['files']),
            leaf_identity_records={name:dict(compiler=ctx.source_files,repository=ctx.repository_files)
                for name,ctx in self.contexts.items()},
            selected_route_validation=self.selected_context.validation,
            identity_sets_overlap_and_must_not_be_added=True,
            accepted_runtime_census_reused=True,predecessor_suites_rerun=False,
            historical_prose_input=audit,
            current_pipeline_extension_correspondence=extension,
            historical_prose_scope='Graph/query Context only: exact accepted pipeline audit note. All compiler, executable, formal-model and source inputs use current pinned bytes; current pipeline note is separately pinned.',
            source_reachability_arguments_are_reviewed_handwritten_arguments=True)


def arithmetic_guards(ordinary,rtl,graph,query):
    """Export every new scoped arithmetic check; never assert it succeeds."""
    guards={}
    def add(prefix,checks):
        for name,value in checks.items():
            require(type(value) is bool,'boolean arithmetic guard '+prefix+name)
            key='native_lifetime_'+prefix+name
            require(key not in guards,'distinct lifetime guard '+key)
            guards[key]=value
    add('ordinary_',ordinary['guards'])
    add('ordinary_',dict(individual_size_t_products=ordinary['individual_size_t_products_fit'],
                         map_count_and_index_uint64=ordinary['map_count_and_index_uint64_fit']))
    for name in ('CONST_INT','reg_attrs'):
        add('RTL_'+name+'_',rtl[name]['checks'])
        add('RTL_'+name+'_',dict(fits=rtl[name]['fits']))
    add('RTL_',dict(conditional_cache_capacity=rtl['conditional_cache_capacity_established']))
    for name in ('alias_sets','child_maps','scalar_finalizers'):
        add('graph_'+name+'_',graph[name]['checks'])
    add('graph_',dict(alias_vector_fits=graph['alias_sets']['fits'],
        type_UID_unsigned=graph['joined_type_UID_projection_upper']<=2**32-1,
        conditional_graph_capacity=graph['conditional_selected_graph_capacity_established']))
    for name in ('identifier_hash','type_hash','integer_hash','global_decls',
                 'stmt_list_cache','alias_sets','scalar_finalizers','counter_endpoints'):
        add('query_'+name+'_',query[name]['checks'])
        if 'fits' in query[name]:add('query_'+name+'_',dict(fits=query[name]['fits']))
    add('query_',dict(conditional_shared_capacity=query['conditional_selected_shared_capacity_established']))
    return guards


def attach(raw,selected,context):
    counts=context.contexts['query'].recognizer(raw)
    source=identity(raw)
    require(selected['source']==source and selected['source_counts']==counts,
            'selected actual source/count join')
    require(selected['conditions'].keys()==context.selected_reference['conditions'].keys() and
            selected['conditional_conditions'].keys()==selected['conditions'].keys(),
            'preserve accepted69 condition keys')
    original=selected['core_result']['native_original_shared_storage']['interface']
    correction=selected['frontend_location_join']['corrected_shared_identifier_projection']
    named=selected['selected_native_later_shared_demands']
    rtl=context.leaves['rtl']['evaluate_source'](raw,context.contexts['rtl'])
    graph=context.leaves['graph']['evaluate_source'](raw,context.contexts['graph'])
    query=context.leaves['query']['evaluate_source'](raw,original,correction,named,rtl,graph,
        context.contexts['query'])
    for label,leaf in [('RTL',rtl),('graph',graph),('query',query)]:
        require(leaf['source']==source and leaf['source_counts']==counts,
                'attached actual source/count join '+label)
    ordinary=selected['selected_native_ordinary_map_preallocation']
    maps=selected['ordinary_map_later_shared_join']
    require(maps['permanent_source_entries_upper']==ordinary['file_count_upper']==1589 and
            ordinary['logical_lines_upper']==2**24 and
            maps['existing_logical_line_guards']==selected['frontend_location_join']['ordinary_map_line_checks'],
            'ordinary lifetime same selected population and line guards')
    c=counts['output_calls']
    require(ordinary['additional_GGC_events_upper']==3 and ordinary['additional_finalizers_upper']==0 and
        [r['rounded_GGC_bytes'] for r in ordinary['allocation_rows']]==[8192,32768,131072] and
        rtl['new_shared_GGC_backing_request_events_upper']==4*c and
        rtl['new_control_direct_GGC_events']==rtl['new_control_hash_replacement_events']==0 and
        graph['new_disjoint_GGC_events_upper']==14 and
        graph['selected_graph_direct_GGC_events_upper']==8 and
        graph['new_shared_GGC_backing_events_upper']==6 and
        graph['new_scalar_finalizer_registrations_upper']==2 and
        all(query[k]==0 for k in ('new_direct_GGC_events','new_shared_GGC_backing_events',
            'new_scalar_registrations','new_ordinary_backing_events','graph14_events_added_again',
            'RTL4C_events_added_again')),'disjoint maps RTL graph and zero-query ownership')
    require(rtl['selected_fixed_RTL_control_lifetimes_closed'] and
        rtl['CONST_INT']['source_lifetime_closed'] and rtl['reg_attrs']['source_lifetime_closed'] and
        graph['selected_graph_lifetime_closed'] and query['same_source_corrected_incoming_history_verified'] and
        all(query[k] for k in ('complete_identifier_lifetime_closed','complete_DECL_UID_lifetime_closed',
            'complete_type_lifetime_closed','complete_tree_integer_cache_lifetime_closed',
            'complete_alias_lifetime_closed','complete_global_decls_lifetime_closed',
            'complete_stmt_list_cache_lifetime_closed','complete_scalar_finalizer_lifetime_closed')),
        'accepted selected source lifetime closure scopes')
    require(all(query[k] is False for k in ('complete_array_finalizer_lifetime_closed',
        'complete_collector_lifetime_closed','complete_global_counter_lifetime_closed',
        'whole_literal_pipeline_capacity_established','production_admission_changed','aggregate_RAM_gate')) and
        query['total_GGC_events'] is None,'query global residuals remain open')
    guards=arithmetic_guards(ordinary,rtl,graph,query)
    require(not (selected['conditions'].keys() & guards.keys()),'new guard names cannot replace inherited guards')
    result=copy.deepcopy(selected)
    result['scope']='selected literal native route with reviewed ordinary, RTL, alias and shared-query lifetimes; incomplete whole pipeline'
    result['conditions'].update(guards);result['conditional_conditions'].update(guards)
    result.update(conditional_arithmetic_pass=all(result['conditional_conditions'].values()),
        failed_conditional_predicates=[k for k,v in result['conditional_conditions'].items() if not v],
        evaluated_predicates_pass=all(v is True for v in result['conditions'].values()),
        failed_predicates=[k for k,v in result['conditions'].items() if v is False],
        unresolved_predicates=[k for k,v in result['conditions'].items() if v is None],
        selected_native_RTL_cache_lifetime=rtl,selected_native_completed_alias_graph=graph,
        selected_native_shared_query_lifetime=query,
        lifetime_attachment=dict(source=source,source_counts=counts,inherited_guards=69,new_guards=len(guards),
            guards=guards,original_corrected_named_RTL_graph_inputs_joined=True,
            ordinary_maps=dict(source_lifetime_closed=True,later_writers_excluded_by_accepted_review=True,
                permanent_source_entries_upper=1589,logical_lines_upper=2**24,
                existing_line_guards=maps['existing_logical_line_guards'],
                bound_applies=maps['ordinary_preallocation_bound_applies'] and
                    all(v for k,v in guards.items() if k.startswith('native_lifetime_ordinary_')),
                lifetime_GGC_events_upper=3,later_GGC_events_upper=0,finalizers_upper=0,
                individual_rounded_requests=[8192,32768,131072]),
            accepted_current_scopes=dict(ordinary_array=True,CONST_INT_cache=True,reg_attrs_cache=True,
                fixed_RTL_controls=True,completed_alias_graph=True,identifier_hash=True,DECL_UID=True,
                type_UID=True,tree_integer_cache=True,alias_sets=True,global_decls=True,
                stmt_list_cache=True,scalar_finalizers=True),
            event_owners=dict(ordinary_maps=3,RTL_caches=4*c,completed_alias_graph=14,shared_query=0),
            event_owners_are_disjoint_but_not_a_complete_ledger=True,
            accepted_reviews=[row for row in read(HERE/'inputs.json')['files'] if '/reviews/' in row['path']],
            historical_leaf_pending_flags_preserved=True,
            diagnostic_named_only_projection_used_as_guard=False,
            independent_attachment_review_status='pending',total_GGC_events=None),
        validation=context.validation)
    result['ordinary_map_leaf_scope']='Frozen preallocation-only leaf. lifetime_attachment.ordinary_maps supplies the accepted selected full ordinary-array source lifetime; its arithmetic remains conditional on inherited source population and logical-line guards.'
    result['later_shared_leaf_scope']='Frozen named-demand leaf. Its null residual/endpoints remain historical; selected_native_shared_query_lifetime supplies the reviewed complete selected identifier/tree-cache/alias/global/list/scalar endpoints and guards. No diagnostic projection becomes a guard.'
    result['location_leaf_scope']='Frozen location leaf; its old ordinary-writer/shared residual wording is historical. Current scoped lifetime closure is recorded by lifetime_attachment; collector/native totals remain open.'
    result['RTL_graph_query_leaf_scope']='Frozen accepted leaves as repaired. Their historical independent-review or remaining-family strings are preserved; lifetime_attachment records accepted current scopes separately. No leaf pending string is a new completion claim.'
    result['accounting']='Existing source-specific shared and partial ledgers are unchanged. Ordinary maps own three events, repaired RTL caches own 4C, completed alias graph owns14, and query closure owns zero. Location/warning remains separate. No event sum is a complete ledger; ordinary scalar backings are not GGC events.'
    result['open_joins']['native_remaining_lifetime_and_collector']='Selected ordinary array, RTL caches/fixed controls and completed alias/shared-query/scalar lifetimes are attached. mem_attrs/setters, SSA/instruction/label/register/DF/emission counters, ordinary pools/stacks, array/outer-finalizer/depth, collector page/mark state, remaining frontend/pass heaps and the complete disjoint event/object ledger remain open. No complete original/native total follows.'
    return result


def evaluate(descriptor_path,context,source_override=None):
    selected=context.selected['evaluate'](descriptor_path,context.selected_context,source_override)
    raw=Path(selected['source_path']).read_bytes()
    return attach(raw,selected,context)


if __name__=='__main__':
    start=datetime.now(timezone.utc).isoformat();timer=time.perf_counter()
    parser=argparse.ArgumentParser(description=__doc__)
    runpy.run_path(str(PIPELINE/'compose.py'))['arguments'](parser)
    parser.add_argument('--descriptor',type=Path,default=PIPELINE/'selected-route.json')
    parser.add_argument('--source',type=Path);parser.add_argument('--output',type=Path,required=True)
    args=parser.parse_args()
    result=evaluate(args.descriptor,Context(args.gcc_root,args.ada_root,args.plugin_include,args.gcc_match),args.source)
    result['offline_run']=dict(started_utc=start,completed_utc=datetime.now(timezone.utc).isoformat(),elapsed_seconds=time.perf_counter()-timer)
    args.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(evaluated_predicates_pass=result['evaluated_predicates_pass'],
        guards=len(result['conditions']),whole_literal_pipeline_capacity_established=False)))
