module

public import Silver.ApplicationPackageRecursiveOutcomes

@[expose] public section

namespace Silver.ApplicationPackageCalls
open Compose Predicate

theorem includedCheck_of_contains {source target : Integer.Interval}
    (contained : ∀ value, source.Contains value → target.Contains value) :
    includedCheck source target = true := by
  rw [includedCheck_model]
  by_cases empty : source.isEmpty = true
  · simp only [Integer.Interval.included, empty, Bool.true_or]
  · have ordered : source.lower ≤ source.upper := by
      simp only [Integer.Interval.isEmpty, decide_eq_true_eq] at empty
      omega
    have low := contained source.lower ⟨Int.le_refl _, ordered⟩
    have high := contained source.upper ⟨ordered, Int.le_refl _⟩
    have included : target.lower ≤ source.lower ∧ source.upper ≤ target.upper := ⟨low.1, high.2⟩
    simp only [Integer.Interval.included, included, and_self, decide_true, Bool.or_true]

/-- The full native flow domain implies the original executable guard.
Together with flow_import_domain, the decoder can move in either direction
without adding a successful native check as an external premise. -/
theorem flowValidCheck_of_domain {context : ParseContext} {facts : ActiveFlow}
    (ready : ScalarMetadata.FlowReady context.scalarNames context.declarationCount facts) :
    flowValidCheck context facts = true := by
  apply (flowValidCheck_meaning context facts).mpr
  refine ⟨ready.compatible.count, ?_⟩
  intro index positive bounded
  have active : index ≤ context.scalarNames.length := by rw [← ready.compatible.count]; exact bounded
  have inside : index - 1 < facts.values.length := by change index ≤ facts.values.length at bounded; omega
  have cell : facts.model.scalars index = some (facts.values.getD (index - 1) Integer.Interval.empty) := by
    change ActiveFlow.ranges facts.values index = _
    rw [ActiveFlow.ranges_inside _ _ positive bounded, List.getD_eq_getElem?_getD,
      List.getElem?_eq_getElem inside]
    rfl
  obtain ⟨value, found, contained⟩ := ready.contained index _
    (ScalarMetadata.flowBounds_active context.scalarNames index positive active)
  have same := Option.some.inj (found.symm.trans cell)
  subst value
  cases writable : (ScalarExpression.binding context.scalarNames index).mutable with
  | true =>
    have mutable : ScalarExpression.mutability context.scalarNames index = true := by
      simp only [ScalarExpression.mutability, positive, active, and_self, decide_true, writable, Bool.and_self]
    have nonempty := ready.mutableNonempty index _ mutable cell
    have included : includedCheck (facts.values.getD (index - 1) Integer.Interval.empty)
        (ScalarExpression.binding context.scalarNames index).declaredBounds = true := by
      apply includedCheck_of_contains
      simpa only [writable, ite_true] using contained
    simp only [flowCellCheck, writable, ite_true, nonempty, Bool.not_false, included, Bool.and_self]
  | false =>
    by_cases declared : index ≤ context.declarationCount
    · have same := ready.compatible.immutable index positive active writable declared
      simp only [flowCellCheck, writable, Bool.false_eq_true, ite_false, Nat.not_lt.mpr declared, same, decide_true]
    · have included : includedCheck (facts.values.getD (index - 1) Integer.Interval.empty)
          (ScalarExpression.binding context.scalarNames index).bounds = true := by
        apply includedCheck_of_contains
        simpa only [writable, Bool.false_eq_true, ite_false] using contained
      simpa only [flowCellCheck, writable, Bool.false_eq_true, ite_false, Nat.lt_of_not_ge declared, ite_true] using included

end Silver.ApplicationPackageCalls

namespace Silver.ApplicationPackageBodies.Recursive
open ApplicationPackages Compose Predicate

theorem ScanDomain.body_checked {text : Source} {context : ParseContext} {scan : BodyScan}
    (valid : ScanDomain text context scan) :
    ApplicationPackageCalls.bodyValidCheck text context scan = true :=
  (ApplicationPackageCalls.bodyValidCheck_meaning text context scan).mpr
    ⟨valid.position, valid.controls.1, ApplicationPackageCalls.flowValidCheck_of_domain valid.flow⟩

end Silver.ApplicationPackageBodies.Recursive
