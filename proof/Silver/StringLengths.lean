module

public import Silver.Bindings

@[expose] public section

/-! Current String expressions retain a length interval and the exact number
of selected-input occurrences. Empty scalar domains have no runtime value, but
their flag does not erase the static contributions of other operands. Resource
checks therefore remain independent of path vacuity. -/
namespace Silver.Compose
open Bindings

structure LengthSummary where
  minimumLength : Nat := 0
  staticLength : Nat := 0
  dynamicCount : Nat := 0
  empty : Bool := false
  deriving DecidableEq, Repr

def LengthSummary.lower (summary : LengthSummary) : Summary :=
  ⟨summary.minimumLength, summary.dynamicCount⟩

def LengthSummary.upper (summary : LengthSummary) : Summary :=
  ⟨summary.staticLength, summary.dynamicCount⟩

def LengthSummary.Contains (summary : LengthSummary) (inputLength length : Nat) : Prop :=
  summary.empty = false ∧ summary.lower.length inputLength ≤ length ∧
    length ≤ summary.upper.length inputLength

def LengthSummary.ofExact (summary : Summary) : LengthSummary :=
  ⟨summary.staticLength, summary.staticLength, summary.dynamicCount, false⟩

def LengthSummary.ofImage (bounds : Integer.Interval) : LengthSummary :=
  if bounds.isEmpty then ⟨0, 0, 0, true⟩ else
    ⟨(Integer.Image.lengthBounds bounds).1, (Integer.Image.lengthBounds bounds).2, 0, false⟩

def LengthSummary.add (left right : LengthSummary) : LengthSummary :=
  ⟨left.minimumLength + right.minimumLength, left.staticLength + right.staticLength,
    left.dynamicCount + right.dynamicCount, left.empty || right.empty⟩

def LengthSummary.exact (summary : LengthSummary) : Option Summary :=
  if !summary.empty && decide (summary.minimumLength = summary.staticLength)
  then some summary.upper else none

theorem LengthSummary.ofExact_contains (summary : Summary) (inputLength length : Nat) :
    (ofExact summary).Contains inputLength length ↔ length = summary.length inputLength := by
  simp only [Contains, ofExact, lower, upper, Summary.length, true_and]
  omega

theorem LengthSummary.add_contains {left right : LengthSummary} {inputLength a b : Nat}
    (first : left.Contains inputLength a) (second : right.Contains inputLength b) :
    (left.add right).Contains inputLength (a + b) := by
  obtain ⟨leftEmpty, lowA, highA⟩ := first
  obtain ⟨rightEmpty, lowB, highB⟩ := second
  simp only [Contains, add, leftEmpty, rightEmpty, Bool.false_or, true_and,
    lower, upper, Summary.length, Nat.add_mul]
  simp only [lower, upper, Summary.length] at lowA highA lowB highB
  omega

theorem LengthSummary.exact_contains {summary : LengthSummary} {affine : Summary}
    (known : summary.exact = some affine) (inputLength length : Nat) :
    summary.Contains inputLength length ↔ length = affine.length inputLength := by
  unfold exact at known
  split at known
  · rename_i exact
    simp only [Bool.and_eq_true, Bool.not_eq_true', decide_eq_true_eq] at exact
    cases known
    simp only [Contains, exact.1, true_and, lower, upper, Summary.length, exact.2]
    omega
  · cases known

theorem LengthSummary.image_contains (bounds : Integer.Interval) (value : Int)
    (within : bounds.Contains value) (inputLength : Nat) :
    (ofImage bounds).Contains inputLength (Integer.Image.bytes value).length := by
  have nonempty : bounds.isEmpty = false := by
    simp only [Integer.Interval.isEmpty, decide_eq_false_iff_not, Integer.Interval.Contains] at *
    omega
  simp only [ofImage, nonempty, Bool.false_eq_true, ↓reduceIte, Contains,
    lower, upper, Summary.length, Nat.zero_mul, Nat.add_zero, true_and]
  exact Integer.Image.length_interval bounds value within

def Operand.inferLength (shape : Shape) (ranges : Integer.Ranges) : Operand → Option LengthSummary
  | .image expression => (expression.infer ranges).map LengthSummary.ofImage
  | atom => (atom.infer shape).map (LengthSummary.ofExact ∘ Bound.summary)

def Operand.ImagesSafe (integers : Integer.Store) : Operand → Prop
  | .image expression => expression.Safe integers
  | _ => True

def Expression.inferLength (expression : Expression) (shape : Shape)
    (ranges : Integer.Ranges) : Option LengthSummary :=
  match expression with
  | [] => some {}
  | atom :: rest => (atom.inferLength shape ranges).bind fun first =>
      (Expression.inferLength rest shape ranges).map first.add

def Expression.ImagesSafe (expression : Expression) (integers : Integer.Store) : Prop :=
  ∀ atom ∈ expression, atom.ImagesSafe integers

theorem Operand.inferLength_sound {atom : Operand} {shape : Shape} {ranges : Integer.Ranges}
    {summary : LengthSummary} {values : Values} {input : Source} {integers : Integer.Store}
    (known : atom.inferLength shape ranges = some summary)
    (strings : Fits shape input values) (scalars : Integer.Fits ranges integers) :
    summary.Contains input.length (atom.evaluate values input integers).length ∧ atom.ImagesSafe integers := by
  cases atom with
  | literal bytes =>
      cases known
      exact ⟨(LengthSummary.ofExact_contains _ _ _).mpr (by simp [Bound.summary, Summary.length, Value.evaluate]), trivial⟩
  | argument =>
      cases known
      exact ⟨(LengthSummary.ofExact_contains _ _ _).mpr (by simp [Bound.summary, Summary.length, Value.evaluate]), trivial⟩
  | reference index =>
      simp only [inferLength, Value.infer, Option.map_map, Option.map_eq_some_iff] at known
      obtain ⟨info, found, rfl⟩ := known
      refine ⟨(LengthSummary.ofExact_contains _ _ _).mpr ?_, trivial⟩
      simpa only [Value.evaluate, Bound.summary_length] using (strings index info found).1
  | image expression =>
      simp only [inferLength, Option.map_eq_some_iff] at known
      obtain ⟨bounds, found, rfl⟩ := known
      obtain ⟨within, safe⟩ := Integer.Expr.infer_sound found scalars
      refine ⟨?_, safe⟩
      exact LengthSummary.image_contains bounds (expression.evaluate integers) within input.length

theorem Expression.inferLength_sound {expression : Expression} {shape : Shape}
    {ranges : Integer.Ranges} {summary : LengthSummary} {values : Values} {input : Source}
    {integers : Integer.Store} (known : expression.inferLength shape ranges = some summary)
    (strings : Fits shape input values) (scalars : Integer.Fits ranges integers) :
    summary.Contains input.length (expression.evaluate values input integers).length ∧
      expression.ImagesSafe integers := by
  induction expression generalizing summary with
  | nil =>
      cases known
      exact ⟨by simp [LengthSummary.Contains, LengthSummary.lower, LengthSummary.upper,
        Summary.length, evaluate], by simp [ImagesSafe]⟩
  | cons atom rest ih =>
      simp only [inferLength, Option.bind_eq_some_iff, Option.map_eq_some_iff] at known
      obtain ⟨first, atomKnown, remaining, restKnown, rfl⟩ := known
      have a := Operand.inferLength_sound atomKnown strings scalars
      have b := ih restKnown
      refine ⟨?_, ?_⟩
      · simpa only [evaluate, List.length_append] using LengthSummary.add_contains a.1 b.1
      · intro item member
        rcases List.mem_cons.mp member with rfl | member
        · exact a.2
        · exact b.2 item member

end Silver.Compose
