#!/usr/bin/env python3
"""Narrow offline status/parent projection from retained stopped session blocks.

This is not the prior collector replay or a binder/alpha computation. Cache
observations, source getter values and recomputed status remain separate.
"""
import argparse
from collections import Counter
import importlib.util
import json
from pathlib import Path
import struct
import tarfile

HERE = Path(__file__).resolve().parent
E = HERE.parent
JOIN = E / 'retained-why-save-state-join-20261020'
HELPER = E / 'retained-why-save-serializer-inputs-20261020/extract.py'
spec = importlib.util.spec_from_file_location('serializer_archive_helpers', HELPER)
helpers = importlib.util.module_from_spec(spec)
spec.loader.exec_module(helpers)
get, identity, check_identity = helpers.get, helpers.ident, helpers.check_identity
CASES = helpers.CASES
SOURCE_RANGES = {
    'why3/src/session/session_itp.ml': [(34, 82), (123, 143), (300, 327),
        (359, 386), (737, 877)],
    'why3/src/driver/call_provers.ml': [(24, 45)],
    'why3/src/gnat/gnat_checks.ml': [(150, 178), (237, 261)],
    'why3/src/session/controller_itp.ml': [(74, 85)],
    'why3/src/gnat/gnat_main.ml': [(298, 305), (332, 336)],
}


def integer(value):
    assert value & 1, ('expected tagged integer', value)
    return (value - (1 << 64) if value >= 1 << 63 else value) >> 1


def boolean(value):
    assert value in (1, 3), ('invalid bool', value)
    return value == 3


class MissingRaw(Exception):
    def __init__(self, pointer):
        self.pointer = pointer
        super().__init__(f'missing retained block {pointer}')


class Blocks:
    def __init__(self, raw):
        self.rows = {}
        self.consumed = set()
        for line in raw.splitlines():
            row = json.loads(line)
            pointer = row['address']
            assert pointer not in self.rows or row == self.rows[pointer], 'conflicting block copies'
            self.rows[pointer] = row

    def block(self, pointer, words=None, tag=0):
        if pointer not in self.rows:
            raise MissingRaw(pointer)
        row = self.rows[pointer]
        payload = bytes.fromhex(row['payload_hex'])
        assert pointer > 0 and pointer % 8 == 0, 'invalid block pointer'
        assert row['header'] == int.from_bytes(bytes.fromhex(row['header_hex']), 'little')
        assert row['tag'] == (row['header'] & 255) == tag, ('block tag mismatch', pointer)
        assert row['words'] == row['header'] >> 10
        assert len(payload) == 8 * row['words']
        assert words is None or row['words'] == words, ('block size mismatch', pointer)
        self.consumed.add(pointer)
        return tuple(struct.unpack('<' + 'Q' * row['words'], payload))

    def values(self, pointer):
        seen, result = set(), []
        while pointer != 1:
            assert pointer not in seen, 'cyclic list'
            seen.add(pointer)
            value, pointer = self.block(pointer, 2)
            result.append(value)
        return result

    def table(self, pointer, integer_keys=True):
        size, array, seed, initial = self.block(pointer, 4)
        heads = self.block(array)
        assert heads and len(heads) & (len(heads)-1) == 0
        rows, seen = [], set()
        for bucket, cell in enumerate(heads):
            while cell != 1:
                assert cell not in seen, 'cyclic or shared bucket chain'
                seen.add(cell)
                k, v, following = self.block(cell, 3)
                if integer_keys:
                    assert integer(k) & (len(heads)-1) == bucket
                rows.append({'bucket': bucket, 'cell': cell, 'raw_key': k,
                    'raw_value': v, 'next': following})
                cell = following
        return {'pointer': pointer, 'array': array, 'size': integer(size),
            'seed': integer(seed), 'initial_size': integer(initial),
            'bucket_capacity': len(heads), 'bucket_heads': list(heads), 'entries': rows}


def matches_projection_table(raw, projection):
    for key in ('pointer', 'array', 'size', 'seed', 'initial_size', 'bucket_capacity', 'bucket_heads'):
        assert raw[key] == projection[key], ('fresh table metadata mismatch', key)
    assert raw['entries'] == [{k: row[k] for k in ('bucket', 'cell', 'raw_key', 'raw_value', 'next')}
                              for row in projection['entries']], 'fresh table entries mismatch'
    assert len(raw['entries']) == projection['binding_visits']
    assert projection['disjoint_finite_chains']


def cache_projection(table, domain, key_decoder=integer):
    rows = [{'key': key_decoder(r['raw_key']), 'value': boolean(r['raw_value'])}
            for r in table['entries']]
    first, counts = {}, Counter()
    for row in rows:
        counts[row['key']] += 1
        first.setdefault(row['key'], row['value'])
    return {'pointer': table['pointer'], 'scalar_size': table['size'],
        'binding_visits': len(rows), 'bucket_capacity': table['bucket_capacity'],
        'size_equals_binding_visits': table['size'] == len(rows), 'bindings': rows,
        'duplicate_keys': sorted(k for k, n in counts.items() if n > 1),
        'out_of_domain_keys': sorted(set(first) - set(domain)),
        'missing_domain_keys': sorted(set(domain) - set(first))}, first


def observed_and_getter(cache, key, default):
    return {'observed_cache_entry': cache.get(key), 'observed_cache_binding_present': key in cache,
            'source_getter_value': cache[key] if key in cache else default,
            'source_getter_uses_default': key not in cache}


def status(blocks, state):
    if state == 1:
        return {'known': True, 'proof_state': 'None', 'result_pointer': None,
                'answer': None, 'missing_raw_block': None}
    shape, result = None, None
    try:
        result, = blocks.block(state, 1)
        shape = 'Some'
        fields = blocks.block(result, 6)
        answer = fields[0]
        if answer & 1:
            index = integer(answer)
            assert 0 <= index < 5, 'unknown constant prover_answer'
            decoded = ['Valid', 'Invalid', 'Timeout', 'OutOfMemory', 'StepLimitExceeded'][index]
        else:
            row = blocks.rows.get(answer)
            if row is None:
                raise MissingRaw(answer)
            assert row['tag'] in (0, 1, 2), 'unknown allocated prover_answer'
            blocks.block(answer, 1, row['tag'])
            decoded = ['Unknown', 'Failure', 'HighFailure'][row['tag']]
        return {'known': True, 'proof_state': 'Some', 'result_pointer': result,
                'answer': decoded, 'missing_raw_block': None}
    except MissingRaw as error:
        return {'known': False, 'proof_state': shape, 'result_pointer': result,
                'answer': None, 'missing_raw_block': error.pointer}


def check_lineage(archive, prefix, comparison, replay):
    assert comparison['matched'] and replay['complete']
    combined = dict(comparison['new_inputs'])
    for name, expected in replay['input_identities'].items():
        assert name not in combined or combined[name] == expected, ('overlapping raw identity mismatch', name)
        combined[name] = expected
    for name, expected in combined.items():
        assert archive.members[f'{prefix}/{name}'][1] == expected, ('archive lineage mismatch', name)
    return combined


def source_witnesses():
    directory = E / 'retained-why-session-helper-source-20261019'
    manifest = get(directory / 'source-identities.json')
    out = []
    with tarfile.open(directory / 'sources.tar.gz') as archive:
        for member, ranges in SOURCE_RANGES.items():
            raw = archive.extractfile(member).read()
            check_identity(raw, manifest['members'][member]['identity'], member)
            lines = raw.decode().splitlines()
            out.append({'member': member, 'identity': identity(raw), 'ranges': [
                {'first': a, 'last': b, 'text': '\n'.join(lines[a-1:b])} for a, b in ranges]})
    return out


def project_case(archive, case, joined):
    slug = case.replace('_', '-')
    group = 'inline' if case == 'input_is_valid' else 'registration'
    prefix = f'{group}/{case}/capture'
    comparison = get(JOIN / (slug + '-correspondence.json'))
    replay = get(JOIN / (slug + '-replay.json'))
    lineage = check_lineage(archive, prefix, comparison, replay)
    read = lambda name: archive.read(f'{prefix}/{name}')
    raw_projection = read('save-missing-state.json')
    projection = json.loads(raw_projection)
    assert identity(raw_projection) == lineage['save-missing-state.json'] == joined['projection_identity']
    assert projection['complete'] and not projection['failures']
    sections = projection['sections']
    assert all(v['known'] for v in sections.values())
    ser = sections['serializer']['value']
    roots = json.loads(read('session-root.json'))
    process = json.loads(read('process.json'))
    forest = json.loads(read('session-forest.json'))['visits']
    summary = json.loads(read('summary.json'))
    inline = case == 'input_is_valid'
    symbols = json.loads(read('session-observer.json' if inline else 'session-symbols.json'))
    blocks = Blocks(read('session-blocks.jsonl'))
    assert roots['complete']
    assert process['pid'] == comparison['new_pid'] == joined['new_pid']
    assert projection['phase'] == comparison['new_phase'] == joined['phase']
    if inline:
        assert symbols['complete'] and symbols['pid'] == process['pid']
        for name, expected in symbols['core_join'].items():
            assert archive.members[f'{prefix}/{name}'][1] == expected
    assert roots['session'] == projection['session']
    handlers = blocks.block(roots['root_words']['signal_handlers']['value'])
    assert handlers[2] == roots['sigint_closure']
    closure = blocks.block(roots['sigint_closure'], 4, 247)
    handler_code = symbols['symbols']['camlGnat_main__fun_14206'] if inline else symbols['checks']['camlGnat_main__fun_14206']['address']
    assert closure[0] == handler_code
    assert closure[2] == roots['controller']
    assert blocks.block(roots['controller'], 6)[0] == roots['session']
    sf = blocks.block(roots['session'], 17)
    goals = {g['goal']: g for g in ser['goals']}
    transformations = {t['id']: t for t in ser['transformations']}
    attempts = {a['id']: a for a in ser['attempts']}
    assert len(goals) == len(ser['goals']) and len(transformations) == len(ser['transformations'])
    assert len(attempts) == len(ser['attempts'])
    assert goals.keys() == set(range(len(goals)))
    for field, domain in [(8, {f['id']: f['pointer'] for f in ser['files']}),
                           (4, {t: row['pointer'] for t, row in transformations.items()})]:
        table = blocks.table(sf[field])
        assert {integer(r['raw_key']): r['raw_value'] for r in table['entries']} == domain
        assert len(table['entries']) == len(domain)
    raw_goal_table = blocks.table(sf[2])
    assert {integer(r['raw_key']): r['raw_value'] for r in raw_goal_table['entries']} == {g: v['pointer'] for g, v in goals.items()}
    assert len(raw_goal_table['entries']) == len(goals)
    raw_attempts = blocks.table(sf[0])
    matches_projection_table(raw_attempts, sections['proof_attempts']['value'])
    assert {integer(r['raw_key']): r['raw_value'] for r in raw_attempts['entries']} == {a: v['pointer'] for a, v in attempts.items()}
    raw_tasks = blocks.table(sf[11])
    tasks = {}
    for row in raw_tasks['entries']:
        tasks.setdefault(integer(row['raw_key']), row['raw_value'])
    assert set(tasks) == set(goals)
    assert len(raw_tasks['entries']) == len(tasks)
    file_rows, theory_rows, theory_by_pointer = [], [], {}
    for file in ser['files']:
        fields = blocks.block(file['pointer'], 5)
        fid = integer(fields[0])
        assert fid == file['id'] and fields[1] == file['path']['pointer']
        assert fields[2] == file['format']['pointer'] and boolean(fields[3]) == bool(file['detached'])
        assert blocks.values(fields[4]) == [t['pointer'] for t in file['theories']]
        file_rows.append({'id': fid, 'pointer': file['pointer'], 'detached': boolean(fields[3]),
                          'theory_ids': [t['name']['id_tag'] for t in file['theories']]})
        for th in file['theories']:
            name, gs, parent, detached = blocks.block(th['pointer'], 4)
            assert name == th['name']['pointer'] and integer(blocks.block(name, 4)[3]) == th['name']['id_tag']
            assert [integer(x) for x in blocks.values(gs)] == th['goals']
            assert integer(parent) == th['parent'] == fid
            assert boolean(detached) == bool(th['detached'])
            row = {'id_tag': th['name']['id_tag'], 'pointer': th['pointer'],
                   'parent_file': fid, 'detached': boolean(detached), 'roots': th['goals']}
            theory_rows.append(row)
            theory_by_pointer[th['pointer']] = row
    assert len(theory_by_pointer) == len(theory_rows)
    cache_rows, cache_maps = {}, {}
    for name, field, domain in [('proof_node_state', 16, goals), ('transformation_state', 15, transformations),
        ('theory_state', 14, [t['id_tag'] for t in theory_rows]), ('file_state', 13, [f['id'] for f in file_rows])]:
        raw = blocks.table(sf[field], integer_keys=name != 'theory_state')
        matches_projection_table(raw, sections[name]['value'])
        key = (lambda p: integer(blocks.block(p, 4)[3])) if name == 'theory_state' else integer
        cache_rows[name], cache_maps[name] = cache_projection(raw, domain, key)
    pa_rows = {}
    for aid, a in attempts.items():
        parent, prover, limits, state, obsolete, script = blocks.block(a['pointer'], 6)
        assert (integer(parent), prover, limits, state, integer(obsolete)) == (
            a['parent'], a['prover']['pointer'], a['limits'], a['proof_state'], a['obsolete'])
        assert a['script'] is None and script == 1
        st = status(blocks, state)
        pa_rows[aid] = {'id': aid, 'pointer': a['pointer'], 'parent_goal': integer(parent),
            'prover': {k: bytes.fromhex(a['prover'][k]['hex']).decode() for k in ('name', 'version', 'alternative')},
            'proof_state_raw': state, 'obsolete': boolean(obsolete), 'decoded_status': st,
            'source_pa_proved': None if not st['known'] else st['answer'] == 'Valid',
            'source_pa_ok': None if not st['known'] else st['answer'] == 'Valid' and not boolean(obsolete)}
    goal_rows, memberships = {}, []
    for gid, g in goals.items():
        name, expl, parent, membership, trans = blocks.block(g['pointer'], 5)
        assert name == g['name']['pointer'] and expl == g['explanation']['pointer']
        assert membership == g['attempts']['pointer']
        assert [integer(x) for x in blocks.values(trans)] == g['transformations']
        p = blocks.rows[parent]
        payload, = blocks.block(parent, 1, p['tag'])
        assert p['tag'] in (0, 1), 'unknown parent variant'
        par = {'kind': 'Trans', 'id': integer(payload)} if p['tag'] == 0 else {
            'kind': 'Theory', 'id_tag': theory_by_pointer[payload]['id_tag']}
        table = blocks.table(membership, integer_keys=False)
        matches_projection_table(table, g['attempts'])
        ids = []
        for raw, decoded in zip(table['entries'], g['attempts']['entries']):
            aid = integer(raw['raw_value'])
            assert aid == decoded['value'] and aid in attempts
            assert pa_rows[aid]['parent_goal'] == gid
            assert decoded['key'] == attempts[aid]['prover'], 'membership/attempt prover mismatch'
            memberships.append({'goal': gid, 'attempt': aid, 'cell': raw['cell']})
            ids.append(aid)
        goal_rows[gid] = {'id': gid, 'pointer': g['pointer'], 'parent': par,
            'task_pointer': tasks[gid], 'detached': False, 'transformations': g['transformations'],
            'attempt_ids_in_binding_order': ids, 'attempt_binding_count': len(ids),
            **observed_and_getter(cache_maps['proof_node_state'], gid, False)}
    trans_rows = {}
    for tid, t in transformations.items():
        name, args, subtasks, parent, detached = blocks.block(t['pointer'], 5)
        assert name == t['name']['pointer'] and args == t['arguments']['pointer']
        assert [integer(x) for x in blocks.values(subtasks)] == t['subtasks']
        assert integer(parent) == t['parent'] and boolean(detached) == bool(t['detached'])
        trans_rows[tid] = {'id': tid, 'pointer': t['pointer'], 'parent_goal': integer(parent),
            'detached': boolean(detached), 'subtasks': t['subtasks'],
            **observed_and_getter(cache_maps['transformation_state'], tid, False)}
        for child in t['subtasks']:
            assert goal_rows[child]['parent'] == {'kind': 'Trans', 'id': tid}, 'parent/child mismatch'
    root_ids = [g for t in theory_rows for g in t['roots']]
    for th in theory_rows:
        for gid in th['roots']:
            assert goal_rows[gid]['parent'] == {'kind': 'Theory', 'id_tag': th['id_tag']}
    assert root_ids == [0] and set(trans_rows) == {0}
    assert goal_rows[0]['transformations'] == [0] and not goal_rows[0]['attempt_ids_in_binding_order']
    assert trans_rows[0]['parent_goal'] == 0 and trans_rows[0]['subtasks'] == list(range(1, len(goals)))
    assert all(not g['transformations'] for gid, g in goal_rows.items() if gid != 0)
    assert len(forest) == len(goals) and {v['goal'] for v in forest} == set(goals)
    for row in forest:
        g = goal_rows[row['goal']]
        assert (row['proof_node'], row['task'], row['detached'], row['root']) == (
            g['pointer'], g['task_pointer'], g['detached'], g['id'] in root_ids)
    # These are source formulas evaluated over captured fields, not target calls.
    for gid, g in goal_rows.items():
        states = [pa_rows[a]['source_pa_ok'] for a in g['attempt_ids_in_binding_order']]
        g['recomputed_from_entry_getters'] = None if any(x is None for x in states) else (
            any(not trans_rows[t]['detached'] and trans_rows[t]['source_getter_value'] for t in g['transformations'])
            or any(states))
    for t in trans_rows.values():
        t['recomputed_from_entry_getters'] = all(goal_rows[g]['detached'] or goal_rows[g]['source_getter_value'] for g in t['subtasks'])
    for th in theory_rows:
        th.update(observed_and_getter(cache_maps['theory_state'], th['id_tag'], not th['roots']))
        th['recomputed_from_entry_getters'] = all(goal_rows[g]['detached'] or goal_rows[g]['source_getter_value'] for g in th['roots'])
    theory_by_id = {t['id_tag']: t for t in theory_rows}
    for f in file_rows:
        f.update(observed_and_getter(cache_maps['file_state'], f['id'], not f['theory_ids']))
        f['recomputed_from_entry_getters'] = all(theory_by_id[t]['detached'] or theory_by_id[t]['source_getter_value'] for t in f['theory_ids'])
    derived_rows = list(goal_rows.values()) + list(trans_rows.values()) + theory_rows + file_rows
    known = all(x['recomputed_from_entry_getters'] is not None for x in derived_rows)
    mismatches = [x for x in derived_rows if x['recomputed_from_entry_getters'] is not None and x['source_getter_value'] != x['recomputed_from_entry_getters']]
    trivial = sorted(a['parent_goal'] for a in pa_rows.values() if a['prover']['name'] == 'Trivial')
    membership_counts = Counter(r['attempt'] for r in memberships)
    relevant_calls = ('schedule_goal', 'run_goal', 'schedule_goal_with_prover', 'prepare_task',
                      'send_request', 'print_task_prepared', 'save_session')
    phase = {'projection_phase': projection['phase'], 'endpoint': comparison['new_phase'],
             'pending_nontrivial_attempt_ids': [a for a, r in pa_rows.items() if r['prover']['name'] != 'Trivial'],
             'inline_task_pointer': summary.get('inline_entry', {}).get('task'),
             'recorded_call_hits': {k: v['hits'] for k, v in summary['forbidden_calls'].items()
                 if any(name in k for name in relevant_calls)},
             'driver_preparation_entry_count': len(summary['driver_preparation']) if 'driver_preparation' in summary else None,
             'driver_preparation_visited_directives': [r['visited_directives'] for r in summary.get('driver_preparation', [])] if 'driver_preparation' in summary else None,
             'driver_input_task_pointer': symbols.get('driver_input_task') if inline else None,
             'driver_input_task_goal_ids': [g for g, task in tasks.items() if task == symbols['driver_input_task']] if inline else None,
             'inline_task_same_pointer_as_leaf_raw_task': summary.get('inline_entry', {}).get('task') in tasks.values() if inline else None,
             'future_scheduling_order': None,
             'scheduler_queue_contents': None,
             'gnat_explmap_and_goalmap_contents': None,
             'unobserved_raw_fields_if_required': ['Gnat_checks.explmap check_rec.to_be_scheduled/to_be_proved/toplevel', 'Gnat_checks.goalmap', 'controller scheduler queue contents']}
    if inline:
        assert phase['driver_input_task_goal_ids'] == [3]
        assert symbols['inline_entry_task'] == phase['inline_task_pointer']
    return {'case': case, 'pid': process['pid'], 'session': roots['session'], 'controller': roots['controller'],
        'sigint_closure': roots['sigint_closure'], 'phase': phase,
        'source_layout_and_projection_crosschecks_pass': True,
        'raw_block_count_consumed': len(blocks.consumed),
        'cache_tables': cache_rows, 'goals': list(goal_rows.values()),
        'transformations': list(trans_rows.values()), 'theories': theory_rows, 'files': file_rows,
        'attempts': list(pa_rows.values()), 'memberships': memberships,
        'attempt_membership_counts': {str(a): membership_counts[a] for a in attempts},
        'unreferenced_attempt_ids': [a for a in attempts if not membership_counts[a]],
        'root_goal_ids': root_ids, 'leaf_goal_ids': list(range(1, len(goals))),
        'synthetic_trivial_leaf_ids': trivial,
        'all_detached_flags_false': all(not x['detached'] for x in derived_rows),
        'all_entry_recomputation_inputs_known': known,
        'entry_getter_update_formula_mismatches': mismatches,
        'entry_cache_or_default_consistency_established': known and not mismatches,
        'observed_cache_completeness_claimed': False,
        'whole_continuation_status_invariant_established': False,
        'input_lineage': {'projection': identity(raw_projection), 'raw_overlap_union': lineage,
            'comparison': identity((JOIN / (slug + '-correspondence.json')).read_bytes()),
            'replay': identity((JOIN / (slug + '-replay.json')).read_bytes())}}


def extract():
    archive = helpers.CaptureArchive()
    joined = get(JOIN / 'result.json')
    by_case = {r['case']: r for r in joined['cases']}
    try:
        cases = [project_case(archive, case, by_case[case]) for case in CASES]
    finally:
        archive.close()
    return {'scope': 'Initial retained status-cache, attempt and forest facts; no continuation invariant asserted',
        'base_commit': '0937ca4a44d012893c7c95517e990f019d1489e6',
        'archive_helper_identity': identity(HELPER.read_bytes()),
        'capture_manifest_identity': identity((helpers.CAPTURE / 'capture-manifest.json').read_bytes()),
        'accepted_state_join_identity': identity((JOIN / 'result.json').read_bytes()),
        'consumed_archive_members': archive.consumed, 'source_witnesses': source_witnesses(),
        'representation_boundary': 'Uses the same retained little-endian 64-bit OCaml record/variant/tagged-value layout as the accepted stopped-state decode; this is not a new compiler/runtime soundness proof.',
        'cases': cases, 'new_captures': 0, 'native_runs': 0, 'prior_collector_replays': 0,
        'binder_recomputations': 0, 'alpha_replays': 0, 'source_fetches': 0}


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true', help='write absent first result')
    args = parser.parse_args()
    result = extract()
    target = HERE / 'result.json'
    if args.write:
        assert not target.exists(), 'refusing to overwrite retained result'
        target.write_text(json.dumps(result, indent=2) + '\n')
    else:
        assert get(target) == result, 'retained projection differs'
    print(json.dumps({'cases': [{'case': r['case'], 'pid': r['pid'],
        'trivial_leaves': len(r['synthetic_trivial_leaf_ids']),
        'entry_consistent': r['entry_cache_or_default_consistency_established']}
        for r in result['cases']], 'retained_result_equal': True}))
