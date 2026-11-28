module

public import Silver.ApplicationPackageCallsValidityNative
public import Silver.PredicateNativeState

@[expose] public section

namespace Silver.ApplicationPackageCalls.ValidityNative
open ApplicationNative Predicate

/-- Bounds supplied by the native Path_Facts and Scalar interval field subtypes.
The flow expression itself supplies all relationships to the declaration table. -/
structure FlowStorage (facts : ActiveFlow) : Prop where
  path : facts.path.Bounded
  intervals : ∀ bounds ∈ facts.values, bounds.Bounded

private theorem stored_range {facts : ActiveFlow} {index : Nat} {bounds : Integer.Interval}
    (found : facts.model.scalars index = some bounds) :
    bounds ∈ facts.values ∧ facts.values.getD (index - 1) .empty = bounds := by
  change ActiveFlow.ranges facts.values index = some bounds at found
  unfold ActiveFlow.ranges at found
  split at found
  · contradiction
  · exact ⟨List.mem_of_getElem? found, by rw [List.getD_eq_getElem?_getD, found]; rfl⟩

private theorem cell_contained (context : ParseContext) (facts : ActiveFlow) (index : Nat)
    (checked : flowCellCheck context facts index = true) :
    let item := ScalarExpression.binding context.scalarNames index
    let current := facts.values.getD (index - 1) Integer.Interval.empty
    ∀ value, current.Contains value →
      (if item.mutable then item.declaredBounds else item.bounds).Contains value := by
  dsimp only
  cases writable : (ScalarExpression.binding context.scalarNames index).mutable with
  | true =>
      simp only [flowCellCheck, writable, ↓reduceIte, Bool.and_eq_true] at checked
      simp only [↓reduceIte]
      intro value within
      exact Integer.Interval.included_sound (by rw [← includedCheck_model]; exact checked.2) within
  | false =>
      simp only [flowCellCheck, writable, Bool.false_eq_true, ↓reduceIte] at checked
      simp only [Bool.false_eq_true, ↓reduceIte]
      split at checked
      · intro value within
        exact Integer.Interval.included_sound (by rwa [← includedCheck_model]) within
      · have same := of_decide_eq_true checked
        exact fun value within => same ▸ within

/-- Follows the Ada expression on every allocated flow cell. The zero-count
case and initially empty immutable captures use the same proof. -/
theorem flow_import_domain (context : Predicate.Native.Context) (facts : ActiveFlow)
    (storage : FlowStorage facts) (checked : flowValidCheck context.model facts = true) :
    Predicate.Native.ValidFlow context facts := by
  obtain ⟨extent, cells⟩ := (flowValidCheck_meaning _ _).mp checked
  change facts.count = context.scalarNames.length at extent
  refine ⟨storage.path, ⟨extent, ?_⟩, ?_, ?_, ?_⟩
  · intro index positive bounded immutable declared
    have accepted := cells index positive (by simpa only [extent] using bounded)
    simpa [flowCellCheck, Predicate.Native.Context.model, immutable, Nat.not_lt.mpr declared] using accepted
  · intro index bounds found
    exact storage.intervals bounds (stored_range found).1
  · intro index target found
    have active : 0 < index ∧ index ≤ context.scalarNames.length := by
      by_cases active : 0 < index ∧ index ≤ context.scalarNames.length
      · exact active
      · simp [ScalarMetadata.flowBounds, ScalarExpression.ranges, active] at found
    obtain ⟨positive, bounded⟩ := active
    rw [ScalarMetadata.flowBounds_active context.scalarNames index positive bounded] at found
    cases found
    have inside : index - 1 < facts.values.length := by
      change facts.values.length = context.scalarNames.length at extent
      omega
    have get : facts.model.scalars index = some (facts.values.getD (index - 1) Integer.Interval.empty) := by
      change ActiveFlow.ranges facts.values index = _
      rw [ActiveFlow.ranges_inside _ _ positive (by change index ≤ facts.count; simpa only [extent] using bounded),
        List.getD_eq_getElem?_getD,
        List.getElem?_eq_getElem inside]
      rfl
    exact ⟨_, get, cell_contained context.model facts index (cells index positive (by simpa only [extent] using bounded))⟩
  · intro index bounds mutable found
    simp only [ScalarExpression.mutability, Bool.and_eq_true, decide_eq_true_eq] at mutable
    obtain ⟨⟨positive, bounded⟩, writable⟩ := mutable
    have accepted := cells index positive (by simpa only [extent] using bounded)
    simp only [flowCellCheck, Predicate.Native.Context.model, writable, ↓reduceIte, Bool.and_eq_true,
      Bool.not_eq_true'] at accepted
    rw [← (stored_range found).2]
    exact accepted.1

theorem body_import_domain (text : Source) (context : Predicate.Native.Context) (scan : BodyScan)
    (storage : FlowStorage scan.facts) (checked : bodyValidCheck text context.model scan = true) :
    scan.position ≤ text.length + 1 ∧ scan.target ≤ context.names.length ∧
      Predicate.Native.ValidFlow context scan.facts := by
  obtain ⟨position, target, flow⟩ := (bodyValidCheck_meaning _ _ _).mp checked
  exact ⟨position, target, flow_import_domain context scan.facts storage flow⟩

end Silver.ApplicationPackageCalls.ValidityNative
