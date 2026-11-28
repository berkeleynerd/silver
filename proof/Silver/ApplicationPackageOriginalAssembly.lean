module

public import Silver.ApplicationPackageOriginalInitialization
public import Silver.ApplicationPackageOriginalRoutineEntries
public import Silver.ApplicationPackageRoutineSourceLibrary
public import Silver.ApplicationPackageMainSourceChecking
public import Silver.ApplicationPackageMainRuntimeInitialization
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

def MainSyntax.predicateObligations {reader completion calls sources result parsed library other readers packages}
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

/-- A projection used only by the shared header-schema and raw-bound trace
relations. Main execution keeps its package environment and actual imported
scalar/Boolean stores; this projection is not a standalone Main program. -/
def MainSyntax.headerProgram {reader completion calls sources result parsed library other readers packages}
    (source : @MainSyntax reader completion calls sources result parsed library other readers packages)
    (fallback : Source) : Predicate.Program :=
  let final := declarationsFrame (library.model other) sources parsed.specification.exports parsed.body.info
  let arguments := (contextClauses (library.model other) sources parsed.body.info).argumentsWith
  { declarations := if arguments then argumentDeclaration :: source.inventory.strings else source.inventory.strings
    names := final.names
    fallback := fallback
    hasArguments := arguments
    statements := []
    booleanDeclarations := source.inventory.booleans
    booleanInitializerChecks := source.inventory.booleanChecks }

def MainSyntax.booleanDeclarationChecks {reader completion calls sources result parsed library other readers packages}
    (source : @MainSyntax reader completion calls sources result parsed library other readers packages) :
    List Predicate.Obligation :=
  let entry := argumentFrame (library.model other) sources parsed.specification.exports parsed.body.info
  let final := declarationsFrame (library.model other) sources parsed.specification.exports parsed.body.info
  booleanDeclarationObligations final.names.shape Integer.Analysis.empty
    ⟨(booleanDeclarationFacts entry).path, Integer.emptyRanges⟩
    (ArrayBindings.booleanAnalysis entry.arrayNames.names (BooleanBindings.analysis entry.booleanNames))
    source.inventory.booleans

/-- Complete Main obligation families: the original optional argument and
every String/Character declaration contribute range and length schemas, in
addition to raw and elaborated Boolean, scalar, callable and body checks. -/
def MainSyntax.obligations {reader completion calls sources result parsed library other readers packages}
    (source : @MainSyntax reader completion calls sources result parsed library other readers packages) :
    List Semantics.Obligation :=
  (Predicate.declarationChecks (source.headerProgram [])).map Compose.Check.toObligation ++
    (source.predicateObligations ++ source.booleanDeclarationChecks).map Predicate.Obligation.toObligation

theorem original_main_strings_valid {text : Source} {arguments : Bool} {entry final : ParserState}
    {inventory : MainInventory} {fallback : Source}
    (source : inventory.SourceAt text arguments entry final)
    (argument : MainArgumentAt text entry arguments fallback) (domain : DeclarationEntry text entry) :
    Bindings.DeclarationsValid Bindings.emptyShape
      (if arguments then argumentDeclaration :: inventory.strings else inventory.strings) final.names.shape := by
  have declared := declarations_shape domain.native.bounds.normal domain.static domain.stored source.strings
  cases argument with
  | absent names dynamic =>
    simpa only [names, empty_names_shape, Bool.false_eq_true, ↓reduceIte] using declared
  | present argument => exact prepend_argument ((argument_shape argument).2.1 ▸ declared)

theorem MainSyntax.obligations_discharge {reader completion calls sources result parsed library other readers packages}
    (source : @MainSyntax reader completion calls sources result parsed library other readers packages)
    (textValid : ValidText (textOf sources))
    (domain : DeclarationEntry (textOf sources)
      (argumentFrame (library.model other) sources parsed.specification.exports parsed.body.info))
    {fallback : Source}
    (argument : MainArgumentAt (textOf sources)
      (argumentFrame (library.model other) sources parsed.specification.exports parsed.body.info)
      (contextClauses (library.model other) sources parsed.body.info).argumentsWith fallback)
    (checked : Predicate.discharged source.predicateObligations = true) :
    Semantics.discharge source.obligations = true := by
  have declared : Bindings.DeclarationsValid Bindings.emptyShape (source.headerProgram []).declarations
      (source.headerProgram []).names.shape := original_main_strings_valid source.declarations argument domain
  have booleans := (boolean_declarations_valid textValid source.declarations.booleans
    domain.native.bounds.normal domain.native.base domain.native.ready domain.static domain.stored).2.1
  have predicates : Predicate.discharged (source.predicateObligations ++ source.booleanDeclarationChecks) = true := by
    rw [Predicate.discharged_append, checked, Bool.true_and]
    exact (boolean_declaration_obligations_exact _ _ _ _ _).trans booleans
  have declarationChecks : ∀ schema ∈ Predicate.declarationChecks (source.headerProgram []), schema.Valid := by
    intro schema present
    unfold Predicate.declarationChecks at present
    rcases List.mem_append.mp present with range | length
    · obtain ⟨schema, rangeMember, rfl⟩ := List.mem_map.mp range
      apply Guarded.RangeObligation.valid_of_refines (Compose.declaration_schemas declared schema rangeMember)
      exact Compose.uniform_range_valid _ (by simp [Compose.uniformRangeObligations])
    · obtain ⟨schema, lengthMember, rfl⟩ := List.mem_map.mp length
      exact Compose.declaration_lengths_valid declared schema lengthMember
  apply (Semantics.discharge_iff _).mpr
  intro check member
  unfold MainSyntax.obligations at member
  rcases List.mem_append.mp member with declarations | predicatesMember
  · obtain ⟨schema, present, rfl⟩ := List.mem_map.mp declarations
    exact (Compose.Check.discharge_iff _).mpr (declarationChecks schema present)
  · obtain ⟨schema, present, rfl⟩ := List.mem_map.mp predicatesMember
    exact List.all_eq_true.mp predicates schema present

/-- Original source initialization yields both raw schema traces and actual
Ada bound-store traces. The optional argument supplies its own first cell;
the absent-argument case permits any irrelevant backing bound store. -/
theorem original_main_bounds {text input : Source} {arguments inputValid : Bool}
    {entry final : ParserState} {inventory : MainInventory} {program : Predicate.Program}
    (start : MainRuntimeStart text entry arguments input inputValid)
    (source : inventory.SourceAt text arguments entry final)
    (programStrings : program.declarations =
      if arguments then argumentDeclaration :: inventory.strings else inventory.strings)
    (programNames : program.names = final.names)
    (programBooleans : program.booleanInitializerChecks = inventory.booleanChecks)
    (textValid : ValidText text) (domain : DeclarationEntry text entry) (bounds : BoundsStore) :
    let values := if arguments then argumentDeclaration.execute Bindings.emptyValues input else Bindings.emptyValues
    let initialBounds := if arguments then argumentDeclaration.executeBounds bounds input else bounds
    NamesBoundsValid final.names ∧ final.names.length ≤ maxBindings ∧
      Bindings.Fits final.names.shape input (inventory.runtimeValues arguments input) ∧
      initialBounds.Compatible entry.names input ∧
      RawHeaderBoundsTrace text arguments program input inputValid entry values
        inventory.strings inventory.booleans inventory.booleanChecks final ∧
      (executeDeclarationsBounds input inventory.strings initialBounds).Compatible final.names input ∧
      ActualHeaderBoundsTrace text arguments input inputValid entry values initialBounds
        inventory.strings inventory.booleans inventory.booleanChecks final := by
  have data := start.domain
  cases start with
  | absent names dynamic =>
    have metadata : NamesBoundsValid entry.names := names ▸ namesBoundsValid_empty
    have count : entry.names.length ≤ maxBindings := by simp only [names, List.length_nil]; omega
    have fit : Bindings.Fits entry.names.shape [] Bindings.emptyValues := by
      rw [names, empty_names_shape]
      exact Bindings.empty_fits []
    have compatible : bounds.Compatible entry.names [] := by
      intro index info selected
      simp only [names, Bindings.BindingEnvironment.get] at selected
      simp at selected
    have finalBounds := MainInventory.string_fit source textValid.2 data.1 data.2.1 count metadata fit domain.static domain.stored
    have traces := MainInventory.string_bounds source programStrings programNames programBooleans names textValid
      domain.native.base domain.native.ready domain.static domain.stored data.1 data.2.1 metadata count fit
      data.2.2 compatible
    exact ⟨finalBounds.1, finalBounds.2.1, finalBounds.2.2, compatible, traces⟩
  | argument argument bounded printable invalid =>
    have traces := MainInventory.string_bounds_after_argument argument source programStrings programNames
      programBooleans textValid domain.native.base domain.native.ready domain.static domain.stored
      bounds bounded printable data.2.2
    exact ⟨traces.1, traces.2.1, traces.2.2.1,
      argument_actual_bounds_compatible argument bounded bounds, traces.2.2.2⟩

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
      sources.Valid ∧ ReaderFrame (sources.prefix .packageBody) parsed.specification.exports ∧
      ReaderFrame (textOf sources) parsed.specification.exports ∧
      parsed.body.info.Typed ∧ parsed.body.info.units = sources.units ∧
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
          Predicate.discharged source.predicateObligations = true := by
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
  exact ⟨parsed, valid, bodyFrame, mainFrame, typed, units, package, phases, summaries, headerChecks,
    source, entry, functions, procedures, checked, discharged⟩

/-- Meaning of the original three-unit Bundle. Native reading histories
identify the exact source declarations and recursive statements. No semantic
decoder, checker, effect-inclusion, obligation or safety result is stored here. -/
structure SourceMeaning (library : ApplicationPackageCompletion.Library)
    (reader : BooleanElaboration.Native.Reader) (packageReaders : Readers)
    (mainLibrary : BodyLibraries) (mainOther : ApplicationPackageMain.Calls) (mainReaders : Readers)
    (other : ApplicationAdmission.Calls) (sources : ApplicationUnits.Bundle) where
  parsed : ParsedPackage reader (ApplicationPackageCompletion.LeafLibraries.model (library.calls reader))
    (packageCalls library reader (mainLibrary.calls mainOther) other) sources
    (analyzeApplication (packageCalls library reader (mainLibrary.calls mainOther) other) sources)
  package : PackageSyntax parsed packageReaders
  main : MainSyntax parsed mainLibrary mainOther mainReaders (buildSummaryLibrary package.entries).environment

structure SourceMeaning.NativeFacts {library reader packageReaders mainLibrary mainOther mainReaders other sources}
    (source : SourceMeaning library reader packageReaders mainLibrary mainOther mainReaders other sources) : Prop where
  valid : sources.Valid
  bodyFrame : ReaderFrame (sources.prefix .packageBody) source.parsed.specification.exports
  mainFrame : ReaderFrame (textOf sources) source.parsed.specification.exports
  typed : source.parsed.body.info.Typed
  units : source.parsed.body.info.units = sources.units
  mainAccepted : (packageMainAt (mainLibrary.calls mainOther) sources
    source.parsed.specification.exports source.parsed.body.info).accepted = true

/-- Derived checking facts, deliberately separate from SourceMeaning. -/
structure SourceMeaning.Checked {library reader packageReaders mainLibrary mainOther mainReaders other sources}
    (source : SourceMeaning library reader packageReaders mainLibrary mainOther mainReaders other sources) : Prop where
  phases : EntriesRelated (EntryCheckedAt source.parsed.body.info.stateSchema)
    source.parsed.history.rows source.package.entries
  summaries : (buildSummaryLibrary source.package.entries).effects =
    ApplicationPackageCalls.completedEnvironment source.parsed.body.info
  headers : Predicate.discharged source.package.headerObligations = true
  entry : DeclarationEntry (textOf sources)
    (argumentFrame (mainLibrary.model mainOther) sources source.parsed.specification.exports source.parsed.body.info)
  functions : source.main.inventory.localFunctions.Valid
  procedures : source.main.inventory.localProcedures.Valid
  body : MainChecked (source.main.inventory.environment (buildSummaryLibrary source.package.entries).environment)
    (mainLibrary.input mainOther sources source.parsed.specification.exports source.parsed.body.info)
    (mainLibrary.result mainOther sources source.parsed.specification.exports source.parsed.body.info) source.main.code
  mainObligations : Predicate.discharged source.main.predicateObligations = true

theorem SourceMeaning.original_argument {library reader packageReaders mainLibrary mainOther mainReaders other sources}
    (source : SourceMeaning library reader packageReaders mainLibrary mainOther mainReaders other sources)
    (native : source.NativeFacts) :
    ∃ fallback, MainArgumentAt (textOf sources)
      (argumentFrame (mainLibrary.model mainOther) sources source.parsed.specification.exports source.parsed.body.info)
      (contextClauses (mainLibrary.model mainOther) sources source.parsed.body.info).argumentsWith fallback := by
  have modeled := (mainLibrary.main_meaning mainOther native.valid source.parsed.specification.exports
    native.mainFrame source.parsed.body.info native.typed source.parsed.complete) ▸ native.mainAccepted
  have present := ((packageMainAt_accepted_iff _ _ _ _).mp modeled).argumentPresent
  have executed := source.parsed.specified ▸ readSpecification_exec reader (sources.prefix .packageSpecification)
    {units := sources.units}
  have tables := ApplicationPackageRoutineClosedFrames.specification_tables (reader := reader) rfl rfl executed
  exact ApplicationPackageMain.original_argument (mainLibrary.bodyCalls mainOther) sources
    source.parsed.specification.exports source.parsed.body.info tables present

theorem accepted_meaning (library : ApplicationPackageCompletion.Library)
    (reader : BooleanElaboration.Native.Reader) (packageReaders : Readers)
    (packageInterpreted : library.readers = sourceReaders packageReaders)
    (main : BodyLibraries) (mainOther : ApplicationPackageMain.Calls) (mainReaders : Readers)
    (mainInterpreted : main.readers = sourceReaders mainReaders)
    (other : ApplicationAdmission.Calls) (sources : ApplicationUnits.Bundle)
    (represented : sources.Representable)
    (accepted : (analyzeApplication (packageCalls library reader (main.calls mainOther) other) sources).accepted = true) :
    ∃ meaning : SourceMeaning library reader packageReaders main mainOther mainReaders other sources,
      meaning.NativeFacts ∧ meaning.Checked := by
  obtain ⟨parsed, valid, bodyFrame, mainFrame, typed, units, package, phases, summaries, headers,
      mainSource, entry, functions, procedures, body, mainObligations⟩ :=
    accepted_assembly library reader packageReaders packageInterpreted main mainOther mainReaders
      mainInterpreted other sources represented accepted
  have mainAccepted : (packageMainAt (main.calls mainOther) sources
      parsed.specification.exports parsed.body.info).accepted = true := by
    have read := parsed.main
    change packageMainAt (main.calls mainOther) sources parsed.specification.exports parsed.body.info =
      analyzeApplication (packageCalls library reader (main.calls mainOther) other) sources at read
    rw [read]
    exact accepted
  exact ⟨⟨parsed, package, mainSource⟩, ⟨valid, bodyFrame, mainFrame, typed, units, mainAccepted⟩,
    ⟨phases, summaries, headers, entry, functions, procedures, body, mainObligations⟩⟩

/-- The checked native wrapper interpretation reaches the same original
Bundle meaning. Its arbitrary caller locals and full native storage domain are
preserved; source slices are never flattened into the single-unit grammar. -/
theorem interpreted_accepted_meaning {specification implementation scalarSpec packageSpec : List String}
    (native : ApplicationPackageSourceBridge.InterpretedSource specification implementation scalarSpec packageSpec)
    (reader : BooleanElaboration.Native.Reader) (packageReaders : Readers)
    (packageInterpreted : native.completion.readers = sourceReaders packageReaders)
    (mainOther : ApplicationPackageMain.Calls) (mainReaders : Readers)
    (mainInterpreted : native.main.readers = sourceReaders mainReaders)
    (other : ApplicationAdmission.Calls) (locals : ApplicationNative.Locals)
    (represented : (locals .bundle "sources").Representable)
    (accepted : (ApplicationAdmission.Native.analyzeBody.eval
      (ApplicationAdmission.Native.modelCallees (native.calls reader mainOther other)) locals).accepted = true) :
    ∃ meaning : SourceMeaning native.completion reader packageReaders native.main mainOther mainReaders
        (native.boundary other) (locals .bundle "sources"), meaning.NativeFacts ∧ meaning.Checked := by
  rw [native.analysis reader mainOther other locals represented] at accepted
  have same := package_main_imports native.completion reader native.main mainOther
    (native.boundary other) (locals .bundle "sources") represented
  change analyzeApplication (native.calls reader mainOther other) (locals .bundle "sources") =
    analyzeApplication (native.model reader mainOther other) (locals .bundle "sources") at same
  have original : (analyzeApplication (native.calls reader mainOther other) (locals .bundle "sources")).accepted = true := by
    rw [same]
    exact accepted
  exact accepted_meaning native.completion reader packageReaders packageInterpreted native.main mainOther mainReaders
    mainInterpreted (native.boundary other) (locals .bundle "sources") represented original

end Silver.ApplicationPackageOriginal
