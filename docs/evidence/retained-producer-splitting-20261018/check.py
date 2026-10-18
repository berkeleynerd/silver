#!/usr/bin/env python3
"""Offline identity and final-splitter arithmetic checks; no native execution.

The general induction and open upstream join are in the component report.
These small shape examples neither execute Why3 nor establish source-to-VC
correspondence, a source-derived goal bound, or any compiler/prover guarantee.
"""
import hashlib
import json
from pathlib import Path
import tarfile

HERE = Path(__file__).resolve().parent


def bound(f):
    kind, *children = f
    if kind in ("atom", "true", "false", "not", "exists", "or"):
        return 1
    if kind in ("and", "iff", "if", "case"):
        return sum(map(bound, children))
    if kind in ("implies", "let", "forall", "bool_if_eq"):
        return bound(children[-1])
    raise ValueError(kind)


def count(f, k=0):
    """List lengths for the documented well-typed shape abstraction.

    Scalar values, conditions, binder names and attributes are omitted only
    where they cannot change this final splitter's list length. Earlier
    transformations have no model here.
    """
    if k > 20:
        return k + 1
    kind, *children = f
    if kind in ("atom", "true", "false", "not", "exists", "or"):
        return k + 1
    if kind == "and":
        return count(children[0], count(children[1], k))
    if kind in ("implies", "let", "forall", "bool_if_eq"):
        return k + count(children[-1])
    if kind == "iff":
        a, b = children
        return count(("implies", b), count(("implies", a), k))
    if kind == "if":
        a, b = children
        return count(("implies", a), count(("implies", b), k))
    if kind == "case":
        assert children
        return k + sum(map(count, children))
    raise ValueError(kind)


def chain(n, right=True):
    assert n >= 1
    f = ("atom",)
    for _ in range(n - 1):
        f = ("and", ("atom",), f) if right else ("and", f, ("atom",))
    return f


def main():
    identity = json.loads((HERE / "identity.json").read_text())
    archive = HERE / "sources.tar.gz"
    assert hashlib.sha256(archive.read_bytes()).hexdigest() == identity[
        "source_archive_sha256"]
    with tarfile.open(archive) as tf:
        files = {m.name: tf.extractfile(m).read()
                 for m in tf.getmembers() if m.isfile()}
    assert len(files) == len(identity["files"])
    for row in identity["files"]:
        b = files[row["path"]]
        assert len(b) == row["bytes"]
        assert hashlib.sha256(b).hexdigest() == row["sha256"]

    def has(name, fragment):
        assert " ".join(fragment.split()) in " ".join(
            files[name].decode().split()), (name, fragment)

    split = "src/transform/gnat_split_conj.ml"
    has(split, 'Trans.register_transform_l "split_goal_wp_conj" trans')
    has(split, 'Split_goal.split_goal_right')
    has(split, 'let g = (unfold_right 1 env t) in')
    has(split, 'Trans.singleton Gnat_rewrite.elim_to_of_array')
    has(split, 'if List.length acc > 20 then f :: acc else')
    has(split, 'split (split acc (t_attr_copy f f2)) (t_attr_copy f f1)')
    has(split, 'let spf = split [] f in')
    has("src/core/term.ml", '| _ -> raise EmptyCase')
    has("src/transform/gnat_rewrite.ml", 'let env = Mvs.add v tdef env in')
    has("src/mlw/vc.ml", 'let f = Typeinv.inject kn f in')
    has("src/mlw/vc.ml", 'Eval_match.eval_match ~keep_trace kn f')

    shapes = {
        "right_conjunction_100": chain(100),
        "left_conjunction_100": chain(100, False),
        "case_three_right_chains": ("case", chain(30), chain(40), chain(50)),
        "equivalent_right_chains": ("iff", chain(40), chain(50)),
        "conditional_right_chains": ("if", chain(40), chain(50)),
        "boolean_if_equality": ("bool_if_eq", chain(100)),
        "quantified_implication": ("forall", ("implies", chain(100))),
    }
    examples = {}
    for name, f in shapes.items():
        limit = bound(f)
        for k in [0, 1, 19, 20, 21, 22, 100]:
            assert k <= count(f, k) <= k + limit
        examples[name] = dict(structural_bound=limit, leaves=count(f))
    assert examples["right_conjunction_100"]["leaves"] == 100
    assert examples["left_conjunction_100"]["leaves"] == 22
    assert examples["case_three_right_chains"]["leaves"] == 120
    result = dict(source_files=len(files), native_executions=0,
                  examples=examples,
                  scope="final-split list-count transfer only",
                  source_to_terminal_goal_bound="unfinished")
    (HERE / "result.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result))


if __name__ == "__main__":
    main()
