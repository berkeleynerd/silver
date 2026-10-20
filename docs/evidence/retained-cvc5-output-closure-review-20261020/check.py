#!/usr/bin/env python3
"""Verify exact reviewed files and local links, without replaying other checks."""
import hashlib
import json
from pathlib import Path
import re
import subprocess
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def identity(raw):
    return {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}


def main():
    start = time.monotonic()
    inputs = json.loads((HERE / "inputs.json").read_text())
    for row in inputs["files"]:
        assert identity((ROOT / row["path"]).read_bytes()) == {
            key: row[key] for key in ("bytes", "sha256")
        }, row["path"]
    for row in inputs["historical_inputs"]:
        raw = subprocess.check_output(
            ["git", "show", row["commit"] + ":" + row["path"]], cwd=ROOT
        )
        assert identity(raw) == {
            key: row[key] for key in ("bytes", "sha256")
        }, (row["commit"], row["path"])
    checks = json.loads((HERE / "checks.json").read_text())
    assert len(checks) == 3
    assert all(row["exit_code"] == 0 for row in checks)
    link_count = 0
    for name in inputs["link_documents"]:
        path = ROOT / name
        for target in re.findall(r"\]\(([^)]+)\)", path.read_text()):
            if target.startswith(("https://", "http://", "#")):
                continue
            local = target.split("#", 1)[0]
            assert (path.parent / local).exists(), (name, target)
            link_count += 1
    print(json.dumps({
        "result": "pass",
        "frozen_files": len(inputs["files"]),
        "historical_inputs": len(inputs["historical_inputs"]),
        "reviewed_components": len(inputs["components"]),
        "new_component_checks_retained": len(checks),
        "local_links": link_count,
        "elapsed_seconds": time.monotonic() - start,
        "whole_capacity_rule_established": False,
        "complete_q_or_weighted_O_exported": False,
        "scope": "Frozen identities and local links; semantic review remains in the report.",
    }, indent=2))


if __name__ == "__main__":
    main()
