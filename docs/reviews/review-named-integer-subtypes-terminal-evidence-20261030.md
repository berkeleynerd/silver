# Named Integer subtypes: terminal evidence review — 2026-10-30

**Draft: complete native, build and repaired-input regression evidence confirmed;
final Lean and Rosetta evidence confirmation remains pending.** No actionable
discrepancy was found in the completed evidence inspected here. This bounded
review concerns owner-authorized #286 and draft PR #289; it neither authorizes
merging nor substitutes for the prior scoped code reviews or external approval.

## Review inputs and method

Implementation target: `6020416906b5fc3d2bd10d012e70937c80f0617c`.
Initial evidence snapshot: `09100f7b92`, in isolated worktree
`tmp/subtypes-terminal-evidence-review`, branch
`review/subtypes-terminal-evidence-20261030`. The 60 changed files between those
snapshots are all under `docs/`. Also inspected the three-file documentation-only
status update `288337f8ce7eb3aa4baebed58156138862afbc76`; it records the completed
native result while retaining the pending complete-Lean boundary.

Selected reviewer: GPT-6 Astra / Extra High, explicitly selected by the parent
through the spawn controls. Runtime model/effort confirmation and token/cost
measurements are unavailable. Initial evidence inspection ran
00:35:10–00:38:56 UTC (226 seconds), followed by report preparation. No proof,
build or regression test was rerun. The live harness returned no active goal.
Only this report is owned by the reviewer; there were no GitHub writes.

Read the applicable Oracle, development validation/reuse/reporting requirements,
and the existing [integration review](review-named-integer-subtypes-final-integration-97312a790f.md)
and [Body_Tail repair review](review-named-integer-subtypes-body-tail-equality-20261029.md).
Their source, erasure and applicability arguments remain the scoped code-review
basis. This review checks retained outcomes and input correspondence, without
repeating those arguments or treating examples as universal assurance.

## Complete native checkpoint

Independently inspected the [native packet](../evidence/named-integer-subtypes-20261029/native-full/README.md),
including raw managed events/log, provenance and input manifests, complete report
archive, actual input snapshot, inventories and summary. Run
`20261029T211041-a76eb6753f23` has native-tool return code 0, a completed audit
phase and a successful terminal event at 2026-10-30 00:32:43 UTC, after
12,119.996 seconds. The raw log independently records all checks proved and the
complete coverage/provenance totals. The command retains forced full analysis,
level 2, the CVC5/Z3/Alt-Ergo portfolio, 30-second timeout, strict warnings/checks
settings and four workers. Existing sessions and cache were present; this is
complete audited native evidence, not a cold run.

Recomputed and checked:

- All nine packet artifact digests; all 80 unique archive members, comprising
  76 `.spark` reports, two aggregate reports and two manifests; all 78 report
  digests against the complete provenance manifest.
- The exact 2,561-entry prepared-input map against the provenance manifest and
  archived input manifest; all 149 archived tracked/generated input payload
  hashes; all 143 tracked input hashes against Git blobs at the implementation
  target. The retained repaired source is thereby bound to the reviewed target.
- All report entry counts and unit-inventory counts: **15,393 proof plus 1,432
  flow entries = 16,825 proved checks**, over 76 units and 1,075 audited entities.
  The entity total counts each report's `spark` entries, excluding its additional
  referenced-entity descriptions. Every proof/flow entry has severity `info`;
  no such entry is suppressed, and every report's assume/skip fields are empty.
- The full warning inventory against actual report messages: **6,598 entries**,
  comprising 6,546 warnings and 52 informational entries. The audit separately
  reports 305 limitation notes, 18 imported entities, 6,236 trusted-mathematics
  notes, 62 vendor-specification entities and five array-initialization
  advisories. These category counts are not a claim that no warnings occurred.

The packet's retention-verification record describes a separate retention check,
not an independent reviewer or a proof rerun. Its claims agree with the direct
checks above. Complete native success is established; final Lean source
correspondence remains a separate required result.

## Build and regression evidence

Inspected every original compressed log and event stream in the
[repair-regression packet](../evidence/named-integer-subtypes-20261029/repair-regression/README.md),
verified its decompressed digest against the retention record, and checked the
actual successful terminal event and native-tool/test return code 0:

| Run | Scope | Confirmed outcome | Managed seconds |
| --- | --- | --- | ---: |
| `20261029T210150-1086727daf3c` | Compiler build | Passed | 13.114 |
| `20261029T210251-939fbc67799b` | Lean-source tests | 12 passed | 74.458 |
| `20261029T210409-2c895b357da6` | Platform fixtures | 16 passed | 260.701 |
| `20261029T210832-732f9cd37a16` | Output-integrity fixtures | 17 passed | 44.925 |
| `20261029T210920-b4b0cd40fe3c` | Silver tool/source-failure fixture | 1 passed | 17.220 |

Recomputed input comparisons from prepared events and actual Git blobs rather
than trusting summary booleans. All 143 tracked build inputs and all 792 tracked
inputs in each test run match the implementation target. The eight remaining
workspace/generated/tool hashes are identical across the four test runs.
Parsed explicit successful outcomes for every identity, including interleaved
tool output in the platform log, and matched them to each retained selection.

The four replacement sets contain exactly the 46 identities required by the
Body_Tail repair review. They are disjoint from the 509 retained identities;
together they equal the complete 555-identity inventory, with no missing or
failed identity. This confirms the current reconciliation. The original
full-suite log, its nine imported duplicate executions (546 distinct methods),
52 sample sources and 108 application executions were already independently
confirmed by the integration review. Those applicable results remain retained
evidence, not fresh execution here. The 16 platform fixtures establish mocked
host/tool routing on Linux, not native macOS or complete Lean proof validity.

## Preserved unsuccessful outcomes

The [failed full native packet](../evidence/named-integer-subtypes-20261029/native-full-reuse/failed-full/README.md)
still records run `20261029T165015-c6b111fb4f2a` as `failure`, return code 1,
after 13,129.891 seconds, without an audit phase. All ten retained artifact
digests match. Reading the actual reports finds exactly one non-informational
proof entry: the `Body_Tail` postcondition reported at `3414:20` (its enclosing
check location is `3412:28`). It remains failed historical evidence.

For old complete Lean run `20261029T161817-0a8089cd7dc3`, all three decompressed
log/event digests match the retention record. Its actual terminal event remains
`interrupted` at 20:40:43 UTC on October 29, after 15,742.412 seconds. That
run supplies neither a completed final source check nor a fresh complete audit.

## Outstanding terminal confirmation

Complete Lean run `20261029T205735-bb72d0625415` and final Rosetta metadata/test
records have not yet been supplied as terminal evidence. No complete-Lean
success is inferred from its completed output certificate, active source
candidate, retained model proofs or the completed native result. Final
confirmation must inspect the whole-project source/module/axiom outcome, exact
captured-input binding, final metadata delta and affected renderer-test outcomes,
then reconcile any replacements against the same final test inventory. The
reviewer is paused pending those records; no proof/test polling or rerun is
needed for this evidence review.
