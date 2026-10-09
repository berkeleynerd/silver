import Silver.NamedAdmission
import Silver.OutputEquations

namespace Silver.Named

structure IdentifierCalls where
  tail : Source → Nat → Bool → Nat
  finish : Source → Nat → Nat
  name : Source → Nat → Nat → Source → Bool
  equal : Source → Nat → Nat → Nat → Nat → Bool
  forbidden : Source → Nat → Nat → Bool

/-- Definition equations on the verified machine domain. These are a target
for the checked typed source interpretation, never an assumption of membership
or solver correctness. Primitive lexical equations are discharged separately. -/
structure IdentifierEquations (calls : IdentifierCalls) : Prop where
  tail : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position previous, 1 ≤ position → position ≤ text.length + 1 →
      calls.tail text position previous = identifierTailEquation (calls.tail text) text position previous
  finish : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      calls.finish text position =
        if position ≤ text.length ∧ letter (Cursor.byteAt text position) = true then
          calls.tail text (position + 1) false else 0
  name : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ first after word, 1 ≤ first → first < after → after ≤ text.length + 1 →
      0 < word.length → word.length ≤ maxSourceLength →
      calls.name text first after word = nameIs text first after word
  equal : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ leftFirst leftAfter rightFirst rightAfter,
      1 ≤ leftFirst → leftFirst < leftAfter → leftAfter ≤ text.length + 1 →
      1 ≤ rightFirst → rightFirst < rightAfter → rightAfter ≤ text.length + 1 →
      calls.equal text leftFirst leftAfter rightFirst rightAfter =
        equalName text leftFirst leftAfter rightFirst rightAfter
  forbidden : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ first after, 1 ≤ first → first < after → after ≤ text.length + 1 →
      calls.forbidden text first after = forbiddenNames.any (calls.name text first after)

theorem identifier_implementation (calls : IdentifierCalls) (equations : IdentifierEquations calls)
    (text : Source) (positive : 0 < text.length) (bounded : text.length ≤ maxSourceLength)
    (position : Nat) (first : 1 ≤ position) (last : position ≤ text.length + 1) :
    calls.finish text position = identifierEnd text position := by
  rw [equations.finish text positive bounded position first last]
  unfold identifierEnd
  split
  · rename_i valid
    exact identifierTail_unique_equations text (calls.tail text) (equations.tail text positive bounded)
      (position + 1) false (by omega) (by omega)
  · rfl

theorem forbidden_word_bounds : ∀ word ∈ forbiddenNames,
    0 < word.length ∧ word.length ≤ maxSourceLength := by decide +kernel

theorem forbidden_implementation (calls : IdentifierCalls) (equations : IdentifierEquations calls)
    (text : Source) (positive : 0 < text.length) (bounded : text.length ≤ maxSourceLength)
    (first after : Nat) (start : 1 ≤ first) (ordered : first < after) (last : after ≤ text.length + 1) :
    calls.forbidden text first after = forbiddenName text first after := by
  rw [equations.forbidden text positive bounded first after start ordered last]
  unfold forbiddenName
  apply Bool.eq_iff_iff.mpr
  simp only [List.any_eq_true]
  constructor <;> rintro ⟨word, member, matched⟩ <;> refine ⟨word, member, ?_⟩
  · rw [equations.name text positive bounded first after word start ordered last
      (forbidden_word_bounds word member).1 (forbidden_word_bounds word member).2] at matched
    exact matched
  · rw [equations.name text positive bounded first after word start ordered last
      (forbidden_word_bounds word member).1 (forbidden_word_bounds word member).2]
    exact matched

def suffixAtIndex (text : Source) (position nextToken : Nat) (state : NameState) : Bool :=
  suffixMatches text (requiredTokens.drop (nextToken - 1)) position state

def suffixEquation (recurse : Nat → Nat → NameState → Bool) (text : Source)
    (position nextToken : Nat) (state : NameState) : Bool :=
  if nextToken > requiredTokens.length then decide (Cursor.triviaPosition text position = text.length + 1)
  else
    let token := requiredTokens.getD (nextToken - 1) (.base .semicolon)
    let start := Cursor.triviaPosition text position
    if token = .declarationName then
      decide (identifierEnd text start ≠ 0) && !forbiddenName text start (identifierEnd text start) &&
        recurse (identifierEnd text start) (nextToken + 1) ⟨start, identifierEnd text start⟩
    else if token = .referenceName then
      decide (0 < state.first) && decide (identifierEnd text start ≠ 0) &&
        equalName text state.first state.after start (identifierEnd text start) &&
        recurse (identifierEnd text start) (nextToken + 1) state
    else if token = .base .stringLiteral then
      decide (start ≤ text.length) && (Cursor.byteAt text start == 34) &&
        decide (Output.literalEnd text (start + 1) ≠ 0) &&
        recurse (Output.literalEnd text (start + 1)) (nextToken + 1) state
    else tokenAt text start token && recurse (start + token.spelling.length) (nextToken + 1) state

theorem suffixAtIndex_equation (text : Source) (position nextToken : Nat) (state : NameState)
    (first : 1 ≤ nextToken) :
    suffixAtIndex text position nextToken state = suffixEquation (suffixAtIndex text) text position nextToken state := by
  unfold suffixAtIndex suffixEquation
  by_cases finished : nextToken > requiredTokens.length
  · have enough : requiredTokens.length ≤ nextToken - 1 := by omega
    simp [finished, List.drop_eq_nil_of_le enough, suffixMatches]
  · have index : nextToken - 1 < requiredTokens.length := by omega
    have drop := List.drop_eq_getElem_cons index
    have next : nextToken - 1 + 1 = nextToken := by omega
    simp only [finished, ↓reduceIte, Nat.add_sub_cancel, drop, suffixMatches, next]
    simp only [List.getD, List.getElem?_eq_getElem index, Option.getD_some]

theorem suffixAtIndex_unique (text : Source) (implementation : Nat → Nat → NameState → Bool)
    (equations : ∀ position nextToken state,
      1 ≤ position → position ≤ text.length + 1 → 1 ≤ nextToken → nextToken ≤ requiredTokens.length + 1 →
      state.Valid text → implementation position nextToken state =
        suffixEquation implementation text position nextToken state)
    (position nextToken : Nat) (state : NameState)
    (positive : 1 ≤ position) (bounded : position ≤ text.length + 1)
    (first : 1 ≤ nextToken) (last : nextToken ≤ requiredTokens.length + 1) (valid : state.Valid text) :
    implementation position nextToken state = suffixAtIndex text position nextToken state := by
  rw [equations position nextToken state positive bounded first last valid,
    suffixAtIndex_equation text position nextToken state first]
  unfold suffixEquation
  by_cases finished : nextToken > requiredTokens.length
  · simp [finished]
  · simp only [finished, ↓reduceIte]
    let token := requiredTokens.getD (nextToken - 1) (.base .semicolon)
    let start := Cursor.triviaPosition text position
    have trivia := Cursor.triviaPosition_bounds text position positive bounded
    have startPositive : 1 ≤ start := by dsimp [start]; omega
    by_cases declaration : token = .declarationName
    · change (if token = .declarationName then _ else _) = (if token = .declarationName then _ else _)
      simp only [declaration, ↓reduceIte]
      by_cases nonzero : identifierEnd text start ≠ 0
      · have bounds := identifierEnd_bounds text start nonzero
        have nextValid : (⟨start, identifierEnd text start⟩ : NameState).Valid text := by
          right
          exact ⟨startPositive, bounds.1, bounds.2⟩
        rw [suffixAtIndex_unique text implementation equations (identifierEnd text start) (nextToken + 1)
          ⟨start, identifierEnd text start⟩ (by omega) bounds.2 (by omega) (by omega)
          nextValid]
      · simp [start] at nonzero
        simp [nonzero]
    · change (if token = .declarationName then _ else _) = (if token = .declarationName then _ else _)
      simp only [declaration, ↓reduceIte]
      change (if token = .referenceName then _ else _) = (if token = .referenceName then _ else _)
      by_cases reference : token = .referenceName
      · simp only [reference, ↓reduceIte]
        by_cases nonzero : identifierEnd text start ≠ 0
        · have bounds := identifierEnd_bounds text start nonzero
          rw [suffixAtIndex_unique text implementation equations (identifierEnd text start) (nextToken + 1)
            state (by omega) bounds.2 (by omega) (by omega) valid]
        · simp [start] at nonzero
          simp [nonzero]
      · simp only [reference, ↓reduceIte]
        change (if token = .base .stringLiteral then _ else _) = (if token = .base .stringLiteral then _ else _)
        by_cases literal : token = .base .stringLiteral
        · simp only [literal, ↓reduceIte]
          by_cases nonzero : Output.literalEnd text (start + 1) ≠ 0
          · have bounds := Output.literalEnd_bounds text (start + 1) nonzero
            rw [suffixAtIndex_unique text implementation equations (Output.literalEnd text (start + 1))
              (nextToken + 1) state (by omega) bounds.2 (by omega) (by omega) valid]
          · simp [start] at nonzero
            simp [nonzero]
        · simp only [literal, ↓reduceIte]
          by_cases matched : tokenAt text start token = true
          · have enough := matched
            simp only [tokenAt, Bool.and_eq_true, decide_eq_true_eq] at enough
            rw [suffixAtIndex_unique text implementation equations (start + token.spelling.length)
              (nextToken + 1) state (by omega) (by omega) (by omega) (by omega) valid]
          · have noMatch := Bool.eq_false_iff.mpr matched
            change (tokenAt text start token && _) = (tokenAt text start token && _)
            simp [noMatch]
termination_by requiredTokens.length + 1 - nextToken
decreasing_by all_goals omega

structure Calls where
  suffix : Source → Nat → Nat → NameState → Bool
  member : Source → Bool

structure DefinitionEquations (calls : Calls) : Prop where
  suffix : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position nextToken state, 1 ≤ position → position ≤ text.length + 1 →
      1 ≤ nextToken → nextToken ≤ requiredTokens.length + 1 → state.Valid text →
      calls.suffix text position nextToken state = suffixEquation (calls.suffix text) text position nextToken state
  member : ∀ text, calls.member text =
    (decide (0 < text.length ∧ text.length ≤ maxSourceLength) && text.all allowedCharacter &&
      (Output.suffixAtIndex text 1 1 || calls.suffix text 1 1 {}))

theorem implementation_member_iff (calls : Calls) (equations : DefinitionEquations calls) (text : Source) :
    calls.member text = true ↔ Output.Member text ∨ Member text := by
  rw [equations.member]
  by_cases bound : 0 < text.length ∧ text.length ≤ maxSourceLength
  · rw [suffixAtIndex_unique text (calls.suffix text) (equations.suffix text bound.1 bound.2)
      1 1 {} (by omega) (by omega) (by omega) (by decide) (Or.inl ⟨rfl, rfl⟩)]
    rw [← Output.accepts_iff_member, ← accepts_iff_member]
    simp [Output.accepts, accepts, Output.suffixAtIndex, suffixAtIndex, bound, Bool.or_eq_true,
      Bool.and_eq_true, and_or_left]
  · have notOutput : ¬ Output.Member text := fun member => bound ⟨member.1, member.2.1⟩
    have notNamed : ¬ Member text := fun member => bound ⟨member.1, member.2.1⟩
    simp [bound, notOutput, notNamed]

/-- Concrete witnesses establish that the equation interfaces are inhabited;
actual SPARK interpretation additionally requires the checked source bridge. -/
def modelIdentifierCalls : IdentifierCalls where
  tail := identifierTail
  finish := identifierEnd
  name := nameIs
  equal := equalName
  forbidden := forbiddenName

theorem model_identifier_equations : IdentifierEquations modelIdentifierCalls where
  tail := by intros; apply identifierTail.eq_1
  finish := by intros; rfl
  name := by intros; rfl
  equal := by intros; rfl
  forbidden := by intros; rfl

def modelCalls : Calls where
  suffix := suffixAtIndex
  member := fun text =>
    decide (0 < text.length ∧ text.length ≤ maxSourceLength) && text.all allowedCharacter &&
      (Output.suffixAtIndex text 1 1 || suffixAtIndex text 1 1 {})

theorem model_equations : DefinitionEquations modelCalls where
  suffix := by
    intro text _ _ position nextToken state _ _ first _ _
    exact suffixAtIndex_equation text position nextToken state first
  member := by intros; rfl

/-- The actual named suffix equation keeps every callee arbitrary. Each call
is closed only on the short-circuit branch where its verified precondition holds. -/
def sourceSuffixEquation (trivia literal finish : Nat → Nat)
    (forbidden : Nat → Nat → Bool) (equal : Nat → Nat → Nat → Nat → Bool)
    (tokenMatch : Nat → Token → Bool) (recurse : Nat → Nat → NameState → Bool)
    (text : Source) (position nextToken : Nat) (state : NameState) : Bool :=
  if nextToken > requiredTokens.length then decide (trivia position = text.length + 1)
  else
    let token := requiredTokens.getD (nextToken - 1) (.base .semicolon)
    let start := trivia position
    if token = .declarationName then
      decide (finish start ≠ 0) && !forbidden start (finish start) &&
        recurse (finish start) (nextToken + 1) ⟨start, finish start⟩
    else if token = .referenceName then
      decide (0 < state.first) && decide (finish start ≠ 0) &&
        equal state.first state.after start (finish start) &&
        recurse (finish start) (nextToken + 1) state
    else if token = .base .stringLiteral then
      decide (start ≤ text.length) && (Cursor.byteAt text start == 34) &&
        decide (literal (start + 1) ≠ 0) &&
        recurse (literal (start + 1)) (nextToken + 1) state
    else tokenMatch start token && recurse (start + token.spelling.length) (nextToken + 1) state

/-- The checked bounds justify every helper call on the branch that evaluates
it. No equation is requested for a zero sentinel or invalid binding span. -/
theorem sourceSuffixEquation_reduce
    (trivia literal finish : Nat → Nat)
    (forbidden : Nat → Nat → Bool) (equal : Nat → Nat → Nat → Nat → Bool)
    (tokenMatch : Nat → Token → Bool) (recurse : Nat → Nat → NameState → Bool)
    (text : Source)
    (triviaEquation : ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      trivia position = Cursor.triviaPosition text position)
    (finishEquation : ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      finish position = identifierEnd text position)
    (literalEquation : ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      literal position = Output.literalEnd text position)
    (forbiddenEquation : ∀ first after, 1 ≤ first → first < after → after ≤ text.length + 1 →
      forbidden first after = forbiddenName text first after)
    (equalEquation : ∀ leftFirst leftAfter rightFirst rightAfter,
      1 ≤ leftFirst → leftFirst < leftAfter → leftAfter ≤ text.length + 1 →
      1 ≤ rightFirst → rightFirst < rightAfter → rightAfter ≤ text.length + 1 →
      equal leftFirst leftAfter rightFirst rightAfter = equalName text leftFirst leftAfter rightFirst rightAfter)
    (tokenEquation : ∀ position token, 1 ≤ position → position ≤ text.length + 1 →
      tokenMatch position token = tokenAt text position token)
    (position nextToken : Nat) (state : NameState)
    (positive : 1 ≤ position) (bounded : position ≤ text.length + 1) (valid : state.Valid text) :
    sourceSuffixEquation trivia literal finish forbidden equal tokenMatch recurse text position nextToken state =
      suffixEquation recurse text position nextToken state := by
  have triviaBounds := Cursor.triviaPosition_bounds text position positive bounded
  have startPositive : 1 ≤ Cursor.triviaPosition text position := by omega
  have startBound : Cursor.triviaPosition text position ≤ text.length + 1 := by omega
  unfold sourceSuffixEquation suffixEquation
  rw [triviaEquation position positive bounded]
  split
  · rfl
  · dsimp only
    split
    · rw [finishEquation _ startPositive startBound]
      by_cases nonzero : identifierEnd text (Cursor.triviaPosition text position) ≠ 0
      · have bounds := identifierEnd_bounds text _ nonzero
        rw [forbiddenEquation _ _ startPositive bounds.1 bounds.2]
      · simp [nonzero]
    · split
      · rw [finishEquation _ startPositive startBound]
        by_cases present : 0 < state.first
        · by_cases nonzero : identifierEnd text (Cursor.triviaPosition text position) ≠ 0
          · have nameBounds := identifierEnd_bounds text _ nonzero
            have stored : 0 < state.first ∧ state.first < state.after ∧ state.after ≤ text.length + 1 := by
              rcases valid with empty | stored
              · omega
              · exact stored
            rw [equalEquation _ _ _ _ (by omega) stored.2.1 stored.2.2
              startPositive nameBounds.1 nameBounds.2]
          · simp [nonzero]
        · simp [present]
      · split
        · by_cases available : Cursor.triviaPosition text position ≤ text.length
          · rw [literalEquation _ (by omega) (by omega)]
          · simp [available]
        · rw [tokenEquation _ _ startPositive startBound]

end Silver.Named
