module

public import Silver.ApplicationPackageFrames
public import Silver.PackageSharedFrames
public import Silver.PackageMetadataSemantics
public import Silver.PredicateConditionAdmission

@[expose] public section

/-! Native frame slots can move when Hide_Outer compacts a table. Live locals
therefore use their original source positions as persistent identities. Slots
outside the declaration table use a separate range for lexical loop binders.
The original source bound is fixed across one invocation's phases. -/
namespace Silver.ApplicationPackageFrameLayout
open Compose Predicate Packages

abbrev Row := QualifiedNames.Reference

def stateMatches (info : PackageBindings.Metadata) (kind : FunctionBindings.ScalarKind)
    (row : Row) (offset : Nat) : Bool :=
  decide (row.qualifierFirst = 0 ∧ (info.stateAt (offset + 1)).kind = kind ∧
    (info.stateAt (offset + 1)).name.first = row.first ∧
    (info.stateAt (offset + 1)).name.after = row.after)

def stateIndex (info : PackageBindings.Metadata) (kind : FunctionBindings.ScalarKind)
    (row : Row) : Option Nat :=
  ((List.range info.states.length).find? (stateMatches info kind row)).map (· + 1)

theorem stateIndex_some {info : PackageBindings.Metadata} {kind : FunctionBindings.ScalarKind}
    {row : Row} {identity : Nat} (found : stateIndex info kind row = some identity) :
    0 < identity ∧ identity ≤ info.states.length ∧ row.qualifierFirst = 0 ∧
      (info.stateAt identity).kind = kind ∧
      (info.stateAt identity).name.first = row.first ∧
      (info.stateAt identity).name.after = row.after := by
  obtain ⟨offset, selected, rfl⟩ := Option.map_eq_some_iff.mp found
  have present := List.mem_range.mp (List.mem_of_find?_eq_some selected)
  have matching := List.find?_some selected
  simp only [stateMatches, decide_eq_true_eq] at matching
  exact ⟨by omega, by omega, matching⟩

def rowAddress (info : PackageBindings.Metadata) (kind : FunctionBindings.ScalarKind)
    (row : Row) : Address :=
  match stateIndex info kind row with
  | some identity => .global identity
  | none => .local row.first

theorem rowAddress_equal_first {info : PackageBindings.Metadata} {kind : FunctionBindings.ScalarKind}
    {left right : Row} (same : rowAddress info kind left = rowAddress info kind right) :
    left.first = right.first := by
  unfold rowAddress at same
  cases l : stateIndex info kind left <;> cases r : stateIndex info kind right <;>
    simp only [l, r] at same
  · exact Address.local.inj same
  · contradiction
  · contradiction
  · have identity := Address.global.inj same
    have leftName := (stateIndex_some l).2.2.2.2.1
    have rightName := (stateIndex_some r).2.2.2.2.1
    rw [identity] at leftName
    exact leftName.symm.trans rightName

def slotAddress (bound : Nat) (info : PackageBindings.Metadata)
    (kind : FunctionBindings.ScalarKind) (rows : List Row) (slot : Nat) : Address :=
  if 0 < slot ∧ slot ≤ rows.length then rowAddress info kind (rows.getD (slot - 1) {})
  else .local (bound + 1 + slot)

/-- Source construction supplies these history facts. They are not properties
of an arbitrary standalone helper input and are not additional admission rules. -/
structure RowsValid (bound : Nat) (rows : List Row) : Prop where
  firstBound : ∀ slot, 0 < slot → slot ≤ rows.length → (rows.getD (slot - 1) {}).first ≤ bound
  unique : ∀ left right, 0 < left → left ≤ rows.length → 0 < right → right ≤ rows.length →
    (rows.getD (left - 1) {}).first = (rows.getD (right - 1) {}).first → left = right

private theorem live_ne_inactive {bound : Nat} {info : PackageBindings.Metadata}
    {kind : FunctionBindings.ScalarKind} {row : Row} (bounded : row.first ≤ bound) (slot : Nat) :
    rowAddress info kind row ≠ .local (bound + 1 + slot) := by
  unfold rowAddress
  cases selected : stateIndex info kind row with
  | none => intro equal; have same := Address.local.inj equal; omega
  | some identity => intro equal; contradiction

theorem slotAddress_injective (bound : Nat) (info : PackageBindings.Metadata)
    (kind : FunctionBindings.ScalarKind) (rows : List Row) (valid : RowsValid bound rows) :
    Function.Injective (slotAddress bound info kind rows) := by
  intro left right same
  unfold slotAddress at same
  by_cases l : 0 < left ∧ left ≤ rows.length <;>
    by_cases r : 0 < right ∧ right ≤ rows.length
  · rw [ite_eq_left l, ite_eq_left r] at same
    exact valid.unique left right l.1 l.2 r.1 r.2 (rowAddress_equal_first same)
  · rw [ite_eq_left l, ite_eq_right r] at same
    exact False.elim (live_ne_inactive (valid.firstBound left l.1 l.2) right same)
  · rw [ite_eq_right l, ite_eq_left r] at same
    exact False.elim (live_ne_inactive (valid.firstBound right r.1 r.2) left same.symm)
  · rw [ite_eq_right l, ite_eq_right r] at same
    have indices := Address.local.inj same
    omega

def scalarRows (context : ParseContext) : List Row :=
  context.scalarNames.map fun row => ⟨row.first,row.after,row.qualifierFirst,row.qualifierAfter⟩

def booleanRows (context : ParseContext) : List Row :=
  context.booleanNames.map fun row => ⟨row.first,row.after,row.qualifierFirst,row.qualifierAfter⟩

def layout (bound : Nat) (info : PackageBindings.Metadata) (context : ParseContext) : FrameLayout :=
  ⟨slotAddress bound info .integer (scalarRows context),
    slotAddress bound info .boolean (booleanRows context)⟩

/-- Inactive slots remain injective too, so the same final layout can interpret
all lexical loop binders without aliasing persistent locals or global state. -/
theorem layout_injective (bound : Nat) (info : PackageBindings.Metadata) (context : ParseContext)
    (scalars : RowsValid bound (scalarRows context))
    (booleans : RowsValid bound (booleanRows context)) : (layout bound info context).Injective := by
  have integer := slotAddress_injective bound info .integer (scalarRows context) scalars
  have boolean := slotAddress_injective bound info .boolean (booleanRows context) booleans
  intro left right same
  cases left with
  | integer first =>
      cases right with
      | integer second =>
          apply congrArg ScalarProcedures.Cell.integer
          apply integer
          cases l : slotAddress bound info .integer (scalarRows context) first <;>
            cases r : slotAddress bound info .integer (scalarRows context) second <;>
            simp_all [FrameLayout.place, layout]
      | boolean second =>
          cases l : slotAddress bound info .integer (scalarRows context) first <;>
            cases r : slotAddress bound info .boolean (booleanRows context) second <;>
            simp_all [FrameLayout.place, layout]
  | boolean first =>
      cases right with
      | boolean second =>
          apply congrArg ScalarProcedures.Cell.boolean
          apply boolean
          cases l : slotAddress bound info .boolean (booleanRows context) first <;>
            cases r : slotAddress bound info .boolean (booleanRows context) second <;>
            simp_all [FrameLayout.place, layout]
      | integer second =>
          cases l : slotAddress bound info .boolean (booleanRows context) first <;>
            cases r : slotAddress bound info .integer (scalarRows context) second <;>
            simp_all [FrameLayout.place, layout]

/-- Any retained row has the same persistent address even when compaction moves
its native slot. This is also the identity used for incoming formals and locals. -/
theorem live_address_stable (bound : Nat) (info : PackageBindings.Metadata)
    (kind : FunctionBindings.ScalarKind) (before after : List Row) (oldSlot newSlot : Nat)
    (oldLive : 0 < oldSlot ∧ oldSlot ≤ before.length)
    (newLive : 0 < newSlot ∧ newSlot ≤ after.length)
    (sameRow : before.getD (oldSlot - 1) {} = after.getD (newSlot - 1) {}) :
    slotAddress bound info kind before oldSlot = slotAddress bound info kind after newSlot := by
  simp only [slotAddress, oldLive, newLive, and_self, ite_true, sameRow]

end Silver.ApplicationPackageFrameLayout
