module

public import Silver.ApplicationPackageRoutineSourceEntries

@[expose] public section

namespace Silver.ApplicationPackageBodies
open Compose PackageBindings ApplicationPackageDeclarations

/-- Original state declarations change the state table and advance the
global cursor, while retaining the package's unit spans and exported names. -/
theorem StateObjects.outer_metadata {calls : UnitCalls} {text : Source}
    {before after : UnitState} {rows : List StateObject}
    (history : StateObjects calls text before rows after) :
    after.info.units = before.info.units ∧ after.info.exports = before.info.exports := by
  induction history with
  | finished => exact ⟨rfl, rfl⟩
  | added _ _ _ _ _ _ _ ih => exact ih

theorem CompletionFrames.outer_metadata {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    (present : result.globals.position ≠ 0) :
    result.info.units = info.units ∧ result.info.exports = info.exports := by
  obtain ⟨read⟩ := completion_body_read frames.executed present
  have signed : readSignature text globals info true = frames.signature := frames.signed
  have retained := signed ▸ (readSignature_exec text globals info true).retains_fields
  rw [read.stored]
  constructor
  · simpa only [finishedInfo, SignatureStates.unchangedFields] using congrArg Metadata.units retained
  · simpa only [finishedInfo, SignatureStates.unchangedFields] using congrArg Metadata.exports retained

theorem RoutineHistory.outer_metadata {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {before : UnitState} {rows : List RoutineRead} {result : ApplicationAdmission.BodyResult}
    (history : RoutineHistory (bodyReaders reader calls) text before rows result) :
    result.info.units = before.info.units ∧ result.info.exports = before.info.exports := by
  induction history with
  | finished phase allRead footer =>
    dsimp only [unitStep] at footer
    cases footer
    exact ⟨rfl, rfl⟩
  | @added row later result phase pending read advanced rest ih =>
    obtain ⟨frames⟩ := RoutineRead.frames read (by omega)
    have kept := frames.outer_metadata (by omega)
    exact ⟨ih.1.trans kept.1, ih.2.trans kept.2⟩

end Silver.ApplicationPackageBodies

namespace Silver.ApplicationPackageRoutineSources
open Compose Packages ApplicationPackageBodies ApplicationPackageDeclarations
open ApplicationPackageInitializers ApplicationPackageRoutineClosedFrames ApplicationPackageObjectRows
open ApplicationPackageFrameLayout ApplicationPackageExportRows
open ApplicationPackageRoutineResults

/-- The accepted original package constructs the initial routine invariant.
Only native representation domains are inputs: all declaration origins, source
ordering, table facts and interface domains follow from the original histories
and the final metadata check. -/
theorem original_frame_facts {reader : BooleanElaboration.Native.Reader} {completion : CompletionCalls}
    {calls : ApplicationAdmission.Calls} {sources : ApplicationUnits.Bundle} {result : ApplicationAdmission.AnalysisResult}
    (parsed : ApplicationAdmission.ParsedPackage reader completion calls sources result)
    (valid : sources.Valid)
    (framed : ReaderFrame (sources.prefix .packageBody) parsed.history.routinesStart.globals)
    (typed : parsed.history.routinesStart.info.Typed) (finalTyped : parsed.body.info.Typed) :
    RoutineFrameFacts (sources.prefix .packageSpecification) parsed.specification.exports.scalarNames
      (sources.prefix .packageBody) parsed.history.routinesStart.globals parsed.history.routinesStart.info := by
  have initial := parsed.history.initial
  have entry := source_state_entry_positions reader (readCompletion reader completion) sources valid
    parsed.specified parsed.specificationAccepted parsed.history.entered
  have specification : Tables parsed.specification.exports := parsed.specified ▸
    specification_tables (reader := reader) rfl rfl
      (readSpecification_exec reader (sources.prefix .packageSpecification) {units := sources.units})
  have tables := stateHistory_tables (reader := reader) parsed.history.declarations (fun _ _ => rfl)
    (unitStart_tables specification parsed.history.entered)
  have frame := stateHistory_fields (reader := reader) parsed.history.declarations (fun _ _ => rfl) initial.frame
  have origins := ApplicationPackageInitializers.StateObjects.scalar_origins
    (reader := reader) parsed.history.declarations (fun _ _ => rfl)
    (show GlobalScalarOrigins parsed.specification.exports.scalarNames parsed.history.entry.info.states
      parsed.history.entry.globals.scalarNames by
        rw [initial.empty, entry.1]
        exact GlobalScalarOrigins.initial _)
  have declarations := stateHistory_declarations (reader := reader) parsed.history.declarations (fun _ _ => rfl)
    initial.frame (initial.empty ▸ StateDeclarations.empty (sources.prefix .packageBody))
  have clear := stateHistory_clear (reader := reader) parsed.history.declarations (fun _ _ => rfl) initial.frame
    (show GlobalRowsClear (sources.prefix .packageBody) parsed.history.entry.info.states
      (integerRows parsed.history.entry.globals) by
        rw [initial.empty]
        exact GlobalRowsClear.emptyStates _ _)
  have states := (parsed.history.completions.source_layouts frame framed.typed.scalarCount).1
  have bounded := state_bounds_from_final states.symm parsed.complete
  have routineTables := parsed.history.routine_start_tables
  have declared := (original_formal_modes parsed).1.of_declarations
    (congrArg (List.map formalDeclaration) routineTables.2)
    (congrArg (List.map routineDeclaration) routineTables.1)
  have interfaces := (parsed.history.completions.interfaces
    (InterfaceDomains.of_metadata finalTyped (Bool.and_eq_true_iff.mp parsed.complete).1)).1
  have statesOuter := parsed.history.declarations.outer_metadata
  have routineOuter := parsed.history.completions.outer_metadata
  have units : parsed.body.info.units = sources.units :=
    routineOuter.1.trans (statesOuter.1.trans initial.units)
  have exports := metadata_exports_before_body (Bool.and_eq_true_iff.mp parsed.complete).1
  rw [routineOuter.2, units] at exports
  have progress := parsed.history.declarations.cursor_order.1
  exact ⟨framed, typed, tables, frame, origins, Nat.lt_of_lt_of_le entry.2.1 progress,
    declarations, clear, bounded, declared, interfaces,
    fun item member => Nat.lt_trans (exports item member) (Nat.lt_of_lt_of_le entry.2.2 progress)⟩

end Silver.ApplicationPackageRoutineSources
