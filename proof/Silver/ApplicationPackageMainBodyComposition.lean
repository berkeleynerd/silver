module

public import Silver.ApplicationPackageMainBodyDomains
public import Silver.ApplicationPackageRecursiveOutcomes

@[expose] public section

namespace Silver.ApplicationPackageMain
open Compose Compose.Expressions Predicate ApplicationPackages ApplicationPackageDeclarations
open ApplicationPackageBodies.Recursive

/-- Main's original imported readers. The recursive interface consists of
equations for the typed native bodies on their native domains, not an assumed
accepted decoder, semantic checker or source/model equality. -/
structure BodyLibraries where
  declarations : DeclarationLibraries
  flow : FlowLibraries
  readers : Readers
  source : Equations (nativeReaders readers) NativeDomain

namespace BodyLibraries

def bodyCalls (library : BodyLibraries) (other : Calls) : Calls :=
  {library.flow.calls other with
    applicationTail := library.readers.statement.applicationTail
    completed := Predicate.completed}

def calls (library : BodyLibraries) (other : Calls) : Calls :=
  library.declarations.calls (library.bodyCalls other)

def model (library : BodyLibraries) (other : Calls) : Calls :=
  DeclarationLibraries.model (library.bodyCalls other)

def input (library : BodyLibraries) (other : Calls) (sources : ApplicationUnits.Bundle)
    (exports : ParserState) (info : PackageBindings.Metadata) : ApplicationPackageBodies.Statement.Input :=
  DeclarationLibraries.bodyInput other library.flow sources exports info

def result (library : BodyLibraries) (other : Calls) (sources : ApplicationUnits.Bundle)
    (exports : ParserState) (info : PackageBindings.Metadata) : ApplicationScan :=
  (nativeReaders library.readers).tailResult (library.input other sources exports info) .endOnly true

theorem model_bodyScan (library : BodyLibraries) (other : Calls)
    (sources : ApplicationUnits.Bundle) (exports : ParserState) (info : PackageBindings.Metadata) :
    bodyScan (library.model other) sources exports info = library.result other sources exports info := rfl

theorem input_domain (library : BodyLibraries) (other : Calls)
    {sources : ApplicationUnits.Bundle} (valid : sources.Valid)
    (exports : ParserState) (framed : ReaderFrame (textOf sources) exports)
    (info : PackageBindings.Metadata) (typed : info.Typed)
    (complete : PackageBindings.completeMetadata (ApplicationPackageNames.metadataText (textOf sources)) info = true) :
    NativeDomain (library.input other sources exports info) :=
  library.declarations.body_input_domain other library.flow valid exports framed info typed complete

/-- Full body return contracts, including rejection. Main establishes every
callee domain from its original imported frame and declarations. -/
theorem outcome (library : BodyLibraries) (other : Calls)
    {sources : ApplicationUnits.Bundle} (valid : sources.Valid)
    (exports : ParserState) (framed : ReaderFrame (textOf sources) exports)
    (info : PackageBindings.Metadata) (typed : info.Typed)
    (complete : PackageBindings.completeMetadata (ApplicationPackageNames.metadataText (textOf sources)) info = true) :
    TailOutcome (nativeReaders library.readers) (library.input other sources exports info) .endOnly true :=
  (library.source.outcomes (library.input_domain other valid exports framed info typed complete) typed).2 .endOnly true

set_option backward.dsimp.instances true

attribute [local irreducible] Names.readContext Compose.argumentAt Compose.declarationsAt
  ApplicationPackageFrames.importedFrame

theorem bodyScan_meaning (library : BodyLibraries) (other : Calls)
    {sources : ApplicationUnits.Bundle} (valid : sources.Valid)
    (exports : ParserState) (framed : ReaderFrame (textOf sources) exports)
    (info : PackageBindings.Metadata) (typed : info.Typed)
    (complete : PackageBindings.completeMetadata (ApplicationPackageNames.metadataText (textOf sources)) info = true) :
    bodyScan (library.calls other) sources exports info = library.result other sources exports info := by
  unfold bodyScan calls
  rw [(library.declarations.body_frame (library.bodyCalls other) valid exports framed info typed complete).1]
  rfl

/-- Each footer token sees the bounded cursor established by the original
recursive reader's complete return contract. No successful body is assumed. -/
theorem following_meaning (library : BodyLibraries) (other : Calls)
    {sources : ApplicationUnits.Bundle} (valid : sources.Valid)
    (exports : ParserState) (framed : ReaderFrame (textOf sources) exports)
    (info : PackageBindings.Metadata) (typed : info.Typed)
    (complete : PackageBindings.completeMetadata (ApplicationPackageNames.metadataText (textOf sources)) info = true) :
    following (library.calls other) sources exports info = following (library.model other) sources exports info := by
  have bound := (library.outcome other valid exports framed info typed complete).scan.position
  have textValid := textOf_valid valid
  let text := textOf sources
  let position := (library.result other sources exports info).scan.position
  let ended := tokenAfter text position (.word "end")
  let named := tokenAfter text ended (.word "main")
  have endEq : library.declarations.identity.boundary.names.shared.composed.function .takeToken
      text position (.word "end") = ended :=
    interpreted_take _ library.declarations.helpers.toRawHelperEquations text textValid
      position (.word "end") bound (by unfold ValidToken; decide)
  have endBound : ValidCursor text ended := fixedAfter_result_bound text position "end" true (by decide)
  have nameEq : library.declarations.identity.boundary.names.shared.composed.function .takeToken
      text ended (.word "main") = named :=
    interpreted_take _ library.declarations.helpers.toRawHelperEquations text textValid
      ended (.word "main") endBound (by unfold ValidToken; decide)
  have nameBound : ValidCursor text named := fixedAfter_result_bound text ended "main" true (by decide)
  have finishEq := interpreted_take _ library.declarations.helpers.toRawHelperEquations text textValid
    named (.symbol ";") nameBound (by unfold ValidToken; decide)
  unfold following
  rw [library.bodyScan_meaning other valid exports framed info typed complete, library.model_bodyScan]
  change library.declarations.identity.boundary.names.shared.composed.function .takeToken text
    (library.declarations.identity.boundary.names.shared.composed.function .takeToken text
      (library.declarations.identity.boundary.names.shared.composed.function .takeToken text position (.word "end"))
      (.word "main")) (.symbol ";") = _
  rw [endEq, nameEq, finishEq]
  rfl

theorem following_bound (library : BodyLibraries) (other : Calls)
    (sources : ApplicationUnits.Bundle) (exports : ParserState) (info : PackageBindings.Metadata) :
    ValidCursor (textOf sources) (following (library.model other) sources exports info) :=
  fixedAfter_result_bound _ _ ";" false (by decide)

theorem eof_meaning (library : BodyLibraries) (other : Calls)
    {sources : ApplicationUnits.Bundle} (valid : sources.Valid)
    (exports : ParserState) (framed : ReaderFrame (textOf sources) exports)
    (info : PackageBindings.Metadata) (typed : info.Typed)
    (complete : PackageBindings.completeMetadata (ApplicationPackageNames.metadataText (textOf sources)) info = true) :
    (library.calls other).skipAt (textOf sources) (following (library.calls other) sources exports info) =
      (library.model other).skipAt (textOf sources) (following (library.model other) sources exports info) := by
  rw [library.following_meaning other valid exports framed info typed complete]
  exact interpreted_skip _ library.declarations.helpers.toRawHelperEquations _ (textOf_valid valid) _
    (library.following_bound other sources exports info)

/-- The whole original Main reader composes its interpreted imports on the
complete declared domain, including every rejected branch. Recursive calls are
still the original readers, with their source-tree semantics proved separately. -/
theorem main_meaning (library : BodyLibraries) (other : Calls)
    {sources : ApplicationUnits.Bundle} (valid : sources.Valid)
    (exports : ParserState) (framed : ReaderFrame (textOf sources) exports)
    (info : PackageBindings.Metadata) (typed : info.Typed)
    (complete : PackageBindings.completeMetadata (ApplicationPackageNames.metadataText (textOf sources)) info = true) :
    packageMainAt (library.calls other) sources exports info =
      packageMainAt (library.model other) sources exports info := by
  have imported := library.declarations.identity.import_guard (library.bodyCalls other) sources info
  have context := library.declarations.context_meaning (library.bodyCalls other) valid complete
  have start := library.declarations.start_meaning (library.bodyCalls other) valid complete
  have argument := (library.declarations.argument_frame (library.bodyCalls other)
    valid exports framed info typed complete).1
  have body := (library.declarations.body_frame (library.bodyCalls other)
    valid exports framed info typed complete).1
  change (library.calls other).samePackageSpelling (textOf sources) info
      ((library.calls other).importedPackage (sources.unitSource .mainBody)) =
    (library.model other).samePackageSpelling (textOf sources) info
      ((library.model other).importedPackage (sources.unitSource .mainBody)) at imported
  change contextClauses (library.calls other) sources info =
    contextClauses (library.model other) sources info at context
  change mainStart (library.calls other) sources info =
    mainStart (library.model other) sources info at start
  change argumentFrame (library.calls other) sources exports info =
    argumentFrame (library.model other) sources exports info at argument
  change bodyFrame (library.calls other) sources exports info =
    bodyFrame (library.model other) sources exports info at body
  have scan : bodyScan (library.calls other) sources exports info =
      bodyScan (library.model other) sources exports info :=
    (library.bodyScan_meaning other valid exports framed info typed complete).trans
      (library.model_bodyScan other sources exports info).symm
  unfold packageMainAt
  rw [library.eof_meaning other valid exports framed info typed complete,
    library.following_meaning other valid exports framed info typed complete]
  rw [imported, context, start, argument, body, scan]
  unfold acceptedResult
  rw [body, scan, context]
  rfl

/-- Arbitrary original local storage is retained in the typed source execution;
only the native parameter preconditions are needed to compose the imports. -/
theorem native_meaning (library : BodyLibraries) (other : Calls) (locals : ApplicationNative.Locals)
    (valid : (locals .bundle "sources").Valid)
    (framed : ReaderFrame (textOf (locals .bundle "sources")) (locals .state "exports"))
    (typed : (locals .metadata "info").Typed)
    (complete : PackageBindings.completeMetadata
      (ApplicationPackageNames.metadataText (textOf (locals .bundle "sources"))) (locals .metadata "info") = true) :
    Native.mainBody.eval (Native.modelFunctions (library.calls other)) locals =
      packageMainAt (library.model other) (locals .bundle "sources")
        (locals .state "exports") (locals .metadata "info") := by
  rw [Native.mainBody_meaning]
  exact library.main_meaning other valid _ framed _ typed complete

end BodyLibraries
end Silver.ApplicationPackageMain
