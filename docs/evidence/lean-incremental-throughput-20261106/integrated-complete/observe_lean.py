"""One-run CPU/RAM observation around the existing managed Lean runner."""
import json
import os
import resource
from pathlib import Path
import signal
import subprocess
import sys
import time
from datetime import datetime, timezone

name, *command = sys.argv[1:]
out = Path("tmp") / name
out.mkdir(exist_ok=False)
hz, page = os.sysconf("SC_CLK_TCK"), os.sysconf("SC_PAGE_SIZE")
started = time.monotonic()
usage_before = resource.getrusage(resource.RUSAGE_CHILDREN)
with (out / "console.log").open("wb") as log:
    child = subprocess.Popen(command, stdout=log, stderr=subprocess.STDOUT,
                             start_new_session=True)
    (out / "launch.json").write_text(json.dumps({
        "command": command, "cwd": str(Path.cwd()), "process_group": child.pid,
        "started_utc": datetime.now(timezone.utc).isoformat(),
        "purpose": "sample CPU/RAM; pause only this run below 4 GiB MemAvailable"
    }, indent=2) + "\n")
    print(json.dumps({"process_group": child.pid, "observation": str(out)}), flush=True)
    prior, previous = {}, time.monotonic()
    peak, minimum, paused = 0, 2**64, False
    with (out / "samples.jsonl").open("w", buffering=1) as samples:
        while child.poll() is None:
            rows = []
            now = time.monotonic()
            for stat in Path("/proc").glob("[0-9]*/stat"):
                try:
                    fields = stat.read_text().rsplit(")", 1)[1].split()
                    if int(fields[2]) != child.pid:
                        continue
                    pid = int(stat.parent.name)
                    ticks = int(fields[11]) + int(fields[12])
                    args = (stat.parent / "cmdline").read_bytes().decode(errors="replace").split("\0")
                    rows.append({"pid": pid, "state": fields[0],
                                 "module": next((Path(a).name for a in args if a.endswith(".lean")), None),
                                 "rss_bytes": int(fields[21]) * page,
                                 "cpu_cores": max(0, ticks - prior.get(pid, ticks)) / hz / max(.001, now - previous)})
                    prior[pid] = ticks
                except (OSError, ValueError, IndexError):
                    pass
            available = next(int(line.split()[1]) * 1024 for line in Path("/proc/meminfo").read_text().splitlines() if line.startswith("MemAvailable:"))
            rss = sum(row["rss_bytes"] for row in rows)
            peak, minimum = max(peak, rss), min(minimum, available)
            sample = {"utc": datetime.now(timezone.utc).isoformat(), "elapsed_seconds": now-started,
                      "rss_bytes": rss, "host_available_bytes": available,
                      "cpu_cores": sum(row["cpu_cores"] for row in rows), "processes": rows}
            if available < 4 * 1024**3 and not paused:
                os.killpg(child.pid, signal.SIGSTOP)
                paused = True
                sample["action"] = "paused run: MemAvailable below 4 GiB; agent intervention required"
                print(json.dumps(sample), flush=True)
            sample["paused_by_monitor"] = paused
            samples.write(json.dumps(sample) + "\n")
            previous = now
            time.sleep(5)
    result = {"returncode": child.wait(), "wall_seconds": time.monotonic()-started,
              "sampled_peak_summed_rss_bytes": peak, "sampled_min_available_bytes": minimum,
              "paused_by_monitor": paused,
              "limitation": "sampled summed RSS can count shared pages; this is not exact peak memory"}
    usage_after = resource.getrusage(resource.RUSAGE_CHILDREN)
    result["child_user_cpu_seconds"] = usage_after.ru_utime - usage_before.ru_utime
    result["child_system_cpu_seconds"] = usage_after.ru_stime - usage_before.ru_stime
    (out / "observation.json").write_text(json.dumps(result, indent=2)+"\n")
    print(json.dumps(result), flush=True)
sys.exit(child.returncode)
