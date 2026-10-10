import Silver.BranchingEquations
import Silver.ArgumentsExpressions

/-! Typed expressions for input-dependent branching recognition. Shared identifier
and literal callees keep their existing checked interpretations; the new suffix
remains arbitrary until recursive uniqueness closes it on its SPARK domains. -/

set_option linter.constructorNameAsVariable false
namespace Silver.Branching.Expressions
open Named

structure Calls where
  base : Arguments.Expressions.Calls
  token : Source → Nat → Token → Bool
  suffix : Source → Nat → Nat → NameState → Bool

structure Context where
  text : Source
  position : Nat := 1
  nextToken : Nat := 1
  declaredFirst : Nat := 0
  declaredAfter : Nat := 0

mutual
inductive Number
  | constant (value : Nat) | character (value : Nat) | characterVal (value : Number)
  | position | last | nextToken | tokenLast | declaredFirst | declaredAfter
  | add (left right : Number) | group (value : Number)
  | byteAt (position : Number) | finish (position : Number)
  | literal (position : Number) | trivia (position : Number)
  | spellingLength (index : Number)
  | ite (condition : Condition) (yes no : Number) | elsif (condition : Condition) (yes no : Number)
  deriving DecidableEq, Repr
inductive Condition
  | eq (left right : Number) | ne (left right : Number)
  | lt (left right : Number) | le (left right : Number) | gt (left right : Number)
  | range (value first last : Number)
  | andThen (left right : Condition) | not (value : Condition) | group (value : Condition)
  | forbidden (first after : Number) | equal (leftFirst leftAfter rightFirst rightAfter : Number)
  | tokenEq (index : Number) (token : Token) | tokenAt (position index : Number)
  | suffix (position index first after : Number)
  | ite (condition yes no : Condition) | elsif (condition yes no : Condition)
  deriving DecidableEq, Repr
end

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
  | .ampersand => "ampersand" | .equal => "equal"
  | .argumentsName => "arguments_name" | .firstOrDefaultName => "first_or_default_name"
  | .ifKeyword => "if_keyword" | .inputIsValidName => "input_is_valid_name"
  | .thenKeyword => "then_keyword" | .elseKeyword => "else_keyword" | .rejectName => "reject_name"

def tokenFor (index : Nat) : Token := requiredTokens.getD (index - 1) (.base .semicolon)
mutual
def Number.render : Number → List String
  | .constant n => [toString n]
  | .character n => [String.ofList ['\'', Char.ofNat n, '\'']]
  | .characterVal a => ["character", "'", "val", "("] ++ a.render ++ [")"]
  | .position => ["position"] | .last => ["text", "'", "last"]
  | .nextToken => ["next_token"] | .tokenLast => ["branching_required_tokens", "'", "last"]
  | .declaredFirst => ["declared_first"] | .declaredAfter => ["declared_after"]
  | .add a b => a.render ++ ["+"] ++ b.render | .group a => ["("] ++ a.render ++ [")"]
  | .byteAt a => call "text" [a.render]
  | .finish a => call "identifier_end" [["text"],a.render]
  | .literal a => call "literal_end" [["text"],a.render]
  | .trivia a => call "trivia_end" [["text"],a.render]
  | .spellingLength a => call "spelling" [call "branching_required_tokens" [a.render]] ++ ["'", "length"]
  | .ite c a b => ["if"] ++ c.render ++ ["then"] ++ a.render ++ (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
  | .elsif c a b => ["elsif"] ++ c.render ++ ["then"] ++ a.render ++ (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
def Condition.render : Condition → List String
  | .eq a b => a.render ++ ["="] ++ b.render | .ne a b => a.render ++ ["/="] ++ b.render
  | .lt a b => a.render ++ ["<"] ++ b.render | .le a b => a.render ++ ["<="] ++ b.render
  | .gt a b => a.render ++ [">"] ++ b.render
  | .range a b c => a.render ++ ["in"] ++ b.render ++ [".."] ++ c.render
  | .andThen a b => a.render ++ ["and", "then"] ++ b.render
  | .not a => ["not"] ++ a.render | .group a => ["("] ++ a.render ++ [")"]
  | .forbidden a b => call "forbidden_argument_name" [["text"],a.render,b.render]
  | .equal a b c d => call "equal_name" [["text"],a.render,b.render,c.render,d.render]
  | .tokenEq i t => call "branching_required_tokens" [i.render] ++ ["=",tokenName t]
  | .tokenAt p i => call "token_at" [["text"],p.render,call "spelling" [call "branching_required_tokens" [i.render]],call "is_word_token" [call "branching_required_tokens" [i.render]]]
  | .suffix p i a b => call "branching_suffix_matches" [["text"],p.render,i.render,a.render,b.render]
  | .ite c a b => ["if"] ++ c.render ++ ["then"] ++ a.render ++ (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
  | .elsif c a b => ["elsif"] ++ c.render ++ ["then"] ++ a.render ++ (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
end

def Number.primary : Number → Bool | .add _ _ | .ite _ _ _ | .elsif _ _ _ => false | _ => true
def Number.simple : Number → Bool | .ite _ _ _ | .elsif _ _ _ => false | _ => true
def Number.isElsif : Number → Bool | .elsif _ _ _ => true | _ => false
def Condition.primary : Condition → Bool
  | .group _ | .forbidden _ _ | .equal _ _ _ _ | .tokenAt _ _ | .suffix _ _ _ _ => true | _ => false
def Condition.relation : Condition → Bool
  | .andThen _ _ | .ite _ _ _ | .elsif _ _ _ => false | _ => true
def Condition.logical : Condition → Bool | .ite _ _ _ | .elsif _ _ _ => false | _ => true
def Condition.isElsif : Condition → Bool | .elsif _ _ _ => true | _ => false
def Condition.andLeft : Condition → Bool | .andThen _ _ => true | c => c.relation
mutual
def Number.wellFormed : Number → Bool
  | .add a b => a.wellFormed && b.wellFormed && a.simple && b.primary
  | .group a => a.wellFormed && !a.isElsif
  | .byteAt a | .finish a | .literal a | .trivia a | .spellingLength a | .characterVal a => a.wellFormed && a.simple
  | .ite c a b | .elsif c a b => c.wellFormed && c.logical && a.wellFormed && a.simple && b.wellFormed && (b.simple || b.isElsif)
  | _ => true
def Condition.wellFormed : Condition → Bool
  | .eq a b | .ne a b | .lt a b | .le a b | .gt a b => a.wellFormed && b.wellFormed && a.simple && b.simple
  | .range a b c => a.wellFormed && b.wellFormed && c.wellFormed && a.simple && b.simple && c.simple
  | .andThen a b => a.wellFormed && b.wellFormed && a.andLeft && b.relation
  | .not a => a.wellFormed && a.primary | .group a => a.wellFormed && !a.isElsif
  | .tokenEq a _ => a.wellFormed && a.simple
  | .forbidden a b | .tokenAt a b => a.wellFormed && b.wellFormed && a.simple && b.simple
  | .equal a b c d => a.wellFormed && b.wellFormed && c.wellFormed && d.wellFormed && a.simple && b.simple && c.simple && d.simple
  | .suffix a b c d => a.wellFormed && b.wellFormed && c.wellFormed && d.wellFormed && a.simple && b.simple && c.simple && d.simple
  | .ite c a b | .elsif c a b => c.wellFormed && c.logical && a.wellFormed && a.logical && b.wellFormed && (b.logical || b.isElsif)
end
mutual
def Number.eval (calls : Calls) (ctx : Context) : Number → Nat
  | .constant n | .character n => n | .characterVal a | .group a => a.eval calls ctx
  | .position => ctx.position | .last => ctx.text.length | .nextToken => ctx.nextToken
  | .tokenLast => requiredTokens.length | .declaredFirst => ctx.declaredFirst
  | .declaredAfter => ctx.declaredAfter
  | .add a b => a.eval calls ctx + b.eval calls ctx
  | .byteAt a => Cursor.byteAt ctx.text (a.eval calls ctx)
  | .finish a => calls.base.identifier.finish ctx.text (a.eval calls ctx)
  | .literal a => calls.base.output.literal ctx.text (a.eval calls ctx)
  | .trivia a => calls.base.primitive.trivia ctx.text (a.eval calls ctx)
  | .spellingLength a => (tokenFor (a.eval calls ctx)).spelling.length
  | .ite c a b | .elsif c a b => if c.eval calls ctx then a.eval calls ctx else b.eval calls ctx
def Condition.eval (calls : Calls) (ctx : Context) : Condition → Bool
  | .eq a b => a.eval calls ctx == b.eval calls ctx | .ne a b => !(a.eval calls ctx == b.eval calls ctx)
  | .lt a b => decide (a.eval calls ctx < b.eval calls ctx) | .le a b => decide (a.eval calls ctx ≤ b.eval calls ctx)
  | .gt a b => decide (a.eval calls ctx > b.eval calls ctx)
  | .range a b c => decide (b.eval calls ctx ≤ a.eval calls ctx ∧ a.eval calls ctx ≤ c.eval calls ctx)
  | .andThen a b => a.eval calls ctx && b.eval calls ctx
  | .not a => !a.eval calls ctx | .group a => a.eval calls ctx
  | .forbidden a b => calls.base.argumentForbidden ctx.text (a.eval calls ctx) (b.eval calls ctx)
  | .equal a b c d => calls.base.identifier.equal ctx.text (a.eval calls ctx) (b.eval calls ctx) (c.eval calls ctx) (d.eval calls ctx)
  | .tokenEq i t => tokenFor (i.eval calls ctx) == t
  | .tokenAt p i => calls.token ctx.text (p.eval calls ctx) (tokenFor (i.eval calls ctx))
  | .suffix p i a b => calls.suffix ctx.text (p.eval calls ctx) (i.eval calls ctx) ⟨a.eval calls ctx,b.eval calls ctx⟩
  | .ite c a b | .elsif c a b => if c.eval calls ctx then a.eval calls ctx else b.eval calls ctx
end

def suffixBody : Condition :=
  let start := Number.trivia .position
  let finish := Number.finish start
  let next := Number.add .nextToken (.constant 1)
  .ite (.gt .nextToken .tokenLast) (.eq start (.add .last (.constant 1)))
    (.elsif (.tokenEq .nextToken .declarationName)
      (.andThen (.andThen (.ne finish (.constant 0)) (.not (.forbidden start finish)))
        (.suffix finish next start finish))
      (.elsif (.tokenEq .nextToken .referenceName)
        (.andThen (.andThen (.andThen (.gt .declaredFirst (.constant 0)) (.ne finish (.constant 0)))
          (.equal .declaredFirst .declaredAfter start finish))
          (.suffix finish next .declaredFirst .declaredAfter))
        (.elsif (.tokenEq .nextToken (.base .stringLiteral))
          (.andThen (.andThen (.andThen (.le start .last)
            (.eq (.byteAt start) (.characterVal (.constant 34))))
            (.ne (.literal (.add start (.constant 1))) (.constant 0)))
            (.suffix (.literal (.add start (.constant 1))) next .declaredFirst .declaredAfter))
          (.andThen (.tokenAt start .nextToken)
            (.suffix (.add start (.spellingLength .nextToken)) next .declaredFirst .declaredAfter)))))

abbrev WellFormedTrees : Prop := suffixBody.wellFormed = true
theorem checked_precedence : WellFormedTrees := by decide +kernel

theorem suffix_denotation (calls : Calls) (ctx : Context) :
    suffixBody.eval calls ctx = sourceSuffixEquation
      (calls.base.primitive.trivia ctx.text) (calls.base.output.literal ctx.text)
      (calls.base.identifier.finish ctx.text) (calls.base.argumentForbidden ctx.text)
      (calls.base.identifier.equal ctx.text) (calls.token ctx.text) (calls.suffix ctx.text)
      ctx.text ctx.position ctx.nextToken ⟨ctx.declaredFirst,ctx.declaredAfter⟩ := by
  have equality (a b : Nat) : (a == b) = decide (a = b) := by apply Bool.eq_iff_iff.mpr; simp
  dsimp +instances only [suffixBody, Number.eval, Condition.eval]
  simp [sourceSuffixEquation, tokenFor, equality]

structure InterpretedSource (calls : Calls) : Prop where
  inherited : Arguments.Expressions.InterpretedSource calls.base
  token : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position token, 1 ≤ position → position ≤ text.length + 1 →
      calls.token text position token = Silver.Expressions.tokenBody.eval
        {text, position, word := token.spelling, wordFlag := token.isWord}
  suffix : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position nextToken state, 1 ≤ position → position ≤ text.length + 1 →
      1 ≤ nextToken → nextToken ≤ requiredTokens.length + 1 → state.Valid text →
      calls.suffix text position nextToken state =
        suffixBody.eval calls {text,position,nextToken,declaredFirst := state.first,declaredAfter := state.after}

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
    (position nextToken : Nat) (state : NameState)
    (first : 1 ≤ position) (last : position ≤ text.length + 1)
    (start : 1 ≤ nextToken) (stop : nextToken ≤ requiredTokens.length + 1)
    (valid : state.Valid text) :
    calls.suffix text position nextToken state = suffixAtIndex text position nextToken state := by
  apply suffixAtIndex_unique text (calls.suffix text) _ position nextToken state first last start stop valid
  intro position nextToken state first last start stop valid
  rw [source.suffix text positive bounded position nextToken state first last start stop valid,
    suffix_denotation]
  have outputSource := Output.Expressions.interpreted_equations calls.base.output calls.base.primitive source.inherited.output
  have outputDefinitions := Output.source_equations_reduce calls.base.output calls.base.primitive outputSource
  have identifiers := Arguments.Expressions.interpreted_identifier_equations calls.base source.inherited
  exact sourceSuffixEquation_reduce
    (calls.base.primitive.trivia text) (calls.base.output.literal text) (calls.base.identifier.finish text)
    (calls.base.argumentForbidden text) (calls.base.identifier.equal text)
    (calls.token text) (calls.suffix text) text
    (fun cursor first last => Output.primitive_trivia calls.base.primitive outputSource.primitive text positive bounded cursor first last)
    (fun cursor first last => identifier_implementation calls.base.identifier identifiers text positive bounded cursor first last)
    (fun cursor first last => Output.implementation_literal calls.base.output outputDefinitions text positive bounded cursor first last)
    (fun first after start ordered last => Arguments.Expressions.interpreted_argument_forbidden
      calls.base source.inherited text positive bounded first after start ordered last)
    (fun leftFirst leftAfter rightFirst rightAfter lf lo ll rf ro rl =>
      identifiers.equal text positive bounded leftFirst leftAfter rightFirst rightAfter lf lo ll rf ro rl)
    (fun cursor token first last => (source.token text positive bounded cursor token first last).trans
      (token_denotation text cursor token last))
    position nextToken state first last valid

def modelCalls : Calls where
  base := Arguments.Expressions.modelCalls
  token := tokenAt
  suffix := suffixAtIndex

theorem model_interpreted : InterpretedSource modelCalls where
  inherited := Arguments.Expressions.model_interpreted
  token := by
    intro text _ _ position token _ last
    exact (token_denotation text position token last).symm
  suffix := by
    intro text _ _ position nextToken state first last start _ valid
    rw [suffix_denotation]
    change suffixAtIndex text position nextToken state = _
    rw [suffixAtIndex_equation text position nextToken state start]
    exact (sourceSuffixEquation_reduce _ _ _ _ _ _ _ text
      (fun _ _ _ => rfl) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
      (fun _ _ _ _ _ => rfl) (fun _ _ _ _ _ _ _ _ _ _ => rfl)
      (fun _ _ _ _ => rfl) position nextToken state first last valid).symm

end Silver.Branching.Expressions
