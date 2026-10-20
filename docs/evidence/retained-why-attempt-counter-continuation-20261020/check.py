#!/usr/bin/env python3
"""Narrow offline projection/check; no observer, binder, alpha or native replay."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile

from transfer import MAX_INT, PREMISES, bound

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
E = HERE.parent
CAP = E / 'retained-why-save-state-capture-20261020'
JOIN = E / 'retained-why-save-state-join-20261020'
CASES = ['put_line', 'put', 'first_or_default', 'is_message', 'input_is_valid']


def get(p):
    return json.loads(p.read_text())


def ident(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def check_sources():
    cache = {}
    for x in get(HERE / 'source-excerpts.json'):
        key = (x['archive'], x['member'])
        if key not in cache:
            with tarfile.open(ROOT / x['archive']) as t:
                cache[key] = t.extractfile(x['member']).read()
        data = cache[key]
        assert ident(data) == {'bytes': x['member_bytes'], 'sha256': x['member_sha256']}
        part = ''.join(data.decode().splitlines(keepends=True)[x['first'] - 1:x['last']])
        assert part == x['text'] and hashlib.sha256(part.encode()).hexdigest() == x['excerpt_sha256']
    census = get(HERE / 'source-census.json')
    raw = next(v for (a, m), v in cache.items() if m == census['member'])
    actual = [{'line': i, 'text': line} for i, line in enumerate(raw.decode().splitlines(), 1)
              if re.search(r'\b(next_proofAttemptID|gen_proofAttemptID|add_proof_attempt|graft_proof_attempt)\b', line)]
    assert census['references'] == actual
    return len(get(HERE / 'source-excerpts.json'))


def project():
    manifest = get(CAP / 'capture-manifest.json')
    archives = {a['path']: a for a in manifest['archives']}
    old_apps = {x['case']: x for x in get(E / 'retained-why-save-attempt-growth-20261020/applications.json')}
    joins = {x['case']: x for x in get(JOIN / 'result.json')['cases']}
    rows = []
    for case in CASES:
        slug = case.replace('_', '-')
        archive = 'capture-' + slug + '.tar.gz'
        rec = archives[archive]
        assert ident((CAP / archive).read_bytes()) == {k: rec[k] for k in ('bytes', 'sha256')}
        members = {m['path']: m for m in rec['members']}
        comp = get(JOIN / (slug + '-correspondence.json'))
        replay = get(JOIN / (slug + '-replay.json'))
        assert comp['matched'] and replay['complete']
        prefix = ('inline' if case == 'input_is_valid' else 'registration') + '/' + case + '/capture/'
        inputs = {}
        with tarfile.open(CAP / archive) as t:
            def read(name):
                member = prefix + name
                data = t.extractfile(member).read()
                actual = ident(data)
                assert actual == {k: members[member][k] for k in ('bytes', 'sha256')}
                assert actual == comp['new_inputs'][name]
                if name in replay['input_identities']:
                    assert actual == replay['input_identities'][name]
                inputs[name] = actual
                return data
            root = json.loads(read('session-root.json'))
            process = json.loads(read('process.json'))
            state = json.loads(read('save-missing-state.json'))
            raw = read('session-blocks.jsonl')
        assert root['complete'] and state['complete'] and not state['failures']
        # Decode only the captured session record; all other JSONL records are
        # merely scanned for this address, never replayed as an observer graph.
        matches = [json.loads(line) for line in raw.splitlines()
                   if json.loads(line)['address'] == root['session']]
        assert len(matches) == 1
        block = matches[0]
        assert block['tag'] == 0 and block['words'] == 17
        header = int.from_bytes(bytes.fromhex(block['header_hex']), 'little')
        assert header == block['header'] and header >> 10 == 17 and header & 255 == 0
        words = struct.unpack('<17Q', bytes.fromhex(block['payload_hex']))
        assert words[1] & 1 == 1
        signed = struct.unpack('<q', struct.pack('<Q', words[1]))[0]
        n0 = signed >> 1
        assert 0 <= n0 <= MAX_INT
        assert all(s['known'] for s in state['sections'].values())
        sections = {k: v['value'] for k, v in state['sections'].items()}
        pa, ser = sections['proof_attempts'], sections['serializer']
        assert words[0] == pa['pointer'] and root['session'] == state['session']
        ids = [r['key'] for r in pa['entries']]
        membership_ids = [r['value'] for g in ser['goals'] for r in g['attempts']['entries']]
        assert pa['disjoint_finite_chains'] and len(ids) == pa['binding_visits']
        assert len(ids) == len(set(ids)) and set(ids) == {a['id'] for a in ser['attempts']}
        assert all(0 <= i < n0 for i in ids + membership_ids)
        assert set(membership_ids) <= set(ids)
        join = joins[case]
        assert process['pid'] == comp['new_pid'] == join['new_pid']
        assert inputs['save-missing-state.json'] == join['projection_identity']
        assert join['logical_graph_correspondence_established'] and join['extension_decode_replayed_byte_equal']
        assert pa['binding_visits'] == join['captured_A_stats']
        app = old_apps[case]
        k = app['inputs']['pair_entries']
        assert join['conditional_growth']['new_table_bindings_upper']['proofAttempt_table'] == k + 2
        x = {'next_attempt_id0': n0, 'pair_key_domain_upper': k,
             'remaining_signal_exceptions_upper': 2,
             **{p: False for p in PREMISES}}
        x['fresh_counter_and_id_domain_joined'] = True
        x['selected_constructor_callers_joined'] = True
        x['terminal_abandoned_prefix_source_theorem'] = True
        conditional = bound(x)
        assert conditional['nonnegative_counter_and_successor_guard']
        rows.append({'case': case, 'pid': process['pid'], 'phase': state['phase'],
                     'archive': str((CAP / archive).relative_to(ROOT)),
                     'input_identities': inputs, 'session_record': block,
                     'tagged_counter_word': words[1], 'field_index': 1,
                     'initial_attempt_ids': sorted(ids),
                     'initial_membership_ids': sorted(membership_ids),
                     'inputs': x, 'conditional_transfer': conditional})
    return rows


def challenge_checks():
    x = {'next_attempt_id0': 3, 'pair_key_domain_upper': 2,
         'remaining_signal_exceptions_upper': 2, **{p: True for p in PREMISES}}
    assert bound(x)['usable_next_attempt_id_upper'] == 8
    for p in PREMISES:
        y = dict(x); y[p] = False
        assert bound(y)['usable_next_attempt_id_upper'] is None
    for p in ('next_attempt_id0', 'pair_key_domain_upper', 'remaining_signal_exceptions_upper'):
        for bad in (None, -1, True):
            y = dict(x); y[p] = bad
            assert bound(y)['conditional_next_attempt_id_upper'] is None
    y = dict(x, next_attempt_id0=MAX_INT - 5)
    assert bound(y)['usable_next_attempt_id_upper'] == MAX_INT
    y['next_attempt_id0'] += 1
    assert bound(y)['nonnegative_counter_and_successor_guard'] is False
    assert bound(y)['usable_next_attempt_id_upper'] is None
    # Explore increment/publication/abandonment interleavings. This challenges
    # the finite abstraction, not the source/catch proof or native execution.
    def abstract_trace(events, cap, allow_restart=False):
        increments = published = 0
        phase = 'idle'
        for event in events:
            if event == 'increment' and phase == 'idle':
                increments += 1; phase = 'pending'
            elif event == 'publish' and phase == 'pending' and published < cap:
                published += 1; phase = 'idle'
            elif event == 'abandon' and phase == 'pending':
                phase = 'terminal'
            elif event == 'restart' and phase == 'terminal' and allow_restart:
                phase = 'idle'
            else:
                raise ValueError((phase, event))
        return increments, published

    checked = 0
    for k in range(4):
        for e in range(3):
            cap = k + e
            todo, seen = [(0, 0, 'idle')], set()
            while todo:
                increments, published, phase = state = todo.pop()
                if state in seen:
                    continue
                seen.add(state)
                assert increments <= published + 1 <= cap + 1
                if phase == 'idle':
                    todo.append((increments + 1, published, 'pending'))
                elif phase == 'pending':
                    todo.append((increments, published, 'terminal'))
                    if published < cap:
                        todo.append((increments, published + 1, 'idle'))
            checked += len(seen)
            # One abandoned increment is a counterexample to treating published
            # membership count as the increment count, even with zero growth.
            i, m = abstract_trace(['increment', 'abandon'], cap)
            assert i > m
            # If abandoned prefixes could restart, cap+2 unpaired increments
            # would violate the proposed bound: terminality is indispensable.
            events = ['increment', 'abandon', 'restart'] * (cap + 2)
            i, m = abstract_trace(events, cap, allow_restart=True)
            assert m == 0 and i > cap + 1
            try:
                abstract_trace(events, cap)
            except ValueError:
                pass
            else:
                raise AssertionError('terminal model accepted a restart')
    return {'abstract_prefix_states_checked': checked,
            'missing_premise_and_unknown_input_checks': True,
            'exact_maximum_and_first_overflow_boundary_checked': True,
            'publication_only_and_restart_counterexamples_checked': True}


def main():
    ap = argparse.ArgumentParser(); ap.add_argument('--write', action='store_true')
    args = ap.parse_args()
    for path, expected in get(HERE / 'inputs.json').items():
        assert ident((ROOT / path).read_bytes()) == expected, path
    result = {'scope': 'Fresh counter projection plus conditional terminal-prefix arithmetic',
              'source_excerpts_checked': check_sources(), 'cases': project(),
              'challenge_checks': challenge_checks(), 'native_runs': 0,
              'observer_replays': 0, 'binder_recomputations': 0, 'alpha_replays': 0,
              'scheduler_entry_envelope_extended': False,
              'whole_save_capacity_established': False}
    if args.write:
        (HERE / 'result.json').write_text(json.dumps(result, indent=2) + '\n')
    else:
        assert result == get(HERE / 'result.json')
    print(json.dumps({'cases': len(result['cases']), 'source_excerpts': result['source_excerpts_checked'],
                      'counter_uppers': [r['conditional_transfer']['conditional_next_attempt_id_upper'] for r in result['cases']],
                      'checks': result['challenge_checks'], 'native_runs': 0}))


if __name__ == '__main__':
    main()
