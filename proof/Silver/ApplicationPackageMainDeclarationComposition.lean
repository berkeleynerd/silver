module

public import Silver.ApplicationPackageMainDomains

@[expose] public section

namespace Silver.ApplicationPackageMain.DeclarationLibraries
open Compose Compose.Expressions ApplicationPackageDeclarations ApplicationPackageFrames

set_option backward.dsimp.instances true

attribute [local irreducible] Names.readContext tokenAfter Compose.argumentAt Compose.declarationsAt
  ApplicationPackageFrames.importedFrame

theorem context_meaning (library : DeclarationLibraries) (other : Calls)
    {sources : ApplicationUnits.Bundle} {info : PackageBindings.Metadata} (valid : sources.Valid)
    (complete : PackageBindings.completeMetadata (ApplicationPackageNames.metadataText (textOf sources)) info = true) :
    contextClauses (library.calls other) sources info = contextClauses (model other) sources info :=
  library.identity.boundary.context other valid complete

theorem start_meaning (library : DeclarationLibraries) (other : Calls)
    {sources : ApplicationUnits.Bundle} {info : PackageBindings.Metadata} (valid : sources.Valid)
    (complete : PackageBindings.completeMetadata (ApplicationPackageNames.metadataText (textOf sources)) info = true) :
    mainStart (library.calls other) sources info = mainStart (model other) sources info :=
  library.identity.boundary.start other valid complete

theorem start_bounded (other : Calls) (sources : ApplicationUnits.Bundle) (info : PackageBindings.Metadata) :
    ValidCursor (textOf sources) (mainStart (model other) sources info) := by
  dsimp only [mainStart, model, IdentityLibraries.model, boundaryModel]
  exact fixedAfter_result_bound (textOf sources) _ ";" false (by decide)

/-- Original optional argument declaration, after actual context/name/frame
imports. Its domain is derived from the native Main precondition, not from
acceptance of either Main or the declaration reader. -/
theorem argument_frame (library : DeclarationLibraries) (other : Calls)
    {sources : ApplicationUnits.Bundle} (valid : sources.Valid)
    (exports : ParserState) (framed : ReaderFrame (textOf sources) exports)
    (info : PackageBindings.Metadata) (typed : info.Typed)
    (complete : PackageBindings.completeMetadata (ApplicationPackageNames.metadataText (textOf sources)) info = true) :
    argumentFrame (library.calls other) sources exports info = argumentFrame (model other) sources exports info ∧
      FunctionDeclarationNative.NativeValidState (textOf sources) (argumentFrame (model other) sources exports info) := by
  let text := textOf sources
  let position := mainStart (model other) sources info
  let frame := importedFrame text exports info position
  have domain := (imported_reader_frame text exports framed info
    (imported_header_domain typed complete).2.1 position).native
  have textValid := textOf_valid valid
  constructor
  · unfold argumentFrame
    rw [library.context_meaning other valid complete, library.start_meaning other valid complete]
    change (if (contextClauses (model other) sources info).argumentsWith then
      library.identity.boundary.names.shared.composed.function .argument text
        (library.identity.boundary.importedFrame text exports info position)
      else library.identity.boundary.importedFrame text exports info position) = _
    rw [library.identity.boundary.frame textValid exports framed info position,
      library.argument textValid frame domain]
    rfl
  · change FunctionDeclarationNative.NativeValidState text
      (if (contextClauses (model other) sources info).argumentsWith then argumentAt text frame else frame)
    cases (contextClauses (model other) sources info).argumentsWith
    · exact domain
    · exact library.argument_domain textValid frame domain

/-- All inherited declarations consume the derived argument/frame domain.
Rejected declarations are included in both exact equality and result contract. -/
theorem declarations_frame (library : DeclarationLibraries) (other : Calls)
    {sources : ApplicationUnits.Bundle} (valid : sources.Valid)
    (exports : ParserState) (framed : ReaderFrame (textOf sources) exports)
    (info : PackageBindings.Metadata) (typed : info.Typed)
    (complete : PackageBindings.completeMetadata (ApplicationPackageNames.metadataText (textOf sources)) info = true) :
    declarationsFrame (library.calls other) sources exports info = declarationsFrame (model other) sources exports info ∧
      FunctionDeclarationNative.NativeValidState (textOf sources) (declarationsFrame (model other) sources exports info) := by
  have argument := library.argument_frame other valid exports framed info typed complete
  constructor
  · unfold declarationsFrame
    rw [argument.1, library.context_meaning other valid complete]
    exact library.declarations (textOf_valid valid) _ _ argument.2
  · exact library.declarations_domain (textOf_valid valid) _ _ argument.2

/-- Exact Main declaration-to-body transition. Every imported helper call has
its full native domain, including the original begin-token reader on rejection. -/
theorem body_frame (library : DeclarationLibraries) (other : Calls)
    {sources : ApplicationUnits.Bundle} (valid : sources.Valid)
    (exports : ParserState) (framed : ReaderFrame (textOf sources) exports)
    (info : PackageBindings.Metadata) (typed : info.Typed)
    (complete : PackageBindings.completeMetadata (ApplicationPackageNames.metadataText (textOf sources)) info = true) :
    bodyFrame (library.calls other) sources exports info = bodyFrame (model other) sources exports info ∧
      FunctionDeclarationNative.NativeValidState (textOf sources) (bodyFrame (model other) sources exports info) := by
  have declarations := library.declarations_frame other valid exports framed info typed complete
  constructor
  · unfold bodyFrame
    rw [declarations.1]
    have token := interpreted_take _ library.helpers.toRawHelperEquations (textOf sources)
      (textOf_valid valid) (declarationsFrame (model other) sources exports info).position (.word "begin")
      declarations.2.base.1 (by unfold ValidToken; decide)
    dsimp +instances only [calls, IdentityLibraries.calls, Libraries.calls]
    rw [token]
    simp only [model, IdentityLibraries.model, boundaryModel, tokenAfter, ShellToken.word, spelling, isWord]
  · exact begin_frame_domain _ declarations.2

end Silver.ApplicationPackageMain.DeclarationLibraries
