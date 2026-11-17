# Proof iteration efficiency

## Authorization and order

On 2026-11-10, after discussing #370's proof cost and concrete enforcement,
the owner instructed: **“Add this as our next unit of work. All of these
optimizations should be implemented to resolve the relevant ticket / roadmap
item.”** [Session memory](session-memory.md#2026-11-10--proof-iteration-efficiency-authorized-as-the-next-unit)
records the authorization. [#373](https://github.com/berkeleynerd/silver/issues/373),
in [milestone 24](https://github.com/berkeleynerd/silver/milestone/24), owns one
coherent tooling and proof-workflow package with one shared final checkpoint.

Scalar procedures [#370](https://github.com/berkeleynerd/silver/issues/370)
and its [#29](https://github.com/berkeleynerd/silver/issues/29) companion merged in
[PR #371](https://github.com/berkeleynerd/silver/pull/371) on 2026-11-17.
Preserve their evidence and the separately authorized Worca implementations
below. No intervening language expansion is selected. Current-main integration
and complete successor validation remain pending.

Closed [#8](https://github.com/berkeleynerd/silver/issues/8),
[#246](https://github.com/berkeleynerd/silver/issues/246) and
[#39](https://github.com/berkeleynerd/silver/issues/39) are historical predecessors,
not reopened work. Build on the existing [iteration controls](proof-iteration.md),
[development policy](../development.md#proof-loop-and-validation) and managed
`dev.py` / `check_lean.py` runners. Use their task records, caches and reservations;
no generic scheduler, telemetry service or proof-identity framework is selected.

## Current handoff — 2026-11-17

The owner subsequently confirmed the Worca artifacts unavailable and selected
[named scalar arguments #392](named-scalar-arguments.md) as the immediate language
work while recovery awaits. This package and all eight increments remain open;
the implementations and explicit PR #385 hold are preserved. The remaining
handoff below applies when the original branches and evidence become available.
No #373 implementation was started during the current recovery investigation.

The existing eight increments #377–#384 retain one shared final checkpoint in
#384. [#377's issue record](https://github.com/berkeleynerd/silver/issues/377#issuecomment-6821158029)
reports Worca's local implementation at `5e91e71be5`, with focused tests passed
and review/integration outstanding. [#378's record](https://github.com/berkeleynerd/silver/issues/378#issuecomment-6834054115)
reports local implementation `f4b7a9e75c`, focused successes and a remaining
selector-family recurrence gap. Both branches are absent from this checkout and
the current GitHub branch list; obtain their exact commits and evidence before
review. Integrate serially because their runner and test changes overlap.

[#379](https://github.com/berkeleynerd/silver/issues/379) is the first unstarted
coding increment: establish the canonical focused/full compiler policy and
experimental-result classification. Start from the delivered #371 policy and
evidence; its native recovery retained the canonical 30-second policy. The
historical mismatch below does not by itself justify larger budgets.

The owner's current request authorizes this assessment, without taking over
the Worca streams or lifting the explicit hold on draft
[PR #385](https://github.com/berkeleynerd/silver/pull/385). No successor code is
changed in this closeout. All milestone-24 issues remain open. Board access lacks
`read:project`; issue-recorded status is not independently verified board status.

## Problem and decisions to settle

#373 records the concrete #370 observations: the complete compiler configuration
used a 30-second timeout while focused trials used 100,000 steps, no timeout and
a 1,000 MiB limit. Successful retained solver attempts beyond 30 seconds expose
policy incompatibility; cached attempts alone do not establish a speedup.
Settle this mismatch before choosing the shared compiler policy. The separately
pinned application proof policy remains unchanged.

Line/column-based failure keys and selector-path scopes can lose recurrence
across ordinary edits. Certificate chunks offer parallel work, while substantial
aggregate `kernel_exact` reconstruction is serial; hardware thread counts do not
promise equal aggregate speedup. Earlier aggregate timings with different source
or machine inputs are not controlled comparisons. Select context decomposition,
splitting strategy and aggregate reservations from bounded current evidence.

## Required implementation and completion checklist

All items belong to #373; a partial optimization does not finish the package.
Keep reviewable commits while sharing final validation. If a real scope split
becomes necessary, record the increments and their issues together under
[planning guidance](planning.md#delivery-batches), without silently dropping work.

- [ ] **Canonical focused/full compiler policy.** Add a focused compiler-proof
  path to the existing runner using the complete audit's canonical solver/budget
  definition. Preserve whole-helper contracts and separate exploration workspaces.
  Keep explicit experiments available and label successes incompatible with the
  final policy as experimental, rather than final-policy readiness.
- [ ] **Resource override reasons.** Preserve automatic available-worker grants
  and hardware-default Lean process threads. Require a retained reason for a
  deliberate reduction below the available allocation/default; automatic grants
  reduced by managed reservations remain ordinary behavior. Report requested and
  actual settings, reassess overrides each run and preserve applicable caches
  when only resource allocation changes.
- [ ] **Stable recurrence.** Extend existing diagnostics to recognize the same
  helper/check-kind across moved lines and selector paths where producer metadata
  supports the identity. Retain exact locations, distinguish unrelated helpers
  and require the concrete diagnosis/next hypothesis at the existing recurrence
  boundary. Missing metadata still requires agent judgment; no automatic retry
  or new arbitrary retry limit is selected.
- [ ] **Final-policy readiness and small-target feedback.** Expose compatibility
  in managed summaries/preflight and use it in the existing complete-helper
  coverage review before expensive integration. Check changed Lean interfaces
  and helpers with the smallest applicable targets before larger consumers.
  Single-check/single-solver diagnostics do not replace whole-helper success or
  complete native and source-corresponding assurance over full declared domains.
- [ ] **Demonstrated proof strategy and scheduling.** Carry forward applicable
  #370 repairs. Reduce targeted proof context through proved helper contracts;
  compare `per_check` with progressive/path splitting on a demonstrated residual
  or representative hotspot, then adopt the demonstrated useful strategy. The
  comparison may retain the existing strategy when it performs best; completing
  that experiment does not itself establish a speedup. Retain unsuccessful
  alternatives honestly. Schedule independent dirty
  certificate chunks with available workers, then the serial-heavy aggregate
  with an appropriate reservation when other useful work is ready. Preserve
  process-thread defaults and memory headroom; serialize dense work when combined
  needs exceed resources. Do not raise global steps/memory without a corresponding
  failure and focused evidence.
- [ ] **Tests and guidance.** Cover common focused/final settings, experimental
  classification, override reasons, recurrence across moved lines/selectors and
  final-policy compatibility. Align `AGENTS.md`, `development.md` and linked
  iteration guidance with actual runner behavior. Keep proof-decomposition
  judgment explicit rather than promising automatic optimality.
- [ ] **Validation and closeout.** Exercise the focused path and readiness checks
  on current delivered compiler inputs. Retain relevant runner regressions,
  required complete native and Lean/source/module/axiom assurance on final
  affected inputs, applicable cache reuse and independent review. Record matched
  input/settings/cache/concurrent-workload scope for timing claims, elapsed/CPU/RAM
  observations and measurement limits. Use bounded matched checks or necessary
  validation, not speculative broad benchmarks. Keep #373 open until every
  selected item is implemented and validated, or an explicit owner scope decision
  changes the remaining work; planning publication does not close it.

## Assurance and evidence boundaries

The [Oracle](../oracle.md), admitted language, full input domains, required native
obligations, actual-source correspondence and provenance scope remain intact.
Fresh applicable Lean coverage/module/axiom audits remain required on cache hits.
Retained successful proof objects may be reused under the existing invalidation
rules; complete assurance and current-input provenance cannot be replaced by a
focused result, hash exception, narrowed domain or suppressed check.

Record actual implementation commits, failed and successful runs, selected
settings, measurement scope and final independent disposition here and on #373.
No timings or implementation evidence are asserted by this plan. It authorizes
no application-budget change, deferred capacity research, mandatory kernel replay,
artifact-security infrastructure or extra approval ceremony. This planning-only
change needs consistency, link and whitespace checks; CLI memory was not updated.
