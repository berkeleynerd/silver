"""Conditional post-cut attempt-counter transfer; arithmetic is not a runtime proof."""

MAX_INT = (1 << 62) - 1
PREMISES = (
    'fresh_counter_and_id_domain_joined',
    'selected_constructor_callers_joined',
    'terminal_abandoned_prefix_source_theorem',
    'continued_signal_contract',
    'attempt_membership_publication_and_key_preservation_contract',
    'native_counter_commit_and_no_unmodeled_mutator_contract',
)


def bound(x):
    missing = [p for p in PREMISES if x.get(p) is not True]
    n, k, e = (x.get(p) for p in ('next_attempt_id0', 'pair_key_domain_upper',
                                'remaining_signal_exceptions_upper'))
    valid = all(type(v) is int and v >= 0 for v in (n, k, e))
    budget = k + e + 1 if valid else None
    upper = n + budget if valid else None
    guard = upper <= MAX_INT if valid else None
    return {
        'conditional_membership_publications_upper': k + e if valid else None,
        'conditional_counter_increments_upper': budget,
        'conditional_next_attempt_id_upper': upper,
        'nonnegative_counter_and_successor_guard': guard,
        'missing_premises': missing,
        'usable_next_attempt_id_upper': upper if guard and not missing else None,
        'scheduler_entry_upper': None,
        'whole_save_capacity_established': False,
        'whole_pipeline_capacity_established': False,
    }
