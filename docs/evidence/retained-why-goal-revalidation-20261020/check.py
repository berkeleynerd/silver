#!/usr/bin/env python3
"""New goal-only structural calculation from retained raw blocks.

No target, original observer, binder/alpha interpreter, or predecessor checker
is run. Counts are mathematical integers; source applicability is reviewed.
"""
import argparse
from collections import Counter
from functools import lru_cache
import hashlib
import json
from pathlib import Path
import struct
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
CAP = 'docs/evidence/retained-why-save-state-capture-20261020/'
CASES = ('put_line', 'put', 'first_or_default', 'is_message', 'input_is_valid')
NAMES = ('Tvar', 'Tconst', 'Tapp', 'Tif', 'Tlet', 'Tcase', 'Teps', 'Tquant', 'Tbinop', 'Tnot')
SIZES = (1, 1, 2, 3, 2, 2, 1, 2, 3, 1)
EPISODE_NOTE = 'docs/research/retained-why-path-writer-capacity.md'
EPISODE_RESULT = 'docs/evidence/retained-why-path-writer-capacity-20261020/result.json'
EPISODE_PREMISES = [
    'selected_source_native_pending_frame_relation',
    'accepted_fresh_status_configuration_and_serial_ownership',
    'accepted_metadata_key_counter_and_result_preservation',
    'continued_global_signal_escape_budget',
    'selected_writer_effects_and_valid_immutable_task_relation',
]


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def read(path):
    return json.loads(path.read_text())


class Goals:
    def __init__(self, raw):
        self.blocks, self.reads, self.active = {}, set(), set()
        self.bindings, self.images = {}, set()
        self.terms = set()
        for line in raw.splitlines():
            row = json.loads(line)
            p = row['address']
            assert p not in self.blocks
            self.blocks[p] = row

    def fields(self, p, words=None, tag=0):
        self.reads.add(p)
        row = self.blocks[p]
        assert row['header'] == int.from_bytes(bytes.fromhex(row['header_hex']), 'little')
        assert row['tag'] == row['header'] & 255
        assert row['words'] == row['header'] >> 10
        assert row['tag'] == tag and (words is None or row['words'] == words)
        raw = bytes.fromhex(row['payload_hex'])
        assert len(raw) == 8*row['words']
        return struct.unpack('<'+'Q'*row['words'], raw)

    @lru_cache(None)
    def seq(self, p):
        values, seen = [], set()
        while p != 1:
            assert p not in seen, ('list cycle', p)
            seen.add(p)
            v, p = self.fields(p, 2)
            values.append(v)
        return tuple(values)

    @lru_cache(None)
    def mapping(self, p):
        if p == 1:
            return ()
        key = ('map', p)
        assert key not in self.active, key
        self.active.add(key)
        try:
            left, var, value, right, height = self.fields(p, 5)
            assert height & 1
            rows = self.mapping(left)+((var, value),)+self.mapping(right)
            assert len({k for k, _ in rows}) == len(rows)
            return rows
        finally:
            self.active.remove(key)

    def node(self, p):
        node, _, _, _ = self.fields(p, 4)
        if node & 1:
            assert node in (1, 3)
            return ('Ttrue' if node == 1 else 'Tfalse'), ()
        tag = self.blocks[node]['tag']
        assert 0 <= tag < len(NAMES)
        return NAMES[tag], self.fields(node, SIZES[tag], tag)

    def binding(self, p):
        _, saved = self.fields(p, 2)
        pairs = self.mapping(saved)
        self.bindings[p] = pairs
        for _, value in pairs:
            name, _ = self.node(value)
            assert name == 'Tvar', ('nonvariable substitution image', value)
            self.images.add(value)

    @lru_cache(None)
    def count(self, p):
        key = ('term', p)
        assert key not in self.active, key
        self.active.add(key)
        self.terms.add(p)
        try:
            name, f = self.node(p)
            assert name != 'Tcase', ('case in raw goal closure', p)
            children, own, quant_slots = (), 0, 0
            if name == 'Tapp':
                children = self.seq(f[1])
            elif name == 'Tif':
                children = f
            elif name in ('Tlet', 'Teps'):
                _, info, body = self.fields(f[1] if name == 'Tlet' else f[0], 3)
                self.binding(info)
                own = 1
                children = (body,)+(f[:1] if name == 'Tlet' else ())
            elif name == 'Tquant':
                variables, info, triggers, body = self.fields(f[1], 4)
                self.binding(info)
                variables = self.seq(variables)
                assert len(set(variables)) == len(variables)
                own = quant_slots = len(variables)
                children = (body,)+tuple(t for tr in self.seq(triggers) for t in self.seq(tr))
            elif name == 'Tbinop':
                children = f[1:]
            elif name == 'Tnot':
                children = f
            result = Counter({name: 1})
            binders, nodes = own, 1
            for child in children:
                n, b, q, ct = self.count(child)
                nodes += n
                binders += b
                quant_slots += q
                result.update(dict(ct))
            assert sum(result.values()) == nodes
            assert binders == result['Tlet']+result['Teps']+quant_slots
            return nodes, binders, quant_slots, tuple(sorted(result.items()))
        finally:
            self.active.remove(key)

    def goal(self, task, chain):
        row = chain[0]
        assert row['option'] == task
        head, = self.fields(task, 1)
        assert head == row['head']
        td, *_ = self.fields(head, 6)
        assert td == row['tdecl']
        node, _ = self.fields(td, 2)
        declaration, = self.fields(node, 1)
        dnode, _, _ = self.fields(declaration, 3)
        prop, = self.fields(dnode, 1, 5)
        kind, symbol, formula = self.fields(prop, 3)
        assert kind == 5  # Pgoal = third nullary constructor.
        return declaration, symbol, formula


def calculate():
    inputs = read(HERE/'inputs.json')
    for path, expected in inputs['files'].items():
        assert identity((ROOT/path).read_bytes()) == expected, path
    manifest = read(ROOT/(CAP+'capture-manifest.json'))
    retained = {(CAP+a['path'], m['path']): {k: m[k] for k in ('bytes', 'sha256')}
                for a in manifest['archives'] for m in a['members']}
    members = {}
    for archive in sorted({m['archive'] for m in inputs['members']}):
        needed = [m for m in inputs['members'] if m['archive'] == archive]
        with tarfile.open(ROOT/archive) as stream:
            for spec in needed:
                raw = stream.extractfile(spec['member']).read()
                assert identity(raw) == spec['identity']
                if archive.startswith(CAP):
                    assert retained[(archive, spec['member'])] == spec['identity']
                members[(archive, spec['member'])] = raw
    for w in read(HERE/'source-witnesses.json'):
        raw = members[(w['archive'], w['member'])]
        assert ''.join(raw.decode().splitlines(keepends=True)[w['first_line']-1:w['last_line']]) == w['text']
    episode_note = (ROOT/EPISODE_NOTE).read_text()
    assert 'Therefore **E≤K+e** for every executed' in episode_note
    assert '**one global e≤2 escaping signal-save' in episode_note
    episode_result = read(ROOT/EPISODE_RESULT)
    episode_rows = {r['case']: r for r in episode_result['cases']}
    assert set(episode_rows) == set(CASES)
    rows, goal_cert = [], {}
    for case in CASES:
        slug = case.replace('_', '-')
        archive = CAP+'capture-'+slug+'.tar.gz'
        group = 'inline' if case == 'input_is_valid' else 'registration'
        prefix = group+'/'+case+'/capture/'
        get = lambda n: members[(archive, prefix+n)]
        graph = Goals(get('session-blocks.jsonl'))
        chains = json.loads(get('session-task-chains.json'))
        forest = json.loads(get('session-forest.json'))
        process = json.loads(get('process.json'))
        summary = json.loads(get('summary.json'))
        assert summary['completed'] and not summary['failures'] and not summary['guard_hits']
        endpoint = 'inline_trivial_entry' if group == 'inline' else 'end_of_registration'
        assert summary['snapshots'][-1]['label'] == endpoint
        if group == 'inline':
            assert len(summary['driver_preparation']) == 1
            assert summary['driver_preparation'][0]['visited_directives'] == ['counterexamples_dependent_intros', 'inline_trivial']
        old_file = ('docs/evidence/retained-why-session-save-state-20261019/binder-certificate.json'
                    if case == 'input_is_valid' else
                    'docs/evidence/retained-why-fixed-session-domain-20261020/'+slug+'-analysis.json')
        old = read(ROOT/old_file)
        old_cert = old if case == 'input_is_valid' else old['full_certificate']
        old_by_goal = {v['goal']: v for v in old_cert['visits']}
        correspondence = read(ROOT/('docs/evidence/retained-why-save-state-join-20261020/'+slug+'-correspondence.json'))
        assert correspondence['matched'] and correspondence['new_pid'] == process['pid']
        for name in ('process.json', 'session-blocks.jsonl', 'session-task-chains.json', 'session-forest.json'):
            assert correspondence['new_inputs'][name] == identity(get(name))
        expected_certificate = identity((ROOT/old_file).read_bytes())
        assert correspondence['accepted_certificate']['identity'] == expected_certificate
        goals = []
        for v in forest['visits']:
            assert not v['detached']
            d, symbol, formula = graph.goal(v['task'], chains[str(v['task'])])
            n, b, q, constructors = graph.count(formula)
            old_visit = old_by_goal[v['goal']]
            assert (v['root'], v['detached']) == (old_visit['root'], old_visit['detached'])
            old_goal = old_cert['tasks'][str(old_visit['task'])]['goal_formula']
            accepted = old_cert['formulas'][str(old_goal)]
            assert (n, b) == (accepted['opened_term_occurrences'], accepted['opened_binder_occurrences'])
            goals.append(dict(goal=v['goal'], root=v['root'], task=v['task'],
                              declaration=d, proposition=symbol, formula=formula,
                              term_occurrences=n, registration_charge=b,
                              quantifier_variable_slots=q, constructor_occurrences=dict(constructors)))
        assert len(goals) == len(chains) == len(old_by_goal)
        assert {v['task'] for v in forest['visits']} == {int(t) for t in chains}
        roots = [g for g in goals if g['root']]
        leaves = [g for g in goals if not g['root']]
        assert len(roots) == 1 and roots[0]['goal'] == 0
        assert sorted(g['goal'] for g in leaves) == list(range(1, len(leaves)+1))
        # Input_Is_Valid classification is the accepted registration filter.
        selected_superset = [g for g in leaves if g['goal'] == 3] if case == 'input_is_valid' else leaves
        row = dict(case=case, pid=process['pid'], all_task_values=len(goals),
                   raw_split_leaves=len(leaves), selected_goal_upper=len(selected_superset),
                   all_domain_max=max(g['registration_charge'] for g in goals),
                   all_domain_sum=sum(g['registration_charge'] for g in goals),
                   root_charge=roots[0]['registration_charge'],
                   raw_leaf_max=max(g['registration_charge'] for g in leaves),
                   raw_leaf_sum=sum(g['registration_charge'] for g in leaves),
                   selected_leaf_max=max(g['registration_charge'] for g in selected_superset),
                   selected_leaf_sum=sum(g['registration_charge'] for g in selected_superset),
                   normal_three_driver_charge=3*sum(g['registration_charge'] for g in selected_superset),
                   raw_goal_stored_terms=len(graph.terms), binding_records=len(graph.bindings),
                   nonempty_binding_records=sum(bool(v) for v in graph.bindings.values()),
                   distinct_saved_variable_images=len(graph.images),
                   checked_raw_blocks=len(graph.reads), old_binder_interpreter_replayed=False)
        # Round 34 counts each first pair once and each repeat against one
        # consumed escape from the same global per-process e <= 2 budget.
        episode = episode_rows[case]
        assert episode['pid'] == process['pid']
        assert episode['registered_goals_upper'] == len(selected_superset)
        active = int(case == 'input_is_valid')
        assert episode['active_preparation_episodes_at_cut'] == active
        assert episode['no_external_assertion']['missing_premises'] == EPISODE_PREMISES
        assert episode['no_external_assertion']['dispatch_bounds'] is None
        named = episode['under_named_existing_premises']
        assert named['missing_premises'] == []
        episodes = named['dispatch_bounds']['preparation_episodes_intersecting_suffix_upper']
        assert episodes == 3*len(selected_superset)+2
        # The active Input_Is_Valid episode is already past update at its
        # inline cut. Remove that call's allowance, not a measured Ident delta.
        completed_call_allowance = selected_superset[0]['registration_charge'] if active else 0
        row['normal_post_cut_charge'] = row['normal_three_driver_charge']-completed_call_allowance
        full = row['normal_three_driver_charge']+2*row['selected_leaf_max']
        row['under_named_existing_episode_premises'] = dict(
            preparation_episodes_intersecting_suffix_upper=episodes,
            global_escaping_signal_save_exceptions_upper=2,
            repeated_pair_goal_charge_upper=2*row['selected_leaf_max'],
            full_episode_goal_charge_upper=full,
            already_returned_update_call_allowance=completed_call_allowance,
            post_cut_goal_charge_upper=full-completed_call_allowance)
        goal_cert[case] = dict(pid=process['pid'], goals=goals,
                               saved_substitution_images=sorted(graph.images),
                               binding_records={str(k): list(v) for k,v in sorted(graph.bindings.items())})
        rows.append(row)
        # Drop each retained block map before loading the next case.
        graph.count.cache_clear(); graph.seq.cache_clear(); graph.mapping.cache_clear()
    classification = read(ROOT/'docs/evidence/retained-producer-fixed-tail-20261018/result.json')['input_is_valid_registration']
    assert classification['registered_goal_ids'] == [3]
    assert classification['endpoint']['not_interesting'] == [1, 2, 4]
    assert [r['selected_leaf_max'] for r in rows] == [236, 190, 181, 28, 15]
    assert sum(r['normal_three_driver_charge'] for r in rows) == 49485
    assert sum(r['normal_post_cut_charge'] for r in rows) == 49470
    composed = [r['under_named_existing_episode_premises'] for r in rows]
    assert [r['preparation_episodes_intersecting_suffix_upper'] for r in composed] == [194, 161, 98, 11, 5]
    assert sum(r['preparation_episodes_intersecting_suffix_upper'] for r in composed) == episode_result['summed_separate_process_episode_upper']
    assert [r['full_episode_goal_charge_upper'] for r in composed] == [25531, 18761, 6266, 152, 75]
    assert sum(r['full_episode_goal_charge_upper'] for r in composed) == 50785
    assert sum(r['post_cut_goal_charge_upper'] for r in composed) == 50770
    result = dict(scope='Direct goal revalidation Ident registrations for retained raw-task domains',
                  cases=rows, normal_full_five_process_charge=49485,
                  normal_post_five_cut_charge=49470,
                  local_shape_count_requires_Ident_freshness=False,
                  no_external_assertion=dict(episode_bound=None, aggregate_goal_charge=None),
                  under_named_existing_episode_premises=dict(
                      required_premises=EPISODE_PREMISES,
                      episode_note=EPISODE_NOTE, episode_result=EPISODE_RESULT,
                      weighted_charge_formula='3*S + e*M, with one global e <= 2 per process',
                      full_five_process_goal_charge_upper=50785,
                      post_five_cut_goal_charge_upper=50770,
                      callback_Ident_work_included=False),
                  complete_Ident_no_wrap=False, complete_preparation_capacity=False,
                  native_runs=0, predecessor_replays=0, source_theorem_machine_checked=False)
    return {'goal-certificate.json': goal_cert, 'result.json': result}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    start = time.monotonic()
    for name, product in calculate().items():
        raw = (json.dumps(product, indent=2)+'\n').encode()
        if args.write:
            (HERE/name).write_bytes(raw)
        else:
            assert (HERE/name).read_bytes() == raw, name
    print(json.dumps(dict(status='pass', cases=5, source_goal_calculation=True,
                          elapsed_seconds=time.monotonic()-start,
                          native_runs=0, predecessor_replays=0), indent=2))


if __name__ == '__main__':
    main()
