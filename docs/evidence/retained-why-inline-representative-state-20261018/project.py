"""Offline completeness, source-shape and selectable-representative projection.

No native execution. Native source arguments are stated in the accompanying
note; these checks do not claim machine-checked OCaml semantics.
"""
from pathlib import Path
from collections import Counter, defaultdict
import hashlib
import importlib.util
import json
import tarfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
ENTRY = HERE.parent / 'retained-why-preparation-entry-20261018'
REFINEMENT = HERE.parent / 'retained-why-inline-refinement-20261018'
OPERATIONS = HERE.parent / 'retained-why-inline-operations-20261018'


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def load(name, path):
    spec = importlib.util.spec_from_file_location(name, path)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    return module


def read_archive(path):
    with tarfile.open(path) as archive:
        return {m.name: archive.extractfile(m).read() for m in archive.getmembers() if m.isfile()}


def decoded(raw):
    assert type(raw) is int and raw & 1
    return (raw - (1 << 64) if raw >= 1 << 63 else raw) >> 1


def validate_graph(g):
    blocks = g['blocks']
    total = 0
    for p, row in blocks.items():
        assert int(p) > 0 and int(p) % 8 == 0
        assert row['header'] & 255 == row['tag']
        assert row['header'] >> 10 == row['words']
        total += 8 * (row['words'] + 1)
        if row['tag'] < 246:
            assert len(row['fields']) == row['words']
            assert all(v & 1 or str(v) in blocks for v in row['fields']), 'missing graph edge'
        else:
            assert row['tag'] in (252, 255), 'unsupported retained opaque tag'
            assert len(bytes.fromhex(row['payload_hex'])) == 8 * row['words']
    assert total == g['retained_payload_bytes']
    assert sorted({v['tag'] for v in blocks.values() if v['tag'] >= 251}) == g['opaque_tags']
    seen, pending = set(), list(g['roots'])
    while pending:
        p = pending.pop()
        if p & 1 or p in seen:
            continue
        seen.add(p)
        pending.extend(blocks[str(p)].get('fields', ()))
    assert seen == set(map(int, blocks)), 'graph coverage differs from declared roots'


def validate_table(t, g):
    assert t['module_hsdecl_offset'] == 704
    assert t['module_header'] & 255 == 0 and t['module_header'] >> 10 > 88
    assert len(t['hsdecl_fields']) == 4
    assert t['hsdecl_fields'][0] == t['hashcons_closure_address']
    assert t['hashcons_closure_header'] & 255 == 247
    assert t['hashcons_closure_header'] >> 10 == 6
    cl = t['hashcons_closure_fields']
    assert len(cl) == 6 and cl[4] == t['table_address'] and cl[3] == t['next_tag_ref']
    assert cl[0] == t['instruction_checks']['camlWhy3__Hashcons__hashcons_412']['address']
    record = t['table_fields']
    assert t['table_header'] & 255 == 0 and t['table_header'] >> 10 == len(record) == 5
    assert record[:2] == [t['outer_array']['address'], t['hash_outer_array']['address']]
    assert list(map(decoded, record[2:])) == [t[k] for k in ('limit', 'oversize', 'rover')]
    assert decoded(t['next_tag_raw']) == t['next_tag']
    length = t['outer_length']
    assert len(t['buckets']) == length >= 7
    for name in ('outer_array', 'hash_outer_array'):
        array = t[name]
        assert array['header'] & 255 == 0 and array['header'] >> 10 == len(array['fields']) == length
    roots, slots, present = [], 0, 0
    seen, bucket_max, oversize = set(), 0, 0
    for i, row in enumerate(t['buckets']):
        assert row['index'] == i, 'omitted or reordered bucket'
        assert row['address'] == t['outer_array']['fields'][i]
        assert row['hash_array']['address'] == t['hash_outer_array']['fields'][i]
        payload, hashes = row['payload'], row['hash_array']
        assert row['header'] & 255 == 251 and row['header'] >> 10 == len(payload) >= 2
        assert payload[1] == t['ephe_none_value']
        assert hashes['header'] & 255 == 0
        assert hashes['header'] >> 10 == len(hashes['fields']) == len(payload) - 2
        size = len(payload) - 2
        slots += size
        bucket_max = max(bucket_max, size)
        oversize += size > t['limit']
        for key, raw_hash in zip(payload[2:], hashes['fields']):
            h = decoded(raw_hash)
            if key == t['ephe_none_value']:
                continue
            assert (h & ((1 << 62) - 1)) % length == i, 'cached hash in wrong bucket'
            assert not key & 1 and str(key) in g['blocks'], 'missing retained key root'
            block = g['blocks'][str(key)]
            assert block['tag'] == 0 and block['words'] == 3
            present += 1
            if key not in seen:
                roots.append(key)
                seen.add(key)
    assert roots == t['retained_unique_declarations'] == g['hsdecl_declaration_roots']
    assert slots == t['allocated_key_slots'] and present == t['nonempty_key_slots']
    assert oversize == t['oversize'] and 0 <= t['rover'] < length
    assert g['roots'] == list(dict.fromkeys(g['input_declaration_roots'] + roots))
    return bucket_max


def input_isomorphism(old, new):
    """Exact rooted sharing isomorphism, including payloads and immediates.

    Only process addresses and header colour bits are immaterial; there is no
    name/path/content normalization or semantic projection here.
    """
    assert len(old['roots']) == len(new['input_declaration_roots'])
    mapping, inverse = {}, {}
    pending = list(zip(old['roots'], new['input_declaration_roots']))
    while pending:
        a, b = pending.pop()
        if a & 1 or b & 1:
            assert a == b, 'input immediate changed'
            continue
        if a in mapping:
            assert mapping[a] == b, 'input sharing changed'
            continue
        assert b not in inverse, 'input sharing collapsed'
        mapping[a], inverse[b] = b, a
        x, y = old['blocks'][str(a)], new['blocks'][str(b)]
        assert (x['tag'], x['words']) == (y['tag'], y['words'])
        if 'fields' in x:
            pending.extend(zip(x['fields'], y['fields']))
        else:
            assert x['payload_hex'] == y['payload_hex'], 'input opaque bytes changed'
    assert len(mapping) == len(old['blocks'])
    return mapping


def project(g, prior_details):
    Refiner = load('representative_state_refiner', REFINEMENT / 'refine.py').Refiner

    class RootRecorder(Refiner):
        def __init__(self, graph):
            super().__init__(graph)
            self.depth, self.recorded_roots = 0, []

        def replace(self, term, root_index):
            outer = self.depth == 0
            self.depth += 1
            result = super().replace(term, root_index)
            self.depth -= 1
            if outer:
                self.recorded_roots.append((root_index, term, result))
            return result

    input_graph = dict(g, roots=g['input_declaration_roots'])
    model = RootRecorder(input_graph)
    details = model.run()
    assert json.loads(json.dumps(details)) == prior_details, 'refinement differs after exact input join'

    def all_miss(term):
        kind, key, ty, attrs, children, bindings, patterns = model.nodes[term]
        if kind == 'choice':
            return all_miss(children[0])
        return model.make(kind, key, ty, attrs, tuple(map(all_miss, children)), bindings, patterns)

    assert len(model.recorded_roots) == 143
    assert [i for i, _, _ in model.recorded_roots] == list(range(143))
    for _, original, alternative in model.recorded_roots:
        # Same interned node means the body, alpha variables, types, constants,
        # triggers, patterns and attributes all survive the all-miss branch.
        assert all_miss(alternative) == original, 'input body not an accepted alternative'

    def key(p):
        node, _, _ = model.fields(p, 3)
        row = g['blocks'][str(node)]
        tag, fields = row['tag'], row['fields']
        if tag == 3:
            return ('logic', tuple(model.fields(d, 2)[0] for d in model.seq(fields[0])))
        if tag == 5:
            kind, symbol, _ = model.fields(fields[0], 3)
            return ('prop', kind, symbol)
        return None

    inputs, corresponding = {}, {}
    for index, ptr in enumerate(g['input_declaration_roots']):
        k = key(ptr)
        if k is not None:
            assert k not in inputs, 'mapped declaration key repeats'
            if k[0] == 'logic':
                assert len(k[1]) == 1
            inputs[k] = ptr
            corresponding[k] = index
    assert len(inputs) == 143
    candidates = defaultdict(list)
    discarded = Counter()
    for ptr in g['hsdecl_declaration_roots']:
        k = key(ptr)
        if k in inputs:
            candidates[k].append(ptr)
        else:
            node = model.fields(ptr, 3)[0]
            discarded[str(g['blocks'][str(node)]['tag'])] += 1
    rows = {r['declaration_index']: r for r in details['root_results']}
    retained, excluded, groups = [], [], []
    for k, ptr in inputs.items():
        index = corresponding[k]
        old = candidates.get(k, [])
        is_goal = k[0] == 'prop' and k[1] == 5
        assert (not old) if is_goal else ptr in old
        groups.append({'declaration_index': index, 'kind': k[0], 'input_address': ptr,
                       'goal_uses_unique': is_goal, 'same_key_old_addresses': old})
        for representative in old:
            if representative == ptr:
                retained.append(representative)
                continue
            assert k[0] == 'prop', 'unhandled extra logic representative'
            node = model.fields(representative, 3)[0]
            _, pr, term = model.fields(g['blocks'][str(node)]['fields'][0], 3)
            coordinates = model.dimensions(model.open(term))
            ceiling = rows[index]['output_coordinates_upper']
            witnesses = [name for name, actual, bound in zip(('n', 'b', 'p', 'a'), coordinates, ceiling) if actual > bound]
            assert witnesses, 'old non-input representative cannot be excluded by strict shape'
            excluded.append({'declaration_index': index, 'name': model.ident(model.fields(pr, 1)[0])['name'],
                             'address': representative, 'opened_coordinates': coordinates,
                             'candidate_coordinates_upper': ceiling, 'strict_shape_exclusion_coordinates': witnesses})
    assert len(retained) == 142 and len(excluded) == 3
    assert sum(map(len, candidates.values())) == len(retained) + len(excluded)
    return {
        'mapped_keys_unique': len(inputs),
        'all_miss_input_alternatives_checked': len(model.recorded_roots),
        'kind_or_symbol_excluded_old_declarations': sum(discarded.values()),
        'excluded_kind_counts': dict(discarded),
        'same_key_old_declarations': sum(map(len, candidates.values())),
        'strict_shape_exclusions': excluded,
        'remaining_old_representatives_are_input_roots': len(retained),
        'groups': groups,
    }


def compose():
    manifest = json.loads((HERE / 'inputs.json').read_text())
    for name, expected in manifest['dependencies'].items():
        assert identity((REPO / name).read_bytes()) == expected, name
    archives = {}
    for name, spec in manifest['archives'].items():
        assert identity((HERE / name).read_bytes()) == spec['identity'], name
        content = read_archive(HERE / name)
        assert {n: identity(b) for n, b in content.items()} == spec['members'], name
        archives[name] = content
    capture = archives['capture.tar.gz']
    g = json.loads(capture['capture/inline-entry-graph.json'])
    table = json.loads(capture['capture/hsdecl-table.json'])
    summary = json.loads(capture['capture/summary.json'])
    assert summary['completed'] and not summary['failures']
    assert not summary['guard_hits'] and not summary['new_threads']
    assert json.loads(capture['capture/process.json'])['initial_threads'] == 1
    assert identity(capture['capture/inline-entry-graph.json']) == summary['inline_entry']['graph']
    assert identity(capture['capture/hsdecl-table.json']) == summary['hsdecl_table']['identity']
    plan = json.loads(capture['plan.json'])
    for name, row in table['instruction_checks'].items():
        assert row['first32'] == plan['table_observer']['symbols'][name]['first32']
    assert len(table['instruction_checks']) == 7
    validate_graph(g)
    bucket_max = validate_table(table, g)
    old_capture = read_archive(ENTRY / 'capture.tar.gz')
    old = json.loads(old_capture['capture/inline-entry-graph.json'])
    old_plan = json.loads(old_capture['plan.json'])
    process = json.loads(capture['capture/process.json'])
    old_case, case = old_plan['inputs'][0], plan['inputs'][0]
    assert identity(capture['input/' + case['argv'][-1]]) == old_case['input'] == case['input']
    old_root = str(Path(old_case['cwd']).parent)
    new_root = str(Path(case['cwd']).parent)
    assert json.loads(json.dumps(old_case).replace(old_root, new_root)) == case
    assert process['argv'] == case['argv'] and process['environment'] == case['environment']
    binary = case['argv'][0]
    assert plan['file_identities'][binary] == old_plan['file_identities'][binary]
    assert summary['mapped_files'][binary] == plan['file_identities'][binary]
    native_result = json.loads(capture['capture/result.json'])
    assert native_result['returncode'] == 0 and native_result['completed']
    assert not native_result['timed_out'] and not native_result['failures']
    # Join the new observer to the unchanged accepted guards. No prior guard is
    # inferred from a matching label: compare the entire generated probe text.
    probe = old_capture['probe.py'].decode().replace(old_root, new_root)
    observer = capture['table-observer.py'].decode()
    probe = probe.replace('# Appended to the retained read-only probe. No inferior calls or data writes.',
                          observer + '\n# Existing entry observer, extended to complete table roots.')
    probe = probe.replace('graph=raw_graph(decls)', "table_roots=read_table_state()\n   graph=raw_graph(list(dict.fromkeys(decls+table_roots)))\n   graph['input_declaration_roots']=decls\n   graph['hsdecl_declaration_roots']=table_roots")
    probe = probe.replace("scope='all logical declaration payloads at first cvc5 inline_trivial entry'",
                          "scope='all first-entry logical declarations and every nonempty Hsdecl weak-table slot'")
    assert probe == capture['probe.py'].decode(), 'unexpected change to accepted observer/guards'
    assert plan['guards'] == old_plan['guards'] and plan['forbidden_calls'] == old_plan['forbidden_calls']
    joined = input_isomorphism(old, g)
    details = json.loads((REFINEMENT / 'details.json').read_text())
    projection = project(g, details)
    prior = json.loads((OPERATIONS / 'result.json').read_text())
    operations = load('representative_state_operations', OPERATIONS / 'compose.py')
    numeric = prior['conditional_arithmetic']['effective_envelope_including_capture']
    assert numeric == {'seed_saved_entries_per_formula': 8, 'delayed_value_nodes': 6,
                       'type_occurrence_nodes': 3, 'attribute_universe_entries': 80}
    result = {
        'scope': 'retained first Input_Is_Valid/cvc5 inline entry; representative state for all optional metadata exclusions',
        'complete_nonempty_slot_projection': True,
        'outer_array_length': table['outer_length'], 'allocated_key_slots': table['allocated_key_slots'],
        'nonempty_key_slots': table['nonempty_key_slots'], 'unique_old_declarations': len(g['hsdecl_declaration_roots']),
        'bucket_length_max': bucket_max, 'declaration_next_tag_at_entry': table['next_tag'],
        'graph_blocks': len(g['blocks']), 'graph_retained_payload_bytes': g['retained_payload_bytes'],
        'graph_opaque_tags': g['opaque_tags'],
        'exact_input_graph_isomorphism_blocks': len(joined),
        'input_roots': len(g['input_declaration_roots']),
        'projection': projection,
        'source_insertion_closure': 'one merge per distinct non-goal mapped key; earlier local insertions cannot match a later key; goal uses unique',
        'opened_attribute_attachment': 'every remaining old object is an exact input root, checked as the all-miss alternative; no strict-equality attribute-preservation assumption',
        'representative_envelope': numeric,
        'representative_contract_instantiated_for_retained_entry': True,
        'local_structural_and_registration_transfer_established_under_existing_runtime_and_freshness_premises': True,
        'attached_local_demands': dict(prior['conditional_arithmetic'], status='attached_to_new_retained_representative_projection', hypothesis_origin='complete_table_projection_and_source_insertion_closure'),
        'Decl.Hsdecl_counter_transfer': operations.counter_transfer(table['next_tag'], 143),
        'Decl.Hsdecl_backing_transfer': operations.weak_transfer(table['outer_length'], bucket_max, table['allocated_key_slots'], 143),
        'unsuccessful_comparand_cost_fully_bounded': False,
        'all_shared_initial_states_instantiated': False,
        'runtime_allocation_collector_composition_established': False,
        'native_inlining_executed': False,
        'all_fixed_pair_dimensions_established': False,
        'complete_transform_capacity_established': False,
        'whole_pipeline_capacity_established': False,
        'source_argument_machine_checked': False,
        'new_native_capture_attempts': 2,
        'successful_complete_state_captures': 1,
        'solver_runs': 0,
    }
    return result, g, table


if __name__ == '__main__':
    print(json.dumps(compose()[0], indent=2))
