# Named Integer subtypes: terminal evidence review — 2026-10-30

**Terminal evidence confirmed: complete native proof/audit, compiler build,
complete Lean source/module/axiom audit and all 555 regression identities are
covered on their applicable final inputs. No actionable finding remains from
this bounded review.** Completion-assurance finding #290 is independently
confirmed, repaired and validated; its failed original run remains history.
Final governed implementation is `d4e2be67b5de7fcc2919cf9eac6efb217e5ca672`,
with delivery metadata `1d6d1b4ffde8b0cdc24212b6c6dd3842880a7cc2` and final
Rosetta evidence integrated as `31c9e6d915`. This bounded
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

**Historical 01:32 UTC review boundary: finding
[#290](https://github.com/berkeleynerd/silver/issues/290) independently confirmed,
severity: blocker for capability-completion assurance; bounded repair reviewed,
authoritative validation then pending.** The completed validation below closes
that obligation. This is an actual-source
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

## Repaired complete Lean and regression confirmation

**The reviewed #290 repair has passed complete source/module/axiom validation.**
Inspected the final Lean packet committed as `d5320f8d85`, the literal-repair
regression and failed-run records at `32bdf6b4a9`, and the delivery metadata delta
`1d6d1b4ffd`, against governed implementation
`d4e2be67b5de7fcc2919cf9eac6efb217e5ca672`. Selected reviewer remained GPT-6 Astra /
Extra High; runtime confirmation and token/cost measurements remain unavailable.
This substantive terminal inspection ran 03:12:42–03:16:07 UTC (205 seconds),
followed by metadata review and report preparation. No proofs or tests were rerun.

Independently verified every retained uncompressed log/event/evidence digest for
the focused and complete repaired runs; matched actual terminal events; compared
all 653 captured input hashes directly with Git blobs at the governed target;
and recomputed their aggregate input digest. The focused run
`20261030T020329-280326d88dbd` passed the four repaired modules and its fresh
139-module / 25,036-declaration audit. It remains focused evidence.

Complete run
[`20261030T020720-944618f28c05`](../evidence/named-integer-subtypes-20261029/runs/20261030T020720-944618f28c05/retained.json)
finished successfully at 03:07:31 UTC. The actual build and separate fresh audit
both exited 0. The build took 3,584.991 seconds and the audit 10.826 seconds;
managed duration was 3,608.781 seconds and the runner's broader elapsed measurement
was 3,611.322 seconds. These measurements are distinct. The raw fresh-audit log
contains exactly the full **538-module** source set, including root `Silver`,
and audits **115,128 declarations**, reporting only `propext`, `Classical.choice`
and `Quot.sound`. Recomputed the expected module set from the actual committed
Lean file inventory and matched it to both the emitted imports and evidence.
Tool digests agree between preflight and final evidence. Settings are the pinned
Lean 4.34.1, one worker/thread and 24,576 MiB per-process allowance.

This is a complete incremental build and fresh whole-project audit, with normal
dependency-checked reuse. It is neither a clean build nor independent kernel
replay. The failed prior run's successful independent modules were retained;
the repaired `PredicateSourceCandidate` and downstream source route now pass.
The initial native checkpoint and compiler build remain applicable because the
later repair changes only the five reviewed Lean literals/checks.

The earlier complete run `20261029T205735-bb72d0625415` retains its actual
`failure` at 02:01:47 UTC after 18,249.514 seconds. Independently checked both
retained hashes, all 653 original-target input hashes, the seven exact errors
listed above and absence of a whole-project audit. Its outcome is not relabeled
by the later success.

For the [literal-repair regressions](../evidence/named-integer-subtypes-20261029/literal-repair-regression/README.md),
verified all 15 packet digests, the original decompressed logs/events, successful
terminal outcomes and test-phase return code 0. Run
`20261030T013443-d9556926db16` explicitly passes all 12 source identities in
82.157 managed seconds; `20261030T013608-6b001884b330` explicitly passes all 16
platform identities in 253.865 seconds. All 792 tracked inputs in each run match
the repaired target. The eight other input hashes agree across both runs and
with the earlier 18 compiler-fixture results, including the native executable.
The exact disjoint sets reconcile **509 original results + 18 retained repair
fixture results + 28 new proof-tree results = 555 identities**. No identity is
missing or failing. This confirms the earlier applicability review on actual
final proof bytes.

## Final Rosetta and inventory confirmation

Reviewed the [final Rosetta packet](../evidence/named-integer-subtypes-20261029/final-rosetta/README.md)
and revised reconciliation at `31c9e6d915`, integrated from
`78d1416d850b1364058e33b2d8d3782e75a193ab`. Selected reviewer remained GPT-6
Astra / Extra High, with runtime confirmation and token/cost measurements
unavailable. This final inspection ran 06:44:35–06:45:52 UTC (77 seconds),
followed by report preparation; the intervening wait is not review execution.
No build, proof or test was rerun by the reviewer.

Verified all eight packet digests and both decompressed log/event digests.
Managed run `20261030T031457-868467f2105b` has a successful terminal event,
test-phase return code 0, and an explicit successful outcome for each of the
three identities, including their multiline descriptions. Its managed duration
is 8.008 seconds; unittest reports 4.499 seconds. All 792 captured tracked hashes
match actual Git blobs at metadata snapshot `1d6d1b4ffd`; all eight other input
hashes match both latest proof-tree runs. The source, proof, scripts, tests,
samples, catalogue and project inputs remain unchanged from `d4e2be67b5`.

The metadata delta preserves original assessment attribution and describes the
two already implemented drivers' delivery confirmation separately from scoped
independent review and external approval. The three renderer tests cover the
actual current assessment data across hash seeds and the two existing fixtures.
This is Linux renderer evidence, not a new native proof or application run.

Independently reconciled the exact sets and preserved prior inventory and
reconciliation bytes. The final disjoint partition is **506 applicable original
results + 28 latest proof-tree passes + 18 earlier compiler-fixture passes + 3
final Rosetta passes = 555 identities**, representing 546 distinct methods after
the nine imported duplicate executions. All five replacement-run sets match
their covered identities, with no missing or failed identity. The 52 sample
sources and 108 application executions retain their previously reviewed results.

The complete native and Lean claims, regression reuse and historical unsuccessful
outcomes are consistent with the actual inputs and retained terminal records.
This completes the requested evidence confirmation and the #290 repair review.
It establishes no native macOS run, hosted CI result, clean rebuild, cold proof,
independent kernel replay, external approval or authorization to merge PR #289.
