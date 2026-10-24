#!/usr/bin/env python3
"""Reconcile retained proof-mode diagnostic positions; run no native tool.

The source/event reduction and raw-recipe classifier are manual arguments.
This reader verifies exact inputs, earlier lifetime arithmetic, configuration,
runtime-source inventory and the broad arithmetic envelope.
"""
import hashlib
import json
import re
import tarfile
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
PREVIOUS = ROOT / "docs/evidence/retained-main-semantics-20261018"
GCC_MANIFEST = ROOT / (
    "docs/evidence/unbounded-programs/continuation-20261017/"
    "frontend-lifetimes/complete-source-manifest.json"
)
GCC_PIN = "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea"
SPARK_PIN = "42554fc241fcd1fdf08d3a2feccb3f86912acbc0"
SPARK_ARCHIVE = ROOT / (
    "docs/evidence/unbounded-programs/frontend-representation-20261017/"
    "toolchain/raw-evidence.tar.gz"
)
SPARK_SHA = "f2e7dd7bbef086a36ddf97f9bd3bd669ca895fcc28e3ac23ffe0c9f85fc5d952"
PRODUCER = "343682de485bb151e1817615acebab5b185504efdf2b082f1647cd41a14241f1"
POSITIONS = {
    "raw_history": "errout__non_instance_msgs__last_valX",
    "errors": "erroutc__errors__last_val",
    "locations": "erroutc__locations__last_val",
    "edits": "erroutc__edits__last_val",
    "fixes": "erroutc__fixes__last_val",
    "warnings": "erroutc__warnings__last_val",
    "specific_warnings": "erroutc__specific_warnings__last_val",
    "unreferenced": "sem_warn__unreferenced_entities__last_valX",
    "in_out_warnings": "sem_warn__in_out_warnings__last_valX",
    "warnings_off_pragmas": "sem_warn__warnings_off_pragmas__last_val",
}
LOCAL = [
    "silver_io.ads", "silver_io.adb", "silver_arguments.ads",
    "silver_arguments.adb", "silver_output_libc.ads", "silver_runtime.ads",
]
RUNTIME = [
    "system-linux-x86.ads", "ada.ads", "a-textio.ads", "a-ioexce.ads",
    "a-stream.ads", "s-ficobl.ads", "interfac__2020.ads", "i-cstrea.ads",
    "s-crtl.ads", "s-parame.ads", "s-wchcon.ads", "i-c.ads",
    "a-sttebu.ads", "a-string.ads", "a-stuten.ads", "a-unccon.ads",
    "a-comlin.ads",
]
RANGES = {
    "gnat1drv.adb": [(517, 529), (1197, 1217), (1530, 1538)],
    "errout.adb": [(550, 697), (1280, 1379), (1510, 1545), (3008, 3025), (3216, 3221)],
    "erroutc.adb": [(228, 232), (990, 1005), (1988, 2005), (2033, 2048), (2140, 2156)],
    "opt.ads": [(530, 540)], "switch-c.adb": [(995, 1007)],
    "sem_warn.adb": [(1241, 1257), (1930, 1943)],
    "sem_ch4.adb": [(4744, 4794)],
    "sem_ch6.adb": [(11310, 11347)],
    "sem_ch7.adb": [(2044, 2057)],
    "sem_prag.adb": [(8190, 8267), (28775, 28805), (35220, 35328)],
    "sem_util.adb": [(4321, 4350), (6020, 6131)],
    "sem_elab.adb": [(2335, 2378), (6420, 6457), (17900, 17920)],
    "inline.adb": [(1950, 2030), (2114, 2170)],
}


def sha(data):
    return hashlib.sha256(data).hexdigest()


def read(path):
    return json.loads(path.read_text())


def positions(capture):
    assert capture["unexpected_collect"] == 0
    phase = capture["phases"][-1]
    assert phase["phase"] == "before_symbol_free"
    result = {}
    for label, key in POSITIONS.items():
        row = phase["pools"][key]
        assert row["positive"] == row["position"]-row["initial"]+row["negative"]
        assert row["negative"] == 0
        result[label] = row["positive"]
    return result


def config(options, invocation):
    assert not options["global_gen_mode"]
    assert options["warning_mode"] == "SW_TREAT_AS_ERROR"
    assert options["report_mode"] == "GPR_ALL"
    assert options["output_mode"] == "GPO_PRETTY_SIMPLE"
    assert not options["debug"] and not options["ide_mode"]
    for value in options["file_specific"].values():
        assert value["no_inlining"] and value["no_loop_unrolling"]
        assert value["why3_args"] == ["/usr/bin/false"]
    argv = invocation["argv"]
    assert all(x in argv for x in ("-gnatA", "-gnat2022", "-gnatc"))
    assert not any(x.startswith("-gnatj") for x in argv)
    return {key: options[key] for key in (
        "global_gen_mode", "warning_mode", "report_mode", "output_mode",
        "debug", "ide_mode",
    )}


def main():
    identity = read(HERE / "identity.json")
    for rel, expected in identity["prior_artifacts"].items():
        assert sha((ROOT / rel).read_bytes()) == expected, rel
    previous_inputs = read(PREVIOUS / "library-capture/inputs.json")
    for name in LOCAL:
        old = next(row for path, row in previous_inputs.items()
                   if path.endswith("/library-src/"+name))
        current = (ROOT / "src" / name).read_bytes()
        assert len(current) == old["bytes"] and sha(current) == old["sha256"]

    manifest = read(GCC_MANIFEST)
    assert manifest["commit"] == GCC_PIN
    expected = {row["path"]: row for row in manifest["files"]}
    core = {name: row for name, row in expected.items()
            if "/" not in name and name.endswith((".adb", ".ads"))}
    assert len(core) == 474
    c_front = sum(row["bytes"] for row in core.values())
    assert c_front == 27301966
    assert sha((HERE / "gcc-sources.tar.gz").read_bytes()) == identity["gcc_archive_sha256"]
    with tarfile.open(HERE / "gcc-sources.tar.gz") as archive:
        source = {m.name: archive.extractfile(m).read() for m in archive if m.isfile()}
    for name, data in source.items():
        assert len(data) == expected[name]["bytes"]
        assert sha(data) == expected[name]["sha256"]
    raw_inventory = read(HERE / "raw-argument-inventory.json")
    assert raw_inventory["gcc_revision"] == GCC_PIN
    assert raw_inventory["call_occurrences"] == 4422
    assert len(raw_inventory["nonstatic_arguments"]) == 228
    assert raw_inventory["maximum_direct_literal_argument"]["bytes"] == 147
    for name, row in raw_inventory["sources"].items():
        assert row == expected[name]
    assert sha(SPARK_ARCHIVE.read_bytes()) == SPARK_SHA
    with tarfile.open(SPARK_ARCHIVE) as archive:
        backend = archive.extractfile("spark-source/src/why/back_end.adb").read()

    scan = read(PREVIOUS / "fixed-capture/static-all-tables.json")
    coverage = read(PREVIOUS / "fixed-capture/address-coverage.json")
    assert scan["sha256"] == coverage["sha256"] == PRODUCER
    stores = {int(row["address"], 16) for row in scan["references"] if row["write"]}
    kept = {row["address"] for row in read(PREVIOUS / "fixed-capture/decrease-hooks.json")}
    excluded = {row["address"] for row in read(PREVIOUS / "fixed-capture/excluded-positive-stores.json")}
    assert not kept & excluded and kept | excluded == stores
    assert (len(stores), len(kept), len(excluded)) == (2299, 1265, 1034)
    for key in ("immediate_candidates", "absolute_candidates", "relocations",
                "dynamic_symbols", "symbol_aliases", "data_pointer_candidates",
                "additional_direct_instructions", "original_direct_missing"):
        assert coverage[key] == []

    main_capture = read(PREVIOUS / "fixed-capture/pool-counters.json")
    assert main_capture["coherence_failures"] == []
    assert len(main_capture["queries"]) == len(main_capture["returns"]) == 179
    main_row = positions(main_capture)
    assert all(value == 0 for value in main_row.values())
    rows = {"main_fixed": main_row}
    configs = {"main_fixed": config(read(PREVIOUS / "fixed-capture/options.json"),
                                    read(PREVIOUS / "fixed-capture/invocation.json"))}
    summary = read(PREVIOUS / "library-capture/summary.json")
    archive_manifest = read(PREVIOUS / "library-capture/archive-manifest.json")
    with tarfile.open(PREVIOUS / "library-capture/captures.tar.gz") as archive:
        for name, row in archive_manifest.items():
            data = archive.extractfile(name).read()
            assert len(data) == row["bytes"] and sha(data) == row["sha256"]
        for case in summary["cases"]:
            name = case["case"]
            get = lambda leaf: json.load(archive.extractfile(name+"/"+leaf))
            capture = get("pool-counters.json")
            assert capture["range_mutations"] == 0
            rows[name] = positions(capture)
            configs[name] = config(get("options.json"), get("invocation.json"))
            assert get("result.json")["producer_sha256"] == PRODUCER
    for name, count in (("silver_io", 12), ("silver_arguments", 7),
                        ("silver_output_libc", 0), ("silver_runtime", 0)):
        assert all(rows[name][key] == count for key in ("raw_history", "errors", "locations"))
        assert all(value == 0 for key, value in rows[name].items()
                   if key not in ("raw_history", "errors", "locations"))

    pragmas = []
    pattern = re.compile(r"\bpragma\s+(Warnings|Warning_As_Error|Compile_Time_Warning|Style_Checks|License)\b", re.I)
    inputs = {"libgnat/"+name: source["libgnat/"+name] for name in RUNTIME}
    inputs.update({"src/"+name: (ROOT/"src"/name).read_bytes() for name in LOCAL})
    for name, data in inputs.items():
        for line_no, line in enumerate(data.decode().splitlines(), 1):
            code = line.split("--", 1)[0]
            if pattern.search(code):
                pragmas.append({"file": name, "line": line_no, "text": code.strip()})
    assert len(pragmas) == 1
    assert pragmas[0]["text"] == "pragma Warnings (Off, Default_Bit_Order);"
    # Storage arithmetic only: no aggregate RAM admission gate.
    example_raw = 2*c_front+2*1024+2*4096+128
    assert 12*example_raw < 2**31-1
    result = {
        "scope": "Offline reconciliation; source reduction and recipe classification are manual",
        "gcc_revision": GCC_PIN, "spark_revision": SPARK_PIN, "producer_sha256": PRODUCER,
        "promoted_positions": rows, "retained_configs": configs,
        "core_source_files": len(core), "core_source_bytes": c_front,
        "raw_argument_inventory_sha256": sha((HERE / "raw-argument-inventory.json").read_bytes()),
        "core_source_manifest": core, "warning_pragmas": pragmas,
        "source_inputs": {name: {"bytes": len(data), "sha256": sha(data)} for name, data in inputs.items()},
        "orientation_only": {"N_fixed": 1024, "P": 4096, "R_fixed": example_raw,
                             "twelve_raw_histories": 12*example_raw},
    }
    (HERE / "result.json").write_text(json.dumps(result, indent=2, sort_keys=True)+"\n")
    excerpts = ["# Fixed proof-mode frontend witnesses\n\n"]
    for name, ranges in RANGES.items():
        lines = source[name].decode().splitlines()
        for low, high in ranges:
            excerpts.append(f"\n## {name}:{low}–{high}\n\n```ada\n")
            excerpts.extend(f"{n}: {lines[n-1]}".rstrip()+"\n" for n in range(low, high+1))
            excerpts.append("```\n")
    lines = backend.decode().splitlines()
    excerpts.append("\n## SPARK why/back_end.adb:126–208\n\n```ada\n")
    excerpts.extend(f"{n}: {lines[n-1]}".rstrip()+"\n" for n in range(126,209))
    excerpts.append("```\n")
    (HERE / "source-excerpts.md").write_text("".join(excerpts))
    print(json.dumps({"status": "passed", "diagnostic_rows": rows,
                      "core_source_bytes": c_front}, sort_keys=True))


if __name__ == "__main__":
    main()
