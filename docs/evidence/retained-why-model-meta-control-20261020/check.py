#!/usr/bin/env python3
"""Attach accepted meta control to exact current inputs; no old checker replay."""
import argparse
import hashlib
import json
from pathlib import Path
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
EVIDENCE = ROOT / "docs/evidence"
ORIGINS = EVIDENCE / "retained-why-path-library-origins-20261020"
STANDARD = EVIDENCE / "retained-why-standard-formatter-control-20261020"
CAPTURE = EVIDENCE / "retained-why-save-state-capture-20261020"
WHY = EVIDENCE / "retained-why-session-helper-source-20261019/sources.tar.gz"
SOURCE_RANGES = [
    ("src/driver/driver.ml", 27, 33),
    ("src/driver/driver.ml", 456, 471),
    ("src/driver/call_provers.ml", 328, 337),
    ("src/driver/call_provers.ml", 465, 492),
    ("src/driver/call_provers.ml", 507, 520),
    ("src/driver/call_provers.ml", 604, 618),
    ("src/driver/smtv2_model_parser.ml", 457, 474),
]


def load(path):
    return json.loads(Path(path).read_text())


def ident(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def identity_fields(row):
    return {k: row[k] for k in ("bytes", "sha256")}


def blob(archive, member):
    return archive.extractfile(member).read()


def obj(archive, member):
    return json.loads(blob(archive, member))


def canonical_resolution(resolution):
    # Same filenames, identities and ordered import edges; only directory moves.
    names = [Path(p).name for p in resolution]
    assert len(names) == len(set(names)) == 14
    result = {}
    for path, row in resolution.items():
        imports = []
        for edge in row["imports"]:
            assert len(edge["candidates"]) == 1
            target = edge["candidates"][0]
            assert target in resolution
            imports.append({"name": edge["name"], "target": Path(target).name})
        result[Path(path).name] = {"identity": row["identity"], "imports": imports}
    return result


def build():
    ce = load(ORIGINS / "counterexample-meta-inputs.json")
    assert ce["forbidden_meta"] == "get_counterexmp"
    assert ce["occurrences_outside_driver_comments"] == 0
    drivers = {Path(r["path"]).name: identity_fields(r)
               for r in ce["inputs"] if r["kind"] == "resolved_driver"}
    libraries = [r for r in ce["inputs"] if r["kind"] == "prefix_library"]
    native = {r["member"].split("/")[0]: identity_fields(r)
              for r in ce["inputs"] if r["kind"] == "native_input"}
    assert (len(drivers), len(libraries), len(native)) == (14, 11, 5)
    dispatch = load(ORIGINS / "selected-dispatch.json")["drivers"]
    envelope = load(EVIDENCE / "retained-producer-driver-envelope-20261018/result.json")
    assert dispatch == envelope["selected_driver_dispatch"]
    names = {r["name"] for d in dispatch.values() for r in d["transformations"]}
    assert len(names) == 20
    initial = {r["case"]: r for r in load(EVIDENCE / "retained-why-path-initial-state-20261020/prefix-attachment.json")}
    standard = load(STANDARD / "initial-inputs.json")
    old_result = load(STANDARD / "result.json")
    assert old_result["model_diagnostic_excluded_by_task_meta"] is None
    assert {(r["case"], r["pid"]) for r in old_result["cases"]} == {
        (r["case"], r["pid"]) for r in standard}
    with tarfile.open(EVIDENCE / "retained-producer-fixed-tail-20261018/observations.tar.gz") as old:
        resolution = canonical_resolution(obj(old, "driver-resolution.json"))
    assert {n: r["identity"] for n, r in resolution.items()} == drivers
    groups, cases, sources = [], [], []
    with tarfile.open(CAPTURE / "capture-common.tar.gz") as common:
        for group in ("registration", "inline"):
            plan_raw = blob(common, group + "/plan.json")
            plan = json.loads(plan_raw)
            assert plan["source_revision"] == "9390baf120ef260547dfa14f08e11c890b203d9c"
            assert plan["runtime_candidate_revision"] == "8eb41f72ded84df884c3671734c947f612091f84"
            actual_raw = blob(common, group + "/driver-resolution.json")
            actual = json.loads(actual_raw)
            assert canonical_resolution(actual) == resolution
            assert set(plan["selected_driver_closure"].values()) == set(actual)
            for path, row in actual.items():
                assert plan["file_identities"][path] == row["identity"]
            overlay = []
            for path in actual:
                if "/overlay/" in path:
                    member = group + "/overlay/" + Path(path).name
                    assert ident(blob(common, member)) == actual[path]["identity"]
                    overlay.append(member)
            assert len(overlay) == 4
            library_joins = []
            for row in libraries:
                suffix = row["member"].removeprefix("installed/")
                matched = [p for p in plan["file_identities"] if p.endswith("/" + suffix)]
                assert len(matched) == 1, row
                assert plan["file_identities"][matched[0]] == identity_fields(row)
                library_joins.append({"accepted_member": row["member"],
                                      "plan_path": matched[0], **identity_fields(row)})
            groups.append({"group": group, "plan_identity": ident(plan_raw),
                           "resolution_identity": ident(actual_raw),
                           "driver_identities_and_ordered_imports_match": True,
                           "resolved_driver_count": 14, "checked_overlay_members": overlay,
                           "library_joins": library_joins})
            for entry in plan["inputs"]:
                name = entry["name"]
                previous = initial[name]
                current = next(r for r in standard if r["case"] == name)
                assert previous["phase"] == group
                assert previous["pid"] == current["pid"]
                assert entry["argv"] == previous["argv"] == current["process"]["argv"]
                assert entry["environment"] == previous["environment"] == current["process"]["environment"]
                assert entry["input"] == native[name]
                with tarfile.open(CAPTURE / current["archive"]) as capture:
                    prefix = group + "/" + name + "/"
                    process_raw = blob(capture, prefix + "capture/process.json")
                    assert json.loads(process_raw) == current["process"]
                    input_raw = blob(capture, prefix + Path(entry["argv"][-1]).name)
                    assert ident(input_raw) == native[name]
                    config = blob(capture, prefix + "why3.conf")
                    assert ident(config) == current["config_identity"]
                image = plan["file_identities"][entry["argv"][0]]
                assert image["sha256"] == "7c8c302f65a98e66159f6514045f4c2634aab5c556eea0a7d6fd1f39dc35a368"
                cases.append({"case": name, "pid": current["pid"], "phase": group,
                              "cut_symbol": previous["cut_symbol"],
                              "cut_directives": previous["directives"],
                              "process_identity": ident(process_raw),
                              "input_identity": ident(input_raw),
                              "config_identity": ident(config),
                              "selected_input_relation_attached": True,
                              "meta_names_or_task_meta_map_observed": False,
                              "get_counterexmp_false_under_accepted_relation": True})
            member = group + "/session_observer.py"
            raw = blob(common, member)
            excerpt = "".join(raw.decode().splitlines(keepends=True)[219:245])
            sources.append({"archive": str((CAPTURE / "capture-common.tar.gz").relative_to(ROOT)),
                            "member": member, "member_identity": ident(raw),
                            "first_line": 220, "last_line": 245, "text": excerpt})
    assert len(cases) == 5
    with tarfile.open(WHY) as why:
        for path, first, last in SOURCE_RANGES:
            member = "why3/" + path
            raw = blob(why, member)
            sources.append({"archive": str(WHY.relative_to(ROOT)), "member": member,
                            "member_identity": ident(raw), "first_line": first,
                            "last_line": last,
                            "text": "".join(raw.decode().splitlines(keepends=True)[first-1:last])})
    attachment = {"cases": cases, "groups": groups,
                  "accepted_driver_resolution": resolution,
                  "selected_transform_names": sorted(names),
                  "selected_printers": sorted(d["printer"] for d in dispatch.values())}
    result = {
        "scope": "Exact attachment of accepted CE-meta preservation to the five standard formatter continuations",
        "model_diagnostic_excluded_by_task_meta_under_named_relation": True,
        "selected_call_provers_model_parser_invocations_upper": 0,
        "get_model_for_selected_saved_calls": "None",
        "accepted_source_argument_reused": True,
        "historical_standard_component_field": None,
        "source_argument_proved_by_this_checker": False,
        "new_native_meta_name_observation": False,
        "initial_standard_dynamic_state": None,
        "whole_output_capacity": None, "complete_R": None, "complete_U": None,
        "other_diagnostics_excluded": False, "issue_119_or_153_complete": False,
        "new_native_runs": 0, "new_captures": 0, "predecessor_checker_replays": 0,
        "fresh_full_source_or_transform_census": False,
    }
    return {"attachment.json": attachment, "source-witnesses.json": sources, "result.json": result}


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("--write", action="store_true")
    args = parser.parse_args()
    start = time.monotonic()
    inputs = load(HERE / "inputs.json")
    for path, expected in inputs["files"].items():
        assert ident((ROOT / path).read_bytes()) == expected, path
    products = build()
    for name, value in products.items():
        data = (json.dumps(value, indent=2, sort_keys=True) + "\n").encode()
        if args.write:
            (HERE / name).write_bytes(data)
        else:
            assert (HERE / name).read_bytes() == data, name
    print(json.dumps({"status": "pass", "mode": "write" if args.write else "comparison",
                      "cases": 5, "driver_groups": 2, "drivers_per_group": 14,
                      "libraries_per_group": 11, "selected_transforms": 20,
                      "source_excerpts": len(products["source-witnesses.json"]),
                      "elapsed_seconds": time.monotonic() - start}, indent=2))


if __name__ == "__main__":
    main()
