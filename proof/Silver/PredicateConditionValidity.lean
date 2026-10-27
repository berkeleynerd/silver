module

public import Silver.PredicateConditionSound
public import Silver.PredicateConditionMeaning
public import Silver.PathBounds
public import Silver.PredicateFlowInvariant
public import Silver.PredicateConditionFlow
public import Silver.PredicateScalarGuardMeaning

@[expose] public section

namespace Silver.Predicate
open Compose Bindings PathFacts

set_option backward.dsimp.instances true

private theorem lengthAt_fits {text context position literal operand result facts}
    (namesValid : Compose.Expressions.ValidNames text context.names) (bounded : facts.Bounded)
    (parsed : LengthAt text context position literal operand result) :
    fitsSummary facts result.value.summary = true := by
  cases parsed with
  | number _ number => exact fitsSummary_fixed (IntegerLiteral.integer_bounds number).2.2
  | @binding index info name after _ _ found _ _ _ _ =>
      have nonzero : index ≠ 0 := by intro zero; simp [Bindings.BindingEnvironment.get, zero] at found
      have member : info ∈ context.names := List.mem_of_getElem? (by
        simpa only [Bindings.BindingEnvironment.get, nonzero, ↓reduceIte] using found)
      have infoValid := namesValid.2 info member
      unfold BindingInfo.bound
      split
      · exact fitsSummary_argument bounded
      · exact fitsSummary_fixed infoValid.2.2

private theorem length_meaning {text context position facts left right leftResult rightResult}
    (namesValid : Compose.Expressions.ValidNames text context.names) (bounded : facts.path.Bounded)
    (leftRead : LengthAt text context position false (.binding left) leftResult)
    (rightRead : LengthAt text context (comparisonAt text leftResult.after).after true right rightResult) :
    ConditionMeaning context facts (.lengthCompare (comparisonAt text leftResult.after).operator left right)
      ⟨rightResult.after,
        refineFlowBounds facts (comparisonAt text leftResult.after).operator leftResult.value rightResult.value true,
        refineFlowBounds facts (comparisonAt text leftResult.after).operator leftResult.value rightResult.value false⟩ := by
  have leftReading := lengthAt_readable leftRead
  have rightReading := lengthAt_readable rightRead
  obtain ⟨info, found⟩ := leftReading.1
  have leftBound : info.bound = leftResult.value := by
    simpa only [LengthOperand.bound, found, Option.map_some, Option.some.injEq] using leftReading.2
  refine ⟨trivial, ⟨⟨info, found⟩, rightReading.1⟩, ?_, ?_, ?_⟩
  · simp only [Condition.checkBounds, found, rightReading.2, leftBound, ParseContext.flow_path,
      lengthAt_fits namesValid bounded leftRead, lengthAt_fits namesValid bounded rightRead, Bool.and_self]
  · simp only [Condition.refine, refineLength, found, rightReading.2, leftBound,
      refineFlowBounds, ParseContext.flow_withPath, ParseContext.flow_path]
  · simp only [Condition.refine, refineLength, found, rightReading.2, leftBound,
      refineFlowBounds, ParseContext.flow_withPath, ParseContext.flow_path]

private theorem string_meaning {text context position facts left right leftResult rightResult}
    (normal : NamesNormal context.names)
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount facts)
    (leftRead : ExpressionAt (scalarNames := context.readingNames facts) (arrays := context.arrayNames) text context.names position left leftResult)
    (rightRead : ExpressionAt (scalarNames := context.readingNames facts) (arrays := context.arrayNames) text context.names (comparisonAt text leftResult.after).after right rightResult)
    (ready : StringRelationReady facts leftResult rightResult (comparisonAt text leftResult.after)) :
    ConditionMeaning context facts (.stringCompare ((comparisonAt text leftResult.after).operator != .eq) left right)
      (stringResult facts leftResult rightResult (comparisonAt text leftResult.after)) := by
  have l := expression_reading_ready normal leftRead
  have r := expression_reading_ready normal rightRead
  have ranges := context.reading_ranges compatible
  rw [ranges] at l r
  have leftInferred := l.2
  have rightInferred := r.2

  refine ⟨trivial, ⟨l.1.1, r.1.1, l.1.2.1, r.1.2.1,
    l.1.2.2.1, l.1.2.2.2, r.1.2.2.1, r.1.2.2.2⟩, ?_, ?_, ?_⟩
  · simp only [Condition.checkBounds, l.2, r.2, Bool.and_eq_true]
    exact ⟨ready.2.2.2.2.2.1, ready.2.2.2.2.2.2⟩
  · rcases ready.2.2.1 with equal | equal <;>
      simp [stringResult, summaryOf, Condition.refine, refineString, equal,
        leftInferred, rightInferred, ParseContext.flow_withPath, ParseContext.flow_path] <;> rfl
  · rcases ready.2.2.1 with equal | equal <;>
      simp [stringResult, summaryOf, Condition.refine, refineString, equal,
        leftInferred, rightInferred, ParseContext.flow_withPath, ParseContext.flow_path] <;> rfl

theorem ConditionMeaning.compatible {context facts condition result}
    (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount facts)
    (meaning : ConditionMeaning context facts condition result)
    (trueCount : result.whenTrue.count = context.scalarNames.length)
    (falseCount : result.whenFalse.count = context.scalarNames.length) :
    ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount result.whenTrue ∧
      ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount result.whenFalse := by
  have preserved : ∀ index, 0 < index → index ≤ context.scalarNames.length →
      (ScalarExpression.binding context.scalarNames index).mutable = false → index ≤ context.declarationCount →
      ∀ truth, (condition.refine context.names.shape context.analysis (context.flow facts) truth).scalars index =
        (context.flow facts).scalars index := by
    intro index positive bounded mutable declared truth
    have readonly : context.analysis.refinable index = false := by
      simp only [ParseContext.analysis, ArrayFlow.analysis,
        ArrayBindings.refinability_scalar _ _ (Nat.le_trans bounded base.size),
        ScalarMetadata.analysis, ScalarMetadata.refinable,
        mutable, Bool.false_or, show ¬context.declarationCount < index by omega,
        decide_false, Bool.and_false]
    have cell : (context.flow facts).scalars index = some (ScalarExpression.binding context.scalarNames index).bounds := by
      rw [context.flow_scalar facts (Nat.le_trans bounded base.size)]
      exact compatible.fixed_cell index positive bounded mutable declared
    exact (condition.refine_preserves_fixed readonly cell
      (base.declarationsNonempty index positive declared)).trans cell.symm
  constructor
  · apply ScalarMetadata.overlayCompatible_of_preserved compatible trueCount
    intro index positive bounded mutable declared
    rw [← context.flow_scalar result.whenTrue (Nat.le_trans bounded base.size), meaning.whenTrue,
      ← context.flow_scalar facts (Nat.le_trans bounded base.size)]
    exact preserved index positive bounded mutable declared true
  · apply ScalarMetadata.overlayCompatible_of_preserved compatible falseCount
    intro index positive bounded mutable declared
    rw [← context.flow_scalar result.whenFalse (Nat.le_trans bounded base.size), meaning.whenFalse,
      ← context.flow_scalar facts (Nat.le_trans bounded base.size)]
    exact preserved index positive bounded mutable declared false

mutual
  theorem primary_valid {text context position facts condition result}
      (normal : NamesNormal context.names) (namesValid : Compose.Expressions.ValidNames text context.names)
      (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
      (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount facts)
      (bounded : facts.path.Bounded) (parsed : PrimaryAt text context position facts condition result) :
      ConditionMeaning context facts condition result ∧ condition.isPrimary = true := by
    cases parsed with
    | group _ _ _ inner _ =>
        have meaning := condition_valid normal namesValid base compatible bounded inner
        exact ⟨meaning.parenthesized _, rfl⟩
    | valid _ _ arguments _ =>
        exact ⟨⟨trivial, arguments, rfl, rfl, rfl⟩, rfl⟩
  termination_by (remainingAt text position, 1)
  decreasing_by all_goals exact Prod.Lex.left _ _ (by assumption)

  theorem relation_valid {text context position facts condition result}
      (normal : NamesNormal context.names) (namesValid : Compose.Expressions.ValidNames text context.names)
      (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
      (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount facts)
      (bounded : facts.path.Bounded) (parsed : RelationAt text context position facts condition result) :
      ConditionMeaning context facts condition result ∧ condition.isRelation = true := by
    cases parsed with
    | negated _ _ _ inner =>
        have meaning := primary_valid normal namesValid base compatible bounded inner
        exact ⟨meaning.1.negated meaning.2, rfl⟩
    | length _ _ _ left right _ => exact ⟨length_meaning namesValid bounded left right, rfl⟩
    | scalars _ _ _ _ left right _ =>
        have ranges := context.reading_ranges compatible
        exact ⟨⟨trivial, trivial, by
          have l := left.inferred
          have r := right.inferred
          change Integer.Expr.infer (ArrayBindings.ranges context.arrayNames [] false
            (ScalarExpression.ranges (context.readingNames facts))) _ = _ at l r
          simp only [Condition.checkBounds, ← ranges, l, r,
            Option.isSome_some, Bool.and_self],
          scalarCondition_whenTrue_model base.size compatible left right,
          scalarCondition_whenFalse_model base.size compatible left right⟩, rfl⟩
    | strings _ _ _ _ left right ready _ =>
        exact ⟨string_meaning normal compatible left right ready, rfl⟩
    | primary _ _ _ _ _ inner =>
        have meaning := primary_valid normal namesValid base compatible bounded inner
        refine ⟨meaning.1, ?_⟩
        cases condition <;> simp_all [Condition.isPrimary, Condition.isRelation]
  termination_by (remainingAt text position, 2)
  decreasing_by all_goals simp_wf; all_goals first | assumption | omega

  theorem chain_valid {text context condition result chained final finalResult facts}
      (normal : NamesNormal context.names) (namesValid : Compose.Expressions.ValidNames text context.names)
      (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
      (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount facts)
      (bounded : facts.path.Bounded) (parsed : ChainAt text context condition result chained final finalResult)
      (meaning : ConditionMeaning context facts condition result) (shape : ChainShape chained condition)
      (counts : result.Counts facts.count) :
      ConditionMeaning context facts final finalResult := by
    cases parsed with
    | done => exact meaning
    | @next condition result chained operator right rightResult final finalResult _ _ _ compatibleChain _ _ rightRead _ _ rest =>
        have outputs := meaning.compatible base compatible
          (counts.1.trans compatible.count) (counts.2.trans compatible.count)
        have reachedCompatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount
            (chainContext result operator) := by
          cases operator
          · exact outputs.2
          · exact outputs.1
        have reachedBound : (chainContext result operator).path.Bounded := by
          cases operator with
          | false =>
              change (context.flow result.whenFalse).path.Bounded
              rw [meaning.whenFalse]
              exact Condition.refine_bounded bounded _ _ _ _
          | true =>
              change (context.flow result.whenTrue).path.Bounded
              rw [meaning.whenTrue]
              exact Condition.refine_bounded bounded _ _ _ _
        have rightMeaning := relation_valid normal namesValid base reachedCompatible reachedBound rightRead
        have rightCounts : rightResult.Counts facts.count := by
          have counted := relation_counts text context (chainAfter text result.after operator) (chainContext result operator)
          rw [relation_complete rightRead] at counted
          simpa only [chainContext_count counts] using counted
        have nextMeaning := meaning.chain rightMeaning.1 (chainShape_selected shape compatibleChain) rightMeaning.2
        exact chain_valid normal namesValid base compatible bounded rest nextMeaning (chainShape_next _ _ _)
          (chainJoin_counts counts rightCounts operator)
  termination_by (remainingAt text result.after, 4)
  decreasing_by all_goals exact Prod.Lex.left _ _ (by assumption)

  theorem condition_valid {text context position facts condition result}
      (normal : NamesNormal context.names) (namesValid : Compose.Expressions.ValidNames text context.names)
      (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
      (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount facts)
      (bounded : facts.path.Bounded) (parsed : ConditionAt text context position facts condition result) :
      ConditionMeaning context facts condition result := by
    cases parsed with
    | condition _ first _ _ tail =>
        have meaning := relation_valid normal namesValid base compatible bounded first
        have counts := relation_counts text context position facts
        rw [relation_complete first] at counts
        exact chain_valid normal namesValid base compatible bounded tail meaning.1 meaning.2 counts
  termination_by (remainingAt text position, 3)
  decreasing_by all_goals simp_wf; all_goals first | assumption | omega
end

end Silver.Predicate
