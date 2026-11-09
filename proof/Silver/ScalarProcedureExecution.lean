module

public import Silver.ScalarProcedureChecking
public import Silver.ScalarCallExecution

@[expose] public section

namespace Silver.ScalarProcedures
open ScalarFunctions (ScalarType Value State Target ArgumentsFit)

/-- Every result has already been computed from the incoming input tuple.
Copy-back does not evaluate actuals or invoke a callee between writes. -/
def copyBack : List Target → List Value → State → State
  | target :: targets, value :: values, state => copyBack targets values (target.write value state)
  | _, _, state => state

def checkedCopyBack : List Target → List Value → State → Option State
  | [], [], state => some state
  | target :: targets, value :: values, state =>
      (target.checkedWrite value state).bind fun next => checkedCopyBack targets values next
  | _, _, _ => none

theorem copyBack_frame (targets : List Target) (values : List Value) (state : State) :
    (copyBack targets values state).values = state.values ∧
      (copyBack targets values state).input = state.input ∧
      (copyBack targets values state).inputValid = state.inputValid := by
  induction targets generalizing values state with
  | nil => exact ⟨rfl, rfl, rfl⟩
  | cons target targets ih =>
      cases values with
      | nil => exact ⟨rfl, rfl, rfl⟩
      | cons value values =>
          have first := target.write_frame value state
          have rest := ih values (target.write value state)
          exact ⟨rest.1.trans first.1, rest.2.1.trans first.2.1, rest.2.2.trans first.2.2⟩

theorem checkedCopyBack_agrees {domains : List ScalarType} {targets : List Target}
    {values : List Value} {analysis : Integer.Analysis} {booleans : Boolean.Analysis} {state : State}
    (checked : checkTargets analysis booleans domains targets = true)
    (contained : ArgumentsFit domains values) :
    checkedCopyBack targets values state = some (copyBack targets values state) := by
  induction domains generalizing targets values state with
  | nil => cases targets <;> cases values <;> simp_all [checkTargets, ArgumentsFit, checkedCopyBack, copyBack]
  | cons domain domains ih =>
      cases targets with
      | nil => simp [checkTargets] at checked
      | cons target targets =>
          cases values with
          | nil => contradiction
          | cons value values =>
              have both := Bool.and_eq_true_iff.mp checked
              have first := Target.checkedWrite_agrees both.1 contained.1 (state := state)
              simp only [checkedCopyBack, first, Option.bind_some, copyBack]
              exact ih both.2 contained.2

theorem copyBack_fits {domains : List ScalarType} {targets : List Target}
    {values : List Value} {analysis : Integer.Analysis} {booleans : Boolean.Analysis}
    {flow : Predicate.Flow} {state : State}
    (checked : checkTargets analysis booleans domains targets = true)
    (contained : ArgumentsFit domains values)
    (declared : Integer.Fits analysis.declared state.integers)
    (incoming : Integer.Fits flow.scalars state.integers) :
    Integer.Fits analysis.declared (copyBack targets values state).integers ∧
      Integer.Fits (afterTargets domains targets flow).scalars (copyBack targets values state).integers := by
  induction domains generalizing targets values flow state with
  | nil => cases targets <;> cases values <;> simp_all [checkTargets, ArgumentsFit, copyBack, afterTargets]
  | cons domain domains ih =>
      cases targets with
      | nil => simp [checkTargets] at checked
      | cons target targets =>
          cases values with
          | nil => contradiction
          | cons value values =>
              have both := Bool.and_eq_true_iff.mp checked
              have first := Target.check_write_fits both.1 contained.1 declared incoming
              exact ih both.2 contained.2 first.1 first.2

theorem target_integer_unchanged {target : Target} {domain : ScalarType} {value : Value}
    {analysis : Integer.Analysis} {booleans : Boolean.Analysis} {state : State} {identity : Nat}
    (checked : target.check analysis booleans domain = true)
    (readonly : analysis.mutable identity = false) :
    (target.write value state).integers identity = state.integers identity := by
  cases target with
  | boolean index => cases value <;> rfl
  | integer index bounds =>
      cases domain with
      | boolean => simp [Target.check] at checked
      | integer result =>
          have writable := (Target.integer_check checked).1
          have other : identity ≠ index := by intro same; rw [← same, readonly] at writable; contradiction
          cases value <;> simp [Target.write, Integer.put, other]

theorem target_boolean_unchanged {target : Target} {domain : ScalarType} {value : Value}
    {analysis : Integer.Analysis} {booleans : Boolean.Analysis} {state : State} {identity : Nat}
    (checked : target.check analysis booleans domain = true)
    (readonly : booleans.mutable identity = false) :
    (target.write value state).booleans identity = state.booleans identity := by
  cases target with
  | integer index bounds => cases value <;> rfl
  | boolean index =>
      cases domain with
      | integer result => simp [Target.check] at checked
      | boolean =>
          have writable := Boolean.canWrite_mutable checked
          have other : identity ≠ index := by intro same; rw [← same, readonly] at writable; contradiction
          cases value <;> simp [Target.write, Boolean.put, other]

theorem copyBack_integer_unchanged {domains : List ScalarType} {targets : List Target}
    {values : List Value} {analysis : Integer.Analysis} {booleans : Boolean.Analysis}
    {state : State} {identity : Nat}
    (checked : checkTargets analysis booleans domains targets = true)
    (readonly : analysis.mutable identity = false) :
    (copyBack targets values state).integers identity = state.integers identity := by
  induction domains generalizing targets values state with
  | nil => cases targets <;> simp_all [checkTargets, copyBack]
  | cons domain domains ih =>
      cases targets with
      | nil => simp [checkTargets] at checked
      | cons target targets =>
          cases values with
          | nil => rfl
          | cons value values =>
              have both := Bool.and_eq_true_iff.mp checked
              exact (ih both.2).trans (target_integer_unchanged both.1 readonly)

theorem copyBack_boolean_unchanged {domains : List ScalarType} {targets : List Target}
    {values : List Value} {analysis : Integer.Analysis} {booleans : Boolean.Analysis}
    {state : State} {identity : Nat}
    (checked : checkTargets analysis booleans domains targets = true)
    (readonly : booleans.mutable identity = false) :
    (copyBack targets values state).booleans identity = state.booleans identity := by
  induction domains generalizing targets values state with
  | nil => cases targets <;> simp_all [checkTargets, copyBack]
  | cons domain domains ih =>
      cases targets with
      | nil => simp [checkTargets] at checked
      | cons target targets =>
          cases values with
          | nil => rfl
          | cons value values =>
              have both := Bool.and_eq_true_iff.mp checked
              exact (ih both.2).trans (target_boolean_unchanged both.1 readonly)

def Call.execute (environment : Environment) (state : State) (call : Call) : State :=
  match call.resolve environment.signatures with
  | none => state
  | some resolved =>
      copyBack resolved.actuals.outputs
        (environment.values call.callee (ScalarFunctions.evaluateActuals state resolved.actuals.inputs)) state

def Call.checkedExecute (environment : Environment) (state : State) (call : Call) : Option State :=
  (call.resolve environment.signatures).bind fun resolved =>
    (ScalarFunctions.checkedActuals state resolved.actuals.inputs).bind fun inputs =>
      if ScalarFunctions.checkArguments (inputTypes resolved.signature.formals) inputs then
        let outputs := environment.values call.callee inputs
        if ScalarFunctions.checkArguments (outputTypes resolved.signature.formals) outputs then
          checkedCopyBack resolved.actuals.outputs outputs state
        else none
      else none

theorem Call.execute_frame (environment : Environment) (state : State) (call : Call) :
    (call.execute environment state).values = state.values ∧
      (call.execute environment state).input = state.input ∧
      (call.execute environment state).inputValid = state.inputValid := by
  unfold execute
  split
  · exact ⟨rfl, rfl, rfl⟩
  · exact copyBack_frame ..

theorem Call.checkedExecute_agrees {environment : Environment} {shape : Bindings.Shape}
    {analysis : Integer.Analysis} {flow : Predicate.Flow} {booleans : Boolean.Analysis}
    {call : Call} {state : State} {hasArguments rejected : Bool}
    (valid : environment.Valid)
    (strings : Bindings.Fits shape state.input state.values)
    (readable : call.Readable hasArguments shape booleans)
    (allowed : flow.Allows state.inputValid state.input.length rejected state.integers)
    (checked : call.check environment.signatures shape analysis flow booleans = true) :
    call.checkedExecute environment state = some (call.execute environment state) := by
  obtain ⟨resolved, found, _, inputsChecked, outputsChecked⟩ := call.check_success checked
  have resolvedEq := call.resolve_success found
  have inputsReadable := bindActuals_inputs_readable readable resolvedEq.2
  have inputsSound := ScalarFunctions.checkActuals_sound strings inputsReadable allowed inputsChecked
  have outputsFit := valid _ _ resolvedEq.1 _ inputsSound.2
  have inputsAgree := ScalarFunctions.checkedActuals_agrees strings inputsSound.1
  have inputsFit := (ScalarFunctions.checkArguments_iff _ _).mpr inputsSound.2
  have outputsCheck := (ScalarFunctions.checkArguments_iff _ _).mpr outputsFit
  simp only [Call.checkedExecute, Call.execute, found, inputsAgree, Option.bind_some,
    inputsFit, outputsCheck, ↓reduceIte]
  exact checkedCopyBack_agrees outputsChecked outputsFit

theorem Call.check_execution_sound {environment : Environment} {shape : Bindings.Shape}
    {analysis : Integer.Analysis} {flow : Predicate.Flow} {booleans : Boolean.Analysis}
    {call : Call} {state : State} {hasArguments rejected : Bool}
    (valid : environment.Valid)
    (strings : Bindings.Fits shape state.input state.values)
    (readable : call.Readable hasArguments shape booleans)
    (allowed : flow.Allows state.inputValid state.input.length rejected state.integers)
    (declared : Integer.Fits analysis.declared state.integers)
    (checked : call.check environment.signatures shape analysis flow booleans = true) :
    Integer.Fits analysis.declared (call.execute environment state).integers ∧
      (call.after environment.signatures flow).Allows state.inputValid state.input.length rejected
        (call.execute environment state).integers ∧
      call.checkedExecute environment state = some (call.execute environment state) := by
  obtain ⟨resolved, found, _, inputsChecked, outputsChecked⟩ := call.check_success checked
  have resolvedEq := call.resolve_success found
  have inputsReadable := bindActuals_inputs_readable readable resolvedEq.2
  have inputsSound := ScalarFunctions.checkActuals_sound strings inputsReadable allowed inputsChecked
  have outputsFit := valid _ _ resolvedEq.1 _ inputsSound.2
  have written := copyBack_fits outputsChecked outputsFit declared allowed.2
  refine ⟨?_, ?_, call.checkedExecute_agrees valid strings readable allowed checked⟩
  · simpa only [Call.execute, found] using written.1
  · refine ⟨by simpa using allowed.1, ?_⟩
    simpa only [Call.execute, Call.after, found] using written.2

theorem Call.integer_unchanged {environment : Environment} {shape : Bindings.Shape}
    {analysis : Integer.Analysis} {flow : Predicate.Flow} {booleans : Boolean.Analysis}
    {call : Call} {state : State} {identity : Nat}
    (checked : call.check environment.signatures shape analysis flow booleans = true)
    (readonly : analysis.mutable identity = false) :
    (call.execute environment state).integers identity = state.integers identity := by
  obtain ⟨resolved, found, _, _, targets⟩ := call.check_success checked
  simpa only [Call.execute, found] using copyBack_integer_unchanged targets readonly

theorem Call.boolean_unchanged {environment : Environment} {shape : Bindings.Shape}
    {analysis : Integer.Analysis} {flow : Predicate.Flow} {booleans : Boolean.Analysis}
    {call : Call} {state : State} {identity : Nat}
    (checked : call.check environment.signatures shape analysis flow booleans = true)
    (readonly : booleans.mutable identity = false) :
    (call.execute environment state).booleans identity = state.booleans identity := by
  obtain ⟨resolved, found, _, _, targets⟩ := call.check_success checked
  simpa only [Call.execute, found] using copyBack_boolean_unchanged targets readonly

end Silver.ScalarProcedures
