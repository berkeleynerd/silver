module

public import Silver.ComposeSemantics
public import Silver.StringFreezing
public import Silver.ScalarExpressionConstants

@[expose] public section

namespace Silver.Compose
open Bindings

def frozenIntegers (names : ScalarExpression.Environment)
    (arrays : ArrayBindings.Metadata := []) (initials : ArrayBindings.Initials := []) : Integer.Store :=
  ArrayBindings.integerStore arrays initials (Integer.Constants.store (ScalarExpression.constants names))

theorem frozenIntegers_fits {names : ScalarExpression.Environment}
    {arrays : ArrayBindings.Metadata} {initials : ArrayBindings.Initials}
    (static : ScalarExpression.StaticEnvironment names) :
    Integer.Fits (ArrayBindings.integerRanges arrays initials true (ScalarExpression.ranges names))
      (frozenIntegers names arrays initials) := by
  apply ArrayBindings.initial_ranges_fits
  rw [ScalarExpression.static_ranges static]
  exact Integer.Constants.fits _

/-- Declaration-time snapshots contain physical array cells. Input views are
introduced only after local elaboration and retain their full component domains. -/
theorem frozenIntegers_view_fits {names : ScalarExpression.Environment}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials}
    (static : ScalarExpression.StaticEnvironment names)
    (stored : ∀ item ∈ arrays.items, item.viewSlot = 0) :
    Integer.Fits (ArrayBindings.viewRanges arrays.items initials true (ScalarExpression.ranges names))
      (frozenIntegers names arrays.items initials) := by
  rw [ArrayBindings.viewRanges_stored stored]
  exact frozenIntegers_fits static

theorem expressionAt_frozen_summary {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {position : Nat}
    {expression : Expression} {result : ExpressionResult}
    (normal : NamesNormal names) (static : ScalarExpression.StaticEnvironment scalarNames)
    (stored : ∀ item ∈ arrays.items, item.viewSlot = 0)
    (parsed : ExpressionAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := true) text names position expression result)
    (exact : result.minimumLength = result.staticLength) :
    (expression.freezeImages (frozenIntegers scalarNames arrays.items initials)).summary names.shape =
      ⟨result.staticLength, result.dynamicCount⟩ := by
  have inferred := expressionAt_inferLength normal parsed
  have scalars := frozenIntegers_view_fits (arrays := arrays) (initials := initials) static stored
  have nonempty := (Expression.freezeImages_contains inferred scalars 0).1
  change result.emptyValue = false at nonempty
  apply Expression.freezeImages_summary inferred _ scalars
  simp only [LengthSummary.exact, ExpressionResult.lengthSummary, nonempty, Bool.not_false,
    exact, decide_true, Bool.and_self, ↓reduceIte, LengthSummary.upper]

theorem expressionAt_safe {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {position capacity : Nat}
    {expression : Expression} {result : ExpressionResult}
    (normal : NamesNormal names) (static : ScalarExpression.StaticEnvironment scalarNames)
    (stored : ∀ item ∈ arrays.items, item.viewSlot = 0)
    (parsed : ExpressionAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := true) text names position expression result)
    (bounded : fits result capacity = true) :
    SafeExpression (expression.freezeImages (frozenIntegers scalarNames arrays.items initials)) names.shape capacity := by
  have known := expressionAt_inferLength normal parsed
  have scalars := frozenIntegers_view_fits (arrays := arrays) (initials := initials) static stored
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
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {position capacity : Nat}
    {expression : Expression} {result : ExpressionResult} {values : Values} {input : Source}
    (normal : NamesNormal names) (static : ScalarExpression.StaticEnvironment scalarNames)
    (stored : ∀ item ∈ arrays.items, item.viewSlot = 0)
    (parsed : ExpressionAt (scalarNames := scalarNames) (integerHidden := integerHidden) (arrays := arrays) (initials := initials) (elaborating := true) text names position expression result)
    (bounded : fits result capacity = true) (state : Fits names.shape input values)
    (inputBound : input.length ≤ capacity) :
    expression.checkedEvaluate values input (frozenIntegers scalarNames arrays.items initials) =
      some ((expression.freezeImages (frozenIntegers scalarNames arrays.items initials)).evaluate values input) := by
  have frozenSafe := expressionAt_safe normal static stored parsed bounded
  have safe : expression.RuntimeSafe values input (frozenIntegers scalarNames arrays.items initials) := by
    refine ⟨(Expression.inferLength_sound (expressionAt_inferLength normal parsed) state
      (frozenIntegers_view_fits (arrays := arrays) (initials := initials) static stored)).2, ?_⟩
    rw [← Expression.freezeImages_evaluate]
    exact Expression.output_bound frozenSafe state inputBound
  rw [Expression.checkedEvaluate_agrees safe, Expression.freezeImages_evaluate]

end Silver.Compose
