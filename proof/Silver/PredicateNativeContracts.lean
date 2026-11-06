module

public import Silver.PredicateNativeCorrespondence

@[expose] public section

namespace Silver.Predicate.Native

/-- Checked native cursor and flow domains, including the immutable initializer
array and the condition's original source cursor. -/
structure Contracts (calls : Calls) : Prop where
  comparison : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
    (calls.comparison text position).after ≤ text.length + 1
  length : ∀ text, ValidText text → ∀ context, ValidContext text context →
    ∀ position, position ≤ text.length + 1 → ∀ literal,
    (calls.length text context position literal).after ≤ text.length + 1
  booleanArray : ∀ text, ValidText text → ∀ context, ValidContext text context →
    ∀ position, position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    calls.booleanArray text context position facts ≤ text.length + 1 ∧
      (calls.booleanArray text context position facts = 0 ∨ position < calls.booleanArray text context position facts)
  booleanAtom : ∀ text, ValidText text → ∀ context, ValidContext text context →
    ∀ position, position ≤ text.length + 1 →
    calls.booleanAtom text context position ≤ text.length + 1 ∧
      (calls.booleanAtom text context position = 0 ∨ position < calls.booleanAtom text context position)
  primary : ∀ text, ValidText text → ∀ context, ValidContext text context →
    ∀ position, position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    ∀ initials, ArrayBindings.ValidInitials initials →
    ValidResult text context (calls.primary text context position facts initials) ∧
      ((calls.primary text context position facts initials).after = 0 ∨ position < (calls.primary text context position facts initials).after)
  booleanFactor : ∀ text, ValidText text → ∀ context, ValidContext text context →
    ∀ position, position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    ∀ initials, ArrayBindings.ValidInitials initials →
    ValidResult text context (calls.booleanFactor text context position facts initials) ∧
      ((calls.booleanFactor text context position facts initials).after = 0 ∨ position < (calls.booleanFactor text context position facts initials).after)
  booleanRelation : ∀ text, ValidText text → ∀ context, ValidContext text context →
    ∀ position, position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    ∀ initials, ArrayBindings.ValidInitials initials →
    ValidResult text context (calls.booleanRelation text context position facts initials) ∧
      ((calls.booleanRelation text context position facts initials).after = 0 ∨ position < (calls.booleanRelation text context position facts initials).after)
  relation : ∀ text, ValidText text → ∀ context, ValidContext text context →
    ∀ position, position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    ∀ initials, ArrayBindings.ValidInitials initials →
    ValidResult text context (calls.relation text context position facts initials) ∧
      ((calls.relation text context position facts initials).after = 0 ∨ position < (calls.relation text context position facts initials).after)
  model : ∀ text, ValidText text → ∀ context, ValidContext text context →
    ∀ position, position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    ∀ initials, ArrayBindings.ValidInitials initials →
    ValidResult text context (calls.model text context position facts initials) ∧
      ((calls.model text context position facts initials).after = 0 ∨ position < (calls.model text context position facts initials).after)
  condition : ∀ text, ValidText text → ∀ context, ValidContext text context →
    ∀ position, position ≤ text.length + 1 → ∀ facts, ValidFlow context facts →
    ∀ initials, ArrayBindings.ValidInitials initials →
    ValidResult text context (calls.condition text context position facts initials) ∧
      ((calls.condition text context position facts initials).after = 0 ∨ position < (calls.condition text context position facts initials).after)
  tail : ∀ text, ValidText text → ∀ context, ValidContext text context →
    ∀ result, ValidResult text context result → ∀ operator, operator.isChain = true → ∀ chained,
    ∀ initials, ArrayBindings.ValidInitials initials → ∀ incoming, ValidFlow context incoming →
    ∀ originalStart, originalStart ≤ text.length + 1 →
    ValidResult text context (calls.tail text context result operator chained initials incoming originalStart) ∧
      ((calls.tail text context result operator chained initials incoming originalStart).after = 0 ∨
        result.after ≤ (calls.tail text context result operator chained initials incoming originalStart).after)

theorem model_contracts : Contracts modelCalls where
  comparison text _ position bounded := comparison_bound text position bounded
  length text _ context _ position bounded literal := length_bound text context.model position literal bounded
  booleanArray text _ context _ position bounded facts _ := by
    change booleanArrayAfter text context.model position facts ≤ text.length + 1 ∧ _
    by_cases zero : booleanArrayAfter text context.model position facts = 0
    · exact ⟨by simp [zero], Or.inl zero⟩
    · exact ⟨(booleanArray_sound zero).2, Or.inr (booleanArray_progress text context.model position facts zero)⟩
  booleanAtom text _ context _ position bounded := by
    change booleanAtomAfter text context.model position ≤ text.length + 1 ∧ _
    by_cases zero : booleanAtomAfter text context.model position = 0
    · exact ⟨by simp [zero], Or.inl zero⟩
    · exact ⟨(booleanAtom_sound zero).2, Or.inr (booleanAtom_progress text context.model position bounded zero)⟩
  primary text tv context cv position bounded facts fv initials _ := by
    refine ⟨model_primary_valid text tv context cv position bounded facts fv initials, ?_⟩
    by_cases zero : (readPrimary text context.model position facts initials).after = 0
    · exact Or.inl zero
    · exact Or.inr (primary_progress text context.model position facts tv cv.1 bounded zero)
  booleanFactor text tv context cv position bounded facts fv initials _ := by
    refine ⟨model_booleanFactor_valid text tv context cv position bounded facts fv initials, ?_⟩
    by_cases zero : (readBooleanFactor text context.model position facts initials).after = 0
    · exact Or.inl zero
    · exact Or.inr (booleanFactor_progress text context.model position facts tv cv.1 bounded zero)
  booleanRelation text tv context cv position bounded facts fv initials _ := by
    refine ⟨model_booleanRelation_valid text tv context cv position bounded facts fv initials, ?_⟩
    by_cases zero : (readBooleanRelation text context.model position facts initials).after = 0
    · exact Or.inl zero
    · exact Or.inr (booleanRelation_progress text context.model position facts tv cv.1 bounded zero)
  relation text tv context cv position bounded facts fv initials _ := by
    refine ⟨model_relation_valid text tv context cv position bounded facts fv initials, ?_⟩
    by_cases zero : (readRelation text context.model position facts initials).after = 0
    · exact Or.inl zero
    · exact Or.inr (relation_progress text context.model position facts tv cv.1 bounded zero)
  model text tv context cv position bounded facts fv initials _ := by
    refine ⟨model_condition_valid text tv context cv position bounded facts fv initials, ?_⟩
    by_cases zero : (readCondition text context.model position facts initials).after = 0
    · exact Or.inl zero
    · exact Or.inr (condition_progress text context.model position facts zero)
  condition text tv context cv position bounded facts fv initials _ := by
    refine ⟨model_condition_valid text tv context cv position bounded facts fv initials, ?_⟩
    by_cases zero : (readCondition text context.model position facts initials).after = 0
    · exact Or.inl zero
    · exact Or.inr (condition_progress text context.model position facts zero)
  tail text tv context cv result rv operator _ chained initials _ incoming incomingValid originalStart _ := by
    refine ⟨⟨tail_bound text context.model result _ incoming tv cv.1 rv.1,
      ?_, ?_⟩, ?_⟩
    · exact ⟨(conditionTail_bounded text context.model result _ incoming ⟨rv.2.1.1, rv.2.2.1⟩ incomingValid.1 initials originalStart).1,
        (tail_flowReady text context.model result _ incoming cv.base ⟨rv.2.1.2, rv.2.2.2⟩ incomingValid.2 initials originalStart).1⟩
    · exact ⟨(conditionTail_bounded text context.model result _ incoming ⟨rv.2.1.1, rv.2.2.1⟩ incomingValid.1 initials originalStart).2,
        (tail_flowReady text context.model result _ incoming cv.base ⟨rv.2.1.2, rv.2.2.2⟩ incomingValid.2 initials originalStart).2⟩
    · by_cases zero : (conditionTail text context.model result (chainState operator chained) incoming initials originalStart).after = 0
      · exact Or.inl zero
      · exact Or.inr (tail_nondecreasing text context.model result _ incoming zero)

end Silver.Predicate.Native
