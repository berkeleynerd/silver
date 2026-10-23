"""Constructor-preserving restricted Main profile; offline, no native execution.

Native identity and pending temporaries precede E/T projection. Program output
is a resolved application interface, not a claim to have run Why3 typing. Each
application retains its actual occurrences and its separate formal contract.
"""
from collections import Counter
from dataclasses import dataclass


@dataclass(frozen=True)
class Term:
    op: str
    args: tuple = ()
    key: str = ""
    ty: str = "prop"


def var(key, ty="int"):
    return Term("var", key=key, ty=ty)


def atom(key, ty="bool"):
    return Term("atom", key=key, ty=ty)


def app(key, *args, ty="prop"):
    return Term("app", tuple(args), key, ty)


def connective(op, *args, ty="prop"):
    return Term(op, tuple(args), ty=ty)


TRUE = atom("true", "prop")
BTRUE = atom("True")
BFALSE = atom("False")


def affine(t):
    """Lexical E0: binder keys are identities, never printed spellings."""
    if t.op == "var":
        return 0, Counter({t.key: 1})
    children = [affine(a) for a in t.args]
    if t.op == "let":
        (ac, av), (bc, bv) = children
        bv = bv.copy()
        multiplicity = 1 + bv.pop(t.key, 0)
        return 1 + multiplicity * ac + bc, bv + Counter(
            {v: multiplicity * n for v, n in av.items()})
    c, vs = 1, Counter()
    for a, b in children:
        c += a
        vs.update(b)
    return c, vs


def lexical(t, weights):
    if t.op == "var":
        return weights[t.key]
    if t.op == "let":
        definition = lexical(t.args[0], weights)
        return 1 + definition + lexical(t.args[1], weights | {t.key: definition})
    return 1 + sum(lexical(a, weights) for a in t.args)


def term_record(t):
    c, vs = affine(t)
    return {"tree": tree_record(t), "constant": c,
            "coefficients": dict(sorted(vs.items())),
            "unit_weight": c + sum(vs.values())}


def tree_record(t):
    return dict(op=t.op, key=t.key, type=t.ty,
                args=[tree_record(a) for a in t.args])


def split_post(t, result="result"):
    """Source-directed term_of_post(false), with unsimplified residual bound."""
    if (t.op == "app" and t.key == "=" and len(t.args) == 2
            and t.args[0].op == "var" and t.args[0].key == result
            and result not in affine(t.args[1])[1]):
        return t.args[1], TRUE
    if t.op == "iff":
        left, right = t.args
        if (left == app("=", var(result, "bool"), BTRUE)
                and result not in affine(right)[1]):
            return connective("if", right, BTRUE, BFALSE, ty="bool"), TRUE
    if t.op == "and":
        part = split_post(t.args[0], result)
        if part:
            definition, residual = part
            return definition, connective("and", residual, t.args[1])
    return None


@dataclass(frozen=True)
class Signature:
    symbol: str
    arg_types: tuple
    result_type: str
    route: str
    pre: tuple
    post: Term | None
    source: str
    reset: bool = False

    def record(self):
        extracted = split_post(self.post) if self.post else None
        return dict(symbol=self.symbol, arg_types=self.arg_types,
                    result_type=self.result_type, route=self.route,
                    pre=[term_record(t) for t in self.pre],
                    opened_post=term_record(self.post) if self.post else None,
                    closed_post_epsilon=1 if self.post else 0,
                    extracted_definition=term_record(extracted[0]) if extracted else None,
                    residual_upper=term_record(extracted[1]) if extracted else None,
                    extraction_basis=("raw conditional only; later simplification not classified"
                                      if self.symbol == "Discrete.bool_eq" else
                                      "source-directed extraction; residual is an unsimplified upper bound"),
                    reset=self.reset, source=self.source)


def catalogue():
    out = {}

    def logical(symbol, args, result, source, route="RKfunc", reset=False):
        xs = tuple(var(f"a{i}", ty) for i, ty in enumerate(args))
        r = var("result", "bool" if result == "prop" else result)
        f = app(symbol, *xs, ty=result)
        post = (connective("iff", app("=", r, BTRUE), f)
                if result == "prop" else app("=", r, f))
        out[symbol] = Signature(symbol, tuple(args), result, route, (), post,
                                source, reset)

    def explicit(symbol, args, result, pre, post, source):
        out[symbol] = Signature(symbol, tuple(args), result, "RKnone", tuple(pre), post, source)

    for name, arity in (("+", 2), ("-", 2), ("neg", 1), ("*", 2)):
        logical("Int." + name, ("int",) * arity, "int", "int.mlw:18-26")
    for name in ("<", "<=", ">", ">="):
        logical("Int." + name, ("int", "int"), "prop", "int.mlw:21-26", "RKpred")
    logical("Array.slide", ("map", "int", "int"), "map", "_gnatprove_standard.mlw:1933")
    logical("Array.slice", ("map", "int", "int"), "map", "_gnatprove_standard.mlw:1972")
    logical("Array.get", ("map", "int"), "character", "_gnatprove_standard.mlw:1890")
    logical("Array.concat", ("map", "int", "int", "map", "int", "int", "int"),
            "map", "_gnatprove_standard.mlw:2013")
    logical("String.to_array", ("string",), "map", "ada__model.mlw:1629")
    logical("String.of_array", ("map", "int", "int"), "string", "ada__model.mlw:1631-1632")
    for name, line in (("first", 1636), ("last", 1640), ("length", 1644)):
        logical("String." + name, ("string",), "int", f"ada__model.mlw:{line}-{line+4}", "RKnone explicit equality")
    for module in ("Standard.Integer", "Standard.Positive"):
        for bound in ("first", "last"):
            logical(module + "." + bound, (), "int",
                    "gnat_ast_to_ptree.ml:1044-1059; dexpr.ml:1817-1833; supplied entity resolution",
                    "RKfunc nullary declaration")
    for ty in ("int", "bool", "map"):
        logical(ty + "__content", (ty + "__ref",), ty,
                "expr.ml:173-184; _gnatprove_standard.mlw:32-33,1884", "projection")
        logical(ty + "__mkref", (ty,), ty + "__ref", "expr.ml:193-211", "constructor", True)
    # There is no program call for dynamic_property in this construction row.
    out["String.dynamic_property"] = Signature(
        "String.dynamic_property", ("int",) * 4, "prop", "logic-only", (), None,
        "ada__model.mlw:1650-1651; why-gen-arrays.adb:3305-3366")
    # Equality is a polymorphic logical intrinsic; only its term route is used.
    out["="] = Signature("=", ("any", "any"), "prop", "logic-only", (), None, "Why3 equality")
    n, r, f, l = var("a0"), var("result"), var("a0"), var("a1")
    for prefix, arg_types, value, range_pred in (
            ("Static", ("int",), n, app("Static.in_range", n)),
            ("Dynamic", ("int",) * 3, var("a2"), app("Dynamic.dynamic_property", f, l, var("a2")))):
        explicit(prefix + ".range_check", arg_types, "int", (range_pred,),
                 connective("and", app("=", r, value), range_pred),
                 "ada__model.mlw:77-89,459-469")
        for name, bound in (("first", f), ("last", l)):
            bound = atom(prefix + "." + name, "int") if prefix == "Static" else bound
            p = connective("not", app("=", value, bound))
            explicit(prefix + ".check_not_" + name, arg_types, "int", (p,),
                     connective("and", app("=", r, value), p), "ada__model.mlw:77-83,459-465")
    explicit("Boolean.range_check", ("int",), "int", (app("Boolean.in_range", n),),
             app("=", r, n), "_gnatprove_standard.mlw:1814-1816")
    for name in ("first", "last"):
        p = connective("not", app("=", n, atom("Boolean." + name, "int")))
        explicit("Boolean.check_not_" + name, ("int",), "int", (p,), app("=", r, n),
                 "_gnatprove_standard.mlw:1818-1824")
    x, y, rb = var("a0", "bool"), var("a1", "bool"), var("result", "bool")
    for name, yes, no in (("bool_eq", BTRUE, BFALSE), ("bool_ne", BFALSE, BTRUE)):
        explicit("Boolean." + name, ("bool", "bool"), "bool", (),
                 app("=", rb, connective("if", app("=", x, y), yes, no, ty="bool")),
                 "_gnatprove_standard.mlw:1826-1830")
    explicit("Discrete.bool_eq", ("rep", "rep"), "bool", (),
             connective("if", app("=", var("a0", "rep"), var("a1", "rep")),
                        app("=", rb, BTRUE), connective("not", app("=", rb, BTRUE))),
             "ada__model.mlw:38-42")
    explicit("Rep_Proj_Base.to_rep", ("abstract",), "int", (),
             app("=", app("Rep_Proj_Base.to_rep", var("a0", "abstract"), ty="int"), r),
             "ada__model.mlw:14-15; program binding, not Cpur logical route")
    explicit("Rep_Proj_Base.of_rep", ("int",), "abstract", (),
             app("=", app("Rep_Proj_Base.to_rep", var("result", "abstract"), ty="int"), n),
             "ada__model.mlw:11-12; result under projection, no extraction")
    return out


@dataclass(frozen=True)
class Native:
    uid: int
    op: str
    ty: str
    args: tuple = ()
    key: str = ""
    domain: str = "term"
    symbol_identifier: bool = False


class Builder:
    def __init__(self):
        self.serial = 0
        self.pending = {}
        self.events = []
        self.issued = {}

    def require_owned(self, *nodes):
        if any(self.issued.get(n.uid) is not n for n in nodes):
            raise ValueError("native node identity belongs to a different builder")

    def node(self, op, ty, *args, key="", domain="term", symbol_identifier=False):
        self.require_owned(*args)
        self.serial += 1
        n = Native(self.serial, op, ty, tuple(args), key, domain, symbol_identifier)
        self.issued[n.uid] = n
        return n

    def identifier(self, key, ty, *, symbol=False):
        if key.startswith("tmp:"):
            raise ValueError("tmp: is reserved for generated identity tokens")
        return self.node("identifier", ty, key=key, symbol_identifier=symbol)

    def call(self, key, ty, *args, domain="term"):
        return self.node("call", ty, *args, key=key, domain=domain)

    def temporary(self, expression, need=True):
        self.require_owned(expression)
        if ((need and expression.op not in {"identifier", "deref"})
                or expression.uid in self.pending):
            tmp = self.node("identifier", expression.ty, key=f"tmp:{self.serial + 1}")
            self.pending[tmp.uid] = expression
            self.events.append(("create", tmp.uid, expression.uid))
            return tmp
        self.events.append(("reuse", expression.uid))
        return expression

    def binding(self, tmp, context, domain="prog"):
        self.require_owned(tmp, context)
        definition = self.pending.pop(tmp.uid, None)
        if definition is None:
            self.events.append(("no-binding", tmp.uid))
            return context
        self.events.append(("consume", tmp.uid, definition.uid))
        return self.node("binding", context.ty, definition, context,
                         key=tmp.key, domain=domain)


@dataclass(frozen=True)
class ArrayShape:
    identity: str
    static: bool
    first: Native
    last: Native

    @property
    def ty(self):
        return "map" if self.static else "string"


def array_attr(b, source, a, name):
    if source.static:
        return source.first if name == "first" else source.last
    return b.call("String." + name, "int", a)


def array_map(b, source, a, domain):
    return a if source.static else b.call("String.to_array", "map", a, domain=domain)


def length_equality(b, lf, ll, rf, rl):
    """why-gen-arrays:3396-3462; six calls, conjunction and conditional."""
    le_l = b.call("Int.<=", "bool", lf, ll)
    le_r = b.call("Int.<=", "bool", rf, rl)
    sub_l = b.call("Int.-", "int", ll, lf)
    sub_r = b.call("Int.-", "int", rl, rf)
    eq = b.call("=", "bool", sub_l, sub_r, domain="pred")
    both = b.node("and", "bool", le_r, eq, domain="pred")
    # The native source really supplies Typ => Base_Ty in this predicate call.
    # Typed context comes from the selected symbol, not this native annotation.
    empty_r = b.call("Int.<", "int", rl, rf)
    return b.node("if", "bool", le_l, both, empty_r, domain="pred")


def array_conversion(b, e, source, target, *, sliding=False, need_check=False,
                     domain="prog", static_lengths_equal=False):
    """Exact retained constructor row under the documented ordinary premises.

    Caller supplies actual Ada type identity, static status, bounds already in
    integer representation, the reached Sliding decision, and length equality.
    No relaxed-init, qualification, component conversion or predicate branch.
    """
    b.require_owned(e, source.first, source.last, target.first, target.last)
    if domain not in {"prog", "term"} or e.ty != source.ty:
        raise ValueError("uncovered domain or representation")
    if any(x.ty != "int" for x in (source.first, source.last, target.first, target.last)):
        raise ValueError("bounds must preserve their integer-representation trees")
    if source.identity == target.identity:
        if source != target:
            raise ValueError("equal Ada identity requires coherent shape summaries")
        return e
    if sliding and not target.static:
        raise ValueError("unconstrained/fixed-lower-bound sliding is outside this row")
    a = b.temporary(e)
    if sliding:
        m = b.call("Array.slide", "map", array_map(b, source, a, domain),
                   array_attr(b, source, a, "first"), target.first, domain=domain)
    else:
        m = array_map(b, source, a, domain)
    # Empty Label is a native node. It forces the second temporary before its
    # attributes are later discarded by E/T conversion.
    split = b.temporary(b.node("label", "map", m, domain=domain))
    if target.static:
        value = split
    else:
        value = b.call("String.of_array", "string", split,
                       array_attr(b, source, a, "first"),
                       array_attr(b, source, a, "last"), domain=domain)
    if domain == "prog" and need_check:
        if target.static:
            if static_lengths_equal and not source.static:
                raise ValueError("static length elision needs both static types")
            check = (None if source.static and static_lengths_equal else length_equality(
                b, array_attr(b, source, a, "first"), array_attr(b, source, a, "last"),
                target.first, target.last))
        else:
            check = b.call("String.dynamic_property", "bool", target.first, target.last,
                           array_attr(b, source, a, "first"),
                           array_attr(b, source, a, "last"), domain="pred")
        if check is not None:
            assertion = b.node("assert", "unit", check, domain="prog")
            value = b.node("sequence", value.ty, assertion, value, domain="prog")
    value = b.binding(split, value, domain)
    return b.binding(a, value, domain)


def validate_call(symbol, children, signatures):
    s = signatures[symbol]
    if len(children) != len(s.arg_types):
        raise ValueError(f"unsaturated symbol: {symbol}")
    for actual, expected in zip(children, s.arg_types):
        if expected != "any" and actual.ty != expected:
            raise ValueError(f"argument type mismatch for {symbol}: {actual.ty} vs {expected}")
    if symbol == "=" and children[0].ty != children[1].ty:
        raise ValueError("equality arguments have different types")
    return s


def term(n, signatures, want="value"):
    """Typed logical skeleton with explicit Boolean/proposition coercions."""
    if n.op == "identifier" and n.symbol_identifier:
        s = validate_call(n.key, (), signatures)
        t = app(n.key, ty=s.result_type)
    elif n.op == "identifier":
        t = var(n.key, n.ty)
    elif n.op == "constant":
        t = atom(n.key, n.ty)
    elif n.op == "label":
        return term(n.args[0], signatures, want)
    elif n.op in {"call", "deref"}:
        xs = tuple(term(a, signatures) for a in n.args)
        s = validate_call(n.key, xs, signatures)
        t = app(n.key, *xs, ty=s.result_type)
    elif n.op == "binding":
        t = Term("let", (term(n.args[0], signatures), term(n.args[1], signatures, want)),
                 n.key, "prop" if want == "prop" else n.ty)
    elif n.op == "and":
        t = connective("and", *(term(a, signatures, "prop") for a in n.args))
    elif n.op == "if":
        t = connective("if", term(n.args[0], signatures, "prop"),
                       term(n.args[1], signatures, want), term(n.args[2], signatures, want),
                       ty="prop" if want == "prop" else n.ty)
    else:
        raise ValueError(f"uncovered term constructor: {n.op}")
    if want == "prop" and t.ty != "prop":
        if t.ty != "bool":
            raise ValueError("only Boolean values coerce to propositions")
        return app("=", t, BTRUE)
    if want == "value" and t.ty == "prop":
        return connective("if", t, BTRUE, BFALSE, ty="bool")
    return t


@dataclass(frozen=True)
class Program:
    op: str
    ty: str
    args: tuple = ()
    key: str = ""
    attached: Term | None = None
    input_scope: str = ""


def program(n, signatures, supplied=None):
    """Mode E is inherited by call actuals, regardless of native domain tag.

    supplied maps native UIDs to already derived child Program profiles or
    Program('input', type, key=provider_identity) handles. A handle retains the
    complete child profile by reference; it is not an Evar or a zero-cost term.
    Every occurrence imports that profile once, including its attached terms,
    contracts, effects and binders (with the enclosing scope's alpha-renaming).
    """
    supplied = {} if supplied is None else supplied
    if n.uid in supplied:
        p = supplied[n.uid]
        if p.ty != n.ty:
            raise ValueError("supplied child profile type mismatch")
        if p.op == "input" and (not p.key or not p.input_scope):
            raise ValueError("complete-profile handle and binding-context identity are required")
        return p
    if n.op == "identifier" and n.symbol_identifier:
        s = validate_call(n.key, (), signatures)
        if s.route == "logic-only":
            raise ValueError("program binding or Cpur route must be supplied")
        return Program("application", n.ty, key=n.key)
    if n.op in {"identifier", "constant"}:
        return Program(n.op, n.ty, key=n.key)
    if n.op == "label":
        return program(n.args[0], signatures, supplied)
    if n.op in {"call", "deref"}:
        xs = tuple(program(a, signatures, supplied) for a in n.args)
        s = validate_call(n.key, xs, signatures)
        if s.route == "logic-only":
            raise ValueError("this catalogue has no program route for " + n.key)
        ty = "bool" if s.result_type == "prop" else s.result_type
        return Program("application", ty, xs, n.key)
    if n.op in {"binding", "sequence"}:
        return Program(n.op, n.ty, tuple(program(a, signatures, supplied) for a in n.args), n.key)
    if n.op in {"if", "and", "or", "not"}:
        return Program(n.op, n.ty, tuple(program(a, signatures, supplied) for a in n.args))
    if n.op == "assert":
        return Program("assert", "unit", attached=term(n.args[0], signatures, "prop"))
    raise ValueError(f"uncovered program constructor: {n.op}")


def program_record(p, signatures):
    out = dict(op=p.op, type=p.ty, key=p.key,
               args=[program_record(a, signatures) for a in p.args])
    if p.attached:
        out["attached_term"] = term_record(p.attached)
    if p.op == "application":
        out["formal_contract"] = p.key
        out["proxy_actual_slots"] = len(p.args)
    if p.op == "input":
        out["input_scope"] = p.input_scope
        out["imports"] = "complete child profile: body, contracts, terms, effects, free and bound identities"
    return out


def typed_expression_affine(p):
    """Accepted local typing envelope with symbolic supplied-child sizes."""
    if p.op == "input":
        return 0, Counter({p.key: 1})
    if p.op not in {"application", "identifier", "constant", "binding", "sequence",
                    "assert", "if", "and", "or", "not"}:
        raise ValueError("no typed-expression transfer for " + p.op)
    local = (2 + 2 * len(p.args) if p.op == "application" else
             2 if p.op in {"and", "or"} else 3 if p.op == "not" else 1)
    coeff = Counter()
    for a in p.args:
        c, vs = typed_expression_affine(a)
        local += c
        coeff.update(vs)
    return local, coeff


def typed_expression_nodes(p, inputs=None):
    c, vs = typed_expression_affine(p)
    inputs = {} if inputs is None else inputs
    return c + sum(n * inputs[k] for k, n in vs.items())


def program_inventory(p):
    counts = Counter({p.op: 1})
    if p.op == "application":
        counts["call:" + p.key] += 1
        counts["proxy_actual_slots"] += len(p.args)
    if p.attached:
        counts["attached_terms"] += 1
    for a in p.args:
        counts.update(program_inventory(a))
    return counts
