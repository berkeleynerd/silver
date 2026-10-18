"""Read-only structural guards for the frozen first inlining entry.

The accepted Refiner supplies semantic alternatives, not native allocation
observations. These additional guards justify the restricted operational
argument in the accompanying research note.
"""
from collections import Counter


def inventory(g, model, details):
    blocks = g['blocks']
    f, seq, mapping = model.fields, model.seq, model.mapping
    types, symbols, variables, patterns, terms, binds = {}, set(), set(), {}, set(), {}
    attrs, names = set(), set()

    def ident(p):
        v = model.ident(p)
        attrs.update(v['attributes'])
        names.add(v['name'])
        return v

    def ty(p):
        if p in types:
            return
        t = model.ty(p)
        types[p] = t
        nd, _ = f(p, 2)
        row = blocks[str(nd)]
        if row['tag'] == 0:
            ident(f(row['fields'][0], 1)[0])
        else:
            ts, children = row['fields']
            name, args, definition = f(ts, 3)
            ident(name)
            # Native Tyapp values are normalized: ty_inst cannot encounter
            # an alias expansion that this occurrence bound did not include.
            assert definition == 1 or blocks[str(definition)]['tag'] in (1, 2)
            assert len(seq(args)) == len(seq(children))
            for child in seq(children):
                ty(child)

    def var(p):
        if p not in variables:
            variables.add(p)
            name, tp = f(p, 2)
            ident(name)
            ty(tp)

    def ls(p):
        if p in symbols:
            return
        symbols.add(p)
        name, args, value, _, _ = f(p, 5)
        ident(name)
        for tp in seq(args):
            ty(tp)
        if value != 1:
            ty(f(value, 1)[0])

    def pat(p):
        if p in patterns:
            return
        nd, vs, tp = f(p, 3)
        ty(tp)
        # Every retained pattern is a nullary constructor pattern. In
        # particular pat_rename/check_compile cannot create a bound slot.
        assert not mapping(vs)
        row = blocks[str(nd)]
        assert row['tag'] == 1
        symbol, children = row['fields']
        assert not seq(children)
        ls(symbol)
        assert not seq(f(symbol, 5)[1])
        patterns[p] = symbol

    def bind(p, kind):
        bound, bi, *rest = f(p, 4 if kind == 'quant' else 3)
        if kind == 'quant':
            for v in seq(bound):
                var(v)
        elif kind == 'case':
            pat(bound)
        else:
            var(bound)
        counts, subst = f(bi, 2)
        pairs = mapping(subst)
        binds[bi] = pairs
        for v, _ in mapping(counts):
            var(v)
        for v, value in pairs:
            var(v)
            term(value)
        if kind == 'quant':
            for trigger in seq(rest[0]):
                for t in seq(trigger):
                    term(t)
        term(rest[-1])

    def term(p):
        if p in terms:
            return
        terms.add(p)
        nd, tp, at, _ = f(p, 4)
        attrs.update(model.attrs(at))
        if tp != 1:
            ty(f(tp, 1)[0])
        if nd & 1:
            return
        row = blocks[str(nd)]
        tag, x = row['tag'], row['fields']
        if tag == 0:
            var(x[0])
        elif tag == 2:
            ls(x[0])
            for child in seq(x[1]):
                term(child)
        elif tag == 3:
            for child in x:
                term(child)
        elif tag == 4:
            term(x[0]); bind(x[1], 'let')
        elif tag == 5:
            term(x[0])
            for b in seq(x[1]):
                bind(b, 'case')
        elif tag == 6:
            bind(x[0], 'eps')
        elif tag == 7:
            bind(x[1], 'quant')
        elif tag == 8:
            term(x[1]); term(x[2])
        elif tag == 9:
            term(x[0])
        else:
            assert tag == 1

    data = {}
    news = set()
    counts = Counter()
    for d in g['roots']:
        nd, new, _ = f(d, 3)
        news.update(k for k, _ in mapping(new))
        row = blocks[str(nd)]
        tag, x = row['tag'], row['fields']
        counts[tag] += 1
        if tag == 0:
            name, args, definition = f(x[0], 3)
            ident(name)
            if definition != 1 and blocks[str(definition)]['tag'] == 0:
                ty(f(definition, 1)[0])
        elif tag == 1:
            for d in seq(x[0]):
                ts, constructors = f(d, 2)
                name, args, definition = f(ts, 3)
                ident(name)
                assert not seq(args) and definition == 1
                cs = []
                for c in seq(constructors):
                    symbol, projections = f(c, 2)
                    ls(symbol)
                    for pr in seq(projections):
                        if pr != 1:
                            ls(f(pr, 1)[0])
                    children = []
                    for tp in seq(f(symbol, 5)[1]):
                        t = model.ty(tp)
                        assert t[0] == 'a' and not t[2]
                        children.append(t[1])
                    cs.append(children)
                data[ts] = cs
        elif tag == 2:
            ls(x[0])
        elif tag == 3:
            assert len(seq(x[0])) == 1
            symbol, ld = f(seq(x[0])[0], 2)
            ls(symbol)
            _, axiom, _ = f(ld, 3)
            term(axiom)
        elif tag == 5:
            _, pr, formula = f(x[0], 3)
            ident(f(pr, 1)[0]); term(formula)
        else:
            raise AssertionError('unexpected inductive declaration')

    substitutions = []
    nonunit_keys = set()
    value_freevars = set()
    for bi, pairs in binds.items():
        for key, value in pairs:
            t = model.open(value)
            dim = model.dimensions(t)
            free = model.free(t)
            assert dim[1:3] == (0, 0) and sum(n for _, n in free) <= 1
            if dim[0] > 1:
                nonunit_keys.add(key)
            value_freevars.update(-v for v, _ in free)
            substitutions.append({'binder': bi, 'key': key, 'value': value,
                                  'nodes': dim[0], 'free_occurrences': sum(n for _, n in free)})
    # Fresh names cannot enter this original key set. Consequently composing
    # these delayed values only renames their free leaf; it cannot expand it.
    assert not nonunit_keys & value_freevars, 'nonunit key occurs in a delayed value'

    def nodes(t):
        return 1 + (sum(nodes(c) for c in t[2]) if t[0] == 'a' else 0)

    def typevars(t):
        return {t[1]} if t[0] == 'v' else set().union(*(typevars(c) for c in t[2]))

    signatures = []
    for symbol in symbols:
        _, args, value, _, _ = f(symbol, 5)
        ts = [model.ty(p) for p in seq(args)]
        if value != 1:
            ts.append(model.ty(f(value, 1)[0]))
        signatures.append(len(set().union(*(typevars(t) for t in ts))))

    semantic_types = [n[2] for n in model.nodes if n[2] is not None]
    semantic_types += [t for t, _ in model.variables.values()]
    type_max = max(map(nodes, list(types.values()) + semantic_types))
    eligible = [x for x in details['definition_eligibility'] if x['must_eligible']]
    assert all(tuple(x['body_coordinates_upper'][1:3]) == (0, 0) for x in eligible)
    assert all(c <= 1 for x in details['symbol_matched_optional_hits'] for c in x['formal_occurrences'])
    seen = set()

    def env_term(t):
        if t in seen:
            return
        seen.add(t)
        n = model.nodes[t]
        if n[0] == 'const':
            tp = n[2]
            assert tp[0] == 'a' and not tp[2]
            name, _, definition = f(tp[1], 3)
            # t_gen_map's smart t_const has no range/float arithmetic here.
            assert model.ident(name)['tag'] == 1 and definition == 1
            cr = blocks[str(n[1])]
            assert cr['tag'] == 0  # Constant.ConstInt
        for c in n[4]:
            env_term(c)

    for _, body in model.environment.values():
        env_term(body)

    # For these ground declarations positivity has no type arguments to
    # inspect. Foundedness follows the finite data dependency graph. Count
    # every constructor (even after List.exists succeeds) for an upper bound.
    def founded(ts, path=()):
        assert ts not in path, 'recursive ground data dependency'
        if ts not in data:
            return (1, 0)
        n, c = 1, len(data[ts])
        for args in data[ts]:
            for child in args:
                nn, cc = founded(child, path + (ts,))
                n += nn; c += cc
        return n, c

    fd = [founded(ts) for ts in data]
    return {
        'logical_declaration_kind_counts': dict(sorted(counts.items())),
        'known_identifier_keys_upper': len(news),
        'raw_terms': len(terms), 'raw_binder_infos': len(binds),
        'raw_substitution_entries': len(substitutions),
        'initial_substitution_map_entries_max': max(map(len, binds.values())),
        'delayed_value_nodes_max': max(x['nodes'] for x in substitutions),
        'nonunit_substitution_keys': sorted(nonunit_keys),
        'all_initial_delayed_values_binder_free_and_unary': True,
        'nonunit_keys_absent_from_every_initial_delayed_value_free_set': True,
        'substitutions': substitutions,
        'all_environment_candidates_binder_free': True,
        'all_hit_formal_coefficients_at_most_one': True,
        'all_environment_constants_unbounded_builtin_integers': True,
        'all_patterns_nullary_constructors': True,
        'distinct_patterns': len(patterns),
        'type_occurrence_nodes_max': type_max,
        'signature_type_variables_max': max(signatures),
        'captured_type_nodes': len(types),
        'application_arity_max': max(len(seq(f(s, 5)[1])) for s in symbols),
        'attribute_universe_entries': len(attrs),
        'identifier_name_utf8_bytes_max': max(len(x.encode()) for x in names),
        'ground_data_declarations': len(data),
        'data_constructor_argument_checks': sum(len(a) for cs in data.values() for a in cs),
        'foundedness_type_entries_upper': sum(x[0] for x in fd),
        'foundedness_constructor_entries_upper': sum(x[1] for x in fd),
    }
