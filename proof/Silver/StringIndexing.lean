module

public import Silver.IntegerExpressions
public import Silver.OutputLiteral

@[expose] public section

/-! Bounds for fixed String objects are supplied by the source correspondence
invariant. These operations preserve Ada's indexing and null-slice meaning;
the list representation contains bytes in increasing index order. -/
namespace Silver.StringIndexing

def indexValid (base : Int) (length : Nat) (index : Int) : Prop :=
  base ≤ index ∧ index < base + (length : Int)

instance (base : Int) (length : Nat) (index : Int) :
    Decidable (indexValid base length index) := inferInstanceAs (Decidable (_ ∧ _))

def indexCheck (base : Int) (length : Nat) (indices : Integer.Interval) : Bool :=
  decide (indices.lower ≤ indices.upper ∧ base ≤ indices.lower ∧
    indices.upper < base + (length : Int))

theorem indexCheck_sound {base : Int} {length : Nat} {indices : Integer.Interval} {index : Int}
    (checked : indexCheck base length indices = true) (within : indices.Contains index) :
    indexValid base length index := by
  simp only [indexCheck, decide_eq_true_eq, Integer.Interval.Contains, indexValid] at *
  omega

theorem indexCheck_singleton {base index : Int} {length : Nat}
    (valid : indexValid base length index) :
    indexCheck base length (Integer.Interval.singleton index) = true := by
  unfold indexCheck
  apply decide_eq_true
  exact ⟨Int.le_refl _, valid⟩

def offset (base index : Int) : Nat := (index - base).toNat

theorem offset_lt {base index : Int} {length : Nat} (valid : indexValid base length index) :
    offset base index < length := by
  simp only [indexValid, offset] at *
  omega

theorem offset_injective {base first second : Int} (a : base ≤ first) (b : base ≤ second) :
    offset base first = offset base second ↔ first = second := by
  simp only [offset]
  omega

def sliceValid (base : Int) (length : Nat) (lower upper : Int) : Prop :=
  lower > upper ∨ (base ≤ lower ∧ upper < base + (length : Int))

instance (base : Int) (length : Nat) (lower upper : Int) :
    Decidable (sliceValid base length lower upper) := inferInstanceAs (Decidable (_ ∨ _))

/-- Endpoint intervals must be nonempty even in unreachable source. Bounds
outside the prefix are allowed precisely when every represented nonnull
slice remains contained. Null slices do not have an Ada prefix-index check. -/
def sliceCheck (base : Int) (length : Nat) (lower upper : Integer.Interval) : Bool :=
  decide (lower.lower ≤ lower.upper ∧ upper.lower ≤ upper.upper ∧
    lower.upper - upper.lower ≤ Integer.maxValue ∧
    (lower.lower > upper.upper ∨
      (base ≤ lower.lower ∧ upper.upper < base + (length : Int))))

theorem sliceCheck_sound {base : Int} {length : Nat} {lower upper : Integer.Interval} {a b : Int}
    (checked : sliceCheck base length lower upper = true)
    (left : lower.Contains a) (right : upper.Contains b) : sliceValid base length a b := by
  simp only [sliceCheck, decide_eq_true_eq, Integer.Interval.Contains, sliceValid] at *
  omega

/-- The native equality expansion subtracts requested endpoints in Integer.
This is a pinned-frontend admission restriction, not an Ada null-slice rule. -/
theorem sliceCheck_nativeSpan {base : Int} {length : Nat}
    {lower upper : Integer.Interval} {a b : Int}
    (checked : sliceCheck base length lower upper = true)
    (left : lower.Contains a) (right : upper.Contains b) : a - b ≤ Integer.maxValue := by
  simp only [sliceCheck, decide_eq_true_eq, Integer.Interval.Contains] at *
  omega

theorem sliceCheck_singletons {base lower upper : Int} {length : Nat}
    (valid : sliceValid base length lower upper)
    (nativeSpan : lower - upper ≤ Integer.maxValue) :
    sliceCheck base length (Integer.Interval.singleton lower) (Integer.Interval.singleton upper) = true := by
  unfold sliceCheck
  apply decide_eq_true
  exact ⟨Int.le_refl _, Int.le_refl _, nativeSpan, valid⟩

def sliceLength (lower upper : Int) : Nat := (upper - lower + 1).toNat

def sliceMinimum (lower upper : Integer.Interval) : Nat := sliceLength lower.upper upper.lower
def sliceMaximum (lower upper : Integer.Interval) : Nat := sliceLength lower.lower upper.upper

theorem sliceLength_bounds {lower upper : Integer.Interval} {a b : Int}
    (left : lower.Contains a) (right : upper.Contains b) :
    sliceMinimum lower upper ≤ sliceLength a b ∧ sliceLength a b ≤ sliceMaximum lower upper := by
  simp only [sliceMinimum, sliceMaximum, sliceLength, Integer.Interval.Contains] at *
  omega

def slice (bytes : Source) (base lower upper : Int) : Source :=
  (bytes.drop (offset base lower)).take (sliceLength lower upper)

theorem slice_null (bytes : Source) {base lower upper : Int} (empty : upper < lower) :
    slice bytes base lower upper = [] := by
  have zero : sliceLength lower upper = 0 := by simp only [sliceLength]; omega
  simp [slice, zero]

theorem slice_length (bytes : Source) {base lower upper : Int}
    (valid : sliceValid base bytes.length lower upper) :
    (slice bytes base lower upper).length = sliceLength lower upper := by
  rcases valid with empty | contained
  · rw [slice_null bytes empty]
    simp only [List.length_nil, sliceLength]
    omega
  · simp only [slice, List.length_take, List.length_drop, offset, sliceLength]
    omega

theorem slice_member {bytes : Source} {base lower upper : Int} {byte : Nat}
    (member : byte ∈ slice bytes base lower upper) : byte ∈ bytes :=
  List.mem_of_mem_drop (List.mem_of_mem_take member)

def read (bytes : Source) (base index : Int) : Nat :=
  (bytes[offset base index]?).getD 32

theorem read_member {bytes : Source} {base index : Int}
    (valid : indexValid base bytes.length index) : read bytes base index ∈ bytes := by
  have present := List.getElem?_eq_getElem (offset_lt valid)
  simp only [read, present, Option.getD_some]
  exact List.getElem_mem _

theorem read_printable {bytes : Source} {base index : Int}
    (printable : ∀ byte ∈ bytes, Output.printable byte = true) :
    Output.printable (read bytes base index) = true := by
  unfold read
  cases found : bytes[offset base index]? with
  | none => decide
  | some byte => exact printable byte (List.mem_of_getElem? found)

def replace (bytes : Source) (base index : Int) (byte : Nat) : Source :=
  bytes.set (offset base index) byte

@[simp] theorem replace_length (bytes : Source) (base index : Int) (byte : Nat) :
    (replace bytes base index byte).length = bytes.length := List.length_set

theorem replace_same {bytes : Source} {base index : Int} {byte : Nat}
    (valid : indexValid base bytes.length index) :
    read (replace bytes base index byte) base index = byte := by
  simp [read, replace, List.getElem?_set_self (offset_lt valid)]

theorem replace_other (bytes : Source) {base index other : Int} (byte : Nat)
    (inside : base ≤ index) (otherInside : base ≤ other) (different : other ≠ index) :
    read (replace bytes base index byte) base other = read bytes base other := by
  have distinct : offset base index ≠ offset base other := by
    intro same
    exact different ((offset_injective inside otherInside).mp same).symm
  simp only [read, replace, List.getElem?_set_ne distinct]

theorem replace_printable {bytes : Source} {base index : Int} {byte : Nat}
    (original : ∀ item ∈ bytes, Output.printable item = true)
    (replacement : Output.printable byte = true) :
    ∀ item ∈ replace bytes base index byte, Output.printable item = true := by
  intro item member
  rcases List.mem_or_eq_of_mem_set member with old | rfl
  · exact original item old
  · exact replacement

end Silver.StringIndexing
