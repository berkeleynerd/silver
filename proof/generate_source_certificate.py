#!/usr/bin/env python3
"""Generate candidate source-token certificates; Lean checks every candidate.

This script is a proof-artifact generator, not compiler implementation or a
trusted lexer. Each generated per-source module proves its candidate token list
equals the Lean lexer result and reconstruction equals the authoritative
include_str source. The handwritten SourceCertificates.lean facade imports
the independent modules. Incorrect generation therefore fails kernel checking.
"""

import argparse
import hashlib
import json
from pathlib import Path

# Large flattened lists exceed elaborator conversion depth with `rfl`.
# The existing explicit-witness helper checks the same equality in the kernel;
# preserve smaller certificates so their checked objects remain reusable.
_RFL_TOKEN_LIMIT = 32_768
OUTPUT_BODY_LINE_MODULES = tuple(f"OutputBodyLines{index}" for index in range(8))

SOURCE_BINDINGS = (
    ("silver_function_bindings.ads", "functionBindingsSpec", "functionBindingsSpecTokens"),
    ("silver_function_bindings.adb", "functionBindingsBody", "functionBindingsBodyTokens"),
    ("silver_array_bindings.ads", "arrayBindingsSpec", "arrayBindingsSpecTokens"),
    ("silver_array_bindings.adb", "arrayBindingsBody", "arrayBindingsBodyTokens"),
    ("silver_image_model.ads", "imageModelSpec", "imageModelSpecTokens"),
    ("silver_image_model.adb", "imageModelBody", "imageModelBodyTokens"),
    ("silver_image_model_templates.ads", "imageModelTemplatesSpec", "imageModelTemplatesSpecTokens"),
    ("silver_image_model_templates.adb", "imageModelTemplatesBody", "imageModelTemplatesBodyTokens"),

    ("silver_scalar_expressions.ads", "scalarExpressionSpec", "scalarExpressionSpecTokens"),
    ("silver_scalar_expressions.adb", "scalarExpressionBody", "scalarExpressionBodyTokens"),
    ("silver_scalars.ads", "scalarsSpec", "scalarsSpecTokens"),
    ("silver_scalar_literals.ads", "scalarLiteralSpec", "scalarLiteralSpecTokens"),
    ("silver_scalar_literals.adb", "scalarLiteralBody", "scalarLiteralBodyTokens"),
    ("silver_names.ads", "namesSpec", "namesSpecTokens"),
    ("silver_names.adb", "namesBody", "namesBodyTokens"),
    ("silver_path_facts.ads", "pathFactsSpec", "pathFactsSpecTokens"),
    ("silver_integer_literals.ads", "integerLiteralSpec", "integerLiteralSpecTokens"),
    ("silver_integer_literals.adb", "integerLiteralBody", "integerLiteralBodyTokens"),
    ("silver_arguments.ads", "argumentsSpec", "argumentsSpecTokens"),
    ("silver_arguments.adb", "argumentsBody", "argumentsBodyTokens"),
    ("silver_runtime.ads", "runtimeSpec", "runtimeSpecTokens"),
    ("silver_profile.ads", "profileSpec", "specTokens"),
    ("silver_profile.adb", "profileBody", "bodyTokens"),
    ("silver_output_profile.ads", "outputProfileSpec", "outputSpecTokens"),
    ("silver_output_profile.adb", "outputProfileBody", "outputBodyTokens"),
    ("silver_output_lexical.ads", "outputLexicalSpec", "outputLexicalSpecTokens"),
    ("silver_output_lexical.adb", "outputLexicalBody", "outputLexicalBodyTokens"),
    ("silver_io.ads", "ioSpec", "ioSpecTokens"),
    ("silver_io.adb", "ioBody", "ioBodyTokens"),
    ("silver_output_libc.ads", "outputLibcSpec", "outputLibcTokens"),
)


def literal(text: str) -> str:
    return json.dumps(text, ensure_ascii=False)


def tokens_literal(tokens: list[str]) -> str:
    return "[" + ", ".join(map(literal, tokens)) + "]"


def characters_literal(text: str) -> str:
    escapes = {"\\": "\\\\", "'": "\\'", "\n": "\\n", "\r": "\\r", "\t": "\\t"}
    return "[" + ", ".join("'" + escapes.get(char, char) + "'" for char in text) + "]"


def lex_candidate(line: str) -> list[str]:
    tokens: list[str] = []
    position = 0
    while position < len(line):
        char = line[position]
        if char in " \t\r\n":
            position += 1
        elif line.startswith("--", position):
            position += 2
            while position < len(line) and line[position] not in "\r\n":
                position += 1
        elif char == '"':
            start = position
            position += 1
            while position < len(line):
                if line[position] in "\r\n":
                    raise ValueError("physical line terminator inside string literal")
                if line.startswith('""', position):
                    position += 2
                elif line[position] == '"':
                    position += 1
                    tokens.append(line[start:position])
                    break
                else:
                    position += 1
            else:
                raise ValueError("unterminated string literal")
        elif char == "'" and position + 2 < len(line) and line[position + 2] == "'":
            if line[position + 1] in "\r\n":
                raise ValueError("physical line terminator inside character literal")
            if line[position + 1] == "(":
                raise ValueError("ambiguous qualified-character syntax outside the compiler fragment")
            tokens.append(line[position:position + 3])
            position += 3
        elif char == "%":
            raise ValueError("percent-delimited literals outside the compiler fragment")
        elif char.isascii() and (char.isalnum() or char == "_"):
            start = position
            while position < len(line) and line[position].isascii() and (
                line[position].isalnum() or line[position] == "_"
            ):
                position += 1
            tokens.append(line[start:position].lower())
        elif line[position:position + 2] in (":=", "=>", "<=", ">=", "/=", ".."):
            tokens.append(line[position:position + 2])
            position += 2
        else:
            tokens.append(char)
            position += 1
    return tokens


def validate_source_bytes(source: bytes, filename: str) -> None:
    """Reject unsupported compiler source before decoding or tokenization.

    Lean independently enforces this alphabet in every lexLine certificate.
    The complete reviewed token shape separately rules out alternate literals,
    declarations, and binding changes even when all their bytes are ASCII.
    """
    for offset, byte in enumerate(source):
        if byte not in (9, 10, 13) and not 32 <= byte <= 126:
            raise ValueError(f"{filename}: unsupported compiler-source byte 0x{byte:02x} at offset {offset}")


def generate_parts(source: str, profile: str, prefix: str, *,
                   line_names: list[str] | None = None) -> tuple[list[list[str]], list[str]]:
    validate_source_bytes(source.encode("utf-8"), profile)
    output: list[str] = []
    declarations: list[list[str]] = []
    names: list[str] = []
    all_tokens: list[str] = []
    # split preserves a final empty chunk, hence exact final newline presence.
    lines = source.split("\n")
    if line_names is not None and len(line_names) != len(lines):
        raise ValueError("line names must account for every source occurrence")
    for index, line in enumerate(lines):
        name = line_names[index] if line_names is not None else f"{prefix}_line_{index}"
        names.append(name)
        tokens = lex_candidate(line)
        all_tokens.extend(tokens)
        declarations.append([
            f"def {name} : LineCertificate where",
            f"  text := {literal(line)}",
            f"  tokens := {tokens_literal(tokens)}",
            "  correct := by decide +kernel",
            "  noNewline := by decide +kernel",
            "",
        ])
    def reconstruction(start: int, end: int) -> str:
        name = f"{prefix}_block_{start}_{end}"
        if end == start + 1:
            output.extend([
                f"def {name} : ReconstructionCertificate :=",
                f"  ReconstructionCertificate.single {names[start]}",
                "",
            ])
        else:
            middle = (start + end) // 2
            left = reconstruction(start, middle)
            right = reconstruction(middle, end)
            text = "\n".join(lines[start:end])
            # Large joins check flat character-list equality witnesses.
            # Give only these declarations a bounded, size-based recursion
            # budget; the kernel still checks the complete equality. Keep
            # smaller certificates unchanged so their native caches remain
            # reusable when this implementation source grows.
            if len(text) > 32_768:
                depth = 100_000 * ((len(text) + 32_767) // 32_768)
                output.append(f"set_option maxRecDepth {depth} in")
            output.extend([
                f"def {name} : ReconstructionCertificate :=",
                f"  ReconstructionCertificate.join {left} {right}",
                f"    {literal(text)}",
                f"    (by kernel_exact (string_join_ofList {characters_literal(chr(10).join(lines[start:middle]))}",
                f"      {characters_literal(chr(10).join(lines[middle:end]))}))",
                "",
            ])
        return name

    tree = reconstruction(0, len(lines))
    values_proof = ("rfl" if len(all_tokens) <= _RFL_TOKEN_LIMIT
                    else f"kernel_exact (Eq.refl {prefix})")
    output.extend([
        f"def {prefix}_certificates : List LineCertificate :=",
        f"  {tree}.lines",
        "",
        f"def {prefix} : Tokens :=",
        "  " + tokens_literal(all_tokens),
        "",
        f"theorem {prefix}_source :",
        f'    String.intercalate "\\n" ({prefix}_certificates.map (·.text)) = {profile} := by',
        f"  exact {tree}.correct",
        "",
        f"theorem {prefix}_values :",
        f"    {prefix}_certificates.flatMap (·.tokens) = {prefix} := by {values_proof}",
        "",
        f"theorem {prefix}_correct : lex {profile} = some {prefix} := by",
        f"  rw [← {prefix}_source, reconstructed_source_lex {prefix}_certificates",
        f"    {tree}.nonempty]",
        f"  rw [{prefix}_values]",
        "",
    ])
    return declarations, output


def generate_output_body_parts(source: str, profile: str,
                               prefix: str) -> tuple[list[list[list[str]]], list[str]]:
    """Share exact line texts in fixed buckets, retaining every ordered occurrence.

    Hashes select names and placement only. Lean still checks every literal,
    candidate token list, newline condition and reconstruction equality.
    """
    validate_source_bytes(source.encode("utf-8"), profile)
    texts: dict[str, str] = {}
    digests: list[str] = []
    for line in source.split("\n"):
        digest = hashlib.sha256(line.encode("ascii")).hexdigest()
        if digest in texts and texts[digest] != line:
            raise ValueError("different source lines have the same SHA256 identifier")
        texts[digest] = line
        digests.append(digest)
    names = [f"{prefix}_line_{digest}" for digest in digests]
    declarations, reconstruction = generate_parts(source, profile, prefix, line_names=names)
    unique = dict(zip(digests, declarations, strict=True))
    chunks: list[list[list[str]]] = [[] for _ in OUTPUT_BODY_LINE_MODULES]
    for digest, declaration in sorted(unique.items()):
        chunks[int(digest[:2], 16) % len(chunks)].append(declaration)
    return chunks, reconstruction


def generate(source: str, profile: str, prefix: str) -> list[str]:
    declarations, reconstruction = generate_parts(source, profile, prefix)
    return [line for declaration in declarations for line in declaration] + reconstruction


def module_header(binding_module: str | None = None,
                  line_modules: tuple[str, ...] = ()) -> list[str]:
    return [
        "module",
        "",
        "public import Silver.SourceLexer",
        "public meta import Silver.CertificateWitness",
        *([f"public import Silver.{binding_module}"] if binding_module else []),
        *(f"public import Silver.{module}" for module in line_modules),
        "",
        "@[expose] public section",
        "",
        "/-! Generated by proof/generate_source_certificate.py.",
        "Every candidate is checked by Lean's kernel. Do not bypass these proofs.",
        "Source reconstruction includes every original byte and final newline.",
        "-/",
        "",
        "set_option maxRecDepth 100000",
        "set_option maxHeartbeats 10000000",
        "",
        "namespace Silver.Source",
        "",
    ]


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", required=True, type=Path,
                        help="candidate module in an isolated proof workspace; output body also emits "
                             "eight sibling line modules with the same suffixes")
    parser.add_argument("--source", required=True, choices=[entry[0] for entry in SOURCE_BINDINGS],
                        help="emit one independently checked source certificate module")
    arguments = parser.parse_args()
    proof = Path(__file__).resolve().parent
    repository = proof.parent
    destination = arguments.output.absolute()
    if destination.resolve().is_relative_to(proof):
        parser.error("candidate output must be outside the shared proof source tree")
    if (destination.parent / "../../src").resolve() != (repository / "src").resolve():
        parser.error("candidate ../../src must resolve to the authoritative source directory")
    filename, binding, prefix = next(entry for entry in SOURCE_BINDINGS
                                     if entry[0] == arguments.source)
    binding_module = binding[0].upper() + binding[1:] + "Source"
    # Read bytes directly: text-mode newline translation would lose CRs.
    source_bytes = (repository / "src" / filename).read_bytes()
    validate_source_bytes(source_bytes, filename)
    line_modules = OUTPUT_BODY_LINE_MODULES if filename == "silver_output_profile.adb" else ()
    if line_modules:
        chunks, reconstruction = generate_output_body_parts(source_bytes.decode("ascii"), binding, prefix)
        declarations = []
    else:
        declarations, reconstruction = generate_parts(source_bytes.decode("ascii"), binding, prefix)
        chunks = []
    output = module_header(binding_module, line_modules)
    if not line_modules:
        output.extend(line for declaration in declarations for line in declaration)
    output.extend(reconstruction)
    outputs = {destination: output}
    # Output-body leaves use content identities; occurrence order remains in the
    # unchanged balanced reconstruction, including repeated and final empty lines.
    for module, chunk in zip(line_modules, chunks, strict=True):
        outputs[destination.with_name(module + "".join(destination.suffixes))] = (
            module_header() + [line for declaration in chunk for line in declaration])
    destination.parent.mkdir(parents=True, exist_ok=True)
    for path, contents in outputs.items():
        path.write_text("\n".join([*contents, "end Silver.Source"]) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
