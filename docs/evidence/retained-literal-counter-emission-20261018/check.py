#!/usr/bin/env python3
"""Offline complete-identity, route-landmark and counter-boundary checks.

Landmarks support the handwritten source proof; this does not execute or
mechanically verify GCC semantics. No compiler, debugger or prover is run.
"""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import platform
import re
import subprocess
import time

from derive import evaluate, interface, I32

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]


def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def region(text, start, end):
    return text[text.index(start):text.index(end, text.index(start) + len(start))]


def main():
    timer = time.perf_counter()
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gcc-root', type=Path,
                        default=Path('/tmp/silver-backend-compose-20261018/full-source'))
    parser.add_argument('--ada-root', type=Path,
                        default=Path('/tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada'))
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    manifest = json.loads((HERE / 'source-manifest.json').read_bytes())
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
        check('historical_identity:' + row['path'],
              identity(data) == {k: row[k] for k in ('bytes', 'sha256')})
        history[row['path']] = data.decode()
    sources = {}
    for row in manifest['files']:
        path = (args.ada_root / row['path'].removeprefix('gcc/ada/')
                if row['root'] == 'ada' else args.gcc_root / row['path'])
        data = path.read_bytes()
        check('complete_source_identity:' + row['path'],
              identity(data) == {k: row[k] for k in ('bytes', 'sha256')}
              and hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest()
              == row['git_blob_sha1']
              and row['sha256'] in history[row['retained_identity_origin']])
        sources[row['path']] = data.decode()

    trans = sources['gcc/ada/gcc-interface/trans.cc']
    utils = sources['gcc/ada/gcc-interface/utils.cc']
    function = sources['gcc/function.cc']
    graph = sources['gcc/cgraph.h']
    layout = sources['gcc/stor-layout.cc']
    target = sources['gcc/config/i386/i386-options.cc']
    names = sources['gcc/langhooks.cc']
    cold = json.loads(history['docs/evidence/retained-literal-string-layout-20261018/interface.json'])
    frontier = json.loads(history['docs/evidence/retained-literal-warning-residual-bound-20261018/interface.json'])
    check('accepted_cold_and_body_frontier_inputs',
          cold['size_functions_created'] == 2
          and cold['helper_emitted_functions'] == 0
          and frontier['other_generated_FUNCTION_DECL_bodies'] == 0
          and frontier['empty_elaboration']['symbol_registration_count'] is None
          and frontier['non_Main_function_definition_number_increment'] == 3)
    check('interface_matches_exported_record',
          interface() == json.loads((HERE / 'interface.json').read_bytes()))

    unit = region(trans, '\nCompilation_Unit_to_gnu (', '/* Mark COND, a boolean')
    check('elaboration_constructor_precedes_Main_translation',
          unit.count('allocate_struct_function (gnu_elab_proc_decl, false);') == 1
          and unit.index('allocate_struct_function (gnu_elab_proc_decl, false);')
          < unit.index('add_stmt (gnat_to_gnu (gnat_unit));')
          and 'is_default, true, false, false, false, true, false, NULL, gnat_unit' in unit)
    empty = region(trans, '/* Finally see if we have any elaboration', '/* Destroy ourselves.')
    check('empty_elaboration_skips_only_finalization_arm',
          'if (!gnu_stmts || empty_stmt_list_p (gnu_stmts))' in empty
          and 'Set_Has_No_Elaboration_Code (info->gnat_node, 1);\n      else' in empty
          and empty.count('rest_of_subprog_body_compilation (info->elab_proc);') == 1)
    declcomp = region(sources['gcc/passes.cc'], '\nrest_of_decl_compilation (', '\nrest_of_type_compilation (')
    check('declaration_finalization_excludes_FUNCTION_DECL',
          'else if (finalize && TREE_CODE (decl) != FUNCTION_DECL)\n'
          '\t    varpool_node::finalize_decl (decl);' in declcomp
          and 'targetm.target_option.relayout_function (decl);' in declcomp)
    declstmt = region(trans, '\nadd_decl_expr (', '/* Mark our TYPE_ADA_SIZE')
    check('global_DECL_EXPR_is_not_added_to_statements',
          'if (DECL_EXTERNAL (gnu_decl) || global_bindings_p ())' in declstmt
          and '}\n  else\n    add_stmt_with_node (gnu_stmt, gnat_node);' in declstmt)
    global_finish = region(utils, '\ngnat_write_global_declarations (', '/* ************************************************************************')
    check('global_finish_has_one_dummy_and_no_function_finalization',
          global_finish.count('varpool_node::get_create (dummy_global)') == 1
          and 'cgraph_node' not in global_finish
          and '&& DECL_EXTERNAL (iter)' in global_finish)
    bodycomp = region(utils, '\nrest_of_subprog_body_compilation (', '\ntree\ngnat_builtin_function')
    check('gigi_body_finalization_routes',
          'cgraph_node::finalize_function (subprog_decl, false);' in bodycomp
          and 'cgraph_node::get_create (subprog_decl);' in bodycomp)

    check('funcdef_zero_static_and_single_increment',
          'static GTY(()) int funcdef_no;' in function
          and function.count('return funcdef_no++;') == 1
          and 'current_function_funcdef_no = get_next_funcdef_no ();' in function
          and 'allocate_struct_function (gnu_subprog, false);' in trans)
    finalize = region(layout, '\nfinalize_size_functions (', '\f')
    check('helper_allocation_before_gimplification_and_finalization',
          finalize.index('allocate_struct_function (fndecl, false);')
          < finalize.index('gimplify_function_tree (fndecl);')
          < finalize.index('cgraph_node::finalize_function (fndecl, false);'))
    unitfinal = region(sources['gcc/cgraphunit.cc'], '\nsymbol_table::finalize_compilation_unit (', '\n/*')
    check('size_finalization_precedes_initial_Main_analysis',
          unitfinal.index('finalize_size_functions ();') < unitfinal.index('analyze_functions (/*first_time=*/true);'))
    check('gimplifier_reuses_existing_function_structure',
          'if (DECL_STRUCT_FUNCTION (fndecl))\n    push_cfun (DECL_STRUCT_FUNCTION (fndecl));\n  else\n    push_struct_function (fndecl);'
          in sources['gcc/gimplify.cc'])

    alloc = region(function, '\nallocate_struct_function (', '/* This is like allocate_struct_function')
    check('all_function_constructor_hook_landmarks',
          all(s in alloc for s in ['init_eh_for_function ();', '(*init_machine_status) ();',
                                   'OVERRIDE_ABI_FORMAT (fndecl);',
                                   'invoke_set_current_function_hook (fndecl);',
                                   'targetm.target_option.relayout_function (fndecl);'])
          and not any(s in alloc for s in ['cgraph_node::', 'varpool_node::', 'register_symbol (']))
    hook = region(target, '\nix86_set_current_function (', '/* Implement the TARGET_OFFLOAD_OPTIONS')
    check('full_x86_hook_branch_landmarks',
          all(s in hook for s in ['if (old_tree != new_tree || fp_flag_change)',
                                  'call_used_or_fixed_reg_p (SI_REG)',
                                  '!= cfun->machine->call_saved_registers',
                                  'prev_call_saved_registers = cfun->machine->call_saved_registers;'])
          and not any(s in hook for s in ['get_create (', 'register_symbol (', 'allocate_struct_function (']))
    check('function_relayout_default_and_no_selected_override',
          '(relayout_function,' in sources['gcc/target.def']
          and 'void, (tree fndecl),\n hook_void_tree)' in sources['gcc/target.def']
          and not re.search(r'^\s*#\s*define\s+TARGET_OPTION_RELAYOUT_FUNCTION\b',
                            sources['gcc/config/i386/i386.cc'], re.M))
    for path in manifest['selected_target_headers']:
        check('selected_target_override_exclusions:' + path,
              not re.search(r'^\s*#\s*define\s+(?:TARGET_OPTION_RELAYOUT_FUNCTION|'
                            r'SUBTARGET_MANGLE_DECL_ASSEMBLER_NAME|FUNC_BEGIN_LABEL|FUNC_END_LABEL)\b',
                            sources[path], re.M))
    check('SysV_ABI_override_is_field_store',
          'cfun->machine->call_abi = ix86_function_abi (fndecl);' in sources['gcc/config/i386/i386.cc'])
    check('EH_initialization_only_state_and_sentinels',
          'cfun->eh = ggc_cleared_alloc<eh_status> ();' in sources['gcc/except.cc']
          and 'vec_safe_push (cfun->eh->region_array, (eh_region)0);' in sources['gcc/except.cc'])
    check('default_target_node_and_FP_save_landmarks',
          'target_option_default_node = target_option_current_node\n'
          '        = build_target_option_node (opts, opts_set);' in target
          and 'opts->x_ix86_unsafe_math_optimizations\n'
          '\t= opts->x_flag_unsafe_math_optimizations;' in target)

    check('symbol_initial_values_and_registration_increments',
          'cgraph_count (0), cgraph_max_uid (1)' in graph
          and 'order (0), max_unit (0)' in graph
          and 'nodes->m_uid = cgraph_max_uid++;' in graph
          and 'if (node->order == -1)\n    node->order = order++;' in graph)
    remove = region(graph, '\nsymbol_table::unregister (', '/* Return first static symbol')
    check('removal_does_not_rewind_symbol_counters',
          'cgraph_max_uid' not in remove and 'order' not in remove)
    check('get_create_reuses_existing_graph_and_varpool_nodes',
          'if (first_clone && !first_clone->inlined_to)\n    return first_clone;'
          in sources['gcc/cgraph.cc']
          and 'if (node)\n    return node;' in sources['gcc/varpool.cc'])
    check('default_GNAT_name_hook_no_override',
          '#define LANG_HOOKS_SET_DECL_ASSEMBLER_NAME lhd_set_decl_assembler_name'
          in sources['gcc/langhooks-def.h']
          and 'LANG_HOOKS_SET_DECL_ASSEMBLER_NAME' not in sources['gcc/ada/gcc-interface/misc.cc'])
    mangler = region(sources['gcc/config/i386/i386-features.cc'], '\nix86_mangle_decl_assembler_name (', '/* Make a dispatcher declaration')
    check('x86_name_mangler_reads_existing_node',
          'cgraph_node::get (decl)' in mangler and 'get_create' not in mangler
          and 'DECL_FUNCTION_VERSIONED (decl)' in mangler)
    check('private_name_counter_is_separate_from_symbol_UID_and_order',
          'static unsigned long num;' in names
          and 'ASM_FORMAT_PRIVATE_NAME (label, name, num++);' in names
          and 'sprintf (buf, "SZ" HOST_WIDE_INT_PRINT_UNSIGNED, fnno++);' in layout)

    dwarf = sources['gcc/dwarf2out.cc']
    check('emission_reads_per_function_number',
          '#define current_function_funcdef_no (cfun->funcdef_no)' in sources['gcc/function.h']
          and 'fde->funcdef_number = current_function_funcdef_no;' in dwarf
          and 'ASM_GENERATE_INTERNAL_LABEL (label, FUNC_BEGIN_LABEL,\n\t\t\t       current_function_funcdef_no);' in dwarf
          and 'ASM_GENERATE_INTERNAL_LABEL (label, FUNC_END_LABEL,\n\t\t\t       current_function_funcdef_no);' in dwarf)
    check('other_emission_counters_are_independent',
          'static GTY(()) int label_num = 1;' in sources['gcc/emit-rtl.cc']
          and 'static GTY(()) int const_labelno;' in sources['gcc/varasm.cc']
          and 'static GTY(()) unsigned long dwarf2out_cfi_label_num;' in sources['gcc/dwarf2cfi.cc'])
    check('hard_register_dummy_not_emitted',
          'if (DECL_HARD_REGISTER (decl))\n    return false;' in sources['gcc/varpool.cc'])
    check('numeric_name_width_envelopes',
          len('.LFB1') == len('.LFE1') == 5
          and len('.L' + str(I32)) == 12
          and len('.LC' + str(I32)) == 13
          and len('.LCFI' + str((1 << 64) - 1)) == 25)

    for c, n in [(1, 0), (1, 1000000), (2, 0), (32767, 1), (I32-7, 0), (I32-6, 0), (1 << 80, 0)]:
        v = evaluate(c, n)
        check(f'cumulative_and_next_values:{c},{n}',
              v['symbol_registrations_upper'] == c+6
              and v['next_symbol_UID_upper'] == c+7
              and v['next_symbol_order_upper'] == c+6
              and v['symbol_next_values_fit_signed_32'] == (c <= I32-7)
              and not v['whole_literal_pipeline_capacity_established'])
    for c in range(1, 17):
        v = evaluate(c, 0)
        for d in range(1, min(2, c)+1):
            for b in range(c+1):
                if not (b+d+4 <= v['symbol_registrations_upper']
                        and b+d+5 <= v['next_symbol_UID_upper']
                        and b+d+4 <= v['next_symbol_order_upper']
                        and b+d+2 <= v['live_symbols_after_both_helper_removals_upper']):
                    raise AssertionError('B/D registration formula')
    check('exact_B_D_counts_fit_exports_for_all_small_combinations', True)
    for c, n in [(0, 0), (-1, 0), (1, -1), (True, 0), (1, False), (1.0, 0), (1, '0')]:
        try:
            evaluate(c, n)
        except ValueError:
            check('invalid_count_rejected:' + repr((c, n)), True)
        else:
            raise AssertionError('accepted invalid count')
    check('non_emission_and_unresolved_storage_not_conflated',
          interface()['complete_imported_allocation_events'] is None
          and interface()['complete_imported_allocation_bytes'] is None
          and not interface()['complete_global_counter_lifetime_closed']
          and not interface()['complete_collector_lifetime_closed'])

    finish = datetime.now(timezone.utc)
    start = datetime(2026, 10, 18, 20, 43, 46, tzinfo=timezone.utc)
    result = dict(status='pass', checks=len(checked), checked=checked,
                  source_files=len(manifest['files']),
                  historical_inputs=len(manifest['historical_silver_inputs']),
                  selected_target_headers=len(manifest['selected_target_headers']),
                  reviewed_silver_revision=manifest['reviewed_silver_revision'],
                  selected_model='GPT-6 Astra', selected_effort='Extra High',
                  runtime_model_confirmation=None, token_measurement=None, cost_measurement=None,
                  host=dict(system=platform.system(),release=platform.release(),machine=platform.machine()),
                  native_runs=0, round_start_utc=start.isoformat(),
                  round_completion_utc=finish.isoformat(),
                  round_elapsed_seconds=(finish-start).total_seconds(),
                  checker_elapsed_seconds=time.perf_counter()-timer,
                  independent_review='pending',
                  whole_literal_pipeline_capacity_established=False)
    output = json.dumps(result, indent=2) + '\n'
    if args.output:
        args.output.write_text(output)
    else:
        print(output, end='')


if __name__ == '__main__':
    main()
