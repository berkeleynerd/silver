"""Candidate #206 extension of #202's frozen cut-C entry envelope.

Evidence arithmetic only, under the source/native proof in allocation.md.
This neither installs a configuration nor substitutes a synthetic state for
the actual populated counters. Acceptance of the two source providers is a
separate review premise. Common runtime/foreign/native stack bounds remain
with their existing providers.
"""
import copy
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
CONFIGURATION = "r78_private_triplicate_start_time_20261024"
BASELINE = "r78_repaired_quiet_timeless_j12_logging"
MAX_INT = 2**62 - 1
ARRAY_MAX = 2**54 - 1
WEAK_MAX = ARRAY_MAX - 2


def recipe_identity():
    files = json.loads((HERE / "recipe.json").read_text())["files"]
    for path, expected in files.items():
        data = (HERE / path).read_bytes()
        assert {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()} == expected
    return hashlib.sha256((json.dumps(files, sort_keys=True, indent=2) + "\n").encode()).hexdigest()


def extend_entry_envelope(baseline, *, configuration_identity):
    """Consume the exact baseline provider result plus this recipe's identity.

    All fixed launch-role/path/configuration premises of that baseline still
    apply. This is not an arbitrary process/driver/Main endpoint adapter.
    """
    if configuration_identity != recipe_identity():
        raise ValueError("the frozen seven-file triplicate-time recipe is required")
    inputs = json.loads((HERE / "baseline-entry-projection.json").read_text())
    role = baseline.get("role")
    if role not in inputs["envelopes"] or baseline != inputs["envelopes"][role]:
        raise ValueError("the exact source-produced baseline provider envelope is required")
    if baseline["configuration"] != BASELINE:
        raise ValueError("wrong baseline configuration")
    allocation = json.loads((HERE / "allocation.json").read_text())
    minor_delta = allocation["startup_minor_words"]
    assert minor_delta == 91752681
    assert all(allocation[key] == 0 for key in (
        "startup_major_words", "startup_remembered_entries", "startup_ephemeron_entries",
        "startup_custom_entries", "startup_extra_minor_resources", "startup_extra_major_resources",
        "startup_dependent_bytes", "new_native_buffer_or_descriptor_owners"))
    out = copy.deepcopy(baseline)
    out["configuration"] = CONFIGURATION
    out["configuration_identity"] = configuration_identity
    out["baseline_provider_identity"] = inputs["source_identity"]
    out["minor_history_words_upper"] += minor_delta
    out["protected_managed_history_words_upper"] += minor_delta
    out["managed_static_carrier_words_upper"] += minor_delta
    carrier = out["managed_static_carrier_words_upper"]
    minor = out["minor_history_words_upper"]
    out["one_byte_payload_upper"] = 8 * carrier
    for row in out["owners"].values():
        requests = minor // row["minimum_minor_words"]
        row["completed_requests_upper"] = requests
        row["counter_value_upper"] = row["initial"] + requests
        if row["kind"] == "weak":
            for key in ("outer_length_upper", "bucket_length_upper", "allocated_bucket_slots_upper",
                        "oversize_upper", "rover_strict_upper"):
                row["backing"][key] = carrier
            row["backing"]["live_entries_upper"] = requests
        elif row["kind"] == "ephemeron":
            row["backing"].update(outer_length_upper=carrier,
                                   stored_bucket_cells_upper=requests, size_upper=requests)
    for key in ("physical_backing_words_upper", "individual_array_slots_upper",
                "physical_list_map_bucket_cells_upper"):
        out["other_reachable_managed_memos"][key] = carrier
    out["guards"].update(
        all_named_counters=all(row["counter_value_upper"] <= MAX_INT for row in out["owners"].values()),
        weak_growth_operands=3 * carrier + 3 <= MAX_INT,
        weak_max_size_unreached=carrier < WEAK_MAX,
        ordinary_array_max_unreached=carrier < ARRAY_MAX,
        map_and_container_arithmetic=2 * carrier + 3 <= MAX_INT,
        paired_byte_arithmetic=16 * carrier + 2 <= MAX_INT,
        minor_prefix_margin=minor < 2**28)
    assert all(out["guards"].values())
    out["configuration_206_extension_available"] = True
    out["configuration_206_extension_review_status"] = "candidate, separate review required"
    out["added_timing_state"] = {
        "selected_driver_triplets": 3, "independent_records": 9,
        "unit_array_lengths": 0, "search_lazies_unforced_at_C": 9,
        "match_lazies_unforced_at_C": 9, "placeholder_search_state": "None",
        "reported_attempt_time_domain": ["0", "binary64 0.000001"],
        "reported_Max_Time_ceiling": 1,
    }
    out["startup_allocation_delta"] = {k: v for k, v in allocation.items() if k.startswith("startup_")}
    out["native_stack_requirement"] = (
        "Existing sufficient physical stack/runtime premise plus the fixed Call.timeregexp "
        "constructor chain; parser linked-stack/tail dispatch and 2/6-byte regexp paths "
        "introduce no recursion depending on Main, result-output length, or attempt count. "
        "No captured stack-byte equality or aggregate stack fit is asserted.")
    return out


def all_envelopes():
    inputs = json.loads((HERE / "baseline-entry-projection.json").read_text())
    configuration_identity = recipe_identity()
    return {role: extend_entry_envelope(base, configuration_identity=configuration_identity)
            for role, base in sorted(inputs["envelopes"].items())}


def later_owned_words(*, parse_entries, finished_results, attempted_searches, owners=9):
    """Additional post-C allocations, with existing result/runtime owners outside.

    parse_entries counts entry to selected authentic Finished-result parsing,
    including abandoned or interrupted calls. Each entry attempts at most three
    timing searches. finished_results independently counts entry to the controller
    ProverFinished arm before smoothing, including queued cancellations and
    interrupted bodies. Each arm entry can cause at most one fuzzy result copy.
    No relation between the two counts, or successful completion, is assumed.

    512 per forced Start owner, 256 per attempted native search, 10 per grep_time
    wrapper, and 7 per possible additional fuzzy result copy. No callback budget
    is renewed. GC copying, remembered writes and native/runtime resources are
    composed by their existing whole-process providers, not counted as words
    newly owned by these source constructors.
    """
    values = (parse_entries, finished_results, attempted_searches, owners)
    if any(type(v) is not int or v < 0 for v in values):
        raise ValueError("nonnegative integral counts required")
    if owners > 9 or attempted_searches > 3 * parse_entries:
        raise ValueError("the three selected independent triplets and search bound are required")
    return 512 * owners + 266 * attempted_searches + 7 * finished_results
