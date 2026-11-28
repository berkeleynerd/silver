# Raw package-call alias and effect derivation — 2026-11-22

Focused Linux run `20261122T183432-f8f9993982e5` passed
`ApplicationPackageCallsEffects` and a fresh axiom audit of 25,251 declarations
with two workers and two process threads. Build took 4.572 seconds and audit
3.067 seconds. The first small attempt failed because the Option fold reduction
did not match a bind rewrite; explicit constructor cases resolved the proof.

Every successful alias loop now exports the explicit payload/payload and
payload/callee-state separation conditions for every formal index. Alias
processing preserves the read/write sets. Full state reset preserves those
sets, and the accepted call exports the exact final union with its actual
completed-prefix callee effects. No callee safety or completed later table is
assumed. These are derivations from the raw executable equations, not yet the
whole typed Call interpreter, actual-expression semantics or final source claim.
