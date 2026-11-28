module

public import Silver.PackageBodySafety
public import Silver.PackageInitializationRanges

@[expose] public section

/-! Routine checking composes the original phases: bind all input-bearing
formals at their full domains, initialize locals using per-phase layouts,
execute the scalar body, then check the declared results. Representation facts
below are derived by the native frame/source bridge; they contain no callee or
body safety premise. -/
namespace Silver.Packages
open ScalarFunctions (Frame Value ScalarType ArgumentsFit)
open Predicate (Flow)

structure RoutineContext where
  analysis : Integer.Analysis
  booleans : Boolean.Analysis

def RoutineDefinition.entryRanges (schema : StateSchema) (definition : RoutineDefinition) : SharedRanges :=
  ⟨schema.integerRanges, inputRangesFrom Integer.emptyRanges definition.inputs⟩

def RoutineDefinition.bodyEntry (definition : RoutineDefinition) (ranges : SharedRanges) : Flow :=
  ⟨ScalarFunctions.entryContext, ranges.view definition.layout⟩

def RoutineDefinition.declaredRanges (schema : StateSchema) (definition : RoutineDefinition) : SharedRanges :=
  initializerDomains (definition.entryRanges schema) definition.initializers

structure RoutineDefinition.Form (schema : StateSchema) (context : RoutineContext)
    (definition : RoutineDefinition) : Prop where
  signature : definition.signature.Valid
  inputs : ∀ binding ∈ definition.inputs, binding.Valid
  interface : definition.inputs.map InputBinding.domain = definition.signature.inputTypes
  initializers : ∀ item ∈ definition.initializers, item.Readable
  layout : definition.layout.Context schema context.analysis
  declared : context.analysis.declared = (definition.declaredRanges schema).view definition.layout
  binders : StatementsLocalBinders definition.layout definition.body
  body : Predicate.StatementsWellFormed false Bindings.emptyShape definition.body context.booleans
  results : ∀ actual ∈ definition.results, actual.Readable false Bindings.emptyShape context.booleans

def RoutineDefinition.check (schema : StateSchema) (earlier : EffectEnvironment)
    (context : RoutineContext) (definition : RoutineDefinition) : Option (SharedRanges × Flow) :=
  (checkInitializers (definition.entryRanges schema) definition.initializers).bind fun initial =>
    (checkPackageStatements earlier definition.layout context.analysis (definition.bodyEntry initial)
      context.booleans definition.body).bind fun after =>
        if ScalarFunctions.checkActuals Bindings.emptyShape context.analysis after context.booleans
          definition.signature.outputTypes definition.results
        then some (initial, after) else none

theorem RoutineDefinition.check_success {schema : StateSchema} {earlier : EffectEnvironment}
    {context : RoutineContext} {definition : RoutineDefinition} {initial : SharedRanges} {after : Flow}
    (checked : definition.check schema earlier context = some (initial, after)) :
    checkInitializers (definition.entryRanges schema) definition.initializers = some initial ∧
      checkPackageStatements earlier definition.layout context.analysis (definition.bodyEntry initial)
        context.booleans definition.body = some after ∧
      ScalarFunctions.checkActuals Bindings.emptyShape context.analysis after context.booleans
        definition.signature.outputTypes definition.results = true := by
  simp only [check, Option.bind_eq_some_iff] at checked
  obtain ⟨ranges, initialized, flow, body, result⟩ := checked
  split at result
  · have same := Option.some.inj result
    cases same
    exact ⟨initialized, body, by assumption⟩
  · contradiction

theorem RoutineDefinition.entry_refines {schema : StateSchema} {context : RoutineContext}
    {definition : RoutineDefinition} {initial : SharedRanges}
    (form : definition.Form schema context)
    (checked : checkInitializers (definition.entryRanges schema) definition.initializers = some initial) :
    (initial.view definition.layout).Refines context.analysis.declared := by
  rw [form.declared]
  exact (checkInitializers_refines checked (SharedRanges.refines_refl _)).view definition.layout

def RoutineDefinition.checkedExecute (environment : SharedEnvironment) (definition : RoutineDefinition)
    (globals : Frame) (inputs : List Value) : Option (Frame × List Value) :=
  if ScalarFunctions.checkArguments definition.signature.inputTypes inputs then
    let initial : SharedState := ⟨globals, bindInputs ⟨Integer.emptyStore, Boolean.emptyStore⟩ definition.inputs inputs⟩
    (checkedInitializeLocals initial definition.initializers).bind fun entered =>
      (checkedSharedStatements environment definition.layout entered definition.body).bind fun final =>
        (ScalarFunctions.checkedActuals (scalarState (final.view definition.layout)) definition.results).bind fun values =>
          if ScalarFunctions.checkArguments definition.signature.outputTypes values
          then some (final.globals, values) else none
  else none

def RoutineDefinition.Safe (schema : StateSchema) (environment : SharedEnvironment)
    (definition : RoutineDefinition) : Prop :=
  ∀ globals, schema.Fits globals → ∀ inputs, ArgumentsFit definition.signature.inputTypes inputs →
    schema.Fits (definition.execute environment globals inputs).1 ∧
      ArgumentsFit definition.signature.outputTypes (definition.execute environment globals inputs).2 ∧
      definition.checkedExecute environment globals inputs = some (definition.execute environment globals inputs)

theorem RoutineDefinition.execution_sound {schema : StateSchema} {environment : SharedEnvironment}
    {earlier : EffectEnvironment} {context : RoutineContext} {definition : RoutineDefinition}
    {initial : SharedRanges} {after : Flow}
    (effects : environment.RespectsEffects earlier) (library : environment.Typed schema)
    (valid : schema.Valid) (form : definition.Form schema context)
    (checked : definition.check schema earlier context = some (initial, after)) :
    definition.Safe schema environment := by
  intro globals globalsFit inputs inputsFit
  have checks := definition.check_success checked
  have entryDeclared := definition.entry_refines form checks.1
  have initialized := definition.initializers_safe valid globalsFit form.inputs form.interface inputsFit
    form.initializers checks.1
  have initialRanges := SharedRanges.view_fits initialized.2.1 definition.layout
  have initialGlobals : schema.Fits (invocationFrame globals definition.inputs inputs definition.initializers).globals := by
    simpa only [invocationFrame_globals] using globalsFit
  have initialAllowed : (definition.bodyEntry initial).Allows true 0 false
      ((invocationFrame globals definition.inputs inputs definition.initializers).view definition.layout).integers :=
    ⟨ScalarFunctions.entryContext_allows false, initialRanges⟩
  have body := package_statements_sound effects library valid form.layout form.binders form.body checks.2.1
    initialGlobals (entryDeclared.fits initialRanges) initialAllowed
  have returned := ScalarFunctions.checkActuals_sound
    (state := scalarState ((definition.executeFrame environment globals inputs).view definition.layout))
    (Bindings.empty_fits []) form.results body.allowed checks.2.2
  have resultsChecked := ScalarFunctions.checkedActuals_agrees (Bindings.empty_fits []) returned.1
  have inputsCompatible := (ScalarFunctions.checkArguments_iff _ _).mpr inputsFit
  have outputsCompatible := (ScalarFunctions.checkArguments_iff _ _).mpr returned.2
  simp only [executeFrame] at resultsChecked outputsCompatible
  refine ⟨body.globals, returned.2, ?_⟩
  simp only [checkedExecute, inputsCompatible, ↓reduceIte, initialized.2.2, Option.bind_some,
    body.agreement, resultsChecked, outputsCompatible, execute, executeFrame, SharedState.actuals]

def RoutineDefinition.obligations (schema : StateSchema) (earlier : EffectEnvironment)
    (context : RoutineContext) (definition : RoutineDefinition) : List Predicate.Obligation :=
  initializersObligations (definition.entryRanges schema) definition.initializers ++
    match checkInitializers (definition.entryRanges schema) definition.initializers with
    | none => [.impossible]
    | some initial =>
        packageStatementsObligations earlier definition.layout context.analysis (definition.bodyEntry initial)
          context.booleans definition.body ++
        match checkPackageStatements earlier definition.layout context.analysis (definition.bodyEntry initial)
          context.booleans definition.body with
        | none => [.impossible]
        | some after => Predicate.actualsObligations Bindings.emptyShape context.analysis after context.booleans
            definition.signature.outputTypes definition.results

theorem RoutineDefinition.obligations_discharge {schema : StateSchema} {earlier : EffectEnvironment}
    {context : RoutineContext} {definition : RoutineDefinition} {initial : SharedRanges} {after : Flow}
    (checked : definition.check schema earlier context = some (initial, after)) :
    Predicate.discharged (definition.obligations schema earlier context) = true := by
  have checks := definition.check_success checked
  simp only [obligations, Predicate.discharged_append, initializers_obligations_discharge checks.1,
    checks.1, package_statements_obligations_discharge checks.2.1, checks.2.1,
    Predicate.actuals_obligations_discharge checks.2.2, Bool.and_self]

end Silver.Packages
