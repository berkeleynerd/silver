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
    calls.primary text context position facts = primaryEquation (interpreted calls) text context position facts
  relation : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    calls.relation text context position facts = relationEquation (interpreted calls) text context position facts
  model : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    calls.model text context position facts = modelEquation (interpreted calls) text context position facts
  condition : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ position,
    position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    calls.condition text context position facts = calls.model text context position facts
  tail : ∀ text, ValidText text → ∀ context, ValidContext text context → ∀ result,
    ValidResult text context result → ∀ operator, operator.isChain = true → ∀ chained,
    calls.tail text context result operator chained = tailEquation (interpreted calls) text context result operator chained

@[simp] theorem interpreted_model : interpreted modelCalls = modelCalls := rfl

theorem model_equations : Equations modelCalls where
  primary text _ context _ position bounded facts _ := by
    rw [interpreted_model]
    exact model_primary_equation text context position facts bounded
  relation text _ context _ position bounded facts _ := by
    rw [interpreted_model]
    exact model_relation_equation text context position facts bounded
  model text tv context cv position bounded facts _ := by
    rw [interpreted_model]
    exact model_model_equation text context position facts tv cv bounded
  condition _ _ _ _ _ _ _ _ := rfl
  tail text tv context cv result bounded operator valid chained := by
    rw [interpreted_model]
    exact model_tail_equation text context result operator chained tv cv bounded.1 valid

theorem model_primary_valid (text : Source) (tv : ValidText text) (context : Context)
    (cv : ValidContext text context) (position : Nat) (bounded : position ≤ text.length + 1)
    (facts : ActiveFlow) (fv : ValidFlow context facts) :
    ValidResult text context (readPrimary text context.model position facts) := by
  have paths := readPrimary_bounded text context.model position facts fv.1
  have scalars := primary_flowReady text context.model position facts cv.base fv.2
  exact ⟨primary_bound text context.model position facts tv cv.1 bounded,
    ⟨paths.1, scalars.1⟩, ⟨paths.2, scalars.2⟩⟩

theorem model_relation_valid (text : Source) (tv : ValidText text) (context : Context)
    (cv : ValidContext text context) (position : Nat) (bounded : position ≤ text.length + 1)
    (facts : ActiveFlow) (fv : ValidFlow context facts) :
    ValidResult text context (readRelation text context.model position facts) := by
  have paths := readRelation_bounded text context.model position facts fv.1
  have scalars := relation_flowReady text context.model position facts cv.base fv.2
  exact ⟨relation_bound text context.model position facts tv cv.1 bounded,
    ⟨paths.1, scalars.1⟩, ⟨paths.2, scalars.2⟩⟩

theorem model_condition_valid (text : Source) (tv : ValidText text) (context : Context)
    (cv : ValidContext text context) (position : Nat) (bounded : position ≤ text.length + 1)
    (facts : ActiveFlow) (fv : ValidFlow context facts) :
    ValidResult text context (readCondition text context.model position facts) := by
  have paths := readCondition_bounded text context.model position facts fv.1
  have scalars := condition_flowReady text context.model position facts cv.base fv.2
  exact ⟨condition_bound text context.model position facts tv cv.1 bounded,
    ⟨paths.1, scalars.1⟩, ⟨paths.2, scalars.2⟩⟩


mutual
  theorem primary_unique (calls : Calls) (equations : Equations calls) (text : Source)
      (tv : ValidText text) (context : Context) (cv : ValidContext text context) (position : Nat)
      (bounded : position ≤ text.length + 1) (facts : ActiveFlow) (fv : ValidFlow context facts) :
      calls.primary text context position facts = readPrimary text context.model position facts := by
    rw [equations.primary text tv context cv position bounded facts fv,
      ← show modelCalls.primary text context position facts = readPrimary text context.model position facts from rfl,
      model_primary_equation text context position facts bounded]
    unfold primaryEquation
    dsimp only [interpreted]
    by_cases zero : position = 0
    · simp [zero]
    · simp only [zero, ↓reduceIte]
      by_cases found : modelCalls.take text position .leftParenthesis ≠ 0
      · rw [ite_eq_left found, ite_eq_left found]
        have nextBound := takeModel_valid text position .leftParenthesis bounded
        have advanced := remaining_lt nextBound (takeModel_progress text position .leftParenthesis bounded found)
        rw [model_unique calls equations text tv context cv (modelCalls.take text position .leftParenthesis) nextBound facts fv]
        rfl
      · simp only [found, ↓reduceIte]
  termination_by (remainingAt text position, 1)

  theorem relation_unique (calls : Calls) (equations : Equations calls) (text : Source)
      (tv : ValidText text) (context : Context) (cv : ValidContext text context) (position : Nat)
      (bounded : position ≤ text.length + 1) (facts : ActiveFlow) (fv : ValidFlow context facts) :
      calls.relation text context position facts = readRelation text context.model position facts := by
    rw [equations.relation text tv context cv position bounded facts fv,
      ← show modelCalls.relation text context position facts = readRelation text context.model position facts from rfl,
      model_relation_equation text context position facts bounded]
    unfold relationEquation
    dsimp only [interpreted]
    by_cases zero : position = 0
    · simp [zero]
    · simp only [zero, ↓reduceIte]
      by_cases found : modelCalls.take text position .notKeyword ≠ 0
      · rw [ite_eq_left found, ite_eq_left found]
        have nextBound := takeModel_valid text position .notKeyword bounded
        have advanced := remaining_lt nextBound (takeModel_progress text position .notKeyword bounded found)
        rw [primary_unique calls equations text tv context cv (modelCalls.take text position .notKeyword) nextBound facts fv]
        rfl
      · simp only [found, ↓reduceIte]
        rw [primary_unique calls equations text tv context cv position bounded facts fv]
        rfl
  termination_by (remainingAt text position, 2)

  theorem model_unique (calls : Calls) (equations : Equations calls) (text : Source)
      (tv : ValidText text) (context : Context) (cv : ValidContext text context) (position : Nat)
      (bounded : position ≤ text.length + 1) (facts : ActiveFlow) (fv : ValidFlow context facts) :
      calls.model text context position facts = readCondition text context.model position facts := by
    rw [equations.model text tv context cv position bounded facts fv,
      ← show modelCalls.model text context position facts = readCondition text context.model position facts from rfl,
      model_model_equation text context position facts tv cv bounded]
    unfold modelEquation
    dsimp only [interpreted]
    rw [relation_unique calls equations text tv context cv position bounded facts fv]
    simp only [show modelCalls.relation = (fun t c p f => readRelation t c.model p f) from rfl]
    have resultValid := model_relation_valid text tv context cv position bounded facts fv
    by_cases zero : (readRelation text context.model position facts).after = 0
    · simp only [zero, ↓reduceIte]
    · simp only [zero, ↓reduceIte]
      have advanced := remaining_lt resultValid.1 (relation_progress text context.model position facts tv cv.1 bounded zero)
      rw [tail_unique calls equations text tv context cv _ resultValid .andKeyword (by rfl) false]
      rfl
  termination_by (remainingAt text position, 3)

  theorem condition_unique (calls : Calls) (equations : Equations calls) (text : Source)
      (tv : ValidText text) (context : Context) (cv : ValidContext text context) (position : Nat)
      (bounded : position ≤ text.length + 1) (facts : ActiveFlow) (fv : ValidFlow context facts) :
      calls.condition text context position facts = readCondition text context.model position facts := by
    rw [equations.condition text tv context cv position bounded facts fv]
    exact model_unique calls equations text tv context cv position bounded facts fv
  theorem tail_unique (calls : Calls) (equations : Equations calls) (text : Source)
      (tv : ValidText text) (context : Context) (cv : ValidContext text context) (result : ConditionResult)
      (rv : ValidResult text context result) (operator : Token) (ov : operator.isChain = true) (chained : Bool) :
      calls.tail text context result operator chained = conditionTail text context.model result (chainState operator chained) := by
    rw [equations.tail text tv context cv result rv operator ov chained,
      ← show modelCalls.tail text context result operator chained = conditionTail text context.model result (chainState operator chained) from rfl,
      model_tail_equation text context result operator chained tv cv rv.1 ov]
    unfold tailEquation
    dsimp only [interpreted]
    by_cases zero : result.after = 0
    · simp [zero]
    · simp only [zero, ↓reduceIte]
      by_cases selected : (modelCalls.chainToken text result.after).isChain = true
      · simp only [selected, Bool.not_true, Bool.false_eq_true, ↓reduceIte]
        by_cases wrong : (chained && decide (operator ≠ modelCalls.chainToken text result.after)) = true
        · simp only [wrong, ↓reduceIte]
        · simp only [wrong, Bool.false_eq_true, ↓reduceIte]
          by_cases afterZero : modelCalls.chainAfter text result.after (modelCalls.chainToken text result.after) = 0
          · simp only [afterZero, ↓reduceIte]
          · have afterBound : modelCalls.chainAfter text result.after (modelCalls.chainToken text result.after) ≤ text.length + 1 := Predicate.chainAfter_bound text result.after (modelCalls.chainToken text result.after).chain rv.1
            have afterProgress := chainAfter_progress text result.after (modelCalls.chainToken text result.after).chain rv.1 afterZero
            have advanced := remaining_lt afterBound afterProgress
            have selectedFacts : ValidFlow context (if modelCalls.chainToken text result.after = .andKeyword then result.whenTrue else result.whenFalse) := by
              split <;> first | exact rv.2.1 | exact rv.2.2
            rw [relation_unique calls equations text tv context cv (modelCalls.chainAfter text result.after (modelCalls.chainToken text result.after)) afterBound _ selectedFacts]
            simp only [show modelCalls.relation = (fun t c p f => readRelation t c.model p f) from rfl]
            let right := readRelation text context.model
              (modelCalls.chainAfter text result.after (modelCalls.chainToken text result.after))
              (if modelCalls.chainToken text result.after = .andKeyword then result.whenTrue else result.whenFalse)
            have rightValid := model_relation_valid text tv context cv _ afterBound _ selectedFacts
            by_cases rightZero : right.after = 0
            · simp only [show (readRelation text context.model _ _).after = 0 from rightZero, afterZero, ↓reduceIte]
            · simp only [show (readRelation text context.model _ _).after ≠ 0 from rightZero, afterZero, ↓reduceIte]
              let next : ConditionResult := if modelCalls.chainToken text result.after = .andKeyword then
                ⟨right.after, right.whenTrue, modelCalls.join result.whenFalse right.whenFalse⟩
                else ⟨right.after, modelCalls.join result.whenTrue right.whenTrue, right.whenFalse⟩
              have nextAfter : next.after = right.after := by dsimp only [next]; split <;> rfl
              have nextValid : ValidResult text context next := by
                refine ⟨?_, ?_⟩
                · rw [nextAfter]; exact rightValid.1
                · dsimp only [next]; split
                  · exact ⟨rightValid.2.1, ValidFlow.join cv.base rv.2.2 rightValid.2.2⟩
                  · exact ⟨ValidFlow.join cv.base rv.2.1 rightValid.2.1, rightValid.2.2⟩
              have rightProgress := relation_progress text context.model _ _ tv cv.1 afterBound rightZero
              have nextAdvanced : remainingAt text next.after < remainingAt text result.after := by
                rw [nextAfter]
                exact remaining_lt rightValid.1 (Nat.lt_trans afterProgress rightProgress)
              exact tail_unique calls equations text tv context cv next nextValid _ selected true
      · simp only [show (modelCalls.chainToken text result.after).isChain = false from Bool.eq_false_iff.mpr selected, Bool.not_false, ↓reduceIte]
  termination_by (remainingAt text result.after, 4)
end

end Silver.Predicate.Native
