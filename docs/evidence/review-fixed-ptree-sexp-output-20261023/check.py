#!/usr/bin/env python3
"""Focused independent review of frozen Sexp transfer/changed bounds.

No target execution, capture, disassembly or provider-checker replay.
"""
import argparse
import hashlib
import json
import platform
import subprocess
import tarfile
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
AUTHOR = ROOT / "docs/evidence/retained-fixed-ptree-sexp-output-20261023"
FREEZE = "e47e5236cf"
FIRST = "22e910d7f7"
CASES = {"put_line", "put", "first_or_default", "input_is_valid", "is_message"}
COUNT = 0


def require(value, message):
    global COUNT
    COUNT += 1
    if not value:
        raise AssertionError(message)


def ident(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def frozen(commit, path):
    return subprocess.check_output(["git", "show", commit + ":" + path], cwd=ROOT)


def project():
    inputs = {}
    paths = [ROOT / "docs/research/retained-fixed-ptree-sexp-output.md"] + sorted(AUTHOR.glob("*"))
    for path in paths:
        if not path.is_file():
            continue
        name = str(path.relative_to(ROOT))
        data = frozen(FREEZE, name)
        require(data == path.read_bytes(), "frozen review input: " + name)
        inputs[name] = ident(data)
    for name, expected in json.loads((AUTHOR / "inputs.json").read_text()).items():
        require(ident((ROOT / name).read_bytes()) == expected, "provider identity: " + name)
        inputs[name] = expected
    require((AUTHOR / "result-before-filetag-repair.json").read_bytes() == frozen(
        FIRST, "docs/evidence/retained-fixed-ptree-sexp-output-20261023/result.json"),
        "first successful graph/native result retained exactly")
    for name, expected in json.loads((AUTHOR / "archive-manifest.json").read_text()).items():
        require(ident((AUTHOR / name).read_bytes()) == {k: expected[k] for k in ("bytes", "sha256")},
                "complete archive identity: " + name)

    provider = json.loads((AUTHOR / "filetag-provider.json").read_text())
    require(provider["all_FileTags_origin_bound"] == 180, "alias-robust all-origin operand")
    for name, expected in provider["providers"].items():
        require(ident((ROOT / name).read_bytes()) == expected, "exact FileTags receipt: " + name)
    raw = {r["case"]: r for r in json.loads((ROOT / "docs/evidence/retained-fixed-ptree-capture-20261023/result.json").read_text())["cases"]}
    source_rows = json.loads((AUTHOR / "result.json").read_text())["cases"]
    require(set(raw) == {r["case"] for r in source_rows} == CASES, "exhaustive fixed five-case family")
    rows = []
    for r in source_rows:
        p = raw[r["case"]]
        R = p["expanded_words"] + p["expanded_blocks"] + p["expanded_immediates"]
        locs = p["position_candidate_occurrences"]
        base = 4 * r["atom_payload_bytes"] + 3 * r["atoms"] + 2 * r["lists"]
        B = base + 19 * R + 4 * 180 * locs
        backing = 1 << (max(1024, B)-1).bit_length()
        atom = max(r["maximum_atom_bytes"], 180, 4)
        require(base == r["captured_mode_byte_bound"], "captured-mode polynomial")
        require(R == r["raw_option_occurrence_allowance"], "option occurrence owner")
        require(B == r["complete_failure_byte_bound"], "complete failed-typing byte bound")
        require(backing == r["buffer_backing_bound"], "doubling capacity")
        require(4 * atom + 2 < 2**57-9 and backing < 2**57-9, "individual string/backing guard")
        require(B + 4 * atom + 2 < 2**62-1 and 2 * backing < 2**62-1, "OCaml integer guards")
        require(B < 2**31-1 and B < 2**63-1, "C block length and signed file offset guards")
        rows.append({"case": r["case"], "R": R, "Loc_candidate_occurrences": locs,
                     "B_captured": base, "option_extra": 19 * R,
                     "filename_alias_extra": 4 * 180 * locs, "B": B,
                     "backing": backing, "escaped_atom_upper": 4 * atom + 2})
    require(4*4+3 == 19 and 4*4+3-2 <= 19, "Some/None mode delta")

    # New concrete question from source review: Curr's marker-prefixed filenames.
    # Query retained strings only; do not replay the provider's complete graph audit.
    markers = []
    with tarfile.open(AUTHOR / "capture.tar.gz") as capture:
        plan = json.load(capture.extractfile("plan.json"))
        require({c["name"] for c in plan["cases"]} == CASES, "capture domain coverage")
        for case in plan["cases"]:
            name = case["name"]
            process = json.load(capture.extractfile(name + "/capture/process.json"))
            require(process["root_register"] == "rax", "actual serializer entry operand")
            require("save_mlw_as_sexp_7559" in process["stack"]
                    and "read_channel_7707" in process["stack"], "actual diagnostic caller")
            graph = json.load(capture.extractfile(name + "/capture/graph.json"))
            require(graph["root"] == process["root"], "capture root attachment")
            marked = [bytes.fromhex(n["data_hex"]) for n in graph["objects"].values()
                      if n["tag"] == 252 and n["data_hex"].startswith("2740")]
            maximum = max(map(len, marked), default=0)
            require(maximum <= 27, "observed marker filename envelope")
            markers.append({"case": name, "maximum_bytes": maximum,
                            "values": [x.decode() for x in sorted(marked)]})
            require(capture.getmember(name + "/" + case["argv"][-1].removesuffix(".gnat-json") + ".sexp").size == 0,
                    "open occurred but serializer bytes did not run after cut")

    spans = []
    selections = [("why3/plugins/gnat_json/gnat_ast_to_ptree.ml", 229, 257),
                  ("why3/src/util/loc.ml", 46, 97),
                  ("why3/src/core/ident.ml", 16, 41),
                  ("sexplib0-sexp_conv.ml", 41, 56),
                  ("sexplib0-sexp.ml", 246, 269),
                  ("sexplib0-sexp.ml", 310, 334)]
    with tarfile.open(AUTHOR / "sources.tar.gz") as archive:
        for member, start, end in selections:
            data = archive.extractfile(member).read()
            text = "".join(data.decode().splitlines(keepends=True)[start-1:end])
            spans.append({"member": member, "start": start, "end": end,
                          "member_identity": ident(data), "span_identity": ident(text.encode()), "text": text})
    return {"inputs.json": inputs, "source-witnesses.json": spans,
            "marker-filename-observation.json": markers,
            "result.json": {"status": "pass", "reviewed_commit": subprocess.check_output(
                ["git", "rev-parse", FREEZE], cwd=ROOT, text=True).strip(), "cases": rows,
                "maximum_B": max(r["B"] for r in rows), "maximum_backing": max(r["backing"] for r in rows),
                "source_semantics_machine_proved": False, "native_runs": 0,
                "provider_checker_runs": 0, "complete_graph_audit_replays": 0,
                "whole_process_capacity_established": False}}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true")
    args = parser.parse_args()
    start = time.monotonic()
    for name, value in project().items():
        if args.write:
            (HERE / name).write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")
        else:
            require(json.loads((HERE / name).read_text()) == value, "retained review projection: " + name)
    record = {"status": "pass", "checks": COUNT, "elapsed_seconds": time.monotonic()-start,
              "host": platform.platform(), "selected_model": "gpt-6-astra", "selected_effort": "xhigh",
              "runtime_confirmed_model_effort": None, "isolated_token_cost_telemetry": None,
              "native_runs": 0, "provider_checker_runs": 0}
    print(json.dumps(record, indent=2))
    if args.write:
        (HERE / "round.json").write_text(json.dumps(record, indent=2) + "\n")


if __name__ == "__main__":
    main()
