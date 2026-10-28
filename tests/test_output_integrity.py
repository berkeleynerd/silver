"""Real output driver rejects changed library snapshots and absent evidence."""
from __future__ import annotations

import json
import os
import platform
from pathlib import Path
import shutil
import subprocess
import sys
import tempfile
import textwrap
import unittest

from scripts.bootstrap import prepare_context
from scripts.platforms import HostLayout, alire_command, tool_environment
from tests import test_silver
from tests.test_library_reports import (
    report as runtime_report, argument_report,
    assignment_call_report as output_call_report,
    main_report,
)

ROOT = test_silver.ROOT
HOST = test_silver.HOST
LIBRARIES = ("silver_io.ads", "silver_io.adb", "silver_output_libc.ads", "silver_arguments.ads", "silver_arguments.adb", "silver_runtime.ads")
SOURCE = (b'with Silver_IO; procedure Main is pragma SPARK_Mode(On); '
          b'begin Silver_IO.Put_Line("Hello, world!"); end Main;')


class OutputIntegrityTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        # Rebuild the unchanged SPARK implementation with fixture-specific fixed
        # installation paths. Only the fixture's external Alire tool is replaced.
        cls.temporary = tempfile.TemporaryDirectory(prefix="silver output integrity-")
        cls.addClassCleanup(cls.temporary.cleanup)
        cls.sandbox = (Path(cls.temporary.name) / "installation ' with spaces").resolve()
        cls.sandbox.mkdir()
        cls.host = HostLayout(cls.sandbox, HOST.key)
        shutil.copytree(ROOT / "src", cls.sandbox / "src")
        for filename in ("silver.gpr", "alire.toml"):
            shutil.copyfile(ROOT / filename, cls.sandbox / filename)
        (cls.sandbox / "proof").mkdir()
        shutil.copyfile(ROOT / "proof/silver_proof_containers.gpr",
                        cls.sandbox / "proof/silver_proof_containers.gpr")
        prepare_context(cls.host)
        built = subprocess.run(
            alire_command(HOST, "exec", "--", "gprbuild", "-P", cls.sandbox / "silver.gpr",
                          "-XSILVER_HOST=" + HOST.key, "--subdirs=explore/output-integrity", "-p", "-j2", "silver.adb"),
            cwd=HOST.context, env=tool_environment(HOST), capture_output=True, text=True, timeout=120)
        if built.returncode:
            raise AssertionError(built.stdout + built.stderr)
        cls.silver = cls.host.compiler / "bin/explore/output-integrity/silver"
        cls.source = Path(cls.temporary.name) / "author source.adb"
        cls.source.write_bytes(SOURCE)
        cls.originals = {name: (ROOT / "src" / name).read_bytes() for name in LIBRARIES}
        cls.fixtures = cls.sandbox / "reports"
        cls.fixtures.mkdir()
        # Every output shell now uses the application policy, including a
        # literal-only output whose Main checks simplify away. Retain its
        # Main/Put_Line entities and approved effects dependency.
        main = output_call_report()
        for name, data in (("main~1.spark", main), ("silver_io.spark", runtime_report()),
                           ("silver_output_libc.spark", runtime_report(True)),
                           ("silver_arguments.spark", argument_report()),
                           ("silver_runtime.spark", argument_report(True))):
            (cls.fixtures / name).write_text(json.dumps(data))
        alr = cls.host.alr
        alr.parent.mkdir(parents=True, exist_ok=True)
        alr.write_text("#!" + sys.executable + "\n" + textwrap.dedent('''\
            import json
            import os
            from pathlib import Path
            import shutil
            import sys
            root = Path(__file__).resolve().parents[4]
            scenario = json.loads((root / "scenario.json").read_text())
            project = Path(sys.argv[sys.argv.index("-P") + 1])
            if not project.is_absolute() or not project.is_file():
                raise SystemExit("project does not resolve from fixed tool context")
            workspace = project.parent
            (root / "workspace").write_text(str(workspace))
            libraries = ("silver_io.ads", "silver_io.adb", "silver_output_libc.ads", "silver_arguments.ads", "silver_arguments.adb", "silver_runtime.ads")
            if any(Path(argument).name == "gnatprove" for argument in sys.argv):
                # Confirm the proof input is exactly the selected local source
                # set, not the caller's cwd or an expanded search directory.
                text = project.read_text()
                if 'for Source_Dirs use (".")' not in text:
                    raise SystemExit("project source directory escaped its snapshot")
                if 'for Source_Files use ("main.adb", "silver_io.ads", "silver_io.adb", "silver_output_libc.ads", "silver_arguments.ads", "silver_arguments.adb", "silver_runtime.ads")' not in text:
                    raise SystemExit("project did not select exactly the runtime files")
                for name in libraries:
                    if (workspace / name).read_bytes() != (root / "src" / name).read_bytes():
                        raise SystemExit("runtime snapshot differs before proof")
                (root / "proof_invoked").touch()
                target = workspace / "obj/gnatprove"
                target.mkdir(parents=True)
                for name in ("main~1.spark", "silver_io.spark", "silver_output_libc.spark", "silver_arguments.spark", "silver_runtime.spark"):
                    if name != scenario.get("missing"):
                        shutil.copyfile(root / "reports" / name, target / name)
                if scenario.get("rejected"):
                    changed = target / scenario["rejected"]
                    evidence = json.loads(changed.read_text())
                    if scenario["fault"] == "unproved":
                        evidence["proof"][0]["severity"] = "high"
                    elif scenario["fault"] == "empty_proof":
                        evidence["proof"] = []
                    else:
                        evidence["spark"][" 2"] = "all"
                    changed.write_text(json.dumps(evidence))
                if scenario.get("phase") == "proof":
                    changed = workspace / scenario["library"]
                    changed.write_bytes(changed.read_bytes() + b"\\n-- changed during proof\\n")
            elif "gprbuild" in sys.argv:
                (root / "build_invoked").touch()
                if scenario.get("phase") == "build":
                    changed = workspace / scenario["library"]
                    changed.write_bytes(changed.read_bytes() + b"\\n-- changed during build\\n")
                executable = workspace / "bin/main"
                executable.parent.mkdir(parents=True)
                if scenario.get("missing_executable"):
                    raise SystemExit(0)
                executable.write_text("#!" + sys.executable + "\\nimport json, os, sys\\nfrom pathlib import Path\\n"
                                      + "Path(" + repr(str(root / "run_invoked")) + ").touch()\\n"
                                      + "Path(" + repr(str(root / "arguments.json")) + ").write_text("
                                      + "json.dumps([os.fsencode(arg).hex() for arg in sys.argv[1:]]))\\n"
                                      + "print('Hello, world!')\\n"
                                      + ("os.kill(os.getpid(), " + repr(scenario["signal"]) + ")\\n"
                                         if "signal" in scenario else "")
                                      + "raise SystemExit(" + repr(scenario.get("exit_status", 0)) + ")\\n")
                executable.chmod(0o755)
            else:
                raise SystemExit("unexpected external tool")
            '''))
        alr.chmod(0o755)

    def invoke_scenario(self, scenario: dict, command: str = "run",
                        arguments: tuple[str | bytes, ...] = (), *,
                        stack_bytes: int | None = None) -> subprocess.CompletedProcess[str]:
        (self.sandbox / "scenario.json").write_text(json.dumps(scenario))
        for name in ("workspace", "proof_invoked", "build_invoked", "run_invoked", "arguments.json"):
            (self.sandbox / name).unlink(missing_ok=True)
        # A caller-owned package with the same filename must not affect the
        # fixed installation selection. The fixture tool checks copied bytes.
        caller = Path(self.temporary.name) / "caller"
        caller.mkdir(exist_ok=True)
        for name in LIBRARIES:
            (caller / name).write_text("caller-owned source must not be selected")
        def set_stack_limit() -> None:
            import resource
            resource.setrlimit(resource.RLIMIT_STACK, (stack_bytes, stack_bytes))
        return subprocess.run([str(self.silver), command, str(self.source), *arguments], cwd=caller,
                              env=os.environ.copy(), capture_output=True, text=True, timeout=30,
                              preexec_fn=set_stack_limit if stack_bytes is not None else None)

    def run_scenario(self, scenario: dict, command: str = "run",
                     arguments: tuple[str | bytes, ...] = (), *,
                     stack_bytes: int | None = None) -> tuple[subprocess.CompletedProcess[str], Path]:
        result = self.invoke_scenario(scenario, command, arguments, stack_bytes=stack_bytes)
        output = result.stdout + result.stderr
        marker = self.sandbox / "workspace"
        self.assertTrue(marker.is_file(), output)
        workspace = Path(marker.read_text())
        self.assertEqual(workspace.parent, self.host.artifacts)
        self.addCleanup(shutil.rmtree, workspace)
        self.assertEqual((workspace / "main.adb").read_bytes(), SOURCE)
        self.assertEqual(self.source.read_bytes(), SOURCE)
        for name, original in self.originals.items():
            self.assertEqual((ROOT / "src" / name).read_bytes(), original)
        return result, workspace

    def assert_rejected(self, scenario: dict, build_started: bool, message: str) -> Path:
        result, workspace = self.run_scenario(scenario)
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 3, output)
        self.assertIn(message, output)
        self.assertNotIn("Executable:", output)
        self.assertNotIn("Execution completed successfully.", output)
        self.assertTrue((self.sandbox / "proof_invoked").exists())
        self.assertEqual((self.sandbox / "build_invoked").exists(), build_started)
        self.assertFalse((self.sandbox / "run_invoked").exists())
        return workspace

    def test_selected_compiler_accepts_output_source(self) -> None:
        result = test_silver.invoke("check", self.source)
        self.assertEqual(result.returncode, 0, result.stdout)

    def test_success_uses_fixed_library_selection_and_runs(self) -> None:
        result, workspace = self.run_scenario({})
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 0, output)
        self.assertIn("Executable:", output)
        self.assertIn("Hello, world!\n", output)
        self.assertIn("Execution completed successfully.", output)
        self.assertTrue((self.sandbox / "build_invoked").exists())
        self.assertTrue((self.sandbox / "run_invoked").exists())
        for name, original in self.originals.items():
            self.assertEqual((workspace / name).read_bytes(), original)

    def test_run_forwards_exact_argument_vector(self) -> None:
        # The real driver invokes a fixture child that records raw argv bytes.
        # Tool reports are fixtures, so this does not repeat application proofs
        # merely to exercise the driver's process boundary.
        cases = ((), (b"",),
                 (b"", b"two words", b"apostrophe's", b'"double quotes"',
                  b"back\\slash", b"$HOME;|<>*?[]{}()", b"$(printf expanded)",
                  b"`printf expanded`", b"--leading-dash", b"--"),
                 (b"\t", b"line\nbreak", b"\r", b"\x7f", b"\x80", b"caf\xc3\xa9"),
                 (b"'" * 4096,), (b"x" * 4097,), (b"",) * 8192)
        for arguments in cases:
            with self.subTest(argument_count=len(arguments),
                              first_lengths=[len(argument) for argument in arguments[:10]]):
                result, _ = self.run_scenario({}, arguments=("--", *arguments))
                output = result.stdout + result.stderr
                self.assertEqual(result.returncode, 0, output)
                observed = json.loads((self.sandbox / "arguments.json").read_text())
                self.assertEqual(observed, [argument.hex() for argument in arguments])
                self.assertIn("Execution completed successfully.", output)
        result, _ = self.run_scenario({})
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(json.loads((self.sandbox / "arguments.json").read_text()), [])

    def test_run_preserves_application_exit_status(self) -> None:
        for status in (1, 9, 127, 255):
            with self.subTest(status=status):
                result, _ = self.run_scenario({"exit_status": status}, arguments=("--", "one", "two"))
                output = result.stdout + result.stderr
                self.assertEqual(result.returncode, status, output)
                self.assertIn(f"Execution returned status {status}.", output)
                self.assertNotIn("Execution completed successfully.", output)
                self.assertNotIn("Execution failed:", output)
                self.assertNotIn("output failure", output)
                self.assertTrue((self.sandbox / "run_invoked").exists())

    @unittest.skipUnless(sys.platform == "linux" and platform.machine() == "x86_64",
                         "the retained 8 MiB / 190,000-argument regression is Linux x86-64")
    def test_large_argument_vector_with_eight_mib_stack(self) -> None:
        arguments = ("",) * 190_000
        result, _ = self.run_scenario({}, arguments=("--", *arguments),
                                      stack_bytes=8 * 1024 * 1024)
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        self.assertEqual(json.loads((self.sandbox / "arguments.json").read_text()), list(arguments))
        self.assertIn("Execution completed successfully.", result.stdout)

    def test_missing_application_keeps_ambiguous_runtime_status(self) -> None:
        # GNAT's Spawn reports the same status for failed exec and child exit 1.
        # The driver must preserve it without inventing a cause.
        result, _ = self.run_scenario({"missing_executable": True})
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 1, output)
        self.assertIn("Execution returned status 1.", output)
        self.assertNotIn("Execution failed:", output)
        self.assertNotIn("Execution completed successfully.", output)
        self.assertFalse((self.sandbox / "run_invoked").exists())

    def test_run_abnormal_exit_reports_process_failure(self) -> None:
        result, _ = self.run_scenario({"signal": 15})
        output = result.stdout + result.stderr
        self.assertEqual(result.returncode, 3, output)
        self.assertIn("Execution failed: application did not exit normally.", output)
        self.assertNotIn("Execution returned status", output)
        self.assertNotIn("Execution completed successfully.", output)
        self.assertTrue((self.sandbox / "run_invoked").exists())

    def test_application_report_capacity_accepts_exact_bound_without_truncation(self) -> None:
        fixture = self.fixtures / "main~1.spark"
        original = fixture.read_bytes()
        self.addCleanup(fixture.write_bytes, original)
        maximum = original + b" " * (33_554_432 - len(original))
        fixture.write_bytes(maximum)
        result, _ = self.run_scenario({})
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        fixture.write_bytes(maximum + b" ")
        self.assert_rejected({}, False, "missing or incomplete proof evidence")

    def test_large_opaque_proof_trees_preserve_complete_original_reports(self) -> None:
        # Exercise the real report readers for Main and selected runtime units.
        # Only external proof/build tools are fixtures. The opaque loser text
        # exceeds both the application and runtime audit-storage bounds.
        for name in ("main~1.spark", "silver_io.spark", "silver_arguments.spark"):
            with self.subTest(report=name):
                fixture = self.fixtures / name
                original = fixture.read_bytes()
                try:
                    data = json.loads(original)
                    if name == "main~1.spark":
                        data["proof"] = main_report(1)["proof"]
                    data["proof"][0]["check_tree"] = [{"proof_attempts": {
                        "Z3": {"result": 'Failure\\\"[]{}\n' + "x" * 34_000_000}}}]
                    raw = json.dumps(data).encode()
                    fixture.write_bytes(raw)
                    result, workspace = self.run_scenario({}, command="compile")
                    self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                    self.assertEqual((workspace / "obj/gnatprove" / name).read_bytes(), raw)
                    self.assertEqual(fixture.read_bytes(), raw)
                finally:
                    fixture.write_bytes(original)

    def test_malformed_opaque_proof_tree_stops_before_build(self) -> None:
        fixture = self.fixtures / "main~1.spark"
        original = fixture.read_bytes()
        self.addCleanup(fixture.write_bytes, original)
        data = json.loads(original)
        data["proof"] = main_report(1)["proof"]
        data["proof"][0]["check_tree"] = "OPAQUE_SENTINEL"
        encoded = json.dumps(data)
        for malformed in ('"bad\\q"', '"bad\\u12', '[{"result":"unfinished',
                          '{"mismatch":[1,2}', '{"missing":}', '[1,]'):
            with self.subTest(opaque=malformed):
                fixture.write_text(encoded.replace('"OPAQUE_SENTINEL"', malformed))
                self.assert_rejected({}, False, "missing or incomplete proof evidence")

    def test_dense_review_construction_accepts_maximal_credit_report(self) -> None:
        from tests.test_capacity import dense_report, dense_source
        fixture = self.fixtures / "main~1.spark"
        original = fixture.read_bytes()
        self.addCleanup(fixture.write_bytes, original)
        self.addCleanup(self.source.write_bytes, SOURCE)
        raw = dense_report().encode()
        self.assertGreater(len(raw), 2_097_152)
        fixture.write_bytes(raw)
        self.source.write_bytes(dense_source())
        result = self.invoke_scenario({}, command="compile")
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
        workspace = Path((self.sandbox / "workspace").read_text())
        self.addCleanup(shutil.rmtree, workspace)
        self.assertEqual((workspace / "main.adb").read_bytes(), dense_source())
        self.assertEqual((workspace / "obj/gnatprove/main~1.spark").read_bytes(), raw)
        self.assertTrue((self.sandbox / "build_invoked").exists())

    def test_missing_runtime_report_stops_before_build(self) -> None:
        for name in ("silver_io.spark", "silver_output_libc.spark", "silver_arguments.spark", "silver_runtime.spark"):
            with self.subTest(report=name):
                self.assert_rejected({"missing": name}, False, "runtime library evidence")

    def test_present_but_rejected_runtime_report_stops_before_build(self) -> None:
        for name, fault in (("silver_io.spark", "unproved"),
                            ("silver_io.spark", "empty_proof"),
                            ("silver_output_libc.spark", "wrong_import_coverage"),
                            ("silver_arguments.spark", "unproved"),
                            ("silver_arguments.spark", "empty_proof"),
                            ("silver_runtime.spark", "wrong_import_coverage")):
            with self.subTest(report=name, fault=fault):
                workspace = self.assert_rejected({"rejected": name, "fault": fault}, False,
                                                 "runtime library evidence")
                self.assertTrue((workspace / "obj/gnatprove" / name).is_file())

    def test_divergent_installed_source_stops_before_proof(self) -> None:
        for name, original in self.originals.items():
            with self.subTest(library=name):
                selected = self.sandbox / "src" / name
                selected.write_bytes(original + b"\n-- divergent live installation\n")
                try:
                    result = self.invoke_scenario({})
                    output = result.stdout + result.stderr
                    self.assertEqual(result.returncode, 3, output)
                    self.assertIn("cannot create identical runtime library snapshots", output)
                    self.assertNotIn("Executable:", output)
                    for marker in ("proof_invoked", "build_invoked", "run_invoked"):
                        self.assertFalse((self.sandbox / marker).exists(), output)
                    self.assertEqual((ROOT / "src" / name).read_bytes(), original)
                    self.assertEqual(self.source.read_bytes(), SOURCE)
                finally:
                    selected.write_bytes(original)

    def test_artifact_symlink_does_not_redirect_runtime_source_selection(self) -> None:
        alias = self.sandbox / ".silver"
        physical = Path(self.temporary.name) / "external artifact store"
        alias.rename(physical)
        alias.symlink_to(physical, target_is_directory=True)
        try:
            result, workspace = self.run_scenario({})
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            for name, original in self.originals.items():
                self.assertEqual((workspace / name).read_bytes(), original)
        finally:
            alias.unlink()
            physical.rename(alias)

    def test_every_library_snapshot_change_during_proof_stops_before_build(self) -> None:
        for name in LIBRARIES:
            with self.subTest(library=name):
                workspace = self.assert_rejected({"phase": "proof", "library": name}, False,
                                                 "runtime library changed during verification")
                self.assertNotEqual((workspace / name).read_bytes(), self.originals[name])

    def test_every_library_snapshot_change_during_build_stops_before_publication(self) -> None:
        for name in LIBRARIES:
            with self.subTest(library=name):
                workspace = self.assert_rejected({"phase": "build", "library": name}, True,
                                                 "runtime library changed during compilation")
                self.assertTrue((workspace / "bin/main").exists())
                self.assertNotEqual((workspace / name).read_bytes(), self.originals[name])


if __name__ == "__main__":
    unittest.main()
