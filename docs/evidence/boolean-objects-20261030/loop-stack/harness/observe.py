"""Retain one bounded admission/compile/runtime observation without source changes."""
import hashlib
import json
import os
from pathlib import Path
import re
import subprocess
import sys
import time

binary, source, destination = map(Path, sys.argv[1:])
destination.mkdir(exist_ok=True)
cpus = sorted(os.sched_getaffinity(0))[:2]
cpu_list = ",".join(map(str, cpus))
shell = 'ulimit -s 8192 || exit; ulimit -s; exec "$@"'
record = {
    "binary": str(binary), "source": str(source), "bytes": source.stat().st_size,
    "binary_sha256": hashlib.sha256(binary.read_bytes()).hexdigest(),
    "source_sha256": hashlib.sha256(source.read_bytes()).hexdigest(),
    "stack_kib": 8192, "cpu_affinity": cpus, "shell_text": shell,
    "observations": [],
}


def observe(name, arguments):
    command = ["bash", "-c", shell, "silver-stack-observation",
               "taskset", "-c", cpu_list, *map(str, arguments)]
    started = time.monotonic()
    result = subprocess.run(command, stdout=subprocess.PIPE, stderr=subprocess.STDOUT)
    elapsed = time.monotonic() - started
    (destination / (name + ".log")).write_bytes(result.stdout)
    observation = {"name": name, "command": command, "returncode": result.returncode,
                   "elapsed_seconds": elapsed, "output_file": name + ".log"}
    record["observations"].append(observation)
    print(json.dumps(observation), flush=True)
    print(result.stdout.decode(errors="replace"), end="", flush=True)
    return result


admission = observe("check", [binary, "check", source])
if admission.returncode == 0:
    compilation = observe("compile", [binary, "compile", source])
    match = re.search(rb"^Executable: (.+)$", compilation.stdout, re.MULTILINE)
    if compilation.returncode == 0 and match:
        executable = Path(os.fsdecode(match.group(1)))
        record["executable"] = str(executable)
        record["workspace"] = str(executable.parent.parent)
        observe("execute", [executable])
(destination / "observation.json").write_text(json.dumps(record, indent=2) + "\n")
raise SystemExit(next((item["returncode"] if item["returncode"] > 0 else 128 - item["returncode"]
                       for item in record["observations"] if item["returncode"]), 0))
