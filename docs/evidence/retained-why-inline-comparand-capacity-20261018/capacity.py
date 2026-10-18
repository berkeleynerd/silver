"""Pure source-operation/representation transfers; no native time/RAM model."""

INT_MAX = (1 << 62) - 1


def natural(value):
    assert type(value) is int and value >= 0
    return value


def shape(n, b, p, g, depth, saved_keys, attrs):
    values = dict(n=n, b=b, p=p, g=g, depth=depth, saved_keys=saved_keys, attrs=attrs)
    for value in values.values():
        natural(value)
    assert n >= 1 and depth <= n
    return values


def strict_transfer(left, right):
    """For well-formed finite terms, nullary patterns and immediate integers.

    n/b/p/g count opened terms/bound slots/patterns/trigger groups, including
    repeated edges. Empty groups are allowed when counted in g. Types and
    symbol comparisons use tags/identity; locations have three integer fields.
    These numeric arguments do not certify membership in the retained state.
    """
    left, right = shape(**left), shape(**right)
    q = min(left['n'], right['n'])
    probes = q * (left['depth'] + right['depth'])
    visits = 2*q*sum(side['depth']*(max(side['b'], side['saved_keys'])+1)
                     for side in (left, right))
    slots = left['b'] + right['b']
    bound_keys = max(left['b'], right['b'])
    attrs = left['attrs'] + right['attrs']
    return {
        'term_pair_entries': q,
        'type_tag_comparisons': q,
        'attribute_set_comparisons': q,
        'attribute_enumeration_nodes': q*attrs,
        'attribute_helper_entries': 3*q*(attrs+2),
        'location_option_comparisons': q,
        'location_immediate_fields_compared': 3*q,
        'constant_comparisons': q,
        'immediate_bigint_comparisons': q,
        'custom_bigint_or_string_comparisons': 0,
        'frame_probes': probes,
        'map_lookups': 2*probes,
        'map_lookup_tree_entries': visits,
        'bound_map_insertions_or_singletons': slots,
        'bound_map_node_constructors': 4*(bound_keys+1)*slots,
        'frame_pairs_and_list_cells': 4*q,
        'descend_result_constructors': 2*q,
        'pattern_pair_entries': min(left['p'], right['p']),
        'list_cursor_tests': 8*(q+slots+left['p']+right['p']+left['g']+right['g']+1),
        'fresh_identifier_registrations': 0,
        'hashcons_requests': 0,
    }


def hash_transfer(term):
    """Strict source hashing of one candidate; cached rehash uses no callback."""
    term = shape(**term)
    n, b, p, g = (term[k] for k in ('n', 'b', 'p', 'g'))
    depth, saved, attrs = (term[k] for k in ('depth', 'saved_keys', 'attrs'))
    return {
        'term_entries': n,
        'type_tag_reads': n,
        'attribute_fold_tree_entries': n*(2*attrs+1),
        'frame_probes': n*depth,
        'map_lookups': 2*n*depth,
        'map_lookup_tree_entries': 2*n*depth*(max(b, saved)+1),
        'bound_map_insertions_or_singletons': b,
        'bound_map_node_constructors': 4*(b+1)*b,
        'frame_pairs_and_list_cells': 2*n,
        'descend_result_constructors': n,
        'pattern_entries': p,
        'list_cursor_tests': 8*(n+b+p+g+1),
        'constant_generic_hash_calls': n,
        'constant_generic_hash_input_value_nodes': 4*n,
        'immediate_discriminant_hash_calls': n,
        'custom_hash_callbacks': 0,
        'hash_combine_calls': (attrs+12)*n+4*(b+p+g+1),
        'fresh_identifier_registrations': 0,
    }


def add_vectors(vectors):
    result = {}
    for vector in vectors:
        for key, value in vector.items():
            result[key] = result.get(key, 0) + natural(value)
    return result


def no_resize_transfer(outer, bucket_max, oversize, limit, requests):
    """Weak.Make over_limit=2; initially unique objects and no foreign inserts.

    Every insertion crosses the size limit at most once. Before any first
    resize, oversize <= initial oversize + requests. The strict inequality
    test below therefore rules out that first resize inductively.
    """
    for value in (outer, bucket_max, oversize, limit, requests):
        natural(value)
    assert outer >= 7 and bucket_max <= limit
    assert oversize + requests <= outer // 2, 'first resize cannot be excluded'
    occupancy = bucket_max + requests
    bucket = max(bucket_max, (3*occupancy)//2+3)
    callbacks = requests*bucket_max + requests*(requests-1)//2
    return {
        'requests': requests,
        'outer_array_length': outer,
        'resizes': 0,
        'initial_bucket_occupancy_upper': bucket_max,
        'bucket_live_entries_upper': occupancy,
        'bucket_array_length_upper': bucket,
        'oversize_upper': oversize+requests,
        'rover_upper': outer-1,
        'find_or_slot_tests_upper': requests*(bucket+1),
        'weak_get_copy_calls_upper': requests*bucket,
        'shallow_declaration_copies_upper': callbacks,
        'equality_callbacks_upper': callbacks,
        'weak_get_after_equal_calls_upper': callbacks,
        'candidate_hash_calls_upper': requests,
        'old_object_rehash_callback_calls': 0,
        'copied_declaration_payload_words': 3,
        'growth_multiply_upper': 3*occupancy,
        'shrink_multiply_plus_two_absolute_upper': 2*bucket+6,
        'all_table_arithmetic_fits_signed_ocaml_int': max(outer, 3*occupancy, 2*bucket+6) <= INT_MAX,
        'array_length_condition': f'Sys.max_array_length >= {max(outer, bucket)}',
        'ephemeron_key_length_condition': f'Obj.Ephemeron.max_ephe_length >= {bucket}',
    }
