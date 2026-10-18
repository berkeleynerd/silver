#!/usr/bin/env python3
"""Reconcile ALI serializer premises with retained source inputs; no execution.

This lexical inventory is an inspection aid for the manual selected-frontier
argument. It is not an Ada semantic parser or a general capacity recognizer.
"""
import argparse
import hashlib
import json
from pathlib import Path
import re

parser = argparse.ArgumentParser(description=__doc__)
parser.add_argument("--ada", type=Path, required=True)
parser.add_argument("--capture", type=Path, required=True)
parser.add_argument("--output", type=Path, required=True)
args = parser.parse_args()
evidence = Path(__file__).resolve().parent
repo = evidence.parents[3]
fixed = json.loads((evidence / "native-fixed-inputs.json").read_text())
capture = json.loads((args.capture / "inputs.json").read_text())
assert hashlib.sha256((args.capture / "inputs.json").read_bytes()).hexdigest() == fixed["capture_files_sha256"]["inputs.json"]
by_hash = {entry["sha256"]: Path(path) for path, entry in capture.items()}
manifest = json.loads((repo / "docs/evidence/unbounded-programs/continuation-20261017/frontend-lifetimes/complete-source-manifest.json").read_text())
expected = {entry["path"]: entry for entry in manifest["files"]}
identities = {}


def read(name, path, digest):
    raw = path.read_bytes()
    assert hashlib.sha256(raw).hexdigest() == digest, name
    identities[name] = dict(bytes=len(raw), sha256=digest)
    return raw.decode()


def without_comments(text):
    return re.sub(r'"(?:""|[^"\n])*"|--[^\n]*',
        lambda m: m[0] if m[0].startswith('"') else " " * len(m[0]), text)


def code_only(text):
    return re.sub(r'"(?:""|[^"\n])*"', lambda m: " " * len(m[0]), without_comments(text))


serializer = {}
for name in ("lib-util.adb", "lib-writ.adb", "lib-xref.adb", "lib.ads",
             "hostparm.ads", "namet.ads", "osint.adb", "gnatvsn.ads", "alloc.ads", "libgnat/s-rident.ads"):
    serializer[name] = read("gcc/ada/" + name, args.ada / name, expected[name]["sha256"])
assert "2 * Hostparm.Max_Name_Length + 64" in serializer["lib-util.adb"]
assert "1000 * Max_Line" in serializer["lib-util.adb"]
assert "if Write_Info_Col > 72 then" in serializer["lib-xref.adb"]
unit_writer = serializer["lib-writ.adb"].split("procedure Write_Unit_Information (Unit_Num : Unit_Number_Type) is", 1)[1].split("Write_Info_EOL;", 1)[0]
unit_literals = re.findall(r'Write_Info_Str \("([^"]*)"\)', unit_writer)
assert len(unit_literals) == 25 and sum(map(len, unit_literals)) == 74
unit_record = re.search(r"type Unit_Record is record(.*?)end record;", serializer["lib.ads"], re.S)[1]
unit_fields = len(re.findall(r"\b\w+\s*:(?!=)", code_only(unit_record)))
assert unit_fields == 26
max_library_name = int(re.search(r"Max_Name_Length\s*:\s*constant\s*:=\s*([0-9_]+)",
    serializer["hostparm.ads"])[1].replace("_", ""))
assert max_library_name == 1024
inventory = {}
for unit, entry in fixed["selected_specifications"].items():
    raw = read("selected/" + entry["file"], by_hash[entry["sha256"]], entry["sha256"])
    text, code = without_comments(raw), code_only(raw)
    arrays = list(re.finditer(r"\barray\s*\((.*?)\)\s*of\b", code, re.I | re.S))
    assert len(arrays) == len(re.findall(r"\barray\b", code, re.I)), unit
    assert all("," not in m[1] and "(" not in m[1] for m in arrays), unit
    assert not re.search(r"\binterface\b", code, re.I), unit
    assert not re.search(r"\b(?:External_Name|Link_Name|Interface_Name)\s*=>", code, re.I), unit
    pragmas = re.findall(r"\bpragma\s+(?:Import|Export|Interface)\s*\((.*?)\)\s*;", text, re.I | re.S)
    externals = []
    for pragma in pragmas:
        fields = [field.strip() for field in pragma.split(",")]
        assert 2 <= len(fields) <= 3, (unit, pragma)
        if len(fields) == 3:
            assert re.fullmatch(r'"(?:""|[^"\n])*"', fields[2]), (unit, pragma)
            externals.append(fields[2][1:-1].replace('""', '"'))
        else:
            # Omitted external names occur only for Intrinsic, which the
            # selected Xref language-name writer does not serialize.
            assert fields[0].lower() == "intrinsic", (unit, pragma)
    inventory[unit] = dict(array_declarations=[dict(line=code.count("\n", 0, m.start())+1,
        index=" ".join(m[1].split())) for m in arrays], interface_types=0,
        max_source_word_length=max(map(len, re.findall(r"[A-Za-z][A-Za-z_0-9]*", code))),
        external_names=externals, generic_instances=entry["generic_instances"])
restriction_code = code_only(serializer["libgnat/s-rident.ads"])
enumeration = re.search(r"type Restriction_Id is\s*\((.*?)\)", restriction_code, re.S)[1]
restrictions = re.findall(r"[A-Za-z][A-Za-z_0-9]*", enumeration)
assert restrictions[0] == "Simple_Barriers" and restrictions[-1] == "Not_A_Restriction_Id"
boolean_count = restrictions.index("SPARK_05")+1
parameter_count = restrictions.index("Max_Storage_At_Blocking")-restrictions.index("No_Specification_Of_Aspect")+1
zero_tables = ["lib__notes__last_val", "lib__version_ref__last_val",
    "lib__linker_option_lines__last_val", "lib__restriction_set_dependences__last_val",
    "restrict__no_dependences__last_val", "lib__writ__interrupt_states__last_val",
    "lib__writ__specific_dispatching__last_val"]
assert all(fixed["fixed_lifetime_table_growth"][name] == 0 for name in zero_tables)
result = dict(scope="Source-selected native Main ALI serialization premises; manual frontier argument required",
    compiler_execution=False, inputs=identities, selected_specifications=inventory,
    max_fixed_source_name_length=max(v["max_source_word_length"] for v in inventory.values()),
    max_external_name_length=max(len(name) for v in inventory.values() for name in v["external_names"]),
    max_array_dimensions=1, max_interface_progenitors=0,
    fixed_instantiation_depth_allowance=fixed["fixed_generic_instances"],
    fixed_nonpath_name_bound=fixed["names"]["maximum_recorded_nonpath_spelling_length"],
    unit_table_last_allowance=fixed["fixed_lifetime_table_growth"]["lib__units__last_val"],
    unit_flag_character_allowance=sum(map(len, unit_literals))+1,
    unit_record_field_count=unit_fields,
    empty_selected_tables=zero_tables,
    restrictions=dict(boolean_count=boolean_count, parameter_count=parameter_count,
        max_name_length=max(map(len, restrictions))),
    verbose_library_version="GNAT Lib v"+re.search(r'Library_Version\s*:\s*constant String\s*:=\s*"([^"]+)"', serializer["gnatvsn.ads"])[1],
    max_library_name_length=max_library_name,
    max_line=2*max_library_name+64, buffer_bytes=1000*(2*max_library_name+64),
    current_source_has_no_generic_types_or_import_export=True,
    complete_native_capacity_result=False)
args.output.write_text(json.dumps(result, indent=2, sort_keys=True)+"\n")
print(f"Reconciled {len(identities)} source inputs; {len(inventory)} selected specifications")
