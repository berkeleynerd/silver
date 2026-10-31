# Boolean scalar objects and expressions

Status: final validation in progress; not yet supported.
[Milestone 14](https://github.com/berkeleynerd/silver/milestone/14) contains one
coherent work package, [#291](https://github.com/berkeleynerd/silver/issues/291).
The [2026-10-30 authorization](session-memory.md#2026-10-30--boolean-scalar-objects-and-expressions-authorized)
covers implementation through complete assurance, validation, independent review
and stacked feature PR publication. Feature merge remains unauthorized.

## Selected scope

The lead driver is Rosetta
[Sequence of primes by trial division](../rosetta/s/sequence-of-primes-by-trial-division/task.wiki),
with [Square but not cube](../rosetta/s/square-but-not-cube/task.wiki) and
[Common list elements](../rosetta/c/common-list-elements/task.wiki) exercising
the same coherent feature. Admit initialized scalar Boolean constants and
variables, assignment, the literals `True`/`False`, `not`, eager `and`/`or`/`xor`,
and Boolean expressions in existing conditions with `and then`/`or else`.
Compose them with the currently admitted declarations, predicates, control flow,
arrays and named Integer subtypes on the feature's base.

Develop on subtype [PR #289](https://github.com/berkeleynerd/silver/pull/289)
at `fa6b5e982cad5662b18f498e75cafbac9fb07cc9`. Keep that PR open and unchanged,
and publish the Boolean implementation as a stacked feature PR. This planning
record on `main` does not promote the unmerged subtype capability to current
support. [language.md](../language.md) remains authoritative for current support.

Retain the current 4,096-byte complete-source, 63-operator and 64-leaf budgets
and existing scalar/array limits. Settle precise expression accounting as part
of design without enlarging those budgets. Boolean arrays, callable routines,
enumeration iteration, general enumeration types and capacity/assurance-mode
expansion remain outside this package. No syntax is supported by this proposal
alone, and no Oracle amendment is selected.

## Semantics and design obligations

Specify exact decidable grammar, declaration order, initialization and assignment
typing, permitted expression/condition positions, precedence and parenthesization
under inherited Ada/SPARK meaning. Resolve `Boolean`, `True` and `False` through
Ada visibility and name hiding rather than treating these spellings as new
reserved words. They are currently legal binding names; preserve or explicitly
document intentional admission changes and test declaration scopes, nested
hiding and case-insensitive lookup. An unrelated binding must not be interpreted
as the predefined type or Boolean literal merely because of its spelling.

Eager `and`, `or` and `xor` evaluate both operands. Membership must establish
both operands' safety under the incoming facts; a false left operand of `and`,
or a true left operand of `or`, cannot guard an unsafe right operand.
Short-circuit `and then` and `or else` retain their inherited evaluation rules:
only the appropriate incoming path may justify the right operand. Address mixed
logical forms, `not` and nested parentheses explicitly, including preservation
of existing Integer, String, length and argument-validity predicate facts.

A stored Boolean flag carries its Boolean value; it does not retain a relation
to earlier scalar values or establish their safety later. For example, storing
`D /= 0` in a flag must not make `N / D` admissible solely under a later test of
that flag. Mutation and name hiding must not revive old scalar facts. Settle any
other Boolean fact propagation explicitly while preserving existing invalidation
rules and all permitted compositions, including loops and subtype bounds.

Inspect the actual native producer obligations and report routes before choosing
any required report-policy change. Accepting reports or passing samples alone
cannot establish automatic discharge. Extend affected native Bronze/Silver
verification and Lean decidable membership, composition, semantic preservation,
termination, universal safety, automatic-discharge and actual-source
correspondence arguments for the entire resulting admitted language. Preserve
the author's exact source through proof and build. Do not suppress obligations,
silently narrow domains or substitute an annotated source.

## Completion and Rosetta mapping

Add faithful bounded driver programs, boundary and rejection regressions and
interaction coverage for literals, initialized constants/variables, assignment,
logical truth cases, typing, hiding, eager unsafe operands, guarded short-circuit
operands, stored flags and existing strings/scalars/arrays/loops/subtypes.
Synchronize language, catalogue, samples, roadmap and this capability record
with implementation and assurance at delivery.

Reconcile the exact delivered fragment with assessed Rosetta uses before
promoting supported identifiers. Broad `booleans`, `logical-operators`,
`boolean-flags` and existing broad stages are not automatically completed by
scalar Boolean support. Split or refine identifiers/assessments when their uses
need Boolean arrays, routines or other excluded forms, update the assessor's
current-language description and review metadata, re-render the progression and
update the corresponding stage bookkeeping as applicable.

Complete required native proof/coverage/provenance and build, Lean/source/module/
axiom assurance and full regressions on identified final inputs, then resolve
independent review findings and publish the stacked feature PR. Keep exact
evidence, reused results and limitations distinct. No implementation, proof or
validation result is claimed by this initial planning record.

## Work round

The bounded planning subthread selected GPT-6.1 Sol / High through explicit spawn
controls; independent runtime confirmation, separately measured total elapsed
time and token/cost measurements are unavailable. The intended deliverable is an authorization-only planning PR,
milestone and single package, followed by Backlog-to-Ready bookkeeping after the
authorization lands on `main`. This round makes no tool/code/proof/test changes
and performs no expensive validation. The feature's design, implementation and
required assurance belong to #291. Planning outcome and handoff are recorded
on that issue. The milestone/package and three planning documents are prepared;
local link checks and `git diff --check` pass, with no material scope rework.
CLI memory is unavailable and was not updated.

## Integration checkpoint — 2026-10-30

The native compiler implements the selected Boolean declarations, assignments
and condition forms. Twelve focused Boolean regression methods, including the
new xor lexical controls, have passed on the restricted implementation. The
[producer review](evidence/boolean-objects-20261030/producer-review.md) records
the discovered exponential xor formula expansion and the selected structural
restriction: neither operand of xor may itself contain xor. Independent xor
expressions remain permitted. The restriction is a pinned-tool capacity policy,
not an Ada restriction; no source/operator/leaf budget or report policy changed.
The [native validation record](evidence/boolean-objects-20261030/native-validation.md)
retains the source identities, build, focused regressions and stack observations.

Focused Lean checkpoints establish Boolean declaration admission and state
preservation; exact raw initializer conditions and frozen-value validity;
condition meaning and unique source readings; and Boolean assignment/body
semantics. The latest combined body checkpoint passed a fresh audit of 16,678
declarations with only the three approved foundations. Its Boolean helper trees
and interpretation proofs are checked, while instantiation against authoritative
source tokens remains part of the pending complete source checkpoint. These
results are focused assurance, not complete language support.

The array-declaration Static equality repair passed its focused native check
with the exact original contract retained; the
[repair record](evidence/boolean-objects-20261030/native-repair.md) also records
the String flow-reader equality repair. Reusing the existing
`Integer_Type_Word` constant at its two identical literal sites passed all
18 focused checks in `20261030T122217-a1313f11b288`, retaining the exact contract. Ordered Boolean header
and program integration passed a focused 156-module / 17,972-declaration audit
in run `20261030T112011-d69c83717868`.

Source integration found an initializer-domain mismatch, independently
confirmed against Ada and filed as [#293](https://github.com/berkeleynerd/silver/issues/293).
The [review](reviews/review-boolean-flow-domain-201d7e7cfc.md) explains why mutable
flow facts must be contained in declared bounds even when an initializer's
snapshot is narrower. The repaired flow domain, preservation and initial-flow proofs now pass focused
checks, as do the native predicate model, correspondence and contracts on that
domain. The issue remains open until the complete actual-source checkpoint
consumes the repair.

The broader integration check also exposed an auxiliary scalar-declaration
equation with an extra rejection clause, filed as
[#294](https://github.com/berkeleynerd/silver/issues/294). The
[review](reviews/review-boolean-scalar-equation-33649e1ee5.md) distinguishes the
transcription error from the consistent Ada, typed body and admission model.
The failed elaboration experiments are retained; increasing their limits did
not repair the mismatch. Removing the extra clause restored the original
`by rfl` proof under its original limit. Managed run
`20261030T120915-bfba5cd5f580` passed its focused build and fresh audit of
10,643 declarations.

The derived Boolean declaration library and final helper libraries now pass
their focused audits. The retained Compose and Sequence models also pass after
propagating the Boolean environment through their contexts and initial states.
The ordinary array declaration wrapper has a checked interpretation preserving
its original initializer value and exact Static assertion/return tokens.
The [evidence index](evidence/boolean-objects-20261030/README.md) records these
checks and the actual incremental cache transfers.

Independent admission and proof/source argument reviews found no new defect in
their stated scopes; they did not claim complete validation. The complete Lean
checkpoint on `5198f2b7b5` subsequently failed as recorded below. Regression metadata at `927cc5e178`
prepares the three Rosetta drivers and the 53-to-56 stage-1 progression while
this capability remains pending. The completed full suite and reviewed repair
reruns now cover all 568 test identities (559 distinct methods), including all
55 manifest samples and 111 executions. The
[regression record](evidence/boolean-objects-20261030/full-suite/README.md) and
[independent applicability review](reviews/review-boolean-regression-37c0babc64.md)
retain the failures, exact input comparison and 565 retained plus three fresh
passing results. Final Rosetta wording still needs its three focused tests.
Complete native proof and Lean/source validation, terminal evidence confirmation
and final publication remain. [PR #295](https://github.com/berkeleynerd/silver/pull/295)
is open as a draft on the unchanged subtype PR.
The earlier native unit run uses pre-xor inputs and cannot establish final
assurance. Neither feature PR is authorized to merge.

| Round | Selected settings | Result and remaining work | Measurement scope |
| --- | --- | --- | --- |
| Boolean semantic/source integration, 2026-10-30 | Existing proof/source/native subthreads: GPT-6 Astra / Extra High. Lead runtime setting and whole-team token/cost totals unavailable. | Condition validity/uniqueness, exact declaration payloads, assignment typed source and body semantic checkpoints passed; complete source/capability integration remains open. | Final combined body/helper focused build 41.019 s plus fresh audit 7.139 s; preceding development failures retained in the managed ledger. These are native tool times, not total implementation time. |
| Helper/domain integration, 2026-10-30 | Continuing source, proof-architecture and native subthreads: previously selected GPT-6 Astra / Extra High; runtime confirmation and whole-team token/cost totals unavailable. | #293 native-domain repair and #294 scalar equation repair passed focused checks. Raw helper equations are separated from the Boolean declaration law, which the source bridge derives from interpreted callees. Final source/model integration remains unchecked. | Scalar denotation build 336.697 s and audit 6.120 s. String native repair 65.257 s. Shared helper build 337 s; later dependency failures remain recorded as failed runs. |
| Stable source checkpoint, 2026-10-30 | Independent admission and correspondence reviewers: GPT-6 Astra / Extra High, explicitly selected. Rosetta preparation: GPT-6.1 Sol / High. Lead runtime setting and token/cost totals unavailable. | Focused helper, declaration and retained model checks passed; complete source checkpoint started. Two independent scoped reviews found no new defect. The new hiding regression fixture was corrected after its expected output overlooked its own shadowed `True` binding. | Review windows 4m32s and 5m04s. Final model build 27.025 s / audit 6.231 s; wrapper build 75.964 s / audit 5.198 s. Rosetta preparation about six minutes; four compiler-independent tests passed in 46.620 s. |
| Terminal regression coverage, 2026-10-30 | Native continuation and independent applicability review selected GPT-6 Astra / Extra High; fixture review selected GPT-6.1 Sol / Extra High; delivery-document preparation selected GPT-6.1 Sol / High. Runtime confirmation and whole-team token/cost totals unavailable. | Reviewed fixture repair and unchanged maximum-expression rerun close all 568 identities. Two-CPU attempts retain their deadline failures; the eight-CPU isolated test passes with unchanged assertions and production options. Native and complete Lean checkpoints remain active. | Full suite 7,866.238 s; three-ID rerun 302.871 s (failed overall, both branching methods passed); isolated successful test 150.108 s. Terminal review 2m48s, following preliminary 3m42s. These are actual tool/review intervals, not a controlled speed comparison. |
| Source-proof repair and interrupted native recovery, 2026-10-30 | Certificate diagnosis, wrapper/adapter repairs, native recovery and independent combined review selected GPT-6 Astra / Extra High; lead runtime setting and whole-team token/cost totals unavailable. | The failed complete Lean run exposed a large-list elaborator limit, omitted wrapper parentheses and an opaque zero conversion. Three proof-only repairs preserve Ada, domains and theorem statements; focused checks and independent review passed. All 28 affected source/platform tests passed. Interrupted native work is retained and resumed with unchanged inputs/cache; repaired complete Lean remains required. | Failed complete run 18,628.882 s. Exact-token diagnostic: checked witness 12.95 s versus reproduced `rfl` failure 14.78 s after fixture preparation. Wrapper focused/token checks 33.403/8.609 s; adapter check 52.232 s. Source tests 82.533 s and platform tests 274.264 s. Independent combined review 5m26s. |
| Host-restart recovery, 2026-10-30 | Native recovery selected GPT-6 Astra / Extra High; delivery-record preparation selected GPT-6.1 Sol / High. Lead runtime setting and token/cost totals unavailable. | The 19:37 UTC host restart interrupted both complete checks. Their logs and partial work were retained, unchanged inputs verified, and both managed checks restarted with the existing caches and settings. Complete assurance remains pending. | Replacement Lean build began at 19:41:28 UTC; native run began at 19:41:45 UTC. Interrupted runs have no recorded terminal time or exit code. |
| Final regression reconciliation, 2026-10-30 | Rosetta update selected GPT-6.1 Sol / High; independent applicability confirmation selected GPT-6 Astra / Extra High. Runtime confirmation and token/cost totals unavailable. | Accurate current Rosetta metadata and three renderer tests passed. Independent review confirms disjoint coverage of all 568 identities by 534 retained and 34 refreshed passes. Native and complete Lean assurance remain pending. | Rosetta tests 4.815 s / managed run 7.928 s; independent review 1m15s. |

## Repaired complete checkpoint

The [failed complete run](evidence/boolean-objects-20261030/source-integration/failed-complete/README.md)
retains its three failures. Repair target `b6aeb9f978` uses the existing checked
explicit witness only for large flattened token lists, restores the array
initializer's exact grouping tokens, and normalizes the adapter's zero numeral
with proved core lemmas. The
[independent review](reviews/review-boolean-proof-repairs-b6aeb9f978.md)
confirms unchanged theorem statements, source bytes, models and domains.

All 12 source-certificate, 16 platform and three final Rosetta tests passed.
The [final applicability review](reviews/review-boolean-final-regression-cff54ae34d.md)
confirms that 534 retained results plus 34 refreshed results, including the
three earlier repairs, cover all 568 identities. The Rosetta summaries now
point to current validation status without claiming complete assurance.
These results do not replace the complete source/module/axiom audit.

Repaired complete Lean run `20261030T190042-c50bf05fd9bc` began its build at
19:00:54 UTC with one worker/thread and the existing 24 GiB threshold. A launch
just before it waited on the platform test's workspace lease and did no build.
The host restarted at 19:37 UTC, interrupting that run and recovered native run
`20261030T185133-160271e45fa1` without terminal audits. The earlier native run
`20261030T142912-eb0b24fc2191` was also interrupted; partial sessions, reports
and caches remain retained work, not a complete result.

Replacement Lean run `20261030T194116-3d6d1353e52b` began its build at
19:41:28 UTC with the same settings and retained Lake objects. All 687 captured
source hashes and both tool hashes still match the repaired target. Native run
`20261030T194142-1f663fdf10c2` reuses the same strict options/cache and four
workers, with all 2,561 preflight hashes unchanged from its predecessor. The
[evidence packet](evidence/boolean-objects-20261030/README.md) retains the recovery.
Both complete results remain pending. Neither feature PR is authorized to merge.

### Native equality-proof repair

The [native checkpoint](evidence/boolean-objects-20261030/full-native-failed-194142/README.md)
finished failed at 19:52:53 UTC after 667.844 s. GNATprove reports 17,192 checks:
1,468 flow, 15,722 proved and two unproved. Complete report/provenance auditing
did not run. The remaining checks are the exact Static equality postcondition
of `Read_Boolean_Relation_Into` and an equality-lemma precondition in the eager
chain branch of `Read_Chain_Into`. The solvers reached time/memory limits;
no counterexample was reported, and the executable reader preconditions passed.

The selected candidate adds checked branch equality steps and uses the existing
named right-hand model value in the eager branch's ghost lemma call. Executable
behavior, complete preconditions, exact postconditions and production proof
settings must remain unchanged. Focused validation and independent review are
required before integration. The lead stopped the complete Lean run at
19:57:36 UTC, retaining its inputs, logs and completed objects, because the Ada
annotation repair changes its captured source. Source pins/certificates and
affected validation will be refreshed together after the native repair passes;
no capability completion is claimed.

The first candidate's [focused check](evidence/boolean-objects-20261030/terminal-native-repair/README.md)
failed after 1,025.978 s: all four new `Same_Condition` assertions reached
solver limits. Its downstream postcondition result depends on those unmet
assertions and is not a completed proof. The candidate remains unintegrated.
A bounded [independent diagnosis](reviews/review-boolean-equality-transport-diagnosis.md),
selected GPT-6 Astra / Max for this equality problem, identified missing
transports from Ada record equality to logical equality, including the
constrained `Expected` snapshot. The model's branch expansion was already
present. A first-branch diagnostic using the existing proved equality helper
is running under unchanged limits; its terminal result and complete-reader
checks remain required before integration. Routine native work continues at
the existing Extra High setting.

### Integrated equality repair and resumed complete validation

Implementation/proof target `87dd912436e35569f12cf95be639e4a534dea978`
integrates the [reviewed equality transports](reviews/review-boolean-equality-transports-88b54a1df3.md).
The exact source body hashes to
`88b54a1df3e6cb1b59c482d36cd29a9f15c2506c69227fbef78c9ab93ab67ddb`.
Focused relation run `20261030T204257-8cba82ab7a71` passed 56 checks
(3 flow and 53 proof) in 570.866 s; chain run
`20261030T205242-3d1308b90ec1` passed 204 (4 flow and 200 proof) in
3,020.054 s. Both terminal comparisons verified all 2,561 captured inputs.
These checks resolve the two native obligations above without changing
contracts, admission domains, models or executable behavior. Their
[packet](evidence/boolean-objects-20261030/terminal-native-repair/README.md)
retains the unsuccessful first candidate separately.

The matching handwritten output pin contains 45,196 tokens. All 28 source
certificates were regenerated; only `OutputBodyCertificate.lean` changed.
This is a mechanical parity check, not completed kernel/source assurance.
The compiler rebuild `20261030T214749-120a2c44c6f6` passed in 10.742 s.
Complete native run `20261030T214853-f14ff090b11a` then started with four
workers and unchanged production settings/cache. Complete Lean run
`20261030T214845-59a80335a9ac` began its build at 21:49:01 UTC, retaining
the existing Lake objects and one worker/thread with a 24 GiB threshold.
Both complete results were pending at that checkpoint; their subsequent
failures and repairs are retained below.

The reviewed annotation and source-binding delta requires 46 refreshed
regression identities: 12 source, 16 platform, 17 output-integrity and one
Silver tool/source-change fixture. Their successful reruns and final input
verification would complete coverage with 522 applicable retained results.
Those reruns, complete native and Lean/source audits, and terminal evidence
confirmation remain required before delivery.

### Body_Tail postcondition and native-first completion

Complete native run `20261030T214853-f14ff090b11a`
[failed](evidence/boolean-objects-20261030/full-native-failed-214853/README.md)
at 2026-10-31 02:03:39 UTC after 15,283.832 s. Both repaired readers passed;
17,224 of 17,225 checks discharged. The remaining obligation was the exact
Static `Body_Tail` result/model postcondition, with solver time/memory limits
and no reported counterexample. Complete report/provenance auditing did not run.
The unchanged Body_Tail region had passed in an earlier run; its merged
postcondition did not identify a single failing return.

[Independent diagnosis and candidate review](reviews/review-boolean-body-tail-20261031.md)
selected three checked Static assertions, each stating the original exact
postcondition before an unchanged return. Focused run
`20261031T021634-ccc87594f70c` passed all 74 checks (3 flow, 71 proof) in
372.167 s, with all 2,561 captured inputs matching at terminal. The candidate
preserves contracts, domains, models and executable behavior. Source/evidence
commit `f5ab46cdef`, body SHA-256
`bb3bd71eb53e7f0637ed27ac4b5eb7c283b66dc0fb81131ebe73543c3950d01f`,
remains isolated from the running integration checkpoint.

Its matching build `20261031T022612-eb8a9047980e` passed in 8.566 s.
Complete native run `20261031T022711-e4258c225793` is now checking it with
four workers and the unchanged production options/cache. Complete native
success will precede integration and the next source-certificate rebuild.
This sequencing responds to the repeated native annotation repairs; it adds
no new completion requirement. The Lean run continued on frozen
`87dd912436` inputs to check remaining source integration; its terminal outcome
is recorded below.

That Lean run was temporarily suspended for memory scheduling from 00:29:35
to 02:03:40 UTC, retaining its process, inputs and lease; it resumed normally.
Its large output-body certificate passed, but complete source/module/axiom
assurance remains pending. After native success, the reviewed Body_Tail delta
requires only the output pin/certificate refresh and the same 46 regression
identities. The prepared test archive for `87dd912436` is superseded for final
testing; a new integrated snapshot will be supplied. Both feature PRs remain
open, with no completed Boolean support claim.

### Terminal Lean integration repair — 2026-10-31

Complete run `20261030T214845-59a80335a9ac`
[finished failed](evidence/boolean-objects-20261030/source-integration/failed-transports/README.md)
at 05:26:23 UTC after 27,455.259 s managed time, including the recorded
memory-scheduling suspension. All 687 source and two tool hashes still matched
before repair. The output certificate, Compose candidate and source bridges,
predicate adapter and scalar-body candidate passed; the whole-project audit
did not run. Completed objects remain available for ordinary cache reuse.

`PredicateSourceCandidate` failed only on four unused simplification arguments
under warnings-as-errors. `PredicateEquations` omitted the initializer-storage
argument after the native condition-reader interface was generalized. The
[reviewed repair](reviews/review-boolean-body-condition-wiring-20261031.md)
removes the unused arguments and applies the reader to `[]` at body calls,
matching the actual Ada default all-zero storage. It proves that argument's
validity while retaining arbitrary valid storage in the generalized reader.
No native source, runtime behavior, theorem domain or proof policy changed.

Focused run `20261031T053848-2f8f986ab6e3`
[passed](evidence/boolean-objects-20261030/source-integration/body-condition-wiring/README.md)
`PredicateEquations` and a fresh 309-module / 91,711-declaration audit in
33.356 s managed time. This does not establish complete assurance. The source
candidate and downstream consumers will be checked with the final native-validated
source rather than repeating the expensive check on the obsolete source bytes.
The same 46-test refresh and terminal applicability confirmation remain required.

This bounded repair round selected GPT-6 Astra / Extra High for integration and
independent review; runtime confirmation and token/cost totals were unavailable.
The independent applied-patch review took 1m29s. The native verification subthread
continued the unchanged complete checkpoint; the documentation subthread's
contingent final-record preparation selected GPT-6.1 Sol / High. No complete
Boolean support or merge is claimed.

### Native-validated final source checkpoint

Complete native run `20261031T022711-e4258c225793`
[passed](evidence/boolean-objects-20261030/full-native/README.md) at 06:20:19 UTC
on 2026-10-31: 17,234 checks (1,468 flow and 15,766 proof), 76 units and 1,091
entities, with strict coverage and provenance audits. Its managed time was
13,985.692 s. All 2,561 captured inputs matched before the installed workspace's
two original files were restored; seven unrelated dirty files were preserved.
The previous failed and interrupted runs retain their outcomes.

The final stable integration target is
`91de078ed81d102485c7dd286758e127630b01d6`, including the reviewed Body_Tail
source and the proof-only body-call/lint repairs above. All 143 native
source/script/project inputs match both the successful capture and its retained
archive. The output pin now contains 45,259 tokens. Regenerating all 28
certificates changed only `OutputBodyCertificate.lean`; the other 27 remain
byte-identical. This is mechanical correspondence evidence, not a replacement
for complete kernel/source checking.

Complete Lean run `20261031T062232-72f05d92e6aa` started at 06:22:35 UTC with
one worker/thread and a 24 GiB process threshold, reusing completed Lake objects.
Its captured inputs are frozen. The installed native workspace was explicitly
released after restoration for the same 46-regression refresh on a new snapshot
of this final target. All 46 [refreshed tests](evidence/boolean-objects-20261030/annotation-repair-regressions-91de078e/README.md)
passed with no skips, including the kernel fixture. All four 838-input maps
and 830 snapshot files matched before exact restoration of the 864 original
nodes; unrelated dirty files, binaries and native reports were preserved.
The mechanical inventory accounts for all 568 IDs / 559 methods as 46 refreshed
plus 522 applicable retained results. Complete Lean/source/module/axiom validation
and terminal independent evidence/applicability confirmation remain pending.
No completed Boolean support or merge is claimed at this checkpoint.
