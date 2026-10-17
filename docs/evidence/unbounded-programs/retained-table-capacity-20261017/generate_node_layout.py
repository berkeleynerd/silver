#!/usr/bin/env python3
"""Run the pinned, standalone Gen_IL generator in a fresh research workspace.

This does not build or replace GNAT, establish installed-compiler identity, or
count source-to-allocation events. Its output supplies exact generated sizes
for the source-relative node-storage argument.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import shutil
import subprocess


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("ada_source", type=Path)
    parser.add_argument("workspace", type=Path, help="fresh output directory")
    args = parser.parse_args()
    source = args.ada_source.resolve()
    workspace = args.workspace.resolve()
    repository = Path(__file__).resolve().parents[4]
    manifest = json.loads((repository / "docs/evidence/unbounded-programs/"
                           "continuation-20261017/frontend-lifetimes/"
                           "complete-source-manifest.json").read_text())
    pin = "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea"
    if manifest["commit"] != pin:
        raise SystemExit("Pinned manifest commit mismatch")
    expected = {entry["path"]: entry for entry in manifest["files"]}
    paths = sorted(path for path in source.glob("gen_il*")
                   if path.suffix in (".ads", ".adb") and path.is_file())
    expected_names = {name for name in expected
                      if "/" not in name and name.startswith("gen_il")
                      and Path(name).suffix in (".ads", ".adb")}
    if {path.name for path in paths} != expected_names:
        raise SystemExit("Pinned Gen_IL source set mismatch")
    hashes = {}
    for path in paths:
        raw = path.read_bytes()
        sha256 = hashlib.sha256(raw).hexdigest()
        blob = hashlib.sha1(b"blob " + str(len(raw)).encode() + b"\0" + raw).hexdigest()
        if (sha256 != expected[path.name]["sha256"]
                or blob != expected[path.name]["git_blob_sha1"]):
            raise SystemExit(f"Pinned source mismatch: {path.name}")
        hashes[path.name] = sha256
    compiler = shutil.which("gnatmake")
    if compiler is None:
        raise SystemExit("gnatmake is required; use the selected Alire environment")
    # Refuse to overwrite a prior run, preserving both successes and failures.
    workspace.mkdir(parents=True, exist_ok=False)
    inputs = workspace / "inputs"
    build = workspace / "build"
    generated = workspace / "generated"
    for directory in (inputs, build, generated):
        directory.mkdir()
    for path in paths:
        shutil.copyfile(path, inputs / path.name)
    executable = workspace / "gen_il-main"
    command = [compiler, "-j1", "-gnat2022", "-gnata", "-gnato", "-O0",
               "-D", str(build), str(inputs / "gen_il-main.adb"),
               "-o", str(executable)]
    versions = subprocess.run([compiler, "--version"], check=True,
                              capture_output=True, text=True).stdout
    (workspace / "compiler-version.txt").write_text(versions)
    (workspace / "command.json").write_text(json.dumps(command, indent=2) + "\n")
    with (workspace / "build.log").open("w") as log:
        subprocess.run(command, cwd=inputs, stdout=log,
                       stderr=subprocess.STDOUT, check=True)
    with (workspace / "generator.log").open("w") as log:
        subprocess.run([str(executable)], cwd=generated, stdout=log,
                       stderr=subprocess.STDOUT, check=True)
    tables = {}
    for filename, family in (("sinfo-nodes.ads", "Node"),
                             ("einfo-entities.ads", "Entity")):
        content = (generated / filename).read_text()
        constants = {key: int(value) for key, value in re.findall(
            rf"((?:Min|Max)_{family}_Size)\s*:\s*constant Field_Offset :=\s*(\d+)",
            content)}
        match = re.search(r"\bSize\s*:\s*constant array\b.*?:=\s*\((.*?)\);",
                          content, re.S)
        if len(constants) != 2 or match is None:
            raise SystemExit(f"Unexpected generated size table: {filename}")
        entries = {key: int(value) for key, value in re.findall(
            r"([NE]_\w+)\s*=>\s*(\d+)", match[1])}
        if not entries or max(entries.values()) != constants[f"Max_{family}_Size"]:
            raise SystemExit(f"Generated size maximum mismatch: {filename}")
        tables[family.lower()] = {"constants": constants, "size_by_kind": entries}
    seinfo = (generated / "seinfo.ads").read_text()
    header = re.search(r"N_Head\s*:\s*constant Field_Offset :=\s*(\d+)", seinfo)
    if header is None:
        raise SystemExit("Missing generated header size")
    result = {
        "source_commit": pin,
        "source_sha256": hashes,
        "host": "Linux x86_64",
        "compiler": str(Path(compiler).resolve()),
        "compiler_version": versions,
        "command": command,
        "header_slots": int(header[1]),
        "slot_bits": 32,
        "tables": tables,
        "generated_sha256": {path.name: digest(path)
                             for path in sorted(generated.iterdir())},
        "scope": "Standalone pinned source generator; not a compiler or proof build",
        "limitations": ["no installed-compiler layout identity established",
                        "no source-to-allocation event bound",
                        "no whole-program capacity predicate"],
    }
    (workspace / "node-layout.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({"workspace": str(workspace), "header_slots": result["header_slots"],
                      "sizes": {name: table["constants"] for name, table in tables.items()}},
                     indent=2))


if __name__ == "__main__":
    main()
