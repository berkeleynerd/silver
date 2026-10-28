module

public import Silver.IntegerChecks

@[expose] public section

namespace Silver.Integer

/-- Ada evaluates the bounds once. Reversal changes enumeration order, and
does not exchange the written lower and upper bounds. Null ranges stay empty. -/
def iterationValues (reverse : Bool) (lower upper : Int) : List Int :=
  let forward := (List.range (upper - lower + 1).toNat).map fun (offset : Nat) => lower + (offset : Int)
  if reverse then forward.reverse else forward

theorem iterationValues_contains {reverse : Bool} {lower upper value : Int}
    (member : value ∈ iterationValues reverse lower upper) : lower ≤ value ∧ value ≤ upper := by
  simp only [iterationValues] at member
  have forward : value ∈ (List.range (upper - lower + 1).toNat).map (fun (offset : Nat) => lower + (offset : Int)) := by
    cases reverse
    · exact member
    · exact List.mem_reverse.mp member
  obtain ⟨offset, present, rfl⟩ := List.mem_map.mp forward
  have before := List.mem_range.mp present
  omega

theorem iterationValues_empty {reverse : Bool} {lower upper : Int} (empty : upper < lower) :
    iterationValues reverse lower upper = [] := by
  have zero : (upper - lower + 1).toNat = 0 := by omega
  simp [iterationValues, zero]

theorem iterationValues_nonempty {reverse : Bool} {lower upper : Int} (nonempty : lower ≤ upper) :
    iterationValues reverse lower upper ≠ [] := by
  have first : lower ∈ (List.range (upper - lower + 1).toNat).map (fun (offset : Nat) => lower + (offset : Int)) :=
    List.mem_map.mpr ⟨0, List.mem_range.mpr (by omega), by simp⟩
  have member : lower ∈ iterationValues reverse lower upper := by
    cases reverse
    · exact first
    · exact List.mem_reverse.mpr first
  intro empty
  simp only [empty, List.not_mem_nil] at member

/-- Every component index occurs, including either extreme Integer endpoint;
the enumeration uses mathematical offsets rather than a successor past Last. -/
theorem iterationValues_mem_iff {reverse : Bool} {lower upper value : Int} :
    value ∈ iterationValues reverse lower upper ↔ lower ≤ value ∧ value ≤ upper := by
  constructor
  · exact iterationValues_contains
  · intro inside
    have forward : value ∈ (List.range (upper - lower + 1).toNat).map
        (fun (offset : Nat) => lower + (offset : Int)) := by
      apply List.mem_map.mpr
      exact ⟨(value - lower).toNat, List.mem_range.mpr (by omega), by omega⟩
    cases reverse
    · exact forward
    · exact List.mem_reverse.mpr forward

theorem iterationValues_length (reverse : Bool) (lower upper : Int) :
    (iterationValues reverse lower upper).length = (upper - lower + 1).toNat := by
  cases reverse <;> simp [iterationValues]

/-- The order is strictly increasing, or strictly decreasing under reverse. -/
theorem iterationValues_ordered (reverse : Bool) (lower upper : Int) :
    (iterationValues reverse lower upper).Pairwise
      (fun left right => if reverse then right < left else left < right) := by
  have forward : ((List.range (upper - lower + 1).toNat).map
      (fun (offset : Nat) => lower + (offset : Int))).Pairwise (· < ·) :=
    List.pairwise_lt_range.map _ (by intro left right less; omega)
  cases reverse <;>
    simpa only [iterationValues, Bool.false_eq_true, ↓reduceIte, List.pairwise_reverse] using forward

/-- Each component is visited once, independently of the component values. -/
theorem iterationValues_nodup (reverse : Bool) (lower upper : Int) :
    (iterationValues reverse lower upper).Nodup := by
  apply (iterationValues_ordered reverse lower upper).imp
  intro left right ordered
  cases reverse <;> simp only [Bool.false_eq_true, ↓reduceIte] at ordered <;> omega

def loopBounds (lower upper : Interval) : Interval :=
  if lower.isEmpty || upper.isEmpty then Interval.empty
  else Interval.normalize ⟨lower.lower, upper.upper⟩

def loopDefinite (lower upper : Interval) : Bool :=
  !lower.isEmpty && !upper.isEmpty && decide (lower.upper ≤ upper.lower)

theorem loopBounds_bounded {lower upper : Interval} (a : lower.Bounded) (b : upper.Bounded) :
    (loopBounds lower upper).Bounded := by
  simp only [loopBounds]; split
  · exact Interval.empty_bounded
  · exact Interval.normalize_bounded ⟨a.1, b.2⟩

theorem loopBounds_contains {lower upper : Interval} {a b value : Int}
    (ha : lower.Contains a) (hb : upper.Contains b) (between : a ≤ value ∧ value ≤ b) :
    (loopBounds lower upper).Contains value := by
  simp only [loopBounds, Interval.contains_nonempty ha, Interval.contains_nonempty hb,
    Bool.false_or, Bool.false_eq_true, ↓reduceIte]
  apply Interval.normalize_contains
  simp only [Interval.Contains] at *
  omega

theorem loopBounds_empty {lower upper : Interval} {a b : Int}
    (ha : lower.Contains a) (hb : upper.Contains b) (empty : (loopBounds lower upper).isEmpty = true) :
    b < a := by
  by_cases nonempty : b < a
  · exact nonempty
  · have within := loopBounds_contains ha hb (value := a) ⟨Int.le_refl _, by omega⟩
    have notEmpty := Interval.contains_nonempty within
    simp only [notEmpty, Bool.false_eq_true] at empty

theorem loopDefinite_nonempty {lower upper : Interval} {a b : Int}
    (ha : lower.Contains a) (hb : upper.Contains b) (definite : loopDefinite lower upper = true) : a ≤ b := by
  simp only [loopDefinite, Bool.and_eq_true, decide_eq_true_eq] at definite
  simp only [Interval.Contains] at ha hb
  omega

theorem loop_index_fits {ranges : Ranges} {values : Store} {lower upper : Expr}
    {a b : Interval} {index : Nat} {reverse : Bool} {value : Int}
    (lowerFound : lower.infer ranges = some a) (upperFound : upper.infer ranges = some b)
    (fits : Fits ranges values)
    (member : value ∈ iterationValues reverse (lower.evaluate values) (upper.evaluate values)) :
    Fits (put ranges index (some (loopBounds a b))) (put values index value) :=
  put_fits fits (loopBounds_contains (Expr.infer_sound lowerFound fits).1
    (Expr.infer_sound upperFound fits).1 (iterationValues_contains member))

end Silver.Integer
