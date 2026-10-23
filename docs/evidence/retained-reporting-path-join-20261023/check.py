"""New configuration-sensitive reporting join; execute no provider code."""
import hashlib
import json
from pathlib import Path
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EV = HERE.parent
PINF = 1000000010
INT = 2**62-1


def read(path):
    return json.loads(path.read_text())


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def core(b, e):
    length, inserts = b+e, 3*e+2
    operands = {"sentinel": length+79,
                "scan": (3*e+1)*(PINF+length+1)+length+79,
                "counts": 4*inserts+2}
    return {"operands": operands,
            "guards": {"sentinel": operands["sentinel"] <= PINF,
                       "scan": operands["scan"] <= INT,
                       "counts": operands["counts"] <= INT}}


def evaluate(fixed_path, b1, e1, r):
    assert isinstance(r, int) and r >= 0
    path, frame = max(fixed_path, r+24), r+72
    s = max(467, path+51, frame+23, 256)
    assert s == max(467, fixed_path+51, r+95)
    k = 723+12*s
    y = 21*(8*k+65536)
    x_each, x = y+1024, 2*(y+1024)
    assert x == 4032*s+2997488
    b, e = b1+6*x, e1+2*x
    standard, private = core(b, e), core(x_each, 2256)
    private["guards"]["buffer_double_and_string"] = 2*max(512, x_each) <= 2**57-9
    private["guards"]["rounded_string_payload"] = (2*max(512,x_each)+8)//8 <= 2**54-1
    offered = b+70*(e+2)+2*y+371
    channel_guard = offered <= 2**63-1
    return {"R": r, "P_diag": path, "M": frame, "S": s, "K": k,
            "Y": y, "x_abort": x_each, "X": x, "B": b, "E": e,
            "standard": standard, "terminal_private": private,
            "selected_stdout_stderr_offer": offered,
            "zero_initial_offset_guard": channel_guard,
            "sentinel_margin": PINF-standard["operands"]["sentinel"],
            "all_guards": all(standard["guards"].values()) and
                          all(private["guards"].values()) and channel_guard,
            "actual_configuration_instantiated": False}


def check():
    inputs = read(HERE / "inputs.json")
    for path, expected in inputs["files"].items():
        assert identity((ROOT / path).read_bytes()) == expected, path
    old = read(EV / "retained-reporting-composition-20261023/result.json")
    paths = read(EV / "retained-why-report-path-inputs-20261023/projection.json")
    warning = read(EV / "retained-why-report-path-inputs-20261023/warning-refinement.json")
    construction = read(EV / "retained-why-report-construction-20261023/bounds.json")
    terminal = read(EV / "retained-why-terminal-diagnostic-bytes-20261023/result.json")
    assert terminal["wrapper_depth_upper"] == 2
    assert terminal["configuration_range_example_only"]["principal_private_events_per_outer"] == 2256
    assert paths["all_FileTags_filename_upper"] == paths["alias_robust_warning_filename_upper"] == 180
    assert paths["alias_robust_warning_entry_upper"] == warning["entry_upper"] == 436
    assert warning["historical_entry_upper"] == 422 and warning["opportunity_counts_unchanged"]
    assert not warning["counter_or_table_persistence_theorem_added"]
    assert old["global_escape_budget"] == paths["global_e_upper"] == construction["shared_e"] == 2
    assert paths["save_entering_callbacks_upper"] == construction["save_entering_callbacks"] == 2
    assert paths["saves_upper"] == construction["saves"] == 3
    assert paths["actual_R"] is paths["P_stat_actual"] is None
    crows = {r["case"]: r for r in construction["cases"]}
    wrows = {r["case"]: r for r in warning["cases"]}
    location = next(r for r in construction["private_default_margin"] if r["owner"] == "located_warning")
    assert location["B"] == 436 and location["E"] == 32
    assert location["buffer_capacity_upper"] == 512 and location["default_margin_guard"]
    assert construction["Loc_margin_specialization"]["margin"] == 1000000000
    assert construction["Loc_margin_specialization"]["segment_input_bytes_upper"] == 1024
    rows = []
    for previous in old["cases"]:
        case = previous["case"]
        p, w, c = paths["domains"][case], wrows[case], crows[case]
        f = p["request_path_upper_F"]
        assert p["P_diag"] == {"maximum": [f, {"R": 1, "constant": 24}]}
        assert p["M"] == {"R": 1, "constant": 72}
        assert w["W_o"] == previous["W_o"]
        assert w["historical_L_o"] == previous["L_o"] == 422*w["W_o"]
        assert w["L_o"] == 436*w["W_o"]
        delta = w["L_o"]-previous["L_o"]
        assert delta == w["L_o_increase"] == 14*w["W_o"]
        assert c["representation_guards_pass"]
        assert c["W"] == w["W_o"]+c["O"]+c["N"]+1
        assert previous["B"]["summed_abort_X"] == 6 and previous["E"]["summed_abort_X"] == 2
        b1 = previous["B"]["constant"]+6*delta
        e1 = previous["E"]["constant"]+2*delta
        s_limit = (PINF-(b1+e1+79)-8*2997488)//(8*4032)
        assert max(467,f+51) <= s_limit
        r_limit = s_limit-95
        lower = evaluate(f,b1,e1,0)
        endpoint = evaluate(f,b1,e1,r_limit)
        beyond = evaluate(f,b1,e1,r_limit+1)
        example = evaluate(f,b1,e1,64)
        assert lower["all_guards"] and endpoint["all_guards"] and example["all_guards"]
        assert not beyond["standard"]["guards"]["sentinel"]
        rows.append({"case": case, "F": f, "W_o": w["W_o"], "L_o": w["L_o"],
                     "L_o_increase": delta, "b1": b1, "e1": e1,
                     "S_limit": s_limit, "R_limit": r_limit,
                     "lower_endpoint_arithmetic_only": lower,
                     "upper_endpoint_arithmetic_only": endpoint,
                     "next_R_sentinel_margin": beyond["sentinel_margin"],
                     "illustrative_R64_only": example,
                     "actual_R": None, "actual_runtime_guard_claim": None,
                     "noncore_representation_provider_attached": True})
    assert len(rows) == len(paths["domains"]) == len(crows) == 5
    return {"status": "pass", "cases": rows, "provider_files": len(inputs["files"]),
            "common_sufficient_R_envelope": min(r["R_limit"] for r in rows),
            "minimum_illustrative_R64_sentinel_margin": min(r["illustrative_R64_only"]["sentinel_margin"] for r in rows),
            "universal_interval_requires_source_and_monotonicity_argument": True,
            "derived_envelope_is_not_an_adopted_admission_cap": True,
            "actual_R": None, "actual_runtime_guard_claim": None,
            "raw_stat_path_storage_closed": False, "whole_process_capacity": False,
            "whole_capacity_rule_complete": False, "production_implemented": False,
            "global_escape_budget": 2, "save_entering_callbacks": 2, "saves_upper": 3,
            "budget_renewed": False, "aggregate_RAM_or_stack_gate": False,
            "native_runs": 0, "provider_program_replays": 0, "requires_independent_review": True}


if __name__ == "__main__":
    start = time.perf_counter()
    result = check()
    result["elapsed_seconds"] = time.perf_counter()-start
    (HERE / "result.json").write_text(json.dumps(result,indent=2)+"\n")
    print(json.dumps({k:v for k,v in result.items() if k != "cases"}))
