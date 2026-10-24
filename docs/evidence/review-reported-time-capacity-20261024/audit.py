"""Independent final-freeze identities and arithmetic; no target/checker runs.

The source/control and allocation-class arguments are reviewed in the report.
This audit does not execute an installed lexer/parser/regexp engine, an author
checker, or a predecessor checker. The two transfer modules are pure evidence
arithmetic, not the tools being analyzed.
"""
from copy import deepcopy
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import platform
import re
import runpy
import subprocess
import sys
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
AUTHOR_REL = "docs/evidence/retained-reported-time-capacity-20261024"
AUTHOR = ROOT / AUTHOR_REL
NOTE = "docs/research/retained-reported-time-capacity.md"
INITIAL = "ae33d531d9259c1ee8896a475b78742d51922917"
BASELINE_FREEZE = "e45ee72a42d6cc669e95b80c2c991cbc65fe4e73"
NATIVE_FREEZE = "6cc4c72f63"


def read(path):
    return json.loads(path.read_text())


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def git(*args):
    return subprocess.check_output(["git", *args], cwd=ROOT)


def reject(fn, *args, **kwargs):
    try:
        fn(*args, **kwargs)
    except ValueError:
        return
    raise AssertionError("invalid input was accepted")


def fixed_lexemes(raw):
    """Independent character scanner for this fixed ASCII common-file corpus."""
    text = raw.decode("ascii")
    tokens, strings = [], []
    pos = 0
    max_depth = 0
    letters = "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ_"
    ident_tail = letters + "0123456789'"
    operators = "=<>~+*/%\\!$&?@^.:|#-"
    while pos < len(text):
        if text[pos].isspace():
            pos += 1
            continue
        if text.startswith("(*", pos) and not text.startswith("(*)", pos):
            depth = 1
            max_depth = max(max_depth, depth)
            pos += 2
            while depth:
                assert pos < len(text)
                if text.startswith("(*)", pos):
                    pos += 3
                elif text.startswith("(*", pos):
                    depth += 1
                    max_depth = max(max_depth, depth)
                    pos += 2
                elif text.startswith("*)", pos):
                    depth -= 1
                    pos += 2
                else:
                    pos += 1
            continue
        start = pos
        char = text[pos]
        pos += 1
        if char == '"':
            while text[pos] != '"':
                pos += 2 if text[pos] == "\\" else 1
            pos += 1
            strings.append(text[start:pos])
        elif char in letters:
            while pos < len(text) and text[pos] in ident_tail:
                pos += 1
        elif char in operators:
            while pos < len(text) and text[pos] in operators:
                pos += 1
        tokens.append(text[start:pos])
    return tokens, strings, max_depth


def main():
    started = time.perf_counter()
    start_utc = datetime.now(timezone.utc).isoformat()
    freeze, dependency_root = sys.argv[1], Path(sys.argv[2])
    assert git("rev-parse", "HEAD").decode().strip() == freeze
    paths = git("ls-tree", "-r", "--name-only", freeze, "--", AUTHOR_REL, NOTE).decode().splitlines()
    frozen = {}
    for path in paths:
        data = (ROOT / path).read_bytes()
        assert data == git("show", f"{freeze}:{path}"), path
        frozen[path] = identity(data)
    inputs = read(AUTHOR / "inputs.json")["files"]
    for path, expected in inputs.items():
        assert identity((ROOT / path).read_bytes()) == expected, path

    # Verify the exact accepted providers without replaying their checkers.
    baseline_record = read(AUTHOR / "baseline-entry-projection.json")
    baseline_path = baseline_record["source_path"]
    baseline_bytes = (dependency_root / baseline_path).read_bytes()
    assert identity(baseline_bytes) == baseline_record["source_identity"]
    assert baseline_bytes == git("show", f"{BASELINE_FREEZE}:{baseline_path}")
    prefix_path = "docs/evidence/retained-combined-parallel-startup-20261020/projection.json"
    assert (dependency_root / prefix_path).read_bytes() == git("show", f"{BASELINE_FREEZE}:{prefix_path}")
    native_provider_files = read(AUTHOR / "native-providers.json")["files"]
    for path, expected in native_provider_files.items():
        data = (dependency_root / path).read_bytes()
        assert identity(data) == expected, path
        assert data == git("show", f"{NATIVE_FREEZE}:{path}"), path

    witnesses = read(AUTHOR / "source-witnesses.json")
    archives = {}
    span_count = 0
    for member, spec in witnesses.items():
        archive_path = spec["archive"]
        if archive_path not in archives:
            with tarfile.open(ROOT / archive_path) as archive:
                archives[archive_path] = {m.name: archive.extractfile(m).read()
                                          for m in archive.getmembers() if m.isfile()}
        raw = archives[archive_path][member]
        assert identity(raw) == spec["identity"], member
        lines = raw.decode().splitlines(keepends=True)
        for span in spec["spans"]:
            assert "".join(lines[span["first"] - 1:span["last"]]) == span["text"]
            span_count += 1
    why = archives["docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz"]
    actual_census = []
    for member, raw in sorted(why.items()):
        if not (member.startswith("why3/src/") and member.endswith(".ml")):
            continue
        assert not re.search(rb"\bpr_time\s*<-", raw)
        for match in re.finditer(rb"\bpr_time\s*=", raw):
            line = raw[:match.start()].count(b"\n") + 1
            actual_census.append({"member": member, "line": line,
                                  "text": raw.decode().splitlines()[line - 1]})
    assert actual_census == read(AUTHOR / "time-origin-census.json")
    call = why["why3/src/driver/call_provers.ml"].decode().splitlines()
    controller = why["why3/src/session/controller_itp.ml"].decode().splitlines()
    assert "let ans = parse_prover_run" in call[490]
    assert "List.map handle_answer" in call[497]
    assert "Some r -> ProverFinished r" in call[545]
    assert "Call_provers.ProverFinished res ->" in controller[468]
    assert "Opt.fold fuzzy_proof_time" in controller[471]
    assert "ptp.tp_callback (Done res)" in controller[473]

    recipe = read(AUTHOR / "recipe.json")
    changes = []
    for path, expected in recipe["files"].items():
        new = (AUTHOR / path).read_bytes()
        assert identity(new) == expected
        old = (ROOT / recipe["baseline"] / Path(path).relative_to("configuration")).read_bytes()
        if new != old:
            changes.append(path)
            old_lines, new_lines = old.splitlines(keepends=True), new.splitlines(keepends=True)
            assert old_lines[:22] == new_lines[:22] and old_lines[23:] == new_lines[23:]
            assert len(old_lines[22]) == 32 and len(new_lines[22]) == 33
            assert new_lines[22].hex() == "74696d6520225c5c3d222074696d6520225c5c3d222074696d6520225c5c3d220a"
    assert len(recipe["files"]) == 7 and changes == ["configuration/overlay/slv-libv2.gen"]
    graph = read(ROOT / "docs/evidence/retained-fixed-failure-composition-20261023/paths.json")
    for role, domain in graph["domains"].items():
        edges = {}
        for edge in domain["driver_imports"]:
            edges.setdefault(edge["from"], []).append(edge["required_existing_candidate"])
        counts = {}
        for root in domain["driver_discovery"]:
            pending = [root["required_existing_candidate"]]
            common = 0
            while pending:
                node = pending.pop()
                common += node.endswith("/slv-libv2.gen")
                pending.extend(edges.get(node, ()))
            counts[root["root"]] = common * 3
        assert len(counts) == 9 and sum(counts.values()) == 9
        assert counts == recipe["loaded"][role]["records_by_configured_root"]

    allocation = read(AUTHOR / "allocation.json")
    common = (AUTHOR / changes[0]).read_bytes()
    tokens, strings, depth = fixed_lexemes(common)
    assert len(common) == 4018 and len(tokens) == 412 and len(strings) == 72
    assert max(map(len, strings)) == 121 and depth == 1
    assert tokens == allocation["lexical"]["tokens"]
    transitions = 18 * (len(tokens) + 1)
    lexer = 17 * (len(common) + 1) + 128 * (len(tokens) + 1) + 512
    delta = 3 * (4096 * transitions + lexer) + 9 * (4096 + 64 + 128)
    assert transitions == 7434 and lexer == 121699 and delta == 91752681
    assert delta == allocation["startup_minor_words"]
    for key, value in allocation.items():
        if key.startswith("startup_") and key != "startup_minor_words":
            assert value == 0, key
    assert allocation["new_native_buffer_or_descriptor_owners"] == 0
    assert allocation["largest_added_managed_payload_words_upper"] == 256

    # Check the newly reviewed parser/wrapper attachments, not the accepted Re kernel.
    sys.path.insert(0, str(ROOT / "docs/evidence/retained-why-library-probe-paths-20261023"))
    from elf_reader import Elf
    native = read(AUTHOR / "parser-native.json")
    binary = Path(native["target"]).read_bytes()
    assert identity(binary) == native["target_identity"]
    elf = Elf(binary)
    direct_bumps = 0
    for name, spec in native["modules"].items():
        assert identity(elf.at(spec["start"], spec["end"] - spec["start"])) == spec["identity"]
        raw = (AUTHOR / (name + ".txt")).read_bytes()
        assert identity(raw) == spec["text_identity"]
        function, words = None, 0
        for line in raw.decode().splitlines():
            header = re.search(r"<([^>]+)>:$", line)
            if header:
                function = header[1]
            bump = re.search(r"sub\s+\$0x([0-9a-f]+),%r15", line)
            if bump and not function.endswith("__entry"):
                byte_count = int(bump[1], 16)
                assert byte_count % 8 == 0
                words += byte_count // 8
        assert words == spec["summed_bump_words"]
        direct_bumps += words
    assert direct_bumps == 1629 and 2 * direct_bumps + 128 == 3386 < 4096
    for name, spec in native["wrapper_functions"].items():
        assert identity(elf.function(name)) == spec["identity"]
        assert identity((AUTHOR / (name + ".txt")).read_bytes()) == spec["text_identity"]

    baseline_provider = runpy.run_path(str(dependency_root / baseline_path))
    baselines = baseline_provider["all_envelopes"]()
    assert baselines == baseline_record["envelopes"] and len(baselines) == 5
    transfer = runpy.run_path(str(AUTHOR / "transfer.py"))
    extended = transfer["all_envelopes"]()
    assert extended == read(AUTHOR / "entry-extension.json")
    config_identity = transfer["recipe_identity"]()
    max_minor, max_carrier = 0, 0
    for role, baseline in baselines.items():
        entry = extended[role]
        minor = baseline["minor_history_words_upper"] + delta
        major = baseline["all_major_history_words_upper"]
        carrier = baseline["managed_static_carrier_words_upper"] + delta
        assert entry["minor_history_words_upper"] == minor < 2**28
        assert entry["all_major_history_words_upper"] == major < 2**24
        assert entry["protected_managed_history_words_upper"] == minor + major
        assert entry["managed_static_carrier_words_upper"] == carrier
        assert entry["one_byte_payload_upper"] == 8 * carrier
        assert all(entry["guards"].values())
        assert entry["Introduction.Hsdecl"] == baseline["Introduction.Hsdecl"]
        assert entry["process_budget"] == {"escaping_save_exceptions": 2, "save_entering_callbacks": 2, "saves": 3}
        for name, row in entry["owners"].items():
            count = minor // baseline["owners"][name]["minimum_minor_words"]
            assert row["completed_requests_upper"] == count
            assert row["counter_value_upper"] == row["initial"] + count < 2**62
            if "backing" in row:
                assert row["backing"]["outer_length_upper"] == carrier
                if row["kind"] == "weak":
                    assert row["backing"]["allocated_bucket_slots_upper"] == carrier
                    assert row["backing"]["live_entries_upper"] == count
                else:
                    assert row["backing"]["size_upper"] == count
        assert carrier < 2**54 - 3 and 16 * carrier + 2 < 2**62
        max_minor, max_carrier = max(max_minor, minor), max(max_carrier, carrier)
    assert max_minor == 227274405 and max_carrier == 237953393
    assert 2**28 - max_minor == 41161051
    first = next(iter(baselines.values()))
    reject(transfer["extend_entry_envelope"], first, configuration_identity="wrong recipe")
    changed = deepcopy(first)
    changed["owners"]["Ident"]["counter_value_upper"] += 1
    reject(transfer["extend_entry_envelope"], changed, configuration_identity=config_identity)
    changed = deepcopy(first)
    changed["role"] = "unknown role"
    reject(transfer["extend_entry_envelope"], changed, configuration_identity=config_identity)

    later = transfer["later_owned_words"]
    # Independent entry counts: no inferred parse/delivery relationship.
    cases = [(0, 0, 0, 0, 0), (1, 1, 0, 0, 7), (1, 0, 3, 0, 798),
             (1, 1, 3, 1, 1317), (3, 3, 3, 1, 1331), (0, 1, 0, 0, 7)]
    for parses, finished, searches, owners, expected in cases:
        assert later(parse_entries=parses, finished_results=finished,
                     attempted_searches=searches, owners=owners) == expected
    for kwargs in ({"parse_entries": 0, "finished_results": 1, "attempted_searches": 1, "owners": 0},
                   {"parse_entries": 1, "finished_results": -1, "attempted_searches": 0, "owners": 0},
                   {"parse_entries": 1, "finished_results": 1, "attempted_searches": 0, "owners": 10},
                   {"parse_entries": True, "finished_results": 1, "attempted_searches": 0, "owners": 0}):
        reject(later, **kwargs)

    # Repairs alter only the later event-count interface, not startup/entry values.
    for name in ("entry-extension.json", "baseline-entry-projection.json", "recipe.json", "result.json"):
        assert (AUTHOR / name).read_bytes() == git("show", f"{INITIAL}:{AUTHOR_REL}/{name}")
    old_allocation = json.loads(git("show", f"{INITIAL}:{AUTHOR_REL}/allocation.json"))
    assert {k: v for k, v in old_allocation.items() if k.startswith("startup_")} == {
        k: v for k, v in allocation.items() if k.startswith("startup_")}
    assert all(identity((ROOT / path).read_bytes()) == expected for path, expected in frozen.items())
    ended_utc = datetime.now(timezone.utc).isoformat()
    result = {
        "status": "pass", "reviewed_commit": freeze, "initial_reviewed_commit": INITIAL,
        "frozen_author_files": frozen, "fixed_input_files": len(inputs),
        "source_archives": len(archives), "source_members": len(witnesses), "source_spans": span_count,
        "time_assignment_census_entries": len(actual_census), "configuration_files": len(recipe["files"]),
        "launch_layouts": len(extended), "new_timing_records": 9,
        "native_parser_modules": len(native["modules"]), "native_caller_wrappers": len(native["wrapper_functions"]),
        "native_target_identity": native["target_identity"], "all_module_direct_bump_words": direct_bumps,
        "startup_minor_words_added": delta, "maximum_minor_words": max_minor,
        "maximum_managed_static_carrier_words": max_carrier,
        "independent_later_cases": len(cases), "interface_negative_controls": 7,
        "queued_only_words": 7, "abandoned_parse_words": 798,
        "entry_baseline_identity": baseline_record["source_identity"],
        "accepted_native_provider_files": native_provider_files,
        "external_provider_root": str(dependency_root),
        "author_checker_runs": 0, "predecessor_checker_runs": 0, "native_target_runs": 0,
        "capture_or_disassembler_runs": 0, "audit_sha256": identity(Path(__file__).read_bytes())["sha256"],
        "host": platform.platform(), "started_utc": start_utc, "ended_utc": ended_utc,
        "elapsed_seconds": time.perf_counter() - started,
        "selected_model": "GPT-6 Astra", "selected_reasoning_effort": "Extra High",
        "runtime_model_confirmation": None, "runtime_effort_confirmation": None,
        "token_usage": None, "cost": None,
    }
    (HERE / "result.json").write_text(json.dumps(result, indent=2, sort_keys=True) + "\n")
    print(json.dumps({k: v for k, v in result.items()
                      if k not in {"frozen_author_files", "accepted_native_provider_files"}}, indent=2))


if __name__ == "__main__":
    main()
