module

public import Silver.PredicateNativeContracts

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
  integer : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
    calls.integer text position = IntegerLiteral.read text position
  expression : ∀ text, ValidText text → ∀ position names scalarNames, position ≤ text.length + 1 → ValidNames text names →
    ScalarExpression.ValidEnvironment text scalarNames →
    calls.expression text position names scalarNames = expressionAt text position names scalarNames
  assumeValid : ∀ facts, calls.assumeValid facts = facts.assumeValid
  assumeInvalid : ∀ facts, calls.assumeInvalid facts = facts.assumeInvalid
  refineBounds : ∀ facts operator left right truth,
    calls.refineBounds facts operator left right truth = Predicate.refineBounds facts operator left right truth
  fits : ∀ facts summary, calls.fits facts summary = fitsSummary facts summary
  refineEqual : ∀ facts left right, calls.refineEqual facts left right = refineAffineEqual facts left right
  join : ∀ left right, calls.join left right = left.join right

/-- Arbitrary-callee equations obtained by evaluating the exact checked source
expression trees, including the direct executable condition wrapper. -/
structure DefinitionEquations (calls : Calls) : Prop where
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
    position ≤ text.length + 1 → ∀ facts, facts.Bounded →
    calls.primary text context position facts = primaryBody.eval calls ({text, context, position, facts} : Inputs).locals
  relation : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, facts.Bounded →
    calls.relation text context position facts = relationBody.eval calls ({text, context, position, facts} : Inputs).locals
  model : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, facts.Bounded →
    calls.model text context position facts = modelBody.eval calls ({text, context, position, facts} : Inputs).locals
  condition : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, facts.Bounded →
    calls.condition text context position facts = conditionBody.eval calls ({text, context, position, facts} : Inputs).locals
  tail : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ result,
    ValidResult text result → ∀ operator, operator.isChain = true → ∀ chained,
    calls.tail text context result operator chained = tailBody.eval calls ({text, context, result, operator, chained} : Inputs).locals

section
variable {calls : Calls} (helpers : HelperMeaning calls) (defs : DefinitionEquations calls)

include defs in
theorem summary_meaning (value : Compose.ExpressionResult) : calls.summary value = summaryOf value := by
  rw [defs.summary, summary_denotation]
include defs in
theorem bound_meaning (binding : Bindings.BindingInfo) : calls.bound binding = binding.bound := by
  rw [defs.bound, bound_denotation]
include defs in
theorem bindingSummary_meaning (binding : Bindings.BindingInfo) : calls.bindingSummary binding = binding.bound.summary := by
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
    helpers.scalarLookup text tv context.scalarNames _ _ cv.2.2 firstBound afterBound,
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
    (facts : PathFacts.Context) (fv : facts.Bounded) :
    calls.primary text context position facts = primaryEquation (interpreted calls) text context position facts := by
  rw [defs.primary text tv context cv position bounded facts fv, primary_denotation]
  unfold primaryEquation
  dsimp only [interpreted]
  rw [helpers.take text tv position .leftParenthesis bounded]
  have openingBound := takeModel_valid text position .leftParenthesis bounded
  have innerBound := (contracts.condition text tv context cv _ openingBound facts fv).1.1
  rw [helpers.take text tv _ .rightParenthesis innerBound,
    helpers.callAfter text tv context.names position .validity context.scalarNames cv.1 cv.2.2 bounded,
    helpers.assumeValid, helpers.assumeInvalid]
  rfl

theorem relation_normalized (text : Source) (tv : ValidText text)
    (context : Context) (cv : ValidContext text context) (position : Nat) (bounded : position ≤ text.length + 1)
    (facts : PathFacts.Context) (fv : facts.Bounded) :
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
  rw [helpers.scalarRead text tv position context.scalarNames bounded cv.2.2]
  have scalarBound : (ScalarExpression.read text position context.scalarNames).after ≤ text.length + 1 := by
    by_cases zero : (ScalarExpression.read text position context.scalarNames).after = 0
    · simp [zero]
    · exact (ScalarExpression.read_bounds bounded zero).2.1
  rw [comparison_meaning helpers defs text tv _ scalarBound]
  have scalarComparisonBound := Predicate.comparison_bound text _ scalarBound
  rw [helpers.scalarRead text tv _ context.scalarNames scalarComparisonBound cv.2.2]
  rw [helpers.expression text tv position context.names context.scalarNames bounded cv.1 cv.2.2]
  have expressionBound := (model_expression_valid (scalarNames := context.scalarNames) text tv position context.names bounded cv.1).1
  rw [comparison_meaning helpers defs text tv _ expressionBound]
  have comparisonBound := Predicate.comparison_bound text _ expressionBound
  rw [helpers.expression text tv _ context.names context.scalarNames comparisonBound cv.1 cv.2.2]
  simp only [summary_meaning defs, helpers.fits, helpers.refineEqual]
  rfl

theorem tail_normalized (text : Source) (tv : ValidText text)
    (context : Context) (cv : ValidContext text context) (result : ConditionResult) (rv : ValidResult text result)
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
    simp only [helpers.join]
    rfl
  · have noChain : (chainTokenModel text result.after).isChain = false := Bool.eq_false_iff.mpr selected
    simp only [show modelCalls.chainToken = chainTokenModel from rfl, noChain, Bool.not_false, ↓reduceIte]

theorem equations_of_definitions (contracts : Contracts calls) : Equations calls where
  primary := primary_normalized helpers defs contracts
  relation := relation_normalized helpers defs
  model text tv context cv position bounded facts fv := by
    rw [defs.model text tv context cv position bounded facts fv, model_denotation]
    rfl
  condition := defs.condition
  tail := tail_normalized helpers defs

/-- End-to-end native predicate correspondence, retaining arbitrary calls until
all source equations, helper meanings and checked contracts are discharged. -/
theorem condition_of_source_equations (contracts : Contracts calls) (text : Source) (tv : ValidText text)
    (context : Context) (cv : ValidContext text context) (position : Nat) (bounded : position ≤ text.length + 1)
    (facts : PathFacts.Context) (fv : facts.Bounded) :
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
  integer _ _ _ _ := rfl
  expression _ _ _ _ _ _ _ _ := rfl
  assumeValid _ := rfl
  assumeInvalid _ := rfl
  refineBounds _ _ _ _ _ := rfl
  fits _ _ := rfl
  refineEqual _ _ _ := rfl
  join _ _ := rfl

theorem model_definition_equations : DefinitionEquations modelCalls where
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
  condition _ _ _ _ _ _ _ _ := rfl
  tail text tv context cv result rv operator valid chained := by
    rw [tail_denotation]
    exact model_tail_equation text context result operator chained tv cv rv.1 valid

/-- The complete source-equation and contract interface is inhabited. -/
theorem source_interface_inhabited : ∃ calls, HelperMeaning calls ∧ DefinitionEquations calls ∧ Contracts calls :=
  ⟨modelCalls, model_helper_meaning, model_definition_equations, model_contracts⟩

end Silver.Predicate.Native
