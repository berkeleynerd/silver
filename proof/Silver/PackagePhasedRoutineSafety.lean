module

public import Silver.PackageInitializerPhases
public import Silver.PackageRoutineSafety

@[expose] public section

namespace Silver.Packages
open ScalarFunctions (Frame Value ScalarType ArgumentsFit)
open Predicate (Flow)

/-- The source adapter selects the original local/output split and mutability.
The ordinary standalone checker remains unchanged. This checker models the
native bodyEnvironment stages between local elaboration, output reads and body
entry, with the same executable initializer list and original expression trees. -/
def RoutineDefinition.checkPhased (schema : StateSchema) (earlier : EffectEnvironment)
    (context : RoutineContext) (definition : RoutineDefinition) (phases : InitializerPhases) :
    Option (InitializedRanges × Flow) :=
  (phases.check (definition.entryRanges schema)).bind fun initial =>
    (checkPackageStatements earlier definition.layout context.analysis (definition.bodyEntry initial.body)
      context.booleans definition.body).bind fun after =>
        if ScalarFunctions.checkActuals Bindings.emptyShape context.analysis after context.booleans
          definition.signature.outputTypes definition.results
        then some (initial, after) else none

theorem RoutineDefinition.checkPhased_success {schema : StateSchema} {earlier : EffectEnvironment}
    {context : RoutineContext} {definition : RoutineDefinition} {phases : InitializerPhases}
    {initial : InitializedRanges} {after : Flow}
    (checked : definition.checkPhased schema earlier context phases = some (initial, after)) :
    phases.check (definition.entryRanges schema) = some initial ∧
      checkPackageStatements earlier definition.layout context.analysis (definition.bodyEntry initial.body)
        context.booleans definition.body = some after ∧
      ScalarFunctions.checkActuals Bindings.emptyShape context.analysis after context.booleans
        definition.signature.outputTypes definition.results = true := by
  simp only [checkPhased, Option.bind_eq_some_iff] at checked
  obtain ⟨ranges, initialized, flow, body, result⟩ := checked
  split at result
  · have same := Option.some.inj result
    cases same
    exact ⟨initialized, body, by assumption⟩
  · contradiction

theorem RoutineDefinition.phased_entry_refines {schema : StateSchema} {context : RoutineContext}
    {definition : RoutineDefinition} {phases : InitializerPhases} {initial : InitializedRanges}
    (form : definition.Form schema context) (split : phases.items = definition.initializers)
    (checked : phases.check (definition.entryRanges schema) = some initial) :
    (initial.body.view definition.layout).Refines context.analysis.declared := by
  rw [form.declared]
  have refined := (phases.check_refines checked).2
  rw [phases.declared_items, split] at refined
  exact refined.view definition.layout

/-- Full-domain execution and automatic-discharge safety for the exact native
initialization phases. Widening changes analysis only; executable initialization,
shared-state writes, call behavior and original result expressions are identical. -/
theorem RoutineDefinition.phased_execution_sound {schema : StateSchema} {environment : SharedEnvironment}
    {earlier : EffectEnvironment} {context : RoutineContext} {definition : RoutineDefinition}
    {phases : InitializerPhases} {initial : InitializedRanges} {after : Flow}
    (effects : environment.RespectsEffects earlier) (library : environment.Typed schema)
    (valid : schema.Valid) (form : definition.Form schema context)
    (split : phases.items = definition.initializers)
    (checked : definition.checkPhased schema earlier context phases = some (initial, after)) :
    definition.Safe schema environment := by
  intro globals globalsFit inputs inputsFit
  have checks := definition.checkPhased_success checked
  have entryDeclared := definition.phased_entry_refines form split checks.1
  have declaredInputs : ArgumentsFit (definition.inputs.map InputBinding.domain) inputs := by
    rw [form.interface]
    exact inputsFit
  have entryFits := invocation_inputs_full_domain valid globalsFit form.inputs declaredInputs
  have initialized := phases.check_sound checks.1
    (fun item member => form.initializers item (split ▸ member)) entryFits
  rw [split] at initialized
  have initialRanges := SharedRanges.view_fits initialized.2.2.1 definition.layout
  have initialGlobals : schema.Fits (invocationFrame globals definition.inputs inputs definition.initializers).globals := by
    simpa only [invocationFrame_globals] using globalsFit
  have initialAllowed : (definition.bodyEntry initial.body).Allows true 0 false
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
  have initializedChecked : checkedInitializeLocals
      ⟨globals, bindInputs ⟨Integer.emptyStore, Boolean.emptyStore⟩ definition.inputs inputs⟩ definition.initializers =
      some (invocationFrame globals definition.inputs inputs definition.initializers) := initialized.2.2.2
  refine ⟨body.globals, returned.2, ?_⟩
  simp only [checkedExecute, inputsCompatible, ↓reduceIte, initializedChecked, Option.bind_some,
    body.agreement, resultsChecked, outputsCompatible, execute, executeFrame, SharedState.actuals]

def RoutineDefinition.phasedObligations (schema : StateSchema) (earlier : EffectEnvironment)
    (context : RoutineContext) (definition : RoutineDefinition) (phases : InitializerPhases) : List Predicate.Obligation :=
  phases.obligations (definition.entryRanges schema) ++
    match phases.check (definition.entryRanges schema) with
    | none => [.impossible]
    | some initial =>
        packageStatementsObligations earlier definition.layout context.analysis (definition.bodyEntry initial.body)
          context.booleans definition.body ++
          match checkPackageStatements earlier definition.layout context.analysis (definition.bodyEntry initial.body)
              context.booleans definition.body with
          | none => [.impossible]
          | some after => Predicate.actualsObligations Bindings.emptyShape context.analysis after context.booleans
              definition.signature.outputTypes definition.results

theorem RoutineDefinition.phased_obligations_discharge {schema : StateSchema} {earlier : EffectEnvironment}
    {context : RoutineContext} {definition : RoutineDefinition} {phases : InitializerPhases}
    {initial : InitializedRanges} {after : Flow}
    (checked : definition.checkPhased schema earlier context phases = some (initial, after)) :
    Predicate.discharged (definition.phasedObligations schema earlier context phases) = true := by
  have checks := definition.checkPhased_success checked
  simp only [phasedObligations, Predicate.discharged_append, phases.obligations_discharge checks.1,
    checks.1, package_statements_obligations_discharge checks.2.1, checks.2.1,
    Predicate.actuals_obligations_discharge checks.2.2, Bool.and_self]

end Silver.Packages
