#!/usr/bin/env python3
"""Replay source identities/inventory/arithmetic, without running Why3."""
import hashlib
import importlib.util
import json
from pathlib import Path
import re
import sys
import tarfile

sys.dont_write_bytecode = True
HERE = Path(__file__).resolve().parent
REPO = HERE.parents[2]


def identity(data):
    return dict(bytes=len(data), sha256=hashlib.sha256(data).hexdigest())


def archive(path):
    with tarfile.open(path) as source:
        members = source.getmembers()
        assert all(m.isfile() for m in members)
        assert len(members) == len({m.name for m in members})
        return {m.name: source.extractfile(m).read() for m in members}


def hits(data, pattern):
    return [dict(line=n, text=line.strip())
            for n, line in enumerate(data.decode().splitlines(), 1)
            if re.search(pattern, line)]


def compose():
    manifest = json.loads((HERE / "identity.json").read_bytes())
    for name, expected in manifest["dependencies"].items():
        assert identity((REPO / name).read_bytes()) == expected, name
    assert identity((HERE / "sources.tar.gz").read_bytes()) == manifest["archive"]
    additions = archive(HERE / "sources.tar.gz")
    assert {n: identity(b) for n, b in additions.items()} == manifest["members"]
    response = json.loads((REPO / "docs/evidence/retained-producer-response-20261018/identity.json").read_bytes())
    assert manifest["acquisition"]["why3_interface_archive_join"]["sha256"] == response["why3_complete_archive_sha256"]
    prefix = archive(REPO / manifest["why3_archive"])
    gc = archive(REPO / manifest["gc_archive"])
    dispatch_sources = archive(REPO / manifest["dispatch_archive"])
    for name in ("src/transform/introduction.ml", "src/util/hashcons.ml"):
        assert prefix[name] == dispatch_sources[name] == gc["why3/" + name]
    for name in ("src/core/decl.ml", "src/core/term.ml", "src/core/trans.ml",
                 "src/util/weakhtbl.ml", "src/transform/prepare_for_counterexmp.ml",
                 "src/transform/gnat_trivial.ml"):
        assert name in prefix
    weak = gc["ocaml/stdlib/weak.ml"]
    assert identity(weak) == manifest["weak_source"]
    hashcons = prefix["src/util/hashcons.ml"]
    intro = prefix["src/transform/introduction.ml"]
    intro_interface = additions["why3/src/transform/introduction.mli"]
    hashcons_interface = additions["why3/src/util/hashcons.mli"]
    assert b"let tag _ d = d" in intro
    assert b"module Make(H : HashedType) : (S with type t = H.t)" in hashcons
    assert b"next_tag" not in hashcons_interface
    assert b"Hsdecl" not in intro_interface
    assert b"let stats () = WH.stats htable" in hashcons
    assert b"let iter f = WH.iter f htable" in hashcons
    assert b"module Make (H : Hashtbl.HashedType)" in weak
    assert b"H.tag" not in weak
    assert b"let tag n d = { d with d_tag = Weakhtbl.create_tag n }" in prefix["src/core/decl.ml"]
    counter = hits(hashcons, r"\bnext_tag\b")
    assert [h["line"] for h in counter] == [37, 42, 44, 48, 49]
    intro_uses = hits(intro, r"\bHsdecl\b")
    assert [h["line"] for h in intro_uses] == [33, 176]
    source_names = sorted(n for n in prefix if n.endswith((".ml", ".mll", ".mly")))
    assert len(source_names) == 293
    inventory = {
        "counter_occurrences": counter,
        "local_introduction_Hsdecl_occurrences": intro_uses,
        "hashcons_functor_applications": {
            n: h for n in source_names
            if (h := hits(prefix[n], r"\bmodule\s+\w+\s*=\s*Hashcons\.Make\s*\("))
        },
        "direct_introduction_references": {
            n: h for n in source_names
            if (h := hits(prefix[n], r"\bIntroduction\."))
        },
        "source_files_scanned": len(source_names),
    }
    assert len(inventory["hashcons_functor_applications"]) == 7
    assert not any(re.search(rb"Introduction\s*\.\s*Hsdecl", prefix[n])
                   for n in source_names)
    stdlib_mli = additions["ocaml/stdlib/stdlib.mli"]
    assert b"All operations are taken modulo 2{^[Sys.int_size]}" in stdlib_mli
    assert b"They do not fail on overflow." in stdlib_mli
    assert b"Equivalent to [fun r -> r := succ !r]." in stdlib_mli
    assert b"(** [succ x] is [x + 1]. *)" in stdlib_mli
    assert b'external incr : int ref -> unit = "%incr"' in additions["ocaml/stdlib/stdlib.ml"]
    m = 2**62
    modulus = 2*m
    signed = lambda x: ((x + m) % modulus) - m
    encoded = lambda x: (2*x + 1) % (2**64)
    assert signed(m - 1 + 1) == -m
    assert signed(-m + 1) == -m + 1
    assert signed(modulus) == 0
    assert (encoded(m-1) + 2) % (2**64) == encoded(-m)
    assert encoded(-m) & 1
    module_path = REPO / "docs/evidence/retained-producer-driver-envelope-20261018/compose.py"
    spec = importlib.util.spec_from_file_location("driver_envelope", module_path)
    driver = importlib.util.module_from_spec(spec)
    spec.loader.exec_module(driver)
    accepted = driver.compose()
    assert accepted == json.loads((module_path.parent / "result.json").read_bytes())
    assert not accepted["whole_pipeline_capacity_established"]
    return dict(
        schema=1, platform="linux-x86_64",
        why3_revision=manifest["why3_revision"],
        ocaml_revision=manifest["ocaml_revision"],
        scope="Introduction.Hsdecl private counter value only",
        inventory=inventory,
        signed_integer_arithmetic=dict(bits=63, minimum=-m, maximum=m-1,
                                       modulus=modulus, successor_of_maximum=-m,
                                       encoded_maximum=encoded(m-1),
                                       encoded_minimum=encoded(-m)),
        accepted_dispatch=dict(registered_tasks=accepted["sum_registered_task_upper"],
                               task_driver_pairs=accepted["sum_task_driver_pair_upper"],
                               outer_directives=accepted["sum_configured_transform_application_upper"]),
        same_object_hits_can_increment=True,
        source_semantics_machine_checked=False,
        relevant_source_runtime_behavior_required=True,
        introduction_counter_value_irrelevant=True,
        natural_counter_no_wrap_bound_established=False,
        event_bound_required_for_counter_value_irrelevance=False,
        other_hashcons_counters_exempted=False,
        hashcons_event_count_established=False,
        weak_table_capacity_established=False,
        structural_traversal_capacity_established=False,
        prepared_task_domain_capacity_established=False,
        shared_preparation_lifetime_established=False,
        backend_task_printer_capacity_established=False,
        whole_tail_capacity_established=False,
        whole_pipeline_capacity_established=False,
        production_configuration_adopted=False,
        target_executions=0,
    )


if __name__ == "__main__":
    result = compose()
    assert result == json.loads((HERE / "result.json").read_bytes())
    print(json.dumps(result, indent=2))
