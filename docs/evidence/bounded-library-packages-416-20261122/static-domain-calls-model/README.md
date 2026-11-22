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
