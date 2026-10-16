module

public import Silver.ComposeSemantics
public import Silver.StringFreezing
public import Silver.ScalarExpressionConstants

@[expose] public section

namespace Silver.Compose
open Bindings

def frozenIntegers (names : ScalarExpression.Environment) : Integer.Store :=
  Integer.Constants.store (ScalarExpression.constants names)

theorem frozenIntegers_fits {names : ScalarExpression.Environment}
    (static : ScalarExpression.StaticEnvironment names) :
    Integer.Fits (ScalarExpression.ranges names) (frozenIntegers names) := by
  rw [ScalarExpression.static_ranges static]
  exact Integer.Constants.fits _

theorem expressionAt_frozen_summary {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool} {position : Nat}
    {expression : Expression} {result : ExpressionResult}
    (normal : NamesNormal names) (static : ScalarExpression.StaticEnvironment scalarNames)
    (parsed : ExpressionAt (scalarNames := scalarNames) (integerHidden := integerHidden) text names position expression result)
    (exact : result.minimumLength = result.staticLength) :
    (expression.freezeImages (frozenIntegers scalarNames)).summary names.shape =
      ⟨result.staticLength, result.dynamicCount⟩ := by
  have inferred := expressionAt_inferLength normal parsed
  have scalars := frozenIntegers_fits static
  have nonempty := (Expression.freezeImages_contains inferred scalars 0).1
  change result.emptyValue = false at nonempty
  apply Expression.freezeImages_summary inferred _ scalars
  simp only [LengthSummary.exact, ExpressionResult.lengthSummary, nonempty, Bool.not_false,
    exact, decide_true, Bool.and_self, ↓reduceIte, LengthSummary.upper]

theorem expressionAt_safe {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool} {position capacity : Nat}
    {expression : Expression} {result : ExpressionResult}
    (normal : NamesNormal names) (static : ScalarExpression.StaticEnvironment scalarNames)
    (parsed : ExpressionAt (scalarNames := scalarNames) (integerHidden := integerHidden) text names position expression result)
    (bounded : fits result capacity = true) :
    SafeExpression (expression.freezeImages (frozenIntegers scalarNames)) names.shape capacity := by
  have known := expressionAt_inferLength normal parsed
  have scalars := frozenIntegers_fits static
  have nonempty := (Expression.freezeImages_contains known scalars 0).1
  change result.emptyValue = false at nonempty
  have bound : result.lengthSummary.upper.length capacity ≤ maxSourceLength := by
    have checked := (decide_eq_true_eq.mp bounded).2
    simpa only [nonempty, Bool.false_eq_true, false_or, ExpressionResult.lengthSummary,
      LengthSummary.upper, Summary.length] using checked
  exact Expression.freezeImages_safe known scalars (expressionTail_readable parsed).2
    (expressionTail_nonempty normal (by simp) rfl rfl parsed)
    (by simpa using expressionTail_count normal (by simp) parsed) bound

/-- Checked evaluation of the actual source Image expressions agrees with
its immutable specialization, including every scalar arithmetic check. -/
theorem expressionAt_frozen_execution {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool} {position capacity : Nat}
    {expression : Expression} {result : ExpressionResult} {values : Values} {input : Source}
    (normal : NamesNormal names) (static : ScalarExpression.StaticEnvironment scalarNames)
    (parsed : ExpressionAt (scalarNames := scalarNames) (integerHidden := integerHidden) text names position expression result)
    (bounded : fits result capacity = true) (state : Fits names.shape input values)
    (inputBound : input.length ≤ capacity) :
    expression.checkedEvaluate values input (frozenIntegers scalarNames) =
      some ((expression.freezeImages (frozenIntegers scalarNames)).evaluate values input) := by
  have frozenSafe := expressionAt_safe normal static parsed bounded
  have safe : expression.RuntimeSafe values input (frozenIntegers scalarNames) := by
    refine ⟨(Expression.inferLength_sound (expressionAt_inferLength normal parsed) state
      (frozenIntegers_fits static)).2, ?_⟩
    rw [← Expression.freezeImages_evaluate]
    exact Expression.output_bound frozenSafe state inputBound
  rw [Expression.checkedEvaluate_agrees safe, Expression.freezeImages_evaluate]

end Silver.Compose
