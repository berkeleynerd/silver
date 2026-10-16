module

public import Silver.IntegerImage

@[expose] public section

/-! A finite arithmetic expression for the Image length theorem. Its tests are
linear integer comparisons, suitable for the native proof representation.
This file supplies mathematical justification, not a native adapter. -/
namespace Silver.Integer.Image

def digitTable : List (Nat × Nat) :=
  [(10, 1), (100, 2), (1000, 3), (10000, 4), (100000, 5),
   (1000000, 6), (10000000, 7), (100000000, 8), (1000000000, 9)]

def selectMagnitude (magnitude : Nat) (table : List (Nat × Nat)) (fallback : Nat) : Nat :=
  match table with
  | [] => fallback
  | (limit, digits) :: rest =>
    if magnitude < limit then digits else selectMagnitude magnitude rest fallback

def selectSigned (value : Int) (table : List (Nat × Nat)) (fallback : Nat) : Nat :=
  match table with
  | [] => fallback
  | (limit, digits) :: rest =>
    if -(limit : Int) < value ∧ value < (limit : Int) then digits
    else selectSigned value rest fallback

def decimalDigitsBounded (magnitude : Nat) : Nat :=
  selectMagnitude magnitude digitTable 10

theorem decimalDigits_eq_of_bounds (magnitude digits : Nat) (positive : 0 < digits)
    (upper : magnitude < 10 ^ digits)
    (lower : digits = 1 ∨ 10 ^ (digits - 1) ≤ magnitude) :
    decimalDigits magnitude = digits := by
  have le := (decimalDigits_le_iff magnitude digits positive).mpr upper
  have nonzero := decimalDigits_positive magnitude
  rcases lower with one | lower
  · omega
  · by_cases single : digits = 1
    · omega
    · have notle : ¬decimalDigits magnitude ≤ digits - 1 := by
        intro small
        have lt := (decimalDigits_le_iff magnitude (digits - 1) (by omega)).mp small
        omega
      omega

theorem decimalDigitsBounded_exact (magnitude : Nat) (bounded : magnitude ≤ 2147483648) :
    decimalDigitsBounded magnitude = decimalDigits magnitude := by
  simp only [decimalDigitsBounded, digitTable, selectMagnitude]
  repeat' split
  all_goals symm
  all_goals apply decimalDigits_eq_of_bounds
  all_goals first | decide | (simp_all <;> omega)

def nativeLength (value : Int) : Int :=
  1 + (selectSigned value digitTable 10 : Int)

theorem magnitude_lt_iff (value : Int) (limit : Nat) :
    value.natAbs < limit ↔ -(limit : Int) < value ∧ value < (limit : Int) := by
  have abs := Int.natAbs_eq value
  omega

theorem selectSigned_eq (value : Int) (table : List (Nat × Nat)) (fallback : Nat) :
    selectSigned value table fallback = selectMagnitude value.natAbs table fallback := by
  induction table with
  | nil => rfl
  | cons item rest ih =>
    rcases item with ⟨limit, digits⟩
    simp only [selectSigned, selectMagnitude, magnitude_lt_iff, ih]

theorem nativeLength_eq_bounded (value : Int) :
    nativeLength value = 1 + (decimalDigitsBounded value.natAbs : Int) := by
  simp only [nativeLength, decimalDigitsBounded, selectSigned_eq]

theorem nativeLength_exact (value : Int) (bounded : InRange value) :
    nativeLength value = ((bytes value).length : Int) := by
  rw [nativeLength_eq_bounded, decimalDigitsBounded_exact _ (magnitude_bounded value bounded), length_exact]
  simp

end Silver.Integer.Image
