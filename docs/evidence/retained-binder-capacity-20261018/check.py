#!/usr/bin/env python3
"""Reconcile retained binder sources/objects without invoking native tools."""
import hashlib
from collections import Counter, defaultdict
import json
from pathlib import Path
import re
import struct
import tarfile

ROOT = Path(__file__).resolve().parent


def digest(raw):
    return {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}


def read_archive(name):
    with tarfile.open(ROOT / name, "r:gz") as archive:
        return {m.name: archive.extractfile(m).read()
                for m in archive.getmembers() if m.isfile()}


def elf(raw):
    assert raw[:6] == b"\x7fELF\x02\x01"
    hdr = struct.unpack_from("<HHIQQQIHHHHHH", raw, 16)
    assert hdr[0] == 1 and hdr[1] == 62  # ET_REL, EM_X86_64
    off, entsize, count, names = hdr[5], hdr[10], hdr[11], hdr[12]
    assert entsize == 64 and 0 < count < 0xFF00
    rows = [struct.unpack_from("<IIQQQQIIQQ", raw, off+i*entsize)
            for i in range(count)]
    names_raw = raw[rows[names][4]:rows[names][4]+rows[names][5]]

    def string(buf, offset):
        return buf[offset:buf.index(b"\0", offset)].decode("ascii")

    sections, symbols, relocations = [], [], []
    for i, row in enumerate(rows):
        name = string(names_raw, row[0])
        sections.append({"index": i, "name": name, "type": row[1],
                         "flags": row[2], "size": row[5], "alignment": row[8]})
        if row[1] == 2:  # SHT_SYMTAB
            assert row[9] == 24 and row[5] % 24 == 0
            strings = rows[row[6]]
            names_buf = raw[strings[4]:strings[4]+strings[5]]
            for pos in range(row[4], row[4]+row[5], 24):
                n, info, other, shndx, value, size = struct.unpack_from("<IBBHQQ", raw, pos)
                symbols.append({"name": string(names_buf, n), "binding": info >> 4,
                                "type": info & 15, "section": shndx,
                                "value": value, "size": size, "other": other})
        elif row[1] in (4, 9):
            expected = 24 if row[1] == 4 else 16
            assert row[9] == expected and row[5] % expected == 0
            relocations.append({"section": name, "count": row[5] // expected})
    assert all(not s["flags"] & 0x800 for s in sections)
    assert all(not s["name"].startswith((".gnu.lto_", ".gnu.offload_lto_", ".zdebug"))
               and s["name"] != ".gnu_object_only" for s in sections)
    return {"file": digest(raw), "sections": sections, "symbols": symbols,
            "relocations": relocations,
            "section_count": len(sections), "symbol_count": len(symbols),
            "relocation_count": sum(r["count"] for r in relocations),
            "external_names": sorted(s["name"] for s in symbols if s["binding"]),
            "maximum_section_alignment": max(s["alignment"] for s in sections),
            "common_symbol_count": sum(s["section"] == 0xfff2 for s in symbols),
            "merge_sections": [s["name"] for s in sections if s["flags"] & 16],
            "allocated_merge_section_count": sum(bool(s["flags"] & 16 and s["flags"] & 2) for s in sections),
            "eh_frame_section_count": sum(s["name"] == ".eh_frame" for s in sections),
            "eh_frame_bytes": sum(s["size"] for s in sections if s["name"] == ".eh_frame"),
            "sframe_section_count": sum(s["name"] == ".sframe" for s in sections),
            "sframe_bytes": sum(s["size"] for s in sections if s["name"] == ".sframe"),
            "allocated_bytes": sum(s["size"] for s in sections if s["flags"] & 2),
            "text_bytes": sum(s["size"] for s in sections if s["flags"] & 4)}


def outside_comments(raw):
    # Generated sources use LF; consume strings first so -- inside a literal
    # cannot be mistaken for a comment. Preserve each noncomment byte's column.
    assert b"\r" not in raw
    return re.sub(rb'"(?:[^"\n]|"")*"|--[^\n]*',
                  lambda m: b" "*len(m[0]) if m[0].startswith(b"--") else m[0], raw)


def token_locations(raw):
    result = []
    for line, text in enumerate(outside_comments(raw).split(b"\n"), 1):
        for m in re.finditer(rb'"(?:[^"\n]|"")*"|[A-Za-z0-9_]+|\S', text):
            result.append([line, m.start()+1, m[0].decode("ascii")])
    return result


def c_strings(raw):
    # Comments and character literals must be consumed before quoted strings.
    # These retained tables use ordinary C strings, with no raw-string syntax.
    tokens = re.findall(rb"""//[^\n]*|/\*.*?\*/|"(?:\\.|[^"\\])*"|'(?:\\.|[^'\\])*'""",
                        raw, re.S)
    return [t[1:-1].decode("unicode_escape")
            for t in tokens if t.startswith(b'"')]


def analyze(artifacts, sources):
    cases = ["indexed-cr", "indexed-lf", "indexed-uppercase", "unindexed-proposed"]
    indexed_specs, indexed_bodies, indexed_objects = [], [], []
    result = {"cases": {}}
    for case in cases:
        stem = "b__main" if case.startswith("unindexed") else "b__main~1"
        spec = artifacts[f"cases/{case}/{stem}.ads"]
        body = artifacts[f"cases/{case}/{stem}.adb"]
        obj = artifacts[f"cases/{case}/{stem}.o"]
        ali_stem = "main" if case.startswith("unindexed") else "main~1"
        main_ali = artifacts[f"cases/{case}/{ali_stem}.ali"]
        match = re.search(rb"^U main%b\s+main.adb\s+([0-9a-f]{8})(.*)$", main_ali, re.M)
        assert match and match[1] == b"73b77761"
        versions = re.findall(rb'pragma Export \(C, u[0-9]{5}, "([^"]+)"\);', spec)
        version_pairs = re.findall(
            rb'(u[0-9]{5}) : constant Version_32 := 16#([0-9a-f]{8})#;\n'
            rb'   pragma Export \(C, \1, "([^"]+)"\);', spec)
        assert len(version_pairs) == len(versions)
        explicit = re.findall(rb'pragma (?:Import|Export) \([^;]+, "([^"]+)"\);', spec+body)
        implicit_c = re.findall(rb'pragma (?:Import|Export) \(C, ([A-Za-z0-9_]+)\);', spec+body)
        assert all(re.fullmatch(rb"[A-Za-z0-9_]+", s) for s in explicit)
        assert not re.search(rb"\b(?:Machine_Code|Asm|Asm_Input|Asm_Output)\b", outside_comments(spec+body), re.I)
        e = elf(obj)
        assert all("@" not in s for s in e["external_names"])
        assert all(s["type"] != 10 for s in e["symbols"])  # STT_GNU_IFUNC
        result["cases"][case] = {
            "spec": digest(spec), "body": digest(body),
            "spec_lf_lines": spec.count(b"\n"), "body_lf_lines": body.count(b"\n"),
            "main_unit_flags": match[2].decode().split(),
            "main_version": match[1].decode(),
            "version_export_count": len(versions),
            "version_exports": [v.decode() for v in versions],
            "version_values": {name.decode(): value.decode() for _, value, name in version_pairs},
            "explicit_external_names": sorted(set(n.decode() for n in explicit)),
            "implicit_c_external_names": sorted(set(n.decode() for n in implicit_c)),
            "object": e,
        }
        if case.startswith("indexed"):
            indexed_specs.append(spec)
            indexed_bodies.append(body)
            indexed_objects.append(obj)
    assert len(set(indexed_specs)) == len(set(indexed_objects)) == 1
    assert all(token_locations(indexed_bodies[0]) == token_locations(x) for x in indexed_bodies[1:])
    assert len(set(map(len, indexed_bodies))) == 1
    assert len(set(map(outside_comments, indexed_bodies))) == 1
    # Broad source alphabet checks support the naming argument; neither these
    # tables nor the observed object census establishes a compilation bound.
    naming_tables = ["gcc/ada/gcc-interface/ada-builtins.def", "gcc/builtins.def",
                     "gcc/sync-builtins.def", "gcc/omp-builtins.def", "gcc/gtm-builtins.def",
                     "gcc/sanitizer.def", "gcc/coroutine-builtins.def",
                     "gcc/config/i386/i386-builtin.def", "gcc/optabs.def"]
    naming_literals = {p: c_strings(sources[p]) for p in naming_tables}
    assert all(values and all("@" not in s for s in values)
               for values in naming_literals.values())
    selected_source = b"\n".join([indexed_specs[0], indexed_bodies[0]] +
        [v for k,v in artifacts.items() if k.startswith("compiler-support/")])
    assert not re.search(rb"\bpragma\s+(?:Machine_Attribute|Linker_Alias|Linker_Section|Weak_External)\b",
                         outside_comments(selected_source), re.I)
    assert not re.search(rb"\b(?:Machine_Code|Asm|Asm_Input|Asm_Output)\b",
                         outside_comments(selected_source), re.I)
    assert all(b".gnu.warning" not in sources[p] for p in (
        "gcc/varasm.cc", "gcc/config/i386/i386.cc", "gcc/config/elfos.h",
        "gcc/config/i386/att.h", "gcc/ada/gcc-interface/utils.cc"))
    assert all(not s["name"].startswith(".gnu.warning")
               for s in result["cases"]["indexed-lf"]["object"]["sections"])
    assert b'#define IFUNC_ASM_TYPE "gnu_indirect_function"' in sources["gcc/defaults.h"]
    assert b"&& cgraph_node::get (decl)->ifunc_resolver)" in sources["gcc/varasm.cc"]
    assert b"ifunc_resolver (false)" in sources["gcc/cgraph.h"]
    assert re.findall(rb'if \(lookup_attribute \("ifunc", DECL_ATTRIBUTES \((\w+)\)\)\)\s+'
                      rb'\w+->ifunc_resolver = true;', sources["gcc/cgraph.cc"]) == [b"decl", b"alias"]
    assert b'node->ifunc_resolver = 1;' in sources["gcc/lto-cgraph.cc"]
    assert b"fcommon\nCommon Var(flag_no_common,0) Init(1)" in sources["gcc/common.opt"]
    assert b"{ OPT_LEVELS_1_PLUS, OPT_fmerge_constants, NULL, 1 }" in sources["gcc/opts.cc"]
    assert b"default_opt->arg, !default_opt->value," in sources["gcc/opts.cc"]
    assert b"if (!flag_no_common\n      && VAR_P (var_decl)" in sources["gcc/ada/gcc-interface/utils.cc"]
    assert b"#define MAKE_DECL_ONE_ONLY(DECL) (DECL_WEAK (DECL) = 1)" in sources["gcc/config/elfos.h"]
    result["selected_object_kind_exclusions"] = {
        "common_variables": 0, "allocated_merge_sections": 0,
        "premises": ["selected O0 and no common/merge override",
                     "no Machine_Attribute, Linker_Section, assembly, plugins or OpenMP",
                     "selected Linux ELF target"],
        "nonallocated_comment_merge_section_excluded": False,
        "scope": "source routes; no universal payload, section-count or alignment bound",
    }
    selected_interfaces = re.findall(rb'pragma\s+(?:Import|Export)\s*\([^;]+"([^"\n]+)"\s*\)',
                                    outside_comments(selected_source), re.I)
    assert all(b"@" not in s for s in selected_interfaces)
    elab_names = sorted({name.lower().replace(b".", b"__") + b"___elab" + kind[:1].lower()
                        for name,kind in re.findall(rb"([A-Za-z][A-Za-z0-9_.]*)'Elab_(Body|Spec)",
                                                    outside_comments(indexed_bodies[0]))})
    assert len(elab_names) == 16
    observed_source_names = set(result["cases"]["indexed-lf"]["explicit_external_names"] +
                                result["cases"]["indexed-lf"]["implicit_c_external_names"])
    observed_object_names = set(result["cases"]["indexed-lf"]["object"]["external_names"])
    observed_extra_names = observed_object_names - observed_source_names
    assert observed_extra_names == {n.decode() for n in elab_names} | {
        "ada_main_E", "ada_main__Tsec_default_sized_stacksBIP", "system__secondary_stack__ss_stackIP"}
    result["naming_projection"] = {
        "builtin_optab_tables": {p: {"string_literals": len(v), "contains_at": False}
                                 for p,v in naming_literals.items()},
        "generated_elaboration_names": [n.decode() for n in elab_names],
        "observed_source_external_name_count": len(observed_source_names),
        "observed_object_additional_names": sorted(observed_extra_names),
        "selected_explicit_section_and_assembly_ingress_absent": True,
        "observed_gnu_warning_sections": 0,
        "observed_gnu_ifunc_symbols": 0,
        "selected_ifunc_attribute_and_lto_ingress_absent": True,
        "scope": "source naming alphabet and constructors; object counts and name-length bound remain open",
    }
    # Only the three workspace comment lines change in these retained cases.
    differences = []
    for body in indexed_bodies[1:]:
        different = [i for i, (a, b) in enumerate(zip(indexed_bodies[0].split(b"\n"), body.split(b"\n")), 1) if a != b]
        assert different == [194, 195, 196]
        differences.append(different)
    result["indexed_body_differing_lines"] = differences
    lines = indexed_bodies[0].split(b"\n")
    assert all(lines[i].startswith(b"   --   ") for i in range(193, 197))
    paths = [lines[193][8:]] + [lines[i][10:] for i in range(194, 197)]
    assert all(p.startswith(b"/") and all(32 <= b <= 126 for b in p) for p in paths)
    workspace_match = re.fullmatch(rb"(.*)(/program-[A-Za-z0-9]{6})/obj/main~1.o", paths[0])
    assert workspace_match
    installation_root, workspace_leaf = workspace_match.groups()
    result["compiler_filename_interning"] = {
        "varying_full_path_count": 2,
        "each_full_path_bytes": len(installation_root)+33,
        "identifier_contribution_bound": 2,
        "nul_inclusive_character_contribution_bound": 2*(len(installation_root)+34),
        "scope": "Gigi file-info interning only; all other compiler allocations remain separate",
    }
    assert paths[1] == paths[2] == installation_root+workspace_leaf+b"/obj/"
    assert all(len(p) == len(q) for body in indexed_bodies[1:]
               for p, q in zip(paths, [body.split(b"\n")[193][8:]]
                               + [body.split(b"\n")[i][10:] for i in range(194, 197)]))
    body_constant = len(indexed_bodies[0]) - sum(map(len, paths))
    assert body_constant == 7483
    q = lambda b: 4096 * ((b + 4096) // 4096)
    result["generated_source_bound"] = {
        "spec_bytes": 14556, "body_constant_bytes": body_constant,
        "path_occurrences": 4, "path_bound_example": 4096,
        "raw_combined_at_example": 14556 + body_constant + 4*4096,
        "aligned_combined_at_example": q(14556) + q(body_constant + 4*4096),
        "source_union_including_fixed_runtime_and_virtual": q(14556) + q(body_constant + 4*4096) + 20496384 + 4096,
        "fixed_installation_root_bytes": len(installation_root),
        "fixed_workspace_leaf_bytes": len(workspace_leaf),
        "fixed_path_occurrence_lengths": list(map(len, paths)),
        "fixed_installation_body_bytes": body_constant+sum(map(len, paths)),
        "fixed_installation_noncomment_byte_projection": digest(outside_comments(indexed_bodies[0])),
    }
    assert body_constant+sum(map(len, paths)) == 7551+3*len(installation_root)+len(paths[3])
    # A source read projection establishes the emitted family first. The
    # monotone append/reset helpers then make the greatest fixed output-line
    # width a bound on every intermediate statement-buffer occupancy.
    bindgen = sources["gcc/ada/bindgen.adb"]
    stm_assignments = re.findall(rb"^\s*Stm_Last\s*:=\s*([^;]+);", bindgen, re.M)
    assert stm_assignments == [b"Stm_Last + True_Str'Length", b"Stm_Last + False_Str'Length",
                               b"Stm_Last + 1", b"Stm_Last + 1", b"Stm_Last + S'Length", b"0"]
    assert b"Statement_Buffer : String (1 .. 1000);" in bindgen
    assert b"Statement_Buffer (Stm_Last - S'Length + 1 .. Stm_Last) := S;" in bindgen
    object_options = re.search(rb"   procedure Gen_Object_Files_Options [^\n]+ is\n(.*?)   end Gen_Object_Files_Options;",
                               bindgen, re.S)[1]
    assert b"Set_String" not in object_options and b"Set_Char" not in object_options
    assert b'WBI ("   --   " & Name_Buffer (1 .. Name_Len));' in object_options
    assert b'WBI ("   --   " & Name_Buffer (Start .. Stop - 1));' in object_options
    fixed_lines = indexed_specs[0].split(b"\n") + [line for i,line in enumerate(lines, 1)
                                                 if i not in (194, 195, 196, 197)]
    assert max(map(len, fixed_lines)) == 139
    write_info = re.search(rb"   procedure Write_Info \(Info : String\) is\n(.*?)   end Write_Info;",
                           sources["gcc/ada/osint.adb"], re.S)[1]
    assert write_info.strip() == (b"begin\n      Write_With_Check (Info'Address, Info'Length);\n"
                                  b"      Write_With_Check (EOL'Address, 1);")
    assert b"type Column_Number is range 0 .. 32767;" in sources["gcc/ada/types.ads"]
    assert b"Types.Column_Number'Pred (Types.Column_Number'Last)" in sources["gcc/ada/hostparm.ads"]
    assert b"Buffer_Max : constant := Hostparm.Max_Line_Length;" in sources["gcc/ada/output.ads"]
    assert b"Buffer : String (1 .. Buffer_Max + 1)" in sources["gcc/ada/output.adb"]
    result["generation_buffers"] = {
        "statement_capacity": 1000, "statement_occupancy_bound": 139,
        "fixed_output_line_bound": 139,
        "fixed_installation_all_output_line_bound": max(map(len, indexed_specs[0].split(b"\n") + lines)),
        "stmt_index_assignments": [s.decode() for s in stm_assignments],
        "variable_path_comments_bypass_statement_buffer": True,
        "generated_source_sink_accumulates_whole_file": False,
        "object_list_path_bytes": len(paths[0]),
        "output_buffer_bytes": 32767,
        "object_list_line_including_lf_bytes": len(paths[0])+1,
        "scope": "selected generation and output buffers; compiler and driver allocations remain separate",
    }
    # Keep the historical unindexed command separate from the indexed
    # source-derived template. The log corroborates the shape, not its bound.
    old_command = re.findall(rb"^\S+/gnatbind (.*)$",
                             artifacts["cases/unindexed-proposed/build.stdout"], re.M)
    assert len(old_command) == 1
    old_args = old_command[0].split()
    assert len(old_args) == 6 and old_args[:2] == [b"-o", b"b__main.adb"]
    assert old_args[2].endswith(b"/main.ali") and old_args[3] == b"-x"
    assert old_args[4].startswith(b"-F=/tmp/GPR.") and old_args[5].startswith(b"-O=/tmp/GPR.")
    main_ali_path = len(paths[0])+2
    argv_constant = sum(map(len, [b"-o", b"b__main~1.adb", b"-x", b"-F=", b"-O="]))+6
    assert argv_constant == 29
    linux_link = sources["gcc/ada/link.c"].split(b"#elif defined (__linux__) || defined (__GLIBC__)")[1].split(b"#elif")[0]
    assert b"int __gnat_link_max = 8192;" in linux_link
    assert b'pragma Import (C, Maximum_Size, "__gnat_link_max");' in sources["gpr/gpr/src/gpr-util.ads"]
    assert b"Line : String (1 .. 1_000);" in sources["gpr/src/gprbind.adb"]
    result["selected_binder_arguments"] = {
        "historical_unindexed_arguments": [a.decode() for a in old_args],
        "argument_count": 6, "size_constant_excluding_ali_and_two_temp_paths": argv_constant,
        "main_ali_path_bytes": main_ali_path, "tmp_root_example_bytes": 4,
        "temp_path_bound_at_tmp_root": 40,
        "size_including_argument_terminators_at_tmp_root": main_ali_path+argv_constant+2*40,
        "linux_response_threshold": 8192,
        "exchange_row_capacity": 1000,
        "size_if_each_temp_path_fits_exchange_row": main_ali_path+argv_constant+2*1000,
        "filename_pointer_and_index_array_slots_each": 8,
        "filename_array_used_slots": 1,
        "scan_retained_string_bytes_at_tmp_root": main_ali_path+13+2*40,
        "main_directory_two_copy_bytes": 2*len(paths[1]),
        "scope": "six-argument descriptor; exchange-row producer/configuration and search storage remain separate",
    }
    common_gnat_config = artifacts["configuration/gnat.xml"].split(b"<!-- CUDA -->")[0]
    assert b'for Mapping_File_Switches    ("Ada") use ("-gnatem=");' in common_gnat_config
    assert b'for Objects_Path_File     ("Ada") use "ADA_PRJ_OBJECTS_FILE";' in common_gnat_config
    assert b"Use_Include_Path_File : Boolean := False;" in sources["gpr/gpr/src/gpr-opt.ads"]
    result["selected_search_directories"] = {
        "project_object_directory_rows": 1,
        "project_object_path_file_bytes_bound": len(paths[1])+1,
        "source_table_demand_including_primary": 2,
        "library_table_demand_including_primary": 3,
        "each_table_initial_capacity": 10,
        "project_directory_normalized_bytes": len(paths[1]),
        "runtime_library_directory_bytes": len(paths[3]),
        "runtime_source_directory_bytes": len(paths[3])+4,
        "three_normalized_directory_payload_bytes": len(paths[1])+2*len(paths[3])+4,
        "runtime_path_iteration_copy_bytes_bound": 2*len(paths[3])+4,
        "premises": ["no extra configured binder search switch",
                     "ADA_INCLUDE_PATH, ADA_OBJECTS_PATH, ADA_PRJ_INCLUDE_FILE empty or absent",
                     "ADA_PRJ_OBJECTS_FILE is the generated one-row project file",
                     "default runtime and absent optional installed search files",
                     "fixed absolute binder executable; absent GNSA_ROOT/GCC_ROOT and fixed filesystem"],
        "scope": "source-derived descriptor; no retained GPR child environment capture",
    }
    # Reconcile the one controlled binder run, without executing it again.
    prefix = "controlled-capture/"
    invocation = json.loads(artifacts[prefix+"invocation.json"])
    captured = json.loads(artifacts[prefix+"result.json"])
    input_manifest = json.loads(artifacts[prefix+"input-manifest.json"])
    original_members = input_manifest["archives"]["artifacts.tar.gz"]["members"]
    for name, row in original_members.items():
        assert digest(artifacts[name]) == {k: row[k] for k in ("bytes", "sha256")}
    argv, environment = invocation["argv"], invocation["environment"]
    assert len(argv) == 7 and argv[1:3] == ["-o", "b__main~1.adb"] and argv[4] == "-x"
    assert argv[0].endswith("/bin/gnatbind") and argv[3].endswith("/obj/main~1.ali")
    assert argv[5].startswith("-F=") and argv[6].startswith("-O=")
    assert set(environment) == {"PATH", "LC_ALL", "TMPDIR", "ADA_PRJ_OBJECTS_FILE"}
    assert environment["LC_ALL"] == "C"
    assert environment["PATH"] == str(Path(argv[0]).parent)+":/usr/bin:/bin"
    assert len(environment["TMPDIR"]) == captured["temporary_root_bytes"] == 43
    assert len(argv[3]) == main_ali_path
    temporary_names = {argv[5][3:], environment["ADA_PRJ_OBJECTS_FILE"], argv[6][3:]}
    assert all(p.startswith(environment["TMPDIR"]+"/GPR.") for p in temporary_names)
    assert all(len(p) <= captured["temporary_root_bytes"]+36 for p in temporary_names)
    assert set(invocation["temporary_input_files"]) == {argv[5][3:], environment["ADA_PRJ_OBJECTS_FILE"]}
    for path, row in invocation["temporary_input_files"].items():
        raw = artifacts[prefix+"temporary/"+Path(path).name]
        assert digest(raw) == row["identity"] and raw.decode() == row["text"]
    assert invocation["temporary_input_files"][argv[5][3:]]["text"] == ""
    object_directory = str(Path(argv[3]).parent)+"/\n"
    assert invocation["temporary_input_files"][environment["ADA_PRJ_OBJECTS_FILE"]]["text"] == object_directory
    assert len(object_directory) == result["selected_search_directories"]["project_object_path_file_bytes_bound"]
    required_inputs = {row["original_path"]: {k: row[k] for k in ("bytes", "sha256")}
                       for name, row in original_members.items()
                       if name.startswith(("closure/", "compiler-support/")) or
                       name in ("cases/indexed-cr/b__main~1.ads", "cases/indexed-cr/b__main~1.adb")}
    for path, row in required_inputs.items():
        assert invocation["input_identities"][path] == row
    assert set(invocation["input_identities"]) == set(required_inputs) | {argv[0]}
    for suffix in ("ads", "adb"):
        name = "b__main~1."+suffix
        raw = artifacts[prefix+"output/"+name]
        assert raw == artifacts["cases/indexed-cr/"+name]
        assert digest(raw) == captured["generated"][name]
        assert captured["matches_original_indexed_source"][name] is True
    assert set(captured["generated"]) == {"b__main~1.ads", "b__main~1.adb"}
    object_list = artifacts[prefix+"temporary/"+Path(argv[6][3:]).name]
    assert object_list.decode() == captured["object_list"]["text"] == argv[3][:-4]+".o\n"
    assert digest(object_list) == captured["object_list"]["identity"]
    assert not artifacts[prefix+"stdout"] and not artifacts[prefix+"stderr"]
    assert captured["returncode"] == captured["stdout_bytes"] == captured["stderr_bytes"] == 0
    assert captured["retained_inputs_unchanged"] is True
    assert captured["host"].startswith("Linux-")
    assert captured["selected_argument_count"] == 6
    assert sum(len(a)+1 for a in argv[1:]) == captured["selected_argument_bytes_with_terminators"] == 303
    events = [json.loads(line) for line in artifacts[prefix+"managed/events.jsonl"].splitlines()]
    prepared, = [e for e in events if e["event"] == "prepared"]
    managed_pins = prepared["inputs"]["inputs_sha256"]
    manifest_pin, = [v for p,v in managed_pins.items() if p.endswith("/retained-binder-capacity-20261018/manifest.json")]
    script_pin, = [v for p,v in managed_pins.items() if p.endswith("/silver-binder-fixed-20261018/run.py")]
    assert manifest_pin == digest(artifacts[prefix+"input-manifest.json"])["sha256"]
    assert script_pin == digest(artifacts[prefix+"run.py"])["sha256"]
    assert managed_pins[argv[0]] == invocation["input_identities"][argv[0]]["sha256"]
    finished, = [e for e in events if e["event"] == "finished"]
    assert finished["outcome"] == "success"
    native_end, = [e for e in events if e["event"] == "phase-end" and e["phase"] == "native-tool"]
    assert native_end["returncode"] == 0
    result["controlled_binder_capture"] = {
        "managed_run": finished["run_id"], "host": captured["host"],
        "binder_duration_seconds": captured["duration_seconds"],
        "managed_duration_seconds": finished["duration_seconds"],
        "returncode": 0, "retained_inputs_unchanged": True,
        "generated_source_hash_equal": True,
        "complete_child_environment": environment,
        "argument_count": 6, "argument_bytes_with_terminators": 303,
        "temporary_root_bytes": 43,
        "source_argument_bound_for_this_root": main_ali_path+argv_constant+2*(43+36),
        "scope": "one controlled binder process; no historical GPR environment reconstruction or compiler/object claim",
    }
    # The fresh selected configuration fills the configuration premise; it is
    # distinct from the unrecovered historical GPR configuration/exchange.
    config_prefix = "configuration-capture/"
    config_invocation = json.loads(artifacts[config_prefix+"invocation.json"])
    config_result = json.loads(artifacts[config_prefix+"result.json"])
    config = artifacts[config_prefix+"selected.cgpr"]
    assert digest(config) == config_result["configuration"]
    assert config_result["returncode"] == 0 and config_result["retained_inputs_unchanged"] is True
    for name in ("stdout", "stderr"):
        assert digest(artifacts[config_prefix+name]) == config_result[name]
    knowledge_inputs = {p: row for p,row in config_invocation["input_identities"].items()
                        if "/share/gprconfig/" in p}
    assert len(knowledge_inputs) == config_result["knowledge_files"] == 71
    for path, row in knowledge_inputs.items():
        assert digest(artifacts["configuration/"+path.split("/share/gprconfig/")[1]]) == row
    assert set(config_invocation["environment"]) == {"PATH", "LC_ALL", "TMPDIR"}
    assert config_invocation["environment"]["LC_ALL"] == "C"
    assert "--target=x86_64-pc-linux-gnu" in config_invocation["argv"]
    assert any(a.startswith("--config=Ada,16.1,default,") and a.endswith(",GNAT")
               for a in config_invocation["argv"])
    config_events = [json.loads(line) for line in artifacts[config_prefix+"managed/events.jsonl"].splitlines()]
    config_prepared, = [e for e in config_events if e["event"] == "prepared"]
    config_finished, = [e for e in config_events if e["event"] == "finished"]
    assert config_finished["outcome"] == "success"
    config_native, = [e for e in config_events if e["event"] == "phase-end" and e["phase"] == "native-tool"]
    assert config_native["returncode"] == 0
    config_pins = config_prepared["inputs"]["inputs_sha256"]
    script_pin, = [v for p,v in config_pins.items() if p.endswith("/silver-gprconfig-fixed-20261018/run.py")]
    assert script_pin == digest(artifacts[config_prefix+"run.py"])["sha256"]
    for path, row in config_invocation["input_identities"].items():
        assert config_pins[path] == row["sha256"]
    commands = re.findall(rb'executing "([^"]+)" output=', artifacts[config_prefix+"stdout"])
    assert commands and all(c in (b"gcc -dumpmachine", b"gcc -v", b"gcc --version",
                                 b"gcc -mno-cygwin -dumpmachine", b"g++ -dumpmachine",
                                 b"g++ -v", b"c++ -dumpmachine", b"gnatls -v --version") for c in commands)
    compiler_config = re.search(rb"package Compiler is(.*?)end Compiler;", config, re.S)[1]
    binder_config = re.search(rb"package Binder is(.*?)end Binder;", config, re.S)[1]
    leading, = re.findall(rb'for Leading_Required_Switches\s*\("Ada"\) use(.*?);', compiler_config, re.S)
    assert re.findall(rb'"([^"]*)"', leading) == [b"-c", b"-x", b"ada", b"-gnatA", b"Ada"]
    assert b"Trailing_Required_Switches" not in compiler_config
    required, = re.findall(rb'for Required_Switches\s*\("Ada"\) use(.*?);', binder_config, re.S)
    assert re.findall(rb'"([^"]*)"', required) == [b"Ada", b"gnatbind_prefix="]
    compiler_path, = re.findall(rb'for Driver\s*\("Ada"\) use "([^"]+)";', compiler_config)
    assert compiler_path.decode() == str(Path(argv[0]).with_name("gcc"))
    assert len(compiler_path) == 146
    assert b'for Toolchain_Version ("Ada") use "GNAT 16.1";' in config
    assert b"Compiler_Leading_Required_Switches : Name_List_Index := No_Name_List;" in sources["gpr/gpr/src/gpr.ads"]
    assert b"Compiler_Trailing_Required_Switches : Name_List_Index := No_Name_List;" in sources["gpr/gpr/src/gpr.ads"]
    # The ALI filter in gprbind preserves exactly these backend options.
    selected_compile = {}
    for case in ("indexed-cr", "unindexed-proposed"):
        stem = "main~1" if case == "indexed-cr" else "main"
        ali_options = re.findall(rb"^A (.*)$", artifacts[f"cases/{case}/{stem}.ali"], re.M)
        backend = [a for a in ali_options if not a.startswith((b"-I", b"-gnat", b"--RTS="))]
        compiler_args = [b"-c", b"-x", b"ada", b"-gnatA",
                         b"-c", b"-gnatA", b"-gnatWb", b"-gnatiw", b"-gnatws"]+backend+[
                         b"b__main~1.adb", b"-o", b"b__main~1.o"]
        selected_compile[case] = {"backend_options": [a.decode() for a in backend],
                                  "argument_count": len(compiler_args),
                                  "argument_payload_bytes": sum(map(len, compiler_args)),
                                  "argument_bytes_with_terminators": sum(len(a)+1 for a in compiler_args),
                                  "display_line_bytes": len(compiler_path)+sum(len(a)+1 for a in compiler_args)}
    assert selected_compile["indexed-cr"]["argument_count"] == 14
    assert selected_compile["unindexed-proposed"]["argument_count"] == 15
    result["selected_gpr_driver_inputs"] = {
        "configuration_capture_run": config_finished["run_id"],
        "configuration_duration_seconds": config_result["duration_seconds"],
        "managed_duration_seconds": config_finished["duration_seconds"],
        "knowledge_file_count": 71, "metadata_query_count": len(commands),
        "configuration_stderr_bytes": config_result["stderr"]["bytes"],
        "configured_leading_compiler_switches": ["-c", "-x", "ada", "-gnatA"],
        "configured_trailing_compiler_switch_count": 0,
        "configured_consumed_binder_switch": "gnatbind_prefix=",
        "initial_exchange_row_count_bound": 26,
        "initial_exchange_fixed_row_bytes_bound": len(compiler_path),
        "initial_exchange_variable_row_bytes_bound": "T_root + 36",
        "additional_dependency_ali_rows": 0, "project_record_count": 1,
        "project_checkline_bytes": 47,
        "binder_vector_entries": 6, "binder_vector_backing_capacity": 8,
        "compiler_vector_backing_capacity_bound": 16,
        "project_vector_entries_and_capacity": 1,
        "binding_options_vector_entries": 0, "trailing_options_vector_entries": 0,
        "additional_ali_vector_entries": 0,
        "compiler_argument_projection": selected_compile,
        "scope": "selected configuration and source-derived exchange/vector bounds; full GPR process allocation and compiler/object transfer remain separate",
    }
    compiler_support = {k.removeprefix("compiler-support/"): digest(v)
                        for k,v in artifacts.items() if k.startswith("compiler-support/")}
    for case in cases[:3]:
        binder_ali = artifacts[f"cases/{case}/b__main~1.ali"]
        compiler_dependencies = set(re.findall(rb"^D (\S+)", binder_ali, re.M))
        assert compiler_dependencies == {b"b__main~1.ads", b"b__main~1.adb"} | {k.encode() for k in compiler_support}
    result["binder_compiler_retained_dependency_sources"] = compiler_support
    alis = {k.removeprefix("closure/"): v for k, v in artifacts.items() if k.startswith("closure/")}
    units = sorted(u.decode() for v in alis.values() for u in re.findall(rb"^U (\S+)", v, re.M))
    assert len(units) == len(set(units))
    exports = sorted(u[:-2].replace(".", "__") + u[-1].upper() for u in units)
    assert exports == sorted(result["cases"]["indexed-cr"]["version_exports"])
    unit_versions = {}
    for raw in alis.values():
        for name, value in re.findall(rb"^U (\S+)\s+\S+\s+([0-9a-f]{8})", raw, re.M):
            export = name[:-2].replace(b".", b"__") + name[-1:].upper()
            assert export.decode() not in unit_versions
            unit_versions[export.decode()] = value.decode()
    for case in cases:
        assert result["cases"][case]["version_values"] == unit_versions
    runtime_main_signatures = [k for k, v in alis.items() if k != "main~1.ali" and b"[main standard " in v]
    assert runtime_main_signatures == []
    dependencies = {}
    for name, raw in alis.items():
        deps = sorted(set(d.decode() for d in re.findall(rb"^[WYZ] \S+[ \t]+\S+[ \t]+(\S+)", raw, re.M)))
        assert all(d in alis for d in deps), (name, deps)
        dependencies[name] = deps
    reachable, todo = set(), ["main~1.ali", "s-stalib.ali"]
    while todo:
        name = todo.pop()
        if name not in reachable:
            reachable.add(name)
            todo.extend(dependencies[name])
    assert reachable == set(alis)
    result["closure"] = {"ali_count": len(alis), "unit_count": len(units),
                         "raw_bytes": sum(map(len, alis.values())),
                         "units": units, "dependencies": dependencies,
                         "runtime_main_standard_signature_matches": runtime_main_signatures}
    result["signature_hash_max_bytes"] = len("standard__main__") + 10 + 1 + 10
    records = Counter()
    signature_texts, signature_hash_texts, args, dep_versions = [], [], [], defaultdict(set)
    subunit_names = []
    main_proposed = artifacts["cases/unindexed-proposed/main.ali"]
    longest_consumed = 0
    note_source_names = 0
    for name, raw in alis.items():
        for line in raw.split(b"\n"):
            if line.startswith(b"X "):
                break
            if not line:
                continue
            records[line[:1].decode()] += 1
            longest_consumed = max(longest_consumed, len(line))
            if line.startswith(b"A "):
                args.append(line[2:])
            if line.startswith(b"D "):
                fields = line.split()
                dep_versions[fields[1]].add(tuple(fields[2:4]))
                if len(fields) > 4 and not fields[4][:1].isdigit() and not fields[4].endswith((b"%b", b"%s")):
                    assert re.fullmatch(rb"[a-z_]+(?:\.[a-z_]+)*", fields[4])
                    subunit_names.append(fields[4])
            if line.startswith(b"N "):
                note_source_names += bool(re.match(rb"N .[0-9]+:[0-9]+:", line))
            if line.startswith(b"G c "):
                assert line.startswith(b"G c Z ")
                matches = re.findall(rb"\[([^\]]*)\]", line)
                assert len(matches) == 1
                sig = matches[0]
                signature_texts.append(sig)
                n, scope, ln, col, loc = sig.split()
                signature_hash_texts.append(scope+b"__"+n+b"__"+ln+b"_"+col+(b"__"+loc if loc != b"none" else b""))
            elif line.startswith(b"G "):
                assert line == b"G a e"  # no invocation relation record
            assert not line.startswith(b"R ")  # no No_Dependence entries
    assert len(signature_texts) == len(set(signature_texts)) == 900
    assert records["I"] == records["S"] == 0
    result["generation_buffers"]["interrupt_and_dispatch_table_slots_each"] = 100
    result["generation_buffers"]["interrupt_and_dispatch_setting_records"] = 0
    assert all(len(values) == 1 for values in dep_versions.values())
    assert not re.search(rb"^X ", main_proposed, re.M)
    assert b"-gnatx\n" in main_proposed and b"-Wno-free-nonheap-object\n" in main_proposed
    original_signature = re.search(rb"\[main standard (\d+) (\d+) none\]", main_proposed)
    assert original_signature
    # Only the eight-byte index switch plus prefix/LF, at most two casing
    # flags, and decimal width of the two signature coordinates can grow.
    coordinate_delta = 20-len(original_signature[1])-len(original_signature[2])
    main_proposed_bound = len(main_proposed)+len(b"A -gnateI1\n")+6+coordinate_delta
    assert main_proposed_bound == 378
    # Each selected name-producing parser site contributes at most one new
    # entry. Charge the optional source filename even for all seven notes,
    # although these retained notes use their unit's source name directly.
    parser_name_events = (2*records["U"] + 3*(records["W"]+records["Y"]+records["Z"])
                          + 3*records["D"] + 3*len(signature_texts)
                          + records["L"] + records["N"])
    assert longest_consumed == 108 and note_source_names == 0
    preset_names = re.findall(rb"^\s*Name_(\w+)\s+: constant Name_Id := N \+ \$;",
                              sources["gcc/ada/snames.ads-tmpl"], re.M)
    assert len(preset_names) == 955 and len(subunit_names) == 6
    # XSnamesT's leading-u/UP_/Op_ transformations never lengthen these names;
    # charging all entries also includes the single letters Namet already owns.
    preset_character_bound = 512+sum(len(n)+1 for n in preset_names)
    namet_entry_bound = (256+len(preset_names)+parser_name_events+5
                         +2*len(alis)+1+1+2+4+2*records["D"]+2*len(subunit_names))
    assert namet_entry_bound == 8282
    max_ali_path = max(len(paths[0])+2,
                       len(paths[3])+max(len(k) for k in alis if k != "main~1.ali"))
    system_source_path = len(paths[3])-len(b"adalib/")+len(b"adainclude/system.ads")
    main_ali_path = len(paths[0])+2
    system_source = artifacts["compiler-support/system.ads"]
    assert not re.search(rb"^\s*(?:Run_Time_Name|Executable_Extension)\s*:", system_source, re.M)
    assert b"pragma Restrictions" not in system_source
    # Character totals are an upper bound on calls, before deduplication.
    # Keep the normalized temporary-root length symbolic, rather than assuming
    # no path names were allocated or selecting a new installation-path cap.
    namet_char_constant = (
        preset_character_bound+parser_name_events*(longest_consumed+1)
        +2*records["D"]*(longest_consumed+1)
        +2*len(subunit_names)*(longest_consumed+3)
        +len(b"main~1.ali\0s-stalib.ali\0system.ads\0")
        +4*len(b"b__main~1.ads\0")
        +system_source_path+1+2*len(alis)*(max_ali_path+1)
        +2*36+main_ali_path+21)
    assert namet_char_constant == 792737
    unit_record = re.search(rb"type Unit_Record is record\n(.*?)   end record;",
                            sources["gcc/ada/ali.ads"], re.S)[1]
    unit_fields = re.findall(rb"^      ([A-Za-z_]+) : ([A-Za-z_]+);", unit_record, re.M)
    assert len(unit_fields) == 40
    assert sum(kind == b"Version_String" for _, kind in unit_fields) == 1
    tables = {
        "ALIs": [records["V"], 500, 200], "Units": [records["U"], 100, 200],
        "Withs": [records["W"]+records["Y"]+records["Z"], 5000, 200],
        "Args_baseline": [records["A"], 1000, 100], "Args_proposed": [records["A"]+2, 1000, 100],
        "Sdep": [records["D"], 5000, 200], "Source": [len(dep_versions), 1000, 200],
        "Invocation_Constructs": [900, 2500, 200], "Invocation_Signatures": [900, 2500, 200],
        "Invocation_Relations": [0, 2500, 200], "Linker_Options_including_dummy": [records["L"]+1, 200, 400],
        "Notes_including_dummy": [records["N"]+1, 200, 400], "No_Deps": [0, 200, 400],
    }
    table_rows = {}
    for name, (demand, initial, growth) in tables.items():
        capacities = [initial]
        while capacities[-1] < demand:
            previous = capacities[-1]
            capacities.append(max(previous*(100+growth)//100, previous+10))
        table_rows[name] = {"demand": demand, "capacities": capacities}
    result["ali_parser"] = {
        "record_counts": dict(sorted(records.items())), "tables": table_rows,
        "max_consumed_line_bytes_without_lf": longest_consumed,
        "max_fixed_ali_bytes": max(len(v) for k,v in alis.items() if k != "main~1.ali"),
        "distinct_dependency_names": len(dep_versions), "dependency_mismatch_count": 0,
        "signature_count": 900, "invocation_relation_count": 0, "elaboration_root_count": 0,
        "max_retained_signature_hash_bytes": max(map(len, signature_hash_texts)),
        "signature_map_bucket_capacities": [500, 1000], "signature_map_peak_bucket_slots": 1500,
        "signature_map_node_slots": 900,
        "argument_payload_bytes_baseline": sum(map(len,args)),
        "argument_payload_bytes_proposed": sum(map(len,args))+len(b"-gnatx")+len(b"-Wno-free-nonheap-object"),
        "largest_argument_payload_bytes": max(map(len,args)),
        "proposed_indexed_main_ali_bound": main_proposed_bound,
        "proposed_cumulative_ali_raw_bytes_bound": sum(map(len,alis.values()))-len(alis["main~1.ali"])+main_proposed_bound,
        "parser_name_entry_event_bound": parser_name_events,
        "parser_name_character_contribution_bound": parser_name_events*(longest_consumed+1),
        "parser_name_payload_bound": longest_consumed,
        "notes_with_explicit_source_name": note_source_names,
        "unit_record_field_count": len(unit_fields), "unit_record_component_bound": 320,
        "unit_table_realloc_old_plus_new_bytes_bound": 400*320,
        "signature_node_component_bound": 64,
        "signature_nodes_plus_coexisting_buckets_bytes_bound": (900+1500)*64,
        "mapping_record_bound": 1, "mapping_name_entry_event_bound": 5,
        "mapping_raw_bytes_excluding_ali_path_bound": len(b"main%b\nmain~1.ali\n\n"),
        "mapping_name_character_bytes_excluding_paths_bound": len(b"main%b\0main~1.ali\0\0\0\0"),
        "mapping_filename_occurrences_in_name_character_bound": 2,
        "gpr_temp_path_bytes_excluding_normalized_root_bound": len(b"/GPR.")+10+len(b"/GNAT-TEMP-000000.TMP"),
        "namet_total_entry_bound": namet_entry_bound,
        "namet_entry_table_capacities": [6000, 12000],
        "namet_entry_table_old_plus_new_bytes_bound": (6000+12000)*16,
        "namet_preset_entry_bound_including_single_characters": 256+len(preset_names),
        "namet_preset_character_bound_including_single_characters": preset_character_bound,
        "namet_preset_payload_bound": max(map(len,preset_names)),
        "namet_subunit_record_count": len(subunit_names),
        "namet_character_bound_excluding_normalized_temp_root_bytes": namet_char_constant,
        "namet_retained_installation_max_ali_path_bytes": max_ali_path,
        "namet_retained_installation_system_source_path_bytes": system_source_path,
        "namet_character_table_capacities_at_tmp_root": [50000, 100000, 200000, 400000, 800000],
        "namet_normalized_temp_root_occurrences_in_character_bound": 2,
        "namet_character_bound_at_tmp_root": namet_char_constant+2*len(b"/tmp"),
        "namet_character_table_old_plus_new_bytes_at_tmp_root": 400000+800000,
    }
    return result


def main():
    manifest = json.loads((ROOT / "manifest.json").read_text())
    absent = manifest["optional_default_search_files"]
    assert set(absent) == {"ada_source_path", "ada_object_path"}
    for name, row in absent.items():
        assert row["path"].endswith("/16.1.0/"+name) and row["exists_at_collection"] is False
    for name, record in manifest["archives"].items():
        raw = (ROOT / name).read_bytes()
        assert digest(raw) == record["archive"]
        members = read_archive(name)
        assert set(members) == set(record["members"])
        for member, expected in record["members"].items():
            assert digest(members[member]) == {k: expected[k] for k in ("bytes", "sha256")}
    result = analyze(read_archive("artifacts.tar.gz"), read_archive("sources.tar.gz"))
    assert result == json.loads((ROOT / "result.json").read_text())
    print("Retained source pins, null binder projection comparisons, ALI closure and ELF inventories agree.")
    print(json.dumps({"closure": {k: v for k, v in result["closure"].items() if k in ("ali_count", "unit_count", "raw_bytes")},
                      "indexed_object": {k: v for k, v in result["cases"]["indexed-cr"]["object"].items()
                                         if k.endswith("_count") or k.endswith("_bytes")}}, sort_keys=True))


if __name__ == "__main__":
    main()
