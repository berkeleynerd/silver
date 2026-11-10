module

public import Silver.ProcedureNameScalarReadings
public import Silver.ComposeCharacterReading
public import Silver.NamedDisjoint

@[expose] public section

namespace Silver.Predicate
open Compose

private theorem lowercase_letter (byte : Nat) :
    Named.letter (lowercase byte) = Named.letter byte := by
  unfold lowercase
  split
  · rename_i upper
    apply Bool.eq_iff_iff.mpr
    simp only [Named.letter, decide_eq_true_eq]
    omega
  · rfl

theorem lowercase_symbol {byte expected : Nat}
    (ordinary : Named.letter expected = false) (same : lowercase byte = expected) :
    byte = expected := by
  unfold lowercase at same
  split at same
  · rename_i upper
    simp only [Named.letter, decide_eq_false_iff_not] at ordinary
    omega
  · exact same

private theorem identifierTail_letters {text : Source} {position count : Nat}
    (bounded : position + count ≤ text.length + 1)
    (letters : ∀ offset, offset < count → Named.letter (Cursor.byteAt text (position + offset)) = true)
    (boundary : position + count > text.length ∨ identifierCharacter (Cursor.byteAt text (position + count)) = false) :
    ∃ bytes, Named.IdentifierTail text position false bytes (position + count) := by
  induction count generalizing position with
  | zero => exact ⟨[], by simpa only [Nat.add_zero] using Named.IdentifierTail.stop boundary⟩
  | succ count ih =>
      have first := letters 0 (by omega)
      simp only [Nat.add_zero] at first
      have notUnderscore : Cursor.byteAt text position ≠ 95 := by
        simp only [Named.letter, decide_eq_true_eq] at first
        omega
      obtain ⟨bytes, rest⟩ := ih (position := position + 1) (by omega)
        (fun offset within => by simpa only [Nat.add_assoc, Nat.add_left_comm, Nat.add_comm] using letters (offset + 1) (by omega))
        (by simpa only [Nat.add_assoc, Nat.add_left_comm, Nat.add_comm] using boundary)
      have nextFlag : (Cursor.byteAt text position == 95) = false := by
        simpa only [beq_eq_false_iff_ne] using notUnderscore
      have rest' : Named.IdentifierTail text (position + 1)
          (Cursor.byteAt text position == 95) bytes (position + 1 + count) := by
        rw [nextFlag]
        exact rest
      refine ⟨Cursor.byteAt text position :: bytes, ?_⟩
      simpa only [Nat.add_assoc, Nat.add_left_comm, Nat.add_comm] using
        Named.IdentifierTail.character (previous := false) (by omega) (Named.letter_identifier _ first)
          (by simp) rest'

theorem fixedAfter_fields {text : Source} {position : Nat} {word : String} {wordFlag : Bool}
    (positionBound : position ≤ text.length + 1)
    (accepted : fixedAfter text position word wordFlag ≠ 0) :
    skipAt text position ≠ 0 ∧
      skipAt text position + word.toList.length ≤ text.length + 1 ∧
      fixedAt text (skipAt text position) word wordFlag = true ∧
      fixedAfter text position word wordFlag = skipAt text position + word.toList.length := by
  have positive : position ≠ 0 := by
    intro zero
    simp only [fixedAfter, zero, ↓reduceIte] at accepted
    contradiction
  have start := Cursor.triviaPosition_bounds text position (by omega) positionBound
  simp only [fixedAfter, skipAt, positive, ↓reduceIte] at accepted ⊢
  split at accepted
  · rename_i matched
    simp only [matched, ↓reduceIte]
    have size := matched
    simp only [fixedAt, Bool.and_eq_true, decide_eq_true_eq, List.length_map] at size
    exact ⟨by omega, by omega, trivial, trivial⟩
  · contradiction

theorem fixedWord_identifier {text : Source} {position : Nat} {word : String}
    (positionBound : position ≤ text.length + 1)
    (nonempty : 0 < word.toList.length)
    (letters : ∀ letter ∈ word.toList, Named.letter letter.toNat = true)
    (accepted : fixedAfter text position word true ≠ 0) :
    ∃ bytes, Named.IdentifierAt text (skipAt text position) bytes (fixedAfter text position word true) := by
  obtain ⟨positive, bounded, matched, after⟩ := fixedAfter_fields positionBound accepted
  have matched' := matched
  simp only [fixedAt, Bool.and_eq_true, decide_eq_true_eq, Bool.not_true, Bool.false_or,
    Bool.or_eq_true, Bool.not_eq_true', List.length_map] at matched'
  have letterAt : ∀ offset, offset < word.toList.length →
      Named.letter (Cursor.byteAt text (skipAt text position + offset)) = true := by
    intro offset within
    have same := matched'.1.2 ⟨offset, by simpa only [List.length_map] using within⟩
    rw [← lowercase_letter, same]
    simp only [List.getElem_map]
    exact letters _ (List.getElem_mem within)
  have first := letterAt 0 nonempty
  simp only [Nat.add_zero] at first
  obtain ⟨bytes, rest⟩ := identifierTail_letters (text := text)
    (position := skipAt text position + 1) (count := word.toList.length - 1) (by omega)
    (fun offset within => by simpa only [Nat.add_assoc, Nat.add_left_comm, Nat.add_comm] using letterAt (offset + 1) (by omega))
    (by simpa only [show skipAt text position + 1 + (word.toList.length - 1) =
      skipAt text position + word.toList.length by omega] using matched'.2)
  refine ⟨Cursor.byteAt text (skipAt text position) :: bytes, ?_⟩
  rw [after]
  have tail : Named.IdentifierTail text (skipAt text position + 1) false bytes
      (skipAt text position + word.toList.length) := by
    rw [show skipAt text position + 1 + (word.toList.length - 1) =
      skipAt text position + word.toList.length by omega] at rest
    exact rest
  exact .identifier (by omega) first tail

theorem ActualNameFreeTrace.fixedWord {text : Source}
    {position limit targetFirst targetAfter : Nat} {word : String}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (positionBound : position ≤ text.length + 1)
    (nonempty : 0 < word.toList.length)
    (letters : ∀ letter ∈ word.toList, Named.letter letter.toNat = true)
    (accepted : fixedAfter text position word true ≠ 0)
    (finishBound : fixedAfter text position word true ≤ limit) :
    ActualNameFreeTrace text limit targetFirst targetAfter (fixedAfter text position word true) := by
  obtain ⟨bytes, identifier⟩ := fixedWord_identifier positionBound nonempty letters accepted
  obtain ⟨positive, _, _, after⟩ := fixedAfter_fields positionBound accepted
  have skip := ScalarExpression.skip_bounds text position positionBound
  change position ≤ skipAt text position ∧ skipAt text position ≤ text.length + 1 at skip
  exact (trace.identifier (by omega) rfl positive identifier finishBound).2

theorem fixedSymbol_source {text : Source} {position : Nat} {byte : Char}
    (positionBound : position ≤ text.length + 1)
    (ordinary : OrdinarySymbol byte.toNat)
    (accepted : fixedAfter text position (String.singleton byte) false ≠ 0) :
    ScalarExpression.SymbolAt text position byte.toNat
      (fixedAfter text position (String.singleton byte) false) := by
  obtain ⟨positive, bounded, matched, after⟩ := fixedAfter_fields positionBound accepted
  simp only [String.toList_singleton, List.length_singleton] at bounded after
  have selected := matched
  simp only [fixedAt, Bool.and_eq_true, decide_eq_true_eq] at selected
  have first := selected.1.2 ⟨0, by simp⟩
  simp only [Nat.add_zero, String.toList_singleton, List.map_cons, List.map_nil, List.getElem_cons_zero] at first
  exact ⟨positive, by change skipAt text position ≤ text.length; omega, lowercase_symbol ordinary.1 first, after⟩

theorem ActualNameFreeTrace.fixedSymbol {text : Source}
    {position limit targetFirst targetAfter : Nat} {byte : Char}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (positionBound : position ≤ text.length + 1) (ordinary : OrdinarySymbol byte.toNat)
    (accepted : fixedAfter text position (String.singleton byte) false ≠ 0)
    (finishBound : fixedAfter text position (String.singleton byte) false ≤ limit) :
    ActualNameFreeTrace text limit targetFirst targetAfter (fixedAfter text position (String.singleton byte) false) :=
  trace.scalarSymbol (fixedSymbol_source positionBound ordinary accepted) ordinary positionBound finishBound

end Silver.Predicate
