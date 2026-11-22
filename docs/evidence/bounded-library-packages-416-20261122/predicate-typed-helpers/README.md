# Predicate typed helpers — 2026-11-22

Focused run `20261122T163258-f99c7f559cdc` passed on Linux x86-64 with Lean 4.34.1,
two Lake workers and two threads per process. The fresh axiom audit checked
37,465 declarations in 279 modules, using only propext, Classical.choice
and Quot.sound. This retained build reused the productive dependency work from
the earlier failed rounds; it is not a clean build or independent kernel replay.

Complete targets: PredicateNativeHelpers, PredicateNativeScalarHelpers,
PredicateBasicEquations and PredicateStructuralGuards. These cover arbitrary
callee interpretation of qualified references, exact typed helper bodies and
operator/scope guards, including all added unit/package context expressions.
Inherited source-library links and actual-source endpoint checking remain pending.

Earlier failed rounds exposed constructor-shadowing pattern names, omitted
optional qualifier arguments, cursor-alias inference, an absent initial-context
witness, and stale context aggregate arity. All are repaired without weakening
contracts or restricting declared domains. The final Boolean proof uses the
explicit ite_eq_left/right equations; earlier if_pos/if_neg names were rejected
by the pinned compiler's warning-as-error policy. Managed diagnostics retain
those failures and their focused hypotheses. Native compiler/source obligations
remain mandatory and are not replaced by this model audit.

Compressed events retain exact commands, allocation, affinity and input hashes.
Selected proof role: Astra Max; live model settings unavailable. CLI memory was
not updated.
