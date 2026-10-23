"""Finite status/failure abstraction, with source mapping in the argument.

It checks payload-flow topology, not arbitrary OCaml execution. Faults outside
the logical producer have the scalar/save family established by that argument.
"""
from itertools import product

STATUSES = ('Undone', 'Scheduled', 'Running', 'Done', 'Interrupted',
            'Detached', 'InternalFailure', 'Uninstalled', 'UpgradeProver', 'Removed')


def parallel_callback(status, *, remaining_zero, status_fault, log_fault):
    # Controller's callback updates session state, then invokes this closure.
    if status_fault:
        return 'secondary_scalar_failure'
    # Logging happens even when remaining=0; its status projection drops e.
    if log_fault:
        return 'secondary_scalar_failure'
    if remaining_zero or status != 'Done':
        return 'return_without_forwarding'
    return 'forward_Done_only'


def check_control():
    rows = []
    for status, zero, status_fault, log_fault in product(STATUSES, (False, True), (False, True), (False, True)):
        outcome = parallel_callback(status, remaining_zero=zero,
                                    status_fault=status_fault, log_fault=log_fault)
        assert outcome != 'forward_Done_only' or status == 'Done'
        if status == 'InternalFailure':
            assert outcome in ('return_without_forwarding', 'secondary_scalar_failure')
        rows.append({'status': status, 'remaining_zero': zero,
                     'status_fault': status_fault, 'log_fault': log_fault,
                     'outcome': outcome})
    # Arbitrary producer exception, including logical payload: the idle catch
    # passes only InternalFailure. An inner Sys_error callback may fail first;
    # the outer catch then receives the secondary failure, still dropped.
    for first_fault, second_fault in product((False, True), repeat=2):
        first = parallel_callback('InternalFailure', remaining_zero=False,
                                  status_fault=False, log_fault=first_fault)
        second = parallel_callback('InternalFailure', remaining_zero=False,
                                   status_fault=second_fault, log_fault=False)
        assert first != 'forward_Done_only' and second != 'forward_Done_only'
    return {'status_cases': rows, 'logical_payload_forwarding_cases': 0,
            'inner_and_outer_callback_fault_cases_checked': 4,
            'source_simulation_machine_checked': False}
