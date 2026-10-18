#!/usr/bin/env python3
"""Check pinned source and reproduce the partial Main structural equation.

No compiler/prover invocation. This does not prove semantic caller coverage,
the equations' soundness, or source-to-installed-tool correspondence.
"""

import argparse
import hashlib
import json
from collections import Counter
from pathlib import Path

PIN = "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea"
RANGES = {
    "atree.adb": [(1301, 1333), (2109, 2138), (2222, 2276)],
    "checks.adb": [(3509, 3534), (3978, 4048), (8044, 8054), (8118, 8165)],
    "exp_ch4.adb": [(10217, 10256)],
    "exp_spark.adb": [(120, 204), (772, 881), (896, 946), (1008, 1023),
                      (1138, 1254)],
    "exp_util.adb": [(5873, 6012), (10664, 10711), (12619, 12723),
                     (12761, 12824), (13102, 13111)],
    "expander.adb": [(105, 127)],
    "freeze.adb": [(4100, 4153), (4282, 4398), (4555, 4605), (6536, 6550),
                   (6803, 6810), (8265, 8283), (10223, 10355)],
    "sem_ch3.adb": [(5138, 5184), (5436, 5453), (14339, 14484),
                    (15317, 15492), (19121, 19198), (22588, 22734)],
    "sem_ch5.adb": [(3295, 3311), (3962, 3979), (4868, 4886)],
    "sem_eval.adb": [(995, 1067), (2454, 2532), (3425, 3510), (5118, 5222)],
    "sem_res.adb": [(1462, 1498), (2545, 2551), (11200, 11214),
                    (11260, 11268), (11668, 11698)],
    "sem_elab.adb": [(3563, 3776)],
    "sem_util.adb": [(10821, 10915)],
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, required=True)
    parser.add_argument("--output", type=Path, default=Path(__file__).parent)
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[3]
    prior = repo / ("docs/evidence/unbounded-programs/continuation-20261017/"
                    "frontend-lifetimes/complete-source-manifest.json")
    manifest = json.loads(prior.read_text())
    assert manifest["commit"] == PIN
    expected = {item["path"]: item for item in manifest["files"]}
    records = []
    for name, ranges in RANGES.items():
        data = (args.source / name).read_bytes()
        digest = hashlib.sha256(data).hexdigest()
        assert digest == expected[name]["sha256"], name
        assert len(data) == expected[name]["bytes"], name
        lines = data.decode().splitlines()
        for first, last in ranges:
            assert 1 <= first <= last <= len(lines), (name, first, last)
        records.append({"path": name, "bytes": len(data), "sha256": digest,
                        "cited_ranges": ranges})

    folds = Counter(O=1, P=1, O_loop=2, F=3, R=1, D_lit=3, U=2, H_len=2)
    direct = Counter(B_loop=4, F=28, R=2, D_lit=13, D_alias=4, G=5,
                     D_copy=2, U=3, H_len=4, V0=1)
    expanded = direct.copy()
    expanded.update({key: 2 * value for key, value in folds.items()})
    assert dict(expanded) == {
        "B_loop": 4, "F": 34, "R": 4, "D_lit": 19, "D_alias": 4,
        "G": 5, "D_copy": 2, "U": 7, "H_len": 8, "V0": 1,
        "O": 2, "P": 2, "O_loop": 4,
    }
    assert 7 + 3 + 1 + 2 == 13  # literal-range + subtype + Rewrite + Find_Type
    assert (1 + 5) - (1 + 2) == 3  # semantic loop entities beyond parser
    result = {
        "source_commit": PIN,
        "verified_against": str(prior.relative_to(repo)),
        "scope": "Pinned-source identity and partial-equation arithmetic only",
        "files": records,
        "equations": {
            "T_fold_coefficients": dict(sorted(folds.items())),
            "A_struct_direct_coefficients": dict(sorted(direct.items())),
            "A_struct_expanded_coefficients": dict(sorted(expanded.items())),
            "L_struct_coefficients": {"R": 1, "D_lit": 2, "D_alias": 1, "G": 1},
            "E_generated": "<= R + 2*D_s + 3*F + K_literal",
            "A_Main_decomposition":
                "<= A_parse + F + E_generated + A_struct + A_residual",
            "A_residual": "UNFINISHED; not a numeric coefficient or allowance",
        },
        "remaining": [
            "Complete semantic query counts, mutations and helper coverage",
            "Freeze/layout, marker placement and enclosing Main/context closure",
            "Complete table/growth, numeric, name and auxiliary-resource connection",
            "Fixed dependency contributions and source-to-installed-tool relation",
        ],
        "not_run": ["compiler", "GNATprove", "Lean", "full test suite"],
    }
    args.output.mkdir(parents=True, exist_ok=True)
    target = args.output / "result.json"
    target.write_text(json.dumps(result, indent=2) + "\n")
    print(f"Verified {len(records)} pinned files and partial equation expansion")
    print(f"result.json sha256 {hashlib.sha256(target.read_bytes()).hexdigest()}")


if __name__ == "__main__":
    main()
