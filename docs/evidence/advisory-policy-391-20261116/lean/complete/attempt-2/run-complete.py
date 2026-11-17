"""Retain one complete cached run's original launcher and resource observations."""

import datetime
import json
import os
from pathlib import Path
import signal
import subprocess
import sys
import threading
import time


root = Path(__file__).resolve().parents[6]
packet = Path(__file__).resolve().parent
command = [
    sys.executable, "scripts/check_lean.py",
    "--workers", "2", "--memory-mb", "8192", "--provenance", "--task", "#391",
    "--reason", "Complete cached Lean checkpoint on frozen reviewed implementation "
    "d60bd8a899fcc66e5ef40112423b7f94b2e4becc after native full success and focused "
    "Boolean Domain success 20261116T231040-cddd7187b7b8. All1116 captured inputs "
    "match Git HEAD; all32 embedded authoritative source bytes remain unchanged. "
    "Retain all998 current primary objects. Actual previous12-worker aggregate RSS "
    "guard reached11.225 GiB on16 GiB host; focused2-worker peak was2.634 GiB. "
    "Select2 workers with automatic12 threads for remaining dense overlap; no native "
    "proof/test run competes. Retain8192 MiB periodic per-process threshold and "
    "10 GiB RSS-tree/1.5 GiB host MemAvailable monitoring guards, not hard OS caps. "
    "No repeated focused success, clean build or replay.",
]
started = time.monotonic()
process = subprocess.Popen(command, cwd=root, stdout=subprocess.PIPE,
                           stderr=subprocess.STDOUT, text=True,
                           start_new_session=True)
stop = threading.Event()
state = {
    "command": command, "cwd": str(root), "launcher_pid": os.getpid(),
    "runner_pid": process.pid, "runner_pgid": process.pid,
    "started_utc": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "sample_interval_seconds": 2, "tree_rss_guard_kib": 10 * 1024 * 1024,
    "host_available_guard_kib": int(1.5 * 1024 * 1024),
    "guard_trigger": None,
}


def observe():
    with (packet / "resources.jsonl").open("w") as output:
        while True:
            table = {}
            for directory in Path("/proc").iterdir():
                if not directory.name.isdigit():
                    continue
                try:
                    fields = dict(line.split(":", 1) for line in
                                  (directory / "status").read_text().splitlines()
                                  if ":" in line)
                    table[int(directory.name)] = (
                        int(fields["PPid"]),
                        int(fields.get("VmRSS", "0 kB").split()[0]),
                        fields["Name"].strip())
                except (FileNotFoundError, ProcessLookupError, PermissionError):
                    continue
            descendants = {process.pid}
            while True:
                expanded = descendants | {pid for pid, row in table.items()
                                           if row[0] in descendants}
                if expanded == descendants:
                    break
                descendants = expanded
            rss = sum(table[pid][1] for pid in descendants if pid in table)
            memory = dict(line.split(":", 1) for line in
                          Path("/proc/meminfo").read_text().splitlines())
            available = int(memory["MemAvailable"].split()[0])
            sample = {"elapsed_seconds": round(time.monotonic() - started, 3),
                      "tree_rss_kib": rss, "host_available_kib": available,
                      "processes": {str(pid): table[pid] for pid in sorted(descendants)
                                    if pid in table}}
            output.write(json.dumps(sample) + "\n")
            output.flush()
            if process.poll() is None and state["guard_trigger"] is None:
                if rss > state["tree_rss_guard_kib"]:
                    state["guard_trigger"] = "aggregate process-tree RSS exceeded 10 GiB"
                elif available < state["host_available_guard_kib"]:
                    state["guard_trigger"] = "host MemAvailable fell below 1.5 GiB"
                if state["guard_trigger"]:
                    os.killpg(process.pid, signal.SIGINT)
            if stop.wait(2):
                break


monitor = threading.Thread(target=observe)
monitor.start()
with (packet / "terminal.log").open("w") as terminal:
    for line in process.stdout:
        terminal.write(line)
        terminal.flush()
        print(line, end="", flush=True)
returncode = process.wait()
stop.set()
monitor.join()
state.update(returncode=returncode,
             finished_utc=datetime.datetime.now(datetime.timezone.utc).isoformat(),
             elapsed_seconds=round(time.monotonic() - started, 3))
(packet / "launcher.json").write_text(json.dumps(state, indent=2) + "\n")
print("Original complete runner terminal:", json.dumps(state), flush=True)
raise SystemExit(returncode if returncode >= 0 else 128 - returncode)
