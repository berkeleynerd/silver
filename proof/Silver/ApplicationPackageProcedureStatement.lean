module

public import Silver.ApplicationPackageProcedureReading
public import Silver.ApplicationCallTranslation

@[expose] public section

namespace Silver.Packages
open Predicate

theorem lookup_effect_signature {earlier : EffectEnvironment} {callee : Nat} {routine : RoutineEffects}
    (found : lookupRoutine earlier callee = some routine) :
    lookupRoutine (earlier.map RoutineEffects.signature) callee = some routine.signature := by
  have positive := (lookupRoutine_before found).1
  have mapped := congrArg (Option.map RoutineEffects.signature) found
  simpa only [lookupRoutine, Nat.ne_of_gt positive, ↓reduceIte, List.getElem?_map, Option.map_some] using mapped

theorem procedure_statement_check {earlier : EffectEnvironment} {layout : FrameLayout}
    {analysis : Integer.Analysis} {before : Flow} {booleans : Boolean.Analysis}
    {call : ScalarProcedures.Call} {signature : ScalarProcedures.Signature} {effects : Effects}
    {bound : ScalarProcedures.ActualBindings}
    (found : lookupRoutine earlier call.callee = some ⟨.procedure signature, effects⟩)
    (binding : ScalarProcedures.bindActuals signature.formals call.actuals = some bound)
    (checked : checkProcedure (earlier.map RoutineEffects.signature) Bindings.emptyShape analysis before booleans call = true) :
    checkPackageStatement earlier layout analysis before booleans (.procedureCall call) =
      some (resetGlobalFlow analysis.declared layout
        (effects.writes ++ globalCells layout (bound.outputs.map ScalarProcedures.targetCell))
        (ScalarProcedures.afterTargets (ScalarProcedures.outputTypes signature.formals) bound.outputs before)) := by
  have signature := lookup_effect_signature found
  simp only [checkPackageStatement, checkProcedureCall, checked, ↓reduceIte,
    resolveProcedure, signature, Option.bind_some, binding, Option.map_some, found]

end Silver.Packages

namespace Silver.Applications
open Predicate Packages

/-- The Main checker keeps the actual package routine identity in the suffix
of the complete local/package procedure table. -/
theorem package_procedure_statement_check {environment : Environment} {shape : Bindings.Shape}
    {analysis : Integer.Analysis} {before : Flow} {booleans : Boolean.Analysis}
    {call : ScalarProcedures.Call} {signature : ScalarProcedures.Signature}
    {bound : ScalarProcedures.ActualBindings} {hasArguments : Bool}
    (readable : call.Readable hasArguments shape booleans)
    (found : lookupRoutine environment.packages.signatures call.callee = some (.procedure signature))
    (binding : ScalarProcedures.bindActuals signature.formals call.actuals = some bound)
    (checked : checkProcedure environment.packages.signatures shape analysis before booleans call = true) :
    let item : Predicate.Statement := .procedureCall ⟨environment.packageProcedureId call.callee, call.actuals⟩
    item.WellFormed hasArguments shape booleans ∧
      item.check shape analysis before booleans environment.functionSignatures environment.procedureSignatures =
        some (ScalarProcedures.afterTargets (ScalarProcedures.outputTypes signature.formals) bound.outputs before) := by
  have lookup := environment.packageProcedure_lookup found
  let translated : ScalarProcedures.Call := ⟨environment.packageProcedureId call.callee, call.actuals⟩
  have resolved : translated.resolve environment.procedureSignatures = some ⟨signature, bound⟩ := by
    simp only [ScalarProcedures.Call.resolve, translated, lookup, Option.bind_some, binding, Option.map_some]
  have called : translated.check environment.procedureSignatures shape analysis before booleans = true := by
    simpa only [ScalarProcedures.Call.check, resolved, checkProcedure, resolveProcedure,
      found, Option.bind_some, binding, Option.map_some, translated] using checked
  refine ⟨?_, ?_⟩
  · simpa only [Predicate.Statement.WellFormed, ScalarProcedures.Call.Readable] using readable
  · change (Predicate.Statement.procedureCall translated).check _ _ _ _ _ _ = _
    simp only [Predicate.Statement.check, called, ↓reduceIte, ScalarProcedures.Call.after, resolved]

end Silver.Applications

namespace Silver.ApplicationPackageBodies.Basic
open Compose Predicate ApplicationPackages ApplicationPackageCalls

set_option backward.dsimp.instances true

/-- Both statement consumers use the original procedure arguments and output
flow. The package consumer needs the original layout's precise reset membership
and ranges; Main needs its private-package state to have no visible reset slots.
Those are representation facts to derive from the source history, not assumed
semantic safety or successful statement checks. -/
theorem procedure_statement_reading {calls : BasicCalls} {text : Source}
    {context : Predicate.Native.Context} {input : ApplicationScan} {info : PackageBindings.Metadata}
    {catalog : FunctionBindings.Metadata} {procedures : ProcedureBindings.Metadata}
    (textValid : Expressions.ValidText text) (valid : Predicate.Native.ValidContext text context)
    (body : context.elaborating = false) (storage : ValidityNative.FlowStorage input.scan.facts)
    (checked : bodyValidCheck text context.model input.scan = true) (typed : info.Typed)
    (selected : origin (procedureReaders calls) ⟨text, context.model, input, info, catalog, procedures⟩ = .packageProcedure)
    (accepted : (applicationBasic (procedureReaders calls) text context.model input info catalog procedures).scan.position ≠ 0) :
    let result := applicationBasic (procedureReaders calls) text context.model input info catalog procedures
    let booleans := ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)
    ∃ callee frame arguments bound,
      let item := info.routineAt callee
      let slots := resetSlots modelCalls text context.model info frame.callWrites
        ((List.range info.states.length).map (· + 1))
      ProcedureCallAt text context input info input.scan.position ⟨callee, arguments⟩ ∧
      readActuals modelCalls text context.model input info item
        (modelCalls.reference text input.scan.position).after = some frame ∧
      FormalArgumentsAt text context input info frame (formalSlots item) arguments ∧
      ScalarProcedures.bindActuals ((item.formals info).map PackageBindings.Formal.semantic) arguments = some bound ∧
      (context.names.shape = Bindings.emptyShape → ∀ layout : Packages.FrameLayout,
        let writes := (item.effects info).writes ++
          Packages.globalCells layout (bound.outputs.map ScalarProcedures.targetCell)
        (∀ slot, slot ∈ slots ↔ ∃ identity,
          layout.integers slot = .global identity ∧ .integer identity ∈ writes) →
        (∀ slot ∈ slots, context.model.analysis.declared slot =
          some (ScalarExpression.binding context.scalarNames slot).declaredBounds) →
        let statement : Predicate.Statement := .procedureCall ⟨callee, arguments⟩
        statement.WellFormed context.model.hasArguments Bindings.emptyShape booleans ∧
          Packages.checkPackageStatement (completedEnvironment info) layout context.model.analysis
            (context.model.flow input.scan.facts) booleans statement = some (context.model.flow result.scan.facts) ∧
          discharged (Packages.packageStatementObligations (completedEnvironment info) layout context.model.analysis
            (context.model.flow input.scan.facts) booleans statement) = true) ∧
      (slots = [] → ∀ environment : Applications.Environment,
        environment.packages.signatures = (completedEnvironment info).map Packages.RoutineEffects.signature →
        let statement : Predicate.Statement := .procedureCall ⟨environment.packageProcedureId callee, arguments⟩
        statement.WellFormed context.model.hasArguments context.names.shape booleans ∧
          statement.check context.names.shape context.model.analysis (context.model.flow input.scan.facts) booleans
            environment.functionSignatures environment.procedureSignatures = some (context.model.flow result.scan.facts) ∧
          discharged (statement.obligations context.names.shape context.model.analysis (context.model.flow input.scan.facts)
            booleans environment.functionSignatures environment.procedureSignatures) = true) := by
  obtain ⟨callee, frame, entries, arguments, bound, _, procedure, lookup, read, _, semantic,
    source, binding, readable, called, flow⟩ :=
    procedure_reading textValid valid body storage checked typed selected accepted
  have signature := lookup
  simp only [PackageBindings.Routine.signature, procedure] at signature
  refine ⟨callee, frame, arguments, bound, source, read, semantic, binding, ?_, ?_⟩
  · intro emptyShape layout
    dsimp only
    intro selected ranges
    have packageChecked := Packages.procedure_statement_check (layout := layout) signature binding
      (emptyShape ▸ called)
    have reset := resetSlotsFlow_global selected ranges
      (ScalarProcedures.afterTargets
        (ScalarProcedures.outputTypes (((info.routineAt callee).formals info).map PackageBindings.Formal.semantic))
        bound.outputs (context.model.flow input.scan.facts))
    rw [← reset, ← flow] at packageChecked
    refine ⟨?_, packageChecked, Packages.package_statement_obligations_discharge packageChecked⟩
    simpa only [Predicate.Statement.WellFormed] using (emptyShape ▸ readable)
  · intro noGlobals environment signatures
    have ordinary := flow
    rw [noGlobals] at ordinary
    change context.model.flow _ = ScalarProcedures.afterTargets _ _ _ at ordinary
    have named := Packages.lookup_effect_signature signature
    rw [← signatures] at named
    have checks := called
    rw [← signatures] at checks
    obtain ⟨wellFormed, mainChecked⟩ := Applications.package_procedure_statement_check
      (environment := environment) readable named binding checks
    rw [← ordinary] at mainChecked
    exact ⟨wellFormed, mainChecked, statement_obligations_discharge mainChecked⟩

end Silver.ApplicationPackageBodies.Basic
