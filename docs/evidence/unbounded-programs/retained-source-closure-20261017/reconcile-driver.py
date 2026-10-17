#!/usr/bin/env python3
"""Reconcile retained driver inputs; no compiler or proof process is invoked."""

import argparse
import hashlib
import json
from pathlib import Path
import re


def digest(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--installation", type=Path, required=True)
    parser.add_argument("--gpr-source", type=Path, required=True)
    parser.add_argument("--gcc", type=Path, required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    root, out = args.installation, args.output
    out.mkdir(parents=True, exist_ok=True)
    native = root / ".tools/linux-x86_64/alire/toolchains/gnat_native_16.1.0_9f74f58a/lib/gcc/x86_64-pc-linux-gnu/16.1.0/adainclude"
    producer = root / ".tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef"
    toolpaths = {
        "native-gnat.xml": root / ".tools/linux-x86_64/alire/toolchains/gprbuild_26.0.1_e3f27f25/share/gprconfig/gnat.xml",
        "producer-gnat.xml": producer / "libexec/spark/share/gprconfig/gnat.xml",
        "producer-custom.xml": producer / "share/spark/config/gnat2why/config.xml",
    }
    retained = {}

    def keep(source, relative):
        data = source.read_bytes()
        target = out / relative
        target.parent.mkdir(parents=True, exist_ok=True)
        target.write_bytes(data)
        retained[relative] = {"original_path": str(source), **digest(data)}
        return data

    for name, path in toolpaths.items():
        keep(path, name)
    records = root / ".silver/linux-x86_64/compose-results/experiment/stopped-256-probes.json"
    original = json.loads(records.read_bytes())
    selected = [p for p in original["processes"] if p["pid"] in (293256, 293263, 293310, 293321)]
    (out / "command-records.json").write_text(json.dumps({
        "original_record": {"path": str(records), **digest(records.read_bytes())},
        "original_reason": original["reason"], "processes": selected,
    }, indent=2, sort_keys=True) + "\n")
    snapshots = []
    for pid, program in ((293256, "dynamic-256-empty-literals"),
                         (293263, "assignment-256-empty-refs")):
        workspace = records.parent / program
        prefix = str(pid)
        keep(workspace / "program.gpr", prefix + "/program.gpr")
        mapping = None
        for n in range(1, 5):
            filename = f"GNAT-TEMP-{n:06}.TMP"
            data = keep(Path(f"/tmp/GPR.{pid}") / filename, prefix + "/" + filename)
            if n == 2:
                config_bytes = len(data)
            if n == 3:
                mapping = data.decode().split("\n")
                assert mapping.pop() == "" and len(mapping) % 3 == 0
        entries = []
        for i in range(0, len(mapping), 3):
            unit, name, resolved = mapping[i:i + 3]
            path = Path(resolved)
            assert path.name == name
            kind = "workspace" if path.parent == workspace else "runtime"
            if kind == "runtime":
                assert path.parent == producer / "libexec/spark/lib/gcc/x86_64-pc-linux-gnu/16.1.0/adainclude"
                assert path.read_bytes() == (native / name).read_bytes()
            entries.append({"unit": unit, "request_name": name,
                            "resolved_path": resolved, "kind": kind,
                            **digest(path.read_bytes())})
        assert len({e["request_name"] for e in entries}) == len(entries)
        snapshots.append({
            "gpr_pid": pid, "program": program,
            "config_bytes": config_bytes,
            "config_aligned_charge": 4096 * ((config_bytes + 4096) // 4096),
            "mapping_entries": entries,
            "all_request_names_are_distinct_basenames": True,
            "current_silver_source_equality": {
                p.name: p.read_bytes() == (root / "src" / p.name).read_bytes()
                for p in sorted(workspace.glob("silver_*")) if p.is_file()
            },
        })
    current = root / ".silver/linux-x86_64/program-Z0j19G"
    current_libraries = [p for p in current.glob("silver_*") if p.is_file()]
    assert len(current_libraries) == 6
    current_files = ["main.adb", "program.gpr", "obj/main.ali", "obj/b__main.adb",
                     "obj/b__main.ads", "obj/b__main.ali", "obj/main.bexch"]
    current_files += [str(p.relative_to(current)) for p in sorted(current.rglob("*.cswi"))]
    for name in current_files:
        keep(current / name, "program-Z0j19G/" + name)
    deps = re.findall(r"^D (\S+)", (current / "obj/main.ali").read_text(), re.M)
    current_dependencies = []
    for name in deps:
        path = current / name
        kind = "workspace"
        if not path.exists():
            path = native / name
            kind = "runtime"
        assert path.is_file() and Path(name).name == name
        current_dependencies.append({"request_name": name, "kind": kind,
                                     **digest(path.read_bytes())})
    source_paths = ["src/gprbuild-compile.adb", "gpr/src/gpr-env.adb"]
    gcc_paths = ["fmap.adb", "fname-uf.adb", "osint.adb", "osint-c.adb",
                 "frontend.adb", "switch-c.adb", "sem_ch7.adb", "sem_ch12.adb"]
    result = {
        "scope": "Retained snapshots and inspected source routing, not universal closure or a new tool run.",
        "gpr_source_commit": "bdfb879cf03643ec8e48a09ce07b08c4a6ff0263",
        "gpr_source_tag": "v26.0.0",
        "gpr_source_archive_url": "https://codeload.github.com/AdaCore/gprbuild/tar.gz/bdfb879cf03643ec8e48a09ce07b08c4a6ff0263",
        "gpr_source_archive": digest((args.gpr_source.parent / "gprbuild-v26.0.0.tar.gz").read_bytes()),
        "gpr_source_inputs": {p: digest((args.gpr_source / p).read_bytes()) for p in source_paths},
        "gcc_source_inputs": {p: digest((args.gcc / p).read_bytes()) for p in gcc_paths},
        "installed_gpr_executable_source_identity_established": False,
        "retained_inputs": retained,
        "older_producer_snapshots": snapshots,
        "current_workspace": {
            "name": current.name, "native_ali_dependencies": current_dependencies,
            "all_six_silver_source_bytes_current": all(
                p.read_bytes() == (root / "src" / p.name).read_bytes()
                for p in current_libraries),
            "native_ali_has_gnatA": "A -gnatA\n" in (current / "obj/main.ali").read_text(),
        },
        "limitations": [
            "Older producer artifacts are stopped exploratory runs, not successful confirmation evidence.",
            "Their naming/project shape agrees, but four library source files differ from current sources.",
            "Current .cswi omits temporary config/map arguments; its historical GPR temporary files were not located.",
            "Source identity of installed GPR executables is not established by the version/tag agreement.",
            "Inherited include/object environment was not retained with these snapshots.",
        ],
    }
    print(json.dumps(result, indent=2, sort_keys=True))


if __name__ == "__main__":
    main()
