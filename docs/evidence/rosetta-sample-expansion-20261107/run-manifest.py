#!/usr/bin/env python3
"""Run the unchanged manifest test against new samples and a retained installation.

Usage: python3 run-manifest.py DELIVERY_ROOT NATIVE_ROOT RESULT_JSON
The managed dev.py tool invocation records the actual inputs and workspace.
"""

import hashlib
import json
from pathlib import Path
import re
import sys
import time
import unittest


delivery, native, result_path = map(lambda p: Path(p).resolve(), sys.argv[1:])
sys.path.insert(0, str(native))
from tests import test_samples, test_silver
from scripts.proof_provenance import input_hashes

assert Path(test_samples.__file__).resolve() == native / "tests/test_samples.py"
assert Path(test_silver.__file__).resolve() == native / "tests/test_silver.py"
assert test_samples.ROOT == test_silver.ROOT == native
assert test_samples.HOST.root == native
assert test_samples.SILVER == native / ".silver/linux-x86_64/compiler/bin/silver"
assert test_samples.invoke is test_silver.invoke
for name in ("test_samples.py", "test_silver.py"):
    assert (native / "tests" / name).read_bytes() == (delivery / "tests" / name).read_bytes()

provenance_path = native / ".silver/linux-x86_64/compiler/obj/review-final/gnatprove/proof-provenance.json"
provenance = json.loads(provenance_path.read_text())
before = input_hashes(test_samples.HOST)
assert before == provenance["inputs_sha256"]
tools_before = {
    name: hashlib.sha256(Path(tool["path"]).read_bytes()).hexdigest()
    for name, tool in provenance["tools"].items()
}
assert all(tools_before[name] == tool["sha256"]
           for name, tool in provenance["tools"].items())

# Redirect only the fixture root. Compiler, installation, invocation cwd,
# source-identity checks, proof policy and report auditing remain the originals.
test_samples.ROOT = delivery
original_invoke = test_samples.invoke
commands = []


def observed_invoke(*arguments, **kwargs):
    started = time.monotonic()
    outcome = original_invoke(*arguments, **kwargs)
    row = {"arguments": [str(arg) for arg in arguments],
           "returncode": outcome.returncode,
           "seconds": time.monotonic() - started,
           "stdout": outcome.stdout}
    commands.append(row)
    print(f"{arguments[0]} {Path(arguments[1]).name}: "
          f"status {outcome.returncode}, {row['seconds']:.3f}s", flush=True)
    if arguments[0] == "compile" and outcome.returncode == 0:
        match = re.search(r"^Executable: (.+)$", outcome.stdout, re.MULTILINE)
        assert match and Path(match.group(1)).is_absolute(), outcome.stdout
    return outcome


test_samples.invoke = observed_invoke
suite = unittest.TestSuite([
    test_samples.SupportedSampleTests("test_manifest_samples"),
])
started = time.monotonic()
result = unittest.TextTestRunner(verbosity=2).run(suite)
after = input_hashes(test_samples.HOST)
tools_after = {
    name: hashlib.sha256(Path(tool["path"]).read_bytes()).hexdigest()
    for name, tool in provenance["tools"].items()
}
stable = before == after and tools_before == tools_after
manifest = json.loads((delivery / "samples/manifest.json").read_text())["samples"]
record = {
    "delivery_root": str(delivery), "native_root": str(native),
    "test": "tests.test_samples.SupportedSampleTests.test_manifest_samples",
    "tests_run": result.testsRun, "success": result.wasSuccessful() and stable,
    "seconds": time.monotonic() - started,
    "sample_count": len(manifest),
    "execution_cases": sum(1 + len(item.get("argument_cases", [])) for item in manifest),
    "native_input_count": len(before), "native_inputs_match_complete_provenance": True,
    "native_inputs_and_tools_stable": stable,
    "errors": [str(test) + "\n" + detail for test, detail in result.errors],
    "failures": [str(test) + "\n" + detail for test, detail in result.failures],
    "commands": commands,
}
result_path.parent.mkdir(parents=True, exist_ok=True)
result_path.write_text(json.dumps(record, indent=2) + "\n")
raise SystemExit(0 if record["success"] else 1)
