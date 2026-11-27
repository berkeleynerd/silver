module

public import Silver.ApplicationPackageObjectRows
public import Silver.ApplicationPackageDeclarationsSpecificationModel
public import Silver.ApplicationPackageRoutineFrame
public import Silver.ApplicationPackageUnitObjectHistory
public import Silver.ApplicationPackageCompletionLocalHistory

@[expose] public section

/-! Package specification and routine declarations cannot introduce string or
array objects, or a dynamic string parameter. These facts follow from the
original readers and declaration histories. Routine entry sets Pure; arbitrary
caller frames are not assumed to have the resulting closed initializer shape. -/
namespace Silver.ApplicationPackageRoutineClosedFrames
open Compose ApplicationPackageDeclarations ApplicationPackageBodies

structure Tables (frame : ParserState) : Prop where
  dynamicFirst : frame.dynamicFirst = 0
  names : frame.names = []
  arrayNames : frame.arrayNames.names = []

structure Closed (frame : ParserState) : Prop extends Tables frame where
  pure : frame.pure = true

/-- The four initializer-relevant fields retained by a successful reader. -/
def Retains (before after : ParserState) : Prop :=
  after.pure = before.pure ∧ after.dynamicFirst = before.dynamicFirst ∧
    after.names = before.names ∧ after.arrayNames.names = before.arrayNames.names

theorem Retains.refl (frame : ParserState) : Retains frame frame := ⟨rfl, rfl, rfl, rfl⟩

theorem Retains.trans {before middle after : ParserState}
    (first : Retains before middle) (last : Retains middle after) : Retains before after :=
  ⟨last.1.trans first.1, last.2.1.trans first.2.1,
    last.2.2.1.trans first.2.2.1, last.2.2.2.trans first.2.2.2⟩

theorem Retains.tables {before after : ParserState} (kept : Retains before after)
    (initial : Tables before) : Tables after :=
  ⟨kept.2.1.trans initial.dynamicFirst, kept.2.2.1.trans initial.names,
    kept.2.2.2.trans initial.arrayNames⟩

theorem Retains.closed {before after : ParserState} (kept : Retains before after)
    (initial : Closed before) : Closed after :=
  ⟨kept.tables initial.toTables, kept.1.trans initial.pure⟩

theorem initial_tables : Tables initialState := ⟨rfl, rfl, rfl⟩

theorem invalid_tables : Tables invalidState := ⟨rfl, rfl, rfl⟩

theorem hideOuter_retains {text : Source} {frame : ParserState} {info : PackageBindings.Metadata}
    {name : PackageBindings.NameSpan}
    (present : (ApplicationPackageFrames.hideOuter text frame info name).position ≠ 0) :
    Retains frame (ApplicationPackageFrames.hideOuter text frame info name) := by
  unfold ApplicationPackageFrames.hideOuter at present ⊢
  split at present
  · exact False.elim (present rfl)
  · rename_i allowed
    rw [ite_eq_right allowed]
    cases scalars : ApplicationPackageFrames.hideEntries
      (ApplicationPackageFrames.scalarMatches text name)
      (fun item => ApplicationPackageNames.outerDeclaration info ⟨item.first, item.after⟩) frame.scalarNames with
    | none => simp [scalars, invalidState] at present
    | some scalarRows =>
      cases booleans : ApplicationPackageFrames.hideEntries
        (ApplicationPackageFrames.booleanMatches text name)
        (fun item => ApplicationPackageNames.outerDeclaration info ⟨item.first, item.after⟩) frame.booleanNames with
      | none => simp [scalars, booleans, invalidState] at present
      | some booleanRows =>
        cases subtypes : ApplicationPackageFrames.hideEntries
          (ApplicationPackageFrames.subtypeMatches text name)
          (fun item => ApplicationPackageNames.outerDeclaration info ⟨item.first, item.after⟩) frame.subtypeNames.items with
        | none => simp [scalars, booleans, subtypes, invalidState] at present
        | some subtypeRows =>
          simp only [scalars, booleans, subtypes, Option.bind_some, pure, bind] at present ⊢
          split at present
          · rename_i valid
            rw [ite_eq_left valid]
            exact ⟨rfl, rfl, rfl, rfl⟩
          · exact False.elim (present rfl)

theorem appendFormal_retains (frame : ParserState) (name : PackageBindings.NameSpan)
    (mark : ApplicationPackageNames.PackageTypeResult) (mode : ProcedureBindings.Mode) :
    Retains frame (appendFormal frame name mark mode) := by
  unfold appendFormal
  split <;> (try split) <;> exact ⟨rfl, rfl, rfl, rfl⟩

private theorem finish_retains {calls : ObjectCalls} {text : Source} {original : ParserState}
    {result : ObjectResult}
    (present : (finishObject calls text original result).frame.position ≠ 0) :
    Retains result.frame (finishObject calls text original result).frame := by
  dsimp only [finishObject] at present ⊢
  split at present
  · exact False.elim (present rfl)
  · rename_i advanced
    rw [ite_eq_right advanced]
    exact ⟨rfl, rfl, rfl, rfl⟩

private theorem booleanFinish_retains {calls : ObjectCalls} {text : Source} {original : ParserState}
    {first last constantEnd after : Nat} {localObject : Bool} {result : ObjectResult}
    (present : (objectBooleanFinish calls text original first last constantEnd after localObject result).frame.position ≠ 0) :
    Retains result.frame
      (objectBooleanFinish calls text original first last constantEnd after localObject result).frame :=
  finish_retains present

private theorem boolean_retains {calls : ObjectCalls} {text : Source} {original : ParserState}
    {first last constantEnd : Nat} {localObject : Bool} {result : ObjectResult}
    (present : (objectBoolean calls text original first last constantEnd localObject result).frame.position ≠ 0) :
    Retains result.frame (objectBoolean calls text original first last constantEnd localObject result).frame := by
  dsimp only [objectBoolean] at present ⊢
  split at present
  · exact False.elim (present rfl)
  · rename_i checked
    rw [ite_eq_right checked]
    split at present
    · rename_i global
      rw [ite_eq_left global]
      split at present
      · exact False.elim (present rfl)
      · rename_i same
        rw [ite_eq_right same]
        exact booleanFinish_retains present
    · rename_i localBranch
      rw [ite_eq_right localBranch]
      exact booleanFinish_retains present

private theorem scalar_retains {calls : ObjectCalls} {text : Source} {original : ParserState}
    {first last constantEnd : Nat} {localObject : Bool} {result : ObjectResult} {constraint : ScalarConstraintResult}
    (present : (objectScalar calls text original first last constantEnd localObject result constraint).frame.position ≠ 0) :
    Retains result.frame (objectScalar calls text original first last constantEnd localObject result constraint).frame := by
  dsimp only [objectScalar] at present ⊢
  split at present
  · exact False.elim (present rfl)
  · rename_i checked
    rw [ite_eq_right checked]
    exact finish_retains present

private theorem initialized_retains {calls : ObjectCalls} {text : Source} {original : ParserState}
    {first last constantEnd : Nat} {localObject : Bool} {result : ObjectResult} {constraint : ScalarConstraintResult}
    (present : (objectInitialized calls text original first last constantEnd localObject result constraint).frame.position ≠ 0) :
    Retains result.frame (objectInitialized calls text original first last constantEnd localObject result constraint).frame := by
  dsimp only [objectInitialized] at present ⊢
  split at present
  · exact False.elim (present rfl)
  · rename_i checked
    rw [ite_eq_right checked]
    split at present
    · rename_i integer
      rw [ite_eq_left integer]
      exact scalar_retains present
    · rename_i boolean
      rw [ite_eq_right boolean]
      exact boolean_retains present

private theorem typed_retains {calls : ObjectCalls} {text : Source} {original : ParserState}
    {info : PackageBindings.Metadata} {first last colonEnd constantEnd : Nat} {localObject : Bool}
    {result : ObjectResult}
    (present : (objectTyped calls text original info first last colonEnd constantEnd localObject result).frame.position ≠ 0) :
    result.frame.position ≠ 0 ∧ Retains result.frame
      (objectTyped calls text original info first last colonEnd constantEnd localObject result).frame := by
  dsimp only [objectTyped] at present ⊢
  split at present
  · exact False.elim (present rfl)
  · rename_i live
    rw [ite_eq_right live]
    refine ⟨by simpa only [decide_eq_true_eq] using live, ?_⟩
    by_cases constant : constantEnd = 0 <;>
      simp only [constant, decide_true, decide_false, Bool.false_eq_true, ↓reduceIte] at present ⊢
    all_goals
      split at present
      · exact False.elim (present rfl)
      · rename_i typed
        rw [ite_eq_right typed]
        split at present
        · rename_i integer
          rw [ite_eq_left integer]
          exact initialized_retains present
        · rename_i boolean
          rw [ite_eq_right boolean]
          exact initialized_retains present


/-- Includes every successful scalar/Boolean branch and arbitrary imported
value readers. Only Hide_Outer's original equation is needed for these fields. -/
theorem objectStep_retains {calls : ObjectCalls}
    (hide : calls.hideOuter = ApplicationPackageFrames.hideOuter)
    {text : Source} {frame : ParserState} {info : PackageBindings.Metadata} {localObject : Bool}
    (present : (objectStep calls text frame info localObject).frame.position ≠ 0) :
    Retains frame (objectStep calls text frame info localObject).frame := by
  dsimp only [objectStep, objectNameStep] at present ⊢
  split at present
  · exact False.elim (present rfl)
  · rename_i named
    rw [ite_eq_right named]
    split at present
    · rename_i localBranch
      rw [ite_eq_left localBranch]
      have retained := typed_retains present
      have kept : Retains frame (calls.hideOuter text frame info
          ⟨calls.skip text frame.position, calls.nameAfter text (calls.skip text frame.position)⟩) := by
        rw [hide]
        exact hideOuter_retains (hide ▸ retained.1)
      exact kept.trans retained.2
    · rename_i global
      rw [ite_eq_right global]
      split at present
      · rename_i fresh
        rw [ite_eq_left fresh]
        exact (typed_retains present).2
      · exact False.elim (present rfl)

theorem initializerBase_retains {reader : BooleanElaboration.Native.Reader} {text : Source}
    {frame : ParserState} {info : PackageBindings.Metadata} {localObject : Bool}
    (present : (objectStep (modelObjectCalls reader) text frame info localObject).frame.position ≠ 0) :
    Retains frame (ApplicationPackageObjectRows.initializerBase text frame info
      (ApplicationPackageObjectRows.objectName text frame) localObject) := by
  cases localObject with
  | false => exact ⟨rfl, rfl, rfl, rfl⟩
  | true =>
    apply hideOuter_retains
    dsimp only [objectStep, objectNameStep] at present
    split at present
    · exact False.elim (present rfl)
    · exact (typed_retains present).1

theorem initializerBase_closed {reader : BooleanElaboration.Native.Reader} {text : Source}
    {frame : ParserState} {info : PackageBindings.Metadata} {localObject : Bool}
    (initial : Closed frame)
    (present : (objectStep (modelObjectCalls reader) text frame info localObject).frame.position ≠ 0) :
    Closed (ApplicationPackageObjectRows.initializerBase text frame info
      (ApplicationPackageObjectRows.objectName text frame) localObject) :=
  (initializerBase_retains present).closed initial

theorem subtype_retains {text : Source} {frame : ParserState} {arguments : Bool}
    (present : (subtypeDeclarationAt text frame arguments).position ≠ 0) :
    Retains frame (subtypeDeclarationAt text frame arguments) := by
  dsimp only [subtypeDeclarationAt] at present ⊢
  split at present
  · exact False.elim (present rfl)
  · rename_i valid
    rw [ite_eq_right valid]
    exact ⟨rfl, rfl, rfl, rfl⟩

private def SpecificationStepTables : SpecificationStep → Prop
  | .returned result => Tables result.exports
  | .ready state | .next state => Tables state.exports

private theorem continueSpecification_tables (calls : SpecificationCalls) (text : Source)
    (before : Nat) (state : SpecificationState) (initial : Tables state.exports) :
    SpecificationStepTables (continueSpecification calls text before state) := by
  dsimp only [continueSpecification]
  split
  · exact invalid_tables
  · exact initial

private theorem appendExport_tables (calls : SpecificationCalls) (text : Source)
    (state : SpecificationState) (next : ParserState) (item : PackageBindings.ExportDeclaration)
    (initial : Tables next) : SpecificationStepTables (appendExport calls text state next item) :=
  continueSpecification_tables _ _ _ _ initial

private theorem specificationRoutine_tables (calls : SpecificationCalls) (text : Source)
    (state : SpecificationState) (initial : Tables state.exports) :
    SpecificationStepTables (specificationRoutine calls text state) := by
  dsimp only [specificationRoutine]
  split
  · exact invalid_tables
  · apply continueSpecification_tables
    exact ⟨initial.dynamicFirst, initial.names, initial.arrayNames⟩

private theorem specificationSubtype_tables {calls : SpecificationCalls}
    (original : calls.subtype = subtypeDeclarationAt) (text : Source)
    (state : SpecificationState) (initial : Tables state.exports) :
    SpecificationStepTables (specificationSubtype calls text state) := by
  dsimp only [specificationSubtype]
  split
  · exact invalid_tables
  · rename_i live
    split
    · exact invalid_tables
    · apply appendExport_tables
      rw [original] at live ⊢
      exact (subtype_retains live).tables initial

private theorem specificationObject_tables {calls : SpecificationCalls} {reader : BooleanElaboration.Native.Reader}
    (original : calls.object = fun text frame info localObject => objectStep (modelObjectCalls reader) text frame info localObject) (text : Source)
    (state : SpecificationState) (initial : Tables state.exports) :
    SpecificationStepTables (specificationObject calls text state) := by
  dsimp only [specificationObject]
  split
  · exact invalid_tables
  · rename_i accepted
    apply appendExport_tables
    have live : (calls.object text state.exports state.info false).frame.position ≠ 0 := by
      intro failed
      apply accepted
      simp only [failed, decide_true, Bool.true_or]
    rw [original] at live ⊢
    exact (objectStep_retains rfl live).tables initial

private theorem specificationStep_tables {calls : SpecificationCalls} {reader : BooleanElaboration.Native.Reader}
    (subtype : calls.subtype = subtypeDeclarationAt)
    (object : calls.object = fun text frame info localObject => objectStep (modelObjectCalls reader) text frame info localObject) (text : Source)
    (state : SpecificationState) (initial : Tables state.exports) :
    SpecificationStepTables (specificationStep calls text state) := by
  dsimp only [specificationStep]
  split
  · exact initial
  · split
    · exact specificationRoutine_tables _ _ _ initial
    · split
      · exact invalid_tables
      · split
        · exact specificationSubtype_tables subtype _ _ initial
        · exact specificationObject_tables object _ _ initial

private def SpecificationExitTables : SpecificationExit → Prop
  | .returned result => Tables result.exports
  | .ready state => Tables state.exports

private theorem specificationLoop_tables {calls : SpecificationCalls} {reader : BooleanElaboration.Native.Reader}
    (subtype : calls.subtype = subtypeDeclarationAt)
    (object : calls.object = fun text frame info localObject => objectStep (modelObjectCalls reader) text frame info localObject) {text : Source}
    {state : SpecificationState} {result : SpecificationExit}
    (run : SpecificationLoop calls text state result) (initial : Tables state.exports) :
    SpecificationExitTables result := by
  induction run with
  | returned step =>
    have kept := specificationStep_tables subtype object text _ initial
    rw [step] at kept
    exact kept
  | ready step =>
    have kept := specificationStep_tables subtype object text _ initial
    rw [step] at kept
    exact kept
  | next step _ ih =>
    apply ih
    have kept := specificationStep_tables subtype object text _ initial
    rw [step] at kept
    exact kept

private theorem finishSpecification_tables (calls : SpecificationCalls) (text : Source)
    (state : SpecificationState) (initial : Tables state.exports) :
    Tables (finishSpecification calls text state).exports := by
  dsimp only [finishSpecification]
  split
  · exact invalid_tables
  · exact ⟨initial.dynamicFirst, initial.names, initial.arrayNames⟩

/-- The seed and every original specification branch establish the empty
tables. No invariant on the incoming metadata or successful parse is assumed. -/
theorem specification_tables {calls : SpecificationCalls} {reader : BooleanElaboration.Native.Reader}
    (subtype : calls.subtype = subtypeDeclarationAt)
    (object : calls.object = fun text frame info localObject => objectStep (modelObjectCalls reader) text frame info localObject) {text : Source}
    {info : PackageBindings.Metadata} {result : SpecificationResult}
    (run : SpecificationExec calls text info result) : Tables result.exports := by
  have seed : match specificationStart calls text info with
      | .returned result => Tables result.exports
      | .loop state => Tables state.exports := by
    dsimp only [specificationStart]
    by_cases named : (!calls.allowed text
      ⟨calls.skip text (calls.word text 1 "package"),
        calls.nameAfter text (calls.skip text (calls.word text 1 "package"))⟩) = true
    · rw [ite_eq_left named]
      exact invalid_tables
    · rw [ite_eq_right named]
      by_cases absent : calls.pragmaAfter text
        (calls.take text (calls.nameAfter text (calls.skip text (calls.word text 1 "package"))) (.word "is")) = 0
      · rw [ite_eq_left absent]
        exact ⟨rfl, rfl, rfl⟩
      · rw [ite_eq_right absent]
        exact ⟨rfl, rfl, rfl⟩
  unfold SpecificationExec at run
  cases start : specificationStart calls text info with
  | returned failed =>
    simp only [start] at run seed
    cases run
    exact seed
  | loop state =>
    simp only [start] at run seed
    obtain ⟨exit, history, rfl⟩ := run
    have kept := specificationLoop_tables subtype object history seed
    cases exit with
    | returned failed => exact kept
    | ready finalState => exact finishSpecification_tables _ _ _ kept

theorem unitStart_tables {calls : UnitCalls} {text : Source} {exports : ParserState}
    {info : PackageBindings.Metadata} {state : UnitState} (initial : Tables exports)
    (started : startUnit calls text exports info = .continued state) : Tables state.globals := by
  dsimp only [startUnit] at started
  split at started
  · contradiction
  · split at started
    · contradiction
    · cases started
      exact ⟨initial.dynamicFirst, initial.names, initial.arrayNames⟩

theorem stateHistory_tables {reader : BooleanElaboration.Native.Reader} {calls : UnitCalls} {text : Source}
    {before after : UnitState} {rows : List StateObject}
    (history : StateObjects calls text before rows after)
    (original : ∀ row ∈ rows, calls.objectAt text row.before.globals row.before.info false =
      objectStep (modelObjectCalls reader) text row.before.globals row.before.info false)
    (initial : Tables before.globals) : Tables after.globals := by
  induction history with
  | finished => exact initial
  | @added row following final phase chosen capacity parsed advanced writable rest ih =>
    apply ih (fun seen member => original seen (List.mem_cons_of_mem _ member))
    have equation := (original row List.mem_cons_self).symm.trans parsed
    have kept : Retains row.before.globals row.object.frame := by
      rw [← equation]
      exact objectStep_retains rfl (by rw [equation]; omega)
    exact kept.tables initial

theorem entry_closed (calls : ApplicationPackageRoutineFrame.Calls) (globals : ParserState)
    (position : Nat) (initial : Tables globals) :
    Closed (ApplicationPackageRoutineFrame.entryFrame calls globals position) :=
  ⟨⟨initial.dynamicFirst, initial.names, initial.arrayNames⟩, rfl⟩

theorem hideParameter_retains {calls : ApplicationPackageRoutineFrame.Calls}
    (original : calls.hideOuter = ApplicationPackageFrames.hideOuter)
    {text : Source} {info : PackageBindings.Metadata} {before after : ParserState} {index : Nat}
    (run : ApplicationPackageRoutineFrame.hideParameter calls text info before index = some after) :
    Retains before after := by
  dsimp only [ApplicationPackageRoutineFrame.hideParameter] at run
  split at run
  · contradiction
  · split at run
    · contradiction
    · rename_i live
      cases run
      rw [original] at live ⊢
      exact hideOuter_retains live

theorem appendParameter_retains {calls : ApplicationPackageRoutineFrame.Calls}
    (original : calls.appendFormal = appendFormal)
    {info : PackageBindings.Metadata} {before after : ParserState} {index : Nat}
    (run : ApplicationPackageRoutineFrame.appendParameter calls info before index = some after) :
    Retains before after := by
  dsimp only [ApplicationPackageRoutineFrame.appendParameter] at run
  split at run
  · cases run; exact .refl _
  · split at run
    · contradiction
    · cases run
      rw [original]
      exact appendFormal_retains _ _ _ _

theorem parameters_retains {step : ParserState → Nat → Option ParserState}
    (original : ∀ before index after, step before index = some after → Retains before after)
    {indices : List Nat} {before after : ParserState}
    (run : ApplicationPackageRoutineFrame.parameters step indices before = some after) : Retains before after := by
  induction indices generalizing before with
  | nil => cases run; exact .refl _
  | cons index rest ih =>
    obtain ⟨middle, first, last⟩ := Option.bind_eq_some_iff.mp run
    exact (original _ _ _ first).trans (ih last)

theorem routineFrame_closed {calls : ApplicationPackageRoutineFrame.Calls}
    (hide : calls.hideOuter = ApplicationPackageFrames.hideOuter)
    (formal : calls.appendFormal = appendFormal) {text : Source} {globals : ParserState}
    {info : PackageBindings.Metadata} {routine position : Nat} (initial : Tables globals)
    (present : (ApplicationPackageRoutineFrame.routineFrame calls text globals info routine position).position ≠ 0) :
    Closed (ApplicationPackageRoutineFrame.routineFrame calls text globals info routine position) := by
  dsimp only [ApplicationPackageRoutineFrame.routineFrame, ApplicationPackageRoutineFrame.withItem] at present ⊢
  split at present
  · exact False.elim (present rfl)
  · rename_i active
    rw [ite_eq_right active]
    split at present
    · exact False.elim (present rfl)
    · rename_i valid
      rw [ite_eq_right valid]
      cases hidden : ApplicationPackageRoutineFrame.parameters
        (ApplicationPackageRoutineFrame.hideParameter calls text info)
        (formalIndices (info.routineAt routine))
        (ApplicationPackageRoutineFrame.entryFrame calls globals position) with
      | none => simp only [hidden] at present; exact False.elim (present rfl)
      | some hiddenFrame =>
        simp only [hidden] at present ⊢
        cases appended : ApplicationPackageRoutineFrame.parameters
          (ApplicationPackageRoutineFrame.appendParameter calls info)
          (formalIndices (info.routineAt routine)) hiddenFrame with
        | none => simp only [appended] at present; exact False.elim (present rfl)
        | some finalFrame =>
          simp only [appended] at present ⊢
          split at present
          · rename_i accepted
            rw [ite_eq_left accepted]
            have first := parameters_retains (fun _ _ _ run => hideParameter_retains hide run) hidden
            have last := parameters_retains (fun _ _ _ run => appendParameter_retains formal run) appended
            exact (first.trans last).closed (entry_closed calls globals position initial)
          · exact False.elim (present rfl)

theorem localHistory_closed {reader : BooleanElaboration.Native.Reader} {calls : CompletionCalls} {text : Source}
    {info : PackageBindings.Metadata} {item : PackageBindings.Routine}
    {before after : InitializationFrame} {rows : List LocalObject}
    (history : LocalObjects calls text info item before rows after)
    (original : ∀ row ∈ rows, calls.objectAt text row.before.frame info true =
      objectStep (modelObjectCalls reader) text row.before.frame info true)
    (initial : Closed before.frame) : Closed after.frame ∧
      ∀ row ∈ rows, Closed row.before.frame ∧ Closed row.object.frame ∧
        Closed (ApplicationPackageObjectRows.initializerBase text row.before.frame info
          (ApplicationPackageObjectRows.objectName text row.before.frame) true) := by
  induction history with
  | finished => exact ⟨initial, by simp⟩
  | @added row final following atBegin apart parsed advanced rest ih =>
    have equation := (original row List.mem_cons_self).symm.trans parsed
    have live : (objectStep (modelObjectCalls reader) text row.before.frame info true).frame.position ≠ 0 := by
      rw [equation]; omega
    have next : Closed row.object.frame := by
      rw [← equation]
      exact (objectStep_retains rfl live).closed initial
    have later := ih (fun seen member => original seen (List.mem_cons_of_mem _ member)) next
    refine ⟨later.1, ?_⟩
    intro seen member
    rcases List.mem_cons.mp member with rfl | following
    · exact ⟨initial, next, initializerBase_closed initial live⟩
    · exact later.2 seen following

theorem outputInitializers_retains {calls : CompletionCalls} {text : Source}
    {info : PackageBindings.Metadata} {indices : List Nat} {before after : InitializationFrame}
    (run : outputInitializers calls text info indices before = some after) : Retains before.frame after.frame := by
  obtain ⟨position, same⟩ := outputInitializers_sameDeclarations run
  rw [same]
  exact ⟨rfl, rfl, rfl, rfl⟩

theorem appendOutput_retains {calls : CompletionCalls}
    (original : calls.appendFormal = appendFormal) {text : Source}
    {formal : PackageBindings.Formal} {before after : ParserState}
    (run : appendOutput calls text formal before = some after) : Retains before after := by
  dsimp only [appendOutput] at run
  split at run
  · cases run; exact .refl _
  · split at run
    · contradiction
    · split at run
      · contradiction
      · cases run
        rw [original]
        exact appendFormal_retains _ _ _ _

theorem appendOutputs_retains {calls : CompletionCalls}
    (original : calls.appendFormal = appendFormal) {text : Source}
    {info : PackageBindings.Metadata} {indices : List Nat} {before after : ParserState}
    (run : appendOutputs calls text info indices before = some after) : Retains before after := by
  induction indices generalizing before with
  | nil => cases run; exact .refl _
  | cons index rest ih =>
    obtain ⟨middle, first, last⟩ := Option.bind_eq_some_iff.mp run
    exact (appendOutput_retains original first).trans (ih last)

end Silver.ApplicationPackageRoutineClosedFrames
