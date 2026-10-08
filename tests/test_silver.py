"""End-to-end regression evidence for the actual SPARK executable."""
from __future__ import annotations

import json
import os
from pathlib import Path
import re
import shutil
import subprocess
import sys
import tempfile
import textwrap
import unittest

from scripts.bootstrap import prepare_context
from scripts.platforms import HostLayout, alire_command, native_layout, tool_environment

ROOT = Path(__file__).resolve().parents[1]
HOST = native_layout(ROOT)
SILVER = HOST.compiler / "bin" / "silver"
CANONICAL = b"procedure Main is pragma SPARK_Mode (On); begin null; end Main;"


def invoke(*args: str | Path, cwd: Path = ROOT) -> subprocess.CompletedProcess[str]:
    return subprocess.run([str(SILVER), *(str(arg) for arg in args)], cwd=cwd,
                          text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                          timeout=120)


class SilverIntegrationTests(unittest.TestCase):
    @classmethod
    def setUpClass(cls) -> None:
        if not SILVER.is_file():
            raise RuntimeError("build the actual SPARK compiler before running its tests")

    def setUp(self) -> None:
        self.directory = tempfile.TemporaryDirectory(prefix="silver tests-")
        self.addCleanup(self.directory.cleanup)
        self.source = Path(self.directory.name) / "input.adb"

    def check_source(self, data: bytes, expected: int) -> None:
        self.source.write_bytes(data)
        before = set(HOST.artifacts.glob("program-*"))
        result = invoke("check", self.source)
        self.assertEqual(result.returncode, expected, result.stdout)
        self.assertEqual(self.source.read_bytes(), data, "checking modified author source")
        self.assertEqual(set(HOST.artifacts.glob("program-*")), before,
                         "membership checking created a build workspace")

    def test_catalogue_is_json(self) -> None:
        result = invoke("catalogue")
        self.assertEqual(result.returncode, 0, result.stdout)
        catalogue = json.loads(result.stdout)
        self.assertIsInstance(catalogue, dict)
        self.assertEqual(catalogue, json.loads((ROOT / "catalogue/silver.json").read_text()))
        self.assertEqual(catalogue["profile"], "silver")
        self.assertEqual(catalogue["max_source_bytes"], 4096)
        self.assertEqual(catalogue["procedure_name"], "Main")
        self.assertEqual(catalogue["source_encoding"], "ASCII")
        self.assertEqual(catalogue["whitespace_bytes"], [9, 10, 13, 32])
        self.assertEqual(catalogue["comment_prefix"], "--")
        self.assertEqual(catalogue["comment_end_bytes"], [10, 13])
        self.assertIs(catalogue["comment_ends_at_eof"], True)
        self.assertEqual(catalogue["comment_printable_bytes"], [32, 126])
        self.assertIs(catalogue["comment_tab_allowed"], True)
        self.assertIs(catalogue["ascii_case_insensitive"], True)
        self.assertIs(catalogue["whole_identifier_tokens"], True)
        self.assertEqual(catalogue["allowed_source_bytes"], [9, 10, 13, *range(32, 127)])
        self.assertEqual(catalogue["identifier_bytes"], sorted(b"0123456789ABCDEFGHIJKLMNOPQRSTUVWXYZ_abcdefghijklmnopqrstuvwxyz"))
        self.assertEqual(catalogue["casefold_bytes"], list(bytes(range(256)).lower()))
        self.assertIs(catalogue["additional_constructs"], False)
        self.assertEqual(catalogue["schema_version"], 1)
        constructs = {item["id"]: item for item in catalogue["constructs"]}
        self.assertEqual(set(constructs), {"main_procedure", "spark_mode_on", "null_statement",
                                          "runtime_context", "literal_output", "string_literal"})
        compositions = {item["name"]: item for item in catalogue["compositions"]}
        self.assertEqual(set(compositions), {"null", "literal_output"})
        self.assertEqual(compositions["null"]["statements"], ["null_statement"])
        self.assertEqual(compositions["null"]["context"], [])
        self.assertEqual(compositions["literal_output"]["statements"], ["literal_output"])
        self.assertEqual(compositions["literal_output"]["context"], ["runtime_context"])
        self.assertEqual(constructs["string_literal"]["conditions"]["quote_escape"], '""')
        self.assertEqual(catalogue["null_tokens"], ["procedure", "main", "is", "pragma",
                         "spark_mode", "(", "on", ")", ";", "begin", "null",
                         ";", "end", "main", ";"])
        self.assertEqual(catalogue["output_tokens"], ["with", "silver_io", ";", "procedure",
                         "main", "is", "pragma", "spark_mode", "(", "on", ")", ";",
                         "begin", "silver_io", ".", "put_line", "(", "<string_literal>",
                         ")", ";", "end", "main", ";"])

    def test_accepted_lexical_forms(self) -> None:
        cases = {
            "original": (ROOT / "samples/null.adb").read_bytes(),
            "compact": CANONICAL,
            "case": CANONICAL.upper(),
            "mixed_case": b"PrOcEdUrE mAiN iS pRaGmA SpArK_MoDe(oN);bEgIn NuLl;eNd MAIN;",
            "crlf": b"\t\r\n" + CANONICAL.replace(b" ", b"\r\n\t") + b"\r\n",
            "comments": b"-- preface\r\nprocedure-- separated\nMain is\rpragma SPARK_Mode-- mode\n(On);begin null;end Main;-- at EOF",
            "comment_punctuation": CANONICAL + b' -- "pragma Assume(False);" -- extra null;\t',
            "size_limit": CANONICAL + b" " * (4096 - len(CANONICAL)),
            "size_limit_comment": CANONICAL + b"--" + b"x" * (4094 - len(CANONICAL)),
        }
        for name, data in cases.items():
            with self.subTest(name=name):
                self.check_source(data, 0)

    def test_excluded_constructs_and_boundaries(self) -> None:
        cases = {
            "empty": b"",
            "oversize": CANONICAL + b" " * (4097 - len(CANONICAL)),
            "keyword_prefix": b"x" + CANONICAL,
            "keyword_suffix": CANONICAL.replace(b"procedure", b"procedurex"),
            "joined_words": CANONICAL.replace(b"Main is", b"Mainis"),
            "identifier_underscore": CANONICAL.replace(b"Main", b"Main_", 1),
            "identifier_digit": CANONICAL.replace(b"Main", b"Main1", 1),
            "different_name": CANONICAL.replace(b"Main", b"Other"),
            "missing_end_name": CANONICAL.replace(b"end Main", b"end"),
            "mismatched_end": CANONICAL.replace(b"end Main", b"end Other"),
            "additional_null": CANONICAL.replace(b"null;", b"null; null;"),
            "additional_unit": CANONICAL + b"\n" + CANONICAL,
            "context_clause": b"with Ada.Text_IO;\n" + CANONICAL,
            "additional_pragma": CANONICAL.replace(b"begin", b"pragma Assert (True); begin"),
            "mode_off": CANONICAL.replace(b"(On)", b"(Off)"),
            "proof_annotation": CANONICAL.replace(b"begin", b"pragma Assume (True); begin"),
            "declaration": CANONICAL.replace(b"begin", b"X : Integer := 0; begin"),
            "comment_consumes_source": b"--" + CANONICAL,
            "single_dash": b"-" + CANONICAL,
            "truncated": CANONICAL[:-1],
            "trailing_token": CANONICAL + b" null;",
        }
        for name, data in cases.items():
            with self.subTest(name=name):
                self.check_source(data, 2)

    def test_excluded_bytes_including_inside_comments(self) -> None:
        for byte in (0, 1, 11, 12, 31, 127, 128, 195, 255):
            for where in ("prefix", "comment"):
                with self.subTest(byte=byte, where=where):
                    data = bytes([byte]) + CANONICAL if where == "prefix" else CANONICAL + b"--" + bytes([byte])
                    self.check_source(data, 2)
        self.check_source(b"\xef\xbb\xbf" + CANONICAL, 2)

    def test_file_errors(self) -> None:
        result = invoke("check", Path(self.directory.name) / "missing.adb")
        self.assertEqual(result.returncode, 3, result.stdout)
        result = invoke("check", self.directory.name)
        self.assertEqual(result.returncode, 3, result.stdout)
        self.source.write_bytes(CANONICAL)
        self.source.chmod(0)
        try:
            if os.geteuid() != 0:
                result = invoke("check", self.source)
                self.assertEqual(result.returncode, 3, result.stdout)
        finally:
            self.source.chmod(0o600)

    def test_command_usage_errors(self) -> None:
        for args in ((), ("unknown",), ("check",), ("compile",), ("run",),
                     ("check", "samples/null.adb", "extra")):
            with self.subTest(args=args):
                self.assertNotEqual(invoke(*args).returncode, 0)

    def test_excluded_source_never_proceeds_to_compilation(self) -> None:
        self.source.write_bytes(CANONICAL.replace(b"null;", b"raise Program_Error;"))
        before = set(HOST.artifacts.glob("program-*"))
        result = invoke("compile", self.source)
        self.assertEqual(result.returncode, 2, result.stdout)
        self.assertNotIn("Executable:", result.stdout)
        created = set(HOST.artifacts.glob("program-*")) - before
        self.assertEqual(created, set(), "excluded source created a workspace")
        for workspace in created:
            self.assertFalse(list(workspace.rglob("*.spark")), "excluded source reached proof")
            self.assertFalse((workspace / "bin/main").exists(), "excluded source was compiled")

    def test_run_preserves_the_admitted_source(self) -> None:
        # Includes filename punctuation, maximum source length and nontrivial
        # lexical variation: these must survive admission/proof/build unchanged.
        variant = b"-- leading comment\r\n" + CANONICAL.upper() + b"--"
        variant += b"x" * (4096 - len(variant))
        source = Path(self.directory.name) / "input ' with spaces.adb"
        source.write_bytes(variant)
        before = set(HOST.artifacts.glob("program-*"))
        # Paths are anchored to the compiled installation, even when
        # the caller has a separate tree resembling that installation.
        foreign = Path(self.directory.name) / "foreign"
        foreign.mkdir(exist_ok=True)
        planted = foreign / HOST.alr.relative_to(ROOT)
        planted.parent.mkdir(parents=True, exist_ok=True)
        planted.write_text("#!/bin/sh\nexit 99\n")
        planted.chmod(0o755)
        result = invoke("run", source, cwd=foreign)
        self.assertEqual(result.returncode, 0, result.stdout)
        self.assertIn("Execution completed successfully.", result.stdout)
        self.assertFalse((foreign / ".silver").exists())
        match = re.search(r"^Executable: (.+)$", result.stdout, re.MULTILINE)
        self.assertIsNotNone(match, result.stdout)
        executable = Path(match.group(1))
        if not executable.is_absolute():
            executable = ROOT / executable
        self.assertTrue(executable.is_file(), result.stdout)
        execution = subprocess.run([str(executable)], timeout=10, capture_output=True)
        self.assertEqual(execution.returncode, 0, execution.stderr)
        self.assertEqual(execution.stdout, b"")
        self.assertEqual(source.read_bytes(), variant)
        created = set(HOST.artifacts.glob("program-*")) - before
        self.assertEqual(len(created), 1, result.stdout)
        workspace = created.pop()
        snapshots = [path for path in workspace.rglob("*.adb")
                     if path.read_bytes() == variant]
        self.assertEqual(len(snapshots), 1, "missing or ambiguous byte-identical snapshot")
        projects = list(workspace.glob("*.gpr"))
        self.assertEqual(len(projects), 1)
        self.assertIn(snapshots[0].name, projects[0].read_text())
        reports = list(workspace.rglob("gnatprove.sarif"))
        self.assertEqual(len(reports), 1)
        from scripts.check_evidence import audit_reports
        statistics = audit_reports(reports[0].parent, {snapshots[0].stem})
        self.assertEqual(statistics["units"], 1)
        self.assertEqual(statistics["proof_checks"], 0)
        shutil.rmtree(workspace)

    def test_tool_failures_and_source_changes_do_not_report_success(self) -> None:
        # Only the external tool is replaced. The real SPARK CLI executes all
        # admission, snapshot, error-handling and evidence-validation code.
        sandbox = (Path(self.directory.name) / "checkout ' \" $literal; `x` café").resolve()
        sandbox.mkdir()
        fixture_host = HostLayout(sandbox, HOST.key)
        (sandbox / "src").symlink_to(ROOT / "src", target_is_directory=True)
        shutil.copyfile(ROOT / "silver.gpr", sandbox / "silver.gpr")
        shutil.copyfile(ROOT / "alire.toml", sandbox / "alire.toml")
        prepare_context(fixture_host)
        # Compile the unchanged implementation with fixture-specific paths.
        # The production binary has no caller-controlled tool override.
        build = subprocess.run(alire_command(HOST, "exec", "--", "gprbuild", "-P",
                               sandbox / "silver.gpr", "-XSILVER_HOST=" + HOST.key, "-p"),
                               cwd=HOST.context, env=tool_environment(HOST),
                               capture_output=True, text=True, timeout=120)
        self.assertEqual(build.returncode, 0, build.stdout + build.stderr)
        fixture_silver = fixture_host.compiler / "bin/silver"
        alr = sandbox / HOST.alr.relative_to(ROOT)
        alr.parent.mkdir(parents=True)
        context = sandbox / HOST.context.relative_to(ROOT)
        context.mkdir(parents=True, exist_ok=True)
        settings = sandbox / HOST.alire_settings.relative_to(ROOT)
        settings.mkdir(parents=True, exist_ok=True)
        protected_settings = [sandbox / relative for relative in (
            "inherited-settings/config.toml", "inherited-legacy-settings/config.toml",
            "alire/config.toml")]
        for path in protected_settings:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(b"settings outside the selected host must remain unchanged")
        alr.write_text("#!" + sys.executable + "\n" + textwrap.dedent('''\
            import json
            import os
            from pathlib import Path
            import sys
            # The shell must enter the host context before starting Alire:
            # its Early_Load runs before command-line -s/-C processing.
            sandbox = Path(__file__).resolve().parents[4]
            mode = (sandbox / "scenario").read_text()
            key = Path(__file__).resolve().parents[2].name
            expected_settings = sandbox / ".tools" / key / "alire/settings"
            expected_context = sandbox / ".silver" / key / "toolchain"
            settings = Path(os.environ.get("ALIRE_SETTINGS_DIR", "."))
            if not settings.is_absolute() or settings.resolve() != expected_settings or not settings.is_dir():
                raise SystemExit("Alire startup settings did not preserve the exact sandbox path")
            overrides = {"ALR_CONFIG", "GPR_CONFIG", "GPR_PROJECT_PATH", "GPR_PROJECT_PATH_FILE", "ADA_PROJECT_PATH"}
            if overrides.intersection(os.environ):
                raise SystemExit("Alire inherited tool configuration overrides")
            if Path.cwd() != expected_context:
                raise SystemExit("Alire started outside the isolated host context")
            if "-s" in sys.argv:
                if Path(sys.argv[sys.argv.index("-s") + 1]).resolve() != expected_settings:
                    raise SystemExit("Alire -s did not preserve the exact sandbox path")
            # Alire changes the child tool's cwd before resolving -P. The
            # real driver must supply a project path valid from that context.
            if "-C" in sys.argv:
                context = Path(sys.argv[sys.argv.index("-C") + 1])
                if context.resolve() != expected_context:
                    raise SystemExit("Alire -C did not select the sandbox host context")
                os.chdir(context)
            project = Path(sys.argv[sys.argv.index("-P") + 1])
            if not project.is_file():
                raise SystemExit("driver project path is invalid after Alire -C")
            (sandbox / "routing_checked").write_text(str(project.resolve()))
            snapshot = project.parent / "main.adb"
            if "gnatprove" in sys.argv:
                if mode == "tool_failure":
                    raise SystemExit(1)
                if mode == "missing_report":
                    raise SystemExit(0)
                report = {"progress": "PROGRESS_PROOF", "stop_reason": "STOP_REASON_NONE",
                          "spark": {" 1": "all"}, "flow": [], "proof": [], "warn_error": [],
                          "skip_flow_proof": [], "skip_proof": [], "pragma_assume": []}
                if mode == "flow_only":
                    report["progress"] = "PROGRESS_FLOW"
                if mode == "outside_spark":
                    report["spark"][" 1"] = "spec"
                if mode == "extra_entity":
                    report["spark"][" 2"] = "all"
                if mode == "unproved":
                    report["proof"] = [{"severity": "medium", "how_proved": "unproved"}]
                if mode == "nonempty_flow":
                    report["flow"] = [{"severity": "medium", "how_proved": "flow"}]
                if mode == "skipped_flow":
                    report["skip_flow_proof"] = [1]
                if mode == "stopped":
                    report["stop_reason"] = "STOP_REASON_ERROR"
                if mode == "skipped":
                    report["skip_proof"] = [1]
                if mode == "assumption":
                    report["pragma_assume"] = [1]
                if mode == "warning":
                    report["warn_error"] = [{"severity": "warning"}]
                target = project.parent / "obj/gnatprove/main.spark"
                target.parent.mkdir(parents=True)
                if mode in ("large_report", "maximum_report", "oversized_report", "large_rejected"):
                    # Non-whitespace padding BEFORE the recognized fields
                    # exercises both compaction and the entire prefix scan.
                    size = 20000 if mode == "large_report" else 262144
                    if mode == "oversized_report":
                        size += 1
                    if mode == "large_rejected":
                        report["skip_flow_proof"] = [1]
                    report = {"padding": "", **report}
                    report["padding"] = "x" * (size - len(json.dumps(report)))
                target.write_text(json.dumps(report))
                if mode == "source_changed_during_proof":
                    snapshot.write_text("source changed by external tool")
            else:
                (sandbox / "build_invoked").touch()
                if mode == "build_failure":
                    raise SystemExit(1)
                if mode == "source_changed_during_build":
                    snapshot.write_text("source changed by external tool")
                executable = project.parent / "bin/main"
                executable.parent.mkdir(parents=True, exist_ok=True)
                executable.write_text("#!/bin/sh\\nexit " + ("9" if mode == "run_failure" else "0") + "\\n")
                executable.chmod(0o755)
            '''))
        alr.chmod(0o755)
        self.source.write_bytes(CANONICAL)
        for mode in ("tool_failure", "missing_report", "flow_only", "outside_spark", "extra_entity",
                     "unproved", "nonempty_flow", "skipped_flow", "stopped", "skipped", "assumption", "warning",
                     "source_changed_during_proof", "build_failure", "source_changed_during_build",
                     "success", "run_failure", "large_report", "maximum_report", "oversized_report", "large_rejected"):
            with self.subTest(mode=mode):
                (sandbox / "scenario").write_text(mode)
                (sandbox / "build_invoked").unlink(missing_ok=True)
                (sandbox / "routing_checked").unlink(missing_ok=True)
                command = "run" if mode in ("success", "run_failure") else "compile"
                result = subprocess.run([str(fixture_silver), command, str(self.source)], cwd=self.directory.name,
                                        text=True, stdout=subprocess.PIPE, stderr=subprocess.STDOUT,
                                        env={**os.environ,
                                             "ALIRE_SETTINGS_DIR": str(sandbox / "inherited-settings"),
                                             "ALR_CONFIG": str(sandbox / "inherited-legacy-settings"),
                                             "GPR_CONFIG": "untrusted.cgpr",
                                             "GPR_PROJECT_PATH": "untrusted-projects",
                                             "GPR_PROJECT_PATH_FILE": "untrusted-list",
                                             "ADA_PROJECT_PATH": "untrusted-ada"},
                                        # Full-size reports exercise bounded scans plus runtime
                                        # ghost observations on potentially contended hosts.
                                        timeout=120 if mode in ("maximum_report", "oversized_report",
                                                               "large_rejected") else 30)
                successful = mode in ("success", "large_report", "maximum_report")
                self.assertEqual(result.returncode, 0 if successful else 3, result.stdout)
                self.assertTrue((sandbox / "routing_checked").is_file(), result.stdout)
                project = Path((sandbox / "routing_checked").read_text())
                self.assertTrue(project.is_relative_to(sandbox / HOST.artifacts.relative_to(ROOT)))
                published = successful or mode == "run_failure"
                self.assertEqual("Executable:" in result.stdout, published, result.stdout)
                self.assertEqual("Execution completed successfully." in result.stdout, mode == "success")
                self.assertEqual((sandbox / "build_invoked").exists(),
                                 mode in ("build_failure", "source_changed_during_build", "run_failure") or successful)
                for path in protected_settings:
                    self.assertEqual(path.read_bytes(),
                                     b"settings outside the selected host must remain unchanged")
                self.assertEqual(self.source.read_bytes(), CANONICAL)
        # Checking alone never invokes the fixture tools or creates a workspace.
        before = set(fixture_host.artifacts.glob("program-*"))
        (sandbox / "routing_checked").unlink(missing_ok=True)
        checked = subprocess.run([str(fixture_silver), "check", str(self.source)],
                                 cwd=self.directory.name, capture_output=True, text=True, timeout=10)
        self.assertEqual(checked.returncode, 0, checked.stdout + checked.stderr)
        self.assertFalse((sandbox / "routing_checked").exists())
        self.assertEqual(set(fixture_host.artifacts.glob("program-*")), before)


if __name__ == "__main__":
    unittest.main()
