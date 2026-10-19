#!/usr/bin/env python3
"""New selected GGC ownership join; no predecessor evaluator or checker calls."""
import argparse
import hashlib
import json
from pathlib import Path
import runpy

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
EVIDENCE = REPO/'docs/evidence'
NATIVE = EVIDENCE/'unbounded-programs/retained-native-expansion-20261017'
ATTACHMENT = EVIDENCE/'retained-literal-mem-ssa-attachment-20261019/result.json'
I32, U32, I64, OBJECT_LIMIT = 2**31-1, 2**32-1, 2**63-1, 2**62


def require(value, message):
    if not value:
        raise ValueError(message)


def read(path):
    return json.loads(Path(path).read_bytes())


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def power2(value):
    return 1 << (max(1,value)-1).bit_length()


def row(owner, events, raw, authority):
    require(type(events) is int and events >= 0 and type(raw) is int and raw >= 0,
            'nonnegative owner/request')
    return dict(owner=owner, positive_GGC_requests_upper=events,
        each_raw_request_bytes_upper=raw,
        each_rounded_request_bytes_upper=power2(max(8,raw)), authority=authority)


def growth_count(extent):
    capacity, allocations = 0, 0
    while capacity < extent:
        capacity = 4 if capacity == 0 else (2*capacity if capacity < 16 else 3*capacity//2)
        allocations += 1
    return allocations


def additions(c, n):
    """Pure new count transfer. Does not supply a source or prior-owner proof."""
    require(type(c) is int and c >= 1 and type(n) is int and n >= 0,
            'selected C/N domain')
    k0, k, b, r0 = 98+3*c, 99+5*c, 2*n+10, 64*c+n+16
    e = b-1
    a1 = (power2(8+56*max(4,k))-8)//56
    second_slots = max(3*a1//2,2*k)
    second_bytes = power2(8+56*second_slots)
    a2 = (second_bytes-8)//56
    edge_bytes = power2(8+8*max(4,2*e))
    map_bytes = power2(8+8*max(20,2*b))
    rows = [
        row('expansion_CALL_EXPR_trees',c,56,'cfgexpand.cc:3131; shared-query rooted hits'),
        row('second_LRA_unshare_nonchain',r0+600*c,24,'lra.cc:2688; emit-rtl.cc:3250-3355'),
        row('second_LRA_unshare_blockage_rtvec',1,16,'emit-rtl.cc:3339-3340'),
        row('alias_pointer_vectors',2,max(8+8*(k-92),8+8*k),'accepted literal backing alias_direct_helpers'),
        row('reload_equivalence_vectors',2,second_bytes,'reload1.cc:644-657; two additional-slot reserves'),
        row('LRA_elimination_REGs',8,24,'accepted elimination-register constructor source'),
        row('IRA_root_loop_setups',10,1024,'two root-only loop setups and optional exit hash'),
        row('LRA_unused_pseudo',1,24,'lra.cc:2420-2439'),
        row('frame_patterns_notes_sequences_hashes',19,248,'accepted frame 7+3+5+4 owners'),
        row('RTL_new_CFG_blocks',n+6,96,'two expansion blocks and N+4 layout-edge splits'),
        row('RTL_new_CFG_edges',n+6,48,'same selected block/edge routes'),
        row('RTL_block_information',b,24,'incoming and newly created blocks'),
        row('RTL_block_map_growth',n+6,map_bytes,'monotone map; one growth per new block'),
        row('RTL_edge_vector_growth',(2*b-2)*growth_count(e),edge_bytes,
            'transferred monotone histories, cold overallowance of additional events'),
        row('variable_expansion_cold_sequence',1,24,'cfgexpand.cc:7091-7099'),
        row('CFI_nonchain_and_backings',4*n+39,256,'2N+10 rows/vectors and 19 fixed events'),
        row('late_cgraph_RTL_info',1,24,'final.cc:4521-4528; cgraph.cc:2408-2427'),
        row('final_sections_and_text_ranges',5,256,'two sections, two strings, one range vector')]
    guards = dict(reload_first_normalized_capacity=a1 <= I32,
        reload_second_normalized_capacity=a2 <= I32,
        reload_growth_unsigned=3*a1 <= U32 and 2*k <= U32,
        reload_individual_request=second_bytes <= I64,
        CFG_signed_extent=4*b <= I32,
        CFG_vector_growth_unsigned=3*max(e,b) <= U32,
        CFG_vector_normalized_capacity=max((edge_bytes-8)//8,(map_bytes-8)//8) <= I32,
        CFG_individual_requests=max(edge_bytes,map_bytes) <= I64,
        second_unshare_individual_requests=24 <= OBJECT_LIMIT and 16 <= OBJECT_LIMIT,
        LRA_signed_hard_register_frequency=10000*c <= I32)
    return dict(counts=dict(C=c,N=n,K0=k0,K=k,B=b,E_CFG=e,R0=r0),rows=rows,
        new_owner_events_upper=sum(x['positive_GGC_requests_upper'] for x in rows),
        reload_equivalence=dict(record_bytes=56,first_capacity_upper=a1,
            first_bytes_upper=power2(8+56*max(4,k)),second_extra_slots_upper=k,
            second_desired_length_upper=2*k,second_pre_round_slots_upper=second_slots,
            second_capacity_upper=a2,second_bytes_upper=second_bytes),
        edge_vectors=dict(histories_upper=2*b-2,allocations_per_history_upper=growth_count(e),
            lifetime_degree_upper=e,each_request_bytes_upper=edge_bytes,
            incoming_backings_receive_cold_credit=True,owner_interval='additional RTL requests'),
        hard_register_usage=dict(element_type='int',block_frequency_upper=1000,
            pseudo_frequency_upper=2000,instruction_register_records_upper=10*c,
            per_hard_register_sum_upper=10000*c,selected_reassignment_updates=0,
            point_frequency_element_type='int',point_frequency_accumulation=False),
        local_representation_checks=guards,fits=all(guards.values()))


class Context:
    def __init__(self,gcc_root):
        manifest = read(HERE/'inputs.json')
        roots = dict(gcc=Path(gcc_root),repository=REPO)
        for pin in manifest['files']:
            require(identity((roots[pin['root']]/pin['path']).read_bytes()) ==
                    {k:pin[k] for k in ('bytes','sha256')},'changed input '+pin['path'])
        self.verified = {name:sum(x['root']==name for x in manifest['files']) for name in roots}
        # Only the standalone recognizer is called; no predecessor Context or main.
        self.recognize = runpy.run_path(str(NATIVE/'derive-literal-output.py'))['source_counts']
        self.selected = read(ATTACHMENT)
        self.finalizer = read(EVIDENCE/'retained-literal-finalizer-lifetime-20261019/result.json')
        self.collector = read(NATIVE/'native-ggc-storage.json')


def compose(raw, source_path, selected, context):
    require(all(32<=b<=126 or b in (9,10,13) for b in raw),'current selected source alphabet')
    counts, source = context.recognize(raw), identity(raw)
    core = selected['core_result']
    require(selected['source'] == core['source'] == source,'actual source identity')
    require(selected['source_counts'] == core['source_counts'] == counts,'actual source counts')
    require(source_path == selected['source_path'] == core['source_path'],'exact source path')
    require(selected['launch'] == core['launch'] and
            selected['complete_path_bound'] == core['complete_path_bound'],'path/launch equality')
    for name in ('selected_native_frontend_storage','selected_current_source_bound_shared_storage',
                 'selected_native_MEM_counter_lifetime','selected_native_SSA_lifetime_extension'):
        require(selected[name]['source']==source and selected[name]['source_counts']==counts,
                'nested same-source owner '+name)
    for name in ('lifetime_attachment','mem_ssa_attachment'):
        require(selected[name]['source']==source and selected[name]['source_counts']==counts and
                all(selected[name]['guards'].values()),'accepted attachment '+name)
    require(selected['conditional_arithmetic_pass'] and core['conditional_arithmetic_pass'] and
            all(selected['conditions'].values()),'inherited caller/counter guards')
    c,n = counts['output_calls'],counts['null_statements']
    new = additions(c,n)
    require(counts['maximum_literal_length']<=I32,'literal length')
    ingress = core['native_gimplifier_ingress']
    require(ingress['whole_body_GGC_request_events_upper']==33*c+9*n+3 and
        ingress['corrected_direct_gimplifier_GGC_events_upper']==10*c+2*n+2 and
        ingress['selected_helper_subtotal_GGC_events_upper']==8*c,'gimplifier existing owners')
    lowering = core['native_lowering_data']
    op = lowering['conditional_native_selected_constructor_requests']
    require(op['selected_nonchain_RTX_lifetime_requests_upper']==104*c+n+17 and
        op['selected_rtvec_lifetime_requests_upper']==2*c+2 and
        op['call_and_move_sequence_stack_requests_upper']==8*c,'operation owner interface')
    backing = core['selected_native_backing']
    require(backing['DF_selected_reference_and_solver_transfer'][
        'selected_REG_DEAD_UNUSED_note_requests_upper']==600*c,'DF/LRA note owner')
    mem = selected['selected_native_MEM_counter_lifetime']
    require(mem['RTL']['final_first_unused_pseudo_upper']==99+5*c and
        mem['RTL']['final_chain_upper']==7*c+7*n+45 and
        mem['mem_attrs']['variable_records_already_owned']==5*c,'MEM/register/chain owners')
    shared = selected['selected_current_source_bound_shared_storage']
    original = core['native_original_shared_storage']['partial_ledger']
    original_groups = original['GGC_groups']
    distinct = int(counts['Put']>0)+int(counts['Put_Line']>0)
    require(original_groups == dict(original_Main=609*c+24*n+54*distinct+398,
        original_String216=216,original_helpers94=94,synthetic173=173,
        new_shared_backings=331*c+12*n+19*distinct+418),'original exact owner formulas')
    require(original['known_selected_GGC_event_subtotal']==sum(original_groups.values()) and
        original_groups['new_shared_backings']==shared['additional_shared_GGC_backing_request_events_upper'],
        'original shared subtotal ownership')
    require(not original['prefix_and_filename_ingress_in_subtotal'] and
        not original['forced_dummy_and_warning_symbol_controls_in_subtotal'],'original exclusions')
    front = selected['selected_native_frontend_storage']['components']['gigi_array_and_name_input']
    require(front['association_array_requests']==2 and front['each_association_array_raw_bytes_upper']==
        8*front['joined_frontend_node_identities_upper'],'association caller product')
    filename = shared['filename_ingress']
    require(filename['direct_GGC_requests_upper']==2*filename['lookup_calls_upper']==3180 and
        filename['each_character_caller_bytes_upper']==selected['complete_path_bound']+1,
        'corrected filename/path owner')
    require(shared['identifier_hash']['incoming_historical_insertions_upper']==40847,
        'corrected incoming identifier history')
    query = selected['selected_native_shared_query_lifetime']
    alias = selected['selected_native_completed_alias_graph']
    cache = selected['selected_native_RTL_cache_lifetime']
    loc = selected['selected_native_location_lifetime']
    warning = core['native_warning_map_demand']['conditional_map_transfer']
    finalizer = context.finalizer
    require(finalizer['scalar_history_upper']==39275 and finalizer['array_registration_history']==0 and
        finalizer['context_depth']==0 and finalizer['new_GGC_events']==0,'accepted finalizer owner')
    require(query['scalar_finalizers']['historical_registrations_upper']==39275,
        'query/finalizer scalar equality')
    require(core['native_collector_callbacks']['collector_callback_additional_GGC_events']==0 and
        selected['selected_native_SSA_lifetime_extension']['later_new_SSA_NAME_objects']==0,
        'zero callback and later SSA owners')
    rows = []
    def add(name,count,size,authority): rows.append(row(name,count,size,authority))
    add('fixed_prefix',39257,65536,'retained fixed-prefix source projection and witness')
    add('filename_ingress',3180,max(40,filename['each_character_caller_bytes_upper']),
        'selected_current_source_bound_shared_storage.filename_ingress')
    maps = selected['selected_native_ordinary_map_preallocation']
    add('ordinary_line_map_array',maps['additional_GGC_events_upper'],maps['each_caller_bytes_upper'],
        'ordinary-map owner extended by accepted complete location/query lifetime')
    add('GNAT_node_association_arrays',2,front['each_association_array_raw_bytes_upper'],
        'selected_native_frontend_storage.components.gigi_array_and_name_input')
    main = core['native_original_Main_storage']['interface']
    add('original_Main',original_groups['original_Main'],max(x['caller_bytes_each'] for x in main['rows']),
        'original Main rows plus fixed-context I, excluding Main struct_function')
    add('original_String',original_groups['original_String216'],2048,'accepted fixed String216 direct requests')
    add('original_size_helper_construction',original_groups['original_helpers94'],
        max(512,selected['complete_path_bound']+64),'accepted helper94 direct requests')
    add('synthetic_nonMain_structures_and_gimplification',original_groups['synthetic173'],1024,
        'accepted synthetic173; three nonMain function structures')
    sg = shared['unchanged_other_shared_projections']
    add('original_shared_backings',original_groups['new_shared_backings'],
        max(sg[k]['each_caller_bytes_upper'] for k in
            ('type_hash','integer_hash','global_decls','stmt_list_cache','alias_sets')),
        'actual-source corrected original shared requests; already inside original subtotal')
    add('Main_struct_function',5,320,'function208, EH48, two EH vectors40, machine320')
    add('Main_gimplifier_trees_and_tuples',51*c+11*n+5,312,
        'exhausted existing whole-body + corrected direct + 8C helpers')
    add('original_and_initial_warning_backing',warning['additive_GGC_event_ceiling'],
        max(x['raw_bytes_each'] for x in warning['request_groups']),'conditional_map_transfer')
    add('later_locations_and_warning_backing',loc['additional_location_and_later_warning_GGC_events_upper'],
        max(loc['ad_hoc_storage']['each_caller_bytes_upper'],loc['later_warning']['each_caller_bytes_upper']),
        'complete location lifetime; original warning owner excluded')
    for key,label,group_key in (
        ('native_pool_lifetime','pool_varpool_and_shared_backings','individual_request_groups'),
        ('native_graph_lifetime','graph_symbols_and_summaries','individual_GGC_request_groups'),
        ('native_initial_SSA_lifetime','initial_SSA_complete_lifetime','individual_GGC_request_groups'),
        ('native_initial_CF_CFG_lifetime','initial_CF_CFG','individual_GGC_request_groups')):
        owner = core[key]
        add(label,owner['additional_GGC_request_events_upper'],
            max(x['raw_bytes_upper'] for x in owner[group_key] if x.get('storage','GGC')=='GGC'),key)
    add('first_RTL_setup',437,max(65536,cache['CONST_INT']['each_backing_caller_bytes_upper']),
        'fixed175 + cold constants120 + sequences10 + dummy11 + CONST_INT backing121')
    add('Main_RTL_initialization',4,1584,'initial pointer vector, constant pool, hash control/backing')
    add('operation_nonchain_RTX_through_first_unshare',104*c+n+17,24,
        '40C+1+R0; first cfgexpand unshare retained')
    add('whole_final_instruction_chain',7*c+7*n+45,72,'replaces expansion I0; includes frame/CFI/merge chain')
    add('operation_rtvecs_through_first_unshare',2*c+2,24,'2C transient ABI vectors plus initial/first blockage')
    add('operation_reg_attrs',c,16,'descriptor reg_attrs; shared cache separate')
    add('operation_mem_attrs',5*c,40,'accepted complete MEM setter lifetime')
    add('operation_sequence_stacks',8*c,24,'cold-per-scope lifetime allowance')
    add('direct_constant_pool_objects',10*c,312,'direct pool10C; graph/pool backings separate')
    add('empty_temporary_slot_vector',2,32,'depth1, no stack payload')
    add('whole_Main_register_pointer_growth',mem['RTL']['complete_Main_growths_upper'],
        mem['RTL']['each_final_pointer_request_bytes_upper'],'q(K) replaces q(K0), initial vector separate')
    add('wide_split_REG_rtvec_attrs',5*c,24,'2C REG + C two-element rtvec + 2C attrs')
    add('DF_LRA_register_note_construction',600*c,24,'accepted backing note owner; second copies separate')
    add('RTL_CONST_INT_and_reg_attrs_backings',
        cache['CONST_INT']['new_shared_GGC_backing_events_upper']+
        cache['reg_attrs']['new_shared_GGC_backing_events_upper'],
        max(cache[x]['each_backing_caller_bytes_upper'] for x in ('CONST_INT','reg_attrs')),
        'complete post-setup cache lifetime; fixed121 stays in first_RTL_setup')
    add('completed_alias_graph_and_later_backings',alias['new_disjoint_GGC_events_upper'],
        max(1024,alias['alias_sets']['each_caller_bytes_upper']),
        'new direct8 + later shared6; original4 backings not repeated')
    rows += new['rows']
    total = sum(x['positive_GGC_requests_upper'] for x in rows)
    require(len({x['owner'] for x in rows})==len(rows),'unique allocation owners')
    cap = power2(max(128,total))
    guards = dict(new['local_representation_checks'])
    guards.update(individual_GGC_order_region=all(x['each_raw_request_bytes_upper']<=OBJECT_LIMIT for x in rows),
        active_page_signed_index=total<=I32,active_page_unsigned_capacity=cap<=U32,
        each_active_page_pointer_backing=8*cap<=I64,
        association_individual_caller_product=front['each_association_array_raw_bytes_upper']<=I64,
        source_bound_inherited_guards=True)
    return dict(scope='Selected literal Main positive GGC owner partition and collector indexed storage',
        source=source,source_path=source_path,source_counts=counts,launch=selected['launch'],
        complete_path_bound=selected['complete_path_bound'],same_source_path_and_owner_join_verified=True,
        new_transfer=new,owner_rows=rows,total_positive_GGC_events_upper=total,
        selected_GGC_event_partition_closed=True,
        gimplifier_exhaustion=dict(existing_event_sum=51*c+11*n+5,new_events=0,
            initial_SSA_warnings_and_pool_owners_remain_separate=True),
        ownership=dict(fixed_prefix_retained=39257,filename_ingress_separate=3180,
            association_arrays_separate=2,original_subtotal=original['known_selected_GGC_event_subtotal'],
            original_subtotal_added_as_an_extra_row=False,historical_null_totals_added=False,
            expansion_chain_replaced_by_whole_final_chain=True,
            expansion_register_growth_replaced_by_whole_Main_growth=True,
            scalar_finalizer_history_recomputed_from_event_total=False),
        collector=dict(active_pages_upper=total,each_pointer_vector_capacity_upper=cap,
            each_pointer_vector_request_bytes_upper=8*cap,unused_quire_pages_in_active_count=False,
            maximum_page_entry_request_bytes=128,maximum_bitmap_with_sentry_bytes=72,
            maximum_objects_per_page=512,maximum_free_count_or_hint=513,
            quire_request_bytes=2097152,page_table_chain_bytes=2064,secondary_lookup_bytes=32768,
            scalar_finalizer_history_upper=39275,scalar_finalizer_capacity_upper=58911,
            scalar_finalizer_backing_bytes_upper=942584,array_finalizer_registrations=0,
            context_depth=0,depth_backing_bytes=40,each_outer_finalizer_backing_bytes=40,
            old_context_bitmap_backups=0,callback_GGC_events=0,
            marker_ordinary_request_bytes_each=104,actual_collection_count=None,
            scheduling_counters_require_cumulative_byte_no_wrap=False,
            individual_caller_arithmetic_remains_required=True),
        local_representation_checks=guards,
        conditional_selected_GGC_and_collector_storage_capacity=all(guards.values()),
        zero_added_GGC_families=['later SSA','collector callbacks','finalizer vectors',
            'shared bitmap/pools','ordinary IRA/DF/LRA/CFI helpers'],
        remaining_ordinary_owners=['IRA allocno/object/preference/cost-class and traversal/emit storage',
            'remaining LRA helper arrays/maps','RTL CFG/jump/label temporary containers',
            'CFI trace/hash/vector capacities'],
        complete_all_ordinary_native_capacity=False,complete_native_capacity=False,
        whole_literal_pipeline_capacity_established=False,production_invocation_established=False,
        production_admission_changed=False,aggregate_RAM_gate=False,
        source_argument_is_handwritten=True,independent_review_status='pending',
        verified_input_files=context.verified,native_tool_executions=0,
        predecessor_evaluator_or_checker_executions=0,aggregate_executions=0,corpus_replays=0)


def evaluate_default(context):
    return compose((REPO/'samples/hello_world.adb').read_bytes(),
        context.selected['source_path'],context.selected,context)


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gcc-root',type=Path,default=Path('/tmp/silver-backend-compose-20261018/full-source'))
    parser.add_argument('--output',type=Path,default=HERE/'result.json')
    args=parser.parse_args()
    result=evaluate_default(Context(args.gcc_root))
    args.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(positive_GGC_events=result['total_positive_GGC_events_upper'],
        fits=result['conditional_selected_GGC_and_collector_storage_capacity'])))


if __name__=='__main__':
    main()
