#!/usr/bin/env python3
"""One independent offline audit of the frozen first #202 interface.

Does not import/run the author checker or any predecessor. Eager interpretation
predicts complete gate decisions and fresh counts, including term attributes.
Compact constructive DAGs exercise real kernel multiplication/addition sites.
"""
from collections import Counter
from dataclasses import dataclass, replace
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

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
TARGET = ROOT / 'docs/evidence/retained-main-why-storage-20261024'
FREEZE = '3a9be892c22061dddac367eb2d5d636405207525'
spec = importlib.util.spec_from_file_location('reviewed_kernel', TARGET/'kernel.py')
k = importlib.util.module_from_spec(spec)
sys.modules[spec.name] = k
spec.loader.exec_module(k)
CHECKS = Counter()


def check(value, family):
    assert value, family
    CHECKS[family] += 1


def sha(data):
    return hashlib.sha256(data).hexdigest()


def author_inputs():
    paths = sorted(p for p in TARGET.iterdir() if p.is_file())
    paths += [ROOT/'docs/research/retained-main-why-storage.md']
    return {str(p.relative_to(ROOT)): sha(p.read_bytes()) for p in paths}


def identities():
    identity = json.loads((TARGET/'identity.json').read_text())
    sources = {}
    for archive in identity['archives']:
        path = ROOT/archive['path']
        check(sha(path.read_bytes()) == archive['sha256'], 'archive identity')
        with tarfile.open(path) as a:
            for item in archive['files']:
                data = a.extractfile(item['path']).read()
                check(sha(data) == item['sha256'] and len(data) == item['bytes'],
                      'complete source identity')
                sources[item['path']] = data.decode().splitlines()
    for row in identity['spans']:
        data = ('\n'.join(sources[row['path']][row['first']-1:row['last']])+'\n').encode()
        check(sha(data) == row['sha256'], 'source span identity')
    for row in identity['providers']:
        check(sha((ROOT/row['path']).read_bytes()) == row['sha256'], 'provider identity')
    return {'archives': len(identity['archives']), 'sources': len(sources),
            'spans': len(identity['spans']), 'providers': len(identity['providers'])}


@dataclass(frozen=True)
class E:
    op: str
    args: tuple = ()
    attrs: frozenset = frozenset()
    variable: object = None
    bound: tuple = ()
    value: object = None
    body: object = None
    triggers: tuple = ()
    symbol: str = ''


def eager(t, frames=()):
    """Interpret delayed frames, dropping the resolving frame at lookup.

    Attributes on the occurrence join the substituted image's root attributes.
    Fresh opaque bound tokens make capture avoidance independent of native IDs.
    """
    if t.op == 'var':
        tag = t.variable.tag
        for pos, (bound, saved) in enumerate(frames):
            if tag in bound:
                return E('var', attrs=t.attrs, variable=bound[tag])
            if tag in saved:
                image = eager(saved[tag], frames[pos+1:])
                return replace(image, attrs=image.attrs | t.attrs)
        return E('var', attrs=t.attrs, variable=tag)
    if t.binding is not None:
        b = t.binding
        tokens = tuple(object() for _ in b.variables)
        frame = ({v.tag: token for v, token in zip(b.variables, tokens)},
                 {v.tag: image for v, image in b.saved.items()})
        nested = (frame,) + frames
        return E(t.op, attrs=t.attrs, bound=tokens,
                 value=eager(t.args[0], frames) if t.op == 'let' else None,
                 body=eager(b.body, nested),
                 triggers=tuple(tuple(eager(x, nested) for x in g) for g in b.triggers))
    return E(t.op, tuple(eager(x, frames) for x in t.args), t.attrs, symbol=t.symbol)


def eager_subst(t, images):
    if t.op == 'var':
        image = images.get(t.variable, t)
        return replace(image, attrs=image.attrs | t.attrs)
    if t.bound:
        return replace(t, value=eager_subst(t.value, images) if t.value else None,
                       body=eager_subst(t.body, images),
                       triggers=tuple(tuple(eager_subst(x, images) for x in g) for g in t.triggers))
    return replace(t, args=tuple(eager_subst(x, images) for x in t.args))


def canonical(t, scope=()):
    if t.op == 'var':
        key = ('free', t.variable) if isinstance(t.variable, int) else ('bound', scope.index(t.variable))
        return ('var', key, t.attrs)
    if t.bound:
        nested = t.bound + scope
        return (t.op, t.attrs, len(t.bound), canonical(t.value, scope) if t.value else None,
                canonical(t.body, nested), tuple(tuple(canonical(x, nested) for x in g) for g in t.triggers))
    return (t.op, t.attrs, t.symbol, tuple(canonical(x, scope) for x in t.args))


def eager_gate(t):
    opened = 0
    def trivial(x):
        nonlocal opened
        if x.op == 'true':
            return True
        if x.op in {'let', 'forall'}:
            opened += len(x.bound)
            return trivial(x.body)
        if x.op == 'implies':
            return trivial(x.args[1])
        if x.op == 'and':
            return trivial(x.args[0]) and trivial(x.args[1])
        if x.op == 'if':
            return trivial(x.args[1]) and trivial(x.args[2])
        return False
    def annotated(x):
        nonlocal opened
        if k.ANNOT in x.attrs:
            return True
        if x.bound:
            opened += len(x.bound)
            return ((x.value is not None and annotated(x.value)) or annotated(x.body)
                    or any(annotated(y) for g in x.triggers for y in g))
        return any(annotated(y) for y in x.args)
    yes = trivial(t)
    attr = annotated(t) if yes else None
    return {'trivial': yes, 'annotated_if_tested': attr, 'keep': not yes or attr}, opened


def gate_diagrams():
    rng = random.Random(202610240313)
    variables = [k.Var(i) for i in range(1, 5)]
    seed = k.Ledger(100000)
    next_binder = 100
    all_ops = set()
    def fresh():
        nonlocal next_binder
        next_binder += 1
        return k.Var(next_binder)
    def attribute(t):
        all_ops.add(t.op)
        return replace(t, attrs=frozenset({k.ANNOT}) if rng.randrange(5) == 0 else frozenset())
    def integer(depth):
        if depth == 0:
            return attribute(k.var(rng.choice(variables)))
        mode = rng.randrange(4)
        if mode == 0:
            return attribute(k.node('const', ty='int', symbol='c'))
        if mode == 1:
            return attribute(k.close('eps', (fresh(),), formula(depth-1), seed))
        if mode == 2:
            return attribute(k.close('let', (fresh(),), integer(depth-1), seed, value=integer(depth-1)))
        return attribute(k.node('app', integer(depth-1), integer(depth-1), ty='int', symbol='f'))
    def formula(depth):
        if depth == 0:
            return attribute(rng.choice([k.node('true'), k.node('false'), k.node('app', integer(0), symbol='P')]))
        op = rng.choice(['and', 'or', 'implies', 'iff', 'if', 'not', 'forall', 'exists', 'let'])
        if op in {'and', 'or', 'implies', 'iff'}:
            t = k.node(op, formula(depth-1), formula(depth-1))
        elif op == 'if':
            t = k.node(op, formula(depth-1), formula(depth-1), formula(depth-1))
        elif op == 'not':
            t = k.node(op, formula(depth-1))
        elif op == 'let':
            t = k.close(op, (fresh(),), formula(depth-1), seed, value=integer(depth-1))
        else:
            t = k.close(op, (fresh(), fresh()), formula(depth-1), seed,
                        triggers=((integer(depth-1), integer(0)), ()))
        return attribute(t)
    count = 0
    expected_increments = 0
    all_terms = []
    for _ in range(100):
        term = formula(3)
        for _ in range(3):
            images = {v: integer(2) for v in rng.sample(variables, 2)}
            expected = eager_subst(eager(term), {v.tag: eager(x) for v, x in images.items()})
            term = k.subst(images, term, k.Ledger(100000))
            check(canonical(eager(term)) == canonical(expected), 'attribute-aware lazy/eager substitution')
            decision, openings = eager_gate(expected)
            actual, ledger = k.gate_batch([term], 100000)
            check(actual == [decision], 'complete gate decision')
            check(ledger.ident_increments == openings, 'eager fresh-identifier prediction')
            check(all(ledger.guards().values()), 'small constructive gate guards')
            all_terms.append(term)
            expected_increments += openings
            count += 1
    _, whole = k.gate_batch(all_terms, 100000)
    check(whole.ident_increments == expected_increments, 'one shared batch counter')
    check(all_ops == k.SUPPORTED, 'every supported constructor exercised')
    return {'diagrams': count, 'supported_nodes': sorted(all_ops), 'batch_ident_increments': expected_increments}


def arithmetic_dags():
    x, y, b = k.Var(1), k.Var(2), k.Var(3)
    def mass(v, steps, plus_one=False):
        term = k.var(v)
        out = k.Ledger(100)
        for _ in range(steps):
            children = (term, term, k.var(v)) if plus_one else (term, term)
            term = k.close('eps', (b,), k.node('app', *children, symbol='P'), out)
        return term, out
    rows = []
    for left, right, safe in [(30,31,True), (31,31,False)]:
        source, construction = mass(x, left)
        image, image_construction = mass(y, right)
        work = k.Ledger(100)
        updated = k.subst({x: image}, source, work)
        check(work.products == [(2**left, 2**right, 2**(left+right))], 'constructive DAG actual multiplication')
        check(work.guards()['occurrence_sums_and_products'] is safe, 'constructive DAG multiplication guard')
        check(updated.binding.free[y] == 2**(left+right), 'constructive DAG output coefficient')
        check(all(construction.guards().values()) and all(image_construction.guards().values()), 'operand DAG construction safe')
        rows.append({'left': 2**left, 'right': 2**right, 'product': 2**(left+right), 'safe': safe})
    term, construction = mass(x, 61, True)
    check(term.binding.free[x] == k.MAX_INT and all(construction.guards().values()), 'constructive DAG exact max_int cache')
    overflow = k.Ledger(100)
    k.t_vars(k.node('app', term, k.var(x), symbol='P'), overflow)
    check(overflow.sums == [(k.MAX_INT,1,k.MAX_INT+1)], 'constructive DAG actual overflowing addition')
    check(not overflow.guards()['occurrence_sums_and_products'], 'constructive DAG addition guard')
    return {'products': rows, 'exact_safe_cache': k.MAX_INT, 'overflowing_sum': list(overflow.sums[0])}


def specific_seams():
    x, y, z = k.Var(1), k.Var(2), k.Var(3)
    seed = k.Ledger(100)
    t = k.close('forall', (z,), k.node('app', k.var(x), symbol='P'), seed)
    # Bring an already-saved key back into the live cache, then collide with it.
    t = k.subst({x: k.var(y)}, t, k.Ledger(100))
    t = k.subst({y: k.node('app', k.var(x), ty='int', symbol='g')}, t, k.Ledger(100))
    t = k.subst({x: k.node('app', k.var(z), ty='int', symbol='f')}, t, k.Ledger(100))
    check(t.binding.saved[x].symbol == 'g', 'saved union keeps rewritten old duplicate')
    expected = k.node('app', k.node('app', k.var(z), ty='int', symbol='f'), ty='int', symbol='g')
    check(canonical(eager(t.binding.saved[x])) == canonical(eager(expected)), 'nonleaf duplicate image rewritten before union')
    # A dead saved image remains in the domain check, despite trivial gate skip.
    malformed = replace(t, binding=replace(t.binding, saved={**t.binding.saved, k.Var(4): k.Term('case')}))
    try:
        k.gate_batch([malformed],100)
    except ValueError:
        check(True, 'dead unsupported image rejected structurally')
    else:
        raise AssertionError('dead unsupported image rejected structurally')
    # Two discarded candidates reach the exact endpoint, then exceed it by one.
    candidate = k.close('forall', (x,y), k.node('true'), seed,
                        triggers=((k.node('app', k.var(x), ty='int', symbol='f'),),))
    decisions, safe = k.gate_batch([candidate,candidate], k.MAX_INT-8)
    _, unsafe = k.gate_batch([candidate,candidate], k.MAX_INT-7)
    check(all(not d['keep'] for d in decisions) and safe.ident_increments == 8, 'discarded candidate Ident count')
    check(safe.guards()['ident_endpoint'] and not unsafe.guards()['ident_endpoint'], 'gate exact Ident endpoint')


def main():
    start = time.monotonic()
    before = author_inputs()
    check(subprocess.check_output(['git','rev-parse','HEAD'], cwd=ROOT, text=True).strip() == FREEZE,
          'review frozen commit')
    identities_result = identities()
    diagrams = gate_diagrams()
    arithmetic = arithmetic_dags()
    specific_seams()
    check(author_inputs() == before, 'author packet unmodified')
    result = {'status':'pass', 'reviewed_commit':FREEZE, 'platform':platform.platform(),
              'assertions':sum(CHECKS.values()), 'families':dict(sorted(CHECKS.items())),
              'identities':identities_result, 'gate_diagrams':diagrams,
              'constructive_arithmetic':arithmetic, 'author_inputs_sha256':before,
              'audit_sha256':sha(Path(__file__).read_bytes()),
              'elapsed_seconds':time.monotonic()-start, 'native_runs':0,
              'author_or_predecessor_checker_replays':0,
              'full_main_attachment_claimed':False}
    (HERE/'result.json').write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps({key:result[key] for key in ['status','assertions','elapsed_seconds','identities']},sort_keys=True))


if __name__ == '__main__':
    main()
