import Silver.OutputAdmission
import Silver.Uniqueness
import Silver.Expressions

namespace Silver.Output

def suffixAtIndex (text : Source) (position nextToken : Nat) : Bool :=
  suffixMatches text (requiredTokens.drop (nextToken - 1)) position

def suffixEquation (trivia literal : Nat → Nat) (tokenMatch : Nat → Token → Bool)
    (suffix : Nat → Nat → Bool) (text : Source) (position nextToken : Nat) : Bool :=
  if nextToken > requiredTokens.length then decide (trivia position = text.length + 1)
  else
    let token := requiredTokens.getD (nextToken - 1) .semicolon
    let start := trivia position
    if token = .stringLiteral then
      decide (start ≤ text.length) && (Cursor.byteAt text start == 34) &&
        decide (literal (start + 1) ≠ 0) && suffix (literal (start + 1)) (nextToken + 1)
    else tokenMatch start token && suffix (start + token.spelling.length) (nextToken + 1)

theorem suffixAtIndex_equation (text : Source) (position nextToken : Nat) (hn : 1 ≤ nextToken) :
    suffixAtIndex text position nextToken =
    suffixEquation (Cursor.triviaPosition text) (literalEnd text) (tokenAt text)
      (suffixAtIndex text) text position nextToken := by
  unfold suffixAtIndex suffixEquation
  by_cases finished : nextToken > requiredTokens.length
  · have enough : requiredTokens.length ≤ nextToken - 1 := by omega
    simp [finished, List.drop_eq_nil_of_le enough, suffixMatches]
  · have index : nextToken - 1 < requiredTokens.length := by omega
    have drop := List.drop_eq_getElem_cons index
    have next : nextToken - 1 + 1 = nextToken := by omega
    simp only [finished, ↓reduceIte, Nat.add_sub_cancel, drop, suffixMatches, next]
    simp only [List.getD, List.getElem?_eq_getElem index, Option.getD_some]

def literalEquation (implementation : Nat → Nat) (text : Source) (position : Nat) : Nat :=
  if position > text.length then 0
  else if Cursor.byteAt text position = 34 then
    if position < text.length ∧ Cursor.byteAt text (position + 1) = 34 then
      implementation (position + 2)
    else position + 1
  else if printable (Cursor.byteAt text position) then implementation (position + 1)
  else 0

theorem literalEnd_unique (text : Source) (implementation : Nat → Nat)
    (equation : ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      implementation position = literalEquation implementation text position)
    (position : Nat) (first : 1 ≤ position) (last : position ≤ text.length + 1) :
    implementation position = literalEnd text position := by
  rw [equation position first last, literalEnd]
  unfold literalEquation
  by_cases finished : position > text.length
  · simp [finished]
  · simp only [finished, ↓reduceIte]
    by_cases quote : Cursor.byteAt text position = 34
    · simp only [quote, ↓reduceIte]
      by_cases doubled : position < text.length ∧ Cursor.byteAt text (position + 1) = 34
      · simp only [doubled]
        exact literalEnd_unique text implementation equation (position + 2) (by omega) (by omega)
      · simp [doubled]
    · simp only [quote, ↓reduceIte]
      by_cases character : printable (Cursor.byteAt text position) = true
      · simp only [character, ↓reduceIte]
        exact literalEnd_unique text implementation equation (position + 1) (by omega) (by omega)
      · simp [character]
termination_by text.length + 1 - position
decreasing_by all_goals omega

theorem suffixAtIndex_unique (text : Source) (implementation : Nat → Nat → Bool)
    (equation : ∀ position nextToken, 1 ≤ position → position ≤ text.length + 1 →
      1 ≤ nextToken → nextToken ≤ requiredTokens.length + 1 →
      implementation position nextToken =
        suffixEquation (Cursor.triviaPosition text) (literalEnd text) (tokenAt text)
          implementation text position nextToken)
    (position nextToken : Nat) (first : 1 ≤ position) (last : position ≤ text.length + 1)
    (start : 1 ≤ nextToken) (stop : nextToken ≤ requiredTokens.length + 1) :
    implementation position nextToken = suffixAtIndex text position nextToken := by
  rw [equation position nextToken first last start stop,
    suffixAtIndex_equation text position nextToken start]
  unfold suffixEquation
  by_cases finished : nextToken > requiredTokens.length
  · simp [finished]
  · simp only [finished, ↓reduceIte]
    let token := requiredTokens.getD (nextToken - 1) .semicolon
    have trivia := Cursor.triviaPosition_bounds text position first last
    by_cases literal : token = .stringLiteral
    · change (if token = .stringLiteral then _ else _) = (if token = .stringLiteral then _ else _)
      simp only [literal, ↓reduceIte]
      by_cases fits : Cursor.triviaPosition text position ≤ text.length
      · by_cases nonzero : literalEnd text (Cursor.triviaPosition text position + 1) ≠ 0
        · have bounds := literalEnd_bounds text _ nonzero
          have recurse := suffixAtIndex_unique text implementation equation
            (literalEnd text (Cursor.triviaPosition text position + 1)) (nextToken + 1)
            (by omega) bounds.2 (by omega) (by omega)
          rw [recurse]
        · simp [nonzero]
      · simp [fits]
    · change (if token = .stringLiteral then _ else _) = (if token = .stringLiteral then _ else _)
      simp only [literal, ↓reduceIte]
      change (tokenAt text (Cursor.triviaPosition text position) token &&
        implementation (Cursor.triviaPosition text position + token.spelling.length) (nextToken + 1)) =
        (tokenAt text (Cursor.triviaPosition text position) token &&
        suffixAtIndex text (Cursor.triviaPosition text position + token.spelling.length) (nextToken + 1))
      by_cases matched : tokenAt text (Cursor.triviaPosition text position) token = true
      · have enough : token.spelling.length ≤ text.length + 1 - Cursor.triviaPosition text position := by
          have h := matched
          simp only [tokenAt, Bool.and_eq_true, decide_eq_true_eq] at h
          exact h.1.1
        have recurse := suffixAtIndex_unique text implementation equation
          (Cursor.triviaPosition text position + token.spelling.length) (nextToken + 1)
          (by omega) (by omega) (by omega) (by omega)
        simp only [matched, Bool.true_and]
        exact recurse
      · simp [Bool.eq_false_iff.mpr matched]
termination_by requiredTokens.length + 1 - nextToken
decreasing_by all_goals omega

/-- These are definition equations, not assumptions of membership correctness
or proof success. SourceBridge checks the precise bodies and surrounding scope.
The frontend interpretation supplies these equations only on verified domains. -/
structure Calls where
  literal : Source → Nat → Nat
  suffix : Source → Nat → Nat → Bool
  member : Source → Bool

structure DefinitionEquations (calls : Calls) : Prop where
  literal : ∀ text, 0 < text.length → text.length ≤ 4096 →
    ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      calls.literal text position = literalEquation (calls.literal text) text position
  suffix : ∀ text, 0 < text.length → text.length ≤ 4096 →
    ∀ position nextToken, 1 ≤ position → position ≤ text.length + 1 →
      1 ≤ nextToken → nextToken ≤ requiredTokens.length + 1 →
      calls.suffix text position nextToken =
        suffixEquation (Cursor.triviaPosition text) (calls.literal text) (tokenAt text)
          (calls.suffix text) text position nextToken
  member : ∀ text, calls.member text =
    (decide (0 < text.length ∧ text.length ≤ maxSourceLength) &&
      text.all allowedCharacter && calls.suffix text 1 1)

theorem implementation_literal (calls : Calls) (equations : DefinitionEquations calls)
    (text : Source) (positive : 0 < text.length) (bounded : text.length ≤ 4096)
    (position : Nat) (first : 1 ≤ position) (last : position ≤ text.length + 1) :
    calls.literal text position = literalEnd text position :=
  literalEnd_unique text _ (equations.literal text positive bounded) position first last

theorem implementation_suffix (calls : Calls) (equations : DefinitionEquations calls)
    (text : Source) (positive : 0 < text.length) (bounded : text.length ≤ 4096)
    (position nextToken : Nat) (first : 1 ≤ position) (last : position ≤ text.length + 1)
    (start : 1 ≤ nextToken) (stop : nextToken ≤ requiredTokens.length + 1) :
    calls.suffix text position nextToken = suffixAtIndex text position nextToken := by
  apply suffixAtIndex_unique text (calls.suffix text) _ position nextToken first last start stop
  intro position nextToken first last start stop
  rw [equations.suffix text positive bounded position nextToken first last start stop]
  unfold suffixEquation
  split
  · rfl
  · dsimp only
    split
    · by_cases fits : Cursor.triviaPosition text position ≤ text.length
      · have trivia := Cursor.triviaPosition_bounds text position first last
        rw [implementation_literal calls equations text positive bounded
          (Cursor.triviaPosition text position + 1) (by omega) (by omega)]
      · simp [fits]
    · rfl

theorem implementation_member_iff (calls : Calls) (equations : DefinitionEquations calls)
    (source : Source) : calls.member source = true ↔ Member source := by
  rw [equations.member]
  by_cases bounds : 0 < source.length ∧ source.length ≤ maxSourceLength
  · rw [implementation_suffix calls equations source bounds.1 bounds.2 1 1
      (by decide) (by omega) (by decide) (by decide)]
    simpa [accepts, suffixAtIndex] using accepts_iff_member source
  · simp only [bounds, decide_false, Bool.false_and, Bool.false_eq_true, false_iff]
    intro member
    exact bounds ⟨member.1, member.2.1⟩

theorem token_expression_denotation (text : Source) (position : Nat) (token : Token)
    (last : position ≤ text.length + 1) :
    Expressions.tokenBody.eval
      { text := text, position := position, word := token.spelling, wordFlag := token.isWord } =
      tokenAt text position token := by
  let context : Expressions.Context :=
    { text := text, position := position, word := token.spelling, wordFlag := token.isWord }
  have quantified := Expressions.quantified_word_denotation context
  have bound : (token.spelling.length : Int) ≤ (text.length : Int) - position + 1 ↔
      token.spelling.length ≤ text.length + 1 - position := by omega
  change Expressions.tokenBody.eval context = _
  simp only [Expressions.tokenBody, Expressions.Condition.eval]
  change (_ && (Expressions.Condition.forallWord Expressions.wordEqualityBody).eval context && _) = _
  rw [quantified]
  simp [Expressions.Number.eval, context, tokenAt, bound, ← Int.natCast_add]

structure PrimitiveCalls where
  comment : Source → Nat → Nat
  trivia : Source → Nat → Nat
  token : Source → Nat → Token → Bool
  normalize : Source → Source
  allowed : Source → Bool

structure PrimitiveEquations (calls : PrimitiveCalls) : Prop where
  comment : ∀ text, 0 < text.length → text.length ≤ 4096 → ∀ position, 1 ≤ position → position ≤ text.length + 1 →
    calls.comment text position =
      if position > text.length ∨ lineEnd (Cursor.byteAt text position) = true then position
      else calls.comment text (position + 1)
  trivia : ∀ text, 0 < text.length → text.length ≤ 4096 → ∀ position, 1 ≤ position → position ≤ text.length + 1 →
    calls.trivia text position =
      if position > text.length then position
      else if whitespace (Cursor.byteAt text position) then calls.trivia text (position + 1)
      else if Cursor.byteAt text position = 45 ∧ position < text.length ∧
        Cursor.byteAt text (position + 1) = 45
      then calls.trivia text (calls.comment text (position + 2)) else position
  token : ∀ text, 0 < text.length → text.length ≤ 4096 → ∀ position token,
    1 ≤ position → position ≤ text.length + 1 →
    calls.token text position token = Expressions.tokenBody.eval
      { text := text, position := position, word := token.spelling, wordFlag := token.isWord }
  normalize : ∀ text, text.length ≤ 4096 → calls.normalize text = text
  allowed : ∀ text, calls.allowed text = text.all allowedCharacter

theorem primitive_trivia (calls : PrimitiveCalls) (equations : PrimitiveEquations calls)
    (text : Source) (positive : 0 < text.length) (bounded : text.length ≤ 4096)
    (position : Nat) (first : 1 ≤ position) (last : position ≤ text.length + 1) :
    calls.trivia text position = Cursor.triviaPosition text position := by
  apply Cursor.triviaPosition_unique text (calls.trivia text) _ position first last
  intro cursor first last
  rw [equations.trivia text positive bounded cursor first last]
  by_cases finished : cursor > text.length
  · simp [finished]
  · simp only [finished, ↓reduceIte]
    by_cases space : whitespace (Cursor.byteAt text cursor) = true
    · simp [space]
    · simp only [space, Bool.false_eq_true, ↓reduceIte]
      by_cases comment : Cursor.byteAt text cursor = 45 ∧ cursor < text.length ∧
          Cursor.byteAt text (cursor + 1) = 45
      · rw [ite_eq_left comment, ite_eq_left comment,
          Cursor.commentPosition_unique text (calls.comment text) (equations.comment text positive bounded)
            (cursor + 2) (by omega) (by omega)]
      · simp [comment]

structure SourceEquations (calls : Calls) (primitives : PrimitiveCalls) : Prop where
  primitive : PrimitiveEquations primitives
  literal : ∀ text, 0 < text.length → text.length ≤ 4096 →
    ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      calls.literal text position = literalEquation (calls.literal text) text position
  suffix : ∀ text, 0 < text.length → text.length ≤ 4096 →
    ∀ position nextToken, 1 ≤ position → position ≤ text.length + 1 →
      1 ≤ nextToken → nextToken ≤ requiredTokens.length + 1 →
      calls.suffix text position nextToken =
        suffixEquation (primitives.trivia text) (calls.literal text) (primitives.token text)
          (calls.suffix text) text position nextToken
  member : ∀ text, calls.member text =
    (decide (0 < text.length ∧ text.length ≤ maxSourceLength) &&
      primitives.allowed (primitives.normalize text) &&
      calls.suffix (primitives.normalize text) 1 1)

theorem source_equations_reduce (calls : Calls) (primitives : PrimitiveCalls)
    (equations : SourceEquations calls primitives) : DefinitionEquations calls where
  literal := equations.literal
  suffix := by
    intro text positive bounded position nextToken first last start stop
    rw [equations.suffix text positive bounded position nextToken first last start stop]
    unfold suffixEquation
    rw [primitive_trivia primitives equations.primitive text positive bounded position first last]
    by_cases finished : nextToken > requiredTokens.length
    · simp [finished]
    · simp only [finished, ↓reduceIte]
      split
      · rfl
      · rw [equations.primitive.token text positive bounded _ _
          (Nat.le_trans first (Cursor.triviaPosition_bounds text position first last).1)
          (Cursor.triviaPosition_bounds text position first last).2,
          token_expression_denotation text _ _
          (Cursor.triviaPosition_bounds text position first last).2]
  member := by
    intro text
    rw [equations.member]
    by_cases bound : 0 < text.length ∧ text.length ≤ maxSourceLength
    · rw [equations.primitive.normalize text bound.2, equations.primitive.allowed]
    · simp [bound]

theorem source_implementation_member_iff (calls : Calls) (primitives : PrimitiveCalls)
    (equations : SourceEquations calls primitives) (source : Source) :
    calls.member source = true ↔ Member source :=
  implementation_member_iff calls (source_equations_reduce calls primitives equations) source

end Silver.Output
