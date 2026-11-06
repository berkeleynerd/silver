# Fixed-size Boolean arrays

**Selected next on 2026-11-06; implementation unstarted.**
[Milestone 19](https://github.com/berkeleynerd/silver/milestone/19) contains the
existing [#297](https://github.com/berkeleynerd/silver/issues/297) as one cohesive
work package. This planning record admits no new source forms.

## Authorization and bounded scope

The owner instructed **“Please merge it if it is ready and proceed to the next
unit of work.”** Ready PR #332 has merged; the
[dated authorization](session-memory.md#2026-11-06--structural-guards-merged-boolean-arrays-selected-next)
identifies #297 from the recorded next-feature queue. The owner did not explicitly
name its issue number. Keep #297 Backlog until that dated record reaches main;
then use the ordinary Ready/claim workflow. Planning publication/merge and
implementation through reviewable publication are authorized. Implementation
merge remains a later owner decision.

Extend the fixed-array foundation to initialized, statically bounded,
one-dimensional arrays of predefined Boolean, with constant/mutable objects,
indexed reads and mutable component writes. Reuse existing Boolean expressions,
Integer index expressions, declaration ordering, finite control flow and
snapshot/update behavior. Sieve of Eratosthenes and elementary cellular automata
are candidate Rosetta drivers, subject to faithful bounded implementations.
The current [language](../language.md) remains authoritative until delivery.

Preserve the 4,096-byte complete-source limit, existing expression and
source-derived storage budgets, Oracle guarantees, native Bronze/Silver
verification and Lean actual-source correspondence. No general containers,
dynamic/multidimensional arrays, new array-wide operations, callable routines,
capacity rewrite or Oracle amendment is selected. Functions #298 and the separate
#300 sample batch retain their existing scope.

## Admission and implementation obligations

Settle these concrete questions during bounded design, rather than treating them
as new owner approval gates:

- Specify the exact Boolean-array declaration, explicit aggregate, indexed read
  and indexed write grammar. Prefer reuse of the current positional aggregate
  and singleton association rules; assess any proposed shorthand against the
  existing source-derived component bound before admitting it. Do not silently
  add `others` or Boolean element iteration.
- Resolve predefined `Boolean`, `True` and `False` by existing Ada visibility and
  name hiding. Specify shared declaration uniqueness and loop-binder shadowing,
  initialization typing and declaration order; exclude self/forward references.
- Define exact declaration-time values, immutable snapshots and body-level
  stored-flag semantics. Reading a stored Boolean cell must not revive scalar,
  String or input-validity relations from its initializer or earlier assignment.
  Writes update exactly the selected cell, preserve other cells and bounds, and
  compose with repeated loop iterations and incoming-state RHS/index evaluation.
- Retain the current nonempty static bounds, safe inferred index intervals and
  checks in dead arms and empty loops. State the exact existing index grammar
  and nested-array-read exclusion. Account for Boolean cells and index operands
  in the existing expression/storage budgets and preserve conservative Integer
  component behavior alongside Boolean storage.
- Establish correct eager and short-circuit evaluation of Boolean component
  expressions, including unsafe operand rejection, guard facts, mutation,
  constants, name hiding and loop compositions. Do not derive index safety from
  stored flag values without an existing sound rule.

Inspect the actual native producer obligations and reports before choosing
representation or report-policy changes. Extend the affected SPARK implementation
and native verification together with Lean membership, semantics, composition,
termination, universal safety, automatic-discharge and actual-source arguments.
Preserve the author's exact admitted/proved/compiled source; successful examples
or accepted reports alone do not establish these universal claims.

## Completion and evidence

1. Integrate exact decidable admission rules, implementation and universal/native/
   Lean actual-source assurance for the entire resulting language and permitted
   compositions. Preserve existing source/token/structural checks, complete
   obligation coverage and documented trusted-boundary assumptions.
2. Add focused acceptance, rejection and boundary tests for aggregates, bounds,
   typing, visibility, constants, declaration snapshots, indexed updates, eager
   versus short-circuit safety, loop persistence, dead code and interactions
   with current String/Character/Integer/Boolean features. Select faithful bounded
   driver samples with asserted outputs before claiming Rosetta gains.
3. Update language, catalogue, samples, roadmap capability status and this record
   together. Reconcile the exact delivered Rosetta fragment with broad `arrays`
   stage #12; use a precise supported identifier or refined assessments rather
   than claiming general arrays. Update assessor current-language text and review
   metadata, re-render and maintain stage bookkeeping under
   [planning](planning.md#rosetta-progression).
4. On stable integrated inputs complete required native verification/audit/build,
   Lean/source/module/axiom checks and applicable complete regressions. Use
   [managed proof iteration](proof-iteration.md), read the run summary first,
   coordinate worker/memory reservations, retain failed outcomes and reuse
   successful evidence only when exact input applicability holds. Changed native
   and proof semantics require corresponding refreshed evidence; the preceding
   proof-only package's retained native result is not Boolean-array validation.
5. Resolve independent critical review of admission, semantic/source
   correspondence and complete resulting-language assurance. Retain exact
   implementation/review/evidence identities, material findings and dispositions,
   then publish the reviewable implementation PR. A partial increment does not
   complete #297; split issues in the same planning step if separate increments
   become necessary.

## Planning round — 2026-11-06

The bounded planning subthread selected GPT-6.1 Sol / High; runtime model/effort
confirmation and token/cost measurements are unavailable. Its deliverable is
the preceding-package closeout and this modest next-feature authorization
record, issue/milestone reconciliation and planning PR. This round changes only
documentation, performs link/consistency and whitespace checks, and runs no
native proof, Lean build or application test. Exact design assessment is a
separate bounded subthread; no new language capability or assurance result is
claimed here. No CLI recall entry was updated.
