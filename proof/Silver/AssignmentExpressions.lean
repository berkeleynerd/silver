import Silver.AssignmentEquations
import Silver.ConcatExpressions

/-! Typed expressions for fixed-length assignment recognition. Shared identifier
and literal callees keep their existing checked interpretations; the new suffix
remains arbitrary until recursive uniqueness closes it on its SPARK domains. -/

set_option linter.constructorNameAsVariable false
namespace Silver.Assignment.Expressions
open Named

structure Calls where
  base : Concat.Expressions.Calls
  length : Source → Nat → Nat
  suffix : Source → Nat → Nat → NameState → Nat → Bool

structure Context where
  text : Source
  position : Nat := 1
  nextToken : Nat := 1
  declaredFirst : Nat := 0
  declaredAfter : Nat := 0
  initialLength : Nat := 0

mutual
inductive Number
  | constant (value : Nat) | character (value : Nat) | characterVal (value : Number)
  | position | last | nextToken | tokenLast | declaredFirst | declaredAfter | initialLength
  | add (left right : Number) | group (value : Number)
  | byteAt (position : Number) | finish (position : Number)
  | literal (position : Number) | length (position : Number) | trivia (position : Number)
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
  | suffix (position index first after length : Number)
  | whenTrue (condition yes : Condition)
  | ite (condition yes no : Condition) | elsif (condition yes no : Condition)
  deriving DecidableEq, Repr
end

def call := Silver.Expressions.call
def tokenFor (index : Nat) : Token := requiredTokens.getD (index - 1) (.base .semicolon)
mutual
def Number.render : Number → List String
  | .constant n => [toString n]
  | .character n => [String.ofList ['\'', Char.ofNat n, '\'']]
  | .characterVal a => ["character", "'", "val", "("] ++ a.render ++ [")"]
  | .position => ["position"] | .last => ["text", "'", "last"]
  | .nextToken => ["next_token"] | .tokenLast => ["assignment_required_tokens", "'", "last"]
  | .declaredFirst => ["declared_first"] | .declaredAfter => ["declared_after"]
  | .initialLength => ["initial_length"]
  | .add a b => a.render ++ ["+"] ++ b.render | .group a => ["("] ++ a.render ++ [")"]
  | .byteAt a => call "text" [a.render]
  | .finish a => call "identifier_end" [["text"],a.render]
  | .literal a => call "literal_end" [["text"],a.render]
  | .length a => call "literal_length" [["text"],a.render]
  | .trivia a => call "trivia_end" [["text"],a.render]
  | .spellingLength a => call "spelling" [call "assignment_required_tokens" [a.render]] ++ ["'", "length"]
  | .ite c a b => ["if"] ++ c.render ++ ["then"] ++ a.render ++ (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
  | .elsif c a b => ["elsif"] ++ c.render ++ ["then"] ++ a.render ++ (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
def Condition.render : Condition → List String
  | .eq a b => a.render ++ ["="] ++ b.render | .ne a b => a.render ++ ["/="] ++ b.render
  | .lt a b => a.render ++ ["<"] ++ b.render | .le a b => a.render ++ ["<="] ++ b.render
  | .gt a b => a.render ++ [">"] ++ b.render
  | .range a b c => a.render ++ ["in"] ++ b.render ++ [".."] ++ c.render
  | .andThen a b => a.render ++ ["and", "then"] ++ b.render
  | .not a => ["not"] ++ a.render | .group a => ["("] ++ a.render ++ [")"]
  | .forbidden a b => call "forbidden_name" [["text"],a.render,b.render]
  | .equal a b c d => call "equal_name" [["text"],a.render,b.render,c.render,d.render]
  | .tokenEq i t => call "assignment_required_tokens" [i.render] ++ ["=",Concat.Expressions.tokenName t]
  | .tokenAt p i => call "token_at" [["text"],p.render,call "spelling" [call "assignment_required_tokens" [i.render]],call "is_word_token" [call "assignment_required_tokens" [i.render]]]
  | .suffix p i a b l => call "assignment_suffix_matches" [["text"],p.render,i.render,a.render,b.render,l.render]
  | .whenTrue c a => ["if"] ++ c.render ++ ["then"] ++ a.render
  | .ite c a b => ["if"] ++ c.render ++ ["then"] ++ a.render ++ (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
  | .elsif c a b => ["elsif"] ++ c.render ++ ["then"] ++ a.render ++ (match b with | .elsif _ _ _ => b.render | _ => ["else"] ++ b.render)
end

def Number.primary : Number → Bool | .add _ _ | .ite _ _ _ | .elsif _ _ _ => false | _ => true
def Number.simple : Number → Bool | .ite _ _ _ | .elsif _ _ _ => false | _ => true
def Number.isElsif : Number → Bool | .elsif _ _ _ => true | _ => false
def Condition.primary : Condition → Bool
  | .group _ | .forbidden _ _ | .equal _ _ _ _ | .tokenAt _ _ | .suffix _ _ _ _ _ => true | _ => false
def Condition.relation : Condition → Bool
  | .andThen _ _ | .whenTrue _ _ | .ite _ _ _ | .elsif _ _ _ => false | _ => true
def Condition.logical : Condition → Bool | .whenTrue _ _ | .ite _ _ _ | .elsif _ _ _ => false | _ => true
def Condition.isElsif : Condition → Bool | .elsif _ _ _ => true | _ => false
def Condition.andLeft : Condition → Bool | .andThen _ _ => true | c => c.relation
mutual
def Number.wellFormed : Number → Bool
  | .add a b => a.wellFormed && b.wellFormed && a.simple && b.primary
  | .group a => a.wellFormed && !a.isElsif
  | .byteAt a | .finish a | .literal a | .length a | .trivia a | .spellingLength a | .characterVal a => a.wellFormed && a.simple
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
  | .suffix a b c d e => a.wellFormed && b.wellFormed && c.wellFormed && d.wellFormed && e.wellFormed && a.simple && b.simple && c.simple && d.simple && e.simple
  | .whenTrue c a => c.wellFormed && c.logical && a.wellFormed && a.logical
  | .ite c a b | .elsif c a b => c.wellFormed && c.logical && a.wellFormed && a.logical && b.wellFormed && (b.logical || b.isElsif)
end
mutual
def Number.eval (calls : Calls) (ctx : Context) : Number → Nat
  | .constant n | .character n => n | .characterVal a | .group a => a.eval calls ctx
  | .position => ctx.position | .last => ctx.text.length | .nextToken => ctx.nextToken
  | .tokenLast => requiredTokens.length | .declaredFirst => ctx.declaredFirst
  | .declaredAfter => ctx.declaredAfter | .initialLength => ctx.initialLength
  | .add a b => a.eval calls ctx + b.eval calls ctx
  | .byteAt a => Cursor.byteAt ctx.text (a.eval calls ctx)
  | .finish a => calls.base.identifier.finish ctx.text (a.eval calls ctx)
  | .literal a => calls.base.output.literal ctx.text (a.eval calls ctx)
  | .length a => calls.length ctx.text (a.eval calls ctx)
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
  | .forbidden a b => calls.base.identifier.forbidden ctx.text (a.eval calls ctx) (b.eval calls ctx)
  | .equal a b c d => calls.base.identifier.equal ctx.text (a.eval calls ctx) (b.eval calls ctx) (c.eval calls ctx) (d.eval calls ctx)
  | .tokenEq i t => tokenFor (i.eval calls ctx) == t
  | .tokenAt p i => calls.base.token ctx.text (p.eval calls ctx) (tokenFor (i.eval calls ctx))
  | .suffix p i a b l => calls.suffix ctx.text (p.eval calls ctx) (i.eval calls ctx) ⟨a.eval calls ctx,b.eval calls ctx⟩ (l.eval calls ctx)
  | .whenTrue c a => if c.eval calls ctx then a.eval calls ctx else true
  | .ite c a b | .elsif c a b => if c.eval calls ctx then a.eval calls ctx else b.eval calls ctx
end

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
  .ite (.gt .nextToken .tokenLast) (.eq start (.add .last (.constant 1)))
    (.elsif (.tokenEq .nextToken .declarationName)
      (.andThen (.andThen (.ne finish (.constant 0)) (.not (.forbidden start finish)))
        (.suffix finish next start finish .initialLength))
      (.elsif (.tokenEq .nextToken .referenceName)
        (.andThen (.andThen (.andThen (.gt .declaredFirst (.constant 0)) (.ne finish (.constant 0)))
          (.equal .declaredFirst .declaredAfter start finish))
          (.suffix finish next .declaredFirst .declaredAfter .initialLength))
        (.elsif (.tokenEq .nextToken (.base .stringLiteral))
          (.andThen (.andThen (.andThen (.andThen (.le start .last)
            (.eq (.byteAt start) (.characterVal (.constant 34))))
            (.ne (.literal (.add start (.constant 1))) (.constant 0)))
            (.group (.whenTrue (.gt .nextToken (.constant 17)) (.eq length .initialLength))))
            (.suffix (.literal (.add start (.constant 1))) next .declaredFirst .declaredAfter
              (.group (.ite (.eq .nextToken (.constant 17)) length .initialLength))))
          (.andThen (.tokenAt start .nextToken)
            (.suffix (.add start (.spellingLength .nextToken)) next .declaredFirst .declaredAfter .initialLength)))))

abbrev WellFormedTrees : Prop := literalLengthBody.wellFormed = true ∧ suffixBody.wellFormed = true
theorem checked_precedence : WellFormedTrees := by decide +kernel

theorem literalLength_denotation (calls : Calls) (ctx : Context) :
    literalLengthBody.eval calls ctx = Guarded.literalLengthEquation (calls.length ctx.text) ctx.text ctx.position := by
  dsimp +instances only [literalLengthBody, Number.eval, Condition.eval]
  simp [Guarded.literalLengthEquation, Bool.and_eq_true]

theorem suffix_denotation (calls : Calls) (ctx : Context) :
    suffixBody.eval calls ctx = sourceSuffixEquation
      (calls.base.primitive.trivia ctx.text) (calls.base.output.literal ctx.text)
      (calls.base.identifier.finish ctx.text) (calls.length ctx.text)
      (calls.base.identifier.forbidden ctx.text) (calls.base.identifier.equal ctx.text)
      (calls.base.token ctx.text) (calls.suffix ctx.text)
      ctx.text ctx.position ctx.nextToken ⟨ctx.declaredFirst,ctx.declaredAfter⟩ ctx.initialLength := by
  have equality (a b : Nat) : (a == b) = decide (a = b) := by apply Bool.eq_iff_iff.mpr; simp
  dsimp +instances only [suffixBody, Number.eval, Condition.eval]
  simp [sourceSuffixEquation, tokenFor, equality]

structure InterpretedSource (calls : Calls) : Prop where
  inherited : Concat.Expressions.InterpretedSource calls.base
  length : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      calls.length text position = literalLengthBody.eval calls {text,position}
  suffix : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position nextToken state initialLength, 1 ≤ position → position ≤ text.length + 1 →
      1 ≤ nextToken → nextToken ≤ requiredTokens.length + 1 → state.Valid text →
      initialLength ≤ maxSourceLength →
      calls.suffix text position nextToken state initialLength =
        suffixBody.eval calls {text,position,nextToken,declaredFirst := state.first,declaredAfter := state.after,initialLength}

theorem interpreted_length (calls : Calls) (source : InterpretedSource calls)
    (text : Source) (positive : 0 < text.length) (bounded : text.length ≤ maxSourceLength)
    (position : Nat) (first : 1 ≤ position) (last : position ≤ text.length + 1) :
    calls.length text position = Guarded.literalLength text position := by
  apply Guarded.literalLength_unique text (calls.length text) _ position first last
  intro position first last
  rw [source.length text positive bounded position first last, literalLength_denotation]

theorem interpreted_suffix (calls : Calls) (source : InterpretedSource calls)
    (text : Source) (positive : 0 < text.length) (bounded : text.length ≤ maxSourceLength)
    (position nextToken : Nat) (state : NameState) (initialLength : Nat)
    (first : 1 ≤ position) (last : position ≤ text.length + 1)
    (start : 1 ≤ nextToken) (stop : nextToken ≤ requiredTokens.length + 1)
    (valid : state.Valid text) (lengthBound : initialLength ≤ maxSourceLength) :
    calls.suffix text position nextToken state initialLength =
      suffixAtIndex text position nextToken state initialLength := by
  apply suffixAtIndex_unique text bounded (calls.suffix text) _ position nextToken state initialLength first last start stop valid lengthBound
  intro position nextToken state initialLength first last start stop valid lengthBound
  rw [source.suffix text positive bounded position nextToken state initialLength first last start stop valid lengthBound,
    suffix_denotation]
  have outputSource := Output.Expressions.interpreted_equations calls.base.output calls.base.primitive source.inherited.output
  have outputDefinitions := Output.source_equations_reduce calls.base.output calls.base.primitive outputSource
  have identifiers := Concat.Expressions.interpreted_identifier_equations calls.base source.inherited
  exact sourceSuffixEquation_reduce
    (calls.base.primitive.trivia text) (calls.base.output.literal text) (calls.base.identifier.finish text)
    (calls.length text) (calls.base.identifier.forbidden text) (calls.base.identifier.equal text)
    (calls.base.token text) (calls.suffix text) text
    (fun cursor first last => Output.primitive_trivia calls.base.primitive outputSource.primitive text positive bounded cursor first last)
    (fun cursor first last => identifier_implementation calls.base.identifier identifiers text positive bounded cursor first last)
    (fun cursor first last => Output.implementation_literal calls.base.output outputDefinitions text positive bounded cursor first last)
    (fun cursor first last => interpreted_length calls source text positive bounded cursor first last)
    (fun first after start ordered last => forbidden_implementation calls.base.identifier identifiers text positive bounded first after start ordered last)
    (fun leftFirst leftAfter rightFirst rightAfter lf lo ll rf ro rl =>
      identifiers.equal text positive bounded leftFirst leftAfter rightFirst rightAfter lf lo ll rf ro rl)
    (fun cursor token first last => (source.inherited.token text positive bounded cursor token first last).trans
      (Concat.Expressions.token_denotation text cursor token last))
    position nextToken state initialLength first last valid

def modelCalls : Calls where
  base := Concat.Expressions.modelCalls
  length := Guarded.literalLength
  suffix := suffixAtIndex

theorem model_interpreted : InterpretedSource modelCalls where
  inherited := Concat.Expressions.model_interpreted
  length := by
    intro text _ _ position _ _
    rw [literalLength_denotation]
    exact Guarded.literalLength_equation text position
  suffix := by
    intro text _ _ position nextToken state initialLength first last start _ valid _
    rw [suffix_denotation]
    change suffixAtIndex text position nextToken state initialLength = _
    rw [suffixAtIndex_equation text position nextToken state initialLength start]
    exact (sourceSuffixEquation_reduce _ _ _ _ _ _ _ _ text
      (fun _ _ _ => rfl) (fun _ _ _ => rfl) (fun _ _ _ => rfl)
      (fun _ _ _ => rfl) (fun _ _ _ _ _ => rfl)
      (fun _ _ _ _ _ _ _ _ _ _ => rfl) (fun _ _ _ _ => rfl)
      position nextToken state initialLength first last valid).symm

end Silver.Assignment.Expressions
