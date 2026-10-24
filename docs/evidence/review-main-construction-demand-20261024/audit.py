#!/usr/bin/env python3
"""Independent finite audit of the repaired construction-demand bridge.

No author/predecessor checker entry point is imported or replayed. The source
argument in the report supplies the universal scope; this is finite evidence.
"""
from collections import Counter
from dataclasses import replace
import hashlib
import importlib.util
import json
from pathlib import Path
import platform
import random
import subprocess
import sys
import tarfile
import time

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
AUTHOR = ROOT / 'docs/evidence/retained-main-construction-demand-20261024'
FREEZE = '3f4f6143c206518bf257d3d9b63cee2a08d14bcd'
spec = importlib.util.spec_from_file_location('reviewed_bridge', AUTHOR/'bridge.py')
b = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = b
spec.loader.exec_module(b)
k = b.k
CHECKS = Counter()


def check(condition, family):
    assert condition, family
    CHECKS[family] += 1


def rejects(fn, family):
    try:
        fn()
    except ValueError:
        check(True, family)
    else:
        raise AssertionError(family)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def frozen_inputs():
    files = sorted(AUTHOR.iterdir()) + [ROOT/'docs/research/retained-main-construction-demand.md']
    result = {}
    for path in files:
        if not path.is_file():
            continue
        rel = str(path.relative_to(ROOT))
        expected = subprocess.check_output(['git', 'show', FREEZE+':'+rel], cwd=ROOT)
        check(path.read_bytes() == expected, 'exact repaired freeze input')
        result[rel] = sha(expected)
    manifest = json.loads((AUTHOR/'identity.json').read_text())
    for row in manifest['providers']:
        check(sha((ROOT/row['path']).read_bytes()) == row['sha256'], 'provider identity')
    archive = manifest['archive']
    check(sha((ROOT/archive['path']).read_bytes()) == archive['sha256'], 'archive identity')
    with tarfile.open(ROOT/archive['path']) as tar:
        for row in archive['files']:
            data = tar.extractfile(row['path']).read()
            check(sha(data) == row['sha256'], 'complete source identity')
            lines = data.decode().splitlines()
            for span in row['spans']:
                text = '\n'.join(lines[span['first']-1:span['last']])+'\n'
                check(sha(text.encode()) == span['sha256'], 'source span identity')
                for anchor in span['anchors']:
                    check(anchor in text, 'source anchor')
    return result


def type_image(ty, tm):
    if ty is None:
        return None
    if ty.variable:
        return tm.get(ty.symbol, ty)
    return b.Ty(ty.symbol, tuple(type_image(x, tm) for x in ty.args))


def old_apps(ty):
    return 0 if ty.variable else 1 + sum(old_apps(x) for x in ty.args)


def cached(t):
    if isinstance(t, b.Case):
        c = cached(t.subject)
        for _, bb in t.branches:
            c.update(bb.free)
        return c
    if t.op == 'var':
        return Counter({t.variable: 1})
    c = Counter()
    for a in t.args:
        c.update(cached(a))
    if t.binding is not None:
        c.update(t.binding.free)
    return c


def census(t, include_free=True):
    count = Counter()
    callbacks = []
    fresh_types = []
    if include_free:
        fresh_types.extend(v.ty for v in cached(t))
        callbacks.extend(fresh_types)

    def pattern(p):
        count['pattern'] += 1
        callbacks.append(p.ty)
        variables = set() if p.variable is None else {p.variable}
        for child in p.children:
            variables.update(pattern(child))
        return variables

    def binding(bb, slots):
        count['saved'] += len(bb.saved)
        vs = tuple(bb.saved) + tuple(slots)
        fresh_types.extend(v.ty for v in vs)
        callbacks.extend(v.ty for v in vs)
        for image in bb.saved.values():
            walk(image)
        for group in bb.triggers:
            for trigger in group:
                walk(trigger)
        walk(bb.body)

    def walk(node):
        count['term'] += 1
        if isinstance(node, b.Case):
            walk(node.subject)
            for pat, bb in node.branches:
                binding(bb, pattern(pat))
            return
        if node.op == 'var':
            callbacks.append(node.variable.ty)
        elif node.op == 'const' or node.op == 'app' and node.ty is not None:
            callbacks.append(node.ty)
        for a in node.args:
            walk(a)
        if node.binding is not None:
            binding(node.binding, node.binding.variables)

    walk(t)
    return count, callbacks, fresh_types


def observe(t, tm=None, replacements=None, env=None, depth=0):
    """Eager environment semantics; saved closures capture the outer env.

    Bound identities become lexical depth/slot pairs, independent of freshly
    allocated native tags. Replacement terms are observed without retyping.
    """
    tm = {} if tm is None else tm
    replacements = {} if replacements is None else replacements
    env = {} if env is None else env
    if t.op == 'var':
        v = t.variable
        if v in env:
            item = env[v]
            if item[0] == 'bound':
                return item
            _, image, outer = item
            return observe(image, tm, replacements, outer, depth)
        if v in replacements:
            return observe(replacements[v], depth=depth)
        return ('free', v.tag, type_image(v.ty, tm))
    args = tuple(observe(a, tm, replacements, env, depth) for a in t.args)
    if t.binding is None:
        return (t.op, type_image(t.ty, tm), t.symbol, args)
    bb = t.binding
    inner = dict(env)
    for v, image in bb.saved.items():
        inner[v] = ('saved', image, env)
    for i, v in enumerate(bb.variables):
        inner[v] = ('bound', depth, i, type_image(v.ty, tm))
    triggers = tuple(tuple(observe(q, tm, replacements, inner, depth+1) for q in group) for group in bb.triggers)
    return (t.op, tuple(type_image(v.ty, tm) for v in bb.variables), args, triggers,
            observe(bb.body, tm, replacements, inner, depth+1))


def verify_demand(t, tm, d, include_free=True):
    count, callbacks, fresh_types = census(t, include_free)
    f = len(cached(t)) if include_free else 0
    check(d.calls['t_gen_map_visit'] == count['term'], 'stored occurrence recurrence')
    check(d.calls['pat_gen_map_visit'] == count['pattern'], 'pattern occurrence recurrence')
    check(d.calls['gen_fresh_attempt'] == len(fresh_types), 'fresh attempt recurrence')
    check(d.kernel.ident_increments == sum(type_image(ty, tm) != ty for ty in fresh_types), 'exact changed-type Ident increments')
    check(d.calls['fnT'] == len(callbacks), 'outer type callback recurrence')
    check(d.ephemeron_lookups == len(callbacks)-f, 'memoized versus pre-wrapper callbacks')
    check(d.hsty_requests_upper == sum(old_apps(ty) for ty in callbacks), 'old Tyapp all-miss Hsty demand')
    check(len(d.saved_image_inputs) == count['saved'], 'every saved image visited')


def diagrams():
    rnd = random.Random(21120261024)
    a = b.Ty('a', variable=True)
    integer = b.Ty('int')
    types = [a, b.Ty('box', (a,)), integer]
    totals = Counter()
    for n in range(120):
        ty = types[n % len(types)]
        vs = [k.Var(i, ty) for i in range(1, 15)]
        x, bound, other, z = vs[:4]
        setup = k.Ledger(1000)
        leaf = k.node('app', k.var(x), k.var(bound), symbol='R')
        trigger = k.node('app', k.var(bound), k.var(other), ty=ty, symbol='f')
        t = k.close('forall' if n % 2 else 'exists', (bound,), leaf, setup, triggers=((trigger,),))
        # Create an intentional bound/free same-identity image and a growing
        # history containing dead saved keys. Some images have inner binders.
        t = k.subst({x:k.var(bound)}, t, setup)
        for stage in range(1 + n % 5):
            free = list(cached(t))
            if not free:
                break
            key = rnd.choice(free)
            value = k.var(vs[5+stage])
            if stage % 2:
                value = k.close('let', (z,), k.node('app', k.var(z), value, ty=ty, symbol='g'), setup, value=k.var(other))
            t = k.subst({key:value}, t, setup)
        if n % 3 == 0:
            eps = k.close('eps', (z,), k.node('app', k.var(z), k.var(other), symbol='P'), setup)
            t = k.node('if', k.node('not', k.node('false')), t,
                       k.node('and', k.node('app', eps, symbol='Q'), k.node('true')))
        # Real constants have resolved concrete types; they exercise the
        # constant callback without inventing polymorphic native literals.
        if n % 4 == 0:
            t = k.node('or', t, k.node('app', k.node('const', ty=integer), symbol='C'))
        tm = {} if n % 7 == 0 else {'a': integer}
        actual = {v:k.var(k.Var(500+i, type_image(v.ty, tm))) for i, v in enumerate(cached(t))}
        d = b.Demand(k.Ledger(10000))
        result = b.ty_subst(tm, actual, t, d)
        verify_demand(t, tm, d)
        check(observe(result) == observe(t, tm, actual), 'eager stored-image/type semantics')
        check(b.stored_closed(result), 'saved-support preservation')
        check(d.ephemeron_tables == 1, 'one table per type-substitution root')
        totals.update(terms=d.calls['t_gen_map_visit'], saved=len(d.saved_image_inputs), fresh=d.calls['gen_fresh_attempt'])
    return totals


def focused():
    it, a = b.Ty('int'), b.Ty('a', variable=True)
    x, v, z = [k.Var(i, it) for i in (1, 2, 3)]
    setup = k.Ledger(100)
    t = k.close('forall', (v,), k.node('app', k.var(x), k.var(v), symbol='R'), setup)
    raw = b._gen_map(t, {x:v}, lambda ty:ty, lambda s:s, b.Demand(k.Ledger(100)))
    check(observe(raw)[-1][-1][0] == observe(raw)[-1][-1][1], 'native capture counterexample retained')
    check(b.stored_closed(raw) and raw.binding.free == {v:1}, 'support alone does not imply cache correctness')
    for mapping, label in [({x:v}, 'capture rejected'), ({}, 'missing support rejected'),
                           ({x:z,v:z}, 'noninjective map rejected'),
                           ({x:v,k.Var(9,it):k.Var(10,it)}, 'inherited capture survives fresh formal')]:
        d = b.Demand(k.Ledger(100))
        rejects(lambda:b.gen_map(t,mapping,lambda ty:d.type_inst({},ty,True),lambda s:s,d), label)
        check(not d.calls and d.kernel.ident_increments == 0, 'proof premise check has no native demand')
    d = b.Demand(k.Ledger(100))
    mapped = b.gen_map(t, {x:z}, lambda ty:d.type_inst({},ty,True), lambda s:s, d)
    check(observe(mapped) == observe(t, replacements={x:k.var(z)}), 'fresh external mapping is capture compatible')
    check(mapped.binding.variables == (v,), 'native unchanged binder retained')
    verify_demand(t, {}, d, False)

    # Pattern set counts deduplicate the two occurrences in an or-pattern.
    x, v, z, w = [k.Var(i, a) for i in (1,2,3,4)]
    p = b.Pattern('as', a, (b.Pattern('app', a, (
        b.Pattern('or', a, (b.Pattern('var', a, variable=v), b.Pattern('var', a, variable=v))),
        b.Pattern('wild', a)), symbol='Ctor'),), variable=z)
    body = k.node('app', k.var(v), k.var(z), k.var(x), ty=a, symbol='f')
    branch = k.Binding((v,z), body, (), {w:1}, {x:k.var(w)})
    case = b.Case(k.var(w), ((p,branch),), a)
    d = b.Demand(k.Ledger(100))
    mapped = b.gen_map(case, {w:k.Var(20,it)}, lambda ty:d.type_inst({'a':it},ty,True), lambda s:s, d)
    verify_demand(case, {'a':it}, d, False)
    check(census(case,False)[0] == census(mapped,False)[0], 'case and all pattern shapes preserved')
    check(b.stored_closed(mapped), 'case saved-image support preserved')
    check(d.saved_image_inputs[0][2] == {w:k.Var(20,it)}, 'case image uses original outer map')
    rejects(lambda:b.ty_subst({'a':it},{},case,b.Demand(k.Ledger(100))), 'case remains outside composed substitution domain')

    # Three lists, multiple roots and a shared owner; each root has its own
    # ephemeral table. Ordinary substitution creates no fresh identifiers.
    p = k.close('eps',(v,),k.node('app',k.var(v),k.var(w),symbol='P'),setup)
    roots = (p,p,p,p,p)
    d = b.Demand(k.Ledger(100))
    b.cty_specs(roots[:2],roots[2:3],{'E':roots[3:]},{'a':it},{w:k.var(k.Var(20,it))},False,d)
    check(d.ephemeron_tables == 5 and d.calls['cty_spec_root'] == 5, 'cty pre/post/xpost root multiplicity')
    check(d.kernel.ident_increments == 10, 'cty roots transport one Ident owner')
    same = b.Demand(d.kernel)
    before = d.kernel.ident_increments
    b.cty_specs(roots[:2],roots[2:3],{'E':roots[3:]},{},{w:k.var(z)},True,same)
    check(same.ephemeron_tables == 0 and same.kernel.ident_increments == before, 'same-type cty avoids generic demand')


def main():
    started = time.monotonic()
    inputs = frozen_inputs()
    totals = diagrams()
    focused()
    check(all(sha((ROOT/p).read_bytes()) == digest for p,digest in inputs.items()), 'author inputs unchanged after audit')
    result = dict(status='pass', reviewed_commit=FREEZE, assertions=sum(CHECKS.values()),
                  families=dict(CHECKS), constructive_diagrams=120, aggregate_demand=dict(totals),
                  elapsed_seconds=time.monotonic()-started, host=platform.platform(),
                  author_or_predecessor_checker_replays=0, native_runs=0,
                  machine_checked_universal_proof=False, actual_clone_map_attachment=False,
                  complete_source_to_vc_storage=False, inputs=inputs)
    (HERE/'audit-result.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({key:value for key,value in result.items() if key != 'inputs'},indent=2))


if __name__ == '__main__':
    main()
