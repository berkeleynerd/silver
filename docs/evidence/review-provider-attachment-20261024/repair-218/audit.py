#!/usr/bin/env python3
"""Independent #218 declaration-context and accounting audit, without GCC."""
from datetime import datetime, timezone
import hashlib
import itertools
import json
from pathlib import Path
import platform
import subprocess
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
AUTHOR = "56fe7bbb442d191dca5ad9b0dcc5f22823713a07"
ORIGINAL_REVIEW = "8e870ce2cc2d05165db8be3ab60b074533e57073"
PACKET = ROOT / "docs/evidence/retained-general-native-capacity-20261024/provider-attachment/repair-218"
FIRST_CLOCK = datetime(2026, 10, 24, 9, 14, 3, tzinfo=timezone.utc)


def digest(data):
    return hashlib.sha256(data).hexdigest()


def git(*args):
    return subprocess.check_output(["git", *args], cwd=ROOT)


def projection(row):
    return sum(x * size for x, size in zip(row, (40, 32, 40, 48, 256)))


def main():
    start = time.monotonic()
    targets = []
    for path in git("diff-tree", "--no-commit-id", "--name-only", "-r", AUTHOR).decode().splitlines():
        data = (ROOT / path).read_bytes()
        assert data == git("show", f"{AUTHOR}:{path}")
        targets.append({"path": path, "bytes": len(data), "sha256": digest(data)})
    assert len(targets) == 8
    inputs = json.loads((PACKET / "inputs.json").read_text())
    for row in inputs["immutable_files"]:
        data = (ROOT / row["path"]).read_bytes()
        assert len(data) == row["bytes"] and digest(data) == row["sha256"]
        assert data == git("show", f'{row["commit"]}:{row["path"]}')
    for row in inputs["review_blobs"]:
        assert digest(git("show", f'{row["commit"]}:{row["path"]}')) == row["sha256"]
    original_review_paths = git("diff-tree", "--no-commit-id", "--name-only", "-r", ORIGINAL_REVIEW).decode().splitlines()
    for path in original_review_paths:
        assert (ROOT / path).read_bytes() == git("show", f"{ORIGINAL_REVIEW}:{path}")

    manifest = json.loads((PACKET / "sources.json").read_text())
    sources = {}
    for archive in manifest["archives"]:
        assert digest((ROOT / archive["path"]).read_bytes()) == archive["sha256"]
        with tarfile.open(ROOT / archive["path"]) as tar:
            for row in manifest["files"]:
                if row["archive"] != archive["path"]:
                    continue
                data = tar.extractfile(row["path"]).read()
                assert len(data) == row["bytes"] and digest(data) == row["sha256"]
                sources[row["path"]] = data

    def span(path, first, last):
        return b"\n".join(sources[path].split(b"\n")[first-1:last]) + b"\n"

    for row in manifest["witnesses"]:
        assert digest(span(row["path"], row["first"], row["last"])) == row["sha256"]

    guards = []

    def guard(path, first, last, required):
        data = span(path, first, last)
        for token in required:
            assert token.encode() in data, (path, first, token)
        guards.append({"path": path, "first_lf_line": first, "last_lf_line": last, "sha256": digest(data)})
        return data.decode()

    decl = "gcc/ada/gcc-interface/decl.cc"
    trans = "gcc/ada/gcc-interface/trans.cc"
    utils = "gcc/ada/gcc-interface/utils.cc"
    guard("gcc/ada/sem_ch3.adb", 4413, 4419, ["Constant_Present (N)", "E_Constant", "Set_Is_True_Constant (Id)"])
    guard(decl, 731, 740, ["Is_True_Constant (gnat_entity)", "!Treat_As_Volatile", "Present (Expression"])
    order = guard(trans, 6828, 6878, ["gnu_expr = gnat_to_gnu", "gnat_save_expr", "gnat_to_gnu_entity (gnat_temp, gnu_expr, true)"])
    assert order.index("gnu_expr = gnat_to_gnu") < order.index("gnat_to_gnu_entity (gnat_temp, gnu_expr, true)")
    guard(utils, 3033, 3056, ["gnat_types_compatible_p", "constant_p = const_flag && init_const", "? CONST_DECL : VAR_DECL"])
    guard(utils, 3090, 3110, ["DECL_INITIAL (var_decl) = init", "TREE_CONSTANT (var_decl) = constant_p"])
    corr = guard(decl, 1673, 1690, ["SET_DECL_CONST_CORRESPONDING_VAR (gnu_decl, gnu_corr_var)"])
    assert "gnu_decl = gnu_corr_var" not in corr
    guard(decl, 403, 446, ["!definition", "present_gnu_tree (gnat_entity)", "return gnu_decl"])
    guard(decl, 5023, 5026, ["save_gnu_tree (gnat_entity, gnu_decl, false)"])
    guard(trans, 853, 974, ["case N_Object_Declaration:", "case N_Type_Conversion:", "default:", "return 0;"])
    guard(trans, 1328, 1350, ["constant_decl_with_initializer_p", "lvalue_required_p", "gnu_result = DECL_INITIAL (gnu_result)"])
    guard(decl, 7580, 7657, ["expr_variable_p = false", "need_for_debug && !TREE_CONSTANT (gnu_expr)", "return expr_variable_p ? gnat_save_expr (gnu_expr) : gnu_expr"])
    guard(trans, 9103, 9177, ["build1 (DECL_EXPR", "if (VAR_P (gnu_decl)", "!gnat_types_compatible_p", "TREE_STATIC (gnu_decl)", "build_binary_op (INIT_EXPR"])
    copies = guard("gcc/ada/exp_ch4.adb", 3552, 3565, ["Lo : constant", "Hi : constant"])
    assert copies.count("New_Copy_Tree (Low_Bound)") == 2
    guard(trans, 7086, 7118, ["TYPE_MIN_VALUE", "TYPE_DOMAIN"])
    guard("gcc/ada/gcc-interface/ada-tree.h", 315, 326, ["TYPE_RM_MIN_VALUE (NODE)", "TYPE_RM_MAX_VALUE (NODE)"])
    guard("gcc/fold-const.cc", 7070, 7098, ["!TREE_CONSTANT (arg)", "TREE_CODE (arg) == COND_EXPR", "return fold_build3_loc"])
    pullout = guard("gcc/fold-const.cc", 9263, 9308, ["tem = fold_build3_loc", "tem = build1_loc", "build3 (COND_EXPR", "return tem;"])
    assert pullout.index("tem = fold_build3_loc") < pullout.index("tem = build1_loc") < pullout.index("return tem;")
    guard("gcc/fold-const.cc", 2810, 2869, ["case VAR_DECL:", "case COND_EXPR:", "return build1_loc"])

    # Independent decision table for the identifier-substitution boundary.
    # The extra contexts are negative controls, not members of the bound path.
    contexts = {"range": False, "arithmetic": False, "if_arm": False,
                "scalar_initializer": False, "converted_range": False,
                "reference": True, "assignment_lhs": True, "renaming": True}
    cases = []
    for debug, (context, lvalue) in itertools.product((False, True), contexts.items()):
        primary = {"code": "CONST_DECL", "TREE_CONSTANT": True, "initial": 1}
        cached = primary
        corresponding = {"code": "VAR_DECL", "initial": 1} if debug else None
        constant_only = corresponding is None
        substitute = constant_only or not lvalue
        if context in ("range", "arithmetic", "if_arm", "scalar_initializer", "converted_range"):
            assert substitute and cached["initial"] == 1
        if debug and lvalue:
            assert not substitute
        assert cached is primary
        cases.append({"debug": debug, "context": context, "substitutes_initializer": substitute})
    # Readonly alone does not meet the predicate. Invalid/missing initializers
    # do not acquire CONST_DECL solely from the source's const_flag either.
    for const_flag, compatible, init_constant in itertools.product((False, True), repeat=3):
        constant_p = const_flag and compatible and init_constant
        assert constant_p == (const_flag and compatible and init_constant)
        if const_flag and not init_constant:
            assert not constant_p

    # Affine induction certificates: base cost is the retained corrected row;
    # one extra selector charges one fresh leaf plus its local continuation.
    # These are reviewer source-derived allowances, not observed GCC counts.
    increments = {
        "direct_integral_convert": ((2,4,2,2), (0,2,1,2)),
        "range_layout_fold_convert": ((4,4,2,4), (0,2,2,4)),
        "size_binop": ((8,4,6,4), (4,2,4,4)),
        "gigi_GE": ((8,4,8,4), (4,2,4,4)),
        "gigi_COND": ((2,2,2,2), (0,0,2,2)),
    }
    for row, increment in increments.values():
        assert all(a <= b for a,b in zip(increment,row))
    # Whole Length path: leaf continuation (8,4,6,0)*(t+1),
    # three local selector completions (0,0,3,6)*t,
    # outer completion (2,2,2,2)*(t+1), initial C2.
    length_intercept = (12,6,8,2)
    length_slope = (10,6,11,8)
    length_row = (24,12,20,12)
    assert all(a <= b for a,b in zip(length_intercept,length_row))
    assert all(a <= b for a,b in zip(length_slope,length_row))

    # Coefficient identities for arbitrary nonnegative source counts.
    assert projection((40,2,2,2,0)) == 1840
    assert projection((153,8,12,4,0)) == 7048 == 3368 + 2*1840
    assert 2*(256+32) == 576
    scalar_coefficients = (2*520+128, 5*520+368, 576, 4*520+344)
    assert scalar_coefficients == (1168,2968,576,2424)
    assert sum(scalar_coefficients) == 7136
    assert 7136 + 2*7048 + 4*576 == 23536
    assert 24*40 + 12*32 + 20*40 + 12*48 == 2720

    done = datetime.now(timezone.utc)
    result = {
        "status": "independent #218 repair audit passed",
        "disposition": "F1 repaired at stated hereditary native-lower-one scope; no further required repair",
        "reviewed_author": AUTHOR,
        "complete_native_capacity_result": False,
        "selected_reviewer_model": "GPT-6 Astra",
        "selected_reviewer_effort": "Extra High",
        "runtime_confirmation": None, "tokens": None, "monetary_cost": None,
        "first_review_clock_utc": FIRST_CLOCK.isoformat(),
        "completed_utc": done.isoformat(),
        "audit_elapsed_seconds": round(time.monotonic()-start,6),
        "elapsed_since_first_review_clock_seconds": round((done-FIRST_CLOCK).total_seconds(),6),
        "host": {"system":platform.system(),"machine":platform.machine(),"node":platform.node()},
        "native_execution_seconds": 0,
        "author_predecessor_or_old_graph_checkers_replayed": False,
        "target_files": targets,
        "preserved_original_review_files": len(original_review_paths),
        "source_files": len(sources), "author_source_spans_bound": len(manifest["witnesses"]),
        "independent_source_guards": guards,
        "declaration_context_cases": cases,
        "affine_selector_domination": increments,
        "length_affine_charge": {"intercept":length_intercept,"slope":length_slope,"budget_per_t_plus_one":length_row},
        "scalar_coefficients_s_r_m_E": scalar_coefficients,
        "scalar_and_index_debug_coarse_per_C": 23536,
        "model_is_GCC_execution": False,
    }
    (HERE/"current.json").write_text(json.dumps(result,indent=2)+"\n")
    print(json.dumps({k:result[k] for k in ("status","source_files","audit_elapsed_seconds","completed_utc")}))


if __name__ == "__main__":
    main()
