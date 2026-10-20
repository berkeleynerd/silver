"""Arithmetic interface for one strict comparison, not an OCaml proof."""
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def candidate_interface(mass, bound_slots):
    if any(type(x) is not int or x < 0 for x in (mass, bound_slots)):
        raise ValueError("nonnegative mathematical integer bounds required")
    if bound_slots + 2 > (1 << 62) - 1:
        raise ValueError("private binder/map arithmetic is not representable")
    return {
        "paired_term_entries_upper": mass,
        "bnd_upper": bound_slots,
        "private_bound_map_entries_upper": bound_slots,
        "private_height_arithmetic_upper": bound_slots + 2,
        "private_bound_insertions_both_sides_upper": 2 * bound_slots,
        "private_map_node_constructions_upper": 8 * bound_slots * (bound_slots + 1),
        "active_frames_each_side_upper": mass,
        "descend_frame_probes_both_sides_upper": 2 * mass * mass,
        "descend_lookup_calls_both_sides_upper": 4 * mass * mass,
    }


def compose():
    r57 = json.loads((HERE.parent / "retained-why-returned-storage-20261020/result.json").read_text())
    assert r57["complete_returned_storage_under_named_source_and_mutation_premises"]
    assert all((r["M"], r["P"], r["V"]) == (99, 8, 1) for r in r57["domains"])
    return {
        "scope": "one Hsdecl.equal old candidate call in first inline",
        "candidate_operand": "right",
        "attributable_effect": {"Ident_registrations": 0, "all_Hashcons_next_tag_increments": 0,
                                "hashcons_or_unique_requests": 0, "tag_field_writes": 0},
        "context_strict_term_interface": candidate_interface(99, 8),
        "old_saved_map_lookup_depth_bounded_by_candidate": False,
        "old_attribute_enumeration_bounded_by_candidate": False,
        "uniform_old_work_bound_needed_for_this_counter_or_request_interface": False,
        "source_allocations": {"map_Node_words": 5, "attribute_More_words": 4,
                               "frame_pair_words": 2, "frame_cons_words": 2,
                               "bound_state_tuple_words": 3, "Trm_words": 2,
                               "Bnd_words": 1, "find_opt_Some_words": 1,
                               "compiler_closures": "fixed layouts under existing compiler correspondence"},
        "primitive_comparison": {"structural_compare_stack_entries_upper": 1,
                                 "structural_compare_initial_stack_entries": 8,
                                 "dynamic_structural_compare_stack_requests": 0,
                                 "bigint_compare_dynamic_requests": 0},
        "conditions": [
            "correct source/native correspondence and ordinary runtime/library behavior",
            "finite well-formed operand/list/map/attribute/type/location/constant representations",
            "valid tag identity and immutable operand data while compared",
            "candidate formula M/P and variable-only images from accepted original-context interface",
            "sufficient physical stack/memory under the existing trusted boundary",
            "asynchronous save work charged separately with the existing process-global allowance",
        ],
        "closed": {"source_Ident_and_hash_tag_effect": True,
                   "comparison_local_correctness_integer_and_request_arithmetic_under_conditions": True},
        "outside_scope": ["candidate hash traversal", "Weak.merge table/index/growth arithmetic",
                          "Hashcons caller next_tag increment", "source caller construction counters",
                          "later-stage candidates without the original-context interface",
                          "whole quiet pipeline capacity"],
        "goal_policy": "Pgoal uses unique; keep separate R56 candidate/goal construction and hashing bounds",
        "fresh_escape_allowance": False,
        "machine_checked_operational_semantics": False,
        "whole_quiet_capacity": False,
    }
