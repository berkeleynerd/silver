# Named scalar association model work — 2026-11-17

Owner-authorized #392 covers both existing scalar call kinds, arbitrary full
named order and positional-prefix/named-suffix calls. No domain narrowing,
defaults, new effects or Oracle change is included. This record is development
evidence, not a delivered-capability or complete-assurance claim.

The source resolver uses absolute formal indices, first-match case-insensitive
lookup in the called signature slice, a source ordinal, a named-suffix flag and
a source-derived Boolean visited set. The abstract trace retains written order.
Distinct complete selections establish a permutation of the declared formal
slice; semantic actuals are then arranged in formal order. Every payload is
read under the incoming flow. Procedure traces also retain each payload span so
the alias replay's exact-own-payload exception cannot exempt another occurrence.
The existing expression and condition alias-reading proofs remain in use.

The selected task setting is inherited from the parent (new proof design uses
the project's Astra Max policy); this subthread cannot independently confirm
runtime model identity/effort or total token/cost usage. Linux ARM64 is the
actual validation platform. All runs below are focused, with automatic workers
and threads (12/12 when uncontended), not complete source assurance.

## Setup and focused diagnosis

- `20261117T020908-6a835d48803d`: interrupted before compilation.
- `20261117T020927-d539f1795c66`: Lake could not import its namespace from the
  host-mounted copied installation, followed by an open-file error. No model
  compilation occurred. Root preserved the failed setup and changed only task
  installation/artifact mounts: pinned tools are a read-only native-filesystem
  bind; the proof workspace is an isolated writable overlay with immutable
  matching prior artifacts below it.
- `20261117T022212-a3fd73a6de45`: Lake import succeeded; first real model check
  reached `ScalarAssociations` in 278 ms. It reported an unavailable tactic and
  an insufficient map simplification. The next focused change replaced these
  with core case analysis and an explicit map-congruence proof.
- `20261117T022259-8869775e59dc`: the next check rejected `exists` as a tactic binder
  name before proving coverage. The binder is now an ordinary identifier. This
  is a syntax repair; no mathematical claim, domain or obligation was changed.

The next focused check is the complete `ScalarAssociations` and
`PredicateAssociationAdmission` targets. Call trace, alias and canonical
copy-back proofs remain under implementation and need their own focused checks
before root's integrated checkpoint.

The subsequent resolver-bound retries isolated a proof-script issue: `split` on
both copies of the association expression in a conjunction split duplicate
outer conditions before the intended arrow condition. The repair uses explicit
`by_cases` predicates and simplifies both copies together. A separate import
cycle exposed by the cursor lemmas was removed by placing those lemmas in
`PredicateAssociationBounds`; admission definitions remain below the body
scanner in the import graph. Neither change modifies the resolver equation.

Shared helper success: `20261117T022858-568cc2722567` passed both selected modules and
the fresh transitive module/axiom audit (8,189 declarations). Automatic grants
were 8 Lake workers and 12 process threads alongside the native 4-worker run.
The explicit `ite_eq_left`/`ite_eq_right` proof rewrites resolved the source
branch simplifier issue. See `association-helpers-evidence.json`, the retained
log and `runs.json` for exact input hashes, failed attempts and timings.

Call readings success: `20261117T023346-8dfb9c9cfe64` passed cursor bounds, function
and procedure source traces, soundness, uniqueness, complete selections and
canonical readings, together with both executable admission models and count
properties. Automatic12 workers/12 threads; fresh audit11,170 declarations.
The first attempt compiled all admissions/properties and needed only explicit
record-projection reduction in two cursor-order proofs.
