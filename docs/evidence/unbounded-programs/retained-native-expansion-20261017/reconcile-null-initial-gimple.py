#!/usr/bin/env python3
"""Reconcile the selected null initial-GIMPLE/CFG/SSA allocation join offline."""
import argparse
import hashlib
import json
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--gcc-root', type=Path, required=True)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parent
identity = json.loads((root / 'null-initial-gimple-source-identity.json').read_text())
sources = {}
for row in identity['files']:
    raw = (args.gcc_root / row['path']).read_bytes()
    assert len(raw) == row['bytes']
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']
    sources[row['path']] = raw.decode()
for row in identity['reused_results']:
    raw = (root / row['path']).read_bytes()
    assert len(raw) == row['bytes']
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']

anchors = {
    'gcc/gimplify.cc': ['init_tree_ssa (cfun);', 'gimplify_ctxp->bind_expr_stack.reserve (8);',
                        'c = XNEW (struct gimplify_ctx);'],
    'gcc/gimple-low.cc': ['data.return_statements.create (8);'],
    'gcc/tree-eh.cc': ['finally_tree = new hash_table<finally_tree_hasher> (31);',
                       'eh_region_may_contain_throw_map = BITMAP_ALLOC (NULL);'],
    'gcc/tree-ssa.cc': ['fn->gimple_df = ggc_cleared_alloc<gimple_df> ();',
                        'hash_table<ssa_name_hasher>::create_ggc (20);'],
    'gcc/tree-ssanames.cc': ['vec_alloc (SSANAMES (fn), 50);'],
    'gcc/tree-ssa-operands.cc': ['get_identifier (".MEM"),',
                                '#define OP_SIZE_1\t(1024 - sizeof (void *))',
                                'auto_vec<tree *, 16> build_uses;'],
    'gcc/cfg.cc': ['ggc_cleared_alloc<control_flow_graph> ();',
                   'e = ggc_cleared_alloc<edge_def> ();',
                   'vec_safe_push (e->src->succs, e);',
                   'vec_safe_push (dest->preds, e);'],
    'gcc/cfghooks.cc': ['a->succs = b->succs;', 'b->preds = b->succs = NULL;'],
    'gcc/tree-cfg.cc': ['initial_cfg_capacity = 20;',
                        'hash_map<int_hash <unsigned, -1U, -2U>, discrim_entry> map (13);',
                        'edge_to_cases = new hash_map<edge, tree>;',
                        'touched_switch_bbs = BITMAP_ALLOC (NULL);',
                        'loop_optimizer_init (AVOID_CFG_MODIFICATIONS);'],
    'gcc/tree-cfgcleanup.cc': ['cfgcleanup_altered_bbs = BITMAP_ALLOC (NULL);',
                               'auto_sbitmap visited (last_basic_block_for_fn (cfun));'],
    'gcc/cfgloop.cc': ['loops = ggc_cleared_alloc<struct loops> ();',
                       'init_loops_structure (cfun, loops, 1);'],
    'gcc/tree-into-ssa.cc': ['bitmap_obstack_initialize (&update_ssa_obstack);',
                            'block_defs_stack.create (10);',
                            'to_remove = BITMAP_ALLOC (NULL);',
                            'if (bitmap_empty_p (phis))',
                            'dfs = XNEWVEC (bitmap_head, last_basic_block_for_fn (fun));'],
    'gcc/cfganal.cc': ['phi_insertion_points = BITMAP_ALLOC (NULL);',
                       'auto_vec<int, 64> work_set (n_basic_blocks_for_fn (cfun));'],
    'gcc/bitmap.cc': ['map = XOBNEW (&bit_obstack->obstack, bitmap_head);',
                      'bit_obstack = &bitmap_default_obstack;'],
}
for path, fragments in anchors.items():
    for fragment in fragments:
        assert fragment in sources[path], (path, fragment)

def align8(n):
    return (n+7)//8*8

# Conservative LP64 source layouts, charging each named bitfield separately.
pt_solution = align8(11*4)+8
ssa_operands = 8+4+4+8+8
gimple_df = 7*8 + 2*pt_solution + 4*4 + ssa_operands
gimplify_context = 9*8+4+7*4
assert (pt_solution, ssa_operands, gimple_df, gimplify_context) == (56, 32, 216, 104)
assert gimple_df <= 256 and gimplify_context <= 128

# Requests are before collector rounding, each charged independently.
ggc = [
    ('initial_and_CF_tuples', 6, 80),
    ('CF_return_LABEL_DECL', 1, 256),
    ('gimple_df', 1, 256),
    ('default_defs_hash_control', 1, 128),
    ('default_defs_hash_backing_31_pointers', 1, 248),
    ('SSA_names_50_pointers', 1, 512),
    ('memory_VAR_DECL', 1, 312),
    ('memory_identifier', 1, 40),
    ('memory_identifier_characters', 1, 5),
    ('default_memory_SSA_NAME', 1, 88),
    ('detached_default_definition_NOP', 1, 64),
    ('operand_use_slab', 1, 1024),
    ('CFG_control', 1, 128),
    ('CFG_blocks_including_entry_exit', 5, 128),
    ('block_and_label_map_20_pointers_each', 2, 256),
    ('CFG_edges', 4, 64),
    ('edge_predecessor_successor_vectors', 8, 64),
    ('loops_control', 1, 32),
    ('root_loop', 1, 1024),
    ('root_exit_sentinel', 1, 32),
    ('root_loop_vector', 1, 16),
]
assert sum(n for _, n, _ in ggc) == 41
assert 4*64+80+72 == 408
assert 8+50*8 == 408 and 8+20*8 == 168 and 8+4*8 == 40
assert 1*4 < 31*3 and 9*4 < 13*3  # no default-def/discriminator growth
prior = json.loads((root / 'native-null-unit-symbols.json').read_text())
assert prior['updated_selected_known_GGC_subtotal'] == 40031

result = {
    'scope': identity['scope'],
    'gcc_commit': identity['gcc_commit'],
    'complete_sources_verified': len(sources),
    'reused_results_verified': len(identity['reused_results']),
    'incoming_shape': {'ordinary_blocks': 3, 'blocks_including_entry_exit': 5,
                       'edges': 4, 'CF_statements': 5, 'label_UIDs': 2,
                       'SSA_live_statements_maximum': 3, 'real_loops': 0},
    'GGC_requests': [{'object': obj, 'events': n, 'individual_raw_bytes_at_most': b}
                     for obj, n, b in ggc],
    'new_GGC_events': 41,
    'updated_selected_known_GGC_subtotal': 40072,
    'SSA': {'memory_declarations': 1, 'default_names': 1, 'NOPs': 1,
            'persistent_use_entries': 1, 'PHIs': 0, 'name_vector_length': 2},
    'shared_identifier_additions_after_prefix_total': 5,
    'identifier_table_slot_ceiling_unchanged': 65536,
    'ordinary_direct_request_examples': {
        'gimplify_context_bytes_at_most': 128, 'bind_stack_bytes': 72,
        'return_records_bytes': 136, 'EH_hash_backing_bytes': 248,
        'EH_record_bytes_each': 16, 'EH_record_count': 2,
        'label_arrays_count': 2, 'label_array_bytes_each': 80,
        'discriminator_hash_backing_bytes': 156,
        'empty_case_map_backing_bytes': 208,
        'SSA_var_info_hash_backing_bytes': 56, 'SSA_var_info_bytes': 48,
        'SSA_frontier_header_array_bytes': 160, 'SSA_var_vector_bytes': 16,
        'SSA_definition_stack_bytes': 88,
        'dominator_walks': 2, 'walk_int_arrays_each_bytes': 20,
        'walk_pointer_stack_bytes': 80,
        'dominance_array_bytes_individually': [20]*9+[40,24,96],
        'root_loop_order_array_bytes': 20, 'root_loop_candidate_vector_bytes': 16,
        'default_bitmap_header_requests': 6,
        'private_SSA_bitmap_header_requests': 3,
        'private_SSA_bitmap_element_requests': 1,
        'bitmap_header_bytes': 32, 'bitmap_element_bytes': 40,
        'PHI_pruning_large_arrays_reached': False,
    },
    'input_requirements': [
        'Previously established null Main GENERIC graph and selected O0/no-debug/no-checking route',
        'LP64 installed target and existing source-to-tool correspondence premise',
        'Existing type/decl/hash/vector/loop layout transfers; source locations may vary',
    ],
    'remaining_terms': [
        'Source/path/line-map storage and discriminator adhoc-location requests',
        'Shared default bitmap obstack and ET-pool whole-invocation growth/lifetime join',
        'Later warning/ranger/IPA managers and later pass allocations',
        'Collector pages, finalizers, process managers and libc bookkeeping',
    ],
    'complete_ordinary_lifetime_inventory': False,
    'complete_capacity_result': False,
    'native_execution': False,
    'reachability_basis': 'Handwritten selected-route/source derivation; anchors are not semantic verification',
}
args.output.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps({'sources': len(sources), 'GGC_events': 41,
                  'known_subtotal': 40072, 'complete_capacity_result': False}))
