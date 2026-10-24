"""Stored type-instantiation seam; not a source-to-VC demand implementation.

Reuse the accepted case-free substitution implementation without rerunning its
checker. The generic mapper also preserves case/pattern syntax in context;
the composed t_ty_subst interface deliberately remains case-free. Type values
denote resolved, canonical Why types, never fresh type-symbol identities.
"""
from collections import Counter
from dataclasses import dataclass, field, replace
from pathlib import Path
import importlib.util
import sys

KPATH = Path(__file__).resolve().parent.parent / 'retained-main-why-storage-20261024/kernel.py'
spec = importlib.util.spec_from_file_location('accepted_storage_kernel', KPATH)
k = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = k
spec.loader.exec_module(k)


@dataclass(frozen=True)
class Ty:
    symbol: str
    args: tuple = ()
    variable: bool = False


@dataclass(frozen=True)
class Pattern:
    op: str
    ty: Ty
    children: tuple = ()
    variable: k.Var | None = None
    symbol: str = ''

    def variables(self):
        s = {self.variable} if self.variable is not None else set()
        for p in self.children:
            s.update(p.variables())
        return s


@dataclass(frozen=True, eq=False)
class Case:
    subject: object
    branches: tuple  # (Pattern, accepted Binding)
    ty: Ty | None = None
    attrs: frozenset = frozenset()
    op: str = 'case'


@dataclass
class Demand:
    kernel: k.Ledger
    calls: Counter = field(default_factory=Counter)
    hsty_requests_upper: int = 0
    ephemeron_tables: int = 0
    ephemeron_lookups: int = 0
    ephemeron_sets_upper: int = 0
    type_pairs: list = field(default_factory=list)
    saved_image_inputs: list = field(default_factory=list)

    def type_inst(self, mapping, ty, memoized=False):
        # Charge every outer callback as a miss. ty_inst recurses directly,
        # not through Wty's wrapper. Returning the same canonical type shape
        # preserves the native equality/freshening choices.
        self.calls['fnT'] += 1
        if memoized:
            self.ephemeron_lookups += 1
            self.ephemeron_sets_upper += 1

        def walk(t):
            self.calls['ty_inst_visit_upper'] += 1
            if t.variable:
                self.kernel.map('type_find_def', len(mapping))
                return mapping.get(t.symbol, t)
            args = tuple(walk(a) for a in t.args)
            self.hsty_requests_upper += 1
            self.calls['ty_app_arity_check'] += 1
            return Ty(t.symbol, args)

        result = walk(ty)
        self.type_pairs.append((ty, result))
        return result


def freevars(t, out):
    """Cached variables, with the same case row as term.ml:605-624."""
    if isinstance(t, Case):
        result = freevars(t.subject, out)
        for _, b in t.branches:
            result = k.union_counts(result, b.free, out)
        return result
    if t.op == 'var':
        return {t.variable: 1}
    if t.op in {'const', 'true', 'false'}:
        return {}
    if t.binding is not None:
        if t.op == 'let':
            return k.union_counts(freevars(t.args[0], out), t.binding.free, out)
        return t.binding.free.copy()
    result = {}
    for child in t.args:
        result = k.union_counts(result, freevars(child, out), out)
    return result


def parts(t):
    if isinstance(t, Case):
        return (t.subject,), tuple(b for _, b in t.branches)
    return t.args, (() if t.binding is None else (t.binding,))


def stored_closed(t):
    """Every saved image's free variables occur in its owning bv_vars.

    This is an invariant check, not a source certificate. The note proves its
    preservation by the native constructors/substitution recurrences.
    """
    out = k.Ledger(0)
    children, binders = parts(t)
    for b in binders:
        if any(not isinstance(n, int) or isinstance(n, bool) or n <= 0 for n in b.free.values()):
            return False
        if any(not set(freevars(image, out)) <= set(b.free)
               for image in b.saved.values()):
            return False
        children += (b.body,) + tuple(x for g in b.triggers for x in g) + tuple(b.saved.values())
    return all(stored_closed(x) for x in children)


def profile(t):
    result = Counter(term=1, case=int(isinstance(t, Case)))
    children, binders = parts(t)
    if isinstance(t, Case):
        def pat(p):
            c = Counter(pattern=1)
            for q in p.children:
                c.update(pat(q))
            return c
        for p, _ in t.branches:
            result.update(pat(p))
            result['pattern_variable_slots'] += len(p.variables())
    for b in binders:
        result.update(binders=1, slots=len(b.variables), free_keys=len(b.free), saved_keys=len(b.saved))
        children += (b.body,) + tuple(x for g in b.triggers for x in g) + tuple(b.saved.values())
    for child in children:
        result.update(profile(child))
    return result


def gen_fresh(v, fnT, demand):
    demand.calls['gen_fresh_attempt'] += 1
    ty = fnT(v.ty)
    return v if ty == v.ty else replace(demand.kernel.fresh(v), ty=ty)


def gen_map(t, mapping, fnT, fnL, demand):
    """term.ml:1085-1151, including the original-map saved-image rule."""
    if isinstance(t, Case):
        if not t.branches:
            raise ValueError('nonempty native case branches required')
    else:
        k.require_term(t)
    out = demand.kernel
    demand.calls['t_gen_map_visit'] += 1

    def rename(v, m):
        v2 = gen_fresh(v, fnT, demand)
        out.map('gen_vs_add', len(m), 1)
        return m | {v: v2}, v2

    def binding(b):
        demand.calls['gen_bnd_rename'] += 1
        out.map('gen_bnd_free_fold', len(b.free))
        free = {}
        for v, n in b.free.items():
            out.map('gen_bnd_free_find', len(mapping))
            out.map('gen_bnd_free_add', len(free), 1)
            if mapping[v] in free:
                raise ValueError('generic variable map must be injective on cached support')
            free[mapping[v]] = n
        nh = mapping.copy()
        saved = {}
        out.map('gen_bnd_saved_fold', len(b.saved))
        for v, image in sorted(b.saved.items(), key=lambda x: x[0].tag):
            nh, v2 = rename(v, nh)
            demand.saved_image_inputs.append((v, image, dict(mapping)))
            # fnE was closed over the OUTER map at term.ml:1114.
            mapped_image = gen_map(image, mapping, fnT, fnL, demand)
            out.map('gen_bnd_saved_add', len(saved), 1)
            saved[v2] = mapped_image
        return nh, free, saved

    def ordinary_binding(b):
        inner, free, saved = binding(b)
        variables = []
        for v in b.variables:
            inner, v2 = rename(v, inner)
            variables.append(v2)
        body = gen_map(b.body, inner, fnT, fnL, demand)
        triggers = tuple(tuple(gen_map(x, inner, fnT, fnL, demand) for x in g) for g in b.triggers)
        return k.Binding(tuple(variables), body, triggers, free, saved)

    def pat(p, m):
        if p.op not in {'wild', 'var', 'app', 'or', 'as'}:
            raise ValueError('foreign pattern constructor')
        demand.calls['pat_gen_map_visit'] += 1
        ty = fnT(p.ty)
        v = m[p.variable] if p.variable is not None else None
        children = tuple(pat(x, m) for x in p.children)
        symbol = fnL(p.symbol) if p.op == 'app' else p.symbol
        return Pattern(p.op, ty, children, v, symbol)

    if isinstance(t, Case):
        subject = gen_map(t.subject, mapping, fnT, fnL, demand)
        branches = []
        for p, b in t.branches:
            inner, free, saved = binding(b)
            pm = {v: gen_fresh(v, fnT, demand) for v in sorted(p.variables(), key=lambda x: x.tag)}
            out.map('gen_pat_mapi', len(pm))
            p2 = pat(p, pm)
            out.map('gen_pat_union', len(inner), len(pm))
            inner.update(pm)
            branches.append((p2, k.Binding(tuple(pm.values()), gen_map(b.body, inner, fnT, fnL, demand), (), free, saved)))
        return Case(subject, tuple(branches), branches[0][1].body.ty, t.attrs)
    if t.op == 'var':
        out.map('gen_var_find_def', len(mapping))
        v = mapping.get(t.variable, t.variable)
        if fnT(t.variable.ty) != v.ty:
            raise ValueError('type-changing free variable not covered by outer mapping')
        result = k.var(v)
    elif t.op == 'const':
        result = replace(t, ty=fnT(t.ty), attrs=frozenset())
    elif t.op in {'true', 'false'}:
        result = t
    elif t.binding is not None:
        b = ordinary_binding(t.binding)
        args = tuple(gen_map(x, mapping, fnT, fnL, demand) for x in t.args)
        ty = b.body.ty if t.op == 'let' else b.variables[0].ty if t.op == 'eps' else None
        result = replace(t, args=args, binding=b, ty=ty, attrs=frozenset())
    else:
        args = tuple(gen_map(x, mapping, fnT, fnL, demand) for x in t.args)
        ty = fnT(t.ty) if t.op == 'app' and t.ty is not None else (args[1].ty if t.op == 'if' else t.ty)
        result = replace(t, args=args, ty=ty, attrs=frozenset(), symbol=fnL(t.symbol) if t.op == 'app' else t.symbol)
    # These are inherited kernel-local charges, not a claim that every new
    # generic/type-checking frame has been priced in native bytes.
    return k.attr_copy(t, result, out)


def ty_subst(mapT, mapV, t, demand):
    if profile(t)['case'] or any(profile(image)['case'] for image in mapV.values()):
        raise ValueError('case-bearing substitution is outside the accepted kernel')
    if not stored_closed(t) or any(not stored_closed(image) for image in mapV.values()):
        raise ValueError('saved-image support invariant is required')
    out = demand.kernel
    free = k.t_vars(t, out)
    out.map('gen_mapV_mapi', len(free))
    # gen_mapV precedes construction of Wty.memoize's wrapper.
    mapping = {v: gen_fresh(v, lambda ty: demand.type_inst(mapT, ty), demand)
               for v in sorted(free, key=lambda x: x.tag)}
    demand.ephemeron_tables += 1
    result = gen_map(t, mapping,
        lambda ty: demand.type_inst(mapT, ty, memoized=True), lambda ls: ls, demand)
    out.map('type_subst_fold2_inter', len(mapping), len(mapV))
    actual = {mapping[v]: image for v, image in mapV.items() if v in mapping}
    return k.subst(actual, result, out)


def cty_specs(pre, post, xpost, mapT, mapV, same_types, demand):
    """The nontrivial cty_apply stage-4 row only; stages 1-3 are separate."""
    def apply(t):
        demand.calls['cty_spec_root'] += 1
        if same_types:
            return k.subst(mapV, t, demand.kernel)
        return ty_subst(mapT, mapV, t, demand)
    return (tuple(map(apply, pre)), tuple(map(apply, post)),
            {x: tuple(map(apply, qs)) for x, qs in xpost.items()})
