# Exact source range expressions — 2026-11-22

`20261122T193321-c222067426eb` passed ApplicationNativeGuards and DeclarationLaws, with a
fresh audit of 20,586 declarations on Linux x86-64, two managed workers and two
threads per process. The core adds exact membership, interval record equality,
flow-value and actual-array range quantifiers, the read-only flow Count property,
and the context Names field. Source rendering, lexical names, precedence, every
child and typed binder scope remain checked; malformed prefix/child/shadow cases
are rejected by kernel-checked structural controls.

Universal range equations cover 1..Facts.Count and the full static Formal_Index
domain, respectively. Actual-array quantification never shrinks to an accidental
list length; the separate native-storage equality requires maxFormals cells.
These are source interpretation primitives, not metadata validity assumptions.
The prior generic proof failed by eagerly unfolding the recursive evaluator;
directed reduction of just the outer constructor resolved it at the unchanged
200,000-heartbeat budget. Native Call and source jobs were preserved.

Selected diagnosis/proof role GPT-6 Astra Max. Live model/effort confirmation,
whole-team elapsed cost and token data are unavailable. This is focused source
core evidence; complete native/source assurance is still outstanding.
