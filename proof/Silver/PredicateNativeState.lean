module

public import Silver.PredicateAdmission
public import Silver.IntegerSubtypeBindings
public import Silver.ComposeContracts
public import Silver.ScalarExpressionEnvironment
public import Silver.PredicateConditionFlowValidity
public import Silver.PredicateConditionBounds

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
  deriving DecidableEq, Repr

def Context.model (context : Context) : ParseContext :=
  ⟨context.names, decide (context.dynamicFirst ≠ 0), context.scalarNames,
    context.declarationCount, context.arrayNames, context.subtypeHiding⟩

def ValidContext (text : Source) (context : Context) : Prop :=
  Compose.Expressions.ValidNames text context.names ∧
    (⟨context.dynamicFirst, context.dynamicAfter⟩ : Named.NameState).Valid text ∧
    ScalarExpression.ValidEnvironment text context.scalarNames ∧
    ScalarMetadata.BaseReady context.scalarNames context.declarationCount ∧
    ArrayBindings.ValidMetadata text context.arrayNames

theorem ValidContext.base {text : Source} {context : Context}
    (valid : ValidContext text context) :
    ScalarMetadata.BaseReady context.scalarNames context.declarationCount := valid.2.2.2.1

theorem ValidContext.arrays {text : Source} {context : Context}
    (valid : ValidContext text context) :
    ArrayBindings.ValidMetadata text context.arrayNames := valid.2.2.2.2

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
    (base : ScalarMetadata.BaseReady context.scalarNames context.declarationCount)
    (a : ValidFlow context left) (b : ValidFlow context right) :
    ValidFlow context (left.join right) :=
  ⟨PathFacts.Context.join_bounded a.1 b.1, ScalarMetadata.FlowReady.join base a.2 b.2⟩

inductive Token
  | leftParenthesis | rightParenthesis | argumentsName | dot | inputIsValid
  | apostrophe | lengthName | notEqual | lessEqual | greaterEqual | equal | less | greater
  | notKeyword | andKeyword | orKeyword | thenKeyword | elseKeyword | endKeyword
  deriving DecidableEq, Repr

def Token.name : Token → String
  | .leftParenthesis => "left_parenthesis" | .rightParenthesis => "right_parenthesis"
  | .argumentsName => "arguments_name" | .dot => "dot" | .inputIsValid => "input_is_valid_name"
  | .apostrophe => "apostrophe" | .lengthName => "length_name" | .notEqual => "not_equal"
  | .lessEqual => "less_equal" | .greaterEqual => "greater_equal" | .equal => "equal"
  | .less => "less" | .greater => "greater" | .notKeyword => "not_keyword"
  | .andKeyword => "and_keyword" | .orKeyword => "or_keyword" | .thenKeyword => "then_keyword"
  | .elseKeyword => "else_keyword" | .endKeyword => "end_keyword"

def Token.shell : Token → Compose.ShellToken
  | .leftParenthesis => .symbol "(" | .rightParenthesis => .symbol ")"
  | .argumentsName => .word "silver_arguments" | .dot => .symbol "." | .inputIsValid => .word "input_is_valid"
  | .apostrophe => .symbol "'" | .lengthName => .word "length" | .notEqual => .symbol "/="
  | .lessEqual => .symbol "<=" | .greaterEqual => .symbol ">=" | .equal => .symbol "="
  | .less => .symbol "<" | .greater => .symbol ">" | .notKeyword => .word "not"
  | .andKeyword => .word "and" | .orKeyword => .word "or" | .thenKeyword => .word "then"
  | .elseKeyword => .word "else" | .endKeyword => .word "end"

def Token.isChain (token : Token) : Bool := token == .andKeyword || token == .orKeyword

def Token.chain (token : Token) : Bool := token == .andKeyword

def chainState (operator : Token) (chained : Bool) : Option Bool :=
  if chained then some operator.chain else none

end Silver.Predicate.Native
