#!/usr/bin/env python3
"""Reconcile R56 accepted freezes and compose request arithmetic, without replay."""
import ast
import hashlib
import json
from pathlib import Path
import re
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
CACHE = {}


def identity(path):
    if path not in CACHE:
        raw = path.read_bytes()
        CACHE[path] = {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}
    return CACHE[path]


def read(path):
    return json.loads((ROOT / path).read_text())


def git(*args):
    return subprocess.check_output(['git', '-C', str(ROOT), *args])


def check():
    manifest = json.loads((HERE / 'inputs.json').read_text())
    assert not manifest['review_freeze_pending']
    assert 'review' in manifest['components']
    frozen, retained = [], {}
    for component, row in manifest['components'].items():
        for name in row['paths']:
            raw = git('show', row['freeze'] + ':' + name)
            expected = {'bytes': len(raw), 'sha256': hashlib.sha256(raw).hexdigest()}
            assert identity(ROOT / name) == expected, name
            frozen.append(dict(component=component, path=name, **expected))

    def record(name, expected, folder):
        if ':' in name or name.startswith('/'):
            return
        path = ROOT / name if name.startswith('docs/') else folder / name
        if not path.is_file():
            return  # Archive-member and symbol keys are not repository paths.
        actual = identity(path)
        if isinstance(expected, str):
            assert actual['sha256'] == expected, str(path)
        else:
            assert actual == {k: expected[k] for k in ['bytes', 'sha256']}, str(path)
        retained[str(path.relative_to(ROOT))] = actual

    def collect(value, folder):
        if isinstance(value, list):
            for child in value:
                collect(child, folder)
        elif isinstance(value, dict):
            for key, child in value.items():
                if isinstance(child, str) and re.fullmatch('[0-9a-f]{64}', child):
                    record(key, child, folder)
                if isinstance(child, dict):
                    expected = child.get('identity', child)
                    if 'bytes' in expected and 'sha256' in expected:
                        record(key, expected, folder)
                collect(child, folder)
            name = value.get('path', '')
            expected = value.get('identity', value)
            if name and 'bytes' in expected and 'sha256' in expected:
                record(name, expected, folder)

    for name in manifest['component_manifests']:
        collect(read(name), (ROOT / name).parent)
    native = read('docs/evidence/retained-literal-native-completion-20261019/inputs.json')
    for row in native['repository']:
        assert identity(ROOT / row['path']) == {k: row[k] for k in ['bytes', 'sha256']}
    installed = read('docs/evidence/retained-why-parallel-state-attachment-20261020/native-witnesses.json')['binary']
    assert identity(Path(installed['path'])) == installed['identity']
    request_native = read('docs/evidence/retained-server-request-storage-20261020/native-inputs.json')['inputs']
    for row in request_native:
        assert identity(Path(row['path'])) == {k: row[k] for k in ['bytes', 'sha256']}
    review = read('docs/evidence/retained-request-inline-capacity-review-20261020/round.json')
    checks = review['first_focused_checks']
    assert len(checks) == 4 and all(row['result']['status'].lower() == 'pass' for row in checks.values())
    assert review['successful_focused_checker_replays'] == review['predecessor_checker_replays'] == 0
    for component, key in [('request_storage', 'request_storage'),
                           ('combined_startup', 'combined_startup'),
                           ('request_bytes', 'filename_request_bytes'),
                           ('fixed_inline', 'first_inline_family')]:
        assert checks[key]['author_freeze'] == manifest['components'][component]['freeze']

    requests = read('docs/evidence/retained-server-request-storage-20261020/result.json')
    operands = read('docs/evidence/retained-solver-request-bytes-20261020/projection.json')
    startup = read('docs/evidence/retained-combined-parallel-startup-20261020/projection.json')
    inline = read('docs/evidence/retained-why-fixed-inline-family-20261020/result.json')
    assert requests['attempts_upper'] == operands['aggregate']['N'] == 459
    assert requests['request_record_bytes'] == 56 and requests['argv_element_bytes'] == 8
    assert requests['parsed_request_bytes'] == 'sum_d N_d*(L_d+8*m_d)+57714'
    assert requests['parsed_request_allocations'] == 'sum_d N_d*m_d+4590'
    assert requests['parent_exec_argv_bytes'] == '8*sum_d N_d*(m_d+2)'
    profiles = {}
    for profile in ['original', 'quiet']:
        constant, calls, argv, a_coefficient, tau = 57714, 4590, 0, 0, {}
        for domain, row in operands['domains'].items():
            p = row['profiles'][profile]
            n, m, length = row['N'], p['m_d'], p['L_d']
            assert length['A'] == length['tau'] == 1 and m == 14
            constant += n * (length['constant'] + 8 * m)
            calls += n * m
            argv += 8 * n * (m + 2)
            a_coefficient += n
            tau[domain] = n
        assert a_coefficient == 459 and calls == 11016 and argv == 58752
        profiles[profile] = {'parser_bytes_A_coefficient': a_coefficient,
                             'parser_bytes_tau_coefficients': tau,
                             'parser_bytes_constant': constant,
                             'parser_allocation_calls': calls, 'parent_exec_argv_bytes': argv}
    assert profiles['quiet']['parser_bytes_constant'] == 234945
    assert profiles['original']['parser_bytes_constant'] == 178488
    assert max(r['bounds']['all_major_words'] for r in startup['domains'].values()) == 8526217
    assert min(r['bounds']['contiguous_remnant_words_lower'] for r in startup['domains'].values()) == 8250999
    assert sum(r['registered_root_count'] for r in startup['domains'].values()) == 118
    assert inline['registered_roots'] == 118 and inline['ordinary_root_driver_pairs'] == 354
    assert inline['first_inline_episodes_all_five_processes_upper'] == 364
    assert inline['all_five_processes']['Ident'] == 792911
    assert inline['budgets']['per_process_escape_e'] == 2
    assert inline['budgets']['per_process_save_callbacks'] == 2
    assert inline['budgets']['per_process_saves'] == 3
    assert not inline['budgets']['stage_receives_new_escape_allowance']
    assert inline['open'] and not inline['source_argument_machine_checked']
    assert requests['complete_q'] is None and not requests['proxy_stream_refinement_established']

    parsed, links = [], []
    for name in sorted({row['path'] for row in frozen} | {str(Path(__file__).relative_to(ROOT))}):
        path = ROOT / name
        if path.suffix == '.py':
            ast.parse(path.read_text(), filename=name)
            parsed.append(name)
        elif path.suffix == '.md':
            for url in re.findall(r'\]\(([^)]+)\)', path.read_text()):
                if '://' in url or url.startswith('#'):
                    continue
                target = url.split('#')[0]
                assert (path.parent / target).exists(), (name, target)
                links.append({'file': name, 'target': target})
    return {'frozen_files': frozen, 'retained_repository_inputs': retained,
            'native_source_pins_unchanged': len(native['repository']),
            'installed_why_binary_unchanged': True, 'unchanged_request_native_inputs': len(request_native),
            'review_first_check_subprocess_seconds': sum(row['elapsed_seconds'] for row in checks.values()),
            'python_parses': parsed, 'local_links': links,
            'composed_request_profiles': profiles,
            'combined_startup_all_major_words_upper': 8526217,
            'combined_startup_scope': 'exact R53 J12 roles plus quiet/timeless/logging; guarded successful prefix',
            'registered_roots': 118, 'first_inline_direct_Ident_upper': 792911,
            'returned_hidden_storage_validator_bound_closed': False,
            'whole_server_storage_bounded': False, 'actual_launcher_attached': False,
            'complete_q': None, 'whole_capacity_rule_delivered': False,
            'component_checker_replays': 0, 'native_target_solver_proof_capture_runs': 0}


if __name__ == '__main__':
    start = time.perf_counter()
    result = check()
    result.update(status='pass', elapsed_seconds=time.perf_counter() - start)
    print(json.dumps(result, indent=2, sort_keys=True))
