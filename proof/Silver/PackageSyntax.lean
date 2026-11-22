module

public import Silver.PackageReindex

@[expose] public section

/-! Resolved package frames distinguish persistent state from invocation-local
storage. A phase-specific layout gives each existing scalar-tree identity its
actual declaration location. This records shadowing without changing source
bytes or treating a hidden global as the local declaration which hides it. -/
namespace Silver.Packages
open ScalarFunctions (Frame Value ScalarType Actual)

/-- Package routine identities share one completion-order table across both
kinds. Main-local callable tables keep their existing separate identities. -/
inductive RoutineSignature
  | function (signature : ScalarFunctions.Signature)
  | procedure (signature : ScalarProcedures.Signature)
  deriving DecidableEq, Repr

def lookupRoutine {α : Type} (earlier : List α) (identity : Nat) : Option α :=
  if identity = 0 then none else earlier[identity - 1]?

theorem lookupRoutine_before {α : Type} {earlier : List α} {identity : Nat} {routine : α}
    (found : lookupRoutine earlier identity = some routine) :
    0 < identity ∧ identity ≤ earlier.length := by
  by_cases zero : identity = 0
  · simp [lookupRoutine, zero] at found
  · simp only [lookupRoutine, zero, ↓reduceIte] at found
    have inside := (List.getElem?_eq_some_iff.mp found).1
    omega

def resolveProcedure (signatures : List RoutineSignature) (call : ScalarProcedures.Call) :
    Option ScalarProcedures.ResolvedCall :=
  (lookupRoutine signatures call.callee).bind fun routine =>
    match routine with
    | .function _ => none
    | .procedure signature =>
        (ScalarProcedures.bindActuals signature.formals call.actuals).map fun actuals => ⟨signature, actuals⟩

inductive Address
  | global (identity : Nat)
  | local (identity : Nat)
  deriving DecidableEq, Repr

inductive Place
  | global (cell : Cell)
  | local (cell : Cell)
  deriving DecidableEq, Repr

def Place.cell : Place → Cell
  | .global cell | .local cell => cell

structure FrameLayout where
  integers : Nat → Address
  booleans : Nat → Address

def FrameLayout.place (layout : FrameLayout) : Cell → Place
  | .integer identity => match layout.integers identity with
      | .global index => .global (.integer index)
      | .local index => .local (.integer index)
  | .boolean identity => match layout.booleans identity with
      | .global index => .global (.boolean index)
      | .local index => .local (.boolean index)

def FrameLayout.InjectiveOn (layout : FrameLayout) (domain : List Cell) : Prop :=
  ∀ left ∈ domain, ∀ right ∈ domain, layout.place left = layout.place right → left = right

def FrameLayout.ofRenaming (mapping : Renaming) : FrameLayout :=
  ⟨fun index => .local (mapping.integers index), fun index => .local (mapping.booleans index)⟩

structure SharedState where
  globals : Frame
  locals : Frame

def SharedState.read (state : SharedState) : Place → Value
  | .global cell => readCell state.globals cell
  | .local cell => readCell state.locals cell

def SharedState.write (state : SharedState) (place : Place) (value : Value) : SharedState :=
  match place with
  | .global cell => {state with globals := writeCell state.globals cell value}
  | .local cell => {state with locals := writeCell state.locals cell value}

def SharedState.integer (state : SharedState) : Address → Int
  | .global index => state.globals.integers index
  | .local index => state.locals.integers index

def SharedState.boolean (state : SharedState) : Address → Bool
  | .global index => state.globals.booleans index
  | .local index => state.locals.booleans index

def SharedState.view (state : SharedState) (layout : FrameLayout) : Frame :=
  ⟨fun index => state.integer (layout.integers index),
    fun index => state.boolean (layout.booleans index)⟩

theorem SharedState.read_kind (state : SharedState) (place : Place) :
    CellValue place.cell (state.read place) := by
  cases place <;> exact readCell_kind ..

theorem SharedState.read_write_same {place : Place} {value : Value}
    (typed : CellValue place.cell value) (state : SharedState) :
    (state.write place value).read place = value := by
  cases place <;> exact readCell_write_same typed _

theorem SharedState.read_write_other {place other : Place} (apart : other ≠ place)
    (value : Value) (state : SharedState) :
    (state.write place value).read other = state.read other := by
  cases place with
  | global cell =>
      cases other with
      | global other => exact readCell_write_other (by simpa using apart) _ _
      | «local» => rfl
  | «local» cell =>
      cases other with
      | global => rfl
      | «local» other => exact readCell_write_other (by simpa using apart) _ _

theorem FrameLayout.place_kind (layout : FrameLayout) (cell : Cell) :
    SameKind cell (layout.place cell).cell := by
  cases cell with
  | integer index => cases located : layout.integers index <;> simp [place, located, Place.cell, SameKind]
  | boolean index => cases located : layout.booleans index <;> simp [place, located, Place.cell, SameKind]

theorem FrameLayout.place_value {layout : FrameLayout} {cell : Cell} {value : Value}
    (typed : CellValue cell value) : CellValue (layout.place cell).cell value := by
  cases cell with
  | integer index =>
      cases located : layout.integers index <;> cases value <;> simp_all [CellValue, FrameLayout.place, Place.cell]
  | boolean index =>
      cases located : layout.booleans index <;> cases value <;> simp_all [CellValue, FrameLayout.place, Place.cell]

theorem SharedState.view_read (state : SharedState) (layout : FrameLayout) (cell : Cell) :
    readCell (state.view layout) cell = state.read (layout.place cell) := by
  cases cell with
  | integer index =>
      cases located : layout.integers index <;> simp [view, integer, readCell, FrameLayout.place, read, located]
  | boolean index =>
      cases located : layout.booleans index <;> simp [view, boolean, readCell, FrameLayout.place, read, located]

def FrameLayout.AgreesOn (layout : FrameLayout) (mapping : Renaming) (domain : List Cell)
    (shared : SharedState) (closed : Frame) : Prop :=
  mapping.AgreesOn domain (shared.view layout) closed

theorem FrameLayout.AgreesOn.write {layout : FrameLayout} {mapping : Renaming}
    {domain : List Cell} {shared : SharedState} {closed : Frame}
    (same : layout.AgreesOn mapping domain shared closed)
    (sourceUnique : layout.InjectiveOn domain) (closedUnique : mapping.InjectiveOn domain)
    {target : Cell} (inside : target ∈ domain) {value : Value} (typed : CellValue target value) :
    layout.AgreesOn mapping domain (shared.write (layout.place target) value)
      (writeCell closed (mapping.cell target) value) := by
  intro cell member
  rw [SharedState.view_read]
  by_cases equal : cell = target
  · subst cell
    rw [readCell_write_same (Renaming.cell_value typed),
      SharedState.read_write_same (FrameLayout.place_value typed)]
  · have closedApart : mapping.cell cell ≠ mapping.cell target :=
      fun bad => equal (closedUnique cell member target inside bad)
    have sourceApart : layout.place cell ≠ layout.place target :=
      fun bad => equal (sourceUnique cell member target inside bad)
    rw [readCell_write_other closedApart, SharedState.read_write_other sourceApart]
    exact (same cell member).trans (shared.view_read layout cell)

/-- Each initializer carries the name-resolution layout in force at its own
source position. Its target is a fresh invocation-local declaration. -/
structure LocalInitializer where
  target : Cell
  domain : ScalarType
  value : Actual
  layout : FrameLayout

def LocalInitializer.Valid (item : LocalInitializer) : Prop :=
  CellDomain item.target item.domain ∧ item.domain.Valid ∧
    ScalarFunctions.scalarActual item.value = true

structure InputBinding where
  target : Cell
  domain : ScalarType
  deriving DecidableEq, Repr

def InputBinding.Valid (binding : InputBinding) : Prop :=
  CellDomain binding.target binding.domain ∧ binding.domain.Valid

def bindInputs : Frame → List InputBinding → List Value → Frame
  | frame, binding :: bindings, value :: values =>
      bindInputs (writeCell frame binding.target value) bindings values
  | frame, _, _ => frame

def initializeLocals : SharedState → List LocalInitializer → SharedState
  | state, [] => state
  | state, item :: rest =>
      let value := item.value.evaluate (scalarState (state.view item.layout))
      initializeLocals (state.write (.local item.target) value) rest

/-- Inputs, including capture values, are bound before sequential local
initialization. The global store is not reinitialized at routine entry. -/
def invocationFrame (globals : Frame) (bindings : List InputBinding) (values : List Value)
    (locals : List LocalInitializer) : SharedState :=
  initializeLocals ⟨globals, bindInputs ⟨Integer.emptyStore, Boolean.emptyStore⟩ bindings values⟩ locals

theorem initializeLocals_globals (state : SharedState) (locals : List LocalInitializer) :
    (initializeLocals state locals).globals = state.globals := by
  induction locals generalizing state with
  | nil => rfl
  | cons item rest ih => exact ih _

theorem invocationFrame_globals (globals : Frame) (bindings : List InputBinding)
    (values : List Value) (locals : List LocalInitializer) :
    (invocationFrame globals bindings values locals).globals = globals :=
  initializeLocals_globals _ _

end Silver.Packages
