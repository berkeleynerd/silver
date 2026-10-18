#!/usr/bin/env python3
"""Source-only reproduction and independent local arithmetic for the review."""
import argparse
import ctypes
import hashlib
import json
from pathlib import Path
import subprocess
import sys
import tarfile

ROOT = Path(__file__).resolve().parent


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ada", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    args.output.mkdir(parents=True, exist_ok=True)
    original = ROOT.parent / "retained-backend-capacity-20261018"
    subprocess.run([sys.executable, str(original / "check.py"),
                    "--ada", str(args.ada), "--output", str(args.output)],
                   check=True)
    reproduced = []
    for name in ("checks.json", "source-excerpts.md"):
        data = (args.output / name).read_bytes()
        assert data == (original / name).read_bytes(), name
        reproduced.append({"file": name,
                           "sha256": hashlib.sha256(data).hexdigest()})

    manifest = json.loads((ROOT / "config-source-manifest.json").read_text())
    assert manifest["commit"] == "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea"
    additional = []
    terms = [b"SUBTARGET_OPTIMIZATION_OPTIONS", b"flag_merge_constants",
             b"OPT_fmerge_constants"]
    with tarfile.open(ROOT / "config-sources.tar.gz") as sources:
        for row in manifest["files"]:
            data = sources.extractfile(row["path"]).read()
            assert len(data) == row["bytes"]
            assert hashlib.sha256(data).hexdigest() == row["sha256"]
            assert hashlib.sha1(b"blob " + str(len(data)).encode()
                                + b"\0" + data).hexdigest() == row["git_blob_sha1"]
            assert not any(term in data for term in terms), row["path"]
            additional.append(row["path"])

    # Derive the per-file interval from the unsigned line-number width and
    # the selected column count; no large source or location array is allocated.
    line_width = 8 * ctypes.sizeof(ctypes.c_uint)
    assert line_width == 32 and ctypes.sizeof(ctypes.c_void_p) == 8
    assert ctypes.sizeof(ctypes.c_long) == 8 and ctypes.sizeof(ctypes.c_int) == 4
    columns = 256
    maximum = (1 << line_width) // columns
    boundaries = []
    for lines in [1, 2, 11, 1000, maximum - 1, maximum, maximum + 1]:
        can_reuse = lines - 1 < maximum
        assert can_reuse == (lines <= maximum)
        boundaries.append({"lines": lines, "map_reusable": can_reuse})

    sequences = []
    for lengths in [[1], [maximum], [1, 17, maximum], [maximum] * 100]:
        highest = 1  # the ordinary initial reserved-location maximum
        starts = []
        for length in lengths:
            start = highest + 1
            starts.append(start)
            last_line = start + (length - 1) * columns
            highest = last_line + 251
        additive = 1 + sum(columns * (n - 1) + 252 for n in lengths)
        assert highest == additive
        later_maximum = max(s + columns * (n - 1) + 255
                            for s, n in zip(starts, lengths))
        assert later_maximum == highest + 4
        assert later_maximum < (0x50000000 << 31)
        sequences.append({"files": len(lengths), "preallocated_maximum": highest,
                          "later_masked_column_maximum": later_maximum})

    # Ordinary LP64 layout premise: one 4-byte flags word, one 4-byte union,
    # an 8-byte tree pointer, then the 4-byte String length.
    header = 4 + 4 + 8 + 4
    int_max = (1 << 31) - 1
    strings = []
    for length in [0, 1, 999, 1000, int_max]:
        requested = length + header + 1
        assert requested <= (1 << 32) - 1
        counts = [(length + chunk - 1) // chunk for chunk in [2000, 16384]]
        assert counts[1] <= counts[0]
        strings.append({"length": length, "node_request": requested,
                        "temporary_plus_node": length + requested,
                        "chunk_callback_bounds": counts})
    result = {
        "scope": "Frozen backend component source review; no compiler, prover or allocation stress run",
        "review_target": "2324105a9b",
        "reproduced_outputs": reproduced,
        "additional_configuration_sources_verified": additional,
        "additional_configuration_override_terms_absent": [x.decode() for x in terms],
        "line_map_boundary_cases": boundaries,
        "cumulative_location_cases": sequences,
        "lp64_string_header_premise": header,
        "string_arithmetic_cases": strings,
        "whole_backend_assurance_established": False,
    }
    (args.output / "review-checks.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({"reproduced_outputs": len(reproduced),
                      "configuration_sources_verified": len(additional),
                      "local_arithmetic": "pass"}))


if __name__ == "__main__":
    main()
