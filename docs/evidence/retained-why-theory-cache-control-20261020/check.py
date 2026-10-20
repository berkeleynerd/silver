#!/usr/bin/env python3
"""Retained-input check and finite challenge model for the source invariant.

The model assumes the source-proved candidate/pending ownership rules; it
does not establish their correspondence to the native execution itself.
"""
import argparse
from collections import deque
import hashlib
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
STATUS = "docs/evidence/retained-why-status-entry-20261020/result.json"
WHY = "docs/evidence/retained-why-session-helper-source-20261019/sources.tar.gz"
RANGES = [
    ("src/session/session_itp.ml", 300, 313, "structural-getters"),
    ("src/session/session_itp.ml", 330, 375, "attempts-and-detachment"),
    ("src/session/session_itp.ml", 645, 675, "attempt-construction-reset"),
    ("src/session/session_itp.ml", 736, 758, "result-and-status-getters"),
    ("src/session/session_itp.ml", 788, 878, "status-propagation"),
    ("src/session/session_itp.ml", 2150, 2172, "save-theory"),
    ("src/util/exthtbl.ml", 40, 58, "default-catches"),
    ("src/util/loc.ml", 302, 306, "loc-error"),
    ("src/util/loc.ml", 338, 341, "loc-errorm"),
    ("src/session/controller_itp.ml", 409, 440, "build-catch"),
    ("src/session/controller_itp.ml", 448, 490, "remove-before-done"),
    ("src/session/controller_itp.ml", 517, 536, "idle-catch"),
    ("src/session/controller_itp.ml", 592, 652, "callback-and-schedule-order"),
    ("src/gnat/gnat_checks.ml", 115, 148, "goal-set"),
    ("src/gnat/gnat_checks.ml", 201, 226, "initial-candidates"),
    ("src/gnat/gnat_checks.ml", 237, 281, "trivial-and-next"),
    ("src/gnat/gnat_checks.ml", 471, 487, "tried-catch"),
    ("src/gnat/gnat_checks.ml", 490, 510, "registration-leaf-iteration"),
    ("src/gnat/gnat_checks.ml", 664, 688, "registration-main-goals"),
    ("src/gnat/gnat_checks.ml", 749, 766, "registration-subprograms"),
    ("src/gnat/gnat_checks.ml", 598, 662, "result-requeue"),
    ("src/gnat/gnat_checks.ml", 983, 1000, "notification"),
    ("src/gnat/gnat_checks.ml", 1038, 1084, "serial-schedule"),
    ("src/gnat/gnat_checks.ml", 1327, 1332, "observer"),
    ("src/gnat/gnat_main.ml", 50, 73, "registration"),
    ("src/gnat/gnat_main.ml", 292, 296, "registration-one-subprogram"),
    ("src/gnat/gnat_main.ml", 75, 160, "gnat-callback-scheduling"),
    ("src/gnat/gnat_main.ml", 298, 309, "signal-save"),
    ("src/gnat/gnat_main.ml", 335, 365, "main-no-restart"),
    ("src/gnat/gnat_scheduler.ml", 1, 29, "blocking-idle-main"),
]


def identity(raw):
    return {"bytes": len(raw), "sha256": hashlib.sha256(raw).hexdigest()}


def encoded(value):
    return json.dumps(value, indent=2, sort_keys=True) + "\n"


# State: actual truth mask, cached leaf mask, transformation, root,
# candidate mask, pending mask, consumed signal escapes. Q is false before
# the first file update. A true selected result retires its candidate.
A, P, T, R, C, W, E = range(7)


def change(state, field, value):
    out = list(state)
    out[field] = value
    return tuple(out)


def read(state, value, exceptional=False):
    yield state, value
    if state[E] < 2:
        yield change(state, E, state[E] + 1), exceptional


def update(state, leaf, n, protected):
    """Completed status updates, first-file entries, and protected aborts.

    False defaults are find_def; true detachment is goal_is_detached.
    Non-signal exceptions may abort protected prefixes WITHOUT consuming E.
    Unprotected aborts are terminal and cannot produce another scheduler step.
    """
    outputs = set()
    files = set()

    def abort(s):
        if protected:
            outputs.add(s)  # service/resource exception, no signal charge
            if s[E] < 2:
                outputs.add(change(s, E, s[E] + 1))

    def theory(s):
        # goal_is_detached root || pn_proved root
        for s1, detached in read(s, False, True):
            choices = [(s1, True)] if detached else read(s1, bool(s1[R]))
            for s2, proved in choices:
                # Before the first file traversal Q defaults to false. A
                # signal at its lookup can only return that same default.
                for s3, _ in read(s2, False):
                    if proved:
                        files.add(s3)
                    else:
                        outputs.add(s3)

    def root(s):
        for s1, proved in read(s, bool(s[T])):
            for s2, old in read(s1, bool(s1[R])):
                if proved != old:
                    s3 = change(s2, R, int(proved))
                    abort(s3)
                    theory(s3)
                else:
                    outputs.add(s2)

    def forall(s, i=0):
        if i == n:
            yield s, True
            return
        for s1, detached in read(s, False, True):
            choices = [(s1, True)] if detached else read(s1, bool(s1[P] & (1 << i)))
            for s2, proved in choices:
                if proved:
                    yield from forall(s2, i + 1)
                else:
                    yield s2, False

    def trans(s):
        for s1, proved in forall(s):
            for s2, old in read(s1, bool(s1[T])):
                if proved != old:
                    s3 = change(s2, T, int(proved))
                    abort(s3)
                    root(s3)
                else:
                    outputs.add(s2)

    abort(state)
    # Detachment can suppress a true attempt; it cannot create a Valid one.
    for s1, proved in read(state, bool(state[A] & (1 << leaf))):
        for s2, old in read(s1, bool(s1[P] & (1 << leaf))):
            if proved != old:
                mask = s2[P] | (1 << leaf) if proved else s2[P] & ~(1 << leaf)
                s3 = change(s2, P, mask)
                abort(s3)
                trans(s3)
            else:
                outputs.add(s2)
    return outputs, files


def explore(n, trivial, initial_pending=0):
    all_leaves = (1 << n) - 1
    initial = (trivial, trivial, 0, 0, all_leaves & ~initial_pending, initial_pending, 0)
    todo = deque([initial])
    seen = {initial}
    if_files = set()
    ordinary_files = set()
    transitions = 0

    def add(states):
        nonlocal transitions
        for s in states:
            transitions += 1
            assert s[P] & ~s[A] == 0, "cache overstates actual leaf truth"
            assert s[C] & s[W] == 0, "candidate overlaps pending owner"
            assert s[W] & s[A] & ~trivial == 0, "nontrivial Valid goal remains pending"
            if s not in seen:
                seen.add(s)
                todo.append(s)

    while todo:
        s = todo.popleft()
        # An irrelevant caught signal is allowed as an overapproximation.
        if s[E] < 2:
            add([change(s, E, s[E] + 1)])
        for i in range(n):
            bit = 1 << i
            if s[C] & bit:
                removed = change(s, C, s[C] & ~bit)
                for picked, proved in read(removed, bool(removed[P] & bit)):
                    if proved:
                        add([picked])
                    else:
                        # Graft can reset a selected attempt only while its
                        # actual truth is false, or leave Trivial true intact.
                        assert not (picked[A] & bit) or trivial & bit
                        scheduled = change(picked, W, picked[W] | bit)
                        states, files = update(scheduled, i, n, False)
                        add(states)
                        ordinary_files.update(files)
            if s[W] & bit:
                # Keep the owner to overapproximate repeated InternalFailure,
                # including a build catch followed by idle's observer catch.
                states, files = update(s, i, n, True)
                add(states)
                if_files.update(files)
                # A failed/interrupted call can also disappear without requeue.
                add([change(s, W, s[W] & ~bit)])
                for valid in [False, True]:
                    done = change(s, W, s[W] & ~bit)
                    done = change(done, A, done[A] | bit if valid else done[A])
                    states, files = update(done, i, n, False)
                    # Only a nonvalid result re-adds the goal. Exhaustion and
                    # warning rules can remove this option, not introduce more.
                    if not valid:
                        states = {change(x, C, x[C] | bit) for x in states}
                    add(states)
                    ordinary_files.update(files)
    assert all(s[E] == 2 and s[A] == s[P] == all_leaves and s[T] == s[R] == 1
               for s in if_files)
    for s in if_files:
        for i in range(n):
            suffix, more_files = update(s, i, n, True)
            assert not more_files and suffix == {s}
    return {"leaves": n, "initial_trivial_mask": trivial,
            "initial_pending_mask": initial_pending, "reachable_states": len(seen),
            "transitions_checked": transitions,
            "protected_first_file_states": len(if_files),
            "ordinary_first_file_states": len(ordinary_files),
            "protected_file_requires_exhausted_budget_and_all_true": True}


def attach_status(record):
    rows = []
    expected = [("put_line", 64, 14, 46), ("put", 53, 12, 46),
                ("first_or_default", 32, 10, 41), ("is_message", 3, 1, 12),
                ("input_is_valid", 4, 3, 21)]
    assert len(record["cases"]) == len(expected)
    for c, (name, leaves, trivials, theories) in zip(record["cases"], expected):
        assert c["case"] == name and c["root_goal_ids"] == [0]
        assert c["leaf_goal_ids"] == list(range(1, leaves + 1))
        assert c["entry_cache_or_default_consistency_established"]
        assert c["all_detached_flags_false"] and c["all_entry_recomputation_inputs_known"]
        assert not c["entry_getter_update_formula_mismatches"]
        trivial = set(c["synthetic_trivial_leaf_ids"])
        assert len(trivial) == trivials and trivials < leaves
        for goal in c["goals"]:
            i = goal["id"]
            assert goal["source_getter_value"] == (i in trivial)
            assert goal["recomputed_from_entry_getters"] == (i in trivial)
            assert goal["task_pointer"] and not goal["detached"]
            if i == 0:
                assert not goal["attempt_ids_in_binding_order"]
                assert goal["transformations"] == [0]
                assert goal["parent"]["kind"] == "Theory"
            else:
                assert goal["parent"] == {"kind": "Trans", "id": 0}
                assert not goal["transformations"]
        assert len(c["transformations"]) == 1
        tr = c["transformations"][0]
        assert tr["id"] == tr["parent_goal"] == 0
        assert tr["subtasks"] == c["leaf_goal_ids"] and not tr["source_getter_value"]
        assert len(c["theories"]) == theories and len(c["files"]) == 1
        assert [t["roots"] for t in c["theories"]] == [[]] * (theories - 1) + [[0]]
        for table in c["cache_tables"].values():
            assert not table["duplicate_keys"] and not table["out_of_domain_keys"]
        th = c["cache_tables"]["theory_state"]
        assert th["scalar_size"] == th["binding_visits"] == 0
        assert th["bucket_capacity"] == 16 and not th["bindings"]
        assert not c["cache_tables"]["file_state"]["bindings"]
        pending = []
        for attempt in c["attempts"]:
            assert not attempt["obsolete"]
            if attempt["prover"]["name"] == "Trivial":
                assert attempt["source_pa_ok"] and attempt["parent_goal"] in trivial
            else:
                assert name == "input_is_valid" and attempt["parent_goal"] == 3
                assert attempt["decoded_status"]["proof_state"] == "None"
                pending.append(attempt["id"])
        if name == "input_is_valid":
            assert pending == [3] and c["phase"]["driver_input_task_goal_ids"] == [3]
            assert c["phase"]["driver_preparation_entry_count"] == 1
        else:
            assert not pending and all(v == 0 for v in c["phase"]["recorded_call_hits"].values())
        before = theories + 2
        resize = before > 32
        rows.append({"case": name, "pid": c["pid"], "leaves": leaves,
                     "initial_true_trivial_leaves": trivials,
                     "initial_actual_equals_cache": True,
                     "theory_count": theories, "first_publication_N_upper": before,
                     "capacity_upper": 32 if resize else 16,
                     "scalar_size_upper": before + 3 if resize else before,
                     "binding_visits_upper": 2 * before + 3 if resize else before,
                     "selected_control_argument_applicable": True,
                     "native_runtime_resource_and_source_premises_required": True,
                     "whole_capacity_closed": False})
    return rows


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--write", action="store_true")
    parser.add_argument("--dependency-root", type=Path,
                        help="authoring-only alternate checkout for not-yet-integrated status packet")
    args = parser.parse_args()
    inputs = json.loads((HERE / "inputs.json").read_text())
    for path, expected in inputs["files"].items():
        base = args.dependency_root if path == STATUS and args.dependency_root else ROOT
        assert identity((base / path).read_bytes()) == expected, path
    excerpts = []
    with tarfile.open(ROOT / WHY) as tar:
        for suffix, first, last, name in RANGES:
            members = [m for m in tar.getmembers() if m.name.endswith("/" + suffix)]
            assert len(members) == 1
            m = members[0]
            raw = tar.extractfile(m).read()
            excerpts.append({"id": name, "archive": WHY, "member": m.name,
                             "member_identity": identity(raw), "first_line": first,
                             "last_line": last,
                             "text": "\n".join(raw.decode().splitlines()[first-1:last]) + "\n"})
    models = [explore(n, (1 << count) - 1)
              for n in range(1, 4) for count in range(n)]
    models.append(explore(2, 1, 2))  # Trivial + current nontrivial inline call
    assert any(m["protected_first_file_states"] for m in models)
    # Removing scheduler ownership permits an IF on a completed Valid goal.
    # One prior fault can then suffice: this is deliberately NOT reachable.
    _, bad_files = update((1, 0, 0, 0, 0, 1, 1), 0, 1, True)
    assert any(s[E] == 1 for s in bad_files)
    status_base = args.dependency_root or ROOT
    joined = attach_status(json.loads((status_base / STATUS).read_text()))
    result = {"scope": "finite challenge of source-proved scheduler/status abstraction",
              "models": models,
              "negative_probe_without_pending_ownership_exposes_one_escape_IF_file": True,
              "universal_argument_is_source_proof_not_enumeration": True,
              "capacity_completeness_claim": False}
    for filename, value in [("source-excerpts.json", excerpts), ("model-result.json", result),
                            ("selected-join.json", joined)]:
        text = encoded(value)
        if args.write:
            (HERE / filename).write_text(text)
        else:
            assert (HERE / filename).read_text() == text, filename
    print(encoded({"status": "pass", "finite_models": len(models),
                   "reachable_states": sum(m["reachable_states"] for m in models),
                   "protected_first_file_states": sum(m["protected_first_file_states"] for m in models)}).strip())


if __name__ == "__main__":
    main()
