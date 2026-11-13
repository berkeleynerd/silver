module

public import Silver.ProcedureNameScanner

@[expose] public section

namespace Silver.Predicate
open Compose

private theorem triviaEnd_fixed {text rest : Source} (parsed : Trivia text rest) :
    triviaEnd rest = rest := by
  induction parsed with
  | eof => simp only [triviaEnd]
  | stop _ _ space comment => simp [triviaEnd, space, comment]
  | space _ _ _ _ _ ih => exact ih
  | comment _ _ _ _ _ ih => exact ih

theorem skipAt_idempotent (text : Source) (position : Nat) :
    skipAt text (skipAt text position) = skipAt text position := by
  by_cases zero : position = 0
  · simp [skipAt, zero]
  have positive : Cursor.triviaPosition text position ≠ 0 := by
    have length := triviaEnd_length (Cursor.remaining text position)
    have remaining : (Cursor.remaining text position).length ≤ text.length := by
      simp [Cursor.remaining]
    unfold Cursor.triviaPosition Cursor.endPosition
    omega
  simp only [skipAt, zero, ↓reduceIte, positive]
  change Cursor.endPosition text (triviaEnd (Cursor.remaining text (Cursor.triviaPosition text position))) = _
  rw [Cursor.remaining_triviaPosition, triviaEnd_fixed (trivia_complete _)]
  rfl

theorem fixedAfter_skipped {text : Source} {position : Nat}
    (positionBound : position ≤ text.length + 1) (word : String) (wordFlag : Bool) :
    fixedAfter text (skipAt text position) word wordFlag = fixedAfter text position word wordFlag := by
  by_cases zero : position = 0
  · simp [zero, skipAt, fixedAfter]
  have skipped := ScalarExpression.skip_bounds text position positionBound
  have triviaPositive : Cursor.triviaPosition text position ≠ 0 := by
    change position ≤ ScalarExpression.skip text position ∧ _ at skipped
    simpa only [ScalarExpression.skip, zero, ↓reduceIte] using (show ScalarExpression.skip text position ≠ 0 by omega)
  have repeated : Cursor.triviaPosition text (Cursor.triviaPosition text position) = Cursor.triviaPosition text position := by
    simpa only [skipAt, zero, triviaPositive, ↓reduceIte] using skipAt_idempotent text position
  simp only [fixedAfter, skipAt, zero, triviaPositive, ↓reduceIte, repeated]

theorem actualNameStep_skipped {text : Source} {position limit targetFirst targetAfter : Nat}
    (positive : position ≠ 0) (before : position < limit)
    (firstPositive : skipAt text position ≠ 0) (firstBefore : skipAt text position < limit) :
    actualNameStep text (skipAt text position) limit targetFirst targetAfter =
      actualNameStep text position limit targetFirst targetAfter := by
  simp only [actualNameStep, skipAt_idempotent, positive, firstPositive,
    Nat.not_le.mpr before, Nat.not_le.mpr firstBefore, or_self, ↓reduceIte]

theorem ActualNameFreeTrace.skipped {text : Source} {position limit targetFirst targetAfter : Nat}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (firstPositive : skipAt text position ≠ 0) (firstBefore : skipAt text position < limit)
    (positionBound : position ≤ text.length + 1) :
    ActualNameFreeTrace text limit targetFirst targetAfter (skipAt text position) := by
  cases trace with
  | done positive =>
      have bound := Cursor.triviaPosition_bounds text position (Nat.pos_of_ne_zero positive) positionBound
      simp only [skipAt, positive, ↓reduceIte] at firstBefore
      omega
  | step positive before nonzero free rest =>
      have same := actualNameStep_skipped (targetFirst := targetFirst) (targetAfter := targetAfter)
        positive before firstPositive firstBefore
      exact .step firstPositive firstBefore (by simpa only [same] using nonzero)
        (by simpa only [same] using free) (by simpa only [same] using rest)

theorem ActualNameFreeTrace.number {text : Source} {position first value finish limit targetFirst targetAfter : Nat}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (before : position < limit) (skipped : skipAt text position = first)
    (number : ScalarLiteral.IntegerAt text first value finish) (bounded : finish ≤ limit) :
    ActualNameFreeTrace text limit targetFirst targetAfter finish := by
  cases trace with
  | done => omega
  | step positive _ _ _ rest =>
      have step := actualNameStep_number (targetFirst := targetFirst) (targetAfter := targetAfter)
        skipped positive before number bounded
      simpa only [step] using rest

/-- Non-dot symbols outside literal and identifier starts advance one byte.
Dot selectors and contiguous ranges have separate checked traversal rules. The
caller supplies the source terminal; no semantic name-use assumption is hidden. -/
def OrdinarySymbol (byte : Nat) : Prop :=
  Named.letter byte = false ∧ 10 ≤ ScalarLiteral.digitValue byte ∧ byte ≠ 34 ∧ byte ≠ 39 ∧ byte ≠ 46

private theorem literal_not_digit (text : Source) (position : Nat)
    (digit : 10 ≤ ScalarLiteral.digitValue (Cursor.byteAt text position)) :
    (ScalarLiteral.read text position).after = 0 := by
  have leading : ScalarLiteral.numeral text position 10 = ScalarLiteral.invalid := by
    simp [ScalarLiteral.numeral, ScalarLiteral.digitsTail, Nat.not_lt.mpr digit]
  simp [ScalarLiteral.read, ScalarLiteral.mantissa, leading, ScalarLiteral.invalid, Guarded.invalidDecimal]

theorem actualNameStep_symbol {text : Source} {position first limit targetFirst targetAfter : Nat}
    (skipped : skipAt text position = first) (positive : position ≠ 0)
    (before : position < limit) (firstBefore : first < limit)
    (symbol : OrdinarySymbol (Cursor.byteAt text first)) :
    actualNameStep text position limit targetFirst targetAfter = ⟨first + 1, true⟩ := by
  have noName : nameAfter text first = 0 := by
    simp [nameAfter, Named.identifierEnd, symbol.1]
  have noNumber := literal_not_digit text first symbol.2.1
  have noCharacter : characterLiteralAfter text first = 0 := by
    simp only [characterLiteralAfter, symbol.2.2.2.1, false_and, and_false, ↓reduceIte]
  simp [actualNameStep, skipped, positive, Nat.not_le.mpr before,
    Nat.not_le.mpr firstBefore, noName, noNumber, noCharacter, symbol.2.2.1, symbol.2.2.2.1, symbol.2.2.2.2]

theorem ActualNameFreeTrace.symbol {text : Source} {position first limit targetFirst targetAfter : Nat}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (before : position < limit) (skipped : skipAt text position = first)
    (firstBefore : first < limit) (symbol : OrdinarySymbol (Cursor.byteAt text first)) :
    ActualNameFreeTrace text limit targetFirst targetAfter (first + 1) := by
  cases trace with
  | done => omega
  | step positive _ _ _ rest =>
      have step := actualNameStep_symbol (targetFirst := targetFirst) (targetAfter := targetAfter)
        skipped positive before firstBefore symbol
      simpa only [step] using rest

end Silver.Predicate
