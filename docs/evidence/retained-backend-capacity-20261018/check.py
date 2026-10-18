#!/usr/bin/env python3
"""Reproduce source identities and local backend arithmetic, without compiling.

The handwritten report supplies reachability and composition reasoning. This
script checks inputs, excerpts and its stated arithmetic; it is not a proof of
the complete compiler or a compiler-success membership test.
"""

import argparse
import hashlib
import json
from pathlib import Path
import tarfile


RANGES = {
    "gcc/ada/back_end.adb": [(123, 130), (155, 175)],
    "gcc/ada/gcc-interface/trans.cc": [(87, 91), (346, 363), (6705, 6732),
                                       (11006, 11030)],
    "gcc/ada/gcc-interface/misc.cc": [(376, 377)],
    "gcc/ada/gcc-interface/utils.cc": [(259, 280), (430, 450)],
    "gcc/toplev.cc": [(761, 767), (1141, 1150)],
    "gcc/ggc-page.cc": [(1292, 1327), (1883, 1905)],
    "gcc/ggc.h": [(230, 258)],
    "gcc/tree.cc": [(2616, 2636)],
    "gcc/tree-core.h": [(1138, 1253), (1565, 1595)],
    "gcc/varasm.cc": [(870, 920), (2304, 2335), (2665, 2667), (3953, 3965),
                       (5627, 5635), (8518, 8527)],
    "gcc/opts.cc": [(470, 560), (596, 605), (819, 825)],
    "gcc/common.opt": [(2411, 2420)],
    "gcc/config/i386/i386-options.cc": [(2275, 2286)],
    "gcc/common/config/i386/i386-common.cc": [(2033, 2059)],
    "libcpp/include/line-map.h": [(48, 55), (295, 324), (425, 471), (747, 777)],
    "libcpp/line-map.cc": [(469, 543), (570, 608), (662, 680), (890, 999), (1009, 1077)],
}


def read_tar(archive, name):
    with tarfile.open(archive) as src:
        with src.extractfile(name) as member:
            return member.read()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--ada", required=True, type=Path,
                        help="Pinned gcc/ada directory")
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    bundle = Path(__file__).resolve().parent
    evidence = bundle.parent
    manifest = json.loads((bundle / "source-manifest.json").read_text())
    assert manifest["commit"] == "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea"
    prior = evidence / "unbounded-programs/frontend-deferred-20261017"
    prior_files = {row["path"]: row for row in json.loads(
        (prior / "gcc-emission-source-manifest.json").read_text())["files"]}
    ada_record = evidence / ("unbounded-programs/continuation-20261017/"
                             "frontend-lifetimes/complete-source-manifest.json")
    ada_files = {"gcc/ada/" + row["path"]: row for row in
                 json.loads(ada_record.read_text())["files"]}
    excerpts = ["# Pinned native backend source excerpts\n",
                "LF line numbering; complete file identities checked.\n"]
    verified = []
    all_bytes = {}
    for row in manifest["files"]:
        name = row["path"]
        if name.startswith("gcc/ada/"):
            data = (args.ada / name.removeprefix("gcc/ada/")).read_bytes()
            assert hashlib.sha256(data).hexdigest() == ada_files[name]["sha256"]
        elif name in prior_files:
            data = read_tar(prior / "gcc-emission-sources.tar.gz",
                            prior_files[name]["file"])
            assert hashlib.sha256(data).hexdigest() == prior_files[name]["sha256"]
        else:
            data = read_tar(bundle / row.get("archive", "new-sources.tar.gz"), name)
        assert len(data) == row["bytes"], name
        assert hashlib.sha256(data).hexdigest() == row["sha256"], name
        blob = hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data)
        assert blob.hexdigest() == row["git_blob_sha1"], name
        all_bytes[name] = data
        verified.append({"path": name, "sha256": row["sha256"]})
        lines = data.decode().split("\n")
        for first, last in RANGES[name]:
            excerpts.extend([f"\n## {name}:{first}–{last}\n", "```text\n"])
            excerpts.extend(f"{i}: {lines[i-1]}".rstrip() + "\n"
                            for i in range(first, last + 1))
            excerpts.append("```\n")

    # Negative source searches corroborate the inspected override scope.
    assert b"flag_merge_constants" not in all_bytes["gcc/ada/gcc-interface/misc.cc"]
    assert b"OPT_fmerge_constants" not in all_bytes[
        "gcc/common/config/i386/i386-common.cc"]

    line_bits, column_bits = 32, 8
    maximum_lines = 1 << (line_bits - column_bits)
    assert maximum_lines - 1 < 1 << (line_bits - column_bits)
    assert not maximum_lines < 1 << (line_bits - column_bits)
    location_charge = 256 * (maximum_lines - 1) + 252
    int_max = (1 << 31) - 1
    map_cases = []
    for demand in sorted({0, 1, 255, 256, 257, int_max} |
                         {2**k+delta for k in range(9,31) for delta in (-1,0,1)}):
        capacity = 0 if demand == 0 else max(256,1 << (demand-1).bit_length())
        assert demand <= capacity <= 2**31
        assert capacity*32 <= 2**36
        if capacity:
            assert capacity*32 == 1 << (capacity.bit_length()-1+5)
        map_cases.append(dict(demand=demand, capacity=capacity, bytes=32*capacity))
    header_offset = 20
    constructor_bytes = int_max + header_offset + 1
    assert constructor_bytes <= (1 << 32) - 1
    results = {
        "scope": "local source-derived arithmetic; no native compiler/prover run",
        "verified_sources": verified,
        "line_map": {
            "location_bits": 64, "line_bits": line_bits,
            "column_bits": column_bits, "range_bits": 0,
            "maximum_lines_without_extra_map": maximum_lines,
            "first_line_count_requiring_extra_map": maximum_lines + 1,
            "preallocation_charge_at_maximum": location_charge,
            "later_column_headroom": 4,
            "normal_region_exclusive_limit": 0x50000000 << 31,
            "ordinary_map_bytes_lp64": 32,
            "growth_transitions": map_cases,
            "maximum_map_vector_bytes_from_nat_file_count": 2**36,
        },
        "gnat_node_associations": {
            "array_count": 2,
            "maximum_count_from_int_interface": int_max,
            "maximum_requested_bytes_per_array": 8*int_max,
            "maximum_rounded_bytes_per_array": 2**34,
            "scope": "backbone arithmetic; pointed-to GCC trees are separate",
        },
        "string": {
            "lp64_header_offset_premise": header_offset,
            "maximum_signed_length": int_max,
            "constructor_request_at_endpoint": constructor_bytes,
            "coexisting_temporary_plus_node_at_endpoint": int_max + constructor_bytes,
            "largest_stack_temporary": 999,
            "maximum_chunk_callbacks_at_endpoint": (int_max + 1999) // 2000,
            "normal_chunk_size": 2000, "base64_chunk_size": 16384,
            "emission_extra_nul_under_o0_no_override": False,
        },
    }
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output / "checks.json").write_text(json.dumps(results, indent=2) + "\n")
    (args.output / "source-excerpts.md").write_text("".join(excerpts))
    print(f"Verified {len(verified)} source files and local arithmetic")


if __name__ == "__main__":
    main()
