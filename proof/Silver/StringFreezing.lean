module

public import Silver.StringExecution
public import Silver.ComposeExpression

@[expose] public section

/-! Semantic specialization of immutable scalar Image operands. The source
witness retains the actual Image expression. This transformation is only a
mathematical model operation; its evaluation equation proves every byte. -/
namespace Silver.Compose
open Bindings

def Operand.freezeImages (integers : Integer.Store) : Operand → Operand
  | .image expression => .literal (Integer.Image.bytes (expression.evaluate integers))
  | atom => atom

def Expression.freezeImages (expression : Expression) (integers : Integer.Store) : Expression :=
  expression.map (Operand.freezeImages integers)

theorem Operand.freezeImages_evaluate (atom : Operand) (integers : Integer.Store)
    (values : Values) (input : Source) :
    (atom.freezeImages integers).evaluate values input = atom.evaluate values input integers := by
  cases atom <;> rfl

theorem Expression.freezeImages_evaluate (expression : Expression) (integers : Integer.Store)
    (values : Values) (input : Source) :
    (expression.freezeImages integers).evaluate values input = expression.evaluate values input integers := by
  induction expression with
  | nil => rfl
  | cons atom rest ih =>
      simp only [freezeImages, List.map_cons, evaluate, Operand.freezeImages_evaluate]
      exact congrArg (List.append (atom.evaluate values input integers)) ih

@[simp] theorem Expression.freezeImages_length (expression : Expression) (integers : Integer.Store) :
    (expression.freezeImages integers).length = expression.length := List.length_map _

theorem Expression.freezeImages_readable {expression : Expression} {shape : Shape}
    (readable : expression.StringReadable shape) (integers : Integer.Store) :
    (expression.freezeImages integers).Readable shape := by
  intro atom member
  obtain ⟨original, present, rfl⟩ := List.mem_map.mp member
  have known := readable original present
  cases original with
  | literal | argument | image => exact ⟨_, rfl⟩
  | reference index =>
      obtain ⟨info, found⟩ := known
      exact ⟨info.bound, by simp [Operand.freezeImages, Value.infer, found]⟩

theorem Expression.freezeImages_printable {expression : Expression}
    (literals : expression.LiteralsPrintable) (integers : Integer.Store) :
    (expression.freezeImages integers).LiteralsPrintable := by
  intro atom member
  obtain ⟨original, present, rfl⟩ := List.mem_map.mp member
  cases original with
  | literal | argument | reference => exact literals _ present
  | image scalar => exact image_printable (scalar.evaluate integers)

private def lengthWitness (shape : Shape) (length : Nat) : Values := fun index =>
  match shape index with
  | none => []
  | some info => List.replicate (info.bound.length length) 32

private theorem lengthWitness_fits (shape : Shape) (input : Source) :
    Fits shape input (lengthWitness shape input.length) := by
  intro index info found
  simp only [lengthWitness, found, List.length_replicate]
  refine ⟨True.intro, ?_⟩
  intro byte member
  have same := List.eq_of_mem_replicate member
  subst byte
  decide

/-- Every input length is represented by the same exact String shape. The
interval bound therefore contains the specialized affine length polynomial. -/
theorem Expression.freezeImages_contains {expression : Expression} {shape : Shape}
    {ranges : Integer.Ranges} {summary : LengthSummary} {integers : Integer.Store}
    (known : expression.inferLength shape ranges = some summary)
    (scalars : Integer.Fits ranges integers) (length : Nat) :
    summary.Contains length (((expression.freezeImages integers).summary shape).length length) := by
  let input : Source := List.replicate length 32
  have state := lengthWitness_fits shape input
  have contained := (Expression.inferLength_sound known state scalars).1
  rw [← Expression.freezeImages_evaluate] at contained
  rw [Expression.evaluate_length state (freezeImages_readable (inferLength_readable known) integers)] at contained
  simpa only [input, List.length_replicate, Expression.summary, Summary.length] using contained

theorem Expression.freezeImages_summary {expression : Expression} {shape : Shape}
    {ranges : Integer.Ranges} {summary : LengthSummary} {affine : Summary} {integers : Integer.Store}
    (known : expression.inferLength shape ranges = some summary)
    (exact : summary.exact = some affine) (scalars : Integer.Fits ranges integers) :
    (expression.freezeImages integers).summary shape = affine := by
  have zero := (LengthSummary.exact_contains exact _ _).mp (freezeImages_contains known scalars 0)
  have one := (LengthSummary.exact_contains exact _ _).mp (freezeImages_contains known scalars 1)
  cases frozen : (expression.freezeImages integers).summary shape with
  | mk staticLength dynamicCount =>
      cases affine with
      | mk targetStatic targetDynamic =>
          rw [frozen] at zero one
          simp only [Summary.length, Nat.mul_zero, Nat.add_zero, Nat.mul_one] at zero one
          congr <;> omega

theorem Expression.freezeImages_safe {expression : Expression} {shape : Shape}
    {ranges : Integer.Ranges} {summary : LengthSummary} {integers : Integer.Store} {capacity : Nat}
    (known : expression.inferLength shape ranges = some summary)
    (scalars : Integer.Fits ranges integers) (literals : expression.LiteralsPrintable)
    (nonempty : expression ≠ []) (count : expression.length ≤ maxExpressionOperands)
    (bound : summary.upper.length capacity ≤ maxSourceLength) :
    SafeExpression (expression.freezeImages integers) shape capacity := by
  refine ⟨freezeImages_readable (inferLength_readable known) integers,
    freezeImages_printable literals integers, ?_, ?_, ?_⟩
  · intro empty
    apply nonempty
    exact List.length_eq_zero_iff.mp (by simpa using congrArg List.length empty)
  · simpa only [freezeImages_length] using count
  · exact Nat.le_trans (freezeImages_contains known scalars capacity).2.2 bound

end Silver.Compose
