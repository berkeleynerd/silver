#!/usr/bin/env python3
"""Join retained fixed Why3 prefix evidence, offline; no toolchain execution.

The numeric and identity checks are executable. Reachability and the complete
operation partition are inspected source arguments in the linked research note,
not properties proved by this checker or by its deliberately broad text scan.
"""
import argparse
import gzip
import hashlib
import json
from pathlib import Path
import re
import subprocess
import sys
import tarfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
EVIDENCE = HERE.parent
NAMES = ("put_line", "put", "first_or_default", "input_is_valid", "is_message")
LIMIT = 2**62 - 1
PATTERNS = {
    "term_size": r"\bterm_(?:branch_)?size\b",
    "numeric_candidates": r"\bincr\b|\bdecr\b|\bsucc\b|\bpred\b|[+*/]|\s-\s|\b(?:lsl|lsr|asr|mod|int_of_string|to_int)\b",
    "dispatch_candidates": r"Reduction_engine|set_infer_invs|split_version|Stats\.|prepare_task|apply_transform|register.*transform",
}


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def archive(path):
    with tarfile.open(path) as stream:
        files = [m for m in stream.getmembers() if m.isfile()]
        assert len({m.name for m in files}) == len(files)
        return {m.name: stream.extractfile(m).read() for m in files}


def scan_sources(sources):
    # This is an overinclusive search aid, including comments and type syntax.
    # It is not an OCaml parser or an independently verified call graph.
    hits = {key: [] for key in PATTERNS}
    for path, data in sorted(sources.items()):
        if not path.endswith((".ml", ".mli", ".mll", ".mly")):
            continue
        for line, text in enumerate(data.decode().splitlines(), 1):
            for kind, pattern in PATTERNS.items():
                if re.search(pattern, text):
                    hits[kind].append({"path": path, "line": line, "text": text})
    return hits


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    manifest = json.loads((HERE / "identity.json").read_bytes())
    for name, expected in manifest["dependencies"].items():
        assert identity((REPO / name).read_bytes()) == expected, name
    assert identity((HERE / "sources.tar.gz").read_bytes()) == manifest["archive"]["identity"]
    sources = archive(HERE / "sources.tar.gz")
    assert {n: identity(b) for n, b in sources.items()} == manifest["archive"]["members"]
    scan_bytes = (HERE / "source-scan.json.gz").read_bytes()
    assert scan_sources(sources) == json.loads(gzip.decompress(scan_bytes))
    assert identity(scan_bytes) == manifest["source_scan"]

    gc_dir = EVIDENCE / "retained-producer-prefix-gc-20261018"
    count_dir = EVIDENCE / "retained-producer-prefix-counts-20261018"
    context_dir = EVIDENCE / "retained-producer-fixed-context-20261018"
    # Each dependency checker compares its recomputation to its retained result.
    # Context's checker also invokes its ordinary-success witness checker.
    for script in (context_dir / "check.py", gc_dir / "check.py",
                   gc_dir / "dimensions_check.py", count_dir / "check.py"):
        subprocess.run([sys.executable, str(script)], check=True,
                       stdout=subprocess.DEVNULL, cwd=REPO)

    old_sources = archive(gc_dir / "sources.tar.gz")
    previous_scan = json.loads(old_sources["why3/source-scan.json"])
    assert len(previous_scan["files"]) == 293
    for path, expected in previous_scan["files"].items():
        assert identity(sources[path]) == expected, path

    current = archive(count_dir / "observations.tar.gz")
    plan = json.loads(current["plan.json"])
    context_id = json.loads((context_dir / "identity.json").read_bytes())
    context = json.loads((context_dir / "result.json").read_bytes())
    dimensions = json.loads((gc_dir / "dimensions-result.json").read_bytes())
    allocations = json.loads((gc_dir / "result.json").read_bytes())
    counts = json.loads((count_dir / "result.json").read_bytes())
    assert previous_scan["why3_revision"] == context_id["why3_revision"] == plan["source_revision"] == manifest["why3_revision"]
    assert plan["protected_start"] == "camlWhy3__Exn_printer__entry"
    assert plan["endpoint"] == {"symbol": "camlGnat_checks__init_1987", "address": 0x52ff00}
    assert [c["name"] for c in plan["inputs"]] == list(NAMES)
    assert [c["name"] for c in allocations["cases"]] == list(NAMES)
    assert [c["name"] for c in counts["cases"]] == list(NAMES)
    fixed = {c["name"]: c for c in context_id["fixed_inputs"]}
    input_rows = []
    for case in plan["inputs"]:
        name, filename = case["name"], case["argv"][-1]
        data = current[name + "/" + filename]
        expected = {k: fixed[name][k] for k in ("bytes", "sha256")}
        assert identity(data) == case["input"] == expected
        assert case["environment"]["OCAMLRUNPARAM"] == "s=256M,h=16M,M=1000"
        assert set(case["environment"]) == {"PATH", "LC_ALL", "TMPDIR", "OCAMLRUNPARAM"}
        assert case["argv"][1:-1] == ["--entity", case["argv"][2], "--prover", "cvc5,z3,altergo",
                                       "--proof", "progressive", "--steps", "0", "--timeout", "0",
                                       "--counterexample", "off"]
        assert b"infer" not in data
        assert b"infer" not in current[name + "/why3.conf"]
        input_rows.append({"name": name, "filename": filename, **expected})

    # Join all eleven native import files to the complete installed-text set,
    # which is already joined by dimensions_check to the guarded native plan.
    texts = archive(gc_dir / "dimensions-sources.tar.gz")
    library_rows = [r for r in context_id["files"] if "library_path" in r]
    assert len(library_rows) == context["library_files"] == 11
    for row in library_rows:
        assert identity(texts[row["path"]]) == {k: row[k] for k in ("bytes", "sha256")}
    installed = {p: b for p, b in texts.items() if p.startswith("installed/")}
    assert len(installed) == 165
    assert all(b"infer" not in b for b in installed.values())

    # No complete source caller of term_size occurs in a selected prefix module.
    # The explanation for excluding these callers is an inspected argument.
    size_paths = sorted({h["path"] for h in scan_sources(sources)["term_size"]})
    assert size_paths == ["plugins/strategies/forward_propagation.ml",
                          "src/core/term.ml", "src/core/term.mli",
                          "src/transform/reduction_engine.ml"]
    w = allocations["maximum_prefix_allocation_words"]
    b = dimensions["combined_managed_and_static_word_budget"]
    assert w == 86632681 and b == 88828616
    numeric = {
        "positive_identity_and_traversal_counter": {"upper": w + 1, "limit": LIMIT},
        "synthetic_location_line": {"upper": w + 1, "limit": 2**47 - 1},
        "physical_word_cardinality": {"upper": b, "limit": LIMIT},
        "dependency_rank_and_midpoint": {"upper": 2*b + 2, "limit": LIMIT},
        "unary_projection_height": {"upper": b + 65536, "limit": LIMIT},
        "byte_length_doubling_and_escaping": {"upper": 16*b + 2, "limit": LIMIT},
        "signed_string_offset_magnitude": {"upper": 16*b + 2, "limit": LIMIT},
        "imported_location_line": {"upper": dimensions["fixed_text_maximum_lines"], "limit": 2**47 - 1},
        "imported_location_byte_column": {"upper": dimensions["fixed_text_maximum_line_bytes"], "limit": 2**16 - 1},
        "semantic_occurrence_count": {"upper": counts["maximum_mathematical_result"], "limit": LIMIT},
    }
    for row in numeric.values():
        row["fits"] = 0 <= row["upper"] < row["limit"]
    assert all(row["fits"] for row in numeric.values())
    assert counts["total_arithmetic_operations"] == 146259
    assert all(c["allocation_snapshots_equal_prior"] for c in counts["cases"])
    result = {
        "scope": "five exact fresh Why3 prefixes, first Why3 module through add_file/session creation; before Gnat_checks.init body",
        "platform": "linux-x86_64",
        "runtime_setting": "s=256M,h=16M,M=1000",
        "inputs": input_rows,
        "native_import_files": 11,
        "native_import_bytes": context["library_bytes"],
        "all_configured_text_files": len(installed),
        "prior_source_identities_joined": len(previous_scan["files"]),
        "retained_source_files": len(sources),
        "term_size_reference_files": size_paths,
        "numeric_conditions": numeric,
        "guarded_semantic_operations": counts["total_arithmetic_operations"],
        "common_exact_inputs_and_configuration_joined": True,
        "complete_prefix_capacity_established": True,
        "completeness_basis": "inspected source partition and fixed-context first-event argument, conditional on documented external behavior/runtime premises",
        "source_argument_machine_checked": False,
        "whole_pipeline_capacity_established": False,
        "variable_Main_capacity_established": False,
        "production_configuration_adopted": False,
        "new_native_executions": 0,
    }
    if args.output:
        args.output.write_text(json.dumps(result, indent=2) + "\n")
    else:
        assert result == json.loads((HERE / "result.json").read_bytes())
    print(json.dumps({k: result[k] for k in ("scope", "complete_prefix_capacity_established",
                                           "source_argument_machine_checked", "whole_pipeline_capacity_established",
                                           "new_native_executions")}, indent=2))


if __name__ == "__main__":
    main()
