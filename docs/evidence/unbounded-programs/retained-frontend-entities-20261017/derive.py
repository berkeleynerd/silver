#!/usr/bin/env python3
"""Retain pinned-source evidence for the Main entity derivation, without tools.

This validates source identity and extracts reviewed caller/guard ranges. It
does not infer reachability or mechanically prove the report's capacity bounds.
"""

import argparse
import hashlib
import json
from pathlib import Path

PIN = "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea"
RANGES = {
    "checks.adb": [(3509, 3538), (11491, 11508)],
    "einfo-utils.adb": [(354, 357)],
    "exp_ch4.adb": [(10162, 10258)],
    "exp_spark.adb": [(120, 213), (772, 881), (896, 946), (1008, 1023),
                      (1073, 1106), (1138, 1254)],
    "exp_util.adb": [(5864, 6012), (7221, 7243), (12619, 12723),
                     (12761, 12824), (13102, 13116), (14429, 14457)],
    "expander.adb": [(105, 127)],
    "gnat1drv.adb": [(511, 516)],
    "gen_il-gen-gen_entities.adb": [(305, 310), (1087, 1095)],
    "inline.adb": [(1950, 1993)],
    "itypes.adb": [(45, 85)],
    "par-ch4.adb": [(2561, 2660)],
    "sem_attr.adb": [(1571, 1618), (8724, 8745), (9717, 9748)],
    "sem_ch3.adb": [(4823, 4829), (5138, 5145), (5320, 5336),
                    (14339, 14477), (15317, 15498),
                    (19080, 19214), (20504, 20605), (20712, 20761), (22704, 22719),
                    (23008, 23038), (23110, 23133)],
    "sem_ch4.adb": [(1916, 1965), (2067, 2141)],
    "sem_ch5.adb": [(300, 365), (3259, 3265), (3295, 3402), (3434, 3438),
                    (3901, 3990), (4104, 4116), (4868, 4886)],
    "sem_ch6.adb": [(3738, 3768), (5442, 5500), (5565, 5623)],
    "sem_eval.adb": [(2342, 2443), (2454, 2534), (5118, 5144), (5293, 5308)],
    "sem_res.adb": [(2545, 2551), (4861, 4879), (9360, 9368),
                    (9732, 9745), (10570, 10619), (10767, 10832),
                    (11875, 11929), (12039, 12120), (13145, 13170),
                    (13205, 13337)],
    "sem_util.adb": [(10380, 10408)],
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, required=True,
                        help="Pinned gcc/ada source directory")
    parser.add_argument("--output", type=Path, default=Path(__file__).parent)
    args = parser.parse_args()
    repo = Path(__file__).resolve().parents[4]
    prior = repo / ("docs/evidence/unbounded-programs/continuation-20261017/"
                    "frontend-lifetimes/complete-source-manifest.json")
    manifest = json.loads(prior.read_text())
    assert manifest["commit"] == PIN
    expected = {item["path"]: item for item in manifest["files"]}
    records = []
    excerpts = ["# Frozen frontend source excerpts\n",
                f"GCC `{PIN}`. LF line numbering; full files hash-verified "
                "against the retained complete source manifest.\n"]
    for name, ranges in RANGES.items():
        data = (args.source / name).read_bytes()
        digest = hashlib.sha256(data).hexdigest()
        assert digest == expected[name]["sha256"], name
        assert len(data) == expected[name]["bytes"], name
        lines = data.decode().split("\n")
        records.append({"path": name, "bytes": len(data), "sha256": digest,
                        "ranges": ranges})
        for first, last in ranges:
            assert 1 <= first <= last <= len(lines)
            excerpts.append(f"\n## {name}:{first}–{last}\n\n```ada\n")
            excerpts.extend(f"{i:6d} {lines[i - 1]}".rstrip() + "\n"
                            for i in range(first, last + 1))
            excerpts.append("```\n")
    args.output.mkdir(parents=True, exist_ok=True)
    result = {
        "commit": PIN,
        "verified_against": str(prior.relative_to(repo)),
        "scope": "Source identity/excerpts; no compiler/prover run",
        "files": records,
        "formulas": {
            "parser_flatten_events": "P <= floor(A / 1000)",
            "literal_subtype_creations": "K_literal <= S + 3*A + 5*P",
            "main_entities": "E_Main <= 1 + D + R + 2*D_s + 5*F + K_literal",
            "semantic_literal_occurrences": "<= S + A + 3*P",
        },
        "unproved_by_this_script": [
            "Caller coverage and reachability",
            "Formula soundness",
            "Installed binary/source correspondence",
            "Complete process or whole-program capacity",
        ],
    }
    (args.output / "source-manifest.json").write_text(
        json.dumps(result, indent=2) + "\n")
    (args.output / "source-excerpts.md").write_text("".join(excerpts))
    print(f"Verified {len(records)} pinned source files; wrote excerpts and manifest")


if __name__ == "__main__":
    main()
