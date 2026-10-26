module

public import Silver.PredicateNativeRanges

@[expose] public section

namespace Silver.Predicate.Native
open Compose Compose.Expressions

set_option backward.dsimp.instances true

theorem primary_progress (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
    (textValid : ValidText text) (namesValid : ValidNames text context.names)
    (bounded : position ≤ text.length + 1) (accepted : (readPrimary text context position facts).after ≠ 0) :
    position < (readPrimary text context position facts).after := by
  by_cases zero : position = 0
  · simp [readPrimary, zero, invalidCondition] at accepted
  · by_cases opening : fixedAfter text position "(" false ≠ 0
    · by_cases advanced : remainingAt text (fixedAfter text position "(" false) < remainingAt text position
      · have closed : fixedAfter text (readCondition text context (fixedAfter text position "(" false) facts).after ")" false ≠ 0 := by
          intro absent
          simp [readPrimary, zero, opening, advanced, absent, invalidCondition] at accepted
        have innerPositive := fixedAfter_nonzero closed
        have afterBound := model_fixed_valid text position "(" false bounded
        have start := model_fixed_advances text position "(" false bounded (by decide) opening
        have inner := condition_progress text context _ facts innerPositive
        have innerBound := condition_bound text context _ facts textValid namesValid afterBound
        have stop := model_fixed_advances text _ ")" false innerBound (by decide) closed
        simp [readPrimary, zero, opening, advanced, closed]
        omega
      · simp [readPrimary, zero, opening, advanced, invalidCondition] at accepted
    · have noOpening : fixedAfter text position "(" false = 0 := by omega
      have arguments : context.hasArguments = true := by
        cases arguments : context.hasArguments with
        | false => simp [readPrimary, zero, noOpening, arguments, invalidCondition] at accepted
        | true => rfl
      have finalPositive : callAfter text context.names position .validity context.scalarNames ≠ 0 := by
        intro absent
        simp [readPrimary, zero, noOpening, arguments, absent, invalidCondition] at accepted
      have progress := model_callAfter_advances text context.names position .validity bounded finalPositive
      simpa only [readPrimary, zero, noOpening, arguments, ne_eq, not_true_eq_false,
        Bool.not_true, Bool.false_eq_true, finalPositive, ↓reduceIte] using progress

theorem relation_progress (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
    (textValid : ValidText text) (namesValid : ValidNames text context.names)
    (bounded : position ≤ text.length + 1) (accepted : (readRelation text context position facts).after ≠ 0) :
    position < (readRelation text context position facts).after := by
  by_cases zero : position = 0
  · simp [readRelation, zero, invalidCondition] at accepted
  · by_cases negation : fixedAfter text position "not" true ≠ 0
    · by_cases advanced : remainingAt text (fixedAfter text position "not" true) < remainingAt text position
      · have primaryPositive : (readPrimary text context (fixedAfter text position "not" true) facts).after ≠ 0 := by
          simpa [readRelation, zero, negation, advanced] using accepted
        have start := model_fixed_advances text position "not" true bounded (by decide) negation
        have inner := primary_progress text context _ facts textValid namesValid
          (model_fixed_valid text position "not" true bounded) primaryPositive
        simp [readRelation, zero, negation, advanced]
        omega
      · simp [readRelation, zero, negation, advanced, invalidCondition] at accepted
    · have noNot : fixedAfter text position "not" true = 0 := by omega
      rw [readRelation] at accepted ⊢
      simp only [zero, noNot, ne_eq, not_true_eq_false, ↓reduceIte] at accepted ⊢
      split <;> (try simp only [*] at accepted)
      · split <;> (try simp only [*] at accepted)
        · simp_all [invalidCondition]
        · dsimp only
          omega
      · split <;> (try simp only [*] at accepted)
        · split <;> (try simp only [*] at accepted)
          · simp_all [invalidCondition]
          · dsimp only [scalarCondition]
            omega
        · split <;> (try simp only [*] at accepted)
          · split <;> (try simp only [*] at accepted)
            · simp_all [invalidCondition]
            · split <;> (try simp only [*] at accepted)
              · simp_all [invalidCondition]
              · rename_i allowed
                have advanced := (not_or.mp allowed).1
                dsimp only
                omega
          · exact primary_progress text context position facts textValid namesValid bounded accepted

end Silver.Predicate.Native
