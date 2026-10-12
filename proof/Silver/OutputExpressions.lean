module

public import Silver.OutputEquations
public import Silver.RecursiveBridge

@[expose] public section

/-! Typed syntax for the two new authoritative expression functions. The same
trees render the checked Ada tokens and interpret the recursive definition
equations. Explicit groups and elsif nodes preserve Ada source precedence. -/

set_option linter.constructorNameAsVariable false

namespace Silver.Output.Expressions

mutual
inductive Number
  | constant (value : Nat) | character (value : Nat) | characterVal (value : Number)
  | position | last | nextToken | tokenLast
  | add (left right : Number) | group (value : Number)
  | byteAt (position : Number) | literal (position : Number) | trivia (position : Number)
  | spellingLength (index : Number)
  | ite (condition : Condition) (yes no : Number)
  | elsif (condition : Condition) (yes no : Number)
  deriving DecidableEq, Repr
inductive Condition
  | eq (left right : Number) | ne (left right : Number)
  | lt (left right : Number) | le (left right : Number) | gt (left right : Number)
  | range (value first last : Number)
  | andThen (left right : Condition)
  | literalToken (index : Number) | tokenAt (position index : Number)
  | suffix (position index : Number)
  | ite (condition yes no : Condition) | elsif (condition yes no : Condition)
  deriving DecidableEq, Repr
end

def call := Silver.Expressions.call

mutual
def Number.render : Number → List String
  | .constant value => [toString value]
  | .character value => [String.ofList ['\'', Char.ofNat value, '\'']]
  | .characterVal value => ["character", "'", "val", "("] ++ value.render ++ [")"]
  | .position => ["position"] | .last => ["text", "'", "last"]
  | .nextToken => ["next_token"] | .tokenLast => ["required_tokens", "'", "last"]
  | .add left right => left.render ++ ["+"] ++ right.render
  | .group value => ["("] ++ value.render ++ [")"]
  | .byteAt position => call "text" [position.render]
  | .literal position => call "literal_end" [["text"], position.render]
  | .trivia position => call "trivia_end" [["text"], position.render]
  | .spellingLength index =>
      call "spelling" [call "required_tokens" [index.render]] ++ ["'", "length"]
  | .ite condition yes no =>
      ["if"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .elsif condition yes no =>
      ["elsif"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
def Condition.render : Condition → List String
  | .eq left right => left.render ++ ["="] ++ right.render
  | .ne left right => left.render ++ ["/="] ++ right.render
  | .lt left right => left.render ++ ["<"] ++ right.render
  | .le left right => left.render ++ ["<="] ++ right.render
  | .gt left right => left.render ++ [">"] ++ right.render
  | .range value first last => value.render ++ ["in"] ++ first.render ++ [".."] ++ last.render
  | .andThen left right => left.render ++ ["and", "then"] ++ right.render
  | .literalToken index => call "required_tokens" [index.render] ++ ["=", "string_literal"]
  | .tokenAt position index => call "token_at" [["text"], position.render,
      call "spelling" [call "required_tokens" [index.render]],
      call "is_word_token" [call "required_tokens" [index.render]]]
  | .suffix position index => call "suffix_matches" [["text"], position.render, index.render]
  | .ite condition yes no =>
      ["if"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .elsif condition yes no =>
      ["elsif"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
end

/-- Ada grammar categories prevent the token renderer from silently changing
precedence. Groups in a tree must be present in the checked source itself. -/
def Number.primary : Number → Bool
  | .add _ _ | .ite _ _ _ | .elsif _ _ _ => false
  | _ => true

def Number.simple : Number → Bool
  | .ite _ _ _ | .elsif _ _ _ => false
  | _ => true

def Number.isElsif : Number → Bool
  | .elsif _ _ _ => true
  | _ => false

def Condition.primary : Condition → Bool
  | .tokenAt _ _ | .suffix _ _ => true
  | _ => false

def Condition.relation : Condition → Bool
  | .andThen _ _ | .ite _ _ _ | .elsif _ _ _ => false
  | _ => true

def Condition.logical : Condition → Bool
  | .ite _ _ _ | .elsif _ _ _ => false
  | _ => true

def Condition.isElsif : Condition → Bool
  | .elsif _ _ _ => true
  | _ => false

def Condition.andLeft : Condition → Bool
  | .andThen _ _ => true
  | value => value.relation


mutual
def Number.wellFormed : Number → Bool
  | .add left right => left.wellFormed && right.wellFormed && left.simple && right.primary
  | .byteAt value | .characterVal value | .literal value | .trivia value | .spellingLength value =>
      value.wellFormed && value.simple
  | .group value => value.wellFormed && !value.isElsif
  | .ite condition yes no | .elsif condition yes no =>
      condition.wellFormed && condition.logical && yes.wellFormed && yes.simple &&
      no.wellFormed && (no.simple || no.isElsif)
  | _ => true

def Condition.wellFormed : Condition → Bool
  | .eq left right | .ne left right | .lt left right | .le left right | .gt left right =>
      left.wellFormed && right.wellFormed && left.simple && right.simple
  | .range value first last =>
      value.wellFormed && first.wellFormed && last.wellFormed && value.simple && first.simple && last.simple
  | .andThen left right => left.wellFormed && right.wellFormed && left.andLeft && right.relation
  | .literalToken index => index.wellFormed && index.simple
  | .tokenAt position index | .suffix position index =>
      position.wellFormed && index.wellFormed && position.simple && index.simple
  | .ite condition yes no | .elsif condition yes no =>
      condition.wellFormed && condition.logical && yes.wellFormed && yes.logical &&
      no.wellFormed && (no.logical || no.isElsif)
end


structure Context where
  text : Source
  position : Nat := 1
  nextToken : Nat := 1

def tokenFor (index : Nat) : Token := requiredTokens.getD (index - 1) .semicolon

mutual
def Number.eval (calls : Calls) (primitives : PrimitiveCalls) (context : Context) : Number → Nat
  | .constant value | .character value => value
  | .characterVal value | .group value => value.eval calls primitives context
  | .position => context.position | .last => context.text.length
  | .nextToken => context.nextToken | .tokenLast => requiredTokens.length
  | .add left right => left.eval calls primitives context + right.eval calls primitives context
  | .byteAt position => Cursor.byteAt context.text (position.eval calls primitives context)
  | .literal position => calls.literal context.text (position.eval calls primitives context)
  | .trivia position => primitives.trivia context.text (position.eval calls primitives context)
  | .spellingLength index => (tokenFor (index.eval calls primitives context)).spelling.length
  | .ite condition yes no | .elsif condition yes no =>
      if condition.eval calls primitives context then yes.eval calls primitives context
      else no.eval calls primitives context
def Condition.eval (calls : Calls) (primitives : PrimitiveCalls) (context : Context) : Condition → Bool
  | .eq left right => left.eval calls primitives context == right.eval calls primitives context
  | .ne left right => !(left.eval calls primitives context == right.eval calls primitives context)
  | .lt left right => decide (left.eval calls primitives context < right.eval calls primitives context)
  | .le left right => decide (left.eval calls primitives context ≤ right.eval calls primitives context)
  | .gt left right => decide (left.eval calls primitives context > right.eval calls primitives context)
  | .range value first last => decide (first.eval calls primitives context ≤ value.eval calls primitives context ∧
      value.eval calls primitives context ≤ last.eval calls primitives context)
  | .andThen left right => left.eval calls primitives context && right.eval calls primitives context
  | .literalToken index => tokenFor (index.eval calls primitives context) == .stringLiteral
  | .tokenAt position index => primitives.token context.text
      (position.eval calls primitives context) (tokenFor (index.eval calls primitives context))
  | .suffix position index => calls.suffix context.text
      (position.eval calls primitives context) (index.eval calls primitives context)
  | .ite condition yes no | .elsif condition yes no =>
      if condition.eval calls primitives context then yes.eval calls primitives context
      else no.eval calls primitives context
end

def literalBody : Number :=
  .ite (.gt .position .last) (.constant 0)
    (.elsif (.eq (.byteAt .position) (.characterVal (.constant 34)))
      (.group (.ite (.andThen (.lt .position .last)
        (.eq (.byteAt (.add .position (.constant 1))) (.characterVal (.constant 34))))
        (.literal (.add .position (.constant 2))) (.add .position (.constant 1))))
      (.elsif (.range (.byteAt .position) (.character 32) (.character 126))
        (.literal (.add .position (.constant 1))) (.constant 0)))

def suffixBody : Condition :=
  .ite (.gt .nextToken .tokenLast)
    (.eq (.trivia .position) (.add .last (.constant 1)))
    (.elsif (.literalToken .nextToken)
      (.andThen (.andThen (.andThen (.le (.trivia .position) .last)
        (.eq (.byteAt (.trivia .position)) (.characterVal (.constant 34))))
        (.ne (.literal (.add (.trivia .position) (.constant 1))) (.constant 0)))
        (.suffix (.literal (.add (.trivia .position) (.constant 1))) (.add .nextToken (.constant 1))))
      (.andThen (.tokenAt (.trivia .position) .nextToken)
        (.suffix (.add (.trivia .position) (.spellingLength .nextToken)) (.add .nextToken (.constant 1)))))


abbrev WellFormedTrees : Prop :=
  literalBody.wellFormed = true ∧
  suffixBody.wellFormed = true

theorem checked_precedence : WellFormedTrees := by decide +kernel

theorem literal_denotation (calls : Calls) (primitives : PrimitiveCalls) (context : Context) :
    literalBody.eval calls primitives context =
      literalEquation (calls.literal context.text) context.text context.position := by
  dsimp +instances only [literalBody, Number.eval, Condition.eval]
  simp [literalEquation, printable, Bool.and_eq_true]

theorem suffix_denotation (calls : Calls) (primitives : PrimitiveCalls) (context : Context) :
    suffixBody.eval calls primitives context =
      suffixEquation (primitives.trivia context.text) (calls.literal context.text)
        (primitives.token context.text) (calls.suffix context.text) context.text
        context.position context.nextToken := by
  have equal (a b : Nat) : (a == b) = decide (a = b) := by
    apply Bool.eq_iff_iff.mpr
    simp
  dsimp +instances only [suffixBody, Number.eval, Condition.eval]
  simp [suffixEquation, tokenFor, equal]

def memberCalls (calls : Calls) (primitives : PrimitiveCalls) : Silver.Expressions.Calls where
  comment := primitives.comment
  trivia := primitives.trivia
  token := fun _ _ _ => false
  suffix := calls.suffix
  normalize := primitives.normalize
  allowed := primitives.allowed
  member := calls.member

structure PrimitiveInterpretation (calls : Calls) (primitives : PrimitiveCalls) : Prop where
  comment : ∀ text, 0 < text.length → text.length ≤ 4096 →
    ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      (primitives.comment text position : Int) = Silver.Expressions.commentBody.evalWith
        (memberCalls calls primitives) {text, position}
  trivia : ∀ text, 0 < text.length → text.length ≤ 4096 →
    ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      (primitives.trivia text position : Int) = Silver.Expressions.triviaBody.evalWith
        (memberCalls calls primitives) {text, position}
  token : ∀ text, 0 < text.length → text.length ≤ 4096 → ∀ position token,
    1 ≤ position → position ≤ text.length + 1 →
    primitives.token text position token = Silver.Expressions.tokenBody.eval
      {text, position, word := token.spelling, wordFlag := token.isWord}
  normalize : ∀ text, text.length ≤ 4096 → primitives.normalize text = text
  allowed : ∀ text, primitives.allowed text = Silver.Expressions.allowedBody.evalWith
    (memberCalls calls primitives) {text}

theorem primitive_interpreted_equations (calls : Calls) (primitives : PrimitiveCalls)
    (source : PrimitiveInterpretation calls primitives) : PrimitiveEquations primitives where
  comment := by
    intro text positive bounded position first last
    have equation := source.comment text positive bounded position first last
    apply Int.ofNat.inj
    simpa [Silver.Expressions.commentBody, Silver.Expressions.Number.evalWith,
      Silver.Expressions.Condition.evalWith, Silver.Expressions.cast_conditional,
      Bool.or_eq_true, ← Int.natCast_add, memberCalls] using equation
  trivia := by
    intro text positive bounded position first last
    have equation := source.trivia text positive bounded position first last
    have character (value : Nat) : (value : Int) = 45 ↔ value = 45 := by omega
    have two : ((position : Int) + 2).toNat = position + 2 := by omega
    apply Int.ofNat.inj
    simpa [Silver.Expressions.triviaBody, Silver.Expressions.Number.evalWith,
      Silver.Expressions.Condition.evalWith, Silver.Expressions.cast_conditional,
      Bool.and_eq_true, and_assoc, ← Int.natCast_add, Cursor.byteAt, character, two,
      memberCalls] using equation
  token := source.token
  normalize := source.normalize
  allowed := by
    intro text
    rw [source.allowed]
    simp [Silver.Expressions.allowedBody, Silver.Expressions.Condition.evalWith,
      Silver.Expressions.Number.evalWith]

/-- The two new ASTs and the existing member AST, with arbitrary callees.
Primitive equations refer to independently checked copied lexical bodies. -/
structure InterpretedSource (calls : Calls) (primitives : PrimitiveCalls) : Prop where
  primitive : PrimitiveInterpretation calls primitives
  literal : ∀ text, 0 < text.length → text.length ≤ 4096 →
    ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      calls.literal text position = literalBody.eval calls primitives {text, position}
  suffix : ∀ text, 0 < text.length → text.length ≤ 4096 →
    ∀ position nextToken, 1 ≤ position → position ≤ text.length + 1 →
      1 ≤ nextToken → nextToken ≤ requiredTokens.length + 1 →
      calls.suffix text position nextToken = suffixBody.eval calls primitives {text, position, nextToken}
  member : ∀ text, calls.member text =
    Silver.Expressions.memberBody.evalWith (memberCalls calls primitives) {text}

theorem interpreted_equations (calls : Calls) (primitives : PrimitiveCalls)
    (source : InterpretedSource calls primitives) : SourceEquations calls primitives where
  primitive := primitive_interpreted_equations calls primitives source.primitive
  literal := by
    intro text positive bounded position first last
    exact (source.literal text positive bounded position first last).trans
      (literal_denotation calls primitives _)
  suffix := by
    intro text positive bounded position nextToken first last start stop
    exact (source.suffix text positive bounded position nextToken first last start stop).trans
      (suffix_denotation calls primitives _)
  member := by
    intro text
    rw [source.member]
    have length : (1 : Int) ≤ text.length ↔ 0 < text.length := by omega
    simp [Silver.Expressions.memberBody, Silver.Expressions.Condition.evalWith,
      Silver.Expressions.Number.evalWith, memberCalls, length]

/-- Concrete inhabitation witness; actual-source interpretation still requires
reviewed frontend semantics and verified machine bounds. -/
def modelCalls : Calls where
  literal := literalEnd
  suffix := suffixAtIndex
  member := accepts

def modelPrimitives : PrimitiveCalls where
  comment := Cursor.commentPosition
  trivia := Cursor.triviaPosition
  token := tokenAt
  normalize := id
  allowed := fun text => text.all allowedCharacter

theorem model_interpreted : InterpretedSource modelCalls modelPrimitives where
  primitive := {
    comment := by
      intro text _ _ position first last
      exact (Silver.Expressions.commentBody_denotation {text, position} first last).symm
    trivia := by
      intro text _ _ position first last
      exact (Silver.Expressions.triviaBody_denotation {text, position} first last).symm
    token := by
      intro text _ _ position token _ last
      exact (token_expression_denotation text position token last).symm
    normalize := by intros; rfl
    allowed := by intros; rfl }
  literal := by
    intro text _ _ position _ _
    rw [literal_denotation]
    change literalEnd text position = literalEquation (literalEnd text) text position
    rw [literalEnd]
    rfl
  suffix := by
    intro text _ _ position nextToken _ _ first _
    rw [suffix_denotation]
    exact suffixAtIndex_equation text position nextToken first
  member := by
    intro text
    have positive : (1 : Int) ≤ text.length ↔ 0 < text.length := by omega
    simp [modelCalls, accepts, Silver.Expressions.memberBody,
      Silver.Expressions.Condition.evalWith, Silver.Expressions.Number.evalWith,
      memberCalls, modelPrimitives, suffixAtIndex, positive]

end Silver.Output.Expressions
