#!/usr/bin/env python3
"""New retained-input check. Does not execute any predecessor or native target.

Source control/closure arguments are reviewed prose, not proved by this script.
"""
import argparse
import hashlib
import json
import platform
import re
import subprocess
import tarfile
import time
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PINF = 1_000_000_010
INT = 2**62 - 1
COUNT = 0


def require(value, label):
    global COUNT
    COUNT += 1
    if not value:
        raise AssertionError(label)


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def load(name):
    return json.loads((HERE / name).read_text())


def input_bytes(name):
    if name.startswith("git:"):
        _, commit, path = name.split(":", 2)
        return subprocess.check_output(["git", "show", f"{commit}:{path}"], cwd=ROOT)
    return (ROOT / name).read_bytes()


def core(B, E):
    L = B + E
    I = 3 * E + 2
    T = PINF + L + 1
    return {
        "B": B, "E": E, "L": L,
        "sentinel": L + 79 <= PINF,
        "scan": (3 * E + 1) * T + L + 79 <= INT,
        "index": 4 * I + 2 <= INT,
    }


def evaluate(P, U, N_id=467):
    """Conditional operands: no actual cwd/path attachment is inferred here."""
    assert P >= 0 and U >= 0 and N_id >= 0
    S = max(467, U + 256, 4 * P + 2048, N_id)
    K = 723 + 12 * S
    C = 8 * K + 65536
    rendered = 31 * C                    # R[4], two children, one copy each
    aggregate = 341 * C                  # A[4], work and copies separate
    events = 320 * 31 + 16
    abort_each = rendered + P + 1024
    X = 4 * abort_each
    B = 6 * X + 4 * 128 + 64
    E = 2 * X + 4 * 128 + 8 + 2        # two process-global exit flushes
    direct = 2 * rendered + 253
    marker_S = max(467, P + 51, N_id)
    marker_C = 8 * (723 + 12 * marker_S) + 65536
    private = core(aggregate + P + 1024, events)
    standard = core(B, E)
    channel = B + 70 * (E + 2) + direct
    return {
        "P": P, "U": U, "N_id": N_id, "S": S, "K": K, "C": C,
        "ordinary_wrapper_depth": 4,
        "rendered_bytes": rendered,
        "aggregate_private_bytes": aggregate,
        "private_events": events,
        "abort_attempts": 4,
        "abort_each": abort_each,
        "abort_payload_sum_X": X,
        "marker_inner_wrapper_depth": 3,
        "marker_rendered_bytes": 15 * marker_C + 1024,
        "marker_private_aggregate_bytes": 85 * marker_C + 1024,
        "marker_private_events": 320 * 15 + 16,
        "private_core": private,
        "standard_core": standard,
        "direct_fallback_bytes": direct,
        "channel_offered_bytes": channel,
        "channel_signed64_guard": channel <= 2**63 - 1,
        "all_scalar_guards": all(private[k] and standard[k] for k in ("sentinel", "scan", "index")) and channel <= 2**63 - 1,
    }


def project():
    inputs = load("inputs.json")
    for name, expected in inputs.items():
        require(identity(input_bytes(name)) == expected, f"input identity: {name}")
    archives = {}
    spans = []
    try:
        for row in load("source-ranges.json"):
            archive = row["archive"]
            if archive not in archives:
                archives[archive] = tarfile.open(ROOT / archive)
            data = archives[archive].extractfile(row["member"]).read()
            lines = data.decode().splitlines(keepends=True)
            start, end = row["start"], row["end"]
            require(1 <= start <= end <= len(lines), f"source span {row['member']}:{start}-{end}")
            text = "".join(lines[start - 1:end])
            spans.append({**row, "member_identity": identity(data), "span_identity": identity(text.encode()), "text": text})

        library_rows = json.loads(input_bytes("docs/evidence/retained-why-report-path-inputs-20261023/library-projection.json"))
        arc = "docs/evidence/retained-producer-import-context-20261018/sources.tar.gz"
        if arc not in archives:
            archives[arc] = tarfile.open(ROOT / arc)
        libraries = []
        for row in library_rows:
            data = archives[arc].extractfile(row["member"]).read()
            require(identity(data) == row["identity"], f"selected complete library {row['member']}")
            # Prevent a hexadecimal constant's x... suffix from being called
            # an identifier; comments/strings are retained conservatively.
            tokens = re.findall(rb"(?<![A-Za-z_0-9'])[A-Za-z_][A-Za-z_0-9']*", data)
            maximum = max(map(len, tokens), default=0)
            require(maximum <= 467, f"source word identifier ceiling {row['member']}")
            libraries.append({"member": row["member"], "identity": row["identity"], "candidate_word_identifier_maximum": maximum})

        patch_archive = "docs/evidence/retained-server-libc-storage-20261020/glibc_2.43-2ubuntu2.4.debian.tar.xz"
        patch_tar = tarfile.open(ROOT / patch_archive)
        archives[patch_archive] = patch_tar
        selected = {r["member"].split("/", 1)[1] for r in spans if "glibc_2.43.orig" in r["archive"]}
        patch_hits = []
        for member in patch_tar.getmembers():
            if not member.isfile() or "/patches/" not in member.name:
                continue
            data = patch_tar.extractfile(member).read()
            targets = re.findall(rb"^\+\+\+\s+(?:b/)?([^\t\r\n ]+)", data, re.M)
            touched = sorted(set(t.decode() for t in targets) & selected)
            if touched:
                patch_hits.append({"member": member.name, "identity": identity(data), "selected_targets": touched, "text": data.decode()})
        require({r["member"] for r in patch_hits} == {
            "debian/patches/any/unsubmitted-ldso-machine-mismatch.diff",
            "debian/patches/arm/unsubmitted-ldso-multilib.diff",
        }, "complete selected loader-file patch targets")
    finally:
        for archive in archives.values():
            archive.close()

    paths = json.loads(input_bytes("docs/evidence/retained-why-report-path-inputs-20261023/projection.json"))
    capture = json.loads(input_bytes("git:09d9a2382f:docs/evidence/retained-fixed-ptree-capture-20261023/result.json"))
    require(capture["status"] == "pass", "retained new raw capture result")
    max_ptree = max(r["maximum_direct_string_payload"] for r in capture["cases"])
    require(max_ptree == 202 and max_ptree < 467, "all direct Ptree string payloads")
    driver = json.loads(input_bytes("docs/evidence/retained-why-printer-output-20261023/census.json"))
    require(driver["maximum_parsed_parameter_bytes"] <= 4, "initial driver numeric substring envelope")
    path_cases = paths["cases"] if "cases" in paths else paths["domains"]
    operands = {name: {
        "raw_json_string_maximum_U": row["decoded_string_max_bytes_U"],
        "retained_initial_path_maximum": row["initial_path_maximum"],
        "client_cwd_bytes": None,
        "P_actual_joined": None,
    } for name, row in path_cases.items()}
    examples = {name: evaluate(180, row["raw_json_string_maximum_U"]) for name, row in operands.items()}
    for name, example in examples.items():
        require(example["all_scalar_guards"], f"orientation scalar arithmetic {name}")
        require(example["marker_rendered_bytes"] == 1743304, f"marker small-path arithmetic {name}")
    result = {
        "status": "pass", "scope": "conditional returning pre-cut scalar failures and marker payload; complete Ptree serializer remains a separate provider",
        "source_semantics_machine_proved": False,
        "operands": operands,
        "raw_ptree_maximum_string_payload": max_ptree,
        "library_word_identifier_maximum": max(r["candidate_word_identifier_maximum"] for r in libraries),
        "examples_only_not_actual_path_attachment": examples,
        "global_e_upper": 2, "save_entering_callbacks_upper": 2, "saves_upper": 3,
        "renewed_failure_budget": False,
        "Ptree_serializer_provider_joined": False,
        "whole_process_capacity_established": False,
        "native_runs": 0, "predecessor_checker_runs": 0,
    }
    return {"source-witnesses.json": spans, "loader-patch-projection.json": patch_hits,
            "library-identifiers.json": libraries, "result.json": result}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true")
    args = parser.parse_args()
    started = time.monotonic()
    outputs = project()
    for name, value in outputs.items():
        if args.write:
            (HERE / name).write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")
        else:
            require(load(name) == value, f"retained projection {name}")
    round_record = {"status": "pass", "checks": COUNT, "elapsed_seconds": time.monotonic() - started,
                    "host": platform.platform(), "selected_model": "GPT-6 Astra", "selected_effort": "Extra High",
                    "runtime_confirmed_model_effort": None, "isolated_token_cost_telemetry": None,
                    "target_runs": 0, "predecessor_checker_runs": 0}
    print(json.dumps(round_record, indent=2))
    if args.write:
        (HERE / "round.json").write_text(json.dumps(round_record, indent=2) + "\n")


if __name__ == "__main__":
    main()
