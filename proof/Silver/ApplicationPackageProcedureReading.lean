module

public import Silver.ApplicationPackageProcedureFlow
public import Silver.ApplicationPackageBodiesBasicReading

@[expose] public section

namespace Silver.ApplicationPackageCalls
open Compose Predicate ApplicationPackages

/-- Both failed and successful raw calls return the same endpoint in their
expression result and statement scan. -/
theorem packageCall_position (calls : Calls) (text : Source) (context : ParseContext)
    (input : ApplicationScan) (info : PackageBindings.Metadata) (position : Nat)
    (kind : PackageBindings.RoutineKind) :
    (packageCallAt calls text context input info position kind).result.scan.position =
      (packageCallAt calls text context input info position kind).value.after := by
  cases found : callStages calls text context input info position kind with
  | none => simp only [packageCallAt, found, failure, invalidApplication_position]; rfl
  | some stages =>
    rcases stages with ⟨callee, item, frame, result⟩
    obtain ⟨_, _, _, _, checked, _, _, finished, _, _⟩ := callStages_success found
    simp only [packageCallAt, found, finished]
    dsimp only [finishCall]
    split <;> rfl

end Silver.ApplicationPackageCalls

namespace Silver.ApplicationPackageBodies.Basic
open Compose Predicate ApplicationPackages ApplicationPackageCalls

set_option backward.dsimp.instances true

def procedureReaders (calls : BasicCalls) : BasicCalls :=
  {calls with
    packageCallee := packageCallee modelCalls
    packageCallAt := packageCallAt modelCalls
    bodyToken := fun text _ scan token => Predicate.bodyToken text scan token}

/-- The original expressions and writable targets only. Semantic readability,
range and alias checks are derived separately from the accepted native scan. -/
inductive ProcedureArgumentsAt (text : Source) (context : Predicate.Native.Context)
    (input : ApplicationScan) (info : PackageBindings.Metadata) (frame : ActualFrame) :
    List Nat → List ScalarProcedures.Actual → Prop
  | nil : ProcedureArgumentsAt text context input info frame [] []
  | value {slot slots value values} :
      ActualAt text context.model (frame.actual slot).first input.scan.facts
        (inputFormal (info.parameterAt slot)) value (frame.actual slot).after →
      ProcedureArgumentsAt text context input info frame slots values →
      ProcedureArgumentsAt text context input info frame (slot :: slots) (.value value :: values)
  | target {slot slots values} :
      (info.parameterAt slot).mode ≠ .input →
      procedureTargetActual text context.model (frame.actual slot).first input.scan.facts
        (outputFormal (info.parameterAt slot)) = (frame.actual slot).target →
      (frame.actual slot).after = (frame.actual slot).target.after →
      ProcedureArgumentsAt text context input info frame slots values →
      ProcedureArgumentsAt text context input info frame (slot :: slots)
        (.target (procedureTargetIdentity context.model (frame.actual slot).target) :: values)

theorem procedure_arguments_source {text context input info frame slots values}
    (parsed : FormalArgumentsAt text context input info frame slots values) :
    ProcedureArgumentsAt text context input info frame slots values := by
  induction parsed with
  | nil => exact .nil
  | cons argument _ rest =>
    cases argument with
    | value _ source _ _ => exact .value source rest
    | target writable source finish _ => exact .target writable source finish rest

def ProcedureCallAt (text : Source) (context : Predicate.Native.Context) (input : ApplicationScan)
    (info : PackageBindings.Metadata) (position : Nat) (call : ScalarProcedures.Call) : Prop :=
  call.callee = packageCallee modelCalls text context.model info position .procedure ∧
    ∃ frame entries,
      ActualListAt modelCalls text context.model input info (info.routineAt call.callee)
        (modelCalls.reference text position).after frame entries ∧
      ProcedureArgumentsAt text context input info frame (formalSlots (info.routineAt call.callee)) call.actuals

/-- The Basic procedure arm retains the original call and has its complete
checked argument semantics and exact native output/reset flow. Its semicolon
and final progress guard do not change the flow. -/
theorem procedure_reading {calls : BasicCalls} {text : Source}
    {context : Predicate.Native.Context} {input : ApplicationScan} {info : PackageBindings.Metadata}
    {catalog : FunctionBindings.Metadata} {procedures : ProcedureBindings.Metadata}
    (textValid : Expressions.ValidText text) (valid : Predicate.Native.ValidContext text context)
    (body : context.elaborating = false) (storage : ValidityNative.FlowStorage input.scan.facts)
    (checked : bodyValidCheck text context.model input.scan = true) (typed : info.Typed)
    (selected : origin (procedureReaders calls) ⟨text, context.model, input, info, catalog, procedures⟩ = .packageProcedure)
    (accepted : (applicationBasic (procedureReaders calls) text context.model input info catalog procedures).scan.position ≠ 0) :
    let result := applicationBasic (procedureReaders calls) text context.model input info catalog procedures
    let booleans := ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames)
    ∃ callee frame entries arguments bound,
      let item := info.routineAt callee
      callee ≠ 0 ∧ item.kind = .procedure ∧
      Packages.lookupRoutine (completedEnvironment info) callee = some ⟨item.signature info, item.effects info⟩ ∧
      readActuals modelCalls text context.model input info item
        (modelCalls.reference text input.scan.position).after = some frame ∧
      ActualListAt modelCalls text context.model input info item
        (modelCalls.reference text input.scan.position).after frame entries ∧
      FormalArgumentsAt text context input info frame (formalSlots item) arguments ∧
      ProcedureCallAt text context input info input.scan.position ⟨callee, arguments⟩ ∧
      ScalarProcedures.bindActuals ((item.formals info).map PackageBindings.Formal.semantic) arguments = some bound ∧
      (ScalarProcedures.Call.mk callee arguments).Readable context.model.hasArguments context.names.shape booleans ∧
      Packages.checkProcedure ((completedEnvironment info).map Packages.RoutineEffects.signature)
        context.names.shape context.model.analysis (context.model.flow input.scan.facts) booleans
        ⟨callee, arguments⟩ = true ∧
      context.model.flow result.scan.facts =
        resetSlotsFlow context.scalarNames
          (resetSlots modelCalls text context.model info frame.callWrites
            ((List.range info.states.length).map (· + 1)))
          (ScalarProcedures.afterTargets
            (ScalarProcedures.outputTypes ((item.formals info).map PackageBindings.Formal.semantic))
            bound.outputs (context.model.flow input.scan.facts)) := by
  let source : Statement.Input := ⟨text, context.model, input, info, catalog, procedures⟩
  let called := packageCallAt modelCalls text context.model input info input.scan.position .procedure
  let result := applicationBasic (procedureReaders calls) text context.model input info catalog procedures
  have scan := (congrArg ApplicationScan.scan (applicationBasic_accepted accepted).2.2).trans
    (basicResult_source_scan (procedureReaders calls) source)
  rw [selected] at scan
  change result.scan = Predicate.bodyToken text called.result.scan (.symbol ";") at scan
  have nonzero : called.value.after ≠ 0 := by
    rw [← packageCall_position]
    have present : result.scan.position ≠ 0 := accepted
    rw [scan] at present
    exact fixedAfter_nonzero present
  obtain ⟨callee, frame, entries, arguments, bound, calleeEq, read, parsed, semantic,
    binding, readable, checkedCall, flow⟩ := accepted_procedure_flow textValid valid body storage checked typed nonzero
  obtain ⟨raw, _, _, _, rawEq, rawPresent, _⟩ := accepted_call nonzero
  have present : callee ≠ 0 := by rwa [calleeEq, ← rawEq]
  obtain ⟨_, _, procedure, lookup⟩ := callee_completed calleeEq.symm present rfl
  refine ⟨callee, frame, entries, arguments, bound, present, procedure, lookup, read, parsed, semantic,
    ⟨calleeEq, frame, entries, parsed, procedure_arguments_source semantic⟩,
    binding, readable, checkedCall, ?_⟩
  have facts := congrArg BodyScan.facts scan
  exact (congrArg context.model.flow facts).trans flow

end Silver.ApplicationPackageBodies.Basic
