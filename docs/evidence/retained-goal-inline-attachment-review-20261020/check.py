#!/usr/bin/env python3
"""Independent raw goal-shape and fresh inline graph/table audit; no target run."""
import argparse
from functools import lru_cache
import hashlib
import json
from pathlib import Path
import struct
import subprocess
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
CAP = ROOT / 'docs/evidence/retained-why-save-state-capture-20261020'
WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
SOURCE_RANGES = {
    'src/driver/driver.ml': [(330, 369)],
    'src/core/task.ml': [(148, 181)],
    'src/core/decl.ml': [(636, 649), (697, 707), (743, 752), (756, 788), (810, 835)],
    'src/core/term.ml': [(36, 39), (739, 831), (1284, 1294)],
    'src/core/pattern.ml': [(20, 152)],
    'src/core/ident.ml': [(187, 192)],
}


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def canonical(value):
    return json.dumps(value, indent=2, sort_keys=True) + '\n'


def raw_goal_counts(case):
    family = 'inline' if case == 'input_is_valid' else 'registration'
    prefix = f'{family}/{case}/capture/'
    with tarfile.open(CAP / ('capture-' + case.replace('_', '-') + '.tar.gz')) as stream:
        rows = (json.loads(line) for line in stream.extractfile(prefix + 'session-blocks.jsonl'))
        blocks = {}
        for row in rows:
            raw = bytes.fromhex(row['payload_hex'])
            assert len(raw) == row['words'] * 8
            assert row['tag'] == row['header'] & 255
            row['fields'] = struct.unpack('<' + 'Q' * row['words'], raw)
            assert row['address'] not in blocks
            blocks[row['address']] = row
        chains = json.loads(stream.extractfile(prefix + 'session-task-chains.json').read())
        forest = json.loads(stream.extractfile(prefix + 'session-forest.json').read())
        process = json.loads(stream.extractfile(prefix + 'process.json').read())

    def fields(pointer, length=None):
        out = blocks[pointer]['fields']
        assert length is None or len(out) == length
        return out

    def sequence(pointer):
        out, seen = [], set()
        while pointer != 1:
            assert pointer not in seen
            seen.add(pointer)
            value, pointer = fields(pointer, 2)
            out.append(value)
        return out

    def variable_values(pointer):
        if pointer == 1:
            return 0
        left, _, value, right, _ = fields(pointer, 5)
        node = fields(value, 4)[0]
        assert not node & 1 and blocks[node]['tag'] == 0
        fields(node, 1)
        return 1 + variable_values(left) + variable_values(right)

    @lru_cache(None)
    def shape(pointer):
        node = fields(pointer, 4)[0]
        if node & 1:
            assert node in (1, 3)
            return 1, 0, 0
        tag, values = blocks[node]['tag'], fields(node)
        children, binders, saved = [], 0, 0
        if tag in (0, 1):
            pass
        elif tag == 2:
            children = sequence(values[1])
        elif tag == 3:
            children = list(values)
        elif tag in (4, 6):
            _, info, body = fields(values[1] if tag == 4 else values[0], 3)
            binders = 1
            saved = variable_values(fields(info, 2)[1])
            children = [body] + ([values[0]] if tag == 4 else [])
        elif tag == 5:
            raise AssertionError('Tcase in raw goal; Pattern.compile charge required')
        elif tag == 7:
            variables, info, triggers, body = fields(values[1], 4)
            binders = len(sequence(variables))
            saved = variable_values(fields(info, 2)[1])
            children = [body] + [child for tr in sequence(triggers) for child in sequence(tr)]
        elif tag == 8:
            children = list(values[1:])
        elif tag == 9:
            children = [values[0]]
        else:
            raise AssertionError(tag)
        total = [1, binders, saved]
        for child in children:
            total = [a + b for a, b in zip(total, shape(child))]
        return tuple(total)

    goals = []
    for visit in forest['visits']:
        chain = chains[str(visit['task'])]
        node = fields(chain[0]['tdecl'])[0]
        assert blocks[node]['tag'] == 0
        declaration, = fields(node, 1)
        prop = fields(declaration, 3)[0]
        assert blocks[prop]['tag'] == 5
        kind, _, formula = fields(fields(prop, 1)[0], 3)
        assert kind == 5
        terms, binders, saved = shape(formula)
        goals.append({'goal': visit['goal'], 'root': visit['root'],
                      'task': visit['task'], 'formula': formula,
                      'term_occurrences': terms, 'binder_occurrences': binders,
                      'saved_variable_value_occurrences': saved})
    assert len({g['goal'] for g in goals}) == len(goals)
    return {'case': case, 'pid': process['pid'], 'goals': sorted(goals, key=lambda g: g['goal']),
            'sum_all_goal_binders': sum(g['binder_occurrences'] for g in goals),
            'max_all_goal_binders': max(g['binder_occurrences'] for g in goals),
            'sum_nonroot_goal_binders': sum(g['binder_occurrences'] for g in goals if not g['root']),
            'max_nonroot_goal_binders': max(g['binder_occurrences'] for g in goals if not g['root'])}


def inline_attachment():
    with tarfile.open(CAP / 'capture-input-is-valid.tar.gz') as stream:
        prefix = 'inline/input_is_valid/capture/'
        graph = json.loads(stream.extractfile(prefix + 'inline-entry-graph.json').read())
        table = json.loads(stream.extractfile(prefix + 'hsdecl-table.json').read())
    old_path = ROOT / 'docs/evidence/retained-why-preparation-entry-20261018/capture.tar.gz'
    with tarfile.open(old_path) as stream:
        old = json.loads(stream.extractfile('capture/inline-entry-graph.json').read())
    assert len(old['roots']) == len(graph['input_declaration_roots']) == 244
    pending = list(zip(old['roots'], graph['input_declaration_roots']))
    forward, inverse = {}, {}
    while pending:
        a, b = pending.pop()
        if a & 1 or b & 1:
            assert a == b
            continue
        if a in forward:
            assert forward[a] == b
            continue
        assert b not in inverse
        forward[a], inverse[b] = b, a
        x, y = old['blocks'][str(a)], graph['blocks'][str(b)]
        assert (x['tag'], x['words']) == (y['tag'], y['words'])
        if 'fields' in x:
            assert len(x['fields']) == len(y['fields']) == x['words']
            pending.extend(zip(x['fields'], y['fields']))
        else:
            assert x['payload_hex'] == y['payload_hex']
    assert len(forward) == len(old['blocks']) == 14477
    slots = [key for bucket in table['buckets'] for key in bucket['payload'][2:]]
    occupied = [key for key in slots if key != table['ephe_none_value']]
    assert len(table['buckets']) == 5003 and len(slots) == 11968
    assert len(occupied) == len(set(occupied)) == 6704
    assert set(occupied) == set(graph['hsdecl_declaration_roots'])
    return {'complete_graph_blocks': len(graph['blocks']), 'input_roots': 244,
            'exact_input_isomorphism_blocks': len(forward),
            'outer_buckets': len(table['buckets']), 'allocated_slots': len(slots),
            'distinct_occupied_slots': len(set(occupied)),
            'direct_accounted_fold_registrations': 235 + 6 * 123 + 4 + 168,
            'direct_accounted_fold_counter_upper': 60496 + 1145}


def run(write):
    inputs = json.loads((HERE / 'inputs.json').read_text())
    matched = 0
    for group in inputs['freezes']:
        for path, expected in group['files'].items():
            raw = (ROOT / path).read_bytes()
            assert identity(raw) == expected
            assert raw == subprocess.check_output(['git', 'show', group['commit'] + ':' + path], cwd=ROOT)
            matched += 1
    for path, expected in inputs['inherited_files'].items():
        assert identity((ROOT / path).read_bytes()) == expected
    sources = []
    with tarfile.open(ROOT / WHY) as stream:
        for suffix, ranges in SOURCE_RANGES.items():
            member = 'why3/' + suffix
            raw = stream.extractfile(member).read()
            lines = raw.decode().splitlines()
            sources.append({'archive': WHY, 'member': member, **identity(raw),
                            'excerpts': [{'first': lo, 'last': hi,
                                          'text': '\n'.join(lines[lo-1:hi])+'\n'}
                                         for lo, hi in ranges]})
    goals = [raw_goal_counts(case) for case in
             ('put_line', 'put', 'first_or_default', 'is_message', 'input_is_valid')]
    author_dir = ROOT / 'docs/evidence/retained-why-goal-revalidation-20261020'
    certificate = json.loads((author_dir / 'goal-certificate.json').read_text())
    author = json.loads((author_dir / 'result.json').read_text())
    for row in goals:
        expected_goals = {g['goal']: g for g in certificate[row['case']]['goals']}
        assert len(row['goals']) == len(expected_goals)
        for goal in row['goals']:
            other = expected_goals[goal['goal']]
            assert (goal['task'], goal['formula'], goal['root'], goal['term_occurrences'],
                    goal['binder_occurrences']) == (
                        other['task'], other['formula'], other['root'],
                        other['term_occurrences'], other['registration_charge'])
        other = next(r for r in author['cases'] if r['case'] == row['case'])
        assert row['sum_all_goal_binders'] == other['all_domain_sum']
        assert row['max_all_goal_binders'] == other['all_domain_max']
        assert row['sum_nonroot_goal_binders'] == other['raw_leaf_sum']
        selected = [g for g in row['goals'] if
                    (g['goal'] == 3 if row['case'] == 'input_is_valid' else not g['root'])]
        maximum = max(g['binder_occurrences'] for g in selected)
        subtotal = sum(g['binder_occurrences'] for g in selected)
        row['selected_maximum'] = maximum
        row['selected_sum'] = subtotal
        row['normal_full_charge'] = 3 * subtotal
        row['two_escape_full_charge'] = 3 * subtotal + 2 * maximum
        already = 15 if row['case'] == 'input_is_valid' else 0
        row['normal_post_cut_charge'] = row['normal_full_charge'] - already
        row['two_escape_post_cut_charge'] = row['two_escape_full_charge'] - already
        assert (maximum, subtotal) == (other['selected_leaf_max'], other['selected_leaf_sum'])
    totals = {key: sum(r[key] for r in goals) for key in
              ('normal_full_charge', 'normal_post_cut_charge',
               'two_escape_full_charge', 'two_escape_post_cut_charge')}
    assert list(totals.values()) == [49485, 49470, 50785, 50770]
    composed = author['under_named_existing_episode_premises']
    assert composed['full_five_process_goal_charge_upper'] == totals['two_escape_full_charge']
    assert composed['post_five_cut_goal_charge_upper'] == totals['two_escape_post_cut_charge']
    assert composed['callback_Ident_work_included'] is False
    assert author['no_external_assertion'] == {'episode_bound': None, 'aggregate_goal_charge': None}
    assert author['complete_Ident_no_wrap'] is False
    fresh = json.loads((ROOT / 'docs/evidence/retained-why-fresh-inline-attachment-20261020/result.json').read_text())
    assert fresh['source_registration_charge']['total'] == 1145
    assert fresh['pending_save_report_registration_charge_included'] is False
    assert fresh['whole_continuation_registration_bound'] is None
    assert fresh['complete_native_transform_capacity'] is False
    result = {'frozen_files_byte_matched': matched, 'goal_counts': goals,
              'sums_over_five_separate_processes': totals,
              'fresh_inline_attachment': inline_attachment(),
              'complete_q': None, 'complete_O': None, 'whole_capacity_goal_complete': False,
              'native_solver_proof_capture_runs': 0,
              'scope': 'Independent raw goal-shape counts under variable-only saved substitutions; exact fresh input sharing/payload and slot census. Source argument and author representative projection remain separate.'}
    for name, value in [('result.json', result), ('source-review.json', sources)]:
        text = canonical(value)
        if write:
            (HERE / name).write_text(text)
        else:
            assert (HERE / name).read_text() == text
    print(f'checked {matched} frozen files; independently counted {sum(len(g["goals"]) for g in goals)} '
          'raw goals, 14477 exact input blocks and all 11968 table slots; complete q/O remain null')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    run(parser.parse_args().write)
