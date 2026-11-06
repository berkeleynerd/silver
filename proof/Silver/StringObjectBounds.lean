module

public import Silver.IntegerIntervals

@[expose] public section

/-! Actual Ada String bounds are distinct from byte length. In particular, a
null slice retains both supplied endpoints, a null left concatenation returns
the right operand, and assignment slides bytes onto the target's old bounds.
These definitions preserve that information for the source declaration bridge.
The generic initialized byte store continues to describe bytes and lengths. -/

namespace Silver.StringObjectBounds

structure Bounds where
  first : Int
  last : Int
  deriving DecidableEq, Repr

def Bounds.length (bounds : Bounds) : Nat := (bounds.last - bounds.first + 1).toNat

def Bounds.isNull (bounds : Bounds) : Bool := decide (bounds.last < bounds.first)

/-- Null bounds need only belong to the index base type. A nonnull String has
Positive indexes; the upper endpoint remains inside Standard.Integer. -/
def Bounds.Valid (bounds : Bounds) : Prop :=
  Integer.InRange bounds.first ∧ Integer.InRange bounds.last ∧
    (bounds.last < bounds.first ∨ 1 ≤ bounds.first)

instance (bounds : Bounds) : Decidable bounds.Valid :=
  inferInstanceAs (Decidable (_ ∧ _ ∧ _))

def Bounds.canonical (length : Nat) : Bounds := ⟨1, length⟩

def Bounds.concatenate (left right : Bounds) : Bounds :=
  if left.isNull then right else ⟨left.first, left.last + right.length⟩

def Bounds.canConcatenate (left right : Bounds) : Bool :=
  left.isNull || decide (left.last + right.length ≤ Integer.maxValue)

theorem Bounds.null_iff_length_zero (bounds : Bounds) :
    bounds.isNull = true ↔ bounds.length = 0 := by
  simp only [isNull, decide_eq_true_eq, length]
  omega

theorem Bounds.nonnull_length (bounds : Bounds) (nonnull : bounds.isNull = false) :
    (bounds.length : Int) = bounds.last - bounds.first + 1 := by
  simp only [isNull, decide_eq_false_iff_not] at nonnull
  simp only [length]
  omega

theorem Bounds.canonical_length (length : Nat) : (canonical length).length = length := by
  simp [canonical, Bounds.length]

theorem Bounds.concatenate_null_left (left right : Bounds) (empty : left.isNull = true) :
    left.concatenate right = right := by simp [concatenate, empty]

theorem Bounds.concatenate_length (left right : Bounds) :
    (left.concatenate right).length = left.length + right.length := by
  by_cases empty : left.isNull = true
  · have zero := (null_iff_length_zero left).mp empty
    simp [concatenate, empty, zero]
  · have nonnull : left.isNull = false := Bool.eq_false_iff.mpr empty
    have exact := nonnull_length left nonnull
    simp only [concatenate, nonnull, Bool.false_eq_true, ↓reduceIte, length]
    omega

theorem Bounds.concatenate_nonnull (left right : Bounds) (nonnull : left.isNull = false) :
    (left.concatenate right).isNull = false := by
  have ordered : left.first ≤ left.last := by
    simp only [isNull, decide_eq_false_iff_not] at nonnull
    omega
  rw [concatenate, ite_eq_right (by simp [nonnull])]
  simp only [isNull, decide_eq_false_iff_not]
  omega

theorem Bounds.concatenate_of_nonnull (left right : Bounds) (nonnull : left.isNull = false) :
    left.concatenate right = ⟨left.first, left.last + right.length⟩ := by
  simp [concatenate, nonnull]

theorem Bounds.concatenate_first (left right : Bounds) (nonnull : left.isNull = false) :
    (left.concatenate right).first = left.first := by simp [concatenate, nonnull]

theorem Bounds.concatenate_assoc (left middle right : Bounds) :
    (left.concatenate middle).concatenate right = left.concatenate (middle.concatenate right) := by
  by_cases empty : left.isNull = true
  · simp [concatenate, empty]
  · have nonnull : left.isNull = false := Bool.eq_false_iff.mpr empty
    have resultNonNull := concatenate_nonnull left middle nonnull
    rw [concatenate_of_nonnull _ _ resultNonNull,
      concatenate_of_nonnull left middle nonnull,
      concatenate_of_nonnull left (middle.concatenate right) nonnull,
      concatenate_length]
    simp [Int.natCast_add, Int.add_assoc]

theorem Bounds.concatenate_valid (left right : Bounds) (leftValid : left.Valid)
    (rightValid : right.Valid) (checked : left.canConcatenate right = true) :
    (left.concatenate right).Valid := by
  by_cases empty : left.isNull = true
  · simpa [concatenate, empty] using rightValid
  · have nonnull : left.isNull = false := Bool.eq_false_iff.mpr empty
    have ordered : left.first ≤ left.last := by
      simp only [isNull, decide_eq_false_iff_not] at nonnull
      omega
    simp only [canConcatenate, nonnull, Bool.false_or, decide_eq_true_eq] at checked
    simp only [concatenate, nonnull, Bool.false_eq_true, ↓reduceIte, Valid,
      Integer.InRange] at *
    omega

/-- Only a nonnull operand's lower bound can become the lower bound of a
nonnull concatenation. Arbitrarily large null endpoints are therefore harmless
to this invariant; retaining them must not produce an artificial rejection. -/
def Bounds.FirstBound (bounds : Bounds) (ceiling : Int) : Prop :=
  bounds.isNull = true ∨ bounds.first ≤ ceiling

theorem Bounds.concatenate_firstBound (left right : Bounds) (ceiling : Int)
    (leftBound : left.FirstBound ceiling) (rightBound : right.FirstBound ceiling) :
    (left.concatenate right).FirstBound ceiling := by
  by_cases empty : left.isNull = true
  · simpa [concatenate, empty] using rightBound
  · have nonnull : left.isNull = false := Bool.eq_false_iff.mpr empty
    rcases leftBound with impossible | upper
    · exact False.elim (empty impossible)
    · exact Or.inr (by simpa [concatenate, nonnull] using upper)

theorem Bounds.upper_from_first_and_length (bounds : Bounds) (ceiling : Int) (limit : Nat)
    (firstBound : bounds.FirstBound ceiling) (bounded : bounds.length ≤ limit)
    (nonnull : bounds.isNull = false) : bounds.last ≤ ceiling + (limit : Int) - 1 := by
  have length := bounds.nonnull_length nonnull
  rcases firstBound with empty | first
  · simp [nonnull] at empty
  · omega

theorem Bounds.fold_firstBound (operands : List Bounds) (initial : Bounds) (ceiling : Int)
    (initialBound : initial.FirstBound ceiling)
    (operandBounds : ∀ operand ∈ operands, operand.FirstBound ceiling) :
    (operands.foldl Bounds.concatenate initial).FirstBound ceiling := by
  induction operands generalizing initial with
  | nil => exact initialBound
  | cons head tail ih =>
      apply ih (initial.concatenate head)
      · exact concatenate_firstBound _ _ _ initialBound (operandBounds head (by simp))
      · intro operand member
        exact operandBounds operand (by simp [member])

/-- The native binding table has at most 4096 / 12 slots. Each new fixed
declaration's nonnull upper bound is at most one further source-length block.
One body expression adds at most another block, far below Integer'Last. -/
theorem source_sized_upper_bound (count : Nat) (within : count ≤ 4096 / 12) :
    ((count + 1) * 4096 : Int) ≤ Integer.maxValue := by
  simp only [Integer.maxValue]
  omega

/-- Initialization captures the expression's actual bounds. Whole assignment
instead retains the existing target bounds and replaces only the value. -/
structure Value where
  bounds : Bounds
  bytes : List Nat
  exactLength : bytes.length = bounds.length

def Value.concatenate (left right : Value) : Value :=
  ⟨left.bounds.concatenate right.bounds, left.bytes ++ right.bytes, by
    rw [List.length_append, left.exactLength, right.exactLength, Bounds.concatenate_length]⟩

def Value.slide (target source : Value) (compatible : source.bytes.length = target.bytes.length) : Value :=
  ⟨target.bounds, source.bytes, compatible.trans target.exactLength⟩

theorem Value.slide_bounds (target source : Value) (compatible) :
    (target.slide source compatible).bounds = target.bounds := rfl

theorem Value.slide_bytes (target source : Value) (compatible) :
    (target.slide source compatible).bytes = source.bytes := rfl

theorem null_bounds_not_normalized :
    (Bounds.mk 100 (-100)).length = 0 ∧
      ((Bounds.mk 1 0).concatenate (Bounds.mk 100 (-100))) = Bounds.mk 100 (-100) := by
  decide

end Silver.StringObjectBounds
