#!/usr/bin/env python3
"""Reproduce reviewed-by-source local concat envelopes, not tool admission.

The rows are a manual control-flow derivation, not automatic call-graph closure.
The script checks pinned inputs, emits a lexical inspection aid, and sums rows.
It neither executes GNAT nor establishes costs of the named open helper routes.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re

parser = argparse.ArgumentParser()
parser.add_argument("ada_source", type=Path)
parser.add_argument("output", type=Path)
args = parser.parse_args()
repository = Path(__file__).resolve().parents[4]
manifest = json.loads((repository / "docs/evidence/unbounded-programs/"
    "continuation-20261017/frontend-lifetimes/complete-source-manifest.json").read_text())
pin = "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea"
assert manifest["commit"] == pin
expected = {entry["path"]: entry for entry in manifest["files"]}
files = ["exp_ch4.adb", "exp_util.adb", "sem_util.adb", "sem_res.adb",
         "sem_eval.adb", "tbuild.adb", "namet.adb", "lib.adb", "validsw.ads",
         "atree.adb", "types.ads", "uintp.ads", "uintp.adb", "gen_il-gen.adb",
         "exp_imgv.adb", "exp_put_image.adb", "exp_ch2.adb", "exp_ch3.adb",
         "exp_ch8.adb", "sem_ch4.adb", "sem_dim.adb", "rtsfind.ads",
         "elists.adb", "libgnat/g-htable.ads", "libgnat/s-htable.adb"]
sources = {}
hashes = {}
for name in files:
    raw = (args.ada_source / name).read_bytes()
    hashes[name] = hashlib.sha256(raw).hexdigest()
    blob = hashlib.sha1(b"blob " + str(len(raw)).encode() + b"\0" + raw).hexdigest()
    assert hashes[name] == expected[name]["sha256"], name
    assert blob == expected[name]["git_blob_sha1"], name
    sources[name] = raw.decode()

# Each pair denotes n_coefficient * n + constant, where n >= 2.
ordinary_rows = [
    ("initial aggregate zero", "2829", 0, 1),
    ("operand bounds/length, excluding last-bound capture", "2870-3045", 4, 0),
    ("last-bound capture, including two Convert_To calls", "2879-3007", 0, 8),
    ("aggregate lengths", "3054-3099", 5, 0),
    ("lower-bound conditional spine and capture", "3176-3228", 4, 3),
    ("high-bound expression", "3237-3253", 0, 3),
    ("null-result selection", "3273-3290", 0, 6),
    ("static maximum and optional slice range", "3306-3315", 0, 2),
    ("result subtype syntax", "3326-3342", 0, 4),
    ("result storage, maximum of secondary/plain paths", "3374-3433", 0, 12),
    ("runtime concatenation call", "3512-3538", 0, 3),
    ("slice assignment with optional guard", "3554-3617", 12, 0),
    ("result reference and optional slice", "3629-3632", 0, 2),
    ("saved old node in terminal Rewrite", "3453,3637", 0, 1),
]
entity_rows = [
    ("dynamic operand length", "3015", 1, 0),
    ("aggregate length beyond first retained operand", "3078", 1, -1),
    ("captured lower bound", "3219", 0, 1),
    ("result object", "3344", 0, 1),
    ("secondary-stack subtype/access/object", "3367,3368,3404", 0, 3),
]
list_rows = [
    ("dispatch operand list", "8046", 0, 1),
    ("action collection", "2658", 0, 1),
    ("lower-bound conditionals", "3197", 1, 0),
    ("null-result selectors", "3276,3285", 0, 2),
    ("result index constraint", "3342", 0, 1),
    ("result-storage Insert_Action wrappers", "3374-3430", 0, 4),
    ("runtime actuals and Insert_Action wrapper", "3513,3535", 0, 2),
    ("assignment guard and Insert_Action wrapper", "3617,3620", 2, 0),
]
copy_rows = [
    ("operand lower bound", "2905,2976", 1, 0),
    ("last literal lower/high bounds", "2881,2886", 0, 2),
    ("aggregate length capture", "3096", 1, -1),
    ("lower-bound recursion", "3179,3205", 1, 0),
    ("high-bound expression", "3249,3252", 0, 2),
    ("null-result selectors", "3278,3287", 0, 2),
    ("error-path bound rewrite", "3453", 0, 1),
    ("slice assignment endpoints", "3556,3561", 2, 0),
]

def table(rows):
    return {"rows": [{"reason": reason, "exp_ch4_lines": lines,
                       "n_coefficient": n, "constant": c}
                      for reason, lines, n, c in rows],
            "n_coefficient": sum(row[2] for row in rows),
            "constant": sum(row[3] for row in rows)}

# This aids coverage inspection; it does not decide whether a site is reachable.
calls = []
for line_number, line in enumerate(sources["exp_ch4.adb"].splitlines(), 1):
    if 2829 <= line_number <= 3638 or 8046 <= line_number <= 8092:
        code = line.split("--", 1)[0]
        for call in re.findall(r"\b(?:Make_\w+|New_\w+|Insert_Actions?|"
                               r"Duplicate_Subexpr|Convert_To|Rewrite|"
                               r"Analyze_And_Resolve|Freeze_Itype|RTE(?:_Available)?)\b", code):
            calls.append({"line": line_number, "name": call})

def uint_digits(magnitude):
    assert magnitude >= 0
    digits = 1
    while magnitude >= 32768:
        digits += 1
        magnitude //= 32768
    return digits

examples = []
for n, input_bound in [(2, 4096), (9, 4096), (10, 4096), (64, 4096),
                       (2**31 - 2, 2**31 - 1)]:
    magnitude = n * max(2 * input_bound + 1, 256) + input_bound + 1
    digits = uint_digits(magnitude)
    examples.append({"operands": n, "input_magnitude_bound": input_bound,
                     "intermediate_magnitude_bound": magnitude, "base_32768_digits": digits,
                     "direct_uint_entries": 7 * n + 6,
                     "including_index_helper_arithmetic_uint_entries": 13 * n + 6,
                     "including_index_helper_arithmetic_digit_words": digits * (13 * n + 6)})

result = {
    "source_commit": pin,
    "source_files_verified": len(files),
    "source_sha256": hashes,
    "scope": "native String concat direct emitter and specified primitive helpers; not transitive closure",
    "ordinary_allocations_excluding_New_Copy_Tree_and_open_helpers": table(ordinary_rows),
    "fresh_temporary_entities_and_internal_names": table(entity_rows),
    "list_headers_including_direct_Insert_Action_wrappers": table(list_rows),
    "direct_New_Copy_Tree_invocations": table(copy_rows),
    "simple_aggregate_leaf_copies": {"n_coefficient": 1, "constant": 2},
    "remaining_direct_New_Copy_Tree_invocations": {"n_coefficient": 4, "constant": 4},
    "Duplicate_Subexpr_invocations": {"n_coefficient": 2, "constant": 2},
    "ordinary_allocations_including_simple_aggregate_leaf_copies": {"n_coefficient": 26, "constant": 47},
    "direct_growing_slot_events": 1,
    "direct_Name_Enter_characters_per_temporary_including_NUL": 13,
    "direct_uint_additions": {"n_coefficient": 3, "constant": 2},
    "direct_uint_subtractions": {"n_coefficient": 2, "constant": 2},
    "Get_First_Index_Bounds_invocations": {"n_coefficient": 2, "constant": 0},
    "uint_arithmetic_examples_not_admission_thresholds": examples,
    "decorated_copy_transfer": {
        "premises": "no owned normal entities/actions/blocks/dimensions/packed/discriminated types; owned itypes only one-dimensional String array subtypes, signed scalar index subtypes and String-literal subtypes; default empty entity map",
        "ordinary_nodes": "t + a + sum(r_j)",
        "entities_and_names": "e",
        "syntax_list_headers": "l + a + sum(s_j)",
        "pending_itype_elist_headers": "q",
        "pending_itype_elist_elements": "e",
        "new_entity_hash_entries": "e",
        "pending_itype_hash_entries": "q",
        "growing_slot_events": 0,
        "String_Uint_value_allocations": 0,
        "hash_lifetime": "wrappers freed at next public copy reset; Elist headers/elements retained",
        "examples": [
            {"shape": "scalar leaf", "t": 1, "l": 0, "a": 0, "sum_r": 0,
             "sum_s": 0, "e": 0, "q": 0, "ordinary_nodes": 1, "syntax_lists": 0},
            {"shape": "Image slice with simple bounds", "t": 5, "l": 0, "a": 1,
             "sum_r": 3, "sum_s": 0, "e": 2, "q": 1,
             "ordinary_nodes": 9, "syntax_lists": 1},
            {"shape": "First attribute of the same Image slice", "t": 6, "l": 0, "a": 1,
             "sum_r": 3, "sum_s": 0, "e": 2, "q": 1,
             "ordinary_nodes": 10, "syntax_lists": 1},
        ],
    },
    "native_Image_shape": "Integer Image uses Image_Integer procedure plus Snn(1..Pnn), not Put_Image/unconstrained function call",
    "concat_allocator_expansion": {
        "runtime_entity": "RE_SS_Allocate",
        "runtime_unit": "System.Secondary_Stack",
        "ordinary_node_entity_list_allocations_in_Expand_N_Allocator": 0,
        "premises": "generated named access to constrained uncontrolled String; expression subtype identifier; No_Initialization; not special return/coextension; Linux 64-bit address; no restrictive config diagnostic",
        "not_included": "allocator semantic analysis, access-type declaration/freezing, RTE lookup/dependency loading, backend emission",
    },
    "lexical_call_sites_not_a_reachable_call_graph": calls,
    "limitations": ["no native compiler/prover/build execution", "no complete source-to-event bound",
                    "no semantic/generated-action/recursive-copy closure", "no safe language threshold",
                    "no backend or dependency cost included", "no independent review yet"],
}
assert (result["ordinary_allocations_excluding_New_Copy_Tree_and_open_helpers"]["n_coefficient"],
        result["ordinary_allocations_excluding_New_Copy_Tree_and_open_helpers"]["constant"]) == (25, 45)
assert (result["fresh_temporary_entities_and_internal_names"]["n_coefficient"],
        result["fresh_temporary_entities_and_internal_names"]["constant"]) == (2, 4)
assert (result["list_headers_including_direct_Insert_Action_wrappers"]["n_coefficient"],
        result["list_headers_including_direct_Insert_Action_wrappers"]["constant"]) == (3, 11)
assert (result["direct_New_Copy_Tree_invocations"]["n_coefficient"],
        result["direct_New_Copy_Tree_invocations"]["constant"]) == (5, 6)
for case in result["decorated_copy_transfer"]["examples"]:
    assert case["ordinary_nodes"] == case["t"] + case["a"] + case["sum_r"]
    assert case["syntax_lists"] == case["l"] + case["a"] + case["sum_s"]
args.output.write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps({"verified_sources": len(files), "lexical_call_sites": len(calls),
                  "ordinary_direct": "25*n+45", "whole_construct_closed": False}))
