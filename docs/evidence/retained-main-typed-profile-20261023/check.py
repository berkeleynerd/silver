#!/usr/bin/env python3
"""Focused offline evidence check for the fixed-contract tranche of #178.

Checks frozen providers, current dependency bytes, extraction, binding-sensitive
affine arithmetic and explicit effect-key sets. Does not execute native tools,
prove source correspondence, or claim the unfinished Main emitter is closed.
"""

from collections import Counter
import hashlib
import json
from pathlib import Path
import sys
import tarfile
import time

sys.dont_write_bytecode = True
from profile import affine, contract, node

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]
APIS = {"input_is_valid", "first_or_default", "reject", "put", "put_line"}


def digest(data):
    return hashlib.sha256(data).hexdigest()


def archive_members(path, expected, manifest):
    assert digest(path.read_bytes()) == expected
    with tarfile.open(path) as archive:
        content = {m.name: archive.extractfile(m).read()
                   for m in archive.getmembers() if m.isfile()}
    assert set(content) == {m["path"] for m in manifest}
    for m in manifest:
        data = content[m["path"]]
        assert len(data) == m["bytes"] and digest(data) == m["sha256"]
    return content


def value(tree, weights):
    """Direct lexical interpretation, independent of coefficient elimination."""
    op = tree["op"]
    if op == "var":
        return weights.get(tree["key"], 1)
    if op == "let":
        definition, body = tree["args"]
        a = value(definition, weights)
        return 1 + a + value(body, weights | {tree["binder"]: a})
    if op == "forall":
        weights = weights | {v: 1 for v in tree["binders"]}
    overhead = max(1, len(tree["args"]) - 1) if op == "connection" else 1
    return overhead + sum(value(a, weights) for a in tree["args"])


def evaluate(coefficients, weights):
    c, vs = coefficients
    return c + sum(n * weights.get(v, 1) for v, n in vs.items())


def main():
    started = time.monotonic()
    identity = json.loads((HERE / "identity.json").read_text())
    for provider in identity["providers"]:
        assert digest((ROOT / provider["path"]).read_bytes()) == provider["sha256"]
    fixed = archive_members(HERE / "retained-main-input.tar.gz",
                            identity["archive_sha256"], identity["members"])
    sources = archive_members(HERE / "sources.tar.gz",
                              identity["source_archive_sha256"],
                              identity["source_members"])
    library = [p for p in fixed if p.startswith("silver_")]
    assert len(library) == 6
    for path in library:
        assert fixed[path] == (ROOT / "src" / path).read_bytes()
    # Check source correspondence of the extracted reviewed files, not the
    # predecessor calculations or any native outcome.
    archives = {}
    for entry in identity["source_members"]:
        provider = entry["provider"]
        if Path(provider).is_absolute():
            continue  # Installed a-textio bytes are retained in this packet.
        archives.setdefault(provider, []).append(entry["path"])
    for provider, members in archives.items():
        with tarfile.open(ROOT / provider) as archive:
            for member in members:
                assert archive.extractfile(member).read() == sources[member]

    native = json.loads(fixed["obj/gnatprove/main.gnat-json"])
    projected = {}
    for theory in native["theory_declarations"]:
        for d in theory[3] or []:
            if d[0] == "W_FUNCTION_DECL" and d[2] == 4 and d[3][3][3] in APIS:
                name = d[3][3][3]
                assert name not in projected
                projected[name] = contract(d)
    assert set(projected) == APIS
    assert projected == json.loads((HERE / "selected-contracts.json").read_text())

    expected_units = dict(input_is_valid=4, first_or_default=74, reject=1,
                          put=116, put_line=127)
    expected_effects = dict(input_is_valid=(0, 0), first_or_default=(0, 0),
                            reject=(7, 7), put=(7, 11), put_line=(7, 11))
    external = {"Ada___ada__text_io__" + n + "." + n for n in
                ("standard_in", "standard_out", "standard_err",
                 "current_in", "current_out", "current_err", "file_system")}
    output = {"Silver_io__" + n + "." + n for n in
              ("written_bytes", "written_count", "flushed", "succeeded")}
    arithmetic_checks = 0
    for name, profile in projected.items():
        assert profile["post_lexical"]["at_unit_weights"] == expected_units[name]
        assert (len(profile["reads"]), len(profile["writes"])) == expected_effects[name]
        assert profile["pre"]["op"] == "truth" and profile["pre"]["value"] == 0
        assert profile["native_exceptional_posts"] == 0
        if name in {"put", "put_line", "reject"}:
            assert set(profile["reads"]) == external
            assert set(profile["writes"]) == external | (output if name != "reject" else set())
            assert all(ty.endswith("__ref") for ty in profile["writes"].values())
        terms = [profile["pre"], profile["post"]]
        split = profile["normal_post_extraction"]
        if name in {"input_is_valid", "first_or_default"}:
            assert split is not None
            assert split["definition_lexical"]["at_unit_weights"] == 2
            assert split["residual_lexical"]["at_unit_weights"] == (
                1 if name == "input_is_valid" else 71)
            terms += [split["definition"], split["residual"]]
        else:
            assert split is None
        for term in terms:
            coeff = affine(term)
            for n in range(1, 10):
                weights = {v: (i + 1) * n for i, v in enumerate(sorted(coeff[1]))}
                assert value(term, weights) == evaluate(coeff, weights)
                arithmetic_checks += 1

    # Lexical scope: the inner binder does not replace the outer free x;
    # use counts multiply definitions even when the native storage is shared.
    x = node("var", key="x")
    inner = node("var", key="inner:x")
    fixture = node("let", [node("application", [x, x], symbol="pair"),
                           node("application", [inner, inner, x], symbol="f")],
                   binder="inner:x")
    assert affine(fixture) == (5, Counter(x=7))
    for n in range(1, 20):
        assert value(fixture, {"x": n}) == 5 + 7 * n
        arithmetic_checks += 1
    # Quantified variables reset to unit weight rather than capturing a
    # caller's weight with the same spelling.
    quantified = node("forall", [fixture], binders=["x"])
    assert affine(quantified) == (13, Counter())
    arithmetic_checks += 1

    result = dict(scope="fixed selected API contracts and conditional key accounting; Main source emitter open",
                  host="linux-x86_64", selected_contracts=5,
                  current_library_files=6, source_files=len(sources),
                  frozen_provider_files=len(identity["providers"]),
                  affine_checks=arithmetic_checks,
                  post_unit_costs=expected_units,
                  native_effect_counts=expected_effects,
                  fixed_external_state_keys=7, fixed_output_effect_keys=11,
                  elapsed_seconds=time.monotonic() - started,
                  target_or_proof_runs=0)
    (HERE / "result.json").write_text(json.dumps(result, indent=2) + "\n")
    print(json.dumps(result, indent=2))


if __name__ == "__main__":
    main()
