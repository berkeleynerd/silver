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

After the prefix, writable formals behave like ordinary initialized mutable
scalars. The body admits existing local assignments, function-call assignments,
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
