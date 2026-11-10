module

public import Silver.ProcedureNameTerminals

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

end Silver.Predicate
