"""Conditional source transfer; it does not certify the native table premises."""

STATUS_LABELS = (
    "valid", "failure", "unknown", "highfailure", "timeout", "outofmemory",
    "steplimitexceeded", "invalid",
)


def table_transfer(entry, growth):
    """Visits and size remain separate, including pre-existing duplicates."""
    if entry is None:
        return {"binding_visits_upper": None, "size_upper": None,
                "no_resize_arithmetic": None, "new_bindings_upper": growth}
    visits, size, capacity = (entry[k] for k in ("binding_visits", "size", "capacity"))
    if min(visits, size) < 0 or capacity <= 0 or growth < 0:
        raise ValueError("invalid nonnegative input/capacity")
    return {"binding_visits_upper": visits + growth,
            "size_upper": size + growth,
            "no_resize_arithmetic": size + growth <= 2 * capacity,
            "new_bindings_upper": growth}


def compose(x, *, signal_contract=False, table_contract=False, tables=None):
    """All maxima are conditional on the note's selected-route/source premises.

    A table-contract flag is a caller assertion, never inferred from arithmetic.
    The continued signal contract applies once from the captured cut through
    ending; the budget is not reset at ordinary-save entry.
    """
    tables = {} if tables is None else tables
    numeric = [x[k] for k in (
        "A_stats0", "A_xml0", "pair_entries", "selected_provers",
        "prover_domain0_upper", "max_goal_multiplicity", "next_attempt_id0",
        "G", "T", "Th", "F", "Args",
    )]
    if min(numeric) < 0:
        raise ValueError("negative source input")
    k = x["pair_entries"]
    p = x["prover_domain0_upper"] + x["selected_provers"]
    # 2 is the accepted protocol's upper bound, not an observed delivery count.
    e = 2 if signal_contract else None
    r = None if e is None else 1 + e
    # K is used as a selected (goal,prover) KEY-domain bound here. A signal
    # exception caught by has_been_tried_by can invalidate the normal-route
    # once-per-pair entry argument. Persistent keys still bound insertions.
    additions = None if e is None else k + e
    a = None if additions is None else x["A_stats0"] + additions
    ax = None if additions is None else x["A_xml0"] + additions * x["max_goal_multiplicity"]
    growth = {
        "proofAttempt_table": additions,
        "each_goal_attempt_table": None if e is None else x["selected_provers"] + e,
        "pn_state": x["G"],
        "tn_state": x["T"],
        "th_state": None if e is None else x["Th"] + e,
        "file_state": None if e is None else x["F"] + e,
        "session_prover_ids": None if e is None else p + e,
    }
    transferred = {
        name: (None if amount is None else table_transfer(tables.get(name), amount))
        for name, amount in growth.items() if name != "each_goal_attempt_table"
    }
    return {
        "conditional_A_stats_upper": a,
        "conditional_A_xml_upper": ax,
        "next_attempt_id_upper": None,
        "next_attempt_id_reason": "Binding growth does not count constructor prefixes abandoned before membership publication; no interrupted-scheduler entry theorem is asserted here.",
        "conditional_prover_key_domain_upper": p,
        "remaining_signal_save_entries_upper": e,
        "remaining_all_save_entries_upper": r,
        "private_statistics_prover_bindings_per_save_upper": None if e is None else min(a, p + e),
        "private_prover_map_keys_upper": p,
        "private_prover_id_map_keys_upper": p,
        "new_table_bindings_upper": growth,
        "tables": transferred,
        "preserved_forest": {k: x[k] for k in ("G", "T", "Th", "F", "Args")},
        "proof_script_path_occurrences": 0 if x["all_scripts_none"] else None,
        "result_status_label_bytes_upper": max(map(len, STATUS_LABELS)),
        "usable_attempt_visit_bounds": {"A_stats": a, "A_xml": ax} if table_contract and signal_contract else None,
        "continued_signal_contract_supplied": signal_contract,
        "native_table_contract_supplied": table_contract,
        "whole_save_capacity_closed": False,
    }
