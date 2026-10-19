"""Source-derived opened occurrence counts; no target or native calls.

Frames interpret term.ml's delayed substitutions, innermost first. A binder
renames its raw variable to a fresh abstract variable (whose binder mass is
zero); substitution values see only the older frames, never their own frame.
Repeated children are summed, even when their memoized state is shared.
"""
from functools import lru_cache


class Opened:
    def __init__(self, blocks):
        self.blocks = blocks
        self.active = set()
        self.states = 0
        self.nonempty_substitutions = set()

    def fields(self, pointer, words=None, tag=0):
        row = self.blocks[str(pointer)]
        assert row['tag'] == tag
        fields = row['fields']
        assert words is None or len(fields) == words
        return fields

    @lru_cache(None)
    def seq(self, pointer):
        result, seen = [], set()
        while pointer != 1:
            assert pointer not in seen, ('list cycle', pointer)
            seen.add(pointer)
            value, pointer = self.fields(pointer, 2)
            result.append(value)
        return tuple(result)

    def mapping(self, pointer, active=frozenset()):
        if pointer == 1:
            return ()
        assert pointer not in active, ('map cycle', pointer)
        left, key, value, right, height = self.fields(pointer, 5)
        assert height & 1
        rows = (self.mapping(left, active | {pointer}) + ((key, value),)
                + self.mapping(right, active | {pointer}))
        assert len({k for k, _ in rows}) == len(rows), 'duplicate map key'
        return rows

    def frame(self, variables, binding):
        assert len(set(variables)) == len(variables), 'duplicate bound variable'
        _, substitutions = self.fields(binding, 2)
        pairs = self.mapping(substitutions)
        if pairs:
            self.nonempty_substitutions.add(binding)
        return (tuple(variables), pairs)

    @lru_cache(None)
    def count(self, pointer, frames=()):
        state = (pointer, frames)
        assert state not in self.active, ('cyclic opened state', pointer)
        self.active.add(state)
        self.states += 1
        try:
            return self._count(pointer, frames)
        finally:
            self.active.remove(state)

    def _count(self, pointer, frames):
        node, _, _, _ = self.fields(pointer, 4)
        if node & 1:
            assert node in (1, 3)
            return (1, 0)
        row = self.blocks[str(node)]
        tag, fields = row['tag'], row['fields']
        assert 0 <= tag <= 9
        expected = (1, 1, 2, 3, 2, 2, 1, 2, 3, 1)[tag]
        assert len(fields) == expected
        if tag == 0:  # Tvar: renamed variables override saved substitution.
            variable, = fields
            for index, (bound, substitutions) in enumerate(frames):
                if variable in bound:
                    return (1, 0)
                substitutions = dict(substitutions)
                if variable in substitutions:
                    return self.count(substitutions[variable], frames[index + 1:])
            return (1, 0)
        if tag == 1:  # Tconst
            return (1, 0)
        children, own = [], 0
        if tag == 2:  # Tapp
            children = [(p, frames) for p in self.seq(fields[1])]
        elif tag == 3:  # Tif
            children = [(p, frames) for p in fields]
        elif tag in (4, 6):  # Tlet / Teps
            binding = fields[1] if tag == 4 else fields[0]
            variable, info, body = self.fields(binding, 3)
            own = 1
            children = [(body, (self.frame((variable,), info),) + frames)]
            if tag == 4:
                children.append((fields[0], frames))
        elif tag == 5:  # Tcase; pat_vars is the distinct variable map.
            children = [(fields[0], frames)]
            for branch in self.seq(fields[1]):
                pattern, info, body = self.fields(branch, 3)
                _, variables, _ = self.fields(pattern, 3)
                variables = tuple(k for k, _ in self.mapping(variables))
                own += len(variables)
                children.append((body, (self.frame(variables, info),) + frames))
        elif tag == 7:  # Tquant, including each trigger occurrence.
            variables, info, triggers, body = self.fields(fields[1], 4)
            variables = self.seq(variables)
            own = len(variables)
            nested = (self.frame(variables, info),) + frames
            children = [(body, nested)]
            children.extend((term, nested) for trigger in self.seq(triggers)
                            for term in self.seq(trigger))
        elif tag == 8:  # Tbinop
            children = [(p, frames) for p in fields[1:]]
        elif tag == 9:  # Tnot
            children = [(fields[0], frames)]
        rows = [self.count(p, context) for p, context in children]
        return (1 + sum(n for n, _ in rows), own + sum(b for _, b in rows))


def certificate(blocks, chains, forest):
    model = Opened(blocks)
    tasks, formulas = {}, {}
    for task, chain in chains.items():
        declarations, props = [], []
        following = int(task)
        for index, row in enumerate(chain):
            assert row['option'] == following
            assert model.fields(following, 1) == [row['head']]
            head = model.fields(row['head'], 6)
            assert head[0] == row['tdecl']
            following = head[1]
            node, _ = model.fields(row['tdecl'], 2)
            kind = blocks[str(node)]['tag']
            assert kind in (0, 1, 2, 3)
            if kind != 0:
                continue
            declaration, = model.fields(node, 1)
            declarations.append(declaration)
            dnode, _, _ = model.fields(declaration, 3)
            dkind = blocks[str(dnode)]['tag']
            assert dkind in range(6)
            if dkind == 5:
                prop, = model.fields(dnode, 1, tag=5)
                pkind, symbol, formula = model.fields(prop, 3)
                assert pkind in (1, 3, 5)
                nodes, binders = model.count(formula)
                formulas[str(formula)] = {'opened_term_occurrences': nodes,
                                          'opened_binder_occurrences': binders}
                props.append({'chain_index': index, 'declaration': declaration,
                              'kind': pkind >> 1, 'symbol': symbol, 'formula': formula})
        assert following == 1
        assert props and props[0]['chain_index'] == 0 and props[0]['kind'] == 2
        tasks[task] = {'chain_length': len(chain), 'logical_declarations': declarations,
                       'propositions': props, 'goal_formula': props[0]['formula']}
    visits = []
    for index, visit in enumerate(forest['visits']):
        if visit['detached']:
            visits.append(dict(visit, index=index, charge=0))
            continue
        task = tasks[str(visit['task'])]
        explanation = formulas[str(task['goal_formula'])]['opened_binder_occurrences']
        shape = sum(formulas[str(prop['formula'])]['opened_binder_occurrences']
                    for prop in task['propositions'])
        visits.append(dict(visit, index=index, explanation_upper=explanation,
                           all_propositions_shape_upper=shape, charge=explanation + shape))
    return {'tasks': tasks, 'formulas': formulas, 'visits': visits,
            'B_binders': sum(v['charge'] for v in visits),
            'finite_opened_states': model.states,
            'distinct_nonempty_bv_subst_records': len(model.nonempty_substitutions)}
