#!/usr/bin/env python3
"""Inventory comment-length components in the archived producer source."""

import argparse
import json
from pathlib import Path
import re

from auxiliary_domains import check, clean


ROOT = Path(__file__).resolve().parent


def actual(source, code, start):
    depth = 0
    for end in range(start, len(code)):
        char = code[end]
        if char == "(":
            depth += 1
        elif char == ")":
            if depth == 0:
                break
            depth -= 1
        elif char == "," and depth == 0:
            break
    return source[start:end]


def body_events(code):
    """Named bodies suffice for these non-generic comment call sites.

    Ignore specifications, instantiations, renamings, expression functions,
    null/abstract/separate declarations. Named ends pop only their matching
    body. The resulting paths are an inventory to review, not an Ada parser.
    """
    events = []
    pattern = r"\b(package(?:\s+body)?|procedure|function)\s+([a-z][a-z_0-9.]*)"
    for match in re.finditer(pattern, code, re.I):
        depth = 0
        for token in re.finditer(r"\b\w+\b|[();]", code[match.end():]):
            value = token.group().lower()
            if value == "(":
                depth += 1
            elif value == ")":
                depth -= 1
            elif depth == 0 and value in (";", "renames"):
                break
            elif depth == 0 and value == "is":
                tail = code[match.end() + token.end():].lstrip()
                if not re.match(r"(?:new|abstract|null|separate)\b|\(", tail, re.I):
                    events.append((match.start(), "start", match.group(2)))
                break
    for match in re.finditer(r"\bend\s+([a-z][a-z_0-9.]*)\s*;", code, re.I):
        events.append((match.start(), "end", match.group(1)))
    return events


def inventory(source_root):
    rows = []
    constructors = 0
    for path in sorted((source_root / "src/why").glob("*.adb")):
        source = path.read_text()
        code = clean(source)
        events = body_events(code)
        for match in re.finditer(r"\bComment\s*=>", code):
            events.append((match.start(), "comment", match.end()))
        for match in re.finditer(r"\b(?:New_Comment|Open_Theory)\s*\(", code):
            prefix = code[max(0, match.start() - 32):match.start()]
            if not re.search(r"\bfunction\s*$", prefix):
                constructors += 1
        stack = []
        for position, kind, value in sorted(events):
            if kind == "start":
                stack.append(value)
            elif kind == "end":
                if stack and stack[-1].lower() == value.lower():
                    stack.pop()
            else:
                expression = actual(source, code, value)
                literals = re.findall(r'"((?:[^"\n]|"")*)"', expression)
                literal_sum = sum(len(s.replace('""', '"')) for s in literals)
                enclosing = ".".join(stack)
                source_info = expression.count("GNAT.Source_Info.Enclosing_Entity")
                rows.append({
                    "file": str(path.relative_to(source_root)),
                    "line": source.count("\n", 0, position) + 1,
                    "enclosing_entity": enclosing,
                    "enclosing_entity_length": len(enclosing),
                    "literal_sum": literal_sum,
                    "raw_name_occurrences": len(re.findall(
                        r"Get_Name_String\s*\(Chars", expression)),
                    "location_occurrences": expression.count("Build_Location_String"),
                    "source_info_occurrences": source_info,
                    "fixed_text_bound": literal_sum + source_info * len(enclosing),
                })
        assert not stack, (path, stack)
    assert len(rows) == 107
    # Open_Theory forwards its comment to New_Theory_Declaration, the remaining
    # Comment actual. Every direct New_Comment/Open_Theory call uses Comment =>.
    assert constructors == len(rows) - 1 == 106
    assert max(r["raw_name_occurrences"] for r in rows) == 2
    assert max(r["location_occurrences"] for r in rows) == 2
    assert max(r["source_info_occurrences"] for r in rows) == 1
    assert max(r["enclosing_entity_length"] for r in rows) == 85
    assert max(r["fixed_text_bound"] for r in rows) == 226
    return rows


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-root", type=Path, required=True)
    parser.add_argument("--source-archive", type=Path, required=True)
    args = parser.parse_args()
    verified = check(args.source_root, args.source_archive)
    rows = inventory(args.source_root)
    result = {
        "archive_sha256": verified["archive_sha256"],
        "verified_complete_ada_files": verified["verified_complete_ada_files"],
        "comment_actuals": len(rows),
        "maximum_fixed_text_bound": 226,
        "comment_bound": "2 Q + 2 L_build + 226",
        "main_location_bound": "P_ref + 11",
        "instantiation_location_bound": "D_loc (P_ref + 28)",
        "to_local_changes_symbol_length": False,
        "comment_inventory": rows,
        "scope": "Checks source identities, inventory and arithmetic. Manual "
                 "source argument covers the forwarded Comment and Object_Name "
                 "parameters; this is not an exhaustive bound on all strings.",
        "toolchain_or_proof_processes_run": False,
    }
    (ROOT / "string-length-check.json").write_text(
        json.dumps(result, indent=2, sort_keys=True) + "\n")
    print(json.dumps({k: result[k] for k in (
        "verified_complete_ada_files", "comment_actuals",
        "maximum_fixed_text_bound", "comment_bound",
        "toolchain_or_proof_processes_run")}))
