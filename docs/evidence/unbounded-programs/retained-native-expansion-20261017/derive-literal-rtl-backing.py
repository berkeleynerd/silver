#!/usr/bin/env python3
"""Compose selected literal-output RTL backing; offline source/hash arithmetic.

The companion source argument establishes reachability and object counts.
This is neither a GCC implementation nor a Silver admission predicate.
"""
import argparse
import hashlib
import json
from pathlib import Path
import runpy

HERE = Path(__file__).resolve().parent
I32, U32, U64 = 2**31-1, 2**32-1, 2**64-1
sha = lambda raw: hashlib.sha256(raw).hexdigest()
power_two = lambda n: 1 << (n-1).bit_length()
sbitmap = lambda n: 8+8*((n+63)//64)
pool_blocks = lambda count, size: (count+(65536-8)//size-1)//((65536-8)//size)


def backing(c, n):
    assert c >= 1 and n >= 0
    k0, k = 98+3*c, 99+5*c
    b, e = 2*n+10, 2*n+9
    m, u = 7*c+5*n+20, 7*c+5*n+22
    reg_entries = 3*k//2+1
    recog_entries = max(3*(u-1)//2, u)
    alias_raw = [8+8*(k-92), 8+8*k]
    alias_rounded = [power_two(v) for v in alias_raw]
    alias_capacity = [(v-8)//8 for v in alias_rounded]
    split_elements = min(c, (k0+127)//128)
    h, call_refs = 92, 186
    artificial_collections = 2*b+2*h+3
    artificial_refs = h*artificial_collections
    instruction_refs = 2*(10+call_refs)*c+(h+1)*call_refs*c+32
    ref_order = artificial_refs+instruction_refs
    final_u = 7*c+7*n+46
    reg_slots = k+k//4
    insn_slots = final_u+1+(final_u+1)//4
    block_slots = b+1+(b+1)//4
    return {
        'interface': {'calls': c, 'nulls': n, 'pre_split_register_extent': k0,
                      'register_extent_upper': k, 'block_slots_upper': b,
                      'edges_upper': e, 'LRA_real_instructions_upper': m,
                      'LRA_first_unused_UID_upper': u,
                      'selected_option': '-fsplit-wide-types'},
        'split_direct_helpers': {
            'bitmap_headers_upper': 5, 'each_bitmap_header_bytes': 32,
            'populated_bitmaps_upper': 2,
            'each_populated_bitmap_elements_upper': split_elements,
            'each_bitmap_element_bytes': 40,
            'copy_graph_pointer_vector_raw_bytes': 8+8*k0,
            'copy_graph_edges': 0, 'sub_block_bitmap_bytes_upper': sbitmap(n+6),
            'change_log_entries_upper': 150, 'change_log_each_bytes': 40,
            'change_log_new_request_bytes_upper': 6000,
            'shared_obstack_and_change_log_incoming_extent_required': True},
        'alias_direct_helpers': {
            'iterations_upper': 10, 'unique_id_peak': 1,
            'selected_fresh_RTX_requests': 0,
            'GGC_pointer_vector_requests_upper': 2,
            'GGC_pointer_vector_raw_requests_upper': alias_raw,
            'GGC_pointer_vector_rounded_requests_upper': alias_rounded,
            'new_GGC_pointer_vector_capacities_upper': alias_capacity,
            'known_equiv_bitmap_bytes_upper': sbitmap(k-92),
            'seen_bitmap_bytes_upper': sbitmap(k),
            'new_base_pointer_array_bytes_upper': 8*k,
            'reverse_postorder_array_bytes_upper': 4*b,
            'old_reg_base_value_incoming_capacity_required': True,
            'CFG_traversal_scratch_included': False},
        'LRA_register_and_recognition_backing': {
            'register_record_entries_upper': reg_entries,
            'each_register_record_bytes': 144,
            'register_record_request_bytes_upper': 144*reg_entries,
            'register_record_array_requests': 1,
            'last_reg_value_upper': reg_entries,
            'recognition_pointer_entries_upper': recog_entries,
            'recognition_pointer_request_bytes_upper': 8*recog_entries,
            'live_recognition_records_upper': m,
            'each_recognition_record_bytes': 80,
            'recognition_pool_blocks_upper': pool_blocks(m,80),
            'static_recognition_records_upper': 4,
            'each_static_recognition_request_bytes_upper': 88,
            'live_operand_location_arrays_upper': 7*c,
            'each_operand_location_array_bytes': 16,
            'duplication_arrays': 0,
            'live_call_hard_argument_arrays_upper': c,
            'each_call_hard_argument_array_bytes': 12,
            'implicit_call_array_stack_entries_used': 3,
            'implicit_call_array_stack_entries_available': 92,
            'static_operand_alternative_arrays_upper': 2,
            'each_operand_alternative_array_bytes_upper': 1680,
            'live_instruction_register_records_upper': 10*c,
            'each_instruction_register_record_bytes': 24,
            'instruction_register_pool_blocks_upper': pool_blocks(10*c,24),
            'static_nonoperand_register_records': 0,
            'live_register_instruction_bitmap_elements_upper': 10*c,
            'referenced_pseudo_nrefs_upper': 2,
            'constraint_stack_request_bytes_upper': 8+8*u,
            'constraint_stack_bitmap_bytes_upper': sbitmap(u),
            'constraint_stack_growth_requests_after_initialization': 0,
            'all_LRA_helpers_and_shared_bitmap_backing_included': False},
        'DF_selected_reference_and_solver_transfer': {
            'complete_scan_generations': 2, 'analyses_upper': 4,
            'NOTE_analyses_upper': 3,
            'canonical_hard_register_count': h,
            'call_references_per_collection_upper': call_refs,
            'all_call_refreshes_upper': h+1,
            'artificial_collections_upper': artificial_collections,
            'artificial_reference_creations_upper': artificial_refs,
            'instruction_reference_creations_upper': instruction_refs,
            'multiword_hard_register_descriptors': 0,
            'ref_order_final_upper': ref_order,
            'optional_reference_tables_enabled': False,
            'LR_solver_visits_upper_per_analysis': b+k*e,
            'DF_REG_DEAD_UNUSED_note_requests_upper': 3*(10+call_refs)*c,
            'LRA_REG_DEAD_UNUSED_note_requests_upper': 12*c,
            'selected_REG_DEAD_UNUSED_note_requests_upper': 600*c,
            'each_note_EXPR_LIST_raw_bytes': 24,
            'note_REG_payloads_copied': False,
            'register_info_pointer_array_entries_upper': reg_slots,
            'each_register_info_pointer_array_bytes_upper': 8*reg_slots,
            'each_register_begin_count_array_bytes_upper': 4*reg_slots,
            'instruction_info_pointer_array_entries_upper': insn_slots,
            'instruction_info_pointer_array_bytes_upper': 8*insn_slots,
            'scan_and_LR_block_array_entries_upper': block_slots,
            'scan_block_array_bytes_upper': 16*block_slots,
            'LR_block_array_bytes_upper': 128*block_slots,
            'register_info_pool_objects_upper_per_generation': 3*k,
            'register_info_pool_blocks_upper_per_generation': pool_blocks(3*k,16),
            'all_shared_pool_bitmap_and_vector_backing_included': False},
        'local_representation_checks': {
            'split_register_vector_31_bit_capacity': k0 <= I32,
            'split_register_vector_size_product': 8+8*k0 <= U64,
            'split_sub_block_bitmap_unsigned_rounding': n+6+63 <= U32,
            'alias_signed_register_loops': k <= I32,
            'alias_bitmap_unsigned_rounding': k+63 <= U32,
            'alias_GGC_vector_rounded_capacity_31_bit': max(alias_capacity) <= I32,
            'alias_GGC_vector_request_size': max(alias_rounded) <= U64,
            'LRA_register_tripling_signed_intermediate': 3*k <= I32,
            'LRA_register_entries_and_value_counter_signed': reg_entries <= I32,
            'LRA_register_record_byte_product': 144*reg_entries <= U64,
            'LRA_recognition_tripling_unsigned_intermediate': 3*(u-1) <= U32,
            'LRA_recognition_stored_capacity_signed': recog_entries <= I32,
            'LRA_instruction_UID_signed': u <= I32,
            'LRA_constraint_stack_31_bit_capacity': u <= I32,
            'LRA_constraint_bitmap_unsigned_rounding': u+63 <= U32,
            'LRA_recognition_array_byte_product': 8*recog_entries <= U64,
            'DF_reference_order_signed_comparator': ref_order <= I32,
            'DF_LR_solver_signed_counters': b+k*e <= I32,
            'DF_final_instruction_UID_signed': final_u <= I32,
            'DF_register_array_unsigned_quarter_growth': reg_slots <= U32,
            'DF_instruction_array_unsigned_quarter_growth': insn_slots <= U32,
            'DF_block_array_signed_quarter_growth': block_slots <= I32,
            'DF_LR_block_byte_product_unsigned_intermediate': 128*block_slots <= U32,
            'DF_selected_array_byte_products': max(8*reg_slots,8*insn_slots,128*block_slots) <= U64},
        'all_RTL_DF_IRA_LRA_lifetime_helpers_accounted': False,
        'whole_native_pipeline_capacity_established': False,
        'aggregate_RAM_or_address_space_gate': False,
        'production_admission_changed': False}


def focused_checks():
    one = backing(1,0)
    lra = one['LRA_register_and_recognition_backing']
    assert lra['register_record_entries_upper'] == 157
    assert lra['register_record_request_bytes_upper'] == 22608
    assert lra['last_reg_value_upper'] == 157
    assert lra['recognition_pointer_entries_upper'] == 42
    assert lra['instruction_register_pool_blocks_upper'] == 1
    assert one['alias_direct_helpers']['GGC_pointer_vector_raw_requests_upper'] == [104,840]
    assert one['alias_direct_helpers']['GGC_pointer_vector_rounded_requests_upper'] == [128,1024]
    # GC rounding can cross the stored capacity's unsigned31 boundary even
    # though an unsigned32 temporary can represent the result.
    assert backing((I32-99)//5,0)['local_representation_checks']['alias_GGC_vector_rounded_capacity_31_bit']
    assert not backing((I32-99)//5+1,0)['local_representation_checks']['alias_GGC_vector_rounded_capacity_31_bit']
    df = one['DF_selected_reference_and_solver_transfer']
    assert df['ref_order_final_upper'] == 36766
    assert df['selected_REG_DEAD_UNUSED_note_requests_upper'] == 600
    c = (I32-19076)//17690
    assert backing(c,0)['local_representation_checks']['DF_reference_order_signed_comparator']
    assert not backing(c+1,0)['local_representation_checks']['DF_reference_order_signed_comparator']
    # Test the intermediate multiplication, not only its smaller quotient.
    c = (I32//3-99)//5
    assert backing(c,0)['local_representation_checks']['LRA_register_tripling_signed_intermediate']
    assert not backing(c+1,0)['local_representation_checks']['LRA_register_tripling_signed_intermediate']
    assert backing(c+1,0)['local_representation_checks']['LRA_register_entries_and_value_counter_signed']
    n = (U32//3-7-21)//5
    assert backing(1,n)['local_representation_checks']['LRA_recognition_tripling_unsigned_intermediate']
    assert not backing(1,n+1)['local_representation_checks']['LRA_recognition_tripling_unsigned_intermediate']
    for size in (24,80):
        slots = (65536-8)//size
        assert pool_blocks(slots,size) == 1 and pool_blocks(slots+1,size) == 2
    # df_grow_bb_info multiplies two unsigned32 fields before XRESIZEVEC.
    lo, hi = 0, U32
    while lo+1 < hi:
        mid = (lo+hi)//2
        if backing(1,mid)['local_representation_checks']['DF_LR_block_byte_product_unsigned_intermediate']:
            lo = mid
        else:
            hi = mid
    assert backing(1,lo)['local_representation_checks']['DF_LR_block_byte_product_unsigned_intermediate']
    assert not backing(1,hi)['local_representation_checks']['DF_LR_block_byte_product_unsigned_intermediate']
    for c in (1,2,10,100,5000):
        r = backing(c,0)
        assert all(r['local_representation_checks'].values())
        assert r['LRA_register_and_recognition_backing']['live_instruction_register_records_upper'] == 10*c
    return ['one-call alias and LRA composition',
            'LRA register signed multiplication boundary',
            'recognition unsigned multiplication boundary',
            'typed-pool block boundaries', '5000-call composition',
            'DF reference order signed comparator boundary',
            'DF block byte-product unsigned intermediate boundary',
            'rounded GC vector 31-bit stored-capacity boundary']


def main():
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--source',type=Path,required=True)
    p.add_argument('--gcc-root',type=Path,required=True)
    p.add_argument('--plugin-include',type=Path,required=True)
    p.add_argument('--output',type=Path,required=True)
    a = p.parse_args()
    identity = json.loads((HERE/'literal-rtl-backing-inputs.json').read_bytes())
    roots = {'gcc':a.gcc_root, 'plugin':a.plugin_include, 'packet':HERE}
    for row in identity['files']:
        raw = (roots[row['root']]/row['path']).read_bytes()
        assert len(raw)==row['bytes'] and sha(raw)==row['sha256'], row['path']
    predecessor = json.loads((HERE/'literal-rtl-backing-predecessor.json').read_bytes())
    assert predecessor['selected_added_option'] == '-fsplit-wide-types'
    assert predecessor['source_selected_LRA_passes']['constraints'] == 2
    assert predecessor['source_selected_LRA_passes']['live_range_construction'] == 1
    old = predecessor['literal_predecessor_arithmetic']
    joined = backing(old['calls'],old['nulls'])['interface']
    assert old['first_unused_pseudo_number_upper'] == joined['register_extent_upper']
    assert old['postreload_chain']+1 == joined['LRA_first_unused_UID_upper']
    source_counts = runpy.run_path(str(HERE/'derive-literal-output.py'))['source_counts']
    counts = source_counts(a.source.read_bytes())
    result = {'scope':'Conditional split, alias, direct LRA and DF backing for literal output',
              'source_files_and_predecessor_inputs_verified':len(identity['files']),
              'source_counts':counts,
              'components':backing(counts['output_calls'],counts['null_statements']),
              'focused_checks':focused_checks(),
              'native_tool_executions':0,
              'arithmetic_requires_companion_manual_source_argument':True}
    a.output.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({'inputs_verified':len(identity['files']),
                      'focused_checks':len(result['focused_checks']),
                      'whole_native_pipeline_capacity_established':False}))


if __name__ == '__main__':
    main()
