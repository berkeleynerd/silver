"""Natural counter transfer for one explicitly bounded continuing call.

A number supplied here is a premise, never evidence of a retained ref or a
process-family invariant. The checked state binding is in compose.py.
"""
def registration_transfer(initial, registrations, value_bits=63):
    assert type(initial) is int and initial >= 0
    assert type(registrations) is int and registrations >= 0
    assert type(value_bits) is int and 2 <= value_bits <= 64
    maximum = (1 << (value_bits - 1)) - 1
    assert initial <= maximum
    final = initial + registrations
    assert final <= maximum, 'private registration counter can overflow'
    return {'initial': initial, 'registrations_upper': registrations,
            'first_tag_if_called': initial + 1 if registrations else None,
            'last_tag_upper': final if registrations else None,
            'counter_after_call_upper': final, 'value_bits': value_bits,
            'signed_maximum': maximum, 'remaining_headroom': maximum-final,
            'no_overflow_during_bounded_call': True}
