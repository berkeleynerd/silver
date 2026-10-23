"""New conditional J12/canonical JSON join; no provider program is executed."""
import hashlib
import json
from pathlib import Path
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EV = HERE.parent


def read(path):
    return json.loads(path.read_text())


def identity(data):
    return {'bytes': len(data), 'sha256': hashlib.sha256(data).hexdigest()}


def calculate():
    inputs = read(HERE / 'inputs.json')
    for path, expected in inputs['files'].items():
        assert identity((ROOT / path).read_bytes()) == expected, path
    spans = read(HERE / 'source-witnesses.json')
    with tarfile.open(ROOT / inputs['source_archive']) as archive:
        for span in spans:
            data = archive.extractfile(span['member']).read()
            assert identity(data) == span['member_identity'], span['member']
            lines = data.decode().splitlines(keepends=True)
            assert 1 <= span['first'] <= span['last'] <= len(lines)
            assert ''.join(lines[span['first']-1:span['last']]) == span['text']
    cuts = read(EV / 'retained-parallel-logging-prefix-20261020/cut-projection.json')
    old_json = read(EV / 'retained-why-standard-json-inputs-20261020/transfer.json')
    old_rows = {row['case']: row for row in old_json['cases']}
    outputs = read(EV / 'retained-why-printer-output-20261023/result.json')
    output_rows = {row['case'].replace('-', '_'): row for row in outputs['cases']}
    table = read(EV / 'retained-adapter-outcome-interface-20261020/canonical-table.json')
    assert len(table) == 31
    assert all(row['bytes'] == len(row['output'].encode()) for row in table)
    q = max(row['bytes'] for row in table)
    assert q == 76 and any(row['warning'] for row in table)
    result_rows = []
    for case in ('put_line', 'put', 'first_or_default', 'is_message', 'input_is_valid'):
        cut = cuts[case]
        counters = cut['session_counters']
        assert cut['goal_ids'] == list(range(counters['next_proofNodeID']))
        assert counters['next_transID'] == counters['next_fileID'] == 1
        argv = cut['prospective_argv']
        assert '--logging' in argv and argv[argv.index('-j')+1] == '12'
        assert '--debug-prover-errors' not in argv and '--replay' not in argv
        assert argv[argv.index('--counterexample')+1] == 'off'
        roots = cut['fixed_root_map']
        assert len({row['goal'] for row in roots}) == len(roots)
        assert all(0 < row['goal'] < counters['next_proofNodeID'] for row in roots)
        g, a0 = counters['next_proofNodeID']-1, counters['next_proofAttemptID']
        e = 3*len(roots)+2
        for driver in output_rows[case]['drivers'].values():
            assert driver['dimensions']['E'] == e
        a, n = a0+e, e
        r = old_rows[case]['conditional_inputs']['R']
        keys = {(x['check_id'], x['check_kind'], x['source_location']) for x in roots}
        assert len(keys) <= r
        oa, op = q*a, q*n
        o = max(oa, op)
        b = 14864+3732*r+189*g+873*a+3075*n+3111*o+3+6*26619+84
        events = 2313+753*r+73*g+194*a+1027*n+1039*o+3+2*26619+106
        # These constants deliberately leave the real unknown inputs symbolic.
        result_rows.append({
            'case': case, 'j12_pid': cut['captured_pid'],
            'R': r, 'actual_registered_key_count': len(keys), 'G': g,
            'A0': a0, 'E': e, 'A': a, 'N': n,
            'canonical_file_bytes_upper': q,
            'answer_occurrence_output_bytes_upper': oa,
            'parser_invocation_output_bytes_upper': op,
            'O': o,
            'JSON_B': {'constant': b, 'W_o': 3, 'L_o': 6, 'X': 6},
            'JSON_E': {'constant': events, 'W_o': 3, 'L_o': 2, 'X': 2},
            'actual_JSON_B': None, 'actual_JSON_E': None,
            'whole_standard_core_guards_established': False})
    return {
        'status': 'pass', 'scope': 'Prospective canonical-file/J12 occurrence/JSON input join',
        'cases': result_rows, 'canonical_rows': len(table), 'provider_files': len(inputs['files']),
        'source_spans': len(spans), 'current_J12_metadata_used': True,
        'old_serial_occurrence_counts_substituted': False,
        'source_count_transport_requires_independent_review': True,
        'independent_review_accepted': False,
        'conditional_on_future_proxy_adapter_refinement': True,
        'raw_solver_file_bytes_upper': None, 'complete_q_claim': False,
        'whole_standard_core_guards_established': False,
        'whole_printer_capacity': False, 'whole_process_capacity': False,
        'whole_capacity_rule_complete': False, 'production_implemented': False,
        'global_escape_budget': 2, 'save_entering_callbacks': 2, 'saves_upper': 3,
        'budget_renewed': False, 'aggregate_RAM_or_stack_gate': False,
        'native_compiler_solver_capture_proof_runs': 0, 'provider_program_replays': 0}


if __name__ == '__main__':
    started = time.perf_counter()
    result = calculate()
    result['elapsed_seconds'] = time.perf_counter()-started
    (HERE / 'result.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps({key: value for key, value in result.items() if key != 'cases'}))
