"""Focused execution of the three original-unit package samples (#416)."""
from pathlib import Path
import gzip
import hashlib
import json
import re
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[4]
sys.path.insert(0, str(ROOT))
from scripts.check_evidence import audit_reports
from tests.test_samples import SupportedSampleTests
from tests.test_silver import invoke

destination = Path(__file__).resolve().parent
manifest = json.loads((ROOT / "samples/manifest.json").read_text())
results = []
for sample in manifest["samples"]:
    if "application_package" not in sample:
        continue
    source = ROOT / "samples" / sample["source"]
    package = sample["application_package"]
    originals = {"main.adb": source}
    for field in ("specification", "body"):
        path = ROOT / "samples" / package[field]
        originals[path.name] = path
    original_bytes = {name: path.read_bytes() for name, path in originals.items()}
    admission = invoke("check", source)
    assert admission.returncode == 0, admission.stdout
    compilation = invoke("compile", source)
    assert compilation.returncode == 0, compilation.stdout
    executable = Path(re.search(r"^Executable: (.+)$", compilation.stdout, re.M).group(1))
    if not executable.is_absolute():
        executable = ROOT / executable
    workspace = executable.parent.parent
    for name, data in original_bytes.items():
        assert originals[name].read_bytes() == data
        assert (workspace / name).read_bytes() == data
    sarif, = workspace.rglob("gnatprove.sarif")
    SupportedSampleTests().assert_application_proof_policy(sarif, output=True, functions=True)
    metadata = {**package,
                "functions": tuple(package["functions"]),
                "procedures": {k: tuple(v) for k, v in package["procedures"].items()},
                "formals": {k: tuple(map(tuple, v)) for k, v in package["formals"].items()},
                "states": tuple(package["states"]),
                "writes": {k: tuple(v) for k, v in package["writes"].items()}}
    counts = audit_reports(sarif.parent,
                          {"main", package["name"].lower(), "silver_io", "silver_output_libc",
                           "silver_arguments", "silver_runtime"},
                          {"silver_output_libc", "silver_runtime"}, application_kind="assigned",
                          indexed_main=True, application_package=metadata, indexed_packages=True)
    execution = subprocess.run([str(executable)], capture_output=True, timeout=10)
    expected = sample["expected"]
    assert execution.returncode == expected["exit_status"]
    assert execution.stdout == expected["stdout"].encode(), execution.stdout
    assert execution.stderr == expected["stderr"].encode(), execution.stderr
    retained = destination / source.parent.name
    retained.mkdir(exist_ok=True)
    (retained / "compile.log").write_text(compilation.stdout)
    for name, data in original_bytes.items():
        (retained / name).write_bytes(data)
    for report in sarif.parent.iterdir():
        if report.suffix in {".spark", ".sarif"}:
            (retained / (report.name + ".gz")).write_bytes(gzip.compress(report.read_bytes(), mtime=0))
    result = {"source": sample["source"], "workspace": str(workspace), "audit": counts,
              "sha256": {name: hashlib.sha256(data).hexdigest() for name, data in original_bytes.items()},
              "stdout": execution.stdout.decode(), "exit_status": execution.returncode}
    results.append(result)
    (destination / "results.json").write_text(json.dumps(results, indent=2) + "\n")
    print(json.dumps(result), flush=True)
assert len(results) == 3
