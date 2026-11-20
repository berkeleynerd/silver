# Proof iteration efficiency

## Current selected package — 2026-11-20

The owner approved the reduced [#373](https://github.com/berkeleynerd/silver/issues/373)
package: **“Approved. Proceed to completion and the accompanying PR.”**
The [dated authorization](session-memory.md#2026-11-20--reduced-proof-iteration-package-approved-for-delivery)
is on main at `a412827d6c`. It replaces the original requirement to complete all
eight increments before delivery. One delivery retains guidance in #383 and one
shared final validation and review checkpoint in #384, in
[milestone 24](https://github.com/berkeleynerd/silver/milestone/24).
Implementation, applicable validation, independent review and a PR are authorized;
merging the new PR is not. PR #385 remains held. Work proceeds directly through
Codex: the owner's [stop-Worca instruction](session-memory.md#2026-11-20--stop-using-worca)
ends the former workflow requirements without changing existing authorizations.

| Issue | Selected scope and remaining work |
| --- | --- |
| [#377](https://github.com/berkeleynerd/silver/issues/377) | Reconcile recovered allocation reporting; require `--resource-reason` for deliberate reductions on native `prove`, direct `tool gnatprove` and Lean proof commands. Preserve requested/automatic/actual reporting for build, test and arbitrary tools without a reason gate. |
| [#378](https://github.com/berkeleynerd/silver/issues/378) | Reconcile recovered native helper/check-kind recurrence, retain exact locations and repair the compiler fallback selector/no-selector family mismatch. Document metadata, reset and conservative family-hold limits. |
| [#379](https://github.com/berkeleynerd/silver/issues/379) | Add canonical whole-helper focused compiler checks using the complete audit's existing solver/budget definition; keep the 30-second policy and separate exploration state. |
| [#380](https://github.com/berkeleynerd/silver/issues/380) | Report minimal final-policy compatibility in existing managed summaries/preflight for the human complete-helper coverage review. Classify experiments honestly; no automatic proof dependency or success-coverage graph. |
| [#383](https://github.com/berkeleynerd/silver/issues/383) | Align `AGENTS.md`, `development.md` and iteration guidance with the delivered interfaces and limits in this same package. |
| [#384](https://github.com/berkeleynerd/silver/issues/384) | Exercise the focused path, affected regressions and applicable complete native/Lean/source/module/axiom assurance on final inputs; retain evidence reuse, settings, measurement limits and independent disposition in one shared checkpoint. |

Selected work is In progress. No implementation or final assurance completion is
asserted by this scope update. Live status and worktree ownership belong on the
issues and [Silver board](https://github.com/users/berkeleynerd/projects/6); board
read/write access was available during this update. The original increments and
recovered branches remain preserved, with no issue closed by this planning step.

## Recovery and evidence basis

The previously unavailable commits are now recovered:
`5e91e71be572bbd1d8c9e793ab5c580c59e11568` (#377) and
`f4b7a9e75c3d278a926111e7e92c6da92e2bdc2f` (#378). Their changes overlap in
`run_history.py` and runner tests, so reconcile them serially. Historical focused
successes and reviews are useful evidence to inspect, not final current-input
validation. The recovered #378 implementation has a confirmed compiler fallback
family gap when selectors disappear; this package includes its narrow repair.

The reassessment used the existing delivery packets rather than new benchmarks.
The [#370 native repair](evidence/scalar-procedures-20261115/native-recovery/README.md)
established a whole-helper success and complete delivery at the unchanged
30-second policy after proof-context repair. Earlier apparent success had reused
an experimental solver result; command settings alone did not establish cache
origin. The [#392 native checkpoint](evidence/named-scalar-arguments-392-20261117/complete-native/README.md)
also passed at 30 seconds. These support clear focused/final classification,
not a global solver-budget increase.

The [#370 delivery](scalar-procedures.md#delivery-assurance-and-validation)
already includes source representation/context improvements; the
[#392 Lean record](evidence/named-scalar-arguments-392-20261117/complete-lean/README.md)
retains a measured memory-driven process-thread reduction and successful cached
continuation. Lake already schedules independent dirty modules, the runner already
coordinates reservations, and [existing concurrency measurements](lean-concurrency.md)
show that process threads do not promise proportional aggregate throughput.
Preserve these delivered improvements without claiming the deferred experiments
below were performed. Different source, host, cache and concurrent-workload
settings do not support a controlled speedup comparison.

## Deferred increments and concrete triggers

- [#381](https://github.com/berkeleynerd/silver/issues/381) remains open in
  Backlog. Reconsider a bounded `per_check`/progressive/path comparison when a
  current unresolved whole-helper proof or measured representative hotspot
  survives the existing focused/context-repair approach. Preserve the residual,
  settings and reports before proposing that work. No standalone strategy
  experiment is required for this delivery.
- [#382](https://github.com/berkeleynerd/silver/issues/382) remains open in
  Backlog. Reconsider additional chunk/aggregate scheduling only when a necessary
  proof run demonstrates a material underutilized interval with independent
  ready work and sufficient memory headroom. Preserve matched timing, workload
  and reservation evidence before proposing automation. Existing Lake scheduling
  and managed resource controls remain available.

These are explicit owner-approved deferrals, not completed implementations.
Reactivation needs the owner's selection of the concrete demonstrated work under
[normal planning rules](planning.md); no new approval procedure is introduced.
Remove these deferred increments from the blocking dependency path for #383/#384.

## Shared completion checklist

- [ ] Reconcile #377/#378, repair the selected gap and pass affected regressions.
- [ ] Implement and exercise #379/#380 on current delivered compiler inputs.
- [ ] Align guidance in #383 with the tested command interfaces and limits.
- [ ] Retain applicable complete final-input native and Lean/source/module/axiom
  assurance, regression coverage and independent review through #384.
- [ ] Record actual settings, retained/fresh/cached evidence, failed attempts,
  measurement limits and final review disposition before closing selected issues.

The [Oracle](../oracle.md), admitted language, full declared domains, native
obligations, actual-source correspondence, provenance scope and fresh required
Lean audits remain unchanged. Resource-only changes preserve applicable caches;
runner edits refresh affected evidence according to the existing
[invalidation matrix](proof-iteration.md#input-changes-and-evidence-refresh).
Focused success does not replace complete assurance. No cold rebuild, mandatory
kernel replay, application-budget change, generic scheduler or telemetry service
is added. Neither elapsed compiler time nor historical sunk cost establishes a
new optimization's value.

## Delivery evidence and rounds

The selected code is integrated at `f0a773fbcb` in the delivery worktree; draft
[PR #406](https://github.com/berkeleynerd/silver/pull/406) is open. This includes
proof-only resource reasons, native recurrence/fallback normalization and query
isolation, canonical focused checks with shared unit coverage auditing, and
rejection of contextual inlining as whole-helper evidence. Final current-input
validation and closing review remain outstanding at this guidance checkpoint.
This update records no new proof timings, speedup, or runtime model confirmation. Preserve useful caches and productive jobs; CLI memory was not
updated by this documentation subthread.

The owner-authorization commit was recorded at **2026-11-20 15:06:13 UTC**
(`a412827d6c` author/committer timestamps). The table records launch selections
reported by the lead, not independently verified runtime model/effort settings.
Token usage, billed cost and whole-team model cost are unavailable; elapsed tool
time is not a substitute for those data.

| Round/work | Selected model and effort | Outcome/evidence boundary |
| --- | --- | --- |
| Recovered-patch cost assessment | GPT-6.1 Sol, Extra High | Recommended preserving compact reporting/recurrence changes, repairing the family gap and reducing routine reason gates; read-only assessment, no proof or benchmark. |
| Proof-payoff reassessment | GPT-6 Astra, Max (version not independently confirmed) | Recommended canonical focused checks/minimal readiness and deferring standalone strategy/scheduling experiments; existing delivery evidence only. |
| Runner recovery, #377/#378 | GPT-6.1 Sol, Extra High | Recovered/reconciled changes integrated as `6a8ff7f41c` / `c6f3e997f1`; 124 recovery-commit fixture tests passed. Native Python execution on Linux x86-64 with mocked proof/tool/platform routes; no compiler/Lean assurance claimed. |
| Focused policy/readiness, #379/#380 | GPT-6.2 Astra, Extra High | Entry point, classification and coverage repairs integrated through `f0a773fbcb`; 119 affected runner/auditor tests passed on the coverage-repair candidate. Retained producer-report checks are historical evidence; final integrated checkpoint remains separate. |
| Planning/guidance, #383 | GPT-6.1 Sol, High | Scope/roadmap/Worca guidance integrated as `b1f55e5126`; issue bodies, statuses and dependency edges updated and reread on the live board. Tested interface guidance aligned with `f0a773fbcb`; local links/whitespace checked. CLI memory not updated. |
| Lead integration and checkpoint, #384 | Model/effort unavailable from live runtime | Current-input validation and independent review remain pending; repository defaults are not reported as observed live settings. |

## Historical plan and handoff — superseded on 2026-11-20

The text below preserves the original 2026-11-10 selection and 2026-11-17 recovery
handoff as history. Its all-eight completion requirement, unavailable-artifact
status and Worca workflow descriptions no longer govern current work. The reduced
selection and recovered status above take precedence.

### Authorization and order

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

### Current handoff — 2026-11-17

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

### Problem and decisions to settle

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

### Required implementation and completion checklist

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

### Assurance and evidence boundaries

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
