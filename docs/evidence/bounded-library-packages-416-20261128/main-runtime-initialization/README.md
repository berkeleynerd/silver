# Original Main runtime initialization

Authorized bounded #416 proof follow-up, 2026-11-28. Selected proof category:
Astra Max; the live model/effort and token/cost measurements are not independently
exposed. This stream owns the new `ApplicationPackageMainRuntimeInitialization`
module and this evidence packet. Native source, shared proof modules and the
final application endpoint were not changed.

`BodyLibraries.original_runtime` derives the runtime premises required by
`Applications.checked_summary_application_sound` for the exact original
`BodyLibraries.input`. It consumes the original specification equation,
`MainInventory.SourceAt`, the native `DeclarationEntry`, the original argument
cursor guard, and bundle validity. It returns the actual optional argument's
fallback syntax and, for every runtime argument list, String-store `Fits`,
printable selected input, initial-flow `Allows`, and declared integer-store
`Fits`. The initial rejected flag is `false`. Invalid runtime input, empty input,
and Main without an argument declaration are covered.

The stores are explicit: `runtimeValues` executes the argument prefix and the
source String declarations; `runtimeIntegers` evaluates the scalar declaration
inventory from the imported constants and loads the original array elaboration;
`runtimeBooleans` executes the source Boolean inventory from imported Boolean
values. The complete scalar declaration safety and equality with the source
elaboration snapshot are proved in `runtime_integers`. `runtime_booleans` and
`runtime_stores` derive Boolean declaration safety and checked execution. The
generic `MainRuntimeStart.argument` also covers any bounded printable input,
with the argument library's empty-input condition on its invalid branch.

Array readiness is derived from original execution: the specification loop,
including rejection, retains the complete empty array environment, and imports
and the optional argument retain it. The declaration history then supplies
canonical array values and component-subtype containment. Mutable scalar
snapshots are widened to declared body intervals. The original Body_Of and
contextOf interpretations identify these stores' range and path facts with the
actual Main body input. No semantic checker, safety certificate, runtime fitting
premise, snapshot correctness assumption, axiom, or unfinished proof is added to
the original-source endpoint.

Final focused run `20261128T022014-b862f0aede21` passed on Linux x86-64 with
Lean 4.34.1 and a fresh 82,046-declaration foundation axiom audit. All 1,749
captured source hashes were rechecked and matched; the owned workspace copy and
four compiled artifacts were recorded in `input-verification.json`. The run used
CPUs 4–5, automatic two Lake workers and two threads per process, and 8192 MiB
per process. Managed preflight and process coordination reserved the other
running streams' CPU shares. The retained events include the actual allocation.
The runner reports 28.233 seconds including setup, with 10.841 seconds for
building and 4.314 seconds for the fresh audit.

Earlier complete component checks passed before the final original-input join.
Draft failures concerned explicit constructors, namespace resolution, local
record projection normalization and a no-op simplification. One eager native
term expansion reached the default heartbeat limit; an existing opacity
boundary resolved it without increasing any proof budget. The managed ledger
and private `tmp/main-runtime-check*.log` retain these attempts. No repeated
complete integration run was performed.

This is focused partial validation with retained dependency artifacts, not a
clean build, independent kernel replay, complete actual-source check, or feature
completion. The lead and semantic integration stream own the final application
composition, complete assurance and publication.
