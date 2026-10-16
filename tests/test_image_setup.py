"""Image routing binds the original vendor tool and preserves its installation."""
from __future__ import annotations

import os
from pathlib import Path
import shutil
import tempfile
import unittest

from scripts import bootstrap, proof_provenance
from scripts.check_evidence import EvidenceError, audit_import_spec, audit_sources
from scripts.platforms import HostLayout, host_key

ROOT = Path(__file__).resolve().parents[1]


class ImageSetupTests(unittest.TestCase):
    def setUp(self) -> None:
        temporary = tempfile.TemporaryDirectory(prefix="silver image ' $ ` ")
        self.addCleanup(temporary.cleanup)
        self.host = HostLayout(Path(temporary.name), host_key())
        root = self.host.root
        (root / "src").mkdir()
        shutil.copy2(ROOT / "alire.toml", root / "alire.toml")
        for filename in bootstrap.RUNTIME_SOURCES.values():
            shutil.copy2(ROOT / "src" / filename, root / "src" / filename)
        shutil.copy2(ROOT / "src/silver_image_adapter.adb", root / "src/silver_image_adapter.adb")
        bootstrap.prepare_context(self.host)
        self.vendor = self.host.tools / "vendor"
        for relative in ("bin/gnatprove", "libexec/spark/bin/gnatwhy3", "libexec/spark/bin/cvc5",
                         "libexec/spark/plugin.dat", "libexec/helper", "share/why3/theory.mlw",
                         "lib/libgnat.so", "include/interface.h"):
            path = self.vendor / relative
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(relative.encode())
            path.chmod(0o755)
        self.native = self.vendor / "bin/gnatprove"
        self.original = self.vendor / "libexec/spark/bin/gnatwhy3"
        self.identities = {"gnatprove": {"path": str(self.native)},
                           "gnatwhy3": {"path": str(self.original)}}

    def prepare(self) -> None:
        bootstrap.prepare_image_tools(self.host, self.native)

    def validate(self) -> None:
        proof_provenance.validate_image_binding(self.host, self.identities)

    def test_overlay_preserves_vendor_and_selects_compiled_adapter(self) -> None:
        before = {path: (path.read_bytes(), path.stat().st_mtime_ns)
                  for path in self.vendor.rglob("*") if path.is_file()}
        self.prepare()
        self.validate()
        copied = self.host.image_tools / "bin/gnatprove"
        self.assertFalse(copied.is_symlink())
        self.assertEqual(copied.read_bytes(), self.native.read_bytes())
        adapter = self.host.image_tools / "libexec/spark/bin/gnatwhy3"
        self.assertEqual(Path(os.readlink(adapter)), self.host.image_adapter)
        self.assertEqual((self.host.image_tools / "share").resolve(), self.vendor / "share")
        self.assertEqual((self.host.generated / "silver_image_config.ads").read_bytes(),
                         bootstrap.image_configuration(self.original))
        self.assertEqual(before, {path: (path.read_bytes(), path.stat().st_mtime_ns) for path in before})
        times = {path: path.lstat().st_mtime_ns for path in self.host.image_tools.rglob("*")}
        config_time = (self.host.generated / "silver_image_config.ads").stat().st_mtime_ns
        self.prepare()
        self.assertEqual(times, {path: path.lstat().st_mtime_ns for path in times})
        self.assertEqual(config_time, (self.host.generated / "silver_image_config.ads").stat().st_mtime_ns)

    def test_config_and_driver_routing_must_match_original_tool_binding(self) -> None:
        self.prepare()
        for name in ("silver_image_config.ads", "silver_build.ads"):
            with self.subTest(name=name):
                path = self.host.generated / name
                original = path.read_bytes()
                path.write_bytes(original.replace(b"gnat", b"other"))
                with self.assertRaises(EvidenceError):
                    self.validate()
                path.write_bytes(original)
        self.identities["gnatwhy3"]["path"] = str(self.host.image_adapter)
        with self.assertRaisesRegex(EvidenceError, "recorded original"):
            self.validate()

    def test_overlay_cannot_delegate_to_itself_or_hide_replacement_tools(self) -> None:
        self.prepare()
        with self.assertRaisesRegex(RuntimeError, "original native"):
            bootstrap.prepare_image_tools(self.host, self.host.image_tools / "bin/gnatprove")
        adapter = self.host.image_tools / "libexec/spark/bin/gnatwhy3"
        adapter.unlink()
        adapter.symlink_to(self.original)
        with self.assertRaisesRegex(EvidenceError, "overlay entry"):
            self.validate()
        self.prepare()
        (self.host.image_tools / "bin/gnatprove").write_bytes(b"changed executable")
        with self.assertRaisesRegex(EvidenceError, "overlay entry"):
            self.validate()
        self.prepare()
        (self.host.image_tools / "unexpected").write_bytes(b"new route")
        with self.assertRaisesRegex(EvidenceError, "overlay layout"):
            self.validate()

    def test_vendor_change_requires_regenerating_exact_configuration(self) -> None:
        self.prepare()
        self.original.write_bytes(b"new original vendor release")
        with self.assertRaisesRegex(EvidenceError, "vendor configuration"):
            self.validate()
        self.prepare()
        self.validate()

    def test_original_support_tool_must_resolve_inside_native_tools(self) -> None:
        self.prepare()
        config = self.host.generated / "silver_image_config.ads"
        before_config = (config.read_bytes(), config.stat().st_mtime_ns)
        before_overlay = self.host.image_tools.stat().st_ino
        before_entries = {path: path.lstat().st_mtime_ns
                          for path in self.host.image_tools.rglob("*")}
        for target in (self.host.image_adapter, self.host.root / "external-gnatwhy3"):
            with self.subTest(target=target):
                target.parent.mkdir(parents=True, exist_ok=True)
                target.write_bytes(b"not the original native support tool")
                self.original.unlink()
                self.original.symlink_to(target)
                with self.assertRaisesRegex(RuntimeError, "original native gnatwhy3"):
                    bootstrap.validate_image_setup(self.host, self.native)
                with self.assertRaisesRegex(RuntimeError, "original native gnatwhy3"):
                    self.prepare()
                self.assertEqual(before_config, (config.read_bytes(), config.stat().st_mtime_ns))
                self.assertEqual(before_overlay, self.host.image_tools.stat().st_ino)
                self.assertEqual(before_entries,
                                 {path: path.lstat().st_mtime_ns for path in before_entries})

    def test_original_support_tool_may_link_inside_native_tools(self) -> None:
        actual = self.host.tools / "original-gnatwhy3"
        self.original.rename(actual)
        self.original.symlink_to(actual)
        self.prepare()
        bootstrap.validate_image_setup(self.host, self.native)
        self.assertEqual((self.host.generated / "silver_image_config.ads").read_bytes(),
                         bootstrap.image_configuration(actual))

    def test_foreign_host_setup_cannot_write_anything(self) -> None:
        foreign_key = "macos-aarch64" if host_key() != "macos-aarch64" else "linux-aarch64"
        foreign = HostLayout(self.host.root, foreign_key)
        with self.assertRaisesRegex(RuntimeError, "refusing to execute"):
            bootstrap.prepare_image_tools(foreign, self.native)
        self.assertFalse(foreign.artifacts.exists())

    def test_full_evidence_requires_adapter_configuration_and_all_units(self) -> None:
        reports = self.host.compiler / "obj/gnatprove"
        reports.mkdir(parents=True)
        with self.assertRaisesRegex(EvidenceError, "original Image vendor binding"):
            audit_sources(self.host.root / "src", reports, self.host.generated)
        self.prepare()
        with self.assertRaisesRegex(EvidenceError, "missing report"):
            audit_sources(self.host.root / "src", reports, self.host.generated)
        audit_import_spec(ROOT / "src/silver_image_libc.ads")


if __name__ == "__main__":
    unittest.main()
