"""Sufficient strict-equality test on the frozen R51 stored graphs.

Follows Term.t_compare's pre-descent metadata checks and delayed frames.
Same type/location pointers suffice; this does not decide equal but differently
allocated locations. Existing attribute interning is an explicit premise.
"""
from collections import Counter


class Comparison:
    def __init__(self, graph):
        self.terms = graph['terms']
        self.binds = graph['bindings']
        self.events = Counter()

    def descend(self, index, frames):
        row = self.terms[index]
        if row['kind'] != 'var':
            return index, frames, None
        var, = row['args']
        for i, (bound, saved) in enumerate(frames):
            if var in bound:
                return None, (), bound[var]
            if str(var) in saved:
                self.events['followed_saved_values'] += 1
                return self.descend(saved[str(var)], frames[i + 1:])
        return index, (), None

    def equal(self, left, right):
        self.events.clear()
        return self.walk(left, right)

    def walk(self, left, right, lf=(), rf=(), depth=0):
        self.events['term_pair_calls'] += 1
        if left == right and not lf and not rf:
            self.events['physical_shortcuts'] += 1
            return True
        a, b = self.terms[left], self.terms[right]
        # Source tests these before descending a variable substitution.
        if (a['type'], a['attrs'], a['location']) != (
                b['type'], b['attrs'], b['location']):
            self.events['metadata_rejections'] += 1
            return False
        left, lf, lb = self.descend(left, lf)
        right, rf, rb = self.descend(right, rf)
        if lb is not None or rb is not None:
            return lb == rb
        a, b = self.terms[left], self.terms[right]
        kind, ax, bx = a['kind'], a['args'], b['args']
        if kind != b['kind']:
            return False

        def recur(x, y):
            return self.walk(x, y, lf, rf, depth)

        def binding(ai, bi):
            u, v = self.binds[ai], self.binds[bi]
            uv, vv = u['variables'], v['variables']
            if len(uv) != len(vv):
                self.events['binder_length_rejections'] += 1
                return False
            self.events['binding_pair_calls'] += 1
            f1 = (({x: depth + i for i, x in enumerate(uv)}, u['saved']),) + lf
            f2 = (({x: depth + i for i, x in enumerate(vv)}, v['saved']),) + rf
            ut, vt = u['triggers'], v['triggers']
            if len(ut) != len(vt) or any(len(x) != len(y) for x, y in zip(ut, vt)):
                self.events['trigger_length_rejections'] += 1
                return False
            self.events['trigger_pair_calls'] += sum(map(len, ut))
            return all(self.walk(x, y, f1, f2, depth + len(uv))
                       for xs, ys in zip(ut, vt) for x, y in zip(xs, ys)) and \
                self.walk(u['body'], v['body'], f1, f2, depth + len(uv))

        if kind in ('var', 'const', 'true', 'false'):
            return ax == bx
        if kind == 'app':
            return ax[0] == bx[0] and len(ax[1]) == len(bx[1]) and \
                all(recur(x, y) for x, y in zip(ax[1], bx[1]))
        if kind in ('if', 'not'):
            return len(ax) == len(bx) and all(recur(x, y) for x, y in zip(ax, bx))
        if kind == 'bin':
            return ax[0] == bx[0] and recur(ax[2], bx[2]) and recur(ax[1], bx[1])
        if kind == 'let':
            return recur(ax[0], bx[0]) and binding(ax[1], bx[1])
        if kind == 'quant':
            return ax[0] == bx[0] and binding(ax[1], bx[1])
        if kind == 'eps':
            return binding(ax[0], bx[0])
        raise AssertionError(('case or unsupported proposition constructor', kind))


def stored(graph, roots):
    terms, bindings = set(), set()

    def bind(index):
        if index in bindings:
            return
        bindings.add(index)
        b = graph['bindings'][index]
        walk(b['body'])
        for group in b['triggers']:
            for t in group:
                walk(t)
        for t in b['saved'].values():
            walk(t)

    def walk(index):
        if index in terms:
            return
        terms.add(index)
        t = graph['terms'][index]
        k, a = t['kind'], t['args']
        if k == 'app':
            for x in a[1]: walk(x)
        elif k in ('if', 'not', 'bin'):
            for x in (a[1:] if k == 'bin' else a): walk(x)
        elif k == 'let':
            walk(a[0]); bind(a[1])
        elif k == 'quant': bind(a[1])
        elif k == 'eps': bind(a[0])
        elif k == 'case':
            walk(a[0])
            for _, b in a[1]: bind(b)
        else: assert k in ('var', 'const', 'true', 'false')

    for root in roots: walk(root)
    maps = [graph['bindings'][i]['saved'] for i in bindings]
    return dict(terms=len(terms), bindings=len(bindings),
                nonempty_saved_maps=sum(bool(x) for x in maps),
                saved_entries=sum(map(len, maps)),
                largest_saved_map=max(map(len, maps), default=0))
