#!/usr/bin/env python3
"""Offline identity and arithmetic checks for the #201 local constructor kernel.

No native tool execution, predecessor replay, extraction or admission decision.
Source-branch coverage is an authored argument requiring independent review;
matching a source witness is not a semantic proof of that argument.
"""
import argparse
import hashlib
import itertools
import json
import platform
import tarfile
import time
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
FAMILIES = ('Ts', 'Ta', 'Tl', 'Tp')


def digest(data):
    return hashlib.sha256(data).hexdigest()


def read_json(path):
    return json.loads(path.read_bytes())


def add_rows(*rows):
    return [sum(x) for x in zip(*rows)]


def coefficients():
    # Candidate components follow the separate source-case derivation.
    direct_types = [1, 1 + 2, 2 + 2, 2 + 2]
    dummies_and_debug = [2] * 4
    type_decls = [2, 3, 2, 1]
    dummy_decls = [1] * 4
    # Typed UI_To_gnu with <=3 digits: initial2 +2*(one digit +2 folds*2)
    # + final conversion1. Widening retry is absent with a supplied type.
    uint_to_constant = 3 + 5 * (3 - 1)
    assert uint_to_constant == 13
    direct_constants = [
        6 + 1 + 1 + 1,
        2 * 13 + 2 + (uint_to_constant + 1 + uint_to_constant) + 1,
        uint_to_constant + 2 + 1 + 2 * 13,
        2 * 4 + 1 + 1 + 1 + 1,
    ]
    return {
        'type_nodes': add_rows(direct_types, dummies_and_debug),
        'type_declarations': add_rows(type_decls, dummy_decls),
        'rm_vectors_3': [1, 0, 1, 0],
        'lang_type_payloads': add_rows([0, 1, 1, 0], [1] * 4),
        'direct_constant_requests': direct_constants,
        'direct_unary_nodes_and_slots': add_rows([1, 2, 2, 1], [0, 4, 4, 0]),
        'alloca_request_count': [0, 2, 0, 0],
        'alloca_logical_payload_bytes': [0, 8 + 1, 0, 0],
    }


def project(matrix, vector):
    return {name: sum(c * n for c, n in zip(row, vector))
            for name, row in matrix.items()}


def check():
    started = time.perf_counter()
    inputs = read_json(HERE / 'inputs.json')
    for row in inputs['inputs']:
        assert digest((ROOT / row['path']).read_bytes()) == row['sha256'], row['path']
    manifest = read_json(HERE / 'source-manifest.json')
    assert manifest['gcc_commit'] == '6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea'
    archive = HERE / manifest['archive']
    assert digest(archive.read_bytes()) == manifest['archive_sha256']
    sources = {}
    with tarfile.open(archive, 'r:gz') as tar:
        members = tar.getmembers()
        assert all(x.isfile() for x in members)
        assert {x.name for x in members} == {x['path'] for x in manifest['files']}
        assert len(members) == len(manifest['files'])
        for row in manifest['files']:
            data = tar.extractfile(row['path']).read()
            assert len(data) == row['bytes']
            assert digest(data) == row['sha256'], row['path']
            predecessor = read_json(ROOT / row['predecessor_manifest'])
            matches = [x for x in predecessor['files']
                       if x['path'] == row['predecessor_key']]
            assert len(matches) == 1
            assert matches[0]['sha256'] == row['sha256']
            sources[row['path']] = data
    witnesses = read_json(HERE / 'source-witnesses.json')['witnesses']
    assert len({x['id'] for x in witnesses}) == len(witnesses)
    for row in witnesses:
        lines = sources[row['source']].split(b'\n')  # Never splitlines(): GCC uses FF.
        lo, hi = row['first_lf_line'], row['last_lf_line']
        assert 1 <= lo <= hi <= len(lines)
        data = b'\n'.join(lines[lo - 1:hi]) + b'\n'
        assert digest(data) == row['sha256'], row['id']
        assert data.decode() == row['excerpt'], row['id']
    matrix = coefficients()
    expected = {
        'type_nodes': [3, 5, 6, 6],
        'type_declarations': [3, 4, 3, 2],
        'rm_vectors_3': [1, 0, 1, 0],
        'lang_type_payloads': [1, 2, 2, 1],
        'direct_constant_requests': [9, 56, 42, 12],
        'direct_unary_nodes_and_slots': [1, 6, 6, 1],
        'alloca_request_count': [0, 2, 0, 0],
        'alloca_logical_payload_bytes': [0, 9, 0, 0],
    }
    assert matrix == expected
    # Check the coarse E projection over every small disjoint family assignment.
    assignments = 0
    for vector in itertools.product(range(8), repeat=4):
        projected = project(matrix, vector)
        total = sum(vector)
        for name, row in matrix.items():
            assert projected[name] <= max(row) * total
        assignments += 1
    # Numeric representation premises, not empirical compiler observations.
    max_string_bits = 8 * ((1 << 31) - 1)
    assert max_string_bits < 32768 ** 3
    assert max_string_bits < (1 << 64)
    assert 8 + 4 * 16 == 72
    assert (512 - 8) // 16 == 31
    assert 8 + 31 * 16 == 504
    predecessor_path = 'docs/evidence/unbounded-programs/retained-native-expansion-20261017/local-envelope.json'
    predecessor = read_json(ROOT / predecessor_path)
    programs = []
    for item in predecessor['representative_current_programs']['programs']:
        assert digest((ROOT / item['source']).read_bytes()) == item['sha256']
        g = item['gigi_source_interface']
        a, e, h, v = (g[k] for k in ('Main_ordinary_allocation_allowance',
                                   'Main_entity_identities', 'Main_Integer_store_events',
                                   'Main_source_syntax_visit_bound'))
        assert v == a + 32 * e + 3 * h
        p = {name: max(row) * e for name, row in matrix.items()}
        p['selected_caller_byte_projection'] = (
            256 * p['type_nodes'] + 48 * p['rm_vectors_3']
            + 16 * p['lang_type_payloads'] + 40 * p['direct_constant_requests'])
        programs.append({'source': item['source'], 'sha256': item['sha256'],
                         'A_Main': a, 'E_Main': e, 'H_store': h, 'V_Main': v,
                         'coarse_direct_kernel_projection': p,
                         'actual_family_counts_supplied': False,
                         'symbolic_helper_cost_supplied': False,
                         'annotation_Q_supplied': False,
                         'complete_native_capacity_result': False})
    assert len(programs) == 5
    residuals = {
        'bound_translation_and_elaboration': [2, 0, 0, 0],
        'literal_lower_translation': [0, 0, 1, 0],
        'convert': [0, 7, 4, 0],
        'fold_convert': [0, 6, 8, 0],
        'size_binop': [0, 17, 12, 0],
        'fold_build2': [0, 3, 2, 0],
        'gigi_binary': [0, 1, 1, 0],
        'gigi_conditional': [0, 1, 0, 0],
        'max_value': [0, 2, 0, 0],
        'multiple_of_p': [0, 2, 2, 0],
        'save_predicate_work': [0, 4, 4, 0],
    }
    return {
        'status': 'pass', 'checked_at_utc': datetime.now(timezone.utc).isoformat(),
        'native_platform': platform.system() + ' ' + platform.machine(),
        'offline_elapsed_seconds': time.perf_counter() - started,
        'source_files': len(sources), 'source_witnesses': len(witnesses),
        'predecessor_inputs': len(inputs['inputs']),
        'coarse_projection_assignments_checked': assignments,
        'family_order': FAMILIES, 'direct_kernel_coefficients': matrix,
        'open_weighted_root_multiplicities': residuals,
        'max_string_bits': max_string_bits,
        'descriptor_vector': {'elements': 2, 'first_raw_reserve_bytes': 72,
                              'allocator_caller_bytes_upper': 504,
                              'rounded_bytes_upper': 512, 'allocations': 1},
        'program_projections': programs,
        'native_compiler_runs': 0, 'prover_runs': 0, 'predecessor_replays': 0,
        'complete_native_capacity_result': False,
        'semantic_source_argument_machine_proved': False,
        'independent_review': 'pending',
        'selected_author_model': 'GPT-6 Astra', 'selected_author_effort': 'Extra High',
        'runtime_model_and_effort': 'unavailable',
        'total_author_elapsed_seconds': None, 'tokens': None, 'cost': None,
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--output', type=Path)
    args = parser.parse_args()
    result = check()
    if args.output:
        args.output.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({k: result[k] for k in ('status', 'source_files', 'source_witnesses',
                                           'predecessor_inputs', 'offline_elapsed_seconds',
                                           'complete_native_capacity_result')}))


if __name__ == '__main__':
    main()
