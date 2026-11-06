module

public import Std

@[expose] public section

/-! Mathematical intervals for the pinned GNAT Standard.Integer domain.
The native implementation uses signed 64-bit intermediates; these definitions
use mathematical integers so that overflow is an explicit checked property.
An interval with its lower endpoint above its upper endpoint is empty. -/

namespace Silver.Integer

def minValue : Int := -2147483648
def maxValue : Int := 2147483647

def InRange (value : Int) : Prop := minValue ≤ value ∧ value ≤ maxValue

instance (value : Int) : Decidable (InRange value) :=
  inferInstanceAs (Decidable (_ ∧ _))

structure Interval where
  lower : Int
  upper : Int
  deriving DecidableEq, Repr

namespace Interval

def Contains (interval : Interval) (value : Int) : Prop :=
  interval.lower ≤ value ∧ value ≤ interval.upper

instance (interval : Interval) (value : Int) : Decidable (interval.Contains value) :=
  inferInstanceAs (Decidable (_ ∧ _))

/-- Endpoints themselves belong to the native type, including empty intervals. -/
def Bounded (interval : Interval) : Prop := InRange interval.lower ∧ InRange interval.upper

instance (interval : Interval) : Decidable interval.Bounded :=
  inferInstanceAs (Decidable (_ ∧ _))

def isEmpty (interval : Interval) : Bool := decide (interval.upper < interval.lower)
def empty : Interval := ⟨1, 0⟩
def full : Interval := ⟨minValue, maxValue⟩
def singleton (value : Int) : Interval := ⟨value, value⟩
def normalize (interval : Interval) : Interval := if interval.isEmpty then empty else interval

theorem contains_nonempty {interval : Interval} {value : Int}
    (within : interval.Contains value) : interval.isEmpty = false := by
  simp only [Contains] at within
  simp [isEmpty]; omega

theorem empty_contains (value : Int) : ¬ empty.Contains value := by
  simp only [Contains, empty]; omega

theorem singleton_contains (value other : Int) :
    (singleton value).Contains other ↔ other = value := by
  simp only [Contains, singleton]; omega

theorem full_contains (value : Int) : full.Contains value ↔ InRange value := Iff.rfl

theorem empty_bounded : empty.Bounded := by decide
theorem full_bounded : full.Bounded := by decide

theorem normalize_contains {interval : Interval} {value : Int}
    (within : interval.Contains value) : interval.normalize.Contains value := by
  simpa only [normalize, contains_nonempty within, Bool.false_eq_true, ↓reduceIte] using within

theorem normalize_bounded {interval : Interval} (bounded : interval.Bounded) :
    interval.normalize.Bounded := by
  simp only [normalize]; split
  · exact empty_bounded
  · exact bounded

theorem bounded_contains {interval : Interval} {value : Int}
    (bounded : interval.Bounded) (within : interval.Contains value) : InRange value := by
  simp only [Bounded, InRange, Contains] at *; omega

def join (left right : Interval) : Interval :=
  if left.isEmpty then right.normalize else if right.isEmpty then left
  else ⟨min left.lower right.lower, max left.upper right.upper⟩

def intersect (left right : Interval) : Interval :=
  let lower := max left.lower right.lower
  let upper := min left.upper right.upper
  if lower ≤ upper then ⟨lower, upper⟩ else empty

theorem join_left {left right : Interval} {value : Int}
    (within : left.Contains value) : (left.join right).Contains value := by
  simp only [join, contains_nonempty within, Bool.false_eq_true, ↓reduceIte]
  split
  · exact within
  · simp only [Contains] at *; omega

theorem join_right {left right : Interval} {value : Int}
    (within : right.Contains value) : (left.join right).Contains value := by
  simp only [join, contains_nonempty within, Bool.false_eq_true, ↓reduceIte]
  split
  · exact normalize_contains within
  · simp only [Contains] at *; omega

theorem join_bounded {left right : Interval} (a : left.Bounded) (b : right.Bounded) :
    (left.join right).Bounded := by
  simp only [join]
  split
  · exact normalize_bounded b
  · split
    · exact a
    · simp only [Bounded, InRange] at *; omega

theorem intersect_contains (left right : Interval) (value : Int) :
    (left.intersect right).Contains value ↔ left.Contains value ∧ right.Contains value := by
  simp only [intersect]
  split
  · simp only [Contains]; omega
  · constructor
    · intro impossible; exact False.elim (empty_contains value impossible)
    · simp only [Contains]; omega

theorem intersect_bounded {left right : Interval} (a : left.Bounded) (b : right.Bounded) :
    (left.intersect right).Bounded := by
  simp only [intersect]
  split
  · simp only [Bounded, InRange] at *; omega
  · exact empty_bounded

theorem intersect_bounded_left {left right : Interval} (a : left.Bounded) :
    (left.intersect right).Bounded := by
  simp only [intersect]
  split
  · simp only [Bounded, InRange] at *; omega
  · exact empty_bounded

def negate (value : Interval) : Interval := ⟨-value.upper, -value.lower⟩
def add (left right : Interval) : Interval :=
  ⟨left.lower + right.lower, left.upper + right.upper⟩
def subtract (left right : Interval) : Interval :=
  ⟨left.lower - right.upper, left.upper - right.lower⟩
def multiply (left right : Interval) : Interval :=
  ⟨min (min (left.lower * right.lower) (left.lower * right.upper))
      (min (left.upper * right.lower) (left.upper * right.upper)),
    max (max (left.lower * right.lower) (left.lower * right.upper))
      (max (left.upper * right.lower) (left.upper * right.upper))⟩

theorem negate_contains {interval : Interval} {value : Int}
    (within : interval.Contains value) : interval.negate.Contains (-value) := by
  simp only [Contains, negate] at *; omega

theorem add_contains {left right : Interval} {a b : Int}
    (ha : left.Contains a) (hb : right.Contains b) : (left.add right).Contains (a + b) := by
  simp only [Contains, add] at *; omega

theorem subtract_contains {left right : Interval} {a b : Int}
    (ha : left.Contains a) (hb : right.Contains b) : (left.subtract right).Contains (a - b) := by
  simp only [Contains, subtract] at *; omega

theorem multiply_contains {left right : Interval} {a b : Int}
    (ha : left.Contains a) (hb : right.Contains b) : (left.multiply right).Contains (a * b) := by
  simp only [Contains] at ha hb
  simp only [Contains, multiply]
  by_cases bn : 0 ≤ b
  · have low := Int.mul_le_mul_of_nonneg_right ha.1 bn
    have high := Int.mul_le_mul_of_nonneg_right ha.2 bn
    constructor
    · by_cases ln : 0 ≤ left.lower
      · have corner := Int.mul_le_mul_of_nonneg_left hb.1 ln; omega
      · have corner := Int.mul_le_mul_of_nonpos_left (by omega : left.lower ≤ 0) hb.2; omega
    · by_cases un : 0 ≤ left.upper
      · have corner := Int.mul_le_mul_of_nonneg_left hb.2 un; omega
      · have corner := Int.mul_le_mul_of_nonpos_left (by omega : left.upper ≤ 0) hb.1; omega
  · have low := Int.mul_le_mul_of_nonpos_right ha.2 (by omega : b ≤ 0)
    have high := Int.mul_le_mul_of_nonpos_right ha.1 (by omega : b ≤ 0)
    constructor
    · by_cases un : 0 ≤ left.upper
      · have corner := Int.mul_le_mul_of_nonneg_left hb.1 un; omega
      · have corner := Int.mul_le_mul_of_nonpos_left (by omega : left.upper ≤ 0) hb.2; omega
    · by_cases ln : 0 ≤ left.lower
      · have corner := Int.mul_le_mul_of_nonneg_left hb.2 ln; omega
      · have corner := Int.mul_le_mul_of_nonpos_left (by omega : left.lower ≤ 0) hb.1; omega

end Interval

structure CheckResult where
  safe : Bool
  bounds : Interval
  deriving DecidableEq, Repr

def checked (interval : Interval) : CheckResult :=
  if interval.isEmpty then ⟨true, Interval.empty⟩
  else if interval.Bounded then ⟨true, interval⟩ else ⟨false, Interval.empty⟩

def checkedNegate (value : Interval) : CheckResult :=
  if value.isEmpty then ⟨true, Interval.empty⟩ else checked value.negate
def checkedAdd (left right : Interval) : CheckResult :=
  if left.isEmpty || right.isEmpty then ⟨true, Interval.empty⟩ else checked (left.add right)
def checkedSubtract (left right : Interval) : CheckResult :=
  if left.isEmpty || right.isEmpty then ⟨true, Interval.empty⟩ else checked (left.subtract right)
def checkedMultiply (left right : Interval) : CheckResult :=
  if left.isEmpty || right.isEmpty then
    if left.Contains 0 ∨ right.Contains 0 then ⟨false, Interval.empty⟩ else ⟨true, Interval.empty⟩
  else checked (left.multiply right)

/-- The frontend restriction leaves every nonempty product unchanged. -/
theorem checkedMultiply_nonempty {left right : Interval}
    (hl : left.isEmpty = false) (hr : right.isEmpty = false) :
    checkedMultiply left right = checked (left.multiply right) := by
  simp [checkedMultiply, hl, hr]

/-- A possible zero factor must not turn an empty expression into a literal. -/
theorem checkedMultiply_empty_zero {left right : Interval}
    (empty : (left.isEmpty || right.isEmpty) = true)
    (zero : left.Contains 0 ∨ right.Contains 0) :
    checkedMultiply left right = ⟨false, Interval.empty⟩ := by
  simp [checkedMultiply, empty, zero]

theorem checked_bounded (interval : Interval) : (checked interval).bounds.Bounded := by
  simp only [checked]
  split
  · exact Interval.empty_bounded
  · split
    · assumption
    · exact Interval.empty_bounded

theorem checked_sound {interval : Interval} {value : Int}
    (safe : (checked interval).safe = true) (within : interval.Contains value) :
    (checked interval).bounds.Contains value ∧ InRange value := by
  have nonempty := Interval.contains_nonempty within
  by_cases bounded : interval.Bounded
  · simpa only [checked, nonempty, Bool.false_eq_true, bounded, ↓reduceIte] using
      And.intro within (Interval.bounded_contains bounded within)
  · simp [checked, nonempty, bounded] at safe

theorem checkedNegate_sound {interval : Interval} {value : Int}
    (safe : (checkedNegate interval).safe = true) (within : interval.Contains value) :
    (checkedNegate interval).bounds.Contains (-value) ∧ InRange (-value) := by
  simp only [checkedNegate, Interval.contains_nonempty within, Bool.false_eq_true, ↓reduceIte] at *
  exact checked_sound safe (Interval.negate_contains within)

theorem checkedAdd_sound {left right : Interval} {a b : Int}
    (safe : (checkedAdd left right).safe = true)
    (ha : left.Contains a) (hb : right.Contains b) :
    (checkedAdd left right).bounds.Contains (a + b) ∧ InRange (a + b) := by
  simp only [checkedAdd, Interval.contains_nonempty ha, Interval.contains_nonempty hb,
    Bool.false_or, Bool.false_eq_true, ↓reduceIte] at *
  exact checked_sound safe (Interval.add_contains ha hb)

theorem checkedSubtract_sound {left right : Interval} {a b : Int}
    (safe : (checkedSubtract left right).safe = true)
    (ha : left.Contains a) (hb : right.Contains b) :
    (checkedSubtract left right).bounds.Contains (a - b) ∧ InRange (a - b) := by
  simp only [checkedSubtract, Interval.contains_nonempty ha, Interval.contains_nonempty hb,
    Bool.false_or, Bool.false_eq_true, ↓reduceIte] at *
  exact checked_sound safe (Interval.subtract_contains ha hb)

theorem checkedMultiply_sound {left right : Interval} {a b : Int}
    (safe : (checkedMultiply left right).safe = true)
    (ha : left.Contains a) (hb : right.Contains b) :
    (checkedMultiply left right).bounds.Contains (a * b) ∧ InRange (a * b) := by
  simp only [checkedMultiply, Interval.contains_nonempty ha, Interval.contains_nonempty hb,
    Bool.false_or, Bool.false_eq_true, ↓reduceIte] at *
  exact checked_sound safe (Interval.multiply_contains ha hb)

theorem checkedNegate_bounded (value : Interval) : (checkedNegate value).bounds.Bounded := by
  simp only [checkedNegate]; split
  · exact Interval.empty_bounded
  · exact checked_bounded _

theorem checkedAdd_bounded (left right : Interval) : (checkedAdd left right).bounds.Bounded := by
  simp only [checkedAdd]; split
  · exact Interval.empty_bounded
  · exact checked_bounded _

theorem checkedSubtract_bounded (left right : Interval) : (checkedSubtract left right).bounds.Bounded := by
  simp only [checkedSubtract]; split
  · exact Interval.empty_bounded
  · exact checked_bounded _

theorem checkedMultiply_bounded (left right : Interval) : (checkedMultiply left right).bounds.Bounded := by
  simp only [checkedMultiply]; split
  · split <;> exact Interval.empty_bounded
  · exact checked_bounded _

/-- All native endpoint calculations fit signed 64-bit intermediates. -/
def WideInRange (value : Int) : Prop := -9223372036854775808 ≤ value ∧ value ≤ 9223372036854775807

theorem endpoint_arithmetic_wide {a b : Int} (ha : InRange a) (hb : InRange b) :
    WideInRange (a + b) ∧ WideInRange (a - b) ∧ WideInRange (-a) ∧ WideInRange (a * b) := by
  have product := Interval.multiply_contains (left := Interval.full) (right := Interval.full) ha hb
  simp only [Interval.multiply, Interval.full, Interval.Contains, minValue, maxValue] at product
  simp only [InRange, minValue, maxValue, WideInRange] at *
  omega

end Silver.Integer
