#!/usr/bin/env python3
"""Recheck pinned SARIF/VSS source bytes and source-derived arithmetic offline."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile


def without_comments(source):
    return re.sub(r'--[^\n]*|"(?:[^"]|"")*"',
                  lambda m: "" if m[0].startswith("--") else m[0], source)


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", required=True, type=Path)
    args = parser.parse_args()
    root = Path(__file__).resolve().parent
    manifest = json.loads((root / "source-manifest.json").read_text())
    sources = {}
    with tarfile.open(root / "sources.tar.gz") as archive:
        assert sorted(archive.getnames()) == sorted(x["path"] for x in manifest["files"])
        for row in manifest["files"]:
            data = archive.extractfile(row["path"]).read()
            assert len(data) == row["bytes"]
            assert hashlib.sha256(data).hexdigest() == row["sha256"]
            sources[row["path"]] = data.decode()
    for repo, expected in [("vss-text", "01c9adfef0efda9589fa544115628e28e26767b3"),
                           ("vss-extra", "a9d466d7d75c555676654b71a0d92e946ea4688d")]:
        ref = json.loads((root / (repo+"-identity.json")).read_text())
        tag = json.loads((root / (repo+"-tag.json")).read_text())
        assert ref["object"]["sha"] == tag["sha"]
        assert tag["object"]["sha"] == expected
    candidate = json.loads((root / "sarif-ada-identity.json").read_text())
    assert candidate[0]["sha"] == "4bc234ccccdd68813352c668a3c83ca82940f1b6"

    spec = without_comments(sources["spark2014/src/common/vc_kinds.ads"])
    enums = {}
    for name in ["VC_Kind", "Flow_Tag_Kind", "Misc_Warning_Kind"]:
        match = re.search(r"type\s+"+name+r"\s+is\s*\((.*?)\);", spec, re.S)
        values = [x.strip() for x in match[1].split(",")]
        assert all(re.fullmatch(r"\w+", x) for x in values)
        enums[name] = values
    assert [len(enums[n]) for n in enums] == [69, 36, 63]
    rules = sum(len(x) for x in enums.values())-1
    assert rules == 167
    text = sources["spark2014/src/common/vc_kinds.adb"]
    maxima = {}
    for kind in ["VC_Kind", "Valid_Flow_Tag_Kind", "Misc_Warning_Kind"]:
        for fn in ["Description", "Kind_Name"]:
            start = re.search(r"function "+fn+r" \(Kind : "+kind+r"\)", text).start()
            stop = re.search(r"\n   (function|procedure|pragma)", text[start+10:]).start()+start+10
            tokens = re.findall(r'--[^\n]*|"(?:[^"]|"")*"|\b\w+\b|=>|[^\s]', text[start:stop])
            branches, current = [], None
            for token in tokens:
                if token.startswith("--"):
                    continue
                if token.lower() == "when":
                    if current is not None:
                        branches.append(current)
                    current = []
                elif current is not None:
                    current.append(token)
            if current is not None:
                branches.append(current)
            maxima[kind+"."+fn] = max(sum(len(t[1:-1].replace('""', '"'))
                for t in branch if t.startswith('"')) for branch in branches)
    assert list(maxima.values()) == [240, 69, 72, 77, 258, 39]
    capacities, length = [2], 0
    for _ in range(rules):
        if length == capacities[-1]:
            capacities.append(3*length//2)
        length += 1
    assert capacities[-1] == 211 and 3*capacities[-2] == 423

    # Conservative selected-ABI accounting, not measured record sizes.
    # Every recognized leaf is <=128 bytes; record/discriminant allowances
    # are 16 each. All upper bounds are multiples of the 16-byte alignment.
    sarif = without_comments(sources["sarif-ada/src/generated/sarif-types.ads"])
    records = {}
    for match in re.finditer(r"\btype\s+(\w+)(\s*\([^;]*?\))?\s+is\s+record\s+(.*?)end record;", sarif, re.S):
        fields = re.findall(r"^\s*\w+\s*:\s*([\w.]+)", match[3], re.M)
        records[match[1].lower()] = (bool(match[2]), fields)
    leaves = set()
    def size(name):
        name = name.lower().removeprefix("sarif.types.")
        if name not in records:
            assert (name in {"boolean", "integer", "float", "any_object", "vss.strings.virtual_string"}
                    or name.startswith("enum.optional_") or name.endswith("_vector")), name
            leaves.add(name)
            return 128
        discriminated, fields = records[name]
        return 16 + 16*discriminated + sum(size(field) for field in fields)
    sizes = {name: size(name) for name in ["reportingDescriptor", "invocation", "run"]}
    assert list(sizes.values()) == [4368, 12640, 44256]
    arrays = {name: 32+n*sizes[name] for name, n in
              [("reportingDescriptor", 211), ("invocation", 2), ("run", 2)]}
    assert max(arrays.values()) < 2**31-1
    body = sources["sarif-ada/src/generated/sarif-types.adb"]
    assert "new reportingDescriptor_Array (1 .. 3 * Self.Length / 2)" in body
    assert "new reportingDescriptor_Array'(Self.Data (1 .. Self.Length))" in body
    heap = sources["vss-text/source/text/implementation/vss-implementation-text_storages-heap.adb"]
    assert "((Static_Size + Capacity) / Minimal_Allocation_Block + 1)" in heap
    writer = sources["vss-extra/source/json/implementation/vss-json-push_writers.adb"]
    assert "while VSS.Implementation.UTF8_Strings.Forward (Text, Position) loop" in writer
    assert "Interfaces.Integer_64'Wide_Wide_Image (Value.Integer_Value)" in writer
    stream = sources["vss-extra/source/os/implementation/vss-text_streams-file_output.adb"]
    assert "Process_BOM   => False" in stream
    examples = []
    for path in [222, 4096]:
        bound = max(258, 181+path, path, 20)  # version length <=258 in this example
        examples.append({"path_bytes": path, "string_bytes": bound,
                         "heap_allocation_upper_bound": 64+bound+64+1})
    result = {"source_files": len(sources), "rule_count": rules,
              "constant_string_maxima": maxima, "rule_vector_capacities": capacities,
              "largest_vector_growth_multiply": 423,
              "selected_ABI_record_upper_bounds": sizes,
              "selected_ABI_array_request_upper_bounds": arrays,
              "text_examples": examples,
              "writer_character_buffer_capacity_including_optional_BOM": 8,
              "compiler_runs": 0, "prover_runs": 0,
              "scope": "caller-specific source transfer; installed behavior and path/configuration premises remain explicit"}
    args.output.write_text(json.dumps(result, indent=2)+"\n")
    print(f"Verified {len(sources)} source files, {rules} rules and selected storage arithmetic")


if __name__ == "__main__":
    main()
