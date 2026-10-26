# Development velocity: retained assessment and scheduling

Assessment date: 2026-10-26; reviewed target `22838bc80995ee66e9cf15fe57f14aeb161e2823`.

The initial assessment was retained for later scheduling. After the feature-review
response merged in #257, the owner [authorized the first package](session-memory.md#2026-10-26--first-development-velocity-package-authorized)
under [#246](https://github.com/berkeleynerd/silver/issues/246) and
[milestone 9](https://github.com/berkeleynerd/silver/milestone/9): A/B, bounded A2
and C1 below, as one increment. Complete applicable assurance and independent
review, and measure a matched unprofiled before/after workload. The detailed
assessment remains historical evidence; its performance forecasts are not
measurements. C2, predicate optimization and persistent D/I9 metrics remain
conditional follow-ups outside the selected scope.

## Assessment and evidence

The owner supplied the complete [external report](https://claude.ai/artifact/9pnpQUNy9impAaSxpnRAFb)
in conversation after its content endpoint proved inaccessible. The findings
below and repository evidence stand independently of that private reference.
[Supplementary inputs](evidence/development-velocity-20261026/assessment-inputs.json)
retain selected event fields and hashes; the [module timeline](evidence/development-velocity-20261026/module-timeline.txt)
is an owner-supplied Appendix B transcription, not independently verified original
telemetry. Detailed total-run accounting and every experiment were not re-audited.

Primary repository evidence is the completed
[timing packet](evidence/scalar-guard-refinement/proof-timing-20261026/README.md),
[delivery validation](evidence/scalar-guard-refinement/delivery-20261026/validation.json)
and [preserved source completion](evidence/scalar-guard-refinement/delivery-20261026/preserved-source/completion.json).
The source build was incremental, not clean/replay. It predates final auditor-only
changes; the final matching-input cached checkpoint is separate.

| Successful Lean module | Division | Guards |
| --- | ---: | ---: |
| OutputBodyCertificate | 3,910 s | 9,037 s |
| PredicateSourceCandidate | 908 s | 5,082 s |
| ComposeSourceChecks | 3,454 s | 3,408 s |

The guard build completed in 12,500.122 s. OutputBodyCertificate followed by
ComposeSourceChecks accounts for 12,445 reported seconds on its dominant path;
the predicate candidate is on another dependency branch. This establishes a
dependency bottleneck, not continuous one-core utilization. The ledger lacks
CPU/RAM samples and explicit memory limits for these complete runs.

An initial assessment omitted native run `20261025T221851-c7c38b2dd915` and
incorrectly denied overlap with the division certificate. That conclusion is
retracted: this four-worker native run covers the entire possible certificate
interval. Both the October 17 and October 25 timed certificates overlapped
multiworker native work. The evidence does not quantify contention's effect.

The additional October 17 focused baseline built its certificate in 1,927 s,
versus division's 3,910 s. Inputs are similar-sized, not identical: Ada bodies
98,059 versus 98,810 bytes; certificates 7,694,026 versus 7,757,780 bytes. The
identified pipeline and tools match, but scope, provenance/cache states and
concurrency differ. Neither this comparison nor the observed 2.31× division-to-
guard certificate time ratio establishes a controlled scaling law.

Division's 57.948 s cached complete Lean check rebuilt consumers while reusing
successful expensive modules from a failed run. Guards' 35.005 s warm check
built no modules and freshly audited the project. These have different artifact
states and are not comparable rebuild benchmarks. Cached native checks invoked
GNATprove with native sessions/cache and freshly audited the resulting reports.
Native run 084316 proved all 16,357 checks; its managed failure was the advisory
audit, a distinct outcome from failed native obligation discharge.

Run 074542 is a superseded, interrupted complete-checkpoint certificate, not
established launch-time noncompliance. Its captured bytes match the contemporary
commit describing them as final; later edits establish rework, not known pending
edits at launch or a proven manual-copy cause. Its candidate logged five
diagnostics across three goals, separately from the certificate interruption.
The additional 3,433 s focused failure retained useful work. Distinguish diagnosis,
retained modules, discarded computation and delay. The complete 094105 log is retained.

Regression run 110119 remains failed: 511 tests, one malformed-message Image
error. Successful unaffected cases were reused following an independent
applicability review; focused Image and evidence repairs passed separately.
This is not a green aggregate or a fresh complete-suite pass. The
[#245 repair/reuse review](reviews/review-scalar-guard-array-initialization-advisory-20261026.md#follow-up-245-malformed-message-guard-and-evidence-reuse)
records the exact scope. The comprehensive feature review must assess any
uncovered interaction or invalidation; #246 does not decide delivery acceptance.

## Recommended sequence when selected

**A — Classify retained evidence first.** Inventory additional baselines,
interrupted runs and snapshots with exact inputs and provenance. Separate native
proof/audit outcomes, failed obligations, reusable objects, rebuilds and fresh
audits. Build an invalidation matrix covering Ada code/annotations, Lean,
generators/configuration, auditors, tests and documentation. This requires no
new proof or benchmark and grants no input-hash exclusions.

**A2 — Schedule isolated profiling.** Locate current costs in
OutputBodyCertificate and PredicateSourceCandidate before choosing micro-probes.
Retain elapsed/CPU time, per-process peak memory, module boundaries, exact
inputs/settings/cache state and concurrent workload. Preserve production caches.
If comparing with unprofiled division to investigate causation, include a matched
unprofiled guard control: profiled guard versus unprofiled division confounds
instrumentation. Even matched measurements cannot reconstruct historical
contention conclusively. The proposed 2.5–3.5 hours is a budget estimate.

**B — Clarify stable checkpoints within current policy.** Prefer a committed
immutable snapshot and verify captured bytes; equivalent exact-byte snapshots
remain valid evidence. Finish planned source changes and resolve known
source-changing failures before expensive correspondence work. Specify focused
diagnostic review, certificate parity, handwritten pins and full-suite placement.
Focused passes are valid scoped evidence; complete supported-delivery assurance
remains required. Preserve caches, explain justified native/Lean overlap and
coordinate resources rather than imposing mandatory serial staging.
The current reason rule concerns expensive repeats with identical successful
inputs/settings. Run 094105 followed changed inputs and failures. Requiring a
reason for every cached complete check would be a separate proposed change.

**C1 — First structural candidate, subject to validation.** Split expensive
composition checks over reviewed tokens from an actual-source adapter using
`actual_complete_shape`, following [PredicateSourceChecks](../proof/Silver/PredicateSourceChecks.lean).
[ComposeSourceChecks](../proof/Silver/ComposeSourceChecks.lean) has six proposition
abbreviations, five source-dependent, plus a token-list abbreviation, and 98
decision calls. Parameterizing public abbreviations or retargeting `actual_*`
statements changes their API: retain authoritative wrappers or identify those
intermediate changes explicitly before promising identical exported statements.
`CheckedSource` and `checked_source` already reside in [ComposeSourceBridge](../proof/Silver/ComposeSourceBridge.lean).
The reviewed import graph suggests no cycle. Preserve final authoritative
claims, actual-byte reconstruction, tokens, semantics, call-domain legality,
native verification, invalidation, coverage and private/transitive axiom audits.

C1's roughly 9,500 s path and 24% saving are unmeasured forecasts. The certificate
would expose about 422 s of downstream bridge work; candidate completion, a
cheap adapter and unchanged contention are assumptions. Two-worker packing
(`3408 + 448 + 5082 = 8938` beside `9037`) has only 99 s nominal slack and assumes
dependency readiness and favorable scheduling. It demonstrates neither that
schedule nor memory safety. Profile actual process peaks and host headroom;
Lean's periodically checked per-process threshold is not an aggregate cap.

**C2/D — Conditional follow-ups.** Consider certificate chunking only if A2
shows a useful independently checkable partition after reconstruction/join costs
and competing bottlenecks. Prefer scratch metrics; add runner telemetry only
for a demonstrated recurring capture gap. Preserve managed workspace ownership
and worker reservations. Drop the specific asynchronous leaf-proof proposal:
pinned `decide +kernel` and `kernel_exact` disable asynchronous auxiliary-lemma
elaboration. This does not rule out all theorem restructuring. The proposed
serial independent-first staging's roughly 40% penalty is conditional arithmetic.

## Re-entry and unchanged constraints

After feature-review responses merge and the owner selects velocity work:

1. Pin the new head and compare affected proof, native and tooling changes with
   this exact review target; reuse only evidence whose assumptions still apply.
2. Resolve relevant review findings, including regression applicability and any
   newly identified interaction, before claiming a complete delivery result.
3. Select the smallest justified package and measurement question, with explicit
   resources, host headroom, inputs and acceptance evidence.
4. Only then create the selected scoped issues and milestone/order, recording
   authorization and status under [planning](planning.md). No A–D work is started
   or scheduled by this document.

The Oracle still requires complete automatic obligation discharge for the
current language and all admitted compositions, with exact source correspondence.
Preserve hash scope and complete native/Lean auditing; identical statements alone
do not establish unchanged assurance. Related experiments may already share a
coherent checkpoint under development.md. Keep incomplete experiments on branches
by default. No new replay gate, assurance deferral, routine approval ceremony,
solver/tool pin or feature is selected. Observed 35–80 s refreshes concern these
auditor-only edits, not all scripts. Adoption needs the applicable complete source
build and fresh audits; performance claims need measured results.

| Round | Selected model/effort | Result and measurement limits |
| --- | --- | --- |
| Retained evidence extraction | GPT-6.1 Sol, Extra High | Corrected omitted native overlap and evidence scopes. |
| Critical source/assurance review | GPT-6 Astra, Extra High | Qualified C1 API, schedule, memory and profiling claims. |
| Documentation closeout | GPT-6.1 Sol, High; lead setting not independently exposed | Retained recommendations and re-entry conditions. Lead checked the record and extracted supplemental evidence; the documentation author reviewed the lead's sequencing edits and found no material inconsistency. No proof execution. |

Runtime confirmation, whole-round elapsed time and token/cost measurements are unavailable.
No proof, test, build, benchmark or project validator ran for this documentation closeout.
