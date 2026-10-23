"""Reconcile R61 exact inputs and retained results without component replay."""
import ast
import hashlib
import json
from pathlib import Path
import re
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def read(path):
    return json.loads((ROOT / path).read_text())


def check():
    manifest = json.loads((HERE / 'inputs.json').read_text())
    frozen = {}
    for component in manifest['components'].values():
        for path in component['paths']:
            expected = subprocess.check_output(['git', 'show', component['freeze'] + ':' + path], cwd=ROOT)
            actual = (ROOT / path).read_bytes()
            assert actual == expected, path
            frozen[path] = identity(actual)
    printer = 'docs/evidence/retained-why-printer-entry-20261020/'
    inputs = read(printer + 'inputs.json')
    for path, expected in inputs['retained_inputs'].items():
        assert identity((ROOT / path).read_bytes()) == expected, path
    for path, expected in inputs['external_frozen_inputs'].items():
        assert identity(subprocess.check_output(['git', 'show', path], cwd=ROOT)) == expected, path
    for path, expected in read(printer + 'packet-inputs.json').items():
        assert identity((ROOT / path).read_bytes()) == expected, path
    audit = read('docs/evidence/retained-printer-entry-review-20261023/audit-result.json')
    assert audit['status'] == 'pass'
    assert audit['freeze'] == manifest['components']['printer']['freeze']
    assert audit['native_runs'] == audit['predecessor_checker_replays'] == 0
    assert not audit['author_checker_replayed'] and not audit['transforms_executed']
    for path, expected in audit['exact_inputs'].items():
        assert identity((ROOT / path).read_bytes()) == expected, path
    result = read('docs/evidence/retained-printer-pause-round61-20261023/composition-result.json')
    source = read(printer + 'result.json')
    by_case = {c['case']: c['process_demands'] for c in source['cases']}
    for case in result['cases']:
        d = by_case[case['case']]
        # The supplied vector contains process totals, already weighted by E.
        v = case['caller_supplied_residuals']['later_preparation']
        mapping = {'Ident': d['direct_Ident_registrations'],
                   'Decl.Hsdecl': d['logical_decl_constructor_requests'],
                   'Ty.Hsty': d['type_hashcons_requests'],
                   'Theory.Hstdecl': d['tdecl_constructor_requests'],
                   'Task.Hstask': d['task_add_requests'],
                   'Task.Stdecl.Hcpt': 64*d['task_add_requests']}
        for owner, value in mapping.items():
            assert v[owner]['increments'] == value
            assert v[owner]['requests'] == (0 if owner == 'Ident' else value)
        assert case['known_and_supplied_operands_fit']
        assert len(case['missing_residual_contracts']) == 3
        assert not case['actual_whole_process_headroom']
    assert not result['whole_pipeline_capacity']
    native = read('docs/evidence/retained-printer-entry-collision-review-20261020/native-byte-join.json')
    assert identity(Path(native['installed_binary']).read_bytes()) == native['installed_identity']
    old = read('docs/evidence/retained-literal-native-completion-20261019/inputs.json')
    for row in old['repository']:
        assert identity((ROOT / row['path']).read_bytes()) == {k: row[k] for k in ('bytes', 'sha256')}
    parsed, links = [], 0
    for path in frozen:
        p = ROOT / path
        if p.suffix == '.py':
            ast.parse(p.read_text(), filename=path)
            parsed.append(path)
        if p.suffix == '.md':
            for target in re.findall(r'\]\(([^)]+)\)', p.read_text()):
                if '://' not in target and not target.startswith('#'):
                    assert (p.parent / target.split('#')[0]).exists(), (path, target)
                    links += 1
    return {'status': 'pass', 'frozen_files': frozen,
            'inherited_input_count': len(inputs['retained_inputs']),
            'external_frozen_input_count': len(inputs['external_frozen_inputs']),
            'native_source_pins_unchanged': len(old['repository']),
            'installed_why_unchanged': True, 'python_parses': parsed,
            'local_packet_links': links, 'known_operands_fit': True,
            'missing_vectors_per_process': 3, 'whole_capacity_rule_complete': False,
            'component_checker_replays': 0, 'native_target_runs': 0}


if __name__ == '__main__':
    start = time.perf_counter()
    result = check()
    result['elapsed_seconds'] = time.perf_counter() - start
    (HERE / 'integration-result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({k: v for k, v in result.items() if k not in ('frozen_files', 'python_parses')}))
