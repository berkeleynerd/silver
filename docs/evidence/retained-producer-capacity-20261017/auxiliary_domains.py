#!/usr/bin/env python3
"""Check producer auxiliary source domains; never executes a toolchain."""

import argparse
import collections
import hashlib
import json
from pathlib import Path
import re
import tarfile


ROOT = Path(__file__).resolve().parent


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def clean(source):
    return re.sub(r'"(?:[^"\n]|"")*"|--[^\n]*',
                  lambda m: " " * len(m.group()), source)


def enum_count(source, name):
    body = re.search(r"\btype " + name + r" is\s*\((.*?)\);",
                     clean(source), re.S).group(1)
    return len(re.findall(r"\b[A-Za-z][A-Za-z_0-9]*\b", body))


def calls(source):
    code = clean(source)
    stack = []
    result = []
    for match in re.finditer(
            r"\b[A-Za-z][A-Za-z_0-9]*(?:\.[A-Za-z][A-Za-z_0-9]*)*\b|[()]",
            code):
        token = match.group()
        prefix = code[max(0, match.start() - 256):match.start()].rstrip()
        if token == "(":
            name = re.search(r"([A-Za-z][A-Za-z_0-9.]*)$", prefix)
            stack.append(name.group(1) if name else "")
        elif token == ")":
            if stack:
                stack.pop()
        elif token.lower() == "nid":
            if re.search(r"\b(?:function|end)\s*$", prefix):
                continue
            ancestors = [n for n in stack if n]
            builders = [n.split(".")[-1] for n in ancestors
                        if n.split(".")[-1].startswith("New_")]
            result.append({
                "line": source.count("\n", 0, match.start()) + 1,
                "enclosing_new_call": builders[-1] if builders else None,
            })
    return result


def check(source_root, archive):
    expected = json.loads((ROOT / "source-archive-check.json").read_text())
    assert digest(archive.read_bytes()) == expected["archive_sha256"]
    sources = {str(p.relative_to(source_root)): p.read_bytes()
               for p in sorted((source_root / "src").rglob("*"))
               if p.suffix in (".adb", ".ads")}
    with tarfile.open(archive) as retained:
        members = {m.name.removeprefix("spark-source/"): m for m in retained
                   if m.isfile() and m.name.startswith("spark-source/src/")
                   and m.name.endswith((".adb", ".ads"))}
        assert sources.keys() == members.keys()
        for name, raw in sources.items():
            assert raw == retained.extractfile(members[name]).read(), name

    inventory = {name: found for name, raw in sources.items()
                 if (found := calls(raw.decode()))}
    counts = collections.Counter(c["enclosing_new_call"] or "other"
                                 for rows in inventory.values() for c in rows)
    why_names = enum_count(sources["src/why/why-gen-names.ads"].decode(),
                           "Why_Name_Enum")
    module_kinds = enum_count(sources["src/why/why-atree-modules.ads"].decode(),
                              "Module_Kind")
    assert why_names == 160 and module_kinds == 27
    assert sum(counts.values()) == 671
    assert counts["other"] == 32

    vc_spec = sources["src/common/vc_kinds.ads"].decode()
    vc_body = re.search(r"type VC_Kind is\s*\((.*?)\);",
                        clean(vc_spec), re.S).group(1)
    vc_images = re.findall(r"\bVC_\w+\b", vc_body)
    max_vc_image = max(map(len, vc_images))
    assert max_vc_image == 35
    module_body = sources["src/why/why-atree-modules.adb"].decode()
    module_suffixes = module_body[module_body.index("(case K is"):]
    module_suffixes = module_suffixes[:module_suffixes.index("begin")]
    max_module_suffix = max(map(len, re.findall(r'"([^"]*)"', module_suffixes)))
    assert max_module_suffix == 24
    assert len("GP_Check:") + 10 + 2 + max_vc_image + 22 == 78
    assert len("GP_Pretty_Ada:") + 10 == 24

    identity = json.loads((ROOT / "gnatcoll/identity.json").read_text())
    for name, expected_hash in identity["files"].items():
        assert digest((ROOT / "gnatcoll" / name).read_bytes()) == expected_hash
    spec = (ROOT / "gnatcoll/gnatcoll-symbols.ads").read_text()
    body = (ROOT / "gnatcoll/gnatcoll-symbols.adb").read_text()
    assert "Calls_To_Find : Natural := 0;" in spec
    assert "Total_Size    : Long_Long_Integer := 0;" in spec
    assert "Size_Saved    : Long_Long_Integer := 0;" in spec
    assert "Table.Calls_To_Find := Table.Calls_To_Find + 1;" in body
    assert body.index("Table.Calls_To_Find :=") < body.index("Table.Hash.Find")
    assert "Table_Size : constant := 98_317;" in body
    natural_last = (1 << 31) - 1
    long_long_last = (1 << 63) - 1
    max_string_sum = natural_last * natural_last
    assert max_string_sum < long_long_last
    assert (1 << 30) - 1 + 1 <= natural_last  # projection occurrence+1

    return {
        "archive_sha256": expected["archive_sha256"],
        "verified_complete_ada_files": len(sources),
        "why_name_enum_cardinality": why_names,
        "module_kind_cardinality": module_kinds,
        "nid_call_sites": sum(counts.values()),
        "lexical_enclosing_call_counts": dict(sorted(counts.items())),
        "nid_calls_by_file": inventory,
        "maximum_vc_kind_image_length": max_vc_image,
        "maximum_entity_module_suffix_length": max_module_suffix,
        "main_check_label_length_above_filename": 78,
        "maximum_pretty_marker_length": 24,
        "natural_last": natural_last,
        "maximum_find_length_sum": max_string_sum,
        "long_long_integer_last": long_long_last,
        "scope": "Lexical inventory and arithmetic only. An enclosing New_ "
                 "call is not automatically an allocation proof. Lookup "
                 "multiplicities and generated-length coverage remain manual.",
        "toolchain_or_proof_processes_run": False,
    }


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-root", type=Path, required=True)
    parser.add_argument("--source-archive", type=Path, required=True)
    args = parser.parse_args()
    result = check(args.source_root, args.source_archive)
    (ROOT / "auxiliary-domain-check.json").write_text(
        json.dumps(result, indent=2, sort_keys=True) + "\n")
    print(json.dumps({k: result[k] for k in (
        "verified_complete_ada_files", "nid_call_sites",
        "why_name_enum_cardinality", "module_kind_cardinality",
        "maximum_find_length_sum", "toolchain_or_proof_processes_run")}))
