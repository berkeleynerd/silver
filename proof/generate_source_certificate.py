#!/usr/bin/env python3
"""Generate candidate source-token certificates; Lean checks every candidate.

This script is a proof-artifact generator, not compiler implementation or a
trusted lexer. SourceCertificates.lean proves each candidate token list equals
the Lean lexer result and proves reconstruction equals the actual include_str
source. Incorrect generation therefore fails kernel checking.
"""

import argparse
import json
from pathlib import Path

SOURCE_BINDINGS = (
    ("silver_profile.ads", "profileSpec", "specTokens"),
    ("silver_profile.adb", "profileBody", "bodyTokens"),
    ("silver_output_profile.ads", "outputProfileSpec", "outputSpecTokens"),
    ("silver_output_profile.adb", "outputProfileBody", "outputBodyTokens"),
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


def generate(source: str, profile: str, prefix: str) -> list[str]:
    validate_source_bytes(source.encode("utf-8"), profile)
    output: list[str] = []
    names: list[str] = []
    all_tokens: list[str] = []
    # split preserves a final empty chunk, hence exact final newline presence.
    lines = source.split("\n")
    for index, line in enumerate(lines):
        name = f"{prefix}_line_{index}"
        names.append(name)
        tokens = lex_candidate(line)
        all_tokens.extend(tokens)
        output.extend([
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
            output.extend([
                f"def {name} : ReconstructionCertificate :=",
                f"  ReconstructionCertificate.join {left} {right}",
                f"    {literal(text)}",
                f"    (string_join_ofList {characters_literal(chr(10).join(lines[start:middle]))}",
                f"      {characters_literal(chr(10).join(lines[middle:end]))})",
                "",
            ])
        return name

    tree = reconstruction(0, len(lines))
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
        f"    {prefix}_certificates.flatMap (·.tokens) = {prefix} := by rfl",
        "",
        f"theorem {prefix}_correct : lex {profile} = some {prefix} := by",
        f"  rw [← {prefix}_source, reconstructed_source_lex {prefix}_certificates",
        f"    {tree}.nonempty]",
        f"  rw [{prefix}_values]",
        "",
    ])
    return output


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", required=True, type=Path,
                        help="candidate module in an isolated proof workspace")
    parser.add_argument("--source", choices=[entry[0] for entry in SOURCE_BINDINGS],
                        help="emit one independently checked source certificate module")
    arguments = parser.parse_args()
    proof = Path(__file__).resolve().parent
    repository = proof.parent
    destination = arguments.output.absolute()
    if destination.resolve().is_relative_to(proof):
        parser.error("candidate output must be outside the shared proof source tree")
    if (destination.parent / "../../src").resolve() != (repository / "src").resolve():
        parser.error("candidate ../../src must resolve to the authoritative source directory")
    output = [
        "import Silver.SourceLexer",
        "import Silver.AuthoritativeSource",
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
    for filename, profile, prefix in SOURCE_BINDINGS:
        if arguments.source is not None and filename != arguments.source:
            continue
        # Read bytes directly: text-mode newline translation would lose CRs.
        source_bytes = (repository / "src" / filename).read_bytes()
        validate_source_bytes(source_bytes, filename)
        source = source_bytes.decode("ascii")
        output.extend(generate(source, profile, prefix))
    output.append("end Silver.Source")
    destination.parent.mkdir(parents=True, exist_ok=True)
    destination.write_text("\n".join(output) + "\n", encoding="utf-8")


if __name__ == "__main__":
    main()
