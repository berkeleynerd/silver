#!/usr/bin/env python3
"""Reconcile accepted R60 inputs/results without replaying their checkers."""
import ast
import hashlib
import json
from pathlib import Path
import re
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def read(name):
    return json.loads((ROOT / name).read_text())


def check():
    manifest = json.loads((HERE / "inputs.json").read_text())
    frozen = {}
    for component in manifest["components"].values():
        for name in component["paths"]:
            expected = subprocess.check_output(["git", "show", component["freeze"]+":"+name], cwd=ROOT)
            actual = (ROOT / name).read_bytes()
            assert actual == expected, name
            frozen[name] = identity(actual)
    inherited = {}
    shared_base = "docs/evidence/retained-why-shared-demand-20261020/"
    sm = read(shared_base+"inputs.json")
    for name, expected in sm["files"].items():
        actual = identity((ROOT / name).read_bytes())
        assert actual == expected, name
        inherited[name] = actual
    for name, expected in sm["local_data"].items():
        assert identity((ROOT/shared_base/name).read_bytes()) == expected, name
    review_base = "docs/evidence/retained-preparation-demand-review-20261023/"
    for name, author in [("split-probe-result.json", "split"), ("shared-audit-result.json", "shared")]:
        r = read(review_base+name)
        assert r["status"] == "pass"
        assert r["freeze"] == manifest["components"][author]["freeze"]
        for path, expected in r["exact_inputs"].items():
            assert identity((ROOT/path).read_bytes()) == expected, path
        assert r["native_runs"] == r["predecessor_replays"] == 0
    sr = read(shared_base+"result.json")
    assert sr["saved_component_reused"]["applications"] == 206
    assert not sr["actual_whole_process_headroom"] and not sr["whole_pipeline_capacity"]
    for row in sr["cases"]:
        assert row["known_and_supplied_operands_fit"]
        assert len(row["missing_residual_contracts"]) == 4
        assert not row["through_R58_complete_including_lookup"]
        assert not row["actual_whole_process_headroom"]
        assert not row["publication_count_is_constructor_count"]
    native = read("docs/evidence/retained-printer-entry-collision-review-20261020/native-byte-join.json")
    assert identity(Path(native["installed_binary"]).read_bytes()) == native["installed_identity"]
    old = read("docs/evidence/retained-literal-native-completion-20261019/inputs.json")
    for row in old["repository"]:
        assert identity((ROOT/row["path"]).read_bytes()) == {k:row[k] for k in ["bytes","sha256"]}
    links = 0
    parsed = []
    for name in frozen:
        p = ROOT/name
        if p.suffix == ".py":
            ast.parse(p.read_text(), filename=name); parsed.append(name)
        if p.suffix == ".md":
            for target in re.findall(r"\]\(([^)]+)\)", p.read_text()):
                if "://" in target or target.startswith("#"):
                    continue
                assert (p.parent/target.split("#")[0]).exists(), (name,target)
                links += 1
    return {"status":"pass", "frozen_files":frozen, "inherited_inputs":inherited,
            "native_source_pins_unchanged":len(old["repository"]),
            "installed_why_unchanged":True,"python_parses":parsed,"local_packet_links":links,
            "six_owner_known_component_operands_fit":True,"missing_residual_vectors_per_process":4,
            "split_interface_accepted":True,"partial_shared_interface_accepted":True,
            "printer_entry_packet_accepted":False,"whole_capacity_rule_complete":False,
            "component_checker_replays":0,"native_target_runs":0}


if __name__ == "__main__":
    start=time.perf_counter(); result=check()
    result["elapsed_seconds"]=time.perf_counter()-start
    print(json.dumps(result,indent=2,sort_keys=True))
