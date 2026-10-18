#!/usr/bin/env python3
"""Check pinned source and reproduce Main node/query equations.

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
                   (3810, 3920), (3978, 4048), (4620, 4913), (5071, 5654),
                   (6112, 6127), (6283, 6455), (6595, 6620),
                   (8044, 8054), (8118, 8165), (10930, 11190)],
    "cstand.adb": [(1396, 1407)],
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
    "layout.adb": [(225, 664), (900, 933)],
    "sem.adb": [(107, 116), (634, 640)],
    "sem_attr.adb": [(8308, 8405), (9717, 9751), (9898, 9970), (13600, 13618)],
    "sem_ch3.adb": [(4820, 4855), (5138, 5184), (5436, 5453), (6340, 6390),
                    (14339, 14484), (15317, 15500), (19121, 19198),
                    (20478, 20761), (22588, 22734), (23676, 23707)],
    "sem_ch5.adb": [(1020, 1035), (3295, 3311), (3430, 3625),
                    (3962, 3979), (4050, 4117), (4523, 4595),
                    (4868, 4886)],
    "sem_ch6.adb": [(3738, 3764), (5440, 5623), (8934, 8946)],
    "sem_ch8.adb": [(4362, 4400), (7107, 7130), (7781, 7805)],
    "sem_ch10.adb": [(989, 1042)],
    "sem_ch11.adb": [(388, 465)],
    "sem_eval.adb": [(660, 682), (995, 1769), (1971, 2110), (2342, 2443), (2454, 2532),
                     (3425, 3840), (3914, 3998), (4178, 4343), (4351, 4451),
                     (4589, 4684), (5118, 5222), (5323, 5479), (6090, 6136),
                     (7085, 7158), (7354, 7496)],
    "sem_mech.adb": [(107, 128)],
    "sem_prag.adb": [(26242, 26325), (26500, 26512)],
    "sem_res.adb": [(1462, 1498), (2545, 2551), (4247, 4276), (4861, 4911),
                    (6285, 6448), (7337, 7345),
                    (11200, 11214),
                    (11260, 11291), (11668, 11698), (12337, 12476),
                    (12729, 12934)],
    "sem_elab.adb": [(3563, 3776), (3782, 3851), (4084, 4102),
                     (10196, 10208), (12226, 12248)],
    "sem_util.adb": [(8450, 8510), (10821, 10915), (23907, 24033)],
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
        # Compiler source references use LF line numbers; form feeds are not
        # line separators (str.splitlines would also split those).
        lines = data.decode().split('\n')
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
    arithmetic = Counter(O=1, O_loop=2, F=3, R=1, D_lit=3)
    scalar_checks = Counter(D=1, G=1, N_assign=1, H_len=1)
    range_compares = Counter(F=6, R=3, D_lit=3)
    range_queries = Counter({key: 2*value for key, value in arithmetic.items()})
    range_queries.update(scalar_checks)
    comparisons = Counter(O=2, U=2, D=2, G=2, H_len=3)
    comparisons.update(range_compares)
    comparisons.update({key: 2*value for key, value in scalar_checks.items()})
    query_syntactic = {}
    for name, equation in (("Q_R", range_queries), ("Q_C", comparisons)):
        equation = equation.copy()
        equation["F"] += 2*equation.pop("G")
        equation["D_s"] = equation.pop("D_lit")
        query_syntactic[name] = dict(sorted(equation.items()))
    assert query_syntactic["Q_R"] == dict(sorted(dict(
        O=2, O_loop=4, F=8, R=2, D_s=6, D=1, N_assign=1, H_len=1).items()))
    assert query_syntactic["Q_C"] == dict(sorted(dict(
        O=2, U=2, F=14, R=3, D_s=3, D=4, N_assign=2, H_len=5).items()))
    evaluator = Counter({key: 2*value for key, value in arithmetic.items()})
    evaluator.update(O=6, U=6, H_len=4)
    result = {
        "source_commit": PIN,
        "verified_against": str(prior.relative_to(repo)),
        "scope": "Pinned-source identity and node/query-equation arithmetic only",
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
            "T_ar_coefficients": dict(sorted(arithmetic.items())),
            "T_check_coefficients": dict(sorted(scalar_checks.items())),
            "Q_range_coefficients": dict(sorted(range_compares.items())),
            "Q_R_coefficients": dict(sorted(range_queries.items())),
            "Q_C_coefficients": dict(sorted(comparisons.items())),
            "query_syntactic_coefficients": query_syntactic,
            "A_q": "3*(A_Main+1)",
            "query_Uint_appends": "6*A_q*Q_R + (80*A_q+60)*Q_C",
            "query_digit_words": "k*(6*A_q*Q_R + (80*A_q+60)*Q_C)",
            "query_k": "ceil(((b+2)*A_q+2)/15), b=max(32, target_longest_integer_bits)",
            "query_max_local_digit_vector_words": "5*k+3",
            "discrete_size_calls": "<= 2*R+2*D_lit+F",
            "discrete_size_Uint_appends": "<= 95*(2*R+2*D_lit+F)",
            "U_eval_coefficients": dict(sorted(evaluator.items())),
            "evaluator_digit_words": "<= 3*U_eval",
            "query_scope": "Root counts exclude helper-internal recursion already paid by transfer",
        },
        "remaining": [
            "Literal/subtype and layout helpers beyond closed query, discrete-size and evaluator contributions",
            "Growing mutations, overload tables and auxiliary allocation",
            "Freeze-result lists and elaboration/scope auxiliary storage",
            "Complete table/growth, numeric, name and auxiliary-resource connection",
            "Fixed dependency contributions and source-to-installed-tool relation",
        ],
        "not_run": ["compiler", "GNATprove", "Lean", "full test suite"],
    }
    args.output.mkdir(parents=True, exist_ok=True)
    target = args.output / "result.json"
    target.write_text(json.dumps(result, indent=2) + "\n")
    print(f"Verified {len(records)} pinned files and Main node/query equation expansion")
    print(f"result.json sha256 {hashlib.sha256(target.read_bytes()).hexdigest()}")


if __name__ == "__main__":
    main()
