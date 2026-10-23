"""Independent diagnostic-output audit; never imports provider programs."""
from __future__ import annotations

import hashlib
import json
from collections import Counter
from pathlib import Path
import re
import subprocess
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
CHECKS = 0


def check(predicate, label):
    global CHECKS
    CHECKS += 1
    if not predicate:
        raise AssertionError(label)


def read(path):
    return json.loads((ROOT / path).read_text())


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def pin_file(path, expected):
    actual = identity((ROOT / path).read_bytes())
    check(actual == expected, "file identity: " + path)
    return actual


def source_spans(archive_path, spans):
    if archive_path is None:
        count, names = 0, []
        for name in sorted({span["archive"] for span in spans}):
            n, members = source_spans(name, [span for span in spans if span["archive"] == name])
            count += n
            names.extend(members)
        return count, names
    members = {}
    with tarfile.open(ROOT / archive_path) as archive:
        for span in spans:
            member = span["member"]
            if member not in members:
                members[member] = archive.extractfile(member).read()
            raw = members[member]
            if "member_identity" in span:
                check(identity(raw) == span["member_identity"], "member: " + member)
            else:
                check(identity(raw)["sha256"] == span["member_sha256"], "member: " + member)
            lines = raw.decode().splitlines(keepends=True)
            first = span.get("first", span.get("start"))
            last = span.get("last", span.get("end"))
            check(1 <= first <= last <= len(lines), "strict range: " + member)
            check("".join(lines[first - 1:last]) == span["text"],
                  "source text: " + member)
    return len(spans), [(archive_path, member) for member in sorted(members)]


def canonical_check():
    packet = "docs/evidence/retained-why-canonical-json-input-20261023/"
    result = read(packet + "result.json")
    table = read("docs/evidence/retained-adapter-outcome-interface-20261020/canonical-table.json")
    check(len(table) == 31, "canonical row count")
    for row in table:
        data = row["output"].encode("ascii")
        check(row["bytes"] == len(data) <= 76, "canonical exact bytes")
    check(max(row["bytes"] for row in table) == 76, "canonical maximum")
    check(any(row["warning"] for row in table), "canonical warnings retained")

    cuts = read("docs/evidence/retained-parallel-logging-prefix-20261020/cut-projection.json")
    owners = read("docs/evidence/retained-why-callback-demand-20261023/result.json")
    owner_map = {row["case"].replace("-", "_"): row for row in owners["cases"]}
    expected = {
        "put_line": (64, 14, 155, 22, 20),
        "put": (53, 12, 128, 18, 16),
        "first_or_default": (32, 10, 68, 9, 9),
        "is_message": (3, 1, 8, 1, 1),
        "input_is_valid": (4, 3, 5, 1, 1),
    }
    rows = []
    for row in result["cases"]:
        case = row["case"]
        g, a0, n, r, key_count = expected[case]
        cut = cuts[case]
        counters = cut["session_counters"]
        check(counters == {"next_fileID": 1, "next_proofAttemptID": a0,
                           "next_proofNodeID": g + 1, "next_transID": 1},
              case + " current counters")
        check(cut["goal_ids"] == list(range(g + 1)), case + " raw goal range")
        roots = cut["fixed_root_map"]
        check(len({root["goal"] for root in roots}) == len(roots) <= g,
              case + " unique registered leaf ownership")
        check(all(1 <= root["goal"] <= g for root in roots), case + " leaf membership")
        keys = {(root["check_id"], root["check_kind"], root["source_location"])
                for root in roots}
        check(len(keys) == key_count <= r, case + " check domain")
        check(owner_map[case]["same_process_preparation_episode_upper"] == n,
              case + " current scheduling provider")
        check("--debug-prover-errors" not in cut["prospective_argv"],
              case + " absent debug output option")
        a = a0 + n
        oa, op = 76 * a, 76 * n
        o = max(oa, op)
        for field, value in {"G": g, "A0": a0, "A": a, "N": n,
                             "E": n, "R": r, "O": o,
                             "answer_occurrence_output_bytes_upper": oa,
                             "parser_invocation_output_bytes_upper": op}.items():
            check(row[field] == value, case + " " + field)

        # Reconstruct the accepted tree schema before affine simplification.
        # Wo=Lo=X=0 here; their independent coefficients are checked below.
        s, k, lt = 5 * r, 26, 1051
        la, wc, lc = 4 * o + 64 * a, o + n, 514 * o + 512 * n

        def schema(wo=0, lo=0, x=0):
            w, lw = wc + wo + 1, lc + lo + 26619
            c = 4 + 6 * r + s + 3 * g + a
            v = c + 9 * r + 3 * s + 3 * a + k + w + 1
            f = 4 + 14 * r + 4 * s + 2 * g + 4 * a + k
            ns, ni, nf, nb = 2 * r + a + w, 3 * r + 2 * s + a + 1, s + a + k, 4 * r
            length = 28 + 139 * r + 29 * s + 29 * g + 22 * a + la + lt + lw
            b = 2 * c + (v - 1) + 3 * f + 2 * ns + 6 * length + 20 * ni + 317 * nf + 5 * nb
            e = 2 * c + (v - 1) + 3 * f + 2 * ns + 2 * length + ni + nf + nb
            return b + 2 * 42 + 6 * x, e + 2 * 53 + 2 * x

        b, e = schema()
        check(row["JSON_B"] == {"constant": b, "W_o": 3, "L_o": 6, "X": 6},
              case + " JSON B schema")
        check(row["JSON_E"] == {"constant": e, "W_o": 3, "L_o": 2, "X": 2},
              case + " JSON E schema")
        check(schema(1, 0, 0) == (b + 3, e + 3), case + " warning count coefficient")
        check(schema(0, 1, 0) == (b + 6, e + 2), case + " warning length coefficient")
        check(schema(0, 0, 1) == (b + 6, e + 2), case + " abort length coefficient")
        check(row["actual_JSON_B"] is None and row["actual_JSON_E"] is None,
              case + " authored symbolic inputs preserved")
        check(row["whole_standard_core_guards_established"] is False,
              case + " no premature whole-core closure")
        rows.append({"case": case, "R": r, "G": g, "A": a, "N": n,
                     "O": o, "JSON_B_constant": b, "JSON_E_constant": e})
    check({row["case"] for row in result["cases"]} == set(expected), "five canonical cases")
    return rows


def terminal_check():
    packet = "docs/evidence/retained-why-terminal-diagnostic-bytes-20261023/"
    result = read(packet + "result.json")
    elf_rel = Path(".tools/linux-x86_64/alire/cache/releases/gnatprove_16.1.0_82528bef/libexec/spark/bin/gnatwhy3")
    paths = [directory / elf_rel for directory in (ROOT, *ROOT.parents)]
    elf_path = next(path for path in paths if path.is_file())
    raw = elf_path.read_bytes()
    check(identity(raw) == {"bytes": result["elf_bytes"], "sha256": result["elf_sha256"]},
          "terminal installed executable identity")
    # Independent linear run scan; no author regex/checker is imported.
    permitted = set(range(32, 127)) | {9, 10, 13}
    length, best_length, best_start = 0, 0, 0
    for index, byte in enumerate(raw):
        length = length + 1 if byte in permitted else 0
        if length > best_length:
            best_length, best_start = length, index - length + 1
    check(best_length == result["static_resident_ascii_cap"] == 467, "whole ELF ASCII maximum")
    check(best_start == result["largest_ascii_run_offset"], "whole ELF maximum offset")
    check(identity(raw[best_start:best_start + best_length])["sha256"] ==
          result["largest_ascii_run_sha256"], "whole ELF maximum bytes")
    for literal in result["literal_witnesses"]:
        text = literal["text"].encode("ascii")
        offset = literal["elf_offset"]
        check(len(text) == literal["bytes"], "terminal literal length")
        check(raw[offset:offset + len(text)] == text, "terminal literal ELF witness")

    census = read(packet + "re-error-census.json")
    for row in census:
        lines = (ROOT / row["file"]).read_text().splitlines()
        check(1 <= row["line"] <= len(lines), "strict Re source line")
        check(lines[row["line"] - 1] == row["text"], "Re source text")
    # Regenerate the new source-line inventory from all its pinned Re inputs.
    inputs = read(packet + "inputs.json")
    regenerated = set()
    for path in inputs:
        if "/re-api-source/" in path or "/re-prefix-source/" in path:
            for line, text in enumerate((ROOT / path).read_text().splitlines(), 1):
                if re.search(r"\b(exception|raise|failwith|invalid_arg|assert)\b", text):
                    regenerated.add((path, line, text))
    check(regenerated == {(row["file"], row["line"], row["text"]) for row in census},
          "new Re lexical inventory completeness")

    # Dispatch package count and returned-string majorant are separate recurrences.
    packages = 1
    for _ in range(2):
        packages = 1 + 2 * packages
    for field, value in {"wrapper_depth_upper": 2, "dispatch_packages_per_outer": packages,
                         "why_passes_per_outer": 2 * packages,
                         "why_candidates_per_outer": 110 * packages,
                         "printexc_calls_per_outer": packages,
                         "printexc_candidates_per_outer": 5 * packages,
                         "outer_diagnostic_calls": 4, "abort_json_attempts": 2,
                         "normal_json_attempts": 1}.items():
        check(result[field] == value, "terminal " + field)
    example = result["configuration_range_example_only"]
    p, m = 416, 444
    s = max(467, p + 51, m + 23, 256)
    k = 467 + 12 * s + 256
    y = sum(4 ** level for level in range(3)) * (8 * k + 65536)
    abort = y + 1024
    events = 320 * packages + 16
    check(467 + 4 * 3 * s + 68 * 3 + 2 <= k, "default direct fields fit K")
    check(64 + 8 * s <= k and p + 128 <= k and 467 + 160 <= k, "other scalar leaves fit K")
    check(88 + 70 * (4 + 2) == 508 <= 1024, "outer finishing byte derivation")
    check(2 * 70 * (320 + 4) < 65536, "package layout copies fit recurrence")
    for field, value in {"P": p, "M": m, "S": s, "K": k,
                         "Y_single_dispatch": y, "x_abort_each": abort,
                         "X_abort_payload_sum": 2 * abort,
                         "principal_private_events_per_outer": events,
                         "principal_private_bytes_all_four_outers": 4 * abort,
                         "principal_private_events_all_four_outers": 4 * events,
                         "direct_terminal_stderr_bytes": 2 * y + 253}.items():
        check(example[field] == value, "terminal orientation " + field)
    fixed_lines = ["Fatal error: exception \n",
                   "Fatal error in uncaught exception handler: exception \n",
                   "Fatal error: out of memory in uncaught exception handler\n"]
    check(sum(len(text.encode("ascii")) for text in fixed_lines) + 2 * 59 == 253,
          "direct fallback constants plus two backtraces")
    l, i = abort + events, 3 * events + 2
    guards = {
        "core_sentinel": l + 79 <= 1000000010,
        "core_scan_arithmetic": (3 * events + 1) * (1000000010 + l + 1) + l + 79 <= 2 ** 62 - 1,
        "core_counts": 4 * i + 2 <= 2 ** 62 - 1,
        "buffer_double_and_string": 2 * max(512, abort) <= 2 ** 57 - 9,
    }
    check(example["guards"] == guards and all(guards.values()), "terminal orientation guards")
    check(result["actual_joined_exports"] is None and example["actual_joined_claim"] is False,
          "terminal actual path inputs remain open")
    check(result["complete_capacity_or_admission"] is False, "terminal scope unchanged")
    request = read("docs/evidence/retained-solver-request-bytes-20261020/projection.json")
    for case, data in request["domains"].items():
        bound = data["recorded_TMPDIR_bytes"] + max(
            prover["task_path_bytes"]["constant"] for prover in data["provers"].values())
        check(result["request_path_inputs"][case]["request_path_upper"] == bound,
              case + " request path provider arithmetic")
        check(result["request_path_inputs"][case]["requires_combined_shared_prefix_preservation"] is True,
              case + " request path transport remains required")
    return {"static_resident_ascii_cap": best_length, "elf_identity": identity(raw),
            "strict_Re_source_lines": len(census), "dispatch_packages": packages,
            "orientation": example, "actual_joined_exports": None}


def warning_check():
    packet = "docs/evidence/retained-why-diagnostic-warnings-20261023/"
    bounds = read(packet + "bounds.json")
    projection = read(packet + "library-projection.json")
    native_projection = read(packet + "native-projection.json")
    archive_name = "docs/evidence/retained-producer-import-context-20261018/sources.tar.gz"
    with tarfile.open(ROOT / archive_name) as archive:
        libraries = {member.name: archive.extractfile(member).read() for member in archive.getmembers()
                     if member.isfile() and member.name.endswith((".mlw", ".why"))}
    check(len(libraries) == 21 and sum(map(len, libraries.values())) == 419906, "complete initial library set")
    keywords = set("requires ensures returns raises reads writes alias variant diverges partial invariant assert check assume".split())
    totals = Counter()
    opportunities = {}
    for row in projection["initial_files"]:
        raw = libraries[row["member"]]
        check(identity(raw) == row["identity"], "initial library identity")
        text = raw.decode()
        words = Counter(re.findall(r"\b\w+\b", text))
        annotations = {word: words[word] for word in keywords}
        check(row["annotation_keywords"] == annotations, "annotation keyword census")
        check(row["left_brackets"] == text.count("["), "bracket opportunity census")
        for word in ("exists", "match", "import"):
            check(row[word + "_tokens"] == words[word], "library token census " + word)
        check(words["import"] == 0 and text.count("[#") == row["location_directives"] == 0,
              "initial parser import/location exclusion")
        check(row["largest_line_bytes"] == max(map(len, raw.splitlines())), "library line bound")
        totals["brackets"] += text.count("[")
        totals["annotations"] += sum(annotations.values())
        totals["exists"] += words["exists"]
        totals["match"] += words["match"]
        opportunities[row["member"]] = text.count("[") + sum(annotations.values()) + words["exists"] + words["match"]
    check(totals == Counter(brackets=343, annotations=797, exists=19, match=38), "initial syntax totals")
    check(projection["J"] == totals["brackets"] + totals["annotations"] == 1140, "J opportunity sum")
    publication = read("docs/evidence/retained-why-library-publication-bound-20261020/bound.json")
    later = {name: opportunities[publication["source_file_identities"][name]["member"]]
             for name in ("int", "real", "algebra", "relations")}
    check(later == projection["later_warning_opportunities_per_file"] ==
          {"int": 54, "real": 7, "algebra": 0, "relations": 0}, "later syntax opportunities")
    parses = {"int": 5, "real": 1, "algebra": 11, "relations": 43}
    check(projection["later_real_root_file_parse_counts"] == parses, "accepted parse coefficient transcription")
    per_root = sum(parses[name] * later[name] for name in parses)
    check(per_root == projection["later_warning_opportunities_per_real_root"] == 277,
          "warning opportunities per larger root")

    # Check each new abstract witness against the full source module region.
    modules = publication["module_recurrence"]
    witnesses = projection["later_clone_target_witnesses"]
    required_targets = {name for module in modules.values() for name in module["clone_targets"]}
    check(required_targets <= set(witnesses), "all later clone targets have witnesses")
    with tarfile.open(ROOT / "docs/evidence/retained-producer-fixed-context-20261018/sources.tar.gz") as archive:
        def validate_witness(name, witness, active):
            check(name not in active, "acyclic inherited abstract witness")
            module = modules[name]
            member = publication["source_file_identities"][module["library"]]["member"]
            raw = archive.extractfile(member).read()
            first, last = module["first_byte"], module["past_last_byte"]
            check(0 <= first < last <= len(raw), "strict module byte region")
            block = raw[first:last].decode()
            if witness["kind"] == "direct_abstract_type_or_axiom":
                check(witness["text"] in {line.strip() for line in block.splitlines()}, "direct abstract witness source")
                check(re.fullmatch(r"type\s+t\d*|axiom\s+.+", witness["text"]) is not None, "abstract witness form")
            else:
                check(witness["kind"] == "first_clone_preserves_abstract_witness", "inherited witness kind")
                lines = block.splitlines()
                start = next(i for i, line in enumerate(lines) if line.strip().startswith("clone "))
                end = next((i for i in range(start + 1, len(lines))
                            if lines[i].strip().startswith(("clone ", "meta ", "end"))), len(lines))
                first_clone = "\n".join(lines[start:end])
                check(lines[start].strip() == witness["header"], "inherited witness clone header")
                check(not re.search(r"\b(type|goal)\b", first_clone), "whole first clone has no type/goal substitution")
                check(witness["target"] == module["clone_targets"][0], "inherited witness target")
                validate_witness(witness["target"], witness["ancestor"], active | {name})
        for name, witness in witnesses.items():
            validate_witness(name, witness, set())

    roles = read("docs/evidence/retained-parallel-logging-prefix-20261020/input-role-projection.json")
    imports = read("docs/evidence/retained-producer-import-context-20261018/result.json")
    old_json = read("docs/evidence/retained-why-standard-json-inputs-20261020/transfer.json")
    scalar_counts = {}
    with tarfile.open(ROOT / "docs/evidence/retained-producer-prefix-gc-20261018/observations.tar.gz") as archive:
        for case, row in native_projection.items():
            raw = archive.extractfile(row["member"]).read()
            check(identity(raw) == row["identity"], case + " native input identity")
            counts = Counter()
            pending = [(json.loads(raw), 0)]
            while pending:
                value, depth = pending.pop()
                if isinstance(value, dict):
                    pending.extend((child, depth) for child in value.values())
                elif isinstance(value, list):
                    if len(value) == 2 and isinstance(value[0], str) and type(value[1]) is int:
                        counts["max_source_filename_bytes"] = max(counts["max_source_filename_bytes"], len(value[0].encode()))
                        counts["max_source_line"] = max(counts["max_source_line"], value[1])
                    if value and value[0] == "W_LOOP":
                        depth += 1
                        counts["loop_count"] += 1
                        counts["max_loop_depth"] = max(counts["max_loop_depth"], depth)
                    if value and value[0] == "W_LOC_LABEL":
                        counts["max_marker_bytes"] = max(counts["max_marker_bytes"], len(value[-1].encode()))
                    if value and value[0] == "W_EXISTENTIAL_QUANTIF":
                        counts["existential_nodes"] += 1
                    pending.extend((child, depth) for child in value)
                else:
                    counts["scalar_leaves"] += 1
            for key in ("scalar_leaves", "loop_count", "max_loop_depth", "existential_nodes",
                        "max_source_filename_bytes", "max_marker_bytes", "max_source_line"):
                check(counts[key] == row[key], case + " native " + key)
            check(counts["max_loop_depth"] <= 1 and counts["loop_count"] <= 1,
                  case + " one nonnested loop")
            check(counts["existential_nodes"] == 0, case + " no native existential")
            check(counts["max_source_filename_bytes"] + counts["max_marker_bytes"] + 4 <= 166,
                  case + " native virtual filename bound")
            matched = [entry for entry in imports["fixed_inputs"]
                       if Path(entry["input"]).name == Path(row["member"]).name]
            check(len(matched) == 1 and matched[0]["direct_clones"] == row["direct_clones"],
                  case + " clone count matched by input filename")
            old = next(entry for entry in old_json["cases"] if entry["case"] == case)
            check(old["input_sha256"] == row["identity"]["sha256"], case + " unchanged native input")
            scalar_counts[case] = counts["scalar_leaves"]
            for capture in roles[case]["captures"]:
                check("GNATWHY3LOG" not in capture["normalized_environment"], case + " warning hook retained")
                opens = [entry for entry in capture["ordered_opens"] if entry["path"].endswith((".mlw", ".why"))]
                check(len(opens) == 21, case + " each initial library read once")
                check(Counter(entry["identity"]["sha256"] for entry in opens) ==
                      Counter(identity(data)["sha256"] for data in libraries.values()), case + " full initial library identities")
                check(max(len(entry["path"].encode()) for entry in opens) <= 166, case + " library filename bound")

    census = read(packet + "warning-census.json")
    source_archive = "docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz"
    with tarfile.open(ROOT / source_archive) as archive:
        for row in census["references"] + census["module_aliases"]:
            lines = archive.extractfile(row["member"]).read().decode().splitlines()
            check(1 <= row["line"] <= len(lines), "strict warning census line")
            check(lines[row["line"] - 1] == row["text"], "warning census text")
        actual_refs, actual_aliases = set(), set()
        for member in archive.getmembers():
            if not member.isfile() or not member.name.endswith((".ml", ".mli", ".mll", ".mly")):
                continue
            for number, text in enumerate(archive.extractfile(member).read().decode().splitlines(), 1):
                if re.search(r"Loc\.(?:warning|set_warning_hook)|Gnat_report\.add_warning|\bwarning_hook\b|\bwarning_list\b", text) or (
                        member.name == "why3/src/util/loc.ml" and re.search(r"\bwarning\s+warn_", text)):
                    actual_refs.add((member.name, number, text))
                if re.search(r"\b(?:open|include)\s+Loc\b|\bmodule\s+\w+\s*=\s*Loc\b", text):
                    actual_aliases.add((member.name, number, text))
        check(actual_refs == {(row["member"], row["line"], row["text"]) for row in census["references"]},
              "whole retained warning lexical inventory")
        check(actual_aliases == {(row["member"], row["line"], row["text"]) for row in census["module_aliases"]},
              "whole retained Loc alias inventory")
    check(len(census["module_aliases"]) == 1 and census["module_aliases"][0]["member"].endswith("/ptree_helpers.mli"),
          "only classified interface Loc opening")
    check(len(census["references"]) == 112, "warning reference count")
    rows = []
    for row in bounds["cases"]:
        case = row["case"]
        initial = 1140 + 4 * scalar_counts[case] + 205 + native_projection[case]["direct_clones"] + 19 + 38
        suffix = 2 * per_root * row["E"]
        w, length = initial + suffix + 5, 422 * (initial + suffix + 5)
        for field, value in {"W_initial": initial, "W_library_suffix": suffix,
                             "W_shared_global": 5, "W_o": w, "L_o": length,
                             "warning_B": 3 * w + 6 * length,
                             "warning_E": 3 * w + 2 * length,
                             "warning_B_plus_E": 6 * w + 8 * length}.items():
            check(row[field] == value, case + " warning arithmetic " + field)
        check(row["E"] == 3 * row["current_registration_roots"] + 2, case + " warning episode join")
        check(row["whole_standard_guard_established"] is False, case + " warning scope")
        rows.append({"case": case, "W_o": w, "L_o": length, "E": row["E"]})
    check(bounds["shared_e"] == 2 and bounds["save_entering_callbacks"] == 2 and bounds["saves"] == 3,
          "warning global budgets")
    check(bounds["final_debug_copy_separate"] == {"D": 1, "H": 26619} and
          bounds["incompatible_answer_warnings_separate"] is True and
          bounds["terminal_X_and_raw_solver_q_closed"] is False, "warning ownership separation")
    return {"cases": rows, "initial_libraries": 21, "initial_J": 1140,
            "native_scalar_leaves": scalar_counts, "later_clone_targets": len(required_targets),
            "warning_references": len(census["references"])}


def composition_check(canonical, warning, terminal):
    result = read("docs/evidence/retained-reporting-composition-20261023/result.json")
    crows = {row["case"]: row for row in canonical}
    wrows = {row["case"]: row for row in warning["cases"]}
    r66 = read("docs/evidence/retained-why-printer-output-20261023/result.json")
    r66_rows = {row["case"].replace("-", "_"): row for row in r66["cases"]}
    example = terminal["orientation"]
    x, y = example["X_abort_payload_sum"], example["Y_single_dispatch"]
    old_x = 2 * (sum(4 ** n for n in range(4)) * (8 * example["K"] + 65536) + 1024)
    rows = []
    for row in result["cases"]:
        case = row["case"]
        c, w = crows[case], wrows[case]
        q = c["N"]
        check(q == w["E"] == row["scheduling_Q"], case + " current episode attachment")
        for driver in r66_rows[case]["drivers"].values():
            fragment = driver["syntax_integer_diagnostic"]
            check(fragment["attempts_per_process_upper"] == q and
                  fragment["process_text_bytes_upper"] == 64 * q and
                  fragment["process_core_events_upper"] == 8 * q and
                  fragment["fresh_stderr_reset_assumed"] is False, case + " R66 once-per-process fragment")
        b0 = c["JSON_B_constant"] + 3 * w["W_o"] + 6 * w["L_o"] + 64 * q
        e0 = c["JSON_E_constant"] + 3 * w["W_o"] + 2 * w["L_o"] + 8 * q + 2
        check(row["B"] == {"constant": b0, "summed_abort_X": 6}, case + " composed B")
        check(row["E"] == {"constant": e0, "summed_abort_X": 2}, case + " composed E")
        b, e = b0 + 6 * x, e0 + 2 * x
        l = b + e
        operands = {"sentinel": l + 79,
                    "scan": (3 * e + 1) * (1000000011 + l) + l + 79,
                    "counts": 4 * (3 * e + 2) + 2}
        guards = {name: value <= (1000000010 if name == "sentinel" else 2 ** 62 - 1)
                  for name, value in operands.items()}
        orientation = row["orientation_only"]
        offered = b + 70 * (e + 2)
        channels = offered + 2 * y + 253 + 2 * 59
        check(orientation["zero_initial_offset_guard_fits"] == (channels <= 2 ** 63 - 1),
              case + " exact zero-offset channel boundary")
        for name, value in {"P": 416, "M": 444, "X": x, "B": b, "E": e, "L": l,
                            "guard_operands": operands, "guards": guards,
                            "all_core_guards_fit": all(guards.values()),
                            "sentinel_margin": 1000000010 - operands["sentinel"],
                            "standard_format_offered_bytes": offered,
                            "both_channels_offered_bytes": channels}.items():
            check(orientation[name] == value, case + " composed orientation " + name)
        old_operand = b0 + e0 + 8 * old_x + 79
        check(row["prior_d3_orientation_at_same_warning_bound"] == {
            "X": old_x, "sentinel_operand": old_operand,
            "sentinel_guard_fits": old_operand <= 1000000010,
            "actual_overflow_claim": False}, case + " retained d3 sufficient-bound result")
        check(row["actual_path_inputs_attached"] is False and
              row["actual_standard_core_guards"] is None and
              row["actual_channel_offset_guards"] is None, case + " actual guards remain open")
        rows.append({"case": case, "B_constant": b0, "E_constant": e0,
                     "orientation_B": b, "orientation_E": e,
                     "orientation_sentinel_margin": 1000000010 - operands["sentinel"],
                     "orientation_all_core_guards_fit": all(guards.values()),
                     "orientation_both_channels_bytes": channels,
                     "prior_d3_sentinel_guard_fits": old_operand <= 1000000010})
    check(len(rows) == 5, "five composed cases")
    check(result["stderr_fragment_copies_per_process"] == 1 and result["exit_flush_events_total"] == 2,
          "standard writers charged once")
    check(result["actual_standard_core_guards"] is None and result["whole_process_capacity"] is False,
          "composition actual scope remains conditional")
    check(rows[0]["case"] == "put_line" and rows[0]["prior_d3_sentinel_guard_fits"] is False,
          "historical Put_Line sufficient guard failure retained")
    return rows


def main():
    started = time.perf_counter()
    targets = json.loads((HERE / "targets.json").read_text())
    exact_inputs, providers = {}, {}
    for component, target in targets["components"].items():
        commit = target["commit"]
        for path, expected in target["files"].items():
            raw = subprocess.check_output(["git", "show", commit + ":" + path], cwd=ROOT)
            check(identity(raw) == expected, component + " frozen commit file: " + path)
            exact_inputs[path] = pin_file(path, expected)
        for path, expected in target["providers"].items():
            if path in providers:
                check(providers[path] == expected, "same provider identity across components: " + path)
            providers[path] = pin_file(path, expected)

    total_spans, complete_members = 0, set()
    for source in targets["source_packets"]:
        n, members = source_spans(source["archive"], read(source["spans"]))
        total_spans += n
        complete_members.update(members)

    canonical = canonical_check()
    terminal = terminal_check()
    warning = warning_check()
    composition = composition_check(canonical, warning, terminal)
    result = {
        "status": "pass", "finite_checks": CHECKS,
        "author_freezes": {name: data["commit"] for name, data in targets["components"].items()},
        "exact_inputs": exact_inputs, "providers": providers,
        "strict_source_ranges": total_spans, "complete_members": len(complete_members),
        "canonical_cases": canonical,
        "terminal": terminal,
        "warning": warning,
        "composition": composition,
        "audit_code_identity": identity(Path(__file__).read_bytes()),
        "author_or_predecessor_checker_model_runs": 0,
        "native_compiler_solver_capture_disassembler_proof_runs": 0,
        "whole_standard_core_guards_established": False,
        "whole_process_capacity": False, "whole_119_claim": False,
        "raw_solver_file_bytes_upper": None,
        "prospective_adapter_refinement_required": True,
        "global_escape_budget": 2, "save_entering_callbacks": 2, "saves_upper": 3,
        "budget_renewed": False, "aggregate_RAM_or_physical_stack_gate": False,
        "elapsed_seconds": time.perf_counter() - started,
    }
    (HERE / "audit-result.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({key: result[key] for key in ["status", "finite_checks", "strict_source_ranges", "complete_members", "elapsed_seconds"]}))


if __name__ == "__main__":
    main()
