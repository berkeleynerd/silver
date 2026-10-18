#!/usr/bin/env python3
"""Offline identity/route checks for an explicitly unresolved imported frontier."""
import argparse
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import subprocess
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]


def require(value, message):
    if not value:
        raise AssertionError(message)


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
    impact = json.loads((HERE / 'dependency-impact.json').read_bytes())
    sources = {}
    for row in manifest['files']:
        relative = row['path'].removeprefix('gcc/ada/') if row['root'] == 'ada' else row['path']
        root = args.ada_root if row['root'] == 'ada' else args.gcc_root
        data = (root / relative).read_bytes()
        require(identity(data) == {k: row[k] for k in ('bytes', 'sha256')}, row['path'])
        blob = b'blob ' + str(len(data)).encode() + b'\0' + data
        require(hashlib.sha1(blob).hexdigest() == row['git_blob_sha1'], 'blob: ' + row['path'])
        sources[row['path']] = data.decode()
    historical = {}
    revision = manifest['reviewed_silver_revision']
    for row in manifest['historical_silver_inputs']:
        data = subprocess.check_output(['git', 'show', revision + ':' + row['path']], cwd=REPO)
        require(identity(data) == {k: row[k] for k in ('bytes', 'sha256')}, 'historical: ' + row['path'])
        historical[row['path']] = data.decode()

    checks = []

    def check(name, value):
        require(value, name)
        checks.append(name)

    for row in manifest['files']:
        origin = json.loads(historical[row['retained_identity_origin']])
        require(origin.get('commit', origin.get('source_commit')) == manifest['commit'],
                'historical GCC revision: ' + row['path'])
        require(any(old['bytes'] == row['bytes'] and old['sha256'] == row['sha256']
                    for old in origin['files']), 'historical source identity: ' + row['path'])
    check('all_source_identities_reuse_same_revision_retained_pins', True)

    ada = 'gcc/ada/'
    decl = sources[ada + 'gcc-interface/decl.cc']
    utils = sources[ada + 'gcc-interface/utils.cc']
    trans = sources[ada + 'gcc-interface/trans.cc']
    cstand = sources[ada + 'cstand.adb']
    tree = sources['gcc/tree.cc']
    layout = sources['gcc/stor-layout.cc']
    cgraph = sources['gcc/cgraphunit.cc']
    gimplify = sources['gcc/gimplify.cc']
    check('Standard_String_is_unconstrained_Positive_Character', all(s in cstand for s in (
        'Tdef_Node := New_Node (N_Unconstrained_Array_Definition, Stloc);',
        'Set_Component_Type  (Standard_String, Standard_Character);',
        'Set_Component_Size  (Standard_String, Uint_8);',
        'Set_Entity (E_Id, Standard_Positive);')))
    check('cstand_does_not_set_fixed_lower_bound_index_flag',
          'Set_Is_Fixed_Lower_Bound_Index_Subtype' not in cstand)
    check('String_template_conditional_uses_placeholder_bounds', all(s in decl for s in (
        'build0 (PLACEHOLDER_EXPR, gnu_fat_type)',
        'const bool is_flb = Is_Fixed_Lower_Bound_Index_Subtype (gnat_index_type);',
        'build3 (COND_EXPR, sizetype,',
        'gnu_orig_max, gnu_orig_min)',
        'tem = build_nonshared_array_type (tem, gnu_index_types[index]);')))
    array = tree[tree.index('\nbuild_array_type_1 ('):tree.index('/* Wrapper around build_array_type_1')]
    check('array_layout_precedes_shared_lookup',
          array.index('layout_type (t);') < array.index('if (shared)'))
    check('array_canonical_branch_reaches_another_array_builder',
          '= build_array_type_1 (TYPE_CANONICAL (elt_type),' in array)
    variable = layout[layout.index('\nvariable_size ('):layout.index('/* An array of functions')]
    check('placeholder_dispatch_precedes_global_binding_return',
          variable.index('CONTAINS_PLACEHOLDER_P (size)') < variable.index('global_bindings_p ()'))
    finalize = layout[layout.index('\nfinalize_type_size ('):layout.index('/* Handle empty records')]
    check('bit_and_byte_sizes_have_separate_variable_size_calls',
          finalize.count('= variable_size (TYPE_SIZE') == 2)
    helper = layout[layout.index('\nself_referential_size ('):layout.index('/* Take, queue and compile')]
    check('size_helper_simple_shape_and_SAVE_EXPR_abort_are_real_guards',
          'TREE_CODE (t) == CALL_EXPR || self_referential_component_ref_p (t)' in helper
          and 'if (walk_tree (&t, copy_self_referential_tree_r, NULL, NULL) != NULL_TREE)' in helper
          and 'else if (code == SAVE_EXPR)\n    return error_mark_node;' in layout)
    check('size_helper_builds_nonvoid_return_body_and_records_function', all(s in helper for s in (
        't = build2 (MODIFY_EXPR, return_type, DECL_RESULT (fndecl), size);',
        'DECL_SAVED_TREE (fndecl) = build1 (RETURN_EXPR, void_type_node, t);',
        'vec_safe_push (size_functions, fndecl);')))
    size_finalizer = layout[layout.index('\nfinalize_size_functions ('):layout.index('/* Return a machine mode')]
    check('size_finalizer_gimplifies_before_finalizing_each_helper',
          size_finalizer.index('gimplify_function_tree (fndecl);')
          < size_finalizer.index('cgraph_node::finalize_function (fndecl, false);'))
    unit_finalizer = cgraph[cgraph.index('\nsymbol_table::finalize_compilation_unit ('):]
    check('size_finalizer_precedes_ordinary_analysis',
          unit_finalizer.index('finalize_size_functions ();')
          < unit_finalizer.index('analyze_functions (/*first_time=*/true);'))
    check('simple_shape_scanner_only_follows_constant_sided_binary_nodes',
          'if (TREE_CONSTANT (TREE_OPERAND (expr, 1)))' in tree
          and 'else if (TREE_CONSTANT (TREE_OPERAND (expr, 0)))' in tree)
    object_record = utils[utils.index('\nbuild_unc_object_type ('):utils.index('/* Same, taking a pointer type')]
    check('object_record_finisher_receives_true_debug_argument',
          'finish_record_type (type, template_field, 0, true);' in object_record)
    check('parallel_variable_record_can_push_a_decl',
          'if (var_size && gnat_encodings == DWARF_GNAT_ENCODINGS_ALL)' in utils
          and 'gnat_pushdecl (TYPE_STUB_DECL (new_record_type), Empty);' in utils)
    check('generated_return_can_suppress_temporary_result',
          'suppress_warning (result, OPT_Wuninitialized);' in gimplify)
    check('fresh_temporary_uses_input_location',
          'tmp_var = build_decl (input_location,' in sources['gcc/gimple-expr.cc'])
    check('Standard_location_is_reserved_but_body_resets_input_from_function',
          '*locus = BUILTINS_LOCATION;' in trans
          and 'input_location = DECL_SOURCE_LOCATION (fndecl);' in gimplify)
    check('location_warning_copy_has_no_no_warning_bit_guard',
          'if (g->location != UNKNOWN_LOCATION)\n    copy_warning (location, g->location);'
          in sources['gcc/gimple.h'])

    aggregate = historical['docs/evidence/retained-literal-pipeline-20261018/compose.py']
    check('historical_pool_graph_closure_fields_are_arithmetic_only', all(s in aggregate for s in (
        'named_consumer_closed=all(checks.values())',
        'conditional_graph_and_summary_lifetime_closed=all(checks.values())',
        'function_summary_ID_high_water_upper=1',
        'optimized_or_inlined_body_copies=0,additional_registered_symbols=0')))
    pipeline = historical['docs/research/retained-literal-pipeline.md']
    check('historical_pipeline_contains_identified_absence_claims',
          'there is no self-referential size-function\nbody.' in pipeline
          and 'Main remains the only defined function body.' in pipeline)
    ingress = historical['docs/research/retained-native-ingress-bound.md']
    check('historical_ingress_leaves_original_gigi_separate',
          'Original gigi constructions, shared caches/maps and complete compiler lifetime\nremain separate obligations.' in ingress)
    check('frontier_does_not_promote_hypothesis_to_R_or_absence',
          impact['reviewed_silver_revision'] == revision
          and impact['original_gigi_residual_R'] is None
          and all(impact[k] is False for k in (
              'original_gigi_source_count_closed', 'imported_size_function_creation_observed',
              'imported_size_function_absence_established', 'extra_function_emission_absence_established',
              'whole_literal_pipeline_capacity_established'))
          and impact['native_tool_executions'] == 0)
    completed = datetime.now(timezone.utc)
    round_start = datetime(2026, 10, 18, 19, 49, 28, tzinfo=timezone.utc)
    result = dict(
        status='passed; source-shape decision and R remain unresolved',
        source_files_verified=len(sources), historical_inputs_verified=len(historical),
        source_and_scope_checks=checks, check_count=len(checks),
        original_gigi_residual_R=None, native_tool_executions=0,
        imported_size_function_creation_observed=False,
        imported_size_function_absence_established=False,
        round_completion_utc=completed.strftime('%Y-%m-%d %H:%M:%S UTC'),
        round_elapsed_seconds=int((completed-round_start).total_seconds()),
        offline_check_elapsed_seconds=round(time.monotonic()-start, 4),
        selected_model='GPT-6 Astra', selected_reasoning_effort='Extra High',
        runtime_confirmed_model=None, runtime_confirmed_reasoning_effort=None,
        token_measurement=None, cost_measurement=None)
    if args.output:
        args.output.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps(result, indent=2))


if __name__ == '__main__':
    main()
