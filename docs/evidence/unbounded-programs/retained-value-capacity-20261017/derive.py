#!/usr/bin/env python3
"""Reproduce component arithmetic and frozen-source inventories for #119.

This is research tooling, not Silver's membership implementation. It derives
allocation upper charges for one successfully scanned integer token and counts
specified String allocation events. It does not infer frontend call counts.
"""

import argparse
import hashlib
import json
from pathlib import Path
import re

PIN = "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea"
DIRECT_MAX = 32767 * 32767
MAGNITUDE_MAX = 2**31
FILES = (
    "alloc.ads", "types.ads", "stringt.adb", "uintp.ads", "uintp.adb",
    "scng.adb", "scans.ads", "scans.adb", "scn.adb", "par-ch3.adb",
    "par-ch4.adb", "par-ch5.adb", "par-ch6.adb", "par-util.adb",
    "par-tchk.adb", "sem_eval.adb", "sem_res.adb", "sem_attr.adb",
    "sem_util.adb", "exp_imgv.adb", "exp_util.adb", "table.ads", "table.adb",
    "par-ch2.adb", "par-ch10.adb", "par-ch13.adb", "par-endh.adb",
    "exp_ch4.adb", "checks.adb", "validsw.ads", "atree.adb", "opt.ads",
    "switch-c.adb", "libgnat/system-linux-x86.ads",
)


def digits(value):
    return max(1, (abs(value).bit_length() + 14) // 15)


def bounded_power(base, exponent, limit):
    """Return min(base**exponent, limit+1) without materializing a large power."""
    result = 1
    power = base
    while exponent:
        if exponent & 1:
            result = min(limit + 1, result * power)
        exponent //= 2
        if exponent:
            power = min(limit + 1, power * power)
    return result


def power_digits(base, exponent):
    # base <= 2**k, hence base**e <= 2**(k*e), whose bit length is k*e+1.
    k = (base - 1).bit_length()
    return max(1, (k * exponent + 15) // 15)


def power_charge(base, exponent):
    """Append-only upper charge; no reuse/release credit, even for warm caches."""
    assert 2 <= base <= 16 and 0 <= exponent <= 799999
    events = []

    def multiply(left, right):
        power = left + right
        direct = bounded_power(base, power, DIRECT_MAX) <= DIRECT_MAX
        events.append({
            "kind": "multiply", "left_exponent": left,
            "right_exponent": right, "result_exponent": power,
            "uint_entries": 0 if direct else 1,
            "digit_words": 0 if direct else power_digits(base, power),
            "local_vector_words": 2 * (power_digits(base, left)
                                       + power_digits(base, right)),
        })

    if exponent <= 1:
        pass
    elif base in (2, 10) and exponent <= 128:
        # Cold memo table is worst case; powers 0..set may already be present.
        for power in range(1, exponent + 1):
            multiply(power - 1, 1)
    else:
        n = exponent
        square = 1
        result = 0
        while True:
            if n & 1:
                multiply(result, square)
                result += square
            n //= 2
            if not n:
                break
            multiply(square, square)
            square *= 2
        assert result == exponent
        direct = bounded_power(base, exponent, DIRECT_MAX) <= DIRECT_MAX
        events.append({
            "kind": "release_and_save", "result_exponent": exponent,
            "uint_entries": 0 if direct else 1,
            "digit_words": 0 if direct else power_digits(base, exponent),
            "local_vector_words": 0 if direct else power_digits(base, exponent),
        })
    return {
        "base": base, "exponent": exponent,
        "uint_entries": sum(event["uint_entries"] for event in events),
        "digit_words": sum(event["digit_words"] for event in events),
        "local_vector_words": max((event["local_vector_words"] for event in events), default=0),
        "events": events,
    }


def token_charge(base, mantissa_digits, exponent):
    """One valid nonnegative integer token; sign belongs to the expression."""
    assert 2 <= base <= 16 and 0 <= exponent <= 799999
    mantissa = 0
    prefix_entries = prefix_words = 0
    for digit in mantissa_digits:
        assert 0 <= digit < base
        product = mantissa * base
        mantissa = product + digit
        assert mantissa <= MAGNITUDE_MAX
        if product > DIRECT_MAX:
            prefix_entries += 1
            prefix_words += digits(product)
        # UI_Add with a table operand and zero returns that operand unchanged.
        if mantissa > DIRECT_MAX and digit:
            prefix_entries += 1
            prefix_words += digits(mantissa)
    power = power_charge(base, exponent)
    value = 0 if not mantissa else mantissa * bounded_power(base, exponent, MAGNITUDE_MAX)
    assert value <= MAGNITUDE_MAX
    final_entries = int(exponent != 0 and value > DIRECT_MAX)
    final_words = final_entries * digits(value)
    return {
        "base": base, "mantissa_digits": mantissa_digits,
        "exponent": exponent, "value": value,
        "uint_entries": prefix_entries + power["uint_entries"] + final_entries,
        "digit_words": prefix_words + power["digit_words"] + final_words,
        # 16 covers a three-digit mantissa prefix's multiply/add vectors.
        "local_vector_words": max(16, power["local_vector_words"],
                                  2 * (digits(mantissa) + power_digits(base, exponent)) if exponent else 0),
        "prefix_uint_entries": prefix_entries,
        "prefix_digit_words": prefix_words,
        "power": power,
        "final_multiply_uint_entries": final_entries,
        "final_multiply_digit_words": final_words,
    }


def check_arithmetic():
    checked = 0
    for base in range(2, 17):
        for exponent in list(range(257)) + [4096, 799999]:
            # This bounded research cross-check is separate from the derivation
            # algorithm, which never computes the materialized large power.
            exact = base**exponent
            assert digits(exact) <= power_digits(base, exponent)
            charge = power_charge(base, exponent)
            if exponent > 1 and not (base in (2, 10) and exponent <= 128):
                multiplies = [event for event in charge["events"] if event["kind"] == "multiply"]
                assert len(multiplies) == exponent.bit_count() + exponent.bit_length() - 1
                assert max(event["result_exponent"] for event in multiplies) <= exponent
            checked += 1
    return checked


def check_range_arithmetic():
    """Discriminate endpoint growth, including reversed and disjoint ranges.

    This checks mathematical operations, not frontend reachability or query
    counts. Source review supplies the transfer and the induction over trees.
    """
    checked = 0
    for left_width in (31, 32, 63, 128, 1024):
        left_bound = 2**left_width
        left_ranges = ((-left_bound, left_bound), (left_bound, -left_bound),
                       (left_bound, left_bound), (-left_bound, -left_bound),
                       (0, 0), (-1, 1))
        for lo, hi in left_ranges:
            assert max(abs(-hi), abs(-lo)) <= left_bound
            assert max(digits(-hi), digits(-lo)) <= (left_width + 15) // 15
            checked += 1
        for right_width in (31, 32, 63, 128, 1024):
            right_bound = 2**right_width
            right_ranges = ((-right_bound, right_bound),
                            (right_bound, -right_bound),
                            (right_bound, right_bound),
                            (-right_bound, -right_bound), (0, 0), (-1, 1))
            for llo, lhi in left_ranges:
                for rlo, rhi in right_ranges:
                    products = (llo*rlo, llo*rhi, lhi*rlo, lhi*rhi)
                    candidates = (
                        ((llo+rlo, lhi+rhi), max(left_width, right_width)+1),
                        ((llo-rhi, lhi-rlo), max(left_width, right_width)+1),
                        (products, left_width+right_width),
                    )
                    for values, width in candidates:
                        assert max(map(abs, values)) <= 2**width
                        assert max(map(digits, values)) <= (width + 15) // 15
                        checked += 1
    # Determine_Range's disjoint case must retain 2**32, not clamp it to
    # Standard.Integer. This is a mathematical discriminator, not an Ada run.
    disjoint = (2**31 + 2**31, 2**31 + 2**31)
    assert disjoint[0] > 2**31 - 1
    return {"checked": checked, "maximum_tested_operand_bits": 1025,
            "disjoint_computed_range": list(disjoint),
            "scope": "endpoint arithmetic only; not query/caller coverage"}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("source_root", type=Path)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    repository = Path(__file__).resolve().parents[4]
    manifest_path = repository / "docs/evidence/unbounded-programs/continuation-20261017/frontend-lifetimes/complete-source-manifest.json"
    manifest = json.loads(manifest_path.read_text())
    expected = {entry["path"]: entry for entry in manifest["files"]}
    sources = []
    rescan_sites = []
    allocations = []
    for name in FILES:
        raw = (args.source_root / name).read_bytes()
        sha256 = hashlib.sha256(raw).hexdigest()
        blob = hashlib.sha1(b"blob " + str(len(raw)).encode() + b"\0" + raw).hexdigest()
        assert sha256 == expected[name]["sha256"]
        assert blob == expected[name]["git_blob_sha1"]
        sources.append({"path": name, "bytes": len(raw), "sha256": sha256,
                        "git_blob_sha1": blob,
                        "url": f"https://github.com/gcc-mirror/gcc/blob/{PIN}/gcc/ada/{name}"})
        # LF, not splitlines(): GCC source contains form feeds.
        for number, line in enumerate(raw.decode().split("\n"), 1):
            if name.startswith("par") and re.search(r"\b(?:Save|Restore)_Scan_State\s*\(", line):
                rescan_sites.append({"file": name, "line": number, "text": line.strip()})
            if re.search(r"\b(?:Start_String|Store_String_Chars?|String_From_Numeric_Literal)\b", line):
                allocations.append({"file": name, "line": number, "text": line.strip()})
    result = {
        "kind": "conditional source-derived allocation components, not a membership rule",
        "upstream_commit": PIN,
        "source_hashes": sources,
        "source_hash_mismatches": 0,
        "arithmetic_discriminators_checked": check_arithmetic(),
        "range_arithmetic_discriminators": check_range_arithmetic(),
        "current_exponent_ceiling": 4096,
        "proposed_exponent_ceiling": 799999,
        "unsigned_scalar_numeral_magnitude_ceiling": MAGNITUDE_MAX,
        "direct_maximum": DIRECT_MAX,
        "string_descriptor_ids_including_initialized_null": -400000000 - (-499999998) + 1,
        "uint_table_ids": -600000000 - (-699999999) + 1,
        "token_examples": [
            token_charge(10, [0], 0), token_charge(10, [0], 4096),
            token_charge(10, [0], 799999), token_charge(2, [0], 799999),
            token_charge(16, [0], 799999), token_charge(10, list(map(int, "2147483648")), 0),
            token_charge(2, [1], 31), token_charge(10, [1], 9),
        ],
        "string_event_examples": {
            "two_chains_30_doublings_no_sharing_credit": {
                "literal_descriptors": 2, "fold_descriptors": 60,
                "characters": 2 + 2 * sum(2**power for power in range(1, 31)),
                "excludes": "dependency/generated events and multiplicity; upper charge, not observed usage",
            },
            "parser_1000_concats_of_one_char_literals": {
                "lexical_descriptors": 1001, "lexical_characters": 1001,
                "parser_fold_descriptors": 1, "parser_fold_characters": 1001,
                "semantic_empty_left_fold_descriptors": 0,
                "semantic_empty_left_fold_characters": 0,
                "excludes": "scan multiplicity, dependencies and generated events",
            },
        },
        "main_parse_upper_bound": {
            "source_literal_scan_multiplicity": 2,
            "parser_characters_per_source_decoded_character": 3,
            "parser_descriptors": "2*source_string_literals + floor(source_concat_operators/1000)",
            "scope": "one syntactically valid Main parse with unchanged Silver grammar; excludes initialization, dependency parses and semantic/generated events",
            "argument": "retained-value-capacity.md#main-parser-multiplicity",
        },
        "normalized_native_scalar_operator_events": {
            "ordinary_node_id_allocations_per_operator": 2,
            "dynamic_slots_per_operator": 9,
            "entity_allocations_per_operator": 0,
            "list_headers_per_operator": 0,
            "growing_slot_copy_events_per_operator": 0,
            "scope": "one local expansion of a resolved nonstatic Standard.Integer +,-,*,unary-minus; strict backend overflow; no widening parent, validity operands, Universal_Integer or other scalar types; excludes prior semantic work and surrounding generated constructs",
            "argument": "retained-value-capacity.md#normalized-native-integer-operator-expansion",
        },
        "scalar_range_inference": {
            "leaf_magnitude_exponent": 31,
            "negation_exponent": "w(child)",
            "addition_subtraction_exponent": "max(w(left), w(right)) + 1",
            "multiplication_exponent": "w(left) + w(right)",
            "digit_words_per_endpoint": "ceil((w(expression) + 1) / 15)",
            "local_operation_charges": {
                "negation": {"uint_entries": 2, "digit_words": "2*k", "local_vector_words": "k"},
                "addition": {"uint_entries": 2, "digit_words": "2*k", "local_vector_words": "5*k+3"},
                "subtraction": {"uint_entries": 4, "digit_words": "4*k", "local_vector_words": "5*k+3"},
                "multiplication_and_save": {"uint_entries": 6, "digit_words": "6*k", "local_vector_words": "4*k"},
            },
            "scope": "one range query over a pure scalar expression tree with leaf/type magnitudes <=2**31; capture initializers must be unfolded; excludes other generated forms and query multiplicity",
            "argument": "retained-value-capacity.md#temporary-values-in-scalar-range-inference",
        },
        "parser_scan_state_text_matches": rescan_sites,
        "selected_string_allocation_text_matches": allocations,
        "inventory_scope": "Text inventories in named files, including comments; not an exhaustive resolved call graph.",
        "validation": "Frozen-source hashes, source reading and bounded integer arithmetic only; no compiler/prover invocation.",
    }
    args.output.write_text(json.dumps(result, indent=2) + "\n")


if __name__ == "__main__":
    main()
