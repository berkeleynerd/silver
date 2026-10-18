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
    "gas/as.c": [(75, 75), (91, 95), (105, 123), (1012, 1018), (1319, 1320)],
    "gas/as.h": [(140, 147), (274, 274), (331, 337)],
    "gas/dw2gencfi.c": [(47, 91), (113, 149), (393, 459), (499, 553),
                       (573, 640), (802, 883), (1337, 1394),
                       (1658, 1790), (1910, 2154), (2208, 2290),
                       (2385, 2500), (2598, 2624)],
    "gas/config/tc-i386.c": [(205, 205), (728, 749), (777, 777),
                             (3744, 3758), (4281, 4287), (4837, 4919),
                             (6672, 6674), (6752, 6754), (7780, 7796),
                             (10466, 10507), (11581, 11603),
                             (12045, 12185), (12289, 12357),
                             (12603, 12640), (12689, 12870),
                             (12956, 12965), (18757, 18762)],
    "gas/config/tc-i386.h": [(308, 338), (472, 484)],
    "gas/symbols.c": [(251, 286), (903, 924)],
    "gas/expr.c": [(57, 100)],
    "gas/frags.c": [(28, 41), (76, 141), (162, 202), (211, 267), (395, 405)],
    "gas/frags.h": [(38, 108)],
    "gas/subsegs.c": [(131, 145)],
    "gas/read.c": [(4547, 4559), (4618, 4619), (4686, 4692)],
    "gas/write.c": [(2681, 2784)],
    "gas/ehopt.c": [(390, 440), (480, 582)],
    "gas/dwarf2dbg.c": [(1071, 1082), (3108, 3118)],
    "opcodes/i386-opc.tbl": [(192, 192), (246, 248), (260, 262),
                             (521, 524), (636, 636)],
    "opcodes/i386-reg.tbl": [(135, 136)],
    "gas/gen-sframe.c": [(54, 59), (210, 225), (392, 421), (428, 506), (526, 627),
                          (649, 738), (742, 1037), (1070, 1117),
                          (1204, 1303), (1310, 1454), (1600, 1637),
                          (2398, 2437), (2467, 2521)],
    "include/sframe.h": [(148, 188), (279, 319)],
    "gas/sframe-opt.c": [(34, 190)],
    "include/obstack.h": [(105, 125), (137, 163)],
    "libiberty/obstack.c": [(79, 85), (115, 150), (188, 236)],
}
UNIT_RANGES = {
    "gas/as.c": [(113, 113), (1352, 1361), (1425, 1447)],
    "gas/config/obj-elf.c": [(118, 123), (2431, 2467), (2986, 3016)],
    "gas/config/tc-i386.h": [(97, 97), (234, 236), (372, 386)],
    "gas/read.c": [(809, 862), (6019, 6083)],
    "gas/frags.c": [(311, 332), (364, 374)],
    "gas/subsegs.c": [(34, 46), (131, 153)],
    "gas/dw2gencfi.c": [(284, 345), (1399, 1438), (2608, 2624)],
    "gas/write.c": [(1835, 1897), (1901, 1925), (1988, 2111), (2131, 2146)],
    "bfd/elf.c": [(292, 321)],
    "bfd/section.c": [(1114, 1132)],
    "bfd/elfxx-x86.c": [(40, 44)],
    "bfd/elf-bfd.h": [(2225, 2232)],
    "bfd/elf-attrs.h": [(26, 34)],
    "bfd/elf-attrs.c": [(314, 330)],
}
for _name, _ranges in UNIT_RANGES.items():
    RANGES.setdefault(_name, []).extend(_ranges)
SYMBOL_RANGES = {
    "gas/as.c": [(1368, 1388)],
    "gas/symbols.c": [(35, 172), (330, 424), (439, 487), (659, 683),
                      (730, 761), (839, 897), (2037, 2165), (3131, 3167)],
    "gas/expr.c": [(38, 100), (729, 750), (2108, 2143)],
    "gas/expr.h": [(116, 158)],
    "gas/config/obj-elf.c": [(203, 234), (2086, 2098), (2183, 2231),
                            (2728, 2813)],
    "gas/config/obj-elf.h": [(72, 101), (127, 129)],
    "gas/subsegs.c": [(235, 281)],
    "gas/read.c": [(3366, 3385), (4868, 4916)],
    "gas/write.c": [(129, 215), (238, 287), (955, 1030), (1258, 1388),
                    (1764, 1810), (1927, 1985), (2211, 2237)],
    "gas/write.h": [(47, 169)],
    "gas/config/tc-i386.c": [(13331, 13352), (18268, 18284), (18617, 18639)],
    "gas/config/tc-i386.h": [(120, 122), (343, 343)],
    "bfd/section.c": [(817, 855)],
    "bfd/syms.c": [(177, 197), (306, 324)],
    "bfd/elf-bfd.h": [(74, 94)],
    "bfd/elf.c": [(9788, 9797)],
    "bfd/reloc.c": [(100, 115)],
    "include/elf/internal.h": [(128, 140)],
}
for _name, _ranges in SYMBOL_RANGES.items():
    RANGES.setdefault(_name, []).extend(_ranges)


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
    x86 = sources["gas/config/tc-i386.c"]
    assert "static int align_branch_power = 0;" in x86
    assert "static int lfence_after_load = 0;" in x86
    assert "i.rm.mode = 3;" in x86
    assert "FRAG_APPEND_1_CHAR (i.tm.base_opcode);" in x86
    assert "p = frag_more (4 + 4 + 4 + 4 + descsz);" in x86
    assert "enum debug_info_type debug_type = DEBUG_UNSPECIFIED;" in sources["gas/as.c"]
    assert "if (debug_type != DEBUG_DWARF2" in sources["gas/dwarf2dbg.c"]
    assert "SYNTH_CFI_NONE = 0," in sources["gas/as.h"]
    assert "bool flag_generate_build_notes = DEFAULT_GENERATE_BUILD_NOTES;" in sources["gas/as.c"]
    assert "#define SUB_SEGMENT_ALIGN(SEG, FRCHAIN) 0" in sources["gas/config/tc-i386.h"]
    assert "#define md_section_align(seg, value) ((void)(seg), (value))" in sources["gas/config/tc-i386.h"]
    assert "TC_OBJ_ATTR" not in sources["gas/config/tc-i386.h"]
    assert "OBJ_ATTR_VERSION_NONE = 0," in sources["bfd/elf-attrs.h"]
    assert "case OBJ_ATTR_VERSION_NONE:\n      return 0;" in sources["bfd/elf-attrs.c"]
    assert "abfd->tdata.any = bfd_zalloc (abfd, object_size);" in sources["bfd/elf.c"]
    assert "return bfd_elf_allocate_object (abfd, sizeof (struct elf_x86_obj_tdata));" in sources["bfd/elfxx-x86.c"]
    assert "note_size = 36;" in sources["gas/write.c"]
    assert "desc_size = 16;" in sources["gas/write.c"]
    sframe = sources["gas/gen-sframe.c"]
    assert "symbolS **fde_fre_symbols = XNEWVEC (symbolS *, num_fdes);" in sframe
    assert "struct sframe_row_entry *fre = XCNEW (struct sframe_row_entry);" in sframe
    assert "gas_assert (sframe_fde->num_fres <= UINT16_MAX);" in sframe
    assert "gas_assert (flag_gen_sframe_version == GEN_SFRAME_VERSION_3);" in sframe
    assert "#define sframe_ra_tracking_p() false" in sources["gas/config/tc-i386.h"]
    assert "frag->fr_fix += frag->fr_subtype & 7;" in sources["gas/sframe-opt.c"]
    frags = sources["gas/frags.c"]
    assert "static unsigned int totalfrags;" in frags
    assert "obstack_blank (ob, extra + SIZEOF_STRUCT_FRAG);" in frags
    assert "while (obstack_room (&frchain_now->frch_obstack) < nchars)" in frags
    assert "newc = 2 * nchars;" in frags
    assert "obstack_blank_fast (&frchain_now->frch_obstack, nchars);" in frags
    assert "unsigned int region:16;" in sources["gas/frags.h"]
    assert "int chunksize = 0;" in sources["gas/as.c"]
    assert "int debug_memory = 0;" in sources["gas/as.c"]
    assert "obstack_begin (&newP->frch_obstack, chunksize);" in sources["gas/subsegs.c"]
    assert "new_size = sum2 + (obj_size >> 3) + 100;" in sources["libiberty/obstack.c"]
    symbols = sources["gas/symbols.c"]
    assert 'local_symbol_make (".gasversion.", absolute_section,' in sources["gas/as.c"]
    assert 'size = sizeof (symbolS) + sizeof (struct xsymbol);' in symbols
    assert 'ent->sy.flags.local_symbol = 0;' in symbols
    assert 'dot_symbol.bsym = bfd_make_empty_symbol (stdoutput);' in symbols
    assert '#define FB_LABEL_SPECIAL (10)' in symbols
    assert 'static char symbol_name_build[24];' in symbols
    assert 'if (seginfo->sym)\n    return seginfo->sym;' in sources["gas/subsegs.c"]
    assert 'newsym = (elf_symbol_type *) bfd_zalloc (abfd, sizeof (*newsym));' in sources["bfd/elf.c"]
    assert '#define WORKING_DOT_WORD 1' in sources["gas/config/tc-i386.h"]
    for excluded in ['TC_SYMFIELD_TYPE', 'TC_FIX_TYPE', 'RELOC_EXPANSION_POSSIBLE',
                     'OBJ_COMPLEX_RELC']:
        assert excluded not in sources["gas/config/tc-i386.h"]
        assert excluded not in sources["gas/config/obj-elf.h"]
    assert 'rel->sym_ptr_ptr = notes_alloc (sizeof (asymbol *));' in x86
    assert 'relocs = notes_alloc (n * sizeof (arelent *));' in sources["gas/write.c"]

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
    instruction_bytes = 18 + 2 + 3 + 2 + 1
    assert instruction_bytes == 26 < 2**32
    sframe_rows = 1+advances
    sframe_header = 2+1+1+1+1+1+1+5*4
    sframe_fde_index = 8+4+4
    sframe_fde_attrs = 2+1+1+1
    sframe_bytes = sframe_header+sframe_fde_index+sframe_fde_attrs+sframe_rows*(4+1+2)
    assert sframe_rows <= 2**16-1 and sframe_bytes == 91
    x86_property_bytes = 4*4+2*((12+7)//8*8)
    assert x86_property_bytes == 48
    payload_bytes = instruction_bytes+eh_frame+sframe_bytes+x86_property_bytes
    explicit_room_requests = advances+1+sframe_rows
    variant_closes = advances+2+1+sframe_rows
    fragment_allocations = 2*payload_bytes+explicit_room_requests+variant_closes
    assert payload_bytes == 257 and fragment_allocations == 540
    # Selected ABI bounds and per-call transfer, not sizeof measurements.
    header_low, header_high, append_high, mask, chunk = 76, 160, 48, 15, 4064
    assert append_high < header_low
    assert header_high+2*append_high <= chunk
    assert max(chunk, header_high+mask+100) == chunk
    room_after_new_header = chunk-16-mask-header_high
    assert room_after_new_header >= append_high
    assert chunk+mask <= ptrdiff_max
    # Every selected textual name, temporary or expression request can create
    # one GAS object; conversion does not create another name or GAS identity.
    gas_symbol_rows = {
        "compiler_named_and_numeric_labels": 3+5+2+1+3*5,
        "CFI_direct_temporary_expression_requests": 19,
        "SFrame_direct_temporary_expression_requests": 27,
        "GAS_section_symbols": 9+2+2,
        "file_symbol": 1, "size_current_location": 1, "gasversion_startup": 1,
    }
    gas_symbols = sum(gas_symbol_rows.values())
    assert gas_symbols == 88
    bfd_symbols = gas_symbols+13+1
    assert bfd_symbols == 102
    fixups = eh_frame+sframe_bytes+3*32
    assert fixups == 279 and fixups+2 == 281
    assert gas_symbols < 2**31 and bfd_symbols < 2**32 and fixups < 2**32
    assert (fixups+2)*8 == 2248 and gas_symbols*8 == 704
    result = {
        "commit": PIN,
        "source_files_checked": len(sources),
        "scope": "conditional streaming-buffer, instruction and frame consumer transfers; not whole assembler capacity",
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
        "selected_instructions": {
            "ordinary_instruction_count": 18+4,
            "encoded_function_bytes": instruction_bytes,
            "instruction_fixups": 0,
            "instruction_relaxation_fragments": 0,
        },
        "optional_SFrame": {
            "translation_context_requests": 1, "FDE_requests": 1,
            "row_requests": sframe_rows, "row_count": sframe_rows,
            "symbol_pointer_array_bytes": 8,
            "header_bytes": sframe_header, "FDE_index_bytes": sframe_fde_index,
            "FDE_attribute_bytes": sframe_fde_attrs,
            "row_reservation_bytes": 4+1+2,
            "section_contribution_bytes": sframe_bytes,
            "variant_fragment_requests": 1+sframe_rows,
            "direct_temporary_symbol_requests": 4+1+1,
            "direct_expression_symbol_requests": 3*(1+sframe_rows),
            "expression_location_record_requests": 3*(1+sframe_rows),
        },
        "optional_x86_property_note_payload_bytes": x86_property_bytes,
        "selected_fragment_growth": {
            "header_bytes_ABI_lower_bound": header_low,
            "header_bytes_ABI_upper_bound": header_high,
            "largest_append_or_room_request": append_high,
            "combined_payload_reservation_bytes": payload_bytes,
            "explicit_preallocation_requests": explicit_room_requests,
            "variant_fragment_closes": variant_closes,
            "fragment_allocations_excluding_other_paths": fragment_allocations,
            "chunk_request_bytes": chunk,
            "minimum_room_after_new_header": room_after_new_header,
            "maximum_grow_loop_iterations": 1,
            "region_increment_events_excluding_other_paths": 2,
        },
        "selected_unit_emission": {
            "compiler_property_notes": 3,
            "compiler_property_payload_bytes": 3*32,
            "compiler_property_alignment_events": 3*3,
            "compiler_property_numeric_label_definitions": 3*5,
            "configured_ident_bytes_example": len("GCC: (GNAT-FSF-builds) 16.1.0"),
            "comment_payload_bytes": "I+2",
            "optional_build_note_bytes": 36,
            "optional_build_note_relocations": 2,
            "ordinary_GAS_sections": 9,
            "internal_GAS_sections": 2,
            "static_absolute_undefined_subsections": 2,
            "subsections_and_initial_fragments": 13,
            "final_alignment_and_sentinel_events": 11,
            "selected_unit_output_payload_bytes": "391+I",
            "selected_unit_positive_backing_reservations": "403+I",
            "selected_unit_fragment_allocation_bound": "866+2*I",
            "fragment_bound_at_I_29": 2*(403+29)+12+35+13,
            "largest_region_increment_count_per_section": 10,
            "maximum_assembler_line_bytes": "max(64,I+10)",
            "scope": "selected null unit payload/fragments; symbol, BFD and ELF metadata storage separate",
        },
        "selected_GAS_symbols_and_fixups": {
            "GAS_symbol_creation_rows": gas_symbol_rows,
            "GAS_symbol_objects": gas_symbols,
            "maximum_name_copy_bytes_including_NUL": 26,
            "local_conversions_per_symbol_at_most": 1,
            "BFD_symbol_allocations_through_GAS": bfd_symbols,
            "expression_location_records": 5+21,
            "size_expression_objects": 1,
            "selected_LP64_raw_request_upper_bytes": {
                "full_symbol_and_xsymbol": 160, "local_symbol": 64,
                "converted_xsymbol": 96, "ELF_BFD_symbol": 128,
                "expression": 40, "expression_location_record": 32,
                "fixS": 128, "arelent": 32, "relocation_symbol_pointer": 8,
                "build_note_reloc_list": 72,
            },
            "fixS_objects": fixups,
            "maximum_fixup_field_bytes": 8,
            "extra_build_note_reloc_list_objects": 2,
            "maximum_relocation_pointer_slots": fixups+2,
            "maximum_relocation_pointer_array_bytes": (fixups+2)*8,
            "maximum_symbol_pointer_array_bytes": gas_symbols*8,
            "numeric_property_label_numbers": list(range(5)),
            "maximum_numeric_label_instances_each": 3,
            "numeric_label_sparse_array_allocations": 0,
            "later_BFD_generated_ELF_metadata_symbols_included": False,
            "global_notes_obstack_or_allocator_storage_established": False,
        },
        "compiler_runs": 0, "assembler_runs": 0, "linker_runs": 0, "prover_runs": 0,
    }
    args.output.write_text(json.dumps(result, indent=2)+"\n")
    print(f"Verified {len(sources)} Binutils files and local buffer/instruction/frame arithmetic")


if __name__ == "__main__":
    main()
