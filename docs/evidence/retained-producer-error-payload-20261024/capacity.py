"""Conditional fixed-process terminal payload arithmetic; no execution model."""


def payload_bounds(path_bytes: int) -> dict:
    """P must dominate the actual accepted pre- and post-cut path providers.

    All source/control/resource and canonical-response premises are supplied by
    the research note. Values here are bounds, not observed native footprints.
    """
    if type(path_bytes) is not int or path_bytes < 180:
        raise ValueError("P must be an integer at least 180")
    p = path_bytes
    leaf = max(4096, 4 * p + 3072)
    primary = leaf + 3 * p + 5552
    early = leaf + 1536
    post = leaf + p + 3072
    line = p + 48
    inside_bytes = 2 * primary + 7689
    early_bytes = 3 * early + 7177
    post_bytes = 2 * post + 4 * (line + p) + 4043
    merged_bytes = max(inside_bytes, early_bytes, post_bytes)
    return {
        "P": p,
        "canonical_response_line_ceiling": line,
        "leaf": leaf,
        "primary": primary,
        "early_primary": early,
        "post_primary": post,
        "inside_main_merged": inside_bytes,
        "before_main_merged": early_bytes,
        "post_cut_merged": post_bytes,
        "active_normal_suffix_bytes": 5067,
        "merged_bytes": merged_bytes,
        "decoded_error_bytes": merged_bytes,
        "error_tail_bytes": merged_bytes,
        "compiler_abort_tail_guard": merged_bytes + 7 <= 32767,
        "assumptions_are_attached_by_this_function": False,
    }
