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
  readingNames : ∀ text, ValidText text → ∀ context, ValidContext text context →
    ∀ facts, ValidFlow context facts →
    calls.readingNames context facts = context.model.readingNames facts
  characterAt : ∀ text, ValidText text → ∀ position names scalarNames arrays initials elaborating,
    position ≤ text.length + 1 → NativeNames text names →
    ScalarExpression.ValidEnvironment text scalarNames → ArrayBindings.ValidMetadata text arrays →
    ArrayBindings.ValidInitials initials →
    calls.characterAt text position names scalarNames arrays initials elaborating =
      Compose.characterAt text position names scalarNames arrays initials elaborating
  xorFree : ∀ text, ValidText text → ∀ first after,
    first ≤ text.length + 1 → after ≤ text.length + 1 →
    calls.xorFree text first after = Predicate.xorFree text first after
  equalName : ∀ text, ValidText text → ∀ first after otherFirst otherAfter,
    Compose.Expressions.ValidName text first after → Compose.Expressions.ValidName text otherFirst otherAfter →
    calls.equalName text first after otherFirst otherAfter = Named.equalName text first after otherFirst otherAfter
  nameIs : ∀ text, ValidText text → ∀ first after word,
    Compose.Expressions.ValidName text first after → 0 < word.toList.length → word.toList.length ≤ 16 →
    calls.nameIs text first after word = Named.nameIs text first after (word.toList.map Char.toNat)
  arrayLookup : ∀ text, ValidText text → ∀ names first after,
    ArrayBindings.ValidMetadata text names → first ≤ text.length + 1 → after ≤ text.length + 1 →
    calls.arrayLookup text names first after = ArrayBindings.lookup text names first after
  arrayContains : ∀ item indices, ArrayBindings.Native.BindingType item → indices.Bounded →
    calls.arrayContains item indices = ArrayBindings.contains item indices
  scalarIndex : ∀ text, ValidText text → ∀ position names maskFirst maskAfter,
    position ≤ text.length + 1 → ScalarExpression.ValidEnvironment text names →
    ScalarExpression.ValidMask text maskFirst maskAfter →
    calls.scalarIndex text position names maskFirst maskAfter =
      ScalarExpression.read text position names maskFirst maskAfter
  booleanLookup : ∀ text, ValidText text → ∀ names first after,
    BooleanBindings.ValidEnvironment text names → first ≤ text.length + 1 → after ≤ text.length + 1 →
    calls.booleanLookup text names first after = BooleanBindings.lookup text names first after
  callAfter : ∀ text, ValidText text → ∀ names position operation scalarNames arrays hidden booleans,
    NativeNames text names → ScalarExpression.ValidEnvironment text scalarNames →
    ArrayBindings.ValidMetadata text arrays → BooleanBindings.ValidEnvironment text booleans → position ≤ text.length + 1 →
    calls.callAfter text names position operation scalarNames arrays hidden booleans = Compose.callAfter text names position operation scalarNames arrays hidden booleans
  take : ∀ text, ValidText text → ∀ position token, position ≤ text.length + 1 →
    calls.take text position token = takeModel text position token
  skip : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
    calls.skip text position = skipAt text position
  name : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
    calls.nameAfter text position = Compose.nameAfter text position
  lookup : ∀ text, ValidText text → ∀ names first after,
    NativeNames text names → first ≤ text.length + 1 → after ≤ text.length + 1 →
    calls.lookup text names first after = lookupName text names first after
  scalarLookup : ∀ text, ValidText text → ∀ names first after,
    ScalarExpression.ValidEnvironment text names → first ≤ text.length + 1 → after ≤ text.length + 1 →
    calls.scalarLookup text names first after = ScalarExpression.lookup text names first after
  scalarRead : ∀ text, ValidText text → ∀ position names, position ≤ text.length + 1 →
    ScalarExpression.ValidEnvironment text names →
    calls.scalarRead text position names = ScalarExpression.read text position names
  scalarInFlow : ∀ text, ValidText text → ∀ context, ValidContext text context →
    ∀ position facts, position ≤ text.length + 1 → ValidFlow context facts →
    ∀ initials, ArrayBindings.ValidInitials initials →
    calls.scalarInFlow text context position facts initials = readScalarInFlow text context.model position facts (initials := initials)
  stringInFlow : ∀ text, ValidText text → ∀ context, ValidContext text context →
    ∀ position facts, position ≤ text.length + 1 → ValidFlow context facts →
    ∀ initials, ArrayBindings.ValidInitials initials →
    calls.stringInFlow text context position facts initials = readStringInFlow text context.model position facts initials
  scalarCondition : ∀ text, ValidText text → ∀ context, ValidContext text context →
    ∀ position rightPosition, position ≤ text.length + 1 → rightPosition ≤ text.length + 1 →
    ∀ facts, ValidFlow context facts → ∀ left right, left.after ≤ text.length + 1 → right.after ≤ text.length + 1 →
    ∀ operator, left.bounds.Bounded → right.bounds.Bounded → calls.scalarCondition text context position rightPosition facts left right operator =
      Predicate.scalarCondition text context.model position rightPosition facts left right operator
  invalidCondition : ∀ facts, facts.count ≤ ScalarExpression.maxBindings →
    calls.invalidCondition facts = Predicate.invalidCondition facts
  integer : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
    calls.integer text position = IntegerLiteral.read text position
  expression : ∀ text, ValidText text → ∀ position names scalarNames, position ≤ text.length + 1 → NativeNames text names →
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

def workerChainInput (text : Source) (context : Context) (result : ConditionResult)
    (incoming : ActiveFlow) (originalStart : Nat) : Prop :=
  ValidText text ∧ ValidContext text context ∧ ValidResult text context result ∧
    result.after ≠ 0 ∧ (chainTokenModel text result.after).isChain = true ∧
    ValidFlow context incoming ∧ originalStart ≤ text.length + 1

/-- Arbitrary-callee equations obtained by evaluating the exact checked source
expression trees, including the direct executable condition wrapper. -/
structure DefinitionEquations (calls : Calls) : Prop where
  sized : SizedModels calls
  characterCondition : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    ∀ initials, ArrayBindings.ValidInitials initials →
    calls.characterCondition text context position facts initials =
      characterBody.eval calls ({text, context, position, facts, initials} : Inputs).locals
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
  booleanArray : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    calls.booleanArray text context position facts =
      booleanArrayBody.eval calls ({text, context, position, facts} : Inputs).locals
  booleanAtom : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 →
    calls.booleanAtom text context position = booleanAtomBody.eval calls ({text, context, position} : Inputs).locals
  primary : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, ValidFlow context facts → ∀ initials, ArrayBindings.ValidInitials initials →
    calls.primary text context position facts initials = primaryBody.eval calls ({text, context, position, facts, initials} : Inputs).locals
  booleanFactor : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, ValidFlow context facts → ∀ initials, ArrayBindings.ValidInitials initials →
    calls.booleanFactor text context position facts initials = booleanFactorBody.eval calls ({text, context, position, facts, initials} : Inputs).locals
  booleanRelation : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, ValidFlow context facts → ∀ initials, ArrayBindings.ValidInitials initials →
    calls.booleanRelation text context position facts initials = booleanRelationBody.eval calls ({text, context, position, facts, initials} : Inputs).locals
  relation : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, ValidFlow context facts → ∀ initials, ArrayBindings.ValidInitials initials →
    calls.relation text context position facts initials = relationBody.eval calls ({text, context, position, facts, initials} : Inputs).locals
  model : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, ValidFlow context facts → ∀ initials, ArrayBindings.ValidInitials initials →
    calls.model text context position facts initials = modelBody.eval calls ({text, context, position, facts, initials} : Inputs).locals
  workers : ∃ outputs : Workers.Outputs,
    Workers.Refinement workerInput workerChainInput calls outputs ∧
      ∀ text context position facts initials, workerInput text context position facts → ArrayBindings.ValidInitials initials →
        calls.condition text context position facts initials = outputs.condition text context position facts facts.count initials
  tail : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ result,
    ValidResult text context result → ∀ operator, operator.isChain = true → ∀ chained,
    ∀ initials, ArrayBindings.ValidInitials initials → ∀ incoming, ValidFlow context incoming →
    ∀ originalStart, originalStart ≤ text.length + 1 →
    calls.tail text context result operator chained initials incoming originalStart =
      tailBody.eval calls ({text, context, result, operator, chained, initials, incoming, originalStart} : Inputs).locals

theorem DefinitionEquations.condition {calls : Calls} (defs : DefinitionEquations calls)
    (text : Source) (tv : ValidText text) (context : Context) (cv : ValidContext text context)
    (position : Nat) (bounded : position ≤ text.length + 1) (facts : ActiveFlow) (fv : ValidFlow context facts)
    (initials : ArrayBindings.Initials) (iv : ArrayBindings.ValidInitials initials) :
    calls.condition text context position facts initials = conditionBody.eval calls ({text, context, position, facts, initials} : Inputs).locals := by
  have legal : workerInput text context position facts := ⟨tv, cv, bounded, fv⟩
  obtain ⟨outputs, verified, observed⟩ := defs.workers
  exact (observed text context position facts initials legal iv).trans
    (verified.condition text context position facts facts.count initials legal iv rfl)

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

theorem character_meaning (text : Source) (tv : ValidText text)
    (context : Context) (cv : ValidContext text context) (position : Nat) (bounded : position ≤ text.length + 1)
    (facts : ActiveFlow) (fv : ValidFlow context facts) (initials : ArrayBindings.Initials)
    (iv : ArrayBindings.ValidInitials initials) :
    calls.characterCondition text context position facts initials =
      Predicate.characterCondition text context.model position facts initials := by
  rw [defs.characterCondition text tv context cv position bounded facts fv initials iv, character_denotation]
  unfold characterEquation
  dsimp only
  rw [helpers.readingNames text tv context cv facts fv]
  have overlayValid : ScalarExpression.ValidEnvironment text (context.model.readingNames facts) :=
    ScalarMetadata.readingNames_valid cv.2.2.1 fv.2.compatible.count fv.2.bounded
  rw [helpers.characterAt text tv position context.names _ context.arrayNames initials context.elaborating
    bounded cv.nativeNames overlayValid cv.arrays iv]
  have leftBound : (Compose.characterAt text position context.names (context.model.readingNames facts)
      context.arrayNames initials context.elaborating).after ≤ text.length + 1 := by
    by_cases zero : (Compose.characterAt text position context.names (context.model.readingNames facts)
        context.arrayNames initials context.elaborating).after = 0
    · simp only [zero]; omega
    · obtain ⟨expression, parsed⟩ := Compose.character_sound position zero
      exact Compose.character_after_bounded parsed
  rw [comparison_meaning helpers defs text tv _ leftBound]
  have operatorBound := Predicate.comparison_bound text _ leftBound
  rw [helpers.characterAt text tv _ context.names _ context.arrayNames initials context.elaborating
    operatorBound cv.nativeNames overlayValid cv.arrays iv]
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
  rw [helpers.lookup text tv context.names _ _ cv.nativeNames firstBound afterBound,
    helpers.scalarLookup text tv context.scalarNames _ _ cv.2.2.1 firstBound afterBound,
    helpers.integer text tv _ firstBound]
  rw [helpers.take text tv _ .apostrophe afterBound,
    helpers.take text tv _ .lengthName (takeModel_valid text _ .apostrophe afterBound), bound_meaning defs]
  rfl

theorem chainToken_meaning (text : Source) (tv : ValidText text) (position : Nat) (bounded : position ≤ text.length + 1) :
    calls.chainToken text position = chainTokenModel text position := by
  rw [defs.chainToken text tv position bounded, chainToken_denotation]
  unfold chainTokenEquation
  simp only [helpers.take text tv position _ bounded,
    helpers.take text tv _ .thenKeyword (takeModel_valid text position .andKeyword bounded),
    helpers.take text tv _ .elseKeyword (takeModel_valid text position .orKeyword bounded)]
  rfl

theorem chainAfter_meaning (text : Source) (tv : ValidText text) (position : Nat) (operator : ChainKind)
    (bounded : position ≤ text.length + 1) (valid : operator.isChain = true) :
    calls.chainAfter text position operator = chainAfterModel text position operator := by
  rw [defs.chainAfter text tv position operator bounded valid, chainAfter_denotation]
  unfold chainAfterEquation
  simp only [helpers.take text tv position _ bounded,
    helpers.take text tv _ .thenKeyword (takeModel_valid text position .andKeyword bounded),
    helpers.take text tv _ .elseKeyword (takeModel_valid text position .orKeyword bounded)]
  cases operator <;> rfl

theorem booleanArray_meaning (text : Source) (tv : ValidText text)
    (context : Context) (cv : ValidContext text context) (position : Nat) (bounded : position ≤ text.length + 1)
    (facts : ActiveFlow) (fv : ValidFlow context facts) :
    calls.booleanArray text context position facts = booleanArrayAfter text context.model position facts := by
  rw [defs.booleanArray text tv context cv position bounded facts fv, booleanArray_denotation]
  unfold booleanArrayEquation booleanArrayAfter
  dsimp only
  rw [helpers.skip text tv position bounded]
  have firstBound := model_skip_valid text position bounded
  rw [helpers.name text tv _ firstBound]
  have afterBound := model_name_valid text (skipAt text position)
  rw [helpers.arrayLookup text tv context.arrayNames _ _ cv.arrays firstBound afterBound,
    helpers.take text tv _ .leftParenthesis afterBound,
    helpers.readingNames text tv context cv facts fv]
  rw [show takeModel text (nameAfter text (skipAt text position)) .leftParenthesis =
    fixedAfter text (nameAfter text (skipAt text position)) "(" false from rfl]
  have indexStart := model_fixed_valid text _ "(" false afterBound
  have overlayValid : ScalarExpression.ValidEnvironment text (context.model.readingNames facts) :=
    ScalarMetadata.readingNames_valid cv.2.2.1 fv.2.compatible.count fv.2.bounded
  rw [helpers.scalarIndex text tv _ _ context.maskFirst context.maskAfter indexStart overlayValid cv.mask]
  have indexType := ScalarExpression.Native.read_type tv (names := context.model.readingNames facts)
    (maskFirst := context.maskFirst) (maskAfter := context.maskAfter)
    (allowSign := true) (arrays := []) (initials := []) (elaborating := false) indexStart
  have indexBound : (ScalarExpression.read text (fixedAfter text (nameAfter text (skipAt text position)) "(" false)
      (context.model.readingNames facts) context.maskFirst context.maskAfter).after ≤ text.length + 1 := by
    by_cases zero : (ScalarExpression.read text (fixedAfter text (nameAfter text (skipAt text position)) "(" false)
      (context.model.readingNames facts) context.maskFirst context.maskAfter).after = 0
    · simp [zero]
    · exact (ScalarExpression.read_bounds indexStart zero).2.1
  rw [helpers.take text tv _ .rightParenthesis indexBound]
  dsimp only [Context.model, ParseContext.readingNames]
  dsimp only [Context.model, ParseContext.readingNames] at indexType
  by_cases targetZero : ArrayBindings.lookup text context.arrayNames (skipAt text position)
      (nameAfter text (skipAt text position)) = 0
  · simp [targetZero]
  · have targetPositive : 0 < ArrayBindings.lookup text context.arrayNames (skipAt text position)
        (nameAfter text (skipAt text position)) := by omega
    have member := ArrayBindings.Native.binding_mem targetPositive
      (ArrayBindings.Native.lookup_bound text context.arrayNames _ _)
    have itemValid := (cv.arrays.2.1 _ member).2.2.2
    have itemType : ArrayBindings.Native.BindingType
        (ArrayBindings.binding context.arrayNames
          (ArrayBindings.lookup text context.arrayNames (skipAt text position) (nameAfter text (skipAt text position)))) :=
      ⟨itemValid.1, by have cap := itemValid.2.2.2.1; omega,
        by have cap := itemValid.2.2.2.1; omega, itemValid.2.2.2.2.2.1⟩
    rw [helpers.scalarLookup text tv context.scalarNames _ _ cv.2.2.1 firstBound afterBound,
      helpers.arrayContains _ _ itemType indexType.2.1]
    have nameValid : Compose.Expressions.ValidName text (skipAt text position) (nameAfter text (skipAt text position)) := by
      have notBad : ¬(skipAt text position = 0 ∨ nameAfter text (skipAt text position) ≤ skipAt text position) := by
        intro bad
        apply targetZero
        change ArrayBindings.lookupFrom text context.arrayNames (skipAt text position)
          (nameAfter text (skipAt text position)) context.arrayNames.length = 0
        cases context.arrayNames.length with
        | zero => rfl
        | succ length => exact ite_eq_left bad
      exact ⟨by omega, by omega, afterBound⟩
    by_cases maskZero : context.maskFirst = 0
    · simp only [maskZero, ne_eq, not_true_eq_false, false_and]
      rfl
    · have maskValid : Compose.Expressions.ValidName text context.maskFirst context.maskAfter := by
        rcases cv.mask with absent | present
        · exact False.elim (maskZero absent.1)
        · exact present
      rw [helpers.equalName text tv _ _ _ _ maskValid nameValid]
      rfl

theorem booleanAtom_meaning (text : Source) (tv : ValidText text)
    (context : Context) (cv : ValidContext text context) (position : Nat) (bounded : position ≤ text.length + 1) :
    calls.booleanAtom text context position = booleanAtomAfter text context.model position := by
  rw [defs.booleanAtom text tv context cv position bounded, booleanAtom_denotation]
  unfold booleanAtomEquation booleanAtomAfter
  dsimp only
  rw [helpers.skip text tv position bounded]
  have firstBound := model_skip_valid text position bounded
  rw [helpers.name text tv _ firstBound]
  have afterBound := model_name_valid text (skipAt text position)
  by_cases zero : skipAt text position = 0
  · simp [zero]
  · by_cases ordered : nameAfter text (skipAt text position) ≤ skipAt text position
    · simp [ordered]
    · have nameValid : Compose.Expressions.ValidName text (skipAt text position) (nameAfter text (skipAt text position)) :=
        ⟨by omega, by omega, afterBound⟩
      rw [helpers.lookup text tv context.names _ _ cv.nativeNames firstBound afterBound,
        helpers.scalarLookup text tv context.scalarNames _ _ cv.2.2.1 firstBound afterBound,
        helpers.arrayLookup text tv context.arrayNames _ _ cv.arrays firstBound afterBound,
        helpers.booleanLookup text tv context.booleanNames _ _ cv.booleans firstBound afterBound,
        helpers.nameIs text tv _ _ "true" nameValid (by decide) (by decide),
        helpers.nameIs text tv _ _ "false" nameValid (by decide) (by decide)]
      by_cases maskZero : context.maskFirst = 0
      · simp [Context.model, maskZero]
      · have maskValid : Compose.Expressions.ValidName text context.maskFirst context.maskAfter := by
          rcases cv.mask with absent | present
          · exact False.elim (maskZero absent.1)
          · exact present
        rw [helpers.equalName text tv _ _ _ _ maskValid nameValid]
        rfl

theorem primary_normalized (contracts : Contracts calls) (text : Source) (tv : ValidText text)
    (context : Context) (cv : ValidContext text context) (position : Nat) (bounded : position ≤ text.length + 1)
    (facts : ActiveFlow) (fv : ValidFlow context facts) (initials : ArrayBindings.Initials) (iv : ArrayBindings.ValidInitials initials) :
    calls.primary text context position facts initials = primaryEquation (interpreted calls) text context position facts initials := by
  rw [defs.primary text tv context cv position bounded facts fv initials iv, primary_denotation]
  unfold primaryEquation
  dsimp only [interpreted]
  rw [helpers.take text tv position .leftParenthesis bounded]
  have openingBound := takeModel_valid text position .leftParenthesis bounded
  have innerBound := (contracts.model text tv context cv _ openingBound facts fv initials iv).1.1
  rw [helpers.take text tv _ .rightParenthesis innerBound,
    booleanArray_meaning helpers defs text tv context cv position bounded facts fv,
    booleanAtom_meaning helpers defs text tv context cv position bounded]
  have masked : (decide (context.maskFirst ≠ 0) && calls.nameIs text context.maskFirst context.maskAfter "input_is_valid") =
      (decide (context.maskFirst ≠ 0) && Named.nameIs text context.maskFirst context.maskAfter ("input_is_valid".toList.map Char.toNat)) := by
    by_cases zero : context.maskFirst = 0
    · simp [zero]
    · have valid : Compose.Expressions.ValidName text context.maskFirst context.maskAfter := by
        rcases cv.mask with absent | present
        · exact False.elim (zero absent.1)
        · exact present
      rw [helpers.nameIs text tv _ _ _ valid (by decide) (by decide)]
  rw [masked, helpers.callAfter text tv context.names position .validity context.scalarNames context.arrayNames _ context.booleanNames cv.nativeNames cv.2.2.1 cv.arrays cv.booleans bounded,
    helpers.assumeValid, helpers.assumeInvalid]
  simp only [helpers.invalidCondition facts (fv.count_le cv)]
  rfl

theorem booleanFactor_normalized (text : Source) (tv : ValidText text)
    (context : Context) (cv : ValidContext text context) (position : Nat) (bounded : position ≤ text.length + 1)
    (facts : ActiveFlow) (fv : ValidFlow context facts) (initials : ArrayBindings.Initials) (iv : ArrayBindings.ValidInitials initials) :
    calls.booleanFactor text context position facts initials = booleanFactorEquation (interpreted calls) text context position facts initials := by
  rw [defs.booleanFactor text tv context cv position bounded facts fv initials iv, booleanFactor_denotation]
  unfold booleanFactorEquation
  simp only [helpers.take text tv position .notKeyword bounded]
  rfl

theorem booleanRelation_normalized (contracts : Contracts calls) (text : Source) (tv : ValidText text)
    (context : Context) (cv : ValidContext text context) (position : Nat) (bounded : position ≤ text.length + 1)
    (facts : ActiveFlow) (fv : ValidFlow context facts) (initials : ArrayBindings.Initials) (iv : ArrayBindings.ValidInitials initials) :
    calls.booleanRelation text context position facts initials = booleanRelationEquation (interpreted calls) text context position facts initials := by
  rw [defs.booleanRelation text tv context cv position bounded facts fv initials iv, booleanRelation_denotation]
  unfold booleanRelationEquation
  dsimp only [interpreted]
  have leftBound := (contracts.booleanFactor text tv context cv position bounded facts fv initials iv).1.1
  rw [comparison_meaning helpers defs text tv _ leftBound]
  simp only [helpers.invalidCondition facts (fv.count_le cv)]
  rfl

theorem relation_normalized (text : Source) (tv : ValidText text)
    (context : Context) (cv : ValidContext text context) (position : Nat) (bounded : position ≤ text.length + 1)
    (facts : ActiveFlow) (fv : ValidFlow context facts) (initials : ArrayBindings.Initials) (iv : ArrayBindings.ValidInitials initials) :
    calls.relation text context position facts initials = relationEquation (interpreted calls) text context position facts initials := by
  rw [defs.relation text tv context cv position bounded facts fv initials iv, relation_denotation]
  unfold relationEquation
  dsimp only [interpreted]
  rw [character_meaning helpers defs text tv context cv position bounded facts fv initials iv]
  rw [helpers.take text tv position .notKeyword bounded,
    length_meaning helpers defs text tv context cv position false bounded]
  have lengthBound := Predicate.length_bound text context.model position false bounded
  rw [comparison_meaning helpers defs text tv _ lengthBound]
  have compareLengthBound := Predicate.comparison_bound text _ lengthBound
  rw [length_meaning helpers defs text tv context cv _ true compareLengthBound]
  simp only [helpers.refineBounds]
  rw [helpers.scalarInFlow text tv context cv position facts bounded fv initials iv]
  have scalarBound : (readScalarInFlow text context.model position facts (initials := initials)).after ≤ text.length + 1 := by
    by_cases zero : (readScalarInFlow text context.model position facts (initials := initials)).after = 0
    · simp [zero]
    · exact (ScalarExpression.read_arrays_bounds bounded zero).2.1
  rw [comparison_meaning helpers defs text tv _ scalarBound]
  have scalarComparisonBound := Predicate.comparison_bound text _ scalarBound
  rw [helpers.scalarInFlow text tv context cv _ facts scalarComparisonBound fv initials iv]
  have rightScalarBound : (readScalarInFlow text context.model
      (comparisonAt text (readScalarInFlow text context.model position facts (initials := initials)).after).after
      facts (initials := initials)).after ≤ text.length + 1 := by
    by_cases zero : (readScalarInFlow text context.model
        (comparisonAt text (readScalarInFlow text context.model position facts (initials := initials)).after).after
        facts (initials := initials)).after = 0
    · simp [zero]
    · exact (ScalarExpression.read_arrays_bounds scalarComparisonBound zero).2.1
  rw [helpers.scalarCondition text tv context cv position _ bounded scalarComparisonBound facts fv _ _ scalarBound rightScalarBound _
    (ScalarExpression.Native.read_type tv bounded).2.1
    (ScalarExpression.Native.read_type tv scalarComparisonBound).2.1]
  rw [helpers.stringInFlow text tv context cv position facts bounded fv initials iv]
  have expressionBound : (readStringInFlow text context.model position facts initials).after ≤ text.length + 1 :=
    (model_expression_valid (scalarNames := context.model.readingNames facts)
    (integerHidden := context.model.integerHidden text) (arrays := context.arrayNames) (initials := initials) (elaborating := context.elaborating)
    text tv position context.names bounded cv.1).1
  rw [comparison_meaning helpers defs text tv _ expressionBound]
  have comparisonBound := Predicate.comparison_bound text _ expressionBound
  rw [helpers.stringInFlow text tv context cv _ facts comparisonBound fv initials iv]
  simp only [summary_meaning defs, helpers.fits, helpers.refineEqual,
    helpers.invalidCondition facts (fv.count_le cv)]
  rfl

theorem tail_normalized (contracts : Contracts calls) (text : Source) (tv : ValidText text)
    (context : Context) (cv : ValidContext text context) (result : ConditionResult) (rv : ValidResult text context result)
    (operator : ChainKind) (valid : operator.isChain = true) (chained : Bool)
    (initials : ArrayBindings.Initials) (iv : ArrayBindings.ValidInitials initials)
    (incoming : ActiveFlow) (incomingValid : ValidFlow context incoming)
    (originalStart : Nat) (startBound : originalStart ≤ text.length + 1) :
    calls.tail text context result operator chained initials incoming originalStart =
      tailEquation (interpreted calls) text context result operator chained initials incoming originalStart := by
  rw [defs.tail text tv context cv result rv operator valid chained initials iv incoming incomingValid originalStart startBound, tail_denotation]
  unfold tailEquation
  dsimp only [interpreted]
  rw [chainToken_meaning helpers defs text tv result.after rv.1]
  by_cases absent : chainTokenModel text result.after = .noChain
  · simp [absent, helpers.invalidCondition result.whenTrue (rv.2.1.count_le cv), modelCalls]
  · have selected : (chainTokenModel text result.after).isChain = true := by simp [ChainKind.isChain, absent]
    have normalized : calls.chainAfter text result.after (chainTokenModel text result.after) =
        modelCalls.chainAfter text result.after (chainTokenModel text result.after) :=
      chainAfter_meaning helpers defs text tv result.after _ rv.1 selected
    rw [normalized]
    let selectedFacts := if chainTokenModel text result.after = .shortAnd then result.whenTrue
      else if chainTokenModel text result.after = .shortOr then result.whenFalse else incoming
    have selectedValid : ValidFlow context selectedFacts := by
      dsimp only [selectedFacts]
      split
      · exact rv.2.1
      · split
        · exact rv.2.2
        · exact incomingValid
    have afterBound : modelCalls.chainAfter text result.after (chainTokenModel text result.after) ≤ text.length + 1 := by
      simp only [modelCalls, chainAfterModel, absent, ↓reduceIte]
      exact Predicate.chainAfter_bound text result.after (chainTokenModel text result.after).predicate rv.1
    let right := calls.relation text context
      (modelCalls.chainAfter text result.after (chainTokenModel text result.after)) selectedFacts initials
    have rightValid : ValidResult text context right :=
      (contracts.relation text tv context cv _ afterBound selectedFacts selectedValid initials iv).1
    have yesSame := rv.2.1.2.compatible.count.trans rightValid.2.1.2.compatible.count.symm
    have noSame := rv.2.2.2.compatible.count.trans rightValid.2.2.2.compatible.count.symm
    have joinedYes := helpers.join result.whenTrue right.whenTrue (rv.2.1.count_le cv) yesSame
    have joinedNo := helpers.join result.whenFalse right.whenFalse (rv.2.2.count_le cv) noSame
    have rightXor := helpers.xorFree text tv _ right.after afterBound rightValid.1
    dsimp only [right, selectedFacts] at joinedYes joinedNo rightXor
    rw [joinedYes, joinedNo, rightXor, helpers.xorFree text tv originalStart result.after startBound rv.1]
    simp only [helpers.invalidCondition result.whenTrue (rv.2.1.count_le cv)]
    rfl

theorem equations_of_definitions (contracts : Contracts calls) : Equations calls where
  primary := primary_normalized helpers defs contracts
  booleanFactor := booleanFactor_normalized helpers defs
  booleanRelation := booleanRelation_normalized helpers defs contracts
  relation := relation_normalized helpers defs
  model text tv context cv position bounded facts fv initials iv := by
    rw [defs.model text tv context cv position bounded facts fv initials iv, model_denotation]
    simp only [modelEquation, helpers.invalidCondition facts (fv.count_le cv)]
    rfl
  condition := defs.condition
  tail := tail_normalized helpers defs contracts

/-- End-to-end native predicate correspondence, retaining arbitrary calls until
all source equations, helper meanings and checked contracts are discharged. -/
theorem condition_of_source_equations (contracts : Contracts calls) (text : Source) (tv : ValidText text)
    (context : Context) (cv : ValidContext text context) (position : Nat) (bounded : position ≤ text.length + 1)
    (facts : ActiveFlow) (fv : ValidFlow context facts) (initials : ArrayBindings.Initials) (iv : ArrayBindings.ValidInitials initials) :
    calls.condition text context position facts initials = readCondition text context.model position facts initials :=
  condition_unique calls (equations_of_definitions helpers defs contracts) text tv context cv position bounded facts fv initials iv

end

theorem model_helper_meaning : HelperMeaning modelCalls where
  readingNames := by intros; rfl
  characterAt := by intros; rfl
  xorFree := by intros; rfl
  equalName := by intros; rfl
  nameIs := by intros; rfl
  arrayLookup := by intros; rfl
  arrayContains := by intros; rfl
  scalarIndex := by intros; rfl
  booleanLookup := by intros; rfl
  callAfter := by intros; rfl
  take := by intros; rfl
  skip := by intros; rfl
  name := by intros; rfl
  lookup := by intros; rfl
  scalarLookup := by intros; rfl
  scalarRead := by intros; rfl
  scalarInFlow := by intros; rfl
  stringInFlow := by intros; rfl
  scalarCondition := by intros; rfl
  invalidCondition := by intros; rfl
  integer := by intros; rfl
  expression := by intros; rfl
  assumeValid := by intros; rfl
  assumeInvalid := by intros; rfl
  refineBounds := by intros; rfl
  fits := by intros; rfl
  refineEqual := by intros; rfl
  join := by intros; rfl

theorem model_definition_equations : DefinitionEquations modelCalls where
  sized := model_sizedModels
  characterCondition text _ context _ position _ facts _ initials _ := by
    rw [character_denotation]
    exact model_character_equation text context position facts initials
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
  booleanArray text _ context _ position _ facts _ := by
    rw [booleanArray_denotation]
    exact model_booleanArray_equation text context position facts
  booleanAtom text _ context _ position _ := by
    rw [booleanAtom_denotation]
    exact model_booleanAtom_equation text context position
  primary text _ context _ position bounded facts _ initials _ := by
    rw [primary_denotation]
    exact model_primary_equation text context position facts initials bounded
  booleanFactor text _ context _ position bounded facts _ initials _ := by
    rw [booleanFactor_denotation]
    exact model_booleanFactor_equation text context position facts initials bounded
  booleanRelation text tv context cv position bounded facts _ initials _ := by
    rw [booleanRelation_denotation]
    exact model_booleanRelation_equation text context position facts initials tv cv.1 bounded
  relation text _ context _ position bounded facts _ initials _ := by
    rw [relation_denotation]
    exact model_relation_equation text context position facts initials bounded
  model text tv context cv position bounded facts _ initials _ := by
    rw [model_denotation]
    exact model_model_equation text context position facts initials tv cv bounded
  workers := ⟨Workers.modelOutputs modelCalls,
    Workers.model_refinement workerInput workerChainInput modelCalls, fun _ _ _ _ _ _ _ => rfl⟩
  tail text tv context cv result rv operator valid chained initials _ incoming _ originalStart _ := by
    rw [tail_denotation]
    exact model_tail_equation text context result operator chained initials incoming originalStart tv cv rv.1 valid

/-- The complete source-equation and contract interface is inhabited. -/
theorem source_interface_inhabited : ∃ calls, HelperMeaning calls ∧ DefinitionEquations calls ∧ Contracts calls :=
  ⟨modelCalls, model_helper_meaning, model_definition_equations, model_contracts⟩

end Silver.Predicate.Native
