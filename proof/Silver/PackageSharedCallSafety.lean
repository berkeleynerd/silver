module

public import Silver.PackageCheckedExecution

@[expose] public section

/-! Shared call safety uses the exact native post-call order: record explicit
output domains, then reset all written visible persistent cells. The callee
invariant is over the full state schema and all explicit input domains. -/
namespace Silver.Packages
open ScalarFunctions (Frame Value Target ScalarType)
open Predicate (Flow)

structure SharedStepSound (schema : StateSchema) (layout : FrameLayout)
    (analysis : Integer.Analysis) (flow : Flow) (before after : SharedState)
    (checked : Option SharedState) : Prop where
  globals : schema.Fits after.globals
  declared : Integer.Fits analysis.declared (after.view layout).integers
  allowed : flow.Allows true 0 false (after.view layout).integers
  agreement : checked = some after
  readonly : ∀ index, analysis.mutable index = false →
    (after.view layout).integers index = (before.view layout).integers index

theorem flow_ext {left right : Flow} (path : left.path = right.path)
    (scalars : left.scalars = right.scalars) : left = right := by
  cases left
  cases right
  cases path
  cases scalars
  rfl

theorem scalarState_write (frame : Frame) (target : Target) (value : Value) :
    scalarState (writeCell frame (ScalarProcedures.targetCell target) value) =
      target.write value (scalarState frame) := by
  cases target <;> cases value <;> rfl

theorem scalarState_copySharedOutputs {layout : FrameLayout} (unique : layout.Injective)
    (targets : List Target) (values : List Value) (state : SharedState) :
    scalarState ((copySharedOutputs layout targets values state).view layout) =
      ScalarProcedures.copyBack targets values (scalarState (state.view layout)) := by
  simpa only [withScalarFrame, scalarState] using
    copySharedOutputs_view unique targets values state (scalarState (state.view layout))

theorem sharedTarget_fits {layout : FrameLayout} {schema : StateSchema}
    {analysis : Integer.Analysis} {booleans : Boolean.Analysis} {flow : Flow}
    {state : SharedState} {target : Target} {domain : ScalarType} {value : Value}
    (context : layout.Context schema analysis) (valid : schema.Valid)
    (globalsFit : schema.Fits state.globals)
    (declared : Integer.Fits analysis.declared (state.view layout).integers)
    (incoming : Integer.Fits flow.scalars (state.view layout).integers)
    (checked : target.check analysis booleans domain = true) (contained : domain.Contains value) :
    let next := state.write (layout.place (ScalarProcedures.targetCell target)) value
    schema.Fits next.globals ∧ Integer.Fits analysis.declared (next.view layout).integers ∧
      Integer.Fits (target.after domain flow).scalars (next.view layout).integers := by
  have sound := Target.check_write_fits (state := scalarState (state.view layout)) checked contained declared incoming
  rw [← scalarState_write] at sound
  have view := state.view_write_total context.unique (ScalarProcedures.targetCell target) value
  have full : Integer.Fits analysis.declared
      ((state.write (layout.place (ScalarProcedures.targetCell target)) value).view layout).integers := by
    rw [view]
    exact sound.1
  refine ⟨state.write_schema_from_declared context valid globalsFit full, full, ?_⟩
  rw [view]
  exact sound.2

theorem sharedOutputs_fits {layout : FrameLayout} {schema : StateSchema}
    {analysis : Integer.Analysis} {booleans : Boolean.Analysis} {flow : Flow}
    {state : SharedState} {targets : List Target} {domains : List ScalarType} {values : List Value}
    (context : layout.Context schema analysis) (valid : schema.Valid)
    (globalsFit : schema.Fits state.globals)
    (declared : Integer.Fits analysis.declared (state.view layout).integers)
    (incoming : Integer.Fits flow.scalars (state.view layout).integers)
    (checked : ScalarProcedures.checkTargets analysis booleans domains targets = true)
    (contained : ScalarFunctions.ArgumentsFit domains values) :
    let next := copySharedOutputs layout targets values state
    schema.Fits next.globals ∧ Integer.Fits analysis.declared (next.view layout).integers ∧
      Integer.Fits (ScalarProcedures.afterTargets domains targets flow).scalars (next.view layout).integers := by
  have sound := ScalarProcedures.copyBack_fits (state := scalarState (state.view layout))
    checked contained declared incoming
  rw [← scalarState_copySharedOutputs context.unique] at sound
  exact ⟨schema_from_visible_changes context valid globalsFit sound.1
    (copySharedOutputs_changes layout targets values state), sound⟩

theorem replaceGlobals_readonly {layout : FrameLayout} {schema : StateSchema}
    {analysis : Integer.Analysis} (context : layout.Context schema analysis)
    (state : SharedState) (globals : Frame) {index : Nat}
    (readonly : analysis.mutable index = false) :
    ({state with globals := globals}.view layout).integers index = (state.view layout).integers index := by
  cases selected : layout.integers index with
  | global identity =>
      have writable := context.mutable index identity selected
      rw [readonly] at writable
      contradiction
  | «local» identity => simp only [SharedState.view, SharedState.integer, selected]

theorem target_after_at_congr (target : Target) (domain : ScalarType) {first second : Flow}
    {index : Nat} (same : first.scalars index = second.scalars index) :
    (target.after domain first).scalars index = (target.after domain second).scalars index := by
  cases target <;> cases domain <;> simp only [Target.after, Integer.put, same]

theorem afterTargets_at_congr (targets : List Target) (domains : List ScalarType)
    {first second : Flow} {index : Nat} (same : first.scalars index = second.scalars index) :
    (ScalarProcedures.afterTargets domains targets first).scalars index =
      (ScalarProcedures.afterTargets domains targets second).scalars index := by
  induction targets generalizing domains first second with
  | nil => cases domains <;> exact same
  | cons target targets ih =>
      cases domains with
      | nil => exact same
      | cons domain domains => exact ih domains (target_after_at_congr target domain same)

theorem resetGlobalFlow_afterTargets {layout : FrameLayout} {declared : Integer.Ranges}
    {writes allWrites : List Cell} (included : ∀ cell ∈ writes, cell ∈ allWrites)
    (targets : List Target) (domains : List ScalarType) (flow : Flow) :
    resetGlobalFlow declared layout allWrites (ScalarProcedures.afterTargets domains targets
      (resetGlobalFlow declared layout writes flow)) =
    resetGlobalFlow declared layout allWrites (ScalarProcedures.afterTargets domains targets flow) := by
  apply flow_ext
  · simp only [resetGlobalFlow, ScalarProcedures.afterTargets_path]
  · funext index
    cases selected : layout.integers index with
    | global identity =>
        by_cases written : ScalarProcedures.Cell.integer identity ∈ allWrites
        · simp only [resetGlobalFlow, resetGlobalRanges, selected, written, ↓reduceIte]
        · have absent : ScalarProcedures.Cell.integer identity ∉ writes :=
            fun member => written (included _ member)
          simp only [resetGlobalFlow, resetGlobalRanges, selected, written, ↓reduceIte]
          apply afterTargets_at_congr
          simp only [resetGlobalRanges, selected, absent, ↓reduceIte]
    | «local» identity =>
        simp only [resetGlobalFlow, resetGlobalRanges, selected]
        apply afterTargets_at_congr
        simp only [resetGlobalRanges, selected]

theorem checkProcedureCall_success {earlier : EffectEnvironment} {layout : FrameLayout}
    {analysis : Integer.Analysis} {before after : Flow} {booleans : Boolean.Analysis}
    {call : ScalarProcedures.Call}
    (checked : checkProcedureCall earlier layout analysis before booleans call = some after) :
    ∃ resolved routine,
      checkProcedure (earlier.map RoutineEffects.signature) Bindings.emptyShape analysis before booleans call = true ∧
      resolveProcedure (earlier.map RoutineEffects.signature) call = some resolved ∧
      lookupRoutine earlier call.callee = some routine ∧
      after = resetGlobalFlow analysis.declared layout
        (routine.effects.writes ++ globalCells layout (resolved.actuals.outputs.map ScalarProcedures.targetCell))
        (ScalarProcedures.afterTargets (ScalarProcedures.outputTypes resolved.signature.formals)
          resolved.actuals.outputs before) := by
  simp only [checkProcedureCall] at checked
  split at checked
  · rename_i bounds
    simp only [Option.bind_eq_some_iff, Option.map_eq_some_iff] at checked
    obtain ⟨resolved, found, routine, known, same⟩ := checked
    exact ⟨resolved, routine, bounds, found, known, same.symm⟩
  · contradiction

theorem shared_function_assignment_agrees {schema : StateSchema} {environment : SharedEnvironment}
    {earlier : EffectEnvironment} {layout : FrameLayout} {analysis : Integer.Analysis}
    {before after : Flow} {booleans : Boolean.Analysis} {state : SharedState}
    {update : ScalarFunctions.Assignment}
    (signatures : environment.signatures = earlier.map RoutineEffects.signature)
    (library : environment.Typed schema) (globalsFit : schema.Fits state.globals)
    (readable : update.call.Readable false Bindings.emptyShape booleans)
    (allowed : before.Allows true 0 false (state.view layout).integers)
    (checked : checkFunctionAssignment earlier analysis before booleans update = some after) :
    checkedSharedFunctionAssignment environment layout state update =
      some (state.functionAssignment environment layout update) := by
  simp only [checkFunctionAssignment, Option.bind_eq_some_iff] at checked
  obtain ⟨result, found, assigned⟩ := checked
  split at assigned
  · rename_i target
    have call := function_call_sound (state := scalarState (state.view layout))
      library globalsFit (Bindings.empty_fits []) readable allowed (by simpa only [signatures] using found)
    simp only [checkedSharedFunctionAssignment, call.2.2, Option.bind_some,
      checkedSharedWrite_agrees target call.2.1, SharedState.functionAssignment, SharedState.actuals]
  · contradiction

theorem shared_function_assignment_sound {schema : StateSchema} {environment : SharedEnvironment}
    {earlier : EffectEnvironment} {layout : FrameLayout} {analysis : Integer.Analysis}
    {before after : Flow} {booleans : Boolean.Analysis} {state : SharedState}
    {update : ScalarFunctions.Assignment}
    (signatures : environment.signatures = earlier.map RoutineEffects.signature)
    (library : environment.Typed schema) (valid : schema.Valid)
    (context : layout.Context schema analysis)
    (globalsFit : schema.Fits state.globals)
    (declared : Integer.Fits analysis.declared (state.view layout).integers)
    (readable : update.call.Readable false Bindings.emptyShape booleans)
    (allowed : before.Allows true 0 false (state.view layout).integers)
    (checked : checkFunctionAssignment earlier analysis before booleans update = some after) :
    SharedStepSound schema layout analysis after state (state.functionAssignment environment layout update)
      (checkedSharedFunctionAssignment environment layout state update) := by
  have agreement := shared_function_assignment_agrees signatures library globalsFit readable allowed checked
  simp only [checkFunctionAssignment, Option.bind_eq_some_iff] at checked
  obtain ⟨result, found, assigned⟩ := checked
  split at assigned
  · rename_i target
    cases Option.some.inj assigned
    have call := function_call_sound (state := scalarState (state.view layout))
      library globalsFit (Bindings.empty_fits []) readable allowed (by simpa only [signatures] using found)
    have written := sharedTarget_fits context valid globalsFit declared allowed.2 target call.2.1
    refine ⟨written.1, written.2.1, ⟨?_, written.2.2⟩, agreement, ?_⟩
    · simpa only [Target.after_path] using allowed.1
    · intro index readonly
      have stable := ScalarProcedures.target_integer_unchanged
        (state := scalarState (state.view layout)) (value := environment.functions update.call.callee
          state.globals (state.actuals layout update.call.actuals)) target readonly
      simp only [SharedState.functionAssignment]
      rw [state.view_write_total context.unique]
      rw [← scalarState_write] at stable
      exact stable
  · contradiction

theorem shared_procedure_call_sound {schema : StateSchema} {environment : SharedEnvironment}
    {earlier : EffectEnvironment} {layout : FrameLayout} {analysis : Integer.Analysis}
    {before after : Flow} {booleans : Boolean.Analysis} {state : SharedState}
    {call : ScalarProcedures.Call}
    (effects : environment.RespectsEffects earlier)
    (library : environment.Typed schema) (valid : schema.Valid)
    (context : layout.Context schema analysis)
    (globalsFit : schema.Fits state.globals)
    (declared : Integer.Fits analysis.declared (state.view layout).integers)
    (readable : call.Readable false Bindings.emptyShape booleans)
    (allowed : before.Allows true 0 false (state.view layout).integers)
    (checked : checkProcedureCall earlier layout analysis before booleans call = some after) :
    SharedStepSound schema layout analysis after state (state.procedureCall environment layout call)
      (checkedSharedProcedureCall environment layout state call) := by
  obtain ⟨resolved, routine, bounded, found, known, rfl⟩ := checkProcedureCall_success checked
  have foundEnv : resolveProcedure environment.signatures call = some resolved := by
    simpa only [effects.1] using found
  obtain ⟨resolvedAgain, foundAgain, _, inputs, targets⟩ := checkProcedure_success bounded
  have same : resolvedAgain = resolved := Option.some.inj (foundAgain.symm.trans found)
  subst resolvedAgain
  obtain ⟨resultResolved, resultFound, _, result⟩ := procedure_call_sound
    (state := scalarState (state.view layout)) library globalsFit (Bindings.empty_fits [])
    readable allowed (by simpa only [effects.1] using bounded)
  have same : resultResolved = resolved := Option.some.inj (resultFound.symm.trans foundEnv)
  subst resultResolved
  let returned := environment.procedures call.callee state.globals (state.actuals layout resolved.actuals.inputs)
  have returnedFit : schema.Fits returned.1 := result.1
  have valuesFit : ScalarFunctions.ArgumentsFit (ScalarProcedures.outputTypes resolved.signature.formals)
      returned.2 := result.2.1
  have computed : checkedProcedureValue environment state.globals (scalarState (state.view layout)) call =
      some returned := result.2.2
  let middle : SharedState := {state with globals := returned.1}
  let final := copySharedOutputs layout resolved.actuals.outputs returned.2 middle
  let allWrites := routine.effects.writes ++ globalCells layout (resolved.actuals.outputs.map ScalarProcedures.targetCell)
  have changes : ChangesOnly routine.effects.writes state.globals returned.1 :=
    effects.2 call.callee routine known state.globals _
  have reset := resetGlobalFlow_allows context.covered allowed returnedFit changes
  have full := replaceGlobals_declared_fits context.covered declared returnedFit
  have copied := sharedOutputs_fits (flow := resetGlobalFlow analysis.declared layout routine.effects.writes before)
    context valid returnedFit full reset.2 targets valuesFit
  have finalDeclared : Integer.Fits analysis.declared (final.view layout).integers := copied.2.1
  have finalFit : schema.Fits final.globals := copied.1
  have outputFlow : (ScalarProcedures.afterTargets (ScalarProcedures.outputTypes resolved.signature.formals)
      resolved.actuals.outputs (resetGlobalFlow analysis.declared layout routine.effects.writes before)).Allows
      true 0 false (final.view layout).integers :=
    ⟨by simpa only [ScalarProcedures.afterTargets_path, resetGlobalFlow] using allowed.1, copied.2.2⟩
  have finalFlow := resetGlobalFlow_allows context.covered outputFlow finalFit (changesOnly_refl allWrites final.globals)
  have order := resetGlobalFlow_afterTargets (layout := layout) (declared := analysis.declared)
    (writes := routine.effects.writes) (allWrites := allWrites) (fun _ present => List.mem_append_left _ present)
    resolved.actuals.outputs (ScalarProcedures.outputTypes resolved.signature.formals) before
  rw [order] at finalFlow
  have ordinary : state.procedureCall environment layout call = final := by
    simp only [SharedState.procedureCall, foundEnv, final, middle, returned]
  rw [ordinary]
  refine ⟨finalFit, finalDeclared, ?_, ?_, ?_⟩
  · exact finalFlow
  · simp only [checkedSharedProcedureCall, foundEnv, Option.bind_some, computed,
      checkedSharedOutputs_agrees targets valuesFit, final, middle]
  · intro index readonly
    have stable := ScalarProcedures.copyBack_integer_unchanged
      (state := scalarState (middle.view layout)) (values := returned.2) targets readonly
    rw [← scalarState_copySharedOutputs context.unique] at stable
    exact stable.trans (replaceGlobals_readonly context state returned.1 readonly)

end Silver.Packages
