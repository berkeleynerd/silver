module

public import Silver.ProcedureNameIdentifierWords
public import Silver.ComposeBounds

@[expose] public section

namespace Silver.Predicate
open Compose

theorem ActualNameFreeTrace.validityOperation {text : Source}
    {position limit targetFirst targetAfter : Nat} {hidden : Bool}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (positionBound : position ≤ text.length + 1)
    (accepted : Names.operationAfter text position .validity hidden ≠ 0)
    (finishBound : Names.operationAfter text position .validity hidden ≤ limit) :
    ActualNameFreeTrace text limit targetFirst targetAfter (Names.operationAfter text position .validity hidden) := by
  simp only [Names.operationAfter, reduceCtorEq, or_self, ↓reduceIte] at accepted finishBound ⊢
  split at accepted
  · contradiction
  · rename_i visible
    rw [ite_eq_right visible] at finishBound ⊢
    split at accepted
    · rename_i qualified
      rw [ite_eq_left qualified] at finishBound ⊢
      change fixedAfter text (fixedAfter text (fixedAfter text position "silver_arguments" true) "." false)
        "input_is_valid" true ≠ 0 at accepted
      change fixedAfter text (fixedAfter text (fixedAfter text position "silver_arguments" true) "." false)
        "input_is_valid" true ≤ limit at finishBound
      have dotPositive : fixedAfter text (fixedAfter text position "silver_arguments" true) "." false ≠ 0 := qualified
      have prefixPositive := Compose.Expressions.model_fixed_input_nonzero text _ "." false dotPositive
      have prefixBound := fixedAfter_result_bound text position "silver_arguments" true (by decide)
      have dotBound := fixedAfter_result_bound text (fixedAfter text position "silver_arguments" true) "." false (by decide)
      have dotAdvance := Compose.Expressions.model_fixed_advances text _ "." false prefixBound (by decide) dotPositive
      have callAdvance := Compose.Expressions.model_fixed_advances text _ "input_is_valid" true dotBound (by decide) accepted
      have afterPrefix := trace.fixedIdentifier (word := "silver_arguments") positionBound (by decide) prefixPositive (by omega)
      have afterDot := afterPrefix.fixedSymbol (byte := '.') prefixBound (by unfold OrdinarySymbol; decide) dotPositive
        (show fixedAfter text (fixedAfter text position "silver_arguments" true) "." false ≤ limit by omega)
      exact afterDot.fixedIdentifier (word := "input_is_valid") dotBound (by decide) accepted finishBound
    · rename_i plain
      rw [ite_eq_right plain] at finishBound ⊢
      split at accepted
      · rename_i used
        rw [ite_eq_left used] at finishBound ⊢
        exact trace.fixedIdentifier (word := "input_is_valid") positionBound (by decide) accepted finishBound
      · contradiction

end Silver.Predicate
