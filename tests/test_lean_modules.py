"""Native checks of module reuse, source invalidation and legacy audit coverage."""

import os
from pathlib import Path
import subprocess
import tempfile
import unittest
from unittest import mock

from scripts import check_lean
from scripts.bootstrap_lean import lean_environment
from scripts.check_lean import prepare_workspace
from scripts.platforms import HostLayout, native_layout

ROOT = Path(__file__).resolve().parents[1]
OBJECT_SUFFIXES = (".olean", ".olean.server", ".olean.private")


class LeanModuleTests(unittest.TestCase):
    def setUp(self) -> None:
        native = native_layout(ROOT)
        if not (native.lean / "bin/lake").is_file():
            self.skipTest("install the pinned native Lean tools to check module boundaries")
        temporary = tempfile.TemporaryDirectory(prefix="silver lean modules-")
        self.addCleanup(temporary.cleanup)
        self.root = Path(temporary.name).resolve()
        self.host = HostLayout(self.root, native.key)
        self.host.lean.parent.mkdir(parents=True)
        self.host.lean.symlink_to(native.lean, target_is_directory=True)
        (self.root / "src").mkdir()
        self.environment = {**lean_environment(self.host), "LEAN_NUM_THREADS": "1"}

    def project(self, modules: dict[str, str], *, binary_source: bool = False) -> None:
        lakefile = (
            'import Lake\nopen Lake DSL\npackage moduleProbe where\n'
            '  moreLeanArgs := #["-DwarningAsError=true"]\n'
            '  weakLeanArgs := #["-j1", "-M2048"]\n')
        if binary_source:
            lakefile += (
                'input_file sourceBytes where\n  path := "../src/probe.adb"\n'
                '  text := false\n')
        lakefile += 'lean_lib Silver\n'
        if binary_source:
            # Match production's binary input and exact provider ownership.
            lakefile += (
                'lean_lib Provider where\n  roots := #[]\n'
                '  globs := #[.one `Silver.Provider]\n  needs := #[sourceBytes]\n')
        files = {**modules, "lakefile.lean": lakefile,
                 "lean-toolchain": (ROOT / "proof/lean-toolchain").read_text()}
        prepare_workspace(self.host, {self.root / "proof" / name: text.encode()
                                      for name, text in files.items()})

    def lake(self, *arguments: str) -> subprocess.CompletedProcess[str]:
        return subprocess.run([str(self.host.lean / "bin/lake"), *arguments],
                              cwd=self.host.proof, env=self.environment,
                              text=True, capture_output=True, timeout=60)

    def build(self, *targets: str) -> subprocess.CompletedProcess[str]:
        return self.lake("--rehash", "--reconfigure", "build",
                         *("+" + target for target in targets))

    def assert_success(self, result: subprocess.CompletedProcess[str]) -> None:
        self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

    def objects(self, module: str) -> dict[str, tuple[bytes, int]]:
        base = self.host.proof / ".lake/build/lib/lean/Silver"
        result = {}
        for suffix in OBJECT_SUFFIXES:
            path = base / (module + suffix)
            self.assertTrue(path.is_file(), f"missing native module artifact: {path}")
            result[suffix] = (path.read_bytes(), path.stat().st_mtime_ns)
        return result

    def test_proof_reuse_and_public_source_invalidation(self) -> None:
        source = self.root / "src/probe.adb"
        source.write_bytes(b"original\n")
        provider = (
            'module\nnamespace Silver\n'
            '@[expose] public def value : Nat := 1\n'
            '@[expose] public def embedded : String := include_str "../../src/probe.adb"\n'
            'public theorem stable : True := True.intro\nend Silver\n')
        self.project({
            "Silver/Provider.lean": provider,
            "Silver/Consumer.lean": (
                'module\nimport Silver.Provider\n'
                'public theorem Silver.consumer : True := Silver.stable\n'
                'example : Silver.value = 1 := by rfl\n'
                'example : Silver.embedded = "original\\n" := by decide\n'),
            "Silver/Independent.lean": (
                'module\npublic theorem Silver.independent : True := True.intro\n'),
        }, binary_source=True)
        targets = ("Silver.Consumer", "Silver.Independent")
        self.assert_success(self.build(*targets))
        before = {module: self.objects(module)
                  for module in ("Provider", "Consumer", "Independent")}

        # Change a real proof term, retaining the statement and public data.
        proof_edit = provider.replace(
            "stable : True := True.intro", "stable : True := (fun h : True => h) True.intro")
        provider_path = self.host.proof / "Silver/Provider.lean"
        provider_path.write_text(proof_edit)
        self.assert_success(self.build(*targets))
        changed = self.objects("Provider")
        self.assertEqual(changed[".olean"][0], before["Provider"][".olean"][0])
        self.assertNotEqual(changed[".olean.private"][0], before["Provider"][".olean.private"][0])
        for module in ("Consumer", "Independent"):
            self.assertEqual(self.objects(module), before[module], module)

        provider_path.write_text(proof_edit.replace("value : Nat := 1", "value : Nat := 2"))
        result = self.build(*targets)
        output = result.stdout + result.stderr
        self.assertNotEqual(result.returncode, 0, output)
        self.assertIn("Tactic `rfl` failed", output)
        self.assertIn("Silver.value = 1", output)
        self.assertNotEqual(self.objects("Provider")[".olean"][0], changed[".olean"][0])
        self.assertEqual(self.objects("Independent"), before["Independent"])

        # Restore a successful state so the definition failure cannot mask the
        # separate binary-source dependency check.
        provider_path.write_text(proof_edit)
        self.assert_success(self.build(*targets))
        restored = self.objects("Provider")
        stat = source.stat()
        source.write_bytes(b"original\r\n")
        os.utime(source, ns=(stat.st_atime_ns, stat.st_mtime_ns))
        self.assertEqual(source.stat().st_mtime_ns, stat.st_mtime_ns)
        result = self.build(*targets)
        output = result.stdout + result.stderr
        self.assertNotEqual(result.returncode, 0, output)
        self.assertIn("Tactic `decide` proved that the proposition", output)
        self.assertIn('Silver.embedded = "original\\n"', output)
        self.assertIn("is false", output)
        self.assertNotEqual(self.objects("Provider")[".olean"][0], restored[".olean"][0])
        self.assertEqual(self.objects("Independent"), before["Independent"])

    def test_legacy_audits_reject_private_axiom_behind_module_import(self) -> None:
        self.project({
            "Silver/Provider.lean": (
                'module\npublic theorem Silver.api : True := True.intro\n'
                'private axiom OutsideSilver.hidden : False\n'),
            "Silver/Consumer.lean": (
                'module\nimport Silver.Provider\n'
                'public theorem Silver.consumer : True := Silver.api\n'),
            "Silver.lean": 'module\npublic import Silver.Consumer\n',
            # The complete audit also imports this independent candidate.
            "Silver/ComposeBooleanDeclarationCandidate.lean": 'module\n',
            "Silver/AxiomAudit.lean": (ROOT / "proof/Silver/AxiomAudit.lean").read_text(),
            "Silver/Audit.lean": (ROOT / "proof/Silver/Audit.lean").read_text(),
        })
        self.assert_success(self.build("Silver", "Silver.ComposeBooleanDeclarationCandidate",
                                       "Silver.AxiomAudit"))
        focused = self.host.proof / ".lake/silver-focused-audit.lean"
        focused.write_text("import Silver.Consumer\nimport Silver.AxiomAudit\n\n#silver_audit\n")
        for driver in ("Silver/Audit.lean", ".lake/silver-focused-audit.lean"):
            with self.subTest(driver=driver):
                result = self.lake("env", str(self.host.lean / "bin/lean"), "-j1", "-M2048",
                                   "-DwarningAsError=true", driver)
                output = result.stdout + result.stderr
                self.assertNotEqual(result.returncode, 0, output)
                self.assertIn("Unapproved logical assumption", output)
                self.assertIn("OutsideSilver.hidden", output)
                self.assertIn("SILVER_MODULE Silver.Provider", output)
                self.assertNotIn("Silver axiom audit passed:", output)

    def test_output_body_chunks_regenerate_and_track_token_and_newline_changes(self) -> None:
        source = self.root / "src/silver_output_profile.adb"
        original = b"X0;\nX1;\nX2;\nX3;\nX4;\nX5;\nX6;\n"
        source.write_bytes(original)
        proof = self.root / "proof"
        proof.mkdir()
        (proof / "generate_source_certificate.py").write_bytes(
            (ROOT / "proof/generate_source_certificate.py").read_bytes())
        inputs = {proof / name: (ROOT / "proof" / name).read_bytes()
                  for name in ("lakefile.lean", "lean-toolchain", *(
                      f"Silver/{module}.lean" for module in (
                          "Lexical", "Admission", "Cursor", "SourceLexer", "CertificateWitness",
                          "OutputProfileBodySource", "AxiomAudit")))}
        inputs[proof / "Silver/Independent.lean"] = (
            b"module\npublic theorem Silver.independent : True := True.intro\n")
        prepare_workspace(self.host, inputs)
        certificate = "OutputBodyCertificate"
        chunks = [path.stem for path in check_lean.OUTPUT_BODY_LINES]
        targets = ("Silver." + certificate, "Silver.Independent", "Silver.AxiomAudit")

        def build():
            return self.lake("--rehash", "--reconfigure", "-K", "silverThreads=1",
                             "-K", "silverMemoryMb=2048", "build", *("+" + target for target in targets))

        def regenerate():
            with mock.patch.object(check_lean, "ROOT", self.root), \
                    mock.patch.object(check_lean, "PROOF", proof):
                check_lean.generate_certificate(self.host, Path("Silver") / f"{certificate}.lean",
                                                source.name)

        def source_identities():
            return {module: ((self.host.proof / f"Silver/{module}.lean").read_bytes(),
                             (self.host.proof / f"Silver/{module}.lean").stat().st_mtime_ns)
                    for module in (certificate, *chunks)}

        def audit():
            driver = self.host.proof / ".lake/output-body-audit.lean"
            driver.write_text("import Silver.OutputBodyCertificate\nimport Silver.AxiomAudit\n\n#silver_audit\n")
            result = self.lake("env", str(self.host.lean / "bin/lean"), "-j1", "-M2048",
                               "-DwarningAsError=true", str(driver))
            self.assert_success(result)
            self.assertIn("Silver axiom audit passed:", result.stdout)
            for module in chunks:
                self.assertIn("SILVER_MODULE Silver." + module, result.stdout)

        regenerate()
        self.assert_success(build())
        audit()
        before_sources = source_identities()
        before_objects = {module: self.objects(module)
                          for module in (certificate, *chunks, "OutputProfileBodySource", "Independent")}
        regenerate()
        self.assertEqual(source_identities(), before_sources)
        self.assert_success(build())
        self.assertEqual({module: self.objects(module) for module in before_objects}, before_objects)

        # Same line count isolates each changed line module. Both edits use the
        # production generator/publisher and Lake's authoritative binary input;
        # restoring mtime must not allow the old source binding to survive.
        for changed, affected_chunk in ((original.replace(b"X0", b"Y0"), chunks[0]),
                                        (original.replace(b"X6;\n", b"X6;\r\n"), chunks[3])):
            with self.subTest(chunk=affected_chunk):
                before_objects = {module: self.objects(module) for module in before_objects}
                before_sources = source_identities()
                stat = source.stat()
                source.write_bytes(changed)
                os.utime(source, ns=(stat.st_atime_ns, stat.st_mtime_ns))
                regenerate()
                after_sources = source_identities()
                self.assertNotEqual(after_sources[certificate][0], before_sources[certificate][0])
                self.assertNotEqual(after_sources[affected_chunk][0], before_sources[affected_chunk][0])
                self.assert_success(build())
                self.assertNotEqual(self.objects("OutputProfileBodySource")[".olean"][0],
                                    before_objects["OutputProfileBodySource"][".olean"][0])
                self.assertNotEqual(self.objects(certificate)[".olean"][0],
                                    before_objects[certificate][".olean"][0])
                for module in (*chunks, "Independent"):
                    if module != affected_chunk:
                        self.assertEqual(self.objects(module), before_objects[module], module)
                        if module in chunks:
                            self.assertEqual(after_sources[module], before_sources[module], module)
                audit()
                source.write_bytes(original)
                regenerate()
                self.assert_success(build())


if __name__ == "__main__":
    unittest.main()
