"""Case-free Term storage transfer and Vc.add_vc_decl's selection gate.

This is a focused mathematical model, not a Silver/WhyML parser or an
allocation observer. Input values preserve bind_info including dead saved
keys. Counters use Python integers. Native request estimates use the retained
Extmap lemma; no cumulative byte total is a native scalar or a RAM limit.

We deliberately overconstruct t_attr_copy results, preserving structure and
attributes but not all physical-sharing optimizations. The selected routines'
control does not depend on that difference, except for requests we overcharge.
The resulting request vector is an upper bound, not an exact native trace.
"""
from collections import Counter
from dataclasses import dataclass, field, replace

MAX_INT = 2**62 - 1
ANNOT = 1
SUPPORTED = {'var', 'const', 'app', 'if', 'let', 'eps', 'forall', 'exists',
             'and', 'or', 'implies', 'iff', 'not', 'true', 'false'}
OWNERS = ('Hsdecl', 'Hsty', 'Hstdecl', 'Hstask', 'Hcpt', 'Hsattr')


@dataclass(frozen=True)
class Var:
    tag: int
    ty: str = 'int'
    attrs: frozenset = frozenset()


@dataclass(frozen=True, eq=False)
class Binding:
    variables: tuple
    body: 'Term'
    triggers: tuple = ()
    free: dict = field(default_factory=dict)
    saved: dict = field(default_factory=dict)


@dataclass(frozen=True, eq=False)
class Term:
    op: str
    args: tuple = ()
    variable: Var | None = None
    binding: Binding | None = None
    attrs: frozenset = frozenset()
    ty: str | None = None
    symbol: str = ''


def var(v, attrs=frozenset()):
    return Term('var', variable=v, ty=v.ty, attrs=attrs)


def node(op, *args, attrs=frozenset(), ty=None, symbol=''):
    if op not in SUPPORTED or op in {'var', 'let', 'eps', 'forall', 'exists'}:
        raise ValueError('unsupported ordinary constructor')
    return Term(op, args, attrs=attrs, ty=ty, symbol=symbol)


@dataclass
class Ledger:
    # An unwrapped, source-derived entry counter is required for attachment.
    ident_entry: int
    ident_increments: int = 0
    local_bytes_upper: int = 0
    map_bytes_upper: int = 0
    calls: Counter = field(default_factory=Counter)
    products: list = field(default_factory=list)
    sums: list = field(default_factory=list)
    map_domain_upper: int = 0
    maximum_count: int = 0
    saved_image_slots_added_upper: int = 0
    candidate_records: Counter = field(default_factory=Counter)

    def local(self, family, slots=1):
        if slots < 1:
            raise ValueError('positive source frame allowance required')
        self.calls[family] += 1
        # Reuses the accepted native/source local-frame envelope; lists and
        # binder lists are separate slots, client callbacks recurse below.
        self.local_bytes_upper += 4096 * slots

    def map(self, family, n, m=0):
        if min(n, m) < 0:
            raise ValueError('negative cardinality')
        self.calls['map.' + family] += 1
        self.map_domain_upper = max(self.map_domain_upper, n + m)
        self.map_bytes_upper += 4096 * (n + m + 1)**3

    def count(self, n):
        if n < 0:
            raise ValueError('negative variable occurrence count')
        self.maximum_count = max(self.maximum_count, n)
        return n

    def add_count(self, a, b):
        self.count(a); self.count(b)
        self.sums.append((a, b, a+b))
        return self.count(a+b)

    def mul_count(self, a, b):
        self.count(a); self.count(b)
        self.products.append((a, b, a*b))
        return self.count(a*b)

    def fresh(self, v):
        self.local('fresh_vsymbol')
        self.map('id_clone_attribute_union', 0, len(v.attrs))
        self.ident_increments += 1
        self.candidate_records.update(ident=1, preid=1, vsymbol=1)
        return Var(self.ident_entry + self.ident_increments, v.ty, v.attrs)

    def guards(self, max_int=MAX_INT):
        return {
            'entry_ident_nonnegative': 0 <= self.ident_entry <= max_int,
            'ident_endpoint': self.ident_entry + self.ident_increments <= max_int,
            'occurrence_sums_and_products': self.maximum_count <= max_int,
            # Every selected Extmap scalar is a height, height+1 or height+2.
            # Domain upper + 3 also covers all selected presence/enumeration
            # bookkeeping without bounding the mathematical byte sum.
            'map_height_arithmetic': self.map_domain_upper + 3 <= max_int,
            'fixed_block_headers': 512 <= 2**54 - 1,
        }

    def result(self):
        return {
            'ident_entry': self.ident_entry,
            'ident_increments': self.ident_increments,
            'ident_exit_upper': self.ident_entry + self.ident_increments,
            'other_owner_requests': {k: 0 for k in OWNERS},
            'other_owner_increments': {k: 0 for k in OWNERS},
            'local_bytes_upper': self.local_bytes_upper,
            'map_bytes_upper': self.map_bytes_upper,
            'direct_bytes_upper': self.local_bytes_upper + self.map_bytes_upper,
            'calls': dict(sorted(self.calls.items())),
            'candidate_records_upper': dict(sorted(self.candidate_records.items())),
            'map_domain_upper': self.map_domain_upper,
            'maximum_occurrence_count': self.maximum_count,
            'saved_image_slots_added_upper': self.saved_image_slots_added_upper,
            'guard_results': self.guards(),
            'complete_main_caller_attachment': False,
        }


def require_term(t):
    if t.op not in SUPPORTED:
        raise ValueError('case/pattern or foreign term family is not covered')


def union_counts(a, b, out):
    out.map('vars_union', len(a), len(b))
    result = a.copy()
    for v, n in b.items():
        out.count(n)
        result[v] = out.add_count(result[v], n) if v in result else n
    return result


def t_vars(t, out):
    require_term(t)
    out.local('t_vars')
    if t.op == 'var':
        out.map('singleton', 1)
        return {t.variable: 1}
    if t.op in {'const', 'true', 'false'}:
        return {}
    if t.op in {'eps', 'forall', 'exists'}:
        for n in t.binding.free.values():
            out.count(n)
        return t.binding.free.copy()
    if t.op == 'let':
        return union_counts(t_vars(t.args[0], out), t.binding.free, out)
    if t.op == 'not':
        return t_vars(t.args[0], out)
    if t.op == 'app':
        acc = {}
        for child in t.args:
            acc = union_counts(acc, t_vars(child, out), out)
        return acc
    # if and binary operators start with the first child's map.
    acc = t_vars(t.args[0], out)
    for child in t.args[1:]:
        acc = union_counts(acc, t_vars(child, out), out)
    return acc


def close(op, variables, body, out, *, value=None, triggers=()):
    if op not in {'let', 'eps', 'forall', 'exists'}:
        raise ValueError('unsupported binding')
    if not variables or (op in {'let', 'eps'} and len(variables) != 1):
        raise ValueError('nonempty quantifier or singleton binding required')
    if op in {'let', 'eps'} and triggers:
        raise ValueError('triggers belong to quantifiers')
    out.local('close_binding', 1 + len(variables) + len(triggers))
    free = t_vars(body, out)
    for trigger in triggers:
        for t in trigger:
            free = union_counts(free, t_vars(t, out), out)
    for v in variables:
        out.map('remove', len(free))
        free.pop(v, None)
    binding = Binding(tuple(variables), body, tuple(triggers), free, {})
    out.candidate_records.update(bind_info=1, binder_tuple=1, term=1, variant=1)
    if op == 'eps':
        out.candidate_records['option'] += 1  # checked t_eps supplies Some v.vs_ty
    args = (value,) if op == 'let' else ()
    ty = body.ty if op == 'let' else variables[0].ty if op == 'eps' else None
    return Term(op, args, binding=binding, ty=ty)


def attr_copy(source, target, out):
    # Includes all three native branches, deliberately overcharging old-return.
    out.local('t_attr_copy')
    out.map('attribute_union', len(source.attrs), len(target.attrs))
    out.candidate_records['term'] += 1
    return replace(target, attrs=source.attrs | target.attrs)


def bv_subst(mapping, b, out):
    out.local('bv_subst_unsafe')
    out.map('set_inter', len(mapping), len(b.free))
    restricted = {v: t for v, t in mapping.items() if v in b.free}
    if not restricted:
        return b
    out.map('set_diff', len(b.free), len(restricted))
    free = {v: n for v, n in b.free.items() if v not in restricted}
    out.map('fold2_inter', len(b.free), len(restricted))
    # Native fold is tag ordered. Sum maxima are order independent because
    # every summand is nonnegative, so use ascending tags here as well.
    for v in sorted(restricted, key=lambda k: k.tag):
        image_free = t_vars(restricted[v], out)
        n = b.free[v]
        if n != 1:
            out.map('map_scale', len(image_free))
            image_free = {w: out.mul_count(n, c) for w, c in image_free.items()}
        free = union_counts(free, image_free, out)
    out.map('map_saved', len(b.saved))
    saved = {v: subst_inner(restricted, t, out) for v, t in b.saved.items()}
    out.map('set_union_saved', len(saved), len(restricted))
    out.saved_image_slots_added_upper += len(restricted)
    # set_union keeps the LEFT old/re-written value on a duplicate key.
    saved = restricted | saved
    out.candidate_records['bind_info'] += 1
    return replace(b, free=free, saved=saved)


def b_subst(mapping, b, out):
    out.map('set_disjoint', len(mapping), len(b.free))
    if not (mapping.keys() & b.free.keys()):
        return b
    out.candidate_records['binder_tuple'] += 1
    return bv_subst(mapping, b, out)


def subst_inner(mapping, t, out):
    require_term(t)
    out.local('t_subst_visit', 1 + (len(t.args) if t.op == 'app' else 0))
    if t.op == 'var':
        return attr_copy(t, mapping.get(t.variable, t), out)
    if t.op in {'const', 'true', 'false'}:
        # t_map_unsafe calls attr_copy with the SAME object: no numeric compare.
        out.local('t_attr_copy_same')
        return t
    if t.op == 'let':
        args = (subst_inner(mapping, t.args[0], out),)
        updated = replace(t, args=args, binding=b_subst(mapping, t.binding, out),
                          attrs=frozenset())
    elif t.op in {'eps', 'forall', 'exists'}:
        updated = replace(t, binding=b_subst(mapping, t.binding, out),
                          attrs=frozenset())
    else:
        args = tuple(subst_inner(mapping, a, out) for a in t.args)
        updated = replace(t, args=args, attrs=frozenset())
        if t.op == 'app':
            out.candidate_records['list_cons'] += len(args)
    out.candidate_records.update(term=1, variant=1)
    return attr_copy(t, updated, out)


def subst(mapping, t, out):
    out.local('t_subst_entry')
    out.map('iter_type_check', len(mapping))
    for v, image in mapping.items():
        if v.ty != image.ty:
            raise ValueError('type-preserving kernel premise violated')
    return subst_inner(mapping, t, out) if mapping else t


def open_binding(b, out, *, quantified=False):
    width = len(b.variables)
    if not quantified and width != 1:
        raise ValueError('singleton bound required')
    out.local('t_open_quant' if quantified else 't_open_bound',
              1 + 2*width + len(b.triggers) + sum(map(len, b.triggers)))
    mapping = b.saved.copy()
    variables = []
    for old in b.variables:
        fresh = out.fresh(old)
        variables.append(fresh)
        out.local('t_var_fresh')
        out.candidate_records.update(term=1, variant=1, option=1)
        out.map('add_opening', len(mapping), 1)
        mapping[old] = var(fresh)
    if quantified:
        out.candidate_records['list_cons'] += 2*width + len(b.triggers) + sum(map(len, b.triggers))
    # t_open_quant constructs every trigger even when its caller ignores them.
    triggers = tuple(tuple(subst_inner(mapping, t, out) for t in group)
                     for group in b.triggers)
    body = subst_inner(mapping, b.body, out)
    return tuple(variables), triggers, body


def trivial(t, out):
    require_term(t)
    out.local('is_trivial_vc')
    if t.op == 'true':
        return True
    if t.op in {'let', 'forall'}:
        _, _, body = open_binding(t.binding, out, quantified=t.op == 'forall')
        return trivial(body, out)
    if t.op == 'implies':
        return trivial(t.args[1], out)
    if t.op == 'and':
        return trivial(t.args[0], out) and trivial(t.args[1], out)
    if t.op == 'if':
        return trivial(t.args[1], out) and trivial(t.args[2], out)
    return False


def has_annotation(t, out):
    require_term(t)
    out.local('has_attr')
    out.map('attribute_mem', len(t.attrs))
    if ANNOT in t.attrs:
        return True
    # Term.t_any uses the safe opening fold, not t_fold_unsafe at a binder.
    if t.op in {'let', 'eps', 'forall', 'exists'}:
        _, triggers, body = open_binding(t.binding, out,
                                         quantified=t.op in {'forall', 'exists'})
        # In t_fold's let branch opening precedes visiting the definition.
        if t.op == 'let' and has_annotation(t.args[0], out):
            return True
        if has_annotation(body, out):
            return True
        return any(has_annotation(t, out) for group in triggers for t in group)
    return any(has_annotation(a, out) for a in t.args)


def select_candidate(t, out):
    """Return keep/drop at entry to mk_vc_decl, without invoking its body."""
    out.local('add_vc_decl_gate')
    is_trivial = trivial(t, out)
    annotated = has_annotation(t, out) if is_trivial else None
    return {'trivial': is_trivial, 'annotated_if_tested': annotated,
            'keep': not is_trivial or annotated}


def stored_profile(t):
    """Occurrence profile includes EVERY saved image, even dead keys."""
    require_term(t)
    result = Counter(term=1, attrs=len(t.attrs))
    for child in t.args:
        result.update(stored_profile(child))
    if t.binding is not None:
        b = t.binding
        result.update(binders=1, slots=len(b.variables), free_keys=len(b.free),
                      saved_keys=len(b.saved))
        result.update(stored_profile(b.body))
        for group in b.triggers:
            for child in group:
                result.update(stored_profile(child))
        for child in b.saved.values():
            result.update(stored_profile(child))
    return result


def validate_inputs(terms, ident_entry):
    """Check structural/identity premises; semantic cache validity is separate.

    The source induction supplies typing and the bv_vars/cache relation. This
    checker cannot turn an arbitrary Binding fixture into that source result.
    """
    if not isinstance(ident_entry, int) or isinstance(ident_entry, bool) or ident_entry < 0:
        raise ValueError('unwrapped nonnegative Ident entry required')
    seen = set(); active = set(); variables = {}

    def variable(v):
        if not 0 < v.tag <= ident_entry:
            raise ValueError('input identifier outside the attached entry domain')
        if v.tag in variables and variables[v.tag] != v:
            raise ValueError('one identifier tag has inconsistent metadata')
        variables[v.tag] = v

    def visit(t):
        require_term(t)
        if id(t) in active:
            raise ValueError('cyclic stored term graph')
        if id(t) in seen:
            return
        active.add(id(t))
        if t.variable is not None:
            variable(t.variable)
        for a in t.args:
            visit(a)
        if t.binding is not None:
            b = t.binding
            for v in b.variables:
                variable(v)
            for v, n in b.free.items():
                variable(v)
                if not isinstance(n, int) or isinstance(n, bool) or n <= 0:
                    raise ValueError('positive occurrence cache required')
            for v, image in b.saved.items():
                variable(v); visit(image)
            visit(b.body)
            for group in b.triggers:
                for child in group:
                    visit(child)
        active.remove(id(t)); seen.add(id(t))
    for t in terms:
        visit(t)


def gate_batch(terms, ident_entry):
    """One actual source-derived graph per candidate; one shared owner counter."""
    validate_inputs(terms, ident_entry)
    out = Ledger(ident_entry)
    decisions = []
    for t in terms:
        decisions.append(select_candidate(t, out))
    return decisions, out
