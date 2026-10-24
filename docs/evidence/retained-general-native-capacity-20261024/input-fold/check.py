#!/usr/bin/env python3
"""Focused input-bound source/certificate/arithmetic check; no GCC execution."""
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
# Reuse only the frozen lexical parser, without invoking its checker or
# writing bytecode into a predecessor packet.
sys.dont_write_bytecode = True
sys.path.insert(0, str(HERE.parent/'fold-envelope'))
from matcher import matcher_inventory


def sha(data):
    return hashlib.sha256(data).hexdigest()


def read(path):
    return json.loads(path.read_bytes())


def export(index_entities, array_entities):
    """Compose the authored ledger with the accepted callback transfer."""
    if (type(index_entities) is not int or type(array_entities) is not int
            or index_entities < 0 or array_entities < 0):
        raise ValueError('nonnegative integer entity counts required')
    s, a = index_entities, array_entities
    ledger = read(HERE/'ledger.json')
    h = {key: value*s for key, value in ledger['index_per_Bs'].items()}
    for row in ledger['array_rows']:
        for key, value in row['per_entry'].items():
            h[key] += row['entries_per_Ba']*value*a
    q = 2*a*15
    combined = dict(h, constants=h['constants']+32*q,
                    unary=h['unary']+q, maps=q)

    def project(vector):
        vector['operand_slots'] = (vector['unary']+2*vector['binary']
                                   +3*vector['ternary'])
        vector['raw_caller_bytes'] = sum(
            vector.get(key, 0)*size for key, size in ledger['raw_bytes'].items())
    project(h)
    project(combined)
    return dict(helper=h, combined=combined, Q_Input=q,
                Uint_entries=3*q, Uint_digits=11*q, Rep_Table_additions=q,
                serial_additions=q, logical_callback_payload=100*q)


def template_export(invocations):
    if type(invocations) is not int or invocations < 0:
        raise ValueError('nonnegative integer invocation count required')
    ledger = read(HERE/'ledger.json')
    result = {k: v*invocations for k, v in ledger['template_per_Db'].items()}
    result['raw_caller_bytes'] = sum(
        result[k]*v for k, v in ledger['template_raw_bytes'].items())
    requests = result['unary']+result['constructor']+result['element_vector']
    result['rounded_request_bytes'] = (
        requests*ledger['template_rounded_bytes_per_request'])
    return result


def arithmetic_case(low, high, scalar_width, size_width, bit_width):
    """Compare the source arithmetic stages to the conditional normal form."""
    assert -(1 << (scalar_width-1)) <= low < 1 << (scalar_width-1)
    assert -(1 << (scalar_width-1)) <= high < 1 << (scalar_width-1)
    assert scalar_width < size_width < bit_width
    modulus, wide_modulus = 1 << size_width, 1 << bit_width
    x, y = low % modulus, high % modulus
    c = high >= low
    z = y if c else (x-1) % modulus
    d = (z-x) % modulus
    distributed_d = (y-x) % modulus if c else modulus-1
    assert d == distributed_d
    n = (1+d) % modulus
    distributed_n = ((y-x+1) % modulus) if c else 0
    assert n == distributed_n == max(0, high-low+1)
    w = n % wide_modulus
    bits = (8*w) % wide_modulus
    distributed_bits = (8*((y-x+1) % modulus)) % wide_modulus if c else 0
    assert bits == distributed_bits
    assert bits == 8*max(0, high-low+1)
    assert bits % 8 == 0


def annotation_graph(conditional):
    # Topological order is part of the certificate. IDs, not Python object
    # identity or equality of runtime values, determine sharing.
    nodes = [
        ('L', 'VAR_DECL', ()), ('H', 'VAR_DECL', ()),
        ('X', 'NOP', ('L',)), ('Y', 'NOP', ('H',)),
        ('C', 'GE', ('H', 'L')), ('D', 'MINUS', ('Y', 'X')),
        ('one', 'INTEGER_CST', ()), ('N', 'PLUS', ('D', 'one')),
        ('W', 'NOP', ('N',)), ('eight', 'INTEGER_CST', ()),
        ('bits', 'MULT', ('W', 'eight')), ('zero', 'INTEGER_CST', ()),
    ]
    if conditional:
        nodes.append(('result', 'COND', ('C', 'bits', 'zero')))
    root = 'result' if conditional else 'bits'
    graph, heights = {}, {}
    for name, code, operands in nodes:
        assert name not in graph
        assert all(operand in graph for operand in operands)
        graph[name] = (code, operands)
        heights[name] = max((heights[o]+1 for o in operands), default=0)
    retries = 0

    def weight(name):
        nonlocal retries
        code, operands = graph[name]
        base = 1+sum(weight(o) for o in operands)
        # Accepted converted-inner failed retry applies only to matching
        # PLUS/MULT code below a conversion of the left operand.
        if code in ('PLUS', 'MULT'):
            left_code, left_ops = graph[operands[0]]
            if left_code == 'NOP' and graph[left_ops[0]][0] == code:
                retries += 1
                base += weight(left_ops[0])
        return base

    charge = weight(root)
    assert retries == 0

    def reachable(name):
        result = {name}
        for operand in graph[name][1]:
            result |= reachable(operand)
        return result
    return dict(conditional=conditional, height=heights[root], Q=charge,
                distinct_vertices=len(reachable(root)),
                annotation_active_depth=heights[root]+1,
                converted_inner_retries=retries)


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
        ap = HERE/archive['path']
        assert sha(ap.read_bytes()) == archive['sha256']
        rows = [r for r in manifest['files'] if r['archive'] == archive['path']]
        with tarfile.open(ap, 'r:gz') as tf:
            members = tf.getmembers()
            assert all(m.isfile() for m in members)
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

    inventory = [
        ('binary', {'plus', 'minus', 'mult'}, 151),
        ('conversion', {'convert', 'nop', 'NOP_EXPR', 'CONVERT_EXPR'}, 19),
        ('conditional', {'cond'}, 65), ('comparison', {'ge'}, 52)]
    audit = read(HERE/'matcher-audit.json')
    for kind, wanted, expected in inventory:
        actual = matcher_inventory(sources['gcc/match.pd'].decode(), wanted)
        retained = audit[kind]
        assert actual['root_forms'] == retained['root_forms'] == expected
        assert actual['simplify_forms_in_both_preprocessor_branches'] == 882
        assert len(actual['root_patterns']) == len(retained['root_patterns'])
        for x, y in zip(actual['root_patterns'], retained['root_patterns']):
            assert y['disposition']
            assert x == {k: v for k, v in y.items() if k != 'disposition'}
    # Dispositions and source correspondence remain authored review claims.
    certificate = read(HERE/'rank.json')
    ranks = certificate['rank']
    assert len(certificate['edges']) == len({tuple(e) for e in certificate['edges']})
    for caller, callee in certificate['edges']:
        assert ranks[caller] > ranks[callee], (caller, callee)

    reduced_cases = 0
    for low, high in itertools.product(range(-128, 128), repeat=2):
        arithmetic_case(low, high, 8, 16, 32)
        reduced_cases += 1
    boundary_values = [
        -2**31, -2**31+1, -2**31+2, -65537, -65536, -257, -256,
        -2, -1, 0, 1, 2, 255, 256, 65535, 65536,
        2**31-3, 2**31-2, 2**31-1]
    boundary_cases = 0
    for low, high in itertools.product(boundary_values, repeat=2):
        arithmetic_case(low, high, 32, 64, 128)
        boundary_cases += 1
    assert 0 >= -1 and not (0 % 2**64 >= (-1) % 2**64)
    assert 2*3**6-1 == 1457 and 2*(2*3**6-1) == 2914

    graphs = [annotation_graph(False), annotation_graph(True)]
    assert [(g['height'], g['Q']) for g in graphs] == [(5, 10), (6, 15)]
    assert graphs[1]['distinct_vertices'] == 13
    assert sum(graphs[1]['Q'] for _ in range(2)) == 30
    assert all(g['Q'] <= 2*3**g['height']-1 for g in graphs)

    counts = (0, 1, 2, 7, 17, 1024, 2**31-1)
    coefficient_cases = 0
    for s, a in itertools.product(counts, repeat=2):
        e = export(s, a)
        h, c = e['helper'], e['combined']
        assert h['constants'] == 49*a and h['unary'] == 2*s+34*a
        assert h['binary'] == 18*a and h['ternary'] == 24*a
        assert h['var_decl'] == 2*s and h['operand_slots'] == 2*s+142*a
        assert h['raw_caller_bytes'] == 576*s+4920*a
        assert c['constants'] == 1009*a and c['unary'] == 2*s+64*a
        assert c['operand_slots'] == 2*s+172*a
        assert c['raw_caller_bytes'] == 576*s+44760*a
        assert e['Uint_entries'] == 90*a and e['Uint_digits'] == 330*a
        assert e['logical_callback_payload'] == 3000*a
        assert e['Q_Input'] == 30*a
        coefficient_cases += 1
    assert 83+49+960 == 1092
    # Linearity preserves occurrence multiplicity, including zero subsets.
    for s, a in ((0, 0), (1, 2), (17, 1024)):
        e0, e1, es = export(s, a), export(2, 7), export(s+2, a+7)
        for kind in ('helper', 'combined'):
            for field in es[kind]:
                assert es[kind][field] == e0[kind][field]+e1[kind][field]
    for d in counts:
        t = template_export(d)
        assert t['raw_caller_bytes'] == 160*d
        assert t['rounded_request_bytes'] == 2048*d
        assert t['stored_elements'] == 2*d and t['unary'] == 2*d
        assert t['constants'] == 0
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

    return dict(
        status='pass', checked_at_utc=datetime.now(timezone.utc).isoformat(),
        offline_platform=f'{platform.system()} {platform.machine()}',
        offline_elapsed_seconds=time.perf_counter()-started, gcc_commit=PIN,
        source_files=len(sources), LF_witnesses=len(witnesses),
        matcher_root_forms={kind: expected for kind, _, expected in inventory},
        rank_states=len(ranks), rank_edges=len(certificate['edges']),
        reduced_signed_exhaustive_cases=reduced_cases,
        signed32_boundary_cases=boundary_cases,
        annotation_result_graph_cases=graphs, coefficient_cases=coefficient_cases,
        template_coefficient_cases=len(counts),
        source_classification='Bs/Ba: initial-input or exact-provenance-preserving type identities',
        H_Input_upper=6, Q_per_Input_root_upper=15, Q_Input='30Ba',
        helper=dict(constants='49Ba', unary='2Bs+34Ba', binary='18Ba',
                    ternary='24Ba', var_decl='2Bs', operand_slots='2Bs+142Ba',
                    raw_caller_bytes='576Bs+4920Ba'),
        helper_plus_annotation=dict(constants='1009Ba', unary='2Bs+64Ba',
                    binary='18Ba', ternary='24Ba', var_decl='2Bs', maps='30Ba',
                    operand_slots='2Bs+172Ba', raw_caller_bytes='576Bs+44760Ba'),
        one_index_one_array_example=export(1, 1),
        classified_kernel_constant_coefficients=dict(Bs=9, Ba=1092),
        dynamic_template=dict(caller_attachment='Db<=8Pb<=8V_Main',
                    one_invocation=template_export(1),
                    raw_caller_bytes='160Db', rounded_request_bytes='2048Db'),
        selected_constructor_projection_closed=True,
        selected_dynamic_annotation_height_source_derived=True,
        selected_bounds_template_subcall_closed=True,
        full_helper_workspace_closed=False, enclosing_fat_pointer_closed=False,
        concat_initializer_transfer_closed=False, all_dynamic_F_Q_closed=False,
        complete_native_capacity_result=False,
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
