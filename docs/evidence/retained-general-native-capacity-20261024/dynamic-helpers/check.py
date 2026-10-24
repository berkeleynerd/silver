#!/usr/bin/env python3
"""Pinned-source arithmetic for the #201 dynamic annotation transfer.

This is neither a native replay nor a proof of the missing FoldEnvelope.
The source argument and correspondence still require independent review.
"""
import argparse
import hashlib
import itertools
import json
import platform
import random
import re
import tarfile
import time
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
PIN = '6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea'
CUTS = {'INTEGER_CST', 'VAR_DECL', 'PARM_DECL', 'COMPONENT_REF', 'CALL_EXPR'}
UNARY = {'NOP_EXPR', 'CONVERT_EXPR', 'NON_LVALUE_EXPR', 'NEGATE_EXPR',
         'ABS_EXPR', 'TRUTH_NOT_EXPR'}
BINARY = {'MINUS_EXPR', 'TRUNC_DIV_EXPR', 'CEIL_DIV_EXPR', 'FLOOR_DIV_EXPR',
          'TRUNC_MOD_EXPR', 'CEIL_MOD_EXPR', 'FLOOR_MOD_EXPR', 'EXACT_DIV_EXPR',
          'MIN_EXPR', 'MAX_EXPR', 'TRUTH_ANDIF_EXPR', 'TRUTH_AND_EXPR',
          'TRUTH_ORIF_EXPR', 'TRUTH_OR_EXPR', 'TRUTH_XOR_EXPR', 'LT_EXPR',
          'LE_EXPR', 'GT_EXPR', 'GE_EXPR', 'EQ_EXPR', 'NE_EXPR', 'PLUS_EXPR',
          'MULT_EXPR', 'BIT_AND_EXPR'}
HANDLED = UNARY | BINARY | {'COND_EXPR'}


def sha(data):
    return hashlib.sha256(data).hexdigest()


def read_json(path):
    return json.loads(path.read_bytes())


def charge(height):
    assert height >= 0
    return 2 * 3 ** height - 1


def charge_capped(height, cap):
    """Exactly min(2*3**height-1, cap+1), without the large exponential."""
    if height < 0 or cap < 0:
        raise ValueError('height and cap must be nonnegative')
    ceiling = cap + 1
    result, factor, exponent = 1, min(3, ceiling), height
    while exponent:
        if exponent & 1:
            result = min(result * factor, ceiling)
        exponent //= 2
        if exponent:
            factor = min(factor * factor, ceiling)
    return min(2 * result - 1, ceiling)


def sum_capped(roots, cap):
    """roots contains (occurrence multiplicity, certified height) pairs."""
    if cap < 0:
        raise ValueError('cap must be nonnegative')
    result = 0
    for multiplicity, height in roots:
        if multiplicity < 0:
            raise ValueError('multiplicity must be nonnegative')
        result = min(cap + 1,
                     result + multiplicity * charge_capped(height, cap))
    return result


def graph_weights(nodes):
    """Conservative Q and height on an explicitly ordered synthetic DAG.

    Node = (GCC code, tuple of earlier child indices, constant sign-bit flag).
    This evaluates the mathematical recurrence, not actual GCC behavior.
    Unsupported codes are cuts. Shared operand occurrences are charged again.
    """
    heights, weights = [], []
    for index, (code, children, sign_bit) in enumerate(nodes):
        assert all(0 <= child < index for child in children)
        if code not in HANDLED:
            height, weight = 0, 1
        else:
            arity = 1 if code in UNARY else 3 if code == 'COND_EXPR' else 2
            assert len(children) == arity
            height = 1 + max(heights[c] for c in children)
            weight = 1 + sum(weights[c] for c in children)
            if code in {'PLUS_EXPR', 'MULT_EXPR', 'BIT_AND_EXPR'}:
                left, right = children
                constant_right = nodes[right][0] == 'INTEGER_CST'
                if code == 'BIT_AND_EXPR' and constant_right:
                    weight += 2
                elif code == 'PLUS_EXPR' and constant_right and nodes[right][2]:
                    weight += 1
                elif (code in {'PLUS_EXPR', 'MULT_EXPR'} and constant_right
                      and nodes[left][0] in {'NOP_EXPR', 'CONVERT_EXPR'}):
                    inner = nodes[left][1][0]
                    if (nodes[inner][0] == code
                            and nodes[nodes[inner][1][1]][0] == 'INTEGER_CST'):
                        weight += weights[nodes[inner][1][0]] + 1
        heights.append(height)
        weights.append(weight)
        assert weight <= charge(height), (index, code, height, weight)
    return heights, weights


def check():
    started = time.perf_counter()
    for manifest_name in ('inputs.json', 'packet-manifest.json'):
        for row in read_json(HERE / manifest_name)['files']:
            data = (ROOT / row['path']).read_bytes()
            assert len(data) == row['bytes'], row['path']
            assert sha(data) == row['sha256'], row['path']

    manifest = read_json(HERE / 'source-manifest.json')
    assert manifest['gcc_commit'] == PIN
    sources = {}
    for archive_row in manifest['archives']:
        archive_path = HERE / archive_row['path']
        assert sha(archive_path.read_bytes()) == archive_row['sha256']
        rows = [r for r in manifest['files'] if r['archive'] == archive_row['path']]
        with tarfile.open(archive_path, 'r:gz') as archive:
            members = archive.getmembers()
            assert all(m.isfile() for m in members)
            assert len(members) == len(rows)
            assert {m.name for m in members} == {r['path'] for r in rows}
            for row in rows:
                data = archive.extractfile(row['path']).read()
                assert len(data) == row['bytes']
                assert sha(data) == row['sha256'], row['path']
                origin = read_json(ROOT / row['retained_identity'])
                matches = [r for r in origin['files'] if r['path'] == row['path']]
                assert len(matches) == 1 and matches[0]['sha256'] == row['sha256']
                assert row['path'] not in sources
                sources[row['path']] = data

    witnesses = read_json(HERE / 'source-witnesses.json')['witnesses']
    assert len({w['id'] for w in witnesses}) == len(witnesses)
    for row in witnesses:
        lines = sources[row['source']].split(b'\n')
        lo, hi = row['first_lf_line'], row['last_lf_line']
        assert 1 <= lo <= hi <= len(lines)
        assert sha(b'\n'.join(lines[lo - 1:hi]) + b'\n') == row['sha256']

    decl = sources['gcc/ada/gcc-interface/decl.cc'].decode()
    body = decl.split('annotate_value (tree gnu_size)\n{', 1)[1].split(
        '\n/* Given GNAT_ENTITY, an object', 1)[0]
    cases = set(re.findall(r'^\s*case ([A-Z_]+)\s*:', body, re.M))
    assert cases | {'NOP_EXPR', 'CONVERT_EXPR'} == HANDLED | CUTS
    assert 'case SAVE_EXPR' not in body
    tree_defs = {
        code: (kind, int(arity))
        for code, kind, arity in re.findall(
            r'DEFTREECODE\s*\(\s*(\w+),\s*"[^"]+",\s*(\w+),\s*(\d+)\)',
            sources['gcc/tree.def'].decode())}
    assert all(tree_defs[c][1] == 1 for c in UNARY)
    assert all(tree_defs[c][1] == 2 for c in BINARY)
    assert tree_defs['COND_EXPR'] == ('tcc_expression', 3)
    assert max(tree_defs[c][1] for c in HANDLED) == 3
    assert 'if (List_Representation_Info >= 3 || type_annotate_only)' in body
    assert 'ops[0] = annotate_value (TREE_OPERAND (inner_op, 0));' in body
    assert 'ops[1] = annotate_value (build1 (NEGATE_EXPR, sizetype, op1));' in body

    current_static = read_json(HERE.parent / 'helper-joins/current.json')
    assert current_static['repaired_general_C'] == [9, 83, 42, 12]
    assert current_static['classified_with_annotation_C'] == [35, 188, 150, 12]
    assert current_static['dynamic_F_closed'] is False
    assert current_static['dynamic_Q_closed'] is False

    # Finite checks corroborate the README's all-height induction, not replace it.
    induction_cases = 0
    for h in range(1, 129):
        prev, bound = charge(h - 1), charge(h)
        assert bound == 3 * prev + 2
        for candidate in (1 + 3 * prev, 2 + 3 * prev, 3 + prev, 4 + prev):
            assert candidate <= bound
            induction_cases += 1
    height_combinations = 0
    for arity in range(1, 4):
        for child_heights in itertools.product(range(9), repeat=arity):
            assert 1 + sum(map(charge, child_heights)) <= charge(
                1 + max(child_heights))
            height_combinations += 1

    # Synthetic DAGs use sharing and all special Q branches, not native samples.
    nodes = [('UNSUPPORTED', (), False), ('INTEGER_CST', (), False),
             ('INTEGER_CST', (), True), ('VAR_DECL', (), False)]
    generator = random.Random(201119)
    for _ in range(2048):
        mode = generator.randrange(7)
        left = generator.randrange(len(nodes))
        if mode == 0:
            nodes.append(('COND_EXPR', (left, left, left), False))
        elif mode == 1:
            nodes.append(('BIT_AND_EXPR', (left, 2), False))
        elif mode == 2:
            nodes.append(('PLUS_EXPR', (left, 2), False))
        elif mode == 3:
            nodes.append(('MINUS_EXPR', (left, generator.randrange(len(nodes))), False))
        elif mode == 4:
            nodes.append(('NOP_EXPR', (left,), False))
        elif mode == 5:
            code = generator.choice(('PLUS_EXPR', 'MULT_EXPR'))
            nodes.append((code, (left, 1), False))
            nodes.append(('CONVERT_EXPR', (len(nodes) - 1,), False))
            nodes.append((code, (len(nodes) - 1, 1), False))
        else:
            # SAVE is a cut despite a nonempty hidden expression.
            nodes.append(('SAVE_EXPR', (left,), False))
    heights, weights = graph_weights(nodes)

    retry_nodes = [('UNSUPPORTED', (), False), ('INTEGER_CST', (), False)]
    retry_roots = [0]
    expected = 1
    for level in range(1, 17):
        retry_nodes.append(('MULT_EXPR', (retry_roots[-1], 1), False))
        retry_nodes.append(('NOP_EXPR', (len(retry_nodes) - 1,), False))
        retry_nodes.append(('MULT_EXPR', (len(retry_nodes) - 1, 1), False))
        retry_roots.append(len(retry_nodes) - 1)
        hs, qs = graph_weights(retry_nodes)
        expected = 2 * expected + 6
        assert hs[-1] == 3 * level and qs[-1] == expected
    # Equal-size actual MINUS-to-PLUS rule disproves a *strict* size-only rank.
    request_minus = ('MINUS_EXPR', ('dynamic_L', 'constant_one'))
    request_plus = ('PLUS_EXPR', ('dynamic_L', 'constant_minus_one'))
    assert 1 + len(request_minus[1]) == 1 + len(request_plus[1]) == 3

    saturation_cases = 0
    caps = sorted(set(range(32)) | {2**n - 1 for n in range(1, 129)})
    for h, cap in itertools.product(range(129), caps):
        assert charge_capped(h, cap) == min(charge(h), cap + 1)
        saturation_cases += 1
    for h in range(32):
        for cap in (max(0, charge(h) - 1), charge(h), charge(h) + 1):
            assert charge_capped(h, cap) == min(charge(h), cap + 1)
            saturation_cases += 1
    huge_height = 1 << 256
    assert charge_capped(huge_height, 2**31 - 1) == 2**31
    assert charge_capped(huge_height, 0) == 1
    family_sum_checks = 0
    for a, b, h, cap in itertools.product(range(5), range(5), range(9),
                                         (0, 1, 3, 16, 127, 2**31 - 1)):
        roots = [(a, h), (b, h + 1)]
        assert sum_capped(roots, cap) == min(
            a * charge(h) + b * charge(h + 1), cap + 1)
        family_sum_checks += 1

    mixed_cases = 0
    for qc, qd, t in itertools.product(range(17), repeat=3):
        constants = 31 * qc + 32 * qd
        gcc_bytes = 40 * constants + 32 * qd + 16 * qd
        assert gcc_bytes == 1240 * qc + 1328 * qd
        payload = 32 * qd + 8 * (qc + 3 * qd + t) + 4 * (5 * qc + 11 * qd + 3 * t)
        assert payload == 28 * qc + 100 * qd + 20 * t
        mixed_cases += 1

    return {
        'status': 'pass', 'checked_at_utc': datetime.now(timezone.utc).isoformat(),
        'offline_platform': f'{platform.system()} {platform.machine()}',
        'offline_elapsed_seconds': time.perf_counter() - started,
        'gcc_commit': PIN, 'source_files': len(sources),
        'LF_witnesses': len(witnesses), 'handled_annotation_codes': len(HANDLED),
        'max_handled_original_arity': 3,
        'induction_arithmetic_cases': induction_cases,
        'ordinary_height_combinations': height_combinations,
        'synthetic_DAG_vertices': len(nodes),
        'synthetic_DAG_max_height': max(heights),
        'retry_levels': 16, 'retry_charge_at_last_level': expected,
        'saturation_exact_comparisons': saturation_cases,
        'huge_saturation_height_bits': huge_height.bit_length(),
        'capped_family_sum_comparisons': family_sum_checks,
        'mixed_allocation_coefficient_cases': mixed_cases,
        'annotation_height_transfer': {
            'premise': 'finite acyclic original annotation operand graph of certified height h',
            'B': '2*3^h-1', 'active_annotation_frames': 'h+2 (1 when h=0)',
            'dynamic_root_allowance': 'Rd=2((Ta-Sa)+(Tl-Sl))',
            'dynamic_charge': 'Qd<=sum_i B(h_i)<=Rd*B(H)',
            'classified_roots': 'Qc=2(Sa+Sl)',
            'constant_requests': '31Qc+32Qd',
            'unary_requests_and_slots': 'Qd each',
            'map_requests': 'Qd', 'gcc_direct_caller_bytes': '1240Qc+1328Qd',
            'Rep_Table_additions': 'Qd', 'Uint_entries': 'Qc+3Qd+T',
            'Uint_digits': '5Qc+11Qd+3T',
            'UI_From_Int_cache_calls': 'Qc+3Qd+T',
            'serial_increments': 'Qd',
            'logical_callback_payload_bytes': '28Qc+100Qd+20T',
            'constant_cache_caller_bytes': '2040*min(31Qc+32Qd,participating_type_instances)',
        },
        'scoped_annotation_transfer_closed': True,
        'source_derived_dynamic_height_closed': False,
        'dynamic_F_closed': False, 'dynamic_Q_source_attachment_closed': False,
        'dynamic_FoldEnvelope_missing': True,
        'complete_native_capacity_result': False,
        'actual_native_allocations_measured': False,
        'semantic_source_argument_machine_proved': False,
        'predecessor_exports_preserved': True,
        'native_target_runs': 0, 'compiler_prover_runs': 0,
        'predecessor_checker_replays': 0,
        'selected_author_model': 'GPT-6 Astra',
        'selected_author_effort': 'Extra High',
        'runtime_model_and_effort': None, 'total_author_elapsed_seconds': None,
        'tokens': None, 'cost': None, 'independent_review': 'pending',
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    result = check()
    payload = json.dumps(result, indent=2) + '\n'
    if args.output:
        args.output.write_text(payload)
    print(payload, end='')


if __name__ == '__main__':
    main()
