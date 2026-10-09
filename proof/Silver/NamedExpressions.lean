import Silver.NamedEquations
import Silver.OutputExpressions

/-! Typed templates for the named recognizer. Numerical subtraction occurs only
on the nonempty span/word domains checked by SPARK; the templates retain each
source group and quantifier. Recursive and helper calls remain arbitrary until
separately interpreted equations close them to the independent grammar. -/

set_option linter.constructorNameAsVariable false

namespace Silver.Named.Expressions

structure Calls where
  output : Output.Calls
  primitive : Output.PrimitiveCalls
  identifier : IdentifierCalls
  named : Named.Calls
  letter : Nat → Bool
  token : Source → Nat → Token → Bool
  forbiddenSpelling : Fin forbiddenNames.length → Source

structure Context where
  text : Source
  position : Nat := 1
  nextToken : Nat := 1
  previous : Bool := false
  item : Nat := 0
  first : Nat := 1
  after : Nat := 2
  leftFirst : Nat := 1
  leftAfter : Nat := 2
  rightFirst : Nat := 1
  rightAfter : Nat := 2
  declaredFirst : Nat := 0
  declaredAfter : Nat := 0
  word : Source := []
  offset : Nat := 0
  forbiddenWord : Fin forbiddenNames.length := ⟨0, by decide⟩

inductive Word
  | parameter | forbidden
  deriving DecidableEq, Repr

mutual
inductive Number
  | constant (value : Nat) | character (value : Nat) | characterVal (value : Number)
  | position | last | nextToken | tokenLast | item | first | after
  | leftFirst | leftAfter | rightFirst | rightAfter | declaredFirst | declaredAfter
  | offset | wordLength | sourceLength | maxLength
  | add (left right : Number) | sub (left right : Number) | group (value : Number)
  | byteAt (position : Number) | wordAt (position : Number) | lower (value : Number)
  | tail (position : Number) (previous : Condition) | finish (position : Number)
  | literal (position : Number) | trivia (position : Number) | spellingLength (index : Number)
  | ite (condition : Condition) (yes no : Number) | elsif (condition : Condition) (yes no : Number)
  deriving DecidableEq, Repr
inductive Condition
  | value (value : Bool) | previous
  | eq (left right : Number) | ne (left right : Number)
  | lt (left right : Number) | le (left right : Number) | gt (left right : Number)
  | range (value first last : Number)
  | twoRanges (value first last secondFirst secondLast : Number)
  | andThen (left right : Condition) | orElse (left right : Condition)
  | not (value : Condition) | group (value : Condition)
  | identifier (value : Number) | letter (value : Number)
  | tokenEq (index : Number) (token : Token) | tokenAt (position index : Number)
  | name (first after : Number) (word : Word) | forbidden (first after : Number)
  | equal (leftFirst leftAfter rightFirst rightAfter : Number)
  | suffix (position index first after : Number)
  | allOffsets (last : Number) (body : Condition) | someForbidden (body : Condition)
  | allowedNormalized | directNormalized | namedNormalized
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

def Word.render : Word → List String
  | .parameter => ["word"] | .forbidden => call "forbidden_spelling" [["word"]]

def Word.eval (calls : Calls) (context : Context) : Word → Source
  | .parameter => context.word | .forbidden => calls.forbiddenSpelling context.forbiddenWord

def tokenFor (index : Nat) : Token := requiredTokens.getD (index - 1) (.base .semicolon)

mutual
def Number.render : Number → List String
  | .constant value => [toString value]
  | .character value => [String.ofList ['\'', Char.ofNat value, '\'']]
  | .characterVal value => ["character", "'", "val", "("] ++ value.render ++ [")"]
  | .position => ["position"] | .last => ["text", "'", "last"]
  | .nextToken => ["next_token"] | .tokenLast => ["named_required_tokens", "'", "last"]
  | .item => ["item"] | .first => ["first"] | .after => ["after"]
  | .leftFirst => ["left_first"] | .leftAfter => ["left_after"]
  | .rightFirst => ["right_first"] | .rightAfter => ["right_after"]
  | .declaredFirst => ["declared_first"] | .declaredAfter => ["declared_after"]
  | .offset => ["offset"] | .wordLength => ["word", "'", "length"]
  | .sourceLength => ["source", "'", "length"] | .maxLength => ["max_source_length"]
  | .add left right => left.render ++ ["+"] ++ right.render
  | .sub left right => left.render ++ ["-"] ++ right.render
  | .group value => ["("] ++ value.render ++ [")"]
  | .byteAt position => call "text" [position.render]
  | .wordAt position => call "word" [position.render]
  | .lower value => call "lowercase" [value.render]
  | .tail position previous => call "identifier_tail" [["text"], position.render, previous.render]
  | .finish position => call "identifier_end" [["text"], position.render]
  | .literal position => call "literal_end" [["text"], position.render]
  | .trivia position => call "trivia_end" [["text"], position.render]
  | .spellingLength index => call "spelling" [call "named_required_tokens" [index.render]] ++ ["'", "length"]
  | .ite condition yes no => ["if"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .elsif condition yes no => ["elsif"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
def Condition.render : Condition → List String
  | .value true => ["true"] | .value false => ["false"] | .previous => ["previous_underscore"]
  | .eq left right => left.render ++ ["="] ++ right.render
  | .ne left right => left.render ++ ["/="] ++ right.render
  | .lt left right => left.render ++ ["<"] ++ right.render
  | .le left right => left.render ++ ["<="] ++ right.render
  | .gt left right => left.render ++ [">"] ++ right.render
  | .range value first last => value.render ++ ["in"] ++ first.render ++ [".."] ++ last.render
  | .twoRanges value first last secondFirst secondLast => value.render ++ ["in"] ++ first.render ++
      [".."] ++ last.render ++ ["|"] ++ secondFirst.render ++ [".."] ++ secondLast.render
  | .andThen left right => left.render ++ ["and", "then"] ++ right.render
  | .orElse left right => left.render ++ ["or", "else"] ++ right.render
  | .not value => ["not"] ++ value.render
  | .group value => ["("] ++ value.render ++ [")"]
  | .identifier value => call "is_identifier_character" [value.render]
  | .letter value => call "is_letter" [value.render]
  | .tokenEq index token => call "named_required_tokens" [index.render] ++ ["=", tokenName token]
  | .tokenAt position index => call "token_at" [["text"], position.render,
      call "spelling" [call "named_required_tokens" [index.render]],
      call "is_word_token" [call "named_required_tokens" [index.render]]]
  | .name first after word => call "name_is" [["text"], first.render, after.render, word.render]
  | .forbidden first after => call "forbidden_name" [["text"], first.render, after.render]
  | .equal leftFirst leftAfter rightFirst rightAfter => call "equal_name"
      [["text"], leftFirst.render, leftAfter.render, rightFirst.render, rightAfter.render]
  | .suffix position index first after => call "named_suffix_matches"
      [["text"], position.render, index.render, first.render, after.render]
  | .allOffsets last body => ["for", "all", "offset", "in", "0", ".."] ++ last.render ++ ["=>"] ++ body.render
  | .someForbidden body => ["for", "some", "word", "in", "forbidden_kind", "=>"] ++ body.render
  | .allowedNormalized => call "allowed_source" [call "normalized" [["source"]]]
  | .directNormalized => call "suffix_matches" [call "normalized" [["source"]], ["1"], ["1"]]
  | .namedNormalized => call "named_suffix_matches" [call "normalized" [["source"]], ["1"], ["1"], ["0"], ["0"]]
  | .ite condition yes no => ["if"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .elsif condition yes no => ["elsif"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
end

mutual
def Number.eval (calls : Calls) (context : Context) : Number → Nat
  | .constant value | .character value => value
  | .characterVal value | .group value => value.eval calls context
  | .position => context.position | .last => context.text.length
  | .nextToken => context.nextToken | .tokenLast => requiredTokens.length
  | .item => context.item | .first => context.first | .after => context.after
  | .leftFirst => context.leftFirst | .leftAfter => context.leftAfter
  | .rightFirst => context.rightFirst | .rightAfter => context.rightAfter
  | .declaredFirst => context.declaredFirst | .declaredAfter => context.declaredAfter
  | .offset => context.offset | .wordLength => context.word.length
  | .sourceLength => context.text.length | .maxLength => maxSourceLength
  | .add left right => left.eval calls context + right.eval calls context
  | .sub left right => left.eval calls context - right.eval calls context
  | .byteAt position => Cursor.byteAt context.text (position.eval calls context)
  | .wordAt position => Cursor.byteAt context.word (position.eval calls context)
  | .lower value => lowercase (value.eval calls context)
  | .tail position previous => calls.identifier.tail context.text (position.eval calls context) (previous.eval calls context)
  | .finish position => calls.identifier.finish context.text (position.eval calls context)
  | .literal position => calls.output.literal context.text (position.eval calls context)
  | .trivia position => calls.primitive.trivia context.text (position.eval calls context)
  | .spellingLength index => (tokenFor (index.eval calls context)).spelling.length
  | .ite condition yes no | .elsif condition yes no =>
      if condition.eval calls context then yes.eval calls context else no.eval calls context
def Condition.eval (calls : Calls) (context : Context) : Condition → Bool
  | .value value => value | .previous => context.previous
  | .eq left right => left.eval calls context == right.eval calls context
  | .ne left right => !(left.eval calls context == right.eval calls context)
  | .lt left right => decide (left.eval calls context < right.eval calls context)
  | .le left right => decide (left.eval calls context ≤ right.eval calls context)
  | .gt left right => decide (left.eval calls context > right.eval calls context)
  | .range value first last => decide (first.eval calls context ≤ value.eval calls context ∧ value.eval calls context ≤ last.eval calls context)
  | .twoRanges value first last secondFirst secondLast =>
      decide ((first.eval calls context ≤ value.eval calls context ∧ value.eval calls context ≤ last.eval calls context) ∨
        (secondFirst.eval calls context ≤ value.eval calls context ∧ value.eval calls context ≤ secondLast.eval calls context))
  | .andThen left right => left.eval calls context && right.eval calls context
  | .orElse left right => left.eval calls context || right.eval calls context
  | .not value => !value.eval calls context | .group value => value.eval calls context
  | .identifier value => identifierCharacter (value.eval calls context)
  | .letter value => calls.letter (value.eval calls context)
  | .tokenEq index token => tokenFor (index.eval calls context) == token
  | .tokenAt position index => calls.token context.text (position.eval calls context) (tokenFor (index.eval calls context))
  | .name first after word => calls.identifier.name context.text (first.eval calls context) (after.eval calls context) (word.eval calls context)
  | .forbidden first after => calls.identifier.forbidden context.text (first.eval calls context) (after.eval calls context)
  | .equal leftFirst leftAfter rightFirst rightAfter => calls.identifier.equal context.text
      (leftFirst.eval calls context) (leftAfter.eval calls context) (rightFirst.eval calls context) (rightAfter.eval calls context)
  | .suffix position index first after => calls.named.suffix context.text (position.eval calls context)
      (index.eval calls context) ⟨first.eval calls context, after.eval calls context⟩
  | .allOffsets last body => (List.range (last.eval calls context + 1)).all (fun offset => body.eval calls {context with offset})
  | .someForbidden body => (List.finRange forbiddenNames.length).any (fun forbiddenWord => body.eval calls {context with forbiddenWord})
  | .allowedNormalized => calls.primitive.allowed (calls.primitive.normalize context.text)
  | .directNormalized => calls.output.suffix (calls.primitive.normalize context.text) 1 1
  | .namedNormalized => calls.named.suffix (calls.primitive.normalize context.text) 1 1 {}
  | .ite condition yes no | .elsif condition yes no =>
      if condition.eval calls context then yes.eval calls context else no.eval calls context
end

def letterBody : Condition := .twoRanges .item (.character 65) (.character 90) (.character 97) (.character 122)
def tailBody : Number :=
  .ite (.orElse (.gt .position .last) (.not (.identifier (.byteAt .position))))
    (.group (.ite .previous (.constant 0) .position))
    (.elsif (.andThen (.eq (.byteAt .position) (.character 95)) .previous) (.constant 0)
      (.tail (.add .position (.constant 1)) (.eq (.byteAt .position) (.character 95))))
def finishBody : Number :=
  .ite (.orElse (.gt .position .last) (.not (.letter (.byteAt .position)))) (.constant 0)
    (.tail (.add .position (.constant 1)) (.value false))
def nameBody : Condition :=
  .andThen (.eq (.sub .after .first) .wordLength)
    (.group (.allOffsets (.sub .wordLength (.constant 1))
      (.eq (.lower (.byteAt (.add .first .offset))) (.wordAt (.add (.constant 1) .offset)))))
def equalBody : Condition :=
  .andThen (.eq (.sub .leftAfter .leftFirst) (.sub .rightAfter .rightFirst))
    (.group (.allOffsets (.sub (.group (.sub .leftAfter .leftFirst)) (.constant 1))
      (.eq (.lower (.byteAt (.add .leftFirst .offset))) (.lower (.byteAt (.add .rightFirst .offset))))))
def forbiddenBody : Condition := .someForbidden (.name .first .after .forbidden)
def stateBody : Condition :=
  .orElse (.group (.andThen (.eq .first (.constant 0)) (.eq .after (.constant 0))))
    (.group (.andThen (.andThen (.gt .first (.constant 0)) (.lt .first .after)) (.le .after (.add .last (.constant 1)))))
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
def memberBody : Condition :=
  .andThen (.andThen (.range .sourceLength (.constant 1) .maxLength) .allowedNormalized)
    (.group (.orElse .directNormalized .namedNormalized))

theorem letter_denotation (calls : Calls) (context : Context) :
    letterBody.eval calls context = letter context.item := by rfl

theorem tail_denotation (calls : Calls) (context : Context) :
    tailBody.eval calls context = identifierTailEquation (calls.identifier.tail context.text)
      context.text context.position context.previous := by
  dsimp +instances only [tailBody, Number.eval, Condition.eval]
  simp [identifierTailEquation, Bool.or_eq_true, Bool.and_eq_true]

theorem finish_denotation (calls : Calls) (context : Context)
    (letterEquation : ∀ item, calls.letter item = letter item) :
    finishBody.eval calls context =
      if context.position ≤ context.text.length ∧ letter (Cursor.byteAt context.text context.position) = true
      then calls.identifier.tail context.text (context.position + 1) false else 0 := by
  dsimp +instances only [finishBody, Number.eval, Condition.eval]
  simp only [letterEquation, Bool.or_eq_true, decide_eq_true_eq, Bool.not_eq_true']
  by_cases bound : context.position ≤ context.text.length <;>
    by_cases character : letter (Cursor.byteAt context.text context.position) = true <;> simp_all
  all_goals intro impossible; omega

/-- The finite enum order is checked against the source catalogue; this lemma
connects its typed quantification to the independent forbidden-word list. -/
theorem forbidden_denotation (calls : Calls) (context : Context)
    (spelling : ∀ index, calls.forbiddenSpelling index = forbiddenNames[index.val]) :
    forbiddenBody.eval calls context = forbiddenNames.any (calls.identifier.name context.text context.first context.after) := by
  apply Bool.eq_iff_iff.mpr
  simp only [forbiddenBody, Condition.eval, Number.eval, Word.eval, List.any_eq_true]
  constructor
  · rintro ⟨index, _, matched⟩
    rw [spelling] at matched
    exact ⟨_, List.getElem_mem _, matched⟩
  · rintro ⟨word, member, matched⟩
    obtain ⟨index, bound, value⟩ := List.mem_iff_getElem.mp member
    refine ⟨⟨index, bound⟩, List.mem_finRange _, ?_⟩
    simpa [spelling, value] using matched

theorem state_denotation (calls : Calls) (context : Context) :
    stateBody.eval calls context = true ↔ (⟨context.first, context.after⟩ : NameState).Valid context.text := by
  dsimp +instances only [stateBody, Condition.eval, Number.eval]
  simp [NameState.Valid, Bool.or_eq_true, Bool.and_eq_true, and_assoc]

theorem name_denotation (calls : Calls) (context : Context) (nonempty : 0 < context.word.length) :
    nameBody.eval calls context = nameIs context.text context.first context.after context.word := by
  have count : context.word.length - 1 + 1 = context.word.length := by omega
  apply Bool.eq_iff_iff.mpr
  dsimp +instances only [nameBody, Condition.eval, Number.eval]
  simp only [nameIs, Bool.and_eq_true, beq_iff_eq, List.all_eq_true, List.mem_range,
    decide_eq_true_eq, count]
  constructor
  · rintro ⟨length, bytes⟩
    refine ⟨length, ?_⟩
    intro index
    have same := bytes index.val index.isLt
    simpa [Cursor.byteAt, List.getD, List.getElem?_eq_getElem index.isLt] using same
  · rintro ⟨length, bytes⟩
    refine ⟨length, ?_⟩
    intro index bound
    have same := bytes ⟨index, bound⟩
    simpa [Cursor.byteAt, List.getD, List.getElem?_eq_getElem bound] using same

theorem equal_denotation (calls : Calls) (context : Context)
    (ordered : context.leftFirst < context.leftAfter) :
    equalBody.eval calls context = equalName context.text context.leftFirst context.leftAfter
      context.rightFirst context.rightAfter := by
  have count : (context.leftAfter - context.leftFirst) - 1 + 1 = context.leftAfter - context.leftFirst := by omega
  apply Bool.eq_iff_iff.mpr
  dsimp +instances only [equalBody, Condition.eval, Number.eval]
  simp only [equalName, Bool.and_eq_true, beq_iff_eq, List.all_eq_true, List.mem_range,
    decide_eq_true_eq, count]
  constructor
  · rintro ⟨length, bytes⟩
    exact ⟨length, fun index => bytes index.val index.isLt⟩
  · rintro ⟨length, bytes⟩
    exact ⟨length, fun index bound => bytes ⟨index, bound⟩⟩

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

theorem suffix_denotation (calls : Calls) (context : Context) :
    suffixBody.eval calls context = sourceSuffixEquation
      (calls.primitive.trivia context.text) (calls.output.literal context.text)
      (calls.identifier.finish context.text) (calls.identifier.forbidden context.text)
      (calls.identifier.equal context.text) (calls.token context.text) (calls.named.suffix context.text)
      context.text context.position context.nextToken ⟨context.declaredFirst, context.declaredAfter⟩ := by
  have equality (a b : Nat) : (a == b) = decide (a = b) := by
    apply Bool.eq_iff_iff.mpr
    simp
  dsimp +instances only [suffixBody, Condition.eval, Number.eval]
  simp [sourceSuffixEquation, tokenFor, equality]

structure InterpretedSource (calls : Calls) : Prop where
  output : Output.Expressions.InterpretedSource calls.output calls.primitive
  letter : ∀ item, calls.letter item = letterBody.eval calls {text := [], item}
  forbiddenSpelling : ∀ index, calls.forbiddenSpelling index = forbiddenNames[index.val]
  token : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position token, 1 ≤ position → position ≤ text.length + 1 →
      calls.token text position token = Silver.Expressions.tokenBody.eval
        {text, position, word := token.spelling, wordFlag := token.isWord}
  tail : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position previous, 1 ≤ position → position ≤ text.length + 1 →
      calls.identifier.tail text position previous = tailBody.eval calls {text, position, previous}
  finish : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      calls.identifier.finish text position = finishBody.eval calls {text, position}
  name : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ first after word, 1 ≤ first → first < after → after ≤ text.length + 1 →
      0 < word.length → word.length ≤ maxSourceLength →
      calls.identifier.name text first after word = nameBody.eval calls {text, first, after, word}
  equal : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ leftFirst leftAfter rightFirst rightAfter,
      1 ≤ leftFirst → leftFirst < leftAfter → leftAfter ≤ text.length + 1 →
      1 ≤ rightFirst → rightFirst < rightAfter → rightAfter ≤ text.length + 1 →
      calls.identifier.equal text leftFirst leftAfter rightFirst rightAfter =
        equalBody.eval calls {text, leftFirst, leftAfter, rightFirst, rightAfter}
  forbidden : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ first after, 1 ≤ first → first < after → after ≤ text.length + 1 →
      calls.identifier.forbidden text first after = forbiddenBody.eval calls {text, first, after}
  suffix : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position nextToken state, 1 ≤ position → position ≤ text.length + 1 →
      1 ≤ nextToken → nextToken ≤ requiredTokens.length + 1 → state.Valid text →
      calls.named.suffix text position nextToken state =
        suffixBody.eval calls {text, position, nextToken, declaredFirst := state.first, declaredAfter := state.after}
  member : ∀ text, calls.named.member text = memberBody.eval calls {text}

theorem interpreted_identifier_equations (calls : Calls) (source : InterpretedSource calls) :
    IdentifierEquations calls.identifier where
  tail := by
    intro text positive bounded position previous first last
    rw [source.tail text positive bounded position previous first last]
    exact tail_denotation calls _
  finish := by
    intro text positive bounded position first last
    rw [source.finish text positive bounded position first last]
    exact finish_denotation calls _ (fun item => (source.letter item).trans (letter_denotation calls _))
  name := by
    intro text positive bounded first after word start ordered last nonempty wordBound
    rw [source.name text positive bounded first after word start ordered last nonempty wordBound]
    exact name_denotation calls _ nonempty
  equal := by
    intro text positive bounded leftFirst leftAfter rightFirst rightAfter lf lo ll rf ro rl
    rw [source.equal text positive bounded leftFirst leftAfter rightFirst rightAfter lf lo ll rf ro rl]
    exact equal_denotation calls _ lo
  forbidden := by
    intro text positive bounded first after start ordered last
    rw [source.forbidden text positive bounded first after start ordered last]
    exact forbidden_denotation calls _ source.forbiddenSpelling

/-- Inhabitation witness for the arbitrary-callee interpretation interface.
Actual Ada correspondence additionally uses the separately checked render trees. -/
def modelCalls : Calls where
  output := Output.Expressions.modelCalls
  primitive := Output.Expressions.modelPrimitives
  identifier := modelIdentifierCalls
  named := Named.modelCalls
  letter := Named.letter
  token := Named.tokenAt
  forbiddenSpelling := fun index => forbiddenNames[index.val]

theorem model_interpreted : InterpretedSource modelCalls where
  output := Output.Expressions.model_interpreted
  letter := by intro item; rfl
  forbiddenSpelling := by intro index; rfl
  token := by
    intro text _ _ position token _ last
    exact (token_denotation text position token last).symm
  tail := by
    intro text _ _ position previous _ _
    rw [tail_denotation]
    change identifierTail text position previous = identifierTailEquation (identifierTail text) text position previous
    rw [identifierTail]
    rfl
  finish := by
    intro text _ _ position _ _
    rw [finish_denotation _ _ (by intro item; rfl)]
    rfl
  name := by
    intro text _ _ first after word _ _ _ nonempty _
    exact (name_denotation modelCalls {text, first, after, word} nonempty).symm
  equal := by
    intro text _ _ leftFirst leftAfter rightFirst rightAfter _ ordered _ _ _ _
    exact (equal_denotation modelCalls {text, leftFirst, leftAfter, rightFirst, rightAfter} ordered).symm
  forbidden := by
    intro text _ _ first after _ _ _
    rw [forbidden_denotation _ _ (by intro index; rfl)]
    rfl
  suffix := by
    intro text _ _ position nextToken state _ _ first _ _
    rw [suffix_denotation]
    change suffixAtIndex text position nextToken state =
      sourceSuffixEquation (Cursor.triviaPosition text) (Output.literalEnd text)
        (identifierEnd text) (forbiddenName text) (equalName text) (tokenAt text)
        (suffixAtIndex text) text position nextToken state
    rw [suffixAtIndex_equation text position nextToken state first]
    rfl
  member := by
    intro text
    dsimp +instances only [memberBody, Condition.eval, Number.eval]
    have bound : 1 ≤ text.length ↔ 0 < text.length := by omega
    simp [modelCalls, Named.modelCalls, Output.Expressions.modelCalls,
      Output.Expressions.modelPrimitives, bound]

theorem interpreted_equations (calls : Calls) (source : InterpretedSource calls) :
    DefinitionEquations calls.named where
  suffix := by
    intro text positive bounded position nextToken state first last start stop valid
    rw [source.suffix text positive bounded position nextToken state first last start stop valid,
      suffix_denotation]
    have outputSource := Output.Expressions.interpreted_equations calls.output calls.primitive source.output
    have outputDefinitions := Output.source_equations_reduce calls.output calls.primitive outputSource
    have identifiers := interpreted_identifier_equations calls source
    exact sourceSuffixEquation_reduce
      (calls.primitive.trivia text) (calls.output.literal text) (calls.identifier.finish text)
      (calls.identifier.forbidden text) (calls.identifier.equal text) (calls.token text)
      (calls.named.suffix text) text
      (fun cursor first last => Output.primitive_trivia calls.primitive outputSource.primitive
        text positive bounded cursor first last)
      (fun cursor first last => identifier_implementation calls.identifier identifiers
        text positive bounded cursor first last)
      (fun cursor first last => Output.implementation_literal calls.output outputDefinitions
        text positive bounded cursor first last)
      (fun first after start ordered last => forbidden_implementation calls.identifier identifiers
        text positive bounded first after start ordered last)
      (fun leftFirst leftAfter rightFirst rightAfter lf lo ll rf ro rl =>
        identifiers.equal text positive bounded leftFirst leftAfter rightFirst rightAfter lf lo ll rf ro rl)
      (fun cursor token first last => (source.token text positive bounded cursor token first last).trans
        (token_denotation text cursor token last))
      position nextToken state first last valid
  member := by
    intro text
    rw [source.member]
    dsimp +instances only [memberBody, Condition.eval, Number.eval]
    have outputSource := Output.Expressions.interpreted_equations calls.output calls.primitive source.output
    have outputDefinitions := Output.source_equations_reduce calls.output calls.primitive outputSource
    by_cases bound : 0 < text.length ∧ text.length ≤ maxSourceLength
    · rw [outputSource.primitive.normalize text bound.2, outputSource.primitive.allowed]
      rw [Output.implementation_suffix calls.output outputDefinitions text bound.1 bound.2
        1 1 (by omega) (by omega) (by decide) (by decide)]
      have first : 1 ≤ text.length := by omega
      simp [bound, first]
    · have outside : ¬ (1 ≤ text.length ∧ text.length ≤ maxSourceLength) := by omega
      simp [outside, bound]

end Silver.Named.Expressions
