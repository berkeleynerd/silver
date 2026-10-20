#!/usr/bin/env python3
"""Offline identity/arithmetic check; does not prove the source control argument."""
import hashlib
import json
from pathlib import Path
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def identity(raw):
    return {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}


def main():
    start = time.monotonic()
    inputs = json.loads((HERE / "inputs.json").read_text())
    for path, expected in inputs["repository_files"].items():
        assert identity((ROOT / path).read_bytes()) == expected, path
    sources = {}
    for archive, members in inputs["archive_members"].items():
        with tarfile.open(ROOT / archive) as stream:
            for member, expected in members.items():
                raw = stream.extractfile(member).read()
                assert identity(raw) == expected, member
                sources[archive, member] = raw
    for witness in json.loads((HERE / "source-witnesses.json").read_text()):
        lines = sources[witness["archive"], witness["member"]].decode().splitlines()
        for part in witness["excerpts"]:
            assert "\n".join(lines[part["first_line"]-1:part["last_line"]])+"\n" == part["text"]
    goals = json.loads((ROOT / "docs/evidence/retained-producer-driver-envelope-20261018/result.json").read_text())
    server = json.loads((ROOT / "docs/evidence/retained-why-server-record-capacity-20261020/attachment.json").read_text())
    cases = []
    goal_map = {g["name"]: g for g in goals["cases"]}
    assert len(goal_map) == len(goals["cases"]) == len(server["cases"]) == 5
    assert set(goal_map) == {s["case"] for s in server["cases"]}
    for s in server["cases"]:
        g = goal_map[s["case"]]
        assert g["name"] == s["case"]
        n = g["registered_task_upper"]
        assert n == s["G"]
        run = 3*n
        interrupts = n * sum(range(3))
        assert interrupts == 3*n and run <= (1 << 62)-1
        raw_id = 20 + 8*run + 9*interrupts
        m = s["C_launch"] + 40 + raw_id
        assert m == s["C_launch"] + 60 + 51*n
        assert m+2 <= (1 << 31)-1
        cases.append({"case":g["name"], "G":n, "C_launch":s["C_launch"],
                      "run_offers_upper":run, "interrupt_offers_upper":interrupts,
                      "raw_run_ID_upper":raw_id,
                      "line_upper_if_C_is_launch_length":m,
                      "finished_allocation_upper_if_C_is_launch_length":m+2,
                      "pending_plus_read_upper_if_C_is_launch_length":m+1024,
                      "direct_InvalidAnswer_upper_if_C_is_launch_length":m+23})
    assert [x["line_upper_if_C_is_launch_length"] for x in cases] == [3396,2830,1772,287,216]
    # Check a concrete abandoned-prefix witness; this is not a target execution.
    offered = b"run;1" + b"interrupt" + b"run;2;0;0;solver;input.smt2\n"
    assert offered.split(b";")[1] == b"1interruptrun"
    result = {"scope":"prospective conditional source interface; not native coverage",
              "source_members":len(sources), "retained_inputs":len(inputs["repository_files"]),
              "cases":cases, "per_file_q":None, "weighted_O":None,
              "complete_parallel_capacity":False,
              "elapsed_seconds":time.monotonic()-start}
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
