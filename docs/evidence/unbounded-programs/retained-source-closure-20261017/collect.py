#!/usr/bin/env python3
"""Read retained sources and installed runtime bytes; invoke no toolchain."""

import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re


def digest(data):
    return {
        "bytes": len(data),
        "sha256": hashlib.sha256(data).hexdigest(),
        "git_blob_sha1": hashlib.sha1(
            b"blob " + str(len(data)).encode() + b"\0" + data
        ).hexdigest(),
    }


def code_only(text):
    # Preserve LF source coordinates, including in files containing form feed.
    return re.sub(
        r'--[^\n]*|"(?:[^"]|"")*"|\'[^\'\n]\'',
        lambda m: "".join("\n" if c == "\n" else " " for c in m[0]),
        text,
    )


def inventory(root):
    accesses = Counter()
    creators, virtual_calls, input_hashes, corpus = [], [], {}, []
    load_calls = []
    inline_calls = []
    for path in sorted(root.rglob("*")):
        if path.suffix.lower() not in {".adb", ".ads"}:
            continue
        data = path.read_bytes()
        name = path.relative_to(root).as_posix()
        corpus.append({"path": name, **digest(data)})
        code = code_only(data.decode("latin-1"))
        hits = []
        for match in re.finditer(r"\bSource_File\s*\.\s*(\w+)", code, re.I):
            operation = match[1].lower()
            accesses[operation] += 1
            if operation in {"append", "increment_last"}:
                hits.append({"file": name, "line": code.count("\n", 0, match.start()) + 1,
                             "operation": operation})
        creators.extend(hits)
        for match in re.finditer(r"\bCreate_Instantiation_Source\s*\(", code, re.I):
            # Includes the defining declaration; consumers are resolved in the record.
            virtual_calls.append({"file": name,
                                  "line": code.count("\n", 0, match.start()) + 1})
        for match in re.finditer(
                r"\b(Load_Source_File|Load_Config_File|Load_Definition_File|"
                r"Load_Preprocessing_Data_File)\s*\(", code, re.I):
            load_calls.append({"file": name,
                               "line": code.count("\n", 0, match.start()) + 1,
                               "operation": match[1]})
        for match in re.finditer(r"\b(Expand_Inlined_Call|Set_Body_To_Inline)\s*\(",
                                 code, re.I):
            inline_calls.append({"file": name,
                                 "line": code.count("\n", 0, match.start()) + 1,
                                 "operation": match[1]})
        if hits or any(item["file"] == name for item in virtual_calls):
            input_hashes[name] = digest(data)
    return {"scanned_ada_files": len(corpus),
            "scanned_manifest_sha256": canonical_digest(corpus),
            "source_file_accesses": dict(sorted(accesses.items())),
            "source_table_creators": creators,
            "physical_load_occurrences": load_calls,
            "inline_body_occurrences": inline_calls,
            "virtual_source_occurrences": virtual_calls,
            "matched_source_inputs": input_hashes}


def canonical_digest(value):
    data = json.dumps(value, sort_keys=True, separators=(",", ":")).encode()
    return hashlib.sha256(data).hexdigest()


def runtime_inventory(root):
    entries = [{"path": path.relative_to(root).as_posix(), **digest(path.read_bytes())}
               for path in sorted(root.rglob("*")) if path.is_file()]
    return {"file_count": len(entries),
            "bytes": sum(x["bytes"] for x in entries),
            "aligned_source_sum": sum(4096 * ((x["bytes"] + 4096) // 4096)
                                      for x in entries),
            "manifest_sha256": canonical_digest(entries)}


def runtime_inline_inventory(root):
    result = {}
    for path in sorted(root.rglob("*")):
        if path.suffix.lower() not in {".ads", ".adb"}:
            continue
        data = path.read_bytes()
        code = code_only(data.decode("latin-1"))
        inline = [code.count("\n", 0, m.start()) + 1
                  for m in re.finditer(r"\bInline_Always\b", code, re.I)]
        nulls = [code.count("\n", 0, m.start()) + 1
                 for m in re.finditer(r"\bis\s+null\b", code, re.I)]
        if inline or nulls:
            result[path.relative_to(root).as_posix()] = {
                **digest(data), "inline_always_lines": inline, "is_null_lines": nulls,
            }
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    for name in ("repo", "gcc", "spark", "native-runtime", "producer-runtime"):
        parser.add_argument("--" + name, type=Path, required=True)
    args = parser.parse_args()
    runtime_names = ["a-stuten.ads", "a-unccon.ads", "s-stalib.ads", "a-tags.ads",
                     "s-imgint.ads", "s-imagei.ads", "s-imagei.adb", "s-secsta.ads"]
    runtime_names += [f"s-conca{i}.ads" for i in range(2, 10)]
    runtime = {}
    for name in runtime_names:
        values = [(args.gcc / "libgnat" / name).read_bytes(),
                  (args.native_runtime / name).read_bytes(),
                  (args.producer_runtime / name).read_bytes()]
        runtime[name] = {
            "baseline": digest(values[0]), "installed_native": digest(values[1]),
            "installed_producer": digest(values[2]), "all_equal": values[0] == values[1] == values[2],
        }
    trace_path = (args.repo / "docs/evidence/unbounded-programs/feasibility-20261017/"
                  "source-capacity/trace-summary.json")
    trace = next(x for x in json.loads(trace_path.read_text()) if x["name"] == "mixed_expanded")
    baseline_manifest_path = (args.repo / "docs/evidence/unbounded-programs/"
                              "continuation-20261017/frontend-lifetimes/"
                              "complete-source-manifest.json")
    baseline = {x["path"]: x for x in json.loads(baseline_manifest_path.read_text())["files"]}
    mismatches = []
    for path in sorted(args.gcc.rglob("*")):
        if path.suffix.lower() in {".ads", ".adb"}:
            name = path.relative_to(args.gcc).as_posix()
            if name not in baseline or digest(path.read_bytes())["sha256"] != baseline[name]["sha256"]:
                mismatches.append(name)
    missing = sorted(name for name in baseline
                     if Path(name).suffix.lower() in {".ads", ".adb"}
                     and not (args.gcc / name).is_file())
    native_corpus = runtime_inventory(args.native_runtime)
    producer_corpus = runtime_inventory(args.producer_runtime)
    cited_gcc = ("sinput.adb", "sinput-l.adb", "sinput-c.adb", "sinput-d.adb",
                 "ali-util.adb", "gprep.adb",
                 "osint.adb", "lib-load.adb", "frontend.adb", "gnat1drv.adb",
                 "prepcomp.adb", "sem.adb", "sem_ch3.adb", "sem_ch4.adb",
                 "sem_ch6.adb", "sem_ch12.adb", "sem_prag.adb", "inline.adb",
                 "contracts.adb", "freeze.adb", "exp_ch3.adb", "exp_ch4.adb",
                 "exp_ch6.adb", "exp_ch7.adb", "exp_smem.adb", "exp_dist.adb", "exp_imgv.adb",
                 "exp_put_image.adb", "expander.adb", "exp_spark.adb", "sem_res.adb",
                 "sem_util.adb", "checks.adb", "debug.adb",
                 "rtsfind.adb", "rtsfind.ads", "sprint.adb", "switch-c.adb")
    result = {
        "scope": "Source-only inventory and byte comparison; no complete source-closure claim.",
        "gcc_commit": "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea",
        "spark_inspected_commit": "42554fc241fcd1fdf08d3a2feccb3f86912acbc0",
        "spark_installed_commit_established": False,
        "gcc_inventory": inventory(args.gcc),
        "gcc_corpus_reconciliation": {
            "retained_manifest": digest(baseline_manifest_path.read_bytes()),
            "mismatched_or_unlisted_ada_files": mismatches,
            "missing_ada_files": missing,
        },
        "spark_src_inventory": inventory(args.spark / "src"),
        "cited_gcc_inputs": {name: digest((args.gcc / name).read_bytes()) for name in cited_gcc},
        "cited_spark_inputs": {name: digest((args.spark / "src" / name).read_bytes())
                               for name in ("gnatprove/gnatprove.adb",
                                            "why/gnat2why-data_decomposition.adb")},
        "installed_runtime_corpora": {
            "native": native_corpus, "producer": producer_corpus,
            "all_names_and_bytes_equal": native_corpus == producer_corpus,
            "scope": "Physical file union; each request name charged once. Does not bound virtual copies or prove search-path closure.",
        },
        "installed_native_runtime_inline_inventory": runtime_inline_inventory(args.native_runtime),
        "runtime_comparison": runtime,
        "silver_inputs": {name: digest((args.repo / name).read_bytes()) for name in (
            "src/silver.adb", "src/silver_libraries.adb", "scripts/bootstrap.py",
            "src/silver_io.ads", "src/silver_io.adb", "src/silver_arguments.ads",
            "src/silver_arguments.adb", "src/silver_output_libc.ads", "src/silver_runtime.ads")},
        "historical_trace_input": digest(trace_path.read_bytes()),
        "historical_mixed_virtual_extents": trace["virtual_units"],
        "identified_template_component": {
            "unchecked_conversion_occurrences": 7,
            "unchecked_conversion_extent": 1554,
            "image_i_occurrences": 1,
            "image_i_extent": 3367,
            "rounded_contribution": 7 * 4096 + 4096,
            "scope": "Only these identified spec instantiations; not a universal virtual-source total.",
        },
    }
    print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
