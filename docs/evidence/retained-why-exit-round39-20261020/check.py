#!/usr/bin/env python3
"""Reconcile frozen timing components and their limited data subtotal; no replay."""
import ast
import hashlib
import json
from pathlib import Path
import re
import subprocess
import time

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
FORMAT = 'docs/evidence/retained-why-exit-timing-format-20261020'
GROWTH = 'docs/evidence/retained-why-exit-timing-growth-20261020'


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
    native = read(native_manifest)
    for row in native['repository']:
        assert identity((ROOT / row['path']).read_bytes()) == {
            key: row[key] for key in ('bytes', 'sha256')}, row['path']
    retained = {name: value for name, value in read(FORMAT + '/inputs.json').items()
                if not Path(name).is_absolute()}
    for group in ('imports', 'archives'):
        for name, value in read(GROWTH + '/inputs.json')[group].items():
            assert name not in retained or retained[name] == value, name
            retained[name] = value
    for name, expected in retained.items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    fmt, growth = read(FORMAT + '/result.json'), read(GROWTH + '/result.json')
    assert (growth['global_save_entries_upper'], growth['global_signal_escapes_upper']) == (3, 2)
    assert growth['budgets_restarted'] is False
    assert fmt['complete_save_capacity_established'] is False
    assert fmt['complete_exit_capacity_established'] is False
    assert fmt['actual_float_bytes_upper'] is None
    cases = []
    for row in growth['cases']:
        assert row['complete_save_capacity_established'] is False
        assert row['complete_exit_capacity_established'] is False
        visits = row['debug_timing_callback_entries_whole_suffix_upper']
        key_bytes = row['total_distinct_key_bytes_upper']
        subtotal = key_bytes + visits * fmt['literal_and_conversion_data_bytes_excluding_name_and_formatter_indentation_upper']
        newlines = visits * fmt['explicit_newline_requests_per_template']
        assert (visits, key_bytes, subtotal, newlines) == (26, 1051, 10099, 26)
        cases.append({'case': row['case'], 'pid': row['pid'],
                      'conditional_template_data_bytes_upper': subtotal,
                      'explicit_newline_requests_upper': newlines,
                      'complete_formatter_output_bytes_upper': None,
                      'complete_exit_capacity_established': False,
                      'complete_save_capacity_established': False})
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
            'conditional_template_data_cases': cases,
            'scope': 'Normal numeric-service template data only; excludes formatter-generated indentation, queued output, callbacks and complete exit/save capacity.',
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
                      'joined_cases': len(result['conditional_template_data_cases']),
                      'python_parses': len(result['python_sources_parsed']),
                      'local_links': len(result['local_document_links']),
                      'seconds': time.monotonic() - start}))
