#!/usr/bin/env python3
"""Current #207 overlay; reads frozen evidence, never executes its generator."""
import argparse
import hashlib
import json
import platform
import re
import tarfile
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
HISTORICAL = 'docs/evidence/unbounded-programs/retained-native-expansion-20261017/local-envelope.json'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def load(path):
    return json.loads(path.read_bytes())


def digits(n):
    return max(1, (abs(n).bit_length() + 14) // 15)


def trunc_div(a, b):
    return (1 if a >= 0 else -1) * (abs(a) // b)


def repaired_allowance(*, historical_entries, historical_digits,
                       cumulative_entity_allowance, incoming_digit_bound):
    """Mandatory keyword inputs; no option that silently omits the repair."""
    assert all(type(x) is int and x >= 0 for x in
               (historical_entries, historical_digits, cumulative_entity_allowance))
    assert type(incoming_digit_bound) is int and incoming_digit_bound >= 1
    n, k = cumulative_entity_allowance, incoming_digit_bound + 1
    extra = 7 * n
    return {'layout_entry_allowance': n, 'layout_result_digit_bound': k,
            'additional_Uint_entries': extra, 'additional_Uint_digits': extra * k,
            'additional_UI_Ints_wrapper_allowance': extra,
            'current_Uint_entries': historical_entries + extra,
            'current_Uint_digits': historical_digits + extra * k,
            'current_common_Uint_digit_bound': k,
            'current_local_numeric_vector': {
                'largest_owner_words': max(k + 1, 3),
                'simultaneous_owner_words': 5 * k + 3,
                'owner_and_borrowed_views': 6,
                'descriptor_and_bound_record_bytes_per_view_upper': 32,
                'descriptor_and_bound_record_bytes_upper': 192,
                'largest_owner_plus_descriptor_bytes': 4 * max(k + 1, 3) + 32,
                'physical_native_frame_bound': False,
                'checks': {'dimension_additions': k + 1 <= 2**31 - 1,
                           'owner_word_sum': 5 * k + 3 <= 2**31 - 1,
                           'individual_object_bytes': 4 * max(k + 1, 3) + 32 <= 2**63 - 1}}}


def backing(demand, low, initial, size, high):
    # Same accepted generic Table arithmetic, specialized to the changed
    # Uints/Udigits instances: factor1, increment100. No old verdict reuse.
    p = max(demand, initial)
    cap = max(initial, demand + demand // 1000, 2 * p, p + 10)
    checks = {'initial_product': initial <= 2**31 - 1,
              'growth_product': p * 200 <= 2**63 - 1,
              'backing_length_plus_one': cap + 1 <= 2**31 - 1,
              'empty_index': low - 1 >= -2**31,
              'backing_index_sentinel': low + cap <= 2**31 - 1,
              'logical_nominal_index': low + demand - 1 <= high,
              'individual_backing_bytes': (cap + 1) * size <= 2**63 - 1}
    return {'demand': demand, 'capacity_upper': cap,
            'bytes_with_sentinel': (cap + 1) * size,
            'checks': checks, 'all_selected_checks_pass': all(checks.values())}


def run():
    start = time.perf_counter()
    manifest = load(HERE / 'string-pack-source-manifest.json')
    for row in manifest['historical_inputs']:
        assert sha((ROOT / row['path']).read_bytes()) == row['sha256'], row['path']
    pins = {x['path']: x for x in load(ROOT / manifest['source_predecessor'])['files']}
    archive = HERE / 'string-pack-sources.tar.gz'
    assert sha(archive.read_bytes()) == manifest['archive_sha256']
    sources = {}
    with tarfile.open(archive, 'r:gz') as tar:
        assert {x.name for x in tar.getmembers()} == {x['path'] for x in manifest['files']}
        assert all(x.isfile() for x in tar.getmembers())
        for row in manifest['files']:
            b = tar.extractfile(row['path']).read()
            assert len(b) == row['bytes']
            assert sha(b) == row['sha256'] == pins[row['path']]['sha256']
            sources[row['path']] = b
    for row in manifest['witnesses']:
        lines = sources[row['source']].split(b'\n')
        b = b'\n'.join(lines[row['first_lf_line'] - 1:row['last_lf_line']]) + b'\n'
        assert sha(b) == row['sha256'] and b.decode() == row['excerpt']
    calls = []
    for name in sorted(sources):
        if name.endswith('.adb'):
            text = sources[name].decode()
            for match in re.finditer(r'\bLayout_Type\s*\(', text, re.I):
                no = text.count('\n', 0, match.start()) + 1
                line = text.split('\n')[no - 1]
                calls.append({'source': name, 'lf_line': no, 'text': line.strip()})
    assert calls == manifest['Layout_Type_callsite_inventory']
    # Source semantics / universal local algebra, independently reviewable.
    assert sum([2, 1, 1, 1, 1, 1]) == 7
    boundary_values = {0, 1, -1, 32767, -32767, 32768, -32768,
                       200000000, (1 << 31) - 1, -(1 << 31)}
    for k in range(1, 10):
        for delta in (-1, 0, 1):
            boundary_values.update((32768**k + delta, -32768**k + delta))
    checked = 0
    for lo in boundary_values:
        for hi in boundary_values:
            h = max(1, abs(lo), abs(hi))
            d = hi - lo + 1
            s = d * 8
            rounded = trunc_div(s + 7, 8) * 8
            magnitude = 8 * (2 * h + 1) + 7
            assert max(abs(-lo), abs(hi - lo), abs(d), abs(s),
                       abs(s + 7), abs(trunc_div(s + 7, 8)), abs(rounded)) <= magnitude
            assert rounded == s if d >= 0 else rounded == s + 8
            # Nonnegative equal sizes, or at least RM_Size negative: no
            # Known_Static_Esize && Known_Static_RM_Size && Esize<RM tail.
            assert not (s >= 0 and rounded >= 0 and rounded < s)
            assert digits(magnitude) <= max(digits(lo), digits(hi)) + 1
            checked += 1
    witness = {'Lo': 1, 'Hi': 200000000,
               'mandatory_general_conversion_results': [1600000000, 1600000007, 1600000000]}
    assert all(x > (32768 - 1)**2 and digits(x) == 3
               for x in witness['mandatory_general_conversion_results'])
    witness.update(Uint_entries=3, Uint_digits=9,
                   admitted_program_claim=False, aggregate_overflow_claim=False)
    historical = load(ROOT / HISTORICAL)
    programs = []
    for item in historical['representative_current_programs']['programs']:
        assert sha((ROOT / item['source']).read_bytes()) == item['sha256']
        old = item['logical_join']
        core = old['Main_constructor']
        e = item['gigi_source_interface']['Main_entity_identities']
        assert core['total']['entity_identities'] == e
        delta = repaired_allowance(historical_entries=old['tables']['Uint_entries'],
            historical_digits=old['tables']['Uint_digits'],
            cumulative_entity_allowance=e, incoming_digit_bound=core['common_Uint_digit_bound'])
        current_tables = dict(old['tables'])
        current_tables['Uint_entries'] = delta['current_Uint_entries']
        current_tables['Uint_digits'] = delta['current_Uint_digits']
        current_main = dict(core['total'])
        current_main['uint'] += delta['additional_Uint_entries']
        current_main['retained_digit_words'] += delta['additional_Uint_digits']
        fresh_checks = {
            'Uints': backing(current_tables['Uint_entries'], -699999999, 5000, 8, -600000000),
            'Udigits': backing(current_tables['Uint_digits'], 0, 10000, 4, 2**31 - 1)}
        assert all(x['all_selected_checks_pass'] for x in fresh_checks.values())
        assert all(delta['current_local_numeric_vector']['checks'].values())
        programs.append({'source': item['source'], 'sha256': item['sha256'],
            'repair_applied_once': True, 'current_Main_constructor_total': current_main,
            'current_tables': current_tables, 'String_layout_repair': delta,
            'fresh_changed_table_checks': fresh_checks,
            'historical_changed_table_verdict_reused': False,
            'all_other_historical_fields_are_unchanged_subtotals': True,
            'complete_native_capacity_result': False})
    return {'status': 'pass', 'issue': 207,
        'supersedes_for_current_frontend_numeric_exports': HISTORICAL,
        'original_generator_and_evidence_preserved': True,
        'source_files_verified': len(sources), 'LF_witnesses_verified': len(manifest['witnesses']),
        'historical_inputs_verified': len(manifest['historical_inputs']),
        'author_complete_body_inventory_count': manifest['inventory_complete_Ada_bodies_hashed'],
        'matching_file_callsite_occurrences_rechecked': len(calls),
        'full_negative_scan_repeated': False, 'signed_and_boundary_pairs_checked': checked,
        'local_counterexample': witness,
        'current_local_transfers': {
            'ordinary_String_pair_first_layout_Uint_entries_upper': 7,
            'ordinary_String_pair_first_layout_digit_words': '7*digits_32768(8*(2H+1)+7)',
            'separately_needed_first_size_entries_upper': 4,
            'first_size_plus_first_layout_entries_upper': 11,
            'immediate_slice_resolution_uint': 4,
            'slice_resolution_plus_first_layout_reservation_uint': 11,
            'explicit_storage_plain_uint': '596*A+526',
            'explicit_storage_secondary_uint': '80*A+166',
            'enabled_final_slice_with_layout_reservation_uint': '596*A+431',
            'literal_subtype_layout_extra_entries': 0,
            'repeat_freeze_extra_entries': 0},
        'current_Main_overlay_required': True,
        'global_and_per_site_repairs_are_alternatives_not_additive': True,
        'programs': programs,
        'selected_author_model': 'GPT-6 Astra', 'selected_author_effort': 'Extra High',
        'runtime_model_and_effort': 'unavailable', 'native_platform': platform.system()+' '+platform.machine(),
        'offline_elapsed_seconds': time.perf_counter()-start,
        'native_compiler_runs': 0, 'prover_runs': 0, 'predecessor_replays': 0,
        'independent_review': 'pending', 'complete_native_capacity_result': False,
        'total_author_time_tokens_cost': 'unavailable'}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    result = run()
    if args.output:
        args.output.write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k: result[k] for k in ('status', 'source_files_verified',
        'LF_witnesses_verified', 'signed_and_boundary_pairs_checked', 'offline_elapsed_seconds',
        'complete_native_capacity_result')}))


if __name__ == '__main__':
    main()
