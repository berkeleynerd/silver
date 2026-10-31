module

public import Silver.ArgumentsRuntime
public import Silver.IntegerExpressions
public import Silver.IntegerImage
public import Silver.CharacterExpressions

@[expose] public section

/-! Shared initialized String bindings. Object bounds and current values are
separate: declaration copies snapshot bytes, and assignment changes only the
selected value. Indices identify declarations; lexical name resolution is a
separate source judgment. -/

namespace Silver.Bindings

def Printable (bytes : Source) : Prop :=
  ∀ byte ∈ bytes, Output.printable byte = true

inductive Bound
  | fixed (length : Nat)
  | argument
  deriving DecidableEq, Repr

def Bound.length (inputLength : Nat) : Bound → Nat
  | .fixed length => length
  | .argument => inputLength

structure Summary where
  staticLength : Nat := 0
  dynamicCount : Nat := 0
  deriving DecidableEq, Repr

def Summary.length (summary : Summary) (inputLength : Nat) : Nat :=
  summary.staticLength + summary.dynamicCount * inputLength

def Bound.summary : Bound → Summary
  | .fixed length => ⟨length, 0⟩
  | .argument => ⟨0, 1⟩

theorem Bound.summary_length (bound : Bound) (inputLength : Nat) :
    bound.summary.length inputLength = bound.length inputLength := by
  cases bound <;> simp [summary, Summary.length, length]

structure CellInfo where
  bound : Bound
  mutable : Bool
  deriving DecidableEq, Repr

/-- The source recognizer retains spans and a copied initialization origin.
Only the active ordered prefix of the native bounded array is modeled here. -/
structure BindingInfo where
  first : Nat := 0
  after : Nat := 0
  valueFirst : Nat := 0
  staticLength : Nat := 0
  dynamic : Bool := false
  mutable : Bool := false
  isCharacter : Bool := false
  firstIndex : Int := 1
  lastIndex : Int := 0
  deriving DecidableEq, Repr

def BindingInfo.bound (info : BindingInfo) : Bound :=
  if info.dynamic then .argument else .fixed info.staticLength

def BindingInfo.cell (info : BindingInfo) : CellInfo := ⟨info.bound, info.mutable⟩

abbrev BindingEnvironment := List BindingInfo

abbrev Shape := Nat → Option CellInfo
abbrev Values := Nat → Source

def emptyShape : Shape := fun _ => none
def emptyValues : Values := fun _ => []

def BindingEnvironment.get (environment : BindingEnvironment) (index : Nat) : Option BindingInfo :=
  if index = 0 then none else environment[index - 1]?

def BindingEnvironment.shape (environment : BindingEnvironment) : Shape :=
  fun index => (environment.get index).map BindingInfo.cell

def put {α : Type} (values : Nat → α) (index : Nat) (value : α) : Nat → α :=
  fun other => if other = index then value else values other

theorem put_same {α : Type} (values : Nat → α) (index : Nat) (value : α) :
    put values index value index = value := by simp [put]

theorem put_other {α : Type} (values : Nat → α) (index other : Nat) (value : α)
    (different : other ≠ index) : put values index value other = values other := by
  simp [put, different]

theorem environment_fresh (environment : BindingEnvironment) :
    environment.shape (environment.length + 1) = none := by
  simp [BindingEnvironment.shape, BindingEnvironment.get]

theorem environment_append (environment : BindingEnvironment) (info : BindingInfo) :
    (environment ++ [info]).shape = put environment.shape (environment.length + 1) (some info.cell) := by
  funext index
  by_cases zero : index = 0
  · subst index
    simp [BindingEnvironment.shape, BindingEnvironment.get, put]
  · by_cases same : index = environment.length + 1
    · subst index
      simp [BindingEnvironment.shape, BindingEnvironment.get, put]
    · by_cases before : index - 1 < environment.length
      · simp [BindingEnvironment.shape, BindingEnvironment.get, put, zero, same,
          List.getElem?_append_left before]
      · have after : environment.length < index - 1 := by omega
        have beyond : environment.length + 1 ≤ index - 1 := by omega
        simp [BindingEnvironment.shape, BindingEnvironment.get, put, zero, same,
          List.getElem?_eq_none (by omega : environment.length ≤ index - 1),
          List.getElem?_eq_none (by simpa using beyond : (environment ++ [info]).length ≤ index - 1)]

def Fits (shape : Shape) (input : Source) (values : Values) : Prop :=
  ∀ index info, shape index = some info →
    (values index).length = info.bound.length input.length ∧ Printable (values index)

theorem empty_fits (input : Source) : Fits emptyShape input emptyValues := by
  intro index info found
  cases found

def Shape.fixedLengths (shape : Shape) : Character.Lengths := fun index =>
  (shape index).bind fun info => match info.bound with
    | .fixed length => some length
    | .argument => none

theorem fixedLengths_found {shape : Shape} {index length : Nat}
    (found : shape.fixedLengths index = some length) :
    ∃ mutable, shape index = some ⟨.fixed length, mutable⟩ := by
  simp only [Shape.fixedLengths, Option.bind_eq_some_iff] at found
  obtain ⟨info, present, result⟩ := found
  cases info with
  | mk bound mutable =>
      cases bound with
      | argument => cases result
      | fixed count => cases result; exact ⟨mutable, present⟩

theorem fits_fixedLengths {shape : Shape} {input : Source} {values : Values}
    (fits : Fits shape input values) : Character.Fits shape.fixedLengths values := by
  intro index length found
  obtain ⟨mutable, present⟩ := fixedLengths_found found
  exact fits index _ present

inductive Value
  | literal (bytes : Source)
  | reference (index : Nat)
  | argument
  | image (expression : Integer.Expr)
  | slice (target : Nat) (baseLower : Int) (lower upper : Integer.Expr)
  | character (expression : Character.Expr)
  | replace (target : Nat) (baseLower : Int) (index : Integer.Expr) (replacement : Character.Expr)
  deriving DecidableEq, Repr

def Value.evaluate (values : Values) (input : Source) (value : Value)
    (integers : Integer.Store := Integer.emptyStore) : Source :=
  match value with
  | .literal bytes => bytes
  | .reference index => values index
  | .argument => input
  | .image expression => Integer.Image.bytes (expression.evaluate integers)
  | .slice target base lower upper =>
      StringIndexing.slice (values target) base (lower.evaluate integers) (upper.evaluate integers)
  | .character expression => [expression.evaluate values integers]
  | .replace target base index replacement =>
      StringIndexing.replace (values target) base (index.evaluate integers) (replacement.evaluate values integers)

/-- Scalar-dependent operations have a non-input length interval. The captured
base is joined to actual Ada object bounds by the source metadata invariant. -/
def Value.extraRange (shape : Shape) (ranges : Integer.Ranges) : Value → Option (Nat × Nat)
  | .slice target base lower upper => (shape.fixedLengths target).bind fun length =>
      (lower.infer ranges).bind fun a => (upper.infer ranges).bind fun b =>
        if StringIndexing.sliceCheck base length a b then
          some (StringIndexing.sliceMinimum a b, StringIndexing.sliceMaximum a b) else none
  | .character expression =>
      if expression.check shape.fixedLengths ranges then some (1, 1) else none
  | .replace target base index replacement => (shape.fixedLengths target).bind fun length =>
      (index.infer ranges).bind fun indices =>
        if StringIndexing.indexCheck base length indices && replacement.check shape.fixedLengths ranges
        then some (length, length) else none
  | _ => none

def Value.ChecksSafe (values : Values) (integers : Integer.Store) : Value → Prop
  | .image expression => expression.Safe integers
  | .slice target base lower upper => lower.Safe integers ∧ upper.Safe integers ∧
      StringIndexing.sliceValid base (values target).length (lower.evaluate integers) (upper.evaluate integers)
  | .character expression => expression.Safe values integers
  | .replace target base index replacement => index.Safe integers ∧
      StringIndexing.indexValid base (values target).length (index.evaluate integers) ∧
      replacement.Safe values integers
  | _ => True

theorem Value.extraRange_sound {value : Value} {shape : Shape} {ranges : Integer.Ranges}
    {bounds : Nat × Nat} {values : Values} {input : Source} {integers : Integer.Store}
    (known : value.extraRange shape ranges = some bounds)
    (strings : Fits shape input values) (scalars : Integer.Fits ranges integers) :
    bounds.1 ≤ (value.evaluate values input integers).length ∧
    (value.evaluate values input integers).length ≤ bounds.2 ∧ value.ChecksSafe values integers := by
  cases value with
  | literal | reference | argument | image => cases known
  | slice target base lower upper =>
      simp only [extraRange, Option.bind_eq_some_iff] at known
      obtain ⟨length, targetFound, a, lowerFound, b, upperFound, result⟩ := known
      split at result
      · rename_i checked
        cases result
        have left := Integer.Expr.infer_sound lowerFound scalars
        have right := Integer.Expr.infer_sound upperFound scalars
        have len := (fits_fixedLengths strings target length targetFound).1
        have safe : StringIndexing.sliceValid base (values target).length
            (lower.evaluate integers) (upper.evaluate integers) := by
          rw [len]
          exact StringIndexing.sliceCheck_sound checked left.1 right.1
        have interval := StringIndexing.sliceLength_bounds left.1 right.1
        simpa only [evaluate, StringIndexing.slice_length _ safe] using
          And.intro interval.1 (And.intro interval.2 (And.intro left.2 (And.intro right.2 safe)))
      · cases result
  | character expression =>
      simp only [extraRange] at known
      split at known
      · rename_i checked
        cases known
        exact ⟨Nat.le_refl _, Nat.le_refl _,
          Character.Expr.check_safe checked (fits_fixedLengths strings) scalars⟩
      · cases known
  | replace target base index replacement =>
      simp only [extraRange, Option.bind_eq_some_iff] at known
      obtain ⟨length, targetFound, indices, indexFound, result⟩ := known
      split at result
      · rename_i checked
        simp only [Bool.and_eq_true] at checked
        cases result
        have inferred := Integer.Expr.infer_sound indexFound scalars
        have len := (fits_fixedLengths strings target length targetFound).1
        have safe : StringIndexing.indexValid base (values target).length (index.evaluate integers) := by
          rw [len]
          exact StringIndexing.indexCheck_sound checked.1 inferred.1
        refine ⟨?_, ?_, inferred.2, safe,
          Character.Expr.check_safe checked.2 (fits_fixedLengths strings) scalars⟩ <;>
          simp only [evaluate, StringIndexing.replace_length, len, Nat.le_refl]
      · cases result

theorem Value.extraRange_printable {value : Value} {shape : Shape} {ranges : Integer.Ranges}
    {bounds : Nat × Nat} {values : Values} {input : Source}
    (known : value.extraRange shape ranges = some bounds) (strings : Fits shape input values)
    (integers : Integer.Store) : Printable (value.evaluate values input integers) := by
  cases value with
  | literal | reference | argument | image => cases known
  | slice target base lower upper =>
      simp only [extraRange, Option.bind_eq_some_iff] at known
      obtain ⟨length, targetFound, _⟩ := known
      intro byte member
      exact (fits_fixedLengths strings target length targetFound).2 byte
        (StringIndexing.slice_member member)
  | character expression =>
      simp only [extraRange] at known
      split at known
      · rename_i checked
        intro byte member
        have same : byte = expression.evaluate values integers := by simpa only [evaluate, List.mem_singleton] using member
        subst byte
        exact Character.Expr.printable (Character.Expr.check_readable checked)
          (Character.Expr.check_literals checked) (fits_fixedLengths strings) integers
      · cases known
  | replace target base index replacement =>
      simp only [extraRange, Option.bind_eq_some_iff] at known
      obtain ⟨length, targetFound, indices, _, result⟩ := known
      split at result
      · rename_i checked
        simp only [Bool.and_eq_true] at checked
        exact StringIndexing.replace_printable (fits_fixedLengths strings target length targetFound).2
          (Character.Expr.printable (Character.Expr.check_readable checked.2)
            (Character.Expr.check_literals checked.2) (fits_fixedLengths strings) integers)
      · cases result

/-- Exact object-bound inference. Scalar-dependent Image operands use the
current integer ranges in `Compose.Operand.inferLength`. -/
def Value.infer (shape : Shape) : Value → Option Bound
  | .literal bytes => some (.fixed bytes.length)
  | .reference index => (shape index).map CellInfo.bound
  | .argument => some .argument
  | .image _ => none
  | value => (value.extraRange shape Integer.emptyRanges).bind fun bounds =>
      if bounds.1 = bounds.2 then some (.fixed bounds.1) else none

def Value.PrintableLiterals : Value → Prop
  | .literal bytes => Printable bytes
  | .character expression | .replace _ _ _ expression => expression.PrintableLiterals
  | _ => True

theorem value_length {shape : Shape} {input : Source} {values : Values}
    (fits : Fits shape input values) {value : Value} {bound : Bound}
    (inferred : value.infer shape = some bound) :
    (value.evaluate values input).length = bound.length input.length := by
  cases value with
  | literal bytes => cases inferred; rfl
  | argument => cases inferred; rfl
  | image _ => cases inferred
  | slice target base lower upper | character | replace =>
      simp only [Value.infer, Option.bind_eq_some_iff] at inferred
      obtain ⟨bounds, found, result⟩ := inferred
      split at result
      · rename_i exact
        cases result
        have known := Value.extraRange_sound found fits (Integer.empty_fits Integer.emptyStore)
        change _ = bounds.1
        omega
      · cases result
  | reference index =>
      simp only [Value.infer, Option.map_eq_some_iff] at inferred
      obtain ⟨info, found, same⟩ := inferred
      subst bound
      exact (fits index info found).1

theorem value_printable {shape : Shape} {input : Source} {values : Values}
    (fits : Fits shape input values) (inputPrintable : Printable input)
    {value : Value} {bound : Bound} (inferred : value.infer shape = some bound)
    (literals : value.PrintableLiterals) : Printable (value.evaluate values input) := by
  cases value with
  | literal bytes => exact literals
  | argument => exact inputPrintable
  | image _ => cases inferred
  | slice | character | replace =>
      simp only [Value.infer, Option.bind_eq_some_iff] at inferred
      obtain ⟨bounds, found, _⟩ := inferred
      exact Value.extraRange_printable found fits Integer.emptyStore
  | reference index =>
      simp only [Value.infer, Option.map_eq_some_iff] at inferred
      obtain ⟨info, found, _⟩ := inferred
      exact (fits index info found).2

end Silver.Bindings

namespace Silver.Compose
open Bindings

abbrev Operand := Bindings.Value
abbrev Expression := List Operand

def maxExpressionOperands : Nat := 64

def Bound.staticPart : Bound → Nat
  | .fixed length => length
  | .argument => 0

def Bound.dynamicPart : Bound → Nat
  | .fixed _ => 0
  | .argument => 1

def Operand.bound (shape : Shape) (atom : Operand) : Bound :=
  (atom.infer shape).getD (.fixed 0)

def Operand.staticLength (shape : Shape) (atom : Operand) : Nat :=
  Bound.staticPart (atom.bound shape)

def Operand.dynamicCount (shape : Shape) (atom : Operand) : Nat :=
  Bound.dynamicPart (atom.bound shape)

def Expression.evaluate (values : Values) (input : Source) (expression : Expression)
    (integers : Integer.Store := Integer.emptyStore) : Source :=
  match expression with
  | [] => []
  | atom :: rest => atom.evaluate values input integers ++ Expression.evaluate values input rest integers

def Expression.staticLength (shape : Shape) : Expression → Nat
  | [] => 0
  | atom :: rest => atom.staticLength shape + Expression.staticLength shape rest

def Expression.dynamicCount (shape : Shape) : Expression → Nat
  | [] => 0
  | atom :: rest => atom.dynamicCount shape + Expression.dynamicCount shape rest

def Expression.Readable (expression : Expression) (shape : Shape) : Prop :=
  ∀ atom ∈ expression, ∃ bound, atom.infer shape = some bound

def Expression.LiteralsPrintable (expression : Expression) : Prop :=
  ∀ atom ∈ expression, atom.PrintableLiterals

theorem Operand.evaluate_length {atom : Operand} {shape : Shape}
    {values : Values} {input : Source} (fits : Fits shape input values)
    (readable : ∃ bound, atom.infer shape = some bound) :
    (atom.evaluate values input).length =
      atom.staticLength shape + atom.dynamicCount shape * input.length := by
  obtain ⟨bound, inferred⟩ := readable
  rw [Bindings.value_length fits inferred]
  simp only [staticLength, dynamicCount, Operand.bound, inferred, Option.getD_some]
  cases bound <;> simp [Bindings.Bound.length, Bound.staticPart, Bound.dynamicPart]

theorem Expression.evaluate_length {expression : Expression} {shape : Shape}
    {values : Values} {input : Source} (fits : Fits shape input values)
    (readable : expression.Readable shape) :
    (expression.evaluate values input).length =
      expression.staticLength shape + expression.dynamicCount shape * input.length := by
  induction expression with
  | nil => simp [evaluate, staticLength, dynamicCount]
  | cons atom rest ih =>
      have first := readable atom (by simp)
      have remaining : Expression.Readable rest shape := fun other present => readable other (by simp [present])
      simp only [evaluate, List.length_append, Operand.evaluate_length fits first, ih remaining,
        staticLength, dynamicCount, Nat.add_mul]
      omega

theorem Expression.evaluate_append (left right : Expression) (values : Values) (input : Source)
    (integers : Integer.Store := Integer.emptyStore) :
    (left ++ right).evaluate values input integers = left.evaluate values input integers ++ right.evaluate values input integers := by
  induction left with
  | nil => rfl
  | cons atom rest ih => simp [evaluate, ih, List.append_assoc]

def Expression.evaluateLeft (expression : Expression) (values : Values) (input : Source)
    (integers : Integer.Store := Integer.emptyStore) : Source :=
  expression.foldl (fun accumulated atom => accumulated ++ atom.evaluate values input integers) []

theorem Expression.foldl_evaluate (expression : Expression) (values : Values) (input initial : Source)
    (integers : Integer.Store := Integer.emptyStore) :
    expression.foldl (fun accumulated atom => accumulated ++ atom.evaluate values input integers) initial =
      initial ++ expression.evaluate values input integers := by
  induction expression generalizing initial with
  | nil => simp [evaluate]
  | cons atom rest ih => simp [List.foldl_cons, ih, evaluate, List.append_assoc]

theorem Expression.left_association (expression : Expression) (values : Values) (input : Source)
    (integers : Integer.Store := Integer.emptyStore) :
    expression.evaluateLeft values input integers = expression.evaluate values input integers := by
  simp only [evaluateLeft, foldl_evaluate, List.nil_append]

theorem Expression.evaluate_printable {expression : Expression} {shape : Shape}
    {values : Values} {input : Source} (readable : expression.Readable shape)
    (literals : expression.LiteralsPrintable) (state : Fits shape input values)
    (inputPrintable : Printable input) : Printable (expression.evaluate values input) := by
  induction expression with
  | nil => simp [evaluate, Printable]
  | cons atom rest ih =>
      intro byte present
      simp only [evaluate, List.mem_append] at present
      rcases present with present | present
      · obtain ⟨bound, inferred⟩ := readable atom (by simp)
        exact Bindings.value_printable state inputPrintable inferred (literals atom (by simp)) byte present
      · exact ih (fun other member => readable other (by simp [member]))
          (fun other member => literals other (by simp [member])) byte present

theorem Expression.staticLength_append (left right : Expression) (shape : Shape) :
    (left ++ right).staticLength shape = left.staticLength shape + right.staticLength shape := by
  induction left with
  | nil => simp [staticLength]
  | cons atom rest ih => simp [staticLength, ih, Nat.add_assoc]

theorem Expression.dynamicCount_append (left right : Expression) (shape : Shape) :
    (left ++ right).dynamicCount shape = left.dynamicCount shape + right.dynamicCount shape := by
  induction left with
  | nil => simp [dynamicCount]
  | cons atom rest ih => simp [dynamicCount, ih, Nat.add_assoc]

def Expression.summary (expression : Expression) (shape : Shape) : Summary :=
  ⟨expression.staticLength shape, expression.dynamicCount shape⟩

def Expression.infer (expression : Expression) (shape : Shape) : Option Summary :=
  if expression.all (fun atom => (atom.infer shape).isSome) then some (expression.summary shape) else none

abbrev Expression.PrintableLiterals := Expression.LiteralsPrintable

theorem Expression.infer_iff {expression : Expression} {shape : Shape} {summary : Summary} :
    expression.infer shape = some summary ↔
      expression.Readable shape ∧ expression.summary shape = summary := by
  have all_iff : expression.all (fun atom => (atom.infer shape).isSome) = true ↔
      expression.Readable shape := by
    simp only [List.all_eq_true, Readable, Option.isSome_iff_exists]
  by_cases readable : expression.Readable shape
  · simp only [infer, all_iff.mpr readable, ↓reduceIte, Option.some.injEq, readable, true_and]
  · have absent : expression.all (fun atom => (atom.infer shape).isSome) ≠ true :=
      fun present => readable (all_iff.mp present)
    simp [infer, absent, readable]

theorem Expression.infer_length {expression : Expression} {shape : Shape}
    {values : Values} {input : Source} {summary : Summary}
    (fits : Fits shape input values) (inferred : expression.infer shape = some summary) :
    (expression.evaluate values input).length = summary.length input.length := by
  obtain ⟨readable, rfl⟩ := infer_iff.mp inferred
  exact evaluate_length fits readable

end Silver.Compose

namespace Silver.Bindings
open Compose

structure Declaration where
  index : Nat
  mutable : Bool
  initializer : Expression
  deriving DecidableEq, Repr

def Declaration.extend (declaration : Declaration) (shape : Shape) (bound : Bound) : Shape :=
  put shape declaration.index (some ⟨bound, declaration.mutable⟩)

def Declaration.execute (declaration : Declaration) (values : Values) (input : Source) : Values :=
  put values declaration.index (declaration.initializer.evaluate values input)

def Declaration.Valid (shape : Shape) (declaration : Declaration) (bound : Bound) : Prop :=
  shape declaration.index = none ∧
  declaration.initializer.infer shape = some bound.summary ∧
  declaration.initializer.PrintableLiterals ∧ declaration.initializer ≠ [] ∧
  declaration.initializer.length ≤ maxExpressionOperands ∧
  bound.length maxSourceLength ≤ maxSourceLength

theorem declaration_preserves {shape : Shape} {input : Source} {values : Values}
    (fits : Fits shape input values) (inputPrintable : Printable input)
    {declaration : Declaration} {bound : Bound} (valid : declaration.Valid shape bound) :
    Fits (declaration.extend shape bound) input (declaration.execute values input) := by
  intro index info found
  by_cases same : index = declaration.index
  · subst index
    simp only [Declaration.extend, put_same, Option.some.injEq] at found
    subst info
    simp only [Declaration.execute, put_same]
    exact ⟨(Expression.infer_length fits valid.2.1).trans (bound.summary_length _),
      Expression.evaluate_printable (Expression.infer_iff.mp valid.2.1).1 valid.2.2.1 fits inputPrintable⟩
  · simp only [Declaration.extend, put, same, ↓reduceIte] at found
    simpa only [Declaration.execute, put, same, ↓reduceIte] using fits index info found

theorem declaration_extends {shape : Shape} {declaration : Declaration} {bound : Bound}
    (valid : declaration.Valid shape bound) {index : Nat} {info : CellInfo}
    (present : shape index = some info) : declaration.extend shape bound index = some info := by
  have different : index ≠ declaration.index := by
    intro same
    subst index
    rw [valid.1] at present
    cases present
  simpa only [Declaration.extend, put_other _ _ _ _ different] using present

theorem declaration_snapshots (values : Values) (input : Source)
    (index source : Nat) (mutable : Bool) :
    (Declaration.execute ⟨index, mutable, [.reference source]⟩ values input) index = values source := by
  simp [Declaration.execute, Expression.evaluate, Value.evaluate, put]

theorem snapshot_survives_source_write (values : Values) (input replacement : Source)
    (index source : Nat) (mutable : Bool) (different : index ≠ source) :
    put (Declaration.execute ⟨index, mutable, [.reference source]⟩ values input)
      source replacement index = values source := by
  simp [put, different, Declaration.execute, Expression.evaluate, Value.evaluate]

structure Assignment where
  target : Nat
  value : Expression
  deriving DecidableEq, Repr

def Assignment.Valid (shape : Shape) (assignment : Assignment) : Prop :=
  ∃ bound, shape assignment.target = some ⟨bound, true⟩ ∧
    assignment.value.infer shape = some bound.summary ∧ assignment.value.PrintableLiterals

def Assignment.execute (assignment : Assignment) (values : Values) (input : Source) : Values :=
  put values assignment.target (assignment.value.evaluate values input)

theorem assignment_length {shape : Shape} {input : Source} {values : Values}
    (fits : Fits shape input values) {assignment : Assignment}
    (valid : assignment.Valid shape) :
    (assignment.value.evaluate values input).length = (values assignment.target).length := by
  obtain ⟨bound, target, inferred, _⟩ := valid
  exact ((Expression.infer_length fits inferred).trans (bound.summary_length _)).trans
    (fits assignment.target _ target).1.symm

theorem assignment_preserves {shape : Shape} {input : Source} {values : Values}
    (fits : Fits shape input values) (inputPrintable : Printable input)
    {assignment : Assignment} (valid : assignment.Valid shape) :
    Fits shape input (assignment.execute values input) := by
  obtain ⟨bound, target, inferred, literals⟩ := valid
  intro index info found
  by_cases same : index = assignment.target
  · subst index
    rw [target] at found
    cases found
    simp only [Assignment.execute, put_same]
    exact ⟨(Expression.infer_length fits inferred).trans (bound.summary_length _),
      Expression.evaluate_printable (Expression.infer_iff.mp inferred).1 literals fits inputPrintable⟩
  · simpa only [Assignment.execute, put, same, ↓reduceIte] using fits index info found

theorem assignment_preserves_other (assignment : Assignment) (values : Values)
    (input : Source) (index : Nat) (different : index ≠ assignment.target) :
    assignment.execute values input index = values index := by
  simp [Assignment.execute, put, different]

def executeDeclarations (input : Source) : List Declaration → Values → Values
  | [], values => values
  | declaration :: rest, values => executeDeclarations input rest (declaration.execute values input)

inductive DeclarationsValid : Shape → List Declaration → Shape → Prop
  | nil (shape) : DeclarationsValid shape [] shape
  | cons {shape final declaration rest bound} : declaration.Valid shape bound →
      DeclarationsValid (declaration.extend shape bound) rest final →
      DeclarationsValid shape (declaration :: rest) final

theorem declarations_extend {initial final : Shape} {declarations : List Declaration}
    (valid : DeclarationsValid initial declarations final) {index : Nat} {info : CellInfo}
    (present : initial index = some info) : final index = some info := by
  induction valid with
  | nil => exact present
  | cons first rest ih => exact ih (declaration_extends first present)

theorem declarations_preserve {initial final : Shape} {declarations : List Declaration}
    (valid : DeclarationsValid initial declarations final) (input : Source)
    (inputPrintable : Printable input) (values : Values) (fits : Fits initial input values) :
    Fits final input (executeDeclarations input declarations values) := by
  induction valid generalizing values with
  | nil => exact fits
  | cons first rest ih =>
      exact ih _ (declaration_preserves fits inputPrintable first)

end Silver.Bindings
