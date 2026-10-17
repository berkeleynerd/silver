module

public import Silver.ScalarExpressionNativeModel

@[expose] public section

namespace Silver.ScalarExpression.Native

set_option linter.unusedSimpArgs false

theorem unary_correspondence (names : Environment) (parsed : Option Parsed) (negative : Bool) :
    unaryResult (summarize names parsed) negative =
      summarize names (parsed.map fun value => unary value negative) := by
  cases parsed with
  | none => simp [summarize, unaryResult, invalid]
  | some value =>
      by_cases zero : value.after = 0
      · cases negative <;> simp [summarize, zero, unary, unaryResult, invalid]
      · by_cases tooMany : maxOperands < leaves value.expression
        · cases negative <;> simp [summarize, unary, leaves, tooMany, unaryResult, invalid]
        · cases inferred : value.expression.infer (ranges names) with
          | none =>
              cases negative <;> simp [summarize, unary, leaves, zero, tooMany,
                Integer.Expr.infer, inferred, unaryResult, invalid]
          | some bounds =>
              cases negative
              · simp [summarize, unary, leaves, zero, tooMany, Integer.Expr.infer,
                  inferred, isStatic, unaryResult]
              · cases checked : (Integer.checkedNegate bounds).safe <;>
                  simp [summarize, unary, leaves, zero, tooMany, Integer.Expr.infer,
                    inferred, isStatic, unaryResult, Integer.accepted, checked]

theorem binary_correspondence (names : Environment) (left right : Parsed) (operator : Nat)
    (leftPositive : left.after ≠ 0) (rightPositive : right.after ≠ 0) :
    binaryResult (summarize names (some left)) (summarize names (some right)) operator =
      summarize names (binary left right operator) := by
  by_cases unsupported : operator ≠ 43 ∧ operator ≠ 45 ∧ operator ≠ 42
  · simp [binaryResult, binary, unsupported.1, unsupported.2.1, unsupported.2.2, summarize]
  · have supported : operator = 43 ∨ operator = 45 ∨ operator = 42 := by omega
    rcases supported with rfl | rfl | rfl <;>
      simp only [binaryResult, binary, show (45 : Nat) ≠ 43 by decide,
        show (42 : Nat) ≠ 43 by decide, show (42 : Nat) ≠ 45 by decide,
        ↓reduceIte, summarize, leaves, Integer.Expr.infer, isStatic]
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
          cases leftInferred : left.expression.infer (ranges names) with
          | none => simp [invalid]
          | some leftBounds =>
              cases rightInferred : right.expression.infer (ranges names) with
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

theorem checked_bounded_normalize {bounds : Integer.Interval} (bounded : bounds.Bounded) :
    Integer.checked bounds = ⟨true, bounds.normalize⟩ := by
  simp [Integer.checked, Integer.Interval.normalize, bounded]
  split <;> rfl

theorem binding_mem {names : Environment} {index : Nat} (positive : 0 < index)
    (bound : index ≤ names.length) : binding names index ∈ names := by
  have within : index - 1 < names.length := by omega
  simp only [binding, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem within, Option.getD_some]
  exact List.getElem_mem within

theorem binding_bounded {text : Source} {names : Environment} {index : Nat}
    (valid : ValidEnvironment text names) (positive : 0 < index) (bound : index ≤ names.length) :
    (binding names index).bounds.Bounded := (valid.2 _ (binding_mem positive bound)).2.2.2.1

theorem atom_correspondence {text : Source} {names : Environment} (valid : ValidEnvironment text names)
    (position maskFirst maskAfter : Nat) (allowSign : Bool) :
    atomResult text position names maskFirst maskAfter allowSign =
      summarize names (atom text position names maskFirst maskAfter allowSign) := by
  unfold atomResult atom
  dsimp only
  split
  · rfl
  · split
    · split
      · rfl
      · exact literal_correspondence ..
    · split
      · exact literal_correspondence ..
      · split
        · rfl
        · rename_i nameGood
          have positive : 0 < lookup text names (skip text position) (nameAfter text (skip text position)) := by omega
          have bounded := binding_bounded valid positive (lookup_bound text names _ _)
          have afterPositive : nameAfter text (skip text position) ≠ 0 := by
            intro zero
            have zeroLookup : lookup text names (skip text position) 0 = 0 := by
              unfold lookup
              cases names.length <;> simp [lookupFrom]
            simp only [zero, zeroLookup] at positive
            omega
          simp only [summarize, afterPositive, leaves, maxOperands,
            show ¬ 64 < 1 by decide, false_or, ↓reduceIte, Integer.Expr.infer,
            ranges, positive, lookup_bound, and_self, Option.bind_some,
            Integer.accepted, checked_bounded_normalize bounded, isStatic]

end Silver.ScalarExpression.Native
