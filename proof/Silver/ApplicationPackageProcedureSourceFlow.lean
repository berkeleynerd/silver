module

public import Silver.ApplicationPackageProcedureTargetCells
public import Silver.ApplicationPackageGlobalShadowHistory
public import Silver.ApplicationPackageProcedureStatement

@[expose] public section

namespace Silver.Packages
open Predicate

theorem resetGlobalFlow_membership {declared : Integer.Ranges} {layout : FrameLayout}
    {left right : List Cell} (same : ∀ cell, cell ∈ left ↔ cell ∈ right) (flow : Flow) :
    resetGlobalFlow declared layout left flow = resetGlobalFlow declared layout right flow := by
  have ranges : resetGlobalRanges declared flow.scalars layout left =
      resetGlobalRanges declared flow.scalars layout right := by
    funext slot
    cases selected : layout.integers slot with
    | «local» identity => simp only [resetGlobalRanges, selected]
    | global identity => simp only [resetGlobalRanges, selected, same]
  simp only [resetGlobalFlow, ranges]

end Silver.Packages

namespace Silver.ApplicationPackageCalls
open Compose Predicate ApplicationPackages PackageBindings

/-- The actual native call guard supplies the active formal window; fixed
SPARK table types supply the complete write-mask capacity. -/
theorem accepted_call_dimensions {text : Source} {context : ParseContext}
    {input : ApplicationScan} {info : Metadata} {position : Nat} {kind : RoutineKind}
    (typed : info.Typed)
    (accepted : (packageCallAt modelCalls text context input info position kind).value.after ≠ 0) :
    let item := info.routineAt (packageCallee modelCalls text context info position kind)
    (0 < item.count → 0 < item.formalFirst) ∧
      (0 < item.count → item.formalFirst + item.count - 1 ≤ maxFormals) ∧
      info.states.length ≤ item.mayWrite.length := by
  obtain ⟨callee, item, frame, result, selected, present, itemEq, window, _⟩ := accepted_call accepted
  rw [← selected, ← itemEq]
  obtain ⟨positive, available, _, _⟩ := callee_completed selected.symm present rfl
  have tableBound := (callee_trace selected.symm present).1
  have inside : callee - 1 < info.routines.length := by omega
  have member : item ∈ info.routines := by
    rw [itemEq]
    simp only [Metadata.routineAt, List.getD_eq_getElem?_getD,
      List.getElem?_eq_getElem inside, Option.getD_some]
    exact List.getElem_mem inside
  rcases typed with ⟨_, _, _, _, states, _, _, parameters, _, _, routines, _⟩
  rcases routines item member with ⟨_, _, _, _, _, _, _, _, _, _, _, _, _, writes⟩
  refine ⟨?_, ?_, by rw [writes]; exact states⟩
  · intro nonempty
    have guarded : ¬(item.formalFirst = 0 ∨ item.formalFirst > info.parameters.length ∨
        item.count > info.parameters.length - item.formalFirst + 1) := fun failed => window ⟨nonempty, failed⟩
    omega
  · intro nonempty
    have guarded : ¬(item.formalFirst = 0 ∨ item.formalFirst > info.parameters.length ∨
        item.count > info.parameters.length - item.formalFirst + 1) := fun failed => window ⟨nonempty, failed⟩
    omega

end Silver.ApplicationPackageCalls

namespace Silver.ApplicationPackageBodies.Basic
open Compose Predicate ApplicationPackages ApplicationPackageCalls Packages
open ApplicationPackageFrameLayout ApplicationPackageObjectRows

set_option backward.dsimp.instances true

theorem procedure_call_accepted {calls : BasicCalls} {text : Source}
    {context : ParseContext} {input : ApplicationScan} {info : PackageBindings.Metadata}
    {catalog : FunctionBindings.Metadata} {procedures : ProcedureBindings.Metadata}
    (selected : origin (procedureReaders calls) ⟨text, context, input, info, catalog, procedures⟩ = .packageProcedure)
    (accepted : (applicationBasic (procedureReaders calls) text context input info catalog procedures).scan.position ≠ 0) :
    (packageCallAt modelCalls text context input info input.scan.position .procedure).value.after ≠ 0 := by
  let source : Statement.Input := ⟨text, context, input, info, catalog, procedures⟩
  have scan := (congrArg ApplicationScan.scan (applicationBasic_accepted accepted).2.2).trans
    (basicResult_source_scan (procedureReaders calls) source)
  rw [selected] at scan
  change (applicationBasic (procedureReaders calls) text context input info catalog procedures).scan =
    Predicate.bodyToken text (packageCallAt modelCalls text context input info input.scan.position .procedure).result.scan
      (.symbol ";") at scan
  rw [← packageCall_position]
  rw [scan] at accepted
  exact fixedAfter_nonzero accepted

/-- The package checker consumes the exact original procedure statement and
the concrete source-derived layout. Output cells, reset membership and reset
ranges are derived here; the caller supplies only ordinary source-frame history
invariants, not a successful semantic call or an effect/reset certificate. -/
theorem procedure_source_statement {calls : BasicCalls} {text : Source}
    {context : Predicate.Native.Context} {input : ApplicationScan} {info : PackageBindings.Metadata}
    {catalog : FunctionBindings.Metadata} {procedures : ProcedureBindings.Metadata}
    (textValid : Expressions.ValidText text) (valid : Predicate.Native.ValidContext text context)
    (body : context.elaborating = false) (storage : ValidityNative.FlowStorage input.scan.facts)
    (checked : bodyValidCheck text context.model input.scan = true) (typed : info.Typed)
    (declarations : StateDeclarations text info.states)
    (clear : GlobalRowsClear text info.states (scalarRows context.model))
    (fields : ScalarStateFields info.states context.scalarNames)
    (emptyShape : context.names.shape = Bindings.emptyShape) (sourceBound : Nat)
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
        context.model.analysis (context.model.flow input.scan.facts) booleans (.procedureCall call)) = true := by
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
  have reset := resetSlotsFlow_source (writes := frame.callWrites) sourceBound declarations clear
    valid.base.size (valid.base.body body) fields outputs
  have exactReset := resetGlobalFlow_membership (declared := context.model.analysis.declared)
    (layout := layout sourceBound info context.model) writeCells outputs
  have finalFlow := flow.trans (reset.trans exactReset)
  have signature := lookup
  simp only [PackageBindings.Routine.signature, procedure] at signature
  have packageChecked := procedure_statement_check (layout := layout sourceBound info context.model)
    signature binding (emptyShape ▸ called)
  rw [← finalFlow] at packageChecked
  exact ⟨⟨callee, arguments⟩, source, by
    simpa only [Predicate.Statement.WellFormed] using (emptyShape ▸ readable),
    packageChecked, package_statement_obligations_discharge packageChecked⟩

end Silver.ApplicationPackageBodies.Basic
