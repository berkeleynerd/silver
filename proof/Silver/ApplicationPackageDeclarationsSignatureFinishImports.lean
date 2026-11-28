module

public import Silver.ApplicationPackageDeclarationsSignatureDomains

@[expose] public section
namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions ApplicationPackageNames ApplicationPackageFrames

set_option backward.dsimp.instances true

/-- Signature's suffix after selecting the routine row and result type. This
factorization changes no branch or metadata update in the original model. -/
def signatureAfterType (calls : SignatureCalls) (text : Source) (outer : ParserState)
    (completing : Bool) (state : SignatureState) (item : PackageBindings.Routine)
    (mark : PackageTypeResult) : SignatureResult :=
  if item.kind = .function ∧ mark.after = 0 then rejectedSignature state.info else
  if completing && decide (item.kind = .function) &&
      decide (item.resultKind ≠ mark.kind ∨ item.resultTypeIdentity ≠ mark.identity ∨ item.resultBounds ≠ mark.bounds) then
    rejectedSignature state.info
  else
  let item := if item.kind = .function then
      if completing then {item with bodyResultName := mark.name}
      else {item with resultKind := mark.kind, resultBounds := mark.bounds, resultTypeIdentity := mark.identity, specResultName := mark.name}
    else item
  let position := if item.kind = .function then mark.after else state.header.position
  let following := calls.take text position (if completing then .word "is" else .symbol ";")
  let header := {state.header with position := following}
  if decide (following ≤ outer.position) || !calls.stateValid text header then rejectedSignature state.info else
  let item := if completing then item else {item with specAfter := following}
  let info := if completing then {state.info with routines := state.info.routines.set (state.routineId - 1) item}
    else {state.info with routines := state.info.routines ++ [item]}
  ⟨info,header⟩

theorem finishSignature_afterType (calls : SignatureCalls) (text : Source) (outer : ParserState)
    (completing : Bool) (state : SignatureState) :
    finishSignature calls text outer completing state =
      if completing && decide (state.formalCount ≠ state.item.count) then rejectedSignature state.info else
      let item := if completing then state.item else {state.item with count := state.formalCount, formalFirst := state.formalStart}
      let mark := if item.kind = .function then
        calls.typeAt text state.header state.info (calls.take text state.header.position (.word "return")) else {}
      signatureAfterType calls text outer completing state item mark := rfl

namespace NameLibraries

theorem signature_after_type (library : NameLibraries) (other : SignatureCalls)
    {text : Source} (valid : ValidText text) (outer : ParserState) (completing : Bool)
    (state : SignatureState) (framed : ReaderFrame text state.header)
    (item : PackageBindings.Routine) (mark : PackageTypeResult) (bounded : ValidCursor text mark.after) :
    signatureAfterType (library.signatureValidity other) text outer completing state item mark =
      signatureAfterType modelSignatureCalls text outer completing state item mark := by
  have positionBound (kind : PackageBindings.RoutineKind) :
      ValidCursor text (if kind = .function then mark.after else state.header.position) := by
    split
    · exact bounded
    · exact framed.cursor
  have tokenValid : ValidToken (if completing then ShellToken.word "is" else .symbol ";") := by
    cases completing <;> unfold ValidToken <;> decide
  have lexical (kind : PackageBindings.RoutineKind) :
      library.shared.composed.function .takeToken text
          (if kind = .function then mark.after else state.header.position)
          (if completing then .word "is" else .symbol ";") =
        tokenAfter text (if kind = .function then mark.after else state.header.position)
          (if completing then .word "is" else .symbol ";") := by
    have meaning := interpreted_take _ library.shared.inherited text valid
      (if kind = .function then mark.after else state.header.position)
      (if completing then ShellToken.word "is" else .symbol ";") (positionBound kind) tokenValid
    cases completing <;> exact meaning
  have checked (position : Nat) := ApplicationPackageFrames.Native.frameCalls_valid
    library.shared library.validity text valid {state.header with position} ⟨(framed.imported_types valid).functions, (framed.imported_types valid).procedures,
      (framed.imported_types valid).arrays⟩
  dsimp +instances only [signatureAfterType, signatureValidity, signature, modelSignatureCalls]
  simp only [lexical, checked]


/-- Interpret the entire final Signature phase on every frame that can reach
it. Arbitrary metadata, mismatching completions and failure returns are covered;
only the original frame/cursor requirements govern imported calls. -/
theorem signature_finish (library : NameLibraries) (other : SignatureCalls)
    {text : Source} (valid : ValidText text) (outer : ParserState) (completing : Bool)
    (state : SignatureState) (framed : ReaderFrame text state.header) :
    finishSignature (library.signatureValidity other) text outer completing state =
      finishSignature modelSignatureCalls text outer completing state := by
  let position := tokenAfter text state.header.position (.word "return")
  have cursor : ValidCursor text position :=
    fixedAfter_result_bound text state.header.position "return" true (by decide)
  have returnEq : (library.signatureValidity other).take text state.header.position (.word "return") = position :=
    interpreted_take _ library.shared.inherited text valid state.header.position (.word "return")
      framed.cursor (by unfold ValidToken; decide)
  have typeEq : (library.signatureValidity other).typeAt text state.header state.info position =
      packageTypeAt text state.header state.info position :=
    library.signature_type _ valid state.header framed state.info position cursor
  let item := if completing then state.item else {state.item with count := state.formalCount, formalFirst := state.formalStart}
  let mark : PackageTypeResult := if item.kind = .function then packageTypeAt text state.header state.info position else {}
  have markBound : ValidCursor text mark.after := by
    dsimp only [mark]
    split
    · rcases package_type_domain text state.header state.info position framed cursor with absent | present
      · rw [absent]; exact Nat.zero_le _
      · exact present.cursor
    · exact Nat.zero_le _
  rw [finishSignature_afterType, finishSignature_afterType]
  by_cases mismatch : (completing && decide (state.formalCount ≠ state.item.count)) = true
  · rw [ite_eq_left mismatch, ite_eq_left mismatch]
  · rw [ite_eq_right mismatch, ite_eq_right mismatch]
    change signatureAfterType (library.signatureValidity other) text outer completing state item
        (if item.kind = .function then
          (library.signatureValidity other).typeAt text state.header state.info
            ((library.signatureValidity other).take text state.header.position (.word "return")) else {}) =
      signatureAfterType modelSignatureCalls text outer completing state item mark
    rw [returnEq, typeEq]
    exact library.signature_after_type other valid outer completing state framed item mark markBound

end NameLibraries
end Silver.ApplicationPackageDeclarations
