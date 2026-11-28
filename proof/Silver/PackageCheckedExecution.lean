module

public import Silver.PackageChecking

@[expose] public section

/-! Checked package execution retains the persistent store and invocation-local
store separately. Calls evaluate all explicit inputs before any output write.
The body theorem and definition-prefix induction prove that every check agrees
with ordinary execution for all admitted input and persistent-state domains. -/
namespace Silver.Packages
open ScalarFunctions (Frame Value Target)
open Predicate (Statement)

def checkedSharedWrite (layout : FrameLayout) (state : SharedState)
    (target : Target) (value : Value) : Option SharedState :=
  (target.checkedWrite value (scalarState (state.view layout))).map fun _ =>
    state.write (layout.place (ScalarProcedures.targetCell target)) value

theorem checkedSharedWrite_agrees {layout : FrameLayout} {state : SharedState}
    {target : Target} {domain : ScalarFunctions.ScalarType} {value : Value}
    {analysis : Integer.Analysis} {booleans : Boolean.Analysis}
    (checked : target.check analysis booleans domain = true) (contained : domain.Contains value) :
    checkedSharedWrite layout state target value =
      some (state.write (layout.place (ScalarProcedures.targetCell target)) value) := by
  simp only [checkedSharedWrite, Target.checkedWrite_agrees checked contained, Option.map_some]

def checkedSharedOutputs (layout : FrameLayout) :
    List Target → List Value → SharedState → Option SharedState
  | [], [], state => some state
  | target :: targets, value :: values, state =>
      (checkedSharedWrite layout state target value).bind fun next =>
        checkedSharedOutputs layout targets values next
  | _, _, _ => none

theorem checkedSharedOutputs_agrees {layout : FrameLayout} {state : SharedState}
    {targets : List Target} {domains : List ScalarFunctions.ScalarType} {values : List Value}
    {analysis : Integer.Analysis} {booleans : Boolean.Analysis}
    (checked : ScalarProcedures.checkTargets analysis booleans domains targets = true)
    (contained : ScalarFunctions.ArgumentsFit domains values) :
    checkedSharedOutputs layout targets values state = some (copySharedOutputs layout targets values state) := by
  induction domains generalizing targets values state with
  | nil => cases targets <;> cases values <;>
      simp_all only [ScalarProcedures.checkTargets, ScalarFunctions.ArgumentsFit,
        checkedSharedOutputs, copySharedOutputs, Bool.false_eq_true]
  | cons domain domains ih =>
      cases targets with
      | nil => simp only [ScalarProcedures.checkTargets, Bool.false_eq_true] at checked
      | cons target targets =>
          cases values with
          | nil => contradiction
          | cons value values =>
              have both := Bool.and_eq_true_iff.mp checked
              simp only [checkedSharedOutputs, checkedSharedWrite_agrees both.1 contained.1,
                Option.bind_some, copySharedOutputs]
              exact ih both.2 contained.2

def checkedSharedFunctionAssignment (environment : SharedEnvironment) (layout : FrameLayout)
    (state : SharedState) (update : ScalarFunctions.Assignment) : Option SharedState :=
  (checkedFunctionValue environment state.globals (scalarState (state.view layout)) update.call).bind
    (checkedSharedWrite layout state update.target)

def checkedSharedProcedureCall (environment : SharedEnvironment) (layout : FrameLayout)
    (state : SharedState) (call : ScalarProcedures.Call) : Option SharedState :=
  (resolveProcedure environment.signatures call).bind fun resolved =>
    (checkedProcedureValue environment state.globals (scalarState (state.view layout)) call).bind fun result =>
      checkedSharedOutputs layout resolved.actuals.outputs result.2 {state with globals := result.1}

def checkedSharedIterations (step : SharedState → Int → Option SharedState) :
    SharedState → List Int → Option SharedState
  | state, [] => some state
  | state, value :: values => (step state value).bind fun next => checkedSharedIterations step next values

mutual
  def checkedSharedStatement (environment : SharedEnvironment) (layout : FrameLayout)
      (state : SharedState) (statement : Statement) : Option SharedState :=
    let frame := state.view layout
    match statement with
    | .simple .null => some state
    | .scalarAssign update =>
        (update.value.checkedEvaluate frame.integers).bind fun value =>
          checkedSharedWrite layout state (.integer update.target update.bounds) (.integer value)
    | .booleanAssign update =>
        (update.value.checkedEvaluate Bindings.emptyValues [] true frame.integers frame.booleans).map
          fun value => state.write (layout.place (.boolean update.target)) (.boolean value)
    | .callAssign update => checkedSharedFunctionAssignment environment layout state update
    | .procedureCall call => checkedSharedProcedureCall environment layout state call
    | .choice condition yes no =>
        (condition.checkedEvaluate Bindings.emptyValues [] true frame.integers frame.booleans).bind fun value =>
          if value then checkedSharedStatements environment layout state yes
          else checkedSharedStatements environment layout state no
    | .forLoop index reverse lower upper body =>
        (lower.checkedEvaluate frame.integers).bind fun first =>
        (upper.checkedEvaluate frame.integers).bind fun last =>
          checkedSharedIterations (fun current value =>
            let place := layout.place (.integer index)
            let before := current.read place
            (checkedSharedStatements environment layout (current.write place (.integer value)) body).map
              fun result => result.write place before) state (Integer.iterationValues reverse first last)
    | _ => none
  termination_by sizeOf statement

  def checkedSharedStatements (environment : SharedEnvironment) (layout : FrameLayout)
      (state : SharedState) : List Statement → Option SharedState
    | [] => some state
    | statement :: rest => (checkedSharedStatement environment layout state statement).bind fun next =>
        checkedSharedStatements environment layout next rest
  termination_by statements => sizeOf statements
end

end Silver.Packages
