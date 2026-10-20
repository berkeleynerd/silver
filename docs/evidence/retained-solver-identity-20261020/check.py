#!/usr/bin/env python3
"""Check retained joins; optionally read the installed files. Never execute them."""
from pathlib import Path
import argparse
import gzip
import hashlib
import json
import re
import stat
import struct
import tarfile
import time
import tomllib

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def load(name):
    return json.loads((HERE / name).read_text())


def identity(raw):
    return {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}


def elf_metadata(raw):
    assert raw[:6] == b"\x7fELF\x02\x01"
    h = struct.unpack_from("<16sHHIQQQIHHHHHH", raw)
    ph = [struct.unpack_from("<IIQQQQQQ", raw, h[5] + i*h[9])
          for i in range(h[10])]
    sh = [struct.unpack_from("<IIQQQQIIQQ", raw, h[6] + i*h[11])
          for i in range(h[12])]
    strings = raw[sh[h[13]][4]:sh[h[13]][4]+sh[h[13]][5]]

    def z(data, offset):
        return data[offset:data.index(b"\0", offset)].decode()

    sections = {z(strings, s[0]): s for s in sh}
    result = {
        "class": 64, "endianness": "little", "type": h[1],
        "machine": h[2], "osabi": raw[7],
        "interpreter": [raw[p[2]:p[2]+p[5]].rstrip(b"\0").decode()
                        for p in ph if p[0] == 3],
        "dynamic_section_present": ".dynamic" in sections,
        "needed": [], "rpath": [], "runpath": [],
    }
    for name in [".note.gnu.build-id", ".comment"]:
        s = sections[name]
        data = raw[s[4]:s[4]+s[5]]
        if name == ".note.gnu.build-id":
            namesz, descsz, typ = struct.unpack_from("<III", data)
            offset = 12 + (namesz+3)//4*4
            assert data[12:12+namesz] == b"GNU\0" and typ == 3
            result["gnu_build_id"] = data[offset:offset+descsz].hex()
        else:
            result["compiler_comments"] = [x.decode() for x in data.split(b"\0") if x]
    if ".dynamic" in sections:
        s, ds = sections[".dynamic"], sections[".dynstr"]
        data = raw[ds[4]:ds[4]+ds[5]]
        for offset in range(s[4], s[4]+s[5], 16):
            tag, value = struct.unpack_from("<qQ", raw, offset)
            if tag in [1, 15, 29]:
                result[{1: "needed", 15: "rpath", 29: "runpath"}[tag]].append(z(data, value))
    return result


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--installed-root", type=Path,
                        help="also read/hash the exact installed package; execute nothing")
    args = parser.parse_args()
    started = time.monotonic()
    inputs, inv = load("inputs.json"), load("inventory.json")
    for path, expected in inputs["repository_files"].items():
        assert identity((ROOT / path).read_bytes()) == expected, path
    retained = {}
    for archive, rows in inputs["archive_members"].items():
        with tarfile.open(ROOT / archive) as stream:
            for member, expected in rows.items():
                raw = stream.extractfile(member).read()
                assert identity(raw) == expected, (archive, member)
                retained[archive, member] = raw

    for witness in load("source-witnesses.json"):
        raw = retained[witness["archive"], witness["member"]]
        assert identity(raw) == witness["identity"]
        lines = raw.decode().splitlines()
        for excerpt in witness["excerpts"]:
            first, last = excerpt["first_line"], excerpt["last_line"]
            assert 1 <= first <= last <= len(lines)
            assert "\n".join(lines[first-1:last])+"\n" == excerpt["text"]

    snapshots = {}
    for row in inv["package_snapshots"]:
        raw = (HERE / row["retained_path"]).read_bytes()
        if row["retained_path"].endswith(".gz"):
            raw = gzip.decompress(raw)
        assert identity(raw) == row["identity"]
        snapshots[row["installed_relative_path"]] = raw
    manifest = tomllib.loads(snapshots["alire.toml"].decode())
    assert manifest["name"] == "gnatprove" and manifest["version"] == "16.1.0"
    assert manifest["origin"]["binary"] is True
    assert manifest["origin"]["hashes"] == [
        "sha256:82528bef29857e239373fcc36732837d743f5a00805d502c70455422ffc97191"]
    assert snapshots["alire.toml"] == snapshots["alire/alire.toml.upstream"]
    package_config = json.loads(snapshots["share/spark/config/gnatprove.conf"])
    selected = {p["shortcut"]: {k: p[k] for k in [
        "executable", "args", "args_time", "args_steps", "driver", "name", "shortcut", "version"]}
        for p in package_config["provers"] if p["shortcut"] in ["cvc5", "z3", "altergo"]}
    assert selected == inv["selected_provers"] and package_config["memlimit"] == 0

    response = "docs/evidence/retained-producer-response-20261018"
    prefix = "docs/evidence/retained-producer-prefix-per-check-20261018"
    old_identity = json.loads((ROOT / response / "identity.json").read_text())
    for name, row in inv["source_candidates"].items():
        assert row["installed_build_recipe_attached"] is False
        assert row["binary_source_correspondence_attached"] is False
        for source in row["retained_source_files"]:
            assert source in old_identity["files"] and source["revision"] == row["revision"]
            assert identity(retained[response+"/sources.tar.gz", source["path"]]) == {
                k: source[k] for k in ["bytes", "sha256"]}
        assert row["binary_embedded_exact_revision_match"] == (name == "cvc5")
        binary = next(x for x in inv["binaries"] if x["name"] == name)
        embedded = [x["text"] for x in binary["ascii_lowercase_40hex_tokens"]]
        assert embedded == ([row["revision"]] if name == "cvc5" else [])

    drivers = load("drivers.json")
    assert drivers["production_adopted"] is False
    for variant in ["installed", "corrected_private"]:
        graph = drivers[variant]
        assert len(graph) == 14
        reachable, todo = set(), list(drivers["roots"])
        while todo:
            name = todo.pop()
            if name in reachable:
                continue
            reachable.add(name)
            row = graph[name]
            raw = retained[row["archive"], row["member"]]
            assert identity(raw) == row["identity"]
            assert re.findall(r'^import "([^"]+)"', raw.decode(), re.M) == row["imports"]
            assert re.findall(r'^steps .*$', raw.decode(), re.M) == row["step_directives"]
            todo.extend(row["imports"])
        assert reachable == set(graph)
    deleted = 0
    for name, row in drivers["corrected_private"].items():
        if not row["private"]:
            assert row == drivers["installed"][name]
            continue
        original_name = "cvc5.gen" if name == "silver_cvc5_no_steps.gen" else name
        old = drivers["installed"][original_name]
        raw = retained[old["archive"], old["member"]]
        deleted += sum(line.startswith(b"steps ") for line in raw.splitlines())
        raw = b"".join(line for line in raw.splitlines(keepends=True) if not line.startswith(b"steps "))
        if name == "cvc5_gnatprove.drv":
            raw = raw.replace(b'import "cvc5.gen"', b'import "silver_cvc5_no_steps.gen"')
        assert raw == retained[row["archive"], row["member"]]
    assert deleted == drivers["deleted_step_directives"] == 6
    assert not any(row["step_directives"] for row in drivers["corrected_private"].values())
    assert drivers["corrected_overlay_base"] == "[main]\nmagic = 14\n"

    launch = load("launch.json")
    attachment = json.loads((ROOT / "docs/evidence/retained-why-server-record-capacity-20261020/attachment.json").read_text())
    assert launch["packaged_executable_resolution_attached"] is False
    assert launch["historical_missing_binary_claim"] is False
    assert len(launch["retained_cases"]) == 5
    for row in launch["retained_cases"]:
        process = json.loads(retained[row["archive"], row["process_member"]])
        server = json.loads(retained[row["archive"], row["server_member"]])
        assert process == row["process"] and server == row["server"]
        plan = json.loads(retained[row["plan_archive"], row["plan_member"]])
        spec = next(x for x in plan["inputs"] if x["name"] == row["case"])
        assert spec == row["spec"]
        assert spec["argv"] == process["argv"] and spec["environment"] == process["environment"]
        assert server["actual_argv"] == server["argv"] == spec["server"]["argv"]
        assert server["actual_environment"] == server["environment"] == {"PATH": "/usr/bin:/bin", "LC_ALL": "C"}
        assert server["argv"][-2:] == ["-j", "1"] and "-j" not in process["argv"]
        assert "--memlimit" not in process["argv"]
        base = retained[row["archive"], row["base_config_member"]]
        assert identity(base) == row["base_config_identity"]
        assert base == retained[prefix+"/observations.tar.gz", "put_line/why3.conf"]
        joined = next(x for x in attachment["cases"] if x["case"] == row["case"])
        assert process["pid"] == joined["pid"] and spec["server"] == joined["server_launch"]
        for shortcut, p in selected.items():
            command = " ".join([p["executable"], *p["args"]])
            assert joined["commands"][shortcut] == command
            assert 'command = "'+command+'"' in base.decode()

    installed_checked = args.installed_root is not None
    if installed_checked:
        for snapshot in inv["package_snapshots"]:
            assert (args.installed_root / snapshot["installed_relative_path"]).read_bytes() == snapshots[snapshot["installed_relative_path"]]
        for row in inv["binaries"]:
            path = args.installed_root / row["installed_relative_path"]
            assert str(path) == row["path"] and str(path.resolve()) == row["realpath"]
            raw = path.read_bytes()
            assert identity(raw) == row["identity"] and elf_metadata(raw) == row["elf"]
            assert stat.S_ISREG(path.lstat().st_mode) == row["regular_file"]
            assert path.is_symlink() == row["symlink"] is False
            assert oct(stat.S_IMODE(path.stat().st_mode)) == row["mode"]
            for string in row["embedded_strings"]:
                token = string["text"].encode()+b"\0"
                assert [m.start() for m in re.finditer(re.escape(token), raw)] == string["offsets"]
            assert [{"text": m.group().decode(), "offset": m.start()} for m in re.finditer(
                rb"(?<![0-9a-f])[0-9a-f]{40}(?![0-9a-f])", raw)] == row["ascii_lowercase_40hex_tokens"]
        for name, row in drivers["installed"].items():
            assert identity((args.installed_root / "libexec/spark/share/why3/drivers" / name).read_bytes()) == row["identity"]

    for doc in [HERE / "README.md", ROOT / "docs/research/retained-solver-identity.md"]:
        for target in re.findall(r"\[[^\]]*\]\(([^)]+)\)", doc.read_text()):
            if "://" not in target:
                assert (doc.parent / target.split("#", 1)[0]).exists(), (doc, target)
    print(json.dumps({"retained_joins": "pass", "local_document_links": "pass",
                      "installed_static_identity_checks": "pass" if installed_checked else "not requested",
                      "binaries": 3, "driver_closure_files_each": 14, "retained_cases": 5,
                      "repository_inputs": len(inputs["repository_files"]),
                      "archive_members": len(retained), "solver_execution": False,
                      "elapsed_seconds": time.monotonic()-started}, sort_keys=True))


if __name__ == "__main__":
    main()
