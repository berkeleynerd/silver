module

public import Silver.ApplicationPackageObjectExtent

@[expose] public section

namespace Silver.ApplicationPackageObjectRows
open Compose ApplicationPackageDeclarations ApplicationPackageFrameLayout

structure BeforeCursor (cursor : Nat) (rows : List Row) : Prop where
  ordered : OrderedRows rows
  before : ∀ row ∈ rows, row.first < cursor

abbrev FrameOrder (frame : ParserState) : Prop :=
  BeforeCursor frame.position (integerRows frame) ∧ BeforeCursor frame.position (flagRows frame)

theorem BeforeCursor.retain {cursor : Nat} {before after : List Row}
    (prior : BeforeCursor cursor before) (kept : after.Sublist before) : BeforeCursor cursor after :=
  ⟨orderedRows_sublist kept prior.ordered, fun row member => prior.before row (kept.subset member)⟩

theorem BeforeCursor.rowsValid {cursor bound : Nat} {rows : List Row}
    (prior : BeforeCursor cursor rows) (within : cursor ≤ bound + 1) : RowsValid bound rows :=
  RowsValid.of_ordered prior.ordered (fun row member => by have := prior.before row member; omega)

private theorem BeforeCursor.install {cursor next : Nat} {rows : List Row} {entry : Row}
    (prior : BeforeCursor cursor rows) (fresh : cursor ≤ entry.first) (consumed : entry.first < next)
    (selected : Prop) [Decidable selected] :
    BeforeCursor next (rows ++ (if selected then [entry] else [])) := by
  have earlier (row : Row) (member : row ∈ rows) : row.first < entry.first :=
    Nat.lt_of_lt_of_le (prior.before row member) fresh
  by_cases installed : selected
  · rw [ite_eq_left installed]
    refine ⟨orderedRows_append prior.ordered earlier, ?_⟩
    intro row member
    rcases List.mem_append.mp member with old | added
    · exact Nat.lt_trans (earlier row old) consumed
    · simpa only [List.mem_singleton.mp added] using consumed
  · rw [ite_eq_right installed, List.append_nil]
    exact ⟨prior.ordered, fun row member => Nat.lt_trans (earlier row member) consumed⟩

theorem FrameOrder.scalar_before {frame : ParserState} (order : FrameOrder frame)
    {row : ScalarExpression.Binding} (member : row ∈ frame.scalarNames) : row.first < frame.position :=
  order.1.before _ (List.mem_map_of_mem member)

theorem objectStep_storage {reader : BooleanElaboration.Native.Reader} {text : Source} {frame : ParserState}
    {info : PackageBindings.Metadata} {localObject : Bool} {out : ObjectResult}
    (parsed : objectStep (modelObjectCalls reader) text frame info localObject = out)
    (present : out.frame.position ≠ 0) :
    let base := initializerBase text frame info out.name localObject
    Appended base out.name out ∧ base.scalarNames.Sublist frame.scalarNames ∧
      base.booleanNames.Sublist frame.booleanNames := by
  subst out
  obtain ⟨_, fields⟩ := objectStep_rows reader text frame info localObject present
  rw [fields.nameEq]
  exact ⟨fields, initializerBase_retained reader text frame info localObject present⟩

/-- Both tables remain in original source order after adding a state or a local.
A local can compact the incoming frame before installing its own declaration. -/
theorem objectStep_frameOrder {reader : BooleanElaboration.Native.Reader} {text : Source} {frame : ParserState}
    {info : PackageBindings.Metadata} {localObject : Bool} {out : ObjectResult}
    (parsed : objectStep (modelObjectCalls reader) text frame info localObject = out)
    (present : out.frame.position ≠ 0) (prior : FrameOrder frame) : FrameOrder out.frame := by
  obtain ⟨fields, integers, booleans⟩ := objectStep_storage parsed present
  have positions := parsed ▸ objectStep_positions reader text frame info localObject (parsed ▸ present)
  have consumed : out.name.first < out.frame.position := Nat.lt_trans positions.2.1 positions.2.2.1
  constructor
  · rw [fields.integers]
    exact (prior.1.retain (integers.map _)).install positions.1 consumed _
  · rw [fields.flags]
    exact (prior.2.retain (booleans.map _)).install positions.1 consumed _

end Silver.ApplicationPackageObjectRows
