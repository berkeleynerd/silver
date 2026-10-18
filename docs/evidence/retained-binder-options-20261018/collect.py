"""Collect completed binder-option captures; never execute a native tool."""
import argparse
import hashlib
import io
import json
from pathlib import Path
import struct
import tarfile


def identity(raw):
    return {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}


parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--prior-repo", type=Path, required=True)
parser.add_argument("--output", type=Path, required=True)
args = parser.parse_args()
assert not (args.output / "manifest.json").exists(), "Preserve the retained packet"
args.output.mkdir(parents=True, exist_ok=True)
prior = args.prior_repo / "docs/evidence"
local = Path(__file__).resolve().parents[1]
artifacts, sources, origins = {}, {}, {}


def add(group, name, path):
    group[name] = path.read_bytes()
    origins[name] = str(path)


def archive_members(path):
    with tarfile.open(path) as archive:
        return {m.name: archive.extractfile(m).read()
                for m in archive.getmembers() if m.isfile()}


old_binder = prior / "retained-binder-capacity-20261018"
output_binder = prior / "retained-linker-output-delta-20261018"
split = local / "retained-split-options-20261018"
for tag, packet in (("binder", old_binder), ("output", output_binder), ("split", split)):
    for name in ("manifest.json", "result.json") if tag != "split" else ("sources.json", "result.json"):
        add(artifacts, "predecessor/" + tag + "/" + name, packet / name)
add(artifacts, "predecessor/binder/check.py", old_binder / "check.py")
add(artifacts, "predecessor/binder/research.md", args.prior_repo / "docs/research/retained-binder-capacity.md")
add(artifacts, "predecessor/output/research.md", args.prior_repo / "docs/research/retained-linker-output-delta.md")
add(artifacts, "predecessor/split/research.md", local.parent / "research/retained-split-options.md")

baseline = archive_members(old_binder / "artifacts.tar.gz")
for name, raw in baseline.items():
    if name.startswith("lifetime-capture/") or name == "compiler-capture/invocation.json" or name == "cases/indexed-cr/b__main~1.o":
        artifacts["baseline/" + name] = raw
        origins["baseline/" + name] = str(old_binder / "artifacts.tar.gz") + ":" + name
old_output = archive_members(output_binder / "artifacts.tar.gz")
for name, raw in old_output.items():
    if name.startswith("indexed/") or name.startswith("objects/"):
        artifacts["output-before/" + name] = raw
        origins["output-before/" + name] = str(output_binder / "artifacts.tar.gz") + ":" + name

for packet in (old_binder, output_binder, split):
    for name, raw in archive_members(packet / "sources.tar.gz").items():
        if packet == split or name in {
                "gcc/ggc-page.cc", "gcc/ggc-common.cc", "gcc/ggc.h",
                "gcc/stringpool.cc", "libcpp/symtab.cc", "gcc/tree.cc", "gcc/varasm.cc",
                "gcc/ada/gcc-interface/trans.cc", "gcc/ada/gcc-interface/decl.cc",
                "gcc/ada/gcc-interface/utils.cc"}:
            assert name not in sources or sources[name] == raw, name
            sources[name] = raw
            origins[name] = str(packet / "sources.tar.gz") + ":" + name

runroot = Path("/home/canto/src/github.com/berkeleynerd/silver/.git/silver-runs/linux-x86_64/d140f139bb2e1ef1/runs")
for tag, path, run_id in (
        ("null", Path("/tmp/silver-binder-split-20261018"), "20261018T141731-1615498c5848"),
        ("output", Path("/tmp/silver-binder-output-split-20261018"), "20261018T141951-b4f17b9f45aa")):
    for p in sorted(path.iterdir()):
        if p.is_file():
            add(artifacts, tag + "/" + p.name, p)
    for p in sorted((path / "capture").iterdir()):
        if p.is_file():
            add(artifacts, tag + "/capture/" + p.name, p)
    plan = json.loads((path / "invocation.json").read_text())
    for p in sorted(Path(plan["cwd"]).iterdir()):
        if p.is_file():
            add(artifacts, tag + "/output/" + p.name, p)
    for name in ("events.jsonl", "native.log"):
        add(artifacts, tag + "/managed/" + name, runroot / run_id / name)
    # Pin all selected actual source and executable inputs after the run.
    # Executables are checked here; only their identities are retained.
    for name, expected in plan["input_identities"].items():
        p = Path(name)
        assert identity(p.read_bytes()) == expected, name
        if p.suffix in (".ads", ".adb") and "adainclude" in p.parts:
            add(artifacts, "runtime/" + p.name, p)

# Read only the installed ELF: retain the default-parameter setters, constants
# and their link to the collector's already retained option-field loads.
plan = json.loads(artifacts["null/invocation.json"])
binary = Path(plan["gnat1"]).read_bytes()
mapping = json.loads(artifacts["null/executable-map.json"])
assert identity(binary)["sha256"] == mapping["binary_sha256"]
defaults = {"binary_sha256": identity(binary)["sha256"], "windows": []}
for name, address, size in (
        ("init_ggc_heuristics", 0xf80d00, 374),
        ("ggc_min_expand_heuristic", 0xf7fc50, 155),
        ("double_constants", 0x2c3e760, 80),
        ("float_hundred", 0x2a1dc04, 4)):
    segment, = [s for s in mapping["load_segments"] if s["address"] <= address < s["address"] + s["file_bytes"]]
    offset = address - segment["address"] + segment["offset"]
    raw = binary[offset:offset + size]
    key = "defaults/" + name + ".bin"
    artifacts[key] = raw
    origins[key] = str(Path(plan["gnat1"])) + ":" + hex(address)
    defaults["windows"].append({"file": key, "address": hex(address), "file_offset": offset, **identity(raw)})
assert struct.unpack("<10d", artifacts["defaults/double_constants.bin"]) == (1/1024**3, 70., 30., 1/1024, 1/8, 1/4, 20480., 100., 4096., 131072.)
assert struct.unpack("<f", artifacts["defaults/float_hundred.bin"]) == (100.,)
artifacts["defaults/mapping.json"] = (json.dumps(defaults, indent=2) + "\n").encode()
origins["defaults/mapping.json"] = "Read-only installed-ELF reconciliation in collect.py"

manifest = {"scope": "Two targeted Linux x86-64 binder-option lifetime captures; no production change", "archives": {}}
for filename, group in (("artifacts.tar.gz", artifacts), ("sources.tar.gz", sources)):
    with tarfile.open(args.output / filename, "w:gz") as archive:
        for name, raw in sorted(group.items()):
            info = tarfile.TarInfo(name)
            info.size, info.mtime, info.mode = len(raw), 0, 0o644
            archive.addfile(info, io.BytesIO(raw))
    manifest["archives"][filename] = {
        **identity((args.output / filename).read_bytes()),
        "members": [{"path": name, **identity(raw), "origin": origins[name]}
                    for name, raw in sorted(group.items())]}
(args.output / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
print(json.dumps({"artifacts": len(artifacts), "sources": len(sources), "output": str(args.output)}))
