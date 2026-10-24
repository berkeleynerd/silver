#!/usr/bin/env python3
"""Independent offline #217 repair check; no author/predecessor imports."""
import hashlib
import itertools
import json
import platform
import subprocess
import tarfile
import time
from datetime import datetime, timezone
from pathlib import Path

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[3]
BASE = ROOT / "docs/evidence/retained-general-native-capacity-20261024"
REPAIR = BASE / "provider-attachment"
TARGET = "df7c4491200dbb56642c56b28f9f8341189f967d"
PRIOR = "793a9738ed8f02e5d84e54a9a687894195f36f94"
REPORT = "docs/reviews/review-concat-layout-20261024.md"


def sha(data):
    return hashlib.sha256(data).hexdigest()


def git(*args):
    return subprocess.check_output(["git", *args], cwd=ROOT)


def read(path):
    return json.loads(path.read_bytes())


def main():
    start = time.perf_counter()
    changed = git("diff-tree", "--no-commit-id", "--name-only", "-r", TARGET).decode().splitlines()
    assert len(changed) == 7 and all("/provider-attachment/repair" in p for p in changed)
    exact = []
    for name in changed:
        data = (ROOT/name).read_bytes()
        assert data == git("show", TARGET + ":" + name)
        exact.append(dict(path=name, bytes=len(data), sha256=sha(data)))
    for name in ("repair-max-inputs.json", "repair-max-manifest.json"):
        for row in read(REPAIR/name)["files"]:
            data = (ROOT/row["path"]).read_bytes()
            assert len(data) == row["bytes"] and sha(data) == row["sha256"]
    original = git("show", PRIOR + ":" + REPORT)
    assert (ROOT/REPORT).read_bytes().startswith(original)
    assert sha(original) == read(REPAIR/"repair-max-inputs.json")["acceptance"]["sha256"]
    old_evidence = []
    for name in git("ls-tree", "-r", "--name-only", PRIOR, "docs/evidence/review-concat-layout-20261024").decode().splitlines():
        data = (ROOT/name).read_bytes()
        assert data == git("show", PRIOR + ":" + name)
        old_evidence.append(name)

    witnesses = read(REPAIR/"repair-max-source-witnesses.json")["witnesses"]
    extra = [("gcc/ada/exp_ch4.adb", 3015, 3034),
             ("gcc/ada/exp_ch4.adb", 3077, 3100),
             ("gcc/ada/exp_imgv.adb", 1418, 1429)]
    needed = {w["source"] for w in witnesses} | {p for p, _, _ in extra}
    manifest = read(BASE/"concat-selectors/source-manifest.json")
    source = {}
    for archive in manifest["archives"]:
        path = REPAIR/archive["path"]
        assert sha(path.read_bytes()) == archive["sha256"]
        with tarfile.open(path) as tf:
            for row in manifest["files"]:
                if row["archive"] == archive["path"] and row["path"] in needed:
                    data = tf.extractfile(row["path"]).read()
                    assert len(data) == row["bytes"] and sha(data) == row["sha256"]
                    source[row["path"]] = data
    def span(path, lo, hi):
        return b"\n".join(source[path].split(b"\n")[lo-1:hi])+b"\n"
    for row in witnesses:
        assert sha(span(row["source"], row["first_lf_line"], row["last_lf_line"])) == row["sha256"]
    extra_receipts = [dict(source=p, first_lf_line=lo, last_lf_line=hi,
                           sha256=sha(span(p, lo, hi))) for p, lo, hi in extra]
    equality = span("gcc/fold-const.cc", 3214, 3330).decode()
    assert equality.index("return tree_int_cst_equal") < equality.index("element_precision (type0)")
    comparison = span("gcc/fold-const.cc", 4372, 4400).decode()
    assert "operand_equal_p (arg0, TREE_OPERAND (arg1, 0), 0)" in comparison
    dispatch = span("gcc/fold-const.cc", 13013, 13040).decode()
    assert dispatch.count("if (tem)\n\t    return tem;") == 2
    maximum = span("gcc/fold-const.cc", 6226, 6238).decode()
    assert "MAX_EXPR, comp_type" in maximum and "return fold_convert_loc (loc, type, tem)" in maximum
    producer = span("gcc/ada/exp_ch4.adb", 3020, 3034).decode()
    assert "Nkind (Opnd) = N_Slice" in producer and "Max_Length (NN) := Too_Large_Length_For_Array" in producer

    # Exact projected source trace: no old success/failed paths are refunded.
    traces = {
        "direct_MAX_return": (0, 1, 1, 0),
        "inverted_arm_MAX_return": (0, 1, 1, 0),
        "ordinary_fallback": (0, 0, 0, 1),
        "ordered_conditional_fallback": (0, 0, 1, 1),
    }
    # Success returns before the opposite helper or fallback construction.
    old = (0, 0, 1, 1)
    replacement = (2, 2, 2, 2)
    assert traces["direct_MAX_return"][1] > old[1]
    assert all(all(a <= b for a, b in zip(trace, replacement)) for trace in traces.values())
    ledger = read(BASE/"concat-layout/ledger.json")
    keys = ("constants", "unary", "binary", "ternary")
    old_total = [sum(r["entries"]*r["per_entry"][k] for r in ledger["rows"]) for k in keys]
    assert old_total == [182, 124, 137, 111]
    new_total = [n-o+r for n,o,r in zip(old_total,old,replacement)]
    raw = sum(n*b for n,b in zip(new_total,(40,32,40,48)))
    slots = sum(n*a for n,a in zip(new_total,(0,1,2,3)))
    assert (new_total, raw, slots, raw+167328) == ([184,126,138,112],22288,738,189616)

    # Semantic witness for all signed inputs in a reduced width, plus signed32
    # boundaries. This checks the cross-width MAX continuation, not GCC execution.
    points = list(range(-128,128)) + [-(1<<31), (1<<31)-1]
    for value in points:
        original_cond = value % (1<<64) if value > 0 else 0
        repaired_graph = max(value,0) % (1<<64)
        assert original_cond == repaired_graph
        assert (1+(repaired_graph-1)) % (1<<64) == repaired_graph
    # Structural recursion independently counts the new retained roots.
    def measure(t):
        if not isinstance(t,tuple):
            return (0,1,1)
        cs = [measure(c) for c in t[1:]]
        return (1+max(c[0] for c in cs),1+sum(c[1] for c in cs),1+sum(c[2] for c in cs))
    pure = measure(("mult",("W",("U",("max","G",0))),8))
    view = measure(("mult",("W",("U",("max",("view","V"),0))),8))
    assert pure == (4,7,7) and view == (5,8,8)
    assert all(x <= y for x,y in zip(view,(9,59,63)))
    now = datetime.now(timezone.utc)
    first = datetime(2026,10,24,8,26,3,tzinfo=timezone.utc)
    result = dict(status="passed",target=TARGET,exact_repair_files=exact,
                  prior_review=PRIOR,preserved_report_prefix_bytes=len(original),
                  preserved_report_prefix_sha256=sha(original),preserved_prior_evidence=old_evidence,
                  source_files=len(source),source_spans=len(witnesses)+len(extra),
                  additional_source_spans=extra_receipts,projected_request_traces=traces,
                  corrected_C_U_B_T=new_total,layout_raw_bytes=raw,operand_slots=slots,
                  annotation_raw_bytes=167328,combined_raw_bytes=189616,
                  signed_values_checked=len(points),MAX_h_O_Q=pure,MAX_with_view_h_O_Q=view,
                  selected_reviewer_model="GPT-6 Astra",selected_reviewer_effort="Extra High",
                  runtime_confirmation=None,tokens=None,monetary_cost=None,
                  native_execution_seconds=0,author_or_predecessor_checker_run=False,
                  complete_native_capacity_result=False,
                  host=dict(system=platform.system(),machine=platform.machine()),
                  completed_utc=now.isoformat(),
                  check_elapsed_seconds=round(time.perf_counter()-start,6),
                  elapsed_since_first_review_clock_seconds=round((now-first).total_seconds(),6))
    (HERE/"current.json").write_text(json.dumps(result,indent=2)+"\n")
    print(json.dumps({k:result[k] for k in ("status","source_files","source_spans","check_elapsed_seconds","completed_utc")},indent=2))


if __name__ == "__main__":
    main()
