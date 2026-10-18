#!/usr/bin/env python3
"""Reconcile source-derived null Main gigi roots, not GCC helper capacity."""
import argparse
import hashlib
import json
from pathlib import Path
import re

parser = argparse.ArgumentParser()
parser.add_argument("--ada", type=Path, required=True)
parser.add_argument("--output", type=Path, required=True)
args = parser.parse_args()
repo = Path(__file__).resolve().parents[4]
manifest = json.loads((repo / "docs/evidence/unbounded-programs/"
    "continuation-20261017/frontend-lifetimes/complete-source-manifest.json").read_text())
expected = {entry["path"]: entry for entry in manifest["files"]}
identities, src = {}, {}
for name in ("gcc-interface/trans.cc", "gcc-interface/decl.cc", "gcc-interface/utils.cc",
             "gcc-interface/misc.cc", "gcc-interface/gigi.h", "types.h", "cstand.adb",
             "einfo-utils.adb", "gnat1drv.adb", "lib-writ.adb", "sem_ch10.adb",
             "sem_util.adb", "sem_ch3.adb", "sem_ch6.adb", "sem_prag.adb",
             "sem_ch13.adb", "exp_ch8.adb", "exp_util.adb", "checks.adb",
             "freeze.adb", "frontend.adb", "par-ch10.adb"):
    raw = (args.ada/name).read_bytes()
    sha = hashlib.sha256(raw).hexdigest()
    assert sha == expected[name]["sha256"], name
    identities[name] = dict(bytes=len(raw), sha256=sha,
        git_blob_sha1=hashlib.sha1(b"blob "+str(len(raw)).encode()+b"\0"+raw).hexdigest())
    src[name] = raw.decode()
trans = src["gcc-interface/trans.cc"]
cstand = src["cstand.adb"]
a = cstand.index("      Build_Exception_Type : declare")
b = cstand.index("         Layout_Type (Standard_Exception_Type);",a)
fields = re.findall(r'Make_Aliased_Component \(Standard_Exception_Type, (Standard_\w+),\s*"([^"]+)"\);',cstand[a:b])
assert len(fields) == 7
assert [typ for typ,_ in fields] == ["Standard_Boolean", "Standard_Character",
    "Standard_Natural", "Standard_Address", "Standard_A_Char", "Standard_Address", "Standard_A_Char"]
a = trans.index("  /* Now declare run-time functions.  */")
b = trans.index("  /* If in no exception handlers mode,",a)
direct_runtime = trans[a:b].count("create_subprog_decl")
assert direct_runtime == 12
last_reason = int(re.search(r"#define LAST_REASON_CODE (\d+)",src["types.h"]).group(1))
assert last_reason == 39
assert "first_global_object_name = ggc_strdup (IDENTIFIER_POINTER (t));" in trans
assert "node = varpool_node::get_create (dummy_global);" in src["gcc-interface/utils.cc"]
assert "bool const_decl_allowed_p = true" in src["gcc-interface/gigi.h"]
assert "if (type_annotate_only && gnat_node == Cunit (Main_Unit))" in trans

result = dict(
    scope="Exact declaration-free null Main, selected ordinary native mode; source-root inventory, not tool execution or complete GCC capacity",
    gcc_commit=manifest["commit"], source_inputs=identities,
    gigi_cached_Standard_bases=["Address", "Integer", "Character", "Boolean"],
    direct_uncached_semantic_type_roots=["Standard_Exception_Type", "Standard_Natural",
        "Standard_A_Char", "Standard_Long_Long_Float"],
    exception_components=[dict(type=typ,name=name) for typ,name in fields],
    Boolean_literal_CONST_DECLs=2,
    external_ignored_OTHERS_VAR_DECLs=3,
    direct_fixed_runtime_FUNCTION_DECL_upper_bound=direct_runtime+2*(last_reason+1),
    direct_fixed_runtime_RESULT_DECL_upper_bound=direct_runtime+2*(last_reason+1),
    largest_direct_fixed_runtime_argument_count=5,
    Main_FUNCTION_DECLs=1, compilation_unit_elaboration_FUNCTION_DECLs=1,
    body_local_LABEL_DECLs=1, forced_dummy_global_VAR_DECLs=1,
    forced_dummy_global_varpool_nodes=1,
    source_object_declarations=0,
    Main_aux_elaboration_counter_objects=0,
    Main_aux_source_or_generated_pragmas_with_executable_effect=0,
    Main_final_freeze_nodes_upper_bound=1,
    Main_final_freeze_new_semantic_type_conversions=0,
    native_walk_all_withed_entities=False,
    System_text_dependency_implies_semantic_Unit_or_gigi_walk=False,
    target_and_common_GCC_builtins_included=False,
    GCC_helper_requests_layout_backannotation_and_caches_priced=False,
    complete_native_capacity_result=False,
    compiler_or_prover_execution=False,
    remaining="Common/target GCC builtin inventory and initialization; helper/identifier/type/field layout and callback quantities; global declaration/cgraph/varpool pipeline and object/link consumers")
args.output.write_text(json.dumps(result, indent=2, sort_keys=True)+"\n")
print(json.dumps(dict(verified_sources=len(identities), exception_fields=len(fields),
    direct_runtime_function_bound=result["direct_fixed_runtime_FUNCTION_DECL_upper_bound"],
    complete_native_capacity_result=False)))
