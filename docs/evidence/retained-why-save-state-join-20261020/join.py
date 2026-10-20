#!/usr/bin/env python3
"""Join fresh captured fields to retained conditional transfers; no target replay.

The default roots are historical local captures. Override both roots with the
registration/ and inline/ directories from the capture packet's safe extractor.
Passing arithmetic does not establish the remaining representation contracts.
"""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
E = HERE.parent
ROOT = E.parent.parent
CASES = ['put_line', 'put', 'first_or_default', 'is_message', 'input_is_valid']


def get(path):
    return json.loads(path.read_text())


def identity(path):
    raw = path.read_bytes()
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def module(name, directory):
    path = E / directory / 'transfer.py'
    spec = importlib.util.spec_from_file_location(name, path)
    result = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(result)
    return result


def maximum(values):
    # Callers have established complete finite traversal; this is not an
    # unknown-to-zero conversion.
    return max(values, default=0)


def entry_projection(s):
    gs, ids = s['gshape'], s['prover_ids']
    h, i = gs['hyp_shape'], gs['index_sh']
    assert h['finite_balanced_ordered'] and i['finite_balanced_ordered']
    assert gs['n'] >= 0
    return {
        'gshape_n': gs['n'], 'hyp_map_bindings': h['cardinality'],
        'index_map_bindings': i['cardinality'],
        'dictionary_string_bytes_max': maximum(
            [r['key']['bytes'] for r in h['nodes']] +
            [r['value']['bytes'] for r in i['nodes']]),
        'hyp_value_abs_max': maximum(abs(r['value']) for r in h['nodes']),
        'bound_index_abs_max': maximum(r['value']['absolute_index_max']
                                       for r in s['bound_shapes']['entries']),
        'bound_list_length_max': maximum(r['value']['length']
                                         for r in s['bound_shapes']['entries']),
        'bound_table_bindings': s['bound_shapes']['binding_visits'],
        'old_shape_bytes_max': maximum(r['value']['bytes'] for r in s['old_shapes']['entries']),
        'checksum_bytes_max': maximum(r['value']['bytes'] for r in s['checksums']['entries']),
        'shape_buffer_capacity': s['shape_buffer']['capacity'],
        'prover_id_bindings': ids['binding_visits'],
        'prover_id_scalar_size': ids['size'],
        'prover_id_bucket_capacity': ids['bucket_capacity'],
        'prover_id_abs_max': maximum(abs(r['value']) for r in ids['entries']),
        'session_dir_bytes': s['serializer']['session_dir']['bytes'],
    }


def table_row(name, table, mode, additions, prefix):
    cap = table['bucket_capacity']
    assert table['disjoint_finite_chains']
    assert 1 <= abs(table['initial_size']) <= cap
    assert 0 <= table['size'] <= prefix.MAX_INT
    row = {'table': name, 'mode': mode, 'entry_size': table['size'],
           'entry_visits': table['binding_visits'], 'bucket_capacity': cap,
           'initial_size': table['initial_size'], 'seed': table['seed'],
           'size_equals_binding_visits': table['size_equals_binding_visits'],
           'insertion_opportunities': additions,
           'entry_layout_and_chains_established': True}
    # Entry decoding is established. Native/source continuation theorems are
    # imported conditionally; this numeric application does not assert their
    # unresolved whole-continuation key/callback/representation premises.
    for premise in prefix.PREMISES:
        row.setdefault(premise, False)
    return {'inputs': row, 'conditional_result': prefix.bound_table(row)}


def join(registration, inline):
    operational = module('operational', 'retained-why-save-operational-bounds-20261020')
    growth = module('growth', 'retained-why-save-attempt-growth-20261020')
    prefix = module('prefix', 'retained-why-save-hashtbl-prefix-20261020')
    forests_path = E / 'retained-why-session-shape-transfer-20261020/bounds.json'
    growth_path = E / 'retained-why-save-attempt-growth-20261020/applications.json'
    forests = {r['case']: r for r in get(forests_path)}
    applications = {r['case']: r for r in get(growth_path)}
    results = []
    for case in CASES:
        slug = case.replace('_', '-')
        capture = (inline if case == 'input_is_valid' else registration) / case / 'capture'
        projection_path = capture / 'save-missing-state.json'
        projection = get(projection_path)
        comparison = get(HERE / (slug + '-correspondence.json'))
        replay = get(HERE / (slug + '-replay.json'))
        assert projection['complete'] and not projection['failures']
        assert comparison['matched'] and replay['complete']
        assert identity(projection_path) == comparison['new_inputs']['save-missing-state.json']
        assert identity(projection_path) == replay['input_identities']['save-missing-state.json']
        forest = forests[case]
        assert comparison['old_pid'] == forest['provenance']['pid']
        assert comparison['B_binders'] == forest['B_imported']
        assert comparison['G'] == forest['G']
        assert comparison['old_inputs']['session-blocks.jsonl'] == forest['provenance']['member_identity']
        assert comparison['accepted_certificate']['identity'] == forest['provenance']['occurrence_certificate_identity']
        s = {k: v['value'] for k, v in projection['sections'].items() if v['known']}
        assert len(s) == len(projection['sections'])
        ser = s['serializer']
        a0 = s['proof_attempts']['binding_visits']
        ax0 = sum(g['attempts']['binding_visits'] for g in ser['goals'])
        app = applications[case]
        x = app['inputs']
        assert (a0, ax0) == (x['A_stats0'], x['A_xml0'])
        assert len(ser['goals']) == x['G'] == forest['G']
        assert len(ser['files']) == x['F']
        assert sum(len(f['theories']) for f in ser['files']) == x['Th']
        assert len(ser['transformations']) == x['T']
        assert sum(t['arguments']['component_count'] for t in ser['transformations']) == x['Args']
        assert all(a['script'] is None for a in ser['attempts']) and x['all_scripts_none']
        gr = growth.compose(x, signal_contract=True, table_contract=False)
        assert gr == app['conditional_transfer']
        additions = gr['new_table_bindings_upper']
        entry = entry_projection(s)
        serializer = {'attempt_stat_visits': gr['conditional_A_stats_upper'],
                      'attempt_xml_visits': gr['conditional_A_xml_upper'],
                      'file_visits': x['F'], 'theory_visits': x['Th'],
                      'transformation_visits': x['T'], 'argument_visits': x['Args'],
                      'path_component_visits': sum(f['path']['component_count'] for f in ser['files']),
                      'raw_string_bytes_sum': None, 'scalar_format_bytes_max': None}
        op = operational.transfer({**forest, 'shape_output_input_ready': True}, entry,
                                  serializer, explanation_prefix_count=2)
        rows = []
        for source, name, mode, n in [
            ('bound_shapes', 'session_bound_shape_table', 'clear_before_add', 3 * x['G']),
            ('old_shapes', 'session_shape_table', 'clear_only', 0),
            ('checksums', 'session_sum_table', 'readonly', 0),
            ('prover_ids', 'session_prover_ids', 'persistent', additions['session_prover_ids']),
            ('file_state', 'file_state', 'persistent', additions['file_state']),
            ('theory_state', 'th_state', 'persistent', additions['th_state']),
            ('transformation_state', 'tn_state', 'persistent', additions['tn_state']),
            ('proof_node_state', 'pn_state', 'persistent', additions['pn_state']),
            ('proof_attempts', 'proofAttempt_table', 'persistent', additions['proofAttempt_table']),
        ]:
            rows.append(table_row(name, s[source], mode, n, prefix))
        for goal in ser['goals']:
            rows.append(table_row('proofn_attempts:' + str(goal['goal']), goal['attempts'],
                                  'persistent', additions['each_goal_attempt_table'], prefix))
        restored = s['restore_paths']['required_identifiers']
        results.append({
            'case': case, 'new_pid': comparison['new_pid'], 'phase': projection['phase'],
            'projection_identity': identity(projection_path),
            'logical_graph_correspondence_established': True,
            'extension_decode_replayed_byte_equal': True,
            'captured_entry': entry, 'captured_A_stats': a0, 'captured_A_xml': ax0,
            'conditional_growth': gr, 'conditional_operational_transfer': op,
            'table_applications': rows,
            'failed_numeric_table_guards': [r['inputs']['table'] for r in rows
                if r['conditional_result']['numeric_guards_pass'] is not True],
            'restored_identifier_observed_or_fallback_bytes_max': maximum(
                max(r['ident']['id_string']['bytes'],
                    0 if r['restore_path'] is None else r['restore_path']['qualified_path']['joined_dot_bytes'])
                for r in restored),
            'restored_path_continuation_preservation_established': False,
            'snapshot_shape_buffer_position': s['shape_buffer']['position'],
            'later_attempt_id_headroom_established': False,
            'complete_save_capacity_established': False,
            'whole_pipeline_capacity_established': False,
        })
    return {'scope': 'Five captured entry projections and conditional whole-continuation arithmetic; not a complete save-capacity result',
            'imported_shape_bounds_identity': identity(forests_path),
            'imported_growth_applications_identity': identity(growth_path),
            'cases': results}


if __name__ == '__main__':
    p = argparse.ArgumentParser(description=__doc__)
    p.add_argument('--registration', type=Path, default=Path('/home/canto/src/github.com/berkeleynerd/silver/tmp/wse-20261020'))
    p.add_argument('--inline', type=Path, default=Path('/home/canto/src/github.com/berkeleynerd/silver/tmp/why-session-save-capture-ready-20261020'))
    p.add_argument('--write', action='store_true', help='write the first result; otherwise compare with retained result')
    a = p.parse_args()
    result = join(a.registration, a.inline)
    target = HERE / 'result.json'
    if a.write:
        assert not target.exists(), 'preserve existing evidence'
        target.write_text(json.dumps(result, indent=2) + '\n')
    else:
        assert result == get(target), 'retained numeric application differs'
    print(json.dumps({'cases': len(result['cases']), 'failed_numeric_table_guards':
                      {r['case']: r['failed_numeric_table_guards'] for r in result['cases']},
                      'complete_save_capacity_established': False}))
