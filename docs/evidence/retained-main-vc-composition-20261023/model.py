"""Focused models of the new composition seams; never invoke native tools.

This is not a Silver/WhyML parser or complete VCgen implementation. The research
note gives the complete source constructor induction. These small executable
models check extraction, reflow, ordered context/clone attachment and the
weighted join, where an apparently harmless scalar replacement loses data.
"""
from dataclasses import dataclass, replace
from collections import Counter


@dataclass(frozen=True)
class Term:
    op: str
    args: tuple = ()
    key: str = ''
    ty: str = 'prop'
    attrs: tuple = ()


def var(key, ty='int'):
    return Term('var', key=key, ty=ty)


def app(key, *args, ty='prop', attrs=()):
    return Term('app', tuple(args), key, ty, attrs)


TRUE = Term('true')
FALSE = Term('false')
BTRUE = app('bool.True', ty='bool')
BFALSE = app('bool.False', ty='bool')
UNIT = app('unit.Tuple0', ty='unit')


def node(op, *args, key='', ty='prop', attrs=()):
    return Term(op, tuple(args), key, ty, attrs)


def free(t):
    if t.op == 'var':
        return {t.key}
    result = set().union(*(free(a) for a in t.args))
    if t.op in {'forall', 'exists', 'epsilon'}:
        result.discard(t.key)
    elif t.op == 'let':
        result = free(t.args[0]) | (free(t.args[1]) - {t.key})
    return result


def subst(t, mapping):
    """Checked substitution on the globally alpha-fresh fixture vocabulary."""
    if t.op == 'var':
        return mapping.get(t.key, t)
    if t.op == 'let':
        local = {k: v for k, v in mapping.items() if k != t.key}
        if any(t.key in free(v) for v in local.values()):
            raise ValueError('capture')
        return replace(t, args=(subst(t.args[0], mapping), subst(t.args[1], local)))
    if t.op in {'forall', 'exists', 'epsilon'}:
        local = {k: v for k, v in mapping.items() if k != t.key}
        if any(t.key in free(v) for v in local.values()):
            raise ValueError('capture')
        return replace(t, args=tuple(subst(a, local) for a in t.args))
    return replace(t, args=tuple(subst(a, mapping) for a in t.args))


def lexical(t, rho=None):
    rho = {} if rho is None else rho
    if t.op == 'var':
        return rho.get(t.key, 1)
    if t.op == 'let':
        a = lexical(t.args[0], rho)
        return 1 + a + lexical(t.args[1], rho | {t.key: a})
    if t.op in {'forall', 'exists', 'epsilon'}:
        rho = rho | {t.key: 1}
    return 1 + sum(lexical(a, rho) for a in t.args)


def affine(t):
    if t.op == 'var':
        return 0, Counter({t.key: 1})
    if t.op == 'let':
        ac, av = affine(t.args[0]); bc, bv = affine(t.args[1])
        bv = bv.copy(); uses = 1 + bv.pop(t.key, 0)
        return 1 + uses*ac + bc, bv + Counter({k: uses*v for k, v in av.items()})
    c, vs = 1, Counter()
    for a in t.args:
        ac, av = affine(a); c += ac; vs.update(av)
    if t.op in {'forall', 'exists', 'epsilon'}:
        c += vs.pop(t.key, 0)
    return c, vs


def pretty(t):
    if any(a.startswith('GP_Pretty_Ada') for a in t.attrs):
        return True
    # The native guard deliberately does not descend into application actuals.
    if t.op in {'var', 'const', 'app', 'true', 'false'}:
        return False
    if t.op in {'forall', 'exists'}:
        return pretty(t.args[0])  # native ignores quantifier triggers here
    return any(pretty(a) for a in t.args)


@dataclass(frozen=True)
class Symbol:
    key: str
    argtypes: tuple
    result: str
    attrs: tuple = ()
    projection: bool = False


@dataclass(frozen=True)
class Logic:
    symbol: str
    formals: tuple
    body: Term
    group_size: int = 1


@dataclass(frozen=True)
class Axiom:
    body: Term
    kind: str = 'axiom'


@dataclass(frozen=True)
class Use:
    module: str


def task_prefixes(units, modules):
    """Logical Task.flat_tdecl/split_theory projection; source-ordered prefixes.

    Only declarations relevant to the map fixture are represented. Uses are
    identity-qualified module references; modules form the accepted finite DAG.
    """
    prefix=[];goals=[];used=set();active=set()
    def add(unit, imported):
        if isinstance(unit,Use):
            key=unit.module
            if key in used:
                return
            if key in active:
                raise ValueError('cyclic module fixture')
            active.add(key)
            for child in modules[key]:
                add(child,True)
            active.remove(key);used.add(key)
        elif isinstance(unit,Axiom) and unit.kind in {'goal','lemma'}:
            if not imported:
                goals.append((tuple(prefix),unit.body))
            if unit.kind=='lemma':
                prefix.append(replace(unit,kind='axiom'))
        else:
            prefix.append(unit)
    for unit in units:
        add(unit,False)
    return goals,tuple(prefix),used


def marked_map(declarations, symbols):
    """Input is source-ordered; task_fold visits newest-to-oldest."""
    result = {}

    def insert(lhs, rhs):
        if lhs.op != 'app' or lhs.key not in symbols:
            return
        if 'GP_Inline' not in symbols[lhs.key].attrs or not pretty(rhs):
            return
        if any(a.op != 'var' for a in lhs.args):
            return
        result[lhs.key] = (tuple(a.key for a in lhs.args), rhs)

    for d in reversed(declarations):
        if isinstance(d, Logic):
            if d.group_size == 1 and 'GP_Inline' in symbols[d.symbol].attrs and pretty(d.body):
                result[d.symbol] = (d.formals, d.body)
        elif isinstance(d, Axiom) and d.kind == 'axiom':
            t = d.body
            if t.op != 'forall':
                continue
            while t.op == 'forall':
                t = t.args[0]
            if t.op == 'iff':
                lhs, rhs = t.args
                if lhs.op == 'app' and lhs.key == '=' and len(lhs.args) == 2:
                    a, b = lhs.args
                    if b.op == 'true' or (b.op == 'app' and b.key == 'bool.True' and not b.args):
                        insert(a, node('if', rhs, BTRUE, BFALSE, ty='bool'))
                    else:
                        insert(lhs, rhs)
                else:
                    insert(lhs, rhs)
            elif t.op == 'app' and t.key == '=' and len(t.args) == 2:
                insert(*t.args)
    return result


def alias_map(reached, symbols, known, destructible):
    """Exact case-free find_inlineable guard, with projection fast-path stop."""
    out = {}; pending = list(reached); seen = set()
    while pending:
        key = pending.pop()
        if key in seen:
            continue
        seen.add(key)
        s = symbols[key]
        if s.projection or len(s.argtypes) != 1 or s.argtypes[0] not in destructible:
            continue
        d = known.get(key)
        if d is None:
            continue
        t = d.body
        eligible = (t.op in {'var', 'const'} or
                    (t.op == 'app' and len(t.args) == 1 and t.args[0].op == 'var'))
        if eligible:
            if len(d.formals) != 1:
                raise ValueError('typed formal arity')
            if t.op == 'var' and t.key != d.formals[0]:
                raise ValueError('free variable in logic definition')
            if t.op == 'app' and t.args[0].key != d.formals[0]:
                raise ValueError('alias changes argument')
            out[key] = (d.formals, t)
            if t.op == 'app':
                pending.append(t.key)
    # This check diagnoses invalid fixture input, not native-success membership.
    def visit(k, active):
        if k in active:
            raise ValueError('alias cycle')
        d = out.get(k)
        if d and d[1].op == 'app':
            visit(d[1].key, active | {k})
    for key in out:
        visit(key, set())
    return out, seen


def rename_symbols(t, smap, tmap):
    return replace(t, key=smap.get(t.key, t.key) if t.op == 'app' else t.key,
                   ty=tmap.get(t.ty, t.ty),
                   args=tuple(rename_symbols(a, smap, tmap) for a in t.args))


def clone_records(symbols, declarations, prefix, symbol_subst=None, type_subst=None):
    """Logical slice: exact identity substitution, no body substitution.

    Substituted symbol declarations are skipped. This deliberately does not
    model the unrelated program-refinement/allocation parts of clone_pdecl.
    """
    symbol_subst = {} if symbol_subst is None else symbol_subst
    type_subst = {} if type_subst is None else type_subst
    smap = {s: symbol_subst.get(s, prefix+s) for s in symbols}
    out_symbols = {}
    for key, s in symbols.items():
        if key not in symbol_subst:
            out_symbols[smap[key]] = replace(s, key=smap[key],
                argtypes=tuple(type_subst.get(t, t) for t in s.argtypes),
                result=type_subst.get(s.result, s.result))
    def alpha(t, env, site):
        if t.op == 'var':
            return replace(t,key=env.get(t.key,t.key))
        if t.op == 'let':
            key=site+':'+t.key
            return replace(t,key=key,args=(alpha(t.args[0],env,site+'.0'),
                alpha(t.args[1],env | {t.key:key},site+'.1')))
        if t.op in {'forall','exists','epsilon'}:
            key=site+':'+t.key
            return replace(t,key=key,args=tuple(alpha(a,env | {t.key:key},site+'.'+str(i))
                for i,a in enumerate(t.args)))
        return replace(t,args=tuple(alpha(a,env,site+'.'+str(i)) for i,a in enumerate(t.args)))
    out = []
    for i,d in enumerate(declarations):
        site=prefix+str(i)
        if isinstance(d, Logic):
            if d.symbol in symbol_subst:
                continue
            fm={v:site+':formal:'+v for v in d.formals}
            out.append(replace(d, symbol=smap[d.symbol], formals=tuple(fm[v] for v in d.formals),
                body=alpha(rename_symbols(d.body,smap,type_subst),fm,site)))
        else:
            out.append(replace(d, body=alpha(rename_symbols(d.body,smap,type_subst),{},site)))
    return out_symbols, out, smap


def application_cost(key, weights, marked, rho=None):
    ordinary = 1 + sum(weights)
    if key not in marked:
        return ordinary
    formals, body = marked[key]
    if len(formals) != len(weights):
        raise ValueError('arity')
    # Native fold_left2 makes the last duplicate formal binding win.
    env = {} if rho is None else dict(rho)
    for key, weight in zip(formals, weights):
        env[key] = weight
    return max(ordinary, lexical(body, env))


def alias_cost(key, weight, marked, aliases, rho=None, active=frozenset()):
    if key in active:
        raise ValueError('alias cycle')
    out = application_cost(key, [weight], marked, rho)
    if key not in aliases:
        return out
    _, t = aliases[key]
    if t.op == 'var':
        return max(out, weight)
    if t.op == 'const':
        return max(out, 1)
    return max(out, alias_cost(t.key,weight,marked,aliases,rho,active | {key}))


def matcher(t, marked=None, aliases=None, rho=None, destructible=None, additive=frozenset()):
    marked = {} if marked is None else marked
    aliases = {} if aliases is None else aliases
    rho = {} if rho is None else rho
    destructible = {} if destructible is None else destructible
    rec = lambda a, r=rho: matcher(a, marked, aliases, r, destructible, additive)
    if t.op == 'var':
        return rho.get(t.key, 1)
    if t.op == 'let':
        d = rec(t.args[0])
        return 1 + d + rec(t.args[1], rho | {t.key: d})
    if t.op in {'forall', 'exists'}:
        # Fixtures use a single explicit binder. key/type carry its identity/type.
        ctor = destructible.get(t.ty)
        weight = 1 if ctor is None else application_cost(ctor[0], [1]*ctor[1], marked, rho)
        overhead = 0 if ctor is None else 1 + weight
        return 1 + overhead + sum(rec(a, rho | {t.key: weight}) for a in t.args)
    if t.op == 'epsilon':
        return 1 + sum(rec(a, rho | {t.key: 1}) for a in t.args)
    if t.op == 'app':
        ws = [rec(a) for a in t.args]
        if t.key == '=':
            if t.args[0].ty in additive:
                return application_cost('=', ws, marked, rho)
            return max(3, application_cost('=', [1,1], marked, rho))*ws[0]*ws[1]
        if len(ws) == 1:
            return alias_cost(t.key, ws[0], marked, aliases, rho)
        return application_cost(t.key, ws, marked, rho)
    return 1 + sum(rec(a) for a in t.args)


@dataclass(frozen=True)
class Kode:
    op: str
    args: tuple = ()
    key: object = None
    terms: tuple = ()


def k(op, *args, key=None, terms=()):
    return Kode(op, tuple(args), key, terms)


def ksize(code):
    return 1 + sum(ksize(a) for a in code.args)


def attached(code):
    out = Counter(code.terms)
    for a in code.args:
        out.update(attached(a))
    return out


def term_of_kode(code, result, unit_keys=frozenset()):
    """vc:511-547 with lexical lets retained instead of optional simplification."""
    def stack(st, code):
        if code.op == 'let':
            if code.key == result:
                return st, code.terms, 0, k('cont',key=0)
            return [(code.key,code.terms[0])]+st, None, 0, code
        if code.op == 'val':
            for v in code.key:
                st = [(v, UNIT if v in unit_keys else None)]+st
            return st, None, 0, code
        if code.op in {'cut','axiom'}:
            return st, None, 0, code
        if code.op == 'cont':
            return st, None, code.key, code
        if code.op == 'seq':
            st,d,j,a = stack(st,code.args[0])
            if code.key != j:
                return st,d,j,replace(code,args=(a,code.args[1]))
            if d is not None:
                raise ValueError('result before matching continuation')
            st,d,j,b = stack(st,code.args[1])
            return st,d,j,replace(code,args=(a,b))
        if code.op == 'tag':
            st,d,j,b = stack(st,code.args[0])
            return st,d,j,replace(code,args=(b,))
        if code.op == 'par' and code.args[0].op == 'stop':
            st,d,j,b = stack(st,code.args[1])
            return st,d,j,replace(code,args=(code.args[0],b))
        raise ValueError('nonlinear extraction')
    st,d,j,residual = stack([],code)
    if j != 0 or d is None:
        raise ValueError('no normal result')
    def unwind(t):
        for v,defn in st:
            if defn is None:
                if v in free(t):
                    raise ValueError('used unknown definition')
            else:
                t = node('let',defn,t,key=v,ty=t.ty)
        return t
    value,predicate = d
    return unwind(value), unwind(predicate) if free(predicate) else predicate, residual


def reflow(code, vc_wp=True):
    """The case-free mark/push rows, retaining actual terms and outcome maps."""
    def join(a,b):
        return a | b | {i:False for i in a.keys() & b.keys()}
    def mark(mode,code):
        op=code.op
        if op == 'seq':
            a,b=code.args
            if a.op in {'havoc','let','val','cut'} and code.key == 0:
                b,ob=mark(mode,b)
                return replace(code,args=(a,b)),ob
            a,oa=mark(mode,a)
            if code.key not in oa:
                return a,oa
            b,ob=mark(mode,b)
            if oa[code.key]:
                b=k('tag',b,key=('push',0 not in ob))
            return replace(code,args=(a,b)),join({i:v for i,v in oa.items() if i!=code.key},ob)
        if op in {'par','if'}:
            a,oa=mark(mode,code.args[0]);b,ob=mark(mode,code.args[1])
            return replace(code,args=(a,b)),join(oa,ob)
        if op in {'havoc','let','val','cut'}:
            return code,{0:True}
        if op == 'stop':
            return code,{}
        if op == 'cont':
            return code,{code.key:True}
        if op == 'axiom':
            a,_=mark('wp',code.args[0]);return replace(code,args=(a,)),{0:True}
        if op == 'tag':
            tag=code.key
            if tag[0] == 'off':
                a,oa=mark(mode,code.args[0]);return replace(code,args=(a,)),oa
            if tag[0] in {'wp','sp'}:
                if tag[0] == mode:
                    return mark(mode,code.args[0])
                a,oa=mark(tag[0],code.args[0])
                if tag[0] == 'wp' and oa:
                    raise ValueError('open SP-to-WP switch')
                return k('tag',k('tag',a,key=tag),key=('out',tuple(sorted(oa)))),dict.fromkeys(oa,False)
        raise ValueError('uncovered mark constructor '+op)
    def push(code,q):
        op=code.op
        if op == 'seq':
            a,b=code.args;i=code.key
            if b.op == 'tag' and b.key[0] == 'push':
                closed=b.key[1] or (0 in q and q[0][1])
                n=q | {i:(push(b.args[0],q),closed)}
                r=push(a,n)
                return r if i==0 or closed else k('seq',r,k('cont',key=0),key=i)
            return replace(code,args=(push(a,{j:v for j,v in q.items() if j!=i}),push(b,q)))
        if op in {'par','if'}:
            return replace(code,args=tuple(push(a,q) for a in code.args))
        if op in {'havoc','let','val','cut'}:
            return k('seq',code,q[0][0],key=0) if 0 in q else code
        if op == 'stop':
            return code
        if op == 'cont':
            if code.key not in q:
                return code
            cont,closed=q[code.key]
            return cont if code.key==0 or closed else k('seq',cont,code,key=0)
        if op == 'axiom':
            r=replace(code,args=(push(code.args[0],{}),))
            return k('seq',r,q[0][0],key=0) if 0 in q else r
        if op == 'tag':
            if code.key[0] == 'push':
                raise ValueError('unremoved push')
            return replace(code,args=(push(code.args[0],q if code.key[0]=='off' else {}),))
        raise ValueError('uncovered push constructor '+op)
    if not vc_wp:
        code=k('tag',code,key=('sp',))
    return push(mark('wp',code)[0],{})


def wp_core(code, q):
    """Structural pure WP seam; unsimplified constructors, no SP/havoc claim."""
    if code.op == 'seq':
        return wp_core(code.args[0],q | {code.key:wp_core(code.args[1],q)})
    if code.op == 'par':
        return node('and',*(wp_core(a,q) for a in code.args))
    if code.op == 'if':
        return node('if',app('=',var(code.key,'bool'),BTRUE),*(wp_core(a,q) for a in code.args))
    if code.op == 'stop':
        return code.terms[0]
    if code.op == 'cont':
        return q[code.key]
    if code.op == 'cut':
        return node('and',code.terms[0],q[0])
    if code.op == 'let':
        return node('let',code.terms[0],node('implies',code.terms[1],q[0]),key=code.key)
    if code.op == 'val':
        out=node('implies',code.terms[0],q[0])
        for v in reversed(code.key):
            out=node('forall',out,key=v)
        return out
    if code.op == 'axiom':
        return node('implies',wp_core(code.args[0],{}),q[0])
    raise ValueError('outside focused pure WP model: '+code.op)


def range_definition(key, dynamic=False, boolean=False):
    x=var(key+':x')
    lo=var(key+':first') if dynamic else app(key+':first',ty='int')
    hi=var(key+':last') if dynamic else app(key+':last',ty='int')
    body=node('and',app('<=',lo,x,attrs=('GP_Pretty_Ada:low',)),
              app('<=',x,hi,attrs=('GP_Pretty_Ada:high',)))
    formals=(lo.key,hi.key,x.key) if dynamic else (x.key,)
    if boolean:
        body=node('if',body,BTRUE,BFALSE,ty='bool')
    return Logic(key,formals,body)
