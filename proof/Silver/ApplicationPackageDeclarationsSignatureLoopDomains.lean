module

public import Silver.ApplicationPackageDeclarationsSignatureStepImports

@[expose] public section
namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions ApplicationPackageNames ApplicationPackageFrames

set_option backward.dsimp.instances true

/-- Only continuing Signature states need a reader frame. Failed returns keep
their actual metadata and do not acquire a stronger acceptance premise. -/
def SignatureStepFramed (text : Source) : SignatureStep → Prop
  | .returned _ => True
  | .ready state | .next state => ReaderFrame text state.header

theorem signature_finish_formal_framed {text : Source} (before : Nat)
    (updated : SignatureState) (framed : ReaderFrame text updated.header) :
    SignatureStepFramed text (finishFormal modelSignatureCalls text before updated) := by
  dsimp only [finishFormal, modelSignatureCalls]
  split
  · exact framed.at_position (fixedAfter_result_bound text _ ")" false (by decide))
  · split
    · trivial
    · exact framed.at_position (fixedAfter_result_bound text _ ";" false (by decide))

theorem signature_store_formal_framed {text : Source} (completing : Bool) (before : Nat)
    (state : SignatureState) (framed : ReaderFrame text state.header) (first last slot : Nat)
    (span : ValidName text first last) (mode : ProcedureBindings.Mode) (mark : PackageTypeResult)
    (cursor : ValidCursor text mark.after) (bounded : mark.bounds.Bounded)
    (ordered : mark.bounds.lower ≤ mark.bounds.upper) :
    SignatureStepFramed text (storeFormal modelSignatureCalls text completing before state first last slot mode mark) := by
  dsimp +instances only [storeFormal, modelSignatureCalls]
  split
  · trivial
  · split
    · trivial
    · apply signature_finish_formal_framed
      exact (framed.at_position cursor).append_formal ⟨first,last⟩ span mark bounded ordered mode

theorem signature_read_formal_type_framed {text : Source} (completing : Bool) (before : Nat)
    (state : SignatureState) (framed : ReaderFrame text state.header) (first last slot : Nat)
    (span : ValidName text first last) :
    SignatureStepFramed text (readFormalType modelSignatureCalls text completing before state first last slot) := by
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
  change SignatureStepFramed text (if modeResult.1 = 0 ∨ (state.item.kind = .function ∧ modeResult.2 ≠ .input) then _ else _)
  split
  · trivial
  · change SignatureStepFramed text (if mark.after = 0 then _ else _)
    split
    · trivial
    · rename_i present
      have fields := (package_type_domain text state.header state.info modeResult.1 framed modeBound).resolve_left present
      exact signature_store_formal_framed completing before state framed first last slot span modeResult.2
        mark fields.cursor fields.bounded fields.ordered

theorem signature_read_formal_name_framed {text : Source} (completing : Bool) (before : Nat)
    (state : SignatureState) (framed : ReaderFrame text state.header) (first last slot : Nat)
    (span : ValidName text first last) :
    SignatureStepFramed text (readFormalName modelSignatureCalls text completing before state first last slot) := by
  dsimp +instances only [readFormalName, modelSignatureCalls]
  split
  · trivial
  · split
    · trivial
    · rename_i present
      exact signature_read_formal_type_framed completing before _
        (framed.hide_outer state.info ⟨first,last⟩ present) first last slot span

theorem signature_step_framed {text : Source} (completing : Bool) (state : SignatureState)
    (framed : ReaderFrame text state.header) :
    SignatureStepFramed text (signatureStep modelSignatureCalls text completing state) := by
  dsimp +instances only [signatureStep, modelSignatureCalls]
  split
  · trivial
  · rename_i accepted
    have named : PackageBindings.validName (metadataText text)
        ⟨skipAt text state.header.position, nameAfter text (skipAt text state.header.position)⟩ = true := by
      exact Bool.of_not_eq_false (fun failed => accepted (by simp only [failed, Bool.not_false]))
    have span := (ApplicationPackageNames.Native.validName_domain named).2
    split
    · trivial
    · apply signature_read_formal_name_framed
      · exact framed
      · exact span

private theorem signatureStartFramed_if {text : Source} (condition : Prop)
    [Decidable condition] {yes no : SignatureStart}
    (whenTrue : SignatureStartFramed text yes) (whenFalse : SignatureStartFramed text no) :
    SignatureStartFramed text (if condition then yes else no) := by
  split <;> assumption

theorem signature_start_framed {text : Source} (outer : ParserState) (framed : ReaderFrame text outer)
    (info : PackageBindings.Metadata) (completing : Bool) :
    SignatureStartFramed text (signatureStart modelSignatureCalls text outer info completing) := by
  let original := skipAt text outer.position
  let functionEnd := tokenAfter text outer.position (.word "function")
  let procedureEnd := tokenAfter text outer.position (.word "procedure")
  let first := skipAt text (if functionEnd ≠ 0 then functionEnd else procedureEnd)
  let last := nameAfter text first
  change SignatureStartFramed text (if original = 0 ∨ (functionEnd = 0 ∧ procedureEnd = 0) ∨ first = 0 ∨ last ≤ first then _ else _)
  split
  · trivial
  · rename_i accepted
    have span : ValidName text first last := by
      simp only [not_or] at accepted
      exact ⟨Nat.pos_of_ne_zero accepted.2.2.1, Nat.lt_of_not_ge accepted.2.2.2, model_name_valid text first⟩
    repeat' first
      | exact True.intro
      | exact signature_body_framed framed _ _ _ _ _ _ span
      | apply signatureStartFramed_if

end Silver.ApplicationPackageDeclarations
