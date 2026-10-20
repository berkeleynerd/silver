#!/usr/bin/env python3
"""Attach the accepted local inline theorem to one fresh retained entry.

Uses focused graph/table/refinement functions only; no predecessor compose,
observer replay, native target, or inferred whole-continuation capacity.
"""
import argparse
from collections import Counter
import hashlib
import importlib.util
import json
from pathlib import Path
import struct
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
E = ROOT / 'docs/evidence'
FRESH = E / 'retained-why-save-state-capture-20261020'
ENTRY = E / 'retained-why-preparation-entry-20261018'
STATE = E / 'retained-why-inline-representative-state-20261018'
REFINE = E / 'retained-why-inline-refinement-20261018'
OPERATIONS = E / 'retained-why-inline-operations-20261018'
IDENTIFIER = E / 'retained-why-inline-identifier-state-20261018'


def ident(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def canonical(value):
    return json.dumps(value, indent=2, sort_keys=True) + '\n'


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def run(write):
    inputs = json.loads((HERE / 'inputs.json').read_text())
    for path, expected in inputs['files'].items():
        assert ident((ROOT / path).read_bytes()) == expected, path
    capture_manifest = json.loads((FRESH / 'capture-manifest.json').read_text())
    fresh_archives = {r['path']: r for r in capture_manifest['archives']}
    selected_members = {}
    opened = {}

    def read(archive, name):
        if archive not in opened:
            if archive.parent == FRESH:
                record = fresh_archives[archive.name]
                assert ident(archive.read_bytes()) == {k: record[k] for k in ('bytes', 'sha256')}
            opened[archive] = tarfile.open(archive)
        raw = opened[archive].extractfile(name).read()
        actual = ident(raw)
        if archive.parent == FRESH:
            record = fresh_archives[archive.name]
            entry = next(r for r in record['members'] if r['path'] == name)
            assert actual == {k: entry[k] for k in ('bytes', 'sha256')}, name
        selected_members[str(archive.relative_to(ROOT)) + ':' + name] = actual
        return raw

    def read_json(archive, name):
        return json.loads(read(archive, name))

    archive = FRESH / 'capture-input-is-valid.tar.gz'
    prefix = 'inline/input_is_valid/capture/'
    plan = read_json(FRESH / 'capture-common.tar.gz', 'inline/plan.json')
    summary = read_json(archive, prefix + 'summary.json')
    process = read_json(archive, prefix + 'process.json')
    native_result = read_json(archive, prefix + 'result.json')
    g = read_json(archive, prefix + 'inline-entry-graph.json')
    table = read_json(archive, prefix + 'hsdecl-table.json')
    private = read_json(archive, prefix + 'identifier-state.json')
    assert process['pid'] == 17869 and process['initial_threads'] == 1
    assert summary['completed'] and not summary['failures']
    assert not summary['guard_hits'] and not summary['new_threads']
    assert native_result['completed'] and native_result['returncode'] == 0
    assert not native_result['failures'] and not native_result['timed_out']
    assert all(row['hits'] == 0 for row in summary['forbidden_calls'].values())
    assert len(summary['driver_preparation']) == 1
    preparation = summary['driver_preparation'][0]
    assert preparation['driver_tag'] == 0
    assert preparation['visited_directives'] == ['counterexamples_dependent_intros', 'inline_trivial']
    assert len(preparation['directives']) == 15
    assert g['task_address'] == summary['inline_entry']['task']
    assert g['ordered_tdecls'] == summary['inline_entry']['ordered_tdecls']
    assert len(g['ordered_tdecls']) == summary['inline_entry']['shape']['chain_length'] == 512
    assert len(g['input_declaration_roots']) == summary['inline_entry']['declaration_roots'] == 244
    for name, expected in [('inline-entry-graph.json', summary['inline_entry']['graph']),
                           ('hsdecl-table.json', summary['hsdecl_table']['identity']),
                           ('identifier-state.json', summary['identifier_state']['identity'])]:
        assert ident(read(archive, prefix + name)) == expected
    for name, row in table['instruction_checks'].items():
        assert row['first32'] == plan['table_observer']['symbols'][name]['first32']
    assert len(table['instruction_checks']) == 7
    for name, row in private['instruction_checks'].items():
        assert row['first32'] == plan['shared_observer']['symbols'][name]['first32']
    case = plan['inputs'][0]
    assert process['argv'] == case['argv'] and process['environment'] == case['environment']
    assert ident(read(archive, 'inline/input_is_valid/' + case['argv'][-1])) == case['input']
    binary = case['argv'][0]
    assert plan['file_identities'][binary] == summary['mapped_files'][binary]
    assert plan['file_identities'][binary]['sha256'] == '7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368'
    assert plan['source_revision'] == '9390baf120ef260547dfa14f08e11c890b203d9c'
    assert plan['runtime_candidate_revision'] == '8eb41f72ded84df884c3671734c947f612091f84'

    # Reuse the accepted decoder and projection with this process's complete
    # graph/table, without invoking compose() or any capture/replay entry point.
    state = load('fresh_inline_projection', STATE / 'project.py')
    state.validate_graph(g)
    bucket_max = state.validate_table(table, g)
    original = read_json(ENTRY / 'capture.tar.gz', 'capture/inline-entry-graph.json')
    old_plan = read_json(ENTRY / 'capture.tar.gz', 'plan.json')
    old_case = old_plan['inputs'][0]
    assert case['input'] == old_case['input']
    assert old_plan['file_identities'][binary] == plan['file_identities'][binary]
    mapping = state.input_isomorphism(original, g)
    assert len(mapping) == 14477
    assert {g['blocks'][str(p)]['tag'] for p in mapping.values()
            if g['blocks'][str(p)]['tag'] >= 251} == {252}
    details = json.loads((REFINE / 'details.json').read_text())
    projection = state.project(g, details)
    prior = json.loads((STATE / 'result.json').read_text())
    operations = json.loads((OPERATIONS / 'result.json').read_text())
    inventory = json.loads((OPERATIONS / 'inventory.json').read_text())
    refinement = json.loads((REFINE / 'result.json').read_text())
    demand = prior['attached_local_demands']
    assert demand['events'] == operations['conditional_arithmetic']['events']
    assert prior['representative_envelope'] == {
        'seed_saved_entries_per_formula': 8, 'delayed_value_nodes': 6,
        'type_occurrence_nodes': 3, 'attribute_universe_entries': 80}
    kinds = Counter(str(g['blocks'][str(g['blocks'][str(p)]['fields'][0])]['tag'])
                    for p in g['input_declaration_roots'])
    assert dict(kinds) == inventory['logical_declaration_kind_counts']
    registrations = demand['events']['all_fresh_identifier_registrations_upper']
    assert registrations == 235 + 6*123 + 4 + 168 == 1145
    assert demand['events']['kernel'] == refinement['kernel_events']
    initial_result = json.loads((E / 'retained-why-initial-registration-bound-20261020/result.json').read_text())
    initial = next(r for r in initial_result['cases'] if r['pid'] == process['pid'])
    current = private['counter']
    assert current['fields'] == list(struct.unpack('<Q', bytes.fromhex(current['payload_hex'])))
    assert state.decoded(current['fields'][0]) == current['decoded'] == 60496
    assert current['decoded'] == summary['identifier_state']['counter'] == initial['initial_registration_count']
    assert initial_result['initial_no_wrap_established_under_named_relation']
    counter = load('fresh_inline_counter', IDENTIFIER / 'counter.py')
    transfer = counter.registration_transfer(current['decoded'], registrations)
    comparand = json.loads((E / 'retained-why-inline-comparand-capacity-20261018/result.json').read_text())
    assert comparand['joined_local_demands']['events']['all_fresh_identifier_registrations_upper'] == registrations

    root_pairs = list(zip(original['roots'], g['input_declaration_roots']))
    result = {
        'scope': 'Fresh PID17869 first Input_Is_Valid/CVC5 inline_trivial entry; one local source invocation',
        'author_base': inputs['author_base'], 'pid': process['pid'],
        'source_revision': plan['source_revision'], 'runtime_revision': plan['runtime_candidate_revision'],
        'visited_directives': preparation['visited_directives'],
        'prepared_task_nodes': len(g['ordered_tdecls']), 'logical_roots': len(root_pairs),
        'logical_declaration_kind_counts': dict(sorted(kinds.items())),
        'exact_prepared_input_isomorphism': {
            'blocks': len(mapping), 'root_pairs': root_pairs,
            'mapping_sha256': ident(canonical(sorted(mapping.items())).encode())['sha256'],
            'preserves': ['sharing', 'constructor_tags', 'sizes', 'immediate_values',
                          'all_opaque_payload_bytes', 'attributes', 'types', 'saved_substitutions'],
            'input_opaque_tags': [252], 'custom_payload_normalization_used': False},
        'fresh_complete_Hsdecl': {
            'outer_buckets': table['outer_length'], 'allocated_slots': table['allocated_key_slots'],
            'nonempty_slots': table['nonempty_key_slots'], 'old_objects': len(g['hsdecl_declaration_roots']),
            'maximum_bucket_length': bucket_max, 'next_tag': table['next_tag'],
            'combined_graph_blocks': len(g['blocks']), 'combined_graph_bytes': g['retained_payload_bytes']},
        'representative_envelope': prior['representative_envelope'],
        'fresh_projection_summary': {k: v for k, v in projection.items() if k != 'groups'},
        'refinement_coordinate_sums_upper': refinement['output_root_coordinate_sums_upper'],
        'metadata_exclusion_set_observed': False, 'all_metadata_exclusion_sets_covered': True,
        'source_registration_charge': {'kernel': 235, 'logic_formals_outside_kernel': 738,
                                       'logic_termination_body': 4, 'task_check_match_body': 168,
                                       'total': registrations},
        'fresh_counter_plus_source_charge': transfer,
        'local_source_registration_bound_attached_under_existing_premises': True,
        'pending_save_report_registration_charge_included': False,
        'whole_continuation_registration_bound': None,
        'global_suffix_budget': {'save_entering_callbacks': 2, 'save_attempts': 3, 'e_upper': 2},
        'other_tasks_drivers_transforms_bound_by_1145': False,
        'complete_native_transform_capacity': False,
        'native_solver_proof_capture_runs': 0, 'predecessor_compose_or_observer_replays': 0,
        'selected_members': selected_members,
        'note_identity': ident((ROOT / 'docs/research/retained-why-fresh-inline-attachment.md').read_bytes()),
        'verification_scope': 'Finite graph/table validation, exact input isomorphism, fresh representative projection and arithmetic; reused semantic source theorem remains a reviewed argument.',
    }
    for name, value in [('result.json', result), ('projection.json', projection)]:
        data = canonical(value)
        if write:
            (HERE / name).write_text(data)
        else:
            assert (HERE / name).read_text() == data, name
    for stream in opened.values():
        stream.close()
    print(f'checked {len(inputs["files"])} pinned inputs; PID 17869: 244 roots, 14477 input blocks, '
          '6704 old objects, 143 mapped keys; local Ident 60496 + 1145 = 61641')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    run(parser.parse_args().write)
