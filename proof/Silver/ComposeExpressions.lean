module

public import Silver.ComposeAdmission

@[expose] public section

/-! A typed interpretation of the restricted Ada expression forms used by the
binding recognizer. Local declarations, record fields and updates have explicit
semantics; calls remain arbitrary until their actual source equations are used.
The interpreter is intentionally limited to this implementation's expressions. -/

namespace Silver.Compose.Expressions

structure Primitives where
  trivia : Source → Nat → Nat
  literal : Source → Nat → Nat
  length : Source → Nat → Nat
  identifier : Source → Nat → Nat
  forbidden : Source → Nat → Nat → Bool
  forbiddenArgument : Source → Nat → Nat → Bool
  equal : Source → Nat → Nat → Nat → Nat → Bool
  decimal : Source → Nat → Guarded.DecimalResult
  token : Source → Nat → String → Bool → Bool
  normalize : Source → Source
  allowed : Source → Bool

inductive Ty
  | number | truth | source | spelling | token | form
  | binding | names | state | value | result | scan | decimal
  | arrow (domain codomain : Ty)
  deriving DecidableEq, Repr

@[reducible] def Ty.meaning : Ty → Type
  | .number => Nat | .truth => Bool | .source => Source | .spelling => String
  | .token => ShellToken | .form => Form | .binding => BindingInfo
  | .names => BindingEnvironment | .state => ParserState
  | .value => ValueResult | .result => ExpressionResult | .scan => ExpressionState
  | .decimal => Guarded.DecimalResult
  | .arrow a b => a.meaning → b.meaning

def Ty.default : (ty : Ty) → ty.meaning
  | Ty.number => 0 | Ty.truth => false | Ty.source => [] | Ty.spelling => ""
  | Ty.token => .symbol ";" | Ty.form => .direct | Ty.binding => {}
  | Ty.names => [] | Ty.state => invalidState | Ty.value => invalidValue
  | Ty.result => invalidExpression | Ty.scan => invalidExpressionState | Ty.decimal => ⟨0, 0⟩
  | Ty.arrow _ b => fun _ => b.default

inductive Function
  | trivia
  | literalEnd
  | literalLength
  | identifier
  | forbidden
  | forbiddenArgument
  | equal
  | decimal
  | tokenAt
  | normalize
  | allowed
  | skip
  | nameAfter
  | fixedAfter
  | takeToken
  | lookupFrom
  | lookupName
  | literal
  | workTail
  | workBudget
  | value
  | newName
  | addBinding
  | declaration
  | argument
  | declarations
  | readDeclarations
  | expressionStep
  | fits
  | comparison
  | tail
  | expression
  | target
  | dynamic
  | assignmentValue
  | output
  | capacity
  | step
  | suffix
  | formMember
  | member
  | arguments
  | assignment
  deriving DecidableEq, Repr

def Function.name : Function → String
  | .trivia => "trivia_end"
  | .literalEnd => "literal_end"
  | .literalLength => "literal_length"
  | .identifier => "identifier_end"
  | .forbidden => "forbidden_name"
  | .forbiddenArgument => "forbidden_argument_name"
  | .equal => "equal_name"
  | .decimal => "decimal_at"
  | .tokenAt => "token_at"
  | .normalize => "normalized"
  | .allowed => "allowed_source"
  | .skip => "skip_at"
  | .nameAfter => "name_after"
  | .fixedAfter => "fixed_after"
  | .takeToken => "take_token"
  | .lookupFrom => "lookup_from"
  | .lookupName => "lookup_name"
  | .literal => "literal_at"
  | .workTail => "work_tail"
  | .workBudget => "within_work_budget"
  | .value => "value_at"
  | .newName => "new_name_allowed"
  | .addBinding => "add_binding"
  | .declaration => "declaration_at"
  | .argument => "argument_at"
  | .declarations => "declarations_at"
  | .readDeclarations => "read_declarations"
  | .expressionStep => "expression_step"
  | .fits => "fits"
  | .comparison => "comparison_at"
  | .tail => "expression_tail"
  | .expression => "expression_at"
  | .target => "target_at"
  | .dynamic => "dynamic_at"
  | .assignmentValue => "assignment_at"
  | .output => "output_at"
  | .capacity => "capacity_at"
  | .step => "step"
  | .suffix => "suffix_matches"
  | .formMember => "form_member"
  | .member => "is_member"
  | .arguments => "has_arguments"
  | .assignment => "has_assignment"

@[reducible] def Function.type : Function → Ty
  | .trivia => .arrow .source (.arrow .number (.number))
  | .literalEnd => .arrow .source (.arrow .number (.number))
  | .literalLength => .arrow .source (.arrow .number (.number))
  | .identifier => .arrow .source (.arrow .number (.number))
  | .forbidden => .arrow .source (.arrow .number (.arrow .number (.truth)))
  | .forbiddenArgument => .arrow .source (.arrow .number (.arrow .number (.truth)))
  | .equal => .arrow .source (.arrow .number (.arrow .number (.arrow .number (.arrow .number (.truth)))))
  | .decimal => .arrow .source (.arrow .number (.decimal))
  | .tokenAt => .arrow .source (.arrow .number (.arrow .spelling (.arrow .truth (.truth))))
  | .normalize => .arrow .source (.source)
  | .allowed => .arrow .source (.truth)
  | .skip => .arrow .source (.arrow .number (.number))
  | .nameAfter => .arrow .source (.arrow .number (.number))
  | .fixedAfter => .arrow .source (.arrow .number (.arrow .token (.number)))
  | .takeToken => .arrow .source (.arrow .number (.arrow .token (.number)))
  | .lookupFrom => .arrow .source (.arrow .names (.arrow .number (.arrow .number (.arrow .number (.number)))))
  | .lookupName => .arrow .source (.arrow .names (.arrow .number (.arrow .number (.number))))
  | .literal => .arrow .source (.arrow .number (.value))
  | .workTail => .arrow .source (.arrow .number (.arrow .number .truth))
  | .workBudget => .arrow .source .truth
  | .value => .arrow .source (.arrow .number (.arrow .names (.value)))
  | .newName => .arrow .source (.arrow .state (.arrow .number (.arrow .number (.arrow .truth (.truth)))))
  | .addBinding => .arrow .state (.arrow .number (.arrow .number (.arrow .value (.arrow .truth (.arrow .number (.state))))))
  | .declaration => .arrow .source (.arrow .state (.arrow .truth (.state)))
  | .argument => .arrow .source (.arrow .state (.state))
  | .declarations => .arrow .source (.arrow .state (.arrow .truth (.state)))
  | .readDeclarations => .arrow .source (.arrow .state (.arrow .truth (.state)))
  | .expressionStep => .arrow .source (.arrow .names (.arrow .scan .scan))
  | .fits => .arrow .result (.arrow .number .truth)
  | .comparison => .arrow .source (.arrow .state .state)
  | .tail => .arrow .source (.arrow .names (.arrow .scan .result))
  | .expression => .arrow .source (.arrow .number (.arrow .names (.result)))
  | .target => .arrow .source (.arrow .state (.arrow .truth (.state)))
  | .dynamic => .arrow .source (.arrow .state (.state))
  | .assignmentValue => .arrow .source (.arrow .state (.state))
  | .output => .arrow .source (.arrow .state (.state))
  | .capacity => .arrow .source (.arrow .state (.state))
  | .step => .arrow .source (.arrow .form (.arrow .token (.arrow .state (.state))))
  | .suffix => .arrow .source (.arrow .form (.arrow .number (.arrow .state (.truth))))
  | .formMember => .arrow .source (.arrow .form (.truth))
  | .member => .arrow .source (.truth)
  | .arguments => .arrow .source (.truth)
  | .assignment => .arrow .source (.truth)

structure Calls where
  primitive : Primitives
  function : (symbol : Function) → symbol.type.meaning

/-- Lexical symbols are projected from the established lexical interface.
Every recognizer helper is left arbitrary. -/
def Calls.get (calls : Calls) : (symbol : Function) → symbol.type.meaning
  | .trivia => calls.primitive.trivia
  | .literalEnd => calls.primitive.literal
  | .literalLength => calls.primitive.length
  | .identifier => calls.primitive.identifier
  | .forbidden => calls.primitive.forbidden
  | .forbiddenArgument => calls.primitive.forbiddenArgument
  | .equal => calls.primitive.equal
  | .decimal => calls.primitive.decimal
  | .tokenAt => calls.primitive.token
  | .normalize => calls.primitive.normalize
  | .allowed => calls.primitive.allowed
  | .skip => calls.function .skip
  | .nameAfter => calls.function .nameAfter
  | .fixedAfter => calls.function .fixedAfter
  | .takeToken => calls.function .takeToken
  | .lookupFrom => calls.function .lookupFrom
  | .lookupName => calls.function .lookupName
  | .literal => calls.function .literal
  | .workTail => calls.function .workTail
  | .workBudget => calls.function .workBudget
  | .value => calls.function .value
  | .newName => calls.function .newName
  | .addBinding => calls.function .addBinding
  | .declaration => calls.function .declaration
  | .argument => calls.function .argument
  | .declarations => calls.function .declarations
  | .readDeclarations => calls.function .readDeclarations
  | .expressionStep => calls.function .expressionStep
  | .fits => calls.function .fits
  | .comparison => calls.function .comparison
  | .tail => calls.function .tail
  | .expression => calls.function .expression
  | .target => calls.function .target
  | .dynamic => calls.function .dynamic
  | .assignmentValue => calls.function .assignmentValue
  | .output => calls.function .output
  | .capacity => calls.function .capacity
  | .step => calls.function .step
  | .suffix => calls.function .suffix
  | .formMember => calls.function .formMember
  | .member => calls.function .member
  | .arguments => calls.function .arguments
  | .assignment => calls.function .assignment

inductive Field : Ty → Ty → Type
  | bindingFirst : Field .binding .number
  | bindingAfter : Field .binding .number
  | bindingValueFirst : Field .binding .number
  | bindingLength : Field .binding .number
  | bindingDynamic : Field .binding .truth
  | bindingMutable : Field .binding .truth
  | statePosition : Field .state .number
  | stateNames : Field .state .names
  | stateDynamicFirst : Field .state .number
  | stateDynamicAfter : Field .state .number
  | stateTarget : Field .state .number
  | stateCapacity : Field .state .number
  | valueAfter : Field .value .number
  | valueFirst : Field .value .number
  | valueLength : Field .value .number
  | valueDynamic : Field .value .truth
  | valueReference : Field .value .number
  | resultAfter : Field .result .number
  | resultLength : Field .result .number
  | resultDynamic : Field .result .number
  | resultNamed : Field .result .truth
  | scanPosition : Field .scan .number
  | scanLength : Field .scan .number
  | scanDynamic : Field .scan .number
  | scanOperands : Field .scan .number
  | scanDepth : Field .scan .number
  | scanNamed : Field .scan .truth
  | scanNeed : Field .scan .truth
  | scanComplete : Field .scan .truth
  | decimalAfter : Field .decimal .number
  | decimalValue : Field .decimal .number

def Field.name : Field a b → String
  | .bindingFirst => "first"
  | .bindingAfter => "after"
  | .bindingValueFirst => "value_first"
  | .bindingLength => "static_length"
  | .bindingDynamic => "dynamic"
  | .bindingMutable => "mutable"
  | .statePosition => "position"
  | .stateNames => "names"
  | .stateDynamicFirst => "dynamic_first"
  | .stateDynamicAfter => "dynamic_after"
  | .stateTarget => "target"
  | .stateCapacity => "capacity"
  | .valueAfter => "after"
  | .valueFirst => "value_first"
  | .valueLength => "static_length"
  | .valueDynamic => "dynamic_seen"
  | .valueReference => "reference"
  | .resultAfter => "after"
  | .resultLength => "static_length"
  | .resultDynamic => "dynamic_count"
  | .resultNamed => "named_seen"
  | .scanPosition => "position"
  | .scanLength => "static_length"
  | .scanDynamic => "dynamic_count"
  | .scanOperands => "operands"
  | .scanDepth => "depth"
  | .scanNamed => "named_seen"
  | .scanNeed => "need_operand"
  | .scanComplete => "complete"
  | .decimalAfter => "after"
  | .decimalValue => "value"

def Field.get : Field a b → a.meaning → b.meaning
  | .bindingFirst, value => value.first
  | .bindingAfter, value => value.after
  | .bindingValueFirst, value => value.valueFirst
  | .bindingLength, value => value.staticLength
  | .bindingDynamic, value => value.dynamic
  | .bindingMutable, value => value.mutable
  | .statePosition, value => value.position
  | .stateNames, value => value.names
  | .stateDynamicFirst, value => value.dynamicFirst
  | .stateDynamicAfter, value => value.dynamicAfter
  | .stateTarget, value => value.target
  | .stateCapacity, value => value.capacity
  | .valueAfter, value => value.after
  | .valueFirst, value => value.valueFirst
  | .valueLength, value => value.staticLength
  | .valueDynamic, value => value.dynamicSeen
  | .valueReference, value => value.reference
  | .resultAfter, value => value.after
  | .resultLength, value => value.staticLength
  | .resultDynamic, value => value.dynamicCount
  | .resultNamed, value => value.namedSeen
  | .scanPosition, value => value.position
  | .scanLength, value => value.staticLength
  | .scanDynamic, value => value.dynamicCount
  | .scanOperands, value => value.operands
  | .scanDepth, value => value.depth
  | .scanNamed, value => value.namedSeen
  | .scanNeed, value => value.needOperand
  | .scanComplete, value => value.complete
  | .decimalAfter, value => value.after
  | .decimalValue, value => value.value

inductive Expr : Ty → Type
  | lexTrivia : Expr .source → Expr .number → Expr .number
  | lexLiteralEnd : Expr .source → Expr .number → Expr .number
  | lexLiteralLength : Expr .source → Expr .number → Expr .number
  | lexIdentifier : Expr .source → Expr .number → Expr .number
  | lexForbidden : Expr .source → Expr .number → Expr .number → Expr .truth
  | lexForbiddenArgument : Expr .source → Expr .number → Expr .number → Expr .truth
  | lexEqual : Expr .source → Expr .number → Expr .number → Expr .number → Expr .number → Expr .truth
  | lexDecimal : Expr .source → Expr .number → Expr .decimal
  | lexTokenAt : Expr .source → Expr .number → Expr .spelling → Expr .truth → Expr .truth
  | lexNormalize : Expr .source → Expr .source
  | lexAllowed : Expr .source → Expr .truth
  | number (n : Nat) : Expr .number
  | truth (b : Bool) : Expr .truth
  | variable (name : String) : Expr ty
  | function (symbol : Function) : Expr symbol.type
  | app : Expr (.arrow a b) → Expr a → Expr b
  | field : Field a b → Expr a → Expr b
  | count : Expr .names → Expr .number
  | item : Expr .names → Expr .number → Expr .binding
  | add : Expr .number → Expr .number → Expr .number
  | sub : Expr .number → Expr .number → Expr .number
  | mul : Expr .number → Expr .number → Expr .number
  | eq : Expr .number → Expr .number → Expr .truth
  | ne : Expr .number → Expr .number → Expr .truth
  | boolNe : Expr .truth → Expr .truth → Expr .truth
  | lt : Expr .number → Expr .number → Expr .truth
  | le : Expr .number → Expr .number → Expr .truth
  | gt : Expr .number → Expr .number → Expr .truth
  | range : Expr .number → Expr .number → Expr .number → Expr .truth
  | andThen : Expr .truth → Expr .truth → Expr .truth
  | orElse : Expr .truth → Expr .truth → Expr .truth
  | not : Expr .truth → Expr .truth
  | group : Expr a → Expr a
  | ite : Expr .truth → Expr a → Expr a → Expr a
  | elsif : Expr .truth → Expr a → Expr a → Expr a
  | local (name typeName : String) : Expr a → Expr b → Expr b
  | locals : Expr a → Expr a
  | byteAt : Expr .source → Expr .number → Expr .number
  | sourceLast : Expr .source → Expr .number
  | sourceLength : Expr .source → Expr .number
  | characterVal : Expr .number → Expr .number
  | maxLength : Expr .number
  | maxBindings : Expr .number
  | maxOperands : Expr .number
  | maxConcatenations : Expr .number
  | token (token : ShellToken) : Expr .token
  | tokenEq : Expr .token → Expr .token → Expr .truth
  | tokenSpelling : Expr .token → Expr .spelling
  | spellingLength : Expr .spelling → Expr .number
  | wordToken : Expr .token → Expr .truth
  | hasArguments : Expr .form → Expr .truth
  | tokensLast : Expr .form → Expr .number
  | tokenIndex : Expr .form → Expr .number → Expr .token
  | initial : Expr .state
  | invalid : Expr .state
  | invalidValue : Expr .value
  | invalidResult : Expr .result
  | invalidScan : Expr .scan
  | binding : Expr .number → Expr .number → Expr .number → Expr .number →
      Expr .truth → Expr .truth → Expr .binding
  | value : Expr .number → Expr .number → Expr .number → Expr .truth → Expr .number → Expr .value
  | result : Expr .number → Expr .number → Expr .number → Expr .truth → Expr .result
  | scan : Expr .number → Expr .number → Expr .number → Expr .number → Expr .number →
      Expr .truth → Expr .truth → Expr .truth → Expr .scan
  | scanDepth : Expr .scan → Expr .number → Expr .number → Expr .scan
  | scanAtom : Expr .scan → Expr .number → Expr .number → Expr .number → Expr .number →
      Expr .truth → Expr .scan
  | scanNeed : Expr .scan → Expr .number → Expr .scan
  | scanComplete : Expr .scan → Expr .scan
  | statePosition : Expr .state → Expr .number → Expr .state
  | stateTarget : Expr .state → Expr .number → Expr .number → Expr .state
  | stateCapacity : Expr .state → Expr .number → Expr .number → Expr .state
  | stateDynamic : Expr .state → Expr .number → Expr .number → Expr .state
  | stateBinding : Expr .state → Expr .number → Expr .binding → Expr .state
  | someForm : Expr .source → Expr .truth
  | firstForm (arguments : Bool) : Expr .source → Expr .truth

abbrev Locals := (ty : Ty) → String → ty.meaning

def Locals.set (locals : Locals) (ty : Ty) (name : String) (value : ty.meaning) : Locals :=
  fun requested key => if same : ty = requested then
    if key = name then same ▸ value else locals requested key
  else locals requested key

def call (name : String) (arguments : List (List String)) : List String :=
  [name, "("] ++ List.flatten (List.intersperse [","] arguments) ++ [")"]

def formName : Form → String
  | .direct => "direct_form" | .assignment => "assignment_form"
  | .argument => "argument_form" | .guardedArgument => "guarded_argument_form"
  | .branching => "branching_form" | .guardedBranching => "guarded_branching_form"
  | .result => "result_form" | .guardedResult => "guarded_result_form"

def tokenName : ShellToken → String
  | .declarations => "declarations" | .argumentDeclaration => "argument_declaration"
  | .assignmentTarget => "assignment_target" | .targetReference => "target_reference"
  | .dynamicReference => "dynamic_reference" | .assignmentValue => "assignment_value"
  | .outputExpression => "output_expression" | .comparisonExpression => "comparison_expression" | .literal => "string_literal" | .capacity => "capacity_literal"
  | .fixed spelling _ => match spelling with
    | "with" => "with_keyword" | "silver_io" => "io_name" | "procedure" => "procedure_keyword"
    | "main" => "main_name" | "is" => "is_keyword" | "pragma" => "pragma_keyword"
    | "spark_mode" => "spark_mode_name" | "on" => "on_name" | "begin" => "begin_keyword"
    | "put_line" => "put_line_name" | "end" => "end_keyword" | "(" => "left_parenthesis"
    | ")" => "right_parenthesis" | ";" => "semicolon" | "." => "dot" | ":" => "colon"
    | "constant" => "constant_keyword" | "string" => "string_name" | ":=" => "assignment"
    | "silver_arguments" => "arguments_name" | "first_or_default" => "first_or_default_name"
    | "if" => "if_keyword" | "input_is_valid" => "input_is_valid_name" | "then" => "then_keyword"
    | "else" => "else_keyword" | "reject" => "reject_name" | "&" => "ampersand"
    | "and" => "and_keyword" | "'" => "apostrophe" | "length" => "length_name"
    | "<=" => "less_equal" | _ => "equal"

def spelling : ShellToken → String
  | .fixed word _ => word
  | .literal => "\"" | .capacity => "0" | _ => "_"
def isWord : ShellToken → Bool | .fixed _ word => word | _ => false

def aggregate (fields : List (String × List String)) : List String :=
  ["("] ++ List.flatten (List.intersperse [","]
    (fields.map fun (field,value) => [field,"=>"] ++ value)) ++ [")"]
def updated (base : List String) (fields : List (String × List String)) : List String :=
  ["("] ++ base ++ ["with", "delta"] ++
    List.flatten (List.intersperse [","] (fields.map fun (field,value) => [field,"=>"] ++ value)) ++ [")"]

/-- Application uses a token-list spine so nested typed applications render as
one ordinary Ada call, without changing the meaning of argument evaluation. -/
def Expr.render : Expr ty → List String
  | .lexTrivia a b => call "trivia_end" [a.render, b.render]
  | .lexLiteralEnd a b => call "literal_end" [a.render, b.render]
  | .lexLiteralLength a b => call "literal_length" [a.render, b.render]
  | .lexIdentifier a b => call "identifier_end" [a.render, b.render]
  | .lexForbidden a b c => call "forbidden_name" [a.render, b.render, c.render]
  | .lexForbiddenArgument a b c => call "forbidden_argument_name" [a.render, b.render, c.render]
  | .lexEqual a b c d e => call "equal_name" [a.render, b.render, c.render, d.render, e.render]
  | .lexDecimal a b => call "decimal_at" [a.render, b.render]
  | .lexTokenAt a b c d => call "token_at" [a.render, b.render, c.render, d.render]
  | .lexNormalize a => call "normalized" [a.render]
  | .lexAllowed a => call "allowed_source" [a.render]
  | .number n => [toString n]
  | .truth b => [if b then "true" else "false"]
  | .variable name => [name]
  | .function symbol => [symbol.name]
  | .app f x =>
      match f with
      | .app _ _ => f.render.dropLast ++ [","] ++ x.render ++ [")"]
      | _ => f.render ++ ["("] ++ x.render ++ [")"]
  | .field projection x => x.render ++ [".", projection.name]
  | .count x => x.render ++ [".", "count"]
  | .item x i => x.render ++ [".", "items", "("] ++ i.render ++ [")"]
  | .add x y => x.render ++ ["+"] ++ y.render
  | .sub x y => x.render ++ ["-"] ++ y.render
  | .mul x y => x.render ++ ["*"] ++ y.render
  | .eq x y => x.render ++ ["="] ++ y.render
  | .ne x y => x.render ++ ["/="] ++ y.render
  | .boolNe x y => x.render ++ ["/="] ++ y.render
  | .lt x y => x.render ++ ["<"] ++ y.render
  | .le x y => x.render ++ ["<="] ++ y.render
  | .gt x y => x.render ++ [">"] ++ y.render
  | .range x a b => x.render ++ ["in"] ++ a.render ++ [".."] ++ b.render
  | .andThen x y => x.render ++ ["and", "then"] ++ y.render
  | .orElse x y => x.render ++ ["or", "else"] ++ y.render
  | .not x => ["not"] ++ x.render
  | .group x => ["("] ++ x.render ++ [")"]
  | .ite c a b => ["if"] ++ c.render ++ ["then"] ++ a.render ++
      (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
  | .elsif c a b => ["elsif"] ++ c.render ++ ["then"] ++ a.render ++
      (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
  | .local name typeName localValue rest => [name, ":", "constant", typeName, ":="] ++ localValue.render ++ [";"] ++
      (match rest with | .local _ _ _ _ => rest.render | _ => ["begin"] ++ rest.render)
  | .locals body => ["declare"] ++ body.render
  | .byteAt text position => text.render ++ ["("] ++ position.render ++ [")"]
  | .sourceLast text => text.render ++ ["'", "last"]
  | .sourceLength text => text.render ++ ["'", "length"]
  | .characterVal localValue => ["character", "'", "val", "("] ++ localValue.render ++ [")"]
  | .maxLength => ["max_source_length"] | .maxBindings => ["max_bindings"]
  | .maxOperands => ["max_expression_operands"]
  | .maxConcatenations => ["max_concatenations"]
  | .token tok => [tokenName tok]
  | .tokenEq a b => a.render ++ ["="] ++ b.render
  | .tokenSpelling t => call "spelling" [t.render]
  | .spellingLength s => s.render ++ ["'", "length"]
  | .wordToken t => call "is_word_token" [t.render]
  | .hasArguments f => call "is_argument_form" [f.render]
  | .tokensLast f => call "tokens" [f.render] ++ ["'", "last"]
  | .tokenIndex f i => call "tokens" [f.render] ++ ["("] ++ i.render ++ [")"]
  | .initial => ["initial_state"] | .invalid => ["invalid_state"]
  | .invalidValue => ["invalid_value"] | .invalidResult => ["invalid_expression"]
  | .invalidScan => ["invalid_expression_state"]
  | .binding a b c d e f => aggregate [("first",a.render),("after",b.render),("value_first",c.render),
      ("static_length",d.render),("dynamic",e.render),("mutable",f.render)]
  | .value a b c d e => aggregate [("after",a.render),("value_first",b.render),
      ("static_length",c.render),("dynamic_seen",d.render),("reference",e.render)]
  | .result a b c d => aggregate [("after",a.render),("static_length",b.render),
      ("dynamic_count",c.render),("named_seen",d.render)]
  | .scan p l d o depth named need complete => aggregate [("position",p.render),
      ("static_length",l.render),("dynamic_count",d.render),("operands",o.render),
      ("depth",depth.render),("named_seen",named.render),("need_operand",need.render),("complete",complete.render)]
  | .scanDepth s p d => updated s.render [("position",p.render),("depth",d.render)]
  | .scanAtom s p l d o n => updated s.render [("position",p.render),("static_length",l.render),
      ("dynamic_count",d.render),("operands",o.render),("named_seen",n.render),("need_operand",["false"])]
  | .scanNeed s p => updated s.render [("position",p.render),("need_operand",["true"])]
  | .scanComplete s => updated s.render [("complete",["true"])]
  | .statePosition s p => updated s.render [("position",p.render)]
  | .stateTarget s p t => updated s.render [("position",p.render),("target",t.render)]
  | .stateCapacity s p c => updated s.render [("position",p.render),("capacity",c.render)]
  | .stateDynamic s a b => updated s.render [("dynamic_first",a.render),("dynamic_after",b.render)]
  | .stateBinding s p info => updated s.render [("position",p.render),("names",
      aggregate [("count", s.render ++ [".", "names", ".", "count", "+", "1"]),
        ("items", (["("] ++ s.render ++ [".","names",".","items","with","delta"] ++
          s.render ++ [".","names",".","count","+","1","=>"] ++ info.render ++ [")"]))])]
  | .someForm source => ["for","some","form","in","form_kind","=>"] ++
      call "form_member" [source.render,["form"]]
  | .firstForm arguments source => ["for","some","form","in","form_kind","=>"] ++
      call "form_member" [source.render,["form"]] ++ ["and","then"] ++
      call (if arguments then "is_argument_form" else "is_assignment_form") [["form"]] ++
      ["and","then","(","for","all","previous","in","form_kind","'","first","..","form","=>","(","if","previous","/=","form","then","not"] ++
      call "form_member" [source.render,["previous"]] ++ [")",")"]

-- The append constructor above is exactly the bounded Ada array update at
-- Count+1. The active-prefix representation discards unused fixed-array cells.
def firstFlag (text : Source) (member : Source → Form → Bool) (flag : Form → Bool) : Bool :=
  allForms.any fun form => member text form && flag form &&
    (allForms.takeWhile fun previous => previous != form).all (fun previous => !member text previous)

def Expr.eval (calls : Calls) (locals : Locals) : Expr ty → ty.meaning
  | .lexTrivia a b => calls.primitive.trivia (a.eval calls locals) (b.eval calls locals)
  | .lexLiteralEnd a b => calls.primitive.literal (a.eval calls locals) (b.eval calls locals)
  | .lexLiteralLength a b => calls.primitive.length (a.eval calls locals) (b.eval calls locals)
  | .lexIdentifier a b => calls.primitive.identifier (a.eval calls locals) (b.eval calls locals)
  | .lexForbidden a b c => calls.primitive.forbidden (a.eval calls locals) (b.eval calls locals) (c.eval calls locals)
  | .lexForbiddenArgument a b c => calls.primitive.forbiddenArgument (a.eval calls locals) (b.eval calls locals) (c.eval calls locals)
  | .lexEqual a b c d e => calls.primitive.equal (a.eval calls locals) (b.eval calls locals) (c.eval calls locals) (d.eval calls locals) (e.eval calls locals)
  | .lexDecimal a b => calls.primitive.decimal (a.eval calls locals) (b.eval calls locals)
  | .lexTokenAt a b c d => calls.primitive.token (a.eval calls locals) (b.eval calls locals) (c.eval calls locals) (d.eval calls locals)
  | .lexNormalize a => calls.primitive.normalize (a.eval calls locals)
  | .lexAllowed a => calls.primitive.allowed (a.eval calls locals)
  | .number n => n | .truth b => b | .variable name => locals _ name
  | .function symbol => calls.get symbol
  | .app f x => f.eval calls locals (x.eval calls locals)
  | .field projection x => projection.get (x.eval calls locals)
  | .count x => (x.eval calls locals).length
  | .item x i => ((x.eval calls locals).get (i.eval calls locals)).getD {}
  | .add x y => x.eval calls locals + y.eval calls locals
  | .sub x y => x.eval calls locals - y.eval calls locals
  | .mul x y => x.eval calls locals * y.eval calls locals
  | .eq x y => decide (x.eval calls locals = y.eval calls locals)
  | .ne x y => decide (x.eval calls locals ≠ y.eval calls locals)
  | .boolNe x y => x.eval calls locals != y.eval calls locals
  | .lt x y => decide (x.eval calls locals < y.eval calls locals)
  | .le x y => decide (x.eval calls locals ≤ y.eval calls locals)
  | .gt x y => decide (x.eval calls locals > y.eval calls locals)
  | .range x a b => decide (a.eval calls locals ≤ x.eval calls locals ∧ x.eval calls locals ≤ b.eval calls locals)
  | .andThen x y => x.eval calls locals && y.eval calls locals
  | .orElse x y => x.eval calls locals || y.eval calls locals
  | .not x => !x.eval calls locals | .group x => x.eval calls locals
  | .ite c a b | .elsif c a b => if c.eval calls locals then a.eval calls locals else b.eval calls locals
  | .local name _ localValue rest => rest.eval calls (locals.set _ name (localValue.eval calls locals))
  | .locals body => body.eval calls locals
  | .byteAt text position => Cursor.byteAt (text.eval calls locals) (position.eval calls locals)
  | .sourceLast text | .sourceLength text => (text.eval calls locals).length
  | .characterVal localValue => localValue.eval calls locals
  | .maxLength => maxSourceLength | .maxBindings => Compose.maxBindings | .maxOperands => maxExpressionOperands
  | .maxConcatenations => Compose.maxConcatenations
  | .token tok => tok | .tokenEq a b => a.eval calls locals == b.eval calls locals
  | .tokenSpelling t => spelling (t.eval calls locals)
  | .spellingLength s => (s.eval calls locals).toList.length
  | .wordToken t => isWord (t.eval calls locals)
  | .hasArguments f => (f.eval calls locals).hasArguments
  | .tokensLast f => (f.eval calls locals).tokens.length
  | .tokenIndex f i => (f.eval calls locals).tokens.getD (i.eval calls locals - 1) (.symbol ";")
  | .initial => initialState | .invalid => invalidState
  | .invalidValue => Compose.invalidValue | .invalidResult => invalidExpression
  | .invalidScan => invalidExpressionState
  | .binding a b c d e f => ⟨a.eval calls locals,b.eval calls locals,c.eval calls locals,d.eval calls locals,e.eval calls locals,f.eval calls locals⟩
  | .value a b c d e => ⟨a.eval calls locals,b.eval calls locals,c.eval calls locals,d.eval calls locals,e.eval calls locals⟩
  | .result a b c d => ⟨a.eval calls locals,b.eval calls locals,c.eval calls locals,d.eval calls locals⟩
  | .scan p l d o depth named need complete => ⟨p.eval calls locals,l.eval calls locals,
      d.eval calls locals,o.eval calls locals,depth.eval calls locals,named.eval calls locals,
      need.eval calls locals,complete.eval calls locals⟩
  | .scanDepth s p d => {(s.eval calls locals) with position := p.eval calls locals, depth := d.eval calls locals}
  | .scanAtom s p l d o n => {(s.eval calls locals) with position := p.eval calls locals, staticLength := l.eval calls locals, dynamicCount := d.eval calls locals, operands := o.eval calls locals, namedSeen := n.eval calls locals, needOperand := false}
  | .scanNeed s p => {(s.eval calls locals) with position := p.eval calls locals, needOperand := true}
  | .scanComplete s => {(s.eval calls locals) with complete := true}
  | .statePosition s p => {(s.eval calls locals) with position := p.eval calls locals}
  | .stateTarget s p t => {(s.eval calls locals) with position := p.eval calls locals, target := t.eval calls locals}
  | .stateCapacity s p c => {(s.eval calls locals) with position := p.eval calls locals, capacity := c.eval calls locals}
  | .stateDynamic s a b => {(s.eval calls locals) with dynamicFirst := a.eval calls locals, dynamicAfter := b.eval calls locals}
  | .stateBinding s p info =>
      {(s.eval calls locals) with position := p.eval calls locals, names := (s.eval calls locals).names ++ [info.eval calls locals]}
  | .someForm source => allForms.any (calls.function .formMember (source.eval calls locals))
  | .firstForm arguments source => firstFlag (source.eval calls locals) (calls.function .formMember)
      (if arguments then Form.hasArguments else Form.hasAssignment)

def skipBody : Expr .number :=
  (.ite (.eq (.variable "position") (.number 0)) (.number 0) (.lexTrivia (.variable "text") (.variable "position")))

def nameBody : Expr .number :=
  (.ite (.eq (.variable "position") (.number 0)) (.number 0) (.lexIdentifier (.variable "text") (.variable "position")))

def fixedBody : Expr .number :=
  (.ite (.eq (.variable "position") (.number 0)) (.number 0) (.elsif (.lexTokenAt (.variable "text") (.lexTrivia (.variable "text") (.variable "position")) (.tokenSpelling (.variable "token")) (.wordToken (.variable "token"))) (.add (.lexTrivia (.variable "text") (.variable "position")) (.spellingLength (.tokenSpelling (.variable "token")))) (.number 0)))

def lookupFromBody : Expr .number :=
  (.ite (.gt (.variable "index") (.count (.variable "names"))) (.number 0) (.elsif (.lexEqual (.variable "text") (.field .bindingFirst (.item (.variable "names") (.variable "index"))) (.field .bindingAfter (.item (.variable "names") (.variable "index"))) (.variable "first") (.variable "after")) (.variable "index") (.app (.app (.app (.app (.app (.function .lookupFrom) (.variable "text")) (.variable "names")) (.variable "first")) (.variable "after")) (.add (.variable "index") (.number 1)))))

def lookupBody : Expr .number :=
  (.ite (.orElse (.eq (.variable "first") (.number 0)) (.le (.variable "after") (.variable "first"))) (.number 0) (.app (.app (.app (.app (.app (.function .lookupFrom) (.variable "text")) (.variable "names")) (.variable "first")) (.variable "after")) (.number 1)))

def literalBody : Expr .value :=
  (.ite (.andThen (.andThen (.andThen (.ne (.variable "position") (.number 0)) (.le (.variable "position") (.sourceLast (.variable "text")))) (.eq (.byteAt (.variable "text") (.variable "position")) (.characterVal (.number 34)))) (.ne (.lexLiteralEnd (.variable "text") (.add (.variable "position") (.number 1))) (.number 0))) (.value (.lexLiteralEnd (.variable "text") (.add (.variable "position") (.number 1))) (.add (.variable "position") (.number 1)) (.lexLiteralLength (.variable "text") (.add (.variable "position") (.number 1))) (.truth false) (.number 0)) (.invalidValue))

def workTailBody : Expr .truth :=
  let text : Expr .source := .variable "text"
  let first : Expr .number := .variable "first"
  let quoted : Expr .value := .variable "quoted"
  let remaining : Expr .number := .variable "remaining"
  let recurse (p r : Expr .number) := Expr.app (.app (.app (.function .workTail) text) p) r
  .locals <| .local "first" "literal_position" (.app (.app (.function .skip) text) (.variable "position")) <|
    .local "quoted" "value_result" (.app (.app (.function .literal) text) first) <|
    .group <| .ite (.eq first (.number 0)) (.truth false) <|
    .elsif (.gt first (.sourceLast text)) (.truth true) <|
    .elsif (.eq (.byteAt text first) (.characterVal (.number 34)))
      (.andThen (.ne (.field .valueAfter quoted) (.number 0))
        (recurse (.field .valueAfter quoted) remaining)) <|
    .elsif (.eq (.byteAt text first) (.characterVal (.number 38)))
      (.andThen (.ne remaining (.number 0))
        (recurse (.add first (.number 1)) (.sub remaining (.number 1))))
      (recurse (.add first (.number 1)) remaining)

def workBudgetBody : Expr .truth :=
  .app (.app (.app (.function .workTail) (.variable "text")) (.number 1)) .maxConcatenations

def valueBody : Expr .value :=
  (.locals (.local "first" "literal_position" (.app (.app (.function .skip) (.variable "text")) (.variable "position")) (.local "quoted" "value_result" (.app (.app (.function .literal) (.variable "text")) (.variable "first")) (.local "after" "literal_position" (.app (.app (.function .nameAfter) (.variable "text")) (.variable "first")) (.local "index" "binding_count" (.app (.app (.app (.app (.function .lookupName) (.variable "text")) (.variable "names")) (.variable "first")) (.variable "after")) (.group (.ite (.ne (.field .valueAfter (.variable "quoted")) (.number 0)) (.variable "quoted") (.elsif (.ne (.variable "index") (.number 0)) (.value (.variable "after") (.field .bindingValueFirst (.item (.variable "names") (.variable "index"))) (.field .bindingLength (.item (.variable "names") (.variable "index"))) (.field .bindingDynamic (.item (.variable "names") (.variable "index"))) (.variable "index")) (.invalidValue)))))))))

def newNameBody : Expr .truth :=
  (.andThen (.andThen (.andThen (.andThen (.ne (.variable "first") (.number 0)) (.gt (.variable "after") (.variable "first"))) (.not (.lexForbidden (.variable "text") (.variable "first") (.variable "after")))) (.group (.orElse (.not (.variable "arguments")) (.not (.lexForbiddenArgument (.variable "text") (.variable "first") (.variable "after")))))) (.eq (.app (.app (.app (.app (.function .lookupName) (.variable "text")) (.field .stateNames (.variable "state"))) (.variable "first")) (.variable "after")) (.number 0)))

def addBindingBody : Expr .state :=
  (.stateBinding (.variable "state") (.variable "following") (.binding (.variable "first") (.variable "after") (.field .valueFirst (.variable "value")) (.field .valueLength (.variable "value")) (.field .valueDynamic (.variable "value")) (.variable "mutable")))

def declarationBody : Expr .state :=
  let text : Expr .source := .variable "text"
  let state : Expr .state := .variable "state"
  let value : Expr .result := .variable "value"
  let take (p : Expr .number) (t : ShellToken) := Expr.app (.app (.app (.function .takeToken) text) p) (.token t)
  .locals <| .local "first" "literal_position" (.app (.app (.function .skip) text) (.field .statePosition state)) <|
    .local "after" "literal_position" (.app (.app (.function .nameAfter) text) (.variable "first")) <|
    .local "colon_after" "literal_position" (take (.variable "after") (.symbol ":")) <|
    .local "constant_after" "literal_position" (take (.variable "colon_after") (.word "constant")) <|
    .local "type_after" "literal_position" (take (.group <| .ite (.ne (.variable "constant_after") (.number 0))
      (.variable "constant_after") (.variable "colon_after")) (.word "string")) <|
    .local "value" "expression_result" (.app (.app (.app (.function .expression) text)
      (take (.variable "type_after") (.symbol ":="))) (.field .stateNames state)) <|
    .local "following" "literal_position" (take (.field .resultAfter value) (.symbol ";")) <|
    .group <| .ite (.orElse (.orElse (.orElse
      (.not <| .app (.app (.app (.app (.app (.function .newName) text) state)
        (.variable "first")) (.variable "after")) (.variable "arguments"))
      (.eq (.variable "following") (.number 0)))
      (.eq (.count (.field .stateNames state)) .maxBindings))
      (.not <| .app (.app (.function .fits) value) .maxLength)) .invalid
      (.app (.app (.app (.app (.app (.app (.function .addBinding) state)
        (.variable "first")) (.variable "after"))
        (.value (.field .resultAfter value) (.number 0) (.field .resultLength value)
          (.eq (.field .resultDynamic value) (.number 1)) (.number 0)))
        (.eq (.variable "constant_after") (.number 0))) (.variable "following"))

def argumentBody : Expr .state :=
  (.locals (.local "first" "literal_position" (.app (.app (.function .skip) (.variable "text")) (.field .statePosition (.variable "state"))) (.local "after" "literal_position" (.app (.app (.function .nameAfter) (.variable "text")) (.variable "first")) (.local "prefix" "literal_position" (.app (.app (.app (.function .takeToken) (.variable "text")) (.app (.app (.app (.function .takeToken) (.variable "text")) (.app (.app (.app (.function .takeToken) (.variable "text")) (.app (.app (.app (.function .takeToken) (.variable "text")) (.app (.app (.app (.function .takeToken) (.variable "text")) (.app (.app (.app (.function .takeToken) (.variable "text")) (.app (.app (.app (.function .takeToken) (.variable "text")) (.app (.app (.app (.function .takeToken) (.variable "text")) (.variable "after")) (.token (.fixed ":" false)))) (.token (.fixed "constant" true)))) (.token (.fixed "string" true)))) (.token (.fixed ":=" false)))) (.token (.fixed "silver_arguments" true)))) (.token (.fixed "." false)))) (.token (.fixed "first_or_default" true)))) (.token (.fixed "(" false))) (.local "default_value" "value_result" (.app (.app (.function .literal) (.variable "text")) (.app (.app (.function .skip) (.variable "text")) (.variable "prefix"))) (.local "following" "literal_position" (.app (.app (.app (.function .takeToken) (.variable "text")) (.app (.app (.app (.function .takeToken) (.variable "text")) (.field .valueAfter (.variable "default_value"))) (.token (.fixed ")" false)))) (.token (.fixed ";" false))) (.group (.ite (.orElse (.orElse (.not (.app (.app (.app (.app (.app (.function .newName) (.variable "text")) (.variable "state")) (.variable "first")) (.variable "after")) (.truth true))) (.eq (.variable "following") (.number 0))) (.ne (.count (.field .stateNames (.variable "state"))) (.number 0))) (.invalid) (.stateDynamic (.app (.app (.app (.app (.app (.app (.function .addBinding) (.variable "state")) (.variable "first")) (.variable "after")) (.value (.variable "following") (.number 0) (.number 0) (.truth true) (.number 0))) (.truth false)) (.variable "following")) (.variable "first") (.variable "after"))))))))))

def declarationsBody : Expr .state :=
  (.ite (.eq (.field .statePosition (.variable "state")) (.number 0)) (.invalid) (.elsif (.ne (.app (.app (.app (.function .takeToken) (.variable "text")) (.field .statePosition (.variable "state"))) (.token (.fixed "begin" true))) (.number 0)) (.variable "state") (.elsif (.eq (.field .statePosition (.app (.app (.app (.function .declaration) (.variable "text")) (.variable "state")) (.variable "arguments"))) (.number 0)) (.invalid) (.app (.app (.app (.function .declarations) (.variable "text")) (.app (.app (.app (.function .declaration) (.variable "text")) (.variable "state")) (.variable "arguments"))) (.variable "arguments")))))

def expressionStepBody : Expr .scan :=
  let text : Expr .source := .variable "text"
  let state : Expr .scan := .variable "state"
  let atom : Expr .value := .variable "atom"
  let take (t : ShellToken) := Expr.app (.app (.app (.function .takeToken) text)
    (.field .scanPosition state)) (.token t)
  .locals <| .local "open_after" "literal_position" (take (.symbol "(")) <|
    .local "atom" "value_result" (.app (.app (.app (.function .value) text)
      (.field .scanPosition state)) (.variable "names")) <|
    .local "join_after" "literal_position" (take (.symbol "&")) <|
    .local "close_after" "literal_position" (take (.symbol ")")) <|
    .group <| .ite (.eq (.field .scanPosition state) (.number 0)) .invalidScan <|
    .elsif (.field .scanComplete state) state <|
    .elsif (.field .scanNeed state)
      (.group <| .ite (.ne (.variable "open_after") (.number 0))
        (.scanDepth state (.variable "open_after") (.add (.field .scanDepth state) (.number 1))) <|
        .elsif (.orElse (.orElse (.eq (.field .scanOperands state) .maxOperands)
          (.eq (.field .valueAfter atom) (.number 0)))
          (.gt (.field .valueLength atom) (.sub .maxLength (.field .scanLength state)))) .invalidScan <|
        .scanAtom state (.field .valueAfter atom)
          (.add (.field .scanLength state) (.field .valueLength atom))
          (.add (.field .scanDynamic state) (.group <| .ite (.field .valueDynamic atom) (.number 1) (.number 0)))
          (.add (.field .scanOperands state) (.number 1))
          (.orElse (.field .scanNamed state) (.ne (.field .valueReference atom) (.number 0)))) <|
    .elsif (.ne (.variable "join_after") (.number 0)) (.scanNeed state (.variable "join_after")) <|
    .elsif (.andThen (.ne (.variable "close_after") (.number 0)) (.ne (.field .scanDepth state) (.number 0)))
      (.scanDepth state (.variable "close_after") (.sub (.field .scanDepth state) (.number 1))) <|
    .elsif (.eq (.field .scanDepth state) (.number 0)) (.scanComplete state) .invalidScan

def tailBody : Expr .result :=
  let state : Expr .scan := .variable "state"
  let next : Expr .scan := .variable "next"
  let result (s : Expr .scan) := Expr.result (.field .scanPosition s) (.field .scanLength s)
    (.field .scanDynamic s) (.field .scanNamed s)
  .ite (.eq (.field .scanPosition state) (.number 0)) .invalidResult <|
    .elsif (.field .scanComplete state) (result state) <|
    .group <| .locals <| .local "next" "expression_state"
      (.app (.app (.app (.function .expressionStep) (.variable "text")) (.variable "names")) state) <|
    .group <| .ite (.eq (.field .scanPosition next) (.number 0)) .invalidResult <|
    .elsif (.field .scanComplete next) (result next)
      (.app (.app (.app (.function .tail) (.variable "text")) (.variable "names")) next)

def expressionBody : Expr .result :=
  .app (.app (.app (.function .tail) (.variable "text")) (.variable "names"))
    (.scan (.variable "position") (.number 0) (.number 0) (.number 0) (.number 0)
      (.truth false) (.truth true) (.truth false))

def fitsBody : Expr .truth :=
  let value : Expr .result := .variable "value"
  .andThen (.ne (.field .resultAfter value) (.number 0))
    (.le (.add (.field .resultLength value) (.mul (.field .resultDynamic value) (.variable "capacity"))) .maxLength)

def targetBody : Expr .state :=
  (.locals (.local "first" "literal_position" (.app (.app (.function .skip) (.variable "text")) (.field .statePosition (.variable "state"))) (.local "after" "literal_position" (.app (.app (.function .nameAfter) (.variable "text")) (.variable "first")) (.local "index" "binding_count" (.app (.app (.app (.app (.function .lookupName) (.variable "text")) (.field .stateNames (.variable "state"))) (.variable "first")) (.variable "after")) (.group (.ite (.orElse (.orElse (.eq (.variable "index") (.number 0)) (.not (.field .bindingMutable (.item (.field .stateNames (.variable "state")) (.variable "index"))))) (.group (.andThen (.variable "same_target") (.ne (.variable "index") (.field .stateTarget (.variable "state")))))) (.invalid) (.stateTarget (.variable "state") (.variable "after") (.variable "index"))))))))

def dynamicBody : Expr .state :=
  (.locals (.local "first" "literal_position" (.app (.app (.function .skip) (.variable "text")) (.field .statePosition (.variable "state"))) (.local "after" "literal_position" (.app (.app (.function .nameAfter) (.variable "text")) (.variable "first")) (.group (.ite (.orElse (.orElse (.orElse (.eq (.variable "first") (.number 0)) (.eq (.variable "after") (.number 0))) (.eq (.field .stateDynamicFirst (.variable "state")) (.number 0))) (.not (.lexEqual (.variable "text") (.field .stateDynamicFirst (.variable "state")) (.field .stateDynamicAfter (.variable "state")) (.variable "first") (.variable "after")))) (.invalid) (.statePosition (.variable "state") (.variable "after")))))))

def assignmentBody : Expr .state :=
  let text : Expr .source := .variable "text"
  let state : Expr .state := .variable "state"
  let value : Expr .result := .variable "value"
  let target := Expr.item (.field .stateNames state) (.field .stateTarget state)
  .locals <| .local "value" "expression_result"
    (.app (.app (.app (.function .expression) text) (.field .statePosition state)) (.field .stateNames state)) <|
    .group <| .ite (.orElse (.orElse (.orElse
      (.not <| .app (.app (.function .fits) value) (.field .stateCapacity state))
      (.eq (.field .stateTarget state) (.number 0)))
      (.ne (.field .resultLength value) (.field .bindingLength target)))
      (.ne (.field .resultDynamic value) (.group <| .ite (.field .bindingDynamic target) (.number 1) (.number 0))))
      .invalid (.statePosition state (.field .resultAfter value))

def outputBody : Expr .state :=
  let state : Expr .state := .variable "state"
  let value : Expr .result := .variable "value"
  .locals <| .local "value" "expression_result"
    (.app (.app (.app (.function .expression) (.variable "text")) (.field .statePosition state)) (.field .stateNames state)) <|
    .group <| .ite (.not <| .app (.app (.function .fits) value) (.field .stateCapacity state))
      .invalid (.statePosition state (.field .resultAfter value))

def comparisonBody : Expr .state :=
  let state : Expr .state := .variable "state"
  let text : Expr .source := .variable "text"
  let lhs : Expr .result := .variable "left"
  let rhs : Expr .result := .variable "right"
  .locals <| .local "left" "expression_result"
    (.app (.app (.app (.function .expression) text) (.field .statePosition state)) (.field .stateNames state)) <|
    .local "right" "expression_result" (.app (.app (.app (.function .expression) text)
      (.app (.app (.app (.function .takeToken) text) (.field .resultAfter lhs)) (.token (.symbol "=")))) (.field .stateNames state)) <|
    .group <| .ite (.orElse (.orElse
      (.not <| .app (.app (.function .fits) lhs) (.field .stateCapacity state))
      (.not <| .app (.app (.function .fits) rhs) (.field .stateCapacity state)))
      (.not <| .group <| .orElse (.field .resultNamed lhs) (.field .resultNamed rhs)))
      .invalid (.statePosition state (.field .resultAfter rhs))

def capacityBody : Expr .state :=
  let state : Expr .state := .variable "state"
  let position := Expr.field .statePosition state
  let parsed := Expr.lexDecimal (.variable "text") (.lexTrivia (.variable "text") position)
  .ite (.eq position (.number 0)) .invalid
    (.elsif (.eq (.field .decimalAfter parsed) (.number 0)) .invalid
      (.stateCapacity state (.field .decimalAfter parsed) (.field .decimalValue parsed)))

def stepBody : Expr .state :=
  let text : Expr .source := .variable "text"
  let state : Expr .state := .variable "state"
  let is (t : ShellToken) := Expr.tokenEq (.variable "token") (.token t)
  let action (f : Function) (h : f.type = .arrow .source (.arrow .state .state)) : Expr .state :=
    .app (.app (h ▸ Expr.function f) text) state
  .ite (.eq (.field .statePosition state) (.number 0)) .invalid <|
    .elsif (is .argumentDeclaration) (action .argument rfl) <|
    .elsif (is .declarations) (.app (.app (.app (.function .readDeclarations) text) state) (.hasArguments (.variable "form"))) <|
    .elsif (is .assignmentTarget) (.app (.app (.app (.function .target) text) state) (.truth false)) <|
    .elsif (is .targetReference) (.app (.app (.app (.function .target) text) state) (.truth true)) <|
    .elsif (is .dynamicReference) (action .dynamic rfl) <|
    .elsif (is .assignmentValue) (action .assignmentValue rfl) <|
    .elsif (is .outputExpression) (action .output rfl) <|
    .elsif (is .comparisonExpression) (action .comparison rfl) <|
    .elsif (is .capacity) (action .capacity rfl) <|
    .elsif (is .literal) (.statePosition state (.field .valueAfter
      (.app (.app (.function .literal) text) (.app (.app (.function .skip) text) (.field .statePosition state)))))
      (.statePosition state (.app (.app (.app (.function .takeToken) text) (.field .statePosition state)) (.variable "token")))

def suffixBody : Expr .truth :=
  (.ite (.eq (.field .statePosition (.variable "state")) (.number 0)) (.truth false) (.elsif (.gt (.variable "next_token") (.tokensLast (.variable "form"))) (.eq (.lexTrivia (.variable "text") (.field .statePosition (.variable "state"))) (.add (.sourceLast (.variable "text")) (.number 1))) (.app (.app (.app (.app (.function .suffix) (.variable "text")) (.variable "form")) (.add (.variable "next_token") (.number 1))) (.app (.app (.app (.app (.function .step) (.variable "text")) (.variable "form")) (.tokenIndex (.variable "form") (.variable "next_token"))) (.variable "state")))))

def formBody : Expr .truth :=
  let source : Expr .source := .variable "source"
  .andThen (.andThen (.andThen
    (.range (.sourceLength source) (.number 1) .maxLength)
    (.lexAllowed (.lexNormalize source)))
    (.app (.function .workBudget) (.lexNormalize source)))
    (.app (.app (.app (.app (.function .suffix) (.lexNormalize source))
      (.variable "form")) (.number 1)) .initial)

def memberBody : Expr .truth :=
  (.someForm (.variable "source"))

def argumentsBody : Expr .truth :=
  (.firstForm true (.variable "source"))

def assignmentSelectorBody : Expr .truth :=
  (.firstForm false (.variable "source"))

def modelPrimitives : Primitives where
  trivia := Cursor.triviaPosition
  literal := Output.literalEnd
  length := Guarded.literalLength
  identifier := Named.identifierEnd
  forbidden := Named.forbiddenName
  forbiddenArgument := Arguments.forbiddenName
  equal := Named.equalName
  decimal := Guarded.decimalAt
  token := fixedAt
  normalize := id
  allowed := fun text => text.all allowedCharacter

def lexical (calls : Calls) : Calls := {calls with primitive := modelPrimitives}


def Function.isLexical : Function → Bool
  | .trivia | .literalEnd | .literalLength | .identifier | .forbidden | .forbiddenArgument | .equal | .decimal | .tokenAt | .normalize | .allowed => true
  | _ => false

/-- Ada 2022 expression categories. Renderers preserve explicit grouping;
these checks prevent a flattened tree from changing precedence or association. -/
def Expr.primary : Expr ty → Bool
  | .add _ _ | .sub _ _ | .mul _ _ | .eq _ _ | .ne _ _ | .boolNe _ _ | .lt _ _ | .le _ _ | .gt _ _
  | .range _ _ _ | .andThen _ _ | .orElse _ _ | .not _ | .ite _ _ _ | .elsif _ _ _
  | .local _ _ _ _ | .locals _ | .someForm _ | .firstForm _ _ => false
  | _ => true

def Expr.term : Expr .number → Bool
  | .mul _ _ => true
  | x => x.primary

def Expr.simple : Expr ty → Bool
  | .ite _ _ _ | .elsif _ _ _ | .local _ _ _ _ | .locals _ | .someForm _ | .firstForm _ _ => false
  | _ => true

def Expr.relation : Expr .truth → Bool
  | .andThen _ _ | .orElse _ _ | .ite _ _ _ | .elsif _ _ _ | .local _ _ _ _
  | .locals _ | .someForm _ | .firstForm _ _ => false
  | _ => true

def Expr.logical : Expr .truth → Bool
  | .ite _ _ _ | .elsif _ _ _ | .local _ _ _ _ | .locals _ | .someForm _ | .firstForm _ _ => false
  | _ => true

def Expr.isElsif : Expr ty → Bool | .elsif _ _ _ => true | _ => false

def Expr.andLeft : Expr .truth → Bool | .andThen _ _ => true | x => x.relation

def Expr.orLeft : Expr .truth → Bool | .orElse _ _ => true | x => x.relation

def Expr.functionSpine : Expr ty → Bool
  | .function _ => true
  | .app f _ => f.functionSpine
  | _ => false

def localType : (ty : Ty) → String → Bool
  | .number, name => decide (name ∈ ["literal_position", "binding_count", "capacity_value", "operand_count"])
  | .value, name => name == "value_result"
  | .result, name => name == "expression_result"
  | .scan, name => name == "expression_state"
  | _, _ => false

def Expr.wellFormed : Expr ty → Bool
  | .lexTrivia a b => a.wellFormed && b.wellFormed
  | .lexLiteralEnd a b => a.wellFormed && b.wellFormed
  | .lexLiteralLength a b => a.wellFormed && b.wellFormed
  | .lexIdentifier a b => a.wellFormed && b.wellFormed
  | .lexForbidden a b c => a.wellFormed && b.wellFormed && c.wellFormed
  | .lexForbiddenArgument a b c => a.wellFormed && b.wellFormed && c.wellFormed
  | .lexEqual a b c d e => a.wellFormed && b.wellFormed && c.wellFormed && d.wellFormed && e.wellFormed
  | .lexDecimal a b => a.wellFormed && b.wellFormed
  | .lexTokenAt a b c d => a.wellFormed && b.wellFormed && c.wellFormed && d.wellFormed
  | .lexNormalize a => a.wellFormed
  | .lexAllowed a => a.wellFormed
  | .app f x => f.wellFormed && x.wellFormed && f.functionSpine && x.simple
  | .field _ x => x.wellFormed && x.primary
  | .count x => x.wellFormed
  | .item x i => x.wellFormed && i.wellFormed
  | .add x y => x.wellFormed && y.wellFormed && x.simple && y.term
  | .sub x y => x.wellFormed && y.wellFormed && x.simple && y.term
  | .mul x y => x.wellFormed && y.wellFormed && x.primary && y.primary
  | .eq x y => x.wellFormed && y.wellFormed && x.simple && y.simple
  | .ne x y => x.wellFormed && y.wellFormed && x.simple && y.simple
  | .boolNe x y => x.wellFormed && y.wellFormed && x.simple && y.simple
  | .lt x y => x.wellFormed && y.wellFormed && x.simple && y.simple
  | .le x y => x.wellFormed && y.wellFormed && x.simple && y.simple
  | .gt x y => x.wellFormed && y.wellFormed && x.simple && y.simple
  | .range x a b => x.wellFormed && a.wellFormed && b.wellFormed && x.simple && a.simple && b.simple
  | .not x => x.wellFormed && x.primary
  | .group x => x.wellFormed && !x.isElsif
  | .locals x => x.wellFormed
  | .byteAt text position => text.wellFormed && position.wellFormed
  | .sourceLast text => text.wellFormed
  | .sourceLength text => text.wellFormed
  | .characterVal x => x.wellFormed
  | .tokenEq x y => x.wellFormed && y.wellFormed
  | .tokenSpelling x => x.wellFormed
  | .spellingLength x => x.wellFormed
  | .wordToken x => x.wellFormed
  | .hasArguments x => x.wellFormed
  | .tokensLast x => x.wellFormed
  | .tokenIndex x i => x.wellFormed && i.wellFormed
  | .binding a b c d e f => a.wellFormed && b.wellFormed && c.wellFormed && d.wellFormed && e.wellFormed && f.wellFormed
  | .value a b c d e => a.wellFormed && b.wellFormed && c.wellFormed && d.wellFormed && e.wellFormed
  | .result a b c d => a.wellFormed && b.wellFormed && c.wellFormed && d.wellFormed
  | .scan a b c d e f g h => a.wellFormed && b.wellFormed && c.wellFormed && d.wellFormed &&
      e.wellFormed && f.wellFormed && g.wellFormed && h.wellFormed
  | .scanDepth s p d => s.wellFormed && p.wellFormed && d.wellFormed
  | .scanAtom s p l d o n => s.wellFormed && p.wellFormed && l.wellFormed && d.wellFormed && o.wellFormed && n.wellFormed
  | .scanNeed s p => s.wellFormed && p.wellFormed
  | .scanComplete s => s.wellFormed
  | .statePosition s p => s.wellFormed && p.wellFormed
  | .stateTarget s p t => s.wellFormed && p.wellFormed && t.wellFormed
  | .stateCapacity s p c => s.wellFormed && p.wellFormed && c.wellFormed
  | .stateDynamic s a b => s.wellFormed && a.wellFormed && b.wellFormed
  | .stateBinding s p info => s.wellFormed && p.wellFormed && info.wellFormed
  | .someForm source => source.wellFormed
  | .firstForm _ source => source.wellFormed
  | .number _ => true
  | .truth _ => true
  | .variable _ => true
  | .maxLength  => true
  | .maxBindings  => true
  | .maxOperands  => true
  | .maxConcatenations => true
  | .token _ => true
  | .initial  => true
  | .invalid  => true
  | .invalidValue  => true
  | .invalidResult  => true
  | .invalidScan => true
  | .function _ => true
  | .andThen a b => a.wellFormed && b.wellFormed && a.andLeft && b.relation
  | .orElse a b => a.wellFormed && b.wellFormed && a.orLeft && b.relation
  | .ite c a b | .elsif c a b => c.wellFormed && c.logical && a.wellFormed && a.simple &&
      b.wellFormed && (b.simple || b.isElsif)
  | .local (a := ty) _ typeName localValue rest => localType ty typeName && localValue.wellFormed &&
      localValue.simple && rest.wellFormed

abbrev WellFormedTrees : Prop :=
  skipBody.wellFormed = true ∧
  nameBody.wellFormed = true ∧
  fixedBody.wellFormed = true ∧
  lookupFromBody.wellFormed = true ∧
  lookupBody.wellFormed = true ∧
  literalBody.wellFormed = true ∧
  workTailBody.wellFormed = true ∧
  workBudgetBody.wellFormed = true ∧
  valueBody.wellFormed = true ∧
  newNameBody.wellFormed = true ∧
  addBindingBody.wellFormed = true ∧
  declarationBody.wellFormed = true ∧
  argumentBody.wellFormed = true ∧
  declarationsBody.wellFormed = true ∧
  expressionStepBody.wellFormed = true ∧
  fitsBody.wellFormed = true ∧
  comparisonBody.wellFormed = true ∧
  tailBody.wellFormed = true ∧
  expressionBody.wellFormed = true ∧
  targetBody.wellFormed = true ∧
  dynamicBody.wellFormed = true ∧
  assignmentBody.wellFormed = true ∧
  outputBody.wellFormed = true ∧
  capacityBody.wellFormed = true ∧
  stepBody.wellFormed = true ∧
  suffixBody.wellFormed = true ∧
  formBody.wellFormed = true ∧
  memberBody.wellFormed = true ∧
  argumentsBody.wellFormed = true ∧
  assignmentSelectorBody.wellFormed = true

theorem checked_precedence : WellFormedTrees := by decide +kernel

/-- Names are checked against the parameter/local declaration scope. The
first binding wins, matching Ada lexical shadowing; a variable of another type
cannot accidentally read a default value from the semantic environment. -/
abbrev Scope := List (String × Ty)

def Scope.contains (scope : Scope) (name : String) (ty : Ty) : Bool :=
  ((scope.find? (fun item => item.1 == name)).map Prod.snd) == some ty

def Expr.scoped (scope : Scope) : Expr ty → Bool
  | .lexTrivia a b => a.scoped scope && b.scoped scope
  | .lexLiteralEnd a b => a.scoped scope && b.scoped scope
  | .lexLiteralLength a b => a.scoped scope && b.scoped scope
  | .lexIdentifier a b => a.scoped scope && b.scoped scope
  | .lexForbidden a b c => a.scoped scope && b.scoped scope && c.scoped scope
  | .lexForbiddenArgument a b c => a.scoped scope && b.scoped scope && c.scoped scope
  | .lexEqual a b c d e => a.scoped scope && b.scoped scope && c.scoped scope && d.scoped scope && e.scoped scope
  | .lexDecimal a b => a.scoped scope && b.scoped scope
  | .lexTokenAt a b c d => a.scoped scope && b.scoped scope && c.scoped scope && d.scoped scope
  | .lexNormalize a => a.scoped scope
  | .lexAllowed a => a.scoped scope
  | .app f x => f.scoped scope && x.scoped scope
  | .field _ x => x.scoped scope
  | .count x => x.scoped scope
  | .item x i => x.scoped scope && i.scoped scope
  | .add x y => x.scoped scope && y.scoped scope
  | .sub x y => x.scoped scope && y.scoped scope
  | .mul x y => x.scoped scope && y.scoped scope
  | .eq x y => x.scoped scope && y.scoped scope
  | .ne x y => x.scoped scope && y.scoped scope
  | .boolNe x y => x.scoped scope && y.scoped scope
  | .lt x y => x.scoped scope && y.scoped scope
  | .le x y => x.scoped scope && y.scoped scope
  | .gt x y => x.scoped scope && y.scoped scope
  | .range x a b => x.scoped scope && a.scoped scope && b.scoped scope
  | .not x => x.scoped scope
  | .group x => x.scoped scope
  | .locals x => x.scoped scope
  | .byteAt text position => text.scoped scope && position.scoped scope
  | .sourceLast text => text.scoped scope
  | .sourceLength text => text.scoped scope
  | .characterVal x => x.scoped scope
  | .tokenEq x y => x.scoped scope && y.scoped scope
  | .tokenSpelling x => x.scoped scope
  | .spellingLength x => x.scoped scope
  | .wordToken x => x.scoped scope
  | .hasArguments x => x.scoped scope
  | .tokensLast x => x.scoped scope
  | .tokenIndex x i => x.scoped scope && i.scoped scope
  | .binding a b c d e f => a.scoped scope && b.scoped scope && c.scoped scope && d.scoped scope && e.scoped scope && f.scoped scope
  | .value a b c d e => a.scoped scope && b.scoped scope && c.scoped scope && d.scoped scope && e.scoped scope
  | .result a b c d => a.scoped scope && b.scoped scope && c.scoped scope && d.scoped scope
  | .scan a b c d e f g h => a.scoped scope && b.scoped scope && c.scoped scope && d.scoped scope &&
      e.scoped scope && f.scoped scope && g.scoped scope && h.scoped scope
  | .scanDepth s p d => s.scoped scope && p.scoped scope && d.scoped scope
  | .scanAtom s p l d o n => s.scoped scope && p.scoped scope && l.scoped scope && d.scoped scope && o.scoped scope && n.scoped scope
  | .scanNeed s p => s.scoped scope && p.scoped scope
  | .scanComplete s => s.scoped scope
  | .statePosition s p => s.scoped scope && p.scoped scope
  | .stateTarget s p t => s.scoped scope && p.scoped scope && t.scoped scope
  | .stateCapacity s p c => s.scoped scope && p.scoped scope && c.scoped scope
  | .stateDynamic s a b => s.scoped scope && a.scoped scope && b.scoped scope
  | .stateBinding s p info => s.scoped scope && p.scoped scope && info.scoped scope
  | .someForm source => source.scoped scope
  | .firstForm _ source => source.scoped scope
  | .number _ => true
  | .truth _ => true
  | .maxLength  => true
  | .maxBindings  => true
  | .maxOperands  => true
  | .maxConcatenations => true
  | .token _ => true
  | .initial  => true
  | .invalid  => true
  | .invalidValue  => true
  | .invalidResult  => true
  | .invalidScan => true
  | .variable (ty := ty) name => scope.contains name ty
  | .function _ => true
  | .andThen a b | .orElse a b => a.scoped scope && b.scoped scope
  | .ite c a b | .elsif c a b => c.scoped scope && a.scoped scope && b.scoped scope
  | .local (a := ty) name _ localValue rest => localValue.scoped scope && rest.scoped ((name,ty) :: scope)

abbrev WellScopedTrees : Prop :=
  skipBody.scoped [("text", .source), ("position", .number)] = true ∧
  nameBody.scoped [("text", .source), ("position", .number)] = true ∧
  fixedBody.scoped [("text", .source), ("position", .number), ("token", .token)] = true ∧
  lookupFromBody.scoped [("text", .source), ("names", .names), ("first", .number), ("after", .number), ("index", .number)] = true ∧
  lookupBody.scoped [("text", .source), ("names", .names), ("first", .number), ("after", .number)] = true ∧
  literalBody.scoped [("text", .source), ("position", .number)] = true ∧
  workTailBody.scoped [("text", .source), ("position", .number), ("remaining", .number)] = true ∧
  workBudgetBody.scoped [("text", .source)] = true ∧
  valueBody.scoped [("text", .source), ("position", .number), ("names", .names)] = true ∧
  newNameBody.scoped [("text", .source), ("state", .state), ("first", .number), ("after", .number), ("arguments", .truth)] = true ∧
  addBindingBody.scoped [("state", .state), ("first", .number), ("after", .number), ("value", .value), ("mutable", .truth), ("following", .number)] = true ∧
  declarationBody.scoped [("text", .source), ("state", .state), ("arguments", .truth)] = true ∧
  argumentBody.scoped [("text", .source), ("state", .state)] = true ∧
  declarationsBody.scoped [("text", .source), ("state", .state), ("arguments", .truth)] = true ∧
  expressionStepBody.scoped [("text", .source), ("names", .names), ("state", .scan)] = true ∧
  tailBody.scoped [("text", .source), ("names", .names), ("state", .scan)] = true ∧
  fitsBody.scoped [("value", .result), ("capacity", .number)] = true ∧
  comparisonBody.scoped [("text", .source), ("state", .state)] = true ∧
  expressionBody.scoped [("text", .source), ("position", .number), ("names", .names)] = true ∧
  targetBody.scoped [("text", .source), ("state", .state), ("same_target", .truth)] = true ∧
  dynamicBody.scoped [("text", .source), ("state", .state)] = true ∧
  assignmentBody.scoped [("text", .source), ("state", .state)] = true ∧
  outputBody.scoped [("text", .source), ("state", .state)] = true ∧
  capacityBody.scoped [("text", .source), ("state", .state)] = true ∧
  stepBody.scoped [("text", .source), ("form", .form), ("token", .token), ("state", .state)] = true ∧
  suffixBody.scoped [("text", .source), ("form", .form), ("next_token", .number), ("state", .state)] = true ∧
  formBody.scoped [("source", .source), ("form", .form)] = true ∧
  memberBody.scoped [("source", .source)] = true ∧
  argumentsBody.scoped [("source", .source)] = true ∧
  assignmentSelectorBody.scoped [("source", .source)] = true

theorem checked_scopes : WellScopedTrees := by decide +kernel

/-- Active entries of the native fixed array. Unused cells are irrelevant:
lookup reads only 1..Count and extension writes exactly Count+1. -/
structure ArrayNames where
  count : Nat
  items : Nat → BindingInfo

def ArrayNames.active (names : ArrayNames) : BindingEnvironment :=
  List.ofFn (fun i : Fin names.count => names.items (i.val + 1))

def ArrayNames.extend (names : ArrayNames) (info : BindingInfo) : ArrayNames :=
  ⟨names.count + 1, fun i => if i = names.count + 1 then info else names.items i⟩

theorem ArrayNames.active_length (names : ArrayNames) : names.active.length = names.count := by
  simp [active]

theorem ArrayNames.active_get (names : ArrayNames) (index : Nat)
    (first : 0 < index) (last : index ≤ names.count) :
    names.active.get index = some (names.items index) := by
  have positive : index ≠ 0 := by omega
  have bounded : index - 1 < names.count := by omega
  simp [Bindings.BindingEnvironment.get, positive, active, bounded,
    Nat.sub_add_cancel first]

theorem ArrayNames.extend_active (names : ArrayNames) (info : BindingInfo) :
    (names.extend info).active = names.active ++ [info] := by
  simp only [active, extend]
  rw [List.ofFn_succ_last]
  congr 1
  · apply congrArg List.ofFn
    funext i
    have different : i.val ≠ names.count := Nat.ne_of_lt i.isLt
    simp [different]
  · simp [Fin.val_last]

end Silver.Compose.Expressions
