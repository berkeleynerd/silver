"""Conditional demand arithmetic for one frozen inline_trivial invocation.

No native run. Natural-number arithmetic only. Shared-state transfers do not
invent an initial counter/table state or certify the entire process.
"""
from pathlib import Path
import hashlib
import importlib.util
import json
import tarfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
PRIOR = HERE.parent / 'retained-why-inline-refinement-20261018'
INT_MAX = (1 << 62) - 1


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    m = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(m)
    return m


representatives = load('inline_operations_representatives', HERE / 'representatives.py')
CONTRACT = representatives.CONTRACT
numeric_hypothesis = representatives.numeric_hypothesis
returned_old_map_witness = representatives.returned_old_map_witness


def identity(b):
    return {'bytes': len(b), 'sha256': hashlib.sha256(b).hexdigest()}


def natural(n):
    assert type(n) is int and n >= 0
    return n


def counter_transfer(initial, increments):
    end = natural(initial) + natural(increments)
    return {'initial': initial, 'increments_upper': increments,
            'final_upper': end, 'signed_ocaml_int_fits': end <= INT_MAX}


def ephemeron_transfer(initial_array, initial_entries, additions):
    """GenHashTable.MakeSeeded, including dead retained entries and cleaning.

    initial_entries is the stored size counter, not a live-key observation.
    The caller supplies a valid initial table with no concurrent insertions.
    """
    natural(initial_array); natural(initial_entries); natural(additions)
    assert initial_array >= 16 and initial_array & (initial_array - 1) == 0
    n = initial_entries + additions
    # Resizing cleans first; growth requires live size >= old_array / 2.
    # Thus every new array has length <= 4*n, even with arbitrary collection.
    a = max(initial_array, 4 * n)
    return {'stored_entries_upper': n, 'individual_array_length_upper': a,
            'old_plus_new_array_slots_upper': 2 * a,
            'resize_multiply_or_threshold_upper': 2 * a,
            'single_bucket_chain_cells_upper': n,
            'representation_condition': '2*array_upper <= min(max_int, Sys.max_array_length); valid initial table'}


def weak_transfer(initial_array, initial_bucket_max, initial_allocated_slots, requests):
    """Weak.Make backing envelope, permitting clearing/shrink/reinsertion.

    All initial allocated bucket slots count, including empty weak slots.
    requests counts external merge/add calls; internal rehashing is covered
    by the fresh-table argument, not charged as new distinct objects.
    """
    for n in (initial_array, initial_bucket_max, initial_allocated_slots, requests):
        natural(n)
    assert initial_array >= 7 and initial_bucket_max <= initial_allocated_slots
    n = initial_allocated_slots + requests
    # The inherited table may resize once because of historical oversize
    # buckets. A table built by rehashing starts empty. For such a table,
    # oversize <= objects inserted <= n; a resize trigger implies oldlen<2*n.
    a = max(initial_array, 3 * initial_array // 2 + 3, 3 * n + 3)
    b = max(initial_bucket_max, 3 * n // 2 + 3)
    return {'live_entries_upper': n, 'individual_outer_array_length_upper': a,
            'individual_bucket_length_upper': b,
            'outer_growth_multiply_upper': 3 * a,
            'bucket_growth_multiply_upper': 3 * b,
            'shrink_multiply_plus_two_absolute_upper': 2 * b + 6,
            'oversize_and_rover_upper': a,
            'find_or_equality_calls_per_request_upper': b,
            'representation_condition': '3*max(array_upper,bucket_upper)+6 <= max_int; array_upper <= Sys.max_array_length; bucket_upper+2 <= Obj.Ephemeron.max_ephe_length'}


def compose(envelope_hypothesis=None):
    """Return conditional arithmetic; never certify representative coverage.

    With no argument, the numerical hypothesis copies the captured profile.
    That is an illustration of the missing premise, not its instantiation.
    Numeric caller input changes the conditional arithmetic only.
    """
    manifest = json.loads((HERE / 'inputs.json').read_text())
    for path, expected in manifest['dependencies'].items():
        assert identity((REPO / path).read_bytes()) == expected, path
    assert identity((HERE / 'sources.tar.gz').read_bytes()) == manifest['sources']['identity']
    with tarfile.open(HERE / 'sources.tar.gz') as archive:
        actual = {m.name: identity(archive.extractfile(m).read()) for m in archive.getmembers() if m.isfile()}
    assert actual == manifest['sources']['members']
    previous = load('inline_operations_prior', PRIOR / 'compose.py')
    compact, details, model = previous.compose()
    graph = model.g
    inv = load('inline_operations_inventory', HERE / 'inventory.py').inventory(graph, model, details)
    rows = details['root_results']
    logic = [x for x in rows if x['kind'] == 'logic']
    n = sum(x['input'][0] for x in rows)
    b = sum(x['input'][1] for x in rows)
    ln = sum(x['input'][0] for x in logic)
    lb = sum(x['input'][1] for x in logic)
    arity = sum(x['arity'] for x in logic)
    root_mass = compact['maximum_reconstructed_formula_mass_upper']
    path_slots = max(x['input'][1] for x in rows) + max(x['arity'] for x in logic)
    captured_profile = {
        'seed_saved_entries_per_formula': inv['raw_substitution_entries'],
        'delayed_value_nodes': inv['delayed_value_nodes_max'],
        'type_occurrence_nodes': inv['type_occurrence_nodes_max'],
        'attribute_universe_entries': inv['attribute_universe_entries'],
    }
    supplied = envelope_hypothesis is not None
    hypothesis = numeric_hypothesis(envelope_hypothesis if supplied else captured_profile)
    effective = {k: max(captured_profile[k], hypothesis[k]) for k in captured_profile}
    # Conditional on CONTRACT, one inlining traversal plus one independent
    # validation traversal. Old selected declarations are additional seeds. Repeated
    # validators start from the immutable declaration, not a previous validator's
    # freshly opened result. Original keys may propagate from ancestor maps,
    # so charge all eight initial entries, not just the largest original map.
    k = effective['seed_saved_entries_per_formula'] + 2 * path_slots
    value = effective['delayed_value_nodes']
    stored = root_mass * (1 + k * value)
    # t_subst_unsafe stops at raw binder bodies and visits their saved values.
    # The full stored-tree envelope also pays for multi-branch/multi-trigger
    # frontiers. Original mapping, logic termination and task check_match are
    # the only recursively opening walks; six sites open definition formals.
    pattern_nodes = compact['output_root_coordinate_sums_upper']['p']
    starts = 2 * n + ln + 6 * len(logic) + pattern_nodes
    hidden = starts * stored
    # These are all fresh registrations. Nullary pattern compilation has none.
    fresh = compact['kernel_events']['fresh_variable_identifiers_inside_kernel_upper'] + 6 * arity + lb + b
    type_size = effective['type_occurrence_nodes']
    hit_nodes = compact['kernel_events']['type_map_term_entries_upper']
    hit_free = sum(sum(c > 0 for c in h['formal_occurrences']) for h in details['symbol_matched_optional_hits'])
    type_calls = (hit_nodes + hit_free) * type_size
    # ty_inst substitutes each type-variable leaf once; replacing by an actual
    # type of size <=type_size gives this bound even for intermediate types
    # erased by the final term substitution.
    instantiated_type_size = type_size * type_size
    logical = len(graph['roots'])
    task_nodes = compact['input_task_nodes']
    meta = 192
    history = 192 + 42 + 34
    patricia = 64 * history
    folds = 3 * len(logic) + len(rows)
    fixed_type_visits = inv['known_identifier_keys_upper'] * (inv['application_arity_max'] + 1) * type_size
    free_scans = hidden * root_mass * value + (n + len(logic) + len(rows) + len(logic) * inv['application_arity_max']) * stored + hit_nodes
    conditional = {
        'status': 'conditional_on_uninstantiated_representative_contract',
        'hypothesis_origin': 'caller_numeric_hypothesis' if supplied else 'captured_profile_used_as_hypothesis_only',
        'numeric_envelope_hypothesis': hypothesis,
        'effective_envelope_including_capture': effective,
        'scope': compact['scope'],
        'covers_every_metadata_exclusion_set': True,
        'metadata_exclusion_set_known': False,
        'structural': {
            'output_task_nodes_upper': task_nodes,
            'maximum_semantic_formula_mass_upper': root_mass,
            'maximum_formal_plus_body_bound_slots_upper': path_slots,
            'delayed_map_entries_upper': k,
            'opening_substitution_map_entries_upper': k + path_slots,
            'delayed_value_term_nodes_upper': value,
            'stored_term_occurrences_per_formula_upper': stored,
            'semantic_free_count_or_intermediate_product_upper': root_mass,
            'instantiated_type_occurrences_upper': instantiated_type_size,
            'type_substitution_keys_upper': inv['signature_type_variables_max'],
            'known_identifier_map_keys_upper': inv['known_identifier_keys_upper'],
            'inline_environment_keys_upper': compact['environment_entries_upper'],
            'inline_no_set_keys_upper': meta,
            'task_meta_map_keys_upper': meta,
            'task_clone_map_keys_upper': 42 + 34,
            'each_history_set_keys_upper': history,
            'attribute_set_keys_upper': effective['attribute_universe_entries'],
            'variable_count_map_keys_upper': root_mass,
            'stored_map_height_plus_two_upper': max(k, root_mass, inv['known_identifier_keys_upper'], history, effective['attribute_universe_entries']) + 2,
        },
        'events': {
            'kernel': compact['kernel_events'],
            'logic_definition_open_calls_upper': 6 * len(logic),
            'logic_formal_registrations_outside_kernel_upper': 6 * arity,
            'logic_termination_opened_term_entries_upper': ln,
            'logic_termination_body_registrations_upper': lb,
            'task_check_match_opened_term_entries_upper': n,
            'task_check_match_body_registrations_upper': b,
            'pattern_compile_variable_registrations_upper': 0,
            'all_fresh_identifier_registrations_upper': fresh,
            'hidden_substitution_root_calls_upper': starts,
            'hidden_substitution_recursive_term_entries_upper': hidden,
            'hidden_binder_substitution_updates_upper': hidden,
            'free_variable_scan_term_entries_upper': free_scans,
            'symbol_and_type_validator_stored_term_entries_upper': folds * stored,
            'symbol_type_fold_recursive_type_entries_upper': folds * (stored + root_mass) * instantiated_type_size + 3 * len(logic) * inv['application_arity_max'] * type_size + fixed_type_visits,
            'unchanged_declaration_symbol_type_entries_upper': fixed_type_visits,
            'definition_close_strict_comparisons_upper': len(logic),
            'definition_close_semantic_node_pairs_upper': len(logic) * root_mass,
            'candidate_decl_hash_semantic_node_entries_upper': len(rows) * root_mass,
            'type_instantiation_recursive_entries_and_hashcons_requests_upper': type_calls,
            'type_matching_recursive_entries_upper': (compact['kernel_events']['unfold_entries_upper'] + hit_nodes + 2 * len(logic) + 5 * compact['output_root_coordinate_sums_upper']['p']) * (inv['application_arity_max'] + 1) * instantiated_type_size,
            'unchanged_data_revalidation_calls_upper': inv['ground_data_declarations'],
            'data_positivity_ground_argument_checks_upper': inv['data_constructor_argument_checks'],
            'data_positivity_extract_pos_calls_upper': inv['foundedness_type_entries_upper'] - inv['ground_data_declarations'],
            'data_foundedness_type_entries_upper': inv['foundedness_type_entries_upper'],
            'data_foundedness_constructor_entries_upper': inv['foundedness_constructor_entries_upper'],
            'data_declaration_constructor_calls_upper': 0,
            'pattern_match_compile_calls_upper': compact['output_root_coordinate_sums_upper']['p'],
            'new_named_type_or_logic_or_prop_symbols_upper': 0,
        },
        'shared_groups': {
            'Ident.id_register': {'increments_upper': fresh, 'initial_counter_required': True},
            'Decl.Hsdecl': {'increments_upper': len(rows), 'weak_merge_requests_upper': len(rows), 'initial_state_required': True},
            'Theory.Hstdecl': {'increments_upper': logical, 'weak_merge_requests_upper': logical, 'initial_state_required': True},
            'Task.Hstask': {'increments_upper': task_nodes, 'weak_merge_requests_upper': task_nodes, 'initial_state_required': True},
            'Ty.Hsty': {'increments_upper': type_calls, 'weak_merge_requests_upper': type_calls, 'initial_state_required': True},
            'Task.Stdecl.Hcpt': {'increments_upper': patricia, 'ephemeron_additions_upper': patricia, 'initial_state_required': True},
        },
        'fresh_groups': {
            'inline_fold_Wtask': {'instances_upper': 1, 'create_argument': 63, 'finds_upper': task_nodes, 'sets_upper': task_nodes - 1,
                                 'backing': ephemeron_transfer(64, 0, task_nodes - 1)},
            'inline_meta_Wtds': {'instances_upper': 1, 'create_argument': 17, 'finds_upper': 1, 'sets_upper': 1,
                                 'backing': ephemeron_transfer(32, 0, 1)},
            'hit_type_Wty': {'instances_upper': compact['kernel_events']['environment_hits_upper'], 'create_argument': 17,
                            'all_instances_finds_and_sets_upper': hit_nodes,
                            'per_instance_backing': ephemeron_transfer(32, 0, compact['maximum_saved_hit_body_mass_upper'])},
            'termination_Hid': {'instances_upper': 2 * len(logic), 'create_argument': 5,
                                'insertions_upper': 0, 'initial_and_final_array_length': 16},
        },
    }
    result = {
        'scope': compact['scope'],
        'representative_contract': CONTRACT,
        'actual_representative_envelope': None,
        'conditional_arithmetic': conditional,
        'returned_old_regression': returned_old_map_witness(),
        'selection_independent_topology_requests': {
            'premise': 'fixed captured task spine, valid shared tables and no foreign concurrent insertions',
            'Decl.Hsdecl_requests_upper': len(rows),
            'Theory.Hstdecl_requests_upper': logical,
            'Task.Hstask_requests_upper': task_nodes,
            'Task.Stdecl.Hcpt_additions_upper': patricia,
            'inline_fold_Wtask': conditional['fresh_groups']['inline_fold_Wtask'],
            'inline_meta_Wtds': conditional['fresh_groups']['inline_meta_Wtds'],
            'does_not_bound_callback_work_or_counter_initial_states': True,
        },
        'call_graph_coverage': {
            'captured_input_inventory': 'checked on captured roots only',
            'semantic_kernel_runtime_attachment': 'requires opened-body and eligibility representative correspondence',
            'original_and_hidden_substitution_operations': 'conditional arithmetic; selectable old representative envelope missing',
            'type_map_and_declaration_validators': 'conditional arithmetic; stored type/symbol/attribute closure missing',
            'fresh_ids_outside_kernel': 'six opening sites counted; 1145 requires representative semantic/shape contract',
            'task_meta_clone_and_transform_wrappers': 'selection-independent topology requests; callback work conditional',
            'global_hashcons_and_Patricia_tables': 'pure initial-state transfers retained; initial state missing',
            'shared_Decl_Hsdecl_returned_representatives': 'downstream inputs, not merely collision comparands; coverage missing',
            'shared_Decl_Hsdecl_collision_comparands': 'unsuccessful-comparand frame/attribute costs also uninstantiated',
            'runtime_allocation_and_collection': 'requires process-lifetime allocation/collector composition',
        },
        'local_structural_and_registration_transfer_established': False,
        'complete_transform_capacity_established': False,
        'shared_initial_state_instantiated': False,
        'all_fixed_pair_dimensions_established': False,
        'whole_pipeline_capacity_established': False,
        'source_argument_machine_checked': False,
        'new_native_runs': 0,
    }
    return result, inv


if __name__ == '__main__':
    print(json.dumps(compose()[0], indent=2))
