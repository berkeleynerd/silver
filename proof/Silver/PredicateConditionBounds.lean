module

public import Silver.PredicateConditionAdmission
public import Silver.PredicateFlowOperations
public import Silver.PathBounds

@[expose] public section
namespace Silver.Predicate
open Compose Bindings PathFacts

def ConditionResult.Bounded (result : ConditionResult) : Prop :=
  result.whenTrue.path.Bounded ∧ result.whenFalse.path.Bounded

theorem invalidCondition_bounded (facts : ActiveFlow) : (invalidCondition facts).Bounded :=
  ⟨Context.empty_bounded, Context.empty_bounded⟩

theorem chainContext_bounded {result : ConditionResult} (bounded : result.Bounded)
    (operator : ChainKind) (incoming : ActiveFlow) (incomingBounded : incoming.path.Bounded) :
    (chainContext result operator incoming).path.Bounded := by
  cases operator
  · exact bounded.1
  · exact bounded.2
  all_goals exact incomingBounded

theorem chainJoin_bounded {left right : ConditionResult} (a : left.Bounded) (b : right.Bounded)
    (operator : ChainKind) (incoming : ActiveFlow) (incomingBounded : incoming.path.Bounded) :
    (chainJoin left right operator incoming).Bounded := by
  cases operator
  · exact ⟨b.1, Context.join_bounded a.2 b.2⟩
  · exact ⟨Context.join_bounded a.1 b.1, b.2⟩
  all_goals exact ⟨incomingBounded, incomingBounded⟩

mutual
  theorem readPrimary_bounded (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
      (bounded : facts.path.Bounded) (initials : ArrayBindings.Initials := []) :
      (readPrimary text context position facts initials).Bounded := by
    rw [readPrimary]
    split
    · exact invalidCondition_bounded facts
    · try dsimp only
      split
      · split
        · try dsimp only
          split
          · exact invalidCondition_bounded facts
          · exact readCondition_bounded text context _ facts bounded initials
        · exact invalidCondition_bounded facts
      · split
        · exact ⟨bounded, bounded⟩
        · split
          · exact invalidCondition_bounded facts
          · try dsimp only
            split
            · exact invalidCondition_bounded facts
            · exact ⟨Context.assumeValid_bounded bounded, Context.assumeInvalid_bounded _⟩
  termination_by (remainingAt text position, 1)

  theorem readBooleanFactor_bounded (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
      (bounded : facts.path.Bounded) (initials : ArrayBindings.Initials := []) :
      (readBooleanFactor text context position facts initials).Bounded := by
    rw [readBooleanFactor]
    split
    · exact readPrimary_bounded text context position facts bounded initials
    · split
      · have next := readPrimary_bounded text context (fixedAfter text position "not" true) facts bounded initials
        exact ⟨next.2, next.1⟩
      · exact invalidCondition_bounded facts
  termination_by (remainingAt text position, 2)

  theorem readBooleanRelation_bounded (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
      (bounded : facts.path.Bounded) (initials : ArrayBindings.Initials := []) :
      (readBooleanRelation text context position facts initials).Bounded := by
    rw [readBooleanRelation]
    try dsimp only
    split
    · exact invalidCondition_bounded facts
    · split
      · exact readBooleanFactor_bounded text context position facts bounded initials
      · split
        · exact invalidCondition_bounded facts
        · split
          · try dsimp only
            split
            · exact invalidCondition_bounded facts
            · exact ⟨bounded, bounded⟩
          · exact invalidCondition_bounded facts
  termination_by (remainingAt text position, 3)

  theorem readRelation_bounded (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
      (bounded : facts.path.Bounded) (initials : ArrayBindings.Initials := []) :
      (readRelation text context position facts initials).Bounded := by
    rw [readRelation]
    split
    · exact invalidCondition_bounded facts
    · try dsimp only
      split
      · exact readBooleanRelation_bounded text context position facts bounded initials
      · try dsimp only
        split
        · try dsimp only
          split
          · exact invalidCondition_bounded facts
          · exact ⟨refineBounds_bounded bounded _ _ _ _, refineBounds_bounded bounded _ _ _ _⟩
        · try dsimp only
          split
          · try dsimp only
            split
            · exact invalidCondition_bounded facts
            · unfold scalarCondition ConditionResult.Bounded
              simpa only [ActiveFlow.refine_path] using And.intro bounded bounded
          · try dsimp only
            split
            · try dsimp only
              split
              · exact invalidCondition_bounded facts
              · try dsimp only
                split
                · exact invalidCondition_bounded facts
                · try dsimp only
                  by_cases equal : (comparisonAt text (readStringInFlow text context position facts bounded initials).after).operator == Comparison.eq
                  · simp only [equal, ↓reduceIte]
                    exact ⟨refineLengthOverlap_bounded bounded _ _, bounded⟩
                  · simp only [equal, Bool.false_eq_true, ↓reduceIte]
                    exact ⟨bounded, refineLengthOverlap_bounded bounded _ _⟩
            · exact readBooleanRelation_bounded text context position facts bounded initials
  termination_by (remainingAt text position, 4)

  theorem conditionTail_bounded (text : Source) (context : ParseContext) (result : ConditionResult)
      (chained : Option ChainKind) (incoming : ActiveFlow)
      (valid : result.Bounded) (incomingBounded : incoming.path.Bounded)
      (initials : ArrayBindings.Initials := []) :
      (conditionTail text context result chained incoming initials).Bounded := by
    have invalid := invalidCondition_bounded result.whenTrue
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
                · apply conditionTail_bounded
                  · exact chainJoin_bounded valid
                      (readRelation_bounded text context _ _ (chainContext_bounded valid _ incoming incomingBounded) initials)
                      _ incoming incomingBounded
                  · exact incomingBounded
                · exact invalid
            · exact invalid
  termination_by (remainingAt text result.after, 6)

  theorem readCondition_bounded (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
      (bounded : facts.path.Bounded) (initials : ArrayBindings.Initials := []) :
      (readCondition text context position facts initials).Bounded := by
    rw [readCondition]
    split
    · exact invalidCondition_bounded facts
    · split
      · try dsimp only
        split
        · exact invalidCondition_bounded facts
        · exact conditionTail_bounded text context _ none facts (readRelation_bounded text context position facts bounded initials) bounded initials
      · exact invalidCondition_bounded facts
  termination_by (remainingAt text position, 5)
end

end Silver.Predicate
