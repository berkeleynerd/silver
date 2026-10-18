#!/usr/bin/env python3
"""Reconcile null Main's non-tree gigi helper objects without a native run."""
import argparse
import hashlib
import json
from pathlib import Path

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument('--gcc-root', type=Path, required=True)
parser.add_argument('--output', type=Path, required=True)
args = parser.parse_args()
root = Path(__file__).resolve().parent
identity = json.loads((root / 'null-gigi-helper-source-identity.json').read_text())
sources = {}
for row in identity['files']:
    raw = (args.gcc_root / row['path']).read_bytes()
    assert len(raw) == row['bytes'], row['path']
    assert hashlib.sha256(raw).hexdigest() == row['sha256'], row['path']
    sources[row['path']] = raw.decode()
anchors = {
    'gcc/ada/gcc-interface/trans.cc': [
        'language_function *gnu_subprog_lang = ggc_cleared_alloc<language_function> ();',
        'info = ggc_alloc<elab_info> ();',
        'group = ggc_alloc<stmt_group> ();',
        'vec_safe_push (gnu_elab_proc_stack, gnu_elab_proc_decl);',
        'vec_safe_push (gnu_return_label_stack, NULL_TREE);',
        'vec_safe_push (gnu_except_ptr_stack, NULL_TREE);',
        'linemap_line_start (line_table, file_info_ptr[i].Num_Source_Lines, 252);'],
    'gcc/ada/gcc-interface/utils.cc': ['newlevel = ggc_alloc<gnat_binding_level> ();',
                                    'newlevel->block = make_node (BLOCK);'],
    'gcc/vec.h': ['return MAX (4, reserve);', 'vec_safe_reserve (v, 1, false PASS_MEM_STAT);'],
    'gcc/cfgrtl.cc': [
        'if (loce1.line != loce2.line', '|| loce1.column != loce2.column',
        '|| loce1.data != loce2.data)',
        'BB_END (a) = emit_insn_after_noloc (gen_nop (), BB_END (a), a);',
        '&& !DECL_IGNORED_P (current_function_decl))'],
    'gcc/tree-cfg.cc': ['&& single_succ_edge (a)->goto_locus != UNKNOWN_LOCATION)'],
    'libcpp/line-map.cc': [
        'if (r <= LINE_MAP_MAX_LOCATION_WITH_COLS)',
        'column & ((loc_one << ord_map->m_column_and_range_bits) - 1)'],
}
for path, values in anchors.items():
    for value in values:
        assert value in sources[path], (path, value)

def check_site(path, line, value):
    assert value in sources[path].split('\n')[line - 1], (path, line, value)

trans = 'gcc/ada/gcc-interface/trans.cc'
utils = 'gcc/ada/gcc-interface/utils.cc'
for line in [5999, 4110, 5686, 7743]:
    check_site(trans, line, 'start_stmt_group ();')
for path, line in [(trans, 6000), (utils, 3845), (trans, 4111)]:
    check_site(path, line, 'gnat_pushlevel ();')

align8 = lambda n: (n + 7) // 8 * 8
rows = [
    dict(object='gnat_binding_level', requests=3, raw_bytes=2 * 8,
         excludes='The corresponding three BLOCK tree requests are not priced by this row'),
    dict(object='stmt_group', requests=4, raw_bytes=4 * 8,
         excludes='Statement-list headers, links and BIND_EXPR trees stay in the tree join'),
    dict(object='language_function', requests=1, raw_bytes=align8(3 * 8 + 4),
         excludes='Two struct-function constructors were already charged separately'),
    dict(object='elab_info', requests=1, raw_bytes=align8(2 * 8 + 4)),
    dict(object='gnu_elab_proc_stack', requests=1, requested_capacity=4, raw_bytes=8 + 4 * 8),
    dict(object='gnu_return_label_stack', requests=1, requested_capacity=4, raw_bytes=8 + 4 * 8),
]
events = sum(x['requests'] for x in rows)
assert events == 11
assert [x['raw_bytes'] for x in rows] == [16, 32, 32, 24, 40, 40]
result = dict(
    scope='Selected null Main non-tree gigi helper constructors only',
    gcc_commit=identity['gcc_commit'], checked_source_identities=len(identity['files']),
    allocation_policy='Charge every request cold; free-list reuse can only reduce events',
    objects=rows, GGC_event_allowance=events,
    existing_selected_known_GGC_subtotal=39957,
    updated_selected_known_GGC_subtotal=39957 + events,
    constructor_peak_stack=dict(statement_groups=4, binding_levels=3),
    return_value_or_parameter_helper_allocations=0,
    exception_pointer_stack_already_in_prefix=True,
    required_inputs=['Complete tree/identifier/global-vector and gigi helper transitive joins',
                     'Initial GIMPLE/SSA/cgraph/IPA allocation composition',
                     'Variable source/path/line-map metadata and whole-unit emission'],
    debug_disabled_implies_exact_assembly_invariance=False,
    source_location_opaque_to_code_layout=False,
    selected_null_exact_output_invariance_established=False,
    no_additional_capture_authorized_or_performed=True,
    complete_capacity_result=False)
args.output.write_text(json.dumps(result, indent=2, sort_keys=True) + '\n')
print(json.dumps(dict(identities=len(identity['files']), added_GGC_events=events,
                     known_subtotal=39957 + events, complete_capacity_result=False)))
