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
  | number | truth | word | value | source | token | chain | booleanNames | initials | operation | comparison | binding | names | scalarNames | arrays | scalarResult | context | result | literal | length | compared | condition | summary | bound | facts | path | arrow (domain codomain : Ty)
  deriving DecidableEq, Repr

@[reducible] def Ty.meaning : Ty → Type
  | .number => Nat
  | .truth => Bool
  | .value => Compose.ValueResult
  | .word => String
  | .source => Source
  | .chain => ChainKind
  | .booleanNames => BooleanBindings.Environment
  | .initials => ArrayBindings.Initials
  | .operation => Names.Operation
  | .token => Token
  | .comparison => Comparison
  | .binding => Bindings.BindingInfo
  | .names => Compose.BindingEnvironment
  | .scalarNames => ScalarExpression.Environment
  | .arrays => ArrayBindings.Metadata
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
  | .value => Compose.invalidValue
  | .word => ""
  | .source => []
  | .chain => .noChain
  | .booleanNames => []
  | .initials => []
  | .operation => .validity
  | .token => .endKeyword
  | .comparison => .eq
  | .binding => {}
  | .names => []
  | .scalarNames => []
  | .arrays => []
  | .scalarResult => ScalarExpression.invalid
  | .context => { names := [], dynamicFirst := 0, dynamicAfter := 0 }
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
  | readingNames | characterAt | characterCondition | xorFree | callAfter | equalName | nameIs | arrayLookup | booleanLookup | booleanAtom | booleanFactor | booleanRelation | take | skip | nameAfter | lookup | scalarLookup | scalarRead | scalarInFlow | stringInFlow | scalarCondition | invalidCondition | integer | expression | summary | bound | bindingSummary | comparison | length | primary | relation | condition | model | chainToken | chainAfter | tail | assumeValid | assumeInvalid | refineBounds | fits | refineEqual | join
  deriving DecidableEq, Repr

def Function.name : Function → List String
  | .readingNames => ["reading_names"]
  | .characterAt => ["character_at"]
  | .characterCondition => ["character_condition"]
  | .xorFree => ["xor_free"]
  | .callAfter => ["call_after"]
  | .equalName => ["equal_name"]
  | .nameIs => ["name_is"]
  | .arrayLookup => ["array_bindings", ".", "lookup"]
  | .booleanLookup => ["lookup_boolean"]
  | .booleanAtom => ["boolean_atom_after"]
  | .booleanFactor => ["boolean_factor_model"]
  | .booleanRelation => ["boolean_relation_model"]
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
  | .readingNames => .arrow .context (.arrow .facts .scalarNames)
  | .characterAt => .arrow .source (.arrow .number (.arrow .names (.arrow .scalarNames (.arrow .arrays (.arrow .initials (.arrow .truth .value))))))
  | .characterCondition => .arrow .source (.arrow .context (.arrow .number (.arrow .facts (.arrow .initials .condition))))
  | .xorFree => .arrow .source (.arrow .number (.arrow .number .truth))
  | .callAfter => .arrow .source (.arrow .names (.arrow .number (.arrow .operation (.arrow .scalarNames (.arrow .arrays (.arrow .truth (.arrow .booleanNames .number)))))))
  | .equalName => .arrow .source (.arrow .number (.arrow .number (.arrow .number (.arrow .number .truth))))
  | .nameIs => .arrow .source (.arrow .number (.arrow .number (.arrow .word .truth)))
  | .arrayLookup => .arrow .source (.arrow .arrays (.arrow .number (.arrow .number .number)))
  | .booleanLookup => .arrow .source (.arrow .booleanNames (.arrow .number (.arrow .number .number)))
  | .booleanAtom => .arrow .source (.arrow .context (.arrow .number .number))
  | .booleanFactor | .booleanRelation => .arrow .source (.arrow .context (.arrow .number (.arrow .facts (.arrow .initials .condition))))
  | .take => .arrow .source (.arrow .number (.arrow .token (.number)))
  | .skip => .arrow .source (.arrow .number (.number))
  | .nameAfter => .arrow .source (.arrow .number (.number))
  | .lookup => .arrow .source (.arrow .names (.arrow .number (.arrow .number (.number))))
  | .scalarLookup => .arrow .source (.arrow .scalarNames (.arrow .number (.arrow .number .number)))
  | .scalarRead => .arrow .source (.arrow .number (.arrow .scalarNames .scalarResult))
  | .scalarInFlow => .arrow .source (.arrow .context (.arrow .number (.arrow .facts (.arrow .initials .scalarResult))))
  | .stringInFlow => .arrow .source (.arrow .context (.arrow .number (.arrow .facts (.arrow .initials .result))))
  | .scalarCondition => .arrow .source (.arrow .context (.arrow .number (.arrow .number (.arrow .facts (.arrow .scalarResult (.arrow .scalarResult (.arrow .comparison .condition)))))))
  | .invalidCondition => .arrow .facts .condition
  | .integer => .arrow .source (.arrow .number (.literal))
  | .expression => .arrow .source (.arrow .number (.arrow .names (.arrow .scalarNames .result)))
  | .summary => .arrow .result (.summary)
  | .bound => .arrow .binding (.bound)
  | .bindingSummary => .arrow .binding (.summary)
  | .comparison => .arrow .source (.arrow .number (.compared))
  | .length => .arrow .source (.arrow .context (.arrow .number (.arrow .truth (.length))))
  | .primary => .arrow .source (.arrow .context (.arrow .number (.arrow .facts (.arrow .initials .condition))))
  | .relation => .arrow .source (.arrow .context (.arrow .number (.arrow .facts (.arrow .initials .condition))))
  | .condition => .arrow .source (.arrow .context (.arrow .number (.arrow .facts (.arrow .initials .condition))))
  | .model => .arrow .source (.arrow .context (.arrow .number (.arrow .facts (.arrow .initials .condition))))
  | .chainToken => .arrow .source (.arrow .number .chain)
  | .chainAfter => .arrow .source (.arrow .number (.arrow .chain .number))
  | .tail => .arrow .source (.arrow .context (.arrow .condition (.arrow .chain (.arrow .truth (.arrow .initials (.arrow .facts (.arrow .number .condition)))))))
  | .assumeValid => .arrow .path .path
  | .assumeInvalid => .arrow .path .path
  | .refineBounds => .arrow .path (.arrow .comparison (.arrow .bound (.arrow .bound (.arrow .truth .path))))
  | .fits => .arrow .path (.arrow .summary .truth)
  | .refineEqual => .arrow .path (.arrow .summary (.arrow .summary .path))
  | .join => .arrow .facts (.arrow .facts (.facts))

structure Calls where
  readingNames : Context → ActiveFlow → ScalarExpression.Environment
  characterAt : Source → Nat → Compose.BindingEnvironment → ScalarExpression.Environment → ArrayBindings.Metadata → ArrayBindings.Initials → Bool → Compose.ValueResult
  characterCondition : Source → Context → Nat → ActiveFlow → ArrayBindings.Initials → ConditionResult
  xorFree : Source → Nat → Nat → Bool
  callAfter : Source → Compose.BindingEnvironment → Nat → Names.Operation → ScalarExpression.Environment → ArrayBindings.Metadata → Bool → BooleanBindings.Environment → Nat
  equalName : Source → Nat → Nat → Nat → Nat → Bool
  nameIs : Source → Nat → Nat → String → Bool
  arrayLookup : Source → ArrayBindings.Metadata → Nat → Nat → Nat
  booleanLookup : Source → BooleanBindings.Environment → Nat → Nat → Nat
  booleanAtom : Source → Context → Nat → Nat
  booleanFactor : Source → Context → Nat → ActiveFlow → ArrayBindings.Initials → ConditionResult
  booleanRelation : Source → Context → Nat → ActiveFlow → ArrayBindings.Initials → ConditionResult
  take : Source → Nat → Token → Nat
  skip : Source → Nat → Nat
  nameAfter : Source → Nat → Nat
  lookup : Source → Compose.BindingEnvironment → Nat → Nat → Nat
  scalarLookup : Source → ScalarExpression.Environment → Nat → Nat → Nat
  scalarRead : Source → Nat → ScalarExpression.Environment → ScalarExpression.Result
  scalarInFlow : Source → Context → Nat → ActiveFlow → ArrayBindings.Initials → ScalarExpression.Result
  stringInFlow : Source → Context → Nat → ActiveFlow → ArrayBindings.Initials → Compose.ExpressionResult
  scalarCondition : Source → Context → Nat → Nat → ActiveFlow → ScalarExpression.Result → ScalarExpression.Result → Comparison → ConditionResult
  invalidCondition : ActiveFlow → ConditionResult
  integer : Source → Nat → IntegerLiteral.Result
  expression : Source → Nat → Compose.BindingEnvironment → ScalarExpression.Environment → Compose.ExpressionResult
  summary : Compose.ExpressionResult → Compose.LengthSummary
  bound : Bindings.BindingInfo → Bindings.Bound
  bindingSummary : Bindings.BindingInfo → Compose.LengthSummary
  comparison : Source → Nat → ComparisonResult
  length : Source → Context → Nat → Bool → LengthResult
  primary : Source → Context → Nat → ActiveFlow → ArrayBindings.Initials → ConditionResult
  relation : Source → Context → Nat → ActiveFlow → ArrayBindings.Initials → ConditionResult
  condition : Source → Context → Nat → ActiveFlow → ArrayBindings.Initials → ConditionResult
  model : Source → Context → Nat → ActiveFlow → ArrayBindings.Initials → ConditionResult
  chainToken : Source → Nat → ChainKind
  chainAfter : Source → Nat → ChainKind → Nat
  tail : Source → Context → ConditionResult → ChainKind → Bool → ArrayBindings.Initials → ActiveFlow → Nat → ConditionResult
  assumeValid : PathFacts.Context → PathFacts.Context
  assumeInvalid : PathFacts.Context → PathFacts.Context
  refineBounds : PathFacts.Context → Comparison → Bindings.Bound → Bindings.Bound → Bool → PathFacts.Context
  fits : PathFacts.Context → Compose.LengthSummary → Bool
  refineEqual : PathFacts.Context → Compose.LengthSummary → Compose.LengthSummary → PathFacts.Context
  join : ActiveFlow → ActiveFlow → ActiveFlow

def Calls.get (calls : Calls) : (f : Function) → f.type.meaning
  | .readingNames => calls.readingNames
  | .characterAt => calls.characterAt
  | .characterCondition => calls.characterCondition
  | .xorFree => calls.xorFree
  | .callAfter => calls.callAfter
  | .equalName => calls.equalName
  | .nameIs => calls.nameIs
  | .arrayLookup => calls.arrayLookup
  | .booleanLookup => calls.booleanLookup
  | .booleanAtom => calls.booleanAtom
  | .booleanFactor => calls.booleanFactor
  | .booleanRelation => calls.booleanRelation
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
  | valueAfter : Field .value .number
  | valueNonliteral : Field .value .truth
  | bindingCharacter : Field .binding .truth
  | contextBooleans : Field .context .booleanNames
  | contextTrueHidden : Field .context .truth
  | contextFalseHidden : Field .context .truth
  | contextElaborating : Field .context .truth
  | contextMaskFirst : Field .context .number
  | contextMaskAfter : Field .context .number
  | contextNames : Field .context .names
  | contextScalarNames : Field .context .scalarNames
  | contextArrays : Field .context .arrays
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
  | .valueAfter => "after"
  | .valueNonliteral => "nonliteral_seen"
  | .bindingCharacter => "is_character"
  | .contextBooleans => "boolean_names"
  | .contextTrueHidden => "true_hidden"
  | .contextFalseHidden => "false_hidden"
  | .contextElaborating => "elaborating"
  | .contextMaskFirst => "mask_first"
  | .contextMaskAfter => "mask_after"
  | .contextNames => "names"
  | .contextScalarNames => "scalar_names"
  | .contextArrays => "array_names"
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
  | .valueAfter, value => value.after
  | .valueNonliteral, value => value.nonliteralSeen
  | .bindingCharacter, value => value.isCharacter
  | .contextBooleans, value => value.booleanNames
  | .contextTrueHidden, value => value.trueHidden
  | .contextFalseHidden, value => value.falseHidden
  | .contextElaborating, value => value.elaborating
  | .contextMaskFirst, value => value.maskFirst
  | .contextMaskAfter, value => value.maskAfter
  | .contextNames, value => value.names
  | .contextScalarNames, value => value.scalarNames
  | .contextArrays, value => value.arrayNames
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
  | chain (value : ChainKind) : Expr .chain
  | word (value : String) : Expr .word
  | emptyPath : Expr .path
  | validityCallWord : Expr .word
  | comparison (value : Comparison) : Expr .comparison
  | variable (name : String) : Expr ty
  | function (symbol : Function) : Expr symbol.type
  | app : Expr (.arrow a b) → Expr a → Expr b
  | appNamed : Expr (.arrow a b) → String → Expr a → Expr b
  | field : Field a b → Expr a → Expr b
  | subtypeHidden : Expr .context → Expr .operation → Expr .truth
  | bindingAt : Expr .names → Expr .number → Expr .binding
  | eq : Expr .number → Expr .number → Expr .truth
  | ne : Expr .number → Expr .number → Expr .truth
  | le : Expr .number → Expr .number → Expr .truth
  | chainEq : Expr .chain → Expr .chain → Expr .truth
  | chainNe : Expr .chain → Expr .chain → Expr .truth
  | chainCase : Expr .chain → Expr a → Expr a → Expr a → Expr a → Expr a → Expr a → Expr a
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
  | .chain value => [value.name]
  | .word value => ["\"" ++ value ++ "\""]
  | .emptyPath => ["paths", ".", "empty_context"]
  | .validityCallWord => ["validity_call_word"]
  | .comparison value => ["paths", ".", comparisonName value]
  | .variable name => [name]
  | .function symbol => symbol.name
  | .app fn argument => match fn with
    | .app _ _ => fn.render.dropLast ++ [","] ++ argument.render ++ [")"]
    | _ => fn.render ++ ["("] ++ argument.render ++ [")"]
  | .appNamed fn name argument => match fn with
    | .app _ _ | .appNamed _ _ _ => fn.render.dropLast ++ [",", name, "=>"] ++ argument.render ++ [")"]
    | _ => fn.render ++ ["(", name, "=>"] ++ argument.render ++ [")"]
  | .chainCase value no shortAnd shortOr eagerAnd eagerOr eagerXor =>
      ["case"] ++ value.render ++ ["is", "when", "no_chain", "=>"] ++ no.render ++
      [",", "when", "short_and", "=>"] ++ shortAnd.render ++
      [",", "when", "short_or", "=>"] ++ shortOr.render ++
      [",", "when", "eager_and", "=>"] ++ eagerAnd.render ++
      [",", "when", "eager_or", "=>"] ++ eagerOr.render ++
      [",", "when", "eager_xor", "=>"] ++ eagerXor.render
  | .field projection value => value.render ++ [".", projection.name]
  | .subtypeHidden context op => context.render ++ [".", "subtype_hiding", "("] ++ op.render ++ [")"]
  | .bindingAt names index => names.render ++ [".", "items", "("] ++ index.render ++ [")"]
  | .eq left right | .tokenEq left right | .chainEq left right | .comparisonEq left right => left.render ++ ["="] ++ right.render
  | .ne left right | .tokenNe left right | .chainNe left right => left.render ++ ["/="] ++ right.render
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
  | .chain value => value
  | .word value => value
  | .emptyPath => PathFacts.Context.empty
  | .validityCallWord => "input_is_valid"
  | .comparison value => value
  | .variable name => locals _ name
  | .function symbol => calls.get symbol
  | .app fn argument | .appNamed fn _ argument => fn.eval calls locals (argument.eval calls locals)
  | .chainCase value no shortAnd shortOr eagerAnd eagerOr eagerXor =>
      match value.eval calls locals with
      | .noChain => no.eval calls locals
      | .shortAnd => shortAnd.eval calls locals
      | .shortOr => shortOr.eval calls locals
      | .eagerAnd => eagerAnd.eval calls locals
      | .eagerOr => eagerOr.eval calls locals
      | .eagerXor => eagerXor.eval calls locals
  | .field projection value => projection.get (value.eval calls locals)
  | .subtypeHidden context op => (context.eval calls locals).subtypeHiding.get (op.eval calls locals)
  | .bindingAt names index => ((names.eval calls locals).get (index.eval calls locals)).getD {}
  | .eq left right => decide (left.eval calls locals = right.eval calls locals)
  | .ne left right => decide (left.eval calls locals ≠ right.eval calls locals)
  | .le left right => decide (left.eval calls locals ≤ right.eval calls locals)
  | .chainEq left right => decide (left.eval calls locals = right.eval calls locals)
  | .chainNe left right => decide (left.eval calls locals ≠ right.eval calls locals)
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

def callOperation (text : Expr .source) (names : Expr .names) (position : Expr .number)
    (operation : Expr .operation) (scalarNames : Expr .scalarNames) (arrays : Expr .arrays)
    (hidden : Expr .truth) (booleans : Expr .booleanNames) : Expr .number :=
  .app (.app (.app (.app (.app (.app (.app (.app (.function .callAfter) text) names)
    position) operation) scalarNames) arrays) hidden) booleans

def callEqualName (text : Expr .source) (first after otherFirst otherAfter : Expr .number) : Expr .truth :=
  .app (.app (.app (.app (.app (.function .equalName) text) first) after) otherFirst) otherAfter

def callNameIs (text : Expr .source) (first after : Expr .number) (word : Expr .word) : Expr .truth :=
  .app (.app (.app (.app (.function .nameIs) text) first) after) word

def callArrayLookup (text : Expr .source) (names : Expr .arrays) (first after : Expr .number) : Expr .number :=
  .app (.app (.app (.app (.function .arrayLookup) text) names) first) after

def callBooleanLookup (text : Expr .source) (names : Expr .booleanNames) (first after : Expr .number) : Expr .number :=
  .app (.app (.app (.app (.function .booleanLookup) text) names) first) after

def callBooleanAtom (text : Expr .source) (context : Expr .context) (position : Expr .number) : Expr .number :=
  .app (.app (.app (.function .booleanAtom) text) context) position

def callBooleanFactor (text : Expr .source) (context : Expr .context) (position : Expr .number)
    (facts : Expr .facts) (initials : Expr .initials) : Expr .condition :=
  .app (.app (.app (.app (.app (.function .booleanFactor) text) context) position) facts) initials

def callReadingNames (context : Expr .context) (facts : Expr .facts) : Expr .scalarNames :=
  .app (.app (.function .readingNames) context) facts

def callCharacterAt (text : Expr .source) (position : Expr .number) (names : Expr .names)
    (scalars : Expr .scalarNames) (arrays : Expr .arrays) (initials : Expr .initials)
    (elaborating : Expr .truth) : Expr .value :=
  .app (.app (.app (.app (.app (.app (.app (.function .characterAt) text) position) names) scalars) arrays) initials) elaborating

def callCharacterCondition (text : Expr .source) (context : Expr .context) (position : Expr .number)
    (facts : Expr .facts) (initials : Expr .initials) : Expr .condition :=
  .app (.app (.app (.app (.app (.function .characterCondition) text) context) position) facts) initials

def callBooleanRelation (text : Expr .source) (context : Expr .context) (position : Expr .number)
    (facts : Expr .facts) (initials : Expr .initials) : Expr .condition :=
  .app (.app (.app (.app (.app (.function .booleanRelation) text) context) position) facts) initials

def callTake (text : Expr .source) (position : Expr .number) (token : Expr .token) : Expr .number :=
  .app (.app (.app (.function .take) text) position) token

def callSkip (text : Expr .source) (position : Expr .number) : Expr .number :=
  .app (.app (.function .skip) text) position

def callNameAfter (text : Expr .source) (position : Expr .number) : Expr .number :=
  .app (.app (.function .nameAfter) text) position

def callLookup (text : Expr .source) (names : Expr .names) (first after : Expr .number) : Expr .number :=
  .app (.app (.app (.app (.function .lookup) text) names) first) after

def callScalarLookup (text : Expr .source) (names : Expr .scalarNames) (first after : Expr .number) : Expr .number :=
  .app (.app (.app (.app (.function .scalarLookup) text) names) first) after

def callScalarRead (text : Expr .source) (position : Expr .number) (names : Expr .scalarNames) : Expr .scalarResult :=
  .app (.app (.app (.function .scalarRead) text) position) names

def callScalarInFlow (text : Expr .source) (context : Expr .context) (position : Expr .number)
    (facts : Expr .facts) (initials : Expr .initials) : Expr .scalarResult :=
  .appNamed (.app (.app (.app (.app (.function .scalarInFlow) text) context) position) facts) "initials" initials

def callStringInFlow (text : Expr .source) (context : Expr .context) (position : Expr .number)
    (facts : Expr .facts) (initials : Expr .initials) : Expr .result :=
  .appNamed (.app (.app (.app (.app (.function .stringInFlow) text) context) position) facts) "initials" initials

def callScalarCondition (text : Expr .source) (context : Expr .context) (position rightPosition : Expr .number)
    (facts : Expr .facts) (left right : Expr .scalarResult) (operator : Expr .comparison) : Expr .condition :=
  .app (.app (.app (.app (.app (.app (.app (.app (.function .scalarCondition) text) context) position) rightPosition) facts) left) right) operator

def callInteger (text : Expr .source) (position : Expr .number) : Expr .literal :=
  .app (.app (.function .integer) text) position

def callExpression (text : Expr .source) (position : Expr .number) (names : Expr .names)
    (scalarNames : Expr .scalarNames) : Expr .result :=
  .app (.app (.app (.app (.function .expression) text) position) names) scalarNames

def callSummary (value : Expr .result) : Expr .summary := .app (.function .summary) value

def callBound (value : Expr .binding) : Expr .bound := .app (.function .bound) value

def callBindingSummary (value : Expr .binding) : Expr .summary := .app (.function .bindingSummary) value

def callComparison (text : Expr .source) (position : Expr .number) : Expr .compared :=
  .app (.app (.function .comparison) text) position

def callLength (text : Expr .source) (context : Expr .context) (position : Expr .number)
    (literal : Expr .truth) : Expr .length :=
  .app (.app (.app (.app (.function .length) text) context) position) literal

def callPrimary (text : Expr .source) (context : Expr .context) (position : Expr .number)
    (facts : Expr .facts) (initials : Expr .initials) : Expr .condition :=
  .appNamed (.app (.app (.app (.app (.function .primary) text) context) position) facts) "initials" initials

def callRelation (text : Expr .source) (context : Expr .context) (position : Expr .number)
    (facts : Expr .facts) (initials : Expr .initials) : Expr .condition :=
  .appNamed (.app (.app (.app (.app (.function .relation) text) context) position) facts) "initials" initials

def callCondition (text : Expr .source) (context : Expr .context) (position : Expr .number)
    (facts : Expr .facts) (initials : Expr .initials) : Expr .condition :=
  .appNamed (.app (.app (.app (.app (.function .condition) text) context) position) facts) "initials" initials

def callModel (text : Expr .source) (context : Expr .context) (position : Expr .number)
    (facts : Expr .facts) (initials : Expr .initials) : Expr .condition :=
  .appNamed (.app (.app (.app (.app (.function .model) text) context) position) facts) "initials" initials

def callChainToken (text : Expr .source) (position : Expr .number) : Expr .chain :=
  .app (.app (.function .chainToken) text) position

def callChainAfter (text : Expr .source) (position : Expr .number) (operator : Expr .chain) : Expr .number :=
  .app (.app (.app (.function .chainAfter) text) position) operator

def callXorFree (text : Expr .source) (first after : Expr .number) : Expr .truth :=
  .app (.app (.app (.function .xorFree) text) first) after

def callTail (text : Expr .source) (context : Expr .context) (result : Expr .condition)
    (operator : Expr .chain) (chained : Expr .truth) (initials : Expr .initials)
    (incoming : Expr .facts) (originalStart : Expr .number) : Expr .condition :=
  .appNamed (.appNamed (.appNamed (.app (.app (.app (.app (.app (.function .tail) text) context) result)
    operator) chained) "initials" initials) "incoming" incoming) "original_start" originalStart

def callAssumeValid (facts : Expr .path) : Expr .path := .app (.function .assumeValid) facts

def callAssumeInvalid (facts : Expr .path) : Expr .path := .app (.function .assumeInvalid) facts

def callRefineBounds (facts : Expr .path) (operator : Expr .comparison) (left right : Expr .bound)
    (truth : Expr .truth) : Expr .path :=
  .app (.app (.app (.app (.app (.function .refineBounds) facts) operator) left) right) truth

def callFits (facts : Expr .path) (value : Expr .summary) : Expr .truth :=
  .app (.app (.function .fits) facts) value

def callRefineEqual (facts : Expr .path) (left right : Expr .summary) : Expr .path :=
  .app (.app (.app (.function .refineEqual) facts) left) right

def callJoin (left right : Expr .facts) : Expr .facts := .app (.app (.function .join) left) right

end Expr

end Silver.Predicate.Native
