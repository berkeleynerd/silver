#!/usr/bin/env python3
"""Reconcile selected null warning/IPA requests using retained source only."""
import argparse
import hashlib
import json
from pathlib import Path

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--gcc-root', type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
root = Path(__file__).resolve().parent
identity = json.loads((root / 'null-pass-join-source-identity.json').read_text())
sources = {}
for row in identity['files']:
    raw = (a.gcc_root / row['path']).read_bytes()
    assert len(raw) == row['bytes']
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']
    sources[row['path']] = raw.decode()
for row in identity['reused_results']:
    raw = (root / row['path']).read_bytes()
    assert len(raw) == row['bytes']
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']
anchors = {
    'gcc/ipa-fnsummary.cc': ['ipa_fn_summaries = ipa_fn_summary_t::create_ggc (symtab);',
                            'ipa_fn_summaries->remove (node);',
                            'ipa_fn_summaries->enable_insertion_hook ();',
                            'order = XNEWVEC (int, n_basic_blocks_for_fn (cfun));'],
    'gcc/ipa-fnsummary.h': ['ggc_alloc_no_dtor<ipa_fn_summary_t> ()',
                           'public fast_function_summary <ipa_fn_summary *, va_gc>'],
    'gcc/symbol-summary.h': ['vec_alloc (m_vector, 13 PASS_MEM_STAT);',
                             'new (ggc_internal_alloc (sizeof (T))) T ()',
                             'm_ggc (ggc), m_map (13, ggc, true, GATHER_STATISTICS PASS_MEM_STAT)'],
    'gcc/ipa-prop.h': ['new (ggc_alloc_no_dtor <ipa_node_params_t> ())'],
    'gcc/ipa-prop.cc': ['new (ggc_alloc_no_dtor<ipa_edge_args_sum_t> ())',
                       'hash_table<ipa_vr_ggc_hash_traits>::create_ggc (37);'],
    'gcc/ipa-inline-analysis.cc': ['new fast_call_summary<edge_growth_cache_entry *, va_heap>',
                                  'new fast_function_summary<node_context_summary *, va_heap>'],
    'gcc/cgraph.h': ['vec<ipa_opt_pass, va_heap, vl_ptr> GTY((skip)) ipa_transforms_to_apply;',
                     'node->m_summary_id = cgraph_max_summary_id++;'],
    'gcc/ipa-free-lang-data.cc': ['free_lang_data_d () : decls (100), types (100) {}'],
    'gcc/ipa.cc': ['hash_set<symtab_node *> reachable;',
                   'hash_set<tree> body_needed_for_clonning;',
                   'hash_set<void *> reachable_call_targets;',
                   'hash_map<varpool_node *, cgraph_node *> single_user_map;'],
    'gcc/ipa-comdats.cc': ['hash_map<symtab_node *, tree> map (251);',
                          'hash_map<tree, symtab_node *> comdat_head_map (251);'],
    'gcc/gimple-ssa-warn-access.cc': ['if (!arg || TREE_CODE (arg) != ADDR_EXPR)',
                                     'hash_set<tree> stores;',
                                     'free_dominance_info (CDI_POST_DOMINATORS);',
                                     'free_dominance_info (CDI_DOMINATORS);'],
    'gcc/gimple-ssa-warn-alloca.cc': ['if (!gimple_alloca_call_p (stmt))\n\t    continue;'],
    'gcc/tree-switch-conversion.cc': ['switch_statements.create (1);'],
    'gcc/fibonacci_heap.h': ['m_allocator = new pool_allocator ("Fibonacci heap",'],
}
for path, fragments in anchors.items():
    for fragment in fragments:
        assert fragment in sources[path], (path, fragment)
schedule = sources['gcc/passes.def']
assert schedule.count('NEXT_PASS (pass_local_fn_summary);') == 2
assert schedule.count('NEXT_PASS (pass_ipa_fn_summary);') == 1
eh = sources['gcc/tree-eh.cc'].split('\n')
assert 'return fun->eh->region_tree != NULL;' in '\n'.join(eh[4060:4084])

# Three cold manager groups conservatively cover two local requests plus
# one whole-unit generation; the second local normally reuses its managers.
groups = 3
rows = [
    ('function_summary_manager', groups, 512),
    ('function_summary_vector', groups, 128),
    ('local_Main_function_summary_record', 2, 128),
    ('IPA_parameter_manager', 1, 512),
    ('IPA_parameter_map_13_entries', 1, 208),
    ('IPA_edge_argument_manager', 1, 512),
    ('IPA_edge_argument_map_13_entries', 1, 208),
    ('IPA_value_range_hash_control', 1, 128),
    ('IPA_value_range_hash_backing_61_pointers', 1, 488),
]
assert sum(n for _, n, _ in rows) == 14
assert 8+13*8 <= 128 and 13*16 == 208 and 61*8 == 488
pool_allocator = 12*8+8+32
largest_summary_manager = 8+7*8+pool_allocator+8+48
assert pool_allocator == 136 and largest_summary_manager == 256 <= 512
assert 2+2*3 == 8  # seed calls plus two calls per retained statement
assert 2*5 <= 12 and 2*(2*5) <= 24  # two GIMPLE directions fit prior ET envelope
prior = json.loads((root / 'native-null-initial-gimple.json').read_text())
assert prior['updated_selected_known_GGC_subtotal'] == 40072
result = {
    'scope': identity['scope'], 'gcc_commit': identity['gcc_commit'],
    'complete_sources_verified': len(sources),
    'reused_results_verified': len(identity['reused_results']),
    'GGC_requests': [{'object': obj, 'events': n, 'individual_raw_bytes_at_most': b}
                     for obj, n, b in rows],
    'new_GGC_events': 14, 'updated_selected_known_GGC_subtotal': 40086,
    'summary_manager_groups_cold_allowance': groups,
    'function_summary_IDs_ever_needed': 1, 'call_summary_IDs_ever_needed': 0,
    'parameter_edge_argument_and_value_range_map_entries': 0,
    'summary_constructor_and_inline_hook_requests_at_most': groups*8+1+6+5+1,
    'ordinary_hook_bytes_each': 24,
    'ordinary_request_bounds': {
        'summary_manager_each': 512, 'summary_pointer_vector': 112,
        'local_size_summary_record': 16, 'size_summary_pool_block': 65536,
        'local_summary_worklist': 40, 'local_summary_order_array': 20,
        'size_time_entry_at_most': 96,
        'size_time_vector_growth_requests_per_local': [392, 776],
        'free_language_data_vectors_each': 808,
        'empty_pointer_hash_set_backing': 104,
        'reachability_hash_sets_per_invocation': 3,
        'ODR_hash_backing': 248, 'single_user_map_backing': 208,
        'COMDAT_map_backing_each': 4016,
        'inline_order_arrays_each': 8, 'reverse_postorder_stack': 24,
        'reduced_postorder_DFS_record': 32,
        'reduced_postorder_stack': 8, 'splay_tree_control_at_most': 64,
        'splay_tree_node': 32, 'indirect_edge_vector': 72,
        'queued_inline_transform_vector': 40,
        'O0_switch_vector': 16,
        'warning_graph_slots': 5, 'coexisting_ET_nodes': 10,
        'coexisting_ET_occurrences': 20,
    },
    'EH_dispatch_selected': False,
    'EH_filter_vectors_or_hashes_created': 0,
    'previous_ranger_and_out_of_SSA_backing_reused': True,
    'warnings_add_GGC_object_constructors': False,
    'existing_ET_pool_envelope_nodes': 12,
    'existing_ET_pool_envelope_occurrences': 24,
    'input_requirements': [
        'Established null one-function/one-dummy symbol graph; no calls, references, loops, aliases or clones',
        'Previously established selected O0/no-debug/no-profile/no-instrumentation pass dispositions',
        'Initial SSA graph has at most5 blocks/4 edges/3 live statements/2 SSA slots',
        'Installed LP64 source/tool, checking/statistics and allocator configuration premises',
    ],
    'remaining_terms': [
        'Whole cgraph analysis/finalization and any helper not covered by these selected pass interfaces',
        'Source/path/line-map and Ada callback metadata',
        'Collector pages/finalizers and whole-invocation process/library composition',
    ],
    'complete_capacity_result': False, 'native_execution': False,
    'reachability_basis': 'Manual selected-route source argument; anchors do not automatically prove reachability',
}
a.output.write_text(json.dumps(result, indent=2)+'\n')
print(json.dumps({'sources': len(sources), 'new_GGC_events': 14,
                  'known_subtotal': 40086, 'complete_capacity_result': False}))
