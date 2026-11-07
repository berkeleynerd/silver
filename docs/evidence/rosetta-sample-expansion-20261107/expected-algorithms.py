#!/usr/bin/env python3
"""Derive the five algorithm-sample manifest entries independently.

This is delivery evidence, not a compiler test or source interpreter. List
concatenation, Python's sort and math.gcd supply independent reference results.
The coin result uses dynamic programming rather than the sample's enumeration.
Run from any directory; stdout is the JSON manifest fragment.
"""

import json
from math import gcd


def image(value):
    """Ada Integer'Image uses a leading blank only for nonnegative values."""
    return f" {value}" if value >= 0 else str(value)


def displayed(label, values):
    return label + "[" + ",".join(map(image, values)) + "]\n"


def entry(source, capabilities, section, stdout):
    return {
        "source": f"rosetta_{source}.adb",
        "capabilities": [
            "main_procedure", "spark_mode_on", "runtime_context",
            *capabilities,
        ],
        "specification": f"../language.md#{section}",
        "expected": {"stdout": stdout, "stderr": "", "exit_status": 0},
    }


first = [-3, 0, 5, 5]
second = [8, -1, 2]
unsorted = [-5, 0, 12, -5, 7, 100, -100, 12, 0, 3]
# math.gcd also uses the conventional extension gcd(0, 0) = 0.
pairs = [(48, 18), (0, 42), (42, 0), (0, 0), (-48, 18),
         (144, -233), (610, 987), (1000, 999)]

# Independent fixed-width table specification: 12 headings and 12 rows, each
# with a four-byte row-heading field and twelve four-byte product fields.
table = "    " + "".join(f"{column:4d}" for column in range(1, 13)) + "\n"
for row in range(1, 13):
    table += f"{row:4d}" + "".join(
        f"{row * column:4d}" if column >= row else "    "
        for column in range(1, 13)
    ) + "\n"
assert len(table.splitlines()) == 13
assert all(len(line) == 52 for line in table.splitlines())

# Each denomination extends the number of unordered combinations already
# formed from smaller denominations. No quarter/dime/nickel triples are used.
ways = [1] + [0] * 100
for coin in (1, 5, 10, 25):
    for amount in range(coin, 101):
        ways[amount] += ways[amount - coin]

samples = [
    entry(
        "array_concatenation",
        ["named_integer_subtype", "integer_array_object", "integer_array_read",
         "integer_array_assignment", "for_loop", "integer_comparison",
         "string_choice", "scalar_guard_refinement",
         "integer_expression", "integer_image", "expression_output",
         "literal_output", "string_literal", "statement_sequence"],
        "fixed-size-integer-arrays",
        displayed("First:", first) + displayed("Second:", second)
        + displayed("Combined:", first + second),
    ),
    entry(
        "bubble_sort",
        ["named_integer_subtype", "integer_array_object", "integer_array_read",
         "integer_array_assignment", "named_integer_variable",
         "integer_assignment", "named_boolean_variable", "boolean_assignment",
         "boolean_expression", "boolean_predicate", "for_loop", "string_choice",
         "integer_comparison", "scalar_guard_refinement", "integer_expression", "integer_image",
         "expression_output", "literal_output", "string_literal",
         "statement_sequence"],
        "fixed-size-integer-arrays",
        displayed("Before:", unsorted) + displayed("After:", sorted(unsorted)),
    ),
    entry(
        "greatest_common_divisor",
        ["named_integer_subtype", "integer_array_object", "integer_array_read",
         "named_integer_variable", "integer_range_constraint",
         "integer_assignment", "scalar_guard_refinement", "for_loop",
         "integer_comparison", "integer_expression", "integer_image",
         "string_choice", "string_literal", "string_expression",
         "string_concatenation", "expression_output", "statement_sequence"],
        "integer-objects-expressions-and-comparisons",
        "".join(f"gcd({image(a)},{image(b)}) ={image(gcd(a, b))}\n"
                for a, b in pairs),
    ),
    entry(
        "multiplication_tables",
        ["named_integer_variable", "integer_range_constraint",
         "integer_assignment", "scalar_guard_refinement", "for_loop",
         "integer_comparison", "integer_expression", "integer_image",
         "string_choice", "string_literal", "expression_output",
         "literal_output", "statement_sequence"],
        "scoped-finite-for-loops", table,
    ),
    entry(
        "count_the_coins",
        ["named_integer_variable", "integer_range_constraint",
         "integer_assignment", "scalar_guard_refinement", "for_loop",
         "integer_comparison", "integer_expression", "integer_image",
         "boolean_predicate", "string_choice", "string_literal",
         "string_expression", "string_concatenation", "expression_output",
         "statement_sequence"],
        "integer-objects-expressions-and-comparisons",
        f"Ways to make 100 cents with 25, 10, 5 and 1:{image(ways[100])}\n",
    ),
]

# These are no-input programs. They neither initialize nor inspect arguments,
# so the normal manifest execution suffices; no argument_cases are claimed.
print(json.dumps({"samples": samples}, indent=2))
