# Boolean initializer flow-domain review

Review date: 2026-10-30. Inputs: integration commit `201d7e7cfc`, especially
`PredicateConditionFlowValidity.lean`, `PredicateFlowInvariant.lean`,
`PredicateNativeState.lean`, and `silver_output_profile.adb`'s `Valid_Context`
and `Valid_Flow`. The pending Compose token/header edits do not affect this
finding. The source-integration subthread identified the mismatch; the native
subthread independently checked the Ada clauses. Both selected GPT-6 Astra /
Extra High. Runtime-confirmed settings and separate review time/token/cost
measurements are unavailable.

## R1 — Initializer flow interpretation narrows the native precondition

**Blocker for completing #291's actual-source assurance.** Native `Valid_Flow`
requires each mutable cell's nonempty facts to fit its `Declared_Bounds`.
Lean `ScalarMetadata.FlowReady.contained` instead requires containment in
`analysis names declarations |>.declared`, which uses each cell's `bounds`.
In body mode `BaseReady` equates mutable bounds with declared bounds, so the
existing body argument is unaffected. `ContextReady` deliberately drops that
equality in elaboration mode, where `bounds` retain the initializer snapshot.

For example, a mutable cell with snapshot `[0,0]`, declared bounds `[0,10]`,
elaboration enabled, and flow facts `[5,5]` satisfies the native containment
clause and fails the old Lean clause. The actual initial flow being `[0,0]`
does not repair an interpretation advertised for the complete native helper
precondition. No rejected admitted program or incorrect runtime result has
been demonstrated; the defect is in the unpublished feature's correspondence
domain.

The repair must express native containment using mutable declared bounds and
immutable snapshot bounds, preserve the complete native domain, and prove its
relationship to the semantic ranges under body readiness. Adapt preservation,
widening, initializer construction and their consumers, then check the native
condition interpretation and complete authoritative source chain. No Ada
restriction, native precondition tightening, obligation suppression or Oracle
amendment is warranted. The finding remains open until that assurance passes.
