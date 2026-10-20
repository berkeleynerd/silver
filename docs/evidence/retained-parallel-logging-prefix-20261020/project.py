#!/usr/bin/env python3
"""New projection of retained J12 bytes; never launches a target or old reader."""
import importlib.util
import json
import struct
import sys
import tarfile
from pathlib import Path

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
R53 = ROOT / 'docs/evidence/retained-why-parallel-residual-transfer-20261020'
R54 = ROOT / 'docs/evidence/retained-fixed-goal-attribution-20261020'
spec = importlib.util.spec_from_file_location('r54_graph', R54 / 'project.py')
module = importlib.util.module_from_spec(spec)
spec.loader.exec_module(module)
Graph = module.Graph
CASES = ['put_line', 'put', 'first_or_default', 'is_message', 'input_is_valid']
MEMBERS = ['process.json', 'session-root.json', 'session-blocks.jsonl',
           'session-task-chains.json', 'session-forest.json',
           'session-tables.json', 'summary.json', 'server.json',
           'session-symbols.json', 'result.json']


def imm(word):
    assert word & 1
    return (word - 1) // 2


def project():
    expected = json.loads((R54 / 'fixed-root-map.json').read_text())
    expected_labels = json.loads((R54 / 'raw-goal-labels.json').read_text())
    output = {}
    for case in CASES:
        with tarfile.open(R53 / (case.replace('_', '-') + '-capture.tar.gz')) as arc:
            raw = {n: arc.extractfile(case + '/capture/' + n).read() for n in MEMBERS}
        graph = Graph(raw['session-blocks.jsonl'])
        obj = {n: json.loads(b) for n, b in raw.items() if n != 'session-blocks.jsonl'}
        process = obj['process.json']
        server = obj['server.json']
        assert server['actual_argv'] == server['argv']
        assert server['argv'][server['argv'].index('-j') + 1] == '12'
        argv = process['argv']
        for flag, value in [('-j', '12'), ('--proof', 'per_check'),
                            ('--counterexample', 'off'), ('--steps', '0'),
                            ('--timeout', '0'), ('--prover', 'cvc5,z3,altergo')]:
            assert argv[argv.index(flag) + 1] == value
        assert len(argv) == 20
        assert not any(flag in argv for flag in ['--logging', '--replay', '--limit-line',
                                                '--limit-lines', '--limit-region'])
        assert process['initial_threads'] == 1
        assert process['environment']['OCAMLRUNPARAM'] == 's=256M,h=16M,M=1000'
        assert process['environment']['LC_ALL'] == 'C'
        assert 'GNATWHY3LOG' not in process['environment']
        summary = obj['summary.json']
        assert summary['completed'] and summary['protected']
        assert not summary['guard_hits'] and not summary['new_threads']
        assert not summary['failures']
        startup = summary['startup_guard_hits']
        assert [row['guard'] for row in startup] == [
            'caml_minor_collection', 'caml_gc_dispatch',
            'caml_empty_minor_heap', 'caml_major_collection_slice']
        assert all('caml_make_vect' in row['backtrace']
                   and 'camlRe__Dense_map__make' in row['backtrace']
                   and 'camlRe__Cset__entry' in row['backtrace'] for row in startup)
        assert all(row['hits'] == 0 for row in summary['forbidden_calls'].values())
        assert [row['name'] for row in summary['dispatch']['transform']] == ['split_goal_wp_conj']
        roots = obj['session-root.json']
        assert roots['complete']
        controller = graph.fields(roots['controller'], 6)
        assert controller[0] == roots['session']
        session = graph.fields(roots['session'], 17)
        tables = obj['session-tables.json']
        for name, index in [('proof_attempts', 0), ('proof_nodes', 2),
                            ('transformations', 4), ('files', 8), ('raw_tasks', 11)]:
            assert tables[name]['address'] == session[index]
        counters = {name: imm(session[index]) for name, index in
                    [('next_proofAttemptID', 1), ('next_proofNodeID', 3),
                     ('next_transID', 5), ('next_fileID', 6)]}
        for table, counter in [('proof_attempts', 'next_proofAttemptID'),
                               ('proof_nodes', 'next_proofNodeID'),
                               ('transformations', 'next_transID'), ('files', 'next_fileID')]:
            assert {imm(e['key']) for e in tables[table]['entries']} == set(range(counters[counter]))
        proofnodes = {imm(e['key']): e['value'] for e in tables['proof_nodes']['entries']}
        transformations = {imm(e['key']): e['value'] for e in tables['transformations']['entries']}
        forest = obj['session-forest.json']['visits']
        chains = obj['session-task-chains.json']
        root, = [v for v in forest if v['root']]
        assert root['goal'] == 0
        _, _, _, _, trans = graph.fields(root['proof_node'], 5)
        trans_id, = graph.seq(trans)
        assert imm(trans_id) == 0
        name, args, children, parent, detached = graph.fields(transformations[0], 5)
        # The reader retained this static pointer, but not the string block.
        # Join it to the pinned installed ELF bytes through recorded load bias.
        static = json.loads((HERE / 'installed-byte-witnesses.json').read_text())['static_transform_name']
        assert name - obj['session-symbols.json']['load_bias'] == static['virtual_address']
        assert static['decoded'] == 'split_goal_wp_conj'
        assert args == detached == 1 and imm(parent) == 0
        assert [imm(x) for x in graph.seq(children)] == list(range(1, len(forest)))
        rows, groups = [], {}
        for node in forest:
            goal = node['goal']
            assert not node['detached'] and proofnodes[goal] == node['proof_node']
            _, _, parent, _, trans = graph.fields(node['proof_node'], 5)
            if not node['root']:
                tid, = graph.fields(parent, 1, 0)
                assert imm(tid) == 0 and trans == 1
            symbol, ident, name, loc, formula = graph.goal(node['task'], chains[str(node['task'])])
            visits = graph.shape_search(formula)
            attrs = [a for _, aset in visits for a in aset]
            check = None
            for _, aset in visits:
                for attr in aset:
                    if attr.startswith('GP_Check:'):
                        parts = attr.split(':')
                        check = {'id': int(parts[1]), 'kind': parts[2],
                                 'source_location': ':'.join(parts[3:])}
                if check is not None and check['kind'] == 'VC_LOOP_INVARIANT':
                    for attr in aset:
                        if attr.startswith('expl:'):
                            check['kind'] = ('VC_LOOP_INVARIANT_INIT' if attr == 'expl:loop invariant init'
                                             else 'VC_LOOP_INVARIANT_PRESERV')
            row = {'goal': goal, 'root': node['root'], 'name': name,
                   'location_words': loc, 'trivial': graph.trivial(formula),
                   'check_labels': [a for a in attrs if a.startswith('GP_Check:')],
                   'check': check, 'already_proved': 'GP_Already_Proved' in attrs}
            old = next(x for x in expected_labels[case] if x['goal'] == goal)
            assert row == {k: old[k] for k in row}
            rows.append(row)
            if not node['root'] and check is not None and not row['already_proved']:
                groups.setdefault((check['id'], check['kind']), []).append(row)
        mapping = []
        for (check_id, kind), group in sorted(groups.items()):
            for rank, row in enumerate(sorted(group, key=lambda x: x['goal'], reverse=True)):
                mapping.append({'goal': row['goal'], 'check_id': check_id,
                                'check_kind': kind, 'root_index': rank,
                                'source_location': row['check']['source_location'],
                                'trivial': row['trivial']})
        assert mapping == expected[case]
        end = summary['snapshots'][-1]
        assert end['label'] == 'end_of_registration'
        base = summary['baseline']
        assert summary['snapshots'][0]['caml_gc_phase'] == 3
        assert base['label'] == 'before_first_why3_module'
        assert base['state']['stat_minor_collections'] == 1
        assert base['state']['stat_major_collections'] == 0
        assert base['state']['stat_minor_words'] + 4 <= 3312 < 2**28
        assert base['state']['stat_major_words'] == base['state']['stat_promoted_words']
        assert base['caml_gc_phase'] == end['caml_gc_phase'] == 0  # Phase_mark, NOT idle.
        assert end['state']['minor_heap_wsz'] == 2**28
        assert all(end['state'][k] == 0 for k in ['in_minor_collection', 'requested_major_slice', 'requested_minor_gc'])
        for key in ['stat_minor_words', 'stat_promoted_words', 'stat_major_words',
                    'stat_minor_collections', 'stat_major_collections', 'stat_compactions']:
            assert end['state'][key] == base['state'][key]
        path = argv[-1].rsplit('.', 1)[0] + '.why3log'
        string_words = 1 + (len(path) + 1 + 7) // 8
        # A conservative current-minor envelope also charges the 4 pre-Re
        # argv words here, although the forced startup collection promotes them.
        delta_minor = 4 + 27 + string_words + 3
        delta_major = 4
        major_max = (end['state']['stat_heap_wsz'] * 8 // 150) * 1000
        minor_max = (end['state']['minor_heap_wsz'] * 8 // 100) * 100
        credits = {'minor_words': end['minor_allocated_words'] + delta_minor,
                   'major_allocation_words': end['caml_allocated_words'] + delta_major,
                   'extra_minor_resources': end['state']['extra_heap_resources_minor'] + 8192 / minor_max,
                   'extra_major_resources': end['caml_extra_heap_resources'] + (65616 - 8192) / major_max,
                   'ref_entries': end['tables']['ref_table']['used_entries'] + 1,
                   'ephe_entries': end['tables']['ephe_ref_table']['used_entries'],
                   'custom_entries': end['tables']['custom_table']['used_entries'] + 1}
        assert credits['minor_words'] < 2**28 and credits['major_allocation_words'] < 2**28
        assert credits['extra_minor_resources'] < 1 and credits['extra_major_resources'] < 1
        for name in ['ref', 'ephe', 'custom']:
            table = {'ref': 'ref_table', 'ephe': 'ephe_ref_table', 'custom': 'custom_table'}[name]
            assert credits[name + '_entries'] < end['tables'][table]['size']
        output[case] = {'captured_pid': process['pid'], 'captured_argv': argv,
                        'prospective_argv': argv[:1] + ['--logging'] + argv[1:],
                        'session_counters': counters, 'goal_ids': sorted(proofnodes),
                        'fixed_root_map': mapping,
                        'checked_binding_records': len(graph.bindings),
                        'startup_collection': {
                            'site': 'caml_make_vect -> Re.Dense_map.make -> Re.Cset initialization',
                            'pre_forced_collection_minor_words': base['state']['stat_minor_words'],
                            'prospective_pre_forced_minor_upper': base['state']['stat_minor_words'] + 4,
                            'promoted_words': base['state']['stat_promoted_words'],
                            'prospective_promoted_upper': base['state']['stat_promoted_words'] + 4,
                            'startup_guard_order': [row['guard'] for row in startup]},
                        'log_path': path, 'log_path_bytes': len(path),
                        'logging_delta': {'argv_words': 4, 'Arg_option_words': 27,
                                          'path_string_words': string_words, 'channel_wrapper_words': 3,
                                          'minor_envelope_words': delta_minor, 'major_envelope_words': delta_major,
                                          'native_channel_bytes': 65616, 'native_path_allocation_bytes': 2 * (len(path) + 1),
                                          'custom_table_entries': 1, 'ref_table_entries_at_most': 1,
                                          'ephe_table_entries': 0, 'Why3_ID_increments': 0},
                        'prospective_end_credits': credits,
                        'captured_native_seconds': obj['result.json']['duration_seconds']}
    return output


if __name__ == '__main__':
    print(json.dumps(project(), indent=2, sort_keys=True))
