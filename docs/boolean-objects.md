# Boolean scalar objects and expressions

Status: implementation and focused assurance in progress; not yet supported.
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

Remaining: aggregate declaration/token/header integration, the complete Compose
and Predicate actual-source joins, final native proof (including investigation
of the array-declaration Static record-equality timeout), full regression and
Lean validation, independent review, and stacked PR publication. The earlier
native unit run uses pre-xor inputs and cannot establish final assurance.

| Round | Selected settings | Result and remaining work | Measurement scope |
| --- | --- | --- | --- |
| Boolean semantic/source integration, 2026-10-30 | Existing proof/source/native subthreads: GPT-6 Astra / Extra High. Lead runtime setting and whole-team token/cost totals unavailable. | Condition validity/uniqueness, exact declaration payloads, assignment typed source and body semantic checkpoints passed; complete source/capability integration remains open. | Final combined body/helper focused build 41.019 s plus fresh audit 7.139 s; preceding development failures retained in the managed ledger. These are native tool times, not total implementation time. |
