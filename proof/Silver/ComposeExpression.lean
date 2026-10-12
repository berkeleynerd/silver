module

public import Silver.GuardedDecimal
public import Silver.Bindings

@[expose] public section

/-! Shared flat String expressions over initialized binding indices. Bounds are
read from the fixed binding shape; bytes are read from the current value store.
Aliases of the input each contribute a dynamic occurrence. -/

namespace Silver.Compose

open Bindings

abbrev Operand := Bindings.Value
abbrev Expression := List Operand

def maxExpressionOperands : Nat := 16

def Bound.staticPart : Bound → Nat
  | .fixed length => length
  | .argument => 0

def Bound.dynamicPart : Bound → Nat
  | .fixed _ => 0
  | .argument => 1

def Operand.bound (shape : Shape) (atom : Operand) : Bound :=
  (atom.infer shape).getD (.fixed 0)

def Operand.staticLength (shape : Shape) (atom : Operand) : Nat :=
  Bound.staticPart (atom.bound shape)

def Operand.dynamicCount (shape : Shape) (atom : Operand) : Nat :=
  Bound.dynamicPart (atom.bound shape)

def Expression.evaluate (values : Values) (input : Source) : Expression → Source
  | [] => []
  | atom :: rest => atom.evaluate values input ++ Expression.evaluate values input rest

def Expression.staticLength (shape : Shape) : Expression → Nat
  | [] => 0
  | atom :: rest => atom.staticLength shape + Expression.staticLength shape rest

def Expression.dynamicCount (shape : Shape) : Expression → Nat
  | [] => 0
  | atom :: rest => atom.dynamicCount shape + Expression.dynamicCount shape rest

def Expression.Readable (expression : Expression) (shape : Shape) : Prop :=
  ∀ atom ∈ expression, ∃ bound, atom.infer shape = some bound

def Expression.LiteralsPrintable (expression : Expression) : Prop :=
  ∀ atom ∈ expression, atom.PrintableLiterals

def Expression.Bounded (expression : Expression) (shape : Shape) (capacity : Nat) : Prop :=
  expression ≠ [] ∧ expression.length ≤ maxExpressionOperands ∧
    expression.dynamicCount shape ≤ 1 ∧
    expression.staticLength shape + expression.dynamicCount shape * capacity ≤ maxSourceLength

def SafeExpression (expression : Expression) (shape : Shape) (capacity : Nat) : Prop :=
  expression.Readable shape ∧ expression.LiteralsPrintable ∧ expression.Bounded shape capacity

theorem Operand.evaluate_length {atom : Operand} {shape : Shape}
    {values : Values} {input : Source} (fits : Fits shape input values)
    (readable : ∃ bound, atom.infer shape = some bound) :
    (atom.evaluate values input).length =
      atom.staticLength shape + atom.dynamicCount shape * input.length := by
  obtain ⟨bound, inferred⟩ := readable
  rw [Bindings.value_length fits inferred]
  simp only [staticLength, dynamicCount, Operand.bound, inferred, Option.getD_some]
  cases bound <;> simp [Bindings.Bound.length, Bound.staticPart, Bound.dynamicPart]

theorem Expression.evaluate_length {expression : Expression} {shape : Shape}
    {values : Values} {input : Source} (fits : Fits shape input values)
    (readable : expression.Readable shape) :
    (expression.evaluate values input).length =
      expression.staticLength shape + expression.dynamicCount shape * input.length := by
  induction expression with
  | nil => simp [evaluate, staticLength, dynamicCount]
  | cons atom rest ih =>
      have first := readable atom (by simp)
      have remaining : Expression.Readable rest shape := fun other present => readable other (by simp [present])
      simp only [evaluate, List.length_append, Operand.evaluate_length fits first, ih remaining,
        staticLength, dynamicCount, Nat.add_mul]
      omega

theorem Expression.evaluate_append (left right : Expression) (values : Values) (input : Source) :
    (left ++ right).evaluate values input = left.evaluate values input ++ right.evaluate values input := by
  induction left with
  | nil => rfl
  | cons atom rest ih => simp [evaluate, ih, List.append_assoc]

def Expression.evaluateLeft (expression : Expression) (values : Values) (input : Source) : Source :=
  expression.foldl (fun accumulated atom => accumulated ++ atom.evaluate values input) []

theorem Expression.foldl_evaluate (expression : Expression) (values : Values) (input initial : Source) :
    expression.foldl (fun accumulated atom => accumulated ++ atom.evaluate values input) initial =
      initial ++ expression.evaluate values input := by
  induction expression generalizing initial with
  | nil => simp [evaluate]
  | cons atom rest ih => simp [List.foldl_cons, ih, evaluate, List.append_assoc]

theorem Expression.left_association (expression : Expression) (values : Values) (input : Source) :
    expression.evaluateLeft values input = expression.evaluate values input := by
  simp only [evaluateLeft, foldl_evaluate, List.nil_append]

theorem Expression.output_bound {expression : Expression} {shape : Shape}
    {values : Values} {input : Source} {capacity : Nat}
    (safe : SafeExpression expression shape capacity) (state : Fits shape input values)
    (fits : input.length ≤ capacity) :
    (expression.evaluate values input).length ≤ maxSourceLength := by
  rw [evaluate_length state safe.1]
  exact Nat.le_trans (Nat.add_le_add_left (Nat.mul_le_mul_left _ fits) _) safe.2.2.2.2.2

theorem Expression.prefix_bound {leading trailing : Expression} {shape : Shape}
    {values : Values} {input : Source} {capacity : Nat}
    (safe : SafeExpression (leading ++ trailing) shape capacity) (state : Fits shape input values)
    (fits : input.length ≤ capacity) :
    (leading.evaluateLeft values input).length ≤ maxSourceLength := by
  have whole := output_bound safe state fits
  rw [evaluate_append, List.length_append] at whole
  rw [left_association]
  omega

theorem Expression.range_bound {expression : Expression} {shape : Shape}
    {values : Values} {input : Source} {capacity : Nat}
    (safe : SafeExpression expression shape capacity) (state : Fits shape input values)
    (inputBound : input.length ≤ maxSourceLength) :
    (expression.evaluate values input).length ≤ 8192 := by
  have fixed : expression.staticLength shape ≤ maxSourceLength := by
    have := safe.2.2.2.2.2
    omega
  have variablePart := Nat.mul_le_mul safe.2.2.2.2.1 inputBound
  rw [evaluate_length state safe.1]
  simp only [Nat.one_mul, maxSourceLength] at *
  omega

theorem Expression.evaluate_printable {expression : Expression} {shape : Shape}
    {values : Values} {input : Source} (readable : expression.Readable shape)
    (literals : expression.LiteralsPrintable) (state : Fits shape input values)
    (inputPrintable : Printable input) : Printable (expression.evaluate values input) := by
  induction expression with
  | nil => simp [evaluate, Printable]
  | cons atom rest ih =>
      intro byte present
      simp only [evaluate, List.mem_append] at present
      rcases present with present | present
      · obtain ⟨bound, inferred⟩ := readable atom (by simp)
        exact Bindings.value_printable state inputPrintable inferred (literals atom (by simp)) byte present
      · exact ih (fun other member => readable other (by simp [member]))
          (fun other member => literals other (by simp [member])) byte present

theorem Expression.staticLength_append (left right : Expression) (shape : Shape) :
    (left ++ right).staticLength shape = left.staticLength shape + right.staticLength shape := by
  induction left with
  | nil => simp [staticLength]
  | cons atom rest ih => simp [staticLength, ih, Nat.add_assoc]

theorem Expression.dynamicCount_append (left right : Expression) (shape : Shape) :
    (left ++ right).dynamicCount shape = left.dynamicCount shape + right.dynamicCount shape := by
  induction left with
  | nil => simp [dynamicCount]
  | cons atom rest ih => simp [dynamicCount, ih, Nat.add_assoc]

end Silver.Compose
