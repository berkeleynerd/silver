# Introduction counter source packet

Bounded source analysis at integration `6180f77708`, for
[#119](https://github.com/berkeleynerd/silver/issues/119).
The [argument](../../research/retained-why-introduction-counter.md) establishes
value irrelevance for `Introduction.Hsdecl.next_tag` under the unchanged
relevant-source/runtime premise. It establishes no transformation, weak-table,
printer or whole-pipeline capacity claim.

`identity.json` pins every reused input and all six new complete source files.
`sources.tar.gz` adds Why3 `introduction.mli`/`hashcons.mli`, plus OCaml
`stdlib.ml`/`stdlib.mli`, `mlvalues.h` and its license at the already selected
revisions. The Why3 interfaces were fetched from their exact revision URLs and
also byte-joined to the previously downloaded complete archive whose digest
is recorded in the accepted response packet. The OCaml files were fetched
from exact revision URLs on 2026-10-18. These downloads are source evidence,
not installed-binary attestation or a pin change.

Run from any directory with ordinary Python (assertions enabled):

```sh
python3 docs/evidence/retained-why-introduction-counter-20261018/check.py
```

The checker validates exact dependency/member identities; reuses the accepted
callable driver composition; joins introduction/hashcons and the retained
Weak.Make implementation; inventories the private counter occurrences,
same-named functor applications and direct introduction references; checks
the integer-contract excerpts and exact signed boundary arithmetic; and
compares the whole result to `result.json`. It never launches a target,
compiler, prover or debugger and never fetches source. The source inventory
is a review aid, not a proof of exhaustiveness or OCaml semantics.

The result leaves every other capacity/adoption flag false. Its `round`
record reports selected GPT-6.1 Sol Extra High, with runtime confirmation,
token and cost evidence unavailable. Elapsed time excludes parent review and
integration. No CLI memory or GitHub write occurred.
