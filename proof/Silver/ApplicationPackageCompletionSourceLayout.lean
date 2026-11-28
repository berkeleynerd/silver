module

public import Silver.ApplicationPackageCompletionFrameHistory
public import Silver.ApplicationPackageFrameCapacity
public import Silver.ApplicationPackageDeclarationsCompletionSpans
public import Silver.ApplicationPackageDeclarationsSignatureStates

@[expose] public section

namespace Silver.ApplicationPackageBodies
open Compose Predicate ApplicationPackageDeclarations ApplicationPackageObjectRows ApplicationPackageFormalStorage
open ApplicationPackageFrameLayout

def routineFrameReaders : ApplicationPackageRoutineFrame.Calls where
  bodyEnvironment := ScalarExpression.bodyEnvironment
  validName text := PackageBindings.validName (ApplicationPackageNames.metadataText text)
  hideOuter := ApplicationPackageFrames.hideOuter
  appendFormal := appendFormal
  validState := ApplicationPackageFrames.stateValid

/-- Substitute the original declaration, token and context readers. The
remaining application statement and effect calls stay explicit. -/
def declarationReaders (staticBoolean : BooleanElaboration.Native.Reader) (calls : CompletionCalls) : CompletionCalls :=
  {calls with
    signatureAt := readSignature
    routineFrame := ApplicationPackageRoutineFrame.routineFrame routineFrameReaders
    objectAt := fun text frame info isLocal => objectStep (modelObjectCalls staticBoolean) text frame info isLocal
    takeToken := tokenAfter
    skipAt := skipAt
    nameAfter := Compose.nameAfter
    validName := fun text => PackageBindings.validName (ApplicationPackageNames.metadataText text)
    sameName := fun text => PackageBindings.sameName (ApplicationPackageNames.metadataText text)
    contextOf := Predicate.contextOf
    bodyOf := Predicate.bodyOf
    appendFormal := ApplicationPackageDeclarations.appendFormal
    validState := ApplicationPackageFrames.stateValid}

theorem CompletionFrames.source_layout {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : PackageBindings.Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    (present : result.globals.position ≠ 0) (initial : StateFrame info.states globals)
    (capacity : globals.scalarNames.length ≤ ScalarExpression.maxBindings) :
    let context := completionContextOf (declarationReaders reader calls) frames.outputs.body
    (layout text.length frames.signature.info context).Context frames.signature.info.stateSchema context.analysis := by
  have signed : readSignature text globals info true = frames.signature := frames.signed
  have order := signed ▸ readSignature_completed_order text globals info (signed ▸ frames.headerPresent)
  have window := HeaderWindow.of_offsets order.progress order.formals.span order.formals.before
  have states : frames.signature.info.states = info.states := signed ▸ readSignature_states text globals info true
  have entered : ApplicationPackageRoutineFrame.routineFrame routineFrameReaders text globals frames.signature.info
      (info.completed + 1) frames.signature.header.position = frames.entry := frames.entered
  have entry := routineFrame_source (calls := routineFrameReaders) rfl rfl rfl (states ▸ initial) window entered frames.entryPresent
  have localScope := entry.locals (reader := reader) frames.declarations (fun _ _ => rfl)
  have entrySize := routineFrame_capacity (calls := routineFrameReaders) rfl rfl rfl entered frames.entryPresent capacity
  have localSize := localHistory_capacity (reader := reader) frames.declarations (fun _ _ => rfl) entrySize
  have finalSize := outputFrame_capacity frames.outputs rfl localSize
  have bounded := completionBody_cursor (calls := declarationReaders reader calls) rfl (frames.executed ▸ present)
  exact frames.outputs.layout localScope frames.declarations.at_begin rfl rfl rfl bounded finalSize

theorem packageCompletionFuel_source_layout (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls)
    {fuel : Nat} {text : Source} {globals : ParserState} {info : PackageBindings.Metadata} {result : CompletionResult}
    (read : packageCompletionFuel (declarationReaders reader calls) fuel text globals info = some result)
    (present : result.globals.position ≠ 0) (initial : StateFrame info.states globals)
    (capacity : globals.scalarNames.length ≤ ScalarExpression.maxBindings) :
    ∃ frames : CompletionFrames (declarationReaders reader calls) text globals info result,
      let context := completionContextOf (declarationReaders reader calls) frames.outputs.body
      (layout text.length frames.signature.info context).Context frames.signature.info.stateSchema context.analysis := by
  obtain ⟨frames⟩ := packageCompletionFuel_frames read present
  exact ⟨frames, frames.source_layout present initial capacity⟩

end Silver.ApplicationPackageBodies
