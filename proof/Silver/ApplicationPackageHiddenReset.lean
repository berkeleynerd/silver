module

public import Silver.ApplicationPackageProcedureReset

@[expose] public section

namespace Silver.ApplicationPackageCalls
open Compose Predicate ApplicationPackages

/-- Resetting a hidden global's already-declared abstract range is an identity.
The native scan need only reset the selected visible slots; the fixed semantic
layout retains every actual global, including one hidden by a loop binder.
This is a local representation lemma, not an admission or safety premise. -/
theorem resetSlotsFlow_global_hidden {names : ScalarExpression.Environment} {slots : List Nat}
    {declared : Integer.Ranges} {layout : Packages.FrameLayout} {writes : List ScalarProcedures.Cell}
    (selected : ∀ slot ∈ slots, ∃ identity,
      layout.integers slot = .global identity ∧ .integer identity ∈ writes)
    (ranges : ∀ slot ∈ slots, declared slot = some (ScalarExpression.binding names slot).declaredBounds)
    (flow : Flow)
    (hidden : ∀ slot identity, layout.integers slot = .global identity →
      ScalarProcedures.Cell.integer identity ∈ writes → slot ∉ slots →
      flow.scalars slot = declared slot) :
    resetSlotsFlow names slots flow = Packages.resetGlobalFlow declared layout writes flow := by
  have ext {left right : Flow} (path : left.path = right.path) (scalars : left.scalars = right.scalars) :
      left = right := by cases left; cases right; cases path; cases scalars; rfl
  apply ext
  · exact resetSlotsFlow_path names slots flow
  · funext slot
    rw [resetSlotsFlow_scalars]
    by_cases present : slot ∈ slots
    · obtain ⟨identity, address, written⟩ := selected slot present
      simp only [Packages.resetGlobalFlow, Packages.resetGlobalRanges, address,
        present, written, ite_true, ranges slot present]
    · rw [ite_eq_right present]
      cases address : layout.integers slot with
      | «local» identity => simp only [Packages.resetGlobalFlow, Packages.resetGlobalRanges, address]
      | global identity =>
        by_cases written : ScalarProcedures.Cell.integer identity ∈ writes
        · simp only [Packages.resetGlobalFlow, Packages.resetGlobalRanges, address, written, ite_true]
          exact hidden slot identity address written present
        · simp only [Packages.resetGlobalFlow, Packages.resetGlobalRanges, address, written, ite_false]

end Silver.ApplicationPackageCalls
