module

public import Silver.StringLengths
public import Silver.IntegerChecks

@[expose] public section

namespace Silver.Character

/-- Failed formation contributes an impossible schema. Successful component
reads retain the original scalar expression and the independent index check. -/
def Expr.obligations (lengths : Lengths) (ranges : Integer.Ranges) : Expr → List Integer.Obligation
  | .literal byte => if Output.printable byte then [] else [.impossible]
  | .reference index => if lengths index = some 1 then [] else [.impossible]
  | .indexed target base index => index.obligations ranges ++
      match lengths target, index.infer ranges with
      | some length, some indices => [.stringIndex base length indices]
      | _, _ => [.impossible]
  | .parenthesized inner => inner.obligations lengths ranges

theorem Expr.obligations_exact (expression : Expr) (lengths : Lengths) (ranges : Integer.Ranges) :
    Integer.discharged (expression.obligations lengths ranges) = expression.check lengths ranges := by
  induction expression with
  | literal byte => cases found : Output.printable byte <;>
      simp [obligations, check, found, Integer.discharged, Integer.Obligation.discharge]
  | reference index => by_cases found : lengths index = some 1 <;>
      simp [obligations, check, found, Integer.discharged, Integer.Obligation.discharge]
  | indexed target base index =>
      simp only [obligations, Integer.discharged_append]
      rw [Integer.Expr.obligations_exact]
      cases targetFound : lengths target <;> cases indexFound : index.infer ranges <;>
        simp [check, targetFound, indexFound, Integer.discharged, Integer.Obligation.discharge]
  | parenthesized inner ih => exact ih

end Silver.Character

namespace Silver.Bindings

/-- These are source checks, before specialization. Each slice retains both
endpoint expressions, including a definitely null slice; replacement retains
both its target index and the complete Character RHS read. -/
def Value.scalarObligations (shape : Shape) (ranges : Integer.Ranges) : Value → List Integer.Obligation
  | .image scalar => scalar.obligations ranges
  | .slice target base lower upper => lower.obligations ranges ++ upper.obligations ranges ++
      match shape.fixedLengths target, lower.infer ranges, upper.infer ranges with
      | some length, some a, some b => [.stringSlice base length a b]
      | _, _, _ => [.impossible]
  | .character expression => expression.obligations shape.fixedLengths ranges
  | .replace target base index replacement => index.obligations ranges ++
      replacement.obligations shape.fixedLengths ranges ++
      match shape.fixedLengths target, index.infer ranges with
      | some length, some indices => [.stringIndex base length indices]
      | _, _ => [.impossible]
  | _ => []

theorem Value.extra_obligations_discharge {atom : Value} {shape : Shape}
    {ranges : Integer.Ranges} {summary : Nat × Nat}
    (known : atom.extraRange shape ranges = some summary) :
    Integer.discharged (atom.scalarObligations shape ranges) = true := by
  cases atom with
  | literal | argument | reference | image => cases known
  | slice target base lower upper =>
      simp only [extraRange, Option.bind_eq_some_iff] at known
      obtain ⟨length, targetFound, a, lowerFound, b, upperFound, result⟩ := known
      split at result
      · rename_i checked
        simp only [scalarObligations, targetFound, lowerFound, upperFound,
          Integer.discharged_append, Integer.Expr.obligations_discharge lowerFound,
          Integer.Expr.obligations_discharge upperFound, Bool.true_and]
        simpa only [Integer.discharged, List.all_cons, List.all_nil, Bool.and_true,
          Integer.Obligation.discharge] using checked
      · cases result
  | character expression =>
      simp only [extraRange] at known
      split at known
      · exact (Character.Expr.obligations_exact expression shape.fixedLengths ranges).trans (by assumption)
      · cases known
  | replace target base index replacement =>
      simp only [extraRange, Option.bind_eq_some_iff] at known
      obtain ⟨length, targetFound, indices, indexFound, result⟩ := known
      split at result
      · rename_i checked
        simp only [Bool.and_eq_true] at checked
        simp only [scalarObligations, targetFound, indexFound, Integer.discharged_append,
          Integer.Expr.obligations_discharge indexFound, Character.Expr.obligations_exact,
          checked.2, Bool.true_and]
        simpa only [Integer.discharged, List.all_cons, List.all_nil, Bool.and_true,
          Integer.Obligation.discharge] using checked.1
      · cases result

end Silver.Bindings

namespace Silver.Compose
open Bindings

/-- Retain every scalar, String-index and slice check before immutable
specialization. The historical name is retained for existing trace APIs. -/
def Expression.imageObligations (expression : Expression) (ranges : Integer.Ranges)
    (shape : Shape) : List Integer.Obligation :=
  expression.flatMap (Value.scalarObligations shape ranges)

theorem Expression.image_obligations_discharge {expression : Expression} {shape : Shape}
    {ranges : Integer.Ranges} {summary : LengthSummary}
    (known : expression.inferLength shape ranges = some summary) :
    Integer.discharged (expression.imageObligations ranges shape) = true := by
  induction expression generalizing summary with
  | nil => rfl
  | cons atom rest ih =>
      simp only [inferLength, Option.bind_eq_some_iff, Option.map_eq_some_iff] at known
      obtain ⟨first, atomKnown, remaining, restKnown, _⟩ := known
      have tail := ih restKnown
      simp only [imageObligations, List.flatMap_cons, Integer.discharged_append]
      change (Integer.discharged _ && Integer.discharged (imageObligations rest ranges shape)) = true
      rw [tail, Bool.and_true]
      cases atom with
      | literal | argument | reference => rfl
      | image scalar =>
          simp only [Operand.inferLength, Option.map_eq_some_iff] at atomKnown
          obtain ⟨bounds, found, _⟩ := atomKnown
          exact Integer.Expr.obligations_discharge found
      | slice | character | replace =>
          simp only [Operand.inferLength, Option.map_eq_some_iff] at atomKnown
          obtain ⟨bounds, found, _⟩ := atomKnown
          exact Value.extra_obligations_discharge found

theorem Expression.image_obligations_valid {expression : Expression} {shape : Shape}
    {ranges : Integer.Ranges} {summary : LengthSummary}
    (known : expression.inferLength shape ranges = some summary) :
    ∀ check ∈ expression.imageObligations ranges shape, check.Valid := by
  have all := List.all_eq_true.mp (image_obligations_discharge known)
  exact fun check member => Integer.Obligation.discharge_sound (all check member)

end Silver.Compose
