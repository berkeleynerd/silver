module

public import Silver.PredicateConditionAdmission
public import Silver.PredicateFlowOperations

@[expose] public section

namespace Silver.Predicate
open Compose

/-- Both constrained native outcome buffers retain the incoming extent, even
when parsing fails. Scalar values on failure are specified separately. -/
def ConditionResult.Counts (result : ConditionResult) (count : Nat) : Prop :=
  result.whenTrue.count = count ∧ result.whenFalse.count = count

theorem invalidCondition_counts (facts : ActiveFlow) :
    (invalidCondition facts).Counts facts.count := ⟨rfl, rfl⟩

theorem characterCondition_counts (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) (initials : ArrayBindings.Initials := []) :
    (characterCondition text context position facts initials).Counts facts.count := by
  unfold characterCondition
  dsimp only
  split
  · exact invalidCondition_counts facts
  · exact ⟨rfl, rfl⟩

theorem scalarCondition_counts (text : Source) (context : ParseContext) (position rightPosition : Nat)
    (facts : ActiveFlow) (left right : ScalarExpression.Result) (operator : Comparison) :
    (scalarCondition text context position rightPosition facts left right operator).Counts facts.count := by
  unfold scalarCondition ConditionResult.Counts
  exact ⟨ActiveFlow.refine_count .., ActiveFlow.refine_count ..⟩

theorem chainContext_count {result : ConditionResult} {count : Nat}
    (valid : result.Counts count) (operator : ChainKind) (incoming : ActiveFlow)
    (incomingCount : incoming.count = count) :
    (chainContext result operator incoming).count = count := by
  cases operator
  · exact valid.1
  · exact valid.2
  all_goals exact incomingCount

theorem chainJoin_counts {left right : ConditionResult} {count : Nat}
    (a : left.Counts count) (b : right.Counts count) (operator : ChainKind)
    (incoming : ActiveFlow) (incomingCount : incoming.count = count) :
    (chainJoin left right operator incoming).Counts count := by
  cases operator
  · exact ⟨b.1, (ActiveFlow.join_count _ _ (a.2.trans b.2.symm)).trans a.2⟩
  · exact ⟨(ActiveFlow.join_count _ _ (a.1.trans b.1.symm)).trans a.1, b.2⟩
  all_goals exact ⟨incomingCount, incomingCount⟩

mutual
  theorem primary_counts (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
      (initials : ArrayBindings.Initials := []) :
      (readPrimary text context position facts initials).Counts facts.count := by
    rw [readPrimary]
    split
    · exact invalidCondition_counts facts
    · try dsimp only
      split
      · split
        · try dsimp only
          split
          · exact invalidCondition_counts facts
          · exact condition_counts text context _ facts initials
        · exact invalidCondition_counts facts
      · split
        · exact ⟨rfl, rfl⟩
        · split
          · exact ⟨rfl, rfl⟩
          · split
            · exact invalidCondition_counts facts
            · try dsimp only
              split
              · exact invalidCondition_counts facts
              · exact ⟨rfl, rfl⟩
  termination_by (remainingAt text position, 1)

  theorem booleanFactor_counts (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
      (initials : ArrayBindings.Initials := []) :
      (readBooleanFactor text context position facts initials).Counts facts.count := by
    rw [readBooleanFactor]
    split
    · exact primary_counts text context position facts initials
    · split
      · have next := primary_counts text context (fixedAfter text position "not" true) facts initials
        exact ⟨next.2, next.1⟩
      · exact invalidCondition_counts facts
  termination_by (remainingAt text position, 2)

  theorem booleanRelation_counts (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
      (initials : ArrayBindings.Initials := []) :
      (readBooleanRelation text context position facts initials).Counts facts.count := by
    rw [readBooleanRelation]
    try dsimp only
    split
    · exact invalidCondition_counts facts
    · split
      · exact booleanFactor_counts text context position facts initials
      · split
        · exact invalidCondition_counts facts
        · split
          · try dsimp only
            split
            · exact invalidCondition_counts facts
            · exact ⟨rfl, rfl⟩
          · exact invalidCondition_counts facts
  termination_by (remainingAt text position, 3)

  theorem relation_counts (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
      (initials : ArrayBindings.Initials := []) :
      (readRelation text context position facts initials).Counts facts.count := by
    rw [readRelation]
    split
    · exact invalidCondition_counts facts
    · try dsimp only
      split
      · exact booleanRelation_counts text context position facts initials
      · try dsimp only
        split
        · try dsimp only
          split
          · exact invalidCondition_counts facts
          · exact ⟨rfl, rfl⟩
        · try dsimp only
          split
          · try dsimp only
            split
            · exact invalidCondition_counts facts
            · exact scalarCondition_counts ..
          · try dsimp only
            split
            · exact booleanRelation_counts text context position facts initials
            · try dsimp only
              split
              · try dsimp only
                split
                · exact invalidCondition_counts facts
                · try dsimp only
                  split
                  · exact invalidCondition_counts facts
                  · try dsimp only
                    by_cases equal : (comparisonAt text (readStringInFlow text context position facts initials).after).operator == Comparison.eq
                    · simp only [equal, ↓reduceIte]
                      exact ⟨rfl, rfl⟩
                    · simp only [equal, Bool.false_eq_true, ↓reduceIte]
                      exact ⟨rfl, rfl⟩
              · try dsimp only
                split
                · exact characterCondition_counts text context position facts initials
                · exact booleanRelation_counts text context position facts initials
  termination_by (remainingAt text position, 4)

  theorem tail_counts (text : Source) (context : ParseContext) (result : ConditionResult)
      (chained : Option ChainKind) (incoming : ActiveFlow) {count : Nat}
      (valid : result.Counts count) (incomingCount : incoming.count = count)
      (initials : ArrayBindings.Initials := []) (originalStart : Nat := 0) :
      (conditionTail text context result chained incoming initials originalStart).Counts count := by
    have invalid : (invalidCondition result.whenTrue).Counts count := by
      simpa only [valid.1] using invalidCondition_counts result.whenTrue
    rw [conditionTail]
    split
    · exact invalid
    · split
      · exact valid
      · try dsimp only
        split
        · exact invalid
        · try dsimp only
          split
          · exact invalid
          · split
            · try dsimp only
              split
              · exact invalid
              · try dsimp only
                split
                · apply tail_counts
                  · apply chainJoin_counts valid _ _ incoming incomingCount
                    simpa only [chainContext_count valid _ incoming incomingCount] using
                      relation_counts text context _ (chainContext result _ incoming) initials
                  · exact incomingCount
                · exact invalid
            · exact invalid
  termination_by (remainingAt text result.after, 6)

  theorem condition_counts (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
      (initials : ArrayBindings.Initials := []) :
      (readCondition text context position facts initials).Counts facts.count := by
    rw [readCondition]
    split
    · exact invalidCondition_counts facts
    · split
      · try dsimp only
        split
        · exact invalidCondition_counts facts
        · exact tail_counts text context _ none facts (relation_counts text context position facts initials) rfl initials position
      · exact invalidCondition_counts facts
  termination_by (remainingAt text position, 5)
end

end Silver.Predicate
