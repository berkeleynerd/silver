#!/usr/bin/env python3
"""Check the new protocol-count/queue arithmetic; reuse predecessor results."""
import hashlib
import json
from pathlib import Path
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def capacity(initial, elements):
    assert initial >= 1 and elements >= 0
    result = initial
    while result < elements:
        result *= 2
    return result


def check():
    inputs = json.loads((HERE / 'inputs.json').read_text())
    for path, expected in inputs['repository_inputs'].items():
        assert identity((ROOT / path).read_bytes()) == expected, path
    witnesses = json.loads((HERE / 'source-witnesses.json').read_text())
    archive = ROOT / 'docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz'
    with tarfile.open(archive) as t:
        for w in witnesses:
            raw = t.extractfile(w['member']).read()
            assert identity(raw) == w['source_identity']
            lines = raw.decode().splitlines(keepends=True)
            assert ''.join(lines[w['start']-1:w['end']]) == w['text']
    launch = json.loads((ROOT / 'docs/evidence/retained-solver-launch-profile-20261020/result.json').read_text())
    completion = json.loads((ROOT / 'docs/evidence/retained-server-completion-format-20261020/result.json').read_text())
    assert completion['time_field_bytes_upper'] == 18
    assert completion['F_bytes_upper'] == 'id_bytes+path_bytes+29'
    rows = []
    for row in launch['cases']:
        n = 3 * row['G']
        assert row['run_offers_upper'] == row['interrupt_offers_upper'] == n
        assert 1 <= n <= 2**62-1
        d = len(str(n))
        rows.append(dict(case=row['case'], G_upper=row['G'], run_entries=n,
            interrupt_entries=n, positive_ID_upper=n, positive_ID_digits=d,
            response_records_upper=2*n, response_ring_capacity_J12=capacity(12,2*n),
            wrapped_request_increment='adapter_exec_bytes+'+str(55+d)))
    a = sum(row['run_entries'] for row in rows)
    digit_mass = sum(row['run_entries']*row['positive_ID_digits'] for row in rows)
    assert a == 459 and digit_mass == 1257
    c_request = capacity(100,a)
    c_responses = [row['response_ring_capacity_J12'] for row in rows]
    assert c_request == 800 and c_responses == [384,384,192,24,12]
    for c in [c_request,*c_responses]:
        assert 2*c <= 2**32-1 and 8*c <= 2**64-1
    # Exhaustive pointer positions for the concrete source resize capacities.
    # These finite witnesses exercise the algebraic interval argument in the note.
    positions = 0
    for initial, maximum in [(100,c_request),*(zip([12]*5,c_responses))]:
        old_cap = initial
        while old_cap < maximum:
            new_cap = 2*old_cap
            for old_p in range(old_cap):
                new_p = new_cap-old_cap+old_p
                amount = old_cap-old_p
                assert 0 <= old_p < old_cap <= new_p < new_cap
                assert new_p+amount == new_cap
                assert old_p+amount == old_cap <= new_p
                assert new_p+old_cap <= 2*new_cap <= 2**32-1
                positions += 1
            old_cap = new_cap
    return dict(scope='conditional fresh fixed-domain protocol counts and payload/ring bounds',
        cases=rows, total_attempts_upper=a, total_interrupt_entries_upper=a,
        intact_positive_ID_digits_upper=3, outstanding_or_history_slots_upper=a,
        control_connections_upper=a, response_records_upper=2*a,
        decision_payload_bytes=64*a, control_receiver_bytes=65*a,
        canonical_file_payload_bytes=76*a,
        backend_SF_wire_bytes=f'{a}*P_b+{2*digit_mass+32*a}',
        backend_SF_allocated_bytes=f'{a}*P_b+{2*digit_mass+35*a}',
        canonical_F_wire_bytes=f'{a}*P_c+{digit_mass+29*a}',
        request_ring_capacity=c_request, response_ring_capacities_J12=c_responses,
        ring_old_new_backing_bytes_J12=2*8*(2*c_request+sum(c_responses)),
        checked_resize_pointer_positions=positions,
        source_excerpts=len(witnesses), repository_inputs=len(inputs['repository_inputs']),
        includes_native_structures_argv_log_raw_output=False,
        malformed_stream_original_identity_established=False,
        actual_parallel_startup_and_cache_attachment=False,
        complete_q=None, full_capacity_rule=False, production_adopted=False,
        global_save_callbacks=2,global_saves=3,global_signal_escape_budget=2,
        native_target_solver_proof_capture_runs=0,predecessor_checker_replays=0)


if __name__ == '__main__':
    start=time.monotonic();result=check();path=HERE/'result.json'
    if path.exists():
        assert json.loads(path.read_text()) == result
    else:
        path.write_text(json.dumps(result,indent=2)+'\n')
    print(json.dumps(dict(status='pass',source_excerpts=result['source_excerpts'],
        repository_inputs=result['repository_inputs'],attempts=result['total_attempts_upper'],
        ring_pointer_positions=result['checked_resize_pointer_positions'],
        elapsed_seconds=time.monotonic()-start)))
