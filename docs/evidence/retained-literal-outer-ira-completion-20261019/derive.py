#!/usr/bin/env python3
"""Pure selected outer-IRA interface arithmetic, never an admission rule."""
from pathlib import Path
import hashlib
import json

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
I32, U32, I64 = 2**31-1, 2**32-1, 2**63-1


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def require(value, message):
    if not value:
        raise ValueError(message)


def arithmetic(c, n):
    require(type(c) is int and c >= 1 and type(n) is int and n >= 0, 'literal C/N domain')
    a, k, b = 4*c, 99+5*c, 2*n+10
    m = 7*c+5*n+20
    u, p, d = m+2, 2*m+b, 17690*c+368*n+19076
    dense = lambda bits: 8+8*((bits+63)//64)
    scratch = 8*(a//2)
    # Halving recursion; an overbound valid even outside the selected guards.
    depth = (max(a,94)-1).bit_length()+1
    requests = dict(alias_new_base_array=8*k, alias_known_equiv_bitmap=dense(k-92),
        alias_seen_bitmap=dense(k), alias_reverse_postorder=4*b,
        DF_each_postorder=4*b, DF_block_index_map=4*b,
        DF_considered_bitmap=dense(b), DF_last_visit_age=8+4*b,
        DF_last_change_age=8+4*(b+1), DF_problem_control=64,
        DF_LR_private_control=128,
        IRA_sort_scratch=0 if scratch <= 256 else scratch,
        DF_sort_scratch=376)
    guards = dict(alias_register_index_signed=k <= I32,
        alias_dense_rounding_unsigned=k+63 <= U32,
        alias_dense_stored_bytes_unsigned=dense(k) <= U32,
        alias_pointer_request_span=8*k <= I64,
        alias_dense_request_span=dense(k) <= I64,
        CFG_block_successor_signed=b+1 <= I32,
        DF_age_vector_capacity_31_bit=b+1 <= I32,
        DF_dense_rounding_unsigned=b+63 <= U32,
        DF_dense_stored_bytes_unsigned=dense(b) <= U32,
        DF_scratch_request_span=max(4*b,8+4*(b+1),dense(b)) <= I64,
        DF_reference_and_hard_nrefs_signed=d <= I32,
        DF_solver_age_and_dcount_signed=b+k*(b-1) <= I32,
        sort_allocno_count_signed=a <= I32,
        sort_object_endpoint_difference_signed=p+1 <= I32,
        sort_pointer_array_span=8*a <= I64,
        sort_scratch_request_span=scratch <= I64,
        sort_DF_register_difference_signed=k <= I32,
        sort_DF_order_difference_signed=d <= I32)
    return dict(source_counts=dict(output_calls=c,null_statements=n),
        extents=dict(A=a,K=k,B=b,M=m,U=u,P=p,D=d),
        individual_ordinary_requests_upper=requests,
        chronology=dict(alias_calls=1,alias_iterations_upper=10,alias_unique_id_peak=1,
            root_loop_setups_upper=2,outer_pre_LRA_DF_analyses_upper=3,
            selected_whole_backend_DF_analyses_upper=4,complete_DF_scan_generations=2,
            NOTE_problem_creations=1,LR_iterative_solver_visits_upper=b+k*(b-1),
            hard_regno_nrefs_upper=d,referenced_pseudos=a,
            selected_simple_LRA_threshold_uint64_product=1000000,
            object_sorts=1,fast_priority_sorts=1,each_IRA_sort_elements_upper=a,
            root_removal_sort_elements=0,per_register_rebuild_sort_elements_upper=1,
            DF_each_collection_sort_elements_upper=94,
            sort_fixed_automatic_scratch_bytes=256,sort_recursion_frames_upper=depth,
            target_probe_mode_register_pairs_upper=124*92,
            target_probe_constraints_operands_upper=30,
            target_probe_constraints_alternatives_upper=35,
            target_probe_matching_index_upper=29,
            target_probe_new_pseudos=0,target_probe_new_UIDs=0,
            target_probe_added_main_chain_nodes=0),
        GGC_correction=dict(owner='IRA_cold_prohibited_mode_probe',
            positive_GGC_requests_upper=4,each_raw_request_bytes_upper=72,
            each_rounded_request_bytes_upper=128,
            constructor_requests=[dict(kind='REG',count=2,each_raw_bytes_upper=24),
                                  dict(kind='SET',count=1,each_raw_bytes_upper=24),
                                  dict(kind='INSN',count=1,each_raw_bytes_upper=72)],
            aggregate_raw_bytes_upper=144,aggregate_rounded_bytes_upper=224,
            old_50_owners_unchanged=True,prior_complete_partition_claim_superseded=True,
            actual_source_collector_attachment_required=True,issue=146),
        ownership=dict(alias_ordinary_requests_already_in_core=True,
            DF_scan_arrays_pools_and_references_reused=True,
            CFG_root_dominance_requests_reused=True,shared_bitmaps_and_ET_pools_reused=True,
            IRA_graph_cost_live_storage_reused=True,IRA_numeric_reused=True,
            IRA_equivalence_reginfo_regstat_storage_reused=True,
            GGC_old_owners_recharged=0,scalar_finalizer_delta=0,array_finalizer_delta=0,
            shared_bitmap_or_ET_event_delta=0),
        local_representation_checks=guards,
        failed_predicates=[key for key,value in guards.items() if not value],
        conditional_remaining_outer_IRA_interface_arithmetic=all(guards.values()),
        complete_selected_outer_IRA_source_interfaces=True,
        source_argument_requires_accepted_route_and_inherited_guards=True,
        actual_source_attachment_implemented=False,corrected_collector_capacity_established=False,
        all_LRA_capacity_established=False,complete_native_capacity=False,
        whole_literal_pipeline_capacity_established=False,aggregate_RAM_gate=False,
        production_admission_changed=False,native_tool_executions=0,
        predecessor_evaluator_executions=0,source_argument_is_handwritten=True)


def validate_inputs(gcc_root, manifest=None):
    manifest = manifest or json.loads((HERE/'inputs.json').read_bytes())
    roots = dict(gcc=Path(gcc_root),repository=REPO)
    for row in manifest['files']:
        raw = (roots[row['root']]/row['path']).read_bytes()
        require(identity(raw) == row['identity'], 'input identity: '+row['path'])
    for row in manifest['excerpts']:
        raw = (roots[row['root']]/row['path']).read_bytes()
        # LF coordinates deliberately retain form feeds and all other bytes.
        text = b'\n'.join(raw.split(b'\n')[row['first_LF_line']-1:row['last_LF_line']])
        require(text.decode() == row['text'] and identity(text) == row['identity'],
                'LF excerpt: '+row['name'])
        require(all(fragment in row['text'] for fragment in row['operative_fragments']),
                'operative fragment: '+row['name'])
    return dict(files=len(manifest['files']),excerpts=len(manifest['excerpts']))


def retained_reconciliation():
    """Read accepted Hello records only; never execute predecessor modules."""
    path = REPO/'docs/evidence/retained-literal-ira-lra-helper-attachment-20261019/result.json'
    old = json.loads(path.read_bytes())
    require(old['source_counts']['output_calls'] == 1 and old['source_counts']['null_statements'] == 0,
            'retained Hello counts')
    result = arithmetic(1,0)
    core = old['core_result']['selected_native_backing']
    alias = core['alias_direct_helpers']
    req = result['individual_ordinary_requests_upper']
    for new, previous in [('alias_new_base_array','new_base_pointer_array_bytes_upper'),
                          ('alias_seen_bitmap','seen_bitmap_bytes_upper'),
                          ('alias_known_equiv_bitmap','known_equiv_bitmap_bytes_upper'),
                          ('alias_reverse_postorder','reverse_postorder_array_bytes_upper')]:
        require(req[new] == alias[previous], 'alias retained owner: '+new)
    require(core['DF_selected_reference_and_solver_transfer']['ref_order_final_upper'] == result['extents']['D'],
            'DF reference owner')
    ledger = old['selected_native_GGC_ledger']
    rows = ledger['owner_rows']
    require(len(rows) == 50 and len({r['owner'] for r in rows}) == 50,'50 distinct inherited GGC owners')
    require(all(r['owner'] != result['GGC_correction']['owner'] for r in rows),'new owner disjoint')
    events = sum(r['positive_GGC_requests_upper'] for r in rows)
    require(events == 47054 == old['selected_positive_GGC_events_upper'],'retained old event record')
    return dict(accepted_record=identity(path.read_bytes()),accepted_367_guard_schema=len(old['conditions']),
        accepted_source=old['source'],inherited_owner_names=[r['owner'] for r in rows],
        inherited_ledger_identity=identity(json.dumps(rows,sort_keys=True,separators=(',',':')).encode()),
        inherited_events=events,correction_events=4,corrected_event_envelope=events+4,
        corrected_owner_count=51,corrected_collector_transfer_evaluated=False,
        old_record_preserved_as_history=True,old_complete_partition_claim_superseded=True,
        fixed_Hello_is_not_general_actual_source_correspondence=True)
