#!/usr/bin/env python3
"""Reconcile null cgraph lifecycle interfaces without executing native tools."""
import argparse
import hashlib
import json
from pathlib import Path

p = argparse.ArgumentParser(description=__doc__)
p.add_argument('--gcc-root', type=Path, required=True)
p.add_argument('--output', type=Path, required=True)
a = p.parse_args()
root = Path(__file__).resolve().parent
identity = json.loads((root / 'null-cgraph-lifecycle-source-identity.json').read_text())
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
    'gcc/cgraphunit.cc': [
        'hash_set<void *> reachable_call_targets;',
        'analyze_functions (/*first_time=*/true);',
        'analyze_functions (/*first_time=*/false);',
        'if (!cnode->analyzed)\n\t\tcnode->analyze ();',
        'if (!cgraph_new_nodes.exists ())\n    return;',
        'node->aux = queued_nodes;',
        'symtab_node::check_ifunc_callee_symtab_nodes ();',
        'execute_pass_list (cfun, g->get_passes ()->all_lowering_passes);',
        'execute_pass_list (cfun, g->get_passes ()->all_passes);',
    ],
    'gcc/cgraphbuild.cc': [
        'walk_stmt_load_store_addr_ops (stmt, this, mark_load, mark_store,',
        'i = fun->eh->region_tree;\n  if (!i)\n    return;',
        'record_eh_tables (node, fun);',
    ],
    'gcc/gimple-walk.cc': [
        'else if (greturn *return_stmt = dyn_cast <greturn *> (stmt))',
        'tree op = gimple_return_retval (return_stmt);\n      if (op)',
    ],
    'gcc/symtab.cc': [
        'ifunc_ref_map = BITMAP_ALLOC (NULL);',
        'bitmap_set_bit (ifunc_ref_map, uid);',
    ],
    'gcc/cgraph.cc': [
        'if (cgraph_fnver_htab == NULL)\n    return NULL;',
        'if (DECL_ARGUMENTS (decl) || gimple_has_body_p (decl))\n    return false;',
    ],
    'gcc/varpool.cc': ['else if (DECL_INITIAL (decl))\n    record_references_in_initializer (decl, analyzed);'],
    'gcc/symtab-thunks.cc': ['if (!thunks)\n    return;'],
    'gcc/tree-nested.cc': ['if (!nested_function_sum)\n    return NULL;'],
    'gcc/lto-section-in.cc': ['if (!node->lto_file_data)\n    return;'],
    'gcc/ada/gcc-interface/misc.cc': [
        '#define LANG_HOOKS_WARN_UNUSED_GLOBAL_DECL hook_bool_const_tree_false'],
    'gcc/ada/gcc-interface/utils.cc': [
        'DECL_HARD_REGISTER (dummy_global) = 1;',
        'node->force_output = 1;'],
    'gcc/langhooks-def.h': ['#define LANG_HOOKS_FINALIZE_EARLY_DEBUG lhd_finalize_early_debug'],
    'gcc/langhooks.cc': ['(*debug_hooks->early_global_decl) (cnode->decl);'],
    'gcc/debug.cc': ['/* early_global_decl */'],
    'gcc/toplev.cc': ['announce_function (tree decl)\n{\n  if (!quiet_flag)'],
}
for path, fragments in anchors.items():
    for fragment in fragments:
        assert fragment in sources[path], (path, fragment)
assert 'LANG_HOOKS_FINALIZE_EARLY_DEBUG' not in sources['gcc/ada/gcc-interface/misc.cc']
invocation = json.loads((root / 'fixed-gcc-prefix-witness/frontend-exec.json').read_text())
assert '-quiet' in invocation['argv']
prior = json.loads((root / 'native-null-pass-join.json').read_text())
assert prior['updated_selected_known_GGC_subtotal'] == 40086
assert 13*8 == 104
result = {
    'scope': identity['scope'], 'gcc_commit': identity['gcc_commit'],
    'complete_sources_verified': len(sources),
    'reused_results_verified': len(identity['reused_results']),
    'analyze_functions_invocations': 2,
    'Main_analyze_and_lowering_invocations': 1,
    'Main_expansion_invocations': 1,
    'symbol_nodes_at_most': 2,
    'callgraph_edges_and_references': 0,
    'generated_functions_aliases_and_version_entries': 0,
    'new_GGC_events': 0,
    'updated_selected_known_GGC_subtotal': 40086,
    'ordinary_requests': {
        'empty_reachable_call_target_hash_backings': 2,
        'individual_reachable_call_target_backing_bytes': 104,
        'ifunc_bitmap_headers': 1,
        'ifunc_bitmap_elements': 1,
        'ifunc_bitmap_header_bytes': 32,
        'ifunc_bitmap_element_bytes': 40,
    },
    'previously_charged_interfaces': [
        'One cgraph and one dummy varpool constructor; assembler-name hash',
        'Initial GIMPLE/CFG/SSA and selected warning/IPA/RTL requests',
        'ODR hash, cfun stack, bitmap initialization depth, fixed bitmap requests',
        'Function-output ordering and direct unit emission',
    ],
    'remaining_terms': [
        'Source/path/line-map and Ada callback metadata',
        'Collector pages/finalizers and allocation callbacks',
        'Whole-invocation process/library setup and teardown',
        'Separate assembler, binder, linker and proof producer composition',
    ],
    'complete_capacity_result': False, 'native_execution': False,
    'reachability_basis': 'Manual selected-route source argument; anchors do not automatically prove reachability',
}
a.output.write_text(json.dumps(result, indent=2) + '\n')
print(json.dumps({'complete_sources_verified': len(sources),
                  'reused_results_verified': len(identity['reused_results']),
                  'new_GGC_events': 0,
                  'known_GGC_subtotal': 40086}))
