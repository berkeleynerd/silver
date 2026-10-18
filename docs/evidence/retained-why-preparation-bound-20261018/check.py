#!/usr/bin/env python3
"""Offline identities, independent small-tree expansion and negative checks."""
import copy
import itertools
import json
from pathlib import Path
import subprocess
import sys
import tempfile

sys.dont_write_bytecode = True
import compose


# A small independent, type-erased tree model. It is a fixture generator, not
# an implementation of Why3 or a certificate for the five native inputs.
# Nodes: (kind/name, children, bound-variable names), with globally distinct
# binder names. Applications start with '@'; free variables start with '$'.
def measure(t, bound=frozenset()):
    label, children, names = t
    n, b, a, free = 1, len(names), int(label.startswith("@")), set()
    scope = bound | frozenset(names)
    if label.startswith("$") and label not in scope:
        free.add(label)
    for child in children:
        cn, cb, ca, cf = measure(child, scope)
        n += cn
        b += cb
        a += ca
        free |= cf
    return n, b, a, free


def substitute(t, mapping):
    label, children, names = t
    if label.startswith("$"):
        return mapping.get(label, t)
    mapping = {k: v for k, v in mapping.items() if k not in names}
    return label, tuple(substitute(c, mapping) for c in children), names


def expand(t, environment):
    label, children, names = t
    rewritten = tuple(expand(c, environment) for c in children)
    if label in environment:
        parameters, body = environment[label]
        assert len(parameters) == len(rewritten)
        # Deliberately no recursive expansion of the substituted result.
        return substitute(body, dict(zip(parameters, rewritten)))
    return label, rewritten, names


def tree_checks():
    x, y = ("$x", (), ()), ("$y", (), ())
    atom = ("c", (), ())
    bodies = [x, ("pair", (x, x), ()), ("pair", (x, atom), ()),
              ("forall", (("pair", (x, y), ()),), ("$y",)),
              ("@g", (x,), ())]
    leaves = [atom, ("$z", (), ())]
    trees = leaves[:]
    for _ in range(3):
        smaller = trees[-20:]
        trees += [("@f", (t,), ()) for t in smaller]
        trees += [("forall", (t,), ("$unused",)) for t in smaller]
        trees += [("pair", (left, right), ())
                  for left, right in itertools.product(smaller[:5], repeat=2)]
    comparisons = 0
    for body in bodies:
        en, eb, _, ef = measure(body)
        environment = {"@f": (("$x",), body)}
        profile = dict(nodes=en, binders=eb, mass=en + eb, freevars=len(ef))
        for term in trees:
            n, b, a, _ = measure(term)
            result = compose.inline_kernel(
                dict(nodes=n, binders=b, mass=n + b, applications=a), profile)
            out_n, out_b, _, _ = measure(expand(term, environment))
            assert out_n + out_b <= result["output_opened_mass_upper"]
            assert result["fresh_variable_identifiers_upper"] == b + a * (2 * eb + len(ef))
            comparisons += 1
    # Stored replacements are not fed back through the recursive transformer.
    env = {"@f": (("$x",), ("@g", (x,), ())),
           "@g": (("$x",), ("pair", (x, x), ()))}
    assert expand(("@f", (atom,), ()), env) == ("@g", (atom,), ())
    # Two input applications compose substitutions and can duplicate a binder.
    body = ("pair", (x, x), ())
    term = ("@f", (("forall", (("@f", (atom,), ()),), ("$u",)),), ())
    assert measure(expand(term, {"@f": (("$x",), body)}))[1] == 2
    return comparisons


def reject_bad_dimensions():
    good = dict(nodes=1, binders=0, mass=1, applications=0)
    env = dict(nodes=0, binders=0, mass=1, freevars=0)
    failures = [dict(good, nodes=-1), dict(good, nodes=True),
                dict(good, applications=2), dict(good, binders=1)]
    for term in failures:
        try:
            compose.inline_kernel(term, env)
        except ValueError:
            pass
        else:
            raise AssertionError("invalid dimensions accepted")
    return len(failures)


def main():
    actual = compose.compose()
    assert actual == json.loads((compose.HERE / "result.json").read_bytes())
    assert actual["inline_directive_entries_upper"] == 459
    assert all(names.count("inline_trivial") == 1
               for names in actual["selected_transform_sequence"].values())
    assert actual["synthetic_kernel"]["fresh_variable_identifiers_upper"] == 16
    context = actual["synthetic_context"]
    assert [r["environment_before"]["mass"] for r in context["rows"]] == [1, 3, 27, 27]
    assert context["decl_hashcons_counter_increments_upper"] == 3
    # Mutated candidate dimensions must change the derived bound.
    fixtures = json.loads((compose.HERE / "fixtures.json").read_bytes())
    changed = copy.deepcopy(fixtures["context"])
    changed[1]["terms"][0]["applications"] = 3
    assert compose.inline_context(changed) != context
    comparisons = tree_checks()
    rejected = reject_bad_dimensions()
    # Fail closed on source identity tampering without modifying retained files.
    with tempfile.TemporaryDirectory(prefix="silver-inline-source-tamper-") as tmp:
        target = Path(tmp)
        for name in ("inputs.json", "sources.tar.gz", "fixtures.json"):
            (target / name).write_bytes((compose.HERE / name).read_bytes())
        data = bytearray((target / "sources.tar.gz").read_bytes())
        data[-1] ^= 1
        (target / "sources.tar.gz").write_bytes(data)
        previous = compose.HERE
        try:
            compose.HERE = target
            try:
                compose.verified_sources()
            except AssertionError:
                pass
            else:
                raise AssertionError("tampered archive accepted")
        finally:
            compose.HERE = previous
    cli = subprocess.run([sys.executable, "-B", str(compose.HERE / "compose.py")],
                         check=True, capture_output=True, text=True)
    assert json.loads(cli.stdout) == actual and not cli.stderr
    print(json.dumps(dict(status="passed", independent_tree_expansions=comparisons,
                          bad_dimension_rejections=rejected, archive_tamper_rejected=True,
                          standalone_cli_replayed=True, native_runs=0), indent=2))


if __name__ == "__main__":
    main()
