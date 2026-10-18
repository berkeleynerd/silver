#!/usr/bin/env python3
"""Check pinned inputs and structural arithmetic, without running a compiler.

The report supplies the manual branch/reachability argument. Site inventories
are coverage aids, not substitutes for that argument or transitive cost bounds.
"""

import argparse
import hashlib
import json
from pathlib import Path
import re


PIN = "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea"
RANGES = {
    "gcc/ada/exp_ch6.adb": [(6180, 6209), (6224, 6290), (6734, 6745)],
    "gcc/ada/exp_ch7.adb": [(4780, 4821)],
    "gcc/ada/gcc-interface/trans.cc": [
        (3026, 3306), (3313, 3400), (3843, 3941), (4028, 4126),
        (4228, 4249), (4582, 4613), (4864, 4930), (5077, 5110),
        (5391, 5427), (5670, 5758), (5990, 6003), (6078, 6095),
        (6150, 6318), (7944, 8003), (8118, 8146), (8603, 8622),
        (8968, 8996), (9104, 9185), (9217, 9278), (9298, 9325),
        (9492, 9582), (9889, 10025)],
    "gcc/ada/gcc-interface/utils.cc": [
        (682, 783), (894, 1018), (1832, 1859), (3018, 3057),
        (3137, 3162), (3830, 3875)],
    "gcc/ada/gcc-interface/decl.cc": [
        (400, 445), (697, 718), (754, 766), (1177, 1205),
        (1507, 1592), (1629, 1713), (7532, 7688)],
    "gcc/ada/gcc-interface/utils2.cc": [(1890, 1984)],
    "gcc/passes.def": [(27, 42)],
    "gcc/gimple-low.cc": [(122, 214), (1178, 1223)],
    "gcc/gimplify.cc": [(1270, 1282), (1677, 1845)],
    "gcc/calls.cc": [(590, 630), (807, 824)],
    "gcc/tree-cfg.cc": [(2185, 2200), (2628, 2652)],
    "gcc/tree-nested.cc": [(2656, 2719), (3668, 3690)],
}
INTERFACE = ("trans", "utils", "utils2", "decl")


def collect(ada, gcc_root):
    sources, manifest, excerpts = {}, [], [
        "# Pinned gigi structural source excerpts\n",
        "Full-file SHA256 identities are in source-manifest.json; LF numbering.\n",
        "Excerpts expand tabs to eight columns and trim trailing whitespace.\n"]
    for name, ranges in RANGES.items():
        path = (ada / name.removeprefix("gcc/ada/")
                if name.startswith("gcc/ada/") else gcc_root / name)
        data = path.read_bytes()
        manifest.append({"path": name, "bytes": len(data),
                         "sha256": hashlib.sha256(data).hexdigest()})
        source = data.decode()
        sources[name] = source
        lines = source.splitlines()
        for low, high in ranges:
            assert 1 <= low <= high <= len(lines)
            excerpts.append(f"\n## {name}:{low}–{high}\n\n```text\n")
            excerpts.extend((f"{n}: " + lines[n-1].expandtabs(8)).rstrip()+"\n"
                            for n in range(low, high+1))
            excerpts.append("```\n")
    patterns = {
        "binding_push": r"\bgnat_pushlevel\s*\(",
        "cleanup_shapes": r"\b(?:TARGET_EXPR|CLEANUP_POINT_EXPR|WITH_CLEANUP_EXPR|TRY_FINALLY_EXPR|TRY_CATCH_EXPR|BIND_EXPR)\b",
        "var_declaration_routes": r"\b(?:create_var_decl|create_temporary|create_init_temporary|create_tmp_var|create_tmp_var_raw|build_decl)\s*\(",
    }
    inventory = {key: [] for key in patterns}
    for stem in INTERFACE:
        name = f"gcc/ada/gcc-interface/{stem}.cc"
        source = sources[name]
        for key, pattern in patterns.items():
            for match in re.finditer(pattern, source):
                line = source.count("\n", 0, match.start()) + 1
                inventory[key].append({"path": name, "line": line,
                                       "match": match.group()})
    return sources, {"commit": PIN, "files": manifest}, "".join(excerpts), inventory


def check_sources(sources, inventory):
    trans = sources["gcc/ada/gcc-interface/trans.cc"]
    exp6 = sources["gcc/ada/exp_ch6.adb"]
    exp7 = sources["gcc/ada/exp_ch7.adb"]
    passes = sources["gcc/passes.def"]
    assert passes.index("NEXT_PASS (pass_lower_cf)") < passes.index(
        "NEXT_PASS (pass_lower_eh)")
    assert "Add_Return (Spec_Id, Statements (HSS));" in exp6
    assert "Append_To (Stmts, Stmt);\n            Set_Analyzed (Stmt);" in exp6
    assert "Set_At_End_Proc (N, New_Occurrence_Of (Fin_Id, Sloc (N)))" in exp7
    begin = trans.index("\nSubprogram_Body_to_gnu (")
    end = trans.index("\n}\n", begin)
    body = trans[begin:end]
    assert body.index("add_stmt (gnat_to_gnu (Handled_Statement_Sequence") < body.index(
        "At_End_Proc_to_gnu (gnat_node)")
    assert "vec_safe_push (gnu_return_label_stack, NULL_TREE);" in body
    begin = trans.index("\ngnat_gimplify_stmt (tree *stmt_p)")
    end = trans.index("    case EXIT_STMT:", begin)
    loop = trans[begin:end]
    assert loop.index("append_to_statement_list (LOOP_STMT_BODY") < loop.index(
        "tree t = build1 (GOTO_EXPR")
    assert loop.count("create_artificial_label (") == 1
    assert loop.count("build1 (LABEL_EXPR") == 2
    assert loop.count("build1 (GOTO_EXPR") == 2
    # Five optimization-annotation COND-adjacent build3 calls are excluded by
    # the selected flags; the executable condition is one explicit COND_EXPR.
    assert loop.count("build3 (COND_EXPR") == 1
    nested = sources["gcc/tree-nested.cc"]
    assert len(re.findall(r"\bget_nl_goto_field\s*\(", nested)) == 2
    assert not any(row["match"] in {"TARGET_EXPR", "CLEANUP_POINT_EXPR",
                                    "WITH_CLEANUP_EXPR"}
                   for row in inventory["cleanup_shapes"])


def arithmetic():
    # Enumerate the call state machine: optional early R, optional late R,
    # and optional CICO P. A temporary only gets made if none already exists.
    call_result_max = 0
    for early in (0, 1):
        for late in (0, 1):
            for cico in (0, 1):
                retval = early
                result_temps = early
                if late and not retval:
                    retval = 1
                    result_temps += 1
                if cico and not retval:
                    result_temps += 1
                call_result_max = max(call_result_max, result_temps)
    assert call_result_max == 1
    # These coefficients arise from the listed sites, not fit measurements.
    push = {"U": 1, "F": 2, "B": 1, "L": 2, "C": 1, "X": 1}
    bind = {"U": 1, "F": 1, "B": 1, "L": 2, "C": 1, "X": 0}
    return {
        "binding_push_coefficients": push,
        "retained_bind_coefficients": bind,
        "main_fixed_framework_push_requests": push["U"] + 2*push["F"],
        "main_fixed_framework_bind_upper_bound": bind["U"] + 2*bind["F"],
        "result_temporary_requests_per_call_upper_bound": call_result_max,
        "loop_lowering_direct_executable_node_requests": 2+2+1,
        "loop_lowering_direct_executable_operand_slots": 2+2+3,
        "loop_lowering_additional_label_declarations": 1,
        "outer_cleanup_eh_Q_upper_bound": 1,
        "outer_cleanup_eh_D_upper_bound": 1,
        "outer_cleanup_eh_may_return": False,
        "inner_cleanup_eh_Q_and_D": 0,
        "clobber_upper_bound": "sum of local VAR_DECL entries in retained BINDs",
        "bind_cleanup_statement_upper_bound": "eligible locals + at most one stack_restore",
        "scope": "source identities, local event counts and interface only; not transitive gigi allocation or compiler success",
    }


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ada", type=Path, required=True)
    parser.add_argument("--gcc-root", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    parser.add_argument("--record", action="store_true",
                        help="Write the pinned manifest/excerpts/inventory initially")
    args = parser.parse_args()
    bundle = Path(__file__).resolve().parent
    sources, manifest, excerpts, inventory = collect(args.ada, args.gcc_root)
    # Anchor Ada identities against the previously retained full source inventory.
    prior = bundle.parent / "unbounded-programs/continuation-20261017/frontend-lifetimes/complete-source-manifest.json"
    known_ada = {"gcc/ada/"+x["path"]: x for x in json.loads(prior.read_text())["files"]}
    for row in manifest["files"]:
        if row["path"].startswith("gcc/ada/"):
            assert row["sha256"] == known_ada[row["path"]]["sha256"]
    check_sources(sources, inventory)
    records = {"source-manifest.json": manifest, "site-inventory.json": inventory}
    if args.record:
        for name, value in records.items():
            (bundle / name).write_text(json.dumps(value, indent=2)+"\n")
        (bundle / "source-excerpts.md").write_text(excerpts)
    else:
        for name, value in records.items():
            assert json.loads((bundle / name).read_text()) == value, name
        assert (bundle / "source-excerpts.md").read_text() == excerpts
    result = {"commit": PIN, "source_files_checked": len(manifest["files"]),
              "arithmetic": arithmetic(), "compiler_runs": 0,
              "solver_runs": 0, "lean_builds": 0}
    args.output.write_text(json.dumps(result, indent=2)+"\n")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
