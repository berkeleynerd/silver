module

public import Silver.ApplicationPackageMainInitializerEntry
public import Silver.ApplicationPackageMainEntryCursors
public import Silver.ApplicationPackageMainRecursiveDomain
public import Silver.ApplicationPackageMainSourceReading
public import Silver.ApplicationPackageSourceFunctionCalls

@[expose] public section

namespace Silver.ApplicationPackageMain
open Compose Compose.Expressions Predicate ApplicationPackageDeclarations ApplicationPackageFrames
open ApplicationPackageBodies ApplicationPackageInitializers ApplicationPackageObjectRows

set_option backward.dsimp.instances true

private theorem argument_input_present {text fallback : Source} {before after : ParserState}
    (read : ArgumentAt text before fallback after) : before.position ≠ 0 := by
  intro zero
  cases read with
  | @argument parts _ partsEq allowed _ _ _ =>
    have first := (newNameAllowed_span text before parts.first parts.after true allowed).1
    have missing : parts.first = 0 := by
      rw [← partsEq]
      simp only [argumentParts, argumentFirst, zero, skipAt, ite_true]
    omega

private theorem imported_position {text : Source} {exports : ParserState} {info : PackageBindings.Metadata}
    {position : Nat} (present : (importedFrame text exports info position).position ≠ 0) :
    (importedFrame text exports info position).position = position := by
  unfold importedFrame at present ⊢
  dsimp only at present ⊢
  split at present
  · rename_i valid
    rw [ite_eq_left valid]
    rfl
  · exact False.elim (present rfl)

private theorem complete_name_positive {text : Source} {info : PackageBindings.Metadata}
    (complete : PackageBindings.completeMetadata (ApplicationPackageNames.metadataText text) info = true) :
    info.nameFirst ≠ 0 := by
  have metadata := PackageBindings.SourceBridge.validMetadata_name_and_main
    PackageBindings.Native.modelCalls PackageBindings.Native.model_primitives
    PackageBindings.Native.model_equations (ApplicationPackageNames.metadataText text) info
    (Bool.and_eq_true_iff.mp complete).1
  exact Nat.ne_of_gt (ApplicationPackageNames.Native.validName_domain metadata.1).2.1

attribute [local irreducible] Names.readContext Compose.argumentAt Compose.declarationsAt
  ApplicationPackageFrames.importedFrame

/-- Qualified imports contain no unqualified scalar. Every optional Main
argument advances from that exact imported cursor and preserves the scalar
origins, including when the package has no public scalar objects. -/
theorem argument_entry_origins (other : Calls) {sources : ApplicationUnits.Bundle}
    (_valid : sources.Valid) (exports : ParserState) (framed : ReaderFrame (textOf sources) exports)
    (info : PackageBindings.Metadata) (typed : info.Typed)
    (complete : PackageBindings.completeMetadata (ApplicationPackageNames.metadataText (textOf sources)) info = true)
    (started : mainStart (DeclarationLibraries.model other) sources info ≠ 0)
    (present : (argumentFrame (DeclarationLibraries.model other) sources exports info).position ≠ 0) :
    ScalarsFrom (sources.units .mainBody).first
      (argumentFrame (DeclarationLibraries.model other) sources exports info).scalarNames ∧
    (sources.units .mainBody).first ≤
      (argumentFrame (DeclarationLibraries.model other) sources exports info).position := by
  let text := textOf sources
  let start := mainStart (DeclarationLibraries.model other) sources info
  let frame := importedFrame text exports info start
  have afterStart := main_start_after other sources info started
  have source : ScalarsFrom (sources.units .mainBody).first frame.scalarNames :=
    imported_scalars_checked (complete_name_positive complete)
  have domain : ReaderFrame text frame :=
    imported_reader_frame text exports framed info (imported_header_domain typed complete).2.1 start
  change (if (contextClauses (DeclarationLibraries.model other) sources info).argumentsWith then
    argumentAt text frame else frame).position ≠ 0 at present
  change ScalarsFrom (sources.units .mainBody).first
      (if (contextClauses (DeclarationLibraries.model other) sources info).argumentsWith then
        argumentAt text frame else frame).scalarNames ∧
    (sources.units .mainBody).first ≤
      (if (contextClauses (DeclarationLibraries.model other) sources info).argumentsWith then
        argumentAt text frame else frame).position
  cases args : (contextClauses (DeclarationLibraries.model other) sources info).argumentsWith with
  | false =>
    simp only [args, Bool.false_eq_true, ite_false] at present ⊢
    exact ⟨source, Nat.le_trans (Nat.le_of_lt afterStart) (Nat.le_of_eq (imported_position present).symm)⟩
  | true =>
    simp only [args, ite_true] at present ⊢
    obtain ⟨fallback, read⟩ := argument_sound text frame present
    have imported := imported_position (argument_input_present read)
    have advanced := argument_after domain.native.base.1 read
    refine ⟨argument_scalar_origins source read, ?_⟩
    change (sources.units .mainBody).first ≤ (argumentAt text frame).position
    exact Nat.le_of_lt (Nat.lt_trans (imported.symm ▸ afterStart) advanced)

namespace BodyLibraries

/-- The native accepted Main supplies a syntax-only declaration inventory.
The imported entry facts are derived from its original Specification result. -/
theorem declaration_inventory (library : BodyLibraries) (other : Calls)
    {sources : ApplicationUnits.Bundle} (valid : sources.Valid)
    {reader : BooleanElaboration.Native.Reader} {specText : Source} {seed : PackageBindings.Metadata}
    {specification : SpecificationResult}
    (specified : readSpecification reader specText seed = specification)
    (framed : ReaderFrame (textOf sources) specification.exports)
    (info : PackageBindings.Metadata) (typed : info.Typed)
    (complete : PackageBindings.completeMetadata (ApplicationPackageNames.metadataText (textOf sources)) info = true)
    (accepted : (packageMainAt (library.calls other) sources specification.exports info).accepted = true) :
    ∃ inventory : MainInventory,
      inventory.SourceAt (textOf sources) (contextClauses (library.model other) sources info).argumentsWith
        (argumentFrame (library.model other) sources specification.exports info)
        (declarationsFrame (library.model other) sources specification.exports info) ∧
      DeclarationEntry (textOf sources) (argumentFrame (library.model other) sources specification.exports info) := by
  have modelAccepted := (library.main_meaning other valid specification.exports framed info typed complete) ▸ accepted
  have admitted := (packageMainAt_accepted_iff _ _ _ _).mp modelAccepted
  have present : (declarationsFrame (library.model other) sources specification.exports info).position ≠ 0 :=
    fixedAfter_nonzero admitted.bodyPresent
  have entry := library.declarations.specification_argument_entry (library.bodyCalls other) valid specified framed info typed complete
  obtain ⟨inventory, source⟩ := main_inventory (textOf sources) _ _ (textOf_valid valid) entry.native.base present
  exact ⟨inventory, source, entry⟩

/-- Metadata modes and function-write restrictions are derived independently
from the original package histories. The environment equations identify exact
signature tables; they do not assert successful semantic checking. -/
theorem entry_scope (library : BodyLibraries) (other : Calls)
    {sources : ApplicationUnits.Bundle} (valid : sources.Valid)
    (exports : ParserState) (framed : ReaderFrame (textOf sources) exports)
    (info : PackageBindings.Metadata) (typed : info.Typed)
    (complete : PackageBindings.completeMetadata (ApplicationPackageNames.metadataText (textOf sources)) info = true)
    (units : info.units = sources.units)
    (declared : DeclaredFormalModes info) (writes : CompletedFunctionWrites info)
    (environment : Applications.Environment)
    (packages : environment.packages.signatures = (ApplicationPackageCalls.completedEnvironment info).map Packages.RoutineEffects.signature)
    (functions : catalogSignatures (declarationsFrame (library.model other) sources exports info).functions
      (declarationsFrame (library.model other) sources exports info).arrayNames.types = environment.localFunctions.signatures)
    (procedures : ProcedureBindings.catalogSignatures (declarationsFrame (library.model other) sources exports info).procedures
      (declarationsFrame (library.model other) sources exports info).arrayNames.types = environment.localProcedures.signatures)
    (accepted : (packageMainAt (library.calls other) sources exports info).accepted = true) :
    SourceSyntax.MainScope environment (sources.units .mainBody).first (library.input other sources exports info) := by
  have modelAccepted := (library.main_meaning other valid exports framed info typed complete) ▸ accepted
  have admitted := (packageMainAt_accepted_iff _ _ _ _).mp modelAccepted
  have argument := library.declarations.argument_frame (library.bodyCalls other) valid exports framed info typed complete
  have declaration := library.declarations.declarations_frame (library.bodyCalls other) valid exports framed info typed complete
  have body := library.declarations.body_frame (library.bodyCalls other) valid exports framed info typed complete
  have present : (declarationsFrame (library.model other) sources exports info).position ≠ 0 :=
    fixedAfter_nonzero admitted.bodyPresent
  obtain ⟨strings, read⟩ := declarations_sound (textOf sources) _ _ present
  have entry := argument_entry_origins (library.bodyCalls other) valid exports framed info typed complete
    admitted.startPresent admitted.argumentPresent
  have origins := declarations_scalar_origins (textOf_valid valid) argument.2.base read entry.2 entry.1
  have later := declarations_after (textOf_valid valid) argument.2.base present
  have begun := (fixed_window (by decide) admitted.bodyPresent).1
  have sourcePosition : (library.input other sources exports info).input.scan.position =
      (bodyFrame (library.model other) sources exports info).position := by
    change (library.flow.wrappers.bodyOf _).position = _
    rw [library.flow.body_meaning _ body.2.base.2.2.2.2.2.1.1]
    rfl
  refine ⟨body.2.bounds.normal, rfl, typed, declared, writes,
    context_scalar_origins origins, ?_, ?_, packages, functions, procedures⟩
  · intro state member
    have before := metadata_states_before_main (Bool.and_eq_true_iff.mp complete).1 state member
    simpa only [units] using before
  · rw [sourcePosition]
    change (sources.units .mainBody).first ≤ tokenAfter (textOf sources)
      (declarationsFrame (library.model other) sources exports info).position (.word "begin")
    exact Nat.le_trans entry.2 (Nat.le_trans later (Nat.le_of_lt begun))

theorem original_entry_scope (library : BodyLibraries) (other : Calls)
    {reader : BooleanElaboration.Native.Reader} {completion : CompletionCalls} {calls : ApplicationAdmission.Calls}
    {sources : ApplicationUnits.Bundle} {result : ApplicationAdmission.AnalysisResult}
    (parsed : ApplicationAdmission.ParsedPackage reader completion calls sources result)
    (valid : sources.Valid) (framed : ReaderFrame (textOf sources) parsed.specification.exports)
    (typed : parsed.body.info.Typed) (units : parsed.body.info.units = sources.units)
    (environment : Applications.Environment)
    (packages : environment.packages.signatures = (ApplicationPackageCalls.completedEnvironment parsed.body.info).map Packages.RoutineEffects.signature)
    (functions : catalogSignatures (declarationsFrame (library.model other) sources parsed.specification.exports parsed.body.info).functions
      (declarationsFrame (library.model other) sources parsed.specification.exports parsed.body.info).arrayNames.types = environment.localFunctions.signatures)
    (procedures : ProcedureBindings.catalogSignatures (declarationsFrame (library.model other) sources parsed.specification.exports parsed.body.info).procedures
      (declarationsFrame (library.model other) sources parsed.specification.exports parsed.body.info).arrayNames.types = environment.localProcedures.signatures)
    (accepted : (packageMainAt (library.calls other) sources parsed.specification.exports parsed.body.info).accepted = true) :
    SourceSyntax.MainScope environment (sources.units .mainBody).first
      (library.input other sources parsed.specification.exports parsed.body.info) :=
  library.entry_scope other valid parsed.specification.exports framed parsed.body.info typed parsed.complete units
    (original_formal_modes parsed).2.1 (original_function_writes parsed).1 environment packages functions procedures accepted

end BodyLibraries
end Silver.ApplicationPackageMain
