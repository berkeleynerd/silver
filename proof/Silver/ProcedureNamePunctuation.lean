module

public import Silver.ProcedureNameSelectors

@[expose] public section

namespace Silver.Predicate
open Compose

theorem ActualNameFreeTrace.fixedPair {text : Source}
    {position limit targetFirst targetAfter : Nat} {left right : Char}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (positionBound : position ≤ text.length + 1)
    (leftOrdinary : OrdinarySymbol left.toNat) (rightOrdinary : OrdinarySymbol right.toNat)
    (rightSpace : whitespace right.toNat = false) (rightComment : right.toNat ≠ 45)
    (accepted : fixedAfter text position (String.ofList [left, right]) false ≠ 0)
    (finishBound : fixedAfter text position (String.ofList [left, right]) false ≤ limit) :
    ActualNameFreeTrace text limit targetFirst targetAfter
      (fixedAfter text position (String.ofList [left, right]) false) := by
  obtain ⟨positive, bounded, matched, after⟩ := fixedAfter_fields positionBound accepted
  simp only [String.toList_ofList, List.length_cons, List.length_nil] at bounded after
  have selected := matched
  simp only [fixedAt, Bool.and_eq_true, decide_eq_true_eq] at selected
  have first := selected.1.2 ⟨0, by simp⟩
  have second := selected.1.2 ⟨1, by simp⟩
  simp only [Nat.add_zero, String.toList_ofList, List.map_cons, List.map_nil,
    List.getElem_cons_zero] at first
  simp only [String.toList_ofList, List.map_cons, List.map_nil,
    List.getElem_cons_succ, List.getElem_cons_zero] at second
  have leftFound := lowercase_symbol leftOrdinary.1 first
  have rightFound := lowercase_symbol rightOrdinary.1 second
  have start := ScalarExpression.skip_bounds text position positionBound
  change position ≤ skipAt text position ∧ skipAt text position ≤ text.length + 1 at start
  have rest := trace.symbol (by omega) rfl (by omega) (by simpa only [leftFound] using leftOrdinary)
  have nextFixed : skipAt text (skipAt text position + 1) = skipAt text position + 1 := by
    change (if skipAt text position + 1 = 0 then 0 else
      Cursor.triviaPosition text (skipAt text position + 1)) = skipAt text position + 1
    rw [ite_eq_right (show skipAt text position + 1 ≠ 0 by omega)]
    rw [Cursor.triviaPosition_equation text (skipAt text position + 1) (by omega) (by omega)]
    simp only [show ¬skipAt text position + 1 > text.length by omega, ↓reduceIte,
      rightFound, rightSpace, rightComment, false_and]
    rfl
  have tail := rest.symbol (by omega) nextFixed (by omega) (by
    simpa only [rightFound] using rightOrdinary)
  simpa only [after, Nat.add_assoc] using tail

/-- Both bytes of the contiguous range delimiter remain individual scanner
steps. The first dot cannot match a selector and the second is guarded by its
preceding dot, even when the following identifier is Input_Is_Valid. -/
theorem ActualNameFreeTrace.fixedRange {text : Source}
    {position limit targetFirst targetAfter : Nat}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (positionBound : position ≤ text.length + 1)
    (accepted : fixedAfter text position ".." false ≠ 0)
    (finishBound : fixedAfter text position ".." false ≤ limit) :
    ActualNameFreeTrace text limit targetFirst targetAfter (fixedAfter text position ".." false) := by
  obtain ⟨positive, bounded, matched, after⟩ := fixedAfter_fields positionBound accepted
  change skipAt text position + 2 ≤ text.length + 1 at bounded
  change fixedAfter text position ".." false = skipAt text position + 2 at after
  have selected := matched
  simp only [fixedAt, Bool.and_eq_true, decide_eq_true_eq] at selected
  have first := selected.1.2 ⟨0, by decide⟩
  have second := selected.1.2 ⟨1, by decide⟩
  have leftFound : Cursor.byteAt text (skipAt text position) = 46 :=
    lowercase_symbol (by decide) (by simpa using first)
  have rightFound : Cursor.byteAt text (skipAt text position + 1) = 46 :=
    lowercase_symbol (by decide) (by simpa using second)
  have start := ScalarExpression.skip_bounds text position positionBound
  change position ≤ skipAt text position ∧ skipAt text position ≤ text.length + 1 at start
  have nextFixed : skipAt text (skipAt text position + 1) = skipAt text position + 1 := by
    change (if skipAt text position + 1 = 0 then 0 else
      Cursor.triviaPosition text (skipAt text position + 1)) = skipAt text position + 1
    rw [ite_eq_right (show skipAt text position + 1 ≠ 0 by omega)]
    rw [Cursor.triviaPosition_equation text (skipAt text position + 1) (by omega) (by omega)]
    simp [show ¬skipAt text position + 1 > text.length by omega, rightFound, whitespace]
  have dotAfter := fixedDot_after positive (by omega) (skipAt_idempotent text position) leftFound
  have noSelector : fixedAfter text (fixedAfter text (skipAt text position) "." false) "input_is_valid" true = 0 := by
    rw [dotAfter]
    exact fixedValidity_dot_rejected (by omega) nextFixed rightFound
  have rest := trace.plainDot (by omega) rfl (by omega) leftFound (.inr (.inr noSelector))
  have tail := rest.plainDot (by omega) nextFixed (by omega) rightFound
    (.inr (.inl (by simpa only [Nat.add_sub_cancel] using leftFound)))
  simpa only [after, Nat.add_assoc] using tail

/-- A genuine identifier after a range is still rejected when it names the
writable actual. This is a generic upper-bound control, not one literal source. -/
theorem actualNameFree_range_alias {text bytes : Source}
    {position first finish limit targetFirst targetAfter : Nat}
    (positionBound : position ≤ text.length + 1)
    (range : fixedAfter text position ".." false ≠ 0)
    (skipped : skipAt text (fixedAfter text position ".." false) = first)
    (positive : first ≠ 0)
    (identifier : Named.IdentifierAt text first bytes finish) (finishBound : finish ≤ limit)
    (same : Named.equalName text first finish targetFirst targetAfter = true) :
    actualNameFree text position limit targetFirst targetAfter = false := by
  apply Bool.eq_false_iff.mpr
  intro accepted
  have trace := actualNameFree_sound accepted
  have rangeBound := fixedAfter_result_bound text position ".." false (by decide)
  have start := ScalarExpression.skip_bounds text (fixedAfter text position ".." false) rangeBound
  change fixedAfter text position ".." false ≤ skipAt text (fixedAfter text position ".." false) ∧ _ at start
  have bounds := Named.identifier_bounds identifier
  have afterRange := trace.fixedRange positionBound range (by omega)
  have excluded := (afterRange.identifier (by omega) skipped positive identifier finishBound).1
  rw [same] at excluded
  contradiction

end Silver.Predicate
