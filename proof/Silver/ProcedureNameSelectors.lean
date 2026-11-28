module

public import Silver.ProcedureNameIdentifierWords
public import Silver.ComposeBounds
public import Silver.ScalarProcedureSyntax

@[expose] public section

/-! Only the validity selector is skipped. Its preceding dot is distinguished
from both bytes of a contiguous range delimiter; ordinary identifiers keep the
same scanner equation over arbitrary metadata and source prefixes. -/
namespace Silver.Predicate
open Compose

/-- The exact dot branch, including failed, truncated and out-of-range selector
lookahead. No successful expression or name-resolution premise is required. -/
theorem actualNameStep_dot {text : Source} {position first limit targetFirst targetAfter : Nat}
    (skipped : skipAt text position = first) (positive : position ≠ 0)
    (before : position < limit) (firstBefore : first < limit)
    (dot : Cursor.byteAt text first = 46) :
    actualNameStep text position limit targetFirst targetAfter =
      let selectorAfter := if first > 1 ∧ Cursor.byteAt text (first - 1) ≠ 46
        then fixedAfter text (fixedAfter text first "." false) "input_is_valid" true else 0
      if selectorAfter > first ∧ selectorAfter ≤ limit then ⟨selectorAfter, true⟩
      else ⟨first + 1, true⟩ := by
  have noNumber : (ScalarLiteral.read text first).after = 0 := by
    simp [ScalarLiteral.read, ScalarLiteral.mantissa, ScalarLiteral.numeral,
      ScalarLiteral.digitsTail, ScalarLiteral.digitValue, dot, ScalarLiteral.invalid,
      Guarded.invalidDecimal]
  have noName : nameAfter text first = 0 := by
    simp [nameAfter, Named.identifierEnd, Named.letter, dot]
  simp [actualNameStep, skipped, positive, Nat.not_le.mpr before,
    Nat.not_le.mpr firstBefore, dot, characterLiteralAfter, noNumber, noName]

theorem actualNameStep_plainDot {text : Source} {position first limit targetFirst targetAfter : Nat}
    (skipped : skipAt text position = first) (positive : position ≠ 0)
    (before : position < limit) (firstBefore : first < limit)
    (dot : Cursor.byteAt text first = 46)
    (plain : first ≤ 1 ∨ Cursor.byteAt text (first - 1) = 46 ∨
      fixedAfter text (fixedAfter text first "." false) "input_is_valid" true = 0) :
    actualNameStep text position limit targetFirst targetAfter = ⟨first + 1, true⟩ := by
  rw [actualNameStep_dot skipped positive before firstBefore dot]
  rcases plain with small | previous | missing
  · simp [show ¬first > 1 by omega]
  · simp [previous]
  · simp [missing]

theorem ActualNameFreeTrace.plainDot {text : Source} {position first limit targetFirst targetAfter : Nat}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (before : position < limit) (skipped : skipAt text position = first)
    (firstBefore : first < limit) (dot : Cursor.byteAt text first = 46)
    (plain : first ≤ 1 ∨ Cursor.byteAt text (first - 1) = 46 ∨
      fixedAfter text (fixedAfter text first "." false) "input_is_valid" true = 0) :
    ActualNameFreeTrace text limit targetFirst targetAfter (first + 1) := by
  cases trace with
  | done => omega
  | step positive _ _ _ rest =>
      simpa only [actualNameStep_plainDot skipped positive before firstBefore dot plain] using rest

/-- A dot followed by the exact word token consumes the selector without a
spelling comparison. The previous-byte guard excludes a range's second dot. -/
theorem actualNameStep_validitySelector {text : Source} {position first limit targetFirst targetAfter : Nat}
    (skipped : skipAt text position = first) (positive : position ≠ 0)
    (before : position < limit) (firstBefore : first < limit)
    (dot : Cursor.byteAt text first = 46) (notFirst : first > 1)
    (previous : Cursor.byteAt text (first - 1) ≠ 46)
    (advance : first < fixedAfter text (fixedAfter text first "." false) "input_is_valid" true)
    (bounded : fixedAfter text (fixedAfter text first "." false) "input_is_valid" true ≤ limit) :
    actualNameStep text position limit targetFirst targetAfter =
      ⟨fixedAfter text (fixedAfter text first "." false) "input_is_valid" true, true⟩ := by
  rw [actualNameStep_dot skipped positive before firstBefore dot]
  simp [notFirst, previous, advance, bounded]

private theorem commentPosition_lineEnd {text : Source} {position : Nat}
    (positive : 1 ≤ position) (bounded : position ≤ text.length + 1)
    (within : Cursor.commentPosition text position ≤ text.length) :
    lineEnd (Cursor.byteAt text (Cursor.commentPosition text position)) = true := by
  rw [Cursor.commentPosition_equation text position positive bounded] at within ⊢
  by_cases stopped : position > text.length ∨ lineEnd (Cursor.byteAt text position) = true
  · simp only [stopped, ↓reduceIte] at within ⊢
    rcases stopped with atEnd | line
    · omega
    · exact line
  · simp only [stopped, ↓reduceIte] at within ⊢
    exact commentPosition_lineEnd (by omega) (by omega) within
termination_by text.length + 1 - position

/-- If trivia advances to a byte in the source, the byte immediately before
that byte is whitespace. In particular, comments cannot manufacture the range
exclusion at the dot of a qualified operation. -/
private theorem triviaPosition_previous {text : Source} {position : Nat}
    (positive : 1 ≤ position) (bounded : position ≤ text.length + 1)
    (within : Cursor.triviaPosition text position ≤ text.length)
    (advance : position < Cursor.triviaPosition text position) :
    whitespace (Cursor.byteAt text (Cursor.triviaPosition text position - 1)) = true := by
  rw [Cursor.triviaPosition_equation text position positive bounded] at within advance ⊢
  by_cases atEnd : position > text.length
  · simp only [atEnd, ↓reduceIte] at advance
    omega
  · simp only [atEnd, ↓reduceIte] at within advance ⊢
    by_cases space : whitespace (Cursor.byteAt text position) = true
    · simp [space] at within advance ⊢
      have next := Cursor.triviaPosition_bounds text (position + 1) (by omega) (by omega)
      by_cases same : Cursor.triviaPosition text (position + 1) = position + 1
      · simpa only [same, Nat.add_sub_cancel] using space
      · exact triviaPosition_previous (by omega) (by omega) within (by omega)
    · simp [space] at within advance ⊢
      by_cases comment : Cursor.byteAt text position = 45 ∧ position < text.length ∧
          Cursor.byteAt text (position + 1) = 45
      · simp [comment] at within advance ⊢
        have commentBound := Cursor.commentPosition_bounds text (position + 2) (by omega) (by omega)
        have next := Cursor.triviaPosition_bounds text (Cursor.commentPosition text (position + 2))
          (by omega) commentBound.2
        have line := commentPosition_lineEnd (text := text) (position := position + 2)
          (by omega) (by omega) (by omega)
        have space : whitespace (Cursor.byteAt text (Cursor.commentPosition text (position + 2))) = true := by
          simp only [lineEnd, Bool.or_eq_true, beq_iff_eq] at line
          rcases line with line | line <;> simp [whitespace, line]
        have strict : Cursor.commentPosition text (position + 2) <
            Cursor.triviaPosition text (Cursor.commentPosition text (position + 2)) := by
          rw [Cursor.triviaPosition_equation text _ (by omega) commentBound.2]
          have further := Cursor.triviaPosition_bounds text
            (Cursor.commentPosition text (position + 2) + 1) (by omega) (by omega)
          simp only [show ¬Cursor.commentPosition text (position + 2) > text.length by omega,
            space, ↓reduceIte]
          omega
        exact triviaPosition_previous (by omega) commentBound.2 within strict
      · simp [comment] at advance
termination_by text.length + 1 - position

/-- A known non-dot preceding a cursor stays non-dot across arbitrary valid
trivia, including comments, when another source byte remains. -/
theorem skipAt_previous_not_dot {text : Source} {position : Nat}
    (positive : 1 ≤ position) (bounded : position ≤ text.length + 1)
    (within : skipAt text position ≤ text.length)
    (previous : Cursor.byteAt text (position - 1) ≠ 46) :
    Cursor.byteAt text (skipAt text position - 1) ≠ 46 := by
  have start := Cursor.triviaPosition_bounds text position positive bounded
  have nonzero : position ≠ 0 := by omega
  simp only [skipAt, nonzero, ↓reduceIte] at within ⊢
  by_cases same : Cursor.triviaPosition text position = position
  · simpa only [same] using previous
  · have space := triviaPosition_previous positive bounded within (by omega)
    intro dot
    simp [dot, whitespace] at space

/-- Exact one-byte dot token at a fixed lexical cursor. -/
theorem fixedDot_after {text : Source} {position : Nat}
    (positive : position ≠ 0) (within : position ≤ text.length)
    (fixed : skipAt text position = position) (dot : Cursor.byteAt text position = 46) :
    fixedAfter text position "." false = position + 1 := by
  have trivia : Cursor.triviaPosition text position = position := by
    simpa only [skipAt, positive, ↓reduceIte] using fixed
  simp [fixedAfter, positive, trivia, fixedAt, dot, lowercase,
    show 1 ≤ text.length + 1 - position by omega]

/-- The first range dot cannot consume a selector, because the second dot is
not the initial byte of the required word token. -/
theorem fixedValidity_dot_rejected {text : Source} {position : Nat}
    (bounded : position ≤ text.length + 1) (fixed : skipAt text position = position)
    (dot : Cursor.byteAt text position = 46) :
    fixedAfter text position "input_is_valid" true = 0 := by
  by_cases missing : fixedAfter text position "input_is_valid" true = 0
  · exact missing
  have accepted := missing
  exfalso
  obtain ⟨_, _, matched, _⟩ := fixedAfter_fields bounded accepted
  simp only [fixedAt, Bool.and_eq_true, decide_eq_true_eq] at matched
  have first := matched.1.2 ⟨0, by decide⟩
  simp [fixed, dot, lowercase] at first

/-- The package token ends with a letter, so its following trivia cannot
satisfy the native range exclusion. This holds for arbitrary ASCII case. -/
theorem validityPrefix_previous {text : Source} {position : Nat}
    (bounded : position ≤ text.length + 1)
    (accepted : fixedAfter text position "silver_arguments" true ≠ 0) :
    1 < fixedAfter text position "silver_arguments" true ∧
      Cursor.byteAt text (fixedAfter text position "silver_arguments" true - 1) ≠ 46 := by
  obtain ⟨positive, _, matched, after⟩ := fixedAfter_fields bounded accepted
  have finalByte := matched
  simp only [fixedAt, Bool.and_eq_true, decide_eq_true_eq] at finalByte
  have last := finalByte.1.2 ⟨15, by decide⟩
  change lowercase (Cursor.byteAt text (skipAt text position + 15)) = 115 at last
  change fixedAfter text position "silver_arguments" true = skipAt text position + 16 at after
  refine ⟨by omega, ?_⟩
  rw [after, show skipAt text position + 16 - 1 = skipAt text position + 15 by omega]
  intro dot
  simp [dot, lowercase] at last

/-- The complete selector branch at a cursor after an earlier non-dot byte.
The fixed token parser supplies the exact word boundary and trivia behavior. -/
theorem validitySelector_step {text : Source} {position limit targetFirst targetAfter : Nat}
    (bounded : position ≤ text.length + 1) (positive : 1 < position)
    (previous : Cursor.byteAt text (position - 1) ≠ 46)
    (accepted : fixedAfter text (fixedAfter text position "." false) "input_is_valid" true ≠ 0)
    (finishBound : fixedAfter text (fixedAfter text position "." false) "input_is_valid" true ≤ limit) :
    actualNameStep text position limit targetFirst targetAfter =
      ⟨fixedAfter text (fixedAfter text position "." false) "input_is_valid" true, true⟩ := by
  have dotPositive := Compose.Expressions.model_fixed_input_nonzero text _ "input_is_valid" true accepted
  have dotBound := fixedAfter_result_bound text position "." false (by decide)
  obtain ⟨_, within, matched, dotAfter⟩ := fixedAfter_fields bounded dotPositive
  have firstByte := matched
  simp only [fixedAt, Bool.and_eq_true, decide_eq_true_eq] at firstByte
  have first := firstByte.1.2 ⟨0, by decide⟩
  have dot : Cursor.byteAt text (skipAt text position) = 46 :=
    lowercase_symbol (by decide) (by simpa using first)
  change skipAt text position + 1 ≤ text.length + 1 at within
  change fixedAfter text position "." false = skipAt text position + 1 at dotAfter
  have start := ScalarExpression.skip_bounds text position bounded
  change position ≤ skipAt text position ∧ skipAt text position ≤ text.length + 1 at start
  have advance := Compose.Expressions.model_fixed_advances text _ "input_is_valid" true dotBound (by decide) accepted
  have noRange := skipAt_previous_not_dot (by omega) bounded (by omega) previous
  have same := fixedAfter_skipped bounded "." false
  have step := actualNameStep_validitySelector (targetFirst := targetFirst) (targetAfter := targetAfter)
    (position := position) (limit := limit) rfl (by omega) (by omega) (by omega) dot (by omega) noRange
    (by rw [same]; omega) (by rw [same]; exact finishBound)
  simpa only [same] using step

theorem ActualNameFreeTrace.validitySelector {text : Source} {position limit targetFirst targetAfter : Nat}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (bounded : position ≤ text.length + 1) (positive : 1 < position)
    (previous : Cursor.byteAt text (position - 1) ≠ 46)
    (accepted : fixedAfter text (fixedAfter text position "." false) "input_is_valid" true ≠ 0)
    (finishBound : fixedAfter text (fixedAfter text position "." false) "input_is_valid" true ≤ limit) :
    ActualNameFreeTrace text limit targetFirst targetAfter
      (fixedAfter text (fixedAfter text position "." false) "input_is_valid" true) := by
  have step := validitySelector_step (targetFirst := targetFirst) (targetAfter := targetAfter)
    bounded positive previous accepted finishBound
  have dotPositive := Compose.Expressions.model_fixed_input_nonzero text _ "input_is_valid" true accepted
  have dotAdvance := Compose.Expressions.model_fixed_advances text position "." false bounded (by decide) dotPositive
  have dotBound := fixedAfter_result_bound text position "." false (by decide)
  have callAdvance := Compose.Expressions.model_fixed_advances text _ "input_is_valid" true dotBound (by decide) accepted
  cases trace with
  | done => omega
  | step _ _ _ _ rest => simpa only [step] using rest

/-- Constructive admission for every well-tokenized qualified query whose
writable target has the selector's length, hence including its exact spelling.
There is no already-successful lexical trace hypothesis. -/
theorem actualNameFree_qualifiedValidity {text : Source} {position targetFirst targetAfter : Nat}
    (bounded : position ≤ text.length + 1)
    (accepted : fixedAfter text
      (fixedAfter text (fixedAfter text position "silver_arguments" true) "." false)
      "input_is_valid" true ≠ 0)
    (targetLength : targetAfter - targetFirst = 14) :
    actualNameFree text position
      (fixedAfter text (fixedAfter text (fixedAfter text position "silver_arguments" true) "." false)
        "input_is_valid" true) targetFirst targetAfter = true := by
  let packageEnd := fixedAfter text position "silver_arguments" true
  let finish := fixedAfter text (fixedAfter text packageEnd "." false) "input_is_valid" true
  have dotPositive := Compose.Expressions.model_fixed_input_nonzero text _ "input_is_valid" true accepted
  have prefixPositive := Compose.Expressions.model_fixed_input_nonzero text _ "." false dotPositive
  have prefixBound := fixedAfter_result_bound text position "silver_arguments" true (by decide)
  have dotBound := fixedAfter_result_bound text packageEnd "." false (by decide)
  have finishBound := fixedAfter_result_bound text (fixedAfter text packageEnd "." false) "input_is_valid" true (by decide)
  have dotAdvance := Compose.Expressions.model_fixed_advances text packageEnd "." false prefixBound (by decide) dotPositive
  have callAdvance := Compose.Expressions.model_fixed_advances text _ "input_is_valid" true dotBound (by decide) accepted
  have prefixFacts := validityPrefix_previous bounded prefixPositive
  have selectorStep := validitySelector_step (targetFirst := targetFirst) (targetAfter := targetAfter)
    (limit := finish) prefixBound prefixFacts.1 prefixFacts.2 accepted (Nat.le_refl _)
  change actualNameStep text packageEnd finish targetFirst targetAfter = ⟨finish, true⟩ at selectorStep
  have afterPrefix : ActualNameFreeTrace text finish targetFirst targetAfter packageEnd :=
    .step (by dsimp only [packageEnd] at *; omega) (by dsimp only [finish] at *; omega)
      (by simpa only [selectorStep] using accepted) (by simp only [selectorStep])
      (by simpa only [selectorStep] using (ActualNameFreeTrace.done accepted :
        ActualNameFreeTrace text finish targetFirst targetAfter finish))
  obtain ⟨firstPositive, _, _, prefixAfter⟩ := fixedAfter_fields bounded prefixPositive
  obtain ⟨bytes, identifier⟩ := fixedIdentifier_source bounded (by decide) prefixPositive
  have first := ScalarExpression.skip_bounds text position bounded
  change position ≤ skipAt text position ∧ skipAt text position ≤ text.length + 1 at first
  have positionPositive := Compose.Expressions.model_fixed_input_nonzero text position "silver_arguments" true prefixPositive
  have prefixAdvance := (Named.identifier_bounds identifier).2.2.1
  have firstStep := actualNameStep_identifier (targetFirst := targetFirst) (targetAfter := targetAfter)
    (after := finish) rfl positionPositive firstPositive (by dsimp only [packageEnd, finish] at *; omega)
    identifier (by dsimp only [packageEnd, finish] at *; omega)
  change actualNameStep text position finish targetFirst targetAfter =
    ⟨packageEnd, !Named.equalName text (skipAt text position) packageEnd targetFirst targetAfter⟩ at firstStep
  have different : Named.equalName text (skipAt text position) packageEnd targetFirst targetAfter = false := by
    have length : packageEnd - skipAt text position = 16 := by
      change packageEnd = skipAt text position + 16 at prefixAfter
      omega
    simp [Named.equalName, length, targetLength]
  have whole : ActualNameFreeTrace text finish targetFirst targetAfter position :=
    .step positionPositive (by dsimp only [packageEnd, finish] at *; omega)
      (by simpa only [firstStep] using prefixPositive) (by simp only [firstStep, different, Bool.not_false])
      (by simpa only [firstStep] using afterPrefix)
  exact whole.complete finishBound bounded

/-- The original collision: a target spelled Input_Is_Valid remains separate
from the qualified library query, for every source, case, trivia and target span. -/
theorem qualifiedValidity_same_spelling {text : Source} {position targetFirst targetAfter : Nat}
    (bounded : position ≤ text.length + 1)
    (accepted : fixedAfter text
      (fixedAfter text (fixedAfter text position "silver_arguments" true) "." false)
      "input_is_valid" true ≠ 0)
    (targetName : Named.nameIs text targetFirst targetAfter
      ("input_is_valid".toList.map Char.toNat) = true) :
    actualNameFree text position
      (fixedAfter text (fixedAfter text (fixedAfter text position "silver_arguments" true) "." false)
        "input_is_valid" true) targetFirst targetAfter = true ∧
      ∀ cell, ScalarProcedures.conditionMentions cell .inputValid = false := by
  have length := (Bool.and_eq_true_iff.mp targetName).1
  change decide (targetAfter - targetFirst = 14) = true at length
  exact ⟨actualNameFree_qualifiedValidity bounded accepted (of_decide_eq_true length), fun _ => rfl⟩

end Silver.Predicate
