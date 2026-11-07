module

public import Silver.ScalarCallChecking

@[expose] public section

namespace Silver.ScalarFunctions

/-- The incoming expression state. A callable receives only the evaluated
scalar arguments, never these stores or an effect-producing continuation. -/
structure State where
  values : Bindings.Values
  input : Source
  inputValid : Bool
  integers : Integer.Store
  booleans : Boolean.Store

def Actual.evaluate (state : State) : Actual → Value
  | .integer expression => .integer (expression.evaluate state.integers)
  | .boolean condition => .boolean
      (condition.evaluate state.values state.input state.inputValid state.integers state.booleans)

def Actual.checkedEvaluate (state : State) : Actual → Option Value
  | .integer expression => (expression.checkedEvaluate state.integers).map Value.integer
  | .boolean condition =>
      (condition.checkedEvaluate state.values state.input state.inputValid
        state.integers state.booleans).map Value.boolean

def Actual.Safe (shape : Bindings.Shape) (state : State) : Actual → Prop
  | .integer expression => expression.Safe state.integers
  | .boolean condition => condition.Safe shape state.values state.input state.inputValid
      state.integers state.booleans

theorem Actual.checkedEvaluate_agrees {shape : Bindings.Shape} {state : State} {actual : Actual}
    (strings : Bindings.Fits shape state.input state.values)
    (safe : actual.Safe shape state) : actual.checkedEvaluate state = some (actual.evaluate state) := by
  cases actual with
  | integer expression =>
      simp only [checkedEvaluate, evaluate, Integer.Expr.checkedEvaluate_agrees safe, Option.map_some]
  | boolean condition =>
      simp only [checkedEvaluate, evaluate, Predicate.Condition.checkedEvaluate_refines safe strings, Option.map_some]

theorem Actual.check_sound {shape : Bindings.Shape} {analysis : Integer.Analysis}
    {flow : Predicate.Flow} {booleans : Boolean.Analysis} {formal : ScalarType}
    {actual : Actual} {state : State} {hasArguments rejected : Bool}
    (strings : Bindings.Fits shape state.input state.values)
    (readable : actual.Readable hasArguments shape booleans)
    (allowed : flow.Allows state.inputValid state.input.length rejected state.integers)
    (checked : actual.check shape analysis flow booleans formal = true) :
    actual.Safe shape state ∧ formal.Contains (actual.evaluate state) := by
  cases formal with
  | integer target =>
      cases actual with
      | boolean condition => simp [Actual.check] at checked
      | integer expression =>
          cases inferred : expression.infer flow.scalars with
          | none => simp [Actual.check, inferred] at checked
          | some bounds =>
              have both : bounds.isEmpty = false ∧ bounds.included target = true := by
                simpa only [Actual.check, inferred, Bool.and_eq_true, Bool.not_eq_true'] using checked
              have included := both.2
              have sound := expression.infer_sound inferred allowed.2
              exact ⟨sound.2, Integer.Interval.included_sound included sound.1⟩
  | boolean =>
      cases actual with
      | integer expression => simp [Actual.check] at checked
      | boolean condition =>
          exact ⟨condition.checkBounds_sound strings readable.2 allowed checked, trivial⟩

def evaluateActuals (state : State) (actuals : List Actual) : List Value :=
  actuals.map (Actual.evaluate state)

def checkedActuals (state : State) : List Actual → Option (List Value)
  | [] => some []
  | actual :: actuals => (actual.checkedEvaluate state).bind fun value =>
      (checkedActuals state actuals).map fun values => value :: values

theorem checkActuals_sound {shape : Bindings.Shape} {analysis : Integer.Analysis}
    {flow : Predicate.Flow} {booleans : Boolean.Analysis} {formals : List ScalarType}
    {actuals : List Actual} {state : State} {hasArguments rejected : Bool}
    (strings : Bindings.Fits shape state.input state.values)
    (readable : ∀ actual ∈ actuals, actual.Readable hasArguments shape booleans)
    (allowed : flow.Allows state.inputValid state.input.length rejected state.integers)
    (checked : checkActuals shape analysis flow booleans formals actuals = true) :
    (∀ actual ∈ actuals, actual.Safe shape state) ∧
      ArgumentsFit formals (evaluateActuals state actuals) := by
  induction formals generalizing actuals with
  | nil =>
      cases actuals <;> simp_all [checkActuals, evaluateActuals, ArgumentsFit]
  | cons formal formals ih =>
      cases actuals with
      | nil => simp [checkActuals] at checked
      | cons actual actuals =>
          have checks : actual.check shape analysis flow booleans formal = true ∧
              checkActuals shape analysis flow booleans formals actuals = true :=
            Bool.and_eq_true_iff.mp checked
          have first := actual.check_sound strings (readable actual (by simp)) allowed checks.1
          have rest := ih (fun other present => readable other (by simp [present])) checks.2
          refine ⟨?_, first.2, rest.2⟩
          intro other present
          rcases List.mem_cons.mp present with rfl | present
          · exact first.1
          · exact rest.1 other present

theorem checkedActuals_agrees {shape : Bindings.Shape} {state : State} {actuals : List Actual}
    (strings : Bindings.Fits shape state.input state.values)
    (safe : ∀ actual ∈ actuals, actual.Safe shape state) :
    checkedActuals state actuals = some (evaluateActuals state actuals) := by
  induction actuals with
  | nil => rfl
  | cons actual actuals ih =>
      have first := actual.checkedEvaluate_agrees strings (safe actual (by simp))
      have rest := ih (fun other present => safe other (by simp [present]))
      simp only [checkedActuals, first, rest, Option.bind_some, Option.map_some, evaluateActuals, List.map_cons]

def Call.evaluate (calls : CallValues) (state : State) (call : Call) : Value :=
  calls call.callee (evaluateActuals state call.actuals)

def Call.checkedEvaluate (signatures : Signatures) (calls : CallValues)
    (state : State) (call : Call) : Option Value :=
  (lookup signatures call.callee).bind fun signature =>
    (checkedActuals state call.actuals).bind fun values =>
      if checkArguments signature.formals values then
        let result := calls call.callee values
        if signature.result.contains result then some result else none
      else none

theorem Call.check_sound {signatures : Signatures} {calls : CallValues}
    {shape : Bindings.Shape} {analysis : Integer.Analysis} {flow : Predicate.Flow}
    {booleans : Boolean.Analysis} {call : Call} {result : ScalarType} {state : State}
    {hasArguments rejected : Bool}
    (results : ResultsFit signatures calls)
    (strings : Bindings.Fits shape state.input state.values)
    (readable : call.Readable hasArguments shape booleans)
    (allowed : flow.Allows state.inputValid state.input.length rejected state.integers)
    (checked : call.check signatures shape analysis flow booleans = some result) :
    (∀ actual ∈ call.actuals, actual.Safe shape state) ∧
      result.Contains (call.evaluate calls state) ∧
      call.checkedEvaluate signatures calls state = some (call.evaluate calls state) := by
  obtain ⟨signature, found, checks, rfl⟩ := call.check_success checked
  have actuals := checkActuals_sound strings readable allowed checks
  have contained := results call.callee signature found _ actuals.2
  refine ⟨actuals.1, contained, ?_⟩
  have evaluated := checkedActuals_agrees strings actuals.1
  have arguments := (checkArguments_iff _ _).mpr actuals.2
  have returned := (ScalarType.contains_iff _ _).mpr contained
  simp only [Call.checkedEvaluate, found, evaluated, Option.bind_some, arguments,
    returned, ↓reduceIte, Call.evaluate]

def Target.write (target : Target) (value : Value) (state : State) : State :=
  match target, value with
  | .integer identity _, .integer result =>
      {state with integers := Integer.put state.integers identity result}
  | .boolean identity, .boolean result =>
      {state with booleans := Boolean.put state.booleans identity result}
  | _, _ => state

def Assignment.execute (calls : CallValues) (state : State) (assignment : Assignment) : State :=
  assignment.target.write (assignment.call.evaluate calls state) state

def Target.checkedWrite (target : Target) (value : Value) (state : State) : Option State :=
  match target, value with
  | .integer identity bounds, .integer result =>
      if bounds.Contains result then some {state with integers := Integer.put state.integers identity result}
      else none
  | .boolean identity, .boolean result =>
      some {state with booleans := Boolean.put state.booleans identity result}
  | _, _ => none

def Assignment.checkedExecute (signatures : Signatures) (calls : CallValues)
    (state : State) (assignment : Assignment) : Option State :=
  (assignment.call.checkedEvaluate signatures calls state).bind fun value =>
    assignment.target.checkedWrite value state

theorem Target.checkedWrite_agrees {target : Target} {result : ScalarType} {value : Value}
    {analysis : Integer.Analysis} {booleans : Boolean.Analysis} {state : State}
    (checked : target.check analysis booleans result = true)
    (contained : result.Contains value) :
    target.checkedWrite value state = some (target.write value state) := by
  cases target with
  | integer identity bounds =>
      cases result with
      | boolean => simp [Target.check] at checked
      | integer result =>
          cases value with
          | boolean value => contradiction
          | integer value =>
              have within := Integer.Interval.included_sound (Target.integer_check checked).2.2.2 contained
              simp only [checkedWrite, write, within, ↓reduceIte]
  | boolean identity =>
      cases result with
      | integer bounds => simp [Target.check] at checked
      | boolean => cases value <;> simp_all [ScalarType.Contains, checkedWrite, write]

theorem Target.write_frame (target : Target) (value : Value) (state : State) :
    (target.write value state).values = state.values ∧
      (target.write value state).input = state.input ∧
      (target.write value state).inputValid = state.inputValid := by
  cases target <;> cases value <;> exact ⟨rfl, rfl, rfl⟩

theorem Target.write_other (target : Target) (value : Value) (state : State)
    (identity : Nat) (other : identity ≠ target.identity) :
    (target.write value state).integers identity = state.integers identity ∧
      (target.write value state).booleans identity = state.booleans identity := by
  cases target <;> cases value <;> simp_all [write, Target.identity, Integer.put, Boolean.put]

theorem Target.check_write_fits {target : Target} {result : ScalarType} {value : Value}
    {analysis : Integer.Analysis} {booleans : Boolean.Analysis}
    {flow : Predicate.Flow} {state : State}
    (checked : target.check analysis booleans result = true)
    (contained : result.Contains value)
    (declared : Integer.Fits analysis.declared state.integers)
    (incoming : Integer.Fits flow.scalars state.integers) :
    Integer.Fits analysis.declared (target.write value state).integers ∧
      Integer.Fits (target.after result flow).scalars (target.write value state).integers := by
  cases target with
  | integer identity targetBounds =>
      cases result with
      | boolean => simp [Target.check] at checked
      | integer bounds =>
          cases value with
          | boolean value => contradiction
          | integer value =>
              cases found : analysis.declared identity with
              | none => simp [Target.check, found] at checked
              | some declaredBounds =>
                  have compatible : targetBounds = declaredBounds ∧
                      bounds.isEmpty = false ∧ bounds.included declaredBounds = true := by
                    have parts := Bool.and_eq_true_iff.mp checked
                    simpa only [found, Bool.and_eq_true, decide_eq_true_eq,
                      Bool.not_eq_true'] using parts.2
                  have within := Integer.Interval.included_sound compatible.2.2 contained
                  refine ⟨?_, ?_⟩
                  · intro other interval present
                    by_cases same : other = identity
                    · subst other
                      rw [found] at present
                      cases present
                      simpa only [Target.write, Integer.put, ↓reduceIte] using within
                    · simpa only [Target.write, Integer.put, same, ↓reduceIte] using
                        declared other interval present
                  · exact Integer.put_fits incoming contained
  | boolean identity =>
      cases result with
      | integer bounds => simp [Target.check] at checked
      | boolean =>
          cases value with
          | integer value => contradiction
          | boolean value => exact ⟨declared, incoming⟩

theorem Assignment.check_execution_sound {signatures : Signatures} {calls : CallValues}
    {shape : Bindings.Shape} {analysis : Integer.Analysis} {flow : Predicate.Flow}
    {booleans : Boolean.Analysis} {assignment : Assignment} {state : State}
    {hasArguments rejected : Bool}
    (results : ResultsFit signatures calls)
    (strings : Bindings.Fits shape state.input state.values)
    (readable : assignment.call.Readable hasArguments shape booleans)
    (allowed : flow.Allows state.inputValid state.input.length rejected state.integers)
    (declared : Integer.Fits analysis.declared state.integers)
    (checked : assignment.check signatures shape analysis flow booleans = true) :
    (∀ actual ∈ assignment.call.actuals, actual.Safe shape state) ∧
      Integer.Fits analysis.declared (assignment.execute calls state).integers ∧
      (assignment.after signatures flow).Allows state.inputValid state.input.length rejected
        (assignment.execute calls state).integers ∧
      assignment.call.checkedEvaluate signatures calls state =
        some (assignment.call.evaluate calls state) := by
  obtain ⟨result, callChecked, targetChecked⟩ := assignment.check_success checked
  have callSound := assignment.call.check_sound results strings readable allowed callChecked
  have written := assignment.target.check_write_fits targetChecked callSound.2.1 declared allowed.2
  refine ⟨callSound.1, written.1, ?_, callSound.2.2⟩
  rw [assignment.after_checked callChecked]
  exact ⟨by simpa using allowed.1, written.2⟩

theorem Assignment.execute_frame (calls : CallValues) (state : State) (assignment : Assignment) :
    (assignment.execute calls state).values = state.values ∧
      (assignment.execute calls state).input = state.input ∧
      (assignment.execute calls state).inputValid = state.inputValid :=
  assignment.target.write_frame _ state

theorem Assignment.checkedExecute_agrees {signatures : Signatures} {calls : CallValues}
    {shape : Bindings.Shape} {analysis : Integer.Analysis} {flow : Predicate.Flow}
    {booleans : Boolean.Analysis} {assignment : Assignment} {state : State}
    {hasArguments rejected : Bool}
    (results : ResultsFit signatures calls)
    (strings : Bindings.Fits shape state.input state.values)
    (readable : assignment.call.Readable hasArguments shape booleans)
    (allowed : flow.Allows state.inputValid state.input.length rejected state.integers)
    (checked : assignment.check signatures shape analysis flow booleans = true) :
    assignment.checkedExecute signatures calls state = some (assignment.execute calls state) := by
  obtain ⟨result, callChecked, targetChecked⟩ := assignment.check_success checked
  have sound := assignment.call.check_sound results strings readable allowed callChecked
  simp only [checkedExecute, sound.2.2, Option.bind_some, execute]
  exact Target.checkedWrite_agrees targetChecked sound.2.1

theorem Assignment.integer_unchanged {signatures : Signatures} {calls : CallValues}
    {shape : Bindings.Shape} {analysis : Integer.Analysis} {flow : Predicate.Flow}
    {booleans : Boolean.Analysis} {assignment : Assignment} {state : State} {identity : Nat}
    (checked : assignment.check signatures shape analysis flow booleans = true)
    (readonly : analysis.mutable identity = false) :
    (assignment.execute calls state).integers identity = state.integers identity := by
  obtain ⟨result, _, targetChecked⟩ := assignment.check_success checked
  cases targetEq : assignment.target with
  | boolean index => cases valueEq : assignment.call.evaluate calls state <;> simp [execute, targetEq, valueEq, Target.write]
  | integer index bounds =>
      rw [targetEq] at targetChecked
      cases result with
      | boolean => simp [Target.check] at targetChecked
      | integer result =>
          have writable := (Target.integer_check targetChecked).1
          have other : identity ≠ index := by intro same; rw [← same, readonly] at writable; contradiction
          cases valueEq : assignment.call.evaluate calls state <;>
            simp [execute, targetEq, valueEq, Target.write, Integer.put, other]

theorem Assignment.boolean_unchanged {signatures : Signatures} {calls : CallValues}
    {shape : Bindings.Shape} {analysis : Integer.Analysis} {flow : Predicate.Flow}
    {booleans : Boolean.Analysis} {assignment : Assignment} {state : State} {identity : Nat}
    (checked : assignment.check signatures shape analysis flow booleans = true)
    (readonly : booleans.mutable identity = false) :
    (assignment.execute calls state).booleans identity = state.booleans identity := by
  obtain ⟨result, _, targetChecked⟩ := assignment.check_success checked
  cases targetEq : assignment.target with
  | integer index bounds => cases valueEq : assignment.call.evaluate calls state <;> simp [execute, targetEq, valueEq, Target.write]
  | boolean index =>
      rw [targetEq] at targetChecked
      cases result with
      | integer result => simp [Target.check] at targetChecked
      | boolean =>
          have writable := Boolean.canWrite_mutable targetChecked
          have other : identity ≠ index := by intro same; rw [← same, readonly] at writable; contradiction
          cases valueEq : assignment.call.evaluate calls state <;>
            simp [execute, targetEq, valueEq, Target.write, Boolean.put, other]

end Silver.ScalarFunctions
