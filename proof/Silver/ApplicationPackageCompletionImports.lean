module

public import Silver.ApplicationPackageCompletionBodyImports
public import Silver.ApplicationPackageCompletionTotal

@[expose] public section

namespace Silver.ApplicationPackageCompletion
open Compose Compose.Expressions Predicate ApplicationPackages ApplicationPackageBodies ApplicationPackageDeclarations
open ApplicationPackageFrames ApplicationPackageNames

set_option backward.dsimp.instances true

theorem completionOutputs_congr (actual model : CompletionCalls) (text : Source) (globals : ParserState)
    (info : PackageBindings.Metadata) (index : Nat) (item : PackageBindings.Routine) (localFrame : InitializationFrame)
    (beginEq : actual.takeToken text localFrame.frame.position (.word "begin") = model.takeToken text localFrame.frame.position (.word "begin"))
    (initializersEq : let state := {localFrame with frame := {localFrame.frame with position := model.takeToken text localFrame.frame.position (.word "begin")}}
      outputInitializers actual text info (formalIndices item) state = outputInitializers model text info (formalIndices item) state)
    (appendEq : ∀ initialized, outputInitializers model text info (formalIndices item)
        {localFrame with frame := {localFrame.frame with position := model.takeToken text localFrame.frame.position (.word "begin")}} = some initialized →
      appendOutputs actual text info (formalIndices item) initialized.frame = appendOutputs model text info (formalIndices item) initialized.frame)
    (bodyEq : ∀ initialized completedFrame, outputInitializers model text info (formalIndices item)
        {localFrame with frame := {localFrame.frame with position := model.takeToken text localFrame.frame.position (.word "begin")}} = some initialized →
      appendOutputs model text info (formalIndices item) initialized.frame = some completedFrame →
      completionBody actual text globals info index item {initialized with frame := completedFrame} =
        completionBody model text globals info index item {initialized with frame := completedFrame}) :
    completionOutputs actual text globals info index item localFrame = completionOutputs model text globals info index item localFrame := by
  dsimp only [completionOutputs]
  rw [beginEq, initializersEq]
  cases initialized : outputInitializers model text info (formalIndices item)
      {localFrame with frame := {localFrame.frame with position := model.takeToken text localFrame.frame.position (.word "begin")}} with
  | none => rfl
  | some state =>
    dsimp only
    rw [appendEq state initialized]
    cases appended : appendOutputs model text info (formalIndices item) state.frame with
    | none => rfl
    | some completedFrame => exact bodyEq state completedFrame initialized appended

theorem completionLocals_congr (actual model : CompletionCalls) (fuel : Nat) (text : Source) (globals : ParserState)
    (info : PackageBindings.Metadata) (index : Nat) (item : PackageBindings.Routine) (state : InitializationFrame)
    (localsEq : localsFuel (localStep actual text info item) fuel state = localsFuel (localStep model text info item) fuel state)
    (outputsEq : ∀ localFrame, localsFuel (localStep model text info item) fuel state = some (some localFrame) →
      completionOutputs actual text globals info index item localFrame = completionOutputs model text globals info index item localFrame) :
    completionLocals actual fuel text globals info index item state = completionLocals model fuel text globals info index item state := by
  dsimp only [completionLocals]
  rw [localsEq]
  cases evaluated : localsFuel (localStep model text info item) fuel state with
  | none => rfl
  | some outcome =>
    cases outcome with
    | none => rfl
    | some localFrame => exact congrArg some (outputsEq localFrame evaluated)

theorem packageCompletionFuel_congr (actual model : CompletionCalls) (fuel : Nat) (text : Source)
    (globals : ParserState) (info : PackageBindings.Metadata)
    (signatureEq : actual.signatureAt text globals info true = model.signatureAt text globals info true)
    (frameEq : let signed := model.signatureAt text globals info true
      actual.routineFrame text globals signed.info (info.completed + 1) signed.header.position =
        model.routineFrame text globals signed.info (info.completed + 1) signed.header.position)
    (localsEq : let signed := model.signatureAt text globals info true
      let index := info.completed + 1
      let item := signed.info.routineAt index
      let frame := model.routineFrame text globals signed.info index signed.header.position
      completionLocals actual fuel text globals signed.info index item {frame} =
        completionLocals model fuel text globals signed.info index item {frame}) :
    packageCompletionFuel actual fuel text globals info = packageCompletionFuel model fuel text globals info := by
  dsimp only [packageCompletionFuel]
  split
  · rfl
  · rw [signatureEq]
    split
    · rfl
    · split
      · rfl
      · rw [frameEq]
        split
        · rfl
        · exact localsEq

namespace Library

theorem outputs (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (globals : ParserState) (info : PackageBindings.Metadata) (typed : info.Typed)
    (index : Nat) (item : PackageBindings.Routine) (itemTyped : item.Typed)
    (localFrame : InitializationFrame) (framed : ReaderFrame text localFrame.frame) :
    completionOutputs (library.calls reader) text globals info index item localFrame =
      completionOutputs (library.model reader) text globals info index item localFrame := by
  have entered : ReaderFrame text {localFrame.frame with position := tokenAfter text localFrame.frame.position (.word "begin")} :=
    framed.at_position (fixedAfter_result_bound text _ "begin" true (by decide))
  apply completionOutputs_congr
  · exact library.take reader valid _ framed.cursor _ (by unfold ValidToken; decide)
  · exact library.output_initializers reader valid info typed _ _ entered
  · intro initialized parsed
    have ready := output_initializers_frame reader (LeafLibraries.model (library.calls reader)) info _ _ initialized entered parsed
    exact library.append_outputs reader text info typed _ initialized.frame (OutputFrame.of_reader valid ready)
  · intro initialized completedFrame parsed appended
    have ready := output_initializers_frame reader (LeafLibraries.model (library.calls reader)) info _ _ initialized entered parsed
    have complete := append_outputs_frame reader (LeafLibraries.model (library.calls reader)) text info
      (ApplicationPackageRoutineFrame.parameterBounds_of_typed typed) _ initialized.frame completedFrame
      (OutputFrame.of_reader valid ready) appended
    exact library.body reader valid globals info typed index item itemTyped _ complete

theorem locals (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (globals : ParserState) (info : PackageBindings.Metadata) (typed : info.Typed)
    (index : Nat) (item : PackageBindings.Routine) (itemTyped : item.Typed)
    (fuel : Nat) (state : InitializationFrame) (framed : ReaderFrame text state.frame) :
    completionLocals (library.calls reader) fuel text globals info index item state =
      completionLocals (library.model reader) fuel text globals info index item state := by
  apply completionLocals_congr
  · exact library.locals_fuel reader valid info item fuel state framed
  · intro localFrame parsed
    have ready := locals_frame reader (LeafLibraries.model (library.calls reader)) valid info item fuel state localFrame framed parsed
    exact library.outputs reader valid globals info typed index item itemTyped localFrame ready

/-- Whole Completion import transport includes rejected headers and partial
Signature writes. All later callee domains follow from the original branches,
native metadata subtypes and the established ReaderFrame invariants. -/
theorem completion_fuel (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (globals : ParserState) (framed : ReaderFrame text globals)
    (info : PackageBindings.Metadata) (typed : info.Typed) (fuel : Nat) :
    packageCompletionFuel (library.calls reader) fuel text globals info =
      packageCompletionFuel (library.model reader) fuel text globals info := by
  apply packageCompletionFuel_congr
  · exact library.signature_at reader valid globals framed info true
  · exact library.routine_frame reader valid globals framed _ _ _ (readSignature_header_cursor text globals info true)
  · have signatureTyped := readSignature_completion_typed valid globals framed info typed
    exact library.locals reader valid globals _ signatureTyped _ _ (MetadataTypes.routine_at signatureTyped _)
      fuel _ (entry_reader reader (LeafLibraries.model (library.calls reader)) valid globals framed info typed)

theorem completion_read (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (globals : ParserState) (framed : ReaderFrame text globals)
    (info : PackageBindings.Metadata) (typed : info.Typed) :
    packageCompletionFuel (library.calls reader) (text.length + 2) text globals info =
      some (readCompletion reader (LeafLibraries.model (library.calls reader)) text globals info) := by
  rw [library.completion_fuel reader valid globals framed info typed]
  exact readCompletion_eq reader (LeafLibraries.model (library.calls reader)) text globals info

end Library
end Silver.ApplicationPackageCompletion
