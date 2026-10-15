module

public import Silver.IntegerIntervals

@[expose] public section

/-! Signed arithmetic with explicit grouping and intermediate overflow checks.
The literal constructor carries the signed value decoded by the source reader;
the exceptional negative minimum spelling is resolved there before this typed
tree. A separate negative node applies Integer's unary operator to an already
typed operand, and therefore rejects negation of Integer'First. -/

namespace Silver.Integer

abbrev Ranges := Nat → Option Interval
abbrev Store := Nat → Int

def Fits (ranges : Ranges) (values : Store) : Prop :=
  ∀ index bounds, ranges index = some bounds → bounds.Contains (values index)

def emptyRanges : Ranges := fun _ => none
def emptyStore : Store := fun _ => 0

theorem empty_fits (values : Store) : Fits emptyRanges values := by
  intro index bounds found; cases found

def put {α : Type} (values : Nat → α) (index : Nat) (value : α) : Nat → α :=
  fun other => if other = index then value else values other

theorem put_fits {ranges : Ranges} {values : Store} {index : Nat} {bounds : Interval} {value : Int}
    (fits : Fits ranges values) (within : bounds.Contains value) :
    Fits (put ranges index (some bounds)) (put values index value) := by
  intro other interval found
  by_cases same : other = index
  · subst other
    simp only [put, ↓reduceIte, Option.some.injEq] at found
    subst interval
    simpa only [put, ↓reduceIte] using within
  · simp only [put, same, ↓reduceIte] at found ⊢
    exact fits other interval found

inductive Expr
  | literal (value : Int)
  | name (index : Nat)
  | positive (value : Expr)
  | negative (value : Expr)
  | parenthesized (value : Expr)
  | add (left right : Expr)
  | subtract (left right : Expr)
  | multiply (left right : Expr)
  deriving DecidableEq, Repr

def Expr.evaluate (values : Store) : Expr → Int
  | .literal value => value
  | .name index => values index
  | .positive value | .parenthesized value => value.evaluate values
  | .negative value => -value.evaluate values
  | .add left right => left.evaluate values + right.evaluate values
  | .subtract left right => left.evaluate values - right.evaluate values
  | .multiply left right => left.evaluate values * right.evaluate values

def accepted (result : CheckResult) : Option Interval :=
  if result.safe then some result.bounds else none

theorem accepted_iff (result : CheckResult) (bounds : Interval) :
    accepted result = some bounds ↔ result.safe = true ∧ result.bounds = bounds := by
  simp only [accepted]
  cases result.safe <;> simp

def Expr.infer (ranges : Ranges) : Expr → Option Interval
  | .literal value => accepted (checked (Interval.singleton value))
  | .name index => (ranges index).bind fun bounds => accepted (checked bounds)
  | .positive value | .parenthesized value => value.infer ranges
  | .negative value => (value.infer ranges).bind fun bounds => accepted (checkedNegate bounds)
  | .add left right => (left.infer ranges).bind fun a =>
      (right.infer ranges).bind fun b => accepted (checkedAdd a b)
  | .subtract left right => (left.infer ranges).bind fun a =>
      (right.infer ranges).bind fun b => accepted (checkedSubtract a b)
  | .multiply left right => (left.infer ranges).bind fun a =>
      (right.infer ranges).bind fun b => accepted (checkedMultiply a b)

/-- Every node, including operands of a larger safe result, must fit Integer. -/
def Expr.Safe (values : Store) : Expr → Prop
  | .literal value => InRange value
  | .name index => InRange (values index)
  | .positive value | .parenthesized value => value.Safe values
  | .negative value => value.Safe values ∧ InRange (-value.evaluate values)
  | .add left right => left.Safe values ∧ right.Safe values ∧
      InRange (left.evaluate values + right.evaluate values)
  | .subtract left right => left.Safe values ∧ right.Safe values ∧
      InRange (left.evaluate values - right.evaluate values)
  | .multiply left right => left.Safe values ∧ right.Safe values ∧
      InRange (left.evaluate values * right.evaluate values)

theorem Expr.safe_value {values : Store} {expression : Expr}
    (safe : expression.Safe values) : InRange (expression.evaluate values) := by
  induction expression with
  | literal | name => exact safe
  | positive _ ih | parenthesized _ ih => exact ih safe
  | negative => exact safe.2
  | add | subtract | multiply => exact safe.2.2

theorem Expr.infer_bounded {ranges : Ranges} {expression : Expr} {bounds : Interval}
    (found : expression.infer ranges = some bounds) : bounds.Bounded := by
  induction expression generalizing bounds with
  | literal value =>
      have accepted := (accepted_iff _ _).mp found
      rw [← accepted.2]; exact checked_bounded _
  | name index =>
      simp only [infer, Option.bind_eq_some_iff] at found
      obtain ⟨interval, _, accepted⟩ := found
      rw [← ((accepted_iff _ _).mp accepted).2]; exact checked_bounded _
  | positive _ ih | parenthesized _ ih => exact ih found
  | negative value _ =>
      simp only [infer, Option.bind_eq_some_iff] at found
      obtain ⟨interval, _, accepted⟩ := found
      rw [← ((accepted_iff _ _).mp accepted).2]; exact checkedNegate_bounded _
  | add left right _ _ | subtract left right _ _ | multiply left right _ _ =>
      simp only [infer, Option.bind_eq_some_iff] at found
      obtain ⟨a, _, b, _, accepted⟩ := found
      rw [← ((accepted_iff _ _).mp accepted).2]
      first | exact checkedAdd_bounded _ _ | exact checkedSubtract_bounded _ _ | exact checkedMultiply_bounded _ _

theorem Expr.infer_sound {ranges : Ranges} {expression : Expr} {bounds : Interval} {values : Store}
    (found : expression.infer ranges = some bounds) (fits : Fits ranges values) :
    bounds.Contains (expression.evaluate values) ∧ expression.Safe values := by
  induction expression generalizing bounds with
  | literal value =>
      have result := (accepted_iff _ _).mp found
      have sound := checked_sound result.1 ((Interval.singleton_contains value value).mpr rfl)
      simpa only [result.2, evaluate, Safe] using sound
  | name index =>
      simp only [infer, Option.bind_eq_some_iff] at found
      obtain ⟨interval, present, accepted⟩ := found
      have result := (accepted_iff _ _).mp accepted
      have sound := checked_sound result.1 (fits index interval present)
      simpa only [result.2, evaluate, Safe] using sound
  | positive value ih | parenthesized value ih => exact ih found
  | negative value ih =>
      simp only [infer, Option.bind_eq_some_iff] at found
      obtain ⟨interval, child, accepted⟩ := found
      have result := (accepted_iff _ _).mp accepted
      have childSound := ih child
      have sound := checkedNegate_sound result.1 childSound.1
      exact ⟨by simpa only [result.2, evaluate] using sound.1, childSound.2, sound.2⟩
  | add left right ihl ihr | subtract left right ihl ihr | multiply left right ihl ihr =>
      simp only [infer, Option.bind_eq_some_iff] at found
      obtain ⟨a, leftFound, b, rightFound, accepted⟩ := found
      have result := (accepted_iff _ _).mp accepted
      have l := ihl leftFound
      have r := ihr rightFound
      first
      | have sound := checkedAdd_sound result.1 l.1 r.1
        exact ⟨by simpa only [result.2, evaluate] using sound.1, l.2, r.2, sound.2⟩
      | have sound := checkedSubtract_sound result.1 l.1 r.1
        exact ⟨by simpa only [result.2, evaluate] using sound.1, l.2, r.2, sound.2⟩
      | have sound := checkedMultiply_sound result.1 l.1 r.1
        exact ⟨by simpa only [result.2, evaluate] using sound.1, l.2, r.2, sound.2⟩

def checkedValue (value : Int) : Option Int := if InRange value then some value else none

def Expr.checkedEvaluate (values : Store) : Expr → Option Int
  | .literal value => checkedValue value
  | .name index => checkedValue (values index)
  | .positive value | .parenthesized value => value.checkedEvaluate values
  | .negative value => (value.checkedEvaluate values).bind fun result => checkedValue (-result)
  | .add left right => (left.checkedEvaluate values).bind fun a =>
      (right.checkedEvaluate values).bind fun b => checkedValue (a + b)
  | .subtract left right => (left.checkedEvaluate values).bind fun a =>
      (right.checkedEvaluate values).bind fun b => checkedValue (a - b)
  | .multiply left right => (left.checkedEvaluate values).bind fun a =>
      (right.checkedEvaluate values).bind fun b => checkedValue (a * b)

theorem Expr.checkedEvaluate_agrees {expression : Expr} {values : Store}
    (safe : expression.Safe values) :
    expression.checkedEvaluate values = some (expression.evaluate values) := by
  induction expression with
  | literal | name =>
      change InRange _ at safe
      simp only [checkedEvaluate, checkedValue, safe, ↓reduceIte, evaluate]
  | positive _ ih | parenthesized _ ih => exact ih safe
  | negative _ ih =>
      simp only [checkedEvaluate, ih safe.1, Option.bind_some, checkedValue, safe.2, ↓reduceIte, evaluate]
  | add _ _ ihl ihr | subtract _ _ ihl ihr | multiply _ _ ihl ihr =>
      simp only [checkedEvaluate, ihl safe.1, ihr safe.2.1, Option.bind_some,
        checkedValue, safe.2.2, ↓reduceIte, evaluate]

theorem Expr.inferred_execution {ranges : Ranges} {expression : Expr} {bounds : Interval} {values : Store}
    (found : expression.infer ranges = some bounds) (fits : Fits ranges values) :
    expression.checkedEvaluate values = some (expression.evaluate values) :=
  checkedEvaluate_agrees (infer_sound found fits).2

end Silver.Integer
