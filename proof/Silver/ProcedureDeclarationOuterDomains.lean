module

public import Silver.ProcedureDeclarationHighEquations
public import Silver.FunctionHeaderValidity

@[expose] public section

namespace Silver.Compose.ProcedureDeclarationNative

set_option maxRecDepth 6000
set_option maxHeartbeats 2000000

structure DeclarationBounds (text : Source) (state : ParserState) : Prop where
  start : (declarationParts modelCalls text state).start ≤ text.length + 1
  first : (declarationParts modelCalls text state).first ≤ text.length + 1
  after : (declarationParts modelCalls text state).after ≤ text.length + 1
  opening : (declarationParts modelCalls text state).opening ≤ text.length + 1

theorem declaration_bounds (text : Source) (state : ParserState) : DeclarationBounds text state := by
  have start := fixedAfter_result_bound text state.position "procedure" true (by decide)
  exact ⟨start, Expressions.model_skip_valid text _ start, function_nameAfter_bound text _,
    fixedAfter_result_bound text _ "(" false (by decide)⟩

structure DeclarationAdmitted (text : Source) (state : ParserState) : Prop where
  name : FunctionBindings.NameSpan text (declarationParts modelCalls text state).first
    (declarationParts modelCalls text state).after
  itemSpace : state.procedures.items.length < ProcedureBindings.maxProcedures
  parameterSpace : state.procedures.parameters.length < ProcedureBindings.maxFormals

theorem declaration_admitted (text : Source) (state : ParserState) (arguments : Bool)
    (valid : FunctionDeclarationNative.StateInput text state)
    (accepted : declarationRejected modelCalls text state arguments (declarationParts modelCalls text state) = false) :
    DeclarationAdmitted text state := by
  have items := valid.1.procedures.1
  have parameters := valid.1.procedures.2.1
  simp only [declarationRejected, Bool.or_eq_false_iff, Bool.not_eq_false', decide_eq_false_iff_not] at accepted
  refine ⟨?_, by omega, by omega⟩
  have span := newNameAllowed_span text state _ _ arguments accepted.1.1.2
  exact ⟨span.1, span.2, (declaration_bounds text state).after⟩

/-- A procedure's fresh local frame retains both earlier callable tables and
the exact next procedure-formal cursor. This follows from the admitted header;
it is not an extra premise on the declaration scanner. -/
theorem declaration_initial_input (text : Source) (tv : FunctionBindings.Native.ValidText text)
    (state : ParserState) (valid : FunctionDeclarationNative.StateInput text state)
    (admitted : DeclarationAdmitted text state) :
    FunctionDeclarationNative.StateInput text (declarationInitial modelCalls text state (declarationParts modelCalls text state)) := by
  have cursor := (declaration_bounds text state).opening
  have sourceSize := tv.2
  have subtypes := valid.2.base.2.2.2.2.2.2.2.1
  have room := admitted.parameterSpace
  constructor
  · constructor
    · change (declarationParts modelCalls text state).opening ≤ 4097
      omega
    · exact valid.1.functions
    · exact Nat.zero_le _
    · simp [declarationInitial, initialState, FunctionDeclarationNative.StringEnvironmentType]
    · simp [declarationInitial, initialState, FunctionDeclarationNative.ScalarEnvironmentType]
    · simp [declarationInitial, initialState, FunctionDeclarationNative.ArrayEnvironmentType]
    · exact valid.1.subtypes
    · simp [declarationInitial, initialState, FunctionDeclarationNative.BooleanEnvironmentType]
    · exact Nat.zero_le _
    · exact Nat.zero_le _
    · exact Nat.zero_le _
    · exact Nat.le_refl _
    · exact valid.1.procedures
    · change state.procedures.parameters.length + 1 ≤ ProcedureBindings.maxFormals
      omega
  · constructor
    · refine ⟨cursor, ?_, ?_, ?_, ?_, ?_, ?_, subtypes, ?_, valid.2.base.functions,
        Nat.zero_le _, Nat.zero_le _, valid.2.base.procedures, Nat.le_refl _, ?_⟩
      · simp [declarationInitial, initialState, Expressions.ValidNames]
      · exact .inl ⟨rfl, rfl⟩
      · exact Nat.zero_le _
      · exact Nat.le_refl _
      · simp [declarationInitial, initialState, ScalarExpression.ValidEnvironment]
      · simp [declarationInitial, initialState, ArrayBindings.ValidEnvironment,
          ArrayBindings.ValidMetadata, ArrayBindings.ValidInitials]
      · simp [declarationInitial, initialState, BooleanBindings.ValidEnvironment]
      · change state.procedures.parameters.length + 1 ≤ ProcedureBindings.maxFormals
        omega
    · exact Predicate.ScalarMetadata.headerReady_empty
    · intro slot info found
      simp [declarationInitial, initialState, Bindings.BindingEnvironment.get] at found

end Silver.Compose.ProcedureDeclarationNative
