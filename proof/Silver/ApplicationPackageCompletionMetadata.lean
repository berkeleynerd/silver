module

public import Silver.ApplicationPackageCompletionImports

@[expose] public section

namespace Silver.ApplicationPackageCompletion
open Compose Compose.Expressions Predicate ApplicationPackages ApplicationPackageBodies ApplicationPackageDeclarations
open ApplicationPackageFrames ApplicationPackageNames PackageBindings

set_option backward.dsimp.instances true

def InitializationWidth (state : InitializationFrame) : Prop := state.reads.length = maxStates

theorem localStep_width {calls : CompletionCalls} {text : Source} {info : Metadata} {item : Routine}
    {state next : InitializationFrame} (width : InitializationWidth state) :
    (localStep calls text info item state = .continued next ∨ localStep calls text info item state = .finished next) →
      InitializationWidth next := by
  intro step
  unfold localStep at step
  dsimp only at step
  split at step
  · rcases step with impossible | selected
    · contradiction
    · cases selected; exact width
  · split at step
    · rcases step with impossible | impossible <;> contradiction
    · split at step
      · rcases step with impossible | impossible <;> contradiction
      · rcases step with selected | impossible
        · cases selected
          simp only [InitializationWidth, stateUnion, List.length_map, List.length_range]
        · contradiction

theorem locals_width {calls : CompletionCalls} {text : Source} {info : Metadata} {item : Routine}
    {fuel : Nat} {state next : InitializationFrame} (width : InitializationWidth state)
    (parsed : localsFuel (localStep calls text info item) fuel state = some (some next)) :
    InitializationWidth next := by
  induction fuel generalizing state with
  | zero => contradiction
  | succ fuel ih =>
    simp only [localsFuel] at parsed
    cases step : localStep calls text info item state with
    | failed => simp only [step, Option.some.injEq, reduceCtorEq] at parsed
    | finished result =>
      simp only [step, Option.some.injEq] at parsed
      cases parsed
      exact localStep_width width (.inr step)
    | continued result =>
      simp only [step] at parsed
      exact ih (localStep_width width (.inl step)) parsed

theorem outputInitializer_width {calls : CompletionCalls} {text : Source} {info : Metadata} {formal : Formal}
    {state next : InitializationFrame} (width : InitializationWidth state)
    (parsed : outputInitializer calls text info formal state = some next) : InitializationWidth next := by
  unfold outputInitializer at parsed
  dsimp only at parsed
  split at parsed
  · cases parsed; exact width
  · split at parsed
    · contradiction
    · split at parsed
      · contradiction
      · split at parsed
        · contradiction
        · cases parsed
          simp only [InitializationWidth, stateUnion, List.length_map, List.length_range]

theorem outputInitializers_width {calls : CompletionCalls} {text : Source} {info : Metadata} {indices : List Nat}
    {state next : InitializationFrame} (width : InitializationWidth state)
    (parsed : outputInitializers calls text info indices state = some next) : InitializationWidth next := by
  induction indices generalizing state with
  | nil => cases parsed; exact width
  | cons index rest ih =>
    simp only [outputInitializers, Option.bind_eq_some_iff] at parsed
    obtain ⟨middle, first, following⟩ := parsed
    exact ih (outputInitializer_width width first) following

theorem completionFooter_typed (calls : CompletionCalls) (text : Source) (globals : ParserState)
    (info : Metadata) (typed : info.Typed) (index : Nat) (indexBound : index ≤ maxRoutines)
    (item : Routine) (itemTyped : item.Typed) (result : ApplicationScan) (width : result.MaskWidth)
    (bounded : calls.takeToken text
      (calls.nameAfter text (calls.skipAt text (calls.takeToken text result.scan.position (.word "end"))))
        (.symbol ";") ≤ maxSourceLength + 1) :
    (completionFooter calls text globals info index item result).info.Typed := by
  unfold completionFooter
  dsimp only
  split
  · exact typed
  · have updated : ({item with
        bodyAfter := calls.takeToken text
          (calls.nameAfter text (calls.skipAt text (calls.takeToken text result.scan.position (.word "end")))) (.symbol ";")
        mayRead := result.reads, mayWrite := result.writes, assigned := result.scan.assigned} : Routine).Typed := by
      rcases itemTyped with ⟨specName, bodyName, specResult, bodyResult, specFirst, specAfter, bodyFirst, _,
        formalFirst, count, bounds, identity, _, _⟩
      exact ⟨specName, bodyName, specResult, bodyResult, specFirst, specAfter, bodyFirst, bounded,
        formalFirst, count, bounds, identity, width.1, width.2⟩
    have stored := MetadataTypes.set_routine typed (index - 1) _ updated
    rcases stored with ⟨name, bodyName, units, exports, states, routines, _, parameters,
      exportTypes, stateTypes, routineTypes, parameterTypes⟩
    exact ⟨name, bodyName, units, exports, states, routines, indexBound, parameters,
      exportTypes, stateTypes, routineTypes, parameterTypes⟩

theorem completionBody_typed (calls : CompletionCalls) (text : Source) (globals : ParserState)
    (info : Metadata) (typed : info.Typed) (index : Nat) (item : Routine) (state : InitializationFrame)
    (dispatched : calls.validState text state.frame = true → (completionDispatch calls text info item state).MaskWidth)
    (footer : ∀ returned, returned.MaskWidth → (completionFooter calls text globals info index item returned).info.Typed) :
    (completionBody calls text globals info index item state).info.Typed := by
  unfold completionBody
  split
  · rename_i valid
    dsimp only [uncheckedCompletionBody]
    split
    · exact typed
    · cases returned : completionReturn calls text (completionContextOf calls state) info item
          (completionDispatch calls text info item state) with
      | none => exact typed
      | some result => exact footer result (completionReturn_mask_width (dispatched valid) returned)
  · exact typed

theorem completionOutputs_typed (calls : CompletionCalls) (text : Source) (globals : ParserState)
    (info : Metadata) (typed : info.Typed) (index : Nat) (item : Routine) (localFrame : InitializationFrame)
    (body : ∀ initialized completedFrame,
      outputInitializers calls text info (formalIndices item)
        {localFrame with frame := {localFrame.frame with position := calls.takeToken text localFrame.frame.position (.word "begin")}} = some initialized →
      appendOutputs calls text info (formalIndices item) initialized.frame = some completedFrame →
      (completionBody calls text globals info index item {initialized with frame := completedFrame}).info.Typed) :
    (completionOutputs calls text globals info index item localFrame).info.Typed := by
  dsimp only [completionOutputs]
  cases parsed : outputInitializers calls text info (formalIndices item)
      {localFrame with frame := {localFrame.frame with position := calls.takeToken text localFrame.frame.position (.word "begin")}} with
  | none => exact typed
  | some initialized =>
    dsimp only
    cases appended : appendOutputs calls text info (formalIndices item) initialized.frame with
    | none => exact typed
    | some completedFrame => exact body initialized completedFrame parsed appended

theorem completionLocals_typed (calls : CompletionCalls) (fuel : Nat) (text : Source) (globals : ParserState)
    (info : Metadata) (typed : info.Typed) (index : Nat) (item : Routine) (state : InitializationFrame)
    (outputs : ∀ localFrame, localsFuel (localStep calls text info item) fuel state = some (some localFrame) →
      (completionOutputs calls text globals info index item localFrame).info.Typed)
    (result : CompletionResult) (parsed : completionLocals calls fuel text globals info index item state = some result) :
    result.info.Typed := by
  dsimp only [completionLocals] at parsed
  obtain ⟨outcome, localRun, finished⟩ := Option.map_eq_some_iff.mp parsed
  cases outcome with
  | none => cases finished; exact typed
  | some localFrame => cases finished; exact outputs localFrame localRun

theorem packageCompletionFuel_typed (calls : CompletionCalls) (fuel : Nat) (text : Source)
    (globals : ParserState) (info : Metadata) (typed : info.Typed)
    (signatureTyped : (calls.signatureAt text globals info true).info.Typed)
    (locals : info.completed < info.routines.length →
      let signed := calls.signatureAt text globals info true
      let index := info.completed + 1
      let item := signed.info.routineAt index
      let frame := calls.routineFrame text globals signed.info index signed.header.position
      ∀ result, completionLocals calls fuel text globals signed.info index item {frame} = some result → result.info.Typed)
    (result : CompletionResult) (parsed : packageCompletionFuel calls fuel text globals info = some result) :
    result.info.Typed := by
  dsimp only [packageCompletionFuel] at parsed
  split at parsed
  · cases parsed; exact typed
  · rename_i unfinished
    split at parsed
    · cases parsed; exact signatureTyped
    · split at parsed
      · cases parsed; exact signatureTyped
      · split at parsed
        · cases parsed; exact signatureTyped
        · exact locals (Nat.lt_of_not_ge unfinished) result parsed

namespace Library

theorem dispatch_width (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (info : Metadata) (typed : info.Typed)
    (item : Routine) (state : InitializationFrame) (framed : ReaderFrame text state.frame)
    (width : InitializationWidth state) :
    (completionDispatch (library.model reader) text info item state).MaskWidth := by
  have inputWidth : (completionInput (library.model reader) item state).MaskWidth :=
    ⟨width, by simp only [completionInput, emptyStateSet, List.length_replicate]⟩
  exact (library.recursive.mask_widths
    (body_source_domain reader (LeafLibraries.model (library.calls reader)) valid info item state framed)
    typed inputWidth).2 _ _

theorem footer_typed (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (globals : ParserState) (info : Metadata) (typed : info.Typed)
    (index : Nat) (indexBound : index ≤ maxRoutines) (item : Routine) (itemTyped : item.Typed)
    (result : ApplicationScan) (width : result.MaskWidth) :
    (completionFooter (library.model reader) text globals info index item result).info.Typed := by
  apply completionFooter_typed _ _ _ _ typed index indexBound item itemTyped result width
  exact Nat.le_trans (fixedAfter_result_bound text _ ";" false (by decide)) (Nat.add_le_add_right valid.2 1)

theorem body_typed (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (globals : ParserState) (info : Metadata) (typed : info.Typed)
    (index : Nat) (indexBound : index ≤ maxRoutines) (item : Routine) (itemTyped : item.Typed)
    (state : InitializationFrame) (prior : OutputFrame state.frame) (width : InitializationWidth state) :
    (completionBody (library.model reader) text globals info index item state).info.Typed :=
  completionBody_typed _ _ _ _ typed index item state
    (fun accepted => library.dispatch_width reader valid info typed item state (prior.checked accepted) width)
    (fun returned resultWidth => library.footer_typed reader valid globals info typed index indexBound item itemTyped returned resultWidth)

theorem outputs_typed (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (globals : ParserState) (info : Metadata) (typed : info.Typed)
    (index : Nat) (indexBound : index ≤ maxRoutines) (item : Routine) (itemTyped : item.Typed)
    (localFrame : InitializationFrame) (framed : ReaderFrame text localFrame.frame) (width : InitializationWidth localFrame) :
    (completionOutputs (library.model reader) text globals info index item localFrame).info.Typed := by
  have entered : ReaderFrame text {localFrame.frame with position := tokenAfter text localFrame.frame.position (.word "begin")} :=
    framed.at_position (fixedAfter_result_bound text _ "begin" true (by decide))
  apply completionOutputs_typed _ _ _ _ typed
  intro initialized completedFrame parsed appended
  have ready := output_initializers_frame reader (LeafLibraries.model (library.calls reader)) info _ _ initialized entered parsed
  have complete := append_outputs_frame reader (LeafLibraries.model (library.calls reader)) text info
    (ApplicationPackageRoutineFrame.parameterBounds_of_typed typed) _ initialized.frame completedFrame
    (OutputFrame.of_reader valid ready) appended
  have initializedWidth := outputInitializers_width (state := {localFrame with frame :=
    {localFrame.frame with position := tokenAfter text localFrame.frame.position (.word "begin")}}) width parsed
  exact library.body_typed reader valid globals info typed index indexBound item itemTyped _ complete initializedWidth

theorem locals_typed (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (globals : ParserState) (info : Metadata) (typed : info.Typed)
    (index : Nat) (indexBound : index ≤ maxRoutines) (item : Routine) (itemTyped : item.Typed)
    (fuel : Nat) (state : InitializationFrame) (framed : ReaderFrame text state.frame) (width : InitializationWidth state)
    (result : CompletionResult)
    (parsed : completionLocals (library.model reader) fuel text globals info index item state = some result) : result.info.Typed := by
  apply completionLocals_typed _ _ _ _ _ typed index item state ?_ result parsed
  intro localFrame localRun
  have ready := locals_frame reader (LeafLibraries.model (library.calls reader)) valid info item fuel state localFrame framed localRun
  exact library.outputs_typed reader valid globals info typed index indexBound item itemTyped localFrame ready (locals_width width localRun)

/-- Every native metadata subtype survives a complete Completion, including
all partial failure metadata. Completed effect arrays come from the original
recursive reader and initializer folds, not an assumed metadata-validity fact. -/
theorem completion_model_typed (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (globals : ParserState) (framed : ReaderFrame text globals)
    (info : Metadata) (typed : info.Typed) (fuel : Nat) (result : CompletionResult)
    (parsed : packageCompletionFuel (library.model reader) fuel text globals info = some result) : result.info.Typed := by
  have signed := readSignature_completion_typed valid globals framed info typed
  apply packageCompletionFuel_typed _ _ _ _ _ typed signed ?_ result parsed
  intro unfinished
  dsimp only
  intro returned locals
  have routineBound : info.routines.length ≤ maxRoutines := typed.2.2.2.2.2.1
  have indexBound : info.completed + 1 ≤ maxRoutines := by omega
  exact library.locals_typed reader valid globals _ signed _ indexBound _ (MetadataTypes.routine_at signed _)
    fuel _ (entry_reader reader (LeafLibraries.model (library.calls reader)) valid globals framed info typed)
    (by simp only [InitializationWidth, emptyStateSet, List.length_replicate]) returned locals

theorem completion_imported_typed (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (globals : ParserState) (framed : ReaderFrame text globals)
    (info : Metadata) (typed : info.Typed) (fuel : Nat) (result : CompletionResult)
    (parsed : packageCompletionFuel (library.calls reader) fuel text globals info = some result) : result.info.Typed := by
  rw [library.completion_fuel reader valid globals framed info typed] at parsed
  exact library.completion_model_typed reader valid globals framed info typed fuel result parsed

theorem completion_read_typed (library : Library) (reader : BooleanElaboration.Native.Reader)
    {text : Source} (valid : ValidText text) (globals : ParserState) (framed : ReaderFrame text globals)
    (info : Metadata) (typed : info.Typed) :
    (readCompletion reader (LeafLibraries.model (library.calls reader)) text globals info).info.Typed :=
  library.completion_model_typed reader valid globals framed info typed _ _
    (readCompletion_eq reader (LeafLibraries.model (library.calls reader)) text globals info)

end Library
end Silver.ApplicationPackageCompletion
