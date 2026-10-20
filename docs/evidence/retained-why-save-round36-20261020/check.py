#!/usr/bin/env python3
"""Reconcile exact author freezes, native pins and local links without replay."""
import ast
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent


def git(*args):
    return subprocess.check_output(['git', '-C', str(ROOT), *args])


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def check():
    inputs = json.loads((HERE / 'inputs.json').read_text())
    overrides = {}
    for commit in inputs.get('clarifications', []):
        for name in git('diff-tree', '--no-commit-id', '--name-only', '-r', commit).decode().splitlines():
            overrides[name] = commit
    author_files = []
    for component, commit in inputs['freezes'].items():
        for name in git('diff-tree', '--no-commit-id', '--name-only', '-r', commit).decode().splitlines():
            checked_revision = overrides.get(name, commit)
            expected = identity(git('show', f'{checked_revision}:{name}'))
            actual = identity((ROOT / name).read_bytes())
            assert actual == expected, (component, name)
            author_files.append({'component': component, 'author_freeze': commit,
                                 'checked_revision': checked_revision,
                                 'path': name, **actual})
    assert set(overrides) <= {row['path'] for row in author_files}
    native_manifest = 'docs/evidence/retained-literal-native-completion-20261019/inputs.json'
    native_raw = (ROOT / native_manifest).read_bytes()
    native = json.loads(native_raw)
    for row in native['repository']:
        assert identity((ROOT / row['path']).read_bytes()) == {
            key: row[key] for key in ('bytes', 'sha256')}, row['path']
    changed = git('diff', '--name-only', inputs['base'], inputs['review_target']).decode().splitlines()
    parsed, links = [], []
    for name in changed:
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
    return {'review_target': inputs['review_target'], 'author_files': author_files,
            'review_clarified_files': overrides,
            'native_manifest': {'path': native_manifest, **identity(native_raw)},
            'native_pins_unchanged': len(native['repository']),
            'python_sources_parsed': parsed, 'local_document_links': links,
            'native_runs': 0, 'predecessor_checker_replays': 0}


if __name__ == '__main__':
    result = check()
    expected = HERE / 'integration-result.json'
    if expected.exists():
        assert result == json.loads(expected.read_text())
    else:
        expected.write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({'status': 'pass', 'author_files': len(result['author_files']),
                      'native_pins_unchanged': result['native_pins_unchanged'],
                      'python_parses': len(result['python_sources_parsed']),
                      'local_links': len(result['local_document_links'])}))
