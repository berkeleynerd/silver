module

public import Silver.ComposeBounds
public import Silver.NamedDisjoint

@[expose] public section

/-! A name comparison and a whole-word token comparison agree on the complete
identifier read by the declaration scanner. The identifier premise supplies both
the absence of leading trivia and the trailing word boundary. -/

namespace Silver.Compose.Expressions
open Named

theorem nameIs_fixedAfter_of_identifier (text : Source) (first after : Nat)
    (bytes : Source) (word : String) (positive : 1 ≤ first)
    (parsed : IdentifierAt text first bytes after) :
    Named.nameIs text first after (word.toList.map Char.toNat) =
      decide (fixedAfter text first word true = after) := by
  have bounds := identifier_bounds parsed
  have start : first ≤ text.length ∧ letter (Cursor.byteAt text first) = true := by
    cases parsed with
    | identifier bound letter _ => exact ⟨bound, letter⟩
  have notSpace : whitespace (Cursor.byteAt text first) = false := by
    have letters := start.2
    simp only [letter, decide_eq_true_eq] at letters
    simp only [whitespace, Bool.or_eq_false_iff, beq_eq_false_iff_ne]
    omega
  have notComment : Cursor.byteAt text first ≠ 45 := by
    have letters := start.2
    simp only [letter, decide_eq_true_eq] at letters
    omega
  have trivia : Cursor.triviaPosition text first = first := by
    rw [Cursor.triviaPosition_equation text first positive (by omega)]
    simp [show ¬first > text.length by omega, notSpace, notComment]
  have nonzero : first ≠ 0 := by omega
  apply Bool.eq_iff_iff.mpr
  simp only [decide_eq_true_eq]
  constructor
  · intro matched
    simp only [Named.nameIs, Bool.and_eq_true, decide_eq_true_eq] at matched
    have length : first + word.toList.length = after := by
      have size := matched.1
      simp only [List.length_map] at size
      omega
    have enough : (word.toList.map Char.toNat).length ≤ text.length + 1 - first := by
      simp only [List.length_map]
      omega
    have boundary : first + (word.toList.map Char.toNat).length > text.length ∨
        identifierCharacter (Cursor.byteAt text (first + (word.toList.map Char.toNat).length)) = false := by
      simpa only [List.length_map, length] using identifier_maximal parsed
    have token : fixedAt text first word true = true := by
      simp only [fixedAt, Bool.and_eq_true, decide_eq_true_eq, Bool.not_true,
        Bool.false_or, Bool.or_eq_true, Bool.not_eq_true']
      exact ⟨⟨enough, matched.2⟩, boundary⟩
    simp [fixedAfter, nonzero, trivia, token, length]
  · intro matched
    have token : fixedAt text first word true = true := by
      by_cases present : fixedAt text first word true = true
      · exact present
      · simp [fixedAfter, nonzero, trivia, present] at matched
        omega
    have length : after = first + word.toList.length := by
      simpa [fixedAfter, nonzero, trivia, token] using matched.symm
    simp only [fixedAt, Bool.and_eq_true, decide_eq_true_eq] at token
    simp only [Named.nameIs, Bool.and_eq_true, decide_eq_true_eq, List.length_map]
    exact ⟨by omega, token.1.2⟩

theorem declaration_nameIs_integer (text : Source) (state : ParserState)
    (arguments : Bool) (first after : Nat)
    (_firstEq : first = skipAt text state.position)
    (afterEq : after = nameAfter text first)
    (allowed : newNameAllowed text state first after arguments = true) :
    Named.nameIs text first after ("integer".toList.map Char.toNat) =
      decide (fixedAfter text first "integer" true = after) := by
  have domain : first ≠ 0 ∧ after > first := by
    have span := newNameAllowed_span text state first after arguments allowed
    exact ⟨Nat.ne_of_gt span.1, span.2⟩
  have identifier : identifierEnd text first = after := by
    simpa only [nameAfter, domain.1, ↓reduceIte] using afterEq.symm
  obtain ⟨bytes, parsed⟩ := identifierEnd_sound text first (by rw [identifier]; omega)
  rw [identifier] at parsed
  exact nameIs_fixedAfter_of_identifier text first after bytes "integer" (by omega) parsed

end Silver.Compose.Expressions
