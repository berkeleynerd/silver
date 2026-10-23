"""Semantic/source-operation interface; not a whole capacity predicate."""


def lineage_key_bound(initial_keys, slots, live_keys):
    """Requires the separately proved binder-free saved-image invariant."""
    if any(type(x) is not int or x < 0 for x in (initial_keys, slots, live_keys)):
        raise ValueError("invalid lineage dimensions")
    return initial_keys + 4 * slots * live_keys


def bounds(mass, slots, dependency_heads=0):
    if any(type(x) is not int for x in (mass, slots, dependency_heads)):
        raise ValueError("dimensions must be mathematical integers")
    if mass < 1 or slots < 0 or dependency_heads < 0:
        raise ValueError("invalid input dimensions")
    return {
        "split_core_entries": mass,
        "positive_results": mass,
        "negative_results": mass,
        "max_visible_mass": 3 * mass,
        "max_visible_slots": slots,
        "positive_family_mass": 3 * mass * mass,
        "positive_negative_family_mass": 6 * mass * mass,
        "each_family_slots": mass * slots,
        "each_bwd_fwd_mass": mass,
        "drop_byso_roots": mass,
        "drop_byso_term_entries": mass * mass,
        "scoped_reconstruction_kernel_entries": 64 * mass * mass,
        "fresh_variable_registrations": (mass + 1) * slots,
        "axiom_decl_requests": mass,
        "axiom_prsymbol_registrations": mass,
        "axiom_tdecl_requests": mass,
        "axiom_dependency_meta_requests": mass * dependency_heads,
        "trivial_accumulator_upper": 3,
        "saved_map_bounds_supplied": False,
        "helper_internal_visits_included": False,
        "whole_capacity_rule_complete": False,
        "fresh_escape_allowance": False,
    }
