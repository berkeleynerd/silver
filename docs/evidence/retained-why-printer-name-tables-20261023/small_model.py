"""Focused finite checks of the NEW history/catch argument, not Why3 execution."""
from itertools import product


class Caught(Exception):
    pass


def run_name(table, ghost, count, base, interrupt):
    """One find_unique call, injecting Not_found before/after guarded stages.

The final replace is outside the catch. Its failure discards the owner and is
checked in the separate structural model, not continued as a dictionary state.
"""
    tab, hist = dict(table), set(ghost)
    tick = 0
    operands = []

    def checkpoint():
        nonlocal tick
        tick += 1
        if tick == interrupt:
            raise Caught

    def spec(i):
        operands.append(i)
        checkpoint()
        return base if i <= 0 else base + str(i)

    def test(i):
        key = spec(i)
        checkpoint()
        return key in tab

    result = base
    try:
        checkpoint()
        if base not in tab:
            raise Caught
        ind = tab[base] + 1
        operands.append(ind)
        if test(ind):
            ind += 1
            operands.append(ind)
            while test(ind):
                ind += 1
                operands.append(ind)
        else:
            while ind != 1 and not test(ind - 1):
                ind -= 1
        checkpoint()
        assert base in tab  # covered base replacement is always a hit
        tab[base] = ind
        hist.add(base + str(ind))  # virtual candidate before specname can fail
        checkpoint()
        result = spec(ind)
    except Caught:
        result = base
    tab[result] = 0
    hist.add(result)
    assert len(hist - set(ghost)) <= 1
    assert len(hist) <= count
    assert set(tab) <= hist
    assert max(operands, default=0) <= count
    for key, value in tab.items():
        assert 0 <= value <= count
        assert all(key + str(i) in hist for i in range(1, value + 1))
    return tuple(sorted(tab.items())), frozenset(hist), tick


def history_checks(depth=4):
    # Ending in digits deliberately exercises collisions between different bases.
    states = {((), frozenset())}
    transitions = 0
    widths = []
    for count in range(1, depth + 1):
        next_states = set()
        for tab_tuple, hist in states:
            tab = dict(tab_tuple)
            for base in ('x', 'x1', 'x2'):
                _, _, checkpoints = run_name(tab, hist, count, base, None)
                for point in [None, *range(1, checkpoints + 1)]:
                    nt, nh, _ = run_name(tab, hist, count, base, point)
                    transitions += 1
                    next_states.add((nt, nh))
                    # Arbitrary subsets removed: stronger than actual forget_id.
                    for mask in product((False, True), repeat=len(nt)):
                        removed = tuple(pair for pair, drop in zip(nt, mask) if not drop)
                        next_states.add((removed, nh))
        states = next_states
        widths.append(len(states))
    tab, hist = {}, frozenset()
    for count in range(1, 7):
        out, hist, _ = run_name(tab, hist, count, 'x', None)
        tab = dict(out)
    for key in tuple(tab):
        if key != 'x':
            del tab[key]
    assert tab == {'x': 5}  # one binding, historical cache five
    return {'depth': depth, 'states_by_depth': widths, 'transitions': transitions,
            'occupancy_counterexample': {'live_bindings': len(tab), 'cached_suffix': tab['x']}}


def structural_checks():
    # A source-order partial rehash may share tails. It must not be exported as
    # an ordinary reusable state, even though all chains remain acyclic.
    hashes = [0, 16, 0]
    nexts = [1, 2, None]
    new_roots, tails = {}, {}
    visited = []
    for cell in range(3):
        saved = nexts[cell]
        slot = hashes[cell] & 31
        if slot in tails:
            nexts[tails[slot]] = cell
        else:
            new_roots[slot] = cell
        tails[slot] = cell
        visited.append(cell)
        if cell == 1:
            def chain(root):
                seen = []
                while root is not None:
                    assert root not in seen
                    seen.append(root)
                    root = nexts[root]
                return seen
            partial = sum(len(chain(root)) for root in new_roots.values())
            assert partial == 5  # exceeds the three original bindings
        assert saved == (cell + 1 if cell < 2 else None)
    for cell in tails.values():
        nexts[cell] = None
    assert visited == [0, 1, 2]
    # Allow interruption after size decrement but before unlink, repeatedly.
    size, bindings = 1, 1
    for _ in range(2):
        size -= 1
        assert bindings == 1
    assert size == -1
    # Neither lookup nor key_index reads size. A negative value suppresses the
    # resize test; it is not used as an array index or allocation extent.
    assert not (size > (2048 << 1))
    return {'partial_rehash_three_cells_five_root_occurrences': partial,
            'reused_partial_rehash_allowed': False,
            'remove_prefix_size_can_be_negative': size}


if __name__ == '__main__':
    import json
    print(json.dumps({'history': history_checks(), 'structure': structural_checks()}, indent=2))
