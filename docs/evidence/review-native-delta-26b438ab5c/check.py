#!/usr/bin/env python3
"""Independent native delta inventory/arithmetic; not whole-tool closure."""
import argparse
import hashlib
import json
from pathlib import Path
import re

p = argparse.ArgumentParser()
p.add_argument("ada_source", type=Path)
p.add_argument("output", type=Path)
a = p.parse_args()
repo = Path(__file__).resolve().parents[3]
manifest = json.loads((repo / "docs/evidence/unbounded-programs/continuation-20261017/frontend-lifetimes/complete-source-manifest.json").read_text())
assert manifest["commit"] == "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea"
expected = {x["path"]: x for x in manifest["files"]}
names = ["sem_attr.adb", "exp_attr.adb", "sem_ch3.adb", "sem_ch4.adb",
         "sem_ch8.adb", "sem_res.adb", "sem_eval.adb", "sem_util.adb",
         "exp_ch3.adb", "exp_ch4.adb", "exp_util.adb", "checks.adb",
         "sem.ads", "nlists.adb", "sem.adb", "atree.adb"]
hashes = {}
for name in names:
    raw = (a.ada_source / name).read_bytes()
    digest = hashlib.sha256(raw).hexdigest()
    assert digest == expected[name]["sha256"], name
    assert hashlib.sha1(b"blob " + str(len(raw)).encode() + b"\0" + raw).hexdigest() == expected[name]["git_blob_sha1"], name
    hashes[name] = digest
sites = []
for i, line in enumerate((a.ada_source / "exp_ch4.adb").read_text().split("\n"), 1):
    if 2829 <= i <= 3638:
        m = re.search(r"Attribute_Name\s*=>\s*Name_(First|Last|Length)", line.split("--", 1)[0])
        if m:
            sites.append([i, m.group(1)])
assert sites == [[2864, "First"], [2989, "First"], [3000, "First"],
                 [3007, "Last"], [3045, "Length"], [3141, "First"]]
# 2864 is the excluded Character operand; 3141 requires a constrained root
# array, excluded by Standard_String. Source/control-flow review supplies
# these classifications, rather than the lexical inventory.
length_uint_constant = 60 + 2 + 1 + 1
assert length_uint_constant == 64
attribute_node_n = 2 + 4
attribute_node_constant = 2 * 2
attribute_growth_n = 1 + 2
assert (attribute_node_n, attribute_node_constant, attribute_growth_n) == (6, 4, 3)
ewa_direct_wrapper = 1 + 1 + 1  # EWA, relocation, possible saved original
ewa_flag_capture = 1 + 1 + 1 + 1 + 1
assert ewa_direct_wrapper + ewa_flag_capture == 8
result = {
    "target": "26b438ab5c",
    "previous_review_target": "cbcd679320",
    "upstream_commit": manifest["commit"],
    "source_sha256": hashes,
    "direct_attribute_lexical_sites": sites,
    "excluded_direct_attribute_sites": [2864, 3141],
    "Length_Uint_appends": "80*A+64",
    "initial_attribute_ordinary_nodes": "20*n*A+6*n+4",
    "initial_attribute_growing_events": "3*n+2",
    "range_check_copy_lists": "2*l",
    "same_Integer_conversion": {"ordinary_nodes": 2, "growing_events": 1},
    "Boolean_EWA": {"ordinary_nodes": 8, "entities_names": 2, "growing_events": 2,
                    "Uint_appends": 1, "live_scope_entries": 1, "extra_lists": 0},
    "submitted_output_sha256": "32397ecddd44e2d6e7d0a73194dbddc520bf6e873aebf8baaaec3758b72f629b",
    "limitation": "Manual shape-conditioned local transfers; no compiler/prover run, source-to-event derivation or exact installed-tool identity",
}
a.output.write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps({"sources_verified": len(hashes), "attribute_sites": len(sites), "whole_construct_closed": False}))
