module

public import Silver.ApplicationPackageMainExportFacts
public import Silver.ApplicationPackageMainBodyComposition

@[expose] public section

namespace Silver.ApplicationPackageMain
open Compose Compose.Expressions Predicate ApplicationPackageDeclarations
open ApplicationPackageInitializers ApplicationPackageFrames ApplicationPackageRoutineClosedFrames

/-- Original Main imports and its optional argument declaration establish these
facts before any ordinary declaration is read. They contain no checked program
or semantic acceptance premise. -/
structure DeclarationEntry (text : Source) (frame : ParserState) : Prop where
  native : FunctionDeclarationNative.NativeValidState text frame
  static : ScalarExpression.ElaboratedEnvironment frame.scalarNames
  arrays : frame.arrayNames.names = []
  functions : frame.functions = {}
  procedures : frame.procedures = {}

theorem DeclarationEntry.stored {text frame} (entry : DeclarationEntry text frame) : frame.StoredArrays := by
  simp only [ParserState.StoredArrays, entry.arrays, List.not_mem_nil, false_implies, implies_true]

theorem DeclarationEntry.known {text frame} (entry : DeclarationEntry text frame) : CallableTypesKnown frame := by
  constructor <;> simp only [entry.functions, entry.procedures, List.not_mem_nil, false_implies, implies_true]

theorem imported_entry {text : Source} {exports : ParserState} {info : PackageBindings.Metadata}
    (framed : ReaderFrame text exports) (mainPositive : 1 ≤ (info.units .mainBody).first)
    (values : ExportFacts.Values exports) (tables : Tables exports) (position : Nat) :
    DeclarationEntry text (importedFrame text exports info position) := by
  have native := (imported_reader_frame text exports framed info mainPositive position).native
  refine ⟨native, ?_, ?_, ?_, ?_⟩
  all_goals
    unfold importedFrame
    dsimp only
    split
  · exact imported_elaborated exports info position values.static
  · exact ScalarExpression.static_empty
  · exact tables.arrayNames
  · rfl
  · exact values.functions
  · rfl
  · exact values.procedures
  · rfl

attribute [local irreducible] argumentParts

theorem DeclarationEntry.argument (library : DeclarationLibraries) {text : Source}
    (textValid : ValidText text) {frame : ParserState} (entry : DeclarationEntry text frame) :
    DeclarationEntry text (argumentAt text frame) := by
  refine ⟨library.argument_domain textValid frame entry.native, ?_, ?_, ?_, ?_⟩
  all_goals
    unfold argumentAt
    dsimp only
    split
  · exact ScalarExpression.static_empty
  · exact entry.static
  · rfl
  · exact entry.arrays
  · rfl
  · exact entry.functions
  · rfl
  · exact entry.procedures

attribute [local irreducible] Names.readContext tokenAfter Compose.argumentAt Compose.declarationsAt
  ApplicationPackageFrames.importedFrame

namespace DeclarationLibraries

/-- The actual optional argument consumes the qualified export frame. Rejected
imports/arguments retain the same full-domain entry theorem. -/
theorem argument_entry (library : DeclarationLibraries) (other : Calls)
    {sources : ApplicationUnits.Bundle} (valid : sources.Valid)
    (exports : ParserState) (framed : ReaderFrame (textOf sources) exports)
    (info : PackageBindings.Metadata) (typed : info.Typed)
    (complete : PackageBindings.completeMetadata (ApplicationPackageNames.metadataText (textOf sources)) info = true)
    (values : ExportFacts.Values exports) (tables : Tables exports) :
    DeclarationEntry (textOf sources) (argumentFrame (model other) sources exports info) := by
  have imported := imported_entry framed (imported_header_domain typed complete).2.1 values tables
    (mainStart (model other) sources info)
  change DeclarationEntry (textOf sources)
    (if (contextClauses (model other) sources info).argumentsWith then
      argumentAt (textOf sources) (importedFrame (textOf sources) exports info (mainStart (model other) sources info))
    else importedFrame (textOf sources) exports info (mainStart (model other) sources info))
  cases (contextClauses (model other) sources info).argumentsWith
  · exact imported
  · exact imported.argument library (textOf_valid valid)

theorem specification_argument_entry (library : DeclarationLibraries) (other : Calls)
    {sources : ApplicationUnits.Bundle} (valid : sources.Valid)
    {reader : BooleanElaboration.Native.Reader} {specText : Source} {seed : PackageBindings.Metadata}
    {specification : SpecificationResult}
    (specified : readSpecification reader specText seed = specification)
    (framed : ReaderFrame (textOf sources) specification.exports)
    (info : PackageBindings.Metadata) (typed : info.Typed)
    (complete : PackageBindings.completeMetadata (ApplicationPackageNames.metadataText (textOf sources)) info = true) :
    DeclarationEntry (textOf sources) (argumentFrame (model other) sources specification.exports info) := by
  have run := specified ▸ readSpecification_exec reader specText seed
  exact library.argument_entry other valid specification.exports framed info typed complete
    (ExportFacts.specification_values run) (specification_tables rfl rfl run)

end DeclarationLibraries
end Silver.ApplicationPackageMain

namespace Silver.ApplicationPackageInitializers
open Compose Compose.Expressions Predicate Bindings ApplicationPackageMain

/-- Every initialization and local callable check is discharged from the
original declaration inventory and the source-derived imported entry. -/
theorem MainInventory.discharged_entry {text : Source} {arguments : Bool} {entry final : ParserState}
    {inventory : MainInventory} (source : inventory.SourceAt text arguments entry final)
    (textValid : ValidText text) (domain : DeclarationEntry text entry) :
    Predicate.discharged (inventory.obligations entry final) = true :=
  MainInventory.discharged source textValid domain.native.base domain.native.bounds.normal domain.native.ready
    domain.static domain.native.base.2.2.2.2.2.1.1 domain.stored
    domain.native.base.2.2.2.2.2.2.2.1 domain.native.base.arrayTypes domain.known

/-- The two local callable signature tables come from exactly the source
inventory. The empty imported catalogs are derived from Specification. -/
theorem MainInventory.catalogs_entry {text : Source} {arguments : Bool} {entry final : ParserState}
    {inventory : MainInventory} (source : inventory.SourceAt text arguments entry final)
    (textValid : ValidText text) (domain : DeclarationEntry text entry) :
    catalogSignatures final.functions final.arrayNames.types = inventory.functions.map ScalarFunctions.Definition.signature ∧
    ProcedureBindings.catalogSignatures final.procedures final.arrayNames.types =
      inventory.procedures.map ScalarProcedures.Definition.signature := by
  have checked := source.callables.checked textValid domain.native.base domain.known
  simpa only [domain.functions, domain.procedures, catalogSignatures, ProcedureBindings.catalogSignatures,
    List.map_nil, List.nil_append] using checked.2.2

end Silver.ApplicationPackageInitializers
