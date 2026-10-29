"""Managed development commands preserve proof evidence and durable run outcomes."""
from __future__ import annotations

import contextlib
import hashlib
import io
import json
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

from scripts import dev, proof_provenance, run_history
from scripts.check_evidence import EvidenceError
from scripts.platforms import HostLayout, host_key


ROOT = Path(__file__).resolve().parents[1]


class DevRunTests(unittest.TestCase):
    def setUp(self):
        directory = tempfile.TemporaryDirectory(prefix="silver dev runs ' ")
        self.addCleanup(directory.cleanup)
        self.root = Path(directory.name).resolve()
        self.host = HostLayout(self.root, host_key())
        for path in (self.root / "alire.toml", self.host.context / "alire.toml",
                     self.host.context / "alire/alire.lock", self.host.alr,
                     self.host.generated / "silver_build.ads", self.root / "src/main.adb",
                     self.root / "scripts/check_evidence.py"):
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("fixture\n")
        for relative in ("silver.gpr", "proof/silver_proof_containers.gpr"):
            path = self.root / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes((ROOT / relative).read_bytes())
        tool = self.host.tools / "fixture-tool"
        tool.write_bytes(b"fixture executable")
        version = "fixture 1.0"
        self.tools = {name: {"path": str(tool), "sha256": proof_provenance.digest(tool),
                            "version": version,
                            "version_sha256": hashlib.sha256(version.encode()).hexdigest()}
                      for name in ("gnatprove", "gnatls", "gcc", "gprbuild", "cvc5", "z3",
                                   "alt-ergo", "gnat2why", "gnatwhy3", "why3server", "python", "alr")}
        for patch in (mock.patch.object(dev, "native_layout", return_value=self.host),
                      mock.patch.object(dev, "alire_command", side_effect=self.fixture_alire),
                      mock.patch.object(run_history, "available_cpus", return_value=4),
                      mock.patch.object(proof_provenance, "tool_identities", return_value=self.tools),
                      mock.patch.object(dev, "tool_identities", return_value=self.tools)):
            patch.start()
            self.addCleanup(patch.stop)
        self.reports = self.host.compiler / "obj/gnatprove"

    def fixture_alire(self, host, *command):
        # Execute only short Python resolver probes for real; proof commands use
        # simulated_proof/invoke mocks and never select an installed toolchain.
        self.assertEqual(command[:2], ("exec", "--"))
        return list(command[2:])

    def main(self, arguments):
        output = io.StringIO()
        with contextlib.redirect_stdout(output):
            dev.main(arguments)
        return output.getvalue()

    def records(self, task=""):
        return run_history.status(self.host, task)["runs"]

    def write_proof_reports(self, host, command, **options):
        """Supply tool output; real preflight, manifests and run policies still execute."""
        if "gnatprove" not in command:
            return
        proof_command = command[command.index("gnatprove"):]
        reports = dev.project_reports(host, [argument for argument in proof_command
                                            if argument.startswith("--subdirs=")])
        reports.mkdir(parents=True, exist_ok=True)
        (reports / "main.spark").write_text("{}\n")
        (reports / "gnatprove.out").write_text("fixture proof completed\n")
        (reports / "gnatprove.sarif").write_text(json.dumps({"runs": [{"invocations": [
            {"commandLine": " ".join(proof_command)}]}]}))

    @contextlib.contextmanager
    def simulated_proof(self):
        with mock.patch.object(dev, "invoke", side_effect=self.write_proof_reports) as invoke, \
                mock.patch.object(dev, "audit_sources"):
            yield invoke

    def test_build_uses_attached_native_worker_flag(self) -> None:
        with mock.patch.object(dev, "invoke") as invoke:
            dev.main(["build", "--task", "#39", "--jobs", "2"])
        command = invoke.call_args.args[1]
        self.assertIn("-j2", command)
        self.assertNotIn("-j", command)

    def rosetta_test_inputs(self):
        paths = [self.root / "rosetta" / name
                 for name in ("refresh.py", "manifest.json", "coverage.json")]
        for path in paths:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_text("fixture Rosetta input\n")
        return paths

    def test_test_command_captures_only_rosetta_test_dependencies(self):
        paths = self.rosetta_test_inputs()
        (self.root / "rosetta/unrelated-downloaded-page.html").write_text("not a test input\n")
        with mock.patch.object(dev, "invoke"):
            self.main(["test", "--jobs", "2", "--", "-p", "test_rosetta.py"])
        record, = self.records()
        self.assertEqual(record["state"], "success")
        captured = record["inputs"]["inputs_sha256"]
        self.assertEqual({name: value for name, value in captured.items()
                          if Path(name).is_relative_to(self.root / "rosetta")},
                         {str(path): proof_provenance.digest(path) for path in paths})

    def test_rosetta_test_dependency_drift_cannot_finish_successfully(self):
        for path in self.rosetta_test_inputs():
            with self.subTest(path=path.name):
                original = proof_provenance.digest(path)
                with mock.patch.object(dev, "invoke", side_effect=lambda *args, **kwargs:
                                       path.write_text("changed during execution\n")) as invoke:
                    with self.assertRaisesRegex(RuntimeError, "declared run inputs changed"):
                        self.main(["test", "--jobs", "2", "--", "-p", "test_rosetta.py"])
                self.assertEqual(invoke.call_count, 1)
                record = self.records()[-1]
                self.assertEqual(record["state"], "failure")
                self.assertEqual(record["inputs"]["inputs_sha256"][str(path)], original)

    def test_full_success_requires_reason_before_replacing_evidence(self):
        arguments = ["prove", "--full", "--jobs", "2", "--task", "#39"]
        with self.simulated_proof() as invoke:
            self.main(arguments)
            original = {path: path.read_bytes() for path in self.reports.iterdir()}
            self.assertEqual(invoke.call_count, 2)
            with self.assertRaisesRegex(run_history.RunHistoryError, "--reason"):
                self.main(arguments)
            self.assertEqual(invoke.call_count, 2)
            self.assertEqual(original, {path: path.read_bytes() for path in self.reports.iterdir()})
            self.main([*arguments, "--reason", "Investigate the retained report discrepancy"])
            self.assertEqual(invoke.call_count, 4)
        records = self.records("#39")
        self.assertEqual([run["state"] for run in records], ["success", "failure", "success"])
        self.assertEqual(records[-1]["reason"], "Investigate the retained report discrepancy")
        self.assertEqual(records[0]["fingerprint"], records[-1]["fingerprint"])

    def test_cold_random_workspace_does_not_evade_success_guard(self):
        arguments = ["prove", "--cold", "--jobs", "2", "--task", "#39"]
        with self.simulated_proof() as invoke:
            self.main(arguments)
            first = next((self.host.compiler / "obj").glob("cold-*"))
            original = (first / "gnatprove" / proof_provenance.MANIFEST).read_bytes()
            with self.assertRaisesRegex(run_history.RunHistoryError, "--reason"):
                self.main(arguments)
            self.assertEqual(invoke.call_count, 2)
            self.assertEqual(list((self.host.compiler / "obj").glob("cold-*")), [first])
            self.main([*arguments, "--reason", "Measure a second independent cold workspace"])
            self.assertEqual(invoke.call_count, 4)
        records = self.records("#39")
        self.assertEqual([run["state"] for run in records], ["success", "failure", "success"])
        self.assertEqual(len({run["fingerprint"] for run in records}), 1)
        outputs = [{resource["resolved"] for resource in run["resources"]
                    if "cold-" in resource["resolved"]} for run in records]
        self.assertTrue(all(outputs))
        self.assertTrue(outputs[0].isdisjoint(outputs[1]))
        self.assertTrue(outputs[0].isdisjoint(outputs[2]))
        self.assertEqual(len(list((self.host.compiler / "obj").glob("cold-*"))), 2)
        self.assertEqual((first / "gnatprove" / proof_provenance.MANIFEST).read_bytes(), original)

    def test_changed_source_permits_new_full_check_without_reason(self):
        arguments = ["prove", "--full", "--jobs", "2", "--task", "#39"]
        with self.simulated_proof() as invoke:
            self.main(arguments)
            (self.root / "src/main.adb").write_text("changed source bytes\n")
            self.main(arguments)
            self.assertEqual(invoke.call_count, 4)
        first, second = self.records()
        self.assertEqual([first["state"], second["state"]], ["success", "success"])
        self.assertNotEqual(first["fingerprint"], second["fingerprint"])

    def test_full_evidence_survives_a_later_incremental_report_replacement(self):
        with self.simulated_proof():
            self.main(["prove", "--full", "--jobs", "2"])
        first, = self.records()
        retained = Path(first["directory"]) / "proof-evidence"
        previous = {path.name: path.read_bytes() for path in self.reports.iterdir()}
        self.assertEqual(previous, {path.name: path.read_bytes() for path in retained.iterdir()})

        def replace_reports(host, command, **options):
            self.write_proof_reports(host, command, **options)
            (self.reports / "gnatprove.out").write_text("later incremental output\n")

        with mock.patch.object(dev, "invoke", side_effect=replace_reports):
            self.main(["prove", "--jobs", "2"])
        second = self.records()[-1]
        copied = Path(second["directory"]) / "previous-reports"
        self.assertEqual(previous, {path.name: path.read_bytes() for path in copied.iterdir()})
        self.assertEqual(previous, {path.name: path.read_bytes() for path in retained.iterdir()})
        self.assertFalse((self.reports / proof_provenance.MANIFEST).exists())
        self.assertEqual((self.reports / "gnatprove.out").read_text(), "later incremental output\n")

    def test_invalid_preflight_launches_no_proof_and_preserves_prior_reports(self):
        with self.simulated_proof() as invoke:
            self.main(["prove", "--full", "--jobs", "2"])
            before = {path: path.read_bytes() for path in self.reports.iterdir()}
            project = self.root / "silver.gpr"
            original = project.read_text()
            outside = self.root / "unselected-tool"
            outside.write_bytes(Path(self.tools["gnatprove"]["path"]).read_bytes())
            for cause in ("project", "tool"):
                with self.subTest(cause=cause):
                    if cause == "project":
                        project.write_text(original.replace('"src"', '"unreviewed-src"'))
                    else:
                        self.tools["gnatprove"]["path"] = str(outside)
                    with self.assertRaises(EvidenceError):
                        self.main(["prove", "--full", "--jobs", "2", "--reason", "Check preflight rejection"])
                    self.assertEqual(invoke.call_count, 2)
                    self.assertEqual(before, {path: path.read_bytes() for path in self.reports.iterdir()})
                    failed = self.records()[-1]
                    self.assertEqual(failed["state"], "failure")
                    phases = [event.get("phase") for event in failed["events"]
                              if event["event"] == "phase-start"]
                    self.assertEqual(phases, ["preflight"])
                    project.write_text(original)

    def test_missing_toolchain_lock_is_a_recorded_preflight_failure(self):
        (self.host.context / "alire/alire.lock").unlink()
        with mock.patch.object(dev, "invoke") as invoke:
            with self.assertRaisesRegex(EvidenceError, "missing proof input"):
                self.main(["prove", "--full", "--task", "#39"])
            invoke.assert_not_called()
        record, = self.records("#39")
        self.assertEqual(record["state"], "failure")
        self.assertIn("alire.lock", record["finish"]["error"])

    def custom_arguments(self):
        self.custom = self.root / "custom inputs"
        self.custom.mkdir(exist_ok=True)
        self.custom_source = self.custom / "main.adb"
        self.custom_source.write_text("custom source\n")
        self.custom_project = self.root / "custom.gpr"
        self.custom_project.write_text("custom project\n")
        self.custom_tool = self.host.tools / "gnatprove"
        self.custom_tool.write_text("#!/bin/sh\nexit 99\n")
        self.custom_tool.chmod(0o755)
        self.workspace = self.root / "custom output"
        self.other_workspace = self.root / "custom cache"
        return ["tool", "--task", "#39", "--jobs", "2",
                "--workspace", str(self.workspace), "--workspace", str(self.other_workspace),
                "--input", str(self.custom), "--input", str(self.custom_project), "--",
                str(self.custom_tool), "-P", str(self.custom_project), "--subdirs=explore/trial"]

    def test_custom_cli_records_declared_inputs_and_actual_workspaces(self):
        arguments = self.custom_arguments()
        with mock.patch.object(dev, "invoke") as invoke:
            self.main(arguments)
        record, = self.records("#39")
        self.assertEqual(record["state"], "success")
        resources = {resource["resolved"] for resource in record["resources"]}
        self.assertTrue({str(self.workspace), str(self.other_workspace)} <= resources)
        self.assertEqual(record["inputs"]["inputs_sha256"][str(self.custom_source)],
                         proof_provenance.digest(self.custom_source))
        self.assertIn(str(self.custom_project), record["inputs"]["inputs_sha256"])
        self.assertEqual(record["inputs"]["executable"],
                         {"path": str(self.custom_tool), "sha256": proof_provenance.digest(self.custom_tool)})
        command = invoke.call_args.args[1]
        self.assertEqual(command[-1:], ["-j2"])
        self.assertTrue(invoke.call_args.kwargs["pass_fds"])

    def test_custom_cli_requires_both_input_and_workspace_declarations(self):
        arguments = self.custom_arguments()
        command = arguments[arguments.index("--"):]
        for declarations in ([], ["--workspace", str(self.workspace)],
                             ["--input", str(self.custom)]):
            with self.subTest(declarations=declarations), mock.patch.object(dev, "invoke") as invoke:
                with self.assertRaisesRegex(RuntimeError, "--workspace and --input"):
                    self.main(["tool", *declarations, *command])
                invoke.assert_not_called()
        self.assertEqual(self.records(), [])

    def test_custom_declared_source_drift_cannot_finish_successfully(self):
        arguments = self.custom_arguments()
        original = proof_provenance.digest(self.custom_source)
        with mock.patch.object(dev, "invoke", side_effect=lambda *args, **kwargs:
                               self.custom_source.write_text("changed during execution\n")) as invoke:
            with self.assertRaisesRegex(RuntimeError, "declared run inputs changed"):
                self.main(arguments)
        self.assertEqual(invoke.call_count, 1)
        record, = self.records()
        self.assertEqual(record["state"], "failure")
        self.assertEqual(record["inputs"]["inputs_sha256"][str(self.custom_source)], original)

    def assert_input_retarget_rejected(self, arguments, selector, replacement):
        original_inputs = dev.hash_paths([selector])
        self.assertEqual(sorted(original_inputs.values()),
                         sorted(dev.hash_paths([replacement]).values()))

        def retarget(*args, **kwargs):
            selector.unlink()
            selector.symlink_to(replacement, target_is_directory=replacement.is_dir())

        with mock.patch.object(dev, "invoke", side_effect=retarget) as invoke:
            with self.assertRaisesRegex(RuntimeError, "declared run inputs changed"):
                self.main(arguments)
        self.assertEqual(invoke.call_count, 1)
        record, = self.records()
        self.assertEqual(record["state"], "failure")
        self.assertTrue(original_inputs.items() <= record["inputs"]["inputs_sha256"].items())

    def test_custom_input_file_symlink_retarget_is_drift_even_with_identical_bytes(self):
        arguments = self.custom_arguments()
        original = self.root / "original.gpr"
        self.custom_project.rename(original)
        replacement = self.root / "replacement.gpr"
        replacement.write_bytes(original.read_bytes())
        self.custom_project.symlink_to(original)
        self.assert_input_retarget_rejected(arguments, self.custom_project, replacement)

    def test_custom_input_directory_symlink_retarget_is_drift_even_with_identical_bytes(self):
        arguments = self.custom_arguments()
        original = self.root / "original inputs"
        self.custom.rename(original)
        replacement = self.root / "replacement inputs"
        replacement.mkdir()
        (replacement / "main.adb").write_bytes((original / "main.adb").read_bytes())
        self.custom.symlink_to(original, target_is_directory=True)
        self.assert_input_retarget_rejected(arguments, self.custom, replacement)

    def test_custom_executable_symlink_retarget_is_drift_even_with_identical_bytes(self):
        arguments = self.custom_arguments()
        original = self.host.tools / "original-tool"
        self.custom_tool.rename(original)
        replacement = self.host.tools / "replacement-tool"
        replacement.write_bytes(original.read_bytes())
        replacement.chmod(0o755)
        self.custom_tool.symlink_to(original)

        def retarget(*args, **kwargs):
            self.custom_tool.unlink()
            self.custom_tool.symlink_to(replacement)

        with mock.patch.object(dev, "invoke", side_effect=retarget) as invoke:
            with self.assertRaisesRegex(RuntimeError, "custom tool executable changed"):
                self.main(arguments)
        self.assertEqual(invoke.call_count, 1)
        record, = self.records()
        self.assertEqual(record["state"], "failure")
        self.assertEqual(record["inputs"]["executable"],
                         {"path": str(original), "sha256": proof_provenance.digest(replacement)})

    def test_new_file_in_declared_directory_is_input_drift(self):
        arguments = self.custom_arguments()
        added = self.custom / "new.ads"
        with mock.patch.object(dev, "invoke", side_effect=lambda *args, **kwargs:
                               added.write_text("new dependency\n")):
            with self.assertRaisesRegex(RuntimeError, "declared run inputs changed"):
                self.main(arguments)
        self.assertEqual(self.records()[0]["state"], "failure")

    def test_exploratory_zero_exit_with_unproved_obligation_is_failure(self):
        arguments = self.custom_arguments()
        report = self.workspace / "obj/explore/gnatprove/main.spark"

        def unproved_report(*args, **kwargs):
            report.parent.mkdir(parents=True)
            report.write_text(json.dumps({"proof": [{"file": "main.adb", "line": 8, "col": 4,
                "rule": "VC_RANGE_CHECK", "severity": "warning", "how_proved": False}]}))

        with mock.patch.object(dev, "invoke", side_effect=unproved_report) as invoke:
            with self.assertRaisesRegex(RuntimeError, "unproved|unresolved|obligation"):
                self.main(arguments)
        self.assertEqual(invoke.call_count, 1)
        record, = self.records()
        self.assertEqual(record["state"], "failure")
        self.assertEqual(record["finish"]["returncode"], 0)
        self.assertEqual(record["finish"]["failure_keys"], ["main.adb:8:4:VC_RANGE_CHECK"])
        retained = Path(record["finish"]["retained_reports"][0]["retained"])
        self.assertEqual(retained.read_bytes(), report.read_bytes())

    def test_custom_executable_drift_cannot_finish_successfully(self):
        arguments = self.custom_arguments()
        with mock.patch.object(dev, "invoke", side_effect=lambda *args, **kwargs:
                               self.custom_tool.write_text("#!/bin/sh\nexit 98\n")):
            with self.assertRaisesRegex(RuntimeError, "custom tool executable changed"):
                self.main(arguments)
        self.assertEqual(self.records()[0]["state"], "failure")

    def test_extra_declared_input_is_checked_for_standard_exploratory_project(self):
        extra = self.root / "extra-input.txt"
        extra.write_text("original input\n")
        arguments = ["tool", "--task", "#39", "--input", str(extra), "--", "gnatprove",
                     "-P", "../../../silver.gpr", "--subdirs=explore/trial", f"-XSILVER_HOST={self.host.key}"]
        with mock.patch.object(dev, "invoke", side_effect=lambda *args, **kwargs:
                               extra.write_text("changed during execution\n")):
            with self.assertRaisesRegex(RuntimeError, "declared run inputs changed"):
                self.main(arguments)
        self.assertEqual(self.records()[0]["state"], "failure")

    def test_standard_exploratory_paths_include_outputs_and_external_cache(self):
        cache = self.root / "separate solver cache"
        command = ["gnatprove", "-P", "../../../silver.gpr", "--subdirs=explore/trial",
                   f"--memcached-server=file:{cache}", f"-XSILVER_HOST={self.host.key}"]
        resources, reports, standard = dev.tool_resources(self.host, command, [], [])
        self.assertTrue(standard)
        self.assertEqual(reports, self.host.compiler / "obj/explore/trial/gnatprove")
        self.assertTrue({cache, reports.parent, self.host.compiler / "bin/explore/trial",
                         self.host.artifacts / "proof-containers/obj/explore/trial"} <= set(resources))

    def test_redirects_and_explicit_executable_require_custom_declarations(self):
        command = ["gnatprove", "-P", "../../../silver.gpr", "--subdirs=explore/trial",
                   f"-XSILVER_HOST={self.host.key}"]
        variants = [[*command, *extra] for extra in (["-o", "elsewhere"], ["-cargs", "-gnatp"],
                    ["-XOTHER_OUTPUT=elsewhere"], ["--relocate-build-tree=elsewhere"])]
        variants.append([str(self.root / "custom/gnatprove"), *command[1:]])
        for arguments in variants:
            with self.subTest(arguments=arguments):
                with self.assertRaisesRegex(RuntimeError, "--workspace and --input"):
                    dev.tool_resources(self.host, arguments, [], [])
                _, reports, standard = dev.tool_resources(self.host, arguments,
                    [str(self.root / "explicit-output")], [str(self.root / "silver.gpr")])
                self.assertFalse(standard)
                self.assertIsNone(reports)

    def test_equivalent_selectors_share_diagnostic_scope_and_distinct_targets_do_not(self):
        split = ["gnatprove", "-P", "probe.gpr", "--mode", "prove", "--limit-line", "main.adb:9"]
        joined = ["gnatprove", "-Pprobe.gpr", "--mode=prove", "--limit-line=main.adb:9"]
        long = ["gnatprove", "--project=probe.gpr", "--mode=prove", "--limit-line=main.adb:9"]
        self.assertEqual(dev.proof_scope(split), dev.proof_scope(joined))
        self.assertEqual(dev.proof_scope(split), dev.proof_scope(long))
        self.assertNotEqual(dev.proof_scope(joined), dev.proof_scope([*joined[:-1], "--limit-line=main.adb:10"]))
        self.assertNotEqual(dev.proof_scope(joined), dev.proof_scope([*joined, "--mode=flow"]))

    def test_status_and_checkpoint_preserve_task_scope_and_no_proof_launch(self):
        with self.simulated_proof():
            self.main(["prove", "--full", "--jobs", "2", "--task", "#39"])
        with mock.patch.object(dev, "invoke") as invoke:
            note = json.loads(self.main(["runs", "checkpoint", "--task", "#39",
                "--summary", "Focused runner checks passed", "--next-check", "Review final CLI documentation"]))
            other = json.loads(self.main(["runs", "checkpoint", "--task", "#other",
                "--summary", "Independent task", "--next-check", "Unrelated check"]))
            result = json.loads(self.main(["runs", "status", "--task", "#39"]))
            invoke.assert_not_called()
        self.assertEqual(note["task"], "#39")
        self.assertEqual(other["task"], "#other")
        self.assertEqual(len(result["runs"]), 1)
        self.assertEqual(result["runs"][0]["state"], "success")
        self.assertNotIn("inputs", result["runs"][0])
        self.assertNotIn("events", result["runs"][0])
        self.assertEqual([item["next_check"] for item in result["notes"]], ["Review final CLI documentation"])
        self.assertEqual(result["reserved_workers"], 0)

    def test_status_limit_preserves_all_active_runs(self):
        for index in range(3):
            with run_history.ManagedRun(self.host, "fixture", [sys.executable], {"index": index},
                                        [], workers=0, task="#39"):
                pass
        with run_history.ManagedRun(self.host, "fixture", [sys.executable], {},
                                    [], workers=1, task="#39") as active:
            result = json.loads(self.main(["runs", "status", "--task", "#39", "--limit", "1"]))
            self.assertEqual(result["total_runs"], 4)
            self.assertEqual(result["omitted_completed_runs"], 2)
            self.assertEqual(len(result["runs"]), 2)
            self.assertEqual(result["runs"][-1]["run_id"], active.run_id)
            self.assertEqual(result["runs"][-1]["state"], "active")
            self.assertEqual(result["reserved_workers"], 1)
            all_runs = json.loads(self.main(["runs", "status", "--task", "#39", "--limit", "0"]))
            self.assertEqual(len(all_runs["runs"]), 4)
            self.assertEqual(all_runs["omitted_completed_runs"], 0)

    def test_invoke_retains_failure_stdout_stderr_and_passes_live_lease(self):
        log = self.root / "child.log"
        program = ("import os, sys; os.fstat(int(sys.argv[1])); "
                   "print('fixture stdout', flush=True); "
                   "print('fixture stderr', file=sys.stderr, flush=True); sys.exit(7)")
        with self.assertRaises(subprocess.CalledProcessError) as failure:
            with run_history.ManagedRun(self.host, "fixture", [sys.executable], {},
                                        [self.root / "objects"], workers=1, evidence=[log]) as run:
                with contextlib.redirect_stdout(io.StringIO()):
                    dev.invoke(self.host, [sys.executable, "-c", program, str(run.pass_fds[0])],
                               pass_fds=run.pass_fds, log=log)
        self.assertEqual(failure.exception.returncode, 7)
        self.assertEqual(log.read_text().splitlines(), ["fixture stdout", "fixture stderr"])
        record, = self.records()
        self.assertEqual(record["state"], "failure")
        self.assertEqual(record["finish"]["returncode"], 7)
        self.assertEqual(record["finish"]["evidence"][0]["resolved"], str(log))

    def test_invoke_without_log_also_passes_live_lease(self):
        marker = self.root / "child-fd-valid"
        program = ("import os, pathlib, sys; os.fstat(int(sys.argv[1])); "
                   "pathlib.Path(sys.argv[2]).write_text('inherited')")
        with run_history.ManagedRun(self.host, "fixture", [sys.executable], {},
                                    [self.root / "objects"], workers=1) as run:
            dev.invoke(self.host, [sys.executable, "-c", program, str(run.pass_fds[0]), str(marker)],
                       pass_fds=run.pass_fds)
        self.assertEqual(marker.read_text(), "inherited")
        self.assertEqual(self.records()[0]["state"], "success")


if __name__ == "__main__":
    unittest.main()
