# Retained Why3 save-artifact dependency packet

Authoring evidence for [the dependency argument](../../research/retained-why-save-artifact-dependency.md),
#119 / #153, based on `b1c0d89f7b652a1c12e957caa986887be890786e`.
Independent review is pending.

`sources.tar.gz` retains 22 complete files, copied from the two named retained
Why3/SPARK archives and three current Silver files. `source-inputs.json` records
every origin and byte identity; `inputs.json` binds the source archives and
governing/reused records. No source was fetched. `issue-88.json` is a read-only
snapshot of the dependency-test specification, not an adopted implementation.

`source-excerpts.json` retains exact numbered source spans. `dependency-map.json`
maps callers, reads, writes, exception paths and current/later dependencies.
`use-census.json` retains lexical navigation for the private shape/prover fields,
load/save calls and current output consumers; it is not an OCaml/Ada parser or a
machine proof of absence/reachability. The argument supplies the semantic join.

Run the focused static retention check with:

```sh
python3 -B docs/evidence/retained-why-save-artifact-dependency-20261020/check.py
```

It checks exact source correspondence, excerpts and their field-specific anchors,
the retained census, key caller ordering and the explicit limits of the result.
It invokes no native tool, solver, public evaluator or predecessor checker.
`result.json` records the bounded conclusion; `round.json` records selected
settings, measurements and remaining obligations. Source hash agreement does not
newly establish installed-binary provenance, save capacity, reliable interruption
attribution, or complete current proof-pipeline assurance.
