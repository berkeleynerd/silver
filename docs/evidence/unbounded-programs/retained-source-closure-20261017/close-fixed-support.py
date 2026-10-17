#!/usr/bin/env python3
"""Inspect selected support specifications and retained binder inputs only."""

import argparse
import hashlib
import json
from pathlib import Path
import re


def digest(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def code_only(data):
    text = data.decode("latin-1")
    return re.sub(r'--[^\n]*|"(?:[^"]|"")*"',
                  lambda m: "".join("\n" if c == "\n" else " " for c in m[0]), text)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--installation", type=Path, required=True)
    parser.add_argument("--gcc", type=Path, required=True)
    parser.add_argument("--gpr-source", type=Path, required=True)
    args = parser.parse_args()
    root = args.installation
    runtime = root / ".tools/linux-x86_64/alire/toolchains/gnat_native_16.1.0_9f74f58a/lib/gcc/x86_64-pc-linux-gnu/16.1.0"
    include, adalib = runtime / "adainclude", runtime / "adalib"
    workspace = root / ".silver/linux-x86_64/program-Z0j19G/obj"
    unit_pattern = re.compile(r"^(?:private\s+)?(?:package|procedure|function)\s+([\w.]+)", re.M | re.I)
    units = {}
    for path in sorted(include.glob("*.ads")):
        match = unit_pattern.search(code_only(path.read_bytes()))
        if match:
            name = match[1].lower()
            assert name not in units, name
            units[name] = path
    seeds = ["ada.text_io", "ada.command_line", "interfaces.c", "system",
             "system.standard_library", "system.secondary_stack", "system.put_images",
             "system.img_int", "system.compare_array_unsigned_8", "system.compare_array_signed_8",
             "ada.tags", "ada.exceptions", "system.soft_links", "system.stack_checking",
             "system.exception_table", "ada.assertions", "system.assertions"]
    seeds += [f"system.concat_{i}" for i in range(2, 10)]
    selected = {}
    todo = seeds[:]
    while todo:
        name = todo.pop()
        if name in selected:
            continue
        path = units[name]
        raw = path.read_bytes()
        code = code_only(raw)
        # Context clauses precede the outer unit declaration. Do not mistake
        # an aspect's "with Preelaborable_Initialization" for a context clause.
        context = code[:unit_pattern.search(code).start()]
        deps = []
        for m in re.finditer(r"^\s*(?:(?:limited|private)\s+)*with\s+([A-Za-z0-9_.,\s]+);",
                             context, re.M | re.I):
            for dep in m[1].split(","):
                dep = "".join(dep.split()).lower()
                assert dep in units, (path.name, dep)
                deps.append(dep)
        if "." in name:
            deps.append(name.rsplit(".", 1)[0])
        instances = []
        for m in re.finditer(r"\b(package|procedure|function)\s+([\w.]+)\s+is\s+new\s+([\w.]+)", code, re.I):
            instances.append({"line": code.count("\n", 0, m.start()) + 1,
                              "kind": m[1], "name": m[2], "generic": m[3]})
        occurrences = {}
        for key, pattern in {
            "inline_always": r"\bInline_Always\b", "null_procedure": r"\bis\s+null\b",
            "classwide_contract": r"\b(?:Pre|Post)'Class\b",
            "source_name_override": r"\bSource_File_Name(?:_Project)?\b",
        }.items():
            occurrences[key] = [code.count("\n", 0, m.start()) + 1
                                for m in re.finditer(pattern, code, re.I)]
        selected[name] = {"file": path.name, **digest(raw), "dependencies": sorted(set(deps)),
                          "generic_instances": instances, "occurrences": occurrences}
        todo.extend(deps)
    binder_specification_seeds = ["system", "system.parameters", "system.secondary_stack", "ada.exceptions"]
    binder_specifications, todo = set(), binder_specification_seeds[:]
    while todo:
        name = todo.pop()
        if name in binder_specifications:
            continue
        binder_specifications.add(name)
        todo.extend(selected[name]["dependencies"])
    ali_seeds = ["main.ali", "silver_io.ali", "silver_arguments.ali", "silver_runtime.ali", "silver_output_libc.ali"]
    ali_seeds += [f"s-conca{i}.ali" for i in range(2, 10)]
    ali_seeds += ["s-carun8.ali", "s-carsi8.ali", "s-imgint.ali"]
    alis, todo = {}, ali_seeds[:]
    while todo:
        name = todo.pop()
        if name in alis:
            continue
        path = workspace / name
        if not path.exists():
            path = adalib / name
        raw = path.read_bytes()
        text = raw.decode("latin-1")
        # Horizontal whitespace only: a W generic line can have no ALI name.
        deps = re.findall(r"^[WYZ] \S+[ \t]+\S+[ \t]+(\S+)", text, re.M)
        for dep in deps:
            assert dep.endswith(".ali"), (name, dep)
        alis[name] = {"path": str(path), **digest(raw), "dependencies": sorted(set(deps)),
                      "units": re.findall(r"^U (\S+)", text, re.M),
                      "linker_records": re.findall(r"^L ([^\n]*)", text, re.M),
                      "interrupt_or_dispatch_records": re.findall(r"^[IS] ([^\n]*)", text, re.M)}
        todo.extend(deps)
    binder_units = sorted(set(u for x in alis.values() for u in x["units"]))
    bindgen = (args.gcc / "bindgen.adb").read_bytes()
    source_lines = bindgen.decode("latin-1").split("\n")
    ranges = {
        "Gen_Adafinal": (469, 531), "Gen_Adainit": (537, 1211),
        "Gen_Main": (1974, 2231), "Gen_Output_File_Ada": (2512, 2944),
        "Gen_Elab_Calls": (1515, 1697), "Gen_Elab_Externals": (1703, 1744),
        "Gen_Elab_Order": (1750, 1763), "Gen_Finalize_Library": (1769, 1968),
        "Gen_Versions": (3039, 3099),
    }
    writers = {}
    for name, (first, last) in ranges.items():
        text = code_only("\n".join(source_lines[first - 1:last]).encode("latin-1"))
        sites = [first + text.count("\n", 0, m.start()) for m in re.finditer(
            r"\bWBI\s*\(|\bWrite_Statement_Buffer\b(?:\s*\(|\s*;)", text, re.I)]
        writers[name] = {"first_line": first, "last_line": last, "writer_lines": sites}
    raw_binder = {name: digest((workspace / name).read_bytes())
                  for name in ("b__main.ads", "b__main.adb")}
    n = len(binder_units)
    # These coefficients are the manually reviewed control-flow transfer in
    # the report, not conclusions of the lexical writer inventory by itself.
    path_bytes, directories, linker_records = 4096, 3, 1
    bound = (1001 * (349 + 19 * n) + 1009 * linker_records
             + (path_bytes + 9) * n + (path_bytes + 11) * directories)
    inputs = ["bindgen.adb", "osint-b.adb", "osint.adb", "gnatvsn.ads", "lib-writ.ads", "lib-load.adb", "sem.adb",
              "sem_ch12.adb", "sem_ch7.adb", "sem_ch6.adb", "inline.adb", "sem_prag.adb", "freeze.adb",
              "contracts.adb", "exp_ch4.adb", "exp_ch6.adb", "exp_imgv.adb", "rtsfind.ads"]
    result = {
        "scope": "Selected source/retained-ALI closure, conditional on caller seed completeness and documented invocation. No compiler or proof run.",
        "specification_seeds": seeds, "selected_specifications": selected,
        "selected_specification_count": len(selected),
        "selected_specification_aligned_charge": sum(4096 * ((x["bytes"] + 4096) // 4096)
                                                     for x in selected.values()),
        "generic_instance_count": sum(len(x["generic_instances"]) for x in selected.values()),
        "selected_generic_bodies": {"s-imagei.adb": digest((include / "s-imagei.adb").read_bytes())},
        "binder_specification_seeds": binder_specification_seeds,
        "binder_specification_closure": sorted(binder_specifications),
        "binder_ali_seeds": ali_seeds, "binder_ali_closure": alis,
        "binder_units": binder_units, "binder_unit_count": n,
        "max_encoded_unit_name_length": max(map(len, binder_units)),
        "max_external_unit_prefix_length": max(len(u.split("%")[0].replace(".", "__")) for u in binder_units),
        "binder_source_writer_sites": writers,
        "binder_transfer": {"nonpath_fixed_writer_bound": 349, "nonpath_per_unit_writer_bound": 19,
                            "path_byte_bound": path_bytes, "object_directory_count_bound": directories,
                            "linker_record_count_bound": linker_records, "linker_comment_byte_bound": 1009,
                            "combined_raw_source_byte_bound": bound,
                            "combined_aligned_source_bound": bound + 8192},
        "retained_binder_source": raw_binder,
        "gcc_source_inputs": {p: digest((args.gcc / p).read_bytes()) for p in inputs},
        "gpr_source_inputs": {p: digest((args.gpr_source / p).read_bytes()) for p in ["src/gprbind.adb", "src/gprbuild-post_compile.adb"]},
    }
    print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
