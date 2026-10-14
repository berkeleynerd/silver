module

public import Silver.PredicateNativeCorrespondence

@[expose] public section

namespace Silver.Predicate.Native

/-- Cursor refinements and the scalar ranges represented by native result types.
Failed parses remain within the same bounded result domain. Progress is required
only on success, matching the source's checked postconditions. -/
structure Contracts (calls : Calls) : Prop where
  comparison : ∀ text, ValidText text → ∀ position, position ≤ text.length + 1 →
    (calls.comparison text position).after ≤ text.length + 1
  length : ∀ text, ValidText text → ∀ context, ValidContext text context →
    ∀ position, position ≤ text.length + 1 → ∀ literal,
    (calls.length text context position literal).after ≤ text.length + 1
  primary : ∀ text, ValidText text → ∀ context, ValidContext text context →
    ∀ position, position ≤ text.length + 1 → ∀ facts, facts.Bounded →
    ValidResult text (calls.primary text context position facts) ∧
      ((calls.primary text context position facts).after = 0 ∨ position < (calls.primary text context position facts).after)
  relation : ∀ text, ValidText text → ∀ context, ValidContext text context →
    ∀ position, position ≤ text.length + 1 → ∀ facts, facts.Bounded →
    ValidResult text (calls.relation text context position facts) ∧
      ((calls.relation text context position facts).after = 0 ∨ position < (calls.relation text context position facts).after)
  model : ∀ text, ValidText text → ∀ context, ValidContext text context →
    ∀ position, position ≤ text.length + 1 → ∀ facts, facts.Bounded →
    ValidResult text (calls.model text context position facts) ∧
      ((calls.model text context position facts).after = 0 ∨ position < (calls.model text context position facts).after)
  condition : ∀ text, ValidText text → ∀ context, ValidContext text context →
    ∀ position, position ≤ text.length + 1 → ∀ facts, facts.Bounded →
    ValidResult text (calls.condition text context position facts) ∧
      ((calls.condition text context position facts).after = 0 ∨ position < (calls.condition text context position facts).after)
  tail : ∀ text, ValidText text → ∀ context, ValidContext text context →
    ∀ result, ValidResult text result → ∀ operator, operator.isChain = true → ∀ chained,
    ValidResult text (calls.tail text context result operator chained) ∧
      ((calls.tail text context result operator chained).after = 0 ∨
        result.after ≤ (calls.tail text context result operator chained).after)

theorem model_contracts : Contracts modelCalls where
  comparison text _ position bounded := comparison_bound text position bounded
  length text _ context _ position bounded literal := length_bound text context.model position literal bounded
  primary text tv context cv position bounded facts fv := by
    refine ⟨model_primary_valid text tv context cv position bounded facts fv, ?_⟩
    by_cases zero : (readPrimary text context.model position facts).after = 0
    · exact Or.inl zero
    · exact Or.inr (primary_progress text context.model position facts tv cv.1 bounded zero)
  relation text tv context cv position bounded facts fv := by
    refine ⟨model_relation_valid text tv context cv position bounded facts fv, ?_⟩
    by_cases zero : (readRelation text context.model position facts).after = 0
    · exact Or.inl zero
    · exact Or.inr (relation_progress text context.model position facts tv cv.1 bounded zero)
  model text tv context cv position bounded facts fv := by
    refine ⟨model_condition_valid text tv context cv position bounded facts fv, ?_⟩
    by_cases zero : (readCondition text context.model position facts).after = 0
    · exact Or.inl zero
    · exact Or.inr (condition_progress text context.model position facts zero)
  condition text tv context cv position bounded facts fv := by
    refine ⟨model_condition_valid text tv context cv position bounded facts fv, ?_⟩
    by_cases zero : (readCondition text context.model position facts).after = 0
    · exact Or.inl zero
    · exact Or.inr (condition_progress text context.model position facts zero)
  tail text tv context cv result rv operator _ chained := by
    refine ⟨⟨tail_bound text context.model result _ tv cv.1 rv.1,
      conditionTail_bounded text context.model result _ rv.2⟩, ?_⟩
    by_cases zero : (conditionTail text context.model result (chainState operator chained)).after = 0
    · exact Or.inl zero
    · exact Or.inr (tail_nondecreasing text context.model result _ zero)

end Silver.Predicate.Native
