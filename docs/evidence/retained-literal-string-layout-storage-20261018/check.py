#!/usr/bin/env python3
"""Offline identities, source landmarks, arithmetic and scalar fold fixtures.

The research note supplies the source-specialized control-flow and fold closure.
Text landmarks and finite fixtures corroborate it; they do not prove it.
No native compiler, build, prover, full test or network request is run here.
"""
import argparse
import ctypes
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import platform
import subprocess
import time

from derive import CONSTANT_ROWS, FIXED_ROWS, NAMES, evaluate, rho

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]


def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def dictionaries(value):
    if isinstance(value, dict):
        yield value
        for child in value.values():
            yield from dictionaries(child)
    elif isinstance(value, list):
        for child in value:
            yield from dictionaries(child)


def main():
    started = time.monotonic()
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--gcc-root', type=Path,
                        default=Path('/tmp/silver-backend-compose-20261018/full-source'))
    parser.add_argument('--ada-root', type=Path,
                        default=Path('/tmp/silver-unbounded-continuation-20261017/upstream-gcc/gcc/ada'))
    parser.add_argument('--matcher', type=Path,
                        default=Path('/tmp/silver-backend-compose-20261018/folding-sources/match.pd'))
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    checks = []

    def check(name, condition):
        if not condition:
            raise AssertionError(name)
        checks.append(name)

    manifest = json.loads((HERE / 'source-manifest.json').read_text())
    history = {}
    for row in manifest['historical_silver_inputs']:
        data = subprocess.check_output(
            ['git', 'show', manifest['reviewed_silver_revision'] + ':' + row['path']],
            cwd=REPO)
        assert identity(data) == {k: row[k] for k in ('bytes', 'sha256')}, row['path']
        history[row['path']] = data.decode()
    check('fourteen_frozen_Silver_inputs_match', len(history) == 14)

    sources = {}
    new_raw = set()
    for row in manifest['files']:
        path = (args.ada_root / row['path'].removeprefix('gcc/ada/')
                if row['root'] == 'ada' else args.matcher if row['root'] == 'matcher'
                else args.gcc_root / row['path'])
        data = path.read_bytes()
        assert identity(data) == {k: row[k] for k in ('bytes', 'sha256')}, row['path']
        assert hashlib.sha1(b'blob ' + str(len(data)).encode() + b'\0' + data).hexdigest() == row['git_blob_sha1']
        assert row['url'] == ('https://raw.githubusercontent.com/gcc-mirror/gcc/'
                              + manifest['commit'] + '/' + row['path'])
        if 'retained_identity_origin' in row:
            origin = json.loads(history[row['retained_identity_origin']])
            assert any(r.get('path') == row['path'] and r.get('sha256') == row['sha256']
                       for r in dictionaries(origin)), row['path']
        else:
            assert row['upstream_identity_check'].startswith('Byte-for-byte raw commit URL comparison')
            new_raw.add(row['path'])
        sources[row['path']] = data.decode()
    check('34_source_bytes_blob_ids_and_identity_origins_match', len(sources) == 34)
    check('six_new_raw_comparisons_are_distinguished_from_reused_identity',
          new_raw == {'gcc/ada/' + name for name in
                      ('layout.adb', 'exp_dbug.adb', 'namet.ads', 'namet.adb',
                       'opt.ads', 'uintp.ads')})

    def lines(path, first, last):
        # GCC uses form-feed page separators; only LF advances source line numbers.
        return '\n'.join(sources[path].split('\n')[first - 1:last])

    def ada(name):
        return sources['gcc/ada/gcc-interface/' + name]

    trans, decl, utils = (ada(name) for name in ('trans.cc', 'decl.cc', 'utils.cc'))
    fold = sources['gcc/fold-const.cc']
    stor = sources['gcc/stor-layout.cc']
    check('startup_associates_base_Integer_and_Character', all(s in lines(
        'gcc/ada/gcc-interface/trans.cc', 398, 438) for s in (
            'save_gnu_tree (Base_Type (standard_integer)',
            'finish_character_type (char_type_node)',
            'save_gnu_tree (Base_Type (standard_character)')))
    check('Character_finisher_has_no_alias_query',
          'get_alias_set' not in lines('gcc/ada/gcc-interface/utils.cc', 2113, 2155))
    check('Positive_has_Integer_base_and_explicit_RM_bounds', all(s in lines(
        'gcc/ada/cstand.adb', 1040, 1053) for s in (
            'E_Signed_Integer_Subtype', 'Base_Type (Standard_Integer)',
            'Standard_Integer_Size - 1', 'Lb  => Uint_1',
            'High_Bound (Scalar_Range (Standard_Integer))')))
    check('selected_GDB_default_is_shared_with_Ada',
          '#define DWARF_GNAT_ENCODINGS_DEFAULT DWARF_GNAT_ENCODINGS_GDB'
          in sources['gcc/defaults.h']
          and 'gnat_encodings = DWARF_GNAT_ENCODINGS_DEFAULT' in sources['gcc/common.opt']
          and 'pragma Import (C, GNAT_Encodings, "gnat_encodings")' in sources['gcc/ada/opt.ads'])
    check('XUT_finisher_debug_true_requires_encoding_gate',
          'finish_record_type (type, template_field, 0, true);'
          in lines('gcc/ada/gcc-interface/utils.cc', 4562, 4583)
          and 'if (var_size && gnat_encodings == DWARF_GNAT_ENCODINGS_ALL)' in utils)
    check('named_types_reuse_existing_stubs',
          'if (!is_named && TYPE_STUB_DECL (type))' in utils
          and 'type_decl = TYPE_STUB_DECL (type);' in utils)
    add_decl = lines('gcc/ada/gcc-interface/trans.cc', 9103, 9189)
    check('DECL_EXPR_is_built_before_global_mark_but_unconstrained_type_exits',
          add_decl.index('UNCONSTRAINED_ARRAY_TYPE') < add_decl.index('build1 (DECL_EXPR')
          < add_decl.index('DECL_EXTERNAL (gnu_decl) || global_bindings_p ()'))
    check('global_declarations_use_shared_vector', 'vec_safe_push (global_decls, decl);' in utils)
    check('original_range_is_comparison_conditional_and_two_readonly_fields', all(s in lines(
        'gcc/ada/gcc-interface/decl.cc', 7338, 7392) for s in (
            'TREE_READONLY (gnu_orig_min) = 1;', 'TREE_READONLY (gnu_orig_max) = 1;',
            'build3 (COND_EXPR, sizetype', 'build2 (GE_EXPR, boolean_type_node',
            'size_binop (MINUS_EXPR, gnu_min, size_one_node)', 'create_index_type')))
    check('conditional_distribution_and_conversion_landmarks_retained',
          'fold_binary_op_with_conditional_arg' in fold
          and 'TREE_CODE (arg0) == COND_EXPR' in lines('gcc/fold-const.cc', 9261, 9300)
          and 'fold_build3_loc' in lines('gcc/fold-const.cc', 7019, 7103))
    check('multiply_widening_barrier_precedes_factor_conversion',
          fold.index('TYPE_OVERFLOW_WRAPS (TREE_TYPE (op0))', fold.index('extract_muldiv_1'))
          < fold.index('Pass the constant down', fold.index('extract_muldiv_1')))
    check('matcher_capture_copy_condition_is_explicit',
          'unshare_expr' in lines('gcc/genmatch.cc', 3575, 3605))
    check('record_layout_allocates_ordinary_descriptor_and_field_RTL_is_noncreating',
          'record_layout_info rli = XNEW (struct record_layout_info_s);' in stor
          and 'rtl = DECL_RTL_IF_SET (decl);' in stor)
    check('finisher_prices_both_size_merges',
          '= merge_sizes (ada_size, pos, this_ada_size,' in utils
          and '= merge_sizes (size, pos, this_size,' in utils)
    check('multiple_of_p_can_allocate_factor_ratio',
          'op2 = wide_int_to_tree (TREE_TYPE (bottom), w);'
          in lines('gcc/fold-const.cc', 14230, 14355))
    check('alignment_AND_probe_can_allocate_positive_divisor',
          'wide_int_to_tree (TREE_TYPE (arg1), ncst1)'
          in lines('gcc/fold-const.cc', 11932, 11948))
    check('generic_mask_gate_rejects_alignment_masks_before_construction',
          '(cst1 & (cst1 + 1)) != 0' in lines('gcc/fold-const.cc', 12758, 12778))
    check('existing_helper_CALL_shortcuts_further_self_reference_factoring',
          't = skip_simple_constant_arithmetic (size);' in lines('gcc/stor-layout.cc', 155, 170)
          and 'TREE_CODE (t) == CALL_EXPR' in lines('gcc/stor-layout.cc', 155, 170))
    check('Positive_Uint_expansion_uses_base15_and_digit_multiply_add',
          'Base_Bits : constant := 15;' in sources['gcc/ada/uintp.ads']
          and all(s in ada('cuintp.cc') for s in (
              'gnu_base = build_cst_from_int (comp_type, Base);',
              'gnu_ret = build_cst_from_int (comp_type, First);',
              'scaled = fold_build2 (MULT_EXPR, comp_type, gnu_ret, gnu_base);',
              'next_ret = fold_build2 (code, comp_type, scaled, elt);')))
    check('names_use_fixed_Ada_buffer_and_GGC_character_callback',
          'Global_Name_Buffer : Bounded_String (Max_Length => 4 * Max_Line_Length);'
          in sources['gcc/ada/namet.ads']
          and 'Name_Find' not in lines('gcc/ada/exp_dbug.adb', 613, 909)
          and 'ident_hash->alloc_subobject = stringpool_ggc_alloc;'
          in sources['gcc/stringpool.cc']
          and 'table->alloc_subobject (len + 1)' in sources['libcpp/symtab.cc'])
    abi = lines('gcc/config/i386/i386.cc', 4451, 4481)
    check('selected_return_in_memory_query_examines_arguments_without_REG_construction',
          'return examine_argument (mode, type, 1,' in abi
          and all(s not in abi for s in ('gen_rtx', 'construct_container', 'hard_function_value'))
          and 'targetm.calls.return_in_memory (gnu_type, NULL_TREE)' in ada('misc.cc'))
    check('TYPE_DECL_cannot_enter_variable_initializer_pool_route',
          'if (VAR_P (gnu_decl) && (gnu_init = DECL_INITIAL (gnu_decl)))' in add_decl)
    check('reserved_warning_destination_blocks_map_insertion',
          'if (RESERVED_LOCATION_P (to_loc))' in sources['gcc/warning-control.cc'])

    class RecordLayout(ctypes.Structure):
        _fields_ = [('t', ctypes.c_void_p), ('offset', ctypes.c_void_p),
                    ('offset_align', ctypes.c_uint), ('bitpos', ctypes.c_void_p),
                    ('record_align', ctypes.c_uint), ('unpacked_align', ctypes.c_uint),
                    ('prev_field', ctypes.c_void_p), ('pending_statics', ctypes.c_void_p),
                    ('remaining_in_alignment', ctypes.c_int), ('packed_maybe_necessary', ctypes.c_int)]

    check('native_LP64_record_descriptor_projection_is_64_bytes',
          ctypes.sizeof(ctypes.c_void_p) == 8 and ctypes.sizeof(ctypes.c_uint) == 4
          and ctypes.sizeof(RecordLayout) == 64)
    digits = [1, 32767, 32767]
    check('INT_MAX_has_three_base15_digits_and_eight_factory_slots',
          sum(d * 32768 ** i for i, d in enumerate(reversed(digits))) == (1 << 31) - 1
          and 2 + 3 * (len(digits) - 1) == 8)

    # These are semantic fixtures, not a finite replacement for the source proof.
    values = [-(1 << 31), -(1 << 31) + 1, -1, 0, 1, (1 << 31) - 2, (1 << 31) - 1]
    mask64 = (1 << 64) - 1
    extent_fixtures = 0
    for lower in values:
        for upper in values:
            lo, hi = lower & mask64, upper & mask64
            q = upper >= lower
            raw_high = hi if q else (lo - 1) & mask64
            original = (1 + raw_high - lo) & mask64
            folded = ((hi - lo + 1) & mask64) if q else 0
            expected = upper - lower + 1 if q else 0
            assert original == folded == expected
            assert original * 8 == (expected << 3)
            extent_fixtures += 1
    check('49_signed32_extent_semantic_fixtures', extent_fixtures == 49)
    object_values = [0, 1, 2, 3, 4, 7, 8, 9, (1 << 31) - 1, 1 << 31, (1 << 32) - 1, 1 << 32]
    for byte_extent in object_values:
        bits = ((8 + byte_extent) * 8 + 31) & ~31
        units = (byte_extent + 11) & ~3
        assert bits == 8 * units == 8 * (((8 + byte_extent + 3) // 4) * 4)
    check('12_XUT_alignment_semantic_fixtures', len(object_values) == 12)
    for precision, divisor in ((128, 32), (64, 4)):
        mask = (-divisor) & ((1 << precision) - 1)
        assert mask & ((mask + 1) & ((1 << precision) - 1))
    check('both_negative_alignment_masks_fail_generic_low_bits_gate', True)

    output = evaluate()
    check('frozen_interface_matches_derivation',
          json.loads((HERE / 'interface.json').read_text()) == output)
    audit = json.loads((HERE / 'fold-audit.json').read_text())
    check('unsigned_high_bit_extends_stored_constant_to_three_units',
          'if (TYPE_UNSIGNED (type) && wi::neg_p (cst))' in
          lines('gcc/tree.cc', 1581, 1588)
          and 'return cst.get_precision () / HOST_BITS_PER_WIDE_INT + 1;' in
          lines('gcc/tree.cc', 1581, 1588)
          and audit['constant_precision_ceiling'] == 128
          and audit['constant_value_words_ceiling'] == 2
          and audit['constant_extended_words_ceiling'] == 128 // 64 + 1 == 3)
    check('three_extended_units_fit_existing_40_byte_factory_charge',
          'int length = ((ext_len - 1) * sizeof (HOST_WIDE_INT)' in
          lines('gcc/tree.cc', 2925, 2930)
          and '+ sizeof (struct tree_int_cst));' in
          lines('gcc/tree.cc', 2925, 2930)
          and 'struct tree_typed typed;' in lines('gcc/tree-core.h', 1575, 1578)
          and 'HOST_WIDE_INT val[1];' in lines('gcc/tree-core.h', 1575, 1578)
          and audit['constant_typed_prefix_bytes'] == 16
          and audit['constant_factory_caller_bytes_ceiling'] == 16 + 3 * 8 == 40)
    check('XUT_high_bit_mask_uses_extended_units_without_changing_bytes',
          ((-32) & ((1 << 128) - 1)) >> 127 == 1
          and 24 + ((128 // 64 + 1) - 1) * 8 == 40)
    check('audit_fixed_and_constant_rows_match_derivation',
          audit['fixed_rows'] == [dict(family=f, requests=n, bytes_each=s) for f, n, s in FIXED_ROWS]
          and audit['constant_rows'] == [dict(family=f, factory_slots=n) for f, n in CONSTANT_ROWS])
    check('original_extent_fold_envelope_is_1_8_4_and_four_constants',
          {key: sum(row[key] for row in audit['array_folds'])
           for key in ('unary', 'binary', 'ternary', 'constant_factories')}
          == dict(unary=1, binary=8, ternary=4, constant_factories=4))
    check('XUT_fold_envelope_is_1_8_and_twelve_rounding_constants',
          all(audit['object_folds'][k] == v for k, v in
              dict(unary=1, binary=8, ternary=0, rounding_constant_factories=12).items()))
    check('129_scalar_slots_and_eleven_names_93_bytes',
          sum(n for _, n in CONSTANT_ROWS) == 129 and len(NAMES) == 11
          and sum(len(s) + 1 for s in NAMES) == 93)
    check('residual_216_events_13149_caller_17112_slots_and_3_192_ordinary',
          [output[k] for k in ('GGC_events', 'GGC_caller_bytes', 'GGC_separately_rounded_bytes',
                              'ordinary_requests', 'ordinary_caller_bytes')]
          == [216, 13149, 17112, 3, 192])
    helper = json.loads(history['docs/evidence/retained-literal-original-string-storage-20261018/interface.json'])
    synthetic = json.loads(history['docs/evidence/retained-literal-synthetic-function-storage-20261018/interface.json'])
    check('accepted_disjoint_predecessors_are_94_and_corrected_173',
          helper['GGC_events'] == 94 and synthetic['GGC_events'] == 173)
    check('complete_cold_conversion_composition_once',
          output['GGC_events'] + helper['GGC_events'] == 310
          and output['GGC_caller_bytes'] + helper['GGC_caller_bytes_sum_ceiling']['constant'] == 19981
          and output['GGC_separately_rounded_bytes'] + helper['GGC_rounded_slots_sum_ceiling']['constant'] == 25024
          and output['ordinary_requests'] + helper['ordinary_requests'] == 5
          and output['ordinary_caller_bytes'] + helper['ordinary_caller_bytes_sum_ceiling'] == 272
          and output['decl_UID_increments'] + helper['identity_demands']['fresh_DECL_UIDs'] == 21
          and output['type_UID_increments'] + helper['identity_demands']['fresh_type_UIDs_ceiling'] == 14)
    for p in (0, 31, 32, 95, 96, 4096, (1 << 31) - 34):
        assert p + 33 <= rho(p + 33) < 2 * (p + 33)
    check('helper_name_parameter_keeps_individual_rounding_and_finite_guard',
          helper['GGC_caller_bytes_sum_ceiling']['P_coefficient'] == 2
          and helper['GGC_rounded_slots_sum_ceiling']['rho(P+33)_coefficient'] == 2)
    check('zero_residual_pool_and_identity_demands_are_explicit', all(output[k] == 0 for k in (
        'tree_pool_insertion_capable_lookups', 'tree_pool_entries', 'tree_pool_replacement_objects',
        'make_decl_rtl_calls', 'constructor_address_materializations', 'finalizers',
        'cgraph_registrations', 'function_definition_numbers', 'RTL_labels', 'RTL_pseudos',
        'symbol_order_increments', 'new_integer_cache_vectors', 'type_hash_insertion_capable_lookups')))
    check('helper94_synthetic173_Main_null11_and_shared_backing_remain_disjoint',
          all(output[k] is False for k in (
              'helper_94_included', 'synthetic_173_included', 'Main_null_helper_11_included',
              'original_Main_and_elaboration_included', 'per_literal_subtype_and_constructor_included',
              'shared_table_backing_included', 'complete_imported_frontend',
              'complete_global_containers', 'complete_collector', 'complete_whole_pipeline')))

    now = datetime.now(timezone.utc)
    result = dict(status='PASS', checked_utc=now.isoformat(),
                  elapsed_seconds=round(time.monotonic() - started, 3),
                  host=dict(system=platform.system(), machine=platform.machine()),
                  selected_model=None, selected_effort=None,
                  settings_note='The checker cannot observe the invoking agent settings; the original worker record remains in check-results.json.',
                  runtime_settings_confirmed=False, token_cost_data_available=False,
                  native_runs=0, network_requests_this_check=0,
                  source_files=len(sources), historical_inputs=len(history),
                  retained_new_raw_comparisons=len(new_raw),
                  extent_semantic_fixtures=extent_fixtures, XUT_semantic_fixtures=len(object_values),
                  check_count=len(checks), checks=checks, independent_review='pending',
                  limitation='Source landmarks and finite fixtures corroborate, but do not prove, the handwritten source/fold closure.')
    rendered = json.dumps(result, indent=2) + '\n'
    if args.output:
        args.output.write_text(rendered)
    print(rendered, end='')


if __name__ == '__main__':
    main()
