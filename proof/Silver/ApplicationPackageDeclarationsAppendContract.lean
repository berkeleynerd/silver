module

public import Silver.ApplicationPackageDeclarationsStorage
public import Silver.ApplicationPackageDeclarationsModel

@[expose] public section

/-! The exact native Append_Package_Formal postcondition specifies the whole
output frame on each branch. The scalar and Boolean arrays retain all inactive
cells, including in the capacity-failure branch. -/
namespace Silver.ApplicationPackageDeclarations.AppendContract
open Compose ApplicationPackageNames

structure NativeFrame where
  frame : ParserState
  scalars : Storage.Table ScalarExpression.Binding
  booleans : Storage.Table BooleanBindings.Binding

def NativeFrame.active (store : NativeFrame) : ParserState :=
  {store.frame with scalarNames := store.scalars.active, booleanNames := store.booleans.active}

/-- The two constrained native environment representations independently supply
their counts and fixed-size arrays. Neither environment needs to satisfy any
parser validity condition in the Append_Package_Formal precondition. -/
structure NativeFrame.Represented (store : NativeFrame) : Prop where
  scalarCount : store.scalars.count ≤ store.scalars.cells.length
  booleanCount : store.booleans.count ≤ store.booleans.cells.length
  scalarCapacity : store.scalars.cells.length = ScalarExpression.maxBindings
  booleanCapacity : store.booleans.cells.length = BooleanBindings.maxBindings

def result (old : NativeFrame) (name : PackageBindings.NameSpan)
    (mark : PackageTypeResult) (mode : ProcedureBindings.Mode) : NativeFrame :=
  if mark.kind = .integer ∧ old.scalars.count < ScalarExpression.maxBindings then
    let binding : ScalarExpression.Binding :=
      ⟨name.first,name.after,mark.bounds,false,mark.bounds,decide (mode ≠ .input),0,0⟩
    {old with scalars := old.scalars.growAndWrite binding}
  else if mark.kind = .boolean ∧ old.booleans.count < BooleanBindings.maxBindings then
    let binding : BooleanBindings.Binding := ⟨name.first,name.after,decide (mode ≠ .input),0,0,false,false⟩
    {old with booleans := old.booleans.growAndWrite binding}
  else {old with frame := {old.frame with position := 0}}

/-- Projection of the complete native contract over every native-typed frame,
mark and parameter mode, including all capacity failures and prior cell values. -/
theorem active_result (old : NativeFrame) (represented : old.Represented)
    (name : PackageBindings.NameSpan) (mark : PackageTypeResult) (mode : ProcedureBindings.Mode) :
    (result old name mark mode).active = appendFormal old.active name mark mode := by
  have scalars : old.scalars.active.length = old.scalars.count := by
    simp [Storage.Table.active, Nat.min_eq_left represented.scalarCount]
  have booleans : old.booleans.active.length = old.booleans.count := by
    simp [Storage.Table.active, Nat.min_eq_left represented.booleanCount]
  have scalarLength : old.active.scalarNames.length = old.scalars.count := scalars
  have booleanLength : old.active.booleanNames.length = old.booleans.count := booleans
  unfold result appendFormal
  rw [scalarLength, booleanLength]
  by_cases integerCase : mark.kind = .integer ∧ old.scalars.count < ScalarExpression.maxBindings
  · have spare : old.scalars.count < old.scalars.cells.length := represented.scalarCapacity ▸ integerCase.2
    simp only [ite_eq_left integerCase, NativeFrame.active, Storage.growAndWrite_active old.scalars _ spare]
  · by_cases booleanCase : mark.kind = .boolean ∧ old.booleans.count < BooleanBindings.maxBindings
    · have spare : old.booleans.count < old.booleans.cells.length := represented.booleanCapacity ▸ booleanCase.2
      simp only [ite_eq_right integerCase, ite_eq_left booleanCase, NativeFrame.active,
        Storage.growAndWrite_active old.booleans _ spare]
    · simp only [ite_eq_right integerCase, ite_eq_right booleanCase, NativeFrame.active]

end Silver.ApplicationPackageDeclarations.AppendContract
