"""Proof success must stay bound to content, host, command and tool identities."""
from __future__ import annotations

import contextlib
import hashlib
import json
import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest import mock

from scripts import dev, proof_provenance
from scripts.check_evidence import EvidenceError, PROOF_OPTIONS
from scripts.dev import proof_arguments
from scripts.platforms import HostLayout
from scripts.proof_provenance import (MANIFEST, digest, input_hashes, report_hashes,
                                      proof_cache, validate_project, validate_provenance)


class ProvenanceTests(unittest.TestCase):
    def setUp(self) -> None:
        directory = tempfile.TemporaryDirectory(prefix="silver provenance ' ")
        self.addCleanup(directory.cleanup)
        self.root = Path(directory.name).resolve()
        self.host = HostLayout(self.root, "linux-aarch64")
        for path in [self.root / "silver.gpr", self.root / "alire.toml",
                     self.host.context / "alire.toml", self.host.context / "alire/alire.lock",
                     self.host.generated / "silver_build.ads", self.root / "src/main.adb",
                     self.root / "scripts/check_evidence.py"]:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("fixture\n")
        (self.root / "silver.gpr").write_bytes((Path(__file__).resolve().parents[1] / "silver.gpr").read_bytes())
        helper = self.root / "proof/silver_proof_containers.gpr"
        helper.parent.mkdir(parents=True)
        helper.write_bytes((Path(__file__).resolve().parents[1] / helper.relative_to(self.root)).read_bytes())
        self.reports = self.host.compiler / "obj/gnatprove"
        self.reports.mkdir(parents=True)
        self.command = ["gnatprove", "-P", "../../../silver.gpr", *PROOF_OPTIONS,
                        "-j", "0", f"--memcached-server=file:{proof_cache(self.host)}", "-f",
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
                         "mode": "full", "initial_state": {"sessions_present": False,
                                                               "cache_entries_present": False},
                         "inputs_sha256": input_hashes(self.host), "tools": tools,
                         "reports_sha256": report_hashes(self.reports)}

        patch = mock.patch.object(proof_provenance, "tool_identities", return_value=tools)
        patch.start()
        self.addCleanup(patch.stop)
        cpus = mock.patch("scripts.run_history.available_cpus", return_value=8)
        cpus.start()
        self.addCleanup(cpus.stop)

    def refresh_invocation(self) -> None:
        self.sarif["runs"][0]["invocations"][0]["commandLine"] = " ".join(self.command)
        (self.reports / "gnatprove.sarif").write_text(json.dumps(self.sarif))
        self.manifest["reports_sha256"] = report_hashes(self.reports)

    def audit(self) -> None:
        validate_provenance(self.host, self.reports, self.manifest)

    def test_unchanged_content_is_accepted(self) -> None:
        self.audit()

    def test_symlinked_selected_tool_root_is_accepted(self) -> None:
        physical = self.root / "shared native tools"
        self.host.tools.rename(physical)
        self.host.tools.symlink_to(physical, target_is_directory=True)
        for identity in self.manifest["tools"].values():
            identity["path"] = str(physical / "test-tool")
        self.audit()

    def test_tool_links_cannot_escape_selected_tool_root(self) -> None:
        outside = self.root / "other-tool"
        outside.write_bytes((self.host.tools / "test-tool").read_bytes())
        alias = self.host.tools / "outside-link"
        alias.symlink_to(outside)
        for path in (outside, alias):
            with self.subTest(path=path):
                self.manifest["tools"]["gnatprove"]["path"] = str(path)
                with self.assertRaisesRegex(EvidenceError, "outside the selected native"):
                    self.audit()

    def test_relative_report_paths_accept_warm_and_cold_evidence(self) -> None:
        for cold in (False, True):
            with self.subTest(cold=cold):
                reports = self.host.compiler / "obj/cold-fixture/gnatprove" if cold else self.reports
                reports.mkdir(parents=True, exist_ok=True)
                command = self.command[:]
                if cold:
                    cache = proof_provenance.selected_proof_cache(self.host, reports, cold=True)
                    command[command.index("-j") + 2] = f"--memcached-server=file:{cache}"
                    command.insert(-1, "--subdirs=cold-fixture")
                (reports / "main.spark").write_text("{}\n")
                (reports / "gnatprove.out").write_text("fixture\n")
                sarif = {"runs": [{"invocations": [{"commandLine": " ".join(command)}]}]}
                (reports / "gnatprove.sarif").write_text(json.dumps(sarif))
                manifest = dict(self.manifest, mode="cold" if cold else "full", command=command,
                                reports_sha256=report_hashes(reports))
                (reports / MANIFEST).write_text(json.dumps(manifest))
                absolute = validate_provenance(self.host, reports)
                with contextlib.chdir(self.root):
                    relative = validate_provenance(self.host, reports.relative_to(self.root))
                self.assertEqual(relative, absolute)

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
                         "--limit-line=main.adb:1", "-u", "--steps=1", "--replay", "main.adb",
                         "--memcached-server=unreviewed:11211"):
            with self.subTest(argument=argument), self.assertRaises(RuntimeError):
                proof_arguments([argument])
        parsed = proof_arguments(["--subdirs", "fresh", "-f"])
        self.assertEqual(parsed.arguments, ["--subdirs", "fresh"])
        self.assertTrue(parsed.full)

    def test_scheduling_can_change_without_weakening_full_evidence(self) -> None:
        for jobs in ("0", "1", "12"):
            with self.subTest(jobs=jobs):
                self.command[self.command.index("-j") + 1] = jobs
                self.refresh_invocation()
                self.audit()
        for jobs in ("-1", "all", "", "1.5", "\u0662"):
            with self.subTest(jobs=jobs):
                self.command[self.command.index("-j") + 1] = jobs
                self.refresh_invocation()
                with self.assertRaisesRegex(EvidenceError, "worker count"):
                    self.audit()

    def test_full_evidence_requires_forcing_and_native_cache(self) -> None:
        original = self.command[:]
        for mutation in ("incremental", "foreign cache", "extra semantic option"):
            with self.subTest(mutation=mutation):
                self.command[:] = original
                if mutation == "incremental":
                    self.command.remove("-f")
                elif mutation == "foreign cache":
                    self.command[self.command.index("-j") + 2] = "--memcached-server=file:/tmp/shared"
                else:
                    self.command.insert(-1, "--checks-as-errors=off")
                self.refresh_invocation()
                with self.assertRaises(EvidenceError):
                    self.audit()

    def test_native_cache_is_stable_across_source_edits_and_changes_with_toolchain(self) -> None:
        initial = proof_cache(self.host)
        self.assertTrue(initial.is_relative_to(self.host.artifacts))
        (self.root / "src/main.adb").write_text("changed source")
        self.assertEqual(proof_cache(self.host), initial)
        (self.host.context / "alire/alire.lock").write_text("new native toolchain release")
        self.assertNotEqual(proof_cache(self.host), initial)
        foreign = HostLayout(self.root, "macos-aarch64")
        lock = foreign.context / "alire/alire.lock"
        lock.parent.mkdir(parents=True)
        lock.write_bytes((self.host.context / "alire/alire.lock").read_bytes())
        self.assertNotEqual(proof_cache(foreign), proof_cache(self.host))

    def test_full_run_regenerates_reports_but_preserves_native_sessions(self) -> None:
        (self.reports / MANIFEST).write_text("old complete evidence")
        session = self.reports / "main__subprogram/why3session.xml"
        session.parent.mkdir()
        session.write_text("native proof session")
        cache = proof_cache(self.host)
        cache.mkdir(parents=True)
        (cache / "result").write_text("cached solver answer")
        with mock.patch.object(proof_provenance, "tool_identities", return_value=self.manifest["tools"]):
            snapshot = proof_provenance.begin_proof(self.host, self.command, self.reports)
        self.assertFalse((self.reports / MANIFEST).exists())
        self.assertFalse((self.reports / "main.spark").exists())
        self.assertFalse((self.reports / "gnatprove.sarif").exists())
        self.assertFalse((self.reports / "gnatprove.out").exists())
        self.assertEqual(session.read_text(), "native proof session")
        self.assertEqual(snapshot["mode"], "full")
        self.assertEqual(snapshot["initial_state"], {"sessions_present": True, "cache_entries_present": True})

    def test_failed_tool_preflight_preserves_successful_reports(self) -> None:
        (self.reports / MANIFEST).write_text("old completed evidence")
        before = {path: path.read_bytes() for path in self.reports.iterdir()}
        outside = self.root / "unselected-tool"
        outside.write_bytes((self.host.tools / "test-tool").read_bytes())
        self.manifest["tools"]["gnatprove"]["path"] = str(outside)
        with self.assertRaisesRegex(EvidenceError, "outside the selected native"):
            proof_provenance.begin_proof(self.host, self.command, self.reports)
        self.assertEqual(before, {path: path.read_bytes() for path in self.reports.iterdir()})

    def test_cold_options_require_their_own_output_directory(self) -> None:
        for arguments in (["--cold"], ["--cold", "--jobs", "2"], ["-j2", "--cold"]):
            run = proof_arguments(arguments)
            self.assertTrue(run.cold)
            self.assertTrue(run.full)
        for arguments in (["--cold", "--subdirs=fresh"], ["--subdirs", "fresh", "--cold"],
                          ["--subdirs=explore"], ["--subdirs=explore/trial"], ["--subdirs=cold-old"]):
            with self.subTest(arguments=arguments), self.assertRaises(RuntimeError):
                proof_arguments(arguments)

    def test_cold_runs_are_unique_and_preserve_warm_and_other_host_state(self) -> None:
        self.host.alr.parent.mkdir(parents=True, exist_ok=True)
        self.host.alr.write_text("fixture Alire")
        (self.reports / MANIFEST).write_text("warm audit")
        session = self.reports / "main__subprogram/why3session.xml"
        session.parent.mkdir()
        session.write_text("warm session")
        warm_cache = proof_cache(self.host)
        warm_cache.mkdir(parents=True)
        (warm_cache / "result").write_text("warm cached answer")
        foreign = HostLayout(self.root, "macos-aarch64").compiler / "obj/gnatprove/retained"
        foreign.parent.mkdir(parents=True)
        foreign.write_text("other host")
        before = {path: path.read_bytes() for path in self.root.rglob("*") if path.is_file()}
        commands = []

        def invoke(host, command, **kwargs):
            if "gnatprove" not in command:
                return
            command = command[command.index("gnatprove"):]
            commands.append(command)
            selected = dev.project_reports(host, [arg for arg in command if arg.startswith("--subdirs=")])
            (selected / "main.spark").write_text("{}\n")
            (selected / "gnatprove.out").write_text("fresh run\n")
            sarif = {"runs": [{"invocations": [{"commandLine": " ".join(command)}]}]}
            (selected / "gnatprove.sarif").write_text(json.dumps(sarif))

        with mock.patch.object(dev, "native_layout", return_value=self.host), \
                mock.patch.object(dev, "invoke", side_effect=invoke), \
                mock.patch.object(dev, "audit_sources"), \
                mock.patch.object(proof_provenance, "tool_identities", return_value=self.manifest["tools"]):
            dev.main(["prove", "--cold", "--jobs", "2"])
            dev.main(["prove", "--", "--cold"])
        self.assertEqual(len(commands), 2)
        workspaces = list((self.host.compiler / "obj").glob("cold-*"))
        self.assertEqual(len(workspaces), 2)
        for workspace in workspaces:
            self.assertTrue((workspace / "cache").is_dir())
            manifest = json.loads((workspace / "gnatprove" / MANIFEST).read_text())
            self.assertEqual(manifest["mode"], "cold")
            self.assertEqual(manifest["initial_state"], {"sessions_present": False, "cache_entries_present": False})
            self.assertIn(f"--memcached-server=file:{workspace / 'cache'}", manifest["command"])
            validate_provenance(self.host, workspace / "gnatprove")
            manifest["initial_state"]["sessions_present"] = True
            with self.assertRaisesRegex(EvidenceError, "did not start"):
                validate_provenance(self.host, workspace / "gnatprove", manifest)
        for path, data in before.items():
            self.assertEqual(path.read_bytes(), data)

    def test_failed_cold_run_cannot_create_success_or_damage_warm_evidence(self) -> None:
        self.host.alr.parent.mkdir(parents=True, exist_ok=True)
        self.host.alr.write_text("fixture Alire")
        (self.reports / MANIFEST).write_text("warm audit")
        with mock.patch.object(dev, "native_layout", return_value=self.host), \
                mock.patch.object(dev, "invoke", side_effect=subprocess.CalledProcessError(1, "gnatprove")), \
                mock.patch.object(proof_provenance, "tool_identities", return_value=self.manifest["tools"]):
            with self.assertRaises(subprocess.CalledProcessError):
                dev.main(["prove", "--cold"])
        workspaces = list((self.host.compiler / "obj").glob("cold-*"))
        self.assertEqual(len(workspaces), 1)
        self.assertTrue((workspaces[0] / "gnatprove/proof-inputs.json").is_file())
        self.assertFalse((workspaces[0] / "gnatprove" / MANIFEST).exists())
        self.assertEqual((self.reports / MANIFEST).read_text(), "warm audit")

    def test_validation_mode_and_initial_state_cannot_be_omitted(self) -> None:
        for field in ("mode", "initial_state"):
            manifest = self.manifest.copy()
            del manifest[field]
            with self.subTest(field=field), self.assertRaises(EvidenceError):
                validate_provenance(self.host, self.reports, manifest)
        self.manifest["mode"] = "cold"
        with self.assertRaisesRegex(EvidenceError, "isolated native"):
            self.audit()

    def test_direct_exploratory_gnatprove_requires_separate_outputs_and_cache(self) -> None:
        for command in (["gnatprove", "--help"], ["gnatprove", "--version"],
                        ["/tools/gnatprove", "-h"], ["gnatls", "--version"],
                        ["gnatprove", "--subdirs=explore"],
                        ["gnatprove", "--subdirs", "explore/trial", "--memcached-server=file:explore-cache"]):
            dev.exploratory_tool(self.host, command)
        managed = proof_cache(self.host)
        cold_cache = self.host.compiler / "obj/cold-example/cache"
        for arguments in ([], ["--subdirs=warm"], ["--subdirs=explore/../warm"],
                          ["--subdirs=/explore"], ["--subdirs=explore", "--subdirs=warm"],
                          ["--subdirs=explore", f"--memcached-server=file:{managed}"],
                          ["--subdirs=explore", "--memcached-server", f"file:{cold_cache}"]):
            with self.subTest(arguments=arguments), self.assertRaises(RuntimeError):
                dev.exploratory_tool(self.host, ["gnatprove", *arguments])
        self.host.alr.parent.mkdir(parents=True, exist_ok=True)
        self.host.alr.write_text("fixture Alire")
        with mock.patch.object(dev, "native_layout", return_value=self.host), mock.patch.object(dev, "invoke") as run:
            with self.assertRaisesRegex(RuntimeError, "exploratory GNATprove"):
                dev.main(["tool", "--", "gnatprove", "--level=4"])
            run.assert_not_called()

    def test_incremental_run_preserves_reports_and_invalidates_only_its_full_evidence(self) -> None:
        self.host.alr.parent.mkdir(parents=True, exist_ok=True)
        self.host.alr.write_text("fixture Alire")
        (self.reports / MANIFEST).write_text("old complete evidence")
        foreign = self.host.compiler / "obj/other/gnatprove" / MANIFEST
        foreign.parent.mkdir(parents=True)
        foreign.write_text("other run")
        before = report_hashes(self.reports)
        with mock.patch.object(dev, "native_layout", return_value=self.host), \
                mock.patch.object(dev, "invoke") as run, \
                mock.patch.object(dev, "begin_proof") as begin, \
                mock.patch.object(dev, "audit_sources") as audit, \
                mock.patch.object(dev, "complete_proof") as complete:
            dev.main(["prove"])
        command = run.call_args.args[1]
        self.assertNotIn("-f", command)
        self.assertEqual(command[command.index("-j") + 1], "8")
        self.assertIn(f"--memcached-server=file:{proof_cache(self.host)}", command)
        self.assertIn("--mode=all", command)
        self.assertIn("--checks-as-errors=on", command)
        begin.assert_not_called()
        audit.assert_not_called()
        complete.assert_not_called()
        self.assertEqual(report_hashes(self.reports), before)
        self.assertFalse((self.reports / MANIFEST).exists())
        self.assertEqual(foreign.read_text(), "other run")

    def test_failed_incremental_run_cannot_keep_old_full_success(self) -> None:
        self.host.alr.parent.mkdir(parents=True, exist_ok=True)
        self.host.alr.write_text("fixture Alire")
        (self.reports / MANIFEST).write_text("old complete evidence")
        with mock.patch.object(dev, "native_layout", return_value=self.host), \
                mock.patch.object(dev, "invoke", side_effect=subprocess.CalledProcessError(1, "gnatprove")):
            with self.assertRaises(subprocess.CalledProcessError):
                dev.main(["prove"])
        self.assertFalse((self.reports / MANIFEST).exists())

    def test_full_mode_routes_through_complete_audit_with_worker_override(self) -> None:
        self.host.alr.parent.mkdir(parents=True, exist_ok=True)
        self.host.alr.write_text("fixture Alire")
        for arguments in (["prove", "--full", "--jobs", "3"],
                          ["prove", "--", "-f", "-j3"],
                          ["prove", "-f", "-j", "3"]):
            with self.subTest(arguments=arguments), \
                    mock.patch.object(dev, "native_layout", return_value=self.host), \
                    mock.patch.object(dev, "invoke") as run, \
                    mock.patch.object(dev, "begin_proof") as begin, \
                    mock.patch.object(dev, "audit_sources") as audit, \
                    mock.patch.object(dev, "complete_proof") as complete:
                dev.main([arguments[0], "--reason", "Check equivalent CLI spellings", *arguments[1:]])
                command = run.call_args_list[0].args[1]
                self.assertIn("-f", command)
                self.assertEqual(command[command.index("-j") + 1], "3")
                begin.assert_called_once()
                audit.assert_called_once_with(self.root / "src", self.reports, self.host.generated,
                                              effective_command=command[command.index("--") + 1:])
                complete.assert_called_once_with(self.host, self.reports, begin.return_value,
                                                 pass_fds=run.call_args.kwargs["pass_fds"])
                self.assertEqual(run.call_count, 2)

    def test_invalid_worker_counts_fail_before_proof(self) -> None:
        for value in ("-1", "", "all", "1.5"):
            with self.subTest(value=value), self.assertRaises(ValueError):
                proof_arguments(["--jobs", value])

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

    def test_changed_proof_container_project_is_rejected(self) -> None:
        path = self.root / "proof/silver_proof_containers.gpr"
        path.write_text(path.read_text().replace('/include/spark', '/other_sources'))
        self.manifest["inputs_sha256"] = input_hashes(self.host)
        with self.assertRaisesRegex(EvidenceError, "project differs"):
            self.audit()


if __name__ == "__main__":
    unittest.main()
