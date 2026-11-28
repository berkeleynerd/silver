module

public import Silver.ApplicationPackageMainEntryScope
public import Silver.ApplicationPackageMainRecursiveMeaning

@[expose] public section

namespace Silver.ApplicationPackageInitializers
open Compose Compose.Expressions Predicate ApplicationPackageMain

/-- Executable local meanings are compiled from the exact source declaration
inventory. Their type and checking properties are proved below, not stored as
premises in either this environment or the original source histories. -/
def MainInventory.localFunctions (inventory : MainInventory) : ScalarFunctions.Environment :=
  ScalarFunctions.compileDefinitions inventory.functions

def MainInventory.localProcedures (inventory : MainInventory) : ScalarProcedures.Environment :=
  ScalarProcedures.compileDefinitions inventory.localFunctions inventory.procedures

def MainInventory.environment (inventory : MainInventory) (packages : Packages.SharedEnvironment) :
    Applications.Environment :=
  ⟨inventory.localFunctions, inventory.localProcedures, packages⟩

theorem MainInventory.local_libraries_checked {text : Source} {arguments : Bool}
    {entry final : ParserState} {inventory : MainInventory}
    (source : inventory.SourceAt text arguments entry final)
    (textValid : ValidText text) (domain : DeclarationEntry text entry) :
    ScalarFunctions.DefinitionsChecked [] inventory.functions ∧
      ScalarProcedures.DefinitionsChecked inventory.localFunctions.signatures [] inventory.procedures := by
  have checked := source.callables.checked textValid domain.native.base domain.known
  have catalogs := MainInventory.catalogs_entry source textValid domain
  constructor
  · simpa only [domain.functions, catalogSignatures, List.map_nil] using checked.1
  · simpa only [catalogs.1, domain.procedures, ProcedureBindings.catalogSignatures, List.map_nil,
      MainInventory.localFunctions, ScalarFunctions.compileDefinitions_signatures] using checked.2.1

/-- All source-local definitions are safe over their full formal domains,
including definitions never called by Main. Package validity is a separate
source-derived result owned by the application join. -/
theorem MainInventory.local_libraries_valid {text : Source} {arguments : Bool}
    {entry final : ParserState} {inventory : MainInventory}
    (source : inventory.SourceAt text arguments entry final)
    (textValid : ValidText text) (domain : DeclarationEntry text entry) :
    inventory.localFunctions.Valid ∧ inventory.localProcedures.Valid ∧
      ScalarFunctions.DefinitionsSafe .empty inventory.functions ∧
      ScalarProcedures.DefinitionsSafe inventory.localFunctions .empty inventory.procedures := by
  have checked := MainInventory.local_libraries_checked source textValid domain
  have functions := ScalarFunctions.compileDefinitions_valid checked.1
  exact ⟨functions, ScalarProcedures.compileDefinitions_valid functions checked.2,
    ScalarFunctions.checked_definitions_safe checked.1,
    ScalarProcedures.checked_definitions_safe functions checked.2⟩

theorem MainInventory.environment_signatures {text : Source} {arguments : Bool}
    {entry final : ParserState} {inventory : MainInventory}
    (source : inventory.SourceAt text arguments entry final)
    (textValid : ValidText text) (domain : DeclarationEntry text entry)
    (packages : Packages.SharedEnvironment) :
    catalogSignatures final.functions final.arrayNames.types =
      (inventory.environment packages).localFunctions.signatures ∧
    ProcedureBindings.catalogSignatures final.procedures final.arrayNames.types =
      (inventory.environment packages).localProcedures.signatures := by
  simpa only [environment, localFunctions, localProcedures, ScalarFunctions.compileDefinitions_signatures,
    ScalarProcedures.compileDefinitions_signatures] using MainInventory.catalogs_entry source textValid domain

end Silver.ApplicationPackageInitializers

namespace Silver.ApplicationPackageMain.BodyLibraries
open Compose Compose.Expressions Predicate ApplicationPackageDeclarations ApplicationPackageInitializers
open ApplicationPackageBodies ApplicationPackageBodies.Recursive ApplicationPackageBodies.SourceSyntax

/-- The reader identity is the literal interpretation dictionary used by the
original source composition. Complete recursive equations and native domains
then derive the source tree, semantic form, checker result and obligations;
none of those conclusions is a source assumption. -/
theorem original_body_checked (library : BodyLibraries) (other : Calls)
    (readers : Readers) (interpreted : library.readers = sourceReaders readers)
    {reader : BooleanElaboration.Native.Reader} {completion : CompletionCalls} {calls : ApplicationAdmission.Calls}
    {sources : ApplicationUnits.Bundle} {result : ApplicationAdmission.AnalysisResult}
    (parsed : ApplicationAdmission.ParsedPackage reader completion calls sources result)
    (valid : sources.Valid) (framed : ReaderFrame (textOf sources) parsed.specification.exports)
    (typed : parsed.body.info.Typed) (units : parsed.body.info.units = sources.units)
    (environment : Applications.Environment)
    (packages : environment.packages.signatures =
      (ApplicationPackageCalls.completedEnvironment parsed.body.info).map Packages.RoutineEffects.signature)
    (functions : catalogSignatures
      (declarationsFrame (library.model other) sources parsed.specification.exports parsed.body.info).functions
      (declarationsFrame (library.model other) sources parsed.specification.exports parsed.body.info).arrayNames.types =
        environment.localFunctions.signatures)
    (procedures : ProcedureBindings.catalogSignatures
      (declarationsFrame (library.model other) sources parsed.specification.exports parsed.body.info).procedures
      (declarationsFrame (library.model other) sources parsed.specification.exports parsed.body.info).arrayNames.types =
        environment.localProcedures.signatures)
    (accepted : (packageMainAt (library.calls other) sources parsed.specification.exports parsed.body.info).accepted = true) :
    TailTree (nativeReaders library.readers)
        (library.input other sources parsed.specification.exports parsed.body.info) .endOnly true false
        (library.result other sources parsed.specification.exports parsed.body.info) ∧
      ∃ code, TailCodeAt (sourceReaders readers) (mainNames environment)
          (library.input other sources parsed.specification.exports parsed.body.info) .endOnly true false
          (library.result other sources parsed.specification.exports parsed.body.info) code ∧
        MainChecked environment (library.input other sources parsed.specification.exports parsed.body.info)
          (library.result other sources parsed.specification.exports parsed.body.info) code := by
  have scope := library.original_entry_scope other parsed valid framed typed units environment
    packages functions procedures accepted
  have domain := library.input_domain other valid parsed.specification.exports framed parsed.body.info typed parsed.complete
  have tree := library.accepted_tree other valid parsed.specification.exports framed parsed.body.info typed parsed.complete accepted
  have equations : Equations (sourceReaders readers) NativeDomain := by
    simpa only [interpreted, sourceReaders_native] using library.source
  have modelAccepted := (library.main_meaning other valid parsed.specification.exports framed
    parsed.body.info typed parsed.complete) ▸ accepted
  have present := library.body_present other modelAccepted
  have resultEq : library.result other sources parsed.specification.exports parsed.body.info =
      (sourceReaders readers).tailResult (library.input other sources parsed.specification.exports parsed.body.info)
        .endOnly true := by
    simp only [BodyLibraries.result, interpreted, sourceReaders_native]
  rw [resultEq] at present
  have checked := (main_recursive_meaning equations scope domain).2 .endOnly true present
  rw [← resultEq] at checked
  exact ⟨tree, checked⟩

/-- Original Specification, optional Main argument, declarations and recursive
body construct their exact syntax inventories and executable local libraries.
The retained inventory/body obligation lists and local-library validity are
derived; MainInitialization supplies runtime String bounds. The application
join separately proves the package library's typed semantics. -/
theorem original_assembly (library : BodyLibraries) (other : Calls)
    (readers : Readers) (interpreted : library.readers = sourceReaders readers)
    {reader : BooleanElaboration.Native.Reader} {completion : CompletionCalls} {calls : ApplicationAdmission.Calls}
    {sources : ApplicationUnits.Bundle} {result : ApplicationAdmission.AnalysisResult}
    (parsed : ApplicationAdmission.ParsedPackage reader completion calls sources result)
    (valid : sources.Valid) (framed : ReaderFrame (textOf sources) parsed.specification.exports)
    (typed : parsed.body.info.Typed) (units : parsed.body.info.units = sources.units)
    (packages : Packages.SharedEnvironment)
    (signatures : packages.signatures =
      (ApplicationPackageCalls.completedEnvironment parsed.body.info).map Packages.RoutineEffects.signature)
    (accepted : (packageMainAt (library.calls other) sources parsed.specification.exports parsed.body.info).accepted = true) :
    let entry := argumentFrame (library.model other) sources parsed.specification.exports parsed.body.info
    let final := declarationsFrame (library.model other) sources parsed.specification.exports parsed.body.info
    let input := library.input other sources parsed.specification.exports parsed.body.info
    let returned := library.result other sources parsed.specification.exports parsed.body.info
    ∃ inventory : MainInventory, ∃ code,
      inventory.SourceAt (textOf sources) (contextClauses (library.model other) sources parsed.body.info).argumentsWith entry final ∧
      DeclarationEntry (textOf sources) entry ∧
      inventory.localFunctions.Valid ∧ inventory.localProcedures.Valid ∧
      TailTree (nativeReaders library.readers) input .endOnly true false returned ∧
      TailCodeAt (sourceReaders readers) (mainNames (inventory.environment packages))
        input .endOnly true false returned code ∧
      MainChecked (inventory.environment packages) input returned code ∧
      Predicate.discharged (inventory.obligations entry final ++
        statementsObligations input.context.names.shape input.context.analysis
          (input.context.flow input.input.scan.facts) code
          (ArrayBindings.booleanAnalysis input.context.arrayNames (BooleanBindings.analysis input.context.booleanNames))
          (inventory.environment packages).functionSignatures
          (inventory.environment packages).procedureSignatures) = true := by
  dsimp only
  obtain ⟨inventory, source, entry⟩ := library.declaration_inventory other valid parsed.specified framed
    parsed.body.info typed parsed.complete accepted
  have localValid := MainInventory.local_libraries_valid source (textOf_valid valid) entry
  have catalogs := MainInventory.environment_signatures source (textOf_valid valid) entry packages
  obtain ⟨tree, code, original, checked⟩ := library.original_body_checked other readers interpreted parsed
    valid framed typed units (inventory.environment packages) signatures catalogs.1 catalogs.2 accepted
  refine ⟨inventory, code, source, entry, localValid.1, localValid.2.1, tree, original, checked, ?_⟩
  rw [Predicate.discharged_append, MainInventory.discharged_entry source (textOf_valid valid) entry,
    checked.obligations]
  rfl

end Silver.ApplicationPackageMain.BodyLibraries
