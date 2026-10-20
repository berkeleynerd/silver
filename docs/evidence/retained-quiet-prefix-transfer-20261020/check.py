#!/usr/bin/env python3
"""Offline source/capture attachment and arithmetic, without target execution."""
import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
CAP = 'docs/evidence/retained-why-save-state-capture-20261020/'
ROUTE = 'docs/evidence/retained-cvc5-quiet-route-20261020/'
WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
DELTA = 4096


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def read(path):
    return json.loads(path.read_text())


def encoded(data):
    return (json.dumps(data, indent=2) + '\n').encode()


def lex_fixed(raw):
    """Restricted concrete Rc token audit; fail on syntax outside this packet."""
    text = raw.decode('ascii')
    ident = r'[a-zA-Z_][a-zA-Z_0-9+.-]*'
    space = r'[ \t\r\n]'
    pos, mode, cap, growth = 0, 'record', 17, []
    events, strings, current = [], [], []
    while pos < len(text):
        if mode == 'record':
            choices = [('space', space+'+', 'record'),
                       ('record_header', r'\['+ident+space+'*', 'header'),
                       ('record_field', ident+space+'*='+space+'*', 'value')]
        elif mode == 'header':
            choices = [('header_key', ident+space+'*', 'header'),
                       ('header_close', r'\]', 'record')]
        elif mode == 'value':
            choices = [('quote_open', r'"', 'string'),
                       ('integer', r'[+-]?[0-9]+', 'record'),
                       ('boolean', r'true|false', 'record')]
        else:
            choices = [('quote_close', r'"', 'record'),
                       ('ordinary_char', r'[^\\"\r\n]', 'string')]
        for action, pattern, next_mode in choices:
            m = re.match(pattern, text[pos:])
            if m:
                token = m.group()
                events.append((action, len(token)))
                if action == 'quote_open':
                    current = []
                elif action == 'ordinary_char':
                    if len(current) == cap:
                        cap *= 2
                        growth.append(cap)
                    current.append(token)
                elif action == 'quote_close':
                    strings.append(''.join(current))
                pos += len(token)
                mode = next_mode
                break
        else:
            raise AssertionError((pos, mode, text[pos:pos+40]))
    assert mode == 'record'
    events.append(('eof', 0))
    return {'file_bytes': len(raw), 'accepted_actions': len(events),
            'action_counts': dict(sorted(Counter(a for a, _ in events).items())),
            'maximum_token_bytes': max(n for _, n in events),
            'quoted_fields': len(strings), 'max_quoted_bytes': max(map(len, strings)),
            'buffer_growth_capacities': growth, 'final_buffer_capacity': cap}


def derive():
    inputs = read(HERE / 'inputs.json')
    for name, expected in inputs['files'].items():
        assert identity((ROOT/name).read_bytes()) == expected, name
    members = {}
    for archive in sorted({s['archive'] for s in inputs['members']}):
        requested = {s['member']: s['identity'] for s in inputs['members']
                     if s['archive'] == archive}
        with tarfile.open(ROOT/archive) as stream:
            for name, expected in requested.items():
                raw = stream.extractfile(name).read()
                assert identity(raw) == expected, (archive, name)
                members[(archive, name)] = raw
    for witness in read(HERE/'source-witnesses.json'):
        raw = members[(witness['archive'], witness['member'])]
        excerpt = ''.join(raw.decode().splitlines(keepends=True)
                          [witness['first_line']-1:witness['last_line']])
        assert excerpt == witness['text']

    route = read(ROOT/(ROUTE+'route.json'))
    candidate = (ROOT/(ROUTE+'candidate-base-why3.conf')).read_bytes()
    old_cmd, new_cmd = (route['command'][k] for k in ('old', 'new'))
    assert (len(old_cmd), len(new_cmd)) == (44, 167)
    assert all(c not in new_cmd+old_cmd for c in '\\"\r\n')
    baseline = candidate.replace(('command = "'+new_cmd+'"').encode(),
                                 ('command = "'+old_cmd+'"').encode())
    assert identity(baseline) == {k: route['baseline'][k] for k in ('bytes', 'sha256')}
    assert candidate.count(new_cmd.encode()) == 1
    old_lex, new_lex = lex_fixed(baseline), lex_fixed(candidate)
    assert new_lex['accepted_actions']-old_lex['accepted_actions'] == 123
    for action, count in old_lex['action_counts'].items():
        assert new_lex['action_counts'][action]-count == (123 if action == 'ordinary_char' else 0)
    assert old_lex['buffer_growth_capacities'] == [34, 68]
    assert new_lex['buffer_growth_capacities'] == [34, 68, 136, 272]
    assert max(old_lex['maximum_token_bytes'], new_lex['maximum_token_bytes'])+1 < 512
    word_string = lambda n: 1+(n+8)//8
    parts = {'positions': 123*5,
             'new_buffer_backings': word_string(136)+word_string(272),
             'resize_refs': 2*2,
             'contents_growth': word_string(167)-word_string(44),
             'direct_code_lexer_allowance': 123*2*6,
             'first_inline_complete_command_growth': word_string(167)-word_string(44)}
    assert sum(parts.values()) == 2180 < DELTA
    assert (272+8)//8 == 35 < 256
    # Generous charged pointer-field writes, including immediate fields.
    ref_writes = 123*4 + 2 + 123*2*5 + 123*2 + 2 + 20
    assert ref_writes == 1992 < DELTA
    lexer_account = {'baseline': old_lex, 'candidate': new_lex,
                     'allocation_upper_parts_words': parts,
                     'table_generator_registration_upper_words': 689,
                     'either_generator_registration_upper_words': 2165,
                     'first_inline_upper_words': sum(parts.values()),
                     'selected_delta_words': DELTA,
                     'conservative_pointer_write_charge': ref_writes,
                     'selected_remembered_entry_allowance': DELTA,
                     'new_command_queue_elements_before_cuts': 0}

    consumers = []
    with tarfile.open(ROOT/WHY) as archive:
        for entry in sorted(archive.getmembers(), key=lambda m: m.name):
            if entry.name.startswith('why3/src/') and entry.name.endswith(('.ml', '.mll')):
                raw = archive.extractfile(entry).read()
                for line, text in enumerate(raw.decode().splitlines(), 1):
                    if re.search(r'\.command(?:_steps)?\b|\bget_complete_command\b', text):
                        consumers.append({'member': entry.name, 'line': line, 'text': text})

    counts = read(ROOT/'docs/evidence/retained-why-initial-registration-bound-20261020/result.json')
    records, rows = [], []
    for case in counts['cases']:
        name = case['case']
        group = 'inline' if name == 'input_is_valid' else 'registration'
        archive = CAP+'capture-'+name.replace('_', '-')+'.tar.gz'
        prefix = group+'/'+name+'/'
        summary = json.loads(members[(archive, prefix+'capture/summary.json')])
        process = json.loads(members[(archive, prefix+'capture/process.json')])
        plan = json.loads(members[(CAP+'capture-common.tar.gz', group+'/plan.json')])
        invocation = next(i for i in plan['inputs'] if i['name'] == name)
        assert process['pid'] == case['pid']
        assert process['argv'] == invocation['argv']
        assert process['environment'] == invocation['environment']
        assert invocation['environment']['OCAMLRUNPARAM'] == 's=256M,h=16M,M=1000'
        assert plan['file_identities'][invocation['cwd']+'/why3.conf'] == identity(baseline)
        extra_path = invocation['argv'][invocation['argv'].index('--why3-conf')+1]
        assert plan['file_identities'][extra_path] == identity((ROOT/(ROUTE+'candidate-extra-why3.conf')).read_bytes())
        assert members[(archive, prefix+'why3.conf')] == baseline
        assert summary['completed'] and not summary['failures'] and not summary['guard_hits']
        assert not summary['new_threads'] and process['initial_threads'] == 1
        start = summary['baseline']
        end = next(s for s in summary['snapshots'] if s['label'] == case['endpoint'])
        assert start['label'] == 'before_first_why3_module'
        stats = ['stat_minor_words', 'stat_major_words', 'stat_promoted_words',
                 'stat_minor_collections', 'stat_major_collections', 'stat_compactions',
                 'stat_forced_major_collections']
        for snap in (start, end):
            s = snap['state']
            assert snap['native_r14'] == snap['state_address']
            assert snap['minor_allocated_words'] == (s['young_alloc_end']-snap['effective_young_ptr'])//8
            assert s['young_limit'] == s['young_trigger'] == s['young_alloc_start']
            assert s['young_alloc_end']-s['young_alloc_start'] == 8*2**28
            assert s['minor_heap_wsz'] == snap['caml_init_minor_heap_wsz'] == 2**28
            assert snap['caml_init_heap_wsz'] == s['stat_heap_wsz'] == 2**24
            assert snap['caml_custom_major_ratio'] == 1000 and snap['caml_gc_phase'] == 0
            assert all(s[k] == 0 for k in ('in_minor_collection', 'requested_major_slice', 'requested_minor_gc'))
            assert 0 <= s['extra_heap_resources_minor'] < 1
            assert 0 <= snap['caml_extra_heap_resources'] < 1
            assert snap['caml_dependent_size'] == snap['caml_dependent_allocated'] == 0
            assert all(s[k] == start['state'][k] for k in stats)
            for t in snap['tables'].values():
                assert t['used_entries'] == (t['ptr']-t['base'])//t['entry_size']
                assert t['ptr'] < t['threshold'] == t['limit']
                assert (t['threshold']-t['base'])//t['entry_size'] == 2**25
        assert end['minor_allocated_words'] == case['minor_allocated_words']
        minor_upper = end['minor_allocated_words']+DELTA
        major_upper = end['caml_allocated_words']
        assert minor_upper < 2**28 and major_upper < 2**28
        assert 5*case['initial_registration_count'] <= minor_upper < 5*2**62
        table_upper = {k: t['used_entries']+DELTA for k, t in end['tables'].items()}
        assert max(table_upper.values()) < 2**25
        if group == 'inline':
            assert len(summary['driver_preparation']) == 1
            assert summary['driver_preparation'][0]['visited_directives'] == ['counterexamples_dependent_intros', 'inline_trivial']
        records.append({'case': name, 'pid': process['pid'], 'invocation': invocation,
                        'start': start, 'end': end})
        rows.append({'case': name, 'cut': case['endpoint'], 'minor_words': end['minor_allocated_words'],
                     'candidate_minor_upper': minor_upper, 'major_words_unchanged': major_upper,
                     'table_used': {k: v['used_entries'] for k, v in end['tables'].items()},
                     'candidate_table_upper': table_upper,
                     'initial_registration_count_preserved': case['initial_registration_count'],
                     'initial_two_arity_family_union_upper': 2*case['initial_registration_count']})
    old = read(ROOT/'docs/evidence/retained-producer-fixed-tail-20261018/result.json')
    # These are separately checked accepted older-family summary values.
    assert old['maximum_protected_lifetime_words'] == 128847761
    assert old['combined_managed_static_word_budget'] == 131043754
    old_transfer = {'W_upper': old['maximum_protected_lifetime_words']+DELTA,
                    'B_upper': old['combined_managed_static_word_budget']+DELTA}
    old_transfer['byte_length_arithmetic_upper'] = 16*old_transfer['B_upper']+2
    assert old_transfer['B_upper'] < 2**27
    assert old_transfer['W_upper']+1 < 2**47-1
    assert old_transfer['byte_length_arithmetic_upper'] < 2**62-1
    old_archive = 'docs/evidence/retained-producer-fixed-tail-20261018/observations.tar.gz'
    old_rows = []
    for case in counts['cases']:
        name = case['case']
        summary = json.loads(members[(old_archive, name+'/capture/summary.json')])
        assert summary['completed'] and not summary['failures'] and not summary['guard_hits']
        start, end = summary['snapshots'][1], summary['snapshots'][-1]
        assert start['label'] == 'before_first_why3_module' and end['label'] == 'end_of_registration'
        for snap in (start, end):
            s = snap['state']
            assert snap['native_r14'] == snap['state_address']
            assert s['young_limit'] == s['young_trigger'] == s['young_alloc_start']
            assert snap['minor_allocated_words'] == (s['young_alloc_end']-snap['effective_young_ptr'])//8
            assert s['minor_heap_wsz'] == 2**28
            assert snap['minor_allocated_words']+DELTA < 2**28
            assert snap['caml_allocated_words'] < 2**28
            assert snap['caml_gc_phase'] == 0
            assert all(s[k] == 0 for k in ('in_minor_collection', 'requested_major_slice', 'requested_minor_gc'))
            assert all(s[k] == start['state'][k] for k in stats)
            assert 0 <= s['extra_heap_resources_minor'] < 1
            assert 0 <= snap['caml_extra_heap_resources'] < 1
            assert snap['caml_dependent_size'] == snap['caml_dependent_allocated'] == 0
            for t in snap['tables'].values():
                assert t['used_entries'] == (t['ptr']-t['base'])//t['entry_size']
                assert t['threshold'] == t['limit']
                assert (t['threshold']-t['base'])//t['entry_size'] == 2**25
                assert t['used_entries']+DELTA < 2**25
        old_rows.append({'case': name, 'minor_words': end['minor_allocated_words'],
                         'major_words': end['caml_allocated_words'],
                         'table_used': {k: t['used_entries'] for k, t in end['tables'].items()}})
    old_transfer['own_capture_margin_inputs'] = old_rows
    result = {'scope': 'Command-only source transfer under named retained prefix/runtime relation',
              'allocation_delta_upper_words': DELTA, 'remembered_entry_allowance': DELTA,
              'later_capture_cases': rows, 'older_fixed_tail_transfer': old_transfer,
              'prefix_transfer_established_under_named_relation': True,
              'source_simulation_machine_checked': False,
              'exact_heap_identity_claimed': False, 'complete_q': None, 'weighted_O': None,
              'complete_writer_capacity': False, 'production_adopted': False,
              'native_target_runs': 0, 'predecessor_checker_replays': 0}
    return {'lexer-account.json': lexer_account, 'capture-resources.json': records,
            'command-consumers.json': consumers, 'result.json': result}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    start = time.monotonic()
    products = derive()
    for name, result in products.items():
        raw = encoded(result)
        if args.write:
            (HERE/name).write_bytes(raw)
        else:
            assert (HERE/name).read_bytes() == raw, name
    print(json.dumps({'status': 'pass', 'capture_cases': 5, 'derived_products': len(products),
                      'elapsed_seconds': time.monotonic()-start,
                      'native_target_runs': 0, 'predecessor_checker_replays': 0}, indent=2))


if __name__ == '__main__':
    main()
