module

public import Silver.ApplicationPackageNames
public import Silver.ApplicationPackageDeclarationsTypes
public import Silver.ApplicationAdmissionModel
public import Silver.ApplicationPackageTypes
public import Silver.ComposeContracts
public import Silver.StaticBooleanModel

@[expose] public section

/-! Feature-local typed source expressions shared by package Names and Frames.
The only parameter is the finite family of typed callee symbols supplied by each
source group. No expression can attach arbitrary tokens to an arbitrary meaning.
Native arithmetic/index/representation legality remains a separate, source-checked
contract obligation. In particular, active-prefix table setters model positive
in-prefix writes and count reductions, not inactive storage or count growth. -/
namespace Silver.ApplicationNative

open Compose

deriving instance DecidableEq for Compose.ShellToken

inductive Ty
  | number | integer | truth | source | spelling | state | metadata | nameSpan
  | packageType | functionType | scalarKind | exportKind | interval
  | scalars | booleans | subtypes | names | scalarBinding | booleanBinding
  | subtypeBinding | nameBinding | hiding | callHiding | functions | procedures | arrays
  | unitKind | unitSpan | routine | exportItem | stateDeclaration | formal | mode
  | token | bundle | unitMap | analysis | charge | specification | bodyResult
  | bodyScan | appScan | appCall | callResult | packageActual | procedureActual | stateSet | activeFlow | parseContext
  | contextClauses | scanResult | bodyStop | path
  | reference | routineKind | functionFormal | procedureFormal | packageActuals | packageSeen | objectResult
  | scalarConstraint | scalarResult | staticBooleanResult
  | conditionResult | arrayTable | arrayBinding
  | arrow (domain codomain : Ty)
  deriving DecidableEq, Repr

@[reducible] def Ty.meaning : Ty → Type
  | .number => Nat | .integer => Int | .truth => Bool | .source => Source | .spelling => String
  | .state => ParserState | .metadata => PackageBindings.Metadata | .nameSpan => PackageBindings.NameSpan
  | .packageType => ApplicationPackageNames.PackageTypeResult | .functionType => FunctionTypeResult
  | .scalarKind => FunctionBindings.ScalarKind | .exportKind => PackageBindings.ExportKind
  | .interval => Integer.Interval | .scalars => ScalarExpression.Environment
  | .booleans => BooleanBindings.Environment | .subtypes => IntegerSubtypes.Environment
  | .names => Bindings.BindingEnvironment | .scalarBinding => ScalarExpression.Binding
  | .booleanBinding => BooleanBindings.Binding | .subtypeBinding => IntegerSubtypes.Binding
  | .nameBinding => Bindings.BindingInfo | .hiding => HiddenMarks | .callHiding => IntegerSubtypes.CallHiding
  | .functions => FunctionBindings.Metadata | .procedures => ProcedureBindings.Metadata
  | .arrays => ArrayBindings.Env | .unitKind => ApplicationUnits.UnitKind
  | .unitSpan => ApplicationUnits.Span | .routine => PackageBindings.Routine
  | .exportItem => PackageBindings.ExportDeclaration | .stateDeclaration => PackageBindings.StateDeclaration
  | .formal => PackageBindings.Formal | .mode => ProcedureBindings.Mode
  | .token => ShellToken | .bundle => ApplicationUnits.Bundle
  | .unitMap => ApplicationUnits.UnitKind → ApplicationUnits.Span
  | .analysis => ApplicationAdmission.AnalysisResult | .charge => ApplicationAdmission.ChargeResult
  | .specification => ApplicationAdmission.SpecificationResult | .bodyResult => ApplicationAdmission.BodyResult
  | .bodyScan => Predicate.BodyScan | .appScan => ApplicationPackages.ApplicationScan
  | .appCall => ApplicationPackages.ApplicationCall | .callResult => Predicate.CallResult
  | .packageActual => ApplicationPackages.PackageActual | .procedureActual => Predicate.ProcedureActualResult
  | .stateSet => PackageBindings.StateSet | .activeFlow => Predicate.ActiveFlow | .parseContext => Predicate.ParseContext
  | .contextClauses => Names.Context | .scanResult => Predicate.ScanResult
  | .bodyStop => Predicate.BodyStop | .path => PathFacts.Context
  | .reference => QualifiedNames.Reference | .routineKind => PackageBindings.RoutineKind
  | .functionFormal => FunctionBindings.Formal | .procedureFormal => ProcedureBindings.Formal
  | .packageActuals => List ApplicationPackages.PackageActual | .packageSeen => List Bool
  | .objectResult => ApplicationPackageDeclarations.ObjectResult
  | .scalarConstraint => Compose.ScalarConstraintResult
  | .conditionResult => Predicate.ConditionResult
  | .arrayTable => ArrayBindings.Table | .arrayBinding => ArrayBindings.Binding
  | .scalarResult => ScalarExpression.Result
  | .staticBooleanResult => BooleanElaboration.Native.Result
  | .arrow a b => a.meaning → b.meaning

def Ty.default : (ty : Ty) → ty.meaning
  | .number => 0 | .integer => 0 | .truth => false | .source => [] | .spelling => ""
  | .state => invalidState | .metadata => {} | .nameSpan => {} | .packageType => {}
  | .functionType => ⟨0, .integer, .empty, 0⟩ | .scalarKind => .integer | .exportKind => .integerSubtype
  | .interval => .empty | .scalars => [] | .booleans => [] | .subtypes => {} | .names => []
  | .scalarBinding => ScalarExpression.emptyBinding | .booleanBinding => {}
  | .subtypeBinding => {} | .nameBinding => {} | .hiding => {} | .callHiding => {}
  | .functions => {} | .procedures => {} | .arrays => {} | .unitKind => .packageSpecification
  | .unitSpan => ⟨1,1⟩ | .routine => {} | .exportItem => {} | .stateDeclaration => {} | .formal => {}
  | .mode => .input | .token => .symbol ";"
  | .bundle => ⟨[], 0, fun _ => ⟨1,1⟩⟩ | .unitMap => fun _ => ⟨1,1⟩
  | .analysis => ApplicationAdmission.invalidAnalysis | .charge => ⟨0,false⟩
  | .specification => ⟨{}, invalidState⟩ | .bodyResult => ⟨{},false⟩
  | .bodyScan => ⟨0,0,0,⟨PathFacts.Context.empty,[]⟩,false,false⟩
  | .appScan => {scan := ⟨0,0,0,⟨PathFacts.Context.empty,[]⟩,false,false⟩}
  | .appCall => {result := {scan := ⟨0,0,0,⟨PathFacts.Context.empty,[]⟩,false,false⟩}}
  | .callResult => Predicate.invalidCall | .packageActual => {} | .procedureActual => Predicate.invalidProcedureActual
  | .stateSet => PackageBindings.emptyStateSet | .activeFlow => ⟨PathFacts.Context.empty,[]⟩
  | .parseContext => {names := [], hasArguments := false}
  | .contextClauses => {} | .scanResult => Predicate.invalidScan
  | .bodyStop => .endOnly | .path => PathFacts.Context.empty
  | .reference => {} | .routineKind => .procedure
  | .functionFormal => FunctionBindings.emptyFormal | .procedureFormal => ProcedureBindings.emptyFormal
  | .packageActuals => List.replicate PackageBindings.maxFormals {}
  | .packageSeen => List.replicate PackageBindings.maxFormals false
  | .objectResult => ApplicationPackageDeclarations.invalidObject
  | .scalarConstraint => ⟨0, .empty⟩
  | .conditionResult => ⟨0, ⟨PathFacts.Context.empty, []⟩, ⟨PathFacts.Context.empty, []⟩⟩
  | .arrayTable => {} | .arrayBinding => ArrayBindings.emptyBinding
  | .scalarResult => ⟨0, .empty, 0, false⟩
  | .staticBooleanResult => ⟨0, false⟩
  | .arrow _ b => fun _ => b.default

inductive Field : Ty → Ty → Type
  | exportInitializerFirst : Field .exportItem .number
  | exportInitializerAfter : Field .exportItem .number
  | routineSpecFirst : Field .routine .number
  | routineSpecAfter : Field .routine .number
  | routineBodyFirst : Field .routine .number
  | routineResultTypeIdentity : Field .routine .number
  | routineSpecResultName : Field .routine .nameSpan
  | routineBodyResultName : Field .routine .nameSpan
  | constraintAfter : Field .scalarConstraint .number
  | constraintBounds : Field .scalarConstraint .interval
  | scalarValueAfter : Field .scalarResult .number
  | scalarValueBounds : Field .scalarResult .interval
  | scalarValueStatic : Field .scalarResult .truth
  | staticAfter : Field .staticBooleanResult .number
  | staticValue : Field .staticBooleanResult .truth
  | routineBodyAfter : Field .routine .number
  | routineMayRead : Field .routine .stateSet
  | routineMayWrite : Field .routine .stateSet
  | routineAssigned : Field .routine .truth
  | contextNames : Field .parseContext .names
  | contextDeclarationCount : Field .parseContext .number
  | contextMaskFirst : Field .parseContext .number
  | contextMaskAfter : Field .parseContext .number
  | contextPure : Field .parseContext .truth
  | contextScalarNames : Field .parseContext .scalars
  | contextBooleanNames : Field .parseContext .booleans
  | objectFrame : Field .objectResult .state
  | objectName : Field .objectResult .nameSpan
  | objectMark : Field .objectResult .packageType
  | objectInitFirst : Field .objectResult .number
  | objectInitAfter : Field .objectResult .number
  | objectInitialBounds : Field .objectResult .interval
  | objectConstantObject : Field .objectResult .truth
  | objectBooleanValue : Field .objectResult .truth
  | referenceFirst : Field .reference .number
  | referenceAfter : Field .reference .number
  | referenceQualifierFirst : Field .reference .number
  | referenceQualifierAfter : Field .reference .number
  | routineKind : Field .routine .routineKind
  | functionFormalFirst : Field .functionFormal .number
  | functionFormalAfter : Field .functionFormal .number
  | functionFormalKind : Field .functionFormal .scalarKind
  | functionFormalBounds : Field .functionFormal .interval
  | functionFormalTypeId : Field .functionFormal .number
  | procedureFormalFirst : Field .procedureFormal .number
  | procedureFormalAfter : Field .procedureFormal .number
  | procedureFormalKind : Field .procedureFormal .scalarKind
  | procedureFormalBounds : Field .procedureFormal .interval
  | procedureFormalTypeId : Field .procedureFormal .number
  | procedureFormalMode : Field .procedureFormal .mode
  | contextAfter : Field .contextClauses .number
  | contextArgumentsWith : Field .contextClauses .truth
  | scanResultState : Field .scanResult .state
  | scanResultAssigned : Field .scanResult .truth
  | scanResultOutput : Field .scanResult .truth
  | activeFlowPath : Field .activeFlow .path
  | bundlePool : Field .bundle .source
  | bundleUsed : Field .bundle .number
  | bundleUnits : Field .bundle .unitMap
  | infoUnits : Field .metadata .unitMap
  | analysisAccepted : Field .analysis .truth
  | analysisPackageInfo : Field .analysis .metadata
  | analysisMainFunctions : Field .analysis .functions
  | analysisMainProcedures : Field .analysis .procedures
  | analysisUsesArguments : Field .analysis .truth
  | analysisUsesAssignment : Field .analysis .truth
  | analysisUsesOutput : Field .analysis .truth
  | scanPosition : Field .bodyScan .number
  | scanTarget : Field .bodyScan .number
  | scanCapacity : Field .bodyScan .number
  | scanFacts : Field .bodyScan .activeFlow
  | scanAssigned : Field .bodyScan .truth
  | scanOutput : Field .bodyScan .truth
  | applicationScan : Field .appScan .bodyScan
  | applicationAllowProcedureCalls : Field .appScan .truth
  | applicationReads : Field .appScan .stateSet
  | applicationWrites : Field .appScan .stateSet
  | callValue : Field .appCall .callResult
  | callResult : Field .appCall .appScan
  | valueAfter : Field .callResult .number
  | valueKind : Field .callResult .scalarKind
  | valueBounds : Field .callResult .interval
  | actualFirst : Field .packageActual .number
  | actualAfter : Field .packageActual .number
  | actualTarget : Field .packageActual .procedureActual
  | actualReads : Field .packageActual .stateSet
  | actualWrittenState : Field .packageActual .number
  | targetFirst : Field .procedureActual .number
  | targetAfter : Field .procedureActual .number
  | targetScalar : Field .procedureActual .number
  | targetFlag : Field .procedureActual .number
  | subtypesHiddenCalls : Field .subtypes .callHiding
  | statePosition : Field .state .number
  | stateContextFirst : Field .state .number
  | statePackageFirst : Field .state .number
  | statePackageAfter : Field .state .number
  | stateNames : Field .state .names
  | stateScalarNames : Field .state .scalars
  | stateBooleanNames : Field .state .booleans
  | stateSubtypeNames : Field .state .subtypes
  | stateArrayNames : Field .state .arrays
  | stateFunctions : Field .state .functions
  | stateProcedures : Field .state .procedures
  | statePure : Field .state .truth
  | stateHiding : Field .state .hiding
  | stateDynamicFirst : Field .state .number
  | stateDynamicAfter : Field .state .number
  | stateTarget : Field .state .number
  | stateCapacity : Field .state .number
  | stateFirstParameter : Field .state .number
  | stateFirstProcedureParameter : Field .state .number
  | stateAssignedInFunctions : Field .state .truth
  | infoNameFirst : Field .metadata .number
  | infoNameAfter : Field .metadata .number
  | infoBodyNameFirst : Field .metadata .number
  | infoBodyNameAfter : Field .metadata .number
  | infoCompleted : Field .metadata .number
  | infoAssigned : Field .metadata .truth
  | nameFirst : Field .nameSpan .number
  | nameAfter : Field .nameSpan .number
  | unitFirst : Field .unitSpan .number
  | unitAfter : Field .unitSpan .number
  | markName : Field .packageType .nameSpan
  | markAfter : Field .packageType .number
  | markKind : Field .packageType .scalarKind
  | markBounds : Field .packageType .interval
  | markIdentity : Field .packageType .number
  | typeAfter : Field .functionType .number
  | typeKind : Field .functionType .scalarKind
  | typeBounds : Field .functionType .interval
  | typeTypeId : Field .functionType .number
  | scalarFirst : Field .scalarBinding .number
  | scalarAfter : Field .scalarBinding .number
  | scalarQualifierFirst : Field .scalarBinding .number
  | scalarQualifierAfter : Field .scalarBinding .number
  | scalarBounds : Field .scalarBinding .interval
  | scalarDeclaredBounds : Field .scalarBinding .interval
  | scalarIsStatic : Field .scalarBinding .truth
  | scalarMutable : Field .scalarBinding .truth
  | booleanFirst : Field .booleanBinding .number
  | booleanAfter : Field .booleanBinding .number
  | booleanQualifierFirst : Field .booleanBinding .number
  | booleanQualifierAfter : Field .booleanBinding .number
  | booleanMutable : Field .booleanBinding .truth
  | booleanKnown : Field .booleanBinding .truth
  | booleanValue : Field .booleanBinding .truth
  | subtypeFirst : Field .subtypeBinding .number
  | subtypeAfter : Field .subtypeBinding .number
  | subtypeQualifierFirst : Field .subtypeBinding .number
  | subtypeQualifierAfter : Field .subtypeBinding .number
  | subtypeBounds : Field .subtypeBinding .interval
  | bindingFirst : Field .nameBinding .number
  | bindingAfter : Field .nameBinding .number
  | bindingValueFirst : Field .nameBinding .number
  | bindingStaticLength : Field .nameBinding .number
  | bindingDynamic : Field .nameBinding .truth
  | bindingMutable : Field .nameBinding .truth
  | bindingIsCharacter : Field .nameBinding .truth
  | bindingFirstIndex : Field .nameBinding .integer
  | bindingLastIndex : Field .nameBinding .integer
  | lower : Field .interval .integer
  | upper : Field .interval .integer
  | exportName : Field .exportItem .nameSpan
  | exportKind : Field .exportItem .exportKind
  | exportBounds : Field .exportItem .interval
  | exportTypeName : Field .exportItem .nameSpan
  | exportTypeIdentity : Field .exportItem .number
  | exportBooleanValue : Field .exportItem .truth
  | declarationName : Field .stateDeclaration .nameSpan
  | declarationKind : Field .stateDeclaration .scalarKind
  | declarationDeclaredBounds : Field .stateDeclaration .interval
  | declarationInitialBounds : Field .stateDeclaration .interval
  | routineSpecName : Field .routine .nameSpan
  | routineBodyName : Field .routine .nameSpan
  | routineFormalFirst : Field .routine .number
  | routineFormalCount : Field .routine .number
  | routineResultKind : Field .routine .scalarKind
  | routineResultBounds : Field .routine .interval
  | formalSpecName : Field .formal .nameSpan
  | formalBodyName : Field .formal .nameSpan
  | formalSpecTypeName : Field .formal .nameSpan
  | formalBodyTypeName : Field .formal .nameSpan
  | formalKind : Field .formal .scalarKind
  | formalBounds : Field .formal .interval
  | formalTypeIdentity : Field .formal .number
  | formalMode : Field .formal .mode
  | subtypesTrueHidden : Field .subtypes .truth
  | subtypesFalseHidden : Field .subtypes .truth
  | scalarCount : Field .scalars .number
  | booleanCount : Field .booleans .number
  | subtypeCount : Field .subtypes .number
  | nameCount : Field .names .number
  | exportCount : Field .metadata .number
  | stateCount : Field .metadata .number
  | routineCount : Field .metadata .number
  | parameterCount : Field .metadata .number
  | functionParameterCount : Field .functions .number
  | procedureParameterCount : Field .procedures .number

def Field.name : Field a b → String
  | .exportInitializerFirst => "initializer_first"
  | .exportInitializerAfter => "initializer_after"
  | .routineSpecFirst => "spec_first"
  | .routineSpecAfter => "spec_after"
  | .routineBodyFirst => "body_first"
  | .routineResultTypeIdentity => "result_type_identity"
  | .routineSpecResultName => "spec_result_name"
  | .routineBodyResultName => "body_result_name"
  | .constraintAfter => "after"
  | .constraintBounds => "bounds"
  | .scalarValueAfter => "after"
  | .scalarValueBounds => "bounds"
  | .scalarValueStatic => "static"
  | .staticAfter => "after"
  | .staticValue => "value"
  | .routineBodyAfter => "body_after"
  | .routineMayRead => "may_read"
  | .routineMayWrite => "may_write"
  | .routineAssigned => "assigned"
  | .contextNames => "names"
  | .contextDeclarationCount => "declaration_count"
  | .contextMaskFirst => "mask_first"
  | .contextMaskAfter => "mask_after"
  | .contextPure => "pure"
  | .contextScalarNames => "scalar_names"
  | .contextBooleanNames => "boolean_names"
  | .objectFrame => "frame"
  | .objectName => "name"
  | .objectMark => "mark"
  | .objectInitFirst => "init_first"
  | .objectInitAfter => "init_after"
  | .objectInitialBounds => "initial_bounds"
  | .objectConstantObject => "constant_object"
  | .objectBooleanValue => "boolean_value"
  | .referenceFirst => "first"
  | .referenceAfter => "after"
  | .referenceQualifierFirst => "qualifier_first"
  | .referenceQualifierAfter => "qualifier_after"
  | .routineKind => "kind"
  | .functionFormalFirst => "first"
  | .functionFormalAfter => "after"
  | .functionFormalKind => "kind"
  | .functionFormalBounds => "bounds"
  | .functionFormalTypeId => "type_id"
  | .procedureFormalFirst => "first"
  | .procedureFormalAfter => "after"
  | .procedureFormalKind => "kind"
  | .procedureFormalBounds => "bounds"
  | .procedureFormalTypeId => "type_id"
  | .procedureFormalMode => "mode"
  | .contextAfter => "after"
  | .contextArgumentsWith => "arguments_with"
  | .scanResultState => "state"
  | .scanResultAssigned => "assigned"
  | .scanResultOutput => "output"
  | .activeFlowPath => "path"
  | .bundlePool => "pool"
  | .bundleUsed => "used"
  | .bundleUnits => "units"
  | .infoUnits => "units"
  | .analysisAccepted => "accepted"
  | .analysisPackageInfo => "package_info"
  | .analysisMainFunctions => "main_functions"
  | .analysisMainProcedures => "main_procedures"
  | .analysisUsesArguments => "uses_arguments"
  | .analysisUsesAssignment => "uses_assignment"
  | .analysisUsesOutput => "uses_output"
  | .scanPosition => "position"
  | .scanTarget => "target"
  | .scanCapacity => "capacity"
  | .scanFacts => "facts"
  | .scanAssigned => "assigned"
  | .scanOutput => "output"
  | .applicationScan => "scan"
  | .applicationAllowProcedureCalls => "allow_procedure_calls"
  | .applicationReads => "reads"
  | .applicationWrites => "writes"
  | .callValue => "value"
  | .callResult => "result"
  | .valueAfter => "after"
  | .valueKind => "kind"
  | .valueBounds => "bounds"
  | .actualFirst => "first"
  | .actualAfter => "after"
  | .actualTarget => "target"
  | .actualReads => "reads"
  | .actualWrittenState => "written_state"
  | .targetFirst => "first"
  | .targetAfter => "after"
  | .targetScalar => "scalar"
  | .targetFlag => "flag"
  | .subtypesHiddenCalls => "hidden_calls"
  | .statePosition => "position"
  | .stateContextFirst => "context_first"
  | .statePackageFirst => "package_first"
  | .statePackageAfter => "package_after"
  | .stateNames => "names"
  | .stateScalarNames => "scalar_names"
  | .stateBooleanNames => "boolean_names"
  | .stateSubtypeNames => "subtype_names"
  | .stateArrayNames => "array_names"
  | .stateFunctions => "functions"
  | .stateProcedures => "procedures"
  | .statePure => "pure"
  | .stateHiding => "hiding"
  | .stateDynamicFirst => "dynamic_first"
  | .stateDynamicAfter => "dynamic_after"
  | .stateTarget => "target"
  | .stateCapacity => "capacity"
  | .stateFirstParameter => "first_parameter"
  | .stateFirstProcedureParameter => "first_procedure_parameter"
  | .stateAssignedInFunctions => "assigned_in_functions"
  | .infoNameFirst => "name_first"
  | .infoNameAfter => "name_after"
  | .infoBodyNameFirst => "body_name_first"
  | .infoBodyNameAfter => "body_name_after"
  | .infoCompleted => "completed"
  | .infoAssigned => "assigned"
  | .nameFirst => "first"
  | .nameAfter => "after"
  | .unitFirst => "first"
  | .unitAfter => "after"
  | .markName => "name"
  | .markAfter => "after"
  | .markKind => "kind"
  | .markBounds => "bounds"
  | .markIdentity => "identity"
  | .typeAfter => "after"
  | .typeKind => "kind"
  | .typeBounds => "bounds"
  | .typeTypeId => "type_id"
  | .scalarFirst => "first"
  | .scalarAfter => "after"
  | .scalarQualifierFirst => "qualifier_first"
  | .scalarQualifierAfter => "qualifier_after"
  | .scalarBounds => "bounds"
  | .scalarDeclaredBounds => "declared_bounds"
  | .scalarIsStatic => "is_static"
  | .scalarMutable => "mutable"
  | .booleanFirst => "first"
  | .booleanAfter => "after"
  | .booleanQualifierFirst => "qualifier_first"
  | .booleanQualifierAfter => "qualifier_after"
  | .booleanMutable => "mutable"
  | .booleanKnown => "known"
  | .booleanValue => "value"
  | .subtypeFirst => "first"
  | .subtypeAfter => "after"
  | .subtypeQualifierFirst => "qualifier_first"
  | .subtypeQualifierAfter => "qualifier_after"
  | .subtypeBounds => "bounds"
  | .bindingFirst => "first"
  | .bindingAfter => "after"
  | .bindingValueFirst => "value_first"
  | .bindingStaticLength => "static_length"
  | .bindingDynamic => "dynamic"
  | .bindingMutable => "mutable"
  | .bindingIsCharacter => "is_character"
  | .bindingFirstIndex => "first_index"
  | .bindingLastIndex => "last_index"
  | .lower => "lower"
  | .upper => "upper"
  | .exportName => "name"
  | .exportKind => "kind"
  | .exportBounds => "bounds"
  | .exportTypeName => "type_name"
  | .exportTypeIdentity => "type_identity"
  | .exportBooleanValue => "boolean_value"
  | .declarationName => "name"
  | .declarationKind => "kind"
  | .declarationDeclaredBounds => "declared_bounds"
  | .declarationInitialBounds => "initial_bounds"
  | .routineSpecName => "spec_name"
  | .routineBodyName => "body_name"
  | .routineFormalFirst => "formal_first"
  | .routineFormalCount => "count"
  | .routineResultKind => "result_kind"
  | .routineResultBounds => "result_bounds"
  | .formalSpecName => "spec_name"
  | .formalBodyName => "body_name"
  | .formalSpecTypeName => "spec_type_name"
  | .formalBodyTypeName => "body_type_name"
  | .formalKind => "kind"
  | .formalBounds => "bounds"
  | .formalTypeIdentity => "type_identity"
  | .formalMode => "mode"
  | .subtypesTrueHidden => "true_hidden"
  | .subtypesFalseHidden => "false_hidden"
  | .scalarCount => "count"
  | .booleanCount => "count"
  | .subtypeCount => "count"
  | .nameCount => "count"
  | .exportCount => "export_count"
  | .stateCount => "state_count"
  | .routineCount => "routine_count"
  | .parameterCount => "parameter_count"
  | .functionParameterCount => "parameter_count"
  | .procedureParameterCount => "parameter_count"

def Field.get : Field a b → a.meaning → b.meaning
  | .exportInitializerFirst, value => value.initializerFirst
  | .exportInitializerAfter, value => value.initializerAfter
  | .routineSpecFirst, value => value.specFirst
  | .routineSpecAfter, value => value.specAfter
  | .routineBodyFirst, value => value.bodyFirst
  | .routineResultTypeIdentity, value => value.resultTypeIdentity
  | .routineSpecResultName, value => value.specResultName
  | .routineBodyResultName, value => value.bodyResultName
  | .constraintAfter, value => value.after
  | .constraintBounds, value => value.bounds
  | .scalarValueAfter, value => value.after
  | .scalarValueBounds, value => value.bounds
  | .scalarValueStatic, value => value.isStatic
  | .staticAfter, value => value.after
  | .staticValue, value => value.value
  | .routineBodyAfter, value => value.bodyAfter
  | .routineMayRead, value => value.mayRead
  | .routineMayWrite, value => value.mayWrite
  | .routineAssigned, value => value.assigned
  | .contextNames, value => value.names
  | .contextDeclarationCount, value => value.declarationCount
  | .contextMaskFirst, value => value.maskFirst
  | .contextMaskAfter, value => value.maskAfter
  | .contextPure, value => value.pure
  | .contextScalarNames, value => value.scalarNames
  | .contextBooleanNames, value => value.booleanNames
  | .objectFrame, value => value.frame
  | .objectName, value => value.name
  | .objectMark, value => value.mark
  | .objectInitFirst, value => value.initFirst
  | .objectInitAfter, value => value.initAfter
  | .objectInitialBounds, value => value.initialBounds
  | .objectConstantObject, value => value.constantObject
  | .objectBooleanValue, value => value.booleanValue
  | .referenceFirst, value => value.first
  | .referenceAfter, value => value.after
  | .referenceQualifierFirst, value => value.qualifierFirst
  | .referenceQualifierAfter, value => value.qualifierAfter
  | .routineKind, value => value.kind
  | .functionFormalFirst, value => value.first
  | .functionFormalAfter, value => value.after
  | .functionFormalKind, value => value.kind
  | .functionFormalBounds, value => value.bounds
  | .functionFormalTypeId, value => value.typeId
  | .procedureFormalFirst, value => value.first
  | .procedureFormalAfter, value => value.after
  | .procedureFormalKind, value => value.kind
  | .procedureFormalBounds, value => value.bounds
  | .procedureFormalTypeId, value => value.typeId
  | .procedureFormalMode, value => value.mode
  | .contextAfter, value => value.after
  | .contextArgumentsWith, value => value.argumentsWith
  | .scanResultState, value => value.state
  | .scanResultAssigned, value => value.assigned
  | .scanResultOutput, value => value.output
  | .activeFlowPath, value => value.path
  | .bundlePool, value => value.pool
  | .bundleUsed, value => value.used
  | .bundleUnits, value => value.units
  | .infoUnits, value => value.units
  | .analysisAccepted, value => value.accepted
  | .analysisPackageInfo, value => value.packageInfo
  | .analysisMainFunctions, value => value.mainFunctions
  | .analysisMainProcedures, value => value.mainProcedures
  | .analysisUsesArguments, value => value.usesArguments
  | .analysisUsesAssignment, value => value.usesAssignment
  | .analysisUsesOutput, value => value.usesOutput
  | .scanPosition, value => value.position
  | .scanTarget, value => value.target
  | .scanCapacity, value => value.capacity
  | .scanFacts, value => value.facts
  | .scanAssigned, value => value.assigned
  | .scanOutput, value => value.output
  | .applicationScan, value => value.scan
  | .applicationAllowProcedureCalls, value => value.allowProcedureCalls
  | .applicationReads, value => value.reads
  | .applicationWrites, value => value.writes
  | .callValue, value => value.value
  | .callResult, value => value.result
  | .valueAfter, value => value.after
  | .valueKind, value => value.kind
  | .valueBounds, value => value.bounds
  | .actualFirst, value => value.first
  | .actualAfter, value => value.after
  | .actualTarget, value => value.target
  | .actualReads, value => value.reads
  | .actualWrittenState, value => value.writtenState
  | .targetFirst, value => value.first
  | .targetAfter, value => value.after
  | .targetScalar, value => value.scalar
  | .targetFlag, value => value.flag
  | .subtypesHiddenCalls, value => value.hiddenCalls
  | .statePosition, value => value.position
  | .stateContextFirst, value => value.contextFirst
  | .statePackageFirst, value => value.packageFirst
  | .statePackageAfter, value => value.packageAfter
  | .stateNames, value => value.names
  | .stateScalarNames, value => value.scalarNames
  | .stateBooleanNames, value => value.booleanNames
  | .stateSubtypeNames, value => value.subtypeNames
  | .stateArrayNames, value => value.arrayNames
  | .stateFunctions, value => value.functions
  | .stateProcedures, value => value.procedures
  | .statePure, value => value.pure
  | .stateHiding, value => value.hiding
  | .stateDynamicFirst, value => value.dynamicFirst
  | .stateDynamicAfter, value => value.dynamicAfter
  | .stateTarget, value => value.target
  | .stateCapacity, value => value.capacity
  | .stateFirstParameter, value => value.firstParameter
  | .stateFirstProcedureParameter, value => value.firstProcedureParameter
  | .stateAssignedInFunctions, value => value.assignedInFunctions
  | .infoNameFirst, value => value.nameFirst
  | .infoNameAfter, value => value.nameAfter
  | .infoBodyNameFirst, value => value.bodyNameFirst
  | .infoBodyNameAfter, value => value.bodyNameAfter
  | .infoCompleted, value => value.completed
  | .infoAssigned, value => value.assigned
  | .nameFirst, value => value.first
  | .nameAfter, value => value.after
  | .unitFirst, value => value.first
  | .unitAfter, value => value.after
  | .markName, value => value.name
  | .markAfter, value => value.after
  | .markKind, value => value.kind
  | .markBounds, value => value.bounds
  | .markIdentity, value => value.identity
  | .typeAfter, value => value.after
  | .typeKind, value => value.kind
  | .typeBounds, value => value.bounds
  | .typeTypeId, value => value.typeId
  | .scalarFirst, value => value.first
  | .scalarAfter, value => value.after
  | .scalarQualifierFirst, value => value.qualifierFirst
  | .scalarQualifierAfter, value => value.qualifierAfter
  | .scalarBounds, value => value.bounds
  | .scalarDeclaredBounds, value => value.declaredBounds
  | .scalarIsStatic, value => value.isStatic
  | .scalarMutable, value => value.mutable
  | .booleanFirst, value => value.first
  | .booleanAfter, value => value.after
  | .booleanQualifierFirst, value => value.qualifierFirst
  | .booleanQualifierAfter, value => value.qualifierAfter
  | .booleanMutable, value => value.mutable
  | .booleanKnown, value => value.known
  | .booleanValue, value => value.value
  | .subtypeFirst, value => value.first
  | .subtypeAfter, value => value.after
  | .subtypeQualifierFirst, value => value.qualifierFirst
  | .subtypeQualifierAfter, value => value.qualifierAfter
  | .subtypeBounds, value => value.bounds
  | .bindingFirst, value => value.first
  | .bindingAfter, value => value.after
  | .bindingValueFirst, value => value.valueFirst
  | .bindingStaticLength, value => value.staticLength
  | .bindingDynamic, value => value.dynamic
  | .bindingMutable, value => value.mutable
  | .bindingIsCharacter, value => value.isCharacter
  | .bindingFirstIndex, value => value.firstIndex
  | .bindingLastIndex, value => value.lastIndex
  | .lower, value => value.lower
  | .upper, value => value.upper
  | .exportName, value => value.name
  | .exportKind, value => value.kind
  | .exportBounds, value => value.bounds
  | .exportTypeName, value => value.typeName
  | .exportTypeIdentity, value => value.typeIdentity
  | .exportBooleanValue, value => value.booleanValue
  | .declarationName, value => value.name
  | .declarationKind, value => value.kind
  | .declarationDeclaredBounds, value => value.declaredBounds
  | .declarationInitialBounds, value => value.initialBounds
  | .routineSpecName, value => value.specName
  | .routineBodyName, value => value.bodyName
  | .routineFormalFirst, value => value.formalFirst
  | .routineFormalCount, value => value.count
  | .routineResultKind, value => value.resultKind
  | .routineResultBounds, value => value.resultBounds
  | .formalSpecName, value => value.specName
  | .formalBodyName, value => value.bodyName
  | .formalSpecTypeName, value => value.specTypeName
  | .formalBodyTypeName, value => value.bodyTypeName
  | .formalKind, value => value.kind
  | .formalBounds, value => value.bounds
  | .formalTypeIdentity, value => value.typeIdentity
  | .formalMode, value => value.mode
  | .subtypesTrueHidden, value => value.trueHidden
  | .subtypesFalseHidden, value => value.falseHidden
  | .scalarCount, value => value.length
  | .booleanCount, value => value.length
  | .subtypeCount, value => value.items.length
  | .nameCount, value => value.length
  | .exportCount, value => value.exports.length
  | .stateCount, value => value.states.length
  | .routineCount, value => value.routines.length
  | .parameterCount, value => value.parameters.length
  | .functionParameterCount, value => value.parameters.length
  | .procedureParameterCount, value => value.parameters.length

/-- Count assignments retain a prefix. Callers prove the assigned count does
not exceed the current active count; increasing native storage needs a richer
representation and is deliberately not justified by this projection. -/
def Field.set : Field a b → a.meaning → b.meaning → a.meaning
  | .exportInitializerFirst, value, item => {value with initializerFirst := item}
  | .exportInitializerAfter, value, item => {value with initializerAfter := item}
  | .routineSpecFirst, value, item => {value with specFirst := item}
  | .routineSpecAfter, value, item => {value with specAfter := item}
  | .routineBodyFirst, value, item => {value with bodyFirst := item}
  | .routineResultTypeIdentity, value, item => {value with resultTypeIdentity := item}
  | .routineSpecResultName, value, item => {value with specResultName := item}
  | .routineBodyResultName, value, item => {value with bodyResultName := item}
  | .constraintAfter, value, item => {value with after := item}
  | .constraintBounds, value, item => {value with bounds := item}
  | .scalarValueAfter, value, item => {value with after := item}
  | .scalarValueBounds, value, item => {value with bounds := item}
  | .scalarValueStatic, value, item => {value with isStatic := item}
  | .staticAfter, value, item => {value with after := item}
  | .staticValue, value, item => {value with value := item}
  | .routineBodyAfter, value, item => {value with bodyAfter := item}
  | .routineMayRead, value, item => {value with mayRead := item}
  | .routineMayWrite, value, item => {value with mayWrite := item}
  | .routineAssigned, value, item => {value with assigned := item}
  | .contextNames, value, item => {value with names := item}
  | .contextDeclarationCount, value, item => {value with declarationCount := item}
  | .contextMaskFirst, value, item => {value with maskFirst := item}
  | .contextMaskAfter, value, item => {value with maskAfter := item}
  | .contextPure, value, item => {value with pure := item}
  | .contextScalarNames, value, item => {value with scalarNames := item}
  | .contextBooleanNames, value, item => {value with booleanNames := item}
  | .objectFrame, value, item => {value with frame := item}
  | .objectName, value, item => {value with name := item}
  | .objectMark, value, item => {value with mark := item}
  | .objectInitFirst, value, item => {value with initFirst := item}
  | .objectInitAfter, value, item => {value with initAfter := item}
  | .objectInitialBounds, value, item => {value with initialBounds := item}
  | .objectConstantObject, value, item => {value with constantObject := item}
  | .objectBooleanValue, value, item => {value with booleanValue := item}
  | .referenceFirst, value, item => {value with first := item}
  | .referenceAfter, value, item => {value with after := item}
  | .referenceQualifierFirst, value, item => {value with qualifierFirst := item}
  | .referenceQualifierAfter, value, item => {value with qualifierAfter := item}
  | .routineKind, value, item => {value with kind := item}
  | .functionFormalFirst, value, item => {value with first := item}
  | .functionFormalAfter, value, item => {value with after := item}
  | .functionFormalKind, value, item => {value with kind := item}
  | .functionFormalBounds, value, item => {value with bounds := item}
  | .functionFormalTypeId, value, item => {value with typeId := item}
  | .procedureFormalFirst, value, item => {value with first := item}
  | .procedureFormalAfter, value, item => {value with after := item}
  | .procedureFormalKind, value, item => {value with kind := item}
  | .procedureFormalBounds, value, item => {value with bounds := item}
  | .procedureFormalTypeId, value, item => {value with typeId := item}
  | .procedureFormalMode, value, item => {value with mode := item}
  | .contextAfter, value, item => {value with after := item}
  | .contextArgumentsWith, value, item => {value with argumentsWith := item}
  | .scanResultState, value, item => {value with state := item}
  | .scanResultAssigned, value, item => {value with assigned := item}
  | .scanResultOutput, value, item => {value with output := item}
  | .activeFlowPath, value, item => {value with path := item}
  | .bundlePool, value, item => {value with pool := item}
  | .bundleUsed, value, item => {value with used := item}
  | .bundleUnits, value, item => {value with units := item}
  | .infoUnits, value, item => {value with units := item}
  | .analysisAccepted, value, item => {value with accepted := item}
  | .analysisPackageInfo, value, item => {value with packageInfo := item}
  | .analysisMainFunctions, value, item => {value with mainFunctions := item}
  | .analysisMainProcedures, value, item => {value with mainProcedures := item}
  | .analysisUsesArguments, value, item => {value with usesArguments := item}
  | .analysisUsesAssignment, value, item => {value with usesAssignment := item}
  | .analysisUsesOutput, value, item => {value with usesOutput := item}
  | .scanPosition, value, item => {value with position := item}
  | .scanTarget, value, item => {value with target := item}
  | .scanCapacity, value, item => {value with capacity := item}
  | .scanFacts, value, item => {value with facts := item}
  | .scanAssigned, value, item => {value with assigned := item}
  | .scanOutput, value, item => {value with output := item}
  | .applicationScan, value, item => {value with scan := item}
  | .applicationAllowProcedureCalls, value, item => {value with allowProcedureCalls := item}
  | .applicationReads, value, item => {value with reads := item}
  | .applicationWrites, value, item => {value with writes := item}
  | .callValue, value, item => {value with value := item}
  | .callResult, value, item => {value with result := item}
  | .valueAfter, value, item => {value with after := item}
  | .valueKind, value, item => {value with kind := item}
  | .valueBounds, value, item => {value with bounds := item}
  | .actualFirst, value, item => {value with first := item}
  | .actualAfter, value, item => {value with after := item}
  | .actualTarget, value, item => {value with target := item}
  | .actualReads, value, item => {value with reads := item}
  | .actualWrittenState, value, item => {value with writtenState := item}
  | .targetFirst, value, item => {value with first := item}
  | .targetAfter, value, item => {value with after := item}
  | .targetScalar, value, item => {value with scalar := item}
  | .targetFlag, value, item => {value with flag := item}
  | .subtypesHiddenCalls, value, item => {value with hiddenCalls := item}
  | .statePosition, value, item => {value with position := item}
  | .stateContextFirst, value, item => {value with contextFirst := item}
  | .statePackageFirst, value, item => {value with packageFirst := item}
  | .statePackageAfter, value, item => {value with packageAfter := item}
  | .stateNames, value, item => {value with names := item}
  | .stateScalarNames, value, item => {value with scalarNames := item}
  | .stateBooleanNames, value, item => {value with booleanNames := item}
  | .stateSubtypeNames, value, item => {value with subtypeNames := item}
  | .stateArrayNames, value, item => {value with arrayNames := item}
  | .stateFunctions, value, item => {value with functions := item}
  | .stateProcedures, value, item => {value with procedures := item}
  | .statePure, value, item => {value with pure := item}
  | .stateHiding, value, item => {value with «hiding» := item}
  | .stateDynamicFirst, value, item => {value with dynamicFirst := item}
  | .stateDynamicAfter, value, item => {value with dynamicAfter := item}
  | .stateTarget, value, item => {value with target := item}
  | .stateCapacity, value, item => {value with capacity := item}
  | .stateFirstParameter, value, item => {value with firstParameter := item}
  | .stateFirstProcedureParameter, value, item => {value with firstProcedureParameter := item}
  | .stateAssignedInFunctions, value, item => {value with assignedInFunctions := item}
  | .infoNameFirst, value, item => {value with nameFirst := item}
  | .infoNameAfter, value, item => {value with nameAfter := item}
  | .infoBodyNameFirst, value, item => {value with bodyNameFirst := item}
  | .infoBodyNameAfter, value, item => {value with bodyNameAfter := item}
  | .infoCompleted, value, item => {value with completed := item}
  | .infoAssigned, value, item => {value with assigned := item}
  | .nameFirst, value, item => {value with first := item}
  | .nameAfter, value, item => {value with after := item}
  | .unitFirst, value, item => {value with first := item}
  | .unitAfter, value, item => {value with after := item}
  | .markName, value, item => {value with name := item}
  | .markAfter, value, item => {value with after := item}
  | .markKind, value, item => {value with kind := item}
  | .markBounds, value, item => {value with bounds := item}
  | .markIdentity, value, item => {value with identity := item}
  | .typeAfter, value, item => {value with after := item}
  | .typeKind, value, item => {value with kind := item}
  | .typeBounds, value, item => {value with bounds := item}
  | .typeTypeId, value, item => {value with typeId := item}
  | .scalarFirst, value, item => {value with first := item}
  | .scalarAfter, value, item => {value with after := item}
  | .scalarQualifierFirst, value, item => {value with qualifierFirst := item}
  | .scalarQualifierAfter, value, item => {value with qualifierAfter := item}
  | .scalarBounds, value, item => {value with bounds := item}
  | .scalarDeclaredBounds, value, item => {value with declaredBounds := item}
  | .scalarIsStatic, value, item => {value with isStatic := item}
  | .scalarMutable, value, item => {value with mutable := item}
  | .booleanFirst, value, item => {value with first := item}
  | .booleanAfter, value, item => {value with after := item}
  | .booleanQualifierFirst, value, item => {value with qualifierFirst := item}
  | .booleanQualifierAfter, value, item => {value with qualifierAfter := item}
  | .booleanMutable, value, item => {value with mutable := item}
  | .booleanKnown, value, item => {value with known := item}
  | .booleanValue, value, item => {value with value := item}
  | .subtypeFirst, value, item => {value with first := item}
  | .subtypeAfter, value, item => {value with after := item}
  | .subtypeQualifierFirst, value, item => {value with qualifierFirst := item}
  | .subtypeQualifierAfter, value, item => {value with qualifierAfter := item}
  | .subtypeBounds, value, item => {value with bounds := item}
  | .bindingFirst, value, item => {value with first := item}
  | .bindingAfter, value, item => {value with after := item}
  | .bindingValueFirst, value, item => {value with valueFirst := item}
  | .bindingStaticLength, value, item => {value with staticLength := item}
  | .bindingDynamic, value, item => {value with dynamic := item}
  | .bindingMutable, value, item => {value with mutable := item}
  | .bindingIsCharacter, value, item => {value with isCharacter := item}
  | .bindingFirstIndex, value, item => {value with firstIndex := item}
  | .bindingLastIndex, value, item => {value with lastIndex := item}
  | .lower, value, item => {value with lower := item}
  | .upper, value, item => {value with upper := item}
  | .exportName, value, item => {value with name := item}
  | .exportKind, value, item => {value with kind := item}
  | .exportBounds, value, item => {value with bounds := item}
  | .exportTypeName, value, item => {value with typeName := item}
  | .exportTypeIdentity, value, item => {value with typeIdentity := item}
  | .exportBooleanValue, value, item => {value with booleanValue := item}
  | .declarationName, value, item => {value with name := item}
  | .declarationKind, value, item => {value with kind := item}
  | .declarationDeclaredBounds, value, item => {value with declaredBounds := item}
  | .declarationInitialBounds, value, item => {value with initialBounds := item}
  | .routineSpecName, value, item => {value with specName := item}
  | .routineBodyName, value, item => {value with bodyName := item}
  | .routineFormalFirst, value, item => {value with formalFirst := item}
  | .routineFormalCount, value, item => {value with count := item}
  | .routineResultKind, value, item => {value with resultKind := item}
  | .routineResultBounds, value, item => {value with resultBounds := item}
  | .formalSpecName, value, item => {value with specName := item}
  | .formalBodyName, value, item => {value with bodyName := item}
  | .formalSpecTypeName, value, item => {value with specTypeName := item}
  | .formalBodyTypeName, value, item => {value with bodyTypeName := item}
  | .formalKind, value, item => {value with kind := item}
  | .formalBounds, value, item => {value with bounds := item}
  | .formalTypeIdentity, value, item => {value with typeIdentity := item}
  | .formalMode, value, item => {value with mode := item}
  | .subtypesTrueHidden, value, item => {value with trueHidden := item}
  | .subtypesFalseHidden, value, item => {value with falseHidden := item}
  | .scalarCount, value, count => value.take count
  | .booleanCount, value, count => value.take count
  | .subtypeCount, value, count => {value with items := value.items.take count}
  | .nameCount, value, count => value.take count
  | .exportCount, value, count => {value with exports := value.exports.take count}
  | .stateCount, value, count => {value with states := value.states.take count}
  | .routineCount, value, count => {value with routines := value.routines.take count}
  | .parameterCount, value, count => {value with parameters := value.parameters.take count}
  | .functionParameterCount, value, count => {value with parameters := value.parameters.take count}
  | .procedureParameterCount, value, count => {value with parameters := value.parameters.take count}

/-- Read-only native discriminants and selectors in the supported expressions. -/
inductive Property : Ty → Ty → Type
  | conditionAfter : Property .conditionResult .number
  | conditionTrue : Property .conditionResult .activeFlow
  | conditionFalse : Property .conditionResult .activeFlow
  | contextArrays : Property .parseContext .arrayTable
  | arrayMutable : Property .arrayBinding .truth
  | arrayBoolean : Property .arrayBinding .truth
  | arrayComponentBounds : Property .arrayBinding .interval
  | flowCount : Property .activeFlow .number
  | scanCount : Property .bodyScan .number
  | appScanCount : Property .appScan .number
  | appCallCount : Property .appCall .number

def Property.name : Property a b → String
  | .conditionAfter => "after"
  | .conditionTrue => "when_true"
  | .conditionFalse => "when_false"
  | .contextArrays => "array_names"
  | .arrayMutable => "mutable"
  | .arrayBoolean => "boolean_elements"
  | .arrayComponentBounds => "component_bounds"
  | .flowCount | .scanCount | .appScanCount | .appCallCount => "count"

def Property.get : Property a b → a.meaning → b.meaning
  | .conditionAfter, value => value.after
  | .conditionTrue, value => value.whenTrue
  | .conditionFalse, value => value.whenFalse
  | .contextArrays, value => value.arrayTable
  | .arrayMutable, value => value.mutable
  | .arrayBoolean, value => value.isBoolean
  | .arrayComponentBounds, value => value.componentBounds
  | .flowCount, value => value.count
  | .scanCount, value => value.count
  | .appScanCount, value => value.count
  | .appCallCount, value => value.count

/-- Every indexed selection has a fixed source selector and fixed meaning. -/
inductive Index : Ty → Ty → Ty → Type
  | scalar : Index .scalars .number .scalarBinding
  | boolean : Index .booleans .number .booleanBinding
  | subtype : Index .subtypes .number .subtypeBinding
  | binding : Index .names .number .nameBinding
  | export : Index .metadata .number .exportItem
  | state : Index .metadata .number .stateDeclaration
  | routine : Index .metadata .number .routine
  | formal : Index .metadata .number .formal
  | unit : Index .metadata .unitKind .unitSpan
  | bundleUnit : Index .bundle .unitKind .unitSpan
  | actual : Index .packageActuals .number .packageActual
  | seen : Index .packageSeen .number .truth
  | stateBit : Index .stateSet .number .truth
  | arrayItem : Index .arrayTable .number .arrayBinding
  | flowValue : Index .activeFlow .number .interval

def Index.name : Index a i b → String
  | .scalar | .boolean | .subtype | .binding | .arrayItem => "items"
  | .export => "exports" | .state => "states" | .routine => "routines"
  | .formal => "parameters" | .unit | .bundleUnit => "units"
  | .actual | .seen | .stateBit => ""
  | .flowValue => "values"

/-- Direct native arrays have no record selector before their index. -/
def Index.path (selection : Index a i b) : List String := match selection with
  | .actual | .seen | .stateBit => []
  | _ => [".", selection.name]

def Index.get : Index a i b → a.meaning → i.meaning → b.meaning
  | .scalar, value, index => ScalarExpression.binding value index
  | .boolean, value, index => BooleanBindings.binding value index
  | .subtype, value, index => value.items.getD (index - 1) {}
  | .binding, value, index => value.getD (index - 1) {}
  | .export, value, index => value.exportAt index
  | .state, value, index => value.stateAt index
  | .routine, value, index => value.routineAt index
  | .formal, value, index => value.parameterAt index
  | .unit, value, kind => value.units kind
  | .bundleUnit, value, kind => value.units kind
  | .actual, value, index => value.getD (index - 1) {}
  | .seen, value, index => value.getD (index - 1) false
  | .stateBit, value, index => value.getD (index - 1) false
  | .arrayItem, value, index => ArrayBindings.binding value.items index
  | .flowValue, value, index => value.values.getD (index - 1) .empty

def Index.set : Index a i b → a.meaning → i.meaning → b.meaning → a.meaning
  | .scalar, value, index, item => value.set (index - 1) item
  | .boolean, value, index, item => value.set (index - 1) item
  | .subtype, value, index, item => {value with items := value.items.set (index - 1) item}
  | .binding, value, index, item => value.set (index - 1) item
  | .export, value, index, item => {value with exports := value.exports.set (index - 1) item}
  | .state, value, index, item => {value with states := value.states.set (index - 1) item}
  | .routine, value, index, item => {value with routines := value.routines.set (index - 1) item}
  | .formal, value, index, item => {value with parameters := value.parameters.set (index - 1) item}
  | .unit, value, kind, item => {value with units := fun other => if other = kind then item else value.units other}
  | .bundleUnit, value, kind, item => {value with units := fun other => if other = kind then item else value.units other}
  | .actual, value, index, item => value.set (index - 1) item
  | .seen, value, index, item => value.set (index - 1) item
  | .stateBit, value, index, item => value.set (index - 1) item
  | .arrayItem, value, index, item => {value with items := value.items.set (index - 1) item}
  | .flowValue, value, index, item => {value with values := value.values.set (index - 1) item}

abbrev Locals := (ty : Ty) → String → ty.meaning

def Locals.set (locals : Locals) (ty : Ty) (name : String) (value : ty.meaning) : Locals :=
  fun requested key => if same : ty = requested then
    if key = name then same ▸ value else locals requested key
  else locals requested key

abbrev Calls (Fn : Ty → Type) := (ty : Ty) → Fn ty → ty.meaning
abbrev FunctionNames (Fn : Ty → Type) := {ty : Ty} → Fn ty → List String
abbrev FunctionParameters (Fn : Ty → Type) := {ty : Ty} → Fn ty → List String

/-- The named package record aggregates in declaration readers have complete
native component defaults. Field lists also check coverage for aggregates
without an others association. -/
inductive PackageRecord : Ty → Type
  | routine : PackageRecord .routine
  | formal : PackageRecord .formal
  | exportItem : PackageRecord .exportItem

def PackageRecord.fields : PackageRecord ty → List String
  | .routine => ["kind", "spec_name", "body_name", "spec_first", "spec_after", "body_first",
      "body_after", "formal_first", "count", "result_kind", "result_bounds", "result_type_identity",
      "spec_result_name", "body_result_name", "may_read", "may_write", "assigned"]
  | .formal => ["spec_name", "body_name", "spec_type_name", "body_type_name", "kind", "bounds",
      "type_identity", "mode"]
  | .exportItem => ["name", "kind", "bounds", "type_name", "type_identity",
      "initializer_first", "initializer_after", "boolean_value"]

def PackageRecord.defaults : PackageRecord ty → ty.meaning
  | .routine => ({} : PackageBindings.Routine)
  | .formal => ({} : PackageBindings.Formal)
  | .exportItem => ({} : PackageBindings.ExportDeclaration)

mutual
inductive Expr (Fn : Ty → Type) : Ty → Type
  | token (value : ShellToken) : Expr Fn .token
  | number (value : Nat) : Expr Fn .number
  | integer (value : Int) : Expr Fn .integer
  | truth (value : Bool) : Expr Fn .truth
  | word (value : String) : Expr Fn .spelling
  | scalarKind (value : FunctionBindings.ScalarKind) : Expr Fn .scalarKind
  | exportKind (value : PackageBindings.ExportKind) : Expr Fn .exportKind
  | mode (value : ProcedureBindings.Mode) : Expr Fn .mode
  | unitKind (value : ApplicationUnits.UnitKind) : Expr Fn .unitKind
  | bodyStop (value : Predicate.BodyStop) : Expr Fn .bodyStop
  | routineKind (value : PackageBindings.RoutineKind) : Expr Fn .routineKind
  | emptyActuals : Expr Fn .packageActuals
  | emptySeen : Expr Fn .packageSeen
  | emptyStateSet : Expr Fn .stateSet
  | invalidObject : Expr Fn .objectResult
  | invalidCall : Expr Fn .callResult
  | callValueAggregate : Expr Fn .number → Expr Fn .scalarKind → Expr Fn .interval → Expr Fn .callResult
  | applicationCall : Expr Fn .number → Expr Fn .callResult → Expr Fn .appScan → Expr Fn .appCall
  | stateDeclarationValue : Expr Fn .nameSpan → Expr Fn .scalarKind → Expr Fn .nameSpan →
      Expr Fn .number → Expr Fn .interval → Expr Fn .interval → Expr Fn .number →
      Expr Fn .number → Expr Fn .truth → Expr Fn .stateDeclaration
  | scalarConstraintValue : Expr Fn .number → Expr Fn .interval → Expr Fn .scalarConstraint
  | scalarBindingValue : Expr Fn .number → Expr Fn .number → Expr Fn .interval → Expr Fn .truth →
      Expr Fn .interval → Expr Fn .truth → Expr Fn .number → Expr Fn .number → Expr Fn .scalarBinding
  | booleanBindingValue : Expr Fn .number → Expr Fn .number → Expr Fn .truth → Expr Fn .number →
      Expr Fn .number → Expr Fn .truth → Expr Fn .truth → Expr Fn .booleanBinding
  | functionType : Expr Fn .number → Expr Fn .scalarKind → Expr Fn .interval → Expr Fn .number → Expr Fn .functionType
  | functionFormal : Expr Fn .number → Expr Fn .number → Expr Fn .scalarKind → Expr Fn .interval → Expr Fn .number → Expr Fn .functionFormal
  | procedureFormal : Expr Fn .number → Expr Fn .number → Expr Fn .scalarKind → Expr Fn .interval → Expr Fn .number → Expr Fn .mode → Expr Fn .procedureFormal
  | variable (name : String) : Expr Fn ty
  | function (symbol : Fn ty) : Expr Fn ty
  | app : Expr Fn (.arrow a b) → Expr Fn a → Expr Fn b
  /-- A single conditional or quantified actual may use the enclosing call's
  parentheses. This completed call is deliberately not an application spine. -/
  | soleApp : Fn (.arrow a b) → Expr Fn a → Expr Fn b
  | namedApp (formal : String) : Expr Fn (.arrow a b) → Expr Fn a → Expr Fn b
  | field : Field a b → Expr Fn a → Expr Fn b
  | property : Property a b → Expr Fn a → Expr Fn b
  | index : Index a i b → Expr Fn a → Expr Fn i → Expr Fn b
  | add : Expr Fn .number → Expr Fn .number → Expr Fn .number
  | sub : Expr Fn .number → Expr Fn .number → Expr Fn .number
  | inRange : Expr Fn .number → Expr Fn .number → Expr Fn .number → Expr Fn .truth
  | scalarBindingEq : Expr Fn .scalarBinding → Expr Fn .scalarBinding → Expr Fn .truth
  | intervalEq : Expr Fn .interval → Expr Fn .interval → Expr Fn .truth
  | eq : Expr Fn .number → Expr Fn .number → Expr Fn .truth
  | ne : Expr Fn .number → Expr Fn .number → Expr Fn .truth
  | lt : Expr Fn .number → Expr Fn .number → Expr Fn .truth
  | le : Expr Fn .number → Expr Fn .number → Expr Fn .truth
  | gt : Expr Fn .number → Expr Fn .number → Expr Fn .truth
  | ge : Expr Fn .number → Expr Fn .number → Expr Fn .truth
  | intLe : Expr Fn .integer → Expr Fn .integer → Expr Fn .truth
  | intGe : Expr Fn .integer → Expr Fn .integer → Expr Fn .truth
  | intNe : Expr Fn .integer → Expr Fn .integer → Expr Fn .truth
  | unitMapEq : Expr Fn .unitMap → Expr Fn .unitMap → Expr Fn .truth
  | unitMapNe : Expr Fn .unitMap → Expr Fn .unitMap → Expr Fn .truth
  | nameEq : Expr Fn .nameSpan → Expr Fn .nameSpan → Expr Fn .truth
  | kindEq : Expr Fn .scalarKind → Expr Fn .scalarKind → Expr Fn .truth
  | truthEq : Expr Fn .truth → Expr Fn .truth → Expr Fn .truth
  | truthNe : Expr Fn .truth → Expr Fn .truth → Expr Fn .truth
  | kindNe : Expr Fn .scalarKind → Expr Fn .scalarKind → Expr Fn .truth
  | intervalNe : Expr Fn .interval → Expr Fn .interval → Expr Fn .truth
  | routineEq : Expr Fn .routineKind → Expr Fn .routineKind → Expr Fn .truth
  | exportEq : Expr Fn .exportKind → Expr Fn .exportKind → Expr Fn .truth
  | modeNe : Expr Fn .mode → Expr Fn .mode → Expr Fn .truth
  | modeEq : Expr Fn .mode → Expr Fn .mode → Expr Fn .truth
  | stateSetNe : Expr Fn .stateSet → Expr Fn .stateSet → Expr Fn .truth
  | not : Expr Fn .truth → Expr Fn .truth
  | andThen : Expr Fn .truth → Expr Fn .truth → Expr Fn .truth
  | orElse : Expr Fn .truth → Expr Fn .truth → Expr Fn .truth
  | eagerOr : Expr Fn .truth → Expr Fn .truth → Expr Fn .truth
  | group : Expr Fn ty → Expr Fn ty
  | ite : Expr Fn .truth → Expr Fn ty → Expr Fn ty → Expr Fn ty
  | conditionalTrue : Expr Fn .truth → Expr Fn .truth → Expr Fn .truth
  | scanResult : Expr Fn .state → Expr Fn .truth → Expr Fn .truth → Expr Fn .scanResult
  | analysisValue : Expr Fn .truth → Expr Fn .metadata → Expr Fn .functions → Expr Fn .procedures →
      Expr Fn .truth → Expr Fn .truth → Expr Fn .truth → Expr Fn .analysis
  | elsif : Expr Fn .truth → Expr Fn ty → Expr Fn ty → Expr Fn ty
  /-- ParseContext retains exactly whether the native Dynamic_First is nonzero. -/
  | contextHasDynamic : Expr Fn .parseContext → Expr Fn .truth
  | flowValuesFirst : Expr Fn .activeFlow → Expr Fn .number
  | intervalValue : Expr Fn .integer → Expr Fn .integer → Expr Fn .interval
  | sourceLast : Expr Fn .source → Expr Fn .number
  | sourceLength : Expr Fn .source → Expr Fn .number
  | sourcePrefix : Expr Fn .source → Expr Fn .number → Expr Fn .source
  | maxConcatenations : Expr Fn .number
  | emptyMetadata : Expr Fn .metadata
  | invalidAnalysis : Expr Fn .analysis
  | nameSpan : Expr Fn .number → Expr Fn .number → Expr Fn .nameSpan
  | packageType : Expr Fn .nameSpan → Expr Fn .number → Expr Fn .scalarKind →
      Expr Fn .interval → Expr Fn .number → Expr Fn .packageType
  | full : Expr Fn .interval
  | empty : Expr Fn .interval
  | invalidType : Expr Fn .packageType
  | invalidState : Expr Fn .state
  | noHidden : Expr Fn .hiding
  | noCalls : Expr Fn .callHiding
  | booleanType : Expr Fn .number
  | integerType : Expr Fn .number
  | forAll (name : String) : Expr Fn .number → Expr Fn .number → Expr Fn .truth → Expr Fn .truth
  | forSome (name : String) : Expr Fn .number → Expr Fn .number → Expr Fn .truth → Expr Fn .truth
  | forAllStates (name : String) : Expr Fn .truth → Expr Fn .truth
  | forAllFlowValues (name : String) : Expr Fn .activeFlow → Expr Fn .truth → Expr Fn .truth
  /-- Package_Actual_Array uses its declared fixed range, never an active prefix. -/
  | forAllActuals (name : String) : Expr Fn .packageActuals → Expr Fn .truth → Expr Fn .truth
  | recordDefault : PackageRecord ty → Expr Fn ty
  | recordValue : PackageRecord ty → Bool → Updates Fn ty → Expr Fn ty
  | update : Expr Fn ty → Updates Fn ty → Expr Fn ty
inductive Updates (Fn : Ty → Type) : Ty → Type
  | one : Field owner ty → Expr Fn ty → Updates Fn owner
  | more : Field owner ty → Expr Fn ty → Updates Fn owner → Updates Fn owner
end

variable {Fn : Ty → Type}

def scalarKindName : FunctionBindings.ScalarKind → List String
  | .integer => ["functions", ".", "integer_kind"] | .boolean => ["functions", ".", "boolean_kind"]
def exportKindName : PackageBindings.ExportKind → List String
  | .integerSubtype => ["packages", ".", "integer_subtype"]
  | .integerConstant => ["packages", ".", "integer_constant"]
  | .booleanConstant => ["packages", ".", "boolean_constant"]
def modeName : ProcedureBindings.Mode → List String
  | .input => ["procedures", ".", "input"] | .output => ["procedures", ".", "output"]
  | .inputOutput => ["procedures", ".", "input_output"]
def unitKindName : ApplicationUnits.UnitKind → List String
  | .packageSpecification => ["units", ".", "package_specification"]
  | .packageBody => ["units", ".", "package_body"] | .mainBody => ["units", ".", "main_body"]

def routineKindName : PackageBindings.RoutineKind → List String
  | .function => ["packages", ".", "function_routine"]
  | .procedure => ["packages", ".", "procedure_routine"]

def bodyStopName : Predicate.BodyStop → String
  | .endOnly => "end_only" | .returnOnly => "return_only"
  | .arm => "arm_boundary" | .elseOnly => "else_only"

mutual
def Expr.render (names : FunctionNames Fn) : Expr Fn ty → List String
  | .token value => [Compose.Expressions.tokenName value]
  | .number value => [toString value] | .integer value => [toString value]
  | .truth value => [if value then "true" else "false"] | .word value => ["\"" ++ value ++ "\""]
  | .scalarKind value => scalarKindName value | .exportKind value => exportKindName value
  | .mode value => modeName value | .unitKind value => unitKindName value
  | .bodyStop value => [bodyStopName value]
  | .routineKind value => routineKindName value
  | .emptyActuals => ["(", "others", "=>", "(", "others", "=>", "<", ">", ")", ")"]
  | .emptySeen => ["(", "others", "=>", "false", ")"]
  | .emptyStateSet => ["packages", ".", "empty_state_set"]
  | .invalidObject => ["invalid_package_object"]
  | .invalidCall => ["invalid_call"]
  | .callValueAggregate after kind bounds => ["("] ++ after.render names ++ [","] ++
      kind.render names ++ [","] ++ bounds.render names ++ [")"]
  | .applicationCall count value scan => ["("] ++ count.render names ++ [","] ++
      value.render names ++ [","] ++ scan.render names ++ [")"]
  | .stateDeclarationValue name kind typeName identity declaredBounds initialBounds first after value =>
      ["(", "name", "=>"] ++ name.render names ++ [",", "kind", "=>"] ++ kind.render names ++
      [",", "type_name", "=>"] ++ typeName.render names ++ [",", "type_identity", "=>"] ++ identity.render names ++
      [",", "declared_bounds", "=>"] ++ declaredBounds.render names ++ [",", "initial_bounds", "=>"] ++ initialBounds.render names ++
      [",", "initializer_first", "=>"] ++ first.render names ++ [",", "initializer_after", "=>"] ++ after.render names ++
      [",", "boolean_initial", "=>"] ++ value.render names ++ [")"]
  | .scalarConstraintValue after bounds => ["("] ++ after.render names ++ [","] ++ bounds.render names ++ [")"]
  | .scalarBindingValue first after bounds isStatic declaredBounds mutable qFirst qAfter =>
      ["("] ++ first.render names ++ [","] ++ after.render names ++ [","] ++ bounds.render names ++
      [","] ++ isStatic.render names ++ [","] ++ declaredBounds.render names ++ [","] ++ mutable.render names ++
      [","] ++ qFirst.render names ++ [","] ++ qAfter.render names ++ [")"]
  | .booleanBindingValue first after mutable qFirst qAfter known value =>
      ["("] ++ first.render names ++ [","] ++ after.render names ++ [","] ++ mutable.render names ++
      [","] ++ qFirst.render names ++ [","] ++ qAfter.render names ++ [","] ++ known.render names ++
      [","] ++ value.render names ++ [")"]
  | .functionType after kind bounds typeId => ["("] ++ after.render names ++ [","] ++
      kind.render names ++ [","] ++ bounds.render names ++ [","] ++ typeId.render names ++ [")"]
  | .functionFormal first after kind bounds typeId => ["("] ++ first.render names ++ [","] ++
      after.render names ++ [","] ++ kind.render names ++ [","] ++ bounds.render names ++ [","] ++ typeId.render names ++ [")"]
  | .procedureFormal first after kind bounds typeId mode => ["("] ++ first.render names ++ [","] ++
      after.render names ++ [","] ++ kind.render names ++ [","] ++ bounds.render names ++ [","] ++ typeId.render names ++ [","] ++ mode.render names ++ [")"]
  | .variable name => [name] | .function symbol => names symbol
  | .soleApp symbol argument => names symbol ++ ["("] ++ argument.render names ++ [")"]
  | .app fn argument => match fn with
    | .app _ _ | .namedApp _ _ _ => (fn.render names).dropLast ++ [","] ++ argument.render names ++ [")"]
    | _ => fn.render names ++ ["("] ++ argument.render names ++ [")"]
  | .namedApp formal fn argument => match fn with
    | .app _ _ | .namedApp _ _ _ =>
        (fn.render names).dropLast ++ [",", formal, "=>"] ++ argument.render names ++ [")"]
    | _ => fn.render names ++ ["(", formal, "=>"] ++ argument.render names ++ [")"]
  | .field projection value => value.render names ++ [".", projection.name]
  | .property projection value => value.render names ++ [".", projection.name]
  | .index selection value index => value.render names ++ selection.path ++ ["("] ++ index.render names ++ [")"]
  | .add left right => left.render names ++ ["+"] ++ right.render names
  | .sub left right => left.render names ++ ["-"] ++ right.render names
  | .truthEq left right | .scalarBindingEq left right | .intervalEq left right | .eq left right | .nameEq left right | .kindEq left right | .routineEq left right | .exportEq left right | .unitMapEq left right | .modeEq left right =>
      left.render names ++ ["="] ++ right.render names
  | .truthNe left right | .kindNe left right | .intervalNe left right
  | .ne left right | .modeNe left right | .unitMapNe left right | .stateSetNe left right | .intNe left right => left.render names ++ ["/="] ++ right.render names
  | .inRange value first last => value.render names ++ ["in"] ++ first.render names ++ [".."] ++ last.render names
  | .lt left right => left.render names ++ ["<"] ++ right.render names
  | .le left right | .intLe left right => left.render names ++ ["<="] ++ right.render names
  | .gt left right => left.render names ++ [">"] ++ right.render names
  | .ge left right | .intGe left right => left.render names ++ [">="] ++ right.render names
  | .not value => ["not"] ++ value.render names
  | .andThen left right => left.render names ++ ["and", "then"] ++ right.render names
  | .orElse left right => left.render names ++ ["or", "else"] ++ right.render names
  | .eagerOr left right => left.render names ++ ["or"] ++ right.render names
  | .group value => ["("] ++ value.render names ++ [")"]
  | .ite condition yes no => ["if"] ++ condition.render names ++ ["then"] ++ yes.render names ++
      (match no with | .elsif _ _ _ => no.render names | _ => ["else"] ++ no.render names)
  | .conditionalTrue condition yes => ["if"] ++ condition.render names ++ ["then"] ++ yes.render names
  | .scanResult state assigned output => ["("] ++ state.render names ++ [","] ++
      assigned.render names ++ [","] ++ output.render names ++ [")"]
  | .analysisValue accepted info functions procedures arguments assigned output =>
      ["(", "accepted", "=>"] ++ accepted.render names ++ [",", "package_info", "=>"] ++
      info.render names ++ [",", "main_functions", "=>"] ++ functions.render names ++
      [",", "main_procedures", "=>"] ++ procedures.render names ++ [",", "uses_arguments", "=>"] ++
      arguments.render names ++ [",", "uses_assignment", "=>"] ++ assigned.render names ++
      [",", "uses_output", "=>"] ++ output.render names ++ [")"]
  | .elsif condition yes no => ["elsif"] ++ condition.render names ++ ["then"] ++ yes.render names ++
      (match no with | .elsif _ _ _ => no.render names | _ => ["else"] ++ no.render names)
  | .contextHasDynamic context => context.render names ++ [".", "dynamic_first", "/=", "0"]
  | .flowValuesFirst facts => facts.render names ++ [".", "values", "'", "first"]
  | .intervalValue lower upper => ["("] ++ lower.render names ++ [","] ++ upper.render names ++ [")"]
  | .sourceLast text => text.render names ++ ["'", "last"]
  | .sourceLength text => text.render names ++ ["'", "length"]
  | .sourcePrefix text last => text.render names ++ ["(", "1", ".."] ++ last.render names ++ [")"]
  | .maxConcatenations => ["max_concatenations"]
  | .emptyMetadata => ["packages", ".", "empty_metadata"]
  | .invalidAnalysis => ["invalid_analysis"]
  | .nameSpan first after => ["("] ++ first.render names ++ [","] ++ after.render names ++ [")"]
  | .packageType name after kind bounds identity => ["("] ++ name.render names ++ [","] ++
      after.render names ++ [","] ++ kind.render names ++ [","] ++ bounds.render names ++ [","] ++
      identity.render names ++ [")"]
  | .full => ["scalars", ".", "full"] | .empty => ["scalars", ".", "empty"]
  | .invalidType => ["invalid_package_type"] | .invalidState => ["invalid_state"]
  | .noHidden => ["no_hidden_marks"]
  | .noCalls => ["(", "others", "=>", "false", ")"]
  | .booleanType => ["packages", ".", "boolean_type"] | .integerType => ["packages", ".", "integer_type"]
  | .forAll name first last body => ["for", "all", name, "in"] ++ first.render names ++ [".."] ++
      last.render names ++ ["=>"] ++ body.render names
  | .forSome name first last body => ["for", "some", name, "in"] ++ first.render names ++ [".."] ++
      last.render names ++ ["=>"] ++ body.render names
  | .forAllStates name body => ["for", "all", name, "in", "packages", ".", "state_index", "=>"] ++ body.render names
  | .forAllFlowValues name facts body => ["for", "all", name, "in"] ++ facts.render names ++
      [".", "values", "'", "range", "=>"] ++ body.render names
  | .forAllActuals name actuals body => ["for", "all", name, "in"] ++ actuals.render names ++
      ["'", "range", "=>"] ++ body.render names
  | .recordDefault _ => ["(", "others", "=>", "<", ">", ")"]
  | .recordValue _ others changes => ["("] ++ changes.render names ++
      (if others then [",", "others", "=>", "<", ">"] else []) ++ [")"]
  | .update value changes => ["("] ++ value.render names ++ ["with", "delta"] ++ changes.render names ++ [")"]
def Updates.render (names : FunctionNames Fn) : Updates Fn owner → List String
  | .one field value => [field.name, "=>"] ++ value.render names
  | .more field value rest => [field.name, "=>"] ++ value.render names ++ [","] ++ rest.render names
end

mutual
def Expr.eval (calls : Calls Fn) (locals : Locals) : Expr Fn ty → ty.meaning
  | .token value => value
  | .number value => value | .integer value => value | .truth value => value | .word value => value
  | .scalarKind value => value | .exportKind value => value | .mode value => value | .unitKind value => value
  | .bodyStop value => value
  | .routineKind value => value
  | .emptyActuals => List.replicate PackageBindings.maxFormals {}
  | .emptySeen => List.replicate PackageBindings.maxFormals false
  | .emptyStateSet => PackageBindings.emptyStateSet
  | .invalidObject => ApplicationPackageDeclarations.invalidObject
  | .invalidCall => Predicate.invalidCall
  | .callValueAggregate after kind bounds =>
      ⟨after.eval calls locals, kind.eval calls locals, bounds.eval calls locals⟩
  | .applicationCall _ value scan => ⟨value.eval calls locals, scan.eval calls locals⟩
  | .stateDeclarationValue name kind typeName identity declaredBounds initialBounds first after value =>
      ⟨name.eval calls locals, kind.eval calls locals, typeName.eval calls locals, identity.eval calls locals,
        declaredBounds.eval calls locals, initialBounds.eval calls locals, first.eval calls locals,
        after.eval calls locals, value.eval calls locals⟩
  | .scalarConstraintValue after bounds => ⟨after.eval calls locals, bounds.eval calls locals⟩
  | .scalarBindingValue first after bounds isStatic declaredBounds mutable qFirst qAfter =>
      ⟨first.eval calls locals, after.eval calls locals, bounds.eval calls locals, isStatic.eval calls locals,
        declaredBounds.eval calls locals, mutable.eval calls locals, qFirst.eval calls locals, qAfter.eval calls locals⟩
  | .booleanBindingValue first after mutable qFirst qAfter known value =>
      ⟨first.eval calls locals, after.eval calls locals, mutable.eval calls locals, qFirst.eval calls locals,
        qAfter.eval calls locals, known.eval calls locals, value.eval calls locals⟩
  | .functionType after kind bounds typeId =>
      ⟨after.eval calls locals, kind.eval calls locals, bounds.eval calls locals, typeId.eval calls locals⟩
  | .functionFormal first after kind bounds typeId =>
      ⟨first.eval calls locals, after.eval calls locals, kind.eval calls locals, bounds.eval calls locals, typeId.eval calls locals⟩
  | .procedureFormal first after kind bounds typeId mode =>
      ⟨first.eval calls locals, after.eval calls locals, kind.eval calls locals, bounds.eval calls locals, mode.eval calls locals, typeId.eval calls locals⟩
  | .variable name => locals _ name | .function symbol => calls _ symbol
  | .soleApp symbol argument => calls _ symbol (argument.eval calls locals)
  | .app fn argument => fn.eval calls locals (argument.eval calls locals)
  | .namedApp _ fn argument => fn.eval calls locals (argument.eval calls locals)
  | .field projection value => projection.get (value.eval calls locals)
  | .property projection value => projection.get (value.eval calls locals)
  | .index selection value index => selection.get (value.eval calls locals) (index.eval calls locals)
  | .add left right => left.eval calls locals + right.eval calls locals
  | .sub left right => left.eval calls locals - right.eval calls locals
  | .inRange value first last => decide (first.eval calls locals ≤ value.eval calls locals ∧
      value.eval calls locals ≤ last.eval calls locals)
  | .scalarBindingEq left right => decide (left.eval calls locals = right.eval calls locals)
  | .intervalEq left right => decide (left.eval calls locals = right.eval calls locals)
  | .eq left right => decide (left.eval calls locals = right.eval calls locals)
  | .ne left right => decide (left.eval calls locals ≠ right.eval calls locals)
  | .lt left right => decide (left.eval calls locals < right.eval calls locals)
  | .le left right => decide (left.eval calls locals ≤ right.eval calls locals)
  | .gt left right => decide (left.eval calls locals > right.eval calls locals)
  | .ge left right => decide (left.eval calls locals ≥ right.eval calls locals)
  | .intLe left right => decide (left.eval calls locals ≤ right.eval calls locals)
  | .intGe left right => decide (left.eval calls locals ≥ right.eval calls locals)
  | .intNe left right => decide (left.eval calls locals ≠ right.eval calls locals)
  | .unitMapEq left right => ApplicationAdmission.unitsEqual (left.eval calls locals) (right.eval calls locals)
  | .unitMapNe left right => !(ApplicationAdmission.unitsEqual (left.eval calls locals) (right.eval calls locals))
  | .nameEq left right => decide (left.eval calls locals = right.eval calls locals)
  | .kindEq left right => decide (left.eval calls locals = right.eval calls locals)
  | .truthEq left right => decide (left.eval calls locals = right.eval calls locals)
  | .truthNe left right => decide (left.eval calls locals ≠ right.eval calls locals)
  | .kindNe left right => decide (left.eval calls locals ≠ right.eval calls locals)
  | .intervalNe left right => decide (left.eval calls locals ≠ right.eval calls locals)
  | .routineEq left right => decide (left.eval calls locals = right.eval calls locals)
  | .exportEq left right => decide (left.eval calls locals = right.eval calls locals)
  | .modeNe left right => decide (left.eval calls locals ≠ right.eval calls locals)
  | .modeEq left right => decide (left.eval calls locals = right.eval calls locals)
  | .stateSetNe left right => decide (left.eval calls locals ≠ right.eval calls locals)
  | .not value => !(value.eval calls locals)
  | .andThen left right => left.eval calls locals && right.eval calls locals
  | .orElse left right => left.eval calls locals || right.eval calls locals
  | .eagerOr left right => left.eval calls locals || right.eval calls locals
  | .group value => value.eval calls locals
  | .ite condition yes no | .elsif condition yes no => if condition.eval calls locals then yes.eval calls locals else no.eval calls locals
  | .conditionalTrue condition yes => if condition.eval calls locals then yes.eval calls locals else true
  | .scanResult state assigned output => ⟨state.eval calls locals, assigned.eval calls locals, output.eval calls locals⟩
  | .analysisValue accepted info functions procedures arguments assigned output =>
      ⟨accepted.eval calls locals, info.eval calls locals, functions.eval calls locals,
        procedures.eval calls locals, arguments.eval calls locals, assigned.eval calls locals,
        output.eval calls locals⟩
  | .contextHasDynamic context => (context.eval calls locals).hasArguments
  | .flowValuesFirst _ => 1
  | .intervalValue lower upper => ⟨lower.eval calls locals, upper.eval calls locals⟩
  | .sourceLast text | .sourceLength text => (text.eval calls locals).length
  | .sourcePrefix text last => (text.eval calls locals).take (last.eval calls locals)
  | .maxConcatenations => Compose.maxConcatenations
  | .emptyMetadata => {} | .invalidAnalysis => ApplicationAdmission.invalidAnalysis
  | .nameSpan first after => ⟨first.eval calls locals, after.eval calls locals⟩
  | .packageType name after kind bounds identity => ⟨name.eval calls locals, after.eval calls locals,
      kind.eval calls locals, bounds.eval calls locals, identity.eval calls locals⟩
  | .full => .full | .empty => .empty | .invalidType => {} | .invalidState => Compose.invalidState
  | .noHidden => {} | .noCalls => {} | .booleanType => 0 | .integerType => 1
  | .forAll name first last body =>
      (List.range (last.eval calls locals + 1 - first.eval calls locals)).all fun offset =>
        body.eval calls (locals.set .number name (first.eval calls locals + offset))
  | .forSome name first last body =>
      (List.range (last.eval calls locals + 1 - first.eval calls locals)).any fun offset =>
        body.eval calls (locals.set .number name (first.eval calls locals + offset))
  | .forAllStates name body => (List.range PackageBindings.maxStates).all fun offset =>
      body.eval calls (locals.set .number name (offset + 1))
  | .forAllFlowValues name facts body => (List.range (facts.eval calls locals).count).all fun offset =>
      body.eval calls (locals.set .number name (offset + 1))
  | .forAllActuals name _ body => (List.range PackageBindings.maxFormals).all fun offset =>
      body.eval calls (locals.set .number name (offset + 1))
  | .recordDefault record => record.defaults
  | .recordValue record _ changes => changes.eval calls locals record.defaults
  | .update value changes => changes.eval calls locals (value.eval calls locals)
def Updates.eval (calls : Calls Fn) (locals : Locals) : Updates Fn owner → owner.meaning → owner.meaning
  | .one field value, base => field.set base (value.eval calls locals)
  | .more field value rest, base => rest.eval calls locals (field.set base (value.eval calls locals))
end

end Silver.ApplicationNative
