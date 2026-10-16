module

public import Silver.StringLengths
public import Silver.PathFacts

@[expose] public section

namespace Silver.Predicate
open Bindings Compose PathFacts

/-- Solve the two overlap inequalities when the left input coefficient is
larger. Natural subtraction clips a negative lower threshold to zero; the
separate upper guard preserves the impossible negative-upper case. -/
def increasingLengthOverlap (context : Context) (left right : LengthSummary) : Context :=
  let slope := left.dynamicCount - right.dynamicCount
  if right.staticLength < left.minimumLength then Context.empty
  else context.intersect
    ⟨(right.minimumLength - left.staticLength + slope - 1) / slope,
      (right.staticLength - left.minimumLength) / slope⟩

def refineLengthOverlap (context : Context) (left right : LengthSummary) : Context :=
  if left.empty || right.empty then Context.empty
  else if right.dynamicCount < left.dynamicCount then increasingLengthOverlap context left right
  else if left.dynamicCount < right.dynamicCount then increasingLengthOverlap context right left
  else if left.minimumLength ≤ right.staticLength ∧ right.minimumLength ≤ left.staticLength
    then context else Context.empty

theorem increasingLengthOverlap_sound {context : Context} {left right : LengthSummary}
    {inputLength length : Nat} {valid rejected : Bool}
    (allowed : context.Allows valid inputLength rejected)
    (slope : right.dynamicCount < left.dynamicCount)
    (a : left.Contains inputLength length) (b : right.Contains inputLength length) :
    (increasingLengthOverlap context left right).Allows valid inputLength rejected := by
  have positive : 0 < left.dynamicCount - right.dynamicCount := by omega
  have products : (left.dynamicCount - right.dynamicCount) * inputLength +
      right.dynamicCount * inputLength = left.dynamicCount * inputLength := by
    rw [Nat.sub_mul]
    have order := Nat.mul_le_mul_right inputLength (Nat.le_of_lt slope)
    omega
  have low : right.minimumLength - left.staticLength ≤
      inputLength * (left.dynamicCount - right.dynamicCount) := by
    simp only [LengthSummary.Contains, LengthSummary.lower, LengthSummary.upper, Summary.length] at a b
    rw [Nat.mul_comm]
    omega
  have high : inputLength * (left.dynamicCount - right.dynamicCount) ≤
      right.staticLength - left.minimumLength := by
    simp only [LengthSummary.Contains, LengthSummary.lower, LengthSummary.upper, Summary.length] at a b
    rw [Nat.mul_comm]
    omega
  have upperPossible : ¬ right.staticLength < left.minimumLength := by
    simp only [LengthSummary.Contains, LengthSummary.lower, LengthSummary.upper, Summary.length] at a b
    omega
  simp only [increasingLengthOverlap, upperPossible, ↓reduceIte]
  apply (Context.intersect_iff _ _ _ _ _).mpr
  refine ⟨allowed, ?_, ?_⟩
  · apply (Nat.div_le_iff_le_mul positive).mpr
    omega
  · exact (Nat.le_div_iff_mul_le positive).mpr high

theorem refineLengthOverlap_sound {context : Context} {left right : LengthSummary}
    {inputLength length : Nat} {valid rejected : Bool}
    (allowed : context.Allows valid inputLength rejected)
    (a : left.Contains inputLength length) (b : right.Contains inputLength length) :
    (refineLengthOverlap context left right).Allows valid inputLength rejected := by
  simp only [refineLengthOverlap, a.1, b.1, Bool.false_or, Bool.false_eq_true, ↓reduceIte]
  split
  · exact increasingLengthOverlap_sound allowed ‹_› a b
  · split
    · exact increasingLengthOverlap_sound allowed ‹_› b a
    · have coefficients : left.dynamicCount = right.dynamicCount := by omega
      have compatible : left.minimumLength ≤ right.staticLength ∧ right.minimumLength ≤ left.staticLength := by
        simp only [LengthSummary.Contains, LengthSummary.lower, LengthSummary.upper, Summary.length] at a b
        rw [coefficients] at a
        omega
      simpa [compatible] using allowed

theorem string_image_equality_overlap {context : Context} {left right : Expression}
    {shape : Shape} {ranges : Integer.Ranges} {leftSummary rightSummary : LengthSummary}
    {values : Values} {integers : Integer.Store} {input : Source} {valid rejected : Bool}
    (leftKnown : left.inferLength shape ranges = some leftSummary)
    (rightKnown : right.inferLength shape ranges = some rightSummary)
    (strings : Fits shape input values) (scalars : Integer.Fits ranges integers)
    (allowed : context.Allows valid input.length rejected)
    (equal : left.evaluate values input integers = right.evaluate values input integers) :
    (refineLengthOverlap context leftSummary rightSummary).Allows valid input.length rejected := by
  have leftLength := (Expression.inferLength_sound leftKnown strings scalars).1
  have rightLength := (Expression.inferLength_sound rightKnown strings scalars).1
  rw [equal] at leftLength
  exact refineLengthOverlap_sound allowed leftLength rightLength

end Silver.Predicate
