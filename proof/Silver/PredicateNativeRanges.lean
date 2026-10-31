module

public import Silver.PredicateConditionSound
public import Silver.PredicateConditionBounds
public import Silver.ComposeBounds

@[expose] public section

namespace Silver.Predicate.Native
open Compose Compose.Expressions

set_option backward.dsimp.instances true
set_option maxRecDepth 10000

/-- Decreasing cursor guards in the total model cannot move an accepted chain
backwards, independently of the facts or expression interpretation. -/
theorem tail_nondecreasing (text : Source) (context : ParseContext) (result : ConditionResult) (chained : Option Predicate.ChainKind) (incoming : ActiveFlow)
    {initials : ArrayBindings.Initials} {originalStart : Nat}
    (accepted : (conditionTail text context result chained incoming initials originalStart).after ≠ 0) :
    result.after ≤ (conditionTail text context result chained incoming initials originalStart).after := by
  rw [conditionTail] at accepted ⊢
  dsimp only at accepted ⊢
  split <;> (try simp only [*] at accepted) <;> (try dsimp only at accepted)
  · exact False.elim (accepted rfl)
  · split
    · exact Nat.le_refl _
    · split <;> (try simp only [*] at accepted) <;> (try dsimp only at accepted)
      · exact False.elim (accepted rfl)
      · split <;> (try simp only [*] at accepted) <;> (try dsimp only at accepted)
        · exact False.elim (accepted rfl)
        · split <;> (try simp only [*] at accepted) <;> (try dsimp only at accepted)
          · split <;> (try simp only [*] at accepted) <;> (try dsimp only at accepted)
            · exact False.elim (accepted rfl)
            · split <;> (try simp only [*] at accepted) <;> (try dsimp only at accepted)
              · have rest := tail_nondecreasing text context _ _ _ accepted
                unfold remainingAt at *
                omega
              · exact False.elim (accepted rfl)
          · exact False.elim (accepted rfl)
termination_by remainingAt text result.after

theorem condition_progress (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow) {initials : ArrayBindings.Initials}
    (accepted : (readCondition text context position facts initials).after ≠ 0) :
    position < (readCondition text context position facts initials).after := by
  rw [readCondition] at accepted ⊢
  split <;> (try simp only [*] at accepted)
  · exact False.elim (accepted rfl)
  · split <;> (try simp only [*] at accepted)
    · dsimp only at accepted ⊢
      split <;> (try simp only [*] at accepted)
      · exact False.elim (accepted rfl)
      · have rest := tail_nondecreasing text context _ _ _ accepted
        unfold remainingAt at *
        omega
    · exact False.elim (accepted rfl)

theorem condition_bound (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow) {initials : ArrayBindings.Initials}
    (textValid : ValidText text) (namesValid : ValidNames text context.names) (bounded : position ≤ text.length + 1) :
    (readCondition text context position facts initials).after ≤ text.length + 1 := by
  by_cases failed : (readCondition text context position facts initials).after = 0
  · simp [failed]
  · exact (condition_sound text context position facts textValid namesValid bounded failed).2

theorem primary_bound (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow) {initials : ArrayBindings.Initials}
    (textValid : ValidText text) (namesValid : ValidNames text context.names) (bounded : position ≤ text.length + 1) :
    (readPrimary text context position facts initials).after ≤ text.length + 1 := by
  by_cases failed : (readPrimary text context position facts initials).after = 0
  · simp [failed]
  · exact (primary_sound text context position facts textValid namesValid bounded failed).2

theorem relation_bound (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow) {initials : ArrayBindings.Initials}
    (textValid : ValidText text) (namesValid : ValidNames text context.names) (bounded : position ≤ text.length + 1) :
    (readRelation text context position facts initials).after ≤ text.length + 1 := by
  by_cases failed : (readRelation text context position facts initials).after = 0
  · simp [failed]
  · exact (relation_sound text context position facts textValid namesValid bounded failed).2

theorem booleanFactor_bound (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
    {initials : ArrayBindings.Initials}
    (textValid : ValidText text) (namesValid : ValidNames text context.names) (bounded : position ≤ text.length + 1) :
    (readBooleanFactor text context position facts initials).after ≤ text.length + 1 := by
  by_cases failed : (readBooleanFactor text context position facts initials).after = 0
  · simp [failed]
  · exact (booleanFactor_sound text context position facts textValid namesValid bounded failed).2

theorem booleanRelation_bound (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
    {initials : ArrayBindings.Initials}
    (textValid : ValidText text) (namesValid : ValidNames text context.names) (bounded : position ≤ text.length + 1) :
    (readBooleanRelation text context position facts initials).after ≤ text.length + 1 := by
  by_cases failed : (readBooleanRelation text context position facts initials).after = 0
  · simp [failed]
  · exact (booleanRelation_sound text context position facts textValid namesValid bounded failed).2

theorem tail_bound (text : Source) (context : ParseContext) (result : ConditionResult) (chained : Option Predicate.ChainKind) (incoming : ActiveFlow)
    {initials : ArrayBindings.Initials} {originalStart : Nat}
    (textValid : ValidText text) (namesValid : ValidNames text context.names) (bounded : result.after ≤ text.length + 1) :
    (conditionTail text context result chained incoming initials originalStart).after ≤ text.length + 1 := by
  by_cases failed : (conditionTail text context result chained incoming initials originalStart).after = 0
  · simp [failed]
  · exact (chain_sound text context .inputValid result chained incoming originalStart textValid namesValid bounded failed).2

end Silver.Predicate.Native
