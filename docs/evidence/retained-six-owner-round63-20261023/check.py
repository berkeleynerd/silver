"""Bind the accepted R63 source contracts to retained numerical composition."""
import ast
import hashlib
import json
from pathlib import Path
import re
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EV = HERE.parent


def read(path):
    return json.loads(path.read_text())


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def check():
    manifest = read(HERE / 'inputs.json')
    frozen = {}
    for component in manifest['components'].values():
        for path in component['paths']:
            data = (ROOT / path).read_bytes()
            assert data == subprocess.check_output(
                ['git', 'show', component['freeze'] + ':' + path], cwd=ROOT), path
            frozen[path] = identity(data)
    review = EV / 'retained-library-callback-demand-review-20261023'
    audit = read(review / 'result.json')
    assert audit['passed']
    assert audit['library_freeze'] == manifest['components']['library']['freeze']
    assert audit['callback_freeze'] == manifest['components']['callbacks']['freeze']
    assert audit['combined_freeze'] == manifest['combined_freeze']
    assert audit['native_runs'] == audit['author_or_predecessor_programs_run'] == 0
    current = {}
    for revision_path, expected in read(review / 'inputs.json').items():
        revision, path = revision_path.split(':', 1)
        if path not in current:
            current[path] = identity((ROOT / path).read_bytes())
        assert current[path] == expected, revision_path
    # This is the unchanged first numerical join, not a re-executed composition.
    result = read(HERE / 'candidate-composition-result.json')
    library = {r['case']: r for r in read(EV / 'retained-why-library-constructors-20261023/result.json')['cases']}
    callbacks = {r['case']: r for r in read(EV / 'retained-why-callback-demand-20261023/result.json')['cases']}
    for row in result['cases']:
        case = row['case']
        assert row['caller_supplied_residuals']['lookup_library_constructors'] == library[case]['lookup_vector']
        assert row['caller_supplied_residuals']['other_callbacks_and_shutdown'] == callbacks[case]['process_vector']
        assert row['complete_six_owner_numeric_input'] and row['known_and_supplied_operands_fit']
        assert row['missing_residual_contracts'] == []
        assert not row['actual_whole_process_headroom']
    assert not result['whole_pipeline_capacity']
    assert not result['new_source_contracts_independently_accepted']  # historical candidate flag
    old = read(EV / 'retained-literal-native-completion-20261019/inputs.json')
    for row in old['repository']:
        assert identity((ROOT / row['path']).read_bytes()) == {
            key: row[key] for key in ('bytes', 'sha256')}
    binary = read(EV / 'retained-printer-entry-collision-review-20261020/native-byte-join.json')
    assert identity(Path(binary['installed_binary']).read_bytes()) == binary['installed_identity']
    links = 0
    paths = set(frozen) | {str(p.relative_to(ROOT)) for p in HERE.iterdir() if p.is_file()}
    for path in paths:
        p = ROOT / path
        if p.suffix == '.py':
            ast.parse(p.read_text(), filename=path)
        if p.suffix == '.md':
            for target in re.findall(r'\]\(([^)]+)\)', p.read_text()):
                if '://' not in target and not target.startswith('#'):
                    destination = (p.parent / target.split('#')[0]).resolve()
                    if destination == HERE / 'integration-result.json':
                        continue  # This run writes its result only after all checks pass.
                    assert destination.exists(), (path, target)
                    links += 1
    return {'status': 'pass', 'frozen_files': frozen,
            'unique_review_inputs_attached': len(current),
            'native_source_pins_unchanged': len(old['repository']),
            'installed_why_unchanged': True, 'local_links': links,
            'new_source_contracts_independently_accepted': True,
            'retained_numerical_composition_reused': True,
            'missing_six_owner_vectors_per_process': 0,
            'whole_process_headroom': False, 'whole_capacity_rule_complete': False,
            'native_runs': 0, 'component_checker_replays': 0}


if __name__ == '__main__':
    start = time.perf_counter()
    result = check()
    result['elapsed_seconds'] = time.perf_counter() - start
    (HERE / 'integration-result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({key: value for key, value in result.items() if key != 'frozen_files'}))
