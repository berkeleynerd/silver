#!/usr/bin/env python3
"""New stored-support and type-instantiation checks; no native execution."""
from collections import Counter
from dataclasses import replace
import hashlib
import json
from pathlib import Path
import platform
import random
import sys
import tarfile
import time

sys.dont_write_bytecode = True
import bridge as b
k = b.k
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
CHECKS = Counter()


def check(ok, family):
    if not ok:
        raise AssertionError(family)
    CHECKS[family] += 1


def reject(fn, family):
    try:
        fn()
    except ValueError:
        check(True, family)
    else:
        raise AssertionError(family)


def identities():
    manifest = json.loads((HERE/'identity.json').read_text())
    sha = lambda x: hashlib.sha256(x).hexdigest()
    for row in manifest['providers']:
        check(sha((ROOT/row['path']).read_bytes()) == row['sha256'], 'provider identity')
    archive = manifest['archive']
    path = ROOT/archive['path']
    check(sha(path.read_bytes()) == archive['sha256'], 'retained archive identity')
    with tarfile.open(path) as tar:
        for row in archive['files']:
            data = tar.extractfile(row['path']).read()
            check(sha(data) == row['sha256'], 'complete retained source identity')
            lines = data.decode().splitlines()
            for span in row['spans']:
                s = '\n'.join(lines[span['first']-1:span['last']])+'\n'
                check(sha(s.encode()) == span['sha256'], 'source span identity')
                for anchor in span['anchors']:
                    check(anchor in s, 'source branch anchor')


def semantics(t, frames=()):
    """Interpret saved images outside their own binder, preserving types."""
    if t.op == 'var':
        for i, (bound, saved) in enumerate(frames):
            if t.variable in bound:
                return ('bound', bound[t.variable], t.variable.ty)
            if t.variable in saved:
                return semantics(saved[t.variable], frames[i+1:])
        return ('free', t.variable.tag, t.variable.ty)
    if t.binding is not None:
        bb = t.binding
        tokens = tuple(object() for _ in bb.variables)
        inner = ((dict(zip(bb.variables, tokens)), bb.saved),) + frames
        return (t.op, tokens, tuple(v.ty for v in bb.variables),
                tuple(semantics(x, frames) for x in t.args),
                tuple(tuple(semantics(x, inner) for x in g) for g in bb.triggers),
                semantics(bb.body, inner))
    return ('node', t.op, t.ty, t.symbol, tuple(semantics(x, frames) for x in t.args))


def canonical(t, scope=()):
    if t[0] == 'bound':
        return ('bound', scope.index(t[1]), t[2])
    if t[0] == 'free':
        return t
    if t[0] == 'node':
        return t[:4]+(tuple(canonical(x, scope) for x in t[4]),)
    op, tokens, tys, args, triggers, body = t
    inner = tokens + scope
    return (op, tys, tuple(canonical(x, scope) for x in args),
            tuple(tuple(canonical(x, inner) for x in g) for g in triggers), canonical(body, inner))


def eager_types(ty, mapping):
    if ty is None:
        return None
    if ty.variable:
        return mapping.get(ty.symbol, ty)
    return b.Ty(ty.symbol, tuple(eager_types(x, mapping) for x in ty.args))


def eager(t, tm, vm):
    if t[0] == 'free':
        return semantics(vm[t[1]]) if t[1] in vm else (t[0], t[1], eager_types(t[2], tm))
    if t[0] == 'bound':
        return (t[0], t[1], eager_types(t[2], tm))
    if t[0] == 'node':
        return (t[0], t[1], eager_types(t[2], tm), t[3], tuple(eager(x, tm, vm) for x in t[4]))
    op, tokens, tys, args, triggers, body = t
    return (op, tokens, tuple(eager_types(x, tm) for x in tys),
            tuple(eager(x, tm, vm) for x in args),
            tuple(tuple(eager(x, tm, vm) for x in g) for g in triggers), eager(body, tm, vm))


def positive(t):
    children, binders = b.parts(t)
    for bb in binders:
        if any(n <= 0 for n in bb.free.values()):
            return False
        children += (bb.body,) + tuple(x for g in bb.triggers for x in g) + tuple(bb.saved.values())
    return all(positive(x) for x in children)


def generated_diagrams():
    rnd = random.Random(20261024)
    a = b.Ty('a', variable=True)
    target = b.Ty('pair', (b.Ty('int'), b.Ty('bool')))
    variables = [k.Var(i, a) for i in range(1, 51)]
    next_bound = 100

    def value(depth, scope, out):
        nonlocal next_bound
        if depth == 0:
            return k.var(rnd.choice(scope))
        n = rnd.randrange(4)
        if n == 0:
            return k.node('app', value(depth-1, scope, out), ty=a, symbol='f')
        if n == 1:
            return k.node('if', formula(depth-1, scope, out), value(depth-1, scope, out), value(depth-1, scope, out), ty=a)
        next_bound += 1
        v = k.Var(next_bound, a)
        if n == 2:
            return k.close('let', (v,), value(depth-1, scope+[v], out), out,
                           value=value(depth-1, scope, out))
        return k.close('eps', (v,), formula(depth-1, scope+[v], out), out)

    def formula(depth, scope, out):
        nonlocal next_bound
        if depth == 0:
            return k.node('app', k.var(rnd.choice(scope)), symbol='P')
        n = rnd.randrange(4)
        if n == 0:
            return k.node('and', formula(depth-1, scope, out), formula(depth-1, scope, out))
        if n == 1:
            return k.node('app', value(depth-1, scope, out), symbol='P')
        next_bound += 1
        v = k.Var(next_bound, a)
        trigger = ((k.node('app', k.var(v), k.var(scope[0]), ty=a, symbol='g'),),)
        return k.close('forall' if n == 2 else 'exists', (v,), formula(depth-1, scope+[v], out), out, triggers=trigger)

    totals = Counter()
    for j in range(100):
        out = k.Ledger(300000)
        t = formula(3, variables[:8], out)
        check(b.stored_closed(t) and positive(t), 'constructor support and positive caches')
        for stage in range(3):
            fv = list(k.t_vars(t, out))
            mapping = {v: (k.var(variables[8+stage]) if rnd.randrange(2) else
                          k.node('app', k.var(variables[9+stage]), ty=a, symbol='h'))
                       for v in fv[::2]}
            t = k.subst(mapping, t, out)
            check(b.stored_closed(t) and positive(t), 'substitution preserves stored support')
        fv = list(k.t_vars(t, out))
        actual = {v: k.var(k.Var(200000+i, target)) for i, v in enumerate(fv)}
        demand = b.Demand(out)
        before = b.profile(t)
        result = b.ty_subst({'a': target}, actual, t, demand)
        check(b.stored_closed(result) and positive(result), 'instantiation preserves stored support')
        check(canonical(semantics(result)) == canonical(eager(semantics(t), {'a': target}, {v.tag:x for v,x in actual.items()})),
              'stored instantiation commutes with eager interpretation')
        check(demand.calls['t_gen_map_visit'] == before['term'], 'visits every stored term occurrence')
        check(demand.calls['gen_fresh_attempt'] == len(fv)+before['slots']+before['saved_keys'], 'freshening attempt recurrence')
        check(len(demand.saved_image_inputs) == before['saved_keys'], 'every saved image mapped')
        check(demand.ephemeron_tables == 1 and demand.ephemeron_sets_upper == demand.ephemeron_lookups,
              'per-root memo table and all-miss demand')
        totals.update(term_visits=demand.calls['t_gen_map_visit'], saved_images=len(demand.saved_image_inputs),
                      fresh_attempts=demand.calls['gen_fresh_attempt'], hsty_requests_upper=demand.hsty_requests_upper)
    return totals


def edge_diagrams():
    a = b.Ty('a', variable=True)
    it = b.Ty('int')
    x, v = k.Var(1, a), k.Var(2, a)
    out = k.Ledger(1000)
    t = k.close('forall', (v,), k.node('app', k.var(x), k.var(v), symbol='R'), out)
    t = k.subst({x:k.var(v)}, t, out)
    check(v in t.binding.free and v in t.binding.variables, 'saved-image variable can share bound identity')
    demand = b.Demand(out)
    actual = {v:k.var(k.Var(200, it))}
    mapped = b.ty_subst({'a':it}, actual, t, demand)
    check(canonical(semantics(mapped)) == canonical(eager(semantics(t), {'a':it}, {v.tag:actual[v]})), 'capture-sensitive outer-map semantics')
    check(b.stored_closed(mapped), 'capture-sensitive support preservation')
    invalid = replace(t, binding=replace(t.binding, free={}))
    reject(lambda: b.ty_subst({'a':it}, {}, invalid, b.Demand(k.Ledger(500))), 'reject hidden free variable in saved image')
    zero = replace(t, binding=replace(t.binding, free={v:0}))
    reject(lambda: b.ty_subst({'a':it}, {}, zero, b.Demand(k.Ledger(500))), 'reject zero occurrence coefficient')
    reject(lambda: b.ty_subst({}, {v:invalid}, t, b.Demand(k.Ledger(500))), 'reject unsupported image support')

    # Pvar/Pwild/Papp/Por/Pas and Tcase are preserved by generic mapping.
    # The composed substitution still refuses this separate context domain.
    pvar = b.Pattern('var', a, variable=v)
    por = b.Pattern('or', a, (pvar, pvar))
    w = k.Var(3, a)
    pattern = b.Pattern('as', a, (b.Pattern('app', a, (por, b.Pattern('wild', a)), symbol='C'),), variable=w)
    body = k.node('app', k.var(x), k.var(v), k.var(w), ty=a, symbol='g')
    bb = k.Binding((v,w), body, (), {x:1}, {})
    case = b.Case(k.var(x), ((pattern,bb),), a)
    d = b.Demand(k.Ledger(500))
    x2 = k.Var(250, it)
    result = b.gen_map(case, {x:x2}, lambda ty:d.type_inst({'a':it},ty,True), lambda ls:ls, d)
    check(b.profile(case) == b.profile(result), 'case and pattern stored shape preserved')
    check(d.calls['pat_gen_map_visit'] == 6, 'all five pattern forms visited')
    check(b.stored_closed(result), 'case branch support preservation')
    reject(lambda:b.ty_subst({'a':it},{},case,d), 'case substitution domain remains explicit')
    reject(lambda:b.ty_subst({'a':it},{x:case},t,d), 'case in actual image remains outside kernel')
    empty_case = b.Case(k.var(x), (), a)
    reject(lambda:b.gen_map(empty_case,{x:x2},lambda ty:it,lambda ls:ls,d), 'reject empty case')

    y = k.Var(4,a)
    collapse = k.close('forall',(v,),k.node('app',k.var(x),k.var(y),symbol='R'),d.kernel)
    reject(lambda:b.gen_map(collapse,{x:x2,y:x2},lambda ty:it,lambda ls:ls,d), 'reject noninjective cache renaming')

    # ty_inst substitutes a Tyvar image once; it does not recursively
    # instantiate variables inside that image. A Tyapp input does recurse
    # through its old arguments and requests hash-consing even if unchanged.
    nested = b.Ty('box', (a,))
    nd = b.Demand(k.Ledger(700))
    image = b.Ty('pair', (a,it))
    check(nd.type_inst({'a':image}, nested) == b.Ty('box',(image,)), 'type images are not recursively substituted')
    check(nd.hsty_requests_upper == 1, 'one Hsty request for old Tyapp node')
    old = k.Var(600, nested)
    repeated = k.node('app', k.var(old), k.var(old), ty=nested, symbol='boxfun')
    actual_box = k.var(k.Var(650,b.Ty('box',(it,))))
    out_box = b.ty_subst({'a':it},{old:actual_box},repeated,nd)
    check(out_box.ty == b.Ty('box',(it,)), 'nested type attached to mapped term')
    check(nd.hsty_requests_upper == 5, 'uncached callback request bound includes repeated old type')
    check(nd.ephemeron_lookups == 3, 'generic wrapper covers repeated term type callbacks')

    # Both branches share the same incoming owner; each nontrivial spec root
    # gets its own generic-map cache, while the identity-type branch gets none.
    ctyd = b.Demand(k.Ledger(1000))
    post = k.close('eps', (v,), k.node('app', k.var(x),k.var(v),symbol='R'), ctyd.kernel)
    b.cty_specs((t,), (post,), {'E':(post,)}, {'a':it}, {x:k.var(x2), v:k.var(x2)}, False, ctyd)
    check(ctyd.calls['cty_spec_root'] == 3 and ctyd.ephemeron_tables == 3, 'cty all pre post xpost roots')
    previous = ctyd.kernel.ident_increments
    identity = b.Demand(ctyd.kernel)
    b.cty_specs((t,), (post,), {}, {}, {x:k.var(v)}, True, identity)
    check(identity.ephemeron_tables == 0 and ctyd.kernel.ident_increments == previous, 'same-type cty bypasses generic mapper')
    return dict(capture_ident_increments=out.ident_increments, cty_ident_increments=ctyd.kernel.ident_increments)


def clone_premise_diagrams():
    """#211: preserve the native counterexample and reject the proof entry."""
    it = b.Ty('int')
    x, v, z = (k.Var(i,it) for i in (1,2,3))
    d = b.Demand(k.Ledger(100))
    t = k.close('forall',(v,),k.node('app',k.var(x),k.var(v),symbol='R'),d.kernel)
    raw = b._gen_map(t,{x:v},lambda ty:ty,lambda ls:ls,d)
    opened = canonical(semantics(raw))
    check(opened[-1][-1][0][0] == 'bound' and opened[-1][-1][1][0] == 'bound',
          'raw native mapper captures with injective incompatible map')
    check(b.stored_closed(raw) and raw.binding.free == {v:1},
          'saved support alone cannot establish cache correctness')
    reject(lambda:b.gen_map(t,{x:v},lambda ty:ty,lambda ls:ls,d),
           'proof wrapper rejects reviewer capture counterexample')
    reject(lambda:b.gen_map(t,{},lambda ty:ty,lambda ls:ls,d),
           'proof wrapper requires cached support coverage')
    good = b.gen_map(t,{x:z},lambda ty:ty,lambda ls:ls,d)
    check(canonical(semantics(good)) == canonical(eager(semantics(t),{}, {x.tag:k.var(z)})),
          'fresh external clone target preserves free and bound roles')
    check(good.binding.variables == (v,) and good.binding.free == {z:1},
          'repair retains native unchanged bound variable')

    # Freshly added formals do not repair an incompatible inherited entry.
    formal = k.Var(4,it)
    fresh_formal = k.Var(5,it)
    inherited = {x:v}
    extended = inherited | {formal:fresh_formal}
    reject(lambda:b.gen_map(t,extended,lambda ty:ty,lambda ls:ls,d),
           'fresh formals do not sanitize inherited clone-map capture')

    # Check the source graph, not just currently visible binders: a saved
    # image has a local binder whose identity must also be protected.
    hidden = k.close('eps',(v,),k.node('app',k.var(v),symbol='P'),d.kernel)
    saved = k.close('forall',(formal,),k.node('app',k.var(x),symbol='P'),d.kernel)
    saved = k.subst({x:hidden},saved,d.kernel)
    check(v in b.stored_variables(saved) and not k.t_vars(saved,d.kernel),
          'capture premise inspects identities in saved images')
    reject(lambda:b.gen_map(saved,{z:v},lambda ty:ty,lambda ls:ls,d),
           'proof wrapper protects saved-image binder identities')
    return {'raw_counterexample_preserved':True,'proof_entry_rejects_capture':True,
            'actual_inherited_clone_map_attachment':'conditional; not discharged'}


def main():
    started = time.monotonic()
    identities()
    totals = generated_diagrams()
    edges = edge_diagrams()
    clone_premises = clone_premise_diagrams()
    result = dict(status='pass', assertions=sum(CHECKS.values()), families=dict(CHECKS),
                  generated_diagrams=100, aggregate_new_diagram_demand=dict(totals), edges=edges,
                  clone_premise_repair=clone_premises,
                  elapsed_seconds=time.monotonic()-started, host=platform.platform(),
                  native_runs=0, predecessor_checker_replays=0, complete_source_to_vc_storage=False)
    (HERE/'result.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(result,indent=2))


if __name__ == '__main__':
    main()
