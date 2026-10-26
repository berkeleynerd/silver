module

public import Silver.IntegerIntervals

@[expose] public section

namespace Silver.Integer

inductive Comparison
  | eq | ne | lt | le | gt | ge
  deriving DecidableEq, Repr

def Comparison.evaluate (operator : Comparison) (left right : Int) : Bool :=
  match operator with
  | .eq => decide (left = right)
  | .ne => decide (left ≠ right)
  | .lt => decide (left < right)
  | .le => decide (left ≤ right)
  | .gt => decide (left > right)
  | .ge => decide (left ≥ right)

def Comparison.complement : Comparison → Comparison
  | .eq => .ne | .ne => .eq | .lt => .ge | .le => .gt | .gt => .le | .ge => .lt

def Comparison.swap : Comparison → Comparison
  | .eq => .eq | .ne => .ne | .lt => .gt | .le => .ge | .gt => .lt | .ge => .le

theorem Comparison.complement_evaluate (operator : Comparison) (left right : Int) :
    operator.complement.evaluate left right = !(operator.evaluate left right) := by
  cases operator <;> simp only [complement, evaluate, ← decide_not] <;>
    apply Bool.eq_iff_iff.mpr <;> simp only [decide_eq_true_eq] <;> omega

theorem Comparison.swap_evaluate (operator : Comparison) (left right : Int) :
    operator.swap.evaluate right left = operator.evaluate left right := by
  cases operator <;> simp [swap, evaluate, eq_comm]

namespace Interval

def below (bounds : Interval) (threshold : Int) : Interval :=
  if threshold = minValue then empty else bounds.intersect ⟨minValue, threshold - 1⟩

def above (bounds : Interval) (threshold : Int) : Interval :=
  if threshold = maxValue then empty else bounds.intersect ⟨threshold + 1, maxValue⟩

def refineTrue (bounds : Interval) (operator : Comparison) (threshold : Int) : Interval :=
  match operator with
  | .eq => bounds.intersect (singleton threshold)
  | .ne => (bounds.below threshold).join (bounds.above threshold)
  | .lt => bounds.below threshold
  | .le => bounds.intersect ⟨minValue, threshold⟩
  | .gt => bounds.above threshold
  | .ge => bounds.intersect ⟨threshold, maxValue⟩

def refine (bounds : Interval) (operator : Comparison) (threshold : Int) (truth : Bool) : Interval :=
  bounds.refineTrue (if truth then operator else operator.complement) threshold

theorem below_sound {bounds : Interval} {threshold value : Int}
    (within : bounds.Contains value) (range : InRange value) (less : value < threshold) :
    (bounds.below threshold).Contains value := by
  simp only [below]
  split
  · simp only [InRange] at range; omega
  · apply (intersect_contains _ _ _).mpr
    exact ⟨within, by simp only [Contains]; simp only [InRange] at range; omega⟩

theorem above_sound {bounds : Interval} {threshold value : Int}
    (within : bounds.Contains value) (range : InRange value) (greater : threshold < value) :
    (bounds.above threshold).Contains value := by
  simp only [above]
  split
  · simp only [InRange] at range; omega
  · apply (intersect_contains _ _ _).mpr
    exact ⟨within, by simp only [Contains]; simp only [InRange] at range; omega⟩

theorem refineTrue_sound {bounds : Interval} {operator : Comparison} {threshold value : Int}
    (within : bounds.Contains value) (range : InRange value)
    (holds : operator.evaluate value threshold = true) :
    (bounds.refineTrue operator threshold).Contains value := by
  cases operator with
  | eq =>
      have same : value = threshold := by simpa only [Comparison.evaluate, decide_eq_true_eq] using holds
      exact (intersect_contains _ _ _).mpr ⟨within, (singleton_contains _ _).mpr same⟩
  | ne =>
      have different : value ≠ threshold := by simpa only [Comparison.evaluate, decide_eq_true_eq] using holds
      by_cases less : value < threshold
      · exact join_left (below_sound within range less)
      · exact join_right (above_sound within range (by omega))
  | lt =>
      apply below_sound within range
      simpa only [Comparison.evaluate, decide_eq_true_eq] using holds
  | le =>
      apply (intersect_contains _ _ _).mpr
      simp only [Comparison.evaluate, decide_eq_true_eq] at holds
      exact ⟨within, range.1, holds⟩
  | gt =>
      apply above_sound within range
      simpa only [Comparison.evaluate, decide_eq_true_eq] using holds
  | ge =>
      apply (intersect_contains _ _ _).mpr
      simp only [Comparison.evaluate, decide_eq_true_eq] at holds
      exact ⟨within, holds, range.2⟩

theorem refine_sound {bounds : Interval} {operator : Comparison} {threshold value : Int} {truth : Bool}
    (within : bounds.Contains value) (range : InRange value)
    (holds : operator.evaluate value threshold = truth) :
    (bounds.refine operator threshold truth).Contains value := by
  apply refineTrue_sound within range
  cases truth with
  | true => exact holds
  | false => simp only [Bool.false_eq_true, ↓reduceIte, Comparison.complement_evaluate, holds, Bool.not_false]

theorem below_bounded {bounds : Interval} (bounded : bounds.Bounded) (threshold : Int) :
    (bounds.below threshold).Bounded := by
  simp only [below]; split
  · exact empty_bounded
  · exact intersect_bounded_left bounded

theorem above_bounded {bounds : Interval} (bounded : bounds.Bounded) (threshold : Int) :
    (bounds.above threshold).Bounded := by
  simp only [above]; split
  · exact empty_bounded
  · exact intersect_bounded_left bounded

theorem refine_bounded {bounds : Interval} (bounded : bounds.Bounded)
    (operator : Comparison) (threshold : Int) (truth : Bool) :
    (bounds.refine operator threshold truth).Bounded := by
  unfold refine
  generalize (if truth then operator else operator.complement) = op
  cases op with
  | eq | le | ge => exact intersect_bounded_left bounded
  | ne => exact join_bounded (below_bounded bounded _) (above_bounded bounded _)
  | lt => exact below_bounded bounded _
  | gt => exact above_bounded bounded _

/-- Contradictory outcomes retain the incoming interval. This does not
prune independent path facts or hide static expression checks. -/
def refineOrKeep (bounds : Interval) (operator : Comparison) (threshold : Int)
    (truth : Bool) : Interval :=
  if (bounds.refine operator threshold truth).isEmpty then bounds
  else bounds.refine operator threshold truth

theorem refineOrKeep_sound {bounds : Interval} {operator : Comparison}
    {threshold value : Int} {truth : Bool}
    (within : bounds.Contains value) (range : InRange value)
    (holds : operator.evaluate value threshold = truth) :
    (bounds.refineOrKeep operator threshold truth).Contains value := by
  unfold refineOrKeep
  split
  · exact within
  · exact refine_sound within range holds

theorem refineOrKeep_bounded {bounds : Interval} (bounded : bounds.Bounded)
    (operator : Comparison) (threshold : Int) (truth : Bool) :
    (bounds.refineOrKeep operator threshold truth).Bounded := by
  unfold refineOrKeep
  split
  · exact bounded
  · exact refine_bounded bounded _ _ _

theorem join_contains_cases {left right : Interval} {value : Int}
    (within : (left.join right).Contains value) :
    (∃ a b, left.Contains a ∧ right.Contains b ∧ min a b ≤ value ∧ value ≤ max a b) ∨
      left.Contains value ∨ right.Contains value := by
  unfold join at within
  split at within
  · right; right
    unfold normalize at within
    split at within
    · exact False.elim (empty_contains _ within)
    · exact within
  · split at within
    · exact Or.inr (Or.inl within)
    · rename_i leftNonempty rightNonempty
      have l : left.lower ≤ left.upper := by simpa [isEmpty] using leftNonempty
      have r : right.lower ≤ right.upper := by simpa [isEmpty] using rightNonempty
      simp only [Contains] at within
      by_cases order : left.lower ≤ right.lower
      · by_cases upper : left.upper ≤ right.upper
        · exact Or.inl ⟨left.lower, right.upper, ⟨Int.le_refl _, l⟩, ⟨r, Int.le_refl _⟩,
            by omega, by omega⟩
        · exact Or.inr (Or.inl (by constructor <;> omega))
      · by_cases upper : right.upper ≤ left.upper
        · exact Or.inl ⟨left.upper, right.lower, ⟨l, Int.le_refl _⟩, ⟨Int.le_refl _, r⟩,
            by omega, by omega⟩
        · exact Or.inr (Or.inr (by constructor <;> omega))

theorem join_subset {left right target : Interval}
    (a : ∀ value, left.Contains value → target.Contains value)
    (b : ∀ value, right.Contains value → target.Contains value) :
    ∀ value, (left.join right).Contains value → target.Contains value := by
  intro value within
  rcases join_contains_cases within with ⟨x, y, hx, hy, low, high⟩ | h | h
  · have xWithin := a x hx
    have yWithin := b y hy
    simp only [Contains] at *
    constructor <;> omega
  · exact a _ h
  · exact b _ h

theorem refine_subset (bounds : Interval) (operator : Comparison) (threshold : Int)
    (truth : Bool) :
    ∀ value, (bounds.refine operator threshold truth).Contains value → bounds.Contains value := by
  unfold refine
  generalize (if truth then operator else operator.complement) = op
  have belowSubset : ∀ value, (bounds.below threshold).Contains value → bounds.Contains value := by
    intro value within
    unfold below at within
    split at within
    · exact False.elim (empty_contains _ within)
    · exact ((intersect_contains _ _ _).mp within).1
  have aboveSubset : ∀ value, (bounds.above threshold).Contains value → bounds.Contains value := by
    intro value within
    unfold above at within
    split at within
    · exact False.elim (empty_contains _ within)
    · exact ((intersect_contains _ _ _).mp within).1
  cases op with
  | eq | le | ge => exact fun _ within => ((intersect_contains _ _ _).mp within).1
  | lt => exact belowSubset
  | gt => exact aboveSubset
  | ne => exact join_subset belowSubset aboveSubset

theorem refineOrKeep_subset (bounds : Interval) (operator : Comparison) (threshold : Int)
    (truth : Bool) :
    ∀ value, (bounds.refineOrKeep operator threshold truth).Contains value → bounds.Contains value := by
  intro value within
  unfold refineOrKeep at within
  split at within
  · exact within
  · exact refine_subset _ _ _ _ value within

theorem refineOrKeep_nonempty {bounds : Interval} (nonempty : bounds.isEmpty = false)
    (operator : Comparison) (threshold : Int) (truth : Bool) :
    (bounds.refineOrKeep operator threshold truth).isEmpty = false := by
  unfold refineOrKeep
  split
  · exact nonempty
  · simpa using (by assumption : ¬(bounds.refine operator threshold truth).isEmpty = true)

theorem refineOrKeep_empty {bounds : Interval} (empty : bounds.isEmpty = true)
    (operator : Comparison) (threshold : Int) (truth : Bool) :
    bounds.refineOrKeep operator threshold truth = bounds := by
  have refinedEmpty : (bounds.refine operator threshold truth).isEmpty = true := by
    cases resultEmpty : (bounds.refine operator threshold truth).isEmpty with
    | true => rfl
    | false =>
        have low : (bounds.refine operator threshold truth).lower ≤
            (bounds.refine operator threshold truth).upper := by simpa [isEmpty] using resultEmpty
        have within := refine_subset bounds operator threshold truth _ ⟨Int.le_refl _, low⟩
        have impossible := contains_nonempty within
        simp [empty] at impossible
  simp only [refineOrKeep, refinedEmpty, ↓reduceIte]

end Interval
end Silver.Integer
