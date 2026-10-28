"""The evidence gate must fail closed even if GNATprove exits successfully."""
from __future__ import annotations

import json
import copy
import os
from itertools import product
from pathlib import Path
import tempfile
import unittest
from unittest import mock

from scripts.check_evidence import (EvidenceError, TRUSTED_IMPORT_ENTITIES,
                                    audit_import_spec, audit_reports, audit_source_policy,
                                    audit_sources)
from scripts import proof_provenance, bootstrap
from scripts.check_evidence import PROOF_OPTIONS
from scripts.check_evidence import (BIG_INTEGER_VALIDITY_TEXT, SEQUENCE_NAME, SEQUENCE_UNIT,
                                    audit_sequence_instance, sequence_entities,
                                    SIGNED_CONVERSION_UNIT, SIGNED_CONVERSION_NAME,
                                    audit_signed_conversion_instance, signed_conversion_entities)
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

    def test_indexed_main_requires_exact_artifact_and_logical_unit_identity(self) -> None:
        self.audit()
        ordinary = self.path / "main.spark"
        indexed = self.path / "main~1.spark"
        with self.assertRaisesRegex(EvidenceError, "missing report"):
            audit_reports(self.path, {"main"}, indexed_main=True)
        ordinary.rename(indexed)
        summary = self.path / "gnatprove.out"
        with self.assertRaisesRegex(EvidenceError, "coverage summary"):
            audit_reports(self.path, {"main"}, indexed_main=True)
        summary.write_text(summary.read_text().replace("in unit main,", "in unit main~1,"))
        self.assertEqual(audit_reports(self.path, {"main"}, indexed_main=True)["units"], 1)
        with self.assertRaisesRegex(EvidenceError, "missing report"):
            audit_reports(self.path, {"main"})
        ordinary.write_bytes(indexed.read_bytes())
        with self.assertRaisesRegex(EvidenceError, "unexpected compilation-unit report"):
            audit_reports(self.path, {"main"}, indexed_main=True)
        ordinary.unlink()
        with self.assertRaisesRegex(EvidenceError, "requires Main"):
            audit_reports(self.path, {"main~1"}, indexed_main=True)
        summary.write_text(summary.read_text().replace("in unit main~1,", "in unit main~2,"))
        with self.assertRaisesRegex(EvidenceError, "coverage summary"):
            audit_reports(self.path, {"main"}, indexed_main=True)

    def prepare_assignment(self, **advisory_changes: object) -> None:
        self.report["assumptions"] = []
        self.report["flow"] = [{"severity": "warning", "how_proved": "flow", "entity": 1,
                                "rule": "INEFFECTIVE", "file": "main.adb", "line": 4, "col": 4,
                                "message": {"text": 'initialization of "Message" has no effect'}}]
        self.report["flow"][0].update(advisory_changes)
        (self.path / "main.spark").write_text(json.dumps(self.report))
        self.refresh_reports()
        # GNATprove reports this advisory separately from required checks.
        (self.path / "gnatprove.out").write_text(
            "Total . . . . .\nin unit main, 1 subprograms and packages out of 1 analyzed\n")
        sarif = json.loads((self.path / "gnatprove.sarif").read_text())
        sarif["runs"][0]["results"][0].update(kind="open", level="warning")
        (self.path / "gnatprove.sarif").write_text(json.dumps(sarif))

    def test_assignment_advisory_requires_explicit_policy_and_is_not_a_check(self) -> None:
        self.prepare_assignment()
        with self.assertRaises(EvidenceError):
            audit_reports(self.path, {"main"})
        stats = audit_reports(self.path, {"main"}, application_kind="assigned")
        self.assertEqual((stats["flow_checks"], stats["proof_checks"], stats["assignment_advisories"]),
                         (0, 0, 1))
        (self.path / "gnatprove.out").write_text(
            "Total 1 1 . . .\nin unit main, 1 subprograms and packages out of 1 analyzed\n")
        with self.assertRaises(EvidenceError):
            audit_reports(self.path, {"main"}, application_kind="assigned")

    def test_assignment_policy_rejects_other_diagnostics_and_suppression(self) -> None:
        changes = (("severity", "info"), ("how_proved", "prover"), ("rule", "VC_LENGTH_CHECK"),
                   ("file", "other.adb"), ("entity", 2), ("line", 0), ("col", 0),
                   ("message", {"text": 'unused assignment to "Message"'}),
                   ("message", {"text": 'initialization of "Message_" has no effect'}),
                   ("suppressed", False), ("justification", ""), ("justified", False))
        for field, value in changes:
            self.prepare_assignment()
            self.report["flow"][0][field] = value
            (self.path / "main.spark").write_text(json.dumps(self.report))
            with self.subTest(field=field, value=value), self.assertRaises(EvidenceError):
                audit_reports(self.path, {"main"}, application_kind="assigned")
        self.prepare_assignment()
        self.report["proof"] = [{"severity": "info", "rule": "VC_LENGTH_CHECK"}]
        (self.path / "main.spark").write_text(json.dumps(self.report))
        with self.assertRaises(EvidenceError):
            audit_reports(self.path, {"main"}, application_kind="assigned")

    def test_assignment_policy_rejects_consistent_malformed_advisories(self) -> None:
        original = copy.deepcopy(self.report)
        changes = (("rule", "UNINITIALIZED"), ("file", "./main.adb"),
                   ("line", 0), ("col", 0), ("entity", 0),
                   ("message", {"text": 'unused assignment to "Message"'}))
        for field, value in changes:
            self.report = copy.deepcopy(original)
            if field == "entity":
                # Keep the reference known so the generic entity lookup cannot
                # mask a missing positive-integer advisory check.
                self.report["entities"][" 0"] = self.report["entities"].pop(" 1")
                self.report["spark"][" 0"] = self.report["spark"].pop(" 1")
            # Mutate before mirroring into SARIF: agreeing reports must still
            # satisfy the narrow permitted-advisory policy.
            self.prepare_assignment(**{field: value})
            if field == "file":
                sarif = json.loads((self.path / "gnatprove.sarif").read_text())
                location = sarif["runs"][0]["results"][0]["locations"][0]["physicalLocation"]
                # The later match normalizes basenames; the .spark policy
                # must independently require the exact filename.
                location["artifactLocation"]["uri"] = "main.adb"
                (self.path / "gnatprove.sarif").write_text(json.dumps(sarif))
            with self.subTest(field=field, value=value), self.assertRaises(EvidenceError):
                audit_reports(self.path, {"main"}, application_kind="assigned")

    def test_assignment_advisory_identifier_pattern_and_schema_bound(self) -> None:
        # This is the report-schema bound, not the maximum identifier length
        # that can fit inside a complete admitted 4096-byte source.
        cases = (("M", True), ("Message_0", True), ("", False), ("0Message", False),
                 ("Message_", False), ("Message__Text", False),
                 ("M" * 4096, True), ("M" * 4097, False))
        for name, accepted in cases:
            self.prepare_assignment(message={"text": f'initialization of "{name}" has no effect'})
            with self.subTest(name=name if len(name) < 32 else f"{len(name)} letters"):
                if accepted:
                    stats = audit_reports(self.path, {"main"}, application_kind="assigned")
                    self.assertEqual((stats["flow_checks"], stats["proof_checks"],
                                      stats["assignment_advisories"]), (0, 0, 1))
                else:
                    with self.assertRaises(EvidenceError):
                        audit_reports(self.path, {"main"}, application_kind="assigned")

    def test_assignment_sarif_must_match_unsuppressed_advisory(self) -> None:
        for field, value in (("ruleId", "UNINITIALIZED"), ("kind", "fail"), ("kind", "pass"),
                             ("level", "error"), ("level", "none"),
                             ("message", {"text": 'initialization of "Other" has no effect'}),
                             ("suppressions", [{"kind": "external"}])):
            self.prepare_assignment()
            sarif = json.loads((self.path / "gnatprove.sarif").read_text())
            sarif["runs"][0]["results"][0][field] = value
            (self.path / "gnatprove.sarif").write_text(json.dumps(sarif))
            with self.subTest(field=field, value=value), self.assertRaises(EvidenceError):
                audit_reports(self.path, {"main"}, application_kind="assigned")

    def test_assignment_output_dependencies_have_approved_references(self) -> None:
        self.report["entities"][" 2"] = {
            "name": "Silver_IO.Put_Line", "sloc": [{"file": "silver_io.ads", "line": 18, "column": 14}]}
        self.report["assumptions"] = [{"claim": {"arg": 1, "predicate": "CLAIM_EFFECTS"},
                                       "assumptions": [{"arg": 2, "predicate": "CLAIM_EFFECTS"}]}]
        (self.path / "main.spark").write_text(json.dumps(self.report))
        self.refresh_reports()
        stats = audit_reports(self.path, {"main"}, application_kind="assigned")
        self.assertEqual((stats["flow_checks"], stats["proof_checks"], stats["assignment_advisories"]),
                         (0, 0, 0))
        exact_assumptions = copy.deepcopy(self.report["assumptions"])
        for assumptions in ([{}], [{"claim": {"arg": 1, "predicate": "CLAIM_ASSUME"},
                                   "assumptions": [{"arg": 2, "predicate": "CLAIM_EFFECTS"}]}],
                            [{"claim": {"arg": 2, "predicate": "CLAIM_EFFECTS"},
                              "assumptions": [{"arg": 3, "predicate": "CLAIM_EFFECTS"}]}]):
            self.report["assumptions"] = assumptions
            (self.path / "main.spark").write_text(json.dumps(self.report))
            with self.assertRaises(EvidenceError):
                audit_reports(self.path, {"main"}, application_kind="assigned")

        # Python bool/float equality must not turn malformed JSON references
        # into the integer entity IDs required by the native report checker.
        for claim_arg, callee_arg in ((True, 2), (1.0, 2), (1, 2.0)):
            self.report["assumptions"] = copy.deepcopy(exact_assumptions)
            self.report["assumptions"][0]["claim"]["arg"] = claim_arg
            self.report["assumptions"][0]["assumptions"][0]["arg"] = callee_arg
            (self.path / "main.spark").write_text(json.dumps(self.report))
            with self.subTest(claim=claim_arg, callee=callee_arg), self.assertRaises(EvidenceError):
                audit_reports(self.path, {"main"}, application_kind="assigned")

    def prepare_composed(self, kind: str, *, warning: bool = False, count: int = 1) -> None:
        self.report["entities"] = {" 1": {
            "name": "Main", "sloc": [{"file": "main.adb", "line": 1, "column": 11}]}}
        names = ["Silver_IO.Put_Line"]
        if kind in ("argument", "selected"):
            names += ["Silver_Arguments.First_Or_Default", "Silver_Arguments.Input_Is_Valid",
                      "Silver_Arguments.Reject"]
        for index, name in enumerate(names, 2):
            filename = "silver_io.ads" if name == "Silver_IO.Put_Line" else "silver_arguments.ads"
            self.report["entities"][f" {index}"] = {
                "name": name, "sloc": [{"file": filename, "line": 1, "column": 1}]}
        self.report["assumptions"] = [{"claim": {"arg": 1, "predicate": "CLAIM_AORTE"},
                                       "assumptions": [{"arg": 2, "predicate": "CLAIM_POST"}]}]
        self.report["flow"] = ([{
            "severity": "warning", "how_proved": "flow", "entity": 1,
            "rule": "INEFFECTIVE", "file": "main.adb", "line": 4, "col": 4,
            "message": {"text": 'initialization of "Result" has no effect'}}] if warning else [])
        self.report["proof"] = [{
            "severity": "info", "how_proved": "prover", "entity": 1,
            "rule": "VC_RANGE_CHECK", "file": "main.adb", "line": 10, "col": 7,
            "message": {"text": "range check proved"}} for _ in range(count)]

    def refresh_composed(self) -> None:
        """Keep each mutated diagnostic mirrored in SARIF to isolate its policy."""
        (self.path / "main.spark").write_text(json.dumps(self.report))
        self.refresh_reports()
        proof = len(self.report["proof"])
        (self.path / "gnatprove.out").write_text(
            f"Total {proof} 0 {proof} . .\nin unit main, 1 subprograms and packages out of 1 analyzed\n")
        sarif = json.loads((self.path / "gnatprove.sarif").read_text())
        for result in sarif["runs"][0]["results"][:len(self.report["flow"])]:
            result.update(kind="open", level="warning")
        (self.path / "gnatprove.sarif").write_text(json.dumps(sarif))

    def test_composed_policies_accept_ranges_with_initializer_advisories(self) -> None:
        for kind in ("static", "argument", "assigned", "selected"):
            for count in (0, 1, 30):
                for warning in (False, True):
                    self.prepare_composed(kind, warning=warning, count=count)
                    self.refresh_composed()
                    with self.subTest(kind=kind, count=count, warning=warning):
                        stats = audit_reports(self.path, {"main"}, application_kind=kind)
                        self.assertEqual(stats["proof_checks"], count)
                        self.assertEqual(stats["flow_checks"], 0)
                    wrong = "static" if kind in ("argument", "selected") else "argument"
                    with self.assertRaises(EvidenceError):
                        audit_reports(self.path, {"main"}, application_kind=wrong)

    def test_composed_ranges_reject_consistently_mutated_checks(self) -> None:
        changes = (("severity", "low"), ("how_proved", "trivial"),
                   ("rule", "VC_ASSERT"), ("file", "./main.adb"),
                   ("entity", 2), ("line", 0), ("col", 0),
                   ("justification", ""), ("suppressed", False))
        for kind in ("static", "argument", "assigned", "selected"):
            for field, value in changes:
                self.prepare_composed(kind, warning=kind in ("assigned", "selected"))
                self.report["proof"][0][field] = value
                self.refresh_composed()
                with self.subTest(kind=kind, field=field), self.assertRaises(EvidenceError):
                    audit_reports(self.path, {"main"}, application_kind=kind)

    def test_argument_policies_accept_exact_optional_callees(self) -> None:
        for kind in ("argument", "selected"):
            for output in (False, True):
                for query in (False, True):
                    self.prepare_composed(kind)
                    if not output:
                        del self.report["entities"][" 2"]
                        self.report["assumptions"][0]["assumptions"] = []
                    if not query:
                        # A positive input length can establish validity.
                        del self.report["entities"][" 4"]
                    self.refresh_composed()
                    with self.subTest(kind=kind, output=output, query=query):
                        self.assertEqual(audit_reports(self.path, {"main"}, application_kind=kind)["proof_checks"], 1)
                    complete = copy.deepcopy(self.report)
                    for missing in (" 3", " 5"):
                        self.report = copy.deepcopy(complete)
                        del self.report["entities"][missing]
                        # First_Or_Default and Reject remain required in each
                        # non-bare argument-call shape; neither is referenced
                        # by these test dependencies.
                        self.refresh_composed()
                        with self.subTest(kind=kind, output=output, query=query, missing=missing), self.assertRaises(EvidenceError):
                            audit_reports(self.path, {"main"}, application_kind=kind)

    def test_composed_advisories_cannot_reference_callees_or_hide_extra_diagnostics(self) -> None:
        for kind in ("assigned", "selected"):
            for change in ("callee", "unknown", "wrong ghost"):
                self.prepare_composed(kind, warning=True)
                if change == "callee":
                    self.report["flow"][0]["entity"] = 2
                elif change == "unknown":
                    self.report["flow"][0]["message"]["text"] = "unused assignment "
                else:
                    self.report["flow"][0]["message"]["text"] = (
                        '"Other" is set by "Put_Line" but not used after the call')
                self.refresh_composed()
                with self.subTest(kind=kind, change=change), self.assertRaises(EvidenceError):
                    audit_reports(self.path, {"main"}, application_kind=kind)

    def test_binding_advisory_lists_and_exact_unused_assignment_scope(self) -> None:
        for kind in ("static", "argument", "assigned", "selected"):
            for bare in (False, True):
                self.prepare_composed(kind, warning=True, count=0)
                if bare:
                    self.report["entities"] = {" 1": self.report["entities"][" 1"]}
                    self.report["assumptions"] = []
                advisory = self.report["flow"][0]
                self.report["flow"] = [dict(advisory, message={
                    "text": f'initialization of "Value_{i}" has no effect'}) for i in range(3)]
                self.refresh_composed()
                stats = audit_reports(self.path, {"main"}, application_kind=kind)
                self.assertEqual((stats["flow_checks"], stats["assignment_advisories"]), (0, 3))
                self.report["flow"].append(dict(advisory, message={"text": "unused assignment"}))
                self.refresh_composed()
                with self.subTest(kind=kind, bare=bare):
                    if kind in ("assigned", "selected"):
                        stats = audit_reports(self.path, {"main"}, application_kind=kind)
                        self.assertEqual(stats["assignment_advisories"], 4)
                    else:
                        with self.assertRaises(EvidenceError):
                            audit_reports(self.path, {"main"}, application_kind=kind)

    def test_comparison_advisories_require_exact_rules_messages_and_routes(self) -> None:
        pairs = (("INEFFECTIVE", "statement has no effect"),
                 ("DEAD_CODE", "this statement is never reached"))
        mutations = (("severity", "info"), ("how_proved", "prover"),
                     ("file", "./main.adb"), ("entity", 2), ("line", 0), ("col", 0),
                     ("suppressed", False), ("justification", ""))
        for kind in ("static", "argument", "assigned", "selected"):
            for bare in (False, True):
                for rule, message in pairs:
                    self.prepare_composed(kind, warning=True, count=0 if bare else 1)
                    if bare:
                        self.report["entities"] = {" 1": self.report["entities"][" 1"]}
                        self.report["assumptions"] = []
                    self.report["flow"][0].update(rule=rule, message={"text": message})
                    self.refresh_composed()
                    with self.subTest(kind=kind, bare=bare, rule=rule):
                        stats = audit_reports(self.path, {"main"}, application_kind=kind)
                        self.assertEqual((stats["flow_checks"], stats["assignment_advisories"]), (0, 1))
                    base = copy.deepcopy(self.report)
                    changes = (*mutations, ("message", {"text": message + " "}),
                               ("rule", "DEAD_CODE" if rule == "INEFFECTIVE" else "INEFFECTIVE"))
                    for field, value in changes:
                        self.report = copy.deepcopy(base)
                        self.report["flow"][0][field] = value
                        self.refresh_composed()
                        with self.subTest(kind=kind, bare=bare, rule=rule, field=field):
                            with self.assertRaises(EvidenceError):
                                audit_reports(self.path, {"main"}, application_kind=kind)

    def test_nonassignment_bare_sequences_preserve_main_coverage(self) -> None:
        for kind in ("static", "argument"):
            self.report["spark"] = {" 1": "all"}
            self.prepare_composed(kind, warning=False, count=0)
            self.report["entities"] = {" 1": self.report["entities"][" 1"]}
            self.report["assumptions"] = []
            self.refresh_composed()
            self.assertEqual(audit_reports(self.path, {"main"}, application_kind=kind)["proof_checks"], 0)
            self.report["spark"] = {}
            self.refresh_composed()
            with self.assertRaises(EvidenceError):
                audit_reports(self.path, {"main"}, application_kind=kind)

    def test_repeated_output_ghost_advisories_are_exact(self) -> None:
        for kind in ("static", "argument", "assigned", "selected"):
            for name, operation in product(("Written_Count", "Flushed", "Succeeded", "Written_Bytes"),
                                           ("Put_Line", "Put")):
                message = f'"{name}" is set by "{operation}" but not used after the call'
                self.prepare_composed(kind, warning=True, count=0)
                self.report["flow"][0]["message"] = {"text": message}
                self.refresh_composed()
                self.assertEqual(audit_reports(self.path, {"main"}, application_kind=kind)["assignment_advisories"], 1)
                base = copy.deepcopy(self.report)
                for field, value in (("rule", "DEAD_CODE"), ("severity", "info"),
                                     ("how_proved", "prover"), ("entity", 2),
                                     ("file", "silver_io.adb"), ("line", 0), ("col", 0),
                                     ("suppressed", False), ("justification", ""),
                                     ("message", {"text": message + " "}),
                                     ("message", {"text": message.replace(operation, "Other")}),
                                     ("message", {"text": message.replace(name, "Other")})):
                    self.report = copy.deepcopy(base)
                    self.report["flow"][0][field] = value
                    self.refresh_composed()
                    with self.subTest(kind=kind, operation=operation, name=name, field=field):
                        with self.assertRaises(EvidenceError):
                            audit_reports(self.path, {"main"}, application_kind=kind)

    def test_length_overflow_division_and_index_policy_rejects_consistent_mutations(self) -> None:
        changes = (("severity", "warning"), ("severity", "low"),
                   ("how_proved", "flow"), ("how_proved", "trivial"),
                   ("rule", "VC_ASSERT"), ("file", "./main.adb"),
                   ("entity", 2), ("line", 0), ("col", 0),
                   ("justification", ""), ("justified", False), ("suppressed", False),
                   ("annot_kind", ""), ("justif_msg", ""))
        for kind, rule in product(("static", "argument", "assigned", "selected"),
                                  ("VC_LENGTH_CHECK", "VC_OVERFLOW_CHECK", "VC_DIVISION_CHECK", "VC_INDEX_CHECK")):
            self.prepare_composed(kind, warning=True, count=1)
            self.report["proof"][0]["rule"] = rule
            self.refresh_composed()
            self.assertEqual(audit_reports(self.path, {"main"}, application_kind=kind)["proof_checks"], 1)
            base = copy.deepcopy(self.report)
            for field, value in changes:
                self.report = copy.deepcopy(base)
                self.report["proof"][0][field] = value
                self.refresh_composed()
                with self.subTest(kind=kind, rule=rule, field=field), self.assertRaises(EvidenceError):
                    audit_reports(self.path, {"main"}, application_kind=kind)
            self.report = copy.deepcopy(base)
            self.report["entities"] = {" 1": self.report["entities"][" 1"]}
            self.report["assumptions"] = []
            self.refresh_composed()
            self.assertEqual(audit_reports(self.path, {"main"}, application_kind=kind)["proof_checks"], 1)
            self.report["proof"][0]["how_proved"] = "trivial"
            self.refresh_composed()
            with self.assertRaises(EvidenceError):
                audit_reports(self.path, {"main"}, application_kind=kind)

    def test_composed_policy_selection_is_explicit_and_validated(self) -> None:
        self.prepare_composed("static")
        self.refresh_composed()
        with self.assertRaises(EvidenceError):
            audit_reports(self.path, {"main"}, application_kind="typo")
        with self.assertRaises(EvidenceError):
            audit_reports(self.path, {"main"}, application_kind="selected")

    def test_partial_and_mixed_output_entities_keep_exact_policies(self) -> None:
        for kind in ("static", "argument", "assigned", "selected"):
            dynamic = kind in ("argument", "selected")
            for query in ((False, True) if dynamic else (False,)):
                for operations in (("Put",), ("Put_Line",), ("Put", "Put_Line")):
                    self.prepare_composed(kind, count=0)
                    self.report["entities"] = {
                        key: value for key, value in self.report["entities"].items()
                        if not value["name"].startswith("Silver_IO.")
                        and (query or value["name"] != "Silver_Arguments.Input_Is_Valid")}
                    next_key = max(int(key) for key in self.report["entities"]) + 1
                    output_keys = []
                    for index, operation in enumerate(operations, next_key):
                        key = f" {index}"
                        self.report["entities"][key] = {
                            "name": "Silver_IO." + operation,
                            "sloc": [{"file": "silver_io.ads", "line": 1, "column": 1}]}
                        output_keys.append(key)
                    self.report["assumptions"] = [{"claim": {"arg": 1, "predicate": "CLAIM_EFFECTS"},
                        "assumptions": [{"arg": int(key), "predicate": "CLAIM_EFFECTS"}
                                        for key in self.report["entities"] if key != " 1"]}]
                    baseline = copy.deepcopy(self.report)
                    self.refresh_composed()
                    with self.subTest(kind=kind, query=query, operations=operations):
                        audit_reports(self.path, {"main"}, application_kind=kind)
                        for key in output_keys:
                            for field, value in (("name", "Silver_IO.Other"),
                                                 ("sloc", [{"file": "silver_arguments.ads",
                                                            "line": 1, "column": 1}])):
                                self.report = copy.deepcopy(baseline)
                                self.report["entities"][key][field] = value
                                self.refresh_composed()
                                with self.assertRaises(EvidenceError):
                                    audit_reports(self.path, {"main"}, application_kind=kind)
                            self.report = copy.deepcopy(baseline)
                            self.report["spark"][key] = "all"
                            self.refresh_composed()
                            with self.assertRaises(EvidenceError):
                                audit_reports(self.path, {"main"}, application_kind=kind)
                        self.report = copy.deepcopy(baseline)
                        self.report["entities"][" 99"] = self.report["entities"][output_keys[0]]
                        self.refresh_composed()
                        with self.assertRaises(EvidenceError):
                            audit_reports(self.path, {"main"}, application_kind=kind)
                        if dynamic:
                            for name in ("Silver_Arguments.First_Or_Default", "Silver_Arguments.Reject"):
                                self.report = copy.deepcopy(baseline)
                                self.report["entities"] = {
                                    key: value for key, value in self.report["entities"].items()
                                    if value["name"] != name}
                                self.report["assumptions"] = []
                                self.refresh_composed()
                                with self.assertRaises(EvidenceError):
                                    audit_reports(self.path, {"main"}, application_kind=kind)

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
        for unit, symbols in (("silver_libc", ("fopen",)),
                              ("silver_image_runtime", ("ada__environment_variables__value__2",)),
                              ("silver_runtime", ("__gnat_set_exit_status",)),
                              ("silver_output_libc", ("putchar",)),
                              ("silver_process_runtime", ("system__os_lib__spawn__2",
                                                          "system__strings__free__2"))):
            target = self.path / (unit + ".ads")
            original = (root / "src" / target.name).read_text()
            target.write_text(original)
            audit_import_spec(target)
            for symbol in symbols:
                for external_name in ('"unreviewed_wrapper"', '"f open"', '"f--comment\nopen"'):
                    with self.subTest(unit=unit, symbol=symbol, external_name=external_name):
                        target.write_text(original.replace('"' + symbol + '"', external_name))
                        with self.assertRaises(EvidenceError):
                            audit_import_spec(target)
            if unit == "silver_process_runtime":
                for before, after in (("Pre => Program_Name'Length > 0", "Pre => True"),
                                      ("Post => Args = null", "Post => Args /= null"),
                                      ("type String_Access is access String;",
                                       "type String_Access is access constant String;")):
                    with self.subTest(unit=unit, changed=before):
                        self.assertIn(before, original)
                        target.write_text(original.replace(before, after))
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
                              ("silver_output_libc", "Silver_Output_Libc"),
                              ("silver_process_runtime", "Silver_Process_Runtime")):
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
                if unit == "silver_process_runtime":
                    for index in range(2, len(names) + 1):
                        missing = copy.deepcopy(report)
                        missing["entities"].pop(str(index))
                        missing["spark"].pop(str(index))
                        target.write_text(json.dumps(missing))
                        self.refresh_reports()
                        with self.subTest(missing=names[index - 1]), self.assertRaisesRegex(
                                EvidenceError, "missing approved import declaration coverage"):
                            audit_reports(self.path, {unit}, {unit})
                    target.write_text(json.dumps(report))
                    self.refresh_reports()
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

    def test_membership_character_literals_preserve_source_policy(self) -> None:
        target = self.path / "main.adb"
        source = '''procedure Main is
          function Special (C : Character) return Boolean is
            (C in '"' | '\\' | '/');
          begin null; end Main;
        '''
        target.write_text(source)
        audit_source_policy(target)
        target.write_text(source.replace("begin null;", "pragma Assume (False); begin null;"))
        with self.assertRaisesRegex(EvidenceError, "forbidden assumption/check-policy pragma"):
            audit_source_policy(target)

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


class ArrayInitializationAdvisoryTests(unittest.TestCase):
    def setUp(self) -> None:
        ProofEvidenceTests.setUp(self)
        self.initial_report = copy.deepcopy(self.report)
        self.initial_sarif = copy.deepcopy(self.sarif)
        self.prepare_array_advisory()

    def prepare_array_advisory(self) -> None:
        self.unit = "silver_output_profile"
        self.report = copy.deepcopy(self.initial_report)
        self.report["entities"] = {" 1": {"name": "Silver_Output_Profile.Initial_Flow",
                                          "sloc": [{"file": self.unit + ".adb",
                                                    "line": 1152, "column": 13}]}}
        self.report["assumptions"] = []
        self.report["proof"] = [{"severity": "info", "how_proved": "prover", "entity": 1,
                                 "rule": "VC_INDEX_CHECK", "file": self.unit + ".adb",
                                 "line": 1161, "col": 16, "message": {"text": "index check proved"}}]
        # Exact native GNATprove 16.1 diagnostic, without an obligation entity.
        self.note = {"rule": "array-initialization", "severity": "warning", "how_proved": "trivial",
                     "file": self.unit + ".adb", "line": 1161, "col": 16,
                     "message": {"text": "initialization of an array in FOR loop is handled imprecisely "
                                          "[array-initialization]"},
                     "unproved_status": {"status": "unknown"}, "check_tree": {}, "suppressed": ""}
        self.report["warn_error"] = [self.note]
        self.reports = {self.unit: self.report}
        self.sarif = copy.deepcopy(self.initial_sarif)

    def write_reports(self) -> None:
        diagnostics = []
        summary = []
        flow = proof = 0
        for unit, report in self.reports.items():
            (self.path / (unit + ".spark")).write_text(json.dumps(report))
            summary.append(f"in unit {unit}, 1 subprograms and packages out of 1 analyzed")
            flow += len(report["flow"])
            proof += len(report["proof"])
            for section in ("flow", "proof", "warn_error"):
                for record in report[section]:
                    diagnostic = {
                        "ruleId": record.get("rule"), "kind": "pass", "level": "none",
                        "message": record.get("message"), "locations": [{"physicalLocation": {
                            "artifactLocation": {"uri": record.get("file")},
                            "region": {"startLine": record.get("line"), "startColumn": record.get("col")}}}]}
                    if section == "warn_error":
                        diagnostic.update(kind="open", level="warning", suppressions=[{"kind": "external"}])
                    diagnostics.append(diagnostic)
        (self.path / "gnatprove.out").write_text(
            f"Total {flow + proof} {flow} {proof} . .\n" + "\n".join(summary) + "\n")
        self.sarif["runs"][0]["results"] = diagnostics
        (self.path / "gnatprove.sarif").write_text(json.dumps(self.sarif))

    def audit(self, application_kind: str | None = None) -> dict[str, int]:
        self.write_reports()
        return audit_reports(self.path, set(self.reports), application_kind=application_kind)

    def test_exact_compiler_advisory_is_separate_from_required_checks(self) -> None:
        stats = self.audit()
        self.assertEqual((stats["array_initialization_advisories"], stats["flow_checks"],
                          stats["proof_checks"], stats["limitation_notes"]), (1, 0, 1, 0))
        (self.path / "gnatprove.out").write_text(
            f"Total 2 . 2 . .\nin unit {self.unit}, 1 subprograms and packages out of 1 analyzed\n")
        with self.assertRaisesRegex(EvidenceError, "check totals disagree"):
            audit_reports(self.path, {self.unit})

    def test_compiler_advisory_requires_exact_native_metadata(self) -> None:
        changes = ({"rule": "numeric-variant"}, {"severity": "info"}, {"severity": "medium"},
                   {"how_proved": "prover"}, {"how_proved": "unproved"},
                   {"file": "other.adb"}, {"file": "./silver_output_profile.adb"},
                   {"line": 0}, {"line": True}, {"line": 1161.0},
                   {"col": 0}, {"col": True}, {"col": 16.0},
                   {"message": {"text": "initialization might fail [array-initialization]"}},
                   {"message": {"text": self.note["message"]["text"], "extra": True}},
                   {"unproved_status": {"status": "valid"}},
                   {"unproved_status": {"status": "unknown", "extra": True}},
                   {"check_tree": {"unproved": True}}, {"suppressed": "source suppression"},
                   {"suppressed": False}, {"entity": 1}, {"justification": ""},
                   {"justified": False}, {"annot_kind": ""}, {"justif_msg": ""}, {"extra": True})
        for change in changes:
            with self.subTest(change=change):
                self.prepare_array_advisory()
                self.note.update(change)
                with self.assertRaisesRegex(EvidenceError, "unexpected array-initialization advisory"):
                    self.audit()
        self.prepare_array_advisory()
        for field in tuple(self.note):
            with self.subTest(missing=field):
                self.prepare_array_advisory()
                self.note.pop(field, None)
                with self.assertRaisesRegex(EvidenceError, "unexpected array-initialization advisory"):
                    self.audit()

    def test_compiler_advisory_cannot_replace_or_hide_required_work(self) -> None:
        for section, severity in product(("flow", "proof"), ("warning", "info")):
            with self.subTest(section=section, severity=severity):
                self.prepare_array_advisory()
                self.note.update(severity=severity, entity=1)
                self.report["warn_error"] = []
                self.report[section] = [self.note]
                with self.assertRaisesRegex(EvidenceError, "unexpected array-initialization advisory"):
                    self.audit()
        for section, record in (("flow", {"severity": "high", "how_proved": "flow", "rule": "UNINITIALIZED"}),
                                ("proof", {"severity": "medium", "how_proved": "unproved"})):
            with self.subTest(section=section):
                self.prepare_array_advisory()
                failed = dict(self.report["proof"][0], **record)
                self.report[section].append(failed)
                with self.assertRaisesRegex(EvidenceError, "not proved/info"):
                    self.audit()
        for section in ("skip_flow_proof", "skip_proof", "pragma_assume"):
            with self.subTest(section=section):
                self.prepare_array_advisory()
                self.report[section] = [1]
                with self.assertRaisesRegex(EvidenceError, "missing or nonempty"):
                    self.audit()

    def test_advisory_is_accepted_only_for_main_in_application_audits(self) -> None:
        for kind, target in product(("static", "argument", "assigned", "selected"), ("main", "library")):
            with self.subTest(kind=kind, target=target):
                self.prepare_array_advisory()
                main = copy.deepcopy(self.initial_report)
                main["assumptions"] = []
                if target == "main":
                    main["warn_error"] = [dict(self.note, file="main.adb")]
                    self.report["warn_error"] = []
                self.reports["main"] = main
                if target == "main":
                    self.assertEqual(self.audit(application_kind=kind)["array_initialization_advisories"], 1)
                else:
                    with self.assertRaisesRegex(EvidenceError, "unexpected array-initialization advisory"):
                        self.audit(application_kind=kind)

    def test_advisory_is_rejected_for_unreviewed_compiler_units(self) -> None:
        self.unit = "silver_io"
        self.note["file"] = self.unit + ".adb"
        self.report["proof"][0]["file"] = self.unit + ".adb"
        self.report["entities"][" 1"].update(
            name="Silver_IO.Put", sloc=[{"file": self.unit + ".adb", "line": 1, "column": 1}])
        self.reports = {self.unit: self.report}
        with self.assertRaisesRegex(EvidenceError, "unexpected array-initialization advisory"):
            self.audit()

    def test_advisory_requires_exact_sarif_classification_and_coverage(self) -> None:
        changes = ({"kind": "pass", "level": "none"}, {"kind": "informational"},
                   {"level": "error"}, {"ruleId": "numeric-variant"},
                   {"message": {"text": "different advisory"}}, {"suppressions": []},
                   {"suppressions": [{"kind": "inSource"}]},
                   {"suppressions": [{"kind": "external", "justification": "trusted"}]},
                   {"properties": {"extra": True}})
        for change in changes:
            with self.subTest(change=change):
                self.prepare_array_advisory()
                self.write_reports()
                self.sarif["runs"][0]["results"][-1].update(change)
                (self.path / "gnatprove.sarif").write_text(json.dumps(self.sarif))
                with self.assertRaises(EvidenceError):
                    audit_reports(self.path, {self.unit})
        for field, value in (("uri", "./silver_output_profile.adb"),
                             ("startLine", 1161.0), ("startColumn", 16.0),
                             ("startLine", True), ("startColumn", True)):
            with self.subTest(field=field, value=value):
                self.prepare_array_advisory()
                self.write_reports()
                location = self.sarif["runs"][0]["results"][-1]["locations"][0]["physicalLocation"]
                location["artifactLocation" if field == "uri" else "region"][field] = value
                (self.path / "gnatprove.sarif").write_text(json.dumps(self.sarif))
                with self.assertRaises(EvidenceError):
                    audit_reports(self.path, {self.unit})
        for duplicate in (False, True):
            with self.subTest(duplicate=duplicate):
                self.prepare_array_advisory()
                self.write_reports()
                results = self.sarif["runs"][0]["results"]
                if duplicate:
                    results.append(copy.deepcopy(results[-1]))
                else:
                    results.pop()
                (self.path / "gnatprove.sarif").write_text(json.dumps(self.sarif))
                with self.assertRaisesRegex(EvidenceError, "diagnostic coverage disagree"):
                    audit_reports(self.path, {self.unit})


class VendorProofEvidenceTests(unittest.TestCase):
    refresh_reports = ProofEvidenceTests.refresh_reports

    def setUp(self) -> None:
        ProofEvidenceTests.setUp(self)
        self.initial_report = copy.deepcopy(self.report)
        self.initial_sarif = copy.deepcopy(self.sarif)

    def prepare_vendor(self) -> None:
        self.report = copy.deepcopy(self.initial_report)
        self.sarif = copy.deepcopy(self.initial_sarif)
        self.instance = (14, 4, 12)
        self.model = copy.deepcopy(self.report)
        self.model["entities"] = {" 1": {"name": "Silver_Report_Projection_Model",
                                       "sloc": [{"file": SEQUENCE_UNIT + ".ads",
                                                 "line": 8, "column": 9}]}}
        self.model["spark"] = {" 1": "all"}
        for index, (name, locations) in enumerate(sorted(sequence_entities(self.instance)), 2):
            key = f" {index}"
            self.model["entities"][key] = {
                "name": name, "sloc": [{"file": file, "line": line, "column": col}
                                       for file, line, col in locations]}
            self.model["spark"][key] = "spec"

    def prepare_note(self) -> None:
        self.prepare_vendor()
        self.note = {"rule": "error", "severity": "warning", "how_proved": "trivial",
                     "file": "a-nbnbin.ads", "line": 60, "col": 17, "check_tree": {},
                     "message": {"text": BIG_INTEGER_VALIDITY_TEXT},
                     "unproved_status": {"status": "unknown"}}
        self.report["warn_error"] = [self.note]
        self.sarif["runs"][0]["results"] = [{"ruleId": "error", "kind": "open", "level": "warning"}]

    def audit_vendor(self) -> dict:
        (self.path / "main.spark").write_text(json.dumps(self.report))
        (self.path / (SEQUENCE_UNIT + ".spark")).write_text(json.dumps(self.model))
        self.refresh_reports()
        return audit_reports(self.path, {"main", SEQUENCE_UNIT}, proof_instance=self.instance)

    def test_exact_vendor_premises_are_counted_separately_from_checks(self) -> None:
        self.prepare_note()
        stats = self.audit_vendor()
        self.assertEqual(stats["vendor_spec_entities"], 30)
        self.assertEqual(stats["trusted_math_notes"], 1)
        self.assertEqual(stats["proof_checks"], 0)
        self.assertEqual(stats["limitation_notes"], 0)
        self.assertEqual(stats["imported_entities"], 0)
        for line, col in ((36, 32), (54, 17)):
            self.note.update(line=line, col=col)
            self.assertEqual(self.audit_vendor()["trusted_math_notes"], 1)

    def test_unknown_warning_and_changed_vendor_note_are_rejected(self) -> None:
        changes = ({"rule": "VC_ASSERT"}, {"file": "silver_report_projection_model.ads"},
                   {"file": "/other/a-nbnbin.ads"}, {"line": 61}, {"col": 18},
                   {"message": {"text": BIG_INTEGER_VALIDITY_TEXT + "."}},
                   {"message": {"text": "an unclassified warning"}},
                   {"severity": "info"}, {"severity": "medium"},
                   {"how_proved": "prover"}, {"unproved_status": {"status": "valid"}},
                   {"suppressed": ""}, {"justification": "trusted"},
                   {"annot_kind": "False_Positive"}, {"justif_msg": "trusted"})
        for change in changes:
            with self.subTest(change=change):
                self.prepare_note()
                self.note.update(change)
                with self.assertRaises(EvidenceError):
                    self.audit_vendor()

    def test_vendor_note_cannot_replace_flow_or_proof_results(self) -> None:
        for section in ("flow", "proof"):
            with self.subTest(section=section):
                self.prepare_note()
                self.report["warn_error"] = []
                self.report[section] = [self.note]
                with self.assertRaises(EvidenceError):
                    self.audit_vendor()
                self.report[section] = []
        self.prepare_note()
        self.report["proof"] = [{"severity": "medium", "how_proved": "unproved"}]
        with self.assertRaises(EvidenceError):
            self.audit_vendor()

    def test_vendor_note_requires_exact_sarif_and_diagnostic_coverage(self) -> None:
        changes = ({"kind": "pass", "level": "none"}, {"kind": "informational"},
                   {"level": "error"}, {"ruleId": "numeric-variant"},
                   {"message": {"text": "different premise"}},
                   {"suppressions": [{"kind": "external"}]},
                   {"locations": [{"physicalLocation": {
                       "artifactLocation": {"uri": "/other/a-nbnbin.ads"},
                       "region": {"startLine": 60, "startColumn": 17}}}]})
        for change in changes:
            with self.subTest(change=change):
                self.prepare_note()
                self.sarif["runs"][0]["results"][0].update(change)
                with self.assertRaises(EvidenceError):
                    self.audit_vendor()
        self.prepare_note()
        self.audit_vendor()
        path = self.path / "gnatprove.sarif"
        sarif = json.loads(path.read_text())
        sarif["runs"][0]["results"] *= 2
        path.write_text(json.dumps(sarif))
        with self.assertRaisesRegex(EvidenceError, "diagnostic coverage disagree"):
            audit_reports(self.path, {"main", SEQUENCE_UNIT}, proof_instance=self.instance)

    def test_vendor_specs_do_not_exempt_owned_helpers_or_unknown_declarations(self) -> None:
        self.prepare_vendor()
        self.model["spark"][" 1"] = "spec"
        with self.assertRaisesRegex(EvidenceError, "outside full SPARK"):
            self.audit_vendor()
        for change in ("name", "vendor_file", "vendor_line", "instance", "missing"):
            with self.subTest(change=change):
                self.prepare_vendor()
                key = next(key for key, entity in self.model["entities"].items()
                           if entity["name"] == SEQUENCE_NAME + ".Length")
                entity = self.model["entities"][key]
                if change == "name":
                    entity["name"] = SEQUENCE_NAME + ".Unproved_Owned_Helper"
                elif change == "vendor_file":
                    entity["sloc"][0]["file"] = "silver_report_projection_model.ads"
                elif change == "vendor_line":
                    entity["sloc"][0]["line"] += 1
                elif change == "instance":
                    entity["sloc"][-1]["line"] += 1
                else:
                    del self.model["entities"][key]
                    del self.model["spark"][key]
                with self.assertRaises(EvidenceError):
                    self.audit_vendor()

    def test_exact_big_integer_dependency_and_origin_are_required(self) -> None:
        self.prepare_vendor()
        entity = {"name": 'Ada.Numerics.Big_Numbers.Big_Integers."+"',
                  "sloc": [{"file": "a-nbnbin.ads", "line": 135, "column": 13}]}
        self.report["entities"][" 2"] = entity
        self.report["assumptions"][0]["assumptions"] = [{"arg": 2, "predicate": "CLAIM_POST"}]
        self.audit_vendor()
        for change in ("operation", "file", "line", "extra_origin"):
            with self.subTest(change=change):
                bad = copy.deepcopy(entity)
                if change == "operation":
                    bad["name"] = 'Ada.Numerics.Big_Numbers.Big_Integers."*"'
                elif change == "file":
                    bad["sloc"][0]["file"] = "unreviewed.ads"
                elif change == "line":
                    bad["sloc"][0]["line"] += 1
                else:
                    bad["sloc"].append({"file": "unreviewed.ads", "line": 1, "column": 1})
                self.report["entities"][" 2"] = bad
                with self.assertRaisesRegex(EvidenceError, "unapproved external assumption"):
                    self.audit_vendor()

    def test_proof_instance_requires_exact_static_ghost_character_binding(self) -> None:
        root = Path(__file__).resolve().parents[1]
        source = (root / "src" / (SEQUENCE_UNIT + ".ads")).read_text()
        target = self.path / (SEQUENCE_UNIT + ".ads")
        target.write_text(source)
        self.assertEqual(audit_sequence_instance(target), (14, 4, 12))
        for old, new in (("Ghost => Static", "Ghost => Check"),
                         ("Ghost => Static", ""),
                         ("Element_Type => Character", "Element_Type => Integer"),
                         ("Use_Logical_Equality => True", "Use_Logical_Equality => False"),
                         ("Functional.Infinite_Sequences", "Functional.Unreviewed_Sequences")):
            with self.subTest(replacement=new):
                self.assertIn(old, source)
                target.write_text(source.replace(old, new))
                with self.assertRaisesRegex(EvidenceError, "unreviewed proof-container"):
                    audit_sequence_instance(target)
        target.write_text("-- retained layout change\n" + source)
        self.assertEqual(audit_sequence_instance(target), (15, 4, 12))

    def test_vendor_premises_require_source_enabled_compiler_scope(self) -> None:
        self.prepare_note()
        self.audit_vendor()
        with self.assertRaises(EvidenceError):
            audit_reports(self.path, {"main", SEQUENCE_UNIT})
        with self.assertRaisesRegex(EvidenceError, "reviewed compiler model"):
            audit_reports(self.path, {"main", SEQUENCE_UNIT}, proof_instance=self.instance,
                          application_kind="static")

    def test_image_instance_requires_exact_static_ghost_observations(self) -> None:
        root = Path(__file__).resolve().parents[1]
        source = (root / "src/silver_image_files.ads").read_text()
        target = self.path / "silver_image_files.ads"
        target.write_text(source)
        self.assertEqual(audit_sequence_instance(target), (12, 4, 12))
        for old, new in (("Ghost => Static", "Ghost => Check"),
                         ("Ghost => Static", ""),
                         ("Element_Type => Character", "Element_Type => Integer"),
                         ("Use_Logical_Equality => True", "Use_Logical_Equality => False"),
                         ("package Bytes is new", "package Other is new")):
            with self.subTest(replacement=new):
                target.write_text(source.replace(old, new))
                with self.assertRaisesRegex(EvidenceError, "unreviewed proof-container"):
                    audit_sequence_instance(target)

    def test_signed_conversion_requires_exact_type_and_visible_generic(self) -> None:
        root = Path(__file__).resolve().parents[1]
        source = (root / "src/silver_image_files.ads").read_text()
        target = self.path / "silver_image_files.ads"
        target.write_text(source)
        self.assertEqual(audit_signed_conversion_instance(target), (16, 4, 12))
        for old, new in (("Signed_Conversions (Model.Byte_Count)", "Signed_Conversions (Integer)"),
                         ("Signed_Conversions (", "Unsigned_Conversions ("),
                         ("package Counts is new", "package Other is new"),
                         ("renames Silver_Image_Model", "renames Other_Model"),
                         ("with SPARK.Big_Integers;", "with Other.Big_Integers;"),
                         ("use SPARK.Big_Integers;", "use Other.Big_Integers;"),
                         ("SPARK_Mode => On", "SPARK_Mode => Off"),
                         ("   package Counts is new", "   package Signed_Conversions renames Other;\n"
                          "   package Counts is new"),
                         ("end Silver_Image_Files;", "package Counts is new Signed_Conversions (Model.Byte_Count);\n"
                          "end Silver_Image_Files;")):
            with self.subTest(replacement=new):
                self.assertIn(old, source)
                target.write_text(source.replace(old, new))
                with self.assertRaisesRegex(EvidenceError, "unreviewed signed-conversion"):
                    audit_signed_conversion_instance(target)
        target.write_text("-- retained layout change\n" + source)
        self.assertEqual(audit_signed_conversion_instance(target), (17, 4, 12))
        other = self.path / "other.ads"
        other.write_text(source)
        with self.assertRaisesRegex(EvidenceError, "unreviewed signed-conversion"):
            audit_signed_conversion_instance(other)

    def test_signed_conversion_specs_require_both_exact_vendor_origins(self) -> None:
        self.prepare_vendor()
        unit = SIGNED_CONVERSION_UNIT
        sequence_instance = (12, 4, 12)
        conversion_instance = (16, 4, 12)
        image = copy.deepcopy(self.initial_report)
        image["entities"] = {" 1": {"name": "Silver_Image_Files",
                                   "sloc": [{"file": unit + ".ads", "line": 7, "column": 9}]}}
        image["spark"] = {" 1": "all"}
        declarations = sequence_entities(sequence_instance, unit=unit) | signed_conversion_entities(conversion_instance)
        for index, (name, locations) in enumerate(sorted(declarations), 2):
            key = f" {index}"
            image["entities"][key] = {"name": name,
                "sloc": [{"file": file, "line": line, "column": col} for file, line, col in locations]}
            image["spark"][key] = "spec"
        initial = copy.deepcopy(image)

        def audit(conversion=conversion_instance) -> dict:
            for name, report in (("main", self.report), (SEQUENCE_UNIT, self.model), (unit, image)):
                (self.path / (name + ".spark")).write_text(json.dumps(report))
            self.refresh_reports()
            return audit_reports(self.path, {"main", SEQUENCE_UNIT, unit},
                proof_instances={SEQUENCE_UNIT: self.instance, unit: sequence_instance},
                signed_conversion_instance=conversion)

        self.assertEqual(audit()["vendor_spec_entities"], 62)
        with self.assertRaisesRegex(EvidenceError, "outside full SPARK") as failure:
            audit(None)
        self.assertIn(SIGNED_CONVERSION_NAME + ".", str(failure.exception))
        self.assertIn("a-nbnbin.ads", str(failure.exception))
        for operation in ("To_Big_Integer", "From_Big_Integer"):
            for mutation in ("name", "vendor_file", "vendor_line", "vendor_column",
                             "instance_file", "instance_line", "instance_column",
                             "extra_origin", "missing", "owned_helper"):
                with self.subTest(operation=operation, mutation=mutation):
                    image = copy.deepcopy(initial)
                    key = next(key for key, entity in image["entities"].items()
                               if entity["name"] == SIGNED_CONVERSION_NAME + "." + operation)
                    entity = image["entities"][key]
                    if mutation == "name":
                        entity["name"] = "Other.Counts." + operation
                    elif mutation in ("vendor_file", "instance_file"):
                        entity["sloc"][0 if mutation == "vendor_file" else 1]["file"] = "unreviewed.ads"
                    elif mutation in ("vendor_line", "vendor_column", "instance_line", "instance_column"):
                        position, field = mutation.split("_")
                        entity["sloc"][0 if position == "vendor" else 1][field] += 1
                    elif mutation == "extra_origin":
                        entity["sloc"].append({"file": "unreviewed.ads", "line": 1, "column": 1})
                    elif mutation == "missing":
                        del image["entities"][key]
                        del image["spark"][key]
                    else:
                        image["spark"][" 1"] = "spec"
                    with self.assertRaises(EvidenceError):
                        audit()
        image = copy.deepcopy(initial)
        audit()
        with self.assertRaisesRegex(EvidenceError, "reviewed compiler model"):
            audit_reports(self.path, {"main", SEQUENCE_UNIT, unit},
                          signed_conversion_instance=conversion_instance)

    def test_multiple_instances_keep_separate_exact_declaration_origins(self) -> None:
        self.prepare_vendor()
        unit = "silver_image_files"
        instance = (11, 4, 12)
        image = copy.deepcopy(self.initial_report)
        image["entities"] = {" 1": {"name": "Silver_Image_Files",
                                      "sloc": [{"file": unit + ".ads", "line": 6, "column": 9}]}}
        image["spark"] = {" 1": "all"}
        for index, (name, locations) in enumerate(sorted(sequence_entities(instance, unit=unit)), 2):
            key = f" {index}"
            image["entities"][key] = {"name": name,
                "sloc": [{"file": file, "line": line, "column": col} for file, line, col in locations]}
            image["spark"][key] = "spec"
        initial = copy.deepcopy(image)

        def audit() -> dict:
            for name, report in (("main", self.report), (SEQUENCE_UNIT, self.model), (unit, image)):
                (self.path / (name + ".spark")).write_text(json.dumps(report))
            self.refresh_reports()
            return audit_reports(self.path, {"main", SEQUENCE_UNIT, unit},
                proof_instances={SEQUENCE_UNIT: self.instance, unit: instance})

        self.assertEqual(audit()["vendor_spec_entities"], 60)
        for mutation in ("unit", "instance", "name", "helper", "missing"):
            with self.subTest(mutation=mutation):
                image = copy.deepcopy(initial)
                key = next(key for key, entity in image["entities"].items()
                           if entity["name"] == "Silver_Image_Files.Bytes.Length")
                if mutation == "unit":
                    image["entities"][key]["sloc"][-1]["file"] = SEQUENCE_UNIT + ".ads"
                elif mutation == "instance":
                    image["entities"][key]["sloc"][-1]["line"] += 1
                elif mutation == "name":
                    image["entities"][key]["name"] = SEQUENCE_NAME + ".Length"
                elif mutation == "helper":
                    image["spark"][" 1"] = "spec"
                else:
                    del image["entities"][key]
                    del image["spark"][key]
                with self.assertRaises(EvidenceError):
                    audit()


if __name__ == "__main__":
    unittest.main()
