#!/usr/bin/env python3
"""Independent source/math audit; no author code, GCC, or prover execution."""
from dataclasses import dataclass
from datetime import datetime, timezone
import hashlib
import json
from pathlib import Path
import platform
import re
import subprocess
import tarfile
import time

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
AUTHOR = "e363118b9343dbae72127411f9bc21cc199e2070"
PACKET = ROOT / "docs/evidence/retained-general-native-capacity-20261024/provider-attachment"
STARTED = datetime(2026, 10, 24, 8, 36, 30, tzinfo=timezone.utc)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def git(*args):
    return subprocess.check_output(["git", *args], cwd=ROOT)


def section(data, first, last):
    return b"\n".join(data.split(b"\n")[first - 1:last]) + b"\n"


def main():
    started = time.monotonic()
    target_paths = git("diff-tree", "--no-commit-id", "--name-only", "-r", AUTHOR).decode().splitlines()
    assert len(target_paths) == 13
    target = []
    for path in target_paths:
        data = (ROOT / path).read_bytes()
        assert data == git("show", f"{AUTHOR}:{path}"), path
        target.append({"path": path, "bytes": len(data), "sha256": sha(data)})

    inputs = json.loads((PACKET / "inputs.json").read_text())
    for entry in inputs["files"]:
        data = (ROOT / entry["path"]).read_bytes()
        assert len(data) == entry["bytes"] and sha(data) == entry["sha256"]
    for entry in inputs["frozen_repair_files"]:
        assert (ROOT / entry["path"]).read_bytes() == git("show", f'{inputs["repair_author"]}:{entry["path"]}')
    accepted = []
    for key in ("acceptance", "repair_acceptance"):
        entry = inputs[key]
        assert sha(git("show", f'{entry["commit"]}:{entry["path"]}')) == entry["sha256"]
        accepted.append(entry)

    sources = {}
    source_manifest = json.loads((PACKET / "source-manifest.json").read_text())
    for entry in source_manifest["archives"]:
        assert sha((PACKET / entry["path"]).read_bytes()) == entry["sha256"]
    for entry in source_manifest["files"]:
        with tarfile.open(PACKET / entry["archive"]) as archive:
            data = archive.extractfile(entry["path"]).read()
        assert sha(data) == entry["sha256"] and len(data) == entry["bytes"]
        sources[entry["path"]] = data
    spans = json.loads((PACKET / "source-witnesses.json").read_text())["witnesses"]
    for entry in spans:
        assert sha(section(sources[entry["source"]], entry["first_lf_line"], entry["last_lf_line"])) == entry["sha256"]

    extra = json.loads((HERE / "frontend-sources.json").read_text())
    assert sha((HERE / "frontend-sources.tar.gz").read_bytes()) == extra["archive_sha256"]
    retained = (ROOT / extra["files"][0]["retained_hash_source"]).read_text()
    for entry in extra["files"]:
        with tarfile.open(HERE / entry["archive"]) as archive:
            data = archive.extractfile(entry["path"]).read()
        assert len(data) == entry["bytes"] and sha(data) == entry["sha256"]
        assert entry["sha256"] in retained
        sources[entry["path"]] = data
    for entry in extra["witnesses"]:
        assert sha(section(sources[entry["path"]], entry["first_lf_line"], entry["last_lf_line"])) == entry["sha256"]

    # Guard ordering is significant: the source predicate runs before gigi.
    expansion = sources["gcc/ada/exp_ch4.adb"].decode()
    nullable = expansion.index("      if Result_May_Be_Null then", expansion.index("--  Now we can compute the high bound"))
    low_if = expansion.index("Low_Bound :=", nullable)
    insertion = expansion.index("Insert_Actions (Cnode, Actions, Suppress => All_Checks);", low_if)
    gate = expansion.index("if Compile_Time_Known_Value (Low_Bound)", insertion)
    assert low_if < insertion < gate
    assert "Make_If_Expression" in expansion[low_if:insertion]
    native_fold = sources["gcc/fold-const.cc"]
    assert b"STRIP_NOPS (arg1)" in section(native_fold, 12896, 12948)
    seval = sources["gcc/ada/sem_eval.adb"]
    if_eval = section(seval, 2534, 2609).decode()
    assert if_eval.index("Is_Static_Expression (Condition)") < if_eval.index("if not Rstat then") < if_eval.index("return;")
    known = section(seval, 1812, 1918)
    assert b"N_If_Expression" not in known
    assert b"K = N_Integer_Literal" in known and b"return False;" in known
    same = section(seval, 1091, 1230)
    assert b"Nkind (Lf) /= Nkind (Rf)" in same
    ranges = section(sources["gcc/ada/checks.adb"], 5071, 5650)
    assert b"N_If_Expression" not in ranges
    assert not re.search(rb"\bAttribute_(?:First|Last)\b", ranges)
    assert b"when others =>" in ranges

    # A deliberately small stage model corroborates the distinction, not GCC.
    @dataclass(frozen=True)
    class E:
        kind: str
        args: tuple = ()
        value: int | None = None

    def literal(n):
        return E("literal", value=n)

    def frontend_known(expr):
        return expr.kind == "literal"

    def frontend_if(expr):
        assert expr.kind == "if"
        test, yes, no = expr.args
        if all(frontend_known(x) for x in (test, yes, no)):
            return yes if test.value else no
        return expr

    def gigi_equal_arm(expr):
        assert expr.kind == "if"
        return expr.args[1] if expr.args[1] == expr.args[2] else expr

    g = E("declaration")
    low = E("if", (E("eq", (g, literal(0))), literal(1), literal(1)))
    assert frontend_if(low) == low and not frontend_known(low)
    assert frontend_known(gigi_equal_arm(low))
    # Outer Inner & "x": the First fallback is not literal1, so the claimed
    # literal equality route is unavailable and the source emits a selector/M.
    outer_first = E("first", (low,))
    assert not frontend_known(outer_first)
    witness = {
        "inner_frontend_low_kind": low.kind,
        "inner_frontend_low_compile_time_known": frontend_known(low),
        "later_native_equal_arm_result": gigi_equal_arm(low).value,
        "outer_first_fallback": True,
        "outer_selected_low_s": 1,
        "outer_selected_low_m": 1,
        "model_is_GCC_execution": False,
    }

    # Preserve arithmetic as arithmetic; it does not establish the disputed
    # frontend-to-native source attachment or authorize its substitution.
    rows = [(7, (2, 4, 2, 2)), (6, (4, 4, 2, 4)),
            (17, (8, 4, 6, 4)), (1, (8, 4, 8, 4)), (1, (2, 2, 2, 2))]
    total = tuple(sum(n * row[i] for n, row in rows) for i in range(4))
    assert total == (184, 126, 138, 112)
    assert sum(n * size for n, size in zip(total, (40, 32, 40, 48))) == 22288
    assert total[1] + 2 * total[2] + 3 * total[3] == 738
    assert 24 * 40 + 12 * 32 + 20 * 40 + 12 * 48 == 2720
    assert 22288 + 38 * 1328 == 72752
    # n is not the predecessor's J. Only the actual s=m=0 endpoint path can
    # use this sharper justification: <=4+5r small literal requests <=13n.
    for r in (0, 1):
        assert 4 + 5 * r <= 13 * 2

    completed = datetime.now(timezone.utc)
    result = {
        "status": "independent audit passed; F1 source-closure finding confirmed",
        "reviewed_author": AUTHOR,
        "complete_native_capacity_result": False,
        "selected_reviewer_model": "GPT-6 Astra",
        "selected_reviewer_effort": "Extra High",
        "runtime_confirmation": None,
        "tokens": None,
        "monetary_cost": None,
        "first_review_clock_utc": STARTED.isoformat(),
        "completed_utc": completed.isoformat(),
        "audit_elapsed_seconds": round(time.monotonic() - started, 6),
        "elapsed_since_first_review_clock_seconds": round((completed - STARTED).total_seconds(), 6),
        "host": {"system": platform.system(), "machine": platform.machine(), "node": platform.node()},
        "native_execution_seconds": 0,
        "author_or_predecessor_checkers_run": False,
        "audit_development": "An initial source-token check matched Attribute_First_Bit as Attribute_First; corrected to exact token boundaries before the successful audit. No author/source change or successful-check replay.",
        "target_files": target,
        "accepted_reviews": accepted,
        "preserved_repair_files": len(inputs["frozen_repair_files"]),
        "source_files": len(sources),
        "source_spans": len(spans) + len(extra["witnesses"]),
        "finding_witness": witness,
        "arithmetic_only": {"layout_CUBT": total, "layout_bytes_per_t_plus_one": 22288, "layout_slots_per_t_plus_one": 738},
    }
    (HERE / "current.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({k: result[k] for k in ("status", "source_files", "source_spans", "audit_elapsed_seconds", "completed_utc")}))


if __name__ == "__main__":
    main()
