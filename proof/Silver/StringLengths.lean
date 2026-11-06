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

@[simp] theorem LengthSummary.add_zero (summary : LengthSummary) : summary.add {} = summary := by
  cases summary
  simp [add]

@[simp] theorem LengthSummary.zero_add (summary : LengthSummary) : ({} : LengthSummary).add summary = summary := by
  cases summary
  simp [add]

theorem LengthSummary.add_assoc (a b c : LengthSummary) : (a.add b).add c = a.add (b.add c) := by
  simp [add, Nat.add_assoc, Bool.or_assoc]

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
  | atom@(.slice _ _ _ _) | atom@(.character _) | atom@(.replace _ _ _ _) =>
      (atom.extraRange shape ranges).map fun bounds => ⟨bounds.1, bounds.2, 0, false⟩
  | atom => (atom.infer shape).map (LengthSummary.ofExact ∘ Bound.summary)

def Operand.ImagesSafe (integers : Integer.Store) (values : Values) : Operand → Prop :=
  Value.ChecksSafe values integers

def Expression.inferLength (expression : Expression) (shape : Shape)
    (ranges : Integer.Ranges) : Option LengthSummary :=
  match expression with
  | [] => some {}
  | atom :: rest => (atom.inferLength shape ranges).bind fun first =>
      (Expression.inferLength rest shape ranges).map first.add

theorem Expression.inferLength_append (left right : Expression) (shape : Shape) (ranges : Integer.Ranges) :
    (left ++ right).inferLength shape ranges = (left.inferLength shape ranges).bind fun first =>
      (right.inferLength shape ranges).map first.add := by
  induction left with
  | nil => cases known : right.inferLength shape ranges <;> simp [inferLength, known]
  | cons atom rest ih =>
      simp only [List.cons_append, inferLength, ih]
      cases atom.inferLength shape ranges <;> cases Expression.inferLength rest shape ranges <;>
        cases right.inferLength shape ranges <;> simp [LengthSummary.add_assoc]

def Expression.ImagesSafe (expression : Expression) (integers : Integer.Store) (values : Values) : Prop :=
  ∀ atom ∈ expression, atom.ImagesSafe integers values

theorem Operand.inferLength_sound {atom : Operand} {shape : Shape} {ranges : Integer.Ranges}
    {summary : LengthSummary} {values : Values} {input : Source} {integers : Integer.Store}
    (known : atom.inferLength shape ranges = some summary)
    (strings : Fits shape input values) (scalars : Integer.Fits ranges integers) :
    summary.Contains input.length (atom.evaluate values input integers).length ∧ atom.ImagesSafe integers values := by
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
  | slice | character | replace =>
      simp only [inferLength, Option.map_eq_some_iff] at known
      obtain ⟨bounds, found, rfl⟩ := known
      have sound := Value.extraRange_sound found strings scalars
      refine ⟨?_, sound.2.2⟩
      simpa only [LengthSummary.Contains, LengthSummary.lower, LengthSummary.upper,
        Summary.length, Nat.zero_mul, Nat.add_zero, true_and] using And.intro sound.1 sound.2.1

theorem Expression.inferLength_sound {expression : Expression} {shape : Shape}
    {ranges : Integer.Ranges} {summary : LengthSummary} {values : Values} {input : Source}
    {integers : Integer.Store} (known : expression.inferLength shape ranges = some summary)
    (strings : Fits shape input values) (scalars : Integer.Fits ranges integers) :
    summary.Contains input.length (expression.evaluate values input integers).length ∧
      expression.ImagesSafe integers values := by
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

theorem image_printable (value : Int) : Printable (Integer.Image.bytes value) := by
  intro byte present
  obtain ⟨character, member, rfl⟩ := List.mem_map.mp present
  simp only [Integer.Image.characters, List.mem_cons] at member
  rcases member with rfl | digit
  · split <;> decide
  · have bounds := Char.isDigit_iff_toNat.mp
      (Nat.isDigit_of_mem_toDigits (by decide) (by decide) digit)
    change 48 ≤ character.toNat ∧ character.toNat ≤ 57 at bounds
    simp only [Output.printable, decide_eq_true_eq]
    omega

theorem Operand.inferLength_printable {atom : Operand} {shape : Shape} {ranges : Integer.Ranges}
    {summary : LengthSummary} {values : Values} {input : Source} {integers : Integer.Store}
    (known : atom.inferLength shape ranges = some summary) (strings : Fits shape input values)
    (inputPrintable : Printable input) (literals : atom.PrintableLiterals) :
    Printable (atom.evaluate values input integers) := by
  cases atom with
  | literal bytes => exact literals
  | argument => exact inputPrintable
  | image expression => exact image_printable (expression.evaluate integers)
  | reference index =>
      simp only [inferLength, Value.infer, Option.map_map, Option.map_eq_some_iff] at known
      obtain ⟨info, found, _⟩ := known
      exact (strings index info found).2
  | slice | character | replace =>
      simp only [inferLength, Option.map_eq_some_iff] at known
      obtain ⟨bounds, found, _⟩ := known
      exact Value.extraRange_printable found strings integers

theorem Expression.inferLength_printable {expression : Expression} {shape : Shape}
    {ranges : Integer.Ranges} {summary : LengthSummary} {values : Values} {input : Source}
    {integers : Integer.Store} (known : expression.inferLength shape ranges = some summary)
    (strings : Fits shape input values) (inputPrintable : Printable input)
    (literals : expression.LiteralsPrintable) :
    Printable (expression.evaluate values input integers) := by
  induction expression generalizing summary with
  | nil => simp [evaluate, Printable]
  | cons atom rest ih =>
      simp only [inferLength, Option.bind_eq_some_iff, Option.map_eq_some_iff] at known
      obtain ⟨first, atomKnown, remaining, restKnown, _⟩ := known
      have a := Operand.inferLength_printable (integers := integers) atomKnown strings inputPrintable
        (literals atom (by simp))
      have b := ih restKnown (fun item member => literals item (by simp [member]))
      intro byte present
      simp only [evaluate, List.mem_append] at present
      exact present.elim (a byte) (b byte)

theorem Expression.inferLength_exact {expression : Expression} {shape : Shape}
    {ranges : Integer.Ranges} {summary : LengthSummary} {affine : Summary}
    {values : Values} {input : Source} {integers : Integer.Store}
    (known : expression.inferLength shape ranges = some summary) (exact : summary.exact = some affine)
    (strings : Fits shape input values) (scalars : Integer.Fits ranges integers) :
    (expression.evaluate values input integers).length = affine.length input.length :=
  (LengthSummary.exact_contains exact _ _).mp (inferLength_sound known strings scalars).1

theorem Expression.inferLength_bound {expression : Expression} {shape : Shape}
    {ranges : Integer.Ranges} {summary : LengthSummary} {values : Values} {input : Source}
    {integers : Integer.Store} {capacity : Nat}
    (known : expression.inferLength shape ranges = some summary)
    (strings : Fits shape input values) (scalars : Integer.Fits ranges integers)
    (bound : summary.upper.length capacity ≤ maxSourceLength) (fits : input.length ≤ capacity) :
    (expression.evaluate values input integers).length ≤ maxSourceLength := by
  have actual := (inferLength_sound known strings scalars).1.2.2
  have monotone : summary.upper.length input.length ≤ summary.upper.length capacity :=
    Nat.add_le_add_left (Nat.mul_le_mul_left _ fits) _
  exact Nat.le_trans actual (Nat.le_trans monotone bound)

end Silver.Compose
