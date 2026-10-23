#!/usr/bin/env python3
"""One focused retained-source/identity/arithmetic check; no native execution."""
from pathlib import Path
import hashlib
import json
import re
import tarfile
import time

ROOT = Path(__file__).resolve().parents[3]
OUT = Path(__file__).resolve().parent
START = time.monotonic()


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def read_json(path):
    return json.loads((ROOT / path).read_bytes())


def archive(path):
    with tarfile.open(ROOT / path) as tf:
        return {m.name: tf.extractfile(m).read() for m in tf.getmembers() if m.isfile()}


def write(name, value):
    (OUT / name).write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")


SOURCES = "docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz"
IMPORTS = "docs/evidence/retained-producer-import-context-20261018/sources.tar.gz"
FIXED = "docs/evidence/retained-producer-fixed-context-20261018/sources.tar.gz"
NATIVE = "docs/evidence/retained-producer-prefix-gc-20261018/observations.tar.gz"
PROVIDERS = [
    "docs/research/retained-why-standard-initial-state.md",
    "docs/research/retained-why-initial-registration-bound.md",
    "docs/research/retained-producer-import-context.md",
    "docs/research/retained-producer-startup-vcs.md",
    "docs/research/retained-producer-diagnostic-strings.md",
    "docs/research/retained-why-path-library-origins.md",
    "docs/research/retained-why-library-constructors.md",
    "docs/research/retained-why-library-publication-bound.md",
    "docs/research/retained-why-diagnostic-occurrences.md",
    "docs/research/retained-why-callback-demand.md",
    "docs/research/retained-why-standard-json-inputs.md",
    "docs/research/retained-combined-parallel-startup.md",
    "docs/research/retained-parallel-logging-prefix.md",
    "docs/research/retained-why-debug-hook-capacity.md",
    "docs/evidence/retained-producer-import-context-20261018/result.json",
    "docs/evidence/retained-parallel-logging-prefix-20261020/input-role-projection.json",
    "docs/evidence/retained-combined-parallel-startup-20261020/projection.json",
    "docs/evidence/retained-why-library-publication-bound-20261020/bound.json",
    "docs/evidence/retained-why-standard-json-inputs-20261020/transfer.json",
]
src, imported, fixed, native = map(archive, [SOURCES, IMPORTS, FIXED, NATIVE])
write("inputs.json", {p: identity((ROOT / p).read_bytes())
                      for p in [SOURCES, IMPORTS, FIXED, NATIVE] + PROVIDERS})

spans = {
    "why3/src/util/loc.ml": [(67, 86), (134, 195), (224, 239), (246, 297)],
    "why3/src/gnat/gnat_report.ml": [(30, 48)],
    "why3/src/gnat/gnat_util.ml": [(125, 152)],
    "why3/src/gnat/gnat_config.ml": [(25, 35), (208, 220), (650, 665)],
    "why3/src/gnat/gnat_main.ml": [(94, 120), (190, 205), (267, 280), (316, 350)],
    "why3/src/core/dterm.ml": [(589, 594), (669, 684)],
    "why3/src/core/theory.ml": [(880, 896)],
    "why3/src/mlw/dexpr.ml": [(1163, 1166), (1337, 1347), (1389, 1417),
                              (1495, 1581), (1617, 1683), (1732, 1845)],
    "why3/src/mlw/pmodule.ml": [(1143, 1154), (1253, 1294), (1590, 1634)],
    "why3/src/mlw/vc.ml": [(599, 616)],
    "why3/src/parser/typing.ml": [(344, 364), (885, 930), (939, 1025),
                                 (1184, 1203), (1675, 1737)],
    "why3/src/parser/parser_common.mly": [(225, 276), (380, 399), (951, 983),
                                        (1098, 1110), (1168, 1177)],
    "why3/src/parser/parser.mly": [(145, 168)],
    "why3/src/session/session_itp.ml": [(840, 865)],
    "why3/src/util/lexlib.mll": [(151, 171)],
}
plugin_spans = {
    "why3/plugins/gnat_json/gnat_ast_to_ptree.ml": [
        (56, 64), (225, 257), (337, 384), (467, 488), (539, 592),
        (703, 784), (786, 876), (878, 948), (1011, 1159)],
    "why3/plugins/gnat_json/ptree_constructors.ml": [(100, 134), (194, 208)],
}
witnesses = []
for source_set, mapping, ar in [(src, spans, SOURCES), (fixed, plugin_spans, FIXED)]:
    for name, ranges in mapping.items():
        data = source_set[name]
        lines = data.decode().splitlines()
        for first, last in ranges:
            assert 1 <= first <= last <= len(lines), (name, first, last, len(lines))
            witnesses.append({"archive": ar, "member": name,
                              "member_identity": identity(data),
                              "first": first, "last": last,
                              "text": "\n".join(lines[first-1:last]) + "\n"})
write("source-witnesses.json", witnesses)

census = []
aliases = []
for name, data in src.items():
    if not name.endswith((".ml", ".mli", ".mll", ".mly")):
        continue
    for line, text in enumerate(data.decode().splitlines(), 1):
        if re.search(r"Loc\.(?:warning|set_warning_hook)|Gnat_report\.add_warning|"
                     r"\bwarning_hook\b|\bwarning_list\b", text) or (
                name == "why3/src/util/loc.ml" and re.search(r"\bwarning\s+warn_", text)):
            census.append({"member": name, "line": line, "text": text})
        if re.search(r"\b(?:open|include)\s+Loc\b|\bmodule\s+\w+\s*=\s*Loc\b", text):
            aliases.append({"member": name, "line": line, "text": text})
assert aliases == [{"member": "why3/src/parser/ptree_helpers.mli",
                    "line": 13, "text": "open Loc"}]
# This interface open resolves the position type; it defines no executable alias.
assert "val warning" not in src["why3/src/parser/ptree_helpers.mli"].decode()
write("warning-census.json", {"references": census, "module_aliases": aliases,
                               "alias_disposition": "interface-only type-name scope, no executable warning alias",
                               "semantic_reachability_from_note_required": True})

libraries = {n: d for n, d in imported.items() if n.endswith((".mlw", ".why"))}
assert len(libraries) == 21 and sum(map(len, libraries.values())) == 419906
annotation_keywords = "requires ensures returns raises reads writes alias variant diverges partial invariant assert check assume".split()
library_rows = []
for name, data in libraries.items():
    s = data.decode()
    row = {"member": name, "identity": identity(data),
           "words": len(re.findall(r"\b[A-Za-z_][A-Za-z_0-9']*\b", s)),
           "left_brackets": s.count("["), "literal_attributes": s.count("[@"),
           "annotation_keywords": {k: len(re.findall(r"\b" + k + r"\b", s))
                                   for k in annotation_keywords},
           "exists_tokens": len(re.findall(r"\bexists\b", s)),
           "match_tokens": len(re.findall(r"\bmatch\b", s)),
           "import_tokens": len(re.findall(r"\bimport\b", s)),
           "location_directives": s.count("[#"),
           "largest_line_bytes": max(map(len, data.splitlines()))}
    assert row["import_tokens"] == row["location_directives"] == 0
    library_rows.append(row)
J = sum(sum(r["annotation_keywords"].values()) + r["left_brackets"] for r in library_rows)
assert J == 1140
assert sum(r["exists_tokens"] for r in library_rows) == 19
assert sum(r["match_tokens"] for r in library_rows) == 38

publication = read_json(PROVIDERS[-2])
modules = publication["module_recurrence"]
targets = sorted({q for m in modules.values() for q in m["clone_targets"]})
target_witnesses = {}
def abstract_witness(name):
    if name in target_witnesses:
        return target_witnesses[name]
    m = modules[name]
    f = publication["source_file_identities"][m["library"]]["member"]
    block = fixed[f][m["first_byte"]:m["past_last_byte"]].decode()
    direct = re.search(r"(?m)^\s*(type\s+t\d*\s*$|axiom\s+[A-Za-z_][A-Za-z_0-9']*\s*:[^\n]*)", block)
    if direct:
        witness = {"kind": "direct_abstract_type_or_axiom", "text": direct.group().strip()}
    else:
        # The first clone in these wrapper modules preserves its abstract t.
        q = m["clone_targets"][0]
        header = re.search(r"(?m)^\s*clone[^\n]*", block).group().strip()
        assert "type " not in header and "goal " not in header
        witness = {"kind": "first_clone_preserves_abstract_witness", "target": q,
                   "header": header, "ancestor": abstract_witness(q)}
    target_witnesses[name] = witness
    return witness
for name in targets:
    abstract_witness(name)
later_files = [publication["source_file_identities"][n]["member"]
               for n in ["int", "real", "algebra", "relations"]]
for name in later_files:
    data = fixed[name]
    assert identity(data) == {k: publication["source_file_identities"][Path(name).stem][k]
                              for k in ["bytes", "sha256"]}
    assert b"[@" not in data and b"[|" not in data and b"[#" not in data
real_parses = publication["direct_root_bounds"]["real"]["whole_file_parse_upper_counts"]
assert real_parses == {"int": 5, "real": 1, "algebra": 11, "relations": 43}
later_opportunities = {}
for f in later_files:
    r = next(row for row in library_rows if row["member"] == f)
    later_opportunities[Path(f).stem] = (r["left_brackets"] +
        sum(r["annotation_keywords"].values()) + r["exists_tokens"] + r["match_tokens"])
per_root = sum(real_parses[n] * later_opportunities[n] for n in real_parses)
assert per_root == 277
write("library-projection.json", {"initial_files": library_rows, "J": J,
                                  "later_clone_target_witnesses": target_witnesses,
                                  "later_warning_opportunities_per_file": later_opportunities,
                                  "later_warning_opportunities_per_real_root": per_root,
                                  "later_real_root_file_parse_counts": real_parses})

combined = read_json(PROVIDERS[-3])["domains"]
role_projection = read_json(PROVIDERS[-4])
json_transfer = read_json(PROVIDERS[-1])
initial_imports = read_json(PROVIDERS[-5])
case_order = ["put_line", "put", "first_or_default", "is_message", "input_is_valid"]
episodes = dict(zip(case_order, [155, 128, 68, 8, 5]))
actual_roots = dict(zip(case_order, [51, 42, 22, 2, 1]))
native_rows = {}
for name, data in native.items():
    if not name.startswith("success/") or not name.endswith(".gnat-json"):
        continue
    case = name.split("/")[1]
    counts = {"scalar_leaves": 0, "loop_count": 0, "max_loop_depth": 0,
              "existential_nodes": 0, "max_source_filename_bytes": 0,
              "max_marker_bytes": 0, "max_source_line": 0}
    def walk(value, depth=0):
        if isinstance(value, dict):
            for child in value.values():
                walk(child, depth)
        elif isinstance(value, list):
            if len(value) == 2 and isinstance(value[0], str) and type(value[1]) is int:
                counts["max_source_filename_bytes"] = max(counts["max_source_filename_bytes"],
                                                           len(value[0].encode()))
                counts["max_source_line"] = max(counts["max_source_line"], value[1])
            if value and value[0] == "W_LOOP":
                depth += 1
                counts["loop_count"] += 1
                counts["max_loop_depth"] = max(counts["max_loop_depth"], depth)
            if value and value[0] == "W_LOC_LABEL":
                assert isinstance(value[-1], str)
                counts["max_marker_bytes"] = max(counts["max_marker_bytes"],
                                                  len(value[-1].encode()))
            if value and value[0] == "W_EXISTENTIAL_QUANTIF":
                counts["existential_nodes"] += 1
            for child in value:
                walk(child, depth)
        else:
            counts["scalar_leaves"] += 1
    walk(json.loads(data))
    assert counts["max_loop_depth"] <= 1 and counts["loop_count"] <= 1
    assert counts["existential_nodes"] == 0 and b"exist" not in data.lower()
    assert counts["max_source_filename_bytes"] + counts["max_marker_bytes"] + 4 <= 166
    clone = next(r for r in initial_imports["fixed_inputs"]
                 if Path(r["input"]).name == Path(name).name)
    native_rows[case] = {"archive": NATIVE, "member": name, "identity": identity(data),
                         **counts, "direct_clones": clone["direct_clones"]}

rows = []
for case in case_order:
    c = combined[case]
    assert c["registered_root_count"] == actual_roots[case]
    assert "--logging" in c["candidate_argv"] and "--debug-prover-errors" not in c["candidate_argv"]
    assert c["candidate_argv"][c["candidate_argv"].index("-j")+1] == "12"
    assert c["candidate_argv"][c["candidate_argv"].index("--counterexample")+1] == "off"
    for capture in role_projection[case]["captures"]:
        assert "GNATWHY3LOG" not in capture["normalized_environment"]
        actual_files = [r for r in capture["ordered_opens"]
                        if r["path"].endswith((".mlw", ".why"))]
        assert len(actual_files) == 21
        assert sorted(r["identity"]["sha256"] for r in actual_files) == sorted(
            identity(d)["sha256"] for d in libraries.values())
        assert max(len(r["path"].encode()) for r in actual_files) <= 166
    old = next(r for r in json_transfer["cases"] if r["case"] == case)
    assert old["input_sha256"] == native_rows[case]["identity"]["sha256"]
    E = episodes[case]
    assert E == 3 * actual_roots[case] + 2
    assert E <= old["conditional_inputs"]["N"]
    assert actual_roots[case] <= old["conditional_inputs"]["G"]
    W_initial = J + 4 * native_rows[case]["scalar_leaves"] + 205 + native_rows[case]["direct_clones"] + 19 + 38
    W_library_suffix = 2 * E * per_root
    W_global = (1 + 2) + 2  # one shared e=2, no producer-local renewal
    W = W_initial + W_library_suffix + W_global
    L = 422 * W
    warning_B, warning_E = 3 * W + 6 * L, 3 * W + 2 * L
    coefficient = old["all_JSON_attempts_coefficients"]
    base = coefficient["B"]["constant"] + coefficient["E"]["constant"] + 79
    O_conditional = 76 * max(old["conditional_inputs"]["A"], old["conditional_inputs"]["N"])
    conditional_total = base + warning_B + warning_E + 4150 * O_conditional
    assert conditional_total < 1000000010
    rows.append({"case": case, "retained_J12_pid": c["original_pid"],
                 "current_registration_roots": actual_roots[case], "E": E,
                 "old_JSON_N": old["conditional_inputs"]["N"],
                 "W_initial": W_initial, "W_library_suffix": W_library_suffix,
                 "W_shared_global": W_global, "W_o": W, "L_o": L,
                 "warning_B": warning_B, "warning_E": warning_E,
                 "warning_B_plus_E": warning_B + warning_E,
                 "conditional_canonical_O": O_conditional,
                 "conditional_JSON_B_plus_E_plus_79_at_X_zero": conditional_total,
                 "remaining_guard_credit_before_X_and_other_writers": 1000000010 - conditional_total,
                 "whole_standard_guard_established": False})
write("native-projection.json", native_rows)
write("bounds.json", {"scope": "one whole selected process, initial plus all continuation warnings",
                       "shared_e": 2, "save_entering_callbacks": 2, "saves": 3,
                       "warning_filename_bound": 166, "warning_length_bound": 422,
                       "incompatible_answer_warnings_separate": True,
                       "final_debug_copy_separate": {"D": 1, "H": 26619},
                       "terminal_X_and_raw_solver_q_closed": False, "cases": rows})
write("check-result.json", {"passed": True, "elapsed_seconds": time.monotonic() - START,
                            "case_count": len(rows), "source_witnesses": len(witnesses),
                            "warning_references": len(census), "native_runs": 0,
                            "proof_runs": 0, "solver_runs": 0, "source_fetches": 0,
                            "predecessor_checker_replays": 0,
                            "semantic_source_argument_in_note_required": True})
print(json.dumps(rows, indent=2))
