#!/usr/bin/env python3
"""Offline identity, route-landmark and warning-transfer arithmetic checks.

Landmarks support the handwritten source argument; they do not prove C++
control flow. This checker executes no compiler or native capture.
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

from derive import evaluate, frozen_module, R_BOUND, R_BREAKDOWN

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
    check('historical_inputs_match_frozen_base', True)
    sources = {}
    for row in manifest['files']:
        path = (args.ada_root / row['path'].removeprefix('gcc/ada/')
                if row['root'] == 'ada' else args.gcc_root / row['path'])
        data = path.read_bytes()
        if identity(data) != {k: row[k] for k in ('bytes', 'sha256')}:
            raise AssertionError('source identity: ' + row['path'])
        blob = b'blob ' + str(len(data)).encode() + b'\0' + data
        if hashlib.sha1(blob).hexdigest() != row['git_blob_sha1']:
            raise AssertionError('Git blob identity: ' + row['path'])
        if row['sha256'] not in history[row['retained_identity_origin']]:
            raise AssertionError('retained pin: ' + row['path'])
        sources[row['path']] = data.decode()
    check('complete_sources_match_retained_identities', True)

    trans = sources['gcc/ada/gcc-interface/trans.cc']
    decl = sources['gcc/ada/gcc-interface/decl.cc']
    utils = sources['gcc/ada/gcc-interface/utils.cc']
    layout = sources['gcc/stor-layout.cc']
    gimplify = sources['gcc/gimplify.cc']
    gimple = sources['gcc/gimple.cc']
    warnings = sources['gcc/warning-control.cc']
    locations = sources['gcc/gcc-diagnostic-spec.cc']
    cold = json.loads(history['docs/evidence/retained-literal-string-layout-20261018/interface.json'])
    check('frozen_two_helper_interface_and_historical_open_R',
          cold['size_functions_created'] == 2
          and cold['initial_helper_gimplifications'] == 2
          and cold['helper_emitted_functions'] == 0
          and cold['helper_initial_warning_map_puts'] is None and cold['R'] is None)
    check('frozen_warning_transfer_remains_source_open',
          not frozen_module().evaluate(1, 0, 5)['original_gigi_source_count_closed'])
    check('selected_library_has_two_ordinary_String_procedures',
          history['src/silver_io.ads'].count('(Item : String)') == 2
          and 'procedure Put_Line (Item : String)' in history['src/silver_io.ads']
          and 'procedure Put (Item : String)' in history['src/silver_io.ads'])
    cache = decl[decl.index('/* If we\'ve already processed this entity'):decl.index('/* If this is a numeric')]
    check('entity_cache_returns_before_uncached_location_assignment',
          'return gnu_decl;' in cache
          and decl.index('return gnu_decl;', decl.index('/* If we\'ve already processed'))
          < decl.index('Sloc_to_locus (Sloc (gnat_entity), &input_location)'))
    check('completed_String_sets_both_fat_pointer_links',
          'TYPE_POINTER_TO (gnu_type) = gnu_fat_type;' in decl
          and 'TYPE_REFERENCE_TO (gnu_type) = gnu_fat_type;' in decl)
    check('Standard_maps_to_plain_BUILTINS_and_No_Location_returns',
          'if (Sloc == No_Location)\n    return false;' in trans
          and 'if (Sloc <= Standard_Location)' in trans
          and '*locus = BUILTINS_LOCATION;' in trans)
    push = utils[utils.index('\ngnat_pushdecl ('):utils.index('\ngnat_pushdecl (') + 6000]
    check('push_suppression_precedes_final_GNAT_location',
          push.index('suppress_warning (decl);') < push.index('&DECL_SOURCE_LOCATION (decl)'))
    param = utils[utils.index('\ncreate_param_decl ('):utils.index('\ncreate_param_decl (') + 500]
    check('parameter_constructor_has_no_push',
          'build_decl' in param and 'gnat_pushdecl' not in param)
    namespace = trans[trans.index('\nget_or_create_namespace ('):trans.index('/* Create namespace decls')]
    check('namespace_cache_precedes_single_push',
          namespace.count('gnat_pushdecl (') == 1
          and namespace.index('return *value;') < namespace.index('gnat_pushdecl ('))
    with_case = trans[trans.index('    case N_With_Clause:'):trans.index('    case N_With_Clause:') + 600]
    check('with_clause_uses_namespace_or_empty_statement',
          'get_namespace' in with_case and 'Implicit_With' in with_case)
    unit = trans[trans.index('\nCompilation_Unit_to_gnu ('):trans.index('/* Mark COND, a boolean')]
    check('one_compilation_unit_elaboration_structure',
          unit.count('allocate_struct_function (gnu_elab_proc_decl, false);') == 1
          and '!Acts_As_Spec (gnat_node)' in unit)
    empty = trans[trans.index('/* Finally see if we have any elaboration'):trans.index('/* Destroy ourselves.')]
    check('empty_elaboration_skips_body_compilation',
          'if (!gnu_stmts || empty_stmt_list_p (gnu_stmts))' in empty
          and 'Set_Has_No_Elaboration_Code (info->gnat_node, 1);\n      else' in empty
          and empty.count('rest_of_subprog_body_compilation (info->elab_proc);') == 1)
    function = sources['gcc/function.cc']
    check('nonnull_function_structure_consumes_definition_number',
          'return funcdef_no++;' in function
          and 'current_function_funcdef_no = get_next_funcdef_no ();' in function)
    helper = layout[layout.index('\nself_referential_size ('):layout.index('/* Take, queue and compile')]
    check('helper_declarations_use_input_location_and_body_is_unlocated',
          'build_decl (input_location, FUNCTION_DECL' in helper
          and 'build1 (RETURN_EXPR, void_type_node, t)' in helper)
    check('helper_body_input_location_from_function',
          'input_location = DECL_SOURCE_LOCATION (fndecl);' in gimplify)
    check('nonvoid_return_suppression_and_copy_landmarks',
          'suppress_warning (result, OPT_Wuninitialized);' in gimplify
          and 'copy_warning (ret, stmt);' in gimplify)
    check('conditional_arms_unlocated_and_labels_UNKNOWN',
          'build2 (INIT_EXPR, type, tmp, then_)' in gimplify
          and 'build2 (INIT_EXPR, type, tmp, else_)' in gimplify
          and 'label_true = create_artificial_label (UNKNOWN_LOCATION);' in gimplify)
    check('gimple_block_setters_are_call_or_debug_builders',
          [s.strip() for s in gimple.splitlines() if 'gimple_set_block (' in s]
          == ['gimple_set_block (call, TREE_BLOCK (t));',
              'gimple_set_block (p, block);', 'gimple_set_block (p, block);'])
    check('gimple_annotation_only_fills_missing_location',
          'if (!gimple_has_location (gs)' in gimple
          and 'gimple_set_location (gs, location);' in gimple)
    check('stored_location_copy_guard_not_a_no_warning_guard',
          'if (g->location != UNKNOWN_LOCATION)\n    copy_warning (location, g->location);'
          in sources['gcc/gimple.h'])
    check('warning_mutators_guard_reserved_destination',
          warnings.count('if (!RESERVED_LOCATION_P (loc))') >= 2
          and 'if (RESERVED_LOCATION_P (to_loc))' in warnings
          and 'if (RESERVED_LOCATION_P (to))' in locations)
    fold = sources['gcc/gimple-fold.cc']
    call_update = fold[fold.index('\nfinish_update_gimple_call ('):fold.index('/* Update a GIMPLE_CALL statement')]
    check('fold_block_location_setter_is_in_call_replacement',
          'gimple_set_block (new_stmt, gimple_block (stmt));' in call_update
          and fold.count('gimple_set_block (') == 1)
    ada_sites = []
    for path, source in sources.items():
        if '/gcc-interface/' in path:
            for line, text in enumerate(source.splitlines(), 1):
                if re.search(r'\b(?:copy_warning|suppress_warning|put_warning_spec_at)\s*\(', text):
                    ada_sites.append(dict(path=path, line=line, source=text.strip()))
    check('Ada_direct_warning_inventory_is_two_selected_sites',
          len(ada_sites) == 2
          and {r['source'] for r in ada_sites} == {'suppress_warning (decl);',
                                                  'suppress_warning (*expr_p);'})

    check('R_breakdown_sums_to_five', R_BOUND == 5 and sum(R_BREAKDOWN.values()) == 5
          and interface['R_put_call_ceiling'] == 5)
    sample = evaluate(1, 0)
    transfer = sample['conditional_map_transfer']
    check('smallest_family_transfer',
          transfer['original_gigi_put_call_ceiling'] == 7
          and transfer['incoming_live_or_occupied_ceiling'] == 4100
          and transfer['outgoing_live_or_occupied_ceiling'] == 4103
          and transfer['additive_GGC_event_ceiling'] == 11
          and transfer['incoming_capacity_ceiling'] == 16381
          and transfer['outgoing_capacity_ceiling'] == 16381)
    examples = [(1, 1), (2, 0), (2, 7), (10000, 137), (268434431, 0)]
    check('composed_formulas_agree', all(
        (t := evaluate(C, N)['conditional_map_transfer'])['original_gigi_put_call_ceiling'] == 2*C+N+5
        and t['outgoing_live_or_occupied_ceiling'] == 4099+4*C+N
        and t['additive_GGC_event_ceiling'] == 4*C+N+7 for C, N in examples))
    edge = evaluate(268434431, 0)['conditional_map_transfer']
    beyond = evaluate(268434432, 0)['conditional_map_transfer']
    check('accepted_occupancy_endpoint_and_failure',
          edge['outgoing_live_or_occupied_ceiling'] == 1073741823
          and edge['outgoing_capacity_ceiling'] == 2147483647
          and edge['conditional_map_interface_fits']
          and not beyond['conditional_map_interface_fits'])
    for C, N in ((0, 0), (-1, 0), (True, 0), (1, -1), (1, False), (1.0, 0)):
        try:
            evaluate(C, N)
        except ValueError:
            pass
        else:
            raise AssertionError(('invalid inputs accepted', C, N))
    check('invalid_inputs_rejected', True)
    check('empty_elaboration_and_helpers_have_separate_counter_join',
          interface['empty_elaboration']['function_structures_allocated'] == 1
          and interface['empty_elaboration']['persistent_function_definition_number_increment'] == 1
          and interface['cold_string_size_helpers']['persistent_function_definition_number_increment'] == 2
          and interface['non_Main_function_definition_number_increment'] == 3
          and interface['additional_emitted_functions_from_selected_constructor_frontier'] == 0)
    open_keys = ('complete_imported_frontier_capacity_closed',
                 'complete_gimplifier_lifetime_closed', 'complete_collector_lifetime_closed',
                 'whole_literal_pipeline_capacity_established')
    check('unrelated_capacity_obligations_remain_open',
          all(not sample[k] and not interface[k] for k in open_keys)
          and not interface['aggregate_conditions_changed'])

    now = datetime.now(timezone.utc)
    result = dict(status='pass', checked=checked, source_files_verified=len(sources),
                  historical_inputs_verified=len(history), direct_Ada_warning_sites=ada_sites,
                  scope='Source identity/landmarks and arithmetic; handwritten exhaustion requires review',
                  independent_review='pending', selected_model='GPT-6 Astra',
                  selected_effort='Extra High', runtime_confirmed_model=None,
                  runtime_confirmed_effort=None, token_usage=None, cost=None,
                  native_executions=0, host=platform.platform(),
                  round_start_utc='2026-10-18T20:20:35+00:00', completed_utc=now.isoformat(),
                  round_elapsed_seconds=int((now-datetime(2026, 10, 18, 20, 20, 35,
                                                         tzinfo=timezone.utc)).total_seconds()),
                  check_elapsed_seconds=round(time.monotonic()-start, 6))
    output = json.dumps(result, indent=2) + '\n'
    if args.output:
        args.output.write_text(output)
    print(output, end='')


if __name__ == '__main__':
    main()
