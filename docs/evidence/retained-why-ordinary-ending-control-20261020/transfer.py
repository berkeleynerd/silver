"""Conditional source transfer; no actual forest or success flag is fabricated."""
TAGGED_MAX = 2**62 - 1
STRING_MAX = 8 * (2**54 - 1) - 1

def natural_or_unknown(value):
    if value is None:
        return None
    if type(value) is not int or value < 0:
        raise ValueError('expected a nonnegative mathematical integer or None')
    return value

def transfer(*, binders=None, shape_insertions=None, apn_visits=None,
             shape_bytes=None, signal_protocol_established=None,
             ordinary_source_transfer_established=None, remaining_signals=None):
    supplied = dict(binders=natural_or_unknown(binders),
        shape_insertions=natural_or_unknown(shape_insertions),
        apn_visits=natural_or_unknown(apn_visits),
        shape_bytes=natural_or_unknown(shape_bytes))
    remaining_signals = natural_or_unknown(remaining_signals)
    if remaining_signals is not None and remaining_signals > 2:
        raise ValueError('the established selected protocol permits at most two remaining save callbacks')
    ready = (signal_protocol_established is True and
        ordinary_source_transfer_established is True and remaining_signals is not None)
    attempts = 1 + remaining_signals if ready else None
    products = {k: attempts*v if attempts is not None and v is not None else None
                for k,v in supplied.items()}
    guards = {k: v <= (STRING_MAX if k == 'shape_bytes' else TAGGED_MAX)
              if v is not None else None for k,v in products.items()}
    return dict(inputs=supplied, source_premises_established=ready,
        remaining_signal_save_callbacks=remaining_signals,
        save_traversals_upper=attempts, mathematical_upper=products,
        scalar_product_guards=guards,
        shape_buffer_bound_scope='position after the first save-owned clear; entry position/backing require separate bounds',
        actual_forest_join_established=False,
        shape_dictionary_consistency_established=False,
        complete_save_capacity_established=False,
        complete_identifier_counter_established=False,
        whole_pipeline_capacity_established=False)
