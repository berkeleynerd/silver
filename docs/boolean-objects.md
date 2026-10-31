# Boolean scalar objects and expressions

Status: implemented and validated on Linux, 2026-10-31, in stacked
[PR #295](https://github.com/berkeleynerd/silver/pull/295). On 2026-10-31, the owner
authorized continued validation and merging PR #289 followed by PR #295 after their required checks pass.
[authorization on
main](https://github.com/berkeleynerd/silver/blob/d71fff53702b7ed1a66b46c3090a6aaf326621ab/docs/session-memory.md#2026-10-31--named-subtype-and-boolean-validation-and-merge-authorized),
recorded through [PR #301](https://github.com/berkeleynerd/silver/pull/301)
(documentation commit `9f649adb2022177c097380a4f10c09ca71d10bab`). Merge
execution/results: Pending ordered execution at the validated publication checkpoint:
PR #289 first, then PR #295, under the owner authorization recorded by PR #301.
Neither feature merge is claimed by this checkpoint; the subsequent main-side handoff
records actual merge hashes and closeout.
The [delivery section](#delivery-assurance-and-validation)
identifies final inputs and evidence; earlier checkpoints retain their outcomes.
[Milestone 14](https://github.com/berkeleynerd/silver/milestone/14) contains one
coherent work package, [#291](https://github.com/berkeleynerd/silver/issues/291).
The [2026-10-30 authorization](session-memory.md#2026-10-30--boolean-scalar-objects-and-expressions-authorized)
covers implementation through complete assurance, validation, independent review
and stacked feature PR publication. That 2026-10-30 authorization excluded
feature merge; the 2026-10-31 instruction above supersedes that earlier hold.

## Selected scope

The lead driver is Rosetta
[Sequence of primes by trial division](../rosetta/s/sequence-of-primes-by-trial-division/task.wiki),
with [Square but not cube](../rosetta/s/square-but-not-cube/task.wiki) and
[Common list elements](../rosetta/c/common-list-elements/task.wiki) exercising
the same coherent feature. The delivered fragment admits initialized scalar
Boolean constants and variables, assignment, visible `True`/`False`, `not`, eager
`and`/`or`/`xor`, Boolean equality/inequality and existing short-circuit conditions.
It composes with admitted declarations, predicates, control flow, arrays and
named Integer subtypes. Stored flags retain no scalar, String or input-validity
relations; neither xor operand may contain xor.

The feature was developed on subtype
[PR #289](https://github.com/berkeleynerd/silver/pull/289) at
`fa6b5e982cad5662b18f498e75cafbac9fb07cc9`. The original planning record on `main`
did not promote that unmerged feature. [language.md](../language.md) remains
authoritative for current support.

The 4,096-byte complete-source, 63-operator and 64-leaf budgets and existing
scalar/array limits are unchanged; [language.md](../language.md) specifies exact
expression accounting. Boolean arrays, callable routines,
enumeration iteration, general enumeration types and capacity/assurance-mode
expansion remain outside this package. No Oracle amendment is introduced.

## Original semantics and design obligations

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

## Original completion and Rosetta obligations

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

## Planning round

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

This section retains intermediate results and settings at their named inputs.
The final [delivery section](#delivery-assurance-and-validation) records
complete Linux native and Lean/actual-source assurance; focused successes retain their
original scope.

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
semantics. The combined body checkpoint at that stage passed a fresh audit of 16,678
declarations with only the three approved foundations. Its Boolean helper trees
and interpretation proofs are checked, while instantiation against authoritative
source tokens remained part of the pending complete source checkpoint. These
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
snapshot is narrower. The repaired flow domain, preservation and initial-flow proofs passed focused
checks, as did the native predicate model, correspondence and contracts on that
domain. At that checkpoint the issue remained open pending consumption of the
repair by complete actual-source validation.

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

The derived Boolean declaration library and final helper libraries passed
their focused audits. The retained Compose and Sequence models also passed after
propagating the Boolean environment through their contexts and initial states.
The ordinary array declaration wrapper has a checked interpretation preserving
its original initializer value and exact Static assertion/return tokens.
The [evidence index](evidence/boolean-objects-20261030/README.md) records these
checks and the actual incremental cache transfers.

Independent admission and proof/source argument reviews found no new defect in
their stated scopes; they did not claim complete validation. The complete Lean
checkpoint on `5198f2b7b5` subsequently failed as recorded below. Regression metadata at `927cc5e178`
prepared the three Rosetta drivers and the 53-to-56 stage-1 progression while
this capability remained pending. The completed full suite and reviewed repair
reruns covered all 568 test identities (559 distinct methods), including all
55 manifest samples and 111 executions. The
[regression record](evidence/boolean-objects-20261030/full-suite/README.md) and
[independent applicability review](reviews/review-boolean-regression-37c0babc64.md)
retain the failures, exact input comparison and 565 retained plus three fresh
passing results at that input. The three subsequent Rosetta tests passed as
recorded below. Complete native proof, Lean/source validation and terminal
confirmation were still outstanding at this checkpoint. PR #295 was published
as a draft on the unchanged subtype PR.
The earlier native unit run uses pre-xor inputs and cannot establish final
assurance. At that 2026-10-30 checkpoint, neither feature PR was authorized
to merge.

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

The following records failed/interrupted checks and the repair sequence before
the final [delivery checkpoint](#delivery-assurance-and-validation).

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
source hashes and both tool hashes matched the repaired target at that stage. Native run
`20261030T194142-1f663fdf10c2` reused the same strict options/cache and four
workers, with all 2,561 preflight hashes unchanged from its predecessor. The
[evidence packet](evidence/boolean-objects-20261030/README.md) retains the recovery.
Both complete results were pending at this 2026-10-30 checkpoint. Neither
feature PR was then authorized to merge.

### Native equality-proof repair

The [native checkpoint](evidence/boolean-objects-20261030/full-native-failed-194142/README.md)
finished failed at 19:52:53 UTC after 667.844 s. GNATprove reports 17,192 checks:
1,468 flow, 15,722 proved and two unproved. Complete report/provenance auditing
did not run. The remaining checks are the exact Static equality postcondition
of `Read_Boolean_Relation_Into` and an equality-lemma precondition in the eager
chain branch of `Read_Chain_Into`. The solvers reached time/memory limits;
no counterexample was reported, and the executable reader preconditions passed.

The first candidate added checked branch equality steps and used the existing
named right-hand model value in the eager branch's ghost lemma call. Executable
behavior, complete preconditions, exact postconditions and production proof
settings were required to remain unchanged. Focused validation and independent
review were required before integration. The lead stopped the complete Lean run at
19:57:36 UTC, retaining its inputs, logs and completed objects, because the Ada
annotation repair changed its captured source. Source pins/certificates and
affected validation required refresh together after successful native repair;
this interrupted check did not establish capability completion.

The first candidate's [focused check](evidence/boolean-objects-20261030/terminal-native-repair/README.md)
failed after 1,025.978 s: all four new `Same_Condition` assertions reached
solver limits. Its downstream postcondition result depends on those unmet
assertions and is not a completed proof. This failed candidate was not integrated.
A bounded [independent diagnosis](reviews/review-boolean-equality-transport-diagnosis.md),
selected GPT-6 Astra / Max for this equality problem, identified missing
transports from Ada record equality to logical equality, including the
constrained `Expected` snapshot. The model's branch expansion was already
present. A first-branch diagnostic subsequently passed using the existing proved
equality helper under unchanged limits; it did not establish complete-reader or
chain discharge. Routine native work retained its Extra High setting.


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
confirmation remained required at this checkpoint.

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
was isolated from the running integration checkpoint at that stage.

Its matching build `20261031T022612-eb8a9047980e` passed in 8.566 s.
Complete native run `20261031T022711-e4258c225793` was launched with four
workers and the unchanged production options/cache. The selected native-first
sequence required complete success before integration and certificate refresh.
This sequencing responded to repeated native annotation repairs without adding
completion requirements. Lean run `20261030T214845-59a80335a9ac` remained on
frozen `87dd912436` inputs while checking source integration. It failed at 2026-10-31
05:26:23 UTC after 27,455.259 s managed time, including the recorded scheduling
suspension; all 687 source and two tool hashes matched. Its completed objects were
retained for ordinary cache reuse, while final-source build and fresh source/module/axiom audits
were still required at that checkpoint.

That Lean run was temporarily suspended for memory scheduling from 00:29:35
to 02:03:40 UTC, retaining its process, inputs and lease; it resumed normally.
Its large output-body certificate passed at the old source. Complete assurance
still required the final integrated source and matching output pin/certificate.
The Body_Tail delta retained the same 46 regression identities. The prepared
`87dd912436` test archive was superseded for final testing; the delivered
snapshot and actual results are identified below. At that 2026-10-31 checkpoint,
both feature PRs remained open under the earlier merge hold.

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
The same 46-test refresh and terminal applicability confirmation remained required
at that focused checkpoint; actual refresh results are recorded below.

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

The native-validated source/regression snapshot at that checkpoint was
`91de078ed81d102485c7dd286758e127630b01d6`, including the reviewed Body_Tail
source and the proof-only body-call/lint repairs above. All 143 native
source/script/project inputs match both the successful capture and its retained
archive. The output pin now contains 45,259 tokens. Regenerating all 28
certificates changed only `OutputBodyCertificate.lean`; the other 27 remain
byte-identical. This is mechanical correspondence evidence, not a replacement
for complete kernel/source checking.

Complete Lean run `20261031T062232-72f05d92e6aa` started at 06:22:35 UTC with
one worker/thread and a 24 GiB process threshold, reusing completed Lake objects.
Its captured inputs were frozen. The installed native workspace was explicitly
released after restoration for the same 46-regression refresh on a new snapshot
of this final target. All 46 [refreshed tests](evidence/boolean-objects-20261030/annotation-repair-regressions-91de078e/README.md)
passed with no skips, including the kernel fixture. All four 838-input maps
and 830 snapshot files matched before exact restoration of the 864 original
nodes; unrelated dirty files, binaries and native reports were preserved.
The mechanical inventory accounts for all 568 IDs / 559 methods as 46 refreshed
plus 522 retained results under the existing applicability reviews. Complete
Lean/source/module/axiom validation and terminal independent evidence/applicability
confirmation remained pending at this checkpoint; the delivery section below
records their actual final outcomes. No support or merge was claimed here.

### Complete Lean coverage repair and final audit — 2026-10-31

Run `20261031T062232-72f05d92e6aa` on source/regression snapshot
`91de078ed81d102485c7dd286758e127630b01d6` [finished failed](evidence/boolean-objects-20261030/source-integration/missing-audit-module/README.md) at
10:44:59 UTC. Its final-source build passed in 15,723.397 s and its fresh audit
checked 122,961 declarations with only `propext`, `Classical.choice` and
`Quot.sound` in 10.624 s. The strict whole-project coverage comparison then
reported exactly one missing standalone module,
`Silver.ComposeBooleanDeclarationCandidate`, and no unexpected module. Its
managed interval was 15,744.021 s. All 687 source and two tool hashes matched.
The successful phases did not make this a successful complete checkpoint;
the original failed result and completed objects are retained.

The only governed change from that snapshot to final implementation/proof target
`8f676fc40975781cdcaa50772d4d95f7e40054a1` is the explicit import of
`Silver.ComposeBooleanDeclarationCandidate` in `proof/Silver/Audit.lean`.
This includes its separately checked declaration-body rendering theorem while
preserving semantic/source proofs, coverage comparison, warning and axiom
policies. Native inputs, executable behavior, source pins/certificates, scripts,
tests, samples and catalogue are unchanged.

Corrected complete cached run `20261031T104817-379c11d51394`
[passed](evidence/boolean-objects-20261030/final-lean/README.md) on the final target: **572 project modules and 122,964
declarations**, with only `propext`, `Classical.choice` and `Quot.sound`, and no
missing or unexpected module. Its build took 12.052 s, fresh module/axiom audit
6.719 s and managed interval 25.155 s, using one worker/thread and a 24 GiB
per-process threshold. All 687 source and two tool hashes matched; all 28
checked-in certificates equal the generated workspace counterparts, and the
authoritative-source link resolves to the actual repository `src/`. The final
input digest is `a8ddafbfc7071b0b7f0a878e10f9f84def62aaa4303b2eaa3934026f0bd3cdf8`.

The [independent terminal review](reviews/review-boolean-closing-7560531370.md) passed with no blocker on
`7560531370904bb677e6a5e7de7aaa441c9faf50`. It confirmed the actual 572-module audit set,
native/source correspondence, all 46 refreshed results and the 568-ID / 559-method
census, and complete consumption of the #293/#294 repairs. The Audit-only import
preserves regression applicability: the kernel fixture uses `AxiomAudit`, and
the platform fixtures use mocked Lean with dynamic module inventory. The exact
native/regression snapshot and retained archive remain `91de078ed8`; these
results required no additional test run for the aggregate import.

## Delivery assurance and validation

Status: implemented and validated on Linux, 2026-10-31. Final implementation/proof
target:
`8f676fc40975781cdcaa50772d4d95f7e40054a1`; Ada profile SHA-256:
`bb3bd71eb53e7f0637ed27ac4b5eb7c283b66dc0fb81131ebe73543c3950d01f`. The terminal
independent review target is `7560531370904bb677e6a5e7de7aaa441c9faf50`. Later
record-only commits retain
their actual scope. The feature was developed against PR #289 at
`fa6b5e982cad5662b18f498e75cafbac9fb07cc9`. The owner authorized continued
validation and merging PR #289 followed by PR #295 on 2026-10-31.
[authorization on
main](https://github.com/berkeleynerd/silver/blob/d71fff53702b7ed1a66b46c3090a6aaf326621ab/docs/session-memory.md#2026-10-31--named-subtype-and-boolean-validation-and-merge-authorized),
recorded through [PR #301](https://github.com/berkeleynerd/silver/pull/301)
(documentation commit `9f649adb2022177c097380a4f10c09ca71d10bab`). Merge
execution/results: Pending ordered execution at the validated publication checkpoint:
PR #289 first, then PR #295, under the owner authorization recorded by PR #301.
Neither feature merge is claimed by this checkpoint; the subsequent main-side handoff
records actual merge hashes and closeout.
Issue and milestone handoff: At the validated publication checkpoint, #291/#293/#294
are In review pending the authorized ordered merges, and milestone 14 remains open
until delivery closeout. The completing commit uses `Fixes #291`, `Fixes #293` and
`Fixes #294`; closure occurs on main. The integration owner drives PR #289 then PR
#295 and the associated issue, milestone and board closeout under the recorded
authorization.

- Final source repair, reviewed pin and regenerated certificate: reviewed Body_Tail
  source plus body-call/lint repairs integrated in `91de078e`; the output pin contains
  45,259 tokens; regeneration of all 28 certificates changed only
  `OutputBodyCertificate.lean`, with the other 27 byte-identical; all 143 native
  inputs match the successful capture and archive. Complete final-source kernel/audit
  results remain recorded separately below.
- Matching compiler build: `20261031T022612-eb8a9047980e` passed in 8.566 s on the
  reviewed native source; all 2,561 terminal inputs matched. Compiler SHA-256
  `69006d784a7fa256c3a7bd78db22a9003e9053b199c97b8c6a82e3bbe31cb506` was verified and
  reused for regressions.
- Complete native proof, coverage and provenance audit: `20261031T022711-e4258c225793`
  passed at 2026-10-31 06:20:19 UTC: all 17,234 checks (1,468 flow and 15,766 proof),
  76 units and 1,091 entities, with strict coverage/provenance audits and all 2,561
  terminal inputs matching; 13,985.692 s managed time, using the unchanged populated
  sessions/cache and production limits.
- Complete Lean/source/module correspondence and fresh approved-axiom audit:
  complete cached Linux run `20261031T104817-379c11d51394` passed on
  `8f676fc40975781cdcaa50772d4d95f7e40054a1`: 572 project modules / 122,964
  declarations, only `propext`, `Classical.choice` and `Quot.sound`, no missing or
  unexpected module; build 12.052 s, fresh source/module/axiom audit 6.719 s, managed
  25.155 s. All 687 source and two tool hashes matched, all 28 certificates equal
  their generated counterparts, and the authoritative-source link resolves to actual
  `src/`. The [final packet](evidence/boolean-objects-20261030/final-lean/README.md)
  preserves exact inputs and reuse.
- Final regression run IDs, snapshot and terminal hashes: all 46 tests passed with no
  skips, including the kernel fixture: source 12 in `20261031T062630-15922d8efdb5`,
  platform 16 in `20261031T062757-d817703939c6`, output-integrity 17 in
  `20261031T063136-92db46acc552`, and tool/source-change 1 in
  `20261031T063241-6a51163735a4`. All four 838-input maps and 830 snapshot files
  matched before exact restoration of 864 original nodes; nine dirty-file
  hashes/modes, both binaries and all 80 native report hashes were preserved. The
  [packet](evidence/boolean-objects-20261030/annotation-repair-regressions-91de078e/README.md)
  identifies every input and outcome.
- Disjoint final coverage and retained-result applicability: mechanical reconciliation
  maps all 568 literal IDs / 559 methods without gaps or overlapping groups: 46
  refreshed plus 522 retained; equivalently 516 original-suite passes plus 52 later
  passes, including six earlier branching/maximum/Rosetta refreshes. The independent terminal review confirmed retained applicability
  after the Audit-only import; its exact result is recorded below. Failed whole runs retain their
  outcomes.
- Independent source, applicability and terminal evidence review: the [scoped
  independent terminal integration/evidence
  review](reviews/review-boolean-closing-7560531370.md) passed with no blocker on
  `7560531370904bb677e6a5e7de7aaa441c9faf50`, 2026-10-31 10:48:05–10:52:33 UTC
  (4m28s), selected GPT-6 Astra / Extra High. It checked the actual 572-module /
  122,964-declaration audit, 687 source + two tool hashes/digest, 28 certificates/src
  link, native 143-input/80-artifact/78-binding and build correspondence, all 46
  refreshed IDs without skips, retained 568-ID / 559-method applicability and complete
  #293/#294 consumption. This was read-only terminal confirmation, with no tests,
  proofs or writes; runtime confirmation and token/cost measurements are unavailable.
  It is not a whole external review or external approval.
- Technical consumption and disposition of #293/#294: the reviewed #293
  native-domain/source-consumer repair and #294 scalar-equation repair were consumed
  by complete actual-source assurance. The terminal reviewer confirmed the #293
  domain/native/source consumers and #294 `ComposeScalarDenotations` /
  `ComposeSourceBridge` in the actual 572-module audit. Issues #291/#293/#294 are In
  review pending merge; the completing commit uses `Fixes #291`, `Fixes #293` and
  `Fixes #294` so they close on main.

The [evidence packet](evidence/boolean-objects-20261030/README.md) preserves the
failed native and Lean runs, stopped/interrupted checks, scheduling suspension,
failed diagnostic candidates and cache reuse. The retained failed/interrupted native
and Lean checks, failed diagnostic candidates, host interruptions and the old
memory-scheduling suspension retain their original outcomes. Complete native success
was followed by exact final-source binding and the 46-test refresh. Run `062232`
successfully built the final source but failed strict audit coverage; the explicit
standalone-module import was then checked by successful complete cached run `104817`,
with fresh full module/axiom auditing and all terminal source/tool hashes matching.
Completed objects and native sessions/cache were reused under the existing policy.
Evidence is native Linux x86-64: complete strict native proof/coverage/provenance,
complete cached Lean build with fresh actual-source/module/approved-axiom audits,
applicable regressions and scoped internal terminal review. It contains no clean Lean
build, separate `leanchecker --fresh` replay, native macOS validation, hosted CI
result or external approval. The timings describe their named phases and reuse; they
establish no causal model-performance comparison.

Rosetta retains the precise scalar Boolean mapping for the three selected
drivers. Its neutral metadata and three renderer passes are unchanged by this
documentation update. Broad Boolean/logical-operator/Boolean-flag forms retain
remaining scope. Broad stage issues #11/#12 remain Open/Backlog at rendered stages
2/3. Only the precise scalar Boolean identifier and its three selected drivers are
promoted. Queue #296/#297/#298 remains unselected in Backlog; no next feature or
deferred capacity/assurance-mode work is started. At the validated publication
checkpoint, #291/#293/#294 are In review pending the authorized ordered merges, and
milestone 14 remains open until delivery closeout. The completing commit uses `Fixes
#291`, `Fixes #293` and `Fixes #294`; closure occurs on main. The integration owner
drives PR #289 then PR #295 and the associated issue, milestone and board closeout
under the recorded authorization.
No next capability, budget expansion or additional assurance mode is authorized.

| Round | Actual or selected settings | Result | Measurements |
| --- | --- | --- | --- |
| Final annotation repair, validation and delivery, 2026-10-31 | Integration, native verification and independent review selected GPT-6 Astra / Extra High; documentation and regressions selected GPT-6.1 Sol / High. Runtime confirmation and token/cost totals are unavailable. | Complete Linux native and Lean/actual-source assurance and applicable 568-ID / 559-method regression coverage are established; scoped independent terminal review passed with no blocker. Ordered feature merges and main-side closeout are pending at this validated publication checkpoint. | Native managed 13,985.692 s. Failed `062232`: build 15,723.397 s, audit 10.624 s. Successful `104817`: build 12.052 s, audit 6.719 s, managed 25.155 s. Four regression batches: 331.742 s unittest / 340.698 s managed; snapshot-to-restoration 448.751 s. Closing review: 10:48:05–10:52:33 UTC, 4m28s. These are distinct measured scopes, with populated caches/objects retained; no causal performance claim or whole-team cost measurement is made. |

The completed regression subthread selected GPT-6.1 Sol / High. Its four commands
used 331.742 s summed unittest time and 340.698 s summed managed time; the
snapshot-manifest-to-restoration interval was 448.751 s. Runtime confirmation
and token/cost measurements were unavailable. These measured scopes exclude
earlier planning/model time and the final Lean/review round above.
