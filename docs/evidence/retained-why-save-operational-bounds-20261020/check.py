#!/usr/bin/env python3
"""Check retained sources and transfer boundaries, without predecessor replay."""
import hashlib
import json
from pathlib import Path
import platform
import tarfile
import time

from transfer import MAX_INT, MAX_STRING, transfer

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def main():
    started = time.monotonic()
    inputs = json.loads((HERE / "inputs.json").read_text())
    for name, expected in inputs["files"].items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    witnesses = json.loads((HERE / "source-witnesses.json").read_text())
    archives = {}
    for witness in witnesses:
        archive = witness["archive"]
        if archive not in archives:
            archives[archive] = tarfile.open(ROOT / archive)
        data = archives[archive].extractfile(witness["member"]).read()
        assert identity(data) == witness["member_identity"]
        lines = data.decode().splitlines(keepends=True)
        excerpt = "".join(lines[witness["first_line"] - 1:witness["last_line"]])
        assert excerpt == witness["text"], witness["name"]
    for archive in archives.values():
        archive.close()

    forests = json.loads((ROOT / inputs["shape_bounds"]).read_text())
    # Readiness follows the exact accepted shape-bound input contract, not a
    # newly established later-entry or source/native correspondence.
    forests = [{**forest, "shape_output_input_ready": True} for forest in forests]
    rows = [transfer(forest) for forest in forests]
    conditional_prefix_rows = [transfer(forest, explanation_prefix_count=2)
                               for forest in forests]
    expected = {
        "put_line": (47775, 195, 9605645635296, 8985),
        "put": (39690, 162, 7438332120546, 7473),
        "first_or_default": (7623, 99, 526763148795, 7713),
        "is_message": (660, 12, 17820545148, 1527),
        "input_is_valid": (945, 15, 28971414486, 1577),
    }
    for row, conditional in zip(rows, conditional_prefix_rows):
        c, g, length, e = expected[row["case"]]
        assert (row["gshape_add_calls"], row["apn_visits"], row["shape_append_bytes"]) == (c, g, length)
        assert row["explanation_bytes_per_insertion"] is None
        assert conditional["explanation_bytes_per_insertion"] == e
        for name in ("gshape_n_upper", "hyp_map_bindings_upper", "index_map_bindings_upper",
                     "shape_file_bytes_per_save_upper", "prover_id_abs_upper"):
            assert row[name] is None and conditional[name] is None, name
        assert row["guards"]["shape_buffer_extent"] is True
        assert row["complete_save_capacity_established"] is False
    assert len("(* shapes version: 6 *)\n") + 1 == 25
    assert len("why3session.xml") + 1 + len(".bak") == 20

    # Synthetic entry, deliberately inconsistent inverse maps and existing lists.
    forest = {"case": "synthetic", "G": 1, "J": 2, "L": 8,
              "shape_output_input_ready": True,
              "explanation": {"attribute_union_count": 1, "attribute_union_bytes": 3,
                              "typed_attribute_closure_established": True}}
    entry = {
        "gshape_n": 1, "hyp_map_bindings": 4, "index_map_bindings": 0,
        "dictionary_string_bytes_max": 9, "hyp_value_abs_max": 99,
        "bound_index_abs_max": 700, "bound_list_length_max": 7,
        "bound_table_bindings": 9, "old_shape_bytes_max": 5,
        "checksum_bytes_max": 32, "shape_buffer_capacity": 16,
        "prover_id_bindings": 3, "prover_id_scalar_size": 1,
        "prover_id_bucket_capacity": 16, "prover_id_abs_max": 1000,
        "session_dir_bytes": 20,
    }
    serializer = {"attempt_stat_visits": 12, "attempt_xml_visits": 4,
                  "file_visits": 1, "theory_visits": 1,
                  "transformation_visits": 2, "argument_visits": 3,
                  "path_component_visits": 2, "raw_string_bytes_sum": 100,
                  "scalar_format_bytes_max": 32}
    result = transfer(forest, entry, serializer, explanation_prefix_count=2)
    assert result["gshape_n_upper"] == 7
    assert result["hyp_map_bindings_upper"] == 10
    assert result["index_map_bindings_upper"] == 6
    assert result["bound_shape_text_bytes_upper"] == 35
    assert result["prover_id_bindings_upper_under_prefix_contract"] == 39
    assert result["prover_id_scalar_size_upper"] == 37
    assert result["prover_id_no_resize_guard"] is False
    assert transfer(forest, entry, {**serializer, "attempt_stat_visits": 1})["prover_id_no_resize_guard"] is True
    assert result["complete_save_capacity_established"] is False
    unready = transfer({**forest, "shape_output_input_ready": False}, entry)
    assert unready["shape_append_bytes"] is None
    assert unready["gshape_add_calls"] == 6
    bad_attributes = {**forest, "explanation": {**forest["explanation"],
                      "typed_attribute_closure_established": False}}
    assert transfer(bad_attributes, entry, explanation_prefix_count=2)["explanation_bytes_per_insertion"] is None
    exact = transfer(forest, {**entry, "gshape_n": MAX_INT - 6})
    overflow = transfer(forest, {**entry, "gshape_n": MAX_INT - 5})
    assert exact["guards"]["gshape_counter"] is True
    assert overflow["guards"]["gshape_counter"] is False
    overlong = transfer({**forest, "L": MAX_STRING})
    assert overlong["guards"]["shape_buffer_extent"] is False
    unknown = transfer(forest, remaining_callbacks=None)
    assert unknown["gshape_add_calls"] is None
    assert unknown["shape_append_bytes"] is None
    for bad in (-1, 3, True):
        try:
            transfer(forest, remaining_callbacks=bad)
        except ValueError:
            pass
        else:
            raise AssertionError("invalid callback input accepted")

    # Every prefix below is admissible for the weaker independent-field bounds.
    # It includes partial clears, one-sided insertion and a counter reset, but
    # deliberately does not assert artifact fidelity or model native polling.
    hyp, index, n = {"old": 4}, {4: "old"}, 5
    snapshots = []
    operations = ["clear_h", "put_h", "clear_i", "clear_n", "put_i", "inc"]
    for operation in operations:
        if operation == "clear_h": hyp = {}
        elif operation == "clear_i": index = {}
        elif operation == "clear_n": n = 0
        elif operation == "put_h": hyp = {**hyp, "new": n}
        elif operation == "put_i": index = {**index, n: "new"}
        elif operation == "inc": n += 1
        assert len(hyp) <= 2 and len(index) <= 2 and 0 <= n <= 6
        snapshots.append({"operation": operation, "hyp": dict(hyp),
                          "index": dict(index), "n": n})
    assert hyp["new"] != next(iter(index))

    output = {
        "status": "pass", "platform": platform.platform(),
        "source_ranges": len(witnesses), "input_identities": len(inputs["files"]),
        "boundary_checks": ["unknown entry is not zero", "unknown signal budget",
                            "non-ready shape output", "incomplete typed attribute closure",
                            "invalid signal budget rejected", "partial independent map writes",
                            "signed stale-list index", "separate hash size and binding visits",
                            "no-resize pass/fail", "counter exact boundary/overflow",
                            "string overflow", "exact header and backup constants"],
        "default_unknown_entry_rows": rows,
        "selected_prefix_hypothesis_only_rows": conditional_prefix_rows,
        "partial_write_example": snapshots,
        "elapsed_seconds": time.monotonic() - started,
        "native_executions": 0, "capture_runs": 0, "solver_runs": 0,
        "predecessor_checker_replays": 0, "complete_save_capacity_established": False,
    }
    (HERE / "result.json").write_text(json.dumps(output, indent=2, sort_keys=True) + "\n")
    print(json.dumps({key: output[key] for key in ("status", "source_ranges", "input_identities", "elapsed_seconds", "complete_save_capacity_established")}, sort_keys=True))


if __name__ == "__main__":
    main()
