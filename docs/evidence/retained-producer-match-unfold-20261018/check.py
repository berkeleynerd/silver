#!/usr/bin/env python3
"""Check pinned identity and affine-envelope examples, not Why3 execution."""
import hashlib
import json
from pathlib import Path

HERE = Path(__file__).resolve().parent
EVIDENCE = HERE.parent
SOURCES = {
    'retained-producer-main-types-20261018': '194168fcfc9ebabae3702bb0782f49634d0c73eb808215482ae8a86823e57910',
    'retained-producer-postsplit-20261018': '4f56faf31f0988eb48b0e8d626f0aa078aa8c59970281dad758b10f5cc15e3f1',
}


def application(coefficients, weights):
    ordinary = 1 + sum(weights)
    if coefficients is None:
        return ordinary
    constant, *uses = coefficients
    return max(ordinary, constant+sum(c*w for c, w in zip(uses, weights)))


def main():
    for dirname, expected in SOURCES.items():
        path = EVIDENCE / dirname / 'sources.tar.gz'
        assert hashlib.sha256(path.read_bytes()).hexdigest() == expected
    # Affine equality cost <= its unit cost times the positive argument product.
    # Finite examples corroborate the algebra; they are not a universal proof.
    for c0 in range(1, 5):
        for c1 in range(5):
            for c2 in range(5):
                coefficients = (c0, c1, c2)
                k = max(3, application(coefficients, [1, 1]))
                for x in range(1, 8):
                    for y in range(1, 8):
                        assert application(coefficients, [x, y]) <= k*x*y
    duplicate = lambda w: application((1, 2), [w])
    assert duplicate(duplicate(1)) == 7
    # A marked target can grow an unmarked alias; skipped triggers can instead
    # preserve a larger original symbol. Both require the maximum.
    unmarked_original = application(None, [7])
    marked_target = application((4, 5), [7])
    assert (unmarked_original, marked_target) == (8, 39)
    marked_original = application((3, 9), [7])
    unmarked_target = application(None, [7])
    assert (marked_original, unmarked_target) == (66, 8)
    result = dict(
        source_archive_sha256=SOURCES,
        nested_duplication=7,
        alias_fixtures=[dict(original=8, target=39, envelope=39),
                        dict(original=66, target=8, envelope=66)],
        unmarked_quantifier_profiles=dict(unit=dict(weight=1, overhead=2),
                                          flat_ref=dict(weight=2, overhead=3)),
        native_executions=0,
        scope='Source archive identities and arithmetic only; source formula/definition/alias derivation and whole-producer closure remain required')
    (HERE / 'result.json').write_text(json.dumps(result, indent=2)+'\n')
    print(json.dumps(result))


if __name__ == '__main__':
    main()
