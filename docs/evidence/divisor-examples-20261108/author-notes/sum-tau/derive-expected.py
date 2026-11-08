#!/usr/bin/env python3
"""Independent prime-factorization oracles for the two #343 samples."""

import hashlib
import json
from pathlib import Path


ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "tmp"


def factorization_values(n):
    """Use prime exponents, not a scan of all candidate divisors."""
    remainder = n
    sigma = 1
    tau = 1
    # Any composite remainder <= 100 has a prime factor <= sqrt(100).
    for prime in (2, 3, 5, 7):
        exponent = 0
        while remainder % prime == 0:
            remainder //= prime
            exponent += 1
        if exponent:
            sigma *= (prime ** (exponent + 1) - 1) // (prime - 1)
            tau *= exponent + 1
    if remainder > 1:
        sigma *= remainder + 1
        tau *= 2
    return sigma, tau


capabilities = [
    "main_procedure", "spark_mode_on", "runtime_context",
    "named_integer_subtype", "scalar_function", "scalar_function_call",
    "named_integer_variable", "integer_assignment", "scalar_guard_refinement",
    "for_loop", "integer_expression", "integer_comparison", "integer_image",
    "string_choice", "string_literal", "string_expression",
    "string_concatenation", "expression_output", "statement_sequence",
]

values = {n: factorization_values(n) for n in range(1, 101)}
max_sum_before = 0
max_count_before = 0
for n, (expected_sum, expected_count) in values.items():
    # This separate direct enumerator checks the implementation recurrence and
    # guards; it does not derive the expected output.
    total = 0
    count = 0
    for divisor in range(1, n + 1):
        max_sum_before = max(max_sum_before, total)
        max_count_before = max(max_count_before, count)
        assert total <= divisor * (divisor - 1) // 2 <= 4950
        assert count <= divisor - 1 <= 99
        if n % divisor == 0:
            assert total <= 4950
            assert count < 100
            total += divisor
            count += 1
            assert 0 <= total <= 5050
            assert 0 <= count <= 100
    assert (total, count) == (expected_sum, expected_count)

entries = []
for index, (source, helper, stem) in enumerate((
    ("rosetta_sum_of_divisors.adb", "Sum_Of_Divisors", "sum-of-divisors"),
    ("rosetta_tau_function.adb", "Tau", "tau-function"),
)):
    stdout = "".join(f" {n}: {values[n][index]}\n" for n in range(1, 101))
    (OUT / f"{stem}.expected.stdout").write_text(stdout, encoding="ascii")
    entries.append({
        "source": source,
        "capabilities": capabilities,
        "application_functions": [helper],
        "specification": "../language.md#small-nonrecursive-scalar-functions",
        "expected": {"stdout": stdout, "stderr": "", "exit_status": 0},
    })

(OUT / "manifest-entries.json").write_text(
    json.dumps(entries, indent=2) + "\n", encoding="ascii")
summary = {
    "domain": "every integer 1..100",
    "derivation": "prime factorization sigma product and tau product",
    "direct_recurrence_matches": 100,
    "guards_true_before_every_iteration": True,
    "maximum_observed_sum_before_iteration": max_sum_before,
    "maximum_observed_count_before_iteration": max_count_before,
    "maximum_sigma": max(value[0] for value in values.values()),
    "maximum_tau": max(value[1] for value in values.values()),
    "sources": {
        entry["source"]: {
            "bytes": len((ROOT / "samples" / entry["source"]).read_bytes()),
            "sha256": hashlib.sha256(
                (ROOT / "samples" / entry["source"]).read_bytes()).hexdigest(),
        }
        for entry in entries
    },
}
(OUT / "derivation-summary.json").write_text(
    json.dumps(summary, indent=2) + "\n", encoding="ascii")
print(json.dumps(summary, indent=2))
