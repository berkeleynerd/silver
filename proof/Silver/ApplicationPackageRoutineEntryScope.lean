module

public import Silver.ApplicationPackageSemanticMeaning
public import Silver.ApplicationPackageCompletionVisibleState
public import Silver.ApplicationPackageRoutineClosedFrames
public import Silver.ApplicationPackageSourceFunctionCalls
public import Silver.PredicateHeaderFlow
public import Silver.ComposeDeclarationBounds

@[expose] public section

/-! Original completion histories establish the recursive routine's entry
scope. Its initial ranges are the actual Body_Of/Context_Of ranges; no body
checker, semantic decoder or successful discharge is an entry premise. -/
namespace Silver.ApplicationPackageBodies
open Compose Predicate ApplicationPackages ApplicationPackageDeclarations
open ApplicationPackageFormalStorage ApplicationPackageObjectRows ApplicationPackageFrameLayout
open ApplicationPackageRoutineClosedFrames SourceSyntax

set_option backward.dsimp.instances true

theorem state_bounds_of_metadata {text : PackageBindings.Text} {info : PackageBindings.Metadata}
    (valid : PackageBindings.validMetadata text info = true) :
    ∀ state ∈ info.states, state.declaredBounds.isEmpty = false := by
  intro state member
  obtain ⟨offset, inside, same⟩ := List.mem_iff_getElem.mp member
  have checked := PackageBindings.validMetadata_state valid (offset + 1) (by omega) (by omega)
  have selected : info.stateAt (offset + 1) = state := by
    simpa only [PackageBindings.Metadata.stateAt, Nat.add_one_sub_one,
      List.getD_eq_getElem?_getD, List.getElem?_eq_getElem inside, Option.getD_some] using same
  simp only [PackageBindings.stateValid, selected, Bool.and_eq_true] at checked
  simpa only [Bool.not_eq_true'] using checked.1.1.2

/-- State declaration identities and bounds are unchanged by routine
completion. The final native metadata check therefore supplies precisely the
nonempty state domains used by the recursive join proof. -/
theorem state_bounds_from_final {text : PackageBindings.Text} {before final : PackageBindings.Metadata}
    (same : before.states = final.states) (complete : PackageBindings.completeMetadata text final = true) :
    ∀ state ∈ before.states, state.declaredBounds.isEmpty = false := by
  rw [same]
  exact state_bounds_of_metadata (Bool.and_eq_true_iff.mp complete).1

def CompletionFrames.bodySource {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : PackageBindings.Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result) : Statement.Input :=
  ⟨text, completionContextOf (declarationReaders reader calls) frames.outputs.body,
    completionInput (declarationReaders reader calls) (frames.signature.info.routineAt (info.completed + 1))
      frames.outputs.body, frames.signature.info, {}, {}⟩

theorem CompletionFrames.body_closed {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : PackageBindings.Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    (tables : Tables globals) : Closed frames.outputs.completed := by
  have entered : ApplicationPackageRoutineFrame.routineFrame routineFrameReaders text globals frames.signature.info
      (info.completed + 1) frames.signature.header.position = frames.entry := frames.entered
  have entry : Closed frames.entry := entered ▸ routineFrame_closed (calls := routineFrameReaders)
    rfl rfl tables (entered ▸ frames.entryPresent)
  have localsClosed := (localHistory_closed frames.declarations (fun _ _ => rfl) entry).1
  have begun : Closed (beginOutputs (declarationReaders reader calls) text frames.locals).frame :=
    ⟨⟨localsClosed.dynamicFirst, localsClosed.names, localsClosed.arrayNames⟩, localsClosed.pure⟩
  exact (appendOutputs_retains rfl frames.outputs.installed).closed
    ((outputInitializers_retains frames.outputs.read).closed begun)

theorem CompletionFrames.states_before_body {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : PackageBindings.Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    (initial : StateFrame info.states globals) :
    ∀ state ∈ frames.signature.info.states, state.name.first < frames.bodySource.input.scan.position := by
  have signed : readSignature text globals info true = frames.signature := frames.signed
  have order := signed ▸ readSignature_completed_order text globals info (signed ▸ frames.headerPresent)
  have window := HeaderWindow.of_offsets order.progress order.formals.span order.formals.before
  have states : frames.signature.info.states = info.states := signed ▸ readSignature_states text globals info true
  have entered : ApplicationPackageRoutineFrame.routineFrame routineFrameReaders text globals frames.signature.info
      (info.completed + 1) frames.signature.header.position = frames.entry := frames.entered
  have entry := routineFrame_source (calls := routineFrameReaders) rfl rfl rfl
    (states ▸ initial) window entered frames.entryPresent
  have localScope := entry.locals (reader := reader) frames.declarations (fun _ _ => rfl)
  have beginPresent : fixedAfter text frames.locals.frame.position "begin" true ≠ 0 := frames.declarations.at_begin
  have later : frames.locals.frame.position ≤
      (beginOutputs (declarationReaders reader calls) text frames.locals).frame.position :=
    Nat.le_of_lt (fixed_window (by decide) beginPresent).1
  have read := (localScope.reposition later).initializers frames.outputs.read
  have stored := outputs_stored (calls := declarationReaders reader calls) rfl text frames.signature.info _ frames.outputs.installed
  intro state member
  change state.name.first < frames.outputs.completed.position
  rw [stored.position]
  exact read.source.statesBefore state member

theorem CompletionFrames.body_initial_ranges {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : PackageBindings.Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result) :
    (frames.bodySource.context.flow frames.bodySource.input.scan.facts).scalars =
      frames.bodySource.context.analysis.declared := by
  change ((contextOf ⟨frames.outputs.completed, frames.outputs.initialized.initialized, false⟩).flow
    (bodyOf ⟨frames.outputs.completed, frames.outputs.initialized.initialized, false⟩).facts).scalars =
      (contextOf ⟨frames.outputs.completed, frames.outputs.initialized.initialized, false⟩).analysis.declared
  exact congrArg Flow.scalars (bodyOf_model _)

theorem CompletionFrames.body_hidden {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : PackageBindings.Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result) (bound : Nat) :
    HiddenRanges bound frames.bodySource (frames.bodySource.context.flow frames.bodySource.input.scan.facts) := by
  intro slot _ _ _
  exact congrFun frames.body_initial_ranges slot

theorem CompletionFrames.body_scope {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : PackageBindings.Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    (initial : StateFrame info.states globals) (tables : Tables globals)
    (declarations : StateDeclarations text info.states)
    (clear : GlobalRowsClear text info.states (integerRows globals))
    (capacity : globals.scalarNames.length ≤ ScalarExpression.maxBindings)
    (typed : frames.signature.info.Typed)
    (bounds : ∀ state ∈ info.states, state.declaredBounds.isEmpty = false)
    (declared : DeclaredFormalModes info) (writes : CompletedFunctionWrites info) :
    PackageScope frames.bodySource := by
  have closed := frames.body_closed tables
  have visible := frames.source_visible initial declarations clear capacity
  have signed : readSignature text globals info true = frames.signature := frames.signed
  have states : frames.signature.info.states = info.states := signed ▸ readSignature_states text globals info true
  have names : frames.bodySource.context.names = [] := closed.names
  refine ⟨?_, rfl, typed, states ▸ bounds, frames.body_formal_modes declared,
    frames.body_function_writes writes, closed.pure, ?_, ?_, closed.arrayNames, rfl, rfl,
    visible.declarations, visible.fields, frames.states_before_body initial⟩
  · rw [names]
    exact namesBoundsValid_empty.normal
  · simp only [CompletionFrames.bodySource, completionContextOf, declarationReaders, contextOf,
      OutputFrames.body, closed.dynamicFirst, ne_eq, not_true_eq_false, decide_false]
  · rw [names]
    exact empty_names_shape

end Silver.ApplicationPackageBodies
