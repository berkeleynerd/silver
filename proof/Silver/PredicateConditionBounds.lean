module

public import Silver.PredicateAdmission
public import Silver.PathBounds

@[expose] public section
namespace Silver.Predicate
open Compose Bindings PathFacts

def ConditionResult.Bounded (result : ConditionResult) : Prop :=
  result.whenTrue.Bounded ∧ result.whenFalse.Bounded

theorem invalidCondition_bounded : invalidCondition.Bounded := ⟨Context.empty_bounded, Context.empty_bounded⟩

theorem chainContext_bounded {result : ConditionResult} (bounded : result.Bounded) (operator : Bool) :
    (chainContext result operator).Bounded := by
  cases operator
  · exact bounded.2
  · exact bounded.1

theorem chainJoin_bounded {left right : ConditionResult} (a : left.Bounded) (b : right.Bounded) (operator : Bool) :
    (chainJoin left right operator).Bounded := by
  cases operator
  · exact ⟨Context.join_bounded a.1 b.1, b.2⟩
  · exact ⟨b.1, Context.join_bounded a.2 b.2⟩

mutual
  theorem readPrimary_bounded (text : Source) (context : ParseContext) (position : Nat) (facts : Context)
      (bounded : facts.Bounded) : (readPrimary text context position facts).Bounded := by
    rw [readPrimary]
    split
    · exact invalidCondition_bounded
    · try dsimp only
      split
      · split
        · exact readCondition_bounded text context _ facts bounded
        · exact invalidCondition_bounded
      · split
        · exact invalidCondition_bounded
        · exact ⟨Context.assumeValid_bounded bounded, Context.assumeInvalid_bounded _⟩
  termination_by (remainingAt text position, 1)

  theorem readRelation_bounded (text : Source) (context : ParseContext) (position : Nat) (facts : Context)
      (bounded : facts.Bounded) : (readRelation text context position facts).Bounded := by
    rw [readRelation]
    split
    · exact invalidCondition_bounded
    · try dsimp only
      split
      · split
        · have next := readPrimary_bounded text context (fixedAfter text position "not" true) facts bounded
          exact ⟨next.2, next.1⟩
        · exact invalidCondition_bounded
      · try dsimp only
        split
        · try dsimp only
          split
          · exact invalidCondition_bounded
          · exact ⟨refineBounds_bounded bounded _ _ _ _, refineBounds_bounded bounded _ _ _ _⟩
        · try dsimp only
          split
          · try dsimp only
            split
            · exact invalidCondition_bounded
            · exact ⟨bounded, bounded⟩
          · try dsimp only
            split
            · try dsimp only
              split
              · exact invalidCondition_bounded
              · try dsimp only
                split
                · exact invalidCondition_bounded
                · try dsimp only
                  by_cases equal : (comparisonAt text (expressionAt text position context.names context.scalarNames).after).operator == Comparison.eq
                  · simp only [equal, ↓reduceIte]
                    exact ⟨refineAffineEqual_bounded bounded _ _, bounded⟩
                  · simp only [equal, Bool.false_eq_true, ↓reduceIte]
                    exact ⟨bounded, refineAffineEqual_bounded bounded _ _⟩
            · exact readPrimary_bounded text context position facts bounded
  termination_by (remainingAt text position, 2)

  theorem conditionTail_bounded (text : Source) (context : ParseContext) (result : ConditionResult) (chained : Option Bool)
      (bounded : result.Bounded) : (conditionTail text context result chained).Bounded := by
    rw [conditionTail]
    split
    · exact invalidCondition_bounded
    · split
      · exact bounded
      · try dsimp only
        split
        · exact invalidCondition_bounded
        · try dsimp only
          split
          · exact invalidCondition_bounded
          · split
            · try dsimp only
              split
              · exact invalidCondition_bounded
              · try dsimp only
                split
                · exact conditionTail_bounded text context _ _
                    (chainJoin_bounded bounded (readRelation_bounded text context _ _ (chainContext_bounded bounded _)) _)
                · exact invalidCondition_bounded
            · exact invalidCondition_bounded
  termination_by (remainingAt text result.after, 4)

  theorem readCondition_bounded (text : Source) (context : ParseContext) (position : Nat) (facts : Context)
      (bounded : facts.Bounded) : (readCondition text context position facts).Bounded := by
    rw [readCondition]
    split
    · exact invalidCondition_bounded
    · split
      · exact conditionTail_bounded text context _ none (readRelation_bounded text context position facts bounded)
      · exact invalidCondition_bounded
  termination_by (remainingAt text position, 3)
end

end Silver.Predicate
