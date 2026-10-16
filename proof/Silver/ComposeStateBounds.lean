module

public import Silver.ComposeContracts
public import Silver.ComposeScalarDeclarations

@[expose] public section

/-! Bounds and progress for the concrete composed recognizer. These are model
proofs of the existing interpretation contracts, independent of that interface's
assumed equations. -/

namespace Silver.Compose.Expressions
open Named

set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

attribute [local irreducible] ScalarExpression.read

theorem model_invalid_state_valid (text : Source) : ValidState text invalidState := by
  simp [ValidState, ValidCursor, ValidNames, NameState.Valid, invalidState, ScalarExpression.ValidEnvironment, ScalarExpression.maxBindings]

theorem model_state_position_valid (text : Source) (state : ParserState)
    (valid : ValidState text state) (position : Nat) (bound : ValidCursor text position) :
    ValidState text {state with position := position} := ⟨bound, valid.2⟩

theorem model_new_name_valid (text : Source) (state : ParserState) (first after : Nat)
    (arguments : Bool) (bound : ValidCursor text after)
    (allowed : newNameAllowed text state first after arguments = true) :
    ValidName text first after := by
  simp only [newNameAllowed, Bool.and_eq_true, decide_eq_true_eq] at allowed
  exact ⟨by omega, allowed.1.1.1.2, bound⟩

theorem model_add_binding_valid (text : Source) (state : ParserState)
    (first after : Nat) (value : ValueResult) (mutable : Bool) (following : Nat)
    (stateValid : ValidState text state) (nameValid : ValidName text first after)
    (valueValid : ValidValue text value) (followingValid : ValidCursor text following)
    (room : state.names.length < maxBindings) :
    ValidState text (addBinding state first after value mutable following) := by
  refine ⟨followingValid, ⟨?_, ?_⟩, stateValid.2.2.1, ?_, stateValid.2.2.2.2⟩
  · simp only [addBinding, List.length_append, List.length_singleton]
    omega
  · intro info member
    simp only [addBinding, List.mem_append, List.mem_singleton] at member
    rcases member with member | rfl
    · exact stateValid.2.1.2 info member
    · exact ⟨nameValid, valueValid.2.1, valueValid.2.2.1⟩
  · simp only [addBinding, List.length_append, List.length_singleton]
    have target := stateValid.2.2.2.1
    omega

theorem model_declaration_position_valid (text : Source) (state : ParserState)
    (_valid : ValidState text state) : ValidCursor text (declarationValuePosition text state) := by
  unfold declarationValuePosition
  apply model_fixed_valid
  apply model_fixed_valid
  split
  · exact model_fixed_valid text _ _ _ (model_fixed_valid text _ _ _ (model_name_valid text _))
  · exact model_fixed_valid text _ _ _ (model_name_valid text _)

theorem model_string_declaration_valid (text : Source) (valid : ValidText text)
    (state : ParserState) (arguments : Bool) (stateValid : ValidState text state) :
    ValidState text (stringDeclarationAt text state arguments) := by
  have nameBound : ValidCursor text (declarationParts text state).after := model_name_valid text _
  have resultBound : ValidResult text (declarationParts text state).value :=
    model_expression_valid (scalarNames := state.scalarNames) (integerHidden := declarationIntegerHidden text state) text valid _ state.names (model_declaration_position_valid text state stateValid) stateValid.2.1
  have followingBound : ValidCursor text (declarationParts text state).following :=
    model_fixed_valid text _ _ _ resultBound.1
  unfold stringDeclarationAt
  dsimp only
  split
  · exact model_invalid_state_valid text
  · rename_i admitted
    simp only [Bool.or_eq_true, Bool.not_eq_true', decide_eq_true_eq, not_or] at admitted
    apply model_add_binding_valid text state _ _ _ _ _ stateValid
    · apply model_new_name_valid text state _ _ arguments nameBound
      simpa using admitted.1.1.1.1
    · exact ⟨resultBound.1, by simp [ExpressionResult.value], resultBound.2.1, by simp [ExpressionResult.value], resultBound.2.2.2⟩
    · exact followingBound
    · have bound := stateValid.2.1.1
      omega

theorem model_string_declaration_advances (text : Source) (valid : ValidText text)
    (state : ParserState) (arguments : Bool) (stateValid : ValidState text state)
    (nonzero : (stringDeclarationAt text state arguments).position ≠ 0) :
    state.position < (stringDeclarationAt text state arguments).position := by
  unfold stringDeclarationAt at nonzero ⊢
  dsimp only at nonzero ⊢
  split at nonzero
  · simp [invalidState] at nonzero
  · rename_i admitted
    rw [ite_eq_right admitted]
    change state.position < (declarationParts text state).following
    change (declarationParts text state).following ≠ 0 at nonzero
    have sourceNameBound : ValidCursor text (declarationParts text state).after := model_name_valid text _
    have resultBound : ValidResult text (declarationParts text state).value :=
      model_expression_valid (scalarNames := state.scalarNames) (integerHidden := declarationIntegerHidden text state) text valid _ state.names
        (model_declaration_position_valid text state stateValid) stateValid.2.1
    have resultNonzero : (declarationParts text state).value.after ≠ 0 :=
      model_fixed_input_nonzero text _ ";" false nonzero
    have startNonzero : declarationValuePosition text state ≠ 0 :=
      model_expression_input_nonzero (scalarNames := state.scalarNames) (integerHidden := declarationIntegerHidden text state) text _ state.names resultNonzero
    have expressionForward : declarationValuePosition text state ≤ (declarationParts text state).value.after := by
      rcases model_tail_nondecreasing (scalarNames := state.scalarNames) (integerHidden := declarationIntegerHidden text state) text state.names {position := declarationValuePosition text state} with zero | forward
      · exact False.elim (resultNonzero zero)
      · exact forward
    have endingForward : (declarationParts text state).value.after < (declarationParts text state).following :=
      model_fixed_advances text _ ";" false resultBound.1 (by decide) nonzero
    simp only [Bool.or_eq_true, Bool.not_eq_true', decide_eq_true_eq, not_or] at admitted
    have nameValid : ValidName text (declarationParts text state).first (declarationParts text state).after :=
      model_new_name_valid text state _ _ arguments sourceNameBound (by simpa using admitted.1.1.1.1)
    have firstNonzero : declarationFirst text state ≠ 0 := Nat.ne_of_gt nameValid.1
    have skipped : state.position ≤ declarationFirst text state := skipAt_advances text _ stateValid.1 firstNonzero
    have nameForward : state.position < declarationAfter text state := Nat.lt_of_le_of_lt skipped nameValid.2.1
    let base := if declarationConstantAfter text state ≠ 0 then declarationConstantAfter text state
      else declarationColonAfter text state
    have colonBound : ValidCursor text (declarationColonAfter text state) :=
      model_fixed_valid text _ ":" false sourceNameBound
    have constantBound : ValidCursor text (declarationConstantAfter text state) :=
      model_fixed_valid text _ "constant" true colonBound
    have baseBound : ValidCursor text base := by
      unfold base
      split
      · exact constantBound
      · exact colonBound
    have stringBound := model_fixed_valid text base "string" true baseBound
    have stringNonzero : fixedAfter text base "string" true ≠ 0 :=
      model_fixed_input_nonzero text _ ":=" false startNonzero
    have baseNonzero : base ≠ 0 := model_fixed_input_nonzero text base "string" true stringNonzero
    have baseForward : declarationAfter text state < base := by
      unfold base at baseNonzero ⊢
      split at baseNonzero
      · rename_i constant
        rw [ite_eq_left constant]
        have colonNonzero : declarationColonAfter text state ≠ 0 :=
          model_fixed_input_nonzero text _ "constant" true constant
        have colonForward := model_fixed_advances text _ ":" false sourceNameBound (by decide) colonNonzero
        have constantForward := model_fixed_advances text _ "constant" true colonBound (by decide) constant
        exact Nat.lt_trans colonForward constantForward
      · rename_i absent
        rw [ite_eq_right absent]
        exact model_fixed_advances text _ ":" false sourceNameBound (by decide) baseNonzero
    have stringForward := model_fixed_advances text base "string" true baseBound (by decide) stringNonzero
    have valueForward : fixedAfter text base "string" true < declarationValuePosition text state :=
      model_fixed_advances text _ ":=" false stringBound (by decide) startNonzero
    exact Nat.lt_trans (Nat.lt_trans (Nat.lt_trans (Nat.lt_trans nameForward baseForward) stringForward) valueForward)
      (Nat.lt_of_le_of_lt expressionForward endingForward)

theorem model_scalar_reading_valid {text : Source} {state next : ParserState} {arguments : Bool}
    {declaration : Integer.Declaration} (stateValid : ValidState text state)
    (parsed : ScalarDeclarationAt text arguments state declaration next) : ValidState text next := by
  cases parsed with
  | @declaration parts value partsEq ready reading =>
      have nameBound : ValidCursor text parts.after := by
        rw [← partsEq]
        exact model_name_valid text _
      have nameValid := model_new_name_valid text state parts.first parts.after arguments nameBound ready.1
      have scalarBounds := ScalarExpression.syntax_bounds reading.positionBound reading.grammar
      dsimp only at scalarBounds
      have followingEq := scalarDeclarationParts_following text state
      rw [partsEq] at followingEq
      have following : ValidCursor text parts.following := by
        rw [followingEq]
        exact model_fixed_valid text parts.value.after ";" false scalarBounds.2.2
      have room : state.scalarNames.length < ScalarExpression.maxBindings := by
        have bound := stateValid.2.2.2.2.2.1
        have available := ready.2.2.2.1
        change state.scalarNames.length ≠ ScalarExpression.maxBindings at available
        omega
      have scalars := ScalarExpression.validEnvironment_append stateValid.2.2.2.2.2 room
        (item := ⟨parts.first, parts.after, parts.value.bounds, true⟩)
        ⟨nameValid.1, nameValid.2.1, nameValid.2.2, Integer.Expr.infer_bounded reading.inferred⟩
      exact ⟨following, stateValid.2.1, stateValid.2.2.1,
        stateValid.2.2.2.1, stateValid.2.2.2.2.1, scalars⟩

theorem model_scalar_declaration_valid (text : Source) (state : ParserState) (arguments : Bool)
    (stateValid : ValidState text state) : ValidState text (scalarDeclarationAt text state arguments) := by
  unfold scalarDeclarationAt
  dsimp only
  split
  · exact model_invalid_state_valid text
  · rename_i good
    have ready : ScalarDeclarationReady text state arguments (scalarDeclarationParts text state) := by
      simpa [ScalarDeclarationReady, Bool.or_eq_true, not_or, Nat.not_le, and_assoc] using good
    have nonzero : (scalarDeclarationAt text state arguments).position ≠ 0 := by
      simp only [scalarDeclarationAt, good, Bool.false_eq_true, ↓reduceIte, addScalarBinding]
      have advance := ready.2.2.1
      omega
    obtain ⟨declaration, parsed⟩ := scalar_declaration_sound text state arguments nonzero
    have valid := model_scalar_reading_valid stateValid parsed
    simpa only [scalarDeclarationAt, good, Bool.false_eq_true, ↓reduceIte] using valid

theorem model_scalar_declaration_advances (text : Source) (state : ParserState) (arguments : Bool)
    (nonzero : (scalarDeclarationAt text state arguments).position ≠ 0) :
    state.position < (scalarDeclarationAt text state arguments).position := by
  unfold scalarDeclarationAt at nonzero ⊢
  dsimp only at nonzero ⊢
  split at nonzero
  · simp only [invalidState] at nonzero
    contradiction
  · rename_i good
    rw [ite_eq_right good]
    have ready : ScalarDeclarationReady text state arguments (scalarDeclarationParts text state) := by
      simpa [ScalarDeclarationReady, Bool.or_eq_true, not_or, Nat.not_le, and_assoc] using good
    exact ready.2.2.1

theorem model_declaration_valid (text : Source) (valid : ValidText text)
    (state : ParserState) (arguments : Bool) (stateValid : ValidState text state) :
    ValidState text (declarationAt text state arguments) := by
  unfold declarationAt
  dsimp only
  split
  · exact model_scalar_declaration_valid text state arguments stateValid
  · exact model_string_declaration_valid text valid state arguments stateValid

theorem model_declaration_advances (text : Source) (valid : ValidText text)
    (state : ParserState) (arguments : Bool) (stateValid : ValidState text state)
    (nonzero : (declarationAt text state arguments).position ≠ 0) :
    state.position < (declarationAt text state arguments).position := by
  by_cases scalar : (scalarDeclarationAt text state arguments).position ≠ 0
  · have selected : declarationAt text state arguments = scalarDeclarationAt text state arguments := ite_eq_left scalar
    rw [selected]
    exact model_scalar_declaration_advances text state arguments scalar
  · have selected : declarationAt text state arguments = stringDeclarationAt text state arguments := ite_eq_right scalar
    rw [selected] at nonzero ⊢
    exact model_string_declaration_advances text valid state arguments stateValid nonzero

theorem model_dynamic_value_valid (text : Source) (following : Nat)
    (bound : ValidCursor text following) :
    ValidValue text ⟨following, 0, 0, 0, true, true, false, 0⟩ :=
  ⟨bound, by simp, by simp, by simp, by simp⟩

theorem model_argument_valid (text : Source) (valid : ValidText text)
    (state : ParserState) (stateValid : ValidState text state) :
    ValidState text (argumentAt text state) := by
  unfold argumentAt argumentParts
  dsimp only
  -- Literal bounds hold at every cursor. Abstract the long token prefix so
  -- elaboration can use that fact without repeatedly unfolding the prefix.
  generalize argumentDefaultPosition text state = position
  let following := fixedAfter text (fixedAfter text (literalAt text position).after ")" false) ";" false
  have nameBound : ValidCursor text (argumentAfter text state) := model_name_valid text _
  have fallbackBound := model_literal_valid text valid position
  have followingBound : ValidCursor text following :=
    model_fixed_valid text (fixedAfter text (literalAt text position).after ")" false) ";" false
      (model_fixed_valid text (literalAt text position).after ")" false fallbackBound.1)
  split
  · exact model_invalid_state_valid text
  · rename_i admitted
    simp only [Bool.or_eq_true, Bool.not_eq_true', decide_eq_true_eq, not_or] at admitted
    have nameValid : ValidName text (argumentFirst text state) (argumentAfter text state) :=
      model_new_name_valid text state _ _ true nameBound (by simpa using admitted.1)
    have room : state.names.length < maxBindings := by
      have empty : state.names.length = 0 := by omega
      simp [empty, maxBindings, maxSourceLength]
    have added := model_add_binding_valid text state (argumentFirst text state) (argumentAfter text state)
      ⟨following, 0, 0, 0, true, true, false, 0⟩ false following stateValid nameValid
      (model_dynamic_value_valid text following followingBound) followingBound room
    exact ⟨added.1, added.2.1, Or.inr nameValid, added.2.2.2⟩

theorem model_declarations_loop_valid (text : Source) (valid : ValidText text)
    (arguments : Bool) (fuel : Nat) (state : ParserState) (stateValid : ValidState text state) :
    ValidState text (declarationsLoop text arguments fuel state) := by
  induction fuel generalizing state with
  | zero => exact model_invalid_state_valid text
  | succ fuel ih =>
    simp only [declarationsLoop]
    split
    · exact model_invalid_state_valid text
    · split
      · exact stateValid
      · split
        · exact model_invalid_state_valid text
        · exact ih _ (model_declaration_valid text valid state arguments stateValid)

theorem model_declarations_valid (text : Source) (valid : ValidText text)
    (state : ParserState) (arguments : Bool) (stateValid : ValidState text state) :
    ValidState text (declarationsAt text state arguments) :=
  model_declarations_loop_valid text valid arguments _ state stateValid

theorem model_target_valid (text : Source) (state : ParserState) (sameTarget : Bool)
    (stateValid : ValidState text state) : ValidState text (targetAt text state sameTarget) := by
  unfold targetAt
  dsimp only
  split
  · exact model_invalid_state_valid text
  · exact ⟨model_name_valid text _, stateValid.2.1, stateValid.2.2.1,
      model_lookup_valid text state.names _ _, stateValid.2.2.2.2⟩

theorem model_dynamic_valid (text : Source) (state : ParserState)
    (stateValid : ValidState text state) : ValidState text (dynamicAt text state) := by
  unfold dynamicAt
  dsimp only
  split
  · exact model_invalid_state_valid text
  · exact model_state_position_valid text state stateValid _ (model_name_valid text _)

theorem model_assignment_valid (text : Source) (valid : ValidText text) (state : ParserState)
    (stateValid : ValidState text state) : ValidState text (assignmentAt text state) := by
  unfold assignmentAt
  dsimp only
  split <;> split
  all_goals first
    | exact model_invalid_state_valid text
    | exact model_state_position_valid text state stateValid _
        (model_expression_valid (scalarNames := state.scalarNames) text valid _ _ stateValid.1 stateValid.2.1).1

theorem model_output_valid (text : Source) (valid : ValidText text) (state : ParserState)
    (stateValid : ValidState text state) : ValidState text (outputAt text state) := by
  unfold outputAt
  dsimp only
  split
  · exact model_state_position_valid text state stateValid _
      (model_expression_valid (scalarNames := state.scalarNames) text valid _ _ stateValid.1 stateValid.2.1).1
  · exact model_invalid_state_valid text

theorem model_comparison_valid (text : Source) (valid : ValidText text) (state : ParserState)
    (stateValid : ValidState text state) : ValidState text (comparisonAt text state) := by
  have left := model_expression_valid (scalarNames := state.scalarNames) (integerHidden := false) text valid _ _ stateValid.1 stateValid.2.1
  have equalPosition := model_fixed_valid text (expressionAt text state.position state.names state.scalarNames).after "=" false left.1
  have right := model_expression_valid (scalarNames := state.scalarNames) (integerHidden := false) text valid _ _ equalPosition stateValid.2.1
  unfold comparisonAt
  dsimp only
  split
  · exact model_state_position_valid text state stateValid _ right.1
  · exact model_invalid_state_valid text

theorem model_capacity_valid (text : Source) (state : ParserState)
    (stateValid : ValidState text state) : ValidState text (capacityAt text state) := by
  unfold capacityAt
  dsimp only
  split
  · exact model_invalid_state_valid text
  · rename_i accepted
    have nonzero : (Guarded.decimalAt text (skipAt text state.position)).after ≠ 0 := by omega
    have parsed := Guarded.decimalAt_sound text (skipAt text state.position) nonzero
    have bounds := Guarded.decimalAt_bounds parsed
    exact ⟨bounds.2.1, stateValid.2.1, stateValid.2.2.1, stateValid.2.2.2.1, bounds.2.2, stateValid.2.2.2.2.2⟩

theorem model_step_valid (text : Source) (valid : ValidText text)
    (form : Form) (token : ShellToken) (state : ParserState)
    (stateValid : ValidState text state) : ValidState text (step text form token state) := by
  unfold step
  split
  · exact model_invalid_state_valid text
  · cases token with
    | contextClauses =>
      exact model_state_position_valid text state stateValid _
        (Names.contextAfter_bound text form.hasArguments)
    | fixed spelling word =>
      exact model_state_position_valid text state stateValid _
        (model_fixed_valid text _ _ _ stateValid.1)
    | declarations => exact model_declarations_valid text valid state _ stateValid
    | argumentDeclaration => exact model_argument_valid text valid state stateValid
    | assignmentTarget => exact model_target_valid text state false stateValid
    | targetReference => exact model_target_valid text state true stateValid
    | dynamicReference => exact model_dynamic_valid text state stateValid
    | assignmentValue => exact model_assignment_valid text valid state stateValid
    | outputExpression => exact model_output_valid text valid state stateValid
    | comparisonExpression => exact model_comparison_valid text valid state stateValid
    | literal => exact model_state_position_valid text state stateValid _ (model_literal_valid text valid _).1
    | capacity => exact model_capacity_valid text state stateValid

end Silver.Compose.Expressions
