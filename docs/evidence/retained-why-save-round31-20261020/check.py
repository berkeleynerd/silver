#!/usr/bin/env python3
"""Cheap final file/pin/link reconciliation; no previous proof replay."""
import ast
import hashlib
import json
from pathlib import Path
import re
import subprocess

ROOT = Path(__file__).resolve().parents[3]
HERE = Path(__file__).resolve().parent
BASE = '87874f41b44f7abb2d3c4848405b3474a09f51b4'
REVIEW_TARGET = '97914a071c'
FREEZES = {
    'formatter_ownership': 'd27fb7abfe',
    'tables_and_counter': '9c3638a4ff78538cb8139321e3411f0992bc9984',
    'path_inventory': 'd35f7809e5366bbdb4012315de00d7089130233b',
    'path_payload_bound': 'b6fd7adbe8a40b2c4dc62b17254454853531c61b',
}

CLARIFICATIONS = ['97914a071c']


def git(*args):
    return subprocess.check_output(['git', '-C', str(ROOT), *args])


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def check():
    overrides = {}
    for revision in CLARIFICATIONS:
        revision = git('rev-parse', revision).decode().strip()
        for name in git('diff-tree', '--no-commit-id', '--name-only', '-r', revision).decode().splitlines():
            overrides[name] = revision
    author_files = []
    for component, commit in FREEZES.items():
        commit = git('rev-parse', commit).decode().strip()
        names = git('diff-tree', '--no-commit-id', '--name-only', '-r', commit).decode().splitlines()
        for name in names:
            checked_revision = overrides.get(name, commit)
            expected = identity(git('show', f'{checked_revision}:{name}'))
            actual = identity((ROOT/name).read_bytes())
            assert actual == expected, (component, name)
            author_files.append({'component': component, 'author_freeze': commit,
                                 'checked_revision': checked_revision,
                                 'path': name, **actual})
    assert set(overrides) <= {row['path'] for row in author_files}
    manifest_path = 'docs/evidence/retained-literal-native-completion-20261019/inputs.json'
    raw = (ROOT/manifest_path).read_bytes()
    manifest = json.loads(raw)
    for row in manifest['repository']:
        assert identity((ROOT/row['path']).read_bytes()) == {
            k: row[k] for k in ('bytes', 'sha256')}, row['path']
    changed = git('diff', '--name-only', BASE, REVIEW_TARGET).decode().splitlines()
    parsed, links = [], []
    for name in changed:
        path = ROOT/name
        if path.suffix == '.py':
            ast.parse(path.read_text(), filename=name)
            parsed.append(name)
        if path.suffix == '.md':
            for url in re.findall(r'\]\(([^)]+)\)', path.read_text()):
                if '://' in url or url.startswith('#'):
                    continue
                target = url.split('#')[0]
                assert (path.parent/target).exists(), (name, target)
                links.append({'file': name, 'target': target})
    return {'review_target': git('rev-parse', REVIEW_TARGET).decode().strip(), 'author_files': author_files,
            'review_clarified_files': overrides,
            'native_manifest': {'path': manifest_path, **identity(raw)},
            'frozen_native_pins_unchanged': len(manifest['repository']),
            'python_sources_parsed': parsed, 'local_document_links': links,
            'native_runs': 0, 'prior_checker_replays': 0}


if __name__ == '__main__':
    result = check()
    expected_path = HERE/'result.json'
    if expected_path.exists():
        assert result == json.loads(expected_path.read_text())
        print(json.dumps({'status': 'pass', 'author_files': len(result['author_files']),
                          'native_pins_unchanged': result['frozen_native_pins_unchanged'],
                          'python_parses': len(result['python_sources_parsed']),
                          'local_links': len(result['local_document_links'])}))
    else:
        expected_path.write_text(json.dumps(result, indent=2)+'\n')
        print(json.dumps({'status':'pass', 'author_files':len(result['author_files']), 'native_pins_unchanged':result['frozen_native_pins_unchanged'], 'python_parses':len(result['python_sources_parsed']), 'local_links':len(result['local_document_links'])}))
