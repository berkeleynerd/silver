#!/usr/bin/env python3
"""Conditional warning-map request interface; not a source admission gate."""
import argparse
import json

PRIMES = (7, 13, 31, 61, 127, 251, 509, 1021, 2039, 4093, 8191,
          16381, 32749, 65521, 131071, 262139, 524287, 1048573, 2097143,
          4194301, 8388593, 16777213, 33554393, 67108859, 134217689,
          268435399, 536870909, 1073741789, 2147483647, 4294967291)
P0 = 4093
U32 = 2**32 - 1
SIGNED_SIZE_MAX = 2**63 - 1


def prime_at_least(n):
    return next((p for p in PRIMES if p >= n), None)


def rounded_ceiling(n):
    """Power-of-two ceiling, conservative for smaller GGC extra orders."""
    return 1 << (n - 1).bit_length()


def evaluate(C, N, other_original_gigi_put_calls=None):
    for name, value, lower in (("C", C, 1), ("N", N, 0)):
        if type(value) is not int or value < lower:
            raise ValueError(f"{name} must be an integer >= {lower}")
    R = other_original_gigi_put_calls
    if R is not None and (type(R) is not int or R < 0):
        raise ValueError("other_original_gigi_put_calls must be a nonnegative integer")
    local = 2*C + N
    selected = 2*C + 1
    result = dict(
        C=C, N=N, prefix_capacity_ceiling=P0,
        local_gigi_suppression_call_ceiling=local,
        other_original_gigi_put_calls=R,
        direct_warning_copy_calls=C+1,
        additional_call_location_warning_copy_calls=C,
        selected_initial_gimplifier_warning_put_call_ceiling=selected,
        original_gigi_source_count_closed=False,
        complete_gimplifier_lifetime_closed=False,
        complete_collector_lifetime_closed=False,
        conditional_map_transfer=None,
    )
    if R is None:
        return result
    incoming_puts = local + R
    incoming = P0 + incoming_puts
    outgoing = incoming + selected
    p_in = prime_at_least(max(P0, 2*incoming))
    p_out = prime_at_least(max(P0, 2*outgoing))
    checks = dict(
        live_and_occupied_sufficient_region=outgoing <= 2**30-1,
        prime_exists=p_out is not None,
        prime_probe_region=p_out is not None and p_out <= 2**31-1,
        probe_addition=p_out is not None and 2*p_out-3 <= U32,
        entry_request_and_pointer_span=(p_out is not None
                                        and 16*p_out <= SIGNED_SIZE_MAX),
        load_factor_products=(p_out is not None and 3*p_out <= 2**64-1
                              and 4*outgoing <= 2**64-1),
    )
    result['conditional_map_transfer'] = dict(
        original_gigi_put_call_ceiling=incoming_puts,
        incoming_live_or_occupied_ceiling=incoming,
        outgoing_live_or_occupied_ceiling=outgoing,
        incoming_capacity_ceiling=p_in,
        outgoing_capacity_ceiling=p_out,
        request_groups=[
            dict(name='possible_original_gigi_control', count=1,
                 raw_bytes_each=64, rounded_bytes_each_ceiling=64),
            dict(name='original_gigi_initial_or_replacement_backbones',
                 count=incoming_puts,
                 raw_bytes_each=None if p_in is None else 16*p_in,
                 rounded_bytes_each_ceiling=None if p_in is None
                 else rounded_ceiling(16*p_in)),
            dict(name='selected_gimplifier_replacement_backbones', count=selected,
                 raw_bytes_each=None if p_out is None else 16*p_out,
                 rounded_bytes_each_ceiling=None if p_out is None
                 else rounded_ceiling(16*p_out)),
        ],
        additive_GGC_event_ceiling=1+incoming_puts+selected,
        additional_singleton_finalizer_registrations_ceiling=1,
        additional_vector_finalizer_registrations=0,
        checks=checks,
        conditional_map_interface_fits=all(checks.values()),
    )
    return result


if __name__ == '__main__':
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument('C', type=int)
    parser.add_argument('N', type=int)
    parser.add_argument('--other-original-gigi-put-calls', type=int)
    args = parser.parse_args()
    print(json.dumps(evaluate(args.C, args.N, args.other_original_gigi_put_calls),
                     indent=2, sort_keys=True))
