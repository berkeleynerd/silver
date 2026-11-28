module

public import Silver.ApplicationPackageReturnReading
public import Silver.ApplicationPackageRoutineEntryScope

@[expose] public section

/-! Routine results retain the original terminal expression or the original
writable formal rows. The result checker is derived from the native reader
domain and final flow, never supplied as an admission premise. -/
namespace Silver.ApplicationPackageRoutineResults
open Compose Predicate Packages ApplicationPackages ApplicationPackageBodies
open ApplicationPackageBodies.Recursive ApplicationPackageBodies.SourceSyntax
open PackageBindings (Metadata Routine)

set_option backward.dsimp.instances true

/-- The original function return is checked in the completed body's incoming
flow. Its original expression and all intermediate obligations remain visible. -/
theorem function_results {calls : CompletionCalls} {text : Source} {globals : ParserState}
    {info : Metadata} {index : Nat} {item : Routine} {state : InitializationFrame}
    {result : CompletionResult}
    (read : CompletionBodyRead calls text globals info index item state result)
    (take : calls.takeToken = tokenAfter)
    (returnAfter : calls.functionReturnAfter = functionReturnAfter)
    (legal : NativeDomain
      ⟨text, completionContextOf calls state, completionDispatch calls text info item state, info, {}, {}⟩)
    (closed : ClosedFunctionContext (completionContextOf calls state))
    (kind : item.kind = .function) :
    ∃ value,
      ActualAt text (completionContextOf calls state)
        (fixedAfter text (completionDispatch calls text info item state).scan.position "return" true)
        (completionDispatch calls text info item state).scan.facts (resultFormal item) value
        (functionReturnAfter text (completionContextOf calls state)
          (completionDispatch calls text info item state).scan ⟨0, item.resultKind, item.resultBounds, 0⟩) ∧
      value.Readable false Bindings.emptyShape
        (ArrayBindings.booleanAnalysis (completionContextOf calls state).arrayNames
          (BooleanBindings.analysis (completionContextOf calls state).booleanNames)) ∧
      ScalarFunctions.scalarActual value = true ∧
      ScalarFunctions.checkActuals Bindings.emptyShape (completionContextOf calls state).analysis
        ((completionContextOf calls state).flow (completionDispatch calls text info item state).scan.facts)
        (ArrayBindings.booleanAnalysis (completionContextOf calls state).arrayNames
          (BooleanBindings.analysis (completionContextOf calls state).booleanNames))
        (item.signature info).outputTypes [value] = true ∧
      discharged (actualObligations Bindings.emptyShape (completionContextOf calls state).analysis
        ((completionContextOf calls state).flow (completionDispatch calls text info item state).scan.facts)
        (ArrayBindings.booleanAnalysis (completionContextOf calls state).arrayNames
          (BooleanBindings.analysis (completionContextOf calls state).booleanNames)) item.resultDomain value) = true ∧
      read.returned.writes = PackageBindings.emptyStateSet := by
  obtain ⟨native, same, valid⟩ := legal.context
  change native.model = completionContextOf calls state at same
  have names : Expressions.ValidNames text (completionContextOf calls state).names := by
    rw [← same]
    exact valid.1
  have normal : NamesNormal (completionContextOf calls state).names := by
    rw [closed.noNames]
    exact namesBoundsValid_empty.normal
  obtain ⟨value, original, _, unwritten⟩ := read.function_source take returnAfter legal.text names kind
  have checked := result_reading_checks normal names legal.base legal.arrays
    legal.scan.flow.1 legal.scan.path original
  have shape : (completionContextOf calls state).names.shape = Bindings.emptyShape := by
    rw [closed.noNames]
    exact empty_names_shape
  rw [closed.noArguments, shape] at checked
  refine ⟨value, original, checked.1, actual_source_scalar closed original, ?_, checked.2.2, unwritten⟩
  simpa only [PackageBindings.Routine.signature, kind, RoutineSignature.outputTypes,
    ScalarFunctions.checkActuals, Bool.and_true] using checked.2.1


open ApplicationPackageDeclarations ApplicationPackageObjectRows ApplicationPackageFormalStorage
open ApplicationPackageFrameLayout ApplicationPackageFrames

/-- The native hiding pass may delete outer declarations only. A returning
pass retains every field of each same-scope row. -/
theorem hideEntries_nonouter {α : Type} {selected outer : α → Bool}
    {before after : List α} (run : hideEntries selected outer before = some after)
    {row : α} (member : row ∈ before) (localRow : outer row = false) : row ∈ after := by
  induction before generalizing after with
  | nil => contradiction
  | cons head tail ih =>
      simp only [hideEntries] at run
      split at run
      · split at run
        · rename_i isOuter
          rcases List.mem_cons.mp member with rfl | later
          · simp only [localRow, Bool.false_eq_true] at isOuter
          · exact ih run later
        · contradiction
      · obtain ⟨rest, remaining, same⟩ := Option.map_eq_some_iff.mp run
        subst after
        rcases List.mem_cons.mp member with rfl | later
        · exact List.mem_cons_self ..
        · exact List.mem_cons_of_mem _ (ih remaining later)

theorem hideOuter_nonouter {text : Source} {frame : ParserState}
    {info : Metadata} {name : PackageBindings.NameSpan}
    (present : (hideOuter text frame info name).position ≠ 0) :
    (∀ row ∈ frame.scalarNames,
      ApplicationPackageNames.outerDeclaration info ⟨row.first,row.after⟩ = false →
      row ∈ (hideOuter text frame info name).scalarNames) ∧
    (∀ row ∈ frame.booleanNames,
      ApplicationPackageNames.outerDeclaration info ⟨row.first,row.after⟩ = false →
      row ∈ (hideOuter text frame info name).booleanNames) := by
  unfold hideOuter at present ⊢
  split at present
  · exact False.elim (present rfl)
  · rename_i allowed
    rw [ite_eq_right allowed]
    cases ints : hideEntries (scalarMatches text name)
      (fun row => ApplicationPackageNames.outerDeclaration info ⟨row.first,row.after⟩) frame.scalarNames with
    | none => simp only [ints] at present; exact False.elim (present rfl)
    | some integers =>
      cases flags : hideEntries (booleanMatches text name)
        (fun row => ApplicationPackageNames.outerDeclaration info ⟨row.first,row.after⟩) frame.booleanNames with
      | none => simp only [ints, flags] at present; exact False.elim (present rfl)
      | some booleans =>
        cases subtypes : hideEntries (subtypeMatches text name)
          (fun row => ApplicationPackageNames.outerDeclaration info ⟨row.first,row.after⟩) frame.subtypeNames.items with
        | none => simp only [ints, flags, subtypes] at present; exact False.elim (present rfl)
        | some types =>
          simp only [ints, flags, subtypes, Option.bind_some, pure, bind] at present ⊢
          split at present
          · rename_i valid
            rw [ite_eq_left valid]
            exact ⟨fun _ member localRow => hideEntries_nonouter ints member localRow,
              fun _ member localRow => hideEntries_nonouter flags member localRow⟩
          · exact False.elim (present rfl)

private theorem typed_live {calls : ObjectCalls} {text : Source} {original : ParserState}
    {info : Metadata} {first last colonEnd constantEnd : Nat} {localObject : Bool}
    {seed : ObjectResult}
    (accepted : (objectTyped calls text original info first last colonEnd constantEnd localObject seed).frame.position ≠ 0) :
    seed.frame.position ≠ 0 := by
  intro missing
  apply accepted
  unfold objectTyped
  rw [ite_eq_left (by simp only [missing, decide_true])]
  rfl

private theorem object_base_present {reader : BooleanElaboration.Native.Reader}
    {text : Source} {frame : ParserState} {info : Metadata}
    (accepted : (objectStep (modelObjectCalls reader) text frame info true).frame.position ≠ 0) :
    (hideOuter text frame info (objectName text frame)).position ≠ 0 := by
  dsimp only [objectStep, objectNameStep] at accepted
  split at accepted
  · exact False.elim (accepted rfl)
  · exact typed_live accepted

/-- Original formal rows, including their complete scalar domains. This
relation records table storage only; it contains no result-checking premise. -/
def FormalPresent (frame : ParserState) (formal : PackageBindings.Formal) : Prop :=
  (∀ row, scalar formal = some row → row ∈ frame.scalarNames) ∧
    (∀ row, flag formal = some row → row ∈ frame.booleanNames)

theorem stored_formal_present {before after : ParserState} {formals : List PackageBindings.Formal}
    (stored : Stored before after formals) {formal : PackageBindings.Formal}
    (member : formal ∈ formals) : FormalPresent after formal := by
  constructor
  · intro row selected
    rw [stored.integers]
    exact List.mem_append_right _ (List.mem_filterMap.mpr ⟨formal, member, selected⟩)
  · intro row selected
    rw [stored.flags]
    exact List.mem_append_right _ (List.mem_filterMap.mpr ⟨formal, member, selected⟩)

theorem FormalPresent.stored {before after : ParserState} {formals : List PackageBindings.Formal}
    {formal : PackageBindings.Formal} (prior : FormalPresent before formal)
    (stored : Stored before after formals) : FormalPresent after formal := by
  constructor
  · intro row selected
    rw [stored.integers]
    exact List.mem_append_left _ (prior.1 row selected)
  · intro row selected
    rw [stored.flags]
    exact List.mem_append_left _ (prior.2 row selected)

theorem FormalPresent.after_object {reader : BooleanElaboration.Native.Reader}
    {text : Source} {frame : ParserState} {info : Metadata} {out : ObjectResult}
    {formal : PackageBindings.Formal} (prior : FormalPresent frame formal)
    (localFormal : ApplicationPackageNames.outerDeclaration info formal.bodyName = false)
    (parsed : objectStep (modelObjectCalls reader) text frame info true = out)
    (present : out.frame.position ≠ 0) : FormalPresent out.frame formal := by
  have live := parsed ▸ present
  have retained := hideOuter_nonouter (object_base_present live)
  obtain ⟨_, storage⟩ := objectStep_rows reader text frame info true live
  rw [parsed] at storage
  have kept : FormalPresent (initializerBase text frame info (objectName text frame) true) formal := by
    constructor
    · intro row selected
      have original := prior.1 row selected
      unfold scalar at selected
      split at selected
      · cases selected
        exact retained.1 _ original localFormal
      · contradiction
    · intro row selected
      have original := prior.2 row selected
      unfold flag at selected
      split at selected
      · cases selected
        exact retained.2 _ original localFormal
      · contradiction
  cases kind : out.mark.kind with
  | integer =>
    obtain ⟨_, installed, same⟩ := storage.integerStorage kind
    exact ⟨fun row selected => installed ▸ List.mem_append_left _ (kept.1 row selected),
      fun row selected => same ▸ kept.2 row selected⟩
  | boolean =>
    obtain ⟨_, installed, same⟩ := storage.booleanStorage kind
    exact ⟨fun row selected => same ▸ kept.1 row selected,
      fun row selected => installed ▸ List.mem_append_left _ (kept.2 row selected)⟩

theorem FormalPresent.local_history {reader : BooleanElaboration.Native.Reader}
    {calls : CompletionCalls} {text : Source} {info : Metadata} {item : Routine}
    {before after : InitializationFrame} {rows : List LocalObject} {formal : PackageBindings.Formal}
    (prior : FormalPresent before.frame formal)
    (localFormal : ApplicationPackageNames.outerDeclaration info formal.bodyName = false)
    (history : LocalObjects calls text info item before rows after)
    (original : ∀ row ∈ rows, calls.objectAt text row.before.frame info true =
      objectStep (modelObjectCalls reader) text row.before.frame info true) :
    FormalPresent after.frame formal := by
  induction history with
  | finished => exact prior
  | @added row final following atBegin apart parsed advanced rest ih =>
      exact ih (prior.after_object localFormal ((original row List.mem_cons_self).symm.trans parsed)
        (by omega)) (fun seen member => original seen (List.mem_cons_of_mem _ member))

theorem FormalPresent.outputs {calls : CompletionCalls} {text : Source} {info : Metadata}
    {indices : List Nat} {before after : InitializationFrame} {formal : PackageBindings.Formal}
    (prior : FormalPresent before.frame formal)
    (read : outputInitializers calls text info indices before = some after) :
    FormalPresent after.frame formal := by
  obtain ⟨position, same⟩ := outputInitializers_sameDeclarations read
  rw [same]
  exact prior

/-- All formal rows are present at the final body frame. Input/in-out rows
survive each successful local hide; out rows come from the original append pass. -/
theorem completion_formals_present {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls}
    {text : Source} {globals : ParserState} {info : Metadata} {result : CompletionResult}
    (frames : CompletionFrames (declarationReaders reader calls) text globals info result)
    (notOuter : ∀ formal ∈ (frames.signature.info.routineAt (info.completed + 1)).formals frames.signature.info,
      ApplicationPackageNames.outerDeclaration frames.signature.info formal.bodyName = false) :
    ∀ formal ∈ (frames.signature.info.routineAt (info.completed + 1)).formals frames.signature.info,
      FormalPresent frames.outputs.completed formal := by
  intro formal member
  have indices : formal ∈ (formalIndices (frames.signature.info.routineAt (info.completed + 1))).map
      frames.signature.info.parameterAt := by
    simpa only [Routine.formals, formalIndices, List.map_map, Function.comp_def] using member
  have chosenMember (output : Bool) (selectedMode : decide (formal.mode = .output) = output) :
      formal ∈ chosen output frames.signature.info (formalIndices (frames.signature.info.routineAt (info.completed + 1))) := by
    obtain ⟨index, active, same⟩ := List.mem_map.mp indices
    exact List.mem_flatMap.mpr ⟨index, active, by simp only [ApplicationPackageFormalStorage.selected, same, selectedMode, ↓reduceIte, List.mem_singleton]⟩
  have outputs := outputs_stored (calls := declarationReaders reader calls) rfl text frames.signature.info _
    frames.outputs.installed
  by_cases output : formal.mode = .output
  · exact stored_formal_present outputs (chosenMember true (by simp only [output, decide_true]))
  · have entered : ApplicationPackageRoutineFrame.routineFrame routineFrameReaders text globals frames.signature.info
        (info.completed + 1) frames.signature.header.position = frames.entry := frames.entered
    obtain ⟨hidden, _, stored⟩ := routineFrame_tables (calls := routineFrameReaders) rfl rfl entered frames.entryPresent
    have initial := stored_formal_present stored (chosenMember false (by simp only [output, decide_false]))
    have localRows := initial.local_history (notOuter formal member) frames.declarations (fun _ _ => rfl)
    have begun : FormalPresent (beginOutputs (declarationReaders reader calls) text frames.locals).frame formal := localRows
    exact (begun.outputs frames.outputs.read).stored outputs

end Silver.ApplicationPackageRoutineResults
