"""Adversarial compiler-source inputs for the untrusted certificate generator."""

import importlib.util
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import unittest

from scripts.check_lean import CANDIDATES

ROOT = Path(__file__).resolve().parents[1]
EMBEDDED = ("silver_profile.ads", "silver_profile.adb", "silver_output_profile.ads",
            "silver_output_profile.adb", "silver_output_lexical.ads", "silver_output_lexical.adb",
            "silver_io.ads", "silver_io.adb",
            "silver_output_libc.ads", "silver_arguments.ads", "silver_arguments.adb",
            "silver_runtime.ads")
CERTIFICATE_MODULES = (
    "ProfileSpecCertificate", "ProfileBodyCertificate",
    "OutputSpecCertificate", "OutputBodyCertificate",
    "OutputLexicalSpecCertificate", "OutputLexicalBodyCertificate",
    "IOSpecCertificate", "IOBodyCertificate", "OutputLibcCertificate",
    "ArgumentsSpecCertificate", "ArgumentsBodyCertificate", "RuntimeSpecCertificate",
)
SPEC = importlib.util.spec_from_file_location(
    "silver_source_certificate", ROOT / "proof" / "generate_source_certificate.py")
assert SPEC is not None and SPEC.loader is not None
GENERATOR = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(GENERATOR)


class CompilerSourcePolicyTests(unittest.TestCase):
    def test_embedded_source_lists_and_lake_dependencies_agree(self):
        facade = (ROOT / "proof/Silver/AuthoritativeSource.lean").read_text()
        modules = re.findall(r'^import Silver\.(\w+Source)$', facade, re.MULTILINE)
        self.assertEqual(len(modules), len(EMBEDDED))
        bindings = []
        source_modules = {}
        for module in modules:
            authoritative = (ROOT / "proof/Silver" / f"{module}.lean").read_text()
            local = re.findall(
                r'^def (\w+) : String := include_str "\.\./\.\./src/([^"/]+)"$',
                authoritative, re.MULTILINE)
            self.assertEqual(len(local), 1)
            bindings.extend(local)
            source_modules[local[0][1]] = module
        self.assertEqual(len(bindings), len(EMBEDDED))
        self.assertEqual({filename for _name, filename in bindings}, set(EMBEDDED))
        self.assertEqual(dict(bindings),
                         {name: filename for filename, name, _prefix in GENERATOR.SOURCE_BINDINGS})
        self.assertEqual(len(GENERATOR.SOURCE_BINDINGS), len(bindings))
        self.assertEqual(CANDIDATES, {
            Path("Silver") / f"{module}.lean": filename
            for filename, module in zip(EMBEDDED, CERTIFICATE_MODULES, strict=True)
        })

        lake = (ROOT / "proof/lakefile.lean").read_text()
        inputs = re.findall(
            r'^input_file (\w+) where\s+path := "\.\./src/([^"/]+)"\s+text := false',
            lake, re.MULTILINE)
        self.assertEqual(len(inputs), len(EMBEDDED))
        self.assertEqual({filename for _name, filename in inputs}, set(EMBEDDED))
        libraries = re.findall(
            r'^lean_lib (\w+) where\s+roots := #\[\]\s+'
            r'globs := #\[\.one `Silver\.(\w+)\]\s+needs := #\[(\w+)\]',
            lake, re.MULTILINE)
        self.assertEqual(len(libraries), len(inputs))
        self.assertEqual({module: need for _library, module, need in libraries},
                         {source_modules[filename]: name for name, filename in inputs})
        # Exact library ownership must follow the umbrella (Lake searches in
        # reverse declaration order), and the umbrella has no global needs.
        umbrella = lake.index("lean_lib Silver\n")
        for library, _module, _need in libraries:
            self.assertGreater(lake.index(f"lean_lib {library} where"), umbrella)
        for filename, binding, _prefix in GENERATOR.SOURCE_BINDINGS:
            module = binding[0].upper() + binding[1:] + "Source"
            self.assertEqual(source_modules[filename], module)

    def test_all_bytes_have_the_explicit_compiler_alphabet(self):
        allowed = {9, 10, 13, *range(32, 127)}
        for byte in range(256):
            with self.subTest(byte=byte):
                if byte in allowed:
                    GENERATOR.validate_source_bytes(bytes([byte]), "probe")
                else:
                    with self.assertRaisesRegex(ValueError, "unsupported compiler-source byte"):
                        GENERATOR.validate_source_bytes(bytes([byte]), "probe")

    def test_hidden_declarations_fail_before_certificate_generation(self):
        declaration = 'function "=" (L, R : Character) return Boolean is (True);'
        for separator in ("\v", "\f", "\x85", "\u2028", "\u2029", "\x00"):
            with self.subTest(separator=repr(separator)):
                source = "-- hidden" + separator + declaration + "\n"
                with self.assertRaisesRegex(ValueError, "unsupported compiler-source byte"):
                    GENERATOR.generate(source, "profileBody", "bodyTokens")

    def test_authoritative_bindings_are_not_generated(self):
        candidate = "\n".join(GENERATOR.generate(
            "-- ordinary comment\n", "profileBody", "bodyTokens"))
        self.assertNotIn("include_str", candidate)
        self.assertNotIn("def profileBody", candidate)
        self.assertIn("= profileBody", candidate)
        for filename, binding, _prefix in GENERATOR.SOURCE_BINDINGS:
            module = binding[0].upper() + binding[1:] + "Source"
            authoritative = (ROOT / "proof/Silver" / f"{module}.lean").read_text()
            self.assertIn(f'include_str "../../src/{filename}"', authoritative)

    def test_unsupported_literal_syntax_cannot_hide_declarations(self):
        bad = [
            'S : String := %--%; function Hidden return Boolean is (True);',
            'C : Character := Character\'(\'"\'); function Hidden return Boolean is (True);',
        ]
        for source in bad:
            with self.subTest(source=source):
                with self.assertRaisesRegex(ValueError, "outside the compiler fragment"):
                    GENERATOR.generate(source, "profileBody", "bodyTokens")
        # Percent characters in ordinary literals and comments retain meaning.
        self.assertEqual(GENERATOR.lex_candidate('-- %--%'), [])
        self.assertEqual(GENERATOR.lex_candidate('"%--%"'), ['"%--%"'])
        self.assertEqual(GENERATOR.lex_candidate("'%'"), ["'%'"])

    def test_checked_in_certificates_equal_regeneration(self):
        with tempfile.TemporaryDirectory(prefix="silver-certificate-parity-") as temporary:
            workspace = Path(temporary)
            (workspace / "src").symlink_to(ROOT / "src", target_is_directory=True)
            for source, module in zip(EMBEDDED, CERTIFICATE_MODULES, strict=True):
                with self.subTest(source=source):
                    candidate = workspace / "proof" / "Silver" / f"{module}.lean"
                    subprocess.run(
                        [sys.executable, str(ROOT / "proof/generate_source_certificate.py"),
                         "--source", source, "--output", str(candidate)],
                        check=True, capture_output=True, text=True,
                    )
                    checked_in = ROOT / "proof" / "Silver" / f"{module}.lean"
                    self.assertTrue(candidate.read_bytes() == checked_in.read_bytes(),
                                    f"{module} differs from regenerated source certificate")

    def test_current_compiler_sources_satisfy_byte_policy(self):
        for filename in EMBEDDED:
            with self.subTest(filename=filename):
                GENERATOR.validate_source_bytes((ROOT / "src" / filename).read_bytes(), filename)


if __name__ == "__main__":
    unittest.main()
