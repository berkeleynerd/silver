module

public import Silver.PredicateStatements
public import Silver.PathNativeEquations

@[expose] public section

namespace Silver.Predicate
open Compose Bindings

/-- The native helper accepts two interval records. Assignment specializes its
right operand to the exact, nonempty target bound. -/
def equalLengthIntervals (facts : PathFacts.Context) (left right : LengthSummary) : Bool :=
  if left.empty || right.empty then
    decide (right.dynamicCount ≠ 0 ∨ left.minimumLength ≤ right.staticLength)
  else equalSummary facts left.lower right.upper && equalSummary facts left.upper right.lower

@[simp] theorem equalLengthIntervals_exact (facts : PathFacts.Context)
    (left : LengthSummary) (right : Summary) :
    equalLengthIntervals facts left (.ofExact right) = equalLengthSummary facts left right := by
  simp only [equalLengthIntervals, equalLengthSummary, LengthSummary.ofExact,
    Bool.or_false, LengthSummary.lower, LengthSummary.upper]
  rfl

end Silver.Predicate

namespace Silver.LengthIntervals.Native
open Compose Bindings Predicate
abbrev Paths := PathFacts.Native.Context

def fits (facts : Paths) (value : LengthSummary) : Bool :=
  decide (value.staticLength ≤ maxSourceLength) &&
    (value.empty || PathFacts.Native.fits facts value.upper)

def sameLength (facts : Paths) (left right : LengthSummary) : Bool :=
  if left.empty || right.empty then
    decide (right.dynamicCount ≠ 0) || decide (left.minimumLength ≤ right.staticLength)
  else PathFacts.Native.sameLength facts left.lower right.upper &&
    PathFacts.Native.sameLength facts left.upper right.lower

def equalIncreasing (facts : Paths) (left right : LengthSummary) : Paths :=
  if right.staticLength < left.minimumLength then PathFacts.Native.empty else
    let difference := left.dynamicCount - right.dynamicCount
    let numerator := if right.minimumLength > left.staticLength
      then right.minimumLength - left.staticLength else 0
    PathFacts.Native.intersect facts ((numerator + difference - 1) / difference)
      ((right.staticLength - left.minimumLength) / difference)

def refineEqual (facts : Paths) (left right : LengthSummary) : Paths :=
  if left.empty || right.empty then PathFacts.Native.empty
  else if left.dynamicCount = right.dynamicCount then
    PathFacts.Native.keepIf facts (decide (left.minimumLength ≤ right.staticLength) &&
      decide (right.minimumLength ≤ left.staticLength))
  else if left.dynamicCount > right.dynamicCount then equalIncreasing facts left right
  else equalIncreasing facts right left

@[simp] theorem fits_model (facts : Paths) (value : LengthSummary) :
    fits facts value = fitsLengthSummary facts.model value := by
  simp only [fits, fitsLengthSummary, PathFacts.Native.fits_model]

theorem affine_sameLength_model (facts : Paths) (left right : Summary) :
    PathFacts.Native.sameLength facts left right = equalSummary facts.model left right := by
  cases reachable : facts.validReachable <;>
    simp [PathFacts.Native.sameLength, PathFacts.Native.Context.model, equalSummary, reachable,
      PathFacts.Native.lengthAt_model, Bool.beq_eq_decide_eq]

@[simp] theorem sameLength_model (facts : Paths) (left right : LengthSummary) :
    sameLength facts left right = equalLengthIntervals facts.model left right := by
  simp only [sameLength, equalLengthIntervals, affine_sameLength_model, Bool.decide_or]

@[simp] theorem equalIncreasing_model (facts : Paths) (left right : LengthSummary) :
    (equalIncreasing facts left right).model = increasingLengthOverlap facts.model left right := by
  have numerator : (if right.minimumLength > left.staticLength
      then right.minimumLength - left.staticLength else 0) =
      right.minimumLength - left.staticLength := by split <;> omega
  simp only [equalIncreasing, increasingLengthOverlap, numerator]
  split <;> simp only [PathFacts.Native.empty_model, PathFacts.Native.intersect_model]

@[simp] theorem refineEqual_model (facts : Paths) (left right : LengthSummary) :
    (refineEqual facts left right).model = refineLengthOverlap facts.model left right := by
  unfold refineEqual refineLengthOverlap
  split
  · exact PathFacts.Native.empty_model
  · split
    · rename_i same
      have a : ¬right.dynamicCount < left.dynamicCount := by omega
      have b : ¬left.dynamicCount < right.dynamicCount := by omega
      simp only [a, b, ↓reduceIte, PathFacts.Native.keepIf_model,
        keepIf, Bool.and_eq_true, decide_eq_true_eq]
    · rename_i different
      by_cases order : right.dynamicCount < left.dynamicCount
      · simp only [order, ↓reduceIte, equalIncreasing_model]
      · have reverse : left.dynamicCount < right.dynamicCount := by omega
        simp only [order, reverse, ↓reduceIte, equalIncreasing_model]

end Silver.LengthIntervals.Native
