#!/usr/bin/env python3
"""Compose reviewed path/input bounds; external behavior remains conditional."""
import importlib.util
import json
from pathlib import Path

ROOT = Path(__file__).resolve().parents[3]
EVIDENCE = ROOT / 'docs/evidence'
EXTERNAL_PREMISES = (
    'selected_source_native_and_valid_value_relation',
    'normal_numerical_and_allocation_services',
    'faithful_pending_callbacks_and_private_frames',
    'retained_occurrence_continuation_and_global_save_budget',
)


def read(directory, name='result.json'):
    return json.loads((EVIDENCE / directory / name).read_text())


def module(directory):
    path = EVIDENCE / directory / 'transfer.py'
    spec = importlib.util.spec_from_file_location(directory, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


def compose(premises=None):
    premises = {} if premises is None else premises
    if not isinstance(premises, dict) or set(premises) - set(EXTERNAL_PREMISES):
        raise ValueError('unknown external premise')
    if any(type(value) is not bool for value in premises.values()):
        raise ValueError('external premises must be explicit booleans')
    joined = all(premises.get(name) is True for name in EXTERNAL_PREMISES)
    initial = read('retained-why-path-initial-state-20261020')
    later = read('retained-why-path-library-origins-20261020')
    payload = read('retained-why-path-payload-bound-20261020')
    ownership = read('retained-why-save-formatter-ownership-20261020')
    core = module('retained-why-save-formatter-core-20261020')
    construction = module('retained-why-path-construction-20261020')
    assert initial['initial_selectable_payload_set_complete_under_named_relation'] is True
    assert initial['suspended_pre_cut_theory_table_mutation_excluded_under_named_relation'] is True
    assert later['complete_selected_later_path_writer_coverage_under_named_relation'] is True
    assert later['normal_numeric_and_allocation_services_required'] is True
    later_bound = later['later_payload_bytes_upper_under_named_relation']
    assert type(later_bound) is int and later_bound >= 0
    initial_bound = initial['initial_nonempty_qualified_path_bytes_upper']
    path_bound = max(initial_bound, later_bound)
    normal = ownership['under_named_existing_external_premises']
    assert normal['fresh_default_and_private_frame_under_supplied_external_premises'] is True
    scalar = normal['normal_scalar_bytes_upper_under_supplied_external_premises']
    assert scalar == 20
    assert [(r['case'], r['pid']) for r in initial['cases']] == [
        (r['case'], r['pid']) for r in payload['cases']]
    cases = []
    for row, initial_row in zip(payload['cases'], initial['cases']):
        count = row['identifier_occurrences']
        assert count == initial_row['serialized_identifier_count']
        raw = row['nonidentifier_raw_bytes'] + count * max(row['fallback_max_bytes'], path_bound)
        q = row['Q']
        text = 1024 * q + 6 * raw + 32 * q * scalar
        events = 128 * q + raw
        core_result = core.core_bounds(text, events, {p: joined for p in core.PREMISES})
        path_result = construction.construction_bounds(
            path_bound, count, 3, {p: joined for p in construction.PREMISES})
        assert text + events + 79 == 1152 * q + 32 * q * scalar + 7 * raw + 79
        assert all(core_result['guards'].values())
        assert path_result['representation_guards_pass'] is True
        # These historical conditional numbers are now re-derived from the
        # attached initial/later arguments, without rewriting the older packet.
        assert raw == row['conditional_uniform_library_bound_U']
        assert text + events + 79 == row['conditional_uniform_library_bound_L_plus79']
        cases.append({
            'case': row['case'], 'pid': row['pid'], 'Q': q,
            'identifier_occurrences': count,
            'initial_identifier_weighted_bytes_upper': initial_row['initial_identifier_weighted_bytes_upper'],
            'candidate_R': path_bound, 'candidate_U': raw,
            'candidate_d': scalar, 'candidate_B': text, 'candidate_E': events,
            'actual_R_under_supplied_external_premises': path_bound if joined else None,
            'actual_U_under_supplied_external_premises': raw if joined else None,
            'actual_d_under_supplied_external_premises': scalar if joined else None,
            'format_core': core_result, 'path_construction': path_result,
        })
    return {
        'scope': 'Five retained cuts through their selected save continuations; conditional on named external behavior/services',
        'external_premises': {p: premises.get(p, False) for p in EXTERNAL_PREMISES},
        'all_external_premises_supplied': joined,
        'source_arguments_machine_proved': False,
        'runtime_service_success_observed': False,
        'cases': cases,
        'complete_restore_table_lookup_capacity_established': False,
        'complete_allocator_or_pending_callback_capacity_established': False,
        'complete_formatter_capacity_established': False,
        'complete_save_capacity_established': False,
        'whole_pipeline_capacity_established': False,
    }


def check():
    supplied = {p: True for p in EXTERNAL_PREMISES}
    plain, conditional = compose(), compose(supplied)
    for name in EXTERNAL_PREMISES:
        missing = compose({**supplied, name: False})
        assert missing['all_external_premises_supplied'] is False
        for row in missing['cases']:
            assert row['actual_R_under_supplied_external_premises'] is None
            assert row['actual_U_under_supplied_external_premises'] is None
            assert row['format_core']['core_bounds'] is None
            assert row['path_construction']['construction_bounds'] is None
    for row in conditional['cases']:
        assert row['format_core']['core_bounds'] is not None
        assert row['path_construction']['construction_bounds'] is not None
    return {'no_external_assertion': plain,
            'under_named_existing_external_premises': conditional}


if __name__ == '__main__':
    print(json.dumps(check(), indent=2))
