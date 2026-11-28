module

public import Silver.ApplicationPackageVisibleReset
public import Silver.ApplicationPackageHiddenTargets
public import Silver.ApplicationPackageProcedureSourceFlow

@[expose] public section

namespace Silver.ApplicationPackageBodies.Basic
open Compose Predicate ApplicationPackages ApplicationPackageCalls Packages
open ApplicationPackageFrameLayout ApplicationPackageObjectRows ApplicationPackageEffects

set_option backward.dsimp.instances true

/-- Complete original procedure-call checking under lexical shadowing. Every
writable actual still resolves to its actual visible source row. Hidden globals
remain actual global state and use their declared interval; their omitted native
reset is therefore identical to the semantic global reset. -/
theorem procedure_hidden_source_statement {calls : BasicCalls} {text : Source}
    {context : Predicate.Native.Context} {input : ApplicationScan} {info : PackageBindings.Metadata}
    {catalog : FunctionBindings.Metadata} {procedures : ProcedureBindings.Metadata}
    (textValid : Expressions.ValidText text) (valid : Predicate.Native.ValidContext text context)
    (body : context.elaborating = false) (storage : ValidityNative.FlowStorage input.scan.facts)
    (checked : bodyValidCheck text context.model input.scan = true) (typed : info.Typed)
    (declarations : StateDeclarations text info.states)
    (fields : ScalarStateFields info.states context.scalarNames)
    (emptyShape : context.names.shape = Bindings.emptyShape) (sourceBound : Nat)
    (hiddenRanges : ∀ slot identity, (layout sourceBound info context.model).integers slot = .global identity →
      ¬OriginalLookup text context.model (.integer slot) →
      (context.model.flow input.scan.facts).scalars slot = context.model.analysis.declared slot)
    (selected : origin (procedureReaders calls) ⟨text, context.model, input, info, catalog, procedures⟩ = .packageProcedure)
    (accepted : (applicationBasic (procedureReaders calls) text context.model input info catalog procedures).scan.position ≠ 0) :
    let result := applicationBasic (procedureReaders calls) text context.model input info catalog procedures
    let booleans := ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)
    ∃ call : ScalarProcedures.Call,
      ProcedureCallAt text context input info input.scan.position call ∧
      (Predicate.Statement.procedureCall call).WellFormed context.model.hasArguments Bindings.emptyShape booleans ∧
      checkPackageStatement (completedEnvironment info) (layout sourceBound info context.model) context.model.analysis
        (context.model.flow input.scan.facts) booleans (.procedureCall call) = some (context.model.flow result.scan.facts) ∧
      discharged (packageStatementObligations (completedEnvironment info) (layout sourceBound info context.model)
        context.model.analysis (context.model.flow input.scan.facts) booleans (.procedureCall call)) = true ∧
      (∀ slot identity, (layout sourceBound info context.model).integers slot = .global identity →
        ¬OriginalLookup text context.model (.integer slot) →
        (context.model.flow result.scan.facts).scalars slot = (context.model.flow input.scan.facts).scalars slot) := by
  obtain ⟨callee, frame, entries, arguments, actuals, _, procedure, lookup, read, parsed, semantic,
    source, binding, readable, called, flow⟩ :=
    procedure_reading textValid valid body storage checked typed selected accepted
  have dimensions := accepted_call_dimensions typed (procedure_call_accepted selected accepted)
  rw [← source.1] at dimensions
  have writeCells := readActuals_effect_cells textValid declarations read parsed semantic binding
    dimensions.1 dimensions.2.1 dimensions.2.2 sourceBound
  let outputs := ScalarProcedures.afterTargets
    (ScalarProcedures.outputTypes (((info.routineAt callee).formals info).map PackageBindings.Formal.semantic))
    actuals.outputs (context.model.flow input.scan.facts)
  have outputHidden (slot identity : Nat)
      (global : (layout sourceBound info context.model).integers slot = .global identity)
      (hidden : ¬OriginalLookup text context.model (.integer slot)) :
      outputs.scalars slot = (context.model.flow input.scan.facts).scalars slot := by
    have targets := semantic.targets_original
      (fun index member => (parsed.slot_positions dimensions.2.1 index member).2)
      (global_integer_original declarations global) hidden
    apply ScalarProcedures.afterTargets_other_integer
    rw [ScalarProcedures.bindActuals_outputs binding]
    exact targets
  have reset := resetSlotsFlow_source_hidden (writes := frame.callWrites) sourceBound declarations
    valid.base.size (valid.base.body body) fields outputs
    (fun slot identity global hidden => (outputHidden slot identity global hidden).trans
      (hiddenRanges slot identity global hidden))
  have exactReset := resetGlobalFlow_membership (declared := context.model.analysis.declared)
    (layout := layout sourceBound info context.model) writeCells outputs
  have finalFlow := flow.trans (reset.trans exactReset)
  have signature := lookup
  simp only [PackageBindings.Routine.signature, procedure] at signature
  have packageChecked := procedure_statement_check (layout := layout sourceBound info context.model)
    signature binding (emptyShape ▸ called)
  rw [← finalFlow] at packageChecked
  refine ⟨⟨callee, arguments⟩, source, ?_, packageChecked,
    package_statement_obligations_discharge packageChecked, ?_⟩
  · simpa only [Predicate.Statement.WellFormed] using (emptyShape ▸ readable)
  · intro slot identity global hidden
    have omitted : slot ∉ resetSlots ApplicationPackageCalls.modelCalls text context.model info frame.callWrites
        ((List.range info.states.length).map (· + 1)) := by
      intro present
      exact hidden ((resetSlots_global_visible_iff declarations (bound := sourceBound)).mp present).2
    rw [flow, resetSlotsFlow_scalars, ite_eq_right omitted]
    exact outputHidden slot identity global hidden

end Silver.ApplicationPackageBodies.Basic
