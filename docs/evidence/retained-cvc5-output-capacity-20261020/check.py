#!/usr/bin/env python3
"""Offline source identity, lexical inventories and component arithmetic.

This is not a C++ reachability proof, solver run, or whole-output certificate.
Use --write to regenerate the two derived JSON files; otherwise compare them.
"""
import argparse
import ast
import collections
import hashlib
import json
from pathlib import Path
import re
import tarfile

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
REV = "86cecd83b685f59e884094693b9a4c5c90a62e03"


def identity(raw):
    return {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}


def archive(path, prefix=""):
    with tarfile.open(path) as t:
        return {m.name.removeprefix(prefix): t.extractfile(m).read()
                for m in t.getmembers() if m.isfile()}


meta = json.loads((HERE / "identity.json").read_text())
assert identity((HERE / "cvc5-source.tar.gz").read_bytes()) == meta["archive"]
assert identity((HERE / "reused-sources.tar.gz").read_bytes()) == meta["reused_archive"]
src = archive(HERE / "cvc5-source.tar.gz", f"cvc5-{REV}/")
reused = archive(HERE / "reused-sources.tar.gz")
assert {k: identity(v) for k, v in reused.items()} == meta["reused_members"]
for path, expected in meta["source_reuse"].items():
    assert identity((REPO / path).read_bytes()) == expected, path
old = json.loads((REPO / "docs/evidence/retained-producer-response-20261018/identity.json").read_text())
reuse_checks = []
for f in old["files"]:
    if f["path"].startswith("solvers/cvc5-cvc5/"):
        name = f["path"].removeprefix("solvers/cvc5-cvc5/")
        assert identity(src[name]) == {"bytes": f["bytes"], "sha256": f["sha256"]}
        reuse_checks.append(name)
    if f["path"] in reused:
        assert identity(reused[f["path"]]) == {"bytes": f["bytes"], "sha256": f["sha256"]}
helper = json.loads((REPO / "docs/evidence/retained-why-session-helper-source-20261019/source-identities.json").read_text())
assert identity(reused["why3/src/printer/smtv2.ml"]) == helper["members"]["why3/src/printer/smtv2.ml"]["identity"]

used = set()


def read(name):
    used.add(name)
    return src[name].decode()


def require(name, *tokens):
    s = read(name)
    for token in tokens:
        assert token in s, (name, token)


require("src/main/command_executor.cpp", "getTermManager().getStatistics()",
        "d_solver->getStatistics()", 'out << it->first << " = " << it->second << std::endl;',
        "printStatistics(d_solver->getDriverOptions().err());")
require("src/main/main.cpp", "catch (cvc5::CVC5ApiException& e)",
        "pExecutor->printStatistics(solver->getDriverOptions().err());")
require("src/util/statistics_value.cpp", 'out << e.first << ": " << e.second;',
        'return std::to_string(get()) + "ms";')
require("src/util/statistics_value.h", "std::map<std::string, uint64_t> res;",
        "if (d_hist[i] > 0)", "res.emplace(ss.str(), d_hist[i]);")
require("src/util/statistics_registry.h", "auto it = d_stats.find(name);",
        "if (it == d_stats.end())")
require("src/options/options_handler.cpp", "OptionsHandler::setStatsDetail",
        "d_options->write_base().statistics = true;")
require("src/main/portfolio_driver.cpp", 'solver.getOption("use-portfolio") == "true"',
        "return ctx.solveContinuous(d_parser, false);")
require("src/parser/commands.cpp", "d_commandStatus = new CommandFailure(e.what());",
        "out << d_result << endl;", 'v.push_back(tm.mkVar(bt, ":" + d_flag));')
require("src/printer/smt2/smt2_printer.cpp",
        'out << "(error " << cvc5::internal::quoteString(message) << \')\' << endl;')
require("src/util/smt2_quote_string.cpp", 'output.replace(pos, 1, "\\\"\\\"");')
require("src/api/cpp/cvc5_parser.cpp", 'os << "Parse Error: " << d_filename << ":" << d_line << "." << d_column')
require("src/parser/input.cpp", 'ss << "Couldn\'t open file: " << filename;')
require("src/main/signal_handlers.cpp", "default_terminator();", "print_statistics();")
require("src/util/safe_print.cpp", "i *= -1;", "int64_t v = static_cast<int64_t>(d);",
        "while (i == 0 || (d > 0.0 && i < BUFFER_SIZE))")
require("src/smt/process_assertions.cpp", "if (options().smt.doITESimp")
require("src/theory/arith/linear/theory_arith_private.cpp", "if (useSimplex && options().arith.collectPivots)")
require("src/smt/solver_engine.cpp", '"driver::filename", value);',
        '"Can\'t get-info :reason-unknown when the "', '"last result wasn\'t unknown!";'.removesuffix(";") )
require("src/base/output.cpp", "WarningC WarningChannel(&std::cerr);")
require("src/smt/env.cpp", "d_options.base.verbosity >= level", "return verbose(0);")
require("src/options/mkoptions.py", "ioutils::setDefault{}(value);", "s_{name}Default")
require("src/options/io_utils_template.cpp", "return defaultValue;")
require("src/main/driver_unified.cpp", '".smt2"', '"output-language",',
        "pExecutor->flushOutputStreams();")
require("src/util/result.cpp", 'out << "unknown";', "r.toStreamSmt2(out);")

defaults = {}
for name in ("base", "main", "arith", "smt", "printer"):
    s = read(f"src/options/{name}_options.toml")
    for block in s.split("[[option]]")[1:]:
        m = re.search(r'name\s*=\s*"([^"]+)"', block)
        d = re.search(r'default\s*=\s*"([^"]+)"', block)
        if m and d:
            defaults[m[1]] = d[1]
expected_defaults = {"statistics": "false", "statisticsAll": "false",
                     "statisticsEveryQuery": "false", "verbosity": "0",
                     "usePortfolio": "false", "printSuccess": "false",
                     "dumpModels": "false", "dumpProofs": "false",
                     "collectPivots": "false", "doITESimp": "false",
                     "doITESimpOnRepeat": "false", "segvSpin": "false"}
assert all(defaults[k] == v for k, v in expected_defaults.items())

# Lexical direct member-call inventory, deliberately not a C++ compiler census.
# Balanced first argument, including calls such as getStatsPrefix(id).
pattern = re.compile(r'(?:\.|->)\s*(register(?:Int|Average|Timer|Histogram|Value|Reference|Size))(?:<([^<>]+)>)?\s*\(')
rows = []
cpp_count = 0
for name, raw in sorted(src.items()):
    if not name.startswith("src/") or Path(name).suffix not in (".cpp", ".h"):
        continue
    cpp_count += 1
    s = raw.decode()
    for m in pattern.finditer(s):
        used.add(name)
        depth, quote, escaped, end = 0, False, False, m.end()
        for end in range(m.end(), len(s)):
            c = s[end]
            if quote:
                if escaped:
                    escaped = False
                elif c == "\\":
                    escaped = True
                elif c == '"':
                    quote = False
            elif c == '"':
                quote = True
            elif c == "(":
                depth += 1
            elif c == ")":
                if depth == 0:
                    break
                depth -= 1
            elif c == "," and depth == 0:
                break
        arg = " ".join(s[m.end():end].split())
        rows.append({"file": name, "line": s.count("\n", 0, m.start()) + 1,
                     "method": m[1], "type": m[2], "name_expression": arg,
                     "literal_name": bool(re.fullmatch(r'"[^"\\]*"', arg))})
assert len(rows) == 354
assert [r["name_expression"] for r in rows if r["method"] == "registerValue"] == ['"driver::filename"', '"driver::filename"']
assert len([r for r in rows if r["method"] == "registerHistogram" and r["type"] == "uint32_t"]) == 4

enum_files = {"Resource": "src/util/resource_manager.cpp",
              "InferenceId": "src/theory/inference_id.cpp",
              "strings::Rewrite": "src/theory/strings/rewrites.cpp",
              "bags::Rewrite": "src/theory/bags/rewrites.cpp",
              "TrustId": "src/proof/trust_id.cpp",
              "LearnedRewriteId": "src/preprocessing/passes/learned_rewrite.cpp",
              "TheoryId": "src/theory/theory_id.cpp"}
enums = {}
for key, name in enum_files.items():
    s = read(name)
    start = s.index("const char* toString")
    body = s[start:s.index("\n}", start)]
    values = sorted(set(re.findall(r'return\s+"([^"\\]*)"', body)))
    n, length = len(values), sum(map(len, values))
    enums[key] = {"file": name, "spellings_including_fallbacks": values,
                  "spelling_count": n, "spelling_bytes": length,
                  "max_spelling_bytes": max(map(len, values)),
                  "normal_histogram_value_bound": 4 + length + 24 * n}

# Generated kind/proof printers remain explicit source-to-build obligations.
for name in ("src/expr/kind_template.cpp", "src/expr/mkkind.py",
             "src/api/cpp/cvc5_proof_rule_template.cpp", "src/rewriter/rewrite_proof_rule.cpp",
             "include/cvc5/cvc5.h", "src/api/cpp/cvc5_checks.h",
             "src/base/exception.cpp", "src/parser/lexer.cpp", "src/util/safe_print.h",
             "src/preprocessing/passes/ite_simp.cpp", "src/smt/set_defaults.cpp"):
    read(name)

why = reused["why3/src/printer/smtv2.ml"].decode()
assert '(get-info :reason-unknown)' in why and 'if info.info_supports_reason_unknown then' in why
assert 'if info.info_incremental then\n        print_incremental_axiom info fmt;' in why
assert 'meta "supports_smt_get_info_unknown_reason" ""' in reused['installed/libexec/spark/share/why3/drivers/cvc5.gen'].decode()
unknown = read("src/api/cpp/cvc5_types.cpp")
start = unknown.index("std::ostream& operator<<(std::ostream& out, UnknownExplanation e)")
body = unknown[start:unknown.index("\n}", start)]
reasons = re.findall(r'out << "([A-Z_]+)";', body)
err = "Can't get-info :reason-unknown when the last result wasn't unknown!"
error_line = '(error "' + err + '")\n'
wrapper = len('(error "') + len('")\n')
assert wrapper == 11
assert wrapper + len('\nPlease use --help to get help on command-line options.\n') == 67
assert wrapper + len('Parse Error: ') + len(':') + len('.') + len(': ') + 40 == 68
assert wrapper + len('Parse Error: ') + len("Couldn't open file: ") == 44
pair_lengths = {"sat": len("sat\n") + len(error_line),
                "unsat": len("unsat\n") + len(error_line),
                "unknown": max(len("unknown\n(:reason-unknown " + r.lower() + ")\n") for r in reasons)}
assert max(pair_lengths.values()) == 84
ceilings = dict(zip(("Put_Line", "Put", "First_Or_Default", "Is_Message", "Input_Is_Valid"),
                    (1156, 1391, 2229, 20074, 26766)))
terminal_messages = {"timeout": "cvc5 interrupted by timeout.\n",
                     "SIGTERM": "cvc5 interrupted by SIGTERM.\n",
                     "SIGINT": "cvc5 interrupted by user.\n",
                     "illegal_instruction_release": "cvc5 executed an illegal instruction.\n",
                     "terminate_release": "cvc5 was terminated by the C++ runtime.\nPerhaps an exception was thrown during stack unwinding.\n"}
sig = read("src/main/signal_handlers.cpp")
literal_tokens = re.findall(r'"(?:[^"\\]|\\.)*"', sig)
signal_literal_sum = sum(len(ast.literal_eval(x).encode()) for x in literal_tokens)

result = {
    "scope": "Candidate-source components and prospective interfaces; no native execution or whole-output bound",
    "q_cvc5": None, "weighted_O": None,
    "reused_cvc5_file_matches": reuse_checks,
    "selected_command": "cvc5 --prenex-quant=none --stats-internal %f",
    "unchanged_default_options_requiring_task_join": expected_defaults,
    "normal_statistics_formula": "L_names + 4*S + 20*I + 13*D + 22*T + L_strings + sum_h(4 + L_keys_h + 24*K_h)",
    "normal_response_pair_bytes": pair_lengths,
    "normal_response_pair_bound": 84,
    "message_wrappers": {"command_error": "11+2*m", "main_api_error": "11+m",
                         "main_option_error": "67+m", "parser_location_plus_main_error_lp64": "68+F+m",
                         "file_open_error_plus_main_error": "44+F"},
    "terminal_own_message_bytes_excluding_statistics_and_runtime": {k: len(v) for k, v in terminal_messages.items()},
    "terminal_per_activation_coarse_own_text": {"literal_sum": signal_literal_sum, "formula": f"{signal_literal_sum}+4*P0+98", "excludes": "statistics, delegated runtime, pre-handler diagnostics; requires normal scalar writes"},
    "finite_histogram_tables": enums,
    "uint32_histogram_value_bound_if_needed": 4 + 34 * 2**32,
    "inference_full_table_allowance_vs_optimistic_q": {k: {"q_ceiling": v, "remaining_after_histogram_value_only": v - enums['InferenceId']['normal_histogram_value_bound']} for k, v in ceilings.items()},
    "lexical_registration_sites": len(rows),
    "lexical_literal_name_sites": sum(r['literal_name'] for r in rows),
    "source_cpp_h_files_scanned": cpp_count,
    "histogram_registration_type_counts": dict(collections.Counter(r['type'] for r in rows if r['method'] == 'registerHistogram')),
    "source_files_used": {n: identity(src[n]) for n in sorted(used)},
}
outputs = {"result.json": result, "registration-sites.json": rows}
args = argparse.ArgumentParser()
args.add_argument("--write", action="store_true")
args = args.parse_args()
for name, value in outputs.items():
    if args.write:
        (HERE / name).write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")
    else:
        assert json.loads((HERE / name).read_text()) == value, name
print(json.dumps({"status": "pass", "registered_call_sites": len(rows),
                  "response_pair_bound": 84, "q_cvc5": None, "weighted_O": None}, sort_keys=True))
