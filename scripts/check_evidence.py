#!/usr/bin/env python3
"""Audit GNATprove 16.1 evidence for every Silver-owned compilation unit.

This development/CI check supplements the compiler's SPARK verification. It does
not implement admission, compilation, or a substitute theorem about Silver.
"""

from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import sys

if __package__:
    from .platforms import native_layout
else:
    from platforms import native_layout

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
}
TRUSTED_IMPORT_ENTITIES = {
    "silver_libc": {f"Silver_Libc.{name}" for name in
                    ("C_Open", "C_Get", "C_Put", "C_Error", "C_Close", "C_System", "C_Mkdir", "C_Mkdtemp")},
    "silver_runtime": {f"Silver_Runtime.{name}" for name in
                       ("Argument_Count", "Argument", "Set_Exit_Status")},
}

# These documented proof limitations withhold information from the prover;
# they do not assume correctness, skip checks, or suppress obligations. All
# actual flow/proof checks must still be discharged. See the contracts-recursive
# and numeric-variant entries in SPARK 16.1 UG proof_limitations.rst.
PROOF_LIMITATION_NOTES = {"contracts-recursive", "numeric-variant"}


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


def audit_reports(report_dir: Path, expected_units: set[str],
                  trusted_import_units: set[str] | None = None) -> dict[str, int]:
    """Fail closed on missing coverage, skipped work, assumptions or failures."""
    require(bool(expected_units), "no implementation units selected for auditing")
    trusted_import_units = trusted_import_units or set()
    stats = {"units": 0, "entities": 0, "flow_checks": 0, "proof_checks": 0,
             "limitation_notes": 0, "imported_entities": 0}
    for unit in sorted(expected_units):
        path = report_dir / f"{unit}.spark"
        report = read_json(path)
        require(report.get("progress") == "PROGRESS_PROOF", f"{unit}: proof phase incomplete")
        require(report.get("stop_reason") == "STOP_REASON_NONE", f"{unit}: analysis stopped early")
        entities = report.get("entities")
        coverage = report.get("spark")
        require(isinstance(entities, dict) and bool(entities), f"{unit}: no analyzed entities")
        require(isinstance(coverage, dict) and bool(coverage), f"{unit}: no SPARK coverage")
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
        if unit in trusted_import_units:
            owned_names = {entities[key]["name"] for key in own_entities}
            require(TRUSTED_IMPORT_ENTITIES[unit] <= owned_names,
                    f"{unit}: missing approved import declaration coverage")
        for key in ("skip_flow_proof", "skip_proof", "pragma_assume"):
            require(report.get(key) == [], f"{unit}: missing or nonempty {key}")
        for key in ("flow", "proof", "warn_error"):
            records = report.get(key)
            require(isinstance(records, list), f"{unit}: missing {key} results")
            for record in records:
                limitation = (key == "warn_error" and record.get("rule") in PROOF_LIMITATION_NOTES
                              and record.get("severity") == "warning")
                require(record.get("severity") == "info" or limitation,
                        f"{unit}: {key} diagnostic is not proved/info: {record}")
                if limitation:
                    stats["limitation_notes"] += 1
                require(record.get("how_proved") in ("flow", "prover", "trivial"),
                        f"{unit}: justified or unproved {key} result: {record}")
                require(not record.get("justification") and not record.get("justified"),
                        f"{unit}: justified result")
        stats["units"] += 1
        stats["entities"] += len(own_entities)
        stats["flow_checks"] += len(report["flow"])
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
    command = invocation.get("commandLine", "")
    require("--mode=all" in command.split() and "--report=all" in command.split(),
            "GNATprove did not record full flow/proof analysis and reporting")
    results = run.get("results")
    require(isinstance(results, list), "missing SARIF results")
    for result in results:
        limitation = (result.get("ruleId") in PROOF_LIMITATION_NOTES
                      and result.get("kind") in ("open", "informational")
                      and result.get("level") == "warning")
        require(result.get("kind") in ("pass", "informational") or limitation,
                f"SARIF result not proved: {result}")
        require(result.get("level", "none") in ("none", "note") or limitation,
                f"SARIF warning/error: {result}")
        # GNATprove marks its disabled-by-default limitation diagnostics as
        # externally suppressed. This is not an obligation suppression.
        suppressions = result.get("suppressions", [])
        require(not suppressions or (limitation and suppressions == [{"kind": "external"}]),
                "suppressed SARIF diagnostic")
    require((report_dir / "gnatprove.out").is_file(), "missing human-readable coverage summary")
    return stats


def audit_sources(source_dir: Path, report_dir: Path,
                  generated_dir: Path | None = None) -> dict[str, int]:
    require(source_dir.is_dir(), f"missing source directory: {source_dir}")
    sources = sorted(path for path in source_dir.rglob("*") if path.suffix in (".ads", ".adb"))
    if generated_dir is not None:
        require((generated_dir / "silver_build.ads").is_file(),
                f"missing platform configuration: {generated_dir / 'silver_build.ads'}")
        sources.extend(sorted(path for path in generated_dir.rglob("*")
                              if path.suffix in (".ads", ".adb")))
    for source in sources:
        audit_source_policy(source)
        if source.name in TRUSTED_IMPORT_SPECS:
            audit_import_spec(source)
    expected_units = {path.stem for path in sources}
    trusted_units = {path.stem for path in sources if path.name in TRUSTED_IMPORT_SPECS}
    stats = audit_reports(report_dir, expected_units, trusted_units)
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
    pieces = re.findall(r'"(?:[^"]|"")*"|\'[^\r\n]\'|--[^\r\n]*|[A-Za-z][A-Za-z_0-9]*|\s+|.',
                        source.read_text(), re.DOTALL)
    tokens = [piece.lower() for piece in pieces
              if not piece.isspace() and not piece.startswith("--")]
    forbidden = {"assume", "suppress", "suppress_all", "assertion_policy", "check_policy"}
    for left, right in zip(tokens, tokens[1:]):
        require(left != "pragma" or right not in forbidden,
                f"{source}: forbidden assumption/check-policy pragma {right}")


def audit_import_spec(source: Path) -> None:
    require(not source.with_suffix(".adb").exists(), f"{source}: trusted import has an implementation body")
    # Preserve quoted external symbol names exactly, including whitespace and
    # doubled quotes. Only layout/comments outside strings are irrelevant.
    pieces = re.findall(r'"(?:[^"]|"")*"|--[^\r\n]*|\s+|.', source.read_text(), re.DOTALL)
    tokens = "".join(piece for piece in pieces if piece.startswith('"')
                     or (not piece.isspace() and not piece.startswith("--"))).encode()
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
    stats = audit_sources(args.source_dir, args.report_dir, args.generated_dir)
    print("Complete GNATprove evidence: " + ", ".join(f"{count} {name}" for name, count in stats.items()))


if __name__ == "__main__":
    try:
        main()
    except (OSError, ValueError, KeyError, TypeError) as error:
        print(f"proof evidence rejected: {error}", file=sys.stderr)
        raise SystemExit(1)
