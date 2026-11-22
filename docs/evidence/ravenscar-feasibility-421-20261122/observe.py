#!/usr/bin/env python3
"""Bounded external observation; SIGTERM at deadline is not task completion."""
import argparse
import json
import os
from pathlib import Path
import resource
import signal
import subprocess
import time

parser = argparse.ArgumentParser()
parser.add_argument("executable", type=Path)
parser.add_argument("output", type=Path)
parser.add_argument("--seconds", type=float, default=1.0)
args = parser.parse_args()
allowed = sorted(os.sched_getaffinity(0))

def prepare_child():
    os.sched_setaffinity(0, {allowed[0]})

record = {"executable": str(args.executable), "seconds_requested": args.seconds,
          "observer_affinity": allowed, "application_affinity_requested": [allowed[0]],
          "stack_limit_bytes": resource.getrlimit(resource.RLIMIT_STACK),
          "observation_kind": "finite external observation of persistent task; never normal completion",
          "samples": []}
start = time.monotonic()
process = subprocess.Popen([str(args.executable)], stdout=subprocess.PIPE,
                           stderr=subprocess.PIPE, start_new_session=True,
                           preexec_fn=prepare_child)
record["pid"] = process.pid
try:
    while time.monotonic() - start < args.seconds and process.poll() is None:
        time.sleep(0.05)
        sample = {"elapsed_seconds": time.monotonic()-start, "threads": []}
        task_root = Path("/proc") / str(process.pid) / "task"
        if task_root.exists():
            for thread in sorted(task_root.iterdir()):
                try:
                    stat = (thread/"stat").read_text()
                    status = (thread/"status").read_text()
                    sample["threads"].append({"tid": int(thread.name), "stat": stat,
                        "wchan": (thread/"wchan").read_text(),
                        "affinity": sorted(os.sched_getaffinity(int(thread.name))),
                        "status": status})
                except (FileNotFoundError, ProcessLookupError):
                    pass
        record["samples"].append(sample)
    record["alive_at_deadline"] = process.poll() is None
finally:
    if process.poll() is None:
        record["harness_signal"] = "SIGTERM"
        os.killpg(process.pid, signal.SIGTERM)
    try:
        stdout, stderr = process.communicate(timeout=2)
    except subprocess.TimeoutExpired:
        record["harness_signal"] = "SIGKILL after SIGTERM grace"
        os.killpg(process.pid, signal.SIGKILL)
        stdout, stderr = process.communicate()
record.update(returncode=process.returncode, elapsed_seconds=time.monotonic()-start,
              stdout=stdout.decode(errors="replace"), stderr=stderr.decode(errors="replace"))
args.output.write_text(json.dumps(record, indent=2)+"\n")
print(json.dumps({k:v for k,v in record.items() if k!="samples"}, indent=2))
print("thread counts:", sorted({len(s["threads"]) for s in record["samples"]}))
raise SystemExit(0 if record["alive_at_deadline"] and not stderr else 1)
