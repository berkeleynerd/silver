module

public import Silver.PredicateNativeModelSizing
public import Silver.PredicateNativeWorkers
public import Silver.ScalarExpressionNativeTypes

@[expose] public section
namespace Silver.Predicate.Native
open Compose Compose.Expressions

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

/-- Already established lexical, literal, expression and path-library meanings.
No predicate parser equivalence occurs in this interface. The path operations
are total mathematical interpretations of the checked native projections. -/
structure HelperMeaning (calls : Calls) : Prop where
  callAfter : ∀ text, ValidText text → ∀ names position operation scalarNames,
    ValidNames text names → ScalarExpression.ValidEnvironment text scalarNames → position ≤ text.length + 1 →
    calls.callAfter text names position operation scalarNames = Compose.callAfter text names position operation scalarNames
  take : ∀ text, ValidText text → ∀ position token, position ≤ text.length + 1 →
    calls.take text position token = takeModel text position token
  skip : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
    calls.skip text position = skipAt text position
  name : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
    calls.nameAfter text position = Compose.nameAfter text position
  lookup : ∀ text, ValidText text → ∀ names first after,
    ValidNames text names → first ≤ text.length + 1 → after ≤ text.length + 1 →
    calls.lookup text names first after = lookupName text names first after
  scalarLookup : ∀ text, ValidText text → ∀ names first after,
    ScalarExpression.ValidEnvironment text names → first ≤ text.length + 1 → after ≤ text.length + 1 →
    calls.scalarLookup text names first after = ScalarExpression.lookup text names first after
  scalarRead : ∀ text, ValidText text → ∀ position names, position ≤ text.length + 1 →
    ScalarExpression.ValidEnvironment text names →
    calls.scalarRead text position names = ScalarExpression.read text position names
  scalarInFlow : ∀ text, ValidText text → ∀ context, ValidContext text context →
    ∀ position facts, position ≤ text.length + 1 → ValidFlow context facts →
    calls.scalarInFlow text context position facts = ScalarExpression.read text position (context.model.readingNames facts)
  stringInFlow : ∀ text, ValidText text → ∀ context, ValidContext text context →
    ∀ position facts, position ≤ text.length + 1 → ValidFlow context facts →
    calls.stringInFlow text context position facts = expressionAt text position context.names (context.model.readingNames facts)
  scalarCondition : ∀ text, ValidText text → ∀ context, ValidContext text context →
    ∀ position rightPosition, position ≤ text.length + 1 → rightPosition ≤ text.length + 1 →
    ∀ facts, ValidFlow context facts → ∀ left right, left.after ≤ text.length + 1 → right.after ≤ text.length + 1 →
    ∀ operator, left.bounds.Bounded → right.bounds.Bounded → calls.scalarCondition text context position rightPosition facts left right operator =
      Predicate.scalarCondition text context.model position rightPosition facts left right operator
  invalidCondition : ∀ facts, facts.count ≤ ScalarExpression.maxBindings →
    calls.invalidCondition facts = Predicate.invalidCondition facts
  integer : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
    calls.integer text position = IntegerLiteral.read text position
  expression : ∀ text, ValidText text → ∀ position names scalarNames, position ≤ text.length + 1 → ValidNames text names →
    ScalarExpression.ValidEnvironment text scalarNames →
    calls.expression text position names scalarNames = expressionAt text position names scalarNames
  assumeValid : ∀ facts, calls.assumeValid facts = facts.assumeValid
  assumeInvalid : ∀ facts, calls.assumeInvalid facts = facts.assumeInvalid
  refineBounds : ∀ facts operator left right truth,
    calls.refineBounds facts operator left right truth = Predicate.refineBounds facts operator left right truth
  fits : ∀ facts summary, calls.fits facts summary = fitsLengthSummary facts summary
  refineEqual : ∀ facts left right, calls.refineEqual facts left right = refineLengthOverlap facts left right
  join : ∀ left right, left.count ≤ ScalarExpression.maxBindings → left.count = right.count →
    calls.join left right = left.join right

def workerInput (text : Source) (context : Context) (position : Nat) (facts : ActiveFlow) : Prop :=
  ValidText text ∧ ValidContext text context ∧ position ≤ text.length + 1 ∧ ValidFlow context facts

def workerChainInput (text : Source) (context : Context) (result : ConditionResult) : Prop :=
  ValidText text ∧ ValidContext text context ∧ ValidResult text context result ∧
    result.after ≠ 0 ∧ (chainTokenModel text result.after).isChain = true

/-- Arbitrary-callee equations obtained by evaluating the exact checked source
expression trees, including the direct executable condition wrapper. -/
structure DefinitionEquations (calls : Calls) : Prop where
  sized : SizedModels calls
  summary : ∀ value, calls.summary value = summaryBody.eval calls ({value} : Inputs).locals
  bound : ∀ binding, calls.bound binding = boundBody.eval calls ({binding} : Inputs).locals
  bindingSummary : ∀ binding, calls.bindingSummary binding = bindingSummaryBody.eval calls ({binding} : Inputs).locals
  comparison : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
    calls.comparison text position = comparisonBody.eval calls ({text, position} : Inputs).locals
  length : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position literal, position ≤ text.length + 1 →
    calls.length text context position literal = lengthBody.eval calls ({text, context, position, literal} : Inputs).locals
  chainToken : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
    calls.chainToken text position = chainTokenBody.eval calls ({text, position} : Inputs).locals
  chainAfter : ∀ text, ValidText text → ∀ position operator, position ≤ text.length + 1 → operator.isChain = true →
    calls.chainAfter text position operator = chainAfterBody.eval calls ({text, position, operator} : Inputs).locals
  primary : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    calls.primary text context position facts = primaryBody.eval calls ({text, context, position, facts} : Inputs).locals
  relation : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    calls.relation text context position facts = relationBody.eval calls ({text, context, position, facts} : Inputs).locals
  model : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    calls.model text context position facts = modelBody.eval calls ({text, context, position, facts} : Inputs).locals
  workers : ∃ outputs : Workers.Outputs,
    Workers.Refinement workerInput workerChainInput calls outputs ∧
      ∀ text context position facts, workerInput text context position facts →
        calls.condition text context position facts = outputs.condition text context position facts facts.count
  tail : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ result,
    ValidResult text context result → ∀ operator, operator.isChain = true → ∀ chained,
    calls.tail text context result operator chained = tailBody.eval calls ({text, context, result, operator, chained} : Inputs).locals

theorem DefinitionEquations.condition {calls : Calls} (defs : DefinitionEquations calls)
    (text : Source) (tv : ValidText text) (context : Context) (cv : ValidContext text context)
    (position : Nat) (bounded : position ≤ text.length + 1) (facts : ActiveFlow) (fv : ValidFlow context facts) :
    calls.condition text context position facts = conditionBody.eval calls ({text, context, position, facts} : Inputs).locals := by
  have legal : workerInput text context position facts := ⟨tv, cv, bounded, fv⟩
  obtain ⟨outputs, verified, observed⟩ := defs.workers
  exact (observed text context position facts legal).trans
    (verified.condition text context position facts facts.count legal rfl)

section
variable {calls : Calls} (helpers : HelperMeaning calls) (defs : DefinitionEquations calls)

include defs in
theorem summary_meaning (value : Compose.ExpressionResult) : calls.summary value = summaryOf value := by
  rw [defs.summary, summary_denotation]
include defs in
theorem bound_meaning (binding : Bindings.BindingInfo) : calls.bound binding = binding.bound := by
  rw [defs.bound, bound_denotation]
include defs in
theorem bindingSummary_meaning (binding : Bindings.BindingInfo) : calls.bindingSummary binding = LengthSummary.ofExact binding.bound.summary := by
  rw [defs.bindingSummary, bindingSummary_denotation]

include helpers defs

theorem comparison_meaning (text : Source) (tv : ValidText text) (position : Nat) (bounded : position ≤ text.length + 1) :
    calls.comparison text position = comparisonAt text position := by
  rw [defs.comparison text tv position bounded, comparison_denotation]
  unfold comparisonEquation
  simp only [helpers.take text tv position _ bounded]
  rfl

theorem length_meaning (text : Source) (tv : ValidText text) (context : Context) (cv : ValidContext text context)
    (position : Nat) (literal : Bool) (bounded : position ≤ text.length + 1) :
    calls.length text context position literal = lengthAt text context.model position literal := by
  rw [defs.length text tv context cv position literal bounded, length_denotation]
  unfold lengthEquation
  dsimp only
  rw [helpers.skip text tv position bounded]
  have firstBound := model_skip_valid text position bounded
  rw [helpers.name text tv _ firstBound]
  have afterBound := model_name_valid text (skipAt text position)
  rw [helpers.lookup text tv context.names _ _ cv.1 firstBound afterBound,
    helpers.scalarLookup text tv context.scalarNames _ _ cv.2.2.1 firstBound afterBound,
    helpers.integer text tv _ firstBound]
  rw [helpers.take text tv _ .apostrophe afterBound,
    helpers.take text tv _ .lengthName (takeModel_valid text _ .apostrophe afterBound), bound_meaning defs]
  rfl

theorem chainToken_meaning (text : Source) (tv : ValidText text) (position : Nat) (bounded : position ≤ text.length + 1) :
    calls.chainToken text position = chainTokenModel text position := by
  rw [defs.chainToken text tv position bounded, chainToken_denotation]
  unfold chainTokenEquation
  rw [helpers.take text tv position .andKeyword bounded, helpers.take text tv position .orKeyword bounded]
  rfl

theorem chainAfter_meaning (text : Source) (tv : ValidText text) (position : Nat) (operator : Token)
    (bounded : position ≤ text.length + 1) (valid : operator.isChain = true) :
    calls.chainAfter text position operator = Predicate.chainAfter text position operator.chain := by
  rw [defs.chainAfter text tv position operator bounded valid, chainAfter_denotation]
  unfold chainAfterEquation
  rw [helpers.take text tv position operator bounded,
    helpers.take text tv _ _ (takeModel_valid text position operator bounded)]
  rcases chain_cases valid with rfl | rfl <;> rfl

theorem primary_normalized (contracts : Contracts calls) (text : Source) (tv : ValidText text)
    (context : Context) (cv : ValidContext text context) (position : Nat) (bounded : position ≤ text.length + 1)
    (facts : ActiveFlow) (fv : ValidFlow context facts) :
    calls.primary text context position facts = primaryEquation (interpreted calls) text context position facts := by
  rw [defs.primary text tv context cv position bounded facts fv, primary_denotation]
  unfold primaryEquation
  dsimp only [interpreted]
  rw [helpers.take text tv position .leftParenthesis bounded]
  have openingBound := takeModel_valid text position .leftParenthesis bounded
  have innerBound := (contracts.model text tv context cv _ openingBound facts fv).1.1
  rw [helpers.take text tv _ .rightParenthesis innerBound,
    helpers.callAfter text tv context.names position .validity context.scalarNames cv.1 cv.2.2.1 bounded,
    helpers.assumeValid, helpers.assumeInvalid]
  simp only [helpers.invalidCondition facts (fv.count_le cv)]
  rfl

theorem relation_normalized (text : Source) (tv : ValidText text)
    (context : Context) (cv : ValidContext text context) (position : Nat) (bounded : position ≤ text.length + 1)
    (facts : ActiveFlow) (fv : ValidFlow context facts) :
    calls.relation text context position facts = relationEquation (interpreted calls) text context position facts := by
  rw [defs.relation text tv context cv position bounded facts fv, relation_denotation]
  unfold relationEquation
  dsimp only [interpreted]
  rw [helpers.take text tv position .notKeyword bounded,
    length_meaning helpers defs text tv context cv position false bounded]
  have lengthBound := Predicate.length_bound text context.model position false bounded
  rw [comparison_meaning helpers defs text tv _ lengthBound]
  have compareLengthBound := Predicate.comparison_bound text _ lengthBound
  rw [length_meaning helpers defs text tv context cv _ true compareLengthBound]
  simp only [helpers.refineBounds]
  rw [helpers.scalarInFlow text tv context cv position facts bounded fv]
  have scalarBound : (ScalarExpression.read text position (context.model.readingNames facts)).after ≤ text.length + 1 := by
    by_cases zero : (ScalarExpression.read text position (context.model.readingNames facts)).after = 0
    · simp [zero]
    · exact (ScalarExpression.read_bounds bounded zero).2.1
  rw [comparison_meaning helpers defs text tv _ scalarBound]
  have scalarComparisonBound := Predicate.comparison_bound text _ scalarBound
  rw [helpers.scalarInFlow text tv context cv _ facts scalarComparisonBound fv]
  have rightScalarBound : (ScalarExpression.read text
      (comparisonAt text (ScalarExpression.read text position (context.model.readingNames facts)).after).after
      (context.model.readingNames facts)).after ≤ text.length + 1 := by
    by_cases zero : (ScalarExpression.read text
        (comparisonAt text (ScalarExpression.read text position (context.model.readingNames facts)).after).after
        (context.model.readingNames facts)).after = 0
    · simp [zero]
    · exact (ScalarExpression.read_bounds scalarComparisonBound zero).2.1
  rw [helpers.scalarCondition text tv context cv position _ bounded scalarComparisonBound facts fv _ _ scalarBound rightScalarBound _
    (ScalarExpression.Native.read_type tv bounded).2.1
    (ScalarExpression.Native.read_type tv scalarComparisonBound).2.1]
  rw [helpers.stringInFlow text tv context cv position facts bounded fv]
  have expressionBound := (model_expression_valid (scalarNames := context.model.readingNames facts) (integerHidden := false)
    text tv position context.names bounded cv.1).1
  rw [comparison_meaning helpers defs text tv _ expressionBound]
  have comparisonBound := Predicate.comparison_bound text _ expressionBound
  rw [helpers.stringInFlow text tv context cv _ facts comparisonBound fv]
  simp only [summary_meaning defs, helpers.fits, helpers.refineEqual,
    helpers.invalidCondition facts (fv.count_le cv)]
  rfl

theorem tail_normalized (contracts : Contracts calls) (text : Source) (tv : ValidText text)
    (context : Context) (cv : ValidContext text context) (result : ConditionResult) (rv : ValidResult text context result)
    (operator : Token) (valid : operator.isChain = true) (chained : Bool) :
    calls.tail text context result operator chained = tailEquation (interpreted calls) text context result operator chained := by
  rw [defs.tail text tv context cv result rv operator valid chained, tail_denotation]
  unfold tailEquation
  dsimp only [interpreted]
  rw [chainToken_meaning helpers defs text tv result.after rv.1]
  by_cases selected : (chainTokenModel text result.after).isChain = true
  · have normalized : calls.chainAfter text result.after (chainTokenModel text result.after) =
        modelCalls.chainAfter text result.after (chainTokenModel text result.after) :=
      chainAfter_meaning helpers defs text tv result.after _ rv.1 selected
    rw [normalized]
    let selectedFacts := if chainTokenModel text result.after = .andKeyword then result.whenTrue else result.whenFalse
    have selectedValid : ValidFlow context selectedFacts := by
      dsimp only [selectedFacts]
      split <;> first | exact rv.2.1 | exact rv.2.2
    have afterBound := Predicate.chainAfter_bound text result.after (chainTokenModel text result.after).chain rv.1
    let right := calls.relation text context
      (modelCalls.chainAfter text result.after (chainTokenModel text result.after)) selectedFacts
    have rightValid : ValidResult text context right :=
      (contracts.relation text tv context cv _ afterBound selectedFacts selectedValid).1
    have yesSame := rv.2.1.2.compatible.count.trans rightValid.2.1.2.compatible.count.symm
    have noSame := rv.2.2.2.compatible.count.trans rightValid.2.2.2.compatible.count.symm
    have joinedYes := helpers.join result.whenTrue right.whenTrue (rv.2.1.count_le cv) yesSame
    have joinedNo := helpers.join result.whenFalse right.whenFalse (rv.2.2.count_le cv) noSame
    dsimp only [right, selectedFacts] at joinedYes joinedNo
    rw [joinedYes, joinedNo]
    simp only [helpers.invalidCondition result.whenTrue (rv.2.1.count_le cv)]
    rfl
  · have noChain : (chainTokenModel text result.after).isChain = false := Bool.eq_false_iff.mpr selected
    simp only [show modelCalls.chainToken = chainTokenModel from rfl, noChain, Bool.not_false, ↓reduceIte,
      helpers.invalidCondition result.whenTrue (rv.2.1.count_le cv)]
    rfl

theorem equations_of_definitions (contracts : Contracts calls) : Equations calls where
  primary := primary_normalized helpers defs contracts
  relation := relation_normalized helpers defs
  model text tv context cv position bounded facts fv := by
    rw [defs.model text tv context cv position bounded facts fv, model_denotation]
    simp only [modelEquation, helpers.invalidCondition facts (fv.count_le cv)]
    rfl
  condition := defs.condition
  tail := tail_normalized helpers defs contracts

/-- End-to-end native predicate correspondence, retaining arbitrary calls until
all source equations, helper meanings and checked contracts are discharged. -/
theorem condition_of_source_equations (contracts : Contracts calls) (text : Source) (tv : ValidText text)
    (context : Context) (cv : ValidContext text context) (position : Nat) (bounded : position ≤ text.length + 1)
    (facts : ActiveFlow) (fv : ValidFlow context facts) :
    calls.condition text context position facts = readCondition text context.model position facts :=
  condition_unique calls (equations_of_definitions helpers defs contracts) text tv context cv position bounded facts fv

end

theorem model_helper_meaning : HelperMeaning modelCalls where
  callAfter _ _ _ _ _ _ _ _ _ := rfl
  take _ _ _ _ _ := rfl
  skip _ _ _ _ := rfl
  name _ _ _ _ := rfl
  lookup _ _ _ _ _ _ _ _ := rfl
  scalarLookup _ _ _ _ _ _ _ _ := rfl
  scalarRead _ _ _ _ _ _ := rfl
  scalarInFlow _ _ _ _ _ _ _ _ := rfl
  stringInFlow _ _ _ _ _ _ _ _ := rfl
  scalarCondition _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ _ := rfl
  invalidCondition _ _ := rfl
  integer _ _ _ _ := rfl
  expression _ _ _ _ _ _ _ _ := rfl
  assumeValid _ := rfl
  assumeInvalid _ := rfl
  refineBounds _ _ _ _ _ := rfl
  fits _ _ := rfl
  refineEqual _ _ _ := rfl
  join _ _ _ _ := rfl

theorem model_definition_equations : DefinitionEquations modelCalls where
  sized := model_sizedModels
  summary value := by rw [summary_denotation]; rfl
  bound binding := by rw [bound_denotation]; rfl
  bindingSummary binding := by rw [bindingSummary_denotation]; rfl
  comparison text _ position _ := by
    rw [comparison_denotation]
    exact model_comparison_equation text position
  length text _ context _ position literal _ := by
    rw [length_denotation]
    exact model_length_equation text context position literal
  chainToken text _ position _ := by
    rw [chainToken_denotation]
    exact model_chainToken_equation text position
  chainAfter text _ position operator _ valid := by
    rw [chainAfter_denotation]
    exact model_chainAfter_equation text position operator valid
  primary text _ context _ position bounded facts _ := by
    rw [primary_denotation]
    exact model_primary_equation text context position facts bounded
  relation text _ context _ position bounded facts _ := by
    rw [relation_denotation]
    exact model_relation_equation text context position facts bounded
  model text tv context cv position bounded facts _ := by
    rw [model_denotation]
    exact model_model_equation text context position facts tv cv bounded
  workers := ⟨Workers.modelOutputs modelCalls,
    Workers.model_refinement workerInput workerChainInput modelCalls, fun _ _ _ _ _ => rfl⟩
  tail text tv context cv result rv operator valid chained := by
    rw [tail_denotation]
    exact model_tail_equation text context result operator chained tv cv rv.1 valid

/-- The complete source-equation and contract interface is inhabited. -/
theorem source_interface_inhabited : ∃ calls, HelperMeaning calls ∧ DefinitionEquations calls ∧ Contracts calls :=
  ⟨modelCalls, model_helper_meaning, model_definition_equations, model_contracts⟩

end Silver.Predicate.Native
