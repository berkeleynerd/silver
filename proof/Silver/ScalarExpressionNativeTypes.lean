module

public import Silver.ScalarExpressionNativeRecursion

@[expose] public section

namespace Silver.ScalarExpression.Native

def ValidText (text : Source) : Prop := 0 < text.length ∧ text.length ≤ 4096
def ResultType (value : Result) : Prop :=
  value.after ≤ 4097 ∧ value.bounds.Bounded ∧ value.operands ≤ maxOperands
def LiteralType (value : ScalarLiteral.Result) : Prop :=
  value.after ≤ 4097 ∧ value.value ≤ ScalarLiteral.maxMagnitude

theorem invalid_type : ResultType invalid := by
  exact ⟨by decide, Integer.Interval.empty_bounded, by decide⟩

theorem literal_read_bounds {text : Source} {position : Nat} (bound : position ≤ text.length + 1) :
    (ScalarLiteral.read text position).after ≤ text.length + 1 ∧
      (ScalarLiteral.read text position).value ≤ ScalarLiteral.maxMagnitude := by
  by_cases zero : (ScalarLiteral.read text position).after = 0
  · have result : ScalarLiteral.read text position = ScalarLiteral.invalid := by
      unfold ScalarLiteral.read at zero ⊢
      dsimp only at zero ⊢
      split
      · rfl
      · split
        · rfl
        · rename_i good
          simp_all only [↓reduceIte]
          simp at good
    simp [result, ScalarLiteral.invalid, Guarded.invalidDecimal, ScalarLiteral.maxMagnitude]
  · exact (ScalarLiteral.integer_bounds (ScalarLiteral.read_sound bound zero)).2

theorem literal_read_type {text : Source} (valid : ValidText text) {position : Nat}
    (bound : position ≤ text.length + 1) : LiteralType (ScalarLiteral.read text position) := by
  have bounds := literal_read_bounds bound
  exact ⟨by have length := valid.2; omega, bounds.2⟩

theorem read_type {text : Source} (valid : ValidText text) {position maskFirst maskAfter : Nat}
    {names : Environment} {allowSign : Bool} (bound : position ≤ text.length + 1) :
    ResultType (read text position names maskFirst maskAfter allowSign) := by
  by_cases zero : (read text position names maskFirst maskAfter allowSign).after = 0
  · rw [show read text position names maskFirst maskAfter allowSign = invalid from summarize_zero zero]
    exact invalid_type
  · have limits := read_bounds bound zero
    obtain ⟨expression, inferred, operands, _⟩ := read_has_expression zero
    exact ⟨by have length := valid.2; omega, Integer.Expr.infer_bounded inferred, limits.2.2.2⟩

theorem literal_result_type {number : ScalarLiteral.Result} (typed : LiteralType number) (negative : Bool) :
    ResultType (literalResult number negative) := by
  unfold literalResult
  dsimp only
  split
  · exact invalid_type
  · exact ⟨typed.1, Integer.checked_bounded _, show 1 ≤ 64 by decide⟩

theorem literal_result_after (number : ScalarLiteral.Result) (negative : Bool) :
    (literalResult number negative).after = 0 ∨ (literalResult number negative).after = number.after := by
  unfold literalResult
  dsimp only
  split <;> simp [invalid]

theorem unary_result_type {operand : Result} (typed : ResultType operand) (negative : Bool) :
    ResultType (unaryResult operand negative) := by
  cases negative
  · simpa [unaryResult] using (show ResultType (if operand.after = 0 then invalid else operand) from
      by split; exact invalid_type; exact typed)
  · unfold unaryResult
    simp only [↓reduceIte]
    split
    · exact invalid_type
    · exact ⟨typed.1, Integer.checkedNegate_bounded _, typed.2.2⟩

theorem unary_result_after (operand : Result) (negative : Bool) :
    (unaryResult operand negative).after = 0 ∨ (unaryResult operand negative).after = operand.after := by
  cases negative <;> simp only [unaryResult, Bool.false_eq_true, ↓reduceIte]
  all_goals split <;> simp [invalid]

theorem binary_result_type {left right : Result} (_a : ResultType left) (b : ResultType right) (operator : Nat) :
    ResultType (binaryResult left right operator) := by
  have bounds : (if operator = 43 then Integer.checkedAdd left.bounds right.bounds
      else if operator = 45 then Integer.checkedSubtract left.bounds right.bounds
      else if operator = 42 then Integer.checkedMultiply left.bounds right.bounds
      else ⟨false, Integer.Interval.empty⟩).bounds.Bounded := by
    split
    · exact Integer.checkedAdd_bounded ..
    · split
      · exact Integer.checkedSubtract_bounded ..
      · split
        · exact Integer.checkedMultiply_bounded ..
        · exact Integer.Interval.empty_bounded
  unfold binaryResult
  dsimp only
  generalize checked : (if operator = 43 then Integer.checkedAdd left.bounds right.bounds
      else if operator = 45 then Integer.checkedSubtract left.bounds right.bounds
      else if operator = 42 then Integer.checkedMultiply left.bounds right.bounds
      else ⟨false, Integer.Interval.empty⟩) = result at bounds ⊢
  split
  · exact invalid_type
  · refine ⟨b.1, bounds, ?_⟩
    have cap := b.2.2
    dsimp only
    omega

theorem binary_result_after (left right : Result) (operator : Nat) :
    (binaryResult left right operator).after = 0 ∨ (binaryResult left right operator).after = right.after := by
  unfold binaryResult
  dsimp only
  generalize checked : (if operator = 43 then Integer.checkedAdd left.bounds right.bounds
      else if operator = 45 then Integer.checkedSubtract left.bounds right.bounds
      else if operator = 42 then Integer.checkedMultiply left.bounds right.bounds
      else ⟨false, Integer.Interval.empty⟩) = result
  split <;> simp [invalid]

end Silver.ScalarExpression.Native
