module

public import Silver.ProcedureNameAttributes
public import Silver.ProcedureNamePunctuation
public import Silver.ComposeBounds

@[expose] public section

namespace Silver.Predicate
open Compose

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

/-- Attribute punctuation and its designator are one scanner step. The
at-least-two-letter premise prevents the tick from being a Character literal. -/
theorem ActualNameFreeTrace.fixedAttribute {text : Source}
    {position limit targetFirst targetAfter : Nat} {word : String}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (positionBound : position ≤ text.length + 1)
    (longWord : 2 ≤ word.toList.length)
    (letters : ∀ letter ∈ word.toList, Named.letter letter.toNat = true)
    (accepted : fixedAfter text (fixedAfter text position "'" false) word true ≠ 0)
    (finishBound : fixedAfter text (fixedAfter text position "'" false) word true ≤ limit) :
    ActualNameFreeTrace text limit targetFirst targetAfter
      (fixedAfter text (fixedAfter text position "'" false) word true) := by
  have tickPositive := Compose.Expressions.model_fixed_input_nonzero text _ word true accepted
  have tickBound := fixedAfter_result_bound text position "'" false (by decide)
  obtain ⟨firstPositive, firstBound, tickFound, tickAfter⟩ := fixedAfter_fields positionBound tickPositive
  change skipAt text position + 1 ≤ text.length + 1 at firstBound
  change fixedAfter text position "'" false = skipAt text position + 1 at tickAfter
  obtain ⟨namePositive, _, _, nameAfter⟩ := fixedAfter_fields tickBound accepted
  obtain ⟨bytes, nameSource⟩ := fixedWord_identifier tickBound (by omega) letters accepted
  have nameBounds := Named.identifier_bounds nameSource
  have longName : 2 ≤ bytes.length := by omega
  have found := tickFound
  simp only [fixedAt, Bool.and_eq_true, decide_eq_true_eq] at found
  have tick := found.1.2 ⟨0, by simp⟩
  simp only [Nat.add_zero] at tick
  have tickByte : Cursor.byteAt text (skipAt text position) = 39 :=
    lowercase_symbol (by decide) tick
  have start := ScalarExpression.skip_bounds text position positionBound
  change position ≤ skipAt text position ∧ skipAt text position ≤ text.length + 1 at start
  have next := ScalarExpression.skip_bounds text (fixedAfter text position "'" false) tickBound
  change fixedAfter text position "'" false ≤ skipAt text (fixedAfter text position "'" false) ∧
    skipAt text (fixedAfter text position "'" false) ≤ text.length + 1 at next
  apply trace.attribute (by omega) rfl (by omega) tickByte
  · simpa only [tickAfter] using nameSource
  · exact longName
  · exact finishBound

end Silver.Predicate
