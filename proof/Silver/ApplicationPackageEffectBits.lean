module

public import Silver.ApplicationPackageEffectsMeaning
public import Silver.PackageMetadataSemantics

@[expose] public section

namespace Silver.ApplicationPackageEffects
open Compose Predicate

/-- One native mask update touches only its own one-based state identity. -/
theorem readStep_get (calls : Calls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (first after : Nat)
    (result : PackageBindings.StateSet) (index slot : Nat)
    (indexPositive : 0 < index) (slotPositive : 0 < slot) (slotBound : slot ≤ result.length) :
    PackageBindings.StateSet.get (readStep calls text context info first after result index) slot =
      if index = slot ∧ visibleState calls text context info slot = true then
        !calls.actualNameFree text first after (info.stateAt slot).name.first (info.stateAt slot).name.after
      else PackageBindings.StateSet.get result slot := by
  unfold readStep
  split
  · rename_i visible
    by_cases same : index = slot
    · subst index
      simp [visible, PackageBindings.StateSet.get,
        List.getD_eq_getElem?_getD, List.getElem?_set_self (by omega : slot - 1 < result.length),
        Option.getD_some]
    · simp only [same, false_and, ite_false, PackageBindings.StateSet.get,
        List.getD_eq_getElem?_getD, List.getElem?_set_ne (by omega : index - 1 ≠ slot - 1)]
  · rename_i hidden
    by_cases same : index = slot
    · subst index
      simp [hidden]
    · simp only [same, false_and, ite_false]

theorem readsFold_get (calls : Calls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (first after : Nat) (indices : List Nat)
    (positive : ∀ index ∈ indices, 0 < index) (result : PackageBindings.StateSet)
    (slot : Nat) (slotPositive : 0 < slot) (slotBound : slot ≤ result.length) :
    PackageBindings.StateSet.get
      (indices.foldl (readStep calls text context info first after) result) slot =
      if slot ∈ indices ∧ visibleState calls text context info slot = true then
        !calls.actualNameFree text first after (info.stateAt slot).name.first (info.stateAt slot).name.after
      else PackageBindings.StateSet.get result slot := by
  induction indices generalizing result with
  | nil => simp
  | cons index rest ih =>
    rw [List.foldl_cons, ih (fun i member => positive i (by simp [member]))
      (readStep calls text context info first after result index)
      (by simpa only [readStep_length] using slotBound)]
    rw [readStep_get calls text context info first after result index slot
      (positive index (by simp)) slotPositive slotBound]
    by_cases present : slot ∈ rest <;> by_cases same : index = slot <;>
      by_cases visible : visibleState calls text context info slot = true <;>
      simp_all [List.mem_cons]
    all_goals intro reversed; exact (same reversed.symm).elim


theorem emptyStateSet_get (slot : Nat) :
    PackageBindings.StateSet.get PackageBindings.emptyStateSet slot = false := by
  simp only [PackageBindings.StateSet.get, PackageBindings.emptyStateSet,
    List.getD_eq_getElem?_getD, List.getElem?_replicate]
  split <;> rfl

theorem stateReads_get (calls : Calls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (first after slot : Nat)
    (positive : 0 < slot) (active : slot ≤ info.states.length)
    (capacity : slot ≤ PackageBindings.maxStates) :
    PackageBindings.StateSet.get (stateReads calls text context info first after) slot =
      if first = 0 ∨ after ≤ first then false
      else if visibleState calls text context info slot then
        !calls.actualNameFree text first after (info.stateAt slot).name.first (info.stateAt slot).name.after
      else false := by
  unfold stateReads
  by_cases empty : first = 0 ∨ after ≤ first
  · simp only [ite_eq_left empty, emptyStateSet_get]
  · simp only [ite_eq_right empty]
    rw [readsFold_get calls text context info first after _
      (by intro index member; obtain ⟨original, _, rfl⟩ := List.mem_map.mp member; omega)
      PackageBindings.emptyStateSet slot positive
      (by simpa only [PackageBindings.emptyStateSet, List.length_replicate] using capacity)]
    have member : slot ∈ (List.range info.states.length).map (· + 1) :=
      List.mem_map.mpr ⟨slot - 1, List.mem_range.mpr (by omega), by omega⟩
    simp only [member, true_and, emptyStateSet_get]

theorem stateReads_selected (calls : Calls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (first after slot : Nat)
    (positive : 0 < slot) (active : slot ≤ info.states.length)
    (capacity : slot ≤ PackageBindings.maxStates) :
    PackageBindings.StateSet.get (stateReads calls text context info first after) slot = true ↔
      ¬(first = 0 ∨ after ≤ first) ∧ visibleState calls text context info slot = true ∧
        calls.actualNameFree text first after (info.stateAt slot).name.first (info.stateAt slot).name.after = false := by
  rw [stateReads_get calls text context info first after slot positive active capacity]
  by_cases empty : first = 0 ∨ after ≤ first <;>
    by_cases visible : visibleState calls text context info slot = true <;> simp [empty, visible]

/-- Native state indices and semantic cells use the same declaration-order
identity, including the scalar kind. This states the exact read-mask criterion;
expression decoding must still establish the relevant lexical occurrence. -/
theorem stateReads_cell (calls : Calls) (text : Source) (context : ParseContext)
    (info : PackageBindings.Metadata) (first after slot : Nat)
    (positive : 0 < slot) (active : slot ≤ info.states.length)
    (capacity : slot ≤ PackageBindings.maxStates) :
    (info.stateAt slot).cell slot ∈ info.effectCells (stateReads calls text context info first after) ↔
      ¬(first = 0 ∨ after ≤ first) ∧ visibleState calls text context info slot = true ∧
        calls.actualNameFree text first after (info.stateAt slot).name.first (info.stateAt slot).name.after = false := by
  rw [info.effectCells_index positive active,
    stateReads_selected calls text context info first after slot positive active capacity]

end Silver.ApplicationPackageEffects
