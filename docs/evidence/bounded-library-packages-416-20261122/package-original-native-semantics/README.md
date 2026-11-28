# Original native Analyze, source meaning and package semantics

Refs #416. `ApplicationPackageOriginalAssembly.SourceMeaning` retains the
original three-unit Bundle's native reading histories, package syntax and Main
syntax. Semantic decoding, checking, effect inclusion, discharge and safety are
not fields of this source witness. `NativeFacts` and `Checked` are independent
derived propositions.

`interpreted_accepted_meaning` starts from the checked native Analyze body
interpretation over arbitrary caller locals and native Bundle representation.
It derives that source witness and its native/checking facts without flattening
the selected source units. `OriginalAssurance.interpreted_accepted_semantics`
adds all package-routine safety, Main executable-environment validity and full
specification/state/routine/Main obligation discharge.

`source_functions_preserve_from` folds the original empty function-write proof
through every completion-order prefix, proving each original function body
preserves the full global frame before its value-only environment wrapper is
used. `interpreted_accepted_values` also derives original immutable load order
and the original RHS value of every persistent state cell, using the same
checked Boolean source interpretation. Those evaluation correspondences remain
theorem conclusions, not source-meaning assumptions.

Focused Linux validation of `Silver.ApplicationPackageOriginalAssurance`
passed with a fresh 92,227-declaration transitive axiom audit. CPUs 0–1,
automatic two workers and two threads per process, 8192 MiB per process. Every
captured source input was rehashed with none missing or changed. Exact run,
inputs and retained artifacts are indexed here. The initial draft needed an
explicit impossible-constructor elimination and a noncomputable annotation
for a definition depending on the already noncomputable native dictionary;
no source, domain, source-pin or proof-budget change was made.

Source-derived Main runtime initialization and the final runtime-execution
corollary remain to join. This is focused evidence, not complete native or
whole-project validation. The authoritative source companion remains unbuilt.
