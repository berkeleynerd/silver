module

public import Silver.ProcedureDeclarationAdmission
public import Silver.PredicateNativeState
import all Init.Data.Repr

@[expose] public section

/-! Typed syntax for the actual scalar-procedure declaration helpers. Calls are
uninterpreted until their native-domain equations are supplied. Record updates,
local declarations and control flow retain their written evaluation order. -/
namespace Silver.Compose.ProcedureDeclarationNative

set_option backward.dsimp.instances true

inductive Ty
  | number | truth | source | word | token | kind | interval | state | metadata | procedures | formal | signature | hidden | typeResult | stepResult | constraint | names | scalars | scalarBinding | booleans | subtypes | arrays | context | scan | bodyScan | flow | stop
  | mode | procedureFormal | procedureSignature | procedureStep
  | arrow (domain codomain : Ty)
  deriving DecidableEq, Repr

@[reducible] def Ty.meaning : Ty → Type
  | .mode => ProcedureBindings.Mode
  | .procedureFormal => ProcedureBindings.Formal
  | .procedureSignature => ProcedureBindings.Signature
  | .procedureStep => ProcedureParameterStepResult
  | .number => Nat
  | .truth => Bool
  | .source => Source
  | .word => String
  | .token => ShellToken
  | .kind => FunctionBindings.ScalarKind
  | .interval => Integer.Interval
  | .state => ParserState
  | .metadata => FunctionBindings.Metadata
  | .procedures => ProcedureBindings.Metadata
  | .formal => FunctionBindings.Formal
  | .signature => FunctionBindings.Signature
  | .hidden => HiddenMarks
  | .typeResult => FunctionTypeResult
  | .stepResult => ParameterStepResult
  | .constraint => ScalarConstraintResult
  | .names => BindingEnvironment
  | .scalars => ScalarExpression.Environment
  | .scalarBinding => ScalarExpression.Binding
  | .booleans => BooleanBindings.Environment
  | .subtypes => IntegerSubtypes.Environment
  | .arrays => ArrayBindings.Metadata
  | .context => Predicate.Native.Context
  | .scan => Predicate.ScanResult
  | .bodyScan => Predicate.BodyScan
  | .flow => Predicate.ActiveFlow
  | .stop => Predicate.BodyStop
  | .arrow a b => a.meaning → b.meaning

def Ty.default : (ty : Ty) → ty.meaning
  | .mode => .input
  | .procedureFormal => ProcedureBindings.emptyFormal
  | .procedureSignature => ProcedureBindings.emptySignature
  | .procedureStep => ⟨invalidState, false⟩
  | .number => 0
  | .truth => false
  | .source => []
  | .word => ""
  | .token => .symbol ";"
  | .kind => .integer
  | .interval => .empty
  | .state => invalidState
  | .metadata => {}
  | .procedures => {}
  | .formal => FunctionBindings.emptyFormal
  | .signature => FunctionBindings.emptySignature
  | .hidden => {}
  | .typeResult => ⟨0, .integer, .empty⟩
  | .stepResult => ⟨invalidState, false⟩
  | .constraint => ⟨0, .empty⟩
  | .names => []
  | .scalars => []
  | .scalarBinding => ScalarExpression.emptyBinding
  | .booleans => []
  | .subtypes => {}
  | .arrays => []
  | .context => {names := [], dynamicFirst := 0, dynamicAfter := 0}
  | .scan => ⟨invalidState, false, false⟩
  | .bodyScan => ⟨0,0,0,⟨PathFacts.Context.empty, []⟩,false,false⟩
  | .flow => ⟨PathFacts.Context.empty, []⟩
  | .stop => .returnOnly
  | .arrow _ b => fun _ => b.default

def Ty.name : Ty → List String
  | .mode => ["procedures", ".", "parameter_mode"]
  | .procedureFormal => ["procedures", ".", "formal"]
  | .procedureSignature => ["procedures", ".", "signature"]
  | .procedureStep => ["procedure_parameter_step_result"]
  | .number => ["literal_position"]
  | .truth => ["boolean"]
  | .source => ["string"]
  | .word => ["string"]
  | .token => ["token_kind"]
  | .kind => ["functions", ".", "scalar_kind"]
  | .interval => ["scalars", ".", "interval"]
  | .state => ["parser_state"]
  | .metadata => ["functions", ".", "metadata"]
  | .procedures => ["procedures", ".", "metadata"]
  | .formal => ["functions", ".", "formal"]
  | .signature => ["functions", ".", "signature"]
  | .hidden => ["hidden_marks"]
  | .typeResult => ["function_type_result"]
  | .stepResult => ["parameter_step_result"]
  | .constraint => ["scalar_constraint_result"]
  | .names => ["binding_environment"]
  | .scalars => ["scalar_expressions", ".", "environment"]
  | .scalarBinding => ["scalar_expressions", ".", "binding"]
  | .booleans => ["boolean_environment"]
  | .subtypes => ["subtype_environment"]
  | .arrays => ["array_bindings", ".", "metadata"]
  | .context => ["body_context"]
  | .scan => ["scan_result"]
  | .bodyScan => ["body_scan"]
  | .flow => ["scalar_flow"]
  | .stop => ["body_stop"]
  | .arrow _ _ => []

inductive Function
  | appendProcedureFormal | appendProcedure | procedureParameterStep | procedureParametersModel | procedureParameters | appendProcedureParameter | procedureInputFrameModel | procedureInputFrame | procedurePrefixStep | procedurePrefixModel | procedurePrefix | procedureBody | procedureDeclaration | readBody | initialFlow
  | skip | nameAfter | nameIs | take | newName | equal | scalarType | lookupString | lookupScalar | lookupBoolean | lookupSubtype | lookupArray | lookupFunction | lookupProcedure | formalHides | hideName | hiddenOuter | functionType | appendFormal | append | parameterStep | parametersModel | parameters | scalarDeclaration | booleanDeclaration | functionLocal | functionLocalsModel | functionLocals | scalarAppend | appendParameter | parameterFrameModel | parameterFrame | contextOf | bodyOf | bodyTail | actualAfter | returnAfter | functionBody | functionDeclaration
  deriving DecidableEq, Repr

def Function.type : Function → Ty
  | .appendProcedureFormal => .arrow .procedures (.arrow .procedureFormal (.procedures))
  | .appendProcedure => .arrow .procedures (.arrow .procedureSignature (.procedures))
  | .procedureParameterStep => .arrow .source (.arrow .state (.arrow .truth (.procedureStep)))
  | .procedureParametersModel => .arrow .source (.arrow .state (.arrow .truth (.state)))
  | .procedureParameters => .arrow .source (.arrow .state (.arrow .truth (.state)))
  | .appendProcedureParameter => .arrow .state (.arrow .procedureFormal (.state))
  | .procedureInputFrameModel => .arrow .state (.arrow .number (.state))
  | .procedureInputFrame => .arrow .source (.arrow .state (.state))
  | .procedurePrefixStep => .arrow .source (.arrow .state (.arrow .state (.arrow .procedureFormal (.arrow .number (.state)))))
  | .procedurePrefixModel => .arrow .source (.arrow .state (.arrow .state (.arrow .number (.arrow .number (.state)))))
  | .procedurePrefix => .arrow .source (.arrow .state (.arrow .number (.state)))
  | .procedureBody => .arrow .source (.arrow .state (.arrow .state (.arrow .number (.arrow .number (.arrow .truth (.state))))))
  | .procedureDeclaration => .arrow .source (.arrow .state (.arrow .truth (.state)))
  | .readBody => .arrow .source (.arrow .context (.arrow .bodyScan (.arrow .stop (.arrow .metadata (.arrow .procedures (.bodyScan))))))
  | .initialFlow => .arrow .context (.flow)
  | .skip => .arrow .source (.arrow .number (.number))
  | .nameAfter => .arrow .source (.arrow .number (.number))
  | .nameIs => .arrow .source (.arrow .number (.arrow .number (.arrow .word .truth)))
  | .take => .arrow .source (.arrow .number (.arrow .token (.number)))
  | .newName => .arrow .source (.arrow .state (.arrow .number (.arrow .number (.arrow .truth (.truth)))))
  | .equal => .arrow .source (.arrow .number (.arrow .number (.arrow .number (.arrow .number (.truth)))))
  | .scalarType => .arrow .source (.arrow .state (.arrow .number (.constraint)))
  | .lookupString => .arrow .source (.arrow .names (.arrow .number (.arrow .number (.number))))
  | .lookupScalar => .arrow .source (.arrow .scalars (.arrow .number (.arrow .number (.number))))
  | .lookupBoolean => .arrow .source (.arrow .booleans (.arrow .number (.arrow .number (.number))))
  | .lookupSubtype => .arrow .source (.arrow .subtypes (.arrow .number (.arrow .number (.number))))
  | .lookupArray => .arrow .source (.arrow .arrays (.arrow .number (.arrow .number (.number))))
  | .lookupFunction => .arrow .source (.arrow .metadata (.arrow .number (.arrow .number (.number))))
  | .lookupProcedure => .arrow .source (.arrow .procedures (.arrow .number (.arrow .number (.number))))
  | .formalHides => .arrow .source (.arrow .state (.arrow .number (.arrow .number (.truth))))
  | .hideName => .arrow .source (.arrow .hidden (.arrow .number (.arrow .number (.hidden))))
  | .hiddenOuter => .arrow .source (.arrow .state (.hidden))
  | .functionType => .arrow .source (.arrow .state (.arrow .number (.typeResult)))
  | .appendFormal => .arrow .metadata (.arrow .formal (.metadata))
  | .append => .arrow .metadata (.arrow .signature (.metadata))
  | .parameterStep => .arrow .source (.arrow .state (.arrow .truth (.stepResult)))
  | .parametersModel => .arrow .source (.arrow .state (.arrow .truth (.state)))
  | .parameters => .arrow .source (.arrow .state (.arrow .truth (.state)))
  | .scalarDeclaration => .arrow .source (.arrow .state (.arrow .truth (.state)))
  | .booleanDeclaration => .arrow .source (.arrow .state (.arrow .truth (.state)))
  | .functionLocal => .arrow .source (.arrow .state (.arrow .truth (.state)))
  | .functionLocalsModel => .arrow .source (.arrow .state (.arrow .truth (.state)))
  | .functionLocals => .arrow .source (.arrow .state (.arrow .truth (.state)))
  | .scalarAppend => .arrow .scalars (.arrow .scalarBinding (.scalars))
  | .appendParameter => .arrow .state (.arrow .formal (.state))
  | .parameterFrameModel => .arrow .state (.arrow .number (.state))
  | .parameterFrame => .arrow .source (.arrow .state (.state))
  | .contextOf => .arrow .scan (.context)
  | .bodyOf => .arrow .scan (.bodyScan)
  | .bodyTail => .arrow .source (.arrow .context (.arrow .bodyScan (.arrow .stop (.arrow .metadata (.arrow .procedures .bodyScan)))))
  | .actualAfter => .arrow .source (.arrow .context (.arrow .number (.arrow .flow (.arrow .formal (.number)))))
  | .returnAfter => .arrow .source (.arrow .context (.arrow .bodyScan (.arrow .typeResult (.number))))
  | .functionBody => .arrow .source (.arrow .state (.arrow .state (.arrow .number (.arrow .number (.arrow .typeResult (.arrow .truth (.state)))))))
  | .functionDeclaration => .arrow .source (.arrow .state (.arrow .truth (.state)))

def Function.name : Function → List String
  | .appendProcedureFormal => ["procedures", ".", "append_formal"]
  | .appendProcedure => ["procedures", ".", "append"]
  | .procedureParameterStep => ["procedure_parameter_step"]
  | .procedureParametersModel => ["procedure_parameters_model"]
  | .procedureParameters => ["procedure_parameters_at"]
  | .appendProcedureParameter => ["append_procedure_parameter"]
  | .procedureInputFrameModel => ["procedure_input_frame_model"]
  | .procedureInputFrame => ["procedure_input_frame"]
  | .procedurePrefixStep => ["procedure_prefix_step"]
  | .procedurePrefixModel => ["procedure_prefix_model"]
  | .procedurePrefix => ["procedure_prefix"]
  | .procedureBody => ["procedure_body_at"]
  | .procedureDeclaration => ["procedure_declaration_at"]
  | .readBody => ["read_body"]
  | .initialFlow => ["initial_flow"]
  | .skip => ["skip_at"]
  | .nameAfter => ["name_after"]
  | .nameIs => ["name_is"]
  | .take => ["take_token"]
  | .newName => ["new_name_allowed"]
  | .equal => ["equal_name"]
  | .scalarType => ["scalar_type_at"]
  | .lookupString => ["lookup_name"]
  | .lookupScalar => ["scalar_expressions", ".", "lookup"]
  | .lookupBoolean => ["lookup_boolean"]
  | .lookupSubtype => ["lookup_subtype"]
  | .lookupArray => ["array_bindings", ".", "lookup"]
  | .lookupFunction => ["functions", ".", "lookup"]
  | .lookupProcedure => ["procedures", ".", "lookup"]
  | .formalHides => ["formal_hides"]
  | .hideName => ["hide_name"]
  | .hiddenOuter => ["hidden_outer"]
  | .functionType => ["function_type_at"]
  | .appendFormal => ["functions", ".", "append_formal"]
  | .append => ["functions", ".", "append"]
  | .parameterStep => ["parameter_step"]
  | .parametersModel => ["parameters_model"]
  | .parameters => ["parameters_at"]
  | .scalarDeclaration => ["scalar_declaration_at"]
  | .booleanDeclaration => ["boolean_declaration_at"]
  | .functionLocal => ["function_local_at"]
  | .functionLocalsModel => ["function_locals_model"]
  | .functionLocals => ["function_locals"]
  | .scalarAppend => ["scalar_expressions", ".", "append"]
  | .appendParameter => ["append_parameter"]
  | .parameterFrameModel => ["parameter_frame_model"]
  | .parameterFrame => ["parameter_frame"]
  | .contextOf => ["context_of"]
  | .bodyOf => ["body_of"]
  | .bodyTail => ["body_tail"]
  | .actualAfter => ["actual_after"]
  | .returnAfter => ["function_return_after"]
  | .functionBody => ["function_body_at"]
  | .functionDeclaration => ["function_declaration_at"]

abbrev Calls := (fn : Function) → fn.type.meaning

def nativeContextOf (scan : Predicate.ScanResult) : Predicate.Native.Context :=
  { names := scan.state.names
    dynamicFirst := scan.state.dynamicFirst
    dynamicAfter := scan.state.dynamicAfter
    scalarNames := ScalarExpression.bodyEnvironment scan.state.scalarNames
    declarationCount := scan.state.scalarNames.length
    arrayNames := scan.state.arrayNames.names
    subtypeHiding := scan.state.subtypeNames.hiddenCalls
    booleanNames := scan.state.booleanNames
    trueHidden := scan.state.subtypeNames.trueHidden || scan.state.hiding.trueHidden
    falseHidden := scan.state.subtypeNames.falseHidden || scan.state.hiding.falseHidden
    pure := scan.state.pure
    integerHidden := scan.state.hiding.integerHidden }

theorem nativeContextOf_model (scan : Predicate.ScanResult) :
    (nativeContextOf scan).model = Predicate.contextOf scan := rfl

def modelCalls : Calls
  | .appendProcedureFormal => ProcedureBindings.appendFormal
  | .appendProcedure => ProcedureBindings.append
  | .procedureParameterStep => procedureParameterStep
  | .procedureParametersModel => procedureParametersModel
  | .procedureParameters => procedureParametersAt
  | .appendProcedureParameter => appendProcedureParameter
  | .procedureInputFrameModel => procedureInputFrameModel
  | .procedureInputFrame => procedureInputFrame
  | .procedurePrefixStep => procedurePrefixStep
  | .procedurePrefixModel => procedurePrefixModel
  | .procedurePrefix => procedurePrefix
  | .procedureBody => procedureBodyAt
  | .procedureDeclaration => procedureDeclarationAt
  | .readBody => fun text context scan stop functions procedures => Predicate.readBody text context.model scan stop functions procedures
  | .initialFlow => fun context => Predicate.ActiveFlow.initial context.scalarNames (Predicate.initialFacts context.model.hasArguments)
  | .skip => skipAt
  | .nameAfter => nameAfter
  | .nameIs => fun text first after word => Named.nameIs text first after (word.toList.map Char.toNat)
  | .take => fun text position token => tokenAfter text position token
  | .newName => newNameAllowed
  | .equal => Named.equalName
  | .scalarType => scalarTypeAt
  | .lookupString => lookupName
  | .lookupScalar => ScalarExpression.lookup
  | .lookupBoolean => BooleanBindings.lookup
  | .lookupSubtype => IntegerSubtypes.lookup
  | .lookupArray => ArrayBindings.lookup
  | .lookupFunction => FunctionBindings.lookup
  | .lookupProcedure => ProcedureBindings.lookup
  | .formalHides => formalHides
  | .hideName => hideName
  | .hiddenOuter => hiddenOuter
  | .functionType => functionTypeAt
  | .appendFormal => FunctionBindings.appendFormal
  | .append => FunctionBindings.append
  | .parameterStep => parameterStep
  | .parametersModel => parametersModel
  | .parameters => parametersAt
  | .scalarDeclaration => scalarDeclarationAt
  | .booleanDeclaration => booleanDeclarationAt
  | .functionLocal => functionLocalAt
  | .functionLocalsModel => functionLocalsModel
  | .functionLocals => functionLocals
  | .scalarAppend => fun names item => names ++ [item]
  | .appendParameter => appendParameter
  | .parameterFrameModel => parameterFrameModel
  | .parameterFrame => parameterFrame
  | .contextOf => nativeContextOf
  | .bodyOf => Predicate.bodyOf
  | .bodyTail => fun text context scan stop functions procedures =>
      Predicate.bodyTail text context.model scan stop functions procedures
  | .actualAfter => fun text context position facts parameter => Predicate.actualAfter text context.model position facts parameter
  | .returnAfter => fun text context scan resultType => functionReturnAfter text context.model scan resultType
  | .functionBody => functionBodyAt
  | .functionDeclaration => functionDeclarationAt

inductive Field : Ty → Ty → Type
  | firstProcedureParameter : Field .state .number
  | procedureCount : Field .procedures .number
  | procedureParameterCount : Field .procedures .number
  | procedureFormalFirst : Field .procedureFormal .number
  | procedureFormalAfter : Field .procedureFormal .number
  | procedureFormalKind : Field .procedureFormal .kind
  | procedureFormalBounds : Field .procedureFormal .interval
  | procedureFormalMode : Field .procedureFormal .mode
  | procedureStepState : Field .procedureStep .state
  | procedureStepClosed : Field .procedureStep .truth
  | scalarNames : Field .state .scalars
  | assignedInFunctions : Field .state .truth
  | position : Field .state .number
  | functions : Field .state .metadata
  | procedures : Field .state .procedures
  | pure : Field .state .truth
  | «hiding» : Field .state .hidden
  | firstParameter : Field .state .number
  | subtypes : Field .state .subtypes
  | names : Field .state .names
  | scalars : Field .state .scalars
  | booleans : Field .state .booleans
  | arrays : Field .state .arrays
  | assigned : Field .state .truth
  | integerHidden : Field .hidden .truth
  | booleanHidden : Field .hidden .truth
  | functionCount : Field .metadata .number
  | parameterCount : Field .metadata .number
  | scalarCount : Field .scalars .number
  | booleanCount : Field .booleans .number
  | typeAfter : Field .typeResult .number
  | typeKind : Field .typeResult .kind
  | typeBounds : Field .typeResult .interval
  | constraintAfter : Field .constraint .number
  | constraintBounds : Field .constraint .interval
  | stepState : Field .stepResult .state
  | stepClosed : Field .stepResult .truth
  | formalFirst : Field .formal .number
  | formalAfter : Field .formal .number
  | formalKind : Field .formal .kind
  | formalBounds : Field .formal .interval
  | bodyPosition : Field .bodyScan .number
  | bodyAssigned : Field .bodyScan .truth
  | bodyFacts : Field .bodyScan .flow

def Field.name : Field a b → List String
  | .firstProcedureParameter => ["first_procedure_parameter"]
  | .procedureCount => ["count"]
  | .procedureParameterCount => ["parameter_count"]
  | .procedureFormalFirst => ["first"]
  | .procedureFormalAfter => ["after"]
  | .procedureFormalKind => ["kind"]
  | .procedureFormalBounds => ["bounds"]
  | .procedureFormalMode => ["mode"]
  | .procedureStepState => ["state"]
  | .procedureStepClosed => ["closed"]
  | .scalarNames => ["scalar_names"]
  | .assignedInFunctions => ["assigned_in_functions"]
  | .position => ["position"]
  | .functions => ["functions"]
  | .procedures => ["procedures"]
  | .pure => ["pure"]
  | .hiding => ["hiding"]
  | .firstParameter => ["first_parameter"]
  | .subtypes => ["subtype_names"]
  | .names => ["names"]
  | .scalars => ["scalar_names"]
  | .booleans => ["boolean_names"]
  | .arrays => ["array_names", ".", "names"]
  | .assigned => ["assigned_in_functions"]
  | .integerHidden => ["integer_hidden"]
  | .booleanHidden => ["boolean_hidden"]
  | .functionCount => ["count"]
  | .parameterCount => ["parameter_count"]
  | .scalarCount => ["count"]
  | .booleanCount => ["count"]
  | .typeAfter => ["after"]
  | .typeKind => ["kind"]
  | .typeBounds => ["bounds"]
  | .constraintAfter => ["after"]
  | .constraintBounds => ["bounds"]
  | .stepState => ["state"]
  | .stepClosed => ["closed"]
  | .formalFirst => ["first"]
  | .formalAfter => ["after"]
  | .formalKind => ["kind"]
  | .formalBounds => ["bounds"]
  | .bodyPosition => ["position"]
  | .bodyAssigned => ["assigned"]
  | .bodyFacts => ["facts"]

def Field.get : Field a b → a.meaning → b.meaning
  | .firstProcedureParameter, value => value.firstProcedureParameter
  | .procedureCount, value => value.items.length
  | .procedureParameterCount, value => value.parameters.length
  | .procedureFormalFirst, value => value.first
  | .procedureFormalAfter, value => value.after
  | .procedureFormalKind, value => value.kind
  | .procedureFormalBounds, value => value.bounds
  | .procedureFormalMode, value => value.mode
  | .procedureStepState, value => value.state
  | .procedureStepClosed, value => value.closed
  | .scalarNames, value => value.scalarNames
  | .assignedInFunctions, value => value.assignedInFunctions
  | .position, value => value.position
  | .functions, value => value.functions
  | .procedures, value => value.procedures
  | .pure, value => value.pure
  | .hiding, value => value.hiding
  | .firstParameter, value => value.firstParameter
  | .subtypes, value => value.subtypeNames
  | .names, value => value.names
  | .scalars, value => value.scalarNames
  | .booleans, value => value.booleanNames
  | .arrays, value => value.arrayNames.names
  | .assigned, value => value.assignedInFunctions
  | .integerHidden, value => value.integerHidden
  | .booleanHidden, value => value.booleanHidden
  | .functionCount, value => value.items.length
  | .parameterCount, value => value.parameters.length
  | .scalarCount, value => value.length
  | .booleanCount, value => value.length
  | .typeAfter, value => value.after
  | .typeKind, value => value.kind
  | .typeBounds, value => value.bounds
  | .constraintAfter, value => value.after
  | .constraintBounds, value => value.bounds
  | .stepState, value => value.state
  | .stepClosed, value => value.closed
  | .formalFirst, value => value.first
  | .formalAfter, value => value.after
  | .formalKind, value => value.kind
  | .formalBounds, value => value.bounds
  | .bodyPosition, value => value.position
  | .bodyAssigned, value => value.assigned
  | .bodyFacts, value => value.facts

inductive StateField : Ty → Type
  | firstProcedureParameter : StateField .number
  | scalarNames : StateField .scalars
  | assignedInFunctions : StateField .truth
  | position : StateField .number
  | functions : StateField .metadata
  | procedures : StateField .procedures
  | pure : StateField .truth
  | «hiding» : StateField .hidden
  | firstParameter : StateField .number
  | subtypes : StateField .subtypes
  | scalars : StateField .scalars
  | booleans : StateField .booleans
  | assigned : StateField .truth

def StateField.name : StateField ty → String
  | .firstProcedureParameter => "first_procedure_parameter"
  | .scalarNames => "scalar_names"
  | .assignedInFunctions => "assigned_in_functions"
  | .position => "position"
  | .functions => "functions"
  | .procedures => "procedures"
  | .pure => "pure"
  | .hiding => "hiding"
  | .firstParameter => "first_parameter"
  | .subtypes => "subtype_names"
  | .scalars => "scalar_names"
  | .booleans => "boolean_names"
  | .assigned => "assigned_in_functions"

def StateField.set : StateField ty → ParserState → ty.meaning → ParserState
  | .firstProcedureParameter, state, value => {state with firstProcedureParameter := value}
  | .scalarNames, state, value => {state with scalarNames := value}
  | .assignedInFunctions, state, value => {state with assignedInFunctions := value}
  | .position, state, value => {state with position := value}
  | .functions, state, value => {state with functions := value}
  | .procedures, state, value => {state with procedures := value}
  | .pure, state, value => {state with pure := value}
  | .hiding, state, value => {state with «hiding» := value}
  | .firstParameter, state, value => {state with firstParameter := value}
  | .subtypes, state, value => {state with subtypeNames := value}
  | .scalars, state, value => {state with scalarNames := value}
  | .booleans, state, value => {state with booleanNames := value}
  | .assigned, state, value => {state with assignedInFunctions := value}

inductive Token | procedureKeyword | outKeyword | assignment | booleanName | colon | inKeyword | semicolon | rightParenthesis | beginKeyword
  | returnKeyword | endKeyword | functionKeyword | leftParenthesis | isKeyword
  deriving DecidableEq, Repr

def Token.name : Token → String
  | .procedureKeyword => "procedure_keyword" | .outKeyword => "out_keyword" | .assignment => "assignment"
  | .booleanName => "boolean_name" | .colon => "colon" | .inKeyword => "in_keyword"
  | .semicolon => "semicolon" | .rightParenthesis => "right_parenthesis" | .beginKeyword => "begin_keyword"
  | .returnKeyword => "return_keyword" | .endKeyword => "end_keyword" | .functionKeyword => "function_keyword"
  | .leftParenthesis => "left_parenthesis" | .isKeyword => "is_keyword"
def Token.shell : Token → ShellToken
  | .procedureKeyword => .word "procedure" | .outKeyword => .word "out" | .assignment => .symbol ":="
  | .booleanName => .word "boolean" | .colon => .symbol ":" | .inKeyword => .word "in"
  | .semicolon => .symbol ";" | .rightParenthesis => .symbol ")" | .beginKeyword => .word "begin"
  | .returnKeyword => .word "return" | .endKeyword => .word "end" | .functionKeyword => .word "function"
  | .leftParenthesis => .symbol "(" | .isKeyword => .word "is"

theorem Token.name_eq_tokenName_shell : ∀ t : Token, t.name = Expressions.tokenName t.shell := by
  intro t; cases t <;> rfl

inductive Capacity | procedures | procedureFormals | functions | formals | scalars | booleans
  deriving DecidableEq, Repr

def Capacity.name : Capacity → List String
  | .procedures => ["procedures", ".", "max_procedures"] | .procedureFormals => ["procedures", ".", "max_formals"]
  | .functions => ["functions", ".", "max_functions"] | .formals => ["functions", ".", "max_formals"]
  | .scalars => ["scalar_expressions", ".", "max_bindings"] | .booleans => ["max_boolean_bindings"]
def Capacity.value : Capacity → Nat
  | .procedures => ProcedureBindings.maxProcedures | .procedureFormals => ProcedureBindings.maxFormals
  | .functions => FunctionBindings.maxFunctions | .formals => FunctionBindings.maxFormals
  | .scalars => ScalarExpression.maxBindings | .booleans => BooleanBindings.maxBindings

inductive Expr : Ty → Type
  | neMode : Expr .mode → Expr .mode → Expr .truth
  | procedureScalarBinding : Expr .procedureFormal → Expr .scalarBinding
  | mode : ProcedureBindings.Mode → Expr .mode
  | endStop : Expr .stop
  | procedureFormalAt : Expr .procedures → Expr .number → Expr .procedureFormal
  | procedureFormal : Expr .number → Expr .number → Expr .kind → Expr .interval → Expr .mode → Expr .procedureFormal
  | procedureSignature : Expr .number → Expr .number → Expr .number → Expr .number → Expr .procedureSignature
  | procedureStepResult : Expr .state → Expr .truth → Expr .procedureStep
  | appendProcedureBoolean : Expr .state → Expr .procedureFormal → Expr .state
  | anyWritable : Expr .procedures → Expr .number → Expr .truth
  | eqMode : Expr .mode → Expr .mode → Expr .truth
  | number : Nat → Expr .number | truth : Bool → Expr .truth
  | token : Token → Expr .token | kind : FunctionBindings.ScalarKind → Expr .kind
  | empty : Expr .interval | full : Expr .interval | initial : Expr .state | invalid : Expr .state
  | emptyProcedures : Expr .procedures
  | capacity : Capacity → Expr .number | returnStop : Expr .stop
  | variable (name : String) : Expr ty
  | function (fn : Function) : Expr fn.type
  | app : Expr (.arrow a b) → Expr a → Expr b
  | field : Field a b → Expr a → Expr b
  | formalAt : Expr .metadata → Expr .number → Expr .formal
  | update : StateField ty → Expr .state → Expr ty → Expr .state
  | updateDeclarationCount : Expr .context → Expr .number → Expr .context
  | addHiddenCalls : Expr .subtypes → Expr .source → Expr .number → Expr .number → Expr .subtypes
  | appendBoolean : Expr .state → Expr .formal → Expr .state
  | typeResult : Expr .number → Expr .kind → Expr .interval → Expr .typeResult
  | stepResult : Expr .state → Expr .truth → Expr .stepResult
  | formal : Expr .number → Expr .number → Expr .kind → Expr .interval → Expr .formal
  | signature : Expr .number → Expr .number → Expr .number → Expr .number → Expr .kind → Expr .interval → Expr .signature
  | scalarBinding : Expr .number → Expr .number → Expr .interval → Expr .truth → Expr .interval → Expr .truth → Expr .scalarBinding
  | scan : Expr .state → Expr .truth → Expr .truth → Expr .scan
  | add : Expr .number → Expr .number → Expr .number
  | sub : Expr .number → Expr .number → Expr .number
  | eq : Expr .number → Expr .number → Expr .truth
  | ne : Expr .number → Expr .number → Expr .truth
  | le : Expr .number → Expr .number → Expr .truth
  | gt : Expr .number → Expr .number → Expr .truth
  | eqKind : Expr .kind → Expr .kind → Expr .truth
  | andThen : Expr .truth → Expr .truth → Expr .truth
  | orElse : Expr .truth → Expr .truth → Expr .truth
  | or : Expr .truth → Expr .truth → Expr .truth
  | not : Expr .truth → Expr .truth
  | group : Expr ty → Expr ty
  | ite : Expr .truth → Expr ty → Expr ty → Expr ty
  | elsif : Expr .truth → Expr ty → Expr ty → Expr ty
  | declare : Expr ty → Expr ty
  | letValue (name : String) : Expr a → Expr b → Expr b
  | beginValue : Expr ty → Expr ty

abbrev Locals := (ty : Ty) → String → ty.meaning

def Locals.set (locals : Locals) (ty : Ty) (name : String) (value : ty.meaning) : Locals :=
  fun other actual => if same : other = ty then
    if actual = name then same.symm ▸ value else locals other actual
  else locals other actual

def Expr.eval (calls : Calls) (locals : Locals) : Expr ty → ty.meaning
  | .neMode left right => decide (left.eval calls locals ≠ right.eval calls locals)
  | .procedureScalarBinding parameter =>
      let item := parameter.eval calls locals
      ⟨item.first, item.after, item.bounds, false, item.bounds, decide (item.mode ≠ .input)⟩
  | .mode value => value | .endStop => .endOnly
  | .procedureFormalAt procedures index => ProcedureBindings.parameter (procedures.eval calls locals) (index.eval calls locals)
  | .procedureFormal first after scalarKind bounds parameterMode =>
      ⟨first.eval calls locals, after.eval calls locals, scalarKind.eval calls locals, bounds.eval calls locals, parameterMode.eval calls locals⟩
  | .procedureSignature first after formalFirst count =>
      ⟨first.eval calls locals, after.eval calls locals, formalFirst.eval calls locals, count.eval calls locals⟩
  | .procedureStepResult state closed => ⟨state.eval calls locals, closed.eval calls locals⟩
  | .appendProcedureBoolean frame parameter =>
      let before := frame.eval calls locals
      let item := parameter.eval calls locals
      {before with booleanNames := before.booleanNames ++ [⟨item.first, item.after, decide (item.mode ≠ .input)⟩]}
  | .anyWritable procedures first =>
      ((procedures.eval calls locals).parameters.drop (first.eval calls locals - 1)).any (fun parameter => parameter.mode != .input)
  | .eqMode left right => decide (left.eval calls locals = right.eval calls locals)
  | .number value => value | .truth value => value | .token value => value.shell | .kind value => value
  | .empty => .empty | .full => .full | .initial => initialState | .invalid => invalidState
  | .emptyProcedures => {}
  | .capacity bound => bound.value | .returnStop => .returnOnly
  | .variable name => locals _ name | .function fn => calls fn
  | .app fn value => fn.eval calls locals (value.eval calls locals)
  | .field projection value => projection.get (value.eval calls locals)
  | .formalAt functions index => FunctionBindings.parameter (functions.eval calls locals) (index.eval calls locals)
  | .update projection state value => projection.set (state.eval calls locals) (value.eval calls locals)
  | .updateDeclarationCount context count => {context.eval calls locals with declarationCount := count.eval calls locals}
  | .addHiddenCalls subtypes text first after =>
      let before := subtypes.eval calls locals
      let matchesOperation (operation : Names.Operation) :=
        calls .nameIs (text.eval calls locals) (first.eval calls locals) (after.eval calls locals) operation.name
      {before with hiddenCalls := {
        output := before.hiddenCalls.output || matchesOperation .output
        partialOutput := before.hiddenCalls.partialOutput || matchesOperation .partialOutput
        argument := before.hiddenCalls.argument || matchesOperation .argument
        validity := before.hiddenCalls.validity || matchesOperation .validity
        reject := before.hiddenCalls.reject || matchesOperation .reject }}
  | .appendBoolean frame parameter =>
      let before := frame.eval calls locals
      let item := parameter.eval calls locals
      {before with booleanNames := before.booleanNames ++ [⟨item.first, item.after, false⟩]}
  | .typeResult after scalarKind bounds => ⟨after.eval calls locals, scalarKind.eval calls locals, bounds.eval calls locals⟩
  | .stepResult state closed => ⟨state.eval calls locals, closed.eval calls locals⟩
  | .formal first after scalarKind bounds => ⟨first.eval calls locals, after.eval calls locals, scalarKind.eval calls locals, bounds.eval calls locals⟩
  | .signature first after formalFirst count scalarKind bounds => ⟨first.eval calls locals, after.eval calls locals,
      formalFirst.eval calls locals, count.eval calls locals, scalarKind.eval calls locals, bounds.eval calls locals⟩
  | .scalarBinding first after bounds mutable declared static => ⟨first.eval calls locals, after.eval calls locals,
      bounds.eval calls locals, mutable.eval calls locals, declared.eval calls locals, static.eval calls locals⟩
  | .scan state assigned output => ⟨state.eval calls locals, assigned.eval calls locals, output.eval calls locals⟩
  | .add left right => left.eval calls locals + right.eval calls locals
  | .sub left right => left.eval calls locals - right.eval calls locals
  | .eq left right => decide (left.eval calls locals = right.eval calls locals)
  | .ne left right => decide (left.eval calls locals ≠ right.eval calls locals)
  | .le left right => decide (left.eval calls locals ≤ right.eval calls locals)
  | .gt left right => decide (left.eval calls locals > right.eval calls locals)
  | .eqKind left right => decide (left.eval calls locals = right.eval calls locals)
  | .andThen left right => left.eval calls locals && right.eval calls locals
  | .orElse left right | .or left right => left.eval calls locals || right.eval calls locals
  | .not value => !value.eval calls locals
  | .group value | .declare value | .beginValue value => value.eval calls locals
  | .ite condition yes no | .elsif condition yes no =>
      if condition.eval calls locals then yes.eval calls locals else no.eval calls locals
  | .letValue name value body => body.eval calls (locals.set _ name (value.eval calls locals))

def separated (items : List (List String)) : List String := (items.intersperse [","]).flatten

def Expr.render : Expr ty → List String
  | .neMode left right => left.render ++ ["/="] ++ right.render
  | .procedureScalarBinding parameter => ["(", "first", "=>"] ++ parameter.render ++
      [".", "first", ",", "after", "=>"] ++ parameter.render ++ [".", "after", ",", "bounds", "=>"] ++
      parameter.render ++ [".", "bounds", ",", "static", "=>", "false", ",", "declared_bounds", "=>"] ++
      parameter.render ++ [".", "bounds", ",", "mutable", "=>"] ++ parameter.render ++
      [".", "mode", "/=", "procedures", ".", "input", ")"]
  | .mode .input => ["procedures", ".", "input"] | .mode .output => ["procedures", ".", "output"]
  | .mode .inputOutput => ["procedures", ".", "input_output"] | .endStop => ["end_only"]
  | .procedureFormalAt procedures index => procedures.render ++ [".", "parameters", "("] ++ index.render ++ [")"]
  | .procedureFormal first after scalarKind bounds parameterMode =>
      ["("] ++ separated [first.render, after.render, scalarKind.render, bounds.render, parameterMode.render] ++ [")"]
  | .procedureSignature first after formalFirst count =>
      ["("] ++ separated [first.render, after.render, formalFirst.render, count.render] ++ [")"]
  | .procedureStepResult state closed => ["("] ++ separated [state.render, closed.render] ++ [")"]
  | .appendProcedureBoolean frame parameter =>
      ["("] ++ frame.render ++ ["with", "delta", "boolean_names", "=>", "(", "count", "=>"] ++
      frame.render ++ [".", "boolean_names", ".", "count", "+", "1", ",", "items", "=>", "("] ++
      frame.render ++ [".", "boolean_names", ".", "items", "with", "delta"] ++ frame.render ++
      [".", "boolean_names", ".", "count", "+", "1", "=>", "("] ++ parameter.render ++ [".", "first", ","] ++
      parameter.render ++ [".", "after", ","] ++ parameter.render ++
      [".", "mode", "/=", "procedures", ".", "input", ")", ")", ")", ")"]
  | .anyWritable procedures first => ["(", "for", "some", "index", "in"] ++ first.render ++ [".."] ++
      procedures.render ++ [".", "parameter_count", "=>"] ++ procedures.render ++
      [".", "parameters", "(", "index", ")", ".", "mode", "/=", "procedures", ".", "input", ")"]
  | .eqMode left right => left.render ++ ["="] ++ right.render
  | .number value => [toString value] | .truth value => [if value then "true" else "false"]
  | .token value => [value.name] | .kind .integer => ["functions", ".", "integer_kind"]
  | .kind .boolean => ["functions", ".", "boolean_kind"]
  | .empty => ["scalars", ".", "empty"] | .full => ["scalars", ".", "full"]
  | .initial => ["initial_state"] | .invalid => ["invalid_state"]
  | .emptyProcedures => ["procedures", ".", "empty_metadata"]
  | .capacity bound => bound.name | .returnStop => ["return_only"]
  | .variable name => [name] | .function fn => fn.name
  | .app fn value => match fn with
    | .app _ _ => fn.render.dropLast ++ [","] ++ value.render ++ [")"]
    | _ => fn.render ++ ["("] ++ value.render ++ [")"]
  | .field projection value => value.render ++ ["."] ++ projection.name
  | .formalAt functions index => functions.render ++ [".", "parameters", "("] ++ index.render ++ [")"]
  | .update projection state value =>
      match state with
      | .update _ _ _ => state.render.dropLast ++ [",", projection.name, "=>"] ++ value.render ++ [")"]
      | _ => ["("] ++ state.render ++ ["with", "delta", projection.name, "=>"] ++ value.render ++ [")"]
  | .updateDeclarationCount context count =>
      ["("] ++ context.render ++ ["with", "delta", "declaration_count", "=>"] ++ count.render ++ [")"]
  | .addHiddenCalls subtypes text first after =>
      ["("] ++ subtypes.render ++ ["with", "delta", "hidden_calls", "=>", "(", "for", "operation", "in",
        "names", ".", "operation_kind", "=>"] ++ subtypes.render ++ [".", "hidden_calls", "(", "operation", ")", "or", "else",
        "name_is", "("] ++ separated [text.render, first.render, after.render,
          ["(", "case", "operation", "is", "when", "names", ".", "output_call", "=>", "\"put_line\"", ",",
           "when", "names", ".", "partial_output_call", "=>", "\"put\"", ",",
           "when", "names", ".", "argument_call", "=>", "\"first_or_default\"", ",",
           "when", "names", ".", "validity_call", "=>", "\"input_is_valid\"", ",",
           "when", "names", ".", "reject_call", "=>", "\"reject\"", ")"]] ++ [")", ")", ")"]
  | .appendBoolean frame parameter =>
      ["("] ++ frame.render ++ ["with", "delta", "boolean_names", "=>", "(", "count", "=>"] ++
      frame.render ++ [".", "boolean_names", ".", "count", "+", "1", ",", "items", "=>", "("] ++
      frame.render ++ [".", "boolean_names", ".", "items", "with", "delta"] ++ frame.render ++
      [".", "boolean_names", ".", "count", "+", "1", "=>", "("] ++ parameter.render ++ [".", "first", ","] ++
      parameter.render ++ [".", "after", ",", "false", ")", ")", ")", ")"]
  | .typeResult after scalarKind bounds => ["("] ++ separated [after.render, scalarKind.render, bounds.render] ++ [")"]
  | .stepResult state closed => ["("] ++ separated [state.render, closed.render] ++ [")"]
  | .formal first after scalarKind bounds => ["("] ++ separated [first.render, after.render, scalarKind.render, bounds.render] ++ [")"]
  | .signature first after formalFirst count scalarKind bounds => ["("] ++
      separated [first.render, after.render, formalFirst.render, count.render, scalarKind.render, bounds.render] ++ [")"]
  | .scalarBinding first after bounds mutable declared static => ["("] ++
      separated [first.render, after.render, bounds.render, mutable.render, declared.render, static.render] ++ [")"]
  | .scan state assigned output => ["("] ++ separated [state.render, assigned.render, output.render] ++ [")"]
  | .add left right => left.render ++ ["+"] ++ right.render
  | .sub left right => left.render ++ ["-"] ++ right.render
  | .eq left right | .eqKind left right => left.render ++ ["="] ++ right.render
  | .ne left right => left.render ++ ["/="] ++ right.render
  | .le left right => left.render ++ ["<="] ++ right.render
  | .gt left right => left.render ++ [">"] ++ right.render
  | .andThen left right => left.render ++ ["and", "then"] ++ right.render
  | .orElse left right => left.render ++ ["or", "else"] ++ right.render
  | .or left right => left.render ++ ["or"] ++ right.render
  | .not value => ["not"] ++ value.render
  | .group value => ["("] ++ value.render ++ [")"]
  | .ite condition yes no => ["if"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .elsif condition yes no => ["elsif"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .declare value => ["declare"] ++ value.render
  | @Expr.letValue a _ name value body => [name, ":", "constant"] ++ a.name ++ [":="] ++ value.render ++ [";"] ++ body.render
  | .beginValue value => ["begin"] ++ value.render

def apply2 (fn : Expr (.arrow a (.arrow b c))) (x : Expr a) (y : Expr b) : Expr c := .app (.app fn x) y
def apply3 (fn : Expr (.arrow a (.arrow b (.arrow c d)))) (x : Expr a) (y : Expr b) (z : Expr c) : Expr d := .app (apply2 fn x y) z
def apply4 (fn : Expr (.arrow a (.arrow b (.arrow c (.arrow d e)))))
    (x : Expr a) (y : Expr b) (z : Expr c) (u : Expr d) : Expr e := .app (apply3 fn x y z) u
def apply5 (fn : Expr (.arrow a (.arrow b (.arrow c (.arrow d (.arrow e f))))))
    (x : Expr a) (y : Expr b) (z : Expr c) (u : Expr d) (v : Expr e) : Expr f := .app (apply4 fn x y z u) v
def apply6 (fn : Expr (.arrow a (.arrow b (.arrow c (.arrow d (.arrow e (.arrow f g)))))))
    (x : Expr a) (y : Expr b) (z : Expr c) (u : Expr d) (v : Expr e) (w : Expr f) : Expr g :=
  .app (apply5 fn x y z u v) w

inductive Command : Ty → Type
  | letValue (name : String) : Expr a → Command b → Command b
  /-- Exact Static metadata lemma call. Its native contract is checked separately;
  the call and its arguments are erased from runtime evaluation. -/
  | staticProcedureMetadataAppend : Expr .source → Expr .procedures → Expr .procedureSignature →
      Command ty → Command ty
  /-- Exact Static assertion used at the procedure body's initial flow.
  Native verification discharges it; its checked erasure has no runtime effect. -/
  | staticInitialFlow : Expr .bodyScan → Expr .context → Command ty → Command ty
  | beginBody : Command ty → Command ty
  | guard : Expr .truth → Expr ty → Command ty → Command ty
  | block : Command ty → Command ty
  | returned : Expr ty → Command ty

def Command.eval (calls : Calls) (locals : Locals) : Command ty → ty.meaning
  | .letValue name value body => body.eval calls (locals.set _ name (value.eval calls locals))
  | .staticProcedureMetadataAppend _ _ _ body => body.eval calls locals
  | .staticInitialFlow _ _ body => body.eval calls locals
  | .beginBody body | .block body => body.eval calls locals
  | .guard condition rejected body =>
      if condition.eval calls locals then rejected.eval calls locals else body.eval calls locals
  | .returned value => value.eval calls locals

def Command.render : Command ty → List String
  | @Command.letValue a _ name value body =>
      [name, ":", "constant"] ++ a.name ++ [":="] ++ value.render ++ [";"] ++ body.render
  | .staticProcedureMetadataAppend text environment item body =>
      ["lemma_procedure_metadata_append", "("] ++
      separated [text.render, environment.render, item.render] ++ [")", ";"] ++ body.render
  | .staticInitialFlow scan context body => ["pragma", "assert", "(", "static", "=>"] ++
      scan.render ++ [".", "facts", ".", "count", "="] ++
      context.render ++ [".", "scalar_names", ".", "count", "and", "then", "(", "for", "all", "index", "in"] ++
      scan.render ++ [".", "facts", ".", "values", "'", "range", "=>"] ++
      scan.render ++ [".", "facts", ".", "values", "(", "index", ")", "="] ++
      context.render ++ [".", "scalar_names", ".", "items", "(", "index", ")", ".", "bounds", ")", ")", ";"] ++
      body.render
  | .beginBody body => ["begin"] ++ body.render
  | .guard condition rejected body => ["if"] ++ condition.render ++ ["then", "return"] ++ rejected.render ++
      [";", "end", "if", ";"] ++ body.render
  | .block body => ["declare"] ++ body.render ++ ["end", ";"]
  | .returned value => ["return"] ++ value.render ++ [";"]

abbrev Scope := List (Ty × String)

def Expr.scoped (scope : Scope) : Expr ty → Bool
  | .neMode left right => left.scoped scope && right.scoped scope
  | .procedureScalarBinding parameter => parameter.scoped scope
  | .mode _ | .endStop => true
  | .procedureFormalAt procedures index => procedures.scoped scope && index.scoped scope
  | .procedureFormal first after scalarKind bounds parameterMode => first.scoped scope && after.scoped scope &&
      scalarKind.scoped scope && bounds.scoped scope && parameterMode.scoped scope
  | .procedureSignature first after formalFirst count => first.scoped scope && after.scoped scope &&
      formalFirst.scoped scope && count.scoped scope
  | .procedureStepResult state closed => state.scoped scope && closed.scoped scope
  | .appendProcedureBoolean frame parameter => frame.scoped scope && parameter.scoped scope
  | .anyWritable procedures first => !(scope.any (·.2 == "index")) && procedures.scoped scope && first.scoped scope
  | .eqMode left right => left.scoped scope && right.scoped scope
  | .number _ | .truth _ | .token _ | .kind _ | .empty | .full | .initial | .invalid | .emptyProcedures |
    .capacity _ | .returnStop | .function _ => true
  | .variable name => scope.contains (ty, name)
  | .app fn value => fn.scoped scope && value.scoped scope
  | .field _ value => value.scoped scope
  | .formalAt functions index => functions.scoped scope && index.scoped scope
  | .update _ state value => state.scoped scope && value.scoped scope
  | .updateDeclarationCount context count => context.scoped scope && count.scoped scope
  | .addHiddenCalls subtypes text first after => subtypes.scoped scope && text.scoped scope && first.scoped scope && after.scoped scope
  | .appendBoolean frame parameter => frame.scoped scope && parameter.scoped scope
  | .typeResult after scalarKind bounds => after.scoped scope && scalarKind.scoped scope && bounds.scoped scope
  | .stepResult state closed => state.scoped scope && closed.scoped scope
  | .formal first after scalarKind bounds => first.scoped scope && after.scoped scope && scalarKind.scoped scope && bounds.scoped scope
  | .signature first after formalFirst count scalarKind bounds => first.scoped scope && after.scoped scope &&
      formalFirst.scoped scope && count.scoped scope && scalarKind.scoped scope && bounds.scoped scope
  | .scalarBinding first after bounds mutable declared static => first.scoped scope && after.scoped scope &&
      bounds.scoped scope && mutable.scoped scope && declared.scoped scope && static.scoped scope
  | .scan state assigned output => state.scoped scope && assigned.scoped scope && output.scoped scope
  | .add left right | .sub left right | .eq left right | .ne left right | .le left right | .gt left right |
    .eqKind left right | .andThen left right | .orElse left right | .or left right => left.scoped scope && right.scoped scope
  | .not value | .group value | .declare value | .beginValue value => value.scoped scope
  | .ite condition yes no | .elsif condition yes no => condition.scoped scope && yes.scoped scope && no.scoped scope
  | @Expr.letValue a _ name value body => value.scoped scope && !(scope.any (·.2 == name)) && body.scoped ((a, name) :: scope)

def Command.scoped (scope : Scope) : Command ty → Bool
  | @Command.letValue a _ name value body => value.scoped scope && !(scope.any (·.2 == name)) && body.scoped ((a, name) :: scope)
  | .staticProcedureMetadataAppend text environment item body =>
      text.scoped scope && environment.scoped scope && item.scoped scope && body.scoped scope
  | .staticInitialFlow scan context body => !(scope.any (·.2 == "index")) &&
      scan.scoped scope && context.scoped scope && body.scoped scope
  | .beginBody body | .block body => body.scoped scope
  | .guard condition rejected body => condition.scoped scope && rejected.scoped scope && body.scoped scope
  | .returned value => value.scoped scope

/-- Selected and indexed components require a name, not a parenthesized
expression or an aggregate. Delta-aggregate bases remain ordinary expressions. -/
def Expr.prefix : Expr ty → Bool
  | .neMode _ _ | .procedureScalarBinding _ => false
  | .mode _ | .endStop | .procedureFormalAt _ _ => true
  | .procedureFormal _ _ _ _ _ | .procedureSignature _ _ _ _ | .procedureStepResult _ _ |
    .appendProcedureBoolean _ _ | .anyWritable _ _ | .eqMode _ _ => false
  | .token _ | .kind _ | .empty | .full | .initial | .invalid | .emptyProcedures | .capacity _ |
    .returnStop | .variable _ | .function _ | .app _ _ | .field _ _ | .formalAt _ _ => true
  | .number _ | .truth _ | .update _ _ _ | .updateDeclarationCount _ _ |
    .addHiddenCalls _ _ _ _ | .appendBoolean _ _ | .typeResult _ _ _ | .stepResult _ _ |
    .formal _ _ _ _ | .signature _ _ _ _ _ _ | .scalarBinding _ _ _ _ _ _ | .scan _ _ _ |
    .add _ _ | .sub _ _ | .eq _ _ | .ne _ _ | .le _ _ | .gt _ _ | .eqKind _ _ |
    .andThen _ _ | .orElse _ _ | .or _ _ | .not _ | .group _ | .ite _ _ _ | .elsif _ _ _ |
    .declare _ | .letValue _ _ _ | .beginValue _ => false

/-- The primary/operator categories reject implicit grouping. Parentheses and
native declare expressions are retained explicitly in the syntax. -/
def Expr.primary : Expr ty → Bool
  | .neMode _ _ => false
  | .procedureScalarBinding _ => true
  | .mode _ | .endStop | .procedureFormalAt _ _ | .procedureFormal _ _ _ _ _ |
    .procedureSignature _ _ _ _ | .procedureStepResult _ _ | .appendProcedureBoolean _ _ | .anyWritable _ _ => true
  | .eqMode _ _ => false
  | .number _ | .truth _ | .token _ | .kind _ | .empty | .full | .initial | .invalid | .emptyProcedures |
    .capacity _ | .returnStop | .variable _ | .function _ | .app _ _ | .field _ _ |
    .formalAt _ _ | .update _ _ _ | .updateDeclarationCount _ _ | .addHiddenCalls _ _ _ _ |
    .appendBoolean _ _ | .typeResult _ _ _ | .stepResult _ _ | .formal _ _ _ _ |
    .signature _ _ _ _ _ _ | .scalarBinding _ _ _ _ _ _ | .scan _ _ _ | .group _ => true
  | .add _ _ | .sub _ _ | .eq _ _ | .ne _ _ | .le _ _ | .gt _ _ | .eqKind _ _ |
    .andThen _ _ | .orElse _ _ | .or _ _ | .not _ | .ite _ _ _ | .elsif _ _ _ |
    .declare _ | .letValue _ _ _ | .beginValue _ => false

def Expr.simple : Expr ty → Bool
  | .add _ _ | .sub _ _ => true
  | value => value.primary

def Expr.relation : Expr ty → Bool
  | .neMode _ _ => true
  | .eq _ _ | .ne _ _ | .le _ _ | .gt _ _ | .eqKind _ _ | .eqMode _ _ | .not _ => true
  | value => value.simple

def Expr.andHead : Expr .truth → Bool
  | .andThen _ _ => true
  | value => value.relation

def Expr.orElseHead : Expr .truth → Bool
  | .orElse _ _ => true
  | value => value.relation

def Expr.orHead : Expr .truth → Bool
  | .or _ _ => true
  | value => value.relation

def Expr.callHead : Expr ty → Bool
  | .function _ | .app _ _ => true
  | _ => false

def Expr.value : Expr ty → Bool
  | .andThen _ _ | .orElse _ _ | .or _ _ => true
  | value => value.relation

def Expr.branch : Expr ty → Bool
  | .elsif _ _ _ => true
  | value => value.value

def Expr.declarations : Expr ty → Bool
  | .letValue _ _ _ | .beginValue _ => true
  | _ => false

def Expr.wellFormed : Expr ty → Bool
  | .neMode left right => left.simple && right.simple && left.wellFormed && right.wellFormed
  | .procedureScalarBinding parameter => parameter.prefix && parameter.wellFormed
  | .mode _ | .endStop => true
  | .procedureFormalAt procedures index => procedures.prefix && index.value && procedures.wellFormed && index.wellFormed
  | .procedureFormal first after scalarKind bounds parameterMode =>
      first.value && after.value && scalarKind.value && bounds.value && parameterMode.value &&
      first.wellFormed && after.wellFormed && scalarKind.wellFormed && bounds.wellFormed && parameterMode.wellFormed
  | .procedureSignature first after formalFirst count => first.value && after.value && formalFirst.value && count.value &&
      first.wellFormed && after.wellFormed && formalFirst.wellFormed && count.wellFormed
  | .procedureStepResult state closed => state.value && closed.value && state.wellFormed && closed.wellFormed
  | .appendProcedureBoolean frame parameter => frame.prefix && parameter.prefix && frame.wellFormed && parameter.wellFormed
  | .anyWritable procedures first => procedures.prefix && first.value && procedures.wellFormed && first.wellFormed
  | .eqMode left right => left.simple && right.simple && left.wellFormed && right.wellFormed
  | .number _ | .truth _ | .token _ | .kind _ | .empty | .full | .initial | .invalid | .emptyProcedures |
    .capacity _ | .returnStop | .variable _ | .function _ => true
  | .app fn value => fn.callHead && value.value && fn.wellFormed && value.wellFormed
  | .field _ value => value.prefix && value.wellFormed
  | .formalAt functions index => functions.prefix && index.value && functions.wellFormed && index.wellFormed
  | .update _ state value => state.primary && value.value && state.wellFormed && value.wellFormed
  | .updateDeclarationCount context count => context.primary && count.value && context.wellFormed && count.wellFormed
  | .addHiddenCalls subtypes text first after => subtypes.prefix && text.value && first.value && after.value &&
      subtypes.wellFormed && text.wellFormed && first.wellFormed && after.wellFormed
  | .appendBoolean frame parameter => frame.prefix && parameter.prefix && frame.wellFormed && parameter.wellFormed
  | .typeResult after scalarKind bounds => after.value && scalarKind.value && bounds.value && after.wellFormed && scalarKind.wellFormed && bounds.wellFormed
  | .stepResult state closed => state.value && closed.value && state.wellFormed && closed.wellFormed
  | .formal first after scalarKind bounds => first.value && after.value && scalarKind.value && bounds.value &&
      first.wellFormed && after.wellFormed && scalarKind.wellFormed && bounds.wellFormed
  | .signature first after formalFirst count scalarKind bounds => first.value && after.value && formalFirst.value &&
      count.value && scalarKind.value && bounds.value && first.wellFormed && after.wellFormed &&
      formalFirst.wellFormed && count.wellFormed && scalarKind.wellFormed && bounds.wellFormed
  | .scalarBinding first after bounds mutable declared static => first.value && after.value && bounds.value &&
      mutable.value && declared.value && static.value && first.wellFormed && after.wellFormed &&
      bounds.wellFormed && mutable.wellFormed && declared.wellFormed && static.wellFormed
  | .scan state assigned output => state.value && assigned.value && output.value && state.wellFormed && assigned.wellFormed && output.wellFormed
  | .add left right | .sub left right => left.simple && right.primary && left.wellFormed && right.wellFormed
  | .eq left right | .ne left right | .le left right | .gt left right | .eqKind left right =>
      left.simple && right.simple && left.wellFormed && right.wellFormed
  | .andThen left right => left.andHead && right.relation && left.wellFormed && right.wellFormed
  | .orElse left right => left.orElseHead && right.relation && left.wellFormed && right.wellFormed
  | .or left right => left.orHead && right.relation && left.wellFormed && right.wellFormed
  | .not value => value.primary && value.wellFormed
  | .group value => (value.value || (match value with | .declare _ | .ite _ _ _ => true | _ => false)) && value.wellFormed
  | .ite condition yes no | .elsif condition yes no => condition.value && yes.value && no.branch &&
      condition.wellFormed && yes.wellFormed && no.wellFormed
  | .declare value => value.declarations && value.wellFormed
  | .letValue _ value body => value.value && body.declarations && value.wellFormed && body.wellFormed
  | .beginValue value => value.value && value.wellFormed

def Command.wellFormed : Command ty → Bool
  | .letValue _ value body => value.value && value.wellFormed && body.wellFormed
  | .staticProcedureMetadataAppend text environment item body =>
      text.value && environment.value && item.value &&
      text.wellFormed && environment.wellFormed && item.wellFormed && body.wellFormed
  | .staticInitialFlow scan context body => scan.prefix && context.prefix &&
      scan.wellFormed && context.wellFormed && body.wellFormed
  | .beginBody body | .block body => body.wellFormed
  | .guard condition rejected body => condition.value && rejected.value && condition.wellFormed && rejected.wellFormed && body.wellFormed
  | .returned value => value.value && value.wellFormed

/-- Erasure preserves every continuation and linked runtime interpretation.
The native proof discharges the separately source-checked lemma contract. -/
theorem static_procedure_metadata_append_erased (calls : Calls) (locals : Locals)
    (text : Expr .source) (environment : Expr .procedures) (item : Expr .procedureSignature)
    (body : Command ty) :
    (Command.staticProcedureMetadataAppend text environment item body).eval calls locals =
      body.eval calls locals := rfl

/-- The exact call retains argument order, recursively checks all arguments and
the continuation, and introduces no bindings into the continuation's scope. -/
theorem static_procedure_metadata_append_source_guards :
    let text : Expr .source := .variable "text"
    let frame : Expr .state := .variable "frame"
    let environment : Expr .procedures := .field .procedures frame
    let item : Expr .procedureSignature :=
      .procedureSignature (.number 1) (.number 2) (.number 1) (.number 1)
    let done : Command .state := .returned .invalid
    let scope : Scope := [(.source, "text"), (.state, "frame")]
    (Command.staticProcedureMetadataAppend text environment item done).render =
      ["lemma_procedure_metadata_append", "(", "text", ",", "frame", ".", "procedures", ",",
       "(", "1", ",", "2", ",", "1", ",", "1", ")", ")", ";", "return", "invalid_state", ";"] ∧
    (Command.staticProcedureMetadataAppend text environment item done).wellFormed = true ∧
    (Command.staticProcedureMetadataAppend text environment item done).scoped scope = true ∧
    (Command.staticProcedureMetadataAppend (.beginValue text) environment item done).wellFormed = false ∧
    (Command.staticProcedureMetadataAppend text (.field .procedures (.group frame)) item done).wellFormed = false ∧
    (Command.staticProcedureMetadataAppend text environment
      (.procedureSignature (.number 1) (.number 2) (.number 1)
        (.sub (.number 3) (.sub (.number 2) (.number 1)))) done).wellFormed = false ∧
    (Command.staticProcedureMetadataAppend text environment item
      (.returned (.letValue "value" .initial (.beginValue (.variable "value")))) : Command .state).wellFormed = false ∧
    (Command.staticProcedureMetadataAppend text environment item done).scoped [(.state, "frame")] = false ∧
    (Command.staticProcedureMetadataAppend text environment item done).scoped [(.source, "text")] = false ∧
    (Command.staticProcedureMetadataAppend text environment
      (.procedureSignature (.variable "first") (.number 2) (.number 1) (.number 1)) done).scoped scope = false ∧
    (Command.staticProcedureMetadataAppend text environment item
      (.returned (.variable "missing")) : Command .state).scoped scope = false ∧
    (Command.staticProcedureMetadataAppend text environment item
      (.returned (.variable "frame")) : Command .state).scoped scope = true := by
  decide +kernel

/-- Static erasure preserves the continuation for all linked calls and locals;
the native proof, not this equality, discharges the written assertion. -/
theorem static_initial_flow_erased (calls : Calls) (locals : Locals)
    (scan : Expr .bodyScan) (context : Expr .context) (body : Command ty) :
    (Command.staticInitialFlow scan context body).eval calls locals = body.eval calls locals := rfl

/-- Controls for selected prefixes, malformed nested operands/continuations,
missing bindings, capture and quantifier scope. -/
theorem static_initial_flow_source_guards :
    let scan : Expr .bodyScan := .variable "scan"
    let context : Expr .context := .variable "context"
    let done : Command .state := .returned .invalid
    let scope : Scope := [(.bodyScan, "scan"), (.context, "context")]
    (Command.staticInitialFlow scan context done).wellFormed = true ∧
    (Command.staticInitialFlow scan context done).scoped scope = true ∧
    (Command.staticInitialFlow (.group scan) context done).wellFormed = false ∧
    (Command.staticInitialFlow scan (.group context) done).wellFormed = false ∧
    (Command.staticInitialFlow
      (.app (.group (.function .bodyOf)) (.variable "input")) context done).wellFormed = false ∧
    (Command.staticInitialFlow scan
      (.app (.group (.function .contextOf)) (.variable "input")) done).wellFormed = false ∧
    (Command.staticInitialFlow scan context
      (.returned (.letValue "result" .initial (.beginValue (.variable "result")))) : Command .state).wellFormed = false ∧
    (Command.staticInitialFlow scan context done).scoped [(.context, "context")] = false ∧
    (Command.staticInitialFlow scan context done).scoped [(.bodyScan, "scan")] = false ∧
    (Command.staticInitialFlow scan context done).scoped ((.number, "index") :: scope) = false ∧
    (Command.staticInitialFlow scan context
      (.returned (.variable "index") : Command .number)).scoped scope = false := by
  decide +kernel

structure Frame where
  readFrame : ParserState := initialState
  declarationCount : Nat := 0
  procedureParameter : ProcedureBindings.Formal := ProcedureBindings.emptyFormal
  text : Source := []
  state : ParserState := initialState
  outer : ParserState := initialState
  frame : ParserState := initialState
  arguments : Bool := false
  position : Nat := 0
  first : Nat := 0
  after : Nat := 0
  index : Nat := 0
  parameter : FunctionBindings.Formal := FunctionBindings.emptyFormal
  resultType : FunctionTypeResult := ⟨0, .integer, .empty⟩
  context : Predicate.Native.Context := {names := [], dynamicFirst := 0, dynamicAfter := 0}
  scan : Predicate.BodyScan := ⟨0,0,0,⟨PathFacts.Context.empty, []⟩,false,false⟩

def Frame.locals (frame : Frame) : Locals
  | .source, _ => frame.text
  | .state, name => if name = "state" then frame.state else if name = "outer" then frame.outer else if name = "read_frame" then frame.readFrame else frame.frame
  | .number, name => if name = "position" then frame.position else if name = "first" then frame.first else
      if name = "after" then frame.after else if name = "declaration_count" then frame.declarationCount else frame.index
  | .truth, _ => frame.arguments
  | .procedureFormal, _ => frame.procedureParameter
  | .formal, _ => frame.parameter
  | .typeResult, _ => frame.resultType
  | .context, _ => frame.context
  | .bodyScan, _ => frame.scan
  | ty, _ => ty.default

end Silver.Compose.ProcedureDeclarationNative
