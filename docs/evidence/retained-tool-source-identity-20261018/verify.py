#!/usr/bin/env python3
"""Verify retained release records and inspect source-identifying metadata only."""
import argparse
import base64
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile

RECIPE = "0334dd54a2c479faa3dfad47a911373581b11739"
SPARK = "42554fc241fcd1fdf08d3a2feccb3f86912acbc0"
ARCHIVE = "82528bef29857e239373fcc36732837d743f5a00805d502c70455422ffc97191"
ROOT = Path(__file__).resolve().parent


def sha(data):
    return hashlib.sha256(data).hexdigest()


def load(name):
    return json.loads((ROOT / name).read_text())


def line_table_metadata(raw):
    """Read ELF64/DWARF5 line-table field descriptions, not executable code."""
    assert raw[:6] == b"\x7fELF\x02\x01"
    header = struct.unpack_from("<16sHHIQQQIHHHHHH", raw)
    sections = [struct.unpack_from("<IIQQQQIIQQ", raw,
                header[6] + i * header[11]) for i in range(header[12])]
    item = sections[header[13]]
    names = raw[item[4]:item[4] + item[5]]
    sections = {names[item[0]:].split(b"\0", 1)[0].decode():
                raw[item[4]:item[4] + item[5]] for item in sections}
    data = sections[".debug_line"]

    def uleb(pos):
        value, shift = 0, 0
        while True:
            byte = data[pos]
            pos += 1
            value |= (byte & 127) << shift
            if not byte & 128:
                return value, pos
            shift += 7

    def formats(pos):
        count = data[pos]
        pos += 1
        result = []
        for _ in range(count):
            content, pos = uleb(pos)
            form, pos = uleb(pos)
            result.append((content, form))
        return result, pos

    offset = 0
    versions, file_formats = Counter(), Counter()
    while offset < len(data):
        length = struct.unpack_from("<I", data, offset)[0]
        assert length != 0xffffffff  # This selected metadata uses DWARF32.
        version = struct.unpack_from("<H", data, offset + 4)[0]
        versions[version] += 1
        assert version == 5
        pos = offset + 12
        opcode_base = data[pos + 5]
        pos += 6 + opcode_base - 1
        directory_formats, pos = formats(pos)
        count, pos = uleb(pos)
        for _ in range(count):
            for _, form in directory_formats:
                if form in (0x1f, 0x0e):  # line_strp / strp, DWARF32
                    pos += 4
                elif form == 0x0f:  # udata
                    _, pos = uleb(pos)
                elif form == 0x08:  # string
                    pos = data.index(0, pos) + 1
                else:
                    raise AssertionError(("unhandled directory form", form))
        fields, pos = formats(pos)
        file_formats[tuple(fields)] += 1
        offset += length + 4
    assert offset == len(data)
    # DW_LNCT_path=1, directory_index=2; no timestamp, size or MD5 field.
    assert set(file_formats) == {((1, 31), (2, 15))}
    return {"versions": dict(versions), "tables": sum(versions.values()),
            "file_entry_fields": ["DW_LNCT_path/DW_FORM_line_strp",
                                  "DW_LNCT_directory_index/DW_FORM_udata"],
            "file_checksums_present": False}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--installation", type=Path, required=True)
    args = parser.parse_args()
    for request in load("requests.json")["requests"]:
        assert sha((ROOT / request["file"]).read_bytes()) == request["sha256"]
    repo = ROOT.parents[2]
    retained = repo / "docs/evidence/unbounded-programs/frontend-representation-20261017/toolchain/raw-evidence.tar.gz"
    with tarfile.open(retained) as old:
        old_tag = json.load(old.extractfile("gnatprove-tag.json"))
        old_release = json.load(old.extractfile("gnatprove-release.json"))
        old_recipe = old.extractfile("spark-recipe.source").read()
        assert json.load(old.extractfile("fsf-builds-repo.json"))["full_name"] == "alire-project/GNAT-FSF-builds"
        assert old_tag["object"]["sha"] == RECIPE
        assert old_recipe == (ROOT / "spark2014.anod").read_bytes()
    release = load("release.json")
    assert release["id"] == old_release["id"] == 345417954
    asset = next(a for a in release["assets"] if a["name"] == "gnatprove-x86_64-linux-16.1.0-1.tar.gz")
    assert asset["digest"] == "sha256:" + ARCHIVE
    assert asset["id"] == 458798534 and asset["size"] == 472919963
    assert load("tag.json")["object"]["sha"] == RECIPE
    assert load("spark-branch.json")["commit"]["sha"] == SPARK
    run = load("build-run.json")
    assert run["id"] == 28247767502 and run["head_sha"] == RECIPE
    assert run["repository"]["full_name"] == "alire-project/GNAT-FSF-builds"
    assert run["event"] == "workflow_dispatch" and run["conclusion"] == "success"
    job = next(j for j in load("jobs.json")["jobs"] if j["id"] == 84010188140)
    assert job["run_id"] == run["id"] and job["conclusion"] == "success"
    assert job["name"] == "SPARK (ubuntu-22.04)"
    upload = next(s for s in job["steps"] if s["name"] == "Release GNATprove")
    assert upload["conclusion"] == "success"
    assert upload["started_at"] <= asset["created_at"] <= asset["updated_at"] <= upload["completed_at"]
    assert load("artifacts.json")["total_count"] == 0
    assert load("linux-job-log-response.json")["status"] == "410"

    tree_record = load("recipe-tree.json")
    assert tree_record["sha"] == RECIPE and tree_record["truncated"] is False
    tree = {e["path"]: e["sha"] for e in tree_record["tree"]}
    decoded = []
    for name in ("workflow", "package-recipe", "common-recipe", "build-helper", "release-helper"):
        contents = load(name + ".json")
        data = base64.b64decode(contents["content"])
        blob = hashlib.sha1(b"blob " + str(len(data)).encode() + b"\0" + data).hexdigest()
        assert blob == contents["sha"] == tree[contents["path"]]
        assert data == (ROOT / (name + ".source")).read_bytes()
        decoded.append({"path": contents["path"], "git_blob_sha1": blob, "sha256": sha(data)})
    recipe_blob = hashlib.sha1(b"blob " + str(len(old_recipe)).encode() + b"\0" + old_recipe).hexdigest()
    assert recipe_blob == tree["specs/spark2014.anod"]

    installation = args.installation / ".tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef"
    manifest = (installation / "alire.toml").read_bytes()
    assert manifest == (ROOT / "installed-alire.toml").read_bytes()
    assert ARCHIVE.encode() in manifest
    assert asset["browser_download_url"].encode() in manifest
    binaries = []
    for name in ("bin/gnatprove", "libexec/spark/bin/gnat2why"):
        raw = (installation / name).read_bytes()
        revisions = [m.group().decode() for m in re.finditer(
            rb"(?<![0-9a-fA-F])[0-9a-fA-F]{40}(?![0-9a-fA-F])", raw)]
        assert not revisions
        binaries.append({"path": name, "bytes": len(raw), "sha256": sha(raw),
                         "standalone_40_hex_ascii_sequences": revisions,
                         "dwarf_line_metadata": line_table_metadata(raw)})
    result = {
        "scope": "Read-only package/release/build records and shipped identifying metadata. No rebuild, compiler/prover run or binary attestation.",
        "upstream_repository": "alire-project/GNAT-FSF-builds",
        "release_id": release["id"], "asset_id": asset["id"],
        "archive_sha256": ARCHIVE, "recipe_commit": RECIPE,
        "build_run_id": run["id"], "linux_job_id": job["id"],
        "linux_release_step": upload,
        "candidate_spark_revision": SPARK,
        "source_identity_established": False,
        "missing_link": "The surviving records do not identify the bytes/revision of the floating SPARK fsf-16 tarball consumed by the June 26 build.",
        "job_log_http_status": 410, "retained_run_artifacts": 0,
        "recipe_sources_verified_against_git_tree": decoded,
        "installed_binary_metadata": binaries,
        "qualifications": ["Current branch commit date is not historical branch-resolution evidence.",
                           "Release asset digest matches Alire selection; original binary archive was not downloaded or independently unpacked in this check.",
                           "Absence of a 40-hex ASCII sequence is limited to that encoding; DWARF inspection covers line-table fields only."]}
    (ROOT / "results.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({"records_verified": True, "source_identity_established": False,
                      "line_tables": [x["dwarf_line_metadata"]["tables"] for x in binaries]}))


if __name__ == "__main__":
    main()
