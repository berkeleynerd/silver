"""Adversarial compiler-source inputs for the untrusted certificate generator."""

import importlib.util
from pathlib import Path
import unittest

ROOT = Path(__file__).resolve().parents[1]
SPEC = importlib.util.spec_from_file_location(
    "silver_source_certificate", ROOT / "proof" / "generate_source_certificate.py")
assert SPEC is not None and SPEC.loader is not None
GENERATOR = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(GENERATOR)


class CompilerSourcePolicyTests(unittest.TestCase):
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
        authoritative = (ROOT / "proof" / "Silver" / "AuthoritativeSource.lean").read_text()
        self.assertIn('include_str "../../src/silver_profile.ads"', authoritative)
        self.assertIn('include_str "../../src/silver_profile.adb"', authoritative)

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

    def test_current_compiler_sources_satisfy_byte_policy(self):
        for filename in ("silver_profile.ads", "silver_profile.adb"):
            with self.subTest(filename=filename):
                GENERATOR.validate_source_bytes((ROOT / "src" / filename).read_bytes(), filename)


if __name__ == "__main__":
    unittest.main()
