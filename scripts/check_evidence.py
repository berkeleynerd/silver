#!/usr/bin/env python3
"""Audit GNATprove 16.1 evidence for every Silver-owned compilation unit.

This development/CI check supplements the compiler's SPARK verification. It does
not implement admission, compilation, or a substitute theorem about Silver.
"""

from __future__ import annotations

import argparse
from collections import Counter
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
    # fopen, fgetc, fputc, ferror, fclose, system, mkdir, mkdtemp
    "silver_libc.ads": "fb760228a2f4a4521fb2ea1959c52454de49717f0c5762c4e462daf1b72b7d0d",
    # ada__command_line__argument_count, ada__command_line__argument,
    # __gnat_set_exit_status (original GNAT runtime symbols)
    "silver_runtime.ads": "1f068e3ef313bdcdc7ada3b2ca7f3d1688db337d6645c9d931baec7a245df32b",
    # putchar, fflush and __gnat_set_exit_status (existing output/status interface)
    "silver_output_libc.ads": "ca1aaff15cdf9a2c780f92f6cace9dd49903896b37ddfb01d65833c8333fdb13",
}
TRUSTED_IMPORT_ENTITIES = {
    "silver_libc": {f"Silver_Libc.{name}" for name in
                    ("C_Open", "C_Get", "C_Put", "C_Error", "C_Close", "C_System", "C_Mkdir", "C_Mkdtemp")},
    "silver_runtime": {f"Silver_Runtime.{name}" for name in
                       ("Argument_Count", "Argument", "Set_Exit_Status")},
    "silver_output_libc": {f"Silver_Output_Libc.{name}" for name in
                           ("Put_Byte", "Flush", "Set_Exit_Status")},
}

# These documented proof limitations withhold information from the prover;
# they do not assume correctness, skip checks, or suppress obligations. All
# actual flow/proof checks must still be discharged. See the contracts-recursive
# and numeric-variant entries in SPARK 16.1 UG proof_limitations.rst.
PROOF_LIMITATION_NOTES = {"contracts-recursive", "numeric-variant"}
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
    literal_predecessors = {"return", "then", "else", "is", "when", "and", "or", "not"}
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


def audit_reports(report_dir: Path, expected_units: set[str],
                  trusted_import_units: set[str] | None = None, *,
                  effective_command: list[str] | None = None,
                  application_kind: str | None = None) -> dict[str, int]:
    """Fail closed on missing coverage, skipped work, assumptions or failures."""
    require(bool(expected_units), "no implementation units selected for auditing")
    require({path.stem for path in report_dir.glob("*.spark")} == expected_units,
            "missing report or unexpected compilation-unit report")
    trusted_import_units = trusted_import_units or set()
    stats = {"units": 0, "entities": 0, "flow_checks": 0, "proof_checks": 0,
             "limitation_notes": 0, "imported_entities": 0}
    require(application_kind in (None, "static", "argument", "assigned", "selected"),
            "unknown application report policy")
    if application_kind is not None:
        require("main" in expected_units, "application audit requires Main")
        stats["assignment_advisories"] = 0
    reports = {unit: read_json(report_dir / f"{unit}.spark") for unit in expected_units}
    owned_names: set[str] = set()
    owned_locations: dict[str, set[str]] = {}
    diagnostics: Counter = Counter()
    assignment_diagnostics: Counter = Counter()
    summary = (report_dir / "gnatprove.out").read_text()
    summaries = {name: (int(analyzed), int(total)) for name, analyzed, total in
                 re.findall(r"in unit (\w+), (\d+) subprograms and packages out of (\d+) analyzed", summary)}
    require(set(summaries) == expected_units, "coverage summary has missing or unexpected units")
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
            callees = {"Silver_IO.Put_Line": "silver_io.ads"}
            if application_kind in ("argument", "selected"):
                callees.update({name: "silver_arguments.ads" for name in
                                ("Silver_Arguments.First_Or_Default",
                                 "Silver_Arguments.Input_Is_Valid", "Silver_Arguments.Reject")})
            bare = len(entities) == 1
            expected_names = set() if bare else set(callees)
            actual_names = [value.get("name") for key, value in entities.items()
                            if key not in main_entities]
            if application_kind in ("argument", "selected") and not bare and "Silver_IO.Put_Line" not in actual_names:
                expected_names.remove("Silver_IO.Put_Line")
            require(len(main_entities) == 1 and set(actual_names) == expected_names
                    and len(actual_names) == len(expected_names)
                    and coverage.keys() == main_entities.keys()
                    and all(value == "all" for value in coverage.values()),
                    "application: unexpected entities or Main coverage")
            main_key, main = next(iter(main_entities.items()))
            for key, item in entities.items():
                filename = "main.adb" if key == main_key else callees[item["name"]]
                require(bool(item.get("sloc"))
                        and all(location.get("file") == filename
                                and type(location.get("line")) is int and location["line"] > 0
                                and type(location.get("column")) is int and location["column"] > 0
                                for location in item["sloc"]),
                        "application: unexpected entity declaration")
            require(report.get("warn_error") == [], "application: unexpected warning record")
            require(isinstance(report.get("flow"), list),
                    "application: missing flow diagnostics")
        require(coverage.keys() <= entities.keys(), f"{unit}: coverage names an unknown entity")
        for key, value in coverage.items():
            trusted_import = (unit in trusted_import_units and value == "spec"
                              and entities.get(key, {}).get("name") in TRUSTED_IMPORT_ENTITIES.get(unit, set()))
            require(value == "all" or trusted_import, f"{unit}: entity outside full SPARK")
            if trusted_import:
                stats["imported_entities"] += 1
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
                locations = entity.get("sloc", [])
                trusted_runtime = name in TRUSTED_RUNTIME_CALLEES and bool(locations) and all(
                    Path(location["file"]).name == TRUSTED_RUNTIME_CALLEES[name]
                    for location in locations)
                owned_dependency = name in owned_names and bool(locations) and all(
                    Path(location["file"]).name in owned_locations[name] for location in locations)
                require(application or owned_dependency or trusted_runtime,
                        f"{unit}: unapproved external assumption dependency {name}")
        for key in ("flow", "proof", "warn_error"):
            records = report.get(key)
            require(isinstance(records, list), f"{unit}: missing {key} results")
            for record in records:
                require(isinstance(record, dict), f"{unit}: malformed {key} record")
                advisory = application and key == "flow"
                if advisory:
                    require(record.get("severity") == "warning"
                            and record.get("how_proved") == "flow"
                            and record.get("file") == "main.adb"
                            and type(record.get("line")) is int and record["line"] > 0
                            and type(record.get("col")) is int and record["col"] > 0
                            and type(record.get("entity")) is int and record["entity"] > 0
                            and entities.get(f" {record['entity']}", entities.get(str(record["entity"]))) == main
                            and ((record.get("rule") == "INEFFECTIVE"
                                  and (re.fullmatch(r'initialization of "[A-Za-z]([A-Za-z0-9]|_[A-Za-z0-9])*" has no effect',
                                                    record.get("message", {}).get("text", "")) is not None
                                       or record.get("message", {}).get("text") in {
                                           f'"{name}" is set by "Put_Line" but not used after the call'
                                           for name in ("Written_Count", "Flushed", "Succeeded", "Written_Bytes")}
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
                            and record.get("rule") in {"VC_RANGE_CHECK", "VC_LENGTH_CHECK"}
                            and record.get("file") == "main.adb"
                            and type(record.get("line")) is int and record["line"] > 0
                            and type(record.get("col")) is int and record["col"] > 0
                            and type(record.get("entity")) is int and record["entity"] > 0
                            and entities.get(f" {record['entity']}", entities.get(str(record["entity"]))) == main,
                            "application: expected a proved Main range or length check")
                    require(not any(field in record for field in
                                    ("justification", "justified", "suppressed", "annot_kind", "justif_msg")),
                            "application: suppressed or justified safety check")
                limitation = (key == "warn_error" and record.get("rule") in PROOF_LIMITATION_NOTES
                              and record.get("severity") == "warning")
                require(record.get("severity") == "info" or limitation or advisory,
                        f"{unit}: {key} diagnostic is not proved/info: {record}")
                if limitation:
                    stats["limitation_notes"] += 1
                require(record.get("how_proved") in ("flow", "prover", "trivial"),
                        f"{unit}: justified or unproved {key} result: {record}")
                require(not record.get("justification") and not record.get("justified"),
                        f"{unit}: justified result")
                require(("suppressed" not in record or (limitation and record["suppressed"] == ""))
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
        stats["units"] += 1
        stats["entities"] += len(own_entities)
        stats["flow_checks"] += 0 if application else len(report["flow"])
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
    results = run.get("results")
    require(isinstance(results, list), "missing SARIF results")
    sarif_diagnostics: Counter = Counter()
    for result in results:
        locations = result.get("locations", [])
        require(len(locations) == 1, "missing/ambiguous SARIF diagnostic location")
        location = locations[0]["physicalLocation"]
        region = location["region"]
        diagnostic = (result.get("ruleId"), Path(location["artifactLocation"]["uri"]).name,
                      region["startLine"], region["startColumn"],
                      result.get("message", {}).get("text"))
        advisory = (diagnostic in assignment_diagnostics
                    and location["artifactLocation"]["uri"] == "main.adb"
                    and result.get("kind") == "open" and result.get("level") == "warning")
        require(diagnostic not in assignment_diagnostics or advisory,
                "assignment: SARIF must preserve unused-value advisory classification")
        limitation = (result.get("ruleId") in PROOF_LIMITATION_NOTES
                      and result.get("kind") in ("open", "informational")
                      and result.get("level") == "warning")
        require(result.get("kind") in ("pass", "informational") or limitation or advisory,
                f"SARIF result not proved: {result}")
        require(result.get("level", "none") in ("none", "note") or limitation or advisory,
                f"SARIF warning/error: {result}")
        # GNATprove marks its disabled-by-default limitation diagnostics as
        # externally suppressed. This is not an obligation suppression.
        suppressions = result.get("suppressions", [])
        require(not suppressions or (limitation and suppressions == [{"kind": "external"}]),
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
        sources.extend(sorted(path for path in generated_dir.rglob("*")
                              if path.suffix in (".ads", ".adb")))
    for source in sources:
        audit_source_policy(source)
        if source.name in TRUSTED_IMPORT_SPECS:
            audit_import_spec(source)
    expected_units = {path.stem for path in sources}
    trusted_units = {path.stem for path in sources if path.name in TRUSTED_IMPORT_SPECS}
    stats = audit_reports(report_dir, expected_units, trusted_units,
                          effective_command=effective_command)
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
    tokens = [piece.lower() for piece in source_tokens(source)]
    forbidden = {"assume", "suppress", "suppress_all", "assertion_policy", "check_policy",
                 "check", "annotate", "warnings"}
    for left, right in zip(tokens, tokens[1:]):
        require(left != "pragma" or right not in forbidden,
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
