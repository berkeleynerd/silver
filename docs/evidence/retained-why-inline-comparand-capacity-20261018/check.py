"""Focused offline state/transfer and rejection checks. No native target runs."""
import json
import time

from capacity import no_resize_transfer, shape, strict_transfer
from compose import HERE, compose
from profile import Profile, extract

start = time.monotonic()
result, details, graph, table = compose()
for name, value in (('result.json', result), ('details.json', details)):
    assert json.loads(json.dumps(value)) == json.loads((HERE / name).read_text()), name
assert result['unsuccessful_Hsdecl_comparand_source_work_bounded']
assert result['local_comparator_and_strict_hash_transfer_established_under_existing_premises']
assert not result['complete_transform_capacity_established']
assert not result['whole_pipeline_capacity_established']
assert result['combined_strict_equality_upper']['term_pair_entries'] == 2450
assert result['candidate_strict_hash_upper']['term_entries'] == 1911
assert result['joined_local_demands']['events']['all_fresh_identifier_registrations_upper'] == 1145
assert result['Hsdecl_backing_and_callback_transfer']['equality_callbacks_upper'] == 11005
assert result['Hsdecl_backing_and_callback_transfer']['bucket_array_length_upper'] == 226
assert sum(row['tag'] == 255 for row in graph['blocks'].values()) > 0
assert set(details['projection']['compared_formula_closure_opaque_tags']) == {252}
for row in details['projection']['potential_strict_old_comparands']:
    opened = row['opened']
    assert opened['resolution_probes'] <= opened['n'] * opened['frame_depth']
checks = []


def reject(label, fn, message=None):
    try:
        fn()
    except AssertionError as exc:
        assert message is None or message in str(exc), (label, str(exc))
        checks.append(label)
    else:
        raise AssertionError(label+' unexpectedly accepted')


# An additional logic-list member cannot be rejected before comparing the
# matched first formula. Force a formerly excluded object to have that prefix.
prior_details = json.loads((HERE.parent / 'retained-why-inline-refinement-20261018/details.json').read_text())
reader = Profile(graph)
input_logic = next(p for p in graph['input_declaration_roots'] if reader.declaration(p)[0] == 3)
key = reader.declaration(input_logic)[1]
old = next(p for p in graph['hsdecl_declaration_roots']
           if reader.declaration(p)[0] == 3 and reader.declaration(p)[1] != key
           and p not in graph['input_declaration_roots'])
bad = dict(graph, blocks=dict(graph['blocks']))
bad['blocks'][str(old)] = dict(graph['blocks'][str(old)], fields=list(graph['blocks'][str(old)]['fields']))
next_address = max(map(int, bad['blocks']))+8


def block(fields, tag=0):
    global next_address
    p = next_address
    next_address += 8*(len(fields)+1)
    bad['blocks'][str(p)] = {'fields': list(fields), 'tag': tag,
                            'words': len(fields), 'header': (len(fields) << 10) | tag}
    return p


input_node = reader.fields(input_logic, 3)[0]
input_list = reader.fields(input_node, 1, tag=3)[0]
first = reader.seq(input_list)[0]
old_node = reader.fields(old, 3)[0]
old_list = reader.fields(old_node, 1, tag=3)[0]
new_list = block([first, old_list])
new_node = block([new_list], tag=3)
bad['blocks'][str(old)]['fields'][0] = new_node
assert Profile(bad).declaration(old)[1] == key
assert Profile(bad).declaration(old)[3] == 2
reject('matched logic prefix before later length mismatch', lambda: extract(bad, prior_details['root_results']))

# Omit a retained object: the projection cannot quietly become a sample.
bad_roots = dict(graph, hsdecl_declaration_roots=graph['hsdecl_declaration_roots'][1:])
reject('omitted initial declaration', lambda: extract(bad_roots, prior_details['root_results']))

# An unused saved value is still inspected. Opening forall v. true never
# reaches that value, so inspecting opened nodes alone would miss the custom.
bad = dict(graph, blocks=dict(graph['blocks']))
reader = Profile(graph)
reader.stored(details['projection']['input_formulas'][0]['formula_address'])
sample = next(p for p in graph['input_declaration_roots'] if reader.declaration(p)[0] == 3)
formula = reader.declaration(sample)[2]
reader.stored(formula)
source = next(row for row in details['projection']['input_formulas'] if row['stored']['saved_entries'])
reader.stored(source['formula_address'])
variable = next(iter(reader.variable_tags.values()))
name, ty = reader.fields(variable, 2)
fresh_name = block(reader.fields(name, 4)[:3] + [2*((1 << 30)-1)+1])
fresh = block([fresh_name, ty])
custom = next(int(p) for p, row in graph['blocks'].items() if row['tag'] == 255)
integer_payload = block([1, custom])
constant = block([integer_payload])
constant_node = block([constant], tag=1)
constant_term = block([constant_node, 1, 1, 1])
unused_map = block([1, fresh, constant_term, 1, 3])
info = block([1, unused_map])
truth = block([1, 1, 1, 1])
variables = block([variable, 1])
binding = block([variables, info, 1, truth])
quant_node = block([1, binding], tag=7)
root = block([quant_node, 1, 1, 1])
assert Profile(bad).opened(root)['n'] == 2
reject('unused custom saved value', lambda: Profile(bad).stored(root), 'expected immediate integer')

# Direct frame-consumption tests: substitution resumes in the remaining outer
# frames; the consumed frame cannot substitute the replacement a second time.
fixture = {'blocks': {}}
def term(address, node, fields):
    fixture['blocks'][str(address)] = {'tag': 0, 'fields': [node, 1, 1, 1]}
    fixture['blocks'][str(node)] = {'tag': 0, 'fields': fields}
term(100, 108, [500])
term(200, 208, [600])
fixture['blocks']['300'] = {'tag': 0, 'fields': [1, 1, 1, 1]}
r = Profile(fixture)
assert r.resolve(100, (((), ((500, 200),)), ((), ((600, 300),)))) == (300, (), 2)
assert r.resolve(100, (((), ((500, 200), (600, 300))),)) == (200, (), 1)
assert r.resolve(100, (((500,), ((500, 300),)),)) == (None, (), 1)
checks.append('remaining-frame substitution and bound-variable precedence')

# Pure transfers propagate a larger map hypothesis; they do not assert actual
# retained coverage from caller-provided numbers or Boolean certificates.
base = shape(91, 8, 2, 3, 91, 36, 80)
small = strict_transfer(base, base)
large = strict_transfer(dict(base, saved_keys=128, attrs=160), base)
assert large['map_lookup_tree_entries'] > small['map_lookup_tree_entries']
assert large['attribute_enumeration_nodes'] > small['attribute_enumeration_nodes']
reject('Boolean numeric substitute', lambda: shape(True, 8, 2, 3, 1, 36, 80))
assert no_resize_transfer(7, 7, 0, 7, 3)['resizes'] == 0
reject('unjustified no-resize extrapolation', lambda: no_resize_transfer(7, 7, 0, 7, 4), 'first resize')
checks.append('larger map/attribute transfer propagation')
print(json.dumps({'status': 'pass', 'elapsed_seconds': round(time.monotonic()-start, 6),
                  'new_native_runs': 0, 'focused_checks': checks}))
