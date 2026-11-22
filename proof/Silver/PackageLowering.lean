module

public import Silver.PackageExecution

@[expose] public section

/-! Relational foundations for closure conversion. The finite observed global
set is the inferred capture set, including transitive callees. No equality is
required for unobserved persistent state. Invocation-local stores remain equal.
The final definition fold must establish callee locality from earlier bodies. -/
namespace Silver.Packages
open ScalarFunctions (Frame Value Actual)

def EqualOn (cells : List Cell) (first second : Frame) : Prop :=
  ∀ cell ∈ cells, readCell second cell = readCell first cell

theorem EqualOn.mono {cells smaller : List Cell} {first second : Frame}
    (same : EqualOn cells first second) (included : ∀ cell ∈ smaller, cell ∈ cells) :
    EqualOn smaller first second := fun cell member => same cell (included cell member)

theorem EqualOn.write {cells : List Cell} {first second : Frame}
    (same : EqualOn cells first second) (target : Cell) (value : Value) :
    EqualOn cells (writeCell first target value) (writeCell second target value) := by
  intro cell member
  by_cases equal : cell = target
  · subst cell
    cases target <;> cases value
    all_goals try exact same _ member
    all_goals simp [readCell, writeCell, Integer.put, Boolean.put]
  · rw [readCell_write_other equal, readCell_write_other equal]
    exact same cell member

structure SharedAgreement (cells : List Cell) (first second : SharedState) : Prop where
  globals : EqualOn cells first.globals second.globals
  locals : second.locals = first.locals

theorem SharedAgreement.mono {cells smaller : List Cell} {first second : SharedState}
    (same : SharedAgreement cells first second) (included : ∀ cell ∈ smaller, cell ∈ cells) :
    SharedAgreement smaller first second := ⟨same.globals.mono included, same.locals⟩

theorem SharedAgreement.write {cells : List Cell} {first second : SharedState}
    (same : SharedAgreement cells first second) (place : Place) (value : Value) :
    SharedAgreement cells (first.write place value) (second.write place value) := by
  cases place with
  | global cell => exact ⟨same.globals.write cell value, same.locals⟩
  | «local» cell =>
      exact ⟨same.globals, congrArg (fun frame => writeCell frame cell value) same.locals⟩

theorem SharedAgreement.view {cells : List Cell} {first second : SharedState}
    (same : SharedAgreement cells first second) (layout : FrameLayout) (reads : List Cell)
    (covered : ∀ cell ∈ globalCells layout reads, cell ∈ cells) :
    Renaming.identity.AgreesOn reads (first.view layout) (second.view layout) := by
  intro cell member
  rw [Renaming.identity_cell, SharedState.view_read, SharedState.view_read]
  cases located : layout.place cell with
  | global global =>
      exact same.globals global (covered global (globalCells_mem.mpr ⟨cell, member, located⟩))
  | «local» localCell => simp [SharedState.read, same.locals]

theorem SharedAgreement.integer_evaluate {cells : List Cell} {first second : SharedState}
    (same : SharedAgreement cells first second) (layout : FrameLayout) (expression : Integer.Expr)
    (scalar : ScalarFunctions.scalarExpression expression = true)
    (covered : ∀ cell ∈ globalCells layout (integerReads expression), cell ∈ cells) :
    expression.evaluate (second.view layout).integers = expression.evaluate (first.view layout).integers := by
  simpa using Renaming.identity.integer_evaluate expression scalar (same.view layout _ covered)

theorem SharedAgreement.condition_evaluate {cells : List Cell} {first second : SharedState}
    (same : SharedAgreement cells first second) (layout : FrameLayout) (expression : Predicate.Condition)
    (scalar : ScalarFunctions.scalarCondition expression = true)
    (covered : ∀ cell ∈ globalCells layout (conditionReads expression), cell ∈ cells) :
    expression.evaluate Bindings.emptyValues [] true (second.view layout).integers (second.view layout).booleans =
      expression.evaluate Bindings.emptyValues [] true (first.view layout).integers (first.view layout).booleans := by
  simpa using Renaming.identity.condition_evaluate expression scalar (same.view layout _ covered)
    Bindings.emptyValues [] true

theorem SharedAgreement.actual_evaluate {cells : List Cell} {first second : SharedState}
    (same : SharedAgreement cells first second) (layout : FrameLayout) (actual : Actual)
    (scalar : ScalarFunctions.scalarActual actual = true)
    (covered : ∀ cell ∈ globalCells layout (actualReads actual), cell ∈ cells) :
    actual.evaluate (scalarState (second.view layout)) = actual.evaluate (scalarState (first.view layout)) := by
  simpa using Renaming.identity.actual_evaluate actual scalar (same.view layout _ covered)

theorem SharedAgreement.actuals_evaluate {cells : List Cell} {first second : SharedState}
    (same : SharedAgreement cells first second) (layout : FrameLayout) (actuals : List Actual)
    (scalar : ∀ actual ∈ actuals, ScalarFunctions.scalarActual actual = true)
    (covered : ∀ cell ∈ globalCells layout (actualsReads actuals), cell ∈ cells) :
    second.actuals layout actuals = first.actuals layout actuals := by
  apply List.map_congr_left
  intro actual member
  apply same.actual_evaluate layout actual (scalar actual member)
  intro cell present
  obtain ⟨native, nativeMem, located⟩ := globalCells_mem.mp present
  apply covered
  apply globalCells_mem.mpr
  exact ⟨native, List.mem_flatMap.mpr ⟨actual, member, nativeMem⟩, located⟩

def Effects.cells (effects : Effects) : List Cell := effects.reads ++ effects.writes

@[simp] theorem Effects.mem_cells (effects : Effects) (cell : Cell) :
    cell ∈ effects.cells ↔ effects.Captures cell := by simp [cells, Captures]

def Effects.CapturedIn (effects : Effects) (cells : List Cell) : Prop :=
  ∀ cell, effects.Captures cell → cell ∈ cells

theorem Effects.CapturedIn.left {first second : Effects} {cells : List Cell}
    (included : (first.merge second).CapturedIn cells) : first.CapturedIn cells :=
  fun cell member => included cell ((Effects.merge_captures _ _ _).mpr (Or.inl member))

theorem Effects.CapturedIn.right {first second : Effects} {cells : List Cell}
    (included : (first.merge second).CapturedIn cells) : second.CapturedIn cells :=
  fun cell member => included cell ((Effects.merge_captures _ _ _).mpr (Or.inr member))

theorem SharedAgreement.captures {cells : List Cell} {first second : SharedState}
    (same : SharedAgreement cells first second) {effects : Effects}
    (included : effects.CapturedIn cells) : EqualOn effects.cells first.globals second.globals :=
  same.globals.mono (fun cell member => included cell ((Effects.mem_cells _ _).mp member))

/-- Earlier completed bodies supply these relational facts. They are used as
the induction hypothesis for a later body and must be constructed by the
definition fold, never supplied by an author or assumed at admission. -/
structure SharedEnvironment.LocalOn (environment : SharedEnvironment) (earlier : EffectEnvironment) : Prop where
  footprints : environment.RespectsEffects earlier
  functions : ∀ identity routine, lookupRoutine earlier identity = some routine →
    ∀ first second inputs, EqualOn routine.effects.cells first second →
      environment.functions identity second inputs = environment.functions identity first inputs
  procedures : ∀ identity routine, lookupRoutine earlier identity = some routine →
    ∀ first second inputs, EqualOn routine.effects.cells first second →
      (environment.procedures identity second inputs).2 = (environment.procedures identity first inputs).2 ∧
        EqualOn routine.effects.cells (environment.procedures identity first inputs).1
          (environment.procedures identity second inputs).1

theorem SharedEnvironment.empty_localOn : SharedEnvironment.empty.LocalOn [] := by
  refine ⟨SharedEnvironment.empty_respectsEffects, ?_, ?_⟩
  all_goals intro identity routine found; simp [lookupRoutine] at found

theorem EqualOn.after_call {cells : List Cell} {effects : Effects}
    {first second firstAfter secondAfter : Frame} (before : EqualOn cells first second)
    (written : EqualOn effects.cells firstAfter secondAfter)
    (left : ChangesOnly effects.writes first firstAfter)
    (right : ChangesOnly effects.writes second secondAfter) :
    EqualOn cells firstAfter secondAfter := by
  intro cell member
  by_cases changed : cell ∈ effects.writes
  · exact written cell ((Effects.mem_cells _ _).mpr (Or.inr changed))
  · exact (right cell changed).trans ((before cell member).trans (left cell changed).symm)

theorem copySharedOutputs_agreement {cells : List Cell} {first second : SharedState}
    (same : SharedAgreement cells first second) (layout : FrameLayout)
    (targets : List ScalarFunctions.Target) (values : List Value) :
    SharedAgreement cells (copySharedOutputs layout targets values first)
      (copySharedOutputs layout targets values second) := by
  induction targets generalizing values first second with
  | nil => exact same
  | cons target targets ih =>
      cases values with
      | nil => exact same
      | cons value values => exact ih (same.write _ _) values

theorem procedure_inputs_scalar {signatures : List RoutineSignature} {call : ScalarProcedures.Call}
    {resolved : ScalarProcedures.ResolvedCall} (found : resolveProcedure signatures call = some resolved)
    (scalar : ∀ actual ∈ call.actuals, ScalarProcedures.scalarActual actual = true) :
    ∀ actual ∈ resolved.actuals.inputs, ScalarFunctions.scalarActual actual = true := by
  simp only [resolveProcedure, Option.bind_eq_some_iff] at found
  obtain ⟨routine, _, found⟩ := found
  cases routine with
  | function => contradiction
  | procedure signature =>
      obtain ⟨bindings, bound, equal⟩ := Option.map_eq_some_iff.mp found
      cases equal
      apply ScalarProcedures.bindActuals_inputs_property
        (property := fun actual => ScalarFunctions.scalarActual actual = true) (boundEq := bound)
      · intro value member
        exact scalar _ member
      · intro target _
        cases target <;> rfl

theorem SharedState.procedureCall_agreement {environment : SharedEnvironment} {earlier : EffectEnvironment}
    (previous : environment.LocalOn earlier) {cells : List Cell} {first second : SharedState}
    (same : SharedAgreement cells first second) (layout : FrameLayout) (call : ScalarProcedures.Call)
    {effects : Effects} (inferred : inferStatementEffects earlier layout (.procedureCall call) = some effects)
    (included : effects.CapturedIn cells)
    (scalar : ∀ actual ∈ call.actuals, ScalarProcedures.scalarActual actual = true) :
    SharedAgreement cells (first.procedureCall environment layout call)
      (second.procedureCall environment layout call) := by
  simp only [inferStatementEffects, Option.bind_eq_some_iff, Option.map_eq_some_iff] at inferred
  obtain ⟨resolved, resolvedFound, routine, known, rfl⟩ := inferred
  have inputs := same.actuals_evaluate layout resolved.actuals.inputs (procedure_inputs_scalar resolvedFound scalar)
    (fun cell member => included.left cell (Or.inl member))
  have calls := previous.procedures call.callee routine known first.globals second.globals
    (first.actuals layout resolved.actuals.inputs) (same.captures included.right)
  have left := previous.footprints.2 call.callee routine known first.globals
    (first.actuals layout resolved.actuals.inputs)
  have right := previous.footprints.2 call.callee routine known second.globals
    (first.actuals layout resolved.actuals.inputs)
  have after : SharedAgreement cells
      {first with globals := (environment.procedures call.callee first.globals
        (first.actuals layout resolved.actuals.inputs)).1}
      {second with globals := (environment.procedures call.callee second.globals
        (first.actuals layout resolved.actuals.inputs)).1} :=
    ⟨same.globals.after_call calls.2 left right, same.locals⟩
  simp only [SharedState.procedureCall, previous.footprints.1, resolvedFound, inputs, calls.1]
  exact copySharedOutputs_agreement after layout _ _

end Silver.Packages
