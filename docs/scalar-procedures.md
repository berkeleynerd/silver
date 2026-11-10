# Small nonrecursive scalar procedures

## Authorization and delivery scope

Owner-selected on 2026-11-09 after the scalar-function Rosetta delivery.
[The authorization](session-memory.md#2026-11-09--rosetta-refresh-repair-and-next-language-increment-authorized)
reached main through PR #369, merge `195b61a559`.
[#370](https://github.com/berkeleynerd/silver/issues/370), in
[milestone 23](https://github.com/berkeleynerd/silver/milestone/23), owns one
bounded language package under the broader
[#11 stage](https://github.com/berkeleynerd/silver/issues/11).
The small [#29 Rosetta refresh repair](https://github.com/berkeleynerd/silver/issues/29)
accompanies its delivery with separate focused Python checks.

**Design and implementation in progress; not supported.** The compiler,
universal proofs, actual-source correspondence, capacity argument and complete
validation must all establish the final rules before support is claimed.
The selected scope is a feature-sized package, not a promise of a same-day
delivery. No broader procedures, Oracle amendment or deferred #119 research
is selected.

## Concrete drivers and boundaries

The first Rosetta driver is
[Return multiple values](../rosetta/r/return-multiple-values/task.wiki).
Its retained Ada solution uses an ordinary procedure with two scalar outputs.
A bounded `Sum_And_Diff` procedure with input subtype `-100 .. 100`, two Integer
outputs and source-written additions/subtractions can express the same task.
Both full input domains must be checked, including calls using their endpoints.
Additional Boolean and `in out` examples and nested-call/loop fixtures exercise
the same mechanism; a sample is counted as Rosetta support only after checking
the task's required behavior and delivering the faithful program.

Use Main-local procedure bodies with a nonempty, single-name formal list,
explicit `in`, `out` or `in out`, and at least one writable formal. Formal types
are visible Integer/Boolean or earlier named Integer subtypes. Procedure names,
formals, locals, predefined names and earlier declarations follow the existing
case-insensitive visibility rules. The closing name must match the opening name.
Locals use the existing initialized Integer/Boolean declaration forms, including
their initializer restrictions. The procedure value environment is closed:
outer objects cannot be captured, and local initializers cannot read formals.

For each `out` formal, require one ordinary assignment immediately after `begin`,
in formal declaration order, before any ordinary body statement. Prefix RHSs may
read initialized locals and `in`/`in out` formals; they may not read any `out`
formal or call a function. This temporary Silver scope rule gives a decidable,
source-visible initialization boundary without adding general path-dependent
definite-assignment analysis. It is not an Ada requirement. The body frame must
be constructed from these actual assignments; inventing initialized output
values in the model is not a substitute.
When no `out` formal supplies a prefix assignment, require at least one ordinary
body statement to satisfy Ada's nonempty statement-list rule.

After the prefix, writable formals behave like ordinary initialized mutable
scalars and enter ordinary body analysis at their full declared ranges. The
prefix establishes initialization and range containment, but does not export
narrower output intervals to that body. This conservative rule reuses the
full-domain parameter-frame check; a body may refine those ranges using its
ordinary assignments and guards. The body admits existing local assignments, function-call assignments,
null, conditions and counted loops, plus calls to earlier accepted procedures.
Function bodies retain their current scope and cannot call procedures in this
increment. Admit a procedure only after its entire body and closing name pass.
Earlier-only calls and finite loops exclude recursion and establish termination.

Calls use positional actuals. A writable actual is an existing mutable bare
Integer/Boolean name; components, constants, immutable formals and loop indexes
are excluded as writable actuals. General aggregates/signatures, String and array
parameters, nested declarations, early return, named/default associations,
capture, external effects, input queries and Reject stay outside this fragment.
These are first-fragment scope restrictions, not inherited Ada restrictions.

## Call and body contracts

1. Check every procedure, including unused ones, over the full product of its
   declared `in` and `in out` domains. Preserve formal name hiding while output
   values are unavailable to prefix RHS readers. The completed initialization
   prefix establishes the existing nonempty initialized-body invariant.
2. Check all actual inputs against the same incoming caller state. Integer `in`
   expressions and `in out` incoming values need nonempty inferred intervals
   contained in their formal ranges. Formal ranges cannot retroactively justify
   unsafe evaluation of the actual expression. Boolean actual evaluation exports
   no path facts to another actual.
3. Each writable formal's entire declared range must fit its actual object's
   declared range. Both input containment and output containment apply to
   `in out`. On return, written Integer targets receive their formal's declared
   interval and lose prior target refinements. Boolean outputs export no saved
   predicate relationship.
4. Writable targets are pairwise distinct by binding identity and scalar kind.
   A writable target cannot occur in another actual's read expression. This
   conservative alias rule prevents conflicting copy-back and keeps the first
   call rule independent of native alias-analysis heuristics.
5. Only the listed writable targets change. Preserve unrelated values and facts,
   String/array stores and immutable input. Derive copy-back order independence
   from target disjointness rather than depending on an Ada copy-back order.
6. Construct executable procedure semantics from the completed declaration
   prefix. Connect body and call checking, execution, safety obligations,
   termination and complete automatic discharge through the actual source
   bridges. An assumed result oracle or an independently safe model does not
   establish the capability.

## Capacity and producer checks

Retain the 4,096-byte complete-source limit, expression operand limits and shared
63-operator budget across Main and all subprograms. Preserve pooled storage
outside recursive body frames; derive metadata capacities from actual admitted
spellings and disjoint source consumption.

The previous [function report envelope](scalar-functions-report-capacity.md)
is 33,149,440 bytes against a 33,554,432-byte allocation. Its 404,992-byte margin
cannot be assumed sufficient for procedures. The shortest statement call
`P(X);` has five bytes, compared with the earlier eight-byte function-assignment
minimum. Changing only that conservative call count from 512 to 819 consumes
235,776 additional dependency bytes and leaves 169,216 bytes before accounting
for new copy-in/copy-back records. Establish the complete current producer bound
before choosing whether the existing allocation suffices. Any necessary bounded
storage adjustment needs its own source-derived argument, documentation and
boundary tests; it does not restart general capacity research.

The [procedure capacity account](scalar-procedures-report-capacity.md) now
derives a conservative 48,676,608-byte envelope, including separate allowances
for copy-back, output-initialization and unused-output records. It selects a 64 MiB retained
Main allocation. Native integration, independent review and boundary validation
of this adjustment are tracked separately: native policy mutations and the
exact 64 MiB/next-byte boundary checks have passed. The
[bounded independent capacity review](reviews/review-scalar-procedures-capacity-a7044d6f45.md)
found no material defect; complete native assurance remains pending.

Managed producer probes precede report-policy changes. Inspect unused procedures,
Integer/Boolean outputs, bounded `in out`, procedure/function composition,
calls under Main branches/loops, copy-in/copy-back subtype boundaries and alias
controls. Inspect exact unread/overwritten output and unused-input diagnostics,
all safety checks, dependency edges, entity coverage and termination witnesses.
Use unchanged application source and production switches, including the existing
`--no-inlining` full-formal-domain route. Never accept a broad warning class
instead of the exact justified producer rule.

## Implementation ownership and validation

Native parsing/metadata and semantic composition have separate isolated Astra
Max streams, coordinated through explicit helper and caller contracts. A source
correspondence stream must derive the raw native equations and interpret them
over their complete precondition domains, including failure states. The lead
owns catalogue/specification integration, samples/regressions, capacity/report
coordination, records, publication and the shared checkpoint. Sol Extra High
owns the independent #29 repair. These are concurrent ownership boundaries
within one language increment; they do not complete separate support claims.

Establish focused success for each new or contract-changed helper and affected
callers before an expensive integrated run. Check inherited Sequence consumers
after shared state or command changes. Review source shapes with their native
and semantic changes; preserve the current guard controls and the #340 raw
equation-to-library derivations. Reuse matching completed proof objects with
recorded seed identity, preserving private/server artifacts and Lake metadata.

Freeze the combined native/proof/test inputs for one complete native audit,
Lean/source/module/axiom checkpoint, and full applicable regression/sample suite.
Use managed runners and automatic CPU defaults unless concurrent reservations
or observed memory headroom require fewer workers. Preserve failures accurately;
focused successes never replace complete assurance. Independent critical review
precedes support/delivery claims. Reconcile only the faithfully demonstrated
Rosetta tasks and update #11's broader-stage record without declaring its
remaining surface complete.

## Work rounds

| Date | Selected settings | Result and next check | Evidence scope |
| --- | --- | --- | --- |
| 2026-11-09 | Astra Max procedure design/native probes; Sol Extra High refresh repair; lead runtime not independently exposed | Established the leading output-initialization scope, identified effectful-call/capacity contracts, and started isolated #370 streams. #29 has successful focused checks; its final source/error review is completing. | Design inspection and focused Python checks only; no new procedure assurance or support. Native producer results, helper contracts and source integration remain pending. |
| 2026-11-09 23:06–23:32 UTC | Sol Extra High refresh author; Astra Max native, semantic and source authors; lead runtime not independently exposed | Final #29 repair passed 12 tests. Procedure metadata passed 62 native checks; the selected mechanism probe passed 75 checks, and initial parser tests passed 19 admission methods. Narrow-copyback and unsafe-unused-body probes failed as expected. | Refresh evidence and native producer/metadata packets are retained under `docs/evidence/scalar-procedures-20261109/`. These are focused results, not feature completion. |
| 2026-11-09 23:21–23:43 UTC | Astra Max semantic/source authors and native helper investigation; lead runtime not independently exposed | Call/input/copy-back contracts, metadata actual-source checks and signature interpretation passed focused Lean audits. Integrated parser implementation and drafted shared Python/native report-policy regressions. Pinned producer inspection established one initialization record per `out` formal. | Runs `20261109T232157-f50052810dba`, `20261109T232318-79e59bd00147` and `20261109T232931-d434ec47373f` cover the completed proof slices; the body/environment/source integration and complete native helper checks remain pending. |
| 2026-11-10 | Lead source inspection; Astra Max native/source repair; live lead settings not independently exposed | Found that the initial alias scan treated based-literal digits and exponent letters as identifier reads, wrongly rejecting calls such as `P(16#F#, F)`. Added discriminating positive literal controls and true-alias rejections; native repair consumes a complete scalar literal before identifier classification. | Regression commit `8265bc085d` and native repair `91fd84a7e5` are integrated. Matching source proof and affected complete-helper checks remain pending. |
| 2026-11-10 00:12–00:20 UTC | Astra Max native/semantic/source authors; lead integration and evidence | Initial native helper/caller run finished with all 739 reported checks proved but failed the strict warning policy for a redundant initializer. Removed that initializer without changing contracts. Integrated native report API, projection plumbing and 64 MiB guards; five focused Python policy methods passed. | Initial run `20261109T233616-62a3028df4a0` remains failed and retained. [Python policy run](evidence/scalar-procedures-20261109/python-policy-tests/README.md) `20261110T001444-6cb1be2b5661` passed. Native fixtures, repaired helper success and semantic/source integration remain pending. |
| 2026-11-10 00:28–00:40 UTC | Astra Max native/semantic/source authors; lead integration and evidence; live lead settings not independently exposed | All 21 admission-only methods passed after correcting literal test operands. Native policy mutation and report-storage boundary methods passed after adding the required IO context to the native fixture. Shared procedure-state and retained Sequence models compiled; focused semantic/call checks continue. | [Integration packet](evidence/scalar-procedures-20261109/integration-tests/README.md) retains the failed fixture run and successful checks. Complete native/Lean/source and application validation remain pending. |
| 2026-11-10 00:40–00:54 UTC | Astra Max semantic/source authors and bounded native-author peer review; lead catalogue/test integration; live lead settings not independently exposed | Shared state/scanner/call-model and constructed semantic checks passed fresh focused audits. The native author found no consequential mismatch in four semantic/parser interfaces. Corrected inherited function-only catalogue contexts and added an admitted array/argument composition fixture whose native execution is pending. | Source run `20261110T003718-dd5e96504455` audited 30,147 declarations; [semantic run](evidence/scalar-procedures-20261109/semantic-core/README.md) `20261110T004159-c31395be0a84` audited 15,228. Catalogue build `20261110T004754-dfff438a7905` and test `20261110T004858-21e97ac0adcc` passed. Complete source/native/regression validation remains pending. |
| 2026-11-10 00:59–01:27 UTC | Astra Max native/semantic/source authors; lead integration; live settings not independently confirmed | Complete native call/prefix helper block passed 1,381 checks. Source work exposed inconsistent guard refinement for immutable inputs in the output prefix; corrected the local declaration count and passed five regression controls. Split pure frame properties from native record equations and checked the recursive lexical scanner over its full native domain. | Native run `20261110T002858-36ecd7c485a1` covers the earlier helper inputs; changed prefix helpers/callers need fresh proof. Source run `20261110T012022-241c8683f07a` passed four targets and a 17,037-declaration audit. Integration build `20261110T012615-5f6273a4685d` and regression `20261110T012642-4eb88a60f0f1` passed. Authoritative scanner tokens, declaration/call meanings and complete validation remain pending. |
| 2026-11-10 01:39–02:08 UTC | Lead scanner integration; Astra Max native/source/semantic authors; live settings not independently confirmed | All ten lexical scanner source fragments and their candidate passed, with a fresh 14,594-declaration audit. Procedure-aware visibility and constructive call readings are integrated from separately focused checks. | [Scanner candidate evidence](evidence/scalar-procedures-20261109/scanner-candidate/README.md), run `20261110T013948-d5400a83673c`; exact authoritative adapter and remaining declaration/call/body integration remain pending. |
| 2026-11-10 02:09–02:21 UTC | Lead report repair; Astra Max native producer/domain review and source/semantic authors; live settings not independently confirmed | Array/argument application passed. Multi-output application proved all 74 checks but exposed an unhandled unused-procedure-output advisory. Matched the exact producer message and known callee in both auditors; policy controls and the unchanged application then passed. Native report baseline completed 3,740 checks. | [Failure and repair evidence](evidence/scalar-procedures-20261109/unused-output-advisory/README.md); repaired build `021739`, final focused rerun `022030`. Native baseline `012143` predates the advisory repair. Changed report contracts, remaining parser contracts and final source/semantic integration still need validation. |
| 2026-11-10 02:22–02:40 UTC | Astra Max semantic/source authors; lead integration; live settings not independently confirmed | Constructive frame/prefix/declaration interfaces and procedure-aware body source readings passed their focused audits. The source slice preserves ordinary body semantics while adding call reading, flow and bound preservation. | Scope run `20261110T022251-2b138acb04b3` audited 24,431 declarations; body run `20261110T023406-93c99c442f2c` audited 17,640. Full declaration/body/call assembly, native raw-library integration and authoritative endpoints remain pending. |
| 2026-11-10 02:55–03:27 UTC | Astra Max semantic/source authors; lead integration; live settings not independently confirmed | Basic procedure dispatch, lexical traversal, declaration extraction and initialized-output/metadata preservation passed focused audits. The inherited lookup run has passed Boolean-array and String equations; its initial-state metadata lemma is prepared for repair after the active run exits. | [Source integration packet](evidence/scalar-procedures-20261109/source-integration/README.md) retains the five successful slices and cache transfer identities. Full Boolean-actual exclusion, mixed declaration/body/call assembly, raw-helper library interpretation and authoritative endpoints remain pending; high-level declaration trees are still drafts. |
| 2026-11-10 03:28–03:56 UTC | Astra Max semantic/source/native authors; lead inherited-interface repair and integration; live settings not independently confirmed | Inherited procedure visibility, initial-state and procedure-aware body/adapter checks passed; mixed callable preservation also passed. Added the native `out` keyword to the shared token domain, pending its next dependency check. | Focused runs `034825-2a8123f9ef80` (39,214 declarations) and `035322-f0371cac4eee` (14,986) are retained in the source integration packet. High declaration/source and metadata selection proofs, complete semantic assembly and final validation remain pending. |
| 2026-11-10 03:58–04:33 UTC | Astra Max semantic/source/native authors; lead source inspection and integration; live settings not independently confirmed | Character/index/length traversal and exact call-source interpretation passed. Lead inspection found the new model dispatcher had procedure-first order; the corrected function-first model passed and is integrated. High declaration model witnesses are undergoing dependent-instance normalization repairs. | Runs `035845-3c155b0af802`, `041546-7a374a26b150` and `042215-69564f38c8a0` are retained in the source integration packet. Full declaration/call/body assembly and final native/Lean/source/regression validation remain pending. |
| 2026-11-10 04:34–04:57 UTC | Astra Max semantic/source/native authors and independent capacity review; lead integration; live settings not independently confirmed | The outer declaration equation compiled; the body equation remains in focused normalization repair. The bounded capacity/classifier review found only two producer-line citations, now corrected. | [Capacity review](reviews/review-scalar-procedures-capacity-a7044d6f45.md). Native helper run `022439-f9ff5f579d7e` retained two caller postcondition timeouts under the exploratory 30-second limit; complete caller retry `044716-a975e2f83ff2` uses the production budget. Mixed declaration consumers, low helper source interpretation and final validation remain pending. |
| 2026-11-10 05:02–05:40 UTC | Astra Max semantic/source/native authors; lead high declaration integration; live settings not independently confirmed | High declaration raw equations, imported-callee reductions and structural guards passed, together with mixed callable traces/decoding and actual-source alias separation. Integrated the exact function-first native dispatcher. Complete-source fragment checks are running; their high-level aggregate has a prepared finite-list proof repair. | Focused runs `052202-573dd511a4b3` (19,194 declarations), `051020-83ef994a401d` (24,751) and `052037-615179f8f445` (50,897) are retained in the source integration packet. Low library interpretation, ordinary body/flag/endpoint assembly, native caller checks and final validation remain pending. |
| 2026-11-10 05:41–06:22 UTC | Astra Max semantic/source/native authors; lead source integration; live settings not independently confirmed | Source-derived body readiness and the low source/domain/contract subset passed fresh audits. Complete reviewed-token declaration/call candidates, fresh-frame construction, metadata selection and statement flags also passed. Staged simplification reduced the next low helper proof from a reduction-budget failure to ordinary local goals. | Runs `053117-1cc7caffd698` (23,675), `060446-823a620d694f` (18,973) and `061920-0ed033d1b83a` (28,691) are retained in the source integration packet. Generic body assembly, low/high library composition, authoritative endpoint checks and final native/Lean/regression validation remain pending. |
| 2026-11-10 06:23–06:53 UTC | Astra Max source/semantic/native authors; lead integration and bounded native-author conceptual review; live settings not independently confirmed | Source-derived actual updates, generic body meaning and checked mixed callable definitions passed. All low declaration source fragments and their repaired aggregate passed against the complete reviewed output tokens. Production native report proof retained two solver-limit failures; prepared caller-local classifier abstraction and passed its three exact annotation-policy tests. | Source integration runs `061700` (21,337), `063245` (23,080), `064408` (25,005) and `064954` (15,836) are retained with input comparisons and cache provenance. [Report caller repair](evidence/scalar-procedures-20261109/report-caller-abstraction/README.md) keeps `044716` failed; retry `064952` is pending. Low/high library composition, outer semantic consumers, authoritative adapters and final validation remain pending. |

| 2026-11-10 06:54–07:52 UTC | Astra Max source/semantic authors and bounded independent reviewer; lead integration; live settings not independently confirmed | Low native-domain libraries, outer source meaning and complete String assurance closure passed focused audits. Admission review found catalogue C1, tracked as #372; its repair awaits the native input freeze. The first high-library gate found a missing procedure count in the inherited declaration termination measure; a proof-only repair is under focused check. Four completed output-body chunks were preserved before allocating six workers to the remaining four. | Runs `070603` (58,086), `071116` (25,909) and `071235` (26,337) are retained in the source-integration packet. Native parser run `022141` remains failed on 13 obligations; production-settings retry `074854-b82fcb5366fa` checks the nine complete affected helpers. Report retry `064952` continues. Complete native/Lean/source/regression validation and final acceptance remain pending. |

## Development checkpoint

The native parser implementation through author commit `91fd84a7e5` is integrated
with its assurance explicitly pending. It checks the frozen output prefix,
full declared body ranges, same-state actual evaluation, nonaliasing targets
and copy-back range containment. The initial admission test run was
`20261109T233200-ae6d07cb4d63`; it preceded the full-range, empty-body and numeric-token test additions
and did not execute the native compile fixture. The complete 21-method
admission-only inventory now passes in `20261110T003856-52403809587f`.
Both application fixtures have now passed proof, compilation and execution in the
focused runs recorded above. Complete helper contracts and final regression
inventory still need validation.

The metadata source bridge covers the actual SPARK unit and its helper domains.
Its signature adapter retains earlier signatures when the pooled metadata grows;
writable-formal existence remains an explicit declaration-admission condition,
rather than narrowing the generic metadata helper's domain. Focused source test
run `20261109T232524-73b6b4ad9ac2` passed 16 tests, including the retained kernel
rejection controls. These results do not yet establish correspondence for the
new declaration and call readers.

The constructed semantic core is now integrated from author commit
`a71e3ccfbf`, with its [focused evidence](evidence/scalar-procedures-20261109/semantic-core/README.md).
It includes actual-prefix evaluation, full-domain body safety, unused-body
obligations, earlier-callable environment construction, copy-back permutation
and safe-read noninterference. Shared-state/model commit `d8400299ec` includes
the retained `SequenceModel` repair and the initial lexical and call-admission
models. The [bounded peer comparison](reviews/review-scalar-procedure-semantic-peer-a71e3ccfbf.md)
initially found no consequential mismatch in prefix order, body entry domains,
call ranges or earlier-body visibility; it does not discharge source correspondence.
Subsequent sequential-prefix source work found that the native prefix excluded
immutable input formals from guard refinement. The
[baseline probes](evidence/scalar-procedures-20261109/prefix-refinement-baseline/README.md)
confirm the difference. The selected native/model repair passes the local
declaration count into prefix checking, preserving ordinary formal refinement
and the full declared input domains. The native-author build and regression
passed in `20261110T011921-1abbf6ac3b3b` and
`20261110T012006-51adf33fb7b7`; the integration compiler rebuild and regression
also passed in the runs linked from the integration packet above. Fresh complete
proof of the changed prefix helpers and affected callers remains pending.

That remaining work has two owners: the source stream derives exact native
trees, raw equations, callee interpretation, lexical alias/read correspondence
and inherited source endpoints; the semantic stream derives constructive
frame, sequential-prefix and declaration readings and their meanings. Both
must meet at the same accepted declaration/call trace. No completed body or
call law may be substituted as an assumption. The complete native, Lean/source,
application and regression checkpoint follows these focused helper checks.

Report regressions use the same policy boundaries in Python and native tests:
missing or duplicate output initialization, wrong owner or output name, missing
unused-procedure coverage, failed safety checks and preservation of function
termination requirements. Initialization classification uses only observations
preserved by the existing report projection. The native policy mutation tests
and report-storage boundary tests now pass against the integrated report API,
as recorded in the
[integration packet](evidence/scalar-procedures-20261109/integration-tests/README.md).
The five Python policy methods passed in the focused run recorded above.
The two compiler-driven application fixtures have passed proof, build and execution.
The changed native helper contracts and complete final checkpoint remain pending.
No new report-auditor architecture or independent kernel replay is selected.

The integration worktree has an isolated native installation copied from the
native-author worktree, followed by a fresh `scripts/bootstrap.py` configuration
and version check. Its Lean 4.34.1 distribution and authenticated archive came
from `tmp/review-response-74ea2edeaa`; `scripts/bootstrap_lean.py` rechecked the
archive and installed version. The initial proof-cache seed was that worktree's
accepted `20261109T144532-5e2dbc4f965b` checkpoint. The complete proof workspace,
including private/server objects, traces and Lake metadata, was copied to the
integration worktree's own `.silver/linux-x86_64/proof`; there are no shared
cache writers. This prepares incremental validation and is not a new proof run.
