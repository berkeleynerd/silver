#!/usr/bin/env python3
"""Check retained GAS source identities and local arithmetic; execute no toolchain."""

import argparse
import hashlib
import json
from pathlib import Path
import tarfile


PIN = "5e56594815854de5eca35c7c04b11705d0f19c02"
RANGES = {
    "gas/input-file.c": [(40, 40), (69, 74)],
    "gas/input-scrub.c": [(50, 74), (141, 151), (380, 438)],
    "gas/as.c": [(105, 123)],
    "gas/as.h": [(140, 147)],
    "gas/dw2gencfi.c": [(47, 91), (113, 149), (393, 459), (499, 553),
                       (573, 640), (802, 883), (1337, 1394),
                       (1658, 1790), (1910, 2154), (2208, 2290),
                       (2385, 2500), (2598, 2624)],
    "gas/config/tc-i386.c": [(3744, 3758), (7785, 7795), (18757, 18762)],
    "gas/symbols.c": [(251, 286), (903, 924)],
    "gas/expr.c": [(57, 100)],
    "gas/frags.c": [(28, 41), (76, 94)],
    "gas/frags.h": [(73, 84)],
    "gas/ehopt.c": [(480, 582)],
    "gas/dwarf2dbg.c": [(3108, 3118)],
}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", required=True, type=Path)
    parser.add_argument("--record-excerpts", action="store_true")
    args = parser.parse_args()
    bundle = Path(__file__).resolve().parent
    manifest = json.loads((bundle / "source-manifest.json").read_text())
    release = json.loads((bundle.parent / "retained-linker-capacity-20261018"
                          / "release-tag.json").read_text())
    assert manifest["commit"] == release["object"]["sha"] == PIN
    sources = {}
    with tarfile.open(bundle / "sources.tar.gz") as archive:
        assert sorted(archive.getnames()) == sorted(r["path"] for r in manifest["files"])
        for row in manifest["files"]:
            assert f"/{PIN}/" in row["url"]
            data = archive.extractfile(row["path"]).read()
            assert len(data) == row["bytes"]
            assert hashlib.sha256(data).hexdigest() == row["sha256"], row["path"]
            sources[row["path"]] = data.decode()
    excerpts = ["# Pinned GAS source excerpts\n\nLiteral LF line numbering.\n"]
    for name, ranges in RANGES.items():
        lines = sources[name].split("\n")
        for low, high in ranges:
            assert 1 <= low <= high <= len(lines)
            excerpts.append(f"\n## {name}:{low}–{high}\n\n```text\n")
            excerpts.extend((f"{n}: " + lines[n-1].expandtabs(8)).rstrip()+"\n"
                            for n in range(low, high+1))
            excerpts.append("```\n")
    excerpts = "".join(excerpts)
    if args.record_excerpts:
        (bundle / "source-excerpts.md").write_text(excerpts)
    else:
        assert (bundle / "source-excerpts.md").read_text() == excerpts

    assert "#define BUFFER_SIZE (32 * 1024)" in sources["gas/input-file.c"]
    scrub = sources["gas/input-scrub.c"]
    assert "buffer_length = input_file_buffer_size () * 2;" in scrub
    assert "buffer_length - input_file_buffer_size () < partial_size" in scrub
    assert "buffer_length *= 2;" in scrub
    cfi = sources["gas/dw2gencfi.c"]
    assert "struct fde_entry *fde = notes_calloc (1, sizeof (*fde));" in cfi
    assert "frchain_now->frch_cfi_data = notes_calloc (1, sizeof (struct frch_cfi_data));" in cfi
    assert "cfi_add_advance_loc (symbol_temp_new_now ());" in cfi
    assert "tc_cfi_frame_initial_instructions ();" in cfi
    assert "frag_var (rs_cfa, 4, 0, DWARF2_LINE_MIN_INSN_LENGTH << 3," in cfi
    assert "cie = XNEW (struct cie_entry);" in cfi
    assert "flag_gen_sframe == GEN_SFRAME_CONFIG_ENABLED" in cfi
    assert "#if DEFAULT_SFRAME" in sources["gas/as.c"]
    assert "flag_dwarf_cie_version = 1;" in sources["gas/dwarf2dbg.c"]
    assert "cfi_add_CFA_def_cfa (object_64bit ? REG_SP : 4, -x86_cie_data_alignment);" in sources["gas/config/tc-i386.c"]
    assert "cfi_add_CFA_offset (x86_dwarf2_return_column, x86_cie_data_alignment);" in sources["gas/config/tc-i386.c"]
    assert "frag->fr_subtype = (frag->fr_subtype & ~7) | (ret & 7);" in sources["gas/ehopt.c"]

    b = 32768
    ptrdiff_max = 2**63-1
    cases = []
    for longest in [0, 1, 32767, 32768, 32769, 65536, 2**62-b]:
        threshold = longest+b
        capacity = max(2*b, 1 << (threshold-1).bit_length())
        assert capacity >= threshold
        assert capacity == 2*b or capacity//2 < threshold
        assert capacity+3 <= ptrdiff_max
        c = 2*b
        growths = 0
        while c < threshold:
            # Every actual doubling satisfies this necessary condition.
            assert c-b < longest
            c *= 2
            growths += 1
        assert c == capacity
        cases.append(dict(longest_line=longest, capacity=capacity,
                          request=capacity+3, maximum_growths=growths))
    assert cases[3]["request"] == 65539
    assert cases[4]["request"] == 131075
    cie_fixed = 4+4+1+3+2+1+1+1+1+1
    fde_fixed = 4+4+4+4+1
    rules, advances = 2+5, 5
    eh_frame = cie_fixed+fde_fixed+3+7+rules*3+advances*5
    assert cie_fixed == 19 and fde_fixed == 17 and eh_frame == 92
    result = {
        "commit": PIN,
        "source_files_checked": len(sources),
        "scope": "conditional streaming-buffer and CFI consumer transfers; not whole assembler capacity",
        "input_buffer": {"read_block_bytes": b, "cases": cases},
        "selected_cfi": {
            "FDE_objects": 1, "per_frchain_state_objects": 1,
            "rule_nodes": rules, "advance_nodes": advances,
            "total_CFI_nodes": rules+advances,
            "parser_temporary_symbol_requests": 1+advances+1,
            "CIE_objects": 1,
            "CIE_non_rule_bytes": cie_fixed, "FDE_non_rule_bytes": fde_fixed,
            "eh_frame_contribution_bytes": eh_frame,
            "direct_temporary_expression_symbol_requests": 7+3+2+1+1+advances,
            "expression_location_record_requests": advances,
        },
        "compiler_runs": 0, "assembler_runs": 0, "linker_runs": 0, "prover_runs": 0,
    }
    args.output.write_text(json.dumps(result, indent=2)+"\n")
    print(f"Verified {len(sources)} Binutils files and local buffer/CFI arithmetic")


if __name__ == "__main__":
    main()
