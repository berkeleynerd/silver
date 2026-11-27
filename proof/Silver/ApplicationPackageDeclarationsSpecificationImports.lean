module

public import Silver.ApplicationPackageDeclarationsReaderImports

@[expose] public section
namespace Silver.ApplicationPackageDeclarations
open Compose Compose.Expressions ApplicationPackageNames ApplicationPackageFrames

set_option backward.dsimp.instances true

namespace NameLibraries

/-- Actual imported lexical/name/validity readers shared by the Specification.
Its procedure and declaration branches retain their separately interpreted calls. -/
def specification (library : NameLibraries) (other : SpecificationCalls) : SpecificationCalls :=
  {other with
    skip := library.shared.composed.function .skip
    nameAfter := library.shared.composed.function .nameAfter
    take := library.shared.composed.function .takeToken
    word := ApplicationPackageNames.Native.readWord library.header.names
    pragmaAfter := ApplicationPackageNames.Native.readPragma library.header.names
    allowed := ApplicationPackageNames.Native.allowedName library.header.names
    fresh := ApplicationPackageNames.Native.freshName library.header.names
    sameName := fun text => library.shared.packages.sameName (metadataText text)
    hide := ApplicationPackageFrames.Native.importedHideName library.shared
    stateValid := fun text frame =>
      ApplicationPackageFrames.Native.frameCalls library.shared library.validity _ .validState text frame}

theorem specification_start (library : NameLibraries) (other : SpecificationCalls)
    (reader : BooleanElaboration.Native.Reader) {text : Source} (valid : ValidText text)
    (info : PackageBindings.Metadata) :
    specificationStart (library.specification other) text info =
      specificationStart (modelSpecificationCalls reader) text info := by
  let word := packageWord text 1 "package"
  let first := skipAt text word
  let last := nameAfter text first
  let afterIs := tokenAfter text last (.word "is")
  have words := ApplicationPackageNames.Native.imported_readers library.shared library.header
  have wordBound : ValidCursor text word := by
    dsimp only [word, packageWord]
    split
    · exact model_name_valid text _
    · exact Nat.zero_le _
  have firstBound := model_skip_valid text word wordBound
  have lastBound := model_name_valid text first
  have afterIsBound : ValidCursor text afterIs := fixedAfter_result_bound text last "is" true (by decide)
  have wordEq := words.word text valid 1 (by unfold ValidCursor; omega) "package" (by decide) (by decide)
  have skipEq := interpreted_skip _ library.shared.inherited text valid word wordBound
  have nameEq := interpreted_name _ library.shared.inherited text valid first firstBound
  have allowedEq := words.allowed text ⟨first,last⟩
  have isEq := interpreted_take _ library.shared.inherited text valid last (.word "is") lastBound (by unfold ValidToken; decide)
  change library.shared.composed.function .takeToken text last (.word "is") = afterIs at isEq
  have pragmaEq := words.pragmaAfter text valid afterIs afterIsBound
  dsimp +instances only [specificationStart, specification, modelSpecificationCalls]
  rw [wordEq, skipEq, nameEq, allowedEq, isEq, pragmaEq]

theorem specification_finish (library : NameLibraries) (other : SpecificationCalls)
    (reader : BooleanElaboration.Native.Reader) {text : Source} (valid : ValidText text)
    (state : SpecificationState) (framed : ReaderFrame text state.exports) :
    finishSpecification (library.specification other) text state =
      finishSpecification (modelSpecificationCalls reader) text state := by
  let ended := tokenAfter text state.exports.position (.word "end")
  let first := skipAt text ended
  let last := nameAfter text first
  let following := tokenAfter text last (.symbol ";")
  have endBound : ValidCursor text ended := fixedAfter_result_bound text _ "end" true (by decide)
  have firstBound := model_skip_valid text ended endBound
  have lastBound := model_name_valid text first
  have followingBound : ValidCursor text following := fixedAfter_result_bound text last ";" false (by decide)
  have endEq := interpreted_take _ library.shared.inherited text valid state.exports.position (.word "end")
    framed.cursor (by unfold ValidToken; decide)
  change library.shared.composed.function .takeToken text state.exports.position (.word "end") = ended at endEq
  have firstEq := interpreted_skip _ library.shared.inherited text valid ended endBound
  have lastEq := interpreted_name _ library.shared.inherited text valid first firstBound
  have followingEq := interpreted_take _ library.shared.inherited text valid last (.symbol ";") lastBound (by unfold ValidToken; decide)
  change library.shared.composed.function .takeToken text last (.symbol ";") = following at followingEq
  have skippedEq := interpreted_skip _ library.shared.inherited text valid following followingBound
  have nameEq := PackageBindings.Native.interpreted_sameName library.shared.packages
    library.shared.packagePrimitives library.shared.packageEquations (metadataText text) state.name ⟨first,last⟩
  dsimp +instances only [finishSpecification, specification, modelSpecificationCalls]
  rw [endEq, firstEq, lastEq, followingEq, skippedEq, nameEq]

end NameLibraries
end Silver.ApplicationPackageDeclarations
