module

public import Silver.PredicateNativeContracts
public import Silver.PredicateNativeSizing

@[expose] public section

namespace Silver.Predicate.Native

/-- The interpretation of each constrained native model checks its allocation
and aggregate extents before projecting the redundant discriminant. -/
structure SizedModels (calls : Calls) : Prop where
  primary : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    primaryBody.Sized calls ({text, context, position, facts} : Inputs).locals
  relation : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    relationBody.Sized calls ({text, context, position, facts} : Inputs).locals
  model : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    modelBody.Sized calls ({text, context, position, facts} : Inputs).locals
  tail : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ result,
    ValidResult text context result → ∀ operator, operator.isChain = true → ∀ chained,
    tailBody.Sized calls ({text, context, result, operator, chained} : Inputs).locals

private theorem count_with_path (facts : ActiveFlow) (path : PathFacts.Context) :
    ({facts with path} : ActiveFlow).count = facts.count := rfl

private theorem primary_true_count (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow) :
    (readPrimary text context position facts).whenTrue.count = facts.count := (primary_counts ..).1
private theorem primary_false_count (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow) :
    (readPrimary text context position facts).whenFalse.count = facts.count := (primary_counts ..).2
private theorem relation_true_count (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow) :
    (readRelation text context position facts).whenTrue.count = facts.count := (relation_counts ..).1
private theorem relation_false_count (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow) :
    (readRelation text context position facts).whenFalse.count = facts.count := (relation_counts ..).2

set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

theorem model_sizedModels : SizedModels modelCalls where
  primary text _ context _ position _ facts _ := by
    simp only [primaryBody, Expr.Sized, Expr.declared, Expr.eval,
      Inputs.locals, Locals.set, Calls.get, Field.get, modelCalls,
      Expr.callTake, Expr.callModel, Expr.callOperation, Expr.callAssumeValid, Expr.callAssumeInvalid,
      condition_counts, invalidCondition_counts, count_with_path]
    simp
  relation text _ context _ position _ facts _ := by
    simp only [relationBody, Expr.Sized, Expr.declared, Expr.declaredCondition, Expr.eval,
      Inputs.locals, Locals.set, Calls.get, Field.get, modelCalls,
      Expr.callTake, Expr.callLength, Expr.callScalarInFlow, Expr.callPrimary,
      Expr.callStringInFlow, Expr.callComparison, Expr.callScalarCondition, Expr.callSummary,
      Expr.callFits, Expr.callRefineEqual, Expr.callRefineBounds,
      primary_counts, invalidCondition_counts, ConditionResult.count, count_with_path]
    simp [primary_true_count, primary_false_count]
  model text _ context _ position _ facts _ := by
    have finalCounts : (conditionTail text context.model (readRelation text context.model position facts) none).Counts facts.count :=
      tail_counts text context.model _ none (relation_counts text context.model position facts)
    simp only [modelBody, Expr.Sized, Expr.declaredCondition, Expr.eval,
      Inputs.locals, Locals.set, Calls.get, Field.get, modelCalls,
      Expr.callRelation, Expr.callTail, chainState,
      relation_counts, invalidCondition_counts]
    simp [finalCounts]
  tail text _ context _ result valid operator _ chained := by
    have same : result.whenTrue.count = result.whenFalse.count :=
      valid.2.1.2.compatible.count.trans valid.2.2.2.compatible.count.symm
    simp only [tailBody, Expr.Sized, Expr.declared, Expr.declaredCondition, Expr.eval,
      Inputs.locals, Locals.set, Calls.get, Field.get, modelCalls,
      Expr.callChainToken, Expr.callChainAfter, Expr.callRelation, Expr.callTail, Expr.callJoin]
    by_cases selected : chainTokenModel text result.after = .andKeyword <;>
      simp [selected, ConditionResult.count, ConditionResult.Counts, invalidCondition,
        relation_true_count, relation_false_count, same, ActiveFlow.join_count]

end Silver.Predicate.Native
