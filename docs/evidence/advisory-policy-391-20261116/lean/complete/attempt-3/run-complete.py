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
    "--workers", "1", "--memory-mb", "8192", "--provenance", "--task", "#391",
    "--reason", "Serialized cached continuation on unchanged frozen d60bd8a899fcc66e5ef40112423b7f94b2e4becc. "
    "Actual previous two-worker attempt 20261116T233051-b2fd2290a41d overlapped "
    "ComposeContractSourceCandidate/ComposeDeclarationSourceCandidate setup; measured "
    "Lean7.136 GiB plus otherLean1.697 GiB plus Lake1.164 GiB crossed10 GiB aggregate "
    "RSS guard at88.186s, with host6.699 GiB. No proof diagnostic; all998 prior objects "
    "remain byte-identical. Parent authorized one worker with automatic12 threads and "
    "8192 MiB periodic per-process threshold, same10 GiB tree/1.5 GiB host guards. "
    "All1116 captured inputs matchGitHEAD and32 embedded sources remain unchanged. "
    "Retain prior attempts and add own-process argv/module sampling. No native/test "
    "overlap, source change, repeated focused success, clean build or replay.",
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
            command_lines = {}
            for pid in sorted(descendants):
                try:
                    command_lines[str(pid)] = [arg.decode(errors="replace") for arg in
                        (Path("/proc") / str(pid) / "cmdline").read_bytes().split(b"\0") if arg]
                except (FileNotFoundError, ProcessLookupError, PermissionError):
                    continue
            sample = {"argv": command_lines,
                      "elapsed_seconds": round(time.monotonic() - started, 3),
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
