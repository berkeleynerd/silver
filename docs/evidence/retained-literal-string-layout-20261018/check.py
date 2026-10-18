#!/usr/bin/env python3
"""Offline source identity, route landmarks and cold-helper interface checks.

This does not execute GCC, simulate its folder, or mechanically establish
the handwritten source argument in the research note.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import platform
import subprocess
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]


def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    start = time.monotonic()
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gcc-root', type=Path,
                        default=Path('/tmp/silver-backend-compose-20261018/full-source'))
    parser.add_argument('--ada-root', type=Path,
                        default=Path('/tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada'))
    parser.add_argument('--match-path', type=Path,
                        default=Path('/tmp/silver-backend-compose-20261018/folding-sources/match.pd'))
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    manifest = json.loads((HERE / 'source-manifest.json').read_bytes())
    interface = json.loads((HERE / 'interface.json').read_bytes())
    checked = []

    def check(name, value):
        if not value:
            raise AssertionError(name)
        checked.append(name)

    history = {}
    for row in manifest['historical_silver_inputs']:
        data = subprocess.check_output(
            ['git', 'show', manifest['reviewed_silver_revision'] + ':' + row['path']],
            cwd=REPO)
        if identity(data) != {k: row[k] for k in ('bytes', 'sha256')}:
            raise AssertionError('historical identity: ' + row['path'])
        history[row['path']] = data.decode()
    check('historical_silver_inputs_pinned', True)
    sources = {}
    for row in manifest['files']:
        path = (args.ada_root / row['path'].removeprefix('gcc/ada/')
                if row['root'] == 'ada' else args.match_path
                if row['root'] == 'match' else args.gcc_root / row['path'])
        data = path.read_bytes()
        if identity(data) != {k: row[k] for k in ('bytes', 'sha256')}:
            raise AssertionError('source identity: ' + row['path'])
        blob = b'blob ' + str(len(data)).encode() + b'\0' + data
        if hashlib.sha1(blob).hexdigest() != row['git_blob_sha1']:
            raise AssertionError('Git blob identity: ' + row['path'])
        if row['sha256'] not in history[row['retained_identity_origin']]:
            raise AssertionError('retained pin: ' + row['path'])
        sources[row['path']] = data.decode()
    check('all_complete_sources_match_retained_pins', True)

    ada = 'gcc/ada/'
    decl = sources[ada + 'gcc-interface/decl.cc']
    utils = sources[ada + 'gcc-interface/utils.cc']
    layout = sources['gcc/stor-layout.cc']
    tree = sources['gcc/tree.cc']
    fold = sources['gcc/fold-const.cc']
    matcher = sources['gcc/match.pd']
    cgraph = sources['gcc/cgraphunit.cc']

    check('standard_positive_has_no_fixed_lower_bound_setter',
          'Set_Is_Fixed_Lower_Bound_Index_Subtype' not in sources[ada + 'cstand.adb'])
    check('new_entities_zero_fields', all(s in sources[ada + 'atree.adb'] for s in (
        'Zero_Dynamic_Slots (Sl, Sl + Sz - 1);', 'Zero_Header_Slots (Result);',
        'New_Id : constant Entity_Id := Allocate_New_Node (New_Node_Kind);')))
    check('fixed_lower_bound_flag_is_a_flag',
          'Sm (Is_Fixed_Lower_Bound_Index_Subtype, Flag)' in sources[ada + 'gen_il-gen-gen_entities.adb'])
    check('selected_bound_builder_has_readonly_leaves_and_conditional', all(s in decl for s in (
        'TREE_READONLY (gnu_orig_min) = 1;', 'TREE_READONLY (gnu_orig_max) = 1;',
        'TREE_READONLY (gnu_template_reference) = 1;',
        '= build3 (COND_EXPR, sizetype,', 'build2 (GE_EXPR, boolean_type_node,')))
    check('distribution_has_no_SAVE_EXPR_constructor',
          'save_expr (' not in fold[fold.index('\nfold_binary_op_with_conditional_arg ('):
                                    fold.index('/* Subroutine of fold() that checks')])
    check('false_branch_contraction_and_narrowing_guards_present', all(s in matcher for s in (
        '(minus (nop_convert1? (plus:c (nop_convert2? @0) @1)) @0)',
        '(minus (nop_convert1? (minus (nop_convert2? @0) @1)) @0)',
        'TYPE_PRECISION (type) <= TYPE_PRECISION (TREE_TYPE (@0))')))
    array_start = layout.index('    case ARRAY_TYPE:', layout.index('\nlayout_type ('))
    array = layout[array_start:layout.index('/* Now round the alignment and size,', array_start)]
    check('array_constructs_bit_and_byte_extents',
          'bits_from_bytes (length)' in array and 'TYPE_SIZE_UNIT (element), length)' in array)
    finalize = layout[layout.index('\nfinalize_type_size ('):
                      layout.index('/* Handle empty records')]
    check('separate_bit_then_byte_variable_size_calls',
          finalize.count('= variable_size (TYPE_SIZE') == 2
          and finalize.index('= variable_size (TYPE_SIZE (type))')
          < finalize.index('= variable_size (TYPE_SIZE_UNIT (type))'))
    ranges = tree[tree.index('\nbuild_range_type_1 ('):tree.index('/* Wrapper around build_range_type_1')]
    check('nonshared_range_returns_before_canonicalization',
          ranges.index('if (!shared)') < ranges.index('type_hash_canon ('))
    check('fresh_type_and_conditional_canonical_recursion',
          'TYPE_CANONICAL (t) = t;' in tree
          and 'TYPE_CANONICAL (elt_type) != elt_type' in tree
          and 'TYPE_CANONICAL (index_type) != index_type' in tree)
    helper = layout[layout.index('\nself_referential_size ('):layout.index('/* Take, queue and compile')]
    check('helper_guard_and_private_inline_constructor', all(s in helper for s in (
        'skip_simple_constant_arithmetic (size)',
        'TREE_CODE (t) == CALL_EXPR || self_referential_component_ref_p (t)',
        'DECL_DECLARED_INLINE_P (fndecl) = 1;',
        'DECL_ARTIFICIAL (fndecl) = 1;', 'DECL_IGNORED_P (fndecl) = 1;',
        'TREE_STATIC (fndecl) = 1;', 'fnno++', 'vec_safe_push (size_functions, fndecl);')))
    check('XUT_rep_zero_and_XVE_constant_size',
          'finish_record_type (type, template_field, 0, true);' in utils
          and 'if (rep_level == 1)' in utils
          and 'TYPE_SIZE (new_record_type) = size_int (TYPE_ALIGN (record_type));' in utils)
    check('variable_field_advances_byte_offset',
          'size_binop (PLUS_EXPR, rli->offset, DECL_SIZE_UNIT (field));' in layout)
    late = layout[layout.index('\nfinalize_size_functions ('):layout.index('/* Return a machine mode')]
    check('helper_allocate_gimplify_finalize_order',
          late.index('allocate_struct_function (fndecl, false);')
          < late.index('gimplify_function_tree (fndecl);')
          < late.index('cgraph_node::finalize_function (fndecl, false);'))
    unit = cgraph[cgraph.index('\nsymbol_table::finalize_compilation_unit ('):]
    check('helper_gimplification_before_analysis_before_compile',
          unit.index('finalize_size_functions ();') < unit.index('analyze_functions (')
          < unit.index('compile ();'))
    check('O0_static_force_output_excludes_declared_inline',
          '&& !DECL_DECLARED_INLINE_P (decl)' in cgraph)
    selected = json.loads(history['docs/evidence/retained-producer-parent-20261018/fixed-gcc-prefix-witness/frontend-exec.json'])
    check('retained_selected_argv_has_no_keep_inline',
          not any(a.startswith('-fkeep-inline-functions') for a in selected['argv'])
          and 'fkeep-inline-functions\nCommon Var(flag_keep_inline_functions)\n' in sources['gcc/common.opt'])
    needed = cgraph[cgraph.index('\nsymtab_node::needed_p ('):cgraph.index('/* Head and terminator')]
    check('needed_does_not_test_TREE_USED', 'TREE_USED' not in needed)
    check('unused_removal_guard_and_initial_lowering_are_distinct',
          'if (!node->aux && !node->referred_to_p () && !node->ref_by_asm)' in cgraph
          and 'execute_pass_list (cfun, g->get_passes ()->all_lowering_passes);' in cgraph)
    check('initializer_walk_stops_at_type_or_decl',
          'if (IS_TYPE_OR_DECL_P (*tp))' in sources['gcc/cgraphbuild.cc'])
    check('registration_increments_uid_and_order',
          'nodes->m_uid = cgraph_max_uid++;' in sources['gcc/cgraph.h']
          and 'node->order = order++;' in sources['gcc/cgraph.h'])
    check('function_allocation_consumes_monotone_definition_number',
          'return funcdef_no++;' in sources['gcc/function.cc']
          and 'current_function_funcdef_no = get_next_funcdef_no ();' in sources['gcc/function.cc'])
    check('concrete_cold_count_and_discard_interface',
          interface['size_functions_created'] == 2
          and interface['initial_helper_gimplifications'] == 2
          and interface['additional_live_function_nodes_during_initial_Main_lowering'] == 2
          and interface['helper_emitted_functions'] == 0
          and interface['live_helper_nodes_after_initial_removal'] == 0
          and set(interface['persistent_counter_increments'].values()) == {2})
    check('warning_allocations_and_aggregate_remain_open',
          all(interface[k] is None for k in ('R', 'helper_initial_warning_map_puts',
              'helper_allocation_request_events', 'helper_allocation_bytes'))
          and not interface['complete_imported_frontier_closed']
          and not interface['aggregate_conditions_changed']
          and not interface['whole_literal_pipeline_capacity_established'])

    now = datetime.now(timezone.utc)
    result = dict(status='pass', checked=checked,
                  source_files_verified=len(manifest['files']),
                  historical_inputs_verified=len(history),
                  scope='Identity and source-route landmarks; handwritten source proof requires review',
                  selected_model='GPT-6 Astra', selected_effort='Extra High',
                  runtime_confirmed_model=None, runtime_confirmed_effort=None,
                  token_usage=None, cost=None, native_executions=0,
                  host=platform.platform(), round_start_utc='2026-10-18T20:01:46+00:00',
                  completed_utc=now.isoformat(),
                  round_elapsed_seconds=int((now-datetime(2026, 10, 18, 20, 1, 46,
                                                         tzinfo=timezone.utc)).total_seconds()),
                  check_elapsed_seconds=round(time.monotonic()-start, 6))
    output = json.dumps(result, indent=2) + '\n'
    if args.output:
        args.output.write_text(output)
    print(output, end='')


if __name__ == '__main__':
    main()
