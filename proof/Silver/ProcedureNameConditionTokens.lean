module

public import Silver.ProcedureNameCompoundTokens
public import Silver.ProcedureNameIdentifierWords
public import Silver.PredicateConditionSound

@[expose] public section

namespace Silver.Predicate
open Compose

theorem ActualNameFreeTrace.comparison {text : Source}
    {position limit targetFirst targetAfter : Nat}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (positionBound : position ≤ text.length + 1)
    (accepted : (Predicate.comparisonAt text position).after ≠ 0)
    (finishBound : (Predicate.comparisonAt text position).after ≤ limit) :
    ActualNameFreeTrace text limit targetFirst targetAfter (Predicate.comparisonAt text position).after := by
  unfold Predicate.comparisonAt at accepted finishBound ⊢
  split
  · rename_i found
    rw [ite_eq_left found] at finishBound
    exact trace.fixedPair (left := '/') (right := '=') positionBound
      (by unfold OrdinarySymbol; decide) (by unfold OrdinarySymbol; decide) (by decide) (by decide) found finishBound
  · rename_i absent
    simp only [absent, ↓reduceIte] at accepted finishBound
    split
    · rename_i found
      rw [ite_eq_left found] at finishBound
      exact trace.fixedPair (left := '<') (right := '=') positionBound
        (by unfold OrdinarySymbol; decide) (by unfold OrdinarySymbol; decide) (by decide) (by decide) found finishBound
    · rename_i absent
      simp only [absent, ↓reduceIte] at accepted finishBound
      split
      · rename_i found
        rw [ite_eq_left found] at finishBound
        exact trace.fixedPair (left := '>') (right := '=') positionBound
          (by unfold OrdinarySymbol; decide) (by unfold OrdinarySymbol; decide) (by decide) (by decide) found finishBound
      · rename_i absent
        simp only [absent, ↓reduceIte] at accepted finishBound
        split
        · rename_i found
          rw [ite_eq_left found] at finishBound
          exact trace.fixedSymbol (byte := '=') positionBound (by unfold OrdinarySymbol; decide) found finishBound
        · rename_i absent
          simp only [absent, ↓reduceIte] at accepted finishBound
          split
          · rename_i found
            rw [ite_eq_left found] at finishBound
            exact trace.fixedSymbol (byte := '<') positionBound (by unfold OrdinarySymbol; decide) found finishBound
          · rename_i absent
            simp only [absent, ↓reduceIte] at accepted finishBound
            split
            · rename_i found
              rw [ite_eq_left found] at finishBound
              exact trace.fixedSymbol (byte := '>') positionBound (by unfold OrdinarySymbol; decide) found finishBound
            · rename_i absent
              simp only [absent, ↓reduceIte] at accepted
              contradiction

theorem ActualNameFreeTrace.logicalChain {text : Source}
    {position limit targetFirst targetAfter : Nat} {operator : ChainKind}
    (trace : ActualNameFreeTrace text limit targetFirst targetAfter position)
    (positionBound : position ≤ text.length + 1)
    (accepted : chainAfter text position operator ≠ 0)
    (finishBound : chainAfter text position operator ≤ limit) :
    ActualNameFreeTrace text limit targetFirst targetAfter (chainAfter text position operator) := by
  cases operator with
  | shortAnd =>
      have firstPositive := Compose.Expressions.model_fixed_input_nonzero text _ "then" true accepted
      have firstBound := fixedAfter_result_bound text position "and" true (by decide)
      have advance := Compose.Expressions.model_fixed_advances text _ "then" true firstBound (by decide) accepted
      have first := trace.fixedWord (word := "and") positionBound (by decide) (by decide) firstPositive (by
        change fixedAfter text (fixedAfter text position "and" true) "then" true ≤ limit at finishBound
        omega)
      exact first.fixedWord (word := "then") firstBound (by decide) (by decide) accepted finishBound
  | shortOr =>
      have firstPositive := Compose.Expressions.model_fixed_input_nonzero text _ "else" true accepted
      have firstBound := fixedAfter_result_bound text position "or" true (by decide)
      have advance := Compose.Expressions.model_fixed_advances text _ "else" true firstBound (by decide) accepted
      have first := trace.fixedWord (word := "or") positionBound (by decide) (by decide) firstPositive (by
        change fixedAfter text (fixedAfter text position "or" true) "else" true ≤ limit at finishBound
        omega)
      exact first.fixedWord (word := "else") firstBound (by decide) (by decide) accepted finishBound
  | eagerAnd => exact trace.fixedWord (word := "and") positionBound (by decide) (by decide) accepted finishBound
  | eagerOr => exact trace.fixedWord (word := "or") positionBound (by decide) (by decide) accepted finishBound
  | eagerXor => exact trace.fixedWord (word := "xor") positionBound (by decide) (by decide) accepted finishBound

end Silver.Predicate
