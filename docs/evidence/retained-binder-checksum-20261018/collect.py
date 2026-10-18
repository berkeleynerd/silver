"""Retain checksum-ingress sources and predecessor data; execute no native tool."""
import argparse
import gzip
import hashlib
import io
import json
from pathlib import Path
import tarfile


def identity(raw):
    return {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}


p = argparse.ArgumentParser(description=__doc__)
p.add_argument("--ada-root", type=Path, required=True)
p.add_argument("--gcc-root", type=Path, required=True)
p.add_argument("--prior-packet", type=Path, required=True)
p.add_argument("--output", type=Path, required=True)
a = p.parse_args()
assert not (a.output / "manifest.json").exists(), "Preserve the retained packet"
a.output.mkdir(parents=True, exist_ok=True)
files, origins = {}, {}
ada_manifest = a.ada_root / "complete-source-manifest.json"
gcc_manifest = a.gcc_root / "manifest.json"
ada = json.loads(ada_manifest.read_bytes())
gcc = json.loads(gcc_manifest.read_bytes())
assert ada["commit"] == gcc["commit"]
for tag, manifest_path in (("ada", ada_manifest), ("gcc", gcc_manifest)):
    files["corpus/" + tag + "-manifest.json"] = manifest_path.read_bytes()
    origins["corpus/" + tag + "-manifest.json"] = str(manifest_path)
for tag, corpus, root, names in (
    ("ada", ada, a.ada_root / "gcc/ada", ["scng.adb", "uintp.ads", "uintp.adb", "libgnat/g-htable.adb", "libgnat/g-htable.ads", "par-ch4.adb", "sem_eval.adb", "sem_res.adb", "gcc-interface/cuintp.cc", "gcc-interface/trans.cc"]),
    ("gcc", gcc, a.gcc_root, ["gcc/tree.cc", "gcc/fold-const.cc", "gcc/hash-table.h", "gcc/params.opt", "gcc/tree-core.h", "gcc/ggc-page.cc"])):
    rows = {r["path"]: r for r in corpus["files"]}
    for name in names:
        raw = (root / name).read_bytes()
        assert identity(raw) == {k: rows[name][k] for k in ("bytes", "sha256")}
        target = "gcc/ada/" + name if tag == "ada" else name
        files[target] = raw
        origins[target] = str(root / name)
for name in ("manifest.json", "result.json"):
    files["predecessor/" + name] = (a.prior_packet / name).read_bytes()
    origins["predecessor/" + name] = str(a.prior_packet / name)
prior_manifest = json.loads(files["predecessor/manifest.json"])
prior_archive = a.prior_packet / "artifacts.tar.gz"
assert identity(prior_archive.read_bytes()) == {k: prior_manifest["archives"]["artifacts.tar.gz"][k] for k in ("bytes", "sha256")}
with tarfile.open(prior_archive) as archive:
    for name in ("output/output/b__main~1.ads", "output/invocation.json"):
        raw = archive.extractfile(name).read()
        row, = [r for r in prior_manifest["archives"]["artifacts.tar.gz"]["members"] if r["path"] == name]
        assert identity(raw) == {k: row[k] for k in ("bytes", "sha256")}
        files["predecessor/" + name] = raw
        origins["predecessor/" + name] = str(prior_archive) + ":" + name
buf = io.BytesIO()
with tarfile.open(fileobj=buf, mode="w", format=tarfile.GNU_FORMAT) as archive:
    for name, raw in sorted(files.items()):
        item = tarfile.TarInfo(name)
        item.size, item.mode, item.mtime = len(raw), 0o644, 0
        archive.addfile(item, io.BytesIO(raw))
packed = gzip.compress(buf.getvalue(), mtime=0)
(a.output / "inputs.tar.gz").write_bytes(packed)
manifest = {"upstream_commit": ada["commit"], "archive": identity(packed),
            "files": [{"path": n, **identity(raw), "origin": origins[n]} for n, raw in sorted(files.items())]}
(a.output / "manifest.json").write_text(json.dumps(manifest, indent=2) + "\n")
print(json.dumps({"files": len(files), "archive_bytes": len(packed)}))
