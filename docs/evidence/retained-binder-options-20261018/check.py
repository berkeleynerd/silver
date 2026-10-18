"""Replay binder-option objects and every counter write without native tools."""
import argparse
from collections import Counter, defaultdict
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile

ROOT = Path(__file__).resolve().parent


def digest(raw):
    return {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}


def load_archive(name, manifest):
    path = ROOT / name
    row = manifest["archives"][name]
    assert digest(path.read_bytes()) == {k: row[k] for k in ("bytes", "sha256")}
    with tarfile.open(path) as archive:
        assert sorted(archive.getnames()) == sorted(r["path"] for r in row["members"])
        result = {}
        for member in row["members"]:
            raw = archive.extractfile(member["path"]).read()
            assert digest(raw) == {k: member[k] for k in ("bytes", "sha256")}
            result[member["path"]] = raw
        return result


def replay(tag, art):
    read = lambda name: json.loads(art[tag + "/" + name])
    plan, run = read("invocation.json"), read("capture/result.json")
    summary, mapping = read("capture/counter-summary.json"), read("executable-map.json")
    guards = read("guard-map.json")
    assert run["returncode"] == summary["frontend_exit_code"] == 0
    assert run["retained_inputs_unchanged"] and summary["completed"]
    assert not run["timed_out"] and not summary["failures"] and not summary["new_threads"]
    assert not summary["mark_calls"] and not summary["value_expr_insert_calls"]
    assert mapping["ELF_type"] == 2
    assert mapping["binary_sha256"] == guards["binary_sha256"] == plan["gnat1_sha256"] == run["gnat1_sha256"]
    for guard in guards["symbols"]:
        assert digest(art[tag + "/" + guard["file"]]) == {k: guard[k] for k in ("bytes", "sha256")}
        assert guard["address"].encode() in art[tag + "/counters.py"]
    assert {g["address"] for g in guards["symbols"]} == {"0xda5780", "0xf80190", "0x16b12e0", "0x16a2e00"}
    allowed = defaultdict(set)
    for site in mapping["sites"]:
        assert int(site["address"], 16) + len(bytes.fromhex(site["instruction_bytes"])) == int(site["post_instruction_pc"], 16)
        allowed[site["counter"]].add(site["post_instruction_pc"])
    expected_specs = {
        "ggc_bytes": {"address": 0x3d1a868, "width": 8, "signed": False, "initial": 0},
        "decl_uid": {"address": 0x3d2354c, "width": 4, "signed": True, "initial": 0},
        "type_uid": {"address": 0x3619d30, "width": 4, "signed": False, "initial": 1},
        "debug_decl_uid": {"address": 0x3d23548, "width": 4, "signed": True, "initial": 0}}
    assert summary["specs"] == expected_specs
    state = {n: {"initial": s["initial"], "current": s["initial"], "peak": s["initial"],
                 "minimum": s["initial"], "events": 0, "positive_sum": 0, "negative_sum": 0,
                 "positive_events": 0, "negative_events": 0, "largest_increment": 0}
             for n, s in expected_specs.items()}
    phases = summary["phases"]
    assert [p["phase"] for p in phases] == ["frontend_exec_before_initialization", "gigi_entry", "builtins_entry", "builtins_return", "before_binder_translation"]
    assert [p["pc"] for p in phases[1:]] == ["0x9a8520", "0x97c6b0", "0x9a909e", "0x9a9419"]
    assert all(p["threads"] == 1 for p in phases)

    def phase_check(i):
        assert phases[i]["values"] == {n: d["current"] for n, d in state.items()}
        assert phases[i]["events"] == {n: d["events"] for n, d in state.items()}

    phase_check(0)
    phase_index, histogram, sites = 1, Counter(), Counter()
    raw_events = art[tag + "/capture/counter-events.jsonl"]
    events = [json.loads(line) for line in raw_events.splitlines()]
    for index, event in enumerate(events, 1):
        name, old, new, delta = (event[k] for k in ("counter", "old", "new", "delta"))
        data = state[name]
        assert old == data["current"] and delta == new - old and event["pc"] in allowed[name]
        if name == "ggc_bytes":
            assert delta > 0 and 0 <= new < 2**64
            histogram[delta] += 1
        elif name == "decl_uid":
            assert delta == 1 and 0 <= new < 2**31
        elif name == "type_uid":
            assert delta in (-1, 1) and 1 <= new < 2**32
        else:
            assert name == "debug_decl_uid" and delta == -1 and -2**31 <= new < 0
        sites[(name, event["pc"])] += 1
        data["current"], data["events"] = new, data["events"] + 1
        data["peak"], data["minimum"] = max(data["peak"], new), min(data["minimum"], new)
        data["positive_sum"] += max(delta, 0)
        data["negative_sum"] += max(-delta, 0)
        data["positive_events"] += int(delta > 0)
        data["negative_events"] += int(delta < 0)
        data["largest_increment"] = max(data["largest_increment"], delta)
        if phase_index < len(phases) and index == sum(phases[phase_index]["events"].values()):
            phase_check(phase_index)
            phase_index += 1
    assert phase_index == len(phases) and state == summary["counters"]
    assert art[tag + "/capture/watchpoints.txt"].count(b"hw watchpoint") == 4
    assert all(c["pc"] == "0xda5780" and c["mode"] == 0 and 0 <= c["cumulative_ggc_bytes"] <= state["ggc_bytes"]["positive_sum"] for c in summary["collection_calls"])
    frontend = read("capture/frontend-exec.json")
    assert len(plan["cwd"]) == 113 and plan["source_fullname_bytes"] == 127
    assert len(plan["environment"]["TMPDIR"]) == 52
    assert set(plan["environment"]) == {"PATH", "LC_ALL", "TMPDIR"}
    assert frontend["threads"] == 1 and frontend["executable"] == plan["gnat1"]
    actual = frontend["environment"]
    assert len(actual) == 6 and all(actual[k] == v for k, v in plan["environment"].items())
    assert set(actual) - set(plan["environment"]) == {"COLLECT_GCC", "COLLECT_GCC_OPTIONS", "GCC_EXEC_PREFIX"}
    assert actual["COLLECT_GCC"] == plan["argv"][0]
    assert actual["GCC_EXEC_PREFIX"] == str(Path(plan["argv"][0]).parent) + "/../lib/gcc/"
    assert len(frontend["argv"]) == 20
    assert frontend["argv"][1:19] == ["-quiet", "-Wno-free-nonheap-object", "-dumpbase", "b__main~1.adb", "-dumpbase-ext", ".adb", "-gnatA", "-gnatA", "-gnatWb", "-gnatiw", "-gnatws", "-mtune=generic", "-march=x86-64", "-fsplit-wide-types", "-gnatO", "b__main~1.o", "b__main~1.adb", "-o"]
    assert frontend["argv"][19].startswith(plan["environment"]["TMPDIR"] + "/cc")
    assert len(frontend["argv"][19]) == 63 and frontend["argv"][19].endswith(".s")
    assert not art[tag + "/capture/dryrun.stdout"]
    assert b"-fsplit-wide-types" in art[tag + "/capture/dryrun.stderr"]
    for name, row in run["generated"].items():
        assert digest(art[tag + "/output/" + name]) == row
    # Reconcile the complete D-record specification interface with retained bytes.
    ali = art[tag + "/output/b__main~1.ali"]
    dependencies = re.findall(rb"^D ([^\s]+)", ali, re.M)
    assert ali.count(b"A -fsplit-wide-types\n") == 1
    for name in dependencies:
        spelling = name.decode()
        raw = art[tag + "/output/" + spelling] if spelling.startswith("b__main") else art["runtime/" + spelling]
        pins = [r for p, r in plan["input_identities"].items() if Path(p).name == spelling]
        assert pins and all(row == digest(raw) for row in pins), spelling
    ledger = [json.loads(line) for line in art[tag + "/managed/events.jsonl"].splitlines()]
    finished, = [r for r in ledger if r["event"] == "finished"]
    prepared, = [r for r in ledger if r["event"] == "prepared"]
    started, = [r for r in ledger if r["event"] == "started"]
    assert finished["outcome"] == "success" and started["workers"] == 1
    pins = prepared["inputs"]["inputs_sha256"]
    for name in ("run.py", "counters.py", "invocation.json", "executable-map.json", "guard-map.json"):
        assert pins[str(Path(plan["cwd"]).parent / name)] == digest(art[tag + "/" + name])["sha256"]
    E, B = state["ggc_bytes"]["positive_events"], state["ggc_bytes"]["positive_sum"]
    slots = 1 << (max(128, E) - 1).bit_length()
    finalizers = max(4, E, 2 * min(15, E - 1), 3 * (E - 1) // 2)
    assert B < 5 * 1024**2
    return {"managed_run_id": finished["run_id"], "managed_duration_seconds": finished["duration_seconds"],
            "debugger_duration_seconds": run["elapsed_seconds"], "counter_event_identity": digest(raw_events),
            "counter_records_replayed": len(events), "counters": state,
            "rounded_GGC_histogram": [{"bytes": n, "events": v} for n, v in sorted(histogram.items())],
            "site_events": [{"counter": n, "pc": p, "events": v} for (n, p), v in sorted(sites.items())],
            "heuristic_collection_calls": len(summary["collection_calls"]), "actual_marker_calls": 0,
            "value_expr_insert_calls": 0, "minimum_heap_bytes": 4 * 1024**2,
            "default_min_expand_percent_lower": 30, "conservative_first_collection_threshold_bytes": 5 * 1024**2,
            "margin_below_threshold_bytes": 5 * 1024**2 - B,
            "each_page_pointer_vector_slots_bound": slots, "each_page_pointer_vector_bytes_bound": 8 * slots,
            "each_finalizer_vector_slots_bound": finalizers, "scalar_finalizer_vector_bytes_bound": 8 + 16 * finalizers,
            "array_finalizer_vector_bytes_bound": 8 + 32 * finalizers,
            "dependency_specifications": [n.decode() for n in dependencies if not n.startswith(b"b__main")],
            "varying_checksum_lifetime_bound_established": False}


def section_data(raw):
    offset = struct.unpack_from("<Q", raw, 40)[0]
    count, strings = struct.unpack_from("<HH", raw, 60)
    headers = [struct.unpack_from("<IIQQQQIIQQ", raw, offset + 64 * i) for i in range(count)]
    names_header = headers[strings]
    names = raw[names_header[4]:names_header[4] + names_header[5]]
    return {names[h[0]:names.index(0, h[0])].decode(): b"" if h[1] == 8 else raw[h[4]:h[4] + h[5]] for h in headers}


def defaults_check(art):
    mapping = json.loads(art["defaults/mapping.json"])
    assert mapping["binary_sha256"] == json.loads(art["null/invocation.json"])["gnat1_sha256"]
    windows = {}
    for row in mapping["windows"]:
        raw = art[row["file"]]
        assert digest(raw) == {k: row[k] for k in ("bytes", "sha256")}
        windows[row["file"]] = (int(row["address"], 16), raw)
    assert struct.unpack("<10d", art["defaults/double_constants.bin"]) == (1/1024**3, 70., 30., 1/1024, 1/8, 1/4, 20480., 100., 4096., 131072.)
    assert struct.unpack("<f", art["defaults/float_hundred.bin"]) == (100.,)

    def rip_target(file, address, opcode, size):
        base, raw = windows[file]
        off = address - base
        assert raw[off:off + len(opcode)] == opcode
        return address + size + struct.unpack_from("<i", raw, off + len(opcode))[0]

    init = "defaults/init_ggc_heuristics.bin"
    expand = "defaults/ggc_min_expand_heuristic.bin"
    assert rip_target(init, 0xf80d04, b"\xe8", 5) == 0xf7fc50
    assert rip_target(init, 0xf80d09, b"\x89\x05", 6) == 0x3d4f4d0
    assert rip_target(init, 0xf80e49, b"\x89\x05", 6) == 0x3d4f4d4
    assert rip_target(expand, 0xf7fcb5, bytes.fromhex("f20f580d"), 8) == 0x2c3e770
    assert art[init][0x126:0x12b] == bytes.fromhex("b800100000")  # minimum heap 4096 KiB
    collect = "null/_Z11ggc_collect11ggc_collect.bin"
    windows[collect] = (0xda5780, art[collect])
    assert rip_target(collect, 0xda5796, bytes.fromhex("8b1d"), 6) == 0x3d4f4d4
    assert rip_target(collect, 0xda57ef, bytes.fromhex("f30f2a05"), 8) == 0x3d4f4d0
    assert rip_target(collect, 0xda57fb, bytes.fromhex("f30f5e05"), 8) == 0x2a1dc04
    f32 = lambda value: struct.unpack("<f", struct.pack("<f", value))[0]
    heap, percent = f32(4 * 1024**2), f32(30)
    expansion = f32(f32(heap * percent) / f32(100))
    threshold = f32(heap + expansion)
    assert expansion == 1258291.25 and threshold == 5452595.0
    assert expansion > 1024**2 and threshold > 5 * 1024**2
    return {"installed_binary_sha256": mapping["binary_sha256"],
            "minimum_heap_KiB": 4096, "minimum_expand_percent": 30,
            "minimum_endpoint_binary32_expansion_bytes": expansion,
            "minimum_endpoint_binary32_threshold_bytes": threshold,
            "conservative_threshold_bytes": 5 * 1024**2,
            "new_parameter_override": False}


def object_delta(old_raw, new_raw, elf):
    old, new = elf(old_raw), elf(new_raw)
    before, after = section_data(old_raw), section_data(new_raw)
    assert len(old["sections"]) == len(new["sections"]) == 16
    for a, b in zip(old["sections"], new["sections"]):
        assert {k: v for k, v in a.items() if k != "size"} == {k: v for k, v in b.items() if k != "size"}
        assert b["size"] == a["size"] - (6 if a["name"] == ".text" else 0)
    changes = [{"before": a, "after": b} for a, b in zip(old["symbols"], new["symbols"]) if a != b]
    assert len(old["symbols"]) == len(new["symbols"]) and len(changes) == 1
    change, = changes
    assert change["before"]["name"] == change["after"]["name"] == "ada_main___elabb"
    assert change["before"]["size"] == 38 and change["after"]["size"] == 32
    assert {k: v for k, v in change["before"].items() if k != "size"} == {k: v for k, v in change["after"].items() if k != "size"}
    start = change["before"]["value"]
    assert before[".text"][:start] == after[".text"][:start]
    assert before[".text"][start:].hex() == "554889e5488d0500000000488d15000000004889c14889d04889cf4889c6e800000000905dc3"
    assert after[".text"][start:].hex() == "554889e5488d1500000000488d05000000004889d74889c6e800000000905dc3"
    changed_sections = [name for name in before if before[name] != after[name]]
    assert changed_sections == [".text", ".rela.text", ".eh_frame", ".symtab"]
    relocation_deltas = []
    for name in before:
        if not name.startswith(".rela."):
            continue
        x, y = before[name], after[name]
        assert len(x) == len(y) and len(x) % 24 == 0
        for i in range(len(x) // 24):
            a, b = struct.unpack_from("<QQq", x, i * 24), struct.unpack_from("<QQq", y, i * 24)
            if a != b:
                relocation_deltas.append({"section": name, "index": i, "before": list(a), "after": list(b)})
    assert len(relocation_deltas) == 1
    relocation, = relocation_deltas
    assert relocation["section"] == ".rela.text"
    assert relocation["after"][0] == relocation["before"][0] - 6
    assert relocation["after"][1:] == relocation["before"][1:]
    assert old["relocations"] == new["relocations"]
    assert old["external_names"] == new["external_names"]
    # The final FDE range and its epilogue advance both shorten by six bytes.
    eh_before, eh_after = before[".eh_frame"], after[".eh_frame"]
    eh_changes = [(i, x, y) for i, (x, y) in enumerate(zip(eh_before, eh_after)) if x != y]
    assert len(eh_changes) == 2
    assert [(x, y) for _, x, y in eh_changes] == [(38, 32), (0x61, 0x5b)]
    assert eh_changes[1][0] == eh_changes[0][0] + 13
    cie_count, fde_count, pos = 0, 0, 0
    while pos < len(eh_after):
        length, = struct.unpack_from("<I", eh_after, pos)
        assert 4 <= length < 0xfffffff0 and pos + 4 + length <= len(eh_after)
        pointer, = struct.unpack_from("<I", eh_after, pos + 4)
        cie_count += int(pointer == 0)
        fde_count += int(pointer != 0)
        pos += 4 + length
    assert pos == len(eh_after) and cie_count == 1
    for key in ("symbol_st_size_sum", "nonlocal_symbol_st_size_sum", "allocated_bytes", "text_bytes"):
        assert new[key] == old[key] - 6
    return {"before": {k: v for k, v in old.items() if k not in ("sections", "symbols", "external_names")},
            "after": {k: v for k, v in new.items() if k not in ("sections", "symbols", "external_names")},
            "changed_section_payloads": changed_sections, "changed_symbols": changes,
            "changed_relocations": relocation_deltas, "nonlocal_symbol_count": len(new["external_names"]),
            "CIE_count": cie_count, "FDE_count": fde_count,
            "EH_changed_bytes": [{"offset": i, "before": x, "after": y} for i, x, y in eh_changes],
            "old_count_payload_alignment_envelope_still_dominates": True}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    manifest = json.loads((ROOT / "manifest.json").read_bytes())
    art, src = (load_archive(n, manifest) for n in ("artifacts.tar.gz", "sources.tar.gz"))
    predecessor = json.loads(art["predecessor/binder/manifest.json"])
    prior_sources = predecessor["archives"]["sources.tar.gz"]["members"]
    split_sources = {r["path"]: r for r in json.loads(art["predecessor/split/sources.json"])["files"]}
    output_sources = {r["path"]: r for r in json.loads(art["predecessor/output/manifest.json"])["sources"]["members"]}
    for name, raw in src.items():
        matches = [r[name] for r in (prior_sources, split_sources, output_sources) if name in r]
        assert matches and all(digest(raw) == {k: row[k] for k in ("bytes", "sha256")} for row in matches), name
    for file, snippets in {
        "gcc/ggc-common.cc": [b"min_expand += 30;", b"return min_expand;", b"phys_kbytes = MAX (phys_kbytes, 4 * ONE_K);", b"param_ggc_min_expand = ggc_min_expand_heuristic ();", b"param_ggc_min_heapsize = ggc_min_heapsize_heuristic ();", b"if (! GATHER_STATISTICS)\n    return;"],
        "gcc/ggc-page.cc": [b"G.allocated += object_size;", b"timevar_ggc_mem_total += object_size;", b"MAX (G.allocated_last_gc, (size_t)param_ggc_min_heapsize * ONE_K)", b"float min_expand = allocated_last_gc * param_ggc_min_expand / 100;", b"&& G.allocated < allocated_last_gc + min_expand)"],
        "gcc/common.opt": [b"fsplit-wide-types\nCommon Var(flag_split_wide_types) Optimization"],
        "gprbuild/src/gprbind.adb": [b'Compiler_Options.Append (Arg.all);']}.items():
        assert all(s in src[file] for s in snippets), file
    # Reuse the already reviewed complete baseline replay unchanged.
    helper = {"__file__": str(ROOT / "predecessor-check.py"), "__name__": "retained_binder_predecessor"}
    exec(compile(art["predecessor/binder/check.py"], helper["__file__"], "exec"), helper)
    baseline = {name.removeprefix("baseline/"): raw for name, raw in art.items() if name.startswith("baseline/")}
    old_lifetime = helper["reconcile_lifetime"](baseline, src)
    old_plan = json.loads(baseline["compiler-capture/invocation.json"])
    results = {}
    for tag, old_key in (("null", "baseline/cases/indexed-cr/b__main~1.o"), ("output", "output-before/indexed/obj/b__main~1.o")):
        plan = json.loads(art[tag + "/invocation.json"])
        assert [a for a in plan["argv"] if a != "-fsplit-wide-types"] == old_plan["argv"]
        for name in ("b__main~1.ads", "b__main~1.adb"):
            key = "baseline/lifetime-capture/output/" + name if tag == "null" else "output-before/indexed/obj/" + name
            assert art[tag + "/output/" + name] == art[key]
        results[tag] = {"lifetime": replay(tag, art), "object": object_delta(art[old_key], art[tag + "/output/b__main~1.o"], helper["elf"])}
    assert results["null"]["lifetime"]["counters"]["ggc_bytes"]["positive_events"] == old_lifetime["counters"]["ggc_bytes"]["positive_events"] == 48889
    assert results["null"]["lifetime"]["counters"]["ggc_bytes"]["positive_sum"] - old_lifetime["counters"]["ggc_bytes"]["positive_sum"] == 16
    for name in ("decl_uid", "type_uid", "debug_decl_uid"):
        assert results["null"]["lifetime"]["counters"][name] == old_lifetime["counters"][name]
    result = {"scope": "Proposed stock split-wide option: fixed null/output binder object and lifetime reconciliation",
              "native_platform": "Linux x86-64", "source_files_verified": len(src), "artifacts_verified": len(art),
              "new_native_compiler_deliveries": 2, "driver_only_queries": 2, "new_full_audits": 0,
              "new_Lean_or_solver_executions": 0, "production_flags_or_admission_changed": False,
              "null_lifetime_GGC_bytes_delta": 16, "null_lifetime_event_count_delta": 0,
              "fixed_source_path_family_no_collection_threshold_bytes": 5 * 1024**2,
              "default_parameter_binary_source_link": defaults_check(art),
              "varying_output_checksum_lifetime_bound_established": False,
              "whole_tool_capacity_established": False, "cases": results}
    rendered = json.dumps(result, indent=2) + "\n"
    if args.output:
        args.output.write_text(rendered)
    else:
        assert json.loads((ROOT / "result.json").read_bytes()) == result
    print(json.dumps({"sources": len(src), "artifacts": len(art), "cases": {tag: {"object_bytes": r["object"]["after"]["file"]["bytes"], "GGC_bytes": r["lifetime"]["counters"]["ggc_bytes"]["positive_sum"]} for tag, r in results.items()}}))


if __name__ == "__main__":
    main()
