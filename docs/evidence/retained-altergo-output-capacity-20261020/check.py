#!/usr/bin/env python3
"""Offline identity and payload arithmetic; not a solver-output theorem."""
import hashlib
import json
from pathlib import Path
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def check():
    inputs = json.loads((HERE / "inputs.json").read_text())
    archive = HERE / "sources.tar.gz"
    assert identity(archive.read_bytes()) == inputs["retained_archive"]
    with tarfile.open(archive) as tar:
        sources = {m.name: tar.extractfile(m).read() for m in tar.getmembers()}
    assert set(sources) == {r["path"] for r in inputs["sources"]}
    for row in inputs["sources"]:
        assert identity(sources[row["path"]]) == {k: row[k] for k in ("bytes", "sha256")}
    for row in inputs["repository"]:
        assert identity((ROOT / row["path"]).read_bytes()) == {
            k: row[k] for k in ("bytes", "sha256")}, row["path"]
    excerpts = []
    for row in inputs["excerpts"]:
        lines = sources[row["path"]].decode().splitlines()
        excerpts.append(f'--- {row["path"]}:{row["first"]}-{row["last"]} ---\n')
        excerpts.extend(f"{i}: {lines[i-1]}".rstrip() + "\n"
            for i in range(row["first"], row["last"] + 1))
    assert "".join(excerpts) == (HERE / "excerpts.txt").read_text()
    constants = dict(location_fixed=len('File "", line , characters -:'),
        location_following_space=1,
        validity_status=max(map(len, ("Valid", "Invalid", "Inconsistent assumption",
            "I don't know", "Timeout", "Preprocessing"))),
        time_wrapper=len(" ()"), steps_wrapper=len(" ( steps)"),
        goal_wrapper=len(" (goal )"), smt_status=max(map(len, ("unsat", "sat", "unknown", ""))))
    fixed = sum(constants.values())
    assert fixed == 80
    endpoints = (-(1 << 62), (1 << 62)-1)
    d = max(len(str(v)) for v in endpoints)
    assert d == 20
    g = len("g_") + d
    assert g == 22 and 4*d + g + fixed == 182
    return dict(candidate_revision=inputs["download"]["revision"],
        source_files=len(sources), repository_inputs=len(inputs["repository"]),
        source_excerpts=len(inputs["excerpts"]), payload_constants=constants,
        status_data_payload_formula="F + G + 4D + T + 80",
        represented_signed_63_bit_D=d, represented_smt_goal_G=g,
        conditional_status_payload_formula="F + T + 182",
        includes_formatter_or_other_output=False, status_occurrences_upper=None,
        formatter_H=None, complete_solver_file_q=None, actual_O=None,
        native_source_correspondence_established=False,
        complete_output_family_inventory=False, global_budget_reset=False,
        new_solver_runs=0, issue_119_complete=False, issue_153_complete=False)


if __name__ == "__main__":
    start = time.monotonic()
    result = check()
    target = HERE / "result.json"
    if target.exists():
        assert result == json.loads(target.read_text())
    else:
        target.write_text(json.dumps(result, indent=2) + "\n")
    run = dict(status="pass", seconds=time.monotonic()-start,
        source_files=result["source_files"], source_excerpts=result["source_excerpts"],
        repository_inputs=result["repository_inputs"], new_solver_runs=0)
    run_path = HERE / "check-run.json"
    if not run_path.exists():
        run_path.write_text(json.dumps(run, indent=2) + "\n")
    print(json.dumps(run))
