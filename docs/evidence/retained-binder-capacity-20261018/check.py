#!/usr/bin/env python3
"""Reconcile retained binder sources/objects without invoking native tools."""
import hashlib
import json
from pathlib import Path
import re
import struct
import tarfile

ROOT = Path(__file__).resolve().parent


def digest(raw):
    return {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}


def read_archive(name):
    with tarfile.open(ROOT / name, "r:gz") as archive:
        return {m.name: archive.extractfile(m).read()
                for m in archive.getmembers() if m.isfile()}


def elf(raw):
    assert raw[:6] == b"\x7fELF\x02\x01"
    hdr = struct.unpack_from("<HHIQQQIHHHHHH", raw, 16)
    assert hdr[0] == 1 and hdr[1] == 62  # ET_REL, EM_X86_64
    off, entsize, count, names = hdr[5], hdr[10], hdr[11], hdr[12]
    assert entsize == 64 and 0 < count < 0xFF00
    rows = [struct.unpack_from("<IIQQQQIIQQ", raw, off+i*entsize)
            for i in range(count)]
    names_raw = raw[rows[names][4]:rows[names][4]+rows[names][5]]

    def string(buf, offset):
        return buf[offset:buf.index(b"\0", offset)].decode("ascii")

    sections, symbols, relocations = [], [], []
    for i, row in enumerate(rows):
        name = string(names_raw, row[0])
        sections.append({"index": i, "name": name, "type": row[1],
                         "flags": row[2], "size": row[5], "alignment": row[8]})
        if row[1] == 2:  # SHT_SYMTAB
            assert row[9] == 24 and row[5] % 24 == 0
            strings = rows[row[6]]
            names_buf = raw[strings[4]:strings[4]+strings[5]]
            for pos in range(row[4], row[4]+row[5], 24):
                n, info, other, shndx, value, size = struct.unpack_from("<IBBHQQ", raw, pos)
                symbols.append({"name": string(names_buf, n), "binding": info >> 4,
                                "type": info & 15, "section": shndx,
                                "value": value, "size": size, "other": other})
        elif row[1] in (4, 9):
            expected = 24 if row[1] == 4 else 16
            assert row[9] == expected and row[5] % expected == 0
            relocations.append({"section": name, "count": row[5] // expected})
    assert all(not s["flags"] & 0x800 for s in sections)
    assert all(not s["name"].startswith((".gnu.lto_", ".gnu.offload_lto_", ".zdebug"))
               and s["name"] != ".gnu_object_only" for s in sections)
    return {"file": digest(raw), "sections": sections, "symbols": symbols,
            "relocations": relocations,
            "section_count": len(sections), "symbol_count": len(symbols),
            "relocation_count": sum(r["count"] for r in relocations),
            "external_names": sorted(s["name"] for s in symbols if s["binding"]),
            "allocated_bytes": sum(s["size"] for s in sections if s["flags"] & 2),
            "text_bytes": sum(s["size"] for s in sections if s["flags"] & 4)}


def outside_comments(raw):
    # Generated sources use LF; consume strings first so -- inside a literal
    # cannot be mistaken for a comment. Preserve each noncomment byte's column.
    assert b"\r" not in raw
    return re.sub(rb'"(?:[^"\n]|"")*"|--[^\n]*',
                  lambda m: b" "*len(m[0]) if m[0].startswith(b"--") else m[0], raw)


def token_locations(raw):
    result = []
    for line, text in enumerate(outside_comments(raw).split(b"\n"), 1):
        for m in re.finditer(rb'"(?:[^"\n]|"")*"|[A-Za-z0-9_]+|\S', text):
            result.append([line, m.start()+1, m[0].decode("ascii")])
    return result


def analyze(artifacts):
    cases = ["indexed-cr", "indexed-lf", "indexed-uppercase", "unindexed-proposed"]
    indexed_specs, indexed_bodies, indexed_objects = [], [], []
    result = {"cases": {}}
    for case in cases:
        stem = "b__main" if case.startswith("unindexed") else "b__main~1"
        spec = artifacts[f"cases/{case}/{stem}.ads"]
        body = artifacts[f"cases/{case}/{stem}.adb"]
        obj = artifacts[f"cases/{case}/{stem}.o"]
        ali_stem = "main" if case.startswith("unindexed") else "main~1"
        main_ali = artifacts[f"cases/{case}/{ali_stem}.ali"]
        match = re.search(rb"^U main%b\s+main.adb\s+([0-9a-f]{8})(.*)$", main_ali, re.M)
        assert match and match[1] == b"73b77761"
        versions = re.findall(rb'pragma Export \(C, u[0-9]{5}, "([^"]+)"\);', spec)
        explicit = re.findall(rb'pragma (?:Import|Export) \([^;]+, "([^"]+)"\);', spec+body)
        implicit_c = re.findall(rb'pragma (?:Import|Export) \(C, ([A-Za-z0-9_]+)\);', spec+body)
        assert all(re.fullmatch(rb"[A-Za-z0-9_]+", s) for s in explicit)
        assert not re.search(rb"\b(?:Machine_Code|Asm|Asm_Input|Asm_Output)\b", outside_comments(spec+body), re.I)
        e = elf(obj)
        assert all("@" not in s for s in e["external_names"])
        result["cases"][case] = {
            "spec": digest(spec), "body": digest(body),
            "spec_lf_lines": spec.count(b"\n"), "body_lf_lines": body.count(b"\n"),
            "main_unit_flags": match[2].decode().split(),
            "main_version": match[1].decode(),
            "version_export_count": len(versions),
            "version_exports": [v.decode() for v in versions],
            "explicit_external_names": sorted(set(n.decode() for n in explicit)),
            "implicit_c_external_names": sorted(set(n.decode() for n in implicit_c)),
            "object": e,
        }
        if case.startswith("indexed"):
            indexed_specs.append(spec)
            indexed_bodies.append(body)
            indexed_objects.append(obj)
    assert len(set(indexed_specs)) == len(set(indexed_objects)) == 1
    assert all(token_locations(indexed_bodies[0]) == token_locations(x) for x in indexed_bodies[1:])
    # Only the three workspace comment lines change in these retained cases.
    differences = []
    for body in indexed_bodies[1:]:
        different = [i for i, (a, b) in enumerate(zip(indexed_bodies[0].split(b"\n"), body.split(b"\n")), 1) if a != b]
        assert different == [194, 195, 196]
        differences.append(different)
    result["indexed_body_differing_lines"] = differences
    lines = indexed_bodies[0].split(b"\n")
    assert all(lines[i].startswith(b"   --   ") for i in range(193, 197))
    paths = [lines[193][8:]] + [lines[i][10:] for i in range(194, 197)]
    assert all(p.startswith(b"/") and all(32 <= b <= 126 for b in p) for p in paths)
    body_constant = len(indexed_bodies[0]) - sum(map(len, paths))
    assert body_constant == 7483
    q = lambda b: 4096 * ((b + 4096) // 4096)
    result["generated_source_bound"] = {
        "spec_bytes": 14556, "body_constant_bytes": body_constant,
        "path_occurrences": 4, "path_bound_example": 4096,
        "raw_combined_at_example": 14556 + body_constant + 4*4096,
        "aligned_combined_at_example": q(14556) + q(body_constant + 4*4096),
        "source_union_including_fixed_runtime_and_virtual": q(14556) + q(body_constant + 4*4096) + 20496384 + 4096,
    }
    alis = {k.removeprefix("closure/"): v for k, v in artifacts.items() if k.startswith("closure/")}
    units = sorted(u.decode() for v in alis.values() for u in re.findall(rb"^U (\S+)", v, re.M))
    assert len(units) == len(set(units))
    exports = sorted(u[:-2].replace(".", "__") + u[-1].upper() for u in units)
    assert exports == sorted(result["cases"]["indexed-cr"]["version_exports"])
    runtime_main_signatures = [k for k, v in alis.items() if k != "main~1.ali" and b"[main standard " in v]
    assert runtime_main_signatures == []
    dependencies = {}
    for name, raw in alis.items():
        deps = sorted(set(d.decode() for d in re.findall(rb"^[WYZ] \S+[ \t]+\S+[ \t]+(\S+)", raw, re.M)))
        assert all(d in alis for d in deps), (name, deps)
        dependencies[name] = deps
    reachable, todo = set(), ["main~1.ali", "s-stalib.ali"]
    while todo:
        name = todo.pop()
        if name not in reachable:
            reachable.add(name)
            todo.extend(dependencies[name])
    assert reachable == set(alis)
    result["closure"] = {"ali_count": len(alis), "unit_count": len(units),
                         "raw_bytes": sum(map(len, alis.values())),
                         "units": units, "dependencies": dependencies,
                         "runtime_main_standard_signature_matches": runtime_main_signatures}
    result["signature_hash_max_bytes"] = len("standard__main__") + 10 + 1 + 10
    return result


def main():
    manifest = json.loads((ROOT / "manifest.json").read_text())
    for name, record in manifest["archives"].items():
        raw = (ROOT / name).read_bytes()
        assert digest(raw) == record["archive"]
        members = read_archive(name)
        assert set(members) == set(record["members"])
        for member, expected in record["members"].items():
            assert digest(members[member]) == {k: expected[k] for k in ("bytes", "sha256")}
    result = analyze(read_archive("artifacts.tar.gz"))
    assert result == json.loads((ROOT / "result.json").read_text())
    print("Retained source pins, null binder projection comparisons, ALI closure and ELF inventories agree.")
    print(json.dumps({"closure": {k: v for k, v in result["closure"].items() if k in ("ali_count", "unit_count", "raw_bytes")},
                      "indexed_object": {k: v for k, v in result["cases"]["indexed-cr"]["object"].items()
                                         if k.endswith("_count") or k.endswith("_bytes")}}, sort_keys=True))


if __name__ == "__main__":
    main()
