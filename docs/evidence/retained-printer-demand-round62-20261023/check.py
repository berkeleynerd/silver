"""Check exact R62 integration inputs and vector attachment; no checker replay."""
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


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def read(path):
    return json.loads(path.read_text())


def check():
    manifest = read(HERE / 'inputs.json')
    frozen = {}
    for component in manifest['components'].values():
        for path in component['paths']:
            actual = (ROOT / path).read_bytes()
            expected = subprocess.check_output(
                ['git', 'show', component['freeze'] + ':' + path], cwd=ROOT)
            assert actual == expected, path
            frozen[path] = identity(actual)
    audit = read(EV / 'retained-printer-demand-review-20261023/audit-result.json')
    assert audit['status'] == 'pass'
    assert audit['reviewed_freeze'] == manifest['components']['printer']['freeze']
    for path, expected in audit['frozen_inputs'].items():
        assert identity((ROOT / path).read_bytes()) == expected, path
    previous = read(EV / 'retained-printer-pause-round61-20261023/composition-result.json')
    printer = read(EV / 'retained-why-printer-demand-20261023/result.json')
    result = read(HERE / 'composition-result.json')
    by_old = {r['case']: r for r in previous['cases']}
    by_printer = {r['case']: r for r in printer['cases']}
    assert {r['case'] for r in result['cases']} == set(by_old) == set(by_printer)
    for row in result['cases']:
        case = row['case']
        assert row['caller_supplied_residuals'] == dict(
            by_old[case]['caller_supplied_residuals'],
            solver_request_printers=by_printer[case]['process_vector'])
        assert row['known_demand'] == by_old[case]['known_demand']
        assert row['attachment'] == by_old[case]['attachment']
        for owner, value in row['joined_known_and_supplied_demand'].items():
            old = by_old[case]['joined_known_and_supplied_demand'][owner]
            delta = by_printer[case]['process_vector'][owner]
            assert value == {key: old[key] + delta[key] for key in old}
        assert row['known_and_supplied_operands_fit']
        assert set(row['missing_residual_contracts']) == {
            'lookup_library_constructors', 'other_callbacks_and_shutdown'}
        assert not row['actual_whole_process_headroom']
    assert result['budgets'] == previous['budgets']
    assert result['saved_component_reused'] == previous['saved_component_reused']
    assert not result['whole_pipeline_capacity']
    native = read(EV / 'retained-literal-native-completion-20261019/inputs.json')
    for row in native['repository']:
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
                    assert (p.parent / target.split('#')[0]).exists(), (path, target)
                    links += 1
    return {'status': 'pass', 'frozen_files': frozen,
            'review_input_count': len(audit['frozen_inputs']),
            'native_source_pins_unchanged': len(native['repository']),
            'installed_why_unchanged': True, 'local_links': links,
            'cases': len(result['cases']), 'known_operands_fit': True,
            'missing_vectors_per_process': 2, 'whole_capacity_rule_complete': False,
            'component_checker_replays': 0, 'native_target_runs': 0}


if __name__ == '__main__':
    start = time.perf_counter()
    result = check()
    result['elapsed_seconds'] = time.perf_counter() - start
    (HERE / 'integration-result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({key: value for key, value in result.items() if key != 'frozen_files'}))
