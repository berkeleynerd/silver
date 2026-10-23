"""Attach the reviewed printer-output interface; no component replay."""
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
    packet = EV / 'retained-printer-output-review-20261023'
    audit = read(packet / 'result.json')
    assert audit['status'] == 'pass'
    assert audit['freeze'] == manifest['components']['author']['freeze']
    assert audit['author_checker_replays'] == audit['predecessor_checker_replays'] == audit['native_runs'] == 0
    providers = {}
    for revision_path, expected in read(packet / 'inputs.json').items():
        revision, path = revision_path.split(':', 1)
        data = (ROOT / path).read_bytes()
        assert identity(data) == expected, revision_path
        providers[path] = expected
    attachment = read(packet / 'provider-review-attachment.json')
    assert attachment['status'] == 'attached' and attachment['provider_reviewer_acceptance_reused']
    assert attachment['provider_review_replays'] == 0
    assert attachment['author'] == audit['freeze']
    for path, expected in attachment['exact_files'].items():
        assert identity((ROOT / path).read_bytes()) == expected, path
    previous = read(EV / 'retained-name-attribute-round65-20261023/inputs.json')
    assert attachment['review'] == previous['components']['review']['freeze']
    previous_result = read(EV / 'retained-name-attribute-round65-20261023/integration-result.json')
    assert previous_result['new_source_contracts_and_seven_owner_join_independently_accepted']
    names = {r['case']: r for r in previous_result['cases']}
    seven = {r['case']: r for r in read(EV / 'retained-name-attribute-round65-20261023/composition-result.json')['cases']}
    result = read(EV / 'retained-why-printer-output-20261023/result.json')
    assert result['providers'] == attachment['providers']
    assert result['global_escape_budget'] == 2 and result['save_entering_callbacks'] == 2
    assert result['saves_upper'] == 3 and not result['budget_renewed']
    assert result['fresh_drain_requires_no_system_scope_break']
    assert result['all_scoped_numeric_guards_pass']
    assert not result['whole_printer_capacity'] and not result['whole_process_capacity']
    assert not result['shared_stderr_whole_interval_closed']
    assert len(result['cases']) == len(names) == 5
    rows = []
    for case in result['cases']:
        n, shared = names[case['case']], seven[case['case']]
        assert set(case['drivers']) == {'cvc5_gnatprove.drv', 'z3_gnatprove.drv', 'alt_ergo_gnatprove_smt2.drv'}
        fragments, offered = [], []
        for driver in case['drivers'].values():
            assert driver['printed_name_bytes_upper'] == n['unique_name_bytes_upper']
            assert driver['raw_comment_name_bytes_upper'] == n['raw_proposition_name_bytes_upper']
            assert driver['files_upper'] == driver['dimensions']['E'] == shared['episodes_upper']
            assert driver['one_solver_input_file_bytes_upper'] == driver['request_formatter']['offered_bytes_upper']
            assert driver['one_solver_input_file_bytes_upper'] <= result['selected_max_string_length']
            for kind in ('request_formatter', 'request_buffer', 'each_annotation_formatter',
                         'each_annotation_buffer', 'each_temporary_name_formatter', 'each_temporary_name_buffer'):
                assert all(driver[kind]['guards'].values()), (case['case'], kind)
            assert not driver['cumulative_total_is_native_operand']
            assert not driver['whole_printer_capacity'] and not driver['whole_process_capacity']
            offered.append(driver['one_solver_input_file_bytes_upper'])
            fragments.append(driver['syntax_integer_diagnostic'])
        # These are alternative drivers within the same process episode bound.
        # Export the identical stderr fragment once, never once per driver.
        assert all(f == fragments[0] for f in fragments)
        assert fragments[0]['attempts_per_process_upper'] == shared['episodes_upper']
        assert not fragments[0]['fresh_stderr_reset_assumed']
        rows.append({'case': case['case'], 'driver_applications': len(offered),
                     'largest_individual_solver_file_bytes_upper': max(offered),
                     'request_opportunities_upper': shared['episodes_upper'],
                     'shared_stderr_fragment_once': fragments[0]})
    pins = read(EV / 'retained-literal-native-completion-20261019/inputs.json')
    for row in pins['repository']:
        assert identity((ROOT / row['path']).read_bytes()) == {k: row[k] for k in ('bytes', 'sha256')}
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
                        continue
                    assert destination.exists(), (path, target)
                    links += 1
    return {'status': 'pass', 'frozen_files': frozen, 'provider_inputs': len(providers),
            'cases': rows, 'reviewed_driver_applications': sum(r['driver_applications'] for r in rows),
            'reviewed_output_interface_and_R65_inputs_attached': True,
            'historical_component_results_reused': True,
            'native_source_pins_unchanged': len(pins['repository']),
            'installed_why_unchanged': True, 'local_links': links,
            'shared_stderr_whole_interval_closed': False,
            'whole_printer_capacity': False, 'whole_process_capacity': False,
            'whole_capacity_rule_complete': False, 'native_runs': 0,
            'component_checker_replays': 0, 'new_episode_multiplier': False}


if __name__ == '__main__':
    started = time.perf_counter()
    result = check()
    result['elapsed_seconds'] = time.perf_counter() - started
    (HERE / 'integration-result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({k: v for k, v in result.items() if k not in ('frozen_files', 'cases')}))
