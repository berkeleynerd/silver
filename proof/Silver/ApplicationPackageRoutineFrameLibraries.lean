module

public import Silver.ApplicationPackageRoutineFrameDomains
public import Silver.ScalarEnvironmentSourceBridge

@[expose] public section

namespace Silver.ApplicationPackageRoutineFrame
open Compose Compose.Expressions ApplicationPackageFrames ApplicationPackageDeclarations ApplicationPackageNames

set_option backward.dsimp.instances true

namespace StorageProjection

def scalars (names : ScalarExpression.Environment) (inactive : Nat → ScalarExpression.Binding) :
    ScalarExpression.EnvironmentSourceBridge.Storage :=
  ⟨names.length, fun index => names[index - 1]?.getD (inactive index)⟩

theorem scalars_active (names : ScalarExpression.Environment) (inactive : Nat → ScalarExpression.Binding) :
    (scalars names inactive).active = names := by
  apply List.ext_getElem (by simp [ScalarExpression.EnvironmentSourceBridge.Storage.active, scalars])
  intro index _ _
  simp [ScalarExpression.EnvironmentSourceBridge.Storage.active, scalars]

def table (items : List α) (capacity : Nat) (inactive : Nat → α) : Storage.Table α :=
  ⟨items.length, items ++ (List.range (capacity - items.length)).map (fun index => inactive (items.length + index))⟩

theorem table_active (items : List α) (capacity : Nat) (inactive : Nat → α) :
    (table items capacity inactive).active = items := by
  simp [Storage.Table.active, table]

def frame (state : ParserState) (scalars : Nat → ScalarExpression.Binding)
    (booleans : Nat → BooleanBindings.Binding) : AppendContract.NativeFrame :=
  ⟨state, table state.scalarNames ScalarExpression.maxBindings scalars,
    table state.booleanNames BooleanBindings.maxBindings booleans⟩

theorem frame_active (state : ParserState) (scalars : Nat → ScalarExpression.Binding)
    (booleans : Nat → BooleanBindings.Binding) : (frame state scalars booleans).active = state := by
  simp only [AppendContract.NativeFrame.active, frame, table_active]

theorem frame_represented {state : ParserState} (scalarCount : state.scalarNames.length ≤ ScalarExpression.maxBindings)
    (booleanCount : state.booleanNames.length ≤ BooleanBindings.maxBindings)
    (scalars : Nat → ScalarExpression.Binding) (booleans : Nat → BooleanBindings.Binding) :
    (frame state scalars booleans).Represented := by
  constructor <;> simp only [frame, table, List.length_append, List.length_map, List.length_range] <;> omega

end StorageProjection

/-- Native full-storage contract interpretations. The arbitrary inactive cells
are retained by the projections; neither import assumes a valid parser state or
nonempty formal bounds. Append's actual name precondition remains explicit. -/
structure Library where
  names : NameLibraries
  bodyEnvironment : ScalarExpression.EnvironmentSourceBridge.Storage → ScalarExpression.EnvironmentSourceBridge.Storage
  bodySource : ScalarExpression.EnvironmentSourceBridge.InterpretedBodyEnvironment bodyEnvironment
  append : AppendContract.NativeFrame → PackageBindings.NameSpan → PackageTypeResult →
    ProcedureBindings.Mode → AppendContract.NativeFrame
  appendSource : ∀ old name mark mode, old.Represented → 0 < name.first → name.first < name.after →
    append old name mark mode = AppendContract.result old name mark mode
  scalarInactive : ParserState → Nat → ScalarExpression.Binding
  booleanInactive : ParserState → Nat → BooleanBindings.Binding
  bodyInactive : ScalarExpression.Environment → Nat → ScalarExpression.Binding

namespace Library

def body (library : Library) (names : ScalarExpression.Environment) : ScalarExpression.Environment :=
  (library.bodyEnvironment (StorageProjection.scalars names (library.bodyInactive names))).active

theorem body_meaning (library : Library) (names : ScalarExpression.Environment)
    (bounded : names.length ≤ ScalarExpression.maxBindings) :
    library.body names = ScalarExpression.bodyEnvironment names := by
  rw [body, ScalarExpression.EnvironmentSourceBridge.interpreted_bodyEnvironment
    library.bodyEnvironment library.bodySource _ bounded, StorageProjection.scalars_active]

def appendFormal (library : Library) (state : ParserState) (name : PackageBindings.NameSpan)
    (mark : PackageTypeResult) (mode : ProcedureBindings.Mode) : ParserState :=
  (library.append (StorageProjection.frame state (library.scalarInactive state) (library.booleanInactive state))
    name mark mode).active

theorem append_meaning (library : Library) (state : ParserState) (prior : AppendFrame state)
    (name : PackageBindings.NameSpan) (mark : PackageTypeResult) (mode : ProcedureBindings.Mode)
    (positive : 0 < name.first) (ordered : name.first < name.after) :
    library.appendFormal state name mark mode = ApplicationPackageDeclarations.appendFormal state name mark mode := by
  have represented := StorageProjection.frame_represented prior.scalarCount prior.booleanCount
    (library.scalarInactive state) (library.booleanInactive state)
  rw [appendFormal, library.appendSource _ name mark mode represented positive ordered,
    AppendContract.active_result _ represented, StorageProjection.frame_active]

def calls (library : Library) : Calls where
  bodyEnvironment := library.body
  validName text := library.names.shared.packages.validName (metadataText text)
  hideOuter := library.names.hideOuter
  appendFormal := library.appendFormal
  validState := ApplicationPackageFrames.Native.frameCalls library.names.shared library.names.validity _ .validState

theorem entry (library : Library) {text : Source} (globals : ParserState) (framed : ReaderFrame text globals)
    (position : Nat) : entryFrame library.calls globals position = entryFrame modelCalls globals position := by
  dsimp only [entryFrame, calls, modelCalls]
  rw [library.body_meaning globals.scalarNames framed.typed.scalarCount]

theorem valid_state (library : Library) {text : Source} (valid : ValidText text) (frame : ParserState)
    (typed : ValidityNative.ImportedTypes frame) : library.calls.validState text frame = stateValid text frame :=
  ApplicationPackageFrames.Native.frameCalls_valid library.names.shared library.names.validity text valid frame typed

end Library
end Silver.ApplicationPackageRoutineFrame
