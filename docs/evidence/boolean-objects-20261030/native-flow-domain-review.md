# Native flow-domain review

Issue #291, 2026-10-30. Selected reviewer: GPT-6 Astra / Extra High, inherited
native subthread; runtime model confirmation, elapsed review time, token usage
and cost were not recorded. This was an independent read-only review requested
by the lead of the source subthread's newly identified contract mismatch.

Inputs: native `a8ee2d9830`, `src/silver_output_profile.adb` definitions
`Valid_Context` and `Valid_Flow`; endpoint `5e2479c08d` with
`PredicateFlowInvariant.lean`, `PredicateConditionFlowValidity.lean`,
`PredicateFlowStorage.lean`, `ScalarExpression.lean`, and the seven native
endpoint files. The later string-reader assertion candidate does not change
these native validity definitions.

The finding is confirmed. Native mutable flow cells must be nonempty and lie
within `Declared_Bounds`. During elaboration, `Valid_Context` permits a narrower
stored `Bounds` snapshot. The current Lean `FlowReady.contained` instead refines
`ScalarExpression.ranges names`, which maps every binding to that snapshot.
For example, mutable `Bounds = [0,0]`, `Declared_Bounds = [0,10]`, elaboration
true, and active flow `[5,5]` pass the native mutable containment condition but
fail the current Lean condition. This is a specification-level counterexample;
no claim of an executable fixture or tool-checked counterexample is made.

The source subthread's proposed repair correctly uses a native bounds map with
mutable declared bounds and immutable snapshot bounds, and proves it equal to
the existing semantic map under `BaseReady` for body callers. No Ada change is
needed. It must cover the full native precondition domain even when initial
source-derived flows happen to use the snapshot.

The seven native endpoint files do not inspect `FlowReady.contained` directly.
They consume shared preservation results, or use count/compatibility fields for
allocation checks, so their dependent proofs need rebuilding after the shared
repair. Their previously successful focused audits remain evidence of their
recorded inputs, not evidence that this newly identified domain obligation was
already closed. Source and scalar helper consumers may require the body-mode
map-equality lemma. No proof files were edited in this review.

Follow-through reported by the source subthread: repair commits `9d1d8d6813`
and `1823f2c244` were integrated by the lead. All seven owned native endpoint
modules rebuilt successfully under the corrected domain in run
`20261030T115006-6b81f016bed4`; that run's overall failure was in older default
Context constructors outside these seven files. Those constructors and the
fresh enclosing audit remain the source subthread's responsibility. These
existing rebuilds are reused instead of rerunning unchanged successful modules.
