module

public import Silver.ApplicationPackageCallContract
public import Silver.ApplicationPackageProcedureReading
public import Silver.ApplicationPackageBodiesBasicReading
public import Silver.PredicateBodyFlowValidity

@[expose] public section

namespace Silver.ApplicationPackageBodies.Recursive
open ApplicationPackages Compose Predicate ApplicationPackageCalls

set_option backward.dsimp.instances true
set_option maxRecDepth 10000
set_option maxHeartbeats 1000000

theorem ScanDomain.token {text : Source} {context : ParseContext} {scan : BodyScan}
    (valid : ScanDomain text context scan) (token : ShellToken) :
    ScanDomain text context (Predicate.bodyToken text scan token) :=
  ⟨bodyToken_bound text scan token valid.position, valid.controls, valid.path, valid.flow⟩

theorem NativeDomain.inheritedBasic {source : Statement.Input} (legal : NativeDomain source) :
    ScanDomain source.text source.context
      (Predicate.basicBody source.text source.context source.input.scan source.catalog source.procedures) := by
  obtain ⟨native, same, valid⟩ := legal.context
  have names : Expressions.ValidNames source.text source.context.names := same ▸ valid.1
  exact ⟨basicBody_bound _ _ _ legal.text names legal.scan.position,
    basicBody_controls _ _ _ legal.scan.controls, basicBody_factsBounded _ _ _ legal.scan.path,
    basic_flowReady _ _ _ legal.functions legal.procedures legal.base legal.scan.flow⟩

theorem ScanDomain.assignment {text : Source} {context : ParseContext} {scan : BodyScan}
    (valid : ScanDomain text context scan) (scalar flag : Nat) (value : CallResult)
    (target : scalar ≤ context.scalarNames.length) (position : value.after ≤ text.length + 1)
    (bounds : value.bounds.Bounded) :
    ScanDomain text context (callAssignmentResult context scan scalar flag value) :=
  ⟨callAssignmentResult_bound context scan scalar flag value _ position,
    callAssignmentResult_controls context scan scalar flag value valid.controls,
    callAssignmentResult_factsBounded context scan scalar flag value valid.path,
    callAssignmentResult_flowReady context scan scalar flag value valid.flow target bounds⟩

/-- The leaf imports retain their existing full-domain interpretations.
Lexical selection and effect recording remain arbitrary here, since neither
can invalidate the native output scan domain. -/
def nativeBasicReaders (calls : BasicCalls) : BasicCalls :=
  {calls with
    scalarTarget := Predicate.scalarTarget
    booleanTarget := Predicate.booleanTarget
    packageCallAt := ApplicationPackageCalls.packageCallAt ApplicationPackageCalls.modelCalls
    callAssignmentResult := Predicate.callAssignmentResult
    bodyToken := fun text _ scan token => Predicate.bodyToken text scan token
    basicBody := fun text context scan functions procedures =>
      Predicate.basicBody text context scan functions procedures}

theorem native_function_scan {calls : BasicCalls} {source : Statement.Input}
    (legal : NativeDomain source) (typed : source.info.Typed) :
    ScanDomain source.text source.context (Basic.functionScan (nativeBasicReaders calls) source) := by
  let called := packageCallAt modelCalls source.text source.context source.input source.info
    (assignmentFirst (nativeBasicReaders calls) source.text source.input) .function
  have result := packageCall_native_contract legal typed
    (assignmentFirst (nativeBasicReaders calls) source.text source.input) .function
  have moved : ScanDomain source.text source.context
      (Statement.atPosition called.result source.input.scan.position).scan :=
    result.1.atPosition legal.scan.position
  have bound : called.value.after ≤ source.text.length + 1 := by
    rw [← packageCall_position]
    exact result.1.position
  exact (moved.assignment _ _ called.value (ScalarExpression.lookup_bound ..) bound result.2.2.2).token (.symbol ";")

theorem native_procedure_scan {calls : BasicCalls} {source : Statement.Input}
    (legal : NativeDomain source) (typed : source.info.Typed) :
    ScanDomain source.text source.context (Basic.procedureScan (nativeBasicReaders calls) source) :=
  (packageCall_native_contract legal typed source.input.scan.position .procedure).1.token (.symbol ";")

theorem native_basicResult_scan {calls : BasicCalls} {source : Statement.Input}
    (legal : NativeDomain source) (typed : source.info.Typed) :
    ScanDomain source.text source.context
      (basicResult (nativeBasicReaders calls) source.text source.context source.input source.info
        source.catalog source.procedures).scan := by
  rw [Basic.basicResult_source_scan (nativeBasicReaders calls) source]
  cases Basic.origin (nativeBasicReaders calls) source with
  | inherited => exact legal.inheritedBasic
  | packageFunction => exact native_function_scan legal typed
  | packageProcedure => exact native_procedure_scan legal typed

private theorem functionAssignment_calls {calls : BasicCalls} {source : Statement.Input}
    (returned : ∀ position kind,
      (calls.packageCallAt source.text source.context source.input source.info position kind).result.allowProcedureCalls =
        source.input.allowProcedureCalls) :
    (functionAssignment calls source.text source.context source.input source.info source.catalog source.procedures).allowProcedureCalls =
      source.input.allowProcedureCalls := by
  unfold functionAssignment
  dsimp only
  split <;> split <;> first | exact returned _ _ | rfl

theorem native_basicResult_calls {calls : BasicCalls} {source : Statement.Input}
    (legal : NativeDomain source) (typed : source.info.Typed) :
    (basicResult (nativeBasicReaders calls) source.text source.context source.input source.info
      source.catalog source.procedures).allowProcedureCalls = source.input.allowProcedureCalls := by
  have returned (position : Nat) (kind : PackageBindings.RoutineKind) :=
    (packageCall_native_contract legal typed position kind).2.2.1
  unfold basicResult
  split
  · exact functionAssignment_calls returned
  · split
    · exact returned _ _
    · rfl

/-- Complete native Basic postconditions, including every rejection result.
All package metadata is allowed within its actual native field/subtype bounds;
no valid-callee or complete-library assumption appears. -/
theorem native_basic_contract {calls : BasicCalls} {source : Statement.Input}
    (legal : NativeDomain source) (typed : source.info.Typed) :
    let result := applicationBasic (nativeBasicReaders calls) source.text source.context source.input source.info
      source.catalog source.procedures
    ScanDomain source.text source.context result.scan ∧ result.count = source.input.count ∧
      result.allowProcedureCalls = source.input.allowProcedureCalls ∧
      (result.scan.position = 0 ∨ source.input.scan.position < result.scan.position) := by
  have valid : ScanDomain source.text source.context
      (applicationBasic (nativeBasicReaders calls) source.text source.context source.input source.info
        source.catalog source.procedures).scan := by
    unfold applicationBasic
    split
    · exact legal.scan.invalid
    · dsimp only
      split
      · exact legal.scan.invalid
      · exact native_basicResult_scan legal typed
  refine ⟨valid, valid.flow.compatible.count.trans legal.scan.flow.compatible.count.symm, ?_, ?_⟩
  · unfold applicationBasic
    split
    · rfl
    · dsimp only
      split
      · rfl
      · exact native_basicResult_calls legal typed
  · by_cases zero : (applicationBasic (nativeBasicReaders calls) source.text source.context source.input source.info
        source.catalog source.procedures).scan.position = 0
    · exact Or.inl zero
    · have accepted := applicationBasic_accepted zero
      exact Or.inr (accepted.2.2.symm ▸ accepted.2.1)

end Silver.ApplicationPackageBodies.Recursive
