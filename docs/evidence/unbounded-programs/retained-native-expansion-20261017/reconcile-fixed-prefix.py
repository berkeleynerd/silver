#!/usr/bin/env python3
"""Inventory collection entry points in the retained upstream source corpus.

The report supplies the selected-path exclusion argument. Lexical inventory is
not a call-graph proof or binary observation. No compiler/prover is executed.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re


parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--gcc-root", type=Path, required=True)
parser.add_argument("--output", type=Path, required=True)
args = parser.parse_args()
manifest_bytes = (args.gcc_root / "manifest.json").read_bytes()
manifest_digest = hashlib.sha256(manifest_bytes).hexdigest()
assert manifest_digest == "6f0991bf5e0e98ab27d165696913f4db31a9bd9336afcc48937cdbdb0de12480"
manifest = json.loads(manifest_bytes)
assert manifest["commit"] == "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea"
mentions = []
sources = {}
for record in manifest["files"]:
    raw = (args.gcc_root / record["path"]).read_bytes()
    assert len(raw) == record["bytes"], record["path"]
    assert hashlib.sha256(raw).hexdigest() == record["sha256"], record["path"]
    text = raw.decode()
    sources[record["path"]] = text
    for number, line in enumerate(text.split("\n"), 1):
        if re.search(r"\bggc_(collect|grow|trim)\b", line):
            mentions.append({"path": record["path"], "line": number,
                             "text": line.strip()})
assert len(manifest["files"]) == 4929
assert len(mentions) == 53


def between(path, start, end):
    text = sources[path]
    a = text.index(start)
    return text[a:text.index(end, a + len(start))]


alloc = between("gcc/ggc-page.cc", "ggc_internal_alloc_ (size_t size",
                "/* Mark function for strings.  */")
assert "ggc_collect" not in alloc and "ggc_grow" not in alloc
assert "timevar_ggc_mem_total += object_size" in alloc
realloc = between("gcc/ggc-common.cc", "ggc_realloc (void *x, size_t size",
                  "ggc_cleared_alloc_htab_ignore_args")
assert "ggc_collect" not in realloc and "ggc_grow" not in realloc
assert "ggc_free (x)" in realloc
trans = sources["gcc/ada/gcc-interface/trans.cc"]
prefix = trans[:trans.index("  Compilation_Unit_to_gnu (gnat_root);")]
assert "ggc_collect" not in prefix
assert "rest_of_subprog_body_compilation" not in prefix
assert "No_Strict_Aliasing_CP" in prefix
utils = sources["gcc/ada/gcc-interface/utils.cc"]
assert "build_translation_unit_decl (get_identifier (main_input_filename))" in utils
assert "associate_gnat_to_gnu = ggc_cleared_vec_alloc<tree> (max_gnat_nodes)" in utils
assert "dummy_node_table = ggc_cleared_vec_alloc<tree> (max_gnat_nodes)" in utils

result = {
    "scope": "Selected native source prefix before Compilation_Unit_to_gnu, with selected-path argument",
    "gcc_commit": manifest["commit"],
    "source_manifest_sha256": manifest_digest,
    "verified_source_files": len(manifest["files"]),
    "verified_source_bytes": sum(r["bytes"] for r in manifest["files"]),
    "collection_name_mentions": mentions,
    "mentions_include_comments_declarations_and_other_frontends": True,
    "handwritten_exclusions": {
        "cgraph": "No pre-Main function finalization, analysis or expansion",
        "passes": "Pass construction occurs; pass execution and IPA summary reading do not",
        "statistics": "Report sites occur after parsing/compilation; no selected memory-report option",
        "selftests": "No self-test option, and top-level selftests follow do_compile",
        "other_frontends_and_plugins": "Selected Ada native non-LTO invocation has no plugin",
        "allocation": "Allocation and reallocation never invoke collection; explicit frees remain",
    },
    "null_token_class_fixed_root_read_projection": True,
    "other_source_classes_require_matching_read_projection": True,
    "source_sensitive_metadata_charged_separately": [
        "filenames and line maps", "two max_gnat_nodes pointer arrays",
        "identifier hash backing", "translation-unit main_input_filename identifier",
        "Ada numeric table positions and backing",
    ],
    "compiler_or_prover_execution": False,
    "binary_counter_availability_established": False,
    "numeric_GCC_setup_bound_established": False,
    "complete_GCC_capacity_established": False,
}
args.output.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
print(json.dumps({"verified_sources": len(manifest["files"]),
                  "collection_name_mentions": len(mentions),
                  "compiler_or_prover_execution": False}))
