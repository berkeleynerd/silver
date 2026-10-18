"""Focused offline replay; no target, prover, compiler, debugger or server."""
import copy
import json
import time
from compose import (HERE, PRIOR, INT_MAX, compose, load, counter_transfer,
                     ephemeron_transfer, weak_transfer, numeric_hypothesis,
                     returned_old_map_witness)

start = time.monotonic()
result, inventory = compose()
assert json.loads(json.dumps(result)) == json.loads((HERE / 'result.json').read_text())
assert json.loads(json.dumps(inventory)) == json.loads((HERE / 'inventory.json').read_text())
conditional = result['conditional_arithmetic']
assert conditional['events']['all_fresh_identifier_registrations_upper'] == 1145
assert result['actual_representative_envelope'] is None
assert result['representative_contract']['coverage_evidence'] is None
assert result['representative_contract']['status'] == 'uninstantiated'
assert not result['local_structural_and_registration_transfer_established']
assert not result['complete_transform_capacity_established']
assert not {'events', 'structural', 'shared_groups', 'fresh_groups'} & result.keys()
assert conditional['status'] == 'conditional_on_uninstantiated_representative_contract'
assert 'opened_body_and_eligibility_correspondence' in {
    x['id'] for x in result['representative_contract']['required_invariants']}

# Source-rule witness: a successful merge returns the old equal-opened object;
# subsequent outer opening and a stored-value fold consume that old map.
# This is neither a native observation nor a state-coverage proof.
for steps in (37, 128):
    witness = returned_old_map_witness(steps)
    assert witness['same_opened_alpha_form'] and witness['returned_old_is_selected']
    assert witness['candidate_saved_entries'] == 0
    assert witness['returned_old_saved_entries'] == steps > 36
    assert witness['inner_saved_entries_after_outer_open'] == steps + 1
    assert witness['downstream_saved_value_visits'] == steps + 1
    assert witness['semantic_free_occurrences'] == 1
    assert witness['saved_value_nodes_max'] == 1
    assert not witness['native_observation']

# Propagate a larger supplied numeric envelope through downstream work, but
# never promote its caller's numbers to evidence about the native process.
larger = {'seed_saved_entries_per_formula': 37, 'delayed_value_nodes': 9,
          'type_occurrence_nodes': 5, 'attribute_universe_entries': 4000}
hypothetical, _ = compose(larger)
changed = hypothetical['conditional_arithmetic']
assert changed['structural']['delayed_map_entries_upper'] == 37 + 2 * 14
assert changed['structural']['opening_substitution_map_entries_upper'] == 37 + 3 * 14
stored = 99 * (1 + (37 + 2 * 14) * 9)
assert changed['structural']['stored_term_occurrences_per_formula_upper'] == stored
assert changed['events']['hidden_substitution_recursive_term_entries_upper'] == 4142 * stored
assert changed['events']['symbol_and_type_validator_stored_term_entries_upper'] == (3 * 81 + 143) * stored
assert changed['structural']['instantiated_type_occurrences_upper'] == 25
assert changed['shared_groups']['Ty.Hsty']['weak_merge_requests_upper'] == (156 + 67) * 5
assert changed['structural']['attribute_set_keys_upper'] == 4000
assert changed['structural']['stored_map_height_plus_two_upper'] == 4002
assert not hypothetical['local_structural_and_registration_transfer_established']
assert hypothetical['actual_representative_envelope'] is None
assert hypothetical['representative_contract']['coverage_evidence'] is None
for bad in (True, dict(larger, coverage_established=True),
            dict(larger, seed_saved_entries_per_formula=True),
            dict(larger, delayed_value_nodes=0),
            dict(larger, type_occurrence_nodes=-1)):
    try:
        numeric_hypothesis(bad)
    except AssertionError:
        pass
    else:
        raise AssertionError('invalid numeric hypothesis or coverage flag accepted')

# Independent arithmetic on the six formal-opening sites and full traversals.
prior = json.loads((PRIOR / 'details.json').read_text())
logic = [r for r in prior['root_results'] if r['kind'] == 'logic']
formals = sum(r['arity'] for r in logic)
assert formals == 123
assert 235 + 6 * formals + sum(r['input'][1] for r in logic) + sum(r['input'][1] for r in prior['root_results']) == 1145
assert conditional['events']['hidden_substitution_root_calls_upper'] == 4142
assert conditional['events']['hidden_substitution_recursive_term_entries_upper'] == 4142 * 99 * (1 + 36 * 6)

# Counter boundaries remain conditional, with no inferred initial value.
assert counter_transfer(INT_MAX - 1145, 1145)['signed_ocaml_int_fits']
assert not counter_transfer(INT_MAX - 1144, 1145)['signed_ocaml_int_fits']
for bad in (-1, True, 1.0):
    try:
        counter_transfer(bad, 0)
    except AssertionError:
        pass
    else:
        raise AssertionError('invalid initial counter accepted')

# Exercise inherited backing independently of live-key counts: an otherwise
# empty old table can still have oversized weak buckets and resize once.
w = weak_transfer(5003, 100, 100, 1)
assert w['individual_outer_array_length_upper'] >= 3 * 5003 // 2 + 3
assert w['individual_bucket_length_upper'] >= 100
assert weak_transfer(7, 0, 0, 1000)['individual_bucket_length_upper'] >= 1503
assert ephemeron_transfer(8192, 20000, 17152)['stored_entries_upper'] == 37152

# Enumerate small ephemeron size/GC choices at the real resize threshold.
# Dead entries can remain until cleanup; cleanup may retain any number.
for adds in range(80):
    states = {(16, 0)}
    envelope = ephemeron_transfer(16, 0, adds)
    for _ in range(adds):
        next_states = set()
        for capacity, size in states:
            size += 1
            if size <= 2 * capacity:
                next_states.add((capacity, size))
            else:
                for live in range(size + 1):
                    next_states.add((2 * capacity if live >= capacity // 2 else capacity, live))
        states = next_states
    assert all(c <= envelope['individual_array_length_upper'] and s <= adds for c, s in states)

# The nonunit-value disjointness guard is material. Corrupt one saved value
# so that its free leaf uses an original nonunit key: the packet must reject.
previous = load('inline_operations_check_prior', PRIOR / 'compose.py')
_, details, model = previous.compose()
g = copy.deepcopy(model.g)
inv = load('inline_operations_check_inventory', HERE / 'inventory.py')
unit = next(x for x in inventory['substitutions'] if x['nodes'] == 1)
nd = model.fields(unit['value'], 4)[0]
g['blocks'][str(nd)]['fields'][0] = inventory['nonunit_substitution_keys'][0]
bad_model = previous.Refiner(g)
# Reuse the accepted semantic alternatives only for this negative structural
# guard check; a complete mutated-graph replay is not claimed.
bad_model.environment = model.environment
bad_model.nodes = model.nodes
bad_model.variables = model.variables
bad_model.intern = model.intern
bad_model.nextvar = model.nextvar
try:
    inv.inventory(g, bad_model, details)
except AssertionError as exc:
    assert str(exc) == 'nonunit key occurs in a delayed value'
else:
    raise AssertionError('recursive nonunit substitution dependency accepted')

print(json.dumps({'status': 'pass', 'elapsed_seconds': round(time.monotonic() - start, 6),
                  'native_runs': 0, 'scope': 'conditional arithmetic replay, returned-old representation regression, missing-coverage and envelope propagation checks, structural rejection, counter and backing boundaries'}))
