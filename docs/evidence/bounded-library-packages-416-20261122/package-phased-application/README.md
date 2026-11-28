# Phased library and application assurance consumer — 2026-11-27

Focused `ApplicationPhasedAssurance` passed and freshly audited 24,608 imported
declarations. Exact inputs/run identifiers are retained here. Linux x86-64,
two workers/two threads, 8192 MiB per process, guest CPUs 0–1 within the shared
eight-CPU ceiling. Selected GPT-6 Astra Max proof role; live settings and whole-
agent token/cost measurements are unavailable.

The completion-order `PhasedRoutineEntry` fold consumes
`RoutineDefinition.phased_execution_sound` and
`phased_obligations_discharge` for every routine, including unused routines.
It builds the unchanged executable RoutineLibrary and derives callee typing,
effect locality, per-routine checked execution safety and complete phased
initializer/body/result obligation discharge. Each entry's original initializer
list equals its source-selected local/output concatenation. Existing ordinary
routine/library clients retain their behavior.

`checked_phased_application_sound` directly consumes that fold and the existing
Main checker to prove application execution safety and the combined obligation
list. This closes the semantic consumer of phased initialization; it does not
by itself establish the final original-source endpoint. Original declaration,
phase/mutable-mask, routine body/effect and Main histories must construct its
representations and successful checks. No new source validity/certificate fields
are introduced, and no old inferred-entry check stands in for a native widened
stage. Complete native/Lean/source assurance and final review remain required.

This focused batch passed on its first run. The accompanying SemanticMeaning
edit corrects its stale Main wording to package routine checking; the theorem
and proof are unchanged from the preceding recursive package packet.
