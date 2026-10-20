#!/usr/bin/env python3
"""Join retained provider identities and case attachments, without replay.

The writer partition and its completeness are a source argument for review.
This script checks identities, joins, transcription and explicit scope flags;
it does not prove that semantic argument by checking its declared conclusions.
"""
import argparse
import hashlib
import json
import platform
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def encode(value):
    return (json.dumps(value, indent=2) + '\n').encode()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('--write', action='store_true')
    args = parser.parse_args()
    started = time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())
    start = time.monotonic()
    spec = json.loads((HERE / 'inputs.json').read_bytes())
    for path, expected in spec['imports'].items():
        assert identity((ROOT / path).read_bytes()) == expected, path

    def read(role):
        return json.loads((ROOT / spec['roles'][role]).read_bytes())

    standard = read('standard_result')
    profile = standard['profile_claim']
    assert profile['stdout_newline_wrapper_depth'] == 0
    assert profile['stderr_debug_newline_wrapper_depth'] == 1
    assert profile['location_output_wrapper_depth'] == profile['color_marker_wrapper_depth'] == 0
    debug = read('debug_result')
    assert debug['constructor_state_preserved_at_cuts_under_named_relation']
    assert debug['debug_formatter_is_escape_formatter_under_named_relation']
    flags = read('debug_flags')
    assert not set(flags['potential_enabled_names']) & set(flags['sink_names'])
    assert {'interm_task', 'prepare_for_counterexmp'} <= set(flags['sink_names'])
    routes = read('route_result')
    assert routes['conditional_source_results'] == {
        'pre_cut_SIGINT_save_interruption_excluded': True,
        'ordinary_abort_JSON_failure_is_Not_found': False,
        'registration_iter_leafs_can_recover_after_ordinary_abort_output_failure': False,
        'controller_driver_loading_can_resume_after_Printer_diagnostic': False}
    assert routes['initial_standard_dynamic_state'] == {'stdout': None, 'stderr': None}
    assert standard['initial_standard_queue_freshness'] is None
    query = read('signal_query')
    assert not query['target_loaded'] and not query['target_executed'] and query['returncode'] == 0

    # Reference existing witness rows, without copying or regenerating bodies.
    witness_refs = []
    for selection in spec['source_selections']:
        rows = json.loads((ROOT / selection['provider']).read_bytes())
        rows = [r for r in rows if r.get('source', r.get('member')) == selection['source']
                and r.get('first', r.get('first_line')) == selection['first']
                and r.get('last', r.get('last_line')) == selection['last']]
        assert len(rows) == 1, selection
        row = rows[0]
        text = row.get('excerpt', row.get('text'))
        for anchor in selection['anchors']:
            assert anchor in text, (selection['id'], anchor)
        witness_refs.append(dict(id=selection['id'], provider=selection['provider'],
                                 source=selection['source'], first=selection['first'], last=selection['last'],
                                 excerpt_identity=identity(text.encode())))

    prefix = {r['case']: r for r in read('prefix_cases')}
    config = {r['case']: r for r in read('standard_cases')}
    debug_cases = {r['case']: r for r in read('debug_cases')}
    observer = read('route_cases')
    guards = {r['name']: r for r in observer['cases']}
    old = {r['case']: r for r in standard['cases']}
    assert set(prefix) == set(config) == set(debug_cases) == set(guards) == set(old)
    joined = []
    for name, pid in spec['cases']:
        p, c, d, g = prefix[name], config[name], debug_cases[name], guards[name]
        assert p['pid'] == c['pid'] == d['pid'] == g['pid'] == pid
        assert p['argv'] == c['process']['argv'] == d['argv']
        assert p['environment'] == c['process']['environment'] == d['environment']
        assert p['exit_gate_raw_values'] == d['exit_gate_raw_values'] == [3, 3]
        assert c['persistent_gates'] == [True, True]
        assert not p['registered_statistics_roots'] and not d['registered_statistics_roots']
        assert p['initial_threads'] == 1 and not p['new_threads'] and not g['new_threads']
        assert p['load_bias'] == c['load_bias'] == g['load_bias']
        assert c['initial_standard_dynamic_state'] is None and old[name]['initial_dynamic_state'] is None
        assert c['standard_slot_read_coverage'] == {'stdout': [], 'stderr': []}
        assert old[name]['standard_slot_read_counts'] == {'stdout': 0, 'stderr': 0}
        for key in ['/process.json', '/exit-hook-roots.json']:
            member = d['members'][key]
            assert c['selected_members'][member['member']] == member['identity']
        process_member = d['members']['/process.json']['member']
        assert {k: observer['members'][process_member][k] for k in ['bytes', 'sha256']} == d['members']['/process.json']['identity']
        assert 'WHY3DEBUG' not in p['environment'] and 'GNATWHY3LOG' not in p['environment']
        assert c['overlay']['text'] == '[main]\nmagic = 14\n'
        assert c['config_identity'] == spec['config_identity']
        assert not g['failures'] and g['completed'] and g['sole_continue']
        assert all(r['hits'] == 0 for r in g['forbidden_calls'].values())
        for symbol in ['camlWhy3__Driver__print_task_prepared_3460', 'camlWhy3__Prove_client__send_request_1156']:
            assert symbol in g['forbidden_calls']
        if name == 'input_is_valid':
            assert p['directives'] == g['visited_directives'] == ['counterexamples_dependent_intros', 'inline_trivial']
            assert g['driver_preparation_count'] == 1
            assert g['save_entry_guards'] == ['camlGnat_main__save_session_and_exit_3133', 'camlWhy3__Session_itp__save_session_4339']
        else:
            assert not p['directives'] and p['cut_symbol'] == 'camlGnat_checks__iter_2373'
            assert 'camlWhy3__Driver__prepare_task_3376' in g['forbidden_calls']
        joined.append(dict(case=name, pid=pid, cut_symbol=p['cut_symbol'], phase=p['phase'],
                           cut_elf_relative_pc=p['cut_elf_relative_pc'], actual_directives=p['directives'],
                           config_identity=c['config_identity'], persistent_exit_gates=[True, True],
                           zero_hit_forbidden_entries=sorted(g['forbidden_calls']),
                           standard_root_pointer_reads={'stdout': 0, 'stderr': 0},
                           conditional_source_constructor_state=True,
                           observed_standard_graph=False,
                           state_instances=['stdout', 'stderr'],
                           source_states_distinct=True))

    # This is a transcription from the standard constructor witnesses, not
    # a transfer of the observed Debug record or its Buffer's capacity.
    state = dict(
        queue=dict(length=1, cell_count=1, first_is_last=True, last_next='Nil',
                   token=dict(kind='Pp_begin', indent=0, box_type='Pp_hovbox', size='Size.unknown', length=0)),
        scan_stack=dict(length=2, top_to_bottom=[
            dict(left_total=1, queue_elem='same system token as queue cell content'),
            dict(left_total=-1, queue_elem=dict(kind='Pp_text', text='', size='Size.unknown', length=0),
                 sentinel_in_queue=False)]),
        format_stack=dict(length=0, entries=[]), tbox_stack=dict(length=0, entries=[]),
        tag_stack=dict(length=0, entries=[]), mark_stack=dict(length=0, entries=[]),
        margin=78, min_space_left=10, max_indent=68, space_left=78, current_indent=0,
        is_new_line=True, left_total=1, right_total=1, curr_depth=1,
        max_boxes=(1 << 62) - 1, ellipsis='.', print_tags=False, mark_tags=False)
    for key in ['margin', 'min_space_left', 'max_indent', 'max_boxes', 'ellipsis', 'print_tags', 'mark_tags']:
        assert state[key] == profile[key]
    callbacks = {}
    for name in ['stdout', 'stderr']:
        callbacks[name] = dict(out_string='Stdlib.output_substring partially applied to Stdlib.' + name,
                               out_flush='closure calling Stdlib.flush on Stdlib.' + name,
                               out_spaces='Format.display_blanks on this formatter',
                               out_indent='Format.display_blanks on this formatter',
                               out_newline='Format.display_newline on this formatter' if name == 'stdout' else
                               'one Debug wrapper: captured default newline, then captured stderr channel flush',
                               newline_wrapper_depth=0 if name == 'stdout' else 1,
                               mark_open_tag='Format.default_pp_mark_open_tag',
                               mark_close_tag='Format.default_pp_mark_close_tag',
                               print_open_tag='ignore', print_close_tag='ignore',
                               channel_buffer_state=None)
    ledger = json.loads((HERE / 'writer-partition.json').read_bytes())
    assert [r['id'] for r in ledger] == spec['writer_partition_ids']
    for row in ledger:
        assert row['disposition'] in ['excluded_before_cut', 'different_owner', 'callback_fields_only']
        assert all(path in spec['imports'] for path in row['providers'])
    result = dict(
        scope='source-derived state at the five retained debugger-controlled cuts only',
        source_composition=dict(complete_selected_standard_mutator_partition=True,
                                constructor_dynamic_state_preserved_at_all_five_cuts=True,
                                conditional_on=spec['premises'], semantic_argument_proved_by_checker=False,
                                remaining_pre_cut_writer=None),
        constructor_state_template=state, callbacks=callbacks, cases=joined,
        observed_raw_standard_graphs=False, observed_raw_standard_root_pointers=False,
        historical_null_exports_preserved=True, debug_buffer_transferred=False,
        suffix_constructor_freshness=False, suffix_no_SIGINT=False,
        uncontrolled_production_prefix_claim=False, global_budget_reset=False,
        complete_formatter_capacity=False, complete_exit_capacity=False, complete_save_capacity=False,
        complete_R=False, complete_U=False, physical_memory_sufficiency=False, physical_stack_sufficiency=False,
        issue_153_complete=False,
        review_status='combined independent review of dab652f5cc and this join pending at aggregate freeze',
        executions=dict(target=0, capture=0, debugger_query=0, native_query=0, disassembler=0,
                        source_fetch=0, new_source_census=0, predecessor_checker=0, proof_suite=0))
    outputs = {'source-references.json': witness_refs, 'result.json': result}
    for name, value in outputs.items():
        if args.write:
            (HERE / name).write_bytes(encode(value))
        else:
            assert json.loads((HERE / name).read_bytes()) == value, name
    elapsed = time.monotonic() - start
    round_record = dict(started_utc=started, completed_utc=time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime()),
                        focused_check_seconds=elapsed, native_platform=platform.system() + '-' + platform.machine(),
                        selected_model='GPT-6 Astra', selected_effort='Extra High', runtime_confirmed_model=None,
                        runtime_confirmed_effort=None, token_usage=None, monetary_cost=None, live_harness_goal=None,
                        intended='compose exact standard initial states from retained source/control providers',
                        achieved='conditional constructor dynamics at five cuts; stdout channel default, stderr one Debug wrapper',
                        material_findings='both first counterexample-transform branches included; no suffix no-signal/freshness transfer',
                        check_rework='first attempt rejected an unqualified constructor anchor; corrected it to the retained Stdlib.stdout/stderr spelling before rerun',
                        independent_review='one combined review requested at final aggregate freeze',
                        executions=result['executions'])
    if args.write:
        (HERE / 'round.json').write_bytes(encode(round_record))
    print(json.dumps(dict(status='pass', seconds=elapsed, imported_files=len(spec['imports']),
                          source_references=len(witness_refs), cases=len(joined), new_native_bodies=0)))


if __name__ == '__main__':
    main()
