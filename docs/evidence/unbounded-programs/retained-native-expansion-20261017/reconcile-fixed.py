#!/usr/bin/env python3
"""Reconcile existing native capture with Main's source-selected fixed roots.

Read-only: no compiler/debugger/prover execution. Root inclusion, freezing and
constructor transfers remain the manual argument in retained-native-expansion.md.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re


def digest(path):
    return hashlib.sha256(path.read_bytes()).hexdigest()


def code_only(raw):
    return re.sub(r'--[^\n]*|"(?:[^"]|"")*"',
                  lambda m: "".join("\n" if c == "\n" else " " for c in m[0]),
                  raw.decode("latin-1"))


parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("capture", type=Path)
parser.add_argument("output", type=Path)
args = parser.parse_args()
manifest = json.loads((args.capture/"inputs.json").read_text())
summary = json.loads((args.capture/"summary.json").read_text())
decoded = json.loads((args.capture/"decoded-names.json").read_text())
unit_pattern = re.compile(r"^(?:private\s+)?(?:package|procedure|function)\s+([\w.]+)", re.M|re.I)
units = {}
for spelling, entry in manifest.items():
    path = Path(spelling)
    if path.suffix not in (".ads", ".adb"):
        continue
    raw = path.read_bytes()
    assert len(raw) == entry["bytes"] and hashlib.sha256(raw).hexdigest() == entry["sha256"], path
    if path.suffix != ".ads":
        continue
    code = code_only(raw)
    match = unit_pattern.search(code)
    assert match, path
    name = match[1].lower()
    assert name not in units, name
    dependencies = []
    for m in re.finditer(r"^\s*(?:(?:limited|private)\s+)*with\s+([A-Za-z0-9_.,\s]+);", code[:match.start()], re.M|re.I):
        dependencies.extend("".join(x.split()).lower() for x in m[1].split(","))
    if "." in name:
        dependencies.append(name.rsplit(".", 1)[0])
    instances = [{"line":code.count("\n",0,m.start())+1,"name":m[2],"generic":m[3]}
        for m in re.finditer(r"\b(package|procedure|function)\s+([\w.]+)\s+is\s+new\s+([\w.]+)", code, re.I)]
    units[name] = dict(file=path.name, **entry, dependencies=sorted(set(dependencies)), generic_instances=instances)
roots = ["silver_io", "silver_arguments", "system", "system.standard_library",
         "system.exception_table", "ada.exceptions", "system.soft_links",
         "system.stack_checking", "ada.tags", "system.put_images",
         "system.img_int", "system.secondary_stack"]
roots += [f"system.concat_{n}" for n in range(2,10)]
selected, todo = {}, roots[:]
while todo:
    name = todo.pop()
    if name in selected:
        continue
    assert name in units, name
    selected[name] = units[name]
    todo.extend(units[name]["dependencies"])
selected = dict(sorted(selected.items()))
assert len(selected) == 38
assert sum(len(x["generic_instances"]) for x in selected.values()) == 8
physical = {x["file"] for x in decoded["corrected_source_map"] if x["template"] == 0}
assert physical == {x["file"] for x in selected.values()}|{"main.adb"}
assert sum(x["template"] != 0 for x in decoded["corrected_source_map"]) == 8
names = [x["value"] for x in decoded["corrected_names"]]
counts = summary["phases"]["main_return"]
assert len(counts) == 120
live_characters = sum(len(x)+1 for x in names)
# Namet locks reserve 5000 characters. Any positive-growth excess not decoded
# is covered as if every character were a separate additional pathname.
name_characters = counts["namet__name_chars__last_val"]
undecoded_characters = name_characters-5000-live_characters
assert undecoded_characters == 4
path_names = sum("/" in x for x in names)
assert path_names == 56
path_occurrences = sum(x.count("/") for x in names)
assert path_occurrences == 831
max_path_occurrences = max(max(x.count("/") for x in names), undecoded_characters)
assert max_path_occurrences == 17
result = dict(
    scope="Source-selected Main fixed unit closure reconciled with the retained complete all-roots capture; no execution. Manual root/freezing reduction is required for constant promotion.",
    capture_files_sha256={name:digest(args.capture/name) for name in ("summary.json","inputs.json","decoded-names.json")},
    fixed_roots=roots, selected_specifications=selected,
    selected_runtime_specifications=36, selected_Silver_specifications=2,
    semantic_compilation_units_including_Main=39,
    fixed_generic_instances=8, physical_source_map_matches_closure=True,
    fixed_lifetime_table_growth=counts,
    names=dict(decoded_entries=len(names), decoded_characters_including_NUL=live_characters,
        locked_character_reserve=5000, undecoded_lifetime_characters=undecoded_characters,
        slash_bearing_spellings=path_names,
        path_occurrence_allowance=path_occurrences+undecoded_characters,
        slash_occurrences=path_occurrences,
        max_path_occurrences_per_spelling=max_path_occurrences,
        maximum_recorded_spelling_length=max(map(len,names)),
        decimal_serial_digit_allowance=10,
        normalization="10*fixed_character_growth + path_occurrence_allowance*(P+1) + 4*(input_identifier_length-1); P bounds each complete pathname under the same search/invocation shape",
        fixed_Name_buffer_bound="10*maximum_recorded_spelling_length + max_path_occurrences_per_spelling*(P+1) + max(0,input_identifier_length-1)"),
    additional_implicit_with_nodes=8*36,
    source_sensitive_unit_scope_saves_included=False,
    physical_representations_included=False,
    whole_native_frontend_closed=False)
args.output.write_text(json.dumps(result,indent=2,sort_keys=True)+"\n")
print(json.dumps(dict(selected_specs=len(selected),semantic_units=39,generic_copies=8,path_occurrences=path_occurrences+undecoded_characters,retained_table_counters=len(counts))))
