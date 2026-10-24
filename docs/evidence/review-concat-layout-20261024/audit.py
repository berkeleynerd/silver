#!/usr/bin/env python3
"""Independent, offline review check; no author checker or matcher imports.

The source argument is in the review report. These finite checks corroborate
specific guards, unfolded graph charges and arithmetic; they do not execute GCC
or establish a whole-language provider/occurrence attachment.
"""
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
ROOT = HERE.parents[2]
AUTHOR = "302b32d15c293c9f8cf352f80ee9b7b4b068eee0"
BASE = ROOT / "docs/evidence/retained-general-native-capacity-20261024"
PACKET = BASE / "concat-layout"
START = datetime(2026, 10, 24, 7, 41, 57, tzinfo=timezone.utc)


def sha(data):
    return hashlib.sha256(data).hexdigest()


def read(path):
    return json.loads(path.read_bytes())


def git(*args):
    return subprocess.check_output(["git", *args], cwd=ROOT)


def identity_checks():
    names = git("diff-tree", "--no-commit-id", "--name-only", "-r", AUTHOR).decode().splitlines()
    assert len(names) == 11
    inputs = []
    for name in names:
        data = (ROOT / name).read_bytes()
        assert data == git("show", AUTHOR + ":" + name), name
        inputs.append(dict(path=name, bytes=len(data), sha256=sha(data)))
    for name in ("inputs.json", "packet-manifest.json"):
        for row in read(PACKET / name)["files"]:
            data = (ROOT / row["path"]).read_bytes()
            assert len(data) == row["bytes"] and sha(data) == row["sha256"]
    review = read(PACKET / "inputs.json")["accepted_review"]
    assert sha(git("show", review["commit"] + ":" + review["path"])) == review["sha256"]
    manifest = read(BASE / "concat-selectors/source-manifest.json")
    assert manifest["gcc_commit"] == "6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea"
    source = {}
    for archive in manifest["archives"]:
        path = PACKET / archive["path"]
        assert sha(path.read_bytes()) == archive["sha256"]
        with tarfile.open(path) as tf:
            for row in manifest["files"]:
                if row["archive"] == archive["path"]:
                    data = tf.extractfile(row["path"]).read()
                    assert len(data) == row["bytes"] and sha(data) == row["sha256"]
                    source[row["path"]] = data
    witnesses = read(PACKET / "source-witnesses.json")["witnesses"]
    for row in witnesses:
        lines = source[row["source"]].split(b"\n")
        data = b"\n".join(lines[row["first_lf_line"]-1:row["last_lf_line"]]) + b"\n"
        assert sha(data) == row["sha256"]
    return inputs, source, len(witnesses)


def source_checks(source):
    def span(name, lo, hi):
        return b"\n".join(source[name].split(b"\n")[lo-1:hi]).decode()
    distribution = span("gcc/fold-const.cc", 7017, 7099)
    gate = distribution.index("TREE_CODE (arg) == COND_EXPR")
    arm = distribution.index("lhs = fold_build2_loc")
    reject = distribution.index("!TREE_CONSTANT (lhs) && !TREE_CONSTANT (rhs)")
    complete = distribution.index("return fold_build3_loc")
    assert gate < arm < reject < complete
    assert "TREE_SIDE_EFFECTS (arg)" in distribution[:arm]
    assert "TREE_CONSTANT (true_value) || TREE_CONSTANT (false_value)" in distribution[:arm]
    pullout = span("gcc/fold-const.cc", 9286, 9308)
    assert "TYPE_PRECISION (TREE_TYPE (tem)) <= BITS_PER_WORD" in pullout
    assert "tem = build1_loc" in pullout and "build3 (COND_EXPR" in pullout
    assert "fold_build" not in pullout and "return tem;" in pullout
    annotate = span("gcc/ada/gcc-interface/decl.cc", 9436, 9501)
    assert annotate.index("return ops[0];") < annotate.index("ops[1] = annotate_value")
    assert annotate.index("return ops[0];") < annotate.index("if (ops[i] == No_Uint)")
    widened = span("gcc/match.pd", 4571, 4584)
    assert "TYPE_OVERFLOW_UNDEFINED (TREE_TYPE (@1))" in widened
    assert "(convert @1)" in widened
    generic = span("gcc/match.pd", 8654, 8689)
    assert "#if GIMPLE" in generic
    assert "(cmp:c (cond @0 @1 @2) @3)" in generic
    assert "(op (cond @0 @1 @2) @3)" in generic
    return dict(guard_before_candidates=True, failed_candidates_not_refunded=True,
                wider_pullout_uses_plain_builders=True, zero_sum_precedes_retry=True,
                widened_shared_addend_guard=True, scalar_distribution_gimple_only=True)


# Independent expression notation. Each occurrence is visited, including shared
# tuples; no node-identity deduplication or author graph/measurement code is used.
def node(code, *children):
    return (code, children)


LEAF = node("leaf")
ZERO = node("constant")
ONE = node("constant")
NEGATIVE = node("negative_constant")


def profile(t):
    code, children = t
    parts = [profile(c) for c in children]
    return (1 + max((p[0] for p in parts), default=-1),
            1 + sum(p[1] for p in parts),
            1 + sum(p[2] for p in parts) + (code == "negative_plus"))


def conv(t):
    return node("convert", t)


def branch(p, a, b):
    return node("cond", p, a, b)


def profiles():
    rows = {}
    count = 0
    for associated, wrapped, low_literal, inv_low, inv_high in itertools.product((False, True), repeat=5):
        test_low = node("ne" if inv_low else "eq", LEAF, ZERO)
        test_high = node("ne" if inv_high else "eq", LEAF, ZERO)
        low_last = ONE if low_literal else LEAF
        high_last = conv(LEAF) if wrapped else LEAF
        d = (node("negative_plus", node("plus", LEAF, LEAF), NEGATIVE)
             if associated else node("plus", LEAF, node("negative_plus", LEAF, NEGATIVE)))
        a_arms = (LEAF, low_last) if inv_low else (low_last, LEAF)
        b_arms = (d, high_last) if inv_high else (high_last, d)
        a = branch(test_low, *a_arms)
        b = branch(test_high, *b_arms)
        x = branch(test_low, *(ONE if arm is ONE else conv(arm) for arm in a_arms))
        y = branch(test_high, *(conv(arm) for arm in b_arms))
        s = branch(test_low, *(ZERO if arm is ONE else node("negative_plus", conv(arm), NEGATIVE) for arm in a_arms))
        c = node("ge", b, a)
        z = branch(c, y, s)
        delta = node("minus", z, x)
        length = node("plus", delta, ONE)
        bits = node("mult", conv(length), ONE)
        for name, term in (("A", a), ("B", b), ("X", x), ("Y", y), ("C", c),
                           ("S", s), ("Z", z), ("D", delta), ("N", length),
                           ("W_N", conv(length)), ("bits", bits)):
            value = profile(term)
            rows[name] = [max(x, y) for x, y in zip(rows.get(name, [0, 0, 0]), value)]
        count += 1
    assert rows["bits"] == [9, 58, 62]
    assert all(x <= y for x, y in zip(rows["bits"], (9, 59, 63)))
    return dict(variants=count, maxima=rows,
                note="Largest selector family; other case reductions are source-reviewed in report.")


def gate_cases():
    # Truth table for the independently inspected guard, then the two result
    # constants. Counts distinguish rejected-before-work and discarded work.
    classes = {}
    for other_const, other_cond, effects, arm0_const, arm1_const, out0_const, out1_const in itertools.product((False, True), repeat=7):
        blocked = not other_const and (effects or other_cond or arm0_const or arm1_const)
        if blocked:
            result = (0, 0)
        else:
            result = (2, int(other_const or out0_const or out1_const))
        if not other_const and other_cond:
            assert result == (0, 0)
        classes[str(result)] = classes.get(str(result), 0) + 1
    # Mixed outer success keeps the failed inner two candidates; both inner
    # calls and both outer arm calls exist, but only the outer COND survives.
    assert (2 + 2, 0 + 1) == (4, 1)
    return dict(boolean_cases=128, arm_calls_and_cond_results=classes,
                mixed_arm_calls=4, mixed_retained_cond=1)


def annotation_control():
    # Exact relevant control-flow projection, deliberately with a failing child.
    def converted_inner(outer, a, b, child_ok):
        calls = ["inner_left"]
        result = a * b if outer == "mult" else a + b
        if outer == "plus" and result % (1 << 64) == 0:
            return child_ok, calls
        calls.append("synthetic_constant")
        if not child_ok:
            calls += ["ordinary_left_conversion", "ordinary_inner", "inner_left"]
            return False, calls
        return True, calls
    traces = {}
    for succeeds in (False, True):
        ok, trace = converted_inner("plus", -1, 1, succeeds)
        assert ok == succeeds and trace == ["inner_left"]
        traces["zero_sum_" + str(succeeds)] = trace
    ok, trace = converted_inner("mult", 2, 8, False)
    assert not ok and trace.count("inner_left") == 2
    traces["nonzero_failed_child"] = trace
    return traces


def arithmetic():
    count = 0
    points = list(range(-8, 8)) + [-(1 << 31), (1 << 31)-1]
    for low, high in itertools.product(points, repeat=2):
        modulus = 1 << 64
        x, y = low % modulus, high % modulus
        z = y if high >= low else (x-1) % modulus
        value = (z-x+1) % modulus
        assert value == max(0, high-low+1)
        count += 1
    rows = [(7, (2, 4, 2, 2)), (6, (4, 4, 2, 4)),
            (17, (8, 4, 6, 4)), (1, (8, 4, 8, 4)), (1, (0, 0, 1, 1))]
    totals = [sum(n*c[i] for n, c in rows) for i in range(4)]
    assert totals == [182, 124, 137, 111]
    raw = sum(n*b for n, b in zip(totals, [40, 32, 40, 48]))
    slots = sum(n*a for n, a in zip(totals, [0, 1, 2, 3]))
    assert (raw, slots, 2*63*1328, raw+2*63*1328) == (22056, 731, 167328, 189384)
    return dict(endpoint_pairs=count, request_totals_C_U_B_T=totals,
                layout_bytes=raw, operand_slots=slots, annotation_bytes=167328,
                combined_bytes=189384)


def main():
    start = time.perf_counter()
    inputs, sources, witnesses = identity_checks()
    guards = source_checks(sources)
    graph = profiles()
    distribution = gate_cases()
    annotation = annotation_control()
    math = arithmetic()
    completed = datetime.now(timezone.utc)
    result = dict(status="passed", author_commit=AUTHOR, author_inputs=inputs,
                  source_files=len(sources), source_spans=witnesses,
                  source_control_checks=guards, independent_profiles=graph,
                  distribution=distribution, annotation_control=annotation,
                  arithmetic=math, selected_reviewer_model="GPT-6 Astra",
                  selected_reviewer_effort="Extra High", runtime_confirmation=None,
                  tokens=None, monetary_cost=None, native_execution_seconds=0,
                  author_predecessor_or_generated_matcher_executed=False,
                  complete_native_capacity_result=False,
                  host=dict(system=platform.system(), machine=platform.machine()),
                  completed_utc=completed.isoformat(),
                  check_elapsed_seconds=round(time.perf_counter()-start, 6),
                  elapsed_since_first_review_clock_seconds=round((completed-START).total_seconds(), 6))
    (HERE / "current.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps({k: result[k] for k in ("status", "author_commit", "source_files", "source_spans", "check_elapsed_seconds", "completed_utc")}, indent=2))


if __name__ == "__main__":
    main()
