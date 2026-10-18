#!/usr/bin/env python3
"""Check source inventories and retained inputs for producer string bounds.

This is an offline evidence checker, not a new admission rule or an Ada parser.
The source reduction and constructor-lineage arguments are in the linked record.
"""

import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re
import sys
import tarfile


ROOT = Path(__file__).resolve().parent
EARLIER = ROOT.parent / "retained-producer-capacity-20261017"
sys.path.insert(0, str(EARLIER))
from auxiliary_domains import check, clean  # noqa: E402
from string_lengths import actual, body_events, inventory as comments  # noqa: E402


FORWARDERS = (
    "New_Identifier", "New_Module", "New_Temp_Identifier",
    "New_Generated_Identifier", "New_Named_Type", "New_Type_Decl",
    "New_Defining_Bool_Axiom", "Unit_Param", "Prepare_Indexes_Substitutions",
    "Get_Model_Trace_Label",
)


def digest(raw):
    return hashlib.sha256(raw).hexdigest()


def scan_calls(source, names):
    code = clean(source)
    pattern = r"\b(" + "|".join(names) + r")\s*\("
    for match in re.finditer(pattern, code, re.I):
        if re.search(r"\b(?:function|procedure)\s*$",
                     code[max(0, match.start() - 40):match.start()], re.I):
            continue
        depth, end = 1, match.end()
        while depth:
            depth += (code[end] == "(") - (code[end] == ")")
            end += 1
        yield match.start(), match.group(1), source[match.end():end - 1]


def literal_value(expression):
    expression = expression.strip()
    if re.fullmatch(r'"(?:[^"\n]|"")*"', expression):
        return expression[1:-1].replace('""', '"')
    return None


def source_inventory(source_root):
    dynamic, literal_lengths, forwarded = [], [], []
    forward_literal_lengths = []
    forward_counts = Counter()
    for path in sorted((source_root / "src").rglob("*")):
        if path.suffix not in (".adb", ".ads"):
            continue
        source = path.read_text()
        code = clean(source)
        events = body_events(code)
        for position, name, expression in scan_calls(source, ("NID",)):
            value = literal_value(expression)
            if value is not None:
                literal_lengths.append(len(value))
            else:
                events.append((position, "sink", expression))
        stack = []
        for position, kind, value in sorted(events):
            if kind == "start":
                stack.append(value)
            elif kind == "end":
                if stack and stack[-1].lower() == value.lower():
                    stack.pop()
            else:
                dynamic.append({
                    "file": str(path.relative_to(source_root)),
                    "line": source.count("\n", 0, position) + 1,
                    "enclosing": ".".join(stack),
                    "expression": " ".join(value.split()),
                })

        for position, name, expression in scan_calls(source, FORWARDERS):
            forward_counts[name] += 1
            forward_literal_lengths.extend(
                len(s.replace('""', '"'))
                for s in re.findall(r'"((?:[^"\n]|"")*)"', expression))
            # Preserve String-bearing named actuals, including node-typed
            # overloads as deliberate overcount; review resolves their types.
            masked = clean(expression)
            for match in re.finditer(
                    r"\b(Name|Base_Name|S|Prefix|Fun_Name)\s*=>", masked, re.I):
                value = actual(expression + ")", masked + ")", match.end()).strip()
                if literal_value(value) is not None:
                    continue
                if re.match(r"(?:New_Name|To_Why_Id|Get_Name|To_Local|E_Symb|"
                            r"To_Ident|New_Temp_Identifier)\b", value):
                    continue
                forwarded.append({
                    "file": str(path.relative_to(source_root)),
                    "line": source.count("\n", 0, position) + 1,
                    "constructor": name,
                    "actual": match.group(1),
                    "expression": " ".join(value.split()),
                })

    names = (source_root / "src/why/why-gen-names.adb").read_text()
    names = names[names.index("function To_String (W : Why_Name_Enum)"):
                  names.index("-- To_Ident --")]
    enum_literals = re.findall(r'when\s+(WNE_\w+)\s*=>\s*"([^"]*)"', names)
    assert len(dynamic) == 180
    assert len(literal_lengths) == 491 and max(literal_lengths) == 40
    assert len(enum_literals) == 62
    assert max(len(s) for _, s in enum_literals) == 23
    assert max(forward_literal_lengths) == 32
    assert len(comments(source_root)) == 107
    return {
        "nid_calls": 671,
        "direct_literal_nid_calls": 491,
        "maximum_direct_literal_length": 40,
        "nonliteral_nid_calls": dynamic,
        "why_enum_literal_arms": 62,
        "maximum_why_enum_literal_length": 23,
        "maximum_forwarder_literal_length": 32,
        "forwarder_call_counts": dict(sorted(forward_counts.items())),
        "nonliteral_named_forwarder_actuals": forwarded,
        "comment_actuals": 107,
    }


def retained_inputs():
    retained = EARLIER / "intern-counters"
    manifest = json.loads((retained / "manifest.json").read_text())
    archive = retained / manifest["archive"]
    assert digest(archive.read_bytes()) == manifest["sha256"]
    with tarfile.open(archive) as tar:
        files = {m.name: tar.extractfile(m).read() for m in tar if m.isfile()}
    assert files.keys() == manifest["members"].keys()
    for name, expected in manifest["members"].items():
        assert len(files[name]) == expected["size"]
        assert digest(files[name]) == expected["sha256"]

    summary = json.loads((retained / "summary.json").read_text())
    observations = {}
    for case in summary["cases"]:
        name = case["case"]
        raw = json.loads(files[f"probe/{name}/result.json"])
        assert raw["debugger_exit"] == 0
        assert raw["snapshots"] == [case["before_standard"],
                                    case["after_standard"], case["final"]]
        observations[name] = {
            pool: max(snapshot[pool]["maximum_symbol_length"]
                      for snapshot in raw["snapshots"])
            for pool in ("why", "entity")
        }
    main_roots = ("put", "put_line", "first_or_default",
                  "input_is_valid", "reject")
    assert max(observations[n]["why"] for n in main_roots) == 169
    assert max(observations[n]["entity"] for n in main_roots) == 76
    expected = {"silver_io": 211, "silver_arguments": 225,
                "silver_output_libc": 229, "silver_runtime": 221}
    assert {n: observations[n]["why"] for n in expected} == expected
    # Current source bytes are part of the fixed-input reduction.
    repo = ROOT.parents[2]
    for name, raw in files.items():
        if name.startswith("probe/library-src/"):
            assert raw == (repo / "src" / Path(name).name).read_bytes()
    return {"archive_sha256": manifest["sha256"],
            "observations": observations}


def bounds(identifier_length, loops, main_nodes, path_bytes):
    """Arguments are the source/config bounds defined in the research record."""
    assert min(identifier_length, loops, main_nodes, path_bytes) >= 0
    h = max(identifier_length + 5, 18)
    q = h + 26 * loops + 30
    main = {
        "names": h + q + 41,
        "comments": 2 * max(q, 760) + 2 * path_bytes + 248,
        "labels": max(9 + main_nodes * (2 * h + 8),
                      path_bytes + 78, h + 5, 44),
        "string_attributes": 33,
        "filenames": path_bytes,
    }
    fixed = {"names": 1702, "comments": 1690 + 2 * path_bytes,
             "labels": 1690 + 2 * path_bytes,
             "string_attributes": 33, "filenames": path_bytes}
    combined = {key: max(main[key], fixed[key]) for key in main}
    assert h + q + 41 >= 2 * h + 52  # projection + metadata family
    assert h + q + 41 >= max(q + 24, h + 20, 52, 40)
    return {"H": h, "Q": q, "main": main, "fixed": fixed,
            "combined": combined, "u": max(combined.values()),
            "common_pool": max(q, 760)}


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-root", type=Path, required=True)
    parser.add_argument("--source-archive", type=Path, required=True)
    parser.add_argument("--write", action="store_true",
                        help="write the reproducible inventory instead of comparing it")
    args = parser.parse_args()
    source = check(args.source_root, args.source_archive)
    result = {
        "source_archive_sha256": source["archive_sha256"],
        "verified_complete_ada_files": source["verified_complete_ada_files"],
        "source_inventory": source_inventory(args.source_root),
        "retained_inputs": retained_inputs(),
        "decimal_inflation": 10,
        "optional_projection_suffix": 12,
        "fixed_path_occurrences": 2,
        "fixed_common_name_bound": 760,
        "fixed_main_name_bound": 1702,
        "manual_obligations": [
            "Fixed-root/source-name template reduction and unchanged branch selection",
            "Main constructor lineages and the single effective localization bound",
            "No fixed generic/inlining source chain; paths are actual configuration bytes",
            "Counter representability and source-to-Main-node bound are supplied separately",
        ],
        "native_tool_executions": 0,
    }
    target = ROOT / "inventory.json"
    if args.write:
        target.write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    else:
        assert result == json.loads(target.read_text())
    # Endpoint arithmetic checks are independent of the manual source theorem.
    assert len(str((1 << 31) - 1)) == 10
    assert len("__" + str((1 << 31) - 1)) == 12
    assert len("model_trace:") + 10 + len("'Loop_Entry") == 33
    assert 10 * 169 + 12 == 1702 and 10 * 76 == 760
    print(json.dumps({
        "verified_complete_ada_files": result["verified_complete_ada_files"],
        "nid_calls": 671, "nonliteral_nid_calls": 180,
        "forwarder_calls": sum(result["source_inventory"]["forwarder_call_counts"].values()),
        "fixed_name_bound": 1702, "fixed_common_name_bound": 760,
        "native_tool_executions": 0,
    }, sort_keys=True))


if __name__ == "__main__":
    main()
