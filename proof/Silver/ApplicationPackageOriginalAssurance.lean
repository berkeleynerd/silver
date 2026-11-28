module

public import Silver.ApplicationPackageOriginalAssembly
public import Silver.ApplicationPackageRoutineInitializerEffects
public import Silver.ApplicationSummaryAssurance
public import Silver.ApplicationPackageOriginalValues

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
    List Predicate.Obligation :=
  source.package.headerObligations ++
    summaryLibraryObligationsFrom source.parsed.body.info.stateSchema .empty source.package.entries ++
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
  discharged : Predicate.discharged source.obligations = true

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
  refine ⟨source.parsed.body.info.stateSchema_valid native.typed
      (Bool.and_eq_true_iff.mp source.parsed.complete).1,
    package.1, ⟨checked.functions, checked.procedures, package.2.1⟩, package.2.2.1, functions, ?_⟩
  rw [SourceMeaning.obligations, Predicate.discharged_append, Predicate.discharged_append,
    checked.headers, package.2.2.2, checked.mainObligations]
  rfl

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

end Silver.ApplicationPackageOriginal
