module

public import Silver.FunctionHeaderValidity
public import Silver.ComposeContracts

@[expose] public section

namespace Silver.Compose
open Silver.Compose.Expressions Named

private theorem function_invalid_valid (text : Source) : ValidState text invalidState := by
  simp [ValidState, ValidCursor, ValidNames, NameState.Valid, invalidState,
    ScalarExpression.ValidEnvironment, ScalarExpression.maxBindings,
    ArrayBindings.ValidEnvironment, ArrayBindings.ValidMetadata, ArrayBindings.ValidInitials,
    IntegerSubtypes.ValidEnvironment, IntegerSubtypes.maxBindings,
    BooleanBindings.ValidEnvironment, BooleanBindings.maxBindings,
    FunctionBindings.ValidMetadata, FunctionBindings.maxFunctions, FunctionBindings.maxFormals,
    ProcedureBindings.ValidMetadata, ProcedureBindings.maxProcedures, ProcedureBindings.maxFormals]

theorem functionBodyAt_valid (text : Source) (outer frame : ParserState)
    (first after : Nat) (resultType : FunctionTypeResult) (arguments : Bool)
    (outerValid : ValidState text outer)
    (metadata : FunctionBindings.ValidMetadata text frame.functions)
    (firstPositive : 0 < frame.firstParameter)
    (firstBound : frame.firstParameter ≤ frame.functions.parameters.length)
    (space : frame.functions.items.length < FunctionBindings.maxFunctions)
    (span : FunctionBindings.NameSpan text first after)
    (resultValid : resultType.bounds.Bounded ∧ resultType.bounds.lower ≤ resultType.bounds.upper)
    (growth : outer.functions.parameters.length ≤ frame.functions.parameters.length) :
    ValidState text (functionBodyAt text outer frame first after resultType arguments) := by
  have signatureValid : FunctionBindings.ValidSignature text frame.functions
      ⟨first, after, frame.firstParameter, frame.functions.parameters.length - frame.firstParameter + 1,
        resultType.kind, resultType.bounds⟩ :=
    ⟨span, by dsimp; omega, firstPositive, firstBound, Nat.le_refl _, resultValid⟩
  have extended := FunctionBindings.append_valid metadata space signatureValid
  rcases outerValid with ⟨position, names, dynamic, target, capacity, scalars, arrays,
    subtypes, booleans, oldMetadata, parameterBound, parameterCapacity⟩
  dsimp only [functionBodyAt]
  split
  · exact function_invalid_valid text
  · split
    · exact function_invalid_valid text
    · split
      · exact function_invalid_valid text
      · exact ⟨fixedAfter_result_bound text _ ";" false (by decide), names, dynamic, target, capacity,
          scalars, arrays, subtypes, booleans, extended, by
            change outer.firstParameter ≤ frame.functions.parameters.length + 1
            omega, parameterCapacity⟩

theorem functionDeclarationAt_valid (text : Source) (state : ParserState) (arguments : Bool)
    (stateValid : ValidState text state) : ValidState text (functionDeclarationAt text state arguments) := by
  have subtypes := stateValid.2.2.2.2.2.2.2.1
  have metadata := stateValid.2.2.2.2.2.2.2.2.2.1
  dsimp only [functionDeclarationAt]
  generalize startEq : fixedAfter text state.position "function" true = start
  generalize firstEq : skipAt text start = first
  generalize afterEq : nameAfter text first = after
  generalize openingEq : fixedAfter text after "(" false = opening
  split
  · exact function_invalid_valid text
  · rename_i admitted
    simp only [not_or, Bool.not_eq_true'] at admitted
    have allowed : newNameAllowed text state first after arguments = true :=
      Bool.eq_true_of_ne_false admitted.2.2.2.1
    have nameSpan := newNameAllowed_span text state first after arguments allowed
    have span : FunctionBindings.NameSpan text first after :=
      ⟨nameSpan.1, nameSpan.2, by rw [← afterEq]; exact function_nameAfter_bound text first⟩
    have itemSpace : state.functions.items.length < FunctionBindings.maxFunctions := by
      have bound := metadata.1
      omega
    generalize initialEq : ({initialState with
      position := opening, pure := true, subtypeNames := state.subtypeNames, functions := state.functions,
      procedures := state.procedures,
      «hiding» := hideName text (hiddenOuter text state) first after,
      firstParameter := state.functions.parameters.length + 1} : ParserState) = initial
    generalize headerEq : parametersAt text initial arguments = header
    split
    · exact function_invalid_valid text
    · rename_i headerGood
      have initialMetadata : FunctionBindings.ValidMetadata text initial.functions := by rw [← initialEq]; exact metadata
      have initialSubtypes : IntegerSubtypes.ValidEnvironment text initial.subtypeNames := by rw [← initialEq]; exact subtypes
      have headerInfo := parametersAt_valid text initial arguments initialMetadata initialSubtypes
      rw [headerEq] at headerInfo
      have headerValid := headerInfo.resolve_left headerGood
      have headerSubtypes : IntegerSubtypes.ValidEnvironment text header.subtypeNames :=
        headerValid.subtypes.symm ▸ initialSubtypes
      have initialCount : initial.functions.parameters.length = state.functions.parameters.length := by rw [← initialEq]
      have grows := headerValid.grows
      rw [initialCount] at grows
      have firstParameter : header.firstParameter = state.functions.parameters.length + 1 := by
        rw [headerValid.firstParameter, ← initialEq]
      have items : header.functions.items = state.functions.items := by rw [headerValid.items, ← initialEq]
      generalize resultEq : functionTypeAt text header (fixedAfter text header.position "return" true) = resultType
      generalize bodyStartEq : fixedAfter text resultType.after "is" true = bodyStart
      split
      · exact function_invalid_valid text
      · rename_i resultGood
        have resultValid := functionTypeAt_good text header (fixedAfter text header.position "return" true) headerSubtypes
        rw [resultEq] at resultValid
        have resultBounds := resultValid.resolve_left (fun zero => resultGood (.inl zero))
        exact functionBodyAt_valid text state {header with position := bodyStart} first after resultType arguments
          stateValid headerValid.valid
          (by change 0 < header.firstParameter; rw [firstParameter]; omega)
          (by change header.firstParameter ≤ header.functions.parameters.length; rw [firstParameter]; omega)
          (by change header.functions.items.length < FunctionBindings.maxFunctions; simpa only [items] using itemSpace)
          span resultBounds
          (by change state.functions.parameters.length ≤ header.functions.parameters.length; omega)

end Silver.Compose
