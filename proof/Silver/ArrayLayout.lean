module

public import Silver.IntegerIntervals

@[expose] public section

/-! A finite array is represented by a contiguous segment of the existing
Integer store. This is a representation, not an assumption that arbitrary
scalar identities cannot overlap it. Source readiness establishes disjoint
segments and reserves scalar/loop identities below their bases. -/
namespace Silver.Integer

structure ArrayDescriptor where
  base : Nat
  bounds : Interval
  deriving DecidableEq, Repr

namespace ArrayDescriptor

def length (array : ArrayDescriptor) : Nat :=
  (array.bounds.upper - array.bounds.lower + 1).toNat

def address (array : ArrayDescriptor) (index : Int) : Nat :=
  array.base + (index - array.bounds.lower).toNat

def Valid (array : ArrayDescriptor) : Prop :=
  array.bounds.Bounded ∧ array.bounds.lower ≤ array.bounds.upper

instance (array : ArrayDescriptor) : Decidable array.Valid :=
  inferInstanceAs (Decidable (_ ∧ _))

def ContainsCell (array : ArrayDescriptor) (cell : Nat) : Prop :=
  array.base ≤ cell ∧ cell < array.base + array.length

instance (array : ArrayDescriptor) (cell : Nat) : Decidable (array.ContainsCell cell) :=
  inferInstanceAs (Decidable (_ ∧ _))

theorem address_within {array : ArrayDescriptor} {index : Int}
    (inside : array.bounds.Contains index) : array.ContainsCell (array.address index) := by
  simp only [ContainsCell, address, length, Interval.Contains] at *
  omega

theorem address_injective {array : ArrayDescriptor} {left right : Int}
    (a : array.bounds.Contains left) (b : array.bounds.Contains right)
    (same : array.address left = array.address right) : left = right := by
  simp only [address, Interval.Contains] at *
  omega

theorem address_offset (array : ArrayDescriptor) (offset : Nat) :
    array.address (array.bounds.lower + offset) = array.base + offset := by
  simp only [address]
  congr 1
  omega

theorem offset_within {array : ArrayDescriptor} {offset : Nat} (inside : offset < array.length) :
    array.bounds.Contains (array.bounds.lower + offset) := by
  simp only [length, Interval.Contains] at *
  omega

def Disjoint (left right : ArrayDescriptor) : Prop :=
  left.base + left.length ≤ right.base ∨ right.base + right.length ≤ left.base

theorem disjoint_addresses {left right : ArrayDescriptor} {a b : Int}
    (apart : left.Disjoint right) (ha : left.bounds.Contains a) (hb : right.bounds.Contains b) :
    left.address a ≠ right.address b := by
  have la := address_within ha
  have rb := address_within hb
  simp only [Disjoint, ContainsCell] at *
  omega

def project (array : ArrayDescriptor) (values : Nat → Int) (index : Int) : Int :=
  values (array.address index)

def write (array : ArrayDescriptor) (values : Nat → Int) (index value : Int) : Nat → Int :=
  fun cell => if cell = array.address index then value else values cell

theorem read_write_same (array : ArrayDescriptor) (values : Nat → Int) (index value : Int) :
    array.project (array.write values index value) index = value := by
  simp [project, write]

theorem read_write_other {array : ArrayDescriptor} {values : Nat → Int} {index other value : Int}
    (hi : array.bounds.Contains index) (ho : array.bounds.Contains other) (different : other ≠ index) :
    array.project (array.write values index value) other = array.project values other := by
  have distinct : array.address other ≠ array.address index := fun same =>
    different (address_injective ho hi same)
  simp [project, write, distinct]

theorem write_preserves_scalar {array : ArrayDescriptor} {values : Nat → Int} {index value : Int}
    {scalar limit : Nat} (reserved : limit < array.base) (bounded : scalar ≤ limit) :
    array.write values index value scalar = values scalar := by
  have distinct : scalar ≠ array.address index := by simp only [address]; omega
  simp [write, distinct]

theorem write_preserves_other {array other : ArrayDescriptor} {values : Nat → Int}
    {index value queried : Int} (apart : other.Disjoint array)
    (hi : array.bounds.Contains index) (hq : other.bounds.Contains queried) :
    other.project (array.write values index value) queried = other.project values queried := by
  simp [project, write, disjoint_addresses apart hq hi]

def Fits (array : ArrayDescriptor) (values : Nat → Int) : Prop :=
  ∀ index, array.bounds.Contains index → InRange (array.project values index)

theorem write_fits {array : ArrayDescriptor} {values : Nat → Int} {index value : Int}
    (fits : array.Fits values) (inside : array.bounds.Contains index) (safe : InRange value) :
    array.Fits (array.write values index value) := by
  intro other ho
  by_cases same : other = index
  · subst other; simpa only [read_write_same] using safe
  · rw [read_write_other inside ho same]
    exact fits other ho

/-- Explicit positional components initialize precisely this finite segment.
The values are already evaluated in the declaration's incoming environment;
source correspondence must retain their original expression obligations. -/
def initializeValues (array : ArrayDescriptor) (values : Nat → Int) (items : List Int) : Nat → Int :=
  fun cell => if array.base ≤ cell ∧ cell - array.base < items.length
    then items[cell - array.base]! else values cell

theorem initialize_at {array : ArrayDescriptor} {values : Nat → Int} {items : List Int}
    {offset : Nat} (inside : offset < items.length) :
    array.project (array.initializeValues values items) (array.bounds.lower + offset) = items[offset]! := by
  simp [project, address_offset, initializeValues, inside]

theorem initialize_preserves_scalar {array : ArrayDescriptor} {values : Nat → Int} {items : List Int}
    {scalar limit : Nat} (reserved : limit < array.base) (bounded : scalar ≤ limit) :
    array.initializeValues values items scalar = values scalar := by
  have below : ¬ array.base ≤ scalar := by omega
  simp [initializeValues, below]

theorem initialize_fits {array : ArrayDescriptor} {values : Nat → Int} {items : List Int}
    (count : items.length = array.length) (safe : ∀ value ∈ items, InRange value) :
    array.Fits (array.initializeValues values items) := by
  intro index inside
  let offset := (index - array.bounds.lower).toNat
  have offsetBound : offset < items.length := by
    simp only [offset, count, length, Interval.Contains] at *
    omega
  have same : array.bounds.lower + (offset : Int) = index := by
    simp only [offset, Interval.Contains] at *
    omega
  rw [← same, initialize_at offsetBound]
  simpa only [getElem!_pos items offset offsetBound] using
    safe _ (List.getElem_mem (l := items) (n := offset) (h := offsetBound))

end ArrayDescriptor

/-- A finite, fully present range segment. Missing cells fail; no array-value
fact is invented by a successful lookup. -/
def arraySpanRange (ranges : Nat → Option Interval) : Nat → Nat → Option Interval
  | _, 0 => some Interval.empty
  | first, count + 1 => (ranges first).bind fun head =>
      (arraySpanRange ranges (first + 1) count).map fun tail => head.join tail

theorem arraySpanRange_sound {ranges : Nat → Option Interval} {values : Nat → Int}
    (fits : ∀ cell bounds, ranges cell = some bounds → bounds.Contains (values cell))
    {first count : Nat} {bounds : Interval}
    (found : arraySpanRange ranges first count = some bounds)
    {cell : Nat} (inside : first ≤ cell ∧ cell < first + count) : bounds.Contains (values cell) := by
  induction count generalizing first bounds with
  | zero => omega
  | succ count ih =>
      simp only [arraySpanRange, Option.bind_eq_some_iff, Option.map_eq_some_iff] at found
      obtain ⟨head, present, tail, rest, rfl⟩ := found
      by_cases same : cell = first
      · subst cell; exact Interval.join_left (fits first head present)
      · exact Interval.join_right (ih rest (by omega))

end Silver.Integer
