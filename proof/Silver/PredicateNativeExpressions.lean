module

public import Silver.PredicateNativeState
public import Silver.IntegerLiteral

@[expose] public section

/-! Typed source trees for the native scalar predicate scanner. Path contexts
and bounds use the separately proved native-library projection; binding arrays
use their checked active-slice interpretation. All function calls remain
arbitrary until their source equations or inherited contracts are applied. -/
namespace Silver.Predicate.Native

inductive Ty
  | number | truth | source | token | operation | comparison | binding | names | scalarNames | scalarResult | context | result | literal | length | compared | condition | summary | bound | facts | path | arrow (domain codomain : Ty)
  deriving DecidableEq, Repr

@[reducible] def Ty.meaning : Ty → Type
  | .number => Nat
  | .truth => Bool
  | .source => Source
  | .operation => Names.Operation
  | .token => Token
  | .comparison => Comparison
  | .binding => Bindings.BindingInfo
  | .names => Compose.BindingEnvironment
  | .scalarNames => ScalarExpression.Environment
  | .scalarResult => ScalarExpression.Result
  | .context => Context
  | .result => Compose.ExpressionResult
  | .literal => IntegerLiteral.Result
  | .length => LengthResult
  | .compared => ComparisonResult
  | .condition => ConditionResult
  | .summary => Compose.LengthSummary
  | .bound => Bindings.Bound
  | .facts => ActiveFlow
  | .path => PathFacts.Context
  | .arrow a b => a.meaning → b.meaning

def Ty.default : (ty : Ty) → ty.meaning
  | .number => 0
  | .truth => false
  | .source => []
  | .operation => .validity
  | .token => .endKeyword
  | .comparison => .eq
  | .binding => {}
  | .names => []
  | .scalarNames => []
  | .scalarResult => ScalarExpression.invalid
  | .context => ⟨[], 0, 0, [], 0⟩
  | .result => Compose.invalidExpression
  | .literal => IntegerLiteral.invalid
  | .length => ⟨0, .fixed 0⟩
  | .compared => ⟨0, .eq⟩
  | .condition => invalidCondition ⟨PathFacts.Context.empty, []⟩
  | .summary => {}
  | .bound => .fixed 0
  | .facts => ⟨PathFacts.Context.empty, []⟩
  | .path => PathFacts.Context.empty
  | .arrow _ b => fun _ => b.default

inductive Function
  | callAfter | take | skip | nameAfter | lookup | scalarLookup | scalarRead | scalarInFlow | stringInFlow | scalarCondition | invalidCondition | integer | expression | summary | bound | bindingSummary | comparison | length | primary | relation | condition | model | chainToken | chainAfter | tail | assumeValid | assumeInvalid | refineBounds | fits | refineEqual | join
  deriving DecidableEq, Repr

def Function.name : Function → List String
  | .callAfter => ["call_after"]
  | .take => ["take_token"]
  | .skip => ["skip_at"]
  | .nameAfter => ["name_after"]
  | .lookup => ["lookup_name"]
  | .scalarLookup => ["scalar_expressions", ".", "lookup"]
  | .scalarRead => ["scalar_expressions", ".", "read_expression"]
  | .scalarInFlow => ["read_scalar_in_flow"]
  | .stringInFlow => ["read_string_in_flow"]
  | .scalarCondition => ["scalar_condition"]
  | .invalidCondition => ["invalid_condition"]
  | .integer => ["silver_integer_literals", ".", "read_integer"]
  | .expression => ["expression_at"]
  | .summary => ["summary_of"]
  | .bound => ["bound_of"]
  | .bindingSummary => ["binding_summary"]
  | .comparison => ["scalar_comparison_at"]
  | .length => ["length_at"]
  | .primary => ["primary_model"]
  | .relation => ["relation_model"]
  | .condition => ["read_condition_into"]
  | .model => ["condition_model"]
  | .chainToken => ["chain_token"]
  | .chainAfter => ["chain_after"]
  | .tail => ["condition_tail"]
  | .assumeValid => ["paths", ".", "assume_valid"]
  | .assumeInvalid => ["paths", ".", "assume_invalid"]
  | .refineBounds => ["paths", ".", "refine_bounds"]
  | .fits => ["length_intervals", ".", "fits"]
  | .refineEqual => ["length_intervals", ".", "refine_equal"]
  | .join => ["joined"]

@[reducible] def Function.type : Function → Ty
  | .callAfter => .arrow .source (.arrow .names (.arrow .number (.arrow .operation (.arrow .scalarNames .number))))
  | .take => .arrow .source (.arrow .number (.arrow .token (.number)))
  | .skip => .arrow .source (.arrow .number (.number))
  | .nameAfter => .arrow .source (.arrow .number (.number))
  | .lookup => .arrow .source (.arrow .names (.arrow .number (.arrow .number (.number))))
  | .scalarLookup => .arrow .source (.arrow .scalarNames (.arrow .number (.arrow .number .number)))
  | .scalarRead => .arrow .source (.arrow .number (.arrow .scalarNames .scalarResult))
  | .scalarInFlow => .arrow .source (.arrow .context (.arrow .number (.arrow .facts .scalarResult)))
  | .stringInFlow => .arrow .source (.arrow .context (.arrow .number (.arrow .facts .result)))
  | .scalarCondition => .arrow .source (.arrow .context (.arrow .number (.arrow .number (.arrow .facts (.arrow .scalarResult (.arrow .scalarResult (.arrow .comparison .condition)))))))
  | .invalidCondition => .arrow .facts .condition
  | .integer => .arrow .source (.arrow .number (.literal))
  | .expression => .arrow .source (.arrow .number (.arrow .names (.arrow .scalarNames .result)))
  | .summary => .arrow .result (.summary)
  | .bound => .arrow .binding (.bound)
  | .bindingSummary => .arrow .binding (.summary)
  | .comparison => .arrow .source (.arrow .number (.compared))
  | .length => .arrow .source (.arrow .context (.arrow .number (.arrow .truth (.length))))
  | .primary => .arrow .source (.arrow .context (.arrow .number (.arrow .facts (.condition))))
  | .relation => .arrow .source (.arrow .context (.arrow .number (.arrow .facts (.condition))))
  | .condition => .arrow .source (.arrow .context (.arrow .number (.arrow .facts (.condition))))
  | .model => .arrow .source (.arrow .context (.arrow .number (.arrow .facts (.condition))))
  | .chainToken => .arrow .source (.arrow .number (.token))
  | .chainAfter => .arrow .source (.arrow .number (.arrow .token (.number)))
  | .tail => .arrow .source (.arrow .context (.arrow .condition (.arrow .token (.arrow .truth (.condition)))))
  | .assumeValid => .arrow .path .path
  | .assumeInvalid => .arrow .path .path
  | .refineBounds => .arrow .path (.arrow .comparison (.arrow .bound (.arrow .bound (.arrow .truth .path))))
  | .fits => .arrow .path (.arrow .summary .truth)
  | .refineEqual => .arrow .path (.arrow .summary (.arrow .summary .path))
  | .join => .arrow .facts (.arrow .facts (.facts))

structure Calls where
  callAfter : Source → Compose.BindingEnvironment → Nat → Names.Operation → ScalarExpression.Environment → Nat
  take : Source → Nat → Token → Nat
  skip : Source → Nat → Nat
  nameAfter : Source → Nat → Nat
  lookup : Source → Compose.BindingEnvironment → Nat → Nat → Nat
  scalarLookup : Source → ScalarExpression.Environment → Nat → Nat → Nat
  scalarRead : Source → Nat → ScalarExpression.Environment → ScalarExpression.Result
  scalarInFlow : Source → Context → Nat → ActiveFlow → ScalarExpression.Result
  stringInFlow : Source → Context → Nat → ActiveFlow → Compose.ExpressionResult
  scalarCondition : Source → Context → Nat → Nat → ActiveFlow → ScalarExpression.Result → ScalarExpression.Result → Comparison → ConditionResult
  invalidCondition : ActiveFlow → ConditionResult
  integer : Source → Nat → IntegerLiteral.Result
  expression : Source → Nat → Compose.BindingEnvironment → ScalarExpression.Environment → Compose.ExpressionResult
  summary : Compose.ExpressionResult → Compose.LengthSummary
  bound : Bindings.BindingInfo → Bindings.Bound
  bindingSummary : Bindings.BindingInfo → Compose.LengthSummary
  comparison : Source → Nat → ComparisonResult
  length : Source → Context → Nat → Bool → LengthResult
  primary : Source → Context → Nat → ActiveFlow → ConditionResult
  relation : Source → Context → Nat → ActiveFlow → ConditionResult
  condition : Source → Context → Nat → ActiveFlow → ConditionResult
  model : Source → Context → Nat → ActiveFlow → ConditionResult
  chainToken : Source → Nat → Token
  chainAfter : Source → Nat → Token → Nat
  tail : Source → Context → ConditionResult → Token → Bool → ConditionResult
  assumeValid : PathFacts.Context → PathFacts.Context
  assumeInvalid : PathFacts.Context → PathFacts.Context
  refineBounds : PathFacts.Context → Comparison → Bindings.Bound → Bindings.Bound → Bool → PathFacts.Context
  fits : PathFacts.Context → Compose.LengthSummary → Bool
  refineEqual : PathFacts.Context → Compose.LengthSummary → Compose.LengthSummary → PathFacts.Context
  join : ActiveFlow → ActiveFlow → ActiveFlow

def Calls.get (calls : Calls) : (f : Function) → f.type.meaning
  | .callAfter => calls.callAfter
  | .take => calls.take
  | .skip => calls.skip
  | .nameAfter => calls.nameAfter
  | .lookup => calls.lookup
  | .scalarLookup => calls.scalarLookup
  | .scalarRead => calls.scalarRead
  | .scalarInFlow => calls.scalarInFlow
  | .stringInFlow => calls.stringInFlow
  | .scalarCondition => calls.scalarCondition
  | .invalidCondition => calls.invalidCondition
  | .integer => calls.integer
  | .expression => calls.expression
  | .summary => calls.summary
  | .bound => calls.bound
  | .bindingSummary => calls.bindingSummary
  | .comparison => calls.comparison
  | .length => calls.length
  | .primary => calls.primary
  | .relation => calls.relation
  | .condition => calls.condition
  | .model => calls.model
  | .chainToken => calls.chainToken
  | .chainAfter => calls.chainAfter
  | .tail => calls.tail
  | .assumeValid => calls.assumeValid
  | .assumeInvalid => calls.assumeInvalid
  | .refineBounds => calls.refineBounds
  | .fits => calls.fits
  | .refineEqual => calls.refineEqual
  | .join => calls.join

inductive Field : Ty → Ty → Type
  | contextNames : Field .context .names
  | contextScalarNames : Field .context .scalarNames
  | contextDeclarations : Field .context .number
  | flowPath : Field .facts .path
  | flowCount : Field .facts .number
  | conditionCount : Field .condition .number
  | scalarAfter : Field .scalarResult .number
  | dynamicFirst : Field .context .number
  | bindingLength : Field .binding .number
  | bindingDynamic : Field .binding .truth
  | resultAfter : Field .result .number
  | resultMinimum : Field .result .number
  | resultEmpty : Field .result .truth
  | resultLength : Field .result .number
  | resultDynamic : Field .result .number
  | resultNamed : Field .result .truth
  | literalAfter : Field .literal .number
  | literalValue : Field .literal .number
  | lengthAfter : Field .length .number
  | lengthValue : Field .length .bound
  | comparedAfter : Field .compared .number
  | comparedOperator : Field .compared .comparison
  | conditionAfter : Field .condition .number
  | whenTrue : Field .condition .facts
  | whenFalse : Field .condition .facts

def Field.name : Field a b → String
  | .contextNames => "names"
  | .contextScalarNames => "scalar_names"
  | .contextDeclarations => "declaration_count"
  | .flowPath => "path"
  | .flowCount | .conditionCount => "count"
  | .scalarAfter => "after"
  | .dynamicFirst => "dynamic_first"
  | .bindingLength => "static_length"
  | .bindingDynamic => "dynamic"
  | .resultAfter => "after"
  | .resultMinimum => "minimum_length"
  | .resultEmpty => "empty_value"
  | .resultLength => "static_length"
  | .resultDynamic => "dynamic_count"
  | .resultNamed => "named_seen"
  | .literalAfter => "after"
  | .literalValue => "value"
  | .lengthAfter => "after"
  | .lengthValue => "value"
  | .comparedAfter => "after"
  | .comparedOperator => "operator"
  | .conditionAfter => "after"
  | .whenTrue => "when_true"
  | .whenFalse => "when_false"

def Field.get : Field a b → a.meaning → b.meaning
  | .contextNames, value => value.names
  | .contextScalarNames, value => value.scalarNames
  | .contextDeclarations, value => value.declarationCount
  | .flowPath, value => value.path
  | .flowCount, value => value.count
  | .conditionCount, value => value.count
  | .scalarAfter, value => value.after
  | .dynamicFirst, value => value.dynamicFirst
  | .bindingLength, value => value.staticLength
  | .bindingDynamic, value => value.dynamic
  | .resultAfter, value => value.after
  | .resultMinimum, value => value.minimumLength
  | .resultEmpty, value => value.emptyValue
  | .resultLength, value => value.staticLength
  | .resultDynamic, value => value.dynamicCount
  | .resultNamed, value => value.namedSeen
  | .literalAfter, value => value.after
  | .literalValue, value => value.value
  | .lengthAfter, value => value.after
  | .lengthValue, value => value.value
  | .comparedAfter, value => value.after
  | .comparedOperator, value => value.operator
  | .conditionAfter, value => value.after
  | .whenTrue, value => value.whenTrue
  | .whenFalse, value => value.whenFalse

inductive Expr : Ty → Type
  | operation (value : Names.Operation) : Expr .operation
  | number (value : Nat) : Expr .number
  | truth (value : Bool) : Expr .truth
  | token (value : Token) : Expr .token
  | comparison (value : Comparison) : Expr .comparison
  | variable (name : String) : Expr ty
  | function (symbol : Function) : Expr symbol.type
  | app : Expr (.arrow a b) → Expr a → Expr b
  | field : Field a b → Expr a → Expr b
  | bindingAt : Expr .names → Expr .number → Expr .binding
  | eq : Expr .number → Expr .number → Expr .truth
  | ne : Expr .number → Expr .number → Expr .truth
  | le : Expr .number → Expr .number → Expr .truth
  | tokenEq : Expr .token → Expr .token → Expr .truth
  | tokenNe : Expr .token → Expr .token → Expr .truth
  | comparisonEq : Expr .comparison → Expr .comparison → Expr .truth
  | notEquality : Expr .comparison → Expr .truth
  | notChain : Expr .token → Expr .truth
  | andThen : Expr .truth → Expr .truth → Expr .truth
  | orElse : Expr .truth → Expr .truth → Expr .truth
  | not : Expr .truth → Expr .truth
  | group : Expr a → Expr a
  | old : Expr a → Expr a
  | ite : Expr .truth → Expr a → Expr a → Expr a
  | elsif : Expr .truth → Expr a → Expr a → Expr a
  | local (name : String) (typeName : List String) : Expr a → Expr b → Expr b
  | localCondition (name : String) : Expr .number → Expr .condition → Expr b → Expr b
  | locals : Expr a → Expr a
  | summary : Expr .number → Expr .number → Expr .number → Expr .truth → Expr .summary
  | bound : Expr .number → Expr .truth → Expr .bound
  | compared : Expr .number → Expr .comparison → Expr .compared
  | length : Expr .number → Expr .bound → Expr .length
  | condition (named : Bool) : Expr .number → Expr .number → Expr .facts → Expr .facts → Expr .condition
  | updatePath : Expr .facts → Expr .path → Expr .facts
  | updateAfter : Expr .condition → Expr .number → Expr .condition
  | invalid : Expr .facts → Expr .condition

abbrev Locals := (ty : Ty) → String → ty.meaning

def Locals.set (locals : Locals) (ty : Ty) (name : String) (value : ty.meaning) : Locals :=
  fun requested key => if same : ty = requested then
    if key = name then same ▸ value else locals requested key
  else locals requested key

def comparisonName : Comparison → String
  | .eq => "equal" | .ne => "unequal" | .lt => "less" | .le => "less_equal"
  | .gt => "greater" | .ge => "greater_equal"

def aggregate (items : List (List String)) : List String :=
  ["("] ++ List.flatten (List.intersperse [","] items) ++ [")"]

def Expr.render : Expr ty → List String
  | .operation value => (Compose.Expressions.Expr.operation value).render
  | .number value => [toString value]
  | .truth value => [if value then "true" else "false"]
  | .token value => [value.name]
  | .comparison value => ["paths", ".", comparisonName value]
  | .variable name => [name]
  | .function symbol => symbol.name
  | .app fn argument => match fn with
    | .app _ _ => fn.render.dropLast ++ [","] ++ argument.render ++ [")"]
    | _ => fn.render ++ ["("] ++ argument.render ++ [")"]
  | .field projection value => value.render ++ [".", projection.name]
  | .bindingAt names index => names.render ++ [".", "items", "("] ++ index.render ++ [")"]
  | .eq left right | .tokenEq left right | .comparisonEq left right => left.render ++ ["="] ++ right.render
  | .ne left right | .tokenNe left right => left.render ++ ["/="] ++ right.render
  | .le left right => left.render ++ ["<="] ++ right.render
  | .notEquality value => value.render ++ ["not", "in", "paths", ".", "equal", "|", "paths", ".", "unequal"]
  | .notChain value => value.render ++ ["not", "in", "and_keyword", "|", "or_keyword"]
  | .andThen left right => left.render ++ ["and", "then"] ++ right.render
  | .orElse left right => left.render ++ ["or", "else"] ++ right.render
  | .not value => ["not"] ++ value.render
  | .group value => ["("] ++ value.render ++ [")"]
  | .old value => value.render ++ ["'", "old"]
  | .ite guard yes no => ["if"] ++ guard.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .elsif guard yes no => ["elsif"] ++ guard.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .local name typeName value rest => [name, ":", "constant"] ++ typeName ++ [":="] ++ value.render ++ [";"] ++
      (match rest with | .local _ _ _ _ | .localCondition _ _ _ _ => rest.render | _ => ["begin"] ++ rest.render)
  | .localCondition name count value rest =>
      [name, ":", "constant", "condition_result", "("] ++ count.render ++ [")", ":="] ++ value.render ++ [";"] ++
        (match rest with | .local _ _ _ _ | .localCondition _ _ _ _ => rest.render | _ => ["begin"] ++ rest.render)
  | .locals body => ["declare"] ++ body.render
  | .summary low high count empty => aggregate [low.render, high.render, count.render, empty.render]
  | .bound left right | .compared left right | .length left right =>
      aggregate [left.render, right.render]
  | .condition named count after yes no =>
      if named then aggregate [["count", "=>"] ++ count.render, ["after", "=>"] ++ after.render,
        ["when_true", "=>"] ++ yes.render, ["when_false", "=>"] ++ no.render]
      else aggregate [count.render, after.render, yes.render, no.render]
  | .updatePath value path => ["("] ++ value.render ++ ["with", "delta", "path", "=>"] ++ path.render ++ [")"]
  | .updateAfter value after => ["("] ++ value.render ++ ["with", "delta", "after", "=>"] ++ after.render ++ [")"]
  | .invalid facts => ["invalid_condition", "("] ++ facts.render ++ [")"]

def Expr.eval (calls : Calls) (locals : Locals) : Expr ty → ty.meaning
  | .operation value => value
  | .number value => value
  | .truth value => value
  | .token value => value
  | .comparison value => value
  | .variable name => locals _ name
  | .function symbol => calls.get symbol
  | .app fn argument => fn.eval calls locals (argument.eval calls locals)
  | .field projection value => projection.get (value.eval calls locals)
  | .bindingAt names index => ((names.eval calls locals).get (index.eval calls locals)).getD {}
  | .eq left right => decide (left.eval calls locals = right.eval calls locals)
  | .ne left right => decide (left.eval calls locals ≠ right.eval calls locals)
  | .le left right => decide (left.eval calls locals ≤ right.eval calls locals)
  | .tokenEq left right => decide (left.eval calls locals = right.eval calls locals)
  | .tokenNe left right => decide (left.eval calls locals ≠ right.eval calls locals)
  | .comparisonEq left right => decide (left.eval calls locals = right.eval calls locals)
  | .notEquality value => decide (value.eval calls locals ≠ .eq ∧ value.eval calls locals ≠ .ne)
  | .notChain value => !((value.eval calls locals).isChain)
  | .andThen left right => left.eval calls locals && right.eval calls locals
  | .orElse left right => left.eval calls locals || right.eval calls locals
  | .not value => !(value.eval calls locals)
  | .group value | .old value => value.eval calls locals
  | .ite guard yes no | .elsif guard yes no =>
      if guard.eval calls locals then yes.eval calls locals else no.eval calls locals
  | .local name _ value rest => rest.eval calls (locals.set _ name (value.eval calls locals))
  | .localCondition name _ value rest => rest.eval calls (locals.set .condition name (value.eval calls locals))
  | .locals value => value.eval calls locals
  | .summary low high count empty => ⟨low.eval calls locals, high.eval calls locals, count.eval calls locals, empty.eval calls locals⟩
  | .bound value dynamic => if dynamic.eval calls locals then .argument else .fixed (value.eval calls locals)
  | .compared after operator => ⟨after.eval calls locals, operator.eval calls locals⟩
  | .length after value => ⟨after.eval calls locals, value.eval calls locals⟩
  | .condition _ _ after yes no => ⟨after.eval calls locals, yes.eval calls locals, no.eval calls locals⟩
  | .updatePath value path => {value.eval calls locals with path := path.eval calls locals}
  | .updateAfter value after => {value.eval calls locals with after := after.eval calls locals}
  | .invalid facts => calls.invalidCondition (facts.eval calls locals)

namespace Expr
def callOperation (text : Expr .source) (names : Expr .names) (position : Expr .number) (operation : Expr .operation) (scalarNames : Expr .scalarNames) : Expr .number :=
  .app (.app (.app (.app (.app (.function .callAfter) text) names) position) operation) scalarNames

def callTake (x0 : Expr .source) (x1 : Expr .number) (x2 : Expr .token) : Expr .number :=
  .app (.app (.app (.function .take) x0) x1) x2

def callSkip (x0 : Expr .source) (x1 : Expr .number) : Expr .number :=
  .app (.app (.function .skip) x0) x1

def callNameAfter (x0 : Expr .source) (x1 : Expr .number) : Expr .number :=
  .app (.app (.function .nameAfter) x0) x1

def callLookup (x0 : Expr .source) (x1 : Expr .names) (x2 : Expr .number) (x3 : Expr .number) : Expr .number :=
  .app (.app (.app (.app (.function .lookup) x0) x1) x2) x3

def callScalarLookup (text : Expr .source) (names : Expr .scalarNames) (first after : Expr .number) : Expr .number :=
  .app (.app (.app (.app (.function .scalarLookup) text) names) first) after

def callScalarRead (text : Expr .source) (position : Expr .number) (names : Expr .scalarNames) : Expr .scalarResult :=
  .app (.app (.app (.function .scalarRead) text) position) names

def callScalarInFlow (text : Expr .source) (context : Expr .context) (position : Expr .number) (facts : Expr .facts) : Expr .scalarResult :=
  .app (.app (.app (.app (.function .scalarInFlow) text) context) position) facts

def callStringInFlow (text : Expr .source) (context : Expr .context) (position : Expr .number) (facts : Expr .facts) : Expr .result :=
  .app (.app (.app (.app (.function .stringInFlow) text) context) position) facts

def callScalarCondition (text : Expr .source) (context : Expr .context) (position rightPosition : Expr .number)
    (facts : Expr .facts) (left right : Expr .scalarResult) (operator : Expr .comparison) : Expr .condition :=
  .app (.app (.app (.app (.app (.app (.app (.app (.function .scalarCondition) text) context) position) rightPosition) facts) left) right) operator

def callInteger (x0 : Expr .source) (x1 : Expr .number) : Expr .literal :=
  .app (.app (.function .integer) x0) x1

def callExpression (x0 : Expr .source) (x1 : Expr .number) (x2 : Expr .names) (scalarNames : Expr .scalarNames) : Expr .result :=
  .app (.app (.app (.app (.function .expression) x0) x1) x2) scalarNames

def callSummary (x0 : Expr .result) : Expr .summary :=
  .app (.function .summary) x0

def callBound (x0 : Expr .binding) : Expr .bound :=
  .app (.function .bound) x0

def callBindingSummary (x0 : Expr .binding) : Expr .summary :=
  .app (.function .bindingSummary) x0

def callComparison (x0 : Expr .source) (x1 : Expr .number) : Expr .compared :=
  .app (.app (.function .comparison) x0) x1

def callLength (x0 : Expr .source) (x1 : Expr .context) (x2 : Expr .number) (x3 : Expr .truth) : Expr .length :=
  .app (.app (.app (.app (.function .length) x0) x1) x2) x3

def callPrimary (x0 : Expr .source) (x1 : Expr .context) (x2 : Expr .number) (x3 : Expr .facts) : Expr .condition :=
  .app (.app (.app (.app (.function .primary) x0) x1) x2) x3

def callRelation (x0 : Expr .source) (x1 : Expr .context) (x2 : Expr .number) (x3 : Expr .facts) : Expr .condition :=
  .app (.app (.app (.app (.function .relation) x0) x1) x2) x3

def callCondition (x0 : Expr .source) (x1 : Expr .context) (x2 : Expr .number) (x3 : Expr .facts) : Expr .condition :=
  .app (.app (.app (.app (.function .condition) x0) x1) x2) x3

def callModel (x0 : Expr .source) (x1 : Expr .context) (x2 : Expr .number) (x3 : Expr .facts) : Expr .condition :=
  .app (.app (.app (.app (.function .model) x0) x1) x2) x3

def callChainToken (x0 : Expr .source) (x1 : Expr .number) : Expr .token :=
  .app (.app (.function .chainToken) x0) x1

def callChainAfter (x0 : Expr .source) (x1 : Expr .number) (x2 : Expr .token) : Expr .number :=
  .app (.app (.app (.function .chainAfter) x0) x1) x2

def callTail (x0 : Expr .source) (x1 : Expr .context) (x2 : Expr .condition) (x3 : Expr .token) (x4 : Expr .truth) : Expr .condition :=
  .app (.app (.app (.app (.app (.function .tail) x0) x1) x2) x3) x4

def callAssumeValid (x0 : Expr .path) : Expr .path :=
  .app (.function .assumeValid) x0

def callAssumeInvalid (x0 : Expr .path) : Expr .path :=
  .app (.function .assumeInvalid) x0

def callRefineBounds (x0 : Expr .path) (x1 : Expr .comparison) (x2 : Expr .bound) (x3 : Expr .bound) (x4 : Expr .truth) : Expr .path :=
  .app (.app (.app (.app (.app (.function .refineBounds) x0) x1) x2) x3) x4

def callFits (x0 : Expr .path) (x1 : Expr .summary) : Expr .truth :=
  .app (.app (.function .fits) x0) x1

def callRefineEqual (x0 : Expr .path) (x1 : Expr .summary) (x2 : Expr .summary) : Expr .path :=
  .app (.app (.app (.function .refineEqual) x0) x1) x2

def callJoin (x0 : Expr .facts) (x1 : Expr .facts) : Expr .facts :=
  .app (.app (.function .join) x0) x1

end Expr

end Silver.Predicate.Native
