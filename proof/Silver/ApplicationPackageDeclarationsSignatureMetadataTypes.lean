module

public import Silver.ApplicationPackageDeclarationsSignatureMetadataStages
public import Silver.ApplicationPackageDeclarationsSignatureLoopImports

@[expose] public section

namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions ApplicationPackageNames ApplicationPackageFrames PackageBindings

set_option backward.dsimp.instances true

namespace SignatureMetadata

theorem after_type (text : Source) (outer : ParserState) (state : SignatureState) (typed : StateTyped state)
    (mark : PackageTypeResult) (named : mark.name.Typed) :
    (signatureAfterType modelSignatureCalls text outer true state state.item mark).info.Typed := by
  dsimp only [signatureAfterType]
  simp only [Bool.true_and, ↓reduceIte]
  split
  · exact typed.1
  · split
    · exact typed.1
    · let item := if state.item.kind = .function then {state.item with bodyResultName := mark.name} else state.item
      have itemTyped : item.Typed := by
        dsimp only [item]
        split
        · exact MetadataTypes.routine_result typed.2 mark.name named
        · exact typed.2
      let position := if item.kind = .function then mark.after else state.header.position
      let following := modelSignatureCalls.take text position (.word "is")
      let header := {state.header with position := following}
      change (if decide (following ≤ outer.position) || !modelSignatureCalls.stateValid text header then
        rejectedSignature state.info else
          ({info := {state.info with routines := state.info.routines.set (state.routineId - 1) item}, header} : SignatureResult)).info.Typed
      split
      · exact typed.1
      · exact MetadataTypes.set_routine typed.1 (state.routineId - 1) item itemTyped

theorem finish {text : Source} (valid : ValidText text) (outer : ParserState)
    (state : SignatureState) (typed : StateTyped state) :
    (finishSignature modelSignatureCalls text outer true state).info.Typed := by
  rw [finishSignature_afterType]
  simp only [Bool.true_and, ↓reduceIte]
  split
  · exact typed.1
  · let mark : PackageTypeResult := if state.item.kind = .function then
        packageTypeAt text state.header state.info (tokenAfter text state.header.position (.word "return")) else {}
    have named : mark.name.Typed := by
      dsimp only [mark]
      split
      · exact MetadataTypes.type_name valid _ _ _
      · exact ⟨Nat.zero_le _, Nat.zero_le _⟩
    exact after_type text outer state typed mark named

theorem loop {text : Source} (valid : ValidText text) {state : SignatureState} {result : SignatureExit}
    (run : SignatureLoop modelSignatureCalls text true state result)
    (typed : StateTyped state) (framed : ReaderFrame text state.header) :
    ExitTyped result ∧ SignatureExitFramed text result := by
  induction run with
  | returned parsed =>
    have fields := step valid _ typed framed
    rw [parsed] at fields
    exact ⟨fields, True.intro⟩
  | ready parsed =>
    have fields := step valid _ typed framed
    have frame := signature_step_framed true _ framed
    rw [parsed] at fields frame
    exact ⟨fields, frame⟩
  | next parsed _ ih =>
    have fields := step valid _ typed framed
    have frame := signature_step_framed true _ framed
    rw [parsed] at fields frame
    exact ih fields frame

end SignatureMetadata

/-- Completing a signature preserves every native metadata component subtype,
including partial formal writes on failure. This is not metadata validity: no
name matching, nonempty interval, unit layout or completed-routine premise is
added to the actual original Signature domain. -/
theorem readSignature_completion_typed {text : Source} (valid : ValidText text)
    (outer : ParserState) (framed : ReaderFrame text outer) (info : Metadata) (typed : info.Typed) :
    (readSignature text outer info true).info.Typed := by
  have started := SignatureMetadata.start valid outer framed info typed
  have startFrame := signature_start_framed outer framed info true
  unfold readSignature
  cases chosen : signatureStart modelSignatureCalls text outer info true with
  | returned result =>
    rw [chosen] at started
    exact started
  | ready state =>
    rw [chosen] at started
    exact SignatureMetadata.finish valid outer state started
  | loop state =>
    dsimp only
    rw [chosen] at started startFrame
    have ended := SignatureMetadata.loop valid (runSignatureLoop_exec text true state) started startFrame
    cases returned : runSignatureLoop text true state with
    | returned result =>
      rw [returned] at ended
      exact ended.1
    | ready finalState =>
      rw [returned] at ended
      exact SignatureMetadata.finish valid outer finalState ended.1

end Silver.ApplicationPackageDeclarations
