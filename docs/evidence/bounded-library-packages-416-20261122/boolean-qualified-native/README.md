# Qualified Boolean native helper interpretation — 2026-11-22

Run `20261122T152221-0f22d1814997` passed the complete BooleanBindingsSourceBridge and
BooleanBindingsSourceChecks targets and freshly audited **1,526 declarations**.
Linux x86-64, pinned Lean, two workers/two threads sharing the host allocation;
retained compiled dependencies, not a clean or complete assurance run.

The checked typed tree mirrors the native qualified lookup and bare-name-only
Integer hiding. Recursive interpretation quantifies over the full native
metadata/query domain, including absent qualifier spans, zero/invalid member
queries, and every lookup prefix. The model instantiation satisfies the same
equations. Qualified query arguments are `qualifierFirst, qualifierAfter`, after
`index` for lookupModel and after `first, after` for lookup. Bare wrappers remain.

SourceChecks now specifies the exact qualifier/known/value record shape,
contracts and tree tokens. The aggregate Predicate source candidate must still
supply the Checked witness for the actual complete parser tokens; this focused
run does not claim that aggregate actual-source result. The independent exact
Boolean elaboration model still requires its Static_Boolean native/source link.

The chain no longer imports Compose merely for a renderer and a text domain;
the local equivalents are definitionally identical. An explicit tree denotation
normalizes dependent decision instances before the lookup induction. Repeated
failed normalization attempts and the diagnostic checkpoint remain in managed
history. No helper domain, source guarantee or obligation was weakened.

Three QualifiedNames reader-case lemmas in the same checked dependency closure
support the pending scalar array dispatch correspondence. They do not add an
admission condition.
