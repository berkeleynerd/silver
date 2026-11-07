module

public import Silver.PredicateNativeContracts
public import Silver.PredicateNativeSizing

@[expose] public section

namespace Silver.Predicate.Native

/-- The interpretation of each constrained native model checks its allocation
and aggregate extents before projecting the redundant discriminant. -/
structure SizedModels (calls : Calls) : Prop where
  character : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    ∀ initials, ArrayBindings.ValidInitials initials →
    characterBody.Sized calls ({text, context, position, facts, initials} : Inputs).locals
  primary : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    ∀ initials, ArrayBindings.ValidInitials initials →
    primaryBody.Sized calls ({text, context, position, facts, initials} : Inputs).locals
  booleanFactor : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    ∀ initials, ArrayBindings.ValidInitials initials →
    booleanFactorBody.Sized calls ({text, context, position, facts, initials} : Inputs).locals
  booleanRelation : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    ∀ initials, ArrayBindings.ValidInitials initials →
    booleanRelationBody.Sized calls ({text, context, position, facts, initials} : Inputs).locals
  relation : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    ∀ initials, ArrayBindings.ValidInitials initials →
    relationBody.Sized calls ({text, context, position, facts, initials} : Inputs).locals
  model : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    ∀ initials, ArrayBindings.ValidInitials initials →
    modelBody.Sized calls ({text, context, position, facts, initials} : Inputs).locals
  tail : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ result,
    ValidResult text context result → ∀ operator, operator.isChain = true → ∀ chained,
    ∀ initials, ArrayBindings.ValidInitials initials → ∀ incoming, ValidFlow context incoming →
    ∀ originalStart, originalStart ≤ text.length + 1 →
    tailBody.Sized calls ({text, context, result, operator, chained, initials, incoming, originalStart} : Inputs).locals

private theorem count_with_path (facts : ActiveFlow) (path : PathFacts.Context) :
    ({facts with path} : ActiveFlow).count = facts.count := rfl

private theorem primary_true_count (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow) (initials : ArrayBindings.Initials) :
    (readPrimary text context position facts initials).whenTrue.count = facts.count := (primary_counts text context position facts initials).1
private theorem primary_false_count (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow) (initials : ArrayBindings.Initials) :
    (readPrimary text context position facts initials).whenFalse.count = facts.count := (primary_counts text context position facts initials).2
private theorem relation_true_count (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow) (initials : ArrayBindings.Initials) :
    (readRelation text context position facts initials).whenTrue.count = facts.count := (relation_counts text context position facts initials).1
private theorem relation_false_count (text : Source) (context : ParseContext) (position : Nat) (facts : ActiveFlow) (initials : ArrayBindings.Initials) :
    (readRelation text context position facts initials).whenFalse.count = facts.count := (relation_counts text context position facts initials).2

private theorem booleanFactor_true_count (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) (initials : ArrayBindings.Initials) :
    (readBooleanFactor text context position facts initials).whenTrue.count = facts.count := (booleanFactor_counts text context position facts initials).1
private theorem booleanFactor_false_count (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) (initials : ArrayBindings.Initials) :
    (readBooleanFactor text context position facts initials).whenFalse.count = facts.count := (booleanFactor_counts text context position facts initials).2
private theorem booleanRelation_true_count (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) (initials : ArrayBindings.Initials) :
    (readBooleanRelation text context position facts initials).whenTrue.count = facts.count := (booleanRelation_counts text context position facts initials).1
private theorem booleanRelation_false_count (text : Source) (context : ParseContext) (position : Nat)
    (facts : ActiveFlow) (initials : ArrayBindings.Initials) :
    (readBooleanRelation text context position facts initials).whenFalse.count = facts.count := (booleanRelation_counts text context position facts initials).2
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

theorem model_sizedModels : SizedModels modelCalls where
  character text _ context _ position _ facts _ initials _ := by
    simp only [characterBody, Expr.Sized, Expr.eval,
      Inputs.locals, Locals.set, Calls.get, Field.get, modelCalls,
      Expr.callReadingNames, Expr.callCharacterAt, Expr.callComparison, count_with_path]
    simp
  primary text _ context _ position _ facts _ initials _ := by
    simp only [primaryBody, Expr.Sized, Expr.declared, Expr.eval,
      Inputs.locals, Locals.set, Calls.get, Field.get, modelCalls,
      Expr.callTake, Expr.callModel, Expr.callBooleanArray, Expr.callBooleanAtom, Expr.callNameIs, Expr.callOperation, Expr.callAssumeValid, Expr.callAssumeInvalid,
      condition_counts, invalidCondition_counts, count_with_path]
    simp
  booleanFactor text _ context _ position _ facts _ initials _ := by
    simp only [booleanFactorBody, Expr.Sized, Expr.declaredCondition, Expr.eval,
      Inputs.locals, Locals.set, Calls.get, Field.get, modelCalls,
      Expr.callTake, primary_counts,
      ConditionResult.count]
    simp [primary_true_count, primary_false_count]
  booleanRelation text _ context _ position _ facts _ initials _ := by
    simp only [booleanRelationBody, Expr.Sized, Expr.declaredCondition, Expr.eval,
      Inputs.locals, Locals.set, Calls.get, Field.get, modelCalls,
      Expr.callBooleanFactor, Expr.callComparison, booleanFactor_counts,
      invalidCondition_counts]
    simp
  relation text _ context _ position _ facts _ initials _ := by
    simp only [relationBody, Expr.Sized, Expr.declared, Expr.eval,
      Inputs.locals, Locals.set, Calls.get, Field.get, modelCalls,
      Expr.callTake, Expr.callLength, Expr.callScalarInFlow, Expr.callBooleanRelation, Expr.callCharacterCondition,
      Expr.callStringInFlow, Expr.callComparison, Expr.callScalarCondition, Expr.callSummary,
      Expr.callFits, Expr.callRefineEqual, Expr.callRefineBounds,
      invalidCondition_counts, count_with_path]
    simp
  model text _ context _ position _ facts _ initials _ := by
    have finalCounts : (conditionTail text context.model (readRelation text context.model position facts initials) none facts initials position).Counts facts.count :=
      tail_counts text context.model _ none facts (relation_counts text context.model position facts initials) rfl initials position
    simp only [modelBody, Expr.Sized, Expr.declaredCondition, Expr.eval,
      Inputs.locals, Locals.set, Calls.get, Field.get, modelCalls,
      Expr.callRelation, Expr.callTail, chainState,
      relation_counts, invalidCondition_counts]
    simp [finalCounts]
  tail text _ context _ result valid operator _ chained initials _ incoming incomingValid originalStart _ := by
    have same : result.whenTrue.count = result.whenFalse.count :=
      valid.2.1.2.compatible.count.trans valid.2.2.2.compatible.count.symm
    have incomingSame : incoming.count = result.whenTrue.count :=
      incomingValid.2.compatible.count.trans valid.2.1.2.compatible.count.symm
    simp only [tailBody, Expr.Sized, Expr.declared, Expr.declaredCondition, Expr.eval,
      Inputs.locals, Locals.set, Calls.get, Field.get, modelCalls,
      Expr.callChainToken, Expr.callChainAfter, Expr.callRelation, Expr.callTail, Expr.callJoin, Expr.callXorFree]
    cases selected : chainTokenModel text result.after <;>
      simp [ConditionResult.count, ConditionResult.Counts, invalidCondition,
        relation_true_count, relation_false_count, same, incomingSame, ActiveFlow.join_count]

end Silver.Predicate.Native
