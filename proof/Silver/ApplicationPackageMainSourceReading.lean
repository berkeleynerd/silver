module

public import Silver.ApplicationPackageMainBodyComposition

@[expose] public section

namespace Silver.ApplicationPackageMain.BodyLibraries
open Compose Compose.Expressions Predicate ApplicationPackageDeclarations ApplicationPackageBodies.Recursive

/-- The original footer cannot turn a failed body cursor into an accepted Main.
This uses the three actual Ada token reads, not a semantic body checker. -/
theorem body_present (library : BodyLibraries) (other : Calls)
    {sources : ApplicationUnits.Bundle} {exports : ParserState} {info : PackageBindings.Metadata}
    (accepted : (packageMainAt (library.model other) sources exports info).accepted = true) :
    (library.result other sources exports info).scan.position ≠ 0 := by
  have finish := ((packageMainAt_accepted_iff _ _ _ _).mp accepted).footerPresent
  change fixedAfter (textOf sources)
    (fixedAfter (textOf sources)
      (fixedAfter (textOf sources) (library.result other sources exports info).scan.position "end" true)
      "main" true) ";" false ≠ 0 at finish
  exact model_fixed_input_nonzero _ _ "end" true
    (model_fixed_input_nonzero _ _ "main" true (model_fixed_input_nonzero _ _ ";" false finish))

/-- Acceptance of the source-interpreted Main constructs the complete original
body history, preserving every conditional arm, loop and sequential tail. The
history contains source reader equations; semantic checking follows separately. -/
theorem accepted_tree (library : BodyLibraries) (other : Calls)
    {sources : ApplicationUnits.Bundle} (valid : sources.Valid)
    (exports : ParserState) (framed : ReaderFrame (textOf sources) exports)
    (info : PackageBindings.Metadata) (typed : info.Typed)
    (complete : PackageBindings.completeMetadata (ApplicationPackageNames.metadataText (textOf sources)) info = true)
    (accepted : (packageMainAt (library.calls other) sources exports info).accepted = true) :
    TailTree (nativeReaders library.readers) (library.input other sources exports info)
      .endOnly true false (library.result other sources exports info) := by
  rw [library.main_meaning other valid exports framed info typed complete] at accepted
  exact (library.outcome other valid exports framed info typed complete).tree
    (library.body_present other accepted)

/-- The source-defined Main body produces the same original metadata/catalogs
and effect flags as the analyzed declaration/body results. -/
theorem accepted_result (library : BodyLibraries) (other : Calls)
    {sources : ApplicationUnits.Bundle} (valid : sources.Valid)
    (exports : ParserState) (framed : ReaderFrame (textOf sources) exports)
    (info : PackageBindings.Metadata) (typed : info.Typed)
    (complete : PackageBindings.completeMetadata (ApplicationPackageNames.metadataText (textOf sources)) info = true)
    (accepted : (packageMainAt (library.calls other) sources exports info).accepted = true) :
    packageMainAt (library.calls other) sources exports info =
      acceptedResult (library.model other) sources exports info := by
  rw [library.main_meaning other valid exports framed info typed complete] at accepted ⊢
  exact packageMainAt_result accepted

end Silver.ApplicationPackageMain.BodyLibraries
