#!/usr/bin/env python3
"""Focused frozen-input, source-excerpt and arithmetic review; no target run."""
import argparse
import hashlib
import json
from pathlib import Path
import subprocess
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
WHY = 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
OCAML = 'docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz'
SPEC = {
    OCAML: {
        'stdlib/lexing.ml': [(64, 169)],
        'stdlib/buffer.ml': [(77, 102)],
        'lex/lexgen.ml': [(332, 369)],
        'lex/outputbis.ml': [(57, 81), (227, 245)],
    },
    WHY: {
        'src/core/theory.ml': [(214, 240), (651, 660), (999, 1016)],
        'src/core/task.ml': [(19, 61), (88, 113), (148, 181)],
        'src/driver/driver.ml': [(330, 369), (490, 494)],
        'src/core/ty.ml': [(120, 128), (159, 170), (203, 217), (234, 236)],
        'src/core/decl.ml': [(743, 752), (830, 835)],
        'src/session/session_itp.ml': [(310, 311), (677, 690)],
        'src/session/controller_itp.ml': [(409, 438)],
        'src/util/hcpt.ml': [(113, 158), (509, 518)],
    },
}


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def canonical(value):
    return json.dumps(value, indent=2, sort_keys=True) + '\n'


def run(write):
    inputs = json.loads((HERE / 'inputs.json').read_text())
    frozen = 0
    for group in inputs['freezes']:
        for path, expected in group['files'].items():
            raw = (ROOT / path).read_bytes()
            assert identity(raw) == expected, path
            assert raw == subprocess.check_output(
                ['git', 'show', group['commit'] + ':' + path], cwd=ROOT), path
            frozen += 1
    for path, expected in inputs['inherited_files'].items():
        assert identity((ROOT / path).read_bytes()) == expected, path

    sources, witnesses = {}, []
    for archive, selected in SPEC.items():
        with tarfile.open(ROOT / archive) as stream:
            for suffix, ranges in selected.items():
                members = [n for n in stream.getnames() if n.endswith('/' + suffix)]
                assert len(members) == 1, suffix
                name = members[0]
                raw = stream.extractfile(name).read()
                source = raw.decode()
                sources[suffix] = source
                lines = source.splitlines()
                witnesses.append({'archive': archive, 'member': name, **identity(raw),
                                  'excerpts': [{'first': lo, 'last': hi,
                                                'text': '\n'.join(lines[lo-1:hi])+'\n'}
                                               for lo, hi in ranges]})

    # These anchors detect changed review inputs. Their semantic interpretation
    # is in the report; a substring check is not a call-graph proof.
    for suffix, anchors in {
        'src/driver/driver.ml': ['Task.find_clone_tds task0 th',
                               'Theory.clone_meta tdm th sm', 'add_tdecl task goal'],
        'src/core/task.ml': ['module Stdecl = Hcpt.MakeSet',
                            'Theory.Stdecl.fold Stdecl.add s Stdecl.empty',
                            '| Meta (t,_) -> new_meta task t td'],
        'src/core/theory.ml': ['let clone_meta tdt th sm =',
                              '| MAty ty -> MAty (sm_trans_ty sm.sm_ty sm.sm_ts ty)'],
        'src/core/decl.ml': ['check_match kn d;', 'let rec check () t ='],
        'src/session/session_itp.ml': ['session_raw_tasks'],
    }.items():
        for anchor in anchors:
            assert anchor in sources[suffix], (suffix, anchor)

    # Independently recompute the reviewed command-change allowance.
    string_words = lambda n: 1 + (n + 8) // 8
    words = {'accepted_positions': 123 * 5,
             'new_backings': string_words(136) + string_words(272),
             'resize_refs': 2 * 2,
             'contents_copy_growth': string_words(167) - string_words(44),
             'direct_lexer_tuples': 123 * 2 * 6,
             'complete_command_growth': string_words(167) - string_words(44)}
    assert sum(words.values()) == 2180 < 4096
    assert 123 * 4 + 2 + 123 * 2 * 5 + 123 * 2 + 2 + 20 == 1992 < 4096

    # Reattach the reviewed summary products directly to their original later
    # capture archives, then reconstruct their maxima from native pointers.
    prefix = 'docs/evidence/retained-quiet-prefix-transfer-20261020/'
    captures = json.loads((ROOT / (prefix + 'capture-resources.json')).read_text())
    rows = []
    for row in captures:
        case = row['case']
        family = 'inline' if case == 'input_is_valid' else 'registration'
        archive = ('docs/evidence/retained-why-save-state-capture-20261020/'
                   + 'capture-' + case.replace('_', '-') + '.tar.gz')
        with tarfile.open(ROOT / archive) as stream:
            raw = stream.extractfile(f'{family}/{case}/capture/summary.json').read()
        summary = json.loads(raw)
        end = row['end']
        assert row['start'] == summary['baseline']
        assert end == next(s for s in summary['snapshots'] if s['label'] == end['label'])
        state = end['state']
        minor = (state['young_alloc_end'] - end['effective_young_ptr']) // 8
        assert minor == end['minor_allocated_words']
        assert minor + 4096 < (state['young_alloc_end'] - state['young_trigger']) // 8
        tables = {}
        for name, table in end['tables'].items():
            used = (table['ptr'] - table['base']) // table['entry_size']
            trigger = (table['threshold'] - table['base']) // table['entry_size']
            assert used == table['used_entries'] and used + 4096 < trigger == 2**25
            tables[name] = used
        rows.append({'case': case, 'pid': row['pid'], 'minor_words': minor,
                     'major_words': end['caml_allocated_words'], 'table_entries': tables})
    maxima = {'minor_words': max(r['minor_words'] for r in rows),
              'major_words': max(r['major_words'] for r in rows),
              'table_entries': {k: max(r['table_entries'][k] for r in rows)
                                for k in rows[0]['table_entries']}}
    assert maxima == {'minor_words': 127939731, 'major_words': 945213,
                      'table_entries': {'ref_table': 68961,
                                        'ephe_ref_table': 146291, 'custom_table': 84}}
    old_w, old_b = 128847761 + 4096, 131043754 + 4096
    assert old_b < 2**27 and old_w + 1 < 2**47 - 1
    assert 16 * old_b + 2 == 2096765602 < 2**62 - 1

    accepted = json.loads((ROOT / 'docs/evidence/retained-cvc5-task-acceptance-20261020/result.json').read_text())
    assert accepted['reachable_module_count'] == 47
    assert accepted['reachable_dependency_edges'] == 66
    assert len(accepted['external_roots']) == 10
    assert accepted['driver_use_directives'] == 0
    assert accepted['direct_driver_metadata_loop_identifier_registrations'] == 0
    assert accepted['update_goal_reattachment_registration_charge'] is None
    for row in accepted['initial_identifier_arithmetic']:
        assert row['maximum_additional_registrations_for_no_wrap'] == 2**62 - 1 - row['I']
    assert accepted['continuing_identifier_inequality_instantiated'] is False
    assert accepted['complete_nonaliasing_task_mapping'] is False
    assert accepted['actual_ordinary_attempt_classification'] is None
    assert accepted['complete_q'] is None

    result = {'frozen_files_byte_matched': frozen,
              'inherited_inputs_checked': len(inputs['inherited_files']),
              'source_members_checked': len(witnesses),
              'allocation_parts_words': words, 'allocation_upper_words': sum(words.values()),
              'selected_allowance_words': 4096, 'later_capture_rows': rows,
              'later_capture_maxima': maxima,
              'older_family_W_upper': old_w, 'older_family_B_upper': old_b,
              'complete_q': None, 'complete_O': None, 'whole_capacity_goal_complete': False,
              'native_solver_proof_capture_runs': 0,
              'scope': 'Frozen identities, exact source witnesses, five original capture attachments and bounded arithmetic. Source simulation and origin induction are reviewed reasoning, not proved by this script.'}
    for name, value in [('source-review.json', witnesses), ('result.json', result)]:
        text = canonical(value)
        if write:
            (HERE / name).write_text(text)
        else:
            assert (HERE / name).read_text() == text, name
    print(f'checked {frozen} frozen files, {len(witnesses)} source members, '
          f'{len(rows)} original capture attachments; complete q/O remain null')


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('--write', action='store_true')
    run(parser.parse_args().write)
