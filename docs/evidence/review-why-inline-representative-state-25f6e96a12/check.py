"""Independent raw-coordinate/slot audit; no Refiner/project imports or native run."""
from pathlib import Path
import hashlib
import json
import tarfile
import time

started = time.monotonic()
HERE = Path(__file__).resolve().parent
PACKET = HERE.parent / 'retained-why-inline-representative-state-20261018'
REFINEMENT = HERE.parent / 'retained-why-inline-refinement-20261018'
with tarfile.open(PACKET / 'capture.tar.gz') as archive:
    raw = archive.extractfile('capture/inline-entry-graph.json').read()
    assert hashlib.sha256(raw).hexdigest() == 'c6e8be9fc2e4243c4b6c0c78ac437fdd531ccba477f9a4b85f3f6c7d1c33f1ed'
    graph = json.loads(raw)
    table = json.loads(archive.extractfile('capture/hsdecl-table.json').read())
blocks = graph['blocks']
result = json.loads((PACKET / 'result.json').read_text())
details = json.loads((REFINEMENT / 'details.json').read_text())


def fields(pointer):
    return blocks[str(pointer)]['fields']


def sequence(pointer):
    out = []
    while pointer != 1:
        value, pointer = fields(pointer)
        out.append(value)
    return out


def tree(pointer):
    if pointer == 1:
        return {}
    left, key, value, right, _ = fields(pointer)
    return tree(left) | {key: value} | tree(right)


def binding(raws, info):
    return set(raws), tree(fields(info)[1])


def pattern_count(pointer):
    node, _, _ = fields(pointer)
    if node & 1:
        return 1
    row = blocks[str(node)]
    tag, values = row['tag'], row['fields']
    children = [] if tag == 0 else sequence(values[1]) if tag == 1 else values if tag == 2 else values[:1]
    return 1 + sum(pattern_count(child) for child in children)


def descend(pointer, frames):
    node = fields(pointer)[0]
    if node & 1 or blocks[str(node)]['tag'] != 0:
        return pointer, frames, False
    raw = fields(node)[0]
    for index, (bound, substitution) in enumerate(frames):
        if raw in bound:
            return pointer, (), True
        if raw in substitution:
            return descend(substitution[raw], frames[index + 1:])
    return pointer, (), False


def count(pointer, frames=()):
    pointer, frames, bound = descend(pointer, frames)
    node = fields(pointer)[0]
    if bound or node & 1:
        return 1, 0, 0, 0
    row = blocks[str(node)]
    tag, values = row['tag'], row['fields']
    base, children = [1, 0, 0, int(tag == 2)], []
    if tag in (0, 1):
        pass
    elif tag == 2:
        children = [(child, frames) for child in sequence(values[1])]
    elif tag == 3:
        children = [(child, frames) for child in values]
    elif tag in (4, 6):
        variable, info, body = fields(values[1] if tag == 4 else values[0])
        base[1] = 1
        children = [(body, (binding([variable], info),) + frames)]
        if tag == 4:
            children.append((values[0], frames))
    elif tag == 5:
        children = [(values[0], frames)]
        for branch in sequence(values[1]):
            pattern, info, body = fields(branch)
            raws = tree(fields(pattern)[1])
            base[1] += len(raws)
            base[2] += pattern_count(pattern)
            children.append((body, (binding(raws, info),) + frames))
    elif tag == 7:
        raw, info, triggers, body = fields(values[1])
        raws = sequence(raw)
        base[1] = len(raws)
        nested = (binding(raws, info),) + frames
        children = [(body, nested)] + [(child, nested) for trigger in sequence(triggers) for child in sequence(trigger)]
    elif tag == 8:
        children = [(child, frames) for child in values[1:]]
    elif tag == 9:
        children = [(values[0], frames)]
    else:
        raise AssertionError(tag)
    for child, nested in children:
        base = [left + right for left, right in zip(base, count(child, nested))]
    return tuple(base)


input_counts = {}
for index, pointer in enumerate(graph['input_declaration_roots']):
    node, _, _ = fields(pointer)
    row = blocks[str(node)]
    values = row['fields']
    if row['tag'] == 5:
        input_counts[index] = count(fields(values[0])[2])
    elif row['tag'] == 3:
        pairs = sequence(values[0])
        assert len(pairs) == 1
        _, definition = fields(pairs[0])
        _, axiom, _ = fields(definition)
        axiom_row, frames = blocks[str(fields(axiom)[0])], ()
        if axiom_row['tag'] == 7:
            raw, info, _, axiom = fields(axiom_row['fields'][1])
            frames = (binding(sequence(raw), info),)
            axiom_row = blocks[str(fields(axiom)[0])]
        assert axiom_row['tag'] in (2, 8)
        body = sequence(axiom_row['fields'][1])[1] if axiom_row['tag'] == 2 else axiom_row['fields'][2]
        input_counts[index] = count(body, frames)
assert len(input_counts) == 143
for row in details['root_results']:
    assert input_counts[row['declaration_index']] == tuple(row['input'])

exclusions = []
for row in result['projection']['strict_shape_exclusions']:
    node = fields(row['address'])[0]
    formula = fields(fields(node)[0])[2]
    actual = count(formula)
    assert actual == tuple(row['opened_coordinates'])
    assert any(value > ceiling for value, ceiling in zip(actual, row['candidate_coordinates_upper']))
    exclusions.append({'declaration_index': row['declaration_index'], 'coordinates': actual,
                       'bound': row['candidate_coordinates_upper']})

slots = [key for bucket in table['buckets'] for key in bucket['payload'][2:]]
occupied = [key for key in slots if key != table['ephe_none_value']]
assert len(table['buckets']) == 5003 and len(slots) == 11968
assert len(occupied) == len(set(occupied)) == 6704
assert set(occupied) == set(graph['hsdecl_declaration_roots'])
assert 235 + 6 * 123 + 4 + 168 == result['attached_local_demands']['events']['all_fresh_identifier_registrations_upper'] == 1145
print(json.dumps({'status': 'pass', 'input_roots_independently_counted': len(input_counts),
                  'strict_shape_exclusions': exclusions, 'all_slots_counted': len(slots),
                  'distinct_occupied_slots': len(set(occupied)), 'new_native_runs': 0,
                  'elapsed_seconds': round(time.monotonic() - started, 6)}, indent=2))
