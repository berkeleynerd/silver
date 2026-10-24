#!/usr/bin/env python3
"""Check the frozen reported-time recipe, source census and additive interface.

This reads retained sources and configuration only. It never executes Why3,
Re, a prover, a compiler, a prior evidence checker, or the candidate recipe.
The source induction and native allocation arguments are reviewed separately.
"""
from __future__ import annotations

import argparse
import hashlib
import json
from pathlib import Path
import re
import runpy
import sys
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
OLD = "docs/evidence/retained-fixed-failure-composition-20261023/"
PREFIX = "docs/evidence/retained-combined-parallel-startup-20261020/projection.json"
WHY = "docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz"
REPORT = "docs/evidence/retained-required-report-consumers-20261024/sources.tar.gz"
RESPONSE = "docs/evidence/retained-producer-response-20261018/sources.tar.gz"
RE_API = "docs/evidence/retained-solver-response-adapter-20261020/re-api-source/lib/"
BEFORE = b"(* time measurement removed  *)\n"
AFTER = b'time "\\\\=" time "\\\\=" time "\\\\="\n'
SELECTED = ("cvc5_silvercap.drv", "z3_silvercap.drv", "alt_ergo_silvercap_smt2.drv")


def ident(raw):
    return {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}


def encoded(obj):
    return (json.dumps(obj, indent=2, sort_keys=True) + "\n").encode()


def archive(path):
    with tarfile.open(ROOT / path) as a:
        return {m.name: a.extractfile(m).read() for m in a.getmembers() if m.isfile()}


def lexical_census(raw):
    """Finite byte census of this fixed ASCII driver, not a target parser run."""
    s = raw.decode("ascii")
    i, tokens, strings, depth_max = 0, [], [], 0
    while i < len(s):
        if s[i].isspace():
            i += 1
        elif s.startswith("(*", i) and not s.startswith("(*)", i):
            depth = 1
            depth_max = max(depth_max, depth)
            i += 2
            while depth:
                assert i < len(s), "unterminated comment"
                if s.startswith("(*)", i):
                    i += 3  # Lexlib's explicit special case
                elif s.startswith("(*", i):
                    depth += 1
                    depth_max = max(depth_max, depth)
                    i += 2
                elif s.startswith("*)", i):
                    depth -= 1
                    i += 2
                else:
                    i += 1
        elif s[i] == '"':
            start = i
            i += 1
            while i < len(s) and s[i] != '"':
                i += 2 if s[i] == "\\" else 1
            assert i < len(s), "unterminated string"
            i += 1
            tokens.append(s[start:i])
            strings.append(s[start:i])
        else:
            m = re.match(r"[A-Za-z_][A-Za-z_0-9']*|[=<>~+*/%\\!$&?@^.:|#-]+", s[i:])
            token = m[0] if m else s[i]
            tokens.append(token)
            i += len(token)
    assert len(tokens) == 412 and len(strings) == 72
    assert max(map(len, strings)) == 121 and depth_max == 1
    return {"file_bytes": len(raw), "tokens_without_EOF": len(tokens),
            "strings": len(strings), "maximum_raw_string_bytes": max(map(len, strings)),
            "comment_nesting": depth_max, "tokens": tokens}


def check_native(dependencies):
    helper = "docs/evidence/retained-why-library-probe-paths-20261023/elf_reader.py"
    dependencies.add(helper)
    sys.path.insert(0, str((ROOT / helper).parent))
    from elf_reader import Elf
    p = HERE / "parser-native.json"
    dependencies.add(p.relative_to(ROOT).as_posix())
    native = json.loads(p.read_text())
    binary = Path(native["target"]).read_bytes()
    assert ident(binary) == native["target_identity"]
    elf = Elf(binary)
    total = 0
    for name, spec in native["modules"].items():
        assert ident(elf.at(spec["start"], spec["end"] - spec["start"])) == spec["identity"]
        text_path = HERE / (name + ".txt")
        dependencies.add(text_path.relative_to(ROOT).as_posix())
        raw = text_path.read_bytes()
        assert ident(raw) == spec["text_identity"]
        rows, function = {}, None
        for line in raw.decode().splitlines():
            m = re.search(r"<([^>]+)>:", line)
            if m:
                function = m[1]
                rows.setdefault(function, [])
            m = re.search(r"sub\s+\$0x([0-9a-f]+),%r15", line)
            if m:
                words, rem = divmod(int(m[1], 16), 8)
                assert rem == 0
                rows[function].append(words)
        kept = {k: v for k, v in rows.items() if not k.endswith("__entry")}
        assert kept == spec["functions"]
        assert sum(sum(v) for v in kept.values()) == spec["summed_bump_words"]
        total += spec["summed_bump_words"]
    assert total == native["sum_direct_bumps"] == 1629
    # The source argument bounds an elementary successful parser transition
    # by two traversals of this overinclusive set plus128 external words.
    assert 2 * total + 128 == 3386 < 4096
    for name, spec in native["wrapper_functions"].items():
        assert elf.symbols[name]["address"] == spec["address"]
        assert ident(elf.function(name)) == spec["identity"]
        path = HERE / (name + ".txt")
        dependencies.add(path.relative_to(ROOT).as_posix())
        assert ident(path.read_bytes()) == spec["text_identity"]
    return {"all_module_direct_bumps_words": total,
            "two_traversals_plus_external_words": 2 * total + 128,
            "per_successful_parser_transition_credit_words": 4096,
            "native_target_executions": 0}


SPANS = {
    "why3/src/driver/call_provers.ml": [(65, 115), (342, 408), (448, 458), (480, 497), (567, 583)],
    "why3/src/driver/driver.ml": [(104, 151), (247, 270)],
    "why3/src/driver/driver_lexer.mll": [(26, 42), (70, 78), (104, 145)],
    "why3/src/driver/driver_parser.mly": [(45, 194), (229, 229)],
    "why3/src/util/lexlib.mll": [(82, 126), (139, 148)],
    "why3/src/util/loc.ml": [(289, 299)],
    "why3/src/session/controller_itp.ml": [(114, 136), (344, 409), (448, 486), (592, 650)],
    "why3/src/session/session_itp.ml": [(586, 636), (645, 676), (737, 747), (1034, 1052), (2056, 2078)],
    "why3/src/session/json_util.ml": [(595, 618)],
    "why3/src/gnat/gnat_checks.ml": [(78, 109), (237, 264), (380, 417), (769, 828), (950, 972)],
    "why3/src/gnat/gnat_report.ml": [(135, 155), (216, 220)],
    "why3/src/gnat/gnat_main.ml": [(334, 356)],
    "why3/src/driver/prove_client.ml": [(161, 173), (230, 245)],
    "why3/src/server/server-unix.c": [(132, 143), (434, 500), (505, 546)],
    "why3/src/util/json_base.ml": [(28, 33), (57, 66)],
    "why3/src/util/debug.ml": [(158, 173)],
    "spark-source/src/common/vc_kinds.adb": [(1202, 1211)],
    "spark-source/src/gnatprove/report_database.adb": [(467, 473)],
    "spark-source/src/gnatprove/spark_report.adb": [(677, 711), (1161, 1191), (1197, 1218), (1562, 1568)],
    "gnatcoll/core/src/gnatcoll-json.adb": [(620, 628), (1350, 1358)],
}


def derive():
    dependencies = {WHY, REPORT, RESPONSE, PREFIX, OLD + "paths.json",
                    OLD + "configuration-repair.json", RE_API + "str.ml"}
    repair = json.loads((ROOT / (OLD + "configuration-repair.json")).read_text())
    base_dir = ROOT / OLD / "configuration"
    config = {}
    changed = []
    for path in sorted(base_dir.rglob("*")):
        if not path.is_file():
            continue
        rel = path.relative_to(base_dir).as_posix()
        raw = path.read_bytes()
        dependencies.add(path.relative_to(ROOT).as_posix())
        expected = repair["base_after"] if rel == "why3.conf" else repair["files"][path.name]["identity"]
        assert ident(raw) == expected, rel
        candidate = raw
        if rel == "overlay/slv-libv2.gen":
            lines = raw.splitlines(keepends=True)
            assert lines[22] == BEFORE and raw.count(BEFORE) == 1
            lines[22] = AFTER
            candidate = b"".join(lines)
            old_lines, new_lines = raw.splitlines(), candidate.splitlines()
            assert len(old_lines) == len(new_lines)
            assert old_lines[:22] == new_lines[:22] and old_lines[23:] == new_lines[23:]
            assert len(BEFORE) == 32 and len(AFTER) == 33
            assert len(candidate) == len(raw) + 1
            changed.append({"path": rel, "line": 23,
                            "before_hex": BEFORE.hex(), "after_hex": AFTER.hex(),
                            "before_bytes_with_LF": 32, "after_bytes_with_LF": 33,
                            "later_raw_offset_delta": 1,
                            "later_line_and_column_preserved": True})
        config["configuration/" + rel] = candidate
    assert len(config) == 7 and len(changed) == 1
    # The only added literal has an escaped backslash in driver syntax.
    literal = re.findall(rb'time "((?:[^"\\]|\\.)*)"', AFTER)
    assert literal == [b"\\\\="] * 3
    decoded = [x.replace(b"\\\\", b"\\") for x in literal]
    assert decoded == [bytes.fromhex("5c3d")] * 3
    assert all(b"%" not in x for x in decoded)
    lexical = lexical_census(config["configuration/overlay/slv-libv2.gen"])
    native_bounds = check_native(dependencies)

    # Reuse R78's exact unique-candidate import graph, without rerunning it.
    paths = json.loads((ROOT / (OLD + "paths.json")).read_text())
    loaded = {}
    for name, domain in paths["domains"].items():
        imports = {}
        for row in domain["driver_imports"]:
            imports.setdefault(row["from"], []).append(row["required_existing_candidate"])
        def common_visits(path, active=()):
            assert path not in active
            return int(path.endswith("/slv-libv2.gen")) + sum(
                common_visits(child, active + (path,)) for child in imports.get(path, []))
        roots = {r["root"]: r["required_existing_candidate"] for r in domain["driver_discovery"]}
        assert len(roots) == 9
        counts = {root: 3 * common_visits(path) for root, path in roots.items()}
        assert counts == {root: 3 if root in SELECTED else 0 for root in roots}
        loaded[name] = {"records_by_configured_root": counts,
                        "new_records": sum(counts.values()),
                        "common_file_parse_occurrences": 3,
                        "added_TIME_tokens": 9, "added_STRING_tokens": 9,
                        "added_located_global_productions": 9,
                        "decoded_pattern_bytes_hex": "5c3d",
                        "placeholder_searches": 9,
                        "placeholder_search_input_bytes": 2,
                        "placeholder_replacement_callbacks": 0,
                        "unit_array_length": 0}

    source_sets = [(WHY, archive(WHY)), (REPORT, archive(REPORT)), (RESPONSE, archive(RESPONSE))]
    witnesses = {}
    for member, spans in SPANS.items():
        provider, members = next((p, m) for p, m in source_sets if member in m)
        raw = members[member]
        lines = raw.decode().splitlines(keepends=True)
        assert max(hi for _, hi in spans) <= len(lines), member
        witnesses[member] = {"archive": provider, "identity": ident(raw),
                             "spans": [{"first": lo, "last": hi,
                                        "text": "".join(lines[lo-1:hi])} for lo, hi in spans]}
    why_members = source_sets[0][1]
    time_census = []
    for name, raw in sorted(why_members.items()):
        if name.startswith("why3/src/") and name.endswith(".ml"):
            for number, line in enumerate(raw.decode().splitlines(), 1):
                if re.search(r"\bpr_time\s*=", line):
                    time_census.append({"member": name, "line": number, "text": line})
    assert [(x["member"], x["line"]) for x in time_census] == [
        ("why3/src/driver/call_provers.ml", 387),
        ("why3/src/driver/call_provers.ml", 397),
        ("why3/src/driver/call_provers.ml", 571),
        ("why3/src/gnat/gnat_checks.ml", 253),
        ("why3/src/session/controller_itp.ml", 354),
        ("why3/src/session/controller_itp.ml", 408),
        ("why3/src/session/json_util.ml", 599),
        ("why3/src/session/json_util.ml", 614),
        ("why3/src/session/session_itp.ml", 1044),
    ]
    assert not any(re.search(rb"\bpr_time\s*<-", raw) for name, raw in why_members.items()
                   if name.startswith("why3/src/") and name.endswith(".ml"))

    prefix = json.loads((ROOT / PREFIX).read_text())
    margins = {}
    for name, row in prefix["domains"].items():
        b = row["bounds"]
        margins[name] = {"retained_bounds": b,
                         "strict_additional_margins": {
                             "minor_words": 2**28 - b["minor_words"],
                             "current_major_words": 2**28 - b["current_major_words"],
                             "all_major_words": 2**24 - b["all_major_words"],
                             "remembered_entries": 2**25 - b["remembered_entries"]}}
    minima = {key: min(x["strict_additional_margins"][key] for x in margins.values())
              for key in next(iter(margins.values()))["strict_additional_margins"]}
    assert minima == {"minor_words": 132913732, "current_major_words": 259912143,
                      "all_major_words": 8250999, "remembered_entries": 14560710}
    n = lexical["tokens_without_EOF"] + 1
    reductions = 16 * n
    transitions = reductions + 2 * n
    lexer_words = 17 * (lexical["file_bytes"] + 1) + 128 * n + 512
    parser_words = 4096 * transitions
    delta_minor = 3 * (lexer_words + parser_words) + 9 * (4096 + 64 + 128)
    assert delta_minor == 91752681 < minima["minor_words"]
    allocation = {"status": "numeric successful-prefix derivation; review pending",
                  "lexical": lexical, "native_parser": native_bounds,
                  "reductions_per_common_parse_upper": reductions,
                  "transitions_per_common_parse_upper": transitions,
                  "lexer_words_per_common_parse": lexer_words,
                  "parser_words_per_common_parse": parser_words,
                  "common_parse_occurrences": 3,
                  "placeholder_words_per_record": 4096,
                  "Call_substitution_and_list_words_per_record": 64,
                  "Start_construction_words_per_record": 128,
                  "new_timing_records": 9,
                  "startup_minor_words": delta_minor,
                  "startup_major_words": 0, "startup_remembered_entries": 0,
                  "startup_ephemeron_entries": 0, "startup_custom_entries": 0,
                  "startup_extra_minor_resources": 0, "startup_extra_major_resources": 0,
                  "startup_dependent_bytes": 0, "new_native_buffer_or_descriptor_owners": 0,
                  "largest_added_managed_payload_words_upper": 256,
                  "later_owned_words": "512*o + 266*q + 7*T; o<=9 and q<=3*T",
                  "later_result_count_T": "all ProverFinished result deliveries, including empty-filename queued cancellations",
                  "later_GC_copying_and_runtime_owners_included": False,
                  "global_allowance_renewed": False}
    # Maxima and copy operations preserve a closed set; this finite calculation
    # does not replace the source-origin/reachability or Float conversion proof.
    values = (0, 1)  # units of the retained mu, not integer seconds
    assert {max(a, b) for a in values for b in values} == set(values)
    assert {v for a in values for b in values for v in (a, b)} == set(values)
    recipe = {"status": "candidate, not adopted", "baseline": OLD + "configuration",
              "files": {p: ident(b) for p, b in config.items()}, "edits": changed,
              "decoded_pattern_hex": "5c3d", "loaded": loaded,
              "command_and_prover_keys_unchanged": True,
              "configured_solver_time_and_step_limits": 0,
              "fresh_session_required": True, "CE_and_replay": False,
              "global_escaping_save_events_upper": 2,
              "save_entering_callbacks_upper": 2, "save_calls_upper": 3,
              "allowance_renewed": False}
    result = {"status": "source/configuration and numeric startup candidate; review pending",
              "normal_result_time": "mu = binary64 literal 0.000001",
              "all_reachable_attempt_times": ["0", "mu"],
              "reported_maximum_time_ceiling_seconds": 1,
              "prover_credit_and_max_steps_may_change": True,
              "same_attempt_identity_answer_status_fields": True,
              "required_native_owner_theorem": "retained-reported-time-native.md",
              "startup_allocation_delta_numeric": {k: v for k, v in allocation.items() if k.startswith("startup_")},
              "retained_prefix_margins": margins,
              "uniform_strict_delta_margins": minima,
              "pre_JSON_cut": "after create_controller/load_drivers, before add_file",
              "pre_JSON_entry_transfer": "transfer.py consumes the baseline entry object and recipe identity; no captured endpoint subtraction",
              "target_runs": 0, "prior_checker_replays": 0,
              "complete_capacity_provider": False, "configuration_adopted": False}
    outputs = {"recipe.json": encoded(recipe), "source-witnesses.json": encoded(witnesses),
               "time-origin-census.json": encoded(time_census), "allocation.json": encoded(allocation),
               "result.json": encoded(result), **config}
    return outputs, dependencies


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true", help="regenerate only this packet's derived fixtures")
    parser.add_argument("--baseline-root", type=Path, default=ROOT,
                        help="checkout containing the separately frozen baseline/native providers")
    args = parser.parse_args()
    started = time.monotonic()
    outputs, dependencies = derive()
    for name, raw in outputs.items():
        path = HERE / name
        if args.write:
            path.parent.mkdir(parents=True, exist_ok=True)
            path.write_bytes(raw)
        else:
            assert path.read_bytes() == raw, name
    baseline_path = HERE / "baseline-entry-projection.json"
    baseline = json.loads(baseline_path.read_text())
    dependency = args.baseline_root / baseline["source_path"]
    assert ident(dependency.read_bytes()) == baseline["source_identity"]
    # Invoke only the provider's arithmetic function, never its checker.
    baseline_functions = runpy.run_path(str(dependency))
    assert baseline_functions["all_envelopes"]() == baseline["envelopes"]
    extension = runpy.run_path(str(HERE / "transfer.py"))
    later_cases = json.loads((HERE / "later-allocation-cases.json").read_text())["cases"]
    assert any(case["ordinary_file_results"] == 0 and case["queued_cancellations"] > 0
               and case["attempted_searches"] == case["owners"] == 0
               and case["expected_words"] > 0 for case in later_cases)
    for case in later_cases:
        finished_results = case["ordinary_file_results"] + case["queued_cancellations"]
        assert case["attempted_searches"] <= 3 * case["ordinary_file_results"], case["name"]
        assert extension["later_owned_words"](
            finished_results=finished_results, attempted_searches=case["attempted_searches"],
            owners=case["owners"]) == case["expected_words"], case["name"]
    extended = extension["all_envelopes"]()
    assert max(v["minor_history_words_upper"] for v in extended.values()) == 227274405
    assert max(v["managed_static_carrier_words_upper"] for v in extended.values()) == 237953393
    assert all(all(v["guards"].values()) for v in extended.values())
    assert all(v["process_budget"] == {"escaping_save_exceptions": 2,
                "save_entering_callbacks": 2, "saves": 3} for v in extended.values())
    extension_raw = encoded(extended)
    if args.write:
        (HERE / "entry-extension.json").write_bytes(extension_raw)
    else:
        assert (HERE / "entry-extension.json").read_bytes() == extension_raw
    for name in ("baseline-entry-projection.json", "transfer.py", "native-providers.json",
                 "later-allocation-cases.json"):
        dependencies.add((HERE / name).relative_to(ROOT).as_posix())
    provider_records = json.loads((HERE / "native-providers.json").read_text())
    for name, expected in provider_records["files"].items():
        assert ident((args.baseline_root / name).read_bytes()) == expected
    dependencies.add((HERE / "check.py").relative_to(ROOT).as_posix())
    inputs = {"files": {p: ident((ROOT / p).read_bytes()) for p in sorted(dependencies)}}
    if args.write:
        (HERE / "inputs.json").write_bytes(encoded(inputs))
    else:
        assert json.loads((HERE / "inputs.json").read_text()) == inputs
    print(json.dumps({"status": "pass", "checked_outputs": len(outputs) + 1,
                      "input_files": len(dependencies), "target_runs": 0,
                      "later_allocation_cases": len(later_cases),
                      "prior_checker_replays": 0, "elapsed_seconds": time.monotonic() - started,
                      "baseline_provider_identity": baseline["source_identity"],
                      "external_provider_root": str(args.baseline_root),
                      "complete_capacity_provider": False}, sort_keys=True))


if __name__ == "__main__":
    main()
