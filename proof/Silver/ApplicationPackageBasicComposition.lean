module

public import Silver.ApplicationPackageBasicImports

@[expose] public section

namespace Silver.ApplicationPackageBodies.BasicImports.Libraries
open Compose Compose.Expressions Predicate ApplicationPackages Recursive

set_option backward.dsimp.instances true

theorem function_assignment (library : Libraries) (other : BasicCalls) (text : Source)
    (native : Predicate.Native.Context) (input : ApplicationScan) (info : PackageBindings.Metadata)
    (functions : FunctionBindings.Metadata) (procedures : ProcedureBindings.Metadata)
    (legal : NativeDomain ⟨text, native.model, input, info, functions, procedures⟩)
    (contextValid : Predicate.Native.ValidContext text native) (typed : info.Typed) :
    functionAssignment (library.calls other) text native.model input info functions procedures =
      functionAssignment (SourceSyntax.basicReaders (library.calls other)) text native.model input info functions procedures := by
  let start := assignmentFirst (SourceSyntax.basicReaders (library.calls other)) text input
  let called := ApplicationPackageCalls.packageCallAt ApplicationPackageCalls.modelCalls text native.model input info start .function
  have first := library.assignment_first other text legal.text input legal.scan.position
  have bounded : ValidCursor text start := fixedAfter_result_bound text _ ":=" false (by decide)
  have call := library.package_call other text legal.text native contextValid input legal.scan info typed start bounded .function
  have scalar := library.scalar_target other text legal.text native contextValid input.scan.position legal.scan.position
  have flag := library.boolean_target other text legal.text native contextValid input.scan.position legal.scan.position
  have ordinary := library.basic_body other text legal.text native contextValid input.scan legal.scan
    functions legal.functions procedures legal.procedures
  have returned := ApplicationPackageCalls.packageCall_native_contract legal typed start .function
  have scalarBound : Predicate.scalarTarget text native.model input.scan.position ≤ native.scalarNames.length :=
    ScalarExpression.lookup_bound ..
  have valueBound : called.value.after ≤ text.length + 1 := by
    rw [← ApplicationPackageCalls.packageCall_position]
    exact returned.1.position
  have assignedDomain : ScanDomain text native.model
      (Predicate.callAssignmentResult native.model {called.result.scan with position := input.scan.position}
        (Predicate.scalarTarget text native.model input.scan.position)
        (Predicate.booleanTarget text native.model input.scan.position) called.value) :=
    (returned.1.atPosition legal.scan.position).assignment _ _ called.value scalarBound valueBound returned.2.2.2
  have assigned := library.assignment_result other native _ _ _ called.value
    (assignment_domain text native input info typed functions procedures legal contextValid start)
  have token := library.body_token other text legal.text native contextValid _ assignedDomain
  dsimp only [called, start] at call assigned token
  unfold functionAssignment
  simp only [first, call, scalar, flag, assigned, token, ordinary]
  rfl

theorem procedure_statement (library : Libraries) (other : BasicCalls) (text : Source)
    (native : Predicate.Native.Context) (input : ApplicationScan) (info : PackageBindings.Metadata)
    (functions : FunctionBindings.Metadata) (procedures : ProcedureBindings.Metadata)
    (legal : NativeDomain ⟨text, native.model, input, info, functions, procedures⟩)
    (contextValid : Predicate.Native.ValidContext text native) (typed : info.Typed) :
    procedureStatement (library.calls other) text native.model input info =
      procedureStatement (SourceSyntax.basicReaders (library.calls other)) text native.model input info := by
  have call := library.package_call other text legal.text native contextValid input legal.scan info typed
    input.scan.position legal.scan.position .procedure
  have returned := ApplicationPackageCalls.packageCall_native_contract legal typed input.scan.position .procedure
  have token := library.body_token other text legal.text native contextValid _ returned.1
  unfold procedureStatement
  simp only [call, token]
  rfl

theorem basic_result (library : Libraries) (other : BasicCalls) (text : Source)
    (native : Predicate.Native.Context) (input : ApplicationScan) (info : PackageBindings.Metadata)
    (functions : FunctionBindings.Metadata) (procedures : ProcedureBindings.Metadata)
    (legal : NativeDomain ⟨text, native.model, input, info, functions, procedures⟩)
    (contextValid : Predicate.Native.ValidContext text native) (typed : info.Typed) :
    basicResult (library.calls other) text native.model input info functions procedures =
      basicResult (SourceSyntax.basicReaders (library.calls other)) text native.model input info functions procedures := by
  have first := library.assignment_first other text legal.text input legal.scan.position
  have scalar := library.scalar_target other text legal.text native contextValid input.scan.position legal.scan.position
  have flag := library.boolean_target other text legal.text native contextValid input.scan.position legal.scan.position
  have callee := library.package_callee other text legal.text native contextValid info input.scan.position legal.scan.position .procedure
  have ordinary := library.basic_body other text legal.text native contextValid input.scan legal.scan
    functions legal.functions procedures legal.procedures
  unfold basicResult
  simp only [first, scalar, flag, callee, ordinary,
    library.function_assignment other text native input info functions procedures legal contextValid typed,
    library.procedure_statement other text native input info functions procedures legal contextValid typed]
  rfl

/-- All Basic imports close on the original complete native domain, including
failed inputs and failed calls. The source-defined state-effect callbacks stay
unchanged on both sides; no source acceptance or semantic-check premise occurs. -/
theorem basic_meaning (library : Libraries) (other : BasicCalls) (text : Source)
    (native : Predicate.Native.Context) (input : ApplicationScan) (info : PackageBindings.Metadata)
    (functions : FunctionBindings.Metadata) (procedures : ProcedureBindings.Metadata)
    (legal : NativeDomain ⟨text, native.model, input, info, functions, procedures⟩)
    (contextValid : Predicate.Native.ValidContext text native) (typed : info.Typed) :
    applicationBasic (library.calls other) text native.model input info functions procedures =
      applicationBasic (SourceSyntax.basicReaders (library.calls other)) text native.model input info functions procedures := by
  unfold applicationBasic
  rw [library.basic_result other text native input info functions procedures legal contextValid typed]

end Silver.ApplicationPackageBodies.BasicImports.Libraries
