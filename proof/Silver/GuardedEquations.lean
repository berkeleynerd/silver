import Silver.GuardedAdmission
import Silver.ArgumentsEquations

namespace Silver.Guarded

open Named

/-- One step of the Ada expression, with the recursive call left arbitrary. -/
def decimalTailEquation (recurse : Nat → Nat → DecimalResult)
    (text : Source) (position value : Nat) : DecimalResult :=
  if position > text.length then ⟨position, value⟩
  else if ¬ digit (Cursor.byteAt text position) then
    if identifierCharacter (Cursor.byteAt text position) then invalidDecimal
    else ⟨position, value⟩
  else if value > (maxSourceLength - (Cursor.byteAt text position - 48)) / 10 then
    invalidDecimal
  else recurse (position + 1) (10 * value + (Cursor.byteAt text position - 48))

def decimalAtEquation (tail : Nat → Nat → DecimalResult)
    (text : Source) (position : Nat) : DecimalResult :=
  if position > text.length ∨ ¬ digit (Cursor.byteAt text position) then invalidDecimal
  else if Cursor.byteAt text position = 48 then
    if position < text.length ∧ identifierCharacter (Cursor.byteAt text (position + 1)) = true then
      invalidDecimal
    else ⟨position + 1, 0⟩
  else tail (position + 1) (Cursor.byteAt text position - 48)

def literalLengthEquation (recurse : Nat → Nat) (text : Source) (position : Nat) : Nat :=
  if position > text.length then 0
  else if Cursor.byteAt text position = 34 then
    if position < text.length ∧ Cursor.byteAt text (position + 1) = 34 then
      1 + recurse (position + 2) else 0
  else if 32 ≤ Cursor.byteAt text position ∧ Cursor.byteAt text position ≤ 126 then
    1 + recurse (position + 1) else 0

theorem decimalTail_equation (text : Source) (position value : Nat) :
    decimalTail text position value = decimalTailEquation (decimalTail text) text position value := by
  rw [decimalTail]
  rfl

theorem decimalTail_unique (text : Source) (implementation : Nat → Nat → DecimalResult)
    (equations : ∀ position value, 1 ≤ position → position ≤ text.length + 1 →
      value ≤ maxSourceLength → implementation position value =
        decimalTailEquation implementation text position value)
    (position value : Nat) (positive : 1 ≤ position)
    (bounded : position ≤ text.length + 1) (valueBound : value ≤ maxSourceLength) :
    implementation position value = decimalTail text position value := by
  rw [equations position value positive bounded valueBound, decimalTail_equation]
  unfold decimalTailEquation
  split
  · rfl
  · rename_i present
    split
    · rfl
    · rename_i isDigit
      split
      · rfl
      · rename_i fits
        have nextBound : 10 * value + (Cursor.byteAt text position - 48) ≤ maxSourceLength := by
          simp only [digit, maxSourceLength] at isDigit fits ⊢
          omega
        exact decimalTail_unique text implementation equations (position + 1)
          (10 * value + (Cursor.byteAt text position - 48)) (by omega) (by omega) nextBound
termination_by text.length + 1 - position
decreasing_by omega

theorem literalLength_equation (text : Source) (position : Nat) :
    literalLength text position = literalLengthEquation (literalLength text) text position := by
  rw [literalLength]
  simp only [literalLengthEquation, Output.printable, decide_eq_true_eq]

theorem literalLength_unique (text : Source) (implementation : Nat → Nat)
    (equations : ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      implementation position = literalLengthEquation implementation text position)
    (position : Nat) (positive : 1 ≤ position) (bounded : position ≤ text.length + 1) :
    implementation position = literalLength text position := by
  rw [equations position positive bounded, literalLength_equation]
  unfold literalLengthEquation
  split
  · rfl
  · rename_i present
    split
    · split
      · rename_i escaped
        rw [literalLength_unique text implementation equations (position + 2) (by omega) (by omega)]
      · rfl
    · split
      · rw [literalLength_unique text implementation equations (position + 1) (by omega) (by omega)]
      · rfl
termination_by text.length + 1 - position
decreasing_by all_goals omega

def suffixAtIndex (text : Source) (position nextToken : Nat) (state : NameState)
    (capacity decorations : Nat) : Bool :=
  suffixMatches text (requiredTokens.drop (nextToken - 1)) nextToken position state capacity decorations

def suffixEquation (recurse : Nat → Nat → NameState → Nat → Nat → Bool) (text : Source)
    (position nextToken : Nat) (state : NameState) (capacity decorations : Nat) : Bool :=
  if nextToken > requiredTokens.length then
    decide (Cursor.triviaPosition text position = text.length + 1) &&
      decide (capacity + decorations = maxSourceLength)
  else
    let token := requiredTokens.getD (nextToken - 1) (.base .semicolon)
    let start := Cursor.triviaPosition text position
    if token = .declarationName then
      decide (identifierEnd text start ≠ 0) && !forbiddenName text start (identifierEnd text start) &&
        recurse (identifierEnd text start) (nextToken + 1) ⟨start, identifierEnd text start⟩ capacity decorations
    else if token = .referenceName then
      decide (0 < state.first) && decide (identifierEnd text start ≠ 0) &&
        equalName text state.first state.after start (identifierEnd text start) &&
        recurse (identifierEnd text start) (nextToken + 1) state capacity decorations
    else if token = .capacityLiteral then
      decide ((decimalAt text start).after ≠ 0) &&
        recurse (decimalAt text start).after (nextToken + 1) state (decimalAt text start).value decorations
    else if token = .base .stringLiteral then
      decide (start ≤ text.length) && (Cursor.byteAt text start == 34) &&
        decide (Output.literalEnd text (start + 1) ≠ 0) &&
        (if nextToken > 39 then decide (decorations + literalLength text (start + 1) ≤ maxSourceLength) else true) &&
        recurse (Output.literalEnd text (start + 1)) (nextToken + 1) state capacity
          (if nextToken > 39 then decorations + literalLength text (start + 1) else decorations)
    else tokenAt text start token &&
      recurse (start + token.spelling.length) (nextToken + 1) state capacity decorations

theorem suffixAtIndex_equation (text : Source) (position nextToken : Nat) (state : NameState)
    (capacity decorations : Nat) (first : 1 ≤ nextToken) :
    suffixAtIndex text position nextToken state capacity decorations =
      suffixEquation (suffixAtIndex text) text position nextToken state capacity decorations := by
  unfold suffixAtIndex suffixEquation
  by_cases finished : nextToken > requiredTokens.length
  · have enough : requiredTokens.length ≤ nextToken - 1 := by omega
    simp [finished, List.drop_eq_nil_of_le enough, suffixMatches]
  · have index : nextToken - 1 < requiredTokens.length := by omega
    have drop := List.drop_eq_getElem_cons index
    have next : nextToken - 1 + 1 = nextToken := by omega
    simp only [finished, ↓reduceIte, Nat.add_sub_cancel, drop, suffixMatches, next]
    simp only [List.getD, List.getElem?_eq_getElem index, Option.getD_some]

theorem suffixAtIndex_unique (text : Source)
    (implementation : Nat → Nat → NameState → Nat → Nat → Bool)
    (equations : ∀ position nextToken state capacity decorations,
      1 ≤ position → position ≤ text.length + 1 →
      1 ≤ nextToken → nextToken ≤ requiredTokens.length + 1 → state.Valid text →
      capacity ≤ maxSourceLength → decorations ≤ maxSourceLength →
      implementation position nextToken state capacity decorations =
        suffixEquation implementation text position nextToken state capacity decorations)
    (position nextToken : Nat) (state : NameState) (capacity decorations : Nat)
    (positive : 1 ≤ position) (bounded : position ≤ text.length + 1)
    (first : 1 ≤ nextToken) (last : nextToken ≤ requiredTokens.length + 1)
    (valid : state.Valid text) (capBound : capacity ≤ maxSourceLength)
    (decoBound : decorations ≤ maxSourceLength) :
    implementation position nextToken state capacity decorations =
      suffixAtIndex text position nextToken state capacity decorations := by
  rw [equations position nextToken state capacity decorations positive bounded first last valid capBound decoBound,
    suffixAtIndex_equation text position nextToken state capacity decorations first]
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
        have nextValid : (⟨start, identifierEnd text start⟩ : NameState).Valid text :=
          Or.inr ⟨startPositive, bounds.1, bounds.2⟩
        rw [suffixAtIndex_unique text implementation equations (identifierEnd text start) (nextToken + 1)
          ⟨start, identifierEnd text start⟩ capacity decorations (by omega) bounds.2 (by omega) (by omega)
          nextValid capBound decoBound]
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
            state capacity decorations (by omega) bounds.2 (by omega) (by omega) valid capBound decoBound]
        · simp [start] at nonzero
          simp [nonzero]
      · simp only [reference, ↓reduceIte]
        change (if token = .capacityLiteral then _ else _) = (if token = .capacityLiteral then _ else _)
        by_cases capacityToken : token = .capacityLiteral
        · simp only [capacityToken, ↓reduceIte]
          by_cases nonzero : (decimalAt text start).after ≠ 0
          · have bounds := decimalAt_bounds (decimalAt_sound text start nonzero)
            rw [suffixAtIndex_unique text implementation equations (decimalAt text start).after
              (nextToken + 1) state (decimalAt text start).value decorations (by omega) bounds.2.1
              (by omega) (by omega) valid bounds.2.2 decoBound]
          · simp [start] at nonzero
            simp [nonzero]
        · simp only [capacityToken, ↓reduceIte]
          change (if token = .base .stringLiteral then _ else _) = (if token = .base .stringLiteral then _ else _)
          by_cases literal : token = .base .stringLiteral
          · simp only [literal, ↓reduceIte]
            by_cases nonzero : Output.literalEnd text (start + 1) ≠ 0
            · have bounds := Output.literalEnd_bounds text (start + 1) nonzero
              by_cases decorated : nextToken > 39
              · by_cases enough : decorations + literalLength text (start + 1) ≤ maxSourceLength
                · simp only [decorated, ↓reduceIte]
                  rw [suffixAtIndex_unique text implementation equations (Output.literalEnd text (start + 1))
                    (nextToken + 1) state capacity (decorations + literalLength text (start + 1))
                    (by omega) bounds.2 (by omega) (by omega) valid capBound enough]
                · simp [decorated, start, enough]
              · simp only [decorated, ↓reduceIte]
                rw [suffixAtIndex_unique text implementation equations (Output.literalEnd text (start + 1))
                  (nextToken + 1) state capacity decorations (by omega) bounds.2
                  (by omega) (by omega) valid capBound decoBound]
            · simp [start] at nonzero
              simp [nonzero]
          · simp only [literal, ↓reduceIte]
            by_cases matched : tokenAt text start token = true
            · have enough := matched
              simp only [tokenAt, Bool.and_eq_true, decide_eq_true_eq] at enough
              rw [suffixAtIndex_unique text implementation equations (start + token.spelling.length)
                (nextToken + 1) state capacity decorations (by omega) (by omega)
                (by omega) (by omega) valid capBound decoBound]
            · have noMatch := Bool.eq_false_iff.mpr matched
              change (tokenAt text start token && _) = (tokenAt text start token && _)
              simp [noMatch]
termination_by requiredTokens.length + 1 - nextToken
decreasing_by all_goals omega

/-- Calls remain arbitrary until separately established helper equations close
them on the precondition domains of the actual short-circuit expression. -/
def sourceSuffixEquation (trivia literal finish length : Nat → Nat)
    (decimal : Nat → DecimalResult) (forbidden : Nat → Nat → Bool)
    (equal : Nat → Nat → Nat → Nat → Bool) (tokenMatch : Nat → Token → Bool)
    (recurse : Nat → Nat → NameState → Nat → Nat → Bool)
    (text : Source) (position nextToken : Nat) (state : NameState)
    (capacity decorations : Nat) : Bool :=
  if nextToken > requiredTokens.length then
    decide (trivia position = text.length + 1) && decide (capacity + decorations = maxSourceLength)
  else
    let token := requiredTokens.getD (nextToken - 1) (.base .semicolon)
    let start := trivia position
    if token = .declarationName then
      decide (finish start ≠ 0) && !forbidden start (finish start) &&
        recurse (finish start) (nextToken + 1) ⟨start, finish start⟩ capacity decorations
    else if token = .referenceName then
      decide (0 < state.first) && decide (finish start ≠ 0) &&
        equal state.first state.after start (finish start) &&
        recurse (finish start) (nextToken + 1) state capacity decorations
    else if token = .capacityLiteral then
      decide ((decimal start).after ≠ 0) &&
        recurse (decimal start).after (nextToken + 1) state (decimal start).value decorations
    else if token = .base .stringLiteral then
      decide (start ≤ text.length) && (Cursor.byteAt text start == 34) &&
        decide (literal (start + 1) ≠ 0) &&
        (if nextToken > 39 then decide (decorations + length (start + 1) ≤ maxSourceLength) else true) &&
        recurse (literal (start + 1)) (nextToken + 1) state capacity
          (if nextToken > 39 then decorations + length (start + 1) else decorations)
    else tokenMatch start token &&
      recurse (start + token.spelling.length) (nextToken + 1) state capacity decorations

theorem sourceSuffixEquation_reduce
    (trivia literal finish length : Nat → Nat) (decimal : Nat → DecimalResult)
    (forbidden : Nat → Nat → Bool) (equal : Nat → Nat → Nat → Nat → Bool)
    (tokenMatch : Nat → Token → Bool) (recurse : Nat → Nat → NameState → Nat → Nat → Bool)
    (text : Source)
    (triviaEquation : ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      trivia position = Cursor.triviaPosition text position)
    (finishEquation : ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      finish position = identifierEnd text position)
    (literalEquation : ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      literal position = Output.literalEnd text position)
    (lengthEquation : ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      length position = literalLength text position)
    (decimalEquation : ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      decimal position = decimalAt text position)
    (forbiddenEquation : ∀ first after, 1 ≤ first → first < after → after ≤ text.length + 1 →
      forbidden first after = forbiddenName text first after)
    (equalEquation : ∀ leftFirst leftAfter rightFirst rightAfter,
      1 ≤ leftFirst → leftFirst < leftAfter → leftAfter ≤ text.length + 1 →
      1 ≤ rightFirst → rightFirst < rightAfter → rightAfter ≤ text.length + 1 →
      equal leftFirst leftAfter rightFirst rightAfter = equalName text leftFirst leftAfter rightFirst rightAfter)
    (tokenEquation : ∀ position token, 1 ≤ position → position ≤ text.length + 1 →
      tokenMatch position token = tokenAt text position token)
    (position nextToken : Nat) (state : NameState) (capacity decorations : Nat)
    (positive : 1 ≤ position) (bounded : position ≤ text.length + 1) (valid : state.Valid text) :
    sourceSuffixEquation trivia literal finish length decimal forbidden equal tokenMatch recurse
      text position nextToken state capacity decorations =
        suffixEquation recurse text position nextToken state capacity decorations := by
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
        · rw [decimalEquation _ startPositive startBound]
        · split
          · by_cases available : Cursor.triviaPosition text position ≤ text.length
            · rw [literalEquation _ (by omega) (by omega), lengthEquation _ (by omega) (by omega)]
            · simp [available]
          · rw [tokenEquation _ _ startPositive startBound]

end Silver.Guarded
