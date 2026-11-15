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
| 2026-11-15 reduced-host recovery | Astra Max native/function-source diagnosis and critical review; Astra Ultra named certificate-memory investigation; Sol High native monitoring; Sol Extra High regression inventory and proposed Rosetta reconciliation; lead runtime not independently exposed | Native storage resolves the open-file ceiling. Native helper/caller recovery and source/certificate normalization pass their focused gates and critical reviews. Complete native validation passed all 19,444 checks on the frozen native inputs, with final coverage and provenance verified. The latest flow-constructor memory failures have a focused complete-candidate success and independent acceptance after exact-field diagnosis, two literal normalizations and unchanged reader-field factoring. The six isolated native-shape header failures now have a complete focused candidate success and independent acceptance. The final compiler build also passes. The next complete Lean continuation stopped at four isolated body-source equalities; their exact-literal repair is the next focused check. All failed attempts and successful objects remain preserved. Final delivery acceptance remains withheld. | [Recovery checkpoint](evidence/scalar-procedures-20261115/recovery/README.md) links exact failures, focused successes and independent reviews, including the native monitoring gap. All 17 source-policy tests passed at candidate refresh; the final 691-ID inventory still requires execution. Complete assurance and final acceptance remain pending. Native timings are retained per run; whole-team token/cost totals unavailable. |
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
| 2026-11-10 07:53–08:38 UTC | Astra Max source/semantic/native authors and bounded peer reviewer; lead integration; live settings not independently confirmed | High declaration library interpretation passed. Production parser retry cleared ten of thirteen failures; a minimal array-state equality annotation is under complete-helper check, with two other parser obligations still in diagnosis. Report callers retained two failed postconditions; a proof-only policy-boundary experiment passed its exact annotation controls and is running. Capacity callers passed 304 checks; the catalogue correction passed its build, exact inventory test and 33 native checks. | High library run `081333` audited 59,394 declarations. Parser `074854` and report `064952` remain failed; current trials are `082741` and `083710`. Capacity `081710` and catalogue `083333` are focused successes. Authoritative source integration, complete native/Lean/regression checks and final independent acceptance remain pending. |
| 2026-11-10 08:39–12:45 UTC | Astra Max native/source diagnosis and independent source review; lead coordination; live settings not independently confirmed | Parser trial `093356` retained 14 failures across three helpers; report reassessment `094033` retained three caller obligations. These step-budget trials remained failed. Exact native contexts motivated bounded helper exports and diagnostic-message extraction rather than another unchanged broad retry. | [Parser repair packet](evidence/scalar-procedures-20261109/native-parser-repair/README.md) retains the failed 287/301 proof, 8/8 flow trial; [report repair packet](evidence/scalar-procedures-20261109/report-diagnostic-repair/README.md) retains the failed reassessment and its exact input. These are diagnostics, not completed assurance or timing comparisons. |
| 2026-11-10 12:45–14:53 UTC | Astra Max native repair and independent full-domain source reviewers; lead coordination; live settings not independently confirmed | Report extraction's first mixed helper failed on empty-default encoding; explicit `Atom_Empty` arguments and exact existing lemmas repaired it. Three complete report helpers and four complete callers then passed. Parser equality-helper export passed, but direct-caller/named-return trials stayed failed; combined early-return, flow-export and join-identity helpers passed. | Report `130301` and `130958` cover 386 proof and 12 flow checks across seven complete entities on `95d4758e`. Parser `143914` covers 227 proof and 15 flow checks across nine complete helpers on `aa1f3722`. Both packets retain canonical 30-second requested policy, warm-cache scope, failed predecessors and bounded reviews. Full native/source/Lean validation remains pending. |
| 2026-11-10 14:54–17:53 UTC | Astra Max native/source repair and independent full-domain reviewers; lead coordination; live settings not independently confirmed | Seven-caller gate retained three residuals; complete metadata helpers and the symmetric short-circuit bridge repaired the function/chain callers. The procedure still had two failures until moving its unchanged static metadata call immediately before successful return. Complete Procedure_Body_At then passed on final parser `735f4bbb`. | [Parser continuity evidence](evidence/scalar-procedures-20261109/native-parser-repair/retained-success-continuity.json) aggregates 687 proof and 43 flow checks across 22 distinct complete entities. Runs `145720` and `162446` remain failed; only their individually complete passing entities are reused, with unchanged selected source fragments and dependencies. Final run `173934` passed 28 proof and two flow checks. This is focused aggregate evidence, not a single whole-source checkpoint. |
| 2026-11-10 17:54–18:13 UTC | Astra Max source integration; lead integration; Sol High evidence-recording role; live settings not independently confirmed | Parser `8108347e75` and report `cf2882170d` are integrated. Build `180332` passed. Source model gate `180634` failed two exact renderer controls; the established Repr import repaired reduction without changing propositions/domains. Focused typed-model/header run `180854` then passed; lead integrated the proof batch as `bfe82aeb81`. | [Bounded source handoff](evidence/scalar-procedures-20261109/native-parser-repair/README.md#subsequent-focused-source-handoff--1812-utc) retains the failure and the 59,461-declaration focused success at 22 workers/22 threads; its 1,101-input recheck and 994-module static inventory have separate scopes. Full native `181302` at 14 workers and eight changed certificate chunks were starting. Complete source/facade/axiom validation, regression coverage and independent delivery acceptance remain pending. |
| 2026-11-10 18:15 – 2026-11-11 03:35 UTC | Astra Max source integration; Sol High native monitoring; selected settings, live runtime not independently confirmed | Eight source chunks and the aggregate passed. Complete Lean build then failed in eleven modules; complete native run failed one Procedure_Updates postcondition and the auditor identified two missing advisory origins. Both run owners retained exact failures and stopped at the owner's evening pause boundary. | [Failed final packets](evidence/scalar-procedures-20261109/final-attempts-20261111/README.md) preserve native `181302` (19,427/19,428 checks), Lean `214613` (no complete fresh audit), and prior successful objects. Independent delta review found the missing `out` checks, tracked as #375 within this delivery. |
| 2026-11-13 09:16–09:23 UTC | Astra Max native/source repair and independent critical review; lead integration runtime settings not independently confirmed | Owner resumed the delivery. Preserved current-main planning records and all caches. Implemented the two reviewed procedure-spec advisory origins; five focused auditor tests pass. Native postcondition and complete handwritten source-integration repairs remain under focused work. | Auditor commit `faa9f17415`, managed test `20261113T092238-18c9ef927da9`; [bounded review](reviews/review-scalar-procedure-advisory-20261113.md). No complete assurance or new capability support is claimed. |
| 2026-11-13 09:24–09:54 UTC | Astra Max native/source authors and independent critical reviewer; lead integration, live settings not independently confirmed | The ghost equality bridge passed 190 proof and 33 flow checks across 17 complete entities. Nine handwritten repairs passed a 62,261-declaration focused audit. Review caught a dormant native path-field loss in the draft ghost model; retaining raw fields repaired it, and its complete-domain contract and counterexample passed a 15,726-declaration audit. | [Resumption repair packet](evidence/scalar-procedures-20261109/resume-repair-20261113/README.md), native `092540`, Lean `092831` and `094850`. Integrated as `3958b2c66d` and `4553fd6a11`. Runtime code, contracts and full domains remain unchanged. Complete native/source/Lean validation is still required. |
| 2026-11-13 09:54–10:13 UTC | Sol High final native/source monitors; Sol Extra High read-only regression/delivery preparation; lead evidence integration, live settings not independently confirmed | Ordinary build passed and complete native validation started with 14 workers. Source chunks started with eight workers, then their process disappeared without a phase exit or proof diagnostic after the ownership handoff. The exact interrupted packet and all completed objects were preserved before the unchanged resume `101154` under the continuing monitor. | Build `095342` passed; native `095455` remains active. Source `095546` is interrupted, not successful or a reported proof failure. Cause is unconfirmed; no contemporaneous OOM was observed. Final regression discovery still has 690 distinct identities; no suite was started alongside proofs. |
| 2026-11-13 10:14–11:34 UTC | Sol High native/source monitors; Astra Max independent integration reviewer; lead confirmation and evidence | Source chunks passed their fresh audit. Independent integration review found a false alias between a qualified validity query and a same-spelled writable variable; lead admission probes confirmed it. Filed #390 inside this delivery and controlled-stopped the now-outdated native/aggregate attempts, retaining exact evidence and caches. | [Finding and stopped-checkpoint packet](evidence/scalar-procedures-20261109/qualified-validity-390-20261113/README.md). Chunk `101154` passed 22,958 declarations / 14 imports. Native `095455` and aggregate `110403` are interrupted, not complete assurance. Native/source Astra Max repair streams and discriminating regressions follow before another stable checkpoint. |
| 2026-11-13 11:35–12:18 UTC | Astra Max native/source repair and independent critical review; Sol High final monitors and regression inventory; live settings not independently confirmed | Repaired qualified validity-selector scanning without changing contracts or the alias rule. Complete native helper/caller, Lean model/source-shape, admission and compiled composition checks passed. Integrated the reviewed repair and restarted complete native validation; final source validation follows in its separate workspace. | [Repair packet](evidence/scalar-procedures-20261109/qualified-validity-repair-20261113/README.md), implementation `51371ef82f`. Native `114106` passed 274 proof / 50 selected flow checks; Lean `115847` passed 16,839 declarations and `120538` passed 16,895. Build `115822`, four admission methods `115938` and compiled fixture `120228` passed. Complete native `121730` is running; #390 remains open pending complete assurance and final regression coverage. |
| 2026-11-13 12:17–18:03 UTC; diagnosis resumed 21:10 UTC | Sol High native/source monitors; Astra Max focused diagnosis after handoff; live settings not independently confirmed | Output certificate passed, but complete source run exhausted host memory and lost a module with Lean exit 137; its owner then controlled-stopped only source processes. Native continued independently and failed one unchanged Array_Declaration_At assertion at the canonical 30-second limit. Exact inputs/reports, successful objects and warm caches are preserved; no full suite followed. | [Final checkpoint failure packet](evidence/scalar-procedures-20261109/final-failures-20261113/README.md). Aggregate `122134`: 16 modules/51,101 declarations passed. Complete source `152103`: 312 builds, no final audit; child exit 137 then actual exit 130 / managed interrupted. Native `121730`: 17,729/17,730 proof records proved, 1,715 flow records; strict obligation/provenance audits fail. Root resumed focused native/memory diagnosis at 21:10 after the monitor-to-lead gap; no complete retry or support claim. |

## Development checkpoint

**Reduced-host recovery resumed, 2026-11-15.** The owner authorized recovery
after the readiness assessment, with the decision recorded on main in
`903dac970`. The [recovery record](evidence/scalar-procedures-20261115/recovery/README.md)
identifies the restored implementation, current Linux ARM64 host, native-storage
workspaces and remaining checks. Original x86_64 binary proof caches are absent.
Mounted-filesystem descriptor exhaustion initially prevented both proof tools
from starting; native storage resolved that problem. The native assertion and
function-source memory failures now have successful focused repairs, preserving
full domains and proof policy. The exact-source aggregate memory repair has
passed its actual-size reconstruction check and independent critical review.
The [combined checkpoint](evidence/scalar-procedures-20261115/recovery/README.md#focused-repairs-and-final-input-checkpoint)
records the reviewed pin, regenerated candidates and remaining capacity checks.
No complete assurance or final regression success is claimed. Preserve the historical attempts
below and the separate worca streams.

The owner resumed this delivery on 2026-11-13. The [retained final attempts](evidence/scalar-procedures-20261109/final-attempts-20261111/README.md)
remain failed. Their native `Procedure_Updates` postcondition and handwritten
Lean integration failures now have independently reviewed repairs and successful
[focused verification](evidence/scalar-procedures-20261109/resume-repair-20261113/README.md)
on integrated `4553fd6a11`. The two exact advisory-origin omissions are repaired
in `faa9f17415`. #375 remains inside this delivery and awaits the complete
authoritative source checks. The subsequent independent integration review found
[#390](https://github.com/berkeleynerd/silver/issues/390): a qualified validity
query falsely conflicts with a same-spelled writable local object. Lead probes
confirmed the mismatch with the specified binding-based alias rule. The native
`095455` and source aggregate `110403` attempts were therefore controlled-stopped;
their [exact packets](evidence/scalar-procedures-20261109/qualified-validity-390-20261113/README.md)
and successful chunks `101154` are preserved. The reviewed native and matching
proof repairs are now integrated at `51371ef82f`, with successful
[complete-contract focused checks and discriminating regressions](evidence/scalar-procedures-20261109/qualified-validity-repair-20261113/README.md).
The [subsequent complete checkpoints](evidence/scalar-procedures-20261109/final-failures-20261113/README.md)
did not pass. Output certificate `122134` passed its 51,101-declaration audit,
but complete source `152103` lost one module with Lean exit 137 during global
memory exhaustion and was then controlled-stopped (actual exit 130, managed
interrupted); no complete audit ran. Native `121730` continued without a signal
and failed one `Array_Declaration_At` assertion at the canonical 30-second
limit. Strict native obligation/coverage and completed-provenance audits fail.
Exact input/report packets, completed objects and warm state remain preserved.
Root resumed focused native and source-memory diagnosis at 21:10 UTC before
another expensive checkpoint; no blind complete retry or domain/obligation
weakening is selected. No full regression suite followed. Complete native/Lean
assurance, the 691-identity suite, independent acceptance and Rosetta promotion
remain pending. #390 and #375 remain part of this delivery until those
requirements are satisfied.

The earlier native parser repair was integrated as `8108347e75`, on exact source
`735f4bbb8cd0f9ecf816e17df3242113417f9ddeeafdf4bcb8ae2ecc25d41758`.
Its [focused repair packet](evidence/scalar-procedures-20261109/native-parser-repair/README.md)
records successful complete helper/caller coverage, including retained successes
from failed broader gates with exact source-fragment continuity. Complete native
and source/Lean assurance remains pending. The parser checks the frozen output prefix,
full declared body ranges, same-state actual evaluation, nonaliasing targets
and copy-back range containment. The initial admission test run was
`20261109T233200-ae6d07cb4d63`; it preceded the full-range, empty-body and numeric-token test additions
and did not execute the native compile fixture. The complete 21-method
admission-only inventory now passes in `20261110T003856-52403809587f`.
Both application fixtures have now passed proof, compilation and execution in the
focused runs recorded above. The new native parser/report helper and affected
caller gates now pass; the final complete regression inventory and integrated
assurance checkpoint remain pending.

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
also passed in the runs linked from the integration packet above. The subsequent
native repair packet records complete focused helper/caller gates; final
integrated native and actual-source assurance remains required.

The final source batch integrates exact native trees, raw equations, callee
interpretation, lexical alias/read correspondence and inherited endpoints with
constructive frame, prefix and declaration readings. Focused typed-model/header
run `20261110T180854-2aee6adef6a2` passed after the retained rendering-control
failure; its audit excludes the whole-output shape/certificate closure.
The [source handoff](evidence/scalar-procedures-20261109/native-parser-repair/README.md#subsequent-focused-source-handoff--1812-utc)
retains its exact scope and input recheck. All parts must meet at the same
accepted declaration/call trace and final source bytes. No completed body or
call law may be substituted as an assumption. Complete native run
`20261110T181302-a4553e500d15` and the changed certificate chunks were starting
at this checkpoint; complete Lean/source/facade/axiom validation, final
regressions and independent acceptance still need completed evidence.
The authorized [#373 proof-iteration package](proof-iteration-efficiency.md)
remains next after this delivery; no successor implementation is included here.

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
Report repair `cf2882170d` now has a
[focused seven-entity packet](evidence/scalar-procedures-20261109/report-diagnostic-repair/README.md)
on exact source `95d4758ea69276203ccfea127b73837701278c2770a996d30e5d6833af1a09b1`.
Its complete helper/caller gates pass all 386 proof and 12 flow checks under the
requested canonical compiler policy, with warm evidence retained. Native
runtime/text/raw contracts carry this report correspondence; the file has no
direct existing Lean model or token certificate. Final Lean capture must still
include these exact report/auditor bytes. Complete final assurance and regression
coverage remain pending; focused successes do not promote capability support.
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
