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
