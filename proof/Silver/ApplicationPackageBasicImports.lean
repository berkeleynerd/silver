module

public import Silver.ApplicationPackageInheritedProjection
public import Silver.ApplicationPackageAssignmentResultImports
public import Silver.ApplicationPackageCallComposition
public import Silver.ApplicationPackageBasicSyntax

@[expose] public section

namespace Silver.ApplicationPackageBodies.BasicImports
open Compose Compose.Expressions Predicate ApplicationPackages Recursive

set_option backward.dsimp.instances true

structure Libraries where
  inherited : Inherited.Libraries
  package : ApplicationPackageCalls.SourceLibraries.Libraries

namespace Libraries

/-- Actual inherited dictionaries and the source-interpreted package call.
The state-effect callbacks remain explicit until the enclosing effect join. -/
noncomputable def calls (library : Libraries) (other : BasicCalls) : BasicCalls :=
  {other with
    skipAt := library.inherited.inherited.function .skip
    nameAfter := library.inherited.inherited.function .nameAfter
    takeToken := library.inherited.inherited.function .takeToken
    scalarTarget := library.inherited.projectedScalarTarget
    booleanTarget := library.inherited.projectedBooleanTarget
    packageCallAt := ApplicationPackageCalls.packageCallAt library.package.calls
    callAssignmentResult := library.package.payload.actual.projectedResult
    bodyToken := library.inherited.projectedToken
    basicBody := library.inherited.projectedBasic
    packageCallee := ApplicationPackageCalls.packageCallee library.package.calls}

theorem assignment_first (library : Libraries) (other : BasicCalls) (text : Source)
    (valid : ValidText text) (input : ApplicationScan) (bounded : ValidCursor text input.scan.position) :
    assignmentFirst (library.calls other) text input =
      assignmentFirst (SourceSyntax.basicReaders (library.calls other)) text input := by
  have first := interpreted_skip _ library.inherited.source text valid input.scan.position bounded
  have named := interpreted_name _ library.inherited.source text valid _ (model_skip_valid text _ bounded)
  have taken := interpreted_take _ library.inherited.source text valid
    (Compose.nameAfter text (Compose.skipAt text input.scan.position)) (.symbol ":=")
    (model_name_valid text (Compose.skipAt text input.scan.position)) (by unfold ValidToken; decide)
  change library.inherited.inherited.function .takeToken text
    (library.inherited.inherited.function .nameAfter text
      (library.inherited.inherited.function .skip text input.scan.position)) (.symbol ":=") = _
  rw [first, named, taken]
  rfl

theorem package_callee (library : Libraries) (other : BasicCalls) (text : Source)
    (valid : ValidText text) (native : Predicate.Native.Context)
    (contextValid : Predicate.Native.ValidContext text native) (info : PackageBindings.Metadata)
    (position : Nat) (bounded : ValidCursor text position) (kind : PackageBindings.RoutineKind) :
    (library.calls other).packageCallee text native.model info position kind =
      ApplicationPackageCalls.packageCallee ApplicationPackageCalls.modelCalls text native.model info position kind :=
  ApplicationPackageCalls.LexicalImports.callee library.package.payload.effects library.package.other
    text valid native.model (ApplicationPackageEffects.LookupDomain.of_native contextValid) info position bounded kind

theorem package_call (library : Libraries) (other : BasicCalls) (text : Source)
    (valid : ValidText text) (native : Predicate.Native.Context)
    (contextValid : Predicate.Native.ValidContext text native) (input : ApplicationScan)
    (scanValid : ScanDomain text native.model input.scan) (info : PackageBindings.Metadata) (typed : info.Typed)
    (position : Nat) (bounded : ValidCursor text position) (kind : PackageBindings.RoutineKind) :
    (library.calls other).packageCallAt text native.model input info position kind =
      ApplicationPackageCalls.packageCallAt ApplicationPackageCalls.modelCalls text native.model input info position kind := by
  let scratch : ApplicationNative.Locals := fun ty _ => ty.default
  have checked : library.package.calls.validBody text native.model input.scan = true := by
    rw [library.package.validity_meaning scratch text valid native contextValid input.scan scanValid.storage]
    exact scanValid.body_checked
  exact library.package.call_meaning scratch text valid native contextValid input scanValid.storage checked info typed position bounded kind

theorem scalar_target (library : Libraries) (other : BasicCalls) (text : Source) (valid : ValidText text)
    (native : Predicate.Native.Context) (contextValid : Predicate.Native.ValidContext text native)
    (position : Nat) (bounded : ValidCursor text position) :
    (library.calls other).scalarTarget text native.model position = Predicate.scalarTarget text native.model position :=
  library.inherited.projected_scalar_target text valid native contextValid position bounded

theorem boolean_target (library : Libraries) (other : BasicCalls) (text : Source) (valid : ValidText text)
    (native : Predicate.Native.Context) (contextValid : Predicate.Native.ValidContext text native)
    (position : Nat) (bounded : ValidCursor text position) :
    (library.calls other).booleanTarget text native.model position = Predicate.booleanTarget text native.model position :=
  library.inherited.projected_boolean_target text valid native contextValid position bounded

theorem basic_body (library : Libraries) (other : BasicCalls) (text : Source) (valid : ValidText text)
    (native : Predicate.Native.Context) (contextValid : Predicate.Native.ValidContext text native)
    (scan : BodyScan) (scanValid : ScanDomain text native.model scan)
    (functions : FunctionBindings.Metadata) (functionsValid : FunctionBindings.ValidMetadata text functions)
    (procedures : ProcedureBindings.Metadata) (proceduresValid : ProcedureBindings.ValidMetadata text procedures) :
    (library.calls other).basicBody text native.model scan functions procedures =
      Predicate.basicBody text native.model scan functions procedures :=
  library.inherited.projected_basic text valid native contextValid scan
    ⟨scanValid.position, scanValid.controls, scanValid.path, scanValid.flow⟩
    functions functionsValid procedures proceduresValid

theorem body_token (library : Libraries) (other : BasicCalls) (text : Source) (valid : ValidText text)
    (native : Predicate.Native.Context) (contextValid : Predicate.Native.ValidContext text native)
    (scan : BodyScan) (scanValid : ScanDomain text native.model scan) :
    (library.calls other).bodyToken text native.model scan (.symbol ";") = Predicate.bodyToken text scan (.symbol ";") :=
  library.inherited.projected_token text valid native contextValid scan
    ⟨scanValid.position, scanValid.controls, scanValid.path, scanValid.flow⟩
    (.symbol ";") (by unfold ValidToken; decide) (by trivial)

theorem assignment_result (library : Libraries) (other : BasicCalls)
    (native : Predicate.Native.Context) (scan : BodyScan) (scalar flag : Nat) (value : CallResult)
    (domain : FunctionCallNative.ResultDomain native scan scalar flag value) :
    (library.calls other).callAssignmentResult native.model scan scalar flag value =
      Predicate.callAssignmentResult native.model scan scalar flag value :=
  library.package.payload.actual.projected_result native scan scalar flag value domain

/-- A package call's complete native contract supplies the weaker component
domain of Call_Assignment_Result, even on the rejected-call branch. -/
theorem assignment_domain (text : Source) (native : Predicate.Native.Context)
    (input : ApplicationScan) (info : PackageBindings.Metadata) (typed : info.Typed)
    (functions : FunctionBindings.Metadata) (procedures : ProcedureBindings.Metadata)
    (legal : NativeDomain ⟨text, native.model, input, info, functions, procedures⟩)
    (contextValid : Predicate.Native.ValidContext text native) (position : Nat) :
    let called := ApplicationPackageCalls.packageCallAt ApplicationPackageCalls.modelCalls text native.model input info position .function
    FunctionCallNative.ResultDomain native {called.result.scan with position := input.scan.position}
      (Predicate.scalarTarget text native.model input.scan.position)
      (Predicate.booleanTarget text native.model input.scan.position) called.value := by
  have result := ApplicationPackageCalls.packageCall_native_contract legal typed position .function
  have scalar : Predicate.scalarTarget text native.model input.scan.position ≤ native.scalarNames.length :=
    ScalarExpression.lookup_bound ..
  have flag : Predicate.booleanTarget text native.model input.scan.position ≤ native.booleanNames.length := by
    unfold Predicate.booleanTarget
    dsimp only
    split
    · exact Nat.zero_le _
    · exact BooleanBindings.lookup_bound ..
  have extent : input.count = native.scalarNames.length := legal.scan.flow.compatible.count
  refine ⟨contextValid.2.2.1.1, ?_, contextValid.booleans.1, ?_, result.2.2.2, scalar, ?_, flag⟩
  · intro row member
    exact (contextValid.2.2.1.2 row member).2.2.2.2.1
  · change (ApplicationPackageCalls.packageCallAt ApplicationPackageCalls.modelCalls text native.model input info position .function).result.count ≤ _
    rw [result.2.1, extent]
    exact contextValid.2.2.1.1
  · change Predicate.scalarTarget text native.model input.scan.position ≤
      (ApplicationPackageCalls.packageCallAt ApplicationPackageCalls.modelCalls text native.model input info position .function).result.count
    rw [result.2.1, extent]
    exact scalar

end Libraries
end Silver.ApplicationPackageBodies.BasicImports
