#!/usr/bin/env python3
"""New source/structural checks only; invoke no native tool or predecessor."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import platform
import random
import tarfile
import time

from kernel import (ANNOT, MAX_INT, Binding, Ledger, Term, Var, close, gate_batch,
                    has_annotation, node, open_binding, select_candidate,
                    stored_profile, subst, t_vars, validate_inputs, var)

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
CHECKS = Counter()


def check(ok, family):
    if not ok:
        raise AssertionError(family)
    CHECKS[family] += 1


def rejects(fn, family):
    try:
        fn()
    except ValueError:
        check(True, family)
    else:
        raise AssertionError('not rejected: ' + family)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def identities():
    manifest = json.loads((HERE/'identity.json').read_text())
    sources = {}
    for row in manifest['archives']:
        path = ROOT/row['path']
        check(sha(path.read_bytes()) == row['sha256'], 'archive identity')
        with tarfile.open(path) as archive:
            for item in row['files']:
                data = archive.extractfile(item['path']).read()
                check(len(data) == item['bytes'] and sha(data) == item['sha256'],
                      'complete source identity')
                sources[item['path']] = data.decode()
    for row in manifest['providers']:
        check(sha((ROOT/row['path']).read_bytes()) == row['sha256'], 'provider identity')
    for row in manifest['spans']:
        text = '\n'.join(sources[row['path']].splitlines()[row['first']-1:row['last']])+'\n'
        check(sha(text.encode()) == row['sha256'], 'source span identity')
        for needle in row['contains']:
            check(needle in text, 'source branch anchor')
    native = json.loads((ROOT/'docs/evidence/retained-why-save-shape-builder-allocation-20261020/native-allocation-sites.json').read_text())
    # Read the accepted result; do not decode instructions or replay its checker.
    for prefix in ('camlWhy3__Term__t_subst_unsafe_', 'camlWhy3__Term__t_vars_',
                   'camlWhy3__Term__bv_subst_unsafe_', 'camlWhy3__Term__t_attr_copy_',
                   'camlWhy3__Term__t_open_quant_', 'camlWhy3__Term__t_open_bound_',
                   'camlWhy3__Term__mk_term_', 'camlWhy3__Lists__map_fold_left_'):
        rows = [v for k, v in native.items() if k.startswith(prefix)]
        check(bool(rows) and all(sum(v) <= 4096 for v in rows), 'retained local-frame ceiling')
    return manifest


# Independent eager interpretation: deferred images are looked up after
# dropping the frame that owns them, as Term.descend does. Bound tokens are
# separate from free identifiers and later alpha-normalized for comparison.
def semantic(t, frames=()):
    if t.op == 'var':
        for i, (bound, saved) in enumerate(frames):
            if t.variable in bound:
                return ('bound', bound[t.variable])
            if t.variable in saved:
                return semantic(saved[t.variable], frames[i+1:])
        return ('var', t.variable.tag)
    if t.binding is not None:
        b = t.binding
        tokens = tuple(object() for _ in b.variables)
        frame = (dict(zip(b.variables, tokens)), b.saved)
        inner = (frame,) + frames
        value = semantic(t.args[0], frames) if t.op == 'let' else None
        triggers = tuple(tuple(semantic(x, inner) for x in g) for g in b.triggers)
        return (t.op, tokens, value, triggers, semantic(b.body, inner))
    return (t.op, t.symbol, tuple(semantic(x, frames) for x in t.args))


def canonical(t, scope=()):
    if t[0] == 'bound':
        return ('bound', scope.index(t[1]))
    if t[0] == 'var':
        return t
    if t[0] in {'let', 'eps', 'forall', 'exists'}:
        op, tokens, value, triggers, body = t
        inner = tokens + scope
        return (op, len(tokens), canonical(value, scope) if value else None,
                tuple(tuple(canonical(x, inner) for x in g) for g in triggers),
                canonical(body, inner))
    return (t[0], t[1], tuple(canonical(x, scope) for x in t[2]))


def eager_subst(t, mapping):
    if t[0] == 'var':
        return mapping.get(t[1], t)
    if t[0] == 'bound':
        return t
    if t[0] in {'let', 'eps', 'forall', 'exists'}:
        op, tokens, value, triggers, body = t
        return (op, tokens, eager_subst(value, mapping) if value else None,
                tuple(tuple(eager_subst(x, mapping) for x in g) for g in triggers),
                eager_subst(body, mapping))
    return (t[0], t[1], tuple(eager_subst(x, mapping) for x in t[2]))


def eager_free(t):
    if t[0] == 'var':
        return Counter({t[1]: 1})
    if t[0] == 'bound':
        return Counter()
    if t[0] in {'let', 'eps', 'forall', 'exists'}:
        _, _, value, triggers, body = t
        result = eager_free(body)
        if value:
            result.update(eager_free(value))
        for group in triggers:
            for child in group:
                result.update(eager_free(child))
        return result
    result = Counter()
    for child in t[2]:
        result.update(eager_free(child))
    return result


def valid_caches(t):
    if t.binding is not None:
        b = t.binding
        # Quantifier shell isolates precisely the body's+triggers' cache.
        shell = Term('forall', binding=b)
        expected = eager_free(semantic(shell))
        check(expected == Counter({v.tag: n for v, n in b.free.items()}),
              'deferred cache equals eager counts')
        valid_caches(b.body)
        for group in b.triggers:
            for child in group:
                valid_caches(child)
        for image in b.saved.values():
            valid_caches(image)
    for child in t.args:
        valid_caches(child)


def eager_trivial(t):
    op = t[0]
    if op == 'true':
        return True
    if op in {'let', 'forall'}:
        return eager_trivial(t[4])
    if op == 'implies':
        return eager_trivial(t[2][1])
    if op == 'and':
        return all(eager_trivial(c) for c in t[2])
    if op == 'if':
        return all(eager_trivial(c) for c in t[2][1:])
    return False


def fixed_fixtures():
    x, y, z, u = (Var(i) for i in range(1, 5))
    seed = Ledger(100)
    eps_cost = Ledger(100)
    close('eps', (z,), node('true'), eps_cost)
    check(eps_cost.candidate_records['option'] == 1, 'epsilon close type option charged')
    p = node('app', var(x), symbol='P')
    t = close('forall', (z,), p, seed)
    initial = stored_profile(t)
    out = Ledger(100)
    current = x
    for i in range(12):
        nxt = Var(10+i)
        t = subst({current: var(nxt)}, t, out)
        current = nxt
        valid_caches(t)
    profile = stored_profile(t)
    check(profile['saved_keys'] == 12, 'dead saved history accumulates')
    check(initial['term'] == 3 and profile['term'] == 15, 'stored occurrences grow')
    check(len(t.binding.free) == 1 and t.binding.free[current] == 1,
          'one live free key despite history')
    check(canonical(semantic(t)) == ('forall', 1, None, (),
                                   ('app', 'P', (('var', current.tag),))),
          'opened skeleton remains three nodes')
    check(out.ident_increments == 0, 'substitution has zero Ident increments')

    # Existing nonleaf images are traversed, not treated as variable leaves.
    q = close('forall', (z,), node('app', var(x), var(x), symbol='P'), seed)
    image = node('app', var(y), var(y), ty='int', symbol='f')
    first = subst({x: image}, q, Ledger(100))
    work = Ledger(100)
    second = subst({y: node('app', var(u), ty='int', symbol='g')}, first, work)
    valid_caches(second)
    check(second.binding.free == {u: 4}, 'nonleaf substitution count product')
    check(work.calls['t_subst_visit'] >= 4, 'old nonleaf image traversed')
    check(any(a == 4 and b == 1 for a, b, _ in work.products),
          'native multiply is recorded')

    true = node('true')
    # Triviality opens the forall, and has_attr opens it AGAIN before dropping.
    candidate = close('forall', (x, y), true, seed,
                      triggers=((node('app', var(x), ty='int', symbol='f'),),))
    decisions, shared = gate_batch([candidate, candidate], 100)
    check(all(not d['keep'] for d in decisions), 'trivial candidates discarded')
    check(shared.ident_increments == 8, 'all candidate openings share Ident owner')
    check(shared.calls['t_subst_visit'] >= 12, 'discarded triggers still constructed')

    # has_attr opens a let body BEFORE inspecting an annotated definition.
    let = close('let', (x,), true, seed,
                value=node('const', ty='int', attrs=frozenset({ANNOT})))
    gate = Ledger(100)
    decision = select_candidate(let, gate)
    check(decision == {'trivial': True, 'annotated_if_tested': True, 'keep': True},
          'annotation in definition retains trivial let')
    check(gate.ident_increments == 2, 'annotation shortcut still pays prior opening')

    # Nontrivial left conjunction stops before a binder on the right;
    # has_attr is skipped by add_vc_decl's && guard.
    stop = node('and', node('false'), candidate)
    gate = Ledger(100)
    check(select_candidate(stop, gate)['keep'] and gate.ident_increments == 0,
          'native short circuit avoids later branch and attribute pass')

    # A saved image's annotation is visible only after opening it into a body.
    annotated_image = var(y, frozenset({ANNOT}))
    formula = close('forall', (z,), node('implies', node('app', var(x), symbol='P'), true), seed)
    formula = subst({x: annotated_image}, formula, Ledger(100))
    gate = Ledger(100)
    check(select_candidate(formula, gate)['keep'], 'annotation transported through saved image')

    # All gate exclusions are explicit; no zero is returned for Tcase.
    rejects(lambda: gate_batch([Term('case')], 100), 'unsupported case is explicit')
    rejects(lambda: gate_batch([var(Var(101))], 100), 'unattached Ident input rejected')
    rejects(lambda: subst({x: node('true')}, var(x), Ledger(100)), 'wrong image type rejected')

    return {'fixed_size_history': {'iterations': 12, 'opened_terms': 3,
                                   'stored_terms_before': initial['term'],
                                   'stored_terms_after': profile['term'],
                                   'saved_keys_after': profile['saved_keys'],
                                   'ledger': out.result()},
            'two_discarded_candidates': {'decisions': decisions, 'ledger': shared.result()},
            'nonleaf_image': work.result()}


def randomized_fixtures():
    rng = random.Random(20261024)
    free = [Var(i) for i in range(1, 7)]
    next_binder = 100
    build = Ledger(10000)

    def fresh():
        nonlocal next_binder
        next_binder += 1
        return Var(next_binder)

    def integer(depth):
        if depth == 0 or rng.randrange(3) == 0:
            return var(rng.choice(free))
        if rng.randrange(3) == 0:
            v = fresh()
            return close('let', (v,), node('app', var(v), integer(depth-1), ty='int', symbol='f'),
                         build, value=integer(depth-1))
        return node('app', integer(depth-1), integer(depth-1), ty='int', symbol='f')

    def formula(depth):
        if depth == 0:
            return rng.choice([node('true'), node('false'), node('app', integer(1), symbol='P')])
        choice = rng.randrange(7)
        if choice < 2:
            return node(rng.choice(['and', 'or', 'implies', 'iff']), formula(depth-1), formula(depth-1))
        if choice == 2:
            return node('if', formula(depth-1), formula(depth-1), formula(depth-1))
        if choice == 3:
            return close('let', (fresh(),), formula(depth-1), build, value=integer(2))
        if choice == 4:
            return close(rng.choice(['forall', 'exists']), (fresh(), fresh()), formula(depth-1),
                         build, triggers=((integer(1),),))
        if choice == 5:
            eps = close('eps', (fresh(),), formula(depth-1), build)
            return node('app', eps, symbol='P')
        return node('not', formula(depth-1))

    totals = Counter()
    for _ in range(120):
        t = formula(3)
        for _ in range(3):
            mapping = {rng.choice(free): integer(2) for _ in range(3)}
            expected = eager_subst(semantic(t), {v.tag: semantic(s) for v, s in mapping.items()})
            out = Ledger(10000)
            updated = subst(mapping, t, out)
            check(canonical(semantic(updated)) == canonical(expected), 'lazy/eager substitution diagram')
            valid_caches(updated)
            measured = t_vars(updated, Ledger(10000))
            check(Counter({v.tag: n for v, n in measured.items()}) == eager_free(semantic(updated)),
                  'native t_vars equals independent free occurrence count')
            check(out.ident_increments == 0 and all(out.guards().values()), 'substitution guards')
            decision, gate = gate_batch([updated], 10000)
            check(decision[0]['trivial'] == eager_trivial(semantic(updated)), 'triviality eager diagram')
            leaf_work = Ledger(10000)
            leaf_map = {v: var(rng.choice(free)) for v in free}
            leaf_result = subst(leaf_map, updated, leaf_work)
            check(stored_profile(leaf_result)['term'] <= stored_profile(updated)['term']
                  + leaf_work.saved_image_slots_added_upper, 'leaf storage additive transfer')
            check(sum(t_vars(leaf_result, Ledger(10000)).values()) == sum(measured.values()),
                  'leaf substitution preserves free-occurrence mass')
            totals.update(out.calls)
            t = updated
    return {'substitutions': 360, 'calls': dict(sorted(totals.items()))}


def arithmetic_boundaries():
    x = Ledger(MAX_INT-2)
    v = Var(1)
    x.fresh(v); x.fresh(v)
    check(x.guards()['ident_endpoint'], 'Ident exact boundary fits')
    x.fresh(v)
    check(not x.guards()['ident_endpoint'], 'Ident next increment fails')
    x = Ledger(0)
    check(x.add_count(MAX_INT-1, 1) == MAX_INT and x.guards()['occurrence_sums_and_products'],
          'count sum exact boundary fits')
    x.add_count(MAX_INT, 1)
    check(not x.guards()['occurrence_sums_and_products'], 'count sum overflow identified')
    x = Ledger(0)
    x.mul_count(2**31, 2**31-1)
    check(x.guards()['occurrence_sums_and_products'], 'count product fits')
    x.mul_count(2**31, 2**31)
    check(not x.guards()['occurrence_sums_and_products'], 'count product overflow identified')
    x = Ledger(0)
    x.map('boundary', MAX_INT-3)
    check(x.guards()['map_height_arithmetic'], 'map conservative boundary fits')
    x.map('boundary', MAX_INT-2)
    check(not x.guards()['map_height_arithmetic'], 'map conservative boundary exceeds')
    check(x.map_bytes_upper > MAX_INT, 'mathematical bytes are not native counter')


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    start = time.monotonic()
    identity = identities()
    fixed = fixed_fixtures()
    random = randomized_fixtures()
    arithmetic_boundaries()
    result = {'status': 'pass', 'platform': platform.platform(),
              'scope': 'case-free Term substitution/opening and VC selection gate only',
              'assertions': sum(CHECKS.values()), 'families': dict(sorted(CHECKS.items())),
              'source_files': sum(len(a['files']) for a in identity['archives']),
              'source_spans': len(identity['spans']), 'provider_inputs': len(identity['providers']),
              'fixed_fixtures': fixed, 'randomized_fixtures': random,
              'native_or_predecessor_runs': 0,
              'full_source_to_initial_vc_storage_closed': False,
              'elapsed_seconds': time.monotonic()-start}
    if args.write:
        (HERE/'result.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({k: result[k] for k in ('status', 'assertions', 'source_files',
          'source_spans', 'provider_inputs', 'elapsed_seconds')}, sort_keys=True))


if __name__ == '__main__':
    main()
