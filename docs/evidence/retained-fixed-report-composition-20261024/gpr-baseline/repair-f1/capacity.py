"""Effective #219 scratch-event overlay; original baseline evidence is immutable."""
from copy import deepcopy


def effective_prefix(prefix, added_rts_reference_calls):
    """Correct the selected baseline and explicitly compose later RTS references.

    The input is the pinned project's original Phase 2 prefix record. Its
    shape reader counts declaration RHS references separately from empty-case
    constructs; each selected case has one simple variable selector. All
    selected references use one prefix name. No original table calculation
    or global GPR.Names demand is changed by this overlay.
    """
    assert type(added_rts_reference_calls) is int and added_rts_reference_calls >= 0
    rhs = 0
    selectors = 0
    for shape in (prefix['project'], prefix['configuration']):
        for key in ('references', 'empty_case_constructs'):
            assert type(shape[key]) is int and shape[key] >= 0
        rhs += shape['references']
        selectors += shape['empty_case_constructs']
    baseline = rhs + selectors
    prospective = baseline + added_rts_reference_calls
    out = deepcopy(prefix)
    # This historical field describes the pre-extra-clause baseline only.
    out['reference_prefix_reset_events_upper'] = baseline
    out['reference_prefix_singleton_push_events_upper'] = baseline
    out['reference_prefix_events'] = {
        'baseline_scope': 'User project and configuration before the two extra RTS clauses',
        'baseline_rhs_reference_calls': rhs,
        'baseline_case_selector_calls': selectors,
        'baseline_reset_events_upper': baseline,
        'baseline_singleton_push_events_upper': baseline,
        'added_RTS_reference_calls': added_rts_reference_calls,
        'prospective_reset_events_upper': prospective,
        'prospective_singleton_push_events_upper': prospective,
        'selected_peak_entries': 1,
        'backing_bytes': prefix['gross_shared_table_bounds']['Reference_Prefix']['bytes'],
        'complete_allocator_event_join_closed': False,
    }
    return out
