"""Focused clone-history and root-call recurrences, over source-fold records.

These records illustrate the native constructor induction. They are not a
new external typed-tree/caller certificate or a replacement WhyML frontend.
The research continuation attaches their inputs to the accepted source fold.
"""
from collections import Counter
from dataclasses import dataclass, field


@dataclass
class History:
    origin_last_ident: int
    current_ident: int = 0
    pv_table: dict = field(default_factory=dict)
    calls: Counter = field(default_factory=Counter)

    def __post_init__(self):
        self.current_ident = max(self.current_ident, self.origin_last_ident)

    def fresh(self):
        self.current_ident += 1
        return self.current_ident

    def extend(self, sm, original):
        result = sm.copy()
        for old in original:
            result[old] = self.fresh()
        self.check(result)
        return result

    def check(self, sm, free=()):
        assert len(set(sm.values())) == len(sm)
        assert all(x > self.origin_last_ident for x in sm.values())
        assert set(free) <= sm.keys()

    def start_declaration(self):
        # Actual origin frontier has no top-level LDvar/RKlocal export.
        assert not self.pv_table
        return self.pv_table.copy()

    def spec(self, sm, args, old_current, pre, post):
        args_map = self.extend(sm,args)
        # find_old creates one old variable per current variable per label;
        # labels are source identities, not a caller-supplied arbitrary map.
        old_source = {}
        for current, old in old_current:
            assert current not in old_source or old_source[current] == old
            old_source[current] = old
        olds_map = self.extend(args_map,old_source.values())
        for free in pre:
            self.check(args_map,free)
            self.calls['clone_term'] += 1
        for free in post:
            self.check(olds_map,free)
            self.calls['clone_term'] += 1
        return args_map, olds_map


@dataclass(frozen=True)
class Spec:
    pre: int = 0
    post: int = 0
    xpost: tuple = ()

    def roots(self, drop_decr=False):
        if drop_decr and not self.pre:
            raise ValueError('native drop_decr requires a leading precondition')
        return self.pre-int(drop_decr)+self.post+sum(self.xpost)


@dataclass(frozen=True)
class Node:
    kind: str
    children: tuple = ()
    spec: Spec = Spec()
    roots: int = 0
    variants: int = 0
    selected: bool = True


def fold(node):
    """Exact direct clone_term/clone_cty/clone c_app entries on a full visit.

    A failed visit is a prefix of this structural envelope; no decrement is
    made when a constructed term/declaration is subsequently discarded.
    This excludes hidden constructor work and general type/effect operations.
    """
    result = Counter()
    for child in node.children:
        result.update(fold(child))
    kind = node.kind
    if kind in {'Cfun','Cany','refined_val'}:
        result['clone_cty'] += 1
        result['clone_term'] += node.spec.roots()
        if kind == 'refined_val':
            result['direct_c_app'] += 1
    elif kind == 'Capp':
        result['direct_c_app'] += 1
    elif kind in {'assert','pure'}:
        result['clone_term'] += 1
    elif kind in {'while','for'}:
        result['clone_term'] += node.roots+node.variants
    elif kind == 'rec_member':
        # Unreached for the inventoried origins, retained as an explicit row.
        result['clone_cty'] += 1
        result['clone_term'] += node.spec.roots(drop_decr=True)+node.variants
    elif kind in {'Dlogic','Dind'}:
        result['clone_term'] += node.roots
    elif kind == 'Dprop':
        result['clone_term'] += int(node.selected)
    elif kind in {'type','Dparam','use','clone_metadata','meta','scope','PDlet',
                  'LDvar','LDsym','let','if','match','raise','exn','ghost',
                  'var','const','assign','absurd','Cpur','exec'}:
        pass
    else:
        raise ValueError('unclassified clone constructor '+kind)
    return result


def expanded(module, local, clone_targets, active=()):
    """Unchanged-weight DAG illustration, not the native transformed fold.

    Actual clone substitutions can discard/add declaration records. Native
    counts use fold on those resulting records at the next clone boundary;
    this simpler helper checks occurrence multiplicity only when weights are
    unchanged. See the research continuation's Build(m) recurrence.
    """
    if module in active:
        raise ValueError('cyclic clone dependency')
    result = Counter(local[module])
    for target in clone_targets.get(module,()):
        result.update(expanded(target,local,clone_targets,active+(module,)))
    return result
