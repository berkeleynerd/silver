#!/usr/bin/env python3
"""Check source identities/sites for the handwritten null-unit symbol join.

This does not run GCC or simulate its initialization/lowering. The research
record supplies the path argument and requires the selected configuration and
null-body transfers; these checks only prevent accidental source/input drift.
"""
import argparse
import hashlib
import json
from pathlib import Path


parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--gcc-root", type=Path, required=True)
parser.add_argument("--output", type=Path, required=True)
args = parser.parse_args()
bundle = Path(__file__).resolve().parent
manifest = json.loads((bundle / "null-symbols-source-identity.json").read_text())
assert manifest["commit"] == "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea"
sources = {}
for record in manifest["files"]:
    raw = (args.gcc_root / record["path"]).read_bytes()
    assert len(raw) == record["bytes"], record["path"]
    assert hashlib.sha256(raw).hexdigest() == record["sha256"], record["path"]
    sources[record["path"]] = raw.decode()


def between(path, start, end):
    text = sources[path]
    a = text.index(start)
    return text[a:text.index(end, a + len(start))]


utils = "gcc/ada/gcc-interface/utils.cc"
trans = "gcc/ada/gcc-interface/trans.cc"
builtin_hook = between(utils, "gnat_builtin_function (tree decl)",
                       "/* Return an integer type")
assert "gnat_pushdecl (decl, Empty);" in builtin_hook
assert "cgraph" not in builtin_hook and "varpool" not in builtin_hook
push = between(utils, "gnat_pushdecl (tree decl, Node_Id gnat_node)",
               "/* Pointer types aren't named types")
for site in ("vec_safe_push (builtin_decls, decl)",
             "vec_safe_push (global_decls, decl)",
             "add_decl_expr (decl, gnat_node)"):
    assert site in push, site
assert "cgraph" not in push and "varpool" not in push
assert "#define LANG_HOOKS_BUILTIN_FUNCTION_EXT_SCOPE\tLANG_HOOKS_BUILTIN_FUNCTION" in sources["gcc/langhooks-def.h"]
decl_finish = between("gcc/passes.cc", "rest_of_decl_compilation (tree decl,",
                      "/* Called after")
assert "else if (finalize && TREE_CODE (decl) != FUNCTION_DECL)" in decl_finish
assert "varpool_node::finalize_decl (decl)" in decl_finish
assert "assemble_alias (decl, alias)" in decl_finish

elaboration = between(trans, "  /* Finally see if we have any elaboration procedures",
                      "  /* Destroy ourselves.  */")
assert "if (!gnu_stmts || empty_stmt_list_p (gnu_stmts))" in elaboration
assert "Set_Has_No_Elaboration_Code (info->gnat_node, 1);" in elaboration
assert elaboration.count("rest_of_subprog_body_compilation") == 1
global_output = between(utils, "gnat_write_global_declarations (void)",
                        "GCC builtins support")
assert global_output.count("varpool_node::get_create") == 1
assert global_output.count("(!DECL_EXTERNAL (iter) || !DECL_IGNORED_P (iter))") == 2
assert "node->force_output = 1" in global_output
assert "DECL_INITIAL (dummy_global)" not in global_output

target = sources["gcc/config/i386/i386-builtins.cc"]
cpu_fold = target.index("fold_builtin_cpu (tree fndecl, tree *args)")
assert "varpool_node::" not in target[:cpu_fold]
assert target.count("varpool_node::add (") == 2
assert "cgraph_node::" not in target
assert "set_decl_section_name" not in target
for name in manifest["selected_target_headers"]:
    for selector in ("SUBTARGET_INIT_BUILTINS", "SUBTARGET_INSERT_ATTRIBUTES",
                     "TARGET_OPTION_RELAYOUT_FUNCTION"):
        assert selector not in sources[name], (name, selector)

layout = sources["gcc/stor-layout.cc"]
assert layout.count("vec_safe_push (size_functions, fndecl)") == 1
assert "if (CONTAINS_PLACEHOLDER_P (size))\n    return self_referential_size (size);" in layout
assert "for (i = 0; size_functions && size_functions->iterate (i, &fndecl); i++)" in layout
var_analyze = between("gcc/varpool.cc", "varpool_node::analyze (void)",
                      "/* Assemble thunks and aliases")
assert "else if (DECL_INITIAL (decl))\n    record_references_in_initializer (decl, analyzed);" in var_analyze
edges = between("gcc/cgraphbuild.cc", "pass_build_cgraph_edges::execute (function *fun)",
                "} // anon namespace")
for site in ("if (gcall *call_stmt = dyn_cast <gcall *> (stmt))",
             "node->record_stmt_references (stmt)",
             "record_eh_tables (node, fun)",
             "TREE_STATIC (decl) && !DECL_EXTERNAL (decl)"):
    assert site in edges, site

result = {
    "scope": "Exact declaration-free null Main, selected native Linux x86_64 O0/non-LTO configuration",
    "gcc_commit": manifest["commit"],
    "verified_source_files": len(manifest["files"]),
    "symbol_ingress": {
        "common_and_target_builtin_registration_nodes": 0,
        "fixed_external_runtime_function_nodes": 0,
        "fixed_external_ignored_OTHERS_variable_nodes": 0,
        "Boolean_CONST_DECL_symbol_nodes": 0,
        "empty_elaboration_function_nodes": 0,
        "self_referential_size_function_nodes": 0,
        "finalized_Main_function_nodes": 1,
        "forced_dummy_variable_nodes": 1,
    },
    "incoming_IPA_join": {
        "function_nodes": 1, "variable_nodes": 1,
        "call_edges": 0, "symbol_references": 0,
        "variable_initializers": 0, "aliases": 0, "thunks": 0,
        "nested_functions": 0, "constructors": 0, "destructors": 0,
    },
    "handwritten_source_path_argument_required": True,
    "null_body_and_effective_configuration_transfers_required": True,
    "builtin_DECL_type_helper_allocation_costs_remain": True,
    "complete_GCC_capacity_established": False,
    "compiler_or_prover_execution": False,
}
args.output.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
print(json.dumps({"verified_sources": len(manifest["files"]),
                  "incoming_IPA_join": result["incoming_IPA_join"],
                  "complete_GCC_capacity_established": False}))
