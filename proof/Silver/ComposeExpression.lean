import Silver.GuardedDecimal
import Silver.ArgumentsRuntime

/-! One flat String-expression semantics for all output positions. The static
binding may be a constant or a fixed-length cell; its value is supplied at the
point of evaluation. Every occurrence contributes its length. -/

namespace Silver.Compose

inductive Operand
  | literal (bytes : Source)
  | staticReference
  | dynamicReference
  deriving DecidableEq, Repr

abbrev Expression := List Operand

def Operand.evaluate (staticValue dynamicValue : Source) : Operand → Source
  | .literal bytes => bytes
  | .staticReference => staticValue
  | .dynamicReference => dynamicValue

def Operand.staticLength (length : Nat) : Operand → Nat
  | .literal bytes => bytes.length
  | .staticReference => length
  | .dynamicReference => 0

def Operand.dynamicCount : Operand → Nat
  | .dynamicReference => 1
  | _ => 0

def Operand.staticCount : Operand → Nat
  | .staticReference => 1
  | _ => 0

def Expression.evaluate (staticValue dynamicValue : Source) : Expression → Source
  | [] => []
  | atom :: rest => atom.evaluate staticValue dynamicValue ++ Expression.evaluate staticValue dynamicValue rest

def Expression.staticLength (length : Nat) : Expression → Nat
  | [] => 0
  | atom :: rest => atom.staticLength length + Expression.staticLength length rest

def Expression.dynamicCount : Expression → Nat
  | [] => 0
  | atom :: rest => atom.dynamicCount + Expression.dynamicCount rest

def Expression.staticCount : Expression → Nat
  | [] => 0
  | atom :: rest => atom.staticCount + Expression.staticCount rest

def Expression.LiteralsPrintable (expression : Expression) : Prop :=
  ∀ bytes, Operand.literal bytes ∈ expression → ∀ byte ∈ bytes, Output.printable byte = true

def Expression.Bounded (expression : Expression) (staticLength capacity : Nat) : Prop :=
  expression ≠ [] ∧ expression.dynamicCount ≤ 1 ∧
    expression.staticLength staticLength + expression.dynamicCount * capacity ≤ maxSourceLength

theorem Operand.evaluate_length (atom : Operand) (staticValue dynamicValue : Source) :
    (atom.evaluate staticValue dynamicValue).length =
      atom.staticLength staticValue.length + atom.dynamicCount * dynamicValue.length := by
  cases atom <;> simp [evaluate, staticLength, dynamicCount]

theorem Expression.evaluate_length (expression : Expression) (staticValue dynamicValue : Source) :
    (expression.evaluate staticValue dynamicValue).length =
      expression.staticLength staticValue.length + expression.dynamicCount * dynamicValue.length := by
  induction expression with
  | nil => simp [evaluate, staticLength, dynamicCount]
  | cons atom rest ih =>
      simp only [evaluate, List.length_append, Operand.evaluate_length, ih,
        staticLength, dynamicCount, Nat.add_mul]
      omega

theorem Expression.evaluate_append (left right : Expression) (staticValue dynamicValue : Source) :
    (left ++ right).evaluate staticValue dynamicValue =
      left.evaluate staticValue dynamicValue ++ right.evaluate staticValue dynamicValue := by
  induction left with
  | nil => rfl
  | cons atom rest ih => simp [evaluate, ih, List.append_assoc]

/-- The flat syntax uses Ada's left association. Its running accumulator has
the same bytes as the mathematical concatenation above. -/
def Expression.evaluateLeft (expression : Expression) (staticValue dynamicValue : Source) : Source :=
  expression.foldl (fun accumulated atom => accumulated ++ atom.evaluate staticValue dynamicValue) []

theorem Expression.foldl_evaluate (expression : Expression) (staticValue dynamicValue initial : Source) :
    expression.foldl (fun accumulated atom => accumulated ++ atom.evaluate staticValue dynamicValue) initial =
      initial ++ expression.evaluate staticValue dynamicValue := by
  induction expression generalizing initial with
  | nil => simp [evaluate]
  | cons atom rest ih => simp [List.foldl_cons, ih, evaluate, List.append_assoc]

theorem Expression.left_association (expression : Expression) (staticValue dynamicValue : Source) :
    expression.evaluateLeft staticValue dynamicValue = expression.evaluate staticValue dynamicValue := by
  simp only [evaluateLeft, foldl_evaluate, List.nil_append]

theorem Expression.output_bound {expression : Expression} {staticValue dynamicValue : Source} {capacity : Nat}
    (bounded : expression.Bounded staticValue.length capacity) (fits : dynamicValue.length ≤ capacity) :
    (expression.evaluate staticValue dynamicValue).length ≤ maxSourceLength := by
  rw [evaluate_length]
  have variablePart := Nat.mul_le_mul_left expression.dynamicCount fits
  exact Nat.le_trans (Nat.add_le_add_left variablePart _) bounded.2.2

theorem Expression.prefix_bound {initialPart rest : Expression} {staticValue dynamicValue : Source} {capacity : Nat}
    (bounded : (initialPart ++ rest).Bounded staticValue.length capacity) (fits : dynamicValue.length ≤ capacity) :
    (initialPart.evaluateLeft staticValue dynamicValue).length ≤ maxSourceLength := by
  have whole := output_bound bounded fits
  rw [evaluate_append, List.length_append] at whole
  rw [left_association]
  omega

/-- All concatenation index arithmetic is bounded even before exploiting the
guard: fixed data contributes at most 4096 and the sole input at most 4096. -/
theorem Expression.range_bound {expression : Expression} {staticValue dynamicValue : Source} {capacity : Nat}
    (bounded : expression.Bounded staticValue.length capacity) (input : dynamicValue.length ≤ maxSourceLength) :
    (expression.evaluate staticValue dynamicValue).length ≤ 8192 := by
  have fixed : expression.staticLength staticValue.length ≤ maxSourceLength := by
    have := bounded.2.2
    omega
  have variablePart := Nat.mul_le_mul bounded.2.1 input
  rw [evaluate_length]
  simp only [Nat.one_mul, maxSourceLength] at *
  omega

theorem Expression.evaluate_printable {expression : Expression} {staticValue dynamicValue : Source}
    (literals : expression.LiteralsPrintable)
    (staticBytes : ∀ byte ∈ staticValue, Output.printable byte = true)
    (dynamicBytes : ∀ byte ∈ dynamicValue, Output.printable byte = true) :
    ∀ byte ∈ expression.evaluate staticValue dynamicValue, Output.printable byte = true := by
  induction expression with
  | nil => simp [evaluate]
  | cons atom rest ih =>
      intro byte present
      simp only [evaluate, List.mem_append] at present
      rcases present with present | present
      · cases atom with
        | literal bytes => exact literals bytes (by simp) byte present
        | staticReference => exact staticBytes byte present
        | dynamicReference => exact dynamicBytes byte present
      · exact ih (fun bytes member => literals bytes (by simp [member])) byte present

/-- A branch assignment preserves the declared fixed length. Repeated uses of
the cell are counted again after the update, with no special branch rule. -/
theorem Expression.assignment_preserves_bound {expression : Expression} {initial replacement : Source}
    {capacity : Nat} (sameLength : replacement.length = initial.length)
    (bounded : expression.Bounded initial.length capacity) :
    expression.Bounded replacement.length capacity := by
  simpa [sameLength] using bounded

end Silver.Compose
