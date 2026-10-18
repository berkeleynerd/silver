"""Focused offline replay; no target, prover, compiler, debugger or server."""
import copy
import json
import time
from compose import HERE, PRIOR, INT_MAX, compose, load, counter_transfer, ephemeron_transfer, weak_transfer

start = time.monotonic()
result, inventory = compose()
assert json.loads(json.dumps(result)) == json.loads((HERE / 'result.json').read_text())
assert json.loads(json.dumps(inventory)) == json.loads((HERE / 'inventory.json').read_text())
assert result['events']['all_fresh_identifier_registrations_upper'] == 1145
assert not result['complete_transform_capacity_established']

# Independent arithmetic on the six formal-opening sites and full traversals.
prior = json.loads((PRIOR / 'details.json').read_text())
logic = [r for r in prior['root_results'] if r['kind'] == 'logic']
formals = sum(r['arity'] for r in logic)
assert formals == 123
assert 235 + 6 * formals + sum(r['input'][1] for r in logic) + sum(r['input'][1] for r in prior['root_results']) == 1145
assert result['events']['hidden_substitution_root_calls_upper'] == 4142
assert result['events']['hidden_substitution_recursive_term_entries_upper'] == 4142 * 99 * (1 + 36 * 6)

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
                  'native_runs': 0, 'scope': 'frozen local-demand replay, structural rejection, counter and backing boundary checks'}))
