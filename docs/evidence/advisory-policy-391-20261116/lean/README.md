# Bounded token-table and procedure-docstring repair — 2026-11-16

This is the owner-authorized Lean portion of [#391](https://github.com/berkeleynerd/silver/issues/391)
and the two November 16 external-review comments on
[PR #371](https://github.com/berkeleynerd/silver/pull/371). The issue, both complete
comments and the November 16 authorization recorded by `33ee7e7c3` were read
before editing. The implementation base is
`877c382f6d07c1e0a2573d4cf70fa13876a399b4`, in the isolated
`repair/token-correspondence-391-20261116` worktree branch. The initial Git state
contained only the unrelated untracked `tmp/` directory, which was preserved.

## Exact owned source scope

This table records the initial focused snapshot. The dated follow-up below
records the Boolean theorem's subsequent move without changing its statement.

| File under `proof/Silver/` | Change |
| --- | --- |
| `ProcedureDeclarationSyntax.lean` | `ProcedureDeclarationNative.Token.name_eq_tokenName_shell`, 14 constructors |
| `PredicateProcedureCallSyntax.lean` | `Predicate.ProcedureCallNative.Token.name_eq_tokenName_shell`, 3 constructors |
| `FunctionDeclarationNative.lean` | `FunctionDeclarationNative.Token.name_eq_tokenName_shell`, 11 constructors |
| `ComposeBooleanDeclarationNative.lean` (original focused location) | `BooleanDeclarationNative.Token.name_eq_tokenName_shell`, 5 constructors; the dated repair moves the unchanged theorem to `ComposeBooleanDeclarationDomain.lean` and removes the added import |
| `PredicateNativeState.lean` | `Predicate.Native.Token.name_eq_tokenName_shell`, 20 constructors |
| `ScalarProcedureComposition.lean` | `DefinitionsSafe` docstring only |
| `ScalarProcedureSemantics.lean` | `Definition.execution_sound` docstring only |

Each new theorem states `∀ t : Token, t.name = Expressions.tokenName t.shell`
and uses `intro t; cases t <;> rfl` (the Predicate native-state module qualifies
`Compose.Expressions`). The 53 existing pairs were independently compared with
the canonical `ComposeExpressions.tokenName` definition; its default branch
renders `=` as `equal`. [token-pairings.json](token-pairings.json) records every
pair. None required correction.

The `DefinitionsSafe` comment now describes precisely fitting outputs, agreement
with checked execution and absence of body effects, for every fitting input and
every definition including unused ones. The `execution_sound` comment describes
its four actual conclusions, including safe output reads. Separate local,
prefix and body lemmas remain separate. There is no new termination statement,
combined deep-safety predicate, changed existing statement or proof body,
Oracle amendment, source pin or certificate change. The native bindings and
implementation files are unchanged in this bounded worktree.
[source-preservation.json](source-preservation.json) verifies that removing the
five exact added theorem texts, one import and the changed docstrings restores
all other bytes of the seven files to the base.

## Focused validation and retained failure

The managed summary was read before the first launch and again after failure.
The previous complete Lean run `20261115T215223-28e04bff3fce` had succeeded;
its artifacts remained cached. All 161 modules in the seven targets' textual
dependency closure already had primary objects. No other managed proof run was
active. The lead reserved this batch exclusively against native proof jobs.

The exact command is retained in [run-focused.py](run-focused.py) and each
attempt's launcher/events metadata. Its checked target set was:

```sh
python3 scripts/check_lean.py \
  --target Silver.ProcedureDeclarationSyntax \
  --target Silver.PredicateProcedureCallSyntax \
  --target Silver.FunctionDeclarationNative \
  --target Silver.ComposeBooleanDeclarationNative \
  --target Silver.PredicateNativeState \
  --target Silver.ScalarProcedureComposition \
  --target Silver.ScalarProcedureSemantics \
  --memory-mb 8192 --provenance --task '#391' \
  --reason 'Bounded five token-name correspondence lemmas and two docstrings; focused seven-module batch with retained caches; automatic available workers and threads on Linux ARM64. No native proof job overlaps. Retained 8192 MiB periodic per-process threshold, with 10 GiB aggregate RSS-tree and 1.5 GiB host MemAvailable monitoring guards; these are not hard OS caps. No clean/replay.'
```

| Attempt | Actual result |
| --- | --- |
| `20261116T223346-5ebf93d9061c` | Failed: `ComposeBooleanDeclarationNative.lean:72:62` could not resolve `Expressions.tokenName`, because this module imported only `ComposeAdmission`. No equality proof or resource guard failed. The complete attempt is retained in [attempt-1](attempt-1/). |
| `20261116T223447-56ea60aaf296` | Passed after the explicit canonical-name import. Seven targets plus their imports and `AxiomAudit`: 162 actual imported modules, 22,708 declarations; foundations `[propext, Classical.choice, Quot.sound]` only. The complete attempt is retained in [attempt-2](attempt-2/). |

The import repair adds no new module to the combined target closure, and imports
no recursive native-condition interpreter. A managed diagnostic checkpoint
records the failure and the next focused check. This was one known import
correction followed by one focused retry; no complete checkpoint was retried.
Two evidence-inspection scripts were also corrected: the first omitted the
canonical token-name fallback, and the second initially resolved artifact paths
against the repository instead of the proof workspace. Neither inspection
started a prover run or changed proof inputs. Final inspections all passed.
Each attempt's `input.patch.gz` retains the exact snapshot diff, compressed with
a zero timestamp; compression preserves diff context spaces without treating
them as whitespace errors in newly committed text.

## Actual host, resources and provenance

Validation ran locally on Linux ARM64 (`silver-m4pro`), Lean 4.34.1, with 12
available CPUs and approximately 15.8 GiB total memory. Worker and thread flags
were omitted: the managed runner confirmed **12 Lake workers and 12 threads per
Lean process**. The retained 8192 MiB periodic per-process memory threshold was
used. Two-second monitoring observed aggregate process-tree RSS and host
`MemAvailable`; the 10 GiB tree/1.5 GiB host limits were monitoring guards, not
hard OS caps or aggregate Lean allocations. RSS can count shared pages more than
once. Neither guard fired.

For the successful run, sampled peak tree RSS was **3.016 GiB** and minimum host
available memory was **14.114 GiB**. Build time was 23.636 seconds; fresh audit time
was 1.493 seconds; managed evidence elapsed time was 32.375 seconds and supervised
terminal elapsed time was 32.592 seconds. The original launcher retained its
child through terminal completion. The failed/successful tool sessions were
`14238`/`15669`, respectively; exact runner PID/PGID and exits are in each
`launcher.json`. Both original terminal results were collected; success exited 0.
The worker reservation was then released to the lead.

[verification-summary.json](verification-summary.json) records the completed
byte checks: all **1,116 repository inputs**, **1,011 workspace inputs**, **6,046
compiled artifacts** and **two Lean/Lake executables** matched the successful
manifest, and the retained log matched its recorded hash. Input digest:
`fea1cea79f39b1fa61782502581e827dde8f902c95ad4e774339ee81c0a822ea`.
Detailed hashes, tool identities, commands and the actual imported module list
remain in [the successful manifest](attempt-2/lean-focused-evidence.json).

[baseline-objects.json](baseline-objects.json) preserves the pre-run inventory
of 1,009 primary objects. All paths still exist; the five table modules changed
as intended, while the other 1,004 primary objects remained byte-identical.
Companion artifacts were retained, with their final hashes included in the
successful provenance. No clean build or independent kernel replay was requested.

## Round and handoff

| Role/settings evidence | Intended result | Achieved result / rework | Available time and cost evidence |
| --- | --- | --- | --- |
| Bounded inherited subthread; model/effort selection and independent runtime identity are not exposed in the recovered context. The lead reports the project-required setting for this proof work as Astra Max; that requirement is not a claim that it was confirmed active. | Check the 53 pairings, add five finite correspondence proofs, correct two comments and obtain a focused fresh audit. | All bounded changes pass; one explicit-import correction after the retained first failure. | Exact native phase and launcher times above; subthread-wide elapsed time, tokens and monetary cost unavailable. |

This is **focused validation on the recorded base plus these seven Lean edits**.
It does not establish the complete native/Lean assurance of the subsequently
integrated #391 repair. The lead will integrate the native changes, hold the
final proof/source/tool inputs stable, and run the complete cached Lean checkpoint
with a fresh whole-project source/module/axiom/provenance audit. The retained
workspace and all existing objects remain available for that run. Publication,
issue bookkeeping and final external review remain with the lead. This subthread
did not update CLI memory, push, merge or begin #373.

## 2026-11-16 follow-up — restore the Boolean module's import boundary

The first complete cached attempt on integrated implementation
`2288af60031763d808b8cd1e024f8fcf7cdc7135` revealed a downstream namespace
ambiguity caused by the added public canonical-name import. The attempt also
crossed its actual aggregate RSS monitoring guard with 12 simultaneous Lean
processes. [The complete-check packet](complete/README.md) retains the exact
failure, frozen inputs, original terminal and resource observations; it is not a
successful complete checkpoint.

Following the parent-assigned Astra Max diagnosis and explicit bounded repair
authorization, the Boolean theorem now resides in
`proof/Silver/ComposeBooleanDeclarationDomain.lean`, in a separate
`Silver.Compose.BooleanDeclarationNative` namespace block immediately before
the existing `.Libraries` namespace. That module already imports both required
tables. The exact theorem text, fully qualified name, type and proof are
unchanged. `ComposeBooleanDeclarationNative.lean` is restored byte for byte to
the `877c382f6d` baseline, removing only the new import and moved theorem.
No import or warning suppression was added; the former public dependency graph
and all pre-existing statements are preserved.

[The repair preservation record](complete/import-repair-preservation.json)
checks the two-file transformation. The other four token lemmas and both
corrected docstrings are unchanged. Historical manifests and the initial
source-preservation record continue to describe their actual checked snapshot.
The selected focused target was `Silver.ComposeBooleanDeclarationDomain`, which
includes both the restored native module and the previously failing meaning
module. It waited for release of the native audit's reservation before running
with two workers, automatic threads and the retained 8192 MiB threshold, with
the same memory guards. The subsequent success is recorded below; a successful
complete refresh remains outstanding.

## 2026-11-16 focused relocation gate — passed

Run `20261116T231040-cddd7187b7b8` on accepted repair head
`c45fe22dc8d9834eac0688976279b79255af849c` passed the single domain target and
a fresh audit of its actual 141-module closure: 15,713 declarations and only
`[propext, Classical.choice, Quot.sound]`. The unchanged previously failing
meaning module built successfully without a warning suppression or source
edit. Two workers/default 12 threads/8192 MiB gave a sampled peak RSS tree of
2.634 GiB and host available-memory minimum of 14.483 GiB; neither guard fired.
The original tool terminal `93277` was collected with exit 0. Detailed exact
input/tool/artifact verification, timings and retained logs are in the
[focused packet](complete/domain-focused/README.md). This is focused evidence;
the full refresh waits for the native repair's final captured bytes.
