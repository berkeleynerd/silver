#!/usr/bin/env python3
"""Focused warning-kind certificate; no native work or predecessor replay.

The accepted typed-coverage and logical-graph correspondence contracts are
imported, not recomputed. Direct raw checks below concern stored term attribute
sets and attribute strings only; no term opening or binder analysis occurs.
"""
import argparse
import collections
import gzip
import hashlib
import io
import json
from pathlib import Path
import re
import struct
import tarfile
import time

HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]
E = HERE.parent
ATOMS = E / "retained-why-fixed-session-atoms-20261020"
JOIN = E / "retained-why-save-state-join-20261020"
WHY = E / "retained-why-session-helper-source-20261019"
CASES = ("put_line", "put", "first_or_default", "is_message", "input_is_valid")
REGISTERED = (64, 53, 32, 3, 1)
SOURCE_RANGES = {
    "gnat/gnat_expl.ml": [(75, 147), (149, 168), (178, 269), (417, 573)],
    "gnat/gnat_util.ml": [(24, 39)],
    "gnat/gnat_main.ml": [(48, 73), (270, 309)],
    "gnat/gnat_checks.ml": [(174, 235), (283, 354), (469, 505),
                            (598, 661), (985, 991), (1022, 1084)],
    "gnat/gnat_config.ml": [(24, 42), (567, 575), (650, 655)],
    "core/task.ml": [(65, 74)],
    "core/term.ml": [(626, 659), (663, 691), (739, 781),
                     (799, 831), (1282, 1294)],
}
DEPENDENCIES = [
    "oracle.md",
    "docs/research/retained-tool-source-identity.md",
    "docs/research/retained-producer-driver-envelope.md",
    "docs/evidence/retained-producer-driver-envelope-20261018/result.json",
    "docs/research/retained-why-fixed-session-domain.md",
    "docs/research/retained-why-session-shape-transfer.md",
    "docs/research/retained-why-save-state-join.md",
    "docs/reviews/review-save-state-continuation-20261020.md",
    "docs/reviews/review-save-capacity-round29-20261020.md",
    "docs/research/retained-why-save-attempt-growth.md",
    "docs/research/retained-why-save-table-contract-join.md",
    "docs/research/retained-why-path-writer-capacity.md",
    "docs/evidence/retained-why-path-writer-capacity-20261020/result.json",
    "docs/evidence/retained-why-fixed-session-atoms-20261020/README.md",
    "docs/evidence/retained-why-fixed-session-atoms-20261020/extract.py",
    "docs/evidence/retained-why-fixed-session-atoms-20261020/check.py",
    "docs/evidence/retained-why-fixed-session-atoms-20261020/inputs.json",
    "docs/evidence/retained-why-fixed-session-atoms-20261020/check-result.json",
    "docs/evidence/retained-why-session-save-outcomes-20261019/check.py",
    "docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz",
    "docs/evidence/retained-why-session-helper-source-20261019/source-identities.json",
    "docs/evidence/retained-why-save-missing-state-20261020/correspondence.py",
    "docs/evidence/retained-why-save-state-join-20261020/result.json",
    "docs/evidence/retained-why-status-entry-20261020/result.json",
    "docs/evidence/retained-why-save-state-capture-20261020/capture-manifest.json",
]


def identity(raw):
    return {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}


def get(path):
    return json.loads(path.read_bytes())


def dump(path, value):
    path.write_text(json.dumps(value, indent=2, sort_keys=True) + "\n")


def member(path, name):
    with tarfile.open(path) as archive:
        row = archive.getmember(name)
        assert row.isfile() and not row.issym() and not row.islnk()
        raw = archive.extractfile(row).read()
        assert len(raw) == row.size
        return raw


def sources():
    result, texts = [], {}
    manifest = get(WHY / "source-identities.json")
    assert manifest["why3_revision"] == "9390baf120ef260547dfa14f08e11c890b203d9c"
    assert identity((WHY / "sources.tar.gz").read_bytes()) == manifest["identity"]
    for name, ranges in SOURCE_RANGES.items():
        name = "why3/src/" + name
        raw = member(WHY / "sources.tar.gz", name)
        assert identity(raw) == manifest["members"][name]["identity"]
        texts[name] = raw.decode()
        lines = raw.decode().splitlines()
        for first, last in ranges:
            result.append(dict(member=name, file_identity=identity(raw),
                               first=first, last=last,
                               text="\n".join(lines[first-1:last])))
    return result, texts


def kind_partition(text):
    warning = text.split("let is_warning_kind r =", 1)[1].split("type subp_entity", 1)[0]
    false, true = warning.split("-> false")
    assert true.count("-> true") == 1
    branches = lambda s: set(re.findall(r"^\s*\|\s*(VC_\w+)\s*$", s, re.M))
    ordinary, warnings = branches(false), branches(true)
    mapping = text.split("let check_kind_from_string s =", 1)[1].split("let check_kind_to_ada", 1)[0]
    parsed = dict(re.findall(r'\|\s*"([^"]+)"\s*->\s*(VC_\w+)', mapping))
    assert ordinary and len(warnings) == 5 and ordinary.isdisjoint(warnings)
    assert set(parsed.values()) == ordinary | warnings
    return parsed, ordinary, warnings


def raw_attribute_check(atom, raw):
    """Check raw membership/bytes; reuse accepted typed term-edge coverage."""
    blocks = {}
    for line in io.BytesIO(raw):
        row = json.loads(line)
        pointer = row["address"]
        assert pointer not in blocks
        data = bytes.fromhex(row["payload_hex"])
        assert len(data) == 8 * row["words"]
        assert (row["tag"], row["words"]) == (row["header"] & 255, row["header"] >> 10)
        blocks[pointer] = (row["tag"], row["words"], data)

    def fields(pointer, length):
        tag, words, data = blocks[pointer]
        assert (tag, words) == (0, length)
        return struct.unpack("<" + "Q" * length, data)

    def attrs(pointer, active=frozenset()):
        if pointer == 1:
            return []
        assert pointer not in active
        left, key, unit, right, height = fields(pointer, 5)
        assert unit == 1 and height & 1
        return attrs(left, active | {pointer}) + [key] + attrs(right, active | {pointer})

    assert set(atom["term_attributes"]) == set(map(str, atom["covered_term_pointers"]))
    for pointer, expected in atom["term_attributes"].items():
        assert attrs(fields(int(pointer), 4)[2]) == expected
    for pointer, expected in atom["attributes"].items():
        string, tag = fields(int(pointer), 2)
        kind, words, data = blocks[string]
        assert kind == 252 and 0 <= data[-1] < 8 and tag & 1
        length = 8 * words - 1 - data[-1]
        assert data[length] == 0
        assert expected == dict(string_pointer=string, hex=data[:length].hex(),
                               bytes=length, attr_tag=tag >> 1, attr_tag_word=tag)
    return len(blocks)


def certificate(texts):
    parsed, ordinary, warnings = kind_partition(texts["why3/src/gnat/gnat_expl.ml"])
    # Loop-invariant refinement is the only non-parser assignment to check_kind
    # after default construction. Its exact source is retained for human review.
    refinement = texts["why3/src/gnat/gnat_expl.ml"].split("let read_vc_labels", 1)[1].split("let extract_check", 1)[0]
    assigned = re.findall(r"b\.check_kind <- Some (VC_\w+)", refinement)
    assert assigned == ["VC_Loop_Invariant_Init", "VC_Loop_Invariant_Preserv"]
    assert set(assigned) <= ordinary
    statuses = {r["case"]: r for r in get(E / "retained-why-status-entry-20261020/result.json")["cases"]}
    applications = {r["case"]: r for r in get(JOIN / "result.json")["cases"]}
    envelope = get(E / "retained-producer-driver-envelope-20261018/result.json")
    envelope_rows = {r["name"]: r for r in envelope["cases"]}
    captures = get(E / "retained-why-save-state-capture-20261020/capture-manifest.json")
    assert envelope["sum_registered_task_upper"] == sum(REGISTERED) == 153
    assert {r["name"]: r["registered_task_upper"] for r in envelope["cases"]} == dict(zip(CASES, REGISTERED))
    cases, paths = [], set(DEPENDENCIES)
    for name, registered in zip(CASES, REGISTERED):
        slug = name.replace("_", "-")
        atom_path = ATOMS / (slug + "-atoms.json.gz")
        atom = json.loads(gzip.decompress(atom_path.read_bytes()))
        assert atom["case"] == name and atom["typed_graph_complete"] and not atom["coverage_failures"]
        provenance, cert = atom["provenance"], atom["saved_occurrence_certificate"]
        paths.add(str(atom_path.relative_to(REPO)))
        paths.add(provenance["archive"])
        paths.add(provenance["occurrence_certificate"])
        original = get(REPO / provenance["occurrence_certificate"])
        assert identity((REPO / provenance["occurrence_certificate"]).read_bytes()) == provenance["occurrence_certificate_identity"]
        assert cert == original.get("full_certificate", original)
        assert set(atom["formula_roots"]) == set(map(int, cert["formulas"]))
        assert set(atom["formula_roots"]) <= set(atom["covered_term_pointers"])
        assert set(atom["formula_roots"]) == {p["formula"] for t in cert["tasks"].values() for p in t["propositions"]}
        assert all(t["propositions"][0]["kind"] == 2 and t["goal_formula"] == t["propositions"][0]["formula"]
                   for t in cert["tasks"].values())
        raw = member(REPO / provenance["archive"], provenance["member"])
        assert identity(raw) == provenance["member_identity"]
        raw_count = raw_attribute_check(atom, raw)
        check_labels = []
        for pointer, attr in sorted(atom["attributes"].items(), key=lambda r: int(r[0])):
            label = bytes.fromhex(attr["hex"])
            if not label.startswith(b"GP_Check"):
                continue
            parts = label.decode("ascii").split(":")
            assert parts[0] == "GP_Check" and len(parts) >= 6
            assert re.fullmatch(r"[0-9]+", parts[1])
            kind = parsed[parts[2]]
            assert kind in ordinary
            check_labels.append(dict(attribute_pointer=int(pointer),
                                     string_pointer=attr["string_pointer"],
                                     hex=attr["hex"], label=label.decode("ascii"),
                                     kind=kind, is_warning=False))
        assert check_labels
        comp_path = JOIN / (slug + "-correspondence.json")
        paths.add(str(comp_path.relative_to(REPO)))
        comp = get(comp_path)
        status, app = statuses[name], applications[name]
        assert comp["matched"] and comp["old_pid"] == provenance["pid"]
        assert comp["new_pid"] == status["pid"] == app["new_pid"] != provenance["pid"]
        assert comp["old_inputs"]["session-blocks.jsonl"] == provenance["member_identity"]
        assert comp["accepted_certificate"]["identity"] == provenance["occurrence_certificate_identity"]
        assert comp["accepted_certificate"]["path"] == provenance["occurrence_certificate"]
        assert status["input_lineage"]["comparison"] == identity(comp_path.read_bytes())
        assert status["input_lineage"]["raw_overlap_union"]["session-blocks.jsonl"] == comp["new_inputs"]["session-blocks.jsonl"]
        prefix = "inline" if name == "input_is_valid" else "registration"
        group, = [g for g in captures["groups"] if g["prefix"] == prefix]
        input_row, = [r for r in group["local_plan_inputs_rehashed"]
                      if r["member"].startswith(prefix + "/" + name + "/")
                      and r["member"].endswith(".gnat-json")]
        assert input_row["sha256"] == envelope_rows[name]["input_sha256"]
        fresh_member = prefix + "/" + name + "/capture/session-blocks.jsonl"
        fresh_row, = [r for a in captures["archives"] for r in a["members"] if r["path"] == fresh_member]
        assert {k: fresh_row[k] for k in ("bytes", "sha256")} == comp["new_inputs"]["session-blocks.jsonl"]
        assert app["logical_graph_correspondence_established"]
        assert set(comp["task_pointer_pairs"]) == set(cert["tasks"])
        assert set(map(int, comp["task_pointer_pairs"].values())) == {g["task_pointer"] for g in status["goals"]}
        assert set(p["old"] for p in comp["formula_pointer_pairs"]) == set(atom["formula_roots"])
        assert len(comp["visits"]) == len(cert["visits"]) == len(status["goals"])
        for old, pair in zip(cert["visits"], comp["visits"]):
            assert not old["detached"] and old["index"] == pair["index"]
            assert old["task"] == pair["old_task"]
            assert int(comp["task_pointer_pairs"][str(old["task"])]) == pair["new_task"]
        assert all(not g["detached"] for g in status["goals"])
        cases.append(dict(case=name, old_pid=provenance["pid"], fresh_pid=status["pid"],
                          old_phase=provenance["phase"], fresh_phase=status["phase"],
                          raw_provenance=provenance, fresh_raw_identity=comp["new_inputs"]["session-blocks.jsonl"],
                          fresh_raw_member=fresh_member,
                          fixed_input_identity={k: input_row[k] for k in ("bytes", "sha256")},
                          correspondence_identity=identity(comp_path.read_bytes()),
                          typed_terms=len(atom["covered_term_pointers"]), raw_blocks=raw_count,
                          raw_forest_visits=len(cert["visits"]), registered_goal_upper=registered,
                          distinct_GP_Check_attributes=len(check_labels),
                          kind_counts=dict(sorted(collections.Counter(r["kind"] for r in check_labels).items())),
                          check_labels=check_labels, warning_attempts_upper=0))
    return dict(scope="Five named fixed-library raw-task domains under the accepted selected source/configuration/metadata relation",
                source_warning_kinds=sorted(warnings), loop_refinement_nonwarning_kinds=assigned,
                cases=cases, warning_attempts_upper=0,
                warning_timeout_option_needed_for_these_domains=False,
                conditional_source_closure_review_required=True,
                source_control_flow_machine_proved=False,
                relevant_source_and_registered_metadata_relation_required=True,
                all_future_fixed_input_executions_covered=False,
                actual_queued_limits_all_zero_established=False,
                complete_configuration_capacity_established=False,
                complete_pipeline_capacity_established=False), paths


def main(write=False):
    start = time.perf_counter()
    if not write:
        for path, expected in get(HERE / "inputs.json")["files"].items():
            assert identity((REPO / path).read_bytes()) == expected, path
    witnesses, texts = sources()
    result, paths = certificate(texts)
    if write:
        assert not (HERE / "certificate.json").exists()
        dump(HERE / "source-witnesses.json", witnesses)
        dump(HERE / "certificate.json", result)
        paths.update(str((HERE / p).relative_to(REPO)) for p in ("check.py", "certificate.json", "source-witnesses.json"))
        dump(HERE / "inputs.json", dict(base_commit="59bf44c59c9bda53b8c4ea5be52c10266f2b93e9",
                                      files={p: identity((REPO / p).read_bytes()) for p in sorted(paths)}))
    else:
        assert witnesses == get(HERE / "source-witnesses.json")
        assert result == get(HERE / "certificate.json")
    return dict(passed=True, elapsed_seconds=time.perf_counter()-start,
                source_slices=len(witnesses), fixed_domains=len(result["cases"]),
                distinct_GP_Check_attributes_by_case=[r["distinct_GP_Check_attributes"] for r in result["cases"]],
                warning_attempts_upper=0, native_runs=0, source_fetches=0,
                prior_checker_replays=0, logical_graph_comparisons=0,
                logical_openings=0, binder_recomputations=0, solver_or_proof_runs=0)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true", help="Create absent certificate and manifest only")
    print(json.dumps(main(parser.parse_args().write), indent=2, sort_keys=True))
