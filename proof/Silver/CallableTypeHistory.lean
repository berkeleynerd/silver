module

public import Silver.ProcedureHeaderValidity

@[expose] public section

namespace Silver.Compose

/-- Source history resolves every pooled nominal formal against the type table
already declared at that point. This is separate from native state validity. -/
structure CallableTypesKnown (state : ParserState) : Prop where
  functions : ∀ formal ∈ state.functions.parameters,
    formal.typeId ≤ state.arrayNames.types.length
  procedures : ∀ formal ∈ state.procedures.parameters,
    formal.typeId ≤ state.arrayNames.types.length

theorem initial_callable_types_known : CallableTypesKnown initialState := by
  constructor <;> simp [initialState]

theorem invalid_callable_types_known : CallableTypesKnown invalidState := by
  constructor <;> simp [invalidState]

theorem CallableTypesKnown.typePrefix {state : ParserState}
    (known : CallableTypesKnown state) (more : ArrayBindings.TypeEnvironment) :
    CallableTypesKnown {state with arrayNames := {state.arrayNames with types := state.arrayNames.types ++ more}} := by
  constructor
  · intro formal member
    exact Nat.le_trans (known.functions formal member) (by simp)
  · intro formal member
    exact Nat.le_trans (known.procedures formal member) (by simp)

theorem parameterStep_callable_types_known (text : Source) (state : ParserState) (arguments : Bool)
    (known : CallableTypesKnown state) :
    CallableTypesKnown (parameterStep text state arguments).state := by
  dsimp only [parameterStep]
  generalize firstEq : skipAt text state.position = first
  generalize afterEq : nameAfter text first = after
  generalize startEq : fixedAfter text (fixedAfter text after ":" false) "in" true = start
  generalize valueEq : formalTypeAt text state start = value
  have bound := formalTypeAt_typeId_bound text state start
  rw [valueEq] at bound
  have extended : CallableTypesKnown
      {state with functions := FunctionBindings.appendFormal state.functions ⟨first, after, value.kind, value.bounds, value.typeId⟩} := by
    refine ⟨?_, known.procedures⟩
    intro formal member
    rcases List.mem_append.mp member with old | fresh
    · exact known.functions formal old
    · have same := List.mem_singleton.mp fresh
      subst formal
      exact bound
  split
  · exact invalid_callable_types_known
  · split
    · exact ⟨extended.functions, extended.procedures⟩
    · split
      · exact ⟨extended.functions, extended.procedures⟩
      · exact invalid_callable_types_known

theorem parametersModel_callable_types_known (text : Source) (state : ParserState) (arguments : Bool)
    (known : CallableTypesKnown state) : CallableTypesKnown (parametersModel text state arguments) := by
  rw [parametersModel]
  split
  · exact invalid_callable_types_known
  · split
    · exact parameterStep_callable_types_known text state arguments known
    · split
      · exact parametersModel_callable_types_known text (parameterStep text state arguments).state arguments
          (parameterStep_callable_types_known text state arguments known)
      · exact invalid_callable_types_known
termination_by Predicate.remainingAt text state.position
decreasing_by assumption

theorem procedureParameterStep_callable_types_known (text : Source) (state : ParserState) (arguments : Bool)
    (known : CallableTypesKnown state) :
    CallableTypesKnown (procedureParameterStep text state arguments).state := by
  dsimp only [procedureParameterStep]
  generalize firstEq : skipAt text state.position = first
  generalize afterEq : nameAfter text first = after
  generalize colonEq : fixedAfter text after ":" false = colonEnd
  generalize inEq : fixedAfter text colonEnd "in" true = inEnd
  generalize outEq : fixedAfter text (if inEnd = 0 then colonEnd else inEnd) "out" true = outEnd
  generalize startEq : (if outEnd ≠ 0 then outEnd else inEnd) = start
  generalize valueEq : formalTypeAt text state start = value
  generalize modeEq : (if inEnd = 0 then ProcedureBindings.Mode.output else
    if outEnd = 0 then .input else .inputOutput) = mode
  have bound := formalTypeAt_typeId_bound text state start
  rw [valueEq] at bound
  have extended : CallableTypesKnown
      {state with procedures := ProcedureBindings.appendFormal state.procedures ⟨first, after, value.kind, value.bounds, mode, value.typeId⟩} := by
    refine ⟨known.functions, ?_⟩
    intro formal member
    rcases List.mem_append.mp member with old | fresh
    · exact known.procedures formal old
    · have same := List.mem_singleton.mp fresh
      subst formal
      exact bound
  split
  · exact invalid_callable_types_known
  · split
    · exact ⟨extended.functions, extended.procedures⟩
    · split
      · exact ⟨extended.functions, extended.procedures⟩
      · exact invalid_callable_types_known

theorem procedureParametersModel_callable_types_known (text : Source) (state : ParserState) (arguments : Bool)
    (known : CallableTypesKnown state) : CallableTypesKnown (procedureParametersModel text state arguments) := by
  rw [procedureParametersModel]
  split
  · exact invalid_callable_types_known
  · split
    · exact procedureParameterStep_callable_types_known text state arguments known
    · split
      · exact procedureParametersModel_callable_types_known text
          (procedureParameterStep text state arguments).state arguments
          (procedureParameterStep_callable_types_known text state arguments known)
      · exact invalid_callable_types_known
termination_by Predicate.remainingAt text state.position
decreasing_by assumption

end Silver.Compose
