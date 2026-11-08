"""Independent arithmetic expectations; does not compile or execute Silver."""

import hashlib
import json
import math
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "tmp"
LCM_PAIRS = [
    (12, 18), (-12, 18), (12, -18), (-12, -18), (0, 18), (12, 0),
    (0, 0), (-1000, 1000), (1000, 999), (-1000, -999), (1, 1000), (1000, 1),
]
COPRIME_PAIRS = [
    (21, 15), (17, 23), (36, 12), (18, 29), (60, 15), (0, 0), (0, 1),
    (1, 0), (-1, 1), (-1000, 999), (1000, 1000), (-1000, -999), (1000, 0),
]


def ada_image(value):
    return str(value) if value < 0 else " " + str(value)


def stdout_for(name, pairs, calculate):
    return "".join(
        f"{name}({ada_image(a)},{ada_image(b)}) = {calculate(a, b)}\n"
        for a, b in pairs
    )


common = [
    "main_procedure", "spark_mode_on", "runtime_context", "named_integer_subtype",
    "scalar_function", "scalar_function_call", "integer_array_object",
    "integer_array_read", "named_integer_variable", "integer_range_constraint",
    "integer_assignment", "scalar_guard_refinement", "for_loop",
    "integer_comparison", "integer_expression", "integer_image", "string_choice",
    "string_literal", "string_expression", "string_concatenation",
    "expression_output", "statement_sequence",
]
entries = [
    {
        "source": "rosetta_least_common_multiple.adb",
        "capabilities": common,
        "application_functions": ["GCD", "LCM"],
        "specification": "../language.md#small-nonrecursive-scalar-functions",
        "expected": {
            "stdout": stdout_for("lcm", LCM_PAIRS, math.lcm),
            "stderr": "", "exit_status": 0,
        },
    },
    {
        "source": "rosetta_coprimes.adb",
        "capabilities": common + [
            "named_boolean_variable", "boolean_assignment", "boolean_expression",
        ],
        "application_functions": ["GCD", "Coprime"],
        "specification": "../language.md#small-nonrecursive-scalar-functions",
        "expected": {
            "stdout": stdout_for(
                "coprime", COPRIME_PAIRS,
                lambda a, b: str(math.gcd(a, b) == 1).lower(),
            ),
            "stderr": "", "exit_status": 0,
        },
    },
]
(OUT / "manifest-entries.json").write_text(json.dumps(entries, indent=2) + "\n")

# Sign normalization reduces all 2001**2 signed pairs to this full magnitude
# square. Compare the bounded update and quotient with independent math.gcd/lcm.
maximum_steps = 0
maximum_steps_pair = None
checked = 0
for left in range(1001):
    for right in range(1001):
        a, b = left, right
        steps = 0
        for _ in range(20):
            if b > 0:
                a, b = b, a % b
                steps += 1
        assert b == 0, (left, right, a, b)
        expected_gcd = math.gcd(left, right)
        assert a == expected_gcd, (left, right, a, expected_gcd)
        result = (left * right) // a if a > 0 else 0
        assert result == math.lcm(left, right), (left, right, result)
        if steps > maximum_steps:
            maximum_steps, maximum_steps_pair = steps, [left, right]
        checked += 1

sources = {}
for entry in entries:
    path = ROOT / "samples" / entry["source"]
    source = path.read_bytes()
    # These sources use no character literals; discard strings and comments
    # before counting the language's shared arithmetic/concatenation operators.
    tokens = re.sub(r'"(?:""|[^"])*"|--[^\n]*', "", source.decode())
    operators = re.findall(r"\b(?:mod|rem)\b|[&+*/-]", tokens, re.IGNORECASE)
    sources[entry["source"]] = {
        "bytes": len(source), "sha256": hashlib.sha256(source).hexdigest(),
        "arithmetic_and_concatenation_operators": len(operators),
    }
summary = {
    "independent_oracles": ["Python math.gcd", "Python math.lcm"],
    "magnitude_pairs_checked": checked,
    "signed_pairs_covered_by_normalization": 2001 ** 2,
    "maximum_executed_euclidean_steps": maximum_steps,
    "first_maximum_steps_pair": maximum_steps_pair,
    "lcm_pairs": LCM_PAIRS,
    "coprime_pairs": COPRIME_PAIRS,
    "sources": sources,
    "scope": "Arithmetic calculation only; no native compile, proof, build or run",
}
(OUT / "independent-arithmetic.json").write_text(json.dumps(summary, indent=2) + "\n")
print(json.dumps(summary, indent=2))
