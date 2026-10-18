#!/usr/bin/env python3
"""Check pinned source and reproduce the Main node-identity equation.

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
    "checks.adb": [(2234, 2286), (3044, 3080), (3155, 3503), (3509, 3534),
                   (3978, 4048), (8044, 8054), (8118, 8165)],
    "exp_ch4.adb": [(10217, 10256)],
    "exp_spark.adb": [(120, 204), (601, 766), (772, 881), (896, 946), (1008, 1023),
                      (1138, 1254)],
    "exp_util.adb": [(5873, 6012), (7984, 7997), (8143, 8191), (8290, 8417),
                     (10664, 10711), (12619, 12723),
                     (12761, 12824), (13102, 13111)],
    "expander.adb": [(105, 127)],
    "freeze.adb": [(750, 912), (2974, 2977), (3641, 4276), (4282, 4605),
                   (4748, 5094), (6536, 6550), (6803, 6810), (8265, 8283),
                   (10223, 10390), (10402, 10771)],
    "layout.adb": [(225, 664)],
    "sem.adb": [(107, 116), (634, 640)],
    "sem_attr.adb": [(8308, 8405), (9717, 9751), (9898, 9970)],
    "sem_ch3.adb": [(5138, 5184), (5436, 5453), (14339, 14484),
                    (15317, 15492), (19121, 19198), (22588, 22734)],
    "sem_ch5.adb": [(3295, 3311), (3962, 3979), (4050, 4117), (4523, 4595),
                    (4868, 4886)],
    "sem_ch6.adb": [(3738, 3764), (5440, 5623), (8934, 8946)],
    "sem_ch8.adb": [(4362, 4400), (7107, 7130), (7781, 7805)],
    "sem_ch10.adb": [(989, 1042)],
    "sem_ch11.adb": [(388, 465)],
    "sem_eval.adb": [(995, 1067), (2342, 2443), (2454, 2532), (3425, 3718),
                     (3914, 3998), (5118, 5222)],
    "sem_mech.adb": [(107, 128)],
    "sem_prag.adb": [(26242, 26325), (26500, 26512)],
    "sem_res.adb": [(1462, 1498), (2545, 2551), (4247, 4276), (7337, 7345),
                    (11200, 11214),
                    (11260, 11268), (11668, 11698)],
    "sem_elab.adb": [(3563, 3776), (3782, 3851), (4084, 4102),
                     (10196, 10208), (12226, 12248)],
    "sem_util.adb": [(10821, 10915), (23907, 24033)],
    "sem_warn.adb": [(3548, 3650)],
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

    folds = Counter(O=1, P=1, O_loop=2, F=3, R=1, D_lit=3, U=2, H_len=3)
    direct = Counter(B_loop=4, F=28, R=2, D_lit=13, D_alias=4, G=5,
                     D_copy=2, U=3, H_len=4, V0=1)
    expanded = direct.copy()
    expanded.update({key: 2 * value for key, value in folds.items()})
    assert dict(expanded) == {
        "B_loop": 4, "F": 34, "R": 4, "D_lit": 19, "D_alias": 4,
        "G": 5, "D_copy": 2, "U": 7, "H_len": 10, "V0": 1,
        "O": 2, "P": 2, "O_loop": 4,
    }
    assert 7 + 3 + 1 + 2 == 13  # literal-range + subtype + Rewrite + Find_Type
    assert (1 + 5) - (1 + 2) == 3  # semantic loop entities beyond parser
    generated_entities = Counter(R=1, D_s=2, F=3, K_literal=1)
    main_entities = Counter(one=1, D=1, R=1, D_s=2, F=5, K_literal=1)
    main = Counter(A_parse=1, F=1, C_lib=1, N_ref=1)
    main.update(generated_entities)
    main.update(expanded)
    main.update(main_entities)  # ordinary freeze nodes, not repeated entities
    simple = main.copy()
    simple["F"] += 2 * simple.pop("G")
    literal = simple.pop("D_lit")
    alias = simple.pop("D_alias")
    assert literal >= alias
    simple["D_s"] += literal + simple.pop("D_copy")
    k_literal = simple.pop("K_literal")
    simple.update(S=k_literal, A=3*k_literal, P=5*k_literal)
    assert dict(simple) == {
        "A_parse": 1, "F": 53, "C_lib": 1, "N_ref": 1, "R": 6,
        "D_s": 25, "B_loop": 4, "U": 7, "H_len": 10, "V0": 1,
        "O": 2, "P": 12, "O_loop": 4, "one": 1, "D": 1, "S": 2, "A": 6,
    }
    result = {
        "source_commit": PIN,
        "verified_against": str(prior.relative_to(repo)),
        "scope": "Pinned-source identity and node-identity-equation arithmetic only",
        "files": records,
        "equations": {
            "T_fold_coefficients": dict(sorted(folds.items())),
            "A_struct_direct_coefficients": dict(sorted(direct.items())),
            "A_struct_expanded_coefficients": dict(sorted(expanded.items())),
            "L_struct_coefficients": {"R": 1, "D_lit": 2, "D_alias": 1, "G": 1},
            "E_generated": "<= R + 2*D_s + 3*F + K_literal",
            "E_Main_coefficients": dict(sorted(main_entities.items())),
            "A_Main_decomposition":
                "<= A_parse + F + E_generated + A_struct + E_Main + C_lib + N_ref",
            "A_Main_expanded_coefficients": dict(sorted(main.items())),
            "A_Main_syntactic_coefficients": dict(sorted(simple.items())),
            "syntactic_substitutions": [
                "G <= 2*F", "D_lit+D_alias <= D_s", "D_copy <= D_s",
                "K_literal <= S+3*A+5*P",
            ],
            "query_and_shell_additional_syntax": 0,
            "syntax_zero_scope": "Manual grammar/type/phase caller argument in derivation",
        },
        "remaining": [
            "Complete semantic query invocation/Uint counts and growing mutations",
            "Freeze-result lists and elaboration/scope auxiliary storage",
            "Complete table/growth, numeric, name and auxiliary-resource connection",
            "Fixed dependency contributions and source-to-installed-tool relation",
        ],
        "not_run": ["compiler", "GNATprove", "Lean", "full test suite"],
    }
    args.output.mkdir(parents=True, exist_ok=True)
    target = args.output / "result.json"
    target.write_text(json.dumps(result, indent=2) + "\n")
    print(f"Verified {len(records)} pinned files and Main node equation expansion")
    print(f"result.json sha256 {hashlib.sha256(target.read_bytes()).hexdigest()}")


if __name__ == "__main__":
    main()
