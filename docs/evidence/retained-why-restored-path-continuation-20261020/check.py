#!/usr/bin/env python3
"""Check retained source/evidence identities and the larger supplied-byte bound."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile

from transfer import supplied_bound

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
E = HERE.parent


def get(path):
    return json.loads(path.read_text())


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def checks():
    a = supplied_bound(10, 2, 100, 3, valid_string_representation=True)
    b = supplied_bound(10, 3, 100, 3, valid_string_representation=True)
    assert a['supplied_raw_string_bytes_sum_per_save_upper'] == 210
    assert b['supplied_raw_string_bytes_sum_per_save_upper'] == 310
    # The bound admits a newly installed qualified path larger than fallback.
    assert 10 + len('long.scope.name') * 2 <= a['supplied_raw_string_bytes_sum_per_save_upper']
    for idx in range(3):
        values = [10, 2, 100, 3]; values[idx] = None
        assert supplied_bound(*values, valid_string_representation=True)['supplied_raw_string_bytes_sum_per_save_upper'] is None
    assert supplied_bound(10, 2, 100, 3, valid_string_representation=False)['supplied_raw_string_bytes_sum_per_save_upper'] is None
    assert supplied_bound(10, 2, 100, None, valid_string_representation=True)['supplied_raw_string_bytes_sum_all_saves_upper'] is None
    for bad in (-1, True):
        try:
            supplied_bound(10, bad, 100, 3, valid_string_representation=True)
        except ValueError:
            pass
        else:
            raise AssertionError('invalid count accepted')
    # A live key can disappear from h.data at the first resize publication.
    old = {7: 'short'}
    current = {}
    assert 7 in old and 7 not in current
    current[7] = 'long.scope.name'
    assert len(current[7]) > len(old[7])
    # Equal tags do not imply physical identifier identity.
    original = {'tag': 7, 'name': 'g'}
    fresh = {'tag': 7, 'name': 'long.scope.name'}
    assert original is not fresh and original['tag'] == fresh['tag']
    return {'multiplicity_and_larger_later_path_checked': True,
            'unknown_input_and_missing_representation_preserved': True,
            'live_key_reachability_and_tag_alias_counterexamples': True}


def compute():
    for path, expected in get(HERE / 'inputs.json').items():
        assert identity((ROOT / path).read_bytes()) == expected, path
    cache = {}
    for x in get(HERE / 'source-excerpts.json'):
        key = (x['archive'], x['member'])
        if key not in cache:
            with tarfile.open(ROOT / x['archive']) as t:
                cache[key] = t.extractfile(x['member']).read()
        raw = cache[key]
        assert identity(raw) == x['member_identity']
        part = ''.join(raw.decode().splitlines(keepends=True)[x['first'] - 1:x['last']])
        assert part == x['text'] and identity(part.encode()) == x['excerpt_identity']
    census = []
    with tarfile.open(E / 'retained-why-session-helper-source-20261019/sources.tar.gz') as t:
        for m in t.getmembers():
            if not m.isfile() or not m.name.endswith(('.ml', '.mli')):
                continue
            for i, line in enumerate(t.extractfile(m).read().decode().splitlines(), 1):
                if re.search(r'\b(store_path|store_theory|id_to_path)\b', line):
                    census.append({'member': m.name, 'line': i, 'text': line})
    assert census == get(HERE / 'private-writer-census.json')
    limits = get(E / 'retained-why-session-save-outcomes-20261019/runtime-limits.json')
    runtime = get(E / 'retained-why-session-helper-source-20261019/runtime-version.json')
    assert limits['elf_identity'] == runtime['identity']
    limit = limits['max_string_length']
    assert limit == 8 * limits['max_wosize'] - 1 == (1 << 57) - 9
    word = bytes.fromhex(limits['windows'][1]['hex'])
    assert word[:2] == bytes.fromhex('48b8')
    assert (int.from_bytes(word[2:10], 'little') - 1) // 2 == limit
    imported = get(E / 'retained-why-save-serializer-inputs-20261020/result.json')
    rows = []
    for c in imported['cases']:
        inv = c['inventory']
        names = [i for i in inv['identifiers'] if i['serializer_visits']]
        count = sum(i['serializer_visits'] for i in names)
        old_name_bytes = sum(i['serializer_visits'] * i['fallback_or_captured_qualified_bytes_upper'] for i in names)
        assert old_name_bytes == inv['field_totals']['identifier_fallback_or_captured_qualified_bytes_upper']
        absent = [i['id_tag'] for i in names if not i['captured_binding_present']]
        assert sorted(absent) == sorted(inv['missing_binding_serialized_identifier_tags'])
        assert all(i['fallback']['bytes'] <= limit for i in names)
        fixed = c['candidate_raw_string_bytes_sum_per_save'] - old_name_bytes
        assert fixed >= 0 and count > 0
        result = supplied_bound(fixed, count, limit, c['remaining_save_entries_upper'],
                                valid_string_representation=True)
        u = result['supplied_raw_string_bytes_sum_per_save_upper']
        assert u > limit and 7 * u + 79 > 1000000010
        rows.append({'case': c['case'], 'pid': c['pid'], 'phase': c['phase'],
                     'identifier_occurrence_count': count,
                     'initially_absent_serialized_identifier_count': len(absent),
                     'initially_absent_serialized_identifier_tags': absent,
                     'captured_identifier_byte_sum': old_name_bytes,
                     'nonidentifier_byte_sum_upper': fixed,
                     'small_candidate_U': c['candidate_raw_string_bytes_sum_per_save'],
                     'remaining_save_entries_upper': c['remaining_save_entries_upper'],
                     'conditional_supplied_byte_bound': result,
                     'coarse_U_fits_one_native_string': u <= limit,
                     'coarse_U_fits_native_integer': u <= (1 << 62) - 1,
                     'operational_B_plus_E_plus79_lower_bound': 7 * u + 79,
                     'lead_supplied_Format_guard_threshold': 1000000010,
                     'lead_supplied_Format_guard_can_pass': False})
    return {'scope': 'Larger supplied-string argument byte bound; exact small-path preservation unresolved',
            'native_max_string_length': limit, 'cases': rows, 'checks': checks(),
            'source_excerpt_count': len(get(HERE / 'source-excerpts.json')),
            'source_writer_census_count': len(census),
            'native_runs': 0, 'new_captures': 0, 'source_fetches': 0,
            'observer_replays': 0, 'binder_recomputations': 0, 'alpha_replays': 0,
            'captured_small_path_bound_preserved': False,
            'whole_save_capacity_established': False}


def main():
    ap = argparse.ArgumentParser(); ap.add_argument('--write', action='store_true')
    args = ap.parse_args(); result = compute()
    if args.write:
        (HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    else:
        assert result == get(HERE / 'result.json')
    print(json.dumps({'cases': len(result['cases']), 'source_excerpts': result['source_excerpt_count'],
                      'all_coarse_bounds_reject_useful_headroom': True,
                      'checks': result['checks'], 'native_runs': 0}))


if __name__ == '__main__':
    main()
