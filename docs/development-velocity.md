# Development velocity: implementation and retained assessment

Assessment date: 2026-10-26; reviewed target `22838bc80995ee66e9cf15fe57f14aeb161e2823`.

The initial assessment was retained for later scheduling. After the feature-review
response merged in #257, the owner [authorized the first package](session-memory.md#2026-10-26--first-development-velocity-package-authorized)
under [#246](https://github.com/berkeleynerd/silver/issues/246) and
[milestone 9](https://github.com/berkeleynerd/silver/milestone/9): A/B, bounded A2
and C1 below, as one increment. The selected package completed on Linux on
2026-10-27, with applicable assurance, independent review and a matched
unprofiled before/after workload. The detailed
assessment remains historical evidence; its performance forecasts are not
measurements. C2, predicate optimization and persistent D/I9 metrics remain
conditional follow-ups outside the selected scope.

## First package: implementation and validation

Implementation target: `80d5ec3e0e5224fe36c705f6be15e429b7fa7468`;
baseline: `e94c8b4343f429c434900cc2a23e29e870f577bf`.

The 98 expensive composition decisions now live in
[`ComposeSourceCandidate`](../proof/Silver/ComposeSourceCandidate.lean), over the
reviewed token lists. Its 37-module dependency closure contains no authoritative
source binding or certificate. The cheap `ComposeSourceChecks` adapter retains
the authoritative predicates and six public theorem statements, transporting
the conjunction once through `Output.SourceBridge.actual_complete_shape`.
`ComposeSourceBridge.CheckedSource` and `checked_source` are unchanged. This
refines the initial proposal: the expensive candidate is independent; the
authoritative adapter still depends on the certificates.

The [independent code review](reviews/review-velocity-c1-80d5ec3e0e.md) found no
actionable issue and confirmed preservation of all 98 decisions. The
[checkpoint guidance](../development.md#proof-loop-and-validation) and
[invalidation matrix](proof-iteration.md#input-changes-and-evidence-refresh)
clarify existing practice without a new gate or input-hash exception. No Ada,
pin, generator, supported runner, catalogue or sample changed.

The complete C1 checkpoint and matched comparison passed. The focused
Lean-related tests (73), platform-isolation tests (16) and Rosetta tests (3)
passed without skips. The [independent applicability review](reviews/review-velocity-evidence-reuse-80d5ec3e0e.md)
accounts for the complete current test inventory using these results and the
retained regression/repair results; no fresh full-suite pass is claimed.
The [native-input comparison](evidence/development-velocity-20261026/implementation/native-reuse.json)
matches all 2,519 original inputs of successful complete native run 121322 and
the 141 tracked inputs at the implementation target; this retains that audit,
not a new GNATprove execution. Complete Lean run
`20261026T221956-84d1b4b6e429` rebuilt exactly the selected 20-module closure,
then freshly audited all 498 modules and 104,251 declarations with only
`propext`, `Classical.choice` and `Quot.sound`. Build time was 6,891.336 seconds;
the complete managed check took 6,914.489 seconds. This is an incremental
complete-scope checkpoint, not a clean rebuild or independent replay.

The first warm complete check failed at the 16 GiB per-process threshold in
two long-header decisions (`refinement_fact_09` and `refinement_fact_11`);
it reported no other proof error. Its 54.62-minute failed result is retained.
A focused check of those exact decisions at 24 GiB passed in 8.75 minutes,
with 16.60 GiB peak child RSS. Its reduced context does not establish the complete
candidate's peak. The matched comparison runs AFTER then BEFORE at
two workers, two threads and 24 GiB per process, with sampled host headroom.
The successful AFTER checkpoint reached 16.70 GiB largest-child RSS and retained
at least 12.55 GiB sampled available host memory. Its composition candidate took
3,266 seconds, overlapping the 6,447-second certificate; the authoritative
composition adapter took 2.2 seconds. The baseline build took 9,567.554 seconds:
the new build is **27.97% shorter**, saving 2,676.218 seconds (44.60 minutes)
in this workload. Complete managed checks took 9,591.191 versus 6,914.489 seconds.
Both rebuilt the intended closures from independent copies of the same original
warm seed, without Lean profiling. This single fixed-order AFTER→BEFORE pair
is not a clean-build baseline or a general scaling result. The historical
12,500-second contended guard run is not the comparison baseline.

The expensive decision work itself is similar: baseline `ComposeSourceChecks`
took 3,261 seconds, versus 3,266 seconds in the new candidate. The saving comes
from scheduling that work independently of the certificate. Child CPU totals
were 13,218.534 seconds before and 13,604.191 after; this reduces wall time,
not total CPU work. The [implementation evidence](evidence/development-velocity-20261026/implementation/README.md)
retains resource settings, exact rebuild sets, profiles and limitations.

The isolated certificate profile attributes 74.79% of named traced elapsed time
to line certificates and 24.62% to joins. These are shares of the named trace
accounting, not exclusive CPU costs. Its instrumented run took 105.47 minutes
and the largest child reached 13.69 GiB RSS. The normal-async predicate profile
passed in 52.53 minutes with an 11.60 GiB largest child, but overlapping
checked-environment waits invalidate its per-declaration cost ranking. The
separate serialized diagnostic passed in 51.94 minutes. Its validated primary
trace assigns 3,079.541 seconds to named declarations; the three largest are
`native_flow_checked` (284.762 s), `native_workers_checked` (284.024 s) and
`native_scalarHelpers_checked` (275.157 s). These are exclusive traced elapsed
costs in that diagnostic, not recovered normal-async CPU costs. The production
async setting is unchanged. Two tiny background reporting streams initially
tripped the one-stream assertion; the corrected analysis excludes their
0.028499 ms of unnamed work and verifies primary-stream conservation and
non-overlapping kernel scopes. No additional proof run was needed.
These instrumented times are not performance baselines, and the certificate
profile does not separate string conversion from lexing inside a line proof.

The no-build invalidation controls passed: a comment-only authoritative Ada
edit leaves the candidate current while the authoritative adapter reports a
stale source binding; a reviewed-token edit makes the candidate stale. Restoring
the bytes restores both targets, with the observed proof objects and sidecars
unchanged. Lake's exit 3 reports a stale dependency frontier, not a complete
list of stale targets. The [final evidence review](reviews/review-velocity-final-80d5ec3e0e.md)
records the complete validation, matched comparison and attribution limits.

This completes the selected scope of #246 through
[PR #259](https://github.com/berkeleynerd/silver/pull/259). Certificate chunking
and predicate optimization now have better measurements for a later owner
decision, but remain unselected. Scratch instrumentation was sufficient here;
persistent runner metrics and I9 remain deferred. Roadmap batching is still an
owner scheduling choice. No successor capability or optimization starts with
this closeout.

Implementation and scratch measurement work used selected GPT-6.1 Sol at
Extra High; independent source, reuse and measurement reviews used selected
GPT-6 Astra at Extra High. Lead runtime settings and token/cost measurements
are unavailable. The retained reviews record their measured intervals; run
records carry machine time, including the failed 16 GiB attempt and successful
resource diagnostic. The reviews corrected invalid async attribution and
identified the small Rosetta test rerun; no assurance requirement was reduced.

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
records the exact scope. The [completed comprehensive feature review](reviews/review-22838bc809.md)
established coverage at its target. The owner subsequently adopted narrow,
independently reviewed reuse in development.md; #246 does not retroactively
change those failed runs into successful suites.

## Original candidate assessment

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
No proof, test, build, benchmark or project validator ran for the original
documentation-only assessment closeout. The implementation work above is separate.
