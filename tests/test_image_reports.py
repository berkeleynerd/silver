"""Only the producer's exact Image advisory may accompany proved checks."""
from __future__ import annotations

import copy
import json
import unittest

from scripts.check_evidence import EvidenceError, IMAGE_ADVISORY_TEXT, audit_reports
from tests import test_evidence as evidence
from tests import test_library_reports as native


def advisory() -> dict:
    return {"rule": "imprecise-image", "severity": "warning", "how_proved": "trivial",
            "file": "main.adb", "line": 3, "col": 8, "check_tree": {}, "suppressed": "",
            "unproved_status": {"status": "unknown"}, "message": {"text": IMAGE_ADVISORY_TEXT}}


def mutations():
    for key, value in (("rule", "VC_LENGTH_CHECK"), ("severity", "info"),
                       ("how_proved", "prover"), ("file", "other.adb"),
                       ("line", 0), ("col", 0), ("line", True), ("entity", 1),
                       ("check_tree", []), ("check_tree", {"result": "valid"}),
                       ("suppressed", "justified"), ("suppressed", False),
                       ("unproved_status", {"status": "proved"}), ("unproved_status", []),
                       ("message", {"text": IMAGE_ADVISORY_TEXT + " changed"}), ("message", []),
                       ("justification", ""), ("justified", False),
                       ("annot_kind", ""), ("justif_msg", "")):
        yield f"changed {key}={value!r}", dict(advisory(), **{key: value})
    for key in advisory():
        value = advisory()
        del value[key]
        yield f"missing {key}", value


class NativeImageReportTests(unittest.TestCase):
    setUpClass = classmethod(native.LibraryReportTests.setUpClass.__func__)
    tearDownClass = classmethod(native.LibraryReportTests.tearDownClass.__func__)
    accepts = native.LibraryReportTests.accepts

    def test_exact_advisory_preserves_required_checks_in_all_application_policies(self) -> None:
        for kind in ("static", "main", "assignment", "selected"):
            data = native.assignment_report(False)
            data["warn_error"] = [advisory(), advisory()]
            data["proof"] = [dict(native.check(), rule="VC_LENGTH_CHECK", file="main.adb")]
            with self.subTest(kind=kind):
                self.assertTrue(self.accepts(data, kind=kind))
                # This probe reads one line; exercise equivalent interior JSON
                # whitespace without truncating its input at a newline.
                self.assertTrue(self.accepts(json.dumps(data).replace('{}', '{ \t }'), kind=kind))
                data["proof"][0]["severity"] = "medium"
                self.assertFalse(self.accepts(data, kind=kind))

    def test_mutated_missing_duplicate_and_misplaced_advisories_are_rejected(self) -> None:
        data = native.assignment_report(False)
        for description, value in mutations():
            with self.subTest(description=description):
                data["warn_error"] = [value]
                self.assertFalse(self.accepts(data, kind="static"))
        data["warn_error"] = [advisory()]
        raw = json.dumps(data).replace('"rule": "imprecise-image"',
                                     '"rule": "imprecise-image", "rule": "imprecise-image"')
        self.assertFalse(self.accepts(raw, kind="static"))
        for section in ("flow", "proof"):
            bad = native.assignment_report(False)
            bad[section] = [advisory()]
            self.assertFalse(self.accepts(bad, kind="static"))
        for kind, value in (("body", native.report()), ("interface", native.report(True)),
                            ("arguments", native.argument_report()),
                            ("runtime", native.argument_report(True))):
            value["warn_error"] = [advisory()]
            self.assertFalse(self.accepts(value, kind=kind))


class ImageEvidenceTests(unittest.TestCase):
    setUp = evidence.ProofEvidenceTests.setUp
    refresh_reports = evidence.ProofEvidenceTests.refresh_reports

    def prepare(self, value: dict | None = None) -> None:
        self.report["warn_error"] = [advisory() if value is None else value]
        (self.path / "main.spark").write_text(json.dumps(self.report))
        self.refresh_reports()
        # The generic fixture helper supplies an entity to every diagnostic;
        # Image advisories deliberately have none in the actual producer schema.
        (self.path / "main.spark").write_text(json.dumps(self.report))
        sarif = json.loads((self.path / "gnatprove.sarif").read_text())
        sarif["runs"][0]["results"][0].update(
            kind="open", level="warning", suppressions=[{"kind": "external"}])
        (self.path / "gnatprove.sarif").write_text(json.dumps(sarif))

    def test_advisory_is_not_counted_as_a_discharged_check(self) -> None:
        self.prepare()
        for kind in ("static", "argument", "assigned", "selected"):
            stats = audit_reports(self.path, {"main"}, application_kind=kind)
            self.assertEqual((stats["proof_checks"], stats["flow_checks"], stats["image_advisories"]), (0, 0, 1))
        with self.assertRaises(EvidenceError):
            audit_reports(self.path, {"main"})
        # The warning never permits a failed original safety obligation.
        self.report["proof"] = [dict(native.check(), rule="VC_LENGTH_CHECK", file="main.adb", severity="medium")]
        self.prepare()
        with self.assertRaises(EvidenceError):
            audit_reports(self.path, {"main"}, application_kind="static")

    def test_mutated_advisory_fields_are_rejected(self) -> None:
        for description, value in mutations():
            with self.subTest(description=description):
                self.prepare(value)
                with self.assertRaises(EvidenceError):
                    audit_reports(self.path, {"main"}, application_kind="static")

    def test_sarif_must_retain_the_exact_producer_classification(self) -> None:
        self.prepare()
        path = self.path / "gnatprove.sarif"
        original = json.loads(path.read_text())
        for key, value in (("kind", "pass"), ("level", "none"), ("suppressions", []),
                           ("suppressions", [{"kind": "inSource"}]),
                           ("suppressions", [{"kind": "external", "justification": "trust me"}])):
            bad = copy.deepcopy(original)
            bad["runs"][0]["results"][0][key] = value
            path.write_text(json.dumps(bad))
            with self.subTest(key=key, value=value), self.assertRaises(EvidenceError):
                audit_reports(self.path, {"main"}, application_kind="static")


if __name__ == "__main__":
    unittest.main()
