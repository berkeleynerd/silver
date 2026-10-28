module

public import Silver.PredicateAdmission
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

theorem scalarCondition_counts (text : Source) (context : ParseContext) (position rightPosition : Nat)
    (facts : ActiveFlow) (left right : ScalarExpression.Result) (operator : Comparison) :
    (scalarCondition text context position rightPosition facts left right operator).Counts facts.count := by
  unfold scalarCondition ConditionResult.Counts
  exact ⟨ActiveFlow.refine_count .., ActiveFlow.refine_count ..⟩

theorem chainContext_count {result : ConditionResult} {count : Nat}
    (valid : result.Counts count) (operator : Bool) :
    (chainContext result operator).count = count := by
  cases operator
  · exact valid.2
  · exact valid.1

theorem chainJoin_counts {left right : ConditionResult} {count : Nat}
    (a : left.Counts count) (b : right.Counts count) (operator : Bool) :
    (chainJoin left right operator).Counts count := by
  cases operator with
  | false =>
      exact ⟨(ActiveFlow.join_count _ _ (a.1.trans b.1.symm)).trans a.1, b.2⟩
  | true =>
      exact ⟨b.1, (ActiveFlow.join_count _ _ (a.2.trans b.2.symm)).trans a.2⟩

mutual
  theorem primary_counts (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow) :
      (readPrimary text context position facts).Counts facts.count := by
    rw [readPrimary]
    split
    · exact invalidCondition_counts facts
    · try dsimp only
      split
      · split
        · try dsimp only
          split
          · exact invalidCondition_counts facts
          · exact condition_counts text context _ facts
        · exact invalidCondition_counts facts
      · split
        · exact invalidCondition_counts facts
        · try dsimp only
          split
          · exact invalidCondition_counts facts
          · exact ⟨rfl, rfl⟩
  termination_by (remainingAt text position, 1)

  theorem relation_counts (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow) :
      (readRelation text context position facts).Counts facts.count := by
    rw [readRelation]
    split
    · exact invalidCondition_counts facts
    · try dsimp only
      split
      · split
        · have next := primary_counts text context (fixedAfter text position "not" true) facts
          exact ⟨next.2, next.1⟩
        · exact invalidCondition_counts facts
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
            · try dsimp only
              split
              · exact invalidCondition_counts facts
              · try dsimp only
                split
                · exact invalidCondition_counts facts
                · try dsimp only
                  by_cases equal : (comparisonAt text
                    (expressionAt (arrays := context.arrayNames) text position context.names (context.readingNames facts)).after).operator == Comparison.eq
                  · simp only [equal, ↓reduceIte]
                    exact ⟨rfl, rfl⟩
                  · simp only [equal, Bool.false_eq_true, ↓reduceIte]
                    exact ⟨rfl, rfl⟩
            · exact primary_counts text context position facts
  termination_by (remainingAt text position, 2)

  theorem tail_counts (text : Source) (context : ParseContext) (result : ConditionResult)
      (chained : Option Bool) {count : Nat} (valid : result.Counts count) :
      (conditionTail text context result chained).Counts count := by
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
                  apply chainJoin_counts valid
                  simpa only [chainContext_count valid] using relation_counts text context _ (chainContext result _)
                · exact invalid
            · exact invalid
  termination_by (remainingAt text result.after, 4)

  theorem condition_counts (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow) :
      (readCondition text context position facts).Counts facts.count := by
    rw [readCondition]
    split
    · exact invalidCondition_counts facts
    · split
      · try dsimp only
        split
        · exact invalidCondition_counts facts
        · exact tail_counts text context _ none (relation_counts text context position facts)
      · exact invalidCondition_counts facts
  termination_by (remainingAt text position, 3)
end

end Silver.Predicate
