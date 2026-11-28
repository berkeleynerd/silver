module

public import Silver.ApplicationPackageLayoutEffects

@[expose] public section

/-! Source histories preserve declaration domains and mutability. BodyReady
widens mutable rows before body analysis; the resulting native analysis is the
one used by the shared-state safety proof, including any array overlay. -/
namespace Silver.ApplicationPackageFrameLayout
open Compose Predicate Packages

def GlobalScalarRows (bound : Nat) (info : PackageBindings.Metadata)
    (context : ParseContext) : Prop :=
  ∀ slot identity, (layout bound info context).integers slot = .global identity →
    (ScalarExpression.binding context.scalarNames slot).declaredBounds =
      (info.stateAt identity).declaredBounds ∧
    (ScalarExpression.binding context.scalarNames slot).mutable = true

theorem scalar_global_analysis {bound : Nat} {info : PackageBindings.Metadata}
    {context : ParseContext} {slot identity : Nat}
    (capacity : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (ready : ScalarExpression.BodyReady context.scalarNames)
    (rows : GlobalScalarRows bound info context)
    (selected : (layout bound info context).integers slot = .global identity) :
    context.analysis.declared slot = some (info.stateAt identity).declaredBounds ∧
    context.analysis.mutable slot = true := by
  have live := slotAddress_global selected
  have active : 0 < slot ∧ slot ≤ context.scalarNames.length := by
    simpa only [scalarRows, List.length_map] using (And.intro live.1 live.2.1)
  have low : slot ≤ ArrayBindings.scalarLimit := Nat.le_trans active.2 capacity
  have fields := rows slot identity selected
  have full := ScalarExpression.bodyReady_binding ready active.1 active.2 fields.2
  constructor
  · change ArrayFlow.ranges (ArrayBindings.viewNames context.arrayNames)
      (ScalarExpression.ranges context.scalarNames) slot = _
    rw [ArrayFlow.ranges_scalar _ _ low]
    simp [ScalarExpression.ranges, active, full, fields.1]
  · change ArrayBindings.mutability (ArrayBindings.integerNames (ArrayBindings.viewNames context.arrayNames))
      (ScalarExpression.mutability context.scalarNames) slot = true
    rw [ArrayBindings.mutability_scalar _ _ low]
    simp [ScalarExpression.mutability, active, fields.2]

/-- The layout used by the decoder supplies every shared-frame representation
field. No schema or analysis correspondence is assumed as an opaque premise. -/
theorem layout_context (bound : Nat) (info : PackageBindings.Metadata) (context : ParseContext)
    (scalars : RowsValid bound (scalarRows context))
    (booleans : RowsValid bound (booleanRows context))
    (capacity : context.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (ready : ScalarExpression.BodyReady context.scalarNames)
    (rows : GlobalScalarRows bound info context) :
    (layout bound info context).Context info.stateSchema context.analysis where
  unique := layout_injective bound info context scalars booleans
  covered := by
    intro slot identity interval selected found
    have live := slotAddress_global selected
    have state := stateIndex_some live.2.2
    have actual := (scalar_global_analysis capacity ready rows selected).1
    have same : (info.stateAt identity).declaredBounds = interval := Option.some.inj (actual.symm.trans found)
    refine ⟨(info.stateAt identity).semantic identity, ?_, ?_, ?_⟩
    · apply List.mem_map.mpr
      refine ⟨identity - 1, List.mem_range.mpr (by omega), ?_⟩
      rw [Nat.sub_add_cancel state.1]
    · simp only [PackageBindings.StateDeclaration.semantic, state.2.2.2.1]
    · simp only [PackageBindings.StateDeclaration.semantic, state.2.2.2.1, same]
  reflected := by
    intro declaration present slot identity cell selected
    obtain ⟨offset, _, rfl⟩ := List.mem_map.mp present
    have indices := congrArg Packages.cellIndex cell
    rw [PackageBindings.StateDeclaration.semantic_cell,
      PackageBindings.StateDeclaration.cell_identity] at indices
    change offset + 1 = identity at indices
    have live := slotAddress_global selected
    have state := stateIndex_some live.2.2
    refine ⟨(info.stateAt identity).declaredBounds, ?_,
      (scalar_global_analysis capacity ready rows selected).1⟩
    simp only [indices, PackageBindings.StateDeclaration.semantic, state.2.2.2.1]
  mutable := fun _ _ selected => (scalar_global_analysis capacity ready rows selected).2

end Silver.ApplicationPackageFrameLayout
