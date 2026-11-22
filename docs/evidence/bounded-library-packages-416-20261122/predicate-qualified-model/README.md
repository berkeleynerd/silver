# Qualified Predicate model and context witness — 2026-11-22

Managed focused run `20261122T161641-d446fee5bfcc` passed on Linux x86-64
with pinned Lean 4.34.1, two Lake workers and two threads per Lean process.
The fresh axiom audit checked 12,876 declarations using only `propext`,
`Classical.choice` and `Quot.sound`. Build took 38.634 seconds; audit 4.193.

Targets were ConditionSound, ConditionUnique, ConditionValidity, NativeProgress,
ScalarGuardMeaning, FlowBounds, LoopProperties and BodyExpectedTokens, all under
`Silver.Predicate`. This covers qualified Boolean grammar/soundness/uniqueness,
scalar refinement through qualified references, full-domain flow/loop validity,
unit-context String readings, and the finite Valid_Context lexer witness.
It does not establish the pending typed helper-library or actual-source endpoint
closure, a complete project audit or independent kernel replay.

The preceding failed run `20261122T161511-843cd5b33a63` compiled the repaired
qualifier aggregate, loop witness, scalar guard and finite context witness, then
exposed a default-context premise in `PredicateReadings.expression_reading_ready`.
The fix generalizes that premise over the already present parser context without
adding assumptions or narrowing admitted sources. Earlier failures and diagnostics
remain in the managed registry. Current inputs also include root Compose checkpoint
`11a033748e` and native scalar-source checkpoint `eaa43165a0`.

The compressed events preserve actual commands, CPU allocation/affinity and
captured input hashes; the evidence and log retain exact target/module scope.
This was a cache-preserving focused build with a fresh axiom audit. Selected proof
role was Astra Max; live settings were not independently exposed. CLI memory was
not updated.
