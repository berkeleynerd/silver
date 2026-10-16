module

public import Silver.GuardedDecimal
public import Silver.Bindings

@[expose] public section

/-! Shared flat String expressions over initialized binding indices. Bounds are
read from the fixed binding shape; bytes are read from the current value store.
Aliases of the input each contribute a dynamic occurrence. -/

namespace Silver.Compose

open Bindings

def Expression.Bounded (expression : Expression) (shape : Shape) (capacity : Nat) : Prop :=
  expression ≠ [] ∧ expression.length ≤ maxExpressionOperands ∧
    expression.staticLength shape + expression.dynamicCount shape * capacity ≤ maxSourceLength

def SafeExpression (expression : Expression) (shape : Shape) (capacity : Nat) : Prop :=
  expression.Readable shape ∧ expression.LiteralsPrintable ∧ expression.Bounded shape capacity

theorem declaration_safe {shape : Shape} {declaration : Declaration} {bound : Bound}
    (valid : declaration.Valid shape bound) :
    SafeExpression declaration.initializer shape maxSourceLength := by
  obtain ⟨readable, summary⟩ := Expression.infer_iff.mp valid.2.1
  refine ⟨readable, valid.2.2.1, valid.2.2.2.1, valid.2.2.2.2.1, ?_⟩
  change (declaration.initializer.summary shape).length maxSourceLength ≤ maxSourceLength
  rw [summary, Bound.summary_length]
  exact valid.2.2.2.2.2

theorem Expression.output_bound {expression : Expression} {shape : Shape}
    {values : Values} {input : Source} {capacity : Nat}
    (safe : SafeExpression expression shape capacity) (state : Fits shape input values)
    (fits : input.length ≤ capacity) :
    (expression.evaluate values input).length ≤ maxSourceLength := by
  rw [evaluate_length state safe.1]
  exact Nat.le_trans (Nat.add_le_add_left (Nat.mul_le_mul_left _ fits) _) safe.2.2.2.2

theorem Expression.prefix_bound {leading trailing : Expression} {shape : Shape}
    {values : Values} {input : Source} {capacity : Nat}
    (safe : SafeExpression (leading ++ trailing) shape capacity) (state : Fits shape input values)
    (fits : input.length ≤ capacity) :
    (leading.evaluateLeft values input).length ≤ maxSourceLength := by
  have whole := output_bound safe state fits
  rw [evaluate_append, List.length_append] at whole
  rw [left_association]
  omega

/-- A grouping tree retains every source concatenation and parenthesis boundary. -/
inductive GroupedExpression
  | atom (value : Operand)
  | concatenate (left right : GroupedExpression)
  | parenthesized (inner : GroupedExpression)
  deriving DecidableEq, Repr

def GroupedExpression.flatten : GroupedExpression → Expression
  | .atom value => [value]
  | .concatenate left right => left.flatten ++ right.flatten
  | .parenthesized inner => inner.flatten

def GroupedExpression.evaluate (values : Values) (input : Source) (expression : GroupedExpression)
    (integers : Integer.Store := Integer.emptyStore) : Source :=
  match expression with
  | .atom value => value.evaluate values input integers
  | .concatenate left right => left.evaluate values input integers ++ right.evaluate values input integers
  | .parenthesized inner => inner.evaluate values input integers

theorem GroupedExpression.flatten_evaluate (grouped : GroupedExpression) (values : Values) (input : Source)
    (integers : Integer.Store := Integer.emptyStore) :
    grouped.flatten.evaluate values input integers = grouped.evaluate values input integers := by
  induction grouped with
  | atom => simp [flatten, Expression.evaluate, evaluate]
  | concatenate left right ihl ihr => simp [flatten, Expression.evaluate_append, ihl, ihr, evaluate]
  | parenthesized inner ih => simpa [flatten, evaluate] using ih

inductive GroupedExpression.Subexpression : GroupedExpression → GroupedExpression → Prop
  | self (expression) : Subexpression expression expression
  | left {part left right} : Subexpression part left → Subexpression part (.concatenate left right)
  | right {part left right} : Subexpression part right → Subexpression part (.concatenate left right)
  | parens {part inner} : Subexpression part inner → Subexpression part (.parenthesized inner)

theorem GroupedExpression.subexpression_length {part whole : GroupedExpression}
    (member : Subexpression part whole) (values : Values) (input : Source)
    (integers : Integer.Store := Integer.emptyStore) :
    (part.evaluate values input integers).length ≤ (whole.evaluate values input integers).length := by
  induction member with
  | self => exact Nat.le_refl _
  | left member ih => simp only [evaluate, List.length_append]; omega
  | right member ih => simp only [evaluate, List.length_append]; omega
  | parens member ih => exact ih

theorem GroupedExpression.intermediate_bound {part whole : GroupedExpression}
    {shape : Shape} {values : Values} {input : Source} {capacity : Nat}
    (member : Subexpression part whole) (safe : SafeExpression whole.flatten shape capacity)
    (state : Fits shape input values) (fits : input.length ≤ capacity) :
    (part.evaluate values input).length ≤ maxSourceLength := by
  have bound := Expression.output_bound safe state fits
  rw [flatten_evaluate] at bound
  exact Nat.le_trans (subexpression_length member values input) bound

end Silver.Compose
