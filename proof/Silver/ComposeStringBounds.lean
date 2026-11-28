module

public import Silver.ComposeStringAtomBounds
public import Silver.ComposeSemantics

@[expose] public section

namespace Silver.Compose

variable {contextFirst : Nat}
open Bindings StringObjectBounds

structure ExpressionResult.ContainsBounds (result : ExpressionResult) (bounds : Bounds) : Prop where
  first : result.firstIndex.Contains bounds.first
  last : result.lastIndex.Contains bounds.last
  minimum : result.minimumLength ≤ bounds.length
  maximum : bounds.length ≤ result.staticLength

def Expression.foldBounds (expression : Expression) (names : BindingEnvironment) (input : Source)
    (integers : Integer.Store) (initial : Bounds) : Bounds :=
  expression.foldl (fun previous atom => previous.concatenate (atom.objectBounds names input integers)) initial

def Expression.objectBounds (expression : Expression) (names : BindingEnvironment) (input : Source)
    (integers : Integer.Store) : Bounds := expression.foldBounds names input integers (.canonical 0)

theorem emission_objectBounds {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials} {state : ExpressionState}
    {emitted : Expression} {bounds : Bounds} {integers : Integer.Store}
    (input : Source) (normal : NamesNormal names)
    (scalars : Integer.Fits (ArrayBindings.viewRanges arrays.items initials true (ScalarExpression.ranges scalarNames)) integers)
    (positive : state.position ≠ 0) (unfinished : state.complete = false)
    (accepted : (expressionStep (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden)
      (arrays := arrays) (initials := initials) (elaborating := true) text names state).position ≠ 0)
    (fixed : (expressionStep (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden)
      (arrays := arrays) (initials := initials) (elaborating := true) text names state).dynamicCount = 0)
    (before : state.ContainsBounds bounds)
    (parsed : EmissionAt (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden)
      (arrays := arrays) (initials := initials) (elaborating := true) text names state emitted) :
    (expressionStep (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden)
      (arrays := arrays) (initials := initials) (elaborating := true) text names state).ContainsBounds
      (emitted.foldBounds names input integers bounds) := by
  by_cases reading : state.needOperand = true ∧ fixedAfter text state.position "(" false = 0
  · rw [EmissionAt, ite_eq_left reading] at parsed
    obtain ⟨atom, source, rfl⟩ := parsed
    simp only [expressionStep, positive, unfinished, Bool.false_eq_true, ↓reduceIte, reading.1,
      reading.2, ne_eq, not_true_eq_false] at accepted fixed ⊢
    generalize rawEq : valueAt (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden)
      (arrays := arrays) (initials := initials) (elaborating := true) text state.position names = raw at accepted fixed source ⊢
    split at accepted
    · simp [invalidExpressionState] at accepted
    · rename_i allowed
      rw [ite_eq_right allowed] at fixed ⊢
      change state.dynamicCount + (if raw.dynamicSeen then 1 else 0) = 0 at fixed
      have fixedLeft : state.dynamicCount = 0 := by split at fixed <;> omega
      have fixedRight : raw.dynamicSeen = false := by
        cases seen : raw.dynamicSeen
        · rfl
        · simp [seen] at fixed
      have lastKnown : (concatenatedLast state raw).isEmpty = false := by
        cases known : (concatenatedLast state raw).isEmpty
        · rfl
        · simp [fixedLeft, fixedRight, known] at allowed
      have next := value_fixed_bounds input normal scalars source fixedRight
      have result := concatenated_bounds before next fixedLeft fixedRight lastKnown (value_operands source).2.1
      rcases result with ⟨first, last, minimum, maximum, empty⟩
      simp only [fixedLeft, fixedRight, decide_true, Bool.true_and, Bool.not_false,
        Expression.foldBounds, List.foldl_cons, List.foldl_nil]
      exact ⟨first, last, minimum, maximum, empty⟩
  · rw [EmissionAt, ite_eq_right reading] at parsed
    subst emitted
    simp only [Expression.foldBounds, List.foldl_nil]
    rcases before with ⟨first, last, minimum, maximum, empty⟩
    by_cases need : state.needOperand = true
    · have opening : fixedAfter text state.position "(" false ≠ 0 := fun absent => reading ⟨need, absent⟩
      simp only [expressionStep, positive, unfinished, Bool.false_eq_true, ↓reduceIte, need]
      rw [ite_eq_left opening]
      exact ⟨first, last, minimum, maximum, empty⟩
    · simp only [expressionStep, positive, unfinished, Bool.false_eq_true, ↓reduceIte, need] at accepted ⊢
      split
      · exact ⟨first, last, minimum, maximum, empty⟩
      · rename_i noJoin
        split
        · exact ⟨first, last, minimum, maximum, empty⟩
        · rename_i noClose
          split
          · exact ⟨first, last, minimum, maximum, empty⟩
          · rename_i noEnd
            simp only [noJoin, noClose, noEnd, ↓reduceIte, invalidExpressionState] at accepted
            contradiction

theorem expressionTail_objectBounds {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials}
    {state : ExpressionState} {expression : Expression} {result : ExpressionResult}
    {bounds : Bounds} {integers : Integer.Store} (input : Source) (normal : NamesNormal names)
    (scalars : Integer.Fits (ArrayBindings.viewRanges arrays.items initials true (ScalarExpression.ranges scalarNames)) integers)
    (bounded : state.operands ≤ maxExpressionOperands)
    (before : state.ContainsBounds bounds)
    (parsed : ExpressionTailAt (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden)
      (arrays := arrays) (initials := initials) (elaborating := true) text names state expression result)
    (fixed : result.dynamicCount = 0) : result.ContainsBounds (expression.foldBounds names input integers bounds) := by
  induction parsed generalizing bounds with
  | done => exact ⟨before.first, before.last, before.minimum, before.maximum⟩
  | last positive unfinished accepted completed emitted =>
      have next := emission_objectBounds input normal scalars positive unfinished accepted fixed before emitted
      exact ⟨next.first, next.last, next.minimum, next.maximum⟩
  | next positive unfinished accepted incomplete advancing emitted rest ih =>
      rename_i scan emittedExpression restExpression finalResult
      obtain ⟨_, _, facts⟩ := emission_accounting normal positive unfinished accepted bounded emitted
      obtain ⟨summary, _, accumulated⟩ := expressionTail_summary normal facts.2.2.1 rest
      have count := congrArg LengthSummary.dynamicCount accumulated
      simp only [ExpressionResult.lengthSummary, ExpressionState.lengthSummary, LengthSummary.add] at count
      have fixedNext : (expressionStep (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden)
          (arrays := arrays) (initials := initials) (elaborating := true) text names scan).dynamicCount = 0 := by
        omega
      have next := emission_objectBounds input normal scalars positive unfinished accepted fixedNext before emitted
      have remaining := ih facts.2.2.1 next fixed
      simpa only [Expression.foldBounds, List.foldl_append] using remaining

theorem expressionAt_objectBounds {text : Source} {names : BindingEnvironment}
    {scalarNames : ScalarExpression.Environment} {integerHidden : Bool}
    {arrays : ArrayBindings.Table} {initials : ArrayBindings.Initials}
    {position : Nat} {expression : Expression} {result : ExpressionResult} {integers : Integer.Store}
    (input : Source) (normal : NamesNormal names)
    (scalars : Integer.Fits (ArrayBindings.viewRanges arrays.items initials true (ScalarExpression.ranges scalarNames)) integers)
    (parsed : ExpressionAt (contextFirst := contextFirst) (scalarNames := scalarNames) (integerHidden := integerHidden)
      (arrays := arrays) (initials := initials) (elaborating := true) text names position expression result)
    (fixed : result.dynamicCount = 0) : result.ContainsBounds (expression.objectBounds names input integers) :=
  expressionTail_objectBounds input normal scalars (by simp) (ExpressionState.emptyBounds position) parsed fixed

theorem ExpressionResult.ContainsBounds.singleton {result : ExpressionResult} {bounds : Bounds}
    (known : result.ContainsBounds bounds)
    (first : result.firstIndex.lower = result.firstIndex.upper)
    (last : result.lastIndex.lower = result.lastIndex.upper) :
    bounds = ⟨result.firstIndex.lower, result.lastIndex.lower⟩ := by
  have lower := known.first
  have upper := known.last
  simp only [Integer.Interval.Contains] at lower upper
  cases bounds
  simp only [Bounds.mk.injEq]
  dsimp only at lower upper
  exact ⟨by omega, by omega⟩

end Silver.Compose
