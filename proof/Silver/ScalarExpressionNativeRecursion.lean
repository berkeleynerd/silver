module

public import Silver.ScalarExpressionNativeAlgebra

@[expose] public section

namespace Silver.ScalarExpression.Native

set_option linter.unusedSimpArgs false

theorem close_invalid (text : Source) : closeResult text invalid = invalid := by
  simp [closeResult, invalid, symbol, skip]

theorem close_correspondence (text : Source) (names : Environment) (parsed : Option Parsed) :
    closeResult text (summarize names parsed) = summarize names (close text parsed) := by
  cases parsed with
  | none => simp [summarize, close, close_invalid]
  | some value =>
      by_cases zero : value.after = 0
      · simp [summarize, zero, close, symbol, skip, close_invalid]
      · by_cases many : maxOperands < leaves value.expression
        · simp only [summarize, many, or_true, ↓reduceIte, close_invalid]
          change invalid = summarize names (if symbol text value.after 41 = 0 then none
            else some {value with after := symbol text value.after 41})
          split <;> simp [summarize, many]
        · cases inferred : value.expression.infer (ranges names) with
          | none =>
              simp only [summarize, zero, many, or_self, ↓reduceIte, inferred, close_invalid]
              change invalid = summarize names (if symbol text value.after 41 = 0 then none
                else some {value with after := symbol text value.after 41})
              split <;> simp [summarize, many, inferred]
          | some bounds =>
              simp only [summarize, zero, many, or_self, ↓reduceIte, inferred, closeResult,
                close, Option.bind_some]
              split <;> simp [summarize, many, inferred, *]

theorem summarize_after_update (names : Environment) (value : Parsed) (finish : Nat)
    (positive : value.after ≠ 0) (finishPositive : finish ≠ 0)
    (success : (summarize names (some value)).after ≠ 0) :
    summarize names (some {value with after := finish}) =
      {summarize names (some value) with after := finish} := by
  simp only [summarize, positive, finishPositive, false_or]
  split
  · simp [summarize, positive, * , invalid] at success
  · cases found : value.expression.infer (ranges names) with
    | none => simp [summarize, found, * , invalid] at success
    | some bounds => rfl

theorem parenthesized_correspondence (names : Environment) (value : Parsed) (finish : Nat)
    (positive : value.after ≠ 0) (finishPositive : finish ≠ 0) :
    summarize names (some ⟨finish, .parenthesized value.expression⟩) =
      if (summarize names (some value)).after = 0 then invalid
      else {summarize names (some value) with after := finish} := by
  simp only [summarize, positive, finishPositive, leaves, Integer.Expr.infer,
    isStatic, false_or]
  split
  · rfl
  · cases found : value.expression.infer (ranges names) with
    | none => rfl
    | some bounds => simp [positive]

theorem summarize_zero {names : Environment} {parsed : Option Parsed}
    (zero : (summarize names parsed).after = 0) : summarize names parsed = invalid := by
  cases parsed with
  | none => rfl
  | some value =>
      simp only [summarize] at zero ⊢
      split
      · rfl
      · rename_i good
        cases found : value.expression.infer (ranges names) with
        | none => rfl
        | some bounds => simp only [ite_eq_right good, found] at zero; omega

theorem binary_invalid_left (right : Result) (operator : Nat) :
    binaryResult invalid right operator = invalid := by simp [binaryResult, invalid]

theorem binary_invalid_right (left : Result) (operator : Nat) :
    binaryResult left invalid operator = invalid := by simp [binaryResult, invalid]

theorem readFuel_correspondence {text : Source} {names : Environment}
    (valid : ValidEnvironment text names) (fuel position maskFirst maskAfter : Nat)
    (allowSign : Bool) (bound : position ≤ text.length + 1) :
    readFuel fuel text position names maskFirst maskAfter allowSign =
      summarize names (parseFuel fuel text position names maskFirst maskAfter allowSign) := by
  induction fuel generalizing position allowSign with
  | zero => rfl
  | succ fuel ih =>
      have firstBounds := skip_bounds text position bound
      simp only [readFuel, readStep, parseFuel]
      split
      · rfl
      · rename_i validFirst
        by_cases group : Cursor.byteAt text (skip text position) = 40
        · simp only [group, ne_eq, not_true_eq_false, ↓reduceIte, groupStep]
          have innerBounds := skip_bounds text (skip text position + 1) (by omega)
          split
          · rfl
          · rename_i validInner
            split
            · simp only [unaryStep]
              have nextBounds := skip_bounds text (skip text (skip text position + 1) + 1) (by omega)
              split
              · rw [literal_correspondence, close_correspondence]
              · rw [ih _ _ nextBounds.2, unary_correspondence, close_correspondence]
            · simp only [compoundStep, ih _ _ innerBounds.2]
              cases leftFound : parseFuel fuel text (skip text (skip text position + 1)) names
                  maskFirst maskAfter true with
              | none => simp [summarize, invalid, skip]
              | some left =>
                  have leftBounds := parseFuel_bounds innerBounds.2 leftFound
                  have nextBounds := skip_bounds text left.after leftBounds.2
                  by_cases rejected : (summarize names (some left)).after = 0
                  · rw [summarize_zero rejected]
                    simp only [show skip text invalid.after = 0 from by simp [skip, invalid],
                      ↓reduceIte, true_or]
                    dsimp only [Bind.bind, Option.bind]
                    split
                    · rfl
                    · split
                      · rw [parenthesized_correspondence names left _ (by omega) (by omega), rejected]
                        rfl
                      · split
                        · rfl
                        · rename_i supported
                          cases rightFound : parseFuel fuel text (skip text left.after + 1) names
                              maskFirst maskAfter false with
                          | none => rfl
                          | some right =>
                              have rightBounds := parseFuel_bounds (by omega) rightFound
                              change invalid = summarize names (close text (binary left right _))
                              rw [← close_correspondence, ← binary_correspondence names left right _
                                (by omega) (by omega), summarize_zero rejected,
                                binary_invalid_left, close_invalid]
                  · obtain ⟨original, bounds, same, originalPositive, leavesBound, inferred, summarized⟩ :=
                      summarize_success rejected
                    have originalEq : original = left := by simpa using same.symm
                    subst original
                    have summarizedAfter : (summarize names (some left)).after = left.after := by rw [summarized]
                    rw [summarizedAfter]
                    dsimp only [Bind.bind, Option.bind]
                    split
                    · rfl
                    · split
                      · rw [parenthesized_correspondence names left _ (by omega) (by omega)]
                        simp only [rejected, ↓reduceIte]
                      · split
                        · rfl
                        · rw [ih _ _ (by omega)]
                          cases rightFound : parseFuel fuel text (skip text left.after + 1) names
                              maskFirst maskAfter false with
                          | none => simp [summarize, binary_invalid_right, close_invalid]
                          | some right =>
                              have rightBounds := parseFuel_bounds (by omega) rightFound
                              change closeResult text (binaryResult (summarize names (some left))
                                (summarize names (some right)) _) = _
                              rw [binary_correspondence names left right _ (by omega) (by omega),
                                close_correspondence]
        · simp only [group, ne_eq, not_false_eq_true, ↓reduceIte]
          exact atom_correspondence valid ..

theorem parseFuel_zero (fuel : Nat) (text : Source) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) :
    parseFuel fuel text 0 names maskFirst maskAfter allowSign = none := by
  cases fuel <;> simp [parseFuel, skip]

theorem readFuel_eq_read {text : Source} {names : Environment}
    (valid : ValidEnvironment text names) (fuel position maskFirst maskAfter : Nat)
    (allowSign : Bool) (bound : position ≤ text.length + 1)
    (enough : text.length + 1 - position < fuel) :
    readFuel fuel text position names maskFirst maskAfter allowSign =
      read text position names maskFirst maskAfter allowSign := by
  rw [readFuel_correspondence valid fuel position maskFirst maskAfter allowSign bound]
  unfold read
  by_cases zero : position = 0
  · subst position; simp [parseFuel_zero]
  · congr 1
    cases found : parseFuel fuel text position names maskFirst maskAfter allowSign with
    | none =>
        cases other : parseFuel (text.length + 1) text position names maskFirst maskAfter allowSign with
        | none => rfl
        | some value =>
            have complete := parseFuel_complete (parseFuel_sound bound other) fuel bound enough
            rw [found] at complete
            cases complete
    | some value =>
        exact (parseFuel_complete (parseFuel_sound bound found) (text.length + 1) bound (by omega)).symm

theorem readFuel_large {text : Source} {names : Environment}
    (valid : ValidEnvironment text names) (fuel position maskFirst maskAfter : Nat)
    (allowSign : Bool) (bound : position ≤ text.length + 1) (large : text.length < fuel) :
    readFuel fuel text position names maskFirst maskAfter allowSign =
      read text position names maskFirst maskAfter allowSign := by
  by_cases zero : position = 0
  · subst position
    rw [readFuel_correspondence valid fuel 0 maskFirst maskAfter allowSign (by omega)]
    simp [read, parseFuel_zero]
  · exact readFuel_eq_read valid fuel position maskFirst maskAfter allowSign bound (by omega)

theorem read_step {text : Source} {names : Environment}
    (valid : ValidEnvironment text names) (position maskFirst maskAfter : Nat)
    (allowSign : Bool) (bound : position ≤ text.length + 1) :
    readStep (@read) text position names maskFirst maskAfter allowSign =
      read text position names maskFirst maskAfter allowSign := by
  have equation := readFuel_large valid (text.length + 2) position maskFirst maskAfter allowSign bound (by omega)
  rw [show text.length + 2 = (text.length + 1) + 1 from rfl, readFuel] at equation
  have same : readStep (readFuel (text.length + 1)) text position names maskFirst maskAfter allowSign =
      readStep (@read) text position names maskFirst maskAfter allowSign := by
    have firstBounds := skip_bounds text position bound
    simp only [readStep]
    split
    · rfl
    · rename_i validFirst
      split
      · simp only [groupStep]
        have innerBounds := skip_bounds text (skip text position + 1) (by omega)
        split
        · rfl
        · rename_i validInner
          split
          · simp only [unaryStep]
            have nextBounds := skip_bounds text (skip text (skip text position + 1) + 1) (by omega)
            rw [readFuel_large valid _ _ maskFirst maskAfter false nextBounds.2 (by omega)]
          · rw [readFuel_large valid _ _ maskFirst maskAfter true innerBounds.2 (by omega)]
            simp only [compoundStep]
            have leftBound : (read text (skip text (skip text position + 1)) names maskFirst maskAfter true).after
                ≤ text.length + 1 := by
              by_cases zero : (read text (skip text (skip text position + 1)) names maskFirst maskAfter true).after = 0
              · omega
              · exact (read_bounds innerBounds.2 zero).2.1
            have nextBounds := skip_bounds text _ leftBound
            split
            · rfl
            · split
              · rfl
              · split
                · rfl
                · rw [readFuel_large valid _ _ maskFirst maskAfter false (by omega) (by omega)]
      · rfl
  exact same.symm.trans equation

end Silver.ScalarExpression.Native
