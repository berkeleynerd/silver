module

public import Silver.ProcedureNameTerminals

@[expose] public section

namespace Silver.Predicate
open Compose

/-- A static token spelling obeys Ada's identifier continuation rule. -/
def IdentifierTailPattern : Bool → Source → Bool
  | previous, [] => !previous
  | previous, byte :: rest => identifierCharacter byte &&
      !decide (byte = 95 ∧ previous = true) && IdentifierTailPattern (byte == 95) rest

def IdentifierPattern : Source → Bool
  | [] => false
  | byte :: rest => Named.letter byte && IdentifierTailPattern false rest

private theorem lowercase_identifierCharacter (byte : Nat) :
    identifierCharacter (lowercase byte) = identifierCharacter byte := by
  unfold lowercase
  split
  · rename_i upper
    apply Bool.eq_iff_iff.mpr
    simp only [identifierCharacter, decide_eq_true_eq]
    omega
  · rfl

private theorem lowercase_underscore (byte : Nat) :
    (lowercase byte == 95) = (byte == 95) := by
  unfold lowercase
  split
  · rename_i upper
    apply Bool.eq_iff_iff.mpr
    simp only [beq_iff_eq]
    omega
  · rfl

private theorem identifierTail_pattern {text expected : Source} {position : Nat} {previous : Bool}
    (pattern : IdentifierTailPattern previous expected = true)
    (bounded : position + expected.length ≤ text.length + 1)
    (matched : ∀ index : Fin expected.length,
      lowercase (Cursor.byteAt text (position + index.val)) = expected[index.val])
    (boundary : position + expected.length > text.length ∨
      identifierCharacter (Cursor.byteAt text (position + expected.length)) = false) :
    ∃ bytes, Named.IdentifierTail text position previous bytes (position + expected.length) := by
  induction expected generalizing position previous with
  | nil =>
      have previousFalse : previous = false := by
        cases previous <;> simp_all only [IdentifierTailPattern, Bool.not_true, Bool.false_eq_true]
      subst previous
      exact ⟨[], by simpa only [List.length_nil, Nat.add_zero] using Named.IdentifierTail.stop boundary⟩
  | cons byte expected ih =>
      have checks := Bool.and_eq_true_iff.mp pattern
      have firstCheck := Bool.and_eq_true_iff.mp checks.1
      have first := matched ⟨0, by simp⟩
      simp only [Nat.add_zero, List.getElem_cons_zero] at first
      have character : identifierCharacter (Cursor.byteAt text position) = true := by
        rw [← lowercase_identifierCharacter, first]
        exact firstCheck.1
      have underscore : (Cursor.byteAt text position == 95) = (byte == 95) := by
        rw [← lowercase_underscore, first]
      have noDouble : ¬(Cursor.byteAt text position = 95 ∧ previous = true) := by
        intro both
        have expected95 : byte = 95 := by simpa [both.1, lowercase] using first.symm
        have refused := firstCheck.2
        simp [expected95, both.2] at refused
      have matchedTail : ∀ index : Fin expected.length,
          lowercase (Cursor.byteAt text (position + 1 + index.val)) = expected[index.val] := by
        intro index
        have next := matched ⟨index.val + 1, by simp⟩
        simpa only [List.getElem_cons_succ, Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using next
      obtain ⟨bytes, rest⟩ := ih checks.2 (position := position + 1) (by simp only [List.length_cons] at bounded; omega)
        matchedTail (by simpa only [List.length_cons, Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using boundary)
      have rest' : Named.IdentifierTail text (position + 1)
          (Cursor.byteAt text position == 95) bytes (position + 1 + expected.length) := by
        rw [underscore]
        exact rest
      refine ⟨Cursor.byteAt text position :: bytes, ?_⟩
      simpa only [List.length_cons, Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using
        Named.IdentifierTail.character (previous := previous) (by simp only [List.length_cons] at bounded; omega)
          character noDouble rest'

/-- Fixed qualified-library identifiers may contain underscores; the checked
pattern retains that syntax without treating a token fragment as a whole name. -/
theorem fixedIdentifier_source {text : Source} {position : Nat} {word : String}
    (positionBound : position ≤ text.length + 1)
    (pattern : IdentifierPattern (word.toList.map Char.toNat) = true)
    (accepted : fixedAfter text position word true ≠ 0) :
    ∃ bytes, Named.IdentifierAt text (skipAt text position) bytes (fixedAfter text position word true) := by
  obtain ⟨positive, bounded, matched, after⟩ := fixedAfter_fields positionBound accepted
  have selected := matched
  simp only [fixedAt, Bool.and_eq_true, decide_eq_true_eq, Bool.not_true, Bool.false_or,
    Bool.or_eq_true, Bool.not_eq_true', List.length_map] at selected
  generalize expectedEq : word.toList.map Char.toNat = expected at pattern
  cases expected with
  | nil => simp [IdentifierPattern] at pattern
  | cons byte expected =>
      have checks := Bool.and_eq_true_iff.mp pattern
      have count : word.toList.length = expected.length + 1 := by
        have same := congrArg List.length expectedEq
        simpa only [List.length_map, List.length_cons] using same
      have first := selected.1.2 ⟨0, by simp only [List.length_map]; rw [count]; omega⟩
      simp only [Nat.add_zero, expectedEq, List.getElem_cons_zero] at first
      have letter : Named.letter (Cursor.byteAt text (skipAt text position)) = true := by
        have folded := checks.1
        rw [← first] at folded
        unfold lowercase at folded
        split at folded
        · rename_i upper
          simp only [Named.letter, decide_eq_true_eq]
          omega
        · exact folded
      have restMatched : ∀ index : Fin expected.length,
          lowercase (Cursor.byteAt text (skipAt text position + 1 + index.val)) = expected[index.val] := by
        intro index
        have next := selected.1.2 ⟨index.val + 1, by simp only [List.length_map]; rw [count]; omega⟩
        simpa only [expectedEq, List.getElem_cons_succ, Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using next
      obtain ⟨bytes, tail⟩ := identifierTail_pattern checks.2
        (position := skipAt text position + 1) (by omega) restMatched
        (by simpa only [count, Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using selected.2)
      refine ⟨Cursor.byteAt text (skipAt text position) :: bytes, ?_⟩
      rw [after, count]
      exact .identifier (by omega) letter (by simpa only [Nat.add_assoc, Nat.add_comm, Nat.add_left_comm] using tail)

theorem ActualNameFreeTrace.fixedIdentifier {text : Source}
    {position limit targetFirst targetAfter : Nat} {word : String}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (positionBound : position ≤ text.length + 1)
    (pattern : IdentifierPattern (word.toList.map Char.toNat) = true)
    (accepted : fixedAfter text position word true ≠ 0)
    (finishBound : fixedAfter text position word true ≤ limit) :
    ActualNameFreeTrace text limit targetFirst targetAfter (fixedAfter text position word true) := by
  obtain ⟨bytes, source⟩ := fixedIdentifier_source positionBound pattern accepted
  have start := ScalarExpression.skip_bounds text position positionBound
  change position ≤ skipAt text position ∧ skipAt text position ≤ text.length + 1 at start
  obtain ⟨positive, _, _, _⟩ := fixedAfter_fields positionBound accepted
  have bounds := Named.identifier_bounds source
  exact (trace.identifier (by omega) rfl positive source finishBound).2

end Silver.Predicate
