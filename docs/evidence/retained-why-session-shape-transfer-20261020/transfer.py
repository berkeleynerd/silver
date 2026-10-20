"""Mathematical shape bounds from a typed fixed-forest atom certificate.

This does not replay opening, execute Why3, or prove successful serialization.
Unknown/unsupported atom forms prevent a numerical L export.
"""

TAGGED_MAX = 2**62 - 1
STRING_MAX = 8 * (2**54 - 1) - 1


def nat(x):
    if type(x) is not int or x < 0:
        raise ValueError("expected a nonnegative mathematical integer")
    return x


def constant_bound(c):
    """SV6 const_v2 output, independent of the 1,024 byte check."""
    kind = c.get("kind")
    if kind in ("int", "real"):
        parts = c.get("parts", [])
        required = 1 if kind == "int" else 3
        if len(parts) != required or any(p.get("decimal_bytes") is None for p in parts):
            return None
        # No unsupported numeric representation is given an invented value.
        if any(p.get("representation") not in
               ("immediate_OCaml_int", "heap_Zarith_custom") for p in parts):
            return None
        return sum(nat(p["decimal_bytes"]) for p in parts) + (3 if kind == "real" else 0)
    if kind == "string":
        if c.get("bytes") is None:
            return None
        return 4 * nat(c["bytes"]) + 2
    return None


def task_bound(*, term_occurrences, binder_occurrences, max_case_patterns,
               original_name_max, constant_max):
    t, b, w, m, c = map(nat, (term_occurrences, binder_occurrences,
                             max_case_patterns, original_name_max, constant_max))
    q = t * w
    p = t + q
    a = b + q
    # Each call has <=2 indices writes. Candidate indices that test occupied
    # are distinct; both decimal and quote families are injective/disjoint.
    # I_k <= I_(k-1) + 2*k, hence I_p <= p*(p+1).
    index = p * (p + 1)
    # max(index, decimal digits) also handles index=0 without a special case.
    name = m + max(index, len(str(index)))
    alpha = len(str(a))
    atom = max(name, alpha, c)
    return dict(T=t, Q=q, P=p, A=a, suffix_index_upper=index,
                original_name_bytes_upper=m, name_bytes_upper=name,
                alpha_bytes_upper=alpha, constant_bytes_upper=c,
                atom_bytes_upper=atom, shape_bytes_upper=p * (1 + atom),
                guards=dict(alpha_counter=a <= TAGGED_MAX,
                            suffix_counter_and_successor=index + 1 <= TAGGED_MAX,
                            individual_name_string=name <= STRING_MAX,
                            individual_constant_string=c <= STRING_MAX))


def derive(atoms, *, explanation_prefix_count=None):
    cert = atoms["saved_occurrence_certificate"]
    visits = cert["visits"]
    tasks = cert["tasks"]
    formulas = cert["formulas"]
    j = sum(len(tasks[str(v["task"])]["propositions"]) + 1 for v in visits)
    assert j == atoms["proposition_and_explanation_requests_per_save"]
    assert len(visits) == atoms["imported_APn_visits"]
    unsupported = [k for k, c in atoms["constants"].items()
                   if constant_bound(c) is None]
    ready = (atoms["typed_graph_complete"] is True and
             atoms["numeric_components_complete"] is True and
             not atoms["coverage_failures"] and not unsupported and
             not atoms["unsupported_numeric_components"])
    bounds = {}
    if ready:
        cm = max((constant_bound(c) for c in atoms["constants"].values()), default=0)
        for address, task in tasks.items():
            t = sum(formulas[str(p["formula"])]["opened_term_occurrences"]
                    for p in task["propositions"])
            b = sum(formulas[str(p["formula"])]["opened_binder_occurrences"]
                    for p in task["propositions"])
            assert t == atoms["imported_shape_term_visits_per_task"][address]
            bounds[address] = task_bound(term_occurrences=t,
                binder_occurrences=b, max_case_patterns=atoms["max_case_pattern_occurrences"],
                original_name_max=atoms["original_name_bytes_max"], constant_max=cm)
    l = sum(bounds[str(v["task"])]["shape_bytes_upper"] for v in visits) if ready else None
    attrs = atoms["shape_attribute_union"]
    p = explanation_prefix_count
    if p is not None:
        p = nat(p)
    e = max(11, p * (attrs["sum_bytes"] + 2 * attrs["count"]) + 1) if p is not None else None
    return dict(case=atoms["case"], provenance=atoms["provenance"],
        B_imported=cert["B_binders"], G=len(visits), J=j, L=l,
        typed_atom_join_established=ready, unsupported_constant_pointers=unsupported,
        task_bounds=bounds,
        explanation=dict(prefix_count=p, attribute_union_count=attrs["count"],
            attribute_union_bytes=attrs["sum_bytes"],
            per_insertion_bytes_upper=e,
            per_save_bytes_upper=len(visits)*e if e is not None else None,
            formula="G * max(11, p * (attribute_union_bytes + 2 * attribute_union_count) + 1)",
            included_in_Shape_buffer_L=False),
        numerical_guards=dict(J_tagged=j <= TAGGED_MAX,
            L_string=l <= STRING_MAX if l is not None else None,
            three_save_shape_buffer=3*l <= STRING_MAX if l is not None else None,
            all_task_guards=all(all(b["guards"].values()) for b in bounds.values()) if ready else None),
        ordinary_signal_source_configuration_join_established=False,
        entry_shape_buffer_representation_established=False,
        shape_dictionary_consistency_established=False,
        complete_save_capacity_established=False,
        complete_identifier_counter_established=False,
        whole_pipeline_capacity_established=False)
