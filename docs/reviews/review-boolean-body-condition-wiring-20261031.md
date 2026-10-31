# Boolean body condition wiring and source-check lint repair

Independent read-only review, 2026-10-31 05:38:02–05:39:31 UTC (1m29s).
The reviewer selected GPT-6 Astra / Extra High; runtime confirmation and
token/cost measurements were unavailable. The lead retained the returned
conclusions. The reviewer performed no edits, proofs, builds or GitHub writes.

Inputs were integration HEAD `3a83e48be1`, the terminal
[failed complete checkpoint](../evidence/boolean-objects-20261030/source-integration/failed-transports/README.md),
the actual Ada condition-reader defaults and body call sites, their Lean
interfaces/models, and the applied two-file repair. Repaired SHA-256 identities:

- `PredicateEquations.lean`:
  `fad0aae90e66f82baa21bc9e7680abf89c90b631291610d073fa7095301b76b1`.
- `PredicateSourceCandidate.lean`:
  `c64cefe67adaba18f57848da59d898466f70b9cd378df0c49567dd4f9af16426`.

No blocker was found. Ada `Conditional_Body` and `Alternative_Body` omit the
`Initials` argument when calling `Read_Condition_Into`; its default is
`Array_Bindings.Empty_Values`, an all-zero array. Lean's initializer storage is
a zero-extended list and `readCondition` defaults to `[]`. The repaired
four-argument body primitive therefore applies the arbitrary native reader to
`[]` explicitly, and its helper theorem supplies the corresponding proved
`ValidInitials []`. This matches the already-checked Boolean body helper.
The generalized native reader still accepts arbitrary valid initializer
storage; no native precondition or interpretation domain is narrowed.
The model helper's original reflexivity proof then has the intended type.

The source-candidate change removes exactly the four simplification arguments
reported unused: `Expr.declared` and `Expr.declaredCondition` from the Boolean
atom check, and `Expr.declared` from each factor/relation check. Statements,
rendered trees, token checks, strict warning handling and kernel checking are
unchanged. This review does not replace checking the repaired source candidate.

The existing 46-regression refresh remains sufficient: source/platform checks
consume the changed Lean files, and the previously selected integrity/tool
fixtures cover the Ada repair. There is no new runtime, native, script or test
dependency. Complete Lean/source/module/axiom validation and affected exposed
definition consumers remain mandatory.

Separately, the lead's focused `PredicateEquations` run
`20261031T053848-2f8f986ab6e3` passed a fresh audit of 309 modules and 91,711
declarations with only `propext`, `Classical.choice` and `Quot.sound`. Build
time was 12.881 s, audit 11.249 s, and managed time 33.356 s. All 687 source
and two tool hashes matched at terminal. Its
[evidence](../evidence/boolean-objects-20261030/source-integration/body-condition-wiring/README.md)
is focused validation, not complete feature assurance.
