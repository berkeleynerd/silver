#!/usr/bin/env python3
"""Source identities and arithmetic for the #201/#209 helper continuation.

No native target, generator, predecessor checker or compiler is executed.
This does not prove the handwritten source/shape/caller argument.
"""
import argparse
import hashlib
import itertools
import json
import platform
import re
import tarfile
import time
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]


def digest(data):
    return hashlib.sha256(data).hexdigest()


def read_json(path):
    return json.loads(path.read_bytes())


def digits(value):
    value = abs(value)
    result = 1
    while value >= 32768:
        value //= 32768
        result += 1
    return result


def check():
    started = time.perf_counter()
    inputs = read_json(HERE / 'inputs.json')['files']
    for row in inputs:
        data = (ROOT / row['path']).read_bytes()
        assert len(data) == row['bytes'], row['path']
        assert digest(data) == row['sha256'], row['path']
    manifest = read_json(HERE / 'source-manifest.json')
    assert manifest['gcc_commit'] == '6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea'
    archive = HERE / manifest['archive']
    assert digest(archive.read_bytes()) == manifest['archive_sha256']
    sources = {}
    with tarfile.open(archive, 'r:gz') as tar:
        assert all(m.isfile() for m in tar.getmembers())
        assert {m.name for m in tar.getmembers()} == {
            row['path'] for row in manifest['files']}
        assert len(tar.getmembers()) == len(manifest['files'])
        for row in manifest['files']:
            data = tar.extractfile(row['path']).read()
            assert len(data) == row['bytes'], row['path']
            assert digest(data) == row['sha256'], row['path']
            origin = read_json(ROOT / row['retained_identity'])
            matches = [r for r in origin['files'] if r['path'] == row['path']]
            assert len(matches) == 1
            assert matches[0]['sha256'] == row['sha256'], row['path']
            sources[row['path']] = data
    witnesses = read_json(HERE / 'source-witnesses.json')['witnesses']
    assert len({w['id'] for w in witnesses}) == len(witnesses)
    for row in witnesses:
        lines = sources[row['source']].split(b'\n')
        lo, hi = row['first_lf_line'], row['last_lf_line']
        assert 1 <= lo <= hi <= len(lines)
        assert digest(b'\n'.join(lines[lo - 1:hi]) + b'\n') == row['sha256']

    host = (ROOT / 'docs/evidence/retained-backend-capacity-20261018/'
            'selected-auto-host.h').read_text()
    assert '#define CHECKING_P 0' in host
    assert '#define GATHER_STATISTICS 0' in host
    assert '/* #undef ENABLE_FOLD_CHECKING */' in host
    # Complete-file syntax inventory, not a claim about execution counts.
    template_sites = {}
    for path in ('gcc/ada/gcc-interface/decl.cc',
                 'gcc/ada/gcc-interface/utils.cc',
                 'gcc/ada/gcc-interface/utils2.cc',
                 'gcc/ada/gcc-interface/trans.cc'):
        text = sources[path].decode()
        sites = [text.count('\n', 0, m.start()) + 1
                 for m in re.finditer(r'\bbuild_template\s*\(', text)]
        template_sites[path] = sites
    assert template_sites == {
        'gcc/ada/gcc-interface/decl.cc': [1237],
        'gcc/ada/gcc-interface/utils.cc': [4401, 4877, 4973, 5147],
        'gcc/ada/gcc-interface/utils2.cc': [2674, 2685],
        'gcc/ada/gcc-interface/trans.cc': [],
    }
    decl = sources['gcc/ada/gcc-interface/decl.cc'].decode().split('\n')
    predicate = '\n'.join(decl[7048:7095])
    assert predicate.count('UI_To_gnu (') == 2
    assert predicate.count('size_binop (MINUS_EXPR') == 1
    assert predicate.count('while (') == 2

    old = read_json(HERE.parent / 'check-result.json')
    original = old['direct_kernel_coefficients']['direct_constant_requests']
    assert original == [9, 56, 42, 12]
    typed_uint = 3 + 5 * (3 - 1)
    predicate_overlay = 2 * typed_uint + 1
    assert typed_uint == 13 and predicate_overlay == 27
    repaired = [9, 56 + predicate_overlay, 42, 12]
    constant_helpers = [0, 7 + 6 + 17 + 3 * 2 + 5 + 2,
                        4 + 8 + 12 + 2 * 2 + 5, 0]
    assert constant_helpers == [0, 43, 33, 0]
    source_constants = [2 * typed_uint, 0, typed_uint, 0]
    before_annotation = [a + b + c for a, b, c in
                         zip(repaired, constant_helpers, source_constants)]
    assert before_annotation == [35, 126, 88, 12]
    annotation_constants = [0, 2 * 31, 2 * 31, 0]
    classified = [a + b for a, b in zip(before_annotation, annotation_constants)]
    assert classified == [35, 188, 150, 12]
    mixed_overlay = [a + b + c for a, b, c in
                     zip(constant_helpers, source_constants, annotation_constants)]
    assert mixed_overlay == [26, 105, 108, 0]
    assignments = 0
    for family in itertools.product(range(5), repeat=4):
        for subset in itertools.product(*(range(n + 1) for n in family[:3])):
            complete_subset = (*subset, 0)
            current = sum(a * b for a, b in zip(repaired, family))
            current += sum(a * b for a, b in zip(mixed_overlay, complete_subset))
            assert current <= max(classified) * sum(family)
            assert current >= sum(a * b for a, b in zip(original, family))
            assignments += 1

    endpoints = sorted({-(2**31), -(2**31) + 1, -(2**30), -32769,
                        -32768, -32767, -9, -8, -1, 0, 1, 7, 8, 9,
                        32767, 32768, 32769, 2**30, 2**31 - 2, 2**31 - 1})
    pairs = 0
    legal_string_pairs = 0
    for low, high in itertools.product(endpoints, repeat=2):
        assert digits(low) <= 3 and digits(high) <= 3
        assert -(2**127) <= low - 1 < 2**127
        assert -(2**127) <= high - low < 2**127
        length = max(0, high - low + 1)
        if length <= 2**31 - 1:
            bits = 8 * length
            assert 0 <= bits <= 8 * (2**31 - 1) < 2**35 < 2**63
            assert digits(bits) <= 3
            legal_string_pairs += 1
        pairs += 1

    # Per-object representation and logical automatic storage, not a frame/RSS bound.
    field_bits = [8 * offset for offset in [0, 4]]
    assert field_bits == [0, 32] and field_bits[0] != field_bits[1]
    constructor = 16 + 8
    first_vector = 8 + 4 * 16
    sort_buffer = (2 // 2) * 16
    assert constructor == 24 and first_vector == 72 and sort_buffer == 16
    assert sort_buffer <= 32 * 8 == 256
    assert (512 - 8) // 16 == 31
    assert max(constructor, first_vector, 40) <= 512
    descriptor_constants = 2 + 2 * (1 + 1 + 1)
    descriptor_caller = descriptor_constants * 40 + constructor + first_vector
    descriptor_rounded = (descriptor_constants + 1 + 1) * 512
    assert descriptor_constants == 8
    assert descriptor_caller == 416 and descriptor_rounded == 5120

    projections = []
    for old_row in old['program_projections']:
        row = {'source': old_row['source'], 'E_Main': old_row['E_Main'],
               'V_Main': old_row['V_Main'],
               'general_predicate_constants_upper': 27 * old_row['E_Main'],
               'classified_type_constants_coarse_upper': 188 * old_row['E_Main'],
               'classified_actual_template_occurrences_coarse_upper': 8 * old_row['V_Main'],
               'classification_or_actual_family_counts_supplied': False,
               'whole_native_capacity_verdict': False}
        projections.append(row)
    return {
        'status': 'pass', 'checked_at_utc': datetime.now(timezone.utc).isoformat(),
        'offline_platform': f'{platform.system()} {platform.machine()}',
        'offline_elapsed_seconds': time.perf_counter() - started,
        'gcc_commit': manifest['gcc_commit'],
        'source_files': len(sources), 'LF_witnesses': len(witnesses),
        'pinned_inputs': len(inputs), 'subset_assignments_checked': assignments,
        'signed_endpoint_pairs_checked': pairs,
        'selected_String_extent_pairs_checked': legal_string_pairs,
        'historical_first_kernel_preserved': True,
        'frontend_207_overlay_still_required_separately': True,
        'current_native_predicate_overlay_required': True,
        'issue_209': {
            'constant_requests_additive': '27Ta',
            'pointer_walk_iterations': '2Ta(Ts+1)',
            'new_Uint_entries': 0,
            'observed_aggregate_bound_violation_claim': False,
        },
        'family_order': ['Ts', 'Ta', 'Tl', 'Tp'],
        'original_C': original, 'repaired_general_C': repaired,
        'classified_before_annotation_C': before_annotation,
        'classified_with_annotation_C': classified,
        'mixed_classified_addition_to_repaired_C': mixed_overlay,
        'classified_annotation': {
            'Qc': '2(Sa+Sl)', 'Uint_entries': 'Qc+T',
            'Uint_digits': '5Qc+3T', 'UI_From_Int_cache_calls': 'Qc+T',
            'GCC_constant_requests': '31Qc', 'Rep_Table_additions': 0,
            'annotation_cache_additions': 0, 'dynamic_serial_increments': 0,
            'maximum_size_value': 8 * (2**31 - 1),
            'incoming_table_growth_guards_still_required': True,
        },
        'descriptor': {
            'source_caller_bound': 'Dc<=8Pc<=8V_Main for classified direct input adaptation',
            'per_call_constant_requests': descriptor_constants,
            'per_call_CONSTRUCTOR_bytes': constructor,
            'per_call_element_vector_caller_bytes': first_vector,
            'per_call_element_vector_rounded_bytes_upper': 512,
            'per_call_total_caller_bytes_upper': descriptor_caller,
            'per_call_total_separately_rounded_bytes_upper': descriptor_rounded,
            'additional_constant_cache_bytes': '2040*min(8Dc,participating_type_instances)',
            'per_call_logical_sort_scratch_bytes': 256,
            'complete_native_frame_claim': False,
            'whole_compiler_template_multiplicity_claim': False,
        },
        'build_template_syntax_sites_including_definition': template_sites,
        'historical_input_projections': projections,
        'dynamic_F_closed': False, 'dynamic_Q_closed': False,
        'general_fixed_entry_cumulative_cost_closed': False,
        'complete_native_capacity_result': False,
        'semantic_source_argument_machine_proved': False,
        'native_target_runs': 0, 'compiler_prover_runs': 0,
        'predecessor_checker_replays': 0,
        'selected_author_model': 'GPT-6 Astra',
        'selected_author_effort': 'Extra High',
        'runtime_model_and_effort': None,
        'total_author_elapsed_seconds': None, 'tokens': None, 'cost': None,
        'independent_review': 'pending',
    }


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    result = check()
    if args.output:
        args.output.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({k: result[k] for k in (
        'status', 'source_files', 'LF_witnesses', 'pinned_inputs',
        'subset_assignments_checked', 'signed_endpoint_pairs_checked',
        'offline_elapsed_seconds')}, indent=2))
