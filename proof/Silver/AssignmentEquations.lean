module

public import Silver.AssignmentAdmission
public import Silver.GuardedEquations
public import Silver.NamedEquations

@[expose] public section

namespace Silver.Assignment

open Named

def suffixAtIndex (text : Source) (position nextToken : Nat) (state : NameState) (initialLength : Nat) : Bool :=
  suffixMatches text (requiredTokens.drop (nextToken - 1)) nextToken position state initialLength

def suffixEquation (recurse : Nat → Nat → NameState → Nat → Bool) (text : Source)
    (position nextToken : Nat) (state : NameState) (initialLength : Nat) : Bool :=
  if nextToken > requiredTokens.length then decide (Cursor.triviaPosition text position = text.length + 1)
  else
    let token := requiredTokens.getD (nextToken - 1) (.base .semicolon)
    let start := Cursor.triviaPosition text position
    if token = .declarationName then
      decide (identifierEnd text start ≠ 0) && !forbiddenName text start (identifierEnd text start) &&
        recurse (identifierEnd text start) (nextToken + 1) ⟨start, identifierEnd text start⟩ initialLength
    else if token = .referenceName then
      decide (0 < state.first) && decide (identifierEnd text start ≠ 0) &&
        equalName text state.first state.after start (identifierEnd text start) &&
        recurse (identifierEnd text start) (nextToken + 1) state initialLength
    else if token = .base .stringLiteral then
      decide (start ≤ text.length) && (Cursor.byteAt text start == 34) &&
        decide (Output.literalEnd text (start + 1) ≠ 0) &&
        (if nextToken > 17 then decide (Guarded.literalLength text (start + 1) = initialLength) else true) &&
        recurse (Output.literalEnd text (start + 1)) (nextToken + 1) state
          (if nextToken = 17 then Guarded.literalLength text (start + 1) else initialLength)
    else Named.tokenAt text start token && recurse (start + token.spelling.length) (nextToken + 1) state initialLength

theorem suffixAtIndex_equation (text : Source) (position nextToken : Nat) (state : NameState) (initialLength : Nat)
    (first : 1 ≤ nextToken) :
    suffixAtIndex text position nextToken state initialLength = suffixEquation (suffixAtIndex text) text position nextToken state initialLength := by
  unfold suffixAtIndex suffixEquation
  by_cases finished : nextToken > requiredTokens.length
  · have enough : requiredTokens.length ≤ nextToken - 1 := by omega
    simp [finished, List.drop_eq_nil_of_le enough, suffixMatches]
  · have index : nextToken - 1 < requiredTokens.length := by omega
    have drop := List.drop_eq_getElem_cons index
    have next : nextToken - 1 + 1 = nextToken := by omega
    simp only [finished, ↓reduceIte, Nat.add_sub_cancel, drop, suffixMatches, next]
    simp only [List.getD, List.getElem?_eq_getElem index, Option.getD_some]

theorem suffixAtIndex_unique (text : Source) (textBound : text.length ≤ maxSourceLength) (implementation : Nat → Nat → NameState → Nat → Bool)
    (equations : ∀ position nextToken state initialLength,
      1 ≤ position → position ≤ text.length + 1 → 1 ≤ nextToken → nextToken ≤ requiredTokens.length + 1 →
      state.Valid text → initialLength ≤ maxSourceLength → implementation position nextToken state initialLength =
        suffixEquation implementation text position nextToken state initialLength)
    (position nextToken : Nat) (state : NameState) (initialLength : Nat)
    (positive : 1 ≤ position) (bounded : position ≤ text.length + 1)
    (first : 1 ≤ nextToken) (last : nextToken ≤ requiredTokens.length + 1) (valid : state.Valid text) (lengthBound : initialLength ≤ maxSourceLength) :
    implementation position nextToken state initialLength = suffixAtIndex text position nextToken state initialLength := by
  rw [equations position nextToken state initialLength positive bounded first last valid lengthBound,
    suffixAtIndex_equation text position nextToken state initialLength first]
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
        rw [suffixAtIndex_unique text textBound implementation equations (identifierEnd text start) (nextToken + 1)
          ⟨start, identifierEnd text start⟩ initialLength (by omega) bounds.2 (by omega) (by omega)
          nextValid lengthBound]
      · simp [start] at nonzero
        simp [nonzero]
    · change (if token = .declarationName then _ else _) = (if token = .declarationName then _ else _)
      simp only [declaration, ↓reduceIte]
      change (if token = .referenceName then _ else _) = (if token = .referenceName then _ else _)
      by_cases reference : token = .referenceName
      · simp only [reference, ↓reduceIte]
        by_cases nonzero : identifierEnd text start ≠ 0
        · have bounds := identifierEnd_bounds text start nonzero
          rw [suffixAtIndex_unique text textBound implementation equations (identifierEnd text start) (nextToken + 1)
            state initialLength (by omega) bounds.2 (by omega) (by omega) valid lengthBound]
        · simp [start] at nonzero
          simp [nonzero]
      · simp only [reference, ↓reduceIte]
        change (if token = .base .stringLiteral then _ else _) = (if token = .base .stringLiteral then _ else _)
        by_cases literal : token = .base .stringLiteral
        · simp only [literal, ↓reduceIte]
          by_cases nonzero : Output.literalEnd text (start + 1) ≠ 0
          · have bounds := Output.literalEnd_bounds text (start + 1) nonzero
            have nextLength : (if nextToken = 17 then Guarded.literalLength text (start + 1) else initialLength) ≤ maxSourceLength := by
              split
              · have boundedLength := Guarded.literalLength_bound text (start + 1)
                omega
              · exact lengthBound
            rw [suffixAtIndex_unique text textBound implementation equations (Output.literalEnd text (start + 1))
              (nextToken + 1) state (if nextToken = 17 then Guarded.literalLength text (start + 1) else initialLength)
              (by omega) bounds.2 (by omega) (by omega) valid nextLength]
          · simp [start] at nonzero
            simp [nonzero]
        · simp only [literal, ↓reduceIte]
          by_cases matched : Named.tokenAt text start token = true
          · have enough := matched
            simp only [Named.tokenAt, Bool.and_eq_true, decide_eq_true_eq] at enough
            rw [suffixAtIndex_unique text textBound implementation equations (start + token.spelling.length)
              (nextToken + 1) state initialLength (by omega) (by omega) (by omega) (by omega) valid lengthBound]
          · have noMatch := Bool.eq_false_iff.mpr matched
            change (Named.tokenAt text start token && _) = (Named.tokenAt text start token && _)
            simp [noMatch]
termination_by requiredTokens.length + 1 - nextToken
decreasing_by all_goals omega

structure Calls where
  suffix : Source → Nat → Nat → NameState → Nat → Bool

structure DefinitionEquations (calls : Calls) : Prop where
  suffix : ∀ text, 0 < text.length → text.length ≤ maxSourceLength →
    ∀ position nextToken state initialLength, 1 ≤ position → position ≤ text.length + 1 →
      1 ≤ nextToken → nextToken ≤ requiredTokens.length + 1 → state.Valid text → initialLength ≤ maxSourceLength →
      calls.suffix text position nextToken state initialLength = suffixEquation (calls.suffix text) text position nextToken state initialLength
/-- Concrete witnesses establish that the equation interfaces are inhabited;
actual SPARK interpretation additionally requires the checked source bridge. -/
def modelCalls : Calls where
  suffix := suffixAtIndex

theorem model_equations : DefinitionEquations modelCalls where
  suffix := by
    intro text _ _ position nextToken state initialLength _ _ first _ _ _
    exact suffixAtIndex_equation text position nextToken state initialLength first

/-- The actual named suffix equation keeps every callee arbitrary. Each call
is closed only on the short-circuit branch where its verified precondition holds. -/
def sourceSuffixEquation (trivia literal finish length : Nat → Nat)
    (forbidden : Nat → Nat → Bool) (equal : Nat → Nat → Nat → Nat → Bool)
    (tokenMatch : Nat → Token → Bool) (recurse : Nat → Nat → NameState → Nat → Bool)
    (text : Source) (position nextToken : Nat) (state : NameState) (initialLength : Nat) : Bool :=
  if nextToken > requiredTokens.length then decide (trivia position = text.length + 1)
  else
    let token := requiredTokens.getD (nextToken - 1) (.base .semicolon)
    let start := trivia position
    if token = .declarationName then
      decide (finish start ≠ 0) && !forbidden start (finish start) &&
        recurse (finish start) (nextToken + 1) ⟨start, finish start⟩ initialLength
    else if token = .referenceName then
      decide (0 < state.first) && decide (finish start ≠ 0) &&
        equal state.first state.after start (finish start) &&
        recurse (finish start) (nextToken + 1) state initialLength
    else if token = .base .stringLiteral then
      decide (start ≤ text.length) && (Cursor.byteAt text start == 34) &&
        decide (literal (start + 1) ≠ 0) &&
        (if nextToken > 17 then decide (length (start + 1) = initialLength) else true) &&
        recurse (literal (start + 1)) (nextToken + 1) state
          (if nextToken = 17 then length (start + 1) else initialLength)
    else tokenMatch start token && recurse (start + token.spelling.length) (nextToken + 1) state initialLength

/-- The checked bounds justify every helper call on the branch that evaluates
it. No equation is requested for a zero sentinel or invalid binding span. -/
theorem sourceSuffixEquation_reduce
    (trivia literal finish length : Nat → Nat)
    (forbidden : Nat → Nat → Bool) (equal : Nat → Nat → Nat → Nat → Bool)
    (tokenMatch : Nat → Token → Bool) (recurse : Nat → Nat → NameState → Nat → Bool)
    (text : Source)
    (triviaEquation : ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      trivia position = Cursor.triviaPosition text position)
    (finishEquation : ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      finish position = identifierEnd text position)
    (literalEquation : ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      literal position = Output.literalEnd text position)
    (lengthEquation : ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      length position = Guarded.literalLength text position)
    (forbiddenEquation : ∀ first after, 1 ≤ first → first < after → after ≤ text.length + 1 →
      forbidden first after = forbiddenName text first after)
    (equalEquation : ∀ leftFirst leftAfter rightFirst rightAfter,
      1 ≤ leftFirst → leftFirst < leftAfter → leftAfter ≤ text.length + 1 →
      1 ≤ rightFirst → rightFirst < rightAfter → rightAfter ≤ text.length + 1 →
      equal leftFirst leftAfter rightFirst rightAfter = equalName text leftFirst leftAfter rightFirst rightAfter)
    (tokenEquation : ∀ position token, 1 ≤ position → position ≤ text.length + 1 →
      tokenMatch position token = Named.tokenAt text position token)
    (position nextToken : Nat) (state : NameState) (initialLength : Nat)
    (positive : 1 ≤ position) (bounded : position ≤ text.length + 1) (valid : state.Valid text) :
    sourceSuffixEquation trivia literal finish length forbidden equal tokenMatch recurse text position nextToken state initialLength =
      suffixEquation recurse text position nextToken state initialLength := by
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
          · rw [literalEquation _ (by omega) (by omega), lengthEquation _ (by omega) (by omega)]
          · simp [available]
        · rw [tokenEquation _ _ startPositive startBound]

end Silver.Assignment
