# Completed String alias graph and fixed-frame alias packet

This packet pins GCC revision `6afcc4f6da931eb93f3ab001a0dd9650ea71d1ea`
and the exact retained Silver inputs used by the
[source argument](../../research/retained-literal-type-alias-controls.md).
It adds at most 14 disjoint GGC requests and two scalar registrations for
the completed String alias graph and the fixed-frame alias ID. It is a
source argument and offline arithmetic check, pending independent review.

Run from the repository root:

```sh
python3 docs/evidence/retained-literal-type-alias-controls-20261019/derive.py
python3 docs/evidence/retained-literal-type-alias-controls-20261019/check.py
```

`--gcc-root` selects the retained full source directory. `derive.py --source`
accepts an actual source file through the retained complete recognizer and
current alphabet; it does not accept user-supplied counts as a source proof.
All complete-file pins are verified before loading any accepted pure
transfer. No aggregate/component Context or accepted suite is executed.

The checker covers ownership, source association, native arithmetic,
adversarial repeated/permuted graph queries, retained incoming capacities,
source mutation rejection and deliberately open global claims. Those graph
probes check the exported model; they do not machine-check the C++ source
mapping or prove complete query reachability. The note supplies that limited
graph mapping and explicitly keeps other later clients as unresolved joins.
No native compiler, build, prover, solver, corpus checker or capture is run.

The selected settings were GPT-6 Astra / Extra High. Runtime-confirmed
model/effort and token/cost evidence are unavailable. `round.json` records
actual focused-check elapsed time and the remaining work; parent owns review
and aggregate integration. CLI memory was not updated.
