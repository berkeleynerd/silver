module

public import Silver.ApplicationPackageMainVisibleState
public import Silver.ComposeStateBounds

@[expose] public section

namespace Silver.ApplicationPackageMain
open Compose Compose.Expressions

/-- The original metadata validation locates private state in the package body.
The application join must separately identify this metadata unit table with the
packed source units before using the Main parser's starting cursor. -/
theorem metadata_states_before_main {text : PackageBindings.Text} {info : PackageBindings.Metadata}
    (valid : PackageBindings.validMetadata text info = true) :
    ∀ state ∈ info.states, state.name.first < (info.units .mainBody).first := by
  simp only [PackageBindings.validMetadata, Bool.and_eq_true, and_assoc] at valid
  have layout := (of_decide_eq_true valid.1).2.2.2
  have allStates := List.all_eq_true.mp valid.2.2.2.2.2.2.1
  intro state member
  obtain ⟨offset, bound, item⟩ := List.mem_iff_getElem.mp member
  have declared := allStates offset (List.mem_range.mpr bound)
  simp only [PackageBindings.stateValid, Bool.and_eq_true, and_assoc] at declared
  have span := of_decide_eq_true declared.2.1
  have stateAt : info.stateAt (offset + 1) = state := by
    simp only [PackageBindings.Metadata.stateAt, Nat.add_sub_cancel,
      List.getD_eq_getElem?_getD, List.getElem?_eq_getElem bound, Option.getD_some, item]
  change (info.units .packageBody).first ≤ (info.stateAt (offset + 1)).name.first ∧
    (info.stateAt (offset + 1)).name.first < (info.stateAt (offset + 1)).name.after ∧
    (info.stateAt (offset + 1)).name.after ≤ (info.units .packageBody).after at span
  rw [stateAt] at span
  rcases layout with ⟨_, _, _, _, adjacent, _, _⟩
  omega

theorem argument_scalar_origins {text fallback : Source} {state next : ParserState}
    {first : Nat} (source : ScalarsFrom first state.scalarNames)
    (parsed : ArgumentAt text state fallback next) : ScalarsFrom first next.scalarNames := by
  cases parsed
  exact source

theorem context_scalar_origins {scan : Predicate.ScanResult} {first : Nat}
    (source : ScalarsFrom first scan.state.scalarNames) :
    ScalarsFrom first (Predicate.contextOf scan).scalarNames :=
  source.bodyEnvironment

private theorem scalar_origins {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Integer.Declaration} {first : Nat}
    (valid : ValidState text state) (start : first ≤ state.position)
    (source : ScalarsFrom first state.scalarNames)
    (parsed : ScalarDeclarationAt text arguments state declaration next) :
    ScalarsFrom first next.scalarNames := by
  cases parsed with
  | @declaration parts value partsEq ready constraint reading =>
    have named := (newNameAllowed_span text state parts.first parts.after arguments ready.1).1
    have nameEq : parts.first = skipAt text state.position := by rw [← partsEq]; rfl
    have skipped := skipAt_advances text state.position valid.1 (nameEq ▸ Nat.ne_of_gt named)
    apply source.append
    change first ≤ parts.first
    omega

private theorem object_progress {text : Source} {arguments : Bool} {state next : ParserState}
    {declaration : Bindings.Declaration} (textValid : ValidText text) (valid : ValidState text state)
    (parsed : DeclarationAt text arguments state declaration next) : state.position < next.position := by
  cases parsed with
  | string _ reading =>
    have positive := string_declaration_positive reading
    rw [← string_declaration_complete reading] at positive ⊢
    exact model_string_declaration_advances text textValid state arguments valid positive
  | character reading => exact model_character_reading_advances valid reading

private theorem callable_progress {text : Source} {arguments : Bool} {state : ParserState}
    (accepted : (callableDeclarationAt text state arguments).position ≠ 0) :
    state.position < (callableDeclarationAt text state arguments).position := by
  unfold callableDeclarationAt at accepted ⊢
  by_cases present : (functionDeclarationAt text state arguments).position ≠ 0
  · rw [ite_eq_left present]
    exact (functionDeclarationAt_position text state arguments).2.resolve_left present
  · rw [ite_eq_right present] at accepted ⊢
    exact (procedureDeclarationAt_position text state arguments).2.resolve_left accepted

/-- Every unqualified scalar added by Main's actual declaration parser starts
after the imported frame's cursor. Other declarations preserve the same scalar
table, including bodies of local functions and procedures. -/
theorem declarations_scalar_origins {text : Source} {arguments : Bool}
    {state final : ParserState} {declarations : List Bindings.Declaration} {first : Nat}
    (textValid : ValidText text) (valid : ValidState text state)
    (parsed : DeclarationsAt text arguments state declarations final)
    (start : first ≤ state.position) (source : ScalarsFrom first state.scalarNames) :
    ScalarsFrom first final.scalarNames := by
  induction parsed with
  | done => exact source
  | next _ _ _ _ _ _ _ reading _ _ ih =>
    have advance := object_progress textValid valid reading
    exact ih (model_object_reading_valid textValid valid reading) (by omega)
      ((declaration_scalarNames reading).symm ▸ source)
  | scalar _ _ _ _ reading _ _ ih =>
    have positive := scalar_declaration_positive reading
    have advance := model_scalar_declaration_advances text _ arguments
      ((scalar_declaration_complete reading).symm ▸ positive)
    rw [scalar_declaration_complete reading] at advance
    exact ih (model_scalar_reading_valid valid reading) (by omega)
      (scalar_origins valid start source reading)
  | array _ _ _ _ _ reading _ _ ih =>
    have advance := array_declaration_advances reading
    exact ih (model_array_reading_valid valid reading) (by omega)
      ((array_declaration_preserves reading).2.symm ▸ source)
  | booleanArray _ _ _ _ _ reading _ _ ih =>
    have advance := boolean_array_declaration_advances reading
    exact ih (model_boolean_array_reading_valid valid reading) (by omega)
      ((boolean_array_declaration_preserves reading).2.1.symm ▸ source)
  | boolean _ _ _ _ _ _ reading _ _ ih =>
    have advance := boolean_declaration_progress reading
    exact ih (model_boolean_reading_valid valid reading) (by omega)
      ((boolean_declaration_preserves reading).2.1.symm ▸ source)
  | subtype _ _ _ reading _ _ ih =>
    have positive := subtype_declaration_positive reading
    have advance := model_subtype_declaration_advances text _ arguments
      ((subtype_declaration_complete reading).symm ▸ positive)
    rw [subtype_declaration_complete reading] at advance
    exact ih (model_subtype_reading_valid valid reading) (by omega)
      ((subtype_declaration_preserves reading).2.1.symm ▸ source)
  | arrayType _ _ _ reading _ ih =>
    have advance := array_type_declaration_advances reading
    have kept := congrArg ParserState.scalarNames (array_type_declaration_fields reading)
    exact ih (model_array_type_reading_valid valid reading) (by omega) (kept.symm ▸ source)
  | callable _ _ accepted _ ih =>
    have advance := callable_progress accepted
    exact ih (model_callable_declaration_valid textValid valid) (by omega)
      ((callableDeclarationAt_preserves_outer _ _ _ accepted).scalarNames.symm ▸ source)

end Silver.ApplicationPackageMain
