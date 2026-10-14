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
  | number | truth | source | token | operation | comparison | binding | names | context | result | literal | length | compared | condition | summary | bound | facts | arrow (domain codomain : Ty)
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
  | .context => Context
  | .result => Compose.ExpressionResult
  | .literal => IntegerLiteral.Result
  | .length => LengthResult
  | .compared => ComparisonResult
  | .condition => ConditionResult
  | .summary => Bindings.Summary
  | .bound => Bindings.Bound
  | .facts => PathFacts.Context
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
  | .context => ⟨[], 0, 0⟩
  | .result => Compose.invalidExpression
  | .literal => IntegerLiteral.invalid
  | .length => ⟨0, .fixed 0⟩
  | .compared => ⟨0, .eq⟩
  | .condition => invalidCondition
  | .summary => ⟨0, 0⟩
  | .bound => .fixed 0
  | .facts => PathFacts.Context.empty
  | .arrow _ b => fun _ => b.default

inductive Function
  | callAfter | take | skip | nameAfter | lookup | integer | expression | summary | bound | bindingSummary | comparison | length | primary | relation | condition | model | chainToken | chainAfter | tail | assumeValid | assumeInvalid | refineBounds | fits | refineEqual | join
  deriving DecidableEq, Repr

def Function.name : Function → List String
  | .callAfter => ["call_after"]
  | .take => ["take_token"]
  | .skip => ["skip_at"]
  | .nameAfter => ["name_after"]
  | .lookup => ["lookup_name"]
  | .integer => ["silver_integer_literals", ".", "read_integer"]
  | .expression => ["expression_at"]
  | .summary => ["summary_of"]
  | .bound => ["bound_of"]
  | .bindingSummary => ["binding_summary"]
  | .comparison => ["scalar_comparison_at"]
  | .length => ["length_at"]
  | .primary => ["read_primary"]
  | .relation => ["read_relation"]
  | .condition => ["read_condition"]
  | .model => ["condition_model"]
  | .chainToken => ["chain_token"]
  | .chainAfter => ["chain_after"]
  | .tail => ["condition_tail"]
  | .assumeValid => ["paths", ".", "assume_valid"]
  | .assumeInvalid => ["paths", ".", "assume_invalid"]
  | .refineBounds => ["paths", ".", "refine_bounds"]
  | .fits => ["paths", ".", "fits"]
  | .refineEqual => ["paths", ".", "refine_equal"]
  | .join => ["paths", ".", "join"]

@[reducible] def Function.type : Function → Ty
  | .callAfter => .arrow .source (.arrow .names (.arrow .number (.arrow .operation .number)))
  | .take => .arrow .source (.arrow .number (.arrow .token (.number)))
  | .skip => .arrow .source (.arrow .number (.number))
  | .nameAfter => .arrow .source (.arrow .number (.number))
  | .lookup => .arrow .source (.arrow .names (.arrow .number (.arrow .number (.number))))
  | .integer => .arrow .source (.arrow .number (.literal))
  | .expression => .arrow .source (.arrow .number (.arrow .names (.result)))
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
  | .assumeValid => .arrow .facts (.facts)
  | .assumeInvalid => .arrow .facts (.facts)
  | .refineBounds => .arrow .facts (.arrow .comparison (.arrow .bound (.arrow .bound (.arrow .truth (.facts)))))
  | .fits => .arrow .facts (.arrow .summary (.truth))
  | .refineEqual => .arrow .facts (.arrow .summary (.arrow .summary (.facts)))
  | .join => .arrow .facts (.arrow .facts (.facts))

structure Calls where
  callAfter : Source → Compose.BindingEnvironment → Nat → Names.Operation → Nat
  take : Source → Nat → Token → Nat
  skip : Source → Nat → Nat
  nameAfter : Source → Nat → Nat
  lookup : Source → Compose.BindingEnvironment → Nat → Nat → Nat
  integer : Source → Nat → IntegerLiteral.Result
  expression : Source → Nat → Compose.BindingEnvironment → Compose.ExpressionResult
  summary : Compose.ExpressionResult → Bindings.Summary
  bound : Bindings.BindingInfo → Bindings.Bound
  bindingSummary : Bindings.BindingInfo → Bindings.Summary
  comparison : Source → Nat → ComparisonResult
  length : Source → Context → Nat → Bool → LengthResult
  primary : Source → Context → Nat → PathFacts.Context → ConditionResult
  relation : Source → Context → Nat → PathFacts.Context → ConditionResult
  condition : Source → Context → Nat → PathFacts.Context → ConditionResult
  model : Source → Context → Nat → PathFacts.Context → ConditionResult
  chainToken : Source → Nat → Token
  chainAfter : Source → Nat → Token → Nat
  tail : Source → Context → ConditionResult → Token → Bool → ConditionResult
  assumeValid : PathFacts.Context → PathFacts.Context
  assumeInvalid : PathFacts.Context → PathFacts.Context
  refineBounds : PathFacts.Context → Comparison → Bindings.Bound → Bindings.Bound → Bool → PathFacts.Context
  fits : PathFacts.Context → Bindings.Summary → Bool
  refineEqual : PathFacts.Context → Bindings.Summary → Bindings.Summary → PathFacts.Context
  join : PathFacts.Context → PathFacts.Context → PathFacts.Context

def Calls.get (calls : Calls) : (f : Function) → f.type.meaning
  | .callAfter => calls.callAfter
  | .take => calls.take
  | .skip => calls.skip
  | .nameAfter => calls.nameAfter
  | .lookup => calls.lookup
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
  | dynamicFirst : Field .context .number
  | bindingLength : Field .binding .number
  | bindingDynamic : Field .binding .truth
  | resultAfter : Field .result .number
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
  | .dynamicFirst => "dynamic_first"
  | .bindingLength => "static_length"
  | .bindingDynamic => "dynamic"
  | .resultAfter => "after"
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
  | .dynamicFirst, value => value.dynamicFirst
  | .bindingLength, value => value.staticLength
  | .bindingDynamic, value => value.dynamic
  | .resultAfter, value => value.after
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
  | ite : Expr .truth → Expr a → Expr a → Expr a
  | elsif : Expr .truth → Expr a → Expr a → Expr a
  | local (name : String) (typeName : List String) : Expr a → Expr b → Expr b
  | locals : Expr a → Expr a
  | summary : Expr .number → Expr .number → Expr .summary
  | bound : Expr .number → Expr .truth → Expr .bound
  | compared : Expr .number → Expr .comparison → Expr .compared
  | length : Expr .number → Expr .bound → Expr .length
  | condition : Expr .number → Expr .facts → Expr .facts → Expr .condition
  | updateAfter : Expr .condition → Expr .number → Expr .condition
  | invalid : Expr .condition

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
  | .ite guard yes no => ["if"] ++ guard.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .elsif guard yes no => ["elsif"] ++ guard.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .local name typeName value rest => [name, ":", "constant"] ++ typeName ++ [":="] ++ value.render ++ [";"] ++
      (match rest with | .local _ _ _ _ => rest.render | _ => ["begin"] ++ rest.render)
  | .locals body => ["declare"] ++ body.render
  | .summary left right | .bound left right | .compared left right | .length left right =>
      aggregate [left.render, right.render]
  | .condition after yes no => aggregate [after.render, yes.render, no.render]
  | .updateAfter value after => ["("] ++ value.render ++ ["with", "delta", "after", "=>"] ++ after.render ++ [")"]
  | .invalid => ["invalid_condition"]

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
  | .group value => value.eval calls locals
  | .ite guard yes no | .elsif guard yes no =>
      if guard.eval calls locals then yes.eval calls locals else no.eval calls locals
  | .local name _ value rest => rest.eval calls (locals.set _ name (value.eval calls locals))
  | .locals value => value.eval calls locals
  | .summary left right => ⟨left.eval calls locals, right.eval calls locals⟩
  | .bound value dynamic => if dynamic.eval calls locals then .argument else .fixed (value.eval calls locals)
  | .compared after operator => ⟨after.eval calls locals, operator.eval calls locals⟩
  | .length after value => ⟨after.eval calls locals, value.eval calls locals⟩
  | .condition after yes no => ⟨after.eval calls locals, yes.eval calls locals, no.eval calls locals⟩
  | .updateAfter value after => {value.eval calls locals with after := after.eval calls locals}
  | .invalid => invalidCondition

namespace Expr
def callOperation (text : Expr .source) (names : Expr .names) (position : Expr .number) (operation : Expr .operation) : Expr .number :=
  .app (.app (.app (.app (.function .callAfter) text) names) position) operation

def callTake (x0 : Expr .source) (x1 : Expr .number) (x2 : Expr .token) : Expr .number :=
  .app (.app (.app (.function .take) x0) x1) x2

def callSkip (x0 : Expr .source) (x1 : Expr .number) : Expr .number :=
  .app (.app (.function .skip) x0) x1

def callNameAfter (x0 : Expr .source) (x1 : Expr .number) : Expr .number :=
  .app (.app (.function .nameAfter) x0) x1

def callLookup (x0 : Expr .source) (x1 : Expr .names) (x2 : Expr .number) (x3 : Expr .number) : Expr .number :=
  .app (.app (.app (.app (.function .lookup) x0) x1) x2) x3

def callInteger (x0 : Expr .source) (x1 : Expr .number) : Expr .literal :=
  .app (.app (.function .integer) x0) x1

def callExpression (x0 : Expr .source) (x1 : Expr .number) (x2 : Expr .names) : Expr .result :=
  .app (.app (.app (.function .expression) x0) x1) x2

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

def callAssumeValid (x0 : Expr .facts) : Expr .facts :=
  .app (.function .assumeValid) x0

def callAssumeInvalid (x0 : Expr .facts) : Expr .facts :=
  .app (.function .assumeInvalid) x0

def callRefineBounds (x0 : Expr .facts) (x1 : Expr .comparison) (x2 : Expr .bound) (x3 : Expr .bound) (x4 : Expr .truth) : Expr .facts :=
  .app (.app (.app (.app (.app (.function .refineBounds) x0) x1) x2) x3) x4

def callFits (x0 : Expr .facts) (x1 : Expr .summary) : Expr .truth :=
  .app (.app (.function .fits) x0) x1

def callRefineEqual (x0 : Expr .facts) (x1 : Expr .summary) (x2 : Expr .summary) : Expr .facts :=
  .app (.app (.app (.function .refineEqual) x0) x1) x2

def callJoin (x0 : Expr .facts) (x1 : Expr .facts) : Expr .facts :=
  .app (.app (.function .join) x0) x1

end Expr

end Silver.Predicate.Native
