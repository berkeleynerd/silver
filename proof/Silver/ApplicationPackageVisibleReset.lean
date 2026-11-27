module

public import Silver.ApplicationPackageHiddenSource
public import Silver.ApplicationPackageGlobalShadowHistory

@[expose] public section

namespace Silver.ApplicationPackageFrameLayout
open Compose Predicate Packages ApplicationPackageEffects ApplicationPackageObjectRows

theorem global_integer_visible_of_lookup {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {bound slot identity : Nat}
    (source : StateDeclarations text info.states)
    (selected : (layout bound info context).integers slot = .global identity)
    (found : OriginalLookup text context (.integer slot)) :
    visibleState ApplicationPackageEffects.modelCalls text context info identity = true := by
  have live := slotAddress_global selected
  have state := stateIndex_some live.2.2
  rw [scalarRows_get] at state
  dsimp only at state
  change ScalarExpression.lookup text context.scalarNames
    (ScalarExpression.binding context.scalarNames slot).first
    (ScalarExpression.binding context.scalarNames slot).after = slot at found
  rw [← state.2.2.2.2.1, ← state.2.2.2.2.2] at found
  simp [visibleState, ApplicationPackageEffects.modelCalls, Nat.not_lt.mpr state.2.1,
    source.name state.1 state.2.1, state.2.2.2.1, found, Nat.ne_of_gt live.1,
    state.2.2.2.2.1.symm, state.2.2.2.2.2.symm]

/-- The native reset selects precisely the written globals whose retained row
still resolves under the current lexical scope. No no-shadowing premise is
needed: hidden rows retain their global identity but are absent from the list. -/
theorem resetSlots_global_visible_iff {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {writes : PackageBindings.StateSet} {bound slot : Nat}
    (source : StateDeclarations text info.states) :
    slot ∈ ApplicationPackageCalls.resetSlots ApplicationPackageCalls.modelCalls text context info writes
      ((List.range info.states.length).map (· + 1)) ↔
    (∃ identity, (layout bound info context).integers slot = .global identity ∧
      ScalarProcedures.Cell.integer identity ∈ info.effectCells writes) ∧
      OriginalLookup text context (.integer slot) := by
  unfold ApplicationPackageCalls.resetSlots
  constructor
  · intro member
    obtain ⟨index, present, found⟩ := List.mem_filterMap.mp member
    obtain ⟨offset, active, rfl⟩ := List.mem_map.mp present
    have bounded := List.mem_range.mp active
    dsimp only at found
    split at found
    · rename_i chosen
      cases found
      have global := visible_integer_global source (by omega : 0 < offset + 1) chosen.2.1 chosen.2.2 (bound := bound)
      have state := stateIndex_some (slotAddress_global global).2.2
      rw [scalarRows_get] at state
      dsimp only at state
      refine ⟨⟨offset + 1, global, ?_⟩, ?_⟩
      · have written := (PackageBindings.Metadata.effectCells_index
          (by omega : 0 < offset + 1) (by omega : offset + 1 ≤ info.states.length)).mpr chosen.1
        simpa only [PackageBindings.StateDeclaration.cell, chosen.2.2] using written
      · change ScalarExpression.lookup text context.scalarNames _ _ = _
        dsimp only [ApplicationPackageCalls.modelCalls]
        rw [← state.2.2.2.2.1, ← state.2.2.2.2.2]
    · contradiction
  · rintro ⟨⟨identity, global, written⟩, original⟩
    have live := slotAddress_global global
    have state := stateIndex_some live.2.2
    rw [scalarRows_get] at state
    dsimp only at state
    have selected : PackageBindings.StateSet.get writes identity = true :=
      (PackageBindings.Metadata.effectCells_index state.1 state.2.1).mp
        (by simpa only [PackageBindings.StateDeclaration.cell, state.2.2.2.1] using written)
    have visible := global_integer_visible_of_lookup source global original
    change ScalarExpression.lookup text context.scalarNames
      (ScalarExpression.binding context.scalarNames slot).first
      (ScalarExpression.binding context.scalarNames slot).after = slot at original
    rw [← state.2.2.2.2.1, ← state.2.2.2.2.2] at original
    apply List.mem_filterMap.mpr
    refine ⟨identity, ?_, ?_⟩
    · exact List.mem_map.mpr ⟨identity - 1, List.mem_range.mpr (by omega), Nat.sub_add_cancel state.1⟩
    · simp only [ApplicationPackageCalls.modelCalls, selected, visible, state.2.2.2.1,
        and_self, ite_true, original]

/-- Hidden globals already at their declarations make the original visible
reset equal the full semantic global reset, without modifying either reader or
runtime state interpretation. The hidden-range invariant is derived separately
from original declaration and loop histories. -/
theorem resetSlotsFlow_source_hidden {text : Source} {context : ParseContext}
    {info : PackageBindings.Metadata} {writes : PackageBindings.StateSet} (bound : Nat)
    (source : StateDeclarations text info.states)
    (capacity : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (ready : ScalarExpression.BodyReady context.scalarNames)
    (fields : ScalarStateFields info.states context.scalarNames) (flow : Flow)
    (hidden : ∀ slot identity, (layout bound info context).integers slot = .global identity →
      ¬OriginalLookup text context (.integer slot) → flow.scalars slot = context.analysis.declared slot) :
    ApplicationPackageCalls.resetSlotsFlow context.scalarNames
      (ApplicationPackageCalls.resetSlots ApplicationPackageCalls.modelCalls text context info writes
        ((List.range info.states.length).map (· + 1))) flow =
      resetGlobalFlow context.analysis.declared (layout bound info context) (info.effectCells writes) flow := by
  apply ApplicationPackageCalls.resetSlotsFlow_global_hidden
  · intro slot present
    exact ((resetSlots_global_visible_iff source (bound := bound)).mp present).1
  · intro slot present
    obtain ⟨⟨identity, selected, _⟩, _⟩ := (resetSlots_global_visible_iff source (bound := bound)).mp present
    have rows := fields.globalRows (bound := bound)
    have declared := (scalar_global_analysis capacity ready rows selected).1
    rw [← (rows slot identity selected).1] at declared
    exact declared
  · intro slot identity selected written omitted
    apply hidden slot identity selected
    intro visible
    exact omitted ((resetSlots_global_visible_iff source (bound := bound)).mpr ⟨⟨identity, selected, written⟩, visible⟩)

end Silver.ApplicationPackageFrameLayout
