# PR #412 external review response — 2026-11-22

The owner accepted the proposed response and authorized a focused proof review
alongside the existing findings' repairs. The original
[Claude report](review-pr412-claude-20261122.md) is preserved verbatim. It reviewed
`5a4b0ad8ac` and found no blocker, one medium, three low and six informational
items. The original report approximates its finish at 02:05 UTC; captured
launch/exit metadata instead records **01:09:13–01:59:56 UTC, 50m42.8s**.
The [response packet](../evidence/named-array-parameters-410-20261121/review-response/README.md)
retains that metadata and the repair evidence.

## Dispositions

| Finding | Response |
| --- | --- |
| C412-M1 | Repaired under existing #413: add function/procedure counted nests and a formal-array Range nest to the source-limit full-route test. All six families use exactly 4,096 bytes plus 4,097-byte rejection siblings. Linux explicitly uses 16 MiB and restores the previous limit. The stack record retains reviewer minima and qualifies old ARM64 evidence. Fresh full-route run `20261122T104947-be031f0bee17` passed. |
| C412-L1 | Remove Horner's unused `integer_array_bound_query` tag, retaining `integer_array_range`. No sample source or expected behavior changes. Independent review checks applicability to the manifest readers. |
| C412-L2 | Replace the capacity account's stale draft/pending introduction with links to completed delivery evidence and the separate ongoing external follow-up. Dated historical checkpoints remain history. |
| C412-L3 | Update the PR description to name CPU allocation/affinity changes, all-platform serial application proofs/builds, and the three-hour maximal-expression test deadline. This is a harness deadline; production prover steps, timeout, memory, portfolio and required discharge remain unchanged. |
| C412-I1 | Retain serial application proving/building for this response. It is a conservative policy expansion beyond an eight-CPU ceiling. Bounded allocation-aware application workers are a separate follow-up, not selected here. No matched old `-j0` timing establishes a slowdown ratio; the former 300-second deadline is not a measured baseline. |
| C412-I2 | Retain the tracked all-host `CPU_LIMIT = 8` for this response. It is conservative on other hosts. Host scope can be addressed with the separately selected application-worker follow-up, without adding a scheduling framework. |
| C412-I3 | Resolve the stack-test part through M1's explicit limit and restoration. Keep actual setting evidence with that test; no general runner schema is added. |
| C412-I4 | Optional additional full-route forms remain test improvements, not demonstrated semantic failures. The new formal-array Range fixture adds one relevant composition; the other listed forms remain optional. |
| C412-I5 | Defer affinity restoration for threads born during a run until a long-lived multiple-run launcher needs it. Current launchers exit after one run. |
| C412-I6 | Repaired the maximal-expression test's timeout path: use an isolated session, terminate its compiler and solver groups, and reap the compiler before re-raising `TimeoutExpired`. Independent repair review caught that Why3 gives solvers separate process groups; the first group-only repair did not cover them. Revised controls passed in `20261122T105339-12d0cd057611`; the independently reviewed repair is integrated as `3258c573a7`. The affected maximal-expression full route passed in `20261122T105525-650db3ffe211` (73m42s). |

## Proof-review scope

The original review did useful independent source work, especially on #414, but
explicitly sampled proof roots, statements and trees. It did not examine every
new full-domain argument, freshly audit extended primitive-interpretation fields
or rederive report-capacity arithmetic. The follow-up is selected as **Claude
Fable 5.2 / Max**, with the runtime model confirmed as `claude-fable-5-2` and
effort confirmed only as the explicit CLI selection. Server-side effort is not
independently exposed.

The [focused report](review-pr412-claude-proof-20261122.md) completed at
11:48:20 UTC, after 61m25.9s from its 10:46:54 start, on fixed source
`5a4b0ad8ac`. It found **no blocker, medium or low finding and five info items**.
It examined full-domain array views/frames/calls; native preconditions and
primitive assumptions; actual-source imports on Main and callable-local paths;
preservation through safety **and automatic discharge**; and feature-local
report capacity. All 62 resource snapshots respected its two-CPU allocation,
guest CPUs 0–1.

The lead accepts this as substantive independent scrutiny of the selected hard
arguments. It is not an exhaustive review of all 347 changed Lean files: 45 were
read in full, 68 as complete diffs, 13 partly, 30 at changed-statement level,
and 175 at changed-definition-header level only. Changed theorem hypotheses in
the latter group could have escaped inspection; eight generated shape tables
and eight certificates were not opened. The
[coverage map](../evidence/named-array-parameters-410-20261121/review-response/focused-proof/coverage-map.tsv)
preserves the per-file scope. No new Lean, kernel, GNATprove, build or test
execution was performed by the reviewer. The complete retained audits keep
their original scope; this review does not replace them.

### Focused proof dispositions

| Item | Lead disposition |
| --- | --- |
| I1 — Value transport and disjointness side lemmas | Clarify their scope in the assurance record. Endpoint safety uses full declared component ranges through `capture_of_checked_ranges` and `bindArrayArguments_fits`; the additional model-consistency lemmas are audited but not endpoint premises. Keep the useful lemmas. |
| I2 — Predicate equivalences and `validNameState` | Name the unchanged lexical function and its full-domain interpretation law in the trusted boundary. Its three-line Ada expression agrees with the law; all array-predicate equivalences except `validType` remain side facts. No new proof repair is demonstrated. |
| I3 — Inherited leaf imports and redundant assumptions | Retain the documented lexical interpretation premises. The #414 array imports and Boolean-wrapper meanings are derived on the traced Main and callable paths. Redundant inherited fields do not justify a separate proof refactor. |
| I4 — Two producer routes unavailable to the reviewer | Resolved by a source-level Astra Max follow-up at pinned SPARK revision `42554fc241fcd1fdf08d3a2feccb3f86912acbc0`. Immutable input pairs and distinct array/scalar roots return `Impossible` before alias-record emission. Ordinary nonlimited array equality and absence of a private view rule out the extra type-theory/status routes. The [capacity account](../named-array-parameters-report-capacity.md) retains the sources/hashes and unchanged envelope. Do not rely on the review's hypothetical 999,424-byte fallback: its per-site multiplicity and record-size assumptions were not established. |
| I5 — Unreferenced new theorems | Retain the audited lemmas. An unused theorem is not a defect or a reason to rebuild the proof graph. |

No production/proof repair or full proof rerun follows from these five items.
The original report remains verbatim, including its stated limitations; the
source-based I4 conclusion above is our subsequent assessment.

### Managed-wrapper outcome

The reviewer subprocess exited successfully, but managed run
`20261122T104651-c6826d4fd799` **failed** its final input-integrity check.
The monitor, with lead approval, added observed model/session fields to declared
input `request.json` while the run was active. This was a monitoring error.
Reconstructing the original fields reproduces the captured input hash;
the prompt and launcher hashes match, and the fixed source checkout is clean.
The [reconciliation](../evidence/named-array-parameters-410-20261121/review-response/focused-proof/reconciliation.json)
records those checks and the original failed event. The review result stands
with this qualification; do not relabel the managed run or repeat the review.
Future runtime observations belong in a separate output file, leaving declared
inputs unchanged.

## Validation boundary

These repairs change tests, one sample capability tag and records. They do not
change Ada, Lean, catalogue, runner scripts or sample programs. The complete
native and Lean checkpoints remain eligible for reuse after exact input checks;
their successful outcomes are not evidence for the changed test bodies.
The affected test identities need fresh results, and an independent applicability
review must account for the final discovery inventory and retained results.

The maximal-expression run previously took roughly 72–116 minutes under serial
application proving. Its rerun is necessary because this repair changes its
launcher. Preserve prior successful evidence and any new failure as recorded;
do not repeat the complete native/Lean runs merely for these test/record edits.
PR #412 remains open. No merge or next capability is authorized.

The [independent repair review](review-pr412-repair-applicability-20261122.md)
found 787 discovery identities: 783 retained
results (756 original full-suite, 15 proof-reader and 12 Rosetta), two changed
existing identities and two new controls. Horner's single tag deletion changes
none of the manifest test's source, expected-output or audit-policy decisions;
the other direct manifest reader uses three unrelated sample outputs.
The two corrected timeout controls and expanded stack regression passed. The
focused Claude verdict is assessed above. The final maximal route passed at
12:09:08 UTC in `20261122T105525-650db3ffe211`, completing **783 retained + four
fresh = 787** covered identities. The
[final packet](../evidence/named-array-parameters-410-20261121/review-response/maximal/README.md)
retains the actual success and resource/cleanup observations. No required repair
or validation remains outstanding; PR #412 is technically ready for merge.
Merge itself still requires the owner's instruction.
