"""Proof success must stay bound to content, host, command and tool identities."""
from __future__ import annotations

import hashlib
import json
import os
from pathlib import Path
import tempfile
import unittest

from scripts.check_evidence import EvidenceError, PROOF_OPTIONS
from scripts.dev import proof_arguments
from scripts.platforms import HostLayout
from scripts.proof_provenance import (MANIFEST, digest, input_hashes, report_hashes,
                                      validate_project, validate_provenance)


class ProvenanceTests(unittest.TestCase):
    def setUp(self) -> None:
        directory = tempfile.TemporaryDirectory(prefix="silver-provenance-")
        self.addCleanup(directory.cleanup)
        self.root = Path(directory.name)
        self.host = HostLayout(self.root, "linux-aarch64")
        for path in [self.root / "silver.gpr", self.root / "alire.toml",
                     self.host.context / "alire.toml", self.host.context / "alire/alire.lock",
                     self.host.generated / "silver_build.ads", self.root / "src/main.adb",
                     self.root / "scripts/check_evidence.py"]:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("fixture\n")
        (self.root / "silver.gpr").write_bytes((Path(__file__).resolve().parents[1] / "silver.gpr").read_bytes())
        self.reports = self.host.compiler / "obj/gnatprove"
        self.reports.mkdir(parents=True)
        self.command = ["gnatprove", "-P", "../../../silver.gpr", *PROOF_OPTIONS,
                        "-XSILVER_HOST=linux-aarch64"]
        self.sarif = {"runs": [{"invocations": [{"commandLine": " ".join(self.command)}]}]}
        (self.reports / "gnatprove.sarif").write_text(json.dumps(self.sarif))
        (self.reports / "gnatprove.out").write_text("fixture\n")
        (self.reports / "main.spark").write_text("{}\n")
        tool = self.host.tools / "test-tool"
        tool.parent.mkdir(parents=True)
        tool.write_bytes(b"fixture executable")
        version = "fixture 1.0"
        tools = {name: {"path": str(tool), "sha256": digest(tool), "version": version,
                        "version_sha256": hashlib.sha256(version.encode()).hexdigest()}
                 for name in ("gnatprove", "gnatls", "gcc", "gprbuild", "cvc5", "z3", "alt-ergo",
                              "gnat2why", "gnatwhy3", "why3server", "python", "alr")}
        self.manifest = {"schema": 1, "complete": True, "host": self.host.key, "command": self.command,
                         "inputs_sha256": input_hashes(self.host), "tools": tools,
                         "reports_sha256": report_hashes(self.reports)}

    def audit(self) -> None:
        validate_provenance(self.host, self.reports, self.manifest)

    def test_unchanged_content_is_accepted(self) -> None:
        self.audit()

    def test_restored_mtime_does_not_hide_input_change(self) -> None:
        for relative in ("src/main.adb", "silver.gpr", "scripts/check_evidence.py"):
            with self.subTest(path=relative):
                path = self.root / relative
                before = path.stat()
                original = path.read_bytes()
                path.write_bytes(original + b"changed")
                os.utime(path, ns=(before.st_atime_ns, before.st_mtime_ns))
                with self.assertRaisesRegex(EvidenceError, "input hashes changed|project differs"):
                    self.audit()
                path.write_bytes(original)

    def test_new_dependency_or_changed_generated_configuration_is_rejected(self) -> None:
        path = self.root / "src/new.ads"
        path.write_text("package New is end New;")
        with self.assertRaises(EvidenceError):
            self.audit()
        path.unlink()
        (self.host.generated / "silver_build.ads").write_text("different host")
        with self.assertRaises(EvidenceError):
            self.audit()

    def test_report_and_tool_tampering_is_rejected(self) -> None:
        path = self.reports / "main.spark"
        path.write_text('{"proof": []}')
        with self.assertRaisesRegex(EvidenceError, "report hashes changed"):
            self.audit()
        path.write_text("{}\n")
        Path(self.manifest["tools"]["gnatprove"]["path"]).write_bytes(b"replacement")
        with self.assertRaisesRegex(EvidenceError, "tool changed"):
            self.audit()

    def test_effective_configuration_and_host_are_checked(self) -> None:
        self.manifest["host"] = "macos-aarch64"
        with self.assertRaisesRegex(EvidenceError, "different host"):
            self.audit()
        self.manifest["host"] = self.host.key
        self.manifest["command"].insert(-1, "--mode=flow")
        with self.assertRaisesRegex(EvidenceError, "unreviewed proof switch"):
            self.audit()

    def test_sarif_command_must_match_captured_invocation(self) -> None:
        self.sarif["runs"][0]["invocations"][0]["commandLine"] += " --level=0"
        (self.reports / "gnatprove.sarif").write_text(json.dumps(self.sarif))
        self.manifest["reports_sha256"] = report_hashes(self.reports)
        with self.assertRaisesRegex(EvidenceError, "effective configuration"):
            self.audit()

    def test_uncompleted_provenance_cannot_be_reused(self) -> None:
        self.manifest["complete"] = False
        with self.assertRaises(EvidenceError):
            self.audit()
        with self.assertRaisesRegex(EvidenceError, "missing report"):
            validate_provenance(self.host, self.reports)

    def test_audited_path_rejects_proof_weakening(self) -> None:
        for argument in ("--mode=flow", "--level=0", "--no-inlining", "--proof=per_path",
                         "--limit-line=main.adb:1", "-u", "--steps=1", "--replay", "main.adb"):
            with self.subTest(argument=argument), self.assertRaises(RuntimeError):
                proof_arguments([argument])
        self.assertEqual(proof_arguments(["--subdirs", "fresh", "-f"]), ["--subdirs", "fresh"])

    def test_changed_project_cannot_approve_its_own_suppression_or_source_selection(self) -> None:
        path = self.root / "silver.gpr"
        original = path.read_text()
        for change in (original.replace('"src"', '"other_src"'),
                       original.replace('end Compiler;', 'for Local_Configuration_Pragmas use "ignore.adc"; end Compiler;'),
                       original.replace('end Compiler;', 'for Switches ("silver.adb") use ("-gnatp"); end Compiler;')):
            with self.subTest(change=change):
                path.write_text(change)
                self.manifest["inputs_sha256"] = input_hashes(self.host)
                with self.assertRaisesRegex(EvidenceError, "project differs"):
                    self.audit()
        path.write_text(original)
        validate_project(self.host)


if __name__ == "__main__":
    unittest.main()
