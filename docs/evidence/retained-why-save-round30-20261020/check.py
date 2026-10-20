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
BASE = '0937ca4a44d012893c7c95517e990f019d1489e6'
REVIEW_TARGET = '8f17435e429ae145dc5aeae50926452100034dba'
FREEZES = {
    'status': '11f37947321d59d870039ce7b6743621245b2eb7',
    'formatter': '6319196c03',
    'restored_paths': '31ef309efee103f74fb47ed466e65764a700dd89',
    'theory_control': '436a1df50828863ca4f4ee2dcc234fef170d1549',
}


def git(*args):
    return subprocess.check_output(['git', '-C', str(ROOT), *args])


def identity(raw):
    return {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}


def check():
    author_files = []
    for component, commit in FREEZES.items():
        commit = git('rev-parse', commit).decode().strip()
        names = git('diff-tree', '--no-commit-id', '--name-only', '-r', commit).decode().splitlines()
        for name in names:
            expected = identity(git('show', f'{commit}:{name}'))
            actual = identity((ROOT/name).read_bytes())
            assert actual == expected, (component, name)
            author_files.append({'component': component, 'author_freeze': commit,
                                 'path': name, **actual})
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
    return {'review_target': REVIEW_TARGET, 'author_files': author_files,
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
        print('Created initial integration result; no predecessor checker replay.')
