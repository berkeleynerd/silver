# Native entry phases and loop global identities — 2026-11-27

Focused run passed `PackagePhasedRoutineSafety` and `ApplicationPackageLoopLayout`
with a fresh axiom audit of 37,739 imported declarations. The exact run identifier,
inputs, module closure and phase times are in the adjacent evidence. Native host:
Linux x86-64; two Lake workers/two Lean threads, 8192 MiB per process, guest CPUs
0–1 within the shared eight-CPU ceiling. Selected proof role: GPT-6 Astra Max;
live model/effort and whole-agent token/cost measurements are unavailable.

`InitializerPhases` models the native local-declaration, output-read and body-entry
stages. It checks each original local initializer at its original layout, widens
only selected mutable local targets to their declaration domains before output
reads, checks original output RHSs at their retained pre-output layouts, then
widens mutable locals/outputs before the body. Immutable locals keep their
inferred snapshots. The source adapter must construct the phase split and mutable
targets from original declaration/output histories and establish each exact range
view; no new validity premise is added to source syntax.

The full-domain helper theorem derives initialization safety, fitting of both
returned range views and equality with the original checked executable initializer
list. Every local and output initializer obligation is retained. The corresponding
routine theorem proves `RoutineDefinition.Safe` for the existing executable routine,
including complete body execution, result domains and exact checked execution;
its discharge theorem retains initializers, recursive statements and original
result obligations. Existing standalone `check`, `bodyEntry`, `Form` and execution
APIs are unchanged. Library/source aggregation still needs to consume the new
checked routine endpoint.

`checkInitializers_refines` alone cannot close the original routine adapter:
refinement transports semantic fitting, but does not equate the old checker's
inferred body-entry ranges with native `bodyEnvironment` widening or discharge
the same computed obligation list. The explicit phased checker supplies that
calculation. Its soundness follows from declaration refinement; no unproved
expression-inference monotonicity or narrowed formal-input domain is assumed.

The loop target proves that appending a fresh source binder preserves every
global identity, even when its spelling shadows a package state name. The complete
package checker observes the same globals under both layouts. Original loop-entry
widening gives each retained global its declared interval and preserves the scalar
field history. Persistent local addresses remain an execution/layout concern;
this theorem does not assert equality of distinct local addresses.

Failed focused drafts retain their failed outcomes in managed history. Repairs
were constructor qualification, explicit mutual-checker equations/termination
arguments, list lookup normalization, deprecated tactic names and the final
invocationFrame wrapper normalization. No declaration domain, native behavior,
source restriction or proof budget changed. The fresh-slot normalization
reassessment is recorded in the task ledger. Full recursive package aggregation,
source-derived phase adapters, complete native/Lean validation and closing review
remain outstanding; this packet is focused evidence, not feature delivery.
