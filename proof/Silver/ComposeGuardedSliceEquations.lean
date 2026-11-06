module

public import Silver.ComposeCoreHelperEquations
public import Silver.ComposeStringEquations

@[expose] public section

namespace Silver.Compose.Expressions
variable {domain : StateDomain}
set_option maxRecDepth 10000
set_option maxHeartbeats 2000000
set_option backward.dsimp.instances true

/-- Interpret the actual recursive helper from its checked body and inherited
token/literal callees. No context-scanner meaning is a trusted premise. -/
theorem interpreted_guarded (calls : Calls) (equations : RawHelperEquations calls (domain := domain))
    (text : Source) (valid : ValidText text) (position limit depth : Nat) (chained ending : Bool)
    (positive : 0 < position) (bound : ValidCursor text position) (limitBound : ValidCursor text limit)
    (depthBound : depth ≤ maxSourceLength) :
    calls.function .guardedAt text position limit depth chained ending =
      guardedAt text position limit depth chained ending := by
  have skipped : position ≤ skipAt text position := by
    simpa only [skipAt, Nat.ne_of_gt positive, ↓reduceIte] using
      (Cursor.triviaPosition_bounds text position positive bound).1
  have firstPositive : 0 < skipAt text position := Nat.lt_of_lt_of_le positive skipped
  have stopBound : limit ≤ text.length + 1 := limitBound
  have firstBound := model_skip_valid text position bound
  have afterBound := model_name_valid text (skipAt text position)
  have quotedBound := (model_literal_valid text valid (skipAt text position)).1
  have characterBound : characterLiteralAfter text (skipAt text position) ≤ text.length + 1 := by
    by_cases zero : characterLiteralAfter text (skipAt text position) = 0
    · simp [zero]
    · exact (characterLiteralAfter_bounds zero).2
  rw [equations.guardedAt text valid position limit depth chained ending positive bound limitBound depthBound,
    guarded_denotation, guardedAt]
  simp only [show ¬ (position = 0 ∨ position > text.length + 1 ∨ limit > text.length + 1) from by
    unfold ValidCursor at *; omega, ↓reduceIte]
  change guardedEquation calls text position limit depth chained ending = _
  simp only [guardedEquation, decide_eq_true_eq]
  simp +instances only [interpreted_skip calls equations text valid position bound,
    interpreted_name calls equations text valid _ firstBound,
    interpreted_characterLiteral calls equations text valid _ firstBound,
    interpreted_literal calls equations text valid _ firstBound]
  split
  · rfl
  · rename_i before
    have beforeLimit : skipAt text position < limit := Nat.lt_of_not_ge before
    have inside : position < text.length + 1 :=
      Nat.lt_of_le_of_lt skipped (Nat.lt_of_lt_of_le beforeLimit stopBound)
    split
    · rename_i advances
      have decrease := Nat.sub_lt_sub_left inside (Nat.lt_of_le_of_lt skipped advances)
      exact interpreted_guarded calls equations text valid _ limit depth chained false
        (Nat.lt_trans firstPositive advances) characterBound limitBound depthBound
    · split
      · rename_i advances
        have decrease := Nat.sub_lt_sub_left inside (Nat.lt_of_le_of_lt skipped advances)
        exact interpreted_guarded calls equations text valid _ limit depth chained false
          (Nat.lt_trans firstPositive advances) quotedBound limitBound depthBound
      · split
        · rename_i ordered
          have decrease := Nat.sub_lt_sub_left inside (Nat.lt_of_le_of_lt skipped ordered)
          have namePositive := Nat.lt_trans firstPositive ordered
          have nameValid : ValidName text (skipAt text position) (nameAfter text (skipAt text position)) :=
            ⟨firstPositive, ordered, afterBound⟩
          simp +instances only [equations.nameIs text valid _ _ "if" nameValid (by decide) (by decide),
            equations.nameIs text valid _ _ "and" nameValid (by decide) (by decide),
            equations.nameIs text valid _ _ "or" nameValid (by decide) (by decide),
            equations.nameIs text valid _ _ "xor" nameValid (by decide) (by decide),
            equations.nameIs text valid _ _ "end" nameValid (by decide) (by decide)]
          split
          · split
            · exact interpreted_guarded calls equations text valid _ limit (depth - 1) chained false
                namePositive afterBound limitBound (by omega)
            · split
              · exact interpreted_guarded calls equations text valid _ limit 0 chained false
                  namePositive afterBound limitBound (by omega)
              · split
                · rfl
                · exact interpreted_guarded calls equations text valid _ limit (depth + 1) chained false
                    namePositive afterBound limitBound (by omega)
          · exact interpreted_guarded calls equations text valid _ limit depth _ _
              namePositive afterBound limitBound depthBound
        · have decrease := Nat.sub_lt_sub_left inside (Nat.lt_succ_of_le skipped)
          exact interpreted_guarded calls equations text valid _ limit depth _ false
            (Nat.zero_lt_succ _) (Nat.le_trans (Nat.succ_le_of_lt beforeLimit) stopBound) limitBound depthBound
termination_by text.length + 1 - position
decreasing_by all_goals assumption

end Silver.Compose.Expressions
