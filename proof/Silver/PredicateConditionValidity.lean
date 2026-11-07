module

public import Silver.PredicateConditionReadings
public import Silver.PredicateConditionMeaning
public import Silver.PathBounds
public import Silver.PredicateFlowInvariant
public import Silver.PredicateConditionFlow
public import Silver.PredicateScalarGuardMeaning
public import Silver.ArrayBindingsNativeEquations

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
  | @binding index info name after _ _ found _ _ _ _ _ =>
      have nonzero : index ≠ 0 := by intro zero; simp [Bindings.BindingEnvironment.get, zero] at found
      have member : info ∈ context.names := List.mem_of_getElem? (by
        simpa only [Bindings.BindingEnvironment.get, nonzero, ↓reduceIte] using found)
      have infoValid := namesValid.2 info member
      unfold BindingInfo.bound
      split
      · exact fitsSummary_argument bounded
      · exact fitsSummary_fixed infoValid.2.2

private theorem length_meaning {text context position facts left right leftResult rightResult initials}
    (namesValid : Compose.Expressions.ValidNames text context.names) (bounded : facts.path.Bounded)
    (leftRead : LengthAt text context position false (.binding left) leftResult)
    (rightRead : LengthAt text context (comparisonAt text leftResult.after).after true right rightResult) :
    ConditionMeaning context facts (.lengthCompare (comparisonAt text leftResult.after).operator left right)
      ⟨rightResult.after,
        refineFlowBounds facts (comparisonAt text leftResult.after).operator leftResult.value rightResult.value true,
        refineFlowBounds facts (comparisonAt text leftResult.after).operator leftResult.value rightResult.value false⟩ initials := by
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

private theorem string_meaning {text context position facts left right leftResult rightResult initials}
    (normal : NamesNormal context.names)
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount facts)
    (leftRead : ExpressionAt (scalarNames := context.readingNames facts) (arrays := context.arrayNames) (initials := initials) (elaborating := context.elaborating) (integerHidden := context.integerHidden text) text context.names position left leftResult)
    (rightRead : ExpressionAt (scalarNames := context.readingNames facts) (arrays := context.arrayNames) (initials := initials) (elaborating := context.elaborating) (integerHidden := context.integerHidden text) text context.names (comparisonAt text leftResult.after).after right rightResult)
    (ready : StringRelationReady facts leftResult rightResult (comparisonAt text leftResult.after)) :
    ConditionMeaning context facts (.stringCompare ((comparisonAt text leftResult.after).operator != .eq) left right)
      (stringResult facts leftResult rightResult (comparisonAt text leftResult.after)) initials := by
  have l := expression_reading_ready normal leftRead
  have r := expression_reading_ready normal rightRead
  have ranges := context.reading_ranges compatible initials
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

theorem ConditionMeaning.compatible {context facts condition result initials}
    (base : ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating)
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount facts)
    (meaning : ConditionMeaning context facts condition result initials)
    (trueCount : result.whenTrue.count = context.scalarNames.length)
    (falseCount : result.whenFalse.count = context.scalarNames.length) :
    ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount result.whenTrue ∧
      ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount result.whenFalse := by
  have preserved : ∀ index, 0 < index → index ≤ context.scalarNames.length →
      (ScalarExpression.binding context.scalarNames index).mutable = false → index ≤ context.declarationCount →
      ∀ truth, (condition.refine context.names.shape context.analysis (context.flow facts initials) truth).scalars index =
        (context.flow facts initials).scalars index := by
    intro index positive bounded mutable declared truth
    have readonly : context.analysis.refinable index = false := by
      simp only [ParseContext.analysis, ArrayFlow.analysis, ArrayBindings.integerRefinability,
        ArrayBindings.refinability_scalar _ _ (Nat.le_trans bounded base.size),
        ScalarMetadata.analysis, ScalarMetadata.refinable,
        mutable, Bool.false_or, show ¬context.declarationCount < index by omega,
        decide_false, Bool.and_false]
    have cell : (context.flow facts initials).scalars index = some (ScalarExpression.binding context.scalarNames index).bounds := by
      rw [context.flow_scalar facts (Nat.le_trans bounded base.size) initials]
      exact compatible.fixed_cell index positive bounded mutable declared
    exact (condition.refine_preserves_fixed readonly cell
      (base.declarationsNonempty index positive declared)).trans cell.symm
  constructor
  · apply ScalarMetadata.overlayCompatible_of_preserved compatible trueCount
    intro index positive bounded mutable declared
    rw [← context.flow_scalar result.whenTrue (Nat.le_trans bounded base.size) initials, meaning.whenTrue,
      ← context.flow_scalar facts (Nat.le_trans bounded base.size) initials]
    exact preserved index positive bounded mutable declared true
  · apply ScalarMetadata.overlayCompatible_of_preserved compatible falseCount
    intro index positive bounded mutable declared
    rw [← context.flow_scalar result.whenFalse (Nat.le_trans bounded base.size) initials, meaning.whenFalse,
      ← context.flow_scalar facts (Nat.le_trans bounded base.size) initials]
    exact preserved index positive bounded mutable declared false

theorem booleanArray_reading_meaning {text context position facts condition after initials}
    (base : ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating)
    (arraysReady : context.ArraysReady text)
    (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount facts)
    (parsed : BooleanArrayAt text context position facts condition after) :
    ConditionMeaning context facts condition ⟨after, facts, facts⟩ initials := by
  cases parsed with
  | @read index subscript target kind _ _ reading _ inside _ =>
    have targetBound := ArrayBindings.Native.lookup_bound text context.arrayNames
      (skipAt text position) (nameAfter text (skipAt text position))
    have member := ArrayBindings.Native.binding_mem (Nat.pos_of_ne_zero target) targetBound
    have valid := (arraysReady.1.2.1 _ member).2.2.2
    have initialized := ArrayBindings.booleanAnalysis_initialized member kind
      (BooleanBindings.analysis context.booleanNames)
    have inferred : index.infer (context.flow facts initials).scalars = some subscript.bounds := by
      rw [← context.reading_ranges compatible initials]
      have same : index.infer (ArrayBindings.integerRanges context.arrayNames initials context.elaborating
            (ScalarExpression.ranges (context.readingNames facts))) =
          index.infer (ScalarExpression.ranges (context.readingNames facts)) := by
        apply Integer.Expr.infer_readsOnly (ScalarExpression.syntax_readsOnly reading.grammar)
        intro scalar allowed
        exact ArrayBindings.ranges_scalar _ _ _ _ (by
          have active : scalar ≤ context.scalarNames.length := by
            simpa only [ParseContext.readingNames, ScalarMetadata.readingNames_length] using allowed.2
          exact Nat.le_trans active base.size)
      rw [same]
      simpa only [ArrayBindings.integerRanges, ArrayBindings.integerNames, List.filter_nil, ArrayBindings.ranges_nil] using reading.inferred
    refine ⟨trivial, initialized, ?_, rfl, rfl⟩
    simp only [Condition.checkBounds, initialized, Bool.true_and,
      Boolean.ArrayDescriptor.checkIndex, inferred]
    have layoutValid : (ArrayBindings.binding context.arrayNames
        (ArrayBindings.lookup text context.arrayNames (skipAt text position)
          (nameAfter text (skipAt text position)))).booleanDescriptor.layout.Valid :=
      ArrayBindings.binding_booleanDescriptor_valid valid
    simp only [Integer.arrayIndexCheck, layoutValid, true_and]
    exact inside


mutual
  theorem primary_valid {text context position facts condition result initials}
      (normal : NamesNormal context.names) (namesValid : Compose.Expressions.ValidNames text context.names)
      (base : ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating)
      (arraysReady : context.ArraysReady text)
      (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount facts)
      (bounded : facts.path.Bounded) (parsed : PrimaryAt text context position facts condition result initials) :
      ConditionMeaning context facts condition result initials ∧ condition.isPrimary = true := by
    cases parsed with
    | group _ _ _ inner _ =>
        have meaning := condition_valid normal namesValid base arraysReady compatible bounded inner
        exact ⟨meaning.parenthesized _, rfl⟩
    | boolean _ _ _ _ _ atom =>
        cases atom with
        | name _ found =>
            have initialized : (ArrayBindings.booleanAnalysis context.arrayNames
                (BooleanBindings.analysis context.booleanNames)).initialized
                (BooleanBindings.lookup text context.booleanNames (skipAt text position)
                  (nameAfter text (skipAt text position))) = true := by
              apply Bool.or_eq_true_iff.mpr
              exact Or.inr (BooleanBindings.lookup_initialized found)
            exact ⟨⟨trivial, initialized, initialized, rfl, rfl⟩, rfl⟩
        | literal => exact ⟨⟨trivial, trivial, rfl, rfl, rfl⟩, rfl⟩
    | valid _ _ _ _ arguments _ =>
        exact ⟨⟨trivial, arguments, rfl, rfl, rfl⟩, rfl⟩
    | booleanArray _ _ _ _ atom =>
        refine ⟨booleanArray_reading_meaning base arraysReady compatible atom, ?_⟩
        cases atom
        rfl

  termination_by (remainingAt text position, 1)
  decreasing_by all_goals exact Prod.Lex.left _ _ (by assumption)

  theorem booleanFactor_valid {text context position facts condition result initials}
      (normal : NamesNormal context.names) (namesValid : Compose.Expressions.ValidNames text context.names)
      (base : ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating)
      (arraysReady : context.ArraysReady text)
      (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount facts)
      (bounded : facts.path.Bounded) (parsed : BooleanFactorAt text context position facts condition result initials) :
      ConditionMeaning context facts condition result initials ∧ condition.isFactor = true := by
    cases parsed with
    | primary _ inner =>
        have meaning := primary_valid normal namesValid base arraysReady compatible bounded inner
        refine ⟨meaning.1, ?_⟩
        cases condition <;> simp_all [Condition.isPrimary, Condition.isFactor]
    | negated _ _ inner =>
        have meaning := primary_valid normal namesValid base arraysReady compatible bounded inner
        exact ⟨meaning.1.negated meaning.2, meaning.2⟩
  termination_by (remainingAt text position, 2)
  decreasing_by all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem booleanRelation_valid {text context position facts condition result initials}
      (normal : NamesNormal context.names) (namesValid : Compose.Expressions.ValidNames text context.names)
      (base : ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating)
      (arraysReady : context.ArraysReady text)
      (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount facts)
      (bounded : facts.path.Bounded) (parsed : BooleanRelationAt text context position facts condition result initials) :
      ConditionMeaning context facts condition result initials ∧ condition.isRelation = true := by
    cases parsed with
    | factor inner _ _ =>
        have meaning := booleanFactor_valid normal namesValid base arraysReady compatible bounded inner
        refine ⟨meaning.1, ?_⟩
        cases condition <;> simp_all [Condition.isPrimary, Condition.isFactor, Condition.isRelation]
    | comparison left _ _ _ _ right _ =>
        have l := booleanFactor_valid normal namesValid base arraysReady compatible bounded left
        have r := booleanFactor_valid normal namesValid base arraysReady compatible bounded right
        exact ⟨l.1.booleanCompare r.1 l.2 r.2 _, rfl⟩
  termination_by (remainingAt text position, 3)
  decreasing_by all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem relation_valid {text context position facts condition result initials}
      (normal : NamesNormal context.names) (namesValid : Compose.Expressions.ValidNames text context.names)
      (base : ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating)
      (arraysReady : context.ArraysReady text)
      (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount facts)
      (bounded : facts.path.Bounded) (parsed : RelationAt text context position facts condition result initials) :
      ConditionMeaning context facts condition result initials ∧ condition.isRelation = true := by
    cases parsed with
    | booleanNot _ _ inner => exact booleanRelation_valid normal namesValid base arraysReady compatible bounded inner
    | length _ _ _ left right _ => exact ⟨length_meaning namesValid bounded left right, rfl⟩
    | scalars _ _ _ _ left right _ =>
        have ranges := context.reading_ranges compatible initials
        exact ⟨⟨trivial, trivial, by
          have l := left.inferred
          have r := right.inferred
          simp only [Condition.checkBounds, ← ranges, l, r, Option.isSome_some, Bool.and_self],
          scalarCondition_whenTrue_model base.size compatible left right,
          scalarCondition_whenFalse_model base.size compatible left right⟩, rfl⟩
    | strings _ _ _ _ left right ready _ => exact ⟨string_meaning normal compatible left right ready, rfl⟩
    | character _ _ _ _ _ inner =>
        obtain ⟨grammar, readable, checked, yes, no⟩ := characterRelation_meaning normal compatible inner
        refine ⟨⟨grammar, readable, checked, yes, no⟩, ?_⟩
        cases inner
        rfl
    | primary _ _ _ _ _ _ inner => exact booleanRelation_valid normal namesValid base arraysReady compatible bounded inner

  termination_by (remainingAt text position, 4)
  decreasing_by all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)

  theorem chain_valid {text context condition result chained final finalResult facts initials originalStart}
      (normal : NamesNormal context.names) (namesValid : Compose.Expressions.ValidNames text context.names)
      (base : ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating)
      (arraysReady : context.ArraysReady text)
      (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount facts)
      (bounded : facts.path.Bounded) (parsed : ChainAt text context condition result chained final finalResult facts initials originalStart)
      (meaning : ConditionMeaning context facts condition result initials) (shape : ChainShape chained condition)
      (counts : result.Counts facts.count) : ConditionMeaning context facts final finalResult initials := by
    cases parsed with
    | done => exact meaning
    | @next _ _ condition result chained operator right rightResult final finalResult _ _ _ compatibleChain _ _ _ rightRead _ _ _ rest =>
        have outputs := meaning.compatible base compatible
          (counts.1.trans compatible.count) (counts.2.trans compatible.count)
        have reachedCompatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount
            (chainContext result operator facts) := by
          cases operator
          · exact outputs.1
          · exact outputs.2
          all_goals exact compatible
        have reachedBound : (chainContext result operator facts).path.Bounded := by
          cases operator with
          | shortAnd =>
              change (context.flow result.whenTrue initials).path.Bounded
              rw [meaning.whenTrue]
              exact Condition.refine_bounded bounded _ _ _ _
          | shortOr =>
              change (context.flow result.whenFalse initials).path.Bounded
              rw [meaning.whenFalse]
              exact Condition.refine_bounded bounded _ _ _ _
          | eagerAnd | eagerOr | eagerXor => exact bounded
        have rightMeaning := relation_valid normal namesValid base arraysReady reachedCompatible reachedBound rightRead
        have rightCounts : rightResult.Counts facts.count := by
          have counted := relation_counts text context (chainAfter text result.after operator)
            (chainContext result operator facts) initials
          rw [relation_complete rightRead] at counted
          simpa only [chainContext_count counts operator facts rfl] using counted
        have nextMeaning := meaning.chain rightMeaning.1 (chainShape_selected shape compatibleChain) rightMeaning.2
        exact chain_valid normal namesValid base arraysReady compatible bounded rest nextMeaning (chainShape_next _ _ _)
          (chainJoin_counts counts rightCounts operator facts rfl)
  termination_by (remainingAt text result.after, 6)
  decreasing_by all_goals exact Prod.Lex.left _ _ (by assumption)

  theorem condition_valid {text context position facts condition result initials}
      (normal : NamesNormal context.names) (namesValid : Compose.Expressions.ValidNames text context.names)
      (base : ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating)
      (arraysReady : context.ArraysReady text)
      (compatible : ScalarMetadata.OverlayCompatible context.scalarNames context.declarationCount facts)
      (bounded : facts.path.Bounded) (parsed : ConditionAt text context position facts condition result initials) :
      ConditionMeaning context facts condition result initials := by
    cases parsed with
    | condition _ first _ _ tail =>
        have meaning := relation_valid normal namesValid base arraysReady compatible bounded first
        have counts := relation_counts text context position facts initials
        rw [relation_complete first] at counts
        exact chain_valid normal namesValid base arraysReady compatible bounded tail meaning.1 meaning.2 counts
  termination_by (remainingAt text position, 5)
  decreasing_by all_goals first | exact Prod.Lex.left _ _ (by assumption) | exact Prod.Lex.right _ (by decide)
end

end Silver.Predicate
