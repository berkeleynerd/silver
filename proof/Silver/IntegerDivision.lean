module

public import Silver.IntegerIntervals

@[expose] public section

/-! Ada integer division truncates toward zero; `rem` has the dividend's sign
and `mod` has the divisor's sign. Lean's default integer division and modulus
are Euclidean, so the three source operators use `tdiv`, `tmod`, and `fmod`
explicitly. A nonempty divisor interval containing zero is rejected before
empty-operand propagation. Exact singleton results preserve declaration
elaboration independently of Ada staticness. -/

namespace Silver.Integer

def DivideDefined (left right : Int) : Prop :=
  right ≠ 0 ∧ ¬ (left = minValue ∧ right = -1)

def ModuloDefined (_left right : Int) : Prop := right ≠ 0
def RemainderDefined (_left right : Int) : Prop := right ≠ 0

instance (left right : Int) : Decidable (DivideDefined left right) :=
  inferInstanceAs (Decidable (_ ∧ _))
instance (left right : Int) : Decidable (ModuloDefined left right) :=
  inferInstanceAs (Decidable (right ≠ 0))
instance (left right : Int) : Decidable (RemainderDefined left right) :=
  inferInstanceAs (Decidable (right ≠ 0))

theorem divide_defined_of_range {left right : Int} (nonzero : right ≠ 0)
    (fits : InRange (left.tdiv right)) : DivideDefined left right := by
  refine ⟨nonzero, ?_⟩
  rintro ⟨rfl, rfl⟩
  have impossible : ¬ InRange (minValue.tdiv (-1)) := by decide +kernel
  exact impossible fits

/-- Increasing a positive denominator decreases a nonnegative quotient. -/
theorem tdiv_denominator_antitone {value low high : Int}
    (nonnegative : 0 ≤ value) (positive : 0 < low) (ordered : low ≤ high) :
    value.tdiv high ≤ value.tdiv low := by
  have quotient := Int.tdiv_nonneg nonnegative (show 0 ≤ high by omega)
  have product := Int.mul_tdiv_self_le (k := high) nonnegative
  have smaller := Int.mul_le_mul_of_nonneg_right ordered quotient
  apply Int.le_tdiv_of_mul_le positive
  rw [Int.mul_comm]
  exact Int.le_trans smaller product

theorem tdiv_positive_denominator_bounds {value low high divisor : Int}
    (positive : 0 < low) (lower : low ≤ divisor) (upper : divisor ≤ high) :
    min (value.tdiv low) (value.tdiv high) ≤ value.tdiv divisor ∧
      value.tdiv divisor ≤ max (value.tdiv low) (value.tdiv high) := by
  by_cases nonnegative : 0 ≤ value
  · have first := tdiv_denominator_antitone nonnegative positive lower
    have last := tdiv_denominator_antitone nonnegative (show 0 < divisor by omega) upper
    omega
  · have first := tdiv_denominator_antitone (value := -value) (by omega) positive lower
    have last := tdiv_denominator_antitone (value := -value) (by omega)
      (show 0 < divisor by omega) upper
    simp only [Int.neg_tdiv] at first last
    omega

theorem tdiv_denominator_bounds {value low high divisor : Int}
    (nonzero : high < 0 ∨ 0 < low) (lower : low ≤ divisor) (upper : divisor ≤ high) :
    min (value.tdiv low) (value.tdiv high) ≤ value.tdiv divisor ∧
      value.tdiv divisor ≤ max (value.tdiv low) (value.tdiv high) := by
  rcases nonzero with negative | positive
  · have bounds := tdiv_positive_denominator_bounds (value := value)
      (low := -high) (high := -low) (divisor := -divisor)
      (by omega) (by omega) (by omega)
    simp only [Int.tdiv_neg] at bounds
    omega
  · exact tdiv_positive_denominator_bounds positive lower upper

theorem fmod_bounds {left right : Int} (_nonzero : right ≠ 0) :
    (0 < right → 0 ≤ left.fmod right ∧ left.fmod right < right) ∧
      (right < 0 → right < left.fmod right ∧ left.fmod right ≤ 0) := by
  constructor
  · intro positive
    exact ⟨Int.fmod_nonneg_of_pos left positive, Int.fmod_lt_of_pos left positive⟩
  · intro negative
    have lower := Int.fmod_nonneg_of_pos (-left) (show 0 < -right by omega)
    have upper := Int.fmod_lt_of_pos (-left) (show 0 < -right by omega)
    simp only [Int.neg_fmod_neg] at lower upper
    omega

theorem tmod_dividend_bounds (left right : Int) :
    (0 ≤ left → 0 ≤ left.tmod right ∧ left.tmod right ≤ left) ∧
      (left ≤ 0 → left ≤ left.tmod right ∧ left.tmod right ≤ 0) := by
  have magnitude : (left.tmod right).natAbs ≤ left.natAbs := by
    rw [Int.natAbs_tmod]
    exact Nat.mod_le _ _
  constructor
  · intro positive
    have sign := Int.tmod_nonneg right positive
    have value := Int.natAbs_of_nonneg positive
    have remainder := Int.natAbs_of_nonneg sign
    exact ⟨sign, by omega⟩
  · intro negative
    have sign := Int.tmod_nonneg right (show 0 ≤ -left by omega)
    simp only [Int.neg_tmod] at sign
    have value := Int.ofNat_natAbs_of_nonpos negative
    have remainder := Int.ofNat_natAbs_of_nonpos (show left.tmod right ≤ 0 by omega)
    exact ⟨by omega, by omega⟩

namespace Interval

def divide (left right : Interval) : Interval :=
  ⟨min (min (left.lower.tdiv right.lower) (left.lower.tdiv right.upper))
      (min (left.upper.tdiv right.lower) (left.upper.tdiv right.upper)),
    max (max (left.lower.tdiv right.lower) (left.lower.tdiv right.upper))
      (max (left.upper.tdiv right.lower) (left.upper.tdiv right.upper))⟩

def modulo (left right : Interval) : Interval :=
  if left.lower = left.upper ∧ right.lower = right.upper then
    singleton (left.lower.fmod right.lower)
  else if 0 < right.lower then ⟨0, right.upper - 1⟩
  else ⟨right.lower + 1, 0⟩

/-- This mathematical absolute magnitude may be 2147483648, so the native
implementation calculates it in Wide before subtracting one. -/
def remainderMagnitude (right : Interval) : Int :=
  max (max right.lower (-right.lower)) (max right.upper (-right.upper)) - 1

def remainder (left right : Interval) : Interval :=
  if left.lower = left.upper ∧ right.lower = right.upper then
    singleton (left.lower.tmod right.lower)
  else
    ⟨if left.lower < 0 then max left.lower (-right.remainderMagnitude) else 0,
      if 0 < left.upper then min left.upper right.remainderMagnitude else 0⟩

theorem excludes_zero {interval : Interval} {value : Int}
    (outside : ¬ interval.Contains 0) (within : interval.Contains value) :
    value ≠ 0 ∧ (interval.upper < 0 ∨ 0 < interval.lower) := by
  simp only [Contains] at *
  omega

theorem divide_contains {left right : Interval} {a b : Int}
    (nonzero : ¬ right.Contains 0) (ha : left.Contains a) (hb : right.Contains b) :
    (left.divide right).Contains (a.tdiv b) := by
  have sign := (excludes_zero nonzero hb).2
  have low := tdiv_denominator_bounds (value := left.lower) sign hb.1 hb.2
  have high := tdiv_denominator_bounds (value := left.upper) sign hb.1 hb.2
  simp only [Contains, divide]
  by_cases positive : 0 < b
  · have lower := Int.tdiv_le_tdiv positive ha.1
    have upper := Int.tdiv_le_tdiv positive ha.2
    omega
  · have negative : 0 < -b := by
      have nz := (excludes_zero nonzero hb).1
      omega
    have lower := Int.tdiv_le_tdiv negative ha.1
    have upper := Int.tdiv_le_tdiv negative ha.2
    simp only [Int.tdiv_neg] at lower upper
    omega

theorem modulo_contains {left right : Interval} {a b : Int}
    (nonzero : ¬ right.Contains 0) (ha : left.Contains a) (hb : right.Contains b) :
    (left.modulo right).Contains (a.fmod b) := by
  have nz := excludes_zero nonzero hb
  unfold modulo
  split
  · rename_i singletons
    have aExact : a = left.lower := by have := ha.1; have := ha.2; omega
    have bExact : b = right.lower := by have := hb.1; have := hb.2; omega
    exact (singleton_contains _ _).mpr (by rw [aExact, bExact])
  · split
    · rename_i positive
      have bounds := (fmod_bounds (left := a) nz.1).1 (show 0 < b by have := hb.1; omega)
      simp only [Contains]
      have := hb.2
      omega
    · rename_i negative
      have bounds := (fmod_bounds (left := a) nz.1).2 (show b < 0 by have := hb.2; omega)
      simp only [Contains]
      have := hb.1
      omega

theorem remainder_magnitude_contains {right : Interval} {a b : Int}
    (nonzero : ¬ right.Contains 0) (hb : right.Contains b) :
    -right.remainderMagnitude ≤ a.tmod b ∧ a.tmod b ≤ right.remainderMagnitude := by
  have nz := excludes_zero nonzero hb
  by_cases positive : 0 < b
  · have low := Int.lt_tmod_of_pos a positive
    have high := Int.tmod_lt_of_pos a positive
    simp only [remainderMagnitude]
    have := hb.2
    omega
  · have low := Int.lt_tmod_of_pos a (show 0 < -b by omega)
    have high := Int.tmod_lt_of_pos a (show 0 < -b by omega)
    simp only [Int.tmod_neg] at low high
    simp only [remainderMagnitude]
    have := hb.1
    omega

theorem remainder_contains {left right : Interval} {a b : Int}
    (nonzero : ¬ right.Contains 0) (ha : left.Contains a) (hb : right.Contains b) :
    (left.remainder right).Contains (a.tmod b) := by
  unfold remainder
  split
  · rename_i singletons
    have aExact : a = left.lower := by have := ha.1; have := ha.2; omega
    have bExact : b = right.lower := by have := hb.1; have := hb.2; omega
    exact (singleton_contains _ _).mpr (by rw [aExact, bExact])
  · have magnitude := remainder_magnitude_contains (a := a) nonzero hb
    have dividend := tmod_dividend_bounds a b
    have lower := ha.1
    have upper := ha.2
    simp only [Contains]
    constructor
    · split
      · by_cases negative : a ≤ 0
        · have bound := dividend.2 negative; omega
        · have bound := dividend.1 (by omega); omega
      · have bound := dividend.1 (by omega); omega
    · split
      · by_cases positive : 0 ≤ a
        · have bound := dividend.1 positive; omega
        · have bound := dividend.2 (by omega); omega
      · have bound := dividend.2 (by omega); omega

theorem divide_singleton (a b : Int) :
    (singleton a).divide (singleton b) = singleton (a.tdiv b) := by
  simp [divide, singleton]

theorem modulo_singleton (a b : Int) :
    (singleton a).modulo (singleton b) = singleton (a.fmod b) := by
  simp [modulo, singleton]

theorem remainder_singleton (a b : Int) :
    (singleton a).remainder (singleton b) = singleton (a.tmod b) := by
  simp [remainder, singleton]

end Interval

def checkedDivide (left right : Interval) : CheckResult :=
  if right.Contains 0 then ⟨false, Interval.empty⟩
  else if left.isEmpty || right.isEmpty then ⟨true, Interval.empty⟩
  else checked (left.divide right)

def checkedModulo (left right : Interval) : CheckResult :=
  if right.Contains 0 then ⟨false, Interval.empty⟩
  else if left.isEmpty || right.isEmpty then ⟨true, Interval.empty⟩
  else checked (left.modulo right)

def checkedRemainder (left right : Interval) : CheckResult :=
  if right.Contains 0 then ⟨false, Interval.empty⟩
  else if left.isEmpty || right.isEmpty then ⟨true, Interval.empty⟩
  else checked (left.remainder right)

theorem checkedDivide_excludes_zero {left right : Interval}
    (safe : (checkedDivide left right).safe = true) : ¬ right.Contains 0 := by
  intro present
  simp only [checkedDivide, present, ↓reduceIte, Bool.false_eq_true] at safe

theorem checkedModulo_excludes_zero {left right : Interval}
    (safe : (checkedModulo left right).safe = true) : ¬ right.Contains 0 := by
  intro present
  simp only [checkedModulo, present, ↓reduceIte, Bool.false_eq_true] at safe

theorem checkedRemainder_excludes_zero {left right : Interval}
    (safe : (checkedRemainder left right).safe = true) : ¬ right.Contains 0 := by
  intro present
  simp only [checkedRemainder, present, ↓reduceIte, Bool.false_eq_true] at safe

theorem checkedDivide_bounded (left right : Interval) : (checkedDivide left right).bounds.Bounded := by
  simp only [checkedDivide]
  split
  · exact Interval.empty_bounded
  · split
    · exact Interval.empty_bounded
    · exact checked_bounded _

theorem checkedModulo_bounded (left right : Interval) : (checkedModulo left right).bounds.Bounded := by
  simp only [checkedModulo]
  split
  · exact Interval.empty_bounded
  · split
    · exact Interval.empty_bounded
    · exact checked_bounded _

theorem checkedRemainder_bounded (left right : Interval) : (checkedRemainder left right).bounds.Bounded := by
  simp only [checkedRemainder]
  split
  · exact Interval.empty_bounded
  · split
    · exact Interval.empty_bounded
    · exact checked_bounded _

theorem checkedDivide_sound {left right : Interval} {a b : Int}
    (safe : (checkedDivide left right).safe = true)
    (ha : left.Contains a) (hb : right.Contains b) :
    (checkedDivide left right).bounds.Contains (a.tdiv b) ∧
      DivideDefined a b ∧ InRange (a.tdiv b) := by
  unfold checkedDivide at safe ⊢
  split at safe
  · contradiction
  · rename_i nonzero
    simp only [nonzero, ↓reduceIte, Interval.contains_nonempty ha,
      Interval.contains_nonempty hb, Bool.false_or, Bool.false_eq_true, ↓reduceIte] at safe ⊢
    have result := checked_sound safe (Interval.divide_contains nonzero ha hb)
    exact ⟨result.1, divide_defined_of_range (Interval.excludes_zero nonzero hb).1 result.2, result.2⟩

theorem checkedModulo_sound {left right : Interval} {a b : Int}
    (safe : (checkedModulo left right).safe = true)
    (ha : left.Contains a) (hb : right.Contains b) :
    (checkedModulo left right).bounds.Contains (a.fmod b) ∧
      ModuloDefined a b ∧ InRange (a.fmod b) := by
  unfold checkedModulo at safe ⊢
  split at safe
  · contradiction
  · rename_i nonzero
    simp only [nonzero, ↓reduceIte, Interval.contains_nonempty ha,
      Interval.contains_nonempty hb, Bool.false_or, Bool.false_eq_true, ↓reduceIte] at safe ⊢
    have result := checked_sound safe (Interval.modulo_contains nonzero ha hb)
    exact ⟨result.1, (Interval.excludes_zero nonzero hb).1, result.2⟩

theorem checkedRemainder_sound {left right : Interval} {a b : Int}
    (safe : (checkedRemainder left right).safe = true)
    (ha : left.Contains a) (hb : right.Contains b) :
    (checkedRemainder left right).bounds.Contains (a.tmod b) ∧
      RemainderDefined a b ∧ InRange (a.tmod b) := by
  unfold checkedRemainder at safe ⊢
  split at safe
  · contradiction
  · rename_i nonzero
    simp only [nonzero, ↓reduceIte, Interval.contains_nonempty ha,
      Interval.contains_nonempty hb, Bool.false_or, Bool.false_eq_true, ↓reduceIte] at safe ⊢
    have result := checked_sound safe (Interval.remainder_contains nonzero ha hb)
    exact ⟨result.1, (Interval.excludes_zero nonzero hb).1, result.2⟩

theorem checkedDivide_singleton {a b : Int} (nonzero : b ≠ 0) :
    checkedDivide (.singleton a) (.singleton b) = checked (.singleton (a.tdiv b)) := by
  have outside : ¬ (Interval.singleton b).Contains 0 := by
    intro inside
    exact nonzero ((Interval.singleton_contains b 0).mp inside).symm
  rw [checkedDivide, ite_eq_right outside]
  simp [Interval.isEmpty, Interval.singleton, Interval.divide]

theorem checkedModulo_singleton {a b : Int} (nonzero : b ≠ 0) :
    checkedModulo (.singleton a) (.singleton b) = checked (.singleton (a.fmod b)) := by
  have outside : ¬ (Interval.singleton b).Contains 0 := by
    intro inside
    exact nonzero ((Interval.singleton_contains b 0).mp inside).symm
  rw [checkedModulo, ite_eq_right outside]
  simp [Interval.isEmpty, Interval.singleton, Interval.modulo]

theorem checkedRemainder_singleton {a b : Int} (nonzero : b ≠ 0) :
    checkedRemainder (.singleton a) (.singleton b) = checked (.singleton (a.tmod b)) := by
  have outside : ¬ (Interval.singleton b).Contains 0 := by
    intro inside
    exact nonzero ((Interval.singleton_contains b 0).mp inside).symm
  rw [checkedRemainder, ite_eq_right outside]
  simp [Interval.isEmpty, Interval.singleton, Interval.remainder]

/-- Every arithmetic endpoint used by the native helpers fits its signed
64-bit calculation type. Negating Integer'First takes place in that type. -/
theorem endpoint_division_wide {a b : Int} (ha : InRange a) (hb : InRange b)
    (nonzero : b ≠ 0) :
    WideInRange (a.tdiv b) ∧ WideInRange (a.fmod b) ∧ WideInRange (a.tmod b) ∧
      WideInRange (-b) ∧ WideInRange (b - 1) ∧ WideInRange (b + 1) := by
  have quotient := Int.natAbs_tdiv_le_natAbs a b
  have quotientLow := Int.le_natAbs (a := -(a.tdiv b))
  have quotientHigh := Int.le_natAbs (a := a.tdiv b)
  simp only [Int.natAbs_neg] at quotientLow
  have magnitude := Int.natAbs_eq a
  have modulo := fmod_bounds (left := a) nonzero
  have remainder := tmod_dividend_bounds a b
  simp only [InRange, minValue, maxValue, WideInRange] at *
  constructor
  · omega
  constructor
  · by_cases positive : 0 < b
    · have bounds := modulo.1 positive; omega
    · have bounds := modulo.2 (by omega); omega
  constructor
  · by_cases positive : 0 ≤ a
    · have bounds := remainder.1 positive; omega
    · have bounds := remainder.2 (by omega); omega
  · omega

end Silver.Integer
