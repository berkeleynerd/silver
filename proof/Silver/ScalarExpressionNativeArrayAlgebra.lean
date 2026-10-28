module

public import Silver.ScalarExpressionNativeRecursion

@[expose] public section

namespace Silver.ScalarExpression.Native

set_option linter.unusedSimpArgs false

variable (arrays : ArrayBindings.Metadata) (initials : ArrayBindings.Initials) (elaborating : Bool)

theorem literal_arrays_correspondence (names : Environment) (number : ScalarLiteral.Result) (negative : Bool) :
    literalResult number negative = summarizeArrays names arrays initials elaborating (literal number negative) := by
  unfold literalResult literal
  dsimp only
  by_cases zero : number.after = 0
  · simp [zero, summarizeArrays]
  · simp only [zero, false_or, ↓reduceIte, summarizeArrays, leaves, maxOperands,
      show ¬ 64 < 1 by decide, or_self, Integer.Expr.infer, Integer.accepted, isStatic]
    cases checked : (Integer.checked (Integer.Interval.singleton (signedValue number.value negative))).safe <;>
      simp

theorem unary_arrays_correspondence (names : Environment) (parsed : Option Parsed) (negative : Bool) :
    unaryResult (summarizeArrays names arrays initials elaborating parsed) negative =
      summarizeArrays names arrays initials elaborating (parsed.map fun value => unary value negative) := by
  cases parsed with
  | none => simp [summarizeArrays, unaryResult, invalid]
  | some value =>
      by_cases zero : value.after = 0
      · cases negative <;> simp [summarizeArrays, zero, unary, unaryResult, invalid]
      · by_cases tooMany : maxOperands < leaves value.expression
        · cases negative <;> simp [summarizeArrays, unary, leaves, tooMany, unaryResult, invalid]
        · cases inferred : value.expression.infer (ArrayBindings.ranges arrays initials elaborating (ranges names)) with
          | none =>
              cases negative <;> simp [summarizeArrays, unary, leaves, zero, tooMany,
                Integer.Expr.infer, inferred, unaryResult, invalid]
          | some bounds =>
              cases negative
              · simp [summarizeArrays, unary, leaves, zero, tooMany, Integer.Expr.infer,
                  inferred, isStatic, unaryResult]
              · cases checked : (Integer.checkedNegate bounds).safe <;>
                  simp [summarizeArrays, unary, leaves, zero, tooMany, Integer.Expr.infer,
                    inferred, isStatic, unaryResult, Integer.accepted, checked]

theorem binary_arrays_correspondence (names : Environment) (left right : Parsed) (operator : Nat)
    (leftPositive : left.after ≠ 0) (rightPositive : right.after ≠ 0) :
    binaryResult (summarizeArrays names arrays initials elaborating (some left)) (summarizeArrays names arrays initials elaborating (some right)) operator =
      summarizeArrays names arrays initials elaborating (binary left right operator) := by
  by_cases unsupported : operator ≠ 43 ∧ operator ≠ 45 ∧ operator ≠ 42 ∧
      operator ≠ 47 ∧ operator ≠ 109 ∧ operator ≠ 114
  · simp [binaryResult, binary, unsupported.1, unsupported.2.1, unsupported.2.2.1,
      unsupported.2.2.2.1, unsupported.2.2.2.2.1, unsupported.2.2.2.2.2, summarizeArrays]
  · have supported : operator = 43 ∨ operator = 45 ∨ operator = 42 ∨
        operator = 47 ∨ operator = 109 ∨ operator = 114 := by omega
    rcases supported with rfl | rfl | rfl | rfl | rfl | rfl <;>
      simp only [binaryResult, binary, Nat.reduceEqDiff, ↓reduceIte, summarizeArrays, leaves,
        Integer.Expr.infer, isStatic]
    all_goals
      have leftLeaves := leaves_positive left.expression
      have rightLeaves := leaves_positive right.expression
      by_cases leftLarge : maxOperands < leaves left.expression
      · have totalLarge : maxOperands < leaves left.expression + leaves right.expression := by omega
        simp [leftLarge, totalLarge, invalid]
      · by_cases rightLarge : maxOperands < leaves right.expression
        · have totalLarge : maxOperands < leaves left.expression + leaves right.expression := by omega
          simp [rightLarge, totalLarge, invalid]
        · simp only [leftPositive, rightPositive, leftLarge, rightLarge, false_or, ↓reduceIte]
          cases leftInferred : left.expression.infer (ArrayBindings.ranges arrays initials elaborating (ranges names)) with
          | none => simp [invalid]
          | some leftBounds =>
              cases rightInferred : right.expression.infer (ArrayBindings.ranges arrays initials elaborating (ranges names)) with
              | none => simp [invalid]
              | some rightBounds =>
                  simp only [leftPositive, rightPositive, false_or, Option.bind_some, Integer.accepted]
                  have resource : (leaves left.expression > maxOperands - leaves right.expression) =
                      (maxOperands < leaves left.expression + leaves right.expression) := by
                    apply propext
                    omega
                  simp only [resource]
                  first
                  | cases checked : (Integer.checkedAdd leftBounds rightBounds).safe <;>
                      simp [checked] <;> split <;> rfl
                  | cases checked : (Integer.checkedSubtract leftBounds rightBounds).safe <;>
                      simp [checked] <;> split <;> rfl
                  | cases checked : (Integer.checkedMultiply leftBounds rightBounds).safe <;>
                      simp [checked] <;> split <;> rfl
                  | cases checked : (Integer.checkedDivide leftBounds rightBounds).safe <;>
                      simp [checked] <;> split <;> rfl
                  | cases checked : (Integer.checkedModulo leftBounds rightBounds).safe <;>
                      simp [checked] <;> split <;> rfl
                  | cases checked : (Integer.checkedRemainder leftBounds rightBounds).safe <;>
                      simp [checked] <;> split <;> rfl

theorem close_arrays_correspondence (text : Source) (names : Environment) (parsed : Option Parsed) :
    closeResult text (summarizeArrays names arrays initials elaborating parsed) = summarizeArrays names arrays initials elaborating (close text parsed) := by
  cases parsed with
  | none => simp [summarizeArrays, close, close_invalid]
  | some value =>
      by_cases zero : value.after = 0
      · simp [summarizeArrays, zero, close, symbol, skip, close_invalid]
      · by_cases many : maxOperands < leaves value.expression
        · simp only [summarizeArrays, many, or_true, ↓reduceIte, close_invalid]
          change invalid = summarizeArrays names arrays initials elaborating (if symbol text value.after 41 = 0 then none
            else some {value with after := symbol text value.after 41})
          split <;> simp [summarizeArrays, many]
        · cases inferred : value.expression.infer (ArrayBindings.ranges arrays initials elaborating (ranges names)) with
          | none =>
              simp only [summarizeArrays, zero, many, or_self, ↓reduceIte, inferred, close_invalid]
              change invalid = summarizeArrays names arrays initials elaborating (if symbol text value.after 41 = 0 then none
                else some {value with after := symbol text value.after 41})
              split <;> simp [summarizeArrays, many, inferred]
          | some bounds =>
              simp only [summarizeArrays, zero, many, or_self, ↓reduceIte, inferred, closeResult,
                close, Option.bind_some]
              split <;> simp [summarizeArrays, many, inferred, *]

theorem summarizeArrays_after_update (names : Environment) (value : Parsed) (finish : Nat)
    (positive : value.after ≠ 0) (finishPositive : finish ≠ 0)
    (success : (summarizeArrays names arrays initials elaborating (some value)).after ≠ 0) :
    summarizeArrays names arrays initials elaborating (some {value with after := finish}) =
      {summarizeArrays names arrays initials elaborating (some value) with after := finish} := by
  simp only [summarizeArrays, positive, finishPositive, false_or]
  split
  · simp [summarizeArrays, positive, * , invalid] at success
  · cases found : value.expression.infer (ArrayBindings.ranges arrays initials elaborating (ranges names)) with
    | none => simp [summarizeArrays, found, * , invalid] at success
    | some bounds => rfl

theorem parenthesized_arrays_correspondence (names : Environment) (value : Parsed) (finish : Nat)
    (positive : value.after ≠ 0) (finishPositive : finish ≠ 0) :
    summarizeArrays names arrays initials elaborating (some ⟨finish, .parenthesized value.expression⟩) =
      if (summarizeArrays names arrays initials elaborating (some value)).after = 0 then invalid
      else {summarizeArrays names arrays initials elaborating (some value) with after := finish} := by
  simp only [summarizeArrays, positive, finishPositive, leaves, Integer.Expr.infer,
    isStatic, false_or]
  split
  · rfl
  · cases found : value.expression.infer (ArrayBindings.ranges arrays initials elaborating (ranges names)) with
    | none => rfl
    | some bounds => simp [positive]

theorem summarizeArrays_zero {names : Environment} {parsed : Option Parsed}
    (zero : (summarizeArrays names arrays initials elaborating parsed).after = 0) : summarizeArrays names arrays initials elaborating parsed = invalid := by
  cases parsed with
  | none => rfl
  | some value =>
      simp only [summarizeArrays] at zero ⊢
      split
      · rfl
      · rename_i good
        cases found : value.expression.infer (ArrayBindings.ranges arrays initials elaborating (ranges names)) with
        | none => rfl
        | some bounds => simp only [ite_eq_right good, found] at zero; omega

end Silver.ScalarExpression.Native
