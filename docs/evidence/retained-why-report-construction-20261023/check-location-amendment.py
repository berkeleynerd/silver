#!/usr/bin/env python3
"""Check only the changed FileTags-origin/located-copy input, offline."""
from pathlib import Path
import copy
import hashlib
import json
import subprocess
import time

START = time.monotonic()
OUT = Path(__file__).resolve().parent
ROOT = OUT.parents[2]
BASE = "41a3f42678ef7f6d2ba75ea5aa8741aed4174a43"
PACKET = str(OUT.relative_to(ROOT))


def frozen(commit, path):
    return subprocess.check_output(["git", "show", f"{commit}:{path}"], cwd=ROOT)


def ident(data):
    return {"bytes":len(data), "sha256":hashlib.sha256(data).hexdigest()}


provider = json.loads((OUT / "path-provider.json").read_bytes())
for path, expected in provider["files"].items():
    assert ident(frozen(provider["commit"], path)) == expected, path
assert provider["warning_filename_bytes_upper"] == 180
assert provider["warning_nonfilename_bytes_upper"] == 256
assert provider["located_warning_bytes_upper"] == 436 == 180+256
refinement = json.loads(frozen(provider["commit"], provider["warning_refinement_path"]))
assert refinement["filename_upper"] == 180 and refinement["entry_upper"] == 436
assert refinement["opportunity_counts_unchanged"]
assert not refinement["counter_or_table_persistence_theorem_added"]
old = json.loads(frozen(BASE, PACKET+"/bounds.json"))
by_case = {r["case"]:r for r in old["cases"]}
for row in refinement["cases"]:
    case = by_case[row["case"]]
    assert row["W_o"] == case["W"]-case["O"]-case["N"]-1
    assert row["L_o"] == 436*row["W_o"]
expected = copy.deepcopy(old)
for row in expected["private_default_margin"]:
    if row["owner"] == "located_warning":
        assert row["B"] == 422
        row["B"] = 436
        assert row["E"] == 32 and row["initial_buffer"] == row["buffer_capacity_upper"] == 512
        assert row["B"]+row["E"]+79 == 547 <= 1000000010
        assert row["B"] <= row["buffer_capacity_upper"]
for row in expected["string_layouts"]:
    if row["bytes"] == 422:
        row["bytes"] = 436
        row["payload_words"] = (436+8)//8
        row["header_and_payload_bytes"] = 8*(row["payload_words"]+1)
        assert row["payload_words"] == 55
        assert 0 <= 8*row["payload_words"]-1-436 <= 7
expected["located_warning_source"] = {
    "provider_commit":provider["commit"], "filename_bytes_upper":180,
    "nonfilename_bytes_upper":256, "total_bytes_upper":436,
    "FileTags_counter_and_storage_owners_closed":False,
}
assert json.loads((OUT / "bounds.json").read_bytes()) == expected
inputs = json.loads((OUT / "inputs.json").read_bytes())
prior_inputs = json.loads(frozen(BASE, PACKET+"/inputs.json"))
assert {k:v for k,v in inputs.items() if k != PACKET+"/path-provider.json"} == prior_inputs
assert inputs[PACKET+"/path-provider.json"] == ident((OUT / "path-provider.json").read_bytes())
generator = (OUT / "check.py").read_text()
assert '("located_warning",436,32,512,512)' in generator
assert '317,368,436,512' in generator
note = (ROOT / "docs/research/retained-why-report-construction.md").read_text()
assert "L_o<=436W_o" in note and "retained-why-report-path-inputs.md" in note
result = {
    "status":"pass", "baseline_author_commit":BASE,
    "path_provider_commit":provider["commit"], "located_warning_bytes_upper":436,
    "default_margin_guard_lhs":547, "buffer_capacity_upper":512,
    "source_inputs_and_other_bound_rows_unchanged":True,
    "provider_replay":False, "full_construction_check_replay":False,
    "native_runs":0, "model_runs":0, "source_fetches":0,
    "elapsed_seconds":time.monotonic()-START,
}
(OUT / "location-amendment-result.json").write_text(json.dumps(result,indent=2,sort_keys=True)+"\n")
print(json.dumps(result,sort_keys=True))
