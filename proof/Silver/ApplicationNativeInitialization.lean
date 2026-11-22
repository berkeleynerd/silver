module

public import Silver.ApplicationNativeCore

@[expose] public section

/-! Elaboration without an explicit object initializer. Values with no Ada
component default retain arbitrary incoming storage. Record components receive
only the defaults in their native declarations, recursively through active
metadata prefixes; in particular Parser_State is not initialized to Initial_State
or Invalid_State. These equations still require the corresponding native type
declaration checks at the source boundary. -/
namespace Silver.ApplicationNative.Initialization

def scalarBinding (prior : ScalarExpression.Binding) : ScalarExpression.Binding :=
  {prior with qualifierFirst := 0, qualifierAfter := 0}

def booleanBinding (prior : BooleanBindings.Binding) : BooleanBindings.Binding :=
  {prior with qualifierFirst := 0, qualifierAfter := 0, known := false, value := false}

def subtypeBinding (prior : IntegerSubtypes.Binding) : IntegerSubtypes.Binding :=
  {prior with qualifierFirst := 0, qualifierAfter := 0}

def functionFormal (prior : FunctionBindings.Formal) : FunctionBindings.Formal :=
  {prior with typeId := 0}

def procedureFormal (prior : ProcedureBindings.Formal) : ProcedureBindings.Formal :=
  {prior with typeId := 0}

def arrayBinding (prior : ArrayBindings.Binding) : ArrayBindings.Binding :=
  {prior with isBoolean := false, typeId := 0, viewSlot := 0}

def state (prior : Compose.ParserState) : Compose.ParserState :=
  {prior with
    contextFirst := 1
    packageFirst := 0
    packageAfter := 0
    functions := {prior.functions with parameters := prior.functions.parameters.map functionFormal}
    procedures := {prior.procedures with parameters := prior.procedures.parameters.map procedureFormal}
    scalarNames := prior.scalarNames.map scalarBinding
    booleanNames := prior.booleanNames.map booleanBinding
    subtypeNames := {prior.subtypeNames with items := prior.subtypeNames.items.map subtypeBinding}
    arrayNames := {prior.arrayNames with names := prior.arrayNames.names.map arrayBinding}}

def applicationScan (prior : ApplicationPackages.ApplicationScan) : ApplicationPackages.ApplicationScan :=
  {prior with
    allowProcedureCalls := true
    reads := PackageBindings.emptyStateSet
    writes := PackageBindings.emptyStateSet}

/-- This is not `Ty.default`: each changed field has a native component default.
Unlisted types receive no initialization. `Declaration.validType` and
`Declaration.implicitSupported` control the source forms that may use this map. -/
def value : (ty : Ty) → ty.meaning → ty.meaning
  | .state, prior => state prior
  | .functionType, prior => {prior with typeId := 0}
  | .functionFormal, prior => functionFormal prior
  | .procedureFormal, prior => procedureFormal prior
  | .scalarBinding, prior => scalarBinding prior
  | .booleanBinding, prior => booleanBinding prior
  | .subtypeBinding, prior => subtypeBinding prior
  | .routine, _ => ({} : PackageBindings.Routine)
  | .formal, _ => ({} : PackageBindings.Formal)
  | .exportItem, _ => ({} : PackageBindings.ExportDeclaration)
  | .stateDeclaration, _ => ({} : PackageBindings.StateDeclaration)
  | .packageType, _ => ({} : ApplicationPackageNames.PackageTypeResult)
  | .objectResult, _ => ApplicationPackageDeclarations.invalidObject
  | .staticBooleanResult, _ => ⟨0, false⟩
  | .nameSpan, _ => ({} : PackageBindings.NameSpan)
  | .reference, _ => ({} : QualifiedNames.Reference)
  | .appScan, prior => applicationScan prior
  | .appCall, prior => {value := Predicate.invalidCall, result := applicationScan prior.result}
  | _, prior => prior

@[simp] theorem number_arbitrary (prior : Nat) : value .number prior = prior := rfl
@[simp] theorem truth_arbitrary (prior : Bool) : value .truth prior = prior := rfl
@[simp] theorem procedureFormal_partial (prior : ProcedureBindings.Formal) :
    value .procedureFormal prior = {prior with typeId := 0} := rfl
@[simp] theorem state_position_arbitrary (prior : Compose.ParserState) :
    (value .state prior).position = prior.position := rfl
@[simp] theorem state_scalar_count (prior : Compose.ParserState) :
    (value .state prior).scalarNames.length = prior.scalarNames.length := by
  simp [value, state]

end Silver.ApplicationNative.Initialization
