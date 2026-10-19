#!/usr/bin/env python3
"""Named CFI/CFG ordinary containers; pure arithmetic and frozen-input attachment.

No predecessor Context/evaluator, aggregate, native tool, or capture is run.
The accompanying source argument supplies reachability and mutation lifetimes.
"""
import argparse
import copy
import hashlib
import json
from pathlib import Path
import runpy

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
EVIDENCE = REPO / 'docs/evidence'
NATIVE = EVIDENCE / 'unbounded-programs/retained-native-expansion-20261017'
I32, U32, I64, U64 = 2**31-1, 2**32-1, 2**63-1, 2**64-1
PRIMES = (7,13,31,61,127,251,509,1021,2039,4093,8191,16381,32749,
          65521,131071,262139,524287,1048573,2097143,4194301,8388593,
          16777213,33554393,67108859,134217689,268435399,536870909,
          1073741789,2147483647,4294967291)


def require(value, message):
    if not value:
        raise ValueError(message)


def read(path):
    return json.loads(Path(path).read_bytes())


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def verify_inputs(gcc_root, manifest=None):
    manifest = read(HERE / 'inputs.json') if manifest is None else manifest
    roots = dict(gcc=Path(gcc_root), repository=REPO)
    for row in manifest['files']:
        raw = (roots[row['root']] / row['path']).read_bytes()
        require(identity(raw) == {k: row[k] for k in ('bytes', 'sha256')},
                'changed CFI/CFG input ' + row['path'])
    for row in manifest['excerpts']:
        text = (roots[row['root']] / row['path']).read_text()
        require(row['text'] in text, 'missing CFI/CFG source excerpt ' + row['name'])
    return dict(source_files=sum(r['root']=='gcc' for r in manifest['files']),
                repository_files=sum(r['root']=='repository' for r in manifest['files']),
                source_excerpts=len(manifest['excerpts']))


def recognize(raw):
    require(isinstance(raw, bytes) and raw and
            all(b in (9,10,13) or 32 <= b <= 126 for b in raw),
            'selected physical Main alphabet')
    # Only the standalone recognizer is called; no old composition/evaluator.
    fn = runpy.run_path(str(NATIVE / 'derive-literal-output.py'))['source_counts']
    return fn(raw)


def next_prime(demand):
    return next((p for p in PRIMES if p >= demand), None)


def hash_bound(name, initial, entries, element_bytes):
    require(all(type(x) is int and x >= 0 for x in (initial, entries, element_bytes)),
            'hash input domain')
    demand = max(7, initial, 2*entries)
    p = next_prime(demand)
    checks = dict(prime_exists=p is not None,
        entry_count_and_too_empty_unsigned=8*entries <= U32,
        load_products_size_t=p is not None and max(3*p,4*entries,2*entries) <= U64,
        probe_addition_unsigned=p is not None and 2*p-3 <= U32,
        individual_request_span=p is not None and element_bytes*p <= I64)
    return dict(family=name, initial_slot_request=initial,
        unique_entries_upper=entries, no_deletion_or_repeated_insertion_growth=True,
        prime_demand_upper=demand, slots_upper=p, element_bytes=element_bytes,
        wrapper_bytes=48, each_backing_bytes_upper=None if p is None else p*element_bytes,
        checks=checks, fits=all(checks.values()))


def trace_capacity(t):
    require(type(t) is int and t >= 1, 'trace count domain')
    return 16 if t <= 16 else max(16, 3*(t-1)//2)


def cold_capacity(n):
    require(type(n) is int and n >= 0, 'cold vector count domain')
    return 0 if n == 0 else max(4, 2*n)


def arithmetic(c, n):
    """Count-only theorem arithmetic; no claim that an upstream input passed."""
    require(type(c) is int and c >= 1 and type(n) is int and n >= 0,
            'literal C/N domain')
    b, e, t = 2*n+10, n+6, n+5
    k0, k, r0, m, uf = 98+3*c, 99+5*c, 64*c+n+16, 7*c+5*n+20, 7*c+7*n+46
    f, local = trace_capacity(t), cold_capacity(c)
    traversal = 0 if b+1 <= 20 else 8+16*(b+1)
    dense = 8+8*((b+63)//64)
    hashes = [hash_bound('CFI trace pointer index',t,t,8),
              hash_bound('expansion block-to-label map',13,e,16),
              hash_bound('empty stack-partition map',13,0,16),
              hash_bound('each empty CFG copy map',10,0,8)]
    checks = dict(
        CFI_trace_ID_and_length_unsigned=t <= U32,
        CFI_vector_growth_intermediate_unsigned=3*max(0,t-1) <= U32,
        CFI_vector_capacity_31_bits=f <= I32,
        CFI_vector_individual_span=8+144*f <= I64,
        expansion_block_index_signed=e <= I32,
        expansion_head_end_capacity_31_bits=e <= I32,
        expansion_head_end_individual_span=8+16*e <= I64,
        maybe_local_decls_growth_unsigned=3*max(0,c-1) <= U32,
        maybe_local_decls_capacity_31_bits=local <= I32,
        maybe_local_decls_individual_span=8+8*local <= I64,
        jump_register_extent_signed=k <= I32,
        jump_register_array_individual_span=4*k <= I64,
        jump_signed_usage_counter_magnitude=r0+1 <= I32,
        jump_signed_deleted_instruction_count=m <= I32,
        CFG_block_and_stack_counters_signed=b+1 <= I32,
        CFG_traversal_capacity_31_bits=b+1 <= I32,
        CFG_traversal_individual_spans=max(8*b,traversal,4*b) <= I64,
        CFG_dense_bitmap_rounding_unsigned=b+63 <= U32,
        CFG_dense_bitmap_request_unsigned=dense <= U32,
        dominance_signed_and_unsigned_intermediates=4*b <= I32,
        dominance_individual_spans=max(4*b,4*(b+1),8*b,16*(b+1)) <= I64,
        inherited_UID_hash_input_signed=uf <= I32)
    for h in hashes:
        prefix = h['family'].replace(' ', '_').replace('-', '_')
        checks.update({prefix+'_'+key: value for key,value in h['checks'].items()})
    return dict(scope='Named ordinary CFI/expansion/jump/CFG traversal and dominance containers',
        source_input=dict(output_calls=c,null_statements=n),
        extents=dict(B=b,expansion_block_slots=e,T=t,K0=k0,K=k,R0=r0,M=m,Uf=uf),
        CFI=dict(trace_element_bytes=144,trace_initial_capacity=16,
            trace_length_upper=t,trace_capacity_upper=f,
            trace_each_backing_bytes_upper=8+144*f,
            index_created_after_last_vector_growth=True,
            worklist_length_upper=1,worklist_capacity=4,worklist_backing_bytes=40,
            queued_saves_length_upper=1,queued_saves_capacity=4,
            queued_save_element_bytes=24,queued_saves_backing_bytes=104,
            regs_saved_in_regs_entries=0,regs_saved_in_regs_backing_requests=0,
            ordinary_label_requests_upper=5,ordinary_label_bytes_each_including_NUL=8,
            ordinary_label_stack_buffer_bytes=20,FDE_label_requests_upper=2,
            FDE_label_bytes_each_including_NUL_upper=26,FDE_label_stack_buffer_bytes=40),
        hashes=hashes,
        expansion=dict(head_end_slots_upper=e,head_end_element_bytes=16,
            head_end_backing_bytes_upper=8+16*e,
            no_backing_growth_during_selected_body_expansion=True,
            released_before_exit_block_construction=True,
            maybe_local_decls_length_upper=c,maybe_local_decls_capacity_upper=local,
            maybe_local_decls_each_backing_bytes_upper=8+8*local,
            selected_stack_variable_count=0,stack_partition_arrays=0,CFG_copy_maps=3),
        jump=dict(register_array_slots_upper=k,register_array_element_bytes=4,
            register_array_bytes_upper=4*k,
            signed_usage_magnitude_upper=r0+1,deleted_instruction_count_upper=m,
            count_array_reinitialized_per_invocation=True,
            DF_death_and_unused_notes_traversed=False,
            wide_split_adds_counted_REG_occurrences=False,
            no_debug_replacement_array=True,later_debug_set_vars_heap_requests=0),
        CFG=dict(unreachable_worklist_entries_upper=b,
            unreachable_worklist_bytes_upper=8*b,
            traversal_stack_length_upper=b+1,traversal_inline_slots=20,
            traversal_iterator_element_bytes=16,traversal_heap_request_bytes_upper=traversal,
            traversal_exact_reserve_and_quick_push=True,dense_bitmap_bytes_upper=dense,
            preorder_temporary_block_flag_bit=15,
            loop_reverse_order_array_bytes_upper=4*b,
            empty_loop_candidate_vector_capacity=1,empty_loop_candidate_vector_bytes=16,
            root_loop_iterator_length_upper=1,root_loop_iterator_inline_capacity=16,
            root_loop_iterator_heap_requests=0),
        dominance=dict(unsigned_arrays=9,unsigned_array_bytes_each_upper=4*b,
            order_array_bytes_upper=4*(b+1),pointer_map_bytes_upper=8*b,
            iterator_stack_bytes_upper=16*(b+1),fast_DFS_endpoint_upper=2*b,
            arithmetic_intermediate_upper=4*b,ET_pool_backing_recharged=False),
        local_representation_checks=checks,
        conditional_named_ordinary_container_capacity_established=all(checks.values()),
        failed_predicates=[key for key,value in checks.items() if not value],
        new_GGC_events=0,new_scalar_registrations=0,new_array_registrations=0,
        new_shared_bitmap_or_ET_pool_blocks=0,aggregate_ordinary_bytes=None,
        lifetime_ordinary_request_total=None,aggregate_RAM_gate=False,
        total_GGC_events=None,complete_all_ordinary_helper_lifetimes_closed=False,
        complete_native_capacity=False,complete_collector_lifetime_closed=False,
        whole_literal_pipeline_capacity_established=False,production_admission_changed=False,
        source_reachability_argument_is_handwritten=True,independent_review_status='pending',
        native_tool_executions=0,predecessor_Context_or_evaluator_calls=0,
        aggregate_or_corpus_executions=0)


def attach(raw, accepted, pools, source_path, launch):
    """Check the named fields of already accepted actual-source owners.

    The published check supplies complete pinned predecessor JSON files. This
    is no replacement for their evaluators and does not establish their guards
    for another source. Pure arithmetic remains separately callable.
    """
    counts = recognize(raw)
    ident = identity(raw)
    core = accepted['core_result']
    mem = accepted['selected_native_MEM_counter_lifetime']
    for row in (accepted,core,mem,pools):
        require(row['source']==ident and row['source_counts']==counts,
                'same physical Main identity and complete counts')
    for row in (accepted,core):
        require(row['source_path']==source_path, 'accepted Main source path')
        require(row['launch']==launch, 'accepted selected launch')
        require(row['actual_shared_inputs']==accepted['actual_shared_inputs'],
                'accepted shared configuration inputs')
        require(row['complete_path_bound']==accepted['complete_path_bound'],
                'accepted complete path bound')
    require(launch['native_options']==['-gnatx','-Wno-free-nonheap-object','-fsplit-wide-types']
            and launch['producer_options']==['-Wno-free-nonheap-object'],
            'selected O0 no-debug launch options')
    for name in ('datarep_Main','phase1_Main','phase2_Main'):
        require(launch[name]==launch['native_Main'], 'same launched physical Main path')
    require(accepted['evaluated_predicates_pass'] is True and
            accepted['conditional_arithmetic_pass'] is True and
            all(type(v) is bool and v for v in accepted['conditions'].values()),
            'accepted inherited guards')
    c,n=counts['output_calls'],counts['null_statements']
    result=arithmetic(c,n)
    x=result['extents']; shape=core['RTL_shape']; rtl=mem['RTL']; p=pools['extents']
    for key,value in dict(block_slots_upper=x['B'],edges_upper=x['B']-1,
            CFI_traces_upper=x['T'],CFI_rows_upper=2*n+10,
            first_unused_pseudo_number_upper=x['K'],first_unused_UID_upper=x['Uf'],
            IRA_entry_chain=x['M']).items():
        require(shape[key]==value, 'accepted RTL shape owner '+key)
    for key,value in dict(pre_split_first_unused_pseudo_upper=x['K0'],
            final_first_unused_pseudo_upper=x['K'],final_first_unused_UID_upper=x['Uf']).items():
        require(rtl[key]==value,'accepted MEM/RTL owner '+key)
    for key in ('B','K','M','Uf'):
        require(p[key]==x[key], 'accepted shared bitmap/ET extent '+key)
    require(pools['dominance']['live_nodes_combined_upper']==2*x['B'] and
            pools['dominance']['live_occurrences_combined_upper']==4*x['B'] and
            pools['dominance']['shared_incoming_and_retained_pool_state_closed'] is True,
            'accepted shared ET owner')
    require(pools['new_GGC_events']==0 and mem['new_mem_attrs_events']==0,
            'disjoint GGC and ordinary owners')
    ec=mem['emission_counter_endpoints']
    require(ec['CFI_label_counter_initial_value']==0 and
            ec['CFI_label_counter_at_exit_upper']==5 and
            ec['CFI_label_signed_temporary_maximum']==4 and
            ec['Main_label_alignment_span_upper']==x['Uf'],
            'accepted CFI and emission label owners')
    result.update(source=ident,source_counts=counts,source_path=source_path,
        launch=copy.deepcopy(launch),actual_shared_inputs=copy.deepcopy(accepted['actual_shared_inputs']),
        complete_path_bound=accepted['complete_path_bound'],same_source_accepted_owners_verified=True,
        retained_owners=dict(shared_bitmap_and_ET=pools['dominance'],
            initial_CF_CFG_GGC=core['native_initial_CF_CFG_lifetime']['additional_GGC_request_events_upper'],
            emission_labels=ec,CFI_rows_and_vectors='existing separate GGC owner; no recharge',
            stack_variable_bitmap='existing shared bitmap/pool owner; no recharge'),
        inherited_guard_count=len(accepted['conditions']))
    return result


def main():
    parser=argparse.ArgumentParser()
    parser.add_argument('--gcc-source', required=True)
    args=parser.parse_args()
    verified=verify_inputs(args.gcc_source)
    accepted=read(EVIDENCE/'retained-literal-mem-ssa-attachment-20261019/result.json')
    pools=read(EVIDENCE/'retained-literal-shared-bitmap-pools-20261019/result.json')
    result=attach((REPO/'samples/hello_world.adb').read_bytes(),accepted,pools,
                  accepted['source_path'],accepted['launch'])
    result['input_verification']=verified
    print(json.dumps(result,indent=2))


if __name__=='__main__':
    main()
