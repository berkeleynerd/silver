# Interim findings — focused proof review of PR #412 (target `5a4b0ad8ac`)

Final state, updated 2026-11-22T11:41Z. `report.md` is the authoritative record;
this file keeps the candidate history.

## Blocker / medium candidates

None was recorded at any point in the review. No candidate reached blocker,
medium or low severity.

## Info-level items (all confirmed; numbering as in `report.md`)

### I1 — array value-transport and slot-disjointness lemmas are side lemmas

Recorded 11:33Z. Confirmed.

- `proof/Silver/NamedArrayParameters.lean`: `formal_disjoint` (:135),
  `bind_preserves_scalar` (:157), `bind_read` (:189), `capture_bind` (:208).
- `proof/Silver/ScalarFunctionFrame.lean`: `bindArrayArguments_preserves_before`
  (:50), `capture_bound_parameter` (:73), `capture_after_scalar_arguments` (:122).
- A whole-tree search finds no reference to any of these outside those two
  files. The endpoint path uses only range fit: `capture_of_checked_ranges`
  (`ScalarCallExecution.lean:80`) → `ArgumentsFit` → `bindArrayArguments_fits`
  (`ScalarFunctionSemantics.lean:73`, `ScalarProcedureSemantics.lean:77`), and
  `capture_put_outside` (`ScalarProcedureNoninterference.lean:215`).
- Alternative explanation checked: the endpoint might need disjoint slots to keep
  an earlier formal's range fit when a later one is bound. It does not:
  `bind_declared_fits` rewrites ranges and cells together, so `Fits` is preserved
  for any slot layout.
- Not a gap. It is the intended "full declared component interval" design.

### I2 — array-table validity equivalences and the new `validNameState` law are side lemmas

Recorded 11:20Z (as O1). Confirmed and extended 11:35Z.

- `proof/Silver/ArrayBindingsSourceBridge.lean:46–64` (`PredicatesCorrect`,
  `interpreted_predicates`), `:66–104` (`ImplementationCorrect`,
  `interpreted_complete`), `:109–115`.
- Only `PredicatesCorrect.validType` reaches the endpoint chain
  (`FunctionDeclarationFrameEquations.lean:41–52`, then
  `ProcedureDeclarationParameterLibraries.lean:172–178` for procedures).
- `ArrayBindings.Native.Primitives.validNameState`
  (`ArrayBindingsNativeEquations.lean:38–39`) is a new assumed field in this PR.
  Its only consumers are `:356–357`, `:373`, `:411`, `:427` of the same file, all
  inside the `validTypes` / `validMetadata` equivalences.
- The law equals the unchanged Ada expression function
  `Silver_Output_Lexical.Valid_Name_State` (`src/silver_output_lexical.ads:268–274`)
  on the full `Literal_Position` range. The same law was already a `Primitives`
  field of the function and procedure binding bridges at the base.

### I3 — remaining assumed leaf import laws; redundant nested re-assumption

Recorded 11:20Z (as O2). Confirmed. Unchanged convention; enumerated in
`report.md`.

### I4 — capacity: two producer routes decided on output, not source

Recorded 11:20Z (as O3), extended 11:46Z. The anti-aliasing source file and the
definitions of two type predicates (`Use_Predefined_Equality_For_Type`,
`Needs_Default_Checks_At_Decl`) are not retained. Both candidate multiplicities
are rejected on retained complete reports, and neither could change the 64 MiB
conclusion (fallback bound under 1 MiB against 17,829,120 bytes of headroom).

### I5 — ten new theorems have no reference anywhere

Recorded 11:33Z. Textual scan (`scratch/work/unused_new_theorems.py`); none
carries `@[simp]`. Housekeeping only.

## Candidates rejected during the review

See `report.md` section 5 for each with its reason: anti-aliasing records;
`installArrayView` evaluation; counted-bound gate with empty initials; default
empty type table in `catalogSignatures` / `formalModel`; procedure-path
`ArrayAppendMeaning`; `P (A, A (1))` aliasing; attributes accepted in subscript
and gate modes; formal attributes in callable-local initializers; table reads
beyond `Count`; Boolean-array-hides-type prefix; old 24-byte capacity minimum.
