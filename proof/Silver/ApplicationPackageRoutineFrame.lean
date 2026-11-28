module

public import Silver.ApplicationPackageBodiesCompletion
public import Silver.ApplicationPackageFrameLoops

@[expose] public section

/-! Routine_Frame's full native domain includes arbitrary metadata. The active
routine guard precedes every observation of Item; the constant's elaborated
inactive physical cell therefore cannot affect a returning result. -/
namespace Silver.ApplicationPackageRoutineFrame
open Compose ApplicationPackageBodies

structure Calls where
  bodyEnvironment : ScalarExpression.Environment → ScalarExpression.Environment
  validName : Source → PackageBindings.NameSpan → Bool
  hideOuter : Source → ParserState → PackageBindings.Metadata → PackageBindings.NameSpan → ParserState
  appendFormal : ParserState → PackageBindings.NameSpan → ApplicationPackageNames.PackageTypeResult →
    ProcedureBindings.Mode → ParserState
  validState : Source → ParserState → Bool

def forgetMutable (binding : BooleanBindings.Binding) : BooleanBindings.Binding :=
  if binding.mutable then {binding with known := false} else binding

def entryFrame (calls : Calls) (globals : ParserState) (position : Nat) : ParserState :=
  {globals with
    position, pure := true, scalarNames := calls.bodyEnvironment globals.scalarNames
    booleanNames := globals.booleanNames.map forgetMutable}

def hideParameter (calls : Calls) (text : Source) (info : PackageBindings.Metadata)
    (frame : ParserState) (index : Nat) : Option ParserState :=
  let parameter := info.parameterAt index
  if !calls.validName text parameter.bodyName then none
  else
    let result := calls.hideOuter text frame info parameter.bodyName
    if result.position = 0 then none else some result

def appendParameter (calls : Calls) (info : PackageBindings.Metadata)
    (frame : ParserState) (index : Nat) : Option ParserState :=
  let parameter := info.parameterAt index
  if parameter.mode = .output then some frame
  else
    let mark : ApplicationPackageNames.PackageTypeResult :=
      ⟨parameter.bodyTypeName, parameter.bodyTypeName.after, parameter.kind, parameter.bounds, parameter.typeIdentity⟩
    let result := calls.appendFormal frame parameter.bodyName mark parameter.mode
    if result.position = 0 then none else some result

def parameters (step : ParserState → Nat → Option ParserState) : List Nat → ParserState → Option ParserState
  | [], frame => some frame
  | index :: rest, frame => (step frame index).bind (parameters step rest)

def withItem (calls : Calls) (text : Source) (globals : ParserState) (info : PackageBindings.Metadata)
    (routine position : Nat) (item : PackageBindings.Routine) : ParserState :=
  if routine > info.routines.length then invalidState
  else
    let initial := entryFrame calls globals position
    if formalRangeRejected info item then invalidState
    else
      match parameters (hideParameter calls text info) (formalIndices item) initial with
      | none => invalidState
      | some hidden =>
          match parameters (appendParameter calls info) (formalIndices item) hidden with
          | none => invalidState
          | some result => if calls.validState text result then result else invalidState

def routineFrame (calls : Calls) (text : Source) (globals : ParserState) (info : PackageBindings.Metadata)
    (routine position : Nat) : ParserState :=
  withItem calls text globals info routine position (info.routineAt routine)

theorem inactive_item_unobserved (calls : Calls) (text : Source) (globals : ParserState)
    (info : PackageBindings.Metadata) (routine position : Nat) (first second : PackageBindings.Routine)
    (inactive : info.routines.length < routine) :
    withItem calls text globals info routine position first =
      withItem calls text globals info routine position second := by
  simp only [withItem, inactive, ↓reduceIte]

theorem inactive_rejected (calls : Calls) (text : Source) (globals : ParserState)
    (info : PackageBindings.Metadata) (routine position : Nat) (inactive : info.routines.length < routine) :
    routineFrame calls text globals info routine position = invalidState := by
  simp only [routineFrame, withItem, inactive, ↓reduceIte]

theorem formalIndices_bounded (info : PackageBindings.Metadata) (item : PackageBindings.Routine)
    (valid : formalRangeRejected info item = false) (index : Nat) (member : index ∈ formalIndices item) :
    0 < index ∧ index ≤ info.parameters.length := by
  simp only [formalIndices, List.mem_map, List.mem_range] at member
  obtain ⟨offset, bounded, rfl⟩ := member
  simp only [formalRangeRejected, decide_eq_false_iff_not] at valid
  omega

end Silver.ApplicationPackageRoutineFrame
