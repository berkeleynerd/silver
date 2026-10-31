module

public import Silver.PredicateFlowInvariant

@[expose] public section

namespace Silver.Predicate.ScalarMetadata

/-- Scalar clauses of native Valid_State: every declaration has a nonempty
value interval, and mutable values lie within their immutable declared subtype. -/
def HeaderReady (names : ScalarExpression.Environment) : Prop :=
  ∀ item ∈ names, item.bounds.isEmpty = false ∧
    (item.mutable = true → item.declaredBounds.lower ≤ item.bounds.lower ∧
      item.bounds.upper ≤ item.declaredBounds.upper)

theorem headerReady_empty : HeaderReady [] := by simp [HeaderReady]

theorem HeaderReady.append {names : ScalarExpression.Environment} {item : ScalarExpression.Binding}
    (ready : HeaderReady names) (nonempty : item.bounds.isEmpty = false)
    (contained : item.mutable = true → item.declaredBounds.lower ≤ item.bounds.lower ∧
      item.bounds.upper ≤ item.declaredBounds.upper) : HeaderReady (names ++ [item]) := by
  intro other present
  rcases List.mem_append.mp present with old | fresh
  · exact ready other old
  · simpa only [List.mem_singleton.mp fresh] using And.intro nonempty contained

theorem HeaderReady.binding {names : ScalarExpression.Environment} (ready : HeaderReady names)
    (index : Nat) (positive : 0 < index) (bounded : index ≤ names.length) :
    (ScalarExpression.binding names index).bounds.isEmpty = false ∧
      ((ScalarExpression.binding names index).mutable = true →
        (ScalarExpression.binding names index).declaredBounds.lower ≤
          (ScalarExpression.binding names index).bounds.lower ∧
        (ScalarExpression.binding names index).bounds.upper ≤
          (ScalarExpression.binding names index).declaredBounds.upper) := by
  have within : index - 1 < names.length := by omega
  simpa only [ScalarExpression.binding, List.getD_eq_getElem?_getD,
    List.getElem?_eq_getElem within, Option.getD_some] using ready names[index - 1] (List.getElem_mem within)

theorem HeaderReady.bodyEnvironment {names : ScalarExpression.Environment} (ready : HeaderReady names) :
    HeaderReady (ScalarExpression.bodyEnvironment names) := by
  intro item present
  obtain ⟨original, old, rfl⟩ := List.mem_map.mp present
  have before := ready original old
  cases mutable : original.mutable with
  | false =>
      refine ⟨?_, ?_⟩
      · simpa only [ScalarExpression.bodyBinding, mutable, Bool.false_eq_true, ↓reduceIte] using before.1
      · intro impossible
        change original.mutable = true at impossible
        simp only [mutable, Bool.false_eq_true] at impossible
  | true =>
      have declared : original.declaredBounds.isEmpty = false := by
        have contained := before.2 mutable
        have nonempty := before.1
        simp only [Integer.Interval.isEmpty, decide_eq_false_iff_not] at nonempty ⊢
        omega
      refine ⟨?_, ?_⟩
      · simpa only [ScalarExpression.bodyBinding, mutable, ↓reduceIte] using declared
      · intro _
        simpa only [ScalarExpression.bodyBinding, mutable, ↓reduceIte] using
          And.intro (Int.le_refl original.declaredBounds.lower) (Int.le_refl original.declaredBounds.upper)

theorem HeaderReady.baseReady {names : ScalarExpression.Environment} (ready : HeaderReady names)
    (size : names.length ≤ ArrayBindings.scalarLimit) :
    BaseReady (ScalarExpression.bodyEnvironment names) names.length := by
  refine ⟨ScalarExpression.bodyEnvironment_ready _, ?_, ?_, ?_, ?_⟩
  · simp only [ScalarExpression.bodyEnvironment_length]
    exact Nat.le_refl _
  · intro index positive bounded
    exact (ready.bodyEnvironment.binding index positive
      (by simpa only [ScalarExpression.bodyEnvironment_length] using bounded)).1
  · intro index positive bounded _mutable
    exact (ready.bodyEnvironment.binding index positive bounded).1
  · simpa only [ScalarExpression.bodyEnvironment_length] using size

theorem HeaderReady.contextReady {names : ScalarExpression.Environment} (ready : HeaderReady names)
    (size : names.length ≤ ArrayBindings.scalarLimit) : ContextReady names names.length true := by
  refine ⟨?_, Nat.le_refl _, ?_, ?_, size⟩
  · intro impossible
    cases impossible
  · intro index positive bounded
    exact (ready.binding index positive bounded).1
  · intro index positive bounded mutable
    have known := ready.binding index positive bounded
    exact ⟨known.1, known.2 mutable⟩

end Silver.Predicate.ScalarMetadata
