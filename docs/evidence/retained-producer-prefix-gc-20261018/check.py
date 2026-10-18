#!/usr/bin/env python3
"""Check retained prefix observations; never launch the producer or a prover.

This checks the evidence arithmetic and identities, not the source argument in
the linked research record and not a whole-pipeline capacity theorem.
"""
import argparse
import hashlib
import json
import tarfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
CASES = ("put_line", "put", "first_or_default", "input_is_valid", "is_message")
STATS = ("stat_minor_words", "stat_promoted_words", "stat_major_words",
         "stat_minor_collections", "stat_major_collections", "stat_compactions",
         "stat_forced_major_collections")
GUARDS = ("caml_gc_dispatch", "caml_empty_minor_heap", "caml_major_collection_slice",
          "caml_finish_major_cycle", "caml_minor_collection", "caml_gc_minor",
          "caml_gc_major", "caml_gc_full_major", "caml_gc_major_slice",
          "caml_gc_compaction", "caml_gc_set", "caml_request_major_slice",
          "caml_request_minor_gc")


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def read_archive(path):
    with tarfile.open(path) as archive:
        members = archive.getmembers()
        assert all(m.isfile() for m in members)
        assert len({m.name for m in members}) == len(members)
        return {m.name: archive.extractfile(m).read() for m in members}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--prior-repo", type=Path, default=HERE.parents[2])
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    manifest = json.loads((HERE / "identity.json").read_text())
    archives = {}
    for name, expected in manifest["archives"].items():
        path = HERE / name
        assert identity(path.read_bytes()) == expected["archive"], name
        members = read_archive(path)
        assert {n: identity(b) for n, b in members.items()} == expected["members"], name
        archives[name] = members
    raw = archives["observations.tar.gz"]
    sources = archives["sources.tar.gz"]
    get = lambda name: json.loads(raw[name])
    plan = get("success/plan.json")
    assert plan["guards"] == list(GUARDS)
    assert plan["protected_start"] == "camlWhy3__Exn_printer__entry"
    assert plan["endpoint"] == {"symbol": "camlGnat_checks__init_1987", "address": 0x52ff00}
    assert tuple(c["name"] for c in plan["inputs"]) == CASES
    prior = read_archive(args.prior_repo / "docs/evidence/retained-producer-bodies-20261018/inputs-and-outputs.tar.gz")
    prior_inputs = {Path(n).name: b for n, b in prior.items() if n.endswith(".gnat-json")}
    native = get("success/result.json")["cases"]
    assert tuple(c["name"] for c in native) == CASES
    results = []
    for case, run in zip(plan["inputs"], native):
        name = case["name"]
        prefix = "success/" + name + "/"
        data = raw[prefix + case["argv"][-1]]
        assert identity(data) == case["input"]
        assert data == prior_inputs[case["argv"][-1]]
        for filename in (case["argv"][-1], "why3.conf"):
            assert identity(raw[prefix + filename]) == plan["file_identities"][case["cwd"] + "/" + filename]
        assert case["environment"]["OCAMLRUNPARAM"] == "s=256M,h=16M,M=1000"
        assert "R" not in case["environment"]["OCAMLRUNPARAM"]
        process = get(prefix + "capture/process.json")
        assert process["argv"] == case["argv"]
        assert process["environment"] == case["environment"]
        assert process["initial_threads"] == 1
        assert run["returncode"] == 0 and not run["timed_out"]
        assert run["completed"] and not run["failures"] and not run["guard_hits"]
        summary = get(prefix + "capture/summary.json")
        assert summary["completed"] and summary["protected"]
        assert not summary["failures"] and not summary["guard_hits"] and not summary["new_threads"]
        assert set(summary["guards"]) == set(GUARDS)
        assert all(len(bytes.fromhex(g["first32"])) == 32 for g in summary["guards"].values())
        start, end = summary["snapshots"][-2:]
        assert start["label"] == "before_first_why3_module" and end["label"] == "end_of_typing"
        assert summary["baseline"] == start
        assert [g["guard"] for g in summary["startup_guard_hits"]] == [
            "caml_minor_collection", "caml_gc_dispatch", "caml_empty_minor_heap", "caml_major_collection_slice"]
        assert "caml_make_vect" in summary["startup_guard_hits"][0]["backtrace"]
        assert "camlRe__Cset__entry" in summary["startup_guard_hits"][0]["backtrace"]
        for snap in (start, end):
            s = snap["state"]
            assert snap["native_r14"] == snap["state_address"]
            assert s["young_limit"] == s["young_trigger"] == s["young_alloc_start"]
            assert s["young_alloc_end"] - s["young_alloc_start"] == 8 * 2**28
            assert s["minor_heap_wsz"] == snap["caml_init_minor_heap_wsz"] == 2**28
            assert snap["caml_init_heap_wsz"] == s["stat_heap_wsz"] == 2**24
            assert snap["caml_custom_major_ratio"] == 1000
            assert snap["minor_allocated_words"] == (s["young_alloc_end"] - snap["effective_young_ptr"]) // 8
            assert 0 <= snap["minor_allocated_words"] < 2**28
            assert 0 <= snap["caml_allocated_words"] < 2**28
            assert snap["caml_gc_phase"] == 0
            assert all(s[n] == 0 for n in ("in_minor_collection", "requested_minor_gc", "requested_major_slice"))
            assert 0 <= s["extra_heap_resources_minor"] < 1
            assert 0 <= snap["caml_extra_heap_resources"] < 1
            assert snap["caml_dependent_size"] == snap["caml_dependent_allocated"] == 0
            for table in snap["tables"].values():
                assert table["used_entries"] == (table["ptr"] - table["base"]) // table["entry_size"]
                assert table["ptr"] < table["threshold"] == table["limit"]
                assert (table["threshold"] - table["base"]) // table["entry_size"] == 2**25
        assert all(start["state"][n] == end["state"][n] for n in STATS)
        assert start["state"]["stat_minor_collections"] == 1
        assert start["state"]["stat_major_collections"] == 0
        assert start["minor_allocated_words"] == 29354 and start["caml_allocated_words"] == 7671
        minor = end["minor_allocated_words"] - start["minor_allocated_words"]
        major = end["caml_allocated_words"] - start["caml_allocated_words"]
        assert 0 <= minor and 0 <= major and minor + major + 1 < 2**47 - 1
        mapped = summary["mapped_files"]
        for p, ident in mapped.items():
            if p in plan["file_identities"]:
                assert ident == plan["file_identities"][p]
        assert mapped[case["argv"][0]] == plan["file_identities"][case["argv"][0]]
        assert sorted(Path(p).name for p in mapped if p.endswith(".cmxs")) == ["ada_terms.cmxs", "gnat_json.cmxs"]
        results.append({"name": name, "minor_delta_words": minor, "major_delta_words": major,
                        "total_delta_words": minor + major, "minor_end_words": end["minor_allocated_words"],
                        "major_end_words": end["caml_allocated_words"],
                        "minor_custom_fraction": end["state"]["extra_heap_resources_minor"],
                        "major_custom_fraction": end["caml_extra_heap_resources"],
                        "table_entries": {n: t["used_entries"] for n, t in end["tables"].items()}})
    stopped = {}
    for name in ("process_entry", "missing_entity", "custom_resource"):
        summary = get("stopped/" + name + "/put_line/capture/summary.json")
        assert not summary["completed"]
        stopped[name] = {"completed": False, "guards": [g["guard"] for g in summary["guard_hits"]]}
    assert stopped["process_entry"]["guards"] == ["caml_minor_collection"]
    assert stopped["missing_entity"]["guards"] == []
    assert stopped["custom_resource"]["guards"] == ["caml_request_major_slice"]
    runtime = json.loads(sources["ocaml/identity.json"])
    assert runtime["revision"] == manifest["ocaml_source_revision"]
    for n, expected in runtime["files"].items():
        assert identity(sources["ocaml/" + n]) == expected
    version = get("success/installed-runtime-version.json")
    assert version["embedded_version"] == "4.14.2" and version["byte_offsets"]
    assert version["identity"] == plan["file_identities"][version["binary"]]
    outcomes = {}
    for n, data in raw.items():
        if n.startswith("managed/") and n.endswith("/events.jsonl"):
            events = [json.loads(line) for line in data.splitlines()]
            final = events[-1]
            assert final["event"] == "finished"
            outcomes[n.split("/")[1]] = final["outcome"]
    assert outcomes[manifest["run"]] == "success" and len(outcomes) == 5
    result = {"scope": "fixed five prefixes, selected allocation-charged counters only",
              "whole_pipeline_capacity_established": False,
              "managed_run": manifest["run"], "pinned_files": len(plan["file_identities"]),
              "cases": results, "stopped_attempts": stopped, "managed_outcomes": outcomes,
              "maximum_prefix_allocation_words": max(r["total_delta_words"] for r in results),
              "minimum_synthetic_line_limit": 2**47 - 1,
              "maximum_signed_ocaml_integer": 2**62 - 1}
    if args.output:
        args.output.write_text(json.dumps(result, indent=2) + "\n")
    else:
        assert result == json.loads((HERE / "result.json").read_text())
        print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
