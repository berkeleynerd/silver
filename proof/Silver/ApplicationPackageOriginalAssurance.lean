module

public import Silver.ApplicationPackageOriginalAssembly
public import Silver.ApplicationPackageRoutineInitializerEffects
public import Silver.ApplicationSummaryAssurance
public import Silver.ApplicationPackageOriginalValues
public import Silver.ApplicationPackageMainRuntimeInitialization
public import Silver.ApplicationPackageReaderEffectsImports

@[expose] public section

namespace Silver.ApplicationPackageOriginal
open Compose Compose.Expressions Predicate Packages ApplicationPackages
open ApplicationPackageDeclarations ApplicationPackageBodies ApplicationPackageInitializers
open ApplicationPackageRoutineSources ApplicationPackageObjectRows ApplicationPackageFrameLayout
open ApplicationPackageBodies.Recursive ApplicationPackageBodies.SourceSyntax
open ApplicationPackageRoutineEffects ApplicationPackageSourceEffects
open ApplicationPackageRoutineInitializerEffects ApplicationPackageRoutineFooterEffects
open ApplicationPackageRoutineResults Packages.EffectSummaries
open ApplicationPackageMain ApplicationAdmission

set_option backward.dsimp.instances true

/-- Combine all original initializer, recursive body, return and footer
effects. Native scan masks remain conservative summaries at their original
routine identity; the complete inclusion is a conclusion of source history. -/
theorem routine_effects {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : PackageBindings.Metadata} {result : CompletionResult}
    {readers : Readers} {frames : CompletionFrames (declarationReaders reader calls) text globals info result}
    (source : RoutineCode frames readers) (specRows : List SpecificationItem)
    {specText : Source} {constants : ScalarExpression.Environment}
    (known : RoutineFrameFacts specText constants text globals info)
    (valid : ValidText text) (writes : CompletedFunctionWrites info)
    (pending : info.completed < info.routines.length) (present : result.globals.position ≠ 0)
    (imports : ReaderEffects readers)
    (reads : calls.stateReads = ApplicationPackageEffects.stateReads ApplicationPackageEffects.modelCalls)
    (returned : calls.functionReturnAfter = functionReturnAfter)
    {schema : StateSchema} {initialized : InitializedRanges} {after : Flow}
    (checked : (source.definition specRows).checkPhased schema
      (ApplicationPackageCalls.completedEnvironment info) source.context (source.phases specRows) =
        some (initialized, after)) :
    ∃ inferred, (source.definition specRows).inferEffects (ApplicationPackageCalls.completedEnvironment info) =
        some inferred ∧ Included inferred (source.summaryEntry specRows).effects := by
  have signatureTyped := frames.signature_typed valid known.framed known.typed
  have scope := frames.body_scope known.initial known.tables known.declarations known.clear
    known.framed.typed.scalarCount signatureTyped known.bounds known.declared writes
  have legal := frames.body_domain valid known.framed known.typed present
  have body := original_body_effects imports text.length source.bodySource legal scope (body_input_width frames)
  have capacity : frames.signature.info.states.length ≤ PackageBindings.maxStates := signatureTyped.2.2.2.2.1
  have initial := initializer_effects source specRows valid
    (frames.entry_reader valid known.framed known.typed) scope.declarations capacity reads
  obtain ⟨read⟩ := completion_body_read frames.executed present
  have retained := return_preserves capacity read.readReturn
  have notOuter := completion_formals_nonouter frames known.initial known.exports
  obtain ⟨native, same, nativeValid⟩ := body.legal.context
  change native.model = frames.bodySource.context at same
  have booleanCapacity : frames.bodySource.context.booleanNames.length ≤ BooleanBindings.maxBindings := by
    rw [← same]
    exact nativeValid.booleans.1
  have results := results_included text.length source.resultSource read.readReturn rfl returned reads
    scope.declarations capacity body.legal.base.size booleanCapacity notOuter
  obtain ⟨inferred, inference⟩ := routine_inference source specRows known.tables checked
  obtain ⟨bodyEffects, bodyInference, _scalar, combined⟩ :=
    ((source.definition specRows).inferEffects_sound inference).body
  have bodyFound : inferStatementsEffects (ApplicationPackageCalls.completedEnvironment frames.signature.info)
      (layout text.length frames.signature.info frames.bodySource.context) source.body = some bodyEffects := by
    rw [frames.body_environment]
    exact bodyInference
  have covered := (initial.trans (body.incoming.trans retained)).merge_bound
    (((body.effects bodyEffects bodyFound).trans retained).merge_bound results)
  refine ⟨inferred, inference, ?_⟩
  change Included inferred ((result.info.routineAt result.info.completed).effects result.info)
  rw [footer_effects frames read pending, combined]
  exact covered

theorem entries_effects {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {readers : Readers} {specRows : List SpecificationItem}
    {rows : List RoutineRead} {entries : List SummaryRoutineEntry} {schema : StateSchema}
    (originals : RoutineEntriesAt reader calls text readers specRows rows entries)
    (phases : EntriesRelated (EntryCheckedAt schema) rows entries)
    {specText : Source} {constants : ScalarExpression.Environment}
    (known : ∀ row ∈ rows, RoutineFrameFacts specText constants text row.before.globals row.before.info)
    (valid : ValidText text) (writes : ∀ row ∈ rows, CompletedFunctionWrites row.before.info)
    (imports : ReaderEffects readers)
    (reads : calls.stateReads = ApplicationPackageEffects.stateReads ApplicationPackageEffects.modelCalls)
    (returned : calls.functionReturnAfter = functionReturnAfter) :
    EntriesRelated EntryEffectsAt rows entries := by
  induction originals with
  | nil => exact .nil
  | @cons row rows entries frames code pending present originals ih =>
    cases phases with
    | cons phase phases =>
      obtain ⟨initialized, after, checked⟩ := phase.2
      exact .cons
        (routine_effects code specRows (known row List.mem_cons_self) valid
          (writes row List.mem_cons_self) pending present imports reads returned checked)
        (ih phases (fun seen member => known seen (List.mem_cons_of_mem _ member))
          (fun seen member => writes seen (List.mem_cons_of_mem _ member)))

/-- Complete inferred-effect inclusion for every original package routine.
The only effect assumptions are exact primitive source-reader equations on
their full native domains. All per-routine semantic facts are derived. -/
theorem package_effects (library : ApplicationPackageCompletion.Library)
    (reader : BooleanElaboration.Native.Reader) {readers : Readers} (imports : ReaderEffects readers)
    {calls : ApplicationAdmission.Calls} {sources : ApplicationUnits.Bundle} {result : AnalysisResult}
    (parsed : ParsedPackage reader (ApplicationPackageCompletion.LeafLibraries.model (library.calls reader))
      calls sources result) (valid : sources.Valid)
    (framed : ReaderFrame (sources.prefix .packageBody) parsed.specification.exports)
    (typed : parsed.body.info.Typed) (source : PackageSyntax parsed readers)
    (phases : EntriesRelated (EntryCheckedAt parsed.body.info.stateSchema) parsed.history.rows source.entries) :
    EntriesRelated EntryEffectsAt parsed.history.rows source.entries := by
  have specValid := specification_prefix_valid sources valid .packageSpecification
  have bodyValid := specification_prefix_valid sources valid .packageBody
  have specTyped := readSpecification_typed reader specValid {units := sources.units}
    (specification_seed_typed sources valid.1)
  rw [parsed.specified] at specTyped
  have domain := parsed.history.routines_domain library reader bodyValid framed specTyped.1
  have initial := original_frame_facts parsed valid domain.frame domain.metadata typed
  have known := history_frame_facts parsed.history.completions initial
    (fun globals info framed typed => library.completion_read_typed reader bodyValid globals framed info typed)
  exact entries_effects source.routines phases (fun row member => (known row member).1)
    bodyValid (original_function_writes parsed).2 imports rfl rfl

/-- The summary-library checker is a derived result of accepted source,
including complete original initializer/body/result effects for every entry. -/
theorem package_library (library : ApplicationPackageCompletion.Library)
    (reader : BooleanElaboration.Native.Reader) {readers : Readers} (imports : ReaderEffects readers)
    {calls : ApplicationAdmission.Calls} {sources : ApplicationUnits.Bundle} {result : AnalysisResult}
    (parsed : ParsedPackage reader (ApplicationPackageCompletion.LeafLibraries.model (library.calls reader))
      calls sources result) (valid : sources.Valid)
    (framed : ReaderFrame (sources.prefix .packageBody) parsed.specification.exports)
    (typed : parsed.body.info.Typed) (source : PackageSyntax parsed readers)
    (phases : EntriesRelated (EntryCheckedAt parsed.body.info.stateSchema) parsed.history.rows source.entries) :
    checkSummaryLibrary parsed.body.info.stateSchema source.entries = some (buildSummaryLibrary source.entries) ∧
      (buildSummaryLibrary source.entries).environment.Typed parsed.body.info.stateSchema ∧
      SummaryRoutinesSafeFrom parsed.body.info.stateSchema .empty source.entries ∧
      Predicate.discharged (summaryLibraryObligationsFrom parsed.body.info.stateSchema .empty source.entries) = true := by
  have effects := package_effects library reader imports parsed valid framed typed source phases
  have checked := checked_source_library parsed.history.completions source.routines phases effects
    (original_routine_start parsed)
  have schema := parsed.body.info.stateSchema_valid typed (Bool.and_eq_true_iff.mp parsed.complete).1
  have safe := checkSummaryLibrary_sound schema checked.2.2 checked.1
  exact ⟨checked.1, safe.1, safe.2.2.1, checkSummaryLibraryFrom_obligations_discharge checked.1⟩

/-- Every function body, at its actual completion-order callable prefix,
preserves all globals. This records the source/executable correspondence which
is separate from the wrapper's value-only function interface. -/
def FunctionsPreserveFrom : RoutineLibrary → List SummaryRoutineEntry → Prop
  | _, [] => True
  | library, entry :: rest =>
      (∀ signature, entry.routine.definition.signature = .function signature →
        ∀ state inputs, (entry.routine.definition.execute library.environment state inputs).1 = state) ∧
      FunctionsPreserveFrom (entry.extend library) rest

theorem source_functions_preserve_from {reader calls text readers specRows before rows result entries}
    (history : RoutineHistory (bodyReaders reader calls) text before rows result)
    (sources : RoutineEntriesAt reader calls text readers specRows rows entries)
    (effects : EntriesRelated EntryEffectsAt rows entries)
    (initial : RoutineLibrary) (prior : initial.effects = ApplicationPackageCalls.completedEnvironment before.info)
    (previous : initial.environment.RespectsEffects initial.effects) :
    FunctionsPreserveFrom initial entries := by
  induction history generalizing entries initial with
  | finished => cases sources; trivial
  | @added row later result phase pending read advanced rest ih =>
    cases sources with
    | cons frames code sourcePending present originals =>
      cases effects with
      | cons footprint footprints =>
        obtain ⟨inferred, inference, included⟩ := footprint
        rw [← prior] at inference
        have next : ((code.summaryEntry specRows).extend initial).effects =
            ApplicationPackageCalls.completedEnvironment row.result.info := by
          change initial.effects ++ [(code.summaryEntry specRows).summary] = _
          rw [prior, code.summary_original sourcePending present]
          exact (next_environment phase pending read advanced rest).symm
        refine ⟨?_, ih originals footprints _ next (append_respects_summary previous inference included)⟩
        intro signature function state inputs
        have kind : (frames.signature.info.routineAt (row.before.info.completed + 1)).kind = .function := by
          cases selected : (frames.signature.info.routineAt (row.before.info.completed + 1)).kind with
          | function => rfl
          | procedure =>
            simp only [RoutineCode.summaryEntry, RoutineCode.entry, RoutineCode.definition,
              PackageBindings.Routine.signature, selected] at function
            cases function
        exact function_execution_readonly code specRows sourcePending present kind
          previous inference included state inputs

noncomputable def SourceMeaning.obligations {library reader packageReaders mainLibrary mainOther mainReaders other sources}
    (source : SourceMeaning library reader packageReaders mainLibrary mainOther mainReaders other sources) :
    List Semantics.Obligation :=
  (source.package.headerObligations ++
    summaryLibraryObligationsFrom source.parsed.body.info.stateSchema .empty source.package.entries).map
      Predicate.Obligation.toObligation ++
    source.main.obligations

/-- All package and Main semantic-library facts, derived separately from the
original source meaning. Runtime initialization is joined below this boundary. -/
structure SourceMeaning.Semantic {library reader packageReaders mainLibrary mainOther mainReaders other sources}
    (source : SourceMeaning library reader packageReaders mainLibrary mainOther mainReaders other sources) : Prop where
  schema : source.parsed.body.info.stateSchema.Valid
  library : checkSummaryLibrary source.parsed.body.info.stateSchema source.package.entries =
    some (buildSummaryLibrary source.package.entries)
  environment : (source.main.inventory.environment (buildSummaryLibrary source.package.entries).environment).Valid
    source.parsed.body.info.stateSchema
  routines : SummaryRoutinesSafeFrom source.parsed.body.info.stateSchema .empty source.package.entries
  functions : FunctionsPreserveFrom .empty source.package.entries
  discharged : Semantics.discharge source.obligations = true

theorem SourceMeaning.semantic {library reader packageReaders mainLibrary mainOther mainReaders other sources}
    (source : SourceMeaning library reader packageReaders mainLibrary mainOther mainReaders other sources)
    (native : source.NativeFacts) (checked : source.Checked) (imports : ReaderEffects packageReaders) :
    source.Semantic := by
  have package := package_library library reader imports source.parsed native.valid native.bodyFrame
    native.typed source.package checked.phases
  have effects := package_effects library reader imports source.parsed native.valid native.bodyFrame
    native.typed source.package checked.phases
  have prior : RoutineLibrary.empty.effects =
      ApplicationPackageCalls.completedEnvironment source.parsed.history.routinesStart.info := by
    simp only [RoutineLibrary.empty, ApplicationPackageCalls.completedEnvironment,
      original_routine_start source.parsed, List.take_zero, List.map_nil]
  have functions := source_functions_preserve_from source.parsed.history.completions source.package.routines
    effects .empty prior SharedEnvironment.empty_respectsEffects
  obtain ⟨fallback, argument⟩ := source.original_argument native
  have mainChecks := source.main.obligations_discharge (textOf_valid native.valid) checked.entry
    argument checked.mainObligations
  have packageChecks : Predicate.discharged (source.package.headerObligations ++
      summaryLibraryObligationsFrom source.parsed.body.info.stateSchema .empty source.package.entries) = true := by
    rw [Predicate.discharged_append, checked.headers, package.2.2.2]
    rfl
  refine ⟨source.parsed.body.info.stateSchema_valid native.typed
      (Bool.and_eq_true_iff.mp source.parsed.complete).1,
    package.1, ⟨checked.functions, checked.procedures, package.2.1⟩, package.2.2.1, functions, ?_⟩
  apply (Semantics.discharge_iff _).mpr
  intro check member
  unfold SourceMeaning.obligations at member
  rcases List.mem_append.mp member with packageMember | mainMember
  · obtain ⟨schema, present, rfl⟩ := List.mem_map.mp packageMember
    exact List.all_eq_true.mp packageChecks schema present
  · exact (Semantics.discharge_iff _).mp mainChecks check mainMember

/-- Actual interpreted Analyze acceptance derives the complete original
source meaning and every package-library/Main-checking obligation. None of
those semantic conclusions is assumed in the native source relation. -/
theorem interpreted_accepted_semantics {specification implementation scalarSpec packageSpec : List String}
    (native : ApplicationPackageSourceBridge.InterpretedSource specification implementation scalarSpec packageSpec)
    (reader : BooleanElaboration.Native.Reader) (packageReaders : Readers)
    (packageInterpreted : native.completion.readers = sourceReaders packageReaders)
    (imports : ReaderEffects packageReaders)
    (mainOther : ApplicationPackageMain.Calls) (mainReaders : Readers)
    (mainInterpreted : native.main.readers = sourceReaders mainReaders)
    (other : ApplicationAdmission.Calls) (locals : ApplicationNative.Locals)
    (represented : (locals .bundle "sources").Representable)
    (accepted : (ApplicationAdmission.Native.analyzeBody.eval
      (ApplicationAdmission.Native.modelCallees (native.calls reader mainOther other)) locals).accepted = true) :
    ∃ meaning : SourceMeaning native.completion reader packageReaders native.main mainOther mainReaders
        (native.boundary other) (locals .bundle "sources"),
      meaning.NativeFacts ∧ meaning.Checked ∧ meaning.Semantic := by
  obtain ⟨meaning, legal, checked⟩ := interpreted_accepted_meaning native reader packageReaders packageInterpreted
    mainOther mainReaders mainInterpreted other locals represented accepted
  exact ⟨meaning, legal, checked, meaning.semantic legal checked imports⟩

/-- Source-value correspondence is also derived separately: immutable
loads retain their original declaration order, and each persistent cell has
the value of its original RHS on every fitting elaboration store. -/
structure SourceMeaning.InitialValues {library reader packageReaders mainLibrary mainOther mainReaders other sources}
    (source : SourceMeaning library reader packageReaders mainLibrary mainOther mainReaders other sources) : Prop where
  constants : ∃ readings : List (OriginalConstant (sources.prefix .packageSpecification)),
    readings.map OriginalConstant.seed = specificationSeeds source.package.specRows ∧
      (∀ item ∈ readings, item.row ∈ source.package.specRows) ∧
      ∀ stores, (∀ item ∈ readings,
        ElaborationStore (sources.prefix .packageSpecification) item.row.before.exports item.row.before.info (stores item)) →
        ∀ backing, loadOriginalConstants stores backing readings =
          initializeLocals backing ((specificationSeeds source.package.specRows).map ConstantSeed.initializer)
  states : ∀ index, index < source.parsed.history.objects.length →
    ∃ row expression, source.parsed.history.objects[index]? = some row ∧
      OriginalValueAt (sources.prefix .packageBody) row.before.globals row.before.info row.object expression ∧
      ∀ state, ElaborationStore (sources.prefix .packageBody) row.before.globals row.before.info state →
        ∀ backing, readCell (initializeFrom backing source.parsed.body.info.stateSchema)
          ((stateDeclaration row.object).cell (index + 1)) = expression.evaluate state

theorem SourceMeaning.initial_values {library : ApplicationPackageCompletion.Library}
    {objects : ObjectLibraries} (booleans : BooleanElaboration.Native.SourceImports.Library objects)
    {tokens : List String} (booleanSource : BooleanElaboration.Native.SourceChecks.Checked tokens)
    {packageReaders mainLibrary mainOther mainReaders other sources}
    (source : SourceMeaning library booleans.condition packageReaders mainLibrary mainOther mainReaders other sources)
    (native : source.NativeFacts) : source.InitialValues := by
  have specValid := specification_prefix_valid sources native.valid .packageSpecification
  have bodyValid := specification_prefix_valid sources native.valid .packageBody
  have specFrame := specification_start_framed booleans.condition
    (sources.prefix .packageSpecification) {units := sources.units}
  rw [source.package.started] at specFrame
  have specTyped := readSpecification_typed booleans.condition specValid {units := sources.units}
    (specification_seed_typed sources native.valid.1)
  rw [source.parsed.specified] at specTyped
  exact ⟨source.package.specification.constant_loading booleans booleanSource specValid specFrame,
    fun index inside => ApplicationPackageInitializers.BodyHistory.loaded_values booleans booleanSource library
      source.parsed.history bodyValid native.bodyFrame specTyped.1 native.typed
      (Bool.and_eq_true_iff.mp source.parsed.complete).1 index inside⟩

/-- The same native source interpretation supplies raw Boolean initializer
meaning, so original declaration evaluation is a conclusion alongside all
package/Main semantic checking and full obligation discharge. -/
theorem interpreted_accepted_values {specification implementation scalarSpec packageSpec : List String}
    (native : ApplicationPackageSourceBridge.InterpretedSource specification implementation scalarSpec packageSpec)
    (booleans : BooleanElaboration.Native.SourceImports.Library native.completion.objects)
    (booleanSource : BooleanElaboration.Native.SourceChecks.Checked implementation)
    (packageReaders : Readers) (packageInterpreted : native.completion.readers = sourceReaders packageReaders)
    (imports : ReaderEffects packageReaders)
    (mainOther : ApplicationPackageMain.Calls) (mainReaders : Readers)
    (mainInterpreted : native.main.readers = sourceReaders mainReaders)
    (other : ApplicationAdmission.Calls) (locals : ApplicationNative.Locals)
    (represented : (locals .bundle "sources").Representable)
    (accepted : (ApplicationAdmission.Native.analyzeBody.eval
      (ApplicationAdmission.Native.modelCallees (native.calls booleans.condition mainOther other)) locals).accepted = true) :
    ∃ meaning : SourceMeaning native.completion booleans.condition packageReaders native.main mainOther mainReaders
        (native.boundary other) (locals .bundle "sources"),
      meaning.NativeFacts ∧ meaning.Checked ∧ meaning.Semantic ∧ meaning.InitialValues := by
  obtain ⟨meaning, legal, checked, semantic⟩ := interpreted_accepted_semantics native booleans.condition
    packageReaders packageInterpreted imports mainOther mainReaders mainInterpreted other locals represented accepted
  exact ⟨meaning, legal, checked, semantic, meaning.initial_values booleans booleanSource legal⟩

/-- Raw header source bounds and actual Ada bounds for every runtime argument
list. The original optional argument initializes its exact first String cell;
ordinary declarations then advance their source-order value and bound stores. -/
def SourceMeaning.HeaderBounds {library reader packageReaders mainLibrary mainOther mainReaders other sources}
    (source : SourceMeaning library reader packageReaders mainLibrary mainOther mainReaders other sources) : Prop :=
  let entry := argumentFrame (mainLibrary.model mainOther) sources
    source.parsed.specification.exports source.parsed.body.info
  let final := declarationsFrame (mainLibrary.model mainOther) sources
    source.parsed.specification.exports source.parsed.body.info
  let hasArgument := (contextClauses (mainLibrary.model mainOther) sources source.parsed.body.info).argumentsWith
  ∃ fallback, MainArgumentAt (textOf sources) entry hasArgument fallback ∧
    ∀ (arguments : Arguments.Runtime.Arguments) (bounds : BoundsStore),
      let input := runtimeInput hasArgument fallback arguments
      let inputValid := runtimeInputValid hasArgument arguments
      let values := if hasArgument then argumentDeclaration.execute Bindings.emptyValues input else Bindings.emptyValues
      let initialBounds := if hasArgument then argumentDeclaration.executeBounds bounds input else bounds
      NamesBoundsValid final.names ∧ final.names.length ≤ maxBindings ∧
        Bindings.Fits final.names.shape input (source.main.inventory.runtimeValues hasArgument input) ∧
        initialBounds.Compatible entry.names input ∧
        RawHeaderBoundsTrace (textOf sources) hasArgument (source.main.headerProgram fallback) input inputValid
          entry values source.main.inventory.strings source.main.inventory.booleans source.main.inventory.booleanChecks final ∧
        (executeDeclarationsBounds input source.main.inventory.strings initialBounds).Compatible final.names input ∧
        ActualHeaderBoundsTrace (textOf sources) hasArgument input inputValid entry values initialBounds
          source.main.inventory.strings source.main.inventory.booleans source.main.inventory.booleanChecks final

theorem SourceMeaning.header_bounds {library reader packageReaders mainLibrary mainOther mainReaders other sources}
    (source : SourceMeaning library reader packageReaders mainLibrary mainOther mainReaders other sources)
    (native : source.NativeFacts) (checked : source.Checked) : source.HeaderBounds := by
  obtain ⟨fallback, argument⟩ := source.original_argument native
  refine ⟨fallback, argument, ?_⟩
  intro arguments bounds
  exact original_main_bounds (argument.runtime_start arguments) source.main.declarations rfl rfl rfl
    (textOf_valid native.valid) checked.entry bounds

/-- Runtime safety quantifies over every actual argument list. All initial
stores and the fallback literal come from the original Main syntax; no fitting
store, successful semantic check or safety certificate is a source premise. -/
def SourceMeaning.RuntimeSound {library reader packageReaders mainLibrary mainOther mainReaders other sources}
    (source : SourceMeaning library reader packageReaders mainLibrary mainOther mainReaders other sources) : Prop :=
  let entry := argumentFrame (mainLibrary.model mainOther) sources
    source.parsed.specification.exports source.parsed.body.info
  let final := declarationsFrame (mainLibrary.model mainOther) sources
    source.parsed.specification.exports source.parsed.body.info
  let hasArgument := (contextClauses (mainLibrary.model mainOther) sources source.parsed.body.info).argumentsWith
  let original := mainLibrary.input mainOther sources source.parsed.specification.exports source.parsed.body.info
  let returned := mainLibrary.result mainOther sources source.parsed.specification.exports source.parsed.body.info
  let environment := source.main.inventory.environment (buildSummaryLibrary source.package.entries).environment
  ∃ fallback, MainArgumentAt (textOf sources) entry hasArgument fallback ∧
    ∀ arguments : Arguments.Runtime.Arguments,
      let input := runtimeInput hasArgument fallback arguments
      let inputValid := runtimeInputValid hasArgument arguments
      let values := source.main.inventory.runtimeValues hasArgument input
      let integers := source.main.inventory.runtimeIntegers entry final
      let booleans := source.main.inventory.runtimeBooleans entry values input inputValid
      Applications.ExecutionSound source.parsed.body.info.stateSchema original.context.names.shape
        original.context.analysis (original.context.flow returned.scan.facts) input inputValid false
        (Applications.executeStatements environment (Packages.initialState source.parsed.body.info.stateSchema)
          input inputValid values source.main.code integers booleans)
        (Applications.checkedStatements environment (Packages.initialState source.parsed.body.info.stateSchema)
          input inputValid values source.main.code integers booleans)

theorem SourceMeaning.runtime_sound {library reader packageReaders mainLibrary mainOther mainReaders other sources}
    (source : SourceMeaning library reader packageReaders mainLibrary mainOther mainReaders other sources)
    (native : source.NativeFacts) (checked : source.Checked) (semantic : source.Semantic) :
    source.RuntimeSound := by
  have modeled := (mainLibrary.main_meaning mainOther native.valid source.parsed.specification.exports
    native.mainFrame source.parsed.body.info native.typed source.parsed.complete) ▸ native.mainAccepted
  have present := ((packageMainAt_accepted_iff _ _ _ _).mp modeled).argumentPresent
  obtain ⟨fallback, argument, states⟩ := mainLibrary.original_runtime mainOther native.valid source.parsed.specified
    source.parsed.body.info source.main.declarations checked.entry present
  refine ⟨fallback, argument, ?_⟩
  intro arguments
  obtain ⟨values, printable, allowed, declared⟩ := states arguments
  exact Applications.statements_execution_sound semantic.environment (Packages.initialState_fits semantic.schema)
    checked.body.form checked.body.check values printable allowed declared

/-- Full original-Bundle assurance for the interpreted native Analyze call.
All package definitions (including unused ones), raw initializer values, Main
initial stores, body execution and complete obligations are derived from that
accepted source. The conclusion covers every runtime argument list. -/
theorem interpreted_accepted_assurance {specification implementation scalarSpec packageSpec : List String}
    (native : ApplicationPackageSourceBridge.InterpretedSource specification implementation scalarSpec packageSpec)
    (booleans : BooleanElaboration.Native.SourceImports.Library native.completion.objects)
    (booleanSource : BooleanElaboration.Native.SourceChecks.Checked implementation)
    (packageReaders : Readers) (packageInterpreted : native.completion.readers = sourceReaders packageReaders)
    (imports : ReaderEffects packageReaders)
    (mainOther : ApplicationPackageMain.Calls) (mainReaders : Readers)
    (mainInterpreted : native.main.readers = sourceReaders mainReaders)
    (other : ApplicationAdmission.Calls) (locals : ApplicationNative.Locals)
    (represented : (locals .bundle "sources").Representable)
    (accepted : (ApplicationAdmission.Native.analyzeBody.eval
      (ApplicationAdmission.Native.modelCallees (native.calls booleans.condition mainOther other)) locals).accepted = true) :
    ∃ meaning : SourceMeaning native.completion booleans.condition packageReaders native.main mainOther mainReaders
        (native.boundary other) (locals .bundle "sources"),
      meaning.NativeFacts ∧ meaning.Checked ∧ meaning.Semantic ∧ meaning.InitialValues ∧
        meaning.HeaderBounds ∧ meaning.RuntimeSound := by
  obtain ⟨meaning, legal, checked, semantic, values⟩ := interpreted_accepted_values native booleans booleanSource
    packageReaders packageInterpreted imports mainOther mainReaders mainInterpreted other locals represented accepted
  exact ⟨meaning, legal, checked, semantic, values, meaning.header_bounds legal checked,
    meaning.runtime_sound legal checked semantic⟩

/-- The canonical native effect imports discharge the primitive equations as
well. This endpoint has no caller-supplied semantic coverage, successful decoder,
checker or safety premise beyond the original accepted native call itself. -/
theorem interpreted_bound_assurance {specification implementation scalarSpec packageSpec : List String}
    (native : ApplicationPackageSourceBridge.InterpretedSource specification implementation scalarSpec packageSpec)
    (booleans : BooleanElaboration.Native.SourceImports.Library native.completion.objects)
    (booleanSource : BooleanElaboration.Native.SourceChecks.Checked implementation)
    (recursive : ApplicationPackageBodies.RecursiveSource.Libraries) (packageOther : Readers)
    (packageInterpreted : native.completion.readers = sourceReaders
      (recursive.readers (ReaderEffectsImports.boundReaders native.completion.leaves.effects packageOther)))
    (mainOther : ApplicationPackageMain.Calls) (mainReaders : Readers)
    (mainInterpreted : native.main.readers = sourceReaders mainReaders)
    (other : ApplicationAdmission.Calls) (locals : ApplicationNative.Locals)
    (represented : (locals .bundle "sources").Representable)
    (accepted : (ApplicationAdmission.Native.analyzeBody.eval
      (ApplicationAdmission.Native.modelCallees (native.calls booleans.condition mainOther other)) locals).accepted = true) :
    let packageReaders := recursive.readers (ReaderEffectsImports.boundReaders native.completion.leaves.effects packageOther)
    ∃ meaning : SourceMeaning native.completion booleans.condition packageReaders native.main mainOther mainReaders
        (native.boundary other) (locals .bundle "sources"),
      meaning.NativeFacts ∧ meaning.Checked ∧ meaning.Semantic ∧ meaning.InitialValues ∧
        meaning.HeaderBounds ∧ meaning.RuntimeSound :=
  interpreted_accepted_assurance native booleans booleanSource _ packageInterpreted
    (ReaderEffectsImports.bound recursive native.completion.leaves.effects packageOther)
    mainOther mainReaders mainInterpreted other locals represented accepted

end Silver.ApplicationPackageOriginal
