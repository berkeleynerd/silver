"""Attach reviewed table/counter arguments; this is not a proof by flags.

The named external premises and the source arguments in the research note
govern every exported bound. Legacy whole-client flags are deliberately not
reinterpreted as structural table facts.
"""
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
MAX_INT = (1 << 62) - 1
MAX_ARRAY = (1 << 54) - 1
EXTERNAL = [
    "selected_source_native_runtime_behavior",
    "whole_post_cut_single_worker_and_native_frame_preservation",
    "whole_post_cut_successful_signal_mask_ignore_and_no_reinstallation",
    "whole_post_cut_no_unmodeled_callback_table_or_counter_mutator",
]


def read(relative):
    return json.loads((ROOT / relative).read_text())


def derive():
    entry = read("docs/evidence/retained-why-save-state-join-20261020/result.json")
    counter = {x["case"]: x for x in read(
        "docs/evidence/retained-why-attempt-counter-continuation-20261020/result.json")["cases"]}
    theory = {x["case"]: x for x in read(
        "docs/evidence/retained-why-theory-cache-control-20261020/selected-join.json")}
    cases, attached, guarded, replaced = [], 0, 0, 0
    for row in entry["cases"]:
        name, tables = row["case"], []
        growth = row["conditional_growth"]
        assert row["logical_graph_correspondence_established"]
        assert row["extension_decode_replayed_byte_equal"]
        assert growth["continued_signal_contract_supplied"]
        assert growth["remaining_signal_save_entries_upper"] == 2
        assert growth["remaining_all_save_entries_upper"] == 3
        for application in row["table_applications"]:
            old, previous = application["inputs"], application["conditional_result"]
            assert old["entry_layout_and_chains_established"]
            assert previous["prefix_traversal_contract_established"] is False
            s, v, c, a = (old[k] for k in (
                "entry_size", "entry_visits", "bucket_capacity", "insertion_opportunities"))
            assert all(type(x) is int and x >= 0 for x in (s, v, c, a))
            assert 1 <= c <= MAX_ARRAY and c & (c - 1) == 0
            scalar = max(s, a) if old["mode"] == "clear_before_add" else s + a
            insertion_size = a if old["mode"] == "clear_before_add" else s + a
            guard = scalar <= MAX_INT and (a == 0 or insertion_size <= 2 * c)
            assert guard == previous["numeric_guards_pass"]
            assert previous["conditional_binding_visits_upper"] == v + a
            assert previous["conditional_scalar_size_upper"] == scalar
            method = "accepted_no_resize_prefix"
            visits = v + a
            if not guard:
                assert old["table"] == "th_state"
                t = theory[name]
                assert t["selected_control_argument_applicable"]
                assert t["pid"] == row["new_pid"]
                assert t["theory_count"] == growth["preserved_forest"]["Th"]
                c, scalar, visits = (t[k] for k in (
                    "capacity_upper", "scalar_size_upper", "binding_visits_upper"))
                method = "accepted_first_resize_and_selected_control"
                replaced += 1
            else:
                guarded += 1
            tables.append({
                "table": old["table"], "method": method,
                "capacity_upper": c, "scalar_size_upper": scalar,
                "binding_visits_per_invocation_upper": visits,
                "structural_prefix_contract_attached_under_external_premises": True,
                "key_and_payload_structural_validity_attached": True,
                "operation_and_insertion_inventory_attached": True,
                "client_owned_table_mutation_accounted": True,
                "legacy_whole_traversal_client_capacity_established": False,
            })
            attached += 1
        global_table = next(x for x in tables if x["table"] == "proofAttempt_table")
        astats = growth["conditional_A_stats_upper"]
        axml = growth["conditional_A_xml_upper"]
        assert global_table["binding_visits_per_invocation_upper"] == astats
        cr = counter[name]
        assert cr["pid"] == row["new_pid"]
        ci, ct = cr["inputs"], cr["conditional_transfer"]
        for key in ("fresh_counter_and_id_domain_joined", "selected_constructor_callers_joined",
                    "terminal_abandoned_prefix_source_theorem"):
            assert ci[key]
        publications = ci["pair_key_domain_upper"] + ci["remaining_signal_exceptions_upper"]
        increments = publications + 1
        endpoint = ci["next_attempt_id0"] + increments
        assert 0 <= endpoint <= MAX_INT
        assert ct["conditional_next_attempt_id_upper"] == endpoint
        assert ct["conditional_membership_publications_upper"] == publications
        assert ct["conditional_counter_increments_upper"] == increments
        prover_bindings = growth["new_table_bindings_upper"]["session_prover_ids"]
        assert row["captured_entry"]["prover_id_bindings"] == 0
        assert prover_bindings <= 2 * 16
        frequency_capacity = 16
        while astats > 2 * frequency_capacity:
            frequency_capacity *= 2
        assert astats < MAX_INT and frequency_capacity <= MAX_ARRAY
        cases.append({
            "case": name, "pid": row["new_pid"], "tables": tables,
            "usable_under_external_premises": {
                "A_stats_upper": astats, "A_xml_upper": axml,
                "next_proofAttemptID_upper": endpoint,
                "counter_increments_upper": increments,
                "new_membership_publications_upper": publications,
                "new_shared_prover_id_bindings_upper": prover_bindings,
                "prover_id_scalar_and_abs_upper": prover_bindings,
                "private_stats_table_bindings_upper": min(astats, prover_bindings),
                "private_stats_table_capacity_upper": 16,
                "each_private_frequency_table_client_entry_binding_visits_upper": astats,
                "abandoned_private_frequency_resize_bucket_occurrences_upper": 2 * astats,
                "each_private_frequency_table_size_upper": astats,
                "each_private_frequency_table_capacity_upper": frequency_capacity,
                "private_frequency_value_upper": astats,
                "private_occurs_binding_visits_upper": prover_bindings,
                "private_occurs_capacity_upper": 16,
                "private_prover_map_keys_upper": growth["conditional_prover_key_domain_upper"],
                "private_id_map_keys_upper": growth["conditional_prover_key_domain_upper"],
            },
            "counter_native_commit_attached_under_external_premises": True,
            "private_tables_abandoned_on_interrupted_mutation": True,
            "successful_membership_to_global_lookup_at_every_prefix": False,
            "failed_lookup_chain_has_structural_bound": True,
            "scheduler_entry_upper": None,
            "complete_save_capacity_established": False,
            "whole_pipeline_capacity_established": False,
        })
    assert (attached, guarded, replaced) == (206, 203, 3)
    return {
        "scope": "Five fresh captured continuations through ordinary ending, including failed save prefixes.",
        "bound_kind": "Structural representation/visits, conditional on named existing external behavior premises; no physical service-success assumption.",
        "required_existing_external_premises": EXTERNAL,
        "whole_post_cut_native_frame_premise_empirically_or_universally_proved_here": False,
        "shared_table_applications_attached": attached,
        "no_resize_applications": guarded,
        "selected_theory_resize_replacements": replaced,
        "native_counter_bodies_newly_checked": 2,
        "legacy_outputs_modified": False,
        "legacy_whole_traversal_client_capacity_established": False,
        "complete_save_capacity_established": False,
        "whole_pipeline_capacity_established": False,
        "cases": cases,
    }


if __name__ == "__main__":
    print(json.dumps(derive(), indent=2, sort_keys=True))
