module

public import Silver.StringLengths

@[expose] public section

namespace Silver.Compose
open Bindings

/-- String name resolution is unconditional. Scalar names and every scalar
arithmetic node are checked by inferLength, including on an empty path. -/
def Operand.StringReadable (shape : Shape) : Operand → Prop
  | .reference index => ∃ info, shape index = some info
  | _ => True

def Expression.StringReadable (expression : Expression) (shape : Shape) : Prop :=
  ∀ atom ∈ expression, atom.StringReadable shape

def Operand.checkedEvaluate (values : Values) (input : Source) (atom : Operand)
    (integers : Integer.Store := Integer.emptyStore) : Option Source :=
  match atom with
  | .image expression => (expression.checkedEvaluate integers).map Integer.Image.bytes
  | _ => some (atom.evaluate values input integers)

def Expression.checkedEvaluate (values : Values) (input : Source) (expression : Expression)
    (integers : Integer.Store := Integer.emptyStore) : Option Source :=
  match expression with
  | [] => some []
  | atom :: rest => (atom.checkedEvaluate values input integers).bind fun first =>
      (Expression.checkedEvaluate values input rest integers).bind fun remaining =>
        if (first ++ remaining).length ≤ maxSourceLength then some (first ++ remaining) else none

def Expression.RuntimeSafe (expression : Expression) (values : Values) (input : Source)
    (integers : Integer.Store) : Prop :=
  expression.ImagesSafe integers ∧ (expression.evaluate values input integers).length ≤ maxSourceLength

theorem Operand.checkedEvaluate_agrees {atom : Operand} {values : Values} {input : Source}
    {integers : Integer.Store} (safe : atom.ImagesSafe integers) :
    atom.checkedEvaluate values input integers = some (atom.evaluate values input integers) := by
  cases atom with
  | literal | reference | argument => rfl
  | image expression =>
      simp only [checkedEvaluate, Integer.Expr.checkedEvaluate_agrees safe, Option.map_some, Value.evaluate]

theorem Expression.checkedEvaluate_agrees {expression : Expression} {values : Values} {input : Source}
    {integers : Integer.Store} (safe : expression.RuntimeSafe values input integers) :
    expression.checkedEvaluate values input integers = some (expression.evaluate values input integers) := by
  induction expression with
  | nil => rfl
  | cons atom rest ih =>
      have first : atom.ImagesSafe integers := safe.1 atom (by simp)
      have remaining : Expression.RuntimeSafe rest values input integers := by
        refine ⟨fun item member => safe.1 item (by simp [member]), ?_⟩
        have bound := safe.2
        simp only [evaluate, List.length_append] at bound
        omega
      have totalBound :
          (atom.evaluate values input integers ++ Expression.evaluate values input rest integers).length
            ≤ maxSourceLength := by
        simpa only [Expression.evaluate] using safe.2
      simp only [checkedEvaluate, Operand.checkedEvaluate_agrees first, Option.bind_some,
        ih remaining, totalBound, ↓reduceIte, evaluate]

theorem Expression.inferLength_runtimeSafe {expression : Expression} {shape : Shape}
    {ranges : Integer.Ranges} {summary : LengthSummary} {values : Values} {input : Source}
    {integers : Integer.Store} {capacity : Nat}
    (known : expression.inferLength shape ranges = some summary)
    (strings : Fits shape input values) (scalars : Integer.Fits ranges integers)
    (bound : summary.upper.length capacity ≤ maxSourceLength) (fits : input.length ≤ capacity) :
    expression.RuntimeSafe values input integers :=
  ⟨(inferLength_sound known strings scalars).2, inferLength_bound known strings scalars bound fits⟩

theorem Operand.inferLength_readable {atom : Operand} {shape : Shape} {ranges : Integer.Ranges}
    {summary : LengthSummary} (known : atom.inferLength shape ranges = some summary) :
    atom.StringReadable shape := by
  cases atom with
  | literal | argument | image => trivial
  | reference index =>
      simp only [inferLength, Value.infer, Option.map_map, Option.map_eq_some_iff] at known
      obtain ⟨info, found, _⟩ := known
      exact ⟨info, found⟩

theorem Expression.inferLength_readable {expression : Expression} {shape : Shape}
    {ranges : Integer.Ranges} {summary : LengthSummary}
    (known : expression.inferLength shape ranges = some summary) : expression.StringReadable shape := by
  induction expression generalizing summary with
  | nil => simp [StringReadable]
  | cons atom rest ih =>
      simp only [inferLength, Option.bind_eq_some_iff, Option.map_eq_some_iff] at known
      obtain ⟨first, atomKnown, remaining, restKnown, _⟩ := known
      intro item member
      rcases List.mem_cons.mp member with rfl | member
      · exact Operand.inferLength_readable atomKnown
      · exact ih restKnown item member

end Silver.Compose
