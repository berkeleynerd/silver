#!/usr/bin/env python3
"""Compose accepted publication inputs; no native or predecessor replay."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EVIDENCE = ROOT / 'docs/evidence'
CASES = ('put_line', 'put', 'first_or_default', 'is_message', 'input_is_valid')


def read(path):
    return json.loads(path.read_text())


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def derive():
    inputs = read(HERE / 'inputs.json')
    for name, expected in inputs['files'].items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    tuple_result = read(EVIDENCE / 'retained-why-tuple-preparation-bound-20261020/result.json')
    initial_result = read(EVIDENCE / 'retained-why-initial-registration-bound-20261020/result.json')
    writer_result = read(EVIDENCE / 'retained-why-path-writer-capacity-20261020/result.json')
    library = read(EVIDENCE / 'retained-why-library-publication-bound-20261020/bound.json')
    spec = importlib.util.spec_from_file_location(
        'retained_writer_transfer', EVIDENCE / 'retained-why-path-writer-capacity-20261020/transfer.py')
    writer = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(writer)
    assert tuple_result['complete_direct_tuple_preparation_bound_established']
    assert initial_result['initial_no_wrap_established_under_named_relation']
    tuples = {row['case']: row for row in tuple_result['rows']}
    initials = {row['case']: row for row in initial_result['cases']}
    writers = {row['case']: row for row in writer_result['cases']}
    assert set(tuples) == set(initials) == set(writers) == set(CASES)
    # Source-derived library coefficients are selected by the versioned input
    # projection, then compared with its exact retained JSON values below.
    coefficients = inputs['library_projection']
    for item in coefficients.values():
        value = library
        for key in item['path']:
            value = value[key]
        assert value == item['value'], item
    constant = coefficients['common_base_constant']['value']
    lexical = coefficients['lexical_domain_size']['value']
    reset_count = coefficients['global_resize_assignments']['value']
    escape_count = coefficients['global_escaping_signal_exceptions']['value']
    per_key = coefficients['publications_per_tuple_key']['value']
    assert (constant, lexical, reset_count, escape_count, per_key) == (3404503, 38679, 128, 2, 4)
    cases = []
    for case in CASES:
        t, i, w = tuples[case], initials[case], writers[case]
        assert i['pid'] == w['pid']
        dispatch = w['under_named_existing_premises']['dispatch_bounds']
        episodes = dispatch['preparation_episodes_intersecting_suffix_upper']
        assert episodes == t['episodes']
        assert dispatch['direct_library_roots_upper'] == 2*episodes
        initial_count = i['initial_registration_count']
        assert i['initial_two_arity_family_union_upper'] == 2*initial_count
        arities = 2*initial_count + lexical
        base_charge = constant + 8*initial_count
        direct = 3*episodes*t['T_prepared']
        assert direct == t['direct_tuple_publications']
        per_root = 2*episodes*base_charge
        resize_charge = per_key*reset_count*arities
        signal_charge = per_key*escape_count*(arities+1)
        publications = direct + per_root + resize_charge + signal_charge
        bounds = writer.writer_bounds(w['initial_cells'], publications, w['initial_scalar_size'])
        threshold = writer.publication_threshold(w['initial_cells'], w['initial_scalar_size'])
        assert threshold == w['publication_upper_passing_conservative_size_guard']
        assert publications <= threshold and bounds['tagged_size_guard']
        # Verify the exact retained threshold rather than only today's interior
        # application. This is an arithmetic boundary check, not a native run.
        assert writer.writer_bounds(w['initial_cells'], threshold, w['initial_scalar_size'])['tagged_size_guard']
        assert not writer.writer_bounds(w['initial_cells'], threshold+1, w['initial_scalar_size'])['tagged_size_guard']
        cases.append({
            'case': case, 'pid': i['pid'],
            'initial_registration_count': initial_count,
            'T_prepared': t['T_prepared'], 'episodes': episodes,
            'initial_cells': w['initial_cells'],
            'initial_scalar_size': w['initial_scalar_size'],
            'tuple_arity_domain_upper': arities,
            'common_library_base_charge_per_root': base_charge,
            'direct_algebraic_tuple_publications_upper': direct,
            'library_base_publications_upper': per_root,
            'global_resize_loss_publications_upper': resize_charge,
            'global_signal_publications_upper': signal_charge,
            'publications_upper': publications,
            'publication_upper_passing_conservative_size_guard': threshold,
            'publication_margin': threshold-publications,
            'writer_bounds': bounds,
        })
    return {
        'scope': 'Five retained continuations under the documented source/native/state/service premises',
        'formula': 'W = 3*E*T + 2*E*(3404503+8*I) + 4*128*K + 4*e*(K+1); K=2*I+38679; e=2',
        'global_allowances_charged_once_per_process': True,
        'cases': cases,
        'publication_bound_established_under_named_premises': True,
        'writer_scalar_size_guard_established_under_named_premises': True,
        'complete_writer_capacity_established': False,
        'complete_restore_table_capacity_established': False,
        'complete_save_capacity_established': False,
        'whole_pipeline_capacity_established': False,
        'native_runs': 0, 'predecessor_checker_replays': 0,
    }


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    started = time.monotonic()
    result = derive()
    raw = (json.dumps(result, indent=2) + '\n').encode()
    if args.write:
        (HERE / 'result.json').write_bytes(raw)
    else:
        assert (HERE / 'result.json').read_bytes() == raw
    print(json.dumps({'status': 'pass', 'cases': len(result['cases']),
                      'publication_bounds': [r['publications_upper'] for r in result['cases']],
                      'all_writer_scalar_guards_pass': True,
                      'elapsed_seconds': time.monotonic()-started,
                      'native_runs': 0, 'predecessor_checker_replays': 0}, indent=2))
