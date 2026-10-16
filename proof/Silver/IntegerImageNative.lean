module

public import Silver.IntegerImageLength

@[expose] public section

/-! Mathematical denotations of the native Image length helpers. The companion
source module checks their complete typed bodies against the authoritative Ada. -/
namespace Silver.Integer.Image.Native

def lengthOf (item : Int) : Nat := 1 + selectSigned item digitTable 10

def minimumLength (bounds : Interval) : Nat :=
  if bounds.isEmpty then 0
  else if bounds.lower ≤ 0 ∧ 0 ≤ bounds.upper then 2
  else min (lengthOf bounds.lower) (lengthOf bounds.upper)

def maximumLength (bounds : Interval) : Nat :=
  if bounds.isEmpty then 0 else max (lengthOf bounds.lower) (lengthOf bounds.upper)

theorem lengthOf_native (item : Int) : (lengthOf item : Int) = nativeLength item := by
  simp [lengthOf, nativeLength]

theorem lengthOf_exact (item : Int) (bounded : InRange item) :
    lengthOf item = (bytes item).length := by
  have exact := nativeLength_exact item bounded
  rw [← lengthOf_native] at exact
  exact Int.ofNat_inj.mp exact

theorem lengthOf_bounded (item : Int) (bounded : InRange item) :
    2 ≤ lengthOf item ∧ lengthOf item ≤ 11 := by
  rw [lengthOf_exact item bounded]
  exact length_bounded item bounded

private theorem min_digits (a b : Nat) :
    min (1 + decimalDigits a) (1 + decimalDigits b) =
      1 + decimalDigits (min a b) := by
  by_cases ordered : a ≤ b
  · have monotone := decimalDigits_mono ordered
    rw [Nat.min_eq_left ordered, Nat.min_eq_left (by omega)]
  · have reverse : b ≤ a := by omega
    have monotone := decimalDigits_mono reverse
    rw [Nat.min_eq_right reverse, Nat.min_eq_right (by omega)]

private theorem max_digits (a b : Nat) :
    max (1 + decimalDigits a) (1 + decimalDigits b) =
      1 + decimalDigits (max a b) := by
  by_cases ordered : a ≤ b
  · have monotone := decimalDigits_mono ordered
    rw [Nat.max_eq_right ordered, Nat.max_eq_right (by omega)]
  · have reverse : b ≤ a := by omega
    have monotone := decimalDigits_mono reverse
    rw [Nat.max_eq_left reverse, Nat.max_eq_left (by omega)]

theorem minimumLength_eq (bounds : Interval) (bounded : bounds.Bounded) :
    minimumLength bounds = if bounds.isEmpty then 0 else (lengthBounds bounds).1 := by
  cases empty : bounds.isEmpty with
  | true => simp only [minimumLength, empty, ↓reduceIte]
  | false =>
      simp only [minimumLength, empty, Bool.false_eq_true, ↓reduceIte]
      rw [lengthOf_exact bounds.lower bounded.1, lengthOf_exact bounds.upper bounded.2]
      simp only [length_exact, lengthBounds, minimumMagnitude]
      by_cases crosses : bounds.lower ≤ 0 ∧ 0 ≤ bounds.upper
      · simp [crosses, decimalDigits_zero]
      · simp only [crosses, ↓reduceIte]
        exact min_digits _ _

theorem maximumLength_eq (bounds : Interval) (bounded : bounds.Bounded) :
    maximumLength bounds = if bounds.isEmpty then 0 else (lengthBounds bounds).2 := by
  cases empty : bounds.isEmpty with
  | true => simp only [maximumLength, empty, ↓reduceIte]
  | false =>
      simp only [maximumLength, empty, Bool.false_eq_true, ↓reduceIte]
      rw [lengthOf_exact bounds.lower bounded.1, lengthOf_exact bounds.upper bounded.2]
      simp only [length_exact, lengthBounds, maximumMagnitude]
      exact max_digits _ _

theorem minimumLength_bounded (bounds : Interval) (bounded : bounds.Bounded) :
    minimumLength bounds ≤ 11 := by
  have lower := lengthOf_bounded bounds.lower bounded.1
  have upper := lengthOf_bounded bounds.upper bounded.2
  unfold minimumLength
  split
  · omega
  · split
    · omega
    · exact Nat.le_trans (Nat.min_le_left _ _) lower.2

theorem maximumLength_bounded (bounds : Interval) (bounded : bounds.Bounded) :
    maximumLength bounds ≤ 11 := by
  have lower := lengthOf_bounded bounds.lower bounded.1
  have upper := lengthOf_bounded bounds.upper bounded.2
  unfold maximumLength
  split
  · omega
  · exact Nat.max_le.mpr ⟨lower.2, upper.2⟩

theorem lengths_contain (bounds : Interval) (bounded : bounds.Bounded) (item : Int)
    (within : bounds.Contains item) :
    minimumLength bounds ≤ (bytes item).length ∧
      (bytes item).length ≤ maximumLength bounds := by
  rw [minimumLength_eq bounds bounded, maximumLength_eq bounds bounded,
    Interval.contains_nonempty within]
  exact length_interval bounds item within

end Silver.Integer.Image.Native
