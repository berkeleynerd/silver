# Original routine results and native effects — #416

Task scope: derive function terminal results and procedure output reads from the
original completion history, and establish sound inclusion in native read/write
summaries. Initializer source files remain at their checked handoff. This packet
is focused Linux x86_64 Lean 4.34.1 evidence, not complete package assurance.

The first checked increment derives the original function return expression,
readability, scalar syntax, complete result check and expression obligations from
CompletionBodyRead and the actual final native domain. Source effect lemmas derive
scalar and condition read coverage from the original StateDeclarations, rather
than demanding full metadata validity on a shorter package-body source prefix.
Effect list equality is deliberately not claimed: native lexical masks may
conservatively include additional cells.

Focused run `20261127T235754-3c6b67ea0b7d` passed both new modules and a fresh axiom
audit of 38,991 declarations. Build took 5.356 s; audit 5.320 s. All 1,715 captured
inputs matched the checked tree. Affinity CPUs 6–7, automatic two workers and two
threads, 8,192 MiB per-process threshold. No independent kernel replay.

Initial failure `20261127T235504-54692d62a1ed` is retained. Its only proof failure
was transport of a projected native context equality; explicitly exposing the
context projection before rewriting repaired it. The later source-effect change
replaces full metadata validity with the precise original-state declaration
premise; it does not remove source-name, capacity or lookup requirements.

Procedure result row retention, complete effect folding and final source wrapper
integration are still in progress. These helper results do not close #416.

## Formal storage retention

`hideEntries_nonouter` and `hideOuter_nonouter` prove the actual successful hiding
pass retains same-scope rows. `FormalPresent` records only original canonical
header rows. Its Object/local-history/output-storage lemmas derive
`completion_formals_present` for all formals, including in-out rows installed at
entry and output rows installed after initializers. The remaining `notOuter`
premise is a declaration-order fact, to be derived at the complete source join.

Focused run `20261128T000125-19344470ba07` passed
39,001 audited declarations, build 5.150 s and audit 3.784 s. All captured inputs
matched. The initial failed run is retained; fixes removed unused simp arguments,
qualified an ambiguous selected definition, and called a theorem by its namespace.

## Procedure results from original formal rows

`FormalResultAt` retains the canonical native row and chooses its Integer or
Boolean name expression. `FormalPresent.result` derives these rows in the exact
body context. `FormalResultAt.checked` derives the full output-domain check from
native FlowReady, preserving mutable nonemptiness and bounded intermediate reads.
`ProcedureResultsAt` retains formal order and exactly output/in-out modes;
`completion_procedure_results` combines all original completion passes into the
result readability, scalar syntax and native-signature output check. Empty result
lists and mixed Integer/Boolean outputs are covered.

Focused run `20261128T000522-fd1aa11e2dba` passed 39,031 audited declarations with
all 1,715 captured inputs matching. The prior failure is retained (explicit local
row unfolding and one qualified imported theorem name). The original body flow
and domains are unchanged. Complete source-derived notOuter/effect joins remain.
