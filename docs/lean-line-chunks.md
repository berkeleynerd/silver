# Lean source parallelism

Authorized on 2026-11-05 under [#8](https://github.com/berkeleynerd/silver/issues/8)
and [milestone 17](https://github.com/berkeleynerd/silver/milestone/17).
The original bounded sample experiment is complete; the 2026-11-06 authorization
below selects complete-candidate evaluation and production integration if useful.

Both production splits passed complete Linux validation on 2026-11-06 and are
retained in [PR #326](https://github.com/berkeleynerd/silver/pull/326), pending
owner review and merge. The [completed validation](#completed-production-validation--2026-11-06)
below records the adoption assessment and its measurement limits.

The automatic-CPU restart of PR #307 exposed useful parallel work followed by
a long single-module tail in `OutputBodyCertificate`. At the selected prototype
baseline `617547bd0d`, it contains 4,915 line certificates and 9,829 reconstruction
nodes in one module. The earlier [#246 profile](development-velocity.md#first-package-implementation-and-validation)
attributed 74.79% of named trace time to line certificates and 24.62% to joins.
These historical trace shares are not current CPU costs or a speedup forecast.

## Current selected scope — 2026-11-06

The owner accepted the plan and instructed **“Proceed”**, as recorded in the
[dated authorization](session-memory.md#2026-11-06--lean-source-parallelism-implementation-authorized).
Milestone 17 now has two work packages under #8:

- [#323](https://github.com/berkeleynerd/silver/issues/323): complete the existing
  four-module `OutputBodyCertificate` trial and, if useful, integrate generation,
  runner/module registration and focused tests. Preserve exact line proofs,
  literals/newlines/tokens, reconstruction and final source/lexer theorems.
- [#324](https://github.com/berkeleynerd/silver/issues/324): divide independent
  `PredicateSourceCandidate` checks into about four leaves, preserving every
  check, the final theorem and actual-source transport.

Preparation can proceed in separate worktrees; shared integration follows. Use
one final complete Lean/source/module/axiom checkpoint for both packages, with
applicable native refresh or justified evidence reuse, focused tests and
independent critical review. Keep managed reservations and automatic CPU defaults
subject to host capacity. The complete output candidate remains unvalidated at
authorization; production benefit must be assessed on its actual complete run.
No #314 guards, language/Oracle changes, reconstruction redesign or proof-framework
expansion are selected. Implementation merge remains a later owner decision.

## Historical sample result — 2026-11-05

The completed isolated experiment is retained at `10e58c31ea`, on
[`perf/lean-line-chunks-20261105`](https://github.com/berkeleynerd/silver/blob/perf/lean-line-chunks-20261105/docs/lean-line-chunks.md),
with preparation and review at `c7c0f175c0`. The same 512 declarations in four
modules took 1,081.519 seconds with one worker and 383.054 seconds with four
workers (18.0 to 6.4 minutes; observed 2.823× wall improvement). CPU increased
31.51%; sampled peak aggregate RSS rose from 2.210 to 4.630 GiB. Both trials
rebuilt five candidate modules and preserved the same 25 common object hashes.
One ordered pair with changing competing load supports only that sample
observation. It establishes neither complete-source assurance nor a whole-build
speedup forecast. The full candidate was unvalidated when that experiment stopped.
The [retained sample packet](evidence/lean-line-chunks-20261105/README.md)
is now included on this implementation branch without rerunning the comparison.

## Historical selected scope — 2026-11-05

Keep the existing certificate representation. Move unchanged line-certificate
declarations into four independent modules, preserving their names, literal
text, candidate tokens and checked proofs. The aggregator retains the existing
reconstruction tree and final source, token and lexer theorems. Candidate chunks
remain untrusted; the final connection to actual Ada bytes remains required.

Prepare this complete candidate without adopting it. First measure a fixed
sample of 512 existing line declarations, selected deterministically across the
source and divided into four modules. This sample tests line-check parallelism
and module overhead; it does not check the complete source reconstruction or
establish the whole-feature assurance guarantee.

Use an isolated worktree and proof workspace. Experimental tooling belongs
outside the production `scripts/` and `proof/` trees. Existing verification
inputs and caches remain unchanged; no live cache is copied. Use pinned tools
and the normal kernel checks, without new axioms or bypasses.

## Historical comparison and completion

The sample uses the same four-module graph at one and four Lake workers, with
one thread per Lean process in both trials to isolate module-level parallelism.
That explicit setting is a measurement control, not a replacement for the
owner's automatic-CPU policy on ordinary runs. Build common imports before the
timed comparison; force the same selected module closure for each trial so the
second trial cannot become a warm-cache comparison.

Wait for capacity without holding idle reservations. Existing managed workspace
leases and worker accounting govern the trials. Retain actual commands, source
and tool identities, cache preparation, elapsed and CPU time, sampled memory,
concurrent workloads and terminal outcomes. Changes in competing load limit
causal timing claims. Lean's memory threshold applies per process, not to the
aggregate. Preparation and static equality checks are distinct from Lean
acceptance and benchmark success.

This bounded experiment is complete when the prototype and comparison are
reviewed, the two comparable trial outcomes are retained, and the next step is
explicitly accepted or rejected based on those results. A useful sample result
may justify a complete-certificate trial; it does not authorize production
adoption. Any adoption still needs generator/runner module integration, exact
source/newline/token invalidation controls and the complete source/module/axiom
checkpoint. Reconstruction-subtree splitting, stable chunk identities, broad
tactic changes and persistent telemetry remain outside this experiment.

## Work record

Preparation selected GPT-6.1 Sol / Extra High; the prior read-only structural
assessment selected GPT-6 Astra / Extra High. Lead runtime settings and token/cost
measurements are unavailable. The initial result is the bounded plan above;
no Lean benchmark was run for authorization.


## 2026-11-06 planning round

Routine authorization/publication bookkeeping selected GPT-6.1 Sol / High;
runtime model/effort settings were not independently verified. The intended
result is two bounded issues and a main-branch authorization before claims,
with production completion still pending. This documentation round ran no
proofs, builds or tests; source and assurance claims are unchanged. Token/cost
measurements are unavailable. No CLI recall was updated.

## Initial implementation round — 2026-11-06

Certificate integration and predicate decomposition selected GPT-6.1 Sol / Extra
High in separate worktrees. Independent review selected GPT-6 Astra / Extra High.
Lead runtime settings and token/cost measurements are unavailable. The intended
result was the two scoped module splits followed by measured focused checks and
one stable complete checkpoint; validation was pending at this initial boundary.

The first certificate implementation is `6a2125a52f` (integrated as `c977fb72b0`).
All five generated files are byte-identical to the prepared full candidate.
Independent static review confirms unchanged ordered line declarations and the
unchanged reconstruction/final-theorem suffix. Run
`20261106T104011-475878966fee` checks all four complete line modules with four
Lake workers, automatic twelve-thread process settings and a 6 GiB internal
threshold per process. Four workers match the independent chunk count and leave
room for a small runner regression. The later reconstruction needs its own
larger process allowance. Host CPU and summed RSS are sampled; available RAM
below 4 GiB pauses only the observed run for intervention. These are scheduling
and observation controls, not new assurance assumptions or hard memory bounds.

All three implementation workspaces were seeded while the source was idle from
`tmp/string-review-repairs` at `ea04481188`, whose complete Lean checkpoint is
`20261105T192530-524a4096ef8f`. Copies include the pinned Lean installation and
the complete proof workspace with Lake metadata and private/server object
sidecars. Normal runner regeneration and Lake dependency checks determine reuse;
the copy itself establishes no validation result. The source cache is retained
unchanged. Each destination keeps its dated `tmp/lean-cache-seed.json` pointer.

## Completed production validation — 2026-11-06

The integrated implementation is `3f5d575635106fe9c5ecc039d6111a5a31429e56`.
All subsequent changes in this package are documentation and retained evidence.
The generator now emits four output-body line modules and the existing
reconstruction module. The predicate candidate uses four independent leaves
and a small assembler. Independent review accounted for all 4,915 unchanged
line declarations, the unchanged reconstruction/final-theorem suffix, all 174
original private predicate declarations and the original inline validity check.
The declaration-boundary concern found in the first predicate draft was repaired
before its production trials; no source-correspondence condition was removed.

Complete run `20261106T123115-e73dba359d09` passed on Linux x86-64 with pinned
Lean 4.34.1. Its cached build reported 669 jobs, including 18 rebuilt modules;
the separate fresh audit covered all **634 modules and 130,923 declarations**,
with only `propext`, `Classical.choice` and `Quot.sound`. Build time was
2,197.453 seconds and fresh audit time 9.366 seconds; runner elapsed time was
2,220.833 seconds and the observed wrapper took 2,221.662 seconds. This is
complete source/module/axiom validation with cache reuse, not a clean build or
independent kernel replay. The [final packet](evidence/lean-source-parallelism-20261106/integrated-complete/README.md)
retains the exact input comparison, logs, ledger and observations.

The checkpoint used automatic twelve-worker/twelve-thread settings and a
24,576 MiB per-process allowance. Peak sampled summed RSS was 23.123 GiB;
minimum host available memory was 8.632 GiB. No pressure pause occurred.
Summed RSS may count shared pages and is not exact peak physical memory.

### Performance assessment and adoption

| Work | Observed result |
| --- | --- |
| Complete four-chunk line build | 2,055.420 s; four workers, average sampled use 3.595 cores; all chunks passed |
| Output reconstruction in the integrated run | Lake-reported 1,872 s; passed |
| Predicate Helpers/Flow focused build | 2,002.216 s; passed |
| Predicate Body focused build | 1,623.675 s; passed |
| Predicate NativeShape, 12 GiB trial | 1,601.849 s; failed at the unchanged `condition_tail` header equality's kernel memory limit |
| Predicate NativeShape, 24 GiB retry | 1,614.261 s; passed without source changes |
| Integrated predicate assembler | Lake-reported 2.7 s; passed |

Retain both splits. The complete line build exercised useful parallel work,
and reconstruction plus the final correspondence chain passed. The line build
and reconstruction together took about **65 minutes**, compared with the
previous monolithic output module's 184 minutes. This is a descriptive
comparison of separate runs, not a controlled speedup measurement: historical
Ada inputs and Lean/Lake binaries match, but surrounding builds, contention,
worker settings and cache state differ. The prior predicate module took 6,899
seconds; the new leaves provide independently checkable and schedulable units,
with their actual costs and failed memory experiment shown above. The
[focused packet](evidence/lean-source-parallelism-20261106/lean-focused/README.md)
and [review](reviews/review-lean-parallelism-20261106.md) preserve these comparisons.

The 37-minute final checkpoint reused the completed leaf trials; it is not the
cost of rebuilding this package from scratch. Neither comparison predicts a
whole-feature or cold-build speedup. Reconstruction and individual kernel
reductions still have serial work. Successful separate trials do not establish
that all four heavy predicate leaves fit concurrently on this 32 GiB host.
Keep the automatic CPU defaults and adjust worker allocation when the actual
fresh module set and observed memory pressure require it, recording the reason.
No new scheduler, reconstruction redesign or persistent telemetry was added.

### Evidence applicability and handoff

The [native refresh](evidence/lean-source-parallelism-20261106/native/README.md)
passed all **17,496 checks** with complete report/coverage/provenance auditing;
the native build also passed. All 143 tracked native input hashes match the
integrated source. Native sessions/cache were reused; this is not a cold proof.
The [test applicability review](evidence/lean-source-parallelism-20261106/tests/applicability.md)
accounts for **87 distinct focused test methods**: 70 tooling checks, 16 mocked
platform checks and one real tiny Lean invalidation fixture. The later twelve
source-policy tests repeat part of the 70. No additional full application suite,
macOS or hosted-CI run is claimed for this proof/tooling change.

The [object-transfer record](evidence/lean-source-parallelism-20261106/object-transfer.json)
names the initial cache seed and the later 48 completed Helpers/Flow/Shape
artifacts copied between idle workspaces, including private/server sidecars.
Matching source/tool identities and normal Lake dependency checks governed their
reuse. All failed runs remain failed. The final complete checkpoint supplies
the integrated acceptance that the individual trials could not.

Implementation and evidence retention selected GPT-6.1 Sol / Extra High;
independent critical review selected GPT-6 Astra / Extra High. Runtime-confirmed
lead settings and token/cost figures are unavailable. The closing round retained
the finished results, checked applicability and prepared reviewable publication.
The capability is implemented and validated on the PR branch; #8, #323, #324 and
milestone 17 remain open until an owner-authorized merge. #314 remains deferred
and unchanged. No CLI recall was updated.
