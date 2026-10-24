#!/usr/bin/env python3
"""Offline source/certificate/arithmetic checks for the concat-prefix unit."""
import argparse
import hashlib
import itertools
import json
import platform
import sys
import tarfile
import time
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
PIN = '6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea'
sys.dont_write_bytecode = True
sys.path.insert(0, str(HERE.parent/'fold-envelope'))
from matcher import matcher_inventory


def sha(data):
    return hashlib.sha256(data).hexdigest()


def read(path):
    return json.loads(path.read_bytes())


def export(index_entities, array_entities):
    if (type(index_entities) is not int or type(array_entities) is not int
            or min(index_entities, array_entities) < 0):
        raise ValueError('nonnegative integer entity counts required')
    ledger = read(HERE/'ledger.json')
    h = dict(constants=0, unary=0, binary=0, var_decl=0)
    for family, label, count in [('index_rows', 'entries_per_Cs', index_entities),
                                  ('array_rows', 'entries_per_Ca', array_entities)]:
        for row in ledger[family]:
            for key, value in row['per_entry'].items():
                h[key] += count*row[label]*value
    q = 2*array_entities*5
    c = dict(h, constants=h['constants']+32*q, unary=h['unary']+q, maps=q)
    for vector in (h, c):
        vector['operand_slots'] = vector['unary']+2*vector['binary']
        vector['raw_caller_bytes'] = sum(
            vector.get(key, 0)*size for key, size in ledger['raw_bytes'].items())
    return dict(helper=h, combined=c, Q_ConcatPrefix=q,
                Uint_entries=3*q, Uint_digits=11*q, Rep_Table_additions=q,
                serial_additions=q, logical_callback_payload=100*q)


def template_export(invocations):
    if type(invocations) is not int or invocations < 0:
        raise ValueError('nonnegative integer invocation count required')
    ledger = read(HERE/'ledger.json')
    result = {k: v*invocations for k, v in ledger['template_per_Dg'].items()}
    result['raw_caller_bytes'] = sum(
        result[k]*v for k, v in ledger['template_raw_bytes'].items())
    requests = sum(result[k] for k in ('constants', 'unary', 'constructor', 'element_vector'))
    result['rounded_request_bytes'] = requests*ledger['template_rounded_bytes_per_request']
    return result


def maximum_query(node, maximum=True, width=32):
    """Model only the proved CONST/VAR/PLUS maximum-query subgrammar."""
    minimum, upper = -(1 << (width-1)), (1 << (width-1))-1
    code = node['code']
    if code == 'CONST':
        return dict(value=node['value'], overflow=False, requests=0, activations=1)
    if code == 'VAR':
        # The initializer is deliberately not inspected.
        return dict(value=upper if maximum else minimum, overflow=False,
                    requests=1, activations=1)
    assert code == 'PLUS'
    left = maximum_query(node['operands'][0], maximum, width)
    right = maximum_query(node['operands'][1], maximum, width)
    exact = left['value']+right['value']
    wrapped = (exact-minimum) % (1 << width)+minimum
    return dict(value=wrapped, overflow=not minimum <= exact <= upper,
                requests=1+left['requests']+right['requests'],
                activations=1+left['activations']+right['activations'])


def check():
    started = time.perf_counter()
    for name in ('inputs.json', 'packet-manifest.json'):
        for row in read(HERE/name)['files']:
            data = (ROOT/row['path']).read_bytes()
            assert len(data) == row['bytes'] and sha(data) == row['sha256'], row['path']
    manifest = read(HERE/'source-manifest.json')
    assert manifest['gcc_commit'] == PIN
    sources = {}
    for archive in manifest['archives']:
        path = HERE/archive['path']
        assert sha(path.read_bytes()) == archive['sha256']
        rows = [r for r in manifest['files'] if r['archive'] == archive['path']]
        with tarfile.open(path, 'r:gz') as tf:
            members = tf.getmembers()
            assert all(member.isfile() for member in members)
            assert len(members) == len(rows)
            assert {m.name for m in members} == {r['path'] for r in rows}
            for row in rows:
                data = tf.extractfile(row['path']).read()
                assert len(data) == row['bytes'] and sha(data) == row['sha256']
                origin = read(ROOT/row['retained_identity'])
                if 'source_sha256_key' in row:
                    assert origin['source_commit'] == PIN
                    original_hash = origin['source_sha256'][row['source_sha256_key']]
                else:
                    matches = [f for f in origin['files'] if f['path'] == row['path']]
                    assert len(matches) == 1
                    original_hash = matches[0]['sha256']
                assert original_hash == row['sha256']
                assert row['path'] not in sources
                sources[row['path']] = data
    witnesses = read(HERE/'source-witnesses.json')['witnesses']
    assert len({r['id'] for r in witnesses}) == len(witnesses)
    for row in witnesses:
        lines = sources[row['source']].split(b'\n')
        lo, hi = row['first_lf_line'], row['last_lf_line']
        assert 1 <= lo <= hi <= len(lines)
        assert sha(b'\n'.join(lines[lo-1:hi])+b'\n') == row['sha256']
    host = (ROOT/'docs/evidence/retained-backend-capacity-20261018/selected-auto-host.h').read_text()
    assert '/* #undef ENABLE_FOLD_CHECKING */' in host

    audit = read(HERE/'matcher-audit.json')
    for kind, wanted, expected in [('binary', {'plus', 'minus', 'mult'}, 151),
            ('conversion', {'convert', 'nop', 'NOP_EXPR', 'CONVERT_EXPR'}, 19)]:
        actual = matcher_inventory(sources['gcc/match.pd'].decode(), wanted)
        retained = audit[kind]
        assert actual['root_forms'] == retained['root_forms'] == expected
        assert actual['simplify_forms_in_both_preprocessor_branches'] == 882
        assert len(actual['root_patterns']) == len(retained['root_patterns'])
        for actual_row, retained_row in zip(actual['root_patterns'], retained['root_patterns']):
            assert retained_row['disposition']
            assert actual_row == {k: v for k, v in retained_row.items() if k != 'disposition'}
    # Disposition and source-correspondence claims require semantic review.
    rank = read(HERE/'rank.json')
    assert len(rank['edges']) == len({tuple(e) for e in rank['edges']})
    for caller, callee in rank['edges']:
        assert rank['rank'][caller] > rank['rank'][callee]

    signed_cases = 0
    for width, values in [
            (8, range(-128, 128)),
            (32, (-2**31, -2**31+1, -65536, -257, -2, -1, 0, 1, 2, 7, 8,
                  11, 12, 255, 256, 65536, 2**31-2, 2**31-1))]:
        minimum = -(1 << (width-1))
        wrap = lambda v: (v-minimum) % (1 << width)+minimum
        for g in values:
            # Actual new stage: source signed high normalization before
            # the already accepted unsigned layout identity is attached.
            assert wrap(1+wrap(g-1)) == g
            if g > minimum:
                assert 1+(g-1) == g  # defined signed arithmetic subdomain
            x = g % (1 << 64)
            assert (1+((x-1) % (1 << 64))) % (1 << 64) == x
            assert (8*x) % 8 == 0
            signed_cases += 1
    assert (-1) % (1 << 64) != (-1) % (1 << 128)

    a, b = dict(code='VAR', name='A'), dict(code='VAR', name='B')
    lit = lambda v: dict(code='CONST', value=v)
    plus = lambda l, r: dict(code='PLUS', operands=(l, r))
    query_shapes = [a, plus(a, b), plus(lit(7), b), plus(a, lit(0)),
                    plus(a, lit(1)), plus(a, lit(2**31-1))]
    maximum_cases = 0
    for node, maximum in itertools.product(query_shapes, (False, True)):
        result = maximum_query(node, maximum)
        assert result['requests'] <= 3 and result['activations'] <= 3
        fallback = (2**31-1) if maximum else -2**31
        chosen = fallback if result['overflow'] else result['value']
        assert -2**31 <= chosen < 2**31
        maximum_cases += 1
    assert maximum_query(plus(a, b), True)['overflow']
    assert maximum_query(plus(a, b), False)['overflow']
    assert not maximum_query(plus(lit(7), b), False)['overflow']

    # Construct long acyclic capture chains, retaining initializers. Querying
    # the final PLUS does not follow any earlier declaration initializer.
    chain_cases = []
    for operands in (2, 3, 7, 31, 1024):
        previous = lit(7)
        for index in range(1, operands):
            length = dict(code='VAR', name=f'V{index}', initializer=lit(index))
            initializer = plus(previous, length)
            previous = dict(code='VAR', name=f'G{index}', initializer=initializer)
        result = maximum_query(previous['initializer'])
        assert result['requests'] <= 3 and result['activations'] <= 3
        chain_cases.append(dict(operands=operands, requests=result['requests'],
                                activations=result['activations']))

    # This is a source-helper counterexample, not a claim of Main reachability.
    c0, c1 = lit(0), lit(1)
    selector = dict(code='COND', condition='synthetic', arms=(c0, c1))
    mapped_arms = tuple(arm for arm in selector['arms'])  # CONST returns unchanged
    unchanged = all(x is y for x, y in zip(mapped_arms, selector['arms']))
    returned = selector if unchanged else None
    assert returned is selector

    graphs = []
    for conversions in (0, 1, 2):
        h, q = conversions+1, conversions+3
        assert h <= 3 and q <= 5 and q <= 2*3**h-1
        graphs.append(dict(conversions=conversions, height=h, Q=q))
    counts = (0, 1, 2, 7, 17, 1024, 2**31-1)
    coefficient_cases = 0
    for s, a in itertools.product(counts, repeat=2):
        e = export(s, a)
        h, c = e['helper'], e['combined']
        assert h['constants'] == 43*s+53*a
        assert h['unary'] == 3*s+13*a and h['binary'] == 2*s+17*a
        assert h['operand_slots'] == 7*s+47*a
        assert h['raw_caller_bytes'] == 2152*s+3216*a
        assert c['constants'] == 43*s+373*a
        assert c['unary'] == 3*s+23*a and c['binary'] == 2*s+17*a
        assert c['operand_slots'] == 7*s+57*a
        assert c['raw_caller_bytes'] == 2152*s+16496*a
        assert e['Q_ConcatPrefix'] == 10*a
        assert e['Uint_entries'] == 30*a and e['Uint_digits'] == 110*a
        assert e['logical_callback_payload'] == 1000*a
        coefficient_cases += 1
    assert 9+43 == 52 and 83+53+320 == 456
    for s, a in ((0, 0), (1, 2), (17, 1024)):
        e0, e1, es = export(s, a), export(2, 7), export(s+2, a+7)
        for kind in ('helper', 'combined'):
            for field in es[kind]:
                assert es[kind][field] == e0[kind][field]+e1[kind][field]
    for d in counts:
        template = template_export(d)
        assert template['raw_caller_bytes'] == 168*d
        assert template['rounded_request_bytes'] == 2048*d
        assert template['constants'] == template['unary'] == d
    for bad in ((-1, 0), (0, -1), (True, 0), (0, 1.0)):
        try:
            export(*bad)
        except ValueError:
            pass
        else:
            raise AssertionError(bad)
    for bad in (-1, True, 1.0):
        try:
            template_export(bad)
        except ValueError:
            pass
        else:
            raise AssertionError(bad)

    remaining = read(HERE/'remaining.json')
    assert not remaining['complete_native_capacity_result']
    assert {r['id'] for r in remaining['initializer_inventory']} == {
        'operand_length', 'aggregate_plus', 'selected_low', 'nonnull_high',
        'null_bound_selectors', 'forced_actions'}
    sample = (ROOT/'samples/command_line_greeting.adb').read_text()
    assert '"Hello, " & Name & "!"' in sample
    assert 'Name : constant String := Silver_Arguments.First_Or_Default ("world");' in sample

    return dict(
        status='pass', checked_at_utc=datetime.now(timezone.utc).isoformat(),
        offline_platform=f'{platform.system()} {platform.machine()}',
        offline_elapsed_seconds=time.perf_counter()-started, gcc_commit=PIN,
        source_files=len(sources), LF_witnesses=len(witnesses),
        matcher_binary_root_forms=151, matcher_conversion_root_forms=19,
        rank_states=len(rank['rank']), rank_edges=len(rank['edges']),
        signed_high_normalization_cases=signed_cases,
        maximum_query_cases=maximum_cases, maximum_query_capture_chains=chain_cases,
        unchanged_conditional_helper_counterexample=True,
        counterexample_Main_reachability_claim=False,
        annotation_result_graph_cases=graphs, coefficient_cases=coefficient_cases,
        template_coefficient_cases=len(counts),
        source_classification='Cs/Ca: selected nonnull low1 concat allocation identities with accepted seed providers and preserved frontend flag',
        H_ConcatPrefix_upper=3, Q_per_ConcatPrefix_root_upper=5,
        Q_ConcatPrefix='10Ca',
        helper=dict(constants='43Cs+53Ca', unary='3Cs+13Ca', binary='2Cs+17Ca',
                    var_decl='Cs', operand_slots='7Cs+47Ca',
                    raw_caller_bytes='2152Cs+3216Ca'),
        helper_plus_annotation=dict(constants='43Cs+373Ca', unary='3Cs+23Ca',
                    binary='2Cs+17Ca', var_decl='Cs', maps='10Ca',
                    operand_slots='7Cs+57Ca', raw_caller_bytes='2152Cs+16496Ca'),
        one_index_one_array_example=export(1, 1),
        classified_kernel_constant_coefficients=dict(Cs=52, Ca=456),
        mixed_template=dict(caller_attachment='Dg<=8Pg<=8V_Main',
                    one_invocation=template_export(1),
                    raw_caller_bytes='168Dg', rounded_request_bytes='2048Dg'),
        source_applicability_example='samples/command_line_greeting.adb:10; source argument only, not a universal test or native run',
        selected_constructor_projection_closed=True,
        immediate_aggregate_maximum_query_closed=True,
        selected_dynamic_annotation_height_source_derived=True,
        selected_bounds_template_subcall_closed=True,
        full_concat_family_closed=False, selected_low_null_selector_closed=False,
        full_helper_workspace_closed=False, enclosing_fat_pointer_closed=False,
        all_dynamic_F_Q_closed=False, complete_native_capacity_result=False,
        semantic_source_argument_machine_proved=False,
        compiler_prover_runs=0, native_target_runs=0, predecessor_checker_replays=0,
        selected_author_model='GPT-6 Astra', selected_author_effort='Extra High',
        runtime_model_and_effort=None, total_author_elapsed_seconds=None,
        tokens=None, cost=None, independent_review='pending')


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    result = check()
    output = json.dumps(result, indent=2)+'\n'
    if args.write:
        (HERE/'current.json').write_text(output)
    print(output, end='')
