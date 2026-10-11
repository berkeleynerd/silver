"""Lean evidence, incremental workspace integrity and temporary-path regressions."""
from contextlib import ExitStack, redirect_stdout
import io
import json
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import threading
import time
from types import SimpleNamespace
import unittest
from unittest import mock

from scripts import check_lean
from scripts.bootstrap_lean import lean_environment
from scripts.check_lean import (CANDIDATES, audit_import_closure, lake_build_command,
                               prepare_tool_cache, prepare_workspace,
                               verify_workspace_inputs)
from scripts.platforms import HostLayout, native_layout
from tests.test_lean_source import EMBEDDED, GENERATOR

ROOT = Path(__file__).resolve().parents[1]


class LeanCPUSelectionTests(unittest.TestCase):
    def test_affinity_and_process_limits_both_constrain_available_cpus(self) -> None:
        for affinity, process_count, expected in (({2, 3}, 8, 2), (set(range(12)), 3, 3)):
            with self.subTest(affinity=affinity, process_count=process_count):
                operating_system = SimpleNamespace(
                    sched_getaffinity=lambda _pid: affinity,
                    process_cpu_count=lambda: process_count, cpu_count=lambda: 16)
                with mock.patch.object(check_lean, "os", operating_system):
                    self.assertEqual(check_lean.available_cpus(), expected)

    def test_python_311_and_non_affinity_platform_fallback(self) -> None:
        with mock.patch.object(check_lean, "os", SimpleNamespace(cpu_count=lambda: 6)):
            self.assertEqual(check_lean.available_cpus(), 6)

    def test_unavailable_affinity_does_not_prevent_cpu_detection(self) -> None:
        operating_system = SimpleNamespace(
            sched_getaffinity=mock.Mock(side_effect=OSError("affinity unavailable")),
            process_cpu_count=lambda: 4, cpu_count=lambda: 16)
        with mock.patch.object(check_lean, "os", operating_system):
            self.assertEqual(check_lean.available_cpus(), 4)

    def test_unknown_counts_still_allow_one_worker(self) -> None:
        for reported in (None, 0):
            with self.subTest(reported=reported), mock.patch.object(
                    check_lean, "os", SimpleNamespace(cpu_count=lambda: reported)):
                self.assertEqual(check_lean.available_cpus(), 1)


class LeanEvidenceTests(unittest.TestCase):
    def test_complete_environment_inventory(self) -> None:
        modules = {name: Path(name + ".lean") for name in ("Silver", "Silver.Audit", "Silver.Source")}
        output = "\n".join(f"info: Silver/Audit.lean:1:0: SILVER_MODULE {name}" for name in modules)
        self.assertEqual(audit_import_closure(modules, output), set(modules))

    def test_orphan_module_is_not_covered_by_a_comment_import(self) -> None:
        modules = {name: Path(name + ".lean") for name in ("Silver", "Silver.Audit", "Silver.Orphan")}
        output = "SILVER_MODULE Silver\nSILVER_MODULE Silver.Audit\n/- import Silver.Orphan -/\n"
        with self.assertRaisesRegex(RuntimeError, "missing=Silver.Orphan"):
            audit_import_closure(modules, output)

    def test_unexpected_loaded_project_module_is_rejected(self) -> None:
        with self.assertRaisesRegex(RuntimeError, "unexpected=Silver.Hidden"):
            audit_import_closure({"Silver.Audit": Path("Audit.lean")},
                                 "SILVER_MODULE Silver.Audit\nSILVER_MODULE Silver.Hidden\n")

    def workspace(self) -> tuple[HostLayout, dict[Path, bytes]]:
        temporary = tempfile.TemporaryDirectory(prefix="silver-lean-binding-")
        self.addCleanup(temporary.cleanup)
        root = Path(temporary.name).resolve()
        (root / "src").mkdir()
        host = HostLayout(root, "linux-aarch64")
        inputs = {root / "proof" / path: contents for path, contents in (
            ("Silver/AuthoritativeSource.lean", b'def source := include_str "../../../src/main.adb"\n'),
            ("Silver/SourceBridge.lean", b"import Silver.AuthoritativeSource\n"),
            ("Silver/SourceCertificates.lean", b"-- protected import facade\n"),
            ("lakefile.lean", b"import Lake\n"),
            ("lean-toolchain", b"leanprover/lean4:v4.34.1\n"))}
        prepare_workspace(host, inputs)
        for candidate in CANDIDATES:
            (host.proof / candidate).write_text("-- untrusted candidate output\n")
        verify_workspace_inputs(host, inputs)
        return host, inputs

    def test_unchanged_workspace_preserves_inputs_and_cached_objects(self) -> None:
        host, inputs = self.workspace()
        cached = host.proof / ".lake/build/lib/lean/Silver/SourceBridge.olean"
        cached.parent.mkdir(parents=True)
        cached.write_bytes(b"cached object")
        before = {path: (path.read_bytes(), path.stat().st_mtime_ns, path.stat().st_ino)
                  for path in host.proof.rglob("*") if path.is_file()}
        prepare_workspace(host, inputs)
        self.assertEqual({path: (path.read_bytes(), path.stat().st_mtime_ns, path.stat().st_ino)
                          for path in before}, before)
        changed = dict(inputs)
        changed[host.root / "proof/Silver/SourceBridge.lean"] += b"-- changed proof\n"
        prepare_workspace(host, changed)
        self.assertEqual((host.proof / "Silver/SourceBridge.lean").read_bytes(),
                         changed[host.root / "proof/Silver/SourceBridge.lean"])
        self.assertEqual(cached.read_bytes(), b"cached object")

    def test_removed_module_cannot_survive_as_an_importable_cached_object(self) -> None:
        host, inputs = self.workspace()
        cached = host.proof / ".lake/build/lib/lean/Silver/SourceBridge.olean"
        cached.parent.mkdir(parents=True)
        cached.write_bytes(b"old removed module")
        del inputs[host.root / "proof/Silver/SourceBridge.lean"]
        prepare_workspace(host, inputs)
        self.assertFalse((host.proof / "Silver/SourceBridge.lean").exists())
        self.assertFalse(cached.exists())
        self.assertTrue((host.proof / "Silver/AuthoritativeSource.lean").is_file())

    def test_changed_tool_invalidates_cache_without_rewriting_sources(self) -> None:
        host, _inputs = self.workspace()
        source = host.proof / "Silver/AuthoritativeSource.lean"
        before = (source.read_bytes(), source.stat().st_mtime_ns)
        prepare_tool_cache(host, {"lean": "old hash"})
        cached = host.proof / ".lake/build/object.olean"
        cached.parent.mkdir(parents=True)
        cached.write_bytes(b"prior compiled configuration or object")
        prepare_tool_cache(host, {"lean": "old hash"})
        self.assertTrue(cached.is_file())
        prepare_tool_cache(host, {"lean": "new hash"})
        self.assertFalse(cached.exists())
        self.assertEqual((source.read_bytes(), source.stat().st_mtime_ns), before)

    def test_generator_cannot_replace_handwritten_inputs_before_hash_capture(self) -> None:
        host, inputs = self.workspace()
        for source, expected in inputs.items():
            destination = host.proof / source.relative_to(host.root / "proof")
            with self.subTest(path=destination):
                destination.write_bytes(b"-- replacement\n")
                with self.assertRaisesRegex(RuntimeError, "changed handwritten proof input"):
                    verify_workspace_inputs(host, inputs)
                destination.write_bytes(expected)
        verify_workspace_inputs(host, inputs)

    def test_each_generated_certificate_must_be_regular_and_present(self) -> None:
        host, inputs = self.workspace()
        for relative in CANDIDATES:
            with self.subTest(candidate=relative):
                candidate = host.proof / relative
                contents = candidate.read_bytes()
                candidate.unlink()
                with self.assertRaisesRegex(RuntimeError, "regular certificate"):
                    verify_workspace_inputs(host, inputs)
                outside = host.root / "candidate.lean"
                outside.write_bytes(contents)
                candidate.symlink_to(outside)
                with self.assertRaisesRegex(RuntimeError, "symbolic link"):
                    verify_workspace_inputs(host, inputs)
                candidate.unlink()
                candidate.write_bytes(contents)
        verify_workspace_inputs(host, inputs)

    def test_generator_cannot_replace_input_with_same_content_symlink(self) -> None:
        host, inputs = self.workspace()
        destination = host.proof / "Silver/AuthoritativeSource.lean"
        outside = host.root / "outside.lean"
        outside.write_bytes(destination.read_bytes())
        destination.unlink()
        destination.symlink_to(outside)
        with self.assertRaisesRegex(RuntimeError, "symbolic link"):
            verify_workspace_inputs(host, inputs)

    def test_generator_cannot_replace_parent_directory_with_symlink(self) -> None:
        host, inputs = self.workspace()
        directory = host.proof / "Silver"
        outside = host.root / "outside"
        directory.rename(outside)
        directory.symlink_to(outside, target_is_directory=True)
        with self.assertRaisesRegex(RuntimeError, "symbolic link"):
            verify_workspace_inputs(host, inputs)


class LeanRunnerPhaseTests(unittest.TestCase):
    """Exercise final-run ordering without compiling the production proofs."""

    def fixture(self) -> SimpleNamespace:
        temporary = tempfile.TemporaryDirectory(prefix="silver lean phases-")
        self.addCleanup(temporary.cleanup)
        root = Path(temporary.name).resolve()
        host = HostLayout(root, "linux-x86_64")
        proof = root / "proof"
        (proof / "Silver").mkdir(parents=True)
        (root / "src").mkdir()
        (root / "scripts").mkdir()
        (root / "scripts/check_lean.py").write_text("# fixture runner input\n")
        (proof / "Silver.lean").write_text("namespace Silver\nend Silver\n")
        (proof / "Silver/Audit.lean").write_text("import Silver\n")
        (proof / "lakefile.lean").write_text("import Lake\n")
        (proof / "lean-toolchain").write_text("leanprover/lean4:v4.34.1\n")
        (proof / "generate_source_certificate.py").write_text("# fixture generator\n")
        for relative, source in CANDIDATES.items():
            (proof / relative).write_text("-- shared candidate is deliberately not trusted\n")
            (root / "src" / source).write_text("-- authoritative source fixture\n")
        (host.lean / "bin").mkdir(parents=True)
        for tool in ("lean", "lake", "leanchecker"):
            (host.lean / "bin" / tool).write_text("fixture " + tool)
        state = SimpleNamespace(host=host, phases=[], generated=0, after_generation=None,
                                after_phase=None, audit="valid", fail=None, interrupt=None)

        def run(command, **_kwargs):
            if command[1:] == ["--short-version"]:
                return subprocess.CompletedProcess(command, 0, "4.34.1\n")
            self.assertEqual(command[:2], [sys.executable, str(proof / "generate_source_certificate.py")])
            source = command[command.index("--source") + 1]
            Path(command[command.index("--output") + 1]).write_text("-- candidate " + source + "\n")
            state.generated += 1
            if state.generated == len(CANDIDATES) and state.after_generation:
                state.after_generation(host)
            return subprocess.CompletedProcess(command, 0)

        def run_logged(command, *, cwd, env, destination):
            self.assertEqual(cwd, host.proof)
            self.assertEqual(env["LEAN_NUM_THREADS"], "2")
            phase = "build" if "build" in command else "audit" if command[-1].endswith(".lean") else "kernel"
            state.phases.append(phase)
            output = "fixture " + phase + "\n"
            if phase == "build":
                artifact = host.proof / ".lake/build/lib/lean/Silver/Audit.olean"
                artifact.parent.mkdir(parents=True)
                artifact.write_bytes(b"compiled fixture")
                output += "Silver axiom audit passed: cached output is insufficient\n"
            if phase == "audit":
                if state.audit != "missing-marker":
                    output += "Silver axiom audit passed: fixture\n"
                names = sorted(check_lean.project_sources(host.proof))
                if state.audit == "missing-module":
                    names = names[1:]
                if state.audit == "unexpected-module":
                    names.append("Silver.Unexpected")
                output += "".join("SILVER_MODULE " + name + "\n" for name in names)
            destination.write(output)
            destination.flush()
            if state.after_phase:
                state.after_phase(phase, host)
            if phase == state.interrupt:
                raise KeyboardInterrupt()
            return subprocess.CompletedProcess(command, 7 if phase == state.fail else 0, output)

        patches = ExitStack()
        self.addCleanup(patches.close)
        for name, value in (("ROOT", root), ("PROOF", proof)):
            patches.enter_context(mock.patch.object(check_lean, name, value))
        patches.enter_context(mock.patch.object(check_lean, "native_layout", return_value=host))
        patches.enter_context(mock.patch.object(check_lean, "available_cpus", return_value=2))
        patches.enter_context(mock.patch.object(check_lean, "lean_environment", return_value=dict(os.environ)))
        patches.enter_context(mock.patch.object(check_lean.subprocess, "run", side_effect=run))
        patches.enter_context(mock.patch.object(check_lean, "run_logged", side_effect=run_logged))
        return state

    def check_fails(self, state: SimpleNamespace, expected: str) -> None:
        with redirect_stdout(io.StringIO()), self.assertRaisesRegex(RuntimeError, expected):
            check_lean.main(["--full"])
        self.assertFalse((state.host.artifacts / "lean-evidence.json").exists())

    def test_added_or_deleted_shared_inputs_stop_after_build_with_cache_retained(self) -> None:
        for relative, action in (("proof/Silver/New.lean", "add"), ("src/new.adb", "add"),
                                 ("scripts/new.py", "add"), ("proof/Silver.lean", "delete"),
                                 ("src/silver_profile.adb", "delete"), ("scripts/check_lean.py", "delete")):
            with self.subTest(path=relative, action=action):
                state = self.fixture()

                def change(_phase, host):
                    path = host.root / relative
                    path.write_text("new input\n") if action == "add" else path.unlink()

                state.after_phase = change
                self.check_fails(state, "shared inventory or bytes")
                self.assertEqual(state.phases, ["build"])
                self.assertTrue((state.host.proof / ".lake/build/lib/lean/Silver/Audit.olean").is_file())

    def test_added_workspace_module_stops_before_fresh_audit(self) -> None:
        state = self.fixture()
        state.after_phase = lambda _phase, host: (host.proof / "Silver/New.lean").write_text("-- new\n")
        self.check_fails(state, "workspace inventory or bytes")
        self.assertEqual(state.phases, ["build"])

    def test_generation_drift_stops_before_lake(self) -> None:
        state = self.fixture()
        state.after_generation = lambda host: (host.root / "src/new.ads").write_text("-- new\n")
        self.check_fails(state, "shared inventory or bytes")
        self.assertEqual(state.phases, [])

    def test_missing_fresh_audit_or_incomplete_closure_never_runs_kernel(self) -> None:
        for audit in ("missing-marker", "missing-module", "unexpected-module"):
            with self.subTest(audit=audit):
                state = self.fixture()
                state.audit = audit
                expected = "freshly executed axiom audit" if audit == "missing-marker" else "actual Lean audit imports"
                self.check_fails(state, expected)
                self.assertEqual(state.phases, ["build", "audit"])

    def test_input_drift_at_audit_or_kernel_cannot_publish_success(self) -> None:
        for changed_phase in ("audit", "kernel"):
            with self.subTest(phase=changed_phase):
                state = self.fixture()

                def change(phase, host):
                    if phase == changed_phase:
                        (host.root / "scripts/added.py").write_text("# new\n")

                state.after_phase = change
                self.check_fails(state, "shared inventory or bytes")
                self.assertEqual(state.phases, ["build", "audit"] + (["kernel"] if changed_phase == "kernel" else []))

    def test_tool_or_artifact_drift_stops_before_kernel(self) -> None:
        for target in ("tool", "artifact", "source-link"):
            with self.subTest(target=target):
                state = self.fixture()

                def change(phase, host):
                    if phase == "audit":
                        if target == "source-link":
                            other = host.root / "other-src"
                            other.mkdir()
                            link = host.artifacts / "src"
                            link.unlink()
                            link.symlink_to(other, target_is_directory=True)
                        else:
                            path = (host.lean / "bin/leanchecker" if target == "tool" else
                                    host.proof / ".lake/build/lib/lean/Silver/Audit.olean")
                            path.write_bytes(b"changed")

                state.after_phase = change
                expected = {"tool": "tools changed", "artifact": "artifacts changed",
                            "source-link": "source link changed"}[target]
                self.check_fails(state, expected)
                self.assertEqual(state.phases, ["build", "audit"])

    def test_shared_candidate_bytes_and_cache_files_are_not_new_proof_inputs(self) -> None:
        state = self.fixture()

        def change(phase, host):
            if phase == "build":
                (host.root / "proof" / next(iter(CANDIDATES))).write_text("-- unused shared candidate\n")
                (host.proof / ".lake/cache.lean").write_text("-- cache entry\n")

        state.after_phase = change
        with redirect_stdout(io.StringIO()):
            check_lean.main(["--full"])
        self.assertEqual(state.phases, ["build", "audit", "kernel"])

    def test_phase_failure_and_interruption_preserve_partial_log(self) -> None:
        for interrupt in (False, True):
            with self.subTest(interrupt=interrupt):
                state = self.fixture()
                if interrupt:
                    state.interrupt = "audit"
                    with redirect_stdout(io.StringIO()), self.assertRaises(KeyboardInterrupt):
                        check_lean.main(["--full"])
                else:
                    state.fail = "audit"
                    self.check_fails(state, "Lean check failed")
                log = (state.host.artifacts / "lean-proof.log").read_text()
                self.assertIn("fixture audit", log)
                self.assertIn("interrupted" if interrupt else "exit 7", log)
                self.assertEqual(state.phases, ["build", "audit"])
                self.assertFalse((state.host.artifacts / "lean-evidence.json").exists())

    def test_success_records_actual_phase_times_and_current_inventories(self) -> None:
        state = self.fixture()
        with redirect_stdout(io.StringIO()):
            check_lean.main(["--full"])
        evidence = json.loads((state.host.artifacts / "lean-evidence.json").read_text())
        self.assertEqual([phase["phase"] for phase in evidence["phases"]], ["build", "audit", "kernel"])
        for phase in evidence["phases"]:
            self.assertEqual(phase["exit_code"], 0)
            self.assertGreaterEqual(phase["elapsed_seconds"], 0)
            self.assertLessEqual(phase["started_at"], phase["finished_at"])
        self.assertEqual(set(evidence["modules"]), set(check_lean.project_sources(state.host.proof)))
        self.assertEqual(evidence["kernel_recheck"], "leanchecker --fresh Silver.Audit")


class LeanStreamingTests(unittest.TestCase):
    def test_partial_lines_and_merged_stderr_are_logged_before_child_exit(self) -> None:
        with tempfile.TemporaryDirectory(prefix="silver lean stream-") as temporary:
            root = Path(temporary).resolve()
            release = root / "release"
            log = root / "phase.log"
            # Exit is gated on the parent observing a flushed, unterminated
            # UTF-8 message in the canonical log. Buffer-until-exit would fail.
            code = ("import os,time\nfrom pathlib import Path\n"
                    "os.write(1, b'partial \\xe2'); time.sleep(.05)\n"
                    "os.write(1, b'\\x9c\\x93'); os.write(2, b' stderr')\n"
                    f"release=Path({str(release)!r})\n"
                    "deadline=time.monotonic()+5\n"
                    "while not release.exists() and time.monotonic()<deadline: time.sleep(.01)\n"
                    "raise SystemExit(7 if release.exists() else 8)\n")
            results = []

            def run():
                with log.open("w") as destination:
                    results.append(check_lean.run_logged(
                        [sys.executable, "-c", code], cwd=root, env=dict(os.environ),
                        destination=destination))

            console = io.StringIO()
            with redirect_stdout(console):
                thread = threading.Thread(target=run)
                thread.start()
                try:
                    deadline = time.monotonic() + 4
                    while time.monotonic() < deadline:
                        if log.exists() and log.read_text() == "partial ✓ stderr":
                            break
                        time.sleep(.01)
                    self.assertEqual(log.read_text(), "partial ✓ stderr")
                    self.assertTrue(thread.is_alive())
                finally:
                    release.touch()
                    thread.join(timeout=6)
            self.assertFalse(thread.is_alive())
            self.assertEqual(len(results), 1)
            self.assertEqual(results[0].returncode, 7)
            self.assertEqual(results[0].stdout, "partial ✓ stderr")
            self.assertEqual(console.getvalue(), results[0].stdout)


class LeanTemporaryDirectoryTests(unittest.TestCase):
    def test_fixture_suite_under_symlinked_tmpdir(self) -> None:
        with tempfile.TemporaryDirectory(prefix="silver lean tmpdir-") as temporary:
            parent = Path(temporary).resolve()
            physical = parent / "physical"
            physical.mkdir()
            alias = parent / "alias"
            alias.symlink_to(physical, target_is_directory=True)
            environment = dict(os.environ, TMPDIR=str(alias), TEMP=str(alias), TMP=str(alias),
                               PYTHONDONTWRITEBYTECODE="1")
            # A fresh process avoids tempfile's cached directory. Select only
            # the fixture class so this subprocess test cannot call itself.
            result = subprocess.run(
                [sys.executable, "-m", "unittest", "tests.test_lean_evidence.LeanEvidenceTests"],
                cwd=Path(__file__).resolve().parents[1], env=environment,
                text=True, capture_output=True, timeout=30)
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


class LeanNativeDependencyTests(unittest.TestCase):
    def test_changed_resource_settings_apply_without_discarding_cached_objects(self) -> None:
        native = native_layout(ROOT)
        if not (native.lean / "bin/lake").is_file():
            self.skipTest("install the pinned native Lean tools to check Lake configuration")
        with tempfile.TemporaryDirectory(prefix="silver lean config-") as temporary:
            root = Path(temporary).resolve()
            host = HostLayout(root, native.key)
            host.lean.parent.mkdir(parents=True)
            host.lean.symlink_to(native.lean, target_is_directory=True)
            (root / "src").mkdir()
            for name in EMBEDDED:
                (root / "src" / name).write_bytes(b"original\n")
            audit_source = (
                'example : True := True.intro\n'
                '#eval (do IO.println ("lake workers=" ++ '
                '(← IO.getEnv "LEAN_NUM_THREADS").getD "missing") : IO Unit)\n').encode()
            inputs = {
                root / "proof/lakefile.lean": (ROOT / "proof/lakefile.lean").read_bytes(),
                root / "proof/lean-toolchain": (ROOT / "proof/lean-toolchain").read_bytes(),
                root / "proof/Silver/Audit.lean": audit_source,
            }
            prepare_workspace(host, inputs)
            environment = lean_environment(host)

            def build(workers: int, threads: int, memory: int) -> subprocess.CompletedProcess[str]:
                command = lake_build_command(host.lean / "bin/lake", [
                    "-K", f"silverThreads={threads}", "-K", f"silverMemoryMb={memory}"])
                command.insert(1, "--verbose")
                result = subprocess.run(
                    command, cwd=host.proof,
                    env={**environment, "LEAN_NUM_THREADS": str(workers)}, text=True,
                    capture_output=True, timeout=180)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
                return result

            first = build(1, 1, 256)
            self.assertRegex(first.stdout + first.stderr, r"\s-j1\s-M256\b")
            self.assertIn("lake workers=1", first.stdout + first.stderr)
            artifact = host.proof / ".lake/build/lib/lean/Silver/Audit.olean"
            before = (artifact.read_bytes(), artifact.stat().st_mtime_ns)
            build(3, 2, 512)
            self.assertEqual((artifact.read_bytes(), artifact.stat().st_mtime_ns), before)
            # Force a new Lean process after changing only the cached Lake
            # configuration. Without --reconfigure it still receives -j1/-M256.
            (host.proof / "Silver/Audit.lean").write_bytes(
                audit_source + b"example : 2 + 2 = 4 := rfl\n")
            changed = build(3, 2, 512)
            self.assertRegex(changed.stdout + changed.stderr, r"\s-j2\s-M512\b")
            self.assertIn("lake workers=3", changed.stdout + changed.stderr)

    def test_lake_tracks_embedded_ada_bytes_and_preserves_unchanged_objects(self) -> None:
        native = native_layout(ROOT)
        if not (native.lean / "bin/lake").is_file():
            self.skipTest("install the pinned native Lean tools to check actual Lake invalidation")
        with tempfile.TemporaryDirectory(prefix="silver lean dependencies-") as temporary:
            root = Path(temporary).resolve()
            host = HostLayout(root, native.key)
            host.lean.parent.mkdir(parents=True)
            host.lean.symlink_to(native.lean, target_is_directory=True)
            (root / "src").mkdir()
            sources = [root / "src" / name for name in EMBEDDED]
            for source in sources:
                source.write_bytes(b"original\n")
            inputs = {
                root / "proof/lakefile.lean": (ROOT / "proof/lakefile.lean").read_bytes(),
                root / "proof/lean-toolchain": (ROOT / "proof/lean-toolchain").read_bytes(),
                root / "proof/Silver/Independent.lean": b"example : True := True.intro\n",
            }
            modules = {}
            imports = ["import Silver.Independent"]
            for filename, binding, _prefix in GENERATOR.SOURCE_BINDINGS:
                module = binding[0].upper() + binding[1:] + "Source"
                modules[filename] = module
                relative = Path("Silver") / f"{module}.lean"
                # Exercise the actual handwritten binding and exact library
                # ownership, with independent stale-value witnesses downstream.
                inputs[root / "proof" / relative] = (ROOT / "proof" / relative).read_bytes()
                inputs[root / f"proof/Silver/{module}Witness.lean"] = (
                    f"import Silver.{module}\n"
                    f'example : Silver.Source.{binding} = "original\\n" := by decide\n'
                ).encode()
                imports.append(f"import Silver.{module}Witness")
            inputs[root / "proof/Silver.lean"] = ("\n".join(imports) + "\n").encode()
            prepare_workspace(host, inputs)
            environment = lean_environment(host)
            command = [str(host.lean / "bin/lake"), "--rehash", "-K", "silverThreads=1",
                       "build", "Silver"]

            def build() -> subprocess.CompletedProcess[str]:
                return subprocess.run(command, cwd=host.proof, env=environment, text=True,
                                      capture_output=True, timeout=180)

            result = build()
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

            def objects() -> dict[str, tuple[bytes, int]]:
                return {str(path.relative_to(host.proof / ".lake/build/lib/lean")):
                        (path.read_bytes(), path.stat().st_mtime_ns)
                        for path in (host.proof / ".lake/build/lib/lean").rglob("*.olean")}

            before = objects()
            result = build()
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertEqual(objects(), before)
            for source in sources:
                with self.subTest(source=source.name):
                    before = objects()
                    original = source.read_bytes()
                    stat = source.stat()
                    # CRLF must differ even with a restored timestamp. A text
                    # input_file dependency would normalize it and miss this.
                    try:
                        source.write_bytes(original.replace(b"\n", b"\r\n"))
                        os.utime(source, ns=(stat.st_atime_ns, stat.st_mtime_ns))
                        result = build()
                        self.assertNotEqual(result.returncode, 0, "changed included Ada bytes used a stale object")
                        self.assertIn("decide", result.stdout + result.stderr)
                        changed_module = f"Silver/{modules[source.name]}.olean"
                        after = objects()
                        self.assertNotEqual(after[changed_module], before[changed_module])
                        affected = {changed_module, "Silver.olean",
                                    f"Silver/{modules[source.name]}Witness.olean"}
                        for module, identity in before.items():
                            if module not in affected:
                                self.assertEqual(after[module], identity, module)
                    finally:
                        source.write_bytes(original)
                    result = build()
                    self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
