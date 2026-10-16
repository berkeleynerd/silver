module

public import Silver.StringLengths
public import Silver.IntegerChecks

@[expose] public section

namespace Silver.Compose
open Bindings

/-- Preserve every scalar node inside each source Image before immutable
specialization. Constant evaluation never removes its safety schemas. -/
def Expression.imageObligations (expression : Expression) (ranges : Integer.Ranges) : List Integer.Obligation :=
  expression.flatMap fun atom => match atom with
    | .image scalar => scalar.obligations ranges
    | _ => []

theorem Expression.image_obligations_discharge {expression : Expression} {shape : Shape}
    {ranges : Integer.Ranges} {summary : LengthSummary}
    (known : expression.inferLength shape ranges = some summary) :
    Integer.discharged (expression.imageObligations ranges) = true := by
  induction expression generalizing summary with
  | nil => rfl
  | cons atom rest ih =>
      simp only [inferLength, Option.bind_eq_some_iff, Option.map_eq_some_iff] at known
      obtain ⟨first, atomKnown, remaining, restKnown, _⟩ := known
      have tail := ih restKnown
      simp only [imageObligations, List.flatMap_cons, Integer.discharged_append]
      change (Integer.discharged _ && Integer.discharged (imageObligations rest ranges)) = true
      rw [tail, Bool.and_true]
      cases atom with
      | literal | argument | reference => rfl
      | image scalar =>
          simp only [Operand.inferLength, Option.map_eq_some_iff] at atomKnown
          obtain ⟨bounds, found, _⟩ := atomKnown
          exact Integer.Expr.obligations_discharge found

theorem Expression.image_obligations_valid {expression : Expression} {shape : Shape}
    {ranges : Integer.Ranges} {summary : LengthSummary}
    (known : expression.inferLength shape ranges = some summary) :
    ∀ check ∈ expression.imageObligations ranges, check.Valid := by
  have all := List.all_eq_true.mp (image_obligations_discharge known)
  exact fun check member => Integer.Obligation.discharge_sound (all check member)

end Silver.Compose
