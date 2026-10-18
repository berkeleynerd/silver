#!/usr/bin/env python3
"""Reconcile selected null gigi structural tree requests offline."""
import argparse
import hashlib
import json
import re
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--gcc-root', type=Path, required=True)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parent
identity = json.loads((root / 'null-gigi-tree-source-identity.json').read_text())
sources = {}
for row in identity['files']:
    raw = (args.gcc_root / row['path']).read_bytes()
    assert len(raw) == row['bytes'], row['path']
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']
    sources[row['path']] = raw.decode()

def lines(path, low, high):
    return '\n'.join(sources[path].split('\n')[low-1:high])

sites = {
    'gcc/ada/gcc-interface/trans.cc': {
        441: 'void_ftype = build_function_type_list (void_type_node, NULL_TREE);',
        5986: 'NULL_TREE, void_ftype, NULL_TREE,',
        5987: 'is_default, true, false, false, false, true, false, NULL, gnat_unit);',
        6081: 'DECL_SAVED_TREE (gnu_elab_proc_decl) = end_stmt_group ();',
        8219: 'gnu_result = alloc_stmt_list ();',
        9117: 'gnu_stmt = build1 (DECL_EXPR, void_type_node, gnu_decl);',
        9265: 'gnu_retval = alloc_stmt_list ();',
        9272: 'gnu_retval = build3 (BIND_EXPR, void_type_node, BLOCK_VARS (group->block),',
    },
    'gcc/ada/gcc-interface/utils.cc': {
        676: 'return force_global || !current_function_decl;',
        703: 'newlevel->block = make_node (BLOCK);',
        726: 'set_block_for_group (current_binding_level->block);',
        3705: 'tree subprog_decl = build_decl (input_location, FUNCTION_DECL, name, type);',
        3790: '= build_decl (DECL_SOURCE_LOCATION (decl), RESULT_DECL, NULL_TREE,',
    },
    'gcc/ada/gcc-interface/decl.cc': {
        6200: 'gnu_return_type = void_type_node;',
        6607: 'gnu_param_type_list = chainon (gnu_param_type_list, void_list_node);',
        6673: '= build_function_type (gnu_return_type, gnu_param_type_list);',
    },
    'gcc/tree.cc': {
        1334: 't = ggc_alloc_cleared_tree_node_stat (length PASS_MEM_STAT);',
        5203: 't = ggc_alloc_tree_node_stat (length PASS_MEM_STAT);',
        7753: 't = make_node (FUNCTION_TYPE);',
    },
    'gcc/tree-iterator.cc': {
        45: 'list = make_node (STATEMENT_LIST);',
        57: 'vec_safe_push (stmt_list_cache, t);',
        213: 'head = ggc_alloc<tree_statement_list_node> ();',
    },
}
for path, mapping in sites.items():
    for line, fragment in mapping.items():
        assert fragment in lines(path, line, line), (path, line, fragment)
assert '#define MACHINE_MODE_BITSIZE 16' in sources['gcc/machmode.h']

# Deliberately pessimistic layout: charge each named bitfield as a separate
# four-byte allocation unit instead of assuming adjacent fields share it.
core = 'gcc/tree-core.h'
def bitfields(low, high):
    source = re.sub(r'/\*.*?\*/', '', lines(core, low, high), flags=re.S)
    return len(re.findall(r'\s:\s*\w+\s*;', source))
assert [bitfields(1897,1972), bitfields(2008,2043), bitfields(2072,2119)] == [28,17,18]
align8 = lambda n: (n+7)//8*8
decl_minimal = 24+4+4+8+8
decl_common = align8(decl_minimal+8+28*4+4+5*8)
decl_rtl = decl_common+8
decl_vis = align8(decl_rtl+2*8+17*4)
function_upper = align8(decl_vis+8+7*8+4+18*4)
assert (decl_common, decl_rtl, decl_vis, function_upper) == (216,224,312,456)
assert function_upper <= 512 and decl_rtl+8 <= 256

rows = [
    dict(object='FUNCTION_DECL', requests=2, raw_bytes_upper=512),
    dict(object='RESULT_DECL', requests=2, raw_bytes_upper=256),
    dict(object='BLOCK', requests=3, raw_bytes_upper=96),
    dict(object='FUNCTION_TYPE candidate', requests=1, raw_bytes_upper=256),
    dict(object='LABEL_DECL in source null', requests=1, raw_bytes_upper=256),
    dict(object='expression trees including unsharing allowance', requests=20,
         operand_slots_upper=24, raw_bytes_upper=48, cumulative_raw_bytes_upper=20*24+24*8),
    dict(object='STATEMENT_LIST headers', requests=5, raw_bytes_upper=32),
    dict(object='statement-list links', requests=4, raw_bytes_upper=24),
]
events = sum(row['requests'] for row in rows)
assert events == 38
assert rows[5]['cumulative_raw_bytes_upper'] == 672
result = dict(
    scope='Null Main gigi structural tree and statement-link requests only',
    gcc_commit=identity['gcc_commit'], checked_source_identities=len(sources),
    premise='Earlier selected null scaffold/body shape and Linux LP64 target closure',
    allocation_policy='Charge all constructors cold, including discarded candidates and the prior twelve-copy unsharing allowance',
    objects=rows,
    declaration_layout_upper_bounds=dict(common=decl_common, with_rtl=decl_rtl,
                                        with_visibility=decl_vis, function=function_upper),
    GGC_event_allowance=events, existing_selected_known_GGC_subtotal=39968,
    updated_selected_known_GGC_subtotal=39968+events,
    required_remaining_inputs=[
        'Identifier nodes/payloads and shared type/name hash backing',
        'Global declaration vector, statement-list cache vector, warning/context helpers',
        'Initial GIMPLE/CFG/SSA and whole-unit cgraph/IPA constructor backing',
        'Variable source/path/location metadata and unit-emission helpers',
        'Whole-schedule shared GGC page/finalizer and non-DF pool arithmetic'],
    native_execution=False, complete_capacity_result=False)
args.output.write_text(json.dumps(result, indent=2, sort_keys=True)+'\n')
print(json.dumps(dict(identities=len(sources), added_GGC_events=events,
                     known_subtotal=39968+events, complete_capacity_result=False)))
