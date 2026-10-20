#!/usr/bin/env python3
"""Reconcile Round38 frozen files, native pins and stack join; no replay."""
import ast
import hashlib
import json
from pathlib import Path
import re
import subprocess
import time

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent


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
            for name in git('diff-tree', '--no-commit-id', '--name-only', '-r', commit).decode().splitlines():
                expected = identity(git('show', f'{commit}:{name}'))
                actual = identity((ROOT / name).read_bytes())
                assert actual == expected, (component, name)
                checked.append({'group': group, 'component': component,
                                'freeze': commit, 'path': name, **actual})
    native_manifest = 'docs/evidence/retained-literal-native-completion-20261019/inputs.json'
    native_raw = (ROOT / native_manifest).read_bytes()
    native = json.loads(native_raw)
    for row in native['repository']:
        assert identity((ROOT / row['path']).read_bytes()) == {
            key: row[key] for key in ('bytes', 'sha256')}, row['path']
    join = json.loads((HERE / 'save-stack-join.json').read_text())
    for name, expected in join['inputs'].items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    s = read('docs/evidence/retained-why-save-serializer-stack-20261020/result.json')['cases']
    t = read('docs/evidence/retained-why-save-stack-helper-closure-20261020/result.json')['cases']
    gf = read('docs/evidence/retained-why-save-binder-formatter-stack-20261020/result.json')['cases']
    assert (join['global_max_saves'], join['global_max_callbacks'],
            join['direct_bridge_high_water_bytes'], join['dispatch_to_save_shell_bytes']) == (3, 2, 4104, 816)
    assert join['complete_save_stack_established'] is False
    for row, sr, tr, gr in zip(join['cases'], s, t, gf, strict=True):
        assert row['case'] == sr['case'] == tr['case'] == gr['case']
        assert row['fresh_pid'] == sr['fresh_pid'] == tr['fresh_pid'] == gr['fresh_pid']
        S, T, G, F = (sr['owned_complete_to_imports_bytes'], tr['task_selection_complete_to_services_bytes'],
                       gr['complete_goal_explanation_or_opening_to_services_bytes'],
                       gr['selected_formatter_and_internal_name_constant_to_imports_bytes'])
        assert (row['S'], row['T'], row['G'], row['F']) == (S, T, G, F)
        assert (T, G, F) == (sr['task_selection_import_T_bytes'],
                            sr['goal_explanation_and_opening_import_G_bytes'],
                            sr['formatter_name_constant_import_F_bytes'])
        assert row['owned_save_caller_per_save_bytes'] == S + T + G + F
        assert row['r3_e2_save_phase_projection_bytes'] == 3 * (S + T + G + F + 4104) + 2 * 816
        assert row['complete_save_stack'] is None and row['complete_save_capacity'] is False
    changed = set(git('diff', '--name-only', inputs['base'], inputs['review_target']).decode().splitlines())
    changed.add(str(Path(__file__).resolve().relative_to(ROOT)))
    parsed, links = [], []
    for name in sorted(changed):
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
            'native_manifest': {'path': native_manifest, **identity(native_raw)},
            'native_pins_unchanged': len(native['repository']),
            'joined_save_cases': len(join['cases']), 'python_sources_parsed': parsed,
            'local_document_links': links, 'native_runs': 0, 'predecessor_checker_replays': 0}


if __name__ == '__main__':
    start = time.monotonic()
    result = check()
    expected = HERE / 'integration-result.json'
    if expected.exists():
        assert result == json.loads(expected.read_text())
    else:
        expected.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({'status': 'pass', 'frozen_files': len(result['frozen_files']),
                      'native_pins_unchanged': result['native_pins_unchanged'],
                      'joined_save_cases': result['joined_save_cases'],
                      'python_parses': len(result['python_sources_parsed']),
                      'local_links': len(result['local_document_links']),
                      'seconds': time.monotonic() - start}))
