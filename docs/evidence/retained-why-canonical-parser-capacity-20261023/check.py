#!/usr/bin/env python3
"""New target-free canonical operand census; no predecessor/model/engine replay."""
import hashlib
import json
import pathlib
import platform
import re
import tarfile
import time

HERE = pathlib.Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EVID = ROOT / "docs/evidence"


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def read_source(row, archives):
    if "archive" in row:
        path = ROOT / row["archive"]
        if path not in archives:
            archives[path] = tarfile.open(path)
        return archives[path].extractfile(row["member"]).read()
    return (ROOT / row["file"]).read_bytes()


def convert(pattern):
    """Only the retained Emacs subset; Python used for byte-span census only."""
    out, i, bracket = [], 0, False
    while i < len(pattern):
        c = pattern[i]
        if c == "\\":
            i += 1
            c = pattern[i]
            assert c in "()|[]*+?.^$\\"
            out.append(c if c in "()|" else "\\" + c)
        elif bracket:
            out.append(c)
            if c == "]":
                bracket = False
        elif c == "[":
            out.append(c)
            bracket = True
        elif c in "()|{}":
            out.append("\\" + c)
        else:
            out.append(c)
        i += 1
    assert not bracket
    return "".join(out)


def syntax(pattern):
    """Finite fixed-input syntax inventory, separate from Re compilation."""
    i, groups, atoms, repeats, nesting, peak = 0, 0, 0, 0, 0, 0
    previous = None
    while i < len(pattern):
        c = pattern[i]
        if c == "\\":
            i += 1
            c = pattern[i]
            if c == "(":
                groups += 1
                nesting += 1
                peak = max(peak, nesting)
                previous = None
            elif c == ")":
                nesting -= 1
                assert nesting >= 0
                previous = "group"
            elif c == "|":
                previous = None
            else:
                assert c in "[]*+?.^$\\"
                atoms += 1
                previous = "set"
        elif c == "[":
            i += 1
            if pattern[i] == "^":
                i += 1
            while pattern[i] != "]":
                i += 1
            atoms += 1
            previous = "set"
        elif c in "*+?":
            assert previous == "set", "Only single-character/class repetition admitted"
            repeats += 1
            previous = "repeat"
        else:
            atoms += 1
            previous = "boundary" if c in "^$" else "set"
        i += 1
    assert nesting == 0
    return {"bytes": len(pattern.encode()), "explicit_groups": groups,
            "atoms": atoms, "single_set_repeats": repeats, "group_depth": peak}


def main():
    started = time.monotonic()
    for row in json.loads((HERE / "inputs.json").read_text()):
        assert identity((ROOT / row["path"]).read_bytes()) == row["identity"], row["path"]
    archives = {}
    spans = json.loads((HERE / "source-spans.json").read_text())
    for row in spans:
        data = read_source(row, archives)
        assert identity(data) == row["file_identity"]
        lines = data.decode().splitlines(keepends=True)
        assert 1 <= row["first"] <= row["last"] <= len(lines)
        selected = "".join(lines[row["first"] - 1:row["last"]])
        assert selected == row["text"]
    for archive in archives.values():
        archive.close()
    manifest = json.loads((HERE / "re-source/manifest.json").read_text())
    assert manifest["commit"] == "f09672608781dc05172ad980a6e9a483c3b9d534"
    for name, spec in manifest["files"].items():
        assert identity((HERE / "re-source" / name).read_bytes()) == {
            k: spec[k] for k in ("bytes", "sha256")}
        assert manifest["commit"] in spec["url"]
    dirs = json.loads((EVID / "retained-adapter-outcome-interface-20261020/loaded-response-directives.json").read_text())
    names = {"cvc5_gnatprove.drv": "cvc5", "z3_gnatprove.drv": "z3",
             "alt_ergo_gnatprove_smt2.drv": "altergo"}
    compiled, patterns = {}, {}
    for key, directives in dirs.items():
        # Current timeless provider removes the historical time entries.
        assert all(d["directive"] not in ("steps", "exitcode", "failure") for d in directives)
        rules = [d for d in directives if d["directive"] != "time"]
        ps = [d["args"][0] for d in rules]
        union = "\\(" + "\\|".join(ps) + "\\)"
        name = names[key]
        patterns[name] = {"rules": rules, "individual": [syntax(p) for p in ps],
                          "union": union, "union_syntax": syntax(union),
                          "rule_count": len(ps), "string_events": 2 * len(ps) + 1}
        compiled[name] = (re.compile(convert(union), re.MULTILINE),
                          [re.compile(convert(p), re.MULTILINE) for p in ps])
        assert len(union) == sum(map(len, ps)) + 2 * len(ps) + 2
        assert len(union) <= 401 and len(ps) <= 13
        assert syntax(union)["explicit_groups"] <= 3
    source_rows = json.loads((EVID / "retained-adapter-outcome-interface-20261020/canonical-table.json").read_text())
    assert len(source_rows) == 31
    rows = []
    for row in source_rows:
        text = row["output"]
        name = "altergo" if row["driver"] in ("alt-ergo", "altergo") else row["driver"]
        union, individual = compiled[name]
        segments, start, matches = [], 0, list(union.finditer(text))
        for match in matches:
            a, b = match.span()
            assert b > a
            if a > start:
                segments.append({"kind": "Text", "start": start, "end": a})
            d = text[a:b]
            candidates = []
            for index, pattern in enumerate(individual):
                found = pattern.search(d)
                if found:
                    candidates.append({"rule": index, "span": list(found.span()),
                                       "groups": list(found.groups())})
            assert len(candidates) == 1
            segments.append({"kind": "Delim", "start": a, "end": b,
                             "individual_matches": candidates})
            start = b
        if start < len(text):
            segments.append({"kind": "Text", "start": start, "end": len(text)})
        assert len(text.encode()) == row["bytes"] <= 76
        assert len(matches) <= 4 and len(segments) <= 8
        assert sum(s["end"] - s["start"] for s in segments) == len(text)
        assert all(text[s["start"]:s["end"]] in ("\n", "!\n")
                   for s in segments if s["kind"] == "Text")
        rows.append({**row, "segments": segments, "union_search_upper": len(matches) + 1,
                     "grep_search_upper": len(matches) * len(individual),
                     "delimiter_bytes": sum(m.end() - m.start() for m in matches)})
    q_values = {"Put_Line": 155, "Put": 128, "First_Or_Default": 68,
                "Is_Message": 8, "Input_Is_Valid": 5}
    results = {"source_spans": len(spans), "rows": rows, "patterns": patterns,
        "guard_inputs": {"input_bytes": 76, "reader_buffer": 1024, "reader_scratch": 1024,
            "native_input_buffer": 65536, "union_format_bytes": 401, "union_format_events": 64,
            "union_buffer": 512, "regexp_records_per_parser": 14, "lazy_cells_per_parser": 28,
            "union_state_add_upper": 402, "answer_state_add_upper": 86,
            "union_table_buckets": 256, "answer_table_buckets": 128,
            "transition_array_words": 257, "working_bits": 512,
            "position_array_words": 2048, "mark_array_words": 8,
            "compile_id_upper": 64 * (401 + 8) ** 2},
        "domains": {name: {"Q": q, "reader_attempts": q, "parser_attempts": q,
            "positive_reads_plus_eof": 77 * q, "regexp_constructors": 14 * q,
            "search_calls": 57 * q, "replacement_attempts": 52 * q}
                    for name, q in q_values.items()},
        "scope": "Source guards and fixed operand/span census; installed internal representation attachment remains explicit."}
    assert 401 + 64 + 79 < 1000000010
    assert 402 <= 2 * 256 and 86 < 2 * 128
    assert 5 * 76 + 2 * 5 + 2 <= 402
    assert 76 + 2 * 4 + 2 == 86
    assert results["guard_inputs"]["compile_id_upper"] < 2 ** 62 - 1
    (HERE / "result.json").write_text(json.dumps(results, indent=2, sort_keys=True) + "\n")
    run = {"status": "pass", "elapsed_seconds": time.monotonic() - started,
           "host": platform.platform(), "python": platform.python_version(),
           "source_spans": len(spans), "canonical_rows": len(rows),
           "target_runs": 0, "native_captures": 0, "predecessor_replays": 0,
           "re_engine_executions": 0}
    (HERE / "run.json").write_text(json.dumps(run, indent=2) + "\n")
    print(json.dumps(run, sort_keys=True))


if __name__ == "__main__":
    main()
