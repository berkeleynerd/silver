module

public import Silver.FunctionDeclarationOrdinaryEquations
public import Silver.FunctionBodyFrameReadiness

@[expose] public section

namespace Silver.Compose.FunctionDeclarationNative

/-- The actual Context_Of record with the local declaration prefix fixed
before formal installation. All dynamic-name and hiding fields are retained. -/
def bodyContext (state : ParserState) (declarations : Nat) : Predicate.Native.Context :=
  {nativeContextOf ⟨state, false, false⟩ with declarationCount := declarations}

theorem body_context_valid (text : Source) (state : ParserState) (declarations : Nat)
    (valid : NativeValidState text state) (count : declarations ≤ state.scalarNames.length) :
    Predicate.Native.ValidContext text (bodyContext state declarations) := by
  refine ⟨valid.base.2.1, valid.base.2.2.1,
    ScalarExpression.bodyEnvironment_valid valid.base.2.2.2.2.2.1,
    functionFrame_contextReady declarations valid.base valid.ready count,
    valid.base.2.2.2.2.2.2.1.1, valid.base.2.2.2.2.2.2.2.2.1,
    Or.inl ⟨rfl, rfl⟩, valid.bounds, valid.base.unit⟩

private theorem initial_path_bounded (arguments : Bool) : (Predicate.initialFacts arguments).Bounded := by
  cases arguments
  · exact Nat.zero_le _
  · exact PathFacts.Context.initial_bounded (Nat.le_refl _)

theorem body_initial_valid (text : Source) (state : ParserState) (declarations : Nat)
    (valid : NativeValidState text state) :
    BodyScanInput text (bodyContext state declarations) (Predicate.bodyOf ⟨state, false, false⟩) := by
  refine ⟨valid.base.1, ⟨valid.base.2.2.2.1, valid.base.2.2.2.2.1⟩,
    initial_path_bounded _, ?_⟩
  exact functionFrame_flowReady declarations valid.base valid.ready
    (Predicate.initialFacts (decide (state.dynamicFirst ≠ 0)))

end Silver.Compose.FunctionDeclarationNative
