#!/usr/bin/env python3
"""Reconcile frozen Debug first-use and hook components without replay."""
import ast
import hashlib
import json
from pathlib import Path
import re
import subprocess
import time

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
CONTROL = 'docs/evidence/retained-why-debug-formatter-control-20261020'
HOOK = 'docs/evidence/retained-why-debug-hook-capacity-20261020'


def git(*args):
    return subprocess.check_output(['git', '-C', str(ROOT), *args])


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def read(name):
    return json.loads((ROOT / name).read_text())


def check():
    inputs = json.loads((HERE / 'inputs.json').read_text())
    checked = []
    for group in ('author_freezes', 'review_freezes'):
        for component, commit in inputs[group].items():
            names = git('diff-tree', '--no-commit-id', '--name-only', '-r', commit)
            for name in names.decode().splitlines():
                expected = identity(git('show', f'{commit}:{name}'))
                actual = identity((ROOT / name).read_bytes())
                assert actual == expected, (component, name)
                checked.append({'group': group, 'component': component,
                                'freeze': commit, 'path': name, **actual})
    native = read('docs/evidence/retained-literal-native-completion-20261019/inputs.json')
    for row in native['repository']:
        assert identity((ROOT / row['path']).read_bytes()) == {
            key: row[key] for key in ('bytes', 'sha256')}, row['path']
    retained = {}
    for packet in (CONTROL, HOOK):
        for name, expected in read(packet + '/inputs.json').items():
            if Path(name).is_absolute():
                continue
            assert name not in retained or retained[name] == expected, name
            retained[name] = expected
    for name, expected in retained.items():
        assert identity((ROOT / name).read_bytes()) == expected, name

    control, hook = read(CONTROL + '/result.json'), read(HOOK + '/result.json')
    assert control['constructor_state_preserved_at_cuts_under_named_relation'] is True
    assert control['constructor_state_preserved_until_first_stats_entry_under_selected_continuation'] is True
    assert control['callback_and_setting_preservation_under_selected_continuation'] is True
    assert control['initial_escape_buffer'] == {'backing_equals_initial': True, 'capacity': 42, 'position': 0}
    assert control['initial_formatter']['queue_length'] == 1
    assert control['initial_formatter']['scan_stack_entries'] == 2
    assert control['newline_wrapper_depth'] == 1
    assert control['earlier_signals_excluded'] is False
    assert control['after_partial_stats_constructor_freshness'] is False
    assert control['arbitrary_global_formatter_freshness_claimed'] is False
    assert (control['global_save_budget_upper'], control['global_callback_opportunities_upper']) == (3, 2)
    assert hook['first_use_provider_freeze'] == inputs['author_freezes']['first_use']
    assert hook['first_use_acceptance_report'] == inputs['review_freezes']['first_use']
    assert hook['cases'] == control['cases']
    assert hook['budgets_restarted'] is False
    assert hook['Debug_newline_wrapper_included_bytes'] == control['newline_wrapper_own_stack_bytes'] == 16
    assert hook['rows_upper'] == 26
    assert hook['main_core_operations_upper'] == 9 * hook['rows_upper'] + 1 == 235
    assert hook['dynamic_queue_insertions_charge_upper'] == 3 * 235 + 1 + 26 * 4 == 810
    assert hook['offered_Buffer_bytes_upper'] == hook['raw_text_bytes_upper'] + 70 * 236 == 26619
    assert hook['owned_hook_stack_to_service_frontiers_bytes'] == 2392 * 3 + 176 * 48 + 32 * 11 + 296 == 16272
    assert hook['owned_initial_plus_new_objects_no_reclamation_envelope'] == hook['source_owned_new_OCaml_requested_block_bytes_upper'] + hook['initial_owned_formatter_Buffer_charge_upper'] == 686128
    for key in ('complete_exit_capacity_established', 'complete_exit_stack_established',
                'complete_save_capacity_established', 'physical_GC_allocator_stack_sufficiency_established',
                'actual_continued_numeric_service_join_established', 'ambient_A_pre_included',
                'C_bridge_GC_runtime_allocator_libc_and_signal_stack_included'):
        assert hook[key] is False, key
    for key in ('complete_exit_capacity', 'complete_exit_stack', 'complete_save_capacity'):
        assert control[key] is False, key
    names = {row['path'] for row in checked}
    names.add(str(Path(__file__).resolve().relative_to(ROOT)))
    parsed, links = [], []
    for name in sorted(names):
        path = ROOT / name
        if path.suffix == '.py':
            ast.parse(path.read_text(), filename=name)
            parsed.append(name)
        if path.suffix == '.md':
            for url in re.findall(r'\]\(([^)]+)\)', path.read_text()):
                if '://' in url or url.startswith('#'):
                    continue
                target = url.split('#')[0]
                assert (path.parent / target).exists(), (name, target)
                links.append({'file': name, 'target': target})
    return {'review_target': inputs['review_target'], 'frozen_files': checked,
            'retained_repository_inputs': retained,
            'native_pins_unchanged': len(native['repository']),
            'cases': hook['cases'],
            'conditional_offered_Buffer_bytes_upper': hook['offered_Buffer_bytes_upper'],
            'conditional_new_OCaml_requested_block_bytes_upper': hook['source_owned_new_OCaml_requested_block_bytes_upper'],
            'conditional_hook_caller_stack_bytes': hook['owned_hook_stack_to_service_frontiers_bytes'],
            'scope': 'One Debug Stats hook under retained source/runtime and normal-service premises; no standard formatter, whole-exit/save or physical-capacity conclusion.',
            'complete_save_capacity_established': False,
            'complete_exit_capacity_established': False,
            'python_sources_parsed': parsed, 'local_document_links': links,
            'target_runs': 0, 'predecessor_checker_replays': 0}


if __name__ == '__main__':
    start = time.monotonic()
    result = check()
    expected = HERE / 'integration-result.json'
    if expected.exists():
        assert result == json.loads(expected.read_text())
    else:
        expected.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({'status': 'pass', 'frozen_files': len(result['frozen_files']),
                      'retained_inputs': len(result['retained_repository_inputs']),
                      'native_pins_unchanged': result['native_pins_unchanged'],
                      'attached_cases': len(result['cases']),
                      'python_parses': len(result['python_sources_parsed']),
                      'local_links': len(result['local_document_links']),
                      'seconds': time.monotonic() - start}))
