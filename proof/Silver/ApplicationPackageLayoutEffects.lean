module

public import Silver.ApplicationPackageFrameLayout
public import Silver.ApplicationPackageConditionReadIdentity

@[expose] public section

/-! The concrete original-span layout supplies the state identity and lookup
premises used by the expression/effect bridge. No correspondence assumption
between arbitrary native slots and state ordinals is needed. -/
namespace Silver.ApplicationPackageFrameLayout
open Compose Predicate Packages ApplicationPackageEffects

theorem slotAddress_global {bound info kind rows slot identity}
    (selected : slotAddress bound info kind rows slot = .global identity) :
    0 < slot ∧ slot ≤ rows.length ∧
      stateIndex info kind (rows.getD (slot - 1) {}) = some identity := by
  unfold slotAddress at selected
  split at selected
  · rename_i live
    refine ⟨live.1, live.2, ?_⟩
    unfold rowAddress at selected
    cases found : stateIndex info kind (rows.getD (slot - 1) {}) with
    | none => simp only [found] at selected; contradiction
    | some index =>
        simp only [found] at selected
        exact congrArg some (Address.global.inj selected)
  · contradiction

theorem scalarRows_get (context : ParseContext) (slot : Nat) :
    (scalarRows context).getD (slot - 1) {} =
      ⟨(ScalarExpression.binding context.scalarNames slot).first,
       (ScalarExpression.binding context.scalarNames slot).after,
       (ScalarExpression.binding context.scalarNames slot).qualifierFirst,
       (ScalarExpression.binding context.scalarNames slot).qualifierAfter⟩ := by
  simp only [scalarRows, ScalarExpression.binding, List.getD_eq_getElem?_getD, List.getElem?_map]
  cases context.scalarNames[slot - 1]? <;> rfl

theorem booleanRows_get (context : ParseContext) (slot : Nat) :
    (booleanRows context).getD (slot - 1) {} =
      ⟨(BooleanBindings.binding context.booleanNames slot).first,
       (BooleanBindings.binding context.booleanNames slot).after,
       (BooleanBindings.binding context.booleanNames slot).qualifierFirst,
       (BooleanBindings.binding context.booleanNames slot).qualifierAfter⟩ := by
  simp only [booleanRows, BooleanBindings.binding, List.getD_eq_getElem?_getD, List.getElem?_map]
  cases context.booleanNames[slot - 1]? <;> rfl

private theorem state_name {text : Source} {info : PackageBindings.Metadata}
    (valid : PackageBindings.validMetadata (ApplicationPackageNames.metadataText text) info = true)
    {identity : Nat} (positive : 0 < identity) (active : identity ≤ info.states.length) :
    PackageBindings.validName (ApplicationPackageNames.metadataText text) (info.stateAt identity).name = true := by
  have state := PackageBindings.validMetadata_state valid identity positive active
  simp only [PackageBindings.stateValid, Bool.and_eq_true] at state
  exact state.1.1.1.1

theorem condition_integer_global_read {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {bound position limit slot identity : Nat}
    {condition : Condition} {result : ConditionResult} {facts : ActiveFlow} {initials : ArrayBindings.Initials}
    (source : ConditionAt text context position facts condition result initials)
    (positionPositive : position ≠ 0) (positionBound : position ≤ text.length + 1)
    (finishBound : result.after ≤ limit)
    (valid : PackageBindings.validMetadata (ApplicationPackageNames.metadataText text) info = true)
    (capacity : info.states.length ≤ PackageBindings.maxStates)
    (scalarCapacity : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (selected : (layout bound info context).integers slot = .global identity)
    (read : .integer slot ∈ conditionReads condition) :
    .integer identity ∈ info.effectCells (stateReads modelCalls text context info position limit) := by
  have live := slotAddress_global selected
  have same := stateIndex_some live.2.2
  rw [scalarRows_get] at same
  dsimp only at same
  have name := state_name valid same.1 same.2.1
  have domain := (ApplicationPackageNames.Native.validName_domain name).2
  have row : OriginalRow context (.integer slot) :=
    ⟨Nat.ne_of_gt live.1, by simpa only [scalarRows, List.length_map] using live.2.1,
      same.2.2.1, by rw [← same.2.2.2.2.1]; exact Nat.ne_of_gt domain.1,
      by rw [← same.2.2.2.2.1, ← same.2.2.2.2.2]; exact domain.2.1⟩
  have found := condition_source_original_lookup source row read
  change ScalarExpression.lookup text context.scalarNames _ _ = slot at found
  rw [← same.2.2.2.2.1, ← same.2.2.2.2.2] at found
  have covered := condition_integer_read_cell source positionPositive positionBound finishBound
    same.1 same.2.1 (Nat.le_trans same.2.1 capacity) name same.2.2.2.1 found row.1
    (Nat.le_trans row.2.1 scalarCapacity) same.2.2.2.2.1.symm same.2.2.2.2.2.symm
    (conditionReads_mentioned condition (.integer slot) read)
  simpa only [PackageBindings.StateDeclaration.cell, same.2.2.2.1] using covered

theorem condition_boolean_global_read {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {bound position limit slot identity : Nat}
    {condition : Condition} {result : ConditionResult} {facts : ActiveFlow} {initials : ArrayBindings.Initials}
    (source : ConditionAt text context position facts condition result initials)
    (positionPositive : position ≠ 0) (positionBound : position ≤ text.length + 1)
    (finishBound : result.after ≤ limit)
    (valid : PackageBindings.validMetadata (ApplicationPackageNames.metadataText text) info = true)
    (capacity : info.states.length ≤ PackageBindings.maxStates)
    (booleanCapacity : context.booleanNames.length ≤ BooleanBindings.maxBindings)
    (selected : (layout bound info context).booleans slot = .global identity)
    (read : .boolean slot ∈ conditionReads condition) :
    .boolean identity ∈ info.effectCells (stateReads modelCalls text context info position limit) := by
  have live := slotAddress_global selected
  have same := stateIndex_some live.2.2
  rw [booleanRows_get] at same
  dsimp only at same
  have name := state_name valid same.1 same.2.1
  have domain := (ApplicationPackageNames.Native.validName_domain name).2
  have row : OriginalRow context (.boolean slot) :=
    ⟨Nat.ne_of_gt live.1, by simpa only [booleanRows, List.length_map] using live.2.1,
      same.2.2.1, by rw [← same.2.2.2.2.1]; exact Nat.ne_of_gt domain.1,
      by rw [← same.2.2.2.2.1, ← same.2.2.2.2.2]; exact domain.2.1⟩
  have found := condition_source_original_lookup source row read
  change ScalarExpression.lookup text context.scalarNames _ _ = 0 ∧
    BooleanBindings.lookup text context.booleanNames _ _ = slot at found
  rw [← same.2.2.2.2.1, ← same.2.2.2.2.2] at found
  have covered := condition_boolean_read_cell source positionPositive positionBound finishBound
    same.1 same.2.1 (Nat.le_trans same.2.1 capacity) name same.2.2.2.1 found.1 found.2 row.1
    (Nat.le_trans row.2.1 booleanCapacity) same.2.2.2.2.1.symm same.2.2.2.2.2.symm
    (conditionReads_mentioned condition (.boolean slot) read)
  simpa only [PackageBindings.StateDeclaration.cell, same.2.2.2.1] using covered

end Silver.ApplicationPackageFrameLayout
