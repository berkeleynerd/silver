"""Attach comparator/strict-hash transfers to the reviewed retained entry."""
from pathlib import Path
import hashlib
import importlib.util
import json
import tarfile

from capacity import add_vectors, hash_transfer, no_resize_transfer, shape, strict_transfer
from profile import extract

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
STATE = HERE.parent / 'retained-why-inline-representative-state-20261018'
REFINEMENT = HERE.parent / 'retained-why-inline-refinement-20261018'


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def archive(path):
    with tarfile.open(path) as source:
        return {row.name: source.extractfile(row).read() for row in source if row.isfile()}


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


def compose():
    manifest = json.loads((HERE / 'inputs.json').read_text())
    for name, expected in manifest['dependencies'].items():
        assert identity((REPO / name).read_bytes()) == expected, name
    assert identity((HERE / 'sources.tar.gz').read_bytes()) == manifest['sources']['identity']
    sources = archive(HERE / 'sources.tar.gz')
    assert {name: identity(data) for name, data in sources.items()} == manifest['sources']['members']
    capture = archive(STATE / 'capture.tar.gz')
    graph = json.loads(capture['capture/inline-entry-graph.json'])
    table = json.loads(capture['capture/hsdecl-table.json'])
    previous = load('comparand_state_checks', STATE / 'project.py')
    previous.validate_graph(graph)
    bucket = previous.validate_table(table, graph)
    attached = json.loads((STATE / 'result.json').read_text())
    assert attached['representative_contract_instantiated_for_retained_entry']
    assert attached['local_structural_and_registration_transfer_established_under_existing_runtime_and_freshness_premises']
    details = json.loads((REFINEMENT / 'details.json').read_text())
    projection, reader = extract(graph, details['root_results'])
    prior_groups = attached['projection']['groups']
    actual_groups = {}
    for row in projection['potential_strict_old_comparands']:
        actual_groups.setdefault(row['declaration_index'], []).append(row['address'])
    assert {row['declaration_index']: row['same_key_old_addresses'] for row in prior_groups if not row['goal_uses_unique']} == actual_groups
    local = attached['attached_local_demands']
    limits = local['structural']
    candidates = {row['declaration_index']: row for row in projection['candidate_formula_bounds']}

    def candidate_shape(row, n=None):
        n = row['n'] if n is None else n
        return shape(n, row['b'], row['p'], row['g'], n,
                     limits['delayed_map_entries_upper'], limits['attribute_set_keys_upper'])

    strict_rows = []
    for row in projection['potential_strict_old_comparands']:
        opened, stored = row['opened'], row['stored']
        old = shape(opened['n'], opened['b'], opened['p'], opened['g'], opened['frame_depth'],
                    stored['saved_map_keys_max'], stored['attribute_keys_max'])
        candidate = candidate_shape(candidates[row['declaration_index']])
        strict_rows.append({'declaration_index': row['declaration_index'], 'old_address': row['address'],
                            'left': old, 'right': candidate, 'upper': strict_transfer(old, candidate)})
    close_rows = []
    hash_rows = []
    for index, row in candidates.items():
        if row['kind'] == 'logic':
            left = candidate_shape(row, row['body_input_n'])
            right = candidate_shape(row, row['body_output_n'])
            close_rows.append({'declaration_index': index, 'left': left, 'right': right,
                               'upper': strict_transfer(left, right)})
        if not row['goal_unique']:
            term = candidate_shape(row)
            hash_rows.append({'declaration_index': index, 'shape': term, 'upper': hash_transfer(term)})
    assert len(close_rows) == 81 and len(hash_rows) == 142
    backing = no_resize_transfer(table['outer_length'], bucket, table['oversize'], table['limit'], len(hash_rows))
    equality = add_vectors(row['upper'] for row in strict_rows)
    close = add_vectors(row['upper'] for row in close_rows)
    hashes = add_vectors(row['upper'] for row in hash_rows)
    events, kernel = local['events'], local['events']['kernel']
    attr_copies = events['hidden_substitution_recursive_term_entries_upper'] + sum(kernel[k] for k in (
        'replace_recursive_entries_upper', 'unfold_entries_upper', 'relocate_recursive_entries_upper',
        'type_map_term_entries_upper', 'post_type_substitution_recursive_entries_upper'))
    shallow = {'t_attr_copy_and_t_similar_calls_upper': attr_copies,
               'physical_type_symbol_child_comparisons_upper': 9*attr_copies,
               'pointer_list_cursor_tests_upper': 8*attr_copies,
               'constant_and_immediate_bigint_comparisons_upper': attr_copies,
               'recursive_term_comparisons': 0, 'custom_numeric_or_string_comparisons': 0,
               'per_call_list_elements_upper': 7}
    term_stats = projection['input_formulas'] + projection['potential_strict_old_comparands']
    max_old = {key: max(row['stored'][key] for row in term_stats) for key in term_stats[0]['stored']}
    maxima = {
        'opened_formula_term_occurrences': max(row['n'] for row in candidates.values()),
        'bound_index_plus_one': 1+max(row['b'] for row in candidates.values()),
        'bound_map_keys': max(row['b'] for row in candidates.values()),
        'delayed_map_keys': max(max_old['saved_map_keys_max'], limits['delayed_map_entries_upper']),
        'attribute_set_keys': max(max_old['attribute_keys_max'], limits['attribute_set_keys_upper']),
        'old_frame_depth': max(row['opened']['frame_depth'] for row in term_stats),
        'candidate_frame_depth': max(row['n'] for row in candidates.values()),
        'pattern_nodes_per_formula': max(row['p'] for row in candidates.values()),
        'trigger_groups_per_formula': max(row['g'] for row in candidates.values()),
        'location_record_immediate_fields': 3,
        'compared_constant_payload_blocks': 2,
        'compared_constant_payload_words_excluding_headers': 3,
        'constant_integer_minimum': min(row['integer'] for row in projection['constant_objects'].values()),
        'constant_integer_maximum': max(row['integer'] for row in projection['constant_objects'].values()),
        'instantiated_type_occurrences': limits['instantiated_type_occurrences_upper'],
        'recursive_type_comparison_entries': 0,
    }
    result = {
        'scope': 'Hsdecl comparison/strict hashing and definition-close strict equality in retained first Input_Is_Valid/cvc5 inline_trivial entry; every metadata-exclusion alternative',
        'complete_initial_objects_classified': len(graph['hsdecl_declaration_roots']),
        'potential_strict_old_comparands': len(strict_rows),
        'initial_objects_rejected_before_formula_comparison': len(projection['shallow_rejected_addresses']),
        'old_objects_scanned_at_most_once_per_own_key': True,
        'local_insertions_reaching_later_strict_comparison': 0,
        'strict_table_comparison_calls_upper': len(strict_rows),
        'definition_close_strict_comparison_calls_upper': len(close_rows),
        'all_strict_comparison_calls_upper': len(strict_rows)+len(close_rows),
        'table_equality_upper': equality,
        'definition_close_equality_upper': close,
        'combined_strict_equality_upper': add_vectors([equality, close]),
        'candidate_strict_hash_upper': hashes,
        'shallow_term_similarity_upper': shallow,
        'Hsdecl_backing_and_callback_transfer': backing,
        'representation_maxima': maxima,
        'all_natural_comparator_counters_fit_signed_ocaml_int': max(maxima[k] for k in maxima if k != 'constant_integer_minimum') < (1 << 62),
        'decl_counter_transfer': attached['Decl.Hsdecl_counter_transfer'],
        'joined_local_demands': local,
        'local_comparator_and_strict_hash_transfer_established_under_existing_premises': True,
        'unsuccessful_Hsdecl_comparand_source_work_bounded': True,
        'custom_numeric_or_string_comparator_input_missing': False,
        'source_argument_machine_checked': False,
        'other_shared_initial_states_instantiated': False,
        'runtime_primitive_lowering_allocation_and_collector_composition_established': False,
        'complete_transform_capacity_established': False,
        'all_fixed_pair_dimensions_established': False,
        'whole_pipeline_capacity_established': False,
        'new_native_runs': 0,
        'validation_kind': 'offline raw-state and source-derived operation/representation arithmetic; not measured native execution or aggregate allocated bytes',
    }
    detail = {'projection': projection, 'table_strict_transfers': strict_rows,
              'definition_close_transfers': close_rows, 'candidate_hash_transfers': hash_rows,
              'stored_input_and_comparand_maxima': max_old}
    return result, detail, graph, table


if __name__ == '__main__':
    print(json.dumps(compose()[0], indent=2))
