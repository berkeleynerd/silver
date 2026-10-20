#!/usr/bin/env python3
"""Check retained terminal-source excerpts and conditional arithmetic offline."""
import hashlib
import json
from pathlib import Path
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def identity(raw):
    return dict(bytes=len(raw), sha256=hashlib.sha256(raw).hexdigest())


def main():
    start = time.monotonic()
    inputs = json.loads((HERE / "inputs.json").read_text())
    archive = inputs["archive"]
    assert identity((ROOT / archive["path"]).read_bytes()) == {
        k:archive[k] for k in ("bytes", "sha256")}
    for row in inputs["repository"]:
        assert identity((ROOT / row["path"]).read_bytes()) == {
            k:row[k] for k in ("bytes", "sha256")}
    with tarfile.open(ROOT / archive["path"]) as stream:
        for row in inputs["sources"]:
            raw = stream.extractfile(row["member"]).read()
            assert identity(raw) == {k:row[k] for k in ("bytes", "sha256")}
            lines = raw.decode().splitlines()
            for excerpt in row["excerpts"]:
                assert "\n".join(lines[excerpt["first"]-1:excerpt["last"]])+"\n" == excerpt["text"]
    signal_kinds = ["SIGINT", "SIGXCPU", "SIGILL", "SIGSEGV_if_installed", "SIGTERM"]
    terminal_upper = len(signal_kinds)+1
    assert terminal_upper == 6
    result = dict(source_members=len(inputs["sources"]),
        signal_kinds=signal_kinds,
        conditional_single_thread_CVC5_terminal_activations=terminal_upper,
        conditional_safe_dump_attempts=terminal_upper,
        conditional_direct_text_formula=f"{terminal_upper*1448} + {terminal_upper*4}*P0",
        conditional_direct_text_if_P0_is_4=terminal_upper*(1448+4*4),
        single_thread_native_relation_established=False,
        all_signal_entry_registry_and_conversion_preconditions_established=False,
        saved_native_terminate_payload_bound=None, complete_safe_dump_bound=None,
        complete_solver_q=None, weighted_O=None, elapsed_seconds=time.monotonic()-start)
    assert result["conditional_direct_text_if_P0_is_4"] == 8784
    print(json.dumps(result,indent=2))


if __name__ == "__main__":
    main()
