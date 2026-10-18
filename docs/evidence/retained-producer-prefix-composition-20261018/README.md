# Fixed Why3 prefix composition evidence

Supports the [complete selected conditional prefix argument](../../research/retained-producer-prefix-composition.md)
for #119, 2026-10-18, Linux x86_64.

- `sources.tar.gz` contains all 293 complete implementation/parser files in
  the preceding prefix source scan, plus `term.mli`, `reduction_engine.mli`
  and the upstream license. Existing source hashes are checked unchanged.
- `source-scan.json.gz` retains broad numeric and dispatch searches, including
  comments and type syntax. It is a review aid, not a call-graph proof.
- `identity.json` pins those sources, the scan and component dependencies.
- `check.py` runs the four prior offline checker entry points, joins all five
  native inputs and eleven imported files, verifies inference is unselected,
  checks the retained term-size caller inventory and evaluates the combined
  numeric conditions. `result.json` retains the result.
- `round.json` records selected settings, actual validation scope and the
  measured packaging/validation interval. It does not invent full-turn time,
  token use or cost.

```sh
python3 docs/evidence/retained-producer-prefix-composition-20261018/check.py
```

Use `--output /tmp/result.json` to recompute instead of comparing the retained
result. The checker requires only Python and the integrated evidence tree. It
does not access the historical `/tmp` paths, installed toolchain or network.
No native producer, debugger, solver, Lean build or suite is launched.

The completeness flag is the conclusion of the linked inspected source
argument under its explicit fixed-context/external-behavior premises. Numeric
replay and source hashes are checked; source semantics and reachability are
not machine-proved by this script. Historical component flags remain unchanged.
Whole-pipeline capacity, variable-Main capacity and production configuration
adoption remain false. This packet ends before the body of `Gnat_checks.init`.
