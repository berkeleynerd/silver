#!/usr/bin/env python3
"""Check the frozen source and bounded ELF projections, without running a target.

This checks identities, correspondence and certificate structure. It does not
machine-prove the source effect argument or the external behavior relation.
"""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import struct
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PREFIX = "ocaml-8eb41f72ded84df884c3671734c947f612091f84/"


def digest(data):
    return hashlib.sha256(data).hexdigest()


def read_json(path):
    return json.loads(path.read_text())


def serialized(value):
    return json.dumps(value, indent=2, ensure_ascii=False) + "\n"


def lifecycle_projection(elf, data):
    sections = {s["name"]: (i, s) for i, s in enumerate(elf.sections)}
    imports = sorted({x["name"] for i, table in elf.tables.items()
                      if elf.sections[i]["type"] == 11 for x in table
                      if x["name"] and not x["shndx"]})
    dynamic = []
    if ".dynamic" in sections:
        _, sec = sections[".dynamic"]
        strings = elf.section_bytes(sec["link"])
        tags = {12: "DT_INIT", 13: "DT_FINI", 25: "DT_INIT_ARRAY",
                26: "DT_FINI_ARRAY", 27: "DT_INIT_ARRAYSZ",
                28: "DT_FINI_ARRAYSZ", 32: "DT_PREINIT_ARRAY",
                33: "DT_PREINIT_ARRAYSZ"}
        for off in range(sec["offset"], sec["offset"] + sec["size"],
                         sec["entsize"]):
            tag, val = struct.unpack_from("<qQ", data, off)
            if tag == 0:
                break
            if tag == 1:
                dynamic.append({"tag": "DT_NEEDED",
                                "value": elf.string(strings, val)})
            if tag in tags:
                names = sorted(n for n, s in elf.symbols.items()
                               if s["value"] == val) if tag in (12, 13) else []
                dynamic.append({"tag": tags[tag], "value": val,
                                "hex": hex(val), "exact_symbol_names": names})
    relocs = {}
    for sec in elf.sections:
        if sec["type"] != 4:
            continue
        for off in range(sec["offset"], sec["offset"] + sec["size"],
                         sec["entsize"]):
            place, info, addend = struct.unpack_from("<QQq", data, off)
            sym = elf.tables[sec["link"]][info >> 32]
            relocs[place] = {"kind": info & 0xffffffff, "symbol": sym["name"],
                             "symbol_value": sym["value"], "addend": addend}
    arrays = []
    for name in (".preinit_array", ".init_array", ".fini_array"):
        if name not in sections:
            continue
        _, sec = sections[name]
        assert sec["size"] % 8 == 0
        for off in range(0, sec["size"], 8):
            raw = struct.unpack_from("<Q", data, sec["offset"] + off)[0]
            reloc = relocs.get(sec["addr"] + off)
            value = reloc["addend"] if reloc and reloc["kind"] == 8 else raw
            arrays.append({"section": name, "cell": hex(sec["addr"] + off),
                           "raw_value": hex(raw), "relocation": reloc,
                           "effective_relative_value": hex(value),
                           "exact_symbol_names": sorted(
                               n for n, s in elf.symbols.items()
                               if s["value"] == value)})
    files = sorted({x["name"] for table in elf.tables.values() for x in table
                    if (x["info"] & 15) == 4 and x["name"]})
    lifecycle = [x for x in imports if any(s in x for s in
                  ("atexit", "on_exit", "cxa", "dlsym", "dlopen",
                   "dlclose", "atfork"))]
    return {"dynamic": dynamic, "lifecycle_imports": lifecycle,
            "all_undefined_dynamic_symbols": imports, "arrays": arrays,
            "file_symbols": files}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write-derived", action="store_true",
                        help="Write source excerpt/plan projections and result")
    args = parser.parse_args()
    started = time.monotonic()
    inputs = read_json(HERE / "inputs.json")
    blobs = {}
    for key, spec in inputs["inputs"].items():
        data = (ROOT / spec["path"]).read_bytes()
        assert len(data) == spec["size"] and digest(data) == spec["sha256"], key
        blobs[key] = data
    archives = {}
    for key in ("ocaml", "why", "capture", "callback_native", "sexplib0",
                "sexplib", "parsexp"):
        archives[key] = tarfile.open(ROOT / inputs["inputs"][key]["path"])

    witnesses = []
    for row in read_json(HERE / "witness-plan.json")["witnesses"]:
        data = (archives[row["input"]].extractfile(row["member"]).read()
                if row["member"] else blobs[row["input"]])
        lines = data.decode().splitlines(keepends=True)
        excerpts = []
        for first, last in row["ranges"]:
            assert 1 <= first <= last <= len(lines), row["id"]
            text = "".join(lines[first - 1:last])
            excerpts.append({"first_line": first, "last_line": last,
                             "sha256": digest(text.encode()), "text": text})
        witnesses.append({"id": row["id"], "input": row["input"],
                          "member": row["member"], "source_sha256": digest(data),
                          "source_lines": len(lines), "excerpts": excerpts})
    witness_result = {"schema": 1,
                      "scope": "Source identity/excerpt witnesses; not a semantic proof or native closure census.",
                      "witnesses": witnesses}

    plan_data = archives["capture"].extractfile("plan.json").read()
    summary_name = "input_is_valid/capture/summary.json"
    summary_data = archives["capture"].extractfile(summary_name).read()
    plan, summary = json.loads(plan_data), json.loads(summary_data)
    env = plan["inputs"][0]["environment"]
    assert env["OCAMLRUNPARAM"] == "s=256M,h=16M,M=1000"
    plan_result = {"input": "capture", "plan_member": "plan.json",
                   "plan_sha256": digest(plan_data), "summary_member": summary_name,
                   "summary_sha256": digest(summary_data), "environment": env,
                   "scope": "Retained launch input; source-prefix derivation, not a live selector observation."}

    reader_path = ROOT / inputs["inputs"]["elf_reader"]["path"]
    spec = importlib.util.spec_from_file_location("retained_elf_reader", reader_path)
    reader = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(reader)
    elf_packet = read_json(HERE / "elf-lifecycle.json")
    assert elf_packet["reader_sha256"] == digest(blobs["elf_reader"])
    elf_by_path = {}
    for key in inputs["images"]:
        image = inputs["inputs"][key]
        path = image["path"]
        assert summary["mapped_files"][path] == {
            "bytes": image["size"], "sha256": image["sha256"]}
        elf_by_path[path] = reader.ELF(blobs[key])
    for row in elf_packet["images"]:
        image_key = next(k for k in inputs["images"]
                         if inputs["inputs"][k]["path"] == row["path"])
        assert row["sha256"] == digest(blobs[image_key])
        assert row["size"] == len(blobs[image_key])
        actual = lifecycle_projection(elf_by_path[row["path"]], blobs[image_key])
        for key, value in actual.items():
            assert row[key] == value, (row["name"], key)
        assert len(row["arrays"]) == 2
        assert row["arrays"][0]["exact_symbol_names"] == ["frame_dummy"]
        assert row["arrays"][1]["exact_symbol_names"] == ["__do_global_dtors_aux"]
        assert not set(row["all_undefined_dynamic_symbols"]) & {
            "atexit", "on_exit", "at_quick_exit", "__cxa_atexit"}
    weak = read_json(HERE / "crt-weak-bindings.json")
    assert len(weak["images"]) == 7
    for row in weak["images"]:
        elf = elf_by_path[row["path"]]
        actual = [x for i, table in elf.tables.items()
                  if elf.sections[i]["type"] == 11 for x in table
                  if x["name"] in weak["names"]]
        assert row["weak_interface_symbols"] == actual
        assert all(x["shndx"] == 0 and x["info"] >> 4 == 2 for x in actual)

    family = read_json(HERE / "source-family.json")
    main_files = elf_packet["images"][0]["file_symbols"]
    assert [r["file_symbol"] for r in family["file_symbol_rows"]] == main_files
    for row in family["file_symbol_rows"]:
        for member in row.get("source_members", []):
            assert digest(archives["ocaml"].extractfile(member["member"]).read()) == member["sha256"]
        if "source_file" in row:
            assert digest((ROOT / row["source_file"]).read_bytes()) == row["source_sha256"]
    for member in family["generated_startup_members"]:
        assert digest(archives["ocaml"].extractfile(member["member"]).read()) == member["sha256"]
    names = [m.name for m in archives["ocaml"].getmembers() if m.isfile()
             and any(m.name.startswith(PREFIX + s) for s in
                     ("runtime/", "otherlibs/unix/", "otherlibs/systhreads/"))
             and m.name.endswith((".c", ".h", ".S"))]
    assert len(names) == family["source_scope"]["c_header_assembly_members"] == 233
    lifetime_pattern = re.compile(r"\b(?:atexit|on_exit|at_quick_exit|__cxa_atexit|__attribute__\s*\(\(\s*(?:constructor|destructor))")
    selector_pattern = re.compile(r"\b(?:caml_(?:major_slice_(?:begin|end)_hook|minor_gc_(?:begin|end)_hook|major_gc_hook|scan_roots_hook|memprof_th_ctx_iter_hook|enter_blocking_section_hook|leave_blocking_section_hook|channel_mutex_(?:free|lock|unlock|unlock_exn)|sigmask_hook|fatal_error_hook|cleanup_on_exit|natdynlink_hook)|prev_scan_roots_hook)\b")
    lifetime, selectors = [], []
    source_rows = [("member", n, archives["ocaml"].extractfile(n).read()) for n in names]
    source_rows.append(("file", inputs["inputs"]["zarith_c"]["path"], blobs["zarith_c"]))
    for kind, path, data in source_rows:
        for number, line in enumerate(data.decode().splitlines(), 1):
            item = {kind: path, "line": number, "text": line}
            if lifetime_pattern.search(line):
                lifetime.append(item)
            if selector_pattern.search(line):
                selectors.append(item)
    assert lifetime == family["lifetime_registration_syntax"]
    assert selectors == family["native_selector_syntax"]

    native = json.load(archives["callback_native"].extractfile("native-audit.json"))
    thread_entry = [r for r in native["code_references"]
                    if r.get("function") == "caml_program"
                    and "<camlThread__entry>" in r["instruction"]]
    assert len(thread_entry) == 1 and thread_entry[0]["address"] == 0x526734

    interface = read_json(HERE / "interface-summary.json")
    config = read_json(HERE / "configuration.json")
    native_interface = read_json(HERE / "native-interface.json")
    witness_ids = {w["id"] for w in witnesses}
    contract_ids = {c["id"] for c in interface["contracts"]}
    for row in interface["contracts"] + interface["roots"]:
        assert set(row["witnesses"]) <= witness_ids, row["id"]
        assert set(row.get("contracts", [])) <= contract_ids, row["id"]
        assert set(row.get("successors", [])) <= contract_ids, row["id"]
    assert len(config["selectors"]) == config["selector_count"] == 17
    assert len({r["symbol"] for r in config["selectors"]}) == 17
    for row in config["selectors"]:
        assert set(row["witnesses"]) <= witness_ids
        assert row["value_observed_in_this_packet"] is False
    assert native_interface["N_native"] == 0
    assert native_interface["binary_refinement_proved"] is False
    assert native_interface["source_semantics_machine_checked"] is False
    assert native_interface["new_capture_required"] is False
    assert native_interface["companion_commit"] == inputs["companion"]["commit"]
    assert inputs["companion"]["review_status"] == "accepted; no material findings"
    composition = read_json(HERE / "composition.json")
    total = (composition["initial_counter"]
             + composition["first_fold_registrations"]
             + composition["maximum_serial_SIGINT_attempts"]
             * composition["binder_registrations_per_attempt"]
             + composition["whole_interval_reporting_allowance"]
             + native_interface["N_native"])
    assert total == composition["endpoint_upper"] == 89493
    assert composition["N_native"] == native_interface["N_native"] == 0
    assert composition["counter_limit"] == (1 << 62) - 1
    assert total < composition["counter_limit"]
    assert composition["headroom"] == composition["counter_limit"] - total
    assert (total - composition["initial_counter"]
            == composition["total_registrations_upper"] == 28997)
    assert composition["pid"] == native_interface["pid"] == 97103
    assert composition["run_id"] == native_interface["run_id"]
    assert composition["companion_source_commit"] == inputs["companion"]["commit"]
    assert composition["companion_review_commit"] == inputs["companion"]["review_commit"]
    assert all(value is False for value in composition["other_capacity_claims"].values())

    for name, value in [("source-witnesses.json", witness_result),
                        ("retained-plan.json", plan_result)]:
        path = HERE / name
        if args.write_derived:
            path.write_text(serialized(value))
        else:
            assert read_json(path) == value, name
    for archive in archives.values():
        archive.close()
    result = {"status": "pass", "input_files": len(blobs),
              "source_witness_files": len(witnesses),
              "source_excerpt_ranges": sum(len(w["excerpts"]) for w in witnesses),
              "source_family_members": 233, "additional_source_family": "Zarith",
              "ELF_lifecycle_images": 3, "CRT_provider_images": 7,
              "source_file_label_rows": len(main_files),
              "source_selector_occurrences": len(selectors),
              "source_lifetime_occurrences": len(lifetime),
              "source_root_rows": len(interface["roots"]),
              "source_contracts": len(contract_ids), "source_selectors": 17,
              "N_native": 0, "N_native_basis": "inspected source argument under named external behavior relation; not checker-proved semantics",
              "composed_endpoint_upper": total,
              "below_tagged_counter_limit": True,
              "new_native_runs": 0, "new_disassembly_runs": 0,
              "old_expensive_checks_replayed": 0}
    if args.write_derived:
        (HERE / "result.json").write_text(serialized(result))
    else:
        assert read_json(HERE / "result.json") == result
    print(serialized({**result, "check_elapsed_seconds": time.monotonic() - started}), end="")


if __name__ == "__main__":
    main()
