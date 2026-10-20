#!/usr/bin/env python3
"""Focused new source/native-byte and arithmetic check. No predecessor replay.

--write freezes new projections and first focused-check result. The source
argument remains reviewed prose; textual checks do not prove OCaml semantics.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re
import struct
import subprocess
import tarfile
import time
from compose import compose, candidate_interface

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
WHY = "docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz"
OCAML = "docs/evidence/retained-why-formatter-prefix-repair-20261019/ocaml-source.tar.gz"
ZDIR = "docs/evidence/retained-why-interval-native-effects-20261019/"
REV = "8eb41f72ded84df884c3671734c947f612091f84"
SELECT = {
    WHY: {
        "why3/src/core/decl.ml": [(295, 300), (340, 367), (411, 420)],
        "why3/src/core/term.ml": [(24, 36), (62, 65), (256, 402), (536, 541)],
        "why3/src/core/ty.ml": [(75, 82), (300, 303)],
        "why3/src/core/ident.ml": [(16, 31), (165, 192)],
        "why3/src/util/hashcons.ml": [(33, 56)],
        "why3/src/util/extmap.ml": [(101, 169), (359, 378), (492, 507)],
        "why3/src/util/extset.ml": [(57, 73)],
        "why3/src/util/wstdlib.ml": [(14, 19), (61, 99)],
        "why3/src/util/weakhtbl.ml": [(50, 58)],
        "why3/src/util/lists.ml": [(38, 46)],
        "why3/src/util/loc.ml": [(67, 71), (110, 112)],
        "why3/src/util/constant.ml": [(15, 32)],
        "why3/src/util/number.ml": [(18, 64)],
        "why3/src/util/bigInt.ml": [(11, 16)],
    },
    OCAML: {
        f"ocaml-{REV}/stdlib/weak.ml": [(272, 294)],
        f"ocaml-{REV}/stdlib/list.ml": [(144, 155), (170, 175)],
        f"ocaml-{REV}/stdlib/option.ml": [(28, 37)],
        f"ocaml-{REV}/runtime/compare.c": [(28, 110), (119, 160), (180, 213), (282, 316)],
    },
}
PLAIN = {
    ZDIR + "big_int_Z.ml": [(78, 83)],
    ZDIR + "z.ml": [(228, 234)],
    ZDIR + "caml_z.c": [(77, 91), (114, 164), (211, 223), (365, 395), (1259, 1306)],
}


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def save(name, obj):
    (HERE / name).write_text(json.dumps(obj, indent=2, sort_keys=True) + "\n")


def source_projection():
    records = {}
    for archive, members in SELECT.items():
        with tarfile.open(ROOT / archive) as tar:
            for member, ranges in members.items():
                data = tar.extractfile(member).read()
                lines = data.decode().splitlines(keepends=True)
                records[member] = {"archive": archive, "identity": identity(data),
                    "excerpts": [{"first": a, "last": b, "text": "".join(lines[a-1:b])}
                                 for a, b in ranges]}
    for path, ranges in PLAIN.items():
        data = (ROOT / path).read_bytes()
        lines = data.decode().splitlines(keepends=True)
        records[path] = {"identity": identity(data),
            "excerpts": [{"first": a, "last": b, "text": "".join(lines[a-1:b])}
                         for a, b in ranges]}
    return records


def elf_symbol(data, wanted):
    assert data[:6] == b"\x7fELF\x02\x01"
    off = struct.unpack_from("<Q", data, 40)[0]
    width, count = struct.unpack_from("<HH", data, 58)
    assert width == 64
    sections = [struct.unpack_from("<IIQQQQIIQQ", data, off+i*width) for i in range(count)]
    found = set()
    for sec in sections:
        if sec[1] not in (2, 11):
            continue
        st = sections[sec[6]]
        names = data[st[4]:st[4]+st[5]]
        for pos in range(sec[4], sec[4]+sec[5], sec[9]):
            ni, info, other, si, address, size = struct.unpack_from("<IBBHQQ", data, pos)
            name = names[ni:names.index(0, ni)].decode()
            if name == wanted and si:
                s = sections[si]
                assert s[1] != 8 and s[3] <= address and address + size <= s[3] + s[5]
                start = s[4] + address - s[3]
                found.add((address, data[start:start+size]))
    assert len(found) == 1
    return found.pop()


def native_projection(binary, objdump):
    data = Path(binary).read_bytes()
    assert identity(data) == {"bytes": 24561432, "sha256": "7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368"}
    address, body = elf_symbol(data, "ml_z_compare")
    output = subprocess.check_output([objdump, "-dw", "--disassemble=ml_z_compare", binary], text=True)
    rows = []
    for line in output.splitlines():
        m = re.match(r"\s*([0-9a-f]+):\s+((?:[0-9a-f]{2} )+)\s*(.*)", line)
        if m:
            rows.append({"address": int(m[1], 16), "bytes": m[2].strip(), "asm": m[3]})
    assert rows[0]["address"] == address
    cursor = address
    for row in rows:
        raw = bytes.fromhex(row["bytes"])
        assert row["address"] == cursor
        assert body[cursor-address:cursor-address+len(raw)] == raw
        cursor += len(raw)
    assert cursor == address + len(body)
    return {"binary_identity": identity(data), "symbol": "ml_z_compare", "address": address,
            "bytes": body.hex(), "instructions": rows,
            "method": "new static ELF read and bounded objdump; target never executed"}


def check_native(record):
    body = bytes.fromhex(record["bytes"])
    cursor = record["address"]
    assert cursor == 0x9AFBA0 and len(body) == 266
    for row in record["instructions"]:
        data = bytes.fromhex(row["bytes"])
        assert row["address"] == cursor
        assert body[cursor-record["address"]:cursor-record["address"]+len(data)] == data
        cursor += len(data)
        asm = row["asm"]
        assert not re.search(r"\b(call|push|pop|syscall|int)\b", asm)
        # AT&T memory destinations would contain parentheses after the final comma.
        if not asm.startswith(("nop", "cs nop", "data16")) and "," in asm:
            assert "(" not in asm.rsplit(",", 1)[1]
        if re.match(r"j\w+\s", asm):
            target = int(asm.split()[1], 16)
            assert record["address"] <= target < record["address"] + len(body)
    assert cursor == record["address"] + len(body)


def source_controls(records):
    def text(name):
        return "".join(r["text"] for r in records[name]["excerpts"])
    weak = text(f"ocaml-{REV}/stdlib/weak.ml")
    assert "Some v when H.equal v d" in weak and "let merge t d" in weak
    term = text("why3/src/core/term.ml")
    compare = term[term.index("let rec descend"):term.index("let t_hash_strict")]
    for forbidden in ("id_register", "id_clone", "create_vsymbol", "t_open", ".hashcons", ".unique", "incr ", " := ", " <- "):
        assert forbidden not in compare
    assert "Some t -> descend vml t" in compare
    assert "if attr then comp_raise (Sattr.compare" in compare
    assert "~trigger:true ~attr:true ~loc:true ~const:true" in term
    number = text("why3/src/util/number.ml")
    structural = number[number.index("  if structural then"):number.index("  else\n    let p2_min")]
    assert structural.count("BigInt.compare") == 3 and "pow_int" not in structural
    # Mutation/orientation controls target checks that matter to this new claim.
    try:
        source_controls_orientation(weak.replace("H.equal v d", "H.equal d v"))
    except AssertionError:
        pass
    else:
        raise AssertionError("orientation mutation accepted")


def source_controls_orientation(weak):
    assert "Some v when H.equal v d" in weak


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true")
    parser.add_argument("--binary")
    parser.add_argument("--objdump")
    args = parser.parse_args()
    start = time.monotonic()
    if args.write:
        dependencies = list(SELECT) + list(PLAIN) + [
            "docs/evidence/retained-why-returned-storage-20261020/result.json",
            "docs/research/retained-why-returned-storage.md",
            ZDIR + "zarith-retrieval.json",
            "docs/evidence/retained-why-formatter-prefix-repair-20261019/inputs.json",
        ]
        save("inputs.json", {"base": "f1268fbb66b8285713ac315fa1b9d7ca6f73ba81",
                             "files": {p: identity((ROOT/p).read_bytes()) for p in dependencies}})
    inputs = json.loads((HERE / "inputs.json").read_text())
    for path, expected in inputs["files"].items():
        assert identity((ROOT / path).read_bytes()) == expected, path
    sources = source_projection()
    if args.write:
        save("source-witnesses.json", sources)
        assert args.binary and args.objdump
        save("native-witness.json", native_projection(args.binary, args.objdump))
    else:
        assert sources == json.loads((HERE / "source-witnesses.json").read_text())
    source_controls(sources)
    check_native(json.loads((HERE / "native-witness.json").read_text()))
    for value in (-1, True, 1.5):
        try:
            candidate_interface(value, 8)
        except ValueError:
            pass
        else:
            raise AssertionError("invalid arithmetic input accepted")
    try:
        candidate_interface(99, (1 << 62)-2)
    except ValueError:
        pass
    else:
        raise AssertionError("unrepresentable private-map arithmetic accepted")
    assert candidate_interface(1, 0)["bnd_upper"] == 0
    result = compose()
    if args.write:
        save("result.json", result)
    else:
        assert result == json.loads((HERE / "result.json").read_text())
    check = {"ok": True, "source_files": len(sources), "predecessor_checks_run": 0,
             "native_targets_run": 0, "new_static_native_bodies": 1,
             "elapsed_seconds": time.monotonic()-start,
             "machine_checked_operational_semantics": False}
    if args.write:
        save("check-result.json", check)
    print(json.dumps(check, sort_keys=True))


if __name__ == "__main__":
    main()
