module

public import Silver.PredicateConditionAdmission
public import Silver.PredicateFlowInvariant
public import Silver.PredicateConditionFlowValidity
public import Silver.PathBounds
public import Silver.BooleanBindings
public import Silver.IntegerSubtypeBindings
public import Silver.ComposeContracts
public import Silver.ScalarExpressionEnvironment

@[expose] public section

namespace Silver.Predicate.Native

/-- The actual immutable Body_Context fields. Only the argument-presence test
is projected away; binding source positions and the complete active name
storage retain their existing compiler interpretation. -/
structure Context where
  names : Compose.BindingEnvironment
  dynamicFirst : Nat
  dynamicAfter : Nat
  scalarNames : ScalarExpression.Environment := []
  declarationCount : Nat := 0
  arrayNames : ArrayBindings.Metadata := []
  subtypeHiding : IntegerSubtypes.CallHiding := {}
  booleanNames : BooleanBindings.Environment := []
  trueHidden : Bool := false
  falseHidden : Bool := false
  elaborating : Bool := false
  maskFirst : Nat := 0
  maskAfter : Nat := 0
  pure : Bool := false
  integerHidden : Bool := false
  arrayTypes : ArrayBindings.TypeEnvironment := []
  contextFirst : Nat := 1
  packageFirst : Nat := 0
  packageAfter : Nat := 0
  deriving DecidableEq, Repr

def Context.arrayTable (context : Context) : ArrayBindings.Table :=
  ⟨context.arrayNames, context.arrayTypes⟩

def Context.model (context : Context) : ParseContext :=
  ⟨context.names, decide (context.dynamicFirst ≠ 0), context.scalarNames,
    context.declarationCount, context.arrayNames, context.subtypeHiding, context.booleanNames,
    context.trueHidden, context.falseHidden, context.elaborating, context.maskFirst, context.maskAfter,
    context.pure, context.integerHidden, context.arrayTypes,
    context.contextFirst, context.packageFirst, context.packageAfter⟩

def ValidContext (text : Source) (context : Context) : Prop :=
  Compose.Expressions.ValidNames text context.names ∧
    (⟨context.dynamicFirst, context.dynamicAfter⟩ : Named.NameState).Valid text ∧
    ScalarExpression.ValidEnvironment text context.scalarNames ∧
    ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating ∧
    ArrayBindings.ValidTable text context.arrayTable ∧
    BooleanBindings.ValidEnvironment text context.booleanNames ∧
    (⟨context.maskFirst, context.maskAfter⟩ : Named.NameState).Valid text ∧
    Compose.NamesBoundsValid context.names ∧
    Names.ValidContext text context.contextFirst context.packageFirst context.packageAfter

theorem ValidContext.base {text : Source} {context : Context}
    (valid : ValidContext text context) :
    ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating := valid.2.2.2.1

theorem ValidContext.arrays {text : Source} {context : Context}
    (valid : ValidContext text context) :
    ArrayBindings.ValidTable text context.arrayTable := valid.2.2.2.2.1

theorem ValidContext.booleans {text : Source} {context : Context}
    (valid : ValidContext text context) :
    BooleanBindings.ValidEnvironment text context.booleanNames := valid.2.2.2.2.2.1

theorem ValidContext.mask {text : Source} {context : Context}
    (valid : ValidContext text context) :
    (⟨context.maskFirst, context.maskAfter⟩ : Named.NameState).Valid text := valid.2.2.2.2.2.2.1

theorem ValidContext.bounds {text : Source} {context : Context}
    (valid : ValidContext text context) : Compose.NamesBoundsValid context.names :=
  valid.2.2.2.2.2.2.2.1

theorem ValidContext.unit {text : Source} {context : Context}
    (valid : ValidContext text context) :
    Names.ValidContext text context.contextFirst context.packageFirst context.packageAfter :=
  valid.2.2.2.2.2.2.2.2

theorem ValidContext.nativeNames {text : Source} {context : Context}
    (valid : ValidContext text context) : Compose.Expressions.NativeNames text context.names :=
  ⟨valid.1, valid.bounds⟩

/-- The native array and interval types contribute the bounded domains; the
checked Valid_Flow predicate contributes active extent, immutable cells,
declaration containment and nonempty mutable cells. -/
def ValidFlow (context : Context) (facts : ActiveFlow) : Prop :=
  facts.path.Bounded ∧ ScalarMetadata.FlowReady context.scalarNames context.declarationCount facts

theorem ValidFlow.count_le {text : Source} {context : Context} {facts : ActiveFlow}
    (cv : ValidContext text context) (fv : ValidFlow context facts) :
    facts.count ≤ ScalarExpression.maxBindings := by
  rw [fv.2.compatible.count]
  exact cv.2.2.1.1

theorem ValidFlow.join {context : Context} {left right : ActiveFlow}
    (base : ScalarMetadata.ContextReady context.scalarNames context.declarationCount context.elaborating)
    (a : ValidFlow context left) (b : ValidFlow context right) :
    ValidFlow context (left.join right) :=
  ⟨PathFacts.Context.join_bounded a.1 b.1, ScalarMetadata.FlowReady.join_context base a.2 b.2⟩

inductive Token
  | leftParenthesis | rightParenthesis | argumentsName | dot | inputIsValid
  | apostrophe | lengthName | notEqual | lessEqual | greaterEqual | equal | less | greater
  | notKeyword | andKeyword | orKeyword | xorKeyword | thenKeyword | elseKeyword | endKeyword
  deriving DecidableEq, Repr

def Token.name : Token → String
  | .leftParenthesis => "left_parenthesis" | .rightParenthesis => "right_parenthesis"
  | .argumentsName => "arguments_name" | .dot => "dot" | .inputIsValid => "input_is_valid_name"
  | .apostrophe => "apostrophe" | .lengthName => "length_name" | .notEqual => "not_equal"
  | .lessEqual => "less_equal" | .greaterEqual => "greater_equal" | .equal => "equal"
  | .less => "less" | .greater => "greater" | .notKeyword => "not_keyword"
  | .xorKeyword => "xor_keyword"
  | .andKeyword => "and_keyword" | .orKeyword => "or_keyword" | .thenKeyword => "then_keyword"
  | .elseKeyword => "else_keyword" | .endKeyword => "end_keyword"

def Token.shell : Token → Compose.ShellToken
  | .leftParenthesis => .symbol "(" | .rightParenthesis => .symbol ")"
  | .argumentsName => .word "silver_arguments" | .dot => .symbol "." | .inputIsValid => .word "input_is_valid"
  | .apostrophe => .symbol "'" | .lengthName => .word "length" | .notEqual => .symbol "/="
  | .lessEqual => .symbol "<=" | .greaterEqual => .symbol ">=" | .equal => .symbol "="
  | .less => .symbol "<" | .greater => .symbol ">" | .notKeyword => .word "not"
  | .xorKeyword => .word "xor"
  | .andKeyword => .word "and" | .orKeyword => .word "or" | .thenKeyword => .word "then"
  | .elseKeyword => .word "else" | .endKeyword => .word "end"

theorem Token.name_eq_tokenName_shell : ∀ t : Token, t.name = Compose.Expressions.tokenName t.shell := by
  intro t; cases t <;> rfl

def Token.isChain (token : Token) : Bool := token == .andKeyword || token == .orKeyword

/-- The scanner's operator category is distinct from its lexical token kind. -/
inductive ChainKind
  | noChain | shortAnd | shortOr | eagerAnd | eagerOr | eagerXor
  deriving DecidableEq, Repr

def ChainKind.name : ChainKind → String
  | .noChain => "no_chain" | .shortAnd => "short_and" | .shortOr => "short_or"
  | .eagerAnd => "eager_and" | .eagerOr => "eager_or" | .eagerXor => "eager_xor"

def ChainKind.isChain (operator : ChainKind) : Bool := operator != .noChain

end Silver.Predicate.Native
