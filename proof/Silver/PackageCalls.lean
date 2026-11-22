module

public import Silver.PackageInterfaces

@[expose] public section

/-! Package call interfaces use a complete existing expression state. Main may
therefore retain String values, input, arrays and local callable operations;
scalar-only package bodies specialize the same interface at scalarState.
This module supplies bounds/safety components, not lexical membership or the
additional source alias/effect checks. Callee typing is discharged by the
definition-prefix induction, never assumed by the source endpoint. -/
namespace Silver.Packages
open ScalarFunctions (Frame Value ScalarType ArgumentsFit)

structure SharedEnvironment.Typed (environment : SharedEnvironment) (schema : StateSchema) : Prop where
  functions : ∀ identity signature, lookupRoutine environment.signatures identity = some (.function signature) →
    ∀ globals, schema.Fits globals → ∀ inputs, ArgumentsFit signature.formals inputs →
      signature.result.Contains (environment.functions identity globals inputs)
  procedures : ∀ identity signature, lookupRoutine environment.signatures identity = some (.procedure signature) →
    ∀ globals, schema.Fits globals → ∀ inputs,
      ArgumentsFit (ScalarProcedures.inputTypes signature.formals) inputs →
      schema.Fits (environment.procedures identity globals inputs).1 ∧
        ArgumentsFit (ScalarProcedures.outputTypes signature.formals)
          (environment.procedures identity globals inputs).2

theorem SharedEnvironment.empty_typed (schema : StateSchema) : SharedEnvironment.Typed .empty schema where
  functions := by intro identity signature found; simp [empty, lookupRoutine] at found
  procedures := by intro identity signature found; simp [empty, lookupRoutine] at found

def checkFunction (earlier : List RoutineSignature) (shape : Bindings.Shape)
    (analysis : Integer.Analysis) (flow : Predicate.Flow) (booleans : Boolean.Analysis)
    (call : ScalarFunctions.Call) : Option ScalarType :=
  (lookupRoutine earlier call.callee).bind fun routine =>
    match routine with
    | .procedure _ => none
    | .function signature =>
        if ScalarFunctions.checkActuals shape analysis flow booleans signature.formals call.actuals
        then some signature.result else none

theorem checkFunction_success {earlier : List RoutineSignature} {shape : Bindings.Shape}
    {analysis : Integer.Analysis} {flow : Predicate.Flow} {booleans : Boolean.Analysis}
    {call : ScalarFunctions.Call} {result : ScalarType}
    (checked : checkFunction earlier shape analysis flow booleans call = some result) :
    ∃ signature, lookupRoutine earlier call.callee = some (.function signature) ∧
      ScalarFunctions.checkActuals shape analysis flow booleans signature.formals call.actuals = true ∧
      signature.result = result := by
  simp only [checkFunction, Option.bind_eq_some_iff] at checked
  obtain ⟨routine, found, result⟩ := checked
  cases routine with
  | procedure => contradiction
  | function signature =>
      dsimp only at result
      split at result
      · exact ⟨signature, found, by assumption, Option.some.inj result⟩
      · contradiction

def checkedFunctionValue (environment : SharedEnvironment) (globals : Frame)
    (state : ScalarFunctions.State) (call : ScalarFunctions.Call) : Option Value :=
  (lookupRoutine environment.signatures call.callee).bind fun routine =>
    match routine with
    | .procedure _ => none
    | .function signature =>
        (ScalarFunctions.checkedActuals state call.actuals).bind fun inputs =>
          if ScalarFunctions.checkArguments signature.formals inputs then
            let result := environment.functions call.callee globals inputs
            if signature.result.contains result then some result else none
          else none

theorem function_call_sound {schema : StateSchema} {environment : SharedEnvironment} {globals : Frame}
    {shape : Bindings.Shape} {analysis : Integer.Analysis} {flow : Predicate.Flow}
    {booleans : Boolean.Analysis} {state : ScalarFunctions.State} {call : ScalarFunctions.Call}
    {result : ScalarType} {hasArguments rejected : Bool}
    (library : environment.Typed schema) (globalsFit : schema.Fits globals)
    (strings : Bindings.Fits shape state.input state.values)
    (readable : call.Readable hasArguments shape booleans)
    (allowed : flow.Allows state.inputValid state.input.length rejected state.integers)
    (checked : checkFunction environment.signatures shape analysis flow booleans call = some result) :
    (∀ actual ∈ call.actuals, actual.Safe shape state) ∧
      result.Contains (environment.functions call.callee globals (ScalarFunctions.evaluateActuals state call.actuals)) ∧
      checkedFunctionValue environment globals state call =
        some (environment.functions call.callee globals (ScalarFunctions.evaluateActuals state call.actuals)) := by
  obtain ⟨signature, found, inputs, rfl⟩ := checkFunction_success checked
  have actuals := ScalarFunctions.checkActuals_sound strings readable allowed inputs
  have result := library.functions call.callee signature found globals globalsFit _ actuals.2
  refine ⟨actuals.1, result, ?_⟩
  have values := ScalarFunctions.checkedActuals_agrees strings actuals.1
  have compatible := (ScalarFunctions.checkArguments_iff _ _).mpr actuals.2
  have returned := (ScalarFunctions.ScalarType.contains_iff _ _).mpr result
  simp only [checkedFunctionValue, found, Option.bind_some, values, compatible, returned, ↓reduceIte]

theorem resolveProcedure_success {earlier : List RoutineSignature} {call : ScalarProcedures.Call}
    {resolved : ScalarProcedures.ResolvedCall} (found : resolveProcedure earlier call = some resolved) :
    lookupRoutine earlier call.callee = some (.procedure resolved.signature) ∧
      ScalarProcedures.bindActuals resolved.signature.formals call.actuals = some resolved.actuals := by
  simp only [resolveProcedure, Option.bind_eq_some_iff] at found
  obtain ⟨routine, known, bound⟩ := found
  cases routine with
  | function => contradiction
  | procedure signature =>
      obtain ⟨actuals, inputs, same⟩ := Option.map_eq_some_iff.mp bound
      cases same
      exact ⟨known, inputs⟩

def checkProcedure (earlier : List RoutineSignature) (shape : Bindings.Shape)
    (analysis : Integer.Analysis) (flow : Predicate.Flow) (booleans : Boolean.Analysis)
    (call : ScalarProcedures.Call) : Bool :=
  match resolveProcedure earlier call with
  | none => false
  | some resolved => ScalarProcedures.actualsApart call.actuals &&
      ScalarFunctions.checkActuals shape analysis flow booleans
        (ScalarProcedures.inputTypes resolved.signature.formals) resolved.actuals.inputs &&
      ScalarProcedures.checkTargets analysis booleans
        (ScalarProcedures.outputTypes resolved.signature.formals) resolved.actuals.outputs

theorem checkProcedure_success {earlier : List RoutineSignature} {shape : Bindings.Shape}
    {analysis : Integer.Analysis} {flow : Predicate.Flow} {booleans : Boolean.Analysis}
    {call : ScalarProcedures.Call}
    (checked : checkProcedure earlier shape analysis flow booleans call = true) :
    ∃ resolved, resolveProcedure earlier call = some resolved ∧
      ScalarProcedures.actualsApart call.actuals = true ∧
      ScalarFunctions.checkActuals shape analysis flow booleans
        (ScalarProcedures.inputTypes resolved.signature.formals) resolved.actuals.inputs = true ∧
      ScalarProcedures.checkTargets analysis booleans
        (ScalarProcedures.outputTypes resolved.signature.formals) resolved.actuals.outputs = true := by
  cases found : resolveProcedure earlier call with
  | none => simp [checkProcedure, found] at checked
  | some resolved =>
      simp only [checkProcedure, found, Bool.and_eq_true] at checked
      exact ⟨resolved, rfl, checked.1.1, checked.1.2, checked.2⟩

def checkedProcedureValue (environment : SharedEnvironment) (globals : Frame)
    (state : ScalarFunctions.State) (call : ScalarProcedures.Call) : Option (Frame × List Value) :=
  (resolveProcedure environment.signatures call).bind fun resolved =>
    (ScalarFunctions.checkedActuals state resolved.actuals.inputs).bind fun inputs =>
      if ScalarFunctions.checkArguments (ScalarProcedures.inputTypes resolved.signature.formals) inputs then
        let result := environment.procedures call.callee globals inputs
        if ScalarFunctions.checkArguments (ScalarProcedures.outputTypes resolved.signature.formals) result.2
        then some result else none
      else none

theorem procedure_call_sound {schema : StateSchema} {environment : SharedEnvironment} {globals : Frame}
    {shape : Bindings.Shape} {analysis : Integer.Analysis} {flow : Predicate.Flow}
    {booleans : Boolean.Analysis} {state : ScalarFunctions.State} {call : ScalarProcedures.Call}
    {hasArguments rejected : Bool}
    (library : environment.Typed schema) (globalsFit : schema.Fits globals)
    (strings : Bindings.Fits shape state.input state.values)
    (readable : call.Readable hasArguments shape booleans)
    (allowed : flow.Allows state.inputValid state.input.length rejected state.integers)
    (checked : checkProcedure environment.signatures shape analysis flow booleans call = true) :
    ∃ resolved, resolveProcedure environment.signatures call = some resolved ∧
      (∀ actual ∈ resolved.actuals.inputs, actual.Safe shape state) ∧
      let result := environment.procedures call.callee globals
        (ScalarFunctions.evaluateActuals state resolved.actuals.inputs)
      schema.Fits result.1 ∧ ArgumentsFit (ScalarProcedures.outputTypes resolved.signature.formals) result.2 ∧
        checkedProcedureValue environment globals state call = some result := by
  obtain ⟨resolved, found, _, inputs, _⟩ := checkProcedure_success checked
  have bound := resolveProcedure_success found
  have readableInputs := ScalarProcedures.bindActuals_inputs_readable readable bound.2
  have actuals := ScalarFunctions.checkActuals_sound strings readableInputs allowed inputs
  have result := library.procedures call.callee resolved.signature bound.1 globals globalsFit _ actuals.2
  refine ⟨resolved, found, actuals.1, result.1, result.2, ?_⟩
  have values := ScalarFunctions.checkedActuals_agrees strings actuals.1
  have compatible := (ScalarFunctions.checkArguments_iff _ _).mpr actuals.2
  have returned := (ScalarFunctions.checkArguments_iff _ _).mpr result.2
  simp only [checkedProcedureValue, found, Option.bind_some, values, compatible, returned, ↓reduceIte]

def functionObligations (earlier : List RoutineSignature) (shape : Bindings.Shape)
    (analysis : Integer.Analysis) (flow : Predicate.Flow) (booleans : Boolean.Analysis)
    (call : ScalarFunctions.Call) : List Predicate.Obligation :=
  match lookupRoutine earlier call.callee with
  | some (.function signature) =>
      Predicate.actualsObligations shape analysis flow booleans signature.formals call.actuals
  | _ => [.impossible]

theorem function_obligations_discharge {earlier : List RoutineSignature} {shape : Bindings.Shape}
    {analysis : Integer.Analysis} {flow : Predicate.Flow} {booleans : Boolean.Analysis}
    {call : ScalarFunctions.Call} {result : ScalarType}
    (checked : checkFunction earlier shape analysis flow booleans call = some result) :
    Predicate.discharged (functionObligations earlier shape analysis flow booleans call) = true := by
  obtain ⟨signature, found, inputs, _⟩ := checkFunction_success checked
  simpa only [functionObligations, found] using Predicate.actuals_obligations_discharge inputs

def procedureObligations (earlier : List RoutineSignature) (shape : Bindings.Shape)
    (analysis : Integer.Analysis) (flow : Predicate.Flow) (booleans : Boolean.Analysis)
    (call : ScalarProcedures.Call) : List Predicate.Obligation :=
  match resolveProcedure earlier call with
  | none => [.impossible]
  | some resolved =>
      Predicate.actualsObligations shape analysis flow booleans
        (ScalarProcedures.inputTypes resolved.signature.formals) resolved.actuals.inputs ++
      Predicate.targetsObligations (ScalarProcedures.outputTypes resolved.signature.formals) resolved.actuals.outputs

theorem procedure_obligations_discharge {earlier : List RoutineSignature} {shape : Bindings.Shape}
    {analysis : Integer.Analysis} {flow : Predicate.Flow} {booleans : Boolean.Analysis} {call : ScalarProcedures.Call}
    (checked : checkProcedure earlier shape analysis flow booleans call = true) :
    Predicate.discharged (procedureObligations earlier shape analysis flow booleans call) = true := by
  obtain ⟨resolved, found, _, inputs, outputs⟩ := checkProcedure_success checked
  simp only [procedureObligations, found, Predicate.discharged_append,
    Predicate.actuals_obligations_discharge inputs, Predicate.targets_obligations_discharge outputs, Bool.and_self]

end Silver.Packages
