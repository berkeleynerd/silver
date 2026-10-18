#!/usr/bin/env python3
"""Offline identity, route-landmark, helper-shape and request arithmetic checks.

The handwritten source argument supplies control-flow closure. Landmarks and
the matcher inventory do not prove that closure. No native program is run.
"""
import argparse
from collections import Counter
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import platform
import re
import subprocess
import time

from derive import evaluate, GGC_ROWS, ORDINARY_ROWS, rounded

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]


def identity(b):
    return {'bytes': len(b), 'sha256': hashlib.sha256(b).hexdigest()}


def matcher_inventory(source):
    """Audit aid: flat simplify patterns after optional unary-node removal.

    Does not resolve for/operator lists or matcher predicates, and does not
    interpret C++ conditions. Original lines/patterns remain review inputs.
    """
    text = re.sub(r'/\*.*?\*/', lambda m: ' ' * len(m[0]), source, flags=re.S)
    rows = []
    for match in re.finditer(r'\(simplify\s*', text):
        start = match.end()
        if text[start] != '(':
            continue
        depth = 0
        for end in range(start, len(text)):
            depth += (text[end] == '(') - (text[end] == ')')
            if depth == 0:
                break
        pattern = text[start:end+1]
        flat = pattern
        while True:
            reduced = re.sub(r'\((?:\w+(?::[a-z]+)?)\?[^ ()]* ([^()]*)\)',
                             r'\1', flat)
            if reduced == flat:
                break
            flat = reduced
        if flat.count('(') == 1:
            rows.append({'line': source.count('\n', 0, start)+1,
                         'pattern': ' '.join(pattern.split()),
                         'optional_nodes_removed': pattern != flat})
    return rows


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
    manifest = json.loads((HERE / 'source-manifest.json').read_bytes())
    checked = []

    def check(name, value):
        if not value:
            raise AssertionError(name)
        checked.append(name)

    history = {}
    for row in manifest['historical_silver_inputs']:
        b = subprocess.check_output(['git', 'show',
                                     manifest['reviewed_silver_revision']+':'+row['path']],
                                    cwd=REPO)
        assert identity(b) == {k: row[k] for k in ('bytes', 'sha256')}, row['path']
        history[row['path']] = b.decode()
    check('historical_inputs_match_frozen_base', True)
    sources = {}
    for row in manifest['files']:
        p = (args.ada_root / row['path'].removeprefix('gcc/ada/')
             if row['root'] == 'ada' else args.matcher
             if row['root'] == 'matcher' else args.gcc_root / row['path'])
        b = p.read_bytes()
        assert identity(b) == {k: row[k] for k in ('bytes', 'sha256')}, row['path']
        assert hashlib.sha1(b'blob '+str(len(b)).encode()+b'\0'+b).hexdigest() == row['git_blob_sha1']
        if 'retained_identity_origin' in row:
            assert row['sha256'] in history[row['retained_identity_origin']], row['path']
        else:
            assert row['path'] in ('gcc/gimple-match-head.cc', 'gcc/value-range.cc')
            assert row['upstream_identity_check'].startswith('Byte-for-byte raw commit URL comparison')
        sources[row['path']] = b.decode()
    check('source_bytes_and_blob_ids_match_manifest', True)
    check('new_source_pins_distinguished_from_retained_pins',
          sum('upstream_identity_check' in r for r in manifest['files']) == 2)
    cold = json.loads(history['docs/evidence/retained-literal-string-layout-20261018/interface.json'])
    check('frozen_two_helper_and_no_emission_interface',
          cold['size_functions_created'] == 2
          and cold['initial_helper_gimplifications'] == 2
          and cold['helper_emitted_functions'] == 0)

    g = sources['gcc/gimplify.cc']
    f = sources['gcc/function.cc']
    fold = sources['gcc/gimple-fold.cc']
    layout = sources['gcc/stor-layout.cc']
    check('one_elaboration_structure_constructor',
          sources['gcc/ada/gcc-interface/trans.cc'].count(
              'allocate_struct_function (gnu_elab_proc_decl, false);') == 1)
    check('helper_finalize_orders_structure_then_gimplification',
          layout.index('allocate_struct_function (fndecl, false);', layout.index('finalize_size_functions (void)'))
          < layout.index('gimplify_function_tree (fndecl);', layout.index('finalize_size_functions (void)')))
    check('function_EH_machine_and_counter_landmarks',
          all(s in f for s in ['ggc_cleared_alloc<function> ();',
                              'init_eh_for_function ();',
                              'cfun->machine = (*init_machine_status) ();',
                              'current_function_funcdef_no = get_next_funcdef_no ();']))
    check('EH_two_zero_vectors', all(s in sources['gcc/except.cc'] for s in [
        'vec_safe_push (cfun->eh->region_array, (eh_region)0);',
        'vec_safe_push (cfun->eh->lp_array, (eh_landing_pad)0);']))
    check('O2_speed_alignment_defaults',
          all('OPT_LEVELS_2_PLUS_SPEED_ONLY, OPT_falign_'+k in sources['gcc/opts.cc']
              for k in ('functions', 'jumps', 'labels', 'loops')))
    parse = sources['gcc/toplev.cc'].split('\nparse_N_M (', 1)[1].split('/* Process -falign-', 1)[0]
    check('alignment_cache_construction_guarded_by_nonnull_string',
          parse.index('if (flag)') < parse.index('static hash_map'))
    check('default_target_change_guards',
          'if (old_tree != new_tree || fp_flag_change)' in sources['gcc/config/i386/i386-options.cc'])
    check('SSA_initial_hash_and_name_reservation',
          'hash_table<ssa_name_hasher>::create_ggc (20)' in sources['gcc/tree-ssa.cc']
          and 'vec_alloc (SSANAMES (fn), 50);' in sources['gcc/tree-ssanames.cc'])
    check('parameter_vector_released_and_callee_copy_guarded',
          'fnargs.release ();' in f and 'if (data.arg.pass_by_reference)' in f)
    check('three_return_ABI_query_routes_per_helper', all(s in f for s in [
        'if (!abstract_p && aggregate_value_p (result, fndecl))',
        'if (aggregate_value_p (DECL_RESULT (fndecl), fndecl)',
        'fnargs = assign_parms_augmented_arg_list (&all);'])
        and 'else if (aggregate_value_p (result_decl, TREE_TYPE (current_function_decl)))' in g
        and 'bind = gimplify_body (fndecl, true);' in g)
    aggregate = f.split('\naggregate_value_p (', 1)[1].split('\n/* Return true if we should assign', 1)[0]
    check('void_ABI_query_exits_before_hard_value',
          aggregate.index('if (VOID_TYPE_P (type))') < aggregate.index('reg = hard_function_value'))
    i386 = sources['gcc/config/i386/i386.cc']
    md = sources['gcc/config/i386/i386.md']
    check('SysV64_DI_TI_single_REG_fast_paths',
          'AX_REG, DX_REG, DI_REG, SI_REG' in i386
          and re.search(r'\(AX_REG\s+0\)', md)
          and re.search(r'\(DX_REG\s+1\)', md)
          and '&& intreg[0] + 1 == intreg[1])' in i386
          and 'return gen_rtx_REG (mode, intreg[0]);' in i386
          and 'return function_value_64 (orig_mode, mode, valtype);' in i386)
    emit = sources['gcc/emit-rtl.cc']
    reg = emit.split('\ngen_rtx_REG (', 1)[1].split('\nrtx\ngen_rtx_MEM', 1)[0]
    check('ordinary_hard_register_cache_disabled',
          '#if 0' in reg
          and reg.index('#if 0') < reg.index('return regno_reg_rtx[regno];') < reg.index('#endif', reg.index('#if 0'))
          and 'return gen_raw_REG (mode, regno);' in reg)
    check('REG_direct_GGC_constructor_and_size_rule',
          'rtx x = rtx_alloc (REG MEM_STAT_INFO);' in emit
          and 'ggc_alloc_rtx_def_stat (RTX_CODE_SIZE (code) + extra' in sources['gcc/rtl.cc']
          and '? RTX_HDR_SIZE + sizeof (reg_info)' in sources['gcc/rtl.cc']
          and 'reg_attrs *attrs;' in sources['gcc/rtl.h']
          and 'val = targetm.calls.function_value (valtype, func ? func : fntype, outgoing);' in sources['gcc/explow.cc'])
    check('unshare_hash_allocated_and_deleted',
          'lang_hooks.deep_unsharing ? new hash_set<tree> : NULL;' in g
          and 'delete visited;' in g)
    check('SSA_materialization_and_INIT_free',
          't = make_ssa_name (TYPE_MAIN_VARIANT (TREE_TYPE (val)));' in g
          and 'mod = build2 (INIT_EXPR, TREE_TYPE (t), t, unshare_expr (val));' in g
          and 'ggc_free (mod);' in g)
    check('conditional_distribution_reuses_destination',
          '(is_gimple_reg (*to_p) && !gimplify_ctxp->allow_rhs_cond_expr)' in g
          and 'tree result = *to_p;' in g)
    check('outer_BIND_created_after_body',
          g.index('gimplify_stmt (&DECL_SAVED_TREE (fndecl), &seq);')
          < g.index('outer_bind = gimple_build_bind (NULL_TREE, seq, NULL);'))
    check('fold_uses_no_follow_callback',
          'return fold_stmt_1 (gsi, false, no_follow_ssa_edges, dce_bitmap);' in fold
          and 'no_follow_ssa_edges (tree)\n{\n  return NULL_TREE;' in fold)
    check('matcher_refuses_definition_at_null_callback',
          'if (valueize && ! valueize (name))\n    return NULL;' in sources['gcc/gimple-match-head.cc'])
    check('unary_and_binary_legacy_fold_are_empty',
          'case GIMPLE_UNARY_RHS:\n      break;\n\n    case GIMPLE_BINARY_RHS:\n      break;' in fold)
    check('same_arity_assignment_reuses_storage',
          'if (gimple_num_ops (stmt) < new_rhs_ops + 1)' in sources['gcc/gimple.cc'])
    check('global_range_query_reuses_global_instance',
          'return (fun && fun->x_range_query) ? fun->x_range_query : &global_ranges;' in sources['gcc/value-query.h'])
    check('Boolean_range_predicate_uses_fixed_pair_storage',
          'int_range<2> r;' in sources['gcc/tree-ssanames.cc']
          and 'template<unsigned N, bool RESIZABLE = false>' in sources['gcc/value-range.h']
          and 'return int_range<1> (type, wi::zero (prec), wi::one (prec));' in sources['gcc/range.h'])
    check('context_pool_reuse_and_chain_declaration',
          'c = XNEW (struct gimplify_ctx);' in g
          and 'ctx_free (c);' in g and 'declare_vars (c->temps, body, false);' in g)
    check('temporary_name_counter_and_private_format',
          'static GTY(()) unsigned int tmp_var_id_num;' in sources['gcc/gimple-expr.cc']
          and '"__%s_%lu"' in sources['gcc/defaults.h'])
    check('body_release_disposes_SSA_and_function',
          'delete_tree_ssa (fn);' in sources['gcc/cgraph.cc']
          and 'ggc_free (fn);' in sources['gcc/cgraph.cc'])

    # Count ordinary occurrence arities from the frozen abstract body, cutting
    # at scalar identities/constants. This is not a parse of GCC's output.
    U, L = ('NOP', 'u'), ('NOP', 'l')
    extent = ('PLUS', ('MINUS', U, L), 'one')
    body = lambda e: ('RETURN', ('MODIFY', 'result', ('COND', ('GE', 'u', 'l'), e, 'zero')))
    def counts(node):
        c = Counter()
        if isinstance(node, tuple):
            c[len(node)-1] += 1
            for child in node[1:]:
                c.update(counts(child))
        return c
    byte = counts(body(extent))
    bit = counts(body(('MULT', ('NOP', extent), 'eight')))
    check('body_occurrence_dimensions', byte == {1: 3, 2: 4, 3: 1}
          and bit == {1: 4, 2: 5, 3: 1})
    check('whole_body_copy_projection',
          3*(byte[1]+bit[1]) == 21 and 3*(byte[2]+bit[2]) == 27
          and 3*(byte[3]+bit[3]) == 6)
    result = evaluate()
    check('interface_matches_callable', result == json.loads((HERE/'interface.json').read_bytes()))
    check('event_and_individual_size_sums',
          result['GGC_events'] == 173 and result['GGC_caller_bytes_sum_ceiling'] == 13480
          and result['GGC_rounded_slots_sum_ceiling'] == 17408
          and result['ordinary_requests'] == 8 and result['ordinary_caller_bytes_sum_ceiling'] == 584)
    queries = result['return_ABI_queries']
    check('six_REG_correction_and_unchanged_nonREG_subtotal',
          2*sum(queries[k] for k in ('allocate_struct_function_per_helper',
                                    'gimplify_parameters_per_helper',
                                    'gimplify_return_expr_per_helper')) == queries['hard_function_value_calls'] == 6
          and ('return_ABI_hard_REG', 6, 24) in GGC_ROWS
          and sum(n for k,n,_ in GGC_ROWS if k != 'return_ABI_hard_REG') == 167
          and queries['PARALLEL_objects'] == queries['rtvec_objects'] == queries['pseudo_register_numbers'] == 0)
    check('GIMPLE_tuple_projection',
          sum(n for k,n,_ in GGC_ROWS if k.startswith('GIMPLE_')) == 28)
    check('rounding_each_object_not_the_subtotal',
          all(b <= rounded(b) < 2*b for _, _, b in GGC_ROWS)
          and result['GGC_rounded_slots_sum_ceiling'] == sum(n*rounded(b) for _,n,b in GGC_ROWS))
    check('fixed_vectors_and_counter_room',
          max(result['identity_demands']['SSA_name_vector_length_per_helper']) <= 50
          and result['shared_container_demands']['default_def_hash_capacity_each'] < 32
          and result['identity_demands']['tmp_var_id_num_incoming_max']+10 == 2**32-1)
    check('shared_resources_exported_and_exclusions_not_zeroed',
          result['shared_container_demands']['identifier_new_entries_ceiling'] == 10
          and result['shared_container_demands']['singleton_finalizer_registrations'] == 2
          and not result['original_gigi_predecessor_construction_included']
          and not result['collector_page_and_finalizer_backing_included']
          and not result['whole_literal_pipeline_closed'])
    inventory = matcher_inventory(sources['gcc/match.pd'])
    check('flat_pattern_inventory_matches_retained_audit',
          inventory == json.loads((HERE/'matcher-flat-patterns.json').read_bytes()))
    check('direct_pattern_landmarks_in_inventory',
          {238,293,305,500,2201,2211,2497,5722,6037,6045,6061,7367,7377,7544,7555,7562,7566,7569}
          <= {r['line'] for r in inventory})

    report = dict(status='pass', checks=len(checked), checked=checked,
                  source_files=len(manifest['files']),
                  historical_inputs=len(manifest['historical_silver_inputs']),
                  flat_matcher_patterns=len(inventory), native_runs=0,
                  host=dict(system=platform.system(), release=platform.release(), machine=platform.machine()),
                  selected_model='GPT-6 Astra', selected_effort='Extra High',
                  runtime_model_effort_confirmation=None, tokens=None, cost=None,
                  elapsed_seconds=round(time.monotonic()-start,3),
                  completed_utc=datetime.now(timezone.utc).isoformat(),
                  scope='offline identity/landmark/arithmetic checks; handwritten source argument required')
    if args.output:
        args.output.write_text(json.dumps(report, indent=2)+'\n')
    print(json.dumps(report, indent=2))


if __name__ == '__main__':
    main()
