module

public import Silver.ApplicationPackageDeclarationsSignatureTypeImports

@[expose] public section
namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions ApplicationPackageNames ApplicationPackageFrames

set_option backward.dsimp.instances true

namespace NameLibraries

theorem signature_read_formal_name (library : NameLibraries) {text : Source}
    (valid : ValidText text) (completing : Bool) (before : Nat) (state : SignatureState)
    (framed : ReaderFrame text state.header) (first last slot : Nat)
    (span : ValidName text first last) :
    readFormalName (library.signatureValidity modelSignatureCalls) text completing before state first last slot =
      readFormalName modelSignatureCalls text completing before state first last slot := by
  have duplicate : duplicateFormal (library.signatureValidity modelSignatureCalls) text completing state.info
      ⟨first,last⟩ state.formalStart state.formalCount =
      duplicateFormal modelSignatureCalls text completing state.info ⟨first,last⟩ state.formalStart state.formalCount :=
    library.signature_duplicate_formal _ text completing state.info ⟨first,last⟩ state.formalStart state.formalCount
  have hidden : (library.signatureValidity modelSignatureCalls).hideOuter text state.header state.info ⟨first,last⟩ =
      ApplicationPackageFrames.hideOuter text state.header state.info ⟨first,last⟩ := library.hide_outer valid framed state.info ⟨first,last⟩ span
  dsimp +instances only [readFormalName]
  rw [duplicate]
  by_cases repeated : (decide (state.formalCount > 0) &&
      duplicateFormal modelSignatureCalls text completing state.info ⟨first,last⟩ state.formalStart state.formalCount) = true
  · rw [ite_eq_left repeated, ite_eq_left repeated]
  · rw [ite_eq_right repeated, ite_eq_right repeated, hidden]
    dsimp +instances only [modelSignatureCalls]
    let next := ApplicationPackageFrames.hideOuter text state.header state.info ⟨first,last⟩
    by_cases absent : next.position = 0
    · rw [ite_eq_left absent, ite_eq_left absent]
    · rw [ite_eq_right absent, ite_eq_right absent]
      exact library.signature_read_formal_type valid completing before {state with header := next}
        (framed.hide_outer state.info ⟨first,last⟩ absent) first last slot span

/-- Every imported call in one complete formal iteration is interpreted on
its original declared domain. Metadata, count/mode rejection and empty input
remain unrestricted; the existing ReaderFrame supplies the native state gate. -/
theorem signature_step (library : NameLibraries) {text : Source}
    (valid : ValidText text) (completing : Bool) (state : SignatureState)
    (framed : ReaderFrame text state.header) :
    signatureStep (library.signatureValidity modelSignatureCalls) text completing state =
      signatureStep modelSignatureCalls text completing state := by
  let first := skipAt text state.header.position
  let last := nameAfter text first
  have firstBound : ValidCursor text first := model_skip_valid text state.header.position framed.cursor
  have firstEq : library.shared.composed.function .skip text state.header.position = first :=
    interpreted_skip _ library.shared.inherited text valid state.header.position framed.cursor
  have lastEq : library.shared.composed.function .nameAfter text first = last :=
    interpreted_name _ library.shared.inherited text valid first firstBound
  have nameEq := PackageBindings.Native.interpreted_validName library.shared.packages
    library.shared.packagePrimitives library.shared.packageEquations (metadataText text) ⟨first,last⟩
  dsimp +instances only [signatureStep, signatureValidity, signature, modelSignatureCalls]
  rw [firstEq,lastEq,nameEq]
  by_cases invalid : (!PackageBindings.validName (metadataText text) ⟨first,last⟩) = true
  · rw [ite_eq_left invalid, ite_eq_left invalid]
  · rw [ite_eq_right invalid, ite_eq_right invalid]
    have named : PackageBindings.validName (metadataText text) ⟨first,last⟩ = true := by
      cases found : PackageBindings.validName (metadataText text) ⟨first,last⟩
      · exact (invalid (by simp only [found, Bool.not_false])).elim
      · rfl
    have span := (ApplicationPackageNames.Native.validName_domain named).2
    by_cases exhausted : ((completing && decide (state.formalCount ≥ state.item.count)) ||
        (!completing && decide (state.info.parameters.length = PackageBindings.maxFormals))) = true
    · rw [ite_eq_left exhausted, ite_eq_left exhausted]
    · rw [ite_eq_right exhausted, ite_eq_right exhausted]
      let slot := if completing then state.formalStart + state.formalCount else state.info.parameters.length + 1
      let nextState := {state with formalStart := if (!completing && decide (state.formalCount = 0)) then slot else state.formalStart}
      exact library.signature_read_formal_name valid completing state.header.position nextState
        (show ReaderFrame text nextState.header from framed) first last slot span

end NameLibraries
end Silver.ApplicationPackageDeclarations
