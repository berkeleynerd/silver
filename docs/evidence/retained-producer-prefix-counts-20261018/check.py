#!/usr/bin/env python3
"""Replay retained fixed-prefix semantic count operands; no native execution."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import struct

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
PRIOR = HERE.parent / "retained-producer-prefix-gc-20261018"
LIMIT = 2**62 - 1


def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    manifest = json.loads((HERE / "identity.json").read_bytes())
    for name, expected in manifest["dependencies"].items():
        assert identity((REPO / name).read_bytes()) == expected
    spec = importlib.util.spec_from_file_location("prefix_gc_check", PRIOR / "check.py")
    prior_check = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(prior_check)
    archives = {}
    for name, expected in manifest["archives"].items():
        assert identity((HERE / name).read_bytes()) == expected["archive"]
        contents = prior_check.read_archive(HERE / name)
        assert {n: identity(b) for n, b in contents.items()} == expected["members"]
        archives[name] = contents
    raw, source = archives["observations.tar.gz"], archives["sources.tar.gz"]
    old = prior_check.read_archive(PRIOR / "observations.tar.gz")
    old_sources = prior_check.read_archive(PRIOR / "sources.tar.gz")
    old_scan = json.loads(old_sources["why3/source-scan.json"])
    scan = json.loads(source["source-scan.json"])
    assert scan["files"] == old_scan["files"]
    assert scan["revision"] == manifest["why3_revision"]
    for name, data in source.items():
        if name in scan["files"]:
            assert identity(data) == scan["files"][name]
    get = lambda name: json.loads(raw[name])
    old_get = lambda name: json.loads(old["success/" + name])
    plan, old_plan = get("plan.json"), old_get("plan.json")
    assert plan["guards"] == old_plan["guards"] == list(prior_check.GUARDS)
    assert plan["protected_start"] == old_plan["protected_start"]
    assert plan["endpoint"] == old_plan["endpoint"]
    previous_root, root = manifest["prior_root"], manifest["capture_root"]
    assert [len(p) for p in Path(root).parts] == [len(p) for p in Path(previous_root).parts]
    renamed = {p.replace(root, previous_root): row for p, row in plan["file_identities"].items()}
    assert renamed == old_plan["file_identities"]
    assert len(plan["inputs"]) == len(old_plan["inputs"]) == 5
    executable = manifest["executable"]
    assert {k: executable[k] for k in ("bytes", "sha256")} == plan["file_identities"][executable["path"]]
    expected_sites = {
        "union_add": ("camlWhy3__Term__fun_13836", 25, "add", "rbx", "rdi", 0x576559),
        "substitution_multiply": ("camlWhy3__Term__fun_13856", 0, "multiply", "closure_rbx_field_2", "rax", 0x576810),
        "occurrence_add": ("camlWhy3__Term__fun_15307", 9, "add", "rax", "rdi", 0x57e319),
    }
    assert set(plan["arithmetic_sites"]) == set(manifest["sites"]) == set(expected_sites)
    for name, expected in expected_sites.items():
        site = plan["arithmetic_sites"][name]
        assert tuple(site[k] for k in ("symbol", "offset", "operation", "left", "right", "static_address")) == expected
        assert site == {k: v for k, v in manifest["sites"][name].items() if k != "first32"}
    runs = get("result.json")["cases"]
    assert len(runs) == 5
    rows = []
    for case, old_case, run in zip(plan["inputs"], old_plan["inputs"], runs):
        name = case["name"]
        assert name == old_case["name"] == run["name"]
        assert json.loads(json.dumps(case).replace(root, previous_root)) == old_case
        assert run["completed"] and run["returncode"] == 0 and not run["timed_out"]
        assert not run["failures"] and not run["guard_hits"]
        for filename in (case["argv"][-1], "why3.conf"):
            data = raw[name + "/" + filename]
            assert data == old["success/" + name + "/" + filename]
            assert identity(data) == plan["file_identities"][case["cwd"] + "/" + filename]
        process = get(name + "/capture/process.json")
        assert process["environment"] == case["environment"]
        assert process["argv"] == case["argv"] and process["initial_threads"] == 1
        summary = get(name + "/capture/summary.json")
        old_summary = old_get(name + "/capture/summary.json")
        assert summary["completed"] and summary["protected"]
        assert not summary["failures"] and not summary["guard_hits"] and not summary["new_threads"]
        assert set(summary["guards"]) == set(prior_check.GUARDS)
        for label, guard in summary["guards"].items():
            assert guard["first32"] == old_summary["guards"][label]["first32"]
        assert [r["guard"] for r in summary["startup_guard_hits"]] == [r["guard"] for r in old_summary["startup_guard_hits"]]
        assert len(summary["snapshots"]) == len(old_summary["snapshots"]) == 3
        start, end = summary["snapshots"][-2:]
        assert summary["baseline"] == start
        assert start["label"] == "before_first_why3_module" and end["label"] == "end_of_typing"
        for current, previous in zip(summary["snapshots"][-2:], old_summary["snapshots"][-2:]):
            assert current["native_r14"] == current["state_address"]
            for field in ("minor_allocated_words", "caml_allocated_words", "caml_gc_phase",
                          "caml_extra_heap_resources", "caml_dependent_size", "caml_dependent_allocated",
                          "caml_init_minor_heap_wsz", "caml_init_heap_wsz", "caml_custom_major_ratio"):
                assert current[field] == previous[field]
            state = current["state"]
            for field in prior_check.STATS + ("minor_heap_wsz", "in_minor_collection", "requested_major_slice",
                                            "requested_minor_gc", "extra_heap_resources_minor", "stat_heap_wsz"):
                assert state[field] == previous["state"][field]
            assert state["young_limit"] == state["young_trigger"] == state["young_alloc_start"]
            assert state["young_alloc_end"] - state["young_alloc_start"] == 8 * 2**28
            assert current["minor_allocated_words"] == (state["young_alloc_end"] - current["effective_young_ptr"]) // 8
            for label, table in current["tables"].items():
                assert table["used_entries"] == previous["tables"][label]["used_entries"]
                assert table["ptr"] < table["threshold"] == table["limit"]
        assert summary["mapped_files"] == old_summary["mapped_files"]
        assert set(summary["arithmetic"]) == set(expected_sites)
        arithmetic = {}
        for label, row in summary["arithmetic"].items():
            expected = manifest["sites"][label]
            assert row["first32"] == expected["first32"]
            assert row["operation"] == expected["operation"] and not row["violations"]
            data = raw[name + "/capture/" + label + ".operands"]
            assert identity(data) == row["trace"] and len(data) % 16 == 0
            pairs = list(struct.iter_unpack("<qq", data))
            assert pairs
            values = []
            for left, right in pairs:
                value = left * right if row["operation"] == "multiply" else left + right
                assert 0 <= left <= LIMIT and 0 <= right <= LIMIT and 0 <= value <= LIMIT
                values.append(value)
            computed = dict(hits=len(pairs), minimum_left=min(a for a, b in pairs),
                            minimum_right=min(b for a, b in pairs), maximum_left=max(a for a, b in pairs),
                            maximum_right=max(b for a, b in pairs), maximum_result=max(values))
            assert computed == {k: row[k] for k in computed}
            arithmetic[label] = computed
        rows.append(dict(name=name, arithmetic=arithmetic, allocation_snapshots_equal_prior=True,
                         debugger_seconds=run["duration_seconds"]))
    events = [json.loads(line) for line in raw["managed/events.jsonl"].splitlines()]
    assert events[-1]["event"] == "finished" and events[-1]["outcome"] == "success"
    result = dict(scope="three semantic free-variable count arithmetic sites in five fixed prefixes",
                  managed_run=manifest["run"], cases=rows,
                  total_arithmetic_operations=sum(r["hits"] for c in rows for r in c["arithmetic"].values()),
                  maximum_mathematical_result=max(r["maximum_result"] for c in rows for r in c["arithmetic"].values()),
                  debugger_seconds=sum(r["debugger_seconds"] for r in rows),
                  signed_OCaml_limit=LIMIT,
                  semantic_free_variable_multiplicity_bound_established=True,
                  fixed_context_and_source_correspondence_required=True,
                  complete_prefix_capacity_established=False,
                  whole_pipeline_capacity_established=False)
    if args.output:
        args.output.write_text(json.dumps(result, indent=2) + "\n")
    else:
        assert result == json.loads((HERE / "result.json").read_bytes())
        print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
