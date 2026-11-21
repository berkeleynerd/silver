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

/-- Local elaboration begins before formal views are installed. Named type
metadata may remain present; the object list is empty. -/
theorem ClosedFunctionState.stored {state : ParserState}
    (closed : ClosedFunctionState state) : state.StoredArrays := by
  simp [ParserState.StoredArrays, closed.noArrays]

theorem ClosedFunctionState.booleanContext {state : ParserState}
    (closed : ClosedFunctionState state) (parts : BooleanDeclarationParts) :
    ClosedFunctionContext (booleanDeclarationContext state parts) := by
  refine ClosedFunctionContext.ofEmpty closed.pure ?_ closed.noNames closed.noArrays
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

private theorem scalarExpression_noArray {expression : Integer.Expr}
    (absent : expression.hasArray = false) : scalarExpression expression = true := by
  induction expression <;> simp_all [Integer.Expr.hasArray, scalarExpression, frameExpression,
    Bool.or_eq_false_iff]

private theorem scalarExpression_freezeArrays (expression : Integer.Expr) (snapshot : Integer.Store) :
    scalarExpression (expression.freezeArrays snapshot) = true := by
  unfold Integer.Expr.freezeArrays
  split
  · rfl
  · rename_i absent
    exact scalarExpression_noArray (Bool.of_not_eq_true absent)

private theorem scalarCondition_freezeIntegers {condition : Condition}
    (scalar : scalarCondition condition = true) (snapshot : Integer.Store) :
    scalarCondition (condition.freezeIntegers snapshot) = true := by
  induction condition with
  | stringCompare | lengthCompare | characterCompare | inputValid | booleanArrayRead =>
      simp only [ScalarFunctions.scalarCondition, frameCondition, Bool.false_eq_true] at scalar
  | scalarCompare | booleanLiteral | booleanName => rfl
  | parenthesized inner ih | negated inner ih => exact ih scalar
  | andThen left right ihl ihr | orElse left right ihl ihr | eager operator left right ihl ihr | booleanCompare operator left right ihl ihr =>
      simp only [ScalarFunctions.scalarCondition, frameCondition, Bool.and_eq_true] at scalar
      exact Bool.and_eq_true_iff.mpr ⟨ihl scalar.1, ihr scalar.2⟩

theorem FunctionLocalsAt.scalar_only {text arguments state final integers booleans checks booleanChecks}
    (source : FunctionLocalsAt text arguments state integers booleans checks booleanChecks final)
    (closed : ClosedFunctionState state) :
    integers.all (fun item => scalarExpression item.value) = true ∧
      booleans.all (fun item => scalarCondition item.value) = true := by
  induction source with
  | done => exact ⟨rfl, rfl⟩
  | @integer before middle final declaration integers booleans firstChecks checks booleanChecks _ _ first _ _ _ ih =>
      have nextClosed : ClosedFunctionState middle := by
        cases first
        exact ⟨closed.pure, closed.noArguments, closed.noNames, closed.noArrays⟩
      have firstShape : scalarExpression declaration.value = true := by
        cases first
        exact scalarExpression_freezeArrays ..
      have following := ih nextClosed
      exact ⟨Bool.and_eq_true_iff.mpr ⟨firstShape, following.1⟩, following.2⟩
  | @boolean before middle final declaration integers booleans checks firstChecks booleanChecks _ _ _ first raw _ _ ih =>
      have nextClosed : ClosedFunctionState middle := by
        cases first
        exact ⟨closed.pure, closed.noArguments, closed.noNames, closed.noArrays⟩
      have firstShape : scalarCondition declaration.value = true := by
        obtain ⟨raw, reading, rfl, _⟩ := raw
        exact scalarCondition_freezeIntegers (condition_source_scalar (closed.booleanContext _) reading) _
      have following := ih nextClosed
      exact ⟨following.1, Bool.and_eq_true_iff.mpr ⟨firstShape, following.2⟩⟩

end Silver.Compose
