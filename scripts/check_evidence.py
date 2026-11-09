#!/usr/bin/env python3
"""Audit GNATprove 16.1 evidence for every Silver-owned compilation unit.

This development/CI check supplements the compiler's SPARK verification. It does
not implement admission, compilation, or a substitute theorem about Silver.
"""

from __future__ import annotations

import argparse
from collections import Counter
from collections.abc import Mapping
import hashlib
import json
from pathlib import Path
import re
import sys

if __package__:
    from .platforms import native_layout
    from .bootstrap import runtime_source_configuration
else:
    from platforms import native_layout
    from bootstrap import runtime_source_configuration

ROOT = Path(__file__).resolve().parents[1]

# These are bodyless declarations of approved existing OS/runtime entry points.
# GNATprove labels their imported functions "spec", not "all". Pin their complete declaration and
# contract tokens (comments/whitespace excluded), not just their filenames.
# Any interface change requires reviewing the external trust boundary again.
TRUSTED_IMPORT_SPECS = {
    # Existing Ada.Environment_Variables.Value (Name, Default), stable environment.
    "silver_image_runtime.ads": "c0c23f506cf7729cdf3d25aa17947a3c38fd0de950121a33d34661c36147daba",
    # POSIX link: atomic publication without replacing an existing theorem file.
    "silver_image_libc.ads": "a238d42e792493f88179a0cb75bf21a55417911edc15f80726c86760fa48cd56",
    # fopen, fgetc, fputc, ferror, fclose, system, mkdir, mkdtemp
    "silver_libc.ads": "fb760228a2f4a4521fb2ea1959c52454de49717f0c5762c4e462daf1b72b7d0d",
    # ada__command_line__argument_count, ada__command_line__argument,
    # __gnat_set_exit_status (original GNAT runtime symbols)
    "silver_runtime.ads": "1f068e3ef313bdcdc7ada3b2ca7f3d1688db337d6645c9d931baec7a245df32b",
    # System.OS_Lib.Spawn and System.Strings.Free (original GNAT Ada ABI)
    "silver_process_runtime.ads": "738da941a2d1450bace845277c8d220531dfa39735fc8315b1dacdb428e7cf21",
    # putchar, fflush and __gnat_set_exit_status (existing output/status interface)
    "silver_output_libc.ads": "ca1aaff15cdf9a2c780f92f6cace9dd49903896b37ddfb01d65833c8333fdb13",
}
TRUSTED_IMPORT_ENTITIES = {
    "silver_image_runtime": {"Silver_Image_Runtime.Environment_Value"},
    "silver_libc": {f"Silver_Libc.{name}" for name in
                    ("C_Open", "C_Get", "C_Put", "C_Error", "C_Close", "C_System", "C_Mkdir", "C_Mkdtemp")},
    "silver_runtime": {f"Silver_Runtime.{name}" for name in
                       ("Argument_Count", "Argument", "Set_Exit_Status")},
    "silver_process_runtime": {"Silver_Process_Runtime.Spawn", "Silver_Process_Runtime.Free_List"},
    "silver_output_libc": {f"Silver_Output_Libc.{name}" for name in
                           ("Put_Byte", "Flush", "Set_Exit_Status")},
    "silver_image_libc": {"Silver_Image_Libc.C_Link"},
}

# These documented proof limitations withhold information from the prover;
# they do not assume correctness, skip checks, or suppress obligations. All
# actual flow/proof checks must still be discharged. See the contracts-recursive
# and numeric-variant entries in SPARK 16.1 UG proof_limitations.rst.
PROOF_LIMITATION_NOTES = {"contracts-recursive", "numeric-variant"}
IMAGE_ADVISORY_TEXT = ('references to the "Image" attribute are handled in an imprecise way, '
                       'so nothing will be known about the evaluation of the attribute reference '
                       'apart from a bound on its length [imprecise-image]')
# The pinned producer renders the attribute using these three unit-casing forms.
IMAGE_ADVISORY_TEXTS = (IMAGE_ADVISORY_TEXT,
                        IMAGE_ADVISORY_TEXT.replace('"Image"', '"image"'),
                        IMAGE_ADVISORY_TEXT.replace('"Image"', '"IMAGE"'))
# This pinned flow limitation withholds the full-array-initialization inference;
# it neither assumes initialization nor removes a flow/proof obligation. Keep it
# separate from proof limitations and application diagnostics, and restrict it to
# the reviewed compiler body. See SPARK 16.1 UG flow_limitations.rst and
# Warn_Init_Array in the pinned producer's vc_kinds.ads.
ARRAY_INITIALIZATION_ADVISORY_TEXT = (
    'initialization of an array in FOR loop is handled imprecisely [array-initialization]')
# GNATprove and the pinned GNAT compiler use the same arithmetic association.
# This portability advisory concerns other compilers, not withheld proof facts.
# Restrict even imported-spec occurrences to the reviewed compiler origins.
OPERATOR_REASSOCIATION_ADVISORY_TEXT = (
    'possible reassociation due to missing parentheses [operator-reassociation]')
OPERATOR_REASSOCIATION_SOURCES = {
    "silver_function_bindings": {"silver_function_bindings.ads"},
    "silver_library_reports": {"silver_library_reports.adb"},
    "silver_output_profile": {"silver_output_profile.adb", "silver_function_bindings.ads"},
}
# Runtime units need verification even when the compiler Main does not call them.
# GNATprove's default only analyzes Main and its transitive dependency closure.
PROOF_OPTIONS = ["-U", "--mode=all", "--report=all", "--warnings=error",
                 "--checks-as-errors=on", "--level=2", "--prover=cvc5,z3,altergo",
                 "--timeout=30"]
TRUSTED_RUNTIME_CALLEES = {
    "Interfaces.C.To_C": "i-c.ads", "Interfaces.C.To_Ada": "i-c.ads",
    "Ada.Text_IO.Put": "a-textio.ads", "Ada.Text_IO.Put_Line": "a-textio.ads",
    "Ada.Text_IO.New_Line": "a-textio.ads",
}

# GNATprove interprets SPARK.Big_Integers (an Ada runtime rename) and the
# selected functional sequence instance mathematically. These are vendor
# premises, not proved Silver bodies. Keep names and declaration origins exact;
# audit_sources enables them only after checking the actual Static ghost
# Character/Use_Logical_Equality instance. See the SPARKlib trusted boundary.
SEQUENCE_UNIT = "silver_report_projection_model"
SEQUENCE_NAME = "Silver_Report_Projection_Model.Byte_Sequences"
SEQUENCE_INSTANCES = {
    SEQUENCE_UNIT: SEQUENCE_NAME,
    "silver_image_files": "Silver_Image_Files.Bytes",
}
SIGNED_CONVERSION_UNIT = "silver_image_files"
SIGNED_CONVERSION_NAME = "Silver_Image_Files.Counts"
SEQUENCE_VENDOR = "spark-containers-functional-infinite_sequences.ads"
SEQUENCE_DECLARATIONS = {
    "Sequence": ((74, 9),), "Length": ((103, 13),), "Get": ((110, 13),),
    "Last": ((119, 13),), "Logical_Eq": ((139, 13),), '"="': ((146, 13),),
    "Lemma_Eq_Extensional": ((157, 14),), '"<"': ((166, 13),),
    '"<="': ((178, 13),), "Equivalent_Sequences": ((194, 13),),
    "Contains": ((209, 13),), "Find": ((227, 13),),
    "Empty_Sequence": ((245, 13),), "Set": ((255, 13),),
    "Add": ((269, 13), (282, 13)), "Remove": ((311, 13),),
    "Iter_First": ((383, 13),), "Iter_Has_Element": ((386, 13),),
    "Iter_Next": ((396, 13),), "Element_Logic_Equal": ((411, 13),),
    "Constant_Range": ((417, 13),), "Equal_Prefix": ((436, 13),),
    "Equal_Except": ((450, 13), (467, 13)), "Range_Equal": ((484, 13),),
    "Range_Shifted": ((500, 13),), "Aggr_Append": ((534, 14),),
}
BIG_INTEGER_DECLARATIONS = {
    '"="': (39,), '"<"': (41,), '"<="': (43,), '">"': (45,),
    '">="': (47,), "To_Big_Integer": (49,), "To_Integer": (70,),
    "From_String": (118,), '"+"': (135,), '"-"': (129, 138),
}
BIG_INTEGER_VALIDITY_TEXT = "function Is_Valid is assumed to return True"
BIG_INTEGER_VALIDITY_LOCATIONS = {(36, 32), (54, 17), (60, 17)}


def entity_origin(entity: dict) -> tuple:
    return tuple((item.get("file"), item.get("line"), item.get("column"))
                 for item in entity.get("sloc", []))


def sequence_entities(instance: tuple[int, int, int], *, unit: str = SEQUENCE_UNIT) -> set[tuple]:
    name_prefix = SEQUENCE_INSTANCES[unit]
    line, package_column, name_column = instance
    location = (unit + ".ads", line, package_column)
    entries = {(name_prefix, ((unit + ".ads", line, name_column),))}
    for name, positions in SEQUENCE_DECLARATIONS.items():
        for vendor_line, column in positions:
            entries.add((name_prefix + "." + name,
                         ((SEQUENCE_VENDOR, vendor_line, column), location)))
    entries.add((name_prefix + ".Eq_Checks.Logical_Eq",
                 (("spark-containers-parameter_checks.ads", 54, 16),
                  (SEQUENCE_VENDOR, 354, 4), location)))
    return entries


def signed_conversion_entities(instance: tuple[int, int, int]) -> set[tuple]:
    """The two vendor specs of the reviewed byte-count conversion instance."""
    line, package_column, _ = instance
    location = (SIGNED_CONVERSION_UNIT + ".ads", line, package_column)
    return {(SIGNED_CONVERSION_NAME + "." + name,
             (("a-nbnbin.ads", vendor_line, 16), location))
            for name, vendor_line in (("To_Big_Integer", 82), ("From_Big_Integer", 85))}


def big_integer_callee(entity: dict) -> bool:
    return any(entity.get("name") == "Ada.Numerics.Big_Numbers.Big_Integers." + name
               and entity_origin(entity) == (("a-nbnbin.ads", line, 13),)
               for name, lines in BIG_INTEGER_DECLARATIONS.items() for line in lines)


def big_integer_validity(rule: str, file: str, line: int, column: int,
                         message: dict) -> bool:
    return (rule == "error" and file == "a-nbnbin.ads"
            and (line, column) in BIG_INTEGER_VALIDITY_LOCATIONS
            and message == {"text": BIG_INTEGER_VALIDITY_TEXT})


class EvidenceError(ValueError):
    """The supplied reports do not establish complete successful analysis."""


def require(condition: bool, message: str) -> None:
    if not condition:
        raise EvidenceError(message)


def read_json(path: Path) -> dict:
    require(path.is_file(), f"missing report: {path}")
    value = json.loads(path.read_text())
    require(isinstance(value, dict), f"not a report object: {path}")
    return value


def source_tokens(source: Path) -> list[str]:
    """Tokenize the deliberately ASCII compiler-source policy subset.

    Reject all unsupported bytes even in comments. In particular VT/FF end Ada
    comments, and a qualified expression's apostrophe is not a character literal.
    This gate supplements GNAT's parser; it does not parse Silver programs.
    """
    data = source.read_bytes()
    require(all(byte in (9, 10, 13) or 32 <= byte <= 126 for byte in data),
            f"{source}: unsupported compiler-source byte")
    text = data.decode("ascii")
    tokens: list[str] = []
    index = 0
    literal_predecessors = {"return", "then", "else", "is", "when", "and", "or", "not", "in"}
    while index < len(text):
        char = text[index]
        if char.isspace():
            index += 1
        elif text.startswith("--", index):
            while index < len(text) and text[index] not in "\r\n":
                index += 1
        elif char == '"':
            start = index
            index += 1
            while index < len(text):
                require(text[index] not in "\r\n", f"{source}: newline in string literal")
                if text[index] == '"':
                    index += 1
                    if index < len(text) and text[index] == '"':
                        index += 1
                        continue
                    break
                index += 1
            else:
                raise EvidenceError(f"{source}: unterminated string literal")
            tokens.append(text[start:index])
        elif char == "'" and index + 2 < len(text) and text[index + 2] == "'" and not (
                tokens and (tokens[-1] in (")", "]") or
                            (tokens[-1][0].isalpha() and tokens[-1].lower() not in literal_predecessors))):
            tokens.append(text[index:index + 3])
            index += 3
        elif char.isalpha():
            start = index
            while index < len(text) and (text[index].isalnum() or text[index] == "_"):
                index += 1
            tokens.append(text[start:index])
        else:
            require(char != "%", f"{source}: alternate percent-delimited strings are outside the compiler policy")
            tokens.append(char)
            index += 1
    return tokens


def audit_sequence_instance(source: Path) -> tuple[int, int, int]:
    tokens = "".join(source_tokens(source)).lower()
    require(source.stem in SEQUENCE_INSTANCES, f"{source}: unreviewed proof-container unit")
    if source.stem == SEQUENCE_UNIT:
        declaration = (
            "packagesilver_report_projection_modelwithspark_mode=>on,ghost=>staticis"
            "usespark.big_integers;usesilver_report_projection_types;"
            "packagebyte_sequencesisnewspark.containers.functional.infinite_sequences"
            "(element_type=>character,use_logical_equality=>true);")
    else:
        # This executable unit has static ghost observations; the instance's
        # element/equality policy and every observation declaration stay exact.
        declaration = (
            "packagesilver_image_fileswithspark_mode=>onis"
            "packagemodelrenamessilver_image_model;usetypemodel.plan;"
            "usetypemodel.plan_kind;usetypemodel.byte_count;"
            "packagebytesisnewspark.containers.functional.infinite_sequences"
            "(element_type=>character,use_logical_equality=>true);usetypebytes.sequence;")
        for observation in ("read_bytes", "copied_bytes", "written_bytes"):
            require(tokens.count(observation + ":bytes.sequence:=bytes.empty_sequencewithghost=>static;") == 1,
                    f"{source}: unreviewed proof-container ghost observation")
    require(tokens.count(declaration) == 1,
            f"{source}: unreviewed proof-container instance or ghost context")
    text = source.read_text()
    name = SEQUENCE_INSTANCES[source.stem].split(".")[-1]
    declarations = list(re.finditer(
        r"(?mi)^[ \t]*(package)[ \t]+(" + re.escape(name) + r")\s+is\s+new\b", text))
    require(len(declarations) == 1, f"{source}: ambiguous proof-container instance location")
    match = declarations[0]
    start = text.rfind("\n", 0, match.start(1)) + 1
    return (text.count("\n", 0, match.start(1)) + 1,
            match.start(1) - start + 1, match.start(2) - start + 1)


def audit_signed_conversion_instance(source: Path) -> tuple[int, int, int]:
    # The complete declaration prefix fixes both visible generic resolution and
    # its actual signed type. No earlier declaration can shadow either name.
    tokens = "".join(source_tokens(source)).lower()
    declaration = (
        "withada.text_io;withspark.big_integers;"
        "withspark.containers.functional.infinite_sequences;"
        "withsilver_image_model;withsilver_platform;"
        "packagesilver_image_fileswithspark_mode=>onis"
        "packagemodelrenamessilver_image_model;usetypemodel.plan;"
        "usetypemodel.plan_kind;usetypemodel.byte_count;"
        "packagebytesisnewspark.containers.functional.infinite_sequences"
        "(element_type=>character,use_logical_equality=>true);usetypebytes.sequence;"
        "usespark.big_integers;packagecountsisnewsigned_conversions(model.byte_count);")
    require(source.stem == SIGNED_CONVERSION_UNIT and tokens.startswith(declaration)
            and tokens.count("packagecountsisnew") == 1,
            f"{source}: unreviewed signed-conversion instance or context")
    text = source.read_text()
    declarations = list(re.finditer(
        r"(?mi)^[ \t]*(package)[ \t]+(Counts)\s+is\s+new\b", text))
    require(len(declarations) == 1, f"{source}: ambiguous signed-conversion instance location")
    match = declarations[0]
    start = text.rfind("\n", 0, match.start(1)) + 1
    return (text.count("\n", 0, match.start(1)) + 1,
            match.start(1) - start + 1, match.start(2) - start + 1)


def audit_reports(report_dir: Path, expected_units: set[str],
                  trusted_import_units: set[str] | None = None, *,
                  effective_command: list[str] | None = None,
                  application_kind: str | None = None,
                  application_functions: tuple[str, ...] = (),
                  application_procedures: Mapping[str, tuple[str, ...]] | None = None,
                  indexed_main: bool = False,
                  proof_instance: tuple[int, int, int] | None = None,
                  proof_instances: dict[str, tuple[int, int, int]] | None = None,
                  signed_conversion_instance: tuple[int, int, int] | None = None) -> dict[str, int]:
    """Fail closed on missing coverage, skipped work, assumptions or failures."""
    require(bool(expected_units), "no implementation units selected for auditing")
    require(not indexed_main or "main" in expected_units,
            "indexed Main audit requires Main")
    # Indexed project naming changes Main's artifact and coverage-summary name,
    # not the entity identity used in diagnostics, dependencies or source locations.
    report_names = {unit: ("main~1.spark" if indexed_main and unit == "main"
                           else f"{unit}.spark") for unit in expected_units}
    require({path.name for path in report_dir.glob("*.spark")} == set(report_names.values()),
            "missing report or unexpected compilation-unit report")
    trusted_import_units = trusted_import_units or set()
    stats = {"units": 0, "entities": 0, "flow_checks": 0, "proof_checks": 0,
             "limitation_notes": 0, "imported_entities": 0,
             "trusted_math_notes": 0, "vendor_spec_entities": 0,
             "array_initialization_advisories": 0, "operator_reassociation_advisories": 0}
    instances = dict(proof_instances or {})
    if proof_instance is not None:
        require(SEQUENCE_UNIT not in instances, "duplicate compiler proof-container instance")
        instances[SEQUENCE_UNIT] = proof_instance
    require(not instances or (instances.keys() <= expected_units
            and instances.keys() <= SEQUENCE_INSTANCES.keys() and application_kind is None),
            "vendor proof premises require the reviewed compiler model")
    vendor_entities = {unit: sequence_entities(instance, unit=unit)
                       for unit, instance in instances.items()}
    if signed_conversion_instance is not None:
        require(SIGNED_CONVERSION_UNIT in instances and application_kind is None,
                "signed-conversion premises require the reviewed compiler model")
        vendor_entities[SIGNED_CONVERSION_UNIT].update(
            signed_conversion_entities(signed_conversion_instance))
    require(application_kind in (None, "static", "argument", "assigned", "selected"),
            "unknown application report policy")
    require(not application_functions or application_kind is not None,
            "application function inventory requires an application policy")
    require(len(application_functions) <= 4096 // 32
            and all(isinstance(name, str) and re.fullmatch(
                r"[A-Za-z]([A-Za-z0-9]|_[A-Za-z0-9])*", name) is not None
                    for name in application_functions),
            "application: invalid source function inventory")
    function_names = {"main." + name.lower() for name in application_functions}
    require(len(function_names) == len(application_functions),
            "application: duplicate source function name")
    procedures = {} if application_procedures is None else application_procedures
    require(isinstance(procedures, Mapping)
            and (not procedures or application_kind is not None),
            "application procedure inventory requires an application policy")
    identifier = r"[A-Za-z]([A-Za-z0-9]|_[A-Za-z0-9])*"
    require(len(procedures) <= 4096 // 32
            and all(isinstance(name, str) and re.fullmatch(identifier, name) is not None
                    and isinstance(outputs, tuple)
                    and all(isinstance(output, str) and re.fullmatch(identifier, output) is not None
                            for output in outputs)
                    and len({output.lower() for output in outputs}) == len(outputs)
                    for name, outputs in procedures.items())
            and sum(len(outputs) for outputs in procedures.values()) <= 4096 // 7,
            "application: invalid source procedure inventory")
    procedure_outputs = {"main." + name.lower(): outputs for name, outputs in procedures.items()}
    procedure_names = set(procedure_outputs)
    require(len(procedure_names) == len(procedures) and not (function_names & procedure_names),
            "application: duplicate source subprogram name")
    callable_names = function_names | procedure_names
    if application_kind is not None:
        require("main" in expected_units, "application audit requires Main")
        stats["assignment_advisories"] = 0
        stats["image_advisories"] = 0
        stats["termination_checks"] = 0
        stats["initialization_checks"] = 0
    reports = {unit: read_json(report_dir / name) for unit, name in report_names.items()}
    owned_names: set[str] = set()
    owned_locations: dict[str, set[str]] = {}
    diagnostics: Counter = Counter()
    assignment_diagnostics: Counter = Counter()
    math_diagnostics: Counter = Counter()
    image_diagnostics: Counter = Counter()
    array_initialization_diagnostics: Counter = Counter()
    operator_reassociation_diagnostics: Counter = Counter()
    summary = (report_dir / "gnatprove.out").read_text()
    summaries_by_report = {name: (int(analyzed), int(total)) for name, analyzed, total in
                          re.findall(r"in unit ([^,\s]+), (\d+) subprograms and packages out of (\d+) analyzed", summary)}
    summary_units = {Path(name).stem: unit for unit, name in report_names.items()}
    require(summaries_by_report.keys() == summary_units.keys(),
            "coverage summary has missing or unexpected units")
    summaries = {summary_units[name]: counts for name, counts in summaries_by_report.items()}
    for unit, report in reports.items():
        for key, entity in report.get("entities", {}).items():
            if any(Path(location["file"]).stem == unit for location in entity.get("sloc", [])):
                owned_names.add(entity["name"])
                owned_locations.setdefault(entity["name"], set()).update(
                    Path(location["file"]).name for location in entity["sloc"])
    for unit in sorted(expected_units):
        report = reports[unit]
        require(report.get("progress") == "PROGRESS_PROOF", f"{unit}: proof phase incomplete")
        require(report.get("stop_reason") == "STOP_REASON_NONE", f"{unit}: analysis stopped early")
        entities = report.get("entities")
        coverage = report.get("spark")
        require(isinstance(entities, dict) and bool(entities), f"{unit}: no analyzed entities")
        require(isinstance(coverage, dict) and bool(coverage), f"{unit}: no SPARK coverage")
        application = application_kind is not None and unit == "main"
        assignment = application and application_kind in ("assigned", "selected")
        comparison = application
        if application:
            # Source membership selects a policy; this helper checks the emitted
            # producer shape without inferring source membership from a report.
            main_entities = {key: value for key, value in entities.items()
                             if value.get("name", "").lower() == "main"}
            local_entities = {key: value for key, value in entities.items()
                              if value.get("name", "").lower() in function_names}
            procedure_entities = {key: value for key, value in entities.items()
                                  if value.get("name", "").lower() in procedure_names}
            require(len(procedure_entities) == len(procedure_names)
                    and {item.get("name", "").lower() for item in procedure_entities.values()} == procedure_names,
                    "application: missing or duplicate source procedure entity")
            application_entities = main_entities | local_entities | procedure_entities
            require(len(local_entities) == len(function_names)
                    and {item.get("name", "").lower() for item in local_entities.values()} == function_names,
                    "application: missing or duplicate source function entity")
            termination_entities: set[str] = set()
            initialization_entities: set[tuple[str, str]] = set()
            expected_initializations = {(key, output) for key, value in procedure_entities.items()
                                        for output in procedure_outputs[value["name"].lower()]}
            output_callees = {"Silver_IO.Put_Line", "Silver_IO.Put"}
            callees = {name: "silver_io.ads" for name in output_callees}
            if application_kind in ("argument", "selected"):
                callees.update({name: "silver_arguments.ads" for name in
                                ("Silver_Arguments.First_Or_Default",
                                 "Silver_Arguments.Input_Is_Valid", "Silver_Arguments.Reject")})
            bare = len(entities) == len(application_entities)
            expected_names = set() if bare else set(callees)
            actual_names = [value.get("name") for key, value in entities.items()
                            if key not in application_entities]
            if not bare:
                expected_names.difference_update(output_callees - set(actual_names))
            if application_kind in ("argument", "selected") and not bare and "Silver_Arguments.Input_Is_Valid" not in actual_names:
                expected_names.remove("Silver_Arguments.Input_Is_Valid")
            require(len(main_entities) == 1 and set(actual_names) == expected_names
                    and len(actual_names) == len(expected_names)
                    and coverage.keys() == application_entities.keys()
                    and all(value == "all" for value in coverage.values()),
                    "application: unexpected entities or application coverage")
            main_key, main = next(iter(main_entities.items()))
            for key, item in entities.items():
                filename = "main.adb" if key in application_entities else callees[item["name"]]
                require(bool(item.get("sloc"))
                        and all(location.get("file") == filename
                                and type(location.get("line")) is int and location["line"] > 0
                                and type(location.get("column")) is int and location["column"] > 0
                                for location in item["sloc"]),
                        "application: unexpected entity declaration")
            require(isinstance(report.get("flow"), list),
                    "application: missing flow diagnostics")
        require(coverage.keys() <= entities.keys(), f"{unit}: coverage names an unknown entity")
        for key, value in coverage.items():
            trusted_import = (unit in trusted_import_units and value == "spec"
                              and entities.get(key, {}).get("name") in TRUSTED_IMPORT_ENTITIES.get(unit, set()))
            trusted_vendor = (value == "spec"
                              and (entities[key].get("name"), entity_origin(entities[key]))
                                  in vendor_entities.get(unit, set()))
            require(value == "all" or trusted_import or trusted_vendor,
                    f"{unit}: entity outside full SPARK: {entities[key].get('name')} "
                    f"at {entity_origin(entities[key])}")
            if trusted_import:
                stats["imported_entities"] += 1
            if trusted_vendor:
                stats["vendor_spec_entities"] += 1
        # entities may also name callees in trusted runtime units. Coverage is
        # required for the entities declared by this unit, not those imports.
        own_entities = {
            key for key, value in entities.items()
            if any(Path(location["file"]).stem == unit for location in value.get("sloc", []))
        }
        require(bool(own_entities), f"{unit}: no owned entities in report")
        require(own_entities <= coverage.keys(), f"{unit}: missing owned entity coverage")
        require(summaries[unit] == (sum(coverage[key] == "all" for key in own_entities), len(own_entities)),
                f"{unit}: summary/entity coverage mismatch")
        if unit in vendor_entities:
            require(vendor_entities[unit] <= {(entities[key].get("name"), entity_origin(entities[key]))
                                        for key in own_entities},
                    f"{unit}: missing reviewed vendor declaration coverage")
        if unit in trusted_import_units:
            import_names = {entities[key]["name"] for key in own_entities}
            require(TRUSTED_IMPORT_ENTITIES[unit] <= import_names,
                    f"{unit}: missing approved import declaration coverage")
        for key in ("skip_flow_proof", "skip_proof", "pragma_assume"):
            require(report.get(key) == [], f"{unit}: missing or nonempty {key}")
        assumptions = report.get("assumptions")
        require(isinstance(assumptions, list), f"{unit}: missing assumption dependencies")
        for entry in assumptions:
            require(isinstance(entry.get("assumptions"), list), f"{unit}: malformed assumption dependencies")
            for reference in [entry.get("claim", {}), *entry["assumptions"]]:
                require(reference.get("predicate") in {"CLAIM_POST", "CLAIM_AORTE", "CLAIM_EFFECTS"},
                        f"{unit}: unknown assumption predicate")
                if application:
                    require(type(reference.get("arg")) is int and reference["arg"] > 0,
                            "application: dependency references must be positive integer entity identifiers")
                entity = entities.get(f" {reference.get('arg')}", entities.get(str(reference.get("arg"))))
                require(isinstance(entity, dict), f"{unit}: assumption references unknown entity")
                name = entity.get("name")
                if application and name.lower() in callable_names:
                    require(reference["predicate"] in {"CLAIM_AORTE", "CLAIM_EFFECTS"},
                            "application: local subprogram has an unapproved claim")
                locations = entity.get("sloc", [])
                trusted_runtime = name in TRUSTED_RUNTIME_CALLEES and bool(locations) and all(
                    Path(location["file"]).name == TRUSTED_RUNTIME_CALLEES[name]
                    for location in locations)
                owned_dependency = name in owned_names and bool(locations) and all(
                    Path(location["file"]).name in owned_locations[name] for location in locations)
                trusted_math = bool(instances) and big_integer_callee(entity)
                require(application or owned_dependency or trusted_runtime or trusted_math,
                        f"{unit}: unapproved external assumption dependency {name}")
        for key in ("flow", "proof", "warn_error"):
            records = report.get(key)
            require(isinstance(records, list), f"{unit}: missing {key} results")
            for record in records:
                require(isinstance(record, dict), f"{unit}: malformed {key} record")
                reassociation_note = (record.get("rule") == "operator-reassociation"
                                      or (isinstance(record.get("message"), dict)
                                          and record["message"].get("text") == OPERATOR_REASSOCIATION_ADVISORY_TEXT))
                if reassociation_note:
                    require(application_kind is None and key == "warn_error"
                            and set(record) == {"rule", "severity", "how_proved", "file", "line", "col",
                                                "message", "unproved_status", "check_tree", "suppressed"}
                            and record.get("rule") == "operator-reassociation"
                            and record.get("severity") == "warning"
                            and record.get("how_proved") == "trivial"
                            and isinstance(record.get("file"), str)
                            and record.get("file") in OPERATOR_REASSOCIATION_SOURCES.get(unit, set())
                            and type(record.get("line")) is int and record["line"] > 0
                            and type(record.get("col")) is int and record["col"] > 0
                            and record.get("message") == {"text": OPERATOR_REASSOCIATION_ADVISORY_TEXT}
                            and record.get("unproved_status") == {"status": "unknown"}
                            and record.get("check_tree") == {}
                            and record.get("suppressed") == "",
                            f"{unit}: unexpected operator-reassociation advisory")
                    stats["operator_reassociation_advisories"] += 1
                array_note = (record.get("rule") == "array-initialization"
                              or (isinstance(record.get("message"), dict)
                                  and record["message"].get("text") == ARRAY_INITIALIZATION_ADVISORY_TEXT))
                if array_note:
                    require(((application_kind is None and unit == "silver_output_profile") or application)
                            and key == "warn_error"
                            and set(record) == {"rule", "severity", "how_proved", "file", "line", "col",
                                                "message", "unproved_status", "check_tree", "suppressed"}
                            and record.get("rule") == "array-initialization"
                            and record.get("severity") == "warning"
                            and record.get("how_proved") == "trivial"
                            and record.get("file") == unit + ".adb"
                            and type(record.get("line")) is int and record["line"] > 0
                            and type(record.get("col")) is int and record["col"] > 0
                            and record.get("message") == {"text": ARRAY_INITIALIZATION_ADVISORY_TEXT}
                            and record.get("unproved_status") == {"status": "unknown"}
                            and record.get("check_tree") == {}
                            and record.get("suppressed") == "",
                            f"{unit}: unexpected array-initialization advisory")
                    stats["array_initialization_advisories"] += 1
                image_note = application and key == "warn_error" and not array_note
                if image_note:
                    require(record.get("severity") == "warning"
                            and record.get("how_proved") == "trivial"
                            and record.get("rule") == "imprecise-image"
                            and record.get("file") == "main.adb"
                            and type(record.get("line")) is int and record["line"] > 0
                            and type(record.get("col")) is int and record["col"] > 0
                            and isinstance(record.get("message"), dict)
                            and record["message"].get("text") in IMAGE_ADVISORY_TEXTS
                            and isinstance(record.get("unproved_status"), dict)
                            and record["unproved_status"].get("status") == "unknown"
                            and record.get("check_tree") == {}
                            and record.get("suppressed") == ""
                            and not any(field in record for field in
                                        ("entity", "justification", "justified", "annot_kind", "justif_msg")),
                            "application: unexpected Image advisory")
                    stats["image_advisories"] += 1
                termination = (application and key == "flow"
                               and record.get("rule") == "SUBPROGRAM_TERMINATION")
                if termination:
                    entity_key = f" {record.get('entity')}"
                    if entity_key not in entities:
                        entity_key = str(record.get("entity"))
                    local = local_entities.get(entity_key)
                    require(local is not None and entity_key not in termination_entities
                            and record.get("severity") == "info"
                            and record.get("how_proved") == "flow"
                            and record.get("file") == "main.adb"
                            and type(record.get("line")) is int and record["line"] > 0
                            and type(record.get("col")) is int and record["col"] > 0
                            and type(record.get("entity")) is int and record["entity"] > 0
                            and record.get("message") == {"text":
                                f'implicit aspect Always_Terminates on "{local["name"].split(".")[1]}" '
                                "has been proved, subprogram will terminate"}
                            and not any(field in record for field in
                                        ("justification", "justified", "suppressed", "annot_kind", "justif_msg")),
                            "application: unexpected function termination record")
                    termination_entities.add(entity_key)
                    stats["termination_checks"] += 1
                initialization = (application and key == "flow"
                                  and record.get("rule") == "UNINITIALIZED")
                if initialization:
                    entity_key = f" {record.get('entity')}"
                    if entity_key not in entities:
                        entity_key = str(record.get("entity"))
                    procedure = procedure_entities.get(entity_key)
                    outputs = (() if procedure is None else procedure_outputs[procedure["name"].lower()])
                    matching = [output for output in outputs
                                if record.get("message") == {"text": f'initialization of "{output}" proved'}]
                    require(procedure is not None and len(matching) == 1
                            and (entity_key, matching[0]) not in initialization_entities
                            and record.get("severity") == "info"
                            and record.get("how_proved") == "flow"
                            and record.get("file") == "main.adb"
                            and type(record.get("line")) is int and record["line"] > 0
                            and type(record.get("col")) is int and record["col"] > 0
                            and type(record.get("entity")) is int and record["entity"] > 0
                            and not any(field in record for field in
                                        ("justification", "justified", "suppressed", "annot_kind", "justif_msg")),
                            "application: unexpected procedure output initialization record")
                    initialization_entities.add((entity_key, matching[0]))
                    stats["initialization_checks"] += 1
                advisory = application and key == "flow" and not termination and not initialization
                if advisory:
                    require(record.get("severity") == "warning"
                            and record.get("how_proved") == "flow"
                            and record.get("file") == "main.adb"
                            and type(record.get("line")) is int and record["line"] > 0
                            and type(record.get("col")) is int and record["col"] > 0
                            and type(record.get("entity")) is int and record["entity"] > 0
                            and entities.get(f" {record['entity']}", entities.get(str(record["entity"]))) in application_entities.values()
                            and ((record.get("rule") == "UNUSED_VARIABLE"
                                  and entities.get(f" {record['entity']}", entities.get(str(record["entity"]))) in (local_entities | procedure_entities).values()
                                  and re.fullmatch(r'unused variable "[A-Za-z]([A-Za-z0-9]|_[A-Za-z0-9])*"',
                                                   record.get("message", {}).get("text", "")) is not None)
                                 or (record.get("rule") == "INEFFECTIVE"
                                  and (re.fullmatch(r'initialization of "[A-Za-z]([A-Za-z0-9]|_[A-Za-z0-9])*" has no effect',
                                                    record.get("message", {}).get("text", "")) is not None
                                       or record.get("message", {}).get("text") in {
                                           f'"{name}" is set by "{operation}" but not used after the call'
                                           for name in ("Written_Count", "Flushed", "Succeeded", "Written_Bytes")
                                           for operation in ("Put_Line", "Put")}
                                       or (assignment and record.get("message", {}).get("text") == "unused assignment")
                                       or (comparison and record.get("message", {}).get("text") == "statement has no effect")))
                                 or (comparison and record.get("rule") == "DEAD_CODE"
                                     and record.get("message", {}).get("text") == "this statement is never reached")),
                            "assignment: unexpected flow diagnostic")
                    require(len(record["message"]["text"]) <= len('initialization of "" has no effect') + 4096,
                            "assignment: initializer name exceeds source bound")
                    require(not any(field in record for field in
                                    ("justification", "justified", "suppressed", "annot_kind", "justif_msg")),
                            "assignment: suppressed or justified diagnostic")
                    stats["assignment_advisories"] += 1
                if application and key == "proof":
                    require(record.get("severity") == "info" and record.get("how_proved") == "prover"
                            and record.get("rule") in {"VC_RANGE_CHECK", "VC_LENGTH_CHECK", "VC_OVERFLOW_CHECK", "VC_DIVISION_CHECK", "VC_INDEX_CHECK"}
                            and record.get("file") == "main.adb"
                            and type(record.get("line")) is int and record["line"] > 0
                            and type(record.get("col")) is int and record["col"] > 0
                            and type(record.get("entity")) is int and record["entity"] > 0
                            and entities.get(f" {record['entity']}", entities.get(str(record["entity"]))) in application_entities.values(),
                            "application: expected a proved application range, length, overflow, division or index check")
                    require(not any(field in record for field in
                                    ("justification", "justified", "suppressed", "annot_kind", "justif_msg")),
                            "application: suppressed or justified safety check")
                limitation = (key == "warn_error" and record.get("rule") in PROOF_LIMITATION_NOTES
                              and record.get("severity") == "warning")
                math_note = (bool(instances) and key == "warn_error"
                             and record.get("severity") == "warning"
                             and record.get("how_proved") == "trivial"
                             and record.get("unproved_status") == {"status": "unknown"}
                             and big_integer_validity(record.get("rule"), record.get("file"),
                                                      record.get("line"), record.get("col"),
                                                      record.get("message")))
                require(record.get("message", {}).get("text") != BIG_INTEGER_VALIDITY_TEXT or math_note,
                        "vendor math note: unreviewed premise classification")
                require(record.get("severity") == "info" or limitation or advisory or math_note or image_note or array_note or reassociation_note,
                        f"{unit}: {key} diagnostic is not proved/info: {record}")
                if limitation:
                    stats["limitation_notes"] += 1
                if math_note:
                    stats["trusted_math_notes"] += 1
                require(record.get("how_proved") in ("flow", "prover", "trivial"),
                        f"{unit}: justified or unproved {key} result: {record}")
                require(not record.get("justification") and not record.get("justified"),
                        f"{unit}: justified result")
                require(("suppressed" not in record or ((limitation or image_note or array_note or reassociation_note) and record["suppressed"] == ""))
                        and not record.get("annot_kind") and not record.get("justif_msg"),
                        f"{unit}: suppressed result")
                require(isinstance(record.get("rule"), str) and isinstance(record.get("file"), str)
                        and isinstance(record.get("line"), int) and isinstance(record.get("col"), int),
                        f"{unit}: incomplete diagnostic location/rule")
                if key in ("flow", "proof"):
                    require(f" {record.get('entity')}" in entities or str(record.get("entity")) in entities,
                            f"{unit}: diagnostic references unknown entity")
                diagnostic = (record["rule"], Path(record["file"]).name, record["line"], record["col"],
                              record.get("message", {}).get("text"))
                diagnostics[diagnostic] += 1
                if advisory:
                    assignment_diagnostics[diagnostic] += 1
                if math_note:
                    math_diagnostics[diagnostic] += 1
                if image_note:
                    image_diagnostics[diagnostic] += 1
                if array_note:
                    array_initialization_diagnostics[diagnostic] += 1
                if reassociation_note:
                    operator_reassociation_diagnostics[diagnostic] += 1
        if application:
            require(termination_entities == local_entities.keys(),
                    "application: missing source function termination coverage")
            require(initialization_entities == expected_initializations,
                    "application: missing source procedure output initialization coverage")
        stats["units"] += 1
        stats["entities"] += len(own_entities)
        stats["flow_checks"] += (len(termination_entities) + len(initialization_entities)) if application else len(report["flow"])
        stats["proof_checks"] += len(report["proof"])

    sarif = read_json(report_dir / "gnatprove.sarif")
    require(sarif.get("version") == "2.1.0", "unsupported SARIF schema")
    runs = sarif.get("runs")
    require(isinstance(runs, list) and len(runs) == 1, "missing or ambiguous GNATprove invocation")
    run = runs[0]
    require(re.match(r"FSF 16\.1\.\d+\b", run.get("tool", {}).get("driver", {}).get("version", "")) is not None,
            "unexpected GNATprove version family")
    invocations = run.get("invocations")
    require(isinstance(invocations, list) and len(invocations) == 1, "missing GNATprove execution status")
    invocation = invocations[0]
    require(invocation.get("executionSuccessful") is True and invocation.get("exitCode") == 0,
            "GNATprove invocation failed")
    command_line = invocation.get("commandLine", "")
    require(isinstance(command_line, str), "missing GNATprove command line")
    if effective_command is not None:
        # GNATprove 16.1 records argv joined by spaces, without shell quoting.
        # Its lossy string cannot recover boundaries in paths containing spaces
        # or quotes. Full audits use the actual captured argv and check this
        # producer representation exactly before inspecting the options.
        require(command_line == " ".join(effective_command),
                "recorded GNATprove invocation differs from the effective command")
        arguments = effective_command
    else:
        # Standalone report audits have no captured argv. Inspect literal
        # producer tokens conservatively; do not interpret quotes as shell code.
        arguments = command_line.split()
    require("--mode=all" in arguments and "--report=all" in arguments,
            "GNATprove did not record full flow/proof analysis and reporting")
    # A later repeated switch wins in GNATprove; membership alone is insufficient.
    for option, expected in (("--mode", "all"), ("--report", "all")):
        values = [argument.split("=", 1)[1] for argument in arguments if argument.startswith(option + "=")]
        require(values == [expected], f"conflicting/repeated {option} configuration")
    require(not callable_names or "--no-inlining" in arguments,
            "application: subprogram proofs require modular no-inlining analysis")
    results = run.get("results")
    require(isinstance(results, list), "missing SARIF results")
    sarif_diagnostics: Counter = Counter()
    for result in results:
        reassociation_note = (result.get("ruleId") == "operator-reassociation"
                              or (isinstance(result.get("message"), dict)
                                  and result["message"].get("text") == OPERATOR_REASSOCIATION_ADVISORY_TEXT))
        if reassociation_note:
            # Compare before extracting locations so missing/malformed nested
            # fields fail closed as well. Multiset equality below retains every
            # occurrence, including a spec warning repeated by an importing unit.
            require(any(result == {
                        "ruleId": "operator-reassociation", "kind": "open", "level": "warning",
                        "message": {"text": OPERATOR_REASSOCIATION_ADVISORY_TEXT},
                        "locations": [{"physicalLocation": {
                            "artifactLocation": {"uri": diagnostic[1]},
                            "region": {"startLine": diagnostic[2], "startColumn": diagnostic[3]}}}],
                        "suppressions": [{"kind": "external"}]}
                        for diagnostic in operator_reassociation_diagnostics),
                    "SARIF must preserve the exact operator-reassociation advisory classification")
        locations = result.get("locations", [])
        require(len(locations) == 1, "missing/ambiguous SARIF diagnostic location")
        location = locations[0]["physicalLocation"]
        region = location["region"]
        diagnostic = (result.get("ruleId"), Path(location["artifactLocation"]["uri"]).name,
                      region["startLine"], region["startColumn"],
                      result.get("message", {}).get("text"))
        if reassociation_note:
            require(type(region["startLine"]) is int and type(region["startColumn"]) is int,
                    "SARIF operator-reassociation locations must be integers")
        advisory = (diagnostic in assignment_diagnostics
                    and location["artifactLocation"]["uri"] == "main.adb"
                    and result.get("kind") == "open" and result.get("level") == "warning")
        require(diagnostic not in assignment_diagnostics or advisory,
                "assignment: SARIF must preserve unused-value advisory classification")
        limitation = (result.get("ruleId") in PROOF_LIMITATION_NOTES
                      and result.get("kind") in ("open", "informational")
                      and result.get("level") == "warning")
        math_note = (diagnostic in math_diagnostics
                     and result.get("kind") == "open" and result.get("level") == "warning"
                     and big_integer_validity(result.get("ruleId"), location["artifactLocation"]["uri"],
                                              region["startLine"], region["startColumn"],
                                              result.get("message")))
        require(diagnostic not in math_diagnostics or math_note,
                "vendor math note: SARIF must preserve the exact premise classification")
        image_note = (diagnostic in image_diagnostics
                      and location["artifactLocation"]["uri"] == "main.adb"
                      and result.get("kind") == "open" and result.get("level") == "warning")
        require(diagnostic not in image_diagnostics or image_note,
                "application: SARIF must preserve the exact Image advisory classification")
        array_note = diagnostic in array_initialization_diagnostics
        if array_note:
            require(type(region["startLine"]) is int and region["startLine"] > 0
                    and type(region["startColumn"]) is int and region["startColumn"] > 0
                    and result == {
                        "ruleId": "array-initialization", "kind": "open", "level": "warning",
                        "message": {"text": ARRAY_INITIALIZATION_ADVISORY_TEXT},
                        "locations": [{"physicalLocation": {
                            "artifactLocation": {"uri": diagnostic[1]},
                            "region": {"startLine": diagnostic[2], "startColumn": diagnostic[3]}}}],
                        "suppressions": [{"kind": "external"}]},
                    "SARIF must preserve the exact array-initialization advisory classification")
        require((result.get("ruleId") != "array-initialization"
                 and result.get("message", {}).get("text") != ARRAY_INITIALIZATION_ADVISORY_TEXT) or array_note,
                "unreviewed SARIF array-initialization advisory")
        require(result.get("kind") in ("pass", "informational") or limitation or advisory or math_note or image_note or array_note or reassociation_note,
                f"SARIF result not proved: {result}")
        require(result.get("level", "none") in ("none", "note") or limitation or advisory or math_note or image_note or array_note or reassociation_note,
                f"SARIF warning/error: {result}")
        # GNATprove marks its disabled-by-default limitation diagnostics as
        # externally suppressed, as it does the pedantic reassociation advisory.
        # These producer markers are not obligation suppressions.
        suppressions = result.get("suppressions", [])
        require((not image_note and not suppressions)
                or ((limitation or image_note or array_note or reassociation_note) and suppressions == [{"kind": "external"}]),
                "suppressed SARIF diagnostic")
        sarif_diagnostics[diagnostic] += 1
    require(diagnostics == sarif_diagnostics, "SARIF and SPARK diagnostic coverage disagree")
    total_rows = re.findall(r"(?m)^Total\s+.*$", summary)
    require(len(total_rows) == 1, "missing/ambiguous proof totals in coverage summary")
    totals = re.sub(r"\([^)]*\)", "", total_rows[0]).split()[1:]
    require(len(totals) == 5, "unsupported coverage summary totals")
    counts = [0 if value == "." else int(value) for value in totals]
    require(counts == [stats["flow_checks"] + stats["proof_checks"], stats["flow_checks"],
                       stats["proof_checks"], 0, 0], "coverage summary and SPARK check totals disagree")
    return stats


def audit_sources(source_dir: Path, report_dir: Path,
                  generated_dir: Path | None = None, *,
                  effective_command: list[str] | None = None) -> dict[str, int]:
    require(source_dir.is_dir(), f"missing source directory: {source_dir}")
    sources = sorted(path for path in source_dir.rglob("*") if path.suffix in (".ads", ".adb"))
    if generated_dir is not None:
        require((generated_dir / "silver_build.ads").is_file(),
                f"missing platform configuration: {generated_dir / 'silver_build.ads'}")
        binding = generated_dir / "silver_library_sources.ads"
        require(binding.is_file(), f"missing runtime source binding: {binding}")
        require(binding.read_bytes() == runtime_source_configuration(source_dir),
                "embedded runtime source bytes differ from current source; bootstrap and rebuild")
        if (source_dir / "silver_image_adapter.adb").is_file():
            require((generated_dir / "silver_image_config.ads").is_file(),
                    "missing original Image vendor binding; bootstrap and rebuild")
        sources.extend(sorted(path for path in generated_dir.rglob("*")
                              if path.suffix in (".ads", ".adb")))
    for source in sources:
        audit_source_policy(source)
        if source.name in TRUSTED_IMPORT_SPECS:
            audit_import_spec(source)
    expected_units = {path.stem for path in sources}
    trusted_units = {path.stem for path in sources if path.name in TRUSTED_IMPORT_SPECS}
    proof_instances = {unit: audit_sequence_instance(source_dir / (unit + ".ads"))
                       for unit in SEQUENCE_INSTANCES if source_dir / (unit + ".ads") in sources}
    conversion_source = source_dir / (SIGNED_CONVERSION_UNIT + ".ads")
    conversion_instance = (audit_signed_conversion_instance(conversion_source)
                           if conversion_source in sources else None)
    stats = audit_reports(report_dir, expected_units, trusted_units,
                          effective_command=effective_command, proof_instances=proof_instances,
                          signed_conversion_instance=conversion_instance)
    for source in sources:
        report = report_dir / f"{source.stem}.spark"
        require(report.stat().st_mtime_ns >= source.stat().st_mtime_ns,
                f"{source}: proof evidence predates source; rerun GNATprove")
    return stats


def audit_source_policy(source: Path) -> None:
    # Ignore strings, character literals, comments and layout when recognizing
    # directives. Report-level checks remain necessary for skipped/justified
    # obligations; source checks also reject directives that could prevent a
    # check from being generated in the first place.
    tokens = [piece if piece.startswith('"') else piece.lower() for piece in source_tokens(source)]
    forbidden = {"assume", "suppress", "suppress_all", "assertion_policy", "check_policy",
                 "check", "annotate", "warnings"}
    # Caller-local Hide_Info removes these expression bodies from the proof
    # context; it supplies no facts and leaves every obligation required.
    hide_info_forms = {
        ("pragma", "annotate", "(", "gnatprove", ",", "hide_info", ",",
         '"Expression_Function_Body"', ",", target, ")", ";")
        for target in ("raw_list_spec", "list_spec")}
    for index, (left, right) in enumerate(zip(tokens, tokens[1:])):
        hide_info = (source.name == "silver_library_reports.adb"
                     and tuple(tokens[index:index + 12]) in hide_info_forms)
        require(left != "pragma" or right not in forbidden or hide_info,
                f"{source}: forbidden assumption/check-policy pragma {right}")
    for index, token in enumerate(tokens):
        if token == "spark_mode":
            require(tokens[index:index + 4] != ["spark_mode", "=", ">", "off"]
                    and tokens[index:index + 3] != ["spark_mode", "(", "off"],
                    f"{source}: SPARK_Mode Off is outside the compiler policy")


def audit_import_spec(source: Path) -> None:
    require(not source.with_suffix(".adb").exists(), f"{source}: trusted import has an implementation body")
    # Preserve quoted external symbol names exactly, including whitespace and
    # doubled quotes. Only layout/comments outside strings are irrelevant.
    tokens = "".join(source_tokens(source)).encode("ascii")
    actual = hashlib.sha256(tokens).hexdigest()
    require(actual == TRUSTED_IMPORT_SPECS.get(source.name),
            f"{source}: imported symbols/contracts changed; review the declared external trust boundary")


def main() -> None:
    host = native_layout(ROOT)
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source-dir", type=Path, default=ROOT / "src")
    parser.add_argument("--generated-dir", type=Path, default=host.generated)
    parser.add_argument("--report-dir", type=Path, default=host.compiler / "obj/gnatprove")
    args = parser.parse_args()
    if __package__:
        from .proof_provenance import validate_provenance
    else:
        from proof_provenance import validate_provenance
    require(args.source_dir.resolve() == (host.root / "src").resolve()
            and args.generated_dir.resolve() == host.generated.resolve(),
            "audited source directories must match the native proof provenance")
    manifest = validate_provenance(host, args.report_dir)
    stats = audit_sources(args.source_dir, args.report_dir, args.generated_dir,
                          effective_command=manifest["command"])
    print("Complete GNATprove evidence: " + ", ".join(f"{count} {name}" for name, count in stats.items()))


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError, TypeError) as error:
        print(f"proof evidence rejected: {error}", file=sys.stderr)
        raise SystemExit(1)
