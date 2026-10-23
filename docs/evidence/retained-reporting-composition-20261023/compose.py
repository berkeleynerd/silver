"""New conditional reporting composition; never executes provider programs."""
import hashlib
import json
from pathlib import Path
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EV = HERE.parent


def read(path):
    return json.loads(path.read_text())


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def compose():
    inputs = read(HERE / "inputs.json")
    for path, expected in inputs["files"].items():
        assert identity((ROOT / path).read_bytes()) == expected, path
    canonical = read(EV / "retained-why-canonical-json-input-20261023/result.json")
    warnings = read(EV / "retained-why-diagnostic-warnings-20261023/bounds.json")
    terminal = read(EV / "retained-why-terminal-diagnostic-bytes-20261023/result.json")
    stderr = read(EV / "retained-why-printer-output-20261023/result.json")
    wrows = {r["case"]: r for r in warnings["cases"]}
    orows = {r["case"].replace("-", "_"): r for r in stderr["cases"]}
    assert canonical["global_escape_budget"] == warnings["shared_e"] == 2
    assert canonical["save_entering_callbacks"] == warnings["save_entering_callbacks"] == 2
    assert canonical["saves_upper"] == warnings["saves"] == 3
    assert canonical["conditional_on_future_proxy_adapter_refinement"]
    assert warnings["incompatible_answer_warnings_separate"]
    assert warnings["final_debug_copy_separate"] == {"D": 1, "H": 26619}
    assert terminal["actual_joined_exports"] is None
    example = terminal["configuration_range_example_only"]
    p, m = example["P"], example["M"]
    k = 467 + 12 * max(467, p+51, m+23, 256) + 256
    depth = terminal["wrapper_depth_upper"]
    assert isinstance(depth, int) and 0 <= depth <= 3
    y = sum(4**n for n in range(depth+1)) * (8*k+65536)
    x = 2 * (y+1024)
    assert example["K"] == k and example["X_abort_payload_sum"] == x
    assert example["Y_single_dispatch"] == y
    assert example["direct_terminal_stderr_bytes"] == 2*y+253
    rows = []
    for c in canonical["cases"]:
        w = wrows[c["case"]]
        assert c["E"] == w["E"]
        assert c["j12_pid"] == w["retained_J12_pid"]
        assert w["L_o"] == 422*w["W_o"]
        for driver in orows[c["case"]]["drivers"].values():
            fragment = driver["syntax_integer_diagnostic"]
            assert fragment["attempts_per_process_upper"] == c["E"]
            assert fragment["process_text_bytes_upper"] == 64*c["E"]
            assert fragment["process_core_events_upper"] == 8*c["E"]
            assert not fragment["fresh_stderr_reset_assumed"]
        # All three driver rows repeat the same one-process fragment.
        b0 = c["JSON_B"]["constant"] + 3*w["W_o"] + 6*w["L_o"] + 64*c["E"]
        e0 = c["JSON_E"]["constant"] + 3*w["W_o"] + 2*w["L_o"] + 8*c["E"]+2
        assert {k: v for k, v in c["JSON_B"].items() if k != "constant"} == {"W_o": 3, "L_o": 6, "X": 6}
        assert {k: v for k, v in c["JSON_E"].items() if k != "constant"} == {"W_o": 3, "L_o": 2, "X": 2}
        b, e = b0+6*x, e0+2*x
        length, inserts = b+e, 3*e+2
        total = 1000000010+length+1
        operands = {"sentinel": length+79,
                    "scan": (3*e+1)*total+length+79,
                    "counts": 4*inserts+2}
        guards = {"sentinel": operands["sentinel"] <= 1000000010,
                  "scan": operands["scan"] <= 2**62-1,
                  "counts": operands["counts"] <= 2**62-1}
        offered = b+70*(e+2)
        channels = offered+2*y+371
        old_x = 2*(85*(8*k+65536)+1024)
        old_sentinel = b0+e0+8*old_x+79
        rows.append({"case": c["case"], "j12_pid": c["j12_pid"],
                     "scheduling_Q": c["E"], "W_o": w["W_o"], "L_o": w["L_o"],
                     "B": {"constant": b0, "summed_abort_X": 6},
                     "E": {"constant": e0, "summed_abort_X": 2},
                     "orientation_only": {"P": p, "M": m, "X": x, "B": b, "E": e,
                         "L": length, "guard_operands": operands, "guards": guards,
                         "all_core_guards_fit": all(guards.values()),
                         "sentinel_margin": 1000000010-operands["sentinel"],
                         "standard_format_offered_bytes": offered,
                         "both_channels_offered_bytes": channels,
                         "zero_initial_offset_guard_fits": channels <= 2**63-1},
                     "actual_path_inputs_attached": False,
                     "prior_d3_orientation_at_same_warning_bound": {
                         "X": old_x, "sentinel_operand": old_sentinel,
                         "sentinel_guard_fits": old_sentinel <= 1000000010,
                         "actual_overflow_claim": False},
                     "actual_standard_core_guards": None,
                     "actual_channel_offset_guards": None})
    assert len(rows) == 5 and len(wrows) == len(orows) == 5
    return {"status": "pass", "scope": "conditional selected standard-root composition",
            "cases": rows, "provider_files": len(inputs["files"]),
            "current_J12_inputs": True, "stderr_fragment_copies_per_process": 1,
            "exit_flush_events_total": 2, "global_escape_budget": 2,
            "save_entering_callbacks": 2, "saves_upper": 3, "budget_renewed": False,
            "actual_path_inputs_attached": False, "actual_standard_core_guards": None,
            "complete_q_claim": False, "whole_process_capacity": False,
            "whole_capacity_rule_complete": False, "production_implemented": False,
            "aggregate_RAM_or_stack_gate": False, "native_runs": 0,
            "provider_program_replays": 0, "requires_independent_review": True}


if __name__ == "__main__":
    start = time.perf_counter()
    result = compose()
    result["elapsed_seconds"] = time.perf_counter()-start
    (HERE / "result.json").write_text(json.dumps(result, indent=2)+"\n")
    print(json.dumps({k: v for k, v in result.items() if k != "cases"}))
