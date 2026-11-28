module

public import Silver.ApplicationPackageDeclarationsMetadataTypes

@[expose] public section

namespace Silver.ApplicationPackageDeclarations.SignatureMetadata
open Compose Compose.Expressions ApplicationPackageNames ApplicationPackageFrames PackageBindings

set_option backward.dsimp.instances true

def StateTyped (state : SignatureState) : Prop := state.info.Typed ∧ state.item.Typed

def StartTyped : SignatureStart → Prop
  | .returned result => result.info.Typed
  | .ready state | .loop state => StateTyped state

def StepTyped : SignatureStep → Prop
  | .returned result => result.info.Typed
  | .ready state | .next state => StateTyped state

def ExitTyped : SignatureExit → Prop
  | .returned result => result.info.Typed
  | .ready state => StateTyped state

private theorem start_if (guard : Prop) [Decidable guard] {yes no : SignatureStart}
    (left : StartTyped yes) (right : StartTyped no) : StartTyped (if guard then yes else no) := by
  split <;> assumption

theorem enter_body (text : Source) (outer : ParserState) (info : Metadata) (typed : info.Typed)
    (first last identity : Nat) (item : Routine) (itemTyped : item.Typed) (formalStart : Nat) :
    StartTyped (startSignatureBody modelSignatureCalls text outer info first last identity item formalStart) := by
  dsimp only [startSignatureBody]
  split <;> exact ⟨typed, itemTyped⟩

theorem start {text : Source} (valid : ValidText text) (outer : ParserState) (framed : ReaderFrame text outer)
    (info : Metadata) (typed : info.Typed) : StartTyped (signatureStart modelSignatureCalls text outer info true) := by
  let original := skipAt text outer.position
  let functionEnd := tokenAfter text outer.position (.word "function")
  let procedureEnd := tokenAfter text outer.position (.word "procedure")
  let first := skipAt text (if functionEnd ≠ 0 then functionEnd else procedureEnd)
  let last := nameAfter text first
  have originalBound : original ≤ maxSourceLength + 1 :=
    Nat.le_trans (model_skip_valid text outer.position framed.cursor) (Nat.add_le_add_right valid.2 1)
  change StartTyped (if original = 0 ∨ (functionEnd = 0 ∧ procedureEnd = 0) ∨ first = 0 ∨ last ≤ first then _ else _)
  split
  · exact typed
  · rename_i accepted
    have span : ValidName text first last := by
      simp only [not_or] at accepted
      exact ⟨Nat.pos_of_ne_zero accepted.2.2.1, Nat.lt_of_not_ge accepted.2.2.2, model_name_valid text first⟩
    have named := MetadataTypes.span valid (⟨first,last⟩ : NameSpan) span
    dsimp only
    simp only [↓reduceIte]
    split
    · exact typed
    · split
      · exact typed
      · apply start_if
        · exact typed
        · apply enter_body text outer info typed first last _ _ _ _
          exact MetadataTypes.routine_body (MetadataTypes.routine_at typed _) _ named original originalBound

theorem finish_formal (text : Source) (before : Nat) (state : SignatureState) (typed : StateTyped state) :
    StepTyped (finishFormal modelSignatureCalls text before state) := by
  dsimp only [finishFormal]
  split
  · exact typed
  · split
    · exact typed.1
    · exact typed

theorem store (text : Source) (before : Nat) (state : SignatureState) (typed : StateTyped state)
    (first last slot : Nat) (named : NameSpan.Typed ⟨first,last⟩) (mode : ProcedureBindings.Mode)
    (mark : PackageTypeResult) (typeNamed : mark.name.Typed) :
    StepTyped (storeFormal modelSignatureCalls text true before state first last slot mode mark) := by
  have parameter := MetadataTypes.formal_body (MetadataTypes.parameter_at typed.1 slot) _ _ named typeNamed
  have stored := MetadataTypes.set_parameter typed.1 (slot - 1) _ parameter
  dsimp only [storeFormal]
  simp only [Bool.true_and, ↓reduceIte]
  split
  · exact typed.1
  · split
    · exact stored
    · exact finish_formal text before _ ⟨stored, typed.2⟩

theorem read_type {text : Source} (valid : ValidText text) (before : Nat) (state : SignatureState)
    (typed : StateTyped state) (framed : ReaderFrame text state.header) (first last slot : Nat)
    (span : ValidName text first last) :
    StepTyped (readFormalType modelSignatureCalls text true before state first last slot) := by
  let colon := tokenAfter text last (.symbol ":")
  let inputEnd := tokenAfter text colon (.word "in")
  let outputEnd := tokenAfter text inputEnd (.word "out")
  let outputOnly := tokenAfter text colon (.word "out")
  let modeResult : Nat × ProcedureBindings.Mode := if inputEnd ≠ 0 then
      ⟨if outputEnd ≠ 0 then outputEnd else inputEnd, if outputEnd ≠ 0 then .inputOutput else .input⟩
    else ⟨outputOnly,.output⟩
  have modeBound : ValidCursor text modeResult.1 := by
    dsimp only [modeResult]
    split
    · dsimp only
      split
      · exact fixedAfter_result_bound text _ "out" true (by decide)
      · exact fixedAfter_result_bound text _ "in" true (by decide)
    · exact fixedAfter_result_bound text _ "out" true (by decide)
  let mark := packageTypeAt text state.header state.info modeResult.1
  change StepTyped (if modeResult.1 = 0 ∨ (state.item.kind = .function ∧ modeResult.2 ≠ .input) then _ else _)
  split
  · exact typed.1
  · change StepTyped (if mark.after = 0 then _ else _)
    split
    · exact typed.1
    · rename_i present
      have fields := (package_type_domain text state.header state.info modeResult.1 framed modeBound).resolve_left present
      have typeSpan := (ApplicationPackageNames.Native.validName_domain fields.name).2
      exact store text before state typed first last slot (MetadataTypes.span valid _ span) modeResult.2 mark
        (MetadataTypes.span valid _ typeSpan)

theorem read_name {text : Source} (valid : ValidText text) (before : Nat) (state : SignatureState)
    (typed : StateTyped state) (framed : ReaderFrame text state.header) (first last slot : Nat)
    (span : ValidName text first last) :
    StepTyped (readFormalName modelSignatureCalls text true before state first last slot) := by
  dsimp +instances only [readFormalName, modelSignatureCalls]
  split
  · exact typed.1
  · split
    · exact typed.1
    · rename_i present
      exact read_type valid before {state with header := hideOuter text state.header state.info ⟨first,last⟩}
        ⟨typed.1, typed.2⟩ (framed.hide_outer state.info ⟨first,last⟩ present) first last slot span

theorem step {text : Source} (valid : ValidText text) (state : SignatureState)
    (typed : StateTyped state) (framed : ReaderFrame text state.header) :
    StepTyped (signatureStep modelSignatureCalls text true state) := by
  dsimp +instances only [signatureStep, modelSignatureCalls]
  split
  · exact typed.1
  · rename_i accepted
    have named : PackageBindings.validName (metadataText text)
        ⟨skipAt text state.header.position, nameAfter text (skipAt text state.header.position)⟩ = true :=
      Bool.of_not_eq_false (fun failed => accepted (by simp only [failed, Bool.not_false]))
    have span := (ApplicationPackageNames.Native.validName_domain named).2
    split
    · exact typed.1
    · exact read_name valid _ _ typed framed _ _ _ span

end Silver.ApplicationPackageDeclarations.SignatureMetadata
