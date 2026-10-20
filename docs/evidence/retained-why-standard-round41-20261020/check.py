#!/usr/bin/env python3
"""Reconcile accepted standard control and JSON escape inputs; no replay."""
import ast
import hashlib
import json
from pathlib import Path
import re
import subprocess
import time

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
JSON = 'docs/evidence/retained-why-json-byte-escape-20261020'
CONTROL = 'docs/evidence/retained-why-standard-formatter-control-20261020'


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def read(name):
    return json.loads((ROOT / name).read_text())


def git(*args):
    return subprocess.check_output(['git', '-C', str(ROOT), *args])


def check():
    inputs = json.loads((HERE / 'inputs.json').read_text())
    files = []
    for component, commit in inputs['freezes'].items():
        names = git('diff-tree', '--no-commit-id', '--name-only', '-r', commit)
        for name in names.decode().splitlines():
            expected = identity(git('show', f'{commit}:{name}'))
            actual = identity((ROOT / name).read_bytes())
            assert expected == actual, (component, name)
            files.append({'component': component, 'freeze': commit, 'path': name, **actual})
    retained = {name: value for name, value in read(JSON + '/inputs.json').items()
                if not Path(name).is_absolute()}
    control_inputs = read(CONTROL + '/inputs.json')
    for group in ('imports', 'archives'):
        for name, expected in control_inputs[group].items():
            assert name not in retained or retained[name] == expected, name
            retained[name] = expected
    for name, expected in retained.items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    native = read('docs/evidence/retained-literal-native-completion-20261019/inputs.json')
    for row in native['repository']:
        assert identity((ROOT / row['path']).read_bytes()) == {
            key: row[key] for key in ('bytes', 'sha256')}, row['path']
    js, ctrl = read(JSON + '/result.json'), read(CONTROL + '/result.json')
    assert all(value is False or value is None for value in js['actual'].values())
    assert js['actual_joined']['formatter_state_and_callback_ownership'] is False
    assert js['actual_joined']['global_caller_occurrence_and_reentry_bound'] is False
    assert js['actual_joined']['continued_numeric_service_success'] is False
    census = js['all_byte_census']
    assert census['s'] + census['p'] + census['u'] == census['n'] == 256
    assert census['data_bytes'] == 2 + 2*census['s'] + census['p'] + 6*census['u'] == 1045
    assert census['text_operations'] == 2 + census['s'] + census['p'] + 2*census['u'] == 414
    assert census['non_core_requested_object_bytes'] == 72 + 16*census['p'] + 256*census['u'] == 41496
    assert js['conditional']['nonreentrant_string_lane_owned_ocaml_bytes'] == 2456*4 + 176*64 + 32*3 + 120 == 21304
    profile = ctrl['profile_claim']
    assert (profile['margin'], profile['min_space_left'], profile['max_indent']) == (78, 10, 68)
    assert (profile['stdout_newline_wrapper_depth'], profile['stderr_debug_newline_wrapper_depth']) == (0, 1)
    assert profile['location_output_wrapper_depth'] == profile['color_marker_wrapper_depth'] == 0
    assert profile['post_cut_setter_preservation'] is True
    assert ctrl['global_budget_reset'] is False and ctrl['issue_153_complete'] is False
    for key in ('initial_standard_queue_freshness', 'global_queue_prefix_preservation',
                'model_diagnostic_excluded_by_task_meta', 'whole_output_capacity',
                'complete_R', 'complete_U', 'assumed_precut_signal_budget'):
        assert ctrl[key] is None, key
    assert [row['case'] for row in ctrl['cases']] == control_inputs['cases']
    for row in ctrl['cases']:
        assert row['initial_dynamic_state'] is None
        assert row['standard_slot_read_counts'] == {'stdout': 0, 'stderr': 0}
    parsed, links = [], []
    names = {row['path'] for row in files} | {str(Path(__file__).resolve().relative_to(ROOT))}
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
    return {'frozen_files': files, 'retained_repository_inputs': retained,
            'native_pins_unchanged': len(native['repository']),
            'json_all_byte_census': census, 'standard_fixed_profile': profile,
            'initial_standard_states': ctrl['cases'],
            'actual_global_json_exports': js['actual'],
            'scope': 'Accepted component identities and interfaces only; no initial-state, continued-service, whole-output, complete save/exit or physical-capacity join.',
            'python_sources_parsed': parsed, 'local_document_links': links,
            'target_runs': 0, 'predecessor_checker_replays': 0}


if __name__ == '__main__':
    start = time.monotonic()
    result = check()
    output = HERE / 'integration-result.json'
    if output.exists():
        assert result == json.loads(output.read_text())
    else:
        output.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({'status': 'pass', 'frozen_files': len(result['frozen_files']),
                      'retained_inputs': len(result['retained_repository_inputs']),
                      'native_pins_unchanged': result['native_pins_unchanged'],
                      'cases': len(result['initial_standard_states']),
                      'python_parses': len(result['python_sources_parsed']),
                      'local_links': len(result['local_document_links']),
                      'seconds': time.monotonic() - start}))
