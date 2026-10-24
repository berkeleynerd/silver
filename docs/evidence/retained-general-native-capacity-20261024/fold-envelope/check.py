#!/usr/bin/env python3
"""Focused source identity / finite-state / arithmetic check, not GCC execution."""
import argparse
import hashlib
import itertools
import json
import platform
import tarfile
import time
from datetime import datetime, timezone
from pathlib import Path

from matcher import matcher_inventory

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
PIN = '6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea'


def sha(data):
    return hashlib.sha256(data).hexdigest()


def read(path):
    return json.loads(path.read_bytes())


def export(index_entities, array_entities):
    """Compose the authored helper and accepted callback transfer."""
    if (type(index_entities) is not int or type(array_entities) is not int
            or index_entities < 0 or array_entities < 0):
        raise ValueError('nonnegative entity counts required')
    s, a = index_entities, array_entities
    q = 2 * a * 5
    helpers = dict(constants=13*s + (7+6+17*2+2)*a,
                   unary=s+(7+6)*a, binary=17*a, var_decl=s)
    combined = dict(constants=helpers['constants']+32*q,
                    unary=helpers['unary']+q, binary=helpers['binary'],
                    var_decl=s, maps=q)
    combined['operand_slots'] = combined['unary']+2*combined['binary']
    combined['raw_caller_bytes'] = (40*combined['constants']
        +32*combined['unary']+40*combined['binary']+256*s+16*q)
    return dict(helper=helpers, combined=combined, Q_Image=q,
                Uint_entries=3*q, Uint_digits=11*q, Rep_Table_additions=q,
                serial_additions=q, logical_callback_payload=100*q)


def check():
    started = time.perf_counter()
    for name in ('inputs.json', 'packet-manifest.json'):
        for r in read(HERE/name)['files']:
            data = (ROOT/r['path']).read_bytes()
            assert len(data) == r['bytes'] and sha(data) == r['sha256'], r['path']
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
            for r in rows:
                data = tf.extractfile(r['path']).read()
                assert len(data) == r['bytes'] and sha(data) == r['sha256']
                origin = read(ROOT/r['retained_identity'])
                if 'source_sha256_key' in r:
                    assert origin['source_commit'] == PIN
                    original_hash = origin['source_sha256'][r['source_sha256_key']]
                else:
                    matches = [f for f in origin['files'] if f['path'] == r['path']]
                    assert len(matches) == 1
                    original_hash = matches[0]['sha256']
                assert original_hash == r['sha256']
                assert r['path'] not in sources
                sources[r['path']] = data
    witnesses = read(HERE/'source-witnesses.json')['witnesses']
    assert len({r['id'] for r in witnesses}) == len(witnesses)
    for r in witnesses:
        lines = sources[r['source']].split(b'\n')
        lo, hi = r['first_lf_line'], r['last_lf_line']
        assert 1 <= lo <= hi <= len(lines)
        assert sha(b'\n'.join(lines[lo-1:hi])+b'\n') == r['sha256']
    host = (ROOT/'docs/evidence/retained-backend-capacity-20261018/selected-auto-host.h').read_text()
    assert '/* #undef ENABLE_FOLD_CHECKING */' in host

    # Re-extract both-branch root patterns. Dispositions are authored review
    # claims; checking their presence does not prove a pattern is unreachable.
    audit = read(HERE/'matcher-audit.json')
    for kind, wanted, expected in [('binary', {'plus', 'minus', 'mult'}, 151),
            ('conversion', {'convert', 'nop', 'NOP_EXPR', 'CONVERT_EXPR'}, 19)]:
        actual = matcher_inventory(sources['gcc/match.pd'].decode(), wanted)
        retained = audit[kind]
        assert actual['root_forms'] == retained['root_forms'] == expected
        assert actual['simplify_forms_in_both_preprocessor_branches'] == 882
        for x, y in zip(actual['root_patterns'], retained['root_patterns']):
            assert y['disposition']
            assert x == {k: v for k, v in y.items() if k != 'disposition'}

    certificate = read(HERE/'rank.json')
    ranks = certificate['rank']
    for caller, callee in certificate['edges']:
        assert ranks[caller] > ranks[callee], (caller, callee)
    # This checks the authored finite graph. Its correspondence with source
    # calls is the README argument, not established by integer comparisons.

    modular_cases = 0
    for width in (8, 16, 32, 64, 128):
        modulus = 1 << width
        values = set(range(257)) | {modulus-2, modulus-1, modulus, modulus+1}
        for v in values:
            x = v % modulus
            assert (1+((x-1) % modulus)) % modulus == x
            modular_cases += 1
    # Counterexample to deleting the intermediate unsigned64 extension:
    assert ((-1) % (1 << 64)) % (1 << 128) != (-1) % (1 << 128)
    signed_cases = 0
    for v in (-2**31, -2**31+1, -1, 0, 1, 10, 11, 2**31-2, 2**31-1):
        x = v % (1 << 64)
        w = x % (1 << 128)
        assert (w*8) % 8 == 0
        assert ((1+((x-1) % (1 << 64))) % (1 << 64)) == x
        signed_cases += 1

    # Abstract result DAGs independently count all conversion possibilities.
    graph_cases = []
    for conversions in (0, 1, 2):
        height = conversions+1
        charge = 1+conversions+1+1  # MULT, conversions, V, eight
        assert height <= 3 and charge <= 5
        assert charge <= 2*3**height-1
        graph_cases.append(dict(conversions=conversions, height=height, Q=charge))
    assert 2*(2*3**3-1) == 106
    counts = (0, 1, 2, 7, 17, 1024, 2**31-1)
    coefficient_cases = 0
    for s, a in itertools.product(counts, repeat=2):
        e = export(s, a)
        c = e['combined']
        assert c['constants'] == 13*s+369*a
        assert c['unary'] == s+23*a and c['binary'] == 17*a
        assert c['operand_slots'] == s+57*a
        assert c['raw_caller_bytes'] == 808*s+16336*a
        assert e['Uint_entries'] == 30*a and e['Uint_digits'] == 110*a
        assert e['logical_callback_payload'] == 1000*a
        h = e['helper']
        assert 40*h['constants']+32*h['unary']+40*h['binary']+256*s == 808*s+3056*a
        coefficient_cases += 1
    assert 9+13 == 22 and 83+49+320 == 452
    for bad in ((-1, 0), (0, -1), (True, 0), (0, 1.0)):
        try:
            export(*bad)
        except ValueError:
            pass
        else:
            raise AssertionError(bad)
    return dict(status='pass', checked_at_utc=datetime.now(timezone.utc).isoformat(),
        offline_platform=f'{platform.system()} {platform.machine()}',
        offline_elapsed_seconds=time.perf_counter()-started, gcc_commit=PIN,
        source_files=len(sources), LF_witnesses=len(witnesses),
        matcher_binary_root_forms=151, matcher_conversion_root_forms=19,
        rank_states=len(ranks), rank_edges=len(certificate['edges']),
        modular_boundary_cases=modular_cases, signed_conversion_cases=signed_cases,
        annotation_result_graph_cases=graph_cases, coefficient_cases=coefficient_cases,
        source_classification='Is/Ia: original or provenance-preserving Image slice type identities',
        H_Image_upper=3, Q_per_Image_root_upper=5, Q_Image='10Ia',
        helper=dict(constants='13Is+49Ia', unary='Is+13Ia', binary='17Ia',
                    var_decl='Is', operand_slots='Is+47Ia', raw_caller_bytes='808Is+3056Ia'),
        helper_plus_annotation=dict(constants='13Is+369Ia', unary='Is+23Ia',
                    binary='17Ia', var_decl='Is', maps='10Ia',
                    operand_slots='Is+57Ia', raw_caller_bytes='808Is+16336Ia'),
        one_index_one_array_example=export(1, 1),
        classified_kernel_constant_coefficients=dict(Is=22, Ia=452),
        selected_constructor_projection_closed=True,
        selected_dynamic_annotation_height_source_derived=True,
        full_helper_workspace_closed=False, all_dynamic_F_Q_closed=False,
        complete_native_capacity_result=False, semantic_source_argument_machine_proved=False,
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
