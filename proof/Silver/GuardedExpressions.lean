import Silver.GuardedEquations
import Silver.ArgumentsExpressions
import Silver.AssignmentExpressions
import Silver.BranchingExpressions

/-! Typed trees for the newly admitted recognizer equations. The inherited
helper interpretation is reused without assuming the obsolete public union.
Arithmetic uses natural subtraction only on the guarded domains proved in
SPARK; render/precedence checks retain the actual Ada grouping. -/

set_option linter.constructorNameAsVariable false
namespace Silver.Guarded.Expressions
open Named

structure Calls where
  base : Arguments.Expressions.Calls
  tail : Source → Nat → Nat → DecimalResult
  decimal : Source → Nat → DecimalResult
  length : Source → Nat → Nat
  suffix : Source → Nat → Nat → NameState → Nat → Nat → Bool
  token : Source → Nat → Token → Bool
  member : Source → Bool
  guarded : Source → Bool
  assignment : Source → Nat → Nat → NameState → Nat → Bool
  assignmentMember : Source → Bool
  branching : Source → Nat → Nat → NameState → Bool
  branchingToken : Source → Nat → Branching.Token → Bool
  branchingMember : Source → Bool

structure Context where
  text : Source
  position : Nat := 1
  value : Nat := 0
  nextToken : Nat := 1
  declaredFirst : Nat := 0
  declaredAfter : Nat := 0
  capacity : Nat := 0
  decorations : Nat := 0

mutual
inductive Number
  | constant (value : Nat) | character (value : Nat) | characterVal (value : Number)
  | characterPos (value : Number)
  | position | last | value | nextToken | tokenLast | declaredFirst | declaredAfter
  | capacity | decorations | sourceLength | maxLength
  | add (left right : Number) | sub (left right : Number)
  | mul (left right : Number) | div (left right : Number) | group (value : Number)
  | byteAt (position : Number) | finish (position : Number)
  | literal (position : Number) | length (position : Number) | trivia (position : Number)
  | decimalAfter (position : Number) | decimalValue (position : Number) | spellingLength (index : Number)
  | ite (condition : Condition) (yes no : Number) | elsif (condition : Condition) (yes no : Number)
  deriving DecidableEq, Repr
inductive Condition
  | value (value : Bool)
  | eq (left right : Number) | ne (left right : Number)
  | lt (left right : Number) | le (left right : Number) | gt (left right : Number)
  | range (value first last : Number) | notRange (value first last : Number)
  | andThen (left right : Condition) | orElse (left right : Condition)
  | not (value : Condition) | group (value : Condition)
  | identifier (value : Number) | forbidden (first after : Number)
  | equal (leftFirst leftAfter rightFirst rightAfter : Number)
  | tokenEq (index : Number) (token : Token) | tokenAt (position index : Number)
  | suffix (position index first after capacity decorations : Number)
  | allowedNormalized | directNormalized | namedNormalized | argumentNormalized | concatNormalized | guardedNormalized | assignmentNormalized | branchingNormalized
  | whenTrue (condition yes : Condition)
  | ite (condition yes no : Condition) | elsif (condition yes no : Condition)
  deriving DecidableEq, Repr
end

inductive Decimal
  | invalid | result (after value : Number) | tail (position value : Number)
  | group (value : Decimal)
  | ite (condition : Condition) (yes no : Decimal) | elsif (condition : Condition) (yes no : Decimal)
  deriving DecidableEq, Repr

def call := Silver.Expressions.call

def tokenName : Token → String
  | .base .withKeyword => "with_keyword" | .base .ioName => "io_name"
  | .base .procedureKeyword => "procedure_keyword" | .base .mainName => "main_name"
  | .base .isKeyword => "is_keyword" | .base .pragmaKeyword => "pragma_keyword"
  | .base .sparkModeName => "spark_mode_name" | .base .onName => "on_name"
  | .base .beginKeyword => "begin_keyword" | .base .putLineName => "put_line_name"
  | .base .endKeyword => "end_keyword" | .base .leftParenthesis => "left_parenthesis"
  | .base .rightParenthesis => "right_parenthesis" | .base .semicolon => "semicolon"
  | .base .dot => "dot" | .base .stringLiteral => "string_literal"
  | .colon => "colon" | .constantKeyword => "constant_keyword" | .stringName => "string_name"
  | .assignment => "assignment" | .declarationName => "declaration_name" | .referenceName => "reference_name"
  | .ampersand => "ampersand" | .argumentsName => "arguments_name" | .firstOrDefaultName => "first_or_default_name"
  | .ifKeyword => "if_keyword" | .inputIsValidName => "input_is_valid_name"
  | .thenKeyword => "then_keyword" | .elseKeyword => "else_keyword" | .rejectName => "reject_name"
  | .andKeyword => "and_keyword" | .apostrophe => "apostrophe" | .lengthName => "length_name"
  | .lessEqual => "less_equal" | .capacityLiteral => "capacity_literal"

def normalized := call "normalized" [["source"]]
def tokenFor (index : Nat) : Token := requiredTokens.getD (index - 1) (.base .semicolon)
mutual
def Number.render : Number → List String
  | .constant value => [toString value]
  | .character value => [String.ofList ['\'', Char.ofNat value, '\'']]
  | .characterVal value => ["character", "'", "val", "("] ++ value.render ++ [")"]
  | .characterPos value => ["character", "'", "pos", "("] ++ value.render ++ [")"]
  | .position => ["position"] | .last => ["text", "'", "last"] | .value => ["value"]
  | .nextToken => ["next_token"] | .tokenLast => ["guarded_required_tokens", "'", "last"]
  | .declaredFirst => ["declared_first"] | .declaredAfter => ["declared_after"]
  | .capacity => ["capacity"] | .decorations => ["decoration_length"]
  | .sourceLength => ["source", "'", "length"] | .maxLength => ["max_source_length"]
  | .add a b => a.render ++ ["+"] ++ b.render | .sub a b => a.render ++ ["-"] ++ b.render
  | .mul a b => a.render ++ ["*"] ++ b.render | .div a b => a.render ++ ["/"] ++ b.render
  | .group a => ["("] ++ a.render ++ [")"]
  | .byteAt a => call "text" [a.render]
  | .finish a => call "identifier_end" [["text"], a.render]
  | .literal a => call "literal_end" [["text"], a.render]
  | .length a => call "literal_length" [["text"], a.render]
  | .trivia a => call "trivia_end" [["text"], a.render]
  | .decimalAfter a => call "decimal_at" [["text"], a.render] ++ [".", "after"]
  | .decimalValue a => call "decimal_at" [["text"], a.render] ++ [".", "value"]
  | .spellingLength a => call "spelling" [call "guarded_required_tokens" [a.render]] ++ ["'", "length"]
  | .ite c a b => ["if"] ++ c.render ++ ["then"] ++ a.render ++ (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
  | .elsif c a b => ["elsif"] ++ c.render ++ ["then"] ++ a.render ++ (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
def Condition.render : Condition → List String
  | .value true => ["true"] | .value false => ["false"]
  | .eq a b => a.render ++ ["="] ++ b.render | .ne a b => a.render ++ ["/="] ++ b.render
  | .lt a b => a.render ++ ["<"] ++ b.render | .le a b => a.render ++ ["<="] ++ b.render
  | .gt a b => a.render ++ [">"] ++ b.render
  | .range a b c => a.render ++ ["in"] ++ b.render ++ [".."] ++ c.render
  | .notRange a b c => a.render ++ ["not", "in"] ++ b.render ++ [".."] ++ c.render
  | .andThen a b => a.render ++ ["and", "then"] ++ b.render
  | .orElse a b => a.render ++ ["or", "else"] ++ b.render
  | .not a => ["not"] ++ a.render | .group a => ["("] ++ a.render ++ [")"]
  | .identifier a => call "is_identifier_character" [a.render]
  | .forbidden a b => call "forbidden_argument_name" [["text"], a.render, b.render]
  | .equal a b c d => call "equal_name" [["text"], a.render, b.render, c.render, d.render]
  | .tokenEq index token => call "guarded_required_tokens" [index.render] ++ ["=", tokenName token]
  | .tokenAt p i => call "token_at" [["text"], p.render, call "spelling" [call "guarded_required_tokens" [i.render]], call "is_word_token" [call "guarded_required_tokens" [i.render]]]
  | .suffix p i a b c d => call "guarded_suffix_matches" [["text"],p.render,i.render,a.render,b.render,c.render,d.render]
  | .allowedNormalized => call "allowed_source" [normalized]
  | .directNormalized => call "suffix_matches" [normalized,["1"],["1"]]
  | .namedNormalized => call "named_suffix_matches" [normalized,["1"],["1"],["0"],["0"]]
  | .argumentNormalized => call "argument_suffix_matches" [normalized,["1"],["1"],["0"],["0"]]
  | .concatNormalized => call "concatenation_suffix_matches" [normalized,["1"],["1"],["0"],["0"]]
  | .guardedNormalized => call "guarded_suffix_matches" [normalized,["1"],["1"],["0"],["0"],["0"],["0"]]
  | .assignmentNormalized => call "assignment_suffix_matches" [normalized,["1"],["1"],["0"],["0"],["0"]]
  | .branchingNormalized => call "branching_suffix_matches" [normalized,["1"],["1"],["0"],["0"]]
  | .whenTrue c a => ["if"] ++ c.render ++ ["then"] ++ a.render
  | .ite c a b => ["if"] ++ c.render ++ ["then"] ++ a.render ++ (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
  | .elsif c a b => ["elsif"] ++ c.render ++ ["then"] ++ a.render ++ (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
end

def Decimal.render : Decimal → List String
  | .invalid => ["invalid_decimal"]
  | .result a b => ["(","after","=>"] ++ a.render ++ [",","value","=>"] ++ b.render ++ [")"]
  | .tail a b => call "decimal_tail" [["text"],a.render,b.render]
  | .group a => ["("] ++ a.render ++ [")"]
  | .ite c a b => ["if"] ++ c.render ++ ["then"] ++ a.render ++ (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
  | .elsif c a b => ["elsif"] ++ c.render ++ ["then"] ++ a.render ++ (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)

-- Explicit precedence categories for Ada simple expressions, terms and primaries.
def Number.primary : Number → Bool
  | .add _ _ | .sub _ _ | .mul _ _ | .div _ _ | .ite _ _ _ | .elsif _ _ _ => false | _ => true
def Number.term : Number → Bool
  | .add _ _ | .sub _ _ | .ite _ _ _ | .elsif _ _ _ => false | _ => true
def Number.simple : Number → Bool
  | .ite _ _ _ | .elsif _ _ _ => false | _ => true
def Number.isElsif : Number → Bool | .elsif _ _ _ => true | _ => false
def Condition.primary : Condition → Bool
  | .value _ | .group _ | .identifier _ | .forbidden _ _ | .equal _ _ _ _ | .tokenAt _ _
  | .suffix _ _ _ _ _ _ | .allowedNormalized | .directNormalized | .namedNormalized
  | .argumentNormalized | .concatNormalized | .guardedNormalized | .assignmentNormalized | .branchingNormalized => true | _ => false
def Condition.relation : Condition → Bool
  | .andThen _ _ | .orElse _ _ | .whenTrue _ _ | .ite _ _ _ | .elsif _ _ _ => false | _ => true
def Condition.logical : Condition → Bool
  | .whenTrue _ _ | .ite _ _ _ | .elsif _ _ _ => false | _ => true
def Condition.isElsif : Condition → Bool | .elsif _ _ _ => true | _ => false
def Condition.andLeft : Condition → Bool | .andThen _ _ => true | c => c.relation
def Condition.orLeft : Condition → Bool | .orElse _ _ => true | c => c.relation
mutual
def Number.wellFormed : Number → Bool
  | .add a b | .sub a b => a.wellFormed && b.wellFormed && a.simple && b.term
  | .mul a b | .div a b => a.wellFormed && b.wellFormed && a.term && b.primary
  | .group a => a.wellFormed && !a.isElsif
  | .byteAt a | .finish a | .literal a | .length a | .trivia a | .decimalAfter a
  | .decimalValue a | .spellingLength a | .characterVal a | .characterPos a => a.wellFormed && a.simple
  | .ite c a b | .elsif c a b => c.wellFormed && c.logical && a.wellFormed && a.simple && b.wellFormed && (b.simple || b.isElsif)
  | _ => true
def Condition.wellFormed : Condition → Bool
  | .eq a b | .ne a b | .lt a b | .le a b | .gt a b => a.wellFormed && b.wellFormed && a.simple && b.simple
  | .range a b c | .notRange a b c => a.wellFormed && b.wellFormed && c.wellFormed && a.simple && b.simple && c.simple
  | .andThen a b => a.wellFormed && b.wellFormed && a.andLeft && b.relation
  | .orElse a b => a.wellFormed && b.wellFormed && a.orLeft && b.relation
  | .not a => a.wellFormed && a.primary
  | .group a => a.wellFormed && !a.isElsif
  | .identifier a | .tokenEq a _ => a.wellFormed && a.simple
  | .forbidden a b | .tokenAt a b => a.wellFormed && b.wellFormed && a.simple && b.simple
  | .equal a b c d => a.wellFormed && b.wellFormed && c.wellFormed && d.wellFormed && a.simple && b.simple && c.simple && d.simple
  | .suffix a b c d e f => a.wellFormed && b.wellFormed && c.wellFormed && d.wellFormed && e.wellFormed && f.wellFormed && a.simple && b.simple && c.simple && d.simple && e.simple && f.simple
  | .whenTrue c a => c.wellFormed && c.logical && a.wellFormed && a.logical
  | .ite c a b | .elsif c a b => c.wellFormed && c.logical && a.wellFormed && a.logical && b.wellFormed && (b.logical || b.isElsif)
  | _ => true
end

def Decimal.simple : Decimal → Bool | .ite _ _ _ | .elsif _ _ _ => false | _ => true
def Decimal.isElsif : Decimal → Bool | .elsif _ _ _ => true | _ => false
def Decimal.wellFormed : Decimal → Bool
  | .invalid => true
  | .result a b | .tail a b => a.wellFormed && b.wellFormed && a.simple && b.simple
  | .group a => a.wellFormed && !a.isElsif
  | .ite c a b | .elsif c a b => c.wellFormed && c.logical && a.wellFormed && a.simple && b.wellFormed && (b.simple || b.isElsif)

mutual
def Number.eval (calls : Calls) (ctx : Context) : Number → Nat
  | .constant n | .character n => n
  | .characterVal a | .characterPos a | .group a => a.eval calls ctx
  | .position => ctx.position | .last => ctx.text.length | .value => ctx.value
  | .nextToken => ctx.nextToken | .tokenLast => requiredTokens.length
  | .declaredFirst => ctx.declaredFirst | .declaredAfter => ctx.declaredAfter
  | .capacity => ctx.capacity | .decorations => ctx.decorations
  | .sourceLength => ctx.text.length | .maxLength => maxSourceLength
  | .add a b => a.eval calls ctx + b.eval calls ctx | .sub a b => a.eval calls ctx - b.eval calls ctx
  | .mul a b => a.eval calls ctx * b.eval calls ctx | .div a b => a.eval calls ctx / b.eval calls ctx
  | .byteAt a => Cursor.byteAt ctx.text (a.eval calls ctx)
  | .finish a => calls.base.identifier.finish ctx.text (a.eval calls ctx)
  | .literal a => calls.base.output.literal ctx.text (a.eval calls ctx)
  | .length a => calls.length ctx.text (a.eval calls ctx)
  | .trivia a => calls.base.primitive.trivia ctx.text (a.eval calls ctx)
  | .decimalAfter a => (calls.decimal ctx.text (a.eval calls ctx)).after
  | .decimalValue a => (calls.decimal ctx.text (a.eval calls ctx)).value
  | .spellingLength a => (tokenFor (a.eval calls ctx)).spelling.length
  | .ite c a b | .elsif c a b => if c.eval calls ctx then a.eval calls ctx else b.eval calls ctx
def Condition.eval (calls : Calls) (ctx : Context) : Condition → Bool
  | .value v => v
  | .eq a b => a.eval calls ctx == b.eval calls ctx | .ne a b => !(a.eval calls ctx == b.eval calls ctx)
  | .lt a b => decide (a.eval calls ctx < b.eval calls ctx) | .le a b => decide (a.eval calls ctx ≤ b.eval calls ctx)
  | .gt a b => decide (a.eval calls ctx > b.eval calls ctx)
  | .range a b c => decide (b.eval calls ctx ≤ a.eval calls ctx ∧ a.eval calls ctx ≤ c.eval calls ctx)
  | .notRange a b c => !decide (b.eval calls ctx ≤ a.eval calls ctx ∧ a.eval calls ctx ≤ c.eval calls ctx)
  | .andThen a b => a.eval calls ctx && b.eval calls ctx | .orElse a b => a.eval calls ctx || b.eval calls ctx
  | .not a => !a.eval calls ctx | .group a => a.eval calls ctx
  | .identifier a => identifierCharacter (a.eval calls ctx)
  | .forbidden a b => calls.base.argumentForbidden ctx.text (a.eval calls ctx) (b.eval calls ctx)
  | .equal a b c d => calls.base.identifier.equal ctx.text (a.eval calls ctx) (b.eval calls ctx) (c.eval calls ctx) (d.eval calls ctx)
  | .tokenEq index token => tokenFor (index.eval calls ctx) == token
  | .tokenAt p i => calls.token ctx.text (p.eval calls ctx) (tokenFor (i.eval calls ctx))
  | .suffix p i a b c d => calls.suffix ctx.text (p.eval calls ctx) (i.eval calls ctx) ⟨a.eval calls ctx,b.eval calls ctx⟩ (c.eval calls ctx) (d.eval calls ctx)
  | .allowedNormalized => calls.base.primitive.allowed (calls.base.primitive.normalize ctx.text)
  | .directNormalized => calls.base.output.suffix (calls.base.primitive.normalize ctx.text) 1 1
  | .namedNormalized => calls.base.namedSuffix (calls.base.primitive.normalize ctx.text) 1 1 {}
  | .argumentNormalized => calls.base.arguments.suffix (calls.base.primitive.normalize ctx.text) 1 1 {}
  | .concatNormalized => calls.base.concatSuffix (calls.base.primitive.normalize ctx.text) 1 1 {}
  | .guardedNormalized => calls.suffix (calls.base.primitive.normalize ctx.text) 1 1 {} 0 0
  | .assignmentNormalized => calls.assignment (calls.base.primitive.normalize ctx.text) 1 1 {} 0
  | .branchingNormalized => calls.branching (calls.base.primitive.normalize ctx.text) 1 1 {}
  | .whenTrue c a => if c.eval calls ctx then a.eval calls ctx else true
  | .ite c a b | .elsif c a b => if c.eval calls ctx then a.eval calls ctx else b.eval calls ctx
end

def Decimal.eval (calls : Calls) (ctx : Context) : Decimal → DecimalResult
  | .invalid => invalidDecimal | .result a b => ⟨a.eval calls ctx,b.eval calls ctx⟩
  | .tail a b => calls.tail ctx.text (a.eval calls ctx) (b.eval calls ctx)
  | .group a => a.eval calls ctx
  | .ite c a b | .elsif c a b => if c.eval calls ctx then a.eval calls ctx else b.eval calls ctx

def digitValue : Number := .sub (.characterPos (.byteAt .position)) (.characterPos (.character 48))
def decimalTailBody : Decimal :=
  .ite (.gt .position .last) (.result .position .value)
    (.elsif (.notRange (.byteAt .position) (.character 48) (.character 57))
      (.group (.ite (.identifier (.byteAt .position)) .invalid (.result .position .value)))
      (.elsif (.gt .value (.div (.group (.sub .maxLength (.group digitValue))) (.constant 10)))
        .invalid (.tail (.add .position (.constant 1)) (.add (.mul (.constant 10) .value) (.group digitValue)))))
def decimalAtBody : Decimal :=
  .ite (.orElse (.gt .position .last) (.notRange (.byteAt .position) (.character 48) (.character 57))) .invalid
    (.elsif (.eq (.byteAt .position) (.character 48))
      (.group (.ite (.andThen (.lt .position .last) (.identifier (.byteAt (.add .position (.constant 1)))))
        .invalid (.result (.add .position (.constant 1)) (.constant 0))))
      (.tail (.add .position (.constant 1)) digitValue))
def literalLengthBody : Number :=
  .ite (.gt .position .last) (.constant 0)
    (.elsif (.eq (.byteAt .position) (.characterVal (.constant 34)))
      (.group (.ite (.andThen (.lt .position .last) (.eq (.byteAt (.add .position (.constant 1))) (.characterVal (.constant 34))))
        (.add (.constant 1) (.length (.add .position (.constant 2)))) (.constant 0)))
      (.elsif (.range (.byteAt .position) (.character 32) (.character 126))
        (.add (.constant 1) (.length (.add .position (.constant 1)))) (.constant 0)))

def suffixBody : Condition :=
  let start := Number.trivia .position
  let finish := Number.finish start
  let next := Number.add .nextToken (.constant 1)
  let length := Number.length (.add start (.constant 1))
  .ite (.gt .nextToken .tokenLast)
    (.andThen (.eq start (.add .last (.constant 1))) (.eq (.add .capacity .decorations) .maxLength))
    (.elsif (.tokenEq .nextToken .declarationName)
      (.andThen (.andThen (.ne finish (.constant 0)) (.not (.forbidden start finish)))
        (.suffix finish next start finish .capacity .decorations))
      (.elsif (.tokenEq .nextToken .referenceName)
        (.andThen (.andThen (.andThen (.gt .declaredFirst (.constant 0)) (.ne finish (.constant 0)))
          (.equal .declaredFirst .declaredAfter start finish))
          (.suffix finish next .declaredFirst .declaredAfter .capacity .decorations))
        (.elsif (.tokenEq .nextToken .capacityLiteral)
          (.andThen (.ne (.decimalAfter start) (.constant 0))
            (.suffix (.decimalAfter start) next .declaredFirst .declaredAfter (.decimalValue start) .decorations))
          (.elsif (.tokenEq .nextToken (.base .stringLiteral))
            (.andThen (.andThen (.andThen (.andThen (.le start .last)
              (.eq (.byteAt start) (.characterVal (.constant 34))))
              (.ne (.literal (.add start (.constant 1))) (.constant 0)))
              (.group (.whenTrue (.gt .nextToken (.constant 39)) (.le (.add .decorations length) .maxLength))))
              (.suffix (.literal (.add start (.constant 1))) next .declaredFirst .declaredAfter .capacity
                (.group (.ite (.gt .nextToken (.constant 39)) (.add .decorations length) .decorations))))
            (.andThen (.tokenAt start .nextToken)
              (.suffix (.add start (.spellingLength .nextToken)) next .declaredFirst .declaredAfter .capacity .decorations))))))
def memberBody : Condition :=
  .andThen (.andThen (.range .sourceLength (.constant 1) .maxLength) .allowedNormalized)
    (.group (.orElse (.orElse (.orElse (.orElse (.orElse (.orElse .directNormalized .namedNormalized) .argumentNormalized) .concatNormalized) .guardedNormalized) .assignmentNormalized) .branchingNormalized))
def guardedBody : Condition :=
  .andThen (.andThen (.range .sourceLength (.constant 1) .maxLength) .allowedNormalized) .guardedNormalized

def assignmentBody : Condition :=
  .andThen (.andThen (.range .sourceLength (.constant 1) .maxLength) .allowedNormalized) .assignmentNormalized

def branchingBody : Condition :=
  .andThen (.andThen (.range .sourceLength (.constant 1) .maxLength) .allowedNormalized) .branchingNormalized

abbrev WellFormedTrees : Prop := decimalTailBody.wellFormed = true ∧ decimalAtBody.wellFormed = true ∧
  literalLengthBody.wellFormed = true ∧ suffixBody.wellFormed = true ∧ memberBody.wellFormed = true ∧ guardedBody.wellFormed = true ∧ assignmentBody.wellFormed = true ∧ branchingBody.wellFormed = true
theorem checked_precedence : WellFormedTrees := by decide +kernel

theorem outside_digit (n : Nat) : (48 ≤ n → 57 < n) ↔ (n < 48 ∨ 57 < n) := by omega

theorem decimalTail_denotation (calls : Calls) (ctx : Context) :
    decimalTailBody.eval calls ctx = decimalTailEquation (calls.tail ctx.text) ctx.text ctx.position ctx.value := by
  dsimp +instances only [decimalTailBody, digitValue, Decimal.eval, Number.eval, Condition.eval]
  simp [decimalTailEquation, digit, outside_digit]
theorem decimalAt_denotation (calls : Calls) (ctx : Context) :
    decimalAtBody.eval calls ctx = decimalAtEquation (calls.tail ctx.text) ctx.text ctx.position := by
  dsimp +instances only [decimalAtBody, digitValue, Decimal.eval, Number.eval, Condition.eval]
  simp [decimalAtEquation, digit, Bool.or_eq_true, Bool.and_eq_true, outside_digit]
theorem literalLength_denotation (calls : Calls) (ctx : Context) :
    literalLengthBody.eval calls ctx = literalLengthEquation (calls.length ctx.text) ctx.text ctx.position := by
  dsimp +instances only [literalLengthBody, Number.eval, Condition.eval]
  simp [literalLengthEquation, Bool.and_eq_true]
theorem suffix_denotation (calls : Calls) (ctx : Context) :
    suffixBody.eval calls ctx = sourceSuffixEquation
      (calls.base.primitive.trivia ctx.text) (calls.base.output.literal ctx.text)
      (calls.base.identifier.finish ctx.text) (calls.length ctx.text) (calls.decimal ctx.text)
      (calls.base.argumentForbidden ctx.text) (calls.base.identifier.equal ctx.text)
      (calls.token ctx.text) (calls.suffix ctx.text)
      ctx.text ctx.position ctx.nextToken ⟨ctx.declaredFirst,ctx.declaredAfter⟩ ctx.capacity ctx.decorations := by
  have equality (a b : Nat) : (a == b) = decide (a = b) := by apply Bool.eq_iff_iff.mpr; simp
  dsimp +instances only [suffixBody, Number.eval, Condition.eval]
  simp [sourceSuffixEquation, tokenFor, equality]

/-- Only inherited helper bodies are source premises. The old public union
is not part of this interface. -/
structure InheritedHelpers (calls : Arguments.Expressions.Calls) : Prop where
  output : Output.Expressions.InterpretedSource calls.output calls.primitive
  letter : ∀ item, calls.letter item = Arguments.Expressions.letterBody.eval calls {text := [], item}
  forbiddenSpelling : ∀ index, calls.forbiddenSpelling index = forbiddenNames[index.val]
  token : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position token, 1 ≤ position → position ≤ text.length + 1 →
      calls.token text position token = Silver.Expressions.tokenBody.eval
        {text, position, word := token.spelling, wordFlag := token.isWord}
  tail : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position previous, 1 ≤ position → position ≤ text.length + 1 →
      calls.identifier.tail text position previous = Arguments.Expressions.tailBody.eval calls {text, position, previous}
  finish : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      calls.identifier.finish text position = Arguments.Expressions.finishBody.eval calls {text, position}
  name : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ first after word, 1 ≤ first → first < after → after ≤ text.length + 1 →
      0 < word.length → word.length ≤ maxSourceLength →
      calls.identifier.name text first after word = Arguments.Expressions.nameBody.eval calls {text, first, after, word}
  equal : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ leftFirst leftAfter rightFirst rightAfter,
      1 ≤ leftFirst → leftFirst < leftAfter → leftAfter ≤ text.length + 1 →
      1 ≤ rightFirst → rightFirst < rightAfter → rightAfter ≤ text.length + 1 →
      calls.identifier.equal text leftFirst leftAfter rightFirst rightAfter =
        Arguments.Expressions.equalBody.eval calls {text, leftFirst, leftAfter, rightFirst, rightAfter}
  forbidden : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ first after, 1 ≤ first → first < after → after ≤ text.length + 1 →
      calls.identifier.forbidden text first after = Arguments.Expressions.forbiddenBody.eval calls {text, first, after}
  argumentForbidden : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ first after, 1 ≤ first → first < after → after ≤ text.length + 1 →
      calls.argumentForbidden text first after = Arguments.Expressions.argumentForbiddenBody.eval calls {text, first, after}
  namedSuffix : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position nextToken state, 1 ≤ position → position ≤ text.length + 1 →
      1 ≤ nextToken → nextToken ≤ Named.requiredTokens.length + 1 → state.Valid text →
      calls.namedSuffix text position nextToken state =
        Named.Expressions.suffixBody.eval (Arguments.Expressions.inheritedCalls calls)
          {text, position, nextToken, declaredFirst := state.first, declaredAfter := state.after}
  suffix : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position nextToken state, 1 ≤ position → position ≤ text.length + 1 →
      1 ≤ nextToken → nextToken ≤ Arguments.requiredTokens.length + 1 → state.Valid text →
      calls.arguments.suffix text position nextToken state =
        Arguments.Expressions.suffixBody.eval calls {text, position, nextToken, declaredFirst := state.first, declaredAfter := state.after}
  concatSuffix : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position nextToken state, 1 ≤ position → position ≤ text.length + 1 →
      1 ≤ nextToken → nextToken ≤ Concat.requiredTokens.length + 1 → state.Valid text →
      calls.concatSuffix text position nextToken state =
        Concat.Expressions.suffixBody.eval (Arguments.Expressions.inheritedConcatCalls calls)
          {text, position, nextToken, declaredFirst := state.first, declaredAfter := state.after}

/-- Internal helper composition used only to apply prior refinement lemmas.
It is synthesized from the callees and is not claimed to be a current Ada body. -/
def helperCalls (calls : Arguments.Expressions.Calls) : Arguments.Expressions.Calls :=
  { calls with arguments := { calls.arguments with member := fun text => Arguments.Expressions.memberBody.eval calls { text := text } } }

theorem inherited_interpretation (calls : Arguments.Expressions.Calls)
    (source : InheritedHelpers calls) : Arguments.Expressions.InterpretedSource (helperCalls calls) where
  output := source.output
  letter := source.letter
  forbiddenSpelling := source.forbiddenSpelling
  token := source.token
  tail := source.tail
  finish := source.finish
  name := source.name
  equal := source.equal
  forbidden := source.forbidden
  argumentForbidden := source.argumentForbidden
  namedSuffix := source.namedSuffix
  suffix := source.suffix
  concatSuffix := source.concatSuffix
  member := by intro text; rfl

def assignmentCalls (calls : Calls) : Assignment.Expressions.Calls where
  base := Arguments.Expressions.inheritedConcatCalls calls.base
  length := calls.length
  suffix := calls.assignment

def branchingCalls (calls : Calls) : Branching.Expressions.Calls where
  base := helperCalls calls.base
  token := calls.branchingToken
  suffix := calls.branching

structure InterpretedSource (calls : Calls) : Prop where
  inherited : InheritedHelpers calls.base
  token : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position token, 1 ≤ position → position ≤ text.length + 1 →
      calls.token text position token = Silver.Expressions.tokenBody.eval
        {text, position, word := token.spelling, wordFlag := token.isWord}
  tail : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position value, 1 ≤ position → position ≤ text.length + 1 → value ≤ maxSourceLength →
      calls.tail text position value = decimalTailBody.eval calls {text,position,value}
  decimal : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      calls.decimal text position = decimalAtBody.eval calls {text,position}
  length : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      calls.length text position = literalLengthBody.eval calls {text,position}
  suffix : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position nextToken state capacity decorations, 1 ≤ position → position ≤ text.length + 1 →
      1 ≤ nextToken → nextToken ≤ requiredTokens.length + 1 → state.Valid text →
      capacity ≤ maxSourceLength → decorations ≤ maxSourceLength →
      calls.suffix text position nextToken state capacity decorations =
        suffixBody.eval calls { text, position, nextToken, declaredFirst := state.first, declaredAfter := state.after, capacity, decorations }
  member : ∀ text, calls.member text = memberBody.eval calls {text}
  guarded : ∀ text, calls.guarded text = guardedBody.eval calls {text}
  assignment : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position nextToken state initialLength, 1 ≤ position → position ≤ text.length + 1 →
      1 ≤ nextToken → nextToken ≤ Assignment.requiredTokens.length + 1 → state.Valid text →
      initialLength ≤ maxSourceLength →
      calls.assignment text position nextToken state initialLength =
        Assignment.Expressions.suffixBody.eval (assignmentCalls calls)
          {text,position,nextToken,declaredFirst := state.first,declaredAfter := state.after,initialLength}
  assignmentMember : ∀ text, calls.assignmentMember text = assignmentBody.eval calls {text}
  branchingToken : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position token, 1 ≤ position → position ≤ text.length + 1 →
      calls.branchingToken text position token = Silver.Expressions.tokenBody.eval
        {text, position, word := token.spelling, wordFlag := token.isWord}
  branching : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position nextToken state, 1 ≤ position → position ≤ text.length + 1 →
      1 ≤ nextToken → nextToken ≤ Branching.requiredTokens.length + 1 → state.Valid text →
      calls.branching text position nextToken state =
        Branching.Expressions.suffixBody.eval (branchingCalls calls)
          {text,position,nextToken,declaredFirst := state.first,declaredAfter := state.after}
  branchingMember : ∀ text, calls.branchingMember text = branchingBody.eval calls {text}

theorem assignment_interpretation (calls : Calls) (source : InterpretedSource calls) :
    Assignment.Expressions.InterpretedSource (assignmentCalls calls) where
  inherited := Arguments.Expressions.interpreted_concat_source (helperCalls calls.base)
    (inherited_interpretation calls.base source.inherited)
  length := by
    intro text positive bounded position first last
    rw [Assignment.Expressions.literalLength_denotation]
    exact (source.length text positive bounded position first last).trans (literalLength_denotation calls _)
  suffix := source.assignment

theorem branching_interpretation (calls : Calls) (source : InterpretedSource calls) :
    Branching.Expressions.InterpretedSource (branchingCalls calls) where
  inherited := inherited_interpretation calls.base source.inherited
  token := source.branchingToken
  suffix := source.branching

theorem interpreted_tail (calls : Calls) (source : InterpretedSource calls)
    (text : Source) (positive : 0 < text.length) (bounded : text.length ≤ maxSourceLength)
    (position value : Nat) (first : 1 ≤ position) (last : position ≤ text.length + 1)
    (valueBound : value ≤ maxSourceLength) : calls.tail text position value = decimalTail text position value := by
  apply decimalTail_unique text (calls.tail text) _ position value first last valueBound
  intro position value first last valueBound
  rw [source.tail text positive bounded position value first last valueBound, decimalTail_denotation]

theorem interpreted_length (calls : Calls) (source : InterpretedSource calls)
    (text : Source) (positive : 0 < text.length) (bounded : text.length ≤ maxSourceLength)
    (position : Nat) (first : 1 ≤ position) (last : position ≤ text.length + 1) :
    calls.length text position = literalLength text position := by
  apply literalLength_unique text (calls.length text) _ position first last
  intro position first last
  rw [source.length text positive bounded position first last, literalLength_denotation]

theorem interpreted_decimal (calls : Calls) (source : InterpretedSource calls)
    (text : Source) (positive : 0 < text.length) (bounded : text.length ≤ maxSourceLength)
    (position : Nat) (first : 1 ≤ position) (last : position ≤ text.length + 1) :
    calls.decimal text position = decimalAt text position := by
  rw [source.decimal text positive bounded position first last, decimalAt_denotation]
  change decimalAtEquation (calls.tail text) text position = decimalAt text position
  unfold decimalAtEquation decimalAt
  split
  · rfl
  · rename_i valid
    split
    · rfl
    · have valueBound : Cursor.byteAt text position - 48 ≤ maxSourceLength := by
        simp only [digit, maxSourceLength] at valid ⊢
        omega
      rw [interpreted_tail calls source text positive bounded (position + 1)
        (Cursor.byteAt text position - 48) (by omega) (by omega) valueBound]

theorem token_denotation (text : Source) (position : Nat) (token : Token)
    (last : position ≤ text.length + 1) :
    Silver.Expressions.tokenBody.eval
      {text, position, word := token.spelling, wordFlag := token.isWord} = tokenAt text position token := by
  let context : Silver.Expressions.Context := {text, position, word := token.spelling, wordFlag := token.isWord}
  have quantified := Silver.Expressions.quantified_word_denotation context
  have bound : (token.spelling.length : Int) ≤ (text.length : Int) - position + 1 ↔
      token.spelling.length ≤ text.length + 1 - position := by omega
  change Silver.Expressions.tokenBody.eval context = _
  simp only [Silver.Expressions.tokenBody, Silver.Expressions.Condition.eval]
  change (_ && (Silver.Expressions.Condition.forallWord Silver.Expressions.wordEqualityBody).eval context && _) = _
  rw [quantified]
  simp [Silver.Expressions.Number.eval, context, tokenAt, bound, ← Int.natCast_add]

theorem interpreted_suffix (calls : Calls) (source : InterpretedSource calls)
    (text : Source) (positive : 0 < text.length) (bounded : text.length ≤ maxSourceLength)
    (position nextToken : Nat) (state : NameState) (capacity decorations : Nat)
    (first : 1 ≤ position) (last : position ≤ text.length + 1)
    (start : 1 ≤ nextToken) (stop : nextToken ≤ requiredTokens.length + 1)
    (valid : state.Valid text) (capBound : capacity ≤ maxSourceLength)
    (decoBound : decorations ≤ maxSourceLength) :
    calls.suffix text position nextToken state capacity decorations =
      suffixAtIndex text position nextToken state capacity decorations := by
  apply suffixAtIndex_unique text (calls.suffix text) _ position nextToken state capacity decorations first last start stop valid capBound decoBound
  intro position nextToken state capacity decorations first last start stop valid capBound decoBound
  rw [source.suffix text positive bounded position nextToken state capacity decorations first last start stop valid capBound decoBound,
    suffix_denotation]
  have inherited := inherited_interpretation calls.base source.inherited
  have outputSource := Output.Expressions.interpreted_equations calls.base.output calls.base.primitive inherited.output
  have outputDefinitions := Output.source_equations_reduce calls.base.output calls.base.primitive outputSource
  have identifiers := Arguments.Expressions.interpreted_identifier_equations (helperCalls calls.base) inherited
  exact sourceSuffixEquation_reduce
    (calls.base.primitive.trivia text) (calls.base.output.literal text) (calls.base.identifier.finish text)
    (calls.length text) (calls.decimal text) (calls.base.argumentForbidden text)
    (calls.base.identifier.equal text) (calls.token text) (calls.suffix text) text
    (fun cursor first last => Output.primitive_trivia calls.base.primitive outputSource.primitive text positive bounded cursor first last)
    (fun cursor first last => identifier_implementation calls.base.identifier identifiers text positive bounded cursor first last)
    (fun cursor first last => Output.implementation_literal calls.base.output outputDefinitions text positive bounded cursor first last)
    (fun cursor first last => interpreted_length calls source text positive bounded cursor first last)
    (fun cursor first last => interpreted_decimal calls source text positive bounded cursor first last)
    (fun first after start ordered last => Arguments.Expressions.interpreted_argument_forbidden
      (helperCalls calls.base) inherited text positive bounded first after start ordered last)
    (fun leftFirst leftAfter rightFirst rightAfter lf lo ll rf ro rl =>
      identifiers.equal text positive bounded leftFirst leftAfter rightFirst rightAfter lf lo ll rf ro rl)
    (fun cursor token first last => (source.token text positive bounded cursor token first last).trans
      (token_denotation text cursor token last))
    position nextToken state capacity decorations first last valid

/-- Reuse only helper equations: the synthetic inherited union is an internal
composition, never identified with the current physical public function. -/
theorem interpreted_guarded (calls : Calls) (source : InterpretedSource calls)
    (text : Source) : calls.guarded text = accepts text := by
  rw [source.guarded]
  dsimp only [guardedBody, Condition.eval, Number.eval]
  have inherited := inherited_interpretation calls.base source.inherited
  have outputSource := Output.Expressions.interpreted_equations calls.base.output calls.base.primitive inherited.output
  by_cases bound : 0 < text.length ∧ text.length ≤ maxSourceLength
  · rw [outputSource.primitive.normalize text bound.2, outputSource.primitive.allowed]
    rw [interpreted_suffix calls source text bound.1 bound.2 1 1 {} 0 0
      (by omega) (by omega) (by decide) (by decide) (Or.inl ⟨rfl, rfl⟩)
      (by decide) (by decide)]
    have first : 1 ≤ text.length := by omega
    simp [accepts, suffixAtIndex, bound, first]
  · have outside : ¬ (1 ≤ text.length ∧ text.length ≤ maxSourceLength) := by omega
    simp [accepts, outside, bound]

theorem interpreted_assignment (calls : Calls) (source : InterpretedSource calls)
    (text : Source) : calls.assignmentMember text = Assignment.accepts text := by
  rw [source.assignmentMember]
  dsimp only [assignmentBody, Condition.eval, Number.eval]
  have inherited := inherited_interpretation calls.base source.inherited
  have outputSource := Output.Expressions.interpreted_equations calls.base.output calls.base.primitive inherited.output
  by_cases bound : 0 < text.length ∧ text.length ≤ maxSourceLength
  · rw [outputSource.primitive.normalize text bound.2, outputSource.primitive.allowed]
    have suffix := Assignment.Expressions.interpreted_suffix (assignmentCalls calls)
      (assignment_interpretation calls source) text bound.1 bound.2 1 1 {} 0
      (by omega) (by omega) (by decide) (by decide) (Or.inl ⟨rfl,rfl⟩) (by decide)
    change calls.assignment text 1 1 {} 0 = _ at suffix
    rw [suffix]
    have first : 1 ≤ text.length := by omega
    simp [Assignment.accepts, Assignment.suffixAtIndex, bound, first]
  · have outside : ¬ (1 ≤ text.length ∧ text.length ≤ maxSourceLength) := by omega
    simp [Assignment.accepts, outside, bound]

theorem interpreted_assignment_iff (calls : Calls) (source : InterpretedSource calls)
    (text : Source) : calls.assignmentMember text = true ↔ Assignment.Member text := by
  rw [interpreted_assignment calls source, Assignment.accepts_iff_member]

theorem interpreted_branching (calls : Calls) (source : InterpretedSource calls)
    (text : Source) : calls.branchingMember text = Branching.accepts text := by
  rw [source.branchingMember]
  dsimp only [branchingBody, Condition.eval, Number.eval]
  have inherited := inherited_interpretation calls.base source.inherited
  have outputSource := Output.Expressions.interpreted_equations calls.base.output calls.base.primitive inherited.output
  by_cases bound : 0 < text.length ∧ text.length ≤ maxSourceLength
  · rw [outputSource.primitive.normalize text bound.2, outputSource.primitive.allowed]
    have suffix := Branching.Expressions.interpreted_suffix (branchingCalls calls)
      (branching_interpretation calls source) text bound.1 bound.2 1 1 {}
      (by omega) (by omega) (by decide) (by decide) (Or.inl ⟨rfl,rfl⟩)
    change calls.branching text 1 1 {} = _ at suffix
    rw [suffix]
    have first : 1 ≤ text.length := by omega
    simp [Branching.accepts, Branching.suffixAtIndex, bound, first]
  · have outside : ¬ (1 ≤ text.length ∧ text.length ≤ maxSourceLength) := by omega
    simp [Branching.accepts, outside, bound]

theorem interpreted_branching_iff (calls : Calls) (source : InterpretedSource calls)
    (text : Source) : calls.branchingMember text = true ↔ Branching.Member text := by
  rw [interpreted_branching calls source, Branching.accepts_iff_member]

theorem public_union (calls : Calls) (source : InterpretedSource calls)
    (text : Source) : calls.member text =
      ((((helperCalls calls.base).arguments.member text || calls.guarded text) || calls.assignmentMember text) || calls.branchingMember text) := by
  rw [source.member, source.guarded, source.assignmentMember, source.branchingMember]
  apply Bool.eq_iff_iff.mpr
  simp only [memberBody, guardedBody, assignmentBody, branchingBody, Condition.eval, Number.eval, helperCalls,
    Arguments.Expressions.memberBody, Arguments.Expressions.Condition.eval,
    Arguments.Expressions.Number.eval, Bool.or_eq_true, Bool.and_eq_true,
    and_or_left]
  rfl

theorem interpreted_guarded_iff (calls : Calls) (source : InterpretedSource calls)
    (text : Source) : calls.guarded text = true ↔ Member text := by
  rw [interpreted_guarded calls source, accepts_iff_member]

theorem interpreted_member_iff (calls : Calls) (source : InterpretedSource calls)
    (text : Source) : calls.member text = true ↔
      Output.Member text ∨ Named.Member text ∨ Arguments.Member text ∨ Concat.Member text ∨ Member text ∨ Assignment.Member text ∨ Branching.Member text := by
  rw [public_union calls source]
  have inherited := inherited_interpretation calls.base source.inherited
  simp only [Bool.or_eq_true]
  rw [Arguments.implementation_member_iff _
    (Arguments.Expressions.interpreted_equations (helperCalls calls.base) inherited),
    interpreted_guarded_iff calls source, interpreted_assignment_iff calls source, interpreted_branching_iff calls source]
  simp only [or_assoc]

/-- A concrete interpretation witnesses that the displayed frontend premises
are consistent. The public Booleans are compositions of independently defined
helper functions, rather than additional assumptions about the language. -/
def modelHelpers : Calls where
  base := Arguments.Expressions.modelCalls
  tail := decimalTail
  decimal := decimalAt
  length := literalLength
  suffix := suffixAtIndex
  token := tokenAt
  member := fun _ => false
  guarded := fun _ => false
  assignment := Assignment.suffixAtIndex
  assignmentMember := fun _ => false
  branching := Branching.suffixAtIndex
  branchingToken := Branching.tokenAt
  branchingMember := fun _ => false

def modelCalls : Calls :=
  { modelHelpers with member := fun text => memberBody.eval modelHelpers {text}, guarded := fun text => guardedBody.eval modelHelpers {text}, assignmentMember := fun text => assignmentBody.eval modelHelpers {text}, branchingMember := fun text => branchingBody.eval modelHelpers {text} }

set_option maxHeartbeats 1000000 in
theorem model_interpreted : InterpretedSource modelCalls where
  inherited := {
    output := Arguments.Expressions.model_interpreted.output
    letter := Arguments.Expressions.model_interpreted.letter
    forbiddenSpelling := Arguments.Expressions.model_interpreted.forbiddenSpelling
    token := Arguments.Expressions.model_interpreted.token
    tail := Arguments.Expressions.model_interpreted.tail
    finish := Arguments.Expressions.model_interpreted.finish
    name := Arguments.Expressions.model_interpreted.name
    equal := Arguments.Expressions.model_interpreted.equal
    forbidden := Arguments.Expressions.model_interpreted.forbidden
    argumentForbidden := Arguments.Expressions.model_interpreted.argumentForbidden
    namedSuffix := Arguments.Expressions.model_interpreted.namedSuffix
    suffix := Arguments.Expressions.model_interpreted.suffix
    concatSuffix := Arguments.Expressions.model_interpreted.concatSuffix }
  token := by
    intro text _ _ position token _ last
    exact (token_denotation text position token last).symm
  tail := by
    intro text _ _ position value _ _ _
    rw [decimalTail_denotation]
    exact decimalTail_equation text position value
  decimal := by
    intro text _ _ position _ _
    rw [decimalAt_denotation]
    rfl
  length := by
    intro text _ _ position _ _
    rw [literalLength_denotation]
    exact literalLength_equation text position
  suffix := by
    intro text _ _ position nextToken state capacity decorations first last start _ valid _ _
    rw [suffix_denotation]
    change suffixAtIndex text position nextToken state capacity decorations = _
    rw [suffixAtIndex_equation text position nextToken state capacity decorations start]
    exact (sourceSuffixEquation_reduce _ _ _ _ _ _ _ _ _ text
      (fun _ _ _ => rfl) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
      (fun _ _ _ => rfl) (fun _ _ _ => rfl) (fun _ _ _ _ _ => rfl)
      (fun _ _ _ _ _ _ _ _ _ _ => rfl) (fun _ _ _ _ => rfl)
      position nextToken state capacity decorations first last valid).symm
  member := by intro text; rfl
  guarded := by intro text; rfl
  assignment := by
    intro text positive bounded position nextToken state initialLength first last start stop valid lengthBound
    rw [Assignment.Expressions.suffix_denotation]
    change Assignment.suffixAtIndex text position nextToken state initialLength = _
    rw [Assignment.suffixAtIndex_equation text position nextToken state initialLength start]
    exact (Assignment.sourceSuffixEquation_reduce _ _ _ _ _ _ _ _ text
      (fun _ _ _ => rfl) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
      (fun _ _ _ => rfl) (fun _ _ _ _ _ => rfl)
      (fun _ _ _ _ _ _ _ _ _ _ => rfl)
      (fun position token _ _ => by
        change Arguments.tokenAt text position (Arguments.Expressions.embedNamedToken token) = Named.tokenAt text position token
        cases token <;> rfl)
      position nextToken state initialLength first last valid).symm
  assignmentMember := by intro text; rfl
  branchingToken := by
    intro text _ _ position token _ last
    exact (Branching.Expressions.token_denotation text position token last).symm
  branching := by
    intro text _ _ position nextToken state first last start _ valid
    rw [Branching.Expressions.suffix_denotation]
    change Branching.suffixAtIndex text position nextToken state = _
    rw [Branching.suffixAtIndex_equation text position nextToken state start]
    exact (Branching.sourceSuffixEquation_reduce _ _ _ _ _ _ _ text
      (fun _ _ _ => rfl) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
      (fun _ _ _ _ _ => rfl) (fun _ _ _ _ _ _ _ _ _ _ => rfl)
      (fun _ _ _ _ => rfl) position nextToken state first last valid).symm
  branchingMember := by intro text; rfl

end Silver.Guarded.Expressions
