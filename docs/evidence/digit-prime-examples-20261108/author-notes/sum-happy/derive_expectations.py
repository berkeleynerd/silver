#!/usr/bin/env python3
"""Cheap independent task oracles and bounded-algorithm cross-checks for #344.

This script neither invokes build/proof tooling nor modifies shared caches.
"""

import hashlib
import json
from pathlib import Path
import re

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "tmp"
MAXIMUM = 2_147_483_647
ALPHABET = "0123456789abcdefghijklmnopqrstuvwxyz"


def base_string(number, base):
    if base in (2, 10, 16):
        return format(number, {2: "b", 10: "d", 16: "x"}[base])
    if number == 0:
        return "0"
    characters = []
    while number:
        number, digit = divmod(number, base)
        characters.append(ALPHABET[digit])
    return "".join(reversed(characters))


def digit_sum_oracle(number, base):
    spelling = base_string(number, base)
    assert int(spelling, base) == number
    return sum(ALPHABET.index(character) for character in spelling)


def sum_digits_candidate(number, base):
    total = 0
    for _ in range(31):
        digit = number % base
        assert total <= 1050, (number, base, total)
        total += digit
        number //= base
    assert number == 0
    return total


def square_sum_oracle(number):
    return sum(int(character) ** 2 for character in str(number))


def happy_oracle(number):
    seen = set()
    path = []
    while number != 1 and number not in seen:
        seen.add(number)
        path.append(number)
        number = square_sum_oracle(number)
    return number == 1, path, number


def square_sum_candidate(number):
    total = 0
    for _ in range(3):
        digit = number % 10
        assert total <= 162
        total += digit * digit
        number //= 10
    assert number == 0
    return total


def source_metadata(name):
    data = (ROOT / "samples" / name).read_bytes()
    source = data.decode("ascii")
    stripped = re.sub(r'"(?:""|[^"\n])*"|--[^\n]*', "", source)
    operators = re.findall(r"\bmod\b|\brem\b|/=|[&+*/-]", stripped, re.I)
    operators = [operator for operator in operators if operator != "/="]
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest(),
            "operator_count": len(operators), "operators": operators}


sum_name = "rosetta_sum_digits_of_an_integer.adb"
happy_name = "rosetta_happy_numbers.adb"
sum_source = (ROOT / "samples" / sum_name).read_text()


def array_values(name):
    match = re.search(rf"\b{name}\s*:.*?:=\s*\((.*?)\);", sum_source,
                      flags=re.S)
    assert match is not None
    return [int(numeral.replace("_", "")) for numeral in match[1].split(",")]


inputs = array_values("Inputs")
bases = array_values("Bases")
assert len(inputs) == len(bases) == 17
cases = list(zip(inputs, bases))
assert cases[:4] == [(1, 10), (1234, 10), (254, 16), (3854, 16)]
sum_cases = [dict(number=number, base=base,
                  spelling=base_string(number, base),
                  result=digit_sum_oracle(number, base))
             for number, base in cases]
sum_stdout = "".join(f"sum_digits({case['number']: d},{case['base']: d}) ="
                     f"{case['result']: d}\n" for case in sum_cases)

sum_comparisons = 0
for base in range(2, 37):
    numbers = set(range(4097)) | set(range(MAXIMUM - 100, MAXIMUM + 1))
    power = 1
    while power <= MAXIMUM:
        numbers.update(number for number in (power - 1, power, power + 1)
                       if 0 <= number <= MAXIMUM)
        power *= base
    for number in numbers:
        assert sum_digits_candidate(number, base) == digit_sum_oracle(number, base)
        sum_comparisons += 1

square_images = [square_sum_candidate(number) for number in range(1000)]
assert square_images == [square_sum_oracle(number) for number in range(1000)]
assert max(square_images) == 243
happy_results = {}
for number in range(1000):
    current = number
    for _ in range(244):
        current = square_images[current]
    oracle, path, terminal = happy_oracle(number)
    assert (current == 1) == oracle, (number, current, path, terminal)
    happy_results[number] = oracle

first_eight = [number for number in range(1, 32) if happy_results[number]]
assert first_eight == [1, 7, 10, 13, 19, 23, 28, 31]
happy_stdout = "".join(f"{number: d}\n" for number in first_eight)
controls = {}
for number in (0, 2, 3, 4, 8, 20, 30, 42, 999):
    happy, path, terminal = happy_oracle(number)
    controls[str(number)] = dict(happy=happy, path=path, terminal=terminal)
assert not any(control["happy"] for control in controls.values())

common = ["main_procedure", "spark_mode_on", "runtime_context",
          "named_integer_subtype", "scalar_function", "scalar_function_call",
          "named_integer_variable", "integer_assignment", "integer_range_constraint",
          "scalar_guard_refinement", "for_loop", "integer_expression",
          "integer_comparison", "integer_image", "string_choice",
          "expression_output", "statement_sequence"]
manifest = [
    {"source": sum_name,
     "capabilities": common + ["integer_array_object", "integer_array_read",
                               "string_literal", "string_expression",
                               "string_concatenation"],
     "application_functions": ["Sum_Digits"],
     "specification": "../language.md#small-nonrecursive-scalar-functions",
     "expected": {"stdout": sum_stdout, "stderr": "", "exit_status": 0}},
    {"source": happy_name,
     "capabilities": common + ["named_boolean_variable", "boolean_assignment",
                               "boolean_expression"],
     "application_functions": ["Sum_Squared_Digits", "Is_Happy"],
     "specification": "../language.md#small-nonrecursive-scalar-functions",
     "expected": {"stdout": happy_stdout, "stderr": "", "exit_status": 0}},
]
(OUT / "manifest-entries.json").write_text(json.dumps(manifest, indent=2) + "\n")
(OUT / "sum-digits-expected.stdout").write_text(sum_stdout)
(OUT / "happy-numbers-expected.stdout").write_text(happy_stdout)
print(json.dumps({
    "sources": {name: source_metadata(name) for name in (sum_name, happy_name)},
    "sum_digits_cases": sum_cases,
    "sum_digits_candidate_comparisons": sum_comparisons,
    "sum_digits_comparison_domain": "All 0..4096, every valid base power +/-1, "
                                   "and 2147483547..2147483647, for every base 2..36",
    "square_sum_complete_domain_comparisons": 1000,
    "happy_complete_domain_comparisons": 1000,
    "happy_count_in_complete_domain": sum(happy_results.values()),
    "first_eight": first_eight,
    "unhappy_controls": controls,
}, indent=2))
