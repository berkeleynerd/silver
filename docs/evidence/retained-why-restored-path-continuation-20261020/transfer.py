"""Bound bytes of supplied serializer strings, not their attempted construction."""


def supplied_bound(nonidentifier_bytes, identifier_visits, string_limit,
                   remaining_saves, *, valid_string_representation):
    values = (nonidentifier_bytes, identifier_visits, string_limit, remaining_saves)
    if any(v is not None and (type(v) is not int or v < 0) for v in values):
        raise ValueError('expected nonnegative mathematical integer or null')
    upper = None
    if valid_string_representation is True and all(v is not None for v in values[:3]):
        upper = nonidentifier_bytes + identifier_visits * string_limit
    return {
        'supplied_raw_string_bytes_sum_per_save_upper': upper,
        'supplied_raw_string_bytes_sum_all_saves_upper':
            None if upper is None or remaining_saves is None else upper * remaining_saves,
        'attempted_qualified_path_joined_bytes_upper': None,
        'path_construction_allocation_bound': None,
        'captured_small_path_bound_preserved': False,
        'complete_save_capacity_established': False,
    }
