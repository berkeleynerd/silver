module

public import Silver.ApplicationPackageGlobalShadowHistory
public import Silver.ApplicationPackageCompletionSourceLayout

@[expose] public section

namespace Silver.ApplicationPackageFrameLayout
open Compose Predicate Packages ApplicationPackageObjectRows

/-- Facts derived from original declaration histories and the final native body
environment. They are not requirements on arbitrary standalone helper inputs. -/
structure VisibleContext (text : Source) (info : PackageBindings.Metadata) (context : ParseContext) : Prop where
  declarations : StateDeclarations text info.states
  clear : GlobalRowsClear text info.states (scalarRows context)
  capacity : context.scalarNames.length ≤ ArrayBindings.scalarLimit
  ready : ScalarExpression.BodyReady context.scalarNames
  fields : ScalarStateFields info.states context.scalarNames

theorem VisibleContext.reset {text : Source} {info : PackageBindings.Metadata} {context : ParseContext}
    (source : VisibleContext text info context) (bound : Nat) (writes : PackageBindings.StateSet) (flow : Flow) :
    ApplicationPackageCalls.resetSlotsFlow context.scalarNames
      (ApplicationPackageCalls.resetSlots ApplicationPackageCalls.modelCalls text context info writes
        ((List.range info.states.length).map (· + 1))) flow =
      resetGlobalFlow context.analysis.declared (layout bound info context) (info.effectCells writes) flow :=
  resetSlotsFlow_source bound source.declarations source.clear source.capacity source.ready source.fields flow

end Silver.ApplicationPackageFrameLayout

namespace Silver.ApplicationPackageBodies
open Compose Predicate ApplicationPackageDeclarations ApplicationPackageObjectRows ApplicationPackageFormalStorage
open ApplicationPackageFrameLayout

/-- Signature, Routine_Frame, every local Object and both output passes are the
actual selected source readers. Only their recorded histories are used to derive
the visibility/reset representation facts at the completed body context. -/
theorem CompletionFrames.source_visible {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : PackageBindings.Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    (initial : StateFrame info.states globals)
    (declarations : StateDeclarations text info.states)
    (clear : GlobalRowsClear text info.states (integerRows globals))
    (capacity : globals.scalarNames.length ≤ ScalarExpression.maxBindings) :
    VisibleContext text frames.signature.info (completionContextOf (declarationReaders reader calls) frames.outputs.body) := by
  have signed : readSignature text globals info true = frames.signature := frames.signed
  have order := signed ▸ readSignature_completed_order text globals info (signed ▸ frames.headerPresent)
  have window := HeaderWindow.of_offsets order.progress order.formals.span order.formals.before
  have states : frames.signature.info.states = info.states := signed ▸ readSignature_states text globals info true
  have entered : ApplicationPackageRoutineFrame.routineFrame routineFrameReaders text globals frames.signature.info
      (info.completed + 1) frames.signature.header.position = frames.entry := frames.entered
  have entry := routineFrame_source (calls := routineFrameReaders) rfl rfl rfl (states ▸ initial) window entered frames.entryPresent
  have entryClear := routineFrame_clear (calls := routineFrameReaders) rfl rfl rfl
    (states ▸ initial) window (states ▸ clear) entered frames.entryPresent
  have localScope := entry.locals (reader := reader) frames.declarations (fun _ _ => rfl)
  have localClear := localHistory_clear (reader := reader) frames.declarations (fun _ _ => rfl)
    entry.source entryClear.1 entryClear.2
  have initialized := (outputInitializers_frame _ frames.outputs.read).1
  have stored := outputs_stored (calls := declarationReaders reader calls) rfl text frames.signature.info _ frames.outputs.installed
  have initializedClear : GlobalRowsClear text frames.signature.info.states (integerRows frames.outputs.initialized.frame) := by
    rw [initialized]
    exact localClear.1
  have initializedApart : GlobalRowsApart text frames.signature.info.states (integerRows frames.outputs.initialized.frame)
      ((formalIndices (frames.signature.info.routineAt (info.completed + 1))).map
        (fun index => (frames.signature.info.parameterAt index).bodyName)) := by
    rw [initialized]
    exact localClear.2
  have outputApart : GlobalRowsApart text frames.signature.info.states (integerRows frames.outputs.initialized.frame)
      ((chosen true frames.signature.info (formalIndices (frames.signature.info.routineAt (info.completed + 1)))).map (·.bodyName)) := by
    apply initializedApart.select
    intro name member
    obtain ⟨formal, chosen, rfl⟩ := List.mem_map.mp member
    obtain ⟨index, selected, rfl⟩ := List.mem_map.mp ((chosen_sublist true frames.signature.info _).subset chosen)
    exact List.mem_map_of_mem selected
  have completeClear := stored_global_clear stored initializedClear outputApart localScope.distinctStates
  have initializedFields : ScalarStateFields frames.signature.info.states frames.outputs.initialized.frame.scalarNames := by
    rw [initialized]
    exact localScope.source.scalarFields
  have completeFields := stored.state_fields initializedFields localScope.distinctStates
  have entrySize := routineFrame_capacity (calls := routineFrameReaders) rfl rfl rfl entered frames.entryPresent capacity
  have localSize := localHistory_capacity (reader := reader) frames.declarations (fun _ _ => rfl) entrySize
  have finalSize := outputFrame_capacity frames.outputs rfl localSize
  have grounded : completionContextOf (declarationReaders reader calls) frames.outputs.body =
      {contextOf ⟨frames.outputs.completed, frames.outputs.initialized.initialized, false⟩ with declarationCount := 0} := rfl
  rw [grounded]
  refine ⟨states ▸ declarations, ?_, ?_, ScalarExpression.bodyEnvironment_ready _, completeFields.bodyEnvironment⟩
  · change GlobalRowsClear text frames.signature.info.states
      (scalarRows (contextOf ⟨frames.outputs.completed, frames.outputs.initialized.initialized, false⟩))
    rw [(context_rows _).1]
    exact completeClear
  · simpa only [contextOf, ScalarExpression.bodyEnvironment_length,
      ScalarExpression.maxBindings, ArrayBindings.scalarLimit] using finalSize

/-- A completed routine preserves package declarations and global binding
rows for the following completion; only the globals cursor advances. -/
theorem CompletionFrames.globals_visible {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : PackageBindings.Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    (present : result.globals.position ≠ 0)
    (declarations : StateDeclarations text info.states)
    (clear : GlobalRowsClear text info.states (integerRows globals)) :
    StateDeclarations text result.info.states ∧ GlobalRowsClear text result.info.states (integerRows result.globals) := by
  have signed : readSignature text globals info true = frames.signature := frames.signed
  have states : frames.signature.info.states = info.states := signed ▸ readSignature_states text globals info true
  have resultState := completionBody_globals frames.executed present
  rw [resultState.2.2, states, resultState.1]
  exact ⟨declarations, clear⟩

theorem packageCompletionFuel_source_visible (reader : BooleanElaboration.Native.Reader) (calls : CompletionCalls)
    {fuel : Nat} {text : Source} {globals : ParserState} {info : PackageBindings.Metadata} {result : CompletionResult}
    (read : packageCompletionFuel (declarationReaders reader calls) fuel text globals info = some result)
    (present : result.globals.position ≠ 0) (initial : StateFrame info.states globals)
    (declarations : StateDeclarations text info.states)
    (clear : GlobalRowsClear text info.states (integerRows globals))
    (capacity : globals.scalarNames.length ≤ ScalarExpression.maxBindings) :
    ∃ frames : CompletionFrames (declarationReaders reader calls) text globals info result,
      VisibleContext text frames.signature.info (completionContextOf (declarationReaders reader calls) frames.outputs.body) ∧
        StateDeclarations text result.info.states ∧ GlobalRowsClear text result.info.states (integerRows result.globals) := by
  obtain ⟨frames⟩ := packageCompletionFuel_frames read present
  exact ⟨frames, frames.source_visible initial declarations clear capacity,
    frames.globals_visible present declarations clear⟩

end Silver.ApplicationPackageBodies
