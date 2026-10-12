module

public import Silver.Expressions
public import Silver.Uniqueness

@[expose] public section

set_option linter.constructorNameAsVariable false

/-!
Interpret the checked expression trees with arbitrary callees. Unlike the model
interpreter, recursive calls are not identified with Cursor by definition.
DefinitionEquations records the equations of the checked Ada expression bodies;
the approved front end supplies ordinary predefined operators, array indexing,
normalization, and primitive numeric contracts on the verified machine domains.
The whole-source shape check in SourceBridge fixes the relevant binding scopes.

Every implementation satisfying those equations is proved equal to Cursor on
its legal domains by APPLYING the recursive uniqueness theorems. No assumption
states membership equivalence or proof success.
-/

namespace Silver.Expressions

structure Calls where
  comment : Silver.Source → Nat → Nat
  trivia : Silver.Source → Nat → Nat
  token : Silver.Source → Nat → Token → Bool
  suffix : Silver.Source → Nat → Nat → Bool
  normalize : Silver.Source → Silver.Source
  allowed : Silver.Source → Bool
  member : Silver.Source → Bool

mutual
def Number.evalWith (calls : Calls) (context : Context) : Number → Int
  | .literal value => value
  | .character value => value
  | .characterVal value | .characterPos value => value.evalWith calls context
  | .position => context.position
  | .last => context.text.length
  | .index => context.index
  | .nextToken => context.nextToken
  | .wordLength => context.word.length
  | .sourceLength => context.text.length
  | .tokenLast => requiredTokens.length
  | .maxLength => maxSourceLength
  | .item => context.item
  | .add left right => left.evalWith calls context + right.evalWith calls context
  | .sub left right => left.evalWith calls context - right.evalWith calls context
  | .group value => value.evalWith calls context
  | .textAt position => Cursor.byteAt context.text (position.evalWith calls context).toNat
  | .wordAt position => Cursor.byteAt context.word (position.evalWith calls context).toNat
  | .introducerAt position => Cursor.byteAt [45, 45] (position.evalWith calls context).toNat
  | .lower value => Silver.lowercase (value.evalWith calls context).toNat
  | .comment position => calls.comment context.text (position.evalWith calls context).toNat
  | .trivia position => calls.trivia context.text (position.evalWith calls context).toNat
  | .spellingLength index => (tokenFor (index.evalWith calls context)).spelling.length
  | .ite condition yes no | .elsif condition yes no =>
      if condition.evalWith calls context then yes.evalWith calls context else no.evalWith calls context

def Condition.evalWith (calls : Calls) (context : Context) : Condition → Bool
  | .wordFlag => context.wordFlag
  | .equal left right => left.evalWith calls context == right.evalWith calls context
  | .less left right => decide (left.evalWith calls context < right.evalWith calls context)
  | .greater left right => decide (left.evalWith calls context > right.evalWith calls context)
  | .lessEqual left right => decide (left.evalWith calls context ≤ right.evalWith calls context)
  | .range value first last => decide (first.evalWith calls context ≤ value.evalWith calls context ∧ value.evalWith calls context ≤ last.evalWith calls context)
  | .andThen left right => left.evalWith calls context && right.evalWith calls context
  | .orElse left right => left.evalWith calls context || right.evalWith calls context
  | .not value => !value.evalWith calls context
  | .group value => value.evalWith calls context
  | .whitespace value => Silver.whitespace (value.evalWith calls context).toNat
  | .identifier value => identifierCharacter (value.evalWith calls context).toNat
  | .lineEnd value => Silver.lineEnd (value.evalWith calls context).toNat
  | .allowed value => allowedCharacter (value.evalWith calls context).toNat
  | .forallWord body => (List.range context.word.length).all
      (fun i => body.evalWith calls { context with index := i + 1 })
  | .forallText body => context.text.all (fun c => body.evalWith calls { context with item := c })
  | .tokenAt position token => calls.token context.text (position.evalWith calls context).toNat
      (tokenFor (token.evalWith calls context))
  | .suffix position nextToken => calls.suffix context.text (position.evalWith calls context).toNat (nextToken.evalWith calls context).toNat
  | .allowedNormalized => calls.allowed (calls.normalize context.text)
  | .suffixNormalized => calls.suffix (calls.normalize context.text) 1 1
  | .ite condition yes no => if condition.evalWith calls context then yes.evalWith calls context else no.evalWith calls context
end

/-- Exact domain of the SPARK ghost routines after source normalization. -/
abbrev ValidText (text : Silver.Source) : Prop :=
  0 < text.length ∧ text.length ≤ maxSourceLength

structure DefinitionEquations (calls : Calls) : Prop where
  normalize : ∀ text, text.length ≤ maxSourceLength → calls.normalize text = text
  allowed : ∀ text, calls.allowed text = allowedBody.evalWith calls { text := text }
  comment : ∀ text, ValidText text → ∀ position, 1 ≤ position → position ≤ text.length + 1 →
    (calls.comment text position : Int) = commentBody.evalWith calls { text := text, position := position }
  trivia : ∀ text, ValidText text → ∀ position, 1 ≤ position → position ≤ text.length + 1 →
    (calls.trivia text position : Int) = triviaBody.evalWith calls { text := text, position := position }
  token : ∀ text, ValidText text → ∀ position token, 1 ≤ position → position ≤ text.length + 1 →
    calls.token text position token = tokenBody.evalWith calls
      { text := text, position := position, word := token.spelling, wordFlag := token.isWord }
  suffix : ∀ text, ValidText text → ∀ position nextToken,
    1 ≤ position → position ≤ text.length + 1 →
    1 ≤ nextToken → nextToken ≤ requiredTokens.length + 1 →
    calls.suffix text position nextToken = suffixBody.evalWith calls
      { text := text, position := position, nextToken := nextToken }
  member : ∀ text, calls.member text = memberBody.evalWith calls { text := text }

theorem comment_implementation_eq (calls : Calls) (equations : DefinitionEquations calls)
    (text : Silver.Source) (valid : ValidText text) (position : Nat)
    (hp : 1 ≤ position) (hl : position ≤ text.length + 1) :
    calls.comment text position = Cursor.commentPosition text position := by
  apply Cursor.commentPosition_unique text (calls.comment text) _ position hp hl
  intro cursor hfirst hlast
  have equation := equations.comment text valid cursor hfirst hlast
  apply Int.ofNat.inj
  simpa [commentBody, Number.evalWith, Condition.evalWith, cast_conditional,
    Bool.or_eq_true, ← Int.natCast_add] using equation

theorem trivia_implementation_eq (calls : Calls) (equations : DefinitionEquations calls)
    (text : Silver.Source) (valid : ValidText text) (position : Nat)
    (hp : 1 ≤ position) (hl : position ≤ text.length + 1) :
    calls.trivia text position = Cursor.triviaPosition text position := by
  apply Cursor.triviaPosition_unique text (calls.trivia text) _ position hp hl
  intro cursor hfirst hlast
  have equation := equations.trivia text valid cursor hfirst hlast
  have hchar (value : Nat) : (value : Int) = 45 ↔ value = 45 := by omega
  have htwo : ((cursor : Int) + 2).toNat = cursor + 2 := by omega
  have raw : calls.trivia text cursor =
      if cursor > text.length then cursor
      else if whitespace (Cursor.byteAt text cursor) then calls.trivia text (cursor + 1)
      else if Cursor.byteAt text cursor = 45 ∧ cursor < text.length ∧ Cursor.byteAt text (cursor + 1) = 45
      then calls.trivia text (calls.comment text (cursor + 2))
      else cursor := by
    apply Int.ofNat.inj
    simpa [triviaBody, Number.evalWith, Condition.evalWith, cast_conditional,
      Bool.and_eq_true, and_assoc, ← Int.natCast_add, Cursor.byteAt, hchar, htwo] using equation
  rw [raw]
  by_cases finished : cursor > text.length
  · simp [finished]
  · simp only [finished, ↓reduceIte]
    by_cases space : whitespace (Cursor.byteAt text cursor) = true
    · simp [space]
    · simp only [space, Bool.false_eq_true, ↓reduceIte]
      by_cases comment : Cursor.byteAt text cursor = 45 ∧ cursor < text.length ∧ Cursor.byteAt text (cursor + 1) = 45
      · rw [ite_eq_left comment, ite_eq_left comment,
          comment_implementation_eq calls equations text valid (cursor + 2) (by omega) (by omega)]
      · simp [comment]

theorem token_implementation_eq (calls : Calls) (equations : DefinitionEquations calls)
    (text : Silver.Source) (valid : ValidText text) (position : Nat) (token : Token)
    (hp : 1 ≤ position) (hl : position ≤ text.length + 1) :
    calls.token text position token = Cursor.tokenAt text position token := by
  rw [equations.token text valid position token hp hl]
  exact tokenBody_denotation text position token hp hl

theorem suffix_implementation_eq (calls : Calls) (equations : DefinitionEquations calls)
    (text : Silver.Source) (valid : ValidText text) (position nextToken : Nat)
    (hp : 1 ≤ position) (hl : position ≤ text.length + 1)
    (hn : 1 ≤ nextToken) (ht : nextToken ≤ requiredTokens.length + 1) :
    calls.suffix text position nextToken = Cursor.suffixAtIndex text position nextToken := by
  apply Cursor.suffixAtIndex_unique text (calls.suffix text) _ position nextToken hp hl hn ht
  intro cursor next hfirst hlast hnext hbound
  rw [equations.suffix text valid cursor next hfirst hlast hnext hbound]
  have trivia := trivia_implementation_eq calls equations text valid cursor hfirst hlast
  have bounds := Cursor.triviaPosition_bounds text cursor hfirst hlast
  have token := token_implementation_eq calls equations text valid
    (Cursor.triviaPosition text cursor) (requiredTokens.getD (next - 1) .semicolon) (by omega) bounds.2
  have equality := congrArg (fun matched =>
    if next > requiredTokens.length then decide (Cursor.triviaPosition text cursor = text.length + 1)
    else matched && calls.suffix text
      (Cursor.triviaPosition text cursor + (requiredTokens.getD (next - 1) .semicolon).spelling.length)
      (next + 1)) token
  simpa [suffixBody, Number.evalWith, Condition.evalWith, tokenFor, trivia,
    ← Int.natCast_add, cast_succ_equal] using equality

theorem allowed_implementation_eq (calls : Calls) (equations : DefinitionEquations calls)
    (text : Silver.Source) : calls.allowed text = text.all allowedCharacter := by
  rw [equations.allowed]
  rfl

/-- Every interpretation of the checked bodies has the independent membership
predicate; recursive callees are derived, never fixed to the model by definition. -/
theorem member_implementation_eq (calls : Calls) (equations : DefinitionEquations calls)
    (text : Silver.Source) : calls.member text = Cursor.isMember text := by
  rw [equations.member]
  have h : (1 : Int) ≤ text.length ↔ 0 < text.length := by omega
  have range : (Condition.range .sourceLength (.literal 1) .maxLength).evalWith calls
      { text := text } = decide (ValidText text) := by
    simp [Condition.evalWith, Number.evalWith, ValidText, h]
  change ((Condition.range .sourceLength (.literal 1) .maxLength).evalWith calls
    { text := text } && calls.allowed (calls.normalize text) &&
      calls.suffix (calls.normalize text) 1 1) = _
  rw [range]
  by_cases valid : ValidText text
  · rw [equations.normalize text valid.2, allowed_implementation_eq calls equations text,
      suffix_implementation_eq calls equations text valid 1 1
        (by omega) (by omega) (by omega) (by decide)]
    rfl
  · change (decide (ValidText text) && _ && _) = (decide (ValidText text) && _ && _)
    simp [valid]

theorem member_implementation_iff (calls : Calls) (equations : DefinitionEquations calls)
    (text : Silver.Source) : calls.member text = true ↔ Member text := by
  rw [member_implementation_eq calls equations text]
  exact Cursor.isMember_iff text

/-- The model is an explicit witness that the definition-equation interface is
inhabited. Physical SPARK interpretation additionally uses the reviewed frontend
semantics and the GNATprove-checked machine bounds and refinement contracts. -/
def modelCalls : Calls where
  comment := Cursor.commentPosition
  trivia := Cursor.triviaPosition
  token := Cursor.tokenAt
  suffix := Cursor.suffixAtIndex
  normalize := id
  allowed := fun text => text.all allowedCharacter
  member := Cursor.isMember

theorem model_equations : DefinitionEquations modelCalls := by
  constructor
  · intro text _
    rfl
  · intro text
    rfl
  · intro text _ position hp hl
    exact (commentBody_denotation { text := text, position := position } hp hl).symm
  · intro text _ position hp hl
    exact (triviaBody_denotation { text := text, position := position } hp hl).symm
  · intro text _ position token hp hl
    exact (tokenBody_denotation text position token hp hl).symm
  · intro text _ position nextToken _ _ hn _
    exact (suffixBody_denotation { text := text, position := position, nextToken := nextToken } hn).symm
  · intro text
    exact (memberBody_denotation { text := text }).symm

end Silver.Expressions
