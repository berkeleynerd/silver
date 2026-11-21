"""Reviewer probe: old (base) vs new (target) check_evidence auditors on real retained reports.

Read-only with respect to the worktree and evidence; every mutated copy lives in a
temporary directory.  Run as:

    python3 -B probes/diff_auditor.py <worktree> <scratch>
"""
from __future__ import annotations

import copy
import importlib.util
import json
import os
from pathlib import Path
import shutil
import sys
import tempfile

worktree, scratch = Path(sys.argv[1]).resolve(), Path(sys.argv[2]).resolve()
sys.path.insert(0, str(worktree / "scripts"))   # platforms/bootstrap for the old module
sys.path.insert(0, str(worktree))

from scripts import check_evidence as new  # noqa: E402

spec = importlib.util.spec_from_file_location("old_check_evidence", scratch / "old/old_check_evidence.py")
old = importlib.util.module_from_spec(spec)
spec.loader.exec_module(old)


def outcome(module, call):
    try:
        return ("ok", call(module))
    except Exception as error:  # compare type and text
        return (type(error).__name__, str(error))


def same(label, call, *, expect=None, quiet=False):
    left, right = outcome(old, call), outcome(new, call)
    status = "SAME" if left == right else "DIFFERENT"
    if expect is not None and right[0] != expect:
        status += f" (expected {expect})"
    if not quiet or status != "SAME":
        detail = right[1] if right[0] != "ok" else {k: v for k, v in right[1].items() if v}
        print(f"  [{status}] {label}: new={right[0]} {str(detail)[:170]}")
        if left != right:
            print(f"      old={left[0]} {str(left[1])[:300]}")
    return left == right, right


results = {"same": 0, "different": 0}


def tally(pair):
    results["same" if pair[0] else "different"] += 1
    return pair


# ---------------------------------------------------------------- complete compiler audit
reports = scratch / "final-native/reports"
source_dir = scratch / "final-src/src"
generated = scratch / "final-src/.silver/linux-x86_64/generated"
manifest = json.loads((reports / "proof-provenance.json").read_text())
command = manifest["command"]

print("== complete compiler audit on retained final native reports ==")
work = Path(tempfile.mkdtemp(prefix="pr406-audit-"))
try:
    base = work / "base"
    shutil.copytree(reports, base)
    for path in base.iterdir():
        os.utime(path)  # the archive normalizes mtimes; freshness is checked by the producer run itself

    def full(module, directory=base):
        return module.audit_sources(source_dir, directory, generated, effective_command=command)

    ok, right = tally(same("audit_sources (complete, unmodified)", full, expect="ok"))
    if right[0] == "ok":
        stats = right[1]
        print("     stats:", json.dumps(stats))

    # argument derivation equal to audit_sources, for direct audit_reports mutations
    sources = sorted(p for p in source_dir.rglob("*") if p.suffix in (".ads", ".adb"))
    sources += sorted(p for p in generated.rglob("*") if p.suffix in (".ads", ".adb"))
    expected_units = {p.stem for p in sources}
    trusted_units = {p.stem for p in sources if p.name in new.TRUSTED_IMPORT_SPECS}
    instances = {unit: new.audit_sequence_instance(source_dir / (unit + ".ads"))
                 for unit in new.SEQUENCE_INSTANCES}
    conversion = new.audit_signed_conversion_instance(source_dir / (new.SIGNED_CONVERSION_UNIT + ".ads"))
    print(f"     units={len(expected_units)} trusted import units={sorted(trusted_units)}")

    def direct(directory, **overrides):
        options = dict(effective_command=command, proof_instances=instances,
                       signed_conversion_instance=conversion)
        options.update(overrides)
        trusted = options.pop("trusted", trusted_units)
        units = options.pop("units", expected_units)
        return lambda module: module.audit_reports(directory, units, trusted, **options)

    tally(same("audit_reports (complete, direct)", direct(base), expect="ok"))

    counter = [0]

    def mutated(label, unit, change, *, summary=None, expect="EvidenceError", **overrides):
        counter[0] += 1
        target = work / f"m{counter[0]}"
        shutil.copytree(base, target)
        path = target / f"{unit}.spark"
        report = json.loads(path.read_text())
        change(report)
        path.write_text(json.dumps(report))
        if summary:
            out = target / "gnatprove.out"
            out.write_text(summary(out.read_text()))
        pair = tally(same(f"{unit}: {label}", direct(target, **overrides), expect=expect))
        shutil.rmtree(target)
        return pair

    def owned(report, unit):
        return [key for key, entity in report["entities"].items()
                if any(Path(loc["file"]).stem == unit for loc in entity.get("sloc", []))]

    def first(report, unit, value="all"):
        return next(key for key in owned(report, unit) if report["spark"].get(key) == value)

    print("== coverage-region mutations (complete audit) ==")
    for unit in ("silver_numbers", "silver_libc", "silver_report_projection_model", "silver_image_files"):
        mutated("owned all -> spec", unit, lambda r, u=unit: r["spark"].__setitem__(first(r, u), "spec"))
        mutated("owned all -> no", unit, lambda r, u=unit: r["spark"].__setitem__(first(r, u), "no"))
        mutated("owned coverage entry removed", unit, lambda r, u=unit: r["spark"].pop(first(r, u)))
        mutated("coverage names unknown entity", unit, lambda r: r["spark"].__setitem__(" 99999", "all"))
        mutated("all owned entities relocated", unit, lambda r, u=unit: [
            loc.__setitem__("file", "elsewhere.ads") for key in owned(r, u) for loc in r["entities"][key]["sloc"]])
        mutated("summary analyzed count changed", unit, lambda r: None,
                summary=lambda text, u=unit: text.replace(f"in unit {u}, ", f"in unit {u}, 9", 1))
        mutated("coverage map emptied", unit, lambda r: r["spark"].clear())
        mutated("extra owned entity without coverage", unit, lambda r, u=unit: r["entities"].__setitem__(
            " 88888", {"name": "X.Extra", "sloc": [{"file": u + ".ads", "line": 1, "column": 1}]}))
    for unit in ("silver_libc", "silver_runtime", "silver_output_libc"):
        mutated("trusted import spec -> all", unit, lambda r, u=unit: r["spark"].__setitem__(first(r, u, "spec"), "all"))
        mutated("trusted import renamed", unit, lambda r, u=unit: r["entities"][first(r, u, "spec")].__setitem__(
            "name", "Other.Name"))
        mutated("trusted import unit not declared trusted", unit, lambda r: None,
                trusted=trusted_units - {unit})
    for unit in ("silver_report_projection_model", "silver_image_files"):
        mutated("vendor spec origin moved", unit, lambda r, u=unit: r["entities"][first(r, u, "spec")]["sloc"][0]
                .__setitem__("line", 1))
        mutated("vendor instance not supplied", unit, lambda r: None,
                proof_instances={k: v for k, v in instances.items() if k != unit},
                **({"signed_conversion_instance": None} if unit == "silver_image_files" else {}))
    mutated("unknown unit declared trusted (expected KeyError both)", "silver_numbers", lambda r: None,
            trusted=trusted_units | {"silver_numbers"}, expect="KeyError")
    mutated("unknown trusted unit plus non-SPARK owned entity", "silver_numbers",
            lambda r: r["spark"].__setitem__(first(r, "silver_numbers"), "no"),
            trusted=trusted_units | {"silver_numbers"}, expect=None)
    mutated("skip_proof nonempty (outside refactor; control)", "silver_numbers",
            lambda r: r["skip_proof"].append("x"))
finally:
    shutil.rmtree(work, ignore_errors=True)

# ---------------------------------------------------------------- application audits
print("== application audits on six retained real report sets ==")
cases = json.loads((worktree / "docs/evidence/advisory-policy-391-20261116/auditors/accepted-reports.json").read_text())["cases"]
recorded = {item["case"]: item["stats"] for item in json.loads(
    (worktree / "docs/evidence/advisory-policy-391-20261116/auditors/accepted-python-results.json").read_text())}
units = {"main", "silver_io", "silver_arguments", "silver_output_libc", "silver_runtime"}
trusted = {"silver_output_libc", "silver_runtime"}
work = Path(tempfile.mkdtemp(prefix="pr406-app-"))
try:
    for case in cases:
        directory = scratch / "accepted" / case["name"] / "reports"
        options = dict(application_kind=case["kind"], application_functions=tuple(case["functions"]),
                       application_procedures={k: tuple(v) for k, v in case["procedures"].items()},
                       application_formals={k: tuple(tuple(x) for x in v) for k, v in case["formals"].items()},
                       indexed_main=True)

        def call(module, directory=directory, options=options, trusted=trusted):
            return module.audit_reports(directory, units, trusted, **copy.deepcopy(options))

        ok, right = tally(same(f"{case['name']} ({case['kind']})", call, expect="ok"))
        if right[0] == "ok" and right[1] != recorded[case["name"]]:
            print("      NOTE: stats differ from the recorded #391 result:", right[1])
        elif right[0] == "ok":
            print("      matches the stats recorded in accepted-python-results.json")
        number = [0]

        def mutate(label, name, change, summary=None, expect="EvidenceError", trusted=trusted):
            number[0] += 1
            target = work / f"{case['name']}-{number[0]}"
            shutil.copytree(directory, target)
            path = target / name
            report = json.loads(path.read_text())
            change(report)
            path.write_text(json.dumps(report))
            if summary:
                out = target / "gnatprove.out"
                out.write_text(summary(out.read_text()))
            tally(same(f"  {case['name']}/{name}: {label}",
                       lambda module: module.audit_reports(target, units, trusted, **copy.deepcopy(options)),
                       expect=expect, quiet=True))
            shutil.rmtree(target)

        def owned_keys(report, unit):
            return [key for key, entity in report["entities"].items()
                    if any(Path(loc["file"]).stem == unit for loc in entity.get("sloc", []))]

        for name, unit in (("main~1.spark", "main"), ("silver_io.spark", "silver_io"),
                           ("silver_output_libc.spark", "silver_output_libc"),
                           ("silver_runtime.spark", "silver_runtime"), ("silver_arguments.spark", "silver_arguments")):
            mutate("first owned coverage -> spec", name,
                   lambda r, u=unit: r["spark"].__setitem__(next(k for k in owned_keys(r, u) if k in r["spark"]), "spec"))
            mutate("first owned coverage -> no", name,
                   lambda r, u=unit: r["spark"].__setitem__(next(k for k in owned_keys(r, u) if k in r["spark"]), "no"))
            mutate("owned coverage removed", name,
                   lambda r, u=unit: r["spark"].pop(next(k for k in owned_keys(r, u) if k in r["spark"])))
            mutate("unknown coverage key", name, lambda r: r["spark"].__setitem__(" 4242", "all"))
            mutate("summary count changed", name, lambda r: None,
                   summary=lambda text, n=Path(name).stem: text.replace(f"in unit {n}, ", f"in unit {n}, 7", 1))
            mutate("coverage emptied", name, lambda r: r["spark"].clear())
        mutate("trusted set omits silver_runtime", "silver_runtime.spark", lambda r: None,
               trusted={"silver_output_libc"})
        mutate("trusted set adds silver_io (KeyError both)", "silver_io.spark", lambda r: None,
               trusted=trusted | {"silver_io"}, expect="KeyError")
finally:
    shutil.rmtree(work, ignore_errors=True)

print(f"\nTOTAL comparisons: same={results['same']} different={results['different']}")
sys.exit(1 if results["different"] else 0)
