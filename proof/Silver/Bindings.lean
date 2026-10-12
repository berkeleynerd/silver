module

public import Silver.ArgumentsRuntime

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

inductive Value
  | literal (bytes : Source)
  | reference (index : Nat)
  | argument
  deriving DecidableEq, Repr

def Value.evaluate (values : Values) (input : Source) : Value → Source
  | .literal bytes => bytes
  | .reference index => values index
  | .argument => input

def Value.infer (shape : Shape) : Value → Option Bound
  | .literal bytes => some (.fixed bytes.length)
  | .reference index => (shape index).map CellInfo.bound
  | .argument => some .argument

def Value.PrintableLiterals : Value → Prop
  | .literal bytes => Printable bytes
  | _ => True

theorem value_length {shape : Shape} {input : Source} {values : Values}
    (fits : Fits shape input values) {value : Value} {bound : Bound}
    (inferred : value.infer shape = some bound) :
    (value.evaluate values input).length = bound.length input.length := by
  cases value with
  | literal bytes => cases inferred; rfl
  | argument => cases inferred; rfl
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
  | reference index =>
      simp only [Value.infer, Option.map_eq_some_iff] at inferred
      obtain ⟨info, found, _⟩ := inferred
      exact (fits index info found).2

structure Declaration where
  index : Nat
  mutable : Bool
  initializer : Value
  deriving DecidableEq, Repr

def Declaration.extend (declaration : Declaration) (shape : Shape) (bound : Bound) : Shape :=
  put shape declaration.index (some ⟨bound, declaration.mutable⟩)

def Declaration.execute (declaration : Declaration) (values : Values) (input : Source) : Values :=
  put values declaration.index (declaration.initializer.evaluate values input)

def Declaration.Valid (shape : Shape) (declaration : Declaration) (bound : Bound) : Prop :=
  shape declaration.index = none ∧
  declaration.initializer.infer shape = some bound ∧
  declaration.initializer.PrintableLiterals

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
    exact ⟨value_length fits valid.2.1,
      value_printable fits inputPrintable valid.2.1 valid.2.2⟩
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
    (Declaration.execute ⟨index, mutable, .reference source⟩ values input) index = values source := by
  simp [Declaration.execute, Value.evaluate, put]

theorem snapshot_survives_source_write (values : Values) (input replacement : Source)
    (index source : Nat) (mutable : Bool) (different : index ≠ source) :
    put (Declaration.execute ⟨index, mutable, .reference source⟩ values input)
      source replacement index = values source := by
  simp [put, different, Declaration.execute, Value.evaluate]

structure Assignment where
  target : Nat
  value : Value
  deriving DecidableEq, Repr

def Assignment.Valid (shape : Shape) (assignment : Assignment) : Prop :=
  ∃ bound, shape assignment.target = some ⟨bound, true⟩ ∧
    assignment.value.infer shape = some bound ∧ assignment.value.PrintableLiterals

def Assignment.execute (assignment : Assignment) (values : Values) (input : Source) : Values :=
  put values assignment.target (assignment.value.evaluate values input)

theorem assignment_length {shape : Shape} {input : Source} {values : Values}
    (fits : Fits shape input values) {assignment : Assignment}
    (valid : assignment.Valid shape) :
    (assignment.value.evaluate values input).length = (values assignment.target).length := by
  obtain ⟨bound, target, inferred, _⟩ := valid
  exact (value_length fits inferred).trans (fits assignment.target _ target).1.symm

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
    exact ⟨value_length fits inferred, value_printable fits inputPrintable inferred literals⟩
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
