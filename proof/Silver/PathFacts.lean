module

public import Silver.Bindings

@[expose] public section

/-! Draft mathematical facts for conditional paths. Valid-input lengths and
invalid-input rejection are separate; all lengths refer to the immutable input.
No current mutable String bytes are tracked. -/

namespace Silver.PathFacts
open Bindings

structure Interval where
  lower : Nat
  upper : Nat
  deriving DecidableEq, Repr

def Interval.Contains (interval : Interval) (length : Nat) : Prop :=
  interval.lower ≤ length ∧ length ≤ interval.upper

instance (interval : Interval) (length : Nat) : Decidable (interval.Contains length) :=
  inferInstanceAs (Decidable (_ ∧ _))

abbrev Region := Option Interval

def Region.Contains (region : Region) (length : Nat) : Prop :=
  match region with
  | none => False
  | some interval => interval.Contains length

instance (region : Region) (length : Nat) : Decidable (region.Contains length) := by
  cases region <;> unfold Region.Contains <;> infer_instance

def Interval.intersect (left right : Interval) : Region :=
  let lower := max left.lower right.lower
  let upper := min left.upper right.upper
  if lower ≤ upper then some ⟨lower, upper⟩ else none

def Interval.hull (left right : Interval) : Interval :=
  ⟨min left.lower right.lower, max left.upper right.upper⟩

theorem Interval.intersect_iff (left right : Interval) (length : Nat) :
    (left.intersect right).Contains length ↔ left.Contains length ∧ right.Contains length := by
  by_cases overlap : max left.lower right.lower ≤ min left.upper right.upper
  · simp only [intersect, overlap, ↓reduceIte, Region.Contains, Contains]
    omega
  · simp only [intersect, overlap, ↓reduceIte, Region.Contains, Contains]
    constructor
    · intro impossible
      exact False.elim impossible
    · rintro ⟨⟨leftLow, leftHigh⟩, ⟨rightLow, rightHigh⟩⟩
      apply overlap
      omega

theorem Interval.hull_left {left right : Interval} {length : Nat}
    (within : left.Contains length) : (left.hull right).Contains length := by
  simp only [Contains, hull] at *
  omega

theorem Interval.hull_right {left right : Interval} {length : Nat}
    (within : right.Contains length) : (left.hull right).Contains length := by
  simp only [Contains, hull] at *
  omega

def Region.intersect (region : Region) (interval : Interval) : Region :=
  region.bind (·.intersect interval)

def Region.join (left right : Region) : Region :=
  match left, right with
  | none, other | other, none => other
  | some left, some right => some (left.hull right)

theorem Region.intersect_iff (region : Region) (interval : Interval) (length : Nat) :
    (region.intersect interval).Contains length ↔ region.Contains length ∧ interval.Contains length := by
  cases region with
  | none => simp [intersect, Contains]
  | some before => simpa [intersect, Contains] using before.intersect_iff interval length

theorem Region.join_left {left right : Region} {length : Nat}
    (within : left.Contains length) : (left.join right).Contains length := by
  cases left with
  | none => exact False.elim within
  | some left =>
      cases right with
      | none => exact within
      | some right => exact Interval.hull_left within

theorem Region.join_right {left right : Region} {length : Nat}
    (within : right.Contains length) : (left.join right).Contains length := by
  cases right with
  | none => exact False.elim within
  | some right =>
      cases left with
      | none => exact within
      | some left => exact Interval.hull_right within

structure Context where
  validLengths : Region
  invalidReachable : Bool
  invalidRejected : Bool
  deriving DecidableEq, Repr

/-- The final flag means rejection has already occurred, not that execution ends. -/
def Context.Allows (context : Context) (validInput : Bool) (length : Nat)
    (rejected : Bool) : Prop :=
  if validInput then context.validLengths.Contains length
  else length = 0 ∧ context.invalidReachable = true ∧
    (context.invalidRejected = true → rejected = true)

def Context.initial (capacity : Nat) : Context := ⟨some ⟨0, capacity⟩, true, false⟩

def Context.empty : Context := ⟨none, false, true⟩

def Context.intersect (context : Context) (interval : Interval) : Context :=
  {context with
    validLengths := context.validLengths.intersect interval
    invalidReachable := context.invalidReachable && decide (interval.Contains 0)}

def Context.join (left right : Context) : Context :=
  ⟨left.validLengths.join right.validLengths,
    left.invalidReachable || right.invalidReachable,
    (!left.invalidReachable || left.invalidRejected) &&
      (!right.invalidReachable || right.invalidRejected)⟩

def Context.reject (context : Context) : Context :=
  {context with invalidRejected := true}

def Context.assumeValid (context : Context) : Context :=
  {context with invalidReachable := false}

def Context.assumeInvalid (context : Context) : Context :=
  {context with validLengths := none}

theorem Context.initial_valid {capacity length : Nat} (bound : length ≤ capacity)
    (rejected : Bool) : (initial capacity).Allows true length rejected :=
  ⟨Nat.zero_le _, bound⟩

theorem Context.initial_invalid (capacity : Nat) (rejected : Bool) :
    (initial capacity).Allows false 0 rejected := by
  simp [initial, Allows]

theorem Context.assumeValid_iff (context : Context) (validInput : Bool) (length : Nat)
    (rejected : Bool) : context.assumeValid.Allows validInput length rejected ↔
      context.Allows validInput length rejected ∧ validInput = true := by
  cases validInput <;> simp [Allows, assumeValid]

theorem Context.assumeInvalid_iff (context : Context) (validInput : Bool) (length : Nat)
    (rejected : Bool) : context.assumeInvalid.Allows validInput length rejected ↔
      context.Allows validInput length rejected ∧ validInput = false := by
  cases validInput <;> simp [Allows, assumeInvalid, Region.Contains]

theorem Context.empty_unreachable (validInput : Bool) (length : Nat) (rejected : Bool) :
    ¬ empty.Allows validInput length rejected := by
  cases validInput <;> simp [Allows, empty, Region.Contains]

theorem Context.intersect_iff (context : Context) (interval : Interval)
    (validInput : Bool) (length : Nat) (rejected : Bool) :
    (context.intersect interval).Allows validInput length rejected ↔
      context.Allows validInput length rejected ∧ interval.Contains length := by
  cases validInput with
  | true => exact Region.intersect_iff context.validLengths interval length
  | false =>
      simp only [Allows, Bool.false_eq_true, ↓reduceIte, intersect, Bool.and_eq_true, decide_eq_true_eq]
      constructor
      · rintro ⟨rfl, ⟨reachable, within⟩, rejected⟩
        exact ⟨⟨rfl, reachable, rejected⟩, within⟩
      · rintro ⟨⟨rfl, reachable, rejected⟩, within⟩
        exact ⟨rfl, ⟨reachable, within⟩, rejected⟩

theorem Context.join_left {left right : Context} {validInput : Bool} {length : Nat}
    {rejected : Bool} (before : left.Allows validInput length rejected) :
    (left.join right).Allows validInput length rejected := by
  cases validInput with
  | true => exact Region.join_left before
  | false =>
      rcases before with ⟨zero, reachable, failed⟩
      refine ⟨zero, ?_, ?_⟩
      · simp [join, reachable]
      · intro guaranteed
        apply failed
        simp only [join, reachable, Bool.not_true, Bool.false_or, Bool.and_eq_true] at guaranteed
        exact guaranteed.1

theorem Context.join_right {left right : Context} {validInput : Bool} {length : Nat}
    {rejected : Bool} (before : right.Allows validInput length rejected) :
    (left.join right).Allows validInput length rejected := by
  cases validInput with
  | true => exact Region.join_right before
  | false =>
      rcases before with ⟨zero, reachable, failed⟩
      refine ⟨zero, ?_, ?_⟩
      · simp [join, reachable]
      · intro guaranteed
        apply failed
        simp only [join, reachable, Bool.not_true, Bool.false_or, Bool.and_eq_true] at guaranteed
        exact guaranteed.2

theorem Context.reject_sound {context : Context} {validInput : Bool} {length : Nat}
    {rejected : Bool} (before : context.Allows validInput length rejected) :
    context.reject.Allows validInput length true := by
  cases validInput with
  | true => exact before
  | false => exact ⟨before.1, before.2.1, fun _ => rfl⟩

theorem Context.invalid_rejection_required {context : Context} {length : Nat} {rejected : Bool}
    (before : context.Allows false length rejected) (guaranteed : context.invalidRejected = true) :
    rejected = true := before.2.2 guaranteed

theorem Context.reject_preserves_reachability (context : Context) :
    context.reject.invalidReachable = context.invalidReachable := rfl

theorem Context.output_requires_valid_input {context : Context} {validInput : Bool}
    {length : Nat} {rejected : Bool} (known : context.Allows validInput length rejected)
    (safe : context.invalidReachable = false) : validInput = true := by
  cases validInput with
  | true => rfl
  | false => simp [Allows, safe] at known

/-- A store write cannot change facts indexed only by unchanged input properties. -/
theorem Context.immutable_input {context : Context} {validInput : Bool} {before after : Nat}
    {rejected : Bool} (same : after = before) (known : context.Allows validInput before rejected) :
    context.Allows validInput after rejected := by
  simpa only [same] using known

theorem affine_monotone (summary : Summary) {before after : Nat} (order : before ≤ after) :
    summary.length before ≤ summary.length after :=
  Nat.add_le_add_left (Nat.mul_le_mul_left summary.dynamicCount order) summary.staticLength

def Interval.Fits (interval : Interval) (summary : Summary) (capacity : Nat) : Prop :=
  summary.length interval.upper ≤ capacity

theorem Interval.fits_sound {interval : Interval} {summary : Summary} {capacity length : Nat}
    (fits : interval.Fits summary capacity) (within : interval.Contains length) :
    summary.length length ≤ capacity :=
  Nat.le_trans (affine_monotone summary within.2) fits

theorem Interval.fits_iff (interval : Interval) (summary : Summary) (capacity : Nat)
    (nonempty : interval.lower ≤ interval.upper) : interval.Fits summary capacity ↔
      ∀ length, interval.Contains length → summary.length length ≤ capacity := by
  constructor
  · intro fits length within
    exact fits_sound fits within
  · intro all
    exact all interval.upper ⟨nonempty, Nat.le_refl _⟩

/-- Equality at both endpoints is enough for every affine length in between. -/
theorem affine_equal_between {left right : Summary} {lower upper length : Nat}
    (low : left.length lower = right.length lower)
    (high : left.length upper = right.length upper)
    (within : lower ≤ length ∧ length ≤ upper) : left.length length = right.length length := by
  by_cases point : lower = upper
  · have same : length = lower := by omega
    simpa only [same] using low
  · have positive : 0 < upper - lower := by omega
    have split : upper = lower + (upper - lower) := by omega
    have expanded := high
    dsimp only [Summary.length] at expanded
    rw [split, Nat.mul_add, Nat.mul_add] at expanded
    simp only [← Nat.add_assoc] at expanded
    have lowExpanded : left.staticLength + left.dynamicCount * lower =
        right.staticLength + right.dynamicCount * lower := low
    rw [lowExpanded] at expanded
    have slopes : left.dynamicCount * (upper - lower) = right.dynamicCount * (upper - lower) :=
      Nat.add_left_cancel expanded
    have slope : left.dynamicCount = right.dynamicCount := Nat.eq_of_mul_eq_mul_right positive slopes
    simp only [Summary.length, slope] at low ⊢
    have constant : left.staticLength = right.staticLength := Nat.add_right_cancel low
    rw [constant]

def Interval.Equal (interval : Interval) (left right : Summary) : Prop :=
  left.length interval.lower = right.length interval.lower ∧
    left.length interval.upper = right.length interval.upper

theorem Interval.equal_sound {interval : Interval} {left right : Summary} {length : Nat}
    (equal : interval.Equal left right) (within : interval.Contains length) :
    left.length length = right.length length :=
  affine_equal_between equal.1 equal.2 within

theorem Interval.equal_iff (interval : Interval) (left right : Summary)
    (nonempty : interval.lower ≤ interval.upper) : interval.Equal left right ↔
      ∀ length, interval.Contains length → left.length length = right.length length := by
  constructor
  · intro equal length within
    exact equal_sound equal within
  · intro all
    exact ⟨all interval.lower ⟨Nat.le_refl _, nonempty⟩,
      all interval.upper ⟨nonempty, Nat.le_refl _⟩⟩

end Silver.PathFacts
