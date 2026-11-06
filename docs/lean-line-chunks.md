# Lean source parallelism

Authorized on 2026-11-05 under [#8](https://github.com/berkeleynerd/silver/issues/8)
and [milestone 17](https://github.com/berkeleynerd/silver/milestone/17).
The original bounded sample experiment is complete; the 2026-11-06 authorization
below selects complete-candidate evaluation and production integration if useful.

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
