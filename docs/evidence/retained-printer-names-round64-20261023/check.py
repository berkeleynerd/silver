"""Integrate exact reviewed printer name-table evidence without replay."""
import ast
import hashlib
import json
from pathlib import Path
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EV = HERE.parent


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def check():
    manifest = json.loads((HERE / 'inputs.json').read_text())
    frozen = {}
    for component in manifest['components'].values():
        for path in component['paths']:
            data = (ROOT / path).read_bytes()
            assert data == subprocess.check_output(
                ['git', 'show', component['freeze'] + ':' + path], cwd=ROOT), path
            frozen[path] = identity(data)
            if path.endswith('.py'):
                ast.parse(data.decode(), filename=path)
    audit = json.loads((EV / 'retained-printer-name-tables-review-20261023/audit-result.json').read_text())
    assert audit['reviewed_commit'] == manifest['components']['author']['freeze']
    for path, expected in audit['inputs'].items():
        assert identity((ROOT / path).read_bytes()) == expected, path
    assert audit['numeric_rows_and_integer_array_guards']
    assert audit['all_witness_ranges_within_actual_source']
    assert audit['author_or_predecessor_checkers_run'] == 0
    result = json.loads((EV / 'retained-why-printer-name-tables-20261023/result.json').read_text())
    assert not result['raw_name_origin_attachment_established']
    assert not result['whole_printer_or_119_capacity_established']
    assert not result['exception_allowance_renewed_per_table']
    return {'status': 'pass', 'frozen_files': frozen,
            'review_inputs_attached': len(audit['inputs']), 'cases': len(result['cases']),
            'name_table_integer_array_interface_accepted': True,
            'raw_name_origin_attachment_established': False,
            'whole_capacity_rule_complete': False,
            'component_checker_replays': 0, 'native_runs': 0}


if __name__ == '__main__':
    start = time.perf_counter()
    result = check()
    result['elapsed_seconds'] = time.perf_counter() - start
    (HERE / 'integration-result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({key: value for key, value in result.items() if key != 'frozen_files'}))
