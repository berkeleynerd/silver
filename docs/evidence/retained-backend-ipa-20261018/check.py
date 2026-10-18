#!/usr/bin/env python3
"""Check retained source identities and the null-unit IPA schedule inventory.

No compiler execution. Shape preservation is the report's handwritten source
argument, conditional on its complete incoming-unit/configuration premises.
"""

import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile


EXPECTED = [
    "ipa_auto_profile_offline", "ipa_free_lang_data",
    "ipa_function_and_variable_visibility", "ipa_strub_mode",
    "build_ssa_passes", "target_clone", "local_optimization_passes",
    "ipa_remove_symbols", "ipa_strub", "ipa_oacc", "target_clone",
    "ipa_auto_profile", "ipa_tree_profile", "ipa_free_fn_summary",
    "ipa_increase_alignment", "ipa_tm", "ipa_lower_emutls", "ipa_asm_lgen",
    "analyzer", "ipa_asm_wpa", "ipa_odr", "ipa_whole_program_visibility",
    "ipa_profile", "ipa_icf", "ipa_devirt", "ipa_cdtor_merge", "ipa_cp",
    "ipa_sra", "ipa_fn_summary", "ipa_inline", "ipa_locality_cloning",
    "ipa_pure_const", "ipa_modref", "ipa_free_fn_summary", "ipa_reference",
    "ipa_single_use", "ipa_comdats", "ipa_pta", "omp_simd_clone",
]


def schedule(source):
    result = []
    group = None
    depth = 0
    groups = {"all_small_ipa_passes", "all_regular_ipa_passes",
              "all_late_ipa_passes"}
    for line_no, line in enumerate(source.split("\n"), 1):
        start = re.search(r"INSERT_PASSES_AFTER \((\w+)\)", line)
        if start and start[1] in groups:
            group, depth = start[1], 0
        if group is None:
            continue
        if "PUSH_INSERT_PASSES_WITHIN" in line:
            depth += 1
        if "POP_INSERT_PASSES" in line:
            depth -= 1
            assert depth >= 0
        entry = re.search(r"NEXT_PASS \(pass_(\w+)", line)
        if entry and depth == 0:
            result.append({"group": group, "line": line_no, "pass": entry[1]})
        if "TERMINATE_PASS_LIST" in line:
            assert depth == 0
            group = None
    assert [row["pass"] for row in result] == EXPECTED
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--gcc-root", type=Path)
    args = parser.parse_args()
    bundle = Path(__file__).resolve().parent
    manifest = json.loads((bundle / "identity.json").read_text())
    assert manifest["commit"] == "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea"
    source = {}
    verified = []
    with tarfile.open(bundle / "sources.tar.gz") as archive:
        for record in manifest["files"]:
            name = record["path"]
            data = archive.extractfile(name).read()
            assert len(data) == record["bytes"], name
            assert hashlib.sha256(data).hexdigest() == record["sha256"], name
            if args.gcc_root:
                assert (args.gcc_root / name).read_bytes() == data, name
            source[name.removeprefix("gcc/")] = data.decode()
            verified.append({"path": name, "sha256": record["sha256"]})

    # These sites connect the report to unconditional/early-return paths that
    # could otherwise be accidentally replaced by an O0/no-work assumption.
    assert "first_global_object_name = ggc_strdup" in source["ada/gcc-interface/trans.cc"]
    global_output = source["ada/gcc-interface/utils.cc"].split(
        "gnat_write_global_declarations (void)", 1)[1].split(
        "GCC builtins support", 1)[0]
    for text in ("build_decl (BUILTINS_LOCATION, VAR_DECL", "void_type_node",
                 "DECL_HARD_REGISTER (dummy_global) = 1",
                 "node = varpool_node::get_create (dummy_global)",
                 "node->force_output = 1"):
        assert text in global_output, text
    fld = source["ipa-free-lang-data.cc"]
    assert "free_lang_data_d () : decls (100), types (100) {}" in fld
    routine = fld.split("free_lang_data (void)", 1)[1]
    assert routine.index("class free_lang_data_d fld") < routine.index("if (in_lto_p")
    assert "hash_map<symtab_node *, tree> map (251)" in source["ipa-comdats.cc"]
    assert "if (!comdat_group_seen)" in source["ipa-comdats.cc"]
    assert "if (!summaries && !summaries_lto)" in source["ipa-modref.cc"]
    assert "if (!flag_ipa_modref" in source["ipa-modref.cc"]
    assert "Init(OMP_TARGET_SIMD_CLONE_NONE)" in source["common.opt"]
    assert "if (attr == NULL_TREE)\n    return;" in source["omp-simd-clone.cc"]
    assert "new_indirect_edges.create (8)" in source["ipa-inline.cc"]
    assert "if (!opt_for_fn (node->decl, optimize)" in source["ipa-inline.cc"]
    assert "if (!prg_ctr_mask)\n    return false;" in source["coverage.cc"]
    assert "node->ipa_transforms_to_apply.safe_push ((ipa_opt_pass_d *)pass)" in source["passes.cc"]
    assert "inline_transform, /* function_transform */" in source["ipa-inline.cc"]
    assert "if (preserve_function_body_p (node))" in source["ipa-inline-transform.cc"]
    assert "if (node->callees && (opt_for_fn (node->decl, optimize) || has_inline))" in source["ipa-inline-transform.cc"]
    assert "if (!need_ssa_update_p (cfun))\n    return;" in source["tree-into-ssa.cc"]

    symbol_path = bundle.parent / "unbounded-programs/retained-native-expansion-20261017/native-null-symbols.json"
    symbol_join = json.loads(symbol_path.read_text())
    assert symbol_join["gcc_commit"] == manifest["commit"]
    for name, expected in {"function_nodes": 1, "variable_nodes": 1,
                           "call_edges": 0, "symbol_references": 0,
                           "variable_initializers": 0}.items():
        assert symbol_join["incoming_IPA_join"][name] == expected
    result = {
        "verified_files": verified,
        "top_level_ipa_schedule": schedule(source["passes.def"]),
        "input_premise": {"function_nodes": 1, "variable_nodes": 1,
                          "call_edges": 0, "symbol_references": 0},
        "handwritten_shape_transfer": {
            "additional_functions": 0, "additional_executable_statements": 0,
            "additional_call_edges": 0, "additional_variable_initializers": 0,
            "source_argument_required": True,
        },
        "small_container_parameters": {
            "reachability_entries_per_call": 2,
            "reverse_postorder_stack_records": 1,
            "reduced_postorder_stack_pointers": 1,
            "reduced_postorder_dfs_records": 1,
            "reduced_postorder_splay_nodes": 1,
            "inliner_order_array_pointers_each": 1,
            "inliner_indirect_edge_vector_initial_pointers": 8,
            "free_language_data_initial_vector_pointers_each": 100,
            "comdat_map_initial_request_each": 251,
            "pending_function_transform_entries": 1,
        },
        "complete_setup_capacity_established": False,
        "complete_incoming_gigi_unit_established": True,
        "incoming_symbol_join_sha256": hashlib.sha256(symbol_path.read_bytes()).hexdigest(),
        "incoming_unit_configuration_and_body_premises_required": True,
        "compiler_or_proof_executed": False,
    }
    args.output.write_text(json.dumps(result, indent=2) + "\n")
    print(f"Verified {len(verified)} complete sources and {len(EXPECTED)} IPA registrations")


if __name__ == "__main__":
    main()
