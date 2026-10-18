#!/usr/bin/env python3
"""Count pinned fixed Why initializer constructors without running a toolchain."""

import argparse
from collections import Counter
import hashlib
import json
from pathlib import Path
import re


ROOT = Path(__file__).resolve().parent
SOURCE = "src/why/why-atree-modules.adb"


def strip_noncode(text):
    # Ada doubled quotes belong to one string. Preserve line numbers.
    return re.sub(r'"(?:[^"\n]|"")*"|--[^\n]*',
                  lambda m: " " * len(m.group()), text)


def inventory(source_root):
    raw = (source_root / SOURCE).read_bytes()
    source = raw.decode("utf-8")
    clean = strip_noncode(source)
    routines = {}
    for match in re.finditer(r"^   procedure (Initialize|Init_\w+) is", clean, re.M):
        name = match.group(1)
        end = clean.index("   end " + name + ";", match.end())
        body = clean[match.end():end]
        assert "while " not in body
        counts = Counter(re.findall(r"\b(New_\w+)\b", body))
        assert set(counts) <= {"New_Module", "New_Type", "New_Name", "New_Identifier"}
        loops = []
        for loop in re.finditer(r"\bfor\s+\w+\s+in\s+(\w+)\s+loop", body):
            loop_end = body.index("end loop;", loop.end())
            inner = body[loop.end():loop_end]
            assert not re.search(r"\b(?:loop|while)\b", inner)
            iterations = {"BV_Kind": 6, "Floating_Kind": 3}[loop.group(1)]
            inner_counts = Counter(re.findall(r"\b(New_\w+)\b", inner))
            counts.update({k: v * (iterations - 1) for k, v in inner_counts.items()})
            loops.append({"kind": loop.group(1), "iterations": iterations,
                          "constructors_per_iteration": dict(inner_counts)})
        assert len(re.findall(r"\bend loop;", body)) == len(loops)
        calls = Counter(re.findall(r"\b(\w+)\s*\(", body))
        assert set(calls) <= {"New_Module", "New_Type", "New_Name", "New_Identifier",
                              "NID", "M_Floats", "M_BVs"}
        helpers = re.findall(r"^\s+(Init_\w+);\s*$", body, re.M)
        routines[name] = {
            "first_line": source[:match.start()].count("\n") + 1,
            "last_line": source[:end].count("\n") + 1,
            "constructors": dict(sorted(counts.items())),
            "loops": loops,
            "helper_calls": helpers,
            "fresh_nodes": sum(n * (2 if kind == "New_Identifier" else 1)
                               for kind, n in counts.items()),
        }
    invoked = routines["Initialize"]["helper_calls"]
    assert len(invoked) == len(set(invoked)) == 23
    assert set(routines) == {"Initialize", *invoked}
    assert all(not routines[name]["helper_calls"] for name in invoked)
    spec = strip_noncode((source_root / "src/why/why-atree-modules.ads").read_text())
    for kind, size in (("BV_Kind", 6), ("Floating_Kind", 3)):
        values = re.search(r"type " + kind + r" is \(([^)]+)\)", spec).group(1)
        assert len(values.split(",")) == size
    total = sum(row["fresh_nodes"] for row in routines.values())
    module_total = sum(row["constructors"].get("New_Module", 0)
                       for row in routines.values())
    assert (total, module_total) == (1439, 117)
    return {"source": SOURCE, "sha256": hashlib.sha256(raw).hexdigest(),
            "routines": routines, "fresh_nodes": total, "modules": module_total,
            "fresh_lists": 0, "list_elements": 0, "independent_serialized_roots": 0,
            "scope": "Why.Atree.Modules.Initialize and its 23 fixed helper calls only; "
                     "not Translate_Standard_Package or the whole fixed dependency cost"}


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-root", type=Path, required=True)
    args = parser.parse_args()
    result = inventory(args.source_root)
    (ROOT / "initializer-inventory.json").write_text(
        json.dumps(result, indent=2, sort_keys=True) + "\n")
    print(f"Pinned initializer: {result['fresh_nodes']} nodes, {result['modules']} modules; "
          "no toolchain run")
