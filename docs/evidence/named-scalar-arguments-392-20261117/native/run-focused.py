"""Run complete helper contracts sequentially under the canonical proof policy."""

from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
import re
import resource
import subprocess
import sys
import time


ROOT = Path(__file__).resolve().parents[4]
EVIDENCE = Path(__file__).resolve().parent / os.environ.get("SILVER_NAMED_FOCUSED_PASS", "focused")
SOURCE = ROOT / os.environ.get("SILVER_NAMED_FOCUSED_SOURCE", "src/silver_output_profile.adb")
HELPERS = (
    "Mark_Formal",
    "Function_Formal_At", "Procedure_Formal_Model", "Procedure_Formal_At",
    "Function_Association", "Procedure_Association", "Function_Actuals_Tail_Model",
    "Actuals_Model", "Lemma_Function_Actuals_Advance", "Actuals_After", "Procedure_Actuals_Tail_Model",
    "Procedure_Actuals_Model", "Procedure_Actuals_After", "Procedure_Payloads_Free_Model",
    "Procedure_Payloads_Free", "Procedure_Update_Step", "Procedure_Updates_Tail_Model",
    "Procedure_Updates_Model", "Procedure_Updates", "Call_Model", "Read_Call",
    "Procedure_Call_Body", "Call_Assignment_Model", "Call_Assignment_Body", "Basic_Body",
)
if SOURCE.name == "silver_catalogue.adb":
    HELPERS = ("Export_Constructs", "Export")


def sample_tree(root_pid: int) -> tuple[int, int]:
    processes = {}
    for entry in Path("/proc").iterdir():
        if not entry.name.isdecimal():
            continue
        try:
            values = {}
            for line in (entry / "status").read_text().splitlines():
                if line.startswith(("PPid:", "VmRSS:")):
                    key, value = line.split(":", 1)
                    values[key] = int(value.split()[0])
            processes[int(entry.name)] = (values["PPid"], values.get("VmRSS", 0))
        except (OSError, KeyError, ValueError):
            pass
    descendants = {root_pid}
    while True:
        expanded = descendants | {pid for pid, (parent, _) in processes.items() if parent in descendants}
        if expanded == descendants:
            break
        descendants = expanded
    rss = sum(processes.get(pid, (0, 0))[1] for pid in descendants)
    available = next(int(line.split()[1]) for line in Path("/proc/meminfo").read_text().splitlines()
                     if line.startswith("MemAvailable:"))
    return rss, available


def main() -> int:
    soft, hard = resource.getrlimit(resource.RLIMIT_STACK)
    resource.setrlimit(resource.RLIMIT_STACK, (16 * 1024 * 1024, hard))
    original = SOURCE.read_bytes()
    source_hash = hashlib.sha256(original).hexdigest()
    source_lines = original.decode().splitlines()
    jobs = os.environ.get("SILVER_NAMED_FOCUSED_JOBS")
    allocation = (f"{jobs} workers to reserve host headroom for concurrent focused Lean on 16 GiB host"
                  if jobs else "automatic available workers")
    selected = sys.argv[1:] or HELPERS
    for helper in selected:
        if helper not in HELPERS:
            raise ValueError(f"unlisted complete helper: {helper}")
        if SOURCE.read_bytes() != original:
            raise RuntimeError("native source changed during focused batch")
        selector_source = SOURCE
        selector_lines = source_lines
        spec = SOURCE.with_suffix(".ads")
        pattern = r"\s*(?:function|procedure) " + re.escape(helper) + r"\b"
        if spec.exists() and any(re.match(pattern, text) for text in spec.read_text().splitlines()):
            selector_source = spec
            selector_lines = spec.read_text().splitlines()
        line = next(i for i, text in enumerate(selector_lines, 1) if re.match(pattern, text))
        folder = EVIDENCE / helper
        folder.mkdir(parents=True, exist_ok=False)
        command = [sys.executable, "scripts/dev.py", "tool", "--task", "#392", "--reason",
                   f"Whole {helper} contract and every selected obligation over full declared domains; "
                   "named scalar associations; canonical all/all level2 cvc5,z3,altergo 30-second policy; "
                   f"16 MiB stack; {allocation}; sequential focused batch, not complete validation",
                   *(["--jobs", jobs] if jobs else []),
                   "--", "gnatprove", "-P", "../../../silver.gpr", "--subdirs=explore/named-392",
                   "-U", "--mode=all", "--report=all", "--warnings=error", "--checks-as-errors=on",
                   "--level=2", "--prover=cvc5,z3,altergo", "--timeout=30",
                   f"--limit-subp={selector_source.name}:{line}", "-XSILVER_HOST=linux-aarch64"]
        metadata = {"helper": helper, "selector_file": str(selector_source.relative_to(ROOT)),
                    "selector_line": line, "source_file": str(SOURCE.relative_to(ROOT)), "source_sha256": source_hash,
                    "command": command, "cwd": str(ROOT), "stack_bytes": 16 * 1024 * 1024}
        (folder / "invocation.json").write_text(json.dumps(metadata, indent=2) + "\n")
        start = time.monotonic()
        print(json.dumps({"starting": helper, "line": line}), flush=True)
        peak_rss = 0
        min_available = None
        with (folder / "terminal.log").open("w") as terminal, (folder / "resources.jsonl").open("w") as samples:
            process = subprocess.Popen(command, cwd=ROOT, stdout=terminal, stderr=subprocess.STDOUT)
            while process.poll() is None:
                rss, available = sample_tree(process.pid)
                peak_rss = max(peak_rss, rss)
                min_available = available if min_available is None else min(min_available, available)
                samples.write(json.dumps({"elapsed_seconds": time.monotonic() - start,
                                          "tree_rss_kib": rss, "mem_available_kib": available}) + "\n")
                samples.flush()
                time.sleep(2)
            returncode = process.wait()
        text = (folder / "terminal.log").read_text()
        managed = re.search(r"Managed run: ([^ ]+) \(([^\n]+)\)", text)
        result = {**metadata, "returncode": returncode, "elapsed_seconds": time.monotonic() - start,
                  "peak_tree_rss_kib": peak_rss, "minimum_mem_available_kib": min_available,
                  "managed_run": managed.group(1) if managed else None,
                  "managed_directory": managed.group(2) if managed else None,
                  "source_unchanged": SOURCE.read_bytes() == original}
        (folder / "result.json").write_text(json.dumps(result, indent=2) + "\n")
        print(json.dumps({key: result[key] for key in ("helper", "returncode", "managed_run",
                                                       "peak_tree_rss_kib", "minimum_mem_available_kib")}), flush=True)
        if returncode or not result["source_unchanged"]:
            print(text[-12000:], flush=True)
            return returncode or 1
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
