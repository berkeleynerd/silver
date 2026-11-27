module

public import Silver.ApplicationPackageDeclarationsNameImports
public import Silver.ApplicationPackageDeclarationsExecution

@[expose] public section

namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions ApplicationPackageNames

set_option backward.dsimp.instances true

namespace NameLibraries

/-- The actual imported lexical, package-name and shadowing readers. The
remaining dictionary entries are retained until their own call domains are
established; the Signature entry does not invoke those entries. -/
def signature (library : NameLibraries) (other : SignatureCalls) : SignatureCalls :=
  {other with
    skip := library.shared.composed.function .skip
    nameAfter := library.shared.composed.function .nameAfter
    take := library.shared.composed.function .takeToken
    validName := fun text => library.shared.packages.validName (metadataText text)
    sameName := fun text => library.shared.packages.sameName (metadataText text)
    fresh := ApplicationPackageNames.Native.freshName library.header.names
    hide := ApplicationPackageFrames.Native.importedHideName library.shared
    hideOuter := library.hideOuter
    typeAt := ApplicationPackageNames.Native.readType library.header.names}

private theorem signature_body_entry (library : NameLibraries) (other : SignatureCalls)
    {text : Source} (valid : ValidText text) (outer : ParserState)
    (info : PackageBindings.Metadata) (first last identity : Nat)
    (item : PackageBindings.Routine) (formalStart : Nat) (span : ValidName text first last) :
    startSignatureBody (library.signature other) text outer info first last identity item formalStart =
      startSignatureBody modelSignatureCalls text outer info first last identity item formalStart := by
  have hidden := ApplicationPackageFrames.Native.importedHideName_meaning
    library.shared text valid outer.hiding first last span
  have opened := interpreted_take _ library.shared.inherited text valid last (.symbol "(")
    span.2.2 (by unfold ValidToken; decide)
  simp only [startSignatureBody, signature, modelSignatureCalls, hidden, opened]
  rfl

/-- The original Signature prefix is interpreted over its complete native
input domain. Metadata may be malformed and the source may be rejected; no
successful signature or whole-source metadata-validity premise is added. -/
theorem signature_start (library : NameLibraries) (other : SignatureCalls)
    {text : Source} (valid : ValidText text) (outer : ParserState) (state : ReaderFrame text outer)
    (info : PackageBindings.Metadata) (completing : Bool) :
    signatureStart (library.signature other) text outer info completing =
      signatureStart modelSignatureCalls text outer info completing := by
  let original := skipAt text outer.position
  let functionEnd := tokenAfter text outer.position (.word "function")
  let procedureEnd := tokenAfter text outer.position (.word "procedure")
  let selected := if functionEnd ≠ 0 then functionEnd else procedureEnd
  let first := skipAt text selected
  let last := Compose.nameAfter text first
  have functionBound : ValidCursor text functionEnd :=
    fixedAfter_result_bound text outer.position "function" true (by decide)
  have procedureBound : ValidCursor text procedureEnd :=
    fixedAfter_result_bound text outer.position "procedure" true (by decide)
  have selectedBound : ValidCursor text selected := by
    dsimp only [selected]; split <;> assumption
  have firstBound := model_skip_valid text selected selectedBound
  have lastBound := model_name_valid text first
  have originalEq := interpreted_skip _ library.shared.inherited text valid outer.position state.cursor
  have functionEq := interpreted_take _ library.shared.inherited text valid outer.position (.word "function")
    state.cursor (by unfold ValidToken; decide)
  have procedureEq := interpreted_take _ library.shared.inherited text valid outer.position (.word "procedure")
    state.cursor (by unfold ValidToken; decide)
  change library.shared.composed.function .takeToken text outer.position (.word "function") = functionEnd at functionEq
  change library.shared.composed.function .takeToken text outer.position (.word "procedure") = procedureEnd at procedureEq
  have firstEq := interpreted_skip _ library.shared.inherited text valid selected selectedBound
  have lastEq := interpreted_name _ library.shared.inherited text valid first firstBound
  have sameName (left right : PackageBindings.NameSpan) := PackageBindings.Native.interpreted_sameName
    library.shared.packages library.shared.packagePrimitives library.shared.packageEquations
    (metadataText text) left right
  have fresh := (ApplicationPackageNames.Native.imported_readers library.shared library.header).fresh text info ⟨first,last⟩
  dsimp +instances only [signatureStart, signature, modelSignatureCalls]
  simp only [originalEq, functionEq, procedureEq]
  rw [firstEq, lastEq]
  simp only [sameName]
  change (if original = 0 ∨ (functionEnd = 0 ∧ procedureEnd = 0) ∨ first = 0 ∨ last ≤ first then _ else _) =
    (if original = 0 ∨ (functionEnd = 0 ∧ procedureEnd = 0) ∨ first = 0 ∨ last ≤ first then _ else _)
  by_cases accepted : original = 0 ∨ (functionEnd = 0 ∧ procedureEnd = 0) ∨ first = 0 ∨ last ≤ first
  · rw [ite_eq_left accepted, ite_eq_left accepted]
  · rw [ite_eq_right accepted, ite_eq_right accepted]
    have span : ValidName text first last := by
      simp only [not_or] at accepted
      exact ⟨Nat.pos_of_ne_zero accepted.2.2.1, Nat.lt_of_not_ge accepted.2.2.2, lastBound⟩
    have entry := library.signature_body_entry other valid outer info first last
    cases completing with
    | false =>
      simp only [Bool.false_eq_true, ↓reduceIte]
      rw [fresh]
      by_cases full : (decide (info.routines.length = PackageBindings.maxRoutines) || !packageNameFresh text info ⟨first,last⟩) = true
      · rw [ite_eq_left full, ite_eq_left full]
      · rw [ite_eq_right full, ite_eq_right full]
        exact entry _ _ _ span
    | true =>
      simp only [↓reduceIte]
      by_cases completed : info.completed ≥ info.routines.length
      · rw [ite_eq_left completed, ite_eq_left completed]
      · rw [ite_eq_right completed, ite_eq_right completed]
        let item := info.routineAt (info.completed + 1)
        by_cases malformed : item.count > 0 ∧ (item.formalFirst = 0 ∨ item.formalFirst > info.parameters.length ∨
            item.count > info.parameters.length - item.formalFirst + 1)
        · rw [ite_eq_left malformed, ite_eq_left malformed]
        · rw [ite_eq_right malformed, ite_eq_right malformed]
          by_cases mismatch : (!PackageBindings.sameName (metadataText text) item.specName ⟨first,last⟩ ||
              (decide (item.kind = .function) != decide (functionEnd ≠ 0))) = true
          · rw [ite_eq_left mismatch, ite_eq_left mismatch]
          · rw [ite_eq_right mismatch, ite_eq_right mismatch]
            exact entry _ _ _ span

end NameLibraries
end Silver.ApplicationPackageDeclarations
