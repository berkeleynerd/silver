#!/usr/bin/env python3
"""Check retained bytes and their shared-source match without rerunning proofs."""
from pathlib import Path
import hashlib
import json

packet = Path(__file__).resolve().parent
root = packet.parents[2]
digest = lambda path: hashlib.sha256(path.read_bytes()).hexdigest()
for line in (packet / "SHA256SUMS").read_text().splitlines():
    expected, name = line.split("  ", 1)
    assert digest(packet / name) == expected, name

native = json.loads((packet / "native-proof-provenance.json").read_text())
lean = json.loads((packet / "lean-evidence.json").read_text())
assert native["complete"] and native["mode"] == "full"
assert lean["scope"] == "complete" and lean["axiom_audit"] == "passed"
assert not lean["clean_build"] and lean["kernel_recheck"] is None
counts = {}
for label, manifest in (("native", native), ("lean", lean)):
    shared = {name: value for name, value in manifest["inputs_sha256"].items()
              if not name.startswith(".")}
    for name, expected in shared.items():
        assert digest(root / name) == expected, (label, name)
    counts[label] = len(shared)

tests = json.loads((packet / "test-inputs.json").read_text())["shared_inputs_sha256"]
for name, expected in tests.items():
    assert digest(root / name) == expected, ("tests", name)
counts["tests"] = len(tests)

programs = json.loads((packet / "programs.json").read_text())["programs"]
for name, record in programs.items():
    directory = packet / "programs" / name
    assert digest(directory / "main.adb") == record["source_sha256"], name
    assert 'for Body ("Main") use "main.adb" at 1;' in (directory / "program.gpr").read_text()
    reports = directory / "obj/gnatprove"
    assert "in unit main~1," in (reports / "gnatprove.out").read_text(), name
    report = json.loads((reports / "main~1.spark").read_text())
    main = [entity for entity in report["entities"].values() if entity["name"].lower() == "main"]
    assert len(main) == 1 and all(Path(location["file"]).name == "main.adb"
                                  for location in main[0]["sloc"]), name
print(json.dumps({"shared_inputs_matched": counts, "native_regression_programs": len(programs),
                  "proofs_rerun": False}, indent=2))
