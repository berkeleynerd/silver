"""Independent R71 frozen-input audit. Never import author/provider programs."""
from pathlib import Path
import hashlib
import itertools
import json
import re
import subprocess
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
CHECKS = 0
ARCHIVES = {}


def check(ok, label):
    global CHECKS
    CHECKS += 1
    if not ok:
        raise AssertionError(label)


def identity(raw):
    return {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}


def read(path):
    return json.loads((ROOT / path).read_bytes())


def member(archive, name):
    if archive not in ARCHIVES:
        ARCHIVES[archive] = tarfile.open(ROOT / archive)
    entry = ARCHIVES[archive].getmember(name)
    check(entry.isfile(), "complete named archive member")
    return ARCHIVES[archive].extractfile(entry).read()


def protocol_audit():
    packet = "docs/evidence/retained-current-protocol-join-20261023/"
    result = read(packet + "result.json")
    cuts = read("docs/evidence/retained-parallel-logging-prefix-20261020/cut-projection.json")
    combined = read("docs/evidence/retained-combined-parallel-startup-20261020/projection.json")["domains"]
    six = read("docs/evidence/retained-six-owner-round63-20261023/candidate-composition-result.json")
    owner = {row["case"].replace("-", "_"): row for row in six["cases"]}
    old = read("docs/evidence/retained-adapter-protocol-storage-20261020/result.json")
    old_rows = {row["case"]: row for row in old["cases"]}
    canonical = {row["case"]: row for row in read("docs/evidence/retained-why-canonical-json-input-20261023/result.json")["cases"]}
    expected = []
    for case, g, raw, pid in [
        ("put_line", 51, 64, 22236), ("put", 42, 53, 22524),
        ("first_or_default", 22, 32, 21865), ("is_message", 2, 3, 22653),
        ("input_is_valid", 1, 4, 22222),
    ]:
        cut, joined, demand = cuts[case], combined[case], owner[case]
        keys = [r["goal"] for r in cut["fixed_root_map"]]
        check(len(keys) == len(set(keys)) == g, "current complete registration map")
        check(cut["session_counters"]["next_proofNodeID"] - 1 == raw, "current raw child count")
        check(cut["captured_pid"] == joined["original_pid"] == demand["attachment"]["retained_j12_pid"] == canonical[case]["j12_pid"] == pid, "same current registration process")
        check(joined["session_counters"] == cut["session_counters"], "combined startup session counter relation")
        check(joined["registered_root_count"] == demand["demand"]["registered_roots"] == g, "root count transported")
        check(demand["demand"]["preparation_episodes_upper"] == canonical[case]["N"] == 3*g+2, "broader preparation owner")
        old_row = old_rows[case]
        check(3*g <= old_row["run_entries"] == old_row["interrupt_entries"], "componentwise old wire envelope")
        check(len(str(3*g)) <= old_row["positive_ID_digits"], "positive original ID digits")
        if case == "input_is_valid":
            check(keys == [3], "Input own J12 goal ID, not post-CE forest")
        expected.append({"case": case, "j12_pid": pid, "raw_children": raw,
            "registered_roots": g, "parallel_wire_entries_upper": 3*g,
            "broader_preparation_episodes_upper": 3*g+2,
            "retained_protocol_entries_upper": old_row["run_entries"],
            "retained_ID_digits": old_row["positive_ID_digits"]})
    check(expected == result["cases"], "exact protocol projection")
    check(sum(r["parallel_wire_entries_upper"] for r in expected) == result["current_wire_entries_upper"] == 354, "wire total")
    check(sum(r["retained_protocol_entries_upper"] for r in expected) == old["total_attempts_upper"] == result["retained_protocol_entries_upper"] == 459, "retained slot total")
    check(old["response_records_upper"] == 918 and old["canonical_file_payload_bytes"] == 34884 and old["ring_old_new_backing_bytes_J12"] == 41536, "unchanged accepted storage terms")
    check(result["raw_backend_file_bytes_upper"] is None and not result["shared_server_connection_refinement_established"] and not result["whole_capacity_rule_complete"] and not result["global_budget_renewed"], "protocol boundary remains open")
    return {"protocol_cases": len(expected), "current_wire_entries": 354, "retained_wire_slots": 459}


def resize_prefix_model():
    """Small independent graph experiment supporting, not proving, rank induction.

    Enumerate all doubled-bucket hashes for N0=2B0 with B0=1,2, every
    false-miss duplicate key, and every published resize-write prefix. The
    production minimum B0=16 is established by source; the model isolates
    structural behavior independently of that numeric minimum.
    """
    prefixes = cases = 0
    for b in (1, 2):
        n = 2*b
        for hashes in itertools.product(range(2*b), repeat=n):
            for duplicate in range(n):
                cases += 1
                keys = list(range(n)) + [duplicate]
                old = [None]*b
                links = {}
                for cell, key in enumerate(keys):
                    bucket = hashes[key] % b
                    links[cell], old[bucket] = old[bucket], cell
                order = []
                for root in old:
                    while root is not None:
                        order.append(root)
                        root = links[root]
                rank = {cell: i for i, cell in enumerate(order)}
                roots, tails = [None]*(2*b), [None]*(2*b)

                def snapshot():
                    nonlocal prefixes
                    prefixes += 1
                    check(all(nxt is None or rank[cell] < rank[nxt] for cell, nxt in links.items()), "every relink follows original traversal rank")
                    published = roots[:]
                    graph = dict(links)
                    live_keys = set()
                    reachable = set()
                    for bucket, root in enumerate(published):
                        seen = set()
                        while root is not None:
                            check(root not in seen, "published chain acyclic")
                            seen.add(root)
                            reachable.add(root)
                            if hashes[keys[root]] == bucket:
                                live_keys.add(keys[root])
                            root = graph[root]
                    missing = n-len(live_keys)
                    if reachable:
                        check(bool(live_keys), "nonempty new graph retains a correctly bucketed initial key")
                        check(n+1+missing <= 4*b, "nonempty damaged graph cannot reach second resize")
                    else:
                        check(missing == n, "empty graph misses all initial names")
                        # Every subsequent restoration prepends a fresh cell to
                        # one bucket. No old cell is reachable, so this graph
                        # is disjoint even if the next addition triggers resize.
                    check(n+1+missing <= 2*n+2, "physical allocation count upper")

                snapshot()  # h.data publication, before first root store
                for cell in order:
                    bucket = hashes[keys[cell]]
                    if tails[bucket] is None:
                        roots[bucket] = cell
                    else:
                        links[tails[bucket]] = cell
                    snapshot()
                    tails[bucket] = cell
                    snapshot()
                for tail in tails:
                    if tail is not None:
                        links[tail] = None
                        snapshot()
    return {"resize_model_initial_cases": cases, "resize_model_mutation_prefixes": prefixes,
            "resize_model_bucket_sizes": [1, 2], "resize_model_is_universal_proof": False}


FILETAGS = "docs/evidence/retained-why-filetags-capacity-20261023/"
PARSER = "docs/evidence/retained-why-canonical-parser-capacity-20261023/"
WHY = "docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz"


def source_audit():
    spans = 0
    complete = set()
    rendered = []
    for row in read(FILETAGS + "source-ranges.json"):
        raw = member(row["archive"], row["member"])
        check(identity(raw) == row["identity"], "FileTags complete source identity")
        lines = raw.decode().splitlines(keepends=True)
        rendered.append(f"## {row['archive']} :: {row['member']}\n")
        for span in row["ranges"]:
            first, last = span["start"], span["end"]
            check(1 <= first <= last <= len(lines), "FileTags strict source range")
            excerpt = "".join(lines[first-1:last])
            check(identity(excerpt.encode()) == span["identity"], "FileTags source range bytes")
            rendered.append(f"### Lines {first}–{last}\n\n```text\n{excerpt}```\n")
            spans += 1
        complete.add((row["archive"], row["member"]))
    check((ROOT / (FILETAGS + "source-witnesses.md")).read_text() == "# FileTags source witnesses\n\n" + "\n".join(rendered), "FileTags rendered exact witnesses")
    for row in read(PARSER + "source-spans.json"):
        if "archive" in row:
            raw = member(row["archive"], row["member"])
            key = row["archive"], row["member"]
        else:
            raw = (ROOT / row["file"]).read_bytes()
            key = row["file"], None
        check(identity(raw) == row["file_identity"], "parser complete source identity")
        lines = raw.decode().splitlines(keepends=True)
        first, last = row["first"], row["last"]
        check(1 <= first <= last <= len(lines), "parser strict source range")
        check("".join(lines[first-1:last]) == row["text"], "parser strict source bytes")
        spans += 1
        complete.add(key)
    manifest = read(PARSER + "re-source/manifest.json")
    check(manifest["commit"] == "f09672608781dc05172ad980a6e9a483c3b9d534", "same reference Re commit")
    check(set(manifest["files"]) == {"category.ml", "group.ml", "mark_infos.ml", "pmark.ml"}, "exact four-source fetch scope")
    for name, spec in manifest["files"].items():
        check(identity((ROOT / (PARSER + "re-source/" + name)).read_bytes()) == {k: spec[k] for k in ("bytes", "sha256")}, "new Re complete source identity")
        check(spec["url"] == f"https://raw.githubusercontent.com/ocaml/ocaml-re/{manifest['commit']}/lib/{name}", "new source exact URL attachment")
    return {"strict_source_ranges": spans, "complete_source_inputs": len(complete), "new_reference_source_files": 4}


def filetags_audit():
    result = read(FILETAGS + "projection.json")
    startup = read("docs/evidence/retained-combined-parallel-startup-20261020/projection.json")
    n = startup["candidate_filetags_names_upper"]
    check(n == startup["baseline_major_words"] + 1 == 945214, "accepted initial FileTags envelope")
    b = max(2**k for k in range(30) if 2**k <= max(16, n))
    cells, cap = 2*n+2, 4*b
    common = {"initial_names_upper": n, "initial_backing_upper": b,
        "suffix_forward_add_attempts_upper": n+2, "suffix_reverse_add_attempts_upper": n+2,
        "suffix_counter_increments_upper": n+2, "counter_upper": cells,
        "size_upper_per_table": cells, "physical_cells_allocated_upper_per_table": cells,
        "backing_and_tail_extent_upper": cap, "threshold_and_attempted_doubling_upper": 8*b,
        "lookup_chain_cells_upper": cells, "single_array_bytes_including_header_upper": 8*(cap+1),
        "summed_root_occurrences_upper_per_table": cap*cells,
        "suffix_bucket_request_words_both_tables": 8*(n+2),
        "suffix_backing_tail_request_words_both_tables": 4*((2*b+1)+(4*b+1)),
        "actual_N0": None, "actual_B0": None, "representation_guards_pass": True}
    common["suffix_bucket_array_request_words_both_tables"] = common["suffix_bucket_request_words_both_tables"] + common["suffix_backing_tail_request_words_both_tables"]
    for case, row in result["domains"].items():
        check(row == common, "complete FileTags numerical projection " + case)
    check(len(result["domains"]) == 5 and b == 524288 and cap == 2097152 and cells == 1890430, "five common FileTags guards")
    check(cells < 2**62-1 and 8*b < 2**62-1 and cap < 2**54-1 and 8*(cap+1) < 2**63, "FileTags representation arithmetic")
    check(result["global_e_upper"] == result["save_entering_callbacks_upper"] == 2 and result["saves_upper"] == 3 and not result["renewed_failure_budget"], "single global exception/save budget")
    check(not result["arbitrary_resumed_resource_failure_closure"] and not result["whole_process_capacity_established"] and result["whole_routine_allocation_bound"] is None, "FileTags resource/allocation scope")
    # Inventory matching is performed over every complete source member, not
    # over the author's already-selected hits or basename aliases.
    if WHY not in ARCHIVES:
        ARCHIVES[WHY] = tarfile.open(ROOT / WHY)
    found, scanned = [], 0
    names = {"FileTags", "get_file_tag", "tag_counter", "user_position", "position_of_sexp"}
    for entry in ARCHIVES[WHY].getmembers():
        if not entry.isfile() or not entry.name.startswith(("why3/src/", "why3/plugins/")) or Path(entry.name).suffix not in {".ml", ".mli", ".mll", ".mly"}:
            continue
        scanned += 1
        raw = member(WHY, entry.name)
        hits = []
        for line_number, line in enumerate(raw.decode().splitlines(), 1):
            words = set(re.findall(r"\b\w+\b", line))
            alias = re.search(r"\b(?:open|include)\s+(?:Why3\.)?Loc\b|\bmodule\s+\w+\s*=\s*(?:Why3\.)?Loc\b", line)
            if names & words or re.search(r"\bLoc\.extract\b", line) or alias:
                hits.append({"line": line_number, "text": line})
        if hits:
            found.append({"member": entry.name, "identity": identity(raw), "hits": hits})
    check({"files": found, "source_files_scanned": scanned} == read(FILETAGS + "call-census.json"), "complete FileTags call/private/alias census")
    loc = member(WHY, "why3/src/util/loc.ml").decode()
    public = member(WHY, "why3/src/util/loc.mli").decode()
    check("FileTags" not in public and "tag_counter" not in public, "FileTags owner not exported")
    check(loc.count("FileTags.get_file_tag") == 2, "only direct dummy/user_position entries")
    private = loc.split("module FileTags = struct", 1)[1].split("type position =", 1)[0]
    check(not re.search(r"\.(?:iter|fold|copy|clear|remove|replace|reset)\b", private), "private tables have no traversal or destructive client")
    roles = read("docs/evidence/retained-parallel-logging-prefix-20261020/input-role-projection.json")
    initial = read("docs/evidence/retained-why-report-path-inputs-20261023/library-projection.json")
    check(len(initial) == 21, "accepted complete initial library family")
    by_member = {r["member"]: r for r in initial}
    joined = read(FILETAGS + "library-domain-join.json")
    for case, rows in joined.items():
        check({r["library"] for r in rows} == {"int", "real", "algebra", "relations"}, "four later library producers")
        opens = {r["path"]: r for r in roles[case]["captures"][1]["ordered_opens"]}
        for row in rows:
            full = "installed/libexec/spark/share/why3/theories/" + row["library"] + ".mlw"
            provider = by_member[full]
            raw = member("docs/evidence/retained-producer-import-context-20261018/sources.tar.gz", full)
            check(identity(raw) == provider["identity"] == row["identity"] == opens[row["path"]]["identity"], "complete later library byte/initial-open join")
            check(row["path"].endswith("/" + full.removeprefix("installed/")), "complete later filename spelling")
            check(all(raw.count(token) == 0 for token in (b"[#", b"vc:written:", b"call_result:")), "no raw virtual/location-attribute origin")
            check(any(line.lstrip().startswith((b"theory ", b"module ")) for line in raw.splitlines()), "initial parser sees a named location producer")
    return {"FileTags_cases": len(result["domains"]), "source_files_censused": scanned, "source_files_with_location_hits": len(found), "initial_later_library_joins": sum(map(len, joined.values()))}


def parser_audit():
    result = read(PARSER + "result.json")
    originals = read("docs/evidence/retained-adapter-outcome-interface-20261020/canonical-table.json")
    directives = read("docs/evidence/retained-adapter-outcome-interface-20261020/loaded-response-directives.json")
    by_driver = {}
    for driver, key, length, count in [("cvc5", "cvc5_gnatprove.drv", 401, 13), ("z3", "z3_gnatprove.drv", 247, 5), ("altergo", "alt_ergo_gnatprove_smt2.drv", 243, 6)]:
        rules = [r for r in directives[key] if r["directive"] != "time"]
        check(len(rules) == count, "exact timeless answer rule count")
        check(all(r["directive"] not in {"time", "steps", "exitcode", "failure"} for r in rules), "selected parser route omissions")
        union = "\\(" + "\\|".join(r["args"][0] for r in rules) + "\\)"
        check(union.isascii() and len(union.encode()) == length, "exact union bytes")
        check(result["patterns"][driver]["union"] == union and result["patterns"][driver]["rules"] == rules, "exact rule/union attachment")
        check(result["patterns"][driver]["rule_count"] == count and result["patterns"][driver]["string_events"] == 2*count+1, "union event arithmetic")
        # Critical syntax inventory without running either regexp engine.
        for pattern in [union] + [r["args"][0] for r in rules]:
            offset, groups, depth, previous = 0, 0, 0, None
            while offset < len(pattern):
                c = pattern[offset]
                if c == "\\":
                    offset += 1
                    c = pattern[offset]
                    if c == "(":
                        groups += 1; depth += 1; previous = None
                    elif c == ")":
                        depth -= 1; previous = "group"
                    elif c == "|": previous = None
                    else:
                        check(c in "[]*+?.^$\\", "no backreference or numeric escape")
                        previous = "set"
                elif c == "[":
                    offset = pattern.index("]", offset+1)
                    previous = "set"
                elif c in "*+?":
                    check(previous == "set", "repetition only of single Set")
                    previous = "repeat"
                else:
                    check(c not in "{}", "no numeric repetition spelling")
                    previous = "boundary" if c in "^$" else "set"
                check(depth >= 0, "balanced group prefix")
                offset += 1
            check(depth == 0 and groups <= 3, "bounded balanced explicit groups")
        by_driver[driver] = rules
    check(len(originals) == len(result["rows"]) == 31, "exact canonical row count")
    # Literal line cases reconstruct byte spans, independently of the author's
    # translated Python regex census. The source review establishes that other
    # configured alternatives cannot match these five literal line families.
    for original, row in zip(originals, result["rows"]):
        check(all(row[key] == value for key, value in original.items()), "exact original canonical row")
        data = original["output"]
        check(data.isascii() and len(data) == original["bytes"] <= 76, "canonical ASCII byte length")
        rules = by_driver[original["driver"]]
        segments, start, delimiters = [], 0, 0
        if data == "!\n":
            segments = [{"kind": "Text", "start": 0, "end": 2}]
        else:
            for line in data.splitlines(keepends=True):
                check(line.endswith("\n"), "canonical complete LF line")
                body = line[:-1]
                groups = []
                if body == "unknown":
                    pattern = r"^\(unknown\|sat\|Fail\)$"; groups = [body]
                elif body == "unsat": pattern = "^unsat$"
                elif body in {"(:reason-unknown resourceout)", "(:reason-unknown timeout)"}:
                    pattern = r"^(:reason-unknown \([^)]*\))$"
                    groups = [body[len("(:reason-unknown "):-1]]
                else:
                    check(body == "Cannot allocate memory", "only selected memory literal")
                    alternatives = [r["args"][0] for r in rules if "Cannot allocate memory" in r["args"][0]]
                    check(len(alternatives) == 1, "unique canonical memory alternative")
                    pattern = alternatives[0]
                choices = [i for i, rule in enumerate(rules) if rule["args"][0] == pattern]
                check(len(choices) == 1, "unique canonical line rule")
                end = start + len(body)
                segments.extend([{"kind": "Delim", "start": start, "end": end,
                    "individual_matches": [{"rule": choices[0], "span": [0, len(body)], "groups": groups}]},
                    {"kind": "Text", "start": end, "end": end+1}])
                delimiters += 1
                start = end+1
        check(row["segments"] == segments, "independent literal canonical split spans")
        total = sum(s["end"]-s["start"] for s in segments if s["kind"] == "Delim")
        check(row["delimiter_bytes"] == total <= 76 and delimiters <= 4 and len(segments) <= 8, "disjoint delimiter owner totals")
        check(row["union_search_upper"] == delimiters+1 and row["grep_search_upper"] == delimiters*len(rules), "canonical search upper bounds")
    expected_guards = {"input_bytes":76,"reader_buffer":1024,"reader_scratch":1024,
        "native_input_buffer":65536,"union_format_bytes":401,"union_format_events":64,
        "union_buffer":512,"regexp_records_per_parser":14,"lazy_cells_per_parser":28,
        "union_state_add_upper":402,"answer_state_add_upper":86,"union_table_buckets":256,
        "answer_table_buckets":128,"transition_array_words":257,"working_bits":512,
        "position_array_words":2048,"mark_array_words":8,"compile_id_upper":64*(401+8)**2}
    check(result["guard_inputs"] == expected_guards, "complete reference representation operands")
    check(5*(76+2)+2 <= 402 <= 512 and 76+2*4+2 == 86 < 256, "cache additions and resize thresholds")
    check(402 < 512 and 2*(512+1) < 2048 and 2*(3+1) == 8 and 64*409**2 == 10705984 < 2**62-1, "reference bit/position/mark/ID guards")
    for case, q in [("Put_Line",155),("Put",128),("First_Or_Default",68),("Is_Message",8),("Input_Is_Valid",5)]:
        check(result["domains"][case] == {"Q":q,"reader_attempts":q,"parser_attempts":q,"positive_reads_plus_eof":77*q,"regexp_constructors":14*q,"search_calls":57*q,"replacement_attempts":52*q}, "complete parser invocation projection")
    return {"canonical_rows": len(originals), "literal_span_reconstruction_without_regex_engine": True, "installed_Re_numerical_correspondence_established": False}


def main():
    start = time.perf_counter()
    inputs = read(str(HERE.relative_to(ROOT) / "inputs.json"))
    for label in ("exact_inputs", "providers"):
        for path, expected in inputs[label].items():
            check(identity((ROOT / path).read_bytes()) == expected, label + " " + path)
    for path, commit in inputs["file_commits"].items():
        raw = subprocess.check_output(["git", "show", commit + ":" + path], cwd=ROOT)
        check(identity(raw) == inputs["exact_inputs"][path], "exact author commit bytes " + path)
    details = {}
    for audit in (source_audit, filetags_audit, parser_audit, protocol_audit, resize_prefix_model):
        details.update(audit())
    result = {"status":"pass", "checks":CHECKS, "elapsed_seconds":time.perf_counter()-start,
        "author_freezes":inputs["author_freezes"], "exact_inputs":inputs["exact_inputs"],
        "providers":inputs["providers"], "audit_code_identity":identity(Path(__file__).read_bytes()),
        "exact_author_files":len(inputs["exact_inputs"]), "provider_identities":len(inputs["providers"]),
        "author_or_predecessor_replays":0, "target_executions":0, "native_captures":0,
        "regex_engine_executions":0, **details}
    (HERE / "audit-result.json").write_text(json.dumps(result, indent=2, sort_keys=True)+"\n")
    print(json.dumps({k:v for k,v in result.items() if k not in {"exact_inputs","providers","author_freezes"}}, sort_keys=True))


if __name__ == "__main__":
    main()
