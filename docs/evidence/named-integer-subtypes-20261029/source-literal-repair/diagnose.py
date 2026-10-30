#!/usr/bin/env python3
"""Read-only cheap extraction for #286; Lean still checks the actual claims.

Uses the existing untrusted certificate lexer. Header/body selectors mirror
SourceDeclarations.headerEnd, SourceLexer.balanced and
PredicateSourceRequirements.ordinaryFunctions, with unique-result checks.
Does not consume typed renderer output or write proof/source inputs.
"""
from pathlib import Path
import argparse
import difflib
import importlib.util
import json
import re
import subprocess

ROOT = Path(__file__).resolve().parents[4]
spec = importlib.util.spec_from_file_location("certificate_generator", ROOT / "proof/generate_source_certificate.py")
generator = importlib.util.module_from_spec(spec)
spec.loader.exec_module(generator)
lex = generator.lex_candidate
sources = {"spec": lex((ROOT / "src/silver_output_profile.ads").read_text()),
           "body": lex((ROOT / "src/silver_output_profile.adb").read_text())}


def literals(path, baseline=None):
    text = (subprocess.check_output(["git", "show", f"{baseline}:{path}"], cwd=ROOT, text=True)
            if baseline else (ROOT / path).read_text())
    result = {}
    for match in re.finditer(r"^def (\w+) : List String :=\s*", text, re.M):
        if text[match.end():].startswith("["):
            result[match[1]] = json.JSONDecoder().raw_decode(text[match.end():])[0]
    return result


def header_end(tokens, start):
    depth = 0
    for i in range(start, len(tokens)):
        token = tokens[i]
        if depth == 0 and token in ("is", ";"):
            return i
        depth += (token == "(") - (token == ")")
    raise ValueError("missing header terminator")


def unique(values, label):
    assert len(values) == 1, (label, len(values))
    return values[0]


def headers(tokens, name, stop, kind="function"):
    result = []
    for i in range(len(tokens)-1):
        if tokens[i:i+2] == [kind, name]:
            end = header_end(tokens, i+2)
            if tokens[end] == stop:
                result.append(tokens[i+2:end])
    return unique(result, (kind, name, stop))


def block(tokens, name, expression=False):
    result = []
    for i in range(len(tokens)-1):
        if tokens[i:i+2] != ["function", name]:
            continue
        end = header_end(tokens, i+2)
        if tokens[end] != "is":
            continue
        start = end + 1
        if expression:
            assert tokens[start] == "("
            depth = 1
            for j in range(start+1, len(tokens)):
                depth += (tokens[j] == "(") - (tokens[j] == ")")
                if depth == 0:
                    assert tokens[j+1] in (";", "with")
                    result.append(tokens[start:j+1])
                    break
        else:
            for j in range(start, len(tokens)-2):
                if tokens[j:j+3] == ["end", name, ";"]:
                    result.append(tokens[start:j+3])
                    break
    return unique(result, (name, expression))


def show(label, old, actual):
    print(f"{label}: {len(old)} -> {len(actual)} tokens; {'MATCH' if old == actual else 'STALE'}")
    for tag, a, b, c, d in difflib.SequenceMatcher(a=old, b=actual, autojunk=False).get_opcodes():
        if tag != "equal":
            print(f"  {tag} old[{a}:{b}]={json.dumps(old[a:b])} actual[{c}:{d}]={json.dumps(actual[c:d])}")
    return old != actual


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--baseline", help="compare prior literals against current authoritative source")
    args = parser.parse_args()
    owned = {
        "proof/Silver/PredicateBasicSourceCandidate.lean": [("candidateBody", "basic_body", False)],
        "proof/Silver/PredicateLoopCandidate.lean": [("candidateBody", "loop_body", False)],
        "proof/Silver/PredicateAdapterSourceCandidate.lean": [
            ("context_ofCandidate", "context_of", True), ("body_ofCandidate", "body_of_model", True),
            ("expand_bodyCandidate", "expand_body", True), ("body_tokenCandidate", "body_token_model", True),
            ("at_body_stopCandidate", "at_body_stop", True), ("read_statementsCandidate", "read_statements", False)],
    }
    for path, definitions in owned.items():
        pins = literals(path, args.baseline)
        for definition, name, expression in definitions:
            show(f"{path}:{definition}", pins[definition], block(sources["body"], name, expression))
    scalar = literals("proof/Silver/ScalarExpressionSourceShape.lean", args.baseline)
    for part, ext in (("spec", "ads"), ("body", "adb")):
        show(f"ScalarExpressionSourceShape:{part}", scalar[part],
             lex((ROOT / f"src/silver_scalar_expressions.{ext}").read_text()))

    # Adjacent explicit header pins are read-only scope expansion: they can hide
    # behind the failed candidate imports and must be reported before editing.
    candidate = (ROOT / "proof/Silver/PredicateSourceCandidate.lean").read_text()
    pins = literals("proof/Silver/PredicateSourceRequirements.lean")
    checks = 0
    skipped = []
    for kind, name, stop, part, definition in re.findall(
            r'(functionHeader|procedureHeader) "(\w+)" "(is|;)" SourceShape\.(body|spec)Tokens = some (\w+) := by', candidate):
        if definition not in pins:
            skipped.append(definition)
            continue
        actual = headers(sources[part], name, stop, "function" if kind == "functionHeader" else "procedure")
        if pins[definition] != actual:
            show(f"UNOWNED PredicateSourceRequirements:{definition}", pins[definition], actual)
        checks += 1
    print(f"Adjacent literal headers checked: {checks}; composite/nonliteral headers excluded: {skipped}")
