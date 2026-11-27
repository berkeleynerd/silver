module

public import Silver.ApplicationPackageObjectStateFields
public import Silver.ApplicationPackageLayoutContext

@[expose] public section

namespace Silver.ApplicationPackageObjectRows
open Compose Predicate ApplicationPackageFrameLayout

theorem ScalarStateFields.bodyEnvironment {states : List PackageBindings.StateDeclaration}
    {names : ScalarExpression.Environment} (fields : ScalarStateFields states names) :
    ScalarStateFields states (ScalarExpression.bodyEnvironment names) := by
  intro row member state declared same
  obtain ⟨original, prior, rfl⟩ := List.mem_map.mp member
  exact fields original prior state declared same

theorem ScalarStateFields.globalRows {bound : Nat} {info : PackageBindings.Metadata} {context : ParseContext}
    (fields : ScalarStateFields info.states context.scalarNames) : GlobalScalarRows bound info context := by
  intro slot identity selected
  have live := slotAddress_global selected
  have found := stateIndex_some live.2.2
  rw [scalarRows_get] at found
  have bounded : slot ≤ context.scalarNames.length := by
    simpa only [scalarRows, List.length_map] using live.2.1
  have within : slot - 1 < context.scalarNames.length := by have := live.1; omega
  have member : ScalarExpression.binding context.scalarNames slot ∈ context.scalarNames := by
    simp only [ScalarExpression.binding, List.getD_eq_getElem?_getD, List.getElem?_eq_getElem within,
      Option.getD_some, List.getElem_mem]
  exact fields _ member _ (info.stateAt_mem identity found.1 found.2.1) found.2.2.2.2.1.symm

/-- Body_Of/Context_Of widen mutable values to the declared bounds.
Completion overrides Declaration_Count after deriving precisely this scalar
environment, so the theorem includes that override at every count. -/
theorem body_frame_context (bound : Nat) (info : PackageBindings.Metadata) (scan : ScanResult) (count : Nat)
    (integers : RowsValid bound (integerRows scan.state)) (flags : RowsValid bound (flagRows scan.state))
    (capacity : scan.state.scalarNames.length ≤ ArrayBindings.scalarLimit)
    (fields : ScalarStateFields info.states scan.state.scalarNames) :
    let context := {contextOf scan with declarationCount := count}
    (layout bound info context).Context info.stateSchema context.analysis := by
  apply layout_context
  · change RowsValid bound (scalarRows (contextOf scan))
    rw [(context_rows scan).1]
    exact integers
  · change RowsValid bound (booleanRows (contextOf scan))
    rw [(context_rows scan).2]
    exact flags
  · simpa only [contextOf, ScalarExpression.bodyEnvironment_length] using capacity
  · exact ScalarExpression.bodyEnvironment_ready _
  · exact fields.bodyEnvironment.globalRows

theorem StateFrame.body_context {bound : Nat} {info : PackageBindings.Metadata} (scan : ScanResult) (count : Nat)
    (frame : StateFrame info.states scan.state) (within : scan.state.position ≤ bound + 1)
    (capacity : scan.state.scalarNames.length ≤ ArrayBindings.scalarLimit) :
    let context := {contextOf scan with declarationCount := count}
    (layout bound info context).Context info.stateSchema context.analysis :=
  body_frame_context bound info scan count (frame.order.1.rowsValid within) (frame.order.2.rowsValid within)
    capacity frame.scalarFields

end Silver.ApplicationPackageObjectRows
