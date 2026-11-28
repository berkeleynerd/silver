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

end Silver.ApplicationPackageOriginal
