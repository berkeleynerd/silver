"""Arithmetic consumer of the documented native Hashtbl prefix contract.

This function checks supplied premises; it does not establish capture validity,
source ownership, or correspondence by accepting a boolean.
"""

MAX_INT = (1 << 62) - 1
MAX_ARRAY = (1 << 54) - 1
PREMISES = (
    "entry_layout_and_chains_established",
    "key_payload_contract_established",
    "native_and_signal_contract_joined",
    "operation_and_insertion_bound_established",
    "traversal_client_contract_established",
)


def bound_table(row):
    """Return a conditional result; missing facts never become zero or true.

    Modes: persistent = add/replace/clear allowed; clear_before_add = every
    insertion occurs after a completed clear in the covered interval; readonly
    = no mutation; clear_only = clear and reads, no insertion. No mode admits
    remove, reset, filter_map_inplace, rebuild or direct field mutation.
    """
    mode = row.get("mode")
    if mode not in ("persistent", "clear_before_add", "readonly", "clear_only"):
        raise ValueError("unknown operation mode")
    values = {k: row.get(k) for k in ("entry_size", "entry_visits", "bucket_capacity",
                                     "insertion_opportunities")}
    for key, value in values.items():
        if value is not None and (type(value) is not int or value < 0):
            raise ValueError(key)
    if mode in ("readonly", "clear_only") and values["insertion_opportunities"] not in (0, None):
        raise ValueError("nonmutating mode has insertions")
    s, v, c, a = (values[k] for k in ("entry_size", "entry_visits", "bucket_capacity",
                                     "insertion_opportunities"))
    complete_numbers = all(x is not None for x in (s, v, c, a))
    numeric_guards = None
    visit_upper = scalar_upper = insertion_size_upper = None
    if complete_numbers:
        visit_upper = v + a
        scalar_upper = max(s, a) if mode == "clear_before_add" else s + a
        insertion_size_upper = a if mode == "clear_before_add" else s + a
        numeric_guards = (1 <= c <= MAX_ARRAY and c & (c - 1) == 0
                          and scalar_upper <= MAX_INT
                          and (a == 0 or insertion_size_upper <= 2 * c))
    premises = {name: row.get(name) is True for name in PREMISES}
    ready = numeric_guards is True and all(premises.values())
    return {
        "table": row.get("table"), "mode": mode,
        "numeric_guards_pass": numeric_guards,
        "missing_premises": [name for name, yes in premises.items() if not yes],
        "conditional_binding_visits_upper": visit_upper,
        "conditional_scalar_size_upper": scalar_upper,
        "conditional_size_at_insertion_upper": insertion_size_upper,
        "prefix_traversal_contract_established": ready,
        "binding_visits_upper": visit_upper if ready else None,
        "scalar_size_upper": scalar_upper if ready else None,
        "complete_save_capacity_established": False,
    }
