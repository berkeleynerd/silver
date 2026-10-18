#!/usr/bin/env python3
"""Selected literal ingress transfer; not a source recognizer or admission gate."""

import argparse
import json


PRIMES = (7, 13, 31, 61, 127, 251, 509, 1021, 2039, 4093, 8191, 16381,
          32749, 65521, 131071, 262139, 524287, 1048573, 2097143, 4194301,
          8388593, 16777213, 33554393, 67108859, 134217689, 268435399,
          536870909, 1073741789, 2147483647, 4294967291)


def higher_prime(n):
    return next((p for p in PRIMES if p >= n), None)


def evaluate(c, n):
    """Caller supplies established direct-literal source counters C >= 1, N >= 0.

    Every decoded literal must have length in 0..INT_MAX. Selected source,
    configuration, LP64 layout and predecessor lowering premises are required.
    All arithmetic here uses mathematical integers. Global native counter and
    collector joins remain the caller's obligations.
    """
    if type(c) is not int or c < 1 or type(n) is not int or n < 0:
        raise ValueError("expected integer C >= 1 and N >= 0")
    rows = [
        dict(object="DECL_EXPR, ADDR_EXPR, optional NOP_EXPR", occurrences=6*c,
             raw_bytes=32, rounded_bytes=32),
        dict(object="one-actual CALL_EXPR", occurrences=c,
             raw_bytes=56, rounded_bytes=64),
        dict(object="fat and bounds CONSTRUCTOR", occurrences=2*c,
             raw_bytes=24, rounded_bytes=32),
        dict(object="null DECL_EXPR, GOTO_EXPR, LABEL_EXPR", occurrences=3*n,
             raw_bytes=32, rounded_bytes=32),
        dict(object="bare RETURN_EXPR", occurrences=1,
             raw_bytes=32, rounded_bytes=32),
    ]
    w = sum(row["occurrences"] for row in rows)
    copies = [dict(object=row["object"], requests_upper=3*row["occurrences"],
                   raw_bytes_upper=row["raw_bytes"],
                   rounded_bytes_upper=row["rounded_bytes"]) for row in rows]
    copies.append(dict(object="copied two-element constructor vector",
                       requests_upper=6*c, raw_bytes_upper=72,
                       rounded_bytes_upper=128))
    protected = c + 1
    slots = higher_prime(max(13, 2*protected))
    return dict(
        source_input=dict(calls=c, nulls=n, each_literal_length_min=0,
                          each_literal_length_max=2147483647),
        ordinary_occurrence_rows=rows,
        whole_body_copy_weight_upper=w,
        whole_body_individual_GGC_request_groups=copies,
        whole_body_ordinary_tree_requests_upper=3*w,
        whole_body_constructor_vector_requests_upper=6*c,
        whole_body_GGC_request_events_upper=3*w+6*c,
        whole_body_raw_request_bytes_sum_upper=sum(
            row["requests_upper"]*row["raw_bytes_upper"] for row in copies),
        whole_body_rounded_request_bytes_sum_upper=sum(
            row["requests_upper"]*row["rounded_bytes_upper"] for row in copies),
        whole_body_fresh_STRING_CST_TYPE_DECL_and_scalar_constant_requests=0,
        local_decl_expr_metadata_nonconstant_unshare_or_materialization_calls=0,
        pointer_type_walker_duplicate_set_requests=0,
        protected_set=dict(
            object_requests_upper=1, initial_slots=13, slot_bytes=8,
            distinct_entries_upper=protected, deletions=0,
            backing_requests_upper=1+protected,
            maximum_backing_slots_upper=slots,
            maximum_backing_request_bytes_upper=None if slots is None else 8*slots,
            selected_prime_table_condition=slots is not None,
            allocation_domain="ordinary; separate from GGC deltas",
            object_size_and_allocator_bookkeeping_joined=False),
        materialization_data_address_delta=dict(
            tree_requests_upper=2*c, raw_and_rounded_bytes_each=32,
            rounded_request_bytes_sum_upper=64*c,
            fresh_string_type_decl_and_vector_requests=0),
        selected_helper_subtotal_GGC_events_upper=8*c,
        selected_helper_subtotal_includes_accepted_6C=True,
        corrected_direct_gimplifier_GGC_events_upper=10*c+2*n+2,
        direct_subtotal_bind_correction_GGC_events_upper=c,
        GENERIC_and_GIMPLE_bind_count_upper=c+1,
        simultaneous_GENERIC_bind_depth_upper=2,
        bind_stack=dict(allocation_domain="ordinary",
                        capacities_upper=[8, 16], requests_upper=2,
                        request_bytes_upper=[72, 136],
                        cumulative_request_bytes_upper=208,
                        maximum_request_bytes_upper=136),
        corrected_CF_gimple_set_block_calls_upper=4*c+2*n+2,
        CF_local_declarations_vector_elements_upper=c,
        direct_copy_warning_calls_upper=c+1,
        conditional_whole_body_ingress_closed=True,
        complete_gimplifier_GGC_request_events_upper=None,
        complete_gimplifier_lifetime_closed=False,
        whole_pipeline_capacity_established=False,
        production_admission_changed=False,
    )


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("calls", type=int)
    parser.add_argument("nulls", type=int)
    args = parser.parse_args()
    print(json.dumps(evaluate(args.calls, args.nulls), indent=2, sort_keys=True))
