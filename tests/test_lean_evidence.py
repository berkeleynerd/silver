"""Lean evidence, incremental workspace integrity and temporary-path regressions."""
import os
from pathlib import Path
import subprocess
import sys
import tempfile
import unittest

from scripts.bootstrap_lean import lean_environment
from scripts.check_lean import (CANDIDATES, audit_import_closure, prepare_tool_cache, prepare_workspace,
                               verify_workspace_inputs)
from scripts.platforms import HostLayout, native_layout
from tests.test_lean_source import EMBEDDED

ROOT = Path(__file__).resolve().parents[1]


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
