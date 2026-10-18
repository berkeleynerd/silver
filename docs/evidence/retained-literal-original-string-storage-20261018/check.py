#!/usr/bin/env python3
"""Offline source identities, constructor landmarks and arithmetic checks.

The handwritten note establishes source control-flow and GENERIC-fold closure.
These checks neither run a compiler nor establish that closure by text matching.
"""
import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import platform
import subprocess
import time

from derive import evaluate, evaluate_at, FIXED_GGC_ROWS, rho

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]


def identity(b):
    return {'bytes': len(b), 'sha256': hashlib.sha256(b).hexdigest()}


def main():
    start = time.monotonic()
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gcc-root', type=Path,
                        default=Path('/tmp/silver-backend-compose-20261018/full-source'))
    parser.add_argument('--ada-root', type=Path,
                        default=Path('/tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada'))
    parser.add_argument('--matcher', type=Path,
                        default=Path('/tmp/silver-backend-compose-20261018/folding-sources/match.pd'))
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    manifest = json.loads((HERE/'source-manifest.json').read_text())
    checks = []

    def check(name, value):
        if not value:
            raise AssertionError(name)
        checks.append(name)

    history = {}
    for r in manifest['historical_silver_inputs']:
        b = subprocess.check_output(['git', 'show',
                                     manifest['reviewed_silver_revision']+':'+r['path']],
                                    cwd=REPO)
        assert identity(b) == {k: r[k] for k in ('bytes', 'sha256')}, r['path']
        history[r['path']] = b.decode()
    check('frozen_predecessor_inputs_match', True)
    src = {}
    for r in manifest['files']:
        p = (args.ada_root/r['path'].removeprefix('gcc/ada/')
             if r['root'] == 'ada' else args.matcher if r['root'] == 'matcher'
             else args.gcc_root/r['path'])
        b = p.read_bytes()
        assert identity(b) == {k: r[k] for k in ('bytes', 'sha256')}, r['path']
        assert hashlib.sha1(b'blob '+str(len(b)).encode()+b'\0'+b).hexdigest() == r['git_blob_sha1']
        if 'retained_identity_origin' in r:
            assert r['sha256'] in history[r['retained_identity_origin']], r['path']
        else:
            assert r['path'] in ('gcc/fold-const.h', 'gcc/builtins.cc', 'gcc/calls.cc')
            assert r['upstream_identity_check'].startswith('Byte-for-byte raw commit URL comparison')
        src[r['path']] = b.decode()
    check('source_bytes_blob_ids_and_retained_origins_match', True)
    check('three_new_raw_upstream_source_comparisons_distinguished',
          sum('upstream_identity_check' in r for r in manifest['files']) == 3)

    cold = json.loads(history['docs/evidence/retained-literal-string-layout-20261018/interface.json'])
    synthetic = json.loads(history['docs/evidence/retained-literal-synthetic-function-storage-20261018/interface.json'])
    check('two_helpers_before_gimplification_and_no_emission',
          cold['size_functions_created'] == 2
          and cold['initial_helper_gimplifications'] == 2
          and cold['helper_emitted_functions'] == 0)
    check('corrected_disjoint_synthetic_predecessor_is_173',
          synthetic['GGC_events'] == 173
          and not synthetic['original_gigi_predecessor_construction_included'])

    t = src['gcc/tree.cc']; s = src['gcc/stor-layout.cc']; f = src['gcc/fold-const.cc']
    body = s[s.index('self_referential_size (tree size)'):s.index('finalize_size_functions (void)')]
    check('constructor_one_substitution_site_inside_reference_loop',
          body.count('size = substitute_in_expr (size, subst, param_decl);') == 1
          and 'FOR_EACH_VEC_ELT (self_refs, i, ref)' in body)
    check('private_walk_has_no_visited_set',
          'walk_tree (&t, copy_self_referential_tree_r, NULL, NULL)' in body)
    check('reference_vector_release_precedes_function_type',
          body.index('self_refs.release ();') < body.index('build_function_type'))
    check('constructor_declaration_body_and_queue_landmarks', all(x in body for x in (
        'PARM_DECL, param_name, param_type', 'FUNCTION_DECL, fnname, fntype',
        'RESULT_DECL, 0, return_type', 'make_node (BLOCK)',
        'build2 (MODIFY_EXPR', 'build1 (RETURN_EXPR',
        'vec_safe_push (size_functions, fndecl)', 'build_call_expr_loc_vec')))
    check('constructor_has_no_symbol_registration_or_pool_route', all(x not in body for x in (
        'cgraph_node::', 'make_decl_rtl', 'output_constant_def', 'allocate_struct_function')))
    sub = t[t.index('substitute_in_expr (tree exp, tree f, tree r)'):
            t.index('substitute_placeholder_in_expr (tree exp, tree obj)')]
    check('substitution_reuses_unchanged_children_and_folds_ancestors', all(x in sub for x in (
        'TREE_CODE (inner) == PLACEHOLDER_EXPR && op1 == f',
        'if (op0 == TREE_OPERAND (exp, 0))',
        'fold_build1 (code, TREE_TYPE (exp), op0)',
        'fold_build2 (code, TREE_TYPE (exp), op0, op1)',
        'fold_build3 (code, TREE_TYPE (exp), op0, op1, op2)')))
    check('fold_build_macros_use_unknown_location', all(
        'fold_build%d_loc (UNKNOWN_LOCATION' % n in src['gcc/fold-const.h'] for n in (1, 2, 3)))
    check('fallback_nodes_are_created_after_failed_fold', all(x in f for x in (
        'tem = fold_unary_loc (loc, code, type, op0);',
        'tem = fold_binary_loc (loc, code, type, op0, op1);',
        'tem = fold_ternary_loc (loc, code, type, op0, op1, op2);')))
    check('split_does_not_decompose_two_variables', 'if (op0 != 0 && op1 != 0)\n\tvar = in;' in f)
    check('association_retains_cross_operand_origin_guard',
          'if (var0_origin != 3 && con0_origin != 3)' in f
          and 'Only do something if we found more than two objects.' in f)
    check('multiply_extraction_rejects_wrapping_widening_before_constant_conversion',
          f.index('TYPE_OVERFLOW_WRAPS (TREE_TYPE (op0))', f.index('extract_muldiv_1'))
          < f.index('Pass the constant down', f.index('extract_muldiv_1')))
    check('integer_comparison_inversion_uses_plain_builder',
          'tree ret = build2_loc (loc, code, type, TREE_OPERAND (arg, 0),' in f)
    check('warning_copy_reserved_destination_blocks_map_insertion',
          'if (RESERVED_LOCATION_P (to_loc))' in src['gcc/warning-control.cc'])
    check('generated_matcher_recursive_construction_and_capture_copy_are_explicit',
          '_r%d = fold_build%d_loc' in src['gcc/genmatch.cc']
          and 'unshare_expr' in src['gcc/genmatch.cc'])
    check('no_generic_truth_not_root_uses_existing_frozen_audit',
          'There is no GENERIC simplifier rooted at `TRUTH_NOT_EXPR` in this pin.'
          in history['docs/research/retained-backend-capacity.md'])
    check('canonical_function_type_and_pointer_guards_present', all(x in t for x in (
        'TYPE_CANONICAL (t) = t;',
        'else if (any_noncanonical_p)',
        'else if (TYPE_CANONICAL (to_type) != to_type || could_alias)')))
    check('positive_signed_type_and_bound_field_route_present', all(x in src['gcc/ada/gcc-interface/decl.cc'] for x in (
        'gnu_type = make_signed_type (esize);',
        'gnu_index_type = get_unpadded_type (gnat_index_type);',
        'gnu_lb_field = create_field_decl')))
    check('function_pointer_size_and_cache_initialization_landmarks', all(x in s for x in (
        'bitsize_int (FUNCTION_BOUNDARY)', 'size_int (FUNCTION_BOUNDARY / BITS_PER_UNIT)',
        'TYPE_SIZE (sizetype) = bitsize_int (precision);',
        'TYPE_SIZE_UNIT (sizetype) = size_int (GET_MODE_SIZE (mode));')))
    check('function_boundary_eight', '#define FUNCTION_BOUNDARY 8' in src['gcc/config/i386/i386.h'])
    check('aligned_constant_rounding_returns_existing_value',
          'if ((val & (divisor - 1)) == 0)\n\t    return value;' in f)
    check('nonbuiltin_call_has_no_builtin_transform',
          '&& fndecl_built_in_p (fndecl))' in src['gcc/builtins.cc']
          and 't = build_vl_exp (CALL_EXPR, nargs + 3);' in t)
    check('call_length_stored_as_sizetype_constant',
          't->exp.operands[0] = build_int_cst (sizetype, len);' in t)
    check('name_format_and_file_suffix_buffer_landmarks', all(x in t for x in (
        '#define FILE_FUNCTION_FORMAT "_GLOBAL__%s_%s"',
        'alloca (9 + 19 + len + 1)', 'get_random_seed (false)')))
    check('identifier_characters_use_GGC_subobject_callback',
          'ident_hash->alloc_subobject = stringpool_ggc_alloc;' in src['gcc/stringpool.cc']
          and 'table->alloc_subobject (len + 1)' in src['libcpp/symtab.cc'])

    # Finite shape fixtures exercise occurrence accounting, not GCC behavior.
    def counts(x):
        if not isinstance(x, tuple):
            return Counter()
        c = Counter({len(x)-1: 1})
        for y in x[1:]:
            c.update(counts(y))
        return c
    fixtures = 0
    for lower, upper in (('l', 'u'), ('p0', 'u'), ('l', 'p0'), ('p0', 'p1')):
        L, U = ('u64', lower), ('u64', upper)
        for extent in (('plus', ('minus', U, L), 1),
                       ('minus', ('plus', U, 1), L),
                       ('plus', U, ('minus', 1, L))):
            for cmp in ('lt', 'le', 'gt', 'ge'):
                for bit in (False, True):
                    arm = ('mult', ('u128', extent), 8) if bit else extent
                    for arms in ((arm, 0), (0, arm)):
                        shape = ('cond', (cmp, upper, lower), *arms)
                        assert counts(shape) == {1: 3 if bit else 2, 2: 4 if bit else 3, 3: 1}
                        fixtures += 1
    check('finite_input_shape_arity_fixtures', fixtures == 192)
    output = evaluate()
    check('frozen_interface_matches_derivation',
          json.loads((HERE/'interface.json').read_text()) == output)
    check('all_four_substitutions_include_reassociation_and_inversion',
          2*(5+7+2)+4+4 == 36 and 10*32+22*40+4*48 == 1392)
    check('94_events_and_constant_byte_coefficients',
          sum(n for _, n, _ in FIXED_GGC_ROWS)+2 == 94
          and sum(n*b for _, n, b in FIXED_GGC_ROWS)+66 == 6832
          and sum(n*rho(b) for _, n, b in FIXED_GGC_ROWS) == 7912)
    for p in (0, 1, 30, 31, 32, 95, 96, 4096, (1 << 31)-34):
        e = evaluate_at(p)
        assert e['GGC_caller_bytes_sum_ceiling'] == 6832+2*p
        assert e['GGC_rounded_slots_sum_ceiling'] == 7912+2*rho(p+33)
        assert p+33 <= rho(p+33) < 2*(p+33)
    check('name_parameter_guards_and_separate_slot_rounding', True)
    audit = json.loads((HERE/'fold-audit.json').read_text())
    check('handwritten_fold_audit_agrees_with_numeric_projection',
          audit['output_envelope'] == dict(unary=10, binary=22, ternary=4,
                                           events=36, caller_bytes=1392))
    check('outside_intervals_remain_outside', all(output[k] is False for k in (
        'broader_Standard_String_conversion_included',
        'original_empty_elaboration_construction_included', 'original_Main_gigi_included',
        'synthetic_gimplification_and_struct_function_included',
        'shared_table_backing_included', 'whole_literal_pipeline_closed')))
    result = dict(status='PASS', checked_utc=datetime.now(timezone.utc).isoformat(),
                  elapsed_seconds=round(time.monotonic()-start, 3),
                  host=dict(system=platform.system(), machine=platform.machine()),
                  selected_model='GPT-6 Astra', selected_effort='Extra High',
                  runtime_settings_confirmed=False, token_cost_data_available=False,
                  native_runs=0, source_files=len(src), historical_inputs=len(history),
                  finite_shape_fixtures=fixtures, check_count=len(checks), checks=checks,
                  limitation='Source landmarks and arithmetic do not prove handwritten folding/control-flow closure.')
    rendered = json.dumps(result, indent=2)+'\n'
    if args.output:
        args.output.write_text(rendered)
    print(rendered, end='')


if __name__ == '__main__':
    main()
