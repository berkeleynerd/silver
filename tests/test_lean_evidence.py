"""Lean evidence, incremental workspace integrity and temporary-path regressions."""
import os
from pathlib import Path
import subprocess
import sys
import tempfile
from types import SimpleNamespace
import unittest
from unittest import mock

from scripts import check_lean
from scripts.bootstrap_lean import lean_environment
from scripts.check_lean import (CANDIDATES, audit_import_closure, lake_build_command,
                               prepare_tool_cache, prepare_workspace,
                               verify_workspace_inputs)
from scripts.platforms import HostLayout, native_layout
from tests.test_lean_source import EMBEDDED

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
            declarations = "\n".join(
                f'def source{i} : String := include_str "../src/{source.name}"\n'
                f'example : source{i} = "original\\n" := by decide'
                for i, source in enumerate(sources)).encode()
            inputs = {
                root / "proof/lakefile.lean": (ROOT / "proof/lakefile.lean").read_bytes(),
                root / "proof/lean-toolchain": (ROOT / "proof/lean-toolchain").read_bytes(),
                root / "proof/Silver.lean": declarations,
            }
            prepare_workspace(host, inputs)
            environment = lean_environment(host)
            command = [str(host.lean / "bin/lake"), "--rehash", "-K", "silverThreads=1",
                       "build", "Silver"]

            def build() -> subprocess.CompletedProcess[str]:
                return subprocess.run(command, cwd=host.proof, env=environment, text=True,
                                      capture_output=True, timeout=180)

            result = build()
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            artifact = host.proof / ".lake/build/lib/lean/Silver.olean"
            before = (artifact.read_bytes(), artifact.stat().st_mtime_ns)
            result = build()
            self.assertEqual(result.returncode, 0, result.stdout + result.stderr)
            self.assertEqual((artifact.read_bytes(), artifact.stat().st_mtime_ns), before)
            for source in sources:
                with self.subTest(source=source.name):
                    original = source.read_bytes()
                    stat = source.stat()
                    source.write_bytes(original.replace(b"\n", b"\r"))
                    os.utime(source, ns=(stat.st_atime_ns, stat.st_mtime_ns))
                    result = build()
                    self.assertNotEqual(result.returncode, 0, "changed included Ada bytes used a stale object")
                    self.assertIn("decide", result.stdout + result.stderr)
                    source.write_bytes(original)
                    result = build()
                    self.assertEqual(result.returncode, 0, result.stdout + result.stderr)


if __name__ == "__main__":
    unittest.main()
