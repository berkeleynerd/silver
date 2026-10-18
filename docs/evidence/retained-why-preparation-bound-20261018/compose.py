#!/usr/bin/env python3
"""Conditional inline_trivial transfers; not a fixed-input capacity certificate."""
import argparse
import hashlib
import importlib.util
import json
from pathlib import Path
import sys
import tarfile

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def natural(value):
    if type(value) is not int or value < 0:
        raise ValueError("expected a natural number")
    return value


def summary(value):
    """Validate dimensions, not their correspondence to an actual Why3 term."""
    n, b, m, a = (natural(value[k]) for k in
                  ("nodes", "binders", "mass", "applications"))
    if n < 1 or m < n + b or a > n:
        raise ValueError("inconsistent opened-term dimensions")
    return n, b, m, a


def inline_kernel(term, environment):
    """Bound one t_replace_all call; environment bounds all possible hit bodies.

    Dimensions refer to the fully opened occurrence tree, including triggers.
    mass = term nodes + binder slots + pattern nodes. Environment freevars
    counts distinct free term variables. Types/attributes/hidden substitution
    representations are not measured by this interface.
    """
    n, b, m, a = summary(term)
    en, eb, em, ef = (natural(environment[k]) for k in
                      ("nodes", "binders", "mass", "freevars"))
    if em < 1 or em < max(en, eb + 1) or ef > en:
        raise ValueError("inconsistent environment dimensions")
    # A body cannot have binders/free variables without a term root.
    if en == 0 and (eb or ef):
        raise ValueError("empty environment has no body dimensions")
    hits = a if en else 0
    return {
        "output_opened_mass_upper": m * em ** hits,
        "replace_recursive_entries_upper": n,
        "unfold_entries_upper": a,
        "environment_hits_upper": hits,
        "relocate_recursive_entries_upper": hits * en,
        "type_map_term_entries_upper": hits * en,
        "post_type_substitution_recursive_entries_upper": hits * en,
        "fresh_variable_identifiers_upper": b + hits * (2 * eb + ef),
        "all_substitution_work_bounded": False,
        "type_hashcons_or_semantic_count_capacity_established": False,
    }


def inline_context(batches):
    """Compose callback bounds in task order, without relying on cache hits.

    One batch per input task node. 'logic' roots are opened definition bodies
    with 'arity'; 'ind'/'prop' roots are their formulas; other kinds have no
    roots. Every singleton logic declaration is conservatively an export
    candidate, even if the actual inline predicate rejects it. No definition
    is made available until its entire declaration has been transformed.
    """
    env = dict(nodes=0, binders=0, mass=1, freevars=0)
    rows = []
    totals = {k: 0 for k in (
        "replace_recursive_entries_upper", "unfold_entries_upper",
        "environment_hits_upper", "relocate_recursive_entries_upper",
        "type_map_term_entries_upper", "post_type_substitution_recursive_entries_upper",
        "fresh_variable_identifiers_upper")}
    constructor_calls = 0
    for batch in batches:
        kind = batch["kind"]
        if kind not in {"logic", "ind", "prop", "type", "data", "param", "meta", "use", "clone"}:
            raise ValueError("unknown task-node kind")
        terms = batch["terms"]
        if kind not in {"logic", "ind", "prop"} and terms:
            raise ValueError("this declaration kind has no mapped term roots")
        if kind == "prop" and len(terms) != 1:
            raise ValueError("proposition has one formula")
        if kind in {"logic", "ind"} and not terms:
            raise ValueError("nonempty logical/inductive declaration required")
        results = [inline_kernel(t, env) for t in terms]
        for result in results:
            for key in totals:
                totals[key] += result[key]
        stored_mass = []
        for term, result in zip(terms, results):
            size = result["output_opened_mass_upper"]
            if kind == "logic":
                arity = natural(term["arity"])
                # Head application + equality/iff + formal variable occurrences,
                # formal binder slots and a nonempty quantifier node.
                size += 2 + 2 * arity + int(arity > 0)
            stored_mass.append(size)
        if kind in {"logic", "ind", "prop"}:
            constructor_calls += 1
        rows.append(dict(kind=kind, environment_before=dict(env), terms=results,
                         stored_formula_mass_upper=stored_mass))
        if kind == "logic" and len(terms) == 1:
            mass = results[0]["output_opened_mass_upper"]
            free = min(natural(terms[0]["arity"]), mass)
            env = dict(nodes=max(env["nodes"], mass),
                       binders=max(env["binders"], mass - 1),
                       mass=max(env["mass"], mass),
                       freevars=max(env["freevars"], free))
    return dict(rows=rows, kernel_totals=totals,
                input_task_nodes=len(batches), output_task_nodes_upper=len(batches),
                decl_hashcons_counter_increments_upper=constructor_calls,
                fold_callback_entries_upper=len(batches),
                fold_cache_find_entries_upper=len(batches),
                fold_cache_set_entries_upper=len(batches),
                all_fresh_identifiers_bounded=False,
                cache_backing_capacity_established=False)


def verified_sources():
    manifest = json.loads((HERE / "inputs.json").read_bytes())
    for name, expected in manifest["dependencies"].items():
        assert identity((REPO / name).read_bytes()) == expected, name
    assert identity((HERE / "sources.tar.gz").read_bytes()) == manifest["archive_identity"]
    with tarfile.open(HERE / "sources.tar.gz") as archive:
        members = archive.getmembers()
        assert all(m.isfile() for m in members)
        assert len(members) == len({m.name for m in members})
        sources = {m.name: archive.extractfile(m).read() for m in members}
    assert {n: identity(b) for n, b in sources.items()} == manifest["members"]
    for archive_name, names in manifest["accepted_source_joins"].items():
        with tarfile.open(REPO / archive_name) as archive:
            for name in names:
                assert sources[name] == archive.extractfile(name).read(), name
    return manifest, sources


def compose():
    manifest, _ = verified_sources()
    predecessor = HERE.parent / "retained-producer-driver-envelope-20261018/compose.py"
    spec = importlib.util.spec_from_file_location("accepted_driver_envelope", predecessor)
    module = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(module)
    previous = module.compose()
    fixtures = json.loads((HERE / "fixtures.json").read_bytes())
    return dict(
        schema=1, platform="linux-x86_64", base=manifest["base"],
        selected_transform_sequence={p: [t["name"] for t in d["transformations"]]
                                     for p, d in previous["selected_driver_dispatch"].items()},
        registered_task_upper=previous["sum_registered_task_upper"],
        inline_directive_entries_upper=previous["sum_task_driver_pair_upper"],
        outer_transform_directives_upper=previous["sum_configured_transform_application_upper"],
        fixed_input_dispatch_domain=[
            {key: row[key] for key in ("name", "input_sha256", "registered_task_upper",
                                      "distinct_task_driver_pair_upper")}
            for row in previous["cases"]],
        synthetic_kernel=inline_kernel(**fixtures["kernel"]),
        synthetic_context=inline_context(fixtures["context"]),
        source_conditional_inline_transfer_established=True,
        source_argument_machine_checked=False,
        fixed_input_prepared_dimensions_instantiated=False,
        all_preparation_recursive_work_bounded=False,
        all_preparation_fresh_identifiers_bounded=False,
        shared_cache_backing_capacity_established=False,
        whole_pipeline_capacity_established=False,
        production_configuration_adopted=False,
        new_native_runs=0)


if __name__ == "__main__":
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--output", type=Path)
    args = parser.parse_args()
    value = json.dumps(compose(), indent=2) + "\n"
    if args.output:
        args.output.write_text(value)
    else:
        print(value, end="")
