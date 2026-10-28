# External comprehensive review of milestone 10 — 2026-10-28

This is a repository retention summary of the full external report supplied by
the owner in conversation, not a verbatim transcript. It preserves all ranked
finding IDs and separates the external conclusions from the authorized response.
The [original report](https://claude.ai/artifact/RDwrLfg5NJMfJ5xC7JZWkg) is private.
The reviewer made no repository, worktree or GitHub edits.

Target: `10cdcd274c`, tree identical to `0a85336c83`, PR #263; base
`b41c4ba0f5`. The review also covered the merges since the previous external
review `22838bc809`, including the review-response and first development-velocity
package. Later main `a2bb0a9f65` changes planning documents only.

## External conclusions

**No blocker; one medium, 16 low and 15 informational findings.** The fixed-size
Integer-array support claims can stand. M1 is a latent defect in the proof-side
precedence guard: no current expression tree has the wrong association, and
stacked PR #266 adds no use of the affected constructors. It nevertheless needs
a guard repair before further trees rely on that check. The implementing team's
closing review quoted no consequential findings accurately but missed this defect;
the earlier scoped reviews had not examined the guard.

The reviewer reports approximately 440 admission probes with no divergences and
220 pinned-GNAT frontend runs compiling every admitted probed shape. Language,
catalogue, Ada, Lean and compiler behavior agree apart from the identified
catalogue descriptions. All 28 certificates regenerate byte-identically; 34
whole-file token literals match independent lexing; 421 extractor applications
select unique declarations and 67 rendered expectations equal the Ada source.
Endpoint statements are unchanged, with no new endpoint premise, unfinished proof
or kernel bypass.

Retained native reports recount to 16,697 proved checks (1,418 flow and 15,279
proof), 76 units and 1,068 entities; all 143 tracked provenance inputs and 78
report digests match. The native run started without sessions or solver cache.
The complete Lean evidence covers 531 modules and 112,162 declarations with only
`propext`, `Classical.choice` and `Quot.sound`, and 646 captured source inputs
match. Four modules rebuilt; the remaining 527 were accepted through Lake's
documented local-cache mechanism. The regression census is 530 unittest
identities: 76 successful reruns plus 454 applicable retained results. Nine
identities duplicate shared-bindings methods, giving 521 distinct tests.

These are external-review observations, not newly executed assurance here. The
review did not rerun Lean, GNATprove or the test suite. It did not observe a
deepest-shape compile at an 8 MiB stack, independent kernel replay, macOS or CI.
Probe programs and review transcripts remain on the reviewer's VM.

Selected reviewers were Claude Fable 5.1, followed by Claude Opus 5.5 at maximum
effort after usage limits. The report records 186 completed agents across three
workflow runs, 68 candidate findings, 170 adversarial verdicts and 208 re-derived
claims (169 confirmed, 32 partially confirmed, three briefing errors refuted and
four not determinable read-only). It reports the following harness measurements;
they were not independently metered by this team:

| Review run | Reported model and work | Subagent tokens | Tool calls |
| --- | --- | --- | --- |
| Dimension analysis | Fable 5.1; 97 launched, 20 completed before usage limit | 5.9 M | 1,324 |
| Continuation and verification | Opus 5.5, maximum; 161 completed, resumed from journal after interruption | 19.3 M | 6,009 |
| Critic and consolidation | Opus 5.5, maximum; five completed | 1.9 M | 484 |

## Medium finding

### M1 — Expression-tree precedence and association

[Issue #268](https://github.com/berkeleynerd/silver/issues/268), medium.
`Compose.Expr.primary` is a deny-list ending in `true`; the `integerSub`,
`integerAdd`, `integerGt` and `integerGe` constructors added by #263 fall through.
Their `wellFormed` arms check children without operand categories, although their
renderers emit bare infix tokens. The corresponding native array tree languages
also lack complete precedence predicates; the array helper's existing predicate
checks scope only. Model-witness equalities do not rule out a model and tree
sharing the same misreading of Ada.

The external report gives these examples for `a = 10`, `b = 3`, `c = 2` and
`t = true`; independently transcribed guards accepted them, and the pinned
frontend confirmed the differing Ada evaluations:

| Tree/rendering | Ada | Tree evaluation |
| --- | --- | --- |
| `integerSub a (integerSub b c)` → `a - b - c` | 5 | 9 |
| `integerSub a (integerAdd b c)` → `a - b + c` | 9 | 5 |
| Grouped `integerAdd (ite t a b) c` → `(if t then a else b + c)` | 10 | 12 |
| `integerSub (ite t a b) c` as argument → `f (if t then a else b - c)` | 10 | 8 |

Only the current array-declaration body uses the four new constructors and its
trees are correctly grouped. All seven native-array trees also match the source's
Ada association. The defect therefore does not invalidate a current compiler
program or correspondence conclusion. The requested repair makes primary
classification fail closed, constrains operator operands, adds both native-array
guards, and kernel-checks negative controls including the latent
`boolNe (andThen p q) r` case. The new guards must be required by the authoritative
source-check predicates; an unconsumed theorem alone would not close the gap.

## Low findings

The descriptions below retain the external findings; the issue links identify
their response tracking rather than claiming that their fixes have passed.

| ID | External finding | Tracking |
| --- | --- | --- |
| L1 | Current safety-class lists omit accepted `VC_INDEX_CHECK`, including an incorrect “No other safety class” sentence. | [#269](https://github.com/berkeleynerd/silver/issues/269) |
| L2 | Five catalogue initializer/Image/bound condition strings omit admitted array components; #267's loop-element correction is related but distinct. | [#270](https://github.com/berkeleynerd/silver/issues/270) |
| L3 | Explain nonempty/contained subscripts even in dead contexts, conservative Full body-read intervals and aggregate exclusions. Pinned frontend rejection motivates both halves of the subscript rule, but the uniform rule also rejects some frontend-accepted shapes. | [#271](https://github.com/berkeleynerd/silver/issues/271) |
| L4 | Array metadata increases each recursive loop frame from 29,184 to about 33,950 bytes; reviewer observations need about 5.2–5.3 MiB for 143 nested loops. Current stack summaries and the previous N3 disposition are stale; observe managed compilation at 8 MiB for counted and foreach nests. | [#272](https://github.com/berkeleynerd/silver/issues/272) |
| L5 | Current README/storage-limit statements still say 16 MiB after the increase to 32 MiB. Dated measurements remain historical. | [#273](https://github.com/berkeleynerd/silver/issues/273) |
| L6 | The arrays native run started without sessions/cache; calling its 28,417-second cost cache reuse misleads planning. Keep native and Lean cache descriptions distinct. | [#274](https://github.com/berkeleynerd/silver/issues/274) |
| L7 | Disclose the Lean seed and actual reuse: four final rebuilds, 257 under-recorded imported objects, other reused objects, six objects completed inside failed focused runs, and the transfer's retained input-map identity. Validity is not disputed. | [#275](https://github.com/berkeleynerd/silver/issues/275) |
| L8 | Managed tests omit the renderer, manifest and coverage files read by Rosetta tests, so the old run alone does not bind its metadata. | [#276](https://github.com/berkeleynerd/silver/issues/276) |
| L9 | The linked arrays assessment retains prepared wording and the roadmap lacks a dated delivery line. | [#277](https://github.com/berkeleynerd/silver/issues/277) |
| L10 | Preserve the replaced 2026-10-25 Even or odd/FizzBuzz review attribution in the linked assessment record. | [#278](https://github.com/berkeleynerd/silver/issues/278) |
| L11 | #255 remains open although the delivered retagging completed its scope. | Completion action on [#255](https://github.com/berkeleynerd/silver/issues/255) |
| L12 | Auto-closed #260/#262 lack final completion comments identifying implementation, review, evidence and remaining M1. | Completion actions on [#260](https://github.com/berkeleynerd/silver/issues/260), [#262](https://github.com/berkeleynerd/silver/issues/262) |
| L13 | The capability rounds table ends at a pending intermediate checkpoint and omits later substantive rounds. Do not invent missing selections or timing. | [#279](https://github.com/berkeleynerd/silver/issues/279) |
| L14 | The previous review summary substitutes unavailable runtime settings for the reviewer's observation that the lead's selected model/effort was not recorded. | [#280](https://github.com/berkeleynerd/silver/issues/280) |
| L15 | Two retained diagnostics are agent-written, use worktree-relative paths, and include 150 memory samples rather than a proven peak. Label their origin accurately. | [#281](https://github.com/berkeleynerd/silver/issues/281) |
| L16 | Define the otherwise undefined `scalar_index_expression` once and use consistent naming. Existing prose still determines membership. | [#282](https://github.com/berkeleynerd/silver/issues/282) |

## Informational findings and selected dispositions

The finding column retains the external observation. The disposition column is
this response's engineering choice under the owner's bounded authorization;
optional suggestions are not automatically new implementation projects.

| ID | External observation | Response disposition |
| --- | --- | --- |
| I1 | Some array source, mutable-write-frame and raw-elaboration facts are proved at lemma level rather than conjoined into the composed endpoint. | Clarify the actual claims in assurance documentation. Retain the external info rating; do not weaken or redesign endpoints or impose a new global severity policy. |
| I2 | Mirroring helper domains to Ada preconditions remains review-checked; two earlier instances were repaired as blockers. No further instance was found. | Defer stronger domain mechanization to the next semantic/helper-domain change; M1's syntax-guard repair does not select that separate argument. |
| I3 | Shared Compose-state edits twice missed retained Sequence modules in focused validation. | Add concise focused-target guidance for `Silver.SequenceModel`; no new runner mode. |
| I4 | The final delivery review was a closing confirmation using earlier scoped reviews and did not cover M1. | Describe that scope accurately in the completion comments and response; preserve the historical verdict as history. |
| I5 | Missing array boundary/dead-code controls, including frontend-rejected dead shapes and the maximum component table. | Record the concrete cases on [#4](https://github.com/berkeleynerd/silver/issues/4) for the next array regression change. |
| I6 | No compiled array-only unused-final-write test distinguishes assignment-policy selection. | Keep as a bounded optional regression with #4; no policy change is needed. |
| I7 | The Main advisory discovery report is cited only through an ephemeral path. | Retain the existing four probe artifacts from run `20261027T075301` with hashes if available; no new proof experiment is implied. |
| I8 | “646 captured Lean inputs” excludes 28 regenerated certificates. | State the distinction and cite the existing parity run `20261027T124103`. |
| I9 | The preliminary regression report includes conclusions obtained in its follow-up pass. | Add attribution from the contemporaneous record. |
| I10 | An imported test class causes nine duplicate unittest executions. | Defer the module-import cleanup to the next touch of that test file; current inventory counts remain accurate identities. |
| I11 | Added source extractors duplicate existing safe definitions. | Defer consolidation to the next relevant edit; do not broaden the guard repair into an extractor refactor. |
| I12 | Unreachable legacy readers carry elaboration-exact array snapshots. | Note on existing cleanup [#6](https://github.com/berkeleynerd/silver/issues/6); retire with a later relevant source/certificate change. |
| I13 | Other Stage-3 array tasks may admit attribute-free rewrites; their nonmigration is disclosed. | Retain as a future planning item under broad arrays [#12](https://github.com/berkeleynerd/silver/issues/12); no reassessment or language expansion is selected now. |
| I14 | The assessor rubric omits independent array operand accounting. | Add the existing 64-operand rule to the description; do not change language budgets. |
| I15 | The capacity input table omits two cited pinned producer files. | Add `flow-analysis.adb` and `gnat2why-driver.adb` identities when reconciling that record, using actual pinned bytes. |

## Context, limits and rejected candidates

The report's notes preserve the following limits and context:

- N1/N4/N5: a runtime-unreachable hull loop, a loose true binding-size comment,
  and ghost equality helpers require no immediate change.
- N2/N8: source-candidate timings, a failed complete run and certificate suspension
  are measured historical work; full-suite compile deadlines on a reserved host
  do not establish compiler runtime growth or peak memory.
- N3: the enclosing-operation 65th operand case can join I5.
- N6/N7/N9/N10: local-cache acceptance is documented policy; some retained tests
  rely on reviewed applicability, successful objects can originate in failed
  runs, and a verified uncommitted exact-byte checkpoint is permitted. L7 asks
  for accurate recording, not mandatory replay.
- N11/N13/N16: the report envelope is conservative; no delivered Main array
  report was retained, while tests exercised both auditors; cross-cutting policy
  additions cannot change array-free outcomes.
- N12: previously noted malformed-message accessor hardening remains optional.
- N14: PR #266 inherits the identified record/guard gaps and its shorter loop
  syntax matters for the stack observation.
- N15: Actions was disabled and no GitHub/macOS/CI assurance was claimed.

The reviewer dropped candidates based on Ada's own-bound name rule, the existing
operand-boundary test, already-written cache-copy guidance, duplicated or
misread review timing, disclosed cross-cutting changes, existing commit issue
references, the absence of a required review pause, preserved dropped-candidate
reasons, existing memory/capacity guidance, already dispositioned auditor
history, and retained velocity input inventories. These rejected candidates
do not justify new gates or infrastructure.

## Authorized response and current state

The owner chose **“Separate response PR stacked on #266 (recommended)”** on
2026-10-28. [Milestone 12](https://github.com/berkeleynerd/silver/milestone/12)
contains one coordinated response: M1, the required low corrections, the two
stack observations, and the dispositions above. Keep #266 and the response PR
open. No Oracle amendment, new language capability, cache-security framework,
independent kernel replay or general #119 capacity redesign is selected.

The external timing recommendations preceded #266's completion. Its full native
audit passed at 17:38 UTC and its final Rosetta tests passed afterward. L8 remains
a real inventory gap; those tests were not missing, and their separately
reviewed applicability remains historical evidence. The two latest source
candidates took 6,034 and 6,859 seconds at one worker/thread, so the older
8,900-second rebuild estimate is not a current baseline.

Implementation and validation of this response are pending. Existing source
certificates remain reusable when their Ada and generator inputs match. The
combined proof, catalogue and runner changes will receive one stable complete
native and Lean/source checkpoint, affected regressions and independent review.
No original failure or interrupted run will be relabelled successful.

| Round | Selected model/effort | Result and measurement limits |
| --- | --- | --- |
| Scope and current-tree assessment | GPT-6 Astra / Extra High; GPT-6.1 Sol / High for record triage | Confirmed M1 remains latent on #266, identified the missing authoritative guard connection, and grouped the required corrections. No builds/proofs/tests. Runtime confirmation and token/cost data unavailable. |
