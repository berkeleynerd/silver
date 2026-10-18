#!/usr/bin/env python3
"""Reconcile fixed Standard floating-bound callbacks, using offline arithmetic.

The handwritten source-path argument in retained-native-expansion.md is required.
This checks pinned sources and the four finite arithmetic cases; it does not run
GNAT/GCC, observe an allocation, or establish a whole-compiler capacity bound.
"""
import argparse
import hashlib
import json
from pathlib import Path


parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--gcc-root", type=Path, required=True)
parser.add_argument("--ada", type=Path, required=True)
parser.add_argument("--output", type=Path, required=True)
args = parser.parse_args()
bundle = Path(__file__).resolve().parent
manifest = json.loads((bundle / "fixed-root-source-identity.json").read_text())
sources = {}
for record in manifest["files"]:
    path = record["path"]
    source = (args.ada / path.removeprefix("gcc/ada/")
              if path.startswith("gcc/ada/") else args.gcc_root / path)
    raw = source.read_bytes()
    assert len(raw) == record["bytes"], record["path"]
    assert hashlib.sha256(raw).hexdigest() == record["sha256"], record["path"]
    sources[record["path"]] = raw.decode()


def between(path, start, end):
    text = sources["gcc/ada/" + path]
    a = text.index(start)
    return text[a:text.index(end, a + len(start))]


literal = between("tbuild.adb", "   function Make_Float_Literal\n",
                  "   end Make_Float_Literal;")
assert "Set_Is_Machine_Number" not in literal
assert "Exponent mod 4" in literal and "Exponent / 4" in literal
assert "Rbase    => UI_To_Int (Radix)" in literal
standard = between("cstand.adb", "   function New_Standard_Entity return Entity_Id",
                   "   end New_Standard_Entity;")
for flag in ("Is_Pure", "Is_Public", "Is_Frozen", "Needs_Debug_Info",
             "Has_Qualified_Name"):
    assert "Set_" + flag + " (E)" in standard, flag
decompose = between("eval_fat.adb", "   procedure Decompose_Int\n",
                    "   end Decompose_Int;")
assert "Release_And_Save" in decompose
assert decompose.count("Release_And_Save") == 7  # Two are in the excluded general-base branch.
assert "Most_Significant_Digit * Radix" in decompose
for op in ("N := N - D", "Fraction := Fraction + 1", "N := N * Radix",
           "Fraction := Fraction * Radix", "D := D * Radix"):
    assert op in decompose, op
assert "return Store_Ureal" in between("urealp.adb", "   function UR_Abs (",
                                      "   end UR_Abs;")
assert "return Store_Ureal" in between("urealp.adb", "   function UR_Negate (",
                                      "   end UR_Negate;")


def fixed_case(p, emax):
    """The selected positive Decompose_Int route, in mathematical integers."""
    shift = (emax - p) % 4
    numerator = ((1 << p) - 1) << shift
    original_numerator = numerator
    exponent = emax - p - shift
    denominator = 1
    most_significant_digit = 1 << (p - 1)
    assert numerator * 2 >= denominator  # The first scaling loop is empty.
    denominator_iterations = 0
    while numerator >= denominator:
        denominator *= 2
        exponent += 1
        denominator_iterations += 1
    assert denominator_iterations == p + shift
    assert exponent == emax
    fraction = 0
    subtractions = shifts = outer_iterations = 0
    max_magnitude = max(original_numerator * 2, denominator)
    while True:
        outer_iterations += 1
        local_subtractions = 0
        while numerator >= denominator:
            numerator -= denominator
            fraction += 1
            subtractions += 1
            local_subtractions += 1
        assert local_subtractions <= 1
        if fraction >= most_significant_digit:
            break
        numerator *= 2
        fraction *= 2
        shifts += 1
        max_magnitude = max(max_magnitude, numerator, fraction)
    assert outer_iterations == p + 1
    assert subtractions == shifts == p
    assert fraction == (1 << p) - 1 and numerator == 0
    assert fraction != most_significant_digit * 2  # No rounding carry.
    assert exponent >= 3 - emax  # No denormal/underflow branch.
    digit_words = (max_magnitude.bit_length() + 14) // 15
    assert digit_words <= 8
    # Cold 2-power cache <= p, denominator updates <= 2*(p+r),
    # fraction arithmetic <= 5*p (subtraction can negate then add),
    # 32 for remaining scalar arithmetic and five two-result save calls.
    tight_append_envelope = p + 2 * (p + shift) + 5 * p + 32
    loose_append_envelope = 9 * p + 8 * shift + 64
    assert tight_append_envelope <= loose_append_envelope
    assert 2 * loose_append_envelope <= 4096
    return {
        "mantissa_bits": p, "emax": emax, "base16_shift": shift,
        "denominator_loop_iterations": denominator_iterations,
        "fraction_loop_iterations": outer_iterations,
        "fraction_subtractions": subtractions,
        "fraction_shifts": shifts,
        "uint_digit_words": digit_words,
        "uint_append_envelope_per_bound": loose_append_envelope,
        "output_numerator_decimal": str(fraction),
        "output_denominator": p - emax,
    }


cases = [fixed_case(p, e) for p, e in ((24, 128), (53, 1024),
                                     (64, 16384), (113, 16384))]
result = {
    "scope": "Two fixed Standard_Long_Long_Float bounds in the selected native gigi prefix",
    "gcc_commit": manifest["commit"],
    "verified_source_files": len(manifest["files"]),
    "arithmetic_cases": cases,
    "sufficient_callback_transfer": {
        "Uint_appends": 4096, "Udigit_word_appends": 32768,
        "Ureal_appends": 7, "UI_Ints_cache_insertions": 4096,
        "largest_local_numeric_vector_words": 9,
        "Repinfo_nodes_from_float_conversion": 0,
    },
    "incoming_table_positions_and_backing_checks_required": True,
    "cache_and_release_reuse_not_subtracted": True,
    "handwritten_source_path_argument_required": True,
    "compiler_or_prover_execution": False,
    "numeric_GCC_setup_bound_established": False,
    "complete_GCC_capacity_established": False,
}
args.output.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
print(json.dumps({"verified_sources": len(manifest["files"]),
                  "finite_arithmetic_cases": len(cases),
                  "callback_transfer": result["sufficient_callback_transfer"],
                  "compiler_or_prover_execution": False}))
