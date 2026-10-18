"""Independent raw-state/count audit; no packet Python modules are imported.

This corroborates the inspected source argument. It is not native execution
or a machine-checked operational-semantics proof.
"""
from collections import Counter
from functools import lru_cache
from pathlib import Path
import hashlib
import json
import tarfile
import time

START = time.monotonic()
HERE = Path(__file__).resolve().parent
EVIDENCE = HERE.parent
PACKET = EVIDENCE / 'retained-why-inline-comparand-capacity-20261018'
STATE = EVIDENCE / 'retained-why-inline-representative-state-20261018'


def archived(path, member):
    with tarfile.open(path) as source:
        return source.extractfile(member).read()


capture_bytes = (STATE / 'capture.tar.gz').read_bytes()
assert hashlib.sha256(capture_bytes).hexdigest() == '5d374cc6d233a717bfc3770839c3322d65d9aaa6feec621b2cfee681d70d1b89'
graph = json.loads(archived(STATE / 'capture.tar.gz', 'capture/inline-entry-graph.json'))
blocks = graph['blocks']
detail = json.loads((PACKET / 'details.json').read_text())
result = json.loads((PACKET / 'result.json').read_text())
semantic = json.loads((EVIDENCE / 'retained-why-inline-refinement-20261018/details.json').read_text())
rows = {r['declaration_index']: r for r in semantic['root_results']}
round_record = json.loads((PACKET / 'round.json').read_text())
for name, expected in round_record['exact_review_inputs'].items():
    content = (HERE.parents[2] / name).read_bytes()
    assert {'bytes': len(content), 'sha256': hashlib.sha256(content).hexdigest()} == expected
with tarfile.open(PACKET / 'sources.tar.gz') as current, tarfile.open(STATE / 'sources.tar.gz') as previous:
    old = {m.name: previous.extractfile(m).read() for m in previous if m.isfile()}
    shared_sources = 0
    for member in current:
        if member.isfile() and member.name in old:
            assert current.extractfile(member).read() == old[member.name]
            shared_sources += 1
assert shared_sources == 26


def fields(p):
    return blocks[str(p)]['fields']


def integer(v):
    assert type(v) is int and v & 1
    return (v - (1 << 64) if v >= 1 << 63 else v) // 2


def sequence(p):
    seen = set()
    while p != 1:
        assert p not in seen
        seen.add(p)
        value, p = fields(p)
        yield value


@lru_cache(None)
def mapping(p):
    if p == 1:
        return ()
    left, key, value, right, _ = fields(p)
    return mapping(left) + ((key, value),) + mapping(right)


def declaration(p):
    node = fields(p)[0]
    tag, values = blocks[str(node)]['tag'], fields(node)
    if tag == 3:
        entries = list(sequence(values[0]))
        if not entries:
            return tag, None, None, 0
        symbol, definition = fields(entries[0])
        return tag, ('logic', symbol), fields(definition)[1], len(entries)
    if tag == 5:
        kind, symbol, formula = fields(values[0])
        return tag, ('prop', kind, symbol), formula, None
    return tag, None, None, None


def children(p):
    """Return direct terms and (bound variables, saved map, triggers, body)."""
    node = fields(p)[0]
    if node & 1:
        return [], []
    tag, x = blocks[str(node)]['tag'], fields(node)
    if tag in (0, 1):
        return [], []
    if tag == 2:
        return list(sequence(x[1])), []
    if tag == 3:
        return list(x), []
    if tag == 4:
        variable, info, body = fields(x[1])
        return [x[0]], [((variable,), fields(info)[1], [], body, 0)]
    if tag == 5:
        bs = []
        for branch in sequence(x[1]):
            pattern, info, body = fields(branch)
            patnode, variables, _ = fields(pattern)
            assert not mapping(variables)
            assert blocks[str(patnode)]['tag'] == 1
            assert not list(sequence(fields(patnode)[1]))
            bs.append(((), fields(info)[1], [], body, 1))
        return [x[0]], bs
    if tag == 6:
        variable, info, body = fields(x[0])
        return [], [((variable,), fields(info)[1], [], body, 0)]
    if tag == 7:
        variables, info, triggers, body = fields(x[1])
        return [], [(tuple(sequence(variables)), fields(info)[1],
                     [list(sequence(group)) for group in sequence(triggers)], body, 0)]
    if tag == 8:
        return list(x[1:]), []
    assert tag == 9
    return list(x), []


raw_terms, constants, locations = set(), {}, set()


@lru_cache(None)
def raw(p):
    raw_terms.add(p)
    node, _, attrs, loc = fields(p)
    if loc != 1:
        locations.add(tuple(integer(v) for v in fields(fields(loc)[0])))
        assert len(fields(fields(loc)[0])) == 3
    if not node & 1 and blocks[str(node)]['tag'] == 1:
        constant = fields(node)[0]
        assert blocks[str(constant)]['tag'] == 0
        payload, = fields(constant)
        kind, value = fields(payload)
        assert 0 <= integer(kind) <= 4
        constants[constant] = integer(value)
    attr_max, saved_max = len(mapping(attrs)), 0
    direct, bindings = children(p)
    for bound, saved, groups, body, patterns in bindings:
        saved_max = max(saved_max, len(mapping(saved)))
        direct.extend(v for _, v in mapping(saved))
        direct.extend(t for group in groups for t in group)
        direct.append(body)
    for child in direct:
        a, s = raw(child)
        attr_max, saved_max = max(attr_max, a), max(saved_max, s)
    return attr_max, saved_max


def opened(p, frames=()):
    depth, probes = len(frames), 0
    # A substitution consumes the matched frame before its replacement is
    # inspected; a bound variable terminates resolution immediately.
    while True:
        node = fields(p)[0]
        if node & 1 or blocks[str(node)]['tag'] != 0:
            break
        variable, = fields(node)
        if not frames:
            break
        bound, saved = frames[0]
        frames = frames[1:]
        probes += 1
        if variable in bound:
            return dict(n=1, b=0, p=0, g=0, frame_depth=depth, resolution_probes=probes)
        replacement = dict(mapping(saved)).get(variable)
        if replacement is not None:
            p = replacement
    counts = dict(n=1, b=0, p=0, g=0, frame_depth=depth, resolution_probes=probes)
    direct, bindings = children(p)
    pending = [(child, frames) for child in direct]
    for bound, saved, groups, body, patterns in bindings:
        counts['b'] += len(bound)
        counts['p'] += patterns
        counts['g'] += len(groups)
        nested = ((bound, saved),) + frames
        pending.extend((t, nested) for group in groups for t in group)
        pending.append((body, nested))
    for child, nested in pending:
        for key, value in opened(child, nested).items():
            counts[key] = max(counts[key], value) if key == 'frame_depth' else counts[key] + value
    return counts


inputs = {}
candidates = {}
for index, address in enumerate(graph['input_declaration_roots']):
    kind, key, formula, length = declaration(address)
    if key is None:
        continue
    assert key not in inputs
    original = opened(formula)
    raw(formula)
    inputs[key] = index
    row = rows[index]
    n, b, p = row['output_coordinates_upper'][:3]
    if kind == 3:
        assert length == 1
        n = max(original['n'], n + row['arity'] + 3)
        b = max(original['b'], b + row['arity'])
    candidates[index] = dict(n=n, b=b, p=max(original['p'], p), g=original['g'])
    expected = next(r for r in detail['projection']['input_formulas'] if r['declaration_index'] == index)
    assert all(original[k] == expected['opened'][k] for k in original)
assert len(inputs) == 143

selected, kinds, lengths = {}, Counter(), Counter()
for address in graph['hsdecl_declaration_roots']:
    kind, key, formula, length = declaration(address)
    kinds[kind] += 1
    if kind == 3:
        lengths[length] += 1
    if key in inputs and key[:2] != ('prop', 5):
        selected[address] = (inputs[key], opened(formula), raw(formula))
assert len(set(graph['hsdecl_declaration_roots'])) == 6704
assert lengths == {1: 1203}
assert len(selected) == 145
assert set(selected) == {r['address'] for r in detail['projection']['potential_strict_old_comparands']}
for row in detail['projection']['potential_strict_old_comparands']:
    index, o, (a, s) = selected[row['address']]
    assert index == row['declaration_index']
    assert all(o[k] == row['opened'][k] for k in o)
    assert (a, s) == (row['stored']['attribute_keys_max'], row['stored']['saved_map_keys_max'])
    assert o['resolution_probes'] <= o['n'] * o['frame_depth']

table_pairs = table_lookups = table_entries = 0
for index, old, (_, saved) in selected.values():
    c = candidates[index]
    q = min(old['n'], c['n'])
    table_pairs += q
    table_lookups += 2*q*(old['frame_depth'] + c['n'])
    table_entries += 2*q*(old['frame_depth']*(max(old['b'], saved)+1)
                          + c['n']*(max(c['b'], 36)+1))
close_pairs = sum(min(r['input'][0], r['output_coordinates_upper'][0]) for r in rows.values() if r['kind'] == 'logic')
hash_terms = sum(candidates[index]['n'] for key, index in inputs.items() if key[:2] != ('prop', 5))
assert (table_pairs, close_pairs, hash_terms) == (2032, 418, 1911)
assert table_lookups == result['table_equality_upper']['map_lookups'] == 130454
assert table_entries == result['table_equality_upper']['map_lookup_tree_entries'] == 4641324
assert len(raw_terms) == 2034 and len(constants) == 38
assert (min(constants.values()), max(constants.values())) == (-2147483648, 2147483647)
extras = set(selected) - set(graph['input_declaration_roots'])
assert sorted(selected[a][0] for a in extras) == [143, 152, 242]

# Direct arithmetic from Weak.Make's first-resize and growth guards. Every
# request contributes at most one new object; old scans finish before mutation.
requests, outer, initial = 142, 5003, 7
assert all(j <= outer//2 for j in range(requests+1))
callbacks = sum(initial+j for j in range(requests))
growth = max((3*occupied)//2+3 for occupied in range(initial+requests+1))
assert (callbacks, growth) == (11005, 226)
assert requests*growth == 32092
assert 6836+143 == 6979
assert 235+6*123+4+168 == 1145

events = result['joined_local_demands']['events']
shallow = events['hidden_substitution_recursive_term_entries_upper'] + sum(events['kernel'][key] for key in (
    'replace_recursive_entries_upper', 'unfold_entries_upper', 'relocate_recursive_entries_upper',
    'type_map_term_entries_upper', 'post_type_substitution_recursive_entries_upper'))
assert shallow == 88985261
assert all(not result[key] for key in ('other_shared_initial_states_instantiated',
    'runtime_primitive_lowering_allocation_and_collector_composition_established',
    'complete_transform_capacity_established', 'whole_pipeline_capacity_established'))

print(json.dumps(dict(status='pass', reviewed_commit='3976f5eec984914ac3e04594fd4d1de3d522a8b1',
    elapsed_seconds=round(time.monotonic()-START, 6), native_runs=0,
    review_input_identities_checked=len(round_record['exact_review_inputs']),
    unchanged_predecessor_source_members=shared_sources,
    imports_packet_python_modules=False, initial_objects=sum(kinds.values()),
    initial_kind_counts=dict(kinds), logic_lengths=dict(lengths), strict_comparands=len(selected),
    unsuccessful_proposition_indexes=sorted(selected[a][0] for a in extras),
    table_term_pairs=table_pairs, close_term_pairs=close_pairs, hash_terms=hash_terms,
    table_map_lookups=table_lookups, table_map_tree_entries=table_entries,
    stored_term_objects=len(raw_terms), integer_constant_objects=len(constants),
    location_records=len(locations), outer_length=outer, bucket_length_upper=growth,
    callback_upper=callbacks, shallow_similarity_calls_upper=shallow), indent=2))
