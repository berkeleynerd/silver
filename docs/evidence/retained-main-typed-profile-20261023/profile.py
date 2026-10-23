"""Binder-aware native contract projection; no compiler or prover execution.

This module deliberately does not label a native expression as a typed Why3
term.  The expression tree, declared types, effects and affine lexical costs
are separate outputs, allowing the remaining typing transfer to be audited.
"""

from collections import Counter


def qualified(node):
    assert node[0] == "W_NAME"
    module = node[5]
    return ".".join(x for x in ([module[3], module[4]] if module else [])
                    + [node[4], node[3]] if x)


def identifier(node):
    assert node[0] == "W_IDENTIFIER"
    return qualified(node[3])


def type_name(node):
    assert node[0] == "W_TYPE"
    return qualified(node[4])


def node(op, args=(), **data):
    return dict(op=op, args=list(args), **data)


class Projector:
    def __init__(self, formals, result_type, effects):
        self.binders = {}
        self.serial = 0
        self.env = {n: n for n, ty in formals}
        self.types = dict(formals)
        self.env["result"] = "result"
        self.types["result"] = result_type
        self.effects = effects

    def bind(self, ident, declared_type):
        spelling = identifier(ident)
        self.serial += 1
        key = f"b{self.serial}:{spelling}"
        self.binders[key] = dict(spelling=spelling, type=declared_type)
        return spelling, key

    def term(self, x, env=None):
        env = self.env if env is None else env
        tag = x[0]
        if tag == "W_LABEL":
            return self.term(x[4], env)
        if tag == "W_LOC_LABEL":
            return self.term(x[4], env)
        if tag == "W_IDENTIFIER":
            spelling = identifier(x)
            assert " " not in spelling, "embedded application needs a separate row"
            if spelling in env or spelling in self.effects:
                return node("var", key=env.get(spelling, spelling),
                            type=self.effects[spelling] if spelling in self.effects
                            else type_name(x[4]) if x[4] else self.types.get(spelling))
            return node("constant", symbol=spelling,
                        type=type_name(x[4]) if x[4] else None)
        if tag == "W_INTEGER_CONSTANT":
            return node("integer", value=x[3], type="int")
        if tag == "W_LITERAL":
            return node("truth", value=x[3], domain=x[2], type="bool")
        if tag == "W_CALL":
            return node("application", [self.term(a, env) for a in x[4] or []],
                        symbol=identifier(x[3]), domain=x[2],
                        type=type_name(x[5]) if x[5] else None)
        if tag == "W_DEREF":
            return node("projection", [self.term(x[3], env)],
                        symbol=type_name(x[4]) + "__content")
        if tag == "W_CONNECTION":
            operands = [x[3], x[5]] + (x[6] or [])
            return node("connection", [self.term(a, env) for a in operands],
                        connector=x[4])
        if tag == "W_NOT":
            return node("not", [self.term(x[3], env)])
        if tag == "W_CONDITIONAL":
            assert not x[5], "selected fixed contracts have no elsif list"
            return node("if", [self.term(x[3], env), self.term(x[4], env),
                               self.term(x[6], env) if x[6] else node("truth", value=0)])
        if tag == "W_BINDING":
            spelling, key = self.bind(x[3], type_name(x[3][4]))
            definition = self.term(x[4], env)
            body = self.term(x[5], env | {spelling: key})
            return node("let", [definition, body], binder=key)
        if tag in {"W_UNIVERSAL_QUANTIF", "W_EXISTENTIAL_QUANTIF"}:
            entries = [self.bind(b[3], type_name(b[4])) for b in x[3]]
            extended = env | dict(entries)
            assert tag == "W_UNIVERSAL_QUANTIF" and not x[5], "audit triggers separately"
            return node("forall", [self.term(x[6], extended)],
                        binders=[key for _, key in entries])
        raise AssertionError(f"uncovered native term: {tag}")


def affine(t):
    """Return constant and free-variable coefficients for lexical E0.

    Definitions count at their own site and at every use.  Variable identity
    is the alpha-fresh binding key, never its source spelling alone.
    """
    op = t["op"]
    if op == "var":
        return 0, Counter({t["key"]: 1})
    children = [affine(a) for a in t["args"]]
    if op == "let":
        (ac, av), (bc, bv) = children
        bv = bv.copy()
        uses = bv.pop(t["binder"], 0)
        return 1 + (1 + uses) * ac + bc, bv + Counter(
            {v: (1 + uses) * n for v, n in av.items()})
    constant = max(1, len(children) - 1) if op == "connection" else 1
    coeff = Counter()
    for c, vs in children:
        constant += c
        coeff.update(vs)
    if op == "forall":
        for v in t["binders"]:
            constant += coeff.pop(v, 0)
    return constant, coeff


def summary(t):
    c, coeff = affine(t)
    return dict(constant=c, coefficients=dict(sorted(coeff.items())),
                at_unit_weights=c + sum(coeff.values()))


def split_result(t):
    """Selected `term_of_post ~prop:false` left-conjunction extraction.

    Keep an unsimplified residual as an upper envelope. No result occurs in
    the selected RHS definitions; no Boolean-iff or function-type case is
    reached by these five complete contract templates.
    """
    if (t["op"] == "application" and t["symbol"] == "="
            and len(t["args"]) == 2 and t["args"][0]["op"] == "var"
            and t["args"][0]["key"] == "result"
            and "result" not in affine(t["args"][1])[1]):
        return t["args"][1], node("truth", value=0, domain=3, type="bool")
    if t["op"] == "connection" and t["connector"] in {1, 5}:
        found = split_result(t["args"][0])
        if found:
            definition, residual = found
            return definition, dict(t, args=[residual] + t["args"][1:])
    return None


def contract(declaration):
    d = declaration
    assert d[0] == "W_FUNCTION_DECL" and d[2] == 4 and d[9] is None
    formals = [[identifier(b[3]), type_name(b[4])] for b in d[4] or []]
    effects = d[5]
    assert effects[0] == "W_EFFECTS" and not effects[5]
    # The annotation on a native identifier is its snapshot type.  Its actual
    # global variable is declared at <snapshot>__ref by converter 1209--1224.
    reads = {identifier(v): type_name(v[4]) + "__ref" for v in effects[3] or []}
    writes = {identifier(v): type_name(v[4]) + "__ref" for v in effects[4] or []}
    p = Projector(formals, type_name(d[8]), reads | writes)
    pre, post = p.term(d[6]), p.term(d[7])
    split = split_result(post)
    extraction = None if split is None else dict(
        definition=split[0], residual=split[1],
        definition_lexical=summary(split[0]), residual_lexical=summary(split[1]))
    return dict(name=identifier(d[3]), formals=formals,
                result_type=type_name(d[8]), reads=reads, writes=writes,
                binders=p.binders, pre=pre, post=post,
                pre_lexical=summary(pre), post_lexical=summary(post),
                normal_post_extraction=extraction,
                native_exceptional_posts=0)
