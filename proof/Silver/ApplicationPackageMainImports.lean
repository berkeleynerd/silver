module

public import Silver.ApplicationPackageMainEquations
public import Silver.ApplicationPackageDeclarationsNameImports
public import Silver.ApplicationPackageFrameImports
public import Silver.NamesEquations

@[expose] public section

/-! Main's lexical and frame imports on their actual native argument domains.
The declaration/body readers and imported-name comparison remain explicit until
their separate interpretations are joined. No accepted Main or decoder is assumed. -/
namespace Silver.ApplicationPackageMain
open Compose Compose.Expressions ApplicationPackageNames ApplicationPackageDeclarations

set_option backward.dsimp.instances true

structure Libraries where
  names : NameLibraries
  contexts : Names.Calls
  contextSource : Names.InterpretedSource contexts

namespace Libraries

/-- The native Imported_Frame parameter is named Exports, unlike the common
name-reader Frame parameter. Keep that binding explicit in the call dictionary. -/
def importedFrame (library : Libraries) (text : Source) (exports : ParserState)
    (info : PackageBindings.Metadata) (position : Nat) : ParserState :=
  ApplicationPackageFrames.Native.importedFrameBody.eval
    (ApplicationPackageFrames.Native.withStateValidity library.names.validity
      (ApplicationPackageFrames.Native.frameCalls library.names.shared library.names.validity))
    (({text, info, position} : ApplicationPackageNames.Native.Inputs).locals.set .state "exports" exports)

def calls (library : Libraries) (other : Calls) : Calls :=
  {other with
    readContext := library.contexts.readContext
    takeToken := library.names.shared.composed.function .takeToken
    sparkPragmaAfter := ApplicationPackageNames.Native.readPragma library.names.header.names
    skipAt := library.names.shared.composed.function .skip
    importedFrame := library.importedFrame}

end Libraries

/-- Replace only the imports proved in this module. The original declaration,
statement, argument and import-identity readers are kept unchanged. -/
def boundaryModel (other : Calls) : Calls :=
  {other with
    readContext := fun text first packageFirst packageAfter => Names.readContext text first packageFirst packageAfter
    takeToken := tokenAfter
    sparkPragmaAfter := ApplicationPackageNames.sparkPragmaAfter
    skipAt := Compose.skipAt
    importedFrame := ApplicationPackageFrames.importedFrame}

theorem textOf_length {sources : ApplicationUnits.Bundle} (valid : sources.Valid) :
    (textOf sources).length = sources.used := by
  simp only [textOf, List.length_take, valid.1.1]
  exact Nat.min_eq_left valid.1.2.1

theorem textOf_valid {sources : ApplicationUnits.Bundle} (valid : sources.Valid) :
    ValidText (textOf sources) := by
  have main := sources.span_bounds valid .mainBody
  rw [ValidText, textOf_length valid]
  exact ⟨by omega, valid.1.2.1⟩

theorem main_context_domain {sources : ApplicationUnits.Bundle} {info : PackageBindings.Metadata}
    (valid : sources.Valid)
    (complete : PackageBindings.completeMetadata (metadataText (textOf sources)) info = true) :
    Names.ValidContext (textOf sources) (sources.units .mainBody).first info.nameFirst info.nameAfter := by
  have metadata : PackageBindings.validMetadata (metadataText (textOf sources)) info = true :=
    (Bool.and_eq_true_iff.mp complete).1
  have name := (PackageBindings.SourceBridge.validMetadata_name_and_main
    PackageBindings.Native.modelCalls PackageBindings.Native.model_primitives
    PackageBindings.Native.model_equations (metadataText (textOf sources)) info metadata).1
  have span := (ApplicationPackageNames.Native.validName_domain name).2
  have main := sources.span_bounds valid .mainBody
  exact ⟨main.1, by rw [textOf_length valid]; omega, Or.inr span⟩

namespace Libraries

theorem context (library : Libraries) (other : Calls) {sources : ApplicationUnits.Bundle}
    {info : PackageBindings.Metadata} (valid : sources.Valid)
    (complete : PackageBindings.completeMetadata (metadataText (textOf sources)) info = true) :
    contextClauses (library.calls other) sources info =
      contextClauses (boundaryModel other) sources info :=
  Names.interpreted_read library.contexts library.contextSource _ (textOf_valid valid)
    _ _ _ (main_context_domain valid complete)

theorem start (library : Libraries) (other : Calls) {sources : ApplicationUnits.Bundle}
    {info : PackageBindings.Metadata} (valid : sources.Valid)
    (complete : PackageBindings.completeMetadata (metadataText (textOf sources)) info = true) :
    mainStart (library.calls other) sources info = mainStart (boundaryModel other) sources info := by
  let text := textOf sources
  let first := (contextClauses (boundaryModel other) sources info).after
  let procedureEnd := tokenAfter text first (.word "procedure")
  let mainEnd := tokenAfter text procedureEnd (.word "main")
  let isEnd := tokenAfter text mainEnd (.word "is")
  have validText := textOf_valid valid
  have firstBound : ValidCursor text first := Names.readContext_bound text _ _ _
  have procedureBound : ValidCursor text procedureEnd := fixedAfter_result_bound text first "procedure" true (by decide)
  have mainBound : ValidCursor text mainEnd := fixedAfter_result_bound text procedureEnd "main" true (by decide)
  have isBound : ValidCursor text isEnd := fixedAfter_result_bound text mainEnd "is" true (by decide)
  have procedureEq : library.names.shared.composed.function .takeToken text first (.word "procedure") = procedureEnd :=
    interpreted_take _ library.names.shared.inherited text validText first _ firstBound (by unfold ValidToken; decide)
  have mainEq : library.names.shared.composed.function .takeToken text procedureEnd (.word "main") = mainEnd :=
    interpreted_take _ library.names.shared.inherited text validText procedureEnd _ procedureBound (by unfold ValidToken; decide)
  have isEq : library.names.shared.composed.function .takeToken text mainEnd (.word "is") = isEnd :=
    interpreted_take _ library.names.shared.inherited text validText mainEnd _ mainBound (by unfold ValidToken; decide)
  have pragmaEq := (ApplicationPackageNames.Native.imported_readers library.names.shared library.names.header).pragmaAfter
    text validText isEnd isBound
  unfold mainStart
  rw [library.context other valid complete]
  change ApplicationPackageNames.Native.readPragma library.names.header.names text
    (library.names.shared.composed.function .takeToken text
      (library.names.shared.composed.function .takeToken text
        (library.names.shared.composed.function .takeToken text first (.word "procedure")) (.word "main")) (.word "is")) = _
  rw [procedureEq, mainEq, isEq, pragmaEq]
  rfl

theorem frame (library : Libraries) {text : Source} (valid : ValidText text)
    (exports : ParserState) (framed : ReaderFrame text exports)
    (info : PackageBindings.Metadata) (position : Nat) :
    library.importedFrame text exports info position =
      ApplicationPackageFrames.importedFrame text exports info position :=
  ApplicationPackageFrames.Native.importedFrame_imports library.names.validity
    (ApplicationPackageFrames.Native.frameCalls library.names.shared library.names.validity)
    _ valid (framed.imported_types valid)

/-- Footer calls consume the result cursor supplied by the checked body reader;
its native position bound is sufficient, including the zero rejection cursor. -/
theorem footer (library : Libraries) {text : Source} (valid : ValidText text)
    (position : Nat) (bounded : ValidCursor text position) :
    library.names.shared.composed.function .skip text
      (library.names.shared.composed.function .takeToken text
        (library.names.shared.composed.function .takeToken text
          (library.names.shared.composed.function .takeToken text position (.word "end")) (.word "main")) (.symbol ";")) =
      Compose.skipAt text (tokenAfter text (tokenAfter text (tokenAfter text position (.word "end")) (.word "main")) (.symbol ";")) := by
  let ended := tokenAfter text position (.word "end")
  let named := tokenAfter text ended (.word "main")
  let finished := tokenAfter text named (.symbol ";")
  have endBound : ValidCursor text ended := fixedAfter_result_bound text position "end" true (by decide)
  have nameBound : ValidCursor text named := fixedAfter_result_bound text ended "main" true (by decide)
  have finishBound : ValidCursor text finished := fixedAfter_result_bound text named ";" false (by decide)
  have endEq : library.names.shared.composed.function .takeToken text position (.word "end") = ended :=
    interpreted_take _ library.names.shared.inherited text valid position _ bounded (by unfold ValidToken; decide)
  have nameEq : library.names.shared.composed.function .takeToken text ended (.word "main") = named :=
    interpreted_take _ library.names.shared.inherited text valid ended _ endBound (by unfold ValidToken; decide)
  have finishEq : library.names.shared.composed.function .takeToken text named (.symbol ";") = finished :=
    interpreted_take _ library.names.shared.inherited text valid named _ nameBound (by unfold ValidToken; decide)
  rw [endEq, nameEq, finishEq, interpreted_skip _ library.names.shared.inherited text valid finished finishBound]

end Libraries
end Silver.ApplicationPackageMain
