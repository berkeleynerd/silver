# Static Boolean domains and package-call equations — 2026-11-22

Linux x86-64 focused run `20261122T174351-3b296ec26c5f` passed the two selected
modules and a fresh audit of 21,394 imported declarations, with only `propext`,
`Classical.choice` and `Quot.sound`. It used two managed workers and two threads
per Lean process within the shared eight-CPU allocation; elapsed evidence time
was 16.546 seconds. Compressed log and structured input evidence are retained.

`StaticBooleanSourceChecks` specifies the complete result record, default,
native headers/contracts and typed bodies. Its domain retains all native field
subtypes, the complete executable `Valid_State`, and position zero. It derives
the previously checked outer-reader state domain. Its source/denotation theorems
require an explicit actual-token witness and explicit imported/recursive calls.
No actual-source witness or exact evaluator-reading closure is supplied here.

`ApplicationPackageCallsModel` supplies raw source-ordered call equations with
completion-prefix lookup, all 585 actual and seen slots, named associations,
explicit and implicit alias checks, read/write collection, scalar updates and
visible-global widening. The accepted-stages theorem exposes its successful
raw result. Native typed interpretation, imported-call correspondence, semantic
checker connection and actual-source certification remain pending.

These are focused helper results, not complete package or compiler assurance.

## Static Boolean operands and condition execution

Linux x86-64 focus `20261127T150852-c01cef55421e` checked
`StaticBooleanPrimaryMeaning`, `StaticBooleanRelationMeaning`,
`StaticBooleanTailMeaning` and `StaticBooleanConditionExecution`. The fresh
axiom audit covered 21,329 declarations. The run used two Lake workers, two
threads and 8,192 MiB per process and took 18.183 seconds. The four committed
source files matched the recorded input hashes.
[Focused run and predecessor logs](static-boolean-execution/)

Accepted primary and factor steps recover original Boolean references,
unqualified literals, parenthesized conditions and negation. A successful
relation recovers either the two scalar source expressions with singleton
inferred bounds, the Boolean factor, or both Boolean operands and their
equality operator. In each case the static evaluator returns the original
Boolean value when the recursive operands supply their source readings.
The chain proof follows each actual operator and advancing right operand.

`runCondition_native_result` identifies the entire output, including a
failed result, with the executable condition loop under the relation
reader's cursor bound and the checked static source witness. Its recursion
decreases the remaining source span. Binding all four recursive readers and
the imported native leaves on their full domains remains open.
