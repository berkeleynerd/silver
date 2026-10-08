import Silver.Cursor

/-!
The source-checked recursive bodies determine unique functions on their proved
domains. Consequently checking their equations is stronger than merely finding
a model that happens to satisfy the same equations. Recursive calls strictly
advance the cursor, as established by the SPARK variants and the Lean bounds.
-/

namespace Silver.Cursor

theorem commentPosition_unique (text : Source) (implementation : Nat → Nat)
    (equation : ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      implementation position =
        if position > text.length ∨ lineEnd (byteAt text position) = true then position
        else implementation (position + 1))
    (position : Nat) (hp : 1 ≤ position) (hl : position ≤ text.length + 1) :
    implementation position = commentPosition text position := by
  have complete : ∀ distance position, text.length + 1 - position = distance →
      1 ≤ position → position ≤ text.length + 1 →
      implementation position = commentPosition text position := by
    intro distance
    induction distance using Nat.strongRecOn with
    | ind distance ih =>
      intro position hd hp hl
      rw [equation position hp hl, commentPosition_equation text position hp hl]
      by_cases finished : position > text.length ∨ lineEnd (byteAt text position) = true
      · simp [finished]
      · simp only [finished, ↓reduceIte]
        exact ih (text.length + 1 - (position + 1)) (by omega) (position + 1) rfl (by omega) (by omega)
  exact complete _ position rfl hp hl

theorem triviaPosition_unique (text : Source) (implementation : Nat → Nat)
    (equation : ∀ position, 1 ≤ position → position ≤ text.length + 1 →
      implementation position =
        if position > text.length then position
        else if whitespace (byteAt text position) then implementation (position + 1)
        else if byteAt text position = 45 ∧ position < text.length ∧ byteAt text (position + 1) = 45
        then implementation (commentPosition text (position + 2))
        else position)
    (position : Nat) (hp : 1 ≤ position) (hl : position ≤ text.length + 1) :
    implementation position = triviaPosition text position := by
  have complete : ∀ distance position, text.length + 1 - position = distance →
      1 ≤ position → position ≤ text.length + 1 →
      implementation position = triviaPosition text position := by
    intro distance
    induction distance using Nat.strongRecOn with
    | ind distance ih =>
      intro position hd hp hl
      rw [equation position hp hl, triviaPosition_equation text position hp hl]
      by_cases finished : position > text.length
      · simp [finished]
      · simp only [finished, ↓reduceIte]
        by_cases space : whitespace (byteAt text position) = true
        · simp only [space]
          exact ih (text.length + 1 - (position + 1)) (by omega) (position + 1) rfl (by omega) (by omega)
        · simp only [space]
          by_cases comment : byteAt text position = 45 ∧ position < text.length ∧ byteAt text (position + 1) = 45
          · simp only [comment]
            have bound := commentPosition_bounds text (position + 2) (by omega) (by omega)
            exact ih (text.length + 1 - commentPosition text (position + 2)) (by omega)
              (commentPosition text (position + 2)) rfl (by omega) bound.2
          · simp [comment]
  exact complete _ position rfl hp hl

theorem suffixAtIndex_unique (text : Source) (implementation : Nat → Nat → Bool)
    (equation : ∀ position nextToken, 1 ≤ position → position ≤ text.length + 1 →
      1 ≤ nextToken → nextToken ≤ requiredTokens.length + 1 →
      implementation position nextToken =
        if nextToken > requiredTokens.length then
          decide (triviaPosition text position = text.length + 1)
        else
          let token := requiredTokens.getD (nextToken - 1) .semicolon
          tokenAt text (triviaPosition text position) token &&
            implementation (triviaPosition text position + token.spelling.length) (nextToken + 1))
    (position nextToken : Nat) (hp : 1 ≤ position) (hl : position ≤ text.length + 1)
    (hn : 1 ≤ nextToken) (ht : nextToken ≤ requiredTokens.length + 1) :
    implementation position nextToken = suffixAtIndex text position nextToken := by
  have complete : ∀ distance position nextToken,
      requiredTokens.length + 1 - nextToken = distance →
      1 ≤ position → position ≤ text.length + 1 →
      1 ≤ nextToken → nextToken ≤ requiredTokens.length + 1 →
      implementation position nextToken = suffixAtIndex text position nextToken := by
    intro distance
    induction distance using Nat.strongRecOn with
    | ind distance ih =>
      intro position nextToken hd hp hl hn ht
      rw [equation position nextToken hp hl hn ht, suffixAtIndex_equation text position nextToken hn]
      by_cases finished : nextToken > requiredTokens.length
      · simp [finished]
      · simp only [finished, ↓reduceIte]
        let token := requiredTokens.getD (nextToken - 1) .semicolon
        change (tokenAt text (triviaPosition text position) token &&
          implementation (triviaPosition text position + token.spelling.length) (nextToken + 1)) =
          (tokenAt text (triviaPosition text position) token &&
            suffixAtIndex text (triviaPosition text position + token.spelling.length) (nextToken + 1))
        have bounds := triviaPosition_bounds text position hp hl
        by_cases matched : tokenAt text (triviaPosition text position) token = true
        · have enough : token.spelling.length ≤ text.length + 1 - triviaPosition text position := by
            have conditions := matched
            simp only [tokenAt, Bool.and_eq_true, decide_eq_true_eq] at conditions
            exact conditions.1.1
          have recursive := ih (requiredTokens.length + 1 - (nextToken + 1)) (by omega)
            (triviaPosition text position + token.spelling.length) (nextToken + 1) rfl
            (by omega) (by omega) (by omega) (by omega)
          simp only [matched, Bool.true_and]
          exact recursive
        · have noMatch : tokenAt text (triviaPosition text position) token = false := Bool.eq_false_iff.mpr matched
          simp only [noMatch, Bool.false_and]
  exact complete _ position nextToken rfl hp hl hn ht

end Silver.Cursor
