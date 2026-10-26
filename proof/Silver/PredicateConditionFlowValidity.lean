module

public import Silver.PredicateConditionFlow
public import Silver.PredicateFlowInvariant

@[expose] public section

namespace Silver.Predicate
open Compose

namespace ScalarMetadata

/-- The scalar portion of the native flow contract. Path boundedness is
independent; captured loop indexes may be empty, while mutable cells may not. -/
structure FlowReady (names : ScalarExpression.Environment) (declarations : Nat)
    (flow : ActiveFlow) : Prop where
  compatible : OverlayCompatible names declarations flow
  bounded : flow.model.scalars.Bounded
  contained : flow.model.scalars.Refines (analysis names declarations).declared
  mutableNonempty : ∀ index bounds, ScalarExpression.mutability names index = true →
    flow.model.scalars index = some bounds → bounds.isEmpty = false

theorem FlowReady.withPath {names declarations flow} (ready : FlowReady names declarations flow)
    (path : PathFacts.Context) : FlowReady names declarations {flow with path := path} :=
  ⟨⟨ready.compatible.count, ready.compatible.immutable⟩,
    ready.bounded, ready.contained, ready.mutableNonempty⟩

theorem FlowReady.refine {names declarations flow} (ready : FlowReady names declarations flow)
    (target : Nat) (operator : Integer.Comparison) (threshold : Int) (truth : Bool)
    (allowed : target = 0 ∨ (ScalarExpression.binding names target).mutable = true ∨ declarations < target) :
    FlowReady names declarations (flow.refine target operator threshold truth) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · apply overlayCompatible_of_preserved ready.compatible
      ((ActiveFlow.refine_count ..).trans ready.compatible.count)
    intro index positive bounded mutable declared
    rw [ActiveFlow.refine_model]
    apply Integer.Ranges.refineName_other
    intro same
    rcases allowed with zero | mutableTarget | lexical
    · omega
    · rw [← same, mutable] at mutableTarget
      contradiction
    · omega
  · simpa only [ActiveFlow.refine_model] using Integer.Ranges.refineName_bounded
      (index := target) (operator := operator) (threshold := threshold) (truth := truth) ready.bounded
  · simpa only [ActiveFlow.refine_model] using Integer.Ranges.refineName_refines
      (index := target) (operator := operator) (threshold := threshold) (truth := truth) ready.contained
  · intro index bounds mutable found
    rw [ActiveFlow.refine_model] at found
    change flow.model.scalars.refineName target operator threshold truth index = some bounds at found
    cases present : flow.model.scalars index with
    | none =>
        rw [Integer.Ranges.refineName_none present] at found
        contradiction
    | some incoming =>
        obtain ⟨result, resultFound, nonempty⟩ := Integer.Ranges.refineName_nonempty
          (target := target) (operator := operator) (threshold := threshold) (truth := truth)
          ⟨incoming, present, ready.mutableNonempty index incoming mutable present⟩
        rw [resultFound] at found
        cases found
        exact nonempty

theorem FlowReady.join {names declarations left right}
    (base : BaseReady names declarations) (a : FlowReady names declarations left)
    (b : FlowReady names declarations right) : FlowReady names declarations (left.join right) := by
  refine ⟨?_, ?_, ?_, ?_⟩
  · apply overlayCompatible_of_preserved a.compatible
      ((ActiveFlow.join_count _ _ (a.compatible.count.trans b.compatible.count.symm)).trans a.compatible.count)
    intro index positive bounded mutable declared
    have l := a.compatible.fixed_cell index positive bounded mutable declared
    have r := b.compatible.fixed_cell index positive bounded mutable declared
    rw [ActiveFlow.join_model]
    exact (Integer.Ranges.join_fixed l r (base.declarationsNonempty index positive declared)).trans l.symm
  · simpa only [ActiveFlow.join_model, Flow.join] using Integer.Ranges.join_bounded a.bounded b.bounded
  · simpa only [ActiveFlow.join_model, Flow.join] using Integer.Ranges.join_refines a.contained b.contained
  · intro index bounds mutable found
    rw [ActiveFlow.join_model] at found
    change (left.model.scalars.join right.model.scalars) index = some bounds at found
    unfold Integer.Ranges.join at found
    split at found
    · rename_i l r leftFound rightFound
      cases found
      obtain ⟨result, resultFound, nonempty⟩ := Integer.Ranges.join_nonempty
        ⟨l, leftFound, a.mutableNonempty index l mutable leftFound⟩
        ⟨r, rightFound, b.mutableNonempty index r mutable rightFound⟩
      have same : result = l.join r := by
        simpa only [Integer.Ranges.join, leftFound, rightFound, Option.some.injEq] using resultFound.symm
      simpa only [same] using nonempty
    · contradiction

end ScalarMetadata

def ConditionResult.FlowReady (context : ParseContext) (result : ConditionResult) : Prop :=
  ScalarMetadata.FlowReady context.scalarNames context.declarationCount result.whenTrue ∧
    ScalarMetadata.FlowReady context.scalarNames context.declarationCount result.whenFalse

theorem invalidCondition_flowReady {context : ParseContext} {facts : ActiveFlow}
    (ready : ScalarMetadata.FlowReady context.scalarNames context.declarationCount facts) :
    (invalidCondition facts).FlowReady context := ⟨ready.withPath _, ready.withPath _⟩

private theorem bareTarget_allowed (text : Source) (context : ParseContext) (position after : Nat) :
    bareTarget text context position after = 0 ∨
      (ScalarExpression.binding context.scalarNames (bareTarget text context position after)).mutable = true ∨
      context.declarationCount < bareTarget text context position after := by
  unfold bareTarget
  dsimp only
  split
  · rename_i selected
    exact Or.inr (by simpa only [Bool.or_eq_true, decide_eq_true_eq] using selected.2.2)
  · exact Or.inl rfl

theorem scalarCondition_flowReady {text context position rightPosition facts left right operator}
    (ready : ScalarMetadata.FlowReady context.scalarNames context.declarationCount facts) :
    (scalarCondition text context position rightPosition facts left right operator).FlowReady context := by
  unfold scalarCondition ConditionResult.FlowReady
  dsimp only
  constructor <;> apply ScalarMetadata.FlowReady.refine ready
  all_goals
    split
    · exact bareTarget_allowed ..
    · split
      · exact bareTarget_allowed ..
      · exact Or.inl rfl

theorem chainContext_flowReady {context : ParseContext} {result : ConditionResult}
    (ready : result.FlowReady context) (operator : Bool) :
    ScalarMetadata.FlowReady context.scalarNames context.declarationCount (chainContext result operator) := by
  cases operator
  · exact ready.2
  · exact ready.1

theorem chainJoin_flowReady {context : ParseContext} {left right : ConditionResult}
    (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (a : left.FlowReady context) (b : right.FlowReady context) (operator : Bool) :
    (chainJoin left right operator).FlowReady context := by
  cases operator
  · exact ⟨ScalarMetadata.FlowReady.join base a.1 b.1, b.2⟩
  · exact ⟨b.1, ScalarMetadata.FlowReady.join base a.2 b.2⟩

mutual
  theorem primary_flowReady (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
      (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
      (ready : ScalarMetadata.FlowReady context.scalarNames context.declarationCount facts) :
      (readPrimary text context position facts).FlowReady context := by
    rw [readPrimary]
    split
    · exact invalidCondition_flowReady ready
    · try dsimp only
      split
      · split
        · try dsimp only
          split
          · exact invalidCondition_flowReady ready
          · exact condition_flowReady text context _ facts base ready
        · exact invalidCondition_flowReady ready
      · split
        · exact invalidCondition_flowReady ready
        · try dsimp only
          split
          · exact invalidCondition_flowReady ready
          · exact ⟨ready.withPath _, ready.withPath _⟩
  termination_by (remainingAt text position, 1)

  theorem relation_flowReady (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
      (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
      (ready : ScalarMetadata.FlowReady context.scalarNames context.declarationCount facts) :
      (readRelation text context position facts).FlowReady context := by
    rw [readRelation]
    split
    · exact invalidCondition_flowReady ready
    · try dsimp only
      split
      · split
        · have next := primary_flowReady text context (fixedAfter text position "not" true) facts base ready
          exact ⟨next.2, next.1⟩
        · exact invalidCondition_flowReady ready
      · try dsimp only
        split
        · try dsimp only
          split
          · exact invalidCondition_flowReady ready
          · exact ⟨ready.withPath _, ready.withPath _⟩
        · try dsimp only
          split
          · try dsimp only
            split
            · exact invalidCondition_flowReady ready
            · exact scalarCondition_flowReady ready
          · try dsimp only
            split
            · try dsimp only
              split
              · exact invalidCondition_flowReady ready
              · try dsimp only
                split
                · exact invalidCondition_flowReady ready
                · try dsimp only
                  by_cases equal : (comparisonAt text
                    (expressionAt text position context.names (context.readingNames facts)).after).operator == Comparison.eq
                  · simp only [equal, ↓reduceIte]
                    exact ⟨ready.withPath _, ready⟩
                  · simp only [equal, Bool.false_eq_true, ↓reduceIte]
                    exact ⟨ready, ready.withPath _⟩
            · exact primary_flowReady text context position facts base ready
  termination_by (remainingAt text position, 2)

  theorem tail_flowReady (text : Source) (context : ParseContext) (result : ConditionResult)
      (chained : Option Bool) (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
      (ready : result.FlowReady context) :
      (conditionTail text context result chained).FlowReady context := by
    rw [conditionTail]
    split
    · exact invalidCondition_flowReady ready.1
    · split
      · exact ready
      · try dsimp only
        split
        · exact invalidCondition_flowReady ready.1
        · try dsimp only
          split
          · exact invalidCondition_flowReady ready.1
          · split
            · try dsimp only
              split
              · exact invalidCondition_flowReady ready.1
              · try dsimp only
                split
                · exact tail_flowReady text context _ _ base
                    (chainJoin_flowReady base ready
                      (relation_flowReady text context _ _ base (chainContext_flowReady ready _)) _)
                · exact invalidCondition_flowReady ready.1
            · exact invalidCondition_flowReady ready.1
  termination_by (remainingAt text result.after, 4)

  theorem condition_flowReady (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow)
      (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
      (ready : ScalarMetadata.FlowReady context.scalarNames context.declarationCount facts) :
      (readCondition text context position facts).FlowReady context := by
    rw [readCondition]
    split
    · exact invalidCondition_flowReady ready
    · split
      · try dsimp only
        split
        · exact invalidCondition_flowReady ready
        · exact tail_flowReady text context _ none base (relation_flowReady text context position facts base ready)
      · exact invalidCondition_flowReady ready
  termination_by (remainingAt text position, 3)
end

end Silver.Predicate
