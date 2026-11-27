module

public import Silver.ApplicationPackageFunctionReading
public import Silver.ApplicationCallTranslation

@[expose] public section

namespace Silver.Applications
open Predicate Packages

set_option backward.dsimp.instances true

/-- Preserve the actual completion-order identity when a package function is
placed after Main's existing local functions. No identity is inferred merely
from equal signatures. -/
theorem package_function_statement_check {environment : Environment} {shape : Bindings.Shape}
    {analysis : Integer.Analysis} {before : Flow} {booleans : Boolean.Analysis}
    {call : ScalarFunctions.Call} {domain : ScalarFunctions.ScalarType} {target : ScalarFunctions.Target}
    {hasArguments : Bool}
    (readable : call.Readable hasArguments shape booleans) (positive : target.identity ≠ 0)
    (called : checkFunction environment.packages.signatures shape analysis before booleans call = some domain)
    (assignable : target.check analysis booleans domain = true) :
    let item : Predicate.Statement := .callAssign ⟨target, ⟨environment.packageFunctionId call.callee, call.actuals⟩⟩
    item.WellFormed hasArguments shape booleans ∧
      item.check shape analysis before booleans environment.functionSignatures environment.procedureSignatures =
        some (target.after domain before) := by
  obtain ⟨signature, found, actuals, result⟩ := checkFunction_success called
  have lookup := environment.packageFunction_lookup found
  have translated : (ScalarFunctions.Call.mk (environment.packageFunctionId call.callee) call.actuals).check
      environment.functionSignatures shape analysis before booleans = some domain := by
    simp only [ScalarFunctions.Call.check, lookup, Option.bind_some, actuals, ↓reduceIte, result]
  have assignment : (ScalarFunctions.Assignment.mk target
      ⟨environment.packageFunctionId call.callee, call.actuals⟩).check
      environment.functionSignatures shape analysis before booleans = true := by
    simp only [ScalarFunctions.Assignment.check, translated, assignable]
  have updated := ScalarFunctions.Assignment.after_checked
    (assignment := ⟨target, ⟨environment.packageFunctionId call.callee, call.actuals⟩⟩) translated
  refine ⟨?_, ?_⟩
  · simpa only [Predicate.Statement.WellFormed, ScalarFunctions.Call.Readable] using And.intro positive readable
  · simp only [Predicate.Statement.check, assignment, ↓reduceIte, updated]

end Silver.Applications

namespace Silver.ApplicationPackageBodies.Basic
open Compose Predicate ApplicationPackages ApplicationPackageCalls
open ApplicationPackageDeclarations

inductive FunctionArgumentsAt (text : Source) (context : Predicate.Native.Context)
    (input : ApplicationScan) (info : PackageBindings.Metadata) (frame : ActualFrame) :
    List Nat → List ScalarFunctions.Actual → Prop
  | nil : FunctionArgumentsAt text context input info frame [] []
  | cons {slot slots value values} :
      ActualAt text context.model (frame.actual slot).first input.scan.facts (inputFormal (info.parameterAt slot))
        value (frame.actual slot).after →
      FunctionArgumentsAt text context input info frame slots values →
      FunctionArgumentsAt text context input info frame (slot :: slots) (value :: values)

theorem function_arguments_source {text context input info frame slots values}
    (parsed : FormalArgumentsAt text context input info frame slots (values.map ScalarProcedures.Actual.value)) :
    FunctionArgumentsAt text context input info frame slots values := by
  induction values generalizing slots with
  | nil => cases parsed; exact .nil
  | cons value values ih =>
    cases parsed with
    | cons head tail =>
      cases head with
      | value _ source _ _ => exact .cons source (ih tail)

/-- A source-only call relation: the routine and every actual are retained at
their original source positions. It contains no safety or checker premise. -/
def FunctionCallAt (text : Source) (context : Predicate.Native.Context) (input : ApplicationScan)
    (info : PackageBindings.Metadata) (position : Nat) (call : ScalarFunctions.Call) : Prop :=
  call.callee = packageCallee modelCalls text context.model info position .function ∧
    ∃ frame entries,
      ActualListAt modelCalls text context.model input info (info.routineAt call.callee)
        (modelCalls.reference text position).after frame entries ∧
      FunctionArgumentsAt text context input info frame (formalSlots (info.routineAt call.callee)) call.actuals

/-- Both semantic consumers receive the same original assignment: package
bodies use their completion-order checker, while Main translates the identity
into its combined local/package callable table. Each consumer obtains the exact
raw output flow and discharges its complete statement obligation inventory. -/
theorem function_statement_reading {calls : BasicCalls} {text : Source}
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
    ∃ call, FunctionCallAt text context input info start call ∧
      (context.names.shape = Bindings.emptyShape → ∀ layout,
        let item : Predicate.Statement := .callAssign ⟨target, call⟩
        item.WellFormed context.model.hasArguments Bindings.emptyShape booleans ∧
          Packages.checkPackageStatement (completedEnvironment info) layout context.model.analysis
            (context.model.flow input.scan.facts) booleans item = some (context.model.flow result.scan.facts) ∧
          discharged (Packages.packageStatementObligations (completedEnvironment info) layout context.model.analysis
            (context.model.flow input.scan.facts) booleans item) = true) ∧
      (∀ environment : Applications.Environment,
        environment.packages.signatures = (completedEnvironment info).map Packages.RoutineEffects.signature →
        let item : Predicate.Statement := .callAssign ⟨target, ⟨environment.packageFunctionId call.callee, call.actuals⟩⟩
        item.WellFormed context.model.hasArguments context.names.shape booleans ∧
          item.check context.names.shape context.model.analysis (context.model.flow input.scan.facts) booleans
            environment.functionSignatures environment.procedureSignatures = some (context.model.flow result.scan.facts) ∧
          discharged (item.obligations context.names.shape context.model.analysis (context.model.flow input.scan.facts)
            booleans environment.functionSignatures environment.procedureSignatures) = true) := by
  obtain ⟨callee, frame, entries, values, selectedCall, source, arguments, readable, called,
      positive, assignable, updated, _⟩ :=
    function_assignment_reading textValid valid body storage checked typed declared writes selected accepted
  refine ⟨⟨callee, values⟩, ⟨selectedCall, frame, entries, source, function_arguments_source arguments⟩, ?_, ?_⟩
  · intro emptyShape layout
    have packageChecked : Packages.checkPackageStatement (completedEnvironment info) layout context.model.analysis
        (context.model.flow input.scan.facts)
        (ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))
        (.callAssign ⟨functionAssignmentTarget text context.model input.scan, ⟨callee, values⟩⟩) =
          some (context.model.flow
            (applicationBasic (functionReaders calls) text context.model input info catalog procedures).scan.facts) := by
      simp only [Packages.checkPackageStatement, Packages.checkFunctionAssignment]
      rw [← emptyShape, called]
      simp only [Option.bind_some, assignable, ↓reduceIte, updated]
    refine ⟨?_, packageChecked, Packages.package_statement_obligations_discharge packageChecked⟩
    simpa only [Predicate.Statement.WellFormed, ScalarFunctions.Call.Readable] using
      And.intro positive (emptyShape ▸ readable)
  · intro environment signatures
    have envCall := called
    rw [← signatures] at envCall
    obtain ⟨wellFormed, mainChecked⟩ := Applications.package_function_statement_check
      (environment := environment) (hasArguments := context.model.hasArguments)
      (shape := context.names.shape) (analysis := context.model.analysis)
      (before := context.model.flow input.scan.facts)
      (booleans := ArrayBindings.booleanAnalysis context.arrayNames (BooleanBindings.analysis context.booleanNames))
      (call := ⟨callee, values⟩) readable positive envCall assignable
    rw [updated] at mainChecked
    exact ⟨wellFormed, mainChecked, statement_obligations_discharge mainChecked⟩

end Silver.ApplicationPackageBodies.Basic
