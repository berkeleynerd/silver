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
         "sem_eval.adb", "tbuild.adb", "namet.adb", "lib.adb", "validsw.ads", "stringt.adb",
         "cstand.adb", "ttypes.ads", "contracts.adb", "uname.adb",
         "atree.adb", "types.ads", "uintp.ads", "uintp.adb", "gen_il-gen.adb", "sinfo-cn.adb",
         "exp_imgv.adb", "exp_put_image.adb", "exp_ch2.adb", "exp_ch3.adb",
         "exp_ch8.adb", "sem_ch4.adb", "sem_dim.adb", "rtsfind.ads",
         "elists.adb", "libgnat/g-htable.ads", "libgnat/s-htable.adb",
         "sem_ch3.adb", "sem.adb", "sem_ch2.adb", "sem_ch6.adb", "sem_ch8.adb", "checks.adb",
         "freeze.adb", "layout.adb", "lib-xref.adb", "sem_warn.adb",
         "sem_elim.adb", "sem_cat.adb", "einfo-utils.adb", "sem_ch13.adb",
         "exp_ch13.adb", "nlists.adb", "itypes.adb", "expander.adb",
         "sem_aux.adb", "ghost.adb", "sem_type.adb", "restrict.adb",
         "gen_il-gen-gen_nodes.adb", "gen_il-gen-gen_entities.adb",
         "local_restrict.adb", "accessibility.adb", "opt.ads",
         "sem_attr.adb", "exp_attr.adb", "sem.ads", "exp_dbug.adb", "namet.ads",
         "sem_ch11.adb", "exp_ch11.adb", "sem_elab.adb", "errout.adb",
         "ali.adb", "ali.ads", "lib-writ.adb", "warnsw.ads", "sem_prag.adb",
         "erroutc.adb", "erroutc.ads", "sem_ch10.adb", "sem_ch12.adb",
         "targparm.adb", "targparm.ads", "libgnat/system-linux-x86.ads",
         "exp_ch7.adb", "exp_ch6.adb", "exp_ch9.adb", "exp_tss.adb", "sem_ch5.adb", "exp_ch5.adb",
         "rtsfind.adb", "libgnat/s-secsta.ads", "libgnat/s-parame.ads",
         "libgnat/s-stoele.ads", "libgnat/s-imgint.ads", "libgnat/s-imagei.ads"
         ] + [f"libgnat/s-conca{i}.ads" for i in range(2, 10)]
sources = {}
hashes = {}
for name in files:
    raw = (args.ada_source / name).read_bytes()
    hashes[name] = hashlib.sha256(raw).hexdigest()
    blob = hashlib.sha1(b"blob " + str(len(raw)).encode() + b"\0" + raw).hexdigest()
    assert hashes[name] == expected[name]["sha256"], name
    assert blob == expected[name]["git_blob_sha1"], name
    sources[name] = raw.decode()

# Residual first RTE lookups need one already-loaded-unit Priv_Par header each.
# Count all enumeration values, conservatively including ineligible roots.
re_enum = re.search(r"type RE_Id is \((.*?)\);", sources["rtsfind.ads"], re.S).group(1)
re_enum = re.sub(r"--[^\n]*", "", re_enum)
re_ids = re.findall(r"\b(?:RE|RO)_[A-Za-z0-9_]+\b", re_enum)
assert len(re_ids) == len(set(re_ids)) and re_ids[0] == "RE_Null"

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

def enabled_range_check(b, lists, analysis_graph):
    """Specified pure resolved Integer bounds; excludes first bound analysis."""
    assert b >= 2 and lists >= 0 and analysis_graph >= 1
    a = analysis_graph
    rows = {
        "builder_and_selection": dict(ordinary=2*b+28+20*a, lists=2*lists,
                                       growth=0, uint=80*a+60),
        "three_order_comparisons": dict(ordinary=3*(40*a+5), lists=0,
                                        growth=6, uint=3*(160*a+120)),
        "two_Positive_bound_attributes": dict(ordinary=4, lists=0, growth=2, uint=0),
        "at_most_six_same_Integer_conversions": dict(ordinary=12, lists=0,
                                                    growth=6, uint=36*a),
        "two_short_circuits_including_empty_left_wrappers": dict(ordinary=16,
                                                                 lists=2, growth=6, uint=0),
        "conditional_raise_analysis": dict(ordinary=2, lists=0, growth=1, uint=0),
    }
    total = {key: sum(row[key] for row in rows.values())
             for key in ("ordinary", "lists", "growth", "uint")}
    assert total == dict(ordinary=2*b+140*a+77, lists=2*lists+2,
                         growth=21, uint=596*a+420)
    return dict(b=b, bound_syntax_lists=lists, analysis_graph=a, rows=rows, total=total)


def direct_and_scalar_concat(n, analysis_graph):
    """Partial stage aggregate; excludes open copies/storage/calls/placement."""
    assert n >= 2 and analysis_graph >= 1
    a = analysis_graph
    rows = {
        "direct_including_simple_aggregate_leaf_copies": dict(
            ordinary=26*n+47, lists=3*n+11, growth=1, uint=13*n+6),
        "initial_arithmetic_with_enabled_check_envelope": dict(
            ordinary=2*(4*n+2), lists=0, growth=4*n+2, uint=(4*n+2)*(6*a+2)),
        "initial_scalar_conditionals": dict(ordinary=2*(n+2), lists=0, growth=n+2, uint=0),
        "initial_Eq_Ne_comparisons": dict(ordinary=(2*n+2)*(40*a+5), lists=2,
                                          growth=4*n+4, uint=(2*n+2)*(160*a+120)),
        "initial_String_attributes": dict(ordinary=20*n*a+6*n+4, lists=0,
                                           growth=3*n+2, uint=n*(80*a+64)),
        "two_initial_same_Integer_conversions": dict(ordinary=4, lists=0,
                                                       growth=2, uint=12*a),
        "direct_lower_bound_selection_comparisons": dict(ordinary=20*n*a,
                                                          lists=0, growth=0, uint=n*(80*a+60)),
    }
    total = {key: sum(row[key] for row in rows.values())
             for key in ("ordinary", "lists", "growth", "uint")}
    assert total == dict(ordinary=(120*n+80)*a+52*n+73, lists=3*n+13,
                         growth=12*n+13, uint=(504*n+344)*a+385*n+250)
    total.update(entities_and_names=2*n+4, name_characters=13*(2*n+4))
    return dict(operands=n, analysis_graph=a, rows=rows, total=total)


def result_storage(b, lists, analysis_graph):
    """Resolved pure bounds; initial bound analysis and later object freeze excluded."""
    a = analysis_graph
    check = enabled_range_check(b, lists, a)["total"]
    plain = dict(ordinary=check["ordinary"]+6, lists=check["lists"]+1,
                 growth=check["growth"]+2, uint=check["uint"]+99,
                 entities_and_names=2, name_characters=33, elists=0)
    secondary = dict(ordinary=2*b+20*a+34, lists=2*lists+2,
                     growth=2, uint=80*a+159,
                     entities_and_names=2, name_characters=29, elists=1)
    envelope = {key: max(plain[key], secondary[key]) for key in plain}
    assert envelope == dict(ordinary=2*b+140*a+83, lists=2*lists+3,
                            growth=23, uint=596*a+519, entities_and_names=2,
                            name_characters=33, elists=1)
    return dict(bound_nodes=b, bound_lists=lists, analysis_graph=a,
                plain=plain, secondary=secondary, envelope=envelope)


def direct_scalar_and_storage_concat(n, b, lists, analysis_graph):
    """Partial composed recurrence, with explicit unresolved boundary."""
    first = direct_and_scalar_concat(n, analysis_graph)["total"]
    storage = result_storage(b, lists, analysis_graph)["envelope"]
    total = {key: first.get(key, 0)+storage.get(key, 0)
             for key in sorted(first.keys() | storage.keys())}
    a = analysis_graph
    assert total == dict(ordinary=(120*n+220)*a+52*n+156+2*b,
                         lists=3*n+2*lists+16, growth=12*n+36,
                         uint=(504*n+940)*a+385*n+769,
                         entities_and_names=2*n+6,
                         name_characters=26*n+85, elists=1)
    return dict(operands=n, bound_nodes=b, bound_lists=lists,
                analysis_graph=a, total=total)


def native_length_optimizer(analysis_graph):
    """Artificial one-dimensional Length Ne, absent dimension arguments."""
    a = analysis_graph
    assert a >= 1
    rows = {
        "builder_including_abandoned_trees": dict(ordinary=27, growth=1, uint=0),
        "four_First_Last_attributes": dict(ordinary=8, growth=4, uint=0),
        "four_unchecked_signed_conversions": dict(ordinary=8, growth=4, uint=0),
        "two_signed_arithmetic_operations": dict(ordinary=4, growth=2, uint=4),
        "one_concrete_non_Length_comparison": dict(ordinary=40*a+5, growth=2,
                                                   uint=160*a+120),
        "two_explicit_comparison_queries": dict(ordinary=40*a, growth=0,
                                                uint=160*a+120),
        "two_range_queries_and_power_cache_extensions": dict(ordinary=0, growth=0,
                                                              uint=12*a+64),
    }
    total = {key: sum(row[key] for row in rows.values())
             for key in ("ordinary", "growth", "uint")}
    assert total == dict(ordinary=80*a+52, growth=13, uint=332*a+308)
    return dict(analysis_graph=a, rows=rows, total=total)


def suppressed_native_length_check(analysis_graph):
    """Frozen constrained String types or literal; excludes actual-subtype creation."""
    a = analysis_graph
    opt = native_length_optimizer(a)["total"]
    rows = {
        "two_initial_Length_attributes": dict(ordinary=40*a+8, growth=4,
                                              uint=160*a+128),
        "initial_universal_comparison": dict(ordinary=40*a+5, growth=2,
                                              uint=160*a+120),
        "narrowing_builder_and_two_conversion_analyses": dict(ordinary=12, growth=3,
                                                              uint=0),
        "narrowing_range_and_size_queries": dict(ordinary=0, growth=0, uint=12*a+272),
        "narrowed_concrete_comparison": dict(ordinary=40*a+5, growth=2,
                                             uint=160*a+120),
        "up_to_two_length_optimizer_entries": {key: 2*value for key, value in opt.items()},
        "check_builder_static_lengths_raise_and_discard": dict(ordinary=10, growth=2,
                                                                uint=6),
    }
    total = {key: sum(row[key] for row in rows.values())
             for key in ("ordinary", "growth", "uint")}
    assert total == dict(ordinary=280*a+144, growth=39, uint=1156*a+1262)
    return dict(analysis_graph=a, rows=rows, total=total)


def suppressed_slice_assignment_checks(analysis_graph):
    """Checks/overlap/optional guard only; excludes slice and child analysis."""
    a = analysis_graph
    one = suppressed_native_length_check(a)["total"]
    rows = {
        "semantic_and_native_length_check_passes": {key: 2*value for key, value in one.items()},
        "two_overlap_queries": dict(ordinary=40*a, growth=0, uint=160*a+120),
        "optional_if_skeleton": dict(ordinary=2, growth=1, uint=0),
    }
    total = {key: sum(row[key] for row in rows.values())
             for key in ("ordinary", "growth", "uint")}
    assert total == dict(ordinary=600*a+290, growth=79, uint=2472*a+2644)
    return dict(analysis_graph=a, rows=rows, total=total)


def suppressed_slice_resolution(t, lists, analysis_graph):
    """Suffix after prefix/actual-subtype and first child analysis; no owned types."""
    assert t >= 3 and lists >= 0 and analysis_graph >= 1
    rows = {
        "range_static_folds": dict(ordinary=4, lists=0, growth=2, uint=0,
                                    entities_and_names=0, name_characters=0),
        "two_scalar_bound_captures": dict(ordinary=10, lists=2, growth=0, uint=0,
                                          entities_and_names=2, name_characters=26),
        "slice_subtype_and_size": dict(ordinary=t+2, lists=lists+2, growth=0, uint=4,
                                       entities_and_names=2, name_characters=26),
    }
    total = {key: sum(row[key] for row in rows.values()) for key in next(iter(rows.values()))}
    assert total == dict(ordinary=t+16, lists=lists+4, growth=2, uint=4,
                         entities_and_names=4, name_characters=52)
    checks = suppressed_slice_assignment_checks(analysis_graph)["total"]
    combined = {key: total.get(key, 0)+checks.get(key, 0)
                for key in sorted(total.keys() | checks.keys())}
    a = analysis_graph
    assert combined == dict(ordinary=600*a+t+306, lists=lists+4, growth=81,
                            uint=2472*a+2648, entities_and_names=4, name_characters=52)
    return dict(range_nodes=t, range_lists=lists, analysis_graph=a, rows=rows,
                total=total, with_assignment_check_suffix=combined)


def enabled_final_slice(t, lists, analysis_graph):
    """Final concat result slice; known target endpoints, frozen result type."""
    a = analysis_graph
    rows = {
        "slice_resolution": suppressed_slice_resolution(t, lists, a)["total"],
        "enabled_range_check": enabled_range_check(t-1, lists, a)["total"],
        "Insert_Action_wrapper": dict(lists=1),
    }
    keys = sorted(set().union(*(row.keys() for row in rows.values())))
    total = {key: sum(row.get(key, 0) for row in rows.values()) for key in keys}
    assert total == dict(ordinary=140*a+3*t+91, lists=3*lists+7, growth=23,
                        uint=596*a+424, entities_and_names=4, name_characters=52)
    return dict(range_nodes=t, range_lists=lists, analysis_graph=a,
                rows=rows, total=total)


def uncached_dereference_actual_subtype(analysis_graph):
    """Frozen unconstrained String view P.all, pure internal constant pointer P."""
    a = analysis_graph
    assert a >= 1
    rows = {
        "build_actual_subtype_including_two_copies": dict(ordinary=13, lists=3,
            growth=0, uint=0, entities_and_names=1, name_characters=13),
        "two_First_Last_analyses": dict(ordinary=4, lists=0,
            growth=2, uint=0, entities_and_names=0, name_characters=0),
        "two_dimension_literal_folds": dict(ordinary=4, lists=0,
            growth=2, uint=0, entities_and_names=0, name_characters=0),
        "suppressed_subtype_b8_l2": dict(ordinary=2*8+32+20*a, lists=2*2,
            growth=2, uint=80*a+155, entities_and_names=1, name_characters=16),
        "explicit_freeze_and_first_size": dict(ordinary=1, lists=1,
            growth=0, uint=4, entities_and_names=0, name_characters=0),
    }
    total = {key: sum(row[key] for row in rows.values()) for key in next(iter(rows.values()))}
    assert total == dict(ordinary=20*a+70, lists=8, growth=6, uint=80*a+159,
                         entities_and_names=2, name_characters=29)
    return dict(analysis_graph=a, rows=rows, total=total)


# Prove the setter inventory against the frozen source manifest, not whatever
# untracked files might happen to be present beside the inspected snapshot.
macro_flag_setter_sites = []
macro_flag_searched_files = 0
for name, entry in expected.items():
    if not name.endswith((".adb", ".ads")):
        continue
    raw = (args.ada_source / name).read_bytes()
    assert hashlib.sha256(raw).hexdigest() == entry["sha256"], name
    macro_flag_searched_files += 1
    for number, line in enumerate(raw.decode().splitlines(), 1):
        if "Set_Is_Renaming_Of_Object" in line:
            macro_flag_setter_sites.append(dict(file=name, line=number, source=line.strip()))
assert macro_flag_setter_sites == [dict(file="exp_ch8.adb", line=174,
    source="Set_Is_Renaming_Of_Object (Defining_Identifier (N));")]


def normalized_native_view():
    """Current native value shape, not cumulative allocation/query cost."""
    low = 3
    last = 5
    high = low+4
    null_low = 1+3+last+low
    null_high = 1+3+last+high
    assignment_low = null_low+2
    assignment_high = null_low+4
    common_range = 1+max(null_low+null_high, assignment_low+assignment_high)
    syntax = 1+2+common_range
    copied_ordinary = syntax+1+common_range
    copied_entities = 2
    copied_lists = 2+1+2
    assert (null_low, null_high, assignment_low, assignment_high, common_range,
            syntax, copied_ordinary, copied_entities, copied_lists) == (
            12, 16, 14, 16, 31, 34, 66, 2, 5)
    return dict(operand_low=low, last_bound=last, high_before_null=high,
                low_after_null=null_low, high_after_null=null_high,
                assignment_low=assignment_low, assignment_high=assignment_high,
                common_range=common_range, current_view_syntax=syntax,
                copied_ordinary=copied_ordinary, copied_entities=copied_entities,
                copied_lists=copied_lists, copied_attribute_ordinary=copied_ordinary+1,
                pending_elist_headers=1, pending_elist_elements=2, hash_wrappers=3)


def direct_native_copy_costs(n):
    """Emitter copies, including raw bounds; excludes later analysis."""
    assert n >= 2
    view = normalized_native_view()
    operand_low = view["copied_attribute_ordinary"]
    last_bound = operand_low+2
    high = operand_low+4
    null_low = 4+last_bound+operand_low
    null_high = 4+last_bound+high
    raw_lists = 2*view["copied_lists"]+1
    raw_entities = 2*view["copied_entities"]
    copies = 4*n+4
    duplications = 2*n+2
    total = dict(
        ordinary=copies*null_high+duplications*view["copied_ordinary"],
        entities_and_names=copies*raw_entities+duplications*view["copied_entities"],
        lists=copies*raw_lists+duplications*view["copied_lists"],
        pending_elist_headers=copies*2+duplications,
        pending_elist_elements=copies*4+duplications*2,
        hash_wrappers=copies*6+duplications*3,
        name_characters=13*(copies*raw_entities+duplications*view["copied_entities"]),
        growth=0, uint=0)
    assert (operand_low, last_bound, high, null_low, null_high,
            raw_entities, raw_lists) == (67, 69, 71, 140, 144, 4, 11)
    assert total == dict(ordinary=708*n+708, entities_and_names=20*n+20,
                        lists=54*n+54, pending_elist_headers=10*n+10,
                        pending_elist_elements=20*n+20, hash_wrappers=30*n+30,
                        name_characters=260*n+260, growth=0, uint=0)
    return dict(operands=n, raw_operand_low=operand_low,
                raw_last_bound=last_bound, raw_high_before_null=high,
                raw_null_low=null_low, raw_null_high=null_high,
                raw_copy_entities=raw_entities, raw_copy_lists=raw_lists,
                direct_remaining_copies=copies, direct_duplications=duplications,
                total=total)


def native_query_weight(kind, children=(), initializer=None, bounds=None,
                        fixed=None, literal_last=False):
    """Weights of specified scalar input shape, never a GNAT invocation.

    Children/initializers/bounds are previously derived summaries. Reusing a
    summary does not suppress its weight: sums count every incoming edge.
    `fixed` is one Compare_Fixup result, not a transitive fixup closure.
    """
    local = {"plus": 0, "minus": 2, "add": 2, "subtract": 4,
             "multiply": 6, "conversion": 0}
    if kind == "internal_constant":
        assert initializer is not None
        demand = (initializer,)
        local_uint = 0
    elif kind in local:
        demand = children
        local_uint = local[kind]
    elif kind == "length":
        assert bounds is not None and len(bounds) == 2
        demand = bounds
        local_uint = 6
    else:
        demand = ()
        local_uint = 0
    d = 1+sum(child["D"] for child in demand)
    u = local_uint+sum(child["U"] for child in demand)
    fixed_kind = kind if fixed is None else fixed["kind"]
    fixed_children = children if fixed is None else fixed["children"]
    same_children = (fixed_children if fixed_kind in
                     ("plus", "minus", "add", "subtract", "multiply") else ())
    s = 1+sum(child["S"] for child in same_children)
    f = int(literal_last)+sum(child["F"] for child in same_children)
    assert u <= 6*d and f <= s
    return dict(kind=kind, children=tuple(children), D=d, U=u, S=s, F=f)


def native_query_weight_examples():
    leaf = native_query_weight("literal")
    first = native_query_weight("first", fixed=leaf)
    last = native_query_weight("last", fixed=leaf, literal_last=True)
    length = native_query_weight("length", bounds=(leaf, leaf))
    saved_length = native_query_weight("internal_constant", initializer=length)
    sum_expr = native_query_weight("add", children=(saved_length, saved_length))
    selected = native_query_weight("conditional", children=(leaf, sum_expr, sum_expr))
    captured = native_query_weight("internal_constant", initializer=selected)
    saved_ewa = native_query_weight("internal_constant",
                                    initializer=native_query_weight("ewa"))
    fixed_sum = native_query_weight("last", fixed=sum_expr)
    cases = dict(leaf=leaf, first=first, literal_last=last, length=length,
                 saved_length=saved_length, repeated_saved_length_sum=sum_expr,
                 conditional=selected, captured_conditional=captured,
                 captured_ewa=saved_ewa, last_fixed_to_arithmetic=fixed_sum)
    assert (sum_expr["D"], sum_expr["U"], sum_expr["S"], sum_expr["F"]) == (9, 14, 3, 0)
    assert (captured["D"], captured["U"], captured["S"], captured["F"]) == (2, 0, 1, 0)
    assert (fixed_sum["D"], fixed_sum["S"]) == (1, 3)
    return {name: {key: value[key] for key in ("D", "U", "S", "F")}
            for name, value in cases.items()}


def native_string_bound_descriptor(kind, operands=(), initializer=None):
    """Conservative D weights for original String index bounds only.

    This source-shape envelope is not all query roots, a GNAT simulator or
    an admission predicate. Exact supplied graph summaries may be smaller.
    Repeated alias operands contribute their weight on every use.
    """
    if kind == "literal":
        return dict(low_D=1, high_D=1)
    if kind == "image":
        return dict(low_D=1, high_D=2)
    if kind == "input":
        return dict(low_D=2, high_D=2)
    if kind == "alias":
        assert initializer is not None
        return {key: initializer[key] for key in ("low_D", "high_D")}
    assert kind == "concat" and len(operands) >= 2
    assert all(op["low_D"] >= 1 and op["high_D"] >= 1 for op in operands)
    n = len(operands)
    saved_lengths = [op["low_D"] + op["high_D"] + 2 for op in operands]
    aggregate_D = sum(saved_lengths) + 2*(n-1)
    low_D = max(2, 2+max(op["low_D"] for op in operands))
    high_D = aggregate_D+low_D+5
    assert high_D >= max(op["high_D"]+2 for op in operands)
    return dict(low_D=low_D, high_D=high_D, aggregate_D=aggregate_D,
                saved_length_D=saved_lengths)


def native_string_bound_examples():
    literal = native_string_bound_descriptor("literal")
    image = native_string_bound_descriptor("image")
    input_value = native_string_bound_descriptor("input")
    alias = input_value
    for _ in range(100):
        alias = native_string_bound_descriptor("alias", initializer=alias)
    assert alias == input_value
    concat = native_string_bound_descriptor("concat", (input_value, image))
    repeated = native_string_bound_descriptor("concat", (concat, concat))
    assert concat == dict(low_D=4, high_D=22, aggregate_D=13,
                          saved_length_D=[6, 5])
    assert repeated == dict(low_D=6, high_D=69, aggregate_D=58,
                            saved_length_D=[28, 28])
    # A binary source-tree envelope dominates flattened native operand groups.
    # Check representative arbitrary bound descriptors and both associations;
    # the report supplies the monotone arithmetic argument for general n.
    for n in (2, 3, 9, 10, 64):
        operands = [dict(low_D=1+j%5, high_D=2+j*j) for j in range(n)]
        flat = native_string_bound_descriptor("concat", operands)
        left = operands[0]
        for op in operands[1:]:
            left = native_string_bound_descriptor("concat", (left, op))
        right = operands[-1]
        for op in reversed(operands[:-1]):
            right = native_string_bound_descriptor("concat", (op, right))
        for tree in (left, right):
            assert tree["low_D"] >= flat["low_D"]
            assert tree["high_D"] >= flat["high_D"]
    return dict(literal=literal, image=image, input=input_value,
                hundred_aliases=alias, input_concat_image=concat,
                repeated_concat_aliases=repeated)


def native_concat_query_roots(operands):
    """Source-backed query-weight bound for the combined concat stages only."""
    descriptor = native_string_bound_descriptor("concat", operands)
    h = descriptor["high_D"]
    low = descriptor["low_D"]
    aggregate = descriptor["aggregate_D"]
    assert h >= 18
    assert all(max(op["low_D"], op["high_D"]) <= h for op in operands)
    assert max(descriptor["saved_length_D"]) <= aggregate <= h
    assert low+aggregate+1+1 <= h  # assignment low and optional capture
    assert low+aggregate+3+1 <= h  # assignment high and optional capture
    roots = {
        "original_bounds_lengths_and_aggregates": h,
        "assignment_endpoints_including_captures": h,
        "fixed_scalar_type_endpoint": 1,
        "First_Last_or_replacement_bound_constant": h,
        "regular_conversion_of_bound": h+1,
        "check_Length": 1+2*h,
        "regular_conversion_of_check_Length": 2+2*h,
    }
    # Although unchecked conversions are Determine_Range leaves, charging
    # one recursive layer gives these conservative optimizer arithmetic sums.
    double_length = 2+3*(h+1)
    general_comp = 2+(h+1)+(roots["regular_conversion_of_check_Length"]+1)+1
    assert double_length == 3*h+5
    assert general_comp == 3*h+7
    roots["optimized_double_Length_arithmetic"] = double_length
    roots["optimized_general_Comp_arithmetic"] = general_comp
    same_value = 2+3*5
    a = 3*h+7
    assert max(roots.values()) <= a and same_value <= a
    return dict(source_descriptor=descriptor, root_D_envelopes=roots,
                max_S=same_value, A=a, whole_construct_closed=False)


def raw_bound_semantics(n, analysis_graph):
    """First scalar passes outside copied, already resolved String prefixes."""
    assert n >= 2 and analysis_graph >= 1
    a = analysis_graph
    rows = {
        "three_additions_or_subtractions": dict(ordinary=6, uint=18*a+6,
                                                 growth=3, lists=0),
        "two_same_Integer_conversions": dict(ordinary=4, uint=12*a,
                                              growth=2, lists=0),
        "two_First_Last_attributes": dict(ordinary=4, uint=0, growth=2, lists=0),
        "one_Eq": dict(ordinary=40*a+5, uint=160*a+120, growth=2, lists=1),
        "one_scalar_conditional": dict(ordinary=2, uint=0, growth=1, lists=0),
    }
    per_copy = {key: sum(row[key] for row in rows.values())
                for key in ("ordinary", "uint", "growth", "lists")}
    assert per_copy == dict(ordinary=40*a+21, uint=190*a+126,
                            growth=10, lists=1)
    total = {key: (4*n+4)*value for key, value in per_copy.items()}
    # Two first result-storage bound captures; slice captures already belong
    # to the separately charged slice-resolution transfer.
    total["ordinary"] += 10
    total["lists"] += 2
    total.update(entities_and_names=2, name_characters=26)
    return dict(operands=n, analysis_graph=a, rows_per_copy=rows,
                total_per_copy=per_copy, raw_copies=4*n+4, total=total)


def native_runtime_concat_call(n):
    """Local call processing; runtime spec is already charged/frozen."""
    assert n >= 2
    return dict(operands_envelope=n, actual_helper_arity_limit=9,
                total=dict(ordinary=n, lists=n+2, positive_xref_increments=n),
                no_new_scalar_query_roots=True)


def source_concat_folding(concat_length_bounds):
    """Semantic concat/literal suffix; excludes source operand constructors."""
    assert all(0 <= length <= 2**31-1 for length in concat_length_bounds)
    c = len(concat_length_bounds)
    # At most 2*c original literal-operand resolutions, c folded-result
    # resolutions, and 2*c explicit post-concat literal-subtype creations.
    resolving_literals = 3*c
    direct_subtypes = 2*c
    total = dict(ordinary=2*c, growth=c,
                 entities_and_names=resolving_literals+direct_subtypes,
                 name_characters=13*(resolving_literals+direct_subtypes),
                 uint=6*resolving_literals+2*direct_subtypes,
                 string_descriptors=c,
                 string_characters=sum(concat_length_bounds), lists=0)
    assert total["entities_and_names"] == 5*c and total["uint"] == 22*c
    slots = 9*(total["ordinary"]+total["growth"])+61*total["entities_and_names"]
    assert slots == 332*c
    return dict(source_concat_operators=c, source_concat_length_bounds=concat_length_bounds,
                total=total, dynamic_slots=slots,
                max_local_uint_magnitude=8*(2**31-1), uint_digits_per_append=3,
                whole_construct_closed=False)


def native_concat_numeric_magnitude(n, analysis_graph):
    """Numeric closure for combined native stages, not source scalar analysis."""
    assert 2 <= n <= 2**31-2 and analysis_graph >= 1
    a = analysis_graph
    incoming_index_magnitude = 2**31
    direct = n*max(2*incoming_index_magnitude+1, 256)+incoming_index_magnitude+1
    scalar_seed = 2**127
    assert direct < 2**63 <= scalar_seed
    range_magnitude = scalar_seed*a
    comparison_magnitude = 2*range_magnitude+1
    first_size_magnitude = 8*(2*range_magnitude+1)
    magnitude = (16*a+8)*scalar_seed
    assert max(direct, range_magnitude, comparison_magnitude,
               first_size_magnitude, 2**126) <= magnitude
    k = uint_digits(magnitude)
    uint_appends = combined_native_emitter_vector(n, a)["total"]["uint"]
    return dict(operands=n, A=a, scalar_seed_magnitude=scalar_seed,
                direct_arithmetic_magnitude=direct,
                Determine_Range_magnitude=range_magnitude,
                comparison_magnitude=comparison_magnitude,
                first_size_magnitude=first_size_magnitude,
                all_closed_stage_magnitude=magnitude,
                base_32768_digits=k, Uint_appends=uint_appends,
                retained_digit_words=k*uint_appends,
                max_local_arithmetic_digit_vectors=5*k+3,
                whole_construct_closed=False)


def local_name_qualification(scope_path_name_lengths, queued_scopes):
    """One-time qualification of Main/types; no debug-renaming/homonym route."""
    assert queued_scopes >= 0
    assert all(path and all(length >= 1 for length in path)
               for path in scope_path_name_lengths)
    qualified_lengths = [sum(path)+2*(len(path)-1)
                         for path in scope_path_name_lengths]
    return dict(qualified_scope_paths=scope_path_name_lengths,
                qualified_name_length_bounds=qualified_lengths,
                total=dict(name_entries=len(qualified_lengths),
                           name_characters=sum(length+1 for length in qualified_lengths),
                           Name_Qualify_Units_appends=queued_scopes),
                max_name_buffer_characters=max(qualified_lengths, default=0),
                fixed_Homonym_Numbers_used=0,
                full_qualification_local_buffer="Name_Buffer'Length characters",
                whole_construct_closed=False)


def output_transient_wrapper(output_calls, parent_scope_depth):
    """Ordinary non-secondary output wrapper, excluding its priced children."""
    assert output_calls >= 0 and 0 <= parent_scope_depth < 2**31-1
    depth = parent_scope_depth+1
    k = max(1, (depth.bit_length()+14)//15)
    fixed_names = ("system.finalization_primitives%s", "standard%s")
    # Is_RTE is nonloading but its name lookups can intern these two names.
    # Name_Find retains at most one copy of either throughout the process.
    fixed_count = len(fixed_names) if output_calls else 0
    fixed_chars = sum(len(name)+1 for name in fixed_names) if output_calls else 0
    return dict(output_call_envelope=output_calls,
                parent_scope_depth_envelope=parent_scope_depth,
                total=dict(ordinary=5*output_calls, growth=output_calls,
                           entities=output_calls, name_entries=output_calls+fixed_count,
                           name_characters=13*output_calls+fixed_chars,
                           lists=2*output_calls, uint=output_calls,
                           retained_digit_words=k*output_calls,
                           Name_Qualify_Units_appends=output_calls,
                           dynamic_slots=115*output_calls),
                fixed_names=fixed_names,
                additional_peak_scope_entries=1 if output_calls else 0,
                child_analysis_replay=False,
                cleanup_or_finalizer_generated=False,
                whole_local_wrapper_closed=True,
                whole_construct_closed=False)


def native_integer_image(image_count):
    """Integer Image expansion after the original scalar argument is resolved."""
    assert image_count >= 0
    a = 17  # static buffer endpoints and the closed check's same-value spine
    rows = {
        "direct_emitter": dict(ordinary=24, growth=1, entities_and_names=2,
                               name_characters=26, lists=3),
        "Width_and_extra_static_leaf_folds": dict(ordinary=10, growth=5, uint=12),
        "suppressed_same_base_scalar_conversion": dict(ordinary=2, growth=1),
        "buffer_subtype_and_first_freezes": result_storage(3, 0, a)["plain"],
        "returned_slice": suppressed_slice_resolution(3, 0, a)["total"],
        "three_actual_call_and_optional_marker": dict(ordinary=4, lists=6,
                                                       positive_xref_increments=3),
    }
    keys = sorted(set().union(*(row.keys() for row in rows.values())))
    per_image = {key: sum(row.get(key, 0) for row in rows.values()) for key in keys}
    assert per_image == dict(ordinary=2528, growth=32, entities_and_names=8,
                             name_characters=111, lists=16, uint=10667,
                             elists=0, positive_xref_increments=3)
    slots = 9*(per_image["ordinary"]+per_image["growth"])+61*per_image["entities_and_names"]
    assert slots == 23528
    magnitude = (16*a+8)*2**127
    digits = (magnitude.bit_length()+14)//15
    assert digits == 10
    return dict(source_Image_count=image_count, local_query_A=a,
                rows_per_Image=rows, per_Image=per_image,
                total={key: image_count*value for key, value in per_image.items()},
                dynamic_slots=image_count*slots,
                generated_Uint_magnitude=magnitude, Uint_digits_per_append=digits,
                retained_digit_words=image_count*per_image["uint"]*digits,
                source_scalar_argument_replayed=False,
                normalized_result_bound_descriptor=dict(low_D=1, high_D=2),
                whole_local_constructor_closed=True, whole_construct_closed=False)


def source_scalar_arithmetic(source_ops, loop_ops, source_names, loop_names,
                             raw_loop_nodes, largest_scalar_tree):
    assert 0 <= loop_ops <= source_ops
    assert 0 <= loop_names <= source_names
    assert raw_loop_nodes >= 0 and largest_scalar_tree >= 1
    visits = source_ops + 2 * loop_ops
    names = source_names + 2 * loop_names
    a = largest_scalar_tree + 1
    k = (130 * a + 2 + 14) // 15
    uint = (12 * a + 3) * visits
    nodes = 2 * raw_loop_nodes + 4 * visits + 3 * names
    growth = 2 * visits + names
    return dict(source_operators=source_ops, loop_bound_operators=loop_ops,
                source_scalar_names=source_names, loop_bound_names=loop_names,
                raw_loop_nodes=raw_loop_nodes,
                largest_scalar_tree=largest_scalar_tree, A=a,
                operator_visits=visits, name_visits=names,
                ordinary_nodes=nodes, growth=growth,
                Uint_appends=uint, Uint_digits=k * uint,
                digits_per_Uint=k, dynamic_slots=9 * (nodes + growth),
                entities=0, syntax_lists=names, String_values=0,
                whole_construct_closed=False)


def source_for_loop_skeleton(loop_count, largest_scalar_tree):
    assert loop_count >= 0 and largest_scalar_tree >= 1
    a = largest_scalar_tree + 1
    captures = 2 * loop_count
    nodes = (120 * a + 40) * loop_count + 5 * captures
    uint = (480 * a + 455) * loop_count
    entities = loop_count + captures
    growth = 3 * loop_count
    return dict(source_loops=loop_count, A=a, capture_allowance=captures,
                ordinary_nodes=nodes, syntax_lists=captures+2*loop_count,
                growth=growth, entities=entities, names=entities,
                name_characters=13*entities, Uint_appends=uint,
                digits_per_Uint=(130*a+2+14)//15,
                dynamic_slots=9*(nodes+growth)+61*entities,
                source_condition_comparison_queries=6*loop_count,
                runtime_trip_count_multiplier=1,
                whole_construct_closed=False)


def source_integer_stores(declarations, assignments, constraints,
                          constrained_name_chars, largest_scalar_tree):
    assert 0 <= constraints <= declarations and assignments >= 0
    assert constrained_name_chars >= constraints and largest_scalar_tree >= 1
    a = largest_scalar_tree + 1
    h = declarations + assignments
    c = 2 * declarations + assignments
    q = 2 * c + 2 * declarations + 3 * constraints + 7 * h
    nodes = 20 * a * q + 7 * constraints + 51 * h + declarations
    growth = 2 * constraints + 16 * h
    entities = constraints + h
    uint = 6 * a * c + (80 * a + 60) * q + 190 * constraints
    return dict(Integer_declarations=declarations, Integer_assignments=assignments,
                explicit_constraints=constraints, A=a, possible_checks=h,
                scalar_check_calls=c, comparison_queries=q,
                ordinary_nodes=nodes, growth=growth,
                syntax_lists=2*constraints+3*h+declarations,
                entities=entities, names=entities,
                name_characters=constrained_name_chars+3*constraints+13*h,
                Uint_appends=uint, digits_per_Uint=(130*a+2+14)//15,
                dynamic_slots=9*(nodes+growth)+61*entities,
                whole_construct_closed=False)


def source_predicates_and_control(comparisons, short_circuits, negations,
                                 if_count, elsif_count, analysis_graph,
                                 incoming_scope_depth):
    assert min(comparisons, short_circuits, negations, if_count, elsif_count,
               incoming_scope_depth) >= 0 and analysis_graph >= 1
    a = analysis_graph
    nodes = ((440*a+144)*comparisons + 18*short_circuits + 2*negations
             + 2*if_count + 3*elsif_count)
    growth = 39*comparisons+5*short_circuits+negations+if_count+elsif_count
    entities = 4*short_circuits
    query_uint = (1868*a+1742)*comparisons
    return dict(comparisons=comparisons, short_circuits=short_circuits,
                negations=negations, ifs=if_count, elsifs=elsif_count, A=a,
                ordinary_nodes=nodes, growth=growth,
                syntax_lists=4*comparisons+short_circuits+2*elsif_count,
                entities=entities, names=entities, name_characters=13*entities,
                query_Uint_appends=query_uint,
                query_digits_per_Uint=(130*a+2+14)//15,
                scope_Uint_appends=2*short_circuits,
                scope_Uint_magnitude=incoming_scope_depth+2*short_circuits,
                dynamic_slots=9*(nodes+growth)+61*entities,
                whole_construct_closed=False)


def source_string_stores(declarations, assignments, declaration_name_chars,
                         analysis_graph):
    """Excludes first input declaration and first analysis of source operands."""
    assert min(declarations, assignments) >= 0
    assert declaration_name_chars >= declarations and analysis_graph >= 1
    a = analysis_graph
    declaration = dict(ordinary=140*a+134, growth=30, lists=11,
                       entities_and_names=4, uint=620*a+567)
    assignment = dict(ordinary=940*a+358, growth=84, lists=18,
                      entities_and_names=2, uint=3976*a+3763)
    total = {key: declarations*declaration[key]+assignments*assignment[key]
             for key in declaration}
    total["name_characters"] = (2*declaration_name_chars+48*declarations
                                +29*assignments)
    total["dynamic_slots"] = (9*(total["ordinary"]+total["growth"])
                              +61*total["entities_and_names"])
    return dict(later_String_declarations=declarations,
                String_assignments=assignments, A=a,
                declaration_per_occurrence=declaration,
                assignment_per_occurrence=assignment, total=total,
                declaration_debug_Uint_allowance=42*declarations,
                debug_name_buffer_peak=32,
                whole_construct_closed=False)


def source_string_literal_suffix(literals, dynamic_assignment_literals,
                                analysis_graph):
    """Literal resolutions outside concat; dynamic-low RHS continuation."""
    assert 0 <= dynamic_assignment_literals <= literals and analysis_graph >= 1
    a = analysis_graph
    # All resolutions receive the static suffix, and each possibly dynamic
    # one additionally receives the complete dynamic branch (overcounting it).
    dynamic = dict(ordinary=42, growth=4, lists=6,
                   entities_and_names=3, name_characters=39, uint=6*a+12)
    total = {key: dynamic_assignment_literals*value
             for key, value in dynamic.items()}
    total["entities_and_names"] += literals
    total["name_characters"] += 13*literals
    total["uint"] += 6*literals
    total["dynamic_slots"] = (9*(total["ordinary"]+total["growth"])
                              +61*total["entities_and_names"])
    return dict(nonconcat_literal_resolutions=literals,
                possibly_dynamic_assignment_literals=dynamic_assignment_literals,
                A=a, dynamic_branch=dynamic, total=total,
                normalized_copied_low_nodes=12,
                normalized_copied_low_lists=1,
                new_String_values=0, whole_construct_closed=False)


def source_calls_and_leaf_bookkeeping(calls, word_tokens, literals,
                                     parser_flattenings):
    """Core syntax only; all source argument constructors are separate rows."""
    assert min(calls, word_tokens, literals, parser_flattenings) >= 0
    return dict(ordinary=word_tokens+2*calls, lists=word_tokens+3*calls,
                growth=3*calls+literals+2*parser_flattenings,
                entities_and_names=0, name_characters=0, uint=0)


def main_native_query_envelope(largest_scalar_tree, string_bound_descriptors):
    """Source descriptor join, including direct-literal assignment subtypes.

    Descriptors cover every source String expression and declared object;
    aliases preserve their initializer descriptor, assignments preserve the
    object's subtype. The extra two visits cover a direct assignment literal's
    generated upper bound low+(length-1), even before it is folded.
    """
    assert largest_scalar_tree >= 1
    assert all(min(value["low_D"], value["high_D"]) >= 1
               for value in string_bound_descriptors)
    source_h = max([2]+[value[key] for value in string_bound_descriptors
                           for key in ("low_D", "high_D")])
    h = source_h+2
    scalar_a = largest_scalar_tree+1
    roots = dict(source_scalar=scalar_a, String_index_bounds=h,
                 String_Length=2*h+1, converted_String_Length=2*h+2,
                 optimized_String_Length=3*h+7, String_same_value=17,
                 Image_local=17)
    a = max(roots.values())
    assert h >= source_h+2 and a >= max(17, scalar_a, 3*h+7)
    return dict(source_bound_H=source_h, effective_bound_H=h,
                root_envelopes=roots, A=a,
                descriptors_are_source_input=True,
                whole_native_frontend_closed=False)


def main_native_construct_vector(*, parser_nodes, parser_slots, parser_lists,
        parser_entities, source_ops, loop_ops, scalar_names, loop_names,
        raw_loop_nodes, largest_scalar_tree, loops, Integer_declarations,
        Integer_assignments, Integer_constraints, constrained_name_chars,
        String_declarations, String_assignments, String_name_chars,
        nonconcat_literals, dynamic_assignment_literals, comparisons,
        short_circuits, negations, ifs, elsifs, images, output_calls,
        source_calls, word_tokens, source_literals, parser_flattenings,
        concat_lengths, String_bound_descriptors, incoming_scope_depth):
    """One executable sum of Main constructor rows, before process residuals.

    Parser/scanner allocation inputs come from the existing table/value
    components. Parser identities already include defining-name promotions;
    generated entities below are fresh identities and must be added to nodes.
    """
    assert min(parser_nodes, parser_slots, parser_lists, parser_entities) >= 0
    query = main_native_query_envelope(largest_scalar_tree,
                                       String_bound_descriptors)
    analysis_graph = query["A"]
    rows = {}
    def add(name, value, aliases=None):
        aliases = aliases or {}
        rows[name] = {aliases.get(key, key): val for key, val in value.items()}
    aliases = {"ordinary_nodes": "ordinary", "syntax_lists": "lists",
               "entities": "entities_and_names", "Uint_appends": "uint"}
    def standard(value):
        return {aliases.get(key, key): value[key] for key in
                ("ordinary_nodes", "syntax_lists", "growth", "entities",
                 "name_characters", "Uint_appends") if key in value}
    scalar = source_scalar_arithmetic(source_ops, loop_ops, scalar_names,
                                     loop_names, raw_loop_nodes,
                                     largest_scalar_tree)
    add("original_scalar", standard(scalar))
    add("for_skeleton", standard(source_for_loop_skeleton(loops,
                                                         largest_scalar_tree)))
    add("Integer_stores", standard(source_integer_stores(Integer_declarations,
        Integer_assignments, Integer_constraints, constrained_name_chars,
        largest_scalar_tree)))
    add("String_stores", source_string_stores(String_declarations,
        String_assignments, String_name_chars, analysis_graph)["total"])
    add("standalone_String_literals", source_string_literal_suffix(nonconcat_literals,
        dynamic_assignment_literals, analysis_graph)["total"])
    predicate = source_predicates_and_control(comparisons, short_circuits,
        negations, ifs, elsifs, analysis_graph, incoming_scope_depth)
    pred_row = standard(predicate)
    pred_row["uint"] = predicate["query_Uint_appends"]+predicate["scope_Uint_appends"]
    add("predicates_and_control", pred_row)
    add("Image", native_integer_image(images)["total"])
    output = output_transient_wrapper(output_calls, incoming_scope_depth)["total"]
    add("output_wrappers", output, {"entities": "entities_and_names"})
    add("source_calls_and_leaves", source_calls_and_leaf_bookkeeping(
        source_calls, word_tokens, source_literals, parser_flattenings))
    add("concat_emission", combined_native_uniform_vector(
        len(concat_lengths), analysis_graph)["total"])
    add("concat_folding_literals", source_concat_folding(concat_lengths)["total"])
    keys = ("ordinary", "growth", "lists", "entities_and_names",
            "name_characters", "uint", "string_descriptors", "string_characters",
            "pending_elist_headers", "pending_elist_elements", "hash_wrappers",
            "positive_xref_increments", "Name_Qualify_Units_appends")
    total = {key: sum(row.get(key, 0) for row in rows.values()) for key in keys}
    generated = total["entities_and_names"]
    # Output wrappers intern two fixed names on their first possible use.
    extra_fixed_names = 2 if output_calls else 0
    total["generated_name_entries"] = generated+extra_fixed_names
    total["node_identities"] = parser_nodes+total["ordinary"]+generated
    total["entity_identities"] = parser_entities+generated
    total["dynamic_slots"] = (parser_slots+9*(total["ordinary"]+total["growth"])
                              +61*generated)
    total["syntax_list_headers"] = parser_lists+total["lists"]
    # This common digit bound deliberately covers multiplicative source scalar
    # queries as well as the smaller additive String-bound and scope values.
    k = max(3, (130*analysis_graph+2+14)//15,
            uint_digits(incoming_scope_depth+2*short_circuits+output_calls+1))
    total["retained_digit_words"] = k*total["uint"]
    return dict(rows=rows, total=total, source_query_envelope=query,
                common_Uint_digit_bound=k,
                scope="Main source/generated constructor core, before fixed and common-process residuals",
                whole_native_frontend_closed=False)


def native_common_metadata(*, concats, words, short_circuits, images,
        output_calls, loop_depth, max_identifier_length, main_entities,
        fixed_entities, fixed_xrefs, newly_analyzed_units):
    """Native overload/xref/qualification/unit-boundary metadata join.

    All counts are source or previously derived component inputs; none is an
    observed program threshold. Fixed dependency entities/xrefs and unit closure
    remain integration inputs. This does not include invocation/diagnostics.
    """
    assert min(concats, words, short_circuits, images, output_calls, loop_depth,
               max_identifier_length, main_entities, fixed_entities,
               fixed_xrefs, newly_analyzed_units) >= 0
    entities = main_entities+fixed_entities
    # Permanent variable scopes: source loops, at most two EWA scopes per
    # source short circuit and one output wrapper along a scope path. Include
    # the one fixed Main finalizer as an extra conservative path member.
    scopes = loop_depth+2*short_circuits+bool(output_calls)+1
    unqualified = max(12, max_identifier_length+5)
    qualified = 6+14*scopes+unqualified
    explicit_xrefs = 2*concats+3*images
    xrefs = fixed_xrefs+16*(words+1)+2*entities+explicit_xrefs+1
    return dict(
        All_Interp_Main_entries=4*concats+3*words+short_circuits,
        Interp_Map_Main_bindings=concats+2*words+short_circuits,
        qualification_Name_entries=main_entities,
        qualification_Name_characters=main_entities*(qualified+1),
        max_unqualified_name=unqualified,
        max_qualified_name=qualified,
        qualification_scope_path_members=scopes+2,
        Name_Qualify_Units_Main_appends=output_calls+2,
        Xrefs_backing_demand=xrefs,
        Xref_sort_vector_Nat_words=xrefs+1,
        Drefs_Main_appends=0,
        unit_boundary_Elist_headers=newly_analyzed_units+1,
        unit_boundary_Elist_elements=newly_analyzed_units*(entities+1),
        fixed_input_name_character_correction="4*(input_identifier_length-1), when present; separate from this variable-entity qualification addend",
        whole_native_frontend_closed=False)


def native_invocation_metadata(source_calls, words, concats, images,
                               fixed_AST_bound):
    """Main-only invocation/elaboration join for the pinned target frontier.

    fixed_AST_bound is the source-reduced fixed native node bound, not a new
    measurement. It overcounts every fixed-scaffold marker and the dummy root.
    """
    assert min(source_calls, words, concats, images, fixed_AST_bound) >= 0
    source_names = ("silver_io__put", "silver_io__put_line",
                    "silver_arguments__input_is_valid",
                    "silver_arguments__first_or_default",
                    "silver_arguments__reject")
    native_names = ("main", "main___finalizer", "system__img_int__image_integer",
                    "system__secondary_stack__ss_allocate",
                    "system__secondary_stack__ss_mark",
                    "system__secondary_stack__ss_release")
    names = source_names+native_names+tuple(
        f"system__concat_{n}__str_concat_{n}" for n in range(2, 10))
    target_count = len(names)
    assert target_count == 19 and max(map(len, names)) == 36
    # Runtime targets are excluded from actual invocation signatures by
    # In_Internal_Unit. Their interface spellings only enlarge the allowance;
    # no assumption about the Image generic alias's canonical name is needed.
    # Get_Qualified_Name(scope) may see an already qualified child-package
    # spelling and prefix its parent again; pay that extra System prefix.
    scopes = ("standard", "main", "silver_io", "silver_arguments",
              "system__system__img_int", "system__system__secondary_stack")
    max_scope = max(map(len, scopes))
    assert max_scope == 31
    marker_bound = source_calls+concats+images+fixed_AST_bound
    sig_chars = 36+max_scope+2*10+4+6  # names, Nat line/column, none, delimiters
    relations = target_count**2
    return dict(target_frontier=names,
        Scenario_Reps_Main_entries=marker_bound,
        Node_To_Scenario_Main_bindings=marker_bound,
        Target_Reps_Main_entries=target_count,
        Entity_To_Target_Main_bindings=target_count,
        Declaration_Scenarios_Main_members=marker_bound,
        Dynamic_ABE_Check_Main_members=0,
        Library_Body_Main_members=0, Library_Spec_Main_members=0,
        SPARK_Main_members=0, Early_Call_Regions_Main_bindings=0,
        Unit_To_Attributes_Main_bindings=0,
        Active_Scenario_Stack_Main_peak=3,
        Nested_Scenarios_Main_bindings=2,
        Nested_Scenario_list_headers=2,
        Nested_Scenario_list_elements=2*(marker_bound+words),
        Traversed_Bodies_Main_peak=2,
        Traversed_Bodies_Main_lifetime_insertions=4,
        Saved_Constructs_Main_members=target_count,
        Saved_Relations_Main_members=relations,
        ALI_Invocation_Constructs=target_count,
        ALI_Invocation_Relations=relations,
        ALI_Invocation_Signatures=target_count,
        ALI_Signature_Map_bindings=target_count,
        signature_scope_Name_entries=target_count,
        signature_scope_Name_characters=target_count*(max_scope+1),
        signature_scope_Name_buffer_peak=max_scope,
        instantiation_location_names=0,
        max_serialized_signature_characters=sig_chars,
        invocation_ALI_characters=20+(target_count+relations)*(2*sig_chars+48),
        signature_location_local_buffer=2052,
        additional_Uint_appends=0,
        whole_native_frontend_closed=False)


def native_stack_peaks(*, main_nodes, main_lists, loop_depth, short_circuits,
                       output_calls, fixed_scope_pushes=1117,
                       fixed_expander_pushes=520, fixed_lists=6526):
    """Logical stack peaks; fixed lifetime captures safely dominate fixed peaks.

    Fixed arguments require the source root/freezing reduction. Main node/list
    counts are the complete constructor vector, not the final surviving tree.
    Physical Ada call-stack bytes are a separate representation obligation.
    """
    assert min(main_nodes, main_lists, loop_depth, short_circuits, output_calls,
               fixed_scope_pushes, fixed_expander_pushes, fixed_lists) >= 0
    permanent = loop_depth+2*short_circuits+bool(output_calls)
    return dict(
        Scope_Stack_live_entries=fixed_scope_pushes+permanent+2,
        Scope_Stack_variable_permanent=permanent,
        Scope_Stack_temporary_freeze_allowance=2,
        Expander_Flags_live_entries=fixed_expander_pushes+main_nodes+1,
        Saved_Checks_TOS_peak=fixed_lists+main_lists+1,
        Saved_Checks_Main_records=0,
        Saved_Checks_fixed_records=200,
        Saved_Checks_Stack_fixed_Nat_words=100,
        semantic_scope_depth_additional_Uints=0,
        counters_require_signed_Int_headroom=True,
        physical_call_stack_bytes_included=False,
        whole_native_frontend_closed=False)


def native_diagnostic_metadata(source_loops, source_with_names):
    """Frontend warning attempts under default native warning flags."""
    assert min(source_loops, source_with_names) >= 0
    attempts = 2*source_loops+source_with_names
    # Column_Number'Last is the pinned Types value, not a source line limit.
    assert "type Column_Number is range 0 .. 32767;" in sources["types.ads"]
    column_last = 2**15-1
    message_length = 1024+2*column_last
    return dict(attempts=attempts,
        Non_Instance_Msgs_Main_appends=attempts,
        Errors_Main_appends=attempts, Locations_Main_appends=attempts,
        raw_history_characters=64*attempts,
        formatted_text_lifetime_characters=(2*message_length+2)*attempts,
        diagnostic_string_requests=2*attempts,
        continuation_join_local_characters=2*message_length+2,
        formatted_message_buffer_characters=message_length,
        Edits_Main_appends=0, Fixes_Main_appends=0, nonempty_label_requests=0,
        Unreferenced_Entities_Main_appends=0, In_Out_Warnings_Main_appends=0,
        Warnings_Main_appends=0, Specific_Warnings_Main_appends=0,
        Warnings_As_Errors_Main_appends=0, additional_Uint_appends=0,
        backend_and_fixed_dependency_diagnostics_included=False,
        whole_native_frontend_closed=False)


def combined_native_emitter_vector(n, analysis_graph):
    """Closed local emitter; source constructors/runtime load/scope excluded."""
    a = analysis_graph
    first = direct_scalar_and_storage_concat(n, 28, 2, a)["total"].copy()
    first["pending_elist_headers"] = first.pop("elists")
    copies = direct_native_copy_costs(n)["total"]
    assignments = {key: n*value for key, value in
                   suppressed_slice_resolution(31, 2, a)["with_assignment_check_suffix"].items()}
    rows = dict(direct_scalar_storage=first, remaining_copies=copies,
                up_to_n_suppressed_slice_assignments=assignments,
                up_to_n_referenced_input_actual_subtypes={
                    key: n*value for key, value in
                    uncached_dereference_actual_subtype(a)["total"].items()},
                raw_bound_semantics=raw_bound_semantics(n, a)["total"],
                enabled_final_slice=enabled_final_slice(31, 2, a)["total"],
                native_runtime_concat_call=native_runtime_concat_call(n)["total"])
    keys = sorted(set().union(*(row.keys() for row in rows.values())))
    total = {key: sum(row.get(key, 0) for row in rows.values()) for key in keys}
    assert total == dict(ordinary=(900*n+520)*a+1252*n+1198,
                        uint=(3816*n+2296)*a+3696*n+1697,
                        lists=76*n+95, growth=139*n+99,
                        entities_and_names=28*n+32, name_characters=367*n+423,
                        pending_elist_headers=10*n+11,
                        pending_elist_elements=20*n+20, hash_wrappers=30*n+30,
                        positive_xref_increments=n)
    return dict(operands=n, analysis_graph=a, rows=rows, total=total)


def combined_native_uniform_vector(c, analysis_graph):
    assert c >= 0 and analysis_graph >= 1
    one = combined_native_emitter_vector(2, analysis_graph)["total"]
    # For nonnegative p*n+q, sum(n)<=2*c and g<=c give (2*p+q)*c.
    total = {key: c*value for key, value in one.items()}
    a = analysis_graph
    assert total == dict(ordinary=(2320*a+3702)*c, uint=(9928*a+9089)*c,
                        lists=247*c, growth=377*c, entities_and_names=88*c,
                        name_characters=1157*c, pending_elist_headers=31*c,
                        pending_elist_elements=60*c, hash_wrappers=90*c,
                        positive_xref_increments=2*c)
    slots = 9*(total["ordinary"]+total["growth"])+61*total["entities_and_names"]
    assert slots == (20880*a+42079)*c
    return dict(source_concat_operators=c, uniform_analysis_graph=a, total=total,
                dynamic_slots=slots)


main_example_counts = dict(
    parser_nodes=7, parser_slots=124, parser_lists=4, parser_entities=1,
    source_ops=0, loop_ops=0, scalar_names=0, loop_names=0, raw_loop_nodes=0,
    largest_scalar_tree=1, loops=0, Integer_declarations=0, Integer_assignments=0,
    Integer_constraints=0, constrained_name_chars=0, String_declarations=0,
    String_assignments=0, String_name_chars=0, nonconcat_literals=0,
    dynamic_assignment_literals=0, comparisons=0, short_circuits=0,
    negations=0, ifs=0, elsifs=0, images=0, output_calls=0, source_calls=0,
    word_tokens=0, source_literals=0, parser_flattenings=0, concat_lengths=[],
    String_bound_descriptors=[], incoming_scope_depth=1)
mixed_example_counts = dict(main_example_counts, parser_nodes=100,
    parser_slots=1800, parser_lists=25, parser_entities=8,
    source_ops=4, loop_ops=1, scalar_names=8, loop_names=2, raw_loop_nodes=5,
    largest_scalar_tree=5, loops=1, Integer_declarations=2, Integer_assignments=1,
    Integer_constraints=1, constrained_name_chars=4, String_declarations=3,
    String_assignments=2, String_name_chars=12, nonconcat_literals=3,
    dynamic_assignment_literals=2, comparisons=3, short_circuits=1,
    negations=1, ifs=1, elsifs=1, images=1, output_calls=2, source_calls=4,
    word_tokens=50, source_literals=5, concat_lengths=[8, 12],
    String_bound_descriptors=[native_string_bound_descriptor("concat", (
        native_string_bound_descriptor("input"),
        native_string_bound_descriptor("image")))])

result = {
    "native_stack_peak_join": {
        "examples_not_thresholds": [native_stack_peaks(
            main_nodes=main_native_construct_vector(**counts)["total"]["node_identities"],
            main_lists=main_native_construct_vector(**counts)["total"]["syntax_list_headers"],
            loop_depth=counts["loops"], short_circuits=counts["short_circuits"],
            output_calls=counts["output_calls"])
            for counts in (main_example_counts, mixed_example_counts)],
        "fixed_counts": "native all-roots lifetime growth 1117 scope pushes, 520 expander pushes, 6526 list headers; source-reduced fixed overhead, never measured stack depths",
        "separate_obligations": "table backing/layout and recursive physical stack bytes; source-sensitive counters must fit Int",
        "whole_native_frontend_closed": False,
    },
    "native_diagnostic_metadata_join": {
        "examples_not_thresholds": [native_diagnostic_metadata(0, 0),
                                    native_diagnostic_metadata(3, 8)],
        "warning_flags": "warnsw.ads defaults; selected argv and configuration must preserve them",
        "dependency_flag_inventory": "native-warning-inputs.json; 42 retained fixed-capture source inputs hash-reconciled, sole pragma is entity-specific Warnings(Off,Default_Bit_Order)",
        "whole_native_frontend_closed": False,
    },
    "native_invocation_metadata_join": {
        "examples_not_thresholds": [native_invocation_metadata(4, 50, 2, 1, 100)],
        "fixed_input": "source-reduced fixed native AST bound; all fixed nodes conservatively dominate fixed-scaffold call markers/dummy root",
        "modes": "modern static elaboration, no invocation-path debug trace, native Main with selected unchanged interfaces/runtime signatures",
        "whole_native_frontend_closed": False,
    },
    "native_common_metadata_join": {
        "examples_not_thresholds": [native_common_metadata(concats=2, words=50,
            short_circuits=1, images=1, output_calls=2, loop_depth=1,
            max_identifier_length=12,
            main_entities=main_native_construct_vector(**mixed_example_counts)["total"]["entity_identities"],
            fixed_entities=100, fixed_xrefs=100, newly_analyzed_units=10)],
        "fixed_inputs": "actual source-reduced entity/xref/unit closure, not the illustrative values above",
        "remaining_common_metadata": "separate native_invocation_metadata_join, native warning attempts/history/text, native_stack_peak_join and physical table representations",
        "whole_native_frontend_closed": False,
    },
    "composed_Main_native_constructor_core": {
        "examples_not_thresholds": [main_native_construct_vector(**main_example_counts),
                                    main_native_construct_vector(**mixed_example_counts)],
        "parser_input": "retained-table-capacity Main parser transfer, including scanner nodes, source defining-entity promotions and raw literal-chain flattening",
        "remaining_inputs": ["fixed native capture and its variable input-name/default-literal/runtime-first-lookup corrections", "source scanner Uint/String/name pools", "deferred name qualification and auxiliary common tables", "native diagnostics/ALI and other late consumers", "target table backing, caller arithmetic, recursion/workspace and backend/object/linker"],
        "whole_native_frontend_closed": False,
    },
    "source_query_join_for_Main_constructor_core": {
        "formula": "H_source=max(2, all source String low/high D descriptors); H=H_source+2; A=max(17, largest_scalar_tree+1, 3H+7)",
        "dynamic_literal_reason": "direct literal assignment creates low+(length-1); Length and optimizer queries must include this transient subtype even though assignments do not change the target subtype",
        "examples_not_thresholds": [main_native_query_envelope(1, []),
            main_native_query_envelope(100, [native_string_bound_descriptor("input")]),
            main_native_query_envelope(5, mixed_example_counts["String_bound_descriptors"])],
        "whole_native_frontend_closed": False,
    },
    "Main_source_String_declarations_and_assignments": {
        "examples_not_thresholds": [source_string_stores(0, 0, 0, 1),
                                    source_string_stores(3, 5, 12, 17)],
        "premises": "later declarations nominally Standard String; first input fixed separately; already normalized source initializer/RHS, first operand analysis separate; A covers String bound/optimizer graphs; ordinary aligned Character arrays, no source slices, no explicit String constraint",
        "debug_renaming": "at most one terminal normalized slice after name-renaming chain, no packed encoding; two bound renderings of at most10 decimal digits, one sign and two Uint appends per digit; transient released arithmetic counted in lifetime demand",
        "excluded": "source operand constructors and literal resolution, first input, parser/source entities, shared metadata/name qualification/backend",
    },
    "Main_standalone_String_literal_suffix": {
        "examples_not_thresholds": [source_string_literal_suffix(0, 0, 1),
                                    source_string_literal_suffix(7, 3, 17)],
        "dynamic_route": "Set_String_Literal_Subtype against target's dynamic low bound creates ordinary index/array subtype and unchecked String conversion; two copies of normalized low, one Integer addition; no per-character aggregate",
        "scalar_query_root": "existing normalized target low plus (literal length-1); A includes this root",
        "source_multiplicity": "one outside-concat literal resolution per original literal occurrence; only direct assignment RHS can have dynamic low; all source literals/assignments are conservative counters",
    },
    "Main_source_predicates_and_control": {
        "examples_not_thresholds": [source_predicates_and_control(0, 0, 0, 0, 0, 1, 1),
                                    source_predicates_and_control(8, 3, 2, 2, 1, 17, 3)],
        "Length_comparison_delta_from_suppressed_check_envelope": {
            "source_warning_comparison_queries": 8,
            "enabled_range_queries": 12, "possible_equality_Bodies_lists": 4},
        "per_short_circuit": {"ordinary_nodes": 18, "growth": 5,
                              "entities_and_names": 4, "name_characters": 52,
                              "syntax_lists": 1, "scope_Uint_appends": 2},
        "excluded": "source operand/name/literal/call and action constructors; qualification/common metadata; physical workspace/backend",
    },
    "Main_source_Integer_declarations_and_assignments": {
        "examples_not_thresholds": [source_integer_stores(0, 0, 0, 0, 1),
                                    source_integer_stores(3, 5, 2, 8, 9)],
        "generated_range_check": {"ordinary_nodes_excluding_queries": 50,
                                  "growth": 16, "syntax_lists": 2,
                                  "entities_and_names": 1, "name_characters": 13,
                                  "comparison_queries": 7},
        "premises": "ordinary initialized Integer source objects; static nonempty object ranges; successful legality; same Standard Integer base; strict overflow/O0; selected default validity options; original scalar work and fixed dependencies separate",
        "excluded": "parser identities; original scalar arithmetic/name visits; source-name qualification; common xref/warning/elaboration metadata; backend and physical workspace",
    },
    "native_fixed_runtime_first_lookup_residue": {
        "all_RE_Id_values_including_ineligible": len(re_ids),
        "additional_element_list_headers": len(re_ids),
        "implicit_with_ordinary_nodes_per_selected_unit": 8,
        "premise": "selected fixed unit parse/analysis/full-view freeze and all-miss numeric work already captured; no additional unit admitted",
        "scope": "residual RTE-cache identities need no duplicate compiler capture",
    },
    "source_commit": pin,
    "source_files_verified": len(files),
    "source_sha256": hashes,
    "scope": "native String concat direct emitter and specified primitive helpers; not transitive closure",
    "Main_source_to_direct_emitter_multiplicity": {
        "premises": "admitted Main grammar, all source arguments explicit, no generic/frontend inlining/target names/String conditional; native child resolution before parent expansion; normalized value copies; ordinary backend renaming flagFalse; no concat debug wrapping",
        "source_concat_operators": "c",
        "emitter_calls": "g<=c", "sum_n_minus_one": "<=c", "sum_n": "<=2*c",
        "linear_per_call_composition": "p*n+q becomes at most(2*p+q)*c for p,q>=0",
        "source_runtime_loop_trip_count_multiplier": 1,
        "excluded": "fixed runtime sources/defaults/contracts; total semantic helper invocations; numeric A; transient placement/freezing; backend",
    },
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
    "mutable_renaming_pointer_capture": {
        "premises": "already-analyzed ordinary pointer name; existing named access to String; relevant types frozen; known nonnull; no renaming/current value/actual subtype/OK_To_Rename on old pointer; fresh local internal constant; no aspects/delayed freeze/static allocation/foreign convention; ordinary non-Ghost procedure/block; empty Related_Id",
        "analysis_of_generated_declaration_and_final_dereference_extra_allocations": 0,
        "Duplicate_Subexpr_total_including_direct_capture_and_final_tree_copy": {
            "ordinary_nodes": 8, "entities_and_internal_names": 1,
            "syntax_list_wrappers": 1, "growing_slot_events": 0,
            "pending_itype_elist_headers_and_elements": 0,
            "String_Uint_value_allocations": 0,
            "internal_name_characters_including_NUL": 13,
        },
        "not_included": "Insert_Actions placement/context handling; derivation of source-to-shape premises; prior access-type creation/freezing; backend",
    },
    "concat_allocator_expansion": {
        "runtime_entity": "RE_SS_Allocate",
        "runtime_unit": "System.Secondary_Stack",
        "ordinary_node_entity_list_allocations_in_Expand_N_Allocator": 0,
        "premises": "generated named access to constrained uncontrolled String; expression subtype identifier; No_Initialization; not special return/coextension; Linux 64-bit address; no restrictive config diagnostic",
        "not_included": "allocator semantic analysis, access-type declaration/freezing, RTE lookup/dependency loading, backend emission",
    },
    "concat_named_access_declaration_and_freeze": {
        "premises": "fresh generated named access to existing frozen constrained String subtype in current ordinary procedure/block scope; no aspects/storage-size/default-pool/private/derived/remote/controlled/task cases",
        "declaration_extra_elist_headers": 1,
        "first_freeze_extra_ordinary_nodes": 1,
        "first_freeze_extra_syntax_list_headers": 1,
        "extra_entity_name_String_Uint_allocations": 0,
        "repeated_freeze_extra_allocations": 0,
        "new_runtime_seeds": [],
        "not_included": "direct declaration syntax, incoming subtype construction/freezing, Insert_Actions context/scope handling, backend",
    },
    "concat_allocator_analysis_and_resolution": {
        "premises": "new ConstrT subtype identifier; exact designated subtype of existing frozen named access type; No_Initialization; no subpool/qualified expression/controlled/task/tagged/coextension cases",
        "extra_entities_and_internal_names": 1,
        "extra_node_list_elist_String_Uint_allocations": 0,
        "name_characters_including_NUL": 13,
        "retention": "E_Allocator_Type remains retained after expression type replaced with named access type",
        "not_included": "direct allocator syntax, enclosing object/renaming declaration, runtime lookup/loading, later whole-scope/backend processing",
    },
    "concat_allocator_object_and_constrained_renaming_skeletons": {
        "premises": "fresh artificial non-Ghost local pointer variable initialized by preceding new ConstrT No_Initialization allocator, then constrained String renaming of its plain dereference; exact frozen named access/designated/index types; no aspects/predicates/delayed-freeze/address/foreign/special-return/volatile/transient/diagnostic/callback; checks suppressed",
        "extra_ordinary_entity_name_list_elist_Uint_String_allocations": 0,
        "debug_renaming_helper": "does run because concat entity needs debug info; prepends only XA to existing bounded buffer, marks Materialize_Entity, returns Empty before debug object/name creation",
        "name_scratch_buffer_characters": 2,
        "not_included": "direct input syntax; allocator semantic/native transfer and runtime lookup; unfrozen access/subtype transfer; later renaming references; source-to-shape, transient/action placement and backend effects",
    },
    "scalar_variable_bound_capture": {
        "premises": "already-analyzed nonvolatile ordinary local Integer-family variable identifier; no renaming/current value/actual subtype/OK_To_Rename/pending Do_Range_Check; relevant types frozen; fresh internal non-Ghost constant with no aspects/delayed freeze; empty Related_Id",
        "ordinary_nodes": 5, "entities_and_internal_names": 1,
        "syntax_list_wrappers": 1, "name_characters_including_NUL": 13,
        "growing_slot_events": 0,
        "extra_analysis_node_entity_list_name_String_Uint_allocations": 0,
        "repeated_Force_Evaluation_of_result_allocations": 0,
        "not_included": "Insert_Actions context/transient handling, source-to-shape derivation, backend",
    },
    "ordinary_String_Set_Slice_Subtype": {
        "premises": "resolved nonpacked one-dimensional String slice; N_Range with t scalar-tree ordinary nodes, no lists/owned entities/itypes/actions; separately charged bounds already side-effect-free under Variable_Ref; no dimension/type attributes; compile-time-known bounds reduce to literals or finite constant-name chains",
        "ordinary_nodes": "t + 2",
        "entities_and_internal_names": 2, "name_characters_including_NUL": 26,
        "syntax_list_headers": 2,
        "growing_slot_events_elist_hash_String_allocations": 0,
        "retained_Uint_entries": 4,
        "retained_Uint_magnitude": "8*(2*H+1), H bounds both input magnitudes",
        "Uint_entries_when_a_bound_value_unknown": 0,
        "UI_Mul_transient_digit_words_for_multiplication_by_8": "2*(k+1), k digits in other operand",
        "Itype_Reference_semantic_and_expander_allocations": 0,
        "Itype_Reference_invokes_Freeze_Itype": False,
        "leaf_range_example": {"t": 3, "ordinary_nodes": 5},
        "not_included": "input syntax/resolution/range checks, bound capture/analysis, Insert_Actions context/transient handling, later freezing/backend",
    },
    "ordinary_String_slice_pair_freezing": {
        "premises": "unaltered Set_Slice_Subtype output; artificial local String/index itypes in current scope; standard/ancestor types frozen; index size 32 bits, array Esize unknown, earlier compile-time size check complete; no aspects/predicates/representation/remote/controlled/task flags",
        "Freeze_Entity_without_delayed_freeze_extra_allocations": 0,
        "per_unfrozen_member_with_delayed_freeze_max_ordinary_nodes": 1,
        "per_unfrozen_member_with_delayed_freeze_max_list_headers": 1,
        "explicit_Freeze_Itype_of_fresh_array_max_ordinary_nodes": 1,
        "explicit_Freeze_Itype_of_fresh_array_max_list_headers": 1,
        "freeze_node_analysis_expansion_extra_allocations": 0,
        "repeated_freeze_extra_allocations": 0,
        "not_included": "Insert_Actions context/transient handling, out-of-scope freeze analysis, later backend, explicit object-derived subtype construction",
    },
    "signed_Integer_index_layout": {
        "premises": "unpredicated signed Integer subtype, no biased representation; finite ancestor chain to frozen Standard Integer; selected compile-time-known bounds are literal/constant chains in -2**31 .. 2**31-1",
        "max_signed_loop_tests": 32,
        "max_power_cache_multiplications": 31,
        "max_Uint_negations": 64,
        "retained_Uint_entries": 95,
        "retained_Uint_digit_words": 285,
        "UI_Ints_cache_insertions": 95,
        "maximum_local_transient_Uint_digit_words": 8,
        "node_entity_list_name_String_allocations": 0,
        "not_included": "incoming range resolution/capture/checks, derived itype name, ancestor/constant-chain stack, cache wrapper bytes, backend",
    },
    "dynamic_range_check_tree_construction": {
        "premises": "no discriminant/access/fixed-lower-bound/static-error route; post-analysis side-effect-free bounds with b ordinary nodes and l syntax-list headers total, no owned itypes/entities/actions",
        "ordinary_nodes": "2*b + 28",
        "syntax_list_headers": "2*l",
        "bound_copy_nodes": "2*b",
        "Convert_To_calls": 6,
        "Convert_To_max_nodes_per_call": 3,
        "bound_attribute_nodes": 4,
        "other_constructor_nodes": 6,
        "entity_name_growing_slot_String_Uint_allocations_in_builder": 0,
        "suppression_prevents_construction": False,
        "not_included": "Compile_Time_Compare/Determine_Range numeric analysis, incoming resolution/capture, static-error handler, enabled-check analysis and placement",
    },
    "scalar_Determine_Range_and_Compile_Time_Compare": {
        "premises": "finite acyclic signed Integer expression/initializer/index-bound graph; +,-,* and unary signs, discrete conversions, scalar conditionals, ordinary String First/Last/Length; no modular/real/generic/discriminant/representation/Interfaces-array/expression-actions; known values are literal/constant chains",
        "A": "maximum fully unfolded rooted tree nodes including captured initializers and queried/substituted index bounds",
        "Determine_Range_Uint_appends": "6*A",
        "Determine_Range_local_Uint_weights": {
            "unary_plus_conversion_constant_forwarding": 0,
            "unary_minus": 2, "addition": 2, "subtraction": 4,
            "multiplication_including_Release_And_Save": 6,
            "String_Length": 6, "unrefined_leaf": 0,
        },
        "Compile_Time_Compare_max_invocations_including_recursive": 5,
        "Determine_Range_max_queries": 10,
        "Is_Same_Value_max_pair_walks": 10,
        "Compile_Time_Compare_ordinary_nodes": "20*A",
        "Compile_Time_Compare_Uint_appends": "80*A + 60",
        "Compile_Time_Compare_Uint_digits": "k*(80*A + 60)",
        "Compile_Time_Compare_other_table_allocations": 0,
        "maximum_local_transient_Uint_digit_words": "5*k+3",
        "no_static_error_Get_Range_Checks_ordinary_nodes": "2*b + 28 + 20*A",
        "no_static_error_Get_Range_Checks_syntax_lists": "2*l",
        "not_included": "source derivation of unfolded shape/acyclicity/magnitude/count, recursive walk stack bytes, numeric cache wrapper bytes, enabled check insertion/analysis",
    },
    "suppressed_explicit_String_subtype_resolved_pure_bounds": {
        "premises": "fresh artificial local ordinary subtype; existing defining entity/input syntax charged; one N_Range with already-analyzed nonoverloaded pure scalar bounds; combined finite analysis graph and 32-bit layout premises; all checks suppressed; standard and referenced scalar types frozen; no aspects/predicates/representation/generic/spec-expression/error/transient wrap",
        "ordinary_nodes": "2*b + 32 + 20*A",
        "extra_entities": 1, "extra_name_entries": 1,
        "name_characters_including_NUL": "L+4, L subtype identifier length",
        "Uint_appends": "80*A + 155", "growing_slot_events": 2,
        "syntax_list_headers": "2*l",
        "elist_String_allocations": 0,
        "dynamic_slot_envelope": "9*(2*b+34+20*A)+61",
        "secondary_concat_index_max_name_characters_including_NUL": 16,
        "plain_object_Find_Type_Of_Object_before_subtype_analysis": {
            "ordinary_nodes": 2, "entities": 1, "syntax_list_wrappers": 1,
            "name_characters_including_NUL": "O+3, O object name length",
            "subtype_plus_index_max_name_characters_for_O_at_most_12": 33,
        },
        "not_included": "initial analysis of generated scalar arithmetic/conditionals, capture, enabled-check analysis, insertion placement/transient contexts, freezing/backend",
    },
    "ordinary_for_range_capture_placement": {
        "premises": "ordinary scalar for-range parent chain; no spec expression or transient scope",
        "placement": "containing statement list immediately before loop",
        "Expression_With_Actions_created_by_this_route": False,
        "source_routes": ["exp_util.adb:12765-12824", "exp_util.adb:8289-8314", "exp_util.adb:8318-8462"],
        "not_included": "proof-domain replay multiplicity and proof-mode exclusion of transient scopes/Itype_Reference replay",
    },
    "generated_Integer_add_subtract_semantic_transfer": {
        "premises": "generated Standard Make_Op_Add/Subtract, already analyzed/resolved nonoverloaded operands of frozen Standard Integer base; all checks suppressed; no pending overflow flag/error/dimension/unset diagnostic/transient wrap; constant-folded intermediates fit Integer",
        "extra_ordinary_nodes": 2,
        "extra_growing_slot_events": 1,
        "extra_Uint_appends": 2,
        "entity_overload_list_name_String_allocations": 0,
        "direct_concat_operator_nodes": "4*n+2",
        "one_initial_analysis_if_all_premises_hold": {
            "ordinary_nodes": "8*n+4", "growing_slot_events": "4*n+2",
            "Uint_appends": "8*n+4",
        },
        "not_included": "child/attribute/conditional analysis, enabled-check plain-storage route, copies/reanalysis/source-to-event multiplicity, backend",
    },
    "generated_Integer_conditional_semantic_transfer": {
        "premises": "artificial complete if expression; already analyzed/resolved Standard Boolean condition and same frozen Standard Integer base/context branches; no actions/delayed expansion/diagnostics/dimensions/checks/conversion-return-aggregate-transient-spec context; strict overflow; validity-test and coverage overrides disabled; no allocating rewrite callbacks; known values are existing literal/constant chains",
        "extra_ordinary_nodes": 2,
        "extra_growing_slot_events": 1,
        "Uint_String_entity_name_overload_list_allocations": 0,
        "direct_concat_conditional_nodes": "n+2",
        "one_initial_analysis_if_all_premises_hold": {
            "ordinary_nodes": "2*n+4", "growing_slot_events": "n+2",
        },
        "not_included": "child comparison/arithmetic/attribute transfers, input Expressions lists, enabled-check route, copies/reanalysis/source-to-event multiplicity, backend",
    },
    "generated_Integer_equality_semantic_transfer": {
        "premises": "artificial Standard Make_Op_Eq/Ne and artificial Original_Node; already analyzed/resolved nonoverloaded same frozen Integer base operands and Boolean context; strict overflow, suppressed checks, no diagnostics/dimensions/transient/callback additions; no root entity Length attribute through conversions; finite initializer graph per comparison transfer",
        "extra_ordinary_nodes": "40*A+5",
        "extra_growing_slot_events": 2,
        "extra_Uint_appends": "160*A+120",
        "extra_syntax_lists_eq": 1,
        "extra_syntax_lists_ne": 0,
        "entity_name_elist_String_overload_allocations": 0,
        "Compile_Time_Compare_calls": 2,
        "direct_concat_comparisons": "2*n+2",
        "one_initial_analysis_if_all_premises_hold": {
            "ordinary_nodes": "(2*n+2)*(40*A+5)",
            "growing_slot_events": "4*n+4",
            "Uint_appends": "(2*n+2)*(160*A+120)",
            "syntax_lists": 2,
        },
        "not_included": "first child analysis, generated range-check comparisons, copies/reanalysis/source-to-event multiplicity, backend",
    },
    "generated_String_bound_attribute_semantic_transfer": {
        "premises": "artificial First/Last/Length without dimension; analyzed/resolved nonoverloaded ordinary String object/view/subtype prefix with frozen referenced entities, frozen ordinary nonpacked/nonprivate/nongeneric/nonpredicated non-literal String nominal/actual subtype and Integer indices; no access-typed prefix/BIP/concurrent/union/error/dimension/pending check/transient/spec/callback additions; Integer base context and folded results fit; checks suppressed, strict overflow; existing known bound values",
        "First_Last": {"ordinary_nodes": 2, "growing_slot_events": 1, "Uint_appends": 0},
        "Length": {"ordinary_nodes": "20*A+4", "growing_slot_events": 2, "Uint_appends": "80*A+64"},
        "extra_Length_arithmetic_magnitude": "2*H+1, combined with comparison magnitude envelope",
        "entity_name_list_elist_String_overload_allocations": 0,
        "direct_concat_First_Last_nodes": "n+2",
        "direct_concat_Length_nodes": "n",
        "one_initial_analysis_if_all_premises_hold": {
            "ordinary_nodes": "20*n*A+6*n+4",
            "growing_slot_events": "3*n+2",
            "Uint_appends": "n*(80*A+64)",
        },
        "not_included": "first prefix analysis, outer conversions, nonfrozen copied slice itypes, insertion contexts, copies/reanalysis/source-to-event multiplicity, backend",
    },
    "generated_same_Integer_conversion_semantic_transfer": {
        "premises": "artificial conversion with existing type mark and same frozen Standard Integer base target/context/analyzed-resolved nonoverloaded operand; suppressed checks; no diagnostics/dimension/predicate/callback/transient/spec/pending checks; known values existing chains and fit target",
        "extra_ordinary_nodes": 2,
        "extra_growing_slot_events": 1,
        "Uint_entity_name_list_elist_String_overload_allocations": 0,
        "direct_concat_explicit_Convert_To_calls": 2,
        "one_initial_analysis_if_all_premises_hold": {"ordinary_nodes": 4, "growing_slot_events": 2},
        "not_included": "input conversion syntax, child first analysis, other type pairs, generated range-check conversions, caller suppression, copies/reanalysis/source-to-event multiplicity, backend",
    },
    "collected_Integer_constant_declaration_skeleton": {
        "premises": "fresh artificial local non-Ghost constant with frozen Standard Integer base type mark; already charged well-typed ordinary scalar initializer analysis; root entity initializer has exact same type; no pending check/error/diagnostic/allocator/function/renaming/actions; no completion/return/address/representation/aspect/foreign/static-allocation/delayed-freeze/transient properties; all checks suppressed; native Expander_Active",
        "extra_node_entity_list_name_Uint_String_allocations": 0,
        "Assignment_OK_required": False,
        "direct_concat_declarations": "2*n",
        "not_included": "direct declaration/entity/name syntax, initializer first analysis/copies, Insert_Actions placement/context movement, compilation-wide multiplicity, backend",
    },
    "ordinary_initial_Insert_Actions_placement": {
        "premises": "ordinary expression parent chain to declaration/statement list or unanalyzed short-circuit-right/conditional-branch/elsif condition action field; supplied lists/action analyses already charged; no transient/wrapped/record/concurrent/generic/spec/aggregate-loop context or allocating callbacks",
        "extra_node_entity_list_name_Uint_String_allocations": 0,
        "Kill_Current_Values_allocations": 0,
        "not_included": "supplied action lists/analysis/recursively inserted actions, Insert_Action wrapper, later Expression_With_Actions and Boolean capture, already-analyzed short-circuit insertion, transient placement, replay/source-to-invocation closure",
    },
    "Boolean_expression_with_actions_wrapper": {
        "premises": "generated wrapper; existing nonempty actions and exact Standard Boolean expression already analyzed/resolved/expanded; enclosing short-circuit result also Standard Boolean; frozen relevant types; ordinary non-Ghost nontransient procedure/block; no diagnostic/rewrite callback/BIP; expression name/literal/comparison/short-circuit/not/ordinary Boolean call/analyzed EWA with no pending check; finite known Boolean values; no renaming/OK_To_Rename; no action replay adds scope/freeze/use actions; object action types ordinary Integer/Boolean/String or access to ordinary String",
        "including_direct_short_circuit_wrapper": {
            "ordinary_nodes": 8, "entities_and_internal_names": 2,
            "name_characters_including_NUL": 26, "growing_slot_events": 2,
            "Uint_appends": 1, "extra_live_scope_stack_entries": 1,
            "extra_syntax_lists_Elists_String_values": 0,
        },
        "wrapper_direct": {"ordinary_nodes": 3, "growing_slot_events": 1},
        "analysis_scope": {
            "entities_and_internal_names": 1, "Uint_appends": 1,
            "Uint_magnitude": "incoming_scope_depth + 1",
            "scope_stack_lifetime": "one push then pop; peak depth, not cumulative retained entries",
        },
        "Boolean_capture": {
            "ordinary_nodes": 5, "entities_and_internal_names": 1,
            "growing_slot_events": 1,
            "extra_declaration_range_check_or_final_name_allocations": 0,
            "list_handling": "append to existing Actions list; no new header",
        },
        "mutually_exclusive_semantic_fold": {"ordinary_nodes": 2, "growing_slot_events": 1},
        "finalization_processing_extra_allocations_for_stated_action_types": 0,
        "not_included": "first child/action analysis; other action types; pending-freeze scope exits; transient placement; replay and source-to-invocation multiplicity; whole-scope/backend costs",
    },
    "enabled_scalar_helper_extensions": {
        "premises": "earlier local frozen exact Standard Integer/Boolean classes, resolved children; strict overflow,O0, Linux x86 Backend_Overflow_Checks=True; no diagnostic; same-Integer parent conversion; no transient/rewrite callback; A bounds finite unfolded queries",
        "arithmetic_or_same_Integer_conversion_additional_Uint": "6*A per operation",
        "arithmetic_or_same_Integer_conversion_additional_other_allocations": 0,
        "ordering_comparison_extra": {"ordinary_nodes": "40*A+5", "growth": 2,
                                       "Uint": "160*A+120", "syntax_lists": 0},
        "scalar_conditional_and_artificial_String_attribute_costs": "same as suppressed local transfer after child analysis",
        "Standard_Positive_First_or_Last_extra": {"ordinary_nodes": 2, "growth": 1},
    },
    "empty_action_Standard_Boolean_short_circuit": {
        "premises": "generated nonoverloaded Standard Boolean operator/context; pure already-resolved children; empty actions; frozen ordinary nontransient context; no diagnostics/callbacks",
        "ordinary_nodes": 8, "growth": 3, "syntax_lists": 1,
        "other_entity_name_Uint_Elist_String_allocations": 0,
        "resolver_left_EWA": "unconditional New_List/relocate/EWA/rewrite; Resolve without Analyze, so no block entity or scope entry; later empty wrapper is folded away",
    },
    "enabled_pure_range_check": {
        "premises": "resolved pure bounds of exact Standard Integer base, b ordinary nodes/l lists, no owned entities/itypes/actions or pending range checks; Standard Positive target; A covers queries; no static error; native no local-raise optimization/transient/callback; fixed generated check grammar",
        "ordinary_nodes": "2*b+140*A+77", "syntax_lists": "2*l+2",
        "growth": 21, "Uint": "596*A+420",
        "extra_entity_name_Elist_String_allocations": 0,
        "result_subtype_with_index_layout_and_bound_folds": {
            "ordinary_nodes": "2*b+140*A+81", "syntax_lists": "2*l+2",
            "growth": 23, "Uint": "596*A+515", "entities_and_names": 1,
            "name_characters": "L+4",
        },
        "composition_examples_not_thresholds": [enabled_range_check(2, 0, 1),
                                               enabled_range_check(31, 4, 127)],
    },
    "direct_and_scalar_concat_aggregate": {
        "premises": "first generated scalar passes meet local helper premises; A bounds every unfolded graph query, including direct Get_Known_Bound comparisons; input numeric values fit and no diagnostic",
        "ordinary_nodes": "(120*n+80)*A+52*n+73", "entities_and_names": "2*n+4",
        "syntax_lists": "3*n+13", "growth": "12*n+13",
        "Uint": "(504*n+344)*A+385*n+250", "name_characters": "13*(2*n+4)",
        "excluded": "remaining direct copies and duplicators; result-subtype/storage/call/assignment analysis; wrapper/transient placement; reanalysis and source-to-invocation multiplicity",
        "composition_examples_not_thresholds": [direct_and_scalar_concat(2, 1),
                                               direct_and_scalar_concat(9, 127),
                                               direct_and_scalar_concat(64, 4095)],
    },
    "input_transient_lifecycle": {
        "source_premises": "only source unconstrained String function is first input declaration with literal actual; later grammar contains literals/names/concat/Integer Image and scalar-return calls; ordinary Integer Image excludes Put_Image and wide-image routes",
        "boundary": "Find_Transient_Context selects input object declaration; Expand marks analyzed then Wrap_Transient_Declaration pops its temporary scope before next declaration",
        "persistent_flag": "Wrap_Transient_Declaration can mark enclosing procedure Uses_Sec_Stack; this is distinct from Scope_Stack.Is_Transient",
        "consequence": "later concat's initial action placement is nontransient, but its secondary-stack storage branch remains reachable",
        "excluded": "input initialization's own allocation/finalization costs; unrelated runtime body analysis; conditional action-wrapper allocation; source-copy/reanalysis multiplicity",
    },
    "result_storage_and_subtype_freezing": {
        "premises": "direct emitted storage syntax separately charged; already analyzed/resolved pure Integer bounds with b nodes/l lists, no owned itypes/entities/actions or pending checks; frozen Standard types; ordinary same current scope; names length at most12; no aspects/diagnostics/callbacks; first array size computation may still be needed",
        "plain_no_initializer_object_skeleton_extra": 0,
        "first_array_size_check_Uint": 4,
        "first_array_size_magnitude": "8*(2*H+1)",
        "ordinary_nodes": "2*b+140*A+83", "lists": "2*l+3", "growth": 23,
        "Uint": "596*A+519", "entities_and_names": 2,
        "name_characters": 33, "elists": 1,
        "excluded": "first bound analysis/captures; initial syntax already charged directly; runtime lookup/loading; later object freezing; other source shapes; final slice/call/assignment analysis; placement/reanalysis/backend",
        "composition_examples_not_thresholds": [result_storage(2, 0, 1), result_storage(31, 4, 127)],
    },
    "direct_scalar_storage_aggregate": {
        "ordinary_nodes": "(120*n+220)*A+52*n+156+2*b",
        "lists": "3*n+2*l+16", "growth": "12*n+36",
        "Uint": "(504*n+940)*A+385*n+769",
        "entities_and_names": "2*n+6", "name_characters": "26*n+85", "elists": 1,
        "excluded": "remaining copies/duplicators; first bound captures; runtime dependencies; object freezing; final result/call/assignment analysis; wrapper placement; reanalysis/source multiplicity; backend",
        "composition_examples_not_thresholds": [direct_scalar_and_storage_concat(2, 2, 0, 1),
                                               direct_scalar_and_storage_concat(64, 31, 4, 4095)],
    },
    "suppressed_native_slice_assignment_checks": {
        "premises": "ordinary one-dimensional String slice assignment; constrained/frozen/cache-resolved actual subtypes or literal RHS; all checks suppressed; no diagnostics, pending checks, callbacks, packed/alignment/atomic/controlled work; artificial dimensionless Length Ne; A bounds all original and newly generated query graphs",
        "one_length_optimizer": "80*A+52 nodes,13 growth,332*A+308 Uint",
        "one_length_check_pass": "280*A+144 nodes,39 growth,1156*A+1262 Uint",
        "two_passes_overlap_and_guard": "600*A+290 nodes,79 growth,2472*A+2644 Uint",
        "extra_lists_entities_names_Elists_String_values": 0,
        "power_cache_largest_new_magnitude": "2^126",
        "excluded": "slice/bound/operand analysis and captures; actual-subtype construction; type/object freezing; direct assignment/guard syntax; guard condition analysis already in scalar aggregate; callback placement; source multiplicity/backend",
        "composition_examples_not_thresholds": [suppressed_slice_assignment_checks(1),
                                                 suppressed_slice_assignment_checks(127)],
    },
    "general_analyzed_scalar_bound_capture": {
        "premises": "already analyzed signed Integer tree, no actions/pending checks/volatile/packed/unaligned aspects; root attributes have object-name prefixes; existing scalar types frozen; ordinary nonallocating placement; Related_Id empty",
        "ordinary_nodes": 5, "entities_and_names": 1, "lists": 1,
        "growth": 0, "Uint": 0, "name_characters": 13,
        "second_capture_extra": 0,
        "excluded": "first bound analysis; external related-name construction; source derivation of retained pure bound size; action placement",
    },
    "concat_runtime_cache": {
        "entity_seeds": [f"RE_Str_Concat_{i}" for i in range(2, 10)] + ["RE_SS_Pool", "RE_SS_Allocate"],
        "distinct_seed_units": 9, "direct_successful_entity_cache_misses": 10,
        "direct_Load_RTU_empty_Elist_headers": 10,
        "Main_private_ancestor_elements": 0,
        "Main_implicit_with_clauses": 9, "ordinary_nodes_per_implicit_with": 4,
        "Main_implicit_with_ordinary_nodes": 36,
        "excluded": "recursive dependency semantic/parse/expansion costs; implicit-with pairs in other units; fixed helper declaration and call analysis; failed lookup/retry configurations; source-to-installed runtime identity",
    },
    "suppressed_slice_resolution_suffix": {
        "premises": "prefix/actual-subtype lookup and first bound analysis already charged; aligned ordinary object-name String view; artificial N_Range; pure captured scalar range t nodes/l lists, no owned entities/itypes/actions; Standard types frozen; checks suppressed; no diagnostics/pending checks/allocating placement",
        "ordinary_nodes": "t+16", "syntax_lists": "l+4", "growth": 2,
        "Uint": 4, "entities_and_names": 4, "name_characters": 52,
        "with_two_assignment_check_passes_overlap_and_guard": "600*A+t+306 nodes,l+4 lists,81 growth,2472*A+2648 Uint,4 entities/names,52 chars",
        "excluded": "source derivation of t/l or no-owned-decoration invariant; RHS view analysis; prefix/actual-subtype construction; first scalar analysis; enabled range checking; later freezing/backend; placement; source multiplicity",
        "composition_examples_not_thresholds": [suppressed_slice_resolution(3, 0, 1),
                                                 suppressed_slice_resolution(31, 2, 127)],
    },
    "uncached_dereference_actual_subtype": {
        "premises": "analyzed ordinary P.all: unconstrained Standard String, no Actual_Designated_Subtype; P internal constant pointer, nonrenamed/nonvolatile/known nonnull; all preexisting types frozen; no owned decoration/actions/pending checks/mutable-original-renaming; ordinary nonallocating placement; query/layout premises; internal names at most12 chars",
        "ordinary_nodes": "20*A+70", "syntax_lists": 8, "growth": 6,
        "Uint": "80*A+159", "entities_and_names": 2, "name_characters": 29,
        "Elists_or_String_values": 0,
        "memoization": "none: allocating Get_Actual_Subtype branch does not populate either input cache",
        "excluded": "source derivation of invocation count; different pointer/original-renaming class; input function/capture; action placement; whole-scope/backend",
        "composition_examples_not_thresholds": [uncached_dereference_actual_subtype(1),
                                                 uncached_dereference_actual_subtype(127)],
    },
    "ordinary_native_renaming_flag_inventory": {
        "manifest_pinned_Ada_files_searched_and_hashed": macro_flag_searched_files,
        "setter_sites": macro_flag_setter_sites,
        "guard": "Evaluation_Required: packed/full-access/representation/discriminant cases; ordinary String names/dereferences returnFalse and ordinary slices recurse to them",
        "Set_Renamed_Object_sets_macro_flag": False,
        "Main_ordinary_String_macro_renaming_replays": 0,
        "excluded": "other caller copying/reanalysis, runtime bodies and nonstandard views",
    },
    "normalized_native_String_view_copy": {
        "premises": "Main first-resolved ordinary String name/literal or direct Image/concat slice; no author slices/general String-return calls; macro flagFalse; generated mutable slice bases; Force_Evaluation normalizes scalar bounds; scalar initializer/query graph excluded",
        "shape": normalized_native_view(),
        "name_characters": "at most13*2 for copied internal itype names under existing serial premise",
        "Uint_or_String_values": 0,
        "excluded": "pre-normalization direct bound-copy sizes; all cumulative allocation/invocation counts; numeric A/magnitudes; enabled checks; runtime dependencies; backend; useful admission predicate",
    },
    "remaining_direct_native_copy_costs": {
        "premises": "Main normalized incoming String views; raw operand bounds contain at most one such view, null selectors at most two; direct later copies occur after completed action analysis, not midway through scalar expansion; macro flagFalse; default Variable_Ref=False makes direct Duplicate_Subexpr inputs side-effect-free",
        "each_remaining_New_Copy_Tree": "144 ordinary,4 entities/names,11 lists,2 pending Elist headers,4 elements,6 hash wrappers",
        "each_Duplicate_Subexpr": "66 ordinary,2 entities/names,5 lists,1 pending Elist header,2 elements,3 hash wrappers",
        "ordinary_nodes": "708*n+708", "entities_and_names": "20*n+20",
        "syntax_lists": "54*n+54", "pending_elist_headers": "10*n+10",
        "pending_elist_elements": "20*n+20", "hash_wrappers": "30*n+30",
        "name_characters": "260*n+260", "growth_or_Uint_or_String_values": 0,
        "excluded": "first raw bound analysis/captures; semantic helpers; generated subtype/call/assignment analysis; later freezing; placement; numeric queries; source-to-invocation count; backend/runtime closure",
        "composition_examples_not_thresholds": [direct_native_copy_costs(2),
                                                 direct_native_copy_costs(64)],
    },
    "native_query_weighted_recurrence": {
        "D": "1 plus recursively queried initializer/arithmetic/conversion/Length-bound D weights; conditional/EWA/First/Last are leaves",
        "U": "sum of recursive U plus local Uint weight: minus2,add2,subtract4,multiply6,Length6,others0",
        "S": "1 plus unary/binary operand S after exactly one Compare_Fixup at this visit; no constant-initializer, conditional-arm or conversion recursion",
        "F": "one for a String-literal Last fixup at this visit, plus recursively visited S-child F weights",
        "root_set": "both comparison operands, decomposition roots and scalar-type bounds of the initial and four Rec=True comparison calls",
        "comparison_ordinary_nodes": "20*max(F)",
        "comparison_Uint": "10*max(U)+20*max(F)+60",
        "reuse_existing_A_formulas": "A=max(1,max(D),max(S)) over same root set; U<=6*D,F<=S",
        "examples_not_admission_thresholds": native_query_weight_examples(),
        "excluded": "source-to-bound-graph derivation, full helper invocation count and numeric magnitudes; not a compiler simulator or membership check",
    },
    "Main_original_String_bound_D_bridge": {
        "seeds": {"literal": [1, 1], "Integer_Image": [1, 2],
                  "first_input": [2, 2]},
        "ordinary_declaration_alias": "reuse initializer bound descriptor; no extra D layer",
        "saved_operand_length_D": "low_D+high_D+2",
        "aggregate_length_D": "sum(saved_operand_length_D)+2*(n-1)",
        "result_low_D": "max(2,2+max(operand_low_D))",
        "result_high_D": "aggregate_length_D+result_low_D+5",
        "source_binary_tree": "monotone conservative envelope dominates native flattening and operand elimination; sharing counted per occurrence",
        "premises": "Main String grammar and selected native options; normalized-view/capture stability and ordinary declaration/type reuse established in report; no source slices/general String calls",
        "examples_not_thresholds": native_string_bound_examples(),
        "excluded": "this descriptor alone is not complete A; subsequent scoped query-root closure is separate; other constructors/helpers, scalar source expressions, numeric magnitudes and all allocation costs remain separate",
    },
    "Main_combined_concat_query_root_closure": {
        "scope": "all query roots in the combined Main concat vector's closed stages; not other Main constructors/operations or open final helpers",
        "D_root_envelope": "3*H+7, where H is the source-derived concat high-bound descriptor",
        "S_root_envelope": 17,
        "A": "3*H+7 (H>=18 for any concat descriptor)",
        "extra_comparison_roots": "one-step decomposition selects an existing child; recursive scalar-type bounds are fixed signed Standard endpoints or previously covered generated String index bounds",
        "noncircularity": "query-generated check trees are priced separately and never fed back into original String-bound H",
        "examples_not_thresholds": [native_concat_query_roots((
            native_string_bound_descriptor("literal"),
            native_string_bound_descriptor("literal"))),
            native_concat_query_roots((native_string_bound_descriptor("input"),
                                       native_string_bound_descriptor("image")))],
        "excluded": "numeric magnitudes; source scalar/Image/input and source String equality/assignment outside this emitter; wrapper/scope work; runtime first lookup/fixed dependencies; backend; whole admission predicate",
    },
    "Main_output_concat_transient_placement": {
        "maximum_fresh_scopes": "number of source output calls with nonstatic concat actuals",
        "Uses_Sec_Stack_of_fresh_output_scope": False,
        "whole_Main_Uses_Sec_Stack_may_be_True": True,
        "pending_action_placement_extra_allocations": 0,
        "wrapper_direct_skeleton": {"ordinary": 5, "lists": 2,
                                    "growth": 1, "entities_and_names": 1,
                                    "name_characters": 13,
                                    "new_scope_stack_entries": 1},
        "closed_local_wrapper": "direct skeleton plus first scope-depth Uint, qualification queue append, and at most two fixed names from nonloading Is_RTE; first entity freezes charged to their constructors",
        "examples_not_thresholds": [output_transient_wrapper(0, 1),
                                    output_transient_wrapper(1, 1),
                                    output_transient_wrapper(8, 4)],
        "excluded": "supplied action creation/analysis/first freezes; deferred per-type qualification, source output-call processing; initial input wrapper and Main secondary-stack cleanup; physical stack bytes",
        "whole_wrapper_closed": True,
    },
    "Main_raw_copied_bound_semantics": {
        "prefix_stability": "New_Copy_Tree preserves Analyzed; owned normalized slice types have no Freeze_Node and retain Is_Frozen; copying does not replay prefix resolution or append conditional-arm actions",
        "per_raw_copy_scalar_class_counts": {"add_or_subtract": 3,
            "same_Integer_conversion": 2, "First_or_Last": 2,
            "Eq": 1, "scalar_conditional": 1},
        "copies": "4*n+4; direct normalized String duplications need no first analysis",
        "result_storage_bound_captures": 2,
        "capture_names": "Constrain_Index explicit N_Range calls Process_Range_Expr_In_Decl without Subtyp: internal serial names, not related FIRST/LAST names",
        "premises": "source-backed normalized input views; selected native options, no diagnostics or pending bound checks; original direct scalar nodes charged earlier; each original/copy analyzed once; initial boundary forcing after scalar children; A covers all queried roots",
        "examples_not_thresholds": [raw_bound_semantics(2, 1),
                                    raw_bound_semantics(64, 127)],
        "excluded": "original Image/input construction, output/input wrapper helpers, final runtime call/result-slice analysis, later object/scope freezing and query-root/magnitude closure",
    },
    "Main_result_object_freeze_and_actual_subtype_lookup": {
        "first_object_freeze_core_table_allocations": 0,
        "premises": "subtype/access type already frozen and charged; generated local plain uninitialized String result or constrained renaming; no delayed/static/aspect/address/C++/controlled properties; Layout_Object is empty",
        "normalized_String_lookup_allocations": 0,
        "lookup_reason": "literal/slice/generated result/source declared String name has constrained nominal type or available Actual_Subtype; Get_Actual_Subtype cannot enter allocating branch",
        "excluded": "initial input call/uncached P.all; whole-scope freezing/qualification; backend materialization; wrapper helpers",
    },
    "Main_enabled_final_result_slice": {
        "source_count": "at most one per native concat invocation",
        "shape_bridge": "Slice_Rng exists only with compile-time-known buffer low and finite fitting known buffer high; target index endpoints static Integer; constrained result name prefix",
        "ordinary_nodes": "140*A+3*t+91", "lists": "3*l+7", "growth": 23,
        "Uint": "596*A+424", "entities_and_names": 4, "name_characters": 52,
        "premises": "first original scalar nodes charged; t/l normalized range bound; no static-error diagnostic, pending check or allocating placement; target/object freezing and subtype lookup closed above",
        "A": "3*H+7 still covers result range, static target endpoints and their check conversions",
        "examples_not_thresholds": [enabled_final_slice(31, 2, 1),
                                    enabled_final_slice(31, 2, 127)],
        "excluded": "runtime concat-call helpers; wrapper/scope work; numeric magnitudes; fixed dependencies/backend",
    },
    "Main_runtime_concat_call_processing": {
        "scope": "one generated Str_Concat_r call with2<=r<=min(n,9); charge original operand envelope n",
        "premises": "runtime spec/types already loaded/frozen under separate fixed-dependency charge; ordinary local/pending placement; normalized resolved aligned Standard String actuals; no diagnostics/pending checks; default validity-parameter and parameter-alias checks off; no frontend inlining/debug override",
        "ordinary_nodes": "n", "syntax_lists": "n+2",
        "positive_Xrefs_increments": "n",
        "other_core_table_additions": 0,
        "two_empty_lists": "Expand_Call_Helper and Expand_Actuals each allocate Post_Call; both headers count although the first becomes abandoned",
        "variable_reference_markers": "at most one node and Insert_Action list per source-name operand; Main local declaration/subprogram scope creates no scenario-set record",
        "xref_primitive": "at most one positive Xrefs-table increment per ordinary source-name operand, no dedup credit; fixed65536 hash headers, links inside Xrefs records",
        "call_marker": "none: generated call is not from source and Str_Concat_r is no Ada-semantic/bridge/SPARK-semantic target",
        "new_scalar_query_roots": 0,
        "examples_not_thresholds": [native_runtime_concat_call(2),
                                    native_runtime_concat_call(9),
                                    native_runtime_concat_call(64)],
        "excluded": "runtime first lookup/spec processing; wrapper/scope work; diagnostics; backend; physical stack/workspace",
    },
    "Main_source_concat_folding_and_literal_suffix": {
        "scope": "Eval_Concatenation/Fold_Str plus Standard_String literal-operand resolution and explicit post-concat subtype creation/freezing; separate additive component, not part of direct-emitter vector",
        "source_counts": "<=c folds, <=2*c original literal-operand resolutions, <=2*c post-concat subtype registrations; no runtime-trip multiplier",
        "source_lengths": "B(left&right)=B(left)+B(right); alias uses existing declaration bound; folded values reuse these same source bounds; each B<=IntegerLast is an input-domain premise",
        "ordinary_nodes": "2*c", "growth": "c", "entities_and_names": "5*c",
        "name_characters": "65*c", "Uint_appends": "22*c", "Uint_digits": "66*c",
        "String_descriptors": "c", "String_character_appends": "sum B(e) over source concats",
        "dynamic_slots": "332*c", "syntax_lists_Elists_hashes_Xrefs": 0,
        "literal_suffix_per_resolution": {"entities_and_names": 1, "name_characters": 13,
            "uint": 6, "other_core_allocations": 0},
        "direct_subtype_and_first_freeze": {"entities_and_names": 1, "name_characters": 13,
            "uint": 2, "other_core_allocations": 0},
        "premises": "Main String-only concat; Standard String/Character/Integer frozen; no diagnostics/pending checks; ordinary local/pending placement; literal low bound is static1; no delayed freeze; internal-name serial bound; native source correspondence remains separate",
        "examples_not_thresholds": [source_concat_folding([]),
                                    source_concat_folding([2, 3, 4]),
                                    source_concat_folding([2, 4, 8, 16])],
        "excluded": "parser/scanner strings and parser folding; source name/Image/input constructors; standalone literal resolution in a possibly dynamic target subtype; outer concat name resolution/xrefs; wrapper/scope/backend; full predicate",
    },
    "Main_combined_concat_numeric_magnitude_closure": {
        "scope": "same closed stages as combined_Main_native_emitter_addends, including scalar queries, cold powers and first-size arithmetic",
        "premises": "selected Linux target Integer32/Nat32, largest relevant signed Standard/Universal width128; n+1 fits Nat; incoming String index values fit Integer; no static-error path; original String-bound graph/query-root bridge; no source scalar-argument evaluation in this bound graph",
        "seed_M": "2^127",
        "direct_numeric_bound": "n*(2^32+1)+2^31+1 < 2^63 for 2<=n<=2^31-2",
        "range_query_bound": "M*D(root), hence M*A; additive-only dependency graph with Length's +1 paid by its own visit",
        "comparison_bound": "2*M*A+1",
        "first_size_bound": "8*(2*M*A+1)",
        "uniform_magnitude": "(16*A+8)*M",
        "digits_per_Uint": "base32768 digit count of ((16*A+8)*2^127)",
        "retained_digits": "k*((3816*n+2296)*A+3696*n+1697) per group; uniform Main k*(9928*A+9089)*c",
        "max_local_arithmetic_vectors": "5*k+3 digit words, separate from recursive call stack",
        "examples_not_thresholds": [native_concat_numeric_magnitude(2, 61),
                                    native_concat_numeric_magnitude(64, 1000000),
                                    native_concat_numeric_magnitude(2**31-2, 2**31-1)],
        "excluded": "initial source scalar/Image/input/standalone String operations, whole-scope and fixed runtime numeric work, source correspondence, complete table headroom and physical memory",
    },
    "Main_local_name_qualification": {
        "scope": "Main-local no-homonym/no-debug-renaming generated type and scope graph; ordinary objects need no fresh qualified name",
        "queued_block": "each Expand_N_Block_Statement adds one Name_Qualify_Units entry; direct skeleton does not contain this entry",
        "qualified_name_length": "Q(e)=sum unqualified name lengths on Main-to-e scope path +2*(path_length-1)",
        "Name_entries": "at most one per Main/type requiring full qualification; repeat visits return on Has_Qualified_Name",
        "Name_characters": "sum(Q(e)+1), including each NUL",
        "Name_Qualify_Units": "count actual qualification enqueue calls; each block call is one; fixed dependencies/Main finalizer subprograms need their own count",
        "other_core_table_allocations": 0,
        "buffer_condition": "each Q(e)<=Name_Buffer'Length; Homonym_Numbers stays empty; one local Full_Qualify_Name buffer of Name_Buffer'Length, plus recursive control-stack depth",
        "premises": "Main and ordinary generated E_Block/E_Loop/type/object scopes; no source nested packages/subprograms/user types, debugging override, Debug_Renaming_Link or same-scope overloads; input unqualified-name lengths and scope graph supplied by constructors",
        "examples_not_thresholds": [local_name_qualification([[4], [4, 12]], 1),
                                    local_name_qualification([[4, 12, 12], [4, 12, 12, 16]], 2)],
        "excluded": "backend external/debug name generation, fixed runtime qualification, whole wrapper/scope processing, full enqueue multiplicity from unclosed constructors",
    },
    "Main_Integer_Image_expansion": {
        "premises": "original scalar argument analyzed/resolved, Standard Integer32, no Put_Image aspect, frozen runtime specs/types, no frontend inlining/validity operand-or-parameter override; fixed runtime unit-name interning charged in dependency baseline",
        "examples_not_thresholds": [native_integer_image(0), native_integer_image(1),
                                    native_integer_image(10)],
        "excluded": "original source attribute/prefix/scalar-argument semantic analysis and numeric work; runtime first loading/spec freezing and fixed unit-name lookups; context/action-wrapper placement; per-type deferred qualification; backend and physical stack bytes",
    },
    "Main_source_scalar_arithmetic": {
        "scope": "source scalar literal/name/unary +/- and binary +/-/* arithmetic, including both raw loop-bound preanalysis copies; parent range/declaration/assignment checks separate",
        "operator_visits": "T=O_scalar+2*O_loop",
        "name_visits": "V=N_scalar_name+2*N_loop_name",
        "raw_copy_nodes": "2*B_loop",
        "query_A": "1+largest source scalar expression tree (including all type-bound expression roots); source constants do not unfold in Determine_Range; internal loop capture contributes at most one initializer edge",
        "ordinary_nodes": "2*B_loop+4*T+3*V",
        "growth": "2*T+V",
        "syntax_lists": "V (immediate source variable-marker insertion wrappers)",
        "Uint_appends": "(12*A+3)*T",
        "digits_per_Uint": "ceil((130*A+2)/15), conservative signed-target-width128 query bound",
        "premises": "current scalar grammar and successful static legality; source values/intermediates fit Integer32; strict overflow/O0/backend overflow enabled; frozen scalar types or their first freezes charged separately; no user operators/types/validity override; syntactic tree copies have no owned decoration",
        "examples_not_thresholds": [source_scalar_arithmetic(0, 0, 0, 0, 0, 1),
                                    source_scalar_arithmetic(12, 4, 18, 6, 20, 9)],
        "excluded": "source scanner/parser; full range/loop/declaration/assignment/attribute processing; capture constructors; first freezes; non-arithmetic diagnostics and shared xref/elaboration metadata; physical recursion stack and backend lowering",
    },
    "Main_source_for_loop_skeleton": {
        "scope": "ordinary scalar for/reverse-loop skeleton beyond parser, scalar-expression/copy transfer and body constructors",
        "examples_not_thresholds": [source_for_loop_skeleton(0, 1),
                                    source_for_loop_skeleton(3, 9)],
        "raw_range_copies_and_arithmetic": "charged by Main_source_scalar_arithmetic, not repeated here",
        "source_captures": "G<=2F, each5ordinary+1entity+1name+13namechars+1list; already analyzed scalar initializer is not replayed",
        "range_checks": "Get_Range_Checks may construct <=32 ordinary nodes after capture; direct N_Range loop has no enclosing N_Subtype_Indication, so Process_Range_Expr_In_Decl does not insert/analyze its returned check tree",
        "range_comparisons": "<=6F: three range-resolution comparisons, two loop classification comparisons, one Get_Range_Checks Not_Null_Range selection",
        "range_folds": "at most two explicit final endpoint folds per loop; preanalyses have Expander_Active=False",
        "new_index_type": "one internal Integer index subtype; copied base layout, allow one95-Uint discrete-size call and two optional first-freeze nodes/lists for index subtype+parameter",
        "excluded": "parser's existing loop scope/parameter identities; scalar-expression work and raw copies; body constructors; name qualification; warning text/xrefs/elaboration metadata and scope-stack backing; backend and physical recursion stack",
    },
    "Main_input_and_secondary_stack_fixed_skeleton_reduction": {
        "scope": "native initial input construction and Main secondary-stack cleanup, after original literal/source call analysis; fixed capture not included here",
        "witness": 'with Silver_Arguments, Silver_IO; procedure Main is pragma SPARK_Mode (On); D : constant String := Silver_Arguments.First_Or_Default ("x"); begin null; end Main;',
        "input_shape": "one transient scope, one access-all String type, one constant reference capture, two bound constants, one constrained subtype, original D rewritten as renaming; transient entities transferred to Main without a block",
        "main_cleanup_shape": "one secondary-stack mark object; one fixed _finalizer spec/body with one SS_Release call; one at-end reference; no task/controlled/tagged cleanup or frontend handler cloning",
        "source_name_delta": "Find_Type_Of_Object creates T<D>S, length len(D)+2; Constrain_Index creates TT<D>SP1, length len(D)+5; each has at most one fully qualified name with main__ prefix; against D fixture add 4*(len(D)-1) character appends, in addition to source scanner name accounting",
        "serial_name_correction": "bound each generated Main internal name by 12 characters (13 with NUL); sum positive difference against captured length, and include same difference for each qualified-name occurrence; source serial counter must fit Nat",
        "separate_variable_charges": ["source lexical/parser/name/context work", "literal resolution, subtype, range-query and first-size arithmetic", "source D references and diagnostics", "all later source/generated constructors and first freezes", "qualification of variable entities and loop/block scopes", "backend callbacks and emitted representation"],
        "capture_boundary": "before gigi directly covers frontend skeleton; complete-process witness totals may conservatively supply fixed overhead, but do not replace variable backend callback accounting",
        "fixed_query_name_premise": "baseline must include fixed unit-name interning from Is_RTE queries, even for runtime units never loaded",
        "whole_construct_closed": False,
    },
    "normalized_Main_backend_frontier": {
        "source_scalar_types": ["Standard_Integer32 and constrained subtypes", "Standard_Boolean", "Standard_Character8"],
        "source_array_type": "one-dimensional Standard_String with Positive32/Integer32 index bounds; source literals remain String literals, not character aggregates",
        "generated_storage": ["constrained String objects", "String slices", "access-all unconstrained String for first input capture", "access-to-constrained String and secondary-stack allocator for selected concatenations", "ordinary scalar bound/length/position temporaries"],
        "fixed_record_value": "System.Secondary_Stack.Mark_Id: stack pointer plus nested Stack_Pointer (Memory_Index, chunk pointer); imported runtime type, no source-dependent record fields",
        "direct_calls": ["Silver_IO.Put", "Silver_IO.Put_Line", "Silver_Arguments.First_Or_Default", "Silver_Arguments.Input_Is_Valid", "Silver_Arguments.Reject", "System.Img_Int.Image_Integer alias of System.Image_I(Integer)", "System.Concat_2..Concat_9.Str_Concat_2..Str_Concat_9", "System.Secondary_Stack.SS_Allocate", "System.Secondary_Stack.SS_Mark", "System.Secondary_Stack.SS_Release"],
        "generated_local_subprogram": "at most Main's fixed _finalizer for the input/secondary-stack scaffold; no source nested subprograms or per-character helper bodies",
        "excluded": "complete source scalar/assignment/comparison/loop expansion multiplicities; backend lowering helpers/checks/ABI representations and exact GCC modes; fixed library bodies; this is a type/constructor frontier, not a complete backend allocation count",
    },
    "combined_Main_native_emitter_addends": {
        "composition": "direct/scalar/storage at normalized b28/l2 + remaining copies/duplications + up to n suppressed assignment slices at t31/l2, including both check passes and referenced-input actual-subtype creation + first raw-copied scalar passes and result-storage bound captures + one enabled final result slice at t31/l2 + local runtime-call processing; result-object freeze and lookup on still-constrained current values add zero",
        "per_invocation": {
            "ordinary": "(900*n+520)*A+1252*n+1198",
            "Uint": "(3816*n+2296)*A+3696*n+1697",
            "lists": "76*n+95", "growth": "139*n+99",
            "entities_and_names": "28*n+32", "name_characters": "367*n+423",
            "Elist_headers": "10*n+11", "Elist_elements": "20*n+20",
            "hash_wrappers": "30*n+30",
            "positive_Xrefs_increments": "n",
        },
        "uniform_Main_bound_in_c": {
            "ordinary": "(2320*A+3702)*c", "Uint": "(9928*A+9089)*c",
            "lists": "247*c", "growth": "377*c", "entities_and_names": "88*c",
            "name_characters": "1157*c", "Elist_headers": "31*c",
            "Elist_elements": "60*c", "hash_wrappers": "90*c",
            "dynamic_slots": "(20880*A+42079)*c",
            "positive_Xrefs_increments": "2*c",
        },
        "source_sensitive_composition": "sum per-invocation vectors at n_i and A_i=3*H_i+7 from source bound descriptors for these stages; uniform maximum A is optional",
        "residual_addends": ["other source construct rows joined by composed_Main_native_constructor_core", "source-reduced fixed input/Main cleanup capture and variable corrections", "deferred name qualification and native common metadata", "source scanner pools and all physical representations/workspace", "runtime first lookup/spec processing, fixed runtime and backend costs"],
        "examples_not_thresholds": [combined_native_emitter_vector(2, 1),
                                    combined_native_emitter_vector(64, 127),
                                    combined_native_uniform_vector(0, 1),
                                    combined_native_uniform_vector(63, 127)],
        "whole_construct_closed": False,
    },
    "lexical_call_sites_not_a_reachable_call_graph": calls,
    "limitations": ["no native compiler/prover/build execution for this source derivation",
                    "no complete Main source-to-event bound", "no safe language threshold",
                    "no backend or fixed dependency cost included",
                    "frozen reviews cbcd679320 and 26b438ab5c do not cover later additions"],
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
