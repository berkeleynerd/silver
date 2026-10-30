module

public import Silver.PredicateNativeModel

@[expose] public section
namespace Silver.Predicate.Native
open Compose Compose.Expressions

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000

/-- Native range types and the checked cursor/facts preconditions. -/
def ValidResult (text : Source) (context : Context) (result : ConditionResult) : Prop :=
  result.after ≤ text.length + 1 ∧ ValidFlow context result.whenTrue ∧ ValidFlow context result.whenFalse

/-- Equations of the actual typed function bodies after substituting the
independently checked helper interpretations. The condition wrapper is its exact
executable expression call. No scanner equivalence is assumed. -/
structure Equations (calls : Calls) : Prop where
  primary : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    ∀ initials, ArrayBindings.ValidInitials initials →
    calls.primary text context position facts initials = primaryEquation (interpreted calls) text context position facts initials
  booleanFactor : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    ∀ initials, ArrayBindings.ValidInitials initials →
    calls.booleanFactor text context position facts initials = booleanFactorEquation (interpreted calls) text context position facts initials
  booleanRelation : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    ∀ initials, ArrayBindings.ValidInitials initials →
    calls.booleanRelation text context position facts initials = booleanRelationEquation (interpreted calls) text context position facts initials
  relation : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    ∀ initials, ArrayBindings.ValidInitials initials →
    calls.relation text context position facts initials = relationEquation (interpreted calls) text context position facts initials
  model : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    ∀ initials, ArrayBindings.ValidInitials initials →
    calls.model text context position facts initials = modelEquation (interpreted calls) text context position facts initials
  condition : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    ∀ initials, ArrayBindings.ValidInitials initials →
    calls.condition text context position facts initials = calls.model text context position facts initials
  tail : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ result,
    ValidResult text context result → ∀ operator, operator.isChain = true → ∀ chained,
    ∀ initials, ArrayBindings.ValidInitials initials → ∀ incoming, ValidFlow context incoming →
    ∀ originalStart, originalStart ≤ text.length + 1 →
    calls.tail text context result operator chained initials incoming originalStart =
      tailEquation (interpreted calls) text context result operator chained initials incoming originalStart

@[simp] theorem interpreted_model : interpreted modelCalls = modelCalls := rfl

theorem model_equations : Equations modelCalls where
  primary text tv context cv position bounded facts _ initials _ := by
    rw [interpreted_model]
    exact model_primary_equation text context position facts initials bounded
  booleanFactor text tv context cv position bounded facts _ initials _ := by
    rw [interpreted_model]
    exact model_booleanFactor_equation text context position facts initials bounded
  booleanRelation text tv context cv position bounded facts _ initials _ := by
    rw [interpreted_model]
    exact model_booleanRelation_equation text context position facts initials tv cv.1 bounded
  relation text tv context cv position bounded facts _ initials _ := by
    rw [interpreted_model]
    exact model_relation_equation text context position facts initials bounded
  model text tv context cv position bounded facts _ initials _ := by
    rw [interpreted_model]
    exact model_model_equation text context position facts initials tv cv bounded
  condition _ _ _ _ _ _ _ _ _ _ := rfl
  tail text tv context cv result bounded operator valid chained initials _ incoming _ originalStart _ := by
    rw [interpreted_model]
    exact model_tail_equation text context result operator chained initials incoming originalStart tv cv bounded.1 valid

theorem model_primary_valid (text : Source) (tv : ValidText text) (context : Context)
    (cv : ValidContext text context) (position : Nat) (bounded : position ≤ text.length + 1)
    (facts : ActiveFlow) (fv : ValidFlow context facts) (initials : ArrayBindings.Initials) :
    ValidResult text context (readPrimary text context.model position facts initials) := by
  have paths := readPrimary_bounded text context.model position facts fv.1 initials
  have scalars := primary_flowReady text context.model position facts cv.base fv.2 initials
  exact ⟨primary_bound text context.model position facts tv cv.1 bounded,
    ⟨paths.1, scalars.1⟩, ⟨paths.2, scalars.2⟩⟩

theorem model_booleanFactor_valid (text : Source) (tv : ValidText text) (context : Context)
    (cv : ValidContext text context) (position : Nat) (bounded : position ≤ text.length + 1)
    (facts : ActiveFlow) (fv : ValidFlow context facts) (initials : ArrayBindings.Initials) :
    ValidResult text context (readBooleanFactor text context.model position facts initials) := by
  have paths := readBooleanFactor_bounded text context.model position facts fv.1 initials
  have scalars := booleanFactor_flowReady text context.model position facts cv.base fv.2 initials
  exact ⟨booleanFactor_bound text context.model position facts tv cv.1 bounded,
    ⟨paths.1, scalars.1⟩, ⟨paths.2, scalars.2⟩⟩

theorem model_booleanRelation_valid (text : Source) (tv : ValidText text) (context : Context)
    (cv : ValidContext text context) (position : Nat) (bounded : position ≤ text.length + 1)
    (facts : ActiveFlow) (fv : ValidFlow context facts) (initials : ArrayBindings.Initials) :
    ValidResult text context (readBooleanRelation text context.model position facts initials) := by
  have paths := readBooleanRelation_bounded text context.model position facts fv.1 initials
  have scalars := booleanRelation_flowReady text context.model position facts cv.base fv.2 initials
  exact ⟨booleanRelation_bound text context.model position facts tv cv.1 bounded,
    ⟨paths.1, scalars.1⟩, ⟨paths.2, scalars.2⟩⟩

theorem model_relation_valid (text : Source) (tv : ValidText text) (context : Context)
    (cv : ValidContext text context) (position : Nat) (bounded : position ≤ text.length + 1)
    (facts : ActiveFlow) (fv : ValidFlow context facts) (initials : ArrayBindings.Initials) :
    ValidResult text context (readRelation text context.model position facts initials) := by
  have paths := readRelation_bounded text context.model position facts fv.1 initials
  have scalars := relation_flowReady text context.model position facts cv.base fv.2 initials
  exact ⟨relation_bound text context.model position facts tv cv.1 bounded,
    ⟨paths.1, scalars.1⟩, ⟨paths.2, scalars.2⟩⟩

theorem model_condition_valid (text : Source) (tv : ValidText text) (context : Context)
    (cv : ValidContext text context) (position : Nat) (bounded : position ≤ text.length + 1)
    (facts : ActiveFlow) (fv : ValidFlow context facts) (initials : ArrayBindings.Initials) :
    ValidResult text context (readCondition text context.model position facts initials) := by
  have paths := readCondition_bounded text context.model position facts fv.1 initials
  have scalars := condition_flowReady text context.model position facts cv.base fv.2 initials
  exact ⟨condition_bound text context.model position facts tv cv.1 bounded,
    ⟨paths.1, scalars.1⟩, ⟨paths.2, scalars.2⟩⟩

mutual
  theorem primary_unique (calls : Calls) (equations : Equations calls) (text : Source)
      (tv : ValidText text) (context : Context) (cv : ValidContext text context) (position : Nat)
      (bounded : position ≤ text.length + 1) (facts : ActiveFlow) (fv : ValidFlow context facts)
      (initials : ArrayBindings.Initials) (iv : ArrayBindings.ValidInitials initials) :
      calls.primary text context position facts initials = readPrimary text context.model position facts initials := by
    rw [equations.primary text tv context cv position bounded facts fv initials iv,
      ← show modelCalls.primary text context position facts initials = readPrimary text context.model position facts initials from rfl,
      model_primary_equation text context position facts initials bounded]
    unfold primaryEquation
    dsimp only [interpreted]
    by_cases zero : position = 0
    · simp [zero]
    · simp only [zero, ↓reduceIte]
      by_cases found : modelCalls.take text position .leftParenthesis ≠ 0
      · rw [ite_eq_left found, ite_eq_left found]
        have nextBound := takeModel_valid text position .leftParenthesis bounded
        have advanced := remaining_lt nextBound (takeModel_progress text position .leftParenthesis bounded found)
        rw [model_unique calls equations text tv context cv (modelCalls.take text position .leftParenthesis) nextBound facts fv initials iv]
        rfl
      · simp only [found, ↓reduceIte]
  termination_by (remainingAt text position, 1)

  theorem booleanFactor_unique (calls : Calls) (equations : Equations calls) (text : Source)
      (tv : ValidText text) (context : Context) (cv : ValidContext text context) (position : Nat)
      (bounded : position ≤ text.length + 1) (facts : ActiveFlow) (fv : ValidFlow context facts)
      (initials : ArrayBindings.Initials) (iv : ArrayBindings.ValidInitials initials) :
      calls.booleanFactor text context position facts initials = readBooleanFactor text context.model position facts initials := by
    rw [equations.booleanFactor text tv context cv position bounded facts fv initials iv,
      ← show modelCalls.booleanFactor text context position facts initials = readBooleanFactor text context.model position facts initials from rfl,
      model_booleanFactor_equation text context position facts initials bounded]
    unfold booleanFactorEquation
    dsimp only [interpreted]
    by_cases absent : modelCalls.take text position .notKeyword = 0
    · simp only [absent, ↓reduceIte]
      exact primary_unique calls equations text tv context cv position bounded facts fv initials iv
    · simp only [absent, ↓reduceIte]
      have nextBound := takeModel_valid text position .notKeyword bounded
      have advanced := remaining_lt nextBound (takeModel_progress text position .notKeyword bounded absent)
      rw [primary_unique calls equations text tv context cv (modelCalls.take text position .notKeyword) nextBound facts fv initials iv]
      rfl
  termination_by (remainingAt text position, 2)

  theorem booleanRelation_unique (calls : Calls) (equations : Equations calls) (text : Source)
      (tv : ValidText text) (context : Context) (cv : ValidContext text context) (position : Nat)
      (bounded : position ≤ text.length + 1) (facts : ActiveFlow) (fv : ValidFlow context facts)
      (initials : ArrayBindings.Initials) (iv : ArrayBindings.ValidInitials initials) :
      calls.booleanRelation text context position facts initials = readBooleanRelation text context.model position facts initials := by
    rw [equations.booleanRelation text tv context cv position bounded facts fv initials iv,
      ← show modelCalls.booleanRelation text context position facts initials = readBooleanRelation text context.model position facts initials from rfl,
      model_booleanRelation_equation text context position facts initials tv cv.1 bounded]
    unfold booleanRelationEquation
    dsimp only [interpreted]
    rw [booleanFactor_unique calls equations text tv context cv position bounded facts fv initials iv]
    simp only [show modelCalls.booleanFactor = (fun t c p f i => readBooleanFactor t c.model p f i) from rfl]
    let left := readBooleanFactor text context.model position facts initials
    have leftValid := model_booleanFactor_valid text tv context cv position bounded facts fv initials
    by_cases leftZero : left.after = 0
    · simp only [show (readBooleanFactor text context.model position facts initials).after = 0 from leftZero, ↓reduceIte]
    · simp only [show (readBooleanFactor text context.model position facts initials).after ≠ 0 from leftZero, ↓reduceIte]
      by_cases comparisonZero : (comparisonAt text left.after).after = 0
      · simp only [show (modelCalls.comparison text (readBooleanFactor text context.model position facts initials).after).after = 0 from comparisonZero, ↓reduceIte]
      · simp only [show (modelCalls.comparison text (readBooleanFactor text context.model position facts initials).after).after ≠ 0 from comparisonZero, ↓reduceIte]
        have nextBound := comparison_bound text left.after leftValid.1
        have nextProgress := comparison_progress text left.after leftValid.1 comparisonZero
        have leftProgress := booleanFactor_progress text context.model position facts tv cv.1 bounded leftZero
        have advanced := remaining_lt nextBound (Nat.lt_trans leftProgress nextProgress)
        simp only [show modelCalls.comparison = comparisonAt from rfl]
        dsimp only [left] at nextBound
        rw [booleanFactor_unique calls equations text tv context cv (comparisonAt text (readBooleanFactor text context.model position facts initials).after).after nextBound facts fv initials iv]
  termination_by (remainingAt text position, 3)

  theorem relation_unique (calls : Calls) (equations : Equations calls) (text : Source)
      (tv : ValidText text) (context : Context) (cv : ValidContext text context) (position : Nat)
      (bounded : position ≤ text.length + 1) (facts : ActiveFlow) (fv : ValidFlow context facts)
      (initials : ArrayBindings.Initials) (iv : ArrayBindings.ValidInitials initials) :
      calls.relation text context position facts initials = readRelation text context.model position facts initials := by
    rw [equations.relation text tv context cv position bounded facts fv initials iv,
      ← show modelCalls.relation text context position facts initials = readRelation text context.model position facts initials from rfl,
      model_relation_equation text context position facts initials bounded]
    unfold relationEquation
    dsimp only [interpreted]
    rw [booleanRelation_unique calls equations text tv context cv position bounded facts fv initials iv]
    rfl
  termination_by (remainingAt text position, 4)

  theorem model_unique (calls : Calls) (equations : Equations calls) (text : Source)
      (tv : ValidText text) (context : Context) (cv : ValidContext text context) (position : Nat)
      (bounded : position ≤ text.length + 1) (facts : ActiveFlow) (fv : ValidFlow context facts)
      (initials : ArrayBindings.Initials) (iv : ArrayBindings.ValidInitials initials) :
      calls.model text context position facts initials = readCondition text context.model position facts initials := by
    rw [equations.model text tv context cv position bounded facts fv initials iv,
      ← show modelCalls.model text context position facts initials = readCondition text context.model position facts initials from rfl,
      model_model_equation text context position facts initials tv cv bounded]
    unfold modelEquation
    dsimp only [interpreted]
    rw [relation_unique calls equations text tv context cv position bounded facts fv initials iv]
    simp only [show modelCalls.relation = (fun t c p f i => readRelation t c.model p f i) from rfl]
    have resultValid := model_relation_valid text tv context cv position bounded facts fv initials
    by_cases zero : (readRelation text context.model position facts initials).after = 0
    · simp only [zero, ↓reduceIte]
    · simp only [zero, ↓reduceIte]
      have advanced := remaining_lt resultValid.1 (relation_progress text context.model position facts tv cv.1 bounded zero)
      rw [tail_unique calls equations text tv context cv _ resultValid .shortAnd (by rfl) false initials iv facts fv position bounded]
      rfl
  termination_by (remainingAt text position, 5)

  theorem condition_unique (calls : Calls) (equations : Equations calls) (text : Source)
      (tv : ValidText text) (context : Context) (cv : ValidContext text context) (position : Nat)
      (bounded : position ≤ text.length + 1) (facts : ActiveFlow) (fv : ValidFlow context facts)
      (initials : ArrayBindings.Initials) (iv : ArrayBindings.ValidInitials initials) :
      calls.condition text context position facts initials = readCondition text context.model position facts initials := by
    rw [equations.condition text tv context cv position bounded facts fv initials iv]
    exact model_unique calls equations text tv context cv position bounded facts fv initials iv
  theorem tail_unique (calls : Calls) (equations : Equations calls) (text : Source)
      (tv : ValidText text) (context : Context) (cv : ValidContext text context) (result : ConditionResult)
      (rv : ValidResult text context result) (operator : ChainKind) (ov : operator.isChain = true) (chained : Bool)
      (initials : ArrayBindings.Initials) (iv : ArrayBindings.ValidInitials initials)
      (incoming : ActiveFlow) (incomingValid : ValidFlow context incoming)
      (originalStart : Nat) (startBound : originalStart ≤ text.length + 1) :
      calls.tail text context result operator chained initials incoming originalStart =
        conditionTail text context.model result (chainState operator chained) incoming initials originalStart := by
    rw [equations.tail text tv context cv result rv operator ov chained initials iv incoming incomingValid originalStart startBound,
      ← show modelCalls.tail text context result operator chained initials incoming originalStart =
          conditionTail text context.model result (chainState operator chained) incoming initials originalStart from rfl,
      model_tail_equation text context result operator chained initials incoming originalStart tv cv rv.1 ov]
    unfold tailEquation
    dsimp only [interpreted]
    by_cases zero : result.after = 0
    · simp [zero]
    · simp only [zero, ↓reduceIte]
      let selected := modelCalls.chainToken text result.after
      by_cases selectedZero : selected = .noChain
      · simp only [show modelCalls.chainToken text result.after = .noChain from selectedZero, ↓reduceIte]
      · simp only [show modelCalls.chainToken text result.after ≠ .noChain from selectedZero, ↓reduceIte]
        by_cases wrong : ((chained && decide (operator ≠ selected)) ||
            (decide (selected = .eagerXor) && !modelCalls.xorFree text originalStart result.after)) = true
        · simp only [show ((chained && decide (operator ≠ modelCalls.chainToken text result.after)) ||
              (decide (modelCalls.chainToken text result.after = .eagerXor) && !modelCalls.xorFree text originalStart result.after)) = true from wrong, ↓reduceIte]
        · simp only [show ((chained && decide (operator ≠ modelCalls.chainToken text result.after)) ||
              (decide (modelCalls.chainToken text result.after = .eagerXor) && !modelCalls.xorFree text originalStart result.after)) ≠ true from wrong, Bool.false_eq_true, ↓reduceIte]
          by_cases afterZero : modelCalls.chainAfter text result.after selected = 0
          · simp only [show modelCalls.chainAfter text result.after (modelCalls.chainToken text result.after) = 0 from afterZero, ↓reduceIte]
          · simp only [show modelCalls.chainAfter text result.after (modelCalls.chainToken text result.after) ≠ 0 from afterZero, ↓reduceIte]
            have afterEq : modelCalls.chainAfter text result.after selected = Predicate.chainAfter text result.after selected.predicate := by
              simp only [modelCalls, chainAfterModel, selectedZero, ↓reduceIte]
            have afterBound : modelCalls.chainAfter text result.after selected ≤ text.length + 1 := by
              rw [afterEq]; exact Predicate.chainAfter_bound text result.after selected.predicate rv.1
            have afterProgress : result.after < modelCalls.chainAfter text result.after selected := by
              rw [afterEq] at afterZero ⊢
              exact chainAfter_progress text result.after selected.predicate rv.1 afterZero
            have advanced := remaining_lt afterBound afterProgress
            let selectedFacts := if selected = .shortAnd then result.whenTrue else if selected = .shortOr then result.whenFalse else incoming
            have selectedValid : ValidFlow context selectedFacts := by
              dsimp only [selectedFacts]
              split
              · exact rv.2.1
              · split
                · exact rv.2.2
                · exact incomingValid
            rw [relation_unique calls equations text tv context cv (modelCalls.chainAfter text result.after selected) afterBound selectedFacts selectedValid initials iv]
            simp only [show modelCalls.relation = (fun t c p f i => readRelation t c.model p f i) from rfl]
            let right := readRelation text context.model (modelCalls.chainAfter text result.after selected) selectedFacts initials
            have rightValid := model_relation_valid text tv context cv _ afterBound selectedFacts selectedValid initials
            change (if right.after = 0 ∨ (selected = .eagerXor ∧ !modelCalls.xorFree text (modelCalls.chainAfter text result.after selected) right.after) then _ else _) =
              (if right.after = 0 ∨ (selected = .eagerXor ∧ !modelCalls.xorFree text (modelCalls.chainAfter text result.after selected) right.after) then _ else _)
            by_cases rejected : right.after = 0 ∨ (selected = .eagerXor ∧ !modelCalls.xorFree text (modelCalls.chainAfter text result.after selected) right.after)
            · simp only [rejected, ↓reduceIte]
            · simp only [rejected, ↓reduceIte]
              let next : ConditionResult := if selected = .shortAnd then
                ⟨right.after, right.whenTrue, modelCalls.join result.whenFalse right.whenFalse⟩
                else if selected = .shortOr then
                  ⟨right.after, modelCalls.join result.whenTrue right.whenTrue, right.whenFalse⟩
                else ⟨right.after, incoming, incoming⟩
              have nextAfter : next.after = right.after := by dsimp only [next]; split <;> first | rfl | (split <;> rfl)
              have nextValid : ValidResult text context next := by
                refine ⟨?_, ?_⟩
                · rw [nextAfter]; exact rightValid.1
                · dsimp only [next]; split
                  · exact ⟨rightValid.2.1, ValidFlow.join cv.base rv.2.2 rightValid.2.2⟩
                  · split
                    · exact ⟨ValidFlow.join cv.base rv.2.1 rightValid.2.1, rightValid.2.2⟩
                    · exact ⟨incomingValid, incomingValid⟩
              have rightProgress := relation_progress text context.model _ _ tv cv.1 afterBound (not_or.mp rejected).1
              have nextAdvanced : remainingAt text next.after < remainingAt text result.after := by
                rw [nextAfter]
                exact remaining_lt rightValid.1 (Nat.lt_trans afterProgress rightProgress)
              have selectedChain : selected.isChain = true := by simp [ChainKind.isChain, selectedZero]
              exact tail_unique calls equations text tv context cv next nextValid selected selectedChain true initials iv incoming incomingValid originalStart startBound
  termination_by (remainingAt text result.after, 6)

end

end Silver.Predicate.Native
