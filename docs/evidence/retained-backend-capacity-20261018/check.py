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
import re
import tarfile


RANGES = {
    "gcc/ada/back_end.adb": [(123, 130), (155, 175)],
    "gcc/ada/gcc-interface/trans.cc": [(87, 91), (346, 363), (6705, 6732),
                                       (1201, 1289), (1330, 1369), (4911, 5015),
                                       (5688, 5691), (6779, 6881), (7086, 7116),
                                       (7291, 7342), (7415, 7470), (7605, 7616),
                                       (7756, 7821), (7944, 7974), (8603, 8622),
                                       (8968, 8996), (9298, 9305), (3301, 3306),
                                       (9889, 10025), (11006, 11030)],
    "gcc/ada/gcc-interface/decl.cc": [(400, 445), (697, 718), (754, 766), (1278, 1291),
                                      (3142, 3177)],
    "gcc/ada/gcc-interface/misc.cc": [(376, 377)],
    "gcc/ada/gcc-interface/utils.cc": [(259, 280), (430, 450), (770, 783)],
    "gcc/toplev.cc": [(761, 767), (1141, 1150)],
    "gcc/ggc-page.cc": [(1292, 1327), (1883, 1905)],
    "gcc/ggc.h": [(230, 258)],
    "gcc/tree.cc": [(2616, 2636)],
    "gcc/tree-core.h": [(1138, 1253), (1565, 1595)],
    "gcc/varasm.cc": [(870, 920), (2304, 2335), (2665, 2667), (3953, 3965),
                       (5627, 5635), (8518, 8527), (76, 85), (2069, 2086),
                       (2976, 2987), (3537, 3553), (3720, 3753), (3804, 3893),
                       (4001, 4038), (4150, 4168), (4184, 4253), (4476, 4523)],
    "gcc/function.h": [(162, 169)],
    "gcc/genmodes.cc": [(828, 845), (1012, 1023)],
    "gcc/config/elfos.h": [(114, 132)],
    "gcc/hash-table.h": [(295, 355), (599, 617), (656, 679), (755, 778),
                         (788, 821), (833, 895), (1026, 1093)],
    "gcc/hash-table.cc": [(44, 78), (87, 110)],
    "include/hashtab.h": [(32, 46)],
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

    # The constant-label counter is file-local: inventory every increment and
    # reset in its complete source, not just a selected emitter excerpt.
    varasm = all_bytes["gcc/varasm.cc"].decode().split("\n")
    label_increments = [i for i, line in enumerate(varasm, 1)
                        if re.search(r"const_labelno\s*\+\+|\+\+\s*const_labelno", line)]
    label_resets = [i for i, line in enumerate(varasm, 1)
                    if re.search(r"\bconst_labelno\s*=\s*0", line)]
    assert label_increments == [2085, 2984, 3733, 4252]
    assert label_resets == [9077]
    deferred_updates = [i for i, line in enumerate(varasm, 1)
                        if re.search(r"n_deferred_constants\s*(?:\+\+|--)", line)]
    assert deferred_updates == [3888, 4519]

    prime_source = all_bytes["gcc/hash-table.cc"].decode()
    prime_text = prime_source.split("prime_tab[] = {", 1)[1].split("};", 1)[0]
    primes = [int(x, 0) for x in re.findall(r"\{\s*(0x[0-9a-f]+|[0-9]+),", prime_text)]
    assert len(primes) == 30 and primes[-2:] == [int_max, 2**32-5]
    live_limit = int_max // 2
    hash_cases = []
    for demand in sorted({0, 1, 23, 24, 765, 766, live_limit} |
                         {p//2+delta for p in primes[:-1] for delta in (0,1)
                          if 0 <= p//2+delta <= live_limit}):
        request = max(1009, 2*demand)
        capacity = next(p for p in primes if p >= request)
        assert capacity <= int_max
        assert 2*capacity-3 <= 2**32-1  # index + secondary step
        assert 8*capacity <= 8*int_max < 2**34
        hash_cases.append(dict(live=demand, request=request, capacity=capacity))
    # Search the exact selected macro lengths; the shortest caller array is LF.
    label_lengths = {prefix: 2+len(prefix)+len(str(int_max-1))+1
                     for prefix in ("LF", "LC", "LHOTB", "LCOLDB", "LHOTE", "LCOLDE")}
    assert label_lengths["LF"] <= 17
    assert max(label_lengths.values()) <= 100
    # The alignment mask is unsigned int before conversion to HOST_WIDE_INT.
    # genmodes emits BITS_PER_UNIT as a plain decimal int literal.
    mode_generator = all_bytes["gcc/genmodes.cc"].decode()
    assert '#define BITS_PER_UNIT (%d)' in mode_generator
    varasm_text = all_bytes["gcc/varasm.cc"].decode()
    assert varasm_text.count("pool->offset &= ~ ((align / BITS_PER_UNIT) - 1);") == 2
    uint_max = 2**32-1
    byte_alignment = 8
    before = 2**32
    unsigned_mask = (~(byte_alignment-1)) & uint_max
    narrowed = (before+byte_alignment-1) & unsigned_mask
    mathematical = (before+byte_alignment-1) & ~(byte_alignment-1)
    assert narrowed == 0 and mathematical == 2**32
    assert before+byte_alignment-1+8 <= 2**63-1
    # Below the 32-bit mask ceiling, zero-extension changes no significant bit.
    mask_cases = []
    for alignment in (1, 2, 4, 8, 16, 32, 64):
        mask = (~(alignment-1)) & uint_max
        for unaligned in sorted({0, alignment-1, alignment, uint_max-1, uint_max}):
            actual = unaligned & mask
            expected = unaligned & ~(alignment-1)
            assert actual == expected and 0 <= actual <= unaligned
            mask_cases.append({"alignment_bytes": alignment,
                               "pre_mask_offset": unaligned, "aligned_offset": actual})
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
        "constant_pools": {
            "label_increment_lines": label_increments,
            "label_reset_lines": label_resets,
            "maximum_total_label_events": int_max,
            "label_buffers_including_nul": label_lengths,
            "deferred_update_lines": deferred_updates,
            "deferred_counter_bits": 32,
            "maximum_deferred_increments_per_function": 2**32-1,
            "decrement_bound_required_separately": True,
            "hash_prime_table": primes,
            "maximum_live_hash_entries_for_bounded_probe_arithmetic": live_limit,
            "maximum_hash_capacity": int_max,
            "maximum_pointer_backbone_bytes": 8*int_max,
            "hash_capacity_cases": hash_cases,
            "RTL_pool_offsets": {
                "offset_bits": 64, "offset_signed": True,
                "align_and_mask_bits": 32, "mask_unsigned": True,
                "sufficient_per_pool_charge": "sum(a_i-1+s_i) <= 2^32-1",
                "maximum_charge": uint_max,
                "witness_above_mask_width": {
                    "incoming_offset": before, "alignment_bytes": byte_alignment,
                    "unsigned_mask": unsigned_mask,
                    "actual_aligned_offset": narrowed,
                    "mathematical_aligned_offset": mathematical,
                    "fits_old_signed64_sum_bound": True,
                },
                "mask_boundary_cases": mask_cases,
                "scope": "local arithmetic; actual source-to-descriptor/mode counts remain open",
            },
            "scope": "local event-to-representation transfers; source event counts remain required",
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
            "ordinary_Main_gigi_lowering": {
                "maximum_visits_per_expanded_literal_identity": 2,
                "events": "2*N_lit <= 2*A_Main",
                "payload_bytes": "2*W_lit <= 2*A_Main*L_max",
                "constructor_bytes": "2*W_lit+42*N_lit",
                "premises": "current normalized Main grammar; cached entity/lazy initialization; scalar literal subtype bounds; selected no-inlining native invocation",
                "excluded": "later GCC copies and constant-pool requests; named objects; diagnostic/filename/fixed dependency Strings",
            },
        },
    }
    args.output.mkdir(parents=True, exist_ok=True)
    (args.output / "checks.json").write_text(json.dumps(results, indent=2) + "\n")
    (args.output / "source-excerpts.md").write_text("".join(excerpts))
    print(f"Verified {len(verified)} source files and local arithmetic")


if __name__ == "__main__":
    main()
