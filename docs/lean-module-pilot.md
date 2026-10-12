# Bounded module and dependency pilot

Historical checkpoint: the owner subsequently authorized the
[coherent module migration](lean-modules.md), which is now adopted after a
complete workload comparison. That decision supersedes the deferral below;
the original pilot's scope and evidence remain recorded here.

Roadmap item 3 of [Lean Critical Path](../roadmap.md#lean-critical-path) was
authorized and completed on 2026-10-12. **This pilot adopted no production migration.**
Lean's new module system demonstrably avoids rebuilding ordinary module
consumers after a proof-only edit. The remaining legacy consumers still depend
on private proof data, including through converted intermediates. Removing the
previously measured complete-check cascade would require migrating 99 of the
109 project modules under the current import graph.

The four-module pilot saved two small rebuilds, with focused runner observations
of 10.371 versus 8.978 seconds. That local result does not justify a near-project
migration during early development. Retain the existing audit and the adopted
[reconstruction optimization](lean-join-optimization.md). Selective improvements
at remaining measured proof hotspots are next proposed; broader module migration
is deferred. The current source correspondence and accepted axioms are unchanged.

## Scope and isolation

The frozen input is `526793536767c6bbb9adeb9de6ac26a8e2ccb370`; the supported
compiler remains Copy String Values (`e9d18f1996`). Independent Git-archive
snapshots exclude the unfinished root `ComposeAdmission.lean` edit. Both start
with copies of the optimized cache retained by the reconstruction experiment.
Canonical tools, caches, earlier evidence and unrelated scratch remain intact.

The actual Linux x86-64 sandbox exposes 12 CPUs, approximately 31 GiB RAM and
no swap. Actual-source pilot commands use pinned Lean 4.34.1, twelve Lake workers,
twelve threads per process and the unchanged 12,288 MiB process threshold:

```sh
python3 scripts/check_lean.py --target Silver.ArgumentsRuntime \
  --workers 12 --threads 12 --memory-mb 12288
```

These are focused checks of six imported project modules, including the audit
helper. They are not complete source-correspondence checkpoints or independent
kernel replays. Tiny separate invalidation and audit controls use one worker,
one thread and a 2,048 MiB threshold. The owner-reported 96 GB physical RAM was
not needed, and no allocation or default changed.

## The actual-source pilot

The copied dependency chain is:

```text
Lexical → Admission → OutputLiteral → OutputRuntime → ArgumentsRuntime
```

The first four modules, totaling 658 source lines before conversion, receive
`module`, `public import` on their existing imports, and
`@[expose] public section`. The final `ArgumentsRuntime` remains legacy.
Public imports preserve the existing reexported API; exposed definitions retain
the computational reduction used by proofs. Theorem proof bodies remain private.
No declaration or proof body changes during this initial conversion.

The proof-only mutation replaces the body of `Silver.accepts_complete` with
`Eq.trans` applied to its original proof and `rfl`. Its name, statement and all
computational definitions stay unchanged. The later public-definition mutation
rewrites `Output.printable` from a decidable conjunction to the conjunction of
its decidable Boolean comparisons. This changes the exposed implementation
while retaining the predicate's meaning.

All six focused checks passed, each with a fresh actual-import/axiom audit:

| Case | Runner | Build | Fresh audit | Rebuilt project modules |
| --- | ---: | ---: | ---: | --- |
| Legacy no change | 7.674 s | 2.773 s | 3.431 s | None |
| Legacy proof-only edit | 10.371 s | 6.548 s | 2.478 s | Admission, OutputLiteral, OutputRuntime, ArgumentsRuntime |
| Initial four-module conversion | 13.065 s | 8.438 s | 3.130 s | Lexical, Admission, OutputLiteral, OutputRuntime, ArgumentsRuntime |
| Converted no change | 6.373 s | 1.853 s | 2.837 s | None |
| Converted proof-only edit | 8.978 s | 4.885 s | 2.480 s | Admission, ArgumentsRuntime |
| Converted public-definition edit | 8.757 s | 5.102 s | 2.313 s | OutputLiteral, OutputRuntime, ArgumentsRuntime |

These are single short observations, not a controlled estimate of whole-project
speedup. Setup/audit time is material and varies even in no-change cases. The
artifact comparison establishes the reuse independently of the timings:

- After the converted proof edit, `Admission.olean` retains its public bytes;
  its private/server objects change. `OutputLiteral` and `OutputRuntime` retain
  their object hashes **and timestamps**. Legacy `ArgumentsRuntime` rebuilds,
  producing byte-identical output.
- The public-definition edit changes the provider's public bytes and rebuilds
  both affected consumers. Reuse does not hide the changed computational body.
- The focused audit covers six project modules and 836 baseline or 841 converted
  declarations. Only `propext`, `Classical.choice` and `Quot.sound` are used.
  The inventory difference is not a changed allowance for axioms.

Independent source normalization removes only the four header conversions and
the two explicit experimental edits to recover the committed proof sources
exactly. Independent evidence review also checks all case inputs, rebuild logs
and artifact hashes/timestamps.

## Source invalidation and audit coverage

A tiny native module fixture independently confirms binary source dependencies:
changing embedded LF to CRLF, with the original nanosecond timestamp restored,
rebuilds the provider and rejects the old consuming equality. Restoring the
source passes again. Changing an exposed public value from 1 to 2 then rejects
its old `rfl` assertion. Both failures have the expected proof diagnostics;
neither a timeout nor a tool failure counts as rejection. The unrelated module's
`.olean`, `.olean.server` and `.olean.private` bytes and timestamps stay intact.
The production runner already inventories `*.olean*` and removes complete module
artifact families; no sidecar-handling rewrite is indicated.

A separate tiny graph tests the actual unchanged `AxiomAudit.lean` under legacy
complete-style and focused-style roots. The provider is behind an intermediate
ordinary import. Clean input and three unused bad-assumption variants produce
all twenty expected outcomes:

| Audit root/import style | Clean | Private axiom | Private theorem with sorry | Private proof-bearing data with sorry |
| --- | --- | --- | --- | --- |
| Existing legacy complete/focused shapes | Pass | Reject | Reject | Reject |
| New module with ordinary imports | Pass | Miss | Miss | Miss |
| New module with `import all` only at the top facade | Pass | Miss | Miss | Miss |
| New module explicitly importing all data from every probe module | Pass | Reject | Reject | Reject |

The two legacy shapes are separate drivers, giving five drivers in total.
Bad producers intentionally compile with ordinary warnings to test the fresh
audit of imported objects; normal production builds still treat warnings as
errors. Every expected rejection names `Unapproved logical assumption` and the
actual private axiom or `sorryAx`. Kernel checking stays enabled. The data
control is proof-bearing data, not a claim to exercise every generated auxiliary.

Retaining the legacy audit preserves transitive private data. A future audit
migration would need complete explicit import coverage; `import all` at a facade
alone is insufficient. These scratch drivers are visibility controls, not runs
of the complete production checker and not a discovered defect in its current
legacy audit. No new audit framework or production regression matrix is added
for a migration that is not adopted.

## Why broader migration is deferred

The [baseline proof-only edit](lean-baseline.md) rebuilt 21 modules. Converting
all affected consumers except the cheap `Silver` umbrella and `Silver.Audit`,
together with their required imports, needs 99 of 109 modules and 54,113 lines
under the current graph. That includes all twelve generated certificates, all
twelve handwritten source bindings, `SourceLexer`, `CertificateWitness`, the
semantic bridges and the currently unfinished `ComposeAdmission` file.

This count is a dependency-closure measurement, not a lower bound for every
possible import refactor. Narrowing `ComposeExpression`'s imports could reduce
its own prerequisites, but its consumers rely on their reexports and the legacy
transitive dependency remains. No small equivalent refactor has demonstrated
the desired complete-check saving.

Pinned Lean/Lake deliberately imports and tracks transitive private artifacts
for legacy roots. The actual pilot reproduces that behavior in the legacy
grandchild. Even the four-module adoption would initially invalidate all legacy
certificates through the changed foundations, while later private foundation
edits would still reach them. A broad migration would additionally require
generator annotations, explicit exposed computational interfaces and complete
source-byte/audit validation. Those costs are deferred until a measured need
or the planned feature foundations makes the scope worthwhile.

## Evidence and handoff

Local ignored evidence is under
`.silver/linux-x86_64/module-pilot-20261012T144532Z/`: frozen inputs, isolated
snapshots, optimized cache copies, six case logs/manifests, artifact inventories,
the dependency analysis, native invalidation/audit controls and independent
reviews. `tmp/module-pilot-active.json` and `checkpoint.md` in that evidence
directory record recovery/publication state. Scratch originals remain under
`tmp/module-pilot-design/`, `tmp/module-pilot-tests/` and `tmp/module-pilot-audit/`.
Ignored evidence is not recoverable from a clone.

All 982 canonical proof/cache files retain their hashes, sizes and timestamps;
the unrelated `ComposeAdmission.lean` edit is byte-identical. The supported proof
tree, runner, compiler, generator and permanent tests are unchanged. No complete
Lean or GNATprove rerun is needed for this documentation-only disposition; prior
evidence keeps its original input scope. Linux remains primary, macOS proof work
is out of scope, and hosted Actions remains disabled.

The review/publication target is the documentation commit introducing this
record, based on `5267935367`. The existing harness goal remains complete; this
pilot creates no new goal. Checked-in session memory is updated, while CLI recall
remains unavailable. The next proposed item is selective proof-authoring
improvement, not an automatic broad module migration.
