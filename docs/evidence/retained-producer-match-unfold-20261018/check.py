#!/usr/bin/env python3
"""Check pinned identity and affine-envelope examples, not Why3 execution."""
import hashlib
import json
from pathlib import Path
import re
import tarfile

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
    spark_path = EVIDENCE/'unbounded-programs/frontend-representation-20261017/toolchain/raw-evidence.tar.gz'
    spark_digest = hashlib.sha256(spark_path.read_bytes()).hexdigest()
    assert spark_digest == 'f2e7dd7bbef086a36ddf97f9bd3bd669ca895fcc28e3ac23ffe0c9f85fc5d952'
    emitters = []
    with tarfile.open(spark_path) as archive:
        sources = {m.name: archive.extractfile(m).read().decode()
                   for m in archive.getmembers()
                   if m.name.startswith('spark-source/src/')
                   and m.name.endswith(('.ads', '.adb'))}
    assert len(sources) == 279
    for name, source in sources.items():
        for line, text in enumerate(source.splitlines(), 1):
            if 'GP_Inline_Marker' in text and name.endswith('.adb'):
                emitters.append(dict(path=name, line=line, text=text.strip()))
    assert sorted(x['path'] for x in emitters) == [
        'spark-source/src/why/gnat2why-subprograms.adb',
        'spark-source/src/why/gnat2why-types.adb',
        'spark-source/src/why/why-gen-scalars.adb',
    ]
    literal_sites = [name for name, source in sources.items()
                     if re.search(r'"GP_Inline"', source)]
    assert literal_sites == ['spark-source/src/common/vc_kinds.ads']
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
        spark_archive_sha256=spark_digest,
        spark_source_files=len(sources),
        inline_marker_emitters=emitters,
        new_main_range_profiles=dict(static=[5,2], dynamic=[3,1,1,2],
                                     possible_boolean_axiom_wrapper=3),
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
