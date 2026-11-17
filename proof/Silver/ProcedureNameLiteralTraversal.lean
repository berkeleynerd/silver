module

public import Silver.ProcedureNameReadings
public import Silver.ComposeCharacterReading

@[expose] public section

namespace Silver.Predicate
open Compose

theorem actualNameStep_character {text : Source}
    {position first byte finish limit targetFirst targetAfter : Nat}
    (skipped : skipAt text position = first) (positive : position ≠ 0)
    (before : position < limit) (source : CharacterLiteralAt text first byte finish)
    (finishBound : finish ≤ limit) :
    actualNameStep text position limit targetFirst targetAfter = ⟨finish, true⟩ := by
  have same := source.following
  simp only [actualNameStep, positive, Nat.not_le.mpr before, or_self, ↓reduceIte, skipped,
    show ¬ first ≥ limit by omega, characterLiteral_complete source,
    show finish ≠ 0 by omega, ne_eq, not_false_eq_true, finishBound, and_self]

theorem ActualNameFreeTrace.character {text : Source}
    {position first byte finish limit targetFirst targetAfter : Nat}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (before : position < limit) (skipped : skipAt text position = first)
    (source : CharacterLiteralAt text first byte finish) (finishBound : finish ≤ limit) :
    ActualNameFreeTrace text limit targetFirst targetAfter finish := by
  cases trace with
  | done => omega
  | step positive _ _ _ rest =>
      have step := actualNameStep_character (targetFirst := targetFirst) (targetAfter := targetAfter)
        skipped positive before source finishBound
      simpa only [step] using rest

theorem actualNameStep_quoted {text bytes : Source}
    {position first finish limit targetFirst targetAfter : Nat}
    (skipped : skipAt text position = first) (positive : position ≠ 0)
    (before : position < limit) (firstPositive : first ≠ 0)
    (quote : Cursor.byteAt text first = 34)
    (source : Output.LiteralAt text (first + 1) bytes finish) (finishBound : finish ≤ limit) :
    actualNameStep text position limit targetFirst targetAfter = ⟨finish, true⟩ := by
  have bounds := Output.literalAt_bounds source
  have noCharacter : characterLiteralAfter text first = 0 := by
    simp [characterLiteralAfter, quote]
  have literal : (literalAt text first).after = finish := by
    simp only [literalAt, firstPositive, ne_eq, not_false_eq_true,
      show first ≤ text.length by omega, quote, Output.literalAt_complete source,
      show finish ≠ 0 by omega, and_self, ↓reduceIte]
  simp only [actualNameStep, positive, Nat.not_le.mpr before, or_self, ↓reduceIte, skipped,
    show ¬ first ≥ limit by omega, noCharacter, ne_eq, not_true_eq_false, false_and,
    quote, literal, show finish > first by omega, finishBound, and_self]

theorem ActualNameFreeTrace.quoted {text bytes : Source}
    {position first finish limit targetFirst targetAfter : Nat}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (before : position < limit) (skipped : skipAt text position = first)
    (firstPositive : first ≠ 0) (quote : Cursor.byteAt text first = 34)
    (source : Output.LiteralAt text (first + 1) bytes finish) (finishBound : finish ≤ limit) :
    ActualNameFreeTrace text limit targetFirst targetAfter finish := by
  cases trace with
  | done => omega
  | step positive _ _ _ rest =>
      have step := actualNameStep_quoted (targetFirst := targetFirst) (targetAfter := targetAfter)
        skipped positive before firstPositive quote source finishBound
      simpa only [step] using rest

end Silver.Predicate
