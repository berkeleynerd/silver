module

public import Silver.PathBounds

@[expose] public section

/-! Scalar representations used by the native path library. These definitions
retain inactive fields; projection erases them only when their reachability
flag is false. -/
namespace Silver.PathFacts.Native
open Bindings Predicate

structure Context where
  lower : Nat
  upper : Nat
  validReachable : Bool
  invalidReachable : Bool
  invalidRejected : Bool
  deriving DecidableEq, Repr

structure Bound where
  staticLength : Nat
  dynamic : Bool
  deriving DecidableEq, Repr

abbrev Summary := Bindings.Summary

def Context.model (value : Context) : PathFacts.Context :=
  ⟨if value.validReachable then some ⟨value.lower, value.upper⟩ else none,
    value.invalidReachable, value.invalidRejected⟩
def Bound.model (value : Bound) : Bindings.Bound :=
  if value.dynamic then .argument else .fixed value.staticLength

def empty : Context := ⟨0, 0, false, false, true⟩
def initial (arguments : Bool) : Context := ⟨0, if arguments then maxSourceLength else 0, true, arguments, false⟩
def ceiling (facts : Context) : Nat := if facts.validReachable then facts.upper else 0
def assumeValid (facts : Context) : Context := {facts with invalidReachable := false}
def assumeInvalid (facts : Context) : Context := {facts with lower := 0, upper := 0, validReachable := false}
def rejected (facts : Context) : Context := {facts with invalidRejected := true}
def completed (facts : Context) : Bool := !facts.invalidReachable || facts.invalidRejected
def keepIf (facts : Context) (condition : Bool) : Context := if condition then facts else empty

def intersect (facts : Context) (lower upper : Nat) : Context :=
  let low := max facts.lower lower
  let high := min facts.upper upper
  let valid := facts.validReachable && decide (low ≤ high)
  ⟨if valid then low else 0, if valid then high else 0, valid,
    facts.invalidReachable && decide (lower = 0), facts.invalidRejected⟩

def join (left right : Context) : Context :=
  ⟨if !left.validReachable then right.lower else if !right.validReachable then left.lower
      else min left.lower right.lower,
    if !left.validReachable then right.upper else if !right.validReachable then left.upper
      else max left.upper right.upper,
    left.validReachable || right.validReachable,
    left.invalidReachable || right.invalidReachable,
    (!left.invalidReachable || left.invalidRejected) &&
      (!right.invalidReachable || right.invalidRejected)⟩

def below (facts : Context) (threshold : Nat) : Context :=
  if threshold = 0 then empty else intersect facts 0 (threshold - 1)
def above (facts : Context) (threshold : Nat) : Context := intersect facts (threshold + 1) (ceiling facts)
def refineInputTrue (facts : Context) (operator : Comparison) (threshold : Nat) : Context :=
  match operator with
  | .eq => intersect facts threshold threshold
  | .ne => join (below facts threshold) (above facts threshold)
  | .lt => below facts threshold
  | .le => intersect facts 0 threshold
  | .gt => above facts threshold
  | .ge => intersect facts threshold (ceiling facts)
def refineInput (facts : Context) (operator : Comparison) (threshold : Nat) (truth : Bool) : Context :=
  refineInputTrue facts (if truth then operator else operator.complement) threshold

def refineBounds (facts : Context) (operator : Comparison) (left right : Bound) (truth : Bool) : Context :=
  if left.dynamic && right.dynamic then keepIf facts (operator.evaluate 0 0 == truth)
  else if left.dynamic then refineInput facts operator right.staticLength truth
  else if right.dynamic then refineInput facts operator.swap left.staticLength truth
  else keepIf facts (operator.evaluate left.staticLength right.staticLength == truth)

def lengthAt (value : Summary) (inputLength : Nat) : Nat := value.staticLength + value.dynamicCount * inputLength
def fits (facts : Context) (value : Summary) : Bool :=
  (!facts.validReachable || decide (lengthAt value facts.upper ≤ maxSourceLength)) &&
    (!facts.invalidReachable || decide (lengthAt value 0 ≤ maxSourceLength))
def sameLength (facts : Context) (left right : Summary) : Bool :=
  (!facts.validReachable || ((lengthAt left facts.lower == lengthAt right facts.lower) &&
      (lengthAt left facts.upper == lengthAt right facts.upper))) &&
    (!facts.invalidReachable || (lengthAt left 0 == lengthAt right 0))
def equalIncreasing (facts : Context) (left right : Summary) : Context :=
  let numerator := if right.staticLength ≥ left.staticLength then right.staticLength - left.staticLength else 0
  let candidate := numerator / (left.dynamicCount - right.dynamicCount)
  keepIf (intersect facts candidate candidate) (lengthAt left candidate == lengthAt right candidate)
def refineEqual (facts : Context) (left right : Summary) : Context :=
  if left.dynamicCount = right.dynamicCount then keepIf facts (left.staticLength == right.staticLength)
  else if left.dynamicCount > right.dynamicCount then equalIncreasing facts left right
  else equalIncreasing facts right left

@[simp] theorem empty_model : empty.model = PathFacts.Context.empty := rfl
@[simp] theorem initial_model (arguments : Bool) : (initial arguments).model =
    if arguments then PathFacts.Context.initial maxSourceLength else (PathFacts.Context.initial 0).assumeValid := by
  cases arguments <;> rfl
@[simp] theorem ceiling_model (facts : Context) : ceiling facts = Predicate.ceiling facts.model := by
  cases h : facts.validReachable <;> simp [ceiling, Context.model, Predicate.ceiling, h]
@[simp] theorem assumeValid_model (facts : Context) : (assumeValid facts).model = facts.model.assumeValid := rfl
@[simp] theorem assumeInvalid_model (facts : Context) : (assumeInvalid facts).model = facts.model.assumeInvalid := rfl
@[simp] theorem rejected_model (facts : Context) : (rejected facts).model = facts.model.reject := rfl
@[simp] theorem completed_model (facts : Context) : completed facts = (!facts.model.invalidReachable || facts.model.invalidRejected) := rfl
@[simp] theorem keepIf_model (facts : Context) (condition : Bool) :
    (keepIf facts condition).model = Predicate.keepIf facts.model condition := by
  cases condition <;> rfl

@[simp] theorem intersect_model (facts : Context) (lower upper : Nat) :
    (intersect facts lower upper).model = facts.model.intersect ⟨lower, upper⟩ := by
  cases reachable : facts.validReachable <;>
    simp [intersect, Context.model, PathFacts.Context.intersect, Region.intersect,
      Interval.intersect, Interval.Contains, reachable]
  split <;> simp_all

@[simp] theorem join_model (left right : Context) : (join left right).model = left.model.join right.model := by
  cases a : left.validReachable <;> cases b : right.validReachable <;>
    simp [join, Context.model, PathFacts.Context.join, Region.join, Interval.hull, a, b]

@[simp] theorem below_model (facts : Context) (threshold : Nat) :
    (below facts threshold).model = Predicate.below facts.model threshold := by
  unfold below Predicate.below
  split <;> simp
@[simp] theorem above_model (facts : Context) (threshold : Nat) :
    (above facts threshold).model = Predicate.above facts.model threshold := by
  simp [above, Predicate.above]
@[simp] theorem refineInputTrue_model (facts : Context) (operator : Comparison) (threshold : Nat) :
    (refineInputTrue facts operator threshold).model = Predicate.refineInputTrue facts.model operator threshold := by
  cases operator <;> simp [refineInputTrue, Predicate.refineInputTrue]
@[simp] theorem refineInput_model (facts : Context) (operator : Comparison) (threshold : Nat) (truth : Bool) :
    (refineInput facts operator threshold truth).model = Predicate.refineInput facts.model operator threshold truth := by
  simp [refineInput, Predicate.refineInput]
@[simp] theorem refineBounds_model (facts : Context) (operator : Comparison) (left right : Bound) (truth : Bool) :
    (refineBounds facts operator left right truth).model = Predicate.refineBounds facts.model operator left.model right.model truth := by
  cases a : left.dynamic <;> cases b : right.dynamic <;>
    simp [refineBounds, Predicate.refineBounds, Bound.model, a, b]
@[simp] theorem lengthAt_model (value : Summary) (inputLength : Nat) : lengthAt value inputLength = value.length inputLength := rfl
@[simp] theorem fits_model (facts : Context) (value : Summary) : fits facts value = Predicate.fitsSummary facts.model value := by
  cases a : facts.validReachable <;> simp [fits, Predicate.fitsSummary, Context.model, a] <;> rfl
@[simp] theorem equalIncreasing_model (facts : Context) (left right : Summary) :
    (equalIncreasing facts left right).model = Predicate.equalIncreasing facts.model left right := by
  have subtraction : (if right.staticLength ≥ left.staticLength then right.staticLength - left.staticLength else 0) = right.staticLength - left.staticLength := by split <;> omega
  simp only [equalIncreasing, subtraction, keepIf_model, intersect_model, lengthAt_model, Predicate.equalIncreasing]
  rfl
@[simp] theorem refineEqual_model (facts : Context) (left right : Summary) :
    (refineEqual facts left right).model = Predicate.refineAffineEqual facts.model left right := by
  unfold refineEqual Predicate.refineAffineEqual
  split
  · simp; rfl
  · split <;> simp

theorem sameLength_sound {facts : Context} {left right : Summary} {valid rejected : Bool} {length : Nat}
    (allowed : facts.model.Allows valid length rejected) (equal : sameLength facts left right = true) :
    left.length length = right.length length := by
  cases valid with
  | false =>
      have zero := allowed.1
      have reachable := allowed.2.1
      simp only [Context.model] at reachable
      simp [sameLength, reachable, lengthAt_model] at equal
      simpa only [zero] using equal.2
  | true =>
      cases reachable : facts.validReachable with
      | false => simp [PathFacts.Context.Allows, Context.model, reachable, Region.Contains] at allowed
      | true =>
          have within : facts.lower ≤ length ∧ length ≤ facts.upper := by
            simpa [PathFacts.Context.Allows, Context.model, reachable, Region.Contains, Interval.Contains] using allowed
          simp [sameLength, reachable, lengthAt_model] at equal
          exact affine_equal_between equal.1.1 equal.1.2 within

end Silver.PathFacts.Native
