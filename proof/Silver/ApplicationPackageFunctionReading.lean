module

public import Silver.ApplicationPackageFunctionAssignment

@[expose] public section

namespace Silver.ApplicationPackageBodies.Basic
open Compose Predicate ApplicationPackages ApplicationPackageCalls
open ApplicationPackageDeclarations

set_option backward.dsimp.instances true

/-- The function arm's concrete imported readers. Unused procedure and effect
fields remain explicit until the complete Basic import adapter is assembled. -/
def functionReaders (calls : BasicCalls) : BasicCalls :=
  {calls with
    skipAt := Compose.skipAt
    nameAfter := Compose.nameAfter
    takeToken := Compose.tokenAfter
    scalarTarget := Predicate.scalarTarget
    booleanTarget := Predicate.booleanTarget
    packageCallAt := packageCallAt modelCalls
    callAssignmentResult := Predicate.callAssignmentResult
    bodyToken := fun text _ scan token => Predicate.bodyToken text scan token}

theorem function_origin {calls : BasicCalls} {source : Statement.Input}
    (selected : origin calls source = .packageFunction) :
    selectedAssignment calls source ∧ (functionCall calls source).value.after ≠ 0 := by
  unfold origin at selected
  split at selected
  · rename_i assignment
    split at selected
    · exact ⟨assignment, by assumption⟩
    · contradiction
  · split at selected <;> contradiction

/-- The raw Basic reader supplies the original actual list, the source target,
its semantic check and the exact output flow. Every argument and target-range
obligation is discharged from those native guards; no callee-safety or
preconstructed statement-check premise is used. -/
theorem function_assignment_reading {calls : BasicCalls} {text : Source}
    {context : Predicate.Native.Context} {input : ApplicationScan} {info : PackageBindings.Metadata}
    {catalog : FunctionBindings.Metadata} {procedures : ProcedureBindings.Metadata}
    (textValid : Expressions.ValidText text) (valid : Predicate.Native.ValidContext text context)
    (body : context.elaborating = false) (storage : ValidityNative.FlowStorage input.scan.facts)
    (checked : bodyValidCheck text context.model input.scan = true) (typed : info.Typed)
    (declared : DeclaredFormalModes info) (writes : CompletedFunctionWrites info)
    (selected : origin (functionReaders calls) ⟨text, context.model, input, info, catalog, procedures⟩ = .packageFunction)
    (accepted : (applicationBasic (functionReaders calls) text context.model input info catalog procedures).scan.position ≠ 0) :
    let start := assignmentFirst (functionReaders calls) text input
    let result := applicationBasic (functionReaders calls) text context.model input info catalog procedures
    let target := functionAssignmentTarget text context.model input.scan
    let booleans := ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)
    ∃ callee frame entries values,
      callee = packageCallee modelCalls text context.model info start .function ∧
      let item := info.routineAt callee
      ActualListAt modelCalls text context.model input info item (modelCalls.reference text start).after frame entries ∧
      FormalArgumentsAt text context input info frame (formalSlots item) (values.map ScalarProcedures.Actual.value) ∧
      (∀ value ∈ values, value.Readable context.model.hasArguments context.names.shape booleans) ∧
      Packages.checkFunction ((completedEnvironment info).map Packages.RoutineEffects.signature) context.names.shape
        context.model.analysis (context.model.flow input.scan.facts) booleans ⟨callee, values⟩ = some item.resultDomain ∧
      target.identity ≠ 0 ∧ target.check context.model.analysis booleans item.resultDomain = true ∧
      target.after item.resultDomain (context.model.flow input.scan.facts) = context.model.flow result.scan.facts ∧
      discharged
        (Packages.functionObligations ((completedEnvironment info).map Packages.RoutineEffects.signature) context.names.shape
          context.model.analysis (context.model.flow input.scan.facts) booleans ⟨callee, values⟩ ++
          targetObligations item.resultDomain target) = true := by
  let source : Statement.Input := ⟨text, context.model, input, info, catalog, procedures⟩
  let start := assignmentFirst (functionReaders calls) text input
  let called := packageCallAt modelCalls text context.model input info start .function
  let result := applicationBasic (functionReaders calls) text context.model input info catalog procedures
  have present : called.value.after ≠ 0 := (function_origin selected).2
  have frame := declared_function_call_frame present declared writes
  have scan := (congrArg ApplicationScan.scan (applicationBasic_accepted accepted).2.2).trans
    (basicResult_source_scan (functionReaders calls) source)
  rw [selected] at scan
  change result.scan = Predicate.bodyToken text
    (callAssignmentResult context.model {called.result.scan with position := input.scan.position}
      (scalarTarget text context.model input.scan.position) (booleanTarget text context.model input.scan.position)
      called.value) (.symbol ";") at scan
  rw [frame.1] at scan
  have targetPresent : (callAssignmentResult context.model input.scan
      (scalarTarget text context.model input.scan.position) (booleanTarget text context.model input.scan.position)
      called.value).position ≠ 0 := by
    have positive : result.scan.position ≠ 0 := accepted
    rw [scan] at positive
    exact fixedAfter_nonzero positive
  have flow := (ValidityNative.body_import_domain text context input.scan storage checked).2.2
  have base := valid.base
  rw [body] at base
  have target := assignment_result_checks (text := text) (context := context.model) (scan := input.scan)
    (value := called.value) base.toBaseReady valid.booleans.1 flow.2.compatible.count body targetPresent
  obtain ⟨callee, actualFrame, entries, values, calleeEq, actuals, arguments, readable, callChecked, returned⟩ :=
    accepted_function_checks textValid valid body storage checked typed present declared
  have domain : callResultDomain called.value = (info.routineAt callee).resultDomain := by
    rw [returned]
    rfl
  dsimp only at target
  rw [domain] at target
  have resultFacts := congrArg BodyScan.facts scan
  refine ⟨callee, actualFrame, entries, values, calleeEq, actuals, arguments, readable,
    callChecked, target.1, target.2.1, ?_, ?_⟩
  · exact target.2.2.trans (congrArg context.model.flow resultFacts.symm)
  · rw [discharged_append, Packages.function_obligations_discharge callChecked,
      target_obligations_discharge target.2.1]
    rfl

end Silver.ApplicationPackageBodies.Basic
