module

public import Silver.ProcedureDeclarationBodyLibrary
public import Silver.ProcedureDeclarationOuterDomains

@[expose] public section

namespace Silver.Compose.ProcedureDeclarationNative

set_option maxRecDepth 6000
set_option maxHeartbeats 2000000

structure OuterLinks (calls : Calls) (source : InterpretedHelpers calls) : Prop
    extends BodyLinks calls source where
  hiddenOuter : calls .hiddenOuter = source.ordinarySource.visibility.hiddenOuter

theorem declaration_library_imports {calls : Calls} (source : InterpretedHelpers calls)
    (links : OuterLinks calls source) (equations : HighEquations calls)
    (text : Source) (tv : FunctionBindings.Native.ValidText text) (state : ParserState)
    (arguments : Bool) (valid : StateInput text state) : DeclarationImports calls text state arguments := by
  have lexical := header_lexical source.ordinarySource.inheritedSource.toRawHelperEquations source.links
  have bounds := declaration_bounds text state
  refine {
    start := lexical.take text tv _ _ _ valid.2.base.1 (native_token_valid .procedureKeyword),
    first := lexical.skip text tv _ bounds.start,
    after := lexical.nameAfter text tv _ bounds.first,
    opening := lexical.take text tv _ _ _ bounds.after (native_token_valid .leftParenthesis),
    newName := ?_, tail := ?_}
  · rw [source.links.newName]
    exact Expressions.interpreted_newName source.ordinarySource.inherited
      source.ordinarySource.inheritedSource.toRawHelperEquations text tv state _ _ arguments
      (valid.2.inherited source.ordinarySource.exactDomain) bounds.first bounds.after
  · intro accepted
    have admitted := declaration_admitted text state arguments valid accepted
    have initialValid := declaration_initial_input text tv state valid admitted
    have initialSame : declarationInitial calls text state (declarationParts modelCalls text state) =
        declarationInitial modelCalls text state (declarationParts modelCalls text state) := by
      unfold declarationInitial
      rw [links.hiddenOuter, FunctionVisibilityNative.hiddenOuter_meaning source.ordinarySource.visibility
        source.ordinarySource.visibilityPrimitives source.ordinarySource.visibilityEquations text tv state valid.2,
        source.links.hideName, FunctionVisibilityNative.hideName_meaning source.ordinarySource.visibility
          source.ordinarySource.visibilityPrimitives source.ordinarySource.visibilityEquations text tv _ _ _ admitted.name]
      rfl
    have parameters := source_parameters source text tv _ arguments initialValid
    have headerInfo := source.traversal.parameters text tv _ arguments initialValid
    rw [parameters] at headerInfo
    let header := procedureParametersAt text (declarationInitial modelCalls text state (declarationParts modelCalls text state)) arguments
    have headerValid : StateInput text header := headerInfo.1
    have bodyBound := fixedAfter_result_bound text header.position "is" true (by decide)
    refine ⟨initialSame, parameters, ?_, ?_⟩
    · intro _
      exact lexical.take text tv _ _ _ headerValid.2.base.1 (native_token_valid .isKeyword)
    · intro headerGood _ _
      have headerMore := headerInfo.2.resolve_left headerGood
      have input : BodyDomain text state {header with position := fixedAfter text header.position "is" true}
          (declarationParts modelCalls text state).first (declarationParts modelCalls text state).after := by
        refine ⟨valid, FunctionDeclarationNative.StateInput.withPosition tv headerValid _ bodyBound,
          ?_, ?_, ?_, ?_, admitted.name⟩
        · exact Nat.le_of_lt headerMore.parameters
        · change 0 < header.firstProcedureParameter
          rw [headerMore.firstParameter]
          exact Nat.succ_pos _
        · change header.firstProcedureParameter ≤ header.procedures.parameters.length
          rw [headerMore.firstParameter]
          exact headerMore.parameters
        · change header.procedures.items.length < ProcedureBindings.maxProcedures
          rw [headerMore.procedures]
          exact admitted.itemSpace
      exact interpreted_body calls equations text tv state _ _ _ arguments input
        (body_library_imports source links.toBodyLinks text tv state _ _ _ arguments input)

end Silver.Compose.ProcedureDeclarationNative
