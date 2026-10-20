#!/usr/bin/env python3
"""Offline finite reducer/canonical checks; deliberately not a Re.Str emulator."""
from __future__ import annotations

import hashlib
import gzip
import itertools
import json
from pathlib import Path
import re
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
WHY = "docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz"
CENSUS = "docs/evidence/retained-solver-task-language-20261020/driver-census.json"
ISSUE = "docs/evidence/retained-why-save-artifact-dependency-20261020/issue-88.json"


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def archive_read(path, member):
    with tarfile.open(ROOT / path) as archive:
        return archive.extractfile(member).read()


def dump(name, value):
    (HERE / name).write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")


def source_packet():
    census = json.loads((ROOT / CENSUS).read_text())["identities"]
    files = {WHY, CENSUS, ISSUE, "src/silver_library_reports.adb",
             "src/silver_reports.adb"}
    drivers = {}
    for name, rec in census.items():
        raw = archive_read(rec["archive"], rec["member"])
        assert identity(raw) == rec["identity"], name
        files.add(rec["archive"])
        # This is a driver DIRECTIVE inventory, not a solver-regexp matcher.
        source = re.sub(r"\(\*.*?\*\)", lambda m: "\n" * m[0].count("\n"),
                        raw.decode(), flags=re.S)
        entries = []
        for line_no, line in enumerate(source.splitlines(), 1):
            match = re.match(r"\s*(import|valid|invalid|unknown|failure|timeout|"
                             r"outofmemory|steplimitexceeded|time|steps|exitcode)\b(.*)", line)
            if match:
                args = re.findall(r'"(?:[^"\\]|\\.)*"', match[2])
                entries.append({"directive": match[1], "args": [json.loads(x) for x in args],
                                "file": name, "line": line_no})
        assert [x["args"][0] for x in entries if x["directive"] == "import"] == rec["imports"]
        drivers[name] = entries

    def expand(name):
        result = []
        for item in drivers[name]:
            if item["directive"] == "import":
                result += expand(item["args"][0])
            else:
                result.append(item)
        return result

    loaded = {n: expand(n) for n in ("cvc5_gnatprove.drv", "z3_gnatprove.drv",
                                    "alt_ergo_gnatprove_smt2.drv")}
    for entries in loaded.values():
        assert not any(e["directive"] in ("steps", "exitcode", "invalid", "failure") for e in entries)
        assert any(e["directive"] == "valid" and e["args"] == ["^unsat$"] for e in entries)
    spans = {
        "why3/src/driver/call_provers.ml": [(82,127),(150,164),(205,226),(233,402)],
        "why3/src/driver/driver.ml": [(119,148),(264,271)],
        "why3/src/driver/driver_lexer.mll": [(117,144)],
        "why3/src/driver/driver_parser.mly": [(45,53)],
        "why3/src/server/server-unix.c": [(346,398),(469,501)],
        "why3/src/server/proc.c": [(20,43)],
        "why3/src/util/loc.ml": [(134,141),(187,195)],
        "why3/src/gnat/gnat_report.ml": [(34,46),(135,156),(211,219)],
        "why3/src/gnat/gnat_config.ml": [(24,29),(567,575),(629,655)],
        "why3/src/gnat/gnat_checks.ml": [(769,826),(961,971),(1021,1032),(1049,1084)],
        "why3/src/gnat/gnat_main.ml": [(95,115)],
        "why3/src/session/controller_itp.ml": [(347,408),(469,474)],
        "why3/src/session/session_itp.ml": [(2056,2071)],
    }
    witnesses = []
    for member, ranges in spans.items():
        raw = archive_read(WHY, member)
        lines = raw.decode().splitlines(keepends=True)
        witnesses.append({"archive": WHY, "member": member, "identity": identity(raw),
                          "ranges": [{"first": a, "last": b,
                                      "text": "".join(lines[a-1:b])} for a,b in ranges]})
    api = json.loads((HERE / "re-api-source/manifest.json").read_text())
    for name, rec in api["files"].items():
        path = HERE / "re-api-source" / rec.get("retained_path", name)
        raw = path.read_bytes()
        if rec.get("encoding") == "gzip": raw = gzip.decompress(raw)
        assert identity(raw) == {k: rec[k] for k in ("bytes", "sha256")}
        files.add(str(path.relative_to(ROOT)))
    files.add(str((HERE / "re-api-source/manifest.json").relative_to(ROOT)))
    return ({"files": {p: identity((ROOT / p).read_bytes()) for p in sorted(files)},
             "why3_revision": "9390baf120ef260547dfa14f08e11c890b203d9c",
             "driver_members": census}, loaded, witnesses)


# Kind M denotes OutOfMemory; S denotes StepLimitExceeded. U classes are
# E=empty, R=resourceout, T=timeout, N=(not unknown!), O=all other strings.
UNKNOWN = {"UE", "UR", "UT", "UN", "UO"}
ANSWERS = ("V", "M", "S", "T", "UE", "UR", "UT", "UN", "UO")
TOKENS = ANSWERS + ("MODEL", "LF")
PAYLOADS = {"UE": "", "UR": "resourceout", "UT": "timeout",
            "UN": "(not unknown!)", "UO": "unknown"}


def kind(a):
    return "U" if a in UNKNOWN else a


def pair(a, b):
    """The finite adjacent-answer table, in source branch order."""
    if b == "UR" and (a == "S" or a in UNKNOWN): return "S", False
    if b == "UT" and (a == "T" or a in UNKNOWN): return "T", False
    if (a in UNKNOWN and b == "UE") or b == "UN": return a, False
    if a == "UE" and b in UNKNOWN: return b, False
    if a in UNKNOWN and b in UNKNOWN: return "UO", False
    return b, True


def step(state, token):
    saved, pending, warning, done = state
    if done or token == "LF": return state
    if token == "MODEL":
        return (kind(pending) if pending else saved or "H", None, warning, False)
    if pending:
        token, warn = pair(pending, token)
        warning |= warn
    if token == "V": return (None, None, warning, True)
    return saved, token, warning, False


INITIAL = (None, None, False, False)


def finish(state, signaled=False):
    saved, pending, warning, done = state
    # Appended terminal HighFailure preserves every earlier answer, including
    # an earlier HighFailure from MODEL; its payload is outside this quotient.
    return ("V" if done else kind(pending) if pending else saved or "H", warning)


def eager_reference(tokens, signaled):
    """Direct source-shaped evaluator using actual strings, not pair/step."""
    rest = [("U", PAYLOADS[t]) if t in UNKNOWN else (t, "")
            for t in tokens if t != "LF"]
    if signaled: rest += [("H", "signaled")]
    saved = None
    warning = False
    while rest:
        first, *tail = rest
        if first[0] == "V": return "V", warning
        if first[0] != "MODEL" and len(tail) == 1 and tail[0][0] == "H":
            return (saved[0] if first[0] == "H" and saved else first[0]), warning
        if first[0] != "MODEL" and tail and tail[0][0] != "MODEL":
            second = tail[0]
            if first[0] in ("S", "U") and second == ("U", "resourceout"):
                rest = [("S", "")] + tail[1:]
            elif first[0] in ("T", "U") and second == ("U", "timeout"):
                rest = [("T", "")] + tail[1:]
            elif (first[0] == "U" and second == ("U", "")) or second == ("U", "(not unknown!)"):
                rest = [first] + tail[1:]
            elif first == ("U", "") and second[0] == "U":
                rest = tail
            elif first[0] == second[0] == "U":
                rest = [("U", first[1] + " + " + second[1])] + tail[1:]
            else:
                warning = True
                rest = tail
        elif first[0] == "MODEL":
            saved = saved or ("H", "unrecognized prover answer")
            rest = tail
        else:
            if first[0] != "H" or saved is None: saved = first
            rest = tail[1:] if tail and tail[0][0] == "MODEL" else tail
    return (saved[0] if saved else "H"), warning


CANONICAL = {
    "V": "unsat\n", "U": "unknown\n", "S": "unknown\n(:reason-unknown resourceout)\n",
    "T": "unknown\n(:reason-unknown timeout)\n", "M": "Cannot allocate memory\n", "H": "!\n",
}
WARNING_PREFIX = CANONICAL["S"]


def canonical_tokens(raw):
    """Lexical witnesses only for this finite literal table; NOT generic regex."""
    mapping = {"unsat": "V", "unknown": "UO", "(:reason-unknown resourceout)": "UR",
               "(:reason-unknown timeout)": "UT", "Cannot allocate memory": "M", "!": "MODEL"}
    return [mapping[line] for line in raw.splitlines()]


def finite_checks():
    states = {INITIAL}
    frontier = [INITIAL]
    while frontier:
        state = frontier.pop()
        for token in TOKENS:
            successor = step(state, token)
            if successor not in states:
                states.add(successor)
                frontier.append(successor)
    assert len(states) <= 110
    compared = 0
    # Includes every length-five sequence of the abstract token alphabet.
    for length in range(6):
        for seq in itertools.product(TOKENS, repeat=length):
            state = INITIAL
            for token in seq: state = step(state, token)
            for signal in (False, True):
                assert finish(state, signal) == eager_reference(seq, signal), (seq, signal)
                compared += 1
    assert all(finish(s) != ("H", True) for s in states)
    rows = []
    for driver in ("cvc5", "z3", "altergo"):
        for result, raw in CANONICAL.items():
            if driver == "altergo" and result == "M": continue
            for warning in (False, True):
                if result == "H" and warning: continue
                out = (WARNING_PREFIX if warning else "") + raw
                seq = canonical_tokens(out)
                for signal in (False, True):
                    assert eager_reference(seq, signal) == (result, warning)
                # None of the non-Valid rows has even the literal word unsat;
                # the only valid regex usable by these canonical alphabets.
                assert ("unsat" in out) == (result == "V")
                rows.append({"driver": driver, "answer_kind": result, "warning": warning,
                             "bytes": len(out.encode()), "output": out, "token_witness": seq})
    return ({"reachable_reducer_states": len(states), "reducer_state_upper_bound": 110,
             "abstract_token_alphabet": list(TOKENS), "compared_eager_and_streaming_cases": compared,
             "maximum_token_sequence_length": 5, "canonical_rows": len(rows),
             "canonical_max_bytes": max(r["bytes"] for r in rows),
             "hf_with_warning_reachable": False,
             "scope": "finite reducer and literal canonical witnesses; not a Re.Str correspondence proof"}, rows)


LONG = {
    "cvc5": [('(error "', 'out of memory")')],
    "z3": [('(error "', 'out of memory")'),
           ('Maximal allocation counts ', ' have been exceeded'),
           ('(error "', 'number of configured allocations exceeded")')],
}
SIMPLE = {
    "cvc5": [("cvc5 suffered a segfault", "M"),
             ("cvc5::internal::Minisat::OutOfMemoryException", "M"),
             ("CVC4 suffered a segfault", "M"),
             ("CVC4::BVMinisat::OutOfMemoryException", "M"),
             ("std::bad_alloc", "M"), ("Cannot allocate memory", "M"),
             ("interrupted by timeout", "T"), ("unknown (RESOURCEOUT)", "S")],
    "z3": [("Cannot allocate memory", "M"), ("interrupted by timeout", "T")],
}


def emacs_subset_to_python(pattern):
    """Reference for finite fixtures under the documented API, not native evidence.

    Selected patterns use only this common byte-compatible syntax subset.
    Python regex execution does not certify the future streaming implementation.
    """
    out, i, in_class = [], 0, False
    while i < len(pattern):
        c = pattern[i]
        if c == "\\" and not in_class:
            i += 1
            c = pattern[i]
            out.append(c if c in "()|" else "\\" + c)
        elif c == "[":
            in_class = True
            out.append(c)
        elif c == "]" and in_class:
            in_class = False
            out.append(c)
        else:
            out.append("\\" + c if not in_class and c in "()|" else c)
        i += 1
    return "".join(out)


def compiled(entries):
    kinds = {"valid": "V", "outofmemory": "M", "timeout": "T", "steplimitexceeded": "S"}
    result = []
    for e in entries:
        if e["directive"] == "time": continue
        answer = ("U", e["args"][1]) if e["directive"] == "unknown" else (kinds[e["directive"]], "")
        result.append((re.compile(emacs_subset_to_python(e["args"][0]), re.M), answer))
    return result


def reference_spans(raw, rules):
    # Explicit search in loaded order realizes first-branch selection at equal
    # starting positions; each individual fixture regexp uses greedy repetition.
    spans, start = [], 0
    while True:
        matches = [(m.start(), i, m) for i, (pat, _) in enumerate(rules)
                   if (m := pat.search(raw, start))]
        if not matches: return spans
        _, _, match = min(matches, key=lambda x: x[:2])
        fragment = raw[match.start():match.end()]
        for pat, answer in rules:
            if found := pat.search(fragment):
                if answer[0] == "U":
                    payload = found.expand(answer[1])
                    token = next((k for k, v in PAYLOADS.items() if v == payload), "UO")
                else: token = answer[0]
                break
        spans.append((match.start(), match.end(), token))
        start = match.end()


def span_tokens(raw, spans):
    tokens, pos = [], 0
    for a,b,token in spans:
        if a > pos: tokens.append("LF" if raw[pos:a] == "\n" else "MODEL")
        tokens.append(token)
        pos = b
    if pos < len(raw): tokens.append("LF" if raw[pos:] == "\n" else "MODEL")
    return tokens


def simple_spans(raw, a, b, literals):
    spans = []
    while a < b:
        found = [(p, i, lit, kind) for i, (lit, kind) in enumerate(literals)
                 if (p := raw.find(lit, a, b)) >= 0]
        if not found: break
        p, _, lit, kind = min(found)
        spans.append((p, p + len(lit), kind))
        a = p + len(lit)
    return spans


def endpoint_matrix_spans(raw, driver):
    """Finite end-selector oracle. Absolute offsets here are test-only.

    The note gives the streaming registers, finite summary snapshots and rank
    representation; this checker independently compares its endpoint rule.
    """
    branches = LONG[driver]
    suffix_starts = [raw.rfind(s) for _,s in branches]
    ends = [p + len(s) if p >= 0 else -1 for p,(_,s) in zip(suffix_starts,branches)]
    anchors = [0] + ends
    first = [[raw.find(p, a) if a >= 0 else -1 for p,_ in branches] for a in anchors]
    spans, row, pos, used = [], 0, 0, set()
    while True:
        choices = [(p, j) for j,p in enumerate(first[row])
                   if p >= pos and suffix_starts[j] >= p + len(branches[j][0])]
        if not choices:
            return spans + simple_spans(raw, pos, len(raw), SIMPLE[driver])
        p,j = min(choices)
        assert j not in used
        used.add(j)
        spans += simple_spans(raw, pos, p, SIMPLE[driver])
        spans.append((p, ends[j], "M"))
        row, pos = j+1, ends[j]


def byte_construction_checks(loaded):
    results = {}
    common = {r"^\(unknown\|sat\|Fail\)$", r"^(:reason-unknown \([^)]*\))$", "^unsat$"}
    n_error = '^' + '(error "Can\'t get-info :reason-unknown when the last result wasn\'t unknown!")' + '$'
    cvc_expected = common | {n_error} | {x for x,_ in SIMPLE["cvc5"]} | {p+'.*'+s for p,s in LONG["cvc5"]}
    z3_long = LONG["z3"]
    z3_memory = (z3_long[0][0]+'.*'+z3_long[0][1] + r'\|Cannot allocate memory\|' +
                 z3_long[1][0]+'.*'+z3_long[1][1] + r'\|' + z3_long[2][0]+'.*'+z3_long[2][1])
    z3_expected = common | {z3_memory, 'interrupted by timeout'}
    alt_expected = common | {
        '^; File ".*", line [0-9]+, characters [0-9]+-[0-9]+: ?Valid',
        '^; File ".*", line [0-9]+, characters [0-9]+-[0-9]+: ?I don\'t know',
        r'^\[Error\]; Fatal Error: Steps limit reached'}
    coverage = {}
    for filename,expected in [('cvc5_gnatprove.drv',cvc_expected),('z3_gnatprove.drv',z3_expected),
                              ('alt_ergo_gnatprove_smt2.drv',alt_expected)]:
        actual = [x['args'][0] for x in loaded[filename] if x['directive'] != 'time']
        assert len(actual) == len(expected) and set(actual) == expected, (filename,set(actual)^expected)
        coverage[filename] = {'answer_directives':len(actual),'all_accounted_for':True}
    for driver, filename in (("cvc5", "cvc5_gnatprove.drv"), ("z3", "z3_gnatprove.drv")):
        branches, literals = LONG[driver], SIMPLE[driver]
        for p,s in branches:
            for literal,_ in literals:
                assert p not in literal and s not in literal
                assert not any(literal[-n:] == p[:n] for n in range(1,min(len(literal),len(p))+1))
                assert not any(s[-n:] == literal[:n] for n in range(1,min(len(s),len(literal))+1))
        assert max(len(x) for pair in branches for x in pair) <= 128
        assert max(len(x) for x,_ in literals) <= 128
        for literal,_ in literals:
            assert all(not other.startswith(literal) for other,_ in literals if literal != other)
        rules = compiled(loaded[filename])
        # Exhaustive finite concatenations include repeated/nested starts,
        # competing last suffixes, literal gaps and unknown high-byte/NUL text.
        pieces = [p for p,_ in branches] + [s for _,s in branches]
        pieces += [literals[0][0], "interrupted by timeout", "\x00\xff\r", "x"]
        tested = 0
        for length in range(5):
            for parts in itertools.product(pieces, repeat=length):
                raw = "".join(parts)
                actual = endpoint_matrix_spans(raw,driver)
                expected = reference_spans(raw,rules)
                assert actual == expected, (driver,raw,actual,expected)
                tested += 1
        results[driver] = {"long_branches": len(branches), "finite_endpoint_cases": tested,
                           "simple_start_and_long_end_crossings": 0}
    fixtures = [
        ("reason_hides_valid", "(:reason-unknown \nunsat\n)\n", "U", False),
        ("unterminated_reason_exposes_valid", "(:reason-unknown \nunsat\n", "V", False),
        ("two_lf_commit_unknown", "unknown\n\n(:reason-unknown resourceout)\n", "U", False),
        ("one_lf_keeps_chain", "unknown\n(:reason-unknown resourceout)\n", "S", False),
        ("cr_not_removed", "unsat\r\n", "H", False),
        ("valid_prefix_no_lf", "unsat", "V", False),
        ("warning_before_valid", "unknown\nunsat\n", "V", True),
        ("warning_after_valid_ignored", "unsat\nunknown\nunsat\n", "V", False),
    ]
    checked = []
    for filename, entries in loaded.items():
        rules = compiled(entries)
        for name,raw,answer,warning in fixtures:
            tokens = span_tokens(raw,reference_spans(raw,rules))
            for signal in (False,True):
                assert eager_reference(tokens,signal) == (answer,warning), (filename,name,tokens)
            checked.append({"driver":filename,"name":name,"raw":raw,"tokens":tokens,
                            "answer_kind":answer,"warning":warning})
    special = '(:reason-unknown \n(error "Can\'t get-info :reason-unknown when the last result wasn\'t unknown!")\n'
    rules = compiled(loaded["cvc5_gnatprove.drv"])
    tokens = span_tokens(special,reference_spans(special,rules))
    assert tokens == ["UN","LF"], tokens
    checked.append({"driver":"cvc5_gnatprove.drv","name":"isolated_delim_earlier_N_rule",
                    "raw":special,"tokens":tokens})
    return {"endpoint_matrix":results,"fixtures":checked,"source_shape_coverage":coverage,
            "interpretation":"finite fixtures under retained documented Re.Str semantics; no native matcher execution",
            "storage": {"reducer_gap_states":330,"transform_entry_bytes":2,"reserved_transform_rows":2048,
                        "transform_bytes":2048*330*2,"other_reserved_bytes":65536,
                        "total_reserved_bytes":2048*330*2+65536,"limit_bytes":2**21}}


def main():
    inputs, loaded, witnesses = source_packet()
    checks, rows = finite_checks()
    byte_checks = byte_construction_checks(loaded)
    dump("inputs.json", inputs)
    dump("loaded-response-directives.json", loaded)
    dump("source-witnesses.json", witnesses)
    dump("canonical-table.json", rows)
    dump("checks.json", checks)
    dump("byte-construction-checks.json", byte_checks)
    print(json.dumps(checks, sort_keys=True))


if __name__ == "__main__": main()
