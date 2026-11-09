module

public import Silver.FunctionDeclarationAdmission
public import Silver.PredicateNativeState

@[expose] public section

/-! Typed syntax for the actual scalar-function declaration helpers. Calls are
uninterpreted until their native-domain equations are supplied. Record updates,
local declarations and control flow retain their written evaluation order. -/
namespace Silver.Compose.FunctionDeclarationNative

set_option backward.dsimp.instances true

inductive Ty
  | number | truth | source | word | token | kind | interval | state | metadata | formal | signature | hidden | typeResult | stepResult | constraint | names | scalars | scalarBinding | booleans | subtypes | arrays | context | scan | bodyScan | flow | stop
  | arrow (domain codomain : Ty)
  deriving DecidableEq, Repr

@[reducible] def Ty.meaning : Ty → Type
  | .number => Nat
  | .truth => Bool
  | .source => Source
  | .word => String
  | .token => ShellToken
  | .kind => FunctionBindings.ScalarKind
  | .interval => Integer.Interval
  | .state => ParserState
  | .metadata => FunctionBindings.Metadata
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
  | .number => 0
  | .truth => false
  | .source => []
  | .word => ""
  | .token => .symbol ";"
  | .kind => .integer
  | .interval => .empty
  | .state => invalidState
  | .metadata => {}
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
  | .number => ["literal_position"]
  | .truth => ["boolean"]
  | .source => ["string"]
  | .word => ["string"]
  | .token => ["token_kind"]
  | .kind => ["functions", ".", "scalar_kind"]
  | .interval => ["scalars", ".", "interval"]
  | .state => ["parser_state"]
  | .metadata => ["functions", ".", "metadata"]
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
  | skip | nameAfter | nameIs | take | newName | equal | scalarType | lookupString | lookupScalar | lookupBoolean | lookupSubtype | lookupArray | lookupFunction | formalHides | hideName | hiddenOuter | functionType | appendFormal | append | parameterStep | parametersModel | parameters | scalarDeclaration | booleanDeclaration | functionLocal | functionLocalsModel | functionLocals | scalarAppend | appendParameter | parameterFrameModel | parameterFrame | contextOf | bodyOf | bodyTail | actualAfter | returnAfter | functionBody | functionDeclaration
  deriving DecidableEq, Repr

def Function.type : Function → Ty
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
  | .bodyTail => .arrow .source (.arrow .context (.arrow .bodyScan (.arrow .stop (.arrow .metadata (.bodyScan)))))
  | .actualAfter => .arrow .source (.arrow .context (.arrow .number (.arrow .flow (.arrow .formal (.number)))))
  | .returnAfter => .arrow .source (.arrow .context (.arrow .bodyScan (.arrow .typeResult (.number))))
  | .functionBody => .arrow .source (.arrow .state (.arrow .state (.arrow .number (.arrow .number (.arrow .typeResult (.arrow .truth (.state)))))))
  | .functionDeclaration => .arrow .source (.arrow .state (.arrow .truth (.state)))

def Function.name : Function → List String
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
  | .bodyTail => fun text context scan stop functions => Predicate.bodyTail text context.model scan stop functions
  | .actualAfter => fun text context position facts parameter => Predicate.actualAfter text context.model position facts parameter
  | .returnAfter => fun text context scan resultType => functionReturnAfter text context.model scan resultType
  | .functionBody => functionBodyAt
  | .functionDeclaration => functionDeclarationAt

inductive Field : Ty → Ty → Type
  | position : Field .state .number
  | functions : Field .state .metadata
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
  | .position => ["position"]
  | .functions => ["functions"]
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
  | .position, value => value.position
  | .functions, value => value.functions
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
  | position : StateField .number
  | functions : StateField .metadata
  | pure : StateField .truth
  | «hiding» : StateField .hidden
  | firstParameter : StateField .number
  | subtypes : StateField .subtypes
  | scalars : StateField .scalars
  | booleans : StateField .booleans
  | assigned : StateField .truth

def StateField.name : StateField ty → String
  | .position => "position"
  | .functions => "functions"
  | .pure => "pure"
  | .hiding => "hiding"
  | .firstParameter => "first_parameter"
  | .subtypes => "subtype_names"
  | .scalars => "scalar_names"
  | .booleans => "boolean_names"
  | .assigned => "assigned_in_functions"

def StateField.set : StateField ty → ParserState → ty.meaning → ParserState
  | .position, state, value => {state with position := value}
  | .functions, state, value => {state with functions := value}
  | .pure, state, value => {state with pure := value}
  | .hiding, state, value => {state with «hiding» := value}
  | .firstParameter, state, value => {state with firstParameter := value}
  | .subtypes, state, value => {state with subtypeNames := value}
  | .scalars, state, value => {state with scalarNames := value}
  | .booleans, state, value => {state with booleanNames := value}
  | .assigned, state, value => {state with assignedInFunctions := value}

inductive Token | booleanName | colon | inKeyword | semicolon | rightParenthesis | beginKeyword
  | returnKeyword | endKeyword | functionKeyword | leftParenthesis | isKeyword
  deriving DecidableEq, Repr

def Token.name : Token → String
  | .booleanName => "boolean_name" | .colon => "colon" | .inKeyword => "in_keyword"
  | .semicolon => "semicolon" | .rightParenthesis => "right_parenthesis" | .beginKeyword => "begin_keyword"
  | .returnKeyword => "return_keyword" | .endKeyword => "end_keyword" | .functionKeyword => "function_keyword"
  | .leftParenthesis => "left_parenthesis" | .isKeyword => "is_keyword"
def Token.shell : Token → ShellToken
  | .booleanName => .word "boolean" | .colon => .symbol ":" | .inKeyword => .word "in"
  | .semicolon => .symbol ";" | .rightParenthesis => .symbol ")" | .beginKeyword => .word "begin"
  | .returnKeyword => .word "return" | .endKeyword => .word "end" | .functionKeyword => .word "function"
  | .leftParenthesis => .symbol "(" | .isKeyword => .word "is"

inductive Capacity | functions | formals | scalars | booleans
  deriving DecidableEq, Repr

def Capacity.name : Capacity → List String
  | .functions => ["functions", ".", "max_functions"] | .formals => ["functions", ".", "max_formals"]
  | .scalars => ["scalar_expressions", ".", "max_bindings"] | .booleans => ["max_boolean_bindings"]
def Capacity.value : Capacity → Nat
  | .functions => FunctionBindings.maxFunctions | .formals => FunctionBindings.maxFormals
  | .scalars => ScalarExpression.maxBindings | .booleans => BooleanBindings.maxBindings

inductive Expr : Ty → Type
  | number : Nat → Expr .number | truth : Bool → Expr .truth
  | token : Token → Expr .token | kind : FunctionBindings.ScalarKind → Expr .kind
  | empty : Expr .interval | full : Expr .interval | initial : Expr .state | invalid : Expr .state
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
  | .number value => value | .truth value => value | .token value => value.shell | .kind value => value
  | .empty => .empty | .full => .full | .initial => initialState | .invalid => invalidState
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
  | .number value => [toString value] | .truth value => [if value then "true" else "false"]
  | .token value => [value.name] | .kind .integer => ["functions", ".", "integer_kind"]
  | .kind .boolean => ["functions", ".", "boolean_kind"]
  | .empty => ["scalars", ".", "empty"] | .full => ["scalars", ".", "full"]
  | .initial => ["initial_state"] | .invalid => ["invalid_state"]
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

def functionTypeBody : Expr .typeResult :=
  let text : Expr .source := .variable "text"
  let state : Expr .state := .variable "state"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let integerType : Expr .constraint := .variable "integer_type"
  .declare <| .letValue "integer_type" (apply3 (.function .scalarType) text state (.variable "position")) <|
    .letValue "first" (apply2 (.function .skip) text (.variable "position")) <|
    .letValue "after" (apply3 (.function .take) text first (.token .booleanName)) <|
    .beginValue <| .group <| .ite (.ne (.field .constraintAfter integerType) (.number 0))
      (.typeResult (.field .constraintAfter integerType) (.kind .integer) (.field .constraintBounds integerType))
      (.elsif (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse
        (.eq after (.number 0)) (.field .booleanHidden (.field .hiding state)))
        (.ne (apply4 (.function .lookupString) text (.field .names state) first after) (.number 0)))
        (.ne (apply4 (.function .lookupScalar) text (.field .scalars state) first after) (.number 0)))
        (.ne (apply4 (.function .lookupBoolean) text (.field .booleans state) first after) (.number 0)))
        (.ne (apply4 (.function .lookupSubtype) text (.field .subtypes state) first after) (.number 0)))
        (.ne (apply4 (.function .lookupArray) text (.field .arrays state) first after) (.number 0)))
        (.ne (apply4 (.function .lookupFunction) text (.field .functions state) first after) (.number 0)))
        (apply4 (.function .formalHides) text state first after))
        (.typeResult (.number 0) (.kind .integer) .empty) (.typeResult after (.kind .boolean) .full))

def parameterStepBody : Expr .stepResult :=
  let text : Expr .source := .variable "text"
  let state : Expr .state := .variable "state"
  let arguments : Expr .truth := .variable "arguments"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let start : Expr .number := .variable "start"
  let value : Expr .typeResult := .variable "value"
  let next : Expr .state := .variable "next"
  let separator : Expr .number := .variable "separator"
  let close : Expr .number := .variable "close"
  .declare <| .letValue "first" (apply2 (.function .skip) text (.field .position state)) <|
    .letValue "after" (apply2 (.function .nameAfter) text first) <|
    .letValue "start" (apply3 (.function .take) text
      (apply3 (.function .take) text after (.token .colon)) (.token .inKeyword)) <|
    .letValue "value" (apply3 (.function .functionType) text state start) <|
    .beginValue <| .group <| .ite
      (.orElse (.orElse (.orElse (.orElse
        (.not (apply5 (.function .newName) text state first after arguments))
        (.eq start (.number 0))) (.le (.field .typeAfter value) (.field .position state)))
        (.eq (.field .parameterCount (.field .functions state)) (.capacity .formals)))
        (apply5 (.function .equal) text first after (apply2 (.function .skip) text start) (.field .typeAfter value)))
      (.stepResult .invalid (.truth false))
      (.group <| .declare <| .letValue "next"
        (.update .hiding (.update .functions (.update .position state (.field .typeAfter value))
          (apply2 (.function .appendFormal) (.field .functions state)
            (.formal first after (.field .typeKind value) (.field .typeBounds value))))
          (apply4 (.function .hideName) text (.field .hiding state) first after)) <|
        .letValue "separator" (apply3 (.function .take) text (.field .typeAfter value) (.token .semicolon)) <|
        .letValue "close" (apply3 (.function .take) text (.field .typeAfter value) (.token .rightParenthesis)) <|
        .beginValue <| .group <| .ite (.ne close (.number 0)) (.stepResult (.update .position next close) (.truth true))
          (.elsif (.gt separator (.field .position state)) (.stepResult (.update .position next separator) (.truth false))
            (.stepResult .invalid (.truth false))))

def parametersModelBody : Expr .state :=
  let text : Expr .source := .variable "text"
  let state : Expr .state := .variable "state"
  let arguments : Expr .truth := .variable "arguments"
  let next : Expr .stepResult := .variable "next"
  .declare <| .letValue "next" (apply3 (.function .parameterStep) text state arguments) <|
    .beginValue <| .group <| .ite (.eq (.field .position (.field .stepState next)) (.number 0)) .invalid
      (.elsif (.field .stepClosed next) (.field .stepState next)
        (apply3 (.function .parametersModel) text (.field .stepState next) arguments))

def functionLocalBody : Expr .state :=
  let text : Expr .source := .variable "text"
  let state : Expr .state := .variable "state"
  let arguments : Expr .truth := .variable "arguments"
  let scalar : Expr .state := .variable "scalar"
  .declare <| .letValue "scalar" (apply3 (.function .scalarDeclaration) text state arguments) <|
    .letValue "flag" (apply3 (.function .booleanDeclaration) text state arguments) <|
    .beginValue <| .group <| .ite (.ne (.field .position scalar) (.number 0)) scalar (.variable "flag")

def functionLocalsModelBody : Expr .state :=
  let text : Expr .source := .variable "text"
  let state : Expr .state := .variable "state"
  let arguments : Expr .truth := .variable "arguments"
  let next : Expr .state := .variable "next"
  .ite (.eq (.field .position state) (.number 0)) .invalid
    (.elsif (.ne (apply3 (.function .take) text (.field .position state) (.token .beginKeyword)) (.number 0)) state
      (.group <| .declare <| .letValue "next" (apply3 (.function .functionLocal) text state arguments) <|
        .beginValue <| .group <| .ite (.eq (.field .position next) (.number 0)) .invalid
          (apply3 (.function .functionLocalsModel) text next arguments)))

def appendParameterBody : Expr .state :=
  let frame : Expr .state := .variable "frame"
  let parameter : Expr .formal := .variable "parameter"
  .ite (.eqKind (.field .formalKind parameter) (.kind .integer))
    (.group <| .ite (.eq (.field .scalarCount (.field .scalars frame)) (.capacity .scalars)) .invalid
      (.update .scalars frame (apply2 (.function .scalarAppend) (.field .scalars frame)
        (.scalarBinding (.field .formalFirst parameter) (.field .formalAfter parameter) (.field .formalBounds parameter)
          (.truth false) (.field .formalBounds parameter) (.truth false)))))
    (.group <| .ite (.eq (.field .booleanCount (.field .booleans frame)) (.capacity .booleans)) .invalid
      (.appendBoolean frame parameter))

def parameterFrameModelBody : Expr .state :=
  let frame : Expr .state := .variable "frame"
  let index : Expr .number := .variable "index"
  let next : Expr .state := .variable "next"
  .ite (.eq (.field .position frame) (.number 0)) .invalid
    (.elsif (.gt index (.field .parameterCount (.field .functions frame))) frame
      (.group <| .declare <| .letValue "next" (apply2 (.function .appendParameter) frame
        (.formalAt (.field .functions frame) index)) <|
        .beginValue <| .group <| .ite (.eq (.field .position next) (.number 0)) .invalid
          (apply2 (.function .parameterFrameModel) next (.add index (.number 1)))))

inductive Command : Ty → Type
  | letValue (name : String) : Expr a → Command b → Command b
  | beginBody : Command ty → Command ty
  | guard : Expr .truth → Expr ty → Command ty → Command ty
  | block : Command ty → Command ty
  | returned : Expr ty → Command ty

def Command.eval (calls : Calls) (locals : Locals) : Command ty → ty.meaning
  | .letValue name value body => body.eval calls (locals.set _ name (value.eval calls locals))
  | .beginBody body | .block body => body.eval calls locals
  | .guard condition rejected body =>
      if condition.eval calls locals then rejected.eval calls locals else body.eval calls locals
  | .returned value => value.eval calls locals

def Command.render : Command ty → List String
  | @Command.letValue a _ name value body =>
      [name, ":", "constant"] ++ a.name ++ [":="] ++ value.render ++ [";"] ++ body.render
  | .beginBody body => ["begin"] ++ body.render
  | .guard condition rejected body => ["if"] ++ condition.render ++ ["then", "return"] ++ rejected.render ++
      [";", "end", "if", ";"] ++ body.render
  | .block body => ["declare"] ++ body.render ++ ["end", ";"]
  | .returned value => ["return"] ++ value.render ++ [";"]

def returnAfterBody : Command .number :=
  let text : Expr .source := .variable "text"
  let context : Expr .context := .variable "context"
  let scan : Expr .bodyScan := .variable "scan"
  let resultType : Expr .typeResult := .variable "result_type"
  .letValue "start" (apply3 (.function .take) text (.field .bodyPosition scan) (.token .returnKeyword)) <|
    .beginBody <| .guard (.eq (.variable "start") (.number 0)) (.number 0) <|
    .returned <| apply5 (.function .actualAfter) text context (.variable "start") (.field .bodyFacts scan)
      (.formal (.number 0) (.number 0) (.field .typeKind resultType) (.field .typeBounds resultType))

def functionBodyBody : Command .state :=
  let text : Expr .source := .variable "text"
  let outer : Expr .state := .variable "outer"
  let frame : Expr .state := .variable "frame"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let resultType : Expr .typeResult := .variable "result_type"
  let arguments : Expr .truth := .variable "arguments"
  let locals : Expr .state := .variable "locals"
  let bound : Expr .state := .variable "bound"
  let start : Expr .state := .variable "start"
  let context : Expr .context := .variable "context"
  let bodyResult : Expr .bodyScan := .variable "body_result"
  let returnEnd : Expr .number := .variable "return_end"
  let endFirst : Expr .number := .variable "end_first"
  let endAfter : Expr .number := .variable "end_after"
  let following : Expr .number := .variable "following"
  .letValue "locals" (apply3 (.function .functionLocals) text frame arguments) <|
    .beginBody <| .guard (.eq (.field .position locals) (.number 0)) .invalid <|
    .block <| .letValue "bound" (apply2 (.function .parameterFrame) text locals) <|
    .beginBody <| .guard (.eq (.field .position bound) (.number 0)) .invalid <|
    .block <| .letValue "start" (.update .position bound (apply3 (.function .take) text (.field .position bound) (.token .beginKeyword))) <|
    .letValue "context" (.updateDeclarationCount (.app (.function .contextOf) (.scan start (.truth false) (.truth false)))
      (.field .scalarCount (.field .scalars locals))) <|
    .letValue "body_result" (apply5 (.function .bodyTail) text context
      (.app (.function .bodyOf) (.scan start (.truth false) (.truth false))) .returnStop (.field .functions frame)) <|
    .letValue "return_end" (apply4 (.function .returnAfter) text context bodyResult resultType) <|
    .letValue "end_first" (apply2 (.function .skip) text
      (apply3 (.function .take) text (apply3 (.function .take) text returnEnd (.token .semicolon)) (.token .endKeyword))) <|
    .letValue "end_after" (apply2 (.function .nameAfter) text endFirst) <|
    .letValue "following" (apply3 (.function .take) text endAfter (.token .semicolon)) <|
    .beginBody <| .guard
      (.orElse (.orElse (.orElse (.orElse (.orElse
        (.eq (.field .bodyPosition bodyResult) (.number 0)) (.eq returnEnd (.number 0)))
        (.eq endFirst (.number 0))) (.le endAfter endFirst))
        (.not (apply5 (.function .equal) text first after endFirst endAfter)))
        (.le following (.field .position outer))) .invalid <|
    .returned <| .update .subtypes
      (.update .assigned
        (.update .hiding
          (.update .functions (.update .position outer following)
            (apply2 (.function .append) (.field .functions frame)
              (.signature first after (.field .firstParameter frame)
                (.add (.sub (.field .parameterCount (.field .functions frame)) (.field .firstParameter frame)) (.number 1))
                (.field .typeKind resultType) (.field .typeBounds resultType))))
          (apply4 (.function .hideName) text (.field .hiding outer) first after))
        (.or (.field .assigned outer) (.field .bodyAssigned bodyResult)))
      (.addHiddenCalls (.field .subtypes outer) text first after)

def functionDeclarationBody : Command .state :=
  let text : Expr .source := .variable "text"
  let state : Expr .state := .variable "state"
  let arguments : Expr .truth := .variable "arguments"
  let start : Expr .number := .variable "start"
  let first : Expr .number := .variable "first"
  let after : Expr .number := .variable "after"
  let opening : Expr .number := .variable "open"
  let initialInput : Expr .state := .variable "initial"
  let header : Expr .state := .variable "header"
  let resultType : Expr .typeResult := .variable "result_type"
  let bodyStart : Expr .number := .variable "body_start"
  .letValue "start" (apply3 (.function .take) text (.field .position state) (.token .functionKeyword)) <|
    .letValue "first" (apply2 (.function .skip) text start) <|
    .letValue "after" (apply2 (.function .nameAfter) text first) <|
    .letValue "open" (apply3 (.function .take) text after (.token .leftParenthesis)) <|
    .beginBody <| .guard
      (.orElse (.orElse (.orElse (.orElse (.orElse
        (.eq start (.number 0)) (.eq opening (.number 0))) (.field .pure state))
        (.not (apply5 (.function .newName) text state first after arguments)))
        (.eq (.field .functionCount (.field .functions state)) (.capacity .functions)))
        (.eq (.field .parameterCount (.field .functions state)) (.capacity .formals))) .invalid <|
    .block <| .letValue "initial"
      (.update .firstParameter
        (.update .hiding
          (.update .functions (.update .subtypes (.update .pure (.update .position .initial opening) (.truth true)) (.field .subtypes state))
            (.field .functions state))
          (apply4 (.function .hideName) text (apply2 (.function .hiddenOuter) text state) first after))
        (.add (.field .parameterCount (.field .functions state)) (.number 1))) <|
    .letValue "header" (apply3 (.function .parameters) text initialInput arguments) <|
    .beginBody <| .guard (.eq (.field .position header) (.number 0)) .invalid <|
    .block <| .letValue "result_type" (apply3 (.function .functionType) text header
      (apply3 (.function .take) text (.field .position header) (.token .returnKeyword))) <|
    .letValue "body_start" (apply3 (.function .take) text (.field .typeAfter resultType) (.token .isKeyword)) <|
    .beginBody <| .guard (.orElse (.eq (.field .typeAfter resultType) (.number 0)) (.eq bodyStart (.number 0))) .invalid <|
    .returned <| .app (.app (apply5 (.function .functionBody) text state (.update .position header bodyStart) first after) resultType) arguments

/-- Input names and local binders are checked independently of their typed
values; extending a tree cannot introduce an unbound native identifier. -/
abbrev Scope := List (Ty × String)

def Expr.scoped (scope : Scope) : Expr ty → Bool
  | .number _ | .truth _ | .token _ | .kind _ | .empty | .full | .initial | .invalid |
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
  | @Expr.letValue a _ name value body => value.scoped scope && body.scoped ((a, name) :: scope)

def Command.scoped (scope : Scope) : Command ty → Bool
  | @Command.letValue a _ name value body => value.scoped scope && body.scoped ((a, name) :: scope)
  | .beginBody body | .block body => body.scoped scope
  | .guard condition rejected body => condition.scoped scope && rejected.scoped scope && body.scoped scope
  | .returned value => value.scoped scope

/-- Selected and indexed components require a name, not a parenthesized
expression or an aggregate. Delta-aggregate bases remain ordinary expressions. -/
def Expr.prefix : Expr ty → Bool
  | .token _ | .kind _ | .empty | .full | .initial | .invalid | .capacity _ |
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
  | .number _ | .truth _ | .token _ | .kind _ | .empty | .full | .initial | .invalid |
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
  | .eq _ _ | .ne _ _ | .le _ _ | .gt _ _ | .eqKind _ _ | .not _ => true
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
  | .andThen _ _ | .orElse _ _ | .or _ _ | .ite _ _ _ => true
  | value => value.relation

def Expr.branch : Expr ty → Bool
  | .elsif _ _ _ => true
  | value => value.value

def Expr.declarations : Expr ty → Bool
  | .letValue _ _ _ | .beginValue _ => true
  | _ => false

def Expr.wellFormed : Expr ty → Bool
  | .number _ | .truth _ | .token _ | .kind _ | .empty | .full | .initial | .invalid |
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
  | .group value => (value.value || (match value with | .declare _ => true | _ => false)) && value.wellFormed
  | .ite condition yes no | .elsif condition yes no => condition.value && yes.value && no.branch &&
      condition.wellFormed && yes.wellFormed && no.wellFormed
  | .declare value => value.declarations && value.wellFormed
  | .letValue _ value body => value.value && body.declarations && value.wellFormed && body.wellFormed
  | .beginValue value => value.value && value.wellFormed

def Command.wellFormed : Command ty → Bool
  | .letValue _ value body => value.value && value.wellFormed && body.wellFormed
  | .beginBody body | .block body => body.wellFormed
  | .guard condition rejected body => condition.value && rejected.value && condition.wellFormed && rejected.wellFormed && body.wellFormed
  | .returned value => value.value && value.wellFormed

structure Frame where
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
  | .state, name => if name = "state" then frame.state else if name = "outer" then frame.outer else frame.frame
  | .number, name => if name = "position" then frame.position else if name = "first" then frame.first else
      if name = "after" then frame.after else frame.index
  | .truth, _ => frame.arguments
  | .formal, _ => frame.parameter
  | .typeResult, _ => frame.resultType
  | .context, _ => frame.context
  | .bodyScan, _ => frame.scan
  | ty, _ => ty.default

def stateScope : Scope := [(.source, "text"), (.state, "state"), (.truth, "arguments")]

def bodyScope : Scope := [(.source, "text"), (.state, "outer"), (.state, "frame"),
  (.number, "first"), (.number, "after"), (.typeResult, "result_type"), (.truth, "arguments")]

abbrev CheckedTrees : Prop :=
  functionTypeBody.wellFormed = true ∧
  functionTypeBody.scoped [(.source, "text"), (.state, "state"), (.number, "position")] = true ∧
  parameterStepBody.wellFormed = true ∧ parameterStepBody.scoped stateScope = true ∧
  parametersModelBody.wellFormed = true ∧ parametersModelBody.scoped stateScope = true ∧
  functionLocalBody.wellFormed = true ∧ functionLocalBody.scoped stateScope = true ∧
  functionLocalsModelBody.wellFormed = true ∧ functionLocalsModelBody.scoped stateScope = true ∧
  appendParameterBody.wellFormed = true ∧ appendParameterBody.scoped [(.state, "frame"), (.formal, "parameter")] = true ∧
  parameterFrameModelBody.wellFormed = true ∧ parameterFrameModelBody.scoped [(.state, "frame"), (.number, "index")] = true ∧
  returnAfterBody.wellFormed = true ∧
  returnAfterBody.scoped [(.source, "text"), (.context, "context"), (.bodyScan, "scan"), (.typeResult, "result_type")] = true ∧
  functionBodyBody.wellFormed = true ∧ functionBodyBody.scoped bodyScope = true ∧
  functionDeclarationBody.wellFormed = true ∧ functionDeclarationBody.scoped stateScope = true

theorem checked_trees : CheckedTrees := by decide +kernel

namespace StructuralControls

private def state : Expr .state := .variable "state"
private def parameter : Expr .formal := .variable "parameter"

theorem selected_and_indexed_prefixes :
    (Expr.field .position (.group state)).wellFormed = false ∧
    (Expr.field .position (.group (.ite (.truth true) state state))).wellFormed = false ∧
    (Expr.field .position (.update .position state (.number 1))).wellFormed = false ∧
    (Expr.field .typeAfter (.typeResult (.number 1) (.kind .integer) .empty)).wellFormed = false ∧
    (Expr.formalAt (.group (.field .functions state)) (.number 1)).wellFormed = false ∧
    (Expr.field .position state).wellFormed = true ∧
    (Expr.field .formalFirst (.formalAt (.field .functions state) (.number 1))).wellFormed = true ∧
    (Expr.field .constraintAfter
      (apply3 (.function .scalarType) (.variable "text") state (.number 1))).wellFormed = true := by decide +kernel

theorem aggregate_internal_prefixes :
    (Expr.addHiddenCalls (.group (.field .subtypes state)) (.variable "text") (.number 1) (.number 2)).wellFormed = false ∧
    (Expr.appendBoolean (.group state) parameter).wellFormed = false ∧
    (Expr.appendBoolean state (.group parameter)).wellFormed = false ∧
    (Expr.addHiddenCalls (.field .subtypes state) (.variable "text") (.number 1) (.number 2)).wellFormed = true ∧
    (Expr.appendBoolean state parameter).wellFormed = true := by decide +kernel

/-- A delta-aggregate base is an expression. Nested updates also retain the
renderer’s deliberate flattening into one aggregate. -/
theorem delta_aggregate_bases :
    (Expr.update .position (.group state) (.number 1)).wellFormed = true ∧
    (Expr.update .pure (.update .position state (.number 1)) (.truth true)).wellFormed = true ∧
    (Expr.updateDeclarationCount (.group (.variable "context")) (.number 1)).wellFormed = true := by decide +kernel

end StructuralControls

end Silver.Compose.FunctionDeclarationNative
