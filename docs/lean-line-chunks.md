# Parallel line-certificate experiment

Authorized on 2026-11-05 under [#8](https://github.com/berkeleynerd/silver/issues/8)
and [milestone 17](https://github.com/berkeleynerd/silver/milestone/17).
Status: preparation selected; no benchmark or production adoption claimed.

The automatic-CPU restart of PR #307 exposed useful parallel work followed by
a long single-module tail in `OutputBodyCertificate`. At the selected prototype
baseline `617547bd0d`, it contains 4,915 line certificates and 9,829 reconstruction
nodes in one module. The earlier [#246 profile](development-velocity.md#first-package-implementation-and-validation)
attributed 74.79% of named trace time to line certificates and 24.62% to joins.
These historical trace shares are not current CPU costs or a speedup forecast.

## Selected scope

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

## Comparison and completion

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
