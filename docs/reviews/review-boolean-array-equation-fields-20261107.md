# Boolean helper equation fields: bounded review — 2026-11-07

**Diagnosis confirmed; the proposed named-field repair is appropriate. Kernel
checking remains pending.** No theorem, domain, source requirement or proof
premise needs to change. The active complete run's captured file was not edited.

Review baseline: `1b4ab33131afb1b7035a8489f6e699e1e63264cc`. Exact target:

- Original `proof/Silver/ComposeSourceBridge.lean` SHA-256:
  `350c87778672d88188ffa1db4e8b394812c3ac485826695a6c0e869cd4fc3de0`.
- Proposed replacement `tmp/ComposeSourceBridge-field-repair.lean` SHA-256:
  `3bb85bcd32810ecc243166b148c97b98fafb72227fe4cb17d021f2d82da9416a`.
- [Retained exact patch](../evidence/boolean-arrays-20261106/final-review/equation-fields-reviewed.patch),
  [failure-goal excerpt](../evidence/boolean-arrays-20261106/final-review/equation-fields-failure-excerpt.log)
  and [input/dependency inventory](../evidence/boolean-arrays-20261106/final-review/equation-fields-inputs.json).

Selected reviewer: **GPT-6 Astra / Extra High**. Runtime confirmation and
token/cost measurements are unavailable. UTC inspection through candidate/body
comparison: **2026-11-07 02:42:56–02:43:43**, 47 seconds. Subsequent record
preparation is separate. No proof, native, test or GitHub jobs were started;
only this report and its owned evidence were written.

## Diagnosis and proposed correction

`ComposeContracts.HelperEquations` declares `booleanInitializer` before
`booleanDeclaration`. The existing `interpreted_equations` construction lists
named holes in the opposite order, then supplies two positional bullet proofs.
The actual Lean diagnostics demonstrate the resulting assignment of goals:

1. The declaration bullet fills the initializer field. Its `arguments` and
   `ready` names therefore bind the initializer's `position` and `maskFirst`,
   both `Nat`. This explains the reported Nat-versus-Bool arguments and the
   nonexistent `Nat.base` projection.
2. The initializer bullet fills the declaration field. The recorded `refine_2`
   context has `position : Ty.truth.meaning`, `first : NativeState ...`, and the
   goal is the Boolean **declaration** equation. The remaining initializer
   `intro` binders consequently exceed the actual goal's binders.

The candidate constructs the same record with `exact { ... }`, placing each
existing proof directly inside `booleanDeclaration := by ...` or
`booleanInitializer := by ...`. Its correctness no longer depends on positional
ordering of the generated field goals. Independent text comparisons establish
that both corresponding proof bodies are identical after whitespace
normalization and that every byte outside the record construction is unchanged.

The declaration proof still derives its equation from the checked declaration
interpretation and `BooleanDeclarationNative.Libraries.imports_meaning`, using
the same raw helper equations, helper meanings, definitions, contracts, links
and `ready.base`. The initializer proof retains the full state, cursor and
masked-name requirements and the same initializer-library derivation. The
`HelperEquations` field statements and `interpreted_equations` theorem statement
are unchanged. No parser equality becomes an assumed premise; no obligation,
source check or trusted assumption is removed or weakened.

## Regression applicability and outstanding validation

This proposed third proof-file delta does not invalidate the earlier composed
regression successes. Neither `ComposeSourceBridge` nor the two repaired flag
modules belongs to the retained native certificate fixture's actual six-module
closure: `Lexical`, `Admission`, `Cursor`, `SourceLexer`, `CertificateWitness`
and `AxiomAudit`. Those modules, the generator and fixture inputs remain
unchanged. Other real-proof regression readers inspect imports, `module` and
`include_str` occurrences; all those projections are identical in the candidate.
Native/application inputs and synthetic Lean fixtures are unchanged.

The broader retained 802-file selection **does include** `ComposeSourceBridge`.
If this exact candidate is integrated after the two flag repairs, 799 of those
802 captured files will match. Reuse rests on the inspected actual dependencies,
not a claim of whole-capture equality. No additional regression method becomes
uncovered, and a repeated certificate fixture/full-suite run is not required for
this proof-only delta.

Complete run `20261107T014623-e873505c3c30` has reported this module failure while
other scheduled work continues; this report does not assert a terminal outcome
or relabel the run successful. After that frozen run reaches terminal state,
the exact candidate still needs integration, a successful focused bridge check
with normal dependency validation, and the required complete final
Lean/source/module/axiom checkpoint. The final committed target and metadata
follow-up must then be confirmed separately. Earlier review targets/verdicts
remain unchanged; no full feature or merge approval follows from this report.
