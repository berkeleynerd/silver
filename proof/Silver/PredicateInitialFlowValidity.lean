module

public import Silver.PredicateConditionFlowValidity
public import Silver.PredicateScalarHeaderReady

@[expose] public section

namespace Silver.Predicate

namespace ScalarMetadata

theorem ranges_bounded {text : Source} {names : ScalarExpression.Environment}
    (valid : ScalarExpression.ValidEnvironment text names) : (ScalarExpression.ranges names).Bounded := by
  intro index bounds found
  unfold ScalarExpression.ranges at found
  split at found
  · rename_i active
    cases found
    have within : index - 1 < names.length := by omega
    have member : ScalarExpression.binding names index ∈ names := by
      simp only [ScalarExpression.binding, List.getD_eq_getElem?_getD,
        List.getElem?_eq_getElem within, Option.getD_some]
      exact List.getElem_mem within
    exact (valid.2 _ member).2.2.2.1
  · contradiction

theorem HeaderReady.initial {text : Source} {names : ScalarExpression.Environment}
    (ready : HeaderReady names) (valid : ScalarExpression.ValidEnvironment text names)
    (path : PathFacts.Context) : FlowReady names names.length (ActiveFlow.initial names path) := by
  refine ⟨initial_compatible .., ?_, ?_, ?_⟩
  · simpa only [ActiveFlow.initial_model] using ranges_bounded valid
  · rw [ActiveFlow.initial_model]
    intro index target found
    by_cases active : 0 < index ∧ index ≤ names.length
    · rw [flowBounds_active names index active.1 active.2] at found
      cases found
      refine ⟨(ScalarExpression.binding names index).bounds,
        by simp only [ScalarExpression.ranges, active, and_self, ↓reduceIte], ?_⟩
      intro value within
      split
      · have subset := (ready.binding index active.1 active.2).2 ‹_›
        exact ⟨Int.le_trans subset.1 within.1, Int.le_trans within.2 subset.2⟩
      · exact within
    · simp only [flowBounds, ScalarExpression.ranges,
        ScalarExpression.bodyEnvironment_length, active, ↓reduceIte] at found
      contradiction
  · intro index bounds mutable found
    rw [ActiveFlow.initial_model] at found
    change ScalarExpression.ranges names index = some bounds at found
    unfold ScalarExpression.ranges at found
    split at found
    · rename_i active
      cases found
      exact (ready.binding index active.1 active.2).1
    · contradiction

end ScalarMetadata

end Silver.Predicate
