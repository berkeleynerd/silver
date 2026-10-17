#!/usr/bin/env python3
"""Focused source/artifact and arithmetic review; does not execute Ada tools.

The four target evidence generators must already have been reproduced into
the supplied scratch directory. This checker compares those outputs, verifies
retained generator inputs/outputs, and supplies independent arithmetic cases.
Neither arithmetic cases nor source hashes establish caller coverage.
"""
import argparse
import hashlib
import itertools
import json
from pathlib import Path
import re


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


p = argparse.ArgumentParser(description=__doc__)
p.add_argument("--source", type=Path, required=True)
p.add_argument("--generated", type=Path, required=True)
p.add_argument("--scratch", type=Path, required=True)
p.add_argument("--output", type=Path, required=True)
a = p.parse_args()
repo = Path(__file__).resolve().parents[3]
base = repo / "docs/evidence/unbounded-programs"
manifest = json.loads((base / "continuation-20261017/frontend-lifetimes/"
                      "complete-source-manifest.json").read_text())
assert manifest["commit"] == "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea"
expected = {item["path"]: item for item in manifest["files"]}
reviewed = [
    "atree.adb", "atree.ads", "checks.adb", "exp_ch4.adb", "exp_util.adb",
    "expander.adb", "gen_il.ads", "gen_il-gen.adb", "gen_il-internals.ads",
    "hostparm.ads", "lib.adb", "namet.adb", "par-ch4.adb", "scng.adb",
    "sem_attr.adb", "sem_ch3.adb", "sem_eval.adb", "sem_res.adb",
    "sem_util.adb", "sinput.adb", "sinput-l.adb", "stringt.adb", "tbuild.adb",
    "types.ads", "uintp.adb", "uintp.ads", "validsw.ads",
]
source_hashes = {}
for name in reviewed:
    source_hashes[name] = digest(a.source / name)
    assert source_hashes[name] == expected[name]["sha256"], name

reproductions = []
for original, reproduced in [
    ("retained-value-capacity-20261017/components.json", "review-capacity-value.json"),
    ("retained-table-capacity-20261017/arithmetic-and-inventory.json",
     "review-capacity-table.json"),
    ("retained-native-expansion-20261017/local-envelope.json",
     "review-capacity-native.json"),
    ("retained-frontend-entities-20261017/source-manifest.json",
     "review-capacity-frontend/source-manifest.json"),
    ("retained-frontend-entities-20261017/source-excerpts.md",
     "review-capacity-frontend/source-excerpts.md"),
]:
    left, right = base / original, a.scratch / reproduced
    assert left.read_bytes() == right.read_bytes(), original
    reproductions.append({"file": original, "sha256": digest(left),
                          "reproduced_byte_identically": True})

layout = json.loads((base / "retained-table-capacity-20261017/node-layout.json").read_text())
for name, sha in layout["source_sha256"].items():
    assert digest(a.source / name) == sha == expected[name]["sha256"], name
for name, sha in layout["generated_sha256"].items():
    assert digest(a.generated / name) == sha, name
sizes = {}
for family, filename in [("node", "sinfo-nodes.ads"),
                         ("entity", "einfo-entities.ads")]:
    source = (a.generated / filename).read_text()
    table = source.split("Size : constant array", 1)[1].split(");", 1)[0]
    entries = {name: int(value) for name, value in
               re.findall(r"([NE]_\w+)\s*=>\s*(\d+)", table)}
    assert entries == layout["tables"][family]["size_by_kind"]
    sizes[family] = {"kinds": len(entries), "min": min(entries.values()),
                     "max": max(entries.values())}
assert sizes == {"node": {"kinds": 242, "min": 5, "max": 12},
                 "entity": {"kinds": 78, "min": 21, "max": 64}}
assert layout["header_slots"] == 3
node_sizes = layout["tables"]["node"]["size_by_kind"]
assert all(node_sizes[n] == 9 for n in ["N_Op_Add", "N_Op_Subtract", "N_Op_Multiply"])
assert node_sizes["N_Op_Minus"] == 8 and node_sizes["N_Integer_Literal"] == 6
assert (9 - 3) + (6 - 3) == 9

# Independent bounded/reversed-endpoint arithmetic. These cases corroborate
# the magnitude induction and its digit conversion, not query multiplicity.
range_cases = 0
for wl, wr in itertools.product([31, 32, 45, 60, 91], repeat=2):
    left = [-2**wl, -2**wl + 1, -1, 0, 1, 2**wl - 1, 2**wl]
    right = [-2**wr, -2**wr + 1, -1, 0, 1, 2**wr - 1, 2**wr]
    for ll, lh in itertools.product(left, repeat=2):
        for rl, rh in itertools.product(right, repeat=2):
            for w, values in [
                (max(wl, wr) + 1, (ll + rl, lh + rh)),
                (max(wl, wr) + 1, (ll - rh, lh - rl, -rl, -rh)),
                (wl + wr, (ll * rl, ll * rh, lh * rl, lh * rh)),
                (wr, (-rh, -rl)),
            ]:
                k = (w + 15) // 15
                assert max(abs(v) for v in values) <= 2**w
                assert all(max(1, (abs(v).bit_length() + 14) // 15) <= k
                           for v in values)
                range_cases += 1

# A disjoint computed range must not be silently replaced by Integer bounds.
lo, hi = 2**31, 2**31 + 2
int_lo, int_hi = -2**31, 2**31 - 1
assert lo > int_hi
assert (lo, hi) != (int_lo, int_hi)

# Compare 1-based scanner columns to independent 0-based indentation stops.
column_cases = 0
for n in range(11):
    for bits in itertools.product([False, True], repeat=n):
        c, offset = 1, 0
        for tab in bits:
            c = ((c - 1 + 8) // 8) * 8 + 1 if tab else c + 1
            offset = 8 * (offset // 8 + 1) if tab else offset + 1
        assert c == offset + 1
        column_cases += 1
assert 1 + 32765 == 32766 and 1 + 32766 > 32766
assert 4095 * 8 + 1 + 5 == 32766 and 4095 * 8 + 1 + 6 > 32766
line_capacities = [500]
while line_capacities[-1] * 2 * 32 <= 2**31 - 1:
    line_capacities.append(line_capacities[-1] * 2)
assert line_capacities[-1] == 65536000
assert line_capacities[-1] * 2 * 32 == 4194304000

# Independent emitter-region sum, including the closed aggregate leaf copies.
# Source reachability was reviewed manually; these are not sampled tool costs.
concat_cases = []
for n in [2, 3, 9, 10, 11, 1000, 2**20]:
    ordinary = sum([1, 4*n, 8, 5*n, 4*n+3, 3, 6, 2, 4, 12, 3, 12*n, 2, 1])
    entities = n + (n-1) + 1 + 1 + 3
    lists = 1 + 1 + n + 2 + 1 + 4 + 2 + 2*n
    copies = n + 2 + (n-1) + n + 2 + 2 + 1 + 2*n
    assert ordinary == 25*n + 45
    assert ordinary + (n+2) == 26*n + 47
    assert entities == 2*n + 4 and lists == 3*n + 11
    assert copies == 5*n + 6 and copies - (n+2) == 4*n + 4
    assert (3*n+2) + 2*(2*n+2) == 7*n+6
    assert (7*n+6) + 3*(2*n) == 13*n+6
    concat_cases.append({"operands": n, "ordinary_with_leaf_copies": 26*n+47,
                         "entities": entities, "lists": lists})

# Check the magnitude bound against all sign choices of the queried bounds.
concat_magnitude_cases = 0
for n, h in itertools.product([2, 9, 10, 1000], [1, 256, 2**31]):
    m = n * max(2*h + 1, 256) + h + 1
    for low, high in itertools.product([-h, 0, h], repeat=2):
        length = max(high-low+1, 0)
        for aggregate in [n*length, n*256]:
            assert all(abs(v) <= m for v in
                       [high-low, high-low+1, aggregate,
                        low+aggregate, low+aggregate-1])
            concat_magnitude_cases += 1

result = {
    "review_target": "63b0c9671f9322c03f961b6df410ba87330bc1e8",
    "source_commit": manifest["commit"],
    "host": "Linux x86_64",
    "source_sha256": source_hashes,
    "reproductions": reproductions,
    "layout": {"verified_inputs": len(layout["source_sha256"]),
               "verified_retained_outputs": len(layout["generated_sha256"]),
               "independently_parsed_sizes": sizes, "compiler_rerun": False},
    "arithmetic": {"endpoint_and_digit_cases": range_cases,
                   "column_recurrence_cases": column_cases,
                   "last_line_capacity": line_capacities[-1],
                   "concat_rows": concat_cases,
                   "concat_magnitude_cases": concat_magnitude_cases},
    "native_inventory_form_feeds": (a.source / "exp_ch4.adb").read_text().count("\f"),
    "scope": "Local components only; no compiler/prover/Lean/full-suite run",
    "whole_predicate_reviewed": False,
}
a.output.write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps({"source_files": len(source_hashes), "reproductions": len(reproductions),
                  "endpoint_cases": range_cases, "column_cases": column_cases,
                  "concat_magnitude_cases": concat_magnitude_cases}))
