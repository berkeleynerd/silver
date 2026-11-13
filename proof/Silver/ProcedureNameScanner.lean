module

public import Silver.ComposeAtomAdmission

@[expose] public section

/-! The exact lexical traversal used to exclude a writable actual's spelling
from every other actual. Numeric and quoted literals and attribute designators
are skipped as syntax; the validity selector is skipped after a nonrange dot.
Ordinary identifiers retain the case-insensitive test. -/
namespace Silver.Predicate
open Compose

structure NameScanStep where
  next : Nat
  free : Bool
  deriving DecidableEq, Repr

def actualNameStep (text : Source) (position after targetFirst targetAfter : Nat) : NameScanStep :=
  let first := skipAt text position
  let numberAfter := (ScalarLiteral.read text first).after
  if position = 0 ∨ position ≥ after then ⟨0, false⟩
  else if first ≥ after then ⟨after, true⟩
  else
    let characterAfter := characterLiteralAfter text first
    if characterAfter ≠ 0 ∧ characterAfter ≤ after then ⟨characterAfter, true⟩
    else if Cursor.byteAt text first = 34 then
      let quoted := literalAt text first
      if quoted.after > first ∧ quoted.after ≤ after then ⟨quoted.after, true⟩ else ⟨0, false⟩
    else if numberAfter ≠ 0 ∧ numberAfter ≤ after then ⟨numberAfter, true⟩
    else if Cursor.byteAt text first = 39 then
      let wordAfter := nameAfter text (skipAt text (first + 1))
      if wordAfter > first ∧ wordAfter ≤ after then ⟨wordAfter, true⟩ else ⟨first + 1, true⟩
    else
      let selectorAfter :=
        if Cursor.byteAt text first = 46 ∧ first > 1 ∧ Cursor.byteAt text (first - 1) ≠ 46
        then fixedAfter text (fixedAfter text first "." false) "input_is_valid" true else 0
      if selectorAfter > first ∧ selectorAfter ≤ after then ⟨selectorAfter, true⟩
      else
        let wordAfter := nameAfter text first
        if wordAfter > first ∧ wordAfter ≤ after then
          ⟨wordAfter, !Named.equalName text first wordAfter targetFirst targetAfter⟩
        else ⟨first + 1, true⟩

theorem actualNameStep_progress (text : Source) (position after targetFirst targetAfter : Nat)
    (positionBound : position ≤ text.length + 1) :
    (actualNameStep text position after targetFirst targetAfter).next = 0 ∨
      (position < (actualNameStep text position after targetFirst targetAfter).next ∧
        (actualNameStep text position after targetFirst targetAfter).next ≤ after) := by
  by_cases positive : position = 0
  · simp [actualNameStep, positive]
  have skipped : position ≤ skipAt text position := by
    simpa only [skipAt, positive, ↓reduceIte] using
      (Cursor.triviaPosition_bounds text position (by omega) positionBound).1
  have firstBound : skipAt text position ≤ text.length + 1 := by
    simpa only [skipAt, positive, ↓reduceIte] using
      (Cursor.triviaPosition_bounds text position (by omega) positionBound).2
  unfold actualNameStep
  dsimp only
  split
  · exact .inl rfl
  · rename_i active
    split
    · exact .inr ⟨by dsimp only; omega, Nat.le_refl _⟩
    · rename_i before
      split
      · rename_i character
        have progress := characterLiteralAfter_bounds character.1
        exact .inr ⟨by dsimp only; omega, character.2⟩
      · split
        · split
          · rename_i quoted
            exact .inr ⟨by dsimp only; omega, quoted.2⟩
          · exact .inl rfl
        · split
          · rename_i number
            have progress := (ScalarLiteral.integer_bounds (ScalarLiteral.read_sound firstBound number.1)).1
            exact .inr ⟨by dsimp only; omega, number.2⟩
          · split
            · split
              · rename_i designator
                exact .inr ⟨by dsimp only; omega, designator.2⟩
              · exact .inr ⟨by dsimp only; omega, by dsimp only; omega⟩
            · generalize selected : (if Cursor.byteAt text (skipAt text position) = 46 ∧
                  skipAt text position > 1 ∧ Cursor.byteAt text (skipAt text position - 1) ≠ 46
                  then fixedAfter text (fixedAfter text (skipAt text position) "." false) "input_is_valid" true
                  else 0) = selectorAfter
              split
              · rename_i selector
                exact .inr ⟨by dsimp only; omega, selector.2⟩
              · split
                · rename_i identifier
                  exact .inr ⟨by dsimp only; omega, identifier.2⟩
                · exact .inr ⟨by dsimp only; omega, by dsimp only; omega⟩

private theorem scalarLiteral_noDigit (text : Source) (position : Nat)
    (digit : 10 ≤ ScalarLiteral.digitValue (Cursor.byteAt text position)) :
    (ScalarLiteral.read text position).after = 0 := by
  have leading : ScalarLiteral.numeral text position 10 = ScalarLiteral.invalid := by
    simp [ScalarLiteral.numeral, ScalarLiteral.digitsTail, Nat.not_lt.mpr digit]
  simp [ScalarLiteral.read, ScalarLiteral.mantissa, leading, ScalarLiteral.invalid, Guarded.invalidDecimal]

private theorem scalarLiteral_letter (text : Source) (position : Nat)
    (letter : Named.letter (Cursor.byteAt text position) = true) :
    (ScalarLiteral.read text position).after = 0 := by
  have letterRange := letter
  simp only [Named.letter, decide_eq_true_eq] at letterRange
  apply scalarLiteral_noDigit
  unfold ScalarLiteral.digitValue
  split
  · omega
  · split
    · omega
    · split <;> omega

theorem actualNameStep_number {text : Source}
    {position first value finish after targetFirst targetAfter : Nat}
    (skipped : skipAt text position = first) (positionPositive : position ≠ 0)
    (positionBefore : position < after) (number : ScalarLiteral.IntegerAt text first value finish)
    (finishBound : finish ≤ after) :
    actualNameStep text position after targetFirst targetAfter = ⟨finish, true⟩ := by
  have advance := (ScalarLiteral.integer_bounds number).1
  have read := ScalarLiteral.read_complete number
  have notDouble : Cursor.byteAt text first ≠ 34 := by
    intro quoted
    have invalid := scalarLiteral_noDigit text first (by simp [ScalarLiteral.digitValue, quoted])
    rw [read] at invalid
    dsimp only at invalid
    omega
  have notApostrophe : Cursor.byteAt text first ≠ 39 := by
    intro quoted
    have invalid := scalarLiteral_noDigit text first (by simp [ScalarLiteral.digitValue, quoted])
    rw [read] at invalid
    dsimp only at invalid
    omega
  have noCharacter : characterLiteralAfter text first = 0 := by
    simp only [characterLiteralAfter, notApostrophe, false_and, and_false, ↓reduceIte]
  simp [actualNameStep, skipped, read, positionPositive, Nat.not_le.mpr positionBefore,
    show ¬ first ≥ after by omega, noCharacter, notDouble, show finish ≠ 0 by omega, finishBound]

theorem actualNameStep_identifier {text bytes : Source}
    {position first finish after targetFirst targetAfter : Nat}
    (skipped : skipAt text position = first) (positionPositive : position ≠ 0)
    (firstPositive : first ≠ 0) (positionBefore : position < after)
    (identifier : Named.IdentifierAt text first bytes finish) (finishBound : finish ≤ after) :
    actualNameStep text position after targetFirst targetAfter =
      ⟨finish, !Named.equalName text first finish targetFirst targetAfter⟩ := by
  have advance := (Named.identifier_bounds identifier).2.2.1
  have nameAfter : Compose.nameAfter text first = finish := by
    simp only [Compose.nameAfter, firstPositive, ↓reduceIte, Named.identifierEnd_complete identifier]
  have letter : Named.letter (Cursor.byteAt text first) = true := by
    cases identifier with
    | identifier _ letter _ => exact letter
  have notDouble : Cursor.byteAt text first ≠ 34 := by
    simp only [Named.letter, decide_eq_true_eq] at letter
    omega
  have notApostrophe : Cursor.byteAt text first ≠ 39 := by
    simp only [Named.letter, decide_eq_true_eq] at letter
    omega
  have noCharacter : characterLiteralAfter text first = 0 := by
    simp only [characterLiteralAfter, notApostrophe, false_and, and_false, ↓reduceIte]
  have notDot : Cursor.byteAt text first ≠ 46 := by
    simp only [Named.letter, decide_eq_true_eq] at letter
    omega
  have noNumber := scalarLiteral_letter text first letter
  simp only [actualNameStep, positionPositive, Nat.not_le.mpr positionBefore, or_self,
    ↓reduceIte, skipped, show ¬ first ≥ after by omega, noCharacter, noNumber,
    ne_eq, not_true_eq_false, false_and, notDouble, notApostrophe, notDot, Nat.not_lt_zero, nameAfter,
    show finish > first from advance, finishBound, and_self]

def actualNameFree (text : Source) (position after targetFirst targetAfter : Nat) : Bool :=
  if position = 0 ∨ position > after then false
  else if position = after then true
  else
    let next := actualNameStep text position after targetFirst targetAfter
    if next.next = 0 ∨ !next.free then false
    else if _advanced : text.length + 1 - next.next < text.length + 1 - position then
      actualNameFree text next.next after targetFirst targetAfter
    else false
termination_by text.length + 1 - position

/-- A successful executable scan supplies a finite traversal with the actual
lexical step at every cursor. It supplies no semantic nonaliasing premise. -/
inductive ActualNameFreeTrace (text : Source) (after targetFirst targetAfter : Nat) : Nat → Prop
  | done : after ≠ 0 → ActualNameFreeTrace text after targetFirst targetAfter after
  | step {position : Nat} : position ≠ 0 → position < after →
      (actualNameStep text position after targetFirst targetAfter).next ≠ 0 →
      (actualNameStep text position after targetFirst targetAfter).free = true →
      ActualNameFreeTrace text after targetFirst targetAfter
        (actualNameStep text position after targetFirst targetAfter).next →
      ActualNameFreeTrace text after targetFirst targetAfter position

theorem actualNameFree_sound {text : Source} {position after targetFirst targetAfter : Nat}
    (accepted : actualNameFree text position after targetFirst targetAfter = true) :
    ActualNameFreeTrace text after targetFirst targetAfter position := by
  rw [actualNameFree] at accepted
  split at accepted
  · contradiction
  · rename_i active
    split at accepted
    · rename_i atEnd
      subst position
      exact .done (by omega)
    · rename_i before
      dsimp only at accepted
      split at accepted
      · contradiction
      · rename_i good
        simp only [not_or, Bool.not_eq_true'] at good
        split at accepted
        · exact .step (by omega) (by omega) good.1
            (Bool.eq_true_of_ne_false good.2) (actualNameFree_sound accepted)
        · contradiction
termination_by text.length + 1 - position
decreasing_by assumption

theorem ActualNameFreeTrace.identifier {text bytes : Source}
    {position first finish after targetFirst targetAfter : Nat}
    (trace : ActualNameFreeTrace text after targetFirst targetAfter position)
    (before : position < after) (skipped : skipAt text position = first)
    (firstPositive : first ≠ 0) (identifier : Named.IdentifierAt text first bytes finish)
    (finishBound : finish ≤ after) :
    Named.equalName text first finish targetFirst targetAfter = false ∧
      ActualNameFreeTrace text after targetFirst targetAfter finish := by
  cases trace with
  | done => omega
  | step positive _ nonzero free rest =>
      have step := actualNameStep_identifier (targetFirst := targetFirst) (targetAfter := targetAfter)
        skipped positive firstPositive before identifier finishBound
      rw [step] at free rest
      exact ⟨by simpa only [Bool.not_eq_true'] using free, rest⟩

theorem ActualNameFreeTrace.complete {text : Source} {position after targetFirst targetAfter : Nat}
    (trace : ActualNameFreeTrace text after targetFirst targetAfter position)
    (afterBound : after ≤ text.length + 1) (positionBound : position ≤ text.length + 1) :
    actualNameFree text position after targetFirst targetAfter = true := by
  induction trace with
  | done positive => simp [actualNameFree, positive]
  | @step position positive before nonzero free rest ih =>
      have step := (actualNameStep_progress text position after targetFirst targetAfter positionBound).resolve_left nonzero
      have advanced : text.length + 1 - (actualNameStep text position after targetFirst targetAfter).next <
          text.length + 1 - position := by omega
      rw [actualNameFree]
      simp only [positive, Nat.not_lt.mpr (Nat.le_of_lt before), or_self, ↓reduceIte,
        Nat.ne_of_lt before, nonzero, free, Bool.not_true, Bool.false_eq_true]
      rw [dite_eq_left advanced]
      exact ih (by omega)

/-- A real bare identifier equal to the writable target remains an alias.
This applies to every identifier spelling, including Input_Is_Valid. -/
theorem actualNameFree_identifier_alias {text bytes : Source}
    {position first finish after targetFirst targetAfter : Nat}
    (before : position < after) (skipped : skipAt text position = first)
    (positive : first ≠ 0) (identifier : Named.IdentifierAt text first bytes finish)
    (finishBound : finish ≤ after)
    (same : Named.equalName text first finish targetFirst targetAfter = true) :
    actualNameFree text position after targetFirst targetAfter = false := by
  apply Bool.eq_false_iff.mpr
  intro accepted
  have excluded := ((actualNameFree_sound accepted).identifier before skipped positive identifier finishBound).1
  rw [same] at excluded
  contradiction

end Silver.Predicate
