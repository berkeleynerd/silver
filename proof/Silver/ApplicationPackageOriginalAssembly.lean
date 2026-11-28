module

public import Silver.ApplicationPackageOriginalInitialization
public import Silver.ApplicationPackageOriginalRoutineEntries
public import Silver.ApplicationPackageRoutineSourceLibrary
public import Silver.ApplicationPackageMainSourceChecking
public import Silver.ApplicationPackageSourceBridge

@[expose] public section

/-! Construct the package and Main syntax from the original accepted Analyze
execution. Source witnesses retain original declaration/statement histories;
all semantic checker results and obligation discharge are separate conclusions.
The conservative effect inclusion is joined by OriginalAssurance. -/
namespace Silver.ApplicationPackageOriginal
open Compose Compose.Expressions Predicate Packages ApplicationPackages
open ApplicationPackageDeclarations ApplicationPackageBodies ApplicationPackageInitializers
open ApplicationPackageRoutineSources ApplicationPackageObjectRows
open ApplicationPackageBodies.Recursive ApplicationPackageBodies.SourceSyntax
open ApplicationPackageMain ApplicationAdmission

set_option backward.dsimp.instances true

/-- The original declaration and completion syntax, with no semantic decoder,
checker, effect-inclusion or safety certificate. -/
structure PackageSyntax {reader : BooleanElaboration.Native.Reader} {completion : CompletionCalls}
    {calls : ApplicationAdmission.Calls} {sources : ApplicationUnits.Bundle} {result : AnalysisResult}
    (parsed : ParsedPackage reader completion calls sources result) (readers : Readers) where
  specStart : SpecificationState
  specEnd : SpecificationState
  specRows : List SpecificationItem
  started : specificationStart (modelSpecificationCalls reader) (sources.prefix .packageSpecification)
    {units := sources.units} = .loop specStart
  specification : SpecificationInventories reader (sources.prefix .packageSpecification)
    specStart specRows (.ready specEnd)
  specScalars : specEnd.exports.scalarNames = parsed.specification.exports.scalarNames
  stateRows : List (StateObject × ObjectSyntax)
  stateOrder : stateRows.map Prod.fst = parsed.history.objects
  stateSource : ∀ entry ∈ stateRows, entry.2.SourceAt (sources.prefix .packageBody)
    entry.1.before.globals entry.1.before.info false entry.1.object
  entries : List SummaryRoutineEntry
  routines : RoutineEntriesAt reader completion (sources.prefix .packageBody) readers specRows
    parsed.history.rows entries

def PackageSyntax.headerObligations {reader completion calls sources result parsed readers}
    (source : @PackageSyntax reader completion calls sources result parsed readers) : List Predicate.Obligation :=
  specificationObligations (sources.prefix .packageSpecification) source.specRows ++
    source.stateRows.flatMap (stateObjectObligations (sources.prefix .packageBody))

theorem summary_signatures_from (initial : RoutineLibrary) (entries : List SummaryRoutineEntry)
    (prior : initial.environment.signatures = initial.effects.map RoutineEffects.signature) :
    (buildSummaryLibraryFrom initial entries).environment.signatures =
      (buildSummaryLibraryFrom initial entries).effects.map RoutineEffects.signature := by
  induction entries generalizing initial with
  | nil => exact prior
  | cons entry rest ih =>
    apply ih
    simp only [SummaryRoutineEntry.extend, SharedEnvironment.append, List.map_append,
      List.map_cons, List.map_nil, SummaryRoutineEntry.summary, prior]

theorem summary_signatures (entries : List SummaryRoutineEntry) :
    (buildSummaryLibrary entries).environment.signatures =
      (buildSummaryLibrary entries).effects.map RoutineEffects.signature :=
  summary_signatures_from .empty entries rfl

/-- Original native domains construct every package entry, including unused
routines. The table equality used by Main follows completion order without
assuming that the effect summary checker has already succeeded. -/
theorem package_syntax (library : ApplicationPackageCompletion.Library)
    (reader : BooleanElaboration.Native.Reader) (readers : Readers)
    (interpreted : library.readers = sourceReaders readers)
    {calls : ApplicationAdmission.Calls} {sources : ApplicationUnits.Bundle} {result : AnalysisResult}
    (parsed : ParsedPackage reader (ApplicationPackageCompletion.LeafLibraries.model (library.calls reader))
      calls sources result)
    (valid : sources.Valid)
    (framed : ReaderFrame (sources.prefix .packageBody) parsed.specification.exports)
    (typed : parsed.body.info.Typed) :
    ∃ source : PackageSyntax parsed readers,
      EntriesRelated (EntryCheckedAt parsed.body.info.stateSchema) parsed.history.rows source.entries ∧
      (buildSummaryLibrary source.entries).effects = ApplicationPackageCalls.completedEnvironment parsed.body.info ∧
      Predicate.discharged source.headerObligations = true := by
  have specValid := specification_prefix_valid sources valid .packageSpecification
  have bodyValid := specification_prefix_valid sources valid .packageBody
  have specTyped := readSpecification_typed reader specValid {units := sources.units}
    (specification_seed_typed sources valid.1)
  rw [parsed.specified] at specTyped
  have domain := parsed.history.routines_domain library reader bodyValid framed specTyped.1
  obtain ⟨first, last, rows, start, firstFrame, order, empty, specified, scalars, specChecks⟩ :=
    original_specification_inventory reader _ specValid {units := sources.units}
      parsed.specified parsed.specificationAccepted
  have equations : Equations (sourceReaders readers) NativeDomain := by
    simpa only [interpreted, sourceReaders_native] using library.recursive
  have tail : (ApplicationPackageCompletion.LeafLibraries.model (library.calls reader)).applicationTail =
      (sourceReaders readers).statement.applicationTail := by
    simp only [ApplicationPackageCompletion.LeafLibraries.model,
      ApplicationPackageCompletion.Library.calls, interpreted, sourceReaders_native]
  obtain ⟨entries, originals, phases⟩ := original_package_entries parsed valid domain.frame domain.metadata typed
    specified specValid firstFrame order empty scalars bodyValid
    (fun globals info framed typed => library.completion_read_typed reader bodyValid globals framed info typed)
    equations tail rfl rfl rfl
  obtain ⟨stateRows, stateOrder, stateSource, stateChecks⟩ :=
    ApplicationPackageInitializers.BodyHistory.state_inventory library reader parsed.history
      bodyValid framed specTyped.1
  let source : PackageSyntax parsed readers :=
    ⟨first, last, rows, start, specified, scalars, stateRows, stateOrder, stateSource, entries, originals⟩
  have prior : RoutineLibrary.empty.effects =
      ApplicationPackageCalls.completedEnvironment parsed.history.routinesStart.info := by
    simp only [RoutineLibrary.empty, ApplicationPackageCalls.completedEnvironment,
      original_routine_start parsed, List.take_zero, List.map_nil]
  refine ⟨source, phases, originals.final_effects parsed.history.completions .empty prior, ?_⟩
  rw [PackageSyntax.headerObligations, Predicate.discharged_append]
  exact Bool.and_eq_true_iff.mpr ⟨specChecks, stateChecks⟩

/-- Main's original declaration and recursive syntax, independently of any
successful semantic checker or runtime-state certificate. -/
structure MainSyntax {reader : BooleanElaboration.Native.Reader} {completion : CompletionCalls}
    {calls : ApplicationAdmission.Calls} {sources : ApplicationUnits.Bundle} {result : AnalysisResult}
    (parsed : ParsedPackage reader completion calls sources result)
    (library : BodyLibraries) (other : ApplicationPackageMain.Calls)
    (readers : Readers) (packages : SharedEnvironment) where
  inventory : MainInventory
  code : List Predicate.Statement
  declarations : inventory.SourceAt (textOf sources)
    (contextClauses (library.model other) sources parsed.body.info).argumentsWith
    (argumentFrame (library.model other) sources parsed.specification.exports parsed.body.info)
    (declarationsFrame (library.model other) sources parsed.specification.exports parsed.body.info)
  body : TailCodeAt (sourceReaders readers) (mainNames (inventory.environment packages))
    (library.input other sources parsed.specification.exports parsed.body.info) .endOnly true false
    (library.result other sources parsed.specification.exports parsed.body.info) code

def MainSyntax.obligations {reader completion calls sources result parsed library other readers packages}
    (source : @MainSyntax reader completion calls sources result parsed library other readers packages) :
    List Predicate.Obligation :=
  let input := library.input other sources parsed.specification.exports parsed.body.info
  source.inventory.obligations
      (argumentFrame (library.model other) sources parsed.specification.exports parsed.body.info)
      (declarationsFrame (library.model other) sources parsed.specification.exports parsed.body.info) ++
    statementsObligations input.context.names.shape input.context.analysis
      (input.context.flow input.input.scan.facts) source.code
      (ArrayBindings.booleanAnalysis input.context.arrayNames (BooleanBindings.analysis input.context.booleanNames))
      (source.inventory.environment packages).functionSignatures
      (source.inventory.environment packages).procedureSignatures

/-- Accepted Analyze constructs all native domains, the original package and
Main syntax, complete phased routine checking and Main checking/discharge.
No additional successful decoder or safety premise is required. -/
theorem accepted_assembly (library : ApplicationPackageCompletion.Library)
    (reader : BooleanElaboration.Native.Reader) (packageReaders : Readers)
    (packageInterpreted : library.readers = sourceReaders packageReaders)
    (main : BodyLibraries) (mainOther : ApplicationPackageMain.Calls) (mainReaders : Readers)
    (mainInterpreted : main.readers = sourceReaders mainReaders)
    (other : ApplicationAdmission.Calls) (sources : ApplicationUnits.Bundle)
    (represented : sources.Representable)
    (accepted : (analyzeApplication (packageCalls library reader (main.calls mainOther) other) sources).accepted = true) :
    ∃ parsed : ParsedPackage reader (ApplicationPackageCompletion.LeafLibraries.model (library.calls reader))
        (packageCalls library reader (main.calls mainOther) other) sources
        (analyzeApplication (packageCalls library reader (main.calls mainOther) other) sources),
      sources.Valid ∧ parsed.body.info.Typed ∧ parsed.body.info.units = sources.units ∧
      ∃ package : PackageSyntax parsed packageReaders,
        EntriesRelated (EntryCheckedAt parsed.body.info.stateSchema) parsed.history.rows package.entries ∧
        (buildSummaryLibrary package.entries).effects = ApplicationPackageCalls.completedEnvironment parsed.body.info ∧
        Predicate.discharged package.headerObligations = true ∧
        ∃ source : MainSyntax parsed main mainOther mainReaders (buildSummaryLibrary package.entries).environment,
          DeclarationEntry (textOf sources)
            (argumentFrame (main.model mainOther) sources parsed.specification.exports parsed.body.info) ∧
          source.inventory.localFunctions.Valid ∧ source.inventory.localProcedures.Valid ∧
          MainChecked (source.inventory.environment (buildSummaryLibrary package.entries).environment)
            (main.input mainOther sources parsed.specification.exports parsed.body.info)
            (main.result mainOther sources parsed.specification.exports parsed.body.info) source.code ∧
          Predicate.discharged source.obligations = true := by
  obtain ⟨parsed, valid, bodyFrame, mainFrame, typed, units, mainAccepted⟩ :=
    package_domains library reader main mainOther other sources represented accepted
  obtain ⟨package, phases, summaries, headerChecks⟩ :=
    package_syntax library reader packageReaders packageInterpreted parsed valid bodyFrame typed
  have signatures : (buildSummaryLibrary package.entries).environment.signatures =
      (ApplicationPackageCalls.completedEnvironment parsed.body.info).map RoutineEffects.signature := by
    rw [summary_signatures, summaries]
  obtain ⟨inventory, code, declarations, entry, functions, procedures, _tree, body, checked, discharged⟩ :=
    main.original_assembly mainOther mainReaders mainInterpreted parsed valid mainFrame typed units
      (buildSummaryLibrary package.entries).environment signatures mainAccepted
  let source : MainSyntax parsed main mainOther mainReaders (buildSummaryLibrary package.entries).environment :=
    ⟨inventory, code, declarations, body⟩
  exact ⟨parsed, valid, typed, units, package, phases, summaries, headerChecks,
    source, entry, functions, procedures, checked, discharged⟩

end Silver.ApplicationPackageOriginal
