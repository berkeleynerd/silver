module

public import Silver.PredicateSyntax

@[expose] public section

/-! Predicate meaning and a separate checked evaluator. Both String operands
are evaluated in the incoming store. Short-circuit forms do not evaluate an
unselected right operand. Path facts will establish Safe at each reached call. -/

namespace Silver.Predicate
open Bindings Compose

def Comparison.evaluate (left right : Nat) : Comparison → Bool
  | .eq => decide (left = right)
  | .ne => decide (left ≠ right)
  | .lt => decide (left < right)
  | .le => decide (left ≤ right)
  | .gt => decide (left > right)
  | .ge => decide (left ≥ right)

def LengthOperand.evaluate (values : Values) : LengthOperand → Nat
  | .literal value => value
  | .binding index => (values index).length

def Condition.evaluate (values : Values) (input : Source) (inputValid : Bool)
    (integers : Integer.Store := Integer.emptyStore)
    (booleans : Boolean.Store := Boolean.emptyStore) : Condition → Bool
  | .stringCompare unequal left right =>
      if unequal then decide (left.evaluate values input integers ≠ right.evaluate values input integers)
      else decide (left.evaluate values input integers = right.evaluate values input integers)
  | .lengthCompare operator left right => operator.evaluate (values left).length (right.evaluate values)
  | .scalarCompare operator left right => operator.evaluate (left.evaluate integers) (right.evaluate integers)
  | .inputValid => inputValid
  | .booleanLiteral value => value
  | .booleanName index => booleans index
  | .parenthesized inner => inner.evaluate values input inputValid integers booleans
  | .negated inner => !(inner.evaluate values input inputValid integers booleans)
  | .andThen left right =>
      if left.evaluate values input inputValid integers booleans then right.evaluate values input inputValid integers booleans else false
  | .orElse left right =>
      if left.evaluate values input inputValid integers booleans then true else right.evaluate values input inputValid integers booleans

  | .eager operator left right =>
      operator.evaluate (left.evaluate values input inputValid integers booleans)
        (right.evaluate values input inputValid integers booleans)
  | .booleanCompare unequal left right =>
      if unequal then left.evaluate values input inputValid integers booleans != right.evaluate values input inputValid integers booleans
      else left.evaluate values input inputValid integers booleans == right.evaluate values input inputValid integers booleans

/-- Bounds are required precisely on paths which evaluate an operand. Name and
grammar checking remain separate unconditional admission obligations. -/
def Condition.Safe (shape : Shape) (values : Values) (input : Source) (inputValid : Bool)
    (integers : Integer.Store := Integer.emptyStore)
    (booleans : Boolean.Store := Boolean.emptyStore) : Condition → Prop
  | .stringCompare _ left right =>
      left.RuntimeSafe values input integers ∧ right.RuntimeSafe values input integers
  | .lengthCompare _ left right =>
      (values left).length ≤ maxSourceLength ∧ right.evaluate values ≤ maxSourceLength
  | .scalarCompare _ left right => left.Safe integers ∧ right.Safe integers
  | .inputValid | .booleanLiteral _ | .booleanName _ => True
  | .parenthesized inner | .negated inner => inner.Safe shape values input inputValid integers booleans
  | .andThen left right =>
      left.Safe shape values input inputValid integers booleans ∧
        (left.evaluate values input inputValid integers booleans = true → right.Safe shape values input inputValid integers booleans)
  | .orElse left right =>
      left.Safe shape values input inputValid integers booleans ∧
        (left.evaluate values input inputValid integers booleans = false → right.Safe shape values input inputValid integers booleans)

  | .eager _ left right | .booleanCompare _ left right =>
      left.Safe shape values input inputValid integers booleans ∧
        right.Safe shape values input inputValid integers booleans

def Condition.checkedEvaluate (values : Values) (input : Source) (inputValid : Bool)
    (integers : Integer.Store := Integer.emptyStore)
    (booleans : Boolean.Store := Boolean.emptyStore) : Condition → Option Bool
  | .stringCompare unequal left right =>
      (left.checkedEvaluate values input integers).bind fun a =>
        (right.checkedEvaluate values input integers).map fun b =>
          if unequal then decide (a ≠ b) else decide (a = b)
  | .lengthCompare operator left right =>
      if (values left).length ≤ maxSourceLength ∧ right.evaluate values ≤ maxSourceLength then
        some (operator.evaluate (values left).length (right.evaluate values))
      else none
  | .scalarCompare operator left right => (left.checkedEvaluate integers).bind fun a =>
      (right.checkedEvaluate integers).map fun b => operator.evaluate a b
  | .inputValid => some inputValid
  | .booleanLiteral value => some value
  | .booleanName index => some (booleans index)
  | .parenthesized inner => inner.checkedEvaluate values input inputValid integers booleans
  | .negated inner => (inner.checkedEvaluate values input inputValid integers booleans).map Bool.not
  | .andThen left right => (left.checkedEvaluate values input inputValid integers booleans).bind fun result =>
      if result then right.checkedEvaluate values input inputValid integers booleans else some false
  | .orElse left right => (left.checkedEvaluate values input inputValid integers booleans).bind fun result =>
      if result then some true else right.checkedEvaluate values input inputValid integers booleans

  | .eager operator left right =>
      (left.checkedEvaluate values input inputValid integers booleans).bind fun a =>
        (right.checkedEvaluate values input inputValid integers booleans).map fun b => operator.evaluate a b
  | .booleanCompare unequal left right =>
      (left.checkedEvaluate values input inputValid integers booleans).bind fun a =>
        (right.checkedEvaluate values input inputValid integers booleans).map fun b =>
          if unequal then a != b else a == b

theorem LengthOperand.evaluate_summary {operand : LengthOperand} {shape : Shape}
    {values : Values} {input : Source} {summary : Summary}
    (state : Fits shape input values) (found : operand.summary shape = some summary) :
    operand.evaluate values = summary.length input.length := by
  cases operand with
  | literal value => cases found; simp [evaluate, Summary.length]
  | binding index =>
      simp only [LengthOperand.summary, Option.map_eq_some_iff] at found
      obtain ⟨info, found, rfl⟩ := found
      simpa only [evaluate, Bound.summary_length] using (state index info found).1

theorem Condition.checkedEvaluate_refines {condition : Condition} {shape : Shape}
    {values : Values} {input : Source} {inputValid : Bool} {integers : Integer.Store} {booleans : Boolean.Store}
    (safe : condition.Safe shape values input inputValid integers booleans) (_state : Fits shape input values) :
    condition.checkedEvaluate values input inputValid integers booleans =
      some (condition.evaluate values input inputValid integers booleans) := by
  induction condition with
  | stringCompare unequal left right =>
      simp only [checkedEvaluate, Expression.checkedEvaluate_agrees safe.1,
        Expression.checkedEvaluate_agrees safe.2, Option.bind_some, Option.map_some, evaluate]
  | lengthCompare operator left right =>
      change (values left).length ≤ maxSourceLength ∧ right.evaluate values ≤ maxSourceLength at safe
      simp only [checkedEvaluate, safe, and_self, ↓reduceIte, evaluate]
  | scalarCompare operator left right =>
      simp only [checkedEvaluate, Integer.Expr.checkedEvaluate_agrees safe.1,
        Integer.Expr.checkedEvaluate_agrees safe.2, Option.bind_some, Option.map_some, evaluate]
  | inputValid | booleanLiteral _ | booleanName _ => rfl
  | parenthesized inner ih => exact ih safe
  | negated inner ih => simp only [checkedEvaluate, ih safe, Option.map_some, evaluate]
  | andThen left right ihl ihr =>
      simp only [checkedEvaluate, ihl safe.1, Option.bind_some, evaluate]
      split
      · rename_i reached
        exact ihr (safe.2 reached)
      · rfl
  | orElse left right ihl ihr =>
      simp only [checkedEvaluate, ihl safe.1, Option.bind_some, evaluate]
      split
      · rfl
      · rename_i skipped
        have falseLeft : left.evaluate values input inputValid integers booleans = false := Bool.eq_false_iff.mpr skipped
        exact ihr (safe.2 falseLeft)

  | eager operator left right ihl ihr | booleanCompare operator left right ihl ihr =>
      simp only [checkedEvaluate, ihl safe.1, ihr safe.2, Option.bind_some, Option.map_some, evaluate]

/-- Equal String bytes imply equal affine lengths. A false String equality
deliberately supplies no inequality about lengths. -/
theorem string_equality_lengths {left right : Expression} {shape : Shape}
    {values : Values} {input : Source} {valid : Bool}
    (state : Fits shape input values) (leftNames : left.Readable shape)
    (rightNames : right.Readable shape)
    (equal : (Condition.stringCompare false left right).evaluate values input valid = true) :
    (left.summary shape).length input.length = (right.summary shape).length input.length := by
  simp only [Condition.evaluate, Bool.false_eq_true, ↓reduceIte, decide_eq_true_eq] at equal
  have lengths := congrArg List.length equal
  simpa only [Expression.evaluate_length state leftNames,
    Expression.evaluate_length state rightNames, Expression.summary, Summary.length] using lengths

theorem string_inequality_false_lengths {left right : Expression} {shape : Shape}
    {values : Values} {input : Source} {valid : Bool}
    (state : Fits shape input values) (leftNames : left.Readable shape)
    (rightNames : right.Readable shape)
    (equal : (Condition.stringCompare true left right).evaluate values input valid = false) :
    (left.summary shape).length input.length = (right.summary shape).length input.length := by
  apply string_equality_lengths (valid := valid) state leftNames rightNames
  simpa [Condition.evaluate] using equal

theorem andThen_skips_right {left right : Condition} {values : Values} {input : Source}
    {valid : Bool} (skipped : left.checkedEvaluate values input valid = some false) :
    (Condition.andThen left right).checkedEvaluate values input valid = some false := by
  simp only [Condition.checkedEvaluate, skipped, Option.bind_some, Bool.false_eq_true, ↓reduceIte]

theorem orElse_skips_right {left right : Condition} {values : Values} {input : Source}
    {valid : Bool} (skipped : left.checkedEvaluate values input valid = some true) :
    (Condition.orElse left right).checkedEvaluate values input valid = some true := by
  simp only [Condition.checkedEvaluate, skipped, Option.bind_some, ↓reduceIte]

end Silver.Predicate
