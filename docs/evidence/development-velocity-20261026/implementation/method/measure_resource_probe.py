#!/usr/bin/env python3
"""Bounded scratch adaptation of the retained 20261012 measurement launcher."""
import argparse
import datetime
import hashlib
import json
import os
from pathlib import Path
import resource
import shutil
import signal
import subprocess
import time

p = argparse.ArgumentParser()
p.add_argument("case")
p.add_argument("--snapshot", required=True, type=Path)
p.add_argument("--target")
p.add_argument("--workers", required=True)
a = p.parse_args()
base = Path(__file__).resolve().parent
snap = a.snapshot.resolve()
out = base / a.case
out.mkdir(exist_ok=False)
workspace = snap / ".silver/linux-x86_64/proof"


def inventory():
    return {
        str(f.relative_to(workspace)): {
            "sha256": hashlib.sha256(f.read_bytes()).hexdigest(),
            "mtime_ns": f.stat().st_mtime_ns,
            "bytes": f.stat().st_size,
        }
        for f in sorted((workspace / ".lake/build").rglob("*"))
        if f.is_file()
    }


(out / "artifacts-before.json").write_text(json.dumps(inventory(), indent=2) + "\n")
command = ["python3", "scripts/check_lean.py", "--task", "#246", "--workers", a.workers,
           "--threads", "2", "--memory-mb", "24576", "--reason",
           "Focused exact-fact resource diagnostic after retained -M16384 failures; test only -M24576 with normal async; original caches preserved."]
if a.target:
    command.extend(["--target", a.target])
started = time.time()
mono = time.monotonic()
reason = None
peak = 0
min_available = None
ticks_per_second = os.sysconf("SC_CLK_TCK")
(out / "command.json").write_text(json.dumps({
    "command": command, "cwd": str(snap),
    "started_at": datetime.datetime.now(datetime.timezone.utc).isoformat(),
    "start_epoch": started, "sample_interval_seconds": 1,
    "cutoff_available_kib": 3 * 1024 * 1024,
    "clock_ticks_per_second": ticks_per_second,
    "scope": "focused exact-proposition memory diagnostic" if a.target else "complete incremental reconstruction build and fresh audit",
    "profile_is_timing_baseline": False,
    "launcher_origin": ".silver/linux-x86_64/lean-baseline-20261012T094603Z/measure.py",
}, indent=2) + "\n")
usage_before = resource.getrusage(resource.RUSAGE_CHILDREN)
with (out / "output.log").open("w") as log, (out / "rss.jsonl").open("w") as samples:
    proc = subprocess.Popen(command, cwd=snap, stdout=log, stderr=subprocess.STDOUT,
                            start_new_session=True)
    try:
        while proc.poll() is None:
            members = []
            for d in Path("/proc").iterdir():
                if not d.name.isdigit():
                    continue
                try:
                    if os.getpgid(int(d.name)) != proc.pid:
                        continue
                    status = dict(line.split(":", 1) for line in (d / "status").read_text().splitlines() if ":" in line)
                    stat = (d / "stat").read_text().rsplit(")", 1)[1].split()
                    rss = int(status.get("VmRSS", "0 kB").split()[0])
                    cmd = (d / "cmdline").read_bytes().replace(b"\0", b" ").decode(errors="replace")
                    members.append({"pid": int(d.name), "rss_kib": rss,
                                    "hwm_kib": int(status.get("VmHWM", "0 kB").split()[0]),
                                    "user_seconds": int(stat[11]) / ticks_per_second,
                                    "system_seconds": int(stat[12]) / ticks_per_second,
                                    "start_ticks": int(stat[19]), "cmd": cmd})
                except (OSError, ProcessLookupError, ValueError):
                    pass
            mem = dict(line.split(":", 1) for line in Path("/proc/meminfo").read_text().splitlines())
            available = int(mem["MemAvailable"].split()[0])
            total = sum(m["rss_kib"] for m in members)
            peak = max(peak, total)
            min_available = available if min_available is None else min(min_available, available)
            samples.write(json.dumps({"monotonic_ns": time.monotonic_ns(), "epoch_seconds": time.time(),
                                      "elapsed_seconds": time.monotonic() - mono, "rss_kib": total,
                                      "available_kib": available, "processes": members}) + "\n")
            samples.flush()
            if available < 3 * 1024 * 1024:
                reason = "host headroom below 3 GiB"
                os.killpg(proc.pid, signal.SIGTERM)
                time.sleep(2)
                try:
                    os.killpg(proc.pid, signal.SIGKILL)
                except ProcessLookupError:
                    pass
                break
            time.sleep(1)
        proc.wait(timeout=20)
    except BaseException:
        os.killpg(proc.pid, signal.SIGTERM)
        try:
            proc.wait(timeout=10)
        except subprocess.TimeoutExpired:
            os.killpg(proc.pid, signal.SIGKILL)
            proc.wait()
        raise
usage = resource.getrusage(resource.RUSAGE_CHILDREN)
result = {"child_user_seconds": usage.ru_utime - usage_before.ru_utime,
          "child_system_seconds": usage.ru_stime - usage_before.ru_stime,
          "maximum_child_rss_kib": usage.ru_maxrss, "exit_code": proc.returncode,
          "wall_seconds": time.monotonic() - mono, "started_epoch": started,
          "finished_epoch": time.time(), "sampled_peak_tree_rss_kib": peak,
          "minimum_available_kib": min_available, "cutoff_reason": reason}
(out / "result.json").write_text(json.dumps(result, indent=2) + "\n")
(out / "artifacts-after.json").write_text(json.dumps(inventory(), indent=2) + "\n")
for name in (["lean-focused-evidence.json", "lean-focused.log"] if a.target else ["lean-evidence.json", "lean-proof.log"]):
    source = snap / ".silver/linux-x86_64" / name
    if source.exists():
        shutil.copy2(source, out / name)
print(json.dumps(result), flush=True)
raise SystemExit(proc.returncode or (1 if reason else 0))
