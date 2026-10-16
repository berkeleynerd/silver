module

public import Silver.PredicateAdmission
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
  deriving DecidableEq, Repr

def Context.model (context : Context) : ParseContext :=
  ⟨context.names, decide (context.dynamicFirst ≠ 0), context.scalarNames⟩

def ValidContext (text : Source) (context : Context) : Prop :=
  Compose.Expressions.ValidNames text context.names ∧
    (⟨context.dynamicFirst, context.dynamicAfter⟩ : Named.NameState).Valid text ∧
    ScalarExpression.ValidEnvironment text context.scalarNames

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
