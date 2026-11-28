module

public import Silver.ApplicationPackageEntrySeedRows
public import Silver.ApplicationPackageRoutineEntryScope

@[expose] public section

namespace Silver.ApplicationPackageInitializers
open Compose Compose.Expressions Predicate Packages ApplicationPackageDeclarations ApplicationPackageBodies
open ApplicationPackageObjectRows ApplicationPackageFrameLayout ApplicationPackageFormalStorage
open ApplicationPackageRoutineClosedFrames

theorem routine_frame_ready {calls : ApplicationPackageRoutineFrame.Calls}
    (body : calls.bodyEnvironment = ScalarExpression.bodyEnvironment)
    (hide : calls.hideOuter = ApplicationPackageFrames.hideOuter)
    (append : calls.appendFormal = ApplicationPackageDeclarations.appendFormal)
    {text : Source} {globals after : ParserState} {info : PackageBindings.Metadata} {routine position : Nat}
    (parsed : ApplicationPackageRoutineFrame.routineFrame calls text globals info routine position = after)
    (present : after.position ≠ 0) : ScalarExpression.BodyReady after.scalarNames := by
  obtain ⟨hidden, retained, added⟩ := routineFrame_tables hide append parsed present
  intro row member mutable
  rw [added.integers] at member
  rcases List.mem_append.mp member with old | new
  · have previous := retained.integers.subset old
    change row ∈ calls.bodyEnvironment globals.scalarNames at previous
    rw [body] at previous
    exact ScalarExpression.bodyEnvironment_ready _ _ previous mutable
  · obtain ⟨formal, _, stored⟩ := List.mem_filterMap.mp new
    unfold ApplicationPackageFormalStorage.scalar at stored
    split at stored
    · cases stored
      rfl
    · contradiction

theorem ScalarRangeRows.body_ready {info : PackageBindings.Metadata} {ranges : SharedRanges}
    {names : ScalarExpression.Environment} (rows : ScalarRangeRows info ranges names)
    (ready : ScalarExpression.BodyReady names) :
    ScalarRangeRows info ranges (ScalarExpression.bodyEnvironment names) := by
  intro row member
  obtain ⟨original, included, rfl⟩ := List.mem_map.mp member
  change integerRangeAt ranges (rowAddress info .integer
    ⟨original.first, original.after, original.qualifierFirst, original.qualifierAfter⟩) =
      some (if original.mutable then original.declaredBounds else original.bounds)
  by_cases mutable : original.mutable = true
  · rw [ite_eq_left mutable, ← ready original included mutable]
    exact rows original included
  · rw [ite_eq_right mutable]
    exact rows original included

theorem LocalObjects.reader_frame {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {info : PackageBindings.Metadata} {item : PackageBindings.Routine}
    {before after : InitializationFrame} {objects : List LocalObject}
    (history : LocalObjects calls text info item before objects after) (textValid : ValidText text)
    (original : ∀ row ∈ objects, calls.objectAt text row.before.frame info true =
      objectStep (modelObjectCalls reader) text row.before.frame info true)
    (initial : ReaderFrame text before.frame) : ReaderFrame text after.frame := by
  induction history with
  | finished => exact initial
  | @added row final following atBegin apart parsed advanced rest ih =>
    have execution := (original row List.mem_cons_self).symm.trans parsed
    have present : row.object.frame.position ≠ 0 := by omega
    apply ih (fun seen member => original seen (List.mem_cons_of_mem _ member))
    change ReaderFrame text row.object.frame
    exact execution ▸ objectStep_reader_frame reader textValid row.before.frame initial info true (execution ▸ present)

/-- Original declaration, local and output histories produce the complete
native initialization phases and exact body declaration ranges. The source
range map is derived internally from the specification and routine header. -/
theorem CompletionFrames.source_initialization {reader : BooleanElaboration.Native.Reader}
    {specText : Source} {specStart specEnd : SpecificationState} {specRows : List SpecificationItem}
    (specified : SpecificationInventories reader specText specStart specRows (.ready specEnd))
    (specValid : ValidText specText) (specFrame : ReaderFrame specText specStart.exports)
    (specOrder : FrameOrder specStart.exports) (specEmpty : specStart.exports.scalarNames = [])
    {calls : CompletionCalls} {text : Source} {globals : ParserState}
    {info : PackageBindings.Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    (textValid : ValidText text) (entryFramed : ReaderFrame text frames.entry)
    (tables : Tables globals) (initial : StateFrame info.states globals)
    (origin : GlobalScalarOrigins specEnd.exports.scalarNames info.states globals.scalarNames)
    (separated : specText.length < globals.position)
    (actual : calls.actualAfter = Predicate.actualAfter)
    (flow : calls.initialFlow = fun context => ActiveFlow.initial context.scalarNames (initialFacts context.hasArguments)) :
    let metadata := frames.signature.info
    let entry : SharedRanges := ⟨metadata.stateSchema.integerRanges,
      inputRangesFrom Integer.emptyRanges (routineInputs metadata (metadata.routineAt (info.completed + 1)))⟩
    let seeds := (specificationSeeds specRows).map ConstantSeed.initializer
    ∃ locals outputRows outputs final,
      LocalValuesAt text.length metadata text frames.objects locals ∧
      OutputObjects (declarationReaders reader calls) text metadata
        (formalIndices (metadata.routineAt (info.completed + 1)))
        (beginOutputs (declarationReaders reader calls) text frames.locals) outputRows frames.outputs.initialized ∧
      OutputValuesAt text.length (declarationReaders reader calls) metadata text outputRows outputs ∧
      (∀ item ∈ (seeds ++ locals) ++ outputs, item.Readable) ∧
      (InitializerPhases.mk (seeds ++ locals) outputs (mutableLocalCells frames.objects)).check entry = some final ∧
      final.body = initializerDomains entry ((seeds ++ locals) ++ outputs) ∧
      (completionContextOf (declarationReaders reader calls) frames.outputs.body).analysis.declared =
        final.body.view (layout text.length metadata (completionContextOf (declarationReaders reader calls) frames.outputs.body)) := by
  have signed : readSignature text globals info true = frames.signature := frames.signed
  have order := signed ▸ readSignature_completed_order text globals info (signed ▸ frames.headerPresent)
  have window := HeaderWindow.of_offsets order.progress order.formals.span order.formals.before
  have states : frames.signature.info.states = info.states := signed ▸ readSignature_states text globals info true
  have entered : ApplicationPackageRoutineFrame.routineFrame routineFrameReaders text globals frames.signature.info
      (info.completed + 1) frames.signature.header.position = frames.entry := frames.entered
  let entry : SharedRanges := ⟨frames.signature.info.stateSchema.integerRanges,
    inputRangesFrom Integer.emptyRanges (routineInputs frames.signature.info
      (frames.signature.info.routineAt (info.completed + 1)))⟩
  let seeds := (specificationSeeds specRows).map ConstantSeed.initializer
  let seeded := seedRanges entry (specificationSeeds specRows)
  have entryClosed : Closed frames.entry := entered ▸ routineFrame_closed (calls := routineFrameReaders)
    rfl rfl tables (entered ▸ frames.entryPresent)
  have entryScope := routineFrame_source (calls := routineFrameReaders) rfl rfl rfl
    (states ▸ initial) window entered frames.entryPresent
  obtain ⟨hidden, retained, installed⟩ := routineFrame_tables (calls := routineFrameReaders) rfl rfl entered frames.entryPresent
  have position : frames.entry.position = frames.signature.header.position := installed.position.trans retained.position
  have bounded : frames.signature.header.position ≤ text.length + 1 := position ▸ entryFramed.cursor
  obtain ⟨seedRows, seedBound⟩ := source_routine_seed_rows specified specOrder specEmpty
    (calls := routineFrameReaders) rfl rfl rfl (states ▸ initial) (states ▸ origin) window separated
    bounded entered frames.entryPresent
  have declaredRows := seedRows.body_ready (routine_frame_ready (calls := routineFrameReaders) rfl rfl rfl
    entered frames.entryPresent)
  obtain ⟨locals, localSources, localReadable, localCheck, localDomains, localRows, localDeclared, localBound, localDeclaredBound⟩ :=
    local_objects_initializers textValid entryFramed entryClosed entryScope.source frames.declarations
      (fun _ _ => rfl) seedRows declaredRows seedBound seedBound
  have localsFramed := Silver.ApplicationPackageInitializers.LocalObjects.reader_frame
    frames.declarations textValid (fun _ _ => rfl) entryFramed
  have localsClosed := (localHistory_closed frames.declarations (fun _ _ => rfl) entryClosed).1
  have localsScope := entryScope.locals (reader := reader) frames.declarations (fun _ _ => rfl)
  have beginPresent : fixedAfter text frames.locals.frame.position "begin" true ≠ 0 := frames.declarations.at_begin
  have beginBounds := fixed_window (by decide) beginPresent
  have startFrame : ReaderFrame text (beginOutputs (declarationReaders reader calls) text frames.locals).frame :=
    localsFramed.at_position beginBounds.2
  have startClosed : Closed (beginOutputs (declarationReaders reader calls) text frames.locals).frame :=
    ⟨⟨localsClosed.dynamicFirst, localsClosed.names, localsClosed.arrayNames⟩, localsClosed.pure⟩
  have startScope := localsScope.reposition (Nat.le_of_lt beginBounds.1)
  obtain ⟨outputRows, outputHistory⟩ := output_initializers_objects frames.outputs.read
  have outputFrames := outputHistory.frames rfl startFrame startClosed
  have outputTargets := outputHistory.target_domains startScope startFrame.cursor
  obtain ⟨outputs, finalRanges, outputSources, outputReadable, outputCheck, _, _⟩ :=
    output_objects_initializers (calls := declarationReaders reader calls) textValid rfl actual rfl flow
      outputHistory outputFrames.2.2 outputTargets
      localDeclared localDeclaredBound
  have outputStorage := outputs_stored (calls := declarationReaders reader calls) rfl text frames.signature.info _ frames.outputs.installed
  have bodyRows := output_declared_rows outputHistory outputSources startScope outputStorage
    localDeclared localDeclaredBound startFrame.cursor
  have seedCheck : checkInitializers entry seeds = some seeded := specified.seeds_checked specValid specFrame entry
  have initialized := source_phases_check seedCheck rfl localCheck localDomains outputCheck
  have domainEq : initializerDomains entry ((seeds ++ locals) ++ outputs) =
      initializerDomains (localDeclaredRanges seeded frames.objects) outputs := by
    rw [initializerDomains_append, initializerDomains_append]
    exact congrArg (fun ranges => initializerDomains ranges outputs) localDomains
  have noArrays := (frames.body_closed tables).arrayNames
  refine ⟨locals, outputRows, outputs, ⟨finalRanges, initializerDomains (localDeclaredRanges seeded frames.objects) outputs⟩,
    localSources, outputHistory, outputSources, ?_, initialized, domainEq.symm, ?_⟩
  · intro item member
    rcases List.mem_append.mp member with earlier | output
    · rcases List.mem_append.mp earlier with seed | localObject
      · exact constant_seeds_readable _ item seed
      · exact localReadable item localObject
    · exact outputReadable item output
  · exact body_declared_view bodyRows.1 bodyRows.2 noArrays

end Silver.ApplicationPackageInitializers
