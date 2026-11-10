module

public import Silver.ProcedureNameTerminals
public import Silver.ProcedureNameLiteralTraversal

@[expose] public section

namespace Silver.Predicate
open Compose

/-- An attribute designator with at least two identifier characters cannot be
misread as a three-byte Character literal, even with trivia after the tick. -/
theorem attribute_no_character {text bytes : Source} {first finish : Nat}
    (source : Named.IdentifierAt text (skipAt text (first + 1)) bytes finish)
    (longName : 2 ≤ bytes.length) : characterLiteralAfter text first = 0 := by
  by_cases absent : characterLiteralAfter text first = 0
  · exact absent
  have literal := characterLiteral_sound absent
  have nextFixed : Cursor.triviaPosition text (first + 2) = first + 2 := by
    rw [Cursor.triviaPosition_equation text (first + 2) (by omega) (by have h := literal.bounded; omega)]
    simp [Nat.not_lt.mpr literal.bounded, whitespace, literal.closing]
  have skipped : skipAt text (first + 1) =
      if whitespace (Cursor.byteAt text (first + 1)) then first + 2 else first + 1 := by
    simp only [skipAt, Nat.add_eq_zero_iff, Nat.one_ne_zero, and_false, ↓reduceIte]
    rw [Cursor.triviaPosition_equation text (first + 1) (by omega) (by have h := literal.bounded; omega)]
    simp only [show ¬first + 1 > text.length by have h := literal.bounded; omega, ↓reduceIte,
      show first + 1 + 1 = first + 2 by omega, literal.closing, show ¬(39 = 45) by decide,
      and_false, nextFixed]
  have length := Named.identifier_bounds source
  cases space : whitespace (Cursor.byteAt text (first + 1)) with
  | true =>
      have letter : Named.letter (Cursor.byteAt text (skipAt text (first + 1))) = true := by
        cases source with
        | identifier _ letter _ => exact letter
      simp [skipped, space, literal.closing, Named.letter] at letter
  | false =>
      have characters := Named.identifier_characters source (first + 2)
        (by simp only [skipped, space, Bool.false_eq_true, ↓reduceIte]; omega)
        (by simp only [skipped, space, Bool.false_eq_true, ↓reduceIte] at length; omega)
      simp [literal.closing, identifierCharacter] at characters

theorem actualNameStep_attribute {text bytes : Source}
    {position first finish limit targetFirst targetAfter : Nat}
    (skipped : skipAt text position = first) (positive : position ≠ 0)
    (before : position < limit) (firstBound : first ≤ text.length)
    (tick : Cursor.byteAt text first = 39)
    (source : Named.IdentifierAt text (skipAt text (first + 1)) bytes finish)
    (longName : 2 ≤ bytes.length) (finishBound : finish ≤ limit) :
    actualNameStep text position limit targetFirst targetAfter = ⟨finish, true⟩ := by
  have next := ScalarExpression.skip_bounds text (first + 1) (by omega)
  change first + 1 ≤ skipAt text (first + 1) ∧ skipAt text (first + 1) ≤ text.length + 1 at next
  have word := Named.identifier_bounds source
  have noCharacter := attribute_no_character source longName
  have numeral : ScalarLiteral.numeral text first 10 = ScalarLiteral.invalid := by
    simp [ScalarLiteral.numeral, ScalarLiteral.digitsTail, ScalarLiteral.digitValue, tick]
  have noNumber : (ScalarLiteral.read text first).after = 0 := by
    simp [ScalarLiteral.read, ScalarLiteral.mantissa, numeral, ScalarLiteral.invalid, Guarded.invalidDecimal]
  have identifier : nameAfter text (skipAt text (first + 1)) = finish := by
    simp only [nameAfter, show skipAt text (first + 1) ≠ 0 by omega, ↓reduceIte,
      Named.identifierEnd_complete source]
  simp only [actualNameStep, positive, Nat.not_le.mpr before, or_self, ↓reduceIte, skipped,
    show ¬ first ≥ limit by omega, noCharacter, noNumber, ne_eq, not_true_eq_false,
    false_and, tick, show ¬(39 = 34) by decide, identifier,
    show finish > first by omega, finishBound, and_self]

theorem ActualNameFreeTrace.attribute {text bytes : Source}
    {position first finish limit targetFirst targetAfter : Nat}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (before : position < limit) (skipped : skipAt text position = first)
    (firstBound : first ≤ text.length) (tick : Cursor.byteAt text first = 39)
    (source : Named.IdentifierAt text (skipAt text (first + 1)) bytes finish)
    (longName : 2 ≤ bytes.length) (finishBound : finish ≤ limit) :
    ActualNameFreeTrace text limit targetFirst targetAfter finish := by
  cases trace with
  | done => omega
  | step positive _ _ _ rest =>
      have step := actualNameStep_attribute (targetFirst := targetFirst) (targetAfter := targetAfter)
        skipped positive before firstBound tick source longName finishBound
      simpa only [step] using rest

end Silver.Predicate
