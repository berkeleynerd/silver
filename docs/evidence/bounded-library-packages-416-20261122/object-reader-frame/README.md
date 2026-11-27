# Successful Object frame preservation

Authorized #416 helper-domain closure, 2026-11-27. Selected proof role: Astra
Max; live model/effort is not independently exposed. This increment adds only
two proof modules and evidence. No native source, declaration guard, semantic
input domain or proof budget changes.

`ApplicationPackageDeclarations.objectStep_reader_frame` proves the full
`ReaderFrame` of every nonzero Object result for valid source text and an input
`ReaderFrame`, arbitrary package metadata, both local modes, and the existing
Boolean reader. The proof combines the previously checked complete native type
domains with state validity derived from each original Object branch.

The state proof covers name hiding, Boolean initialization, integer interval
nonemptiness and inclusion guards, declaration values and mutability, and the
final semicolon cursor bound. Rejected paths retain their original zero result.
It adds no validity check, assumed Object postcondition, metadata-validity
premise, or read restriction. Unit and Completion may use this theorem as their
continuing-loop invariant.

Focused target `Silver.ApplicationPackageDeclarationsObjectFrameDomains`
passed managed run `20261127T213347-c505f6e2988b`: 495 build jobs and a fresh axiom
audit of 70,648 declarations. Linux x86-64 / Lean 4.34.1, two managed workers,
two threads per process, 8192 MiB/process and recorded CPU affinity 0–1. The
runner reports 23.506 seconds including setup. Cached prerequisites were used;
this is focused proof validation, not complete repository or native assurance.
All captured source hashes were rechecked; see `input-recheck.json`.

Draft diagnostics concerned list normalization, Boolean conjunction parsing,
and a private proposition appearing in a public theorem signature. The final
focus checks the resulting complete theorem, with unchanged proof budgets.
Root owns the Unit/Completion source joins and complete assurance integration.

## Current-input refresh

The earlier run above is retained as historical evidence: it captured seven
older shared/native inputs. After synchronizing exactly those inputs from
primary `595c22cdb896c43f0896a43be49369cd5d8ac0cb`, managed run
`20261127T214729-64239ee3783e` passed ObjectFrameDomains together with the new
RoutineFrameLibraries helper scope. Its fresh audit covers 71,073 declarations.
All 1,548 captured hashes match this worktree, and every shared captured input
matches primary; the three private Routine_Frame drafts are listed separately.
The imported Routine_Frame body draft was not a target of this helper run.

The current refresh used explicit CPU affinity 4–5, two workers, two threads
per process and 8192 MiB/process on Linux x86-64 / Lean 4.34.1. The `current-*`
records retain the exact run, log and applicability recheck. Object proof source
is unchanged; the rerun refreshes its dependency/source snapshot without
suppressing the prior failed Routine helper drafts.
