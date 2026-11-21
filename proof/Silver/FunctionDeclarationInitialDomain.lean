module

public import Silver.FunctionDeclarationOuterEquations

@[expose] public section

namespace Silver.Compose.FunctionDeclarationNative

set_option maxRecDepth 4000
set_option maxHeartbeats 1000000

structure DeclarationBounds (text : Source) (state : ParserState) : Prop where
  start : (declarationParts modelCalls text state).start ≤ text.length + 1
  first : (declarationParts modelCalls text state).first ≤ text.length + 1
  after : (declarationParts modelCalls text state).after ≤ text.length + 1
  opening : (declarationParts modelCalls text state).opening ≤ text.length + 1

theorem declaration_bounds (text : Source) (state : ParserState) : DeclarationBounds text state := by
  have start := fixedAfter_result_bound text state.position "function" true (by decide)
  exact ⟨start, Expressions.model_skip_valid text _ start, function_nameAfter_bound text _,
    fixedAfter_result_bound text _ "(" false (by decide)⟩

structure DeclarationAdmitted (text : Source) (state : ParserState) (arguments : Bool) : Prop where
  name : FunctionBindings.NameSpan text (declarationParts modelCalls text state).first (declarationParts modelCalls text state).after
  itemSpace : state.functions.items.length < FunctionBindings.maxFunctions
  parameterSpace : state.functions.parameters.length < FunctionBindings.maxFormals

theorem declaration_admitted (text : Source) (state : ParserState) (arguments : Bool)
    (valid : StateInput text state)
    (accepted : declarationRejected modelCalls text state arguments (declarationParts modelCalls text state) = false) :
    DeclarationAdmitted text state arguments := by
  have items := valid.1.functions.1
  have parameters := valid.1.functions.2.1
  simp only [declarationRejected, Bool.or_eq_false_iff, Bool.not_eq_false', decide_eq_false_iff_not] at accepted
  refine ⟨?_, by omega, by omega⟩
  have span := newNameAllowed_span text state _ _ arguments accepted.1.1.2
  exact ⟨span.1, span.2, (declaration_bounds text state).after⟩

theorem StateInput.withPosition {text state} (tv : FunctionBindings.Native.ValidText text)
    (valid : StateInput text state) (position : Nat) (bound : position ≤ text.length + 1) :
    StateInput text {state with position := position} :=
  ⟨{valid.1 with position := by change position ≤ 4097; have size := tv.2; omega},
    ⟨⟨bound, valid.2.base.2⟩, valid.2.ready, valid.2.bounds⟩⟩

theorem declaration_initial_input (text : Source) (tv : FunctionBindings.Native.ValidText text)
    (state : ParserState) (arguments : Bool) (valid : StateInput text state)
    (admitted : DeclarationAdmitted text state arguments) :
    StateInput text (declarationInitial modelCalls text state (declarationParts modelCalls text state)) := by
  have cursor := (declaration_bounds text state).opening
  have sourceSize := tv.2
  have metadata := valid.2.base.2.2.2.2.2.2.2.2.2.1
  have subtypes := valid.2.base.2.2.2.2.2.2.2.1
  constructor
  · constructor
    · change (declarationParts modelCalls text state).opening ≤ 4097
      omega
    · exact valid.1.functions
    · change state.functions.parameters.length + 1 ≤ FunctionBindings.maxFormals
      have room := admitted.parameterSpace
      omega
    · simp [declarationInitial, initialState, StringEnvironmentType]
    · simp [declarationInitial, initialState, ScalarEnvironmentType]
    · simp [declarationInitial, initialState, ArrayEnvironmentType]
    · exact valid.1.subtypes
    · simp [declarationInitial, initialState, BooleanEnvironmentType]
    · change 0 ≤ _
      exact Nat.zero_le _
    · change 0 ≤ _
      exact Nat.zero_le _
    · change 0 ≤ _
      exact Nat.zero_le _
    · exact Nat.le_refl _
    · exact valid.1.procedures
    · exact Nat.zero_le _
    · exact valid.1.arrayTypes
  · constructor
    · refine ⟨cursor, ?_, ?_, ?_, ?_, ?_, ?_, subtypes, ?_, metadata, ?_, ?_,
        valid.2.base.procedures, Nat.zero_le _, Nat.zero_le _⟩
      · simp [declarationInitial, initialState, Expressions.ValidNames]
      · exact .inl ⟨rfl, rfl⟩
      · exact Nat.zero_le _
      · exact Nat.le_refl _
      · simp [declarationInitial, initialState, ScalarExpression.ValidEnvironment]
      · simp [declarationInitial, initialState, ArrayBindings.ValidNativeEnvironment, ArrayBindings.ValidTable, ArrayBindings.Env.table,
          ArrayBindings.ValidInitials, valid.2.base.arrayTypes]
      · simp [declarationInitial, initialState, BooleanBindings.ValidEnvironment]
      · exact Nat.le_refl _
      · change state.functions.parameters.length + 1 ≤ FunctionBindings.maxFormals
        have room := admitted.parameterSpace
        omega
    · exact Predicate.ScalarMetadata.headerReady_empty
    · intro slot info found
      simp [declarationInitial, initialState, Bindings.BindingEnvironment.get] at found

end Silver.Compose.FunctionDeclarationNative
