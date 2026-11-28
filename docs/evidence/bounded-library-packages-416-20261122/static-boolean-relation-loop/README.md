# Static Boolean relation and loop typed interpretation — 2026-11-22

Focused run `20261122T172453-afa5538eae9d` passed both complete targets
`Silver.StaticBooleanRelationNative` and `Silver.StaticBooleanLoopNative`, then
freshly audited **13,598 declarations**. Foundations were only `propext`,
`Classical.choice`, and `Quot.sound`. Linux x86-64, pinned Lean, two Lake workers
and two threads per process, CPU affinity 6–7 within the shared eight-CPU host;
19.951 seconds in the managed record (21.401 seconds in the runner evidence).
Matching dependencies were reused; this was not a clean
build, independent kernel replay, complete source audit or native proof.

The Relation tree includes every declaration, imported argument, assignment,
ordered scalar/Boolean branch, six-way scalar comparison case, rejection and
return. Its complete denotation holds for every imported-call interpretation,
recursive factor reader and initial local frame. Uninitialized local values are
arbitrary and cannot determine the result before their assignments.

The condition tree includes native declarations, the initial rejection, selected
operator, while guard, both proof annotations, each loop branch/update and the
trailing return. Its finite operational execution is equivalent in both directions
to the exact `TailExec`/`ConditionExec` equations. No arbitrary fuel cutoff is
interpreted as rejection. The previously checked model supplies uniqueness and
termination under the native result-cursor bound. Render well-formedness checks
cover expression precedence and actual record-field prefixes.

This completes typed executable trees for all four Static_Boolean helpers with
the earlier Primary/Factor commit `28539c613d`. Concrete imported-call witnesses,
full native argument/contract bindings, actual source-token correspondence, and
the admitted-reading/exact-evaluator argument remain outstanding. In particular,
Static success alone does not imply Predicate admission for arbitrary Valid_State
inputs with cross-table shadowing; the initializer also checks the ordinary
Boolean reader and equal endpoints. No disjointness assumption was introduced.

Failed focused attempts are retained separately in managed history and the
compressed event records here. They exposed constructor names shadowing pattern
binders, a record-update continuation syntax issue, and an overbroad `apply_ite`
simplification. The final proof names local constructors unambiguously, keeps
arbitrary initial locals, and splits the four actual loop tests explicitly.
No failed result was promoted and no theorem was weakened to complete the check.
