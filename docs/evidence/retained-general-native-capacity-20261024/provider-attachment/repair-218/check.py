#!/usr/bin/env python3
"""Focused #218 source/bridge/request audit; no predecessor or native execution."""
import argparse
from dataclasses import dataclass, field
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import platform
import subprocess
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[4]
START = datetime(2026, 10, 24, 8, 52, 51, tzinfo=timezone.utc)


def read(path):
    return json.loads(path.read_bytes())


def sha(data):
    return hashlib.sha256(data).hexdigest()


def git_blob(commit, path):
    return subprocess.check_output(['git', 'show', commit + ':' + path], cwd=ROOT)


def bytes_for(row):
    return sum(a*b for a, b in zip(row, (40, 32, 40, 48, 256)))


@dataclass(eq=False)
class Native:
    code: str
    value: int | None = None
    constant: bool = False
    readonly: bool = False
    initial: object = None
    corresponding: object = None


@dataclass(eq=False)
class Front:
    code: str
    args: tuple = ()


@dataclass(eq=False)
class Provider:
    low: Front
    native_low: Native
    fixed_positive: bool = False


@dataclass
class Meter:
    cubtd: list = field(default_factory=lambda: [0, 0, 0, 0, 0])
    tests: int = 0
    initializer_visits: int = 0
    entity_reads: int = 0
    saved_entities: dict = field(default_factory=dict)

    def one(self, value=1):
        self.cubtd[0] += 1
        return Native('INTEGER_CST', value, True)


def known_front(f):
    # Surviving IFs are not compile-time known, even with equal arms.
    if f.code == 'literal':
        return True
    if f.code == 'first':
        return known_front(f.args[0].low)
    if f.code == 'capture':
        return known_front(f.args[1])
    return False


def static_max_gate(low, high_known=False, finite=True, in_range=True):
    return known_front(low) and not high_known and finite and in_range


def native_low(f, meter, *, pure=True):
    if f.code == 'literal':
        return meter.one(f.args[0])
    if f.code == 'first':
        p = f.args[0]
        assert p.native_low.code == 'INTEGER_CST' and p.native_low.value == 1
        # Completed index read plus one conservative constant conversion.
        return meter.one(p.native_low.value)
    if f.code == 'capture':
        meter.entity_reads += 1
        decl = meter.saved_entities[f.args[0]]
        # Native scalar bound/initializer rvalue: no lvalue is required.
        assert decl.constant and decl.initial is not None
        assert decl.code == 'CONST_DECL'
        return decl.initial
    if f.code == 'if':
        assert pure, 'equal-arm bridge requires an effect-free test'
        meter.tests += 1
        meter.one(0)  # test is constructed even though it is discarded
        meter.cubtd[2] += 1
        left = native_low(f.args[0], meter, pure=pure)
        right = native_low(f.args[1], meter, pure=pure)
        assert left.code == right.code == 'INTEGER_CST'
        assert left.value == right.value == 1
        return left
    raise AssertionError(f.code)


def define_capture(key, initializer, meter, debug):
    meter.initializer_visits += 1
    init = native_low(initializer, meter)
    # Generated E_Constant/Is_True_Constant, compatible scalar, local/nonvolatile.
    assert init.constant and init.value == 1
    decl = Native('CONST_DECL', constant=True, readonly=True, initial=init)
    meter.cubtd[4] += 1
    meter.cubtd[1] += 1  # add_decl_expr, including for CONST_DECL
    if debug:
        decl.corresponding = Native('VAR_DECL', constant=True, readonly=True, initial=init)
        assert decl.corresponding is not decl
        meter.cubtd[4] += 1
        meter.cubtd[1] += 1
    assert key not in meter.saved_entities
    meter.saved_entities[key] = decl
    return Front('capture', (key, initializer))


def make_event(providers, nullable, debug, all_encodings, key):
    meter = Meter()
    lows = [Front('literal', (1,)) if known_front(p.low) else Front('first', (p,))
            for p in providers]
    selected, selectors = lows[-1], 0
    for i in range(len(lows)-2, -1, -1):
        if providers[i].fixed_positive:
            selected = lows[i]
            selectors = 0
        elif known_front(lows[i]) and known_front(selected):
            pass  # actual literal equality branch; no claimed IF folding
        else:
            selected = Front('if', (lows[i], selected))
            selectors += 1
    m = int(selected.code == 'if')
    chosen = define_capture(key, selected, meter, debug) if m else selected
    low = Front('if', (lows[-1], chosen)) if nullable else chosen
    native = native_low(low, meter)
    # The high's use of the selected low is a second rvalue occurrence.
    assert native_low(chosen, meter).value == 1
    assert native.value == 1 and native.constant
    before_visits = meter.initializer_visits
    if m:
        for _ in range(17):
            assert native_low(chosen, meter) is meter.saved_entities[key].initial
        assert meter.initializer_visits == before_visits == 1
    # Isolated low-only debug allocation: return the original constant anyway.
    debug_low = int(all_encodings and not known_front(low))
    assert native.code == 'INTEGER_CST'
    j = 2*selectors+4+5*int(nullable)
    row = (13*j+4+2*int(nullable), 2+int(nullable)+2*m,
           2*selectors+4*int(nullable)+3, selectors+2*int(nullable), 2*m)
    assert all(a <= b for a, b in zip(meter.cubtd, row)), (meter.cubtd, row)
    assert meter.tests == selectors+int(nullable)
    assert selectors <= len(providers)-1 and m <= 1
    return Provider(low, native), meter, selectors, m, debug_low


def bridge_checks():
    seed = Provider(Front('literal', (1,)), Native('INTEGER_CST', 1, True))
    fixed = Provider(seed.low, seed.native_low, True)
    witnesses, profiles, copy_profiles = [], 0, 0
    for debug in (False, True):
        for all_encodings in (False, True):
            inner, im, s, m, dl = make_event([seed, seed], True, debug, all_encodings, ('inner', debug, all_encodings))
            assert s == m == 0 and not known_front(inner.low)
            outer, om, s, m, dl = make_event([inner, fixed], False, debug, all_encodings, ('outer', debug, all_encodings))
            assert s == m == 1 and not known_front(outer.low)
            assert outer.native_low.value == 1
            witnesses.append(dict(debug=debug, all_encodings=all_encodings,
                                  outer_s=s, outer_m=m, low_debug=dl,
                                  native_lower=1, frontend_known=False,
                                  initializer_visits=om.initializer_visits,
                                  entity_reads=om.entity_reads))
            # Finite maximum alone cannot pass the frontend low-known gate.
            direct_nullable, *_ = make_event([seed, seed], True, debug, all_encodings, ('direct', debug, all_encodings))
            assert not static_max_gate(direct_nullable.low)
            nonnull_fixed, *_ = make_event([fixed, seed], False, debug, all_encodings, ('fixed', debug, all_encodings))
            assert static_max_gate(nonnull_fixed.low)
            assert not static_max_gate(nonnull_fixed.low, finite=False)
            assert not static_max_gate(nonnull_fixed.low, high_known=True)
            assert not static_max_gate(nonnull_fixed.low, in_range=False)
            p, total_s, total_m, source_c = inner, 0, 0, 1
            for depth in range(1, 129):
                if depth % 2:
                    # Ordinary source alias: same completed index/native bound.
                    p = Provider(p.low, p.native_low)
                p, meter, s, m, dl = make_event([p, p], True, debug, all_encodings, (depth, debug, all_encodings))
                source_c += 1
                total_s += s
                total_m += m
                assert total_s <= source_c and total_m <= source_c
                assert not known_front(p.low) and p.native_low.value == 1
                # Actual fresh source copies must retranslate the local IF.
                # Their capture leaves consult the existing completed entity.
                for _ in range(2):
                    copied = Meter(saved_entities=meter.saved_entities)
                    assert native_low(p.low, copied).value == 1
                    assert copied.tests == 1 and copied.initializer_visits == 0
                    assert all(a <= b for a, b in zip(copied.cubtd, (40,2,2,2,0)))
                    copy_profiles += 1
                profiles += 1
            # Long current-event selectors, distinct from provider depth.
            for n in (2, 3, 9, 10, 63, 64, 129):
                p2, meter, s, m, dl = make_event([p]*n, True, debug, all_encodings, ('arity', n, debug, all_encodings))
                assert s == n-1 and m == 1 and p2.native_low.value == 1
                profiles += 1
    try:
        native_low(Front('if', (seed.low, seed.low)), Meter(), pure=False)
    except AssertionError:
        pass
    else:
        raise AssertionError('effectful test admitted')
    bad = Provider(seed.low, Native('VAR_DECL', readonly=True))
    try:
        native_low(Front('first', (bad,)), Meter())
    except AssertionError:
        pass
    else:
        raise AssertionError('readonly assumed native-one')
    return witnesses, profiles, copy_profiles


def source_checks():
    inputs = read(HERE/'inputs.json')
    for entry in inputs['immutable_files']:
        data = (ROOT/entry['path']).read_bytes()
        assert len(data) == entry['bytes'] and sha(data) == entry['sha256']
        assert data == git_blob(entry['commit'], entry['path'])
    for entry in inputs['review_blobs']:
        assert sha(git_blob(entry['commit'], entry['path'])) == entry['sha256']
    historical = inputs['original_research_append']
    old_research = git_blob(historical['commit'], historical['path'])
    assert sha(old_research) == historical['sha256']
    assert (ROOT/historical['path']).read_bytes().startswith(old_research)
    for entry in read(HERE/'manifest.json')['files']:
        data = (ROOT/entry['path']).read_bytes()
        assert len(data) == entry['bytes'] and sha(data) == entry['sha256']
    manifest = read(HERE/'sources.json')
    sources = {}
    for a in manifest['archives']:
        path = ROOT/a['path']
        assert sha(path.read_bytes()) == a['sha256']
        rows = [e for e in manifest['files'] if e['archive'] == a['path']]
        with tarfile.open(path, 'r:gz') as tf:
            for entry in rows:
                data = tf.extractfile(entry['path']).read()
                assert len(data) == entry['bytes'] and sha(data) == entry['sha256']
                sources[entry['path']] = data
    for entry in manifest['witnesses']:
        data = b'\n'.join(sources[entry['path']].split(b'\n')[entry['first']-1:entry['last']])+b'\n'
        assert sha(data) == entry['sha256']
    snippets = {}
    for entry in manifest['witnesses']:
        snippets[entry['id']] = b'\n'.join(sources[entry['path']].split(b'\n')[entry['first']-1:entry['last']]).decode()
    assert 'Set_Is_True_Constant (Id)' in snippets['constant_analysis']
    assert 'Is_True_Constant (gnat_entity)' in snippets['constant_flag']
    assert 'constant_p = const_flag && init_const' in snippets['constant_declaration']
    assert '? CONST_DECL : VAR_DECL' in snippets['constant_declaration']
    assert 'DECL_INITIAL (var_decl) = init' in snippets['constant_flags']
    assert 'SET_DECL_CONST_CORRESPONDING_VAR' in snippets['corresponding_debug']
    assert 'gnu_result = DECL_INITIAL (gnu_result)' in snippets['identifier_substitution']
    assert '!TREE_CONSTANT (gnu_expr)' in snippets['bound_elaboration']
    assert 'gnu_stmt = build1 (DECL_EXPR' in snippets['declaration_expression']
    return len(sources), len(manifest['witnesses'])


def main():
    start = time.perf_counter()
    files, spans = source_checks()
    witnesses, profiles, copies = bridge_checks()
    effective = read(HERE/'effective.json')
    assert bytes_for((40,2,2,2,0)) == 1840
    assert bytes_for((153,8,12,4,0)) == 7048 == 3368+2*1840
    assert 2*(256+32) == 576
    assert 1168+2968+576+2424 == 7136
    assert 7136+2*7048+4*576 == 23536
    for s in range(129):
        for r in (0,1):
            for m in (0,1):
                j = 2*s+4+5*r
                row = (13*j+4+2*r,2+r+2*m,2*s+4*r+3,s+2*r,2*m)
                assert bytes_for(row) == 520*j+128*s+368*r+576*m+344
                assert bytes_for(row) == 1168*s+2968*r+576*m+2424
    assert effective['copied_nullable_low']['bytes'] == 1840
    assert effective['assignment_scalar']['maximum_bytes'] == 7048
    assert effective['index_debug_bytes'] == 576
    done = datetime.now(timezone.utc)
    return dict(status='focused #218 repair check passed; exact independent review pending',
                complete_native_capacity_result=False,
                source_files=files, changed_source_spans=spans,
                bridge_profiles=profiles, copied_low_profiles=copies,
                maximum_tested_provider_depth=128, maximum_tested_event_arity=129,
                arbitrary_finite_C_argument='README source induction; finite profiles only corroborate',
                inherited_low_witnesses=witnesses,
                frontend_nullable_static_max_gate=False,
                positive_fixed_prefix_static_max_gate=True,
                original_scalar_coarse_per_C=7136,
                assignment_scalar_maximum=7048,index_debug=576,
                scalar_and_index_debug_coarse_per_C=23536,
                old_provider_files_unchanged=True,accepted_217_unchanged=True,
                predecessor_checkers_executed=False,old_graph_checkers_replayed=False,
                native_execution_seconds=0,generic_model_is_GCC_execution=False,
                selected_author_model='GPT-6 Astra',selected_author_effort='Extra High',
                runtime_model_effort_confirmation=None,tokens=None,monetary_cost=None,
                host=dict(system=platform.system(),machine=platform.machine(),node=platform.node()),
                completed_utc=done.isoformat(),
                check_elapsed_seconds=round(time.perf_counter()-start,6),
                elapsed_since_first_repair_clock_seconds=round((done-START).total_seconds(),6))


if __name__ == '__main__':
    ap = argparse.ArgumentParser()
    ap.add_argument('--output', type=Path)
    args = ap.parse_args()
    output = json.dumps(main(),indent=2)+'\n'
    if args.output:
        args.output.write_text(output)
    print(output,end='')
