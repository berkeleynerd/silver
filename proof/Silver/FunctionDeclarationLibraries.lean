module

public import Silver.FunctionDeclarationHeaderLibraries
public import Silver.FunctionDeclarationTraversalContracts
public import Silver.FunctionDeclarationInitialDomain

@[expose] public section

namespace Silver.Compose.FunctionDeclarationNative

set_option maxRecDepth 6000
set_option maxHeartbeats 2000000

structure OrdinaryLinks (calls : Calls) (inherited : Expressions.Calls)
    (metadata : FunctionBindings.Native.Calls) (visibility : FunctionVisibilityNative.Implementation)
    : Prop extends HeaderLinks calls inherited metadata visibility where
  hiddenOuter : calls .hiddenOuter = visibility.hiddenOuter
  append : calls .append = metadata.append
  nameIs : calls .nameIs = inherited.function .nameIs

theorem declaration_library_imports {domain calls inherited metadata visibility}
    (source : InheritedEquations inherited domain)
    (exactDomain : ExactDomain domain) (functions : FunctionBindings.SourceBridge.ImplementationCorrect metadata)
    (visibilityPrimitives : FunctionVisibilityNative.Primitives visibility.calls)
    (visibilityEquations : FunctionVisibilityNative.Equations visibility)
    (links : OrdinaryLinks calls inherited metadata visibility)
    (headers : HeaderEquations calls) (headerContracts : HeaderContracts calls)
    (contracts : TraversalContracts calls) (equations : OrdinaryEquations calls)
    (bodyImports : ∀ text, FunctionBindings.Native.ValidText text → ∀ outer frame first after resultType arguments,
      BodyInput text outer frame first after resultType → BodyImports calls text outer frame first after resultType arguments)
    (text : Source) (tv : FunctionBindings.Native.ValidText text) (state : ParserState) (arguments : Bool)
    (valid : StateInput text state) : DeclarationImports calls text state arguments := by
  have lexical := header_lexical source.toRawHelperEquations links.toHeaderLinks
  have imports := header_imports source exactDomain functions visibilityPrimitives visibilityEquations links.toHeaderLinks headers
  have bounds := declaration_bounds text state
  refine {
    start := lexical.take text tv _ _ _ valid.2.base.1 (native_token_valid .functionKeyword),
    first := lexical.skip text tv _ bounds.start,
    after := lexical.nameAfter text tv _ bounds.first,
    opening := lexical.take text tv _ _ _ bounds.after (native_token_valid .leftParenthesis),
    newName := ?_, tail := ?_}
  all_goals dsimp only
  · rw [links.newName]
    exact Expressions.interpreted_newName inherited source.toRawHelperEquations text tv state _ _ arguments
      (valid.2.inherited exactDomain) bounds.first bounds.after
  · intro accepted
    have admitted := declaration_admitted text state arguments valid accepted
    have initialValid := declaration_initial_input text tv state arguments valid admitted
    have initialSame : declarationInitial calls text state (declarationParts modelCalls text state) =
        declarationInitial modelCalls text state (declarationParts modelCalls text state) := by
      unfold declarationInitial
      rw [links.hiddenOuter, FunctionVisibilityNative.hiddenOuter_meaning visibility visibilityPrimitives
        visibilityEquations text tv state valid.2, links.hideName,
        FunctionVisibilityNative.hideName_meaning visibility visibilityPrimitives visibilityEquations
          text tv _ _ _ admitted.name]
      rfl
    have parameters := interpreted_parameters calls headers imports headerContracts text tv _ arguments initialValid
    have headerInfo := contracts.parameters text tv _ arguments initialValid
    rw [parameters] at headerInfo
    let header := parametersAt text (declarationInitial modelCalls text state (declarationParts modelCalls text state)) arguments
    have headerValid : StateInput text header := headerInfo.1
    have resultBound := fixedAfter_result_bound text header.position "return" true (by decide)
    have resultMeaning := interpreted_functionType calls headers imports text tv header _ headerValid resultBound
    have typeInfo := contracts.functionType text tv header _ headerValid resultBound
    rw [resultMeaning] at typeInfo
    let resultType := functionTypeAt text header (fixedAfter text header.position "return" true)
    have bodyBound := fixedAfter_result_bound text resultType.after "is" true (by decide)
    refine ⟨initialSame, parameters, ?_, ?_, ?_, ?_⟩
    all_goals dsimp only
    · intro _
      exact lexical.take text tv _ _ _ headerValid.2.base.1 (native_token_valid .returnKeyword)
    · intro _
      exact resultMeaning
    · intro _
      exact lexical.take text tv _ _ _ (functionTypeAt_position_bound text header _) (native_token_valid .isKeyword)
    · intro headerGood resultGood _
      have headerMore := headerInfo.2.resolve_left headerGood
      have resultGoodInfo := typeInfo.2.resolve_left resultGood
      have input : BodyInput text state {header with position := fixedAfter text resultType.after "is" true}
          (declarationParts modelCalls text state).first (declarationParts modelCalls text state).after resultType := by
        refine ⟨valid, StateInput.withPosition tv headerValid _ bodyBound, ?_, ?_, ?_, ?_, admitted.name, typeInfo.1, resultGoodInfo.2.2⟩
        · change state.functions.parameters.length ≤ header.functions.parameters.length
          have count := headerMore.2.2.1
          change state.functions.parameters.length < header.functions.parameters.length at count
          exact Nat.le_of_lt count
        · change 0 < header.firstParameter
          rw [headerMore.2.2.2.1]
          exact Nat.succ_pos _
        · change header.firstParameter ≤ header.functions.parameters.length
          have count := headerMore.2.2.1
          rw [headerMore.2.2.2.1]
          change state.functions.parameters.length + 1 ≤ header.functions.parameters.length
          change state.functions.parameters.length < header.functions.parameters.length at count
          omega
        · change header.functions.items.length < FunctionBindings.maxFunctions
          rw [headerMore.2.1]
          exact admitted.itemSpace
      exact interpreted_functionBody calls equations text tv state _ _ _ resultType arguments input
        (bodyImports text tv state _ _ _ resultType arguments input)

theorem body_finish_library_imports {domain calls inherited metadata visibility}
    (source : Expressions.RawHelperEquations inherited (domain := domain))
    (functions : FunctionBindings.SourceBridge.ImplementationCorrect metadata)
    (visibilityPrimitives : FunctionVisibilityNative.Primitives visibility.calls)
    (visibilityEquations : FunctionVisibilityNative.Equations visibility)
    (links : OrdinaryLinks calls inherited metadata visibility)
    (text : Source) (tv : FunctionBindings.Native.ValidText text) (outer frame : ParserState) (first after : Nat)
    (resultType : FunctionTypeResult) (parts : BodyParts) (valid : BodyInput text outer frame first after resultType)
    (endBound : parts.endAfter ≤ text.length + 1) : BodyFinishImports calls text outer frame first after resultType parts := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · intro accepted
    simp only [bodyPrefix, Bool.or_eq_false_iff, decide_eq_false_iff_not] at accepted
    rw [links.equal]
    exact visibilityPrimitives.equalName text tv first after parts.endFirst parts.endAfter valid.name
      ⟨by omega, by omega, endBound⟩
  · intro _
    have size := tv.2
    have nameBound := valid.name.2.2
    have nameOrder := valid.name.2.1
    have firstParameter := valid.frame.1.firstParameter
    have parameterCount := valid.frame.1.functions.2.1
    have positive := valid.firstParameter
    rw [links.append]
    exact functions.append frame.functions valid.frame.1.functions _
      ⟨by dsimp only; omega, by dsimp only; omega, firstParameter,
        by dsimp only; omega, valid.resultType.bounds⟩ valid.capacity
  · intro _
    rw [links.hideName]
    exact FunctionVisibilityNative.hideName_meaning visibility visibilityPrimitives visibilityEquations text tv _ _ _ valid.name
  · intro _ operation
    rw [links.nameIs]
    exact source.nameIs text tv first after operation.name valid.name
      (by cases operation <;> decide) (by cases operation <;> decide)

end Silver.Compose.FunctionDeclarationNative
