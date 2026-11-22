module

public import Silver.BooleanBindings
public import Silver.ScalarExpression
public import Silver.PredicateSemantics

@[expose] public section

/-! Exact values used during bounded package elaboration. The evaluator can
return a value only when every referenced Boolean is known and every Integer
operand has a singleton inferred interval. Body analysis remains independent
of these exact values. -/
namespace Silver.BooleanElaboration

def binary (operation : Bool → Bool → Bool) (left right : Option Bool) : Option Bool :=
  match left, right with
  | some a, some b => some (operation a b)
  | _, _ => none

def evaluate (scalars : ScalarExpression.Environment) (booleans : BooleanBindings.Environment) :
    Predicate.Condition → Option Bool
  | .booleanLiteral value => some value
  | .booleanName index =>
      if 0 < index ∧ index ≤ booleans.length ∧ (BooleanBindings.binding booleans index).known = true
      then some (BooleanBindings.binding booleans index).value else none
  | .scalarCompare operation left right =>
      match left.infer (ScalarExpression.ranges scalars), right.infer (ScalarExpression.ranges scalars) with
      | some a, some b =>
          if a.lower = a.upper ∧ b.lower = b.upper then some (operation.evaluate a.lower b.lower)
          else none
      | _, _ => none
  | .parenthesized inner => evaluate scalars booleans inner
  | .negated inner => (evaluate scalars booleans inner).map Bool.not
  | .andThen left right => binary (· && ·) (evaluate scalars booleans left) (evaluate scalars booleans right)
  | .orElse left right => binary (· || ·) (evaluate scalars booleans left) (evaluate scalars booleans right)
  | .eager operation left right =>
      binary operation.evaluate (evaluate scalars booleans left) (evaluate scalars booleans right)
  | .booleanCompare unequal left right =>
      binary (fun a b => if unequal then a != b else a == b)
        (evaluate scalars booleans left) (evaluate scalars booleans right)
  | _ => none

theorem binary_success {operation : Bool → Bool → Bool} {left right : Option Bool} {value : Bool}
    (success : binary operation left right = some value) :
    ∃ a b, left = some a ∧ right = some b ∧ operation a b = value := by
  cases left with
  | none => cases success
  | some a =>
    cases right with
    | none => cases success
    | some b => exact ⟨a, b, rfl, rfl, Option.some.inj success⟩

theorem singleton_infer_value {ranges : Integer.Ranges} {values : Integer.Store}
    {expression : Integer.Expr} {bounds : Integer.Interval}
    (inferred : expression.infer ranges = some bounds) (fits : Integer.Fits ranges values)
    (singleton : bounds.lower = bounds.upper) : expression.evaluate values = bounds.lower := by
  have contained := (expression.infer_sound inferred fits).1
  change bounds.lower ≤ expression.evaluate values ∧ expression.evaluate values ≤ bounds.upper at contained
  omega

/-- This conclusion quantifies over every fitting store. No sample or chosen
initial store is substituted for the declared Integer/Boolean domains. -/
theorem evaluate_sound {scalars : ScalarExpression.Environment} {booleans : BooleanBindings.Environment}
    {integers : Integer.Store} {flags : Boolean.Store}
    (scalarFits : Integer.Fits (ScalarExpression.ranges scalars) integers)
    (booleanFits : BooleanBindings.KnownFits booleans flags)
    (values : Bindings.Values) (input : Source) (inputValid : Bool)
    (condition : Predicate.Condition) (value : Bool)
    (accepted : evaluate scalars booleans condition = some value) :
    condition.evaluate values input inputValid integers flags = value := by
  induction condition generalizing value with
  | booleanLiteral literal =>
      exact Option.some.inj accepted
  | booleanName index =>
      simp only [evaluate] at accepted
      split at accepted
      · rename_i known
        have exactValue := booleanFits index known.1 known.2.1 known.2.2
        exact exactValue.trans (Option.some.inj accepted)
      · cases accepted
  | scalarCompare operation left right =>
      simp only [evaluate] at accepted
      cases leftResult : left.infer (ScalarExpression.ranges scalars) with
      | none => simp [leftResult] at accepted
      | some a =>
        cases rightResult : right.infer (ScalarExpression.ranges scalars) with
        | none => simp [leftResult, rightResult] at accepted
        | some b =>
          simp only [leftResult, rightResult] at accepted
          split at accepted
          · rename_i singleton
            have l := singleton_infer_value leftResult scalarFits singleton.1
            have r := singleton_infer_value rightResult scalarFits singleton.2
            simpa only [Predicate.Condition.evaluate, l, r] using Option.some.inj accepted
          · cases accepted
  | parenthesized inner ih => exact ih value accepted
  | negated inner ih =>
      simp only [evaluate, Option.map_eq_some_iff] at accepted
      obtain ⟨old, found, equal⟩ := accepted
      simp only [Predicate.Condition.evaluate, ih old found]
      exact equal
  | andThen left right leftIH rightIH =>
      obtain ⟨a, b, leftFound, rightFound, equal⟩ := binary_success accepted
      simp only [Predicate.Condition.evaluate, leftIH a leftFound, rightIH b rightFound]
      cases a <;> simpa using equal
  | orElse left right leftIH rightIH =>
      obtain ⟨a, b, leftFound, rightFound, equal⟩ := binary_success accepted
      simp only [Predicate.Condition.evaluate, leftIH a leftFound, rightIH b rightFound]
      cases a <;> simpa using equal
  | eager operation left right leftIH rightIH =>
      obtain ⟨a, b, leftFound, rightFound, equal⟩ := binary_success accepted
      simpa only [Predicate.Condition.evaluate, leftIH a leftFound, rightIH b rightFound] using equal
  | booleanCompare unequal left right leftIH rightIH =>
      obtain ⟨a, b, leftFound, rightFound, equal⟩ := binary_success accepted
      simpa only [Predicate.Condition.evaluate, leftIH a leftFound, rightIH b rightFound] using equal
  | stringCompare | lengthCompare | characterCompare | inputValid | booleanArrayRead => cases accepted

end Silver.BooleanElaboration
