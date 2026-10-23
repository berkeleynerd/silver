"""Attach accepted private/accumulator inputs without replaying their checkers."""
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
    review_dir = EV / 'retained-printer-remaining-review-20261023'
    audit = read(review_dir / 'audit-result.json')
    assert audit['status'] == 'passed'
    assert not audit['author_or_predecessor_code_executed']
    assert not audit['native_compiler_solver_capture_disassembler_proof_run']
    assert audit['author_freezes'] == {
        key: manifest['components'][key]['freeze']
        for key in ('private_owners', 'format_accumulator')}
    assert identity((review_dir / 'audit.py').read_bytes()) == audit['audit_code_identity']
    for group in ('exact_inputs', 'providers'):
        for path, expected in audit[group].items():
            assert identity((ROOT / path).read_bytes()) == expected, path
    for field in ('whole_printer_capacity', 'whole_process_capacity', 'whole_119_claim'):
        assert audit[field] is False, field

    private = read(EV / 'retained-why-printer-private-owners-20261023/result.json')
    accumulator = read(EV / 'retained-why-format-accumulator-20261023/result.json')
    output = read(EV / 'retained-why-printer-output-20261023/result.json')
    accepted_output = read(EV / 'retained-printer-output-round66-20261023/integration-result.json')
    assert accepted_output['reviewed_output_interface_and_R65_inputs_attached']
    assert private['one_global_escape_budget'] == accumulator['global_escape_budget'] == 2
    assert private['save_entering_callbacks'] == accumulator['save_entering_callbacks'] == 2
    assert private['saves_upper'] == accumulator['saves_upper'] == 3
    assert not private['aggregate_RAM_gate'] and not accumulator['aggregate_RAM_or_stack_gate']
    assert not private['full_printer_claim'] and not accumulator['whole_printer_capacity']
    assert not accumulator['budget_renewed']
    assert accumulator['accumulator_representation_interface_closed_under_retained_premises']
    assert not accumulator['shared_stderr_whole_interval_closed']
    p_rows = {r['case']: r for r in private['cases']}
    a_rows = {r['case']: r for r in accumulator['cases']}
    o_rows = {r['case']: r for r in output['cases']}
    assert p_rows.keys() == a_rows.keys() == o_rows.keys() and len(p_rows) == 5
    rows = []
    for case, p in p_rows.items():
        a, o = a_rows[case], o_rows[case]
        assert p['all_guards_pass'] and all(p['native_operand_guards'].values())
        assert len(p['owners']) == 37
        assert a['drivers'].keys() == o['drivers'].keys() and len(a['drivers']) == 3
        fragments, offered = [], []
        for driver, ar in a['drivers'].items():
            old = o['drivers'][driver]
            for dim in ('S', 'P', 'H', 'A', 'T', 'E'):
                assert p['dimensions'][dim] == old['dimensions'][dim], (case, dim)
            assert p['dimensions']['W'] == old['printed_name_bytes_upper']
            assert ar['all_local_representation_guards']
            assert ar['structural_progress_under_typed_source_premises']
            assert not ar['assumes_each_formatting_call_emits_core_event']
            assert ar['physical_stack_and_allocator_sufficiency_remain_external']
            strings = ar['string_objects']
            assert strings['main_buffer_backing']['length_bytes_upper'] == old['request_buffer']['allocated_capacity_upper']
            assert strings['name_helper_result']['length_bytes_upper'] == p['dimensions']['W']
            assert strings['annotation_error_message']['length_bytes_upper'] == 46
            assert strings['annotation_error_backing']['length_bytes_upper'] == 256
            for value in strings.values():
                assert all(value['guards'].values())
            assert ar['dynamic_source_closure_group_payload_words_upper'] == 28
            fragments.append(old['syntax_integer_diagnostic'])
            offered.append(old['one_solver_input_file_bytes_upper'])
        assert all(f == fragments[0] for f in fragments)
        assert fragments[0]['attempts_per_process_upper'] == p['dimensions']['E']
        rows.append({'case': case, 'private_owner_families': len(p['owners']),
                     'driver_applications': len(offered),
                     'largest_tree_height_operand_upper': p['largest_tree_height_operand_upper'],
                     'largest_individual_solver_input_bytes_upper': max(offered),
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
    return {'status': 'pass', 'frozen_files': frozen, 'cases': rows,
            'reviewed_target_files': len(audit['exact_inputs']),
            'provider_inputs': len(audit['providers']),
            'reviewed_private_and_accumulator_interfaces_attached': True,
            'accepted_R65_R66_inputs_reused': True,
            'native_source_pins_unchanged': len(pins['repository']),
            'installed_why_unchanged': True, 'local_links': links,
            'shared_stderr_whole_interval_closed': False,
            'whole_printer_capacity': False, 'whole_process_capacity': False,
            'whole_capacity_rule_complete': False,
            'aggregate_RAM_or_stack_gate': False, 'native_runs': 0,
            'component_checker_replays': 0, 'new_episode_multiplier': False}


if __name__ == '__main__':
    started = time.perf_counter()
    result = check()
    result['elapsed_seconds'] = time.perf_counter() - started
    (HERE / 'integration-result.json').write_text(json.dumps(result, indent=2) + '\n')
    print(json.dumps({k: v for k, v in result.items() if k not in ('frozen_files', 'cases')}))
