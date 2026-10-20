#!/usr/bin/env python3
"""Focused source-correspondence/arithmetic check, not the semantic proof.

No target, prior checker, native disassembler, solver, network or source fetch.
--write materializes this packet's deterministic witnesses and result once.
"""
import argparse
import hashlib
import json
from pathlib import Path
import platform
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
OCAML = 'docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
OCAML_PREFIX = 'ocaml-8eb41f72ded84df884c3671734c947f612091f84/'
PINNED_ARCHIVES = {
    WHY: (1372815, '2dd835cb251c82766ba7808f4cb2d384f91e0101468fd22d5810919072863749'),
    OCAML: (5510610, '04686c5bc81d09e89d2885326924206b028f05e9518f45fd5d56113ce36db7a7'),
}
# Exact ranges selected for this bounded argument; no registration extraction.
RANGES = {
    WHY: {
        'why3/src/util/exn_printer.ml': [(11, 52)],
        'why3/src/core/trans.ml': [(30, 65), (365, 401), (521, 566)],
        'why3/src/transform/encoding.ml': [(19, 69), (104, 149)],
        'why3/src/transform/discriminate.ml': [(46, 108), (400, 432), (453, 479)],
        'why3/src/util/loc.ml': [(114, 126), (302, 360)],
        'why3/src/parser/typing.ml': [(1583, 1660), (1713, 1745)],
        'why3/src/mlw/pmodule.ml': [(1365, 1392), (1590, 1638)],
        'why3/src/mlw/expr.ml': [(697, 703), (755, 779), (837, 844)],
        'why3/src/mlw/ity.ml': [(1436, 1505)],
        'why3/src/core/pretty.ml': [(798, 808), (1011, 1022)],
        'why3/src/core/ident.ml': [(93, 154)],
        'why3/src/util/debug.ml': [(158, 173)],
        'why3/src/util/sysutil.ml': [(69, 90)],
        'why3/src/driver/prove_client.ml': [(75, 90), (195, 261)],
    },
    OCAML: {
        OCAML_PREFIX + 'stdlib/fun.ml': [(21, 38)],
        OCAML_PREFIX + 'stdlib/printexc.ml': [(20, 76)],
        OCAML_PREFIX + 'stdlib/stdlib.ml': [(267, 290)],
        OCAML_PREFIX + 'stdlib/bytes.ml': [(170, 208)],
    },
}


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def dump(value):
    return json.dumps(value, indent=2, sort_keys=True) + '\n'


def probe(b, e):
    # An arithmetic experiment, NEVER a joined formatter result.
    p = 1000000010
    max_int = (1 << 62) - 1
    length = b + e
    insertions = 3 * e + 2
    total = p + length + 1
    size = (3 * e + 1) * total
    return {
        'illustrative_B': b, 'illustrative_E': e,
        'flush_sentinel': length + 79 <= p,
        'size_and_intermediate_arithmetic': size + length + 79 <= max_int,
        'container_counters_and_depth': 4 * insertions + 2 <= max_int,
        'remaining_sentinel_B_at_this_illustrative_E': p - 79 - e,
        'actual_standard_input_or_joined_result': False,
    }


def main():
    start = time.monotonic()
    ap = argparse.ArgumentParser()
    ap.add_argument('--write', action='store_true')
    args = ap.parse_args()
    inputs = json.loads((HERE / 'inputs.json').read_text())
    for row in inputs['providers']:
        actual = identity((ROOT / row['path']).read_bytes())
        assert actual == {k: row[k] for k in actual}, row['path']
    for path, (size, sha) in PINNED_ARCHIVES.items():
        assert identity((ROOT / path).read_bytes()) == {'bytes': size, 'sha256': sha}
    witnesses = []
    texts = {}
    for archive, members in RANGES.items():
        with tarfile.open(ROOT / archive) as tf:
            for member, ranges in members.items():
                data = tf.extractfile(member).read()
                source = data.decode('utf-8')
                texts[member] = source
                lines = source.splitlines(keepends=True)
                for first, last in ranges:
                    assert 1 <= first <= last <= len(lines), (member, first, last)
                    witnesses.append({
                        'archive': archive, 'member': member,
                        'member_identity': identity(data),
                        'first': first, 'last': last,
                        'text': ''.join(lines[first-1:last]),
                    })
    # Import the accepted census; do not recreate it.
    registry = json.loads((ROOT / 'docs/evidence/retained-why-session-exception-prefix-20261019/why-printer-inventory.json').read_text())
    assert len(registry) == 55
    selected = json.loads((ROOT / 'docs/evidence/retained-why-path-library-origins-20261020/selected-dispatch.json').read_text())
    outer_names = [x['name'] for x in selected['registrations']]
    assert len(set(outer_names)) == 20 and max(map(len, outer_names)) <= 64
    # Fixed keys/names from the accepted selected callbacks; not arbitrary meta strings.
    metas = ['select_kept', 'select_kept_default', 'enco_kept', 'enco_poly',
             'select_inst', 'select_inst_default', 'select_lskept', 'select_lskept_default',
             'select_lsinst', 'select_lsinst_default', 'select_alginst', 'select_alginst_default']
    keys = ['none', 'goal', 'local', 'all', 'twin', 'guards', 'tags', 'guards_full', 'tags_full']
    assert all('"'+m+'"' in texts['why3/src/transform/encoding.ml'] + texts['why3/src/transform/discriminate.ml'] for m in metas)
    name_lengths = [len(m+' (default)') for m in metas] + [len(m+':'+k) for m in metas for k in keys]
    assert max(name_lengths) <= 64
    literal_sizes = {s: len(s.encode()) for s in [
        'Failure in transformation ', 'Illegal instantiation for program function ',
        'Fun.Finally_raised: ', 'anomaly: ']}
    assert list(literal_sizes.values()) == [26, 43, 20, 9]
    for s in literal_sizes:
        assert any(s in source for source in texts.values()), s
    # Full byte alphabet verifies the elementary byte escape multiplier only.
    widths = [2 if c in (34, 92, 10, 9, 13, 8) else 1 if 32 <= c <= 126 else 4 for c in range(256)]
    assert max(widths) == 4 and max(len(str(n)) for n in (-(1 << 62), (1 << 62)-1)) == 20
    # This identity is algebraic, not a simulation of arbitrary source failures.
    for depth in range(8):
        nodes = 2 ** (depth + 1) - 1
        assert nodes == (1 if depth == 0 else 1 + 2 * (2 ** depth - 1))
    ledger = {
        'scope': 'accepted fixed-library/driver/registry/pending-client relation',
        'semantic_proof_owner': 'research note plus independent review',
        'wrappers': [
            {'constructor': 'Trans.TransFailure', 'maximum_chain_occurrences': 3},
            {'constructor': 'Loc.Located', 'maximum_chain_occurrences': 2},
            {'constructor': 'Theory.BadInstance(BadI_rs_type)', 'maximum_chain_occurrences': 1},
            {'constructor': 'Fun.Finally_raised', 'maximum_chain_occurrences': 1},
        ],
        'source_constructor_identity_and_client_closure_required': True,
        'other_recursive_registry_constructors_excluded_by_selected_creation_roots': True,
        'partial_failed_candidates_charged': True,
        'printer_failure_replaces_original_dispatch_input': False,
    }
    d = sum(x['maximum_chain_occurrences'] for x in ledger['wrappers'])
    assert d == 7
    n = 2 ** (d + 1) - 1
    per = {
        'same_exception_dispatch_packages_upper': n,
        'why_registry_passes_upper': 2*n,
        'why_callback_attempts_upper': 110*n,
        'printexc_to_string_calls_upper': n,
        'printexc_callback_attempts_upper': 5*n,
        'particular_terminal_matching_branch_attempts_upper': 2**(d+1),
        'all_pretty_callback_attempts_upper': 2*n,
        'private_candidate_shell_direct_events_upper': 220*n,
        'simultaneously_nested_exception_value_packages_upper': d+1,
    }
    occurrences = json.loads((HERE / 'outer-occurrences-import.json').read_text())
    cases = []
    for case, expected_h in zip(occurrences['cases'], [392, 326, 200, 26, 14], strict=True):
        h = case['under_named_existing_relation']['combined_outer_report_calls_upper']
        assert h == expected_h
        products = {k: v*h for k, v in per.items() if not k.startswith('simultaneously')}
        assert max(products.values()) <= (1 << 62)-1
        arithmetic = probe(0, products['private_candidate_shell_direct_events_upper'])
        assert all(arithmetic[x] for x in ['flush_sentinel', 'size_and_intermediate_arithmetic', 'container_counters_and_depth'])
        cases.append({'case': case['case'], 'pid': case['pid'], 'outer_calls_upper': h,
                      'conditional_dispatch_products': products,
                      'private_shell_count_standard_formula_probe_only': arithmetic})
    result = {
        'source_excerpts_checked': len(witnesses),
        'selected_source_members_checked': len(texts),
        'provider_inputs_checked': len(inputs['providers']),
        'wrapper_depth_upper_under_named_relation': d,
        'per_outer_diagnostic_under_named_relation': per,
        'cases': cases,
        'wrapper_literal_byte_lengths': literal_sizes,
        'selected_transformation_name_length_upper': 64,
        'ordinary_default_scalar_text_upper': 'C + 4*S + 68*k + 2',
        'special_default_location_text_upper': 'filename_bytes + 160',
        'normal_scalar_service_required': True,
        'full_semantic_control_closure_machine_checked': False,
        'actual_standard_core_B_E': None,
        'actual_private_diagnostic_B_E': None,
        'all_leaf_payload_byte_bounds': None,
        'server_complete_line_bytes_upper': None,
        'all_diagnostic_identifier_registrations_upper': None,
        'native_stack_bytes_upper': None,
        'runtime_service_R': None,
        'physical_sufficiency_established': False,
        'complete_save_or_exit_capacity_established': False,
        'whole_pipeline_capacity_established': False,
        'native_runs': 0, 'capture_runs': 0, 'disassembler_runs': 0,
        'source_fetches': 0, 'predecessor_checker_runs': 0, 'solver_or_lean_runs': 0,
    }
    for filename, value in [('source-witnesses.json', witnesses), ('wrapper-ledger.json', ledger), ('result.json', result)]:
        expected = dump(value)
        path = HERE / filename
        if args.write:
            assert not path.exists(), 'Do not overwrite an existing frozen result with --write'
            path.write_text(expected)
        else:
            assert path.read_text() == expected, filename
    print(dump({'status': 'pass', 'mode': 'materialize-and-check' if args.write else 'compare',
                'host': platform.system()+' '+platform.machine(),
                'source_excerpts': len(witnesses), 'providers': len(inputs['providers']),
                'elapsed_seconds': time.monotonic()-start,
                'semantic_proof_and_resource_joins': 'not established by this checker'}), end='')


if __name__ == '__main__':
    main()
