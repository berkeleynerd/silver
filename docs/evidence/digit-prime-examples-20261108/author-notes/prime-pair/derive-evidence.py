#!/usr/bin/env python3
"""Independent expected outputs and cheap finite-domain mathematics for #344.

This runs no Silver/Ada application and writes only this worktree's tmp files.
The sieve and prime-power contribution table derive the expected results;
separate algorithm simulations check the source's bounded loops/guards.
"""
import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parent.parent
OUT = ROOT / "tmp"


def sieve(limit):
    flags = [True] * (limit + 1)
    flags[0] = flags[1] = False
    for prime in range(2, limit + 1):
        if flags[prime]:
            for multiple in range(prime * prime, limit + 1, prime):
                flags[multiple] = False
    return flags


flags = sieve(499)
decimal_sums = [sum(map(int, str(n))) for n in range(500)]
additive = [n for n in range(2, 500) if flags[n] and flags[decimal_sums[n]]]

# Omega(n) = sum over prime powers p**k dividing n of 1.
# Incrementing each prime-power's multiples differs from the sample's
# increasing candidate-factor repeated-division algorithm.
omega = [0] * 121
for prime in range(2, 121):
    if flags[prime]:
        power = prime
        while power <= 120:
            for multiple in range(power, 121, power):
                omega[multiple] += 1
            power *= prime
attractive = [n for n in range(1, 121) if flags[omega[n]]]


def trial_primality(n):
    result = False
    if n >= 2:
        result = True
        for divisor in range(2, n // 2 + 1):
            if n % divisor == 0:
                result = False
    return result


assert all(trial_primality(n) == flags[n] for n in range(500))
digit_guard_skips = 0
max_digit_sum = 0
max_before_digit_add = 0
for n in range(500):
    remaining, total = n, 0
    for _ in range(3):
        max_before_digit_add = max(max_before_digit_add, total)
        if total <= 18:
            total += remaining % 10
        else:
            digit_guard_skips += 1
        remaining //= 10
    assert remaining == 0
    assert total == decimal_sums[n]
    max_digit_sum = max(max_digit_sum, total)
assert digit_guard_skips == 0

count_guard_skips = 0
max_count = 0
max_same_factor_successes = 0
for n in range(1, 121):
    remaining, count = n, 0
    for factor in range(2, 121):
        factor_successes = 0
        for _ in range(7):
            if remaining > 1 and remaining % factor == 0:
                if count < 6:
                    remaining //= factor
                    count += 1
                    factor_successes += 1
                else:
                    count_guard_skips += 1
        max_same_factor_successes = max(max_same_factor_successes, factor_successes)
    assert remaining == 1
    assert count == omega[n]
    max_count = max(max_count, count)
assert count_guard_skips == 0

capabilities = [
    "main_procedure", "spark_mode_on", "runtime_context",
    "named_integer_subtype", "scalar_function", "scalar_function_call",
    "named_integer_variable", "integer_assignment", "named_boolean_variable",
    "boolean_assignment", "boolean_expression", "integer_expression",
    "integer_comparison", "scalar_guard_refinement", "for_loop",
    "integer_image", "expression_output", "string_choice", "statement_sequence",
]

records = []
budgets = {}
for source, functions, values in [
    ("rosetta_additive_primes.adb", ["Is_Prime", "Digit_Sum"], additive),
    ("rosetta_attractive_numbers.adb", ["Is_Prime", "Prime_Factor_Count"], attractive),
]:
    stdout = "".join(f" {n}\n" for n in values)
    (OUT / (source.removesuffix(".adb") + ".expected.stdout")).write_text(stdout)
    records.append({
        "source": source,
        "capabilities": capabilities,
        "application_functions": functions,
        "specification": "../language.md#small-nonrecursive-scalar-functions",
        "expected": {"stdout": stdout, "stderr": "", "exit_status": 0},
    })
    raw = (ROOT / "samples" / source).read_bytes()
    # Sources contain no quoted String/Character contents, and Image attributes
    # have no operator characters. Remove comments before counting lexical ops.
    body = re.sub(r"--[^\n]*", "", raw.decode())
    operators = re.findall(r"\b(?:mod|rem)\b|[&+*\-]|/(?![=])", body, re.I)
    budgets[source] = {
        "bytes": len(raw), "arithmetic_and_concat_operators": len(operators),
        "max_embedded_expression_operands": 3 if "additive" in source else 2,
        "sha256": hashlib.sha256(raw).hexdigest(),
    }

(OUT / "manifest-entries.json").write_text(json.dumps(records, indent=2) + "\n")
summary = {
    "method": "sieve primality and prime-power contribution Omega table; separate bounded algorithm models",
    "additive_values": additive, "additive_count": len(additive),
    "attractive_values": attractive, "attractive_count": len(attractive),
    "additive_controls": {str(n): {
        "prime": flags[n], "digit_sum": decimal_sums[n],
        "digit_sum_prime": flags[decimal_sums[n]],
        "additive": flags[n] and flags[decimal_sums[n]],
    } for n in [0, 1, 2, 13, 21, 499]},
    "primality_controls": {str(n): flags[n] for n in [0, 1, 2, 3, 4, 6, 119, 120, 499]},
    "factor_count_controls": {str(n): omega[n] for n in [1, 2, 4, 8, 16, 20, 32, 64, 97, 120]},
    "factor_qualification_controls": {str(n): flags[omega[n]] for n in [1, 2, 4, 8, 16, 20, 32, 64, 97, 120]},
    "full_primality_domain_checked": [0, 499],
    "full_digit_domain_checked": [0, 499],
    "full_factor_domain_checked": [1, 120],
    "digit_guard_skips": digit_guard_skips,
    "max_before_digit_add": max_before_digit_add,
    "max_digit_sum": max_digit_sum,
    "count_guard_skips": count_guard_skips,
    "max_factor_count": max_count,
    "max_same_factor_successes": max_same_factor_successes,
    "source_budgets": budgets,
    "ada_application_execution": False,
}
(OUT / "derivation-results.json").write_text(json.dumps(summary, indent=2) + "\n")
print(json.dumps(summary, indent=2))
