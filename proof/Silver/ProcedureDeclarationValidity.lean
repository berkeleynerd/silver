module

public import Silver.ProcedureHeaderValidity
public import Silver.ProcedureDeclarationPreservation
public import Silver.ComposeContracts

@[expose] public section

namespace Silver.Compose
open Silver.Compose.Expressions Named

private theorem procedure_invalid_valid (text : Source) : ValidState text invalidState := by
  simp [ValidState, Names.ValidContext, Names.ValidNameState, ValidCursor, ValidNames, NameState.Valid, invalidState,
    ScalarExpression.ValidEnvironment, ScalarExpression.maxBindings,
    ArrayBindings.ValidNativeEnvironment, ArrayBindings.ValidTable, ArrayBindings.ValidTypes,
    ArrayBindings.Env.table, ArrayBindings.ValidInitials, ArrayBindings.maxTypes, ArrayBindings.maxBindings,
    IntegerSubtypes.ValidEnvironment, IntegerSubtypes.maxBindings,
    BooleanBindings.ValidEnvironment, BooleanBindings.maxBindings,
    FunctionBindings.ValidMetadata, FunctionBindings.maxFunctions, FunctionBindings.maxFormals,
    ProcedureBindings.ValidMetadata, ProcedureBindings.maxProcedures, ProcedureBindings.maxFormals]

theorem procedureBodyAt_valid (text : Source) (outer frame : ParserState)
    (first after : Nat) (arguments : Bool)
    (outerValid : ValidState text outer)
    (metadata : ProcedureBindings.ValidMetadata text frame.procedures)
    (firstPositive : 0 < frame.firstProcedureParameter)
    (firstBound : frame.firstProcedureParameter ≤ frame.procedures.parameters.length)
    (space : frame.procedures.items.length < ProcedureBindings.maxProcedures)
    (span : ProcedureBindings.NameSpan text first after)
    (growth : outer.procedures.parameters.length ≤ frame.procedures.parameters.length) :
    ValidState text (procedureBodyAt text outer frame first after arguments) := by
  have signatureValid : ProcedureBindings.ValidSignature text frame.procedures
      ⟨first, after, frame.firstProcedureParameter,
        frame.procedures.parameters.length - frame.firstProcedureParameter + 1⟩ :=
    ⟨span, by dsimp; omega, firstPositive, firstBound, Nat.le_refl _⟩
  have extended := ProcedureBindings.append_valid metadata space signatureValid
  rcases outerValid with ⟨position, names, dynamic, target, capacity, scalars, arrays,
    subtypes, booleans, functions, parameterBound, parameterCapacity,
    oldMetadata, procedureBound, procedureCapacity⟩
  rw [procedureBodyAt_equation]
  split
  · exact procedure_invalid_valid text
  · split
    · exact procedure_invalid_valid text
    · split
      · exact procedure_invalid_valid text
      · split
        · exact procedure_invalid_valid text
        · exact ⟨fixedAfter_result_bound text _ ";" false (by decide), names, dynamic, target, capacity,
            scalars, arrays, subtypes, booleans, functions, parameterBound, parameterCapacity,
            extended, by
              change outer.firstProcedureParameter ≤ frame.procedures.parameters.length + 1
              omega, procedureCapacity⟩

/-- Every model state is covered, including malformed headers and rejected
bodies. No body-safety assumption is needed to preserve scanner metadata. -/
theorem procedureDeclarationAt_valid (text : Source) (state : ParserState) (arguments : Bool)
    (stateValid : ValidState text state) : ValidState text (procedureDeclarationAt text state arguments) := by
  have subtypes := stateValid.2.2.2.2.2.2.2.1
  have metadata := stateValid.procedures
  dsimp only [procedureDeclarationAt]
  generalize startEq : fixedAfter text state.position "procedure" true = start
  generalize firstEq : skipAt text start = first
  generalize afterEq : nameAfter text first = after
  generalize openingEq : fixedAfter text after "(" false = opening
  split
  · exact procedure_invalid_valid text
  · rename_i admitted
    simp only [not_or, Bool.not_eq_true'] at admitted
    have allowed : newNameAllowed text state first after arguments = true :=
      Bool.eq_true_of_ne_false admitted.2.2.2.1
    have nameSpan := newNameAllowed_span text state first after arguments allowed
    have span : ProcedureBindings.NameSpan text first after :=
      ⟨nameSpan.1, nameSpan.2, by rw [← afterEq]; exact function_nameAfter_bound text first⟩
    have itemSpace : state.procedures.items.length < ProcedureBindings.maxProcedures := by
      have bound := metadata.1
      omega
    generalize initialEq : ({initialState with
      position := opening, pure := true, subtypeNames := state.subtypeNames, functions := state.functions,
      procedures := state.procedures,
      arrayNames := {types := state.arrayNames.types},
      «hiding» := hideName text (hiddenOuter text state) first after,
      firstProcedureParameter := state.procedures.parameters.length + 1} : ParserState) = initial
    generalize headerEq : procedureParametersAt text initial arguments = header
    split
    · exact procedure_invalid_valid text
    · rename_i headerGood
      have initialMetadata : ProcedureBindings.ValidMetadata text initial.procedures := by
        rw [← initialEq]
        exact metadata
      have initialSubtypes : IntegerSubtypes.ValidEnvironment text initial.subtypeNames := by
        rw [← initialEq]
        exact subtypes
      have initialArrays : ArrayBindings.ValidTypes text initial.arrayNames.types := by
        rw [← initialEq]
        exact stateValid.arrayTypes
      have headerInfo := procedureParametersAt_valid text initial arguments initialMetadata initialSubtypes initialArrays
      rw [headerEq] at headerInfo
      have headerValid := headerInfo.resolve_left headerGood
      have initialCount : initial.procedures.parameters.length = state.procedures.parameters.length := by
        rw [← initialEq]
      have grows := headerValid.grows
      rw [initialCount] at grows
      have firstParameter : header.firstProcedureParameter = state.procedures.parameters.length + 1 := by
        rw [headerValid.firstParameter, ← initialEq]
      have items : header.procedures.items = state.procedures.items := by
        rw [headerValid.items, ← initialEq]
      split
      · exact procedure_invalid_valid text
      · exact procedureBodyAt_valid text state _ first after arguments stateValid headerValid.valid
          (by change 0 < header.firstProcedureParameter; rw [firstParameter]; omega)
          (by change header.firstProcedureParameter ≤ header.procedures.parameters.length; rw [firstParameter]; omega)
          (by change header.procedures.items.length < ProcedureBindings.maxProcedures; simpa only [items] using itemSpace)
          span (by change state.procedures.parameters.length ≤ header.procedures.parameters.length; omega)

end Silver.Compose
