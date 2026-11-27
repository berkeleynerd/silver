module

public import Silver.ApplicationPackageDeclarationsFormalDomains
public import Silver.ApplicationPackageDeclarationsSignatureFinishImports

@[expose] public section
namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions ApplicationPackageNames ApplicationPackageFrames

set_option backward.dsimp.instances true

namespace NameLibraries

theorem signature_duplicate_formal (library : NameLibraries) (other : SignatureCalls)
    (text : Source) (completing : Bool) (info : PackageBindings.Metadata)
    (name : PackageBindings.NameSpan) (first count : Nat) :
    duplicateFormal (library.signature other) text completing info name first count =
      duplicateFormal modelSignatureCalls text completing info name first count := by
  have sameName (left right : PackageBindings.NameSpan) := PackageBindings.Native.interpreted_sameName
    library.shared.packages library.shared.packagePrimitives library.shared.packageEquations
    (metadataText text) left right
  simp only [duplicateFormal, signature, modelSignatureCalls, sameName]

/-- The original formal-store branch, including mismatch and capacity failure,
uses interpreted name equality and the checked full-frame append projection. -/
theorem signature_store_formal (library : NameLibraries) {text : Source}
    (valid : ValidText text) (completing : Bool) (before : Nat) (state : SignatureState)
    (framed : ReaderFrame text state.header) (first last slot : Nat)
    (span : ValidName text first last) (mode : ProcedureBindings.Mode) (mark : PackageTypeResult)
    (cursor : ValidCursor text mark.after) (bounded : mark.bounds.Bounded)
    (ordered : mark.bounds.lower ≤ mark.bounds.upper) :
    storeFormal (library.signatureValidity modelSignatureCalls) text completing before state first last slot mode mark =
      storeFormal modelSignatureCalls text completing before state first last slot mode mark := by
  let parameter := state.info.parameterAt slot
  let updatedParameter : PackageBindings.Formal := if completing then
      {parameter with bodyName := ⟨first,last⟩, bodyTypeName := mark.name}
    else {specName := ⟨first,last⟩, specTypeName := mark.name, kind := mark.kind, bounds := mark.bounds, typeIdentity := mark.identity, mode := mode}
  let info := if completing then {state.info with parameters := state.info.parameters.set (slot - 1) updatedParameter}
    else {state.info with parameters := state.info.parameters ++ [updatedParameter]}
  let header := appendFormal {state.header with position := mark.after} ⟨first,last⟩ mark mode
  let updated := {state with info, header, formalCount := state.formalCount + 1}
  have after : ReaderFrame text header := (framed.at_position cursor).append_formal ⟨first,last⟩ span mark bounded ordered mode
  have suffix : finishFormal (library.signatureValidity modelSignatureCalls) text before updated =
      finishFormal modelSignatureCalls text before updated :=
    library.signature_finish_formal _ valid before updated after
  have sameName := PackageBindings.Native.interpreted_sameName
    library.shared.packages library.shared.packagePrimitives library.shared.packageEquations
    (metadataText text) parameter.specName ⟨first,last⟩
  dsimp +instances only [storeFormal, signatureValidity, signature, modelSignatureCalls]
  rw [sameName]
  by_cases mismatch : (completing && (!PackageBindings.sameName (metadataText text) parameter.specName ⟨first,last⟩ ||
      decide (parameter.mode ≠ mode ∨ parameter.kind ≠ mark.kind ∨
        parameter.typeIdentity ≠ mark.identity ∨ parameter.bounds ≠ mark.bounds))) = true
  · rw [ite_eq_left mismatch, ite_eq_left mismatch]
  · rw [ite_eq_right mismatch, ite_eq_right mismatch]
    by_cases failed : header.position = 0
    · rw [ite_eq_left failed, ite_eq_left failed]
    · rw [ite_eq_right failed, ite_eq_right failed]
      exact suffix

end NameLibraries
end Silver.ApplicationPackageDeclarations
