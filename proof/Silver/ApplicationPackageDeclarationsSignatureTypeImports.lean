module

public import Silver.ApplicationPackageDeclarationsSignatureStoreImports

@[expose] public section
namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions ApplicationPackageNames

set_option backward.dsimp.instances true

namespace NameLibraries

/-- Read the original colon, explicit mode and type before storing a formal.
Every intermediate cursor supplies the actual lexical/type reader's domain. -/
theorem signature_read_formal_type (library : NameLibraries) {text : Source}
    (valid : ValidText text) (completing : Bool) (before : Nat) (state : SignatureState)
    (framed : ReaderFrame text state.header) (first last slot : Nat)
    (span : ValidName text first last) :
    readFormalType (library.signatureValidity modelSignatureCalls) text completing before state first last slot =
      readFormalType modelSignatureCalls text completing before state first last slot := by
  let colon := tokenAfter text last (.symbol ":")
  let inputEnd := tokenAfter text colon (.word "in")
  let outputEnd := tokenAfter text inputEnd (.word "out")
  let outputOnly := tokenAfter text colon (.word "out")
  let modeResult : Nat × ProcedureBindings.Mode := if inputEnd ≠ 0 then
      ⟨if outputEnd ≠ 0 then outputEnd else inputEnd, if outputEnd ≠ 0 then .inputOutput else .input⟩
    else ⟨outputOnly,.output⟩
  have colonBound : ValidCursor text colon := fixedAfter_result_bound text last ":" false (by decide)
  have inputBound : ValidCursor text inputEnd := fixedAfter_result_bound text colon "in" true (by decide)
  have outputBound : ValidCursor text outputEnd := fixedAfter_result_bound text inputEnd "out" true (by decide)
  have outputOnlyBound : ValidCursor text outputOnly := fixedAfter_result_bound text colon "out" true (by decide)
  have modeBound : ValidCursor text modeResult.1 := by
    dsimp only [modeResult]
    split
    · dsimp only
      split <;> assumption
    · exact outputOnlyBound
  have colonEq : library.shared.composed.function .takeToken text last (.symbol ":") = colon :=
    interpreted_take _ library.shared.inherited text valid last (.symbol ":") span.2.2 (by unfold ValidToken; decide)
  have inputEq : library.shared.composed.function .takeToken text colon (.word "in") = inputEnd :=
    interpreted_take _ library.shared.inherited text valid colon (.word "in") colonBound (by unfold ValidToken; decide)
  have outputEq : library.shared.composed.function .takeToken text inputEnd (.word "out") = outputEnd :=
    interpreted_take _ library.shared.inherited text valid inputEnd (.word "out") inputBound (by unfold ValidToken; decide)
  have outputOnlyEq : library.shared.composed.function .takeToken text colon (.word "out") = outputOnly :=
    interpreted_take _ library.shared.inherited text valid colon (.word "out") colonBound (by unfold ValidToken; decide)
  let mark := packageTypeAt text state.header state.info modeResult.1
  have markEq : ApplicationPackageNames.Native.readType library.header.names text state.header state.info modeResult.1 = mark :=
    library.signature_type modelSignatureCalls valid state.header framed state.info modeResult.1 modeBound
  dsimp +instances only [readFormalType, signatureValidity, signature, modelSignatureCalls]
  rw [colonEq, inputEq, outputEq, outputOnlyEq]
  change (if modeResult.1 = 0 ∨ (state.item.kind = .function ∧ modeResult.2 ≠ .input) then _ else _) =
    (if modeResult.1 = 0 ∨ (state.item.kind = .function ∧ modeResult.2 ≠ .input) then _ else _)
  by_cases invalid : modeResult.1 = 0 ∨ (state.item.kind = .function ∧ modeResult.2 ≠ .input)
  · rw [ite_eq_left invalid, ite_eq_left invalid]
  · rw [ite_eq_right invalid, ite_eq_right invalid, markEq]
    by_cases failed : mark.after = 0
    · rw [ite_eq_left failed, ite_eq_left failed]
    · rw [ite_eq_right failed, ite_eq_right failed]
      have fields := (package_type_domain text state.header state.info modeResult.1 framed modeBound).resolve_left failed
      exact library.signature_store_formal valid completing before state framed first last slot span modeResult.2
        mark fields.cursor fields.bounded fields.ordered

end NameLibraries
end Silver.ApplicationPackageDeclarations
