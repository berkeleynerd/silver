#!/usr/bin/env python3
"""Check frozen source and algebraic right-only splitter interfaces."""
import ast
import hashlib
import itertools
import json
from pathlib import Path
import tarfile
import time

from bounds import bounds, lineage_key_bound

HERE = Path(__file__).resolve().parent
ROOT = HERE.parents[2]


def identity(data):
    return {"bytes": len(data), "sha256": hashlib.sha256(data).hexdigest()}


def right_product(a, b, enabled=True):
    # A Zero is one output; Unit is zero. The selected left defaults to a
    # singleton whenever right_only's other-family test does not pass.
    left = a if enabled and min(2, b) <= 1 else 1
    return left * b


def check():
    manifest = json.loads((HERE / "inputs.json").read_text())
    archive = ROOT / manifest["archive"]["path"]
    assert identity(archive.read_bytes()) == manifest["archive"]["identity"]
    excerpts = json.loads((HERE / "source-excerpts.json").read_text())
    with tarfile.open(archive) as tar:
        for path, expected in manifest["members"].items():
            data = tar.extractfile(path).read()
            assert identity(data) == expected, path
            lines = data.decode().splitlines()
            for section in excerpts.get(path, []):
                selected = "\n".join(lines[section["first"]-1:section["last"]])+"\n"
                assert selected == section["text"], (path, section["first"])

    # Cardinalities need not describe a particular formula: these inequalities
    # hold on the larger nonnegative interface used in the induction.
    values = (0, 1, 2, 3, 17, 32, 65)
    branch_cases = 0
    for p1, n1, p2, n2 in itertools.product(values, repeat=4):
        m1, m2 = max(1, p1, n1), max(1, p2, n2)
        parent = 1 + m1 + m2
        for flag in (False, True):
            pairs = [
                (p1+p2, right_product(n1, n2, flag)),
                (right_product(p1, p2, flag), n1+n2),
                (right_product(n1, p2, flag), p1+n2),
                (p1+p2, 2),
            ]
            assert all(p <= parent and n <= parent for p, n in pairs)
            branch_cases += len(pairs)
    assert right_product(34, 35) == 35
    assert 34*35 > 1+34+35  # sensitivity to removal of the right-only guard

    highest = 0
    for degrees in itertools.product((0, 1, 2), repeat=8):
        accumulator = 0
        for degree in degrees:
            accumulator += degree
            highest = max(highest, accumulator)
            if accumulator > 1:
                break
    assert highest == 3

    for m, p, d in ((1, 0, 0), (99, 8, 7), (4096, 2048, 0), (2**63, 9, 1)):
        result = bounds(m, p, d)
        assert result["positive_negative_family_mass"] == 6*m*m
        assert result["fresh_variable_registrations"] == (m+1)*p
        assert 32*m*m + 4*m*m <= result["scoped_reconstruction_kernel_entries"]
        assert not result["saved_map_bounds_supplied"]
        assert not result["whole_capacity_rule_complete"]
    assert bounds(2**63, 9)["scoped_reconstruction_kernel_entries"] > 2**62-1
    assert lineage_key_bound(6,8,8) == 262
    assert lineage_key_bound(6,8,20) == 646  # free slots cannot be omitted
    for invalid in ((0,0,0), (1,-1,0), (1,0,-1), (True,0,0)):
        try:
            bounds(*invalid)
        except ValueError:
            pass
        else:
            raise AssertionError(invalid)
    for path in HERE.glob("*.py"):
        ast.parse(path.read_text(), filename=str(path))
    return {
        "status": "pass", "source_members": len(manifest["members"]),
        "source_sections": sum(map(len, excerpts.values())),
        "local_branch_cases": branch_cases,
        "unguarded_product_exceeds_linear_bound": True,
        "trivial_accumulator_upper": highest,
        "mathematical_work_not_clamped_to_ocaml_int": True,
        "example_m99_p8": bounds(99, 8),
        "native_target_runs": 0, "predecessor_replays": 0,
        "whole_capacity_rule_complete": False,
    }


if __name__ == "__main__":
    started = time.perf_counter()
    result = check()
    result["elapsed_seconds"] = time.perf_counter() - started
    print(json.dumps(result, indent=2, sort_keys=True))
