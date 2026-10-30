# Named Integer subtypes: terminal evidence review — 2026-10-30

**Draft: complete native, build and repaired-input regression evidence confirmed;
the later source-literal repair is reviewed, with final Lean and Rosetta
confirmation pending.** The initial completed-evidence check found no actionable
discrepancy. The later completion-assurance finding #290 and its reviewed repair
are recorded below. This bounded
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

## Source-literal repair review — 2026-10-30

**Finding [#290](https://github.com/berkeleynerd/silver/issues/290): independently
confirmed, severity: blocker for capability-completion assurance; bounded repair
reviewed, authoritative validation pending.** This is an actual-source
correspondence defect, not a demonstrated native/runtime defect. Complete run
`20261029T205735-bb72d0625415` reports false propositions in
`ScalarExpressionSourceChecks` (lines 23 and 73),
`PredicateBasicSourceCandidate` (22), `PredicateLoopCandidate` (21), and
`PredicateAdapterSourceCandidate` (18, 35 and 60). Those failures prevent a
successful complete checkpoint even while independent modules finish.

Reviewed repair `d4e2be67b5de7fcc2919cf9eac6efb217e5ca672`, based on
`288337f8ce7eb3aa4baebed58156138862afbc76`, directly in the isolated
`tmp/subtypes-source-literal-repair` worktree. Reviewed the actual failing log
at `tmp/named-integer-subtypes/tmp/subtypes-repaired-lean.log`, the exact diff,
relevant authoritative Ada, typed render/evaluation definitions, model equations,
source-extraction requirements, dependency graph and regression fixtures. The
worker's handoff was supporting context; this verdict follows direct inspection.
Selected reviewer remained GPT-6 Astra / Extra High; runtime confirmation and
token/cost measurements remain unavailable. Substantive inspection ran
01:27:41–01:32:31 UTC (290 seconds), followed by report preparation. No proof,
native build or regression test was run by the reviewer.

Only five proof files change, comprising seven literal-line replacements:

- `ScalarExpressionSourceShape.spec` and
  `ScalarExpressionSourceChecks.Declarations` replace the stale divisor 12 with
  7. The Ada declaration, `ScalarExpressionEnvironment.maxBindings`, and
  `ScalarEnvironmentSourceBridge.Checked.maximum` already use 7: the existing
  585-slot capacity and semantic domain do not change. The complete scalar spec
  pin now matches all 820 source tokens; its unchanged body pin matches 3,496.
- `PredicateBasicSourceCandidate` gains the six actual subtype-hiding arguments
  on the test and update calls for output, partial output and rejection. Existing
  `Test.eval/render` and `Update.eval/render` already select the same operation's
  visibility bit. The repaired candidate matches all 783 source tokens.
- `PredicateLoopCandidate` replaces the old full-range literal with the actual
  array component interval, inside the target's scope, and replaces the obsolete
  whole-environment `Append` call with the actual count increment and fresh-slot
  assignment. Existing `Update.arrayBounds` evaluation/rendering, `commands`,
  `array_tail` and `Update.inner` already model these operations. Scope entry
  copies the context; the modeled retained prefix and new last binding match
  those assignments. The repaired candidate matches all 1,165 source tokens.
- `PredicateAdapterSourceCandidate` adds the actual hidden-call projection to
  `Context_Of`, subtype environment to `Expand_Body`, and fourth subtype argument
  to the `Read_Statements` call. Existing `contextOf`, `expand`, `adapterEval`,
  typed expressions/renderers and evaluation/model equations already carry these
  fields. The three repaired candidates match 68, 67 and 95 source tokens.

Independently extracted those tokens from authoritative source with the existing
untrusted lexical helper and compared each complete candidate, selecting actual
implementations rather than forward declarations. This is a review check, not a
Lean proof. All nonliteral file content is unchanged; the only other textual
change is the `/7` declaration expectation itself. No Ada, runtime behavior,
semantic model, endpoint domain, theorem proof script, assumption, source
extractor, generator, audit or tool setting changes. The source-check conclusion
is intentionally corrected to the already admitted declaration.

The final chain still requires both typed-render equality and extraction from
the authoritative source: `PredicateSourceRequirements` and
`PredicateSourceCandidate` retain their basic/loop/adapter extraction obligations;
scalar checks retain complete source-shape, declaration and expression checks.
Thus this repair aligns stale literals with the existing semantic argument; it
does not treat refreshing a pin as a substitute for source correspondence.
No actionable defect was found in this exact patch. Focused kernel checks and
the complete source/module/axiom checkpoint must still establish its results.

### Invalidation and regression applicability

Read-only traversal of actual imports found none of the five changed modules in
the dependency closures of `OutputBodyCertificate`, `ComposeSourceCandidate` or
`PredicateScalarBodyCandidate`. Their source/generator/model inputs are unchanged;
their successful objects remain applicable under ordinary Lake dependency checks.
The ongoing independent scalar-body build need not be interrupted for this repair.
The three Predicate candidates feed `PredicateSourceRequirements` and then
`PredicateSourceCandidate`; the scalar files feed `ScalarExpressionSourceBridge`.
`PredicateSourceBridge` consumes both routes. Those affected source checks and the
fresh complete module/axiom audit remain required; a focused pass is insufficient.

For exactly these five changed proof literals, refresh the **12
`test_lean_source.py` identities and 16 `test_platforms.py` identities**. The
first family scans actual proof sources/imports; every platform fixture copies
the current complete Lean tree. Their 28 identities match the established
inventory. Other Lean tests consume unchanged audit, binding, Lake/toolchain
inputs or synthetic fixtures. Native/output-integrity/sample fixtures do not
consume these proof literals. Consequently the verified native checkpoint,
compiler build, 509 applicable original test results and 18 repaired native
fixture results remain applicable. The 28 proof-tree results require replacement
again; original outcomes stay intact. Later Rosetta metadata changes require
their own affected-test results and final identity reconciliation.

## Outstanding terminal confirmation

Run `20261029T205735-bb72d0625415` has known source-literal failures and must
retain its actual terminal outcome. No complete-Lean success is inferred from
its successful independent modules or the completed native result. After the
reviewed repair, final confirmation must inspect the repaired whole-project
source/module/axiom outcome, exact captured-input binding, 28 refreshed proof-tree
results, final Rosetta metadata delta and affected renderer-test outcomes, then
reconcile all 555 identities. The reviewer is paused pending those records;
no proof/test polling or rerun is needed for this evidence review.
