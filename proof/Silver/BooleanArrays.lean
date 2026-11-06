module

public import Silver.BooleanModel
public import Silver.IntegerChecks
public import Silver.IntegerArrays

@[expose] public section

/-! Boolean arrays reuse the checked Integer index layout, but their components
live only in the Boolean store. No Integer value encodes a Boolean component. -/
namespace Silver.Boolean

structure ArrayDescriptor where
  base : Nat
  bounds : Integer.Interval
  deriving DecidableEq, Repr

namespace ArrayDescriptor

/-- Only bounds and addresses are shared with the Integer layout. -/
def layout (array : ArrayDescriptor) : Integer.ArrayDescriptor :=
  ⟨array.base, array.bounds, .full⟩

def length (array : ArrayDescriptor) : Nat := array.layout.length
def address (array : ArrayDescriptor) (index : Int) : Nat := array.layout.address index
def Valid (array : ArrayDescriptor) : Prop := array.layout.Valid
def ContainsCell (array : ArrayDescriptor) (cell : Nat) : Prop := array.layout.ContainsCell cell
def Disjoint (left right : ArrayDescriptor) : Prop := left.layout.Disjoint right.layout

instance (array : ArrayDescriptor) : Decidable array.Valid :=
  inferInstanceAs (Decidable array.layout.Valid)

instance (array : ArrayDescriptor) (cell : Nat) : Decidable (array.ContainsCell cell) :=
  inferInstanceAs (Decidable (array.layout.ContainsCell cell))

theorem address_within {array : ArrayDescriptor} {index : Int}
    (inside : array.bounds.Contains index) : array.ContainsCell (array.address index) :=
  Integer.ArrayDescriptor.address_within inside

theorem address_injective {array : ArrayDescriptor} {left right : Int}
    (a : array.bounds.Contains left) (b : array.bounds.Contains right)
    (same : array.address left = array.address right) : left = right :=
  Integer.ArrayDescriptor.address_injective a b same

theorem address_offset (array : ArrayDescriptor) (offset : Nat) :
    array.address (array.bounds.lower + offset) = array.base + offset :=
  Integer.ArrayDescriptor.address_offset array.layout offset

theorem offset_within {array : ArrayDescriptor} {offset : Nat} (inside : offset < array.length) :
    array.bounds.Contains (array.bounds.lower + offset) :=
  Integer.ArrayDescriptor.offset_within inside

theorem disjoint_addresses {left right : ArrayDescriptor} {a b : Int}
    (apart : left.Disjoint right) (ha : left.bounds.Contains a) (hb : right.bounds.Contains b) :
    left.address a ≠ right.address b :=
  Integer.ArrayDescriptor.disjoint_addresses apart ha hb

def project (array : ArrayDescriptor) (values : Store) (index : Int) : Bool :=
  values (array.address index)

def write (array : ArrayDescriptor) (values : Store) (index : Int) (value : Bool) : Store :=
  Boolean.put values (array.address index) value

@[simp] theorem read_write_same (array : ArrayDescriptor) (values : Store) (index : Int) (value : Bool) :
    array.project (array.write values index value) index = value :=
  Boolean.put_same values (array.address index) value

theorem read_write_other {array : ArrayDescriptor} {values : Store} {index other : Int} {value : Bool}
    (hi : array.bounds.Contains index) (ho : array.bounds.Contains other) (different : other ≠ index) :
    array.project (array.write values index value) other = array.project values other := by
  exact Boolean.put_other _ _ _ _ (fun same => different (address_injective ho hi same))

theorem write_preserves_scalar {array : ArrayDescriptor} {values : Store} {index : Int} {value : Bool}
    {scalar limit : Nat} (reserved : limit < array.base) (bounded : scalar ≤ limit) :
    array.write values index value scalar = values scalar := by
  apply Boolean.put_other
  simp only [address, Integer.ArrayDescriptor.address, layout]
  omega

theorem write_preserves_other {array other : ArrayDescriptor} {values : Store}
    {index queried : Int} {value : Bool} (apart : other.Disjoint array)
    (hi : array.bounds.Contains index) (hq : other.bounds.Contains queried) :
    other.project (array.write values index value) queried = other.project values queried :=
  Boolean.put_other _ _ _ _ (disjoint_addresses apart hq hi)

def initializeValues (array : ArrayDescriptor) (values : Store) (items : List Bool) : Store :=
  fun cell => if array.base ≤ cell ∧ cell - array.base < items.length
    then items[cell - array.base]! else values cell

theorem initialize_read {array : ArrayDescriptor} {values : Store} {items : List Bool}
    {offset : Nat} (inside : offset < items.length) :
    array.project (array.initializeValues values items) (array.bounds.lower + offset) = items[offset]! := by
  simp only [project, address_offset, initializeValues, Nat.add_sub_cancel_left]
  simp [inside]

theorem initialize_preserves_scalar {array : ArrayDescriptor} {values : Store} {items : List Bool}
    {scalar limit : Nat} (reserved : limit < array.base) (bounded : scalar ≤ limit) :
    array.initializeValues values items scalar = values scalar := by
  have outside : ¬ array.base ≤ scalar := by omega
  simp [initializeValues, outside]

theorem initialize_preserves_other {array other : ArrayDescriptor} {values : Store}
    {items : List Bool} {index : Int} (count : items.length = array.length)
    (apart : other.Disjoint array) (inside : other.bounds.Contains index) :
    other.project (array.initializeValues values items) index = other.project values index := by
  have atCell := other.address_within inside
  have outside : ¬ (array.base ≤ other.address index ∧
      other.address index - array.base < items.length) := by
    simp only [Disjoint, ContainsCell, Integer.ArrayDescriptor.Disjoint,
      Integer.ArrayDescriptor.ContainsCell, layout] at apart atCell
    change items.length = (array.bounds.upper - array.bounds.lower + 1).toNat at count
    simp only [Integer.ArrayDescriptor.length] at apart atCell
    omega
  simp only [project, initializeValues, outside, ↓reduceIte]

def allCells (array : ArrayDescriptor) (predicate : Nat → Bool) : Bool :=
  array.layout.allCells predicate

theorem allCells_iff (array : ArrayDescriptor) (predicate : Nat → Bool) :
    array.allCells predicate = true ↔
      ∀ cell, array.ContainsCell cell → predicate cell = true :=
  Integer.ArrayDescriptor.allCells_iff array.layout predicate

def initialized (array : ArrayDescriptor) (analysis : Analysis) : Bool :=
  array.allCells analysis.initialized

def writable (array : ArrayDescriptor) (analysis : Analysis) : Bool :=
  array.allCells analysis.canWrite

theorem initialized_address {array : ArrayDescriptor} {analysis : Analysis} {index : Int}
    (ready : array.initialized analysis = true) (inside : array.bounds.Contains index) :
    analysis.initialized (array.address index) = true :=
  (array.allCells_iff analysis.initialized).mp ready _ (array.address_within inside)

theorem writable_address {array : ArrayDescriptor} {analysis : Analysis} {index : Int}
    (ready : array.writable analysis = true) (inside : array.bounds.Contains index) :
    analysis.canWrite (array.address index) = true :=
  (array.allCells_iff analysis.canWrite).mp ready _ (array.address_within inside)

def checkIndex (array : ArrayDescriptor) (ranges : Integer.Ranges) (index : Integer.Expr) : Bool :=
  match index.infer ranges with
  | none => false
  | some indices => Integer.arrayIndexCheck array.layout indices

theorem checkIndex_valid {array : ArrayDescriptor} {ranges : Integer.Ranges} {index : Integer.Expr}
    (checked : array.checkIndex ranges index = true) : array.Valid := by
  unfold checkIndex at checked
  cases found : index.infer ranges with
  | none => simp [found] at checked
  | some indices =>
      simp only [found, Integer.arrayIndexCheck, decide_eq_true_eq] at checked
      exact checked.1

theorem indexCheck_singleton {array : ArrayDescriptor} {index : Int}
    (valid : array.Valid) (inside : array.bounds.Contains index) :
    Integer.arrayIndexCheck array.layout (Integer.Interval.singleton index) = true := by
  unfold Integer.arrayIndexCheck
  apply decide_eq_true
  exact ⟨valid, Int.le_refl _, inside.1, inside.2⟩

def indexObligations (array : ArrayDescriptor) (ranges : Integer.Ranges)
    (index : Integer.Expr) : List Integer.Obligation :=
  index.obligations ranges ++ match index.infer ranges with
    | none => [.impossible]
    | some indices => [.arrayIndex array.layout indices]

theorem indexObligations_exact (array : ArrayDescriptor) (ranges : Integer.Ranges)
    (index : Integer.Expr) :
    Integer.discharged (array.indexObligations ranges index) = array.checkIndex ranges index := by
  simp only [indexObligations, Integer.discharged_append, Integer.Expr.obligations_exact]
  cases found : index.infer ranges <;>
    simp [checkIndex, found, Integer.discharged, Integer.Obligation.discharge]

theorem checkIndex_sound {array : ArrayDescriptor} {ranges : Integer.Ranges}
    {values : Integer.Store} {index : Integer.Expr}
    (checked : array.checkIndex ranges index = true) (fits : Integer.Fits ranges values) :
    index.Safe values ∧ array.bounds.Contains (index.evaluate values) := by
  unfold checkIndex at checked
  cases found : index.infer ranges with
  | none => simp [found] at checked
  | some indices =>
      simp only [found] at checked
      have sound := Integer.Expr.infer_sound found fits
      exact ⟨sound.2, Integer.Obligation.discharge_sound
        (obligation := .arrayIndex array.layout indices) checked _ sound.1⟩

end ArrayDescriptor
end Silver.Boolean
