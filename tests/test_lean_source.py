"""Adversarial compiler-source inputs for the untrusted certificate generator."""

import hashlib
import importlib.util
import json
from pathlib import Path
import re
import subprocess
import sys
import tempfile
import unittest
from unittest import mock

from scripts.bootstrap_lean import lean_environment
from scripts.check_lean import CANDIDATES, CERTIFICATE_ROOTS, OUTPUT_BODY_LINES
from scripts.platforms import native_layout

ROOT = Path(__file__).resolve().parents[1]
EMBEDDED = ("silver_application_units.ads", "silver_application_units.adb",
            "silver_package_bindings.ads", "silver_package_bindings.adb",
            "silver_profile.ads", "silver_profile.adb", "silver_output_profile.ads",
            "silver_output_profile.adb", "silver_output_lexical.ads", "silver_output_lexical.adb",
            "silver_io.ads", "silver_io.adb",
            "silver_output_libc.ads", "silver_arguments.ads", "silver_arguments.adb",
            "silver_runtime.ads", "silver_integer_literals.ads", "silver_integer_literals.adb",
            "silver_path_facts.ads", "silver_names.ads", "silver_names.adb",
            "silver_scalar_expressions.ads", "silver_scalar_expressions.adb",
            "silver_array_bindings.ads", "silver_array_bindings.adb",
            "silver_function_bindings.ads", "silver_function_bindings.adb",
            "silver_procedure_bindings.ads", "silver_procedure_bindings.adb", "silver_scalars.ads",
            "silver_scalar_literals.ads", "silver_scalar_literals.adb",
            "silver_image_model.ads", "silver_image_model.adb",
            "silver_image_model_templates.ads", "silver_image_model_templates.adb")
CERTIFICATE_MODULES = (
    "ApplicationUnitsSpecCertificate", "ApplicationUnitsBodyCertificate",
    "PackageBindingsSpecCertificate", "PackageBindingsBodyCertificate",
    "ProfileSpecCertificate", "ProfileBodyCertificate",
    "OutputSpecCertificate", "OutputBodyCertificate",
    "OutputLexicalSpecCertificate", "OutputLexicalBodyCertificate",
    "IOSpecCertificate", "IOBodyCertificate", "OutputLibcCertificate",
    "ArgumentsSpecCertificate", "ArgumentsBodyCertificate", "RuntimeSpecCertificate",
    "IntegerLiteralSpecCertificate", "IntegerLiteralBodyCertificate", "PathFactsSpecCertificate",
    "NamesSpecCertificate", "NamesBodyCertificate",
    "ScalarExpressionSpecCertificate", "ScalarExpressionBodyCertificate",
    "ArrayBindingsSpecCertificate", "ArrayBindingsBodyCertificate",
    "FunctionBindingsSpecCertificate", "FunctionBindingsBodyCertificate",
    "ProcedureBindingsSpecCertificate", "ProcedureBindingsBodyCertificate", "ScalarsSpecCertificate",
    "ScalarLiteralSpecCertificate", "ScalarLiteralBodyCertificate",
    "ImageModelSpecCertificate", "ImageModelBodyCertificate",
    "ImageModelTemplatesSpecCertificate", "ImageModelTemplatesBodyCertificate",
)
# These constants have dedicated checked rendering or capture proofs. Their
# byte dependencies remain explicit and equally pinned.
EXTRA_SOURCE_BINDINGS = {
    "ImageFilesSpecSource": ("imageFilesSpec", "silver_image_files.ads"),
    "ImageFilesBodySource": ("imageFilesBody", "silver_image_files.adb"),
    "LengthIntervalsSpecSource": ("lengthIntervalsSpec", "silver_length_intervals.ads"),
    "LengthIntervalsBodySource": ("lengthIntervalsBody", "silver_length_intervals.adb"),
    "IntegerImageSpecSource": ("integerImageSpec", "silver_integer_image.ads"),
    "ImageTheorySpecSource": ("imageTheorySpec", "silver_image_theory.ads"),
}
SPEC = importlib.util.spec_from_file_location(
    "silver_source_certificate", ROOT / "proof" / "generate_source_certificate.py")
assert SPEC is not None and SPEC.loader is not None
GENERATOR = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(GENERATOR)


class CompilerSourcePolicyTests(unittest.TestCase):
    def test_embedded_source_lists_and_lake_dependencies_agree(self):
        facade = (ROOT / "proof/Silver/AuthoritativeSource.lean").read_text()
        modules = re.findall(r'^public import Silver\.(\w+Source)$', facade, re.MULTILINE)
        all_files = set(EMBEDDED) | {filename for _binding, filename in EXTRA_SOURCE_BINDINGS.values()}
        self.assertEqual(len(modules), len(all_files))
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
        self.assertEqual(len(bindings), len(all_files))
        self.assertEqual({filename for _name, filename in bindings}, all_files)
        self.assertEqual(dict(bindings),
                         {name: filename for filename, name, _prefix in GENERATOR.SOURCE_BINDINGS}
                         | dict(EXTRA_SOURCE_BINDINGS.values()))
        self.assertEqual(len(GENERATOR.SOURCE_BINDINGS) + len(EXTRA_SOURCE_BINDINGS), len(bindings))
        self.assertEqual(CERTIFICATE_ROOTS, {
            Path("Silver") / f"{module}.lean": filename
            for filename, module in zip(EMBEDDED, CERTIFICATE_MODULES, strict=True)
        })
        self.assertEqual(OUTPUT_BODY_LINES, tuple(
            Path(f"Silver/OutputBodyLines{index}.lean") for index in range(8)))
        self.assertEqual(GENERATOR.OUTPUT_BODY_LINE_MODULES,
                         tuple(path.stem for path in OUTPUT_BODY_LINES))
        self.assertEqual(CANDIDATES, CERTIFICATE_ROOTS | {
            path: "silver_output_profile.adb" for path in OUTPUT_BODY_LINES})

        lake = (ROOT / "proof/lakefile.lean").read_text()
        inputs = re.findall(
            r'^input_file (\w+) where\s+path := "\.\./src/([^"/]+)"\s+text := false',
            lake, re.MULTILINE)
        self.assertEqual(len(inputs), len(all_files))
        self.assertEqual({filename for _name, filename in inputs}, all_files)
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

    def test_include_str_is_confined_to_the_source_bindings(self):
        proof = ROOT / "proof"
        expected = {
            Path("Silver") / f"{binding[0].upper() + binding[1:]}Source.lean": 1
            for _filename, binding, _prefix in GENERATOR.SOURCE_BINDINGS
        }
        expected.update({Path("Silver") / f"{module}.lean": 1 for module in EXTRA_SOURCE_BINDINGS})
        actual = {}
        for path in proof.rglob("*.lean"):
            if ".lake" in path.parts:
                continue
            # Match the macro and its literal, not prose mentions in comments.
            count = len(re.findall(r'\binclude_str\s*"', path.read_text()))
            if count:
                actual[path.relative_to(proof)] = count
        self.assertEqual(len(expected), len(EMBEDDED) + len(EXTRA_SOURCE_BINDINGS))
        self.assertEqual(actual, expected)

    def test_only_audit_roots_use_legacy_full_imports(self):
        # Ordinary modules consume public interfaces to avoid rebuilding after
        # private proof changes. Legacy audit roots deliberately load the full
        # environment, including private declarations and their assumptions.
        proof = ROOT / "proof"
        legacy = {
            path.relative_to(proof)
            for path in proof.rglob("*.lean")
            if ".lake" not in path.parts and path.name != "lakefile.lean"
            and not re.search(r"^module\s*$", path.read_text(), re.MULTILINE)
        }
        self.assertEqual(legacy, {Path("Silver/Audit.lean"), Path("Silver/AxiomAudit.lean")})

    def project_import_closure(self, *roots):
        # Include ordinary, public, meta and import-all dependencies. Guard the
        # production graph rather than an exact spelling of direct imports.
        proof = ROOT / "proof"
        pending = list(roots)
        closure = set()
        while pending:
            module = pending.pop()
            if module in closure:
                continue
            closure.add(module)
            path = proof.joinpath(*module.split(".")).with_suffix(".lean")
            pending.extend(re.findall(
                r"^(?:public )?(?:meta )?import(?: all)? (Silver(?:\.\w+)*)\b",
                path.read_text(), re.MULTILINE))
        return closure

    def test_compose_candidate_has_no_authoritative_source_dependencies(self):
        closure = self.project_import_closure("Silver.ComposeSourceCandidate")
        self.assertIn("Silver.ReviewedOutputShape", closure)
        for module in sorted(closure):
            with self.subTest(module=module):
                self.assertFalse(module.endswith("Certificate"))
                self.assertNotIn(module, {"Silver.Source", "Silver.AuthoritativeSource",
                                          "Silver.SourceBridge", "Silver.OutputSourceBridge",
                                          "Silver.ComposeSourceChecks", "Silver.ComposeSourceBridge"})
                path = (ROOT / "proof").joinpath(*module.split(".")).with_suffix(".lean")
                self.assertNotRegex(path.read_text(), r'\binclude_str\s*"')

    def test_compose_source_checks_retain_authoritative_dependencies(self):
        closure = self.project_import_closure("Silver.ComposeSourceChecks")
        self.assertIn("Silver.ComposeSourceCandidate", closure)
        # The adapter uses the complete actual-output shape theorem, including
        # its lexical/runtime/profile source closure. Pin-only checks cannot
        # replace that source-certified boundary.
        authoritative = self.project_import_closure("Silver.OutputSourceBridge")
        self.assertLessEqual(authoritative, closure)

        for required in ("OutputSpecCertificate", "OutputBodyCertificate",
                         "OutputProfileSpecSource", "OutputProfileBodySource",
                         "OutputLexicalSpecCertificate", "OutputLexicalBodyCertificate",
                         "IOSpecCertificate", "IOBodyCertificate", "OutputLibcCertificate",
                         "ProfileSpecCertificate", "ProfileBodyCertificate"):
            with self.subTest(required=required):
                self.assertIn("Silver." + required, closure)
        for unrelated in ("PathFactsSpecCertificate", "PathFactsSpecSource"):
            with self.subTest(unrelated=unrelated):
                self.assertNotIn("Silver." + unrelated, closure)

    def test_procedure_name_checks_join_candidates_to_authoritative_source(self):
        candidate = self.project_import_closure("Silver.ProcedureNameSourceCandidate")
        self.assertIn("Silver.ReviewedOutputShape", candidate)
        self.assertIn("Silver.ProcedureNameSource", candidate)
        self.assertFalse(any(module.endswith("Certificate") for module in candidate))
        self.assertNotIn("Silver.OutputSourceBridge", candidate)
        actual = self.project_import_closure("Silver.ProcedureNameSourceChecks")
        self.assertLessEqual(candidate, actual)
        self.assertLessEqual(self.project_import_closure("Silver.OutputSourceBridge"), actual)

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
            for relative in OUTPUT_BODY_LINES:
                self.assertEqual((workspace / "proof" / relative).read_bytes(),
                                 (ROOT / "proof" / relative).read_bytes())

    def test_output_body_split_preserves_every_line_proof_and_ordered_reconstruction(self):
        source = (ROOT / "src/silver_output_profile.adb").read_bytes().decode("ascii")
        declarations, reconstruction = GENERATOR.generate_parts(
            source, "outputProfileBody", "outputBodyTokens", compact_joins=True)
        lines = source.split("\n")
        self.assertEqual(len(declarations), len(lines))
        digests = [hashlib.sha256(line.encode("ascii")).hexdigest() for line in lines]
        expected = {}
        for digest, declaration in zip(digests, declarations, strict=True):
            expected[digest] = [f"def outputBodyTokens_line_{digest} : LineCertificate where",
                                *declaration[1:]]
        header = "\n".join(GENERATOR.module_header()) + "\n"
        recovered = []
        for index, relative in enumerate(OUTPUT_BODY_LINES):
            chunk = (ROOT / "proof" / relative).read_text()
            selected = [declaration for digest, declaration in sorted(expected.items())
                        if int(digest[:2], 16) % 8 == index]
            body = "\n".join(line for declaration in selected for line in declaration) + "\n"
            self.assertEqual(chunk, header + body + "end Silver.Source\n")
            recovered.extend(selected)
        self.assertEqual(len(recovered), len(set(lines)))
        # Only single-leaf references change. Compact witnesses retain the same
        # balanced tree and final source/token/lexer statements.
        for index, line in enumerate(reconstruction):
            match = re.fullmatch(r"  ReconstructionCertificate.single outputBodyTokens_line_(\d+)", line)
            if match:
                reconstruction[index] = "  ReconstructionCertificate.single outputBodyTokens_line_" + digests[int(match[1])]
        aggregator = (ROOT / "proof/Silver/OutputBodyCertificate.lean").read_text()
        expected_header = GENERATOR.module_header("OutputProfileBodySource", GENERATOR.OUTPUT_BODY_LINE_MODULES)
        self.assertEqual(aggregator, "\n".join([
            *expected_header, *reconstruction, "end Silver.Source", ""]))

    def test_output_body_content_names_preserve_exact_texts_and_every_occurrence(self):
        for source in ("", "\n", "\n\n", "X;", "X;\n", "X;\r\n",
                       "X;\r\nX;\nX;\r\n", "X;\nX;\nY;\nX;"):
            with self.subTest(source=source):
                chunks, reconstruction = GENERATOR.generate_output_body_parts(
                    source, "outputProfileBody", "outputBodyTokens")
                self.assertEqual(len(chunks), 8)
                texts = {}
                for bucket, chunk in enumerate(chunks):
                    names = []
                    for declaration in chunk:
                        text = json.loads(declaration[1].removeprefix("  text := "))
                        digest = hashlib.sha256(text.encode("ascii")).hexdigest()
                        name = "outputBodyTokens_line_" + digest
                        self.assertEqual(declaration[0], f"def {name} : LineCertificate where")
                        self.assertEqual(int(digest[:2], 16) % 8, bucket)
                        self.assertEqual(declaration[3:5], ["  correct := by decide +kernel",
                                                           "  noNewline := by decide +kernel"])
                        self.assertNotIn(name, texts)
                        texts[name] = text
                        names.append(name)
                    self.assertEqual(names, sorted(names))
                self.assertEqual(set(texts.values()), set(source.split("\n")))
                occurrences = [line.removeprefix("  ReconstructionCertificate.single ")
                               for line in reconstruction
                               if line.startswith("  ReconstructionCertificate.single ")]
                self.assertEqual([texts[name] for name in occurrences], source.split("\n"))
                self.assertEqual("\n".join(texts[name] for name in occurrences), source)

    def test_output_body_edit_locality_depends_only_on_unique_exact_texts(self):
        original = "X0;\nX1;\nX2;\nX0;\n"
        variants = {
            "noop": original,
            "append": original + "Z;\n",
            "insert_at_old_partition_boundary": original.replace("X2;\n", "Z;\nX2;\n"),
            "delete_unique": original.replace("X1;\n", ""),
            "replace": original.replace("X1;", "Y1;"),
            "reorder": "X2;\nX1;\nX0;\nX0;\n",
            "repeat": original + "X0;\n",
            "delete_repeated_occurrence": original.removeprefix("X0;\n"),
            "crlf": original.replace("X1;\n", "X1;\r\n"),
            "remove_final_newline": original.removesuffix("\n"),
            "empty_source": "",
        }
        before, _ = GENERATOR.generate_output_body_parts(original, "outputProfileBody", "outputBodyTokens")
        for label, changed in variants.items():
            with self.subTest(edit=label):
                after, reconstruction = GENERATOR.generate_output_body_parts(
                    changed, "outputProfileBody", "outputBodyTokens")
                changed_texts = set(original.split("\n")) ^ set(changed.split("\n"))
                expected = {hashlib.sha256(text.encode("ascii")).digest()[0] % 8
                            for text in changed_texts}
                self.assertEqual({index for index, pair in enumerate(zip(before, after, strict=True))
                                  if pair[0] != pair[1]}, expected)
                occurrences = [line for line in reconstruction
                               if line.startswith("  ReconstructionCertificate.single ")]
                self.assertEqual(len(occurrences), len(changed.split("\n")))

    def test_output_body_conflicting_digest_is_rejected(self):
        with mock.patch.object(GENERATOR.hashlib, "sha256") as digest:
            digest.return_value.hexdigest.return_value = "0" * 64
            # Identical lines share safely; distinct texts must fail before output.
            chunks, _ = GENERATOR.generate_output_body_parts("X;\nX;", "outputProfileBody", "outputBodyTokens")
            self.assertEqual(sum(map(len, chunks)), 1)
            with self.assertRaisesRegex(ValueError, "different source lines"):
                GENERATOR.generate_output_body_parts("X;\nY;", "outputProfileBody", "outputBodyTokens")

    def test_current_compiler_sources_satisfy_byte_policy(self):
        for filename in EMBEDDED:
            with self.subTest(filename=filename):
                GENERATOR.validate_source_bytes((ROOT / "src" / filename).read_bytes(), filename)


class NativeCertificateTests(unittest.TestCase):
    def test_generated_certificates_and_witnesses_remain_kernel_checked(self):
        native = native_layout(ROOT)
        lean = native.lean / "bin/lean"
        if not lean.is_file():
            self.skipTest("install pinned native Lean to check generated certificates")
        with tempfile.TemporaryDirectory(prefix="silver certificate checks-") as temporary:
            root = Path(temporary).resolve()
            (root / "Silver").mkdir()
            environment = {**lean_environment(native), "LEAN_PATH": str(root)}

            def compile_file(relative):
                return subprocess.run(
                    [str(lean), "-j1", "-M2048", "-DwarningAsError=true",
                     "-o", str(Path(relative).with_suffix(".olean")), relative],
                    cwd=root, env=environment, text=True, capture_output=True, timeout=60)

            # Compile current sources, not canonical cached helper objects. Only
            # this small dependency chain is needed; all outputs stay temporary.
            for module in ("Lexical", "Admission", "Cursor", "SourceLexer",
                           "CertificateWitness", "CertificateJoinWitness", "AxiomAudit"):
                relative = f"Silver/{module}.lean"
                (root / relative).write_bytes((ROOT / "proof" / relative).read_bytes())
                result = compile_file(relative)
                self.assertEqual(result.returncode, 0, result.stdout + result.stderr)

            prelude = ("module\n\npublic import Silver.SourceLexer\n"
                       "public meta import Silver.CertificateWitness\n"
                       "public meta import Silver.CertificateJoinWitness\n\n"
                       "@[expose] public section\n\n")

            def check(name, body, failure=None):
                relative = f"Silver/Check_{name}.lean"
                (root / relative).write_text(prelude + body + "\n")
                result = compile_file(relative)
                output = result.stdout + result.stderr
                if failure is None:
                    self.assertEqual(result.returncode, 0, output)
                    # A module cannot import the legacy full-environment audit.
                    # Audit the compiled module from a separate legacy driver.
                    driver = f"Silver/Audit_{name}.lean"
                    (root / driver).write_text(
                        f"import Silver.Check_{name}\nimport Silver.AxiomAudit\n\n#silver_audit\n")
                    audit = compile_file(driver)
                    output = audit.stdout + audit.stderr
                    self.assertEqual(audit.returncode, 0, output)
                    self.assertIn("Silver axiom audit passed:", output)
                    self.assertIn("SILVER_MODULE Silver.CertificateWitness", output)
                    self.assertIn("SILVER_MODULE Silver.CertificateJoinWitness", output)
                else:
                    self.assertNotEqual(result.returncode, 0, output)
                    self.assertRegex(output, failure)
                    for suffix in (".olean", ".olean.server", ".olean.private"):
                        self.assertFalse((root / relative).with_suffix(suffix).exists())

            check("witness", "theorem Silver.witness : 2 + 2 = 4 := by\n"
                  "  kernel_exact (Eq.refl (4 : Nat))\n")
            check("false_witness", "theorem Silver.badWitness : 2 + 2 = 5 := by\n"
                  "  kernel_exact (Eq.refl (4 : Nat))\n",
                  r"\(kernel\) declaration type mismatch")

            def generated(source):
                return "\n".join(GENERATOR.generate(
                    source.decode("ascii"), "fixtureSource", "fixtureTokens"))

            def certificate(name, source, candidate, failure=None):
                (root / "input.adb").write_bytes(source)
                check(name, "namespace Silver.Source\n"
                      'def fixtureSource : String := include_str "../input.adb"\n' +
                      candidate + "\nend Silver.Source\n", failure)

            mixed = b'-- marker\r\n\tX := "a""b";\n'
            for name, source in (("empty", b""), ("no_final_lf", b"X;"),
                                 ("mixed_endings", mixed), ("blank_lines", b"\nX;\n\n")):
                with self.subTest(case=name):
                    certificate(name, source, generated(source))

            # Same tokens do not establish byte identity, including CR and the
            # final LF. Keep the candidate unchanged while altering include_str.
            for name, source in (("comment_byte", mixed.replace(b"marker", b"changed")),
                                 ("missing_final_lf", mixed[:-1]),
                                 ("normalized_crlf", mixed.replace(b"\r\n", b"\n"))):
                with self.subTest(case=name):
                    certificate(name, source, generated(mixed), r"(?i)type mismatch")

            source = b"X;\n"
            original = generated(source)
            mutations = (
                ("leaf_token", 'tokens := ["x", ";"]',
                 'tokens := ["wrong", ";"]', r"decide"),
                ("flattened_tokens", 'def fixtureTokens : Tokens :=\n  ["x", ";"]',
                 'def fixtureTokens : Tokens :=\n  ["wrong", ";"]', r"rfl"),
                ("join_witness", GENERATOR.literal("X;\n"), GENERATOR.literal("X;\n!"),
                 r"\(kernel\) declaration type mismatch"),
            )
            for name, before, after, failure in mutations:
                with self.subTest(case=name):
                    self.assertEqual(original.count(before), 1)
                    certificate(name, source, original.replace(before, after, 1), failure)

            # Exercise the large-list proof path on a small, checked fixture.
            with mock.patch.object(GENERATOR, "_RFL_TOKEN_LIMIT", 0):
                explicit_values = generated(source)
            certificate("explicit_values", source, explicit_values)
            before = 'def fixtureTokens : Tokens :=\n  ["x", ";"]'
            after = 'def fixtureTokens : Tokens :=\n  ["wrong", ";"]'
            self.assertEqual(explicit_values.count(before), 1)
            certificate("wrong_explicit_values", source,
                        explicit_values.replace(before, after, 1),
                        r"\(kernel\) declaration type mismatch")

            # The compact tactic constructs the existing character-list theorem;
            # its untrusted strings still have to match the exact kernel goal.
            for name, left, right in (("empty", "", ""),
                                      ("crlf", "-- marker\r", "X;\n"),
                                      ("unicode", "α", "😀")):
                joined = left + "\n" + right
                statement = (f"theorem Silver.compactJoin : {GENERATOR.literal(left)} ++ "
                             f'"\\n" ++ {GENERATOR.literal(right)} = {GENERATOR.literal(joined)} := by\n')
                witness = f"  kernel_join {GENERATOR.literal(left)} {GENERATOR.literal(right)}\n"
                check("compact_join_" + name, statement + witness)
                check("compact_false_goal_" + name,
                      statement.replace(" = " + GENERATOR.literal(joined),
                                        " = " + GENERATOR.literal(joined + "!")) + witness,
                      r"\(kernel\) declaration type mismatch")

            def compact(source):
                return "\n".join(GENERATOR.generate(
                    source.decode("ascii"), "fixtureSource", "fixtureTokens", compact_joins=True))

            for name, source in (("empty", b""), ("no_final_lf", b"X;"),
                                 ("mixed_endings", mixed), ("blank_lines", b"\nX;\n\n")):
                certificate("compact_" + name, source, compact(source))
            for name, source in (("comment_byte", mixed.replace(b"marker", b"changed")),
                                 ("truncated_source", mixed[:-2]),
                                 ("missing_final_lf", mixed[:-1]),
                                 ("normalized_crlf", mixed.replace(b"\r\n", b"\n"))):
                certificate("compact_" + name, source, compact(mixed), r"(?i)type mismatch")
            source = b"X;\nY;\n"
            original = compact(source)
            for name, before, after in (
                    ("wrong_byte", 'kernel_join "Y;" ""', 'kernel_join "Z;" ""'),
                    ("truncated_witness", 'kernel_join "Y;" ""', 'kernel_join "Y" ""'),
                    ("newline_boundary", 'kernel_join "Y;" ""', 'kernel_join "Y;\\n" ""')):
                self.assertEqual(original.count(before), 1)
                certificate("compact_" + name, source, original.replace(before, after, 1),
                            r"\(kernel\) declaration type mismatch")
            with mock.patch.object(GENERATOR, "_RFL_TOKEN_LIMIT", 0):
                compact_values = compact(source)
            certificate("compact_explicit_values", source, compact_values)
            before = 'def fixtureTokens : Tokens :=\n  ["x", ";", "y", ";"]'
            after = 'def fixtureTokens : Tokens :=\n  ["x", ";"]'
            self.assertEqual(compact_values.count(before), 1)
            certificate("compact_missing_tokens", source,
                        compact_values.replace(before, after, 1),
                        r"\(kernel\) declaration type mismatch")

            # Bypass Python's byte validation to exercise the independent Lean
            # alphabet and physical-line restrictions themselves.
            for name, text in (("unsupported_byte", r"\u000b"), ("lf_inside_leaf", r"\n")):
                with self.subTest(case=name):
                    check(name, "open Silver.Source\n"
                          "def Silver.badLine : LineCertificate where\n"
                          f'  text := "{text}"\n'
                          "  tokens := []\n"
                          "  correct := by decide +kernel\n"
                          "  noNewline := by decide +kernel\n", r"decide")


if __name__ == "__main__":
    unittest.main()
