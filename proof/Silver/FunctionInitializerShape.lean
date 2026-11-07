module

public import Silver.FunctionDeclarationMeaning
public import Silver.PredicateFunctionCallMeaning
public import Silver.ScalarFunctionFrozenBoolean

@[expose] public section

namespace Silver.Compose
open Predicate ScalarFunctions

structure ClosedFunctionState (state : ParserState) : Prop where
  pure : state.pure = true
  noArguments : state.dynamicFirst = 0
  noNames : state.names = []
  noArrays : state.arrayNames.names = []

theorem ClosedFunctionState.booleanContext {state : ParserState}
    (closed : ClosedFunctionState state) (parts : BooleanDeclarationParts) :
    ClosedFunctionContext (booleanDeclarationContext state parts) := by
  refine ⟨closed.pure, ?_, closed.noNames, closed.noArrays⟩
  simp only [booleanDeclarationContext, closed.noArguments, ne_eq, not_true_eq_false, decide_false]

theorem FunctionLocalsAt.closed {text arguments state final integers booleans checks booleanChecks}
    (source : FunctionLocalsAt text arguments state integers booleans checks booleanChecks final)
    (closed : ClosedFunctionState state) : ClosedFunctionState final := by
  have kept := source.preserves
  exact ⟨kept.pure.trans closed.pure, kept.dynamicFirst.trans closed.noArguments,
    kept.names.trans closed.noNames, by rw [kept.arrayNames]; exact closed.noArrays⟩

theorem FunctionLocalsAt.boolean_checks_independent
    {text arguments state final integers booleans checks booleanChecks}
    (source : FunctionLocalsAt text arguments state integers booleans checks booleanChecks final)
    (closed : ClosedFunctionState state)
    (leftShape rightShape : Bindings.Shape) (leftAnalysis rightAnalysis : Integer.Analysis)
    (leftFlow rightFlow : Flow) (before : Boolean.Analysis) :
    checkBooleanDeclarations leftShape leftAnalysis leftFlow before booleans =
      checkBooleanDeclarations rightShape rightAnalysis rightFlow before booleans := by
  induction source generalizing before with
  | done => rfl
  | @integer stateBefore middle final declaration integers booleans firstChecks checks booleanChecks _ _ first _ _ _ ih =>
      have nextClosed : ClosedFunctionState middle := by
        cases first
        exact ⟨closed.pure, closed.noArguments, closed.noNames, closed.noArrays⟩
      exact ih nextClosed before
  | @boolean stateBefore middle final declaration integers booleans checks firstChecks booleanChecks _ _ _ first raw _ _ ih =>
      have nextClosed : ClosedFunctionState middle := by
        cases first
        exact ⟨closed.pure, closed.noArguments, closed.noNames, closed.noArrays⟩
      obtain ⟨raw, reading, rfl, _⟩ := raw
      have scalar := condition_source_scalar (closed.booleanContext _) reading
      simp only [checkBooleanDeclarations]
      rw [frozenScalarCondition_checkBounds scalar _ leftShape rightShape
        leftAnalysis rightAnalysis leftFlow rightFlow before]
      rw [ih nextClosed]

end Silver.Compose
