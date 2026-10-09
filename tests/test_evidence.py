"""The evidence gate must fail closed even if GNATprove exits successfully."""
from __future__ import annotations

import json
import copy
import os
from pathlib import Path
import tempfile
import unittest
from unittest import mock

from scripts.check_evidence import (EvidenceError, TRUSTED_IMPORT_ENTITIES,
                                    audit_import_spec, audit_reports, audit_source_policy,
                                    audit_sources)
from scripts import proof_provenance, bootstrap
from scripts.check_evidence import PROOF_OPTIONS
from scripts.platforms import HostLayout


class ProofEvidenceTests(unittest.TestCase):
    def setUp(self) -> None:
        self.directory = tempfile.TemporaryDirectory(prefix="silver-evidence-")
        self.addCleanup(self.directory.cleanup)
        self.path = Path(self.directory.name)
        # Minimum real GNATprove 16.1 schema for the zero-VC null program.
        self.report = {
            "entities": {" 1": {"name": "Main", "sloc": [{"file": "main.adb", "line": 1, "column": 11}]}},
            "spark": {" 1": "all"}, "progress": "PROGRESS_PROOF", "stop_reason": "STOP_REASON_NONE",
            "flow": [], "proof": [], "pragma_assume": [], "skip_flow_proof": [],
            "skip_proof": [], "warn_error": [],
            "assumptions": [{"claim": {"arg": 1, "predicate": "CLAIM_EFFECTS"}, "assumptions": []}],
        }
        self.sarif = {
            "version": "2.1.0", "runs": [{
                "tool": {"driver": {"name": "GNATProve", "version": "FSF 16.1.0"}},
                "invocations": [{"commandLine": "gnatprove -P test.gpr --mode=all --report=all",
                                 "executionSuccessful": True, "exitCode": 0}],
                "results": [],
            }],
        }
        (self.path / "gnatprove.out").write_text("Total . . . . .\nin unit main, 1 subprograms and packages out of 1 analyzed\n")

    def refresh_reports(self) -> None:
        """Build mutually consistent producer reports; mutations happen after this."""
        summary = []
        diagnostics = []
        flow = proof = 0
        for path in self.path.glob("*.spark"):
            report = json.loads(path.read_text())
            own = {key for key, entity in report["entities"].items()
                   if any(Path(location["file"]).stem == path.stem for location in entity["sloc"])}
            count = sum(report["spark"].get(key) == "all" for key in own)
            summary.append(f"in unit {path.stem}, {count} subprograms and packages out of {len(own)} analyzed")
            flow += len(report["flow"])
            proof += len(report["proof"])
            for kind in ("flow", "proof", "warn_error"):
                for record in report[kind]:
                    for key, value in {"file": path.stem + ".adb", "line": 1, "col": 1,
                                       "rule": "VC_ASSERT", "entity": 1,
                                       "message": {"text": "assertion proved"}}.items():
                        record.setdefault(key, value)
                    diagnostics.append({"ruleId": record["rule"], "kind": "pass", "level": "none",
                                        "message": record["message"], "locations": [{"physicalLocation": {
                                            "artifactLocation": {"uri": record["file"]},
                                            "region": {"startLine": record["line"], "startColumn": record["col"]}}}]})
            path.write_text(json.dumps(report))
        summary.insert(0, f"Total {flow + proof} {flow} {proof} . .")
        (self.path / "gnatprove.out").write_text("\n".join(summary) + "\n")
        sarif = json.loads(json.dumps(self.sarif))
        if not sarif["runs"][0]["results"]:
            sarif["runs"][0]["results"] = diagnostics
        else:
            for result, diagnostic in zip(sarif["runs"][0]["results"], diagnostics):
                for key in ("locations", "message"):
                    result.setdefault(key, diagnostic[key])
        (self.path / "gnatprove.sarif").write_text(json.dumps(sarif))

    def audit(self, effective_command: list[str] | None = None) -> dict[str, int]:
        (self.path / "main.spark").write_text(json.dumps(self.report))
        self.refresh_reports()
        return audit_reports(self.path, {"main"}, effective_command=effective_command)

    def test_success_with_zero_obligations_requires_coverage(self) -> None:
        self.assertEqual(self.audit()["proof_checks"], 0)
        self.report["spark"] = {}
        with self.assertRaises(EvidenceError):
            self.audit()

    def test_captured_arguments_handle_lossy_producer_paths_without_shell_parsing(self) -> None:
        command = ["gnatprove", "-P", "/tmp/checkout ' --mode=flow/project.gpr",
                   "--mode=all", "--report=all",
                   "--memcached-server=file:/tmp/solver cache ' quoted"]
        invocation = self.sarif["runs"][0]["invocations"][0]
        invocation["commandLine"] = " ".join(command)
        self.assertEqual(self.audit(command)["units"], 1)
        invocation["commandLine"] += " --mode=flow"
        with self.assertRaisesRegex(EvidenceError, "effective command"):
            self.audit(command)
        command.append("--mode=flow")
        with self.assertRaisesRegex(EvidenceError, "conflicting/repeated --mode"):
            self.audit(command)

    def test_standalone_report_does_not_treat_path_apostrophe_as_shell_quoting(self) -> None:
        self.sarif["runs"][0]["invocations"][0]["commandLine"] = (
            "gnatprove -P /tmp/project.gpr --mode=all --report=all "
            "--memcached-server=file:/tmp/solver cache ' quoted")
        self.assertEqual(self.audit()["units"], 1)

    def test_missing_unit_report(self) -> None:
        self.audit()
        with self.assertRaises(EvidenceError):
            audit_reports(self.path, {"main", "omitted"})

    def test_generated_configuration_requires_current_proof_coverage(self) -> None:
        source_dir = self.path / "src"
        generated_dir = self.path / "generated"
        source_dir.mkdir()
        generated_dir.mkdir()
        (source_dir / "main.adb").write_text("procedure Main is begin null; end Main;\n")
        root = Path(__file__).resolve().parents[1]
        for filename in bootstrap.RUNTIME_SOURCES.values():
            (source_dir / filename).write_bytes((root / "src" / filename).read_bytes())
        self.audit()
        with self.assertRaisesRegex(EvidenceError, "missing platform configuration"):
            audit_sources(source_dir, self.path, generated_dir)

        generated = generated_dir / "silver_build.ads"
        generated.write_text('package Silver_Build with SPARK_Mode => On is\n'
                             '   Host : constant String := "linux-aarch64";\n'
                             'end Silver_Build;\n')
        binding = generated_dir / "silver_library_sources.ads"
        with self.assertRaisesRegex(EvidenceError, "missing runtime source binding"):
            audit_sources(source_dir, self.path, generated_dir)
        binding.write_bytes(bootstrap.runtime_source_configuration(source_dir))
        with self.assertRaisesRegex(EvidenceError, "missing report"):
            audit_sources(source_dir, self.path, generated_dir)

        for unit, package in (("silver_io", "Silver_IO"),
                              ("silver_output_libc", "Silver_Output_Libc"),
                              ("silver_arguments", "Silver_Arguments"),
                              ("silver_runtime", "Silver_Runtime"),
                              ("silver_library_sources", "Silver_Library_Sources")):
            report = copy.deepcopy(self.report)
            names = [package, *sorted(TRUSTED_IMPORT_ENTITIES.get(unit, set()))]
            report["entities"] = {
                str(index): {"name": name, "sloc": [{"file": unit + ".ads"}]}
                for index, name in enumerate(names, 1)}
            report["spark"] = {str(index): "all" if index == 1 else "spec"
                               for index in range(1, len(names) + 1)}
            (self.path / (unit + ".spark")).write_text(json.dumps(report))
        report = dict(self.report)
        report["entities"] = {" 1": {"name": "Silver_Build", "sloc": [{"file": "silver_build.ads"}]}}
        report_path = self.path / "silver_build.spark"
        report_path.write_text(json.dumps(report))
        self.refresh_reports()
        self.assertEqual(audit_sources(source_dir, self.path, generated_dir)["units"], 7)

        for unit in ("silver_arguments", "silver_runtime"):
            target = self.path / (unit + ".spark")
            original_report = target.read_bytes()
            target.unlink()
            with self.subTest(unit=unit), self.assertRaisesRegex(EvidenceError, "missing report"):
                audit_sources(source_dir, self.path, generated_dir)
            target.write_bytes(original_report)
        self.refresh_reports()

        # A generated spec with changed expected bytes cannot be accepted even
        # if all producer reports claim success and are newer than the source.
        original_binding = binding.read_bytes()
        binding.write_bytes(original_binding + b"-- changed binding\n")
        with self.assertRaisesRegex(EvidenceError, "embedded runtime source bytes differ"):
            audit_sources(source_dir, self.path, generated_dir)
        binding.write_bytes(original_binding)
        self.refresh_reports()
        for filename in bootstrap.RUNTIME_SOURCES.values():
            target = source_dir / filename
            original = target.read_bytes()
            target.write_bytes(original + b"-- changed installed source\n")
            with self.subTest(source=filename), self.assertRaisesRegex(
                    EvidenceError, "embedded runtime source bytes differ"):
                audit_sources(source_dir, self.path, generated_dir)
            target.write_bytes(original)
        self.refresh_reports()

        # A proof for yesterday's host configuration cannot verify today's.
        old = report_path.stat().st_mtime_ns
        os.utime(generated, ns=(old + 1_000_000_000, old + 1_000_000_000))
        with self.assertRaisesRegex(EvidenceError, "proof evidence predates source"):
            audit_sources(source_dir, self.path, generated_dir)

    def test_missing_owned_entity(self) -> None:
        self.report["entities"][" 2"] = {"name": "Hidden", "sloc": [{"file": "main.adb"}]}
        with self.assertRaises(EvidenceError):
            self.audit()

    def test_trusted_external_callee_is_not_owned_coverage(self) -> None:
        self.report["entities"][" 2"] = {"name": "Runtime.Read", "sloc": [{"file": "runtime.ads"}]}
        self.assertEqual(self.audit()["entities"], 1)

    def test_analysis_stopped_or_skipped(self) -> None:
        for key, value in (("progress", "PROGRESS_FLOW"), ("stop_reason", "STOP_REASON_ERROR"),
                           ("spark", {" 1": "spec"}), ("skip_proof", [1]),
                           ("skip_flow_proof", [1]), ("pragma_assume", [1])):
            with self.subTest(key=key):
                original = self.report[key]
                self.report[key] = value
                with self.assertRaises(EvidenceError):
                    self.audit()
                self.report[key] = original

    def test_unproved_or_justified_check(self) -> None:
        for record in ({"severity": "medium", "how_proved": "unproved"},
                       {"severity": "info", "how_proved": "justified"},
                       {"severity": "info", "how_proved": "prover", "justification": "ignored"}):
            with self.subTest(record=record):
                self.report["proof"] = [record]
                with self.assertRaises(EvidenceError):
                    self.audit()

    def test_warning_rejected_but_informational_unrolling_note_allowed(self) -> None:
        self.report["warn_error"] = [{"severity": "info", "how_proved": "trivial",
                                      "message": {"text": "cannot unroll loop (too many loop iterations)"}}]
        self.audit()
        self.report["warn_error"][0]["severity"] = "warning"
        with self.assertRaises(EvidenceError):
            self.audit()

    def test_flow_only_invocation_is_insufficient(self) -> None:
        self.sarif["runs"][0]["invocations"][0]["commandLine"] = "gnatprove --mode=flow --report=all"
        with self.assertRaises(EvidenceError):
            self.audit()

    def test_documented_proof_limitation_is_counted_but_cannot_hide_a_failed_check(self) -> None:
        self.report["warn_error"] = [{"rule": "numeric-variant", "severity": "warning",
                                      "how_proved": "trivial"}]
        self.sarif["runs"][0]["results"] = [{"ruleId": "numeric-variant", "kind": "open",
                                            "level": "warning", "suppressions": [{"kind": "external"}]}]
        self.assertEqual(self.audit()["limitation_notes"], 1)
        self.report["proof"] = [{"severity": "medium", "how_proved": "unproved"}]
        with self.assertRaises(EvidenceError):
            self.audit()

    def test_trusted_import_allowance_pins_symbols_and_contracts(self) -> None:
        root = Path(__file__).resolve().parents[1]
        for unit, symbol in (("silver_libc", "fopen"), ("silver_runtime", "__gnat_set_exit_status"),
                             ("silver_output_libc", "putchar")):
            target = self.path / (unit + ".ads")
            original = (root / "src" / target.name).read_text()
            target.write_text(original)
            audit_import_spec(target)
            for external_name in ('"unreviewed_wrapper"', '"f open"', '"f--comment\nopen"'):
                with self.subTest(unit=unit, external_name=external_name):
                    target.write_text(original.replace('"' + symbol + '"', external_name))
                    with self.assertRaises(EvidenceError):
                        audit_import_spec(target)
            target.write_text(original)
            target.with_suffix(".adb").write_text("package body Unreviewed is end Unreviewed;")
            with self.subTest(unit=unit, body=True), self.assertRaises(EvidenceError):
                audit_import_spec(target)

    def test_source_cannot_hide_checks_before_report_generation(self) -> None:
        target = self.path / "main.adb"
        target.write_text('''procedure Main is
          -- pragma Suppress (All_Checks);
          Text : constant String := "pragma Assume (False);";
          Dash : constant Character := '-';
        begin null; end Main;
        ''')
        audit_source_policy(target)
        for directive in ("Assume (False)", "Suppress (All_Checks)",
                          "Assertion_Policy (Ignore)", "Check_Policy (Assert, Ignore)"):
            with self.subTest(directive=directive):
                target.write_text("procedure Main is PrAgMa -- layout\n" + directive
                                  + "; begin null; end Main;")
                with self.assertRaises(EvidenceError):
                    audit_source_policy(target)

    def test_import_declaration_checks_cannot_be_waived(self) -> None:
        for unit, package in (("silver_libc", "Silver_Libc"),
                              ("silver_output_libc", "Silver_Output_Libc")):
            with self.subTest(unit=unit):
                report = copy.deepcopy(self.report)
                names = [package, *sorted(TRUSTED_IMPORT_ENTITIES[unit])]
                report["entities"] = {
                    str(index): {"name": name, "sloc": [{"file": unit + ".ads"}]}
                    for index, name in enumerate(names, 1)
                }
                report["spark"] = {str(index): "all" if index == 1 else "spec"
                                   for index in range(1, len(names) + 1)}
                target = self.path / (unit + ".spark")
                target.write_text(json.dumps(report))
                self.refresh_reports()
                stats = audit_reports(self.path, {unit}, {unit})
                self.assertEqual(stats["imported_entities"], len(names) - 1)
                report["flow"] = [{"severity": "high", "rule": "UNINITIALIZED", "how_proved": "flow"}]
                target.write_text(json.dumps(report))
                with self.assertRaises(EvidenceError):
                    audit_reports(self.path, {unit}, {unit})
                target.unlink()

    def test_output_call_requires_owned_runtime_and_reviewed_import_reports(self) -> None:
        source_dir = self.path / "src"
        source_dir.mkdir()
        root = Path(__file__).resolve().parents[1]
        for name in ("silver_io.ads", "silver_io.adb", "silver_output_libc.ads"):
            (source_dir / name).write_bytes((root / "src" / name).read_bytes())
        (source_dir / "main.adb").write_text(
            'with Silver_IO; procedure Main is begin Silver_IO.Put_Line ("Hello"); end Main;')
        self.report["entities"][" 2"] = {
            "name": "Silver_IO.Put_Line", "sloc": [{"file": "silver_io.ads"}]}
        self.report["assumptions"][0]["assumptions"] = [{"arg": 2, "predicate": "CLAIM_EFFECTS"}]
        (self.path / "main.spark").write_text(json.dumps(self.report))
        library = copy.deepcopy(self.report)
        library["entities"] = {
            " 1": {"name": "Silver_IO", "sloc": [{"file": "silver_io.ads"}]},
            " 2": {"name": "Silver_IO.Put_Line", "sloc": [{"file": "silver_io.ads"}]},
            " 3": {"name": "Silver_Output_Libc.Put_Byte", "sloc": [{"file": "silver_output_libc.ads"}]},
        }
        library["spark"] = {" 1": "all", " 2": "all"}
        library["assumptions"] = [{"claim": {"arg": 2, "predicate": "CLAIM_AORTE"},
                                   "assumptions": [{"arg": 3, "predicate": "CLAIM_AORTE"}]}]
        library["proof"] = [{"severity": "info", "how_proved": "prover", "entity": 2}]
        (self.path / "silver_io.spark").write_text(json.dumps(library))
        imports = copy.deepcopy(self.report)
        names = ["Silver_Output_Libc", *sorted(TRUSTED_IMPORT_ENTITIES["silver_output_libc"])]
        imports["entities"] = {
            str(index): {"name": name, "sloc": [{"file": "silver_output_libc.ads"}]}
            for index, name in enumerate(names, 1)
        }
        imports["spark"] = {str(index): "all" if index == 1 else "spec"
                            for index in range(1, len(names) + 1)}
        imports["assumptions"] = []
        (self.path / "silver_output_libc.spark").write_text(json.dumps(imports))
        self.refresh_reports()
        stats = audit_sources(source_dir, self.path)
        self.assertEqual((stats["units"], stats["proof_checks"], stats["imported_entities"]), (3, 1, 3))

        # A zero-check Main report cannot stand in for its owned call chain.
        (self.path / "silver_io.spark").unlink()
        with self.assertRaisesRegex(EvidenceError, "missing report"):
            audit_sources(source_dir, self.path)
        self.refresh_reports()
        with self.assertRaisesRegex(EvidenceError, "unapproved external assumption"):
            audit_reports(self.path, {"main", "silver_output_libc"}, {"silver_output_libc"})

    def test_deleted_diagnostic_is_detected_without_fixed_check_count(self) -> None:
        self.report["proof"] = [{"severity": "info", "how_proved": "prover"}]
        self.audit()
        report = json.loads((self.path / "main.spark").read_text())
        report["proof"] = []
        (self.path / "main.spark").write_text(json.dumps(report))
        with self.assertRaisesRegex(EvidenceError, "diagnostic coverage disagree"):
            audit_reports(self.path, {"main"})

    def test_real_suppression_schema_is_rejected(self) -> None:
        self.report["proof"] = [{"severity": "info", "how_proved": "prover", "suppressed": "reviewed"}]
        with self.assertRaisesRegex(EvidenceError, "suppressed result"):
            self.audit()

    def test_unknown_external_assumption_is_rejected(self) -> None:
        self.report["entities"][" 2"] = {"name": "Runtime.Unreviewed", "sloc": [{"file": "runtime.ads"}]}
        self.report["assumptions"][0]["assumptions"] = [{"arg": 2, "predicate": "CLAIM_POST"}]
        with self.assertRaisesRegex(EvidenceError, "unapproved external assumption"):
            self.audit()

    def test_later_mode_override_is_rejected(self) -> None:
        self.sarif["runs"][0]["invocations"][0]["commandLine"] += " --mode=flow"
        with self.assertRaisesRegex(EvidenceError, "conflicting/repeated"):
            self.audit()

    def test_comment_format_effectors_and_qualified_expression_cannot_hide_pragma(self) -> None:
        target = self.path / "attack.adb"
        for byte in (11, 12, 133, 255):
            target.write_bytes(b"-- comment" + bytes([byte]) + b" pragma Assume (False);\n")
            with self.subTest(byte=byte), self.assertRaises(EvidenceError):
                audit_source_policy(target)
        target.write_text("procedure Main is C : Character := Character'('P'); "
                          "pragma Check (Assume, False); begin null; end Main;")
        with self.assertRaisesRegex(EvidenceError, "forbidden"):
            audit_source_policy(target)
        target.write_text('procedure Main is Text : String := %"--%; pragma Suppress (All_Checks); begin null; end Main;')
        with self.assertRaisesRegex(EvidenceError, "percent-delimited"):
            audit_source_policy(target)

    def test_static_assertion_level_is_not_a_suppression(self) -> None:
        target = self.path / "model.ads"
        target.write_text("function Model return Boolean with Ghost => Static, Post => True;\n")
        audit_source_policy(target)

    def test_unsuccessful_invocation_or_suppressed_diagnostic(self) -> None:
        invocation = self.sarif["runs"][0]["invocations"][0]
        invocation["executionSuccessful"] = False
        with self.assertRaises(EvidenceError):
            self.audit()
        invocation["executionSuccessful"] = True
        self.sarif["runs"][0]["results"] = [{"kind": "pass", "level": "none", "suppressions": [{"kind": "inSource"}]}]
        with self.assertRaises(EvidenceError):
            self.audit()


if __name__ == "__main__":
    unittest.main()
