#!/usr/bin/env python3
"""Derive five sample manifest entries without executing or reading Silver output.

Run from any directory and redirect stdout to the manifest fragment. Numeric
formatting follows Ada Integer'Image; every output line ends in LF. FizzBuzz is
derived by divisibility classes, parity by the low bit, factors by paired
divisors through the integer square root, and Gregorian years by calendar.isleap.
The argument boundary and empty-string predicates are modeled independently.
"""

import calendar
import json
from math import isqrt


def image(number):
    return f"{number: d}"


def expected(stdout="", status=0):
    return {"stdout": stdout, "stderr": "", "exit_status": status}


def entry(source, capabilities, section, stdout):
    return {
        "source": f"rosetta_{source}.adb",
        "capabilities": [
            "main_procedure", "spark_mode_on", "runtime_context",
            "statement_sequence", "string_literal", *capabilities,
        ],
        "specification": f"../language.md#{section}",
        "expected": expected(stdout),
    }


def factors(number):
    paired = {
        divisor
        for candidate in range(1, isqrt(number) + 1)
        if number % candidate == 0
        for divisor in (candidate, number // candidate)
    }
    return sorted(paired)


def empty_result(arguments):
    if len(arguments) > 1:
        return expected(status=1)
    value = arguments[0] if arguments else ""
    if len(value) > 4096 or any(not 32 <= ord(char) <= 126 for char in value):
        return expected(status=1)
    state = "empty" if not value else "not empty"
    return expected(
        "empty variable: empty\nnonempty variable: not empty\n"
        f"argument: {state}\n"
    )


def manifest():
    fizz_classes = {
        (True, True): "FizzBuzz", (True, False): "Fizz",
        (False, True): "Buzz",
    }
    fizzbuzz = "".join(
        fizz_classes.get((number % 3 == 0, number % 5 == 0), image(number)) + "\n"
        for number in range(1, 101)
    )
    parity = "".join(
        f"{image(number)}: {'odd' if number & 1 else 'even'}\n"
        for number in range(-3, 4)
    )
    divisor_table = "".join(
        f"{image(number)}:" + "".join(map(image, factors(number))) + "\n"
        for number in (1, 2, 6, 12, 13, 28, 36, 97, 100)
    )
    year_table = "".join(
        f"{image(year)}: {'leap' if calendar.isleap(year) else 'common'}\n"
        for year in (1600, 1700, 1800, 1900, 1996, 1999,
                     2000, 2004, 2100, 2200, 2300, 2400)
    )
    scalar = ["scalar_integer_literal", "integer_expression", "integer_comparison",
              "integer_image", "string_choice", "boolean_predicate"]
    output = ["string_expression", "string_concatenation",
              "expression_output", "concatenated_output"]
    fizz = entry("fizzbuzz", [*scalar, "for_loop", "literal_output",
                              "string_expression", "expression_output"],
                 "integer-objects-expressions-and-comparisons", fizzbuzz)
    even = entry("even_or_odd", [*scalar, "for_loop", *output],
                 "integer-objects-expressions-and-comparisons", parity)
    empty = entry("empty_string", [
        "argument_context", "argument_initialization", "named_string_constant",
        "named_string_variable", "string_assignment", "string_equality",
        "length_predicate", "integer_literal", "input_guard",
        "argument_rejection", "string_choice", "boolean_predicate", "literal_output",
    ], "predicates-and-conditional-statements", empty_result([])["stdout"])
    empty["argument_cases"] = [
        {"arguments": arguments, "expected": empty_result(arguments)}
        for arguments in ([""], ["Silver"], [" "], ["x" * 4096],
                          ["one", "two"], ["x" * 4097], ["\t"])
    ]
    divisor = entry("factors_of_an_integer", [
        *scalar, "named_integer_subtype", "integer_array_object",
        "integer_array_iteration", "for_loop", *output, "literal_output",
    ], "constant-integer-array-iteration", divisor_table)
    leap = entry("leap_year", [
        *scalar, "named_integer_subtype", "integer_array_object",
        "integer_array_iteration", *output, "literal_output",
    ], "predicates-and-conditional-statements", year_table)
    return {"schema_version": 1, "samples": [fizz, even, empty, divisor, leap]}


if __name__ == "__main__":
    print(json.dumps(manifest(), indent=2))
