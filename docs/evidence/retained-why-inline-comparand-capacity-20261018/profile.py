"""Read the complete retained table through the actual equality preconditions.

The raw walker includes unused saved values. Its opened walker implements the
frame consumption of term.ml:266-281; it does not execute native comparison.
"""
from collections import Counter
from functools import lru_cache


def immediate(v):
    assert type(v) is int and v & 1, 'expected immediate integer'
    return (v - (1 << 64) if v >= 1 << 63 else v) >> 1


class Profile:
    def __init__(self, graph):
        self.graph = graph
        self.blocks = graph['blocks']
        self.constants = {}
        self.locations = set()
        self.type_tags = set()
        self.attributes = set()
        self.term_addresses = set()
        self.map_roots = set()
        self.variable_tags = {}
        self.active_stored = set()
        self.active_opened = set()

    def fields(self, p, n=None, tag=0):
        row = self.blocks[str(p)]
        assert row['tag'] == tag
        fields = row['fields']
        assert n is None or len(fields) == n
        return fields

    @lru_cache(None)
    def seq(self, p):
        result, seen = [], set()
        while p != 1:
            assert p not in seen, 'cyclic list'
            seen.add(p)
            v, p = self.fields(p, 2)
            result.append(v)
        return tuple(result)

    def key_tag(self, p, kind):
        if kind == 'attr':
            return immediate(self.fields(p, 2)[1])
        assert kind == 'var'
        name, _ = self.fields(p, 2)
        tag = immediate(self.fields(name, 4)[3])
        assert tag != -1
        assert self.variable_tags.setdefault(tag, p) == p, 'variable identity/tag alias'
        return tag

    @lru_cache(None)
    def mapping(self, p, kind):
        active = set()

        def walk(p):
            if p == 1:
                return (), 0
            assert p not in active, 'cyclic map'
            active.add(p)
            left, key, value, right, height = self.fields(p, 5)
            l, lh = walk(left)
            r, rh = walk(right)
            active.remove(p)
            assert immediate(height) == 1 + max(lh, rh)
            assert abs(lh-rh) <= 2, 'invalid balanced map'
            pairs = l + ((key, value),) + r
            tags = [self.key_tag(k, kind) for k, _ in pairs]
            assert tags == sorted(set(tags)), 'invalid map key order'
            return pairs, immediate(height)

        self.map_roots.add(p)
        return walk(p)

    def pattern(self, p):
        node, variables, _ = self.fields(p, 3)
        assert self.mapping(variables, 'var')[0] == ()
        symbol, children = self.fields(node, 2, tag=1)
        assert self.seq(children) == (), 'non-nullary compared pattern'
        assert self.seq(self.fields(symbol, 5)[1]) == ()
        return 1

    def constant(self, p):
        # No integer-size inference from an opaque custom block is permitted.
        payload, = self.fields(p, 1)
        kind, value = self.fields(payload, 2)
        assert 0 <= immediate(kind) <= 4
        integer = immediate(value)
        self.constants[p] = {'literal_kind': immediate(kind), 'integer': integer}

    def term_metadata(self, p):
        node, ty, attrs, loc = self.fields(p, 4)
        self.term_addresses.add(p)
        if ty != 1:
            # Only field zero is accessed by the option match. Some retained
            # option-shaped values have a larger tag-zero payload; do not
            # infer an allocation shape that comparison does not require.
            tp = self.fields(ty)[0]
            _, tag = self.fields(tp, 2)
            assert immediate(tag) != -1
            self.type_tags.add(immediate(tag))
        pairs, height = self.mapping(attrs, 'attr')
        assert all(value == 1 for _, value in pairs)
        self.attributes.update(key for key, _ in pairs)
        if loc != 1:
            position = self.fields(loc)[0]
            coordinates = tuple(map(immediate, self.fields(position, 3)))
            self.locations.add(coordinates)
        return node, len(pairs), height

    def binding(self, p, kind):
        bound, info, *rest = self.fields(p, 4 if kind == 'quant' else 3)
        if kind == 'quant':
            variables = self.seq(bound)
            groups = tuple(self.seq(group) for group in self.seq(rest[0]))
            patterns = 0
        elif kind == 'case':
            patterns = self.pattern(bound)
            variables, groups = (), ()
        else:
            variables, groups, patterns = (bound,), (), 0
        assert len({self.key_tag(v, 'var') for v in variables}) == len(variables)
        counts, subst = self.fields(info, 2)
        self.mapping(counts, 'var')
        pairs, height = self.mapping(subst, 'var')
        return variables, pairs, height, groups, rest[-1], patterns

    def children(self, p):
        """Raw direct term children and binding groups; no stored-value loss."""
        node, _, _, _ = self.fields(p, 4)
        if node & 1:
            assert node in (1, 3)
            return (), ()
        row = self.blocks[str(node)]
        tag, x = row['tag'], row['fields']
        assert 0 <= tag <= 9
        if tag == 0:
            assert len(x) == 1
            self.key_tag(x[0], 'var')
            return (), ()
        if tag == 1:
            assert len(x) == 1
            self.constant(x[0])
            return (), ()
        if tag == 2:
            assert len(x) == 2
            return self.seq(x[1]), ()
        if tag == 3:
            assert len(x) == 3
            return tuple(x), ()
        if tag == 4:
            assert len(x) == 2
            return (x[0],), (self.binding(x[1], 'let'),)
        if tag == 5:
            assert len(x) == 2
            return (x[0],), tuple(self.binding(b, 'case') for b in self.seq(x[1]))
        if tag == 6:
            assert len(x) == 1
            return (), (self.binding(x[0], 'eps'),)
        if tag == 7:
            assert len(x) == 2 and x[0] in (1, 3)
            return (), (self.binding(x[1], 'quant'),)
        if tag == 8:
            assert len(x) == 3 and x[0] & 1
            return tuple(x[1:]), ()
        assert len(x) == 1
        return (x[0],), ()

    @lru_cache(None)
    def stored(self, p):
        assert p not in self.active_stored, 'cyclic stored term'
        self.active_stored.add(p)
        _, attrs, attr_height = self.term_metadata(p)
        children, bindings = self.children(p)
        data = {'term_occurrences': 1, 'saved_entries': 0,
                'saved_map_keys_max': 0, 'saved_map_height_max': 0,
                'attribute_keys_max': attrs, 'attribute_height_max': attr_height,
                'trigger_groups': 0, 'empty_trigger_groups': 0,
                'bound_slots': 0, 'patterns': 0, 'binding_frames': len(bindings)}
        descendants = list(children)
        for variables, pairs, height, groups, body, patterns in bindings:
            data['saved_entries'] += len(pairs)
            data['saved_map_keys_max'] = max(data['saved_map_keys_max'], len(pairs))
            data['saved_map_height_max'] = max(data['saved_map_height_max'], height)
            data['trigger_groups'] += len(groups)
            data['empty_trigger_groups'] += sum(not group for group in groups)
            data['bound_slots'] += len(variables)
            data['patterns'] += patterns
            descendants.extend(value for _, value in pairs)
            descendants.extend(t for group in groups for t in group)
            descendants.append(body)
        for child in descendants:
            for key, value in self.stored(child).items():
                data[key] = max(data[key], value) if key.endswith('_max') else data[key] + value
        self.active_stored.remove(p)
        return data

    def resolve(self, p, frames):
        probes = 0
        while True:
            node = self.fields(p, 4)[0]
            if node & 1 or self.blocks[str(node)]['tag'] != 0:
                return p, frames, probes
            variable, = self.fields(node, 1)
            while frames:
                bound, pairs = frames[0]
                frames = frames[1:]
                probes += 1
                if variable in bound:
                    return None, (), probes
                substitution = dict(pairs)
                if variable in substitution:
                    p = substitution[variable]
                    break
            else:
                return p, (), probes

    def opened(self, p, frames=()):
        state = p, frames
        assert state not in self.active_opened, 'cyclic opened term'
        self.active_opened.add(state)
        q, remaining, probes = self.resolve(p, frames)
        data = {'n': 1, 'b': 0, 'p': 0, 'g': 0, 'empty_g': 0,
                'frame_depth': len(frames), 'resolution_probes': probes}
        if q is not None:
            children, bindings = self.children(q)
            descendants = [(child, remaining) for child in children]
            for variables, pairs, _, groups, body, patterns in bindings:
                data['b'] += len(variables)
                data['p'] += patterns
                data['g'] += len(groups)
                data['empty_g'] += sum(not group for group in groups)
                nested = ((variables, pairs),) + remaining
                descendants.extend((t, nested) for group in groups for t in group)
                descendants.append((body, nested))
            for child, child_frames in descendants:
                for key, value in self.opened(child, child_frames).items():
                    data[key] = max(data[key], value) if key == 'frame_depth' else data[key] + value
        self.active_opened.remove(state)
        return data

    def declaration(self, p):
        node, _, _ = self.fields(p, 3)
        row = self.blocks[str(node)]
        tag, x = row['tag'], row['fields']
        if tag == 3:
            definitions = self.seq(x[0])
            if not definitions:
                return tag, None, None, 0
            symbol, definition = self.fields(definitions[0], 2)
            _, formula, _ = self.fields(definition, 3)
            # Equality compares this first formula before checking list tails.
            return tag, ('logic', symbol), formula, len(definitions)
        if tag == 5:
            kind, symbol, formula = self.fields(x[0], 3)
            return tag, ('prop', kind, symbol), formula, None
        return tag, None, None, None


def extract(graph, root_results):
    reader = Profile(graph)
    by_index = {row['declaration_index']: row for row in root_results}
    inputs, candidates, keys = [], [], {}
    for index, decl in enumerate(graph['input_declaration_roots']):
        tag, key, formula, length = reader.declaration(decl)
        if key is None:
            continue
        assert key not in keys
        keys[key] = index
        row = by_index[index]
        old = reader.opened(formula)
        stored = reader.stored(formula)
        assert old['empty_g'] == 0, 'empty trigger group needs explicit list allowance'
        if tag == 3:
            assert length == 1
            # make_ls_defn adds the head application, arity many variables,
            # equality/iff, and at most one quantifier. An unchanged callback
            # may instead retain the complete original definition axiom.
            n = max(old['n'], row['output_coordinates_upper'][0] + row['arity'] + 3)
            b = max(old['b'], row['output_coordinates_upper'][1] + row['arity'])
        else:
            n, b = row['output_coordinates_upper'][:2]
        candidate = {'declaration_index': index, 'kind': row['kind'],
                     'goal_unique': key[0] == 'prop' and key[1] == 5,
                     'n': n, 'b': b, 'p': max(old['p'], row['output_coordinates_upper'][2]),
                     'g': old['g'], 'frame_depth': n,
                     'body_input_n': row['input'][0],
                     'body_output_n': row['output_coordinates_upper'][0]}
        inputs.append({'declaration_index': index, 'address': decl,
                       'formula_address': formula, 'opened': old, 'stored': stored})
        candidates.append(candidate)
    assert len(inputs) == len(by_index) == 143
    initial_kinds, logic_lengths = Counter(), Counter()
    selected, shallow = [], []
    for decl in graph['hsdecl_declaration_roots']:
        tag, key, formula, length = reader.declaration(decl)
        initial_kinds[tag] += 1
        if tag == 3:
            logic_lengths[length] += 1
        if key in keys and not (key[0] == 'prop' and key[1] == 5):
            selected.append({'declaration_index': keys[key], 'address': decl,
                             'formula_address': formula, 'logic_length': length,
                             'opened': reader.opened(formula), 'stored': reader.stored(formula)})
        else:
            shallow.append(decl)
    # The prefix-sensitive scan is separate from the prior equality-key scan.
    # A new multi-definition prefix match would require an expanded argument.
    assert dict(logic_lengths) == {1: 1203}
    assert len(selected) == 145 and len(shallow) == 6559
    reachable, pending = set(), [row['formula_address'] for row in inputs + selected]
    while pending:
        p = pending.pop()
        if p & 1 or p in reachable:
            continue
        reachable.add(p)
        pending.extend(graph['blocks'][str(p)].get('fields', ()))
    opaque = Counter(graph['blocks'][str(p)]['tag'] for p in reachable if graph['blocks'][str(p)]['tag'] >= 246)
    assert set(opaque) <= {252}, 'custom payload in compared formula closure'
    return {'initial_kind_counts': dict(initial_kinds),
            'initial_logic_list_lengths': dict(logic_lengths),
            'shallow_rejected_addresses': shallow,
            'potential_strict_old_comparands': selected,
            'input_formulas': inputs, 'candidate_formula_bounds': candidates,
            'compared_formula_closure_blocks': len(reachable),
            'compared_formula_closure_opaque_tags': dict(opaque),
            'stored_term_objects': len(reader.term_addresses),
            'constant_objects': reader.constants,
            'location_records': len(reader.locations),
            'type_tags_observed': len(reader.type_tags),
            'attribute_objects': len(reader.attributes)}, reader
