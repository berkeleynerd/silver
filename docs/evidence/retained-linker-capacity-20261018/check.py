#!/usr/bin/env python3
"""Check retained Binutils inputs and local representation arithmetic offline.

This does not derive source-to-linker event counts or execute vendor tools.
"""

import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    bundle = Path(__file__).resolve().parent
    manifest = json.loads((bundle / "source-manifest.json").read_text())
    tag = json.loads((bundle / "release-tag.json").read_text())
    assert manifest["commit"] == tag["object"]["sha"]
    assert tag["tag"] == manifest["tag"] == "binutils-2_46_1"
    sources = {}
    with tarfile.open(bundle / "sources.tar.gz") as archive:
        for row in manifest["files"]:
            data = archive.extractfile(row["path"]).read()
            assert len(data) == row["bytes"], row["path"]
            assert hashlib.sha256(data).hexdigest() == row["sha256"], row["path"]
            sources[row["path"]] = data.decode()

    uint_max = 2**32 - 1
    int_max = 2**31 - 1
    primes = [int(x) for x in re.findall(r"UINT32_C \((\d+)\)",
                                       sources["bfd/hash.c"])]
    assert len(primes) == 28 and primes[-2:] == [int_max, uint_max - 4]
    largest = max(p for p in primes if 3*p <= uint_max)
    assert largest == 1073741789
    distinct_limit = 3*largest // 4
    assert distinct_limit == 805306341
    cases = []
    # Every growth threshold in the sufficient region: insertion immediately
    # above it selects one next prime; the next table fits unless it is the
    # excluded insertion immediately above our final D bound.
    for capacity in [4051] + [p for p in primes if 4051 < p <= largest]:
        threshold = 3*capacity // 4
        assert 3*capacity <= uint_max
        next_capacity = next(p for p in primes if p > capacity)
        if threshold < distinct_limit:
            assert next_capacity <= largest
        cases.append(dict(capacity=capacity, threshold=threshold,
                          next_capacity=next_capacity,
                          growth_in_region=threshold < distinct_limit))
    wrapped_next_threshold = ((3*int_max) & uint_max) // 4
    assert wrapped_next_threshold == 536870911 < distinct_limit
    assert 3*int_max > uint_max

    # Default-size setter's LP64 clamp and strict higher-prime selection.
    max_initial = next(p for p in primes if p > 0x4000000)
    assert max_initial == 134217689 < largest
    backbone_request = 8*largest
    cumulative_backbones = 8*(max_initial + sum(p for p in primes if p <= largest))
    assert backbone_request < 2**33 and cumulative_backbones < 2**35
    array_capacity = max(64, 1 << distinct_limit.bit_length())
    assert array_capacity == 2**30
    assert distinct_limit + 1 <= array_capacity
    sorting_bytes = 8*(distinct_limit+1)
    save_bytes = 16+4*distinct_limit
    for request in (backbone_request, int_max, 40):
        aligned = (request + 7) & ~7
        assert aligned + 16 < 2**64
    # Offset endpoint: two near-maximal names and a nonempty short tail take
    # the section to exactly 2^32 while all starting offsets stay below it.
    lengths_with_nul = [int_max, int_max-1, 2]
    offset, offsets = 1, []
    for length in lengths_with_nul:
        assert 2 <= length <= int_max
        offsets.append(offset)
        assert offset < 2**32
        offset += length
    assert offset == 2**32

    result = {
        "scope": "local representation arithmetic; no compiler/linker/prover execution",
        "commit": manifest["commit"],
        "verified_source_files": len(sources),
        "elf_strtab": {
            "maximum_nonempty_name_bytes": int_max-1,
            "maximum_distinct_lifetime_names": distinct_limit,
            "maximum_unshared_section_bytes_including_initial_nul": 2**32,
            "maximum_positive_refcount_events_per_entry": uint_max,
            "maximum_pointer_array_capacity": array_capacity,
            "maximum_pointer_array_bytes": 8*array_capacity,
            "maximum_sorting_array_bytes": sorting_bytes,
            "maximum_save_record_bytes": save_bytes,
            "offset_endpoint_example": {"lengths_including_nul": lengths_with_nul,
                                        "offsets": offsets, "section_bytes": offset},
        },
        "bfd_hash": {
            "primes": primes, "largest_no_wrap_growth_capacity": largest,
            "maximum_distinct_names_for_this_region": distinct_limit,
            "largest_default_setter_capacity": max_initial,
            "growth_thresholds": cases,
            "next_capacity_wrapped_threshold": wrapped_next_threshold,
            "maximum_backbone_request": backbone_request,
            "conservative_cumulative_backbone_requests": cumulative_backbones,
        },
    }
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output / "checks.json").write_text(json.dumps(result, indent=2)+"\n")
    print(f"Verified {len(sources)} Binutils files and local arithmetic")


if __name__ == "__main__":
    main()
