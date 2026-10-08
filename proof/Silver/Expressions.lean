import Silver.Cursor

set_option linter.constructorNameAsVariable false

/-!
A typed expression language for the actual SPARK ghost bodies. Its numerical
arithmetic is mathematical integer arithmetic, including intermediate negative
values in `(Text'Last - Position) + 1`. The actual implementation's SPARK proofs
establish the relevant machine bounds. Array positions are 1-based.

The renderer preserves grouping, attributes, short-circuit operators, calls,
and quantifier binders. SourceBridge checks its token output against the actual
expression bodies. This is deliberately a restricted expression fragment, not
a model of all Ada syntax or a second Silver authoring language.
-/

namespace Silver.Expressions

mutual
inductive Number
  | literal (value : Nat)
  | character (value : Nat)
  | characterVal (value : Number) | characterPos (value : Number)
  | position | last | index | nextToken | wordLength | sourceLength | tokenLast | maxLength | item
  | add (left right : Number) | sub (left right : Number) | group (value : Number)
  | textAt (position : Number) | wordAt (position : Number) | introducerAt (position : Number)
  | lower (value : Number) | comment (position : Number) | trivia (position : Number)
  | spellingLength (index : Number)
  | ite (condition : Condition) (yes no : Number)
  | elsif (condition : Condition) (yes no : Number)
  deriving Repr, DecidableEq

inductive Condition
  | wordFlag
  | equal (left right : Number) | less (left right : Number)
  | greater (left right : Number) | lessEqual (left right : Number)
  | range (value first last : Number)
  | andThen (left right : Condition) | orElse (left right : Condition)
  | not (value : Condition) | group (value : Condition)
  | whitespace (value : Number) | identifier (value : Number)
  | lineEnd (value : Number) | allowed (value : Number)
  | forallWord (body : Condition) | forallText (body : Condition)
  | tokenAt (position token : Number) | suffix (position nextToken : Number)
  | allowedNormalized | suffixNormalized
  | ite (condition yes no : Condition)
  deriving Repr, DecidableEq
end

abbrev Tokens := List String

def call (name : String) (arguments : List Tokens) : Tokens :=
  [name, "("] ++ List.flatten (arguments.intersperse [","]) ++ [")"]

mutual
def Number.render : Number → Tokens
  | .literal value => [toString value]
  | .character value => [String.ofList ['\'', Char.ofNat value, '\'']]
  | .characterVal value => ["character", "'", "val", "("] ++ value.render ++ [")"]
  | .characterPos value => ["character", "'", "pos", "("] ++ value.render ++ [")"]
  | .position => ["position"]
  | .last => ["text", "'", "last"]
  | .index => ["index"]
  | .nextToken => ["next_token"]
  | .wordLength => ["word", "'", "length"]
  | .sourceLength => ["source", "'", "length"]
  | .tokenLast => ["required_tokens", "'", "last"]
  | .maxLength => ["max_source_length"]
  | .item => ["item"]
  | .add left right => left.render ++ ["+"] ++ right.render
  | .sub left right => left.render ++ ["-"] ++ right.render
  | .group value => ["("] ++ value.render ++ [")"]
  | .textAt position => call "text" [position.render]
  | .wordAt position => call "word" [position.render]
  | .introducerAt position => call "comment_introducer" [position.render]
  | .lower value => call "lowercase" [value.render]
  | .comment position => call "comment_end" [["text"], position.render]
  | .trivia position => call "trivia_end" [["text"], position.render]
  | .spellingLength index => call "spelling" [call "required_tokens" [index.render]] ++ ["'", "length"]
  | .ite condition yes no =>
    ["if"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)
  | .elsif condition yes no =>
    ["elsif"] ++ condition.render ++ ["then"] ++ yes.render ++
      (match no with | .elsif _ _ _ => no.render | _ => ["else"] ++ no.render)

def Condition.render : Condition → Tokens
  | .wordFlag => ["is_word"]
  | .equal left right => left.render ++ ["="] ++ right.render
  | .less left right => left.render ++ ["<"] ++ right.render
  | .greater left right => left.render ++ [">"] ++ right.render
  | .lessEqual left right => left.render ++ ["<="] ++ right.render
  | .range value first last => value.render ++ ["in"] ++ first.render ++ [".."] ++ last.render
  | .andThen left right => left.render ++ ["and", "then"] ++ right.render
  | .orElse left right => left.render ++ ["or", "else"] ++ right.render
  | .not value => ["not"] ++ value.render
  | .group value => ["("] ++ value.render ++ [")"]
  | .whitespace value => call "is_whitespace" [value.render]
  | .identifier value => call "is_identifier_character" [value.render]
  | .lineEnd value => call "is_comment_end" [value.render]
  | .allowed value => call "is_allowed_character" [value.render]
  | .forallWord body => ["for", "all", "index", "in", "word", "'", "range", "=>"] ++ body.render
  | .forallText body => ["for", "all", "item", "of", "text", "=>"] ++ body.render
  | .tokenAt position token => call "token_at"
      [["text"], position.render, call "spelling" [call "required_tokens" [token.render]],
       call "is_word_token" [call "required_tokens" [token.render]]]
  | .suffix position nextToken => call "suffix_matches" [["text"], position.render, nextToken.render]
  | .allowedNormalized => call "allowed_source" [call "normalized" [["source"]]]
  | .suffixNormalized => call "suffix_matches" [call "normalized" [["source"]], ["1"], ["1"]]
  | .ite condition yes no => ["if"] ++ condition.render ++ ["then"] ++ yes.render ++ ["else"] ++ no.render
end

structure Context where
  text : Silver.Source
  position : Nat := 1
  word : Silver.Source := []
  wordFlag : Bool := false
  nextToken : Nat := 1
  index : Nat := 1
  item : Nat := 0

def tokenFor (index : Int) : Token := requiredTokens.getD (index.toNat - 1) .semicolon

mutual
def Number.eval (context : Context) : Number → Int
  | .literal value => value
  | .character value => value
  | .characterVal value | .characterPos value => value.eval context
  | .position => context.position
  | .last => context.text.length
  | .index => context.index
  | .nextToken => context.nextToken
  | .wordLength => context.word.length
  | .sourceLength => context.text.length
  | .tokenLast => requiredTokens.length
  | .maxLength => maxSourceLength
  | .item => context.item
  | .add left right => left.eval context + right.eval context
  | .sub left right => left.eval context - right.eval context
  | .group value => value.eval context
  | .textAt position => Cursor.byteAt context.text (position.eval context).toNat
  | .wordAt position => Cursor.byteAt context.word (position.eval context).toNat
  | .introducerAt position => Cursor.byteAt [45, 45] (position.eval context).toNat
  | .lower value => Silver.lowercase (value.eval context).toNat
  | .comment position => Cursor.commentPosition context.text (position.eval context).toNat
  | .trivia position => Cursor.triviaPosition context.text (position.eval context).toNat
  | .spellingLength index => (tokenFor (index.eval context)).spelling.length
  | .ite condition yes no | .elsif condition yes no =>
      if condition.eval context then yes.eval context else no.eval context

def Condition.eval (context : Context) : Condition → Bool
  | .wordFlag => context.wordFlag
  | .equal left right => left.eval context == right.eval context
  | .less left right => decide (left.eval context < right.eval context)
  | .greater left right => decide (left.eval context > right.eval context)
  | .lessEqual left right => decide (left.eval context ≤ right.eval context)
  | .range value first last => decide (first.eval context ≤ value.eval context ∧ value.eval context ≤ last.eval context)
  | .andThen left right => left.eval context && right.eval context
  | .orElse left right => left.eval context || right.eval context
  | .not value => !value.eval context
  | .group value => value.eval context
  | .whitespace value => Silver.whitespace (value.eval context).toNat
  | .identifier value => identifierCharacter (value.eval context).toNat
  | .lineEnd value => Silver.lineEnd (value.eval context).toNat
  | .allowed value => allowedCharacter (value.eval context).toNat
  | .forallWord body => (List.range context.word.length).all
      (fun i => body.eval { context with index := i + 1 })
  | .forallText body => context.text.all (fun c => body.eval { context with item := c })
  | .tokenAt position token => Cursor.tokenAt context.text (position.eval context).toNat
      (tokenFor (token.eval context))
  | .suffix position nextToken => Cursor.suffixAtIndex context.text (position.eval context).toNat (nextToken.eval context).toNat
  | .allowedNormalized => context.text.all allowedCharacter
  | .suffixNormalized => Cursor.suffixAtIndex context.text 1 1
  | .ite condition yes no => if condition.eval context then yes.eval context else no.eval context
end

def commentBody : Number :=
  .ite (.orElse (.greater .position .last) (.lineEnd (.textAt .position)))
    .position (.comment (.add .position (.literal 1)))

def triviaBody : Number :=
  .ite (.greater .position .last) .position
    (.elsif (.whitespace (.textAt .position)) (.trivia (.add .position (.literal 1)))
      (.elsif
        (.andThen
          (.andThen (.equal (.textAt .position) (.introducerAt (.literal 1))) (.less .position .last))
          (.equal (.textAt (.add .position (.literal 1))) (.introducerAt (.literal 2))))
        (.trivia (.comment (.add .position (.literal 2)))) .position))

def tokenBody : Condition :=
  .andThen
    (.andThen
      (.lessEqual .wordLength (.add (.group (.sub .last .position)) (.literal 1)))
      (.group (.forallWord (.equal
        (.lower (.textAt (.sub (.group (.add .position .index)) (.literal 1))))
        (.wordAt .index)))))
    (.group (.orElse
      (.orElse (.not .wordFlag) (.greater (.add .position .wordLength) .last))
      (.not (.identifier (.textAt (.add .position .wordLength))))))

def suffixBody : Condition :=
  .ite (.greater .nextToken .tokenLast)
    (.equal (.trivia .position) (.add .last (.literal 1)))
    (.andThen (.tokenAt (.trivia .position) .nextToken)
      (.suffix (.add (.trivia .position) (.spellingLength .nextToken))
        (.add .nextToken (.literal 1))))

def memberBody : Condition :=
  .andThen (.andThen (.range .sourceLength (.literal 1) .maxLength) .allowedNormalized) .suffixNormalized

def allowedBody : Condition := .forallText (.allowed .item)

def whitespaceBody : Condition :=
  .orElse (.orElse (.orElse (.equal .item (.character 32))
    (.equal .item (.characterVal (.literal 9))))
    (.equal .item (.characterVal (.literal 10))))
    (.equal .item (.characterVal (.literal 13)))

def allowedCharacterBody : Condition :=
  .orElse (.range .item (.character 32) (.character 126)) (.whitespace .item)

def lineEndBody : Condition :=
  .orElse (.equal .item (.characterVal (.literal 10)))
    (.equal .item (.characterVal (.literal 13)))

def identifierBody : Condition :=
  .orElse (.orElse (.orElse (.range .item (.character 65) (.character 90))
    (.range .item (.character 97) (.character 122)))
    (.range .item (.character 48) (.character 57)))
    (.equal .item (.character 95))

def lowercaseBody : Number :=
  .ite (.range .item (.character 65) (.character 90))
    (.characterVal (.add (.characterPos .item) (.literal 32))) .item

theorem cast_conditional (p : Prop) [Decidable p] (yes no : Nat) :
    ((if p then yes else no : Nat) : Int) = if p then (yes : Int) else (no : Int) := by
  split <;> rfl

theorem cast_equal (left right : Nat) : ((left : Int) == (right : Int)) = decide (left = right) := by
  apply Bool.eq_iff_iff.mpr
  simp only [beq_iff_eq, decide_eq_true_eq]
  omega

theorem cast_succ_equal (left right : Nat) : ((left : Int) == (right : Int) + 1) = decide (left = right + 1) := by
  apply Bool.eq_iff_iff.mpr
  simp only [beq_iff_eq, decide_eq_true_eq]
  omega

theorem whitespaceBody_denotation (context : Context) :
    whitespaceBody.eval context = Silver.whitespace context.item := by
  apply Bool.eq_iff_iff.mpr
  simp [whitespaceBody, Condition.eval, Number.eval, Silver.whitespace]
  omega

theorem character_range_denotation (context : Context) (first last : Nat) :
    (Condition.range .item (.character first) (.character last)).eval context =
      decide (first ≤ context.item ∧ context.item ≤ last) := by
  change decide ((first : Int) ≤ (context.item : Int) ∧ (context.item : Int) ≤ (last : Int)) = _
  apply Bool.eq_iff_iff.mpr
  rw [decide_eq_true_iff, decide_eq_true_iff]
  omega

theorem allowedCharacterBody_denotation (context : Context) :
    allowedCharacterBody.eval context = allowedCharacter context.item := by
  change ((Condition.range .item (.character 32) (.character 126)).eval context ||
    Silver.whitespace context.item) = _
  rw [character_range_denotation]
  rfl

theorem lineEndBody_denotation (context : Context) :
    lineEndBody.eval context = Silver.lineEnd context.item := by
  apply Bool.eq_iff_iff.mpr
  simp [lineEndBody, Condition.eval, Number.eval, Silver.lineEnd]
  omega

theorem identifierBody_denotation (context : Context) :
    identifierBody.eval context = identifierCharacter context.item := by
  change ((((Condition.range .item (.character 65) (.character 90)).eval context ||
    (Condition.range .item (.character 97) (.character 122)).eval context) ||
    (Condition.range .item (.character 48) (.character 57)).eval context) ||
    ((context.item : Int) == (95 : Int))) = _
  rw [character_range_denotation, character_range_denotation, character_range_denotation]
  apply Bool.eq_iff_iff.mpr
  simp [identifierCharacter]
  omega

theorem lowercaseBody_denotation (context : Context) :
    lowercaseBody.eval context = (lowercase context.item : Int) := by
  have h : (65 : Int) ≤ context.item ∧ (context.item : Int) ≤ 90 ↔
      65 ≤ context.item ∧ context.item ≤ 90 := by omega
  simp [lowercaseBody, Condition.eval, Number.eval, lowercase, h, cast_conditional]

theorem commentBody_denotation (context : Context)
    (hp : 1 ≤ context.position) (hl : context.position ≤ context.text.length + 1) :
    commentBody.eval context = (Cursor.commentPosition context.text context.position : Int) := by
  have he := congrArg Int.ofNat (Cursor.commentPosition_equation context.text context.position hp hl)
  simpa [commentBody, Number.eval, Condition.eval, ← Int.natCast_add, Bool.or_eq_true,
    cast_conditional] using he.symm

theorem triviaBody_denotation (context : Context)
    (hp : 1 ≤ context.position) (hl : context.position ≤ context.text.length + 1) :
    triviaBody.eval context = (Cursor.triviaPosition context.text context.position : Int) := by
  have he := congrArg Int.ofNat (Cursor.triviaPosition_equation context.text context.position hp hl)
  have htwo : ((context.position : Int) + 2).toNat = context.position + 2 := by omega
  have hchar (c : Nat) : (c : Int) = 45 ↔ c = 45 := by omega
  simpa [triviaBody, Number.eval, Condition.eval, ← Int.natCast_add, Cursor.byteAt,
    Bool.and_eq_true, and_assoc, cast_conditional, cast_equal, htwo, hchar] using he.symm

theorem allowedBody_denotation (context : Context) :
    allowedBody.eval context = context.text.all allowedCharacter := by
  simp [allowedBody, Condition.eval, Number.eval]

def wordEqualityBody : Condition := .equal
  (.lower (.textAt (.sub (.group (.add .position .index)) (.literal 1))))
  (.wordAt .index)

theorem quantified_word_denotation (context : Context) :
    (Condition.forallWord wordEqualityBody).eval context =
      decide (∀ i : Fin context.word.length,
        lowercase (Cursor.byteAt context.text (context.position + i.val)) = context.word[i.val]) := by
  apply Bool.eq_iff_iff.mpr
  simp only [Condition.eval, List.all_eq_true, List.mem_range, decide_eq_true_eq]
  have he (i : Nat) (hi : i < context.word.length) :
      wordEqualityBody.eval { context with index := i + 1 } = true ↔
        lowercase (Cursor.byteAt context.text (context.position + i)) = context.word[i] := by
    have hindex : ((context.position : Int) + (i + 1 : Nat) - 1).toNat = context.position + i := by omega
    simp only [wordEqualityBody, Condition.eval, Number.eval, Int.toNat_natCast]
    simp only [Int.natCast_one]
    rw [hindex]
    simp [Cursor.byteAt, hi, Int.ofNat_inj]
  constructor
  · intro h i
    exact (he i.val i.isLt).mp (h i.val i.isLt)
  · intro h i hi
    exact (he i hi).mpr (h ⟨i, hi⟩)

theorem tokenBody_denotation (text : Silver.Source) (position : Nat) (token : Token)
    (_hp : 1 ≤ position) (hl : position ≤ text.length + 1) :
    tokenBody.eval { text := text, position := position, word := token.spelling, wordFlag := token.isWord } =
      Cursor.tokenAt text position token := by
  let context : Context := { text := text, position := position, word := token.spelling, wordFlag := token.isWord }
  have hq := quantified_word_denotation context
  have hb : (token.spelling.length : Int) ≤ (text.length : Int) - position + 1 ↔
      token.spelling.length ≤ text.length + 1 - position := by omega
  change tokenBody.eval context = _
  simp only [tokenBody, Condition.eval]
  change (_ && (Condition.forallWord wordEqualityBody).eval context && _) = _
  rw [hq]
  simp [Number.eval, context, Cursor.tokenAt, hb, ← Int.natCast_add]

theorem memberBody_denotation (context : Context) :
    memberBody.eval context = Cursor.isMember context.text := by
  have h : (1 : Int) ≤ context.text.length ↔ 0 < context.text.length := by omega
  simp [memberBody, Condition.eval, Number.eval, Cursor.isMember, h]

theorem suffixBody_denotation (context : Context) (hn : 1 ≤ context.nextToken) :
    suffixBody.eval context = Cursor.suffixAtIndex context.text context.position context.nextToken := by
  have he := Cursor.suffixAtIndex_equation context.text context.position context.nextToken hn
  simpa [suffixBody, Condition.eval, Number.eval, tokenFor, ← Int.natCast_add,
    cast_equal, cast_succ_equal] using he.symm

end Silver.Expressions
