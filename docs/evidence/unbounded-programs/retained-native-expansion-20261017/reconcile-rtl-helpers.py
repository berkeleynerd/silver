#!/usr/bin/env python3
"""Reconcile null expansion/CFG and ranger helper storage without native runs."""
import argparse
import hashlib
import io
import json
from pathlib import Path
import re
import tarfile

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--gcc-root', required=True, type=Path)
parser.add_argument('--output', required=True, type=Path)
args = parser.parse_args()
root = Path(__file__).resolve().parent
identity = json.loads((root / 'rtl-helpers-source-identity.json').read_text())
digest = lambda raw: hashlib.sha256(raw).hexdigest()
sources = {}
for row in identity['files']:
    raw = (args.gcc_root / row['path']).read_bytes()
    assert len(raw) == row['bytes'] and digest(raw) == row['sha256'], row['path']
    sources[row['path']] = raw.decode()
row = identity['reused_identity']
raw = (root / row['path']).read_bytes()
assert len(raw) == row['bytes'] and digest(raw) == row['sha256']
retained = json.loads(raw)
row = retained['headers_archive']
raw = (root / row['path']).read_bytes()
assert len(raw) == row['bytes'] and digest(raw) == row['sha256']
headers = {}
with tarfile.open(fileobj=io.BytesIO(raw), mode='r:gz') as archive:
    for row in retained['selected_headers']:
        raw = archive.extractfile(row['path']).read()
        assert len(raw) == row['bytes'] and digest(raw) == row['sha256']
        headers[row['path']] = raw.decode()
assert '#define MAX_BITSIZE_MODE_ANY_INT (64*BITS_PER_UNIT)' in headers['insn-modes.h']

anchors = {
    'gcc/cfgexpand.cc': ['var_ret_seq = expand_used_vars (forced_stack_vars);',
                         'head_end_for_bb.create (last_basic_block_for_fn (fun));',
                         'lab_rtx_for_bb = new hash_map<basic_block, rtx_code_label *>;'],
    'gcc/tree-outof-ssa.cc': ['nodes (30), edge_list (20), edge_locus (10), visited (map->num_partitions),',
                            'stack (30), map (map), const_dests (20), const_copies (20), copy_locus (10)'],
    'gcc/tree-ssa-coalesce.cc': ['partition tentative = partition_new (parts);',
                               'if (num_var_partitions (map) < 1)',
                               'hash_table<ssa_name_var_hash> ssa_name_hash (10);'],
    'libiberty/partition.c': ['(num_elements - 1) * sizeof (struct partition_elem)'],
    'gcc/cfg.cc': ['vec_safe_push (e->src->succs, e);', 'vec_safe_push (dest->preds, e);'],
    'gcc/cfghooks.cc': ['a->succs = b->succs;', 'b->preds = b->succs = NULL;'],
    'gcc/cfgrtl.cc': ['bb->il.x.rtl = ggc_cleared_alloc<rtl_bb_info> ();',
                     'last_basic_block_for_fn (cfun) + 1);'],
    'gcc/gimple-range-cache.cc': ['m_ssa_ranges.safe_grow_cleared (num_ssa_names);',
                                'm_update_list.safe_grow_cleared (last_basic_block_for_fn (cfun) + 64);',
                                'm_current_time = 1;'],
    'gcc/gimple-range-gori.cc': ['m_bool_zero = range_false ();', 'm_bool_one = range_true ();',
                               'm_outgoing[bb->index] = BITMAP_ALLOC (&m_bitmaps);',
                               'm_incoming[bb->index] = BITMAP_ALLOC (&m_bitmaps);'],
    'gcc/gimple-range-gori.h': ['int_range<2> m_bool_zero;', 'int_range<2> m_bool_one;'],
    'gcc/value-range-storage.h': ['vrange_allocator (bool gc = false);'],
    'gcc/value-range-storage.cc': ['m_alloc = new vrange_obstack_alloc;'],
    'gcc/value-relation.cc': ['m_lhs_equiv_set_p = BITMAP_ALLOC (&m_bitmaps);'],
    'gcc/vec.cc': ['else if (alloc < 16)', 'alloc = alloc * 2;'],
}
for path, strings in anchors.items():
    for string in strings:
        assert string in sources[path], (path, string)

align8 = lambda n: (n + 7) // 8 * 8
u64 = (1 << 64) - 1
partition_element = 8 + 4 + 4
partition_header = align8(4) + partition_element
partition_requests = {
    str(n): (partition_header + ((n - 1) & u64) * partition_element) & u64
    for n in (0, 2)
}
assert partition_requests == {'0': 8, '2': 40}
primes = [int(x) for x in re.findall(r'\{\s*(\d+), 0x', sources['gcc/hash-table.cc'])]
prime = lambda n: min(p for p in primes if p >= n)
assert (prime(10), prime(13), prime(40)) == (13, 13, 61)

# Ordinary vectors have no GGC rounding. Initial safe_grow has minimum4;
# explicit create/reserve_exact uses its positive requested count exactly.
heap_vec = lambda n, size, exact=False: 0 if not n else 8 + (n if exact else max(n, 4)) * size
elim = [(30, 4), (20, 4), (10, 4), (30, 4), (20, 4), (20, 8), (10, 4)]
elim_bytes = [heap_vec(n, size, True) for n, size in elim]
assert elim_bytes == [128, 88, 48, 128, 88, 168, 48]
ranger_vecs = {
    'statement_list': heap_vec(2, 8),
    'block_range_cache': heap_vec(2, 8),
    'timestamps': heap_vec(2, 4),
    'GORI_definition_chain': heap_vec(2, 24),
    'GORI_outgoing': heap_vec(6, 8),
    'GORI_incoming': heap_vec(6, 8),
    'infer_exit': heap_vec(7, 24),
    'infer_nonzero': heap_vec(3, 8),
    'propagation_update': heap_vec(70, 4),
    'optional_equivalence': heap_vec(7, 8),
    'optional_self_equivalence': heap_vec(3, 8),
    'optional_partial_equivalence': heap_vec(3, 24),
    'optional_relations': heap_vec(7, 24),
}
assert max(ranger_vecs.values()) == 288
wide_int_bytes = ((512 + 64) // 64) * 8 + 8
int_range_2_upper = align8(16 + 3) + 8 + 2 * wide_int_bytes + 8 + 4 * wide_int_bytes
assert (wide_int_bytes, int_range_2_upper) == (80, 520)
gori_compute_upper = 32 + 8 + 2 * int_range_2_upper + 120 + 8
assert gori_compute_upper == 1208

incoming_block_objects = 5  # Three ordinary plus ENTRY and EXIT.
new_blocks = 2 + 5
new_edges = 2 + 5
lifetime_block_objects = incoming_block_objects + new_blocks
assert lifetime_block_objects == 12
# One predecessor and successor lineage per ordinary lifetime block,
# ENTRY has only successors; EXIT only predecessors. Ownership transfer
# on merging does not start another lineage. Cold-credit all incoming
# lineages too: this is an upper bound on additional phase allocations.
edge_vector_lineages = 2 * lifetime_block_objects - 2
edge_vector_events = edge_vector_lineages * 3  # minimum capacities4,8,16
assert edge_vector_events == 66
assert 8 + (2 * 10) * 8 == 168  # A grow from capacity<=10, degree<=11.
assert 8 + (2 * 11) * 8 == 184  # Block map grows to length<=12.
ggc_events = {
    'basic_block_objects': new_blocks,
    'edge_objects': new_edges,
    'RTL_block_info': lifetime_block_objects,
    'edge_vector_allocations_upper': edge_vector_events,
    'basic_block_map_growth_upper': new_blocks,
    'variable_expansion_cold_sequence': 1,
}
assert sum(ggc_events.values()) == 100
edge_bits = [int(x) for x in re.findall(r'DEF_EDGE_FLAG\([^,]+,\s*(\d+)\)', sources['gcc/cfg-flags.def'])]
assert max(edge_bits) == 17
assert (1 << 18) < (1 << 31)

result = {
    'scope': identity['scope'],
    'source_files_verified': len(sources),
    'retained_installed_headers_verified': len(headers),
    'premises': {'incoming_GIMPLE_ordinary_blocks_upper': 3, 'SSA_slots': 2,
                 'real_partitions': 0, 'block_index_slots_upper': 12,
                 'lifetime_edges_upper': 11, 'ranger_instances_upper': 4,
                 'scalar_range_queries': 0, 'no_gimple_phi': True,
                 'linear_CFG_except_transient_edge_redirection': True},
    'out_of_SSA': {'partition_raw_bytes_by_count': partition_requests,
                  'variable_map_bytes': 80, 'coalesce_record_bytes': 120,
                  'coalesce_hash_slots': prime(40), 'same_variable_hash_slots': prime(10),
                  'coalesce_obstack_chunk_bytes': 65536,
                  'elimination_vector_raw_bytes': elim_bytes,
                  'zero_partition_simple_bitmap_raw_bytes': 8,
                  'zero_xmalloc_or_xcalloc_actual_bytes': 1,
                  'shared_default_bitmap_fresh_headers_upper': 5,
                  'shared_default_bitmap_fresh_elements': 0},
    'ranger_per_instance': {
        'ordinary_vectors_raw_bytes_upper': ranger_vecs,
        'ordinary_object_bytes_upper': {'gimple_ranger': 456, 'GORI_map': 144,
                                        'GORI_compute': gori_compute_upper,
                                        'infer_manager': 240, 'optional_dom_oracle': 280,
                                        'temporal_cache': 16, 'update_list': 128,
                                        'vrange_allocator': 8, 'vrange_obstack_allocator': 96},
        'vrange_allocator_pairs': 3, 'default_obstack_initial_chunks_upper': 5,
        'default_obstack_chunk_bytes': 4064, 'bitmap_obstack_initial_chunks_upper': 5,
        'bitmap_obstack_chunk_bytes': 65536, 'bitmap_headers_upper': 20,
        'bitmap_elements': 0, 'range_clones': 0, 'GGC_events': 0,
        'Boolean_wide_int_precision': 1, 'Boolean_range_heap_growth': False,
        'temporal_time_final': 1, 'definition_chain_depth_final': 0,
        'temporary_edge_flag_bit': 18,
    },
    'CFG': {'basic_block_bytes': 96, 'edge_bytes': 48, 'RTL_info_bytes': 24,
            'lifetime_block_objects_upper': lifetime_block_objects,
            'edge_vector_lineages_upper': edge_vector_lineages,
            'edge_vector_raw_growth_request_upper': 168,
            'block_map_raw_growth_request_upper': 184,
            'GGC_vector_rounded_bytes_upper': 256,
            'edge_vector_growth_events_per_lineage_upper': 3},
    'other_ordinary_storage': {
        'stack_partition_hash': {'wrapper_bytes': 48, 'backbone_bytes': 13 * 16},
        'label_to_RTL_hash': {'wrapper_bytes': 48, 'backbone_bytes': 13 * 16},
        'head_end_vector_raw_bytes_upper': heap_vec(6, 16, True),
        'CFG_copy_maps': {'count': 3, 'wrapper_bytes_each': 48, 'backbone_bytes_each': 13 * 8},
        'jump_register_use_array_raw_bytes': 98 * 4,
        'stack_variable_bitmap_initial_chunk_bytes': 65536,
    },
    'additional_GGC_event_bounds': ggc_events,
    'additional_GGC_events_total': sum(ggc_events.values()),
    'phase_boundary_overallowance': 'All22 edge-vector lineages charged cold; some backing predates expansion.',
    'unclosed_inputs': ['Remaining pass-manager and non-DF shared helper state',
                        'Main translation/GIMPLE/IPA outside these ranger instances',
                        'Metadata', 'Unit emission', 'Shared GGC page/finalizer composition'],
    'whole_native_capacity_established': False,
}
args.output.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps({'source_files': len(sources), 'headers': len(headers),
                  'additional_GGC_events': sum(ggc_events.values()),
                  'ranger_GGC_events': 0, 'whole_native_capacity_established': False}))
