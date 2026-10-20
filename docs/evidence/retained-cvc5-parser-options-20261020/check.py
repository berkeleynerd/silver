#!/usr/bin/env python3
"""Offline identity/inventory/arithmetic checks; no CVC5 execution."""

import ast
import hashlib
import json
from pathlib import Path
import re
import tarfile
import time
import tomllib

PACKET = Path(__file__).resolve().parent
ROOT = PACKET.parents[2]
ARCHIVE = ROOT / "docs/evidence/retained-cvc5-output-capacity-20261020/cvc5-source.tar.gz"
PREFIX = "cvc5-86cecd83b685f59e884094693b9a4c5c90a62e03/"
FIELDS = {
    "statistics": "true", "statisticsInternal": "true",
    "statisticsAll": "false", "statisticsEveryQuery": "false",
    "printSuccess": "false", "collectPivots": "false", "doITESimp": "false",
    "usePortfolio": "false", "dumpModels": "false", "dumpProofs": "false",
    "dumpInstantiations": "false", "dumpInstantiationsDebug": "false",
    "dumpUnsatCores": "false", "dumpUnsatCoresLemmas": "false",
    "dumpDifficulty": "false", "proofLog": "false", "verbosity": "0",
    "outputTagHolder": "{}", "inputLanguage": "Language::LANG_SMTLIB_V2_6",
    "outputLanguage": "Language::LANG_SMTLIB_V2_6", "parseOnly": "false",
    "interactive": "false", "incrementalSolving": "false",
    "wellFormedChecking": "false", "freshBinders": "false",
    "cumulativeMillisecondLimit": "0", "segvSpin": "false",
    "earlyExit": "true", "satSolver": "MINISAT", "nodeDepth": "-1",
    "printArithLitToken": "false",
}


def read_json(path):
    return json.loads(path.read_text())


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def read_sources():
    with tarfile.open(ARCHIVE) as archive:
        return {
            member.name.removeprefix(PREFIX): archive.extractfile(member).read()
            for member in archive.getmembers()
            if member.isfile() and member.name.startswith(PREFIX + "src/")
        }


def texts(sources):
    result = {}
    for name, data in sources.items():
        try:
            result[name] = data.decode("utf-8")
        except UnicodeDecodeError:
            pass
    return result


def derive(sources):
    src = texts(sources)
    declarations = {}
    for name, text in sorted(src.items()):
        if name.startswith("src/options/") and name.endswith("_options.toml"):
            module = tomllib.loads(text)
            for opt in module.get("option", []):
                if opt.get("name") in FIELDS:
                    field = opt["name"]
                    assert field not in declarations
                    declarations[field] = {
                        "source": name,
                        "module": module["id"],
                        "declaration": opt,
                        "selected_projection": FIELDS[field],
                    }
    assert set(declarations) == set(FIELDS)
    keys = set()
    for decl in declarations.values():
        opt = decl["declaration"]
        if "long" in opt:
            keys.add(opt["long"].split("=")[0])
        keys.update(opt.get("alias", []))
    field_pat = re.compile(r"\b(?:" + "|".join(sorted(FIELDS)) + r")\b")
    key_pat = re.compile(r'"(?:' + "|".join(map(re.escape, sorted(keys))) + r')"')
    setter_pat = re.compile(r"\b(?:setOption|setOptionInternal|copyValues)\s*\(|options::set\s*\(|TraceChannel\.on\s*\(")
    field_rows, setter_rows, diagnostic_rows = [], [], []
    diag_pat = re.compile(r"\b(?:parseError|parseErrorLogic|unexpectedTokenError|warning|Warning)\s*\(")
    for name, text in sorted(src.items()):
        for line, content in enumerate(text.splitlines(), 1):
            row = {"source": name, "line": line, "text": content}
            if field_pat.search(content) or key_pat.search(content):
                field_rows.append(row)
            if setter_pat.search(content):
                setter_rows.append(row)
            if name.startswith("src/parser/") and diag_pat.search(content):
                diagnostic_rows.append(row)

    parser_lines = src["src/parser/parser_state.cpp"].splitlines()
    literal_pat = r'"(?:[^"\\]|\\.)*"'

    def string_bytes(first, last):
        block = "\n".join(parser_lines[first - 1:last])
        return sum(len(ast.literal_eval(s).encode()) for s in re.findall(literal_pat, block))

    fresh_literal = string_bytes(267, 271)
    attribute_literal = string_bytes(678, 681)
    token_literals = re.findall(r'o << ("(?:[^"\\]|\\.)*")', src["src/parser/tokens.cpp"])
    token_max = max(len(ast.literal_eval(s)) for s in token_literals)
    constants = {
        "fresh_binder_fixed_payload_bytes": fresh_literal,
        "fresh_binder_complete_fixed_bytes": fresh_literal + 1,
        "attribute_fixed_payload_bytes": attribute_literal,
        "located_warning_uint32_prefix_and_lf_bytes": 1 + 10 + 1 + 10 + 2 + 1,
        "attribute_complete_fixed_excluding_filename_bytes": attribute_literal + 25,
        "max_valid_token_name_bytes": token_max,
        "direct_message_fixed_allowance": 256,
        "direct_message_raw_token_factor": 2,
        "direct_message_rendered_operand_factor": 3,
        "parser_wrapper_reused_allowance": 68,
        "normal_result_pair_reused_allowance": 84,
        "ordinary_statistics_fixed_bytes": 883872 + 10892 + 4 * 23453 + 2 * 557 + 4 * 6022 + 4 * 22527,
    }
    assert fresh_literal == 172 and attribute_literal == 74 and token_max == 29
    assert constants["ordinary_statistics_fixed_bytes"] == 1103886
    assert "uint32_t d_line;" in src["src/parser/lexer.h"]
    assert "uint32_t d_column;" in src["src/parser/lexer.h"]
    return {
        "option-projection.json": declarations,
        "option-occurrences.json": {
            "scan": "Every UTF-8-decodable file in the exact archive's src/ tree; comments and tests retained as lexical occurrences, not value writers.",
            "field_or_key_occurrences": field_rows,
            "setter_and_copy_occurrences": setter_rows,
        },
        "parser-sites.json": {"lexical_diagnostic_sites": diagnostic_rows, "constants": constants},
    }


def main():
    started = time.monotonic()
    inputs = read_json(PACKET / "inputs.json")
    for name, expected in inputs["files"].items():
        assert identity((ROOT / name).read_bytes()) == expected, name
    sources = read_sources()
    manifest = read_json(PACKET / "sources.json")
    for name, expected in manifest["cvc5_sources"].items():
        assert identity(sources[name]) == expected, name
    for witness in manifest["witnesses"]:
        lines = sources[witness["source"]].decode().splitlines()
        actual = "\n".join(lines[witness["first"] - 1:witness["last"]])
        assert actual == witness["text"], witness["label"]
    for foreign in manifest["foreign_sources"]:
        with tarfile.open(ROOT / foreign["archive"]) as archive:
            data = archive.extractfile(foreign["member"]).read()
        assert identity(data) == foreign["identity"], foreign["member"]
        for literal in foreign["required_literals"]:
            assert literal in data.decode(), (foreign["member"], literal)
    generated = derive(sources)
    for name, expected in generated.items():
        assert read_json(PACKET / name) == expected, name
    print(json.dumps({
        "result": "pass",
        "inputs": len(inputs["files"]),
        "complete_cvc5_sources": len(manifest["cvc5_sources"]),
        "foreign_sources": len(manifest["foreign_sources"]),
        "witnesses": len(manifest["witnesses"]),
        "projected_options": len(FIELDS),
        "parser_lexical_sites": len(generated["parser-sites.json"]["lexical_diagnostic_sites"]),
        "ordinary_statistics_fixed_bytes": 1103886,
        "q_cvc5": None,
        "weighted_O": None,
        "check_seconds": round(time.monotonic() - started, 6),
        "scope": "Offline source identity, inventory, literal constants and arithmetic; no semantic/native execution or universal capacity proof.",
    }, indent=2))


if __name__ == "__main__":
    main()
