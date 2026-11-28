module

public import Silver.ScalarExpressionNativeArrayAtoms

@[expose] public section

namespace Silver.ScalarExpression.Native

set_option linter.unusedSimpArgs false

theorem arraysReadFuel_nil (fuel : Nat) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) (initials : ArrayBindings.Initials) (elaborating : Bool) :
    arraysReadFuel fuel text position names maskFirst maskAfter allowSign [] initials elaborating =
      readFuel fuel text position names maskFirst maskAfter allowSign := by
  cases fuel <;> rfl

theorem arraysReadFuel_nonempty {arrays : ArrayBindings.Metadata} (nonempty : arrays ≠ [])
    (fuel : Nat) (text : Source) (position : Nat) (names : Environment)
    (maskFirst maskAfter : Nat) (allowSign : Bool) (initials : ArrayBindings.Initials) (elaborating : Bool) :
    arraysReadFuel (fuel + 1) text position names maskFirst maskAfter allowSign arrays initials elaborating =
      arraysReadStep (@arraysReadFuel fuel) text position names maskFirst maskAfter allowSign arrays initials elaborating := by
  cases arrays with
  | nil => contradiction
  | cons => rfl

theorem arraysReadFuel_nonempty_correspondence {text : Source} {names : Environment}
    (valid : ValidEnvironment text names) {arrays : ArrayBindings.Metadata}
    (metadata : ArrayBindings.ValidMetadata text arrays) (nonempty : arrays ≠ [])
    {initials : ArrayBindings.Initials} (initialsValid : ArrayBindings.ValidInitials initials)
    (elaborating : Bool) (fuel position maskFirst maskAfter : Nat)
    (allowSign : Bool) (bound : position ≤ text.length + 1) :
    arraysReadFuel fuel text position names maskFirst maskAfter allowSign arrays initials elaborating =
      summarizeArrays names arrays initials elaborating (parseArraysFuel fuel text position names arrays maskFirst maskAfter allowSign) := by
  induction fuel generalizing position allowSign with
  | zero => rfl
  | succ fuel ih =>
      have firstBounds := skip_bounds text position bound
      rw [arraysReadFuel_nonempty nonempty]
      simp only [arraysReadStep, parseArraysFuel]
      split
      · rfl
      · rename_i validFirst
        by_cases group : Cursor.byteAt text (skip text position) = 40
        · simp only [group, ne_eq, not_true_eq_false, ↓reduceIte, arraysGroupStep]
          have innerBounds := skip_bounds text (skip text position + 1) (by omega)
          split
          · rfl
          · rename_i validInner
            split
            · simp only [arraysUnaryStep, unaryStep]
              have nextBounds := skip_bounds text (skip text (skip text position + 1) + 1) (by omega)
              split
              · rw [literal_arrays_correspondence arrays initials elaborating, close_arrays_correspondence arrays initials elaborating]
              · rw [ih _ _ nextBounds.2, unary_arrays_correspondence arrays initials elaborating, close_arrays_correspondence arrays initials elaborating]
            · simp only [arraysCompoundStep, compoundStep, ih _ _ innerBounds.2]
              cases leftFound : parseArraysFuel fuel text (skip text (skip text position + 1)) names arrays
                  maskFirst maskAfter true with
              | none => simp [summarizeArrays, invalid, skip]
              | some left =>
                  have leftBounds := parseArraysFuel_bounds innerBounds.2 leftFound
                  have nextBounds := skip_bounds text left.after leftBounds.2
                  by_cases rejected : (summarizeArrays names arrays initials elaborating (some left)).after = 0
                  · rw [summarizeArrays_zero arrays initials elaborating rejected]
                    simp only [show skip text invalid.after = 0 from by simp [skip, invalid],
                      ↓reduceIte, true_or]
                    dsimp only [Bind.bind, Option.bind]
                    split
                    · rfl
                    · split
                      · rw [parenthesized_arrays_correspondence arrays initials elaborating names left _ (by omega) (by omega), rejected]
                        rfl
                      · split
                        · rfl
                        · rename_i supported
                          have operatorBounds := binaryAfter_bounds supported
                          cases rightFound : parseArraysFuel fuel text (binaryAfter text (skip text left.after)) names arrays
                              maskFirst maskAfter false with
                          | none => rfl
                          | some right =>
                              have rightBounds := parseArraysFuel_bounds (by omega) rightFound
                              change invalid = summarizeArrays names arrays initials elaborating (close text (binary left right _))
                              rw [← close_arrays_correspondence arrays initials elaborating, ← binary_arrays_correspondence arrays initials elaborating names left right _
                                (by omega) (by omega), summarizeArrays_zero arrays initials elaborating rejected,
                                binary_invalid_left, close_invalid]
                  · obtain ⟨original, bounds, same, originalPositive, leavesBound, inferred, summarized⟩ :=
                      summarizeArrays_success rejected
                    have originalEq : original = left := by simpa using same.symm
                    subst original
                    have summarizedAfter : (summarizeArrays names arrays initials elaborating (some left)).after = left.after := by rw [summarized]
                    rw [summarizedAfter]
                    dsimp only [Bind.bind, Option.bind]
                    split
                    · rfl
                    · split
                      · rw [parenthesized_arrays_correspondence arrays initials elaborating names left _ (by omega) (by omega)]
                        simp only [rejected, ↓reduceIte]
                      · split
                        · rfl
                        · rename_i supported
                          have operatorBounds := binaryAfter_bounds supported
                          rw [ih _ _ operatorBounds.2]
                          cases rightFound : parseArraysFuel fuel text (binaryAfter text (skip text left.after)) names arrays
                              maskFirst maskAfter false with
                          | none => simp [summarizeArrays, binary_invalid_right, close_invalid]
                          | some right =>
                              have rightBounds := parseArraysFuel_bounds (by omega) rightFound
                              change closeResult text (binaryResult (summarizeArrays names arrays initials elaborating (some left))
                                (summarizeArrays names arrays initials elaborating (some right)) _) = _
                              rw [binary_arrays_correspondence arrays initials elaborating names left right _ (by omega) (by omega),
                                close_arrays_correspondence arrays initials elaborating]
        · simp only [group, ne_eq, not_false_eq_true, ↓reduceIte]
          simp only [arraysReadFuel_nil]
          exact arraysAtom_correspondence valid metadata initialsValid fuel _ maskFirst maskAfter allowSign elaborating firstBounds.2

theorem arraysReadFuel_correspondence {text : Source} {names : Environment}
    (valid : ValidEnvironment text names) {arrays : ArrayBindings.Metadata}
    (metadata : ArrayBindings.ValidMetadata text arrays) {initials : ArrayBindings.Initials}
    (initialsValid : ArrayBindings.ValidInitials initials) (elaborating : Bool)
    (fuel position maskFirst maskAfter : Nat) (allowSign : Bool) (bound : position ≤ text.length + 1) :
    arraysReadFuel fuel text position names maskFirst maskAfter allowSign arrays initials elaborating =
      summarizeArrays names arrays initials elaborating
        (parseWithArrays fuel text position names arrays maskFirst maskAfter allowSign) := by
  cases arrays with
  | nil =>
      rw [arraysReadFuel_nil, readFuel_correspondence valid fuel position maskFirst maskAfter allowSign bound]
      exact (summarizeArrays_nil names initials elaborating _).symm
  | cons item tail =>
      exact arraysReadFuel_nonempty_correspondence valid metadata (by simp) initialsValid
        elaborating fuel position maskFirst maskAfter allowSign bound

theorem parseWithArrays_zero (fuel : Nat) (text : Source) (names : Environment)
    (arrays : ArrayBindings.Metadata) (maskFirst maskAfter : Nat) (allowSign : Bool) :
    parseWithArrays fuel text 0 names arrays maskFirst maskAfter allowSign = none := by
  cases arrays with
  | nil => exact parseFuel_zero ..
  | cons => cases fuel <;> simp [parseWithArrays, parseArraysFuel, skip]

theorem arraysReadFuel_eq_read {text : Source} {names : Environment}
    (valid : ValidEnvironment text names) {arrays : ArrayBindings.Metadata}
    (metadata : ArrayBindings.ValidMetadata text arrays) {initials : ArrayBindings.Initials}
    (initialsValid : ArrayBindings.ValidInitials initials) (elaborating : Bool)
    (fuel position maskFirst maskAfter : Nat) (allowSign : Bool)
    (bound : position ≤ text.length + 1) (enough : text.length + 1 - position < fuel) :
    arraysReadFuel fuel text position names maskFirst maskAfter allowSign arrays initials elaborating =
      read text position names maskFirst maskAfter allowSign arrays initials elaborating := by
  rw [arraysReadFuel_correspondence valid metadata initialsValid elaborating fuel position maskFirst maskAfter allowSign bound,
    read_eq_summarizeArrays]
  by_cases zero : position = 0
  · subst position; simp only [parseWithArrays_zero]
  · congr 1
    cases found : parseWithArrays fuel text position names arrays maskFirst maskAfter allowSign with
    | none =>
        cases other : parseWithArrays (text.length + 1) text position names arrays maskFirst maskAfter allowSign with
        | none => rfl
        | some value =>
            have complete := parseWithArrays_complete (parseWithArrays_sound bound other) fuel bound enough
            rw [found] at complete
            cases complete
    | some value =>
        exact (parseWithArrays_complete (parseWithArrays_sound bound found) (text.length + 1) bound (by omega)).symm

theorem arraysReadFuel_large {text : Source} {names : Environment}
    (valid : ValidEnvironment text names) {arrays : ArrayBindings.Metadata}
    (metadata : ArrayBindings.ValidMetadata text arrays) {initials : ArrayBindings.Initials}
    (initialsValid : ArrayBindings.ValidInitials initials) (elaborating : Bool)
    (fuel position maskFirst maskAfter : Nat) (allowSign : Bool)
    (bound : position ≤ text.length + 1) (large : text.length < fuel) :
    arraysReadFuel fuel text position names maskFirst maskAfter allowSign arrays initials elaborating =
      read text position names maskFirst maskAfter allowSign arrays initials elaborating := by
  by_cases zero : position = 0
  · subst position
    rw [arraysReadFuel_correspondence valid metadata initialsValid elaborating fuel 0 maskFirst maskAfter allowSign (by omega),
      read_eq_summarizeArrays]
    simp only [parseWithArrays_zero]
  · exact arraysReadFuel_eq_read valid metadata initialsValid elaborating fuel position maskFirst maskAfter allowSign bound (by omega)

theorem arraysAtomStep_nil {text : Source} {names : Environment} (valid : ValidEnvironment text names)
    (recurse : Reader) (position maskFirst maskAfter : Nat) (allowSign : Bool)
    (initials : ArrayBindings.Initials) (elaborating : Bool) :
    arraysAtomStep recurse text position names maskFirst maskAfter allowSign [] initials elaborating =
      atomResult text position names maskFirst maskAfter allowSign := by
  rw [arraysAtomStep_dispatch]
  simp only [ArrayBindings.lookup, List.length_nil, ArrayBindings.lookupFrom, true_or, or_true, ↓reduceIte]
  split
  · rfl
  · rename_i absent
    rw [atom_correspondence valid]
    cases found : atom text position names maskFirst maskAfter allowSign with
    | none => rfl
    | some value => simp [found] at absent

theorem arraysReadStep_nil {text : Source} {names : Environment} (valid : ValidEnvironment text names)
    (recurse : ArraysReader) (position maskFirst maskAfter : Nat) (allowSign : Bool)
    (initials : ArrayBindings.Initials) (elaborating : Bool) :
    arraysReadStep (@recurse) text position names maskFirst maskAfter allowSign [] initials elaborating =
      readStep (fun text position names maskFirst maskAfter allowSign =>
        recurse text position names maskFirst maskAfter allowSign [] initials elaborating)
        text position names maskFirst maskAfter allowSign := by
  simp only [arraysReadStep, readStep]
  split
  · rfl
  · split
    · simp only [arraysGroupStep, groupStep, arraysUnaryStep, arraysCompoundStep]
    · exact arraysAtomStep_nil valid ..

theorem nameAfter_cursor_bound (text : Source) (position : Nat) : nameAfter text position ≤ text.length + 1 := by
  by_cases zero : position = 0
  · simp [nameAfter, zero]
  · by_cases failed : Named.identifierEnd text position = 0
    · simp [nameAfter, zero, failed]
    · simpa only [nameAfter, zero, ↓reduceIte] using (Named.identifierEnd_bounds text position failed).2

theorem arraysReadStep_congr {text : Source} {names : Environment}
    (left right : ArraysReader) (position maskFirst maskAfter : Nat) (allowSign : Bool)
    (arrays : ArrayBindings.Metadata) (initials : ArrayBindings.Initials) (elaborating : Bool)
    (bound : position ≤ text.length + 1)
    (same : ∀ next sign, next ≤ text.length + 1 →
      left text next names maskFirst maskAfter sign arrays initials elaborating =
        right text next names maskFirst maskAfter sign arrays initials elaborating)
    (scalarSame : ∀ next sign, next ≤ text.length + 1 →
      left text next names maskFirst maskAfter sign = right text next names maskFirst maskAfter sign) :
    arraysReadStep (@left) text position names maskFirst maskAfter allowSign arrays initials elaborating =
      arraysReadStep (@right) text position names maskFirst maskAfter allowSign arrays initials elaborating := by
  have firstBounds := skip_bounds text position bound
  simp only [arraysReadStep]
  split
  · rfl
  · rename_i validFirst
    split
    · simp only [arraysGroupStep]
      have innerBounds := skip_bounds text (skip text position + 1) (by omega)
      split
      · rfl
      · rename_i validInner
        split
        · simp only [arraysUnaryStep, unaryStep]
          have nextBounds := skip_bounds text (skip text (skip text position + 1) + 1) (by omega)
          rw [same _ false nextBounds.2]
        · rw [same _ true innerBounds.2]
          simp only [arraysCompoundStep, compoundStep]
          split
          · rfl
          · split
            · rfl
            · split
              · rfl
              · rename_i supported
                rw [same _ false (binaryAfter_bounds supported).2]
    · simp only [arraysAtomStep_dispatch]
      split
      · rfl
      · split
        · rfl
        · simp only [arrayAtomStep]
          split
          · rfl
          · rename_i opening
            rw [scalarSame _ true (symbol_bounds (nameAfter_cursor_bound text _) (not_or.mp opening).1).2]

theorem arrays_read_step {text : Source} {names : Environment}
    (valid : ValidEnvironment text names) {arrays : ArrayBindings.Metadata}
    (metadata : ArrayBindings.ValidMetadata text arrays) {initials : ArrayBindings.Initials}
    (initialsValid : ArrayBindings.ValidInitials initials) (elaborating : Bool)
    (position maskFirst maskAfter : Nat) (allowSign : Bool) (bound : position ≤ text.length + 1) :
    arraysReadStep (@read) text position names maskFirst maskAfter allowSign arrays initials elaborating =
      read text position names maskFirst maskAfter allowSign arrays initials elaborating := by
  by_cases empty : arrays = []
  · subst arrays
    rw [arraysReadStep_nil valid]
    exact read_step valid position maskFirst maskAfter allowSign bound
  · have equation := arraysReadFuel_large valid metadata initialsValid elaborating
      (text.length + 2) position maskFirst maskAfter allowSign bound (by omega)
    rw [show text.length + 2 = (text.length + 1) + 1 from rfl,
      arraysReadFuel_nonempty empty] at equation
    have same := arraysReadStep_congr (text := text) (names := names) (@arraysReadFuel (text.length + 1))
      (@read) position maskFirst maskAfter allowSign arrays initials elaborating bound
      (by
        intro next sign nextBound
        exact arraysReadFuel_large valid metadata initialsValid elaborating
          _ next maskFirst maskAfter sign nextBound (by omega))
      (by
        intro next sign nextBound
        rw [arraysReadFuel_nil]
        exact readFuel_large valid _ next maskFirst maskAfter sign nextBound (by omega))
    exact same.symm.trans equation

end Silver.ScalarExpression.Native
