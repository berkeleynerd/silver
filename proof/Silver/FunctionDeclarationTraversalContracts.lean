module

public import Silver.FunctionDeclarationOrdinaryEquations

@[expose] public section

namespace Silver.Compose.FunctionDeclarationNative

/-- Only native record bounds and literal runtime postconditions of the
three executable traversals. These do not assert scanner/model equivalence. -/
structure TraversalContracts (calls : Calls) : Prop where
  parameters : ∀ text, FunctionBindings.Native.ValidText text → ∀ state arguments,
    StateInput text state →
    let result := calls .parameters text state arguments
    StateInput text result ∧ (result.position = 0 ∨
      state.position < result.position ∧ result.functions.items.length = state.functions.items.length ∧
      state.functions.parameters.length < result.functions.parameters.length ∧
      result.firstParameter = state.firstParameter ∧ result.pure = state.pure)
  locals : ∀ text, FunctionBindings.Native.ValidText text → ∀ state arguments,
    StateInput text state →
    let result := calls .functionLocals text state arguments
    StateInput text result ∧ (result.position = 0 ∨
      state.position ≤ result.position ∧ result.functions = state.functions ∧
      result.firstParameter = state.firstParameter ∧ result.pure = state.pure)
  parameterFrame : ∀ text, FunctionBindings.Native.ValidText text → ∀ state,
    StateInput text state → 0 < state.firstParameter →
    let result := calls .parameterFrame text state
    StateInput text result ∧ (result.position = 0 ∨
      result.position = state.position ∧ result.functions = state.functions ∧
      state.scalarNames.length ≤ result.scalarNames.length ∧ state.booleanNames.length ≤ result.booleanNames.length)
  functionType : ∀ text, FunctionBindings.Native.ValidText text → ∀ state position,
    StateInput text state → position ≤ text.length + 1 →
    let result := calls .functionType text state position
    TypeResultRecord result ∧ (result.after = 0 ∨
      position < result.after ∧ result.after ≤ text.length + 1 ∧ result.bounds.isEmpty = false)
  returnAfter : ∀ text, FunctionBindings.Native.ValidText text → ∀ context scan resultType,
    ReturnInput text context scan resultType →
    let result := calls .returnAfter text context scan resultType
    result = 0 ∨ scan.position < result ∧ result ≤ text.length + 1

end Silver.Compose.FunctionDeclarationNative
