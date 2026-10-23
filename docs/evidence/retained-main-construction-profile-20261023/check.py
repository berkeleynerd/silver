#!/usr/bin/env python3
"""Focused offline identities, coefficients and constructor-family checks."""
import hashlib
import gzip
import itertools
import json
from pathlib import Path
import platform
import tarfile
import time

from algebra import (ArrayShape, Builder, Program, Signature, Term, affine, app,
                     array_conversion, catalogue, connective, length_equality,
                     lexical, program, program_inventory, program_record,
                     split_post, term, term_record, typed_expression_affine, typed_expression_nodes, var)

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
COUNT = 0


def check(value, message):
    global COUNT
    if not value:
        raise AssertionError(message)
    COUNT += 1


def digest(data):
    return hashlib.sha256(data).hexdigest()


def identity_checks():
    spec = json.loads((HERE / 'identity.json').read_text())
    for p in spec['providers']:
        check(digest((ROOT / p['path']).read_bytes()) == p['sha256'], p['path'])
    archive = HERE / 'sources.tar.gz'
    check(digest(archive.read_bytes()) == spec['sources_sha256'], 'source archive')
    with tarfile.open(archive) as tf:
        check(set(tf.getnames()) == {p['path'] for p in spec['sources']}, 'complete source member inventory')
        for p in spec['sources']:
            data = tf.extractfile(p['path']).read()
            check(len(data) == p['bytes'] and digest(data) == p['sha256'], p['path'])
            with tarfile.open(ROOT / p['provider']) as upstream:
                check(upstream.extractfile(p['provider_member']).read() == data,
                      'complete copied source equals retained upstream member')
    # Retained source bytes are checked; semantic source correspondence is the
    # accompanying derivation plus independent review, not string matching.
    return dict(source_files=len(spec['sources']), providers=len(spec['providers']))


def nodes(n):
    yield n
    for a in n.args:
        yield from nodes(a)


def pnodes(n):
    yield n
    for a in n.args:
        yield from pnodes(a)


def occurrences(root, uid):
    return sum(n.uid == uid for n in nodes(root))


def native_record(root):
    # Node identity is retained; child arrays contain repeated IDs at each use.
    ns = {n.uid: n for n in nodes(root)}
    return dict(root=root.uid, nodes=[dict(id=n.uid, op=n.op, type=n.ty,
                key=n.key, domain=n.domain, symbol_identifier=n.symbol_identifier,
                children=[a.uid for a in n.args]) for n in ns.values()])


def expected(t, c, **vs):
    ac, av = affine(t)
    check(ac == c and dict(av) == vs, f'expected affine {c}, {vs}; got {ac}, {av}')


def positive_checks(t):
    c, vs = affine(t)
    check(c >= 0 and all(v > 0 for v in vs.values()), 'nonnegative affine coefficients')
    keys = sorted(vs)
    for scale in (1, 2, 17, 10**80):
        weights = {k: scale * (i + 1) for i, k in enumerate(keys)}
        check(lexical(t, weights) == c + sum(v * weights[k] for k, v in vs.items()),
              'affine agrees with direct lexical binder evaluation')
        grown = {k: v + scale for k, v in weights.items()}
        check(lexical(t, grown) >= lexical(t, weights), 'fixed-shape monotonicity')


def primitive_checks(c):
    for s in c.values():
        for t in s.pre + ((s.post,) if s.post else ()):
            positive_checks(t)
        parts = split_post(s.post) if s.post else None
        if parts:
            for t in parts:
                positive_checks(t)
    expected(c['Boolean.bool_eq'].post, 5, result=1, a0=1, a1=1)
    expected(c['Boolean.bool_ne'].post, 5, result=1, a0=1, a1=1)
    expected(split_post(c['Boolean.bool_eq'].post)[0], 4, a0=1, a1=1)
    expected(c['Discrete.bool_eq'].post, 7, result=2, a0=1, a1=1)
    expected(c['Static.range_check'].post, 3, result=1, a0=2)
    expected(c['Dynamic.range_check'].post, 3, result=1, a0=1, a1=1, a2=2)
    expected(c['String.of_array'].post, 2, result=1, a0=1, a1=1, a2=1)
    expected(c['Int.<='].post, 4, result=1, a0=1, a1=1)
    expected(split_post(c['Int.<='].post)[0], 4, a0=1, a1=1)
    for k in ('Rep_Proj_Base.to_rep', 'Rep_Proj_Base.of_rep'):
        check(split_post(c[k].post) is None, 'orientation/projection blocks extraction: ' + k)
    # This only checks the unsimplified conditional's split, not an assertion
    # that Why3 cannot simplify this non-reached catalogue shape before split.
    check(split_post(c['Discrete.bool_eq'].post) is None, 'raw Discrete conditional split')
    nested = Term('let', (var('x'), Term('let', (
        app('f', var('b1'), ty='int'), app('=', var('b1'), var('b2'))), 'b2', 'prop')),
        'b1', 'prop')
    expected(nested, 5, x=4)
    positive_checks(nested)


def length_checks(c):
    b = Builder()
    bounds = [b.identifier(k, 'int') for k in ('lf', 'll', 'rf', 'rl')]
    n = length_equality(b, *bounds)
    t = term(n, c, 'prop')
    expected(t, 8, lf=2, ll=2, rf=3, rl=3)
    check(sum(x.op == 'call' for x in nodes(n)) == 6, 'six length helper calls')
    check(n.args[-1].ty == 'int' and t.args[-1].ty == 'prop', 'symbol/context overrides native return annotation')
    positive_checks(t)
    # Check explicit coercion costs, independently of the native domain tag.
    pred = b.call('Int.<', 'bool', bounds[0], bounds[1], domain='term')
    expected(term(pred, c), 4, lf=1, ll=1)
    val = b.identifier('flag', 'bool')
    expected(term(val, c, 'prop'), 2, flag=1)


def make_case(static_source, static_target, kind, sliding, need_check, domain, equal=False):
    b = Builder()
    src = ArrayShape('source-type', static_source, b.identifier('sf', 'int'), b.identifier('sl', 'int'))
    dst = ArrayShape('target-type', static_target, b.identifier('tf', 'int'), b.identifier('tl', 'int'))
    if kind == 'identifier':
        e = b.identifier('source-value', src.ty)
    elif kind == 'deref':
        if not static_source:
            raise ValueError('ordinary unconstrained read uses separate reconstruction')
        e = b.node('deref', 'map', b.identifier('source-ref', 'map__ref'), key='map__content')
    else:
        m = b.identifier('source-map', 'map')
        if static_source:
            e = b.call('Array.slice', 'map', m, src.first, src.last, domain='prog')
        else:
            e = b.call('String.of_array', 'string', m, src.first, src.last, domain='prog')
        if kind == 'pending':
            e = b.temporary(e)
    pending_before = dict(b.pending)
    out = array_conversion(b, e, src, dst, sliding=sliding, need_check=need_check,
                           domain=domain, static_lengths_equal=equal)
    return b, src, dst, e, out, pending_before


def case_checks(c):
    cases = []
    samples = []
    for ss, st, sliding, check_on, mode in itertools.product((False, True), (False, True),
                                                            (False, True), (False, True), ('prog', 'term')):
        if sliding and not st:
            continue
        kinds = ('identifier', 'complex', 'pending') + (('deref',) if ss else ())
        for kind in kinds:
            b, src, dst, e, out, old_pending = make_case(ss, st, kind, sliding, check_on, mode)
            expected_mult = (1 if kind in {'complex', 'pending'} or ss else
                             1 + (1 if sliding else 0) + (0 if st else 2)
                             + ((4 if st else 2) if check_on and mode == 'prog' else 0))
            check(occurrences(out, e.uid) == expected_mult, 'source-child occurrence multiplicity')
            check(b.pending == old_pending, 'conversion consumes only its own new temporaries')
            creates = sum(x[0] == 'create' for x in b.events) - len(old_pending)
            check(creates == 1 + (kind in {'complex', 'pending'}), 'mandatory split binding and conditional source binding')
            nbindings = sum(n.op == 'binding' for n in nodes(out))
            check(nbindings == creates, 'one retained binding per consumed temporary')
            label_bindings = [n for n in nodes(out) if n.op == 'binding' and n.args[0].op == 'label']
            check(len(label_bindings) == 1, 'empty label forces one split binding')
            case = dict(static_source=ss, static_target=st, input=kind, sliding=sliding,
                        need_check=check_on, mode=mode, child_occurrences=expected_mult,
                        source_bindings=nbindings)
            sample = dict(parameters=case, native=native_record(out),
                          construction_events=b.events, source_child=native_record(e),
                          source_shape=dict(identity=src.identity, static=src.static,
                                            first=native_record(src.first), last=native_record(src.last)),
                          target_shape=dict(identity=dst.identity, static=dst.static,
                                            first=native_record(dst.first), last=native_record(dst.last)),
                          pending_before={str(k): native_record(v) for k, v in old_pending.items()},
                          pending_after={str(k): native_record(v) for k, v in b.pending.items()})
            if mode == 'prog':
                p = program(out, c)
                inv = program_inventory(p)
                check(inv['binding'] == nbindings, 'E projection preserves non-wildcard bindings')
                check(inv['assert'] == int(check_on), 'one requested assertion in nonmatching case')
                check(sum(x.key == 'String.first' for x in pnodes(p)) ==
                      (int(sliding) + int(not st) if not ss else 0),
                      'program accessors survive term-domain native tag')
                check(typed_expression_nodes(p) >= sum(1 for _ in pnodes(p)), 'local expression-node envelope')
                for x in pnodes(p):
                    if x.attached:
                        positive_checks(x.attached)
                case['typed_expression_nodes_upper'] = typed_expression_nodes(p)
                case['program_inventory'] = dict(sorted(inv.items()))
                # The input tree is parameterized; these complete diagrams are
                # selected branch witnesses, not completeness-by-sampling.
                sample['program'] = program_record(p, c)
            else:
                t = term(out, c)
                positive_checks(t)
                case['logical_profile'] = {k: v for k, v in term_record(t).items() if k != 'tree'}
                sample['logical_profile'] = term_record(t)
            cases.append(case)
            samples.append(sample)
    # Same entity fast path neither consumes an incoming pending temp nor
    # inserts even a requested check/slide. Coherent shape identity is required.
    b = Builder()
    src = ArrayShape('same', False, b.identifier('f', 'int'), b.identifier('l', 'int'))
    e = b.temporary(b.call('String.of_array', 'string', b.identifier('m', 'map'), src.first, src.last))
    before = dict(b.pending)
    check(array_conversion(b, e, src, src, sliding=True, need_check=True) is e, 'same-identity fast path')
    check(b.pending == before, 'same-identity fast path leaves pending state unchanged')
    # Statically matching lengths elide only the assertion, not split binding.
    b, src, dst, e, out, _ = make_case(True, True, 'identifier', False, True, 'prog', True)
    p = program(out, c)
    check(program_inventory(p)['assert'] == 0 and program_inventory(p)['binding'] == 1,
          'static matching length assertion elision')
    # Named bound symbols and representation conversions retain their own
    # program application routes. A supplied first tree is not a literal leaf.
    b = Builder()
    c2 = dict(c)
    c2['Bound.first'] = Signature('Bound.first', (), 'abstract', 'Cpur', (),
                                  app('=', var('result', 'abstract'), app('Bound.first', ty='abstract')),
                                  'supplied bound-symbol resolution interface')
    bound = b.call('Rep_Proj_Base.to_rep', 'int', b.identifier('Bound.first', 'abstract', symbol=True))
    src = ArrayShape('from', True, bound, b.identifier('sl', 'int'))
    dst = ArrayShape('to', False, b.identifier('tf', 'int'), b.identifier('tl', 'int'))
    e = b.identifier('m', 'map')
    out = array_conversion(b, e, src, dst, need_check=True)
    p = program(out, c2)
    inv = program_inventory(p)
    check(inv['call:Rep_Proj_Base.to_rep'] == 1 and inv['call:Bound.first'] == 1, 'bound subtree program route')
    t = next(x.attached for x in pnodes(p) if x.attached)
    check(affine(t)[0] == 3, 'dynamic check retains bound call and conversion term nodes')
    # Need_Temp=False still rebinds an already pending temporary.
    b = Builder()
    e = b.call('Int.neg', 'int', b.identifier('x', 'int'))
    check(b.temporary(e, need=False) is e, 'Need_Temp=False for nonpending complex child')
    first = b.temporary(e)
    second = b.temporary(first, need=False)
    check(second.uid != first.uid and b.pending[second.uid] is first, 'pending disjunct overrides Need_Temp=False')
    outer = b.binding(first, b.binding(second, second))
    check(not b.pending and occurrences(outer, e.uid) == 1, 'pending chain binds once without capture')
    # Sharing a cheap dereference would lose program-call occurrences. Retain
    # each use; this witness concerns the temporary API, not a new String form.
    b = Builder()
    d = b.node('deref', 'map', b.identifier('r', 'map__ref'), key='map__content')
    cheap = b.temporary(d)
    twice = b.node('sequence', 'map', cheap, cheap)
    check(program_inventory(program(b.binding(cheap, twice), c))['call:map__content'] == 2,
          'cheap dereference is repeated at both program uses')
    for bad in ('tmp:1', 'tmp:999'):
        try:
            b.identifier(bad, 'int')
        except ValueError:
            check(True, 'generated namespace protected')
        else:
            check(False, 'generated namespace collision')
    other = Builder().identifier('alien', 'int')
    try:
        b.temporary(other)
    except ValueError:
        check(True, 'foreign UID rejected even when its integer equals a local UID')
    else:
        check(False, 'foreign UID accepted')
    # The wrapper can import an independently derived complete child profile;
    # the projection does not replace that profile by an untyped variable.
    b = Builder()
    src = ArrayShape('source', False, b.identifier('sf', 'int'), b.identifier('sl', 'int'))
    dst = ArrayShape('target', True, b.identifier('tf', 'int'), b.identifier('tl', 'int'))
    e = b.node('unexpanded-source-concat', 'string')
    out = array_conversion(b, e, src, dst, sliding=True, need_check=True)
    hole = Program('input', 'string', key='P_source_child', input_scope='source-binding-environment')
    p = program(out, c, {e.uid: hole})
    constant, coefficient = typed_expression_affine(p)
    check(dict(coefficient) == {'P_source_child': 1}, 'whole complex child profile imported exactly once')
    check(typed_expression_nodes(p, {'P_source_child': 10**90}) == constant + 10**90,
          'symbolic source size without a policy ceiling')
    supplied_example = dict(native=native_record(out), program=program_record(p, c),
                            expression_nodes=dict(constant=constant, coefficients=dict(coefficient)),
                            obligation='P_source_child and its binding context require a complete independent derivation')
    return dict(cases=cases, diagrams=samples, supplied_child_interface=supplied_example)


def calculate():
    c = catalogue()
    primitive_checks(c)
    length_checks(c)
    cases = case_checks(c)
    return dict(primitive_catalogue={k: s.record() for k, s in sorted(c.items())}, **cases)


def main():
    start = time.monotonic()
    identities = identity_checks()
    actual = calculate()
    with gzip.open(HERE / 'profiles.json.gz', 'rt') as retained:
        expected_data = json.load(retained)
    actual = json.loads(json.dumps(actual))
    check(actual == expected_data, 'retained profiles agree with recomputation')
    report = dict(status='pass', checks=COUNT, primitive_signatures=len(actual['primitive_catalogue']),
                  conversion_parameter_cases=len(actual['cases']), retained_diagrams=len(actual['diagrams']),
                  **identities, platform=platform.platform(),
                  elapsed_seconds=time.monotonic() - start,
                  compiler_prover_target_runs=0,
                  scope='restricted construction and formal-call interface; full typed Main join remains open')
    print(json.dumps(report, indent=2))
    return report


if __name__ == '__main__':
    main()
