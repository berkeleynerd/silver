module

public import Silver.IntegerIntervals
public import Init.Data.Nat.ToString

@[expose] public section

/-! Decimal Image semantics for Ada's predefined signed Integer. These are
semantic facts, not yet a connection to GNATprove's abstract Image primitive.
The sign character is always present; negative magnitudes use mathematical
integers, so Integer'First is covered without native negation overflow. -/
namespace Silver.Integer.Image

def decimalDigits (magnitude : Nat) : Nat := (Nat.toDigits 10 magnitude).length

def characters (value : Int) : List Char :=
  (if value < 0 then '-' else ' ') :: Nat.toDigits 10 value.natAbs

def bytes (value : Int) : List Nat := (characters value).map Char.toNat

theorem magnitude_roundtrip (value : Int) :
    Nat.ofDigitChars 10 (characters value).tail 0 = value.natAbs := by
  simp only [characters, List.tail_cons]
  exact Nat.ofDigitChars_toDigits (by decide) (by decide)

theorem sign (value : Int) :
    (characters value).head? = some (if value < 0 then '-' else ' ') := rfl

theorem digit_characters (value : Int) (item : Char)
    (member : item ∈ (characters value).tail) : item.isDigit :=
  Nat.isDigit_of_mem_toDigits (by decide) (by decide) member

theorem length_exact (value : Int) :
    (bytes value).length = 1 + decimalDigits value.natAbs := by
  simp [bytes, characters, decimalDigits, Nat.add_comm]

theorem decimalDigits_positive (magnitude : Nat) : 0 < decimalDigits magnitude :=
  Nat.length_toDigits_pos

theorem decimalDigits_zero : decimalDigits 0 = 1 := by
  simp [decimalDigits, Nat.toDigits_zero]

theorem decimalDigits_le_iff (magnitude digits : Nat) (positive : 0 < digits) :
    decimalDigits magnitude ≤ digits ↔ magnitude < 10 ^ digits :=
  Nat.length_toDigits_le_iff (by decide) positive

theorem decimalDigits_mono {left right : Nat} (ordered : left ≤ right) :
    decimalDigits left ≤ decimalDigits right := by
  have positive := decimalDigits_positive right
  apply (decimalDigits_le_iff left _ positive).mpr
  exact Nat.lt_of_le_of_lt ordered ((decimalDigits_le_iff right _ positive).mp (Nat.le_refl _))

theorem magnitude_bounded (value : Int) (bounded : InRange value) :
    value.natAbs ≤ 2147483648 := by
  obtain positive | negative := Int.natAbs_eq value
  all_goals simp only [InRange, minValue, maxValue] at bounded; omega

theorem length_bounded (value : Int) (bounded : InRange value) :
    2 ≤ (bytes value).length ∧ (bytes value).length ≤ 11 := by
  rw [length_exact]
  have positive := decimalDigits_positive value.natAbs
  have upper : decimalDigits value.natAbs ≤ 10 :=
    (decimalDigits_le_iff _ 10 (by decide)).mpr (by
      have magnitude := magnitude_bounded value bounded
      change value.natAbs < 10000000000
      omega)
  omega

def minimumMagnitude (bounds : Interval) : Nat :=
  if bounds.lower ≤ 0 ∧ 0 ≤ bounds.upper then 0
  else min bounds.lower.natAbs bounds.upper.natAbs

def maximumMagnitude (bounds : Interval) : Nat :=
  max bounds.lower.natAbs bounds.upper.natAbs

theorem magnitude_interval (bounds : Interval) (value : Int) (within : bounds.Contains value) :
    minimumMagnitude bounds ≤ value.natAbs ∧ value.natAbs ≤ maximumMagnitude bounds := by
  simp only [Interval.Contains] at within
  obtain lowerPos | lowerNeg := Int.natAbs_eq bounds.lower
  all_goals obtain upperPos | upperNeg := Int.natAbs_eq bounds.upper
  all_goals obtain valuePos | valueNeg := Int.natAbs_eq value
  all_goals simp only [minimumMagnitude, maximumMagnitude]; split <;> omega

def lengthBounds (bounds : Interval) : Nat × Nat :=
  (1 + decimalDigits (minimumMagnitude bounds), 1 + decimalDigits (maximumMagnitude bounds))

theorem length_interval (bounds : Interval) (value : Int) (within : bounds.Contains value) :
    (lengthBounds bounds).1 ≤ (bytes value).length ∧
      (bytes value).length ≤ (lengthBounds bounds).2 := by
  obtain ⟨lower, upper⟩ := magnitude_interval bounds value within
  have lowerDigits := decimalDigits_mono lower
  have upperDigits := decimalDigits_mono upper
  simp only [lengthBounds, length_exact]
  omega

end Silver.Integer.Image
