module

public import Silver.PackageSyntax
public import Silver.ScalarProcedureDefinition

@[expose] public section

/-! Direct shared-state execution of the existing scalar body tree. Calls see
the current persistent store, and procedure output actuals are evaluated before
the callee runs. The source checker admits only the scalar statement forms;
the remaining constructors have no package execution meaning. -/
namespace Silver.Packages
open ScalarFunctions (Frame Value Actual Target)
open Predicate (Statement)

structure SharedEnvironment where
  signatures : List RoutineSignature
  functions : Nat → Frame → List Value → Value
  procedures : Nat → Frame → List Value → Frame × List Value

def SharedEnvironment.empty : SharedEnvironment :=
  ⟨[], fun _ _ _ => .integer 0, fun _ globals _ => (globals, [])⟩

def SharedState.actuals (state : SharedState) (layout : FrameLayout)
    (actuals : List Actual) : List Value :=
  ScalarFunctions.evaluateActuals (scalarState (state.view layout)) actuals

def SharedState.functionAssignment (environment : SharedEnvironment) (layout : FrameLayout)
    (state : SharedState) (assignment : ScalarFunctions.Assignment) : SharedState :=
  let value := environment.functions assignment.call.callee state.globals
    (state.actuals layout assignment.call.actuals)
  state.write (layout.place (ScalarProcedures.targetCell assignment.target)) value

/-- The tuple has already been computed. No actual expression is reevaluated
between the writes, including when a target designates persistent state. -/
def copySharedOutputs (layout : FrameLayout) : List Target → List Value → SharedState → SharedState
  | target :: targets, value :: values, state =>
      copySharedOutputs layout targets values
        (state.write (layout.place (ScalarProcedures.targetCell target)) value)
  | _, _, state => state

def SharedState.procedureCall (environment : SharedEnvironment) (layout : FrameLayout)
    (state : SharedState) (call : ScalarProcedures.Call) : SharedState :=
  match resolveProcedure environment.signatures call with
  | none => state
  | some resolved =>
      let returned := environment.procedures call.callee state.globals
        (state.actuals layout resolved.actuals.inputs)
      copySharedOutputs layout resolved.actuals.outputs returned.2 {state with globals := returned.1}

mutual
  def executeSharedStatement (environment : SharedEnvironment) (layout : FrameLayout)
      (state : SharedState) (statement : Statement) : SharedState :=
    let frame := state.view layout
    match statement with
    | .simple .null => state
    | .scalarAssign update => state.write (layout.place (.integer update.target))
        (.integer (update.value.evaluate frame.integers))
    | .booleanAssign update => state.write (layout.place (.boolean update.target))
        (.boolean (update.value.evaluate Bindings.emptyValues [] true frame.integers frame.booleans))
    | .callAssign update => state.functionAssignment environment layout update
    | .procedureCall call => state.procedureCall environment layout call
    | .choice condition yes no =>
        if condition.evaluate Bindings.emptyValues [] true frame.integers frame.booleans
        then executeSharedStatements environment layout state yes
        else executeSharedStatements environment layout state no
    | .forLoop index reverse lower upper body =>
        (Integer.iterationValues reverse (lower.evaluate frame.integers) (upper.evaluate frame.integers)).foldl
          (fun current value =>
            let place := layout.place (.integer index)
            let before := current.read place
            let result := executeSharedStatements environment layout (current.write place (.integer value)) body
            result.write place before) state
    | _ => state
  termination_by sizeOf statement
  def executeSharedStatements (environment : SharedEnvironment) (layout : FrameLayout)
      (state : SharedState) : List Statement → SharedState
    | [] => state
    | statement :: rest => executeSharedStatements environment layout
        (executeSharedStatement environment layout state statement) rest
  termination_by statements => sizeOf statements
end

def globalCells (layout : FrameLayout) (cells : List Cell) : List Cell :=
  cells.filterMap fun cell => match layout.place cell with
    | .global global => some global
    | .local _ => none

theorem globalCells_mem {layout : FrameLayout} {cells : List Cell} {global : Cell} :
    global ∈ globalCells layout cells ↔ ∃ cell ∈ cells, layout.place cell = .global global := by
  simp only [globalCells, List.mem_filterMap]
  constructor
  · rintro ⟨cell, member, found⟩
    refine ⟨cell, member, ?_⟩
    cases place : layout.place cell <;> simp_all
  · rintro ⟨cell, member, place⟩
    exact ⟨cell, member, by simp [place]⟩

def directEffects (layout : FrameLayout) (reads writes : List Cell) : Effects :=
  ⟨globalCells layout reads, globalCells layout writes⟩

def actualsReads (actuals : List Actual) : List Cell := actuals.flatMap actualReads

structure RoutineEffects where
  signature : RoutineSignature
  effects : Effects
  deriving DecidableEq, Repr

abbrev EffectEnvironment := List RoutineEffects

/- Every branch and loop body is traversed, independently of evaluated guards
or trip counts. Only previously completed callable summaries are available. -/
mutual
  def inferStatementEffects (earlier : EffectEnvironment) (layout : FrameLayout) : Statement → Option Effects
    | .simple .null => some ⟨[], []⟩
    | .scalarAssign update =>
        some (directEffects layout (integerReads update.value) [.integer update.target])
    | .booleanAssign update =>
        some (directEffects layout (conditionReads update.value) [.boolean update.target])
    | .callAssign update =>
        (lookupRoutine earlier update.call.callee).bind fun called =>
          match called.signature with
          | .procedure _ => none
          | .function _ => some ((directEffects layout (actualsReads update.call.actuals)
              [ScalarProcedures.targetCell update.target]).merge called.effects)
    | .procedureCall call =>
        (resolveProcedure (earlier.map RoutineEffects.signature) call).bind fun resolved =>
          (lookupRoutine earlier call.callee).map fun called =>
            (directEffects layout (actualsReads resolved.actuals.inputs)
              (resolved.actuals.outputs.map ScalarProcedures.targetCell)).merge called.effects
    | .choice condition yes no =>
        (inferStatementsEffects earlier layout yes).bind fun left =>
          (inferStatementsEffects earlier layout no).map fun right =>
            (directEffects layout (conditionReads condition) []).merge (left.merge right)
    | .forLoop index _ lower upper body =>
        (inferStatementsEffects earlier layout body).map fun inner =>
          (directEffects layout (integerReads lower ++ integerReads upper) [.integer index]).merge inner
    | _ => none
  termination_by statement => sizeOf statement
  def inferStatementsEffects (earlier : EffectEnvironment) (layout : FrameLayout) : List Statement → Option Effects
    | [] => some ⟨[], []⟩
    | statement :: rest =>
        (inferStatementEffects earlier layout statement).bind fun first =>
          (inferStatementsEffects earlier layout rest).map fun following => first.merge following
  termination_by statements => sizeOf statements
end

theorem inferStatementEffects_choice {earlier : EffectEnvironment} {layout : FrameLayout}
    {condition : Predicate.Condition} {yes no : List Statement} {effects : Effects}
    (inferred : inferStatementEffects earlier layout (.choice condition yes no) = some effects) :
    ∃ left right, inferStatementsEffects earlier layout yes = some left ∧
      inferStatementsEffects earlier layout no = some right ∧
      (∀ cell, left.Captures cell → effects.Captures cell) ∧
      (∀ cell, right.Captures cell → effects.Captures cell) := by
  simp only [inferStatementEffects, Option.bind_eq_some_iff, Option.map_eq_some_iff] at inferred
  obtain ⟨left, leftFound, right, rightFound, rfl⟩ := inferred
  refine ⟨left, right, leftFound, rightFound, ?_, ?_⟩
  · intro cell member
    exact (Effects.merge_captures _ _ _).mpr (Or.inr ((Effects.merge_captures _ _ _).mpr (Or.inl member)))
  · intro cell member
    exact (Effects.merge_captures _ _ _).mpr (Or.inr ((Effects.merge_captures _ _ _).mpr (Or.inr member)))

theorem inferStatementEffects_loop {earlier : EffectEnvironment} {layout : FrameLayout}
    {index : Nat} {reverse : Bool} {lower upper : Integer.Expr} {body : List Statement} {effects : Effects}
    (inferred : inferStatementEffects earlier layout (.forLoop index reverse lower upper body) = some effects) :
    ∃ inner, inferStatementsEffects earlier layout body = some inner ∧
      ∀ cell, inner.Captures cell → effects.Captures cell := by
  simp only [inferStatementEffects] at inferred
  obtain ⟨inner, found, rfl⟩ := Option.map_eq_some_iff.mp inferred
  exact ⟨inner, found, fun cell member => (Effects.merge_captures _ _ _).mpr (Or.inr member)⟩

/-- The public body inference rejects every expression and statement form not
selected for package scalar bodies before exposing its summary. -/
def inferBodyEffects (earlier : EffectEnvironment) (layout : FrameLayout)
    (body : List Statement) : Option Effects :=
  if ScalarProcedures.scalarStatements body then inferStatementsEffects earlier layout body else none

theorem inferBodyEffects_scalar {earlier : EffectEnvironment} {layout : FrameLayout}
    {body : List Statement} {effects : Effects}
    (inferred : inferBodyEffects earlier layout body = some effects) :
    ScalarProcedures.scalarStatements body = true := by
  unfold inferBodyEffects at inferred
  split at inferred
  · assumption
  · contradiction

theorem changesOnly_trans {writes : List Cell} {before middle after : Frame}
    (first : ChangesOnly writes before middle) (second : ChangesOnly writes middle after) :
    ChangesOnly writes before after :=
  fun cell absent => (second cell absent).trans (first cell absent)

theorem SharedState.write_globals (state : SharedState) (layout : FrameLayout)
    (cell : Cell) (value : Value) :
    ChangesOnly (globalCells layout [cell]) state.globals
      (state.write (layout.place cell) value).globals := by
  cases place : layout.place cell with
  | global global =>
      simpa [globalCells, place, SharedState.write] using changesOnly_write state.globals global value
  | «local» identity =>
      simpa [globalCells, place, SharedState.write] using changesOnly_refl [] state.globals

theorem copySharedOutputs_changes (layout : FrameLayout) (targets : List Target)
    (values : List Value) (state : SharedState) :
    ChangesOnly (globalCells layout (targets.map ScalarProcedures.targetCell))
      state.globals (copySharedOutputs layout targets values state).globals := by
  induction targets generalizing values state with
  | nil => exact changesOnly_refl _ _
  | cons target targets ih =>
      cases values with
      | nil => exact changesOnly_refl _ _
      | cons value values =>
          have first := state.write_globals layout (ScalarProcedures.targetCell target) value
          have rest := ih values (state.write (layout.place (ScalarProcedures.targetCell target)) value)
          have split : globalCells layout ((target :: targets).map ScalarProcedures.targetCell) =
              globalCells layout [ScalarProcedures.targetCell target] ++
                globalCells layout (targets.map ScalarProcedures.targetCell) := by
            change globalCells layout ([ScalarProcedures.targetCell target] ++
              targets.map ScalarProcedures.targetCell) = _
            exact List.filterMap_append
          rw [split]
          exact changesOnly_sequence first rest

/-- This is the prefix-induction hypothesis for already completed procedures.
The definition fold must derive it from each body; it is not an admission
premise for a source package or a substitute for body safety. -/
def SharedEnvironment.RespectsEffects (environment : SharedEnvironment)
    (earlier : EffectEnvironment) : Prop :=
  environment.signatures = earlier.map RoutineEffects.signature ∧
    ∀ identity routine, lookupRoutine earlier identity = some routine →
      ∀ globals inputs, ChangesOnly routine.effects.writes globals
        (environment.procedures identity globals inputs).1

theorem SharedEnvironment.empty_respectsEffects : SharedEnvironment.empty.RespectsEffects [] := by
  refine ⟨rfl, ?_⟩
  intro identity routine found
  simp [lookupRoutine] at found

theorem SharedState.procedureCall_changes {environment : SharedEnvironment} {earlier : EffectEnvironment}
    (previous : environment.RespectsEffects earlier) (layout : FrameLayout) (state : SharedState)
    (call : ScalarProcedures.Call) {effects : Effects}
    (inferred : inferStatementEffects earlier layout (.procedureCall call) = some effects) :
    ChangesOnly effects.writes state.globals (state.procedureCall environment layout call).globals := by
  simp only [inferStatementEffects, Option.bind_eq_some_iff, Option.map_eq_some_iff] at inferred
  obtain ⟨resolved, resolvedFound, routine, known, rfl⟩ := inferred
  have globals := previous.2 call.callee routine known state.globals
    (state.actuals layout resolved.actuals.inputs)
  have outputs := copySharedOutputs_changes layout resolved.actuals.outputs
    (environment.procedures call.callee state.globals (state.actuals layout resolved.actuals.inputs)).2
    {state with globals := (environment.procedures call.callee state.globals
      (state.actuals layout resolved.actuals.inputs)).1}
  have combined := changesOnly_sequence globals outputs
  simp only [SharedState.procedureCall, previous.1, resolvedFound]
  apply changesOnly_mono _ combined
  intro cell member
  simpa only [Effects.merge, directEffects, List.mem_append, or_comm] using member

theorem foldl_globals_changes (writes : List Cell) (step : SharedState → Int → SharedState)
    (bounded : ∀ state value, ChangesOnly writes state.globals (step state value).globals)
    (values : List Int) (state : SharedState) :
    ChangesOnly writes state.globals (values.foldl step state).globals := by
  induction values generalizing state with
  | nil => exact changesOnly_refl _ _
  | cons value values ih => exact changesOnly_trans (bounded state value) (ih _)

mutual
  theorem executeSharedStatement_changes {environment : SharedEnvironment} {earlier : EffectEnvironment}
      (previous : environment.RespectsEffects earlier) (layout : FrameLayout) (state : SharedState)
      (statement : Statement) {effects : Effects}
      (inferred : inferStatementEffects earlier layout statement = some effects) :
      ChangesOnly effects.writes state.globals
        (executeSharedStatement environment layout state statement).globals := by
    cases statement with
    | simple item =>
        cases item <;> simp only [inferStatementEffects] at inferred
        all_goals try contradiction
        simp only [executeSharedStatement]
        exact changesOnly_refl _ _
    | scalarAssign update =>
        simp only [inferStatementEffects] at inferred
        cases Option.some.inj inferred
        simp only [executeSharedStatement]
        exact state.write_globals layout (.integer update.target) _
    | booleanAssign update =>
        simp only [inferStatementEffects] at inferred
        cases Option.some.inj inferred
        simp only [executeSharedStatement]
        exact state.write_globals layout (.boolean update.target) _
    | callAssign update =>
        simp only [inferStatementEffects, Option.bind_eq_some_iff] at inferred
        obtain ⟨routine, _, returned⟩ := inferred
        cases kind : routine.signature with
        | procedure => simp [kind] at returned
        | function signature =>
            simp only [kind] at returned
            cases Option.some.inj returned
            simp only [executeSharedStatement, SharedState.functionAssignment]
            apply changesOnly_mono _ (state.write_globals layout (ScalarProcedures.targetCell update.target) _)
            intro cell member
            exact List.mem_append_left _ member
    | procedureCall call =>
        simp only [executeSharedStatement]
        exact state.procedureCall_changes previous layout call inferred
    | arrayAssign | booleanArrayAssign | reject | arrayLoop => simp [inferStatementEffects] at inferred
    | choice condition yes no =>
        simp only [inferStatementEffects, Option.bind_eq_some_iff, Option.map_eq_some_iff] at inferred
        obtain ⟨left, leftFound, right, rightFound, rfl⟩ := inferred
        simp only [executeSharedStatement]
        split
        · apply changesOnly_mono _ (executeSharedStatements_changes previous layout state yes leftFound)
          intro cell member
          simp [Effects.merge, directEffects, globalCells, member]
        · apply changesOnly_mono _ (executeSharedStatements_changes previous layout state no rightFound)
          intro cell member
          simp [Effects.merge, directEffects, globalCells, member]
    | forLoop index reverse lower upper body =>
        simp only [inferStatementEffects] at inferred
        obtain ⟨inner, bodyFound, rfl⟩ := Option.map_eq_some_iff.mp inferred
        simp only [executeSharedStatement]
        apply foldl_globals_changes
        intro current value
        have start := current.write_globals layout (.integer index) (.integer value)
        have bodyBound := executeSharedStatements_changes previous layout
          (current.write (layout.place (.integer index)) (.integer value)) body bodyFound
        have finish := (executeSharedStatements environment layout
          (current.write (layout.place (.integer index)) (.integer value)) body).write_globals
            layout (.integer index) (current.read (layout.place (.integer index)))
        apply changesOnly_trans (changesOnly_trans (changesOnly_mono _ start) (changesOnly_mono _ bodyBound))
          (changesOnly_mono _ finish)
        · intro cell member; exact List.mem_append_left _ member
        · intro cell member; exact List.mem_append_right _ member
        · intro cell member; exact List.mem_append_left _ member
  termination_by sizeOf statement
  theorem executeSharedStatements_changes {environment : SharedEnvironment} {earlier : EffectEnvironment}
      (previous : environment.RespectsEffects earlier) (layout : FrameLayout) (state : SharedState)
      (statements : List Statement) {effects : Effects}
      (inferred : inferStatementsEffects earlier layout statements = some effects) :
      ChangesOnly effects.writes state.globals
        (executeSharedStatements environment layout state statements).globals := by
    cases statements with
    | nil =>
        simp only [executeSharedStatements]
        exact changesOnly_refl _ _
    | cons statement rest =>
        simp only [inferStatementsEffects, Option.bind_eq_some_iff, Option.map_eq_some_iff] at inferred
        obtain ⟨first, firstFound, following, followingFound, rfl⟩ := inferred
        simp only [executeSharedStatements]
        exact changesOnly_sequence
          (executeSharedStatement_changes previous layout state statement firstFound)
          (executeSharedStatements_changes previous layout
            (executeSharedStatement environment layout state statement) rest followingFound)
  termination_by sizeOf statements
end

end Silver.Packages
