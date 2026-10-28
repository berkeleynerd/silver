module

public import Silver.IntegerDivision
public import Silver.ArrayLayout

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
  /-- Internal exact declaration snapshot; never an author-source production. -/
  | snapshot (value : Int)
  | name (index : Nat)
  | indexed (array : ArrayDescriptor) (index : Expr)
  | positive (value : Expr)
  | negative (value : Expr)
  | parenthesized (value : Expr)
  | add (left right : Expr)
  | subtract (left right : Expr)
  | multiply (left right : Expr)
  | divide (left right : Expr)
  | modulo (left right : Expr)
  | remainder (left right : Expr)
  deriving DecidableEq, Repr

def Expr.evaluate (values : Store) : Expr → Int
  | .literal value | .snapshot value => value
  | .name index => values index
  | .indexed array index => array.project values (index.evaluate values)
  | .positive value | .parenthesized value => value.evaluate values
  | .negative value => -value.evaluate values
  | .add left right => left.evaluate values + right.evaluate values
  | .subtract left right => left.evaluate values - right.evaluate values
  | .multiply left right => left.evaluate values * right.evaluate values
  | .divide left right => (left.evaluate values).tdiv (right.evaluate values)
  | .modulo left right => (left.evaluate values).fmod (right.evaluate values)
  | .remainder left right => (left.evaluate values).tmod (right.evaluate values)

def accepted (result : CheckResult) : Option Interval :=
  if result.safe then some result.bounds else none

theorem accepted_iff (result : CheckResult) (bounds : Interval) :
    accepted result = some bounds ↔ result.safe = true ∧ result.bounds = bounds := by
  simp only [accepted]
  cases result.safe <;> simp

/-- Every indexed occurrence has a nonempty, contained index interval, even
in source regions whose execution is otherwise impossible. -/
def arrayIndexCheck (array : ArrayDescriptor) (indices : Interval) : Bool :=
  decide (array.Valid ∧ indices.lower ≤ indices.upper ∧
    array.bounds.lower ≤ indices.lower ∧ indices.upper ≤ array.bounds.upper)

def arrayReadRange (ranges : Ranges) (array : ArrayDescriptor) (indices : Interval) : Option Interval :=
  if arrayIndexCheck array indices then
    (arraySpanRange ranges (array.address indices.lower)
      (indices.upper - indices.lower + 1).toNat).bind fun bounds => accepted (checked bounds)
  else none

theorem arrayReadRange_index {ranges : Ranges} {array : ArrayDescriptor} {indices bounds : Interval}
    (found : arrayReadRange ranges array indices = some bounds) :
    arrayIndexCheck array indices = true := by
  unfold arrayReadRange at found
  split at found
  · assumption
  · contradiction

theorem arrayReadRange_bounded {ranges : Ranges} {array : ArrayDescriptor} {indices bounds : Interval}
    (found : arrayReadRange ranges array indices = some bounds) : bounds.Bounded := by
  unfold arrayReadRange at found
  split at found
  · simp only [Option.bind_eq_some_iff] at found
    obtain ⟨raw, _, accepted⟩ := found
    rw [← ((accepted_iff _ _).mp accepted).2]
    exact checked_bounded _
  · contradiction

theorem arrayReadRange_sound {ranges : Ranges} {values : Store} {array : ArrayDescriptor}
    {indices bounds : Interval} {index : Int}
    (found : arrayReadRange ranges array indices = some bounds) (fits : Fits ranges values)
    (inside : indices.Contains index) : array.bounds.Contains index ∧
      bounds.Contains (array.project values index) ∧ InRange (array.project values index) := by
  have allowed := arrayReadRange_index found
  simp only [arrayIndexCheck, decide_eq_true_eq] at allowed
  have inArray : array.bounds.Contains index := by
    simp only [Interval.Contains] at *
    omega
  have inSpan : array.address indices.lower ≤ array.address index ∧
      array.address index < array.address indices.lower + (indices.upper - indices.lower + 1).toNat := by
    simp only [ArrayDescriptor.address, Interval.Contains] at *
    omega
  unfold arrayReadRange at found
  rw [show arrayIndexCheck array indices = true from by simpa [arrayIndexCheck] using allowed] at found
  simp only [↓reduceIte, Option.bind_eq_some_iff] at found
  obtain ⟨raw, scanned, checked⟩ := found
  have accepted := (accepted_iff _ _).mp checked
  have within := arraySpanRange_sound fits scanned inSpan
  have sound := checked_sound accepted.1 within
  exact ⟨inArray, by simpa only [accepted.2, ArrayDescriptor.project] using sound.1,
    by simpa only [ArrayDescriptor.project] using sound.2⟩

def Expr.infer (ranges : Ranges) : Expr → Option Interval
  | .literal value | .snapshot value => accepted (checked (Interval.singleton value))
  | .name index => (ranges index).bind fun bounds => accepted (checked bounds)
  | .indexed array index => (index.infer ranges).bind fun bounds => arrayReadRange ranges array bounds
  | .positive value | .parenthesized value => value.infer ranges
  | .negative value => (value.infer ranges).bind fun bounds => accepted (checkedNegate bounds)
  | .add left right => (left.infer ranges).bind fun a =>
      (right.infer ranges).bind fun b => accepted (checkedAdd a b)
  | .subtract left right => (left.infer ranges).bind fun a =>
      (right.infer ranges).bind fun b => accepted (checkedSubtract a b)
  | .multiply left right => (left.infer ranges).bind fun a =>
      (right.infer ranges).bind fun b => accepted (checkedMultiply a b)
  | .divide left right => (left.infer ranges).bind fun a =>
      (right.infer ranges).bind fun b => accepted (checkedDivide a b)
  | .modulo left right => (left.infer ranges).bind fun a =>
      (right.infer ranges).bind fun b => accepted (checkedModulo a b)
  | .remainder left right => (left.infer ranges).bind fun a =>
      (right.infer ranges).bind fun b => accepted (checkedRemainder a b)

/-- Every node, including operands of a larger safe result, must fit Integer. -/
def Expr.Safe (values : Store) : Expr → Prop
  | .literal value | .snapshot value => InRange value
  | .name index => InRange (values index)
  | .indexed array index => index.Safe values ∧ array.bounds.Contains (index.evaluate values) ∧
      InRange (array.project values (index.evaluate values))
  | .positive value | .parenthesized value => value.Safe values
  | .negative value => value.Safe values ∧ InRange (-value.evaluate values)
  | .add left right => left.Safe values ∧ right.Safe values ∧
      InRange (left.evaluate values + right.evaluate values)
  | .subtract left right => left.Safe values ∧ right.Safe values ∧
      InRange (left.evaluate values - right.evaluate values)
  | .multiply left right => left.Safe values ∧ right.Safe values ∧
      InRange (left.evaluate values * right.evaluate values)
  | .divide left right => left.Safe values ∧ right.Safe values ∧
      DivideDefined (left.evaluate values) (right.evaluate values) ∧
      InRange ((left.evaluate values).tdiv (right.evaluate values))
  | .modulo left right => left.Safe values ∧ right.Safe values ∧
      ModuloDefined (left.evaluate values) (right.evaluate values) ∧
      InRange ((left.evaluate values).fmod (right.evaluate values))
  | .remainder left right => left.Safe values ∧ right.Safe values ∧
      RemainderDefined (left.evaluate values) (right.evaluate values) ∧
      InRange ((left.evaluate values).tmod (right.evaluate values))

theorem Expr.safe_value {values : Store} {expression : Expr}
    (safe : expression.Safe values) : InRange (expression.evaluate values) := by
  induction expression with
  | literal | snapshot | name => exact safe
  | indexed => exact safe.2.2
  | positive _ ih | parenthesized _ ih => exact ih safe
  | negative => exact safe.2
  | add | subtract | multiply => exact safe.2.2
  | divide | modulo | remainder => exact safe.2.2.2

theorem Expr.infer_bounded {ranges : Ranges} {expression : Expr} {bounds : Interval}
    (found : expression.infer ranges = some bounds) : bounds.Bounded := by
  induction expression generalizing bounds with
  | literal value | snapshot value =>
      have accepted := (accepted_iff _ _).mp found
      rw [← accepted.2]; exact checked_bounded _
  | name index =>
      simp only [infer, Option.bind_eq_some_iff] at found
      obtain ⟨interval, _, accepted⟩ := found
      rw [← ((accepted_iff _ _).mp accepted).2]; exact checked_bounded _
  | indexed array index _ =>
      simp only [infer, Option.bind_eq_some_iff] at found
      obtain ⟨indices, _, read⟩ := found
      exact arrayReadRange_bounded read
  | positive _ ih | parenthesized _ ih => exact ih found
  | negative value _ =>
      simp only [infer, Option.bind_eq_some_iff] at found
      obtain ⟨interval, _, accepted⟩ := found
      rw [← ((accepted_iff _ _).mp accepted).2]; exact checkedNegate_bounded _
  | add left right _ _ | subtract left right _ _ | multiply left right _ _
  | divide left right _ _ | modulo left right _ _ | remainder left right _ _ =>
      simp only [infer, Option.bind_eq_some_iff] at found
      obtain ⟨a, _, b, _, accepted⟩ := found
      rw [← ((accepted_iff _ _).mp accepted).2]
      first
      | exact checkedAdd_bounded _ _
      | exact checkedSubtract_bounded _ _
      | exact checkedMultiply_bounded _ _
      | exact checkedDivide_bounded _ _
      | exact checkedModulo_bounded _ _
      | exact checkedRemainder_bounded _ _

theorem Expr.infer_sound {ranges : Ranges} {expression : Expr} {bounds : Interval} {values : Store}
    (found : expression.infer ranges = some bounds) (fits : Fits ranges values) :
    bounds.Contains (expression.evaluate values) ∧ expression.Safe values := by
  induction expression generalizing bounds with
  | literal value | snapshot value =>
      have result := (accepted_iff _ _).mp found
      have sound := checked_sound result.1 ((Interval.singleton_contains value value).mpr rfl)
      simpa only [result.2, evaluate, Safe] using sound
  | name index =>
      simp only [infer, Option.bind_eq_some_iff] at found
      obtain ⟨interval, present, accepted⟩ := found
      have result := (accepted_iff _ _).mp accepted
      have sound := checked_sound result.1 (fits index interval present)
      simpa only [result.2, evaluate, Safe] using sound
  | indexed array index ih =>
      simp only [infer, Option.bind_eq_some_iff] at found
      obtain ⟨indices, inferred, read⟩ := found
      have child := ih inferred
      have sound := arrayReadRange_sound read fits child.1
      exact ⟨sound.2.1, child.2, sound.1, sound.2.2⟩
  | positive value ih | parenthesized value ih => exact ih found
  | negative value ih =>
      simp only [infer, Option.bind_eq_some_iff] at found
      obtain ⟨interval, child, accepted⟩ := found
      have result := (accepted_iff _ _).mp accepted
      have childSound := ih child
      have sound := checkedNegate_sound result.1 childSound.1
      exact ⟨by simpa only [result.2, evaluate] using sound.1, childSound.2, sound.2⟩
  | add left right ihl ihr | subtract left right ihl ihr | multiply left right ihl ihr
  | divide left right ihl ihr | modulo left right ihl ihr | remainder left right ihl ihr =>
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
      | have sound := checkedDivide_sound result.1 l.1 r.1
        exact ⟨by simpa only [result.2, evaluate] using sound.1, l.2, r.2, sound.2⟩
      | have sound := checkedModulo_sound result.1 l.1 r.1
        exact ⟨by simpa only [result.2, evaluate] using sound.1, l.2, r.2, sound.2⟩
      | have sound := checkedRemainder_sound result.1 l.1 r.1
        exact ⟨by simpa only [result.2, evaluate] using sound.1, l.2, r.2, sound.2⟩

def checkedValue (value : Int) : Option Int := if InRange value then some value else none

def Expr.checkedEvaluate (values : Store) : Expr → Option Int
  | .literal value | .snapshot value => checkedValue value
  | .name index => checkedValue (values index)
  | .indexed array index => (index.checkedEvaluate values).bind fun value =>
      if array.bounds.Contains value then checkedValue (array.project values value) else none
  | .positive value | .parenthesized value => value.checkedEvaluate values
  | .negative value => (value.checkedEvaluate values).bind fun result => checkedValue (-result)
  | .add left right => (left.checkedEvaluate values).bind fun a =>
      (right.checkedEvaluate values).bind fun b => checkedValue (a + b)
  | .subtract left right => (left.checkedEvaluate values).bind fun a =>
      (right.checkedEvaluate values).bind fun b => checkedValue (a - b)
  | .multiply left right => (left.checkedEvaluate values).bind fun a =>
      (right.checkedEvaluate values).bind fun b => checkedValue (a * b)
  | .divide left right => (left.checkedEvaluate values).bind fun a =>
      (right.checkedEvaluate values).bind fun b =>
        if DivideDefined a b then checkedValue (a.tdiv b) else none
  | .modulo left right => (left.checkedEvaluate values).bind fun a =>
      (right.checkedEvaluate values).bind fun b =>
        if ModuloDefined a b then checkedValue (a.fmod b) else none
  | .remainder left right => (left.checkedEvaluate values).bind fun a =>
      (right.checkedEvaluate values).bind fun b =>
        if RemainderDefined a b then checkedValue (a.tmod b) else none

theorem Expr.checkedEvaluate_agrees {expression : Expr} {values : Store}
    (safe : expression.Safe values) :
    expression.checkedEvaluate values = some (expression.evaluate values) := by
  induction expression with
  | literal | snapshot | name =>
      change InRange _ at safe
      simp only [checkedEvaluate, checkedValue, safe, ↓reduceIte, evaluate]
  | indexed array index ih =>
      simp only [checkedEvaluate, ih safe.1, Option.bind_some, safe.2.1,
        checkedValue, safe.2.2, ↓reduceIte, evaluate]
  | positive _ ih | parenthesized _ ih => exact ih safe
  | negative _ ih =>
      simp only [checkedEvaluate, ih safe.1, Option.bind_some, checkedValue, safe.2, ↓reduceIte, evaluate]
  | add _ _ ihl ihr | subtract _ _ ihl ihr | multiply _ _ ihl ihr =>
      simp only [checkedEvaluate, ihl safe.1, ihr safe.2.1, Option.bind_some,
        checkedValue, safe.2.2, ↓reduceIte, evaluate]
  | divide _ _ ihl ihr | modulo _ _ ihl ihr | remainder _ _ ihl ihr =>
      simp only [checkedEvaluate, ihl safe.1, ihr safe.2.1, Option.bind_some,
        safe.2.2.1, checkedValue, safe.2.2.2, ↓reduceIte, evaluate]

theorem Expr.inferred_execution {ranges : Ranges} {expression : Expr} {bounds : Interval} {values : Store}
    (found : expression.infer ranges = some bounds) (fits : Fits ranges values) :
    expression.checkedEvaluate values = some (expression.evaluate values) :=
  checkedEvaluate_agrees (infer_sound found fits).2

end Silver.Integer
