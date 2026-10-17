#!/usr/bin/env python3
"""Focused retained-source/fixture checks and independent Why shape arithmetic.

No compiler/proof execution. The shape reconstructions use the pinned AST
schema, counting every builder list (including empty lists) and every emitted
reference. They corroborate manually reviewed source paths, not reachability.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re

p = argparse.ArgumentParser(description=__doc__)
p.add_argument("--source", type=Path, required=True)
p.add_argument("--reproduced", type=Path, required=True)
p.add_argument("--output", type=Path, required=True)
a = p.parse_args()
repo = Path(__file__).resolve().parents[3]
target = repo / "docs/evidence/retained-producer-capacity-20261017"

def sha(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()

manifest = json.loads((target / "source-manifest.json").read_text())
assert manifest["revision"] == "42554fc241fcd1fdf08d3a2feccb3f86912acbc0"
for item in manifest["files"]:
    assert sha(a.source / item["path"]) == item["sha256"]
reproductions = []
for f in sorted(target.iterdir()):
    if f.is_file():
        assert f.read_bytes() == (a.reproduced / f.name).read_bytes(), f.name
        reproductions.append({"file": f.name, "sha256": sha(f)})

schema = (a.source / "src/why/xgen/xtree_sinfo.adb").read_text()
fields = {}
for kind, name, cardinality in re.findall(
    r'New_Field\s*\(\s*(W_\w+)\s*,\s*"([^"]+)"\s*,\s*"[^"]+"\s*,\s*(Id_\w+)',
    schema, re.S,
):
    fields.setdefault(kind, {})[name] = cardinality

cost = [0, 0, 0]

def node(kind, **children):
    """Only serialized node-valued fields are needed for this reconstruction."""
    declared = fields.get(kind, {})
    assert children.keys() <= declared.keys(), (kind, children.keys(), declared)
    cost[0] += 1
    result = {"kind": kind, "children": {}}
    for name, cardinality in declared.items():
        if cardinality in ("Id_Set", "Id_Some"):
            value = children.get(name, [])
            assert isinstance(value, list)
            cost[1] += 1
            cost[2] += len(value)
        else:
            value = children.get(name)
        result["children"][name] = value
    return result

def occurrences(n):
    if n is None:
        return 0
    if isinstance(n, list):
        return sum(map(occurrences, n))
    return 1 + sum(occurrences(v) for v in n["children"].values())

def name(module=None):
    return node("W_Name", Module=module)

def typ(module=None):
    return node("W_Type", Name=name(module))

def ident(t=None, module=None):
    return node("W_Identifier", Name=name(module), Typ=t)

def call(fn, args, t=None):
    return node("W_Call", Name=fn, Args=args, Typ=t)

def reset():
    cost[:] = [0, 0, 0]

unit, integer, boolean = typ(), typ(), typ()
true_pred = node("W_Literal")
void = ident(unit)
wellformed = ident(module=node("W_Module"))
add = ident(integer, node("W_Module"))

# Literal fixed theory shape, excluding map type and use (per-invocation costs).
maptype = typ(node("W_Module"))
reset()
unused_low = ident(integer)
unit_param = ident(unit)
literal_id = ident(maptype)
literal_module = node("W_Module")
theory = node("W_Theory_Declaration", Declarations=[], Includes=[])
fdecl = node("W_Function_Decl", Name=literal_id,
             Binders=[node("W_Binder", Name=unit_param, Arg_Type=unit)],
             Effects=node("W_Effects"), Pre=true_pred, Post=true_pred,
             Return_Type=maptype)
literal_call = call(literal_id, [unit_param], maptype)
trigger = node("W_Triggers", Triggers=[node("W_Trigger", Terms=[literal_call])])
quantifier = node("W_Universal_Quantif",
                  Binders=[node("W_Binder", Name=unit_param, Arg_Type=unit)],
                  Triggers=trigger, Pred=true_pred)
definition = node("W_Axiom", Def=quantifier,
                  Dep=node("W_Axiom_Dep", Name=literal_id))
well_axiom = node("W_Axiom", Def=call(wellformed, [call(literal_id, [void], maptype)]),
                  Dep=node("W_Axiom_Dep", Name=literal_id))
theory["children"]["Declarations"].extend([fdecl, definition, well_axiom])
cost[2] += 3
fixed_cost = list(cost)
assert fixed_cost == [22, 12, 10], fixed_cost
fixed_occ = occurrences(theory) - occurrences(true_pred)
assert fixed_occ == 74, fixed_occ
assert occurrences(fdecl) == 19
assert occurrences(definition) - 1 == 30
assert occurrences(well_axiom) == 24
assert occurrences(literal_call) == 13

# The map type, returned call and discarded static program check occur even
# on a module-cache hit; no cache credit is used.
reset()
fresh_map = typ(node("W_Module"))
returned = call(ident(fresh_map, literal_module), [void], fresh_map)
discarded_last = call(add, [node("W_Integer_Constant"),
                            node("W_Integer_Constant")], integer)
assert cost == [9, 2, 3], cost
assert occurrences(returned) == 14
literal_use_cost = list(cost)

# Maximal ordinary bound accessor shape: a ten-occurrence cheap array read,
# a five-occurrence existing scalar function, and a two-occurrence result type.
arraytype = typ(node("W_Module"))
global_ref = ident(arraytype, node("W_Module"))
cheap = node("W_Deref", Right=global_ref, Typ=arraytype)
fn_int = ident(integer, node("W_Module"))
fn_bool = ident(boolean, node("W_Module"))
assert occurrences(cheap) == 10
reset()
lf, ll, rf, rl = [call(fn_int, [cheap], integer) for _ in range(4)]
assert all(occurrences(n) == 18 for n in [lf, ll, rf, rl])
length_eq = node("W_Conditional",
                 Condition=call(fn_bool, [lf, ll], boolean),
                 Then_Part=node("W_Connection",
                     Left=call(fn_bool, [rf, rl], boolean),
                     Right=call(fn_bool, [call(fn_int, [ll, lf], integer),
                                          call(fn_int, [rl, rf], integer)], boolean)),
                 Else_Part=call(fn_bool, [rl, rf], integer), Typ=boolean)
length_cost = list(cost)
assert length_cost == [12, 12, 16], length_cost
assert occurrences(length_eq) == 232

def refs(root, target):
    if root is None:
        return 0
    if isinstance(root, list):
        return sum(refs(n, target) for n in root)
    return int(root is target) + sum(refs(n, target) for n in root["children"].values())

reference_counts = [refs(length_eq, n) for n in [lf, ll, rf, rl]]
assert reference_counts == [2, 2, 3, 3]

def add_rows(rows):
    return [sum(row[i] for row in rows) for i in range(4)]

conversion = add_rows([(6,0,0,0), (3,0,0,9), (17,8,10,148),
                       (1,0,0,4), (3,0,0,9), (1,1,3,51), (16,13,18,238)])
concat = add_rows([(2,0,0,0), (1,1,1,0), (1,1,1,10), (21,12,20,188),
                  (16,11,18,171), (13,7,9,97), (6,0,0,18)])
initializer = add_rows([(2,0,0,0), (2,0,0,0), (2,0,0,0), (5,1,1,25),
                       (8,6,8,82), (1,1,3,1), (1,0,0,8)])
assignment_pre = add_rows([(4,0,0,0), (3,0,0,0), (3,0,0,9), (17,3,5,57),
                          (16,13,18,243), (4,0,0,0), (2,0,0,0), (5,1,1,20)])
assignment = add_rows([assignment_pre, conversion, conversion])
assert conversion == [47,22,31,459]
assert concat == [60,32,49,484]
assert initializer == [21,8,12,116]
assert assignment_pre == [54,17,24,329]
assert assignment == [148,61,86,1247]

result = {
    "target": "4073ab0820", "source_revision": manifest["revision"],
    "source_files_verified": len(manifest["files"]),
    "reproduced_files": reproductions,
    "independent_schema_reconstruction": {
        "literal_fixed_nodes_lists_elements": fixed_cost,
        "literal_fixed_emitted_occurrences": fixed_occ,
        "literal_use_nodes_lists_elements": literal_use_cost,
        "literal_use_emitted_occurrences": occurrences(returned),
        "length_equality_nodes_lists_elements": length_cost,
        "length_equality_emitted_occurrences": occurrences(length_eq),
        "length_bound_reference_multiplicities": reference_counts,
    },
    "reviewed_row_arithmetic": {"array_conversion": conversion,
        "concat": concat, "initializer_core": initializer,
        "assignment_pre_conversions": assignment_pre, "assignment": assignment},
    "scope": "Source/retained fixture/shape arithmetic only; no compiler or proofs",
    "whole_producer_closed": False,
}
a.output.write_text(json.dumps(result, indent=2) + "\n")
print(json.dumps({"verified_sources": len(manifest["files"]),
                  "reproduced_files": len(reproductions),
                  "literal_fixed": fixed_cost, "length_equality": length_cost}))
