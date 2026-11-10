module

public import Silver.ComposeContracts
public import Silver.FunctionDeclarationValidity
public import Silver.ProcedureDeclarationValidity
public import Silver.ComposeScalarDeclarations
public import Silver.ComposeArrayElaboration
public import Silver.ComposeBooleanArrayElaboration
public import Silver.ComposeBooleanDeclarations
public import Silver.ComposeObjectDeclarations
public import Silver.ComposeCharacterBounds

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
  simp [ValidState, ValidCursor, ValidNames, NameState.Valid, invalidState, ScalarExpression.ValidEnvironment, ScalarExpression.maxBindings, ArrayBindings.ValidEnvironment, ArrayBindings.ValidMetadata, ArrayBindings.ValidInitials,
    IntegerSubtypes.ValidEnvironment, IntegerSubtypes.maxBindings,
    BooleanBindings.ValidEnvironment, BooleanBindings.maxBindings,
    FunctionBindings.ValidMetadata, FunctionBindings.maxFormals, FunctionBindings.maxFunctions,
    ProcedureBindings.ValidMetadata, ProcedureBindings.maxFormals, ProcedureBindings.maxProcedures]

theorem model_state_position_valid (text : Source) (state : ParserState)
    (valid : ValidState text state) (position : Nat) (bound : ValidCursor text position) :
    ValidState text {state with position := position} := ⟨bound, valid.2⟩

theorem model_new_name_valid (text : Source) (state : ParserState) (first after : Nat)
    (arguments : Bool) (bound : ValidCursor text after)
    (allowed : newNameAllowed text state first after arguments = true) :
    ValidName text first after := by
  have span := newNameAllowed_span text state first after arguments allowed
  exact ⟨by omega, span.2, bound⟩

theorem model_add_binding_valid (text : Source) (state : ParserState)
    (first after : Nat) (value : ValueResult) (mutable : Bool) (following : Nat)
    (stateValid : ValidState text state) (nameValid : ValidName text first after)
    (valueValid : ValidValue text value) (followingValid : ValidCursor text following)
    (room : state.names.length < maxBindings) (characterObject : Bool := false) :
    ValidState text (addBinding state first after value mutable following characterObject) := by
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
    model_expression_valid (scalarNames := state.scalarNames) (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true) (integerHidden := declarationIntegerHidden text state) text valid _ state.names (model_declaration_position_valid text state stateValid) stateValid.2.1
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
      simpa using admitted.1.1.1.1.1
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
      model_expression_valid (scalarNames := state.scalarNames) (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true) (integerHidden := declarationIntegerHidden text state) text valid _ state.names
        (model_declaration_position_valid text state stateValid) stateValid.2.1
    have resultNonzero : (declarationParts text state).value.after ≠ 0 :=
      model_fixed_input_nonzero text _ ";" false nonzero
    have startNonzero : declarationValuePosition text state ≠ 0 :=
      model_expression_input_nonzero (scalarNames := state.scalarNames) (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true) (integerHidden := declarationIntegerHidden text state) text _ state.names resultNonzero
    have expressionForward : declarationValuePosition text state ≤ (declarationParts text state).value.after := by
      rcases model_tail_nondecreasing (scalarNames := state.scalarNames) (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true) (integerHidden := declarationIntegerHidden text state) text state.names {position := declarationValuePosition text state} with zero | forward
      · exact False.elim (resultNonzero zero)
      · exact forward
    have endingForward : (declarationParts text state).value.after < (declarationParts text state).following :=
      model_fixed_advances text _ ";" false resultBound.1 (by decide) nonzero
    simp only [Bool.or_eq_true, Bool.not_eq_true', decide_eq_true_eq, not_or] at admitted
    have nameValid : ValidName text (declarationParts text state).first (declarationParts text state).after :=
      model_new_name_valid text state _ _ arguments sourceNameBound (by simpa using admitted.1.1.1.1.1)
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
  | @declaration parts value partsEq ready constraint reading =>
      have nameBound : ValidCursor text parts.after := by
        rw [← partsEq]
        exact model_name_valid text _
      have nameValid := model_new_name_valid text state parts.first parts.after arguments nameBound ready.1
      have scalarBounds := reading.cursorBounds
      have followingEq := scalarDeclarationParts_following text state
      rw [partsEq] at followingEq
      have following : ValidCursor text parts.following := by
        rw [followingEq]
        exact model_fixed_valid text parts.value.after ";" false scalarBounds.2.2
      have room : state.scalarNames.length < ScalarExpression.maxBindings := by
        have bound := stateValid.2.2.2.2.2.1.1
        have available := ready.2.2.2.2.1
        change state.scalarNames.length ≠ ScalarExpression.maxBindings at available
        omega
      have scalars := ScalarExpression.validEnvironment_append stateValid.2.2.2.2.2.1 room
        (item := ⟨parts.first, parts.after, parts.value.bounds, decide (parts.constantAfter ≠ 0) && parts.value.isStatic, parts.constraint.bounds, decide (parts.constantAfter = 0)⟩)
        ⟨nameValid.1, nameValid.2.1, nameValid.2.2, Integer.Expr.infer_bounded reading.inferred,
          constraint.bounded stateValid.2.2.2.2.2.2.2.1⟩
      exact ⟨following, stateValid.2.1, stateValid.2.2.1,
        stateValid.2.2.2.1, stateValid.2.2.2.2.1, scalars, stateValid.2.2.2.2.2.2⟩

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
      have advance := ready.2.2.2.1
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
    exact ready.2.2.2.1

theorem model_array_reading_valid {text : Source} {state next : ParserState} {arguments : Bool}
    {declaration : Integer.ArrayDeclaration} (stateValid : ValidState text state)
    (parsed : ArrayDeclarationAt text arguments state declaration next) : ValidState text next := by
  have arrays := array_declaration_array_valid parsed stateValid.2.2.2.2.2.2.1
    stateValid.2.2.2.2.2.2.2.1
  cases parsed with
  | declaration _ _ _ _ _ _ values following _ =>
      have fields := arrayValues_fields values
      refine ⟨?_, ?_, ?_, ?_, ?_, ?_, arrays, ?_, ?_⟩
      · rw [following]
        exact fixedAfter_result_bound text _ ";" false (by decide)
      · rw [show _ = state.names from congrArg (fun s => s.names) fields]
        exact stateValid.2.1
      · rw [show _ = state.dynamicFirst from congrArg (fun s => s.dynamicFirst) fields,
          show _ = state.dynamicAfter from congrArg (fun s => s.dynamicAfter) fields]
        exact stateValid.2.2.1
      · rw [show _ = state.target from congrArg (fun s => s.target) fields,
          show _ = state.names from congrArg (fun s => s.names) fields]
        exact stateValid.2.2.2.1
      · rw [show _ = state.capacity from congrArg (fun s => s.capacity) fields]
        exact stateValid.2.2.2.2.1
      · rw [show _ = state.scalarNames from congrArg (fun s => s.scalarNames) fields]
        exact stateValid.2.2.2.2.2.1
      · rw [show _ = state.subtypeNames from congrArg (fun s => s.subtypeNames) fields]
        exact stateValid.2.2.2.2.2.2.2.1
      · rw [show _ = state.booleanNames from congrArg (fun s => s.booleanNames) fields,
          show _ = state.functions from congrArg (fun s => s.functions) fields,
          show _ = state.firstParameter from congrArg (fun s => s.firstParameter) fields,
          show _ = state.procedures from congrArg (fun s => s.procedures) fields,
          show _ = state.firstProcedureParameter from congrArg (fun s => s.firstProcedureParameter) fields]
        exact stateValid.2.2.2.2.2.2.2.2

theorem model_boolean_array_reading_valid {text arguments state next}
    (stateValid : ValidState text state)
    (parsed : BooleanArrayDeclarationAt text arguments state next) : ValidState text next := by
  have arrays := boolean_array_declaration_array_valid parsed stateValid.2.2.2.2.2.2.1
  have fields := boolean_array_declaration_fields parsed
  have position : ValidCursor text next.position := by
    cases parsed with
    | declaration _ _ _ _ _ _ _ following _ =>
        rw [following]
        exact fixedAfter_result_bound text _ ";" false (by decide)
  rw [fields]
  exact ⟨position, stateValid.2.1, stateValid.2.2.1, stateValid.2.2.2.1,
    stateValid.2.2.2.2.1, stateValid.2.2.2.2.2.1, arrays,
    stateValid.2.2.2.2.2.2.2.1, stateValid.2.2.2.2.2.2.2.2⟩

theorem model_array_declaration_valid (text : Source) (state : ParserState) (arguments : Bool)
    (stateValid : ValidState text state) : ValidState text (arrayDeclarationAt text state arguments) := by
  unfold arrayDeclarationAt
  dsimp only
  split
  · exact model_invalid_state_valid text
  · split
    · exact model_invalid_state_valid text
    · split
      · exact model_invalid_state_valid text
      · split
        · exact model_invalid_state_valid text
        · rename_i good start positive advances
          have accepted : (arrayDeclarationAt text state arguments).position ≠ 0 := by
            simp only [arrayDeclarationAt, good, start, positive, advances, Bool.false_eq_true, ↓reduceIte]
            omega
          have valid : ValidState text (arrayDeclarationAt text state arguments) := by
            by_cases kind : (arrayDeclarationParts text state).isBoolean = true
            · exact model_boolean_array_reading_valid stateValid
                (boolean_array_declaration_sound text state arguments kind accepted)
            · obtain ⟨declaration, reading⟩ := array_declaration_sound text state arguments
                (Bool.eq_false_iff.mpr kind) accepted
              exact model_array_reading_valid stateValid reading
          simpa only [arrayDeclarationAt, good, start, positive, advances, Bool.false_eq_true, ↓reduceIte] using valid

theorem model_array_declaration_advances (text : Source) (state : ParserState) (arguments : Bool)
    (positive : (arrayDeclarationAt text state arguments).position ≠ 0) :
    state.position < (arrayDeclarationAt text state arguments).position := by
  by_cases kind : (arrayDeclarationParts text state).isBoolean = true
  · exact boolean_array_declaration_advances (boolean_array_declaration_sound text state arguments kind positive)
  · obtain ⟨declaration, reading⟩ := array_declaration_sound text state arguments (Bool.eq_false_iff.mpr kind) positive
    exact array_declaration_advances reading

theorem model_subtype_reading_valid {text arguments state next}
    (stateValid : ValidState text state)
    (parsed : SubtypeDeclarationAt text arguments state next) : ValidState text next := by
  have subtypes := subtype_declaration_valid parsed stateValid.2.2.2.2.2.2.2.1
  cases parsed with
  | declaration partsEq _ _ =>
      refine ⟨?_, stateValid.2.1, stateValid.2.2.1, stateValid.2.2.2.1,
        stateValid.2.2.2.2.1, stateValid.2.2.2.2.2.1, stateValid.2.2.2.2.2.2.1, subtypes, stateValid.2.2.2.2.2.2.2.2⟩
      rw [← partsEq]
      exact fixedAfter_result_bound text _ ";" false (by decide)

theorem model_subtype_declaration_valid (text : Source) (state : ParserState) (arguments : Bool)
    (stateValid : ValidState text state) : ValidState text (subtypeDeclarationAt text state arguments) := by
  by_cases positive : (subtypeDeclarationAt text state arguments).position ≠ 0
  · exact model_subtype_reading_valid stateValid (subtype_declaration_sound text state arguments positive)
  · unfold subtypeDeclarationAt
    dsimp only
    split
    · exact model_invalid_state_valid text
    · rename_i good
      have ready : SubtypeDeclarationReady text state arguments (subtypeDeclarationParts text state) := by
        simpa [SubtypeDeclarationReady, Bool.or_eq_true, not_or, Nat.not_le, and_assoc] using good
      have advance := ready.2.2.2.2.2.2.1
      simp only [subtypeDeclarationAt, good, Bool.false_eq_true, ↓reduceIte, addSubtypeBinding] at positive
      omega

theorem model_subtype_declaration_advances (text : Source) (state : ParserState) (arguments : Bool)
    (positive : (subtypeDeclarationAt text state arguments).position ≠ 0) :
    state.position < (subtypeDeclarationAt text state arguments).position := by
  unfold subtypeDeclarationAt at positive ⊢
  dsimp only at positive ⊢
  split at positive
  · simp only [invalidState] at positive
    contradiction
  · rename_i good
    rw [ite_eq_right good]
    have ready : SubtypeDeclarationReady text state arguments (subtypeDeclarationParts text state) := by
      simpa [SubtypeDeclarationReady, Bool.or_eq_true, not_or, Nat.not_le, and_assoc] using good
    exact ready.2.2.2.2.2.2.1

theorem model_boolean_reading_valid {text arguments state next}
    (stateValid : ValidState text state)
    (parsed : BooleanDeclarationAt text arguments state next) : ValidState text next := by
  cases parsed with
  | declaration ready advance =>
      simp only [booleanDeclarationReady, Bool.and_eq_true, decide_eq_true_eq] at ready
      have allowed : newNameAllowed text state (booleanDeclarationParts text state).first
          (booleanDeclarationParts text state).after arguments = true := by
        exact ready.1.1.1.1.1.1.1
      have nameBound : ValidCursor text (booleanDeclarationParts text state).after := model_name_valid text _
      have nameValid := model_new_name_valid text state _ _ arguments nameBound allowed
      have room : state.booleanNames.length < BooleanBindings.maxBindings := by
        have bound := stateValid.booleans.1
        have available : state.booleanNames.length ≠ BooleanBindings.maxBindings := by
          exact ready.1.1.1.1.1.1.2.2.2
        omega
      have booleans := BooleanBindings.valid_append stateValid.booleans room
        (item := ⟨(booleanDeclarationParts text state).first, (booleanDeclarationParts text state).after,
          decide ((booleanDeclarationParts text state).constantAfter = 0)⟩) nameValid
      exact ⟨fixedAfter_result_bound text _ ";" false (by decide), stateValid.2.1,
        stateValid.2.2.1, stateValid.2.2.2.1, stateValid.2.2.2.2.1,
        stateValid.2.2.2.2.2.1, stateValid.2.2.2.2.2.2.1, stateValid.2.2.2.2.2.2.2.1, booleans,
        stateValid.2.2.2.2.2.2.2.2.2⟩

theorem model_boolean_declaration_valid (text : Source) (state : ParserState) (arguments : Bool)
    (stateValid : ValidState text state) : ValidState text (booleanDeclarationAt text state arguments) := by
  unfold booleanDeclarationAt
  dsimp only
  split
  · exact model_invalid_state_valid text
  · rename_i ready
    split
    · exact model_invalid_state_valid text
    · rename_i advance
      have good : booleanDeclarationReady text state arguments (booleanDeclarationParts text state) = true := by
        cases value : booleanDeclarationReady text state arguments (booleanDeclarationParts text state) <;> simp_all
      exact model_boolean_reading_valid stateValid (.declaration good (Nat.lt_of_not_ge advance))

theorem model_boolean_declaration_advances (text : Source) (state : ParserState) (arguments : Bool)
    (positive : (booleanDeclarationAt text state arguments).position ≠ 0) :
    state.position < (booleanDeclarationAt text state arguments).position :=
  boolean_declaration_progress (boolean_declaration_sound text state arguments positive)

theorem model_character_reading_valid {text : Source} {state next : ParserState} {arguments : Bool}
    {declaration : Bindings.Declaration} (stateValid : ValidState text state)
    (parsed : CharacterDeclarationAt text arguments state declaration next) : ValidState text next := by
  cases parsed with
  | @declaration parts value partsEq ready following source =>
      have nameBound : ValidCursor text parts.after := by
        rw [← partsEq]
        exact model_name_valid text _
      have allowed : newNameAllowed text state parts.first parts.after arguments = true := by
        cases checked : newNameAllowed text state parts.first parts.after arguments with
        | true => rfl
        | false => simp [characterDeclarationRejected, checked] at ready
      have room : state.names.length < maxBindings := by
        have notFull : state.names.length ≠ maxBindings := by
          intro full
          simp [characterDeclarationRejected, full] at ready
        have count := stateValid.2.1.1
        omega
      have followingBound : ValidCursor text parts.following := by
        rw [← partsEq]
        exact fixedAfter_result_bound text _ ";" false (by decide)
      exact model_add_binding_valid text state parts.first parts.after parts.value
        (decide (parts.constantAfter = 0)) parts.following stateValid
        (model_new_name_valid text state _ _ arguments nameBound allowed)
        (character_value_valid source stateValid.2.1.1) followingBound room true

theorem model_character_declaration_valid (text : Source) (state : ParserState) (arguments : Bool)
    (stateValid : ValidState text state) : ValidState text (characterDeclarationAt text state arguments) := by
  by_cases positive : (characterDeclarationAt text state arguments).position ≠ 0
  · obtain ⟨declaration, source⟩ := character_declaration_sound text state arguments positive
    exact model_character_reading_valid stateValid source
  · unfold characterDeclarationAt
    dsimp only
    split
    · exact model_invalid_state_valid text
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

theorem model_object_reading_valid {text state next arguments declaration}
    (textValid : ValidText text) (stateValid : ValidState text state)
    (parsed : DeclarationAt text arguments state declaration next) : ValidState text next := by
  cases parsed with
  | string _ source =>
      rw [← string_declaration_complete source]
      exact model_string_declaration_valid text textValid state arguments stateValid
  | character source => exact model_character_reading_valid stateValid source

theorem model_character_reading_advances {text : Source} {state next : ParserState} {arguments : Bool}
    {declaration : Bindings.Declaration} (stateValid : ValidState text state)
    (source : CharacterDeclarationAt text arguments state declaration next) : state.position < next.position := by
  cases source with
  | @declaration parts value partsEq ready following source =>
      have valueBound := character_after_bounded source
      have startBound := fixedAfter_result_bound text parts.typeAfter ":=" false (by decide)
      have valueForward := character_advances source startBound
      have valueNonzero := character_input_nonzero source
      have typeNonzero := model_fixed_input_nonzero text _ ":=" false valueNonzero
      have followingEq : parts.following = fixedAfter text parts.value.after ";" false := by
        rw [← partsEq]
        rfl
      have finalForward := model_fixed_advances text _ ";" false valueBound (by decide)
        (followingEq ▸ following)
      have afterBound : ValidCursor text parts.after := by
        rw [← partsEq]
        exact model_name_valid text _
      have allowed : newNameAllowed text state parts.first parts.after arguments = true := by
        cases checked : newNameAllowed text state parts.first parts.after arguments with
        | true => rfl
        | false => simp [characterDeclarationRejected, checked] at ready
      have nameValid := model_new_name_valid text state _ _ arguments afterBound allowed
      have firstNonzero : declarationFirst text state ≠ 0 := by
        simpa only [← partsEq, characterDeclarationParts, declarationFirst] using Nat.ne_of_gt nameValid.1
      have nameForward : state.position < declarationAfter text state := by
        have skipped := skipAt_advances text _ stateValid.1 firstNonzero
        have named : declarationFirst text state < declarationAfter text state := by
          simpa only [← partsEq, characterDeclarationParts, declarationFirst, declarationAfter] using nameValid.2.1
        exact Nat.lt_of_le_of_lt skipped named
      let base := if declarationConstantAfter text state ≠ 0 then declarationConstantAfter text state
        else declarationColonAfter text state
      have sourceNameBound : ValidCursor text (declarationAfter text state) := model_name_valid text _
      have colonBound := model_fixed_valid text (declarationAfter text state) ":" false sourceNameBound
      have constantBound := model_fixed_valid text (declarationColonAfter text state) "constant" true colonBound
      have baseBound : ValidCursor text base := by unfold base; split <;> assumption
      have typeEq : parts.typeAfter = fixedAfter text (skipAt text base) "character" true := by
        rw [← partsEq]
        rfl
      have typeStartNonzero := model_fixed_input_nonzero text (skipAt text base) "character" true (typeEq ▸ typeNonzero)
      have baseNonzero : base ≠ 0 := by intro zero; simp [zero, skipAt] at typeStartNonzero
      have baseForward : declarationAfter text state < base := by
        unfold base at baseNonzero ⊢
        split at baseNonzero
        · rename_i present
          rw [ite_eq_left present]
          have colonNonzero := model_fixed_input_nonzero text _ "constant" true present
          exact Nat.lt_trans (model_fixed_advances text _ ":" false sourceNameBound (by decide) colonNonzero)
            (model_fixed_advances text _ "constant" true colonBound (by decide) present)
        · rename_i absent
          rw [ite_eq_right absent]
          exact model_fixed_advances text _ ":" false sourceNameBound (by decide) baseNonzero
      have typeStartBound := model_skip_valid text base baseBound
      have typeStartForward := skipAt_advances text base baseBound typeStartNonzero
      have typeForward := model_fixed_advances text (skipAt text base) "character" true typeStartBound (by decide) (typeEq ▸ typeNonzero)
      have typeBound : ValidCursor text parts.typeAfter := by
        rw [typeEq]
        exact model_fixed_valid text (skipAt text base) "character" true typeStartBound
      have startForward := model_fixed_advances text parts.typeAfter ":=" false typeBound (by decide) valueNonzero
      simp only [addBinding]
      rw [followingEq]
      rw [← typeEq] at typeForward
      omega

theorem model_character_declaration_advances (text : Source) (state : ParserState) (arguments : Bool)
    (stateValid : ValidState text state)
    (positive : (characterDeclarationAt text state arguments).position ≠ 0) :
    state.position < (characterDeclarationAt text state arguments).position := by
  obtain ⟨declaration, source⟩ := character_declaration_sound text state arguments positive
  exact model_character_reading_advances stateValid source

theorem model_procedure_declaration_valid {text : Source} {state : ParserState} {arguments : Bool}
    (_textValid : ValidText text) (stateValid : ValidState text state) :
    ValidState text (procedureDeclarationAt text state arguments) :=
  procedureDeclarationAt_valid text state arguments stateValid

theorem model_function_declaration_valid {text : Source} {state : ParserState} {arguments : Bool}
    (_textValid : ValidText text) (stateValid : ValidState text state) :
    ValidState text (functionDeclarationAt text state arguments) :=
  functionDeclarationAt_valid text state arguments stateValid

theorem model_declaration_valid (text : Source) (valid : ValidText text)
    (state : ParserState) (arguments : Bool) (stateValid : ValidState text state) :
    ValidState text (declarationAt text state arguments) := by
  unfold declarationAt
  dsimp only
  split
  · exact model_procedure_declaration_valid valid stateValid
  · split
    · exact model_function_declaration_valid valid stateValid
    · split
      · exact model_subtype_declaration_valid text state arguments stateValid
      · split
        · exact model_scalar_declaration_valid text state arguments stateValid
        · split
          · exact model_array_declaration_valid text state arguments stateValid
          · split
            · exact model_boolean_declaration_valid text state arguments stateValid
            · split
              · exact model_character_declaration_valid text state arguments stateValid
              · exact model_string_declaration_valid text valid state arguments stateValid

theorem model_declaration_advances (text : Source) (valid : ValidText text)
    (state : ParserState) (arguments : Bool) (stateValid : ValidState text state)
    (nonzero : (declarationAt text state arguments).position ≠ 0) :
    state.position < (declarationAt text state arguments).position := by
  by_cases procedure : (procedureDeclarationAt text state arguments).position ≠ 0
  · have selected : declarationAt text state arguments = procedureDeclarationAt text state arguments := by
      dsimp only [declarationAt]
      rw [ite_eq_left procedure]
    rw [selected]
    exact (procedureDeclarationAt_position text state arguments).2.resolve_left procedure
  ·
    by_cases function : (functionDeclarationAt text state arguments).position ≠ 0
    · have selected : declarationAt text state arguments = functionDeclarationAt text state arguments := by
        dsimp only [declarationAt]
        rw [ite_eq_right procedure]
        rw [ite_eq_left function]
      rw [selected]
      exact (functionDeclarationAt_position text state arguments).2.resolve_left function
    · by_cases subtype : (subtypeDeclarationAt text state arguments).position ≠ 0
      · have selected : declarationAt text state arguments = subtypeDeclarationAt text state arguments := by
          dsimp only [declarationAt]
          rw [ite_eq_right procedure]
          rw [ite_eq_right function]
          rw [ite_eq_left subtype]
        rw [selected]
        exact model_subtype_declaration_advances text state arguments subtype
      · by_cases scalar : (scalarDeclarationAt text state arguments).position ≠ 0
        · have selected : declarationAt text state arguments = scalarDeclarationAt text state arguments := by
            dsimp only [declarationAt]
            rw [ite_eq_right procedure]
            rw [ite_eq_right function]
            rw [ite_eq_right subtype, ite_eq_left scalar]
          rw [selected]
          exact model_scalar_declaration_advances text state arguments scalar
        · by_cases array : (arrayDeclarationAt text state arguments).position ≠ 0
          · have selected : declarationAt text state arguments = arrayDeclarationAt text state arguments := by
              dsimp only [declarationAt]
              rw [ite_eq_right procedure]
              rw [ite_eq_right function]
              rw [ite_eq_right subtype, ite_eq_right scalar, ite_eq_left array]
            rw [selected]
            exact model_array_declaration_advances text state arguments array
          · by_cases boolean : (booleanDeclarationAt text state arguments).position ≠ 0
            · have selected : declarationAt text state arguments = booleanDeclarationAt text state arguments := by
                simp only [declarationAt, procedure, function, ↓reduceIte]; split <;> simp_all
              rw [selected]
              exact model_boolean_declaration_advances text state arguments boolean
            · by_cases character : (characterDeclarationAt text state arguments).position ≠ 0
              · have selected : declarationAt text state arguments = characterDeclarationAt text state arguments := by
                  dsimp only [declarationAt]
                  rw [ite_eq_right procedure]
                  rw [ite_eq_right function]
                  rw [ite_eq_right subtype, ite_eq_right scalar, ite_eq_right array, ite_eq_right boolean, ite_eq_left character]
                rw [selected]
                exact model_character_declaration_advances text state arguments stateValid character
              · have selected : declarationAt text state arguments = stringDeclarationAt text state arguments := by
                  dsimp only [declarationAt]
                  rw [ite_eq_right procedure]
                  rw [ite_eq_right function]
                  rw [ite_eq_right subtype, ite_eq_right scalar, ite_eq_right array, ite_eq_right boolean, ite_eq_right character]
                rw [selected] at nonzero ⊢
                exact model_string_declaration_advances text valid state arguments stateValid nonzero

theorem model_dynamic_value_valid (text : Source) (following : Nat)
    (bound : ValidCursor text following) :
    ValidValue text ⟨following, 0, 0, 0, true, true, false, 0, 1, .singleton 1, ⟨0, maxSourceLength⟩⟩ :=
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
      ⟨following, 0, 0, 0, true, true, false, 0, 1, .singleton 1, ⟨0, maxSourceLength⟩⟩ false following stateValid nameValid
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
        (model_expression_valid (scalarNames := state.scalarNames) (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true) text valid _ _ stateValid.1 stateValid.2.1).1

theorem model_output_valid (text : Source) (valid : ValidText text) (state : ParserState)
    (stateValid : ValidState text state) : ValidState text (outputAt text state) := by
  unfold outputAt
  dsimp only
  split
  · exact model_state_position_valid text state stateValid _
      (model_expression_valid (scalarNames := state.scalarNames) (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true) text valid _ _ stateValid.1 stateValid.2.1).1
  · exact model_invalid_state_valid text

theorem model_comparison_valid (text : Source) (valid : ValidText text) (state : ParserState)
    (stateValid : ValidState text state) : ValidState text (comparisonAt text state) := by
  have left := model_expression_valid (scalarNames := state.scalarNames) (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true) (integerHidden := false) text valid _ _ stateValid.1 stateValid.2.1
  have equalPosition := model_fixed_valid text (expressionAt text state.position state.names state.scalarNames false state.arrayNames.names state.arrayNames.values true).after "=" false left.1
  have right := model_expression_valid (scalarNames := state.scalarNames) (arrays := state.arrayNames.names) (initials := state.arrayNames.values) (elaborating := true) (integerHidden := false) text valid _ _ equalPosition stateValid.2.1
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
