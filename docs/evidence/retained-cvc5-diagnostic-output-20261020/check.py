#!/usr/bin/env python3
"""Offline identities/excerpts and diagnostic-component arithmetic, not C++ proof."""
import argparse
import hashlib
import json
from pathlib import Path
import re
import tarfile
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
REV = "86cecd83b685f59e884094693b9a4c5c90a62e03"
ARCHIVE = REPO / "docs/evidence/retained-cvc5-output-capacity-20261020/cvc5-source.tar.gz"
IMPORTED = [
    "docs/research/retained-cvc5-output-capacity.md",
    "docs/research/retained-cvc5-registry-domain.md",
    "docs/research/retained-solver-task-language.md",
    "docs/reviews/review-solver-domains-and-parallel-launch-20261020.md",
]

# Each source range is retained verbatim. Source identities cover complete files.
RANGES = {
    "src/options/prop_options.toml": [(1, 15)],
    "src/options/printer_options.toml": [(15, 31), (76, 82)],
    "src/options/base_options.toml": [(292, 321)],
    "src/prop/prop_engine.cpp": [(82, 99)],
    "src/prop/sat_solver_factory.cpp": [(26, 30)],
    "src/prop/minisat/minisat.cpp": [(109, 129)],
    "src/prop/minisat/core/Solver.cc": [
        (1153, 1185), (1276, 1279), (1486, 1500), (1590, 1620),
        (1663, 1681), (1748, 1773)],
    "src/prop/theory_proxy.cpp": [(209, 214), (272, 277)],
    "src/theory/theory.cpp": [(541, 599)],
    "src/theory/theory_engine.cpp": [(72, 86), (377, 455), (462, 468)],
    "src/theory/arith/theory_arith.cpp": [(245, 305), (493, 509), (527, 575)],
    "src/theory/arith/theory_arith.h": [(183, 195)],
    "src/theory/arith/linear/theory_arith_private.cpp": [(3973, 4030)],
    "src/theory/arith/branch_and_bound.cpp": [(47, 54), (125, 154)],
    "src/smt/env.cpp": [(183, 201)],
    "src/smt/env_obj.cpp": [(88, 94)],
    "src/printer/smt2/smt2_printer.cpp": [(70, 146), (197, 202), (320, 324)],
    "src/expr/node.h": [(856, 868), (900, 911)],
    "src/expr/node_value.cpp": [(44, 53)],
    "src/util/rational_gmp_imp.h": [(151, 160), (314, 320)],
    "src/util/integer_gmp_imp.h": [(326, 343)],
    "src/util/integer_gmp_imp.cpp": [(377, 377)],
    "src/util/resource_manager.cpp": [(281, 320)],
    "src/util/statistics_stats.cpp": [(42, 58)],
    "src/api/cpp/cvc5.cpp": [(2115, 2122), (3774, 3780), (7432, 7445)],
    "src/api/cpp/cvc5_checks.h": [(32, 71), (125, 130)],
    "include/cvc5/cvc5.h": [(100, 119)],
    "src/parser/commands.cpp": [(1207, 1223)],
    "src/expr/node.cpp": [(32, 60)],
    "src/base/exception.h": [(37, 48)],
}

ANCHORS = {
    "src/theory/arith/theory_arith.cpp": [
        "d_arithModelCacheIllTyped.clear();", "sanityCheckIntegerModel();",
        "for (const auto& p : d_arithModelCacheIllTyped)",
        'warning() << "TheoryArithPrivate generated a bad model value for "',
        '"integer variable "', '<< p.first << " : " << p.second << std::endl;',
        "d_bab.branchIntegerVariable(p.first, p.second.getConst<Rational>());",
        "if (addedLemma)", "AlwaysAssert(!badAssignment)"],
    "src/theory/arith/linear/theory_arith_private.cpp": [
        "Rational qmodel = mod.substituteDelta(delta);", "if (!qmodel.isIntegral())",
        "qNode = nm->mkConstReal(qmodel);", "if (term.getType().isInteger())",
        "arithModelIllTyped[term] = qNode;"],
    "src/prop/minisat/core/Solver.cc": [
        "for (;;)", "CRef confl = propagate(check_type);",
        "theoryCheck(cvc5::internal::theory::Theory::EFFORT_FULL);",
        "recheck = true;", "else if (recheck)", "check_type = CHECK_FINAL;",
        "while (status == l_Undef)"],
    "src/prop/theory_proxy.cpp": ["d_theoryEngine->check(effort);"],
    "src/theory/theory_engine.cpp": ["theoryOf(THEORY)->check(effort);"],
    "src/theory/theory.cpp": ["postCheck(level);"],
    "src/smt/env.cpp": ["d_options.base.verbosity >= level", "return *d_options.base.err;"],
    "src/smt/env_obj.cpp": ["EnvObj::warning() const { return verbose(0); }"],
    "src/printer/smt2/smt2_printer.cpp": [
        "int toDepth = options::ioutils::getNodeDepth(out);", 'out << "(/ ";',
        'out << "(- " << abs_r.getNumerator() << ") " << abs_r.getDenominator();',
        "out << r.getNumerator() << ' ' << r.getDenominator();"],
    "src/util/rational_gmp_imp.h": ["mpq_class d_value;"],
    "src/util/integer_gmp_imp.h": ["mpz_class d_value;", "return os << n.toString();"],
    "src/api/cpp/cvc5.cpp": [
        '<< "invalid sort of function body \'" << term << "\', expected \'" << sort',
        '<< "\', found \'" << term.getSort() << "\'";'],
    "src/api/cpp/cvc5_checks.h": [
        "throw CVC5ApiException(e.getMessage());",
        "throw CVC5ApiException(d_stream.str());"],
    "src/parser/commands.cpp": ["solver->defineFun(d_symbol, d_formals, d_sort, d_formula, global);",
        "d_commandStatus = new CommandFailure(e.what());"],
    "src/util/resource_manager.cpp": [
        "if (d_options.base.perCallResourceLimit > 0)",
        "if (d_options.base.cumulativeResourceLimit > 0)",
        "if (d_options.base.perCallMillisecondLimit == 0) return false;"],
    "src/util/statistics_stats.cpp": ["d_data->d_value++;"],
}


def identity(raw):
    return {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}


def option_default(source, option):
    for block in source.split("[[option]]")[1:]:
        name = re.search(r'\bname\s*=\s*"([^"]+)"', block)
        if name and name[1] == option:
            return re.search(r'\bdefault\s*=\s*"([^"]+)"', block)[1]
    raise AssertionError(option)


def main():
    args = argparse.ArgumentParser()
    args.add_argument("--write", action="store_true")
    args = args.parse_args()
    start = time.perf_counter()
    raw = ARCHIVE.read_bytes()
    old = json.loads((ARCHIVE.parent / "identity.json").read_text())
    assert identity(raw) == old["archive"], "archive changed"
    with tarfile.open(ARCHIVE) as tf:
        src = {name: tf.extractfile(f"cvc5-{REV}/{name}").read()
               for name in RANGES}
    decoded = {name: raw.decode() for name, raw in src.items()}
    for name, anchors in ANCHORS.items():
        for anchor in anchors:
            assert anchor in decoded[name], (name, anchor)
    defaults = {}
    for module, option, expected in [
        ("prop", "satSolver", "MINISAT"),
        ("printer", "nodeDepth", "-1"),
        ("printer", "printArithLitToken", "false"),
        ("base", "cumulativeMillisecondLimit", "0"),
        ("base", "perCallMillisecondLimit", "0"),
        ("base", "cumulativeResourceLimit", "0"),
        ("base", "perCallResourceLimit", "0"),
    ]:
        defaults[option] = option_default(decoded[f"src/options/{module}_options.toml"], option)
        assert defaults[option] == expected

    warning_fixed = len("TheoryArithPrivate generated a bad model value for "
                        "integer variable " + " : " + "\n")
    rational_overhead = len("(/ " + "(- " + ") " + ")")
    exception_fixed = sum(map(len, ["invalid sort of function body '",
                                   "', expected '", "', found '", "'"]))
    assert (warning_fixed, rational_overhead, exception_fixed) == (72, 9, 55)
    # Arithmetic boundary checks use digit placeholders; this is not a C++ run.
    for a in ["1", "123456789012345678901234567890"]:
        for b in ["2", "987654321098765432109876543211"]:
            assert len(f"(/ {a} {b})") == len(a) + len(b) + 5
            assert len(f"(/ (- {a}) {b})") == len(a) + len(b) + rational_overhead
    witnesses = []
    for name, ranges in RANGES.items():
        lines = decoded[name].splitlines(keepends=True)
        for first, last in ranges:
            assert 1 <= first <= last <= len(lines), (name, first, last)
            witnesses.append({"source": name, "first_line": first, "last_line": last,
                              "text": "".join(lines[first - 1:last])})
    inputs = {
        "revision": REV,
        "archive": {"path": str(ARCHIVE.relative_to(REPO)), **identity(raw)},
        "imported": {name: identity((REPO / name).read_bytes()) for name in IMPORTED},
        "sources": {name: identity(data) for name, data in src.items()},
    }
    result = {
        "source_files": len(src), "source_ranges": len(witnesses),
        "defaults_checked_not_auto_option_theorem": defaults,
        "warning_fixed_bytes": warning_fixed,
        "nonintegral_smt2_rational_overhead_bound": rational_overhead,
        "arithmetic_warning_coefficient": warning_fixed + rational_overhead,
        "define_fun_api_payload_fixed_bytes": exception_fixed,
        "define_fun_command_wrapper_fixed_bound": 11 + 2 * exception_fixed,
        "arithmetic_family_conditional_bound": "81*K_ar(N)+L_ar(N)+D_ar(N)",
        "K_ar": None, "L_ar": None, "D_ar": None,
        "zero_warning_invariant_established": False,
        "complete_nonterminal_output_account": False,
        "q_cvc5": None, "weighted_O": None,
        "source_native_correspondence_established": False,
        "solver_or_native_run": False,
    }
    for name, value in [("inputs.json", inputs), ("witnesses.json", witnesses),
                        ("result.json", result)]:
        path = HERE / name
        if args.write:
            path.write_text(json.dumps(value, indent=2) + "\n")
        else:
            assert json.loads(path.read_text()) == value, name
    print(json.dumps({"status": "pass", "source_files": len(src),
                      "source_ranges": len(witnesses),
                      "warning_fixed_bytes": warning_fixed,
                      "arithmetic_coefficient": 81,
                      "define_fun_fixed_payload": exception_fixed,
                      "q_cvc5": None,
                      "elapsed_seconds": round(time.perf_counter() - start, 6)}))


if __name__ == "__main__":
    main()
