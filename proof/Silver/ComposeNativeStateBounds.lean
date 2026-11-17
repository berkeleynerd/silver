module

public import Silver.ComposeDeclarationBounds
public import Silver.ComposeStateBounds
public import Silver.ComposeNativeValueBounds

@[expose] public section

/-! String metadata preservation for arbitrary native parser states. These
lemmas use the checked raw metadata fields, without a declaration-history or
runtime byte-store premise. -/
namespace Silver.Compose.Expressions
open Named Bindings

theorem model_string_declaration_bounds_of_result (text : Source) (state : ParserState)
    (arguments : Bool) (metadata : NamesBoundsValid state.names)
    (indices : (declarationParts text state).value.firstIndex.Bounded ∧
      (declarationParts text state).value.lastIndex.Bounded) :
    NamesBoundsValid (stringDeclarationAt text state arguments).names := by
  unfold stringDeclarationAt
  generalize partsEq : declarationParts text state = parts at indices ⊢
  dsimp only
  split
  · exact namesBoundsValid_empty
  · rename_i accepted
    apply namesBoundsValid_append metadata
    have checked : fixedDeclarationBounds parts.value (state.names.length + 1) = true := by
      cases bounds : fixedDeclarationBounds parts.value (state.names.length + 1)
      · simp [bounds] at accepted
      · rfl
    simp only [fixedDeclarationBounds, Bool.and_eq_true] at checked
    exact ⟨indices.1.1, indices.2.1, checked.2⟩

theorem model_string_declaration_bounds (text : Source) (valid : ValidText text)
    (state : ParserState) (arguments : Bool) (metadata : NamesBoundsValid state.names) :
    NamesBoundsValid (stringDeclarationAt text state arguments).names := by
  apply model_string_declaration_bounds_of_result text state arguments metadata
  rw [declarationParts_value]
  exact model_expression_index_bounds text valid _ state.names metadata

theorem model_character_declaration_bounds (text : Source) (state : ParserState)
    (arguments : Bool) (metadata : NamesBoundsValid state.names) :
    NamesBoundsValid (characterDeclarationAt text state arguments).names := by
  by_cases positive : (characterDeclarationAt text state arguments).position ≠ 0
  · obtain ⟨declaration, source⟩ := character_declaration_sound text state arguments positive
    exact character_declaration_bounds metadata source
  · unfold characterDeclarationAt
    dsimp only
    split
    · exact namesBoundsValid_empty
    · rename_i ready
      have readyFalse : characterDeclarationRejected text state arguments
          (characterDeclarationParts text state) = false := Bool.eq_false_iff.mpr ready
      have following : (characterDeclarationParts text state).following ≠ 0 := by
        intro zero
        simp [characterDeclarationRejected, zero] at readyFalse
      have successful : (characterDeclarationAt text state arguments).position ≠ 0 := by
        simp only [characterDeclarationAt, readyFalse, Bool.false_eq_true, ↓reduceIte, addBinding]
        exact following
      exact False.elim (positive successful)

theorem model_scalar_declaration_bounds (text : Source) (state : ParserState)
    (arguments : Bool) (metadata : NamesBoundsValid state.names) :
    NamesBoundsValid (scalarDeclarationAt text state arguments).names := by
  unfold scalarDeclarationAt
  dsimp only
  split
  · exact namesBoundsValid_empty
  · exact metadata

theorem model_subtype_declaration_bounds (text : Source) (state : ParserState)
    (arguments : Bool) (metadata : NamesBoundsValid state.names) :
    NamesBoundsValid (subtypeDeclarationAt text state arguments).names := by
  unfold subtypeDeclarationAt
  dsimp only
  split
  · exact namesBoundsValid_empty
  · exact metadata

theorem model_boolean_declaration_bounds (text : Source) (state : ParserState)
    (arguments : Bool) (metadata : NamesBoundsValid state.names) :
    NamesBoundsValid (booleanDeclarationAt text state arguments).names := by
  unfold booleanDeclarationAt
  dsimp only
  split
  · exact namesBoundsValid_empty
  · split
    · exact namesBoundsValid_empty
    · exact metadata

theorem model_array_declaration_bounds (text : Source) (state : ParserState)
    (arguments : Bool) (metadata : NamesBoundsValid state.names) :
    NamesBoundsValid (arrayDeclarationAt text state arguments).names := by
  unfold arrayDeclarationAt
  dsimp only
  split
  · exact namesBoundsValid_empty
  · split
    · exact namesBoundsValid_empty
    · split
      · exact namesBoundsValid_empty
      · split
        · exact namesBoundsValid_empty
        · rename_i good start positive advances
          have accepted : (arrayDeclarationAt text state arguments).position ≠ 0 := by
            simp only [arrayDeclarationAt, good, start, positive, advances, Bool.false_eq_true, ↓reduceIte]
            omega
          have preserved : NamesBoundsValid (arrayDeclarationAt text state arguments).names := by
            cases kind : (arrayDeclarationParts text state).isBoolean with
            | false =>
              obtain ⟨declaration, reading⟩ := array_declaration_sound text state arguments kind accepted
              rw [(array_declaration_preserves reading).1]
              exact metadata
            | true =>
              have reading := boolean_array_declaration_sound text state arguments kind accepted
              rw [(boolean_array_declaration_preserves reading).1]
              exact metadata
          simpa only [arrayDeclarationAt, good, start, positive, advances, Bool.false_eq_true, ↓reduceIte] using preserved

theorem model_argument_bounds (text : Source) (state : ParserState)
    (metadata : NamesBoundsValid state.names) : NamesBoundsValid (argumentAt text state).names := by
  unfold argumentAt
  dsimp only
  split
  · exact namesBoundsValid_empty
  · apply namesBoundsValid_append metadata
    simp [BindingInfo.BoundsValid, fixedBoundsValid, Integer.Interval.singleton,
      Integer.InRange, Integer.minValue, Integer.maxValue]

theorem model_declaration_bounds (text : Source) (valid : ValidText text)
    (state : ParserState) (arguments : Bool) (metadata : NamesBoundsValid state.names) :
    NamesBoundsValid (declarationAt text state arguments).names := by
  rw [declarationAt_callable_equation]
  split
  · rename_i accepted
    rw [(callableDeclarationAt_preserves_outer _ _ _ accepted).names]
    exact metadata
  · split
    · exact model_subtype_declaration_bounds text state arguments metadata
    · split
      · exact model_scalar_declaration_bounds text state arguments metadata
      · split
        · exact model_array_declaration_bounds text state arguments metadata
        · split
          · exact model_boolean_declaration_bounds text state arguments metadata
          · split
            · exact model_character_declaration_bounds text state arguments metadata
            · exact model_string_declaration_bounds text valid state arguments metadata
theorem model_declarations_loop_bounds (text : Source) (valid : ValidText text)
    (arguments : Bool) (fuel : Nat) (state : ParserState) (metadata : NamesBoundsValid state.names) :
    NamesBoundsValid (declarationsLoop text arguments fuel state).names := by
  induction fuel generalizing state with
  | zero => exact namesBoundsValid_empty
  | succ fuel ih =>
      rw [declarationsLoop]
      split
      · exact namesBoundsValid_empty
      · split
        · exact metadata
        · split
          · exact namesBoundsValid_empty
          · exact ih _ (model_declaration_bounds text valid state arguments metadata)

theorem model_declarations_bounds (text : Source) (valid : ValidText text)
    (state : ParserState) (arguments : Bool) (metadata : NamesBoundsValid state.names) :
    NamesBoundsValid (declarationsAt text state arguments).names :=
  model_declarations_loop_bounds text valid arguments _ state metadata

theorem model_target_bounds (text : Source) (state : ParserState) (sameTarget : Bool)
    (metadata : NamesBoundsValid state.names) : NamesBoundsValid (targetAt text state sameTarget).names := by
  unfold targetAt
  dsimp only
  split
  · exact namesBoundsValid_empty
  · exact metadata

theorem model_dynamic_bounds (text : Source) (state : ParserState)
    (metadata : NamesBoundsValid state.names) : NamesBoundsValid (dynamicAt text state).names := by
  unfold dynamicAt
  dsimp only
  split
  · exact namesBoundsValid_empty
  · exact metadata

theorem model_assignment_bounds (text : Source) (state : ParserState)
    (metadata : NamesBoundsValid state.names) : NamesBoundsValid (assignmentAt text state).names := by
  unfold assignmentAt
  dsimp only
  repeat' first | exact metadata | exact namesBoundsValid_empty | split

theorem model_output_bounds (text : Source) (state : ParserState)
    (metadata : NamesBoundsValid state.names) : NamesBoundsValid (outputAt text state).names := by
  unfold outputAt
  dsimp only
  split
  · exact metadata
  · exact namesBoundsValid_empty

theorem model_comparison_bounds (text : Source) (state : ParserState)
    (metadata : NamesBoundsValid state.names) : NamesBoundsValid (Compose.comparisonAt text state).names := by
  unfold Compose.comparisonAt
  dsimp only
  split
  · exact metadata
  · exact namesBoundsValid_empty

theorem model_capacity_bounds (text : Source) (state : ParserState)
    (metadata : NamesBoundsValid state.names) : NamesBoundsValid (capacityAt text state).names := by
  unfold capacityAt
  dsimp only
  split
  · exact namesBoundsValid_empty
  · exact metadata

theorem model_step_bounds (text : Source) (valid : ValidText text)
    (form : Compose.Form) (token : ShellToken) (state : ParserState)
    (metadata : NamesBoundsValid state.names) : NamesBoundsValid (Compose.step text form token state).names := by
  unfold Compose.step
  split
  · exact namesBoundsValid_empty
  · cases token with
    | contextClauses | fixed | literal => exact metadata
    | declarations => exact model_declarations_bounds text valid state _ metadata
    | argumentDeclaration => exact model_argument_bounds text state metadata
    | capacity => exact model_capacity_bounds text state metadata
    | dynamicReference => exact model_dynamic_bounds text state metadata
    | assignmentTarget => exact model_target_bounds text state false metadata
    | targetReference => exact model_target_bounds text state true metadata
    | assignmentValue => exact model_assignment_bounds text state metadata
    | outputExpression => exact model_output_bounds text state metadata
    | comparisonExpression => exact model_comparison_bounds text state metadata

end Silver.Compose.Expressions
