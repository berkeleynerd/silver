"""Import coverage comes from the loaded environment, never comment text."""
from pathlib import Path
import tempfile
import unittest

from scripts.check_lean import (CANDIDATE, audit_import_closure, prepare_workspace,
                               verify_workspace_inputs)
from scripts.platforms import HostLayout


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
        root = Path(temporary.name)
        (root / "src").mkdir()
        host = HostLayout(root, "linux-aarch64")
        inputs = {root / "proof" / path: contents for path, contents in (
            ("Silver/AuthoritativeSource.lean", b'def source := include_str "../../../src/main.adb"\n'),
            ("Silver/SourceBridge.lean", b"import Silver.AuthoritativeSource\n"),
            ("lakefile.lean", b"import Lake\n"),
            ("lean-toolchain", b"leanprover/lean4:v4.34.1\n"))}
        prepare_workspace(host, inputs)
        (host.proof / CANDIDATE).write_text("-- untrusted candidate output\n")
        verify_workspace_inputs(host, inputs)
        return host, inputs

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


if __name__ == "__main__":
    unittest.main()
