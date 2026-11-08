# Raw function-source library derivation — #298 / #340

Implementation commit `e76a3f9420300dec1011b8a549814769a0eb85db`. Owner-authorized bounded R1 repair; five files
owned by the function-native subthread. This is focused partial validation, not
completion of #298 or #340.

`FunctionDeclarationNative.InterpretedSource` now retains raw body/predicate/
wrapper definitions and direct inherited/reader/actual-callee links. Reader
meaning, wrapper normalization and actual imports meaning are derived conclusions.
`PredicateBodyLibraries` factors this derivation using only `RawHelperEquations`
and source-derived lexical meaning. Its 310-module import closure excludes
`PredicateOuterModel`, `PredicateInheritedReady`, `ComposeSourceBridge` and
`FunctionDeclarationSourceBridge`; it does not require the function-declaration
law being constructed. Raw wrapper definitions explicitly carry the native
`Initial_Flow` and `Take_Token` callees. The concrete model exercises the generic
derivation and retains the existing `model_interpreted` signature and native
domains. No Ada, source pins, capacities or language rules changed.

Managed Linux x86_64 run `20261107T230226-02ff494be2c6` passed these targets:

- `Silver.PredicateBodyLibraries`
- `Silver.FunctionDeclarationSourceBridge`
- `Silver.FunctionDeclarationModelSource`

The incremental build completed 351 jobs in 80.146 seconds. The fresh axiom audit
checked 49,907 declarations in 13.585 seconds and found only `propext`,
`Classical.choice` and `Quot.sound`. It finished at 2026-11-07 23:04:43 UTC.
Actual settings were four Lake workers and 22 threads per Lean process, with 22
available CPUs; the four-worker reservation allowed concurrent root/native work.
This was neither a clean build nor independent kernel replay. Exact inputs,
versions, commands and phase timings are retained in `lean-focused-evidence.json`;
`source-hashes.json` identifies all five implementation files.

`PredicateEquations` reuses the extracted library through an adapter and an
extended raw-definition record. That downstream file is included in the commit
but was **not compiled by this focused target set**. The lead must check it in the
current authoritative-source integration, together with the root source bridges,
source candidates and complete assurance. Independent candidate re-review was
requested at the implementation commit above; it is separate evidence.

Two failed prerequisite attempts are retained in the managed ledger:
`20261107T223515-cd3cec4c0343` first reached an existing namespace ambiguity in
`PredicateFunctionCallLibraries`: `Expressions.Calls` resolved to
`Silver.Expressions.Calls`, rather than `Silver.Compose.Expressions.Calls`.
`20261107T230025-379fc4175db0` confirmed that qualification fixed the type errors
and exposed one final reflexive interval-inclusion goal. The lead authorized the
namespace qualification and proof-local final `rfl`; statements, domains and
source semantics are unchanged. Productive objects from both runs were retained;
the corresponding diagnostic records name the evidence and next checks.

Local dependency-only commit `cda3b59dbf` imports the exact parent `3c76b69a59`
baseline in 16 files and must not be cherry-picked back. No CLI memory was updated.
The live harness goal was null; the parent owns task/issue status and publication.
Selected role tier was Astra / Extra High; actual runtime model and effort were
not independently exposed.
